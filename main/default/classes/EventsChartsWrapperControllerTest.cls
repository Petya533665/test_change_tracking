@IsTest
public with sharing class EventsChartsWrapperControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create Rule for Spike subtype manually to avoid caching issues
        Rule__c rule = new Rule__c();
        rule.Active__c = true;
        rule.Is_Not_Valid__c = false;
        rule.Index__c = 0;
        rule.Type__c = 'Monitoring';
        rule.Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_SPIKE;
        rule.Threshold__c = 10;
        rule.EventTimeInterval__c = 60;
        rule.AggregateInterval__c = 60;
        rule.AggregateType__c = 'Count';
        rule.ComparisonOperator__c = 'Greater or equal';
        rule.FilterLogic__c = '1';
        insert rule;
        
        // Create RuleFilter for Spike rule
        RuleFilter__c ruleFilter = new RuleFilter__c();
        ruleFilter.Rule__c = rule.Id;
        ruleFilter.Index__c = 1;
        ruleFilter.FieldName__c = ConfigUtil.nameSpacePrefix + 'Type__c';
        ruleFilter.ComparisonOperator__c = 'Not equal';
        ruleFilter.Value__c = 'notTestType';
        ruleFilter.Comparison_Type__c = 'Value';
        insert ruleFilter;
        
        // Create Rule for Impact subtype manually to avoid caching issues
        Rule__c impactRule = new Rule__c();
        impactRule.Active__c = true;
        impactRule.Is_Not_Valid__c = false;
        impactRule.Index__c = 1;
        impactRule.Type__c = 'Monitoring';
        impactRule.Subtype__c = Constants.RULE_SOBJECT.SUB_TYPE_IMPACT;
        impactRule.Threshold__c = 1;
        impactRule.EventTimeInterval__c = 30;
        impactRule.AggregateInterval__c = 30;
        impactRule.AggregateType__c = 'Count';
        impactRule.ComparisonOperator__c = 'Greater or equal';
        impactRule.FilterLogic__c = '2';
        insert impactRule;
        
        // Create RuleFilter for Impact rule (Field type for grouping)
        RuleFilter__c impactFilterField = new RuleFilter__c();
        impactFilterField.Rule__c = impactRule.Id;
        impactFilterField.Index__c = 1;
        impactFilterField.FieldName__c = ConfigUtil.nameSpacePrefix + 'Hash_1__c';
        impactFilterField.ComparisonOperator__c = 'Equal';
        impactFilterField.Value__c = '1';
        impactFilterField.Comparison_Type__c = 'Field';
        impactFilterField.Field_Type__c = 'STRING';
        insert impactFilterField;
        
        // Create RuleFilter for Impact rule (Value type for filtering)
        RuleFilter__c impactFilterValue = new RuleFilter__c();
        impactFilterValue.Rule__c = impactRule.Id;
        impactFilterValue.Index__c = 2;
        impactFilterValue.FieldName__c = ConfigUtil.nameSpacePrefix + 'Type__c';
        impactFilterValue.ComparisonOperator__c = 'Equal';
        impactFilterValue.Value__c = 'ERROR';
        impactFilterValue.Comparison_Type__c = 'Value';
        insert impactFilterValue;
        
        // Create Logs for timing and chart data
        // Use time around now so Events can find them
        List<Log__c> logs = new List<Log__c>();
        DateTime baseTime = DateTime.now().addMinutes(-30); // 30 minutes ago
        for (Integer i = 0; i < 10; i++) {
            Log__c log = new Log__c();
            log.Type__c = 'ERROR';
            log.Category__c = 'Apex';
            log.Summary__c = 'Test Error ' + i;
            log.Hash_1__c = 'hash' + i;
            log.Created_At__c = baseTime.addMinutes(i * 5);
            logs.add(log);
        }
        insert logs;
        
        // Create Event with Map format for Records__c using real log IDs
        Map<String, List<Id>> recordsMap = new Map<String, List<Id>>();
        List<Id> logIds = new List<Id>();
        for (Integer i = 0; i < 3 && i < logs.size(); i++) {
            logIds.add(logs[i].Id);
        }
        recordsMap.put('Log__c', logIds);
        
        // Create Event for Spike rule with time matching logs
        Event__c event = new Event__c();
        event.Rule__c = rule.Id;
        event.Records__c = JSON.serialize(recordsMap);
        insert event;
        
        // Update CreatedDate to match log timeframe (middle of log range)
        Test.setCreatedDate(event.Id, baseTime.addMinutes(25));
        
        // Create Event for Impact rule with time matching logs
        Event__c impactEvent = new Event__c();
        impactEvent.Rule__c = impactRule.Id;
        impactEvent.Records__c = JSON.serialize(recordsMap);
        insert impactEvent;
        
        // Update CreatedDate to match log timeframe
        Test.setCreatedDate(impactEvent.Id, baseTime.addMinutes(25));
    }
    
    @IsTest
    static void test_constructor_withDevParameter() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];
        
        PageReference pageRef = Page.EventsChartsWrapper;
        pageRef.getParameters().put('recordId', event.Id);
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(event);
        EventsChartsWrapperController controller = new EventsChartsWrapperController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev parameter is set');
        Assert.areNotEqual(null, controller.currentEvent, 'currentEvent should not be null');
        Assert.areNotEqual(null, controller.currentRule, 'currentRule should not be null');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
    }
    
    @IsTest
    static void test_constructor_withDevCookie() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];
        
        PageReference pageRef = Page.EventsChartsWrapper;
        pageRef.getParameters().put('recordId', event.Id);
        Test.setCurrentPage(pageRef);
        
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{devCookie});
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(event);
        EventsChartsWrapperController controller = new EventsChartsWrapperController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev cookie is set');
    }
    
    @IsTest
    static void test_constructor_withoutDevParameterOrCookie() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];
        
        PageReference pageRef = Page.EventsChartsWrapper;
        pageRef.getParameters().put('recordId', event.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(event);
        EventsChartsWrapperController controller = new EventsChartsWrapperController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when no dev parameter or cookie');
    }
    
    @IsTest
    static void test_getEvents_with7Days() {
        Rule__c rule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        
        Test.startTest();
        String result = EventsChartsWrapperController.getEvents(7, rule.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        List<Event__c> events = (List<Event__c>)JSON.deserialize(result, List<Event__c>.class);
        Assert.areNotEqual(null, events, 'Events list should not be null');
        Assert.areEqual(1, events.size(), 'Should return 1 event for Spike rule');
    }
    
    @IsTest
    static void test_getEvents_with30Days() {
        Rule__c rule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        
        Test.startTest();
        String result = EventsChartsWrapperController.getEvents(30, rule.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        List<Event__c> events = (List<Event__c>)JSON.deserialize(result, List<Event__c>.class);
        Assert.areNotEqual(null, events, 'Events list should not be null');
        Assert.areEqual(1, events.size(), 'Should return 1 event for Spike rule');
    }
    
    @IsTest
    static void test_getEvents_with60Days() {
        Rule__c rule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        
        Test.startTest();
        String result = EventsChartsWrapperController.getEvents(60, rule.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        List<Event__c> events = (List<Event__c>)JSON.deserialize(result, List<Event__c>.class);
        Assert.areNotEqual(null, events, 'Events list should not be null');
        Assert.areEqual(1, events.size(), 'Should return 1 event for Spike rule');
    }
    
    @IsTest
    static void test_getEvents_with180Days() {
        Rule__c rule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        
        Test.startTest();
        String result = EventsChartsWrapperController.getEvents(180, rule.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        List<Event__c> events = (List<Event__c>)JSON.deserialize(result, List<Event__c>.class);
        Assert.areNotEqual(null, events, 'Events list should not be null');
        Assert.areEqual(1, events.size(), 'Should return 1 event for Spike rule');
    }
    
    @IsTest
    static void test_getEvents_withInvalidDays() {
        Rule__c rule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        
        Test.startTest();
        String result = EventsChartsWrapperController.getEvents(99, rule.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null, should default to 30 days');
        List<Event__c> events = (List<Event__c>)JSON.deserialize(result, List<Event__c>.class);
        Assert.areNotEqual(null, events, 'Events list should not be null');
        Assert.areEqual(1, events.size(), 'Should return 1 event for Spike rule');
    }
    
    @IsTest
    static void test_getTimingLogs_with10Minutes() {
        DateTime eventTime = DateTime.now();
        
        Test.startTest();
        String result = EventsChartsWrapperController.getTimingLogs(eventTime, 10);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        List<Log__c> logs = (List<Log__c>)JSON.deserialize(result, List<Log__c>.class);
        Assert.areNotEqual(null, logs, 'Logs list should not be null');
    }
    
    @IsTest
    static void test_getTimingLogs_with30Minutes() {
        DateTime eventTime = DateTime.now();
        
        Test.startTest();
        String result = EventsChartsWrapperController.getTimingLogs(eventTime, 30);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void test_getTimingLogs_with60Minutes() {
        DateTime eventTime = DateTime.now();
        
        Test.startTest();
        String result = EventsChartsWrapperController.getTimingLogs(eventTime, 60);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void test_getTimingLogs_withInvalidRange() {
        DateTime eventTime = DateTime.now();
        
        Test.startTest();
        String result = EventsChartsWrapperController.getTimingLogs(eventTime, 99);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null, should default to 10 minutes');
    }
    
    @IsTest
    static void test_remoteActionHandler_getOccurrenceEvents() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id, Rule__c FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];
        
        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getOccurrenceEvents',
            'data' => new Map<String, Object>{
                'eventId' => event.Id,
                'showDays' => 7
            }
        };
        
        Test.startTest();
        String result = EventsChartsWrapperController.remoteActionHandler(JSON.serialize(input));
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
    }
    
    @IsTest
    static void test_remoteActionHandler_getEventRecords_spike() {
        TestDataFactory.enableMaxArchivalRules();
        
        // Get Spike rule and its event (only one Spike event exists)
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id, Records__c FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getEventRecords',
            'data' => new Map<String, Object>{
                'eventId' => event.Id,
                'range' => 60
            }
        };
        
        Test.startTest();
        String result = EventsChartsWrapperController.remoteActionHandler(JSON.serialize(input));
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
    }
    
    @IsTest
    static void test_remoteActionHandler_getEventRecords_impact() {
        TestDataFactory.enableMaxArchivalRules();
        
        // Get Impact rule and its event (only one Impact event exists)
        Rule__c impactRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_IMPACT LIMIT 1];
        Event__c event = [SELECT Id, Records__c FROM Event__c WHERE Rule__c = :impactRule.Id LIMIT 1];

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getEventRecords',
            'data' => new Map<String, Object>{
                'eventId' => event.Id,
                'range' => 30
            }
        };
        
        Test.startTest();
        String result = EventsChartsWrapperController.remoteActionHandler(JSON.serialize(input));
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
    }
    
    @IsTest
    static void test_remoteActionHandler_getTimingLogs() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'getTimingLogs',
            'data' => new Map<String, Object>{
                'eventId' => event.Id,
                'range' => 10
            }
        };
        
        Test.startTest();
        String result = EventsChartsWrapperController.remoteActionHandler(JSON.serialize(input));
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response data should not be null');
    }
    
    @IsTest
    static void test_remoteActionHandler_invalidMethod() {
        Rule__c spikeRule = [SELECT Id FROM Rule__c WHERE Subtype__c = :Constants.RULE_SOBJECT.SUB_TYPE_SPIKE LIMIT 1];
        Event__c event = [SELECT Id FROM Event__c WHERE Rule__c = :spikeRule.Id LIMIT 1];

        Map<String, Object> input = new Map<String, Object>{
            'method' => 'invalidMethod',
            'data' => new Map<String, Object>{
                'eventId' => event.Id
            }
        };
        
        Test.startTest();
        String result = EventsChartsWrapperController.remoteActionHandler(JSON.serialize(input));
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error');
        Assert.areEqual('Action not found', (String)response.get('error'), 'Error message should indicate action not found');
    }
    
    @IsTest
    static void test_chartData_constructor() {
        Test.startTest();
        EventsChartsWrapperController.ChartData chartData = new EventsChartsWrapperController.ChartData();
        Test.stopTest();
        
        Assert.areNotEqual(null, chartData.mapIntervals, 'mapIntervals should not be null');
        Assert.areNotEqual(null, chartData.logs, 'logs should not be null');
        Assert.areEqual(0, chartData.countLogs, 'countLogs should be 0');
    }
    
    @IsTest
    static void test_chartDataInterval_constructor() {
        Test.startTest();
        EventsChartsWrapperController.ChartDataInterval interval = new EventsChartsWrapperController.ChartDataInterval();
        Test.stopTest();
        
        Assert.areNotEqual(null, interval.logValues, 'logValues should not be null');
        Assert.areEqual(0, interval.value, 'value should be 0');
    }
    
    @IsTest
    static void test_remoteActionResponse_class() {
        Test.startTest();
        EventsChartsWrapperController.RemoteActionResponse response = new EventsChartsWrapperController.RemoteActionResponse();
        response.params = 'test params';
        response.data = 'test data';
        response.error = 'test error';
        response.stack = 'test stack';
        Test.stopTest();
        
        Assert.areEqual('test params', response.params, 'params should be set correctly');
        Assert.areEqual('test data', response.data, 'data should be set correctly');
        Assert.areEqual('test error', response.error, 'error should be set correctly');
        Assert.areEqual('test stack', response.stack, 'stack should be set correctly');
    }
}