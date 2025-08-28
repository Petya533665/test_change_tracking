@IsTest
public class Test_AdminController {
    @IsTest
    static void test_RemoteAction_Scope_1 () {

        Test.startTest();

        ApexPages.currentPage().getParameters().put('dev', 'true');
        AdminController ctrl = new AdminController();
        String baseUrl = AdminController.baseUrl;

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'Unknown',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getEmailServiceData',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));


        payload = new Map<String, Object>{
            'method' => 'confirmEmailService',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getConfigurationOverviewData',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'resetJiraSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getJiraProjectUsers',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getOAuthSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getMasks',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getLoggerWrapperInfo',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getSplunkSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'saveMask',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_2 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'createEmailService',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'createConnectedApp',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_3 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setMonitoringSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setMonitoringRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setNotificationRules',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getPagerDutySettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getPagerDutyServices',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'savePagerDutySettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'deleteLogRecordTypeMappings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'deleteMonitoringRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getActionRules',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setArchivalSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getArchivalSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'deleteArchivalRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setArchivalRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_4 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'emailToCaseTracking',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setupRemoteSiteSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getMergeFields',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getRemoteSiteSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getSelfConnectedOrgsInfo',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getTestEmailExceptionLog',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setArchivalSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'connectedAppSendMeAnEmail',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getApexEmailNotification',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getPackageEmailServiceFunctionEmailAddress',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_5 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setSplunkSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setBatchErrorTrackingSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getBatchErrorTrackingSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getDefaultSlackActionTemplate',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getDefaultJiraActionTemplate',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'startTestExceptionEmail',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_6 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setSplunkSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getQSAnotherConnectedOrg',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'isMyDomainEnabled',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));
        payload = new Map<String, Object>{
            'method' => 'createSelfConnectionOrg',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getQSAnotherConnectedOrg',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getUrlToPlatformEventSubscriberConfigLogEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getUrlToPlatformEventSubscriberConfigAIEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getAdminActiveUsers',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setPlatformEventSubscriberConfigLogEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setPlatformEventSubscriberConfigAIEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_7 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getPlatformEventSubscriberConfigLogEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getPlatformEventSubscriberConfigAIEvent',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setBatchErrorTrackingSetting',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setRuleIndex',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getNotificationSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setNotificationRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getBroadcastSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setBroadcastRule',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getScheduleBulkAPIBatch',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'abortScheduleBulkAPIBatch',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'scheduleBulkAPIBatch',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'resetAllSettingsForRefreshSandbox',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getSubscriptionInfo',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_8 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'checkEmailAccess',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getIsAvailableSingleEmail',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getTeamChannels',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getTeams',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getTeamsSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setTeamsSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getGitHubRepos',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_9 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getDefaultTeamsActionTemplate',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'validateAndRefreshGraphApiOauthToken',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setSettingsForJiraSite',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setChangeTrackingSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getChangeTrackingSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'validateGitHubConnection',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
        System.assertNotEquals(null, AdminController.salesforceBaseUrl);
        System.assertNotEquals(null, AdminController.getOrgId());
    }

    @IsTest
    static void test_RemoteAction_Scope_10 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'setJiraSetting',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getJiraRuleSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'deleteJiraRule',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setJiraRule',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'resetTimerForNewConnectedApp',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'deleteConnectedOrg',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'deleteFakeConnectedOrg',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setJiraRuleIndex',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getDefaultNotificationTemplate',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'deleteNotificationRule',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getOccurrenceLogs',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getAppPermissions',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setJiraRuleIndex',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getInstalledVersion',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'flowErrorTracking',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getMonitoringSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setGitHubSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getGitHubRepoBranches',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_11 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'updatePassthroughtMode',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'createConnectionOrg',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'updateConnectedOrg',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'schedulerEnabledUpdated',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'refreshConnectedOrgToken',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'testConnectedOrg',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_12 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'deleteMask',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'testMask',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'saveSplunkSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'validateSplunkEventCollectorConnection',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getCreateMeta',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getConnectedOrgsInfo',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_13 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'saveJiraFieldsMapping',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getCustomSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'saveCustomSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getSlackSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getSlackChannels',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'saveSlackSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_14 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getQuickStartState',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'setQuickStartState',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getUserInfo',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_15 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'startPlatformEventTest',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
                'method' => 'getPlatformEventTestLog',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_16 () {

        Test.startTest();
        AdminController ac = new AdminController();
        System.assertNotEquals(null, ac.packageNamespace);
        System.assertNotEquals(null, AdminController.baseRemoteSiteSettings);
        System.assertNotEquals(null, AdminController.remoteSiteSettingsPayload);
        Test.stopTest();
    }

    @IsTest
    static void test_RemoteAction_getSessionSettings () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getSessionSettings',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_createSelfConnectionOrgOauth () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createSelfConnectionOrgOauth',
                'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    private static void testLogCategories() {
        Test.startTest();
        Map<String, Object> payload = new Map<String, Object> {
            'method' => 'getLogCategories',
            'data' => ''
        };
        String responseData = AdminController.remoteActionHandler(JSON.serialize(payload));
        System.assertNotEquals(null, responseData);
        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseData);
        Map<String, Object> mapData = (Map<String, Object>)mapResponse.get('data');
        System.assertNotEquals(null, mapData.get('categories'));
        System.assertNotEquals(null, mapData.get('recordtypes'));
        System.assertNotEquals(null, mapData.get('mappings'));

        payload = new Map<String, Object> {
            'method' => 'setLogRecordTypeMappings',
            'data' => JSON.serialize(mapData.get('mappings'))
        };
        String responseSaveData = AdminController.remoteActionHandler(JSON.serialize(payload));
        System.assertNotEquals('success', responseSaveData);
        Test.stopTest();
    }

    @IsTest
    public static void testDefaultPermissions_FeatureMap1() {
        PermissionsUtil.FeatureMap1IntValue = PermissionsUtil.DEFAULT_FEATURE_MAP_1_VALUE;
        System.assertEquals(true, PermissionsUtil.MonitoringEnabled);
        System.assertEquals(true, PermissionsUtil.ArchivalEnabled);
        System.assertEquals(true, PermissionsUtil.JiraIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.SlackIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.SplunkIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.PagerDutyIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.SensitiveDataMaskingEnabled);
        System.assertEquals(true, PermissionsUtil.FlowDebugViewEnabled);
        System.assertEquals(true, PermissionsUtil.NotificationIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.NotificationIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.BulkAPITrackingEnabled);
    }

    @IsTest
    public static void testDefaultPermissions_FeatureMap2() {
        PermissionsUtil.FeatureMap2IntValue = PermissionsUtil.DEFAULT_FEATURE_MAP_2_VALUE;
        Map<Integer, Integer> maxFeatureValues = PermissionsUtil.FeatureMap2;
        System.assertEquals(255, maxFeatureValues.get(0));
        System.assertEquals(255, maxFeatureValues.get(1));
        System.assertEquals(255, maxFeatureValues.get(2));
    }

    @IsTest
    public static void testDefaultPermissions_FeatureMap3() {
        PermissionsUtil.FeatureMap3IntValue = PermissionsUtil.DEFAULT_FEATURE_MAP_3_VALUE;
        Map<Integer, Integer> maxFeatureValues = PermissionsUtil.FeatureMap3;
        System.assertEquals(255, maxFeatureValues.get(0));
        System.assertEquals(255, maxFeatureValues.get(1));
        System.assertEquals(255, maxFeatureValues.get(2));
    }

    @IsTest
    public static void testDefaultPermissions_FeatureMap4() {
        PermissionsUtil.FeatureMap4IntValue = PermissionsUtil.DEFAULT_FEATURE_MAP_4_VALUE;
        // all TTL's with DEFAULT values
        Map<Integer, Integer> featureValues = PermissionsUtil.FeatureMap4;
        System.assertEquals(0, featureValues.get(0));
        System.assertEquals(0, featureValues.get(1));
        System.assertEquals(0, featureValues.get(2));
        System.assertEquals(0, featureValues.get(3));
        System.assertEquals(0, featureValues.get(4));
        System.assertEquals(0, featureValues.get(5));
        System.assertEquals(0, featureValues.get(6));
        System.assertEquals(0, featureValues.get(7));
        System.assertEquals(5, featureValues.get(8));
    }

    @IsTest
    public static void testDefaultPermissions_FeatureMap4_max_values() {
        // all TTL's with max values
        PermissionsUtil.FeatureMap4IntValue = Integer.valueOf(Math.pow(2, 27) - 1);
        Map<Integer, Integer> featureValues = PermissionsUtil.FeatureMap4;
        System.assertEquals(7, featureValues.get(0));
        System.assertEquals(7, featureValues.get(1));
        System.assertEquals(7, featureValues.get(2));
        System.assertEquals(7, featureValues.get(3));
        System.assertEquals(7, featureValues.get(4));
        System.assertEquals(7, featureValues.get(5));
        System.assertEquals(7, featureValues.get(6));
        System.assertEquals(7, featureValues.get(7));
        System.assertEquals(7, featureValues.get(8));
    }

    @IsTest
    public static void testPermissions() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0 => 1,
            1 => 1,
            2 => 0,
            3 => 0,
            4 => 1,
            5 => 0,
            6 => 1,
            7 => 1
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
        System.assertEquals(211, intValue);

        System.assertEquals(true, PermissionsUtil.MonitoringEnabled);
        System.assertEquals(true, PermissionsUtil.ArchivalEnabled);
        System.assertEquals(false, PermissionsUtil.JiraIntegrationEnabled);
        System.assertEquals(false, PermissionsUtil.SlackIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.SplunkIntegrationEnabled);
        System.assertEquals(false, PermissionsUtil.PagerDutyIntegrationEnabled);
        System.assertEquals(true, PermissionsUtil.SensitiveDataMaskingEnabled);
        System.assertEquals(true, PermissionsUtil.FlowDebugViewEnabled);

        Map<Integer, Integer> mapIntegers = PermissionsUtil.getBitmapFromInteger(211);
        System.assertNotEquals(null, mapIntegers);
        System.assertNotEquals(0, mapIntegers.size());

        System.assertEquals(1, mapIntegers.get(0));
        System.assertEquals(1, mapIntegers.get(1));
        System.assertEquals(0, mapIntegers.get(2));
        System.assertEquals(0, mapIntegers.get(3));
        System.assertEquals(1, mapIntegers.get(4));
        System.assertEquals(0, mapIntegers.get(5));
        System.assertEquals(1, mapIntegers.get(6));
        System.assertEquals(1, mapIntegers.get(7));
    }

    
    @IsTest
    static void test_admin_service_getDefaultMonitoringActionTemplate() {
        Map<String, String> testTemplate;
        Test.startTest();
        testTemplate = AdminService.getDefaultMonitoringActionTemplate();
        Test.stopTest();
    
        String eventObjectName = Schema.SObjectType.Event__c.getName();
        
        System.assertNotEquals(null, testTemplate, 'Returned template should not be null');
        System.assert(testTemplate.containsKey('subject'), 'Returned template should contain a subject');
        System.assert(testTemplate.containsKey('body'), 'Returned template should contain a body');
        System.assert(testTemplate.get('subject').contains(eventObjectName), 'Subject template should contain Event__c object name');
        System.assert(testTemplate.get('body').contains(eventObjectName), 'Body template should contain Event__c object name');
    }

    @IsTest
    static void test_getDefaultTeamsActionTemplate() {
        Map<String, String> testTemplate;
        Test.startTest();
        testTemplate = AdminService.getDefaultTeamsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, testTemplate);
    }

    @IsTest
    static void test_getTeamsSettings() {
        AdminService.TeamsSettings settings;
        Test.startTest();
        settings = AdminService.getTeamsSettings();
        Test.stopTest();
        System.assertNotEquals(null, settings.oAuthEndpoint);
    }

    @IsTest
    static void test_getGitHubSettings() {
        AdminService.GitHubSettings settings;
        Test.startTest();
        settings = AdminService.getGitHubSettings();
        Test.stopTest();
        System.assertNotEquals(null, settings.oAuthEndpoint);
    }

    @IsTest
    static void test_setGitHubSettings() {
        AdminService.GitHubSettings settings;
        Test.startTest();
        settings = AdminService.getGitHubSettings();
        settings.enabled = true;
        AdminService.setGitHubSettings(settings);
        Test.stopTest();
        System.assertEquals(true, ConfigUtil.GIT_API_SETTINGS.Enabled__c);
    }

    @IsTest
    static void test_setGitHubSettingsWithResetByRepoOrBranchName() {
        ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
        ConfigUtil.GIT_API_SETTINGS.Username__c = GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME;
        ConfigUtil.GIT_API_SETTINGS.Token__c = GitHubCommitBatchTest.TEST_GIT_API_TOKEN;
        ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = UserInfo.getUserId();
        upsert ConfigUtil.GIT_API_SETTINGS;

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserReposByNameEndpoint(GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME,GitHubCommitBatchTest.TEST_GIT_API_EXT_REPONAME), GitHubCommitBatchTest.getGitAPIUserReposByNameMock());
        endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserExtRepoBranchesByNameEndpoint(), GitHubCommitBatchTest.getGitAPIUserExtRepoBranchesByNameMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> inputSettings = new Map<String, Object>{
            'repositoryUrl' => GitHubCommitBatchTest.TEST_GIT_API_EXT_REPOSITORY_URL,
            'branchName' => GitHubCommitBatchTest.TEST_GIT_API_EXT_BRANCH_NAME
        };
        AdminService.setGitHubSettings(inputSettings);
        Test.stopTest();
        System.assertEquals(null, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c);
    }

    @IsTest
    static void test_setGitHubSettings_ValidateRepositoryName() {
        ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
        ConfigUtil.GIT_API_SETTINGS.Username__c = GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME;
        ConfigUtil.GIT_API_SETTINGS.Token__c = GitHubCommitBatchTest.TEST_GIT_API_TOKEN;
        ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = UserInfo.getUserId();
        upsert ConfigUtil.GIT_API_SETTINGS;

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserReposByNameEndpoint(GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME, GitHubCommitBatchTest.TEST_GIT_API_EXT_REPONAME), getGitAPIUserReposByNameNotFoundMock());
        endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserExtRepoBranchesByNameEndpoint(),getGitAPIUserExtRepoBranchesByNameNotFoundMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> inputSettings = new Map<String, Object>{
            'repositoryUrl' => GitHubCommitBatchTest.TEST_GIT_API_EXT_REPOSITORY_URL,
            'branchName' => GitHubCommitBatchTest.TEST_GIT_API_EXT_BRANCH_NAME
        };
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setGitHubSettings',
            'data' => inputSettings
        };
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();
        
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertNotEquals(null, data);

        AdminService.GitHubSettings settings = (AdminService.GitHubSettings)JSON.deserialize(JSON.serialize(data), AdminService.GitHubSettings.class);
        System.assertNotEquals(null, settings);
        System.assertEquals(AdminService.GIT_API_REPOSITORY_NAME_NOT_FOUND, settings.reponameError);
        System.assertEquals(null, settings.branchNameError);
    }

    @IsTest
    static void test_setGitHubSettings_ValidateBranchName() {
        ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
        ConfigUtil.GIT_API_SETTINGS.Username__c = GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME;
        ConfigUtil.GIT_API_SETTINGS.Token__c = GitHubCommitBatchTest.TEST_GIT_API_TOKEN;
        ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = UserInfo.getUserId();
        upsert ConfigUtil.GIT_API_SETTINGS;

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserReposByNameEndpoint(GitHubCommitBatchTest.TEST_GIT_API_EXT_USERNAME, GitHubCommitBatchTest.TEST_GIT_API_EXT_REPONAME), GitHubCommitBatchTest.getGitAPIUserReposByNameMock());
        endpoint2TestResp.put(GitHubCommitBatchTest.getGitAPIUserExtRepoBranchesByNameEndpoint(),getGitAPIUserExtRepoBranchesByNameNotFoundMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> inputSettings = new Map<String, Object>{
            'repositoryUrl' => GitHubCommitBatchTest.TEST_GIT_API_EXT_REPOSITORY_URL,
            'branchName' => GitHubCommitBatchTest.TEST_GIT_API_EXT_BRANCH_NAME
        };
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setGitHubSettings',
            'data' => inputSettings
        };
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();
        
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertNotEquals(null, data);

        AdminService.GitHubSettings settings = (AdminService.GitHubSettings)JSON.deserialize(JSON.serialize(data), AdminService.GitHubSettings.class);
        System.assertNotEquals(null, settings);
        System.assertEquals(null, settings.reponameError);
        System.assertEquals(AdminService.GIT_API_BRANCH_NAME_NOT_FOUND, settings.branchNameError);
    }

    private static TestDataFactory.SingleRequestMock getGitAPIUserReposByNameNotFoundMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			404,
			'OK',
			'some error message'
		);
		return singleRequestMock;
	}

    private static TestDataFactory.SingleRequestMock getGitAPIUserExtRepoBranchesByNameNotFoundMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			404,
			'OK',
			'some error message'
		);
		return singleRequestMock;
	}

    @IsTest
    static void test_resetGitHubSettings() {
        AdminService.GitHubSettings settings;
        Test.startTest();
        settings = AdminService.resetGitHubSettings();
        Test.stopTest();
        System.assertEquals(false, ConfigUtil.GIT_API_SETTINGS.Enabled__c);
        System.assertEquals(null, ConfigUtil.GIT_API_SETTINGS.Token__c);
        System.assertEquals(null, ConfigUtil.GIT_API_SETTINGS.oauth_Token__c);
    }

    @IsTest
    static void test_getIsAvailableSingleEmail() {
        Boolean availableSingleEmail;
        Test.startTest();
        availableSingleEmail = AdminService.getIsAvailableSingleEmail();
        Test.stopTest();
        System.assertEquals(true, availableSingleEmail);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive() {
        Rule__c testRule = TestDataFactory.createMonitoringRule(true, true);
        TestDataFactory.enableMaxArchivalRules();

        Test.startTest();
        String ruleType = MonitoringUtil.RULE_TYPE_MONITORING;
        Map<String, Object> ruleData = new Map<String, Object>();
        ruleData.put(RuleUtil.KEY_RULE, RuleUtil.getRuleWrappers(ruleType).get(0));
        ruleData.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleData.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, RuleUtil.ACTION_SUBTYPE_NOTIFICATION));

        ApexPages.currentPage().getParameters().put('dev', 'true');
        AdminController ctrl = new AdminController();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setRule',
            'data' => ruleData
        };
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        system.assertEquals(null, response.get('error'));
        system.assertEquals(null, response.get('stack'));
    }

    @IsTest
    static void test_validate_set_monitoring_rule_negative() {
        Rule__c testRule = TestDataFactory.createMonitoringRule(true, true);
        testRule.FilterLogic__c = '1 OR 5 AND';
        update testRule;

        Test.startTest();
        String ruleType = MonitoringUtil.RULE_TYPE_MONITORING;
        Map<String, Object> ruleData = new Map<String, Object>();
        ruleData.put(RuleUtil.KEY_RULE, RuleUtil.getRuleWrappers(ruleType).get(0));
        ruleData.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleData.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, RuleUtil.ACTION_SUBTYPE_NOTIFICATION));

        ApexPages.currentPage().getParameters().put('dev', 'true');
        AdminController ctrl = new AdminController();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setRule',
            'data' => ruleData
        };
       
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        system.assertEquals(AdminService.RULE_FILTER_LOGIC_NOT_VALID, response.get('error'));
        system.assertNotEquals(null, response.get('stack'));
    }

    @IsTest
    static void test_validate_set_archival_rule_positive() {
        Rule__c testRule = TestDataFactory.createArchivalRule(true, true);
        TestDataFactory.enableMaxArchivalRules();
        Test.startTest();
        String ruleType = MonitoringUtil.RULE_TYPE_ARCHIVAL;
        Map<String, Object> ruleData = new Map<String, Object>();
        ruleData.put(RuleUtil.KEY_RULE, RuleUtil.getRuleWrappers(ruleType).get(0));
        ruleData.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleData.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, null));

        ApexPages.currentPage().getParameters().put('dev', 'true');
        AdminController ctrl = new AdminController();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setRule',
            'data' => ruleData
        };
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        system.assertEquals(null, response.get('error'));
        system.assertEquals(null, response.get('stack'));
    }

    @IsTest
    static void test_validate_set_archival_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, null)
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1')
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive4() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, null)
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive5() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1')
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive6() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive7() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive8() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 AND 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive9() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive10() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 AND 2')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive11() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_negative1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1')
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive4() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1')
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive41() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive42() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2')
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive5() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive51() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2 OR 3')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive52() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2 OR 3')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive6() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive7() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_MONITORING, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive31() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive32() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_negative1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_NOTIFICATION, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_NOTIFICATION, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_NOTIFICATION, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_operands_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_NOTIFICATION, '1 OR 2')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_operands_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_NOTIFICATION, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_operands_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_operands_failed2() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }


    @IsTest
    static void test_validate_set_archival_rule_bad_filters_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(MonitoringUtil.RULE_TYPE_ARCHIVAL, '1 OR 2')
            .addFiltrableRuleFilter()
            .addBadFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }


    static void test_validate_set_rule(Boolean isPositive, RuleDataFactory testFactory) {
        TestDataFactory.enableMaxArchivalRules();
        TestDataFactory.enableMaxJiraRules();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('dev', 'true');
        AdminController ctrl = new AdminController();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'setRule',
            'data' => testFactory.getRuleData()
        };
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        if(isPositive) {
            system.assertEquals(null, response.get('error'));
            system.assertEquals(null, response.get('stack'));
        }
        else {
            String errorMessage = String.valueOf(response.get('error'));
            system.assertEquals(true, (errorMessage.contains(AdminService.RULE_FILTER_LOGIC_NOT_VALID) ||  errorMessage.contains(AdminService.RULE_NOT_VALID)));
            system.assertNotEquals(null, response.get('stack'));
        }
    }

    private class RuleDataFactory {

        private Map<String, Object> ruleData = new Map<String, Object>();
        private List<Map<String, Object>> ruleFilters = new List<Map<String, Object>>();

        public Map<String, Object> getRuleData() {
            return this.ruleData;
        }

        private List<Map<String, Object>> filtrableFilters = new List<Map<String, Object>>{
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_EQUAL,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Category__c.getName(),
                'value' => 'TestCategory'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_EQUAL,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Is_New__c.getName(),
                'value' => 'true'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_EQUAL,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Organization_Name__c.getName(),
                'value' => UserInfo.getOrganizationName()
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_EQUAL,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Area__c.getName(),
                'value' => 'someArea'
            }
        };

        private List<Map<String, Object>> nonFiltrableFilters = new List<Map<String, Object>>{
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_CONTAINS,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Details__c.getName(),
                'value' => 'somevalue'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_CONTAINS,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Deploy_Results__c.getName(),
                'value' => 'somevalue'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_DOSENT_CONTAINS,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Executable_Rules__c.getName(),
                'value' => 'someruleid'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_EQUAL,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Stacktrace__c.getName(),
                'value' => 'somestacktrace'
            }
        };

        private List<Map<String, Object>> badFiltrableFilters = new List<Map<String, Object>>{
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_GREATER_THEN,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.Created_At__c.getName(),
                'value' => '2023-06-13T07:16:21.000Z'
            },
            new Map<String, Object> {
                'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_LESS_THAN,
                'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,
                'fieldName' => Schema.sObjectType.Log__c.fields.CreatedDate.getName(),
                'value' => '2023-06-13T07:16:21.000Z'
            }
        };

        public RuleDataFactory addBadFiltrableRuleFilter() {
            Integer index = this.ruleFilters.size() + 1;
            Integer filtrableIndex = Math.mod(Math.abs(Crypto.getRandomLong().intValue()), badFiltrableFilters.size());
            Map<String, Object> filter = badFiltrableFilters.get(filtrableIndex);
            filter.put('index', index);
            ruleFilters.add(new Map<String, Object>(filter));
            return this;
        }

        public RuleDataFactory addFiltrableRuleFilter() {
            Integer index = this.ruleFilters.size() + 1;
            Integer filtrableIndex = Math.mod(Math.abs(Crypto.getRandomLong().intValue()), filtrableFilters.size());
            Map<String, Object> filter = filtrableFilters.get(filtrableIndex);
            filter.put('index', index);
            ruleFilters.add(new Map<String, Object>(filter));
            return this;
        }

        public RuleDataFactory addNonFiltrableRuleFilter() {
            Integer index = this.ruleFilters.size() + 1;
            Integer nonFiltrableIndex = Math.mod(Math.abs(Crypto.getRandomLong().intValue()), nonFiltrableFilters.size());
            Map<String, Object> filter = nonFiltrableFilters.get(nonFiltrableIndex);
            filter.put('index', index);
            ruleFilters.add(new Map<String, Object>(filter));
            return this;
        }

        public RuleDataFactory(String ruleType, String filterLogic) {
            Map<String, Object> ruleObject = new Map<String, Object>();
            ruleObject.put('name', 'sometestrule');
            ruleObject.put('description', 'test');
            ruleObject.put('active', true);
            ruleObject.put('type', ruleType);
            ruleObject.put('filterLogic', filterLogic);


            Map<String, Object> actionsObject = new Map<String, Object>();
            actionsObject.put('type', RuleUtil.ACTION_TYPE_EMAIL_NOTIFICATION);

            if(ruleType == RuleUtil.RULE_TYPE_ARCHIVAL) {
                ruleObject.put('eventTimeInterval', 60);
                actionsObject.put('type', RuleUtil.RULE_TYPE_ARCHIVAL);
                ruleFilters.add(new Map<String, Object> {
                    'index' => 1,
                    'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_GREATER_THEN,//'Greater than',
                    'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,//'Value',
                    'fieldName' => 'Created_At__c',
                    'value' => '60'
                });
            }
            if(ruleType == RuleUtil.RULE_TYPE_MONITORING) {
                ruleObject.put('aggregateType', 'Count');
                ruleObject.put('aggregateInterval', 30);
                ruleObject.put('subtype', 'Spike');
                ruleObject.put('comparisonOperator', 'Greater or equal');
                ruleObject.put('eventTimeInterval', 60);
                ruleObject.put('threshold', 1);
            }
            if(ruleType == RuleUtil.RULE_TYPE_JIRA_UPDATE) {
                actionsObject.put('type', RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION);
            }
            if(ruleType == RuleUtil.RULE_TYPE_NOTIFICATION) {
                actionsObject.put('type', RuleUtil.ACTION_TYPE_EMAIL_NOTIFICATION);
            }
            
            List<Map<String, Object>> ruleActions = new List<Map<String, Object>> {
                new Map<String, Object> {
                    'id' => null,
                    'ruleId' => null,
                    'actionId' => null
                }
            };

            this.ruleData.put('rule', ruleObject);
            this.ruleData.put('actions', new List<Map<String, Object>> {actionsObject});
            this.ruleData.put('ruleActions', ruleActions);
            this.ruleData.put('ruleFilters', ruleFilters);
            
        }
    }

    @IsTest
    private static void testDefaultTemplates() {
        system.assertNotEquals(null, AdminService.getDefaultEmailActionTemplate());
        system.assertNotEquals(null, AdminService.getDefaultAzureDevOpsActionTemplate());
        system.assertNotEquals(null, AdminService.getIssueDefaultAzureDevOpsActionTemplate());
        system.assertNotEquals(null, AdminService.getIssueDefaultJiraActionTemplate());
        system.assertNotEquals(null, AdminService.getTraceResultDefaultSlackActionTemplate());
        system.assertNotEquals(null, AdminService.getTraceResultDefaultTeamsActionTemplate());
        system.assertNotEquals(null, AdminService.getIssueDefaultSlackActionTemplate());
        system.assertNotEquals(null, AdminService.getIssueDefaultTeamsActionTemplate());
        system.assertNotEquals(null, AdminService.getIssueDefaultNotificationsTemplate());
    }

    @IsTest
    private static void testGetEmailServiceData() {
        system.assertNotEquals(null, AdminService.getEmailServiceData(true, true, 'emailToCaseErrorTrackingType', true, true));
    }

    @IsTest
    private static void testResetAllSettingsForRefreshSandbox() {
        Object res = null;
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());

        List<EmailServicesFunction> activeFunctions = new EmailServicesSelector().getPackageEmailServicesFunctions();
        if(!activeFunctions.isEmpty()) {
            List<EmailServicesAddress> activeAddresses = [SELECT Id FROM EmailServicesAddress WHERE FunctionId =:activeFunctions.get(0).Id LIMIT 1];

            mocks.putAll(getDeleteEmailServicesFunctionMock(activeAddresses.get(0).Id));
            mocks.putAll(getUpdateEmailServicesFunctionMock(activeFunctions.get(0).Id));
        }
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Rule__c testRule = TestDataFactory.createMonitoringRule(true, true);
        testRule = [SELECT Id, Active__c FROM Rule__c WHERE Id = :testRule.Id LIMIT 1];
        System.assertEquals(true, testRule.Active__c);

        Test.startTest();
        try{
            res = AdminService.resetAllSettingsForRefreshSandbox();
        }
        catch(Exception e){}
        Test.stopTest();
        system.assertEquals(true, res);

        testRule = [SELECT Id, Active__c FROM Rule__c WHERE Id = :testRule.Id LIMIT 1];
        System.assertEquals(false, testRule.Active__c);
    }

    @IsTest
    private static void test_admin_service_getUserInfo() {
        User user;
        Test.startTest();
        user = AdminService.getUserInfo();
        Test.stopTest();
        System.assertNotEquals(null, user);
    }

    @IsTest
    private static void test_admin_service_isMyDomainEnabled() {
        Map<String, Object> result;
        Test.startTest();
        result = AdminService.isMyDomainEnabled();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.containsKey('enabled'));
    }

    @IsTest
    private static void test_admin_service_getUrlToPlatformEventSubscriberConfigLogEvent() {
        String result;
        Test.startTest();
        result = AdminService.getUrlToPlatformEventSubscriberConfigLogEvent();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getAdminActiveUsers() {
        List<User> result;
        Test.startTest();
        result = AdminService.getAdminActiveUsers();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    @IsTest
    private static void test_admin_service_getMergeFields() {
        List<AdminService.MergeField> result;
        Test.startTest();
        result = (List<AdminService.MergeField>)AdminService.getMergeFields();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    @IsTest
    private static void test_admin_service_getDefaultEmailActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultEmailActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getDefaultAzureDevOpsActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultAzureDevOpsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getDefaultJiraActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultJiraActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueDefaultAzureDevOpsActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getIssueDefaultAzureDevOpsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueDefaultJiraActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getIssueDefaultJiraActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getDefaultSlackActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultSlackActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getDefaultTeamsActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultTeamsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getDefaultNotificationsTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getDefaultNotificationsTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getTraceResultDefaultSlackActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getTraceResultDefaultSlackActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getTraceResultDefaultTeamsActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getTraceResultDefaultTeamsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueDefaultSlackActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getIssueDefaultSlackActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueDefaultTeamsActionTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getIssueDefaultTeamsActionTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueDefaultNotificationsTemplate() {
        Map<String, String> result;
        Test.startTest();
        result = AdminService.getIssueDefaultNotificationsTemplate();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getAppPermissions() {
        Map<String, Object> result;
        Test.startTest();
        result = (Map<String,Object>)AdminService.getAppPermissions(null);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    @IsTest
    private static void test_admin_service_getRemoteSiteSettings() {
        List<MetadataServiceUtil.RemoteSiteSettingsWrapper> result;
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        result = AdminService.getRemoteSiteSettings();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    public static Map<String, HttpCalloutMock> getDeleteEmailServicesFunctionMock(String activeAddressesId) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

       TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            204,
            'OK',
            ''
        );
        result.put(ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + activeAddressesId, singleRequestMock);
        return result;
    }

    public static Map<String, HttpCalloutMock> getUpdateEmailServicesFunctionMock(String emailServicesFunctionId) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

       TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            204,
            'OK',
            ''
        );
        result.put(ConfigUtil.EMAIL_SERVICES_FUNCTION_ENDPOINT + '/' + emailServicesFunctionId + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH, singleRequestMock);
        return result;
    }

    private static Map<String, HttpCalloutMock> getRemoteSiteSettingsMock() {
        return getRemoteSiteSettingsMock('someURL');
    }

    private static Map<String, HttpCalloutMock> getRemoteSiteSettingsMock(String endpointUrl) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        MetadataServiceUtil.RemoteSiteSettingsWrapper wrapper1 = new MetadataServiceUtil.RemoteSiteSettingsWrapper();
        wrapper1.Id = 'someId';
        wrapper1.IsActive = true;
        wrapper1.SiteName = 'someSiteName';
        wrapper1.EndpointUrl = endpointUrl;
        data.put(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS, new List<MetadataServiceUtil.RemoteSiteSettingsWrapper>());
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(data)
        );
        result.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_admin_service_getConnectedOrgsInfo() {
        Map<String, Object> result;
        TestDataFactory.createConnectedOrg();
        Test.startTest();
        result = (Map<String, Object>)AdminService.getConnectedOrgsInfo();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    @IsTest
    private static void test_admin_service_getSelfConnectedOrgsInfo() {
        Map<String, Object> result;
        TestDataFactory.createConnectedOrg();
        Test.startTest();
        result = (Map<String, Object>)AdminService.getSelfConnectedOrgsInfo();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.size());
    }

    @IsTest
    private static void test_admin_service_updatePassthroughtMode() {
        AdminService.ConnectedOrgsSettings result;
        AdminService.ConnectedOrgsSettings data = new AdminService.ConnectedOrgsSettings();
        data.passthroughtMode = true;
        data.passthroughConnection = 'mode@gmail.com';
        Test.startTest();
        result = (AdminService.ConnectedOrgsSettings)AdminService.updatePassthroughtMode(data);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_createConnectionOrg() {
        Map<String, Object> result;
        AdminService.ConnectedOrgCreateData data = new AdminService.ConnectedOrgCreateData();
        data.name = 'somename';
        data.type = 'production';
        data.description = 'description';
        data.source = 'source';
        data.dataDirection = 'direction';
        data.orgId = UserInfo.getOrganizationId();
        Test.startTest();
        result = (Map<String, Object>)AdminService.createConnectionOrg(data);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_createSelfConnectionOrg() {
        Map<String, Object> result;
        AdminService.ConnectedOrgCreateData data = new AdminService.ConnectedOrgCreateData();
        data.name = 'somename';
        data.description = 'description';
        Test.startTest();
        result = (Map<String, Object>)AdminService.createSelfConnectionOrg(data);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_createSelfConnectionOrgOauth() {
        Map<String, Object> result;
        AdminService.ConnectedOrgCreateData data = new AdminService.ConnectedOrgCreateData();
        data.name = 'somename';
        data.description = 'description';
        Test.startTest();
        result = (Map<String, Object>)AdminService.createSelfConnectionOrgOauth(data);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getSessionSettings_positive() {
        test_admin_service_getSessionSettings(true);
        System.assertEquals(true, ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c);
    }

    @IsTest
    private static void test_admin_service_getSessionSettings_negative() {
        test_admin_service_getSessionSettings(false);
        System.assertEquals(false, ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c);
    }

    private static void test_admin_service_getSessionSettings(Boolean positive) {
        Map<String, Object> result;
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getSessionSettings(positive));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        result = (Map<String, Object>)AdminService.getSessionSettings();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    private static Map<String, HttpCalloutMock> getSessionSettings(Boolean positive) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        MetadataService.SessionSettings sessionSettings = new MetadataService.SessionSettings();
        sessionSettings.lockSessionsToIp = true;
        Map<String, Object> body = new Map<String, Object>();
        body.put('Id', '000000000000AAA');
        body.put('LockSessionsToIp', positive);
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                        'records' => new List<Object>{body}
                })
        );
        String query = new QBuilder('SessionSettings')
                .selectFields(new Set<String>{'Id', 'LockSessionsToIp'})
                .build();
        result.put(System.Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(query, 'UTF-8'), singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_admin_service_updateConnectedOrg() {
        Map<String, Object> result;
        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        AdminService.ConnectedOrgDTO data = new AdminService.ConnectedOrgDTO(corg);
        Test.startTest();
        result = (Map<String, Object>)AdminService.updateConnectedOrg(data);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_deleteConnectedOrg() {
        Boolean result;
        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        AdminService.ConnectedOrgDTO data = new AdminService.ConnectedOrgDTO(corg);

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        result = (Boolean)AdminService.deleteConnectedOrg(data);
        Test.stopTest();
        System.assertEquals(true, result);
    }

    @IsTest
    private static void test_admin_service_saveSlackSettings() {
        String result;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        AdminService.SlackSettings data = new AdminService.SlackSettings();
        data.slackEnabled = true;
        data.slackToken = 'sometoken';
        data.slackChannelId = 'somechannelid';
        data.oAuthEndpoint = 'https://slack.com';
        Test.startTest();
        result = (String)AdminService.saveSlackSettings(data);
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_savePagerDutySettings() {
        String result;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        AdminService.PagerDutySettings data = new AdminService.PagerDutySettings();
        data.enabled = true;
        data.token = 'sometoken';
        data.serviceId = 'someserviceid';
        data.serviceId = 'someservicekey';
        data.userEmail = 'someemail@gmail.com';
        Test.startTest();
        result = (String)AdminService.savePagerDutySettings(data);
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_getLogFieldsForJiraMapping() {
        List<Map<String, String>> result;
        Test.startTest();
        result = (List<Map<String, String>>)AdminService.getLogFieldsForJiraMapping();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getIssueFieldsForJiraMapping() {
        List<Map<String, String>> result;
        Test.startTest();
        result = (List<Map<String, String>>)AdminService.getIssueFieldsForJiraMapping();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getAzureDevOpsSettings() {
        AdminService.AzureDevOpsSettings result;
        Test.startTest();
        result = (AdminService.AzureDevOpsSettings)AdminService.getAzureDevOpsSettings();
        AdminService.resetAzureDevOpsSettings();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.oAuthEndpoint);
    }

    @IsTest
    private static void test_admin_service_resetJiraSettings() {
        String result;
        Test.startTest();
        result = (String)AdminService.resetJiraSettings();
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_resetAzureDevOpsSettings() {
        String result;
        Test.startTest();
        result = (String)AdminService.resetAzureDevOpsSettings();
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_saveAzureDevOpsSettings() {
        String result;
        AdminService.AzureDevOpsSettings data = new AdminService.AzureDevOpsSettings(new Azure_Dev_Ops_API_Settings__c());
        data.autoJiraTaskLabelsFromHashes = true;
        data.autoRelateTicketsWithSimilarErrors = true;
        data.createUniqueTicketsByOrg = true;
        data.automaticallyUpdateIssuePriority = true;
        data.automaticallyUpdateTicketPriority = true;
        data.synchronizeCompletedStatus = true;
        data.synchronizeDuplicateTicketsAndIssues = true;
        data.synchronizeRelatedTicketsAndIssues = true;

        Test.startTest();
        result = (String)AdminService.saveAzureDevOpsSettings(data);
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_saveDebugLogServiceSettings() {
        String result;
        AdminService.DebugLogServiceSettings data = new AdminService.DebugLogServiceSettings(new Debug_Log_Service_Flag__c());
        data.enabled = true;
        data.traceWindow = '5';

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        result = (String)AdminService.saveDebugLogServiceSettings(data);
        Test.stopTest();
        System.assertEquals(Constants.UI.RESULT_SUCCESS, result);
    }

    @IsTest
    private static void test_admin_service_getDebugLogServiceSettings() {
        AdminService.DebugLogServiceSettings result;
        Test.startTest();
        result = (AdminService.DebugLogServiceSettings)AdminService.getDebugLogServiceSettings();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_admin_service_getSlackUsers() {
        SlackService.SlackUsersResponse result;

        ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c = 'someTestToken';
        upsert ConfigUtil.SLACK_SETTINGS;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackUsersMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        result = (SlackService.SlackUsersResponse)AdminService.getSlackUsers(null);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.ok);
        System.assertNotEquals(null, result.members);
        System.assertNotEquals(null, result.response_metadata);
        System.assertEquals('nextCursor', result.response_metadata.next_cursor);
        System.assertEquals('someUserName1', result.members.get(0).name);
        System.assertEquals('someUserName2', result.members.get(1).name);
    }

    private static Map<String, HttpCalloutMock> getSlackUsersMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        SlackService.SlackUsersResponse wrapper1 = new SlackService.SlackUsersResponse();
        SlackService.SlackUser user1 = new SlackService.SlackUser();
        user1.id = 'someSlackId1';
        user1.name = 'someUserName1';
        SlackService.SlackUser user2 = new SlackService.SlackUser();
        user2.id = 'someSlackId2';
        user2.name = 'someUserName2';
        wrapper1.members = new List<SlackService.SlackUser>{user1, user2};
        wrapper1.ok = true;
        wrapper1.response_metadata = new SlackService.SlackChannelsResponseMetadata();
        wrapper1.response_metadata.next_cursor = 'nextCursor';

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(wrapper1)
        );
        result.put(ConfigUtil.SLACK_USER_LIST_ENDPOINT, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_settings_page_generate_token_for_azure_dev_ops() {
        String codeValue = 'someCode';
        String returnValue = 'someHttpUrl';
        PageReference pageReference = Page.Settings;
        Test.setCurrentPage(pageReference);
        pageReference.getParameters().put('code', String.valueOf(codeValue));
        LoggerSettingsController ctrl = new LoggerSettingsController();
        Map<String, Object> testResult;
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'return_url' => returnValue
        });

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        mocks.putAll(getAzureDevOpsOAuthMock());
        mocks.putAll(getMyProfileMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        Test.startTest();
        String result = LoggerSettingsController.generateTokenForAzureDevOps(testData);
        testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        Test.stopTest();

        System.assertNotEquals(null, testResult);
        System.assertEquals('ok', testResult.get('status'));
        System.assertEquals('someAccountName', ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c);
        
        GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		AzureService.OAUTH_API_TOKEN = null;
		AzureService.OAUTH_API_REFRESH_TOKEN = null;
		System.assertEquals(TEST_OAUTH_TOKEN, AzureService.OAUTH_API_TOKEN);
		System.assertEquals(TEST_OAUTH_REFRESH_TOKEN, AzureService.OAUTH_API_REFRESH_TOKEN);
    }

    private static Map<String, HttpCalloutMock> getMyProfileMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
		AzureService.AzureDevOpsMyProfile profile = new AzureService.AzureDevOpsMyProfile();
        profile.id = TEST_OAUTH_AZURE_DEV_OPS_ORG_ID;
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(profile)
		);
        result.put(AzureService.AZURE_DEVOPS_REST_API_MY_PROFILE, singleRequestMock);

        List<AzureService.AzureDevOpsAccount> accounts = new List<AzureService.AzureDevOpsAccount>();
        AzureService.AzureDevOpsAccount account = new AzureService.AzureDevOpsAccount();
        account.accountName = 'someAccountName';
        account.accountId = 'someAccountId';
        account.accountUri = 'someAccountUri';
        accounts.add(account);
        AzureService.AzureDevOpsAccountWrapper resultWrapper = new AzureService.AzureDevOpsAccountWrapper();
        resultWrapper.value = accounts;

        TestDataFactory.SingleRequestMock singleRequestMock2 = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(resultWrapper)
		);
        String endpointAccounts = AzureService.AZURE_DEVOPS_REST_API_MY_ACCOUNTS + '?memberId='+ TEST_OAUTH_AZURE_DEV_OPS_ORG_ID + '&'+ AzureService.AZURE_DEVOPS_REST_API_VERSION;
        result.put(endpointAccounts, singleRequestMock2);
		return result;
	}

    private static final String TEST_OAUTH_AZURE_DEV_OPS_ORG_ID = 'someOrganizationId';
    
    private static Map<String, HttpCalloutMock> getAzureDevOpsOAuthMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        ConnectedOrgService.AuthTokenResponse response = new ConnectedOrgService.AuthTokenResponse();
        response.access_token = TEST_OAUTH_TOKEN;
        response.refresh_token = TEST_OAUTH_REFRESH_TOKEN;
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        );
        result.put(AzureService.AZURE_DEVOPS_API_GET_TOKEN_ENDPOINT, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_settings_page_generate_token_for_graph() {
        String codeValue = 'someCode';
        String returnValue = 'someHttpUrl';
        PageReference pageReference = Page.Settings;
        Test.setCurrentPage(pageReference);
        pageReference.getParameters().put('code', String.valueOf(codeValue));
        LoggerSettingsController ctrl = new LoggerSettingsController();
        Map<String, Object> testResult;
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'return_url' => returnValue
        });

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        mocks.putAll(getGraphOAuthMock());
        mocks.putAll(getOrganizationMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        Test.startTest();
        String result = LoggerSettingsController.generateTokenForGraph(testData);
        testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        Test.stopTest();

        System.assertNotEquals(null, testResult);
        System.assertEquals('ok', testResult.get('status'));
        System.assertEquals(TEST_OAUTH_GRAPH_TENANT_ID, ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c);

        GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		GraphAPIService.OAUTH_API_TOKEN = null;
		GraphAPIService.OAUTH_API_REFRESH_TOKEN = null;
		System.assertEquals(TEST_OAUTH_TOKEN, GraphAPIService.OAUTH_API_TOKEN);
		System.assertEquals(TEST_OAUTH_REFRESH_TOKEN, GraphAPIService.OAUTH_API_REFRESH_TOKEN);
    }

    private static final String TEST_OAUTH_GRAPH_TENANT_ID = 'someTenantId';

    private static Map<String, HttpCalloutMock> getOrganizationMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
		GraphAPIService.OrganizationWrapper wrapper = new GraphAPIService.OrganizationWrapper();
		wrapper.value = new List<GraphAPIService.Organization>{
			new GraphAPIService.Organization(TEST_OAUTH_GRAPH_TENANT_ID)
		};
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
        result.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, singleRequestMock);
		return result;
	}

    private static Map<String, HttpCalloutMock> getGraphOAuthMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        ConnectedOrgService.AuthTokenResponse response = new ConnectedOrgService.AuthTokenResponse();
        response.access_token = TEST_OAUTH_TOKEN;
        response.refresh_token = TEST_OAUTH_REFRESH_TOKEN;
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        );
        result.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_settings_page_generate_token_for_slack() {
        String codeValue = 'someCode';
        PageReference pageReference = Page.Settings;
        Test.setCurrentPage(pageReference);
        pageReference.getParameters().put('code', String.valueOf(codeValue));
        LoggerSettingsController ctrl = new LoggerSettingsController();
        Map<String, Object> testResult;
        String testData = JSON.serialize(new Map<String, Object>{'code' => codeValue});

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        mocks.putAll(getSlackOAuthV2Mock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        Test.startTest();
        String result = LoggerSettingsController.generateTokenForSlack(testData);
        testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        Test.stopTest();

        System.assertNotEquals(null, testResult);
        System.assertEquals('ok', testResult.get('status'));
        System.assertEquals(TEST_OAUTH_TOKEN, ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c);
    }

    private static final String TEST_OAUTH_TOKEN = 'testToken';
    private static final String TEST_OAUTH_REFRESH_TOKEN = 'testRefreshToken';

    private static Map<String, HttpCalloutMock> getSlackOAuthV2Mock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        ConnectedOrgService.AuthTokenResponse response = new ConnectedOrgService.AuthTokenResponse();
        response.access_token = TEST_OAUTH_TOKEN;
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        );
        result.put(LoggerSettingsController.SLACK_OAUTH_ENDPOINT_V2, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_save_jira_settings_api_from_cloud_settings() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'baseUrl' => JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT,
                'username' => 'someusername',
                'apiToken' => 'sometoken',
                'apiform' => ''
            }
        };
        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, JiraService.getJIRAServiceAuthType(), 'should be hosted api');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        // after mocks setup should be CLOUD from init setup
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');


        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        System.assertEquals(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        System.assertEquals('someusername', ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
    }
    
    @IsTest
    private static void test_save_jira_settings_pat_from_cloud_settings() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String newHostedJiraEndpoint = 'https://someurl.com';
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'baseUrl' => newHostedJiraEndpoint,
                'apiToken' => 'sometoken',
                'apiform' => ''
            }
        };

        // setup mocks
        JiraService.JIRA_API_URL = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = null;
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(newHostedJiraEndpoint), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(newHostedJiraEndpoint));
        mocks.putAll(getJiraSettingsMock(false));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
       
        // after mocks setup should be CLOUD from init setup
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');
        
        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        System.assertEquals('https://someurl.com', ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
    }

    @IsTest
    private static void test_save_jira_settings_pat_from_empty_settings() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        // clear cloud config
        Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Jira_Base_Url__c = null;
		jiraSettings.Jira_API_Url__c = null;
		jiraSettings.Jira_Username__c = null;
		update jiraSettings;
        ConfigUtil.JIRA_SETTINGS = null;

        System.assertEquals(null, JiraService.getJIRAServiceAuthType(), 'should be null');


        String newHostedJiraEndpoint = 'https://someurl.com';
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'baseUrl' => newHostedJiraEndpoint,
                'apiToken' => 'sometoken',
                'apiform' => ''
            }
        };

        // setup mocks
        JiraService.JIRA_API_URL = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = null;
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(newHostedJiraEndpoint), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(newHostedJiraEndpoint));
        mocks.putAll(getJiraSettingsMock(false));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
       
        // after mocks setup should be empty
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        System.assertEquals(null, JiraService.getJIRAServiceAuthType(), 'should be null');
        
        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        System.assertEquals('https://someurl.com', ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
    }

    @IsTest
    private static void test_save_jira_settings_cloud() {
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'oauthToken' => 'sometoken',
                'cloudform' => ''
            }
        };
        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
    }

    @IsTest
    private static void test_save_jira_settings_settings() {
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'autoJiraTaskLabelsFromHashes' => true,
                'autoRelateTicketsWithSimilarErrors' => true,
                'createUniqueTicketsByOrg' => false
            }
        };
        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        System.assertEquals(true, ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c);
        System.assertEquals(true, ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        System.assertEquals(false, ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c);
    }

    private static final String JIRA_MOCK_REST_ENDPOINT = 'https://test.atlassian.net';
    private static JiraNotificationBatchTest.SingleRequestMock getProjectsMock(Boolean isCloud) {
		List<JiraService.JiraProject> projects = new List<JiraService.JiraProject>();
		JiraService.JiraProject testProject = new JiraService.JiraProject();
		testProject.id = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
		testProject.key = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;

		JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
		jiraField.required = false;
		jiraField.name = JiraNotificationBatchTest.JIRA_MOCK_EPICK_NAME;
		jiraField.key = JiraNotificationBatchTest.JIRA_MOCK_EPICK_ID;

		List<JiraService.JiraProjectIssueType> issueTypes = new List<JiraService.JiraProjectIssueType>();
		JiraService.JiraProjectIssueType testIssueType = new JiraService.JiraProjectIssueType();
		testIssueType.id = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
		testIssueType.name = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_NAME;
		testIssueType.fields = new Map<String, JiraService.JiraProjectIssueField>{JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID => jiraField};

		issueTypes.add(testIssueType);
		testProject.issueTypes = issueTypes;
		projects.add(testProject);

        JiraService.JiraProjectList listResp = new JiraService.JiraProjectList();
        listResp.projects = projects;

		JiraNotificationBatchTest.SingleRequestMock getProjectsRespMock = new JiraNotificationBatchTest.SingleRequestMock(
			200,
			'OK',
			isCloud ? JSON.serialize(listResp) : JSON.serialize(projects)
		);
		return getProjectsRespMock;
	}

    private static Map<String, HttpCalloutMock> getJiraSettingsMock(Boolean isCloud) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getProjectsEndpoint(), getProjectsMock(isCloud));
		endpoint2TestResp.put(JiraService.getService().getProjectEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID), JiraNotificationBatchTest.getProjectMock());
		endpoint2TestResp.put(JiraService.getService().getProjectIssueTypesEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID), JiraNotificationBatchTest.getProjectIssueTypesMock());
		endpoint2TestResp.put(JiraService.getService().getProjectIssueFieldsEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID), JiraNotificationBatchTest.getProjectIssueFieldsMock());
		endpoint2TestResp.put(JiraService.getService().getPrioritySchemesEndpoint(), JiraNotificationBatchTest.createPrioritySchemesMock());
		endpoint2TestResp.put(JiraService.getService().getPrioritiesEndpoint(), JiraNotificationBatchTest.createPrioritiesMock());
		return endpoint2TestResp;
	}

    @TestSetup
    private static void testSetup() {
        Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_API_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_Username__c = JiraService.JIRA_CLOUD_OAUTH_USERNAME;
		insert jiraSettings;
        String oauthToken = AdminService.generateRandomString(1000);
        JiraService.putApiTokenToSettings(oauthToken, true, null);
    }
    @IsTest
    private static void test_save_jira_settings_cloud_settings() {
        Map<String, HttpCalloutMock> endpoint2TestResp = getJiraSettingsMock(true);
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'saveJiraSettings',
            'data' => new Map<String, Object>{
                'baseUrl' => JIRA_MOCK_REST_ENDPOINT,
                'username' => JiraService.JIRA_CLOUD_OAUTH_USERNAME,
                'oauthToken' => AdminService.generateRandomString(1000),
                'autoJiraTaskLabelsFromHashes' => true,
                'autoRelateTicketsWithSimilarErrors' => true,
                'createUniqueTicketsByOrg' => false
            }
        };
        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        System.assertEquals(JiraService.JIRA_CLOUD_OAUTH_USERNAME, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        System.assertEquals(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        System.assertEquals(true, ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c);
        System.assertEquals(true, ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        System.assertEquals(false, ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c);
    }

    @IsTest
    private static void test_call_jira_pririty_schemes() {
        List<JiraService.JiraMappingSObjectWrapper> records = new List<JiraService.JiraMappingSObjectWrapper>{
            new JiraService.JiraMappingSObjectWrapper('KEY1', '1,3,,5'),
            new JiraService.JiraMappingSObjectWrapper('KEY2', '2,4,6')
        };

        JiraService.JIRA_PRIORITY_MAPPING_TEST_RECORDS = records;
        Test.startTest();
        List<JiraService.JiraPriorityScheme> schemes = JiraService.JIRA_PRIORITY_MAPPING;
        system.assertEquals(2, schemes.size());
        system.assertEquals(true, schemes.get(0).projectKeys.contains('KEY1'));
        system.assertEquals(true, schemes.get(0).optionIds.contains('1'));
        system.assertEquals(true, schemes.get(0).optionIds.contains('3'));
        system.assertEquals(true, schemes.get(0).optionIds.contains('5'));
        system.assertEquals(true, !schemes.get(0).optionIds.contains('2'));
        system.assertEquals(true, !schemes.get(0).optionIds.contains('4'));

        system.assertEquals(true, schemes.get(1).projectKeys.contains('KEY2'));
        system.assertEquals(true, schemes.get(1).optionIds.contains('2'));
        system.assertEquals(true, schemes.get(1).optionIds.contains('4'));
        system.assertEquals(true, schemes.get(1).optionIds.contains('6'));
        system.assertEquals(true, !schemes.get(1).optionIds.contains('1'));
        system.assertEquals(true, !schemes.get(1).optionIds.contains('3'));
        Test.stopTest();
    }

    @IsTest
    private static void test_get_slack_channel_by_name_failed_by_bad_json() {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQueryFailedByBadJSON(query));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getSlackChannels',
            'data' => query
        };
        resp = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertNotEquals(null, resp);
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(resp);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertEquals(null, data);
        String error = (String)respAction.get('error');
        System.assertNotEquals(null, error);
        System.assertEquals(true, error.contains('Unexpected character'));
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQueryFailedByBadJSON(String query) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '<!DOCTYPE html><html><body><h1>some server error</h1></body>'
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_get_slack_channel_by_name_failed_by_jira_rate_limit_error() {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQueryFailedByToManyRequests(query));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getSlackChannels',
            'data' => query
        };
        resp = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertNotEquals(null, resp);
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(resp);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertEquals(null, data);
        String error = (String)respAction.get('error');
        System.assertNotEquals(null, error);
        System.assertEquals(true, error.contains('429'));
        System.assertEquals(true, error.contains('Too many requests'));
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQueryFailedByToManyRequests(String query) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            429,
            'OK',
            'Too many requests'
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_get_slack_channels_by_query_found_success() {
        test_get_slack_channels_by_query_success(true);
    }

    @IsTest
    private static void test_get_slack_channels_by_query_not_found_success() {
        test_get_slack_channels_by_query_success(false);
    }

    private static void test_get_slack_channels_by_query_success(Boolean foundChannelSuccess) {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQuery(query, foundChannelSuccess));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getSlackChannels',
            'data' => query
        };
        resp = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertNotEquals(null, resp);
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(resp);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertNotEquals(null, data);

        SlackService.SlackChannelsResponse methodReps = (SlackService.SlackChannelsResponse)JSON.deserialize(JSON.serialize(data), SlackService.SlackChannelsResponse.class);
        System.assertEquals(true, methodReps.ok);

        if(foundChannelSuccess) {
            System.assertNotEquals(true, methodReps.channels.isEmpty());
            System.assertEquals(SLACK_CHANNEL_ID, methodReps.channels.get(0).id);
            System.assertEquals(SLACK_CHANNEL_NAME, methodReps.channels.get(0).name);
        }
        else {
            System.assertEquals(true, methodReps.channels.isEmpty());
        }
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQuery(String query, Boolean foundChannelSuccess) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        SlackService.SlackChannelResponse resp = new SlackService.SlackChannelResponse();
        resp.ok = true;

        SlackService.SlackChannel channel1 = new SlackService.SlackChannel();
        channel1.id = SLACK_CHANNEL_ID;
        channel1.name = SLACK_CHANNEL_NAME;
        resp.channel = foundChannelSuccess ? channel1 : null;

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(resp)
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    @IsTest
    private static void test_get_slack_channels_retrieve_all_success() {
        test_get_slack_channels_retrieve_success(SLACK_CHANNEL_EMPTY_CURSOR);
    }

    @IsTest
    private static void test_get_slack_channels_retrieve_by_cursor_success() {
        test_get_slack_channels_retrieve_success(SLACK_CHANNEL_NEXT_CURSOR);
    }

    private static final String SLACK_CHANNEL_ID = 'C1AD0CDA4';
    private static final String SLACK_CHANNEL_NAME = 'Test Pharos Channel';
    private static final String SLACK_CHANNEL_NEXT_CURSOR = 'dGVhbTpDUlBKVzFRVEM=';
    private static final String SLACK_CHANNEL_EMPTY_CURSOR = null;


    private static void test_get_slack_channels_retrieve_success(String cursor) {
        String resp;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByCursor(cursor));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getSlackChannels',
            'data' => cursor
        };
        resp = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        System.assertNotEquals(null, resp);
        Map<String, Object> respAction = (Map<String, Object>)JSON.deserializeUntyped(resp);
        Map<String, Object> data = (Map<String, Object>)respAction.get('data');
        System.assertNotEquals(null, data);

        SlackService.SlackChannelsResponse methodReps = (SlackService.SlackChannelsResponse)JSON.deserialize(JSON.serialize(data), SlackService.SlackChannelsResponse.class);
        System.assertEquals(true, methodReps.ok);
        System.assertNotEquals(true, methodReps.channels.isEmpty());
        System.assertEquals(SLACK_CHANNEL_ID, methodReps.channels.get(0).id);
        System.assertEquals(SLACK_CHANNEL_NAME, methodReps.channels.get(0).name);
        System.assertNotEquals(null, methodReps.response_metadata.next_cursor);
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByCursor(String cursor) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        SlackService.SlackChannelsResponse resp = new SlackService.SlackChannelsResponse();
        resp.channels = new List<SlackService.SlackChannel>();
        resp.ok = true;
        resp.response_metadata = new SlackService.SlackChannelsResponseMetadata();
        resp.response_metadata.next_cursor = SLACK_CHANNEL_NEXT_CURSOR;

        SlackService.SlackChannel channel1 = new SlackService.SlackChannel();
        channel1.id = SLACK_CHANNEL_ID;
        channel1.name = SLACK_CHANNEL_NAME;
        resp.channels.add(channel1);

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(resp)
        );
        String endpoint = String.isNotBlank(cursor) ? (ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT + '&cursor=' + cursor) : ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    @IsTest
    private static void testParseGitRepositoryUrl() {
        String testString = 'https://github.com/dima2024test/1.901private.git';
        List<String> res = AdminService.getOwnerAndRepositoryNameFromUrl(testString);
        System.assertEquals('dima2024test', res.get(0));
        System.assertEquals('1.901private', res.get(1));

        testString = 'https://github.com/dima20---..git24test/1---9.01.gitprivate.git';
        res = AdminService.getOwnerAndRepositoryNameFromUrl(testString);
        System.assertEquals('dima20---..git24test', res.get(0));
        System.assertEquals('1---9.01.gitprivate', res.get(1));
    }

    @IsTest
    private static void test_custom_jira_ui_endpoint_success() {
        List<JiraService.JiraSettingsSObjectWrapper> records = new List<JiraService.JiraSettingsSObjectWrapper>{
            new JiraService.JiraSettingsSObjectWrapper('https://custom.jira.com')
        };

        JiraService.JIRA_SETTINGS_TEST_RECORDS = records;
        Test.startTest();
        String endpoint = JiraService.toCustomJiraUiEndpoint('https://jira.com/browse/TEST-123');
        system.assertEquals('https://custom.jira.com/browse/TEST-123', endpoint);
        Test.stopTest();
    }

    @IsTest
    private static void test_custom_jira_ui_endpoint_without_settings() {

        Test.startTest();
        String endpoint = JiraService.toCustomJiraUiEndpoint('https://jira.com/browse/TEST-123');
        system.assertEquals('https://jira.com/browse/TEST-123', endpoint);
        Test.stopTest();
    }

    @IsTest
    static void test_RemoteAction_getPharosRunningUserWrapper() {
        LogServiceScheduler.runLogServiceSchedulerModes();

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getPharosRunningUserWrapper',
                'data' => ''
            };
            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        AdminService.PharosRunningUserWrapper wrapper = (AdminService.PharosRunningUserWrapper) JSON.deserialize(
                JSON.serialize(response.get('data')), AdminService.PharosRunningUserWrapper.class
        );

        Assert.areEqual(UserInfo.getFirstName(), wrapper.currentUser.FirstName, 'User First Name does not match');
        Assert.areEqual(UserInfo.getLastName(), wrapper.currentUser.LastName, 'User Last Name does not match');
        Assert.areEqual(2, wrapper.scheduleInfoWrappers.size(), 'Number of scheduled jobs do not match');
        Assert.areEqual(Constants.JOBS.JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_1, wrapper.scheduleInfoWrappers.get(0).jobName, 'Job Name does not match');
        Assert.areEqual(Constants.JOBS.JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_2, wrapper.scheduleInfoWrappers.get(1).jobName, 'Job Name does not match');
    }

    @IsTest
    static void test_RemoteAction_resetScheduleJobs() {
        LogServiceScheduler.runLogServiceSchedulerModes();
        AdminService.PharosRunningUserWrapper oldWrapper = AdminService.getPharosRunningUserWrapper();

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'resetScheduleJobs',
                'data' => ''
            };
            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        AdminService.PharosRunningUserWrapper newWrapper = AdminService.getPharosRunningUserWrapper();

        Assert.areEqual(UserInfo.getFirstName(), newWrapper.currentUser.FirstName, 'User First Name does not match');
        Assert.areEqual(UserInfo.getLastName(), newWrapper.currentUser.LastName, 'User Last Name does not match');
        Assert.areEqual(2, newWrapper.scheduleInfoWrappers.size(), 'Number of scheduled jobs do not match');
        Assert.areEqual(Constants.JOBS.JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_1, newWrapper.scheduleInfoWrappers.get(0).jobName, 'Job Name does not match');
        Assert.areEqual(Constants.JOBS.JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_2, newWrapper.scheduleInfoWrappers.get(1).jobName, 'Job Name does not match');
        Assert.areNotEqual(oldWrapper.scheduleInfoWrappers.get(0).jobId, newWrapper.scheduleInfoWrappers.get(0).jobId, 'Job IDs should not match');
        Assert.areNotEqual(oldWrapper.scheduleInfoWrappers.get(1).jobId, newWrapper.scheduleInfoWrappers.get(1).jobId, 'Job IDs should not match');
    }

    @IsTest
    static void test_RemoteAction_resetEmailAddressContextUser() {
        List<Id> emailServicesAddressFakeIds = TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 2);
        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 1),
            TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1),
            emailServicesAddressFakeIds
        );

        emailServicesSelectorMock.setEmailServicesAddressDeveloperName('Test123');

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getUpdateEmailServicesAddressMocks(new List<Id>{ emailServicesAddressFakeIds.get(0) }));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getDeleteEmailServicesAddressMocks(new List<Id>{ emailServicesAddressFakeIds.get(1) }));

        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'resetEmailAddressContextUser',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        Assert.isTrue((Boolean) response.get('data'));
    }

    @IsTest
    static void test_RemoteAction_validateEmailServiceDataWithEmailServices() {
        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 1),
            TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1),
            TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1)
        );

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'validateEmailServiceData',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        Assert.isTrue((Boolean) response.get('data'));
    }

    @IsTest
    static void test_RemoteAction_validateEmailServiceDataWithEmailServicesAndChangedApexEmailNotification() {
        Logger_Settings__c loggerSettings = Logger_Settings__c.getOrgDefaults();
        loggerSettings.Enable_Email_To_Case_Error_Tracking__c = Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED;
        loggerSettings.Batch_Error_Tracking_Enabled__c = true;
        upsert loggerSettings;

        Pharos_Settings__c pharosSettings = Pharos_Settings__c.getOrgDefaults();
        pharosSettings.Archival_Scheduler_Cron_Exp__c = '1';
        upsert pharosSettings;

        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 1),
            TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1),
            TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1)
        );

        emailServicesSelectorMock.setApexEmailNotificationsEmail('test@test.test');

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'validateEmailServiceData',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();
        
        Assert.isTrue((Boolean) response.get('data'));
        Assert.areEqual(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_DISABLED, ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c);
        Assert.isFalse(ConfigUtil.SETTINGS.Batch_Error_Tracking_Enabled__c);
        Assert.areEqual(null, ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c);
    }

    @IsTest
    static void test_RemoteAction_validateEmailServiceDataWithEmptyEmailServices() {
        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            null,
            null,
            null
        );

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'validateEmailServiceData',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        Assert.isTrue((Boolean) response.get('data'));
    }

    @IsTest
    private static void test_hosted_jira_search_users_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = 'username123';

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraProjectUsers',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };

        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, JiraService.getJIRAServiceAuthType(), 'should be hosted api');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchUsersMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertEquals(true, String.valueOf(data).contains(query));
        
    }

    @IsTest
    private static void test_cloud_jira_search_users_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = 'username123';

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraProjectUsers',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };
        
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchUsersMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertEquals(true, String.valueOf(data).contains(query));
    }

    @IsTest
    private static void test_hosted_jira_search_components_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        // hosted jira does not support query parameter for components
        String query = null;

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraProjectComponents',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };

        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, JiraService.getJIRAServiceAuthType(), 'should be hosted api');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchComponentsMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertNotEquals(null, data);
    }

    @IsTest
    private static void test_cloud_jira_search_components_by_project_id() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = null;

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraProjectComponents',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };
        
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchComponentsMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertNotEquals(null, data);
    }

    @IsTest
    private static void test_cloud_jira_search_components_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = 'component123';

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraProjectComponents',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };
        
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchComponentsPaginatedMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertEquals(true, String.valueOf(data).contains(query));
    }

    @IsTest
    private static void test_hosted_jira_search_epics_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = 'epic123';

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraEpics',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };

        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, JiraService.getJIRAServiceAuthType(), 'should be hosted api');
        System.assertEquals(true, JiraService.getService().getProjectsEndpoint().contains(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchEpicsMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertEquals(true, String.valueOf(data).contains(query));
    }

    @IsTest
    private static void test_cloud_jira_search_epics_by_project_id_and_query() {
        System.assertEquals(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        System.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String query = 'epic123';

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getJiraEpics',
            'data' => new Map<String, Object>{
                'projectId' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                'query' => query
            }
        };
        
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(createJiraSearchEpicsMocks(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, query));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Test.startTest();
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Test.stopTest();

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String error = (String)mapResponse.get('error');
        System.assertEquals(null, error);

        Object data = mapResponse.get('data');
        System.assertEquals(true, String.valueOf(data).contains(query));
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createJiraSearchEpicsMocks(String projectId, String query) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getEpicsEndpoint(projectId, query), getEpicsMock());
		return endpoint2TestResp;
	}

    @TestVisible
    private static TestDataFactory.SingleRequestMock getEpicsMock() {
        List<JiraService.JiraIssue> epics = new List<JiraService.JiraIssue>();
        JiraService.JiraIssue testEpic = new JiraService.JiraIssue();
        testEpic.id = '123';
        testEpic.key = 'epic123';
        epics.add(testEpic);

        JiraService.JQLResponse jqlResponse = new JiraService.JQLResponse();
        jqlResponse.issues = epics;

        TestDataFactory.SingleRequestMock getEpicsRespMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(jqlResponse)
        );
        return getEpicsRespMock;
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createJiraSearchComponentsPaginatedMocks(String projectId, String query) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getProjectComponentsEndpoint(projectId, query), getProjectComponentsPaginatedMock());
		return endpoint2TestResp;
	}

    @TestVisible
    private static TestDataFactory.SingleRequestMock getProjectComponentsPaginatedMock() {
        List<JiraService.JiraProjectComponent> components = new List<JiraService.JiraProjectComponent>();
        JiraService.JiraProjectComponent testComponent = new JiraService.JiraProjectComponent();
        testComponent.id = '123';
        testComponent.name = 'component123';
        components.add(testComponent);

        JiraService.JiraProjectComponentPaginatedResponse paginatedResponse = new JiraService.JiraProjectComponentPaginatedResponse();
        paginatedResponse.values = components;

        TestDataFactory.SingleRequestMock getProjectComponentsPaginatedRespMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(paginatedResponse)
        );
        return getProjectComponentsPaginatedRespMock;
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createJiraSearchComponentsMocks(String projectId, String query) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getProjectComponentsEndpoint(projectId, query), getProjectComponentsMock());
		return endpoint2TestResp;
	}

    @TestVisible
    private static TestDataFactory.SingleRequestMock getProjectComponentsMock() {
        List<JiraService.JiraProjectComponent> components = new List<JiraService.JiraProjectComponent>();
        JiraService.JiraProjectComponent testComponent = new JiraService.JiraProjectComponent();
        testComponent.id = '123';
        testComponent.name = 'component123';
        components.add(testComponent);

        TestDataFactory.SingleRequestMock getProjectComponentsRespMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(components)
        );
        return getProjectComponentsRespMock;
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createJiraSearchUsersMocks(String projectId, String query) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getProjectAssignableUsersEndpoint(projectId, query), getProjectAssignableUsersMock());
		return endpoint2TestResp;
	}

    @TestVisible
	private static TestDataFactory.SingleRequestMock getProjectAssignableUsersMock() {
		List<JiraService.JiraProjectUser> users = new List<JiraService.JiraProjectUser>();
		JiraService.JiraProjectUser testUser = new JiraService.JiraProjectUser();
		testUser.accountId = '123';
		testUser.name = 'username123';
        users.add(testUser);

		TestDataFactory.SingleRequestMock getProjectAssignableUsersRespMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(users)
		);
		return getProjectAssignableUsersRespMock;
	}

    @IsTest
    static void test_eventMonitoringTracking_EnableSuccess() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state - event monitoring disabled
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = null;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test enabling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(null, responseMap.get('error'), 'Should not have error');
        System.assertNotEquals(null, responseMap.get('data'), 'Should have data');
        
        // Verify settings were updated
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.Enabled__c, 'Event monitoring should be enabled');
        System.assertEquals(EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING, 
            updatedSettings.Enabled_Types__c, 'Should have default enabled event types');
        System.assertNotEquals(null, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should be set');
    }

    @IsTest
    static void test_eventMonitoringTracking_DisableSuccess() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state - event monitoring enabled
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = true;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = DateTime.now().addHours(-1);
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test disabling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => false
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(null, responseMap.get('error'), 'Should not have error');
        System.assertNotEquals(null, responseMap.get('data'), 'Should have data');
        
        // Verify settings were updated
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(false, updatedSettings.Enabled__c, 'Event monitoring should be disabled');
        System.assertEquals(EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING, 
            updatedSettings.Enabled_Types__c, 'Should have all event types disabled');
        System.assertNotEquals(null, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should still be set');
    }

    @IsTest
    static void test_eventMonitoringTracking_EnableWithMetadataUpdate() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls to simulate event log generation being disabled
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test enabling event monitoring (should trigger metadata update)
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(null, responseMap.get('error'), 'Should not have error');
        System.assertNotEquals(null, responseMap.get('data'), 'Should have data');
        
        // Verify settings were updated
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.Enabled__c, 'Event monitoring should be enabled');
        System.assertEquals(EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING, 
            updatedSettings.Enabled_Types__c, 'Should have default enabled event types');
    }

    @IsTest
    static void test_eventMonitoringTracking_ExceptionHandling() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls to throw exception
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test with invalid data to trigger exception
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                'invalidKey' => 'invalidValue'
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify error response
        System.assertNotEquals(null, responseMap.get('error'), 'Should have error');
        System.assertNotEquals(null, responseMap.get('stack'), 'Should have stack trace');
    }

    @IsTest
    static void test_eventMonitoringTracking_LastProcessedHourlyEventsCalculation() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = null;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test enabling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        
        Test.stopTest();
        
        // Verify Last_Processed_Hourly_Events__c calculation
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertNotEquals(null, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should be set');
        
        // Verify it's set to previous hour (rounded down)
        DateTime now = DateTime.now();
        DateTime expectedTime = DateTime.newInstance(now.year(), now.month(), now.day(), now.hour(), 0, 0).addHours(-1);
        System.assertEquals(expectedTime, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should be set to previous hour');
    }

    @IsTest
    static void test_eventMonitoringTracking_EmailServiceDataReturn() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test enabling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> data = (Map<String, Object>)responseMap.get('data');
        
        Test.stopTest();
        
        // Verify email service data is returned
        System.assertNotEquals(null, data, 'Should have data');
        System.assert(data.containsKey(ConfigUtil.CONFIRM_AUTOMATED_FLOW_ERROR_TRACKING_KEY), 
            'Should contain flow error tracking key');
        System.assert(data.containsKey(ConfigUtil.CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_KEY), 
            'Should contain email to case error tracking key');
        System.assert(data.containsKey(ConfigUtil.CONFIRM_EVENT_MONITORING_TRACKING_KEY), 
            'Should contain event monitoring tracking key');
    }

    @IsTest
    static void test_eventMonitoringTracking_AdminServiceDirectCall() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test direct AdminService call
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
        };
        
        Map<String, Object> result = AdminService.eventMonitoringTracking(inputData);
        
        Test.stopTest();
        
        // Verify result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey(ConfigUtil.CONFIRM_AUTOMATED_FLOW_ERROR_TRACKING_KEY), 
            'Should contain flow error tracking key');
        System.assert(result.containsKey(ConfigUtil.CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_KEY), 
            'Should contain email to case error tracking key');
        System.assert(result.containsKey(ConfigUtil.CONFIRM_EVENT_MONITORING_TRACKING_KEY), 
            'Should contain event monitoring tracking key');
        
        // Verify settings were updated
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.Enabled__c, 'Event monitoring should be enabled');
    }

    @IsTest
    static void test_eventMonitoringTracking_WithExistingSettings() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state with existing settings
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = true;
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = '1,0,1,0,1';
        ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = DateTime.now().addHours(-2);
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test toggling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => false
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(null, responseMap.get('error'), 'Should not have error');
        
        // Verify settings were updated
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(false, updatedSettings.Enabled__c, 'Event monitoring should be disabled');
        System.assertEquals(EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING, 
            updatedSettings.Enabled_Types__c, 'Should have all event types disabled');
        System.assertNotEquals(null, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should still be set');
    }

    @IsTest
    static void test_eventMonitoringTracking_InvalidInputData() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        Test.startTest();
        
        // Test with null data
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => null
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify error response
        System.assertNotEquals(null, responseMap.get('error'), 'Should have error for null data');
    }

    @IsTest
    static void test_eventMonitoringTracking_EmptyInputData() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        Test.startTest();
        
        // Test with empty data
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>()
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        
        Test.stopTest();
        
        // Verify error response
        System.assertNotEquals(null, responseMap.get('error'), 'Should have error for empty data');
    }

    @IsTest
    static void test_eventMonitoringTracking_IntegrationWithOtherServices() {
        // Setup test data
        TestDataFactory.createConnectedOrg();
        
        // Mock metadata service calls
        Test.setMock(WebServiceMock.class, new EventMonitoringTrackingWebServiceMockImpl());
        
        // Setup initial state
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = false;
        upsert ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        
        // Test enabling event monitoring
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'eventMonitoringTracking',
            'data' => new Map<String, Object>{
                ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
            }
        };
        
        String response = AdminController.remoteActionHandler(JSON.serialize(payload));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        Map<String, Object> data = (Map<String, Object>)responseMap.get('data');
        
        Test.stopTest();
        
        // Verify integration with other services
        System.assertNotEquals(null, data, 'Should have data');
        System.assert(data.containsKey('emailToCaseErrorTrackingAvailable'), 
            'Should contain email to case error tracking available');
        System.assert(data.containsKey('emailToCaseErrorTrackingType'), 
            'Should contain email to case error tracking type');
        System.assert(data.containsKey('emailServicesFunctionIsActive'), 
            'Should contain email services function active status');
    }

    public class EventMonitoringTrackingWebServiceMockImpl implements WebServiceMock {
        
        public EventMonitoringTrackingWebServiceMockImpl() {}

        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {

            if(request instanceof MetadataService.readMetadata_element) {
                MetadataService.readMetadata_element readMetadataRequest = (MetadataService.readMetadata_element)request;
                

                if (readMetadataRequest.type_x == 'EventSettings') {
                    MetadataService.readEventSettingsResponse_element metadataResponse = new MetadataService.readEventSettingsResponse_element();
                    MetadataService.ReadEventSettingsResult result = new MetadataService.ReadEventSettingsResult();
                    result.records = new List<MetadataService.EventSettings>();
                    
                    MetadataService.EventSettings eventSettings = new MetadataService.EventSettings();
                    eventSettings.fullName = 'EventSettings';
                    eventSettings.enableEventLogGeneration = true;
                    result.records.add(eventSettings);
                    metadataResponse.result = result;
                    response.put('response_x', metadataResponse);
                }
                else if (readMetadataRequest.type_x == 'CaseSettings') {
                    MetadataService.readCaseSettingsResponse_element metadataResponse = new MetadataService.readCaseSettingsResponse_element();
                    MetadataService.ReadCaseSettingsResult result = new MetadataService.ReadCaseSettingsResult();
                    result.records = new List<MetadataService.CaseSettings>();
                    MetadataService.CaseSettings caseSettings = new MetadataService.CaseSettings();
                    caseSettings.fullName = 'CaseSettings';
                    result.records.add(caseSettings);
                    metadataResponse.result = result;
                    response.put('response_x', metadataResponse);
                }
                else if (readMetadataRequest.type_x == 'FlowSettings') {
                    MetadataService.readFlowSettingsResponse_element metadataResponse = new MetadataService.readFlowSettingsResponse_element();
                    MetadataService.ReadFlowSettingsResult result = new MetadataService.ReadFlowSettingsResult();
                    result.records = new List<MetadataService.FlowSettings>();
                    MetadataService.FlowSettings flowSettings = new MetadataService.FlowSettings();
                    flowSettings.fullName = 'FlowSettings';
                    flowSettings.enableFlowUseApexExceptionEmail = true;
                    result.records.add(flowSettings);
                    metadataResponse.result = result;
                    response.put('response_x', metadataResponse);
                }
            }
                
        }
    }
}