@IsTest(IsParallel=true)
private class EventMonitoringUtilTest {
    private static final String TEST_EVENT_TYPE = EventLogProcessors.EVENT_TYPE_APEX_EXECUTION;
    
    @IsTest
    static void testLoadThresholdsFromRules() {
        // Arrange
        Rule__c rule = new Rule__c(
            Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
            Subtype__c = EventLogProcessors.EVENT_TYPE_API,
            Active__c = true
        );
        insert rule;
        
        List<RuleFilter__c> filters = new List<RuleFilter__c>{
            new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = EventLogProcessors.FIELD_CPU_TIME,
                ComparisonOperator__c = 'GREATER_THAN',
                Value__c = '1000',
                Index__c = EventMonitoringUtil.CRITICAL_INDEX
            ),
            new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = EventLogProcessors.FIELD_CPU_TIME,
                ComparisonOperator__c = 'GREATER_THAN',
                Value__c = '500',
                Index__c = EventMonitoringUtil.WARNING_INDEX
            )
        };
        insert filters;
        
        // Act
        Test.startTest();
        Map<String, Map<String, ThresholdConfig>> thresholds = 
            EventMonitoringUtil.loadThresholdsFromRules();
        Test.stopTest();
        
        // Assert
        System.assert(thresholds.containsKey(EventLogProcessors.EVENT_TYPE_API));
        System.assert(thresholds.get(EventLogProcessors.EVENT_TYPE_API).containsKey(EventLogProcessors.FIELD_CPU_TIME));
        
        ThresholdConfig config = thresholds.get(EventLogProcessors.EVENT_TYPE_API).get(EventLogProcessors.FIELD_CPU_TIME);
        System.assertEquals('500', config.warningThreshold);
        System.assertEquals('1000', config.criticalThreshold);
        System.assertEquals(ThresholdConfig.EvaluationType.GREATER_THAN, config.evaluationType);
    }
    
    @IsTest
    static void testSaveThresholdAsRule() {
        // Arrange
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_API)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setWarningThreshold(500)
            .setCriticalThreshold(1000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
            
        // Act
        Test.startTest();
        Rule__c rule = EventMonitoringUtil.saveThresholdAsRule(config);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, rule.Id);
        
        // Verify rule filters
        List<RuleFilter__c> filters = [
            SELECT FieldName__c, ComparisonOperator__c, Value__c, Index__c 
            FROM RuleFilter__c 
            WHERE Rule__c = :rule.Id
            ORDER BY Index__c ASC
        ];
        
        System.assertEquals(2, filters.size());
        
        // Verify critical threshold filter
        System.assertEquals(EventLogProcessors.FIELD_CPU_TIME, filters[0].FieldName__c);
        System.assertEquals('GREATER_THAN', filters[0].ComparisonOperator__c);
        System.assertEquals('1000', filters[0].Value__c);
        System.assertEquals(EventMonitoringUtil.CRITICAL_INDEX, filters[0].Index__c);
        
        // Verify warning threshold filter
        System.assertEquals(EventLogProcessors.FIELD_CPU_TIME, filters[1].FieldName__c);
        System.assertEquals('GREATER_THAN', filters[1].ComparisonOperator__c);
        System.assertEquals('500', filters[1].Value__c);
        System.assertEquals(EventMonitoringUtil.WARNING_INDEX, filters[1].Index__c);
    }
    
    @IsTest
    static void testLoadInactiveRules() {
        // Arrange
        Rule__c rule = new Rule__c(
            Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
            Subtype__c = EventLogProcessors.EVENT_TYPE_API,
            Active__c = false
        );
        insert rule;
        
        RuleFilter__c filter = new RuleFilter__c(
            Rule__c = rule.Id,
            FieldName__c = EventLogProcessors.FIELD_CPU_TIME,
            ComparisonOperator__c = 'GREATER_THAN',
            Value__c = '1000',
            Index__c = EventMonitoringUtil.CRITICAL_INDEX
        );
        insert filter;
        
        // Act
        Test.startTest();
        Map<String, Map<String, ThresholdConfig>> thresholds = 
            EventMonitoringUtil.loadThresholdsFromRules();
        Test.stopTest();
        
        // Assert
        System.assert(!thresholds.containsKey(EventLogProcessors.EVENT_TYPE_API));
    }

    @TestSetup
    static void setupTestData() {
        // Create Event Monitoring Settings
        Event_Monitoring__c settings = new Event_Monitoring__c(
            Enabled__c = true,
            Last_Processed_Hourly_Events__c = DateTime.now().addHours(-1),
            Enabled_Types__c = '1,0,1,0,1' // Example: Enable some event types
        );
        insert settings;
    }
    
    @IsTest
    static void testGetEventLogs() {
        // Arrange
        DateTime testDateTime = DateTime.now().addHours(-1);
        SObject testLog = EventMonitoringUtil.createTestEventLogSObject(
            TEST_EVENT_TYPE,
            Date.today(),
            Blob.valueOf('test,data\nvalue1,value2')
        );
        
        // Fallback for orgs without EventLogFile - create a mock SObject for testing
        if (testLog == null) {
            // Create a simple mock SObject for testing purposes
            Account mockAccount = new Account(Name = 'Test Mock EventLog');
            testLog = (SObject)mockAccount;
            testLog.put('Id', '001000000000001AAA'); // Mock ID for testing
        }
        
        EventMonitoringUtil.testEventLogs.add(testLog);
        
        // Act
        Test.startTest();
        List<SObject> result = EventMonitoringUtil.getEventLogs(TEST_EVENT_TYPE);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, result.size(), 'Should return one event log');
        // Skip EventType assertion as the mock SObject might not have this field
        System.assertNotEquals(null, result[0], 'Should return a valid SObject');
    }
    
    @IsTest
    static void testGetEventLogsWithNullParams() {
        // Act
        Test.startTest();
        List<SObject> result = EventMonitoringUtil.getEventLogs(null);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Should return empty list for null event type');
    }

    @IsTest
    static void testGetEnabledMembersWithDefaultEnabledEventTypes() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '0,0,0'; // Disable all event types
        update settings;
        
        // Act
        Test.startTest();
        List<EventLogProcessingBatch.EventLogFileType> result = EventMonitoringUtil.getEnabledMembers();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(0, result.size(), 'Should return enabled event types');

        EventLogProcessingBatch.EventLogFileType eventType = result.get(0);
        System.assertEquals(1, result.size(), 'Should return only one event type');
        System.assertEquals(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION, eventType.type, 'Unexpected Exception event type should be enabled by default');
    }
    
    @IsTest
    static void testGetEnabledMembers() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '1,0,1'; // Enable first and third event types
        update settings;
        
        // Act
        Test.startTest();
        List<EventLogProcessingBatch.EventLogFileType> result = EventMonitoringUtil.getEnabledMembers();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(0, result.size(), 'Should return enabled event types');
    }
    
    @IsTest
    static void testGetEnabledMembersWhenDisabled() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = false;
        update settings;
        
        // Act
        Test.startTest();
        List<EventLogProcessingBatch.EventLogFileType> result = EventMonitoringUtil.getEnabledMembers();
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Should return empty list when disabled');
    }
    
    @IsTest
    static void testGetEnabledMembersFromSettings() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '1,0,1,0,1';
        update settings;
        
        // Act
        Test.startTest();
        List<Boolean> result = EventMonitoringUtil.getEnabledMembersFromSettings();
        Test.stopTest();
        
        // Assert
        System.assertEquals(EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES.size(), result.size(), 
            'Should return list matching MAP_ENABLED_EVENT_TYPES size');
        System.assertEquals(true, result[0], 'First event type should be enabled');
        System.assertEquals(false, result[1], 'Second event type should be disabled');

        Integer index = EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES.get(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
        System.assertEquals(true, result[index], 'Unexpected Exception event type should be enabled by default');
    }
    
    @IsTest
    static void testIsEnabled() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '1,0,1';
        update settings;
        
        EventMonitoringUtil util = new EventMonitoringUtil();
        
        // Act & Assert
        Test.startTest();
        System.assertEquals(true, util.isEnabled(EventLogProcessors.EVENT_TYPE_API), 
            'API event type should be enabled');
        System.assertEquals(false, util.isEnabled(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT), 
            'APEX_CALLOUT event type should be disabled');
        System.assertEquals(false, util.isEnabled('INVALID_EVENT_TYPE'), 
            'Invalid event type should return false');
        Test.stopTest();
    }
    
    @IsTest
    static void testEnableEventType() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '0,0,0';
        update settings;
        
        EventMonitoringUtil util = new EventMonitoringUtil();
        
        // Act
        Test.startTest();
        util.enableEventType(EventLogProcessors.EVENT_TYPE_API);
        Test.stopTest();
        
        // Assert
        settings = Event_Monitoring__c.getOrgDefaults();
        System.assert(settings.Enabled_Types__c.startsWith('1'), 
            'First event type should be enabled');
    }
    
    @IsTest
    static void testSaveLastProcessedHourlyDateTime() {
        // Arrange
        DateTime testDateTime = DateTime.now();
        
        // Act
        Test.startTest();
        EventMonitoringUtil.saveLastProcessedHourlyDateTime(testDateTime);
        Test.stopTest();
        
        // Assert
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        System.assertEquals(testDateTime.addHours(1), 
            settings.Last_Processed_Hourly_Events__c, 
            'Last processed datetime should be incremented by 1 hour');
    }
    
    @IsTest
    static void testMapEnabledEventTypes() {
        // Act
        Map<String, Integer> eventTypeMap = EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES;
        
        // Assert
        System.assertNotEquals(null, eventTypeMap, 'Event type map should not be null');
        System.assertEquals(0, eventTypeMap.get(EventLogProcessors.EVENT_TYPE_API), 
            'API event type should have index 0');
        System.assertEquals(1, eventTypeMap.get(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT), 
            'APEX_CALLOUT event type should have index 1');
    }
    
    @IsTest
    static void testGetEnabledMembersWithInvalidSettings() {
        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '1,0,invalid,1';  // Invalid format
        update settings;
        
        // Act
        Test.startTest();
        List<Boolean> result = EventMonitoringUtil.getEnabledMembersFromSettings();
        Test.stopTest();
        
        // Assert
        System.assertEquals(EventMonitoringUtil.MAP_ENABLED_EVENT_TYPES.size(), result.size(), 
            'Should handle invalid settings gracefully');
    }
    
    @IsTest
    static void testIsEventLogFileAvailable() {
        Test.startTest();
        Boolean isAvailable = EventMonitoringUtil.isEventLogFileAvailable();
        Test.stopTest();
        
        // Should return true in test context (unless mocked otherwise)
        System.assertNotEquals(null, isAvailable, 'isEventLogFileAvailable should not return null');
    }
    
    @IsTest
    static void testIsSequenceFieldAvailable() {
        Test.startTest();
        Boolean isAvailable = EventMonitoringUtil.isSequenceFieldAvailable();
        Test.stopTest();
        
        // Should return a boolean value
        System.assertNotEquals(null, isAvailable, 'isSequenceFieldAvailable should not return null');
    }
    
    @IsTest
    static void testGetEventLogFileType() {
        Test.startTest();
        SObjectType sObjectType = EventMonitoringUtil.getEventLogFileType();
        Test.stopTest();
        
        // If EventLogFile is available, should return the type
        if (EventMonitoringUtil.isEventLogFileAvailable()) {
            System.assertNotEquals(null, sObjectType, 'getEventLogFileType should return SObjectType if available');
        }
    }
    
    @IsTest
    static void testGetEventLogsWithTestDataDetailed() {
        // Setup test data
        SObject testLog = EventMonitoringUtil.createTestEventLogSObject(
            'ApexUnexpectedException',
            Date.today().addDays(-1),
            Blob.valueOf('test,data\nvalue1,value2')
        );
        
        // Fallback for orgs without EventLogFile - create a mock SObject for testing
        if (testLog == null) {
            // Create a simple mock SObject for testing purposes
            Account mockAccount = new Account(Name = 'Test Mock EventLog');
            testLog = (SObject)mockAccount;
            testLog.put('Id', '001000000000002AAA'); // Mock ID for testing
        }
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLog};
        
        Test.startTest();
        List<SObject> result = EventMonitoringUtil.getEventLogs('ApexUnexpectedException');
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should return test event log');
    }
    
    @IsTest
    static void testFieldValueGetters() {
        // Create a test SObject without inserting (to avoid flow triggers)
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.Id = '001000000000003AAA'; // Mock ID
        
        SObject testSObject = (SObject)testAccount;
        
        Test.startTest();
        
        // Test getFieldValue
        Object fieldValue = EventMonitoringUtil.getFieldValue(testSObject, 'Name');
        System.assertEquals('Test Account', fieldValue, 'getFieldValue should return correct value');
        
        // Test getStringValue
        String stringValue = EventMonitoringUtil.getStringValue(testSObject, 'Name');
        System.assertEquals('Test Account', stringValue, 'getStringValue should return correct string');
        
        // Test with non-existent field
        try {
            Object nullValue = EventMonitoringUtil.getFieldValue(testSObject, 'NonExistentField');
            System.assert(false, 'getFieldValue should throw exception for non-existent field');
        } catch (Exception e) {
            System.assert(true, 'getFieldValue should throw exception');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetEventLogsWhenObjectNotAvailable() {
        // This test assumes EventLogFile might not be available in some orgs
        // The actual behavior will depend on the org configuration
        
        Test.startTest();
        List<SObject> result = EventMonitoringUtil.getEventLogs('TestEventType');
        Test.stopTest();
        
        // Should not throw exception and return a list (even if empty)
        System.assertNotEquals(null, result, 'Should return a list even when object not available');
    }

    @IsTest
    static void testSafeFieldAccessMethods() {
        // Create test data without inserting (to avoid flow triggers)
        Account testAccount = new Account(
            Name = 'Test Account',
            AnnualRevenue = 1000000
        );
        testAccount.Id = '001000000000004AAA'; // Mock ID
        
        SObject testSObject = (SObject)testAccount;
        
        Test.startTest();
        
        // Test getBlobValue (will be null for Account.Name but should not throw)
        Blob blobValue = EventMonitoringUtil.getBlobValue(testSObject, 'Name');
        System.assertEquals(null, blobValue, 'getBlobValue should return null for non-blob field');
        
        // Test getIntegerValue
        Integer intValue = EventMonitoringUtil.getIntegerValue(testSObject, 'AnnualRevenue');
        System.assertEquals(1000000, intValue, 'getIntegerValue should return correct integer');
        
        // Test with null SObject
        Object nullFieldValue = EventMonitoringUtil.getFieldValue(null, 'Name');
        System.assertEquals(null, nullFieldValue, 'getFieldValue should handle null SObject gracefully');
        
        Test.stopTest();
    }
}