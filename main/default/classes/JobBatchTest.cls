@IsTest
private class JobBatchTest {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
        TestDataFactory.createConnectedOrgPassthrought();
    }

    @IsTest
    private static void test_start() {
        Test.startTest();
        JobBatch.getInstance().startBatch();
        Test.stopTest();
    }

    @IsTest
    private static void test_batchApexErrorEvent() {
        try {
            Test.startTest();
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
            update ConfigUtil.CONNECTED_ORGS_SETTINGS;
            Database.executeBatch(new Test_ErrorBatch());
            Test.stopTest();
        } catch (System.MathException e) {
        }
        Test.getEventBus().deliver();
        Test.getEventBus().deliver();
        List<Log__c> logs = [SELECT Id, Type__c, Summary__c, Hash_1__c FROM Log__c];
        System.assertEquals('System.MathException', logs[0].Type__c);
        System.assertEquals('Divide by 0', logs[0].Summary__c);
    }

    @IsTest
    private static void test_batchApexErrorEmail() {
        try {
            Test.startTest();
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
            update ConfigUtil.CONNECTED_ORGS_SETTINGS;
            Database.executeBatch(new Test_ErrorBatch());
            Test.stopTest();
        } catch (System.MathException e) {
        }
        Test.getEventBus().deliver();
        Test.getEventBus().deliver();
        List<AsyncApexJob> asyncApexJobs = [SELECT Id FROM AsyncApexJob];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Developer script exception from ' + UserInfo.getOrganizationName() + ' : Test_ErrorBatch for job ID ' + asyncApexJobs[0].Id + '. : Divide by 0';
        email.plainTextBody = 'Apex script unhandled exception by user/organization: ' + UserInfo.getUserId().toString().left(15) + '/' + UserInfo.getOrganizationId().toString().left(15) + '\n' +
                '\n' +
                'Failed to process Queueable job for class Test_ErrorBatch for job ID ' + asyncApexJobs[0].Id + '.\n' +
                '\n' +
                'caused by: System.MathException: Divide by 0\n' +
                '\n' +
                'Class.Test_ErrorBatch.execute: line 17, column 1';
        email.fromAddress = 'system@salesforce.com';
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        List<Log__c> logs = [SELECT Id, Type__c, Summary__c, Hash_1__c FROM Log__c];
        System.assertEquals(false, logs.isEmpty());
        System.assertEquals(1, logs.size());
    }

    @IsTest
    private static void test_execute() {
        Test.startTest();
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class));
        jobBatch.finish(null);
        Test.stopTest();
        List<Log__c> lstLogs = [SELECT Id, Area__c FROM Log__c WHERE Async_Job_Id__c = '707KK00000KKK11KKK'];
        if (!lstLogs.isEmpty()) {
            System.assertEquals(1, lstLogs.size());
            System.assertEquals('AsyncApexJob', lstLogs[0].Area__c);
        }
    }

    @IsTest
    private static void test_execute_passthrought() {
        Test.startTest();
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(JobBatch.LOG_FIELDS)
                .add(QBuilder.condition(Log__c.Hash_1__c.getDescribe().getName()).isIn(new List<String>{'wAhZERa30MnOrejvDepb+y96StqoPKD4LOIH1Yg6nlA='}))
                .build();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.QUERY_ALL_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), getLogs());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class));
        jobBatch.finish(null);
        Test.stopTest();
        List<Log__c> lstLogs = [SELECT Id, Area__c FROM Log__c WHERE Async_Job_Id__c = '707KK00000KKK11KKK'];
        if (!lstLogs.isEmpty()) {
            System.assertEquals(1, lstLogs.size());
            System.assertEquals('AsyncApexJob', lstLogs[0].Area__c);
        }
    }

    private static TestDataFactory.SingleRequestMock getLogs() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                TestDataFactory.LOGS_QUERY_ALL_JSON
        );
        return singleRequestMock;
    }

}