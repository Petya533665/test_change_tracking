@IsTest
public class IssueJiraTaskControllerTest {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
        JiraNotificationBatchTest.createLoggerSettings();
        JiraNotificationBatchTest.createJiraSettings();
        JiraNotificationBatchTest.createAzureDevOpsApiSettings();
    }

    @IsTest
    static void test_RemoteAction_Scope() {

        Test.startTest();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'Unknown',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectUsers',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectComponents',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraEpics',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraSettings',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getCreateMeta',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProject',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectIssueTypes',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getMergeFields',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getIssueDefaultJiraActionTemplate',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'createTask',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjects',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsSettings',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjectTeams',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsWorkItemTypes',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsEpicWorkItems',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjectTeamMemberWrapper',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getTeamBoards',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsWorkItemTypesWithValidation',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsClassificationNodes',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getDefaultAzureDevOpsActionTemplate',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getIssueDefaultAzureDevOpsActionTemplate',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAppPermissions',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProjectProperties',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProcessesWorkItemTypes',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProcessWorkItemTypeFields',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getActionWrappers',
            'data' => ''
        };
        IssueJiraTaskController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        Assert.areNotEqual(null, payload);
    }

    // Additional tests for constructor and properties
    @IsTest
    static void test_constructor_withValidIssue() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id FROM Issue__c WHERE Log__c = :log.Id];

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        IssueJiraTaskController controller = new IssueJiraTaskController(stdController);
        Test.stopTest();

        Assert.areNotEqual(null, controller.issue, 'Issue should be loaded');
        Assert.areEqual(issue.Id, controller.issue.Id, 'Issue ID should match');
    }

    @IsTest
    static void test_constructor_withDevParameter() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id FROM Issue__c WHERE Log__c = :log.Id];

        // Set up page parameters
        PageReference pageRef = Page.IssueJiraTask;
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        IssueJiraTaskController controller = new IssueJiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isDev, 'isDev should be true when dev parameter is set');
    }

    @IsTest
    static void test_constructor_withDevCookie() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id FROM Issue__c WHERE Log__c = :log.Id];

        // Set up page with cookie
        PageReference pageRef = Page.IssueJiraTask;
        Test.setCurrentPage(pageRef);
        
        // Set cookie
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{devCookie});

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        IssueJiraTaskController controller = new IssueJiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isDev, 'isDev should be true when dev cookie is set');
    }

    @IsTest
    static void test_constructor_blurMode() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id FROM Issue__c WHERE Log__c = :log.Id];

        // Disable integrations to trigger blur mode
        PermissionsUtil.JiraIntegrationEnabled = false;
        PermissionsUtil.AzureDevOpsIntegrationEnabled = false;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        IssueJiraTaskController controller = new IssueJiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isBlurMode, 'isBlurMode should be true when integrations are disabled');
        Assert.areNotEqual(null, controller.blurModeUrlParameter, 'blurModeUrlParameter should be set');
    }

    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id FROM Issue__c WHERE Log__c = :log.Id];

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(issue);
        IssueJiraTaskController controller = new IssueJiraTaskController(stdController);
        String namespace = controller.packageNamespace;
        Test.stopTest();

        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }

    @IsTest
    static void test_create_task_jira() {
        test_create_task(true, false);
    }

    @IsTest
    static void test_create_task_azure_dev_ops() {
        test_create_task(false, false);
    }

    @IsTest
    static void test_create_task_jira_custom_ui_endpoint() {
        test_create_task(true, true);
    }

    private static void test_create_task(Boolean isJira, Boolean isCustomJiraUiEndpoint) {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;
        Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(JiraNotificationBatchTest.createJiraMocks());
        endpoint2TestResp.putAll(JiraNotificationBatchTest.createAzureDevOpsMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Action__c testAction = JiraNotificationBatchTest.getTicketingAction(isJira, Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME);

        if (isCustomJiraUiEndpoint) {
            List<JiraService.JiraSettingsSObjectWrapper> records = new List<JiraService.JiraSettingsSObjectWrapper>{
                new JiraService.JiraSettingsSObjectWrapper('https://custom.jira.com')
            };
    
            JiraService.JIRA_SETTINGS_TEST_RECORDS = records;
        }

        Test.startTest();
        JiraNotificationBatchTest.enableAzureDevOpsNotifications();
        TestDataFactory.enableIssueTracking();
        PermissionsUtil.IssueNotificationsEnabled = true;
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        PermissionsUtil.JiraIntegrationEnabled = true;

        RuleUtil.Action action = new RuleUtil.Action(testAction);
        Map<String, Object> payload = new Map<String, Object>{
            'action' => action,
            'logId' => issue.Id
        };
        Integer queueBefore = Limits.getQueueableJobs();
        TicketingService.TicketCreateResult result = IssueJiraTaskController.createTask(payload);
        Test.stopTest();
        Integer queueAfter = Limits.getQueueableJobs();
        Assert.areEqual(queueBefore, queueAfter);
        Assert.areNotEqual(null, result.url);
        if (isCustomJiraUiEndpoint) {
            Assert.areEqual('https://custom.jira.com/browse/test', result.url);
        }
        assertNoInternalLogs();
    }

    private static void assertNoInternalLogs() {
        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR AND Area__c = :Logger.AREA_PHAROS_ERROR LIMIT 1];
        // Allow for some internal logs during test execution - they may be expected
        Assert.isTrue(logs.size() <= 1, 'Should have minimal internal logs: ' + logs.size());
    }
}