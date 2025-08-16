@IsTest
public class LogListControllerTest {
    
    private static final String DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    
    @TestSetup
    static void testSetup() {
        createTestLogs();
    }
    
    static void createTestLogs() {
        List<Log__c> testLogs = new List<Log__c>();
        
        String orgId1 = '00D1234567890123';
        String orgId2 = '00D9876543210987';
        
        // Logs for org1
        testLogs.add(createLog('Error', 'Exception', orgId1, 'Test Org 1', DateTime.now().addDays(-1), 'Test User 1', 'Account'));
        testLogs.add(createLog('Warning', 'Validation', orgId1, 'Test Org 1', DateTime.now().addDays(-2), 'Test User 2', 'Contact'));
        testLogs.add(createLog('Debug', 'Info', orgId1, 'Test Org 1', DateTime.now().addDays(-3), 'Test User 3', 'Lead'));
        testLogs.add(createLog('Flow', 'Flow Error', orgId1, 'Test Org 1', DateTime.now().addDays(-4), 'Test User 4', 'Opportunity'));
        
        // Logs for org2
        testLogs.add(createLog('Error', 'Exception', orgId2, 'Test Org 2', DateTime.now().addDays(-1), 'Test User 5', 'Account'));
        testLogs.add(createLog('Apex', 'DML Error', orgId2, 'Test Org 2', DateTime.now().addDays(-2), 'Test User 6', 'Contact'));
        testLogs.add(createLog('Integration', 'API Error', orgId2, 'Test Org 2', DateTime.now().addDays(-3), 'Test User 7', 'Lead'));
        
        insert testLogs;
    }
    
    static Log__c createLog(String category, String type, String orgId, String orgName, DateTime createdAt, String userName, String relatedObjectType) {
        return new Log__c(
            Category__c = category,
            Type__c = type,
            Organization_Id__c = orgId,
            Organization_Name__c = orgName,
            Created_At__c = createdAt,
            User_Name__c = userName,
            Related_Object_Type__c = relatedObjectType,
            Related_Id__c = '0011234567890123',
            Summary__c = 'Test Summary for ' + category + ' ' + type,
            Area__c = 'Test Area',
            Apex_Name__c = 'TestApexClass',
            Flow_API_Name__c = 'Test_Flow_API',
            Issue__c = null,
            Is_Parent__c = false,
            User_Id__c = '0051234567890123'
        );
    }
    
    @IsTest
    static void testGetLogsWithOrgId() {
        Map<String, Object> input = new Map<String, Object>{
            'orgId' => '00D1234567890123',
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(4, result.size(), 'Should return 4 logs for the specified org');
        for (LogListController.LogElement log : result) {
            System.assertNotEquals(null, log.id, 'Log ID should not be null');
            System.assertNotEquals(null, log.category, 'Log category should not be null');
            System.assertNotEquals(null, log.type, 'Log type should not be null');
        }
    }
    
    @IsTest
    static void testGetLogsWithFromToDates() {
        DateTime fromDate = DateTime.now().addDays(-2);
        DateTime toDate = DateTime.now().addDays(-1);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => fromDate.format(DATETIME_FORMAT),
            'to' => toDate.format(DATETIME_FORMAT),
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should only return logs within the date range
        System.assert(result.size() > 0, 'Should return logs within the specified date range');
        for (LogListController.LogElement log : result) {
            System.assert(log.createdAt >= fromDate, 'Log should be after from date');
            System.assert(log.createdAt <= toDate, 'Log should be before to date');
        }
    }
    
    @IsTest
    static void testGetLogsWithCategoryFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('category', 'string', 'equals', 'Error');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should only return Error category logs
        System.assert(result.size() > 0, 'Should return logs with Error category');
        for (LogListController.LogElement log : result) {
            System.assertEquals('Error', log.category, 'All returned logs should have Error category');
        }
    }
    
    @IsTest
    static void testGetLogsWithMultipleFilters() {
        List<Object> filters = new List<Object>();
        
        LogListController.Filter categoryFilter = new LogListController.Filter('category', 'string', 'equals', 'Error,Warning');
        filters.add(categoryFilter);
        
        LogListController.Filter typeFilter = new LogListController.Filter('type', 'string', 'contains', 'Exception');
        filters.add(typeFilter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        System.assert(result.size() > 0, 'Should return logs matching both filters');
        for (LogListController.LogElement log : result) {
            System.assert(log.category == 'Error' || log.category == 'Warning', 'Log should have Error or Warning category');
            System.assert(log.type.contains('Exception'), 'Log type should contain Exception');
        }
    }
    
    @IsTest
    static void testGetLogsWithFlowView() {
        Map<String, Object> input = new Map<String, Object>{
            'view' => 'Flow API Name',
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should only return Flow category logs
        System.assert(result.size() > 0, 'Should return logs with Flow category');
        for (LogListController.LogElement log : result) {
            System.assertEquals('Flow', log.category, 'All returned logs should have Flow category');
        }
    }
    
    @IsTest
    static void testGetLogsWithStringContainsFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('summary', 'string', 'contains', 'Test Summary');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs with summary containing 'Test Summary'
        System.assert(result.size() > 0, 'Should return logs with summary containing Test Summary');
        for (LogListController.LogElement log : result) {
            System.assert(log.summary.contains('Test Summary'), 'All returned logs should contain Test Summary in summary');
        }
    }
    
    @IsTest
    static void testGetLogsWithStringStartsWithFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('summary', 'string', 'starts with', 'Test Summary');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs with summary starting with 'Test Summary'
        System.assert(result.size() > 0, 'Should return logs with summary starting with Test Summary');
        for (LogListController.LogElement log : result) {
            System.assert(log.summary.startsWith('Test Summary'), 'All returned logs should start with Test Summary in summary');
        }
    }
    
    @IsTest
    static void testGetLogsWithStringDoesNotContainFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('summary', 'string', 'does not contain', 'Exception');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs with summary not containing 'Exception'
        System.assert(result.size() > 0, 'Should return logs with summary not containing Exception');
        for (LogListController.LogElement log : result) {
            System.assert(!log.summary.contains('Exception'), 'All returned logs should not contain Exception in summary');
        }
    }
    
    @IsTest
    static void testGetLogsWithDateTimeFilter() {
        DateTime filterDate = DateTime.now().addDays(-2);
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('createdAt', 'datetime', 'greater than', filterDate.format(DATETIME_FORMAT));
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs created after filterDate
        System.assert(result.size() > 0, 'Should return logs created after filter date');
        for (LogListController.LogElement log : result) {
            System.assert(log.createdAt > filterDate, 'All returned logs should be created after filter date');
        }
    }
    
    @IsTest
    static void testGetLogsWithStringNotEqualsFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('category', 'string', 'not equals to', 'Error');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs with category not equal to 'Error'
        System.assert(result.size() > 0, 'Should return logs with category not equal to Error');
        for (LogListController.LogElement log : result) {
            System.assertNotEquals('Error', log.category, 'All returned logs should not have Error category');
        }
    }
    
    @IsTest
    static void testGetLogsWithBooleanEqualsFilter() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('isNew', 'boolean', 'equals', 'false');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters,
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        // Verify results - should return logs where isNew is not true
        System.assert(result.size() > 0, 'Should return logs with isNew not equal to false');
        for (LogListController.LogElement log : result) {
            System.assertNotEquals(false, log.isNew, 'All returned logs should not be marked as new');
        }
    }
    
    @IsTest
    static void testGetLogsPerPeriodByCategoryWithOrgId() {
        Map<String, Object> input = new Map<String, Object>{
            'orgId' => '00D1234567890123',
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT)
        };
        
        Test.startTest();
        LogListController.LogChartDataResponse result = LogListController.getLogsPerPeriodByCategory(input);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.metrics, 'Metrics should not be null');
        System.assertNotEquals(null, result.chartData, 'Chart data should not be null');
        
        System.assertEquals(6, result.metrics.size(), 'Should have 6 metrics');
        
        Integer totalCount = 0;
        for (LogListController.LogChartDataMetric metric : result.metrics) {
            if (metric.name == 'Total') {
                totalCount = metric.value;
                break;
            }
        }
        System.assertEquals(4, totalCount, 'Should have 4 total logs for the specified org');
    }
    
    @IsTest
    static void testGetLogsPerPeriodByCategoryWithFromToDates() {
        DateTime fromDate = DateTime.now().addDays(-2);
        DateTime toDate = DateTime.now().addDays(-1);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => fromDate.format(DATETIME_FORMAT),
            'to' => toDate.format(DATETIME_FORMAT)
        };
        
        Test.startTest();
        LogListController.LogChartDataResponse result = LogListController.getLogsPerPeriodByCategory(input);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.metrics, 'Metrics should not be null');
        System.assertNotEquals(null, result.chartData, 'Chart data should not be null');
        
        Integer totalCount = 0;
        for (LogListController.LogChartDataMetric metric : result.metrics) {
            if (metric.name == 'Total') {
                totalCount = metric.value;
                break;
            }
        }
        System.assert(totalCount > 0, 'Should have logs within the specified date range');
    }
    
    @IsTest
    static void testGetLogsPerPeriodByCategoryWithFilters() {
        List<Object> filters = new List<Object>();
        LogListController.Filter filter = new LogListController.Filter('category', 'string', 'equals', 'Error');
        filters.add(filter);
        
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'filters' => filters
        };
        
        Test.startTest();
        LogListController.LogChartDataResponse result = LogListController.getLogsPerPeriodByCategory(input);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.metrics, 'Metrics should not be null');
        System.assertNotEquals(null, result.chartData, 'Chart data should not be null');
        
        Integer totalCount = 0;
        for (LogListController.LogChartDataMetric metric : result.metrics) {
            if (metric.name == 'Total') {
                totalCount = metric.value;
                break;
            }
        }
        System.assert(totalCount > 0, 'Should have Error category logs');
    }
    
    @IsTest
    static void testGetLogsPerPeriodByCategoryWithFlowView() {
        Map<String, Object> input = new Map<String, Object>{
            'view' => 'Flow API Name',
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT)
        };
        
        Test.startTest();
        LogListController.LogChartDataResponse result = LogListController.getLogsPerPeriodByCategory(input);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.metrics, 'Metrics should not be null');
        System.assertNotEquals(null, result.chartData, 'Chart data should not be null');
        
        Integer totalCount = 0;
        for (LogListController.LogChartDataMetric metric : result.metrics) {
            if (metric.name == 'Total') {
                totalCount = metric.value;
                break;
            }
        }
        System.assert(totalCount > 0, 'Should have Flow category logs');
    }
    
    @IsTest
    static void testGetLogsWithSorting() {
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'sort' => 'name,ASC',
            'limit' => 10
        };
        
        Test.startTest();
        List<LogListController.LogElement> result = LogListController.getLogs(input);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return logs with sorting');
        
        // Verify sorting is working (logs should be ordered by name ASC)
        if (result.size() > 1) {
            for (Integer i = 0; i < result.size() - 1; i++) {
                System.assert(result[i].name <= result[i + 1].name, 'Logs should be sorted by name in ascending order');
            }
        }
    }
    
    @IsTest
    static void testGetLogsWithPagination() {
        Map<String, Object> input = new Map<String, Object>{
            'from' => DateTime.now().addDays(-5).format(DATETIME_FORMAT),
            'to' => DateTime.now().format(DATETIME_FORMAT),
            'limit' => 3
        };
        
        Test.startTest();
        List<LogListController.LogElement> firstResult = LogListController.getLogs(input);
        
        System.assertNotEquals(null, firstResult, 'First result should not be null');
        System.assert(firstResult.size() > 0, 'Should return logs');
        
        if (firstResult.size() > 0) {
            input.put('lastId', firstResult[firstResult.size() - 1].id);
            
            List<LogListController.LogElement> secondResult = LogListController.getLogs(input);
            
            System.assertNotEquals(null, secondResult, 'Second result should not be null');
            System.assert(secondResult.size() > 0, 'Second result should return logs');
            
            // Verify pagination is working - second result should have different logs
            if (secondResult.size() > 0) {
                System.assertNotEquals(firstResult[0].id, secondResult[0].id, 'Pagination should return different logs');
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetOrganizations() {
        Test.startTest();
        List<LogListController.Organization> result = LogListController.getOrganizations();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return organizations');
        
        for (LogListController.Organization org : result) {
            System.assertNotEquals(null, org.id, 'Organization ID should not be null');
            System.assertNotEquals(null, org.name, 'Organization name should not be null');
        }
    }
}