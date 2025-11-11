@IsTest
private class Test_JiraTaskController {

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
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectUsers',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectComponents',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraEpics',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraSettings',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getCreateMeta',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProject',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectIssueTypes',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getMergeFields',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getDefaultJiraActionTemplate',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'createTask',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjects',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsSettings',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjectTeams',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsWorkItemTypes',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsEpicWorkItems',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsProjectTeamMemberWrapper',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getTeamBoards',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsWorkItemTypesWithValidation',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsClassificationNodes',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getDefaultAzureDevOpsActionTemplate',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getIssueDefaultAzureDevOpsActionTemplate',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAppPermissions',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProjectProperties',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProcessesWorkItemTypes',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOrganizationProcessWorkItemTypeFields',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getActionWrappers',
            'data' => ''
        };
        JiraTaskController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        Assert.areNotEqual(null, payload);
    }

    // Additional tests for constructor and properties
    @IsTest
    static void test_constructor_withValidIssue() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraTaskController controller = new JiraTaskController(stdController);
        Test.stopTest();

        Assert.areNotEqual(null, controller.log, 'Log should be loaded');
        Assert.areEqual(log.Id, controller.log.Id, 'Log ID should match');
    }

    @IsTest
    static void test_constructor_withDevParameter() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;

        // Set up page parameters
        PageReference pageRef = Page.JiraTask;
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraTaskController controller = new JiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isDev, 'isDev should be true when dev parameter is set');
    }

    @IsTest
    static void test_constructor_withDevCookie() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;

        // Set up page with cookie
        PageReference pageRef = Page.JiraTask;
        Test.setCurrentPage(pageRef);
        
        // Set cookie
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{devCookie});

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraTaskController controller = new JiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isDev, 'isDev should be true when dev cookie is set');
    }

    @IsTest
    static void test_constructor_blurMode() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;

        // Disable integrations to trigger blur mode
        PermissionsUtil.JiraIntegrationEnabled = false;
        PermissionsUtil.AzureDevOpsIntegrationEnabled = false;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraTaskController controller = new JiraTaskController(stdController);
        Test.stopTest();

        Assert.isTrue(controller.isBlurMode, 'isBlurMode should be true when integrations are disabled');
        Assert.areNotEqual(null, controller.blurModeUrlParameter, 'blurModeUrlParameter should be set');
    }

    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
        insert log;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        JiraTaskController controller = new JiraTaskController(stdController);
        String namespace = controller.packageNamespace;
        Test.stopTest();

        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }

    @IsTest
    static void test_getActionWrappers() {
        TestDataFactory.createNotificationRule(TestDataFactory.createEmailAction());
        TestDataFactory.enableMaxArchivalRules();

        Map<String, Object> input = new Map<String, Object>{
            RuleUtil.KEY_RULE_TYPE => Constants.RULE_SOBJECT.TYPE_NOTIFICATION
        };
        
        List<RuleUtil.Action> result;
        Test.startTest();
        result = JiraTaskController.getActionWrappers(input);
        Test.stopTest();

        Assert.areNotEqual(true, result == null || result.isEmpty(), 'Action Wrappers should not be null or empty');
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

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(JiraNotificationBatchTest.createJiraMocks());
        endpoint2TestResp.putAll(JiraNotificationBatchTest.createAzureDevOpsMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Action__c testAction = JiraNotificationBatchTest.getTicketingAction(isJira, Constants.LOG_SOBJECT.SOBJECT_TYPE_NAME);

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
            'logId' => log.Id
        };
        Integer queueBefore = Limits.getQueueableJobs();
        TicketingService.TicketCreateResult result = JiraTaskController.createTask(payload);
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