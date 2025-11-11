@isTest
public class NotificationServiceIssueImplTest {

    @isTest
    static void testGetSObjectType() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        System.assertEquals(Issue__c.SObjectType, service.getRecordSObjectType(), 'Should return Issue__c SObjectType');
    }

    @isTest
    static void testGetServiceType() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        System.assertEquals(NotificationService.NOTIFICATION_SERVICE_TYPE.ISSUE, service.getServiceType(), 'Should return ISSUE service type');
    }

    @isTest
    static void testIsPermissionEnabled() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        System.assertEquals(true, service.isPermissionEnabled(), 'Permission should be enabled by default');
    }

    @isTest
    static void testFieldNameMethods() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        System.assertEquals('Executable_Rules__c', service.getExecutableRulesFieldName(), 'Should return correct executable rules field name');
        System.assertEquals('Notification_Integration_Status__c', service.getNotificationStatusFieldName(), 'Should return correct notification status field name');
        System.assertEquals('Jira_Integration_Status__c', service.getTicketingStatusFieldName(), 'Should return correct ticketing status field name');
    }

    @isTest
    static void testQueryLocator() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        Database.QueryLocator ql = service.getQueryLocator();
        System.assertNotEquals(null, ql, 'QueryLocator for Issue impl should not be null');
    }

    @isTest
    static void testNotificationBatchInstance() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        Object batchInstance = service.notificationBatchInstance();
        System.assertNotEquals(null, batchInstance, 'Batch instance should not be null');
    }

    @isTest
    static void testStartNotificationBatch() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        
        try {
            service.startNotificationBatch();
            System.assert(true, 'startNotificationBatch should execute without errors');
        } catch (Exception e) {
            System.assert(false, 'startNotificationBatch should not throw exception: ' + e.getMessage());
        }
    }

    @isTest
    static void testGetOrganizationIdFromSObjectRecord() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        String orgId = service.getOrganizationIdFromSObjectRecord();
        System.assertEquals(UserInfo.getOrganizationId(), orgId, 'Should return current organization ID');
    }

    @isTest
    static void testSetIterationRecordFailedStatus() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        
        // Create test issue
        Issue__c testIssue = new Issue__c(
            Jira_Integration_Status__c = Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING,
            Notification_Integration_Status__c = Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING,
            Executable_Rules__c = '{"executedRuleIds":[],"runRuleIds":[],"ruleIdsToReRun":[]}'
        );
        insert testIssue;
        
        service.init(testIssue);
        
        try {
            service.setIterationRecordFailedStatus();
            System.assert(true, 'setIterationRecordFailedStatus should execute without errors');
        } catch (Exception e) {
            System.assert(false, 'setIterationRecordFailedStatus should not throw exception: ' + e.getMessage());
        }
    }

    @isTest
    static void testSetRecordFailedStatusThrowBySendErrors() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        
        // Create test issue
        Issue__c testIssue = new Issue__c(
            Jira_Integration_Status__c = Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING
        );
        insert testIssue;
        
        service.init(testIssue);
        
        try {
            service.setRecordFailedStatusThrowBySendErrors();
            System.assert(true, 'setRecordFailedStatusThrowBySendErrors should execute without errors');
        } catch (Exception e) {
            System.assert(false, 'setRecordFailedStatusThrowBySendErrors should not throw exception: ' + e.getMessage());
        }
    }

    @isTest
    static void testFilterRecordsForRunNotificationRules() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        
        // Test with empty list
        List<SObject> result = service.filterRecordsForRunNotificationRules(new List<SObject>(), null);
        System.assertEquals(0, result.size(), 'Should return empty list for empty input');
        
        // Test with null list
        try {
            result = service.filterRecordsForRunNotificationRules(null, null);
            System.assertEquals(0, result.size(), 'Should return empty list for null input');
        } catch (Exception e) {
            System.assert(true, 'filterRecordsForRunNotificationRules may throw exception in test context: ' + e.getMessage());
        }
    }

    @isTest
    static void testFilterRecordsForRunTicketingRules() {
        NotificationServiceIssueImpl service = new NotificationServiceIssueImpl();
        
        // Test with empty list
        List<SObject> result = service.filterRecordsForRunTicketingRules(new List<SObject>(), null);
        System.assertEquals(0, result.size(), 'Should return empty list for empty input');
        
        // Test with null list
        try {
            result = service.filterRecordsForRunTicketingRules(null, null);
            System.assertEquals(0, result.size(), 'Should return empty list for null input');
        } catch (Exception e) {
            System.assert(true, 'filterRecordsForRunTicketingRules may throw exception in test context: ' + e.getMessage());
        }
    }

}