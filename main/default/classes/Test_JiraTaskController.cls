@IsTest
private class Test_JiraTaskController {

    @IsTest
    static void test1 () {

	    PermissionsUtil.JiraIntegrationEnabled = true;

        Jira_Settings__c jiraSettings = new Jira_Settings__c();
		jiraSettings.Jira_Base_Url__c = 'http://test.jira.com';
		jiraSettings.Jira_API_Url__c = 'http://test.jira.com';
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		jiraSettings.Create_Unique_Tickets_by_Org__c = true;
		insert jiraSettings;

        Log__c testLog = new Log__c();
        insert testLog;

        RuleUtil.Action testAction = new RuleUtil.Action();
        testAction.jiraLabels = 'TestLabel';
        testAction.jiraPriority = 'High';
        testAction.jiraAssigneeId = '12345';
        testAction.jiraEpic = 'Epic1';
        testAction.jiraProject = 'test';
        testAction.jiraIssueType = 'test';
        testAction.jiraComponents = 'Component1';
        testAction.subject = 'Test Subject';
        testAction.body = 'Test Body';
        testAction.type = 'Jira Notification';

        JiraTaskController.CreateJiraTicketRequest request = new JiraTaskController.CreateJiraTicketRequest();
        request.action = testAction;
        request.logId = testLog.Id;

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp = JiraNotificationBatchTest.createJiraMocks();

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        TicketingService.TicketCreateResult result = JiraTaskController.createTask(request);
        Test.stopTest();

        Log__c updatedLog = [SELECT Id, Bug_Tracker__c FROM Log__c WHERE Id = :testLog.Id];

        System.assertNotEquals(null, updatedLog.Bug_Tracker__c, 'Bug_Tracker__c field should be updated');
    }
}