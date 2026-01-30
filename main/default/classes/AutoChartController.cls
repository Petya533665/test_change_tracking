public with sharing class AutoChartController {

    public static Map<String, Object> getAutoChartSetting() {
        Map<String, Object> autoChartSetting = new Map<String, Object> {
            'isEnableNotificationCharts' => ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c
        };

        return autoChartSetting;
    }

    public static String  updateAutoChartSetting(String autoChartSettingJSON) {
        Map<String, Object> autoChartSetting = (Map<String, Object>) JSON.deserializeUntyped(autoChartSettingJSON);
        ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c = (Boolean) autoChartSetting.get('isEnableNotificationCharts');

        Boolean isEnabledRemoteSiteSetting = ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c
            || ConfigUtil.PHAROS_SETTINGS.EnableForecast__c;

        if (isEnabledRemoteSiteSetting) {
            AdminService.upsertRemoteSiteSetting(
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME,
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_API_URL,
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_DESCRIPTION
            );
            AdminService.upsertRemoteSiteSetting(
                Constants.REMOTE_SITE_SETTINGS.SLACK_FILES_API_NAME,
                Constants.REMOTE_SITE_SETTINGS.SLACK_FILES_API_URL,
                Constants.REMOTE_SITE_SETTINGS.SLACK_FILES_DESCRIPTION
            );
        } else {
            MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(
                new List<String> {
                    ConfigUtil.prefixCurrentOrgNamespace(Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME),
                    ConfigUtil.prefixCurrentOrgNamespace(Constants.REMOTE_SITE_SETTINGS.SLACK_FILES_API_NAME)
                }
            );
        }

        upsert ConfigUtil.PHAROS_SETTINGS;

        autoChartSetting = new Map<String, Object> {
            'isEnableNotificationCharts' => ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c,
            'isUpdate' => true
        };

        return JSON.serialize(autoChartSetting);
    }
}