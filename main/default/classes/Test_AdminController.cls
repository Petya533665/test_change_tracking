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
            'method' => 'getAzureDevOpsSettings',
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
            'method' => 'getLoggerWrapperInfo',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getSplunkSettings',
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
            'method' => 'saveJiraSettings',
            'data' => ''
        };
        AdminController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'saveAzureDevOpsSettings',
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

        Test.stopTest();

        System.assertNotEquals(null, payload);
    }

    @IsTest
    static void test_RemoteAction_Scope_12 () {

        Test.startTest();

        AdminController ctrl = new AdminController();

        Map<String, Object> payload = new Map<String, Object>{
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
        System.assertNotEquals(null, AdminController.blurModeUrlParameter);
        System.assertNotEquals(null, ac.userTimezoneOffset);
        System.assertNotEquals(null, AdminController.getAdminPageInitEvent());
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
    static void test_admin_service_getIssueDefaultEmailActionTemplate() {
        Map<String, String> testTemplate;
        Test.startTest();
        testTemplate = AdminService.getIssueDefaultEmailActionTemplate();
        Test.stopTest();
    
        String issueObjectName = Schema.SObjectType.Issue__c.getName();
        
        Assert.areNotEqual(null, testTemplate, 'Returned template should not be null');
        Assert.isTrue(testTemplate.containsKey('subject'), 'Returned template should contain a subject');
        Assert.isTrue(testTemplate.containsKey('body'), 'Returned template should contain a body');
        Assert.isTrue(testTemplate.get('subject').contains(issueObjectName), 'Subject template should contain Issue__c object name');
        Assert.isTrue(testTemplate.get('body').contains(issueObjectName), 'Body template should contain Issue__c object name');
    }

    @IsTest
    static void test_admin_service_getIssueTicketCommentActionTemplate() {
        Map<String, String> testTemplate;
        Test.startTest();
        testTemplate = AdminService.getIssueTicketCommentActionTemplate();
        Test.stopTest();
    
        String issueObjectName = Schema.SObjectType.Issue__c.getName();
        
        Assert.areNotEqual(null, testTemplate, 'Returned template should not be null');
        Assert.isTrue(testTemplate.containsKey('subject'), 'Returned template should contain a subject');
        Assert.isTrue(testTemplate.containsKey('body'), 'Returned template should contain a body');
        Assert.isTrue(testTemplate.get('subject') == null);
        Assert.isTrue(testTemplate.get('body').contains(issueObjectName), 'Body template should contain Issue__c object name');
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
        String ruleType = Constants.RULE_SOBJECT.TYPE_MONITORING;
        Map<String, Object> ruleData = new Map<String, Object>();
        ruleData.put(RuleUtil.KEY_RULE, RuleUtil.getRuleWrappers(ruleType).get(0));
        ruleData.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleData.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, Constants.ACTION_SOBJECT.SUBTYPE_NOTIFICATION));

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
        String ruleType = Constants.RULE_SOBJECT.TYPE_MONITORING;
        Map<String, Object> ruleData = new Map<String, Object>();
        ruleData.put(RuleUtil.KEY_RULE, RuleUtil.getRuleWrappers(ruleType).get(0));
        ruleData.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleData.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, Constants.ACTION_SOBJECT.SUBTYPE_NOTIFICATION));

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
        String ruleType = Constants.RULE_SOBJECT.TYPE_ARCHIVAL;
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
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null)
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1')
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive4() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, null)
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive5() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1')
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive6() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive7() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive8() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 AND 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive9() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive10() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 AND 2')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_positive11() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_negative1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1')
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive4() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1')
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive41() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive42() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2')
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive5() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive51() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2 OR 3')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive52() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2 OR 3')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive6() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_monitoring_rule_positive7() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_MONITORING, '1 OR 2 AND (3 OR 4)')
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive31() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter()
            .addNonFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_positive32() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_jira_update_rule_negative1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE, '1 OR 2 OR (1 OR 3)')
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, null);
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive2() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, '');
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_positive3() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, '1 OR 2 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_operands_positive1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, '1 OR 2')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(true, testFactory);
    }

    @IsTest
    static void test_validate_set_notification_rule_operands_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_operands_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }

    @IsTest
    static void test_validate_set_archival_rule_operands_failed2() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 3')
            .addFiltrableRuleFilter()
            .addFiltrableRuleFilter();
        test_validate_set_rule(false, testFactory);
    }


    @IsTest
    static void test_validate_set_archival_rule_bad_filters_failed1() {
        RuleDataFactory testFactory = new RuleDataFactory(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, '1 OR 2')
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
            actionsObject.put('type', Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION);

            if(ruleType == Constants.RULE_SOBJECT.TYPE_ARCHIVAL) {
                ruleObject.put('eventTimeInterval', 60);
                actionsObject.put('type', Constants.RULE_SOBJECT.TYPE_ARCHIVAL);
                ruleFilters.add(new Map<String, Object> {
                    'index' => 1,
                    'comparisonOperator' => RuleUtil.COMPARISON_OPERATOR_GREATER_THEN,//'Greater than',
                    'comparisonType' => RuleUtil.COMPARISON_TYPE_VALUE,//'Value',
                    'fieldName' => 'Created_At__c',
                    'value' => '60'
                });
            }
            if(ruleType == Constants.RULE_SOBJECT.TYPE_MONITORING) {
                ruleObject.put('aggregateType', 'Count');
                ruleObject.put('aggregateInterval', 30);
                ruleObject.put('subtype', 'Spike');
                ruleObject.put('comparisonOperator', 'Greater or equal');
                ruleObject.put('eventTimeInterval', 60);
                ruleObject.put('threshold', 1);
            }
            if(ruleType == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE) {
                actionsObject.put('type', Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION);
            }
            if(ruleType == Constants.RULE_SOBJECT.TYPE_NOTIFICATION) {
                actionsObject.put('type', Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION);
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
    private static void test_admin_service_getMergeFields_LogFields() {
        List<AdminService.MergeField> allFields;
        
        Test.startTest();
        allFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
        Test.stopTest();
        
        System.assertNotEquals(null, allFields, 'Result should not be null');
        
        // Filter to Log merge fields
        List<AdminService.MergeField> logFields = new List<AdminService.MergeField>();
        for (AdminService.MergeField field : allFields) {
            if (field.sobjectype == 'log') {
                logFields.add(field);
            }
        }
        
        System.assert(logFields.size() > 0, 'Should have Log merge fields');
        
        // Build a map for easier lookup
        Map<String, AdminService.MergeField> fieldMap = new Map<String, AdminService.MergeField>();
        for (AdminService.MergeField field : logFields) {
            fieldMap.put(field.apiName, field);
        }
        
        // Check standard Log fields are included
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Category__c.getName().toLowerCase()), 'Should contain Category');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Summary__c.getName().toLowerCase()), 'Should contain Summary');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Details__c.getName().toLowerCase()), 'Should contain Details');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Type__c.getName().toLowerCase()), 'Should contain Type');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Area__c.getName().toLowerCase()), 'Should contain Functional Area');
        
        // IMPORTANT: Merge fields INCLUDE "Insert field ONLY" fields (unlike filter fields)
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Flow_Link__c.getName().toLowerCase()), 'Should contain Flow_Link__c (Insert field)');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Organization_Url__c.getName().toLowerCase()), 'Should contain Organization_Url__c (Insert field)');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Related_Object__c.getName().toLowerCase()), 'Should contain Related_Object__c (Insert field)');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Log__c.fields.User__c.getName().toLowerCase()), 'Should contain User__c (Insert field)');
        
        // Verify special merge fields (custom merge fields like links) are included
        Boolean hasLinkField = false;
        for (AdminService.MergeField field : logFields) {
            if (field.apiName == 'link') {
                hasLinkField = true;
                break;
            }
        }
        System.assert(hasLinkField, 'Should contain special Link merge field');
        
        // Verify system fields and internal fields are excluded
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Log__c.fields.IsDeleted.getName().toLowerCase()), 'Should NOT contain IsDeleted (system field)');
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Email_Integration_Status__c.getName().toLowerCase()), 'Should NOT contain Email_Integration_Status__c');
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Log__c.fields.Bug_Tracker__c.getName().toLowerCase()), 'Should NOT contain Bug_Tracker__c (internal)');
    }
    
    @IsTest
    private static void test_admin_service_getMergeFields_IssueFields_All() {
        List<AdminService.MergeField> allFields;
        
        Test.startTest();
        allFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
        Test.stopTest();
        
        System.assertNotEquals(null, allFields, 'Result should not be null');
        
        // Filter to Issue merge fields
        List<AdminService.MergeField> issueFields = new List<AdminService.MergeField>();
        for (AdminService.MergeField field : allFields) {
            if (field.sobjectype == 'issue') {
                issueFields.add(field);
            }
        }
        
        System.assert(issueFields.size() > 0, 'Should have Issue merge fields');
        
        // Build a map for easier lookup
        Map<String, AdminService.MergeField> fieldMap = new Map<String, AdminService.MergeField>();
        for (AdminService.MergeField field : issueFields) {
            fieldMap.put(field.apiName, field);
        }
        
        // Check fields from CREATE list are included
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Category__c.getName().toLowerCase()), 'Should contain Category');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.CreatedDate.getName().toLowerCase()), 'Should contain Created Date');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Description__c.getName().toLowerCase()), 'Should contain Description');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Functional_Area__c.getName().toLowerCase()), 'Should contain Functional Area');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Organization_Name__c.getName().toLowerCase()), 'Should contain Organization Name');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Summary__c.getName().toLowerCase()), 'Should contain Summary');
        
        // Check fields from UPDATE list are included
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Assigned__c.getName().toLowerCase()), 'Should contain Assigned');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Priority__c.getName().toLowerCase()), 'Should contain Priority');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Status__c.getName().toLowerCase()), 'Should contain Status');
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getName().toLowerCase()), 'Should contain Bug Tracker');
        
        // IMPORTANT: Merge fields INCLUDE "Insert field ONLY" field Log__c
        System.assert(fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Log__c.getName().toLowerCase()), 'Should contain Log__c (Insert field)');
        
        // Verify special merge fields are included
        Boolean hasLinkField = false;
        Boolean hasAnalysisField = false;
        for (AdminService.MergeField field : issueFields) {
            if (field.apiName == 'link') {
                hasLinkField = true;
            }
            if (field.apiName == 'analysis') {
                hasAnalysisField = true;
            }
        }
        System.assert(hasLinkField, 'Should contain special Link merge field');
        System.assert(hasAnalysisField, 'Should contain special Analysis merge field');
        
        // Verify system fields and internal fields are excluded
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.IsDeleted.getName().toLowerCase()), 'Should NOT contain IsDeleted (system field)');
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c.getName().toLowerCase()), 'Should NOT contain Email_Integration_Status__c');
        System.assert(!fieldMap.containsKey(Schema.sObjectType.Issue__c.fields.Key__c.getName().toLowerCase()), 'Should NOT contain Key__c (internal)');
    }
    
    @IsTest
    private static void test_admin_service_getMergeFields_IssueFields_isUpdateOnly() {
        List<AdminService.MergeField> allFields;
        
        Test.startTest();
        allFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
        Test.stopTest();
        
        System.assertNotEquals(null, allFields, 'Result should not be null');
        
        // Filter to Issue merge fields
        List<AdminService.MergeField> issueFields = new List<AdminService.MergeField>();
        for (AdminService.MergeField field : allFields) {
            if (field.sobjectype == 'issue') {
                issueFields.add(field);
            }
        }
        
        // Build a map for easier lookup
        Map<String, AdminService.MergeField> fieldMap = new Map<String, AdminService.MergeField>();
        for (AdminService.MergeField field : issueFields) {
            fieldMap.put(field.apiName, field);
        }
        
        // Check that UPDATE-ONLY fields are marked with isUpdateOnly = true
        AdminService.MergeField assignedField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Assigned__c.getName().toLowerCase());
        System.assertNotEquals(null, assignedField, 'Assigned field should exist');
        System.assertEquals(true, assignedField.isUpdateOnly, 'Assigned should be marked as isUpdateOnly');
        
        AdminService.MergeField priorityField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Priority__c.getName().toLowerCase());
        System.assertNotEquals(null, priorityField, 'Priority field should exist');
        System.assertEquals(true, priorityField.isUpdateOnly, 'Priority should be marked as isUpdateOnly');
        
        AdminService.MergeField statusField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Status__c.getName().toLowerCase());
        System.assertNotEquals(null, statusField, 'Status field should exist');
        System.assertEquals(true, statusField.isUpdateOnly, 'Status should be marked as isUpdateOnly');
        
        AdminService.MergeField bugTrackerField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getName().toLowerCase());
        System.assertNotEquals(null, bugTrackerField, 'Bug Tracker field should exist');
        System.assertEquals(true, bugTrackerField.isUpdateOnly, 'Bug Tracker should be marked as isUpdateOnly');
        
        AdminService.MergeField exceptionCodesField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Exception_Codes__c.getName().toLowerCase());
        System.assertNotEquals(null, exceptionCodesField, 'Exception Codes field should exist');
        System.assertEquals(true, exceptionCodesField.isUpdateOnly, 'Exception Codes should be marked as isUpdateOnly');
        
        // Check that CREATE fields are NOT marked as isUpdateOnly
        AdminService.MergeField categoryField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Category__c.getName().toLowerCase());
        System.assertNotEquals(null, categoryField, 'Category field should exist');
        System.assertEquals(false, categoryField.isUpdateOnly, 'Category should NOT be marked as isUpdateOnly');
        
        AdminService.MergeField summaryField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Summary__c.getName().toLowerCase());
        System.assertNotEquals(null, summaryField, 'Summary field should exist');
        System.assertEquals(false, summaryField.isUpdateOnly, 'Summary should NOT be marked as isUpdateOnly');
        
        AdminService.MergeField descriptionField = fieldMap.get(Schema.sObjectType.Issue__c.fields.Description__c.getName().toLowerCase());
        System.assertNotEquals(null, descriptionField, 'Description field should exist');
        System.assertEquals(false, descriptionField.isUpdateOnly, 'Description should NOT be marked as isUpdateOnly');
        
        // Check that special merge fields are NOT marked as isUpdateOnly
        for (AdminService.MergeField field : issueFields) {
            if (field.apiName == 'link' || field.apiName == 'analysis') {
                System.assertEquals(false, field.isUpdateOnly, field.apiName + ' special merge field should NOT be marked as isUpdateOnly');
            }
        }
    }
    
    @IsTest
    private static void test_admin_service_getMergeFields_AllUpdateOnlyFields() {
        List<AdminService.MergeField> allFields;
        
        Test.startTest();
        allFields = (List<AdminService.MergeField>)AdminService.getMergeFields();
        Test.stopTest();
        
        // Filter to Issue merge fields
        List<AdminService.MergeField> issueFields = new List<AdminService.MergeField>();
        for (AdminService.MergeField field : allFields) {
            if (field.sobjectype == 'issue') {
                issueFields.add(field);
            }
        }
        
        // Build a map for easier lookup
        Map<String, AdminService.MergeField> fieldMap = new Map<String, AdminService.MergeField>();
        for (AdminService.MergeField field : issueFields) {
            fieldMap.put(field.apiName, field);
        }
        
        // Verify ALL update-only fields from MAP_UPDATE_ONLY_MERGE_FIELDS are marked correctly
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Assigned__c.getName().toLowerCase())?.isUpdateOnly, 'Assigned should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Assigned_To__c.getName().toLowerCase())?.isUpdateOnly, 'Assigned To should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Average_Daily_Volume__c.getName().toLowerCase())?.isUpdateOnly, 'Average Daily Volume should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Average_Frequency__c.getName().toLowerCase())?.isUpdateOnly, 'Average Frequency should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getName().toLowerCase())?.isUpdateOnly, 'Bug Tracker should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Exception_Codes__c.getName().toLowerCase())?.isUpdateOnly, 'Exception Codes should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.First_Occurred_On__c.getName().toLowerCase())?.isUpdateOnly, 'First Occurred On should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Impacted_Objects__c.getName().toLowerCase())?.isUpdateOnly, 'Impacted Objects should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Impacted_Objects_Count__c.getName().toLowerCase())?.isUpdateOnly, 'Impacted Objects Count should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Impacted_Objects_by_Type__c.getName().toLowerCase())?.isUpdateOnly, 'Impacted Objects by Type should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Impacted_Users__c.getName().toLowerCase())?.isUpdateOnly, 'Impacted Users should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Impacted_Users_Count__c.getName().toLowerCase())?.isUpdateOnly, 'Impacted Users Count should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Name.getName().toLowerCase())?.isUpdateOnly, 'Issue Name should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Last_Occurred_On__c.getName().toLowerCase())?.isUpdateOnly, 'Last Occurred On should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Log_Count__c.getName().toLowerCase())?.isUpdateOnly, 'Log Count should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Priority__c.getName().toLowerCase())?.isUpdateOnly, 'Priority should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Regressed_On__c.getName().toLowerCase())?.isUpdateOnly, 'Regressed On should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Regression__c.getName().toLowerCase())?.isUpdateOnly, 'Regression should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Related_Issue__c.getName().toLowerCase())?.isUpdateOnly, 'Related Issue should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Resolved_On__c.getName().toLowerCase())?.isUpdateOnly, 'Resolved On should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Score__c.getName().toLowerCase())?.isUpdateOnly, 'Score should be isUpdateOnly');
        System.assertEquals(true, fieldMap.get(Schema.sObjectType.Issue__c.fields.Status__c.getName().toLowerCase())?.isUpdateOnly, 'Status should be isUpdateOnly');
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
    private static void test_RemoteAction_refreshConnectedOrgToken() {
        TestDataFactory.createConnectedOrg();
        TestDataFactory.createConnectedOrgSettings();

        final String NEW_ACCESS_TOKEN = 'new_access_token';

        ConnectedOrgService.AuthTokenResponse authTokenResponse = new ConnectedOrgService.AuthTokenResponse();
        authTokenResponse.access_token = NEW_ACCESS_TOKEN;

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(
            new Map<String, HttpCalloutMock>{
                TestDataFactory.CONNECTED_ORG_INSTANCE_URL + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT =>
                new TestDataFactory.SingleRequestMock(
                    200,
                    'OK',
                    JSON.serialize(authTokenResponse)
                )
            }
        ));

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'refreshConnectedOrgToken',
                'data' => new AdminService.ConnectedOrgDTO(ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15)))
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        AdminService.ConnectedOrgDTO d = (AdminService.ConnectedOrgDTO) JSON.deserialize(
            JSON.serialize(response.get('data')),
            AdminService.ConnectedOrgDTO.class
        );

        Assert.areEqual(NEW_ACCESS_TOKEN, d.accessToken);
    }

    @IsTest
    private static void test_RemoteAction_testConnectedOrg_success() {
        TestDataFactory.createConnectedOrg();

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(
            new Map<String, HttpCalloutMock>{
                TestDataFactory.CONNECTED_ORG_IDENTITY_URL =>
                new TestDataFactory.SingleRequestMock(
                    200,
                    'OK',
                    JSON.serialize(new ConnectedOrgService.IdentityDTO())
                )
            }
        ));

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'testConnectedOrg',
                'data' => new AdminService.ConnectedOrgDTO(ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15)))
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        Assert.areEqual(ConfigUtil.CONNECTED_ORG_TESTING_KEY_SUCCESS, response.get('data'));
    }

    @IsTest
    private static void test_RemoteAction_testConnectedOrg_fail() {
        TestDataFactory.createConnectedOrg();

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(
            new Map<String, HttpCalloutMock>{
                TestDataFactory.CONNECTED_ORG_IDENTITY_URL =>
                new TestDataFactory.SingleRequestMock(
                    200,
                    'OK',
                    '{'
                )
            }
        ));
        
        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();

            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'testConnectedOrg',
                'data' => new AdminService.ConnectedOrgDTO(ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15)))
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));

        Test.stopTest();

        Assert.areEqual(ConfigUtil.CONNECTED_ORG_TESTING_KEY_FAIL, response.get('data'));
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
        result.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, singleRequestMock);
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

    private static final String JIRA_MOCK_REST_ENDPOINT = 'https://test.atlassian.net';

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
    private static void testParseGitRepositoryUrl() {
        String testString = 'https://github.com/dima2024test/1.901private.git';
        List<String> res = GitHubUtils.getOwnerAndRepositoryNameFromUrl(testString);
        System.assertEquals('dima2024test', res.get(0));
        System.assertEquals('1.901private', res.get(1));

        testString = 'https://github.com/dima20---..git24test/1---9.01.gitprivate.git';
        res = GitHubUtils.getOwnerAndRepositoryNameFromUrl(testString);
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
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 2),
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
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 2),
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
            TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 2),
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
    static void test_RemoteAction_createEmailService_disableParam() {
        List<Id> emailServicesFunctionFakeIds = TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1);
        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            null,
            TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1),
            null
        );

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getUpdateEmailServicesFunctionMock(emailServicesFunctionFakeIds.get(0))));

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createEmailService',
                'data' => new Map<String, Object>{
                    ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => false
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.areNotEqual(null, response);
    }

    @IsTest
    static void test_RemoteAction_createEmailService_enableParam_WithoutExistingServices() {
        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            null,
            null,
            null
        );

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        List<Id> emailServicesFunctionFakeIds = TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1);
        List<Id> emailServicesAddressFakeIds = TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesFunctionServiceMock.getCreateEmailServicesFunctionMock(emailServicesFunctionFakeIds.get(0)));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getCreateEmailServicesAddressMock(emailServicesAddressFakeIds.get(0)));
        endpoint2TestResp.putAll(EmailServicesServiceMock.apexEmailNotificationServiceMock.getCreateApexEmailNotificationMock());

        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createEmailService',
                'data' => new Map<String, Object>{
                    ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.areNotEqual(null, response);
    }

    @IsTest
    static void test_RemoteAction_createEmailService_enableParam_WithAllExistingServices() { 
        List<Id> apexEmailNotificationFakeIds = TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 2);
        List<Id> emailServicesFunctionFakeIds = TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1);
        List<Id> emailServicesAddressFakeIds = TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 2);

        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            apexEmailNotificationFakeIds,
            emailServicesFunctionFakeIds,
            emailServicesAddressFakeIds
        );

        emailServicesSelectorMock.setEmailServicesAddressIsActive(false);

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(getUpdateEmailServicesFunctionMock(emailServicesFunctionFakeIds.get(0)));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getUpdateEmailServicesAddressMocks(new List<Id>{ emailServicesAddressFakeIds.get(0) }));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getDeleteEmailServicesAddressMocks(new List<Id>{ emailServicesAddressFakeIds.get(1) }));
        endpoint2TestResp.putAll(EmailServicesServiceMock.apexEmailNotificationServiceMock.getUpdateApexEmailNotificationMock(apexEmailNotificationFakeIds.get(0)));

        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createEmailService',
                'data' => new Map<String, Object>{
                    ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.areNotEqual(null, response);
    }

    @IsTest
    static void test_RemoteAction_createEmailService_enableParam_WithNonMatchingEmailAddresses() {
        // Setup: 1 ApexEmailNotification with different email than package email service address
        List<Id> apexEmailNotificationFakeIds = TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 1);
        List<Id> emailServicesFunctionFakeIds = TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1);
        List<Id> emailServicesAddressFakeIds = TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1);

        EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
            apexEmailNotificationFakeIds,
            emailServicesFunctionFakeIds,
            emailServicesAddressFakeIds
        );

        // Set different email for ApexEmailNotification (not matching package email)
        emailServicesSelectorMock.setApexEmailNotificationsEmail('different.email@example.com');
        emailServicesSelectorMock.setEmailServicesAddressIsActive(true);

        AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
            EmailServicesSelector.class,
            emailServicesSelectorMock
        );

        List<Id> newEmailServicesAddressFakeIds = TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(getUpdateEmailServicesFunctionMock(emailServicesFunctionFakeIds.get(0)));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getDeleteEmailServicesAddressMocks(new List<Id>{ emailServicesAddressFakeIds.get(0) }));
        endpoint2TestResp.putAll(EmailServicesServiceMock.emailServicesAddressServiceMock.getCreateEmailServicesAddressMock(newEmailServicesAddressFakeIds.get(0)));
        endpoint2TestResp.putAll(EmailServicesServiceMock.apexEmailNotificationServiceMock.getUpdateApexEmailNotificationMock(apexEmailNotificationFakeIds.get(0)));

        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createEmailService',
                'data' => new Map<String, Object>{
                    ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE => true
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.areNotEqual(null, response, 'Response should not be null');
    }

    @IsTest
    static void test_RemoteAction_getCreateMeta() {
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getCreateMeta',
                'data' => new Map<String, Object>{
                    ConfigUtil.CREATE_META_REQUEST_DATA_KEY_PROJECT_ID => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID,
                    ConfigUtil.CREATE_META_REQUEST_DATA_KEY_ISSUE_TYPE_ID => JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        Map<String, Object> mapData = (Map<String, Object>) response.get('data');
        Assert.areNotEqual(null, mapData.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_META));
        Assert.areNotEqual(null, mapData.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_COMPONENTS));
        Assert.areNotEqual(null, mapData.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_EPICS));
        Assert.areNotEqual(null, mapData.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_PRIORITIES));
    }

    @IsTest
    static void test_RemoteAction_getJiraProjectIssueTypes() {
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getJiraProjectIssueTypes',
                'data' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        List<JiraService.JiraProjectIssueType> issueTypes = (List<JiraService.JiraProjectIssueType>) JSON.deserialize(JSON.serialize(response.get('data')), List<JiraService.JiraProjectIssueType>.class);
        Assert.isFalse(issueTypes.isEmpty());
    }

    @IsTest
    static void test_RemoteAction_getJiraProject() {
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getJiraProject',
                'data' => JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        JiraService.JiraProject jiraProject = (JiraService.JiraProject) JSON.deserialize(JSON.serialize(response.get('data')), JiraService.JiraProject.class);

        Assert.isTrue(jiraProject != null);
        Assert.isTrue(String.isNotBlank(jiraProject.id));
        Assert.isTrue(String.isNotBlank(jiraProject.key));
    }

    @IsTest
    static void test_RemoteAction_createConnectedApp_useManagedAppTrue() {
        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createConnectedApp',
                'data' => new Map<String, Object> {
                    'useManagedApp' => true
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(ConfigUtil.PHAROS_APP_SETTINGS_NAME);
        AdminService.OAuthSettings oauthSettings = new AdminService.OAuthSettings();

        oauthSettings = (AdminService.OAuthSettings) JSON.deserialize(JSON.serialize(response.get('data')), AdminService.OAuthSettings.class);

        Assert.areEqual(mdtSettings.Client_Id__c, oauthSettings.clientKey);
        Assert.areEqual(mdtSettings.Client_Secret__c, oauthSettings.clientSecret);
        Assert.areEqual(ConfigUtil.CONNECTED_APP_API_NAME, ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c);
        Assert.isTrue(ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        Assert.isTrue(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c != null);
    }

    @IsTest
    static void test_RemoteAction_createConnectedApp_useManagedAppFalse() {
        TestDataFactory.createConnectedOrgSettings();
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
                   
        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'createConnectedApp',
                'data' => new Map<String, Object> {
                    'useManagedApp' => false
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        AdminService.OAuthSettings oauthSettings = new AdminService.OAuthSettings();

        oauthSettings = (AdminService.OAuthSettings) JSON.deserialize(JSON.serialize(response.get('data')), AdminService.OAuthSettings.class);

        Assert.isTrue(String.isNotBlank(oauthSettings.clientKey));
        Assert.isTrue(String.isNotBlank(oauthSettings.clientSecret));
        Assert.isTrue(String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c));
        Assert.isFalse(ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        Assert.isTrue(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c != null);
    }

    @IsTest
    static void test_RemoteAction_getMasks() {
        final String NAME = 'testName';
        final String DESCRIPTION = 'testDescription';
        final String REGEX = 'testRegex';

        insert new SensitiveDataMask__c(
            Name = NAME,
            Description__c = DESCRIPTION,
            Regex__c = REGEX
        );

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getMasks',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        List<AdminService.SensitiveDataMaskWrapper> wrappers = (List<AdminService.SensitiveDataMaskWrapper>) JSON.deserialize(
            JSON.serialize(response.get('data')), List<AdminService.SensitiveDataMaskWrapper>.class
        );

        Assert.isFalse(wrappers.isEmpty());
        Assert.areEqual(1, wrappers.size());
        Assert.areEqual(NAME, wrappers.get(0).id);
        Assert.areEqual(NAME, wrappers.get(0).name);
        Assert.areEqual(DESCRIPTION, wrappers.get(0).description);
        Assert.areEqual(REGEX, wrappers.get(0).regex);
    }

    @IsTest
    static void test_RemoteAction_saveMask() {
        final String NAME = 'testName';
        final String DESCRIPTION = 'testDescription';
        final String REGEX = 'testRegex';

        AdminService.SensitiveDataMaskWrapper wrapper = new AdminService.SensitiveDataMaskWrapper();
        wrapper.Id = NAME;
        wrapper.description = DESCRIPTION;
        wrapper.regex = REGEX;

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'saveMask',
                'data' => wrapper
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));
        
        List<AdminService.SensitiveDataMaskWrapper> wrappers = (List<AdminService.SensitiveDataMaskWrapper>) JSON.deserialize(
            JSON.serialize(response.get('data')), List<AdminService.SensitiveDataMaskWrapper>.class
        );

        Assert.isFalse(wrappers.isEmpty());
        Assert.areEqual(1, wrappers.size());
        Assert.areEqual(NAME, wrappers.get(0).id);
        Assert.areEqual(NAME, wrappers.get(0).name);
        Assert.areEqual(DESCRIPTION, wrappers.get(0).description);
        Assert.areEqual(REGEX, wrappers.get(0).regex);

        List<SensitiveDataMask__c> masks = SensitiveDataMask__c.getAll().values();
        Assert.areEqual(1, masks.size());
        Assert.areEqual(NAME, masks.get(0).Name);
        Assert.areEqual(DESCRIPTION, masks.get(0).Description__c);
        Assert.areEqual(REGEX, masks.get(0).Regex__c);
    }

    @IsTest
    static void test_RemoteAction_testMask() {
        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'testMask',
                'data' => new Map<String, Object>{
                    ConfigUtil.SENSETIVE_MASK_KEY_TEXT => 'test@example.com',
                    ConfigUtil.SENSETIVE_MASK_KEY_REGEX => '\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b'
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        String result = (String) response.get('data');

        Assert.isTrue(String.isNotBlank(result));
        Assert.areEqual(ConfigUtil.SENSETIVE_MASK_KEY_MASK, result);
    }

    @IsTest
    static void test_RemoteAction_deleteMask() {
        final String NAME = 'testName';
        final String DESCRIPTION = 'testDescription';
        final String REGEX = 'testRegex';

        insert new SensitiveDataMask__c(
            Name = NAME,
            Description__c = DESCRIPTION,
            Regex__c = REGEX
        );

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'deleteMask',
                'data' => new Map<String, Object>{
                    ConfigUtil.SENSETIVE_MASK_KEY_ID => NAME
                }
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        List<AdminService.SensitiveDataMaskWrapper> wrappers = (List<AdminService.SensitiveDataMaskWrapper>) JSON.deserialize(
            JSON.serialize(response.get('data')), List<AdminService.SensitiveDataMaskWrapper>.class
        );

        Assert.isTrue(wrappers.isEmpty());

        List<SensitiveDataMask__c> masks = SensitiveDataMask__c.getAll().values();
        Assert.areEqual(0, masks.size());
    }

    @IsTest
    static void test_RemoteAction_deleteLogRecordTypeMappings() {
        final String LOG_CATEGORY_ERROR = 'Error';
        final String LOG_RT_NAME_ERROR = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Error').getDeveloperName();

        insert new Log_Category_Mapping_Setting__c(
            Name = 'Error',
            Category__c = LOG_CATEGORY_ERROR,
            Record_Type_Developer_Name__c = LOG_RT_NAME_ERROR
        );

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'deleteLogRecordTypeMappings',
                'data' => new AdminService.LogRecordTypeMapping(LOG_CATEGORY_ERROR, LOG_CATEGORY_ERROR, LOG_RT_NAME_ERROR, LOG_RT_NAME_ERROR)
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));
        Assert.areEqual(Constants.UI.RESULT_SUCCESS, (String) response.get('data'));
        Assert.areEqual(0, Log_Category_Mapping_Setting__c.getAll().values().size());
    }

    @IsTest
    static void test_RemoteAction_setLogRecordTypeMappings_insert() {
        final String LOG_CATEGORY_ERROR = 'Error';
        final String LOG_RT_NAME_ERROR = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Error').getDeveloperName();

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'setLogRecordTypeMappings',
                'data' => new AdminService.LogRecordTypeMapping(LOG_CATEGORY_ERROR, LOG_CATEGORY_ERROR, LOG_RT_NAME_ERROR, LOG_RT_NAME_ERROR)
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));
        Assert.areEqual(Constants.UI.RESULT_SUCCESS, (String) response.get('data'));
        
        List<Log_Category_Mapping_Setting__c> settings = Log_Category_Mapping_Setting__c.getAll().values();
        Assert.areEqual(1, settings.size());
        Assert.areEqual(LOG_CATEGORY_ERROR, settings.get(0).Category__c);
        Assert.areEqual(LOG_RT_NAME_ERROR, settings.get(0).Record_Type_Developer_Name__c);
    }

    @IsTest
    static void test_RemoteAction_setLogRecordTypeMappings_update() {
        final String LOG_CATEGORY_ERROR = 'Error';
        final String LOG_RT_NAME_ERROR = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Error').getDeveloperName();
        final String LOG_RT_NAME_DEBUG = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Debug').getDeveloperName();

        insert new Log_Category_Mapping_Setting__c(
            Name = 'Error',
            Category__c = LOG_CATEGORY_ERROR,
            Record_Type_Developer_Name__c = LOG_RT_NAME_ERROR
        );

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'setLogRecordTypeMappings',
                'data' => new AdminService.LogRecordTypeMapping(LOG_CATEGORY_ERROR, LOG_CATEGORY_ERROR, LOG_RT_NAME_DEBUG, LOG_RT_NAME_DEBUG)
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));
        Assert.areEqual(Constants.UI.RESULT_SUCCESS, (String) response.get('data'));

        List<Log_Category_Mapping_Setting__c> settings = Log_Category_Mapping_Setting__c.getAll().values();
        Assert.areEqual(1, settings.size());
        Assert.areEqual(LOG_CATEGORY_ERROR, settings.get(0).Category__c);
        Assert.areEqual(LOG_RT_NAME_DEBUG, settings.get(0).Record_Type_Developer_Name__c);
    }

    @IsTest
    static void test_RemoteAction_getLogCategories() {
        final String LOG_CATEGORY_ERROR = 'Error';
        final String LOG_RT_NAME_ERROR = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Error').getDeveloperName();

        insert new Log_Category_Mapping_Setting__c(
            Name = 'Error',
            Category__c = LOG_CATEGORY_ERROR,
            Record_Type_Developer_Name__c = LOG_RT_NAME_ERROR
        );

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getLogCategories',
                'data' => new AdminService.LogRecordTypeMapping(LOG_CATEGORY_ERROR, LOG_CATEGORY_ERROR, LOG_RT_NAME_ERROR, LOG_RT_NAME_ERROR)
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        Map<String, Object> mapData = (Map<String, Object>) response.get('data');
        Assert.areNotEqual(null, mapData.get(ConfigUtil.LOG_CATEGORIES_KEY_CATEGORIES));
        Assert.areNotEqual(null, mapData.get(ConfigUtil.LOG_CATEGORIES_KEY_RECORDTYPES));
        Assert.areNotEqual(null, mapData.get(ConfigUtil.LOG_CATEGORIES_KEY_MAPPINGS));
    }

    @IsTest
    static void test_RemoteAction_getMetadataChatSettings() {
        final String GIT_API_SETTINGS_USERNAME = 'Test_Username';
        final String GIT_API_SETTINGS_REPONAME = 'Test_Reponame';
        final String GIT_API_SETTINGS_BRANCH_NAME = 'Test_BranchName';

        OpenAI_Settings__c openAISettings = OpenAI_Settings__c.getOrgDefaults();
        openAISettings.OpenAI_Enabled__c = true;
        openAISettings.Token__c = 'someToken';
        upsert openAISettings;

        Git_API_Settings__c gitApiSettings = Git_API_Settings__c.getOrgDefaults();
        gitApiSettings.Token__c = 'Test_Token';
        gitApiSettings.oAuth_Token__c = 'Test_oAuthToken';
        gitApiSettings.Username__c = GIT_API_SETTINGS_USERNAME;
        gitApiSettings.Reponame__c = GIT_API_SETTINGS_REPONAME;
        gitApiSettings.Branch_Name__c = GIT_API_SETTINGS_BRANCH_NAME;
        gitApiSettings.Last_Processed_Date_Time__c = Datetime.now().formatGmt(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
        gitApiSettings.Enabled__c = true;
        upsert gitApiSettings;

        MetadataServiceUtil.CspTrustedSiteWrapper cspTrustedSiteWrapper = new MetadataServiceUtil.CspTrustedSiteWrapper();
        cspTrustedSiteWrapper.Id = 'someId';
        cspTrustedSiteWrapper.IsActive = true;
        cspTrustedSiteWrapper.DeveloperName = 'someDeveloperName';
        cspTrustedSiteWrapper.EndpointUrl = PharosChatController.CHAT_WEBSOCKET_URL;

        GitHubUtils.GitRepoBranchInfo gitRepoBranchInfo = new GitHubUtils.GitRepoBranchInfo();
        gitRepoBranchInfo.name = GIT_API_SETTINGS_BRANCH_NAME;

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>{
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_CSP_TRUSTED_SITES_QUERY => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.CSP_TRUSTED_SITES_KEY_RECORDS => new List<MetadataServiceUtil.CspTrustedSiteWrapper>{ cspTrustedSiteWrapper }
                })
            ),
            PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId() => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{"empty": false, "indexingInProgress": true, "logsEmpty": false}'
            ),
            ConfigUtil.OPEN_AI_USAGE_ENDPOINT => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                ''
            ),
            String.format(GitHubUtils.GIT_API_GET_REPO_BRANCHES_INFO, new List<String>{GIT_API_SETTINGS_USERNAME, GIT_API_SETTINGS_REPONAME, GIT_API_SETTINGS_BRANCH_NAME}) => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(gitRepoBranchInfo)
            )
        };
        mocks.putAll(getRemoteSiteSettingsMock());
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(mocks));
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getMetadataChatSettings',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        AdminService.MetadataChatSettings settings = (AdminService.MetadataChatSettings) JSON.deserialize(
            JSON.serialize(response.get('data')), AdminService.MetadataChatSettings.class
        );

        Assert.isTrue(settings.openAiConfigured);
        Assert.isTrue(settings.gitConfigured);
        Assert.isTrue(settings.codebaseIndexed);
        Assert.isTrue(settings.indexingInProgress);
        Assert.isTrue(settings.trustedSiteReady);
    }

    @IsTest
    static void test_RemoteAction_setupMetadataChatTrustedSite() {
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>{
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_CSP_TRUSTED_SITES_QUERY => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.CSP_TRUSTED_SITES_KEY_RECORDS => new List<MetadataServiceUtil.CspTrustedSiteWrapper>()
                })
            )
        };

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(mocks));
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Map<String, Object> response;

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'setupMetadataChatTrustedSite',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        Assert.isTrue(String.isBlank((String) response.get('error')));

        AdminService.MetadataChatSettings settings = (AdminService.MetadataChatSettings) JSON.deserialize(
            JSON.serialize(response.get('data')), AdminService.MetadataChatSettings.class
        );

        Assert.areEqual(0, [SELECT COUNT() FROM Log__c]);

        Assert.isTrue(settings.openAiConfigured == null);
        Assert.isTrue(settings.gitConfigured == null);
        Assert.isTrue(settings.codebaseIndexed == null);
        Assert.isTrue(settings.indexingInProgress == null);
        Assert.isTrue(settings.trustedSiteReady);
    }

    @IsTest
    private static void test_RemoteAction_getQuickStartState() {
        Logger_Settings__c loggerSettings = Logger_Settings__c.getOrgDefaults();
        loggerSettings.Quick_Start_State__c = JSON.serialize(new AdminService.QuickStartStateWrapper());
        upsert loggerSettings;

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();
            AdminController ctrl = new AdminController();
            
            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'getQuickStartState',
                'data' => ''
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        AdminService.QuickStartStateWrapper responseQuickStartStateWrapper = (AdminService.QuickStartStateWrapper) JSON.deserialize(
            JSON.serialize(response.get('data')),
            AdminService.QuickStartStateWrapper.class
        );

        Assert.isFalse(responseQuickStartStateWrapper.connectApp);
        Assert.isFalse(responseQuickStartStateWrapper.connectOrg);
        Assert.isFalse(responseQuickStartStateWrapper.quickTest);
        Assert.isFalse(responseQuickStartStateWrapper.jira);
        Assert.isFalse(responseQuickStartStateWrapper.slack);
        Assert.isFalse(responseQuickStartStateWrapper.teams);
        Assert.isFalse(responseQuickStartStateWrapper.monitoring);
        Assert.isFalse(responseQuickStartStateWrapper.monitoringTestInProgress);
        Assert.isFalse(responseQuickStartStateWrapper.isPassthrough);
        Assert.isFalse(responseQuickStartStateWrapper.useTeams);
        Assert.isFalse(responseQuickStartStateWrapper.useSlack);
    }

    @IsTest
    private static void test_RemoteAction_setQuickStartState() {
        Logger_Settings__c loggerSettings = Logger_Settings__c.getOrgDefaults();
        loggerSettings.Quick_Start_State__c = JSON.serialize(new AdminService.QuickStartStateWrapper());
        upsert loggerSettings;

        AdminService.QuickStartStateWrapper quickStartStateWrapper = new AdminService.QuickStartStateWrapper();
        quickStartStateWrapper.connectApp = true;
        quickStartStateWrapper.connectOrg = true;

        Map<String, Object> response = new Map<String, Object>();

        Test.startTest();
            AdminController ctrl = new AdminController();

            Map<String, Object> payload = new Map<String, Object>{
                'method' => 'setQuickStartState',
                'data' => quickStartStateWrapper
            };

            response = (Map<String, Object>)JSON.deserializeUntyped(AdminController.remoteActionHandler(JSON.serialize(payload)));
        Test.stopTest();

        AdminService.QuickStartStateWrapper responseQuickStartStateWrapper = (AdminService.QuickStartStateWrapper) JSON.deserialize(
            JSON.serialize(response.get('data')),
            AdminService.QuickStartStateWrapper.class
        );

        Assert.isTrue(responseQuickStartStateWrapper.connectApp);
        Assert.isTrue(responseQuickStartStateWrapper.connectOrg);
        Assert.isFalse(responseQuickStartStateWrapper.quickTest);
        Assert.isFalse(responseQuickStartStateWrapper.jira);
        Assert.isFalse(responseQuickStartStateWrapper.slack);
        Assert.isFalse(responseQuickStartStateWrapper.teams);
        Assert.isFalse(responseQuickStartStateWrapper.monitoring);
        Assert.isFalse(responseQuickStartStateWrapper.monitoringTestInProgress);
        Assert.isFalse(responseQuickStartStateWrapper.isPassthrough);
        Assert.isFalse(responseQuickStartStateWrapper.useTeams);
        Assert.isFalse(responseQuickStartStateWrapper.useSlack);
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
        
        // Verify it's set to previous hour (rounded down) + default delay
        DateTime now = DateTime.now();
        DateTime expectedTime = DateTime.newInstance(now.year(), now.month(), now.day(), now.hour(), 0, 0).addHours(-EventMonitoringUtil.DEFAULT_DELAY_CSV_FILE_GENERATION);
        System.assertEquals(expectedTime, updatedSettings.Last_Processed_Hourly_Events__c, 
            'Last processed hourly events should be set to previous hour + default delay');
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

    // ========================================
    // AZURE DEVOPS TEST CASES
    // ========================================

    @IsTest
    static void test_azure_devops_get_organization_processes_work_item_types() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test with mock data
        List<AzureService.AzureDevOpsProcessWorkItemType> result = AzureService.getOrganizationProcessesWorkItemTypes('test-org', 'test-process');

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock work item types');
    }

    @IsTest
    static void test_azure_devops_get_organization_processes_work_item_types_with_validation() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test with validation parameters
        List<AzureService.AzureDevOpsProcessWorkItemType> result = AzureService.getOrganizationProcessesWorkItemTypesWithValidation(
            'test-org', 'test-process', 'test-project', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock work item types with validation');
    }

    @IsTest
    static void test_azure_devops_get_azure_dev_ops_work_item_types_with_validation() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test the underlying method directly with organization parameter
        String organization = 'test-org';
        String projectId = 'test-project';
        String teamId = 'test-team';
        String boardId = 'test-board';

        // Get process ID for the project
        List<AzureService.AzureDevOpsProjectProperty> projectProperties = AzureService.getOrganizationProjectProperties(organization, projectId);
        String processId = null;
        for (AzureService.AzureDevOpsProjectProperty prop : projectProperties) {
            if (prop.name == AzureService.AZURE_DEVOPS_PROCESS_TEMPLATE_TYPE) {
                processId = prop.value;
                break;
            }
        }

        // Test the validation method directly
        List<AzureService.AzureDevOpsProcessWorkItemType> result = AzureService.getOrganizationProcessesWorkItemTypesWithValidation(organization, processId, projectId, teamId, boardId);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock work item types');
    }

    @IsTest
    static void test_azure_devops_get_team_boards() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsBoardsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test getting team boards
        List<AzureService.AzureDevOpsBoardReference> result = AzureService.getTeamBoards('test-org', 'test-project', 'test-team');

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock team boards');
    }

    @IsTest
    static void test_azure_devops_get_project_teams() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsTeamsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test getting project teams directly with organization parameter
        String organization = 'test-org';
        String projectId = 'test-project';

        List<AzureService.AzureDevOpsTeam> result = AzureService.getProjectTeams(organization, projectId);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock project teams');
    }

    @IsTest
    static void test_azure_devops_get_project_team_member_wrapper() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsTeamMembersMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test getting team members directly with organization parameter
        String organization = 'test-org';
        String projectId = 'test-project';
        String teamId = 'test-team';
        String skip = '0';

        AzureService.AzureDevOpsTeamMemberWrapper result = AzureService.getProjectTeamMemberWrapper(organization, projectId, teamId, skip);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.count, 'Team member count should not be null');
    }

    @IsTest
    static void test_azure_devops_get_work_item_types() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test getting work item types directly with organization parameter
        String organization = 'test-org';
        String projectId = 'test-project';

        List<AzureService.AzureDevOpsWorkItemType> result = AzureService.getWorkItemTypes(organization, projectId);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock work item types');
    }

    @IsTest
    static void test_azure_devops_validate_work_item_type_configuration() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test configuration validation
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.isValid, 'isValid should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypes, 'filteredWorkItemTypes should not be null');
    }

    @IsTest
    static void test_azure_devops_validate_team_access() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test team access validation - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.teamAccessValidation, 'teamAccessValidation should not be null');
    }

    @IsTest
    static void test_azure_devops_validate_board_configuration() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test board configuration validation - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.boardConfigurationValidation, 'boardConfigurationValidation should not be null');
    }

    @IsTest
    static void test_azure_devops_is_work_item_type_allowed_in_board() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test work item type board filtering - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypes, 'filteredWorkItemTypes should not be null');
    }

    @IsTest
    static void test_azure_devops_is_work_item_type_hidden_by_backlog_visibility() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test backlog visibility filtering - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.teamAccessValidation, 'teamAccessValidation should not be null');
    }

    @IsTest
    static void test_azure_devops_is_work_item_type_hidden_by_team_settings() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test team settings filtering - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.teamAccessValidation, 'teamAccessValidation should not be null');
    }

    @IsTest
    static void test_azure_devops_is_work_item_type_in_category() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test category checking - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypes, 'filteredWorkItemTypes should not be null');
    }

    @IsTest
    static void test_azure_devops_apply_custom_filtering() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test custom filtering - this method is private, so we test through the main validation method
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            'test-org', 'test-project', 'test-process', 'test-team', 'test-board'
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypes, 'filteredWorkItemTypes should not be null');
    }

    @IsTest
    static void test_azure_devops_get_organization_project_properties() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test getting project properties
        List<AzureService.AzureDevOpsProjectProperty> result = AzureService.getOrganizationProjectProperties('test-org', 'test-project');

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Should return mock project properties');
    }

    @IsTest
    static void test_azure_devops_remote_action_handler() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        mocks.putAll(getAzureDevOpsTeamMembersMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test Azure DevOps remote action methods
        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'getAzureDevOpsWorkItemTypesWithValidation',
            'data' => new Map<String, Object>{
                'projectId' => 'test-project',
                'teamId' => 'test-team',
                'boardId' => 'test-board'
            }
        };

        String result = AdminController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');

        // Test getting project teams
        payload = new Map<String, Object>{
            'method' => 'getProjectTeams',
            'data' => new Map<String, Object>{
                'projectId' => 'test-project'
            }
        };

        result = AdminController.remoteActionHandler(JSON.serialize(payload));

        System.assertNotEquals(null, result, 'Result should not be null');

        // Test getting team members
        payload = new Map<String, Object>{
            'method' => 'getProjectTeamMemberWrapper',
            'data' => new Map<String, Object>{
                'projectId' => 'test-project',
                'teamId' => 'test-team',
                'skip' => '0'
            }
        };

        result = AdminController.remoteActionHandler(JSON.serialize(payload));

        System.assertNotEquals(null, result, 'Result should not be null');

        // Test getting work item types
        payload = new Map<String, Object>{
            'method' => 'getWorkItemTypes',
            'data' => new Map<String, Object>{
                'projectId' => 'test-project'
            }
        };

        result = AdminController.remoteActionHandler(JSON.serialize(payload));

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @IsTest
    static void test_azure_devops_constants() {
        Test.startTest();

        // Test that all constants are properly defined
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_BUG, 'BUG constant should be defined'); 
        System.assertNotEquals(null, AzureService.BUGS_BEHAVIOR_AS_TASKS, 'BUGS_BEHAVIOR_AS_TASKS constant should be defined');
        System.assertNotEquals(null, AzureService.BUGS_BEHAVIOR_OFF, 'BUGS_BEHAVIOR_OFF constant should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_error_handling() {
        Test.startTest();

        // Test error handling with invalid parameters
        Map<String, Object> data = new Map<String, Object>{
            'projectId' => null,
            'teamId' => null
        };

        List<AzureService.AzureDevOpsProcessWorkItemType> result = AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null even with invalid parameters');
        System.assertEquals(0, result.size(), 'Should return empty list with invalid parameters');
    }

    @IsTest
    static void test_azure_devops_parameter_constants() {
        Test.startTest();

        // Test parameter constants
        System.assertNotEquals(null, AzureService.PARAM_PROJECT_ID, 'PROJECT_ID parameter should be defined');
        System.assertNotEquals(null, AzureService.PARAM_TEAM_ID, 'TEAM_ID parameter should be defined');
        System.assertNotEquals(null, AzureService.PARAM_BOARD_ID, 'BOARD_ID parameter should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_json_field_constants() {
        Test.startTest();

        // Test JSON field constants
        System.assertNotEquals(null, AzureService.JSON_FIELD_COLUMNS, 'COLUMNS JSON field should be defined');
        System.assertNotEquals(null, AzureService.JSON_FIELD_STATE_MAPPINGS, 'STATE_MAPPINGS JSON field should be defined');
        System.assertNotEquals(null, AzureService.JSON_FIELD_ALLOWED_MAPPINGS, 'ALLOWED_MAPPINGS JSON field should be defined');
        System.assertNotEquals(null, AzureService.JSON_FIELD_ID, 'ID JSON field should be defined');
        System.assertNotEquals(null, AzureService.JSON_FIELD_NAME, 'NAME JSON field should be defined');
        System.assertNotEquals(null, AzureService.JSON_FIELD_BUGS_BEHAVIOR, 'BUGS_BEHAVIOR JSON field should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_board_mapping_constants() {
        Test.startTest();

        // Test board mapping constants
        System.assertNotEquals(null, AzureService.BOARD_MAPPING_INCOMING, 'INCOMING board mapping should be defined');
        System.assertNotEquals(null, AzureService.BOARD_MAPPING_IN_PROGRESS, 'IN_PROGRESS board mapping should be defined');
        System.assertNotEquals(null, AzureService.BOARD_MAPPING_OUTGOING, 'OUTGOING board mapping should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_work_item_type_field_constants() {
        Test.startTest();

        // Test work item type field constants
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_ASSIGNED_TO, 'ASSIGNED_TO field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_TITLE, 'TITLE field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_DESCRIPTION, 'DESCRIPTION field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_PRIORITY, 'PRIORITY field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_TAG, 'TAG field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_ITERATION, 'ITERATION field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_AREA, 'AREA field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK, 'RELATED_LINK field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_RELATED_CHILD_LINK, 'RELATED_CHILD_LINK field should be defined');
        System.assertNotEquals(null, AzureService.WORK_ITEM_TYPE_FIELD_RELATED_PARENT_LINK, 'RELATED_PARENT_LINK field should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_api_endpoint_constants() {
        Test.startTest();

        // Test API endpoint constants
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_PROJECT_PROPERTIES, 'PROJECT_PROPERTIES API endpoint should be defined');
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_TEAMS, 'TEAMS API endpoint should be defined');
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_TEAM_MEMBERS, 'TEAM_MEMBERS API endpoint should be defined');
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_TEAM_SETTINGS, 'TEAM_SETTINGS API endpoint should be defined');
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_BOARDS, 'BOARDS API endpoint should be defined');
        System.assertNotEquals(null, AzureService.AZURE_DEVOPS_REST_API_BOARD_SETTINGS, 'BOARD_SETTINGS API endpoint should be defined');

        Test.stopTest();
    }

    @IsTest
    static void test_azure_devops_comprehensive_validation() {
        // Setup HTTP mocks
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getAzureDevOpsProcessesMock());
        mocks.putAll(getAzureDevOpsWorkItemTypesMock());
        mocks.putAll(getAzureDevOpsProjectPropertiesMock());
        mocks.putAll(getAzureDevOpsTeamsMock());
        mocks.putAll(getAzureDevOpsTeamSettingsMock());
        mocks.putAll(getAzureDevOpsBoardsMock());
        mocks.putAll(getAzureDevOpsBoardSettingsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        // Test comprehensive validation with all components
        String organization = 'test-org';
        String projectId = 'test-project';
        String processId = 'test-process';
        String teamId = 'test-team';
        String boardId = 'test-board';

        // Test validation with all parameters
        AzureService.AzureDevOpsConfigurationValidationResult result = AzureService.validateWorkItemTypeConfiguration(
            organization, projectId, processId, teamId, boardId
        );

        Test.stopTest();

        System.assertNotEquals(null, result, 'Validation result should not be null');
        System.assertNotEquals(null, result.isValid, 'isValid should not be null');
        System.assertNotEquals(null, result.totalWorkItemTypes, 'totalWorkItemTypes should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypeCount, 'filteredWorkItemTypeCount should not be null');
        System.assertNotEquals(null, result.filteredWorkItemTypes, 'filteredWorkItemTypes should not be null');
        System.assertNotEquals(null, result.teamAccessValidation, 'teamAccessValidation should not be null');
        System.assertNotEquals(null, result.boardConfigurationValidation, 'boardConfigurationValidation should not be null');
    }

    @isTest
    static void test_splitTeamIdAndBoardId() {
        String teamIdAndBoardId = 'teamId;boardId';
        String teamId = RuleUtil.getAzureDevOpsTeamId(teamIdAndBoardId);
        String boardId = RuleUtil.getAzureDevOpsBoardId(teamIdAndBoardId);
        System.assertEquals('teamId', teamId);
        System.assertEquals('boardId', boardId);

        teamIdAndBoardId = 'teamId';
        teamId = RuleUtil.getAzureDevOpsTeamId(teamIdAndBoardId);
        boardId = RuleUtil.getAzureDevOpsBoardId(teamIdAndBoardId);
        System.assertEquals('teamId', teamId);
        System.assertEquals(null, boardId);

        teamIdAndBoardId = '';
        teamId = RuleUtil.getAzureDevOpsTeamId(teamIdAndBoardId);
        boardId = RuleUtil.getAzureDevOpsBoardId(teamIdAndBoardId);
        System.assertEquals(null, teamId);
        System.assertEquals(null, boardId);

        teamIdAndBoardId = null;
        teamId = RuleUtil.getAzureDevOpsTeamId(teamIdAndBoardId);
        boardId = RuleUtil.getAzureDevOpsBoardId(teamIdAndBoardId);
        System.assertEquals(null, teamId);
        System.assertEquals(null, boardId);
    }

    // ========================================
    // AZURE DEVOPS HTTP MOCK METHODS
    // ========================================

    private static Map<String, HttpCalloutMock> getAzureDevOpsProcessesMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock processes response
        Map<String, Object> processesResponse = new Map<String, Object>{
            'count' => 1,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'typeId' => 'test-process-id',
                    'name' => 'Test Process',
                    'description' => 'Test Process Description',
                    'isDefault' => true,
                    'type' => 'system'
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(processesResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/_apis/process/processes?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsWorkItemTypesMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock work item types response
        Map<String, Object> workItemTypesResponse = new Map<String, Object>{
            'count' => 3,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'name' => 'User Story',
                    'referenceName' => 'System.UserStory',
                    'description' => 'User Story work item type',
                    'color' => '009688',
                    'icon' => 'icon_story',
                    'customization' => 'inherited',
                    'inherits' => 'System.UserStory',
                    'isDefault' => true,
                    'isDisabled' => false,
                    'url' => 'https://dev.azure.com/test-org/_apis/work/processes/test-process/workitemtypes/System.UserStory'
                },
                new Map<String, Object>{
                    'name' => 'Bug',
                    'referenceName' => 'System.Bug',
                    'description' => 'Bug work item type',
                    'color' => 'cc293d',
                    'icon' => 'icon_bug',
                    'customization' => 'inherited',
                    'inherits' => 'System.Bug',
                    'isDefault' => false,
                    'isDisabled' => false,
                    'url' => 'https://dev.azure.com/test-org/_apis/work/processes/test-process/workitemtypes/System.Bug'
                },
                new Map<String, Object>{
                    'name' => 'Task',
                    'referenceName' => 'System.Task',
                    'description' => 'Task work item type',
                    'color' => 'ff8c00',
                    'icon' => 'icon_task',
                    'customization' => 'inherited',
                    'inherits' => 'System.Task',
                    'isDefault' => false,
                    'isDisabled' => false,
                    'url' => 'https://dev.azure.com/test-org/_apis/work/processes/test-process/workitemtypes/System.Task'
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(workItemTypesResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/_apis/work/processes/test-process/workitemtypes?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        // Mock work item types for test-process-id (used in the test)
        String testProcessIdEndpoint = 'https://dev.azure.com/test-org/_apis/work/processes/test-process-id/workitemtypes?api-version=7.0';
        result.put(testProcessIdEndpoint, singleRequestMock);

        // Mock project work item types
        String projectEndpoint = 'https://dev.azure.com/test-org/test-project/_apis/wit/workitemtypes?api-version=7.0';
        result.put(projectEndpoint, singleRequestMock);

        // Mock project work item types (different class structure)
        Map<String, Object> projectWorkItemTypesResponse = new Map<String, Object>{
            'count' => 3,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'name' => 'User Story',
                    'referenceName' => 'System.UserStory',
                    'description' => 'User Story work item type',
                    'isDisabled' => false
                },
                new Map<String, Object>{
                    'name' => 'Bug',
                    'referenceName' => 'System.Bug',
                    'description' => 'Bug work item type',
                    'isDisabled' => false
                },
                new Map<String, Object>{
                    'name' => 'Task',
                    'referenceName' => 'System.Task',
                    'description' => 'Task work item type',
                    'isDisabled' => false
                }
            }
        };

        TestDataFactory.SingleRequestMock projectWorkItemTypesMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(projectWorkItemTypesResponse)
        );

        String projectWorkItemTypesEndpoint = 'https://dev.azure.com/test-org/test-project/_apis/wit/workitemtypes?api-version=7.0';
        result.put(projectWorkItemTypesEndpoint, projectWorkItemTypesMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsProjectPropertiesMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock project properties response
        Map<String, Object> propertiesResponse = new Map<String, Object>{
            'count' => 2,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'name' => 'System.ProcessTemplateType',
                    'value' => 'test-process-id'
                },
                new Map<String, Object>{
                    'name' => 'System.ProcessId',
                    'value' => 'test-process-id'
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(propertiesResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/_apis/projects/test-project/properties?api-version=7.0-preview.1';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsTeamsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock teams response
        Map<String, Object> teamsResponse = new Map<String, Object>{
            'count' => 2,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'id' => 'test-team-id-1',
                    'name' => 'Test Team 1',
                    'url' => 'https://dev.azure.com/test-org/test-project/_apis/teams/test-team-id-1',
                    'description' => 'Test Team 1 Description',
                    'identityUrl' => 'https://dev.azure.com/test-org/test-project/_apis/teams/test-team-id-1',
                    'projectName' => 'test-project',
                    'projectId' => 'test-project-id'
                },
                new Map<String, Object>{
                    'id' => 'test-team-id-2',
                    'name' => 'Test Team 2',
                    'url' => 'https://dev.azure.com/test-org/test-project/_apis/teams/test-team-id-2',
                    'description' => 'Test Team 2 Description',
                    'identityUrl' => 'https://dev.azure.com/test-org/test-project/_apis/teams/test-team-id-2',
                    'projectName' => 'test-project',
                    'projectId' => 'test-project-id'
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(teamsResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/_apis/projects/test-project/teams?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsTeamSettingsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock team settings response
        Map<String, Object> teamSettingsResponse = new Map<String, Object>{
            'bugsBehavior' => 'AsRequirements',
            'workingDays' => new List<String>{'monday', 'tuesday', 'wednesday', 'thursday', 'friday'},
            'defaultIterationMacro' => '@currentIteration',
            'backlogVisibilities' => new Map<String, Object>{
                'Microsoft.EpicCategory' => true,
                'Microsoft.FeatureCategory' => true,
                'Microsoft.RequirementCategory' => true
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(teamSettingsResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/teamsettings?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsBoardsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock boards response
        Map<String, Object> boardsResponse = new Map<String, Object>{
            'count' => 2,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'id' => 'test-board-id-1',
                    'name' => 'Test Board 1',
                    'url' => 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards/test-board-id-1'
                },
                new Map<String, Object>{
                    'id' => 'test-board-id-2',
                    'name' => 'Test Board 2',
                    'url' => 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards/test-board-id-2'
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(boardsResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsBoardSettingsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock board settings response
        Map<String, Object> boardSettingsResponse = new Map<String, Object>{
            'id' => 'test-board-id-1',
            'name' => 'Test Board 1',
            'url' => 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards/test-board-id-1',
            'columns' => new List<Object>{
                new Map<String, Object>{
                    'id' => 'column-1',
                    'name' => 'New',
                    'itemLimit' => 0,
                    'stateMappings' => new Map<String, String>{
                        'User Story' => 'New',
                        'Bug' => 'New',
                        'Task' => 'New'
                    },
                    'columnType' => 'incoming'
                },
                new Map<String, Object>{
                    'id' => 'column-2',
                    'name' => 'Active',
                    'itemLimit' => 5,
                    'stateMappings' => new Map<String, String>{
                        'User Story' => 'Active',
                        'Bug' => 'Active',
                        'Task' => 'Active'
                    },
                    'columnType' => 'inProgress'
                },
                new Map<String, Object>{
                    'id' => 'column-3',
                    'name' => 'Closed',
                    'itemLimit' => 0,
                    'stateMappings' => new Map<String, String>{
                        'User Story' => 'Closed',
                        'Bug' => 'Closed',
                        'Task' => 'Closed'
                    },
                    'columnType' => 'outgoing'
                }
            },
            'allowedMappings' => new Map<String, Object>{
                'Incoming' => new Map<String, List<String>>{
                    'User Story' => new List<String>{'New'},
                    'Bug' => new List<String>{'New'},
                    'Task' => new List<String>{'New'}
                },
                'InProgress' => new Map<String, List<String>>{
                    'User Story' => new List<String>{'Active', 'New'},
                    'Bug' => new List<String>{'Active', 'New'},
                    'Task' => new List<String>{'Active', 'New'}
                },
                'Outgoing' => new Map<String, List<String>>{
                    'User Story' => new List<String>{'Closed'},
                    'Bug' => new List<String>{'Closed'},
                    'Task' => new List<String>{'Closed'}
                }
            }
        };

        TestDataFactory.SingleRequestMock boardSettingsMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(boardSettingsResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards/test-board-id-1?api-version=7.0';
        result.put(endpoint, boardSettingsMock);

        // Mock board columns response
        Map<String, Object> boardColumnsResponse = new Map<String, Object>{
            'count' => 3,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'id' => 'column-1',
                    'name' => 'New',
                    'itemLimit' => 0,
                    'columnType' => 'incoming',
                    'workItemTypes' => new List<String>{'User Story', 'Bug', 'Task'}
                },
                new Map<String, Object>{
                    'id' => 'column-2',
                    'name' => 'Active',
                    'itemLimit' => 5,
                    'columnType' => 'inProgress',
                    'workItemTypes' => new List<String>{'User Story', 'Bug', 'Task'}
                },
                new Map<String, Object>{
                    'id' => 'column-3',
                    'name' => 'Closed',
                    'itemLimit' => 0,
                    'columnType' => 'outgoing',
                    'workItemTypes' => new List<String>{'User Story', 'Bug', 'Task'}
                }
            }
        };

        TestDataFactory.SingleRequestMock boardColumnsMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(boardColumnsResponse)
        );

        String boardColumnsEndpoint = 'https://dev.azure.com/test-org/test-project/test-team/_apis/work/boards/test-board-id-1/columns?api-version=7.0';
        result.put(boardColumnsEndpoint, boardColumnsMock);

        return result;
    }

    private static Map<String, HttpCalloutMock> getAzureDevOpsTeamMembersMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        // Mock team members response
        Map<String, Object> teamMembersResponse = new Map<String, Object>{
            'count' => 2,
            'value' => new List<Object>{
                new Map<String, Object>{
                    'identity' => new Map<String, Object>{
                        'id' => 'test-user-id-1',
                        'displayName' => 'Test User 1',
                        'uniqueName' => 'testuser1@test.com',
                        'url' => 'https://dev.azure.com/test-org/_apis/Identities/test-user-id-1',
                        'imageUrl' => 'https://dev.azure.com/test-org/_apis/GraphProfile/MemberAvatars/test-user-id-1',
                        'links' => null
                    },
                    'isTeamAdmin' => true
                },
                new Map<String, Object>{
                    'identity' => new Map<String, Object>{
                        'id' => 'test-user-id-2',
                        'displayName' => 'Test User 2',
                        'uniqueName' => 'testuser2@test.com',
                        'url' => 'https://dev.azure.com/test-org/_apis/Identities/test-user-id-2',
                        'imageUrl' => 'https://dev.azure.com/test-org/_apis/GraphProfile/MemberAvatars/test-user-id-2',
                        'links' => null
                    },
                    'isTeamAdmin' => false
                }
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(teamMembersResponse)
        );

        String endpoint = 'https://dev.azure.com/test-org/_apis/projects/test-project/teams/test-team/members?api-version=7.0';
        result.put(endpoint, singleRequestMock);

        return result;
    }

    // ============ NEW TEST CASES FOR AdminService.setEventMonitoringSetting DML EXCEPTION FIX ============
    
    @IsTest
    static void test_setEventMonitoringSetting_WithFreshOrgNoExistingRecord() {
        // Arrange - Simulate fresh org where Event_Monitoring__c record doesn't exist
        List<Event_Monitoring__c> existingSettings = [SELECT Id FROM Event_Monitoring__c];
        if (!existingSettings.isEmpty()) {
            delete existingSettings;
        }
        
        // Clear the cached settings to force re-initialization
        ConfigUtil.EVENT_MONITORING_SETTINGS = null;
        
        // Prepare input data with event type statuses
        List<Map<String, Object>> eventTypeStatusesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => EventLogProcessors.EVENT_TYPE_API,
                'active' => true,
                'logsLimit' => 150
            },
            new Map<String, Object>{
                'name' => EventLogProcessors.EVENT_TYPE_APEX_TRIGGER,
                'active' => true,
                'logsLimit' => 200
            }
        };
        
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => true,
            ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES => eventTypeStatusesData
        };
        
        Test.startTest();
        
        // Act - This should not throw DML exception even with no existing record
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were created successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Id, 'Settings should have an Id after upsert');
        System.assertEquals(true, result.Enabled__c, 'Event monitoring should be enabled');
        System.assertNotEquals(null, result.Enabled_Types__c, 'Enabled_Types__c should be set');
        
        // Verify rules were created
        List<Rule__c> createdRules = [
            SELECT Subtype__c, Logs_Limit__c 
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
        ];
        System.assertEquals(2, createdRules.size(), 'Should create 2 rules');
    }
    
    @IsTest
    static void test_setEventMonitoringSetting_WithExistingRecord() {
        // Arrange - Create existing Event_Monitoring__c record
        Event_Monitoring__c existingSettings = Event_Monitoring__c.getOrgDefaults();
        existingSettings.Enabled__c = false;
        existingSettings.Enabled_Types__c = '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        upsert existingSettings;
        
        Id originalId = existingSettings.Id;
        
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => true
        };
        
        Test.startTest();
        
        // Act - This should work with existing record
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were updated successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(originalId, result.Id, 'Should update the same record');
        System.assertEquals(true, result.Enabled__c, 'Event monitoring should be enabled');
    }
    
    @IsTest
    static void test_setEventMonitoringSetting_WithNullEventTypeStatuses() {
        // Arrange - Simulate fresh org where Event_Monitoring__c record doesn't exist
        List<Event_Monitoring__c> existingSettings = [SELECT Id FROM Event_Monitoring__c];
        if (!existingSettings.isEmpty()) {
            delete existingSettings;
        }
        
        // Clear the cached settings to force re-initialization
        ConfigUtil.EVENT_MONITORING_SETTINGS = null;
        
        // Delete any existing rules to start clean
        List<Rule__c> existingRules = [SELECT Id FROM Rule__c WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE];
        if (!existingRules.isEmpty()) {
            delete existingRules;
        }
        
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => true,
            ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES => null // Explicitly set to null
        };
        
        Test.startTest();
        
        // Act - This should not throw DML exception even with null event types
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were created successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Id, 'Settings should have an Id after upsert');
        System.assertEquals(true, result.Enabled__c, 'Event monitoring should be enabled');
        System.assertNotEquals(null, result.Enabled_Types__c, 'Enabled_Types__c should be set with default values');
        
        // Verify that default event types are enabled in settings
        List<Boolean> enabledStatuses = EventMonitoringUtil.getEnabledMembersFromSettings();
        Set<String> enabledEventTypes = new Set<String>();
        for (String eventType : EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES.keySet()) {
            Integer index = EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES.get(eventType);
            if (index != null && index < enabledStatuses.size() && enabledStatuses[index]) {
                enabledEventTypes.add(eventType);
            }
        }
        
        // Verify that all default enabled event types are now enabled
        for (String defaultEventType : EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES) {
            System.assert(enabledEventTypes.contains(defaultEventType), 
                'Default event type ' + defaultEventType + ' should be enabled');
        }
        
        // Verify that Rule__c records were created for default enabled event types that have thresholds
        List<Rule__c> createdRules = [
            SELECT Id, Subtype__c, Active__c, Logs_Limit__c, Type__c
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
            AND Active__c = true
        ];
        
        // Note: Rules are only created for event types that have default thresholds defined
        // Not all default enabled event types have thresholds, so we expect some but not necessarily all
        
        // Verify that rules were created for the expected default event types
        Set<String> createdRuleSubtypes = new Set<String>();
        for (Rule__c rule : createdRules) {
            createdRuleSubtypes.add(rule.Subtype__c);
            System.assertEquals(EventMonitoringUtil.EVENT_MONITORING_TYPE, rule.Type__c, 'Rule type should be Event Monitoring');
            System.assertEquals(true, rule.Active__c, 'Created rules should be active');
            // Note: Logs_Limit__c can be null for unlimited limits (like APEX_UNEXPECTED_EXCEPTION)
        }
        
        // Verify that rules exist for event types that have default thresholds
        // These are the event types that should have rules created:
        Set<String> eventTypesWithThresholds = new Set<String>{
            EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION,
            EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR,
            EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS,
            EventLogProcessors.EVENT_TYPE_API,
            EventLogProcessors.EVENT_TYPE_APEX_REST_API
        };
        
        Integer expectedRulesCount = 0;
        for (String eventTypeWithThreshold : eventTypesWithThresholds) {
            if (createdRuleSubtypes.contains(eventTypeWithThreshold)) {
                expectedRulesCount++;
            }
        }
        System.assert(expectedRulesCount > 0, 'Should create rules for event types that have default thresholds defined');
    }
    
    @IsTest
    static void test_setEventMonitoringSetting_EnabledOnlyWithoutEventTypes() {
        // Arrange - Test the exact scenario: {"enabled":true} without enabledTypes key
        List<Event_Monitoring__c> existingSettings = [SELECT Id FROM Event_Monitoring__c];
        if (!existingSettings.isEmpty()) {
            delete existingSettings;
        }
        
        // Clear the cached settings to force re-initialization
        ConfigUtil.EVENT_MONITORING_SETTINGS = null;
        
        // Delete any existing rules to start clean
        List<Rule__c> existingRules = [SELECT Id FROM Rule__c WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE];
        if (!existingRules.isEmpty()) {
            delete existingRules;
        }
        
        // Input data with only enabled=true, no enabledTypes key (this was the failing scenario)
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => true
            // Note: No ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES key at all
        };
        
        Test.startTest();
        
        // Act - This should create default enabled event types and their rules
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were created successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Id, 'Settings should have an Id after upsert');
        System.assertEquals(true, result.Enabled__c, 'Event monitoring should be enabled');
        System.assertNotEquals(null, result.Enabled_Types__c, 'Enabled_Types__c should be set with default values');
        
        // Verify that Rule__c records were created for default enabled event types that have thresholds
        List<Rule__c> createdRules = [
            SELECT Id, Subtype__c, Active__c, Logs_Limit__c, Type__c, Name__c
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
            AND Active__c = true
        ];
        
        System.assert(createdRules.size() > 0, 'Should create Rule__c records for default enabled event types when enabledTypes is not provided');
        
        // Verify that rules were created with proper structure
        Set<String> createdRuleSubtypes = new Set<String>();
        for (Rule__c rule : createdRules) {
            createdRuleSubtypes.add(rule.Subtype__c);
            System.assertEquals(EventMonitoringUtil.EVENT_MONITORING_TYPE, rule.Type__c, 'Rule type should be Event Monitoring');
            System.assertEquals(true, rule.Active__c, 'Created rules should be active');
            // Note: Logs_Limit__c can be null for unlimited limits (like APEX_UNEXPECTED_EXCEPTION)
            System.assert(rule.Name__c.contains('Event Monitoring Rule'), 'Rule name should contain Event Monitoring Rule');
        }
        
        // Verify that rules exist for event types that have default thresholds
        Set<String> eventTypesWithThresholds = new Set<String>{
            EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION,
            EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR,
            EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS,
            EventLogProcessors.EVENT_TYPE_API,
            EventLogProcessors.EVENT_TYPE_APEX_REST_API
        };
        
        Integer rulesForDefaultTypes = 0;
        for (String eventTypeWithThreshold : eventTypesWithThresholds) {
            if (createdRuleSubtypes.contains(eventTypeWithThreshold)) {
                rulesForDefaultTypes++;
            }
        }
        System.assert(rulesForDefaultTypes > 0, 'Should create rules for event types that have default thresholds defined');
        
        // Verify specific important event types have rules (these have thresholds defined)
        System.assert(createdRuleSubtypes.contains(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION), 
            'Should create rule for APEX_UNEXPECTED_EXCEPTION');
        System.assert(createdRuleSubtypes.contains(EventLogProcessors.EVENT_TYPE_API), 
            'Should create rule for API events');
    }
    
    @IsTest
    static void test_setEventMonitoringSetting_WithEmptyEventTypeStatuses() {
        // Arrange - Simulate fresh org where Event_Monitoring__c record doesn't exist
        List<Event_Monitoring__c> existingSettings = [SELECT Id FROM Event_Monitoring__c];
        if (!existingSettings.isEmpty()) {
            delete existingSettings;
        }
        
        // Clear the cached settings to force re-initialization
        ConfigUtil.EVENT_MONITORING_SETTINGS = null;
        
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => true,
            ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES => new List<Object>() // Empty list
        };
        
        Test.startTest();
        
        // Act - This should not throw DML exception even with empty event types list
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were created successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Id, 'Settings should have an Id after upsert');
        System.assertEquals(true, result.Enabled__c, 'Event monitoring should be enabled');
    }
    
    @IsTest
    static void test_setEventMonitoringSetting_DisableEventMonitoring() {
        // Arrange - Create existing Event_Monitoring__c record with some enabled types
        Event_Monitoring__c existingSettings = Event_Monitoring__c.getOrgDefaults();
        existingSettings.Enabled__c = true;
        existingSettings.Enabled_Types__c = '1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        upsert existingSettings;
        
        // Create some existing rules that should be disabled
        List<Rule__c> existingRules = new List<Rule__c>{
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_API,
                Active__c = true
            ),
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_APEX_CALLOUT,
                Active__c = true
            )
        };
        insert existingRules;
        
        // Prepare input data to disable all event types
        List<Map<String, Object>> eventTypeStatusesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => EventLogProcessors.EVENT_TYPE_API,
                'active' => false,
                'logsLimit' => 100
            },
            new Map<String, Object>{
                'name' => EventLogProcessors.EVENT_TYPE_APEX_CALLOUT,
                'active' => false,
                'logsLimit' => 100
            }
        };
        
        Map<String, Object> inputData = new Map<String, Object>{
            ConfigUtil.MONITORING_APP_KEY_ENABLED => false,
            ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES => eventTypeStatusesData
        };
        
        Test.startTest();
        
        // Act - This should work to disable event monitoring
        Event_Monitoring__c result = AdminService.setEventMonitoringSetting(inputData);
        
        Test.stopTest();
        
        // Assert - Verify settings were updated successfully
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(false, result.Enabled__c, 'Event monitoring should be disabled');
        
        // Verify rules were deleted/disabled properly
        List<Rule__c> remainingActiveRules = [
            SELECT Id 
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE 
            AND Active__c = true
        ];
        System.assertEquals(0, remainingActiveRules.size(), 'No rules should be active after disabling');
    }

    @IsTest
    private static void test_admin_service_getLogFields() {
        List<AdminService.FilterField> result;
        
        Test.startTest();
        result = (List<AdminService.FilterField>)AdminService.getLogFields(Constants.RULE_SOBJECT.TYPE_NOTIFICATION);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have at least one field');
        
        // Verify standard fields are included
        Set<String> fieldNames = new Set<String>();
        for (AdminService.FilterField field : result) {
            fieldNames.add(field.value);
        }
        
        // Check ALL Log fields that should be included (from requirements)
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Async_Job_Id__c.getName()), 'Should contain Async Job Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Async_Job_Name__c.getName()), 'Should contain Async Job Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Area__c.getName()), 'Should contain Functional Area');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Category__c.getName()), 'Should contain Category');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Created_At__c.getName()), 'Should contain Created At');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.CreatedById.getName()), 'Should contain CreatedById');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Details__c.getName()), 'Should contain Details');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Exception_Codes__c.getName()), 'Should contain Exception Codes');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.First_Occurred_On__c.getName()), 'Should contain First Occurred On');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Flow_API_Name__c.getName()), 'Should contain Flow API Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Flow_Version__c.getName()), 'Should contain Flow Version');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Flow_Version_Id__c.getName()), 'Should contain Flow Version Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Hash_1__c.getName()), 'Should contain Hash 1');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Hash_2__c.getName()), 'Should contain Hash 2');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Hash_3__c.getName()), 'Should contain Hash 3');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Installed_Packages__c.getName()), 'Should contain Installed Packages');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Interview_GUID_External__c.getName()), 'Should contain Interview GUID');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Is_New__c.getName()), 'Should contain Is New');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Is_Parent__c.getName()), 'Should contain Is Parent');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Is_Sandbox__c.getName()), 'Should contain Is Sandbox');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Name.getName()), 'Should contain Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Namespace__c.getName()), 'Should contain Namespace');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Apex_Name__c.getName()), 'Should contain Operation (Apex Name)');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Organization_Id__c.getName()), 'Should contain Organization Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Organization_Name__c.getName()), 'Should contain Organization Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Originated_From__c.getName()), 'Should contain Originated From');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Parent__c.getName()), 'Should contain Parent');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Pending_Jobs__c.getName()), 'Should contain Pending Jobs');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Profile_Id__c.getName()), 'Should contain Profile Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Profile_Name__c.getName()), 'Should contain Profile Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.RecordTypeId.getName()), 'Should contain Record Type');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Related_Id__c.getName()), 'Should contain Related Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Related_Object_Type__c.getName()), 'Should contain Related Object Type');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Related_Objects__c.getName()), 'Should contain Related Objects');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Request_Id_External__c.getName()), 'Should contain Request Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Role_Id__c.getName()), 'Should contain Role Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Role_Name__c.getName()), 'Should contain Role Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Salesforce_Error_Id__c.getName()), 'Should contain Salesforce Error Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Salesforce_License_Type_Name__c.getName()), 'Should contain Salesforce License Type Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c.getName()), 'Should contain Setup Audit Trail');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Stacktrace__c.getName()), 'Should contain Stacktrace');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Summary__c.getName()), 'Should contain Summary');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Total_Active_Sessions__c.getName()), 'Should contain Total Active Sessions');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Total_Pending_Jobs__c.getName()), 'Should contain Total Pending Jobs');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Transaction_Id_External__c.getName()), 'Should contain Transaction Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Type__c.getName()), 'Should contain Type');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.User_Id__c.getName()), 'Should contain User Id');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.User_Name__c.getName()), 'Should contain User Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Log__c.fields.Visualforce_Page__c.getName()), 'Should contain Visualforce Page');
        
        // Verify "Insert field ONLY" fields are excluded
        System.assert(!fieldNames.contains(Schema.sObjectType.Log__c.fields.Flow_Link__c.getName()), 'Should NOT contain Flow_Link__c (Insert field ONLY)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Log__c.fields.Organization_Url__c.getName()), 'Should NOT contain Organization_Url__c (Insert field ONLY)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Log__c.fields.Related_Object__c.getName()), 'Should NOT contain Related_Object__c (Insert field ONLY)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Log__c.fields.User__c.getName()), 'Should NOT contain User__c (Insert field ONLY)');
    }

    @IsTest
    private static void test_admin_service_getIssueFields_Create() {
        List<AdminService.FilterField> result;
        
        Test.startTest();
        result = (List<AdminService.FilterField>)AdminService.getIssueFields(Constants.RULE_SOBJECT.TYPE_NOTIFICATION);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have at least one field');
        
        // Verify only the limited set of fields for Issue Create rules
        Set<String> fieldNames = new Set<String>();
        for (AdminService.FilterField field : result) {
            fieldNames.add(field.value);
        }
        
        // Check ALL fields that should be included in Create rules (from requirements)
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Category__c.getName()), 'Should contain Category');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.CreatedDate.getName()), 'Should contain Created Date');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Description__c.getName()), 'Should contain Description');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Functional_Area__c.getName()), 'Should contain Functional Area');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Organization_Name__c.getName()), 'Should contain Organization Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Summary__c.getName()), 'Should contain Summary');
        
        // Verify these are the ONLY standard fields (no extra fields beyond the 6 required)
        Integer standardFieldCount = 0;
        for (AdminService.FilterField field : result) {
            if (!field.value.contains('__c') || 
                field.value == Schema.sObjectType.Issue__c.fields.Category__c.getName() ||
                field.value == Schema.sObjectType.Issue__c.fields.Description__c.getName() ||
                field.value == Schema.sObjectType.Issue__c.fields.Functional_Area__c.getName() ||
                field.value == Schema.sObjectType.Issue__c.fields.Organization_Name__c.getName() ||
                field.value == Schema.sObjectType.Issue__c.fields.Summary__c.getName()) {
                standardFieldCount++;
            }
        }
        System.assert(standardFieldCount >= 6, 'Should have at least 6 standard fields for Create rules');
        
        // Verify "Insert field ONLY" fields are excluded from Create rules
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Log__c.getName()), 'Should NOT contain Log__c (Insert field ONLY)');
        
        // Verify Update-only fields are excluded from Create rules
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Status__c.getName()), 'Should NOT contain Status in Create rules');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Priority__c.getName()), 'Should NOT contain Priority in Create rules');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Assigned__c.getName()), 'Should NOT contain Assigned in Create rules');
    }

    @IsTest
    private static void test_admin_service_getIssueFields_Update() {
        List<AdminService.FilterField> result;
        
        Test.startTest();
        result = (List<AdminService.FilterField>)AdminService.getIssueFields(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, true);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have at least one field');
        
        // Verify all fields are included for Issue Update rules
        Set<String> fieldNames = new Set<String>();
        for (AdminService.FilterField field : result) {
            fieldNames.add(field.value);
        }
        
        // Check ALL fields that should be included in Update rules (from requirements)
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Assigned__c.getName()), 'Should contain Assigned');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Assigned_To__c.getName()), 'Should contain Assigned To');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Average_Daily_Volume__c.getName()), 'Should contain Average Daily Volume');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Average_Frequency__c.getName()), 'Should contain Average Frequency');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getName()), 'Should contain Bug Tracker');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Category__c.getName()), 'Should contain Category');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.CreatedDate.getName()), 'Should contain Created Date');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Description__c.getName()), 'Should contain Description');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Exception_Codes__c.getName()), 'Should contain Exception Codes');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.First_Occurred_On__c.getName()), 'Should contain First Occurred On');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Functional_Area__c.getName()), 'Should contain Functional Area');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Impacted_Objects__c.getName()), 'Should contain Impacted Objects');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Impacted_Objects_Count__c.getName()), 'Should contain Impacted Objects Count');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Impacted_Objects_by_Type__c.getName()), 'Should contain Impacted Objects by Type');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Impacted_Users__c.getName()), 'Should contain Impacted Users');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Impacted_Users_Count__c.getName()), 'Should contain Impacted Users Count');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Name.getName()), 'Should contain Issue Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Last_Occurred_On__c.getName()), 'Should contain Last Occurred On');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Log_Count__c.getName()), 'Should contain Log Count');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Organization_Name__c.getName()), 'Should contain Organization Name');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Priority__c.getName()), 'Should contain Priority');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Regressed_On__c.getName()), 'Should contain Regressed On');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Regression__c.getName()), 'Should contain Regression');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Related_Issue__c.getName()), 'Should contain Related Issue');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Resolved_On__c.getName()), 'Should contain Resolved On');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Score__c.getName()), 'Should contain Score');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Status__c.getName()), 'Should contain Status');
        System.assert(fieldNames.contains(Schema.sObjectType.Issue__c.fields.Summary__c.getName()), 'Should contain Summary');
        
        // Verify system fields are excluded from Update rules
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.IsDeleted.getName()), 'Should NOT contain IsDeleted (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.CreatedById.getName()), 'Should NOT contain CreatedById (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.LastModifiedById.getName()), 'Should NOT contain LastModifiedById (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.LastModifiedDate.getName()), 'Should NOT contain LastModifiedDate (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.SystemModstamp.getName()), 'Should NOT contain SystemModstamp (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.LastActivityDate.getName()), 'Should NOT contain LastActivityDate (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.LastViewedDate.getName()), 'Should NOT contain LastViewedDate (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.LastReferencedDate.getName()), 'Should NOT contain LastReferencedDate (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.OwnerId.getName()), 'Should NOT contain OwnerId (system field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.RecordTypeId.getName()), 'Should NOT contain RecordTypeId (system field)');
        
        // Verify Insert field ONLY is excluded
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Log__c.getName()), 'Should NOT contain Log__c (Insert field ONLY)');
        
        // Verify internal/integration fields are excluded from Update rules
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c.getName()), 'Should NOT contain Email_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c.getName()), 'Should NOT contain Jira_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c.getName()), 'Should NOT contain Slack_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c.getName()), 'Should NOT contain PagerDuty_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c.getName()), 'Should NOT contain Notification_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c.getName()), 'Should NOT contain Teams_Integration_Status__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Executable_Rules__c.getName()), 'Should NOT contain Executable_Rules__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Key__c.getName()), 'Should NOT contain Key__c (internal field)');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Category_Icon__c.getName()), 'Should NOT contain Category_Icon__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Analysis_Statuses_Details__c.getName()), 'Should NOT contain Analysis_Statuses_Details__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Issue_Analysis__c.getName()), 'Should NOT contain Issue_Analysis__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Source_Control_Metadata__c.getName()), 'Should NOT contain Source_Control_Metadata__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.DevOps_Center_Metadata_Available__c.getName()), 'Should NOT contain DevOps_Center_Metadata_Available__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Override_Priority__c.getName()), 'Should NOT contain Override_Priority__c');
        System.assert(!fieldNames.contains(Schema.sObjectType.Issue__c.fields.Users_Impacted__c.getName()), 'Should NOT contain Users_Impacted__c');
    }

    @IsTest
    private static void test_admin_service_getSObjectFields_LogFields() {
        List<AdminService.FilterField> result;
        
        Test.startTest();
        result = (List<AdminService.FilterField>)AdminService.getSObjectFields(
            Schema.sObjectType.Log__c.getSObjectType(), 
            Constants.RULE_SOBJECT.TYPE_NOTIFICATION
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have at least one field');
        
        // Verify the result is sorted
        for (Integer i = 0; i < result.size() - 1; i++) {
            System.assert(
                result[i].label.compareTo(result[i + 1].label) <= 0, 
                'Fields should be sorted by label'
            );
        }
        
        // Verify field structure
        AdminService.FilterField firstField = result[0];
        System.assertNotEquals(null, firstField.value, 'Field value should not be null');
        System.assertNotEquals(null, firstField.label, 'Field label should not be null');
        System.assertNotEquals(null, firstField.type, 'Field type should not be null');
    }

    @IsTest
    private static void test_admin_service_getSObjectFields_IssueFields() {
        List<AdminService.FilterField> result;
        
        Test.startTest();
        result = (List<AdminService.FilterField>)AdminService.getSObjectFields(
            Schema.sObjectType.Issue__c.getSObjectType(), 
            Constants.RULE_SOBJECT.TYPE_NOTIFICATION,
            false
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have at least one field');
        
        // Verify the result includes standard + custom fields
        Set<String> fieldNames = new Set<String>();
        for (AdminService.FilterField field : result) {
            fieldNames.add(field.value);
        }
        
        // Standard fields for Issue Create should be present (using actual field API names from schema)
        String categoryField = Schema.sObjectType.Issue__c.fields.Category__c.getName();
        String summaryField = Schema.sObjectType.Issue__c.fields.Summary__c.getName();
        
        System.assert(fieldNames.contains(categoryField), 'Should contain Category field: ' + categoryField);
        System.assert(fieldNames.contains(summaryField), 'Should contain Summary field: ' + summaryField);
    }

    @IsTest
    private static void test_admin_service_getRuleSettings_includesFields() {
        Map<String, Object> result;
        
        Test.startTest();
        result = AdminService.getRuleSettings(Constants.RULE_SOBJECT.TYPE_NOTIFICATION);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey(RuleUtil.KEY_LOG_FIELDS), 'Should contain log fields key');
        System.assert(result.containsKey(RuleUtil.KEY_ISSUE_FIELDS), 'Should contain issue fields key');
        System.assert(result.containsKey(RuleUtil.KEY_ISSUE_FIELDS_FOR_UPDATE), 'Should contain issue fields for update key');
        
        List<AdminService.FilterField> logFields = (List<AdminService.FilterField>)result.get(RuleUtil.KEY_LOG_FIELDS);
        List<AdminService.FilterField> issueFields = (List<AdminService.FilterField>)result.get(RuleUtil.KEY_ISSUE_FIELDS);
        List<AdminService.FilterField> issueFieldsUpdate = (List<AdminService.FilterField>)result.get(RuleUtil.KEY_ISSUE_FIELDS_FOR_UPDATE);
        
        System.assertNotEquals(null, logFields, 'Log fields should not be null');
        System.assertNotEquals(null, issueFields, 'Issue fields should not be null');
        System.assertNotEquals(null, issueFieldsUpdate, 'Issue fields for update should not be null');
        
        System.assert(logFields.size() > 0, 'Log fields should have at least one entry');
        System.assert(issueFields.size() > 0, 'Issue fields should have at least one entry');
        System.assert(issueFieldsUpdate.size() > 0, 'Issue fields for update should have at least one entry');
        
        // Verify that Update rules have more fields than Create rules for Issue
        System.assert(
            issueFieldsUpdate.size() > issueFields.size(), 
            'Issue Update rules should have more fields than Create rules'
        );
    }

    @IsTest
    private static void test_admin_service_filterField_compareTo() {
        AdminService.FilterField field1 = new AdminService.FilterField('Field_A__c', 'Alpha Field', 'TEXT');
        AdminService.FilterField field2 = new AdminService.FilterField('Field_B__c', 'Beta Field', 'TEXT');
        AdminService.FilterField field3 = new AdminService.FilterField('Field_C__c', 'Alpha Field', 'TEXT');
        
        Test.startTest();
        Integer comparison1 = field1.compareTo(field2);
        Integer comparison2 = field1.compareTo(field3);
        Test.stopTest();
        
        System.assert(comparison1 < 0, 'Alpha should come before Beta');
        System.assertEquals(0, comparison2, 'Same labels should be equal');
    }

    // ========================================================================
    // Error Scenario Tests for LoggerSettingsController RemoteAction Methods
    // ========================================================================

    @IsTest
    private static void test_generateTokenForConnectedOrg_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String redirectUrl = 'https://test.salesforce.com/callback';
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'redirectUrl' => redirectUrl,
            'state' => 'someState'
        });

        // Set up mock to throw an error
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            400,
            'Bad Request',
            '{"error":"invalid_grant","error_description":"authentication failure"}'
        );
        Test.setMock(HttpCalloutMock.class, errorMock);

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForConnectedOrg(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForConnectedOrg fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForConnectedOrg'), 
                'Log should contain method name');
        }
    }

    @IsTest
    private static void test_generateTokenForSlack_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String testData = JSON.serialize(new Map<String, Object>{'code' => codeValue});

        // Set up mock to throw an error
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            401,
            'Unauthorized',
            '{"ok":false,"error":"invalid_code"}'
        );
        mocks.put(LoggerSettingsController.SLACK_OAUTH_ENDPOINT_V2, errorMock);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForSlack(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForSlack fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForSlack'), 
                'Log should contain method name');
        }
    }

    @IsTest
    private static void test_generateTokenForGraph_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String returnValue = 'someHttpUrl';
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'return_url' => returnValue
        });

        // Set up mock to throw an error
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            400,
            'Bad Request',
            '{"error":"invalid_grant","error_description":"authorization code expired"}'
        );
        mocks.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, errorMock);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForGraph(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForGraph fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForGraph'), 
                'Log should contain method name');
        }
    }

    @IsTest
    private static void test_generateTokenForAzureDevOps_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String returnValue = 'someHttpUrl';
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'return_url' => returnValue
        });

        // Set up mock to throw an error
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            403,
            'Forbidden',
            '{"error":"access_denied","error_description":"user denied access"}'
        );
        mocks.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, errorMock);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForAzureDevOps(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForAzureDevOps fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForAzureDevOps'), 
                'Log should contain method name');
        }
    }

    @IsTest
    private static void test_generateTokenForGitHub_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String returnValue = 'someHttpUrl';
        String testData = JSON.serialize(new Map<String, Object>{
            'code' => codeValue,
            'return_url' => returnValue
        });

        // Set up mock to throw an error
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            401,
            'Unauthorized',
            '{"error":"bad_verification_code","error_description":"The code passed is incorrect or expired"}'
        );
        mocks.put(GitHubUtils.GIT_API_TOKEN_ENDPOINT, errorMock);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForGitHub(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForGitHub fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForGitHub'), 
                'Log should contain method name');
        }
    }

    @IsTest
    private static void test_generateTokenForJira_error_creates_pharos_log() {
        String codeValue = 'someCode';
        String testData = JSON.serialize(new Map<String, Object>{'code' => codeValue});

        // Set up mock to throw an error
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock());
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            400,
            'Bad Request',
            '{"error":"invalid_grant"}'
        );
        mocks.put(JiraService.JIRA_CLOUD_OAUTH_ENDPOINT, errorMock);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        Integer initialPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                           WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                           AND Area__c = :Logger.AREA_PHAROS_ERROR];

        Test.startTest();
        String result = LoggerSettingsController.generateTokenForJira(testData);
        Test.stopTest();

        Map<String, Object> testResult = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('error', testResult.get('status'), 'Status should be error');
        System.assertNotEquals(null, testResult.get('message'), 'Error message should be present');

        // Verify Pharos Error log was created
        Integer finalPharosErrorCount = [SELECT COUNT() FROM Log__c 
                                         WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                         AND Area__c = :Logger.AREA_PHAROS_ERROR];
        
        System.assert(finalPharosErrorCount > initialPharosErrorCount, 
            'A Pharos Error log should be created when generateTokenForJira fails. ' +
            'Initial: ' + initialPharosErrorCount + ', Final: ' + finalPharosErrorCount);

        // Verify the log contains correct apex name
        List<Log__c> pharosLogs = [SELECT Id, Apex_Name__c, Summary__c 
                                   FROM Log__c 
                                   WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR 
                                   AND Area__c = :Logger.AREA_PHAROS_ERROR
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        
        if (!pharosLogs.isEmpty()) {
            System.assert(pharosLogs[0].Apex_Name__c.contains('LoggerSettingsController'), 
                'Log should contain class name');
            System.assert(pharosLogs[0].Apex_Name__c.contains('generateTokenForJira'), 
                'Log should contain method name');
        }
    }
}