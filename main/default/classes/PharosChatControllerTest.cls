@IsTest
public class PharosChatControllerTest {
    // Error message constants to match PharosChatController
    private static final String ERROR_OPENAI_NOT_READY = 'OpenAI token is not configured or is invalid. Please set up OpenAI integration first.';
    private static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    private static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    private static final String ERROR_INIT_FAILED = 'Chat initialization has failed.';

    private static final String MOCK_RESPONSE = '{ "empty": false }';
    private static final String MOCK_ERROR_RESPONSE = '{ "message": "Internal server error" }';

    @TestSetup
    static void testSetup() {
        TestDataFactory.createConnectedOrg();
        ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = true;
        ConfigUtil.OPEN_AI_SETTINGS.Token__c = 'Token';
        upsert ConfigUtil.OPEN_AI_SETTINGS;
        ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c = false;
        upsert ConfigUtil.CHANGE_TRACKING_SETTINGS;
    }

    @IsTest
    static void testInitChat_Success() {
        TestDataFactory.enableIssueTracking();

        TestDataFactory.SingleRequestMock openAiTokenValidation = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        String gitEndpoint = String.format(GitHubUtils.GIT_API_GET_REPO_BRANCHES_INFO, new List<String>{'test-owner', 'test-repo', 'test-branch'});
        TestDataFactory.SingleRequestMock gitConnectionValidation = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            ''
        );

        TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
			'{"empty": false}'
        );

        TestDataFactory.SingleRequestMock chatInitMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"status": "success"}'
        );

        Map<String, HttpCalloutMock> httpMocks = new Map<String, HttpCalloutMock>();
        httpMocks.put(ConfigUtil.OPEN_AI_USAGE_ENDPOINT, openAiTokenValidation);
        httpMocks.put(gitEndpoint, gitConnectionValidation);
        httpMocks.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId(), namespaceStatusMock);
        httpMocks.put(PharosChatController.CHAT_INIT_ENDPOINT, chatInitMock);

        HttpCalloutMock multiRequestMock = new TestDataFactory.MultiRequestMock(httpMocks);
        Test.setMock(HttpCalloutMock.class, multiRequestMock);

        Test.startTest();
        PharosChatController.InitChatResponse response = PharosChatController.initChat();
        Test.stopTest();

        System.assertEquals(true, response.success, 'Chat initialization should be successful');
        System.assertEquals(null, response.errorMessages, 'There should be no error messages');
    }

//    @IsTest
//    static void testInitChat_OpenAI_Not_Ready() {
//        // Setup
//        TestDataFactory.enableIssueTracking();
//
//        // Disable OpenAI
//        ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = false;
//        upsert ConfigUtil.OPEN_AI_SETTINGS;
//
//        Test.startTest();
//        PharosChatController.InitChatResponse response = PharosChatController.initChat();
//        Test.stopTest();
//
//        // Verify
//        System.assertEquals(false, response.success, 'Chat initialization should fail');
//        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
//        System.assertEquals(PharosChatController.ERROR_OPENAI_NOT_READY, response.errorMessages[0], 'Error message should indicate OpenAI is not ready');
//    }
//
//    @IsTest
//    static void testInitChat_Git_Not_Integrated() {
//        // Setup
//        TestDataFactory.enableIssueTracking();
//
//        // Mock the namespace status check
//        TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
//            200,
//            'OK',
//            MOCK_RESPONSE
//        );
//
//        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
//        endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId(), namespaceStatusMock);
//
//        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
//        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
//
//        Test.startTest();
//        PharosChatController.InitChatResponse response = PharosChatController.initChat();
//        Test.stopTest();
//
//        // Verify
//        System.assertEquals(false, response.success, 'Chat initialization should fail');
//        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
//        System.assertEquals(PharosChatController.ERROR_GIT_NOT_INTEGRATED, response.errorMessages[0], 'Error message should indicate Git is not integrated');
//    }
//
//    @IsTest
//    static void testInitChat_Code_Not_Indexed() {
//        // Setup
//        TestDataFactory.enableIssueTracking();
//
//        // Mock the namespace status check to return empty=true
//        TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
//            200,
//            'OK',
//            '{ "empty": true }'
//        );
//
//        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
//        endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + UserInfo.getOrganizationId(), namespaceStatusMock);
//
//        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
//        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
//
//        Test.startTest();
//        PharosChatController.InitChatResponse response = PharosChatController.initChat();
//        Test.stopTest();
//
//        // Verify
//        System.assertEquals(false, response.success, 'Chat initialization should fail');
//        System.assertEquals(1, response.errorMessages.size(), 'There should be one error message');
//        System.assertEquals(PharosChatController.ERROR_CODE_NOT_INDEXED, response.errorMessages[0], 'Error message should indicate code is not indexed');
//    }
}