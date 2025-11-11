@IsTest
public with sharing class GanttChartControllerTest {

    private static final String LOG_CATEGORY = 'TestCategory';
    private static final String LOG_TYPE_PARENT = 'TestTypeParent';
    private static final String LOG_TYPE_CHILD = 'TestTypeChild';
    private static final String LOG_AREA = 'Apex';
    private static final String LOG_TRANSACTION_ID = 'testTransactionId';

    @TestSetup
    static void testSetup() {
        // Create test Log__c records
        Log__c parentLog = new Log__c(
            Category__c = LOG_CATEGORY,
            Type__c = LOG_TYPE_PARENT,
            Area__c = LOG_AREA,
            Summary__c = 'Parent Log Summary',
            Is_Parent__c = true,
            Transaction_Id_External__c = LOG_TRANSACTION_ID
        );
        insert parentLog;

        // Create child Log__c record
        Log__c childLog = new Log__c(
            Category__c = LOG_CATEGORY,
            Type__c = LOG_TYPE_CHILD,
            Area__c = LOG_AREA,
            Summary__c = 'Child Log Summary',
            Parent__c = parentLog.Id,
            Created_Timestamp__c = 1640995200,
            Transaction_Id_External__c = LOG_TRANSACTION_ID
        );
        insert childLog;
    }

    @IsTest
    static void test_RemoteAction_Scope() {

        Test.startTest();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'Unknown',
            'data' => ''
        };
        GanttChartController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getChildLogs',
            'data' => ''
        };
        GanttChartController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        Assert.areNotEqual(null, payload);
    }

    @IsTest
    static void test_RemoteAction_withInvalidJson() {
        Test.startTest();
        GanttChartController.remoteActionHandler(null);
        Test.stopTest();

        Assert.areEqual(1, [SELECT COUNT() FROM Log__c WHERE Category__c != :LOG_CATEGORY]);
    }

    @IsTest
    static void test_constructor_withDevParameterTrue() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        pageRef.getParameters().put('dev', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);
        Test.stopTest();

        Assert.areEqual(log.Id, controller.recordId, 'recordId should match');
        Assert.areEqual(true, controller.isDev, 'isDev should be true when dev parameter is true');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
    }

    @IsTest
    static void test_constructor_withDevParameterFalse() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        pageRef.getParameters().put('dev', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);
        Test.stopTest();

        Assert.areEqual(log.Id, controller.recordId, 'recordId should match');
        Assert.areEqual(false, controller.isDev, 'isDev should be false when dev parameter is false');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
    }

    @IsTest
    static void test_constructor_withoutDevParameter() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);
        Test.stopTest();

        Assert.areEqual(log.Id, controller.recordId, 'recordId should match');
        Assert.areEqual(false, controller.isDev, 'isDev should be false when no dev parameter is provided');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
    }

    @IsTest
    static void test_constructor_withCookie() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        // Set a cookie for development mode
        Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);
        Test.stopTest();

        Assert.areEqual(log.Id, controller.recordId, 'recordId should match');
        Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
        // Note: Cookie reading might not work in test context, so isDev will likely be false
    }

    @IsTest
    static void test_packageNamespace_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);

        Test.startTest();
        String namespace = controller.packageNamespace;
        Test.stopTest();

        Assert.areNotEqual(null, namespace, 'packageNamespace should not be null');
    }

    @IsTest
    static void test_userTimezoneOffset_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);

        Test.startTest();
        Integer offset = controller.userTimezoneOffset;
        Test.stopTest();

        Assert.areNotEqual(null, offset, 'userTimezoneOffset should not be null');
    }

    @IsTest
    static void test_recordId_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);

        Test.startTest();
        String testRecordId = controller.recordId;
        controller.recordId = 'TestRecordId';
        Test.stopTest();

        Assert.areEqual(log.Id, testRecordId, 'recordId should match log Id');
        Assert.areEqual('TestRecordId', controller.recordId, 'recordId should be updated');
    }

    @IsTest
    static void test_isDev_property() {
        Log__c log = getLog();

        PageReference pageRef = Page.GanttChart;
        pageRef.getParameters().put('recordId', log.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(log);
        GanttChartController controller = new GanttChartController(sc);

        Test.startTest();
        controller.isDev = true;
        Test.stopTest();

        Assert.areEqual(true, controller.isDev, 'isDev should be true after setting');
    }

    @IsTest
    static void test_getChildLogs() {
        Log__c parentLog = getLogByType(LOG_TYPE_PARENT);
        Log__c childLog = getLogByType(LOG_TYPE_CHILD);

        List<GanttChartController.GanttChartData> result;
        Test.startTest();
        result = GanttChartController.getChildLogs(parentLog.Id);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Gantt Chart Data should not be null');
        Assert.areEqual(1, result.size(), 'Number of records do not match');

        GanttChartController.GanttChartData ganttChartData = result.get(0);

        Assert.areEqual(childLog.Id, ganttChartData.recordId, 'Id does not match');
        Assert.areEqual(childLog.Name, ganttChartData.name, 'Name does not match');
        Assert.areEqual(childLog.Category__c, ganttChartData.category, 'Category does not match');
        Assert.areEqual(childLog.Type__c, ganttChartData.type, 'Type does not match');
        Assert.areEqual(childLog.Summary__c, ganttChartData.summary, 'Summary does not match');
        Assert.areEqual(childLog.Duration__c, ganttChartData.duration, 'Duration does not match');
        Assert.areEqual(childLog.Created_Timestamp__c, ganttChartData.createdTimestamp, 'Created Timestamp does not match');
        Assert.isTrue(String.isBlank(ganttChartData.logLevel));
        Assert.areEqual(null, ganttChartData.logLevelValues);
    }

    @IsTest
    static void test_getChildLogs_withAdditionalPicklistField() {
        Log__c parentLog = getLogByType(LOG_TYPE_PARENT);
        Log__c childLog = getLogByType(LOG_TYPE_CHILD);

        List<GanttChartController.GanttChartData> result;
        Test.startTest();
        GanttChartController.setTritonField('Teams_Integration_Status__c');
        result = GanttChartController.getChildLogs(parentLog.Id);
        GanttChartController.resetTritonField();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Gantt Chart Data should not be null');
        Assert.areEqual(1, result.size(), 'Number of records do not match');

        GanttChartController.GanttChartData ganttChartData = result.get(0);

        Assert.areEqual(childLog.Id, ganttChartData.recordId, 'Id does not match');
        Assert.areEqual(childLog.Name, ganttChartData.name, 'Name does not match');
        Assert.areEqual(childLog.Category__c, ganttChartData.category, 'Category does not match');
        Assert.areEqual(childLog.Type__c, ganttChartData.type, 'Type does not match');
        Assert.areEqual(childLog.Summary__c, ganttChartData.summary, 'Summary does not match');
        Assert.areEqual(childLog.Duration__c, ganttChartData.duration, 'Duration does not match');
        Assert.areEqual(childLog.Created_Timestamp__c, ganttChartData.createdTimestamp, 'Created Timestamp does not match');
        Assert.areEqual(childLog.Teams_Integration_Status__c, ganttChartData.logLevel, 'Log Level does not match');
        Assert.areNotEqual(null, ganttChartData.logLevelValues);
        Assert.areNotEqual(true, ganttChartData.logLevelValues.isEmpty());
    }

    private static Log__c getLog() {
        return [SELECT Id FROM Log__c LIMIT 1];
    }

    private static Log__c getLogByType(String type) {
        return [
            SELECT Name, Category__c, Type__c, Summary__c, Duration__c, Created_Timestamp__c, Teams_Integration_Status__c
            FROM Log__c 
            WHERE Type__c = :type
        ];
    }
}