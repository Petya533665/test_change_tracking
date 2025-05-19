@IsTest
private class TestDataGeneratorTest {

	@TestSetup
	private static void testSetup() {
		Slack_Settings__c slackSettings = new Slack_Settings__c(
			Slack_Enabled__c = true,
			Slack_API_Token__c = '123321'
		);
		insert slackSettings;

		Jira_Settings__c jiraSettings = new Jira_Settings__c();
		jiraSettings.Jira_Base_Url__c = 'http://test.jira.com';
		jiraSettings.Jira_Username__c = 'jirausername';
		jiraSettings.Jira_API_Token__c = 'sometoken';
		insert jiraSettings;

		Jira_Fields_Mapping__c jiraMappings = new Jira_Fields_Mapping__c();
		jiraMappings.Name = ConfigUtil.generateUUID4();
		jiraMappings.Log_Field__c = 'Id';
		jiraMappings.Jira_Field__c = 'Id';
		jiraMappings.Project_Id__c = 'Id';
		jiraMappings.Issue_Type_Id__c = '10001';
		insert jiraMappings;

		Splunk_Fields__c splunkFields = new Splunk_Fields__c();
		splunkFields.Name = 'Id';
		splunkFields.Field_Name__c = 'Id';
		insert splunkFields;

		Test_LogService.initSettings();

	}

	@IsTest
	static void connectedAppSendMeAnEmail() {
		Test.startTest();
		TestDataGenerator.connectedAppSendMeAnEmail();
		Test.stopTest();
	}

	@IsTest
	static void startTestExceptionEmail() {
		Test.startTest();
		try {
			TestDataGenerator.sendTestEmailException();
		}
		catch(Exception e){}
		Test.stopTest();

		TestDataGenerator.getTestEmailExceptionLog();
	}

	@IsTest
	static void sendConnectedAppReadyEmail() {
		createTestEmailTemplate(TestDataGenerator.CONNECTED_APP_READY_EMAIL_TEMPLATE_NAME);
		Test.startTest();
		TestDataGenerator.sendConnectedAppReadyEmail(UserInfo.getUserId());
		Test.stopTest();
	}

	private static void createTestEmailTemplate(String templateName) {
		EmailTemplate validEmailTemplate = new EmailTemplate();
		validEmailTemplate.isActive = true;
		validEmailTemplate.Name = templateName;
		validEmailTemplate.DeveloperName = templateName;
		validEmailTemplate.TemplateType = 'text';
		validEmailTemplate.Subject = 'test subject';
		validEmailTemplate.Body = 'some test body <link>';
		validEmailTemplate.FolderId = UserInfo.getUserId();

		insert validEmailTemplate;
	}

	@IsTest
	static void testDataGeneratorSchedulerConnectedApp() {
		Test.startTest();
		TestDataGenerator.CURRENT_CONNECTED_ORG_TITLE = Test_LogService.CONNECETED_ORG_NAME;
		Map<String, Object> input = new Map<String, Object>();
		input.put(TestDataGenerator.TEST_EMAIL_SERVICE_KEY_USER, UserInfo.getUserId());
		String cronExp = TestDataGenerator.getNextFireTime(Datetime.now().addMinutes(10));
		String jobId = System.schedule('testDataGeneratorSchedulerConnectedApp',
			cronExp,
			new TestDataGeneratorScheduler(TestDataGeneratorScheduler.MODE.CHECK_COMPLETE_SETUP_CONNECTED_APP_AND_SEND_EMAIL, JSON.serialize(input)));
		Test.stopTest();
	}

	private static void mockPostProcessingRequests() {
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
			LogPostProcessingService.PAGE_MONITOR_DEPLOYMENT_STATUS_DEPLOYMENT
		);

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(System.Url.getOrgDomainUrl().toExternalForm() + '/services/oauth2/token', getOAuthToken);
		endpoint2TestResp.put(System.Url.getOrgDomainUrl().toExternalForm() + LogPostProcessingService.PAGE_MONITOR_DEPLOYMENT_URL, monitorDeployments);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	@IsTest
	private static void test_parse_rfc2822_date_time() {
		Messaging.inboundEmail im = new Messaging.inboundEmail();
		im.headers = new List<Messaging.InboundEmail.Header>();
		Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
		dateHeader.value = 'Wed, 12 Jul 2023 19:58:02 +0000 (GMT)';
		dateHeader.name = 'Date';
		im.headers.add(dateHeader);

		DateTime parsedDateTime = ConfigUtil.getDateTimeFromEmailHeader(im);
    	system.assertNotEquals(null, parsedDateTime);
	} 
}