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

    /**
     * Test: Passthrough mode email with dual index creation
     * Verifies that when email arrives at target org with pre-calculated simple hashes from source org,
     * both simple hash index and correct hash index are created with proper lookup
     */
    @IsTest
    static void test_passthrough_email_creates_dual_indexes() {
        // Setup: Create connected org for passthrough
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        
        // Simulate source org sending email with AsyncApexJobId
        // Use current org as source org (it has Connected_Org__c record)
        String sourceOrgId = UserInfo.getOrganizationId().left(15);
        String asyncApexJobId = '707000000000001'; // Fake AsyncApexJob ID
        
        // Pre-calculated simple hash from source org (calculated from AsyncApexJob details)
        String simpleHash = 'simpleHashFromSourceOrg123';
        
        // Create plain text email body - copy format from passing test and add AsyncApexJobId pattern
        // The pattern MUST match ApexExceptionParser.PATTERN_FOR_JOB_ID: "for job id '(707[a-zA-Z0-9]{12,15})'"
        String emailBody = 'Apex script unhandled exception by user/organization: ' + sourceOrgId + '\n\n' +
                          'Source organization: Source Org\n\n' +
                          'Failed to process batch for class \'TestBatchClass\' for job id \'' + asyncApexJobId + '\'\n\n' +
                          'System.DmlException: Insert failed.\n\n' +
                          'Class.TestBatchClass.execute: line 10, column 1\n' +
                          'Class.TestBatchClass.processRecords: line 25, column 1';
        
        // Create IncomingLogData with email and simple hash map
        PassthroughtModeService.IncomingLogData incomingLogData = new PassthroughtModeService.IncomingLogData();
        incomingLogData.logs = null;
        incomingLogData.organizationId = sourceOrgId;
        incomingLogData.inboundEmail = new Inbound_Email__c();
        incomingLogData.inboundEmail.From__c = 'noreply@salesforce.com';
        incomingLogData.inboundEmail.Subject__c = 'Batch Apex Error for job ' + asyncApexJobId;
        incomingLogData.inboundEmail.Plain_Text__c = emailBody; // Use Plain_Text__c for Apex errors
        incomingLogData.inboundEmail.Html_Body__c = null; // Explicitly set null
        incomingLogData.inboundEmail.Pharos_Org_ID__c = sourceOrgId;
        
        // CRITICAL: Pre-calculated simple hash from source org
        incomingLogData.asyncJobIdToSimpleHash = new Map<String, String>{
            asyncApexJobId => simpleHash
        };
        
        // Create REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REST_URI;
        req.addParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_PASSTHROUGH_MODE);
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(incomingLogData));
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        PermissionsUtil.AsyncProcessErrorTracking = true;
        LogRestService.doPost();
        Test.stopTest();
        
        // Verify: Log was created
        List<Log__c> logs = [
            SELECT Id, Hash_1__c, Async_Job_Id__c, Stacktrace__c, Organization_Id__c
            FROM Log__c
            WHERE Organization_Id__c = :sourceOrgId
        ];
        System.assertEquals(1, logs.size(), 'Should create exactly one log');
        
        Log__c createdLog = logs[0];
        System.assertNotEquals(null, createdLog.Hash_1__c, 'Log should have correct hash (from stacktrace)');
        System.assertNotEquals(null, createdLog.Stacktrace__c, 'Log should have stacktrace');
        
        // CRITICAL: Verify AsyncApexJobId was extracted from email
        System.assertEquals(asyncApexJobId, createdLog.Async_Job_Id__c, 
            'AsyncApexJobId should be extracted from email body. This is required for dual index creation.');
        
        String correctHash = createdLog.Hash_1__c;
        
        // CRITICAL VALIDATION: Verify dual indexes were created
        
        // 1. Verify correct hash index exists
        String correctIndexKey = ConfigUtil.getLogIndexKey(correctHash, sourceOrgId);
        List<Log_Index__c> correctIndexes = [
            SELECT Id, Hash__c, Key__c, Organization_Id__c, First_Occurred_On__c
            FROM Log_Index__c
            WHERE Key__c = :correctIndexKey
        ];
        System.assertEquals(1, correctIndexes.size(), 
            'Should create exactly one correct hash index');
        System.assertEquals(correctHash, correctIndexes[0].Hash__c,
            'Correct hash index should have correct hash from stacktrace');
        System.assertEquals(sourceOrgId, correctIndexes[0].Organization_Id__c,
            'Correct hash index should belong to source org');
        
        // 2. Verify simple hash index exists
        String simpleIndexKey = ConfigUtil.getLogIndexKey(simpleHash, sourceOrgId);
        List<Log_Index__c> simpleIndexes = [
            SELECT Id, Hash__c, Key__c, Organization_Id__c, Correct_Hash_Index__c, 
                   Correct_Hash_Index__r.Hash__c, Correct_Hash_Index__r.Key__c
            FROM Log_Index__c
            WHERE Key__c = :simpleIndexKey
        ];
        System.assertEquals(1, simpleIndexes.size(), 
            'Should create exactly one simple hash index');
        System.assertEquals(simpleHash, simpleIndexes[0].Hash__c,
            'Simple hash index should have simple hash from source org');
        System.assertEquals(sourceOrgId, simpleIndexes[0].Organization_Id__c,
            'Simple hash index should belong to source org');
        
        // 3. CRITICAL: Verify Correct_Hash_Index__c lookup is set
        System.assertNotEquals(null, simpleIndexes[0].Correct_Hash_Index__c,
            'Simple hash index MUST have lookup to correct hash index');
        System.assertEquals(correctIndexes[0].Id, simpleIndexes[0].Correct_Hash_Index__c,
            'Simple hash index should point to correct hash index');
        System.assertEquals(correctHash, simpleIndexes[0].Correct_Hash_Index__r.Hash__c,
            'Lookup should point to correct hash index with correct hash');
        
        // 4. Verify hashes are different (simple vs correct)
        System.assertNotEquals(simpleHash, correctHash,
            'Simple hash (from AsyncApexJob) should differ from correct hash (from stacktrace)');
        
        // Verify response
        String jsonResponse = res.responseBody.toString();
        System.assertNotEquals(null, jsonResponse, 'Should return response');
    }

    /**
     * Test: Passthrough mode email without AsyncApexJobId (no dual indexes)
     * Verifies that emails without AsyncApexJobId only create correct hash index
     */
    @IsTest
    static void test_passthrough_email_without_asyncjobid() {
        // Setup: Create connected org for passthrough
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        
        // Use current org as source org (it has Connected_Org__c record)
        String sourceOrgId = UserInfo.getOrganizationId().left(15);
        
        // Email body WITHOUT AsyncApexJobId (standard Apex exception format)
        String emailBody = 'Apex script unhandled exception by user/organization: ' + sourceOrgId + '\n\n' +
                          'Source organization: Source Org\n\n' +
                          'System.NullPointerException: Attempt to de-reference a null object\n\n' +
                          'Class.MyClass.myMethod: line 15, column 1\n' +
                          'Class.MyClass.process: line 30, column 1';
        
        // Create IncomingLogData without simple hash map
        PassthroughtModeService.IncomingLogData incomingLogData = new PassthroughtModeService.IncomingLogData();
        incomingLogData.logs = null;
        incomingLogData.organizationId = sourceOrgId;
        incomingLogData.inboundEmail = new Inbound_Email__c();
        incomingLogData.inboundEmail.From__c = 'noreply@salesforce.com';
        incomingLogData.inboundEmail.Subject__c = 'Apex Error';
        incomingLogData.inboundEmail.Plain_Text__c = emailBody;
        incomingLogData.inboundEmail.Html_Body__c = null; // Use plain text
        incomingLogData.inboundEmail.Pharos_Org_ID__c = sourceOrgId;
        
        // No asyncJobIdToSimpleHash map (or empty)
        incomingLogData.asyncJobIdToSimpleHash = new Map<String, String>();
        
        // Create REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REST_URI;
        req.addParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_PASSTHROUGH_MODE);
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(incomingLogData));
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        LogRestService.doPost();
        Test.stopTest();
        
        // Verify: Log was created
        List<Log__c> logs = [
            SELECT Id, Hash_1__c, Async_Job_Id__c
            FROM Log__c
            WHERE Organization_Id__c = :sourceOrgId
        ];
        System.assertEquals(1, logs.size(), 'Should create exactly one log');
        System.assertNotEquals(null, logs[0].Hash_1__c, 'Log should have hash');
        System.assertEquals(null, logs[0].Async_Job_Id__c, 'Log should NOT have AsyncApexJobId');
        
        // Verify: Only correct hash index created (no simple hash index)
        List<Log_Index__c> indexes = [
            SELECT Id, Hash__c, Correct_Hash_Index__c
            FROM Log_Index__c
            WHERE Organization_Id__c = :sourceOrgId
        ];
        System.assertEquals(1, indexes.size(), 
            'Should create exactly ONE index (correct hash only, no simple hash)');
        System.assertEquals(logs[0].Hash_1__c, indexes[0].Hash__c,
            'Index should have correct hash from log');
        System.assertEquals(null, indexes[0].Correct_Hash_Index__c,
            'Correct hash index should NOT have lookup (it IS the correct hash)');
    }

}