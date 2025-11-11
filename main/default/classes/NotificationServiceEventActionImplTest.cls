@isTest
public class NotificationServiceEventActionImplTest {

    @isTest
    static void testGetSObjectType() {
        NotificationServiceEventActionImpl service = new NotificationServiceEventActionImpl();
        System.assertEquals(EventAction__c.SObjectType, service.getRecordSObjectType(), 'Should return EventAction__c SObjectType');
    }

    @isTest
    static void testGetServiceType() {
        NotificationServiceEventActionImpl service = new NotificationServiceEventActionImpl();
        System.assertEquals(NotificationService.NOTIFICATION_SERVICE_TYPE.EVENT_ACTION, service.getServiceType(), 'Should return EVENT_ACTION service type');
    }

    @isTest
    static void testIsPermissionEnabled() {
        NotificationServiceEventActionImpl service = new NotificationServiceEventActionImpl();
        System.assertEquals(true, service.isPermissionEnabled(), 'Permission should be enabled by default');
    }

    @isTest
    static void testFieldNameMethods() {
        NotificationServiceEventActionImpl service = new NotificationServiceEventActionImpl();
        System.assertEquals('Executable_Rules__c', service.getExecutableRulesFieldName(), 'Should return correct executable rules field name');
        System.assertEquals('Notification_Integration_Status__c', service.getNotificationStatusFieldName(), 'Should return correct notification status field name');
        System.assertEquals('Jira_Integration_Status__c', service.getTicketingStatusFieldName(), 'Should return correct ticketing status field name');
    }

    @isTest
    static void testGetActionIterationsNonAutoChart() {
        NotificationServiceEventActionImpl service = new NotificationServiceEventActionImpl();

        EventAction__c evt = new EventAction__c();
        Action__c act = new Action__c(Subject__c = 'Subject without charts', Body__c = 'Plain body');
        evt.Action__r = act; // unsaved related action is enough for method logic
        evt.Action__c = 'a01xx0000000001AAA';
        evt.Action_Type__c = Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION;

        List<NotificationService.ActionIteration> iters = service.getActionIterations(evt);
        System.assertEquals(1, iters.size(), 'Should produce one standard iteration');
        System.assertEquals(2, iters[0].totalIterations, 'Total iterations should account for precalc + 1');
        System.assertEquals(Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION, iters[0].actionType, 'Action type should propagate');
        System.assertEquals(evt.Action__c, iters[0].actionId, 'Action id should propagate');
    }

}