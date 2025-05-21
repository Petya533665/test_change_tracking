@IsTest
public class IssueTriggerHandlerTest {

	private static final String TEST_ISSUE_DESCRIPTION = 'some error';
	private static final String TEST_ISSUE_SUMMARY = 'some error';

	@TestVisible
	private static Log__c createPharosLog(String hash1, String hash2, String hash3) {
		return new Log__c(
				Hash_1__c = hash1,
				Hash_2__c = hash2,
				Hash_3__c = hash3,
				Category__c = IssueTriggerHandler.FLOW_CATEGORY,
				Details__c = TEST_ISSUE_DESCRIPTION,
				Summary__c = TEST_ISSUE_SUMMARY,
				Related_Id__c = UserInfo.getUserId(),
				User_Id__c = UserInfo.getUserId(),
				Related_Object_Type__c = 'User',
				Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST
		);
	}

	@IsTest
	private static void test_case_1() {
		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_1', 'hash3_3'));
		logs.add(createPharosLog('hash1_4', 'hash2_2', 'hash3_4'));
		insert logs;
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c = NULL]);
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c != NULL]);
	}

	@IsTest
	private static void test_case_2() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		Issue__c issue = [SELECT Id, Status__c FROM Issue__c LIMIT 1];
		issue.Status__c = 'Completed';
		update issue;
		insert new List<Log__c>{createPharosLog('hash1_2', 'hash2_1', 'hash3_1'),createPharosLog('hash1_3', 'hash2_2', 'hash3_1')};
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c = NULL]);
	}

	@IsTest
	private static void test_case_3() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.enableMaxIssues(0);
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		Issue__c issue = [SELECT Id, Status__c FROM Issue__c LIMIT 1];
		issue.Status__c = 'Completed';
		update issue;
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_2');
		List<Issue__c> issues = [SELECT Id, Regression__c, Regressed_On__c FROM Issue__c WHERE Regressed_On__c != NULL];
		System.assertEquals(1, issues.size());
		System.assertEquals(true, issues.get(0).Regression__c);
	}

	@IsTest
	private static void test_case_4() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		Issue__c issue = [SELECT Id, Status__c FROM Issue__c LIMIT 1];
		Issue__c completedIssue = issue.clone();
		completedIssue.Status__c = 'Completed';
		insert completedIssue;
		insert createPharosLog('hash1_1', 'hash2_2', 'hash3_2');
		System.assertEquals(0, [SELECT COUNT() FROM Issue__c WHERE Regressed_On__c != NULL]);
	}

	@IsTest
	private static void test_delete_issue() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.enableMaxIssues(0);
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		logs.add(createPharosLog('hash1_4', 'hash2_4', 'hash3_4'));
		logs.add(createPharosLog('hash1_5', 'hash2_5', 'hash3_5'));
		insert logs;
		List<Issue__c> issues = [SELECT Id, Status__c, Related_Issue__c, Log__r.Hash_1__c FROM Issue__c];
		Map<String, Issue__c> mapIssuesByHash = new Map<String, Issue__c>();
		for (Issue__c issue : issues) {
			mapIssuesByHash.put(issue.Log__r.Hash_1__c, issue);
		}
		for (Issue__c issue : issues) {
			if (issue.Log__r.Hash_1__c == 'hash1_1') {
				issue.Related_Issue__c = null;
			} else if (issue.Log__r.Hash_1__c == 'hash1_2') {
				issue.Related_Issue__c = mapIssuesByHash.get('hash1_1').Id;
			} else if (issue.Log__r.Hash_1__c == 'hash1_3') {
				issue.Related_Issue__c = mapIssuesByHash.get('hash1_2').Id;
			} else if (issue.Log__r.Hash_1__c == 'hash1_4') {
				issue.Related_Issue__c = mapIssuesByHash.get('hash1_2').Id;
				issue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
			} else if (issue.Log__r.Hash_1__c == 'hash1_5') {
				issue.Related_Issue__c = mapIssuesByHash.get('hash1_2').Id;
				issue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
			}
		}
		update issues;
		delete [SELECT Id FROM Log__c WHERE Hash_1__c = 'hash1_2'];
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Related_Issue__c = NULL]);
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c WHERE Status__c = :IssueService.ISSUE_STATUS_DUPLICATE]);
	}

	@IsTest
	private static void test_delete_content_documents() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		ContentVersion contentVersion = new ContentVersion();
		contentVersion.PathOnClient = 'test.json';
		contentVersion.VersionData = Blob.valueOf('Test');
		contentVersion.Description = 'test';
		contentVersion.ContentLocation = 'S';
		contentVersion.IsMajorVersion = true;
		insert contentVersion;
		List<ContentVersion> contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id AND IsLatest = TRUE];
		ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
		contentDocumentLink.ContentDocumentId = contentVersions[0].ContentDocumentId;
		contentDocumentLink.LinkedEntityId = issues[0].Id;
		contentDocumentLink.ShareType = 'I';
		insert contentDocumentLink;
		delete issues;
		System.assertEquals(0, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(0, [SELECT COUNT() FROM ContentVersion]);
		System.assertEquals(0, [SELECT COUNT() FROM ContentDocument]);
	}

	@IsTest
	private static void test_delete_log_and_update_issue() {
		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		insert logs;
		System.assertEquals(4, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		delete [SELECT Id FROM Log__c LIMIT 2];
		System.assertEquals(2, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
	}

	@IsTest
	private static void test_delete_related_records_on_issue_delete() {
		Issue__c issue1 = TraceServiceTest.createIssue();
        Trace_Schedule__c schedule1 = TraceServiceTest.createTraceSchedule(issue1.Id);
        Trace_Request__c traceRequest1 = TraceServiceTest.createTraceRequest(true, false, schedule1.Id);
        insert traceRequest1;

		Trace_Result__c traceResult1 = TraceServiceTest.createTraceResult(issue1.Id, traceRequest1.Id, schedule1.Id);
		insert traceResult1;
		ContentDocumentLink cdl1 = TraceServiceTest.createTraceResultCV(traceResult1.Id);

		Test.startTest();
		delete issue1;
		Test.stopTest();

		List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Id = :issue1.Id LIMIT 1];
		System.assertEquals(0, issues.size());

		List<Trace_Schedule__c> schedules = [SELECT Id FROM Trace_Schedule__c WHERE Id = :schedule1.Id LIMIT 1];
		System.assertEquals(0, schedules.size());

		List<Trace_Request__c> requests = [SELECT Id FROM Trace_Request__c WHERE Id = :traceRequest1.Id LIMIT 1];
		System.assertEquals(0, requests.size());

		List<Trace_Result__c> results = [SELECT Id FROM Trace_Result__c WHERE Id = :traceResult1.Id LIMIT 1];
		System.assertEquals(0, results.size());

		List<ContentDocumentLink> cvs = [SELECT Id FROM ContentDocumentLink WHERE Id = :cdl1.Id LIMIT 1];
		System.assertEquals(0, cvs.size());
	}

	@IsTest
	private static void test_max_issues_1_enabled() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.enableMaxIssues(1);
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		insert createPharosLog('hash1_2', 'hash2_2', 'hash3_2');
		insert createPharosLog('hash1_3', 'hash2_3', 'hash3_3');
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs;
		System.assertEquals(1, [SELECT COUNT() FROM Issue__c]);
	}

	private static void fillTestOffset() {
		Savepoint sp = Database.setSavepoint();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		List<Issue__c> issues = [SELECT Id, Name FROM Issue__c];
		if (!issues.isEmpty()) {
			BlurModeService.TEST_OFFSET = IssueService.getHighestIssueNumber(issues);
		}
		Database.rollback(sp);
	}

	@IsTest
	private static void test_max_issues_2_enabled() {
		TestDataFactory.enableIssueTracking();
		fillTestOffset();
		TestDataFactory.enableMaxIssues(2);
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs;
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(1, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		List<Log__c> logs2 = new List<Log__c>();
		logs2.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs2.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs2.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs2;
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(2, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		List<Log__c> logs3 = new List<Log__c>();
		logs3.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs3.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs3.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs3;
		System.assertEquals(2, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(3, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
	}

	@IsTest
	private static void test_max_issues_disable_to_enable() {
		TestDataFactory.enableIssueTracking();
		fillTestOffset();
		TestDataFactory.enableMaxIssues(0);
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs;
		System.assertEquals(3, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(1, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		List<Log__c> logs2 = new List<Log__c>();
		logs2.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs2.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs2.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs2;
		System.assertEquals(3, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(2, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		List<Log__c> logs3 = new List<Log__c>();
		logs3.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs3.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs3.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs3;
		System.assertEquals(3, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(3, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		TestDataFactory.enableMaxIssues(3);
		List<Log__c> logs4 = new List<Log__c>();
		logs4.add(createPharosLog('hash1_4', 'hash2_4', 'hash3_4'));
		insert logs4;
		System.assertEquals(3, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(3, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
	}

	@IsTest
	private static void test_max_issues_disable_and_delete_to_enable() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.enableMaxIssues(0);
		List<Log__c> logs = new List<Log__c>();
		logs.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs;
		System.assertEquals(3, [SELECT COUNT() FROM Issue__c]);
		System.assertEquals(1, [SELECT Id, Log_Count__c FROM Issue__c][0].Log_Count__c);
		TestDataFactory.enableMaxIssues(3);
		fillTestOffset();
		delete [SELECT Id FROM Issue__c];
		List<Log__c> logs2 = new List<Log__c>();
		logs2.add(createPharosLog('hash1_1', 'hash2_1', 'hash3_1'));
		logs2.add(createPharosLog('hash1_2', 'hash2_2', 'hash3_2'));
		logs2.add(createPharosLog('hash1_3', 'hash2_3', 'hash3_3'));
		insert logs2;
		System.assertEquals(0, [SELECT COUNT() FROM Issue__c]);
	}

}