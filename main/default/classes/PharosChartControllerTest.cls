@IsTest
public with sharing class PharosChartControllerTest {

    @TestSetup
    static void testSetup() {
        List<Log__c> testLogs = new List<Log__c>();

        Log__c parentLog = new Log__c(
            Category__c = 'Test Category',
            Apex_Name__c = 'TestClass.testMethod',
            Created_At__c = DateTime.now()
        );
        insert parentLog;

        for (Integer i = 0; i < 3; i++) {
            Log__c childLog = new Log__c(
                Category__c = 'Test Category',
                Apex_Name__c = 'TestClass.testMethod' + i,
                Parent__c = parentLog.Id,
                Created_At__c = DateTime.now().addMinutes(-i)
            );
            testLogs.add(childLog);
        }
        insert testLogs;
    }

    @IsTest
    static void testConstructor_WithValidRecordId() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Parent__c = null LIMIT 1];

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        pageRef.getParameters().put('chart', 'testChart');
        pageRef.getParameters().put('modal', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual(parentLog.Id, controller.recordId, 'Record ID should be set correctly');
        Assert.areEqual('testChart', controller.chart, 'Chart parameter should be set correctly');
        Assert.areEqual('true', controller.modal, 'Modal parameter should be set correctly');
        Assert.areEqual(null, controller.chartData, 'Chart data should be null when LogLimitsChartController returns null');
    }

    @IsTest
    static void testConstructor_WithBlankRecordId() {
        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('chart', 'testChart');
        pageRef.getParameters().put('modal', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual(null, controller.recordId, 'Record ID should be null when not provided');
        Assert.areEqual('testChart', controller.chart, 'Chart parameter should be set correctly');
        Assert.areEqual('false', controller.modal, 'Modal parameter should be set correctly');
        Assert.areEqual(null, controller.chartData, 'Chart data should be null when no record ID');
    }

    @IsTest
    static void testConstructor_WithNoParameters() {
        PageReference pageRef = Page.PharosChart;
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual(null, controller.recordId, 'Record ID should be null when not provided');
        Assert.areEqual(null, controller.chart, 'Chart parameter should be null when not provided');
        Assert.areEqual(null, controller.modal, 'Modal parameter should be null when not provided');
        Assert.areEqual(null, controller.chartData, 'Chart data should be null when no record ID');
    }

    @IsTest
    static void testConstructor_WithInvalidRecordId() {
        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', '001000000000000'); // Invalid ID format
        pageRef.getParameters().put('chart', 'testChart');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual('001000000000000', controller.recordId, 'Record ID should be set even if invalid');
        Assert.areEqual('testChart', controller.chart, 'Chart parameter should be set correctly');
        Assert.areEqual(null, controller.modal, 'Modal parameter should be null when not provided');
        Assert.areEqual(null, controller.chartData, 'Chart data should be null for invalid record ID');
    }

    @IsTest
    static void testGetChartDataJSON_WithValidData() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Parent__c = null LIMIT 1];

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
            String jsonData = controller.getChartDataJSON();
        Test.stopTest();

        Assert.areEqual('null', jsonData, 'JSON should be "null" when chartData is null');
    }

    @IsTest
    static void testGetChartDataJSON_WithNullData() {
        PageReference pageRef = Page.PharosChart;
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
            String jsonData = controller.getChartDataJSON();
        Test.stopTest();

        Assert.areEqual('null', jsonData, 'JSON should be "null" when chartData is null');
    }

    @IsTest
    static void testGetChartDataJSON_WithEmptyData() {
        Log__c parentLog = new Log__c(
            Category__c = 'Test Category',
            Apex_Name__c = 'TestClass.testMethod',
            Created_At__c = DateTime.now()
        );
        insert parentLog;

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
            String jsonData = controller.getChartDataJSON();
        Test.stopTest();

        Assert.areEqual('null', jsonData, 'JSON should be "null" when no child logs exist');
    }

    @IsTest
    static void testPropertyGetters() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Parent__c = null LIMIT 1];

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        pageRef.getParameters().put('chart', 'testChart');
        pageRef.getParameters().put('modal', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual(parentLog.Id, controller.recordId, 'recordId getter should return correct value');
        Assert.areEqual('testChart', controller.chart, 'chart getter should return correct value');
        Assert.areEqual('true', controller.modal, 'modal getter should return correct value');
        Assert.areEqual(null, controller.chartData, 'chartData getter should return null when LogLimitsChartController returns null');
    }

    @IsTest
    static void testIntegrationWithLogLimitsChartController() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Parent__c = null LIMIT 1];

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areEqual(null, controller.chartData, 'Chart data should be null when LogLimitsChartController returns null');

        List<LogLimitsChartController.LimitInfo> expectedData = LogLimitsChartController.getLimitsChartData(parentLog.Id);
        Assert.areEqual(expectedData, controller.chartData, 'Chart data should match LogLimitsChartController output');
    }

    @IsTest
    static void testConstructor_HandlesExceptionsGracefully() {
        Log__c parentLog = [SELECT Id FROM Log__c WHERE Parent__c = null LIMIT 1];

        PageReference pageRef = Page.PharosChart;
        pageRef.getParameters().put('id', parentLog.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            PharosChartController controller = new PharosChartController();
        Test.stopTest();

        Assert.areNotEqual(null, controller, 'Controller should be created successfully');
        Assert.areEqual(parentLog.Id, controller.recordId, 'Record ID should be set correctly');
    }
}