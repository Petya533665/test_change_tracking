public with sharing class ApexEmailNotificationSelector {

    public ApexEmailNotification getApexEmailNotification() {
        List<ApexEmailNotification> apexEmailNotifications = getApexEmailNotifications();
        return !apexEmailNotifications.isEmpty() ? apexEmailNotifications.get(0) : null;
    }
    
    private List<ApexEmailNotification> getApexEmailNotifications() {
        return [
            SELECT Id, Email
            FROM ApexEmailNotification
        ];
    }
}