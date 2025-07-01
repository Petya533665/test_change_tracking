public with sharing class ApexEmailNotificationService {

    public static ApexEmailNotificationWrapper getApexEmailNotificationResult() {
        ApexEmailNotificationWrapper result;
        
        String b = getApexEmailNotification();

        Map<String, Object> respResults = (Map<String, Object>)JSON.deserializeUntyped(b);
        if (respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS) != null) {
            List<ApexEmailNotificationWrapper> apexEmailNotificationWrappers = (List<ApexEmailNotificationWrapper>)JSON.deserialize(
                JSON.serialize(respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS)),
                List<ApexEmailNotificationWrapper>.class
            );

            if (!apexEmailNotificationWrappers.isEmpty()) {
                result = apexEmailNotificationWrappers.get(0);
            }
        }
        
        return result;
    }

    public static String getApexEmailNotification() {
        return HttpUtils.get(
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_EMAIL_APEX_EMAIL_NOTIFICATION,
            ConfigUtil.getToolingHeaders(),
            200
        );
    }

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

    public static String updateApexEmailNotification(ApexEmailNotificationWrapper apexEmailNotification, Map<String, Object> apexEmailNotificationData) {
        return HttpUtils.post(
            ConfigUtil.TOOLING_API_UPDATE_APEX_EMAIL_NOTIFICATION + apexEmailNotification.Id + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
            JSON.serialize(apexEmailNotificationData),
            ConfigUtil.getToolingHeaders(),
            204
        );
    }
    
    public class ApexEmailNotificationWrapper {
        public String Id;
        public String Email;
    }
}