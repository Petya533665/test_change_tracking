@IsTest
private class PostInstallClassTest {

	@IsTest
	static void test_upgrade_patch_1_850_1() {
		test_upgrade_patch_1_850(1, true);
	}

	@IsTest
	static void test_upgrade_patch_1_850_0() {
		test_upgrade_patch_1_850(0, true);
	}

	@IsTest
	static void test_upgrade_patch_1_850_2() {
		test_upgrade_patch_1_850(2, true);
	}

	@IsTest
	static void test_upgrade_patch_1_850_3() {
		test_upgrade_patch_1_850(3, false);
	}

	static void test_upgrade_patch_1_850(Integer patch, Boolean success) {

		TestDataFactory.enableIssueTracking();
		Log__c newLog = LogTriggerHandlerTest.createPharosLog('somehash1');
		insert newLog;

		Issue__c issue = LogTriggerHandlerTest.createIssue(newLog.Id, 'somehash1');
		issue.Jira_Integration_Status__c = Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING;
		insert issue;

		Test.startTest();
		PostInstallClass postinstall = new PostInstallClass();
		Test.testInstall(postinstall, new Version(1, 850, patch), false);
		Test.stopTest();

		issue = [SELECT Jira_Integration_Status__c FROM Issue__c WHERE Id = :issue.Id LIMIT 1];
		if(success) {
			System.assertEquals(Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED, issue.Jira_Integration_Status__c);
		}
		else {
			System.assertEquals(Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING, issue.Jira_Integration_Status__c);
		}
		
	}

	@IsTest
	static void testPositiveUpgrade_1_754() {
		testLogIndexBatchOnUpgrade(true, 1, 754);
	}
	@IsTest
	static void testPositiveUpgrade_1_755() {
		testLogIndexBatchOnUpgrade(false, 1, 755);
	}


	static void testLogIndexBatchOnUpgrade(Boolean isPositive, Integer major, Integer minor) {
		Log__c log1 = new Log__c();
		log1.Created_At__c = DateTime.now();
		log1.Hash_1__c = null;
		insert log1;
		log1.Hash_1__c = 'sometesthash1';
		update log1;
		Test.startTest();
		PostInstallClass postinstall = new PostInstallClass();
		Test.testInstall(postinstall, new Version(major, minor), false);
		Test.stopTest();

		Integer countIndexes = [SELECT COUNT() FROM Log_Index__c];
		System.assertEquals(isPositive ? 1 : 0, countIndexes);
	}

	@IsTest
	static void testPopulateOldJiraRuleActionTypeField_1_590() {
		testPopulateOldJiraRuleActionTypeField(1, 590);
	}

	@IsTest
	static void testPopulateOldJiraRuleActionTypeField_1_707() {
		testPopulateOldJiraRuleActionTypeField(1, 707);
	}

	static void testPopulateOldJiraRuleActionTypeField(Integer major, Integer minor) {
		Rule__c testRule = new Rule__c();
        testRule.Active__c = true;
        testRule.Index__c = 0;
	    testRule.Type__c = Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE;
        insert testRule;

        Action__c action = new Action__c(Type__c = Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION);
		insert action;
		
        RuleAction__c en1 = new RuleAction__c();
        en1.Action__c = action.Id;
        en1.Rule__c = testRule.Id;
        insert en1;

		Rule__c before = [SELECT Id, (SELECT Id, Action__r.Type__c, Action__r.Action_Type__c FROM RuleActions__r) FROM Rule__c WHERE Id = :testRule.Id LIMIT 1];
		System.assertEquals(1, before.RuleActions__r.size());
		System.assertNotEquals(null, before.RuleActions__r.get(0).Action__r.Type__c);
		System.assertEquals(null, before.RuleActions__r.get(0).Action__r.Action_Type__c);

		Test.startTest();
		PostInstallClass postinstall = new PostInstallClass();
		Test.testInstall(postinstall, new Version(major, minor), false);
		Test.stopTest();

		Rule__c after = [SELECT Id, (SELECT Id, Action__r.Type__c, Action__r.Action_Type__c FROM RuleActions__r) FROM Rule__c WHERE Id = :testRule.Id LIMIT 1];
		System.assertEquals(1, after.RuleActions__r.size());
		System.assertEquals(after.RuleActions__r.get(0).Action__r.Type__c, after.RuleActions__r.get(0).Action__r.Action_Type__c);
	}
}