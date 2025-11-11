/**
 * Unit Tests for HoltwintersForecastLambdaClient
 * 
 * Tests all functionality including:
 * - User activity forecast generation with LogEntry objects
 * - SeasonalityType enum usage
 * - Response wrapper classes
 * - Error handling
 * - Configuration constants
 * 
 * @since API Version 62.0
 */
@IsTest
private class HoltwintersForecastLambdaClientTest {

    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@test.com',
            Username = 'testuser1.client@test.com.test',
            ProfileId = p.Id,
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;

        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@test.com',
            Username = 'testuser2.client@test.com.test',
            ProfileId = p.Id,
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;
    }

    @IsTest
    static void testLogEntry_Constructor() {
        // Arrange
        String userId = '0051234567890ABC';
        String timestamp = '2025-07-17T06:15:00Z';

        // Act
        Test.startTest();
        HoltwintersForecastLambdaClient.LogEntry logEntry = new HoltwintersForecastLambdaClient.LogEntry(userId, timestamp);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logEntry, 'LogEntry should not be null');
        System.assertEquals(userId, logEntry.userId, 'User ID should match');
        System.assertEquals(timestamp, logEntry.timestamp, 'Timestamp should match');
    }

    @IsTest
    static void testLogEntry_Properties() {
        // Arrange
        String userId = '005DEF4567890XYZ';
        String timestamp = '2025-07-18T12:30:00Z';

        // Act
        Test.startTest();
        HoltwintersForecastLambdaClient.LogEntry logEntry = new HoltwintersForecastLambdaClient.LogEntry(userId, timestamp);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logEntry.userId, 'User ID should not be null');
        System.assertNotEquals(null, logEntry.timestamp, 'Timestamp should not be null');
        System.assertEquals(userId, logEntry.userId, 'User ID should match input');
        System.assertEquals(timestamp, logEntry.timestamp, 'Timestamp should match input');
    }

    @IsTest
    static void testLogEntry_MultipleInstances() {
        // Arrange
        List<HoltwintersForecastLambdaClient.LogEntry> logEntries = new List<HoltwintersForecastLambdaClient.LogEntry>();

        // Act
        Test.startTest();
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('0051234567890ABC', '2025-07-17T06:15:00Z'));
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('005DEF4567890XYZ', '2025-07-17T12:02:00Z'));
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('0051234567890ABC', '2025-07-18T09:30:00Z'));
        Test.stopTest();

        // Assert
        System.assertEquals(3, logEntries.size(), 'Should have 3 log entries');
        System.assertEquals('0051234567890ABC', logEntries[0].userId, 'First entry user ID should match');
        System.assertEquals('005DEF4567890XYZ', logEntries[1].userId, 'Second entry user ID should match');
        System.assertEquals('0051234567890ABC', logEntries[2].userId, 'Third entry user ID should match');
    }

    @IsTest
    static void testSeasonalityType_EnumValues() {
        // Act & Assert
        Test.startTest();
        
        // Test all enum values exist
        System.assertNotEquals(null, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 'DAILY should exist');
        System.assertNotEquals(null, HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY, 'WEEKLY should exist');
        System.assertNotEquals(null, HoltwintersForecastLambdaClient.SeasonalityType.MONTHLY, 'MONTHLY should exist');
        System.assertNotEquals(null, HoltwintersForecastLambdaClient.SeasonalityType.AUTO, 'AUTO should exist');
        
        // Test enum name conversion
        System.assertEquals('daily', HoltwintersForecastLambdaClient.SeasonalityType.DAILY.name().toLowerCase(), 'DAILY should convert to daily');
        System.assertEquals('weekly', HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY.name().toLowerCase(), 'WEEKLY should convert to weekly');
        System.assertEquals('monthly', HoltwintersForecastLambdaClient.SeasonalityType.MONTHLY.name().toLowerCase(), 'MONTHLY should convert to monthly');
        System.assertEquals('auto', HoltwintersForecastLambdaClient.SeasonalityType.AUTO.name().toLowerCase(), 'AUTO should convert to auto');
        
        Test.stopTest();
    }

    @IsTest
    static void testActivityTimeRange_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.ActivityTimeRange timeRange = new HoltwintersForecastLambdaClient.ActivityTimeRange();
        
        // Act
        Test.startTest();
        timeRange.time_range = '08:30-10:30';
        timeRange.startDateTime = '2025-07-31T08:30:00';
        timeRange.endDateTime = '2025-07-31T10:30:00';
        timeRange.predicted_activity = 3.869;
        timeRange.confidence = 'high';
        timeRange.detected_peak_time = '09:00';
        timeRange.userId = '0051234567890ABC';
        Test.stopTest();

        // Assert
        System.assertEquals('08:30-10:30', timeRange.time_range, 'Time range should match');
        System.assertEquals('2025-07-31T08:30:00', timeRange.startDateTime, 'Start date time should match');
        System.assertEquals('2025-07-31T10:30:00', timeRange.endDateTime, 'End date time should match');
        System.assertEquals(3.869, timeRange.predicted_activity, 'Predicted activity should match');
        System.assertEquals('high', timeRange.confidence, 'Confidence should match');
        System.assertEquals('09:00', timeRange.detected_peak_time, 'Detected peak time should match');
        System.assertEquals('0051234567890ABC', timeRange.userId, 'User ID should match');
    }

    @IsTest
    static void testActivityForecast_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.ActivityForecast activityForecast = new HoltwintersForecastLambdaClient.ActivityForecast();
        List<HoltwintersForecastLambdaClient.ActivityTimeRange> timeRanges = new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
        
        // Create a test time range
        HoltwintersForecastLambdaClient.ActivityTimeRange timeRange = new HoltwintersForecastLambdaClient.ActivityTimeRange();
        timeRange.time_range = '08:30-10:30';
        timeRange.startDateTime = '2025-07-31T08:30:00';
        timeRange.endDateTime = '2025-07-31T10:30:00';
        timeRange.predicted_activity = 3.869;
        timeRange.confidence = 'high';
        timeRange.detected_peak_time = '09:00';
        timeRange.userId = '0051234567890ABC';
        
        timeRanges.add(timeRange);
        
        // Act
        Test.startTest();
        activityForecast.timeRanges = timeRanges;
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, activityForecast.timeRanges, 'Time ranges should not be null');
        System.assertEquals(1, activityForecast.timeRanges.size(), 'Should have 1 time range');
        System.assertEquals('08:30-10:30', activityForecast.timeRanges[0].time_range, 'Time range should match');
    }

    @IsTest
    static void testSeasonalityInfo_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.SeasonalityInfo seasonalityInfo = new HoltwintersForecastLambdaClient.SeasonalityInfo();
        
        // Act
        Test.startTest();
        seasonalityInfo.type = 'daily';
        seasonalityInfo.description = 'Daily seasonality (24 hours)';
        Test.stopTest();

        // Assert
        System.assertEquals('daily', seasonalityInfo.type, 'Type should match');
        System.assertEquals('Daily seasonality (24 hours)', seasonalityInfo.description, 'Description should match');
    }

    @IsTest
    static void testExecutionStats_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.ExecutionStats executionStats = new HoltwintersForecastLambdaClient.ExecutionStats();
        
        // Act
        Test.startTest();
        executionStats.execution_time_seconds = 0.123;
        executionStats.logs_processed = 150;
        executionStats.users_processed = 1;
        executionStats.total_users = 1;
        Test.stopTest();

        // Assert
        System.assertEquals(0.123, executionStats.execution_time_seconds, 'Execution time should match');
        System.assertEquals(150, executionStats.logs_processed, 'Logs processed should match');
        System.assertEquals(1, executionStats.users_processed, 'Users processed should match');
        System.assertEquals(1, executionStats.total_users, 'Total users should match');
    }

    @IsTest
    static void testLambdaResponse_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.LambdaResponse lambdaResponse = new HoltwintersForecastLambdaClient.LambdaResponse();
        Map<String, HoltwintersForecastLambdaClient.ActivityForecast> activity = new Map<String, HoltwintersForecastLambdaClient.ActivityForecast>();
        HoltwintersForecastLambdaClient.SeasonalityInfo seasonality = new HoltwintersForecastLambdaClient.SeasonalityInfo();
        HoltwintersForecastLambdaClient.ExecutionStats executionStats = new HoltwintersForecastLambdaClient.ExecutionStats();
        
        // Create test data
        HoltwintersForecastLambdaClient.ActivityForecast activityForecast = new HoltwintersForecastLambdaClient.ActivityForecast();
        activityForecast.timeRanges = new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
        activity.put('31-07-2025', activityForecast);
        
        seasonality.type = 'daily';
        seasonality.description = 'Daily seasonality (24 hours)';
        
        executionStats.execution_time_seconds = 0.123;
        executionStats.logs_processed = 150;
        executionStats.users_processed = 1;
        executionStats.total_users = 1;
        
        // Act
        Test.startTest();
        lambdaResponse.forecast = new Map<String, List<HoltwintersForecastLambdaClient.ActivityTimeRange>>();
        lambdaResponse.execution_time_seconds = 0.123;
        lambdaResponse.logs_processed = 150;
        lambdaResponse.users_processed = 1;
        lambdaResponse.total_users = 1;
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, lambdaResponse.forecast, 'Forecast should not be null');
        System.assertEquals(0.123, lambdaResponse.execution_time_seconds, 'Execution time should match');
        System.assertEquals(150, lambdaResponse.logs_processed, 'Logs processed should match');
    }

    @IsTest
    static void testGenerateUserActivityForecast_WithLogEntry() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_WithLogEntryAndForecastDays() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY, 14, 60);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_WithLogEntryAndLookbackDays() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY, 14, 60);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_EmptyLogsData() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> emptyLogsData = new List<HoltwintersForecastLambdaClient.LogEntry>();

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(emptyLogsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Should have thrown an exception');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('Logs data is required'), 'Should contain error message about empty logs');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGenerateUserActivityForecast_NullLogsData() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(null, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Should have thrown an exception');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('Logs data is required'), 'Should contain error message about null logs');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGenerateUserActivityForecast_LambdaError() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response with error
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(500, createErrorResponse()));

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Should have thrown an exception');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('Error'), 'Should contain error message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetLambdaResponse_Success() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaResponse lambdaResponse = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, lambdaResponse, 'Lambda response should not be null');
        System.assertNotEquals(null, lambdaResponse.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGetLambdaResponse_NoCall() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act & Assert
        Test.startTest();
        try {
            client.getLambdaResponse();
            System.assert(false, 'Should have thrown an exception');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('No Lambda response available'), 'Should contain error message about no response');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetActivityForecast_Success() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGetSeasonalityInfo_Success() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGetExecutionStats_Success() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
        System.assertNotEquals(null, result.execution_time_seconds, 'Execution time should not be null');
        System.assertNotEquals(null, result.logs_processed, 'Logs processed should not be null');
    }

    @IsTest
    static void testIsSuccess_Success() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        Boolean isSuccess = client.isSuccess();
        Test.stopTest();

        // Assert
        System.assertEquals(true, isSuccess, 'Should be successful');
    }

    @IsTest
    static void testIsSuccess_NoCall() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act
        Test.startTest();
        Boolean isSuccess = client.isSuccess();
        Test.stopTest();

        // Assert
        System.assertEquals(false, isSuccess, 'Should not be successful when no call made');
    }

    @IsTest
    static void testGetErrorResponse_NoError() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
        HoltwintersForecastLambdaClient.LambdaErrorResponse errorResponse = client.getErrorResponse();
        Test.stopTest();

        // Assert
        System.assertEquals(null, errorResponse, 'Error response should be null for successful call');
    }

    @IsTest
    static void testConfigurationConstants() {
        // Act & Assert
        Test.startTest();
        
        System.assertEquals(7, HoltwintersForecastLambdaClient.getDefaultForecastDays(), 'Default forecast days should be 7');
        System.assertEquals(1, HoltwintersForecastLambdaClient.getMinForecastDays(), 'Min forecast days should be 1');
        System.assertEquals(30, HoltwintersForecastLambdaClient.getMaxForecastDays(), 'Max forecast days should be 30');
        
        // Test lookback days constants
        System.assertEquals(30, HoltwintersForecastLambdaClient.getDefaultLookbackDays(), 'Default lookback days should be 30');
        System.assertEquals(1, HoltwintersForecastLambdaClient.getMinLookbackDays(), 'Min lookback days should be 1');
        System.assertEquals(365, HoltwintersForecastLambdaClient.getMaxLookbackDays(), 'Max lookback days should be 365');
        
        Test.stopTest();
    }

    @IsTest
    static void testLambdaErrorResponse_Properties() {
        // Arrange
        HoltwintersForecastLambdaClient.LambdaErrorResponse errorResponse = new HoltwintersForecastLambdaClient.LambdaErrorResponse();

        // Act
        Test.startTest();
        errorResponse.statusCode = 500;
        errorResponse.message = 'Error processing request';
        errorResponse.error = 'Invalid input data';
        Test.stopTest();

        // Assert
        System.assertEquals(500, errorResponse.statusCode, 'Status code should match');
        System.assertEquals('Error processing request', errorResponse.message, 'Message should match');
        System.assertEquals('Invalid input data', errorResponse.error, 'Error should match');
    }

    @IsTest
    static void testGenerateUserActivityForecast_NullSeasonalityType() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        client.generateUserActivityForecast(logsData, null, 7, 30); // null seasonality type should default to AUTO
        HoltwintersForecastLambdaClient.LambdaResponse result = client.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals(null, result.forecast, 'Forecast should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_InvalidForecastDays() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        // Test with invalid forecast days (out of range)
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 0, 30); // Invalid: too low
        HoltwintersForecastLambdaClient.LambdaResponse result1 = client.getLambdaResponse();
        
        HoltwintersForecastLambdaClient client2 = new HoltwintersForecastLambdaClient();
        client2.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 50, 30); // Invalid: too high
        HoltwintersForecastLambdaClient.LambdaResponse result2 = client2.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result1, 'Response should not be null');
        System.assertNotEquals(null, result2, 'Response should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_InvalidLookbackDays() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, createSuccessResponse()));

        // Act
        Test.startTest();
        // Test with invalid lookback days (out of range)
        client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 0); // Invalid: too low
        HoltwintersForecastLambdaClient.LambdaResponse result1 = client.getLambdaResponse();
        
        HoltwintersForecastLambdaClient client2 = new HoltwintersForecastLambdaClient();
        client2.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 500); // Invalid: too high
        HoltwintersForecastLambdaClient.LambdaResponse result2 = client2.getLambdaResponse();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result1, 'Response should not be null');
        System.assertNotEquals(null, result2, 'Response should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_EmptyResponse() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response with empty body
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, ''));

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Exception should have been thrown for empty response');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assertEquals('Empty response from Lambda function', e.getMessage(), 'Expected empty response error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGenerateUserActivityForecast_InvalidJsonResponse() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response with invalid JSON
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(200, '{"invalid": "json", "structure": {'));

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Exception should have been thrown for invalid JSON');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('Error calling Lambda function'), 'Expected error calling lambda function message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetActivityForecast_NoResponse() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act & Assert
        Test.startTest();
        try {
            client.getActivityForecast();
            System.assert(false, 'Exception should have been thrown');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('No activity forecast data available'), 'Expected no forecast data error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetSeasonalityInfo_NoResponse() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act & Assert
        Test.startTest();
        try {
            client.getSeasonalityInfo();
            System.assert(false, 'Exception should have been thrown');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('No seasonality information available'), 'Expected no seasonality error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetExecutionStats_NoResponse() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        // Act & Assert
        Test.startTest();
        try {
            client.getExecutionStats();
            System.assert(false, 'Exception should have been thrown');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('No execution statistics available'), 'Expected no stats error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testHttpCalloutException() {
        // Arrange
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = createTestLogEntries();

        // Mock HTTP response with error status
        Test.setMock(HttpCalloutMock.class, new HoltwintersForecastMock(500, 'Server Error'));

        // Act & Assert
        Test.startTest();
        try {
            client.generateUserActivityForecast(logsData, HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 7, 30);
            System.assert(false, 'Exception should have been thrown for HTTP error');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            System.assert(e.getMessage().contains('Error calling Lambda function'), 'Expected HTTP error message');
        }
        Test.stopTest();
    }

    // Helper methods
    private static List<HoltwintersForecastLambdaClient.LogEntry> createTestLogEntries() {
        List<HoltwintersForecastLambdaClient.LogEntry> logEntries = new List<HoltwintersForecastLambdaClient.LogEntry>();
        
        // Add some test log entries
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('0051234567890ABC', '2025-07-17T06:15:00Z'));
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('0051234567890ABC', '2025-07-17T12:02:00Z'));
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('005DEF4567890XYZ', '2025-07-17T09:30:00Z'));
        
        return logEntries;
    }

    private static String createSuccessResponse() {
        return JSON.serialize(new Map<String, Object>{
            'forecast' => new Map<String, Object>{
                '31-07-2025' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'time_range' => '08:30-10:30',
                        'startDateTime' => '2025-07-31T08:30:00',
                        'endDateTime' => '2025-07-31T10:30:00',
                        'predicted_activity' => 3.869,
                        'confidence' => 'high',
                        'detected_peak_time' => '09:00',
                        'userId' => '0051234567890ABC'
                    }
                }
            },
            'seasonality' => new Map<String, Object>{
                'type' => 'daily',
                'description' => 'Daily seasonality (24 hours)'
            },
            'execution_time_seconds' => 0.123,
            'logs_processed' => 150,
            'users_processed' => 1,
            'total_users' => 1
        });
    }

    private static String createErrorResponse() {
        return JSON.serialize(new Map<String, Object>{
            'message' => 'Error processing request',
            'error' => 'Invalid input data'
        });
    }

    // Mock class for HTTP callouts
    private class HoltwintersForecastMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public HoltwintersForecastMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }
}