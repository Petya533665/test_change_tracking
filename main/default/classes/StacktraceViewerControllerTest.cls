@IsTest
public with sharing class StacktraceViewerControllerTest {

    @TestSetup
    static void testSetup() {
        // Create test Log__c records
        Log__c parentLog = new Log__c(
            Category__c = 'StacktraceTest',
            Type__c = 'Parent',
            Summary__c = 'Parent Log Summary',
            Is_Parent__c = true,
            Stacktrace__c = '123456789',
            Stacktrace_Parse_Result__c = '987654321',
            Stack_trace_parse_result_available__c = true,
            Organization_Url__c = 'https://test.salesforce.com',
            Async_Job_Id__c = 'test-job-id',
            Transaction_Id_External__c = 'testTransactionId'
        );
        insert parentLog;

        // Create child Log__c record
        Log__c childLog = new Log__c(
            Category__c = 'StacktraceTest',
            Type__c = 'Child',
            Summary__c = 'Log After: Test Child Summary',
            Parent__c = parentLog.Id,
            Stacktrace__c = '111222333',
            Stacktrace_Parse_Result__c = '333222111',
            Stack_trace_parse_result_available__c = true,
            Organization_Url__c = 'https://test.salesforce.com',
            Created_Timestamp__c = 1640995200,
            Async_Job_Id__c = 'test-child-job-id',
            Transaction_Id_External__c = 'testTransactionId'
        );
        insert childLog;

        // Create regular Log__c record (not parent)
        Log__c regularLog = new Log__c(
            Category__c = 'StacktraceTest',
            Type__c = 'Regular',
            Summary__c = 'Regular Log Summary',
            Is_Parent__c = false,
            Stacktrace__c = '444555666',
            Stacktrace_Parse_Result__c = '666555444',
            Stack_trace_parse_result_available__c = false,
            Organization_Url__c = 'https://test.salesforce.com',
            Async_Job_Id__c = 'test-regular-job-id'
        );
        insert regularLog;

        // Create Issue__c record
        Issue__c testIssue = new Issue__c(
            Log__c = regularLog.Id,
            Summary__c = 'Test Issue Summary',
            Description__c = 'Test Issue Description'
        );
        insert testIssue;

        // Create ContentVersion records for stacktrace files
        ContentVersion stacktraceCV = new ContentVersion(
            Title = 'Stacktrace.html',
            PathOnClient = 'Stacktrace.html',
            VersionData = Blob.valueOf('<html>Test Stacktrace Content</html>'),
            ContentLocation = 'S'
        );
        insert stacktraceCV;

        ContentVersion stacktraceParseResultCV = new ContentVersion(
            Title = 'StacktraceParseResult.json',
            PathOnClient = 'StacktraceParseResult.json',
            VersionData = Blob.valueOf('{"parsed": "data"}'),
            ContentLocation = 'S'
        );
        insert stacktraceParseResultCV;

        // Create ContentDocumentLinks
        List<ContentVersion> cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :new List<Id>{stacktraceCV.Id, stacktraceParseResultCV.Id}];
        
        ContentDocumentLink stacktraceCDL = new ContentDocumentLink(
            ContentDocumentId = cvs[0].ContentDocumentId,
            LinkedEntityId = regularLog.Id,
            ShareType = 'V'
        );
        insert stacktraceCDL;

        ContentDocumentLink stacktraceParseResultCDL = new ContentDocumentLink(
            ContentDocumentId = cvs[1].ContentDocumentId,
            LinkedEntityId = regularLog.Id,
            ShareType = 'V'
        );
        insert stacktraceParseResultCDL;
    }

    @IsTest
    static void testConstructor_WithLogRecordId() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areEqual(testLog.Id, controller.log.Id, 'Log ID should match');
        Assert.areNotEqual(null, controller.packageNamespace, 'Package namespace should not be null');
        Assert.areNotEqual(null, StacktraceViewerController.baseUrl, 'Base URL should not be null');
        Assert.areEqual(false, controller.isDev, 'isDev should default to false');
        Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should not be null');
    }

    @IsTest
    static void testConstructor_WithIssueRecordId() {
        Issue__c testIssue = [SELECT Id FROM Issue__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testIssue.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testIssue);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areNotEqual(null, controller.packageNamespace, 'Package namespace should not be null');
        Assert.areNotEqual(null, StacktraceViewerController.baseUrl, 'Base URL should not be null');
        Assert.areEqual(false, controller.isDev, 'isDev should default to false');
    }

    @IsTest
    static void testConstructor_WithDevParameter() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify dev parameter handling
        Assert.areEqual(true, controller.isDev, 'isDev should be true when dev parameter is set');
    }

    @IsTest
    static void testConstructor_WithDevCookie() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Set cookie
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify dev cookie handling
        Assert.areEqual(true, controller.isDev, 'isDev should be true when dev cookie is set');
    }

    @IsTest
    static void testConstructor_WithParentLog() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Type__c = 'Parent' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', parentLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(parentLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.isTrue(controller.log.Summary__c.contains('Log After:'), 'Should use child log with Log After summary');
    }

    @IsTest
    static void testConstructor_WithInvalidRecordId() {
        // Set up page parameters with invalid ID
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', 'invalid-id');
        Test.setCurrentPage(pageRef);
        
        // Create standard controller with dummy record
        Log__c dummyLog = new Log__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(dummyLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify controller handles invalid ID gracefully
        Assert.areEqual(null, controller.log, 'Log should be null for invalid ID');
        Assert.areEqual(false, controller.isDev, 'isDev should default to false');
    }

    @IsTest
    static void testConstructor_WithNoRecordId() {
        // Set up page parameters without recordId
        PageReference pageRef = Page.StacktraceViewer;
        Test.setCurrentPage(pageRef);
        
        // Create standard controller with dummy record
        Log__c dummyLog = new Log__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(dummyLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify controller handles missing recordId gracefully
        Assert.areEqual(null, controller.log, 'Log should be null when no recordId provided');
        Assert.areEqual(false, controller.isDev, 'isDev should default to false');
    }

    @IsTest
    static void testRemoteActionHandler_GetContentDocumentIds() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        String input = JSON.serialize(new Map<String, Object>{
            'method' => 'getContentDocumentIds',
            'data' => new Map<String, Object>{
                'logId' => testLog.Id
            }
        });
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(input);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
    }

    @IsTest
    static void testRemoteActionHandler_GetSummaryContentDocumentId() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        String input = JSON.serialize(new Map<String, Object>{
            'method' => 'getSummaryContentDocumentId',
            'data' => new Map<String, Object>{
                'logId' => testLog.Id
            }
        });
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(input);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
    }

    @IsTest
    static void testRemoteActionHandler_GetAppPermissions() {
        String input = JSON.serialize(new Map<String, Object>{
            'method' => 'getAppPermissions',
            'data' => new Map<String, Object>{
                'permission' => 'test-permission'
            }
        });
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(input);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
    }

    @IsTest
    static void testRemoteActionHandler_ReplayCallout() {
        String endpoint = 'https://test.salesforce.com/services/data/v50.0/sobjects/Account';
        String method = 'GET';
        String testResponseBody = '{"records":[{"Id":"001000000000001","Name":"Test Account"}]}';
        
        // Create mock for HTTP callout
        TestDataFactory.SingleRequestMock mockResponse = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            testResponseBody
        );
        
        TestDataFactory.MultiRequestMock multiMock = new TestDataFactory.MultiRequestMock(
            new Map<String, HttpCalloutMock>{
                endpoint => mockResponse
            }
        );
        
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        String input = JSON.serialize(new Map<String, Object>{
            'method' => 'replayCallout',
            'data' => new Map<String, Object>{
                'endpoint' => endpoint,
                'method' => method,
                'headers' => new Map<String, Object>{
                    'Authorization' => 'Bearer test-token',
                    'Content-Type' => 'application/json'
                },
                'body' => '{"test": "data"}'
            }
        });
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(input);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('data'), 'Response should contain data');
        Assert.areEqual(null, response.get('error'), 'Response should not contain error');
        
        // Verify the data structure matches HttpResponseWrapper.formatResponse()
        Map<String, Object> responseData = (Map<String, Object>)response.get('data');
        Assert.areNotEqual(null, responseData.get('statusCode'), 'Response data should contain statusCode');
        Assert.areNotEqual(null, responseData.get('body'), 'Response data should contain body');
        Assert.areEqual(200, responseData.get('statusCode'), 'Status code should be 200');
        Assert.areEqual(testResponseBody, responseData.get('body'), 'Response body should match mock data');
    }

    @IsTest
    static void testRemoteActionHandler_InvalidMethod() {
        String input = JSON.serialize(new Map<String, Object>{
            'method' => 'invalidMethod',
            'data' => new Map<String, Object>()
        });
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(input);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areEqual('Action not found', response.get('error'), 'Response should contain error for invalid method');
    }

    @IsTest
    static void testRemoteActionHandler_InvalidJson() {
        String invalidInput = 'invalid json input';
        
        Test.startTest();
        String result = StacktraceViewerController.remoteActionHandler(invalidInput);
        Test.stopTest();
        
        // Verify response
        Assert.areNotEqual(null, result, 'Result should not be null');
        
        // Parse response
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, response.get('error'), 'Response should contain error for invalid JSON');
    }

    @IsTest
    static void testPackageNamespaceProperty() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify package namespace property
        Assert.areNotEqual(null, controller.packageNamespace, 'Package namespace should not be null');
    }

    @IsTest
    static void testBaseUrlProperty() {
        // Test static property
        Test.startTest();
        String baseUrl = StacktraceViewerController.baseUrl;
        Test.stopTest();
        
        // Verify base URL property
        Assert.areNotEqual(null, baseUrl, 'Base URL should not be null');
        Assert.isTrue(baseUrl.contains('salesforce.com'), 'Base URL should contain salesforce.com');
    }

    @IsTest
    static void testBlurModeBehavior() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify blur mode properties
        Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should not be null');
        
        if (controller.isBlurMode) {
            Assert.areNotEqual(null, controller.blurModeUrlParameter, 'blurModeUrlParameter should not be null when in blur mode');
        }
    }

    @IsTest
    static void testContentDocumentLinksProcessing() {
        Log__c testLog = [SELECT Id FROM Log__c WHERE Type__c = 'Regular' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        StacktraceViewerController controller = new StacktraceViewerController(stdController);
        Test.stopTest();
        
        // Verify content document IDs are set
        Assert.areNotEqual(null, controller.stacktraceCvId, 'Stacktrace CV ID should not be null');
        Assert.areNotEqual(null, controller.stacktraceParseResultCvId, 'Stacktrace Parse Result CV ID should not be null');
    }

    @IsTest
    static void testRemoteActionResponseClass() {
        // Test the inner class
        StacktraceViewerController.RemoteActionResponse response = new StacktraceViewerController.RemoteActionResponse();
        
        // Set properties
        response.params = new Map<String, Object>{'test' => 'value'};
        response.data = 'test data';
        response.error = 'test error';
        response.stack = 'test stack';
        
        // Verify properties
        Assert.areNotEqual(null, response.params, 'Params should not be null');
        Assert.areEqual('test data', response.data, 'Data should match');
        Assert.areEqual('test error', response.error, 'Error should match');
        Assert.areEqual('test stack', response.stack, 'Stack should match');
    }
}