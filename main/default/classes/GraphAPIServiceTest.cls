@IsTest
private class GraphAPIServiceTest {

	@TestSetup
	private static void testSetup() {
		ConfigUtil.GRAPH_API_SETTINGS.Enabled__c = true;
		ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c = TEST_GRAPH_API_TENANT_ID;
		upsert ConfigUtil.GRAPH_API_SETTINGS;
	}

	@IsTest
	static void test_getTeams() {
		List<GraphAPIService.Team> testTeams;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ALL_TEAMS_ENDPOINT, getAllTeamsMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		testTeams = GraphAPIService.getTeams('').value;
		Test.stopTest();

		System.assertNotEquals(null, testTeams);
		System.assertEquals(1, testTeams.size());
	}

	@IsTest
	static void test_getTeamChannels() {
		List<GraphAPIService.Channel> testChannels;
		String testEndpoint = String.format(GraphAPIService.GRAPH_API_GET_TEAM_CHANNELS, new List<String>{TEST_GRAPH_API_TEAM_ID});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(testEndpoint, getChannelsMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		testChannels = GraphAPIService.getChannels(TEST_GRAPH_API_TEAM_ID);
		Test.stopTest();

		System.assertNotEquals(null, testChannels);
		System.assertEquals(1, testChannels.size());
	}

	@IsTest
	static void test_getOrganization() {
		GraphAPIService.Organization testOrganization;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(true));
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		testOrganization = GraphAPIService.getOrganization(TEST_GRAPH_API_TOKEN);
		Test.stopTest();

		System.assertNotEquals(null, testOrganization);
		System.assertEquals(TEST_GRAPH_API_TENANT_ID, testOrganization.id);
	}

	@IsTest
	static void test_sendChannelMessage() {
		GraphAPIService.ChatMessage testChatMessage;
		String endpoint = String.format(GraphAPIService.GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{TEST_GRAPH_API_TEAM_ID, TEST_GRAPH_API_TEAM_CHANNEL_ID});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, getSendChannelMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		testChatMessage = new GraphAPIService.ChatMessage(TEST_GRAPH_API_CHAT_MESSAGE_SUBJECT, TEST_GRAPH_API_CHAT_MESSAGE_BODY);
		testChatMessage = GraphAPIService.sendChannelMessage(TEST_GRAPH_API_TEAM_ID, TEST_GRAPH_API_TEAM_CHANNEL_ID, testChatMessage);
		Test.stopTest();

		System.assertNotEquals(null, testChatMessage);
	}

	@IsTest
	static void test_refresh_token() {
		GraphAPIService.putApiRefreshTokenToSettings('oldRefreshToken', true, null);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(false));
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, getRefreshTokenMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		PermissionsUtil.TeamsIntegrationEnabled = true;
		GraphAPIService.validateAndRefreshGraphApiOauthToken(Logger.getInstance(), false);
		Test.stopTest();

		System.assertNotEquals(null, GraphAPIService.getApiRefreshTokenFromSettings());
	}

	@IsTest
	static void test_async_refresh_token() {
		GraphAPIService.putApiRefreshTokenToSettings('oldRefreshToken', true, null);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(false));
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, getRefreshTokenMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		PermissionsUtil.TeamsIntegrationEnabled = true;
		GraphAPIService.validateAndRefreshGraphApiOauthToken(Logger.getInstance(), false);
		Test.stopTest();

		System.assertNotEquals(null, GraphAPIService.getApiRefreshTokenFromSettings());
	}

	@IsTest
	static void test_getGraphAPIToken() {
		String testToken;

		String endpoint = String.format(GraphAPIService.GET_GRAPH_API_TOKEN_ENDPOINT, new List<String>{TEST_GRAPH_API_TENANT_ID});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, getTokenMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		testToken = GraphAPIService.getGraphAPIToken();
		Test.stopTest();

		System.assertNotEquals(null, testToken);
	}

	@IsTest
	static void test_splitApiToken() {
		final String testToken1;

		Test.startTest();
		testToken1 = generateRandomString(255*3 + 230);
		GraphAPIService.putApiTokenToSettings(testToken1, true, null);
		Test.stopTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		String result = GraphAPIService.getApiTokenFromSettings();
		System.assertEquals(testToken1, result);
	}

	@IsTest
	static void test_splitApiRefreshToken() {
		final String testToken1;

		Test.startTest();
		testToken1 = generateRandomString(255*5 + 0);
		GraphAPIService.putApiRefreshTokenToSettings(testToken1, true, null);
		Test.stopTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		String result = GraphAPIService.getApiRefreshTokenFromSettings();
		System.assertEquals(testToken1, result);
	}

	private static final String TEST_GRAPH_API_TEAM_ID = 'someTestGraphTeamId';
	private static final String TEST_GRAPH_API_TEAM_DISPLAY_NAME = 'someTestGraphTeamLabel';
	private static final String TEST_GRAPH_API_TEAM_CHANNEL_ID = 'someTestGraphChannelTeamId';
	private static final String TEST_GRAPH_API_TEAM_CHANNEL_DISPLAY_NAME = 'someTestGraphTeamChannelLabel';
	private static final String TEST_GRAPH_API_TENANT_ID = 'someTenantId';
	private static final String TEST_GRAPH_API_TOKEN = 'someToken';
	private static final String TEST_GRAPH_API_TOKEN_ID = 'someTokenId';
	private static final String TEST_GRAPH_API_REFRESH_TOKEN_ID = 'someRefreshTokenId';
	private static final String TEST_GRAPH_API_CHAT_MESSAGE_SUBJECT = 'subject';
	private static final String TEST_GRAPH_API_CHAT_MESSAGE_BODY = 'body';

	public static String generateRandomString(Integer len) {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr;
	}

	private static TestDataFactory.SingleRequestMock getTokenMock() {
		ConnectedOrgService.AuthTokenResponse wrapper = new ConnectedOrgService.AuthTokenResponse();
		wrapper.access_token = TEST_GRAPH_API_TOKEN_ID;
		wrapper.refresh_token = TEST_GRAPH_API_REFRESH_TOKEN_ID;
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getRefreshTokenMock() {
		ConnectedOrgService.AuthTokenResponse wrapper = new ConnectedOrgService.AuthTokenResponse();
		wrapper.access_token = TEST_GRAPH_API_TOKEN_ID;
		wrapper.refresh_token = generateRandomString(6*255);
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getSendChannelMock() {
		GraphAPIService.ChatMessage wrapper = new GraphAPIService.ChatMessage(TEST_GRAPH_API_CHAT_MESSAGE_SUBJECT, TEST_GRAPH_API_CHAT_MESSAGE_BODY);
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			201,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getOrganizationMock(Boolean isValidRequest) {
		GraphAPIService.OrganizationWrapper wrapper = new GraphAPIService.OrganizationWrapper();
		wrapper.value = new List<GraphAPIService.Organization>{
			new GraphAPIService.Organization(TEST_GRAPH_API_TENANT_ID)
		};
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			isValidRequest ? 200 : 400,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getChannelsMock() {
		GraphAPIService.TeamChannelWrapper wrapper = new GraphAPIService.TeamChannelWrapper();
		wrapper.value = new List<GraphAPIService.Channel>{
			new GraphAPIService.Channel(TEST_GRAPH_API_TEAM_CHANNEL_ID, TEST_GRAPH_API_TEAM_CHANNEL_DISPLAY_NAME)
		};
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getAllTeamsMock() {
		GraphAPIService.TeamRequestWrapper wrapper = new GraphAPIService.TeamRequestWrapper();
		wrapper.value = new List<GraphAPIService.Team>{
			new GraphAPIService.Team(TEST_GRAPH_API_TEAM_ID, TEST_GRAPH_API_TEAM_DISPLAY_NAME)
		};
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
		200,
		'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	@IsTest
	private static void test_generate_git_api_oauth_flow_token() {
		Map<String, Object> input = new Map<String, Object>{
			'code' => 'someOAuthFlowCode',
			'return_url' => 'https://someCallbackUrl.com'
		};

		Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
		mocks.putAll(getGitHubRemoteSiteSettingsMock());
		mocks.putAll(getGitHubTokenMock());
		mocks.putAll(getGitHubSettingsMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		LoggerSettingsController.generateTokenForGitHub(JSON.serialize(input));
		Test.stopTest();

		System.assertNotEquals(null, ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c);
		System.assertNotEquals(null, ConfigUtil.GIT_API_SETTINGS.Username__c);
		System.assertEquals(true, ConfigUtil.GIT_API_SETTINGS.Enabled__c);
	}

	private static Map<String, HttpCalloutMock> getGitHubSettingsMock() {
		Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

		GitHubUtils.GitUserInfo userInfo = new GitHubUtils.GitUserInfo();
		userInfo.company = 'somecompanyid';
		userInfo.login = 'someloginid';
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(userInfo)
		);
		result.put(GitHubUtils.GIT_API_USER_INFO, singleRequestMock);
		return result;
	}


	private static Map<String, HttpCalloutMock> getGitHubTokenMock() {
		Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

		ConnectedOrgService.AuthTokenResponse wrapper = new ConnectedOrgService.AuthTokenResponse();
		wrapper.access_token = 'sometoken';
		wrapper.refresh_token = 'somerefreshtoken';
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
		result.put(GitHubUtils.GIT_API_TOKEN_ENDPOINT, singleRequestMock);
		return result;
	}

	private static Map<String, HttpCalloutMock> getGitHubRemoteSiteSettingsMock() {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        AdminService.RemoteSiteSettingsWrapper wrapper1 = new AdminService.RemoteSiteSettingsWrapper();
        wrapper1.Id = 'siteid1';
        wrapper1.IsActive = true;
        wrapper1.SiteName = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_API_NAME;
        wrapper1.EndpointUrl = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_API_URL;

		AdminService.RemoteSiteSettingsWrapper wrapper2 = new AdminService.RemoteSiteSettingsWrapper();
        wrapper2.Id = 'siteid2';
        wrapper2.IsActive = true;
        wrapper2.SiteName = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_NAME;
        wrapper2.EndpointUrl = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_URL;

		AdminService.RemoteSiteSettingsWrapper wrapper3 = new AdminService.RemoteSiteSettingsWrapper();
        wrapper3.Id = 'siteid3';
        wrapper3.IsActive = true;
        wrapper3.SiteName = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_SFDX_API_NAME;
        wrapper3.EndpointUrl = ConfigUtil.REMOTE_SITE_SETTINGS_GIT_SFDX_API_URL;

        data.put(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS, new List<AdminService.RemoteSiteSettingsWrapper>{
			wrapper1,
			wrapper2,
			wrapper3
		});
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(data)
        );
        result.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY, singleRequestMock);
        return result;
    }
	
}