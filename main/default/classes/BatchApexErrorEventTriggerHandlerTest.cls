@IsTest
private class BatchApexErrorEventTriggerHandlerTest {

	@IsTest
	private static void test_batch_error_handler() {
		// Enable AsyncProcessErrorTracking permission for this test
		PermissionsUtil.AsyncProcessErrorTracking = true;

		Log__c log = new Log__c();
		log.Hash_1__c = 'hash1';
		log.Async_Job_Id__c = '707KK00000KKK00KKK';
		log.Organization_Id__c = UserInfo.getOrganizationId();
		insert log;

		Integer logEventCountBefore = Limits.getPublishImmediateDML();

		try {
			Test.startTest();
			LogPostProcessingBatch.testThrowUnhandledException = true;
			LogPostProcessingBatch.getInstance().startBatch();
			Test.getEventBus().deliver();
			Test.stopTest();
			Integer logEventCountAfter = Limits.getPublishImmediateDML();
			System.assertEquals(1, logEventCountAfter);
			System.assertEquals(0, logEventCountBefore);
		}
		catch (Exception e) {}
		Test.getEventBus().deliver();
	}

	@IsTest
	private static void test_batch_error_handler_skips_when_permission_disabled() {
		// Disable AsyncProcessErrorTracking permission for this test
		PermissionsUtil.AsyncProcessErrorTracking = false;

		Log__c log = new Log__c();
		log.Hash_1__c = 'hash1';
		log.Async_Job_Id__c = '707KK00000KKK00KKK';
		log.Organization_Id__c = UserInfo.getOrganizationId();
		insert log;

		List<Log__c> logsBefore = [SELECT Id FROM Log__c];

		try {
			Test.startTest();
			LogPostProcessingBatch.testThrowUnhandledException = true;
			LogPostProcessingBatch.getInstance().startBatch();
			Test.getEventBus().deliver();
			Test.stopTest();
		}
		catch (Exception e) {}
		Test.getEventBus().deliver();

		List<Log__c> logsAfter = [SELECT Id FROM Log__c];
		// No additional logs should be created from BatchApexErrorEvent when permission is disabled
		System.assertEquals(logsBefore.size(), logsAfter.size(),
			'No additional logs should be created when AsyncProcessErrorTracking is disabled');
	}
}