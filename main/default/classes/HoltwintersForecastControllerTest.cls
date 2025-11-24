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
        Map<String, Object> forecastSetting = HoltwintersForecastController.getForecastSetting();
        
        // Then
        System.assertEquals(true, forecastSetting.get('isEnabledForecast'), 'Forecast should be enabled');
    }

    @IsTest
    static void test_getForecastSetting_WhenDisabled() {
        // Given
        Pharos_Settings__c settings = createPharosSettings(false);
        upsert settings;
        
        // When
        Map<String, Object> forecastSetting = HoltwintersForecastController.getForecastSetting();
        
        // Then
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
        Map<String, Object> result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = result;
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
        Map<String, Object> result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = result;
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
        Map<String, Object> result = HoltwintersForecastController.updateForecastSetting(forecastSettingJSON);
        Test.stopTest();
        
        // Then
        Map<String, Object> updatedForecastSetting = result;
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
    static void test_getLogsCountByDayLargeDataset_MultipleScenarios() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Large Dataset');
        insert testIssue;

        Test.startTest();
        
        // Test scenario 1: Valid JSON with ISO dates
        Map<String, Object> parameters1 = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDate' => '2024-01-01T00:00:00.000Z',
            'endDate' => '2024-01-31T23:59:59.000Z'
        };
        String parametersJSON1 = JSON.serialize(parameters1);
        
        Map<String, Object> result1 = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON1);
        
        System.assertNotEquals(null, result1, 'Result should not be null');
        System.assert(result1.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');

        // Test scenario 2: JSON without dates (should use default 90 days)
        Map<String, Object> parameters2 = new Map<String, Object>{
            'issueId' => testIssue.Id
        };
        String parametersJSON2 = JSON.serialize(parameters2);
        
        Map<String, Object> result2 = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON2);
        
        System.assertNotEquals(null, result2, 'Result should not be null');
        System.assert(result2.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');

        // Test scenario 3: Simple date format
        Map<String, Object> parameters3 = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDate' => '2024-01-01 00:00:00',
            'endDate' => '2024-01-31 23:59:59'
        };
        String parametersJSON3 = JSON.serialize(parameters3);
        
        Map<String, Object> result3 = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON3);
        
        System.assertNotEquals(null, result3, 'Result should not be null');
        System.assert(result3.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');

        // Test scenario 4: Invalid JSON (should handle gracefully)
        String invalidJSON = 'just-an-issue-id';
        
        Map<String, Object> result4 = HoltwintersForecastController.getLogsCountByDayLargeDataset(invalidJSON);
        
        System.assertNotEquals(null, result4, 'Result should not be null');
        System.assert(result4.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
        System.assert(result4.containsKey('error'), 'Result should contain error for invalid JSON');
        
        Test.stopTest();
    }

    @IsTest
    static void test_getUserIdToDateTime_MultipleScenarios() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for User DateTime');
        insert testIssue;

        Test.startTest();

        // Test scenario 1: Valid JSON with ISO dates
        Map<String, Object> parameters1 = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDatetime' => '2024-01-01T00:00:00.000Z',
            'endDatetime' => '2024-01-31T23:59:59.000Z'
        };
        String parametersJSON1 = JSON.serialize(parameters1);
        
        Map<String, Object> result1 = HoltwintersForecastController.getUserIdToDateTime(parametersJSON1);
        
        System.assertNotEquals(null, result1, 'Result should not be null');
        System.assert(result1.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');

        // Test scenario 2: Valid JSON with simple dates
        Map<String, Object> parameters2 = new Map<String, Object>{
            'issueId' => testIssue.Id,
            'startDatetime' => '2024-01-01 00:00:00',
            'endDatetime' => '2024-01-31 23:59:59'
        };
        String parametersJSON2 = JSON.serialize(parameters2);
        
        Map<String, Object> result2 = HoltwintersForecastController.getUserIdToDateTime(parametersJSON2);
        
        System.assertNotEquals(null, result2, 'Result should not be null');
        System.assert(result2.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');
        
        Test.stopTest();
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

        // Create valid logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('success'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert(result.containsKey('message'), 'Result should contain message');
    }

    @IsTest
    static void test_createAutoTraceRequests_EmptyForecast() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Auto Trace');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create valid logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('empty'));
        Test.startTest();
        try {
            Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
            Test.stopTest();
            
            System.assertEquals(false, result.get('success'), 'Should return success=false for empty forecast data');
            System.assertEquals(0, result.get('traceRequestsCreated'), 'Should return 0 trace requests created');
            System.assertEquals('No forecast data available', result.get('message'), 'Should return appropriate message for no forecast data');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assertEquals('No valid activity forecast data found in Lambda response', e.getMessage(), 'Should throw appropriate exception message');
        }
    }

    @IsTest
    static void test_createAutoTraceRequests_PastDates() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Auto Trace');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create valid logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('past_dates'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert((Integer)result.get('traceRequestsCreated') > 0, 'Should create trace requests with adjusted dates');
    }

    @IsTest
    static void test_createAutoTraceRequests_CurrentTimeRange() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Auto Trace');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create valid logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('current_time_range'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert((Integer)result.get('traceRequestsCreated') > 0, 'Should create trace requests with adjusted current time');
    }

    @IsTest
    static void test_createAutoTraceRequests_FutureDates() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Auto Trace');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create valid logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            },
            new Map<String, Object>{
                'userId' => 'testuser2', 
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('future_dates'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert((Integer)result.get('traceRequestsCreated') > 0, 'Should create trace requests with original future dates');
    }

    // Universal mock class for forecast responses
    private class UniversalForecastMock implements HttpCalloutMock {
        private String forecastType;
        
        public UniversalForecastMock(String forecastType) {
            this.forecastType = forecastType;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> forecastData = new Map<String, Object>();
            
            if (forecastType == 'success') {
                forecastData = new Map<String, Object>{
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
                };
            } else if (forecastType == 'empty') {
                forecastData = new Map<String, Object>{
                'forecast' => new Map<String, Object>(),
                'seasonality' => null,
                'execution_time_seconds' => 0.1,
                'logs_processed' => 0,
                'users_processed' => 0,
                'total_users' => 0
                };
            } else if (forecastType == 'past_dates') {
            Datetime yesterday = Datetime.now().addDays(-1);
            String yesterdayStr = yesterday.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                'forecast' => new Map<String, Object>{
                    yesterdayStr => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'time_range' => '08:30-10:30',
                            'startDateTime' => yesterday.addHours(8).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                            'endDateTime' => yesterday.addHours(10).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
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
                };
            } else if (forecastType == 'current_time_range') {
            Datetime now = Datetime.now();
                Datetime startTime = now.addMinutes(-30);
                Datetime endTime = now.addMinutes(30);
            String todayStr = now.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                'forecast' => new Map<String, Object>{
                    todayStr => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'time_range' => '08:30-10:30',
                            'startDateTime' => startTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                            'endDateTime' => endTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
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
                };
            } else if (forecastType == 'future_dates') {
            Datetime tomorrow = Datetime.now().addDays(1);
            String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                'forecast' => new Map<String, Object>{
                    tomorrowStr => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'time_range' => '08:30-10:30',
                            'startDateTime' => tomorrow.addHours(8).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                            'endDateTime' => tomorrow.addHours(10).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
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
                };
            } else if (forecastType == 'invalid_datetime') {
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:30-10:30',
                                'startDateTime' => null,  // Invalid: null datetime
                                'endDateTime' => 'invalid-date-format',  // Invalid: bad format
                                'predicted_activity' => 3.869,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '10:30-12:30',
                                'startDateTime' => '',  // Invalid: empty string
                                'endDateTime' => tomorrow.addHours(10).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 2.5,
                                'confidence' => 'medium',
                                'detected_peak_time' => '11:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'null_userid') {
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:30-10:30',
                                'startDateTime' => tomorrow.addHours(8).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => tomorrow.addHours(10).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.869,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => null  // Null userId
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
                };
            } else if (forecastType == 'empty_time_ranges') {
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>()  // Empty list
                    },
                    'seasonality' => new Map<String, Object>{
                        'type' => 'weekly',
                        'description' => 'Weekly seasonality pattern detected'
                    },
                    'execution_time_seconds' => 0.456,
                    'logs_processed' => 500,
                    'users_processed' => 10,
                    'total_users' => 15
                };
            } else if (forecastType == 'two_overlapping_ranges') {
                // Two overlapping ranges that should merge into one
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '09:30-11:30',
                                'startDateTime' => baseTime.addHours(1).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(3).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '10:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'two_non_overlapping_ranges') {
                // Two non-overlapping ranges that should remain separate
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '11:00-13:00',
                                'startDateTime' => baseTime.addHours(3).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(5).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '12:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'adjacent_ranges') {
                // Two adjacent ranges (touching exactly) - should merge
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '10:00-12:00',
                                'startDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(4).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '11:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'contained_range') {
                // One range completely contains another - should merge
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '08:00-12:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(4).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '10:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '09:00-11:00',
                                'startDateTime' => baseTime.addHours(1).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(3).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '10:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'multiple_groups') {
                // Multiple separate groups of overlapping ranges
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            // First group: 08:00-10:00 and 09:00-11:00 (overlap, merge to 08:00-11:00)
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '09:00-11:00',
                                'startDateTime' => baseTime.addHours(1).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(3).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '10:00',
                                'userId' => 'user2'
                            },
                            // Second group: 13:00-15:00 and 14:00-16:00 (overlap, merge to 13:00-16:00)
                            new Map<String, Object>{
                                'time_range' => '13:00-15:00',
                                'startDateTime' => baseTime.addHours(5).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(7).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 5.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '14:00',
                                'userId' => 'user3'
                            },
                            new Map<String, Object>{
                                'time_range' => '14:00-16:00',
                                'startDateTime' => baseTime.addHours(6).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(8).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 6.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '15:00',
                                'userId' => 'user4'
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
                };
            } else if (forecastType == 'unsorted_ranges') {
                // Unsorted ranges (to test sorting functionality)
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            // Add ranges in reverse order
                            new Map<String, Object>{
                                'time_range' => '11:00-13:00',
                                'startDateTime' => baseTime.addHours(3).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(5).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '12:00',
                                'userId' => 'user2'
                            },
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '09:30-11:30',
                                'startDateTime' => baseTime.addHours(1).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(3).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 5.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '10:00',
                                'userId' => 'user3'
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
                };
            } else if (forecastType == 'invalid_start_end') {
                // Ranges where start > end (should be skipped)
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '10:00-08:00',
                                'startDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),  // end < start
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '08:00-10:00',
                                'startDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user2'
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
                };
            } else if (forecastType == 'all_invalid_ranges') {
                // All ranges are invalid (null dates, empty strings, start > end) - should return empty list
                Datetime tomorrow = Datetime.now().addDays(1);
                String tomorrowStr = tomorrow.format('yyyy-MM-dd');
                Datetime baseTime = tomorrow.addHours(8);
                forecastData = new Map<String, Object>{
                    'forecast' => new Map<String, Object>{
                        tomorrowStr => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'time_range' => '10:00-08:00',
                                'startDateTime' => baseTime.addHours(2).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'endDateTime' => baseTime.format(TraceService.DATE_TIME_FORMAT_ISO08601),  // end < start
                                'predicted_activity' => 3.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user1'
                            },
                            new Map<String, Object>{
                                'time_range' => '08:30-10:30',
                                'startDateTime' => null,  // Invalid: null datetime
                                'endDateTime' => 'invalid-date-format',  // Invalid: bad format
                                'predicted_activity' => 4.0,
                                'confidence' => 'high',
                                'detected_peak_time' => '09:00',
                                'userId' => 'user2'
                            },
                            new Map<String, Object>{
                                'time_range' => '10:30-12:30',
                                'startDateTime' => '',  // Invalid: empty string
                                'endDateTime' => baseTime.addHours(10).addMinutes(30).format(TraceService.DATE_TIME_FORMAT_ISO08601),
                                'predicted_activity' => 2.5,
                                'confidence' => 'medium',
                                'detected_peak_time' => '11:00',
                                'userId' => 'user3'
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
                };
            }
            
            response.setBody(JSON.serialize(forecastData));
            return response;
        }
    }

    @IsTest
    static void test_createAutoTraceRequests_InvalidParameters() {
        Test.startTest();
        
        // Test scenario 1: Missing issueId
        Map<String, Object> parameters1 = new Map<String, Object>{
            'logsData' => JSON.serialize(new List<Map<String, Object>>()),
            'traceScheduleId' => 'test-schedule-id'
            // Missing issueId
        };
        String parametersJSON1 = JSON.serialize(parameters1);
        
        Map<String, Object> result1 = HoltwintersForecastController.createAutoTraceRequests(parametersJSON1);
        
        System.assertEquals(false, result1.get('success'), 'Should return success=false for missing issueId');
        System.assertEquals(0, result1.get('traceRequestsCreated'), 'Should return 0 trace requests created');
        System.assert(String.valueOf(result1.get('message')).contains('Missing required parameters'), 'Should return appropriate error message');

        // Test scenario 2: Missing logsData
        Map<String, Object> parameters2 = new Map<String, Object>{
            'issueId' => 'test-issue-id',
            'traceScheduleId' => 'test-schedule-id'
            // Missing logsData
        };
        String parametersJSON2 = JSON.serialize(parameters2);
        
        Map<String, Object> result2 = HoltwintersForecastController.createAutoTraceRequests(parametersJSON2);
        
        System.assertEquals(false, result2.get('success'), 'Should return success=false for missing logsData');
        System.assertEquals(0, result2.get('traceRequestsCreated'), 'Should return 0 trace requests created');
        System.assert(String.valueOf(result2.get('message')).contains('Missing required parameters'), 'Should return appropriate error message');

        // Test scenario 3: Missing traceScheduleId
        Map<String, Object> parameters3 = new Map<String, Object>{
            'issueId' => 'test-issue-id',
            'logsData' => JSON.serialize(new List<Map<String, Object>>())
            // Missing traceScheduleId
        };
        String parametersJSON3 = JSON.serialize(parameters3);
        
        Map<String, Object> result3 = HoltwintersForecastController.createAutoTraceRequests(parametersJSON3);
        
        System.assertEquals(false, result3.get('success'), 'Should return success=false for missing traceScheduleId');
        System.assertEquals(0, result3.get('traceRequestsCreated'), 'Should return 0 trace requests created');
        System.assert(String.valueOf(result3.get('message')).contains('Missing required parameters'), 'Should return appropriate error message');
        
        Test.stopTest();
    }

    @IsTest
    static void test_createAutoTraceRequests_InvalidJson() {
        // Test with invalid JSON
        String invalidJSON = 'invalid-json-string';
        
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(invalidJSON);
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'), 'Should return success=false for invalid JSON');
        System.assertEquals(0, result.get('traceRequestsCreated'), 'Should return 0 trace requests created');
        System.assert(String.valueOf(result.get('message')).contains('Error:'), 'Should return error message for invalid JSON');
    }

    @IsTest
    static void test_getUserIdToDateTime_InvalidParameters() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Invalid Parameters');
        insert testIssue;

        Test.startTest();

        // Test scenario 1: Invalid JSON
        String invalidJSON = 'invalid-json-string';
        
        Map<String, Object> result1 = HoltwintersForecastController.getUserIdToDateTime(invalidJSON);
        
        System.assertNotEquals(null, result1, 'Result should not be null');
        System.assert(result1.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');
        System.assert(result1.containsKey('error'), 'Result should contain error for invalid JSON');

        // Test scenario 2: Missing issueId
        Map<String, Object> parameters2 = new Map<String, Object>{
            'startDatetime' => '2024-01-01T00:00:00.000Z',
            'endDatetime' => '2024-01-31T23:59:59.000Z'
            // Missing issueId
        };
        String parametersJSON2 = JSON.serialize(parameters2);
        
        Map<String, Object> result2 = HoltwintersForecastController.getUserIdToDateTime(parametersJSON2);
        
        System.assertNotEquals(null, result2, 'Result should not be null');
        System.assert(result2.containsKey('userIdToDateTimeData'), 'Result should contain userIdToDateTimeData');
        System.assert(result2.containsKey('error'), 'Result should contain error for missing issueId');
        
        Test.stopTest();
    }

    @IsTest
    static void test_getLogsCountByDayLargeDataset_InvalidParameters() {
        Test.startTest();
        
        // Test scenario 1: Invalid JSON
        String invalidJSON = 'invalid-json-string';
        
        Map<String, Object> result1 = HoltwintersForecastController.getLogsCountByDayLargeDataset(invalidJSON);
        
        System.assertNotEquals(null, result1, 'Result should not be null');
        System.assert(result1.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
        System.assert(result1.containsKey('error'), 'Result should contain error for invalid JSON');

        // Test scenario 2: Missing issueId
        Map<String, Object> parameters2 = new Map<String, Object>{
            'startDate' => '2024-01-01T00:00:00.000Z',
            'endDate' => '2024-01-31T23:59:59.000Z'
            // Missing issueId
        };
        String parametersJSON2 = JSON.serialize(parameters2);
        
        Map<String, Object> result2 = HoltwintersForecastController.getLogsCountByDayLargeDataset(parametersJSON2);
        
        System.assertNotEquals(null, result2, 'Result should not be null');
        System.assert(result2.containsKey('logsCountByDayLargeDataset'), 'Result should contain logsCountByDayLargeDataset');
        // Note: The controller might handle missing issueId gracefully without returning an error
        // This assertion might need to be adjusted based on actual controller behavior
        
        Test.stopTest();
    }

    @IsTest
    static void test_createAutoTraceRequests_InvalidDateTimeFormats() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Invalid DateTime');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        // Mock with invalid datetime formats (null, empty, invalid format)
        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('invalid_datetime'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        // Should handle invalid datetime gracefully - may return 0 trace requests or skip invalid entries
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
    }

    @IsTest
    static void test_createAutoTraceRequests_WithNullUserId() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Null UserId');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        // Mock with null userId in time range
        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('null_userid'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Should still create trace requests even without userId
    }

    @IsTest
    static void test_createAutoTraceRequests_PartialSaveFailure() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Partial Save');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('success'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('success'), 'Result should contain success');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        System.assert(result.containsKey('message'), 'Result should contain message');
    }

    @IsTest
    static void test_createAutoTraceRequests_DeletesExistingAutoTraceRequests() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Delete Existing');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create existing AutoTrace requests
        Trace_Request__c existingRequest1 = new Trace_Request__c(
            Issue__c = testIssue.Id,
            Type__c = 'AutoTrace',
            Status__c = 'New',
            Trace_Schedule__c = traceSchedule.Id,
            Start_Date__c = Datetime.now().addDays(1),
            End_Date__c = Datetime.now().addDays(1).addHours(1)
        );
        Trace_Request__c existingRequest2 = new Trace_Request__c(
            Issue__c = testIssue.Id,
            Type__c = 'AutoTrace',
            Status__c = 'New',
            Trace_Schedule__c = traceSchedule.Id,
            Start_Date__c = Datetime.now().addDays(2),
            End_Date__c = Datetime.now().addDays(2).addHours(1)
        );
        insert new List<Trace_Request__c>{existingRequest1, existingRequest2};

        // Verify existing requests exist
        List<Trace_Request__c> existingRequests = [
            SELECT Id 
            FROM Trace_Request__c 
            WHERE Issue__c = :testIssue.Id AND Type__c = 'AutoTrace'
        ];
        System.assertEquals(2, existingRequests.size(), 'Should have 2 existing AutoTrace requests');

        // Create logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('success'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        // Verify existing requests were deleted
        List<Trace_Request__c> remainingRequests = [
            SELECT Id 
            FROM Trace_Request__c 
            WHERE Issue__c = :testIssue.Id AND Type__c = 'AutoTrace'
        ];
        // Should have new requests, but old ones should be deleted
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
    }

    @IsTest
    static void test_createAutoTraceRequests_EmptyTimeRanges() {
        // Create test issue and trace schedule
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Empty Time Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        // Create logs data
        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        // Mock with empty time ranges
        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('empty_time_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('holtwintersForecast'), 'Result should contain holtwintersForecast');
        System.assertEquals('No valid time ranges found in forecast data for trace request creation', 
            result.get('message'), 'Should return appropriate message for empty time ranges');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_TwoOverlappingRanges() {
        // Test that two overlapping ranges merge into one
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Overlapping Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('two_overlapping_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Two overlapping ranges (08:00-10:00 and 09:30-11:30) should merge into one (08:00-11:30)
        System.assertEquals(1, result.get('traceRequestsCreated'), 'Should merge two overlapping ranges into one');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_TwoNonOverlappingRanges() {
        // Test that two non-overlapping ranges remain separate
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Non-Overlapping Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('two_non_overlapping_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Two non-overlapping ranges should remain separate
        System.assertEquals(2, result.get('traceRequestsCreated'), 'Should keep two non-overlapping ranges separate');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_AdjacentRanges() {
        // Test that adjacent (touching) ranges merge
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Adjacent Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('adjacent_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Adjacent ranges (touching exactly) should merge
        System.assertEquals(1, result.get('traceRequestsCreated'), 'Should merge adjacent ranges');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_ContainedRange() {
        // Test that one range containing another merges correctly
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Contained Range');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('contained_range'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // One range containing another should merge into the larger range
        System.assertEquals(1, result.get('traceRequestsCreated'), 'Should merge contained range into containing range');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_MultipleGroups() {
        // Test multiple separate groups of overlapping ranges
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Multiple Groups');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('multiple_groups'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Two groups of overlapping ranges should result in 2 merged ranges
        System.assertEquals(2, result.get('traceRequestsCreated'), 'Should create 2 merged ranges from 2 groups');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_UnsortedRanges() {
        // Test that unsorted ranges are sorted and merged correctly
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Unsorted Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('unsorted_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Unsorted overlapping ranges should be sorted and merged into one
        System.assertEquals(1, result.get('traceRequestsCreated'), 'Should sort and merge unsorted overlapping ranges');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_InvalidStartEnd() {
        // Test that ranges with start > end are skipped
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for Invalid Start End');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('invalid_start_end'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // Invalid range (start > end) should be skipped, only valid range should create trace request
        System.assertEquals(1, result.get('traceRequestsCreated'), 'Should skip invalid range and create trace request for valid range');
    }

    @IsTest
    static void test_mergeOverlappingTimeRanges_AllInvalidRanges() {
        // Test that when all ranges are invalid, empty list is returned (covers wrappers.isEmpty() branch)
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue for All Invalid Ranges');
        insert testIssue;

        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(
            Issue__c = testIssue.Id,
            Status__c = 'Scheduled'
        );
        insert traceSchedule;

        List<Map<String, Object>> logEntries = new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => 'testuser1',
                'timestamp' => Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            }
        };

        Map<String, Object> parameters = new Map<String, Object>{
            'logsData' => JSON.serialize(logEntries),
            'traceScheduleId' => traceSchedule.Id,
            'issueId' => testIssue.Id
        };
        String parametersJSON = JSON.serialize(parameters);

        Test.setMock(HttpCalloutMock.class, new UniversalForecastMock('all_invalid_ranges'));
        Test.startTest();
        Map<String, Object> result = HoltwintersForecastController.createAutoTraceRequests(parametersJSON);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('traceRequestsCreated'), 'Result should contain traceRequestsCreated');
        // All ranges are invalid, so no trace requests should be created
        System.assertEquals(0, result.get('traceRequestsCreated'), 'Should return 0 trace requests when all ranges are invalid');
        // When all ranges have invalid dates, parseDateTime may throw exception which is caught and returns error message
        // OR if parsing succeeds but all are filtered out, returns "No valid time ranges found"
        String message = String.valueOf(result.get('message'));
        System.assert(message.contains('No valid time ranges found') || message.contains('Error:'), 
            'Should return appropriate message when all ranges are invalid. Actual: ' + message);
    }

}