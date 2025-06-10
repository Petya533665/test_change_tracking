@IsTest
public class JiraNotificationBatchTest {

	@IsTest
	private static void test_settings_auth_jira_cloud() {
		Jira_Settings__c settings = JIRA_Settings__c.getOrgDefaults();
		settings.Jira_Username__c = JiraService.JIRA_CLOUD_OAUTH_USERNAME;
		update settings;
		ConfigUtil.JIRA_SETTINGS = null;

		JiraService.JIRA_SERVICE_AUTH_TYPE authType;
		Test.startTest();
		authType = JiraService.getJIRAServiceAuthType();
		Test.stopTest();
		system.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, authType);
	}

	@IsTest
	private static void test_settings_auth_jira_pat() {
		Jira_Settings__c settings = JIRA_Settings__c.getOrgDefaults();
		settings.Jira_Username__c = null;
		update settings;
		ConfigUtil.JIRA_SETTINGS = null;

		JiraService.JIRA_SERVICE_AUTH_TYPE authType;
		Test.startTest();
		authType = JiraService.getJIRAServiceAuthType();
		Test.stopTest();
		system.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, authType);
	}

	@IsTest
	private static void test_settings_auth_jira_hosted() {
		ConfigUtil.JIRA_SETTINGS = null;
		JiraService.JIRA_SERVICE_AUTH_TYPE authType;
		Test.startTest();
		authType = JiraService.getJIRAServiceAuthType();
		Test.stopTest();
		system.assertEquals(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, authType);
	}

	@TestSetup
	private static void testSetup() {
		TestDataFactory.createConnectedOrg();

		Logger_Settings__c settings = Logger_Settings__c.getOrgDefaults();
		settings.Monitoring_Enabled__c = false;
		insert settings;

		Jira_Settings__c jiraSettings = new Jira_Settings__c();
		jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_API_Url__c = JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		jiraSettings.Create_Unique_Tickets_by_Org__c = true;
		jiraSettings.SetupOwnerId = UserInfo.getOrganizationId();
		insert jiraSettings;

		Azure_Dev_Ops_API_Settings__c azureSettings = new Azure_Dev_Ops_API_Settings__c();
		azureSettings.Organization_Id__c = AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
		azureSettings.Create_Unique_Tickets_by_Org__c = true;
		insert azureSettings;

		Connected_Org__c corg = new Connected_Org__c(
            Name = Test_LogService.CONNECETED_ORG_NAME,
            Title__c = Test_LogService.CONNECETED_ORG_TITLE,
            Description__c = Test_LogService.CONNECETED_ORG_DESCRIPTION,
            Type__c = Test_LogService.CONNECETED_ORG_TYPE,
            Access_Token__c = Test_LogService.CONNECETED_ORG_ACCESS_TOKEN,
            Refresh_Token__c = Test_LogService.CONNECETED_ORG_REFRESH_TOKEN,
            Token_Refreshed_At__c = Test_LogService.CONNECETED_ORG_TOKEN_REFRESHED_AT,
            Instance_Url__c = Test_LogService.CONNECETED_ORG_INSTANCE_URL,
            Identity_Url__c = Test_LogService.CONNECETED_ORG_IDENTITY_URL
        );
        insert new List<Connected_Org__c>{corg};
	}

	public static final String AZURE_DEV_OPS_MOCK_ACCOUNT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_PROJECT_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID = '5';
	public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
	public static final String AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID = '6';
	public static final String AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_ISSUE_TYPE_NAME = 'bug';
	public static final String AZURE_DEV_OPS_MOCK_EPICK_ID = 'test';
	public static final String AZURE_DEV_OPS_MOCK_SUBJECT = 'test';
	public static final String AZURE_DEV_OPS_MOCK_DESCRIPTION = 'test';
	public static final String AZURE_DEV_OPS_MOCK_BODY = 'test';
	public static final String AZURE_DEV_OPS_MOCK_TAGS = 'test';
	public static final String AZURE_DEV_OPS_MOCK_PRIORITY = '1';

	public static void enableAzureDevOpsNotifications() {
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
			0=>1, 1=>1,	2=>1,
			3=>1, 4=>1,	5=>1,
			6=>1, 7=>1,	8=>1,
			9=>1, 10=>0, 11=>0,
			12=>1, 13=>0, 14=>0,
			15=>0, 16=>0, 17=>1,
			18=>1, 19=>0, 20=>1,
			21=>0, 22=>0, 23=>0,
			24=>0, 25=>0, 26=>0,
			27=>0, 28=>0
		});
		PermissionsUtil.FeatureMap1IntValue = intValue;
	}

	public static void enableDebugLogService() {
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
			0=>1, 1=>1,	2=>1,
			3=>1, 4=>1,	5=>1,
			6=>1, 7=>1,	8=>1,
			9=>1, 10=>0, 11=>0,
			12=>1, 13=>0, 14=>0,
			15=>0, 16=>0, 17=>1,
			18=>1, 19=>1, 20=>1,
			21=>0, 22=>0, 23=>0,
			24=>0, 25=>0, 26=>0,
			27=>0, 28=>0
		});
		PermissionsUtil.FeatureMap1IntValue = intValue;
	}

	public static Trace_Result__c createTraceResult(Id issueId) {
		Trace_Schedule__c schedule = new Trace_Schedule__c(
			Issue__c = issueId
		);
		insert schedule;
		Trace_Request__c request = new Trace_Request__c(
			Status__c = 'In Progress',
			Start_Date__c = DateTime.now().addHours(1),
			End_Date__c = DateTime.now().addHours(2),
			Traced_Entity_Id__c = UserInfo.getUserId(),
			Source__c = UserInfo.getOrganizationId(),
			Trace_Schedule__c = schedule.Id
		);
		insert request;
		Trace_Result__c traceResult = new Trace_Result__c(
			Issue__c = issueId,
			Trace_Request__c = request.Id,
			Trace_Schedule__c = schedule.Id,
			Trace_Start_Date__c = DateTime.now().addHours(1),
			Trace_End_Date__c = DateTime.now().addHours(2)
		);
		return traceResult;
	}

	public static Map<String, HttpCalloutMock> createAzureDevOpsMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String newTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID});
		endpoint2TestResp.put(newTicketEndpoint, createAzureDevOpsNewTicketMock());
		String existingTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(existingTicketEndpoint, createAzureDevOpsExistTicketMock());
		String workItemCommentEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(workItemCommentEndpoint, createAzureTicketCommentMock());
		return endpoint2TestResp;
	}

	@TestVisible
	private static SingleRequestMock createAzureDevOpsExistTicketMock() {
		AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
		existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
		existWorkItem.url = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
		existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
		existWorkItem.fields.State = 'Done';

		return new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(existWorkItem)
		);
	}

	@TestVisible
	private static SingleRequestMock createAzureDevOpsNewTicketMock() {
		AzureService.AzureDevOpsWorkItem newWorkItem = new AzureService.AzureDevOpsWorkItem();
		newWorkItem.id = AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID;
		newWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID});

		return new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(newWorkItem)
		);
	}

	@IsTest
	private static void test_jira_notification_batch_processing_dosent_rerun_on_update_issue() {

		TestDataFactory.enableIssueTracking();
		// make regular log
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		log.Originated_From__c = null;
		insert log;
		// complete post processing to fire issue
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		List<Issue__c> issues = [SELECT Id, Executable_Rules__c FROM Issue__c WHERE Log__c = :log.Id];
		System.assertEquals(1, issues.size());
		Issue__c issue = issues[0];

		// no rules should be fired on insert
		System.assertEquals(null, issue.Executable_Rules__c);
		NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);
		System.assertEquals(0, config.getAllRuleIdsToRun().size());

		Rule__c testIssueInsertRule1 = createIssueSlackNotificationRule(false);
		Rule__c testIssueInsertRule2 = createIssueSlackNotificationRule(false);
		Rule__c testIssueUpdateRule1 = createIssueSlackNotificationRule(true);

		TestDataFactory.createRuleFilterOnUpdate(1, testIssueUpdateRule1, ISSUE_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_NEW_VALUE, ISSUE_NOTIFICATION_UPDATE_NEW_VALUE, ISSUE_NOTIFICATION_FIELD_NAME, false);
		TestDataFactory.createRuleFilterOnUpdate(2, testIssueUpdateRule1, ISSUE_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_OLD_VALUE, ISSUE_NOTIFICATION_UPDATE_OLD_VALUE, ISSUE_NOTIFICATION_FIELD_NAME, true);

		// simulate insert rule1 should be fired
		config.a.add(testIssueInsertRule1.Id);
		issue.Executable_Rules__c = config.toJson();
		issue.Notification_Integration_Status__c = MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED;
		update issue;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.createSlackSettings();

		String executedRulesBefore = [SELECT Executable_Rules__c FROM Issue__c WHERE Id = :issue.Id].Executable_Rules__c;

		Test.startTest();
		MonitoringUtil.cachedRules.clear();
		// update issue, shuld dosent trigger update rule1
		// update rule affected on Average_Frequency__c field, not on Status__c field
		issue.Status__c = 'Actioned';
		update issue;

		Test.stopTest();
		issue = [SELECT Id, Executable_Rules__c, Slack_Integration_Status__c, Notification_Integration_Status__c FROM Issue__c WHERE Id = :issue.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, issue.Notification_Integration_Status__c);
		System.assertEquals(executedRulesBefore, issue.Executable_Rules__c);
		System.assertEquals(null, issue.Slack_Integration_Status__c);

		assertNoInternalLogs();
	}

	@IsTest
	private static void test_notifications_slack_positive() {
		test_notifications_slack(true, false);
	}
	@IsTest
	private static void test_notifications_slack_negative() {
		test_notifications_slack(false, false);
	}

	private static final String LOG_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_NEW_VALUE = 'Equal';
	private static final String LOG_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_OLD_VALUE = 'Not equal';
	private static final String LOG_NOTIFICATION_UPDATE_NEW_VALUE = 'Debug';
	private static final String LOG_NOTIFICATION_UPDATE_OLD_VALUE = '';
	private static final String LOG_NOTIFICATION_FIELD_NAME = Schema.SObjectType.Log__c.fields.Category__c.getName();
	
	private static void test_notifications_slack(Boolean positiveResult, Boolean isUpdateCase) {
		Rule__c testRule = createSlackNotificationRule();

		if (isUpdateCase) createRuleFilterOnUpdate(testRule);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(positiveResult) {
			TestDataFactory.createSlackSettings();
		}

		Test.startTest();
		Log__c log = TestDataFactory.createTestNotificationLog();

		if(isUpdateCase) {
			log.Category__c = LOG_NOTIFICATION_UPDATE_NEW_VALUE;
			update log;
		}
		else {
			log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
			update log;

			log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);
		}

		Test.stopTest();
		log = [SELECT Slack_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, log.Notification_Integration_Status__c);
			System.assertNotEquals(null, log.Slack_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_notifications_slack_by_flow_email_positive() {
		test_notifications_slack_by_flow_email(true);
	}
	@IsTest
	private static void test_notifications_slack_by_flow_email_negative() {
		test_notifications_slack_by_flow_email(false);
	}

	private static void test_notifications_slack_by_flow_email(Boolean positiveResult) {
		Rule__c testRule = createSlackNotificationRule();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());
		endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.DESCRIBE_SOBJECT_PATH, createDescribeSObjectMock());
		endpoint2TestResp.putAll(Test_StackTraceParser.createPostProcessingMock('accounttranfform1', 'testpharosx', 4));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);		
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(positiveResult) {
			TestDataFactory.createSlackSettings();
		}

		LogTriggerHelper.runPostProcessingBatchInTest = true;

		Test.startTest();		
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();        
        createInboundEmailForFlow(email, env);

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
		
		Test.stopTest();
		Log__c log = [SELECT Slack_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Category__c = :FlowExceptionParser.FLOW_CATEGORY LIMIT 1];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, log.Notification_Integration_Status__c);
			System.assertNotEquals(null, log.Slack_Integration_Status__c);
		}
	}

	private static void createInboundEmailForFlow(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        List<string> emails = new List<string>{'testemail1@gmail.com','testemail1@gmail.com'};        
        email.subject = 'An error occurred with your "GovnopaketFlowContact1" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = String.valueOf(Test_LogService.getTestStub('FLOW_MULTI_SUBFLOWS_STACKTRACE')).replaceAll('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME);

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};
        
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new Test_StackTraceParser.YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_MULTI_SUBFLOWS_METADATA')));
	}

	@IsTest
	private static void test_mixed_rules_notifications_slack_and_ticketing() {
		Rule__c notifRule = createSlackNotificationRule();
		Rule__c jiraRule = createTicketingRule(true);
		PermissionsUtil.SlackIntegrationEnabled = true;
		PermissionsUtil.JiraIntegrationEnabled = true;
		TestDataFactory.enableMaxJiraRules();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());
		endpoint2TestResp.putAll(createJiraMocks());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.createSlackSettings();

		Test.startTest();
		Log__c log = TestDataFactory.createTestNotificationLog();
		
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);

		Test.stopTest();
		log = [SELECT Slack_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
		System.assertEquals(true, log.Executable_Rules__c.contains(notifRule.Id));
		System.assertEquals(true, log.Executable_Rules__c.contains(jiraRule.Id));
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_trace_result_notifications_slack_positive() {
		test_trace_result_notifications_slack(true);
	}
	@IsTest
	private static void test_trace_result_notifications_slack_negative() {
		test_trace_result_notifications_slack(false);
	}
	
	private static void test_trace_result_notifications_slack(Boolean positiveResult) {
		Rule__c testRule = createTraceResultSlackNotificationRule();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(positiveResult) {
			TestDataFactory.createSlackSettings();
		}

		Test.startTest();
		TestDataFactory.enableIssueTracking();
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Notification_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		Trace_Result__c traceResult = createTraceResult(issue.Id);
		enableDebugLogService();
		PermissionsUtil.DebugLogServiceEnabled = true;
		insert traceResult;

		Test.stopTest();
		traceResult = [SELECT Notification_Integration_Status__c FROM Trace_Result__c WHERE Id = :traceResult.Id];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, traceResult.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, traceResult.Notification_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_trace_result_notifications_teams_positive() {
		test_trace_result_notifications_teams(true);
	}
	@IsTest
	private static void test_trace_result_notifications_teams_negative() {
		test_trace_result_notifications_teams(false);
	}
	private static void test_trace_result_notifications_teams(Boolean positiveResult) {
		createIssueTeamsNotificationRule();
		createTraceResultTeamsNotificationRule();

		String endpoint = String.format(GraphAPIService.GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{'testTeamId', 'testChannelId'});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, positiveResult ? getTeamsSendMock(positiveResult) : null);
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(true));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		PermissionsUtil.TeamsIntegrationEnabled = true;
		TestDataFactory.createTeamsSettings();

		Test.startTest();
		TestDataFactory.enableIssueTracking();
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Notification_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		Trace_Result__c traceResult = createTraceResult(issue.Id);
		enableDebugLogService();
		PermissionsUtil.DebugLogServiceEnabled = true;
		insert traceResult;

		Test.stopTest();
		traceResult = [SELECT Id, Notification_Integration_Status__c FROM Trace_Result__c WHERE Id = :traceResult.Id];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, traceResult.Notification_Integration_Status__c);
			assertNoInternalLogs();
			assertRequestBodyHasWrappedLink(endpoint, multiCalloutMock, traceResult.Id);
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, traceResult.Notification_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_issue_notifications_slack_positive() {
		test_issue_notifications_slack(true, false, false);
	}
	@IsTest
	private static void test_issue_notifications_slack_negative() {
		test_issue_notifications_slack(false, false, false);
	}
	@IsTest
	private static void test_issue_notifications_slack_positive_batch() {
		test_issue_notifications_slack(true, false, true);
	}
	@IsTest
	private static void test_issue_notifications_slack_negative_batch() {
		test_issue_notifications_slack(false, false, true);
	}
	@IsTest
	private static void test_issue_notifications_slack_positive_on_update() {
		test_issue_notifications_slack(true, true, false);
	}
	@IsTest
	private static void test_issue_notifications_slack_negative_on_update() {
		test_issue_notifications_slack(false, true, false);
	}
	@IsTest
	private static void test_issue_notifications_slack_positive_on_update_batch() {
		test_issue_notifications_slack(true, true, true);
	}
	@IsTest
	private static void test_issue_notifications_slack_negative_on_update_batch() {
		test_issue_notifications_slack(false, true, true);
	}

	private static final String ISSUE_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_NEW_VALUE = 'Equal';
	private static final String ISSUE_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_OLD_VALUE = 'Not equal';
	private static final String ISSUE_NOTIFICATION_UPDATE_NEW_VALUE = '2';
	private static final String ISSUE_NOTIFICATION_UPDATE_OLD_VALUE = '1';
	private static final String ISSUE_NOTIFICATION_FIELD_NAME = Schema.SObjectType.Issue__c.fields.Log_Count__c.getName();

	private static void createRuleFilterOnUpdate(Rule__c testRule) {
		TestDataFactory.createRuleFilterOnUpdate(1, testRule, ISSUE_NOTIFICATION_UPDATE_COMPARISON_OPERATOR_NEW_VALUE, ISSUE_NOTIFICATION_UPDATE_NEW_VALUE, ISSUE_NOTIFICATION_FIELD_NAME, false);
	}

	private static void createPharosLog(Boolean isBatch) {
		TestDataFactory.enableIssueTracking();
		if (isBatch) {
			TestDataFactory.disableIssueTracking();
			PermissionsUtil.IssueTrackingEnabled = false;
		}
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;
		log = [SELECT Id, Type__c, Post_Processing_Status__c FROM Log__c WHERE Id = :log.Id];
		
		if (isBatch) {
			TestDataFactory.enableIssueTracking();
			PermissionsUtil.IssueTrackingEnabled = true;
			IssueTrackerBatch.getInstance().startBatch();
		}
	}

	private static void test_issue_notifications_slack(Boolean positiveResult, Boolean isUpdateCase, Boolean isBatch) {
		Rule__c testRule = createIssueSlackNotificationRule(isUpdateCase);

		if (isUpdateCase) createRuleFilterOnUpdate(testRule);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT, createSlackChannelsRequestMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if (positiveResult) {
			TestDataFactory.createSlackSettings();
		}

		Test.startTest();

		createPharosLog(isBatch);

		if (isUpdateCase) createPharosLog(isBatch);

		Test.stopTest();

		Issue__c issue = [SELECT Slack_Integration_Status__c, Notification_Integration_Status__c FROM Issue__c];
		if (positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, issue.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, issue.Notification_Integration_Status__c);
			System.assertNotEquals(null, issue.Slack_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_notifications_teams_positive() {
		test_notifications_teams(true);
	}
	@IsTest
	private static void test_notifications_teams_negative() {
		test_notifications_teams(false);
	}
	private static void test_notifications_teams(Boolean positiveResult) {
		createTeamsNotificationRule();

		String endpoint = String.format(GraphAPIService.GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{'testTeamId', 'testChannelId'});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, positiveResult ? getTeamsSendMock(positiveResult) : null);
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(true));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		PermissionsUtil.TeamsIntegrationEnabled = true;
		TestDataFactory.createTeamsSettings();

		Test.startTest();
		Log__c log = TestDataFactory.createTestNotificationLog();

		NotificationService.transactionIds = new Set<String>();
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);

		Test.stopTest();
		log = [SELECT Id, Teams_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
			assertNoInternalLogs();
			assertRequestBodyHasWrappedLink(endpoint, multiCalloutMock, log.Id);
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, log.Notification_Integration_Status__c);
			System.assertNotEquals(null, log.Teams_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_notifications_teams_by_flow_email_positive() {
		test_notifications_teams_by_flow_email(true);
	}
	@IsTest
	private static void test_notifications_teams_by_flow_email_negative() {
		test_notifications_teams_by_flow_email(false);
	}

	private static void test_notifications_teams_by_flow_email(Boolean positiveResult) {
		createTeamsNotificationRule();

		String endpoint = String.format(GraphAPIService.GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{'testTeamId', 'testChannelId'});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, positiveResult ? getTeamsSendMock(positiveResult) : null);
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(true));
		endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.DESCRIBE_SOBJECT_PATH, createDescribeSObjectMock());
		endpoint2TestResp.putAll(Test_StackTraceParser.createPostProcessingMock('accounttranfform1', 'testpharosx', 4));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		PermissionsUtil.TeamsIntegrationEnabled = true;
		TestDataFactory.createTeamsSettings();

		LogTriggerHelper.runPostProcessingBatchInTest = true;

		Test.startTest();		
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();        
        createInboundEmailForFlow(email, env);

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);

		Test.stopTest();
		Log__c log = [SELECT Id, Teams_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Category__c = :FlowExceptionParser.FLOW_CATEGORY LIMIT 1];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
			assertNoInternalLogs();
			assertRequestBodyHasWrappedLink(endpoint, multiCalloutMock, log.Id);
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, log.Notification_Integration_Status__c);
			System.assertNotEquals(null, log.Teams_Integration_Status__c);
		}
	}

	private static void assertRequestBodyHasWrappedLink(String endpoint, TestDataFactory.MultiRequestMock mockInstance, String recordId) {
		String linkFormat = '<a href=\"{0}\" target=\"_blank\">{0}</a>';
		String link = ConfigUtil.BASE_URL + '/' + recordId;
		String expectedValueLink = String.format(linkFormat, new List<String>{link}).escapeJava();
		HttpRequest sendRequest = mockInstance.getRequest(endpoint);
		String body = sendRequest.getBody();
		System.assertEquals(true, body.contains(expectedValueLink));
	}

	@IsTest
	private static void test_issue_notifications_teams_positive() {
		test_issue_notifications_teams(true, false, false);
	}
	@IsTest
	private static void test_issue_notifications_teams_negative() {
		test_issue_notifications_teams(false, false, false);
	}
	@IsTest
	private static void test_issue_notifications_teams_positive_batch() {
		test_issue_notifications_teams(true, false, true);
	}
	@IsTest
	private static void test_issue_notifications_teams_negative_batch() {
		test_issue_notifications_teams(false, false, true);
	}
	@IsTest
	private static void test_issue_notifications_teams_positive_on_update() {
		test_issue_notifications_teams(true, true, false);
	}
	@IsTest
	private static void test_issue_notifications_teams_negative_on_update() {
		test_issue_notifications_teams(false, true, false);
	}
	@IsTest
	private static void test_issue_notifications_teams_positive_on_update_batch() {
		test_issue_notifications_teams(true, true, true);
	}
	@IsTest
	private static void test_issue_notifications_teams_negative_on_update_batch() {
		test_issue_notifications_teams(false, true, true);
	}

	private static void test_issue_notifications_teams(Boolean positiveResult, Boolean isUpdateCase, Boolean isBatch) {
		Rule__c testRule = createIssueTeamsNotificationRule();

		if (isUpdateCase) createRuleFilterOnUpdate(testRule);

		String endpoint = String.format(GraphAPIService.GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{'testTeamId', 'testChannelId'});
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(endpoint, positiveResult ? getTeamsSendMock(positiveResult) : null);
		endpoint2TestResp.put(GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT, getOrganizationMock(true));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		PermissionsUtil.TeamsIntegrationEnabled = true;
		TestDataFactory.createTeamsSettings();

		Test.startTest();

		createPharosLog(isBatch);

		if (isUpdateCase) createPharosLog(isBatch);

		Test.stopTest();

		Issue__c issue = [SELECT Id, Teams_Integration_Status__c, Notification_Integration_Status__c FROM Issue__c];
		if (positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, issue.Notification_Integration_Status__c);
			assertNoInternalLogs();
			assertRequestBodyHasWrappedLink(endpoint, multiCalloutMock, issue.Id);
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, issue.Notification_Integration_Status__c);
			System.assertNotEquals(null, issue.Teams_Integration_Status__c);
		}
	}

	@IsTest
	private static void test_notifications_pagerDuty_incedent_positive() {
		test_notifications_pagerDuty(true, 'Incident');
	}
	@IsTest
	private static void test_notifications_pagerDuty_incedent_negative() {
		test_notifications_pagerDuty(false, 'Incident');
	}
	@IsTest
	private static void test_notifications_pagerDuty_event_positive() {
		test_notifications_pagerDuty(true, 'Event');
	}
	@IsTest
	private static void test_notifications_pagerDuty_event_negative() {
		test_notifications_pagerDuty(false, 'Event');
	}

	private static void test_notifications_pagerDuty(Boolean positiveResult, String pagerDutyType) {
		createPagerDutyNotificationRule(pagerDutyType);
		PermissionsUtil.PagerDutyIntegrationEnabled = true;
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_INCIDENT_ENDPOINT, createPagerDutyRequestIncidentMock());
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_EVENTS_ENDPOINT, createPagerDutyRequestEventsMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(positiveResult) {
			TestDataFactory.createPagerDutySettings();
		}

		Test.startTest();
		Log__c log = TestDataFactory.createTestNotificationLog();

		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);

		Test.stopTest();
		log = [SELECT PagerDuty_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		if(positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, log.Notification_Integration_Status__c);
			System.assertNotEquals(null, log.PagerDuty_Integration_Status__c);
		}

	}

	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_positive() {
		test_issue_notifications_pagerDuty(true, 'Incident', false, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_negative() {
		test_issue_notifications_pagerDuty(false, 'Incident', false, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_positive_batch() {
		test_issue_notifications_pagerDuty(true, 'Incident', false, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_negative_batch() {
		test_issue_notifications_pagerDuty(false, 'Incident', false, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_positive() {
		test_issue_notifications_pagerDuty(true, 'Event', false, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_negative() {
		test_issue_notifications_pagerDuty(false, 'Event', false, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_positive_batch() {
		test_issue_notifications_pagerDuty(true, 'Event', false, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_negative_batch() {
		test_issue_notifications_pagerDuty(false, 'Event', false, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_positive_on_update() {
		test_issue_notifications_pagerDuty(true, 'Incident', true, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_negative_on_update() {
		test_issue_notifications_pagerDuty(false, 'Incident', true, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_positive_on_update_batch() {
		test_issue_notifications_pagerDuty(true, 'Incident', true, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_incident_negative_on_update_batch() {
		test_issue_notifications_pagerDuty(false, 'Incident', true, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_positive_on_update() {
		test_issue_notifications_pagerDuty(true, 'Event', true, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_negative_on_update() {
		test_issue_notifications_pagerDuty(false, 'Event', true, false);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_positive_on_update_batch() {
		test_issue_notifications_pagerDuty(true, 'Event', true, true);
	}
	@IsTest
	private static void test_issue_notifications_pagerDuty_event_negative_on_update_batch() {
		test_issue_notifications_pagerDuty(false, 'Event', true, true);
	}
	private static void test_issue_notifications_pagerDuty(Boolean positiveResult, String pagerDutyType, Boolean isUpdateCase, Boolean isBatch) {
		Rule__c testRule = createIssuePagerDutyNotificationRule(pagerDutyType);

		if (isUpdateCase) createRuleFilterOnUpdate(testRule);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_INCIDENT_ENDPOINT, createPagerDutyRequestIncidentMock());
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_EVENTS_ENDPOINT, createPagerDutyRequestEventsMock());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		if(positiveResult) {
			TestDataFactory.createPagerDutySettings();
		}

		Test.startTest();

		createPharosLog(isBatch);

		if (isUpdateCase) createPharosLog(isBatch);

		Test.stopTest();

		Issue__c issue = [SELECT PagerDuty_Integration_Status__c, Notification_Integration_Status__c FROM Issue__c];
		if (positiveResult) {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, issue.Notification_Integration_Status__c);
			assertNoInternalLogs();
		}
		else {
			System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED, issue.Notification_Integration_Status__c);
			System.assertNotEquals(null, issue.PagerDuty_Integration_Status__c);
		}

	}

	@IsTest
	private static void test_notifications_email() {
		createEmailNotificationRule();

		Test.startTest();
		Log__c log = TestDataFactory.createTestNotificationLog();

		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);

		Test.stopTest();
		log = [SELECT Email_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
		System.assertEquals(null, log.Email_Integration_Status__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_notifications_email() {
		test_issue_notifications_email(false, false);
	}
	@IsTest
	private static void test_issue_notifications_email_batch() {
		test_issue_notifications_email(false, true);
	}

	@IsTest
	private static void test_issue_notifications_email_on_update() {
		test_issue_notifications_email(true, false);
	}
	@IsTest
	private static void test_issue_notifications_email_on_update_batch() {
		test_issue_notifications_email(true, true);
	}

	private static void test_issue_notifications_email(Boolean isUpdateCase, Boolean isBatch) {
		Rule__c testRule = createIssueEmailNotificationRule();

		if (isUpdateCase) createRuleFilterOnUpdate(testRule);

		Test.startTest();

		createPharosLog(isBatch);

		if (isUpdateCase) createPharosLog(isBatch);

		Test.stopTest();

		Issue__c issue = [SELECT Id, Email_Integration_Status__c, Notification_Integration_Status__c FROM Issue__c];

		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, issue.Notification_Integration_Status__c);
		System.assertEquals(null, issue.Email_Integration_Status__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_ticketing_comment_jira() {
		test_issue_ticketing_comment(true);
	}

	@IsTest
	private static void test_issue_ticketing_comment_azure_dev_ops() {
		test_issue_ticketing_comment(false);
	}

	private static void test_issue_ticketing_comment(Boolean isJira) {

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Rule__c testRule = createTicketingCommentRule(isJira, ConfigUtil.ISSUE_SOBJECT_NAME);

		createRuleFilterOnUpdate(testRule);

		Test.startTest();

		enableAzureDevOpsNotifications();
		TestDataFactory.enableMaxJiraRules();
		TestDataFactory.enableIssueTracking();
		PermissionsUtil.IssueNotificationsEnabled = true;
		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		PermissionsUtil.JiraIntegrationEnabled = true;
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
		issue.Jira_Integration_Status__c = ConfigUtil.NEW_TICKET_CREATED_STATUS;
		String bugTrackerLink = isJira 
			? ConfigUtil.JIRA_TASK_URL + JIRA_MOCK_NEW_TICKET_ID
			: String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		issue.Bug_Tracker__c = bugTrackerLink;
		update issue;

		NotificationService.transactionIds = new Set<String>();
		issue.Log_Count__c = Decimal.valueOf(ISSUE_NOTIFICATION_UPDATE_NEW_VALUE);
		update issue;
 
		Test.stopTest();
		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];

		String newTicketCommentEndpoint = isJira 
			? JiraService.getService().getCreateIssueCommentEndpoint(JIRA_MOCK_NEW_TICKET_ID)
			: String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		HttpRequest postRequest = multiCalloutMock.getRequest(newTicketCommentEndpoint);
		System.assertNotEquals(null, postRequest.getBody());
		System.assertNotEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(ConfigUtil.NEW_TICKET_CREATED_STATUS, issue.Jira_Integration_Status__c);
		assertNoInternalLogs();
	}

	private static void createTraceResultTeamsNotificationRule() {
		TestDataFactory.createNotificationRule(TestDataFactory.createTeamsAction(ConfigUtil.TRACE_RESULT_SOBJECT_NAME),ConfigUtil.TRACE_RESULT_SOBJECT_NAME, ConfigUtil.ISSUE_SOBJECT_NAME);
	}

	private static Rule__c createIssueTeamsNotificationRule() {
		return TestDataFactory.createNotificationRule(TestDataFactory.createTeamsAction(ConfigUtil.ISSUE_SOBJECT_NAME), ConfigUtil.ISSUE_SOBJECT_NAME);
	}

	private static void createTeamsNotificationRule() {
		TestDataFactory.createNotificationRule(TestDataFactory.createTeamsAction());
	}

	private static Rule__c createIssueSlackNotificationRule(Boolean isUpdateCase) {
		return TestDataFactory.createNotificationRule(TestDataFactory.createSlackAction(ConfigUtil.ISSUE_SOBJECT_NAME), ConfigUtil.ISSUE_SOBJECT_NAME, null, isUpdateCase);
	}

	private static Rule__c createTraceResultSlackNotificationRule() {
		return TestDataFactory.createNotificationRule(TestDataFactory.createSlackAction(ConfigUtil.TRACE_RESULT_SOBJECT_NAME),ConfigUtil.TRACE_RESULT_SOBJECT_NAME, ConfigUtil.ISSUE_SOBJECT_NAME);
	}

	private static Rule__c createTraceResultSlackNotificationRuleOnUpdate() {
		return TestDataFactory.createNotificationRule(TestDataFactory.createSlackAction(ConfigUtil.TRACE_RESULT_SOBJECT_NAME),ConfigUtil.TRACE_RESULT_SOBJECT_NAME, null);
	}

	private static Rule__c createSlackNotificationRule() {
		return TestDataFactory.createNotificationRule(TestDataFactory.createSlackAction());
	}

	private static Rule__c createIssueEmailNotificationRule() {
		return TestDataFactory.createNotificationRule(TestDataFactory.createEmailAction(ConfigUtil.ISSUE_SOBJECT_NAME), ConfigUtil.ISSUE_SOBJECT_NAME);
	}

	private static void createEmailNotificationRule() {
		TestDataFactory.createNotificationRule(TestDataFactory.createEmailAction());
	}

	private static Rule__c createIssuePagerDutyNotificationRule(String pagerDutyType) {
		return TestDataFactory.createNotificationRule(TestDataFactory.createPagerDutyAction(pagerDutyType, ConfigUtil.ISSUE_SOBJECT_NAME), ConfigUtil.ISSUE_SOBJECT_NAME);
	}

	private static Rule__c createPagerDutyNotificationRule(String pagerDutyType) {
		return TestDataFactory.createNotificationRule(TestDataFactory.createPagerDutyAction(pagerDutyType));
	}

	@IsTest
	private static void test_all_notifications_positive_with_jira() {
		test_all_notifications_positive(true);
	}

	@IsTest
	private static void test_all_notifications_positive_with_azure_dev_ops() {
		test_all_notifications_positive(false);
	}

	private static void test_all_notifications_positive(Boolean isJira) {
		createEmailNotificationRule();
		createPagerDutyNotificationRule('Event');
		createSlackNotificationRule();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_INCIDENT_ENDPOINT, createPagerDutyRequestIncidentMock());
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_EVENTS_ENDPOINT, createPagerDutyRequestEventsMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.createPagerDutySettings();
		TestDataFactory.createSlackSettings();

		createTicketingRule(isJira);

		Test.startTest();
		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			enableAzureDevOpsNotifications();
		}

		Log__c log = TestDataFactory.createTestNotificationLog();
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
		update log;

		log = [SELECT Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING, log.Notification_Integration_Status__c);

		Test.stopTest();
		log = [SELECT Email_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Id = :log.Id];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_all_notifications_positive_with_jira_by_flow_email() {
		test_all_notifications_positive_by_flow_email(true);
	}

	@IsTest
	private static void test_all_notifications_positive_with_azure_dev_ops_by_flow_email() {
		test_all_notifications_positive_by_flow_email(false);
	}

	private static void test_all_notifications_positive_by_flow_email(Boolean isJira) {
		createEmailNotificationRule();
		createPagerDutyNotificationRule('Event');
		createSlackNotificationRule();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_INCIDENT_ENDPOINT, createPagerDutyRequestIncidentMock());
		endpoint2TestResp.put(ConfigUtil.PAGER_DUTY_EVENTS_ENDPOINT, createPagerDutyRequestEventsMock());
		endpoint2TestResp.put(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT, createSlackRequestMock());
		endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.DESCRIBE_SOBJECT_PATH, createDescribeSObjectMock());
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		endpoint2TestResp.putAll(Test_StackTraceParser.createPostProcessingMock('accounttranfform1', 'testpharosx', 4));

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.createPagerDutySettings();
		TestDataFactory.createSlackSettings();

		createTicketingRule(isJira);

		LogTriggerHelper.runPostProcessingBatchInTest = true;

		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			enableAzureDevOpsNotifications();
		}

		Test.startTest();		
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();        
        createInboundEmailForFlow(email, env);

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);

		Test.stopTest();
		Log__c log = [SELECT Email_Integration_Status__c, Notification_Integration_Status__c FROM Log__c WHERE Category__c = :FlowExceptionParser.FLOW_CATEGORY LIMIT 1];
		System.assertEquals(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED, log.Notification_Integration_Status__c);
		assertNoInternalLogs();
	}


	@IsTest
	private static void test_azure_service_put_token() {
		String token = 'sometoken';
		String refreshToken = 'refreshToken';

		Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
		Test.startTest();
		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		enableAzureDevOpsNotifications();
		AzureService.putEncryptedAzureDevOpsTokenToCache(null, azureSettings, token);
		GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings(refreshToken, true, null);
		Test.stopTest();
		GraphAPIService.GRAPH_API_LIST_RECORDS = null;
		AzureService.OAUTH_API_TOKEN = null;
		AzureService.OAUTH_API_REFRESH_TOKEN = null;
		System.assertEquals(token, AzureService.OAUTH_API_TOKEN);
		System.assertEquals(refreshToken, AzureService.OAUTH_API_REFRESH_TOKEN);
	}

	@IsTest
	private static void test_related_closed_logs_by_hash1_with_jira() {
		test_related_closed_logs_by_hash1(true);
	}

	@IsTest
	private static void test_related_closed_logs_by_hash1_with_azure_dev_ops() {
		test_related_closed_logs_by_hash1(false);
	}


	private static void test_related_closed_logs_by_hash1(Boolean isJira) {
		Log__c log1 = new Log__c();
		log1.Hash_1__c = JIRA_MOCK_HASH1;
		log1.Hash_2__c = JIRA_MOCK_HASH2;
		log1.Hash_3__c = JIRA_MOCK_HASH3;
		log1.Bug_Tracker__c = ConfigUtil.JIRA_TASK_URL + 'TaskKey';
		log1.Organization_Id__c = UserInfo.getOrganizationId().left(15);
		log1.Resolved_On__c = Datetime.now().addDays(-1);
		insert log1;

		log1 = [SELECT Id, Resolved_On__c, Organization_Id__c, Bug_Tracker__c FROM Log__c WHERE Id = :log1.Id LIMIT 1];
		System.assertNotEquals(null, log1.Resolved_On__c);

		Log__c log2 = new Log__c();
		log2.Hash_1__c = JIRA_MOCK_HASH1;
		log2.Hash_2__c = JIRA_MOCK_HASH2;
		log2.Hash_3__c = JIRA_MOCK_HASH3;
		log2.Bug_Tracker__c = null;
		log2.Organization_Id__c = log1.Organization_Id__c;
		log2.Jira_Integration_Status__c = MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING;
		log2.Resolved_On__c = null;
		insert log2;

		log2 = [SELECT Id, Resolved_On__c, Organization_Id__c, Jira_Integration_Status__c FROM Log__c WHERE Id = :log2.Id LIMIT 1];
		System.assertEquals(MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING, log2.Jira_Integration_Status__c);

		createTicketingRule(isJira);

		Test.startTest();

		if(!isJira) {
			PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
			enableAzureDevOpsNotifications();
		}

		log2.Executable_Rules__c = JSON.serialize(new List<String>{[SELECT Id FROM Rule__c LIMIT 1].Id});
		update log2;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		
		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		JiraNotificationBatch.getInstance().startBatch();

		Test.stopTest();
		log2 = [SELECT Bug_Tracker__c FROM Log__c WHERE Id = :log2.Id LIMIT 1];
		System.assertNotEquals(log1.Bug_Tracker__c, log2.Bug_Tracker__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_IssueJiraTaskController_create_task_jira() {
		test_IssueJiraTaskController_create_task(true, false);
	}

	@IsTest
	private static void test_IssueJiraTaskController_create_task_azure_dev_ops() {
		test_IssueJiraTaskController_create_task(false, false);
	}

	@IsTest
	private static void test_IssueJiraTaskController_create_task_jira_custom_ui_endpoint() {
		test_IssueJiraTaskController_create_task(true, true);
	}

	private static void test_IssueJiraTaskController_create_task(Boolean isJira, Boolean isCustomJiraUiEndpoint){

		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;
		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Action__c testAction = getTicketingAction(isJira, ConfigUtil.ISSUE_SOBJECT_NAME);

		if(isCustomJiraUiEndpoint) {
			List<JiraService.JiraSettingsSObjectWrapper> records = new List<JiraService.JiraSettingsSObjectWrapper>{
				new JiraService.JiraSettingsSObjectWrapper('https://custom.jira.com')
			};
	
			JiraService.JIRA_SETTINGS_TEST_RECORDS = records;
		}

		Test.startTest();
		enableAzureDevOpsNotifications();
		TestDataFactory.enableIssueTracking();
		PermissionsUtil.IssueNotificationsEnabled = true;
		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		PermissionsUtil.JiraIntegrationEnabled = true;

		RuleUtil.Action action = new RuleUtil.Action(testAction);
		Map<String, Object> payload = new Map<String, Object>{
			'action' => action,
			'logId' => issue.Id
		};
		Integer queueBefore = Limits.getQueueableJobs();
		TicketingService.TicketCreateResult result = IssueJiraTaskController.createTask(payload);
		Test.stopTest();
		Integer queueAfter = Limits.getQueueableJobs();
		System.assertEquals(queueBefore, queueAfter);
		system.assertNotEquals(null, result.url);
		if(isCustomJiraUiEndpoint) {
			System.assertEquals('https://custom.jira.com/browse/test', result.url);
		}
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_notifications_ticketing_jira() {
		test_issue_notifications_ticketing(true);
	}

	@IsTest
	private static void test_issue_notifications_ticketing_azure_dev_ops() {
		test_issue_notifications_ticketing(false);
	}

	private static void test_issue_notifications_ticketing(Boolean isJira) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		endpoint2TestResp.putAll(createAzureDevOpsMocks());

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		createTicketingRule(isJira, ConfigUtil.ISSUE_SOBJECT_NAME);

		Test.startTest();

		enableAzureDevOpsNotifications();
		TestDataFactory.enableMaxJiraRules();
		TestDataFactory.enableIssueTracking();
		PermissionsUtil.IssueNotificationsEnabled = true;
		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		PermissionsUtil.JiraIntegrationEnabled = true;

		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		if(!isJira) {
			issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
			issue.Bug_Tracker__c = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
			issue.Jira_Integration_Status__c = MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING;
			update issue;
		}

		Test.stopTest();
		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		if(!isJira) {
			String newTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID});
			HttpRequest postRequest = multiCalloutMock.getRequest(newTicketEndpoint);
			AzureService.AzureDevOpsWorkItemRequestBody existTicketRelation = new AzureService.AzureDevOpsWorkItemRequestBody(
				AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_RELATIONS, new Map<String, Object>{
				'rel' => AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK,
				'url' => String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID})
			});

			System.assertEquals(true, postRequest.getBody().containsIgnoreCase(JSON.serialize(existTicketRelation)));

			String newAzureTicketUrl = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID});
			issue = [SELECT Jira_Integration_Status__c, Bug_Tracker__c FROM Issue__c WHERE Id = :issue.Id];
			System.assertEquals(newAzureTicketUrl, issue.Bug_Tracker__c);
		}
		System.assertNotEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(ConfigUtil.NEW_TICKET_CREATED_STATUS, issue.Jira_Integration_Status__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_ticketing_do_not_create_ticket_on_issue_update() {

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		System.assertEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(null, issue.Jira_Integration_Status__c);

		createTicketingRule(true, ConfigUtil.ISSUE_SOBJECT_NAME);

		Test.startTest();

		Log__c secondLog = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert secondLog;

		Test.stopTest();

		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];

		System.assertEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(null, issue.Jira_Integration_Status__c);
		List<Log__c> relatedLogs = [SELECT Id FROM Log__c WHERE Issue__c = :issue.Id LIMIT 2];
		System.assertEquals(2, relatedLogs.size());
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_ticketing_re_create_ticket_on_issue_update_status() {

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createJiraMocks());
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		TestDataFactory.enableMaxJiraRules();
		createTicketingRule(true, ConfigUtil.ISSUE_SOBJECT_NAME);

		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];

		issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
		issue.Resolved_On__c = DateTime.now();
		update issue;

		Test.startTest();

		Log__c secondLog = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert secondLog;

		Test.stopTest();

		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c,Regressed_On__c,Resolved_On__c FROM Issue__c WHERE Log__c = :log.Id];
		System.assertEquals(IssueService.ISSUE_STATUS_NEW, issue.Status__c);
		System.assertNotEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(ConfigUtil.NEW_TICKET_CREATED_STATUS, issue.Jira_Integration_Status__c);
		System.assertNotEquals(null, issue.Regressed_On__c);
		System.assertEquals(null, issue.Resolved_On__c);
		List<Log__c> relatedLogs = [SELECT Id FROM Log__c WHERE Issue__c = :issue.Id LIMIT 2];
		System.assertEquals(2, relatedLogs.size());
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_ticketing_not_re_create_ticket_on_sync_batch() {

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(JiraSyncBatchTest.getJiraTicketMocks());
		endpoint2TestResp.putAll(createJiraMocks());


		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		TestDataFactory.enableIssueTracking();
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c, Executable_Rules__c FROM Issue__c WHERE Log__c = :log.Id];

		Rule__c rule = createTicketingRule(true, ConfigUtil.ISSUE_SOBJECT_NAME);
		MonitoringUtil.cachedRules = new Map<String, Map<Id, MonitoringUtil.MonitoringRule>>();

		NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);
		config.a = new Set<String>{rule.Id};

		issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
		issue.Resolved_On__c = DateTime.now();
		issue.Executable_Rules__c = config.toJSON();
		issue.Bug_Tracker__c = JiraSyncBatchTest.JIRA_MOCK_TICKET_URL;
		update issue;

		Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
		jiraSettings.Jira_Base_Url__c = JiraSyncBatchTest.JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_API_Url__c = JiraSyncBatchTest.JIRA_MOCK_REST_ENDPOINT;
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		update jiraSettings;
		JiraSyncBatchTest.enableSyncCompletedStatus();

		ConfigUtil.JIRA_SETTINGS = null;

		Test.startTest();
		JiraSyncBatch.getInstance().startBatch();
		Test.stopTest();

		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c,Regressed_On__c,Resolved_On__c FROM Issue__c WHERE Log__c = :log.Id];
		System.assertEquals(IssueService.ISSUE_STATUS_COMPLETED, issue.Status__c);
		System.assertNotEquals(null, issue.Bug_Tracker__c);
		System.assertEquals(null, issue.Jira_Integration_Status__c);
		System.assertEquals(null, issue.Regressed_On__c);
		System.assertNotEquals(null, issue.Resolved_On__c);
		assertNoInternalLogs();
	}

	@IsTest
	private static void test_issue_notifications_ticketing_handle_azure_dev_ops_tag_permission() {

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String newTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID});
		endpoint2TestResp.put(newTicketEndpoint, createAzureDevOpsNewTicketMock());
		String existingTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		endpoint2TestResp.put(existingTicketEndpoint, createAzureDevOpsExistTicketMock());
		
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		multiCalloutMock.setEndpointError(newTicketEndpoint, TicketingService.AZURE_DEV_OPS_ERROR_CREATE_TAGS);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
		createTicketingRule(false, ConfigUtil.ISSUE_SOBJECT_NAME);

		Test.startTest();

		enableAzureDevOpsNotifications();
		TestDataFactory.enableMaxJiraRules();
		TestDataFactory.enableIssueTracking();
		PermissionsUtil.IssueNotificationsEnabled = true;
		PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
		Log__c log = IssueTriggerHandlerTest.createPharosLog('hash1', 'hash2', 'hash3');
		insert log;

		Issue__c issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
		issue.Bug_Tracker__c = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
		issue.Jira_Integration_Status__c = MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING;
		update issue;

		Test.stopTest();
		issue = [SELECT Id, Bug_Tracker__c, Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Log__c = :log.Id];
		
		HttpRequest postRequest = multiCalloutMock.getRequest(newTicketEndpoint);
		System.assertEquals(true, !postRequest.getBody().containsIgnoreCase(AzureService.WORK_ITEM_TYPE_FIELD_TAG));

		String newAzureTicketUrl = String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID});
		issue = [SELECT Jira_Integration_Status__c, Bug_Tracker__c FROM Issue__c WHERE Id = :issue.Id];
		System.assertEquals(newAzureTicketUrl, issue.Bug_Tracker__c);
		System.assertEquals(ConfigUtil.NEW_TICKET_CREATED_STATUS, issue.Jira_Integration_Status__c);
		assertNoInternalLogs();
	}

	private static Action__c getTicketingAction(Boolean isJira, String sobjectType) {
		Action__c rn1 = new Action__c();
		Id recordtypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RuleUtil.ACTION_RT_MONITORING).getRecordtypeId();
		rn1.RecordTypeId = recordtypeId;
		rn1.Description__c = isJira ? JIRA_MOCK_DESCRIPTION : AZURE_DEV_OPS_MOCK_DESCRIPTION;
		rn1.Subject__c = isJira ? JIRA_MOCK_SUBJECT : JIRA_MOCK_SUBJECT;
		rn1.Body__c = isJira ? JIRA_MOCK_BODY : AZURE_DEV_OPS_MOCK_BODY;
		rn1.JIRALabels__c = isJira ? JIRA_MOCK_LABELS : AZURE_DEV_OPS_MOCK_TAGS;
		rn1.JIRAComponents__c = isJira ? JIRA_MOCK_COMPONENTS : null;
		rn1.JIRAEpic__c = isJira ? JIRA_MOCK_EPICK_ID : AZURE_DEV_OPS_MOCK_EPICK_ID;
		rn1.JIRAPriority__c = isJira ? JIRA_MOCK_PRIORITY : AZURE_DEV_OPS_MOCK_PRIORITY;
		rn1.JIRAProject__c = isJira ? JIRA_MOCK_PROJECT_ID : AZURE_DEV_OPS_MOCK_PROJECT_ID;
		rn1.JIRAIssueType__c = isJira ? JIRA_MOCK_ISSUE_TYPE_ID : AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID;
		rn1.Action_Type__c = isJira ? RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION : RuleUtil.ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION;
		rn1.SobjectType__c = sobjectType;
		insert rn1;
		return rn1;
	}

	private static Action__c getTicketingCommentAction(Boolean isJira, String sobjectType) {
		Action__c rn1 = new Action__c();
		Id recordtypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RuleUtil.ACTION_RT_MONITORING).getRecordtypeId();
		rn1.RecordTypeId = recordtypeId;
		rn1.Description__c = isJira ? JIRA_MOCK_DESCRIPTION : AZURE_DEV_OPS_MOCK_DESCRIPTION;
		rn1.Subject__c = isJira ? JIRA_MOCK_SUBJECT : JIRA_MOCK_SUBJECT;
		rn1.Body__c = isJira ? JIRA_MOCK_BODY : AZURE_DEV_OPS_MOCK_BODY;
		rn1.JIRALabels__c = isJira ? JIRA_MOCK_LABELS : AZURE_DEV_OPS_MOCK_TAGS;
		rn1.JIRAComponents__c = isJira ? JIRA_MOCK_COMPONENTS : null;
		rn1.JIRAEpic__c = isJira ? JIRA_MOCK_EPICK_ID : AZURE_DEV_OPS_MOCK_EPICK_ID;
		rn1.JIRAPriority__c = isJira ? JIRA_MOCK_PRIORITY : AZURE_DEV_OPS_MOCK_PRIORITY;
		rn1.JIRAProject__c = isJira ? JIRA_MOCK_PROJECT_ID : AZURE_DEV_OPS_MOCK_PROJECT_ID;
		rn1.JIRAIssueType__c = isJira ? JIRA_MOCK_ISSUE_TYPE_ID : AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID;
		rn1.Action_Type__c = isJira ? RuleUtil.ACTION_TYPE_JIRA_TICKET_COMMENT : RuleUtil.ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT;
		rn1.SobjectType__c = sobjectType;
		rn1.Is_Update__c = true;
		insert rn1;
		return rn1;
	}

	private static Rule__c createTicketingRule(Boolean isJira) {
		return createTicketingRule(isJira, null);
	}

	private static Rule__c createTicketingRule(Boolean isJira, String sobjectType) {
		Rule__c mr1 = new Rule__c();
		mr1.Active__c = true;
		mr1.Type__c = isJira ? RuleUtil.RULE_TYPE_JIRA_UPDATE : RuleUtil.RULE_TYPE_AZURE_DEV_OPS;
		mr1.Index__c = 1;
		mr1.SobjectType__c = sobjectType;
		insert mr1;

		Action__c rn1 = getTicketingAction(isJira, sobjectType);

		RuleAction__c en1 = new RuleAction__c();
		en1.Action__c = rn1.Id;
		en1.Rule__c = mr1.Id;
		insert en1;

		return mr1;
	}

	private static Rule__c createTicketingCommentRule(Boolean isJira, String sobjectType) {
		Rule__c mr1 = new Rule__c();
		mr1.Active__c = true;
		mr1.Type__c = isJira ? RuleUtil.RULE_TYPE_JIRA_UPDATE : RuleUtil.RULE_TYPE_AZURE_DEV_OPS;
		mr1.Index__c = 1;
		mr1.SobjectType__c = sobjectType;
		mr1.Is_Update__c = true;
		insert mr1;

		Action__c rn1 = getTicketingCommentAction(isJira, sobjectType);

		RuleAction__c en1 = new RuleAction__c();
		en1.Action__c = rn1.Id;
		en1.Rule__c = mr1.Id;
		insert en1;

		return mr1;
	}

	public static final String JIRA_MOCK_REST_ENDPOINT = 'http://test.jira.com';
	public static final String JIRA_MOCK_REST_API = JIRA_MOCK_REST_ENDPOINT +'/rest/api/';
	public static final String JIRA_MOCK_NEW_TICKET_ID = 'test';
	public static final String JIRA_MOCK_NEW_TICKET_URL = 'test';
	public static final String JIRA_MOCK_PROJECT_ID = 'test';
	public static final String JIRA_MOCK_ISSUE_TYPE_ID = 'test';
	public static final String JIRA_MOCK_ISSUE_TYPE_NAME = 'bug';
	public static final String JIRA_MOCK_EPICK_ID = 'test';
	public static final String JIRA_MOCK_EPICK_NAME = 'Epic Link';
	public static final String JIRA_MOCK_SUBJECT = 'test';
	public static final String JIRA_MOCK_DESCRIPTION = 'test';
	public static final String JIRA_MOCK_BODY = 'test';
	public static final String JIRA_MOCK_LABELS = 'test';
	public static final String JIRA_MOCK_COMPONENTS = 'test';
	public static final String JIRA_MOCK_PRIORITY = '1';
	public static final String JIRA_MOCK_HASH1 = 'hash1';
	public static final String JIRA_MOCK_HASH2 = 'hash2';
	public static final String JIRA_MOCK_HASH3 = 'hash3';
	public static final String JIRA_MOCK_LABEL_HASH2 = 'h2_'+JIRA_MOCK_HASH2;
	public static final String JIRA_MOCK_LABEL_HASH3 = 'h3_'+JIRA_MOCK_HASH3;

	public static Map<String, HttpCalloutMock> createJiraMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(JiraService.getService().getProjectsEndpoint(), getProjectsMock());
		endpoint2TestResp.put(JiraService.getService().getProjectEndpoint(JIRA_MOCK_PROJECT_ID), getProjectMock());
		endpoint2TestResp.put(JiraService.getService().getProjectIssueTypesEndpoint(JIRA_MOCK_PROJECT_ID), getProjectIssueTypesMock());
		endpoint2TestResp.put(JiraService.getService().getProjectIssueFieldsEndpoint(JIRA_MOCK_PROJECT_ID, JIRA_MOCK_ISSUE_TYPE_ID), getProjectIssueFieldsMock());
		endpoint2TestResp.put(JiraService.getService().getCreateIssueEndpoint(), createJiraTicketResponseMock());
		endpoint2TestResp.put(JiraService.getService().getPutJiraTaskPropertiesEndpoint(JIRA_MOCK_NEW_TICKET_ID), createAddJiraPropertiesMock());
		endpoint2TestResp.put(JiraService.getService().getSearchIssueByLabelEndpoint(JIRA_MOCK_LABEL_HASH2, JIRA_MOCK_PROJECT_ID), createJQLSearchByHash2Mock());
		endpoint2TestResp.put(JiraService.getService().getSearchIssueByLabelEndpoint(JIRA_MOCK_LABEL_HASH3, JIRA_MOCK_PROJECT_ID), createJQLSearchByHash3Mock());
		endpoint2TestResp.put(JiraService.getService().getLinkIssuesEndpoint(), createRelatedTaskMock());
		endpoint2TestResp.put(JiraService.getService().getCreateIssueCommentEndpoint(JIRA_MOCK_NEW_TICKET_ID), createJiraTicketCommentMock());
		endpoint2TestResp.put(JiraService.getService().getPrioritySchemesEndpoint(), createPrioritySchemesMock());
		endpoint2TestResp.put(JiraService.getService().getPrioritiesEndpoint(), createPrioritiesMock());

		return endpoint2TestResp;
	}

	@TestVisible
	private static SingleRequestMock getProjectsMock() {
		List<JiraService.JiraProject> projects = new List<JiraService.JiraProject>();
		JiraService.JiraProject testProject = new JiraService.JiraProject();
		testProject.id = JIRA_MOCK_PROJECT_ID;
		testProject.key = JIRA_MOCK_PROJECT_ID;

		JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
		jiraField.required = false;
		jiraField.name = JIRA_MOCK_EPICK_NAME;
		jiraField.key = JIRA_MOCK_EPICK_ID;

		List<JiraService.JiraProjectIssueType> issueTypes = new List<JiraService.JiraProjectIssueType>();
		JiraService.JiraProjectIssueType testIssueType = new JiraService.JiraProjectIssueType();
		testIssueType.id = JIRA_MOCK_ISSUE_TYPE_ID;
		testIssueType.name = JIRA_MOCK_ISSUE_TYPE_NAME;
		testIssueType.fields = new Map<String, JiraService.JiraProjectIssueField>{JIRA_MOCK_ISSUE_TYPE_ID => jiraField};

		issueTypes.add(testIssueType);
		testProject.issueTypes = issueTypes;
		projects.add(testProject);

		SingleRequestMock getProjectsRespMock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(projects)
		);
		return getProjectsRespMock;
	}

	@TestVisible
	private static SingleRequestMock getProjectIssueFieldsMock() {
		JiraService.JiraSearchIssueTypeFieldsWrapper result = new JiraService.JiraSearchIssueTypeFieldsWrapper();

		JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
		jiraField.required = false;
		jiraField.name = JIRA_MOCK_EPICK_NAME;
		jiraField.key = JIRA_MOCK_EPICK_ID;

		result.values = new List<JiraService.JiraProjectIssueField>{jiraField};

		SingleRequestMock getProjectsRespMock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(result)
		);
		return getProjectsRespMock;
	}

	@Testvisible
	private static SingleRequestMock getProjectIssueTypesMock() {
		JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
		jiraField.required = false;
		jiraField.name = JIRA_MOCK_EPICK_NAME;
		jiraField.key = JIRA_MOCK_EPICK_ID;

		List<JiraService.JiraProjectIssueType> issueTypes = new List<JiraService.JiraProjectIssueType>();
		JiraService.JiraProjectIssueType testIssueType = new JiraService.JiraProjectIssueType();
		testIssueType.id = JIRA_MOCK_ISSUE_TYPE_ID;
		testIssueType.name = JIRA_MOCK_ISSUE_TYPE_NAME;
		testIssueType.fields = new Map<String, JiraService.JiraProjectIssueField>{JIRA_MOCK_ISSUE_TYPE_ID => jiraField};

		issueTypes.add(testIssueType);

		SingleRequestMock getProjectsRespMock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(issueTypes)
		);
		return getProjectsRespMock;
	}

	@TestVisible
	private static SingleRequestMock getProjectMock() {
		JiraService.JiraProject testProject = new JiraService.JiraProject();
		testProject.id = JIRA_MOCK_PROJECT_ID;
		testProject.key = JIRA_MOCK_PROJECT_ID;

		JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
		jiraField.required = false;
		jiraField.name = JIRA_MOCK_EPICK_NAME;
		jiraField.key = JIRA_MOCK_EPICK_ID;

		List<JiraService.JiraProjectIssueType> issueTypes = new List<JiraService.JiraProjectIssueType>();
		JiraService.JiraProjectIssueType testIssueType = new JiraService.JiraProjectIssueType();
		testIssueType.id = JIRA_MOCK_ISSUE_TYPE_ID;
		testIssueType.name = JIRA_MOCK_ISSUE_TYPE_NAME;
		testIssueType.fields = new Map<String, JiraService.JiraProjectIssueField>{JIRA_MOCK_ISSUE_TYPE_ID => jiraField};

		issueTypes.add(testIssueType);
		testProject.issueTypes = issueTypes;

		SingleRequestMock getProjectsRespMock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(testProject)
		);
		return getProjectsRespMock;
	}

	@TestVisible
	private static SingleRequestMock createAddJiraPropertiesMock() {
		SingleRequestMock addPropertiesMock = new SingleRequestMock(
			201,
			'OK',
			'{}'
		);
		return addPropertiesMock;
	}

	@TestVisible
	private static SingleRequestMock createJiraTicketResponseMock() {
		JiraService.NewTaskCreatedResponse createdResponse1 = new JiraService.NewTaskCreatedResponse();
		createdResponse1.id = JIRA_MOCK_NEW_TICKET_ID;
		createdResponse1.key = JIRA_MOCK_NEW_TICKET_ID;
		createdResponse1.self = JIRA_MOCK_NEW_TICKET_URL;

		SingleRequestMock createTaskResponse = new SingleRequestMock(
			201,
			'OK',
			JSON.serialize(createdResponse1)
		);
		return createTaskResponse;
	}

	@TestVisible
	private static SingleRequestMock createJQLSearchByHash2Mock() {
		JiraService.JQLResponse jqlSearchByHash2 = new JiraService.JQLResponse();
		jqlSearchByHash2.total = 0;

		SingleRequestMock searchHash2Mock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(jqlSearchByHash2)
		);
		return searchHash2Mock;
	}

	@TestVisible
	private static SingleRequestMock createJQLSearchByHash3Mock() {
		JiraService.JQLResponse jqlSearchByHash3 = new JiraService.JQLResponse();
		jqlSearchByHash3.total = 0;

		SingleRequestMock searchHash3Mock = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(jqlSearchByHash3)
		);
		return searchHash3Mock;
	}

	private static SingleRequestMock createAzureTicketCommentMock() {
		SingleRequestMock createTicketCommentMock = new SingleRequestMock(
			200,
			'OK',
			'{}'
		);
		return createTicketCommentMock;
	}

	private static SingleRequestMock createJiraTicketCommentMock() {
		SingleRequestMock createTicketCommentMock = new SingleRequestMock(
			201,
			'OK',
			'{}'
		);
		return createTicketCommentMock;
	}

	@TestVisible
	private static SingleRequestMock createPrioritiesMock() {
		List<JiraService.JiraPriority> jiraPriorities = new List<JiraService.JiraPriority>();
		JiraService.JiraPriority priority1 = new JiraService.JiraPriority();
		priority1.id = '1';
		priority1.name = 'Higest';
		jiraPriorities.add(priority1);

		SingleRequestMock prioritySchemes = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(jiraPriorities)
		);
		return prioritySchemes;
	}

	@TestVisible
	private static SingleRequestMock createPrioritySchemesMock() {
		JiraService.JiraPrioritySchemeWrapper wrap = new JiraService.JiraPrioritySchemeWrapper();
		JiraService.JiraPriorityScheme scheme1 = new JiraService.JiraPriorityScheme();
		scheme1.description = 'description';
		scheme1.id = '1';
		scheme1.name = 'scheme1';
		scheme1.optionIds = new List<String>{'1','2','3','4','5'};
		scheme1.projectKeys = new List<String>{'Test'};

		wrap.schemes = new List<JiraService.JiraPriorityScheme>{scheme1};

		SingleRequestMock prioritySchemes = new SingleRequestMock(
			200,
			'OK',
			JSON.serialize(wrap)
		);
		return prioritySchemes;
	}

	@TestVisible
	private static SingleRequestMock createRelatedTaskMock() {
		SingleRequestMock createRelatedTaskMock = new SingleRequestMock(
			201,
			'OK',
			'{}'
		);
		return createRelatedTaskMock;
	}

	private static TestDataFactory.SingleRequestMock getTeamsSendMock(Boolean positiveResult) {
		GraphAPIService.ChatMessage wrapper = new GraphAPIService.ChatMessage('testTeamId', 'testChannelId');
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				positiveResult ? 201 : 500,
				'OK',
				JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getOrganizationMock(Boolean isValidRequest) {
		GraphAPIService.OrganizationWrapper wrapper = new GraphAPIService.OrganizationWrapper();
		wrapper.value = new List<GraphAPIService.Organization>{
			new GraphAPIService.Organization('testTenantId')
		};
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			isValidRequest ? 200 : 400,
			'OK',
			JSON.serialize(wrapper)
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock createSlackRequestMock() {
		TestDataFactory.SingleRequestMock slackRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			'{}'
		);
		return slackRequestMock;
	}

	private static TestDataFactory.SingleRequestMock createSlackChannelsRequestMock() {
		TestDataFactory.SingleRequestMock slackRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
				'{"ok":true, "channels":[{"id":"@test"}]}'
		);
		return slackRequestMock;
	}

	private static TestDataFactory.SingleRequestMock createPagerDutyRequestIncidentMock() {
		TestDataFactory.SingleRequestMock slackRequestMock = new TestDataFactory.SingleRequestMock(
			201,
			'OK',
			'{}'
		);
		return slackRequestMock;
	}

	private static TestDataFactory.SingleRequestMock createPagerDutyRequestEventsMock() {
		TestDataFactory.SingleRequestMock slackRequestMock = new TestDataFactory.SingleRequestMock(
			202,
			'OK',
			'{}'
		);
		return slackRequestMock;
	}

	private static TestDataFactory.SingleRequestMock createDescribeSObjectMock() {
		List<LogPostProcessingService.SObjectDescribeInfo> sObjectDescribeInfos = new List<LogPostProcessingService.SObjectDescribeInfo>();
		LogPostProcessingService.SObjectDescribeInfo sObjectDescribeInfo = new LogPostProcessingService.SObjectDescribeInfo('Account', 'Account');
		sObjectDescribeInfo.keyPrefix = '001';
		sObjectDescribeInfo.name = 'Account';
		sObjectDescribeInfos.add(sObjectDescribeInfo);
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                'sobjects' => sObjectDescribeInfos
            })
        );
		return singleRequestMock;
	}

	public class MultiRequestMock implements HttpCalloutMock {
		Map<String, HttpCalloutMock> requests;

		public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
			this.requests = requests;
		}

		public HTTPResponse respond(HTTPRequest req) {
			HttpCalloutMock mock = requests.get(req.getEndpoint());
			if (mock != null) {
				return mock.respond(req);
			}
			else {
				throw new MultiRequestMockException('HTTP callout not supported for test methods');
			}
		}

		public void addRequestMock(String url, HttpCalloutMock mock) {
			requests.put(url, mock);
		}
	}

	public class MultiRequestMockException extends Exception {}

	public class SingleRequestMock implements HttpCalloutMock {

		protected Integer code;
		protected String status;
		protected String body;
		protected String reqBody;

		public SingleRequestMock(Integer code, String status, String body) {
			this.code = code;
			this.status = status;
			this.body = body;
		}

		public HTTPResponse respond(HTTPRequest req) {

			HttpResponse res = new HttpResponse();
			res.setBody(this.body);
			res.setStatusCode(this.code);
			res.setStatus(this.status);
			this.reqBody = req.getBody();
			return res;
		}

		public String getBodyRequest() {
			return this.reqBody;
		}
	}

	@IsTest
	private static void test_render_merge_fields() {
		List<String> mergedMessages;
		String subject = AdminService.DEFAULT_JIRA_ACTION_TEMPLATE.get('subject');
		String body = AdminService.DEFAULT_JIRA_ACTION_TEMPLATE.get('body');

		String relationsBody = String.format(
			'Issue: \'{!\'{0}.{1}.{2}\'}\'',
			new List<String> {
				Schema.SObjectType.Log__c.getName(),
				Schema.SObjectType.Log__c.fields.Issue__c.getRelationshipName(),
				Schema.SObjectType.Issue__c.fields.Status__c.getName()
			}
		);
		body = body + relationsBody;

		Issue__c issue = new Issue__c();
        issue.Status__c = 'New';
        issue.Key__c = 'somehash1';
        insert issue;

		Log__c log = new Log__c();
		log.Summary__c = 'someSummaryText';
        log.Category__c = 'TestCategory';
        log.Type__c = 'TestType' ;
        log.Area__c = 'Apex';
        log.Details__c = 'TestDetails';
        log.User_Id__c = 'TestUserId';
        log.Related_Id__c = 'TestRelatedId';
        log.Issue__c = issue.Id;
        log.Hash_1__c = 'somehash1';
		insert log;

		issue.Log__c = log.Id;
        update issue;

		Test.startTest();
		mergedMessages = NotificationService.renderMergeFields(log.Id, new List<String>{subject, body}, new NotificationService.MergeFieldSettings(RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION));
		Test.stopTest();

		System.assertNotEquals(null, mergedMessages);
		System.assertEquals(2, mergedMessages.size());
		System.assertEquals(true, mergedMessages.get(0).contains('someSummaryText'));
		System.assertEquals(true, mergedMessages.get(1).contains(log.Id));
		System.assertEquals(true, mergedMessages.get(1).contains('Category: TestCategory'));
		System.assertEquals(true, mergedMessages.get(1).contains('Issue: New'));
		System.assertEquals(true, mergedMessages.get(1).contains('Type: TestType'));
		System.assertEquals(true, mergedMessages.get(1).contains('Area: Apex'));
		System.assertEquals(true, mergedMessages.get(1).contains('TestDetails'));
	}

	private static void assertNoInternalLogs() {
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Category__c = :Logger.CATEGORY_PHAROS_ERROR AND Area__c = :Logger.AREA_PHAROS_ERROR LIMIT 1];
		System.assertEquals(0, logs.size());
	}
}