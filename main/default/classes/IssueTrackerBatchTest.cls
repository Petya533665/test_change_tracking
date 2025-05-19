@IsTest
private class IssueTrackerBatchTest {

	@IsTest
	private static void test_batch_case_1() {
		Test.startTest();
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 2', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		IssueTrackerBatch.getInstance().startBatch();
		Test.stopTest();
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c]);
	}

	@IsTest
	private static void test_batch_case_2() {
		Test.startTest();
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 2', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, true);
		IssueTrackerBatch.getInstance().startBatch();
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c]);
	}

	@IsTest
	private static void test_batch_case_3() {
		Test.startTest();
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 2', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, true);
		IssueTrackerBatch.getInstance().startBatch();
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 1', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, false);
		insert createLog('test hash 2', System.now(), IssueService.POST_PROCESSING_STATUS_COMPLETED, null, true);
		IssueTrackerBatch.getInstance().startBatch();
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c]);
	}

	private static Log__c createLog(String hash_1, Datetime createdAt, String postProcessingStatus, String originatedFrom, Boolean doNotCreateIssue) {
		return new Log__c(
				Summary__c = 'test',
				Details__c = 'test',
				Hash_1__c = hash_1,
				Created_At__c = createdAt,
				Post_Processing_Status__c = postProcessingStatus,
				Originated_From__c = originatedFrom,
				Do_Not_Create_Issue__c = doNotCreateIssue
		);
	}

}