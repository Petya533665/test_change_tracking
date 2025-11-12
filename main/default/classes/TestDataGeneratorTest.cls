@IsTest
private class TestDataGeneratorTest {

	private static final String KEY_MAIN_LOG = 'mainLog';
	private static final String KEY_RELATED_ERROR = 'relatedError';

	@TestSetup
	private static void testSetup() {
		Test_LogService.initSettings();
	}

	// ============================================
	// Test Connected App Email Methods
	// ============================================

	@IsTest
	static void test_connectedAppSendMeAnEmail_withoutConnectedAppCreatedAt() {
		Connected_Orgs_Settings__c connectedOrgsSettings = Connected_Orgs_Settings__c.getOrgDefaults();
		connectedOrgsSettings.Connected_App_Created_At__c = null;
		upsert connectedOrgsSettings;

		Test.startTest();
			Boolean result = (Boolean) TestDataGenerator.connectedAppSendMeAnEmail();
		Test.stopTest();

		Assert.isFalse(result, 'Should return false when Connected_App_Created_At__c is null');
	}

	@IsTest
	static void test_connectedAppSendMeAnEmail_withReadyEmail() {
		// To avoid mixed dml operation
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(currentUser) {
			createEmailTemplate(TestDataGenerator.CONNECTED_APP_READY_EMAIL_TEMPLATE_NAME);
		}

		Connected_Orgs_Settings__c connectedOrgsSettings = ConfigUtil.CONNECTED_ORGS_SETTINGS;
		connectedOrgsSettings.Connected_App_Created_At__c = Datetime.now().addMinutes(-15);
		upsert connectedOrgsSettings;

		Test.startTest();
		Boolean result = (Boolean) TestDataGenerator.connectedAppSendMeAnEmail();
		Test.stopTest();

		Assert.isTrue(result, 'Should return true when email is sent');
	}

	@IsTest
	static void test_connectedAppSendMeAnEmail_withScheduledJob() {
		Connected_Orgs_Settings__c connectedOrgsSettings = ConfigUtil.CONNECTED_ORGS_SETTINGS;
		connectedOrgsSettings.Connected_App_Created_At__c = Datetime.now().addMinutes(5);
		upsert connectedOrgsSettings;

		Test.startTest();
			Boolean result = (Boolean) TestDataGenerator.connectedAppSendMeAnEmail();
		Test.stopTest();

		Assert.isTrue(result, 'Should return true when job is scheduled');
	}

	// ============================================
	// Test Platform Event Methods
	// ============================================

	@IsTest
	static void test_startPlatformEventTest() {
		Map<String, Id> logIds = createPlatformEventTestLogs();

		Test.startTest();
		Boolean result = (Boolean) TestDataGenerator.startPlatformEventTest();
		Test.stopTest();

		Assert.isTrue(result, 'Should return true when platform event is created');
		
		List<Log__c> logs = [
			SELECT Id, Hash_1__c, Summary__c
			FROM Log__c
			WHERE Hash_1__c = :TestDataGenerator.TEST_PLATFORM_EVENT_LOG_HASH1
		];
		Assert.areEqual(1, logs.size(), 'Should create one log record');
		Assert.areEqual(TestDataGenerator.TEST_PLATFORM_EVENT_LOG_SUMMARY, logs[0].Summary__c, 'Log summary should match');
		
		// Verify old logs were deleted
		List<Log__c> deletedLogs = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_MAIN_LOG)];
		Assert.areEqual(0, deletedLogs.size(), 'Old log should be deleted');
		
		List<Log__c> deletedRelatedErrors = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_RELATED_ERROR)];
		Assert.areEqual(0, deletedRelatedErrors.size(), 'Related error should be deleted');
	}

	@IsTest
	static void test_getPlatformEventTestLog() {
		Map<String, Id> logIds = createPlatformEventTestLogs();

		Test.startTest();
		TestDataGenerator.TestResultLogs result = TestDataGenerator.getPlatformEventTestLog();
		Test.stopTest();

		Assert.areNotEqual(null, result, 'Result should not be null');
		Assert.areEqual(1, result.createdLogs.size(), 'Should have one created log');
		Assert.areEqual(1, result.errorLogs.size(), 'Should have one error log');
		
		Map<String, Object> createdLog = result.createdLogs.get(0);
		Assert.areEqual(logIds.get(KEY_MAIN_LOG), createdLog.get('Id'), 'Created log Id should match');
		
		Map<String, Object> errorLog = result.errorLogs.get(0);
		Assert.areEqual(logIds.get(KEY_RELATED_ERROR), errorLog.get('Id'), 'Error log Id should match');
	}

	// ============================================
	// Test Platform AI Event Methods
	// ============================================

	@IsTest
	static void test_startPlatformAIEventTest() {
		Map<String, Id> logIds = createAIEventTestLogs();

		Test.startTest();
		Boolean result = (Boolean) TestDataGenerator.startPlatformAIEventTest();
		Test.stopTest();

		Assert.isTrue(result, 'Should return true when AI event is published');
		
		// Verify old logs were deleted
		List<Log__c> deletedLogs = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_MAIN_LOG)];
		Assert.areEqual(0, deletedLogs.size(), 'Old AI event log should be deleted');
		
		List<Log__c> deletedRelatedErrors = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_RELATED_ERROR)];
		Assert.areEqual(0, deletedRelatedErrors.size(), 'Related AI error should be deleted');
	}

	@IsTest
	static void test_getPlatformEventTestAIEventLog() {
		Map<String, Id> logIds = createAIEventTestLogs();

		Test.startTest();
		TestDataGenerator.TestResultLogs result = TestDataGenerator.getPlatformEventTestAIEventLog();
		Test.stopTest();

		Assert.areNotEqual(null, result, 'Result should not be null');
		Assert.areEqual(1, result.createdLogs.size(), 'Should have one created log');
		Assert.areEqual(1, result.errorLogs.size(), 'Should have one error log');
		
		Map<String, Object> createdLog = result.createdLogs.get(0);
		Assert.areEqual(logIds.get(KEY_MAIN_LOG), createdLog.get('Id'), 'Created log Id should match');
		
		Map<String, Object> errorLog = result.errorLogs.get(0);
		Assert.areEqual(logIds.get(KEY_RELATED_ERROR), errorLog.get('Id'), 'Error log Id should match');
	}

	// ============================================
	// Test Error Tracking Methods
	// ============================================

	@IsTest
	static void test_startErrorTrackingRequiresConfigurationTest() {
		Map<String, Id> logIds = createErrorTrackingTestLogs();

		User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];

		Test.startTest();
		Boolean result = (Boolean) TestDataGenerator.startErrorTrackingRequiresConfigurationTest(testUser);
		Test.stopTest();

		Assert.isTrue(result, 'Should return true when error tracking log is created');
		
		List<Log__c> logs = [
			SELECT Id, Hash_1__c, Summary__c, User_Id__c, User_Name__c
			FROM Log__c
			WHERE Hash_1__c = :TestDataGenerator.TEST_ERROR_TRACKING_REQUIRES_CONFIGURATION_HASH1
		];
		Assert.areEqual(1, logs.size(), 'Should create one log record');
		Assert.areEqual(TestDataGenerator.TEST_ERROR_TRACKING_REQUIRES_CONFIGURATION_SUMMARY, logs[0].Summary__c, 'Log summary should match');
		Assert.areEqual(testUser.Id, logs[0].User_Id__c, 'User Id should match');
		Assert.areEqual(testUser.Email, logs[0].User_Name__c, 'User Email should match');
		
		// Verify old logs were deleted
		List<Log__c> deletedLogs = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_MAIN_LOG)];
		Assert.areEqual(0, deletedLogs.size(), 'Old error tracking log should be deleted');
		
		List<Log__c> deletedRelatedErrors = [SELECT Id FROM Log__c WHERE Id = :logIds.get(KEY_RELATED_ERROR)];
		Assert.areEqual(0, deletedRelatedErrors.size(), 'Related error should be deleted');
	}

	@IsTest
	static void test_getErrorTrackingRequiresConfigurationLog() {
		Map<String, Id> logIds = createErrorTrackingTestLogs();

		Test.startTest();
		TestDataGenerator.TestResultLogs result = TestDataGenerator.getErrorTrackingRequiresConfigurationLog();
		Test.stopTest();

		Assert.areNotEqual(null, result, 'Result should not be null');
		Assert.areEqual(1, result.createdLogs.size(), 'Should have one created log');
		Assert.areEqual(1, result.errorLogs.size(), 'Should have one error log');
		
		Map<String, Object> createdLog = result.createdLogs.get(0);
		Assert.areEqual(logIds.get(KEY_MAIN_LOG), createdLog.get('Id'), 'Created log Id should match');
		
		Map<String, Object> errorLog = result.errorLogs.get(0);
		Assert.areEqual(logIds.get(KEY_RELATED_ERROR), errorLog.get('Id'), 'Error log Id should match');
	}

	// ============================================
	// Test Email Exception Log Methods
	// ============================================

	@IsTest
	static void test_getTestEmailExceptionLog_withPassthroughtMode() {
		// Create test log with TEST_EMAIL_HASH1
		Log__c testLog = new Log__c(
			Hash_1__c = TestDataGenerator.TEST_EMAIL_HASH1,
			Summary__c = 'Test email exception log'
		);
		insert testLog;

		// Enable passthrough mode
		ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = true;
		ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c = Test_LogService.CONNECETED_ORG_NAME;
		
		// Update Connected_Org__c to be valid
		Connected_Org__c corg = [SELECT Id FROM Connected_Org__c WHERE Name = :Test_LogService.CONNECETED_ORG_NAME LIMIT 1];
		corg.Connection_Valid__c = true;
		update corg;

		mockPassthroughLogServiceRequest(testLog.Id, testLog.Name);

		Test.startTest();
		TestDataGenerator.TestResultLogs result = TestDataGenerator.getTestEmailExceptionLog();
		Test.stopTest();

		Assert.areNotEqual(null, result, 'Result should not be null');
		Assert.areEqual(1, result.createdLogs.size(), 'Should have one created log');
		
		Map<String, Object> createdLog = result.createdLogs.get(0);
		Assert.areEqual(testLog.Id, createdLog.get('Id'), 'Created log Id should match');
	}

	@IsTest
	static void test_getTestEmailExceptionLog_withoutPassthroughtMode() {
		// Create test log with TEST_EMAIL_HASH1
		Log__c testLog = new Log__c(
			Hash_1__c = TestDataGenerator.TEST_EMAIL_HASH1,
			Summary__c = 'Test email exception log'
		);
		insert testLog;

		// Ensure passthrough mode is disabled (default behavior)
		ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;

		Test.startTest();
		TestDataGenerator.TestResultLogs result = TestDataGenerator.getTestEmailExceptionLog();
		Test.stopTest();

		Assert.areNotEqual(null, result, 'Result should not be null');
		Assert.areEqual(1, result.createdLogs.size(), 'Should have one created log');
		
		Map<String, Object> createdLog = result.createdLogs.get(0);
		Assert.areEqual(testLog.Id, createdLog.get('Id'), 'Created log Id should match');
	}

	@IsTest
	static void test_sendTestEmailException_success() {
		// Create old test log with TEST_EMAIL_HASH1 that should be deleted
		Log__c oldLog = new Log__c(
			Hash_1__c = TestDataGenerator.TEST_EMAIL_HASH1,
			Summary__c = 'Old test email exception log'
		);
		insert oldLog;

		// Ensure passthrough mode is disabled (default behavior)
		ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;

		// Setup mock for email service address
		EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
			TestDataFactory.getFakeIds(ApexEmailNotification.SObjectType, 2),
			TestDataFactory.getFakeIds(EmailServicesFunction.SObjectType, 1),
			TestDataFactory.getFakeIds(EmailServicesAddress.SObjectType, 1)
		);

		AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
			EmailServicesSelector.class,
			emailServicesSelectorMock
		);

		Boolean result;
		Test.startTest();
			result = (Boolean) TestDataGenerator.sendTestEmailException();
			Integer emailInvocations = Limits.getEmailInvocations();
		Test.stopTest();

		// Verify method returned true
		Assert.isTrue(result, 'Should return true when email is sent successfully');
		
		// Verify old log was deleted
		List<Log__c> deletedLogs = [SELECT Id FROM Log__c WHERE Id = :oldLog.Id];
		Assert.areEqual(0, deletedLogs.size(), 'Old test log should be deleted');
		
		// Verify email was sent
		Assert.areEqual(1, emailInvocations, 'Should send one email');
	}

	@IsTest
	static void test_sendTestEmailException_noEmailAddress() {
		// Ensure passthrough mode is disabled
		ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;

		// Setup mock to return empty lists (no email address)
		EmailServicesSelectorMock emailServicesSelectorMock = new EmailServicesSelectorMock(
			new List<Id>(),
			new List<Id>(),
			new List<Id>()
		);

		AdminService.emailServicesSelector = (EmailServicesSelector) Test.createStub(
			EmailServicesSelector.class,
			emailServicesSelectorMock
		);

		TestDataGenerator.TestDataGeneratorException expectedException;
		Test.startTest();
			try {
				TestDataGenerator.sendTestEmailException();
			} catch (TestDataGenerator.TestDataGeneratorException e) {
				expectedException = e;
			}
		Test.stopTest();

		Assert.areNotEqual(null, expectedException, 'TestDataGeneratorException should not be null');
		Assert.areEqual(
			TestDataGenerator.ERROR_EMAIL_SERVICE_FUNCTION_NOT_EXIST,
			expectedException.getMessage(),
			'Exception message should match'
		);
	}

	// ============================================
	// Helper Methods
	// ============================================

	private static Map<String, Id> createTestLogsWithRelatedError(String hash1, String summary) {
		// Create main test log
		Log__c testLog = new Log__c(
			Hash_1__c = hash1,
			Summary__c = summary,
			User_Id__c = UserInfo.getUserId(),
			User_Name__c = UserInfo.getUserName()
		);
		insert testLog;

		// Create related error log
		Log__c relatedError = new Log__c(
			Related_Id__c = testLog.Id,
			Summary__c = 'Related error log'
		);
		insert relatedError;

		return new Map<String, Id>{
			KEY_MAIN_LOG => testLog.Id,
			KEY_RELATED_ERROR => relatedError.Id
		};
	}

	private static Map<String, Id> createPlatformEventTestLogs() {
		return createTestLogsWithRelatedError(
			TestDataGenerator.TEST_PLATFORM_EVENT_LOG_HASH1,
			'Test platform event log'
		);
	}

	private static Map<String, Id> createAIEventTestLogs() {
		return createTestLogsWithRelatedError(
			TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_LOG_HASH1,
			'Test AI event log'
		);
	}

	private static Map<String, Id> createErrorTrackingTestLogs() {
		return createTestLogsWithRelatedError(
			TestDataGenerator.TEST_ERROR_TRACKING_REQUIRES_CONFIGURATION_HASH1,
			TestDataGenerator.TEST_ERROR_TRACKING_REQUIRES_CONFIGURATION_SUMMARY
		);
	}

	private static void createEmailTemplate(String templateName) {
		EmailTemplate emailTemplate = new EmailTemplate();
		emailTemplate.isActive = true;
		emailTemplate.Name = templateName;
		emailTemplate.DeveloperName = templateName;
		emailTemplate.TemplateType = 'text';
		emailTemplate.Subject = 'test subject';
		emailTemplate.Body = 'some test body <link>';
		emailTemplate.FolderId = UserInfo.getUserId();
		insert emailTemplate;
	}

	private static void mockPassthroughLogServiceRequest(Id logId, String logName) {
		// Create mock response for LogRestService endpoint
		Map<String, Object> responseBody = new Map<String, Object>{
			'logs' => new List<Object>{ new Map<String, Object>{
				'Id' => logId,
				'Name' => logName
			}}
		};
		
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>{
			TestDataGenerator.getTestEmailExceptionLogEndpoint(Test_LogService.CONNECETED_ORG_INSTANCE_URL) =>
			new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				JSON.serialize(responseBody)
			)
		};

		Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(endpoint2TestResp));
	}

	// TODO: Need to move
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