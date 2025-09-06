@IsTest
private class LogRestServiceTest {

    private static final String REST_URI = '/services/apexrest/'+ ConfigUtil.nameSpacePrefix +'/logs/';

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
    }

    @IsTest
    static void test_retrieve_logs_success() {
        Log__c log = new Log__c();
        insert log;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doGet();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);

        System.assertEquals(LogRestService.STATUS_SUCCESS, (String)result.get('status'));
        System.assertEquals(null, result.get('error'));
        System.assertNotEquals(null, (List<Object>)result.get('logs'));
        System.assertNotEquals(0, ((List<Object>)result.get('logs')).size());
    }

    @IsTest
    static void test_retrieve_logs_fail() {
        Log__c log = new Log__c();
        insert log;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        req.addParameter('startDate', 'wrong date');
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doGet();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        System.assertEquals(LogRestService.STATUS_FAIL, (String)result.get('status'));
        System.assertNotEquals(null, result.get('error'));
        System.assertEquals(null, (List<Object>)result.get('logs'));
    }

    @IsTest
    static void test_retrieve_logs_filter_by_start_date_success() {
        Log__c log = new Log__c();
        insert log;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        DateTime dt = DateTime.now().addHours(-2);
        String dtString = dt.format(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
        req.addParameter('startDate', dtString);
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doGet();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        System.assertEquals(LogRestService.STATUS_SUCCESS, (String)result.get('status'));
        System.assertEquals(null, result.get('error'));
        System.assertNotEquals(null, (List<Object>)result.get('logs'));
        System.assertNotEquals(0, ((List<Object>)result.get('logs')).size());

    }

    @IsTest
    static void test_retrieve_logs_filter_by_start_date_fail() {
        Log__c log = new Log__c();
        insert log;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        DateTime dt = DateTime.now().addDays(1);
        String dtString = dt.format(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
        req.addParameter('startDate', dtString);
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doGet();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        System.assertEquals(LogRestService.STATUS_SUCCESS, (String)result.get('status'));
        System.assertEquals(null, result.get('error'));
        System.assertNotEquals(null, (List<Object>)result.get('logs'));
        System.assertEquals(0, ((List<Object>)result.get('logs')).size());
    }

    @IsTest
    static void test_send_logs_broadcast() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        req.addParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_BROADCAST);
        req.httpMethod = 'POST';
        BroadcastService.IncomingData incomingData = new BroadcastService.IncomingData();
        Log__c log = new Log__c();
        log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        log.Post_Processing_Complete__c = true;
        incomingData.logs = new List<Log__c>{log};
        incomingData.organizationId = UserInfo.getOrganizationId().left(15);
        req.requestBody = Blob.valueOf(JSON.serialize(incomingData));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doPost();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

    @IsTest
    static void test_send_logs_passthrough_mode() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        req.addParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_PASSTHROUGH_MODE);
        req.httpMethod = 'POST';
        PassthroughtModeService.IncomingLogData incomingLogData = new PassthroughtModeService.IncomingLogData();
        Log__c log = new Log__c();
        log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        log.Post_Processing_Complete__c = true;
        incomingLogData.logs = new List<Log__c>{log};
        incomingLogData.organizationId = UserInfo.getOrganizationId().left(15);
        req.requestBody = Blob.valueOf(JSON.serialize(incomingLogData));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doPost();
        Test.stopTest();

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

    @IsTest
    static void test_send_logs_passthrough_mode_avoid_callout_loop_exception() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = REST_URI;
        req.addParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_PASSTHROUGH_MODE);
        req.httpMethod = 'POST';
        PassthroughtModeService.IncomingLogData incomingLogData = new PassthroughtModeService.IncomingLogData();
        incomingLogData.logs = null;
        incomingLogData.organizationId = UserInfo.getOrganizationId().left(15);
        incomingLogData.inboundEmail = new Inbound_Email__c();
        incomingLogData.inboundEmail.From__c = 'test@test.com';
        incomingLogData.inboundEmail.Subject__c = 'An error occurred with your "some_labels" flow';
        incomingLogData.inboundEmail.Html_Body__c = String.valueOf(Test_LogService.getTestStub('FLOW_SAME_API_LABELS_ELEMENTS_STACKTRACE'));
        incomingLogData.inboundEmail.Pharos_Org_ID__c = UserInfo.getOrganizationId().left(15);
        req.requestBody = Blob.valueOf(JSON.serialize(incomingLogData));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LogRestService.doPost();
        Test.stopTest();

        Integer calloutsAfter = Limits.getCallouts();
        System.assertEquals(0, calloutsAfter);

        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse);
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

}