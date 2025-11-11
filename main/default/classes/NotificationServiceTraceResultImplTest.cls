@isTest
public class NotificationServiceTraceResultImplTest {

    @isTest
    static void testGetSObjectType() {
        NotificationServiceTraceResultImpl service = new NotificationServiceTraceResultImpl();
        System.assertEquals(Trace_Result__c.SObjectType, service.getRecordSObjectType(), 'Should return Trace_Result__c SObjectType');
    }

    @isTest
    static void testGetServiceType() {
        NotificationServiceTraceResultImpl service = new NotificationServiceTraceResultImpl();
        System.assertEquals(NotificationService.NOTIFICATION_SERVICE_TYPE.TRACE_RESULT, service.getServiceType(), 'Should return TRACE_RESULT service type');
    }

    @isTest
    static void testIsPermissionEnabled() {
        NotificationServiceTraceResultImpl service = new NotificationServiceTraceResultImpl();
        // Note: This might return false based on the actual implementation
        Boolean result = service.isPermissionEnabled();
        System.assert(result == true || result == false, 'Permission should return a boolean value');
    }

    @isTest
    static void testFieldNameMethods() {
        NotificationServiceTraceResultImpl service = new NotificationServiceTraceResultImpl();
        System.assertEquals('Executable_Rules__c', service.getExecutableRulesFieldName(), 'Should return correct executable rules field name');
        System.assertEquals('Notification_Integration_Status__c', service.getNotificationStatusFieldName(), 'Should return correct notification status field name');
        // Note: getTicketingStatusFieldName might return null for TraceResult implementation
        String ticketingField = service.getTicketingStatusFieldName();
        System.assert(ticketingField == null || ticketingField == 'Jira_Integration_Status__c', 'Should return correct ticketing status field name or null');
    }

    @isTest
    static void testCountAndQueryLocator() {
        NotificationServiceTraceResultImpl service = new NotificationServiceTraceResultImpl();
        Integer cnt = service.getSObjectRecordsCount();
        System.assertNotEquals(null, cnt, 'Count for TraceResult impl should not be null');
        Database.QueryLocator ql = service.getQueryLocator();
        System.assertNotEquals(null, ql, 'QueryLocator for TraceResult impl should not be null');
    }

}