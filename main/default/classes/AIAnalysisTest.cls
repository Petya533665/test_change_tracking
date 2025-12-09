@IsTest
public class AIAnalysisTest {
	private static final String MOCK_RESPONSE = '{ "status": "success", "data": "Analysis completed" }';

	@TestSetup
	static void testSetup() {
		TestDataFactory.createConnectedOrg();
		ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = true;
		ConfigUtil.OPEN_AI_SETTINGS.Token__c = 'Token';
		upsert ConfigUtil.OPEN_AI_SETTINGS;
		ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c = false;
		upsert ConfigUtil.CHANGE_TRACKING_SETTINGS;
	}

	private static void enableIssuePermissions() {
		TestDataFactory.enableIssueTracking();
		PermissionsUtil.IssueAnalysisEnabled = true;
	}

	private static void createPharosLog() {
		Log__c log = new Log__c();
		log.Category__c = 'Apex';
		log.Type__c = 'NullPointerException' ;
		log.Area__c = 'Apex';
		log.Summary__c = 'Attempt to de-reference a null object';
		log.Details__c = 'TestDetails';
		log.User_Id__c = UserInfo.getUserId();
		log.Related_Id__c = UserInfo.getUserId();
		log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
		log.Hash_1__c = 'hash_1';
		log.Hash_2__c = 'hash_2';
		log.Hash_3__c = 'hash_3';
		log.Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST;
		log.Setup_Audit_Trail__c = 'test_data';
		insert log;
	}

	private static void startAnalysis(String issueId, Boolean invocable) {
		if (invocable) {
			List<Id> issueIds = new List<Id>{issueId};
			Logger.IssueAnalysis issueAnalysis = new Logger.IssueAnalysis();
			issueAnalysis.issueIds = issueIds;
			Logger.startAnalysis(new List<Logger.IssueAnalysis>{issueAnalysis});
		} else {
			OpenAIController.startAnalysis(issueId);
		}
	}

	@IsTest
	private static void testStartAnalysis() {
		testStartAnalysis(false);
	}

	@IsTest
	private static void testStartAnalysis_invocable() {
		testStartAnalysis(true);
	}

	private static void testStartAnalysis(Boolean invocable) {
		enableIssuePermissions();
		createPharosLog();
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.OPEN_AI_COMPLETIONS_ENDPOINT, basicAnalysisMock());
		endpoint2TestResp.put(AIAnalysisService.AI_ANALYSIS_ENDPOINT, auditTrailAnalysisMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		startAnalysis(issues[0].Id, invocable);
		Test.stopTest();
		issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c WHERE Id = :issues[0].Id];
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails = (List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(issues[0].Analysis_Statuses_Details__c, List<AIAnalysisService.AnalysisStatusDetails>.class);
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			if (asd.analysis == AIAnalysisService.BASIC_ANALYSIS) {
				System.assertEquals(AIAnalysisService.PENDING_STATUS, asd.status);
			} else if (asd.analysis == AIAnalysisService.FLOW_ANALYSIS) {
				System.assertEquals(AIAnalysisService.NOT_APPLICABLE_STATUS, asd.status);
			} else if (asd.analysis == AIAnalysisService.FLOW_EXPLAIN_ANALYSIS) {
				System.assertEquals(AIAnalysisService.NOT_APPLICABLE_STATUS, asd.status);
			} else if (asd.analysis == AIAnalysisService.AUDIT_TRAIL_ANALYSIS) {
				System.assertEquals(AIAnalysisService.CONFIGURATION_REQUIRED_STATUS, asd.status);
			}
		}
	}

	@IsTest
	private static void testAnalysisStatusTransition() {
		enableIssuePermissions();
		createPharosLog();
		List<Issue__c> issues = [SELECT Id FROM Issue__c];

		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.OPEN_AI_COMPLETIONS_ENDPOINT, basicAnalysisMock());
		endpoint2TestResp.put(AIAnalysisService.AI_ANALYSIS_ENDPOINT, auditTrailAnalysisMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		startAnalysis(issues[0].Id, false);
		Test.stopTest();

		issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c WHERE Id = :issues[0].Id];
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails =
				(List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(
						issues[0].Analysis_Statuses_Details__c,
						List<AIAnalysisService.AnalysisStatusDetails>.class
				);

		String basicAnalysisStatus = null;
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			if (asd.analysis == AIAnalysisService.BASIC_ANALYSIS) {
				basicAnalysisStatus = asd.status;
				break;
			}
		}
		System.assertEquals(AIAnalysisService.PENDING_STATUS, basicAnalysisStatus);
	}

	@IsTest
	private static void testAnalysisPendingToCompleted() {
		testAnalysisPending('success', AIAnalysisService.COMPLETED_STATUS);
	}

	@IsTest
	private static void testAnalysisPendingToFailed() {
		testAnalysisPending(AIAnalysisService.AWS_ERROR_STATUS, AIAnalysisService.FAILED_STATUS);
	}

	private static void testAnalysisPending(String aws_status, String analysis_status) {
		enableIssuePermissions();
		createPharosLog();
		List<Issue__c> issues = [SELECT Id, Analysis_Status__c, Analysis_Statuses_Details__c FROM Issue__c];

		issues[0].Analysis_Status__c = AIAnalysisService.PENDING_STATUS;
		issues[0].Analysis_Statuses_Details__c = issueAnalysisDetails;

		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails =
				(List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(
						issues[0].Analysis_Statuses_Details__c,
						List<AIAnalysisService.AnalysisStatusDetails>.class
				);

		String basicAnalysisStatus = null;
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			if (asd.analysis == AIAnalysisService.BASIC_ANALYSIS) {
				basicAnalysisStatus = asd.status;
				break;
			}
		}
		System.assertEquals(AIAnalysisService.PENDING_STATUS, basicAnalysisStatus);
		Test.startTest();
		AI_Event__e event = new AI_Event__e();
		event.Analysis__c = AIAnalysisService.BASIC_ANALYSIS;
		event.Record_Id__c = issues[0].Id;
		event.Result__c = 'Test Data';
		event.Status__c = aws_status;
		EventBus.publish(new List<AI_Event__e>{
				event
		});
		Test.stopTest();
		issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c WHERE Id = :issues[0].Id];
		analysisStatusesDetails =
				(List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(
						issues[0].Analysis_Statuses_Details__c,
						List<AIAnalysisService.AnalysisStatusDetails>.class
				);

		basicAnalysisStatus = null;
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			if (asd.analysis == AIAnalysisService.BASIC_ANALYSIS) {
				basicAnalysisStatus = asd.status;
				break;
			}
		}
		System.assertEquals(analysis_status, basicAnalysisStatus);
	}

	private static String issueAnalysisDetails = '[{"status":"Pending","message":null,"lastAnalysisTimestamp":1761750279470,"analysis":"basic"},{"status":"Configuration Required","message":"Code and flow analysis requires Change Tracking feature to be enabled in Pharos Admin -> Change Tracking.  If that menu option is not available please contact success@pharos.ai for enablement.","lastAnalysisTimestamp":null,"analysis":"code_explain"},{"status":"Not Applicable","message":null,"lastAnalysisTimestamp":null,"analysis":"flow"},{"status":"Not Applicable","message":null,"lastAnalysisTimestamp":null,"analysis":"flow_explain"},{"status":"Configuration Required","message":"Code and flow analysis requires Change Tracking feature to be enabled in Pharos Admin -> Change Tracking.  If that menu option is not available please contact success@pharos.ai for enablement.","lastAnalysisTimestamp":null,"analysis":"audit_trail"}]';

	@IsTest
	private static void testStartAnalysis_invocable_negative() {
		enableIssuePermissions();
		Test.startTest();
		startAnalysis(UserInfo.getUserId(), true);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM Log__c]);
	}

	@IsTest
	private static void testAuditTrailAnalysis() {
		testAuditTrailAnalysis(false);
	}

	@IsTest
	private static void testAuditTrailAnalysis_invocable() {
		testAuditTrailAnalysis(true);
	}

	private static void testAuditTrailAnalysis(Boolean invocable) {
		enableIssuePermissions();
		createPharosLog();
		List<Log__c> logs = [SELECT Id, Setup_Audit_Trail__c, Audit_Trail_available__c FROM Log__c];
		logs[0].Setup_Audit_Trail__c = '[{audit_trail_data}]';
		logs[0].Audit_Trail_available__c = true;
		update logs;
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.OPEN_AI_COMPLETIONS_ENDPOINT, basicAnalysisMock());
		endpoint2TestResp.put(AIAnalysisService.AI_ANALYSIS_ENDPOINT, auditTrailAnalysisMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		startAnalysis(issues[0].Id, invocable);
		Test.stopTest();
		issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c WHERE Id = :issues[0].Id];
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails = (List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(issues[0].Analysis_Statuses_Details__c, List<AIAnalysisService.AnalysisStatusDetails>.class);
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			if (asd.analysis == AIAnalysisService.AUDIT_TRAIL_ANALYSIS) {
				System.assertEquals(AIAnalysisService.CONFIGURATION_REQUIRED_STATUS, asd.status);
			}
		}
	}

	@IsTest
	private static void testStartAnalysis_CDL() {
		testStartAnalysis_CDL(false);
	}

	@IsTest
	private static void testStartAnalysis_CDL_invocable() {
		testStartAnalysis_CDL(true);
	}

	private static void testStartAnalysis_CDL(Boolean invocable) {
		enableIssuePermissions();
		createPharosLog();
		List<Issue__c> issues = [SELECT Id, Name FROM Issue__c];
		String title = issues[0].Name + '_' + 'basic';
		ContentVersion contentVersion = new ContentVersion();
		contentVersion.PathOnClient = title + '.json';
		contentVersion.VersionData = Blob.valueOf('result');
		contentVersion.Description = title;
		contentVersion.ContentLocation = 'S';
		contentVersion.IsMajorVersion = true;
		insert contentVersion;
		List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
		ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
		contentDocumentLink.ContentDocumentId = contentVersions[0].ContentDocumentId;
		contentDocumentLink.LinkedEntityId = issues[0].Id;
		contentDocumentLink.ShareType = 'I';
		insert contentDocumentLink;
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.OPEN_AI_COMPLETIONS_ENDPOINT, basicAnalysisMock());
		endpoint2TestResp.put(AIAnalysisService.AI_ANALYSIS_ENDPOINT, auditTrailAnalysisMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		startAnalysis(issues[0].Id, invocable);
		Test.stopTest();
		System.assertEquals(1, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :issues[0].Id].size());
	}
	
	@IsTest
	private static void testGetAnalysis() {
		enableIssuePermissions();
		createPharosLog();
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(ConfigUtil.OPEN_AI_COMPLETIONS_ENDPOINT, basicAnalysisMock());
		endpoint2TestResp.put(AIAnalysisService.AI_ANALYSIS_ENDPOINT, auditTrailAnalysisMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		startAnalysis(issues[0].Id, false);
		List<OpenAIController.AnalysisStatusDetails> result = OpenAIController.getAnalysis(issues[0].Id);
		Test.stopTest();
		for (OpenAIController.AnalysisStatusDetails analysisStatusDetails : result) {
			if (analysisStatusDetails.analysis == AIAnalysisService.BASIC_ANALYSIS) {
				System.assert(String.isBlank(analysisStatusDetails.result));
			}
		}
	}

	@IsTest
	private static void testBasicAnalysisHtml() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.BASIC, Test_LogService.getTestStub('BASIC_ANALYSIS_RESPONSE'));
		responseInterface.setContext('LWC');
		System.assertEquals(Test_LogService.getTestStub('BASIC_ANALYSIS_HTML').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testExplainAnalysisHtml() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.CODE_EXPLAIN, Test_LogService.getTestStub('EXPLAIN_ANALYSIS_RESPONSE'));
		responseInterface.setContext('LWC');
		System.assertEquals(Test_LogService.getTestStub('EXPLAIN_ANALYSIS_HTML').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testAuditTrailAnalysisHtml() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.AUDIT_TRAIL, Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_RESPONSE'));
		responseInterface.setContext('LWC');
		System.assertEquals(Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_HTML').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testBasicAnalysisJiraMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.BASIC, Test_LogService.getTestStub('BASIC_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA');
		System.assertEquals(Test_LogService.getTestStub('BASIC_ANALYSIS_JIRA_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testExplainAnalysisJiraMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.CODE_EXPLAIN, Test_LogService.getTestStub('EXPLAIN_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA');
		System.assertEquals(Test_LogService.getTestStub('EXPLAIN_ANALYSIS_JIRA_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testAuditTrailAnalysisJiraMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.AUDIT_TRAIL, Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA');
		System.assertEquals(Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_JIRA_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testBasicAnalysisJiraADFMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.BASIC, Test_LogService.getTestStub('BASIC_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA_ADF');
		System.assertEquals(Test_LogService.getTestStub('BASIC_ANALYSIS_JIRA_ADF_MARKDOWN').trim(), JSON.serialize(responseInterface.getFormattedDataADF()).trim());
	}

	@IsTest
	private static void testExplainAnalysisJiraADFMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.CODE_EXPLAIN, Test_LogService.getTestStub('EXPLAIN_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA_ADF');
		System.debug(JSON.serialize(responseInterface.getFormattedDataADF()).trim());
		System.assertEquals(Test_LogService.getTestStub('EXPLAIN_ANALYSIS_JIRA_ADF_MARKDOWN').trim(), JSON.serialize(responseInterface.getFormattedDataADF()).trim());
	}

	@IsTest
	private static void testAuditTrailAnalysisJiraADFMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.AUDIT_TRAIL, Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_RESPONSE'));
		responseInterface.setContext('JIRA_ADF');
		System.assertEquals(Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_JIRA_ADF_MARKDOWN').trim(), JSON.serialize(responseInterface.getFormattedDataADF()).trim());
	}

	@IsTest
	private static void testBasicAnalysisSlackMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.BASIC, Test_LogService.getTestStub('BASIC_ANALYSIS_RESPONSE'));
		responseInterface.setContext('SLACK');
		System.assertEquals(Test_LogService.getTestStub('BASIC_ANALYSIS_SLACK_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testExplainAnalysisSlackMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.CODE_EXPLAIN, Test_LogService.getTestStub('EXPLAIN_ANALYSIS_RESPONSE'));
		responseInterface.setContext('SLACK');
		System.assertEquals(Test_LogService.getTestStub('EXPLAIN_ANALYSIS_SLACK_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	@IsTest
	private static void testAuditTrailAnalysisSlackMarkdown() {
		AIAnalysisService.ResponseInterface responseInterface = AIAnalysisService.getResponseInterface(AIAnalysisService.Analysis.AUDIT_TRAIL, Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_RESPONSE'));
		responseInterface.setContext('SLACK');
		System.assertEquals(Test_LogService.getTestStub('AUDIT_TRAIL_ANALYSIS_SLACK_MARKDOWN').trim(), responseInterface.getFormattedData().trim());
	}

	private static TestDataFactory.SingleRequestMock basicAnalysisMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{' +
						'  "id": "chatcmpl-A6zwbvdXSAKFfFHpzy9W3hU8XgLlJ",' +
						'  "object": "chat.completion",' +
						'  "created": 1726231445,' +
						'  "model": "gpt-4o-mini-2024-07-18",' +
						'  "choices": [' +
						'    {' +
						'      "index": 0,' +
						'      "message": {' +
						'        "role": "assistant",' +
						'        "content": "{\\n  \\"RootCauseAnalysis\\": \\"The error is due to a maximum stack depth being reached in the execution of a invocable job. This indicates that there may be a recursive logic or a deep chain of invocable calls that is leading to excessive nesting, ultimately causing the AsyncException.\\",\\n  \\"ResolutionOptions\\": [\\n    \\"Investigate the logic in the invocable job classes to identify any recursive calls or deep chaining that could be optimized.\\",\\n    \\"Implement error handling to catch and manage the maximum stack depth condition to avoid unhandled exceptions.\\",\\n    \\"Consider breaking down the processing logic into smaller, more manageable invocable jobs to prevent reaching stack depth limits.\\"\\n  ],\\n  \\"SeverityEstimate\\": \\"Medium\\",\\n  \\"Justification\\": \\"The issue has just occurred within 1 day and has impacted 1 user; however, there are no impacted data records reported. The average days between error occurrences is relatively low, indicating it occurs more frequently and poses a potential ongoing operational impact.\\"\\n}",' +
						'        "refusal": null' +
						'      },' +
						'      "logprobs": null,' +
						'      "finish_reason": "stop"' +
						'    }' +
						'  ],' +
						'  "usage": {' +
						'    "prompt_tokens": 430,' +
						'    "completion_tokens": 198,' +
						'    "total_tokens": 628,' +
						'    "completion_tokens_details": {' +
						'      "reasoning_tokens": 0' +
						'    }' +
						'  },' +
						'  "system_fingerprint": "fp_483d39d857"' +
						'}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock auditTrailAnalysisMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				''
		);
		return singleRequestMock;
	}

	private static final String ANALYSIS_STATUSES_DETAILS = '[' +
			'{"status":"Completed","message":null,"lastAnalysisTimestamp":1719232885391,"analysis":"basic"},' +
			'{"status":"In Progress","message":null,"lastAnalysisTimestamp":1719232885415,"analysis":"code_fix"},' +
			'{"status":"In Progress","message":null,"lastAnalysisTimestamp":1719232885415,"analysis":"code_explain"},' +
			'{"status":"In Progress","message":null,"lastAnalysisTimestamp":1719232885415,"analysis":"flow"},' +
			'{"status":"In Progress","message":null,"lastAnalysisTimestamp":1719232885415,"analysis":"audit_trail"}' +
			']';

	private static void setAnalysisStatusesDetails() {
		List<Issue__c> issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c];
		issues[0].Analysis_Statuses_Details__c = ANALYSIS_STATUSES_DETAILS;
		update issues;
	}

	@IsTest
	private static void testEventTrigger_code() {
		testEventTrigger(new List<String>{AIAnalysisService.CODE_EXPLAIN_ANALYSIS}, 'success');
	}

	@IsTest
	private static void testEventTrigger_flow() {
		testEventTrigger(new List<String>{AIAnalysisService.FLOW_ANALYSIS}, 'success');
	}

	@IsTest
	private static void testEventTrigger_auditTrail() {
		testEventTrigger(new List<String>{AIAnalysisService.AUDIT_TRAIL_ANALYSIS}, 'success');
	}

	@IsTest
	private static void testEventTrigger_code_negative() {
		testEventTrigger(new List<String>{AIAnalysisService.CODE_EXPLAIN_ANALYSIS}, 'error');
	}

	@IsTest
	private static void testEventTrigger_flow_negative() {
		testEventTrigger(new List<String>{AIAnalysisService.FLOW_ANALYSIS}, 'error');
	}

	@IsTest
	private static void testEventTrigger_auditTrail_negative() {
		testEventTrigger(new List<String>{AIAnalysisService.AUDIT_TRAIL_ANALYSIS}, 'error');
	}

	private static void testEventTrigger(List<String> analysis, String status) {
		enableIssuePermissions();
		createPharosLog();
		setAnalysisStatusesDetails();
		List<Issue__c> issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c];
		List<AI_Event__e> events = new List<AI_Event__e>();
		for (String a : analysis) {
			AI_Event__e event = new AI_Event__e();
			event.Analysis__c = a;
			event.Record_Id__c = issues[0].Id;
			if (status == 'success') {
				event.Result__c = 'Test Data';
				event.Status__c = status;
			} else {
				event.Result__c = 'Failed to establish a connection to the OpenAi API';
				event.Status__c = status;
			}
			events.add(event);
		}
		Test.startTest();
		EventBus.publish(
				events
		);
		Test.stopTest();
		issues = [SELECT Id, Analysis_Statuses_Details__c FROM Issue__c];
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails = (List<AIAnalysisService.AnalysisStatusDetails>)JSON.deserialize(issues[0].Analysis_Statuses_Details__c, List<AIAnalysisService.AnalysisStatusDetails>.class);
		for (AIAnalysisService.AnalysisStatusDetails asd : analysisStatusesDetails) {
			for (String a : analysis) {
				if (asd.analysis == a) {
					if (status == 'success') {
						System.assertEquals(AIAnalysisService.COMPLETED_STATUS, asd.status);
					} else {
						System.assertEquals(AIAnalysisService.FAILED_STATUS, asd.status);
					}
				}
			}
		}
	}

}