@IsTest
public class LogTriggerHandlerTest {

	@IsTest
	private static void test_create_new_issue() {
		TestDataFactory.enableIssueTracking();
		Log__c newLog = createPharosLog(TEST_HASH1_1);

		Test.startTest();
		insert newLog;
		Test.stopTest();

		newLog = [SELECT Id, Issue__c, Issue__r.Key__c, Issue__r.Status__c,
				Issue__r.Description__c, Issue__r.First_Occurred_On__c,
				Issue__r.Log_Count__c, Issue__r.Priority__c, Issue__r.Summary__c
		FROM Log__c WHERE Id =: newLog.Id LIMIT 1];
		System.assertNotEquals(null, newLog.Issue__c);
		System.assertNotEquals(null, newLog.Issue__r.Key__c);
		System.assertNotEquals(null, newLog.Issue__r.Status__c);
		System.assertNotEquals(null, newLog.Issue__r.Description__c);
		System.assertNotEquals(null, newLog.Issue__r.First_Occurred_On__c);
		System.assertNotEquals(null, newLog.Issue__r.Log_Count__c);
		System.assertNotEquals(null, newLog.Issue__r.Priority__c);
		System.assertNotEquals(null, newLog.Issue__r.Summary__c);
	}

	@IsTest
	private static void test_link_to_parent_issue() {
		TestDataFactory.enableIssueTracking();
		Log__c newLog = createPharosLog(TEST_HASH1_1);
		insert newLog;

		Issue__c issue = createIssue(newLog.Id, TEST_HASH1_2);
		insert issue;
		issue.Related_Issue__c = [SELECT Issue__c FROM Log__c WHERE Id =:newLog.Id LIMIT 1].Issue__c;
		update issue;

		Log__c newLog2 = createPharosLog(TEST_HASH1_2);

		Test.startTest();
		insert newLog2;
		Test.stopTest();

		newLog2 = [SELECT Id, Issue__c, Issue__r.Key__c, Issue__r.Status__c,
				Issue__r.Description__c, Issue__r.First_Occurred_On__c,
				Issue__r.Log_Count__c, Issue__r.Priority__c, Issue__r.Summary__c
		FROM Log__c WHERE Id =: newLog2.Id LIMIT 1];
		System.assertNotEquals(null, newLog2.Issue__c);
		System.assertNotEquals(null, newLog2.Issue__r.Key__c);
		System.assertNotEquals(null, newLog2.Issue__r.Status__c);
		System.assertNotEquals(null, newLog2.Issue__r.Description__c);
		System.assertNotEquals(null, newLog2.Issue__r.First_Occurred_On__c);
		System.assertNotEquals(null, newLog2.Issue__r.Log_Count__c);
		System.assertNotEquals(null, newLog2.Issue__r.Priority__c);
		System.assertNotEquals(null, newLog2.Issue__r.Summary__c);
	}

	@IsTest
	private static void test_issue_re_open_duplicate() {
		TestDataFactory.enableIssueTracking();
		Test.startTest();
		Log__c newLog = createPharosLog(TEST_HASH1_1);
		Log__c newLog2 = createPharosLog(TEST_HASH1_2);
		insert new List<Log__c>{newLog, newLog2};

		Issue__c issue = [SELECT Id, Status__c FROM Issue__c WHERE Key__c = :TEST_HASH1_1];
		issue.Status__c = IssueService.ISSUE_STATUS_COMPLETED;
		Issue__c issue2 = [SELECT Id, Status__c, Related_Issue__c FROM Issue__c WHERE Key__c = :TEST_HASH1_2];
		issue2.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
		issue2.Related_Issue__c = issue.Id;
		update new List<Issue__c>{issue, issue2};

		Log__c newLog3 = createPharosLog(TEST_HASH1_2);
		insert newLog3;
		Test.stopTest();

		newLog3 = [SELECT Id, Issue__c, Issue__r.Key__c, Issue__r.Status__c,
				Issue__r.Description__c, Issue__r.First_Occurred_On__c,
				Issue__r.Log_Count__c, Issue__r.Priority__c, Issue__r.Summary__c,
				Issue__r.Related_Issue__c, Issue__r.Regression__c, Issue__r.Regressed_On__c
		FROM Log__c WHERE Id =: newLog3.Id LIMIT 1];
		System.assertNotEquals(null, newLog3.Issue__c);
		System.assertNotEquals(null, newLog3.Issue__r.Key__c);
		System.assertNotEquals(null, newLog3.Issue__r.Status__c);
		System.assertNotEquals(null, newLog3.Issue__r.Description__c);
		System.assertNotEquals(null, newLog3.Issue__r.First_Occurred_On__c);
		System.assertNotEquals(null, newLog3.Issue__r.Log_Count__c);
		System.assertNotEquals(null, newLog3.Issue__r.Priority__c);
		System.assertNotEquals(null, newLog3.Issue__r.Summary__c);
		System.assertEquals(true, newLog3.Issue__r.Regression__c);
		System.assertEquals(IssueService.ISSUE_STATUS_NEW, newLog3.Issue__r.Status__c);
	}

	@IsTest
	private static void test_issue_update_log_lookup() {
		TestDataFactory.enableIssueTracking();
		Test.startTest();
		Log__c newLog1 = createPharosLog(TEST_HASH1_1);
		Log__c newLog2 = createPharosLog(TEST_HASH1_1);
		insert newLog1;
		insert newLog2;
		System.assertEquals(newLog1.Id, [SELECT Id, Log__c FROM Issue__c WHERE Key__c = :TEST_HASH1_1][0].Log__c);
		delete newLog1;
		System.assertEquals(newLog2.Id, [SELECT Id, Log__c FROM Issue__c WHERE Key__c = :TEST_HASH1_1][0].Log__c);
		Test.stopTest();
	}

	private static final String TEST_HASH1_1 = '12312312';
	private static final String TEST_HASH1_2 = '123123123';
	private static final String TEST_ISSUE_DESCRIPTION = 'some error';
	private static final String TEST_ISSUE_PRIORITY = 'Medium';
	private static final String TEST_ISSUE_STATUS = 'New';
	private static final String TEST_ISSUE_SUMMARY = 'some error';

	public static Issue__c createIssue(Id logId, String hash1) {
		return new Issue__c(
				Description__c = TEST_ISSUE_DESCRIPTION,
				First_Occurred_On__c = Datetime.now(),
				Last_Occurred_On__c = Datetime.now(),
				Key__c = hash1,
				Log_Count__c = 1,
				Log__c = logId,
				Priority__c = TEST_ISSUE_PRIORITY,
				Status__c = TEST_ISSUE_STATUS,
				Summary__c = TEST_ISSUE_SUMMARY
		);
	}

	public static Log__c createPharosLog(String hash1) {
		return new Log__c(
				Hash_1__c = hash1,
				Details__c = TEST_ISSUE_DESCRIPTION,
				Summary__c = TEST_ISSUE_SUMMARY,
				Related_Id__c = UserInfo.getUserId(),
				User_Id__c = UserInfo.getUserId(),
				Related_Object_Type__c = 'User',
				Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST
		);
	}

}