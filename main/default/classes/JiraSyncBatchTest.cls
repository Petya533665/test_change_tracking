@IsTest
@TestVisible
private class JiraSyncBatchTest {

	public static final String JIRA_MOCK_REST_ENDPOINT = 'http://test.jira.com';
	public static final String JIRA_MOCK_REST_API = JIRA_MOCK_REST_ENDPOINT +'/rest/api/';
	
	public static final String JIRA_MOCK_TICKET_ID = 'Key-1';
	public static final String JIRA_MOCK_TICKET_URL = ConfigUtil.JIRA_TASK_URL + JIRA_MOCK_TICKET_ID;
	public static final String JIRA_MOCK_TICKET_ID2 = 'Key-2';
	public static final String JIRA_MOCK_TICKET_URL2 = ConfigUtil.JIRA_TASK_URL + JIRA_MOCK_TICKET_ID2;
	public static final String JIRA_MOCK_PROJECT_ID = 'test';
	public static final String JIRA_MOCK_ISSUE_TYPE_ID = 'test';
	public static final String JIRA_MOCK_PRIORITY_SFDC = 'Medium';
	public static final String JIRA_MOCK_PRIORITY_JIRA = 'Low';
	public static final String JIRA_MOCK_RESOLVE_DATE = '2020-04-24T10:41:33.239-0700';
	public static final String JIRA_MOCK_EXTRA_RELATED_TICKET_KEY = 'KEY-01';
	public static final String JIRA_MOCK_EXTRA_RELATED_TICKET_ID = '10001';
	public static final String JIRA_MOCK_EXTRA_DUPLICATED_TICKET_KEY = 'KEY-02';
	public static final String JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID = '10002';
	

	public static final String AZURE_DEV_OPS_MOCK_ACCOUNT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_PROJECT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID = '5';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID2 = '6';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL2 = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID2});
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID3 = '7';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL3 = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID3});
	public static final String AZURE_DEV_OPS_MOCK_PRIORITY_SFDC = 'High';
	public static final String AZURE_DEV_OPS_MOCK_PRIORITY_AZURE = '3';
	public static final String AZURE_DEV_OPS_MOCK_CLOSE_DATE = '2023-04-13T19:03:25.153Z';
	public static final String AZURE_DEV_OPS_MOCK_EXTRA_RELATED_WORK_ITEM_ID = '01';
	public static final String AZURE_DEV_OPS_MOCK_EXTRA_DUPLICATED_WORK_ITEM_ID = '02';


	@TestSetup
	@TestVisible
	private static void testSetup() {
		Logger_Settings__c settings = Logger_Settings__c.getOrgDefaults();
		settings.Monitoring_Enabled__c = false;
		insert settings;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_API_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		insert jiraSettings;

		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		azureSettings.Organization_Id__c = AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
		azureSettings.Create_Unique_Tickets_by_Org__c = true;
		insert azureSettings;

		GraphAPIService.putAzureDevOpsApiTokenToSettings('sometoken', true, null);
	}

	@IsTest
	private static void testUnlinkIssueBugTrackerOnRemovedTicketJira() {
		testUnlinkIssueBugTrackerOnRemovedTicket(false);
	}

	@IsTest
	private static void testUnlinkIssueBugTrackerOnRemovedTicketAzureDevOps() {
		testUnlinkIssueBugTrackerOnRemovedTicket(false);
	}

	private static void testUnlinkIssueBugTrackerOnRemovedTicket(Boolean isJira) {
		Map<String, HttpCalloutMock> endpoint2TestResp = getTicketNotFoundMocks();
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		insert logs;
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c, Related_Issue__c, First_Occurred_On__c FROM Issue__c];
		System.assertEquals(1, testIssues.size());

		testIssues.get(0).Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		update testIssues;

		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			JiraNotificationBatchTest.enableAzureDevOpsNotifications();
		}

		enableSyncCompletedStatus();
		enableSyncIssuePriority();
		enableSyncRelated();
		ConfigUtil.JIRA_SETTINGS = null;
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		Test.startTest();
		JiraSyncBatch.getInstance().startBatch();
		Test.stopTest();

		Issue__c issue = [SELECT Id, Bug_Tracker__c FROM Issue__c WHERE Id = :testIssues.get(0).Id];
		System.assertEquals(null, issue.Bug_Tracker__c);
	}

	private static Map<String, HttpCalloutMock> getTicketNotFoundMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getExpandedIssueEndpoint(JIRA_MOCK_TICKET_ID), getJiraTicketNotFoundMock());
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(endpoint, getAzureDevOpsTicketNotFoundMock());
		return endpoint2TestResp;
	}

	private static TestDataFactory.SingleRequestMock getJiraTicketNotFoundMock() {
		TestDataFactory.SingleRequestMock getTicket = new TestDataFactory.SingleRequestMock(
			404,
			'OK',
			'Ticket not found'
		);
		return getTicket;
	}

	private static TestDataFactory.SingleRequestMock getAzureDevOpsTicketNotFoundMock() {
		TestDataFactory.SingleRequestMock getTicket = new TestDataFactory.SingleRequestMock(
			404,
			'OK',
			'TF401232: Work item 140 does not exist, or you do not have permissions to read it.'
		);
		return getTicket;
	}

	private static void enableSyncRelated() {
		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		azureSettings.Synchronize_related_tickets_and_issues__c = true;
		azureSettings.Synchronize_duplicate_tickets_and_issues__c = true;
		upsert azureSettings;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Synchronize_related_tickets_and_issues__c = true;
		jiraSettings.Synchronize_duplicate_tickets_and_issues__c = true;
		upsert jiraSettings;
	}

	@TestVisible
	private static void enableSyncCompletedStatus() {
		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		azureSettings.Synchronize_completed_Status__c = true;
		upsert azureSettings;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Synchronize_completed_Status__c = true;
		upsert jiraSettings;
	}

	private static void enableSyncIssuePriority() {
		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		azureSettings.Automatically_update_Issue_priority__c = true;
		upsert azureSettings;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Automatically_update_Issue_priority__c = true;
		upsert jiraSettings;
	}

	private static void enableSyncTicketPriority() {
		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		azureSettings.Automatically_update_ticket_priority__c = true;
		upsert azureSettings;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Automatically_update_ticket_priority__c = true;
		upsert jiraSettings;
	}

	@TestVisible
	private static Map<String, HttpCalloutMock> getJiraTicketMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getIssueEndpoint(JIRA_MOCK_TICKET_ID), setJiraTicketPriorityMock());
		endpoint2TestResp.put(JiraService.getService().getExpandedIssueEndpoint(JIRA_MOCK_TICKET_ID), getJiraTicketDetailsMock());
		endpoint2TestResp.put(JiraService.getService().getExpandedIssueEndpoint(JIRA_MOCK_TICKET_ID2), getJiraTicket2DetailsMock());
		List<String> jiraKeys = new List<String>{JIRA_MOCK_TICKET_ID};
		endpoint2TestResp.put(JiraService.getService().getBulkResolutionTasksEndpoint(jiraKeys), setJiraTicketResolutionMock());
		endpoint2TestResp.put(JiraService.getService().getLinkIssuesEndpoint(), createJiraTicketLinkMock());
		endpoint2TestResp.put(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_RELATED_TICKET_ID), getUnLinkIssueJiraMock(JIRA_MOCK_EXTRA_RELATED_TICKET_ID));
		endpoint2TestResp.put(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID), getUnLinkIssueJiraMock(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID));
		return endpoint2TestResp;
	}

	public static Map<String, HttpCalloutMock> createAzureDevOpsMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(endpoint, createAzureDevOpsExistTicketMock());
		return endpoint2TestResp;
	}

	public static Map<String, HttpCalloutMock> createAzureDevOpsMocksUpdates() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(endpoint, createAzureDevOpsExistTicketMock());
		return endpoint2TestResp;
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createAzureDevOpsExistTicketMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
		existWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
		existWorkItem.fields.Priority = AZURE_DEV_OPS_MOCK_PRIORITY_AZURE;
		existWorkItem.fields.ClosedDate = AZURE_DEV_OPS_MOCK_CLOSE_DATE;

		AzureService.AzureDevOpsWorkItemRelation relation1 = new AzureService.AzureDevOpsWorkItemRelation();
		relation1.rel = AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK;
		relation1.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_EXTRA_RELATED_WORK_ITEM_ID});
		AzureService.AzureDevOpsWorkItemRelation relation2 = new AzureService.AzureDevOpsWorkItemRelation();
		relation2.rel = AzureService.WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK;
		relation2.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_EXTRA_DUPLICATED_WORK_ITEM_ID});
		existWorkItem.relations = new List<AzureService.AzureDevOpsWorkItemRelation>{relation1, relation2};

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createAzureDevOpsPatchExistTicketMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
		existWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@IsTest
	private static void testTicketingSyncBatchJira() {
		testSyncTicketingBatch(true);
	}

	@IsTest
	private static void testTicketingSyncBatchAzureDevOps() {
		testSyncTicketingBatch(false);
	}

	/*
	* test sync relations/priority/status by batch
	*/
	private static void testSyncTicketingBatch(Boolean isJira) {
		Map<String, HttpCalloutMock> endpoint2TestResp = getJiraTicketMocks();
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocksUpdates());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_2', 'hash2_1', 'hash3_2'));
		insert logs;
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c != NULL]);
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c, Related_Issue__c, First_Occurred_On__c FROM Issue__c];
		System.assertEquals(2, testIssues.size());
		
		Issue__c childIssue;
		Issue__c parentIssue;

		for(Issue__c issue : testIssues) {
			System.assertEquals(JIRA_MOCK_PRIORITY_SFDC, testIssues.get(0).Priority__c);
			if(issue.Related_Issue__c == null) {
				issue.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-2);
				parentIssue = issue;
			}
			else {
				issue.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL2 : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL2;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-1);
				childIssue = issue;
			}
		}
		update testIssues;

		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			JiraNotificationBatchTest.enableAzureDevOpsNotifications();
		}

		enableSyncCompletedStatus();
		enableSyncIssuePriority();
		enableSyncRelated();
		ConfigUtil.JIRA_SETTINGS = null;
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		Test.startTest();
		JiraSyncBatch.getInstance().startBatch();
		Test.stopTest();

		parentIssue = [SELECT Id, Status__c, Priority__c, Resolved_On__c, Override_Priority__c FROM Issue__c WHERE Id = :parentIssue.Id];
		
		System.assertEquals(true, parentIssue.Override_Priority__c);
		System.assertEquals((isJira ? JIRA_MOCK_PRIORITY_JIRA : AZURE_DEV_OPS_MOCK_PRIORITY_SFDC), parentIssue.Priority__c);
		System.assertNotEquals(null, parentIssue.Resolved_On__c);

		if(isJira) {
			HttpRequest deleteLinkRequest1 = multiCalloutMock.getRequest(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_RELATED_TICKET_ID));
			HttpRequest deleteLinkRequest2 = multiCalloutMock.getRequest(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID));
			HttpRequest createLinkRequest1 = multiCalloutMock.getRequest(JiraService.getService().getLinkIssuesEndpoint());
			System.assertNotEquals(null, deleteLinkRequest1);
			System.assertNotEquals(null, deleteLinkRequest2);
			System.assertNotEquals(null, createLinkRequest1);
			
			HttpResponse deleteLinkResponse1 = multiCalloutMock.getResponse(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_RELATED_TICKET_ID));
			HttpResponse deleteLinkResponse2 = multiCalloutMock.getResponse(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID));
			HttpResponse createLinkResponse1 = multiCalloutMock.getResponse(JiraService.getService().getLinkIssuesEndpoint());
			
			system.assertEquals('deleted', deleteLinkResponse1.getBody());
			system.assertEquals('deleted', deleteLinkResponse2.getBody());
			system.assertEquals('created', createLinkResponse1.getBody());
		}
		else {
			String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
			HttpRequest updateWorkItemRequest = multiCalloutMock.getRequest(endpoint);
			System.assertNotEquals(null, updateWorkItemRequest);
			System.assertEquals(true, updateWorkItemRequest.getBody().contains('/relations/0'));
			System.assertEquals(true, updateWorkItemRequest.getBody().contains('/relations/1'));
		}
	}

	@IsTest
	private static void test_sync_relations_by_trigger_handler_jira() {
		testSyncRelationsTicketing(true);
	}

	@IsTest
	private static void test_sync_relations_by_trigger_handler_azure_dev_ops() {
		testSyncRelationsTicketing(false);
	}

	/*
	* test sync relations by trigger handler
	*/
	private static void testSyncRelationsTicketing(Boolean isJira) {
		Map<String, HttpCalloutMock> endpoint2TestResp = getJiraTicketMocks();
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocksUpdates());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_2', 'hash2_1', 'hash3_2'));
		insert logs;
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c != NULL]);
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c, Related_Issue__c, First_Occurred_On__c FROM Issue__c];
		System.assertEquals(2, testIssues.size());

		Issue__c childIssue;
		Issue__c parentIssue;
		
		// assign bug trackers, dml should be start sync queueable
		for(Issue__c issue : testIssues) {
			if(issue.Related_Issue__c == null) {
				issue.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-2);
				parentIssue = issue;
			}
			else {
				issue.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL2 : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL2;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-1);
				childIssue = issue;
			}
		}

		update childIssue;
		
		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			JiraNotificationBatchTest.enableAzureDevOpsNotifications();
		}
		enableSyncCompletedStatus();
		enableSyncIssuePriority();
		enableSyncRelated();
		ConfigUtil.JIRA_SETTINGS = null;
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		Test.startTest();
		update parentIssue;
		Test.stopTest();
		
		if(isJira) {
			HttpRequest deleteLinkRequest1 = multiCalloutMock.getRequest(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_RELATED_TICKET_ID));
			HttpRequest deleteLinkRequest2 = multiCalloutMock.getRequest(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID));
			HttpRequest createLinkRequest1 = multiCalloutMock.getRequest(JiraService.getService().getLinkIssuesEndpoint());
			System.assertNotEquals(null, deleteLinkRequest1);
			System.assertNotEquals(null, deleteLinkRequest2);
			System.assertNotEquals(null, createLinkRequest1);
			
			HttpResponse deleteLinkResponse1 = multiCalloutMock.getResponse(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_RELATED_TICKET_ID));
			HttpResponse deleteLinkResponse2 = multiCalloutMock.getResponse(JiraService.getService().getUnLinkIssueEndpoint(JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID));
			HttpResponse createLinkResponse1 = multiCalloutMock.getResponse(JiraService.getService().getLinkIssuesEndpoint());
			
			system.assertEquals('deleted', deleteLinkResponse1.getBody());
			system.assertEquals('deleted', deleteLinkResponse2.getBody());
			system.assertEquals('created', createLinkResponse1.getBody());
		}
		else {
			String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
			HttpRequest updateWorkItemRequest = multiCalloutMock.getRequest(endpoint);
			System.assertNotEquals(null, updateWorkItemRequest);
			System.assertEquals(true, updateWorkItemRequest.getBody().contains('/relations/0'));
			System.assertEquals(true, updateWorkItemRequest.getBody().contains('/relations/1'));
		}
	}

	private static TestDataFactory.SingleRequestMock setJiraTicketPriorityMock() {
		TestDataFactory.SingleRequestMock getIssueMeta = new TestDataFactory.SingleRequestMock(
			204,
			'OK',
			''
		);
		return getIssueMeta;
	}

	private static TestDataFactory.SingleRequestMock createJiraTicketLinkMock() {
		TestDataFactory.SingleRequestMock creteLinkMeta = new TestDataFactory.SingleRequestMock(
			201,
			'OK',
			'created'
		);
		return creteLinkMeta;
	}

	private static TestDataFactory.SingleRequestMock setJiraTicketResolutionMock() {
		Map<String, Object> jiraData = new Map<String, Object> {
			'issues' => new List<Object> {
				new Map<String, Object> {
					'key' => JIRA_MOCK_TICKET_ID,
					'fields' => new Map<String, Object> {
						'resolutiondate' => JIRA_MOCK_RESOLVE_DATE
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

	private static TestDataFactory.SingleRequestMock getJiraTicketDetailsMock() {
		Map<String, Object> response = new Map<String, Object>{
			'id' => JIRA_MOCK_TICKET_URL,
			'key' => JIRA_MOCK_TICKET_URL,
			'fields' => new Map<String, Object>{
				'status' => new Map<String, Object>{
					'name' => 'In Progress'
				},
				'priority' => new Map<String, Object>{
					'name' => JIRA_MOCK_PRIORITY_JIRA
				},
				'issuelinks' => new List<Map<String, Object>> {
					new Map<String, Object>{
						'id' => JIRA_MOCK_EXTRA_RELATED_TICKET_ID,
						'type' => new Map<String, Object> {
							'name' => 'Relates'
						},
						'inwardIssue' => new Map<String, Object> {
							'id' => '10004',
							'key' => JIRA_MOCK_EXTRA_RELATED_TICKET_KEY
						}
					},
					new Map<String, Object>{
						'id' => JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID,
						'type' => new Map<String, Object> {
							'name' => 'Duplicate'
						},
						'inwardIssue' => new Map<String, Object> {
							'id' => '10005',
							'key' => JIRA_MOCK_EXTRA_DUPLICATED_TICKET_KEY
						}
					}
				}
			}
		};
		TestDataFactory.SingleRequestMock getIssueMeta = new TestDataFactory.SingleRequestMock(
		200,
		'OK',
			JSON.serialize(response)
		);
		return getIssueMeta;
	}

	private static TestDataFactory.SingleRequestMock getJiraTicket2DetailsMock() {
		Map<String, Object> response = new Map<String, Object>{
			'id' => JIRA_MOCK_TICKET_URL2,
			'key' => JIRA_MOCK_TICKET_URL2,
			'fields' => new Map<String, Object>{
				'status' => new Map<String, Object>{
					'name' => 'In Progress'
				},
				'priority' => new Map<String, Object>{
					'name' => JIRA_MOCK_PRIORITY_JIRA
				},
				'issuelinks' => new List<Map<String, Object>> {
					new Map<String, Object>{
						'id' => JIRA_MOCK_EXTRA_DUPLICATED_TICKET_ID,
						'type' => new Map<String, Object> {
							'name' => 'Duplicate'
						},
						'inwardIssue' => new Map<String, Object> {
							'id' => JIRA_MOCK_TICKET_ID,
							'key' => JIRA_MOCK_TICKET_ID
						}
					}
				}
			}
		};
		TestDataFactory.SingleRequestMock getIssueMeta = new TestDataFactory.SingleRequestMock(
		200,
		'OK',
			JSON.serialize(response)
		);
		return getIssueMeta;
	}

	private static TestDataFactory.SingleRequestMock getUnLinkIssueJiraMock(String linkId) {
		TestDataFactory.SingleRequestMock getIssueMeta = new TestDataFactory.SingleRequestMock(
			204,
			'OK',
			'deleted'
		);
		return getIssueMeta;
	}

	@IsTest
	private static void testPushIssuePriorityJira() {
		testPushIssuePriority(true);
	}

	@IsTest
	private static void testPushIssuePriorityAzureDevOps() {
		testPushIssuePriority(false);
	}

	private static void testPushIssuePriority(Boolean isJira) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getIssueEndpoint(JIRA_MOCK_TICKET_ID), setJiraTicketPriorityMock());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			JiraNotificationBatchTest.enableAzureDevOpsNotifications();
		}
		TestDataFactory.enableIssueTracking();
		insert IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c FROM Issue__c];
		System.assertEquals(1, testIssues.size());
		System.assertEquals(JIRA_MOCK_PRIORITY_SFDC, testIssues.get(0).Priority__c);

		enableSyncTicketPriority();
		ConfigUtil.JIRA_SETTINGS = null;
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		Test.startTest();
		for(Issue__c issue : testIssues) {
			issue.Priority__c = isJira ? JIRA_MOCK_PRIORITY_JIRA : AZURE_DEV_OPS_MOCK_PRIORITY_SFDC;
			issue.Bug_Tracker__c = isJira ? JIRA_MOCK_TICKET_URL : AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		}
		update testIssues;
		Test.stopTest();
	}

	/*
	* test sync ADO relations by trigger handler
	*/
	@IsTest
	private static void testSyncAzureDevOpsRelationsByTriggerHandler() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createRetrieveChildWorkItemAzureDevOpsMocks());
		endpoint2TestResp.putAll(createRetrieveParentWorkItemAzureDevOpsMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocksUpdates());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		insert logs;

		logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_2', 'hash2_1', 'hash3_2'));
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_3', 'hash2_1', 'hash3_2'));
		insert logs;

		System.assertEquals(2, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c != NULL]);
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c, Related_Issue__c, First_Occurred_On__c FROM Issue__c];
		System.assertEquals(3, testIssues.size());

		Issue__c childRelatedIssue;
		Issue__c childDuplicatedIssue;
		Issue__c parentIssue;
		
		// assign bug trackers, dml should be start sync queueable
		for(Issue__c issue : testIssues) {
			if(issue.Related_Issue__c == null) {
				issue.Bug_Tracker__c = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-2);
				parentIssue = issue;
			}
			else if (childRelatedIssue == null) {
				issue.Bug_Tracker__c = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL2;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-1);
				childRelatedIssue = issue;
			}
			else {
				issue.Bug_Tracker__c = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL3;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-1);
				issue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
				childDuplicatedIssue = issue;
			}
		}

		update new List<Issue__c>{childDuplicatedIssue, childRelatedIssue};

		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		JiraNotificationBatchTest.enableAzureDevOpsNotifications();
		enableSyncRelated();
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		Test.startTest();
		update parentIssue;
		Test.stopTest();
		
		
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		HttpRequest updateWorkItemRequest = multiCalloutMock.getRequest(endpoint);
		System.assertNotEquals(null, updateWorkItemRequest);

		List<Object>  workItemRequest = (List<Object>)JSON.deserializeUntyped(updateWorkItemRequest.getBody());
		System.assertEquals(4, workItemRequest.size());

		Boolean addRelatedLink = false;
		Boolean addDuplicatedLink = false;
		Boolean removeRelatedLink = false;
		Boolean removeDuplicatedLink = false;

		for(Object item : workItemRequest) {
			Map<String, Object> itemObj = (Map<String, Object>)item;
			String itemOp = (String)itemObj.get('op');
			Map<String, Object> itemValueObj = (Map<String, Object>)itemObj.get('value');
			String relValue = itemValueObj != null && itemValueObj.get('rel') != null ? (String)itemValueObj.get('rel') : '';
			String pathValue = (String)itemObj.get('path');
			if(itemOp == AzureService.WORK_ITEM_TYPE_OPERATION_ADD) {
				if(relValue == AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK){
					addRelatedLink = true;
				}
				else {
					addDuplicatedLink = true;
				}
			}
			else if(itemOp == AzureService.WORK_ITEM_TYPE_OPERATION_REMOVE) {
				if(pathValue == '/relations/0'){
					removeRelatedLink = true;
				}
				else {
					removeDuplicatedLink = true;
				}
			}
		}

		System.assertEquals(true, addRelatedLink);
		System.assertEquals(true, addDuplicatedLink);
		System.assertEquals(true, removeRelatedLink, updateWorkItemRequest.getBody());
		System.assertEquals(true, removeDuplicatedLink);		
	}

	public static Map<String, HttpCalloutMock> createRetrieveChildWorkItemAzureDevOpsMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID2});
		endpoint2TestResp.put(endpoint, createRetrieveChildDuplicatedWorkItemMock());

		endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID3});
		endpoint2TestResp.put(endpoint, createRetrieveChildRelatedWorkItemMock());
		return endpoint2TestResp;
	}

	public static Map<String, HttpCalloutMock> createRetrieveParentWorkItemAzureDevOpsMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(endpoint, createRetrieveParentWorkItemMock());
		return endpoint2TestResp;
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createRetrieveChildRelatedWorkItemMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID2;
		existWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID2});
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
		existWorkItem.fields.Priority = AZURE_DEV_OPS_MOCK_PRIORITY_AZURE;
		existWorkItem.fields.ClosedDate = AZURE_DEV_OPS_MOCK_CLOSE_DATE;
		existWorkItem.relations = new List<AzureService.AzureDevOpsWorkItemRelation>();

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createRetrieveChildDuplicatedWorkItemMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID3;
		existWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID3});
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
		existWorkItem.fields.Priority = AZURE_DEV_OPS_MOCK_PRIORITY_AZURE;
		existWorkItem.fields.ClosedDate = AZURE_DEV_OPS_MOCK_CLOSE_DATE;
		existWorkItem.relations = new List<AzureService.AzureDevOpsWorkItemRelation>();

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock createRetrieveParentWorkItemMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
		existWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
		existWorkItem.fields.Priority = AZURE_DEV_OPS_MOCK_PRIORITY_AZURE;
		existWorkItem.fields.ClosedDate = AZURE_DEV_OPS_MOCK_CLOSE_DATE;
		
		AzureService.AzureDevOpsWorkItemRelation relation1 = new AzureService.AzureDevOpsWorkItemRelation();
		relation1.rel = AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK;
		relation1.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_EXTRA_RELATED_WORK_ITEM_ID});
		AzureService.AzureDevOpsWorkItemRelation relation2 = new AzureService.AzureDevOpsWorkItemRelation();
		relation2.rel = AzureService.WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK;
		relation2.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_EXTRA_DUPLICATED_WORK_ITEM_ID});
		existWorkItem.relations = new List<AzureService.AzureDevOpsWorkItemRelation>{relation1, relation2};

		return new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@IsTest
	private static void testSyncJiraRelationsByTriggerHandler_on_remove_duplicate() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(getJiraTicketMocks());
		
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		insert logs;

		logs = new List<Log__c>();
		logs.add(IssueTriggerHandlerTest.createPharosLog('hash1_2', 'hash2_1', 'hash3_2'));
		insert logs;

		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c != NULL]);
		List<Issue__c> testIssues = [SELECT Id, Status__c, Priority__c, Related_Issue__c, First_Occurred_On__c FROM Issue__c];
		System.assertEquals(2, testIssues.size());

		Issue__c childDuplicatedIssue;
		Issue__c parentIssue;
		
		// assign bug trackers, dml should be start sync queueable
		for(Issue__c issue : testIssues) {
			if(issue.Related_Issue__c == null) {
				issue.Bug_Tracker__c = JIRA_MOCK_TICKET_URL;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-2);
				parentIssue = issue;
			}
			else {
				issue.Bug_Tracker__c = JIRA_MOCK_TICKET_URL2;
				issue.First_Occurred_On__c = issue.First_Occurred_On__c.addHours(-1);
				issue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
				childDuplicatedIssue = issue;
			}
		}

		update new List<Issue__c>{parentIssue, childDuplicatedIssue};

		enableSyncRelated();
		ConfigUtil.JIRA_SETTINGS = null;
		ConfigUtil.AZURE_DEV_OPS_API_SETTINGS = null;

		// remove second chain
		Test.startTest();
		childDuplicatedIssue.Status__c = IssueService.ISSUE_STATUS_NEW;
		update childDuplicatedIssue;
		Test.stopTest();
		
		HttpRequest createLinkRequest1 = multiCalloutMock.getRequest(JiraService.getService().getLinkIssuesEndpoint());
		System.assertNotEquals(null, createLinkRequest1);
		
		HttpResponse createLinkResponse1 = multiCalloutMock.getResponse(JiraService.getService().getLinkIssuesEndpoint());
		system.assertEquals('created', createLinkResponse1.getBody());	
	}
}