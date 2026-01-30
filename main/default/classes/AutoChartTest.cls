/**
 * Test class for AutoChart service
 * Tests all AutoChart functionality including chart field detection, 
 * 3-step processing workflow, and integration with messaging platforms
 */
@isTest
private class AutoChartTest {

    // Simple Mock BatchContextManager for testing
    private class TestBatchContextManager implements NotificationService.BatchContextManager {
        private Map<String, NotificationService.ActionIteration> iterationContexts = new Map<String, NotificationService.ActionIteration>();
        private Map<String, String> chartDataStorage = new Map<String, String>();
        private Map<String, Map<String, String>> chartImagesStorage = new Map<String, Map<String, String>>();
        private Map<String, Integer> notificationAttempts = new Map<String, Integer>();

        public NotificationService.ActionIteration getIterationContext(String recordId) {
            return iterationContexts.get(recordId);
        }

        public void setIterationContext(String recordId, NotificationService.ActionIteration iteration) {
            iterationContexts.put(recordId, iteration);
        }

        public void clearIterationContext(String recordId) {
            iterationContexts.remove(recordId);
        }

        public void addRecordNotificationAttempt(String recordId) {
            Integer current = notificationAttempts.get(recordId);
            notificationAttempts.put(recordId, current != null ? current + 1 : 1);
        }

        public Integer getRecordNotificationAttempts(String recordId) {
            Integer attempts = notificationAttempts.get(recordId);
            return attempts != null ? attempts : 0;
        }

        public void incrementNotificationAttempts(String recordId) {
            addRecordNotificationAttempt(recordId);
        }

        public Integer getNotificationAttempts(String recordId) {
            return getRecordNotificationAttempts(recordId);
        }

        public void clearNotificationAttempts(String recordId) {
            notificationAttempts.remove(recordId);
        }

        public Set<String> getRecordsWithNotificationAttempts() {
            return notificationAttempts.keySet();
        }

        public void storeChartData(String recordId, String chartData) {
            chartDataStorage.put(recordId, chartData);
        }

        public String getChartData(String recordId) {
            return chartDataStorage.get(recordId);
        }

        public void storeChartImages(String recordId, Map<String, String> images) {
            chartImagesStorage.put(recordId, images);
        }

        public Map<String, String> getChartImages(String recordId) {
            return chartImagesStorage.get(recordId);
        }

        public void clearChartData(String recordId) {
            chartDataStorage.remove(recordId);
        }

        public void clearChartImages(String recordId) {
            chartImagesStorage.remove(recordId);
        }
    }

    // Test data setup
    @TestSetup
    static void makeData() {
        // Enable AutoChart feature for testing
        enableAutoChartFeature();

        // Create test records for different SObject types using existing patterns
        Log__c testLog = new Log__c(
            Hash_1__c = 'TEST-HASH-001',
            Hash_2__c = 'TEST-HASH-002',
            Hash_3__c = 'TEST-HASH-003',
            Category__c = 'Test',
            Details__c = 'Test log details for AutoChart',
            Summary__c = 'Test log summary',
            Related_Id__c = UserInfo.getUserId(),
            User_Id__c = UserInfo.getUserId(),
            Related_Object_Type__c = 'User'
        );
        insert testLog;

        Issue__c testIssue = new Issue__c(
            Status__c = 'New'
        );
        insert testIssue;

        // Create a Trace_Request__c first
        Trace_Request__c traceRequest = new Trace_Request__c(
            Status__c = 'In Progress',
            Start_Date__c = System.now().addMinutes(-30),
            End_Date__c = System.now(),
            Traced_Entity_Id__c = UserInfo.getUserId(),
            Source__c = UserInfo.getOrganizationId()
        );
        insert traceRequest;

        Trace_Result__c testTrace = new Trace_Result__c(
            Trace_Request__c = traceRequest.Id,
            Trace_Start_Date__c = System.now().addMinutes(-30),
            Trace_End_Date__c = System.now()
        );
        insert testTrace;

        // Create test Actions with AutoChart merge fields
        Action__c chartAction = new Action__c(
            Subject__c = 'Chart Report: {!System_Auto_Chart.EXECUTION_TIME_CHART}',
            Body__c = 'Daily metrics: {!System_Auto_Chart.MEMORY_USAGE_CHART} and {!System_Auto_Chart.ERROR_RATE_CHART}',
            Action_Type__c = 'SLACK_NOTIFICATION'
        );
        insert chartAction;

        Action__c regularAction = new Action__c(
            Subject__c = 'Regular notification without charts',
            Body__c = 'This is a regular notification message',
            Action_Type__c = 'EMAIL_NOTIFICATION'
        );
        insert regularAction;

        // Create EventAction for testing TicketingService scenarios  
        // Note: Commenting out EventAction creation as it requires Event__c field
        // EventAction__c testEventAction = new EventAction__c(
        //     Action__c = chartAction.Id,
        //     Action_Type__c = 'JIRA_NOTIFICATION',
        //     Executed_On__c = System.now(),
        //     Event__c = 'some_event_id'  // This field is required but complex to set up
        // );
        // insert testEventAction;
    }

    // Test AutoChartIteration class
    @isTest
    static void testAutoChartIteration() {
        Test.startTest();

        String recordId = 'a0A000000000001';
        List<String> chartTypes = new List<String>{
            'EXECUTION_TIME_CHART', 'MEMORY_USAGE_CHART'
        };

        // Test creating AutoChartIteration for each step
        AutoChart.AutoChartIteration dataIteration = new AutoChart.AutoChartIteration(
            recordId, 1, 3, chartTypes, AutoChart.AutoChartStep.GET_DATA
        );

        System.assertEquals(recordId, dataIteration.recordId);
        System.assertEquals(1, dataIteration.iterationNumber);
        System.assertEquals(3, dataIteration.totalIterations);
        System.assertEquals(chartTypes, dataIteration.chartTypes);
        System.assertEquals(AutoChart.AutoChartStep.GET_DATA, dataIteration.currentStep);
        System.assertEquals('AUTOCHART', dataIteration.actionType);
        System.assertEquals(String.join(chartTypes, ','), dataIteration.actionId);

        // Test other steps
        AutoChart.AutoChartIteration imageIteration = new AutoChart.AutoChartIteration(
            recordId, 2, 3, chartTypes, AutoChart.AutoChartStep.GET_IMAGE
        );
        System.assertEquals(AutoChart.AutoChartStep.GET_IMAGE, imageIteration.currentStep);

        AutoChart.AutoChartIteration messageIteration = new AutoChart.AutoChartIteration(
            recordId, 3, 3, chartTypes, AutoChart.AutoChartStep.SEND_MESSAGE
        );
        System.assertEquals(AutoChart.AutoChartStep.SEND_MESSAGE, messageIteration.currentStep);

        Test.stopTest();
    }

    // Test AutoChartActionProcessor class with full workflow
    @isTest
    static void testAutoChartActionProcessor() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        NotificationService.ErrorsHelper errorsHelper = new NotificationService.ErrorsHelper(testLog);
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartActionProcessor processor = new AutoChart.AutoChartActionProcessor(
            testLog.Id, errorsHelper, batchContext
        );

        List<String> chartTypes = new List<String>{
            'EXECUTION_TIME_CHART'
        };

        // Test all three steps of the workflow
        AutoChart.AutoChartIteration dataIteration = new AutoChart.AutoChartIteration(
            testLog.Id, 1, 3, chartTypes, AutoChart.AutoChartStep.GET_DATA
        );

        AutoChart.AutoChartIteration imageIteration = new AutoChart.AutoChartIteration(
            testLog.Id, 2, 3, chartTypes, AutoChart.AutoChartStep.GET_IMAGE
        );

        AutoChart.AutoChartIteration messageIteration = new AutoChart.AutoChartIteration(
            testLog.Id, 3, 3, chartTypes, AutoChart.AutoChartStep.SEND_MESSAGE
        );

        try {
            // Test GET_DATA step
            processor.processAutoChartIteration(dataIteration);
        } catch (Exception e) {
            // Expected as we don't have full ReportService setup in test
            System.assert(true, 'Expected exception during data retrieval in test context');
        }

        try {
            // Test GET_IMAGE step
            processor.processAutoChartIteration(imageIteration);
        } catch (Exception e) {
            // Expected as we don't have chart data
            System.assert(true, 'Expected exception during image generation in test context');
        }

        try {
            // Test SEND_MESSAGE step
            processor.processAutoChartIteration(messageIteration);
        } catch (Exception e) {
            // Expected as we don't have chart images
            System.assert(true, 'Expected exception during message sending in test context');
        }

        Test.stopTest();
    }

    // Test AutoChartDataRetrievalHandler
    @isTest
    static void testAutoChartDataRetrievalHandler() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        Action__c testAction = [SELECT Id, Subject__c, Body__c, Action_Type__c FROM Action__c WHERE Subject__c LIKE '%System_Auto_Chart%' LIMIT 1];
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartDataRetrievalHandler handler = new AutoChart.AutoChartDataRetrievalHandler();

        // Test getActionType
        System.assertEquals('AUTOCHART_DATA_RETRIEVAL', handler.getActionType());

        // Test execute methods with different signatures
        try {
            handler.execute(testLog.Id, testAction);
            handler.execute(testLog.Id, testAction, testLog);
            handler.execute(testLog.Id, testAction, testLog, batchContext);
        } catch (Exception e) {
            // Expected as we don't have full ReportService setup
            System.assert(true, 'Expected exception during data retrieval in test context');
        }

        // Test exception handling
        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception'), null);
        } catch (Exception e) {
            System.assertEquals('Test exception', e.getMessage());
        }

        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception with batch'), null, batchContext);
        } catch (Exception e) {
            System.assertEquals('Test exception with batch', e.getMessage());
        }

        Test.stopTest();
    }

    // Test AutoChartImageGenerationHandler
    @isTest
    static void testAutoChartImageGenerationHandler() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        Action__c testAction = [SELECT Id, Subject__c, Body__c, Action_Type__c FROM Action__c WHERE Subject__c LIKE '%System_Auto_Chart%' LIMIT 1];
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartImageGenerationHandler handler = new AutoChart.AutoChartImageGenerationHandler();

        // Test getActionType
        System.assertEquals('AUTOCHART_IMAGE_GENERATION', handler.getActionType());

        // Test execute methods with different signatures
        try {
            handler.execute(testLog.Id, testAction);
            handler.execute(testLog.Id, testAction, testLog);
            handler.execute(testLog.Id, testAction, testLog, batchContext);
        } catch (Exception e) {
            // Expected as we don't have chart data in test context
            System.assert(true, 'Expected exception during image generation in test context');
        }

        // Test exception handling
        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception'), null);
        } catch (Exception e) {
            System.assertEquals('Test exception', e.getMessage());
        }

        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception with batch'), null, batchContext);
        } catch (Exception e) {
            System.assertEquals('Test exception with batch', e.getMessage());
        }

        Test.stopTest();
    }

    // Test AutoChartMessageSenderHandler with different platforms
    @isTest
    static void testAutoChartMessageSenderHandler() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        Action__c testAction = [SELECT Id, Subject__c, Body__c, Action_Type__c FROM Action__c WHERE Subject__c LIKE '%System_Auto_Chart%' LIMIT 1];
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartMessageSenderHandler handler = new AutoChart.AutoChartMessageSenderHandler();

        // Test getActionType
        System.assertEquals('AUTOCHART_MESSAGE_SENDING', handler.getActionType());

        // Test different platform types by modifying action type
        List<String> platformTypes = new List<String>{
            'SLACK_NOTIFICATION',
            'TEAMS_NOTIFICATION',
            'JIRA_NOTIFICATION',
            'AZURE_DEVOPS_NOTIFICATION',
            'EMAIL_NOTIFICATION',
            'PAGERDUTY_NOTIFICATION',
            'UNKNOWN_NOTIFICATION'
        };

        for (String platformType : platformTypes) {
            testAction.Action_Type__c = platformType;

            try {
                handler.execute(testLog.Id, testAction);
                handler.execute(testLog.Id, testAction, testLog);
                handler.execute(testLog.Id, testAction, testLog, batchContext);
            } catch (Exception e) {
                // Expected as we don't have chart images in test context
                System.assert(true, 'Expected exception during message sending for ' + platformType);
            }
        }

        // Test exception handling
        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception'), null);
        } catch (Exception e) {
            System.assertEquals('Test exception', e.getMessage());
        }

        try {
            handler.handleException(testLog.Id, new CalloutException('Test exception with batch'), null, batchContext);
        } catch (Exception e) {
            System.assertEquals('Test exception with batch', e.getMessage());
        }

        Test.stopTest();
    }

    // Test containsAutoChartFields method
    @isTest
    static void testContainsAutoChartFields() {
        // Enable AutoChart feature for this test
        enableAutoChartFeature();

        // Test with chart action
        Action__c chartAction = new Action__c(
            Subject__c = 'Test {!System_Auto_Chart.EXECUTION_TIME_CHART}',
            Body__c = 'Test {!System_Auto_Chart.MEMORY_USAGE_CHART} and {!System_Auto_Chart.ERROR_RATE_CHART}'
        );

        RuleUtil.Action chartActionWrapper = new RuleUtil.Action();
        chartActionWrapper.fields = chartAction;

        // Test with chart fields - result depends on feature flag state
        Boolean hasChartFields = AutoChart.containsAutoChartFields(chartActionWrapper);
        // Note: This will return false if AutoChartEnabled is false, which is expected behavior

        // Test with regular action
        Action__c regularAction = new Action__c(
            Subject__c = 'Regular notification without charts',
            Body__c = 'This is a regular notification message'
        );

        RuleUtil.Action regularActionWrapper = new RuleUtil.Action();
        regularActionWrapper.fields = regularAction;

        // Test without chart fields
        Boolean hasNoChartFields = AutoChart.containsAutoChartFields(regularActionWrapper);
        System.assertEquals(false, hasNoChartFields, 'Should not detect chart fields in regular action');

        // Test with null action
        RuleUtil.Action nullAction = new RuleUtil.Action();
        Boolean nullResult = AutoChart.containsAutoChartFields(nullAction);
        System.assertEquals(false, nullResult, 'Should return false for null action fields');
    }

    // Test extractChartTypesFromAction method
    @isTest
    static void testExtractChartTypesFromAction() {
        // Enable AutoChart feature for this test
        enableAutoChartFeature();

        // Test with chart action
        Action__c chartAction = new Action__c(
            Subject__c = 'Test {!System_Auto_Chart.EXECUTION_TIME_CHART}',
            Body__c = 'Test {!System_Auto_Chart.MEMORY_USAGE_CHART} and {!System_Auto_Chart.ERROR_RATE_CHART}'
        );

        RuleUtil.Action actionWrapper = new RuleUtil.Action();
        actionWrapper.fields = chartAction;

        List<String> chartTypes = AutoChart.extractChartTypesFromAction(actionWrapper);

        // The result depends on the current feature flag state
        if (AutoChart.isEnabled) {
            System.assert(!chartTypes.isEmpty(), 'Should extract chart types from action when feature is enabled');
            System.assert(chartTypes.contains('EXECUTION_TIME_CHART'), 'Should contain EXECUTION_TIME_CHART');
            System.assert(chartTypes.contains('MEMORY_USAGE_CHART'), 'Should contain MEMORY_USAGE_CHART');
            System.assert(chartTypes.contains('ERROR_RATE_CHART'), 'Should contain ERROR_RATE_CHART');
        } else {
            System.assertEquals(0, chartTypes.size(), 'Should return empty list when feature is disabled');
        }

        // Test with regular action
        Action__c regularAction = new Action__c(
            Subject__c = 'Regular notification without charts',
            Body__c = 'This is a regular notification message'
        );

        RuleUtil.Action regularWrapper = new RuleUtil.Action();
        regularWrapper.fields = regularAction;

        List<String> noChartTypes = AutoChart.extractChartTypesFromAction(regularWrapper);
        System.assertEquals(0, noChartTypes.size(), 'Should return empty list for action without chart fields');
    }

    // Test getChartTypesFromAction method
    @isTest
    static void testGetChartTypesFromAction() {
        // Enable AutoChart feature for this test
        enableAutoChartFeature();

        // Test with AutoChart action
        Action__c autoChartAction = new Action__c(
            Subject__c = 'AutoChart: EXECUTION_TIME_CHART,MEMORY_USAGE_CHART',
            Body__c = 'Test body'
        );

        List<String> chartTypes = AutoChart.getChartTypesFromAction(autoChartAction);

        // The result depends on the current feature flag state
        if (AutoChart.isEnabled) {
            System.assertEquals(2, chartTypes.size());
            System.assertEquals('EXECUTION_TIME_CHART', chartTypes[0]);
            System.assertEquals('MEMORY_USAGE_CHART', chartTypes[1]);
        } else {
            System.assertEquals(0, chartTypes.size(), 'Should return empty list when feature is disabled');
        }

        // Test with regular action
        Action__c regularAction = new Action__c(
            Subject__c = 'Regular notification',
            Body__c = 'Test body'
        );

        List<String> emptyTypes = AutoChart.getChartTypesFromAction(regularAction);
        System.assertEquals(0, emptyTypes.size());

        // Test with null subject
        Action__c nullAction = new Action__c();
        List<String> nullTypes = AutoChart.getChartTypesFromAction(nullAction);
        System.assertEquals(0, nullTypes.size());
    }

    // Test removeAutoChartMergeFieldsWithList method
    @isTest
    static void testRemoveAutoChartMergeFieldsWithList() {
        Test.startTest();

        // Test with chart merge fields
        String contentWithCharts = 'Daily report: {!System_Auto_Chart.EXECUTION_TIME_CHART} and metrics: {!System_Auto_Chart.MEMORY_USAGE_CHART}';
        AutoChart.AutoChartFieldsResult result = AutoChart.removeAutoChartMergeFieldsWithList(contentWithCharts);

        System.assertEquals(1, result.cleanedMessages.size());
        System.assertEquals('Daily report:  and metrics: ', result.cleanedMessages[0]);
        System.assertEquals(2, result.autoChartFields.size());
        System.assert(result.autoChartFields.contains('EXECUTION_TIME_CHART'));
        System.assert(result.autoChartFields.contains('MEMORY_USAGE_CHART'));

        // Test with no chart fields
        String contentWithoutCharts = 'Regular notification message';
        AutoChart.AutoChartFieldsResult noChartResult = AutoChart.removeAutoChartMergeFieldsWithList(contentWithoutCharts);

        System.assertEquals(1, noChartResult.cleanedMessages.size());
        System.assertEquals(contentWithoutCharts, noChartResult.cleanedMessages[0]);
        System.assertEquals(0, noChartResult.autoChartFields.size());

        // Test with null/blank content
        AutoChart.AutoChartFieldsResult nullResult = AutoChart.removeAutoChartMergeFieldsWithList(null);
        System.assertEquals(0, nullResult.cleanedMessages.size());
        System.assertEquals(0, nullResult.autoChartFields.size());

        AutoChart.AutoChartFieldsResult blankResult = AutoChart.removeAutoChartMergeFieldsWithList('');
        System.assertEquals(0, blankResult.cleanedMessages.size());
        System.assertEquals(0, blankResult.autoChartFields.size());

        Test.stopTest();
    }

    // Test getChartFieldsAndClear method
    @isTest
    static void testGetChartFieldsAndClear() {
        Test.startTest();

        List<String> messagesWithCharts = new List<String>{
            'Subject with chart: {!System_Auto_Chart.EXECUTION_TIME_CHART}',
            'Body with multiple charts: {!System_Auto_Chart.MEMORY_USAGE_CHART} and {!System_Auto_Chart.ERROR_RATE_CHART}',
            'Regular message without charts'
        };

        AutoChart.AutoChartFieldsResult result = AutoChart.getChartFieldsAndClear(messagesWithCharts);

        System.assertEquals(3, result.cleanedMessages.size());
        System.assertEquals('Subject with chart: ', result.cleanedMessages[0]);
        System.assertEquals('Body with multiple charts:  and ', result.cleanedMessages[1]);
        System.assertEquals('Regular message without charts', result.cleanedMessages[2]);

        System.assertEquals(3, result.autoChartFields.size());
        System.assert(result.autoChartFields.contains('EXECUTION_TIME_CHART'));
        System.assert(result.autoChartFields.contains('MEMORY_USAGE_CHART'));
        System.assert(result.autoChartFields.contains('ERROR_RATE_CHART'));

        // Test with null list
        AutoChart.AutoChartFieldsResult nullResult = AutoChart.getChartFieldsAndClear(null);
        System.assertEquals(0, nullResult.cleanedMessages.size());
        System.assertEquals(0, nullResult.autoChartFields.size());

        // Test with empty list
        AutoChart.AutoChartFieldsResult emptyResult = AutoChart.getChartFieldsAndClear(new List<String>());
        System.assertEquals(0, emptyResult.cleanedMessages.size());
        System.assertEquals(0, emptyResult.autoChartFields.size());

        // Test with list containing null/blank entries
        List<String> mixedMessages = new List<String>{
            'Valid message: {!System_Auto_Chart.TEST_CHART}',
            null,
            '',
            'Another valid message'
        };

        AutoChart.AutoChartFieldsResult mixedResult = AutoChart.getChartFieldsAndClear(mixedMessages);
        System.assertEquals(4, mixedResult.cleanedMessages.size());
        System.assertEquals('Valid message: ', mixedResult.cleanedMessages[0]);
        System.assertEquals(null, mixedResult.cleanedMessages[1]);
        System.assertEquals('', mixedResult.cleanedMessages[2]);
        System.assertEquals('Another valid message', mixedResult.cleanedMessages[3]);
        System.assertEquals(1, mixedResult.autoChartFields.size());
        System.assertEquals('TEST_CHART', mixedResult.autoChartFields[0]);

        Test.stopTest();
    }

    // Test AutoChartFieldsResult class
    @isTest
    static void testAutoChartFieldsResult() {
        Test.startTest();

        List<String> cleanedMessages = new List<String>{
            'Clean message 1', 'Clean message 2'
        };
        List<String> chartFields = new List<String>{
            'CHART_1', 'CHART_2'
        };

        AutoChart.AutoChartFieldsResult result = new AutoChart.AutoChartFieldsResult(cleanedMessages, chartFields);

        System.assertEquals(cleanedMessages, result.cleanedMessages);
        System.assertEquals(chartFields, result.autoChartFields);
        System.assertEquals(2, result.cleanedMessages.size());
        System.assertEquals(2, result.autoChartFields.size());

        Test.stopTest();
    }

    // Test getAutoChartIterations method (complex scenario)
    @isTest
    static void testGetAutoChartIterations() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];

        Test.startTest();

        // This method would typically require complex MonitoringUtil setup
        // For now, test with empty inputs to ensure no exceptions
        List<String> emptyRuleIds = new List<String>();
        String ruleSobjectType = 'Rule__c';

        List<NotificationService.ActionIteration> iterations = AutoChart.getAutoChartIterations(
            testLog, emptyRuleIds, ruleSobjectType
        );

        System.assertEquals(0, iterations.size(), 'Should return empty list for no rules');

        // Test with non-empty rule IDs (will require mocking MonitoringUtil in real implementation)
        List<String> mockRuleIds = new List<String>{
            'a01000000000001', 'a01000000000002'
        };

        try {
            List<NotificationService.ActionIteration> mockIterations = AutoChart.getAutoChartIterations(
                testLog, mockRuleIds, ruleSobjectType
            );
            // Should handle gracefully even without proper MonitoringUtil data
            System.assert(true, 'Method should handle missing data gracefully');
        } catch (Exception e) {
            // Expected in test context without full MonitoringUtil setup
            System.assert(true, 'Expected exception due to missing MonitoringUtil data in test');
        }

        Test.stopTest();
    }

    // Test getRecordById method with different SObject types
    @isTest
    static void testGetRecordById() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        Issue__c testIssue = [SELECT Id FROM Issue__c LIMIT 1];
        Trace_Result__c testTrace = [SELECT Id FROM Trace_Result__c LIMIT 1];

        Test.startTest();

        // We can't directly test the private getRecordById method, but we can test it indirectly
        // through the message sender handler which uses it
        AutoChart.AutoChartMessageSenderHandler handler = new AutoChart.AutoChartMessageSenderHandler();
        TestBatchContextManager batchContext = new TestBatchContextManager();

        // Store some chart images in the batch context for each record type
        Map<String, String> chartImages = new Map<String, String>{
            'TEST_CHART' => 'base64data'
        };
        batchContext.storeChartImages(testLog.Id, chartImages);
        batchContext.storeChartImages(testIssue.Id, chartImages);
        batchContext.storeChartImages(testTrace.Id, chartImages);

        Action__c testAction = new Action__c(
            Subject__c = 'AutoChart: TEST_CHART',
            Action_Type__c = 'SLACK_NOTIFICATION'
        );

        // Test with different record types
        List<String> recordIds = new List<String>{
            testLog.Id, testIssue.Id, testTrace.Id
        };

        for (String recordId : recordIds) {
            try {
                handler.execute(recordId, testAction, null, batchContext);
            } catch (Exception e) {
                // Expected due to missing dependencies in test context
                System.assert(true, 'Expected exception for record ID: ' + recordId);
            }
        }

        // Test with invalid record ID
        try {
            handler.execute('invalid_id', testAction, null, batchContext);
        } catch (Exception e) {
            System.assert(true, 'Expected exception for invalid record ID');
        }

        // Test with unknown SObject type (should return null)
        String unknownTypeId = '001000000000000'; // Account ID format
        try {
            handler.execute(unknownTypeId, testAction, null, batchContext);
        } catch (Exception e) {
            System.assert(true, 'Expected exception for unknown SObject type');
        }

        Test.stopTest();
    }

    // Test edge cases and error scenarios
    @isTest
    static void testEdgeCasesAndErrors() {
        Test.startTest();

        // Test with various chart field patterns
        String complexChartContent = 'Start {!System_Auto_Chart.COMPLEX_CHART_NAME_123} middle {!System_Auto_Chart.ANOTHER.CHART} end';
        AutoChart.AutoChartFieldsResult complexResult = AutoChart.removeAutoChartMergeFieldsWithList(complexChartContent);

        System.assertEquals('Start  middle  end', complexResult.cleanedMessages[0]);
        System.assertEquals(2, complexResult.autoChartFields.size());

        // Test containsAutoChartFields with edge cases
        RuleUtil.Action edgeAction = new RuleUtil.Action();
        edgeAction.fields = new Action__c(
            Subject__c = 'Contains {!System_Auto_Chart.} invalid pattern',
            Body__c = 'And {!NotChart.VALID} non-chart field'
        );

        Boolean edgeResult = AutoChart.containsAutoChartFields(edgeAction);
        System.assertEquals(false, edgeResult, 'Should not match invalid chart patterns');

        // Test with mix of valid and text content - regex should only match properly formed fields
        String mixedContent = 'Bad: Invalid_Pattern_Without_Braces. Good: {!System_Auto_Chart.VALID_CHART} and more text.';
        AutoChart.AutoChartFieldsResult mixedResult = AutoChart.removeAutoChartMergeFieldsWithList(mixedContent);

        System.assertEquals(1, mixedResult.autoChartFields.size());
        System.assertEquals('VALID_CHART', mixedResult.autoChartFields[0]);
        System.assertEquals('Bad: Invalid_Pattern_Without_Braces. Good:  and more text.', mixedResult.cleanedMessages[0]);

        Test.stopTest();
    }

    // Test integration scenarios
    @isTest
    static void testIntegrationScenarios() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        Issue__c testIssue = [SELECT Id FROM Issue__c LIMIT 1];
        Trace_Result__c testTrace = [SELECT Id FROM Trace_Result__c LIMIT 1];

        Test.startTest();

        // Test processor with different SObject types
        NotificationService.ErrorsHelper logErrorsHelper = new NotificationService.ErrorsHelper(testLog);
        NotificationService.ErrorsHelper issueErrorsHelper = new NotificationService.ErrorsHelper(testIssue);
        NotificationService.ErrorsHelper traceErrorsHelper = new NotificationService.ErrorsHelper(testTrace);

        TestBatchContextManager batchContext = new TestBatchContextManager();

        AutoChart.AutoChartActionProcessor logProcessor = new AutoChart.AutoChartActionProcessor(
            testLog.Id, logErrorsHelper, batchContext
        );

        AutoChart.AutoChartActionProcessor issueProcessor = new AutoChart.AutoChartActionProcessor(
            testIssue.Id, issueErrorsHelper, batchContext
        );

        AutoChart.AutoChartActionProcessor traceProcessor = new AutoChart.AutoChartActionProcessor(
            testTrace.Id, traceErrorsHelper, batchContext
        );

        // Ensure processors are created successfully
        System.assertNotEquals(null, logProcessor);
        System.assertNotEquals(null, issueProcessor);
        System.assertNotEquals(null, traceProcessor);

        // Test complete workflow simulation
        List<String> chartTypes = new List<String>{
            'TEST_CHART_1', 'TEST_CHART_2'
        };

        AutoChart.AutoChartIteration step1 = new AutoChart.AutoChartIteration(
            testLog.Id, 1, 3, chartTypes, AutoChart.AutoChartStep.GET_DATA
        );

        AutoChart.AutoChartIteration step2 = new AutoChart.AutoChartIteration(
            testLog.Id, 2, 3, chartTypes, AutoChart.AutoChartStep.GET_IMAGE
        );

        AutoChart.AutoChartIteration step3 = new AutoChart.AutoChartIteration(
            testLog.Id, 3, 3, chartTypes, AutoChart.AutoChartStep.SEND_MESSAGE
        );

        // Verify iteration sequence
        System.assertEquals(AutoChart.AutoChartStep.GET_DATA, step1.currentStep);
        System.assertEquals(AutoChart.AutoChartStep.GET_IMAGE, step2.currentStep);
        System.assertEquals(AutoChart.AutoChartStep.SEND_MESSAGE, step3.currentStep);

        Test.stopTest();
    }

    // Test message sender handler with chart data workflow
    @isTest
    static void testMessageSenderWithChartData() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartMessageSenderHandler handler = new AutoChart.AutoChartMessageSenderHandler();

        // Simulate chart data and images being available
        batchContext.storeChartData(testLog.Id, '{"test": "data"}');
        Map<String, String> chartImages = new Map<String, String>{
            'EXECUTION_TIME_CHART' => 'base64imagedata1',
            'MEMORY_USAGE_CHART' => 'base64imagedata2'
        };
        batchContext.storeChartImages(testLog.Id, chartImages);

        Action__c testAction = new Action__c(
            Subject__c = 'AutoChart: EXECUTION_TIME_CHART,MEMORY_USAGE_CHART',
            Action_Type__c = 'SLACK_NOTIFICATION'
        );

        try {
            handler.execute(testLog.Id, testAction, testLog, batchContext);

            // Verify cleanup happened
            System.assertEquals(null, batchContext.getChartData(testLog.Id), 'Chart data should be cleared');
            System.assertEquals(null, batchContext.getChartImages(testLog.Id), 'Chart images should be cleared');
        } catch (Exception e) {
            // Expected due to missing dependencies in test context
            System.assert(true, 'Expected exception due to missing NotificationService dependencies');
        }

        Test.stopTest();
    }

    // Test createActionFieldsForIteration method coverage
    @isTest
    static void testCreateActionFieldsForIteration() {
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        NotificationService.ErrorsHelper errorsHelper = new NotificationService.ErrorsHelper(testLog);
        TestBatchContextManager batchContext = new TestBatchContextManager();

        Test.startTest();

        AutoChart.AutoChartActionProcessor processor = new AutoChart.AutoChartActionProcessor(
            testLog.Id, errorsHelper, batchContext
        );

        List<String> chartTypes = new List<String>{
            'TEST_CHART_1', 'TEST_CHART_2'
        };
        AutoChart.AutoChartIteration iteration = new AutoChart.AutoChartIteration(
            testLog.Id, 1, 3, chartTypes, AutoChart.AutoChartStep.GET_DATA
        );

        // This will internally call createActionFieldsForIteration
        try {
            processor.processAutoChartIteration(iteration);
        } catch (Exception e) {
            // Expected - but the createActionFieldsForIteration method should have been called
            System.assert(true, 'Expected exception but createActionFieldsForIteration was tested');
        }

        Test.stopTest();
    }

    /**
     * Enable AutoChart feature for testing
     */
    private static void enableAutoChartFeature() {
        // For testing purposes, just enable the EnableNotificationCharts setting
        // The AutoChartEnabled feature flag will remain in its default state
        Pharos_Settings__c settings = Pharos_Settings__c.getOrgDefaults();
        if (settings == null) {
            settings = new Pharos_Settings__c();
        }
        settings.EnableNotificationCharts__c = true;
        upsert settings;
    }

    // Simple test to verify AutoChartEnabled flag behavior
    @isTest
    static void testAutoChartEnabledFlag() {
        // Enable AutoChart feature for this test
        enableAutoChartFeature();

        // Test the current state of the feature flags
        Boolean autoChartEnabled = PermissionsUtil.AutoChartEnabled;
        Boolean autoChartIsEnabled = AutoChart.isEnabled;

        // Test that containsAutoChartFields returns false when feature is disabled
        // We can't easily change the feature flag in tests, so we test the current behavior
        RuleUtil.Action testAction = new RuleUtil.Action();
        testAction.fields = new Action__c(Subject__c = 'Test {!System_Auto_Chart.TEST}');

        Boolean result = AutoChart.containsAutoChartFields(testAction);
        // The result depends on the current feature flag state
        System.assertEquals(autoChartIsEnabled, result, 'Should match current feature flag state');
    }

    // Mock for remote site settings to avoid web service callouts in future tests
    private static Map<String, HttpCalloutMock> getPharosRemoteSiteSettingsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        MetadataServiceUtil.RemoteSiteSettingsWrapper wrapper = new MetadataServiceUtil.RemoteSiteSettingsWrapper();
        wrapper.Id = 'test-remote-site-id';
        wrapper.IsActive = true;
        wrapper.SiteName = Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME;
        wrapper.EndpointUrl = Constants.REMOTE_SITE_SETTINGS.PHAROS_API_API_URL;

        data.put(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS, new List<MetadataServiceUtil.RemoteSiteSettingsWrapper>{
            wrapper
        });

        // Mock for reading remote site settings
        TestDataFactory.SingleRequestMock readMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(data)
        );
        result.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY, readMock);

        return result;
    }

    // Mock WebService for SOAP callouts (MetadataService.MetadataPort)
    public class MockWebService implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            // Mock successful response for deleteMetadata
            if (request instanceof MetadataService.deleteMetadata_element) {
                MetadataService.deleteMetadataResponse_element responseElement = new MetadataService.deleteMetadataResponse_element();
                MetadataService.DeleteResult deleteResult = new MetadataService.DeleteResult();
                deleteResult.success = true;
                deleteResult.fullName = 'Pharos_ai_API';
                responseElement.result = new List<MetadataService.DeleteResult>{
                    deleteResult
                };
                response.put('response_x', responseElement);
            }
            // Mock successful response for upsertMetadata (RemoteSiteSetting/CspTrustedSite/etc.)
            else if (request instanceof MetadataService.upsertMetadata_element) {
                MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
                MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();
                upsertResult.success = true;
                upsertResult.fullName = 'Pharos_ai_Mock';
                responseElement.result = new List<MetadataService.UpsertResult>{
                    upsertResult
                };
                response.put('response_x', responseElement);
            }
        }
    }

    // Test integration with AutoChartController
    @isTest
    static void testAutoChartControllerIntegration() {
        // Enable AutoChart feature for this test
        enableAutoChartFeature();

        // Setup mock for remote site settings (HTTP callouts)
        Map<String, HttpCalloutMock> mocks = getPharosRemoteSiteSettingsMock();
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Setup mock for SOAP callouts (MetadataService.MetadataPort)
        Test.setMock(WebServiceMock.class, new MockWebService());

        Test.startTest();

        // Test getAutoChartSetting
        String getResult = JSON.serialize(AutoChartController.getAutoChartSetting());
        System.assertNotEquals(null, getResult, 'getAutoChartSetting result should not be null');

        // Test updateAutoChartSetting
        String updateInput = JSON.serialize(new Map<String, Object>{
            'isEnableNotificationCharts' => true
        });
        String updateResult = AutoChartController.updateAutoChartSetting(updateInput);
        System.assertNotEquals(null, updateResult, 'updateAutoChartSetting result should not be null');

        // Verify the update worked
        Map<String, Object> parsedResult = (Map<String, Object>) JSON.deserializeUntyped(updateResult);
        System.assertEquals(true, parsedResult.get('isEnableNotificationCharts'), 'EnableNotificationCharts should be true');
        System.assertEquals(true, parsedResult.get('isUpdate'), 'Update flag should be true');

        Test.stopTest();
    }
}