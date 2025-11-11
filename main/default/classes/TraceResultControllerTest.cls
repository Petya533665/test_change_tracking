@IsTest
public with sharing class TraceResultControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create test data
        Log__c log = new Log__c();
        log.Type__c = 'ERROR';
        log.Category__c = 'Apex';
        insert log;
        
        // Create ContentVersion records
        ContentVersion debugLogCv = new ContentVersion();
        debugLogCv.Title = 'Debug Log';
        debugLogCv.PathOnClient = 'debug.json';
        debugLogCv.VersionData = Blob.valueOf('{"test": "debug log"}');
        debugLogCv.IsMajorVersion = true;
        debugLogCv.Description = '{"user":"testuser","application":"testapp","request":"testrequest","operation":"testop","status":"success","duration":100,"logSize":500,"startTime":"2023-01-01T00:00:00Z"}';
        insert debugLogCv;
        
        ContentVersion flowLogCv = new ContentVersion();
        flowLogCv.Title = 'flow debug log';
        flowLogCv.PathOnClient = 'flow.json';
        flowLogCv.VersionData = Blob.valueOf('{"test": "flow log"}');
        flowLogCv.IsMajorVersion = true;
        flowLogCv.Description = '{"user":"flowuser","application":"flowapp","request":"flowrequest","operation":"flowop","status":"success","duration":200,"logSize":600,"startTime":"2023-01-01T01:00:00Z"}';
        insert flowLogCv;
        
        // Create ContentDocumentLinks
        ContentDocumentLink debugLink = new ContentDocumentLink();
        debugLink.LinkedEntityId = log.Id;
        debugLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :debugLogCv.Id].ContentDocumentId;
        debugLink.ShareType = 'V';
        insert debugLink;
        
        ContentDocumentLink flowLink = new ContentDocumentLink();
        flowLink.LinkedEntityId = log.Id;
        flowLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :flowLogCv.Id].ContentDocumentId;
        flowLink.ShareType = 'V';
        insert flowLink;
    }
    
    @IsTest
    static void test_constructor_withDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.TraceResult;
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev parameter is set');
    }
    
    @IsTest
    static void test_constructor_withDevCookie() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page with cookie
        PageReference pageRef = Page.TraceResult;
        Test.setCurrentPage(pageRef);
        
        // Set cookie
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{devCookie});
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev cookie is set');
    }
    
    @IsTest
    static void test_constructor_withoutDevParameterOrCookie() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when no dev parameter or cookie');
    }
    
    @IsTest
    static void test_constructor_withInvalidDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters with invalid dev value
        PageReference pageRef = Page.TraceResult;
        pageRef.getParameters().put('dev', 'invalid');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when dev parameter is invalid');
    }
    
    @IsTest
    static void test_constructor_withEmptyDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters with empty dev value
        PageReference pageRef = Page.TraceResult;
        pageRef.getParameters().put('dev', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when dev parameter is empty');
    }
    
    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        TraceResultController controller = new TraceResultController(stdController);
        String namespace = controller.packageNamespace;
        Test.stopTest();
        
        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }
    
    @IsTest
    static void test_baseUrl_property() {
        Test.startTest();
        String baseUrl = TraceResultController.baseUrl;
        Test.stopTest();
        
        Assert.areNotEqual(null, baseUrl, 'baseUrl should not be null');
        Assert.isTrue(baseUrl.contains('salesforce.com') || baseUrl.contains('force.com'), 'baseUrl should contain salesforce domain');
    }
    
    @IsTest
    static void test_getNameSpacePrefix() {
        Test.startTest();
        String namespace = TraceResultController.getNameSpacePrefix();
        Test.stopTest();
        
        Assert.areNotEqual(null, namespace, 'getNameSpacePrefix should not return null');
    }
    
    @IsTest
    static void test_getDebugLogs_withValidRecordId() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        List<TraceResultController.DebugLog> debugLogs = TraceResultController.getDebugLogs(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, debugLogs, 'DebugLogs should not be null');
        Assert.areEqual(2, debugLogs.size(), 'Should return 2 debug logs');
        
        // Find the non-flow debug log (testuser)
        TraceResultController.DebugLog testLog = null;
        for (TraceResultController.DebugLog logItem : debugLogs) {
            if (!logItem.isFlow) {
                testLog = logItem;
                break;
            }
        }
        
        Assert.areNotEqual(null, testLog, 'Non-flow log should be found');
        Assert.areNotEqual(null, testLog.contentDocumentId, 'contentDocumentId should not be null');
        Assert.areNotEqual(null, testLog.contentDocumentCreatedDate, 'contentDocumentCreatedDate should not be null');
        Assert.areNotEqual(null, testLog.contentVersionId, 'contentVersionId should not be null');
        Assert.areNotEqual(null, testLog.Title, 'Title should not be null');
        Assert.areEqual('testuser', testLog.user, 'User should match');
        Assert.areEqual('testapp', testLog.application, 'Application should match');
        Assert.areEqual('testrequest', testLog.request, 'Request should match');
        Assert.areEqual('testop', testLog.operation, 'Operation should match');
        Assert.areEqual('success', testLog.status, 'Status should match');
        Assert.areEqual(100, testLog.duration, 'Duration should match');
        Assert.areEqual(500, testLog.logSize, 'LogSize should match');
        Assert.areEqual('2023-01-01T00:00:00Z', testLog.startTime, 'StartTime should match');
        Assert.areNotEqual(null, testLog.timeZone, 'TimeZone should not be null');
        Assert.isFalse(testLog.isFlow, 'isFlow should be false for non-flow log');
    }
    
    @IsTest
    static void test_getDebugLogs_withFlowLog() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        List<TraceResultController.DebugLog> debugLogs = TraceResultController.getDebugLogs(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, debugLogs, 'DebugLogs should not be null');
        Assert.areEqual(2, debugLogs.size(), 'Should return 2 debug logs');
        
        // Find flow log
        TraceResultController.DebugLog flowLog = null;
        for (TraceResultController.DebugLog logItem : debugLogs) {
            if (logItem.isFlow) {
                flowLog = logItem;
                break;
            }
        }
        
        Assert.areNotEqual(null, flowLog, 'Flow log should be found');
        Assert.isTrue(flowLog.isFlow, 'isFlow should be true for flow log');
        Assert.areEqual('flowuser', flowLog.user, 'Flow user should match');
        Assert.areEqual('flowapp', flowLog.application, 'Flow application should match');
    }
    
    @IsTest
    static void test_getDebugLogs_withNullRecordId() {
        Test.startTest();
        try {
            List<TraceResultController.DebugLog> debugLogs = TraceResultController.getDebugLogs(null);
            // If no exception is thrown, verify the result
            Assert.areNotEqual(null, debugLogs, 'DebugLogs should not be null');
            Assert.areEqual(0, debugLogs.size(), 'Should return empty list for null record ID');
        } catch (Exception e) {
            // Expected behavior - SOQL query fails with null ID
            Assert.isTrue(e.getMessage().contains('ContentDocumentLink requires a filter'), 'Should throw ContentDocumentLink filter exception');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void test_remoteActionHandler_getApexClassById() {
        Test.startTest();
        String input = '{"method":"getApexClassById","data":"01p000000000000"}';
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
    }
    
    @IsTest
    static void test_remoteActionHandler_getApexTriggerById() {
        Test.startTest();
        String input = '{"method":"getApexTriggerById","data":"01t000000000000"}';
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
    }
    
    @IsTest
    static void test_remoteActionHandler_invalidMethod() {
        Test.startTest();
        String input = '{"method":"invalidMethod"}';
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areEqual(null, response.get('data'), 'Response should not contain data');
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error');
        Assert.areEqual('Action not found', (String) response.get('error'), 'Error message should indicate action not found');
    }
    
    @IsTest
    static void test_remoteActionHandler_invalidJson() {
        Test.startTest();
        String input = 'invalid json';
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areEqual(null, response.get('data'), 'Response should not contain data');
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error');
    }
    
    @IsTest
    static void test_remoteActionHandler_emptyInput() {
        Test.startTest();
        String input = '';
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areEqual(null, response.get('data'), 'Response should not contain data');
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error');
    }
    
    @IsTest
    static void test_remoteActionHandler_nullInput() {
        Test.startTest();
        String input = null;
        String result = TraceResultController.remoteActionHandler(input);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areEqual(null, response.get('data'), 'Response should not contain data');
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error');
    }
    
    @IsTest
    static void test_getApexClassById_withValidId() {
        Test.startTest();
        Map<String, Object> result = TraceResultController.getApexClassById('01p000000000000');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.containsKey('apexClasses'), 'Result should contain apexClasses key');
        // Note: The apexClasses list may be empty if the ID doesn't exist in the database
        List<Object> apexClasses = (List<Object>)result.get('apexClasses');
        Assert.areNotEqual(null, apexClasses, 'apexClasses list should not be null');
    }
    
    @IsTest
    static void test_getApexClassById_withNullData() {
        Test.startTest();
        Map<String, Object> result = TraceResultController.getApexClassById(null);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.isEmpty(), 'Result should be empty when data is null');
        Assert.isFalse(result.containsKey('apexClasses'), 'Result should not contain apexClasses key when data is null');
    }
    
    @IsTest
    static void test_getApexTriggerById_withValidId() {
        Test.startTest();
        Map<String, Object> result = TraceResultController.getApexTriggerById('01t000000000000');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.containsKey('apexTriggers'), 'Result should contain apexTriggers key');
        // Note: The apexTriggers list may be empty if the ID doesn't exist in the database
        List<Object> apexTriggers = (List<Object>)result.get('apexTriggers');
        Assert.areNotEqual(null, apexTriggers, 'apexTriggers list should not be null');
    }
    
    @IsTest
    static void test_getApexTriggerById_withNullData() {
        Test.startTest();
        Map<String, Object> result = TraceResultController.getApexTriggerById(null);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.isEmpty(), 'Result should be empty when data is null');
        Assert.isFalse(result.containsKey('apexTriggers'), 'Result should not contain apexTriggers key when data is null');
    }
    
    @IsTest
    static void test_debugLog_constructor_withContentDocument() {
        ContentDocument contentDocument = [SELECT Id, Title, Description, CreatedDate, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        TraceResultController.DebugLog debugLog = new TraceResultController.DebugLog(contentDocument);
        Test.stopTest();
        
        Assert.areEqual(contentDocument.Id, debugLog.contentDocumentId, 'contentDocumentId should match');
        Assert.areEqual(contentDocument.CreatedDate, debugLog.contentDocumentCreatedDate, 'contentDocumentCreatedDate should match');
        Assert.areEqual(contentDocument.LatestPublishedVersionId, debugLog.contentVersionId, 'contentVersionId should match');
        Assert.areEqual(contentDocument.Title, debugLog.Title, 'Title should match');
        Assert.areNotEqual(null, debugLog.user, 'User should not be null');
        Assert.areNotEqual(null, debugLog.application, 'Application should not be null');
        Assert.areNotEqual(null, debugLog.request, 'Request should not be null');
        Assert.areNotEqual(null, debugLog.operation, 'Operation should not be null');
        Assert.areNotEqual(null, debugLog.status, 'Status should not be null');
        Assert.areNotEqual(null, debugLog.duration, 'Duration should not be null');
        Assert.areNotEqual(null, debugLog.logSize, 'LogSize should not be null');
        Assert.areNotEqual(null, debugLog.startTime, 'StartTime should not be null');
        Assert.areNotEqual(null, debugLog.timeZone, 'TimeZone should not be null');
    }
    
    @IsTest
    static void test_debugLog_defaultConstructor() {
        Test.startTest();
        TraceResultController.DebugLog debugLog = new TraceResultController.DebugLog();
        Test.stopTest();
        
        Assert.areEqual(null, debugLog.contentDocumentId, 'contentDocumentId should be null');
        Assert.areEqual(null, debugLog.contentDocumentCreatedDate, 'contentDocumentCreatedDate should be null');
        Assert.areEqual(null, debugLog.contentVersionId, 'contentVersionId should be null');
        Assert.areEqual(null, debugLog.Title, 'Title should be null');
        Assert.areEqual(null, debugLog.user, 'User should be null');
        Assert.areEqual(null, debugLog.application, 'Application should be null');
        Assert.areEqual(null, debugLog.request, 'Request should be null');
        Assert.areEqual(null, debugLog.operation, 'Operation should be null');
        Assert.areEqual(null, debugLog.status, 'Status should be null');
        Assert.areEqual(null, debugLog.duration, 'Duration should be null');
        Assert.areEqual(null, debugLog.logSize, 'LogSize should be null');
        Assert.areEqual(null, debugLog.startTime, 'StartTime should be null');
        Assert.areEqual(null, debugLog.timeZone, 'TimeZone should be null');
        Assert.areEqual(null, debugLog.isFlow, 'isFlow should be null');
    }
    
    @IsTest
    static void test_remoteActionResponse_class() {
        Test.startTest();
        TraceResultController.RemoteActionResponse response = new TraceResultController.RemoteActionResponse();
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