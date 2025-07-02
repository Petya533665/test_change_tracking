public with sharing class ApexEmailNotificationService {

    public static String createApexEmailNotification(Map<String, Object> apexEmailNotificationData) {
        if (!apexEmailNotificationData.containsKey('UserId')) {
            apexEmailNotificationData.put('UserId', '');
        }
        
        return HttpUtils.post(
            ConfigUtil.TOOLING_API_CREATE_APEX_EMAIL_NOTIFICATION,
            JSON.serialize(apexEmailNotificationData),
            ConfigUtil.getToolingHeaders(),
            201
        );
    }

    public static String updateApexEmailNotification(ApexEmailNotification apexEmailNotification, Map<String, Object> apexEmailNotificationData) {
        return HttpUtils.post(
            ConfigUtil.TOOLING_API_UPDATE_APEX_EMAIL_NOTIFICATION + apexEmailNotification.Id + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
            JSON.serialize(apexEmailNotificationData),
            ConfigUtil.getToolingHeaders(),
            204
        );
    }
}