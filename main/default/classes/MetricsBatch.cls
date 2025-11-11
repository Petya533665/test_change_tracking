public with sharing class MetricsBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private static MetricsBatch instance = null;

    public static MetricsBatch getInstance() {
        if (instance == null) {
            instance = new MetricsBatch(Logger.getInstance());
        }
        return instance;
    }

    private MetricsBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('MetricsBatch', this);
    }

    public override Boolean initialValidation() {
        // run once per 24h
        Time currentTime = Datetime.now().time();
        Time time1am = Time.newInstance(1, 0, 0, 0);
        Time time2am = Time.newInstance(2, 0, 0, 0);
        Boolean isCurrentTimeBetween1amAnd2am = Test.isRunningTest() ? true : (currentTime >= time1am && currentTime <= time2am);
        return isCurrentTimeBetween1amAnd2am;
    }

    public override Integer getIterationsCount() {
        // "-3" - Decreasing count by 3 to reserve slots for batch start and execute and finish in async apex executions.
        return 3;
    }

    public Iterable<String> start(Database.BatchableContext BC) {
        return new List<String>{'BatchIteration'};
    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
        calculateOrgMetrics();
        calculateOrgMetrics2();
        calculateOrgMetrics3();
        calculateOrgMetrics4();
        // Analytics
        calculateOrgMetrics5();
        calculateOrgMetrics6();
    }

    public void finish(Database.BatchableContext BC) {}

    public static void calculateOrgMetrics5() {
        AnalyticsService analyticsService = AnalyticsService.getInstance();
        AnalyticsService.AnalyticsMetrics metrics = analyticsService.calculateMetrics();
        Integer firstMetric = metrics.firstMetric.intValue();
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_9_NAME, firstMetric);
    }

    public static void calculateOrgMetrics6() {
        AnalyticsService analyticsService = AnalyticsService.getInstance();
        AnalyticsService.AnalyticsMetrics metrics = analyticsService.calculateMetrics();
        Integer secondMetric = metrics.secondMetric.intValue();
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_11_NAME, secondMetric);
    }

    public static final Integer START_BIT_OF_CONNECTED_ORG_COUNT = 0; // 7bit
    public static final Integer START_BIT_OF_PLATFORM_EVENT_CONFIGURED = 7; //1bit
    public static final Integer START_BIT_OF_COUNT_INTEGRATION_LOGS = 8; //2bit
    public static final Integer START_BIT_OF_APEX_TRACKING_ENABLED = 10; //1bit
    public static final Integer START_BIT_OF_EMAIL_TO_CASE_ENABLED = 11; //1bit
    public static final Integer START_BIT_OF_AUTOMATED_FLOW_TRACKING_ENABLED = 12; //1bit
    public static final Integer START_BIT_OF_COUNT_MONITORING_RULES = 13; //3bit
    public static final Integer START_BIT_OF_COUNT_NOTIFICATION_RULES = 16; //3bit
    public static final Integer START_BIT_OF_COUNT_ARCHIVAL_RULES = 19; //2bit
    public static final Integer START_BIT_OF_COUNT_BROADCAST_RULES = 21; //2bit
    public static final Integer START_BIT_OF_BATCH_ERROR_TRACKING_ENABLED = 23; //1bit
    public static final Integer START_BIT_OF_BULK_API_ERROR_TRACKING_ENABLED = 24; //1bit
    public static final Integer START_BIT_OF_TEAMS_INTEGRATION_ENABLED = 25; //1bit
    public static final Integer START_BIT_OF_GIT_HUB_INTEGRATION_ENABLED = 26; //1bit
    public static final Integer START_BIT_OF_CHANGE_TRACKING_ENABLED = 27; //1bit
    public static final Integer START_BIT_OF_API_CALLS_COMPLETED = 28; //1bit

    public class APISettings {
        public Boolean platformEventConfigured;
        public Boolean isApexTrackingEnabled;
        public Boolean emailToCaseEnabled;
        public Boolean automatedFlowTrackingEnabled;
        public Boolean isApiCallsCompleted;

        public APISettings() {
            this.platformEventConfigured = false;
            this.isApexTrackingEnabled = false;
            this.emailToCaseEnabled = false;
            this.automatedFlowTrackingEnabled = false;
            this.isApiCallsCompleted = true;
        }

        public APISettings getApiSettings() {
            try {
                PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper pescw = 
                    new PlatformEventSubscriberConfigService(Log_Event__e.SObjectType).getPlatformEventSubscriberConfig(true);
                this.platformEventConfigured = pescw != null && pescw.Id != null;
                List<EmailServicesFunction> availableEmailServices = new EmailServicesSelector().getPackageEmailServicesFunctions();
                this.isApexTrackingEnabled = (!availableEmailServices.isEmpty() && availableEmailServices.get(0).IsActive);
                this.emailToCaseEnabled = AdminService.getEmailToCaseErrorTracking();
                this.automatedFlowTrackingEnabled = AdminService.getAutomatedFlowErrorTracking();
            }
            catch(Exception e) {
                this.isApiCallsCompleted = false;
            }
            return this;
        }
    }

    public static final Integer START_BIT_OF_NUMBER_OF_ACTIVE_SFDC_USERS = 0; // 14bit
    public static final Integer START_BIT_OF_NUMBER_OF_NON_LOGIN_LICENSES = 14; // 14bit
    public static final Integer START_BIT_OF_NUMBER_OF_COMMUNITY_LOGINS_LAST_MONTHS = 0; // 29bit


    public static void calculateOrgMetrics3() {
        Map<Integer, Integer> result = new Map<Integer, Integer>();

        Integer countActiveSFDCUsers = [
            SELECT COUNT() 
            FROM User 
            WHERE Profile.UserLicense.LicenseDefinitionKey = 'SFDC'
                AND isActive = true
        ];
        Integer countNonLoginLicenses = [
            SELECT COUNT() 
            FROM UserLicense 
            WHERE LicenseDefinitionKey = 'PID_Customer_Community'
                AND Status = 'Active'
        ];

        addBits(START_BIT_OF_NUMBER_OF_ACTIVE_SFDC_USERS, countActiveSFDCUsers, result, 14);
        addBits(START_BIT_OF_NUMBER_OF_NON_LOGIN_LICENSES, countNonLoginLicenses, result, 14);

        Integer resultIntValue = PermissionsUtil.getIntegerFromBitmap(result);
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_7_NAME, resultIntValue);
    }

    public static void calculateOrgMetrics4() {
        Map<Integer, Integer> result = new Map<Integer, Integer>();
        Integer countCommunityLoginsLastMonths = 0;
        for(TenantUsageEntitlement entitlement : [
            SELECT AmountUsed,CurrentAmountAllowed,Frequency, UsageDate, MasterLabel 
            FROM TenantUsageEntitlement]) {

            if(entitlement?.MasterLabel == 'Customer Community Logins') {
                countCommunityLoginsLastMonths = (entitlement.AmountUsed != null) 
                    ? Integer.valueOf(entitlement.AmountUsed)
                    : 0;
            }
        }

        addBits(START_BIT_OF_NUMBER_OF_COMMUNITY_LOGINS_LAST_MONTHS, countCommunityLoginsLastMonths, result, 29);
        
        Integer resultIntValue = PermissionsUtil.getIntegerFromBitmap(result);
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_8_NAME, resultIntValue);
    }

    public static void calculateOrgMetrics2() {
        Map<Integer, Integer> result = new Map<Integer, Integer>();

        APISettings apiSettings = new APISettings().getApiSettings();

        Integer countConnectedOrgs = ConnectedOrgService.getConnectedOrgsList().size();
        countConnectedOrgs = countConnectedOrgs >= 127 ? 127 : countConnectedOrgs;
        add7Bits(START_BIT_OF_CONNECTED_ORG_COUNT, countConnectedOrgs, result);

        result.put(START_BIT_OF_PLATFORM_EVENT_CONFIGURED, apiSettings.platformEventConfigured ? 1 : 0);

        Integer countErrors = getCountLogsByCategory('Integration');
        add2Bits(START_BIT_OF_COUNT_INTEGRATION_LOGS, countErrors, result);

        result.put(START_BIT_OF_APEX_TRACKING_ENABLED, apiSettings.isApexTrackingEnabled ? 1 : 0);
        result.put(START_BIT_OF_EMAIL_TO_CASE_ENABLED, apiSettings.emailToCaseEnabled ? 1 : 0);
        result.put(START_BIT_OF_AUTOMATED_FLOW_TRACKING_ENABLED, apiSettings.automatedFlowTrackingEnabled ? 1 : 0);

        Integer countMonitoringRule = getCountRulesByType(Constants.RULE_SOBJECT.TYPE_MONITORING, 7);
        add3Bits(START_BIT_OF_COUNT_MONITORING_RULES, countMonitoringRule, result);
        Integer countNotificationRule = getCountRulesByType(Constants.RULE_SOBJECT.TYPE_NOTIFICATION, 3);
        add3Bits(START_BIT_OF_COUNT_NOTIFICATION_RULES, countNotificationRule, result);
        Integer countArchivalRule = getCountRulesByType(Constants.RULE_SOBJECT.TYPE_ARCHIVAL, 3);
        add2Bits(START_BIT_OF_COUNT_ARCHIVAL_RULES, countArchivalRule, result);
        Integer countBroadcastRule = getCountRulesByType(Constants.RULE_SOBJECT.TYPE_BROADCAST, 3);
        add2Bits(START_BIT_OF_COUNT_BROADCAST_RULES, countBroadcastRule, result);

        Boolean batchErrorTrackingEnabled = ConfigUtil.SETTINGS.Batch_Error_Tracking_Enabled__c;
        result.put(START_BIT_OF_BATCH_ERROR_TRACKING_ENABLED, batchErrorTrackingEnabled ? 1 : 0);
        Boolean bulkAPIErrorTrackingEnabled = isBulkAPIBatchScheduled();
        result.put(START_BIT_OF_BULK_API_ERROR_TRACKING_ENABLED, bulkAPIErrorTrackingEnabled ? 1 : 0);
        Boolean teamsIntegrationEnabled = ConfigUtil.GRAPH_API_SETTINGS.Enabled__c && String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c);
        result.put(START_BIT_OF_TEAMS_INTEGRATION_ENABLED, teamsIntegrationEnabled ? 1 : 0);
        Boolean gitHubIntegrationEnabled = ConfigUtil.GIT_API_SETTINGS.Enabled__c;
        result.put(START_BIT_OF_GIT_HUB_INTEGRATION_ENABLED, gitHubIntegrationEnabled ? 1 : 0);
        Boolean changeTrackingEnabled = ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c;
        result.put(START_BIT_OF_CHANGE_TRACKING_ENABLED, changeTrackingEnabled ? 1 : 0);

        result.put(START_BIT_OF_API_CALLS_COMPLETED, apiSettings.isApiCallsCompleted ? 1 : 0);

        Integer resultIntValue = PermissionsUtil.getIntegerFromBitmap(result);
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_6_NAME, resultIntValue);
    }

    public static final Integer START_BIT_OF_BASIC_SETUP_COMPLETED = 0; // 1bit
    public static final Integer START_BIT_OF_MESSENGER_SETUP_COMPLETED = 1; //1bit
    public static final Integer START_BIT_OF_SLACK_ENABLED = 2; //1bit
    public static final Integer START_BIT_OF_JIRA_ENABLED = 3; //1bit
    public static final Integer START_BIT_OF_SPLUNK_ENABLED = 4; //1bit
    public static final Integer START_BIT_OF_PAGER_DUTY_ENABLED = 5; //1bit
    public static final Integer START_BIT_OF_COUNT_ERROR_LOGS = 6; //2bit
    public static final Integer START_BIT_OF_COUNT_WARNING_LOGS = 8; //2bit
    public static final Integer START_BIT_OF_COUNT_DEBUG_LOGS = 10; //2bit
    public static final Integer START_BIT_OF_COUNT_EVENT_LOGS = 12; //2bit
    public static final Integer START_BIT_OF_COUNT_APEX_LOGS = 14; //2bit
    public static final Integer START_BIT_OF_COUNT_PB_LOGS = 16; //2bit
    public static final Integer START_BIT_OF_COUNT_FLOW_LOGS = 18; //2bit
    public static final Integer START_BIT_OF_COUNT_EMAIL_TO_CASE_LOGS = 20; //2bit
    public static final Integer START_BIT_OF_COUNT_WEB_TO_CASE_WEB_TO_LEAD_LOGS = 22; //2bit
    public static final Integer START_BIT_OF_COUNT_ALL_LOGS = 24; //3bit
    public static final Integer START_BIT_OF_COUNT_ALL_BULK_LOGS = 27; //2bit

    @TestVisible
    private static void calculateOrgMetrics() {
        Map<Integer, Integer> result = new Map<Integer, Integer>();

        Boolean isBasicSetupCompleted = AdminService.isRemoteSiteSettingsSetupCompleted()
            && AdminService.isEmailServiceFunctionSetupCompleted()
            && AdminService.isConnectionOrgsSetupCompleted();

        Boolean isMessengerSetupCompleted = isMessengerSetupCompleted();
        result.put(START_BIT_OF_BASIC_SETUP_COMPLETED, isBasicSetupCompleted ? 1 : 0);
        result.put(START_BIT_OF_MESSENGER_SETUP_COMPLETED, isMessengerSetupCompleted ? 1 : 0);

        Boolean isSlackIntegrationEnabled = (String.isNotBlank(ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c) && ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c && PermissionsUtil.SlackIntegrationEnabled);
        result.put(START_BIT_OF_SLACK_ENABLED, isSlackIntegrationEnabled ? 1 : 0);
        Boolean isJiraIntegrationEnabled = (String.isNotBlank(JiraService.JIRA_OAUTH_TOKEN) && String.isNotBlank(JiraService.JIRA_API_URL) && PermissionsUtil.JiraIntegrationEnabled);
        result.put(START_BIT_OF_JIRA_ENABLED, isJiraIntegrationEnabled ? 1 : 0);
        Boolean isSplunkIntegrationEnabled = (String.isNotBlank(ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c) && ConfigUtil.SPLUNK_SETTINGS.Splunk_Enabled__c && PermissionsUtil.SplunkIntegrationEnabled);
        result.put(START_BIT_OF_SPLUNK_ENABLED, isSplunkIntegrationEnabled ? 1 : 0);
        Boolean isPagerDutyIntegrationEnabled = (String.isNotBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c) && ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c && PermissionsUtil.PagerDutyIntegrationEnabled);
        result.put(START_BIT_OF_PAGER_DUTY_ENABLED, isPagerDutyIntegrationEnabled ? 1 : 0);

        Integer countErrors = getCountLogsByCategory('Error');
        add2Bits(START_BIT_OF_COUNT_ERROR_LOGS, countErrors, result);
        Integer countWarnings = getCountLogsByCategory('Warning');
        add2Bits(START_BIT_OF_COUNT_WARNING_LOGS, countWarnings, result);
        Integer countDebugs = getCountLogsByCategory('Debug');
        add2Bits(START_BIT_OF_COUNT_DEBUG_LOGS, countDebugs, result);
        Integer countEvents = getCountLogsByCategory('Event');
        add2Bits(START_BIT_OF_COUNT_EVENT_LOGS, countEvents, result);
        Integer countApexs = getCountLogsByCategory('Apex');
        add2Bits(START_BIT_OF_COUNT_APEX_LOGS, countApexs, result);
        Integer countPBs = getCountLogsByCategory('Process Builder');
        add2Bits(START_BIT_OF_COUNT_PB_LOGS, countPBs, result);
        Integer countFlows = getCountLogsByCategory('Flow');
        add2Bits(START_BIT_OF_COUNT_FLOW_LOGS, countFlows, result);
        Integer countE2C = getCountLogsByCategory('Email-to-Case');
        add2Bits(START_BIT_OF_COUNT_EMAIL_TO_CASE_LOGS, countE2C, result);
        Integer countW2CandW2L = getCountLogsByCategory(new List<String>{'Web-to-Case', 'Web-to-Lead'});
        add2Bits(START_BIT_OF_COUNT_WEB_TO_CASE_WEB_TO_LEAD_LOGS, countW2CandW2L, result);

        Integer allLogsCount = getAllCountLogs();
        add3Bits(START_BIT_OF_COUNT_ALL_LOGS, allLogsCount, result);

        Integer allBulkLogsCount = getCountBulkLogs();
        add2Bits(START_BIT_OF_COUNT_ALL_BULK_LOGS, allBulkLogsCount, result);

        Integer resultIntValue = PermissionsUtil.getIntegerFromBitmap(result);
        PermissionsUtil.setPackageFeatureInteger(PermissionsUtil.FEATURE_PARAM_MAP_5_NAME, resultIntValue);
    }

    private static void add2Bits(Integer startBitPosition, Integer intValue, Map<Integer, Integer> result) {
        addBits(startBitPosition, intValue, result, 2);
    }

    private static void add3Bits(Integer startBitPosition, Integer intValue, Map<Integer, Integer> result) {
        addBits(startBitPosition, intValue, result, 3);
    }

    private static void add7Bits(Integer startBitPosition, Integer intValue, Map<Integer, Integer> result) {
        addBits(startBitPosition, intValue, result, 7);
    }

    private static void addBits(Integer startBitPosition, Integer intValue, Map<Integer, Integer> result, Integer bits) {
        Map<Integer, Integer> bitsValue = PermissionsUtil.getBitmapFromInteger(intValue);
        for(Integer i = 0; i < bits; i++) {
            result.put(startBitPosition + i, bitsValue.get(i));
        }
    }

    private static final String BULK_API_JOB_DETAIL_NAME = 'Pharos Bulk API';

    private static Boolean isBulkAPIBatchScheduled() {
        return ![SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :BULK_API_JOB_DETAIL_NAME].isEmpty();
    }

    private static Boolean isMessengerSetupCompleted() {
        return (String.isNotBlank(ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c) && ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c && PermissionsUtil.SlackIntegrationEnabled) ||
                (ConfigUtil.GRAPH_API_SETTINGS.Enabled__c && String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c));
    }

    private static Integer getCountBulkLogs() {
        Integer count = [
                SELECT COUNT()
                FROM Log__c
                WHERE Type__c IN (:BulkAPIJobBatchService.TYPE_BULK_API_V1,:BulkAPIJobBatchService.TYPE_BULK_API_V2)
        ];
        return get2BitCount(count);
    }

    private static Integer getCountLogsByCategory(List<String> logCategories) {
        Integer count = [SELECT COUNT() FROM Log__c WHERE Category__c IN :logCategories];
        return get2BitCount(count);
    }

    private static Integer getCountLogsByCategory(String logCategory) {
        Integer count = [SELECT COUNT() FROM Log__c WHERE Category__c = :logCategory];
        return get2BitCount(count);
    }

    public static Integer getCountRulesByType(String ruleType, Integer countLimit) {
        Integer count = [SELECT COUNT() FROM Rule__c WHERE Type__c = :ruleType];
        return count >= countLimit ? countLimit : count;
    }

    private static Integer getAllCountLogs() {
        Integer count = [SELECT COUNT() FROM Log__c];
        return get3bitCount(count);
    }

    private static Integer get2BitCount(Integer count) {
        if(count == 0) {
            return 0;
        }
        else if(count > 1 && count <= 10) {
            return 1;
        }
        else if(count > 10 && count <= 100) {
            return 2;
        }
        else if(count > 100) {
            return 3;
        }
        return count;
    }

    private static Integer get3BitCount(Integer count) {
        if(count == 0) {
            return 0;
        }
        else if(count <= 10) {
            return 1;
        }
        else if(count > 10 && count <= 100) {
            return 2;
        }
        else if(count > 100 && count <= 1000) {
            return 3;
        }
        else if(count > 1000 && count <= 5000) {
            return 4;
        }
        else if(count > 5000 && count <= 10000) {
            return 5;
        }
        else if(count > 10000 && count <= 20000) {
            return 6;
        }
        else if(count > 20000) {
            return 7;
        }
        return count;
    }
}