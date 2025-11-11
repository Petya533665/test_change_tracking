@IsTest
public with sharing class DeployResultsViewerControllerTest {

    @TestSetup
    static void testSetup() {
        // Create test Connected_Org__c record using TestDataFactory
        TestDataFactory.createConnectedOrg();
        
        // Get the created connected org
        Connected_Org__c connectedOrg = [SELECT Name FROM Connected_Org__c LIMIT 1];

        // Create test Log__c record with deploy results
        Log__c testLog = new Log__c(
            Deploy_Results__c = '[{"status":"Succeeded","id":"001000000000001","completedDate":"2022-12-13T21:48:21.000Z"},{"status":"Failed","id":"001000000000002","completedDate":"2022-12-13T21:48:22.000Z"}]',
            Organization_Id__c = connectedOrg.Name,
            Issue__c = null,
            Category__c = 'DeployResultsTest'
        );
        insert testLog;

        // Create test Log__c record without deploy results
        Log__c testLogEmpty = new Log__c(
            Deploy_Results__c = null,
            Organization_Id__c = connectedOrg.Name,
            Issue__c = null,
            Category__c = 'DeployResultsEmptyTest'
        );
        insert testLogEmpty;

        // Create test Log__c record with empty deploy results
        Log__c testLogBlank = new Log__c(
            Deploy_Results__c = '',
            Organization_Id__c = connectedOrg.Name,
            Issue__c = null,
            Category__c = 'DeployResultsBlankTest'
        );
        insert testLogBlank;
    }

    @IsTest
    static void testConstructor_WithValidLogRecord() {
        // Get the test log record
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties are set correctly
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areEqual(testLog.Id, controller.log.Id, 'Log ID should match');
        Assert.areNotEqual(null, controller.data, 'Data should not be null');
        Assert.areNotEqual('', controller.data, 'Data should not be empty');
        Assert.areNotEqual(null, controller.timeZoneOffset, 'Time zone offset should not be null');
        
        // Verify data content based on blur mode
        if (controller.isBlurMode) {
            Assert.isTrue(controller.data.contains('XXXXXXXXXXXXXXXXXX'), 'Data should contain fake data in blur mode');
        } else {
            Assert.isTrue(controller.data.contains('"status":"Succeeded"'), 'Data should contain real deploy results when not in blur mode');
        }
    }

    @IsTest
    static void testConstructor_WithLogWithoutDeployResults() {
        // Get the test log record without deploy results
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsEmptyTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areEqual(testLog.Id, controller.log.Id, 'Log ID should match');
        
        // When blur mode is active, data will be replaced with fake data
        if (controller.isBlurMode) {
            Assert.areNotEqual(null, controller.data, 'Data should not be null in blur mode');
            Assert.areNotEqual('', controller.data, 'Data should not be empty in blur mode');
            Assert.isTrue(controller.data.contains('XXXXXXXXXXXXXXXXXX'), 'Data should contain fake data in blur mode');
        } else {
            Assert.areEqual(null, controller.data, 'Data should be null when Deploy_Results__c is null and not in blur mode');
        }
    }

    @IsTest
    static void testConstructor_WithLogWithEmptyDeployResults() {
        // Get the test log record with empty deploy results
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsBlankTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify controller properties
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areEqual(testLog.Id, controller.log.Id, 'Log ID should match');
        
        // When blur mode is active, data will be replaced with fake data
        if (controller.isBlurMode) {
            Assert.areNotEqual(null, controller.data, 'Data should not be null in blur mode');
            Assert.areNotEqual('', controller.data, 'Data should not be empty in blur mode');
            Assert.isTrue(controller.data.contains('XXXXXXXXXXXXXXXXXX'), 'Data should contain fake data in blur mode');
        } else {
            Assert.areEqual('', controller.data, 'Data should be empty when Deploy_Results__c is empty and not in blur mode');
        }
    }

    @IsTest
    static void testConstructor_WithConnectedOrgInstanceUrl() {
        // Get the test log record with connected org
        Log__c testLog = [SELECT Id, Organization_Id__c FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify instance URL is set when connected org exists
        Assert.areNotEqual(null, controller.instanceUrl, 'Instance URL should not be null when connected org exists');
        Assert.areEqual('https://test_Instance_Url', controller.instanceUrl, 'Instance URL should match connected org URL');
    }

    @IsTest
    static void testConstructor_WithNoConnectedOrg() {
        // Create test Log__c record without connected org
        Log__c testLogNoOrg = new Log__c(
            Deploy_Results__c = '[{"status":"Succeeded","id":"001000000000001","completedDate":"2022-12-13T21:48:21.000Z"}]',
            Organization_Id__c = null,
            Issue__c = null
        );
        insert testLogNoOrg;
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLogNoOrg.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLogNoOrg);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify instance URL is null when no connected org
        Assert.areEqual(null, controller.instanceUrl, 'Instance URL should be null when no connected org');
    }

    @IsTest
    static void testConstructor_WithInvalidRecordId() {
        // Set up page parameters with invalid record ID
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', '001000000000000'); // Invalid ID
        Test.setCurrentPage(pageRef);
        
        // Create a dummy log for standard controller
        Log__c dummyLog = new Log__c();
        
        Test.startTest();
        try {
            ApexPages.StandardController stdController = new ApexPages.StandardController(dummyLog);
            DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
            Assert.isTrue(false, 'Should have thrown an exception for invalid record ID');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('List has no rows'), 'Should throw list has no rows exception');
        }
        Test.stopTest();
    }

    @IsTest
    static void testConstructor_WithNoRecordIdParameter() {
        // Set up page without recordId parameter
        PageReference pageRef = Page.DeployResultsViewer;
        Test.setCurrentPage(pageRef);
        
        // Create a dummy log for standard controller
        Log__c dummyLog = new Log__c();
        
        Test.startTest();
        try {
            ApexPages.StandardController stdController = new ApexPages.StandardController(dummyLog);
            DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
            Assert.isTrue(false, 'Should have thrown an exception for missing record ID');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('List has no rows'), 'Should throw list has no rows exception');
        }
        Test.stopTest();
    }

    @IsTest
    static void testConstructor_BlurModeProperties() {
        // Get the test log record
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify blur mode properties are initialized
        Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should not be null');
        // Note: The actual value depends on BlurModeService.isAvailableDebugView() implementation
    }

    @IsTest
    static void testConstructor_DataPropertyWithValidJson() {
        // Get the test log record with valid JSON data
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify data property contains valid JSON
        Assert.areNotEqual(null, controller.data, 'Data should not be null');
        Assert.areNotEqual('', controller.data, 'Data should not be empty');
        
        // Verify it's valid JSON by trying to deserialize
        try {
            List<Object> jsonData = (List<Object>) JSON.deserializeUntyped(controller.data);
            Assert.isTrue(jsonData.size() > 0, 'JSON should contain deploy results');
            
            // Verify content based on blur mode
            if (controller.isBlurMode) {
                Assert.isTrue(controller.data.contains('XXXXXXXXXXXXXXXXXX'), 'Should contain fake data in blur mode');
            } else {
                Assert.isTrue(controller.data.contains('"status":"Succeeded"'), 'Should contain real deploy results when not in blur mode');
            }
        } catch (Exception e) {
            Assert.isTrue(false, 'Data should be valid JSON: ' + e.getMessage());
        }
    }

    @IsTest
    static void testConstructor_TimeZoneOffsetProperty() {
        // Get the test log record
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify time zone offset is set
        Assert.areNotEqual(null, controller.timeZoneOffset, 'Time zone offset should not be null');
        Assert.isTrue(controller.timeZoneOffset != null, 'Time zone offset should be an Integer');
    }

    @IsTest
    static void testConstructor_LogPropertyFields() {
        // Get the test log record
        Log__c testLog = [SELECT Id, Deploy_Results__c, Organization_Id__c, Issue__c FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify log property contains all required fields
        Assert.areNotEqual(null, controller.log, 'Log should not be null');
        Assert.areEqual(testLog.Id, controller.log.Id, 'Log ID should match');
        Assert.areEqual(testLog.Deploy_Results__c, controller.log.Deploy_Results__c, 'Deploy_Results__c should match');
        Assert.areEqual(testLog.Organization_Id__c, controller.log.Organization_Id__c, 'Organization_Id__c should match');
        Assert.areEqual(testLog.Issue__c, controller.log.Issue__c, 'Issue__c should match');
    }

    @IsTest
    static void testConstructor_IntegrationWithServices() {
        // Get the test log record
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify integration with services
        Assert.areNotEqual(null, controller.timeZoneOffset, 'AdminService.getUserTimezoneOffset() should be called');
        // Note: BlurModeService integration is tested through isBlurMode property
        // Note: ConnectedOrgService integration is tested through instanceUrl property
    }

    @IsTest
    static void testConstructor_BlurModeBehavior() {
        // Get the test log record
        Log__c testLog = [SELECT Id FROM Log__c WHERE Category__c = 'DeployResultsTest' LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.DeployResultsViewer;
        pageRef.getParameters().put('recordId', testLog.Id);
        Test.setCurrentPage(pageRef);
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testLog);
        
        Test.startTest();
        DeployResultsViewerController controller = new DeployResultsViewerController(stdController);
        Test.stopTest();
        
        // Verify blur mode behavior
        Assert.areNotEqual(null, controller.isBlurMode, 'isBlurMode should be initialized');
        
        if (controller.isBlurMode) {
            // When blur mode is active, data should be replaced with fake data
            Assert.areNotEqual(null, controller.data, 'Data should not be null in blur mode');
            Assert.areNotEqual('', controller.data, 'Data should not be empty in blur mode');
            Assert.isTrue(controller.data.contains('XXXXXXXXXXXXXXXXXX'), 'Data should contain fake IDs in blur mode');
            Assert.isTrue(controller.data.contains('"status":"Succeeded"'), 'Data should contain fake status in blur mode');
            Assert.areNotEqual(null, controller.blurModeUrlParameter, 'Blur mode URL parameter should be set');
        } else {
            // When blur mode is not active, data should be real
            Assert.areNotEqual(null, controller.data, 'Data should not be null when not in blur mode');
            Assert.areNotEqual('', controller.data, 'Data should not be empty when not in blur mode');
            Assert.isTrue(controller.data.contains('"status":"Succeeded"'), 'Data should contain real deploy results');
            Assert.isTrue(controller.data.contains('001000000000001'), 'Data should contain real IDs');
        }
    }
}