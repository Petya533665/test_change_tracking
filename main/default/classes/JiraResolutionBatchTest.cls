@IsTest
private class JiraResolutionBatchTest {

	public static final String JIRA_MOCK_REST_ENDPOINT = 'http://test.jira.com';
	public static final String JIRA_MOCK_REST_API = JIRA_MOCK_REST_ENDPOINT +'/rest/api/';
	
	public static final String JIRA_MOCK_TICKET_ID = 'Key-1';
	public static final String JIRA_MOCK_TICKET_URL = ConfigUtil.JIRA_TASK_URL + JIRA_MOCK_TICKET_ID;
	public static final String JIRA_MOCK_PROJECT_ID = 'test';
	public static final String JIRA_MOCK_HASH1 = 'hash1';
	public static final String JIRA_MOCK2_HASH1 = 'hash2';
	public static final String JIRA_MOCK_TICKET2_ID = 'Key-2';
	public static final String JIRA_MOCK_TICKET2_URL = ConfigUtil.JIRA_TASK_URL + JIRA_MOCK_TICKET2_ID;
	public static final String JIRA_MOCK_ISSUE_TYPE_ID = 'test';
	public static final String JIRA_MOCK_RESOLVE_DATE = '2020-04-24T10:41:33.239-0700';
	

	public static final String AZURE_DEV_OPS_MOCK_ACCOUNT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_PROJECT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID = '5';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM2_ID = '6';
	public static final String AZURE_DEV_OPS_MOCK_HASH1 = 'azurehash1';
	public static final String AZURE_DEV_OPS_MOCK2_HASH1 = 'azurehash2';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM2_URL = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM2_ID});
	public static final String AZURE_DEV_OPS_MOCK_CLOSE_DATE = '2023-04-13T19:03:25.153Z';

	@TestSetup
	private static void testSetup() {

		Jira_Settings__c jiraSettings = new Jira_Settings__c();
		jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		insert jiraSettings;

		Azure_Dev_Ops_API_Settings__c azureSettings = new Azure_Dev_Ops_API_Settings__c();
		azureSettings.Organization_Id__c = AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
		azureSettings.Create_Unique_Tickets_by_Org__c = true;
		insert azureSettings;

		GraphAPIService.putAzureDevOpsApiTokenToSettings('sometoken', true, null);
	}

	@IsTest
	static void testLogRegression_positive_jira() {
		testLogRegression_positive(true);
	}

	@IsTest
	static void testLogRegression_positive_azure_dev_ops() {
		testLogRegression_positive(false);
	}

	static void testLogRegression_positive(Boolean isJira) {
		Log__c log1 = new Log__c();
		log1.Hash_1__c = JIRA_MOCK_HASH1;
		log1.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		log1.Resolved_On__c = DateTime.now().addDays(-1);
		insert log1;

		Test.startTest();
		Log__c log2 = new Log__c();
		log2.Hash_1__c = JIRA_MOCK_HASH1;
		log2.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		insert log2;
		Test.stopTest();

		log2 = [SELECT Id, Regression__c, Regressed_On__c FROM Log__c WHERE Id =: log2.Id LIMIT 1];
		System.assertEquals(true, log2.Regression__c);
		System.assertNotEquals(null, log2.Regressed_On__c);
	}

	@IsTest
	static void testLogRegression_negative() {
		Log__c log1 = new Log__c();
		log1.Hash_1__c = JIRA_MOCK_HASH1;
		log1.Bug_Tracker__c = JIRA_MOCK_TICKET_URL;
		insert log1;

		Test.startTest();
		Log__c log2 = new Log__c();
		log2.Hash_1__c = JIRA_MOCK_HASH1;
		log2.Bug_Tracker__c = JIRA_MOCK_TICKET_URL;
		insert log2;
		Test.stopTest();

		log2 = [SELECT Id, Regression__c, Regressed_On__c FROM Log__c WHERE Id =: log2.Id LIMIT 1];
		System.assertEquals(false, log2.Regression__c);
		System.assertEquals(null, log2.Regressed_On__c);
	}

	@IsTest
	static void testBatch() {
		Log__c log1 = new Log__c();
		log1.Hash_1__c = JIRA_MOCK_HASH1;
		log1.Bug_Tracker__c = JIRA_MOCK_TICKET_URL;
		Log__c log2 = new Log__c();
		log2.Hash_1__c = AZURE_DEV_OPS_MOCK_HASH1;
		log2.Bug_Tracker__c = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		Log__c log3 = new Log__c();
		log3.Hash_1__c = JIRA_MOCK2_HASH1;
		log3.Bug_Tracker__c = JIRA_MOCK_TICKET2_URL;
		Log__c log4 = new Log__c();
		log4.Hash_1__c = AZURE_DEV_OPS_MOCK2_HASH1;
		log4.Bug_Tracker__c = AZURE_DEV_OPS_MOCK_WORK_ITEM2_URL;
		insert new List<Log__c>{log1, log2, log3, log4};

		Test.startTest();

		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		JiraNotificationBatchTest.enableAzureDevOpsNotifications();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(getBatchMocks());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		JiraResolutionBatch.getInstance().forceStartBatch();
		Test.stopTest();

		log1 = [SELECT Id, Resolved_On__c FROM Log__c WHERE Id =: log1.Id LIMIT 1];
		log2 = [SELECT Id, Resolved_On__c FROM Log__c WHERE Id =: log2.Id LIMIT 1];
		log3 = [SELECT Id, Resolved_On__c FROM Log__c WHERE Id =: log3.Id LIMIT 1];
		log4 = [SELECT Id, Resolved_On__c FROM Log__c WHERE Id =: log4.Id LIMIT 1];
		System.assertNotEquals(null, log1.Resolved_On__c);
		System.assertNotEquals(null, log2.Resolved_On__c);
		System.assertEquals(null, log3.Resolved_On__c);
		System.assertEquals(null, log4.Resolved_On__c);
	}

	private static Map<String, HttpCalloutMock> getBatchMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		List<String> jiraKeys = new List<String>{JIRA_MOCK_TICKET_ID, JIRA_MOCK_TICKET2_ID};
		endpoint2TestResp.put(JiraService.getService().getBulkResolutionTasksEndpoint(jiraKeys), setJiraTicketResolutionMock());
		
		String wiIds = String.join(new List<String>{AZURE_DEV_OPS_MOCK_WORK_ITEM_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM2_ID}, ',');
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_LIST, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, wiIds});
		endpoint2TestResp.put(endpoint, createAzureDevOpsTicketListMock());

		return endpoint2TestResp;
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createAzureDevOpsTicketListMock() {
		AzureService.AzureDevOpsWorkItemWrapper wrapper = new AzureService.AzureDevOpsWorkItemWrapper();
		AzureService.AzureDevOpsWorkItem workItem1 = new AzureService.AzureDevOpsWorkItem();
		workItem1.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
		workItem1.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		workItem1.fields = new AzureService.AzureDevOpsWorkItemFields();
		workItem1.fields.ClosedDate = AZURE_DEV_OPS_MOCK_CLOSE_DATE;
		AzureService.AzureDevOpsWorkItem workItem2 = new AzureService.AzureDevOpsWorkItem();
		workItem2.id = AZURE_DEV_OPS_MOCK_WORK_ITEM2_ID;
		workItem2.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM2_ID});
		workItem2.fields = new AzureService.AzureDevOpsWorkItemFields();
		workItem2.fields.ClosedDate = null;
		wrapper.count = 2;
		wrapper.value = new List<AzureService.AzureDevOpsWorkItem>{workItem1, workItem2};

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrapper)
		);
	}

	private static TestDataFactory.SingleRequestMock setJiraTicketResolutionMock() {
		Map<String, Object> jiraData = new Map<String, Object> {
			'issues' => new List<Object> {
				new Map<String, Object> {
					'key' => JIRA_MOCK_TICKET_ID,
					'fields' => new Map<String, Object> {
						'resolutiondate' => JIRA_MOCK_RESOLVE_DATE
					}
				},
				new Map<String, Object> {
					'key' => JIRA_MOCK_TICKET2_ID,
					'fields' => new Map<String, Object> {
						'resolutiondate' => null
					}
				}
			}
		};

		TestDataFactory.SingleRequestMock getIssueMeta = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(jiraData)
		);
		return getIssueMeta;
	}
}