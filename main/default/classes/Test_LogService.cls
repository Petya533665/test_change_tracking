@IsTest
public class Test_LogService {

    public static final String CONNECTED_ORG_SETTINGS_CLIENT_KEY = 'somekey';
    public static final String CONNECTED_ORG_SETTINGS_CLIENT_SECRET = 'somesecretkey';
    public static final String LOGGER_SETTINGS_EMAIL_SERVICE_ADDRESS = 'someone@test.com';
    public static final Boolean LOGGER_SETTINGS_DEBUG_MODE = true;
    public static final String CONNECETED_ORG_NAME = '00D40000000N3x2';
    public static final String CONNECETED_ORG_TITLE = 'Test Connected Org';
    public static final String CONNECETED_ORG_DESCRIPTION = 'Test Description';
    public static final String CONNECETED_ORG_TYPE = 'production';
    public static final String CONNECETED_ORG_ACCESS_TOKEN = 'someAccessToken';
    public static final String CONNECETED_ORG_REFRESH_TOKEN = 'someRefreshToken';
    public static final DateTime CONNECETED_ORG_TOKEN_REFRESHED_AT = Datetime.now();
    public static final String CONNECETED_ORG_INSTANCE_URL = 'https://testurl.test';
    public static final String CONNECETED_ORG_IDENTITY_URL = null;

    public static String getTestStub(String name) {
        String testStub = [SELECT Body FROM StaticResource WHERE Name = 'TestStubs'].Body.toString();
        Map<String, Object> testStubMap = (Map<String, Object>)JSON.deserializeUntyped(testStub);
        return (String)testStubMap.get(name);
    }

    public static List<Object> getTestStubList(String name) {
        String testStub = [SELECT Body FROM StaticResource WHERE Name = 'TestStubs'].Body.toString();
        Map<String, Object> testStubMap = (Map<String, Object>)JSON.deserializeUntyped(testStub);
        return (List<Object>)testStubMap.get(name);
    }

    public static void initSettings() {
        Connected_Orgs_Settings__c connectedOrgsSettings = new Connected_Orgs_Settings__c(
            Client_Key__c = CONNECTED_ORG_SETTINGS_CLIENT_KEY,
            Client_Secret__c = CONNECTED_ORG_SETTINGS_CLIENT_SECRET
        );
        insert connectedOrgsSettings;

        Logger_Settings__c settings = new Logger_Settings__c(
            Email_Service_Address__c = LOGGER_SETTINGS_EMAIL_SERVICE_ADDRESS,
            Debug__c = LOGGER_SETTINGS_DEBUG_MODE,
            Web_2_Lead_Parser_Enabled__c = true
        );
        insert settings;
        
        Connected_Org__c corg = new Connected_Org__c(
            Name = CONNECETED_ORG_NAME,
            Title__c = CONNECETED_ORG_TITLE,
            Description__c = CONNECETED_ORG_DESCRIPTION,
            Type__c = CONNECETED_ORG_TYPE,
            Access_Token__c = CONNECETED_ORG_ACCESS_TOKEN,
            Refresh_Token__c = CONNECETED_ORG_REFRESH_TOKEN,
            Token_Refreshed_At__c = CONNECETED_ORG_TOKEN_REFRESHED_AT,
            Instance_Url__c = CONNECETED_ORG_INSTANCE_URL,
            Identity_Url__c = CONNECETED_ORG_IDENTITY_URL
        );
        Connected_Org__c selfCorg = new Connected_Org__c(
            Name = UserInfo.getOrganizationId().left(15),
            Instance_Url__c = System.Url.getOrgDomainUrl().toExternalForm(),
            Title__c = CONNECETED_ORG_TITLE,
            Description__c = CONNECETED_ORG_DESCRIPTION
        );
        insert new List<Connected_Org__c>{corg, selfCorg};
    }

    @IsTest
    static void test_failed_trigger () {
        initSettings();
        Test.startTest();
        String exceptionBody = String.valueOf(getTestStubList('testExceptionEmails').get(0));
        Log__c log = LogService.createLogFromEmailBody(exceptionBody, 'Test Email', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_failed_batch () {
        initSettings();
        Test.startTest();
        String exceptionBody = String.valueOf(getTestStubList('testExceptionEmails').get(1));
        Log__c log = LogService.createLogFromEmailBody(exceptionBody, 'Test Email', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_failed_batch_full_stack () {
        initSettings();
        Test.startTest();
        String exceptionBody = String.valueOf(getTestStubList('testExceptionEmails').get(2));
        Log__c log = LogService.createLogFromEmailBody(exceptionBody, 'Test Email', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_failed_queueable_job () {
        initSettings();
        Test.startTest();
        String exceptionBody = String.valueOf(getTestStubList('testExceptionEmails').get(3));
        Log__c log = LogService.createLogFromEmailBody(exceptionBody, 'Test Email', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_visualforce_exception_email () {
        initSettings();
        Test.startTest();
        Log__c log = LogService.createLogFromEmailBody(getTestStub('visualforceExceptionEmail'), 'Test Email', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_web2Lead_trigger () {
        initSettings();
        Test.startTest();
        String exceptionBody = 'Salesforce could not create this lead because of the reason listed below. For more information about this error or help with Web-to-Lead, please contact Customer Support.\n' +
                '\n' +
                'Reason: Apex trigger testpharosx.LEadTrigger caused an unexpected exception, contact your administrator: testpharosx.LEadTrigger: execution of AfterInsert\n' +
                '\n' +
                'caused by: System.FinalException: Record is read-only: Class.testpharosx.LeadHelper.insertLeads: line 5, column 1\n' +
                '    Lead Capture Page: Not available.\n' +
                '\n' +
                'Record Information:\n' +
                '\n' +
                '    city = asd \n' +
                '    company = asd \n' +
                '    email = useremail@gmail.com \n' +
                '    encoding = UTF-8 \n' +
                '    encoding = UTF-8 \n' +
                '    first_name = asdas \n' +
                '    last_name = asdas \n' +
                '    oid = '+CONNECETED_ORG_NAME+' \n' +
                '    retURL = https://pharosdev11-dev-ed.my.salesforce.com/ \n' +
                '    state = asd \n' +
                '    submit = Submit \n' +
                '\n' +
                'To incorporate this lead into salesforce.com you can key in the data above.\n' +
                '\n' +
                'If you have any questions, please click on Support at the top right of any page within salesforce.com.\n' +
                '\n' +
                'Customer Support\n' +
                'salesforce.com';
        Log__c log = LogService.createLogFromEmailBody(exceptionBody, 'Salesforce Could Not Create This Lead', 'test@test.com', Datetime.now());
        Test.stopTest();
        System.assertNotEquals(null, log);
    }

    @IsTest
    static void test_apex_hash1 () {
        initSettings();
        Test.startTest();
        String exceptionBody1 = 'Apex script unhandled trigger exception by user/organization: 0055Y00000HkHld/' + CONNECETED_ORG_NAME +'\n' +
            '\n' +
            'JobOpeningTrigger: execution of AfterInsert\n' +
            '\n' +
            'caused by: System.DmlException: Update failed. First exception on row 0 with id a2q4z000008bhq6AAA; first error: STRING_TOO_LONG, Job Opening Name: data value too large: 001798-Front Range Roofing Systems, LLC- Corporate-Estimator - Roofing / Xactimate (max length=80): [Name]\n' +
            '\n' +
            'Class.JobOpeningTriggerHandler.setJobOpeningName: line 75, column 1\n' +
            'Class.JobOpeningTriggerHandler.afterInsert: line 18, column 1\n' +
            'Class.TriggerHandler.run: line 62, column 1\n' +
            'Trigger.JobOpeningTrigger: line 6, column 1';
        String exceptionBody2 = 'Apex script unhandled trigger exception by user/organization: 0055Y00000HlAQW/' + CONNECETED_ORG_NAME + '\n' +
            '\n' +
            'JobOpeningTrigger: execution of AfterInsert\n' +
            '\n' +
            'caused by: System.DmlException: Update failed. First exception on row 0 with id a2q4z000008bUSqAAM; first error: STRING_TOO_LONG, Job Opening Name: data value too large: 000858-Radyne Corporation: An Inductotherm Group Company-BIM Engineer - Mechanical (max length=80): [Name]\n' +
            '\n' +
            'Class.JobOpeningTriggerHandler.setJobOpeningName: line 75, column 1\n' +
            'Class.JobOpeningTriggerHandler.afterInsert: line 18, column 1\n' +
            'Class.TriggerHandler.run: line 62, column 1\n' +
            'Trigger.JobOpeningTrigger: line 6, column 1';
        Log__c log1 = LogService.createLogFromEmailBody(exceptionBody1, 'Test Email', 'test@test.com', Datetime.now());
        Log__c log2 = LogService.createLogFromEmailBody(exceptionBody2, 'Test Email', 'test@test.com', Datetime.now());

        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log1, log2}, Schema.SObjectType.Log__c)
            .handleError(LogService.class.getName(), '.', null);


        Test.stopTest();
        log1 = [SELECT Hash_1__c FROM Log__c WHERE Id =:log1.Id LIMIT 1];
        log2 = [SELECT Hash_1__c FROM Log__c WHERE Id =:log2.Id LIMIT 1];
        System.assertNotEquals(null, log1.Hash_1__c);
        System.assertEquals(log2.Hash_1__c, log1.Hash_1__c);
    }

    @IsTest
    static void test_errors_remove_extra_details_CIRCULAR_DEPENDENCY() {
        test_errors_remove_extra_details('Error Occurred: The flow tried to update these records: 5004z00001hDUSHAA4. This error occurred: CIRCULAR_DEPENDENCY: Hierarchy Constraint Violation. You can look up ExceptionCode values in the SOAP API Developer Guide.','CIRCULAR_DEPENDENCY: Hierarchy Constraint Violation');
    }

    @IsTest
    static void test_errors_remove_extra_details_DUPLICATE_VALUE() {
        test_errors_remove_extra_details('The flow tried to update these records: null. This error occurred: DUPLICATE_VALUE: Maximum number of duplicate updates in one batch (12 allowed). Attempt to update Id more than once in this Api call: a0L5e000003vWHl. You can look up ExceptionCode valu...','DUPLICATE_VALUE: Maximum number of duplicate updates in one batch (12 allowed). Attempt to update Id more than once in this Api call');
    }

    @IsTest
    static void test_errors_remove_extra_details_DUPLICATE_VALUE2() {
        test_errors_remove_extra_details('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','DUPLICATE_VALUE, duplicate value found');
    }

    @IsTest
    static void test_errors_remove_extra_details_FIELD_CUSTOM_VALIDATION_EXCEPTION() {
        test_errors_remove_extra_details('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: ContentTrigger: execution of AfterDelete  caused by: System.DmlException: Update failed. First exception on row 0 with id a0V4y00000WYElaEAH; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, No Access By Org!: []  C...','FIELD_CUSTOM_VALIDATION_EXCEPTION, No Access By Org!');
    }

    @IsTest
    static void test_errors_remove_extra_details_CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY() {
        test_errors_remove_extra_details('The flow tried to update these records: 0011a00000vQUWfAAO. This error occurred: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: PFLSwagIQ.AccountTrigger: System.LimitException: Apex CPU time limit exceeded. You can look up ExceptionCode values in the SOAP API D...','CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: PFLSwagIQ.AccountTrigger');
    }

    @IsTest
    static void test_errors_remove_extra_details_CANNOT_EXECUTE_FLOW_TRIGGER() {
        test_errors_remove_extra_details('The flow tried to update these records: 0015f00000EYLPNAA5. This error occurred: CANNOT_EXECUTE_FLOW_TRIGGER: We can\'t save this record because the "acc" process failed. Give your Salesforce admin these details. This error occurred when the flow tried ...','CANNOT_EXECUTE_FLOW_TRIGGER: We can\'t save this record because the "acc" process failed');
    }

    @IsTest
    static void test_errors_remove_extra_details_APEX_DATA_ACCESS_RESTRICTION() {
        test_errors_remove_extra_details('System.DmlException: Insert failed. First exception on row 0; first error: APEX_DATA_ACCESS_RESTRICTION, In parallel Apex tests, DML operations aren\'t permitted on this type of object: User: []','APEX_DATA_ACCESS_RESTRICTION, In parallel Apex tests, DML operations aren\'t permitted on this type of object');
    }

    @IsTest
    static void test_errors_remove_extra_details_INSUFFICIENT_ACCESS_OR_READONLY() {
        test_errors_remove_extra_details('Delete failed. First exception on row 0 with id a0q8Z00000CkM6RQAV; first error: INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id: []','INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id');
    }

    @IsTest
    static void test_errors_remove_extra_details_FIELD_CUSTOM_VALIDATION_EXCEPTION2() {
        test_errors_remove_extra_details('The flow tried to update these records: 0035f000007nFeTAAU. This error occurred: FIELD_CUSTOM_VALIDATION_EXCEPTION: fax 123. You can look up ExceptionCode values in the SOAP API Developer Guide.','FIELD_CUSTOM_VALIDATION_EXCEPTION: fax 123');
    }

    @IsTest
    static void test_errors_remove_extra_details_FIELD_FILTER_VALIDATION_EXCEPTION() {
        test_errors_remove_extra_details('Update failed. First exception on row 0 with id a385Y000001NWvGQAW; first error: FIELD_FILTER_VALIDATION_EXCEPTION, User should be Active: [User__c]','FIELD_FILTER_VALIDATION_EXCEPTION, User should be Active');
    }

    @IsTest
    static void test_errors_remove_extra_details_FIELD_FILTER_VALIDATION_EXCEPTION2() {
        test_errors_remove_extra_details('Error Occurred: The flow tried to update these records: 0035Y00004PjeCrQAJ. This error occurred: FIELD_FILTER_VALIDATION_EXCEPTION: Value does not exist or does not match filter criteria.. You can look up ExceptionCode values in the SOAP API Developer ...','FIELD_FILTER_VALIDATION_EXCEPTION: Value does not exist or does not match filter criteria');
    }

    @IsTest
    static void test_errors_remove_extra_details_FIELD_INTEGRITY_EXCEPTION() {
        test_errors_remove_extra_details('This error occurred when the flow tried to create records: FIELD_INTEGRITY_EXCEPTION: Name ID: id value of incorrect type: 0016s00000RxRSIAA3. You can look up ExceptionCode values in the SOAP API Developer Guide.','FIELD_INTEGRITY_EXCEPTION: Name ID');
    }

    @IsTest
    static void test_errors_remove_extra_details_INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY() {
        test_errors_remove_extra_details('Update failed. First exception on row 0 with id a0w4y00000EsPhtAAF; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: []','INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id');
    }


    static void test_errors_remove_extra_details(String testSummary, String expectedResult) {
        initSettings();
        Test.startTest();
        System.assertEquals(expectedResult, LogService.removeExtraErrorDetails(testSummary));
        Test.stopTest();
    }

    @IsTest
    static void test_handle_failed_inbound_flow_error() {
        initSettings();
        ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD = 1200;

        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com','testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "GovnopaketFlowContact1" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = '';

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_SAME_API_LABELS_ELEMENTS_STACKTRACE'));
        
        for(Integer i = 0; i < 1000; i++) {
            email.htmlBody += testStubStacktrace;
        }
        System.assertEquals(true, email.htmlBody.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(Test_StackTraceParser.createPostProcessingMock('same_labels', 'testpharosx', 1));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LogTriggerHelper.runPostProcessingBatchInTest = true;
        
        Test.startTest();
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, (SELECT Id FROM ContentDocumentLinks), Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog);
        System.assertEquals(1, failedFlowLog.ContentDocumentLinks.size());
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_FAILED, failedFlowLog.Post_Processing_Status__c);
    }

    @IsTest
    private static void test_generate_hash1_with_guids() {
        String valueTemplate = 'HttpUtilsException:[]: 401: "error":"invalid_client","error_description":"AADSTS7000222: The provided client secret keys for app "{0}" are expired. Visit the Azure portal to create new keys for your app: https://aka.ms/NewClientSecret, or consider using certificate credentials for added security: https://aka.ms/certCreds. Trace ID: {1} Correlation ID: {2} Timestamp: 2024-03-13 20:25:02Z","error_codes":[7000222],"timestamp":"2024-03-13 20:25:02Z","trace_id":"{3}","correlation_id":"{4}","error_uri":"https://login.microsoftonline.com/error?code=7000222"';
        String hash1 = null;

        for(Integer i = 0 ; i < 10; i++) {
            String value = String.format(valueTemplate, new List<String>{ConfigUtil.generateUUID4(), ConfigUtil.generateUUID4(), ConfigUtil.generateUUID4(), ConfigUtil.generateUUID4(), ConfigUtil.generateUUID4()});
            String hash = LogService.generateHash_1(value);
            if(hash1 == null) {
                hash1 = hash;
            }
            System.assertEquals(hash1, hash);
        }

    }

    @IsTest
    private static void test_getEmailBody_plainText_old() {
        test_getEmailBody(true, 'Apex script unhandled exception by user/organization: 0054R00000BKhA/00D8N000001Ghs4', '');
    }

    @IsTest
    private static void test_getEmailBody_plainText_new() {
        test_getEmailBody(true, 'Apex script unhandled exception by user/organization: 0054R00000BKhA/00D8N000001Ghs4', '<html>Apex script unhandled exception by user/organization: 0054R00000BKhA/00D8N000001Ghs4</html>');
    }

    @IsTest
    private static void test_getEmailBody_html_flow() {
        test_getEmailBody(false, '', '<!DOCTYPE html><html><head><style>');
    }

    private static void test_getEmailBody(Boolean expectedPlainText, String plainText, String htmlBody) {
        Inbound_Email__c testEmail = new Inbound_Email__c(
            Html_Body__c = htmlBody,
            Plain_Text__c = plainText
        );
        String result = ErrorEmailHandler.getEmailBody(testEmail);
        if(expectedPlainText) {
            System.assertEquals(true, !result?.startsWith('<'));
            System.assertEquals(true, !result?.startsWith('<html'));
        }
        else {
            System.assertEquals(true, result.startsWith('<'));
        }
        
    }

    @IsTest
    private static void test_parse_exception_type_from_sandbox_email() {
        String emailBody = 'Sandbox\r\n\r\nApex script unhandled trigger exception by user/organization: 005d00000048BMk/00DDV000000tc9I\r\n\r\nOrganization: CrowdStrike Inc Full Sandbox (crowdstrike--uat.sandbox.my.salesforce.com).\r\nSource organization: 00Dd0000000btJo (null)\r\nUserGem.UserGemsContactOwnerUpdate: System.LimitException: Apex CPU time limit exceeded';
        String emailSubject = 'Sandbox: Developer script exception from CrowdStrike Inc Full Sandbox : UserGem.UserGemsContactOwnerUpdate : UserGem.UserGemsContactOwnerUpdate: System.LimitException: Apex CPU time limit exceeded';
        String fromAddress = 'lalal@gmail.com';
        ApexExceptionParser processor = new ApexExceptionParser();

        processor.init(emailBody, emailSubject, fromAddress);
        processor.process();

        System.assertEquals('LimitException', processor.getErrorType());
    }

    @IsTest
    private static void test_is_new_logic_for_the_same_logs_in_transaction() {
        Integer logsCount = 10;
        Test.startTest();
        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            for(integer i =0; i < logsCount; i++) {
                Log__c log = LogBuilder.getInstance()
                    .category('Some Category')
                    .summary(e.getMessage())
                    .area('Some Area')
                    .type(String.isBlank(e.getTypeName()) ? 'Some Type' : e.getTypeName())
                    .stackTrace(e.getStackTraceString())
                    .details(e.getMessage())
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                    .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), 'Some Area: Some Apex Name')
                    .build();
                Logger.getInstance().add(log);
            }
            Logger.getInstance().flush();
        }
        Test.stopTest();
        List<Log__c> logs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c FROM Log__c WHERE Category__c = 'Some Category'];
        System.assertEquals(logsCount, logs.size());
        Boolean findIsNew = false;
        // only one log should be new
        for(Log__c log : logs) {
            if(log.Is_New__c) {
                System.assertEquals(false, findIsNew, 'Only one log should be new');
                findIsNew = true;
            }
            System.assertEquals(true, log.Created_At__c != null);
            System.assertEquals(true, log.First_Occurred_On__c != null);
        }
        System.assertEquals(true, findIsNew);


    }

    @IsTest
    private static void test_is_new_logic_multiple_logs_same_hash() {
        // Setup test data
        List<Log__c> logs = new List<Log__c>();
        DateTime now = DateTime.now();
        DateTime earlier = now.addHours(-1);
        DateTime earliest = now.addHours(-2);
        
        // Create 3 logs with same hash but different Created_At__c times
        Log__c log1 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log2 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = earlier
        );
        Log__c log3 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = earliest
        );
        
        Logger.getInstance().add(log1);
        Logger.getInstance().add(log2);
        Logger.getInstance().add(log3);        
        
        Test.startTest();
        Logger.getInstance().flush();
        Test.stopTest();
        
        List<Log__c> logWithEarliestDate = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c FROM Log__c WHERE Hash_1__c = 'test_hash' AND Is_New__c = true];
        System.assertEquals(1, logWithEarliestDate.size(), 'Only one log should have the earliest Created_At__c');
        System.assertEquals(earliest, logWithEarliestDate[0].Created_At__c, 'Created_At__c should be set to earliest date');
        System.assertEquals(earliest, logWithEarliestDate[0].First_Occurred_On__c, 'First_Occurred_On__c should be set to earliest date');

        List<Log__c> otherLogs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c FROM Log__c WHERE Hash_1__c = 'test_hash' AND Is_New__c = false];
        system.assertEquals(2, otherLogs.size(), 'There should be 2 other logs');
        for(Log__c log : otherLogs) {
            // All logs should have First_Occurred_On__c set to earliest
            System.assertEquals(earliest, log.First_Occurred_On__c, 'First_Occurred_On__c should be set to earliest date');
            System.assertNotEquals(earliest, log.Created_At__c, 'Created_At__c should not be set to earliest date');
        }
    }

    @IsTest
    private static void test_is_new_logic_different_hashes() {
        // Setup test data
        DateTime now = DateTime.now();
        
        // Create logs with different hashes
        Log__c log1 = new Log__c(
            Hash_1__c = 'hash1',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log2 = new Log__c(
            Hash_1__c = 'hash2',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now.addHours(-1)
        );
        
        Logger.getInstance().add(log1);
        Logger.getInstance().add(log2);
        
        Test.startTest();
        Logger.getInstance().flush();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c FROM Log__c WHERE Hash_1__c IN ('hash1', 'hash2')];
        // Verify each hash group got its own earliest date
        System.assertEquals(now, logs[0].Created_At__c, 'Log1 should have its original date minus 1 second');
        System.assertEquals(now, logs[0].First_Occurred_On__c, 'Log1 should have its original date minus 1 second');
        System.assertEquals(true, logs[0].Is_New__c, 'Log1 should be new');
        System.assertEquals(now.addHours(-1), logs[1].Created_At__c, 'Log2 should have its original date minus 1 second');
        System.assertEquals(now.addHours(-1), logs[1].First_Occurred_On__c, 'Log2 should have its original date minus 1 second');
        System.assertEquals(true, logs[1].Is_New__c, 'Log2 should be new');
    }

    @IsTest
    private static void test_is_new_logic_multiple_logs_with_different_hashes() {
        // Setup test data
        DateTime now = DateTime.now();
        
        // Create logs with different hashes
        Log__c log1 = new Log__c(
            Hash_1__c = 'hash1',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log11 = new Log__c(
            Hash_1__c = 'hash1',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log2 = new Log__c(
            Hash_1__c = 'hash2',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now.addHours(-1)
        );
        Log__c log22 = new Log__c(
            Hash_1__c = 'hash2',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now.addHours(-1)
        );
        
        Logger.getInstance().add(log1);
        Logger.getInstance().add(log11);
        Logger.getInstance().add(log2);
        Logger.getInstance().add(log22);
        
        Test.startTest();
        Logger.getInstance().flush();
        Test.stopTest();

        List<Log__c> newLogs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c, Hash_1__c FROM Log__c WHERE Hash_1__c IN ('hash1', 'hash2') AND Is_New__c = true];
        system.assertEquals(2, newLogs.size(), 'There should be 2 new logs');
        for(Log__c log : newLogs) {
            if(log.Hash_1__c == 'hash1') {
                System.assertEquals(now.addSeconds(-1), log.Created_At__c, 'Log1 should have its original date minus 1 second');
                System.assertEquals(now.addSeconds(-1), log.First_Occurred_On__c, 'Log1 should have its original date minus 1 second');
            }
            else if(log.Hash_1__c == 'hash2') {
                System.assertEquals(now.addHours(-1).addSeconds(-1), log.Created_At__c, 'Log2 should have its original date minus 1 second');
                System.assertEquals(now.addHours(-1).addSeconds(-1), log.First_Occurred_On__c, 'Log2 should have its original date minus 1 second');
            }
        }

        List<Log__c> otherLogs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c, Hash_1__c FROM Log__c WHERE Hash_1__c IN ('hash1', 'hash2') AND Is_New__c = false];
        for(Log__c log : otherLogs) {
            if(log.Hash_1__c == 'hash1') {
                System.assertEquals(now.addSeconds(-1), log.First_Occurred_On__c, 'Log1 should have its original date minus 1 second');
            }
            else if(log.Hash_1__c == 'hash2') {
                System.assertEquals(now.addHours(-1).addSeconds(-1), log.First_Occurred_On__c, 'Log2 should have its original date minus 1 second');
            }
        }
    }

    @IsTest
    private static void test_is_new_logic_with_existing_index() {
        // Setup test data
        DateTime now = DateTime.now();
        DateTime indexDate = now.addDays(-1);
        
        // Create a log
        Log__c log1 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log2 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Bug_Tracker__c = 'https://jira.com/browse/JIRA-333',
            Jira_Integration_Status__c = ConfigUtil.EXISTING_TICKET_LINKED_STATUS,
            Created_At__c = now
        );
        Logger.getInstance().add(log1);
        Logger.getInstance().add(log2);
        
        // Create and insert an index record
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{ConfigUtil.getLogIndexKey(log1.Hash_1__c, log1.Organization_Id__c)});
        String indexKey = ConfigUtil.getLogIndexKey(log1.Hash_1__c, log1.Organization_Id__c);
        ConfigUtil.LogIndex existingIndex = new ConfigUtil.LogIndex(log1.Hash_1__c, log1.Organization_Id__c, indexDate);
        existingIndex.firstOccurredOn = indexDate;
        existingIndex.bugTracker = 'https://jira.com/browse/JIRA-123';
        helper.saveLogIndex(null, existingIndex);

        Test.startTest();
        Logger.getInstance().flush();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Is_New__c, Created_At__c, First_Occurred_On__c, Bug_Tracker__c, Jira_Integration_Status__c FROM Log__c WHERE Hash_1__c = 'test_hash' AND Is_New__c = false LIMIT 2];
        System.assertEquals(2, logs.size(), 'There should be two logs');
        for(Log__c logActual : logs) {
            // Verify the log got the index's firstOccurredOn date
            System.assertEquals(indexDate, logActual.First_Occurred_On__c, 'Log should have index firstOccurredOn date');
            System.assertEquals('https://jira.com/browse/JIRA-123', logActual.Bug_Tracker__c, 'Log should have index bug tracker reference');
            System.assertEquals(ConfigUtil.EXISTING_TICKET_LINKED_STATUS, logActual.Jira_Integration_Status__c, 'Log should have correct Jira status');        
            System.assertEquals(now.second(), logActual.Created_At__c.second(), 'Log should have its original date');
        }
        
        ConfigUtil.LogIndexHelper helperAfter = new ConfigUtil.LogIndexHelper(new Set<String>{ConfigUtil.getLogIndexKey(log1.Hash_1__c, log1.Organization_Id__c)});
        ConfigUtil.LogIndex indexAfter = helperAfter.getLogIndex(log1);
        System.assertEquals(indexDate, indexAfter.firstOccurredOn, 'Index should have the same firstOccurredOn date');
        System.assertEquals('https://jira.com/browse/JIRA-123', indexAfter.bugTracker, 'Index should have the same bugTracker');

    }

    @IsTest
    private static void test_is_new_logic_multiple_logs_same_hash_and_created_at() {
        // Setup test data
        List<Log__c> logs = new List<Log__c>();
        DateTime now = DateTime.now();
        
        // Create 3 logs with same hash and same Created_At__c time
        Log__c log1 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log2 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        Log__c log3 = new Log__c(
            Hash_1__c = 'test_hash',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Created_At__c = now
        );
        
        Logger.getInstance().add(log1);
        Logger.getInstance().add(log2);
        Logger.getInstance().add(log3);
        
        Test.startTest();
        Logger.getInstance().flush();
        Test.stopTest();
        
        List<Log__c> resultLogs = [
            SELECT Id, Created_At__c, First_Occurred_On__c, Is_New__c 
            FROM Log__c 
            WHERE Hash_1__c = 'test_hash' 
            ORDER BY Created_At__c ASC
        ];
        
        System.assertEquals(3, resultLogs.size(), 'Should have 3 logs');
        
        // Verify that all logs have First_Occurred_On__c set to now-1 second
        DateTime expectedDate = now.addSeconds(-1);
        for(Log__c resultLog : resultLogs) {
            System.assertEquals(expectedDate, resultLog.First_Occurred_On__c, 
                'First_Occurred_On__c should be set to original date minus 1 second');
        }
        
        // Verify only one log got the earliest Created_At__c
        Integer countWithEarliestDate = 0;
        Integer countOtherLogs = 0;
        for(Log__c resultLog : resultLogs) {
            if(resultLog.Created_At__c.second() == expectedDate.second()) {
                countWithEarliestDate++;

                System.assertEquals(true, resultLog.Is_New__c, 'Log should be new');
            }
            else {
                System.assertEquals(false, resultLog.Is_New__c, 'Log should not be new');
                countOtherLogs++;
            }
        }
        System.assertEquals(1, countWithEarliestDate, 'Only one log should have the earliest Created_At__c');
        System.assertEquals(2, countOtherLogs, 'Only one log should have the earliest Created_At__c');
    }

    @IsTest
    private static void test_logBuilder_tracePoint_methods() {
        Log__c log;

        Test.startTest();

        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            LogBuilder logBuilder = LogBuilder.getInstance()
                    .category('Some Category')
                    .summary(e.getMessage())
                    .area('Some Area')
                    .type(String.isBlank(e.getTypeName()) ? 'Some Type' : e.getTypeName())
                    .stackTrace(e.getStackTraceString())
                    .details(e.getMessage())
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                    .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), 'Some Area: Some Apex Name');

            log = logBuilder.build();
            
            System.assertEquals(null, log.Hash_1__c, 'Hash_1__c should be null');
            System.assertEquals(null, logBuilder.getTraceId(), 'Hash_1__c should be null');
            System.assertEquals(true, log.Hash_1__c == logBuilder.getTraceId(), 'Should be true');


            log  = logBuilder.tracePoint().build();
            Logger.getInstance().add(log);
            Logger.getInstance().flush();
        }

        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Hash_1__c FROM Log__c];
        System.assertEquals(log.Hash_1__c, logs[0].Hash_1__c, 'Hash_1__c should be set');
    }
}