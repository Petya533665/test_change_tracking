@IsTest
private class IssueRelatedObjectsControllerTest {

	@TestSetup
	private static void testSetup() {
		TestDataFactory.createConnectedOrg();
	}

	private static Log__c createPharosLog(String hash1, String hash2, String hash3, String userName, String relatedObjects) {
		return new Log__c(
				Hash_1__c = hash1,
				Hash_2__c = hash2,
				Hash_3__c = hash3,
				Category__c = IssueTriggerHandler.FLOW_CATEGORY,
				Details__c = 'test description',
				Summary__c = 'test summary',
				Related_Id__c = UserInfo.getUserId(),
				User_Name__c = userName,
				User_Id__c = UserInfo.getUserId(),
				Related_Object_Type__c = 'User',
				Related_Objects__c = relatedObjects,
				Organization_Id__c = UserInfo.getOrganizationId().left(15),
				Originated_From__c = IssueService.ORIGINATED_FROM_BROADCAST
		);
	}

	@IsTest
	private static void test_RelatedObjects_Users_positive() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', UserInfo.getName(), null);
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', UserInfo.getName(), null);
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		List<IssueRelatedObjectsController.RelatedObject> relatedObjects = IssueRelatedObjectsController.getRelatedObjects(issues[0].Id, 'Users', JSON.serialize(IssueRelatedObjectsController.getChunkProperties(issues[0].Id)[0]));
		System.assertNotEquals(relatedObjects, null);
		System.assertEquals(1, relatedObjects.size());
	}

	@IsTest
	private static void test_RelatedObjects_Users_negative() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, null);
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, null);
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		List<IssueRelatedObjectsController.RelatedObject> relatedObjects = IssueRelatedObjectsController.getRelatedObjects(issues[0].Id, 'Users', JSON.serialize(IssueRelatedObjectsController.getChunkProperties(issues[0].Id)[0]));
		System.assertNotEquals(relatedObjects, null);
		System.assertEquals(0, relatedObjects.size());
	}

	@IsTest
	private static void test_RelatedObjects_Objects_positive() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, '{"Account:Account":["0015e00000XXXXXXXX"]}');
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, '{"Contact:Contact":["0035e00000XXXXXXXX"]}');
		List<Issue__c> issues = [SELECT Id FROM Issue__c];
		List<IssueRelatedObjectsController.RelatedObject> relatedObjects = IssueRelatedObjectsController.getRelatedObjects(issues[0].Id, 'Objects', JSON.serialize(IssueRelatedObjectsController.getChunkProperties(issues[0].Id)[0]));
		System.assertNotEquals(relatedObjects, null);
		System.assertEquals(2, relatedObjects.size());
	}

	@IsTest
	private static void test_RelatedObjects_Objects_negative() {
		TestDataFactory.enableIssueTracking();
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, null);
		insert createPharosLog('hash1_1', 'hash2_1', 'hash3_1', null, null);
		List<Issue__c> issues = [SELECT Id, Key__c, Log__c FROM Issue__c];
		List<IssueRelatedObjectsController.RelatedObject> relatedObjects = IssueRelatedObjectsController.getRelatedObjects(issues[0].Id, 'Objects', JSON.serialize(IssueRelatedObjectsController.getChunkProperties(issues[0].Id)[0]));
		System.assertNotEquals(relatedObjects, null);
		System.assertEquals(0, relatedObjects.size());
	}

}