@IsTest
public class HoltwintersForecastControllerTest {

    private static Pharos_Settings__c createPharosSettings(Boolean enableForecast) {
        Pharos_Settings__c settings = Pharos_Settings__c.getOrgDefaults();
        if (settings == null) {
            settings = new Pharos_Settings__c();
        }
        settings.EnableForecast__c = enableForecast;
        return settings;
    }

    @IsTest
    static void test_getForecastSetting_WhenEnabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        // When
        String result = HoltwintersForecastController.getForecastSetting();
        
        // Then
        Map<String, Object> forecastSetting = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(true, forecastSetting.get('isEnabledForecast'), 'Forecast should be enabled');
    }

    @IsTest
    static void test_getForecastSetting_WhenDisabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When
        String result = HoltwintersForecastController.getForecastSetting();
        
        // Then
        Map<String, Object> forecastSetting = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(false, forecastSetting.get('isEnabledForecast'), 'Forecast should be disabled');
    }

    @IsTest
    static void test_updateForecastSetting_EnableForecast() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => true
        };
        String forecastSettingJSON = JSON.serialize(forecastSetting);
        
        // Mock HTTP callouts for metadata API and remote site settings
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(mocks));
        Test.setMock(WebServiceMock.class, new HoltwintersForecastWebServiceMock());
        
        // When
        Test.startTest();
        String result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(true, updatedForecastSetting.get('isEnabledForecast'), 'Forecast should be enabled');
        System.assertEquals(true, updatedForecastSetting.get('isUpdate'), 'Update flag should be true');
        
        // Verify database was updated
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(true, updatedSettings.EnableForecast__c, 'Database should reflect the updated setting');
    }

    @IsTest
    static void test_updateForecastSetting_DisableForecast() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(true);
        upsert settings;
        
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => false
        };
        String forecastSettingJSON = JSON.serialize(forecastSetting);
        
        // Mock HTTP callouts for metadata API and remote site settings
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(mocks));
        Test.setMock(WebServiceMock.class, new HoltwintersForecastWebServiceMock());
        
        // When
        Test.startTest();
        String result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(false, updatedForecastSetting.get('isEnabledForecast'), 'Forecast should be disabled');
        System.assertEquals(true, updatedForecastSetting.get('isUpdate'), 'Update flag should be true');
        
        // Verify database was updated
        Pharos_Settings__c updatedSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(false, updatedSettings.EnableForecast__c, 'Database should reflect the updated setting');
    }

    @IsTest
    static void test_updateForecastSetting_WithNullSettings() {
        // Given - no settings exist
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => true
        };
        String forecastSettingJSON = JSON.serialize(forecastSetting);
        
        // Mock HTTP callouts for metadata API and remote site settings
        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(mocks));
        Test.setMock(WebServiceMock.class, new HoltwintersForecastWebServiceMock());
        
        // When
        Test.startTest();
        String result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(true, updatedForecastSetting.get('isEnabledForecast'), 'Forecast should be enabled');
        System.assertEquals(true, updatedForecastSetting.get('isUpdate'), 'Update flag should be true');
        
        // Verify database was created
        Pharos_Settings__c createdSettings = Pharos_Settings__c.getOrgDefaults();
        System.assertEquals(true, createdSettings.EnableForecast__c, 'Database should reflect the created setting');
    }

    // Mock class for HTTP callouts - handles multiple endpoints
    private class MultiRequestMock implements HttpCalloutMock {
        Map<String, HttpCalloutMock> requests;
        
        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                return mock.respond(req);
            } else {
                // Default mock for unmatched endpoints
                return new MockHttpCalloutSuccess().respond(req);
            }
        }
    }

    // Mock class for successful HTTP callouts
    private class MockHttpCalloutSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            
            // Check if this is a metadata API call or regular REST call
            if (request.getEndpoint().contains('services/Soap/m/')) {
                // Mock successful metadata API response
                String responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
                    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    '<soapenv:Body>' +
                    '<deployResponse>' +
                    '<result>' +
                    '<done>true</done>' +
                    '<id>0Af000000000001</id>' +
                    '<success>true</success>' +
                    '</result>' +
                    '</deployResponse>' +
                    '</soapenv:Body>' +
                    '</soapenv:Envelope>';
                response.setHeader('Content-Type', 'text/xml');
                response.setBody(responseBody);
            } else {
                // Mock REST API response (for getRemoteSiteSettings)
                // Return an empty object map instead of array
                String responseBody = '{}'; 
                response.setHeader('Content-Type', 'application/json');
                response.setBody(responseBody);
            }
            
            return response;
        }
    }

    // Enhanced WebService mock that handles both upsert and delete metadata operations
    private class HoltwintersForecastWebServiceMock implements WebServiceMock {
        public void doInvoke(
                Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType)
        {
            if (request instanceof MetadataService.upsertMetadata_element) {
                MetadataService.UpsertResult result = new MetadataService.UpsertResult();
                result.success = true;
                MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
                responseElement.result = new MetadataService.UpsertResult[] {result};
                response.put('response_x', responseElement);
            } else if (request instanceof MetadataService.deleteMetadata_element) {
                MetadataService.DeleteResult deleteResult = new MetadataService.DeleteResult();
                deleteResult.success = true;
                MetadataService.deleteMetadataResponse_element responseElement = new MetadataService.deleteMetadataResponse_element();
                responseElement.result = new MetadataService.DeleteResult[] {deleteResult};
                response.put('response_x', responseElement);
            }
        }
    }

    @IsTest
    static void test_getIsEnabledHoltwinters() {
        // Given - setup test data if needed
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getIsEnabledHoltwinters();
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('isEnabledHoltwinters'), 'Result should contain isEnabledHoltwinters key');
        System.assert(result.get('isEnabledHoltwinters') != null, 'isEnabledHoltwinters should not be null');
    }

    @IsTest
    static void test_getLogsCountByDayLargeDataset_WithJsonParameters() {
        // Create test issue and logs
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Large Dataset');
        insert testIssue;

        // Given - JSON parameters with dates
        Map<String, Object> parameters = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDate' => '2024-01-01T00:00:00.000Z',
            'endDate' => '2024-01-31T23:59:59.000Z'
        };
        String parametersJSON = JSON.serialize(parameters);
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
    }

    @IsTest
    static void test_getLogsCountByDayLargeDataset_WithoutDates() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue without Dates');
        insert testIssue;

        // Given - JSON parameters without dates (should use default 90 days)
        Map<String, Object> parameters = new Map<String, Object>{
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
    }

    @IsTest
    static void test_getLogsCountByDayLargeDataset_SimpleDateFormat() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Simple Dates');
        insert testIssue;

        // Given - JSON with simple date format
        Map<String, Object> parameters = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDate' => '2024-01-01 00:00:00',
            'endDate' => '2024-01-31 23:59:59'
        };
        String parametersJSON = JSON.serialize(parameters);
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
    }

    @IsTest
    static void test_getLogsCountByDayLargeDataset_InvalidJson() {
        // Given - invalid JSON (should fallback to simple issue ID)
        String invalidJSON = 'just-an-issue-id';
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getLogsCountByDayLargeDataset(invalidJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
    }

    @IsTest
    static void test_getUserIdToDateTime_WithISODates() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for User DateTime');
        insert testIssue;

        // Given - JSON parameters with ISO dates
        Map<String, Object> parameters = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDatetime' => '2024-01-01T00:00:00.000Z',
            'endDatetime' => '2024-01-31T23:59:59.000Z'
        };
        String parametersJSON = JSON.serialize(parameters);
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getUserIdToDateTime(parametersJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');
    }

    @IsTest
    static void test_getUserIdToDateTime_WithSimpleDates() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Simple DateTime');
        insert testIssue;

        // Given - JSON parameters with simple dates
        Map<String, Object> parameters = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDatetime' => '2024-01-01 00:00:00',
            'endDatetime' => '2024-01-31 23:59:59'
        };
        String parametersJSON = JSON.serialize(parameters);
        
        // When
        Map<String, Object> result = HoltwintersForecastController.getUserIdToDateTime(parametersJSON);
        
        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');
    }

    @IsTest
    static void test_createAutoTraceRequests_Success() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Auto Trace');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Given - valid logs data and parameters
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => '2024-01-15T10:30:00Z'
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => '2024-01-15T14:15:00Z'
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        // Mock HTTP callout for forecast
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccessWithForecast());

        // When
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        // Then
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert(result.containsKey('message'), 'Result should contain message');
    }

    @IsTest
    static void test_createAutoTraceRequests_NoForecastData() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue No Forecast');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create minimal valid logs data to pass validation
        List<HoltwintersForecastLambdaClient.LogEntry> validLogsData = new List<HoltwintersForecastLambdaClient.LogEntry>{
            new HoltwintersForecastLambdaClient.LogEntry('user1', Datetime.now().addDays(-1).format('yyyy-MM-dd HH:mm:ss'))
        };
        String logsDataJson = JSON.serialize(validLogsData);

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => logsDataJson,
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        // Mock HTTP callout with empty forecast (no forecast data returned)
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutEmptyForecast());

        // When
        Test.startTest();
        try {
            Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
            System.assert(false, 'Expected HoltwintersForecastException to be thrown for empty forecast data');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            // Then - verify the expected exception is thrown
            System.assert(e.getMessage().contains('No valid activity forecast data found'), 
                         'Expected exception message about no valid forecast data, but got: ' + e.getMessage());
        }
        Test.stopTest();
    }

    // Enhanced mock class with detailed forecast response for auto trace tests
    private class MockHttpCalloutSuccessWithForecast implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            // Return detailed mock forecast response for auto trace creation
            String responseBody = JSON.serialize(new Map<String, Object>{
                'forecast' => new Map<String, Object>{
                    '2024-07-31' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'time_range' => '08:30-10:30',
                            'startDateTime' => '2024-07-31T08:30:00',
                            'endDateTime' => '2024-07-31T10:30:00',
                            'predicted_activity' => 3.869,
                            'confidence' => 'high',
                            'detected_peak_time' => '09:00',
                            'userId' => 'user1'
                        }
                    }
                },
                'seasonality' => new Map<String, Object>{
                    'type' => 'weekly',
                    'description' => 'Weekly seasonality pattern detected'
                },
                'execution_time_seconds' => 0.456,
                'logs_processed' => 500,
                'users_processed' => 10,
                'total_users' => 15
            });
            
            response.setBody(responseBody);
            return response;
        }
    }

    // Mock class for empty forecast response
    private class MockHttpCalloutEmptyForecast implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            String responseBody = JSON.serialize(new Map<String, Object>{
                'forecast' => new Map<String, Object>(),
                'seasonality' => null,
                'execution_time_seconds' => 0.1,
                'logs_processed' => 0,
                'users_processed' => 0,
                'total_users' => 0
            });
            
            response.setBody(responseBody);
            return response;
        }
    }
}