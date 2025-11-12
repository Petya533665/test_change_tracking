@IsTest
public class PharosChatControllerTest {
    private static final String TEST_GIT_OWNER = 'test-owner';
    private static final String TEST_GIT_REPO = 'test-repo';
    private static final String TEST_GIT_BRANCH = 'test-branch';
    private static final String GIT_ENDPOINT = String.format(GitHubUtils.GIT_API_GET_REPO_BRANCHES_INFO, 
        new List<String>{TEST_GIT_OWNER, TEST_GIT_REPO, TEST_GIT_BRANCH});

    private static Map<String, HttpCalloutMock> getBaseHttpMocks() {
        TestDataFactory.SingleRequestMock openAiValidationMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        TestDataFactory.SingleRequestMock gitValidationMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"name": "' + TEST_GIT_BRANCH + '"}'
        );

        TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"empty": false, "logsEmpty": false, "indexingInProgress": false}'
        );

        TestDataFactory.SingleRequestMock chatInitMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        TestDataFactory.SingleRequestMock cspTrustedSitesMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records": [{"Id": "test-id", "IsActive": true, "DeveloperName": "Pharos_Chat_Websocket", "EndpointUrl": "' + PharosChatController.CHAT_WEBSOCKET_URL + '"}]}'
        );

        TestDataFactory.SingleRequestMock remoteSiteSettingsMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records": [{"Id": "test-id", "IsActive": true, "SiteName": "' + Constants.REMOTE_SITE_SETTINGS.AI_NAME + '"  , "EndpointUrl": "' + Constants.REMOTE_SITE_SETTINGS.AI_URL + '"}]}'
        );

        return new Map<String, HttpCalloutMock>{
            ConfigUtil.OPEN_AI_USAGE_ENDPOINT => openAiValidationMock,
            GIT_ENDPOINT => gitValidationMock,
            PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId() => namespaceStatusMock,
            PharosChatController.CHAT_INIT_ENDPOINT => chatInitMock,
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_CSP_TRUSTED_SITES_QUERY => cspTrustedSitesMock,
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY => remoteSiteSettingsMock
        };
    }

    @TestSetup
    static void testSetup() {
        TestDataFactory.createConnectedOrg();
        ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = true;
        ConfigUtil.OPEN_AI_SETTINGS.Token__c = 'Token';
        upsert ConfigUtil.OPEN_AI_SETTINGS;

        ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
        ConfigUtil.GIT_API_SETTINGS.Username__c = TEST_GIT_OWNER;
        ConfigUtil.GIT_API_SETTINGS.Reponame__c = TEST_GIT_REPO;
        ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = TEST_GIT_BRANCH;
        upsert ConfigUtil.GIT_API_SETTINGS;
        ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c = false;
        upsert ConfigUtil.CHANGE_TRACKING_SETTINGS;
    }

    @IsTest
    static void testInitChat_Success() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.areEqual(true, response.success, 'Chat initialization should be successful');
        Assert.areEqual(null, response.errorMessages, 'There should be no error messages');
    }

    @IsTest
    static void testInitChat_OpenAI_Not_Ready() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        httpMocks.put(ConfigUtil.OPEN_AI_USAGE_ENDPOINT, new TestDataFactory.SingleRequestMock(
            401,
            'Unauthorized',
            'Incorrect API key'
        ));

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.areEqual(false, response.success, 'Chat initialization should fail');
        Assert.areEqual(1, response.errorMessages.size(), 'There should be one error message');
        Assert.areEqual(PharosChatController.ERROR_OPENAI_NOT_READY, response.errorMessages[0], 'Error message should indicate OpenAI is not ready');
    }

    @IsTest
    static void testInitChat_Git_Not_Integrated() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        httpMocks.put(GIT_ENDPOINT, new TestDataFactory.SingleRequestMock(200, 'OK', '{"name": ""}'));

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.areEqual(false, response.success, 'Chat initialization should fail');
        Assert.areEqual(1, response.errorMessages.size(), 'There should be one error message');
        Assert.areEqual(PharosChatController.ERROR_GIT_NOT_INTEGRATED, response.errorMessages[0], 'Error message should indicate Git is not integrated');
    }

    @IsTest
    static void testInitChat_Code_Not_Indexed() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        httpMocks.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId(), 
            new TestDataFactory.SingleRequestMock(200, 'OK', '{"empty": true}'));

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.areEqual(false, response.success, 'Chat initialization should fail');
        Assert.areEqual(1, response.errorMessages.size(), 'There should be one error message');
        Assert.areEqual(PharosChatController.ERROR_CODE_NOT_INDEXED, response.errorMessages[0], 'Error message should indicate code is not indexed');
    }

    @IsTest
    static void testInitChat_CSP_Trusted_Site_Not_Ready() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        TestDataFactory.SingleRequestMock cspTrustedSitesMock = new TestDataFactory.SingleRequestMock(200, 'OK', '{"records": []}');
        httpMocks.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_CSP_TRUSTED_SITES_QUERY, cspTrustedSitesMock);

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.areEqual(false, response.success, 'Chat initialization should fail');
        Assert.areEqual(1, response.errorMessages.size(), 'There should be one error message');
        Assert.areEqual(PharosChatController.ERROR_TRUSTED_SITE_NOT_READY, response.errorMessages[0], 'Error message should indicate CSP Trusted Site is not ready');
    }

    @IsTest
    static void testInitChat_WithGitToken() {
        ConfigUtil.GIT_API_SETTINGS.Token__c = 'test-git-token';
        upsert ConfigUtil.GIT_API_SETTINGS;
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.isTrue(response.success, 'Chat initialization should be successful');
        Assert.areEqual(null, response.errorMessages, 'There should be no error messages');
    }

    @IsTest
    static void testInitChat_Exception() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        // Mock HTTP callout to return 404 error for chat init endpoint
        httpMocks.put(PharosChatController.CHAT_INIT_ENDPOINT, new TestDataFactory.SingleRequestMock(
            404,
            'Not Found',
            ''
        ));

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        Assert.isFalse(response.success, 'Chat initialization should fail');
        Assert.areEqual(1, response.errorMessages.size(), 'There should be one error message');
        Assert.areEqual(PharosChatController.ERROR_INIT_FAILED, response.errorMessages[0], 'Error message should indicate initialization failed');
    }

    @IsTest
    static void testGetNamespaceStatus_Exception() {
        // Mock HTTP callout to return 404 error for namespace status endpoint
        TestDataFactory.SingleRequestMock errorMock = new TestDataFactory.SingleRequestMock(
            404,
            'Not Found',
            ''
        );
        Test.setMock(HttpCalloutMock.class, errorMock);

        Test.startTest();
        PharosChatController.NamespaceStatusResponse response = PharosChatController.getNamespaceStatus(UserInfo.getOrganizationId());
        Test.stopTest();

        Assert.areEqual(true, response.empty, 'empty should be true on error');
        Assert.areEqual(true, response.logsEmpty, 'logsEmpty should be true on error');
        Assert.areEqual(false, response.indexingInProgress, 'indexingInProgress should be false on error');
    }

    @IsTest
    static void test_getSendMessageData() {
        Id testRecordId = TestDataFactory.getFakeIds(Log__c.SObjectType, 1).get(0);
        
        Test.startTest();
        Map<String, String> result = PharosChatController.getSendMessageData(testRecordId);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(7, result.size(), 'Result should contain 7 keys');
        
        Assert.isTrue(result.containsKey('sf_session'), 'Result should contain sf_session key');
        Assert.isTrue(String.isNotBlank(result.get('sf_session')), 'sf_session should not be blank');
        
        Assert.isTrue(result.containsKey('sf_instance'), 'Result should contain sf_instance key');
        Assert.areEqual(System.Url.getOrgDomainUrl().toExternalForm(), result.get('sf_instance'), 'sf_instance should match org domain URL');
        
        Assert.isTrue(result.containsKey('sf_namespace'), 'Result should contain sf_namespace key');
        Assert.areEqual(ConfigUtil.nameSpacePrefix, result.get('sf_namespace'), 'sf_namespace should match namespace prefix');
        
        Assert.isTrue(result.containsKey('sf_timezone_offset'), 'Result should contain sf_timezone_offset key');
        Assert.isTrue(String.isNotBlank(result.get('sf_timezone_offset')), 'sf_timezone_offset should not be blank');
        
        Assert.isTrue(result.containsKey('git_user'), 'Result should contain git_user key');
        Assert.areEqual(TEST_GIT_OWNER, result.get('git_user'), 'git_user should match configured username');
        
        Assert.isTrue(result.containsKey('git_repo'), 'Result should contain git_repo key');
        Assert.areEqual(TEST_GIT_REPO, result.get('git_repo'), 'git_repo should match configured repo name');
        
        Assert.isTrue(result.containsKey('record_id'), 'Result should contain record_id key');
        Assert.areEqual(testRecordId, result.get('record_id'), 'record_id should match provided recordId');
    }

    @IsTest
    static void test_getCodeEntityLink_withInvalidCharacters() {
        Test.startTest();
        String result1 = PharosChatController.getCodeEntityLink('SomeClass/Method');
        String result2 = PharosChatController.getCodeEntityLink('SomeClass(param)');
        Test.stopTest();

        Assert.areEqual(null, result1, 'Should return null for entity with slash');
        Assert.areEqual(null, result2, 'Should return null for entity with parentheses');
    }

    @IsTest
    static void test_getCodeEntityLink_withField() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('Account.Name');
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for field');
        Assert.isTrue(result.contains('/lightning/setup/ObjectManager/'), 'Should contain ObjectManager path');
        Assert.isTrue(result.contains('/FieldsAndRelationships/'), 'Should contain FieldsAndRelationships path');
    }

    @IsTest
    static void test_getCodeEntityLink_withField_notFound() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('NonExistentObject__c.Field__c');
        Test.stopTest();

        Assert.areEqual(null, result, 'Should return null for non-existent field');
    }

    @IsTest
    static void test_getCodeEntityLink_withObject() {
        // Mock HttpCalloutMock for LWC tooling query (Account doesn't contain __, so it goes to 'other' case)
        TestDataFactory.SingleRequestMock lwcMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records":[]}'
        );
        Test.setMock(HttpCalloutMock.class, lwcMock);

        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('Account');
        Test.stopTest();

        // Account without __ will be treated as Apex class name (not found) or LWC (not found), returns null
        Assert.areEqual(null, result, 'Should return null for standard object without __');
    }

    @IsTest
    static void test_getCodeEntityLink_withCustomObject() {
        // Log__c contains __, so it goes to 'object' case and queries EntityDefinition
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('Log__c');
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for custom object');
        Assert.isTrue(result.contains('/lightning/setup/ObjectManager/'), 'Should contain ObjectManager path');
    }

    @IsTest
    static void test_getCodeEntityLink_withObject_notFound() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('NonExistentObject__c');
        Test.stopTest();

        Assert.areEqual(null, result, 'Should return null for non-existent object');
    }

    @IsTest
    static void test_getCodeEntityLink_withLog() {
        Log__c log = new Log__c(
            Category__c = 'Test',
            Type__c = 'Test',
            Area__c = 'Apex'
        );
        insert log;
        
        // Get the auto-generated Name
        log = [SELECT Id, Name FROM Log__c WHERE Id = :log.Id];

        Test.startTest();
        String result = PharosChatController.getCodeEntityLink(log.Name);
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for log');
        Assert.isTrue(result.contains('/lightning/r/'), 'Should contain lightning record path');
        Assert.isTrue(result.contains('Log__c'), 'Should contain Log__c in path');
        Assert.isTrue(result.contains(log.Id), 'Should contain log Id');
    }

    @IsTest
    static void test_getCodeEntityLink_withLog_notFound() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('LOG-99999');
        Test.stopTest();

        Assert.areEqual(null, result, 'Should return null for non-existent log');
    }

    @IsTest
    static void test_getCodeEntityLink_withIssue() {
        Issue__c issue = new Issue__c(
            Status__c = 'New',
            Key__c = 'test_hash'
        );
        insert issue;
        
        // Get the auto-generated Name
        issue = [SELECT Id, Name FROM Issue__c WHERE Id = :issue.Id];

        Test.startTest();
        String result = PharosChatController.getCodeEntityLink(issue.Name);
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for issue');
        Assert.isTrue(result.contains('/lightning/r/'), 'Should contain lightning record path');
        Assert.isTrue(result.contains('Issue__c'), 'Should contain Issue__c in path');
        Assert.isTrue(result.contains(issue.Id), 'Should contain issue Id');
    }

    @IsTest
    static void test_getCodeEntityLink_withIssue_notFound() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('ISS-99999');
        Test.stopTest();

        Assert.areEqual(null, result, 'Should return null for non-existent issue');
    }

    @IsTest
    static void test_getCodeEntityLink_withApexClass() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('PharosChatController');
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for Apex class');
        Assert.isTrue(result.startsWith(System.Url.getOrgDomainUrl().toExternalForm()), 'Should start with org domain');
    }

    @IsTest
    static void test_getCodeEntityLink_withApexClass_clsExtension() {
        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('PharosChatController.cls');
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for Apex class with .cls extension');
        Assert.isTrue(result.startsWith(System.Url.getOrgDomainUrl().toExternalForm()), 'Should start with org domain');
    }

    @IsTest
    static void test_getCodeEntityLink_withLWC() {
        // Mock HttpCalloutMock for LWC tooling query
        TestDataFactory.SingleRequestMock lwcMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records":[{"Id":"0Rb000000000001"}]}'
        );
        Test.setMock(HttpCalloutMock.class, lwcMock);

        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('nonExistentClassName');
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'Should return link for LWC');
        Assert.isTrue(result.contains('/lightning/setup/LightningComponentBundles/'), 'Should contain LightningComponentBundles path');
    }

    @IsTest
    static void test_getCodeEntityLink_withLWC_notFound() {
        // Mock HttpCalloutMock for empty LWC tooling query result
        TestDataFactory.SingleRequestMock lwcMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records":[]}'
        );
        Test.setMock(HttpCalloutMock.class, lwcMock);

        Test.startTest();
        String result = PharosChatController.getCodeEntityLink('nonExistentComponent');
        Test.stopTest();

        Assert.areEqual(null, result, 'Should return null for non-existent LWC');
    }

    @IsTest
    static void test_getCodeEntityLink_withNamespacePrefix() {
        String namespacePrefix = ConfigUtil.nameSpacePrefix;
        if (String.isNotBlank(namespacePrefix)) {
            Test.startTest();
            String result = PharosChatController.getCodeEntityLink(namespacePrefix + 'PharosChatController');
            Test.stopTest();

            Assert.isTrue(String.isNotBlank(result), 'Should return link for class with namespace prefix');
        }
    }

    @IsTest
    static void test_getCodeEntityLink_withNamespacePrefixDotNotation() {
        String namespacePrefix = ConfigUtil.nameSpacePrefix;
        if (String.isNotBlank(namespacePrefix)) {
            // Replace __ with . in namespace prefix (e.g., testpharos2530__ -> testpharos2530.)
            String dotNotationPrefix = namespacePrefix.replace('__', '.');
            
            Test.startTest();
            String result = PharosChatController.getCodeEntityLink(dotNotationPrefix + 'PharosChatController');
            Test.stopTest();

            Assert.isTrue(String.isNotBlank(result), 'Should return link for class with dot notation namespace prefix');
        }
    }
    
    @IsTest
    static void test_isMetadataChatEnabled_whenEnabled() {
        enableMetadataChat();
        
        Test.startTest();
        Boolean result = PharosChatController.isMetadataChatEnabled();
        Test.stopTest();
        
        Assert.isTrue(result, 'Metadata chat should be enabled');
    }
    
    @IsTest
    static void test_isMetadataChatEnabled_whenDisabled() {
        disableMetadataChat();
        
        Test.startTest();
        Boolean result = PharosChatController.isMetadataChatEnabled();
        Test.stopTest();
        
        Assert.isFalse(result, 'Metadata chat should be disabled');
    }

    private static void enableMetadataChat() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>0, 1=>0, 2=>0,
            3=>0, 4=>0, 5=>0,
            6=>0, 7=>0, 8=>0,
            9=>0, 10=>0, 11=>0,
            12=>0, 13=>0, 14=>0,
            15=>0, 16=>0, 17=>0,
            18=>0, 19=>0, 20=>0,
            21=>0, 22=>0, 23=>0,
            24=>0, 25=>0, 26=>0,
            27=>0, 28=>1
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }

    private static void disableMetadataChat() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>0, 1=>0, 2=>0,
            3=>0, 4=>0, 5=>0,
            6=>0, 7=>0, 8=>0,
            9=>0, 10=>0, 11=>0,
            12=>0, 13=>0, 14=>0,
            15=>0, 16=>0, 17=>0,
            18=>0, 19=>0, 20=>0,
            21=>0, 22=>0, 23=>0,
            24=>0, 25=>0, 26=>0,
            27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }
}