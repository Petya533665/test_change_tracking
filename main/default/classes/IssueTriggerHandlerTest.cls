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

	@TestVisible
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

	@IsTest
	private static void test_skip_max_attempts_log() {
		TestDataFactory.enableIssueTracking();
		Log__c testLog = createPharosLog('hash_max_attempts', 'hash2', 'hash3');
		// Do not insert the log, as getMapLogsByHash operates on the input list directly
		List<Log__c> logs = new List<Log__c>{ testLog };

		Test.startTest();

		// Call 1: Counter becomes 1. Log should be included.
		Map<String, List<Log__c>> mapLogsByHash1 = IssueService.getMapLogsByHash(logs);
		System.assertEquals(1, mapLogsByHash1.size(), 'Log should be included on first pass');
		System.assert(mapLogsByHash1.containsKey('hash_max_attempts'), 'Map should contain the log hash on first pass');

		// Call 2: Counter becomes 2. Log should be included.
		Map<String, List<Log__c>> mapLogsByHash2 = IssueService.getMapLogsByHash(logs);
		System.assertEquals(1, mapLogsByHash2.size(), 'Log should be included on second pass');
		System.assert(mapLogsByHash2.containsKey('hash_max_attempts'), 'Map should contain the log hash on second pass');

		// Call 3: Counter becomes 3. Log should be skipped as LOG_ISSUE_TRACKER_MAX_ATTEMPTS is 2 (>= check).
		// Note: The IssueTrackerLogCounter uses Cache, which persists within a single transaction context in tests.
		Map<String, List<Log__c>> mapLogsByHash3 = IssueService.getMapLogsByHash(logs);
		System.assertEquals(0, mapLogsByHash3.size(), 'Log should be skipped on third pass due to max attempts');
		System.assert(!mapLogsByHash3.containsKey('hash_max_attempts'), 'Map should not contain the log hash on third pass');

		Test.stopTest();
	}

	@IsTest
	private static void test_skip_failed_log() {
		TestDataFactory.enableIssueTracking();
		Log__c testLog = createPharosLog('hash_failed', 'hash2', 'hash3');
		testLog.Issue_Tracker_Status__c = IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED;
		// Do not insert the log, as getMapLogsByHash operates on the input list directly
		List<Log__c> logs = new List<Log__c>{ testLog };

		Test.startTest();
		Map<String, List<Log__c>> mapLogsByHash = IssueService.getMapLogsByHash(logs);
		Test.stopTest();

		System.assertEquals(0, mapLogsByHash.size(), 'Map should be empty as the log has failed status');
		System.assert(!mapLogsByHash.containsKey('hash_failed'), 'Map should not contain the hash of the failed log');
	}

	@IsTest
	private static void test_empty_log_list() {
		TestDataFactory.enableIssueTracking();
		List<Log__c> logs = new List<Log__c>();

		Test.startTest();
		Map<String, List<Log__c>> mapLogsByHash = IssueService.getMapLogsByHash(logs);
		Test.stopTest();

		System.assert(mapLogsByHash != null, 'Map should not be null');
		System.assertEquals(0, mapLogsByHash.size(), 'Map should be empty for an empty input list');
	}

	@IsTest
	private static void test_blank_hash_log() {
		TestDataFactory.enableIssueTracking();
		Log__c testLog = createPharosLog(null, 'hash2', 'hash3'); // Blank Hash_1__c
		List<Log__c> logs = new List<Log__c>{ testLog };

		Test.startTest();
		Map<String, List<Log__c>> mapLogsByHash = IssueService.getMapLogsByHash(logs);
		Test.stopTest();

		System.assertEquals(0, mapLogsByHash.size(), 'Map should be empty as the log has a blank hash');
	}

	@IsTest
	private static void test_multiple_logs_same_hash_via_trigger() {
		TestDataFactory.enableIssueTracking();
		String commonHash = 'common_hash_trigger_test_' + Math.random(); // Unique hash per run

		// Create logs
		Log__c log1 = createPharosLog(commonHash, 'hash2_1', 'hash3_1');
		Log__c log2 = createPharosLog(commonHash, 'hash2_2', 'hash3_2');

		Test.startTest();
		// Insert logs together, triggering the handler once for the list
		insert new List<Log__c>{log1, log2};
		Test.stopTest();

		// Verify the outcome: One issue should be created for the common hash
		// The trigger calls getMapLogsByHash -> getMapIssuesByHash -> issueTracker
		// getMapLogsByHash increments counters for log1.Id and log2.Id to 1.
		// It returns a map { commonHash => [log1, log2] }.
		// getMapIssuesByHash prepares one new Issue__c record.
		// issueTracker upserts that one Issue__c.
		List<Issue__c> createdIssues = [SELECT Id, Key__c FROM Issue__c WHERE Key__c = :commonHash];
		System.assertEquals(1, createdIssues.size(), 'Exactly one issue should be created for the common hash via trigger when inserted together.');

		// We can also check the logs were linked to the issue
		List<Log__c> updatedLogs = [SELECT Id, Issue__c FROM Log__c WHERE Hash_1__c = :commonHash];
		System.assertEquals(2, updatedLogs.size(), 'Both logs should exist.');
		for(Log__c l : updatedLogs) {
			System.assertNotEquals(null, l.Issue__c, 'Log ' + l.Id + ' should be linked to an issue.');
			System.assertEquals(createdIssues[0].Id, l.Issue__c, 'Log ' + l.Id + ' should be linked to the created issue.');
		}
	}

	@IsTest
	private static void test_skip_failed_log_via_trigger() {
		TestDataFactory.enableIssueTracking();
		String failedHash = 'failed_hash_trigger_test_' + Math.random(); // Unique hash per run

		// Create a log marked as failed
		Log__c failedLog = createPharosLog(failedHash, 'hash2_failed', 'hash3_failed');
		failedLog.Issue_Tracker_Status__c = IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED;
		// Ensure post-processing is completed if needed for trigger condition
		failedLog.Post_Processing_Status__c = IssueService.POST_PROCESSING_STATUS_COMPLETED;
		// Mark as broadcast to meet one of the trigger conditions, or ensure it meets the update condition
		failedLog.Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST;

		Test.startTest();
		// Insert the failed log
		insert failedLog;
		Test.stopTest();

		// Verify the outcome: No issue should be created because the log was skipped
		// The trigger calls getMapLogsByHash.
		// Inside getMapLogsByHash, the check 'if (log?.Issue_Tracker_Status__c == LOG_ISSUE_TRACKER_STATUS_FAILED)' is true.
		// The log is skipped (continue statement).
		// getMapLogsByHash returns an empty map.
		// No issue is created.
		List<Issue__c> createdIssues = [SELECT Id FROM Issue__c WHERE Key__c = :failedHash];
		System.assertEquals(0, createdIssues.size(), 'No issue should be created for a log inserted with Failed status.');

		// Verify the log itself was inserted but not linked
		List<Log__c> insertedLogs = [SELECT Id, Issue__c, Issue_Tracker_Status__c FROM Log__c WHERE Hash_1__c = :failedHash];
		System.assertEquals(1, insertedLogs.size(), 'The failed log should still be inserted.');
		System.assertEquals(null, insertedLogs[0].Issue__c, 'Failed log should not be linked to any issue.');
		System.assertEquals(IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED, insertedLogs[0].Issue_Tracker_Status__c, 'Log status should remain Failed.');
	}

	@IsTest
	private static void test_issue_upsert_failure_marks_log_failed_via_forced_exception() {
		TestDataFactory.enableIssueTracking();
		String uniqueHash = 'issue_upsert_forced_fail_test_';

		// Create a standard log that *would* normally create an issue
		Log__c logToFail = createPharosLog(uniqueHash, 'hash2_force_fail', 'hash3_force_fail');
		// Ensure the log meets trigger criteria to be processed
		logToFail.Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST;
		logToFail.Post_Processing_Status__c = IssueService.POST_PROCESSING_STATUS_COMPLETED;

		// Force the exception
		IssueTriggerHandler.throwDmlExceptionForTest = true;

		try {
			Test.startTest();
			// Insert the log. This triggers LogTrigger -> LogTriggerHandler -> IssueService flow.
			// 1. getMapLogsByHash processes the log.
			// 2. getMapIssuesByHash creates an Issue__c SObject in memory.
			// 3. issueTracker is called.
			// 4. The check 'if (throwDmlExceptionForTest)' is true, and a DmlException is thrown.
			// 5. *** ASSUMPTION FOR TEST ***: DatabaseUtils catches this exception via handleError,
			//    and getSuccessSObjects() returns an empty list.
			// 6. The logic identifies 'uniqueHash' as belonging to a failed Issue upsert (failedHashes set).
			// 7. The logic prepares an update for 'logToFail' setting Issue_Tracker_Status__c to Failed.
			// 8. The update DML for the Log__c record is performed.
			
			insert logToFail;
			Test.stopTest();
		}
		finally {
			IssueTriggerHandler.throwDmlExceptionForTest = false;
		}

		// 1. Verify no Issue was actually created with this hash
		List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Key__c = :uniqueHash];
		System.assertEquals(0, issues.size(), 'No Issue record should have been created due to the forced DML exception.');

		// 2. Verify the Log record was updated correctly
		List<Log__c> logs = [SELECT Id, Issue__c, Issue_Tracker_Status__c FROM Log__c WHERE Id = :logToFail.Id];
		System.assertEquals(1, logs.size(), 'The Log record should still exist.');
		Log__c resultLog = logs[0];
		System.assertEquals(null, resultLog.Issue__c, 'Log should not be linked to any Issue.');
		System.assertEquals(IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED, resultLog.Issue_Tracker_Status__c,
				'Log\'s Issue_Tracker_Status__c should be updated to Failed after forced exception.');
	}
}