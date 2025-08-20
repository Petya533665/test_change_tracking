@isTest
global class Test_Logger {

    global static void setMock(HttpCalloutMock theMock) {
        Test.setMock(HttpCalloutMock.class, theMock);
    }

    global static void initSettings() {
        createLoggerSetting();
        createConnectedOrg();
    }

    public static void createLoggerSetting() {
        Logger_Settings__c settings = new Logger_Settings__c(
            Email_Service_Address__c = 'someone@test.com',
            Debug__c = true
        );
        Connected_Orgs_Settings__c connectedOrgsSettings = new Connected_Orgs_Settings__c(
            Client_Key__c = 'ccccccc',
            Client_Secret__c = 'dddddd'
        );
        insert connectedOrgsSettings;
        insert settings;
    }

    public static void createConnectedOrg() {
        Connected_Org__c corg = new Connected_Org__c(
            SetupOwnerId = UserInfo.getOrganizationId().left(15),
            Name = UserInfo.getOrganizationId().left(15),
            Title__c = 'Test Connected Org',
            Description__c = 'Test Description',
            Type__c = 'production',
            Access_Token__c = '111111',
            Refresh_Token__c = '222222',
            Token_Refreshed_At__c = Datetime.now(),
            Instance_Url__c = 'https://testurl.test',
            Identity_Url__c = null
        );
        insert corg;
    }

    @TestSetup
    static void testSetup() {
        initSettings();
    }

    static void initHttpMocks() {
        ConnectedOrgService.AuthTokenResponse oAuthResponse = new ConnectedOrgService.AuthTokenResponse();
        oAuthResponse.access_token = 'token';
        oAuthResponse.refresh_token = 'token';

        TestDataFactory.SingleRequestMock getOAuthToken = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(oAuthResponse)
        );

        TestDataFactory.SingleRequestMock monitorDeployments = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://testurl.test/services/oauth2/token', getOAuthToken);
        endpoint2TestResp.put('https://testurl.test/changemgmt/monitorDeployment.apexp', monitorDeployments);

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }

    @IsTest
    static void test1 () {

        initHttpMocks();

        Test.startTest();
        Connected_Org__c corg = Connected_Org__c.getInstance(UserInfo.getOrganizationId().left(15));
        System.assertNotEquals(null, corg);

        Logger loggerInst = Logger.getInstance();
        loggerInst.internalError(new LogService.LogException(), Test_Logger.class.getName(), 'test1');

        Test.stopTest();

        Log__c log1 = [
            SELECT
                Id,
                Hash_1__c,
                Area__c,
                Apex_Name__c,
                Category__c
            FROM Log__c
        ];

        System.assertEquals(Logger.AREA_PHAROS_ERROR, log1.Area__c);
        System.assertEquals(Logger.CATEGORY_PHAROS_ERROR, log1.Category__c);
        System.assertEquals(Test_Logger.class.getName() + ':test1', log1.Apex_Name__c);
    }

    @IsTest
    static void testLogger_async() {

        initHttpMocks();

        Test.startTest();

        Log__c log;
        Logger logger = Logger.getInstance();
        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            log = LogBuilder.getInstance()
                .category('Pharos Error')
                .summary(e.getMessage())
                .area('Pharos')
                .type(String.isBlank(e.getTypeName()) ? 'Pharos' : e.getTypeName())
                .stackTrace(e.getStackTraceString())
                .details(String.valueOf(e) + '\n\n' + e.getStackTraceString())
                .build();
        }

        logger.add(log);
        logger.flush();

        Test.stopTest();

        Log__c log1 = [
            SELECT
                Id,
                Hash_1__c,
                Setup_Audit_Trail__c
            FROM Log__c
            LIMIT 1
        ];
        System.assertNotEquals(null, log1.Hash_1__c);
    }

    @IsTest
    static void test_split_logs_by_platform_events() {

        Integer testCountLogs = 250;
        
        initHttpMocks();

        Test.startTest();

        List<Log__c> logs = new List<Log__c>();
        Logger logger = Logger.getInstance();
        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            Log__c log = LogBuilder.getInstance()
                .category('Pharos Error')
                .summary(e.getMessage())
                .area('Pharos')
                .type(String.isBlank(e.getTypeName()) ? 'Pharos' : e.getTypeName())
                .stackTrace(e.getStackTraceString())
                .details(String.valueOf(e) + '\n\n' + e.getStackTraceString())
                .build();
            
            for(Integer i = 0; i < testCountLogs; i++) {
                logger.add(log);
            }
        }

        logger.flush();

        Test.stopTest();

        System.assertEquals(testCountLogs, [SELECT COUNT() FROM Log__c]);
    }

    @IsTest
    static void testLogBuilderAttribute_AllValidValues() {
        List<Id> fakeAccountIds = TestDataFactory.getFakeIds(Account.SObjectType, 2);
        String fakeAccountIdsJSON = JSON.serialize(fakeAccountIds);
        
        initHttpMocks();
        
        Test.startTest();

        Logger logger = Logger.getInstance();
        
        // Test all valid attribute calls
        LogBuilder builder = LogBuilder.getInstance()
            .category('Test Category')
            .summary('Test Summary')
            .area('Test Area')
            .type('Test Type')
            .stackTrace('Test Stack Trace')
            .details('Test Details')
            .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), fakeAccountIds.get(0))
            .attribute(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), UserInfo.getUserId())
            .attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.getName(), fakeAccountIdsJSON);
        
        logger.add(builder.build());
        logger.flush();
        
        Test.stopTest();
        
        List<Log__c> logs = [
            SELECT User_Id__c, Related_Id__c, Related_Objects__c
            FROM Log__c
        ];
        
        System.assertEquals(1, logs.size());
        Log__c log = logs.get(0);

        System.assertEquals(fakeAccountIds.get(0), log.Related_Id__c);
        System.assertEquals(UserInfo.getUserId(), log.User_Id__c);
        System.assertEquals(fakeAccountIdsJSON, log.Related_Objects__c);
    }

    @IsTest
    static void testLogBuilderAttribute_InvalidValues() {
        
        initHttpMocks();
        
        Test.startTest();

        Logger logger = Logger.getInstance();
        
        // Test all invalid attribute calls
        LogBuilder builder = LogBuilder.getInstance()
            .category('Test Category')
            .summary('Test Summary')
            .area('Test Area')
            .type('Test Type')
            .stackTrace('Test Stack Trace')
            .details('Test Details')
            .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), 'Test')
            .attribute(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), 'Test')
            .attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.getName(), 'Test');
        
        logger.add(builder.build());
        logger.flush();
        
        Test.stopTest();
        
        List<Log__c> createdLogs = [
            SELECT User_Id__c, Related_Id__c, Related_Objects__c
            FROM Log__c
            WHERE Category__c = 'Test Category'
        ];
        
        System.assertEquals(1, createdLogs.size());
        Log__c log = createdLogs.get(0);

        System.assert(String.isBlank(log.Related_Id__c));
        System.assertEquals(UserInfo.getUserId(), log.User_Id__c);
        System.assert(String.isBlank(log.Related_Objects__c));

        List<Log__c> errorLogs = [
            SELECT User_Id__c, Related_Id__c, Related_Objects__c
            FROM Log__c
            WHERE Category__c != 'Test Category'
        ];

        System.assertEquals(3, errorLogs.size());
    }

    @IsTest
    static void testLogBuilderAttribute_ValidValuesWrongObjectType() {
        List<Id> fakeAccountIds = TestDataFactory.getFakeIds(Account.SObjectType, 2);
        String fakeAccountIdsJSON = JSON.serialize(fakeAccountIds);
        
        initHttpMocks();
        
        Test.startTest();

        Logger logger = Logger.getInstance();
        
        // Test all valid attribute calls
        LogBuilder builder = LogBuilder.getInstance()
            .category('Test Category')
            .summary('Test Summary')
            .area('Test Area')
            .type('Test Type')
            .stackTrace('Test Stack Trace')
            .details('Test Details')
            .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), fakeAccountIds.get(0))
            .attribute(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), fakeAccountIds.get(0))
            .attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.getName(), fakeAccountIdsJSON);
        
        logger.add(builder.build());
        logger.flush();
        
        Test.stopTest();
        
        List<Log__c> createdLogs = [
            SELECT User_Id__c, Related_Id__c, Related_Objects__c
            FROM Log__c
            WHERE Category__c = 'Test Category'
        ];
        
        System.assertEquals(1, createdLogs.size());
        Log__c log = createdLogs.get(0);

        System.assertEquals(fakeAccountIds.get(0), log.Related_Id__c);
        System.assertEquals(UserInfo.getUserId(), log.User_Id__c);
        System.assertEquals(fakeAccountIdsJSON, log.Related_Objects__c);

        List<Log__c> errorLogs = [
            SELECT User_Id__c, Related_Id__c, Related_Objects__c
            FROM Log__c
            WHERE Category__c != 'Test Category'
        ];

        System.assertEquals(1, errorLogs.size());
    }
}