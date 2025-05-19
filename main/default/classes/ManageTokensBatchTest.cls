@IsTest
private class ManageTokensBatchTest {

	private static final String TEST_JIRA_API_URL = 'https://somejiraapiurl.com';
	private static final String TEST_JIRA_BASE_URL = 'https://somejiraapiurl.com/jirasiteid';
	private static final String TEST_JIRA_API_ACCESS_TOKEN_BEFORE = 'sometoken1';
	private static final String TEST_JIRA_API_REFRESH_TOKEN_BEFORE = 'somerefreshtoken1';
	private static final String TEST_JIRA_API_ACCESS_TOKEN_AFTER = 'sometoken2';
	private static final String TEST_JIRA_API_REFRESH_TOKEN_AFTER = 'somerefreshtoken2';
	private static final String TEST_JIRA_API_USERNAME = JiraService.JIRA_CLOUD_OAUTH_USERNAME;

	@IsTest
	static void testRefreshJiraToken() {
		ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c = TEST_JIRA_API_URL;
		ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = TEST_JIRA_BASE_URL;
		ConfigUtil.JIRA_SETTINGS.Jira_Username__c = TEST_JIRA_API_USERNAME;
		upsert ConfigUtil.JIRA_SETTINGS;
		JiraService.putApiTokenToSettings(TEST_JIRA_API_ACCESS_TOKEN_BEFORE, true, null);
		JiraService.putApiRefreshTokenToSettings(TEST_JIRA_API_REFRESH_TOKEN_BEFORE, true, null);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.JIRA_CLOUD_OAUTH_ENDPOINT, createJiraRefreshRequestMock());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS_UPSERT = null;
		GraphAPIService.GRAPH_API_LIST_RECORDS_DELETE = null;
		ManageTokensBatch.getInstance().startBatch();
		Test.stopTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		System.assertEquals(TEST_JIRA_API_ACCESS_TOKEN_AFTER, JiraService.getApiTokenFromSettings());
		System.assertEquals(TEST_JIRA_API_REFRESH_TOKEN_AFTER, JiraService.getApiRefreshTokenFromSettings());
	}

	private static TestDataFactory.SingleRequestMock createJiraRefreshRequestMock() {
		ConnectedOrgService.AuthTokenResponse response = new ConnectedOrgService.AuthTokenResponse();
		response.refresh_token = TEST_JIRA_API_REFRESH_TOKEN_AFTER;
		response.access_token = TEST_JIRA_API_ACCESS_TOKEN_AFTER;
		TestDataFactory.SingleRequestMock jiraRefreshRequestMock = new TestDataFactory.SingleRequestMock(
				200,
		'OK',
			JSON.serialize(response)
		);
		return jiraRefreshRequestMock;
	}

	private static final String TEST_GRAPH_API_TENANT_ID = 'someTenantId';
	private static final String TEST_GRAPH_API_TOKEN_BEFORE = 'someToken1';
	private static final String TEST_GRAPH_API_REFRESH_TOKEN_BEFORE = 'someRefreshToken1';
	private static final String TEST_GRAPH_API_TOKEN_AFTER = 'someToken2';
	private static final String TEST_GRAPH_API_REFRESH_TOKEN_AFTER = 'someRefreshToken2';

	@IsTest
	static void testRefreshTeamsToken() {
		enableTeamsIntegration();
		ConfigUtil.GRAPH_API_SETTINGS.Enabled__c = true;
		ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c = TEST_GRAPH_API_TENANT_ID;
		upsert ConfigUtil.GRAPH_API_SETTINGS;
		GraphAPIService.putApiTokenToSettings(TEST_GRAPH_API_TOKEN_BEFORE, true, null);
		GraphAPIService.putApiRefreshTokenToSettings(TEST_GRAPH_API_REFRESH_TOKEN_BEFORE, true, null);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT, getRefreshTokenMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS_UPSERT = null;
		GraphAPIService.GRAPH_API_LIST_RECORDS_DELETE = null;
		ManageTokensBatch.getInstance().startBatch();
		Test.stopTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		System.assertEquals(TEST_GRAPH_API_TOKEN_AFTER, GraphAPIService.getApiTokenFromSettings());
		System.assertEquals(TEST_GRAPH_API_REFRESH_TOKEN_AFTER, GraphAPIService.getApiRefreshTokenFromSettings());
	}

	public static void enableTeamsIntegration() {
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
			0=>1, 1=>1,	2=>1,
			3=>1, 4=>1,	5=>1,
			6=>1, 7=>1,	8=>1,
			9=>1, 10=>0, 11=>0,
			12=>1, 13=>0, 14=>1,
			15=>1, 16=>0, 17=>1,
			18=>1, 19=>0, 20=>0,
			21=>0, 22=>0, 23=>0,
			24=>0, 25=>0, 26=>0,
			27=>0, 28=>0
		});
		PermissionsUtil.FeatureMap1IntValue = intValue;
	}

	private static TestDataFactory.SingleRequestMock getRefreshTokenMock() {
		ConnectedOrgService.AuthTokenResponse wrapper = new ConnectedOrgService.AuthTokenResponse();
		wrapper.access_token = TEST_GRAPH_API_TOKEN_AFTER;
		wrapper.refresh_token = TEST_GRAPH_API_REFRESH_TOKEN_AFTER;
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}
}