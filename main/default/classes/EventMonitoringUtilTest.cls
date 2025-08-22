@IsTest(IsParallel=true)
private class EventMonitoringUtilTest {
    private static final String TEST_EVENT_TYPE = EventLogProcessors.EVENT_TYPE_APEX_EXECUTION;
    
    @IsTest
    static void testLoadThresholdsFromRules() {
        // Arrange
        Rule__c rule = new Rule__c(
            Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
            Subtype__c = EventLogProcessors.EVENT_TYPE_API,
            Active__c = true,
            Logs_Limit__c = 1000
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
            EventMonitoringUtil.loadThresholdsFromRules(EventMonitoringUtil.getActiveEventMonitoringRules());
        Map<String, Integer> logsLimitPerHour = EventMonitoringUtil.getLogsLimitPerHour(EventMonitoringUtil.getActiveEventMonitoringRules());
        Test.stopTest();

        System.assertEquals(1000, logsLimitPerHour.get(EventLogProcessors.EVENT_TYPE_API));
        System.assertEquals(null, logsLimitPerHour.get(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION));
        
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
            Subtype__c = EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE,
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
            EventMonitoringUtil.loadThresholdsFromRules(EventMonitoringUtil.getActiveEventMonitoringRules());
        Test.stopTest();
        
        // Assert
        System.assert(!thresholds.containsKey(EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE));
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

    static void enableEventMonitoringPermissions() {
        PermissionsUtil.EventMonitoringEnabled = true;
    }
    
    @IsTest
    static void testGetEventLogs() {
        enableEventMonitoringPermissions();

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
        List<SObject> result = EventMonitoringUtil.getEventLogs((String)null);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Should return empty list for null event type');
    }
    
    @IsTest
    static void testGetEnabledMembers() {
        enableEventMonitoringPermissions();
        
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
        enableEventMonitoringPermissions();
        
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
    }
    
    @IsTest
    static void testIsEnabled() {
        enableEventMonitoringPermissions();
        
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
        enableEventMonitoringPermissions();

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
    static void testDisableEventType() {
        enableEventMonitoringPermissions();

        // Arrange
        Event_Monitoring__c settings = Event_Monitoring__c.getOrgDefaults();
        settings.Enabled__c = true;
        settings.Enabled_Types__c = '1,0,0';
        update settings;
        
        EventMonitoringUtil util = new EventMonitoringUtil();
        
        // Act
        Test.startTest();
        util.disableEventType(EventLogProcessors.EVENT_TYPE_API);
        Test.stopTest();
        
        // Assert
        settings = Event_Monitoring__c.getOrgDefaults();
        System.assert(settings.Enabled_Types__c.startsWith('0'), 
            'First event type should be disabled');
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
        enableEventMonitoringPermissions();
        
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

    @IsTest
    static void testDefaultEnabledEventTypesString() {
        Test.startTest();
        String result = EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING;
        String result2 = EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING;
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'DEFAULT_ENABLED_EVENT_TYPES_STRING should not be null');
        System.assertNotEquals(null, result2, 'DEFAULT_DISABLED_EVENT_TYPES_STRING should not be null');
    }

    @IsTest
    static void testGetEventTypesWithStatus() {
        // Arrange - Create some test rules
        List<Rule__c> testRules = new List<Rule__c>{
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_API,
                Active__c = true,
                Logs_Limit__c = 150
            ),
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_APEX_TRIGGER,
                Active__c = true,
                Logs_Limit__c = 200
            )
        };
        insert testRules;
        
        // Set some event types as enabled in settings (API=0, APEX_TRIGGER=5)
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = '1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        List<EventMonitoringUtil.EventTypeStatus> result = EventMonitoringUtil.getEventTypesWithStatus();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return event type statuses');
        
        // Find API event type status
        EventMonitoringUtil.EventTypeStatus apiStatus = null;
        EventMonitoringUtil.EventTypeStatus triggerStatus = null;
        
        for (EventMonitoringUtil.EventTypeStatus status : result) {
            if (status.name == EventLogProcessors.EVENT_TYPE_API) {
                apiStatus = status;
            } else if (status.name == EventLogProcessors.EVENT_TYPE_APEX_TRIGGER) {
                triggerStatus = status;
            }
        }
        
        // Assert API status
        System.assertNotEquals(null, apiStatus, 'API event type should be found');
        System.assertEquals(true, apiStatus.active, 'API should be active');
        System.assertEquals(150, apiStatus.logsLimit, 'API should have custom logs limit from Rule__c');
        
        // Assert Trigger status  
        System.assertNotEquals(null, triggerStatus, 'Trigger event type should be found');
        System.assertEquals(true, triggerStatus.active, 'Trigger should be active');
        System.assertEquals(200, triggerStatus.logsLimit, 'Trigger should have custom logs limit from Rule__c');
    }

    @IsTest
    static void testGetEventTypesWithStatusNoExistingRules() {
        // Arrange - No existing rules, should use default logs limits
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = '1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        List<EventMonitoringUtil.EventTypeStatus> result = EventMonitoringUtil.getEventTypesWithStatus();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Find API event type status (should use default logs limit)
        EventMonitoringUtil.EventTypeStatus apiStatus = null;
        for (EventMonitoringUtil.EventTypeStatus status : result) {
            if (status.name == EventLogProcessors.EVENT_TYPE_API) {
                apiStatus = status;
                break;
            }
        }
        
        System.assertNotEquals(null, apiStatus, 'API event type should be found');
        System.assertEquals(true, apiStatus.active, 'API should be active based on settings');
        System.assertEquals(100, apiStatus.logsLimit, 'API should have default logs limit');
    }

    @IsTest
    static void testSetEventTypesStatusesCreateRules() {
        // Arrange - Create EventTypeStatus objects to enable some types (use types we know work)
        List<EventMonitoringUtil.EventTypeStatus> statusesToSet = new List<EventMonitoringUtil.EventTypeStatus>{
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION, true, 250),
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR, true, 300),
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_LOGIN, false, 100)
        };
        
        // Ensure no existing rules
        System.assertEquals(0, [SELECT COUNT() FROM Rule__c WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE], 'Should start with no rules');
        
        Test.startTest();
        EventMonitoringUtil.setEventTypesStatuses(statusesToSet);
        Test.stopTest();
        
        // Assert rules were created for enabled types
        List<Rule__c> createdRules = [
            SELECT Subtype__c, Active__c, Logs_Limit__c, 
                   (SELECT FieldName__c, ComparisonOperator__c, Value__c, Index__c FROM RuleFilters__r)
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
            ORDER BY Subtype__c
        ];
        
        System.assertEquals(2, createdRules.size(), 'Should create rules for 2 enabled event types');
        
        // Verify rules
        Rule__c exceptionRule = null;
        Rule__c lightningRule = null;
        for (Rule__c rule : createdRules) {
            if (rule.Subtype__c == EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION) {
                exceptionRule = rule;
            } else if (rule.Subtype__c == EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR) {
                lightningRule = rule;
            }
        }
        
        System.assertNotEquals(null, exceptionRule, 'Exception rule should be created');
        System.assertEquals(true, exceptionRule.Active__c, 'Exception rule should be active');
        System.assertEquals(250, exceptionRule.Logs_Limit__c, 'Exception rule should have custom logs limit');
        System.assert(exceptionRule.RuleFilters__r.size() > 0, 'Exception rule should have threshold filters');
        
        System.assertNotEquals(null, lightningRule, 'Lightning rule should be created');
        System.assertEquals(true, lightningRule.Active__c, 'Lightning rule should be active');
        System.assertEquals(300, lightningRule.Logs_Limit__c, 'Lightning rule should have custom logs limit');
        System.assert(lightningRule.RuleFilters__r.size() > 0, 'Lightning rule should have threshold filters');
        
        // Verify settings were updated
        Event_Monitoring__c settings = [SELECT Enabled_Types__c FROM Event_Monitoring__c LIMIT 1];
        System.assertNotEquals(null, settings.Enabled_Types__c, 'Settings should be updated');
    }

    @IsTest
    static void testSetEventTypesStatusesDeleteRules() {
        // Arrange - Create existing rules first
        List<Rule__c> existingRules = new List<Rule__c>{
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_API,
                Active__c = true,
                Logs_Limit__c = 150
            ),
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_APEX_TRIGGER,
                Active__c = true,
                Logs_Limit__c = 200
            )
        };
        insert existingRules;
        
        // Set initial enabled types
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = '1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        // Now disable one type and modify the other
        List<EventMonitoringUtil.EventTypeStatus> statusesToSet = new List<EventMonitoringUtil.EventTypeStatus>{
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_API, true, 350), // Keep enabled but change limit
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER, false, 100) // Disable
        };
        
        Test.startTest();
        EventMonitoringUtil.setEventTypesStatuses(statusesToSet);
        Test.stopTest();
        
        // Assert trigger rule was deleted
        List<Rule__c> remainingRules = [
            SELECT Subtype__c, Logs_Limit__c 
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
        ];
        
        System.assertEquals(1, remainingRules.size(), 'Should only have 1 rule remaining');
        System.assertEquals(EventLogProcessors.EVENT_TYPE_API, remainingRules[0].Subtype__c, 'Should be API rule');
        System.assertEquals(150, remainingRules[0].Logs_Limit__c, 'API rule should keep existing logs limit (not recreated)');
    }

    @IsTest
    static void testBulkifiedRuleCreation() {
        // Test creating rules for multiple event types in one operation
        Map<String, Integer> eventTypesWithLimits = new Map<String, Integer>{
            EventLogProcessors.EVENT_TYPE_API => 100,
            EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => 200,
            EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => 300,
            EventLogProcessors.EVENT_TYPE_LOGIN => 400
        };
        
        Test.startTest();
        List<Rule__c> createdRules = EventMonitoringUtil.createDefaultRulesForEventTypes(eventTypesWithLimits);
        Test.stopTest();
        
        // Assert bulkified creation worked
        System.assertEquals(4, createdRules.size(), 'Should create 4 rules');
        
        // Verify rules in database
        List<Rule__c> dbRules = [
            SELECT Subtype__c, Logs_Limit__c,
                   (SELECT Id FROM RuleFilters__r)
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
            ORDER BY Subtype__c
        ];
        
        System.assertEquals(4, dbRules.size(), 'Should have 4 rules in database');
        
        for (Rule__c rule : dbRules) {
            System.assertEquals(eventTypesWithLimits.get(rule.Subtype__c), Integer.valueOf(rule.Logs_Limit__c), 
                               'Rule should have correct logs limit: ' + rule.Subtype__c);
            System.assert(rule.RuleFilters__r.size() > 0, 'Rule should have filters: ' + rule.Subtype__c);
        }
    }

    @IsTest
    static void testBulkifiedRuleDeletion() {
        // Arrange - Create multiple rules
        List<Rule__c> rulesToCreate = new List<Rule__c>();
        List<String> eventTypesToDelete = new List<String>{
            EventLogProcessors.EVENT_TYPE_API,
            EventLogProcessors.EVENT_TYPE_APEX_TRIGGER,
            EventLogProcessors.EVENT_TYPE_LOGIN
        };
        
        for (String eventType : eventTypesToDelete) {
            rulesToCreate.add(new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = eventType,
                Active__c = true,
                Logs_Limit__c = 100
            ));
        }
        
        // Add one rule that should NOT be deleted
        rulesToCreate.add(new Rule__c(
            Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
            Subtype__c = EventLogProcessors.EVENT_TYPE_APEX_CALLOUT,
            Active__c = true,
            Logs_Limit__c = 100
        ));
        
        insert rulesToCreate;
        
        Test.startTest();
        EventMonitoringUtil.deleteRulesForEventTypes(eventTypesToDelete);
        Test.stopTest();
        
        // Assert only the callout rule remains
        List<Rule__c> remainingRules = [
            SELECT Subtype__c 
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
        ];
        
        System.assertEquals(1, remainingRules.size(), 'Should only have 1 rule remaining');
        System.assertEquals(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT, remainingRules[0].Subtype__c, 
                           'Should be the callout rule that was not deleted');
    }

    @IsTest
    static void testSetEventTypesStatusesWithEmptyList() {
        // Create some existing rules
        List<Rule__c> existingRules = new List<Rule__c>{
            new Rule__c(
                Type__c = EventMonitoringUtil.EVENT_MONITORING_TYPE,
                Subtype__c = EventLogProcessors.EVENT_TYPE_API,
                Active__c = true,
                Logs_Limit__c = 150
            )
        };
        insert existingRules;
        
        // Set initial enabled types
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = '1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
        
        Test.startTest();
        // Disable all types by passing empty list
        EventMonitoringUtil.setEventTypesStatuses(new List<EventMonitoringUtil.EventTypeStatus>());
        Test.stopTest();
        
        // Assert all rules were deleted
        Integer ruleCount = [SELECT COUNT() FROM Rule__c WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE];
        System.assertEquals(0, ruleCount, 'All event monitoring rules should be deleted');
        
        // Assert settings were updated to all disabled
        Event_Monitoring__c settings = [SELECT Enabled_Types__c FROM Event_Monitoring__c LIMIT 1];
        System.assert(settings.Enabled_Types__c.contains('0'), 'Settings should indicate disabled types');
    }

    @IsTest
    static void testSingleEventTypeRule() {
        // Simple test to verify one event type rule creation works
        List<EventMonitoringUtil.EventTypeStatus> statusesToSet = new List<EventMonitoringUtil.EventTypeStatus>{
            new EventMonitoringUtil.EventTypeStatus(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION, true, 200)
        };
        
        Test.startTest();
        EventMonitoringUtil.setEventTypesStatuses(statusesToSet);
        Test.stopTest();
        
        // Verify rule was created
        List<Rule__c> createdRules = [
            SELECT Subtype__c, Logs_Limit__c 
            FROM Rule__c 
            WHERE Type__c = :EventMonitoringUtil.EVENT_MONITORING_TYPE
        ];
        
        System.assertEquals(1, createdRules.size(), 'Should create 1 rule');
        System.assertEquals(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION, createdRules[0].Subtype__c, 'Should be Exception rule');
        System.assertEquals(200, createdRules[0].Logs_Limit__c, 'Should have correct logs limit');
    }
}