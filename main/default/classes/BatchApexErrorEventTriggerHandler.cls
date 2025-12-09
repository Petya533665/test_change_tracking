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
		Set<String> existAsyncJobIds = new Set<String>();
		if ([SELECT COUNT() FROM Log__c WHERE Created_At__c = TODAY AND Async_Job_Id__c IN :asyncJobIds] < 49000) {
			List<AggregateResult> aggregateResults = [SELECT Async_Job_Id__c asyncJobId FROM Log__c WHERE Created_At__c = TODAY AND Async_Job_Id__c IN :asyncJobIds GROUP BY Async_Job_Id__c];
			for (AggregateResult aggregateResult : aggregateResults) {
				existAsyncJobIds.add((String)aggregateResult.get('asyncJobId'));
			}
		}
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null) {
				if (!JobBatch.isInternalError(asyncApexJob) || !existAsyncJobIds.contains(evt.AsyncApexJobId)) {
					Log__c log = JobBatch.createLog(asyncApexJob, corg);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Summary__c, evt.Message);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Details__c, evt.Phase + '\n\n' + evt.Message + '\n\n' + evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Type__c, String.isNotBlank(evt.ExceptionType) ? evt.ExceptionType : asyncApexJob.JobType);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace__c, evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Id__c, getRelatedId(evt.JobScope));
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Created_At__c, existAsyncJobIds.add(evt.AsyncApexJobId) ? Datetime.now() : Datetime.now().addSeconds(1));
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