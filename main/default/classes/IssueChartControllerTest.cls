@IsTest
private class IssueChartControllerTest {

    private static final String SOME_HASH_1_1 = 'somehash1';
    private static final String SOME_HASH_1_2 = 'somehash2';

    @TestSetup
    static void testSetup() {
        createTestData(SOME_HASH_1_1);
    }

    public static void createTestData(String hash_1) {
        Issue__c issue = new Issue__c();
        issue.Status__c = 'New';
        issue.Key__c = hash_1;
        insert issue;

        Log__c log = new Log__c();
        log.Category__c = 'TestCategory';
        log.Type__c = 'TestType' ;
        log.Area__c = 'Apex';
        log.Details__c = 'TestDetails';
        log.User_Id__c = 'TestUserId';
        log.Related_Id__c = 'TestRelatedId';
        log.Issue__c = issue.Id;
        log.Hash_1__c = hash_1;

        Datetime datetimeNow = Datetime.now();
        Datetime currentTime = Datetime.newInstance(datetimeNow.year(), datetimeNow.month(), datetimeNow.day(), datetimeNow.hour(), datetimeNow.minute(), datetimeNow.second());
        Datetime created_at_7_days_ago = currentTime.addDays(-7);
        Datetime created_at_30_days_ago = currentTime.addDays(-30);
        Datetime created_at_60_days_ago = currentTime.addDays(-60);
        Datetime created_at_180_days_ago = currentTime.addDays(-180);

        log.Created_At__c = currentTime;
        Log__c log_7_days_ago = log.clone(); log_7_days_ago.Created_At__c = created_at_7_days_ago;
        Log__c log_30_days_ago = log.clone(); log_30_days_ago.Created_At__c = created_at_30_days_ago;
        Log__c log_60_days_ago = log.clone(); log_60_days_ago.Created_At__c = created_at_60_days_ago;
        Log__c log_180_days_ago = log.clone(); log_180_days_ago.Created_At__c = created_at_180_days_ago;
        List<Log__c> logs = new List<Log__c>{log, log_7_days_ago, log_30_days_ago, log_60_days_ago, log_180_days_ago};
        insert logs;

        issue.Log__c = log.Id;
        update issue;
    }

    public static void disableBlurMode() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>0, 1=>0,	2=>0,
                3=>0, 4=>0,	5=>0,
                6=>0, 7=>0,	8=>0,
                9=>0, 10=>0, 11=>0,
                12=>0, 13=>0, 14=>0,
                15=>0, 16=>0, 17=>0,
                18=>0, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap10IntValue = intValue;
        PermissionsUtil.MaxIssues = intValue;
    }

    public static void enableBlurMode() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>1, 1=>0,	2=>0,
                3=>0, 4=>0,	5=>0,
                6=>0, 7=>0,	8=>0,
                9=>0, 10=>0, 11=>0,
                12=>0, 13=>0, 14=>0,
                15=>0, 16=>0, 17=>0,
                18=>0, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap10IntValue = intValue;
        PermissionsUtil.MaxIssues = intValue;
    }

    @IsTest
    private static void test_getLogs() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        List<Log__c> logs = IssueChartController.getLogs(issues[0].Id);
        System.assertEquals(1, logs.size());
    }

    @IsTest
    private static void test_getTodaysLogsCount() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertEquals(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays User Impact').todaysLogsCount);
        System.assertEquals(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays Data Impact').todaysLogsCount);
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertEquals(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays User Impact').todaysLogsCount);
        System.assertEquals(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays Data Impact').todaysLogsCount);
        Test.stopTest();
    }

    @IsTest
    private static void test_getDateRange() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertEquals('7', IssueChartController.getDateRange(issues[0].Id));
    }

    @IsTest
    private static void test_getChartData_Occurrence() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_OCCURRENCE, ChartService.LAST_30_DAYS_DATE_RANGE));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_OCCURRENCE, ChartService.LAST_30_DAYS_DATE_RANGE));
        Test.stopTest();
    }

    @IsTest
    private static void test_getChartData_UserImpactLast30Days() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS, null));
        Test.stopTest();
    }

    @IsTest
    private static void test_getChartData_UserImpactLast30DaysDetails() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.stopTest();
    }

    @IsTest
    private static void test_getChartData_DataImpactLast30Days() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS, null));
        Test.stopTest();
    }

    @IsTest
    private static void test_getChartData_DataImpactLast30DaysDetails() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        System.assertNotEquals(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.stopTest();
    }

    private static List<ChartService.ChartData> getChartData(String recordId, String chartName, Integer dateRange) {
        ChartService.ChartDataProperties chartDataProperties = IssueChartController.getChartDataProperties(recordId, chartName, dateRange, null);
        chartDataProperties.requestedCreatedAt = chartDataProperties.mapExistDateByLabel.values()[0];
        return IssueChartController.getChartData(JSON.serialize(chartDataProperties));
    }

}