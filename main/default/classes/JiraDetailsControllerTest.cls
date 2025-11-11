@IsTest
public with sharing class JiraDetailsControllerTest {

    private static final String JIRA_MOCK_REST_ENDPOINT = 'http://test.jira.com';

    private static final String BUG_TRACKER_TEMPLATE = '{0}/browse/{1}';

    private static final String LOG_BUG_TRACKER_JIRA_TASK_KEY = 'TEST-123';
    private static final String LOG_BUG_TRACKER_JIRA = String.format(BUG_TRACKER_TEMPLATE, new List<String>{
        JIRA_MOCK_REST_ENDPOINT,
        LOG_BUG_TRACKER_JIRA_TASK_KEY
    });

    private static final String LOG_BUG_TRACKER_AZURE_WORK_ITEM_ID = 'testWorkItemId';
    private static final String LOG_BUG_TRACKER_AZURE_PROJECT_ID = 'testProjectId';
    private static final String LOG_BUG_TRACKER_AZURE_ORGANIZATION_ID = 'testOrganizationId';
    private static final String LOG_BUG_TRACKER_AZURE_TEMPLATE = 'https://dev.azure.com/{0}/{1}/_workitems/edit/{2}';
    private static final String LOG_BUG_TRACKER_AZURE = String.format(LOG_BUG_TRACKER_AZURE_TEMPLATE, new List<String>{
        LOG_BUG_TRACKER_AZURE_ORGANIZATION_ID,
        LOG_BUG_TRACKER_AZURE_PROJECT_ID,
        LOG_BUG_TRACKER_AZURE_WORK_ITEM_ID
    });

    private static final String ISSUE_BUG_TRACKER_JIRA_TASK_KEY = 'TEST-456';
    private static final String ISSUE_BUG_TRACKER_JIRA = String.format(BUG_TRACKER_TEMPLATE, new List<String>{
        JIRA_MOCK_REST_ENDPOINT,
        ISSUE_BUG_TRACKER_JIRA_TASK_KEY
    });
    
    @TestSetup
    static void testSetup() {

        Jira_Settings__c jiraSettings = new Jira_Settings__c();
        jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
        jiraSettings.Jira_API_Url__c = JIRA_MOCK_REST_ENDPOINT;
        jiraSettings.Jira_Username__c = 'jirausername';
        jiraSettings.Jira_API_Token__c = 'sometoken';
        jiraSettings.Create_Unique_Tickets_by_Org__c = true;
        jiraSettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert jiraSettings;

        // Create test Log__c record
        Log__c log = new Log__c();
        log.Type__c = 'ERROR';
        log.Category__c = 'Apex';
        log.Bug_Tracker__c = LOG_BUG_TRACKER_JIRA;
        log.Hash_1__c = 'testhash123';
        insert log;

        // Create test Issue__c record
        Issue__c issue = new Issue__c();
        issue.Status__c = 'New';
        issue.Summary__c = 'Test Issue';
        issue.Bug_Tracker__c = ISSUE_BUG_TRACKER_JIRA;
        insert issue;
    }
    
    @IsTest
    static void test_constructor_withLogRecordId() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.log, 'log should not be null');
        Assert.areEqual(log.Id, controller.log.Id, 'log ID should match');
        Assert.areNotEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should not be null');
        Assert.areEqual(LOG_BUG_TRACKER_JIRA, controller.jiraTaskUrl, 'jiraTaskUrl should match Bug_Tracker__c');
    }
    
    @IsTest
    static void test_constructor_withIssueRecordId() {
        Issue__c issue = [SELECT Id FROM Issue__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', issue.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        Test.stopTest();
        
        Assert.areEqual(null, controller.log, 'log should be null for Issue__c record');
        Assert.areNotEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should not be null');
        Assert.areEqual(ISSUE_BUG_TRACKER_JIRA, controller.jiraTaskUrl, 'jiraTaskUrl should match Issue Bug_Tracker__c');
    }
    
    @IsTest
    static void test_constructor_withInvalidRecordId() {
        // Set up page parameters with invalid ID
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', 'invalid_id');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Log__c());
        JiraDetailsController controller = new JiraDetailsController(stdController);
        Test.stopTest();
        
        Assert.areEqual(null, controller.log, 'log should be null for invalid record ID');
        Assert.areEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should be null for invalid record ID');
    }
    
    @IsTest
    static void test_constructor_withNullRecordId() {
        // Set up page parameters with null ID
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', null);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Log__c());
        JiraDetailsController controller = new JiraDetailsController(stdController);
        Test.stopTest();
        
        Assert.areEqual(null, controller.log, 'log should be null for null record ID');
        Assert.areEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should be null for null record ID');
    }
    
    @IsTest
    static void test_constructor_withEmptyRecordId() {
        // Set up page parameters with empty ID
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Log__c());
        JiraDetailsController controller = new JiraDetailsController(stdController);
        Test.stopTest();
        
        Assert.areEqual(null, controller.log, 'log should be null for empty record ID');
        Assert.areEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should be null for empty record ID');
    }
    
    @IsTest
    static void test_init_withJiraUrl() {
        Log__c log = [SELECT Id, Bug_Tracker__c FROM Log__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getJiraMock()));
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        controller.init();
        Test.stopTest();
        
        Assert.areEqual(null, controller.isAzure, 'isAzure should be null for Jira URL');
        Assert.areNotEqual(null, controller.jiraTaskUrl, 'jiraTaskUrl should not be null');
        Assert.areEqual('ticketId', controller.jiraTask, 'jiraTask should not be null');
    }
    
    @IsTest
    static void test_init_withAzureUrl() {
        // Create Log__c with Azure URL
        Log__c log = new Log__c();
        log.Type__c = 'ERROR';
        log.Category__c = 'Apex';
        log.Bug_Tracker__c = LOG_BUG_TRACKER_AZURE;
        log.Hash_1__c = 'testhash456';
        insert log;

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getAzureMocks()));
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        controller.init();
        Test.stopTest();
        
        Assert.isTrue(controller.isAzure, 'isAzure should be true for Azure URL');
        Assert.areNotEqual(null, controller.workItem, 'workItem should not be null');
        Assert.areNotEqual(null, controller.workItemComments, 'workItemComments should not be null');
        // Note: workItem and workItemComments may contain error messages if Azure service is not available in test context
    }
    
    @IsTest
    static void test_properties() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        
        // Test property getters
        String jiraTaskUrl = controller.jiraTaskUrl;
        String jiraTask = controller.jiraTask;
        Log__c logProperty = controller.log;
        Boolean isAzure = controller.isAzure;
        String workItem = controller.workItem;
        String workItemComments = controller.workItemComments;
        
        // Test property setters
        controller.jiraTaskUrl = 'test-url';
        controller.jiraTask = 'test-task';
        controller.isAzure = true;
        controller.workItem = 'test-workitem';
        controller.workItemComments = 'test-comments';
        
        Test.stopTest();
        
        Assert.areEqual('test-url', controller.jiraTaskUrl, 'jiraTaskUrl setter should work');
        Assert.areEqual('test-task', controller.jiraTask, 'jiraTask setter should work');
        Assert.isTrue(controller.isAzure, 'isAzure setter should work');
        Assert.areEqual('test-workitem', controller.workItem, 'workItem setter should work');
        Assert.areEqual('test-comments', controller.workItemComments, 'workItemComments setter should work');
    }
    
    @IsTest
    static void test_init_exceptionHandling() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.JiraDetails;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraDetailsController controller = new JiraDetailsController(stdController);
        
        // Set an invalid URL to trigger exception
        controller.jiraTaskUrl = 'invalid-url-that-will-cause-exception';
        controller.init();
        
        Test.stopTest();
        
        // Should handle exception gracefully and set jiraTask to error message
        Assert.areNotEqual(null, controller.jiraTask, 'jiraTask should contain error message when exception occurs');
    }

    private static Map<String, HttpCalloutMock> getJiraMock() {
        return new Map<String, HttpCalloutMock>{
            JiraService.getService().getExpandedIssueEndpoint(LOG_BUG_TRACKER_JIRA_TASK_KEY) =>
            new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                'ticketId'
            )
        };
    }

    private static Map<String, HttpCalloutMock> getAzureMocks() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(getAzureDevOpsWorkItemMock());
        endpoint2TestResp.putAll(getAzureDevOpsWorkItemCommentsWrapMock());
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsWorkItemMock() {
        AzureService.AzureDevOpsWorkItem azureDevOpsWorkItem = new AzureService.AzureDevOpsWorkItem();
        azureDevOpsWorkItem.Id = 'testAzureDevOpsWorkItemId';
        azureDevOpsWorkItem.rev = 1;
        azureDevOpsWorkItem.url = 'testUrl';
        azureDevOpsWorkItem.organizationName = 'testOrganizationName';

        return new Map<String, HttpCalloutMock>{
            String.format(
                AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL,
                new List<String>{
                    LOG_BUG_TRACKER_AZURE_ORGANIZATION_ID,
                    LOG_BUG_TRACKER_AZURE_PROJECT_ID,
                    LOG_BUG_TRACKER_AZURE_WORK_ITEM_ID
            }) =>
            new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(azureDevOpsWorkItem)
            )
        };
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsWorkItemCommentsWrapMock() {
        AzureService.AzureDevOpsWorkItemComment wic = new AzureService.AzureDevOpsWorkItemComment();
		wic.workItemId = 123;
		wic.id = 'testId';
		wic.text = 'testText';

        AzureService.AzureDevOpsWorkItemCommentsWrap wicWrap = new AzureService.AzureDevOpsWorkItemCommentsWrap();
        wicWrap.totalCount = 1;
        wicWrap.count = 1;
        wicWrap.comments = new List<AzureService.AzureDevOpsWorkItemComment>{ wic };

        return new Map<String, HttpCalloutMock>{
            String.format(
                AzureApiClient.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENTS,
                new List<String>{
                    LOG_BUG_TRACKER_AZURE_ORGANIZATION_ID,
                    LOG_BUG_TRACKER_AZURE_PROJECT_ID,
                    LOG_BUG_TRACKER_AZURE_WORK_ITEM_ID
            }) =>
            new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(wicWrap)
            )
        };
    }
}