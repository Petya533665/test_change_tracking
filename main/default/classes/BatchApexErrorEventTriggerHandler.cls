public with sharing class BatchApexErrorEventTriggerHandler {

	public static void handleErrorEvents(List<BatchApexErrorEvent> errorEvents) {
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
		Set<String> hashes = new Set<String>();
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null && JobBatch.isInternalError(asyncApexJob)) hashes.add(JobBatch.getHash1(asyncApexJob));
		}

		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
		Set<String> existHashes = new Set<String>();
		if ([SELECT COUNT() FROM Log__c WHERE Created_At__c = TODAY AND Hash_1__c IN :hashes] < 49000) {
			List<AggregateResult> aggregateResults = [SELECT Hash_1__c hash FROM Log__c WHERE Created_At__c = TODAY AND Hash_1__c IN :hashes GROUP BY Hash_1__c];
			for (AggregateResult aggregateResult : aggregateResults) {
				existHashes.add((String)aggregateResult.get('hash'));
			}
		}
		for (BatchApexErrorEvent evt : errorEvents) {
			AsyncApexJob asyncApexJob = JobBatch.getAsyncApexJob(evt.AsyncApexJobId, jobs, parentJobs);
			if (asyncApexJob != null) {
				String hash = JobBatch.getHash1(asyncApexJob);
				if (!JobBatch.isInternalError(asyncApexJob) || !existHashes.contains(hash)) {
					Log__c log = JobBatch.createLog(asyncApexJob, corg);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Summary__c, evt.Message);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Details__c, evt.Phase + '\n\n' + evt.Message + '\n\n' + evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Type__c, String.isNotBlank(evt.ExceptionType) ? evt.ExceptionType : asyncApexJob.JobType);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace__c, evt.StackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Id__c, getRelatedId(evt.JobScope));
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Created_At__c, existHashes.add(hash) ? Datetime.now() : Datetime.now().addSeconds(1));
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