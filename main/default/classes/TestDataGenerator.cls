public with sharing class TestDataGenerator {

	public static final Integer TEST_EMAIL_EXCEPTION_STEP_TIME = 1;
	public static final Integer TEST_EMAIL_EXCEPTION_LIMIT_TIME = 20;
	public static final String TEST_EMAIL_EXCEPTION_KEY_USER = 'userid';
	public static final String TEST_EMAIL_EXCEPTION_KEY_START_TIME = 'startat';
	public static final Integer MONITORING_EVENTS_STEP_TIME = 1;
	public static final Integer MONITORING_EVENTS_LIMIT_TIME = 20;
	public static final String MONITORING_EVENTS_KEY_USER = 'userid';
	public static final String MONITORING_EVENTS_KEY_START_TIME = 'startat';


	public static void abortCronTriggerJob(String jobName) {
		String fullJobName = jobName + '%';
		for(CronTrigger ct : [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :fullJobName]){
			try{
				System.abortJob(ct.id);
			}
			catch(Exception e) {}
		}
	}

	public static final String CHECK_MONITORING_EVENTS_JOB_NAME = 'Status Monitoring Events Job Started At';
	public static final String TEST_MONITORING_EVENTS_EMAIL_TEMPLATE_NAME = 'Test_Email_Monitoring_Events';
	public static final String TEST_MONITORING_EVENTS_EMAIL_TEMPLATE_NAME_FAIL = 'Test_Email_Monitoring_Events_Fail';


	public static void setSubjectBody(Messaging.SingleEmailMessage message, EmailTemplate emailTemplate, String link, String error) {
		String subject = emailTemplate.Subject;
		String body = emailTemplate.Body;
		body = body.replace('<link>', link);
		body = body.replace('<error>', error);
		message.setSubject(subject);
		message.setPlainTextBody(body);
	}

	public static EmailTemplate getEmailTemplateByDeveloperName(String devName) {
		EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
			FROM EmailTemplate
			WHERE DeveloperName = :devName
			LIMIT 1
		];
		return emailTemplate;
	}

	public static String getNextFireTime(DateTime dt) {
		String hour = String.valueOf(dt.hour());
		String min = String.valueOf(dt.minute());
		String ss = String.valueOf(dt.second());
		String nextFireTime = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + ' ' + dt.year();
		return nextFireTime;
	}


	public static final Integer SETUP_CONNECTED_APP_LIMIT_TIME = 10;
	public static final String TEST_EMAIL_SERVICE_KEY_USER = 'userid';

	@Future(Callout=true)
	public static void startCheckSetupConnectedAppFuture(String data) {
		startCheckSetupConnectedApp(data);
	}

	public static Object connectedAppSendMeAnEmail() {
		Map<String, Object> data = new Map<String, Object> {
			MONITORING_EVENTS_KEY_USER => CURRENT_USER_ID_15
		};
		return startCheckSetupConnectedApp(JSON.serialize(data));
	}

	public static final String STATUS_CONNECTED_APP_JOB_NAME = 'Status Connected App Job Started At';

	public static Boolean startCheckSetupConnectedApp(String data) {
		Boolean result = false;
		abortCronTriggerJob(STATUS_CONNECTED_APP_JOB_NAME);

		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(data);
		String userId = String.valueOf(input.get(TEST_EMAIL_SERVICE_KEY_USER));

		if(String.isNotBlank(userId)
				&& ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c != null) {

			String nextFireTime;

			if(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c.addMinutes(SETUP_CONNECTED_APP_LIMIT_TIME) > Datetime.now()){
				nextFireTime = getNextFireTime(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c.addMinutes(SETUP_CONNECTED_APP_LIMIT_TIME + 1));
			}
			else if (ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c.addMinutes(SETUP_CONNECTED_APP_LIMIT_TIME) < Datetime.now()) {
				sendConnectedAppReadyEmail(userId);
				result = true;
			}

			if(String.isNotBlank(nextFireTime)) {
				TestDataGeneratorScheduler s = new TestDataGeneratorScheduler(TestDataGeneratorScheduler.MODE.CHECK_COMPLETE_SETUP_CONNECTED_APP_AND_SEND_EMAIL, JSON.serialize(input));
				Id jobId;
				try {
					jobId = System.schedule(STATUS_CONNECTED_APP_JOB_NAME + ' ' + String.valueOf(Datetime.now()), nextFireTime, s);
					result = true;
				}
				catch(System.AsyncException ae) {
					sendConnectedAppReadyEmail(userId);
					result = true;
				}
				catch(Exception e){}
			}
		}
		return result;
	}

	public static final String CONNECTED_APP_READY_EMAIL_TEMPLATE_NAME = 'Email_Connected_App_Ready';

	public static void sendConnectedAppReadyEmail(String userId) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

		message.setTargetObjectId(userId);
		message.setUseSignature(false);
		message.setBccSender(false);
		message.setSaveAsActivity(false);

		EmailTemplate emailTemplate = getEmailTemplateByDeveloperName(CONNECTED_APP_READY_EMAIL_TEMPLATE_NAME);
		setSubjectBody(message, emailTemplate, ConfigUtil.BASE_URL + '/apex/' + ConfigUtil.NameSpacePrefix + 'Admin#/quick-start/connect-org', '');

		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

	}

	public class TestResultLogs {
		public List<Map<String, Object>> createdLogs;
		public List<Map<String, Object>> errorLogs;
		public List<Map<String, Object>> createdEvents;

		public TestResultLogs(){
			this.createdLogs = new List<Map<String, Object>>();
			this.errorLogs = new List<Map<String, Object>>();
			this.createdEvents = new List<Map<String, Object>>();
		}
	}

	@TestVisible
	private static String CURRENT_CONNECTED_ORG_ID_15 = UserInfo.getOrganizationId().left(15);
	@TestVisible
	private static String CURRENT_CONNECTED_ORG_NAME = UserInfo.getOrganizationName();
	@TestVisible
	private static String CURRENT_USER_ID_15 = UserInfo.getUserId().left(15);

	@TestVisible
	public static String CURRENT_CONNECTED_ORG_TITLE {
		get {
			if(CURRENT_CONNECTED_ORG_TITLE == null) {
				Connected_Org__c corg = Connected_Org__c.getInstance(CURRENT_CONNECTED_ORG_ID_15);
				CURRENT_CONNECTED_ORG_TITLE = corg.Title__c;
			}
			return CURRENT_CONNECTED_ORG_TITLE;
		}
		private set;
	}

	public static void deleteTestEmailExceptionLogs() {
		List<Log__c> logs = getTestEmailExceptionLogs();
		if(!logs.isEmpty() && !ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
			delete logs;
		}
	}

	public static List<Log__c> getTestEmailExceptionLogs() {
		List<Log__c> logs;
		if(ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
			Connected_Org__c connectedPharosOrg = ConnectedOrgService.getPassthroughConnectedOrg();
			if(connectedPharosOrg != null) {
				String logServiceEndpoint = connectedPharosOrg.Instance_Url__c + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?'
					+ LogRestService.HASH1_PARAMS + '=' + EncodingUtil.urlEncode(TEST_EMAIL_HASH1, 'UTF-8')
					+ '&' + LogRestService.LIMIT_PARAMS + '=1';

				String b = HttpUtils.get(
					logServiceEndpoint,
					HttpUtils.getHeaders(ConnectedOrgService.getConnectedOrgAccessToken(connectedPharosOrg)),
					200
				);
				Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(b);
				List<Object> logsMap = (List<Object>)responseMap.get('logs');
				logs = (List<Log__c>)JSON.deserialize(JSON.serialize(logsMap), List<Log__c>.class);
			}
		}
		else {
			logs = [SELECT Id, Name FROM Log__c WHERE Hash_1__c =:TEST_EMAIL_HASH1 ORDER BY CreatedDate DESC LIMIT 1];
		}
		return logs;
	}

	public static TestResultLogs getTestEmailExceptionLog() {
		TestResultLogs result = new TestResultLogs();
		result.createdLogs = ConfigUtil.getSObjectWithoutNameSpace(getTestEmailExceptionLogs());
		return result;
	}

	public static Object sendTestEmailException() {
		Boolean result = false;
		deleteTestEmailExceptionLogs();
		String errorEmailHandlerAddress = AdminService.getPackageEmailServiceFunctionEmailAddress();
		if(String.isNotBlank(errorEmailHandlerAddress)) {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] {errorEmailHandlerAddress};
			message.subject = TEST_EMAIL_SUBJECT;
			message.plainTextBody = TEST_EMAIL_BODY;
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			if (!results[0].success) {
				throw new TestDataGeneratorException(ERROR_SEND_TEST_EMAIL + results[0].errors[0].message);
			}
			else {
				result = true;
			}
		}
		else {
			throw new TestDataGeneratorException(ERROR_EMAIL_SERVICE_FUNCTION_NOT_EXIST);
		}
		return result;
	}

	public class TestDataGeneratorException extends Exception {}
	public static final String ERROR_EMAIL_SERVICE_FUNCTION_NOT_EXIST = 'ERROR_EMAIL_SERVICE_FUNCTION_NOT_EXIST';
	public static final String ERROR_SEND_TEST_EMAIL = 'ERROR_SEND_TEST_EMAIL:';
	public static final String TEST_EMAIL_HASH1 = 'scMlAnyYyfwCAufe0WUj+47enHaVZ3mZjpfJefGij0Y=';
	public static final String TEST_EMAIL_SUBJECT = 'Developer script exception from '+CURRENT_CONNECTED_ORG_NAME+' : \'pharos.LogServiceBatchTest\' for job id \'7076g00000ScE4F\' : Attempt to de-reference a null object';
	public static final String TEST_EMAIL_BODY = 'Apex script unhandled exception by user/organization: '+CURRENT_USER_ID_15.left(15)+'/'+CURRENT_CONNECTED_ORG_ID_15+'\n' +
		'\n' +
		'Failed to process batch for class \'pharos.LogServiceBatchTest\' for job id \'7076g00000ScE4F\'\n' +
		'\n' +
		'caused by: System.NullPointerException: Attempt to de-reference a null object\n' +
		'\n' +
		'Class.pharos.LogServiceBatchTest.execute: line 14, column 1';


	public static final String TEST_PLATFORM_EVENT_LOG_HASH1 = '7woH3kUlYkezkkEt3c1eQ8fLj9jXCcmhcCft5AX+3nI=';
	public static final String TEST_PLATFORM_EVENT_LOG_SUMMARY = 'Divide by 0';
	public static final String TEST_PLATFORM_EVENT_LOG_TYPE = 'System.MathException';
	public static final String TEST_PLATFORM_EVENT_LOG_CATEGORY = 'Error';
	public static final String TEST_PLATFORM_EVENT_LOG_AREA = 'Test Platform Event';
	public static final String TEST_PLATFORM_EVENT_LOG_STACKTRACE = 'Class.pharos.TestDataGenerator.slack.startPlatformEventTest: line 71, column 1';
	public static final String TEST_PLATFORM_EVENT_LOG_DETAILS = 'System.MathException: Divide by 0' + '\n\n' + TEST_PLATFORM_EVENT_LOG_STACKTRACE;

	public static List<Log__c> getTestPlatformEventLogs() {
		List<Log__c> logs = [
			SELECT Id, Name
			FROM Log__c
			WHERE Hash_1__c = :TEST_PLATFORM_EVENT_LOG_HASH1
		];
		return logs;
	}

	public static List<Log__c> getTestPlatformEventRelatedErrorLogs(List<Id> logIds) {
		List<Log__c> logs = [
			SELECT Id, Name, Summary__c
			FROM Log__c
			WHERE Related_Id__c IN :logIds
		];
		return logs;
	}

	public static void deleteTestPlatformEventLogs() {
		List<Log__c> logs = getTestPlatformEventLogs();
		if(!logs.isEmpty()) {
			Map<Id, Log__c> mapLogs = new Map<Id, Log__c>(logs);
			List<Log__c> relatedErrors = getTestPlatformEventRelatedErrorLogs(new List<Id>(mapLogs.keySet()));
			if(!relatedErrors.isEmpty()){
				delete relatedErrors;
			}
			delete logs;
		}

	}

	public static TestResultLogs getPlatformEventTestLog() {
		TestResultLogs result = new TestResultLogs();

		List<Log__c> logs = getTestPlatformEventLogs();
		if(!logs.isEmpty()) {
			result.createdLogs.add(ConfigUtil.getSObjectWithoutNameSpace(logs.get(0)));
			List<Log__c> relatedErrors = getTestPlatformEventRelatedErrorLogs(new List<Id>{logs.get(0).Id});
			if(!relatedErrors.isEmpty()) {
				result.errorLogs.add(ConfigUtil.getSObjectWithoutNameSpace(relatedErrors.get(0)));
			}
		}

		return result;
	}

	public static Object startPlatformEventTest() {
		Boolean result = false;

		//delete old test Logs and related errors
		deleteTestPlatformEventLogs();

		// create Log for Slack Test
		Log__c log = LogBuilder.getInstance()
			.category(TEST_PLATFORM_EVENT_LOG_CATEGORY)
			.summary(TEST_PLATFORM_EVENT_LOG_SUMMARY)
			.area(TEST_PLATFORM_EVENT_LOG_AREA)
			.type(TEST_PLATFORM_EVENT_LOG_TYPE)
			.stackTrace(TEST_PLATFORM_EVENT_LOG_STACKTRACE)
			.details(TEST_PLATFORM_EVENT_LOG_DETAILS)
			.createIssue()
			.build();
		Logger.getInstance().add(log);
		Logger.getInstance().flush();
		result = true;

		return result;
	}

	public static String TEST_JOB_ID = 'testJobId';
	public static String TEST_1_JOB_ID = 'test1JobId';
	public static String TEST_2_JOB_ID = 'test2JobId';

	public static Map<String, String> MAP_SUMMARY_ERRORS = new Map<String, String>{
			'header' => 'sf__Error,"Company","Industry","LastName","Status","Description",total_records',
			'FIELD_CUSTOM_VALIDATION_EXCEPTION' => '"Test, Inc.",,"TestLastName","New","TestDescription", '
	};
	public static Map<String, Integer> MAP_SUMMARY_ERRORS_COUNTER = new Map<String, Integer>{
			'FIELD_CUSTOM_VALIDATION_EXCEPTION' => 1
	};

	public static BulkAPIJobBatchService.Job generateJob(String jobId) {
		BulkAPIJobBatchService.Job job = new BulkAPIJobBatchService.Job();
		job.id = jobId;
		job.apiVersion = '52.0';
		job.contentType = 'CSV';
		job.jobType = 'Classic';
		job.columnDelimiter = 'COMMA';
		job.lineEnding = 'LF';
		job.obj = 'Lead';
		job.operation = 'insert';
		job.systemModstamp = String.valueOf(System.now());
		job.numberRecordsFailed = 1;
		job.numberRecordsProcessed = 1;
		return job;
	}

}