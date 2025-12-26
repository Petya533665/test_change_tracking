public with sharing class BatchApexErrorEventTriggerHandler {

	public static void handleErrorEvents(List<BatchApexErrorEvent> errorEvents) {
		// Check AsyncProcessErrorTracking permission
		if (!PermissionsUtil.AsyncProcessErrorTracking) {
			return; // Skip processing if async process error tracking is disabled
		}

		Set<String> asyncApexJobIds = new Set<String>();
		for (BatchApexErrorEvent evt : errorEvents) {
			asyncApexJobIds.add(evt.AsyncApexJobId);
		}
		Map<Id, AsyncApexJob> jobs = JobBatch.getAsyncApexJobsById(asyncApexJobIds);
		Set<String> parentAsyncApexJobIds = new Set<String>();
		for (AsyncApexJob asyncApexJob : jobs.values()) {
			if (String.isNotBlank(asyncApexJob.ParentJobId)) parentAsyncApexJobIds.add(asyncApexJob.ParentJobId);
		}
		Map<Id, AsyncApexJob> parentJobs = JobBatch.getAsyncApexJobsById(parentAsyncApexJobIds);
		Set<String> asyncJobIds = new Set<String>();
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null && JobBatch.isInternalError(asyncApexJob)) asyncJobIds.add(evt.AsyncApexJobId);
		}

		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
		// Hybrid approach: check both Hash_1__c and Async_Job_Id__c
		Map<String, String> hash1ByAsyncJobId = new Map<String, String>();
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null && JobBatch.isInternalError(asyncApexJob)) {
				String hash1 = JobBatch.getHash1(asyncApexJob);
				hash1ByAsyncJobId.put(evt.AsyncApexJobId, hash1);
			}
		}
		
		// Check for existing logs by Hash_1__c (no time window - Log_Index__c handles historical deduplication)
		Set<String> existHash1Values = new Set<String>();
		if (!hash1ByAsyncJobId.isEmpty() && [SELECT COUNT() FROM Log__c WHERE Hash_1__c IN :hash1ByAsyncJobId.values()] < Constants.QUERY_LIMITS.MAX_COUNT_FOR_SAFE_AGGREGATE_RESULT_QUERY) {
			List<AggregateResult> aggregateResults = [SELECT Hash_1__c hash1 FROM Log__c WHERE Hash_1__c IN :hash1ByAsyncJobId.values() GROUP BY Hash_1__c];
			for (AggregateResult aggregateResult : aggregateResults) {
				existHash1Values.add((String)aggregateResult.get('hash1'));
			}
		}
		
		// Check for existing logs by Async_Job_Id__c (fallback for logs updated by EventLogProcessingBatch)
		Set<String> existAsyncJobIds = new Set<String>();
		if ([SELECT COUNT() FROM Log__c WHERE Async_Job_Id__c IN :asyncJobIds] < Constants.QUERY_LIMITS.MAX_COUNT_FOR_SAFE_AGGREGATE_RESULT_QUERY) {
			List<AggregateResult> aggregateResults = [SELECT Async_Job_Id__c asyncJobId FROM Log__c WHERE Async_Job_Id__c IN :asyncJobIds GROUP BY Async_Job_Id__c];
			for (AggregateResult aggregateResult : aggregateResults) {
				existAsyncJobIds.add((String)aggregateResult.get('asyncJobId'));
			}
		}
			
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null) {
				String hash1 = hash1ByAsyncJobId.get(evt.AsyncApexJobId);
				// Skip if: internal error AND (found by Hash_1__c OR found by Async_Job_Id__c)
				Boolean foundByHash1 = hash1 != null && existHash1Values.contains(hash1);
				Boolean foundByAsyncJobId = existAsyncJobIds.contains(evt.AsyncApexJobId);
				if (!JobBatch.isInternalError(asyncApexJob) || (!foundByHash1 && !foundByAsyncJobId)) {
					Log__c log = JobBatch.createLog(asyncApexJob, corg);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Summary__c, evt.Message);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Details__c, evt.Phase + '\n\n' + evt.Message + '\n\n' + evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Type__c, String.isNotBlank(evt.ExceptionType) ? evt.ExceptionType : asyncApexJob.JobType);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace__c, evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Id__c, getRelatedId(evt.JobScope));
					
					// CRITICAL FIX: Recalculate hashes with stacktrace-based formula
					// Platform event provides stacktrace, so we must use correct hash formula
					// JobBatch.createLog() uses simple hash (className + error + jobType)
					// But with stacktrace, we need correct hash (stacktraceLines + summary)
					if (String.isNotBlank(evt.StackTrace)) {
						// Clear existing hashes to force recalculation
						log.Hash_1__c = null;
						log.Hash_2__c = null;
						log.Hash_3__c = null;
						// Recalculate with stacktrace-based formula
						LogService.calculateHashes(log);
						// Update hash1 for deduplication tracking with new correct value
						hash1 = log.Hash_1__c;
					}
					
					// Track both hash1 and asyncJobId to prevent duplicates within this batch
					Boolean isFirstOccurrence = (hash1 != null && existHash1Values.add(hash1)) || existAsyncJobIds.add(evt.AsyncApexJobId);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Created_At__c, isFirstOccurrence ? Datetime.now() : Datetime.now().addSeconds(1));
					Logger.getInstance().add(log);
				}
			}
		}
		Logger.getInstance().flush();
	}

	private static String getRelatedId(String jobScope) {
		String relatedId;
		if (String.isNotBlank(jobScope)) {
			for (String item : jobScope.split(',')) {
				relatedId = item;
				break;
			}
		}
		return relatedId;
	}

}