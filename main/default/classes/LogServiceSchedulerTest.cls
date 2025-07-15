@IsTest
private class LogServiceSchedulerTest {

	@TestSetup
	private static void testSetup() {
		ConfigUtil.SETTINGS.Service_Scheduler_Enabled__c = true;
		ConfigUtil.SETTINGS.Archival_Enabled__c = true;
		upsert ConfigUtil.SETTINGS;
	}

	@IsTest
	private static void test_LogServiceScheduler() {
		LogServiceScheduler.rescheduleCronTriggers();

		System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_1_NAME]);
		System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_2_NAME]);
	}

	@IsTest
	private static void test_startJobsMode1() {
		Test.startTest();
		test_startJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_1);
		System.assertEquals(DatabaseUtils.startJobs, new Set<String>{
				'LogServiceBatch',
				'ManageTokensBatch',
				'EventLogProcessingBatch',
				'RetentionBatch',
				'MonitoringBatch',
				'JiraNotificationBatch',
				'IssueNotificationBatch',
				'TraceResultNotificationBatch',
				'BroadcastBatch',
				'JobBatch',
				'GitHubCommitBatch',
				'IssueTrackerBatch',
				'JiraSyncBatch',
				'TraceService'
		});
		Test.stopTest();
	}

	@IsTest
	private static void test_startJobsMode2() {
		Test.startTest();
		test_startJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_2);
		System.assertEquals(DatabaseUtils.startJobs, new Set<String>{
				'ManageTokensBatch',
				'LogPostProcessingBatch',
				'ErrorEmailReportBatch',
				'JiraResolutionBatch',
				'MetricsBatch',
				'IssueAverageFrequencyBatch',
				'TraceService',
				'BulkAPIJobBatchScheduler',
				'TraceBatch'
		});
		Test.stopTest();
	}

	private static void test_startJobs(LogServiceScheduler.SCHEDULER_MODE schedulerMode) {
		DatabaseUtils.TEST_MODE = true;
		LogServiceScheduler logServiceScheduler = new LogServiceScheduler(schedulerMode);
		logServiceScheduler.execute(null);
	}

	@IsTest
	private static void test_queueJobsMode1() {
		test_queueJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_1);

		System.assertEquals(4, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL]);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'LogServiceBatch']);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'ManageTokensBatch']);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'RetentionBatch']);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'ArchivalBatch']);
		System.assertEquals(3, [SELECT COUNT() FROM Log__c WHERE Category__c = 'TestCategory']);
	}

	@IsTest
	private static void test_queueJobsMode2() {
		test_queueJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_2);

		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL]);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'ManageTokensBatch']);
	}

	private static void test_queueJobs(LogServiceScheduler.SCHEDULER_MODE schedulerMode) {
		initData_LogServiceBatch();
		initData_ManageTokensBatch();
		initData_RetentionBatch();
		TestDataFactory.enableMaxArchivalRules();

		System.assertEquals(4, [SELECT COUNT() FROM Log__c WHERE Category__c = 'TestCategory']);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT, refreshTokenMock());
		endpoint2TestResp.put(JiraService.JIRA_CLOUD_OAUTH_ENDPOINT, createJiraRefreshRequestMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		LogServiceScheduler logServiceScheduler = new LogServiceScheduler(schedulerMode);
		logServiceScheduler.execute(null);
		Test.stopTest();
	}

	// LogServiceBatch

	private static void initData_LogServiceBatch() {
		TestDataFactory.createConnectedOrgSettings();
		TestDataFactory.createConnectedOrg();
	}

	private static TestDataFactory.SingleRequestMock refreshTokenMock() {
		ConnectedOrgService.AuthTokenResponse authTokenResponse = new ConnectedOrgService.AuthTokenResponse();
		authTokenResponse.access_token = 'test_new_Access_Token';
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				JSON.serialize(authTokenResponse)
		);
		return singleRequestMock;
	}

	// ManageTokensBatch

	private static final String TEST_JIRA_API_URL = 'https://somejiraapiurl.com';
	private static final String TEST_JIRA_BASE_URL = 'https://somejiraapiurl.com/jirasiteid';
	private static final String TEST_JIRA_API_ACCESS_TOKEN_BEFORE = 'sometoken1';
	private static final String TEST_JIRA_API_REFRESH_TOKEN_BEFORE = 'somerefreshtoken1';
	private static final String TEST_JIRA_API_ACCESS_TOKEN_AFTER = 'sometoken2';
	private static final String TEST_JIRA_API_REFRESH_TOKEN_AFTER = 'somerefreshtoken2';
	private static final String TEST_JIRA_API_USERNAME = JiraService.JIRA_CLOUD_OAUTH_USERNAME;

	private static void initData_ManageTokensBatch() {
		ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c = TEST_JIRA_API_URL;
		ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = TEST_JIRA_BASE_URL;
		ConfigUtil.JIRA_SETTINGS.Jira_Username__c = TEST_JIRA_API_USERNAME;
		upsert ConfigUtil.JIRA_SETTINGS;
		JiraService.putApiTokenToSettings(TEST_JIRA_API_ACCESS_TOKEN_BEFORE, true, null);
		JiraService.putApiRefreshTokenToSettings(TEST_JIRA_API_REFRESH_TOKEN_BEFORE, true, null);
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

	// RetentionBatch

	private static void initData_RetentionBatch() {
		Rule__c mr1 = new Rule__c();
		mr1.Active__c = true;
		mr1.Type__c = MonitoringUtil.RULE_TYPE_ARCHIVAL;
		mr1.EventTimeInterval__c = 1*60;
		insert mr1;

		Id recordtypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(MonitoringUtil.RULE_TYPE_ARCHIVAL).getRecordTypeId();

		Action__c rn1 = new Action__c();
		rn1.RecordTypeId = recordtypeId;
		rn1.Description__c = 'test';
		rn1.Subject__c = 'test';
		rn1.Body__c = 'test';
		rn1.EmailBody__c = 'test';
		rn1.SlackChannels__c = 'test';
		rn1.EmailTo__c = 'test@test.cc';
		rn1.EmailCC__c = 'test2@test.cc';
		rn1.JIRALabels__c = 'test';
		rn1.JIRAComponents__c = 'test';
		rn1.JIRAEpic__c = 'test';
		rn1.JIRAPriority__c = 'test';
		rn1.JIRAProject__c = 'test';
		rn1.JIRAIssueType__c = 'test';
		rn1.Action_Type__c = MonitoringUtil.ACTION_TYPE_REMOVAL;
		insert rn1;

		RuleAction__c en1 = new RuleAction__c();
		en1.Action__c = rn1.Id;
		en1.Rule__c = mr1.Id;
		insert en1;

		RuleFilter__c rf1 = new RuleFilter__c();
		rf1.Index__c = 1;
		rf1.Rule__c = mr1.Id;
		rf1.ComparisonOperator__c = 'Greater than';
		rf1.FieldName__c = 'Created_At__c';
		rf1.Value__c = '13600';
		rf1.Comparison_Type__c = 'Value';
		insert rf1;

		Log__c log = new Log__c();
		log.Category__c = 'TestCategory';
		log.Type__c = 'TestType' ;
		log.Area__c = 'Apex';
		log.Details__c = 'pass pass pass pass pass pass pass';

		Datetime dtnow = Datetime.now();
		Datetime currentTime = Datetime.newInstance(dtnow.year(), dtnow.month(), dtnow.day(), dtnow.hour(), dtnow.minute(), dtnow.second());
		Datetime time_2h_ago = currentTime.addHours(-2);
		Datetime time_3h_ago = currentTime.addHours(-3);
		Datetime time_6h_ago = currentTime.addHours(-6);

		Log__c log_2h_ago = log.clone(); log_2h_ago.Created_At__c = time_2h_ago;
		Log__c log_3h_ago = log.clone(); log_3h_ago.Created_At__c = time_3h_ago;
		Log__c log_6h_ago = log.clone(); log_6h_ago.Created_At__c = time_6h_ago;
		List<Log__c> allLogs = new List<Log__c>{log, log_2h_ago, log_3h_ago, log_6h_ago};
		insert allLogs;

		List<Inbound_Email__c> logEmails = new List<Inbound_Email__c>();
		for (Log__c logIterator : allLogs) {
			logEmails.add(createInboundEmail(logIterator.Id));
		}
		insert logEmails;

		Event__c lastEvent = new Event__c();
		lastEvent.RecordCount__c = 1;
		lastEvent.Rule__c = mr1.Id;
		insert lastEvent;
		Test.setCreatedDate(lastEvent.Id, currentTime.addMinutes(-2*60));

	}

	public static final String INBOUND_EMAIL_SUBJECT = 'Subject';
	public static final String INBOUND_EMAIL_PLAIN_TEXT = 'Please review error';
	public static final String INBOUND_EMAIL_FROM = 'erroruser@somedomain.com';

	private static Inbound_Email__c createInboundEmail(Id logId) {
		Inbound_Email__c inboundEmail = new Inbound_Email__c();
		inboundEmail.Subject__c = INBOUND_EMAIL_SUBJECT;
		inboundEmail.Plain_Text__c = INBOUND_EMAIL_PLAIN_TEXT;
		inboundEmail.From__c = INBOUND_EMAIL_FROM;
		return inboundEmail;
	}

	@IsTest
	private static void test_scopeJobsMode1_BroadcastBatch() {
		initData_LogServiceBatch();

		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
		corg.Data_Direction__c = 'sendTo';
		update corg;

		Log__c log = new Log__c();
		log.Hash_1__c = 'hash1';
		log.Category__c = 'Other';
		log.Type__c = 'Custom';
		log.Broadcast_Status__c = BroadcastService.BROADCAST_STATUS_NEEDED;
		log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
		insert log;

		String query = new QBuilder(Log__c.SObjectType)
				.selectFields(new Set<String>{'FIELDS(ALL)'})
				.add(QBuilder.condition(Log__c.Broadcast_Status__c.getDescribe().getName()).equalsTo(BroadcastService.BROADCAST_STATUS_NEEDED))
				.add(QBuilder.condition(Log__c.Originated_From__c.getDescribe().getName()).isNull())
				.addLimit(BroadcastService.queryLimit)
				.build();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT, refreshTokenMock());
		endpoint2TestResp.put(Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"records":[{"attributes":{"type":"Log__c"},"Id":"' + log.Id + '","' + Log__c.Type__c.getDescribe().getName() + '":"Test"}]}'
		));
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?' + ConfigUtil.PARAMS_TYPE + '=' + ConfigUtil.TYPE_BROADCAST, sendLogMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		test_scopeJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_1);

		System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL]);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'LogServiceBatch']);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'BroadcastBatch']);
	}

	private static TestDataFactory.SingleRequestMock sendLogMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'Done'
		);
		return singleRequestMock;
	}

	@IsTest
	private static void test_scopeJobsMode2_LogPostProcessingBatch() {
		Log__c log = new Log__c();
		log.Hash_1__c = 'hash1';
		log.Category__c = 'Other';
		log.Type__c = 'Custom';
		log.Post_Processing_Settings__c = '["UI"]';
		log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED;
		log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
		insert log;

		test_scopeJobs(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_2);

		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL]);
		System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ParentJobId = NULL AND ApexClass.Name = 'LogPostProcessingBatch']);
	}

	private static void test_scopeJobs(LogServiceScheduler.SCHEDULER_MODE schedulerMode) {
		Test.startTest();
		LogServiceScheduler logServiceScheduler = new LogServiceScheduler(schedulerMode);
		logServiceScheduler.execute(null);
		Test.stopTest();
	}

}