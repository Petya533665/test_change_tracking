@IsTest
public with sharing class StacktraceViewerWrapperControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create test data
        Log__c log = new Log__c();
        log.Type__c = 'ERROR';
        log.Category__c = 'Apex';
        log.Stacktrace__c = 'Test stacktrace';
        log.Stacktrace_Parse_Result__c = '{"test": "result"}';
        insert log;
        
        // Create ContentVersion records
        ContentVersion stacktraceCv = new ContentVersion();
        stacktraceCv.Title = 'Stacktrace';
        stacktraceCv.PathOnClient = ErrorEmailHandler.STACK_TRACE_CV_NAME;
        stacktraceCv.VersionData = Blob.valueOf('<html>Test stacktrace</html>');
        stacktraceCv.IsMajorVersion = true;
        insert stacktraceCv;
        
        ContentVersion parseResultCv = new ContentVersion();
        parseResultCv.Title = 'Parse Result';
        parseResultCv.PathOnClient = ErrorEmailHandler.STACK_TRACE_PARSE_RESULT_CV_NAME;
        parseResultCv.VersionData = Blob.valueOf('{"test": "parse result"}');
        parseResultCv.IsMajorVersion = true;
        insert parseResultCv;
        
        // Create ContentDocumentLinks
        ContentDocumentLink stacktraceLink = new ContentDocumentLink();
        stacktraceLink.LinkedEntityId = log.Id;
        stacktraceLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :stacktraceCv.Id].ContentDocumentId;
        stacktraceLink.ShareType = 'V';
        insert stacktraceLink;
        
        ContentDocumentLink parseResultLink = new ContentDocumentLink();
        parseResultLink.LinkedEntityId = log.Id;
        parseResultLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :parseResultCv.Id].ContentDocumentId;
        parseResultLink.ShareType = 'V';
        insert parseResultLink;
    }
    
    @IsTest
    static void test_constructor_withValidLog() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.log, 'Log should be loaded');
        Assert.areEqual(log.Id, controller.log.Id, 'Log ID should match');
    }
    
    @IsTest
    static void test_constructor_withDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.StacktraceViewerWrapper;
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev parameter is set');
    }
    
    @IsTest
    static void test_constructor_withDevCookie() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page with cookie
        PageReference pageRef = Page.StacktraceViewerWrapper;
        Test.setCurrentPage(pageRef);
        
        // Set cookie
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{devCookie});
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isTrue(controller.isDev, 'isDev should be true when dev cookie is set');
    }
    
    @IsTest
    static void test_constructor_withoutDevParameterOrCookie() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when no dev parameter or cookie');
    }
    
    @IsTest
    static void test_constructor_withBlurMode() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should be set');
    }
    
    @IsTest
    static void test_constructor_withContentDocumentLinks() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.stacktraceCvId, 'stacktraceCvId should be set');
        Assert.areNotEqual(null, controller.stacktraceParseResultCvId, 'stacktraceParseResultCvId should be set');
    }
    
    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        String namespace = controller.packageNamespace;
        Test.stopTest();
        
        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }
    
    @IsTest
    static void test_constructor_withLogWithoutContentDocumentLinks() {
        // Create log without content document links
        Log__c log = new Log__c();
        log.Type__c = 'ERROR';
        log.Category__c = 'Apex';
        insert log;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.log, 'Log should be loaded');
        Assert.areEqual(null, controller.stacktraceCvId, 'stacktraceCvId should be null when no content document links');
        Assert.areEqual(null, controller.stacktraceParseResultCvId, 'stacktraceParseResultCvId should be null when no content document links');
    }
    
    @IsTest
    static void test_constructor_withInvalidDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters with invalid dev value
        PageReference pageRef = Page.StacktraceViewerWrapper;
        pageRef.getParameters().put('dev', 'invalid');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when dev parameter is invalid');
    }
    
    @IsTest
    static void test_constructor_withEmptyDevParameter() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page parameters with empty dev value
        PageReference pageRef = Page.StacktraceViewerWrapper;
        pageRef.getParameters().put('dev', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when dev parameter is empty');
    }
    
    @IsTest
    static void test_constructor_withNullDevCookie() {
        Log__c log = [SELECT Id FROM Log__c LIMIT 1];
        
        // Set up page without cookie
        PageReference pageRef = Page.StacktraceViewerWrapper;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(log);
        StacktraceViewerWrapperController controller = new StacktraceViewerWrapperController(stdController);
        Test.stopTest();
        
        Assert.isFalse(controller.isDev, 'isDev should be false when dev cookie is null');
    }
}