@IsTest
private class BatchApexErrorEventTriggerHandlerTest {

	@IsTest
	private static void test_batch_error_handler() {

		Log__c log = new Log__c();
		log.Hash_1__c = 'hash1';
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
}