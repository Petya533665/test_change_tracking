@IsTest
public class IssueRelatedListControllerTest {

	@TestVisible
	private static Log__c createPharosLog(String hash1, String hash2, String hash3) {
		return new Log__c(
				Hash_1__c = hash1,
				Hash_2__c = hash2,
				Hash_3__c = hash3,
				Category__c = IssueTriggerHandler.FLOW_CATEGORY,
				Details__c = 'test description',
				Summary__c = 'test summary',
				Related_Id__c = UserInfo.getUserId(),
				User_Id__c = UserInfo.getUserId(),
				Related_Object_Type__c = 'User',
				Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST
		);
	}

	@IsTest
	private static void test_getDataTable() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		insert createPharosLog('hash1_2', 'hash2_2', 'hash3_2');
		List<Issue__c> issues = [SELECT Id, Related_Issue__c FROM Issue__c];
		if (!issues.isEmpty() && issues.size() > 1) {
			issues[1].Related_Issue__c = issues[0].Id;
			update issues;
		}
		IssueRelatedListController.DataTable dataTable = IssueRelatedListController.getDataTable(issues[0].Id, 'Name,Status__c');
		System.assertNotEquals(dataTable, null);
		System.assertEquals(1, dataTable.childData[0].Related_Issues__r.size());

	}

	@IsTest
	private static void test_getDataTable_withoutRelated() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		List<Issue__c> issues = [SELECT Id, Related_Issue__c FROM Issue__c];
		if (!issues.isEmpty() && issues.size() > 1) {
			issues[1].Related_Issue__c = issues[0].Id;
			update issues;
		}
		if (!issues.isEmpty()) {
			IssueRelatedListController.DataTable dataTable = IssueRelatedListController.getDataTable(issues[0].Id, 'Name,Status__c');
			System.assertNotEquals(dataTable, null);
			System.assertEquals(0, dataTable.childData[0].Related_Issues__r.size());
		}
	}

}