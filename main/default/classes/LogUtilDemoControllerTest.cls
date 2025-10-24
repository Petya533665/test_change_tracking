@IsTest
private class LogUtilDemoControllerTest {

	@TestSetup
	private static void testSetup() {
		Account account = new Account();
		account.Name = 'test';
		insert account;
	}

	@IsTest
	private static void test_scenarioDMLError() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioDMLError(transactionId);
		Test.stopTest();
		System.assertEquals(2, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioTriggerError() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioTriggerError(transactionId);
		Test.stopTest();
		System.assertEquals(3, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioFlowError() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioFlowError(transactionId);
		Test.stopTest();
		System.assertEquals(4, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioAsyncSync1() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioAsyncSync1(transactionId);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioAsyncSync2() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioAsyncSync2(transactionId);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioApexCPU() {
		String transactionId = LogUtilDemoController.getTransactionId();
		Test.startTest();
		LogUtilDemoController.scenarioApexCPU(transactionId);
		Test.stopTest();
		System.assertEquals(6, [SELECT COUNT() FROM pharos__Log__c]);
	}

	@IsTest
	private static void test_scenarioApexCPU2() {
		Test.startTest();
		LogUtilDemoController.scenarioApexCPU2();
		Test.stopTest();
		System.assertEquals(2, [SELECT COUNT() FROM pharos__Log__c]);
	}

}