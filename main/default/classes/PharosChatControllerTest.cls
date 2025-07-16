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
            '{"empty": false}'
        );

        TestDataFactory.SingleRequestMock chatInitMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        return new Map<String, HttpCalloutMock>{
            ConfigUtil.OPEN_AI_USAGE_ENDPOINT => openAiValidationMock,
            GIT_ENDPOINT => gitValidationMock,
            PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId() => namespaceStatusMock,
            PharosChatController.CHAT_INIT_ENDPOINT => chatInitMock
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

        System.assertEquals(true, response.success, 'Chat initialization should be successful');
        System.assertEquals(null, response.errorMessages, 'There should be no error messages');
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

        System.assertEquals(false, response.success, 'Chat initialization should fail');
        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
        System.assertEquals(PharosChatController.ERROR_OPENAI_NOT_READY, response.errorMessages[0], 'Error message should indicate OpenAI is not ready');
    }

    @IsTest
    static void testInitChat_Git_Not_Integrated() {
        Map<String, HttpCalloutMock> httpMocks = getBaseHttpMocks();
        httpMocks.put(GIT_ENDPOINT, new TestDataFactory.SingleRequestMock(200, 'OK', '{"name": ""}'));

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(httpMocks));

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        System.assertEquals(false, response.success, 'Chat initialization should fail');
        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
        System.assertEquals(PharosChatController.ERROR_GIT_NOT_INTEGRATED, response.errorMessages[0], 'Error message should indicate Git is not integrated');
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

        System.assertEquals(false, response.success, 'Chat initialization should fail');
        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
        System.assertEquals(PharosChatController.ERROR_CODE_NOT_INDEXED, response.errorMessages[0], 'Error message should indicate code is not indexed');
    }
}