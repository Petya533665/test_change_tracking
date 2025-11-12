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

    @IsTest
    static void test_isBlurMode_disabled() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        
        Test.startTest();
        Boolean blurMode = IssueChartController.isBlurMode(issues[0].Id);
        Test.stopTest();
        
        Assert.isFalse(blurMode, 'Blur mode should be false when disabled');
    }

    @IsTest
    static void test_isBlurMode_enabled() {
        enableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        
        Test.startTest();
        Boolean blurMode = IssueChartController.isBlurMode(issues[0].Id);
        Test.stopTest();
        
        Assert.isTrue(blurMode, 'Blur mode should be true when enabled');
    }

    @IsTest
    static void test_isDebugLogServiceEnabled() {
        enableDebugLogService();
        Test.startTest();
        Boolean isEnabled = IssueChartController.isDebugLogServiceEnabled();
        Test.stopTest();
        
        Assert.isTrue(isEnabled, 'Debug log service enabled should not be null');
    }

    @IsTest
    static void test_getUrlParameter() {
        Test.startTest();
        String urlParam = IssueChartController.getUrlParameter();
        Test.stopTest();
        
        Assert.isTrue(String.isNotBlank(urlParam), 'URL parameter should not be null');
    }

    @IsTest
    static void test_getReportId_notFound() {
        Test.startTest();
        String reportId = IssueChartController.getReportId('NonExistentReport');
        Test.stopTest();
        
        Assert.areEqual(null, reportId, 'Report ID should be null for non-existent report');
    }

    @IsTest
    static void test_getLogs() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        List<Log__c> logs = IssueChartController.getLogs(issues[0].Id);
        Assert.areEqual(1, logs.size());
    }

    @IsTest
    static void test_getLogs_throwsExceptionForNullRecordId() {
        Exception expectedException;
        
        Test.startTest();
        try {
            IssueChartController.getLogs(null);
        } catch (Exception e) {
            expectedException = e;
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, expectedException, 'Exception should not be null');
        Assert.areEqual(IssueChartController.RECORD_ID_EXCEPTION, expectedException.getMessage(), 'Error message should match');
    }

    @IsTest
    static void test_getTodaysLogsCount() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areEqual(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays User Impact').todaysLogsCount);
        Assert.areEqual(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays Data Impact').todaysLogsCount);
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areEqual(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays User Impact').todaysLogsCount);
        Assert.areEqual(1, IssueChartController.getTodaysLogsCount(issues[0].Id, 'Todays Data Impact').todaysLogsCount);
        Test.stopTest();
    }

    @IsTest
    static void test_getTodaysLogsCount_throwsExceptionForNullRecordId() {
        Exception expectedException;
        
        Test.startTest();
        try {
            IssueChartController.getTodaysLogsCount(null, 'Todays User Impact');
        } catch (Exception e) {
            expectedException = e;
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, expectedException, 'Exception should not be null');
        Assert.areEqual(IssueChartController.RECORD_ID_EXCEPTION, expectedException.getMessage(), 'Error message should match');
    }

    @IsTest
    static void test_getDateRange() {
        disableBlurMode();

        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Test.startTest();
        String result = IssueChartController.getDateRange(issues[0].Id);
        Test.stopTest();

        Assert.areEqual(String.valueOf(ChartService.LAST_7_DAYS_DATE_RANGE), result);
    }

    @IsTest
    static void test_getDateRange_notAvailableDebugView() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areEqual(String.valueOf(ChartService.LAST_7_DAYS_DATE_RANGE), IssueChartController.getDateRange(issues[0].Id));
    }

    @IsTest
    static void test_getChartData_Occurrence() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_OCCURRENCE, ChartService.LAST_30_DAYS_DATE_RANGE));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_OCCURRENCE, ChartService.LAST_30_DAYS_DATE_RANGE));
        Test.stopTest();
    }

    @IsTest
    static void test_getChartData_UserImpactLast30Days() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS, null));
        Test.stopTest();
    }

    @IsTest
    static void test_getChartData_UserImpactLast30DaysDetails() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.stopTest();
    }

    @IsTest
    static void test_getChartData_DataImpactLast30Days() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS, null));
        Test.stopTest();
    }

    @IsTest
    static void test_getChartData_DataImpactLast30DaysDetails() {
        disableBlurMode();
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :SOME_HASH_1_1];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.startTest();
        enableBlurMode();
        createTestData(SOME_HASH_1_2);
        issues = [SELECT Id, Name FROM Issue__c WHERE Key__c = :SOME_HASH_1_2];
        Assert.areNotEqual(null, getChartData(issues[0].Id, ChartService.ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS, null));
        Test.stopTest();
    }

    @IsTest
    static void test_getChartData_withEmptyJSON() {
        List<ChartService.ChartData> result;

        Test.startTest();
        result = IssueChartController.getChartData('');
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Chart Data should not be null');
        Assert.isTrue(result.isEmpty(), 'Chart Data should be empty');
    }

    @IsTest
    static void test_getChartData_withNullJSON() {
        List<ChartService.ChartData> result;

        Test.startTest();
        result = IssueChartController.getChartData(null);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Chart Data should not be null');
        Assert.isTrue(result.isEmpty(), 'Chart Data should be empty');
    }

    @IsTest
    static void test_getChartDataProperties_throwsExceptionForNullRecordId() {
        Exception expectedException;
        
        Test.startTest();
        try {
            IssueChartController.getChartDataProperties(null, 'Some Chart', 30, null);
        } catch (Exception e) {
            expectedException = e;
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, expectedException, 'Exception should not be null');
        Assert.areEqual(IssueChartController.RECORD_ID_EXCEPTION, expectedException.getMessage(), 'Error message should match');
    }

    @IsTest
    static void test_getRelated_withChildAndSiblingIssues() {
        // Create parent issue
        Issue__c parentIssue = new Issue__c();
        parentIssue.Status__c = 'New';
        parentIssue.Key__c = 'parent_hash';
        insert parentIssue;

        // Create sibling issue (related to parent)
        Issue__c siblingIssue = new Issue__c();
        siblingIssue.Status__c = 'New';
        siblingIssue.Key__c = 'sibling_hash';
        siblingIssue.Related_Issue__c = parentIssue.Id;
        insert siblingIssue;

        // Create child issue (pointing to sibling)
        Issue__c childIssue = new Issue__c();
        childIssue.Status__c = 'New';
        childIssue.Key__c = 'child_hash';
        childIssue.Related_Issue__c = siblingIssue.Id;
        insert childIssue;

        Test.startTest();
        List<String> related = IssueChartController.getRelated(siblingIssue.Id);
        Test.stopTest();

        Assert.areNotEqual(null, related, 'Related list should not be null');
        Assert.areEqual(4, related.size(), 'Should have 4 options when both child and sibling exist');
        Assert.isTrue(related.contains('None'), 'Should contain None option');
        Assert.isTrue(related.contains('All'), 'Should contain All option');
        Assert.isTrue(related.contains('Child Issues'), 'Should contain Child Issues option');
        Assert.isTrue(related.contains('Sibling Issues'), 'Should contain Sibling Issues option');
    }

    @IsTest
    static void test_getRelated_withChildIssuesOnly() {
        // Create parent issue
        Issue__c parentIssue = new Issue__c();
        parentIssue.Status__c = 'New';
        parentIssue.Key__c = 'parent_hash_2';
        insert parentIssue;

        // Create child issue
        Issue__c childIssue = new Issue__c();
        childIssue.Status__c = 'New';
        childIssue.Key__c = 'child_hash_2';
        childIssue.Related_Issue__c = parentIssue.Id;
        insert childIssue;

        Test.startTest();
        List<String> related = IssueChartController.getRelated(parentIssue.Id);
        Test.stopTest();

        Assert.areNotEqual(null, related, 'Related list should not be null');
        Assert.areEqual(3, related.size(), 'Should have 3 options when only child exists');
        Assert.isTrue(related.contains('None'), 'Should contain None option');
        Assert.isTrue(related.contains('All'), 'Should contain All option');
        Assert.isTrue(related.contains('Child Issues'), 'Should contain Child Issues option');
        Assert.isFalse(related.contains('Sibling Issues'), 'Should not contain Sibling Issues option');
    }

    @IsTest
    static void test_getRelated_withSiblingIssuesOnly() {
        // Create parent issue
        Issue__c parentIssue = new Issue__c();
        parentIssue.Status__c = 'New';
        parentIssue.Key__c = 'parent_hash_3';
        insert parentIssue;

        // Create sibling issue
        Issue__c siblingIssue = new Issue__c();
        siblingIssue.Status__c = 'New';
        siblingIssue.Key__c = 'sibling_hash_3';
        siblingIssue.Related_Issue__c = parentIssue.Id;
        insert siblingIssue;

        Test.startTest();
        List<String> related = IssueChartController.getRelated(siblingIssue.Id);
        Test.stopTest();

        Assert.areNotEqual(null, related, 'Related list should not be null');
        Assert.areEqual(3, related.size(), 'Should have 3 options when only sibling exists');
        Assert.isTrue(related.contains('None'), 'Should contain None option');
        Assert.isTrue(related.contains('All'), 'Should contain All option');
        Assert.isTrue(related.contains('Sibling Issues'), 'Should contain Sibling Issues option');
        Assert.isFalse(related.contains('Child Issues'), 'Should not contain Child Issues option');
    }

    @IsTest
    static void test_getRelated_noRelatedIssues() {
        // Create standalone issue
        Issue__c standaloneIssue = new Issue__c();
        standaloneIssue.Status__c = 'New';
        standaloneIssue.Key__c = 'standalone_hash';
        insert standaloneIssue;

        Test.startTest();
        List<String> related = IssueChartController.getRelated(standaloneIssue.Id);
        Test.stopTest();

        Assert.areEqual(null, related, 'Related list should be null when no related issues exist');
    }

    private static List<ChartService.ChartData> getChartData(String recordId, String chartName, Integer dateRange) {
        ChartService.ChartDataProperties chartDataProperties = IssueChartController.getChartDataProperties(recordId, chartName, dateRange, null);
        chartDataProperties.requestedCreatedAt = chartDataProperties.mapExistDateByLabel.values()[0];
        return IssueChartController.getChartData(JSON.serialize(chartDataProperties));
    }

    private static void disableBlurMode() {
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

    private static void enableBlurMode() {
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

    private static void enableDebugLogService() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>1, 1=>1,	2=>1,
            3=>1, 4=>1,	5=>1,
            6=>1, 7=>1,	8=>1,
            9=>1, 10=>0, 11=>0,
            12=>1, 13=>0, 14=>0,
            15=>0, 16=>0, 17=>1,
            18=>1, 19=>1, 20=>1,
            21=>0, 22=>0, 23=>0,
            24=>0, 25=>0, 26=>0,
            27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }
}