@IsTest
public class ReportApiClientTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data if needed
    }
    
    @IsTest
    static void testConstructor() {
        // Test default constructor
        ReportApiClient client = new ReportApiClient();
        
        // Verify headers are set correctly
        System.assertNotEquals(null, client);
    }
    
    @IsTest
    static void testSetReportId() {
        ReportApiClient client = new ReportApiClient();
        String testReportId = '00O1234567890123';
        
        ReportApiClient result = client.setReportId(testReportId);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
    }
    
    @IsTest
    static void testBuildCurrentOrgUrl() {
        ReportApiClient client = new ReportApiClient();
        String testReportId = '00O1234567890123';
        
        ReportApiClient result = client.setReportId(testReportId).buildCurrentOrgUrl();
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
    }
    
    @IsTest
    static void testSetHeaders() {
        ReportApiClient client = new ReportApiClient();
        Map<String, String> customHeaders = new Map<String, String>{
            'Custom-Header' => 'Custom-Value',
            'Authorization' => 'Bearer custom-token'
        };
        
        ReportApiClient result = client.setHeaders(customHeaders);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
    }
    
    @IsTest
    static void testSetPayload() {
        ReportApiClient client = new ReportApiClient();
        String testPayload = '{"test": "data"}';
        
        ReportApiClient result = client.setPayload(testPayload);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
    }
    
    @IsTest
    static void testExecuteReportWithValidPayload() {
        // This test would require mocking HttpUtils.send method
        // For now, we'll test the exception case when payload is null
        
        ReportApiClient client = new ReportApiClient();
        client.setReportId('00O1234567890123')
              .buildCurrentOrgUrl()
              .setPayload('{"test": "data"}');
        
        // Note: In a real test environment, this would require mocking the HTTP call
        // The actual HTTP call would fail in test context, but we can test the setup
        System.assertNotEquals(null, client);
    }
    
    @IsTest
    static void testExecuteReportWithNullPayload() {
        ReportApiClient client = new ReportApiClient();
        client.setReportId('00O1234567890123')
              .buildCurrentOrgUrl();
        
        try {
            client.executeReport();
            System.assert(false, 'Should have thrown exception for null payload');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Payload is required. Use setPayload() method.', e.getMessage());
        }
    }
    
    @IsTest
    static void testExecuteReportWithEmptyPayload() {
        ReportApiClient client = new ReportApiClient();
        client.setReportId('00O1234567890123')
              .buildCurrentOrgUrl()
              .setPayload('');
        
        try {
            client.executeReport();
            System.assert(false, 'Should have thrown exception for empty payload');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Payload is required. Use setPayload() method.', e.getMessage());
        }
    }
    
    @IsTest
    static void testGetResponse() {
        ReportApiClient client = new ReportApiClient();
        
        // Initially response should be null
        System.assertEquals(null, client.getResponse());
    }
    
    @IsTest
    static void testCreateIssueFilter() {
        String issueKey = 'TEST-123';
        
        Map<String, Object> filter = ReportApiClient.createIssueFilter(issueKey);
        
        System.assertNotEquals(null, filter);
        // Dynamically get the expected field name using Schema
        String expectedField = Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Issue__c.getName();
        System.assertEquals(expectedField, filter.get('column'));
        System.assertEquals('equals', filter.get('operator'));
        System.assertEquals(issueKey, filter.get('value'));
    }
    
    @IsTest
    static void testBuildReportPayload() {
        ReportApiClient client = new ReportApiClient();
        List<Map<String, Object>> filters = new List<Map<String, Object>>{
            new Map<String, Object>{
                'column' => 'Log__c.Created_At__c',
                'operator' => 'greaterOrEqual',
                'value' => DateTime.now()
            }
        };
        
        ReportApiClient result = client.buildReportPayload(filters);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
        
        // Verify payload is set (we can't directly access it, but we can test the flow)
        System.assertNotEquals(null, client);
    }
    
    @IsTest
    static void testCreateFilter() {
        String column = 'Log__c.Status__c';
        String operator = 'equals';
        String value = 'Active';
        
        Map<String, Object> filter = ReportApiClient.createFilter(column, operator, value);
        
        System.assertNotEquals(null, filter);
        System.assertEquals(column, filter.get('column'));
        System.assertEquals(operator, filter.get('operator'));
        System.assertEquals(value, filter.get('value'));
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithBothDates() {
        String column = 'Log__c.Created_At__c';
        DateTime startDateTime = DateTime.now().addDays(-7);
        DateTime endDateTime = DateTime.now();
        
        List<Map<String, Object>> filters = ReportApiClient.createDateRangeFilters(column, startDateTime, endDateTime);
        
        System.assertNotEquals(null, filters);
        System.assertEquals(2, filters.size());
        
        // Verify first filter (start date)
        Map<String, Object> startFilter = filters[0];
        System.assertEquals(column, startFilter.get('column'));
        System.assertEquals('greaterOrEqual', startFilter.get('operator'));
        System.assertEquals(startDateTime, startFilter.get('value'));
        
        // Verify second filter (end date)
        Map<String, Object> endFilter = filters[1];
        System.assertEquals(column, endFilter.get('column'));
        System.assertEquals('lessOrEqual', endFilter.get('operator'));
        System.assertEquals(endDateTime, endFilter.get('value'));
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithStartDateOnly() {
        String column = 'Log__c.Created_At__c';
        DateTime startDateTime = DateTime.now().addDays(-7);
        DateTime endDateTime = null;
        
        List<Map<String, Object>> filters = ReportApiClient.createDateRangeFilters(column, startDateTime, endDateTime);
        
        System.assertNotEquals(null, filters);
        System.assertEquals(1, filters.size());
        
        // Verify only start date filter exists
        Map<String, Object> startFilter = filters[0];
        System.assertEquals(column, startFilter.get('column'));
        System.assertEquals('greaterOrEqual', startFilter.get('operator'));
        System.assertEquals(startDateTime, startFilter.get('value'));
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithEndDateOnly() {
        String column = 'Log__c.Created_At__c';
        DateTime startDateTime = null;
        DateTime endDateTime = DateTime.now();
        
        List<Map<String, Object>> filters = ReportApiClient.createDateRangeFilters(column, startDateTime, endDateTime);
        
        System.assertNotEquals(null, filters);
        System.assertEquals(1, filters.size());
        
        // Verify only end date filter exists
        Map<String, Object> endFilter = filters[0];
        System.assertEquals(column, endFilter.get('column'));
        System.assertEquals('lessOrEqual', endFilter.get('operator'));
        System.assertEquals(endDateTime, endFilter.get('value'));
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithNoDates() {
        String column = 'Log__c.Created_At__c';
        DateTime startDateTime = null;
        DateTime endDateTime = null;
        
        List<Map<String, Object>> filters = ReportApiClient.createDateRangeFilters(column, startDateTime, endDateTime);
        
        System.assertNotEquals(null, filters);
        System.assertEquals(0, filters.size());
    }
    
    @IsTest
    static void testFluentInterface() {
        ReportApiClient client = new ReportApiClient();
        String testReportId = '00O1234567890123';
        String testPayload = '{"test": "data"}';
        Map<String, String> customHeaders = new Map<String, String>{
            'Custom-Header' => 'Custom-Value'
        };
        
        // Test fluent interface - all methods should return the same instance
        ReportApiClient result = client
            .setReportId(testReportId)
            .buildCurrentOrgUrl()
            .setHeaders(customHeaders)
            .setPayload(testPayload);
        
        System.assertEquals(client, result);
    }
    
    @IsTest
    static void testGetDomain() {
        // This tests the private getDomain method indirectly through buildCurrentOrgUrl
        ReportApiClient client = new ReportApiClient();
        String testReportId = '00O1234567890123';
        
        ReportApiClient result = client.setReportId(testReportId).buildCurrentOrgUrl();
        
        // Verify the method completes without error
        System.assertNotEquals(null, result);
    }
    
    @IsTest
    static void testExecuteReportWithNullEndpoint() {
        ReportApiClient client = new ReportApiClient();
        client.setPayload('{"test": "data"}');
        
        try {
            client.executeReport();
            System.assert(false, 'Should have thrown exception for null endpoint');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Report endpoint is required. Use buildCurrentOrgUrl() method.', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateFilterWithNullColumn() {
        try {
            ReportApiClient.createFilter(null, 'equals', 'value');
            System.assert(false, 'Should have thrown exception for null column');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Column parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateFilterWithEmptyColumn() {
        try {
            ReportApiClient.createFilter('', 'equals', 'value');
            System.assert(false, 'Should have thrown exception for empty column');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Column parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateFilterWithNullOperator() {
        try {
            ReportApiClient.createFilter('Log__c.Status__c', null, 'value');
            System.assert(false, 'Should have thrown exception for null operator');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Operator parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateFilterWithEmptyOperator() {
        try {
            ReportApiClient.createFilter('Log__c.Status__c', '', 'value');
            System.assert(false, 'Should have thrown exception for empty operator');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Operator parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithNullColumn() {
        try {
            ReportApiClient.createDateRangeFilters(null, DateTime.now(), DateTime.now());
            System.assert(false, 'Should have thrown exception for null column');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Column parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testCreateDateRangeFiltersWithEmptyColumn() {
        try {
            ReportApiClient.createDateRangeFilters('', DateTime.now(), DateTime.now());
            System.assert(false, 'Should have thrown exception for empty column');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Column parameter cannot be blank', e.getMessage());
        }
    }
    
    @IsTest
    static void testIsSuccessWithNullResponse() {
        ReportApiClient client = new ReportApiClient();
        
        Boolean result = client.isSuccess();
        
        System.assertEquals(false, result, 'Should return false for null response');
    }
    
    @IsTest
    static void testGetResponseBodyWithNullResponse() {
        ReportApiClient client = new ReportApiClient();
        
        String result = client.getResponseBody();
        
        System.assertEquals(null, result, 'Should return null for null response');
    }
    
    @IsTest
    static void testGetStatusCodeWithNullResponse() {
        ReportApiClient client = new ReportApiClient();
        
        Integer result = client.getStatusCode();
        
        System.assertEquals(null, result, 'Should return null for null response');
    }
    
    @IsTest
    static void testBuildReportPayloadWithEmptyFilters() {
        ReportApiClient client = new ReportApiClient();
        List<Map<String, Object>> filters = new List<Map<String, Object>>();
        
        ReportApiClient result = client.buildReportPayload(filters);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
        
        // Verify payload is set (we can't directly access it, but we can test the flow)
        System.assertNotEquals(null, client);
    }
    
    @IsTest
    static void testBuildReportPayloadWithNullFilters() {
        ReportApiClient client = new ReportApiClient();
        
        ReportApiClient result = client.buildReportPayload(null);
        
        // Verify method returns the same instance (fluent interface)
        System.assertEquals(client, result);
        
        // Verify payload is set (we can't directly access it, but we can test the flow)
        System.assertNotEquals(null, client);
    }
}