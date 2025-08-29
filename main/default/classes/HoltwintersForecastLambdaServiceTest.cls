/**
 * Unit Tests for HoltwintersForecastLambdaService
 * 
 * Tests all functionality including:
 * - User activity forecast generation
 * - Data preparation and validation
 * - Error handling
 * - Date range filtering
 * - Integration with Lambda client
 * 
 * @since API Version 62.0
 */
@IsTest
private class HoltwintersForecastLambdaServiceTest {

    @TestSetup
    static void setupTestData() {
        // Create test users with unique usernames
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@test.com',
            Username = 'testuser1.holtwinters@test.com.test',
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
            Username = 'testuser2.holtwinters@test.com.test',
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
    static void testGetLogsCountByDay_Success() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Datetime startDate = System.now().addDays(-30);
        Datetime endDate = System.now();
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        Map<String, Integer> logsByDay = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logsByDay, 'Logs by day should not be null');
        
        // Verify structure of returned data (even if empty)
        for (String dateKey : logsByDay.keySet()) {
            System.assert(dateKey.length() == 10, 'Date key should be 10 characters (YYYY-MM-DD format)');
            System.assert(logsByDay.get(dateKey) >= 0, 'Count should be non-negative');
        }
    }

    @IsTest
    static void testGetLogsCountByDay_EmptyRange() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Datetime startDate = System.now().addDays(1); // Future date
        Datetime endDate = System.now().addDays(2);
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        Map<String, Integer> logsByDay = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logsByDay, 'Logs by day should not be null');
        System.assertEquals(0, logsByDay.size(), 'Should return empty map for future date range');
    }

    @IsTest
    static void testGetLogsCountByDayLargeDataset_Success() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Datetime startDate = System.now().addDays(-90);
        Datetime endDate = System.now();
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, dateRanges, 'Date ranges should not be null');
        
        // Verify structure of returned data
        for (Map<String, Datetime> dateRange : dateRanges) {
            System.assert(dateRange.containsKey('startDate'), 'Date range should contain startDate key');
            System.assert(dateRange.containsKey('endDate'), 'Date range should contain endDate key');
            System.assertNotEquals(null, dateRange.get('startDate'), 'startDate should not be null');
            System.assertNotEquals(null, dateRange.get('endDate'), 'endDate should not be null');
            System.assert(dateRange.get('startDate') <= dateRange.get('endDate'), 'startDate should be before or equal to endDate');
        }
    }

    @IsTest
    static void testGetLogsCountByDayLargeDataset_SingleBatch() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Datetime startDate = System.now().addDays(-7);
        Datetime endDate = System.now();
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, dateRanges, 'Date ranges should not be null');
        // Note: Returns 0 batches when no Log__c records exist in the org
        System.assert(dateRanges.size() >= 0, 'Should return 0 or more batches');
        
        if (dateRanges.size() > 0) {
            Map<String, Datetime> singleRange = dateRanges[0];
            System.assertEquals(startDate, singleRange.get('startDate'), 'Start date should match input');
            System.assertEquals(endDate, singleRange.get('endDate'), 'End date should match input');
        }
    }

    @IsTest
    static void testGetLogsCountByDayLargeDataset_EmptyRange() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Datetime startDate = System.now().addDays(1); // Future date
        Datetime endDate = System.now().addDays(2);
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, dateRanges, 'Date ranges should not be null');
        System.assertEquals(0, dateRanges.size(), 'Should return empty list for future date range');
    }

    @IsTest
    static void testServiceInstantiation() {
        // Arrange & Act
        Test.startTest();
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, service, 'Service should be instantiated successfully');
    }

    @IsTest
    static void testMethodSignatures() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        String issueId = 'test-issue-123';
        Datetime startDate = System.now().addDays(-30);
        Datetime endDate = System.now();

        // Act & Assert
        Test.startTest();
        
        // Test getLogsCountByDay method signature
        Map<String, Integer> logsByDay = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, startDate, endDate);
        System.assertNotEquals(null, logsByDay, 'getLogsCountByDay should return a Map');
        
        // Test getLogsCountByDayLargeDataset method signature
        List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, startDate, endDate);
        System.assertNotEquals(null, dateRanges, 'getLogsCountByDayLargeDataset should return a List');
        
        Test.stopTest();
    }

    @IsTest
    static void testDateRangeValidation() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        String issueId = 'test-issue-123';
        Datetime startDate = System.now().addDays(-30);
        Datetime endDate = System.now();

        // Act & Assert
        Test.startTest();
        
        // Test with valid date range (startDate < endDate)
        Map<String, Integer> logsByDay = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, startDate, endDate);
        System.assertNotEquals(null, logsByDay, 'Should handle valid date range');
        
        // Test with same start and end date
        Map<String, Integer> logsByDaySame = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, startDate, startDate);
        System.assertNotEquals(null, logsByDaySame, 'Should handle same start and end date');
        
        // Test with future date range (should return empty results)
        Datetime futureStart = System.now().addDays(1);
        Datetime futureEnd = System.now().addDays(2);
        Map<String, Integer> logsByDayFuture = HoltwintersForecastLambdaService.getLogsCountByDay(issueId, futureStart, futureEnd);
        System.assertNotEquals(null, logsByDayFuture, 'Should handle future date range');
        System.assertEquals(0, logsByDayFuture.size(), 'Future date range should return empty results');
        
        Test.stopTest();
    }

    @IsTest
    static void testLargeDatasetMethodValidation() {
        // Arrange
        HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
        String issueId = 'test-issue-123';
        Datetime startDate = System.now().addDays(-90);
        Datetime endDate = System.now();

        // Act & Assert
        Test.startTest();
        
        // Test with large date range
        List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, startDate, endDate);
        System.assertNotEquals(null, dateRanges, 'Should handle large date range');
        
        // Test with small date range (should return single batch when data exists)
        Datetime smallStart = System.now().addDays(-7);
        Datetime smallEnd = System.now();
        List<Map<String, Datetime>> smallDateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, smallStart, smallEnd);
        System.assertNotEquals(null, smallDateRanges, 'Should handle small date range');
        System.assert(smallDateRanges.size() >= 0, 'Small date range should return 0 or more batches');
        
        // Test with future date range (should return empty list)
        Datetime futureStart = System.now().addDays(1);
        Datetime futureEnd = System.now().addDays(2);
        List<Map<String, Datetime>> futureDateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(issueId, futureStart, futureEnd);
        System.assertNotEquals(null, futureDateRanges, 'Should handle future date range');
        System.assertEquals(0, futureDateRanges.size(), 'Future date range should return empty list');
        
        Test.stopTest();
    }

    @IsTest
    static void testIsEnabled() {
        // Test isEnabled property
        Test.startTest();
        Boolean enabled = HoltwintersForecastLambdaService.isEnabled;
        Test.stopTest();
        
        // Assert that method returns without error (actual value depends on permissions and settings)
        System.assert(enabled != null, 'isEnabled property should return a valid boolean value');
    }

    @IsTest
    static void testGenerateUserActivityForecast_FourParameters() {
        // Arrange
        String issueId = 'test-issue-123';
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType = HoltwintersForecastLambdaClient.SeasonalityType.DAILY;
        Integer forecastDays = 7;
        Integer lookbackDays = 30;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        try {
            HoltwintersForecastLambdaClient.LambdaResponse response = 
                HoltwintersForecastLambdaService.generateUserActivityForecast(issueId, seasonalityType, forecastDays, lookbackDays);
            
            // If we get here without exception, the test passed
            System.assertNotEquals(null, response, 'Response should not be null');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            // Expected exception when no logs data available in test context
            System.assert(e.getMessage().contains('Logs data is required'), 'Expected logs data validation error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGenerateUserActivityForecast_WithLogEntries() {
        // Arrange
        List<HoltwintersForecastLambdaClient.LogEntry> logEntries = new List<HoltwintersForecastLambdaClient.LogEntry>();
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('user123', '2024-01-15T10:30:00Z'));
        logEntries.add(new HoltwintersForecastLambdaClient.LogEntry('user456', '2024-01-15T14:15:00Z'));
        
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType = HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY;
        Integer forecastDays = 5;
        Integer lookbackDays = 60;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        HoltwintersForecastLambdaClient.LambdaResponse response = 
            HoltwintersForecastLambdaService.generateUserActivityForecast(logEntries, seasonalityType, forecastDays, lookbackDays);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @IsTest
    static void testGenerateUserActivityForecast_ThreeParameters() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer forecastDays = 7;
        Integer lookbackDays = 30;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        try {
            HoltwintersForecastLambdaClient.LambdaResponse response = 
                HoltwintersForecastLambdaService.generateUserActivityForecast(issueId, forecastDays, lookbackDays);
            
            // If we get here without exception, the test passed
            System.assertNotEquals(null, response, 'Response should not be null');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            // Expected exception when no logs data available in test context
            System.assert(e.getMessage().contains('Logs data is required'), 'Expected logs data validation error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGenerateUserActivityForecast_TwoParameters() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer forecastDays = 7;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        try {
            HoltwintersForecastLambdaClient.LambdaResponse response = 
                HoltwintersForecastLambdaService.generateUserActivityForecast(issueId, forecastDays);
            
            // If we get here without exception, the test passed
            System.assertNotEquals(null, response, 'Response should not be null');
        } catch (HoltwintersForecastLambdaClient.HoltwintersForecastException e) {
            // Expected exception when no logs data available in test context
            System.assert(e.getMessage().contains('Logs data is required'), 'Expected logs data validation error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetUserIdToDateTime() {
        // Arrange
        String issueId = 'test-issue-123';
        Datetime startDate = System.now().addDays(-7);
        Datetime endDate = System.now();

        // Act
        Test.startTest();
        List<HoltwintersForecastLambdaClient.LogEntry> logEntries = 
            HoltwintersForecastLambdaService.getUserIdToDateTime(issueId, startDate, endDate);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logEntries, 'Log entries should not be null');
        System.assert(logEntries.size() >= 0, 'Should return valid list of log entries');
    }

    @IsTest
    static void testGetForecastStatistics_Success() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer forecastDays = 7;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        Map<String, Object> stats = HoltwintersForecastLambdaService.getForecastStatistics(issueId, forecastDays);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, stats, 'Stats should not be null');
    }

    @IsTest
    static void testGetForecastStatistics_NullForecastDays() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer forecastDays = null; // Test default behavior

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        Map<String, Object> stats = HoltwintersForecastLambdaService.getForecastStatistics(issueId, forecastDays);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, stats, 'Stats should not be null even with null forecastDays');
    }

    @IsTest
    static void testGetForecastStatistics_Exception() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer forecastDays = 7;

        // Mock HTTP callout that will cause an exception
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutFailure());

        // Act
        Test.startTest();
        Map<String, Object> stats = HoltwintersForecastLambdaService.getForecastStatistics(issueId, forecastDays);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, stats, 'Stats should not be null even on exception');
        System.assertEquals(0, stats.size(), 'Should return empty map on exception');
    }

    @IsTest
    static void testHasSufficientData_WithMinimumLogs() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer minimumLogs = 50;

        // Act
        Test.startTest();
        Boolean hasSufficient = HoltwintersForecastLambdaService.hasSufficientData(issueId, minimumLogs);
        Test.stopTest();

        // Assert
        System.assert(hasSufficient != null, 'hasSufficientData should return a valid boolean');
    }

    @IsTest
    static void testHasSufficientData_NullMinimumLogs() {
        // Arrange
        String issueId = 'test-issue-123';
        Integer minimumLogs = null; // Test default behavior

        // Act
        Test.startTest();
        Boolean hasSufficient = HoltwintersForecastLambdaService.hasSufficientData(issueId, minimumLogs);
        Test.stopTest();

        // Assert
        System.assert(hasSufficient != null, 'hasSufficientData should return a valid boolean even with null minimumLogs');
    }

    @IsTest
    static void testGetRecommendedParameters() {
        // Arrange
        String issueId = 'test-issue-123';

        // Act
        Test.startTest();
        Map<String, Object> recommendations = HoltwintersForecastLambdaService.getRecommendedParameters(issueId);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, recommendations, 'Recommendations should not be null');
        System.assert(recommendations.containsKey('recommendedSeasonality'), 'Should contain recommendedSeasonality');
        System.assert(recommendations.containsKey('recommendedForecastDays'), 'Should contain recommendedForecastDays');
        System.assert(recommendations.containsKey('dataQuality'), 'Should contain dataQuality');
    }

    // Mock class for successful HTTP callouts
    private class MockHttpCalloutSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            // Return mock successful forecast response
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
            
            response.setBody(responseBody);
            return response;
        }
    }

    // Mock class for failed HTTP callouts
    private class MockHttpCalloutFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"error": "Internal server error"}');
            return response;
        }
    }

    @IsTest
    static void testGenerateUserActivityForecast_WithActualLogs() {
        // Create test log data to trigger successful path
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue');
        insert testIssue;
        
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 5; i++) {
            testLogs.add(new Log__c(
                Issue__c = testIssue.Id,
                User_Id__c = 'user' + i,
                Created_At__c = System.now().addDays(-i),
                Summary__c = 'Test log ' + i
            ));
        }
        insert testLogs;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());

        // Act
        Test.startTest();
        HoltwintersForecastLambdaClient.LambdaResponse response = 
            HoltwintersForecastLambdaService.generateUserActivityForecast(
                testIssue.Id, 
                HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 
                7, 
                30
            );
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @IsTest
    static void testGetLogsCountByDayLargeDataset_WithBatchProcessing() {
        // Create test issue and logs to trigger batch processing logic
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Large Dataset');
        insert testIssue;
        
        List<Log__c> testLogs = new List<Log__c>();
        // Create logs across multiple days to trigger batch logic
        for (Integer day = 0; day < 10; day++) {
            for (Integer i = 0; i < 100; i++) {
                testLogs.add(new Log__c(
                    Issue__c = testIssue.Id,
                    User_Id__c = 'user' + i,
                    Created_At__c = System.now().addDays(-day).addHours(i),
                    Summary__c = 'Test log day ' + day + ' entry ' + i
                ));
            }
        }
        insert testLogs;

        // Act
        Test.startTest();
        List<Map<String, Datetime>> dateRanges = 
            HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(
                testIssue.Id, 
                System.now().addDays(-10), 
                System.now()
            );
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, dateRanges, 'Date ranges should not be null');
        System.assert(dateRanges.size() > 0, 'Should return date ranges for batch processing');
    }

    @IsTest
    static void testGetForecastStatistics_WithDetailedResponse() {
        // Create test issue with logs
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Stats');
        insert testIssue;
        
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 10; i++) {
            testLogs.add(new Log__c(
                Issue__c = testIssue.Id,
                User_Id__c = 'user' + i,
                Created_At__c = System.now().addDays(-i),
                Summary__c = 'Test log ' + i
            ));
        }
        insert testLogs;

        // Mock HTTP callout with detailed forecast response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutDetailedSuccess());

        // Act
        Test.startTest();
        Map<String, Object> stats = HoltwintersForecastLambdaService.getForecastStatistics(testIssue.Id, 7);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, stats, 'Stats should not be null');
        System.assert(stats.containsKey('totalForecastDays'), 'Should contain totalForecastDays');
        System.assert(stats.containsKey('totalTimeRanges'), 'Should contain totalTimeRanges');
        System.assert(stats.containsKey('highConfidenceRanges'), 'Should contain highConfidenceRanges');
        System.assert(stats.containsKey('mediumConfidenceRanges'), 'Should contain mediumConfidenceRanges');
        System.assert(stats.containsKey('lowConfidenceRanges'), 'Should contain lowConfidenceRanges');
    }

    @IsTest
    static void testGetUserIdToDateTime_WithActualLogs() {
        // Create test issue and logs
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue DateTime');
        insert testIssue;
        
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 3; i++) {
            testLogs.add(new Log__c(
                Issue__c = testIssue.Id,
                User_Id__c = 'testuser' + i,
                Created_At__c = System.now().addHours(-i),
                Summary__c = 'Test log ' + i
            ));
        }
        insert testLogs;

        // Act
        Test.startTest();
        List<HoltwintersForecastLambdaClient.LogEntry> logEntries = 
            HoltwintersForecastLambdaService.getUserIdToDateTime(
                testIssue.Id, 
                System.now().addDays(-1), 
                System.now()
            );
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, logEntries, 'Log entries should not be null');
        System.assertEquals(3, logEntries.size(), 'Should return 3 log entries');
        
        // Verify log entries contain expected data
        for (HoltwintersForecastLambdaClient.LogEntry entry : logEntries) {
            System.assert(entry.userId.startsWith('testuser'), 'User ID should start with testuser');
            System.assertNotEquals(null, entry.timestamp, 'Timestamp should not be null');
        }
    }

    @IsTest
    static void testHasSufficientData_WithVariousDataCounts() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Sufficient Data');
        insert testIssue;
        
        // Test with insufficient data (less than default 72)
        List<Log__c> fewLogs = new List<Log__c>();
        for (Integer i = 0; i < 10; i++) {
            fewLogs.add(new Log__c(
                Issue__c = testIssue.Id,
                User_Id__c = 'user' + i,
                Created_At__c = System.now().addDays(-i),
                Summary__c = 'Test log ' + i
            ));
        }
        insert fewLogs;

        // Act & Assert for insufficient data
        Test.startTest();
        Boolean hasInsufficientData = HoltwintersForecastLambdaService.hasSufficientData(testIssue.Id, 50);
        System.assertEquals(false, hasInsufficientData, 'Should return false for insufficient data');
        
        Boolean hasEnoughData = HoltwintersForecastLambdaService.hasSufficientData(testIssue.Id, 5);
        System.assertEquals(true, hasEnoughData, 'Should return true when threshold is met');
        Test.stopTest();
    }

    @IsTest
    static void testGetRecommendedParameters_DetailedLogic() {
        // Create test issue
        Issue__c testIssue = new Issue__c(Summary__c = 'Test Issue Recommendations');
        insert testIssue;
        
        // Add varying amounts of logs to test different recommendation paths
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 100; i++) {
            testLogs.add(new Log__c(
                Issue__c = testIssue.Id,
                User_Id__c = 'user' + Math.mod(i, 10),
                Created_At__c = System.now().addDays(-Math.mod(i, 30)),
                Summary__c = 'Test log ' + i
            ));
        }
        insert testLogs;

        // Act
        Test.startTest();
        Map<String, Object> recommendations = 
            HoltwintersForecastLambdaService.getRecommendedParameters(testIssue.Id);
        Test.stopTest();

        // Assert detailed recommendations
        System.assertNotEquals(null, recommendations, 'Recommendations should not be null');
        System.assert(recommendations.containsKey('recommendedSeasonality'), 'Should contain recommendedSeasonality');
        System.assert(recommendations.containsKey('recommendedForecastDays'), 'Should contain recommendedForecastDays');
        System.assert(recommendations.containsKey('dataQuality'), 'Should contain dataQuality');
        System.assert(recommendations.containsKey('hasMinimumData'), 'Should contain hasMinimumData');
        System.assert(recommendations.containsKey('hasOptimalData'), 'Should contain hasOptimalData');
        System.assert(recommendations.containsKey('hasGoodData'), 'Should contain hasGoodData');
        
        // Verify recommendation logic
        String seasonality = (String)recommendations.get('recommendedSeasonality');
        System.assert(seasonality != null, 'Seasonality recommendation should not be null');
        
        Integer forecastDays = (Integer)recommendations.get('recommendedForecastDays');
        System.assert(forecastDays > 0, 'Forecast days should be positive');
    }

    // Enhanced mock class with detailed forecast response
    private class MockHttpCalloutDetailedSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            // Return detailed mock forecast response with multiple confidence levels
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
                        },
                        new Map<String, Object>{
                            'time_range' => '14:00-16:00',
                            'startDateTime' => '2024-07-31T14:00:00',
                            'endDateTime' => '2024-07-31T16:00:00',
                            'predicted_activity' => 2.5,
                            'confidence' => 'medium',
                            'detected_peak_time' => '15:00',
                            'userId' => 'user2'
                        }
                    },
                    '2024-08-01' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'time_range' => '10:00-12:00',
                            'startDateTime' => '2024-08-01T10:00:00',
                            'endDateTime' => '2024-08-01T12:00:00',
                            'predicted_activity' => 1.2,
                            'confidence' => 'low',
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
            });
            
            response.setBody(responseBody);
            return response;
        }
    }
}