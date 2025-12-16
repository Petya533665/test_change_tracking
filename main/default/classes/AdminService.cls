public without sharing class AdminService {

    /**
     * Email Services Address records query class
     */
    public static EmailServicesSelector emailServicesSelector = new EmailServicesSelector();

    public static User getUserInfo() {
        User user = new User();
        user.FirstName = UserInfo.getFirstName();
        user.LastName = UserInfo.getLastName();
        user.Email = UserInfo.getUserEmail();
        user.CompanyName = UserInfo.getOrganizationName();
        return user;
    }

    public static Map<String, Boolean> isMyDomainEnabled() {
        Map<String, Boolean> output = new Map<String, Boolean>();
        Boolean enabled = URL.getOrgDomainUrl().getHost().endsWith(Constants.GLOBAL_VARIABLE.SALESFORCE_DOMAIN) || URL.getOrgDomainUrl().getHost().contains(Constants.GLOBAL_VARIABLE.CUSTOM_DOMAIN_SYMBOLS);
        output.put('enabled', enabled);
        return output;
    }

    public static String getUrlToPlatformEventSubscriberConfigLogEvent() {
        return new PlatformEventSubscriberConfigService(Log_Event__e.SObjectType).getUrlToPlatformEventSubscriberConfig();
    }

    public static String getUrlToPlatformEventSubscriberConfigAIEvent() {
        return new PlatformEventSubscriberConfigService(AI_Event__e.SObjectType).getUrlToPlatformEventSubscriberConfig();
    }

    public static List<User> getAdminActiveUsers() {
        return [
            Select Id, Name, Profile.UserLicense.LicenseDefinitionKey
            From User
            Where IsActive = true AND Profile.UserLicense.LicenseDefinitionKey = 'SFDC'
        ];
    }

    public static List<MergeField> addCustomMergeFields(Schema.DescribeSObjectResult d, String dType) {
        List<MergeField> result = new List<MergeField>();
        String linkLabel =  d.getLabel() + ' Link';
        String linkApiName = '{!' + d.getName() + '.Link}';
        result.add(new MergeField(linkLabel, linkApiName, dType, 'link', true));

        if (d.getName() == Issue__c.SObjectType.getDescribe().getName()) {
            String analysisLabel =  'Advanced Analysis';
            String analysisApiName = '{!' + d.getName() + '.Analysis}';
            MergeField analysisField = new MergeField(analysisLabel, analysisApiName, dType, 'analysis', false);
            analysisField.setIsUpdateOnly(true);
            result.add(analysisField);
        }
        return result;
    }

    public static List<MergeField> getSobjectFields(Schema.DescribeSObjectResult d, String dType) {
        return getSobjectFields(d, dType, null, null, 0);
    }

    public static Boolean isStandardPreferencesField(Schema.DescribeFieldResult dfr) {
        if(dfr != null && !dfr.isCustom() && (dfr.getLocalName().startsWith('UserPreferences') || dfr.getLocalName().startsWith('EmailPreferences'))) {
            return true;
        }
        return false;
    }

    public static Map<String, String> getDefaultEmailActionTemplate() {
        return getDefaultNotificationsTemplate();
    }
    
    public static Map<String, String> getIssueDefaultEmailActionTemplate() {
        return getIssueDefaultNotificationsTemplate();
    }

    public static Map<String, String> getDefaultAzureDevOpsActionTemplate() {
        return Templates.LOG_SOBJECT.DEFAULT_JIRA_ACTION;
    }

    public static Map<String, String> getDefaultJiraActionTemplate() {
        return Templates.LOG_SOBJECT.DEFAULT_JIRA_ACTION;
    }

    public static Map<String, String> getIssueDefaultAzureDevOpsActionTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_JIRA_ACTION;
    }

    public static Map<String, String> getIssueDefaultJiraActionTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_JIRA_ACTION;
    }

    public static Map<String, String> getDefaultSlackActionTemplate() {
        return getDefaultNotificationsTemplate();
    }

    public static Map<String, String> getDefaultTeamsActionTemplate() {
        return getDefaultNotificationsTemplate();
    }

    public static Map<String, String> getDefaultNotificationsTemplate() {
        return Templates.LOG_SOBJECT.DEFAULT_NOTIFICATION;
    }

    public static Map<String, String> getTraceResultDefaultSlackActionTemplate() {
        return Templates.TRACE_RESULT_SOBJECT.DEFAULT_NOTIFICATION;
    }

    public static Map<String, String> getTraceResultDefaultTeamsActionTemplate() {
        return Templates.TRACE_RESULT_SOBJECT.DEFAULT_NOTIFICATION;
    }

    public static Map<String, String> getIssueDefaultSlackActionTemplate() {
        return getIssueDefaultNotificationsTemplate();
    }

    public static Map<String, String> getIssueDefaultTeamsActionTemplate() {
        return getIssueDefaultNotificationsTemplate();
    }

    public static Map<String, String> getIssueDefaultNotificationsTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_NOTIFICATION;
    }

    public static Map<String, String> getDefaultMonitoringActionTemplate() {
        return Templates.EVENT_SOBJECT.DEFAULT_MONITORING_ACTION;
    }

    public static Map<String, String> getIssueTicketCommentActionTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_TICKET_COMMENT_ACTION;
    }

    // Webhook template methods
    public static Map<String, String> getDefaultWebhookActionTemplate() {
        return Templates.LOG_SOBJECT.DEFAULT_WEBHOOK_ACTION;
    }

    public static Map<String, String> getIssueDefaultWebhookActionTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_WEBHOOK_ACTION;
    }

    public static Map<String, String> getIssueDefaultWebhookUpdateActionTemplate() {
        return Templates.ISSUE_SOBJECT.DEFAULT_WEBHOOK_UPDATE_ACTION;
    }

    public static Map<String, String> getDefaultMonitoringWebhookActionTemplate() {
        return Templates.EVENT_SOBJECT.DEFAULT_WEBHOOK_ACTION;
    }

    public static Map<String, String> getTraceResultDefaultWebhookActionTemplate() {
        return Templates.TRACE_RESULT_SOBJECT.DEFAULT_WEBHOOK_ACTION;
    }

    public static List<MergeField> getSobjectFields(Schema.DescribeSObjectResult d, String dType, Schema.DescribeFieldResult parent, Schema.DescribeSObjectResult parentObject, Integer depth) {
        depth = depth + 1;
        List<MergeField> result = new List<MergeField>();
        Map<String, Schema.SObjectField> fieldsMap = d.fields.getMap();
        
        // Get exclusion list for this SObject (only applies to Log and Issue at root level, not related objects)
        List<Schema.SObjectField> excludedFields = new List<Schema.SObjectField>();
        List<Schema.SObjectField> updateOnlyFields = new List<Schema.SObjectField>();
        
        if (parent == null) { // Only apply exclusions and update-only markings at root level
            Schema.SObjectType sobjType = d.getSObjectType();
            if (MAP_EXCLUDE_FIELDS_FROM_MERGE_FIELDS.containsKey(sobjType)) {
                excludedFields = MAP_EXCLUDE_FIELDS_FROM_MERGE_FIELDS.get(sobjType);
            }
            if (MAP_UPDATE_ONLY_MERGE_FIELDS.containsKey(sobjType)) {
                updateOnlyFields = MAP_UPDATE_ONLY_MERGE_FIELDS.get(sobjType);
            }
        }
        
        for(String sobjectFieldName : fieldsMap.keySet()) {
            Schema.SObjectField sfd = fieldsMap.get(sobjectFieldName);
            
            // Check if field is in exclusion list (only at root level)
            if (parent == null && excludedFields.contains(sfd)) continue;
            
            Schema.DescribeFieldResult dfr = sfd.getDescribe();
            // skip if field is not accessible
            if(!dfr.isAccessible()) continue;
            // skip if field is a standard preference field
            if(isStandardPreferencesField(dfr)) continue;

            String label = ((parent != null) ? (parent.getLabel() + ' -> ') : '') + dfr.getLabel();
            String localName = (parent != null) ? (parent.getRelationshipName() + '.' + dfr.getName()) : dfr.getName();
            String objectName = (parentObject != null) ? parentObject.getName() : d.getName();
            String apiName = '{!' + objectName + '.' + localName + '}';
            String sobjectFieldAPIName = (parentObject != null) ? parent.getRelationshipName() + '.' + sobjectFieldName : sobjectFieldName;

            Boolean availableForJiraMapping = true;
            if (MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING.get(dType).contains(sobjectFieldAPIName)) {
                availableForJiraMapping = false;
            }
            
            MergeField field = new MergeField(label, apiName, dType, sobjectFieldAPIName, availableForJiraMapping);
            
            // Mark field as update-only if it's in the updateOnlyFields list (only at root level)
            if (parent == null && updateOnlyFields.contains(sfd)) {
                field.setIsUpdateOnly(true);
            }
            
            result.add(field);

            List<Schema.sObjectType> relSObjectTypes = dfr.getReferenceTo();
            if(!relSObjectTypes.isEmpty() && depth < 2 && dfr.getRelationshipName() != null) {
                Schema.DescribeSObjectResult relObjectDescr = relSObjectTypes.get(0).getDescribe();
                result.addAll(getSobjectFields(relObjectDescr, dType, dfr, d, depth));
            }
            
        }
        return result;
    }

    public static Object getMergeFields() {
        List<MergeField> mergeFields = new List<MergeField>();

        Schema.DescribeSObjectResult logDsR = Log__c.sObjectType.getDescribe();
        mergeFields.addAll(addCustomMergeFields(logDsR, 'log'));
        mergeFields.addAll(getSobjectFields(logDsR, 'log'));

        Schema.DescribeSObjectResult eventDsR = Event__c.sObjectType.getDescribe();
        mergeFields.addAll(addCustomMergeFields(eventDsR, 'event'));
        mergeFields.addAll(getSobjectFields(eventDsR, 'event'));

        Schema.DescribeSObjectResult issueDsR = Issue__c.sObjectType.getDescribe();
        mergeFields.addAll(addCustomMergeFields(issueDsR, 'issue'));
        mergeFields.addAll(getSobjectFields(issueDsR, 'issue'));

        Schema.DescribeSObjectResult traceResultDsR = Trace_Result__c.sObjectType.getDescribe();
        mergeFields.addAll(addCustomMergeFields(traceResultDsR, 'traceResult'));
        mergeFields.addAll(getSobjectFields(traceResultDsR, 'traceResult'));

        if (AutoChart.isEnabled) {
            mergeFields.addAll(ChartService.getChartsFields());
        }

        mergeFields.sort();
        return mergeFields;
    }

    public static final Map<String, Set<String>> MAP_SOBJECT_TYPE_TO_NOT_AVAILABLE_FOR_JIRA_MAPPING = new Map<String, Set<String>>{
        'log' => new Set<String>{
            Schema.sObjectType.Log__c.fields.Deploy_Results__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Deploy_results_available__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Pending_Jobs__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Total_Pending_Jobs__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Total_Active_Sessions__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Installed_Packages__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Related_Id__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Related_Object_Type__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Related_Objects__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Stacktrace_Parse_Result__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Stack_trace_parse_result_available__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Settings__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Complete__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Broadcast_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Email_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Jira_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Slack_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.PagerDuty_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Notification_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Teams_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Sent_To_Splunk__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Splunk_Link__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Executable_Rules__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Bug_Tracker__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Audit_Trail_available__c.getName().toLowerCase(),
            Schema.sObjectType.Log__c.fields.Issue_Tracker_Status__c.getName().toLowerCase()
        },
        'issue' => new Set<String>{
            Schema.sObjectType.Issue__c.fields.Analysis_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Analysis_Statuses_Details__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.DevOps_Center_Metadata_Available__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Executable_Rules__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Impacted_Objects__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Impacted_Objects_by_Type__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Issue_Analysis__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Override_Priority__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Source_Control_Metadata__c.getName().toLowerCase(),
            Schema.sObjectType.Issue__c.fields.Users_Impacted__c.getName().toLowerCase()
        },
        'event' => new Set<String>{
            Schema.sObjectType.Event__c.fields.Event_Details__c.getName().toLowerCase(),
            Schema.sObjectType.Event__c.fields.Grouped_Field_Values__c.getName().toLowerCase(),
            Schema.sObjectType.Event__c.fields.Records__c.getName().toLowerCase()
        },
        'traceResult' => new Set<String>{
            Schema.sObjectType.Trace_Result__c.fields.Executable_Rules__c.getName().toLowerCase(),
            Schema.sObjectType.Trace_Result__c.fields.Notification_Integration_Status__c.getName().toLowerCase()
        }
    };

    public class MergeField implements Comparable{
        public String label;
        public String value;
        public String sobjectype;
        public String apiName;
        public Boolean availableForJiraMapping;
        public Boolean isUpdateOnly;

        public MergeField(String label, String value, String sobjectype, String apiName) {
            this(label, value, sobjectype, apiName, true);
        }

        public MergeField(String label, String value, String sobjectype, String apiName, Boolean availableForJiraMapping) {
            this.label = label;
            this.value = value;
            this.sobjectype = sobjectype;
            this.apiName = apiName;
            this.availableForJiraMapping = availableForJiraMapping;
            this.isUpdateOnly = false;
        }

        public void setAvailableForJiraMapping(Boolean availableForJiraMapping) {
            this.availableForJiraMapping = availableForJiraMapping;
        }

        public void setIsUpdateOnly(Boolean isUpdateOnly) {
            this.isUpdateOnly = isUpdateOnly;
        }

        public Integer compareTo(Object compareTo) {
            MergeField mf = (MergeField)compareTo;
            return this.apiName.compareTo(mf.apiName);
        }
    }

    public static Object getAppPermissions(Object data) {
        Map<String, Object> result = new Map<String, Object> {
            'JiraIntegrationEnabled' => PermissionsUtil.JiraIntegrationEnabled,
            'SlackIntegrationEnabled' => PermissionsUtil.SlackIntegrationEnabled,
            'PagerDutyIntegrationEnabled' => PermissionsUtil.PagerDutyIntegrationEnabled,
            'SplunkIntegrationEnabled' => PermissionsUtil.SplunkIntegrationEnabled,
            'MonitoringEnabled' => PermissionsUtil.MonitoringEnabled,
            'LimitsMonitoringEnabled' => PermissionsUtil.LimitsMonitoringEnabled,
            'EventMonitoringEnabled' => PermissionsUtil.EventMonitoringEnabled,
            'MaxMonitoringRules' => PermissionsUtil.MaxMonitoringRules,
            'ArchivalEnabled' => PermissionsUtil.ArchivalEnabled,
            'MaxArchivalRules' => PermissionsUtil.MaxArchivalRules,
            'MaxConnectedOrgs' => PermissionsUtil.MaxConnectedOrgs,
            'MaxJiraRules' => PermissionsUtil.MaxJiraRules,
            'SensitiveDataMaskingEnabled' => PermissionsUtil.SensitiveDataMaskingEnabled,
            'NotificationIntegrationEnabled' => PermissionsUtil.NotificationIntegrationEnabled,
            'MaxNotificationRules' => PermissionsUtil.MaxNotificationRules,
            'FlowDebugViewEnabled' => PermissionsUtil.FlowDebugViewEnabled,
            'BulkAPITrackingEnabled' => PermissionsUtil.BulkAPITrackingEnabled,
            'IntegrationDebugViewEnabled' => PermissionsUtil.IntegrationDebugViewEnabled,
            'TeamsIntegrationEnabled' => PermissionsUtil.TeamsIntegrationEnabled,
            'GitHubIntegrationEnabled' => PermissionsUtil.GitHubIntegrationEnabled,
            'ChangeTrackingEnabled' => PermissionsUtil.ChangeTrackingEnabled,
            'IssueNotificationsEnabled' => PermissionsUtil.IssueNotificationsEnabled,
            'AzureDevOpsIntegrationEnabled' => PermissionsUtil.AzureDevOpsIntegrationEnabled,
            'DebugLogServiceEnabled' => PermissionsUtil.DebugLogServiceEnabled,
            'IssueAnalysisEnabled' => PermissionsUtil.IssueAnalysisEnabled,
            'MandatoryErrorReportingEnabled' => PermissionsUtil.MandatoryErrorReportingEnabled,
            'FlowLoggingEnabled' => PermissionsUtil.FlowLoggingEnabled,
            'IssueTrackingEnabled' => PermissionsUtil.IssueTrackingEnabled,
            'MetadataChatEnabled' => PermissionsUtil.MetadataChatEnabled,
            'AutoChartEnabled' => PermissionsUtil.AutoChartEnabled,
            'ForecastEnabled' => PermissionsUtil.ForecastEnabled,
            'WebhookIntegrationEnabled' => PermissionsUtil.WebhookIntegrationEnabled,
            'ForecastEnabled' => PermissionsUtil.ForecastEnabled,
            'SystemOverviewDashboardEnabled' => PermissionsUtil.SystemOverviewDashboardEnabled,
            'RuleTemplateCustomization' => PermissionsUtil.RuleTemplateCustomization,
            'RuleImportExport' => PermissionsUtil.RuleImportExport,
            'UpdateRules' => PermissionsUtil.UpdateRules,
            'AsyncProcessErrorTracking' => PermissionsUtil.AsyncProcessErrorTracking,
            'EmailToCaseErrorTracking' => PermissionsUtil.EmailToCaseErrorTracking
        };
        return result;
    }

    public static Map<String, Object> getSessionSettings() {
        Map<String, Object> output = new Map<String, Object>();
        Boolean lockSessionsToIp = false;
        String query = new QBuilder('SessionSettings')
                .selectFields(new Set<String>{'Id', 'LockSessionsToIp'})
                .build();
        try {
            List<Object> sObjectItems = HttpUtils.runToolingQuery(System.Url.getOrgDomainUrl().toExternalForm(), ConnectedOrgService.getSelfConnectedOrgAccessToken(), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT);
            if (!sObjectItems.isEmpty()) {
                Map<String, Object> sobjectMap = (Map<String, Object>)sObjectItems[0];
                lockSessionsToIp = Boolean.valueOf(sobjectMap.get('LockSessionsToIp'));
            }
        } catch (HttpUtils.HttpUtilsException e) {
            if (e.getMessage().contains(HttpUtils.EXCEPTION_INVALID_SESSION_ID)) {
                lockSessionsToIp = true;
            }
            debugSession(e, 'getSessionSettings');
        }
        if (ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c != lockSessionsToIp) {
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c = lockSessionsToIp;
            DatabaseUtils.getInstance().performUpsertDML(new List<Connected_Orgs_Settings__c>{ConfigUtil.CONNECTED_ORGS_SETTINGS}, Schema.SObjectType.Connected_Orgs_Settings__c, true);
        }
        output.put(ConfigUtil.USE_OAUTH_FOR_SELF_ORG, ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c);
        return output;
    }

    public static List<MetadataServiceUtil.RemoteSiteSettingsWrapper> getRemoteSiteSettings() {
        return getRemoteSiteSettings(ConnectedOrgService.getSelfConnectedOrgAccessToken());
    }

    public static List<MetadataServiceUtil.RemoteSiteSettingsWrapper> getRemoteSiteSettings(String accessToken) {
        List<MetadataServiceUtil.RemoteSiteSettingsWrapper> remoteSiteSettingsList =
            new List<MetadataServiceUtil.RemoteSiteSettingsWrapper>();
        try {
            String b = HttpUtils.get(
                ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY,
                ConfigUtil.getRemoteSiteSettingsHeadersMap(accessToken),
                200
            );
            Map<String, Object> respResults = (Map<String, Object>)JSON.deserializeUntyped(b);
            if (respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS) != null) {
                remoteSiteSettingsList = (List<MetadataServiceUtil.RemoteSiteSettingsWrapper>)JSON.deserialize(
                    JSON.serialize(respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS)),
                    List<MetadataServiceUtil.RemoteSiteSettingsWrapper>.class
                );
                return remoteSiteSettingsList;
            }
        }
        catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'getRemoteSiteSettings');
        }
        return remoteSiteSettingsList;
    }

    public static Object getConnectedOrgsInfo() {
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTED_ORGS_INFO_KEY_SETTINGS, new ConnectedOrgsSettings(ConfigUtil.CONNECTED_ORGS_SETTINGS));
        List<ConnectedOrgDTO> corgs = new List<ConnectedOrgDTO>();
        for (Connected_Org__c corg : ConnectedOrgService.getConnectedOrgsList()) {
            corgs.add(new ConnectedOrgDTO(corg));
        }
        output.put(ConfigUtil.CONNECTED_ORGS_INFO_KEY_CONNECTED_ORGS, corgs);
        return output;
    }


    public static Object getSelfConnectedOrgsInfo() {
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTED_ORGS_INFO_KEY_SETTINGS, new ConnectedOrgsSettings(ConfigUtil.CONNECTED_ORGS_SETTINGS));
        output.put(ConfigUtil.CURRENT_ORG_IS_SANDBOX_KEY, ConfigUtil.currentOrgIsSandbox());
        List<ConnectedOrgDTO> corgs = new List<ConnectedOrgDTO>();
        Connected_Org__c selfCorg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
        if(selfCorg != null) {
            corgs.add(new ConnectedOrgDTO(selfCorg));
        }
        output.put(ConfigUtil.CONNECTED_ORGS_INFO_KEY_CONNECTED_ORGS, corgs);
        return output;
    }

    public static Object updatePassthroughtMode(Object payload) {
        ConnectedOrgsSettings s = (ConnectedOrgsSettings)JSON.deserialize(JSON.serialize(payload), ConnectedOrgsSettings.class);
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = s.passthroughtMode;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c = s.passthroughConnection;
        DatabaseUtils.getInstance().performUpsertDML(new List<Connected_Orgs_Settings__c>{ConfigUtil.CONNECTED_ORGS_SETTINGS}, Schema.SObjectType.Connected_Orgs_Settings__c, true);
        ConfigUtil.initConnectedOrgsSettings();
        return new ConnectedOrgsSettings(ConfigUtil.CONNECTED_ORGS_SETTINGS);
    }

    public static Object createConnectionOrg(Object payload) {
        ConnectedOrgCreateData d = (ConnectedOrgCreateData)JSON.deserialize(JSON.serialize(payload), ConnectedOrgCreateData.class);
        Connected_Org__c corg = ConnectedOrgService.createConnectedOrg(d.name, d.type, d.description, d.source, d.dataDirection, d.orgId);
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CORG, new ConnectedOrgDTO(corg));
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CLIENT_KEY, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        output.put('useManagedApp', ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        return output;
    }

    public static Object createSelfConnectionOrg(Object payload) {
        ConnectedOrgCreateData d = (ConnectedOrgCreateData)JSON.deserialize(JSON.serialize(payload), ConnectedOrgCreateData.class);
        Connected_Org__c corg = ConnectedOrgService.createSelfConnectedOrg(d.name, d.description);
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CORG, new ConnectedOrgDTO(corg));
        return output;
    }

    public static Object createSelfConnectionOrgOauth(Object payload) {
        ConnectedOrgCreateData d = (ConnectedOrgCreateData)JSON.deserialize(JSON.serialize(payload), ConnectedOrgCreateData.class);
        Connected_Org__c corg = ConnectedOrgService.createSelfConnectedOrg(d.name, d.description);
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CORG, new ConnectedOrgDTO(corg));
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CLIENT_KEY, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        output.put('useManagedApp', ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        return output;
    }

    public static Object updateConnectedOrg(Object payload) {
        ConnectedOrgDTO d = (ConnectedOrgDTO)JSON.deserialize(JSON.serialize(payload), ConnectedOrgDTO.class);
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(d.orgId);
        if (corg == null) {
            throw new AdminServiceException(ConfigUtil.EXCEPTION_CONNECTED_ORG_NOT_FOUND);
        }
        corg.Title__c = d.name;
        corg.Description__c = d.description;
        corg.Data_Direction__c = d.dataDirection;
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c, true);

        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CORG, new ConnectedOrgDTO(corg));
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CLIENT_KEY, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        output.put('useManagedApp', ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        return output;
    }

    public static Object resetConnectedOrgOauth(Object payload) {
        ConnectedOrgDTO d = (ConnectedOrgDTO)JSON.deserialize(JSON.serialize(payload), ConnectedOrgDTO.class);
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(d.orgId);
        if (corg == null) {
            throw new AdminServiceException(ConfigUtil.EXCEPTION_CONNECTED_ORG_NOT_FOUND);
        }
        corg.Access_Token__c = null;
        corg.Refresh_Token__c = null;
        corg.Token_Refreshed_At__c = null;
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c, true);

        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CORG, new ConnectedOrgDTO(corg));
        output.put(ConfigUtil.CONNECTION_ORG_KEY_CLIENT_KEY, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        output.put('useManagedApp', ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c);
        return output;
    }

    public static Object refreshConnectedOrgToken(Object payload) {
        ConnectedOrgDTO d = (ConnectedOrgDTO)JSON.deserialize(JSON.serialize(payload), ConnectedOrgDTO.class);
        Connected_Org__c corg = ConnectedOrgService.refreshToken(d.orgId);
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c, true);
        return new ConnectedOrgDTO(corg);
    }

    public static Object testConnectedOrg(Object payload) {
        ConnectedOrgDTO d = (ConnectedOrgDTO)JSON.deserialize(JSON.serialize(payload), ConnectedOrgDTO.class);
        if (ConnectedOrgService.testConnection(d.orgId)) {
            return ConfigUtil.CONNECTED_ORG_TESTING_KEY_SUCCESS;
        } else {
            return ConfigUtil.CONNECTED_ORG_TESTING_KEY_FAIL;
        }
    }

    public static Object deleteFakeConnectedOrg() {
        ConnectedOrgService.deleteFakeConnectedOrgs();
        return true;
    }

    public static Object deleteConnectedOrg(Object payload) {
        ConnectedOrgDTO d = (ConnectedOrgDTO)JSON.deserialize(JSON.serialize(payload), ConnectedOrgDTO.class);
        Connected_Org__c corg = Connected_Org__c.getInstance(d.orgId);  //get connect org by exact org id to ensure invalid org ids can be deleted
        if (corg == null) {
            throw new AdminServiceException(ConfigUtil.EXCEPTION_CONNECTED_ORG_DELETE_FAIL);
        }
        List<Rule__c> rules = [SELECT Id, Type__c FROM Rule__c WHERE Related_Id__c = :corg.Id LIMIT 1];
        if (!rules.isEmpty()) {
            Database.DeleteResult deleteResult = RuleUtil.deleteRule(rules[0].Id);
            if (deleteResult.isSuccess()) RuleUtil.reIndexRules(rules[0].Type__c);
        }
        deleteRemoteSiteSettingsMetadata(corg.Name);
        DatabaseUtils.getInstance().performDeleteDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c, true);
        return true;
    }

    public class ConnectedOrgsSettings {
        public Boolean passthroughtMode = false;
        public String passthroughConnection;
        public String clientKey;
        public String clientSecret;
        public Boolean connectedAppCreatedLessThan10Mins;
        public Datetime connectedAppCreatedAt;
        public String connectedAppId;
        public String connectedAppName;
        public Boolean schedulerEnabled = false;
        public ConnectedOrgsSettings() {}
        public ConnectedOrgsSettings(Connected_Orgs_Settings__c connectedOrgsSettings) {
            this.passthroughConnection = connectedOrgsSettings.Passthrought_Email__c;
            this.passthroughtMode = connectedOrgsSettings.Passthrought_Mode__c;
            this.clientKey = connectedOrgsSettings.Client_Key__c;
            this.clientSecret = connectedOrgsSettings.Client_Secret__c;
            this.schedulerEnabled = connectedOrgsSettings.Service_Scheduler_Enabled__c;
            this.connectedAppCreatedAt = connectedOrgsSettings.Connected_App_Created_At__c;
            this.connectedAppCreatedLessThan10Mins = connectedOrgsSettings.Connected_App_Created_At__c != null && connectedOrgsSettings.Connected_App_Created_At__c > Datetime.now().addMinutes(-10);
            this.connectedAppId = connectedOrgsSettings.Connected_App_ID__c;
            this.connectedAppName = connectedOrgsSettings.Connected_App_Name__c;
        }
    }

    public class ConnectedOrgDTO {
        public String recordId;
        public String orgId;
        public String name;
        public String description;
        public String type;
        public String instanceUrl;
        public String accessToken;
        public String refreshToken;
        public Datetime tokenRefreshedAt;
        public Boolean schedulerEnabled;
        public String source;
        public String dataDirection;
        public Boolean connectionValid;
        public ConnectedOrgDTO(Connected_Org__c corg) {
            recordId = corg.Id;
            orgId = corg.Name;
            name = corg.Title__c;
            type = corg.Type__c;
            instanceUrl = corg.Instance_Url__c;
            description = corg.Description__c;
            accessToken = corg.Access_Token__c;
            refreshToken = corg.Refresh_Token__c;
            tokenRefreshedAt = corg.Token_Refreshed_At__c;
            schedulerEnabled = corg.Scheduler_Enabled__c;
            source = corg.Source__c;
            dataDirection = corg.Data_Direction__c;
            connectionValid = corg.Connection_Valid__c;
        }
    }

    public class ConnectedOrgCreateData {
        public String name;
        public String type;
        public String description;
        public String source;
        public String dataDirection;
        public String orgId;
    }

    public static String BASE_REMOTE_SITE_SETTINGS_NAME = 'Pharos_ai_Base_URL';
    public static String CONNECTED_ORG_REMOTE_SITE_SETTINGS_NAME = 'Pharos_ai_Connected_Org_';

    public static List<DefaultRemoteSiteSetting> defaultRemoteSiteSettings = new List<DefaultRemoteSiteSetting> {
        new DefaultRemoteSiteSetting(
            'https://login.salesforce.com',
            'Pharos_ai_Sfdc_Prod_Login_URL',
            'Login URL for salesforce production orgs'),
        new DefaultRemoteSiteSetting(
            'https://test.salesforce.com',
            'Pharos_ai_Sfdc_Sandbox_Login_URL',
            'Login URL for salesforce sandbox orgs'),
        new DefaultRemoteSiteSetting(
            System.URL.getOrgDomainUrl().toExternalForm(),
            'Pharos_ai_Base_URL',
            'Pharos.ai callback URL in this org')
    };

    public class DefaultRemoteSiteSetting {
        public String url;
        public String name;
        public String description;

        public DefaultRemoteSiteSetting(String url, String name, String description) {
            this.url = url;
            this.name = name;
            this.description = description;
        }
    }

    public static Object setupRemoteSiteSettings() {
        for(DefaultRemoteSiteSetting drss : defaultRemoteSiteSettings) {
            upsertRemoteSiteSetting(drss.name, drss.url, drss.description);
        }
        return 'success';
    }

    public static Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper> getRemoteSiteSettingsMap() {
        Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper> output =
            new Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper>();
        for (MetadataServiceUtil.RemoteSiteSettingsWrapper rss : getRemoteSiteSettings()) {
            output.put(rss.EndpointUrl, rss);
        }
        return output;
    }

    public static void upsertRemoteSiteSetting(String name, String url, String description) {
        Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper> createdRemoteSiteSettings = getRemoteSiteSettingsMap();
        if (createdRemoteSiteSettings.containsKey(url) && createdRemoteSiteSettings.get(url).SiteName == name) {
            return;
        }

        MetadataServiceUtil.upsertRemoteSiteSettingsMetadata(
            MetadataServiceUtil.createRemoteSiteSettingInstance(name, url, description)
        );
    }

    /**
     * Extract base URL (protocol + domain) from a webhook URL
     * @param webhookUrl The full webhook URL
     * @return Base URL (e.g., https://example.com)
     */
    public static String extractWebhookBaseUrl(String webhookUrl) {
        if (String.isBlank(webhookUrl)) {
            return null;
        }

        try {
            // Find the third slash to get protocol + domain
            Integer firstSlash = webhookUrl.indexOf(Constants.GLOBAL_VARIABLE.URL_PROTOCOL_SEPARATOR);
            if (firstSlash == -1) {
                return null;
            }
            Integer thirdSlash = webhookUrl.indexOf(Constants.GLOBAL_VARIABLE.SYMBOL_SLASH, firstSlash + 3);
            if (thirdSlash == -1) {
                return webhookUrl; // URL is just protocol + domain
            }
            return webhookUrl.substring(0, thirdSlash);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Generate Remote Site Setting name for a webhook URL
     * @param webhookUrl The webhook URL
     * @return Remote Site Setting name
     */
    public static String generateWebhookRemoteSiteName(String webhookUrl) {
        String baseUrl = extractWebhookBaseUrl(webhookUrl);
        if (String.isBlank(baseUrl)) {
            return null;
        }

        // Extract domain from URL and create a safe name
        String domain = baseUrl
            .replace(Constants.GLOBAL_VARIABLE.URL_PROTOCOL_HTTPS, '')
            .replace(Constants.GLOBAL_VARIABLE.URL_PROTOCOL_HTTP, '')
            .replace(Constants.GLOBAL_VARIABLE.SYMBOL_DOT, Constants.GLOBAL_VARIABLE.SYMBOL_UNDERSCORE)
            .replace(Constants.GLOBAL_VARIABLE.SYMBOL_COLON, Constants.GLOBAL_VARIABLE.SYMBOL_UNDERSCORE)
            .replace(Constants.GLOBAL_VARIABLE.SYMBOL_SLASH, Constants.GLOBAL_VARIABLE.SYMBOL_UNDERSCORE)
            .replace(Constants.GLOBAL_VARIABLE.SYMBOL_DASH, Constants.GLOBAL_VARIABLE.SYMBOL_UNDERSCORE);
        return WebhookService.WEBHOOK_REMOTE_SITE_PREFIX + domain.left(WebhookService.WEBHOOK_REMOTE_SITE_NAME_MAX_LENGTH);
    }

    /**
     * Create Remote Site Settings for webhook URLs (synchronous batch operation - called BEFORE DML)
     * @param webhookUrls Set of webhook URLs to process
     */
    public static void upsertWebhookRemoteSiteSettings(Set<String> webhookUrls) {
        if (webhookUrls == null || webhookUrls.isEmpty()) {
            return;
        }

        // Batch process all unique base URLs (no callout in loop)
        Set<String> processedBaseUrls = new Set<String>();

        for (String webhookUrl : webhookUrls) {
            if (String.isBlank(webhookUrl)) {
                continue;
            }

            String baseUrl = extractWebhookBaseUrl(webhookUrl);
            String remoteSiteName = generateWebhookRemoteSiteName(webhookUrl);

            // Only process each unique base URL once
            if (String.isNotBlank(baseUrl) && String.isNotBlank(remoteSiteName) && !processedBaseUrls.contains(baseUrl)) {
                try {
                    upsertRemoteSiteSetting(
                        remoteSiteName,
                        baseUrl,
                        WebhookService.WEBHOOK_REMOTE_SITE_DESCRIPTION
                    );
                    processedBaseUrls.add(baseUrl);
                } catch (Exception e) {
                    Logger.getInstance()?.addInternalError(
                        e,
                        AdminService.class.getName(),
                        'upsertWebhookRemoteSiteSettings - URL: ' + webhookUrl
                    );
                }
            }
        }
    }

    /**
     * Delete Remote Site Settings for webhook URLs if not used by other actions (synchronous batch operation - called BEFORE DML)
     * This method queries existing actions to determine which Remote Site Settings will be unused AFTER the pending delete.
     * @param webhookUrlsToCheck Set of webhook URLs to check
     * @param actionIdsToExclude Set of action IDs that will be deleted (exclude from usage check)
     */
    public static void deleteWebhookRemoteSiteSettings(Set<String> webhookUrlsToCheck, Set<Id> actionIdsToExclude) {
        if (webhookUrlsToCheck == null || webhookUrlsToCheck.isEmpty()) {
            return;
        }

        // Extract base URLs from webhook URLs to check
        Set<String> baseUrlsToCheck = new Set<String>();
        for (String webhookUrl : webhookUrlsToCheck) {
            if (String.isNotBlank(webhookUrl)) {
                String baseUrl = extractWebhookBaseUrl(webhookUrl);
                if (String.isNotBlank(baseUrl)) {
                    baseUrlsToCheck.add(baseUrl);
                }
            }
        }

        if (baseUrlsToCheck.isEmpty()) {
            return;
        }

        // Get all currently active webhook domains, EXCLUDING the ones that will be deleted
        Set<String> activeBaseUrls = new Set<String>();
        String actionType = Constants.ACTION_SOBJECT.ACTION_TYPE_WEBHOOK_NOTIFICATION;

        List<Action__c> activeActions;
        if (actionIdsToExclude != null && !actionIdsToExclude.isEmpty()) {
            activeActions = [
                SELECT Webhook_URL_Domain__c
                FROM Action__c
                WHERE Action_Type__c = :actionType
                AND Webhook_URL_Domain__c != null
                AND Webhook_URL_Domain__c IN :baseUrlsToCheck
                AND Id NOT IN :actionIdsToExclude
            ];
        } else {
            activeActions = [
                SELECT Webhook_URL_Domain__c
                FROM Action__c
                WHERE Action_Type__c = :actionType
                AND Webhook_URL_Domain__c != null
                AND Webhook_URL_Domain__c IN :baseUrlsToCheck
            ];
        }

        for (Action__c action : activeActions) {
            if (String.isNotBlank(action.Webhook_URL_Domain__c)) {
                activeBaseUrls.add(action.Webhook_URL_Domain__c);
            }
        }

        // Process each URL to potentially delete
        Set<String> processedBaseUrls = new Set<String>();
        Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper> createdRemoteSiteSettings = getRemoteSiteSettingsMap();

        for (String webhookUrl : webhookUrlsToCheck) {
            if (String.isBlank(webhookUrl)) {
                continue;
            }

            String baseUrl = extractWebhookBaseUrl(webhookUrl);
            if (String.isBlank(baseUrl) || processedBaseUrls.contains(baseUrl)) {
                continue; // Already processed this base URL
            }

            // Check if this base URL will still be in use AFTER the delete
            if (activeBaseUrls.contains(baseUrl)) {
                continue; // Still in use, don't delete
            }

            // Get the Remote Site Setting name
            String remoteSiteName = generateWebhookRemoteSiteName(webhookUrl);
            if (String.isBlank(remoteSiteName)) {
                continue;
            }

            // Find and delete the Remote Site Setting
            try {
                for (MetadataServiceUtil.RemoteSiteSettingsWrapper rss : createdRemoteSiteSettings.values()) {
                    if (rss.SiteName == remoteSiteName || rss.SiteName == ConfigUtil.prefixCurrentOrgNamespace(remoteSiteName)) {
                        MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(
                            new List<String>{ConfigUtil.prefixCurrentOrgNamespace(rss.SiteName)}
                        );
                        processedBaseUrls.add(baseUrl);
                        break;
                    }
                }
            } catch (Exception e) {
                Logger.getInstance()?.addInternalError(
                    e,
                    AdminService.class.getName(),
                    'deleteWebhookRemoteSiteSettings - URL: ' + webhookUrl
                );
            }
        }
    }

    public static Boolean checkRemoteSiteSettings() {
        Boolean result = true;
        try {
            Map<String, MetadataServiceUtil.RemoteSiteSettingsWrapper> createdRemoteSiteSettings = getRemoteSiteSettingsMap();
            for(DefaultRemoteSiteSetting drss : defaultRemoteSiteSettings) {
                result = createdRemoteSiteSettings.containsKey(drss.url);
                if (!result) {
                    break;
                }
            }
        }
        catch(Exception e) {
            result = false;
        }
        return result;
    }

    public static Boolean getIsAvailableSingleEmail() {
        return (LimitsService.getAvailableSingleEmail() >= 1);
    }

    public static Map<String, String> checkEmailAccess() {
        Map<String, String> data = new Map<String, String>();
        PageReference emailSettingsPage = new PageReference('/email-admin/editOrgEmailSettings.apexp');
        String htmlBody = emailSettingsPage.getContent().toString().replace('\n','');
        String accessLevel = htmlBody.substringBetween(' selected="selected">','</option>');
        data.put('access', accessLevel);
        return data;
    }

    public static String getPackageEmailServiceFunctionEmailAddress() {
        List<EmailServicesAddress> addresses = getEmailServicesAddresses();
        return !addresses.isEmpty() ? EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(addresses.get(0)) : null;
    }

    public static List<EmailServicesAddress> getEmailServicesAddresses() {
        List<EmailServicesAddress> addresses = new List<EmailServicesAddress>();
        List<EmailServicesFunction> packageFunctions = emailServicesSelector.getPackageEmailServicesFunctions();
        if (!packageFunctions.isEmpty()) {
            addresses = emailServicesSelector.getActiveEmailServicesAddressesByFunctionIdsOrderingByCreatedDate(new Set<Id>{ packageFunctions.get(0).Id });
        }
        return addresses;
    }

    private static Boolean isEmailServicesAvailable() {
        Map<String, ApexEmailNotification> apexEmailNotificationByEmail = getApexEmailNotificationByEmailMap();
        List<EmailServicesFunction> availableEmailServices = emailServicesSelector.getPackageEmailServicesFunctions();
        List<EmailServicesAddress> availableEmailServicesAddresses = emailServicesSelector.getPackageAllAddresses();

        if (apexEmailNotificationByEmail.isEmpty() || availableEmailServices.isEmpty() || availableEmailServicesAddresses.isEmpty() || !availableEmailServices.get(0).IsActive) {
            return false;
        }

        EmailServicesAddress availableAddress;
        for (EmailServicesAddress currentAddress : availableEmailServicesAddresses) {
            if (apexEmailNotificationByEmail.containsKey(EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(currentAddress)) && currentAddress.isActive) {
                availableAddress = currentAddress;
                break;
            }
        }

        return availableAddress != null;
    }

    public static Object validateEmailServiceData() {
        Boolean result = false;
        if (!isEmailServicesAvailable()) {
            if (getAutomatedFlowErrorTracking()) {
                MetadataServiceUtil.setAutomatedFlowErrorTracking(false);
            }
            if (getScheduleBulkAPIBatch().get('cronParameter') != null) {
                abortScheduleBulkAPIBatch();
            }
            if (Boolean.valueOf(getBatchErrorTrackingSetting(null).get(ConfigUtil.BATCH_ERROR_TRACKING_ENABLED)) || ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c == Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED) {
                disableBatchErrorTrackingAndEmailToCaseErrorTracking();
            }
        }
        
        result = true;

        return result;
    }

    public static Map<String, Object> getEmailServiceData() {
        return getEmailServiceData(getAutomatedFlowErrorTracking(), getEmailToCaseErrorTracking(), getEmailToCaseErrorTrackingType(), getEmailToCaseErrorTrackingAvailable(), isEmailServicesAvailable());
    }

    public static Map<String, Object> getEmailServiceData(Boolean flowErrorTracking, Boolean emailToCaseErrorTracking, String emailToCaseErrorTrackingType, Boolean emailToCaseErrorTrackingAvailable, Boolean isEmailServicesAvailable) {
        Map<String, Object> output = new Map<String, Object>{
            ConfigUtil.EMAIL_SERVICE_DATA_KEY_CONFIRMED => ConfigUtil.SETTINGS.Email_Service_Confirmed__c,
            ConfigUtil.CONFIRM_AUTOMATED_FLOW_ERROR_TRACKING_KEY => flowErrorTracking,
            ConfigUtil.CONFIRM_EVENT_MONITORING_TRACKING_KEY => ConfigUtil.EVENT_MONITORING_SETTINGS?.Enabled__c,
            ConfigUtil.CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_KEY => ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c,
            ConfigUtil.CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_KEY => ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c == Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED,
            ConfigUtil.CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_ENABLED_KEY => emailToCaseErrorTracking,
            'emailToCaseErrorTrackingAvailable' => emailToCaseErrorTrackingAvailable,
            'emailToCaseErrorTrackingType' => emailToCaseErrorTrackingType,
            'emailServicesFunctionIsActive' => isEmailServicesAvailable
        };
        return output;
    }

    public static Map<String, Object> getLoggerWrapperInfo() {
        Map<String, String> output = new Map<String, String>{};
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :Constants.STATIC_RESOURCE_SOBJECT.RESOURCE_NAME_APEX_UTIL LIMIT 1];
        StaticResource srTest = [SELECT Body FROM StaticResource WHERE Name = :Constants.STATIC_RESOURCE_SOBJECT.RESOURCE_NAME_APEX_UTIL_TEST LIMIT 1];
        if (sr == null) {
            throw new AdminServiceException(ConfigUtil.APEXUTILSOURCE_NOT_FOUND_MESSAGE);
        }
        if (srTest == null) {
            throw new AdminServiceException(ConfigUtil.APEXUTILTESTSOURCE_NOT_FOUND_MESSAGE);
        }
        String loggerWrapperCode = sr.Body.toString();
        String loggerWrapperTestCode = srTest.Body.toString();
        String loggerWrapperCodeWithNS = loggerWrapperCode.replaceAll('pharos', ConfigUtil.NS);
        String loggerWrapperTestCodeWithNS = loggerWrapperTestCode.replaceAll('pharos', ConfigUtil.NS);
        output.put(ConfigUtil.LOGGER_WRAPPER_INFO_KEY_CODE, loggerWrapperCodeWithNS);
        output.put(ConfigUtil.LOGGER_WRAPPER_INFO_KEY_TEST_CODE, loggerWrapperTestCodeWithNS);
        return output;
    }

    public static void updateEmailServicesFunction(EmailServicesFunction emailServicesFunction, Boolean isActive) {
        try {
            EmailServicesService.emailServicesFunctionService.updateEmailServicesFunction(emailServicesFunction, isActive);
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'updateEmailServicesFunction');
        }
    }

    public static Map<String, Object> createEmailService(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean incomingValue = Boolean.valueOf(input.get(ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE));

        Map<String, ApexEmailNotification> apexEmailNotificationByEmail = getApexEmailNotificationByEmailMap();
        List<EmailServicesFunction> availableEmailServices = emailServicesSelector.getPackageEmailServicesFunctions();

        Id functionId;
        SObjectsCreateResponse response;
        String b;

        if (!availableEmailServices.isEmpty()) {
            updateEmailServicesFunction(availableEmailServices.get(0), incomingValue);
            functionId = availableEmailServices.get(0).Id;
        }
        
        if (incomingValue) {
            if (availableEmailServices.isEmpty()) {
                b = EmailServicesService.emailServicesFunctionService.createEmailServicesFunction();

                try {
                    response = (SObjectsCreateResponse)JSON.deserialize(b, SObjectsCreateResponse.class);
                    functionId = response.id;
                }
                catch(Exception e) {
                    throw new AdminServiceException(b);
                }
            }
            
            List<EmailServicesAddress> emailServicesAddresses = emailServicesSelector.getPackageAllAddresses();
            if (emailServicesAddresses.isEmpty()) {
                createEmailServicesAddress(functionId);
            } else {
                List<EmailServicesAddress> addressesToDelete = new List<EmailServicesAddress>();
                EmailServicesAddress addressToUpdate;
                Boolean isEmailAddressMatched = false;

                if (apexEmailNotificationByEmail.isEmpty()) {
                    addressToUpdate = emailServicesAddresses.get(0);
                    emailServicesAddresses.remove(0);
                    addressesToDelete.addAll(emailServicesAddresses);
                } else {
                    for (EmailServicesAddress currentEmailServicesAddress : emailServicesAddresses) {
                        if (apexEmailNotificationByEmail.containsKey(EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(currentEmailServicesAddress))) {
                            isEmailAddressMatched = true;
                            
                            if (!currentEmailServicesAddress.IsActive) {
                                addressToUpdate = currentEmailServicesAddress;
                            }
                        } else {
                            addressesToDelete.add(currentEmailServicesAddress);
                        }
                    }
                }

                EmailServicesService.emailServicesAddressService.deleteEmailServicesAddresses(addressesToDelete);

                if (addressToUpdate != null) {
                    EmailServicesService.emailServicesAddressService.updateEmailServicesAddress(addressToUpdate);
                } else if (!isEmailAddressMatched) {
                    createEmailServicesAddress(functionId);
                }
            }

            try {
                String errorEmailServiceAddress = getPackageEmailServiceFunctionEmailAddress();
                ApexEmailNotification apexEmailNotification;
                
                if (apexEmailNotificationByEmail.size() == 1 && !apexEmailNotificationByEmail.containsKey(errorEmailServiceAddress)) {
                    apexEmailNotification = apexEmailNotificationByEmail.get(new List<String>(apexEmailNotificationByEmail.keySet()).get(0));
                } else {
                    apexEmailNotification = apexEmailNotificationByEmail.get(errorEmailServiceAddress);
                }
                upsertApexEmailNotification(errorEmailServiceAddress, apexEmailNotification);
            }
            catch(Exception e) {
                throw new AdminServiceException(e);
            }
        }
        return getEmailServiceData();
    }

    public static void createEmailServicesAddress(Id functionId) {
        String b = EmailServicesService.emailServicesAddressService.createEmailServicesAddress(functionId);
        try {
            SObjectsCreateResponse response = (SObjectsCreateResponse)JSON.deserialize(b, SObjectsCreateResponse.class);
        }
        catch(Exception e) {
            throw new AdminServiceException(b);
        }
    }

    public static void upsertApexEmailNotification(String errorEmailServiceAddress, ApexEmailNotification apexEmailNotification) {
        Map<String, Object> apexEmailNotificationData = new Map<String, Object>{
            'Email' => errorEmailServiceAddress
        };

        try {
            if (apexEmailNotification == null) {
                EmailServicesService.apexEmailNotificationService.createApexEmailNotification(apexEmailNotificationData);
            } else {
                EmailServicesService.apexEmailNotificationService.updateApexEmailNotification(apexEmailNotification, apexEmailNotificationData);
            }
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'upsertApexEmailNotification');
        }
    }

    @future(Callout=true)
    public static void checkEmailToCaseErrorTrackingSettings() {
        // check limits
        // SOAP Fault: REQUEST_LIMIT_EXCEEDED: TotalRequests Limit exceeded. faultcode=sf:REQUEST_LIMIT_EXCEEDED faultactor=
        Integer sumTotalJobItems = DatabaseUtils.getSumTotalJobItems();
        Integer availableQuantityAsyncApexExecutions = LimitsService.getAvailableQuantityAsyncApexExecutions() - (sumTotalJobItems != null ? (sumTotalJobItems - 1) : 1);

        if(availableQuantityAsyncApexExecutions > 0 && ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c == Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED) {
            boolean emailToCaseErrorTracking = getEmailToCaseErrorTracking();
            if(!emailToCaseErrorTracking) {
                setEmailToCaseTracking(true);
            }
        }
    }

    public static Boolean getEmailToCaseErrorTrackingAvailable() {
        Boolean result = false;

        String errorHandlerAddress = getPackageEmailServiceFunctionEmailAddress();
        if(String.isNotBlank(errorHandlerAddress)) {
            try {
                MetadataService.CaseSettings caseSettings = MetadataServiceUtil.CASE_SETTINGS;
                if(caseSettings != null && caseSettings.emailToCase != null && caseSettings.emailToCase.enableEmailToCase) {
                    result = true;
                }
            }
            catch(Exception e){}
        }
        return result;
    }

    public static String getEmailToCaseErrorTrackingType() {
        String result = null;

        String errorHandlerAddress = getPackageEmailServiceFunctionEmailAddress();
        if(String.isNotBlank(errorHandlerAddress)) {
            try {
                MetadataService.CaseSettings caseSettings = MetadataServiceUtil.CASE_SETTINGS;
                if(caseSettings != null && caseSettings.emailToCase != null && caseSettings.emailToCase.enableEmailToCase) {
                    // User
                    if(String.isNotBlank(caseSettings.defaultCaseUser)) {
                        result = 'User';
                    }
                    //System
                    else if (String.isNotBlank(caseSettings.systemUserEmail)) {
                        result = 'System';
                    }
                }
            }
            catch(Exception e){}
        }
        return result;
    }

    public static Boolean getEmailToCaseErrorTracking() {
        Boolean result = false;

        if (String.isNotBlank(getPackageEmailServiceFunctionEmailAddress())) {
            MetadataService.CaseSettings caseSettings = MetadataServiceUtil.CASE_SETTINGS;
            if (caseSettings != null) {
                // User
                if (String.isNotBlank(caseSettings.defaultCaseUser)) {
                    List<User> users = getUserByUsername(caseSettings.defaultCaseUser);
                    List<Log__c> logs = TestDataGenerator.getTestPlatformEventLogs(TestDataGenerator.TEST_ERROR_TRACKING_REQUIRES_CONFIGURATION_HASH1);
                    result = !users.isEmpty() 
                        && !logs.isEmpty() 
                        && users.get(0).Id == logs.get(0).User_Id__c
                        && users.get(0).Email == logs.get(0).User_Name__c;
                }
                //System
                else if (String.isNotBlank(caseSettings.systemUserEmail)) {
                    result = true;
                }
            }
        }
        return result;
    }

    public static User getEmailToCaseDefaultCaseUserData() {
        User user = new User();
        if (String.isNotBlank(getPackageEmailServiceFunctionEmailAddress())) {
            MetadataService.CaseSettings caseSettings = MetadataServiceUtil.CASE_SETTINGS;
            if (caseSettings != null) {
                // User
                if (String.isNotBlank(caseSettings.defaultCaseUser)) {
                    List<User> users = getUserByUsername(caseSettings.defaultCaseUser);
                    user = !users.isEmpty() ? users.get(0) : user;
                }
            }
        }

        return user;
    }

    public static List<User> getUserByUsername(String username) {
        return [SELECT Id, Email FROM User WHERE UserName =:username LIMIT 1];
    }

    public static Boolean getAutomatedFlowErrorTracking() {
        Boolean result = false;
        try {
            MetadataService.FlowSettings flowSettings = MetadataServiceUtil.getFlowSettings();
            result = flowSettings.enableFlowUseApexExceptionEmail;
        }
        catch(Exception e){}
        return result;
    }

    public static Boolean setEmailToCaseTracking(Boolean value) {
        String errorHandlerAddress = getPackageEmailServiceFunctionEmailAddress();
        if(value && String.isNotBlank(errorHandlerAddress)) {
            MetadataService.CaseSettings caseSettings = MetadataServiceUtil.CASE_SETTINGS;
            if(caseSettings != null && caseSettings.emailToCase != null && caseSettings.emailToCase.enableEmailToCase) {
                // User
                if(String.isNotBlank(caseSettings.defaultCaseUser)) {
                    setEmailToCaseErrorTrackingStatus(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED);
                    
                    return true;
                }
                //System
                else if (String.isNotBlank(caseSettings.systemUserEmail)) {
                    caseSettings.systemUserEmail = errorHandlerAddress;
                    List<MetadataService.SaveResult> results =
                        MetadataServiceUtil.getCaseSettingsService().updateMetadata(
                            new MetadataService.Metadata[] {caseSettings});
                    MetadataServiceUtil.handleSaveResults(results[0]);

                    setEmailToCaseErrorTrackingStatus(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED);
                    return true;
                }
            }
            else {
                setEmailToCaseErrorTrackingStatus(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ERROR);
            }
        }
        else {
            PermissionsUtil.putSObjectField(ConfigUtil.SETTINGS, Schema.SObjectType.Logger_Settings__c.fields.Enable_Email_To_Case_Error_Tracking__c, Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_DISABLED);
            DatabaseUtils.getInstance().performUpdateDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        }
        return false;
    }


    public static void handleChangeUserEmail(String subject, String body) {
        String changeEmailLink = getTokenValue(body, PATTERN_CHANGE_EMAIL_LINK, 0);
        String emailHandlerAddress = getPackageEmailServiceFunctionEmailAddress();

        if(String.isNotBlank(emailHandlerAddress)
            && String.isNotBlank(changeEmailLink)
            && body.containsIgnoreCase(emailHandlerAddress)) {

            try {
                HttpUtils.get(changeEmailLink, null, 200);
                setEmailToCaseErrorTrackingStatus(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED);
            }
            catch(Exception e) {
                setEmailToCaseErrorTrackingStatus(Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ERROR);
            }

        }
    }

    @Future(Callout = true)
    public static void setEmailToCaseErrorTrackingStatus(String status){
        PermissionsUtil.putSObjectField(ConfigUtil.SETTINGS, Schema.SObjectType.Logger_Settings__c.fields.Enable_Email_To_Case_Error_Tracking__c, status);
        DatabaseUtils.getInstance().performUpdateDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        Logger.getInstance().flush();
    }

    public static final Pattern PATTERN_CHANGE_EMAIL_LINK = Pattern.compile('(http|https)://([\\w_-]+(?:(?:\\.[\\w_-]+)+))([\\w.,@?^=%&:/~+#-]*[\\w@?^=%&/~+#-])?');

    public static String getTokenValue(String value, Pattern pattern, Integer groupIndex) {
        String result;
        Pattern p = pattern;
        Matcher pm = p.matcher(value);

        if (pm.find()) {
            result = pm.group(groupIndex);
        }

        return result;
    }

    public static Map<String, Object> emailToCaseTracking(Object data) {
        if (!PermissionsUtil.EmailToCaseErrorTracking) return new Map<String, Object>();
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean incomingValue = Boolean.valueOf(input.get(ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE));

        Boolean flowErrorTracking = getAutomatedFlowErrorTracking();
        String emailToCaseErrorTrackingType = getEmailToCaseErrorTrackingType();
        Boolean emailToCaseErrorTrackingAvailable = getEmailToCaseErrorTrackingAvailable();
        Boolean isEmailServicesAvailable = isEmailServicesAvailable();
        Boolean emailToCaseErrorTracking = setEmailToCaseTracking(incomingValue);


        return getEmailServiceData(flowErrorTracking, emailToCaseErrorTracking, emailToCaseErrorTrackingType, emailToCaseErrorTrackingAvailable, isEmailServicesAvailable);
    }

    public static Map<String, Object> eventMonitoringTracking(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean incomingValue = Boolean.valueOf(input.get(ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE));

        Boolean flowErrorTracking = getAutomatedFlowErrorTracking();
        String emailToCaseErrorTrackingType = getEmailToCaseErrorTrackingType();
        Boolean emailToCaseErrorTrackingAvailable = getEmailToCaseErrorTrackingAvailable();
        Boolean isEmailServicesAvailable = isEmailServicesAvailable();
        Boolean emailToCaseErrorTracking = getEmailToCaseErrorTracking();
        
        try {
            // enable event log generation in metadata settings if this settings in metadata is disabled
            if(incomingValue) {
                if(!MetadataServiceUtil.getEventSettingsLogGenerationEnabled()) {
                    // enable event log generation in metadata settings
                    MetadataServiceUtil.setEventSettingsLogGeneration(incomingValue);
                }
            }
            // enable event monitoring in custom settings
            AdminService.setEventMonitoringSetting(new Map<String, Object>{
                ConfigUtil.MONITORING_APP_KEY_ENABLED => incomingValue
            });

            // set enabled event types with default enabled event types
            // or disable all event types
            ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = (incomingValue) 
                ? EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING
                : EventMonitoringUtil.DEFAULT_DISABLED_EVENT_TYPES_STRING;
            // Round to previous hour and remove minutes/seconds
            DateTime now = DateTime.now();
            DateTime roundedHour = DateTime.newInstance(now.year(), now.month(), now.day(), now.hour(), 0, 0);
            // Subtract the default delay to get the previous hour
            DateTime previousHour = roundedHour.addHours(-EventMonitoringUtil.DEFAULT_DELAY_CSV_FILE_GENERATION);
            
            ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = previousHour;
            DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
        }
        catch(Exception e) {
            throw new AdminServiceException(e);
        }
        
        return getEmailServiceData(flowErrorTracking, emailToCaseErrorTracking, emailToCaseErrorTrackingType, emailToCaseErrorTrackingAvailable, isEmailServicesAvailable);

    }

    public static Map<String, Object> flowErrorTracking(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        MetadataServiceUtil.setAutomatedFlowErrorTracking(Boolean.valueOf(input.get(ConfigUtil.CONFIRM_EMAIL_SERVICE_KEY_VALUE)));

        return getEmailServiceData();
    }

    public class QuickStartStateWrapper {
        public Boolean connectApp;
        public Boolean connectOrg;
        public Boolean quickTest;
        public Boolean jira;
        public Boolean slack;
        public Boolean teams;
        public Boolean monitoring;
        public Boolean monitoringTestInProgress;
        public Boolean isPassthrough;
        public Boolean useTeams;
        public Boolean useSlack;

        public QuickStartStateWrapper() {
            this.connectApp = false;
            this.connectOrg = false;
            this.quickTest = false;
            this.jira = false;
            this.slack = false;
            this.teams = false;
            this.monitoring = false;
            this.monitoringTestInProgress = false;
            this.isPassthrough = false;
            this.useTeams = false;
            this.useSlack = false;
        }
    }

    public static QuickStartStateWrapper setQuickStartState(Object data) {
        if(data != null) {
            QuickStartStateWrapper state = (QuickStartStateWrapper)JSON.deserialize(JSON.serialize(data), QuickStartStateWrapper.class);
            if(state != null) {
                ConfigUtil.SETTINGS.Quick_Start_State__c = JSON.serialize(state);
                DatabaseUtils.getInstance().performUpdateDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
            }
        }
        return getQuickStartState();
    }

    public static QuickStartStateWrapper getQuickStartState() {
        QuickStartStateWrapper result = new QuickStartStateWrapper();
        String state = ConfigUtil.SETTINGS.Quick_Start_State__c;
        if(String.isNotBlank(state)) {
            result = (QuickStartStateWrapper)JSON.deserialize(state, QuickStartStateWrapper.class);
        }
        return result;
    }

    public static Object resetAllSettingsForRefreshSandbox() {
        // deactivate active emailServiceFunctions / address
        List<EmailServicesFunction> activeFunctions = emailServicesSelector.getPackageEmailServicesFunctions();
        if(!activeFunctions.isEmpty()) {
            List<EmailServicesAddress> activeAddresses = emailServicesSelector.getEmailServicesAddressByFunctionId(activeFunctions.get(0).Id);
            if(!activeAddresses.isEmpty()) {
                String b = EmailServicesService.emailServicesAddressService.deleteEmailServicesAddress(activeAddresses.get(0));
            }
            updateEmailServicesFunction(activeFunctions.get(0), false);
        }

        Set<String> setRemoteSiteSettingsNames = new Set<String>();
        for (MetadataServiceUtil.RemoteSiteSettingsWrapper rss : getRemoteSiteSettings()) {
            setRemoteSiteSettingsNames.add(rss.SiteName);
        }
        List<String> lstRemoteSiteSettingsToDelete = new List<String>();
        List<Connected_Org__c> connectedOrgsList = ConnectedOrgService.getConnectedOrgsList();
        for (Connected_Org__c corg : connectedOrgsList) {
            if (setRemoteSiteSettingsNames.contains(CONNECTED_ORG_REMOTE_SITE_SETTINGS_NAME + corg.Name.left(15))) {
                lstRemoteSiteSettingsToDelete.add(ConfigUtil.prefixCurrentOrgNamespace(CONNECTED_ORG_REMOTE_SITE_SETTINGS_NAME + corg.Name.left(15)));
            }
        }
        Set<String> setDefaultRemoteSiteSettingsNames = new Set<String>();
        setDefaultRemoteSiteSettingsNames.add(BASE_REMOTE_SITE_SETTINGS_NAME);

        for (String defaultRemoteSiteSettingsName : setDefaultRemoteSiteSettingsNames) {
            if (setRemoteSiteSettingsNames.contains(defaultRemoteSiteSettingsName)) {
                lstRemoteSiteSettingsToDelete.add(ConfigUtil.prefixCurrentOrgNamespace(defaultRemoteSiteSettingsName));
            }
        }

        // Remove all remote site settings generated by pharos, no more then 10 records per callout
        if(!lstRemoteSiteSettingsToDelete.isEmpty()) {
            List<List<String>> chunks = doListPartition(lstRemoteSiteSettingsToDelete, 9);
            for(List<String> chunk : chunks) {
                MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(chunk);
            }
        }

        // Remove all connected orgs, except for the self org for government cloud flow
        Integer removeIndex;
        for (Integer i = 0; i < connectedOrgsList.size(); i++) {
            Connected_Org__c corg = connectedOrgsList.get(i);
            if (ConnectedOrgService.isSelfConnectedOrg(corg)
                    && ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c
                    && String.isNotBlank(corg.Access_Token__c)) {
                removeIndex = i;
                break;
            }
        }
        if (removeIndex != null) connectedOrgsList.remove(removeIndex);
        DatabaseUtils.getInstance().performDeleteDML(connectedOrgsList, Schema.SObjectType.Connected_Org__c, true);

        // clear QS state
        ConfigUtil.SETTINGS.Quick_Start_State__c = null;
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);

        ConfigUtil.CONNECTED_ORGS_SETTINGS.Instance_Url__c = null;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Service_Scheduler_Enabled__c = false;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c = null;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c = null;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c = null;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c = null;
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c = false;
        DatabaseUtils.getInstance().performUpsertDML(new List<Connected_Orgs_Settings__c>{ConfigUtil.CONNECTED_ORGS_SETTINGS}, Schema.SObjectType.Connected_Orgs_Settings__c, true);

        // clear branch name for git integration
        ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = null;
        DatabaseUtils.getInstance().performUpsertDML(new List<Git_API_Settings__c>{ConfigUtil.GIT_API_SETTINGS}, Schema.SObjectType.Git_API_Settings__c, true);

        // All types of rules (except for archival) should deactivate after refresh.
        List<Rule__c> allActiveRules = [SELECT Id, Active__c FROM Rule__c WHERE Active__c = true AND Type__c != :Constants.RULE_SOBJECT.TYPE_ARCHIVAL];
        for(Rule__c rule : allActiveRules) {
            rule.Active__c = false;
        }
        DatabaseUtils.getInstance().performUpdateDML(allActiveRules, Schema.SObjectType.Rule__c, true);
        
        return true;
    }

    public static List<List<String>> doListPartition(List<String> items, Integer splitSize){
        List<List<String>> result = new List<List<String>>();
        List<String> protoList = items.clone();
        protoList.clear();
        List<String> tempList = protoList.clone();
        Integer index = 0, count = 0, size = items.size();
        while(index < size) {
            tempList.add(items.get(index++));
            ++count;
            if(count == splitSize) {
                result.add(tempList);
                tempList = protoList.clone();
                count = 0;
            }
        }
        if(!tempList.isEmpty()) {
            result.add(tempList);
        }
        return result;
    }

    public static void deleteRemoteSiteSettingsMetadata(String name) {
        for (MetadataServiceUtil.RemoteSiteSettingsWrapper rss : getRemoteSiteSettings()) {
            if (rss.SiteName == (CONNECTED_ORG_REMOTE_SITE_SETTINGS_NAME + name.left(15))) {
                MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(new List<String>{ConfigUtil.prefixCurrentOrgNamespace(rss.SiteName)});
                break;
            }
        }
    }

    public static Boolean isRemoteSiteSettingsSetupCompleted() {
        return checkRemoteSiteSettings();
    }

    public static Boolean isEmailServiceFunctionSetupCompleted() {
        // Email Service
        List<EmailServicesFunction> availableEmailServices = emailServicesSelector.getPackageEmailServicesFunctions();
        String emailServiceAddress = getPackageEmailServiceFunctionEmailAddress();

        return !availableEmailServices.isEmpty()
            && availableEmailServices.get(0).IsActive
            && String.isNotBlank(emailServiceAddress);
    }

    public static Boolean isConnectionOrgsSetupCompleted() {
        return !ConnectedOrgService.getConnectedOrgsList().isEmpty();
    }

    public static Integer getIntegrationsPercentCompleted() {
        // Integrations
        Integer integrationsPercent = 0;
        Integer integrationsAvailable = (PermissionsUtil.JiraIntegrationEnabled ? 1 : 0)
            + (PermissionsUtil.SlackIntegrationEnabled ? 1 : 0)
            + (PermissionsUtil.PagerDutyIntegrationEnabled ? 1 : 0)
            + (PermissionsUtil.SplunkIntegrationEnabled ? 1 : 0);

        if (String.isNotBlank(ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c) && ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c && PermissionsUtil.SlackIntegrationEnabled) {
            integrationsPercent += 100/integrationsAvailable;
        }
        if (String.isNotBlank(JiraService.JIRA_OAUTH_TOKEN) && String.isNotBlank(JiraService.JIRA_API_URL) && PermissionsUtil.JiraIntegrationEnabled) {
            integrationsPercent += 100/integrationsAvailable;
        }
        if (String.isNotBlank(ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c) && ConfigUtil.SPLUNK_SETTINGS.Splunk_Enabled__c && PermissionsUtil.SplunkIntegrationEnabled) {
            integrationsPercent += 100/integrationsAvailable;
        }
        if (String.isNotBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c) && ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c && PermissionsUtil.PagerDutyIntegrationEnabled) {
            integrationsPercent += 100/integrationsAvailable;
        }
        return integrationsPercent;
    }

    public static Decimal getErrorTrackingPercentCompleted() {
        Boolean emailToCaseErrorTrackingAvailable = getEmailToCaseErrorTrackingAvailable();
        Boolean flowErrorTracking = getAutomatedFlowErrorTracking();
        String emailServiceAddress = getPackageEmailServiceFunctionEmailAddress();
        Boolean eventMonitoringTracking = ConfigUtil.EVENT_MONITORING_SETTINGS?.Enabled__c;
        Decimal percentComplete = 0;
        if(emailToCaseErrorTrackingAvailable) {
            percentComplete += (String.isNotBlank(emailServiceAddress)) ? 25 : 0;
            percentComplete += (flowErrorTracking) ? 25 : 0;
            percentComplete += (eventMonitoringTracking) ? 25 : 0;
            percentComplete += (ConfigUtil.SETTINGS.Enable_Email_To_Case_Error_Tracking__c == Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED) ? 25 : 0;
        }
        else {
            percentComplete += (String.isNotBlank(emailServiceAddress)) ? 33.33 : 0;
            percentComplete += (flowErrorTracking) ? 33.33 : 0;
            percentComplete += (eventMonitoringTracking) ? 33.33 : 0;
        }
        return percentComplete;
    }

    public static Boolean isNotificationsSetupCompleted() {
        List<RuleUtil.Rule> notificationRulesLogs = RuleUtil.getNotificationRules(null);
        List<RuleUtil.Rule> notificationRulesIssues = RuleUtil.getNotificationRules(null, Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME);
        return !notificationRulesLogs.isEmpty() || !notificationRulesIssues.isEmpty();
    }

    public static Boolean isMonitoringRulesSetupCompleted() {
        List<Rule__c> availableMonitoringRules = [SELECT Id FROM Rule__c WHERE Active__c = true AND Type__c = :Constants.RULE_SOBJECT.TYPE_MONITORING LIMIT 1];
        return (availableMonitoringRules.size() > 0 && PermissionsUtil.MonitoringEnabled);
    }

    public static Boolean isArchivalRulesSetupCompleted() {
        List<Rule__c> availableMonitoringRules = [SELECT Id FROM Rule__c WHERE Active__c = true AND Type__c = :Constants.RULE_SOBJECT.TYPE_ARCHIVAL LIMIT 1];
        return (availableMonitoringRules.size() > 0 && PermissionsUtil.ArchivalEnabled);
    }

    public static Map<String, Object> getConfigurationOverviewData() {
        Map<String, Object> data = Constants.UI.CONFIGURATION_OVERVIEW_DATA;

        // Remote Site Settings
        if (isRemoteSiteSettingsSetupCompleted()) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG0, true);
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
        }

        // Error Tracking
        if (isEmailServiceFunctionSetupCompleted()) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG1, true);
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
        }

        // Connected Orgs
        if (isConnectionOrgsSetupCompleted()) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG2, true);
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PASSTHROUGHT_MODE_ENABLED, ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c);
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
        }

        // Integrations
        Integer integrationsPercentCompleted = getIntegrationsPercentCompleted();
        if (integrationsPercentCompleted > 0) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG3, true);
        }

        // Sensitive Data Masking
        Integer availableMasks = SensitiveDataMask__c.getAll().size();
        if (availableMasks > 0 && PermissionsUtil.SensitiveDataMaskingEnabled) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG4, true);
        }

        // Monitoring
        if (ConfigUtil.SETTINGS.Monitoring_Enabled__c) {
            if (isMonitoringRulesSetupCompleted()) {
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG5, true);
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
            }
        }

        // Log Retention
        if (ConfigUtil.SETTINGS.Archival_Enabled__c) {
            if (isArchivalRulesSetupCompleted()) {
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG6, true);
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
            }
        }

        // Triton
        if (new PlatformEventSubscriberConfigService(Log_Event__e.SobjectType).isPlatformEventConfigSetupCompleted()) {
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG7, true);
            data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
        }

        // Notifications
        if (PermissionsUtil.NotificationIntegrationEnabled) {
            if (isNotificationsSetupCompleted()) {
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_FLAG8, true);
                data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, ((Integer)data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)) + 1);
            }
        }

        // FLAG0 FLAG2 FLAG3 FLAG4 FLAG6 FLAG7 FLAG8 FLAG9
        Integer flagsQuantity = 8;
        Decimal progress = 100*Decimal.valueOf(String.valueOf(data.get(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS)))/flagsQuantity + (Decimal.valueOf(100)/flagsQuantity)*(Decimal.valueOf(integrationsPercentCompleted)/100);
        data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS, progress <= 100 ? Integer.valueOf(progress) : 100);
        data.put(Constants.UI.CONFIGURATION_OVERVIEW_DATA_KEY_INTEGRATION_PROGRESS, integrationsPercentCompleted);
        data.put('emailServicePercentComplete', getErrorTrackingPercentCompleted().round(System.RoundingMode.CEILING));

        LogServiceScheduler.rescheduleCronTriggers();

        if (String.isBlank(ConfigUtil.SETTINGS.Namespace__c)) {
            ConfigUtil.SETTINGS.Namespace__c = ConfigUtil.nameSpacePrefix;
            DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        }

        return data;
    }

    // TODO: Remove if don't use
    public static void stopScheduler(String schedulerJobName) {
        List<CronTrigger> availableCrons = getAvailableCronJobByName(schedulerJobName);
        if (availableCrons.size() == 1) {
            System.abortJob(availableCrons[0].Id);
        }
    }

    public static void runScheduler(String schedulerJobName, String configCronExpr, String defaultCronExpr, Schedulable schedulableInstance) {
        List<CronTrigger> availableCrons = getAvailableCronJobByName(schedulerJobName);
        if (availableCrons.size() == 0) {
            String cronExpr = (String.isNotBlank(configCronExpr))
                ? configCronExpr
                : defaultCronExpr;
            Id cronId = system.schedule(schedulerJobName, cronExpr, schedulableInstance);
        }
    }

    public static List<CronTrigger> getAvailableCronJobByName(String jobName) {
        List<CronTrigger> availableCronJobs = [
            SELECT Id, CronExpression, CronJobDetail.Name, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
            LIMIT 1
        ];
        return availableCronJobs;
    }

    public static ChangeTrackingSettings getChangeTrackingSettings() {
        ChangeTrackingSettings settings = new ChangeTrackingSettings(ConfigUtil.CHANGE_TRACKING_SETTINGS);
        return settings;
    }

    public static ChangeTrackingSettings setChangeTrackingSettings(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        if(input.get('gitChangeTracking') != null) {
            ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c = Boolean.valueOf(input.get('gitChangeTracking'));
        }
        DatabaseUtils.getInstance().performUpsertDML(new List<Change_Tracking__c>{ConfigUtil.CHANGE_TRACKING_SETTINGS}, Schema.SObjectType.Change_Tracking__c, true);
        return getChangeTrackingSettings();
    }

    public static Map<String, Boolean> pushGitChanges() {
        GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
        Boolean isJobAlreadyRunning = !DatabaseUtils.getCurrentJobs(new List<String>{'GitHubCommitBatch'}).isEmpty();
        Boolean hasAuditChanges = String.isBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c);
        if (!hasAuditChanges) {
            GitHubCommitBatch.AuditChangeWrapper lastChanges = GitHubCommitBatch.getAuditTrails(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c);
            hasAuditChanges = (lastChanges != null && !lastChanges.auditChange.isEmpty()) || false;
        }
        
        Boolean isExecuted = false;
        if (!isJobAlreadyRunning && hasAuditChanges) {
            isExecuted = DatabaseUtils.executeBatchWithLimitCheck('GitHubCommitBatch', batchInstance);
        }

        return new Map<String, Boolean>{
            'changesPushed' => isExecuted,
            'hasChanges' => hasAuditChanges,
            'jobAlreadyRunning' => isJobAlreadyRunning
        };
    }

    public static Object getJiraEpics(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String projectId = (input.get('projectId') != null) ? (String)input.get('projectId') : null;
        String query = (input.get('query') != null) ? (String)input.get('query') : null;
        Object epics;
        try {
            epics = JiraService.getService().getEpics(projectId, query);
        }
        catch(HttpUtils.HttpUtilsException e) {
            // handle 404 and 400 errors
            // 400: {"errorMessages":["The issue key 'A' for field 'issueKey' is invalid."],"warningMessages":[]}
            if(e?.getMessage()?.contains('404:') || e?.getMessage()?.contains('400:')) {
                epics = new List<JiraService.JiraIssue>();
            }
            else {
                throw e;
            }
        }
        return epics;
    }

    public static Object getJiraProjectComponents(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String projectId = (input.get('projectId') != null) ? (String)input.get('projectId') : null;
        String query = (input.get('query') != null) ? (String)input.get('query') : null;
        Object components = JiraService.getService().getProjectComponents(projectId, query);
        return components;
    }

    public static Object getJiraProjectUsers(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String projectId = (input.get('projectId') != null) ? (String)input.get('projectId') : null;
        String query = (input.get('query') != null) ? (String)input.get('query') : null;
        Object users = JiraService.getService().getProjectAssignableUsers(projectId, query);
        return users;
    }

    public static Object getJiraProjectUsers(String projectId) {
        Object users = JiraService.getService().getProjectAssignableUsers(projectId, null);
        return users;
    }

    public static Object getJiraProject(String projectId) {
        Object project = JiraService.getService().getProject(projectId);
        return project;
    }

    public static Object getJiraProjectIssueTypes(String projectId) {
        Object issueTypes = JiraService.getService().getProjectIssueTypes(projectId);
        return issueTypes;
    }

    public static Map<String, Object> getCreateMeta(Object createMetaRequestData) {
        try {
            Map<String, Object> ss = (Map<String, Object>)createMetaRequestData;
            String projectId = (String)ss?.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_PROJECT_ID);
            String issueTypeId = (String)ss?.get(ConfigUtil.CREATE_META_REQUEST_DATA_KEY_ISSUE_TYPE_ID);

            JiraService.JiraProject project = JiraService.getService().getProject(projectId);

            Map<String, JiraService.JiraProjectIssueField> customFields = JiraService.getService().getProjectIssueCustomFields(project.issueTypes, issueTypeId);
            // if project dosen't contains internal wrapper's (IssueTypes && IssueTypeFields)
            if(customFields == null || customFields.isEmpty()) {
                customFields = JiraService.getService().getProjectIssueCustomFields(projectId, issueTypeId);
            }

            List<JiraService.JiraProjectComponent> components = JiraService.getService().getProjectComponents(projectId, null);
            List<JiraService.JiraIssue> epics = new List<JiraService.JiraIssue>();
            List<JiraService.JiraPriority> priorities = new List<JiraService.JiraPriority>();

            try {
                epics = JiraService.getService().getEpics(projectId, null);
                priorities = JiraService.getService().getPriorities();
            }
            catch(Exception e){}

            Map<String, Object> output = new Map<String, Object>{
                ConfigUtil.CREATE_META_REQUEST_DATA_KEY_META => customFields,
                ConfigUtil.CREATE_META_REQUEST_DATA_KEY_COMPONENTS => components,
                ConfigUtil.CREATE_META_REQUEST_DATA_KEY_EPICS => epics,
                ConfigUtil.CREATE_META_REQUEST_DATA_KEY_PRIORITIES => priorities
            };
            return output;
        }
        catch(Exception e){
            Logger.getInstance().internalError(e, null, true, AdminService.class.getName(), 'getCreateMeta');
        }
        return null;
    }

    // Fields to exclude from update rule filters (fields that should NOT appear in update filters)
    public static Map<Schema.sObjectType, List<Schema.SObjectField>> MAP_EXCLUDE_FILTER_FIELDS_ON_UPDATE = new Map<Schema.sObjectType, List<Schema.SObjectField>>{
        Log__c.sObjectType => new List<Schema.SObjectField>(),
        Issue__c.sObjectType => new List<Schema.SObjectField>{
            // System fields excluded from Issue update rules
            Schema.sObjectType.Issue__c.fields.IsDeleted.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.CreatedById.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastModifiedById.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastModifiedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.SystemModstamp.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastActivityDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastViewedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastReferencedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.OwnerId.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.RecordTypeId.getSObjectField(),
            // Insert field ONLY
            Schema.sObjectType.Issue__c.fields.Log__c.getSObjectField(),
            // Internal/Integration fields
            Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Executable_Rules__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Key__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Category_Icon__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Analysis_Statuses_Details__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Issue_Analysis__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Source_Control_Metadata__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.DevOps_Center_Metadata_Available__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Override_Priority__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Users_Impacted__c.getSObjectField()
        }
    };

    // Fields to exclude from merge fields (for Insert Field dialogs)
    // These are system fields and internal fields that should NOT appear in merge field lists
    public static Map<Schema.sObjectType, List<Schema.SObjectField>> MAP_EXCLUDE_FIELDS_FROM_MERGE_FIELDS = new Map<Schema.sObjectType, List<Schema.SObjectField>>{
        Log__c.sObjectType => new List<Schema.SObjectField>{
            // System fields that are not useful in merge fields
            Schema.sObjectType.Log__c.fields.CreatedById.getSObjectField(),
            Schema.sObjectType.Log__c.fields.IsDeleted.getSObjectField(),
            Schema.sObjectType.Log__c.fields.LastModifiedById.getSObjectField(),
            Schema.sObjectType.Log__c.fields.LastModifiedDate.getSObjectField(),
            Schema.sObjectType.Log__c.fields.SystemModstamp.getSObjectField(),
            Schema.sObjectType.Log__c.fields.LastActivityDate.getSObjectField(),
            Schema.sObjectType.Log__c.fields.LastViewedDate.getSObjectField(),
            Schema.sObjectType.Log__c.fields.LastReferencedDate.getSObjectField(),
            Schema.sObjectType.Log__c.fields.OwnerId.getSObjectField(),
            // Internal/system fields
            Schema.sObjectType.Log__c.fields.Email_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Jira_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Slack_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.PagerDuty_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Notification_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Teams_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Executable_Rules__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Issue_Tracker_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Bug_Tracker__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Complete__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Post_Processing_Settings__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Broadcast_Status__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Stacktrace_Parse_Result__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Stack_trace_parse_result_available__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Audit_Trail_available__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Deploy_results_available__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Deploy_Results__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Icon__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Sent_To_Splunk__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Splunk_Link__c.getSObjectField()
        },
        Issue__c.sObjectType => new List<Schema.SObjectField>{
            // System fields that are not useful in merge fields
            Schema.sObjectType.Issue__c.fields.IsDeleted.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastModifiedById.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastModifiedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.SystemModstamp.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastActivityDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastViewedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.LastReferencedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.OwnerId.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.RecordTypeId.getSObjectField(),
            // Internal/Integration fields
            Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Executable_Rules__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Key__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Category_Icon__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Analysis_Status__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Analysis_Statuses_Details__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Issue_Analysis__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Source_Control_Metadata__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.DevOps_Center_Metadata_Available__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Override_Priority__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Users_Impacted__c.getSObjectField()
        },
        Event__c.sObjectType => new List<Schema.SObjectField>{
            Schema.sObjectType.Event__c.fields.CreatedById.getSObjectField(),
            Schema.sObjectType.Event__c.fields.IsDeleted.getSObjectField(),
            Schema.sObjectType.Event__c.fields.LastModifiedById.getSObjectField(),
            Schema.sObjectType.Event__c.fields.LastModifiedDate.getSObjectField(),
            Schema.sObjectType.Event__c.fields.SystemModstamp.getSObjectField(),
            Schema.sObjectType.Event__c.fields.LastViewedDate.getSObjectField(),
            Schema.sObjectType.Event__c.fields.LastReferencedDate.getSObjectField(),
            Schema.sObjectType.Event__c.fields.OwnerId.getSObjectField(),
            Schema.sObjectType.Event__c.fields.RecordTypeId.getSObjectField()
        },
        Trace_Result__c.sObjectType => new List<Schema.SObjectField>{
            Schema.sObjectType.Trace_Result__c.fields.CreatedById.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.IsDeleted.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.LastModifiedById.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.LastModifiedDate.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.SystemModstamp.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.LastActivityDate.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.LastViewedDate.getSObjectField(),
            Schema.sObjectType.Trace_Result__c.fields.LastReferencedDate.getSObjectField()
        }
    };

    // Fields that are ONLY available for Update rules (not for Create rules) - these should be marked as isUpdateOnly in merge fields
    public static Map<Schema.sObjectType, List<Schema.SObjectField>> MAP_UPDATE_ONLY_MERGE_FIELDS = new Map<Schema.sObjectType, List<Schema.SObjectField>>{
        Log__c.sObjectType => new List<Schema.SObjectField>(),
        Issue__c.sObjectType => new List<Schema.SObjectField>{
            // These fields are available in Update but NOT in Create
            Schema.sObjectType.Issue__c.fields.Assigned__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Assigned_To__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Average_Daily_Volume__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Average_Frequency__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Bug_Tracker__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Exception_Codes__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.First_Occurred_On__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Impacted_Objects__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Impacted_Objects_Count__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Impacted_Objects_by_Type__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Impacted_Users__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Impacted_Users_Count__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Name.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Last_Occurred_On__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Log_Count__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Priority__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Regressed_On__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Regression__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Related_Issue__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Resolved_On__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Score__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Status__c.getSObjectField()
        }
    };

    // Standard fields to include in rule filters (excludes "Insert field ONLY" fields like Flow_Link__c, Organization_Url__c, Related_Object__c, User__c, Log__c)
    public static Map<Schema.sObjectType, List<Schema.SObjectField>> MAP_INCLUDE_FIELDS_FOR_FILTERS_ON_CREATE = new Map<Schema.sObjectType, List<Schema.SObjectField>>{
        Log__c.sObjectType => new List<Schema.SObjectField>{
            Schema.sObjectType.Log__c.fields.Async_Job_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Async_Job_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Area__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Category__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Created_At__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.CreatedById.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Details__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Exception_Codes__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.First_Occurred_On__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Flow_API_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Flow_Version__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Flow_Version_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Hash_1__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Hash_2__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Hash_3__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Installed_Packages__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Interview_GUID_External__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Is_New__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Is_Parent__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Is_Sandbox__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Name.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Namespace__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Apex_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Organization_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Organization_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Originated_From__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Parent__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Pending_Jobs__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Profile_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Profile_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.RecordTypeId.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Related_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Related_Object_Type__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Related_Objects__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Request_Id_External__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Role_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Role_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Salesforce_Error_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Salesforce_License_Type_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Stacktrace__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Summary__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Total_Active_Sessions__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Total_Pending_Jobs__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Transaction_Id_External__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Type__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.User_Id__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.User_Name__c.getSObjectField(),
            Schema.sObjectType.Log__c.fields.Visualforce_Page__c.getSObjectField()
        },
        Issue__c.sObjectType => new List<Schema.SObjectField>{
            // Fields for Issue Create rules only (limited set)
            Schema.sObjectType.Issue__c.fields.Category__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.CreatedDate.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Description__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Functional_Area__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Organization_Name__c.getSObjectField(),
            Schema.sObjectType.Issue__c.fields.Summary__c.getSObjectField()
        }
    };

    public class FilterField implements Comparable{
        public String value;
        public String label;
        public String type;

        public FilterField(String value, String label, String type) {
            this.value = value;
            this.label = label;
            this.type = type;
        }

        public Integer compareTo(Object compareTo) {
            FilterField ff = (FilterField)compareTo;
            return this.label.compareTo(ff.label);
        }
    }


    public static Object getEventMonitoringFields() {
        return EventMonitoringUtil.getEventMonitoringFields();
    }

    public static Object getIssueFields(String ruleType) {
        return getIssueFields(ruleType, false);
    }

    public static Object getIssueFields(String ruleType, Boolean isUpdateRule) {
        return getSObjectFields(Schema.sObjectType.Issue__c.getSObjectType(), ruleType, isUpdateRule);
    }

    public static Object getLogFields(String ruleType) {
        return getSObjectFields(Schema.sObjectType.Log__c.getSObjectType(), ruleType);
    }

    public static Object getSObjectFields(SObjectType sobjectType, String ruleType) {
        return getSObjectFields(sobjectType, ruleType, false);
    }

    public static Object getSObjectFields(SObjectType sobjectType, String ruleType, Boolean isUpdateRule) {
        List<FilterField> result = new List<FilterField>();
        String pahrosPrefix = ConfigUtil.getNameSpacePrefix();
        // standard first
        if(!isUpdateRule) {
            for (Schema.SObjectField field : MAP_INCLUDE_FIELDS_FOR_FILTERS_ON_CREATE.get(sobjectType)) {
                Schema.DescribeFieldResult dsr = field.getDescribe();
                result.add(new FilterField(dsr.getName(), dsr.getLabel(), String.valueOf(dsr.getType())));
            }
        }
        // then custom fields
        Map<String, Schema.SObjectField> mfields = sobjectType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : mfields.values()) {
            Schema.DescribeFieldResult dsr = field.getDescribe();
            if((!isUpdateRule && dsr.isCustom() && !dsr.getName().startsWith(pahrosPrefix)) 
                || (isUpdateRule && !MAP_EXCLUDE_FILTER_FIELDS_ON_UPDATE.get(sobjectType).contains(field))) {
                result.add(new FilterField(dsr.getName(), dsr.getLabel(), String.valueOf(dsr.getType())));
            }
        }
        result.sort();
        return result;
    }

    public static OAuthSettings getOAuthSettings() {
        OAuthSettings oauthSettings = new OAuthSettings(ConfigUtil.CONNECTED_ORGS_SETTINGS);
        return oauthSettings;
    }

    public class OAuthSettings {
        public String clientKey;
        public String clientSecret;
        public Boolean connectedAppCreatedLessThan10Mins = false;
        public Boolean schedulerEnabled;

        public OAuthSettings() {}

        public OAuthSettings(Connected_Orgs_Settings__c connectedOrgSettings) {
            this.clientKey = connectedOrgSettings.Client_Key__c;
            this.clientSecret = connectedOrgSettings.Client_Secret__c;
            this.schedulerEnabled = connectedOrgSettings.Service_Scheduler_Enabled__c;
            this.connectedAppCreatedLessThan10Mins = connectedOrgSettings.Connected_App_Created_At__c != null && connectedOrgSettings.Connected_App_Created_At__c > Datetime.now().addMinutes(-10);
        }
    }

    public static OAuthSettings createConnectedApp(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean useManagedApp = (Boolean)input.get('useManagedApp');

        if(!useManagedApp) {
            if(String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c)) {
                String oldConnectedAppApiName = ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c;

                MetadataService.ConnectedApp currentConnectedApp = MetadataServiceUtil.getConnectedAppMetadataByApiName(oldConnectedAppApiName);
                if(currentConnectedApp.fullName != null) {
                    MetadataServiceUtil.deleteConnectedAppMetadata(oldConnectedAppApiName);
                }
            }

            String newConnectedAppName = ConfigUtil.CONNECTED_APP_API_NAME + generateRandomStringOfNumbers(10);
            String newConnectedAppApiName = ConfigUtil.prefixCurrentOrgNamespace(newConnectedAppName);
            
            String key = generateRandomString(32);
            String secret = generateRandomStringOfNumbers(32);
            String payload = getConnectedAppPayload(secret, key, AdminController.salesforceBaseUrl + ConfigUtil.CONNECTED_APP_CALLBACK_PAGE_URL, newConnectedAppName, newConnectedAppApiName);

            MetadataServiceUtil.createConnectedAppMetadata(payload);

            ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c = key;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c = secret;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c = Datetime.now();
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c = newConnectedAppApiName;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c = useManagedApp;
        }
        else {
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(ConfigUtil.PHAROS_APP_SETTINGS_NAME);
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c = mdtSettings.Client_Id__c;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c = mdtSettings.Client_Secret__c;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Created_At__c = Datetime.now().addMinutes(-10);
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Connected_App_Name__c = ConfigUtil.CONNECTED_APP_API_NAME;
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Managed_App__c = useManagedApp;
        }

        DatabaseUtils.getInstance().performUpsertDML(new List<Connected_Orgs_Settings__c>{ConfigUtil.CONNECTED_ORGS_SETTINGS}, Schema.SObjectType.Connected_Orgs_Settings__c, true);

        ConfigUtil.initConnectedOrgsSettings();
        return getOAuthSettings();
    }

    public static String getConnectedAppPayload(String secret, String key, String callBackUrl, String name, String apiName) {
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :Constants.STATIC_RESOURCE_SOBJECT.RESOURCE_NAME_METADATA_CONNECTED_APP_PAYLOAD LIMIT 1];
        String payload = sr.Body.toString();
        payload = payload.replace('XXXXX1', secret);
        payload = payload.replace('XXXXX2', key);
        payload = payload.replace('XXXXX3', callBackUrl);
        payload = payload.replace('XXXXX4', name);
        payload = payload.replace('XXXXX5', apiName);
        return payload;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static String generateRandomStringOfNumbers(Integer len) {
        final String chars = '0123456789';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static List<SensitiveDataMaskWrapper> getMasks() {
        List<SensitiveDataMaskWrapper> masks = new List<SensitiveDataMaskWrapper>();
        Map<String, SensitiveDataMask__c> masksMap = SensitiveDataMask__c.getAll();
        if(!masksMap.isEmpty()) {
            for (SensitiveDataMask__c m : masksMap.values()) {
                masks.add(new SensitiveDataMaskWrapper(m));
            }
        }

        return masks;
    }

    public static List<SensitiveDataMaskWrapper> saveMask(Object data) {
        SensitiveDataMaskWrapper input = (SensitiveDataMaskWrapper)JSON.deserialize(JSON.serialize(data), SensitiveDataMaskWrapper.class);
        SensitiveDataMask__c mask = new SensitiveDataMask__c(
            Name = (input.id == null) ? ConfigUtil.generateUUID4() : input.id,
            Regex__c = input.regex,
            Description__c = input.description
        );
        DatabaseUtils.getInstance().performUpsertDML(new List<SensitiveDataMask__c>{mask}, Schema.SObjectType.SensitiveDataMask__c, SensitiveDataMask__c.Name, true);
        return getMasks();
    }

    public static List<SensitiveDataMaskWrapper> deleteMask(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        List<SensitiveDataMask__c> sensitiveDataMasks = [SELECT Id FROM SensitiveDataMask__c WHERE Name = :(String)input.get(ConfigUtil.SENSETIVE_MASK_KEY_ID) LIMIT 1];
        DatabaseUtils.getInstance().performDeleteDML(sensitiveDataMasks, Schema.SObjectType.SensitiveDataMask__c, true);
        return getMasks();
    }

    public static String testMask(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String text = (String)input.get(ConfigUtil.SENSETIVE_MASK_KEY_TEXT);
        String regex = (String)input.get(ConfigUtil.SENSETIVE_MASK_KEY_REGEX);
        String result = text.replaceAll(regex, ConfigUtil.SENSETIVE_MASK_KEY_MASK);
        return result;
    }

    public static Map<String, Object> getServicesEnable() {
        return new Map<String, Object>{
            //'Jira' => ConfigUtil.SETTINGS.Auto_Jira_Task__c,
            ConfigUtil.SLACK_SERVICE_NAME => ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c,
            ConfigUtil.PAGER_DUTY_SERVICE_NAME => ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c,
            ConfigUtil.TEAMS_SERVICE_NAME => ConfigUtil.GRAPH_API_SETTINGS.Enabled__c,
            ConfigUtil.WEBHOOK_SERVICE_NAME => PermissionsUtil.WebhookIntegrationEnabled
        };
    }
    //log-categories
    public static Map<String, Object> getLogCategories() {
        Map<String, Object> ret = new Map<String, Object>();
        ret.put(ConfigUtil.LOG_CATEGORIES_KEY_CATEGORIES, SObjectType.Log__c.fields.Category__c.getPicklistValues());
        ret.put(ConfigUtil.LOG_CATEGORIES_KEY_RECORDTYPES, getLogRecordTypePicklistValues());
        ret.put(ConfigUtil.LOG_CATEGORIES_KEY_MAPPINGS, getLogRecordTypeMappings());
        return ret;
    }

    public class SelectOptionWrapper {
        String value;
        String label;

        public SelectOptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    public class LogRecordTypeMapping {
        public String categoryValue;
        public String categoryLabel;
        public String recordTypeValue;
        public String recordTypeLabel;

        public LogRecordTypeMapping(String categoryValue, String categoryLabel, String recordTypeValue, String recordTypeLabel) {
            this.categoryValue = categoryValue;
            this.categoryLabel = categoryLabel;
            this.recordTypeValue = recordTypeValue;
            this.recordTypeLabel = recordTypeLabel;
        }
    }

    public static String deleteLogRecordTypeMappings(Object payload) {
        return setMappings(payload, true);
    }

    public static String setLogRecordTypeMappings(Object payload) {
        return setMappings(payload, false);
    }

    public static String setMappings(Object payload, Boolean isDelete) {

        List<Sobject> toDelete = new List<Sobject>();
        List<Sobject> toUpdate = new List<Sobject>();
        List<Sobject> toInsert = new List<Sobject>();
        LogRecordTypeMapping mapping = (LogRecordTypeMapping)JSON.deserialize(JSON.serialize(payload), LogRecordTypeMapping.class);
        Map<String, Log_Category_Mapping_Setting__c> records = Log_Category_Mapping_Setting__c.getAll();
        List<Log_Category_Mapping_Setting__c> mappingRecords = records.values();

        Set<String> existMappingRecords = new Set<String>();
        existMappingRecords.add(mapping.categoryValue + mapping.recordTypeValue);

        String categoryValue = mapping.categoryValue;
        String recordTypeValue = mapping.recordTypeValue;
        Boolean haveUpdate = false;
        Boolean existRecord = false;
        for(Log_Category_Mapping_Setting__c categoryMapping : mappingRecords) {
            if(categoryMapping.Category__c != null && categoryMapping.Record_Type_Developer_Name__c != null) {
                String rtDeveloperNameValue = categoryMapping.Record_Type_Developer_Name__c;
                String categoryFieldValue = categoryMapping.Category__c;

                if(categoryValue == categoryFieldValue) {
                    if(recordTypeValue != rtDeveloperNameValue) {
                        categoryMapping.Record_Type_Developer_Name__c = recordTypeValue;
                        toUpdate.add(categoryMapping);
                        haveUpdate = true;
                    }
                    else {
                        existRecord = true;
                        if(isDelete) {
                            toDelete.add(categoryMapping);
                        }
                    }
                }
            }
        }

        if(!haveUpdate && !existRecord) {
            Log_Category_Mapping_Setting__c sObjInsert = new Log_Category_Mapping_Setting__c();
            sObjInsert.Name = categoryValue;
            sObjInsert.Category__c = categoryValue;
            sObjInsert.Record_Type_Developer_Name__c = recordTypeValue;
            toInsert.add(sObjInsert);
        }

        DatabaseUtils.getInstance().performUpdateDML(toUpdate, true);
        DatabaseUtils.getInstance().performInsertDML(toInsert, true);
        DatabaseUtils.getInstance().performDeleteDML(toDelete, true);

        return Constants.UI.RESULT_SUCCESS;
    }

    private static List<LogRecordTypeMapping> getLogRecordTypeMappings() {
        List<LogRecordTypeMapping> result = new List<LogRecordTypeMapping>();
        Map<String, Log_Category_Mapping_Setting__c> records = Log_Category_Mapping_Setting__c.getAll();

        for(Log_Category_Mapping_Setting__c record : records.values()) {
            if(record.Category__c != null && record.Record_Type_Developer_Name__c != null) {
                LogRecordTypeMapping mapping = new LogRecordTypeMapping(record.Category__c,record.Category__c,record.Record_Type_Developer_Name__c,record.Record_Type_Developer_Name__c);
                result.add(mapping);
            }
        }
        return result;
    }

    private static List<SelectOptionWrapper> getLogRecordTypePicklistValues() {
        List<SelectOptionWrapper> recordTypes = new List<SelectOptionWrapper>();
        for(String rtLabel : Schema.SObjectType.Log__c.getRecordTypeInfosByName().keySet()) {
            String rtDeveloperName = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get(rtLabel).getDeveloperName();
            SelectOptionWrapper option = new SelectOptionWrapper(rtDeveloperName, rtLabel);
            recordTypes.add(option);
        }
        return recordTypes;
    }

    public static Map<String, Object> getRuleSettings(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        return getRuleSettings(String.valueOf(input.get(RuleUtil.KEY_RULE_TYPE)));
    }

    public static Map<String, Object> getRuleSettings(String ruleType) {
        Map<String, Object> ruleSettings = new Map<String, Object>();
        ruleSettings.put(RuleUtil.KEY_RULE_ENABLED, RuleUtil.MAP_RULES_ENABLED.get(ruleType));
        ruleSettings.put(RuleUtil.KEY_RULES, RuleUtil.getRuleWrappers(ruleType));
        if(ruleType != Constants.RULE_SOBJECT.TYPE_EVENT_MONITORING) {
            ruleSettings.put(RuleUtil.KEY_RULE_COMPARISON_OPERATORS, SObjectType.Rule__c.fields.ComparisonOperator__c.getPicklistValues());
            List<SelectOptionWrapper> filterComparisonOperators = new List<SelectOptionWrapper>();
            for (String comparisonOperatorLabel : RuleUtil.RULE_FILTER_COMPARISON_OPERATORS) {
                filterComparisonOperators.add(new SelectOptionWrapper(comparisonOperatorLabel, comparisonOperatorLabel));
            }
            ruleSettings.put(RuleUtil.KEY_RULE_FILTER_COMPARISON_OPERATORS, filterComparisonOperators);
        }
        else {
            ruleSettings.put(RuleUtil.KEY_RULE_COMPARISON_OPERATORS, new List<SelectOptionWrapper>());
            ruleSettings.put(RuleUtil.KEY_RULE_FILTER_COMPARISON_OPERATORS, new List<SelectOptionWrapper>());

            ruleSettings.put(RuleUtil.KEY_EVENT_FIELDS, EventMonitoringUtil.getEventMonitoringFields());
        }
        ruleSettings.put(RuleUtil.KEY_RULE_FILTERS, RuleUtil.getRuleFilterWrappers());
        ruleSettings.put(RuleUtil.KEY_EVENTS, RuleUtil.getLastCreatedEventsMap().values());
        ruleSettings.put(RuleUtil.KEY_RULE_ACTIONS, RuleUtil.getRuleActionWrappers(ruleType, null));
        ruleSettings.put(RuleUtil.KEY_ACTIONS, RuleUtil.getActionWrappers(ruleType, null));
        
        ruleSettings.put(RuleUtil.KEY_LOG_FIELDS, getLogFields(ruleType));
        ruleSettings.put(RuleUtil.KEY_ISSUE_FIELDS, getIssueFields(ruleType));
        ruleSettings.put(RuleUtil.KEY_ISSUE_FIELDS_FOR_UPDATE, getIssueFields(ruleType, true));
        ruleSettings.put(RuleUtil.KEY_SERVICE_ENABLE, getServicesEnable());
        ruleSettings.put(RuleUtil.KEY_ACTION_TYPES, RuleUtil.getActionTypes(ruleType));
        ruleSettings.put(RuleUtil.KEY_RULE_SUBTYPES, SObjectType.Rule__c.fields.Subtype__c.getPicklistValues());
        ruleSettings.put(RuleUtil.KEY_USER_TIMEZONE_OFFSET, getUserTimezoneOffset());

        if (ruleType == Constants.RULE_SOBJECT.TYPE_LIMITS) {
            ruleSettings.put(RuleUtil.KEY_LIMIT_FIELD_NAMES, LimitsService.FIELD_MAP.keySet());
            ruleSettings.put(RuleUtil.KEY_LIMIT_MONITORING_FREQUENCY, String.isNotBlank(ConfigUtil.SETTINGS.Limits_Monitoring_Frequency__c) ? Integer.valueOf(ConfigUtil.SETTINGS.Limits_Monitoring_Frequency__c) : null);
        } else if (ruleType == Constants.RULE_SOBJECT.TYPE_EVENT_MONITORING) {
            ruleSettings.put(RuleUtil.KEY_EVENT_MONITORING_TYPES, EventMonitoringUtil.getEventTypesWithStatus());
        }
        return ruleSettings;
    }

    public static Integer getUserTimezoneOffset() {
        Integer userTimezoneOffset = UserInfo.getTimeZone().getOffset(Datetime.now())/(3600*1000);
        return userTimezoneOffset;
    }

    public static Map<String, List<SelectOptionWrapper>> getActionTypes(String ruleType) {
        Map<String, List<SelectOptionWrapper>> result = new Map<String, List<SelectOptionWrapper>>();
        Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Action__c.getRecordTypeInfosByName();
        for(String rtName : rtMapByName.keySet()) {
            if(rtName != ruleType) continue;
            Schema.RecordTypeInfo rtInfo = rtMapByName.get(rtName);
            List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
            for(String actionType : RuleUtil.MAP_ACTION_TYPES_BY_RULE_TYPE.get(ruleType)) {
                options.add(new SelectOptionWrapper(actionType, actionType));
            }
            result.put(rtInfo.getRecordTypeId(), options);
        }
        return result;
    }

    public static Logger_Settings__c setArchivalSetting(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        ConfigUtil.SETTINGS.Archival_Enabled__c = Boolean.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED));
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        return ConfigUtil.SETTINGS;
    }

    public static Logger_Settings__c setMonitoringSetting(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        ConfigUtil.SETTINGS.Monitoring_Enabled__c = Boolean.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED));
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        return ConfigUtil.SETTINGS;
    }

    public static Logger_Settings__c setLimitsMonitoringSetting(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c = Boolean.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED));
        ConfigUtil.SETTINGS.Limits_Monitoring_Frequency__c = String.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_FREQUENCY));
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        return ConfigUtil.SETTINGS;
    }

    public static Event_Monitoring__c setEventMonitoringSetting(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean incomingValue = Boolean.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED));
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c = incomingValue;

        // if the incoming value is true and the enabled value is false, enable the event log generation in metadata settings
        if(incomingValue && !ConfigUtil.EVENT_MONITORING_SETTINGS?.Enabled__c) {
            if(!MetadataServiceUtil.getEventSettingsLogGenerationEnabled()) {
                // enable event log generation in metadata settings
                MetadataServiceUtil.setEventSettingsLogGeneration(incomingValue);
            }
        }
        Boolean monitoringEnabledFirstTime = incomingValue && !ConfigUtil.EVENT_MONITORING_SETTINGS?.Initialized__c;
        if (monitoringEnabledFirstTime) {
            EventMonitoringUtil.createDefaultRulesForEventType(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
            ConfigUtil.EVENT_MONITORING_SETTINGS.Initialized__c = true;
        }

        List<EventMonitoringUtil.EventTypeStatus> eventTypeStatuses = null;
        Object enabledTypesData = input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED_TYPES);
        if (enabledTypesData != null) {
            eventTypeStatuses = (List<EventMonitoringUtil.EventTypeStatus>)JSON.deserialize(
                JSON.serialize(enabledTypesData),
                List<EventMonitoringUtil.EventTypeStatus>.class
            );
        } else {
            // Create default enabled event types when enabledTypesData is null
            eventTypeStatuses = new List<EventMonitoringUtil.EventTypeStatus>();
            for (String eventType : EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES) {
                Integer defaultLogsLimit = EventMonitoringUtil.getDefaultLogsLimitForEventType(eventType);
                eventTypeStatuses.add(new EventMonitoringUtil.EventTypeStatus(eventType, true, defaultLogsLimit));
            }
        }
        EventMonitoringUtil.setEventTypesStatuses(eventTypeStatuses);
        DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
        return ConfigUtil.EVENT_MONITORING_SETTINGS;
    }

    public static Map<String, Object> setBatchErrorTrackingSetting(Object data) {
        if (!PermissionsUtil.AsyncProcessErrorTracking) return new Map<String, Object>();
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        ConfigUtil.SETTINGS.Batch_Error_Tracking_Enabled__c = Boolean.valueOf(input.get(ConfigUtil.MONITORING_APP_KEY_ENABLED));
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        return getBatchErrorTrackingSetting(null);
    }

    public static void disableBatchErrorTrackingAndEmailToCaseErrorTracking() {
        PermissionsUtil.putSObjectField(ConfigUtil.SETTINGS, Schema.SObjectType.Logger_Settings__c.fields.Enable_Email_To_Case_Error_Tracking__c, Constants.LOGGER_SETTINGS_SOBJECT.ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_DISABLED);
        PermissionsUtil.putSObjectField(ConfigUtil.SETTINGS, Schema.SObjectType.Logger_Settings__c.fields.Batch_Error_Tracking_Enabled__c, false);
        DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        
    }

    public static Map<String, Object> getBatchErrorTrackingSetting(Object data) {
        Map<String, Object> ret = new Map<String, Object>();
        ret.put(ConfigUtil.BATCH_ERROR_TRACKING_ENABLED, ConfigUtil.SETTINGS.Batch_Error_Tracking_Enabled__c);
        return ret;
    }

    public static Map<String, Object> setErrorReportingOptOut(Object data) {
        if (!PermissionsUtil.MandatoryErrorReportingEnabled) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c = Boolean.valueOf(input.get(ConfigUtil.ERROR_REPORTING_OPT_OUT));
            DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        }
        return getErrorReportingOptOut();
    }

    public static Map<String, Object> getErrorReportingOptOut() {
        Map<String, Object> output = new Map<String, Object>();
        output.put(ConfigUtil.ERROR_REPORTING_OPT_OUT, ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c);
        return output;
    }

    public static Map<String, Object> deleteRule(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String ruleId = String.valueOf(input.get(RuleUtil.KEY_RULE_ID));
        Map<String, Object> output = new Map<String, Object>();
        List<Rule__c> rules = [SELECT Id, Type__c FROM Rule__c WHERE Id = :ruleId LIMIT 1];
        if (!rules.isEmpty()) {
            Database.DeleteResult deleteResult = RuleUtil.deleteRule(ruleId);
            if (deleteResult.isSuccess()) RuleUtil.reIndexRules(rules[0].Type__c);
            output.put(RuleUtil.KEY_SUCCESS, deleteResult.isSuccess());
            output.put(RuleUtil.KEY_MESSAGE, deleteResult.getErrors());
            output.put(RuleUtil.KEY_RULES, RuleUtil.getRuleWrappers(rules[0].Type__c));
        } else {
            output.put(RuleUtil.KEY_SUCCESS, false);
            output.put(RuleUtil.KEY_MESSAGE, RuleUtil.KEY_MESSAGE_PARAMS_RULE_ID_NOT_FOUND);
        }
        return output;
    }

    public static Map<String, Object> deleteRuleAction(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        return RuleUtil.deleteRuleAction(String.valueOf(input.get(RuleUtil.KEY_RULE_ACTION_ID)));
    }
    
    public static Map<String, Object> deleteAction(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        return RuleUtil.deleteAction(String.valueOf(input.get(RuleUtil.KEY_ACTION_ID)));
    }
    
    public static List<Rule__c> validateRuleFilters(List<RuleUtil.Rule> rules) {
        List<Rule__c> toUpdate = new List<Rule__c>();
        if(!rules.isEmpty()) {
            Boolean ruleNotValid = false;
            if(rules.get(0).type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) {
                try {
                    DateTime lastProcessedDatetime = DateTime.now();
                    DateTime ruleStartTime = Datetime.now();
                    List<String> logFields = RuleUtil.getLogFieldNames(rules);
                    QBuilder qb = RetentionBatch.getArchivalLogsQuery(rules.get(0), new Set<String>(logFields), lastProcessedDatetime, ruleStartTime);
                    qb.addLimit(1);
                    String qbQuery = qb.build();
                    List<Log__c> logs = Database.query(qbQuery);
                }
                catch(Exception e) {
                    ruleNotValid = true;
                }
                if(rules.get(0).ruleFilters == null || rules.get(0).ruleFilters.isEmpty()) {
                    ruleNotValid = true;
                }
            }
            if(rules.get(0).type.equals(Constants.RULE_SOBJECT.TYPE_MONITORING)) {
                try {
                    DateTime lastProcessedDatetime = DateTime.now();
                    QBuilder qbCount = MonitoringService.buildMonitoringLogsQuery(rules.get(0), new Set<String>{'COUNT()'});
                    String qbCountQuery = qbCount.build();
                    Integer countLogs = Database.countQuery(qbCountQuery);

                    List<String> logFields = RuleUtil.getLogFieldNames(rules);
                    QBuilder qb = MonitoringService.buildMonitoringLogsQuery(rules.get(0), new Set<String>(logFields));
                    qb.addLimit(1);
                    String qbQuery = qb.build();
                    List<Log__c> logs = Database.query(qbQuery);
                }
                catch(Exception e) {
                    ruleNotValid = true;
                }
            }
            if (rules[0].type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE) {
                try {
                    List<String> jiraLogFields = RuleUtil.getLogFieldNames(rules);
                    String query = new QBuilder(Log__c.SObjectType)
                        .selectFields(new Set<String>(jiraLogFields))
                        .addLimit(1)
                        .build();
                    List<Log__c> logs = Database.query(query);
                }
                catch(Exception e) {
                    ruleNotValid = true;
                }
            }
            if(rules.get(0).type.equals(Constants.RULE_SOBJECT.TYPE_NOTIFICATION)) {
                try {
                    List<String> logFields = RuleUtil.getLogFieldNames(rules);
                    String query = new QBuilder(Log__c.SObjectType)
                        .selectFields(new Set<String>(logFields))
                        .addLimit(1)
                        .build();
                    List<Log__c> logs = Database.query(query);
                }
                catch(Exception e) {
                    ruleNotValid = true;
                }
            }
            if(rules.get(0).type == null) {
                ruleNotValid = true;
            }
            Boolean isNotValidRuleFields = isRuleNotValid(rules.get(0));
            if(isNotValidRuleFields && !ruleNotValid) {
                ruleNotValid = isNotValidRuleFields;
            }
            toUpdate.add(new Rule__c(Id = rules.get(0).id, Is_Not_Valid__c = ruleNotValid));
        }
        return toUpdate;
    }

    public static Boolean isRuleNotValid(RuleUtil.Rule rule) {
        Boolean ruleNotValid = false;
        if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) {
            ruleNotValid = isNotValidArchivalRule(rule);
        }
        if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_MONITORING)) {
            ruleNotValid = isNotValidMonitoringRule(rule);
        }
        if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE)) {
            ruleNotValid = isNotValidJiraUpdateRule(rule);
        }
        if(rule.type.equals(Constants.RULE_SOBJECT.TYPE_NOTIFICATION)) {
            ruleNotValid = isNotValidNotificationRule(rule);
        }
        return ruleNotValid;
    }

    public static Boolean isNotValidArchivalRule(RuleUtil.Rule rule) {
        return (rule.eventTimeInterval == null
            || (rule.actions == null
            || rule.actions.isEmpty()
            || rule.ruleFilters == null
            || rule.ruleFilters.isEmpty()));
    }

    public static Boolean isNotValidMonitoringRule(RuleUtil.Rule rule) {
        return (rule.eventTimeInterval == null
            || rule.threshold == null
            || String.isBlank(rule.subtype)
            || (rule.actions == null
            || rule.actions.isEmpty()));
    }

    public static Boolean isNotValidJiraUpdateRule(RuleUtil.Rule rule) {
        return (rule.actions == null || rule.actions.isEmpty());
    }

    public static Boolean isNotValidNotificationRule(RuleUtil.Rule rule) {
        return (rule.actions == null || rule.actions.isEmpty());
    }

    public static Map<String, Object> setRuleIndex(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        RuleUtil.Rule ruleWrapper = (RuleUtil.Rule)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_RULE)), RuleUtil.Rule.class);
        Rule__c rule = ruleWrapper.getRule();
        List<Rule__c> currentRule = [SELECT Id, Index__c FROM Rule__c WHERE Id = :rule.Id LIMIT 1];
        Rule__c currentRuleToUpdate = new Rule__c(Id = rule.Id, Index__c = rule.Index__c);
        if (!currentRule.isEmpty() && currentRule[0].Index__c != null) {
            List<Rule__c> ruleWithOldIndex = [SELECT Id, Index__c FROM Rule__c WHERE Index__c = : rule.Index__c AND Type__c IN : RuleUtil.addAllTicketingRuleTypes(rule.Type__c)];
            if (!ruleWithOldIndex.isEmpty()) {
                Rule__c ruleWithOldIndexToUpdate = new Rule__c(Id = ruleWithOldIndex[0].Id, Index__c = currentRule[0].Index__c);
                DatabaseUtils.getInstance().performUpdateDML(new List<Rule__c>{ruleWithOldIndexToUpdate}, Schema.SObjectType.Rule__c, true);
            }
        }
        DatabaseUtils.getInstance().performUpdateDML(new List<Rule__c>{currentRuleToUpdate}, Schema.SObjectType.Rule__c, true);
        RuleUtil.reIndexRules(RuleUtil.addAllTicketingRuleTypes(rule.Type__c));
        return new Map<String, Object>{RuleUtil.KEY_RULES => RuleUtil.getRuleWrappers(null, RuleUtil.addAllTicketingRuleTypes(rule.Type__c))};
    }

    private static RuleUtil.Rule getMonitoringRuleWrapper(RuleUtil.Rule rule, Map<String, Object> input) {
        RuleUtil.Rule ruleWrapper = (RuleUtil.Rule)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_RULE)), RuleUtil.Rule.class);
        ruleWrapper.type = rule.type;
        ruleWrapper.eventTimeInterval = rule.eventTimeInterval;
        ruleWrapper.sobjectType = rule.sobjectType;
        ruleWrapper.subtype = rule.subtype;
        ruleWrapper.threshold = rule.threshold;

        ruleWrapper.aggregateType = rule.aggregateType;
        ruleWrapper.eventTimeInterval = rule.eventTimeInterval;
        ruleWrapper.aggregateInterval = rule.aggregateInterval;
        ruleWrapper.comparisonOperator = rule.comparisonOperator;
        
        ruleWrapper.actions = (List<RuleUtil.Action>)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_ACTIONS)), List<RuleUtil.Action>.class);
        ruleWrapper.ruleFilters = new List<RuleUtil.RuleFilter>();
        ruleWrapper.groupFieldNames = new Set<String>();
        ruleWrapper.isUpdateRule = (rule.isUpdateRule == null) ? false : rule.isUpdateRule;

        List<RuleUtil.RuleFilter> ruleFilters = new List<RuleUtil.RuleFilter>();
        ruleFilters.sort();
        for(RuleUtil.RuleFilter rf : (List<RuleUtil.RuleFilter>)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_RULE_FILTERS)), List<RuleUtil.RuleFilter>.class)) {
            ruleFilters.add(new RuleUtil.RuleFilter(rf.index, rf.comparisonType, rf.comparisonOperator, rf.fieldName, rf.value, ruleWrapper.sobjectType, rf.isOld));
        }
        ruleWrapper.addFilters(ruleFilters);
        return ruleWrapper;
    }

    public static final String RULE_FILTER_LOGIC_NOT_VALID = 'Rule filter logic not valid';
    public static final String RULE_NOT_VALID = 'Rule not valid';
    public static final String RULE_MAX_ACTIVE_RULES_REACHED = 'Max number of active rules reached: ';

    public static void validateMaxActiveRules(String type, String ruleId, Boolean isActive) {
        if(String.isNotBlank(type)) {
            RuleUtil.RuleType ruleType = RuleUtil.MAP_RULE_TYPE.get(type);
            Integer limitRules = 100;

            switch on ruleType {
                when MONITORING {
                    limitRules = LimitsService.getMaxMonitoringRules();
                }
                when ARCHIVAL {
                    limitRules = LimitsService.getMaxArchivalRules();
                }
                when JIRA_UPDATE, AZURE_DEV_OPS {
                    limitRules = LimitsService.getMaxJiraRules();
                }
                when NOTIFICATION {
                    limitRules = LimitsService.getMaxNotificationRules();
                }
            }
            
            // If limitRules is null, it means unlimited - skip validation
            if (limitRules != null) {
                Integer rulesCount = [SELECT COUNT() FROM Rule__c WHERE Type__c = :type AND Active__c = TRUE];
                Boolean oldActvieValue = String.isNotBlank(ruleId) 
                    ? [SELECT Active__c FROM Rule__c WHERE Id = :ruleId LIMIT 1].Active__c
                    : false;
                Integer newRuleCount = String.isNotBlank(ruleId) 
                    ? (oldActvieValue ? 0 : 1) 
                    : 1;
                if(isActive && (rulesCount + newRuleCount > limitRules)) {
                    throw new AdminServiceValidationException(RULE_MAX_ACTIVE_RULES_REACHED + limitRules);
                }
            }
        }
    }

    public static Map<String, Object> setRule(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Boolean isOnlyRuleData = input.containsKey(RuleUtil.KEY_RULE)
            && !input.containsKey(RuleUtil.KEY_RULE_ACTIONS)
            && !input.containsKey(RuleUtil.KEY_ACTIONS)
            && !input.containsKey(RuleUtil.KEY_RULE_FILTERS);
        RuleUtil.Rule deserializedRuleWrapper = (RuleUtil.Rule)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_RULE)), RuleUtil.Rule.class);
        String type = deserializedRuleWrapper?.type;
        if (!PermissionsUtil.UpdateRules && deserializedRuleWrapper?.isUpdateRule == true && (type == Constants.RULE_SOBJECT.TYPE_NOTIFICATION || type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE || type == Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS)) {
            return getRuleSettings(type);
        }

        // FIRST: Create Remote Site Settings for webhook actions (BEFORE any DML)
        // Collect all webhook URLs and make synchronous callout(s)
        if (!isOnlyRuleData && PermissionsUtil.WebhookIntegrationEnabled
            && input.get(RuleUtil.KEY_ACTIONS) != null) {
            Set<String> webhookUrls = new Set<String>();
            List<RuleUtil.Action> actions = (List<RuleUtil.Action>)JSON.deserialize(
                JSON.serialize(input.get(RuleUtil.KEY_ACTIONS)),
                List<RuleUtil.Action>.class
            );
            for (RuleUtil.Action actionWrapper : actions) {
                if (actionWrapper.type == Constants.ACTION_SOBJECT.ACTION_TYPE_WEBHOOK_NOTIFICATION
                    && String.isNotBlank(actionWrapper.webhookUrl)) {
                    webhookUrls.add(actionWrapper.webhookUrl);
                }
            }
            if (!webhookUrls.isEmpty()) {
                // Make synchronous callout(s) BEFORE any DML operations
                upsertWebhookRemoteSiteSettings(webhookUrls);
            }
        }
        if(!isOnlyRuleData) {
            RuleUtil.Rule ruleWrapper = getMonitoringRuleWrapper(deserializedRuleWrapper, input);
            if(ruleWrapper != null) {
                if(String.isNotBlank(ruleWrapper.filterLogic)) {
                    // validate expression
                    ConfigUtil.BooleanExpressionParser parser = new ConfigUtil.BooleanExpressionParser(ruleWrapper.filterLogic);
                    if(!parser.isValidExpression()) {
                        throw new AdminServiceValidationException(RULE_FILTER_LOGIC_NOT_VALID);
                    }
                    // validate expression & rule filters
                    Set<String> operands = parser?.getOperands();
                    if(operands != null && !operands.isEmpty()) {
                        for (RuleUtil.RuleFilter rf : ruleWrapper.ruleFilters) {
                            if (RuleUtil.MAP_COMPARISON_TYPES_BY_STRINGS.get(rf.comparisonType) == RuleUtil.ComparisonType.FIELD) {
                                continue;
                            }
                            Integer filterIndex = Integer.valueOf(rf.index);
                            if(ruleWrapper.type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) {
                                if(filterIndex == 1 && ruleWrapper.filterLogic != '1') {
                                    continue;
                                }
                                else if(filterIndex == 1 && ruleWrapper.filterLogic == '1') {
                                    operands.remove(String.valueOf(filterIndex));
                                }
                                else {
                                    filterIndex -= 1;
                                }
                            }
                            if (filterIndex == 1 || operands.contains(String.valueOf(filterIndex))) {
                                operands.remove(String.valueOf(filterIndex));
                            } else {
                                throw new AdminServiceValidationException(RULE_FILTER_LOGIC_NOT_VALID);
                            }
                        }
                        if(!operands.isEmpty() 
                            && ruleWrapper.type.equals(Constants.RULE_SOBJECT.TYPE_MONITORING) 
                            && (ruleWrapper.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_IMPACT)
                                || ruleWrapper.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_SPIKE)
                                || ruleWrapper.subtype.equals(Constants.RULE_SOBJECT.SUB_TYPE_FREQUENCY))
                            && ruleWrapper?.ruleFilters?.isEmpty()) {
                            operands.clear();
                        }
                        if(!operands.isEmpty()) {
                            throw new AdminServiceValidationException(RULE_FILTER_LOGIC_NOT_VALID);
                        }
                    }
                }
                // validate soql with rule filters by logic expression
                List<Rule__c> checkRuleFilterRecords = validateRuleFilters(new List<RuleUtil.Rule>{ruleWrapper});
                Rule__c resultRule = checkRuleFilterRecords.get(0);
                if(resultRule.Is_Not_Valid__c) {
                    throw new AdminServiceValidationException(RULE_NOT_VALID);
                }

                // validate rule filter values
                try {
                    List<SObject> testData = generateSObjectsForEvaluateRuleFilters(ruleWrapper);
                    Schema.SObjectField ruleSubType = (ruleWrapper.subtype == Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME) 
                        ? Trace_Result__c.Issue__c.getDescribe().getSObjectField()
                        : null;
                    ruleWrapper.applyNotificationRules(testData, ruleSubType);
                }
                catch(Exception e) {
                    throw new AdminServiceValidationException(RULE_NOT_VALID);
                }
            }
        }

        if(!isOnlyRuleData && deserializedRuleWrapper?.type.equals(Constants.RULE_SOBJECT.TYPE_ARCHIVAL)) {
            List<RuleUtil.RuleFilter> currentRuleFilters = new List<RuleUtil.RuleFilter>();
            if (input.get(RuleUtil.KEY_RULE_FILTERS) != null) {
                currentRuleFilters = (List<RuleUtil.RuleFilter>)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_RULE_FILTERS)), List<RuleUtil.RuleFilter>.class);
                currentRuleFilters.sort();
            }
            Boolean isChangedRuleFilterLogicOrFilters = isChangedRuleFilterLogicOrFilters(deserializedRuleWrapper, currentRuleFilters);
            if(isChangedRuleFilterLogicOrFilters) {
                List<Event__c> relatedEvents = [SELECT Id FROM Event__c WHERE Rule__c = :deserializedRuleWrapper.Id LIMIT 1000];
                DatabaseUtils.getInstance().performDeleteDML(relatedEvents, Schema.SObjectType.Event__c, true);
            }
        }

        Rule__c rule = deserializedRuleWrapper.getRule();
        validateMaxActiveRules(rule?.Type__c, rule?.Id, rule?.Active__c);
        validateJiraActions(deserializedRuleWrapper, JSON.serialize(input.get(RuleUtil.KEY_ACTIONS)));
        
        RuleUtil.setRuleIndex(rule);
        DatabaseUtils.getInstance().performUpsertDML(new List<Rule__c>{rule}, Schema.SObjectType.Rule__c, true);
        RuleUtil.reIndexRules(rule.Type__c);
        if(!isOnlyRuleData) {
            RuleUtil.upsertRuleFilters(input, rule.Id);
            if (input.get(RuleUtil.KEY_RULE_ACTIONS) != null && input.get(RuleUtil.KEY_ACTIONS) != null) {
                String recordTypeName = rule.Type__c == Constants.ACTION_SOBJECT.RT_ARCHIVAL ? Constants.ACTION_SOBJECT.RT_ARCHIVAL : Constants.ACTION_SOBJECT.RT_MONITORING;
                RuleUtil.upsertRuleActionsWithActions(JSON.serialize(input.get(RuleUtil.KEY_ACTIONS)), JSON.serialize(input.get(RuleUtil.KEY_RULE_ACTIONS)), rule.Id, recordTypeName);
            }
        }
        return getRuleSettings(rule.Type__c);
    }

    public static void validateJiraActions(RuleUtil.Rule ruleWrapper, String actionsJSON) {
        if(ruleWrapper.type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE) {
            List<RuleUtil.Action> actions = (List<RuleUtil.Action>)JSON.deserialize(actionsJSON, List<RuleUtil.Action>.class);
            for(RuleUtil.Action actionWrapper : actions) {
                // getAction start validation of jira custom fields
                Action__c action = actionWrapper.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
            }
        }
    }

    public static List<Action__c> setActions(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        List<RuleUtil.Action> actionWrappers = (List<RuleUtil.Action>)JSON.deserialize(JSON.serialize(input.get(RuleUtil.KEY_ACTIONS)), List<RuleUtil.Action>.class);
        List<Action__c> actionsToCreate = new List<Action__c>();
        List<Action__c> actionsToUpsert = new List<Action__c>();

        for (RuleUtil.Action actionWrapper : actionWrappers) {
            Action__c action = actionWrapper.getAction(Constants.ACTION_SOBJECT.RT_MONITORING);
            if (action.Id == null) {
                actionsToCreate.add(action);
            } else {
                actionsToUpsert.add(action);
            }
        }
        if (!actionsToCreate.isEmpty()) {
            DatabaseUtils.getInstance().performInsertDML(actionsToCreate, Schema.SObjectType.Action__c, true);
        }
        if (!actionsToUpsert.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(actionsToUpsert, Schema.SObjectType.Action__c, true);
        }
        
        return actionsToCreate;
    }

    public static Boolean isChangedRuleFilterLogicOrFilters(RuleUtil.Rule mRule, List<RuleUtil.RuleFilter> currentRuleFilters) {
        Boolean result = false;
        if(String.isNotBlank(mRule.id)) {
            List<RuleUtil.Rule> rules = RuleUtil.getRuleWrappers(mRule.id, mRule.type);
            if(!rules.isEmpty()) {
                RuleUtil.Rule rule = rules.get(0);
                if(String.isNotBlank(rule.filterLogic) && String.isNotBlank(mRule.filterLogic)
                    && rule.filterLogic != mRule.filterLogic) {
                    result = true;
                    return result;
                }
                if(currentRuleFilters?.size() != rule?.ruleFilters?.size()) {
                    result = true;
                    return result;
                }
                Set<String> filtersMap = new Set<String>();
                for(RuleUtil.RuleFilter rf : rule.ruleFilters) {
                    if(rf.index == 1) continue;
                    String key = JSON.serialize(rf.index) + JSON.serialize(rf.fieldName) + JSON.serialize(rf.value) + JSON.serialize(rf.comparisonOperator);
                    filtersMap.add(key);
                }
                for(RuleUtil.RuleFilter rf : currentRuleFilters) {
                    if(rf.index == 1) continue;
                    String key = JSON.serialize(rf.index) + JSON.serialize(rf.fieldName) + JSON.serialize(rf.value) + JSON.serialize(rf.comparisonOperator);
                    filtersMap.remove(key);
                }
                
                if(!filtersMap.isEmpty()) {
                    result = true;
                    return result;
                }
            }
        }
        
        return result;
    }

    public static List<SObject> generateSObjectsForEvaluateRuleFilters(RuleUtil.Rule rule) {
        List<SObject> result = new List<SObject>();

        Schema.SObjectField ruleSubType = (rule.subtype == Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME) 
            ? Trace_Result__c.Issue__c.getDescribe().getSObjectField()
            : null;
        String sobjectType = rule.sobjectType == null ? Schema.SObjectType.Log__c.getName() : rule.sobjectType;

        Type t = Type.forName(sobjectType);  
        Map<String, Object> sobjectMap = new Map<String, Object>();

        for(RuleUtil.RuleFilter filter : rule.ruleFilters) {
            if(RuleUtil.MAP_COMPARISON_TYPES_BY_STRINGS.get(filter.comparisonType) == RuleUtil.ComparisonType.VALUE) {
                Object testValue;
                switch on filter.getFieldType() {
                    when FT_BOOLEAN {
                        testValue = true;
                    }
                    when FT_ID, FT_PICKLIST, FT_REFERENCE, FT_STRING, FT_TEXTAREA, FT_URL {
                        testValue = 'someString';
                    }
                    when FT_NUMBER, FT_DOUBLE {
                        testValue = Decimal.valueOf(1377);
                    }
                    when FT_DATE {
                        testValue = Date.today();
                    }
                    when FT_DATETIME {
                        testValue = DateTime.now();
                    }
                }
                sobjectMap.put(filter.fieldName, testValue);
            }
        }
        SObject sobjectRecord;
        if(ruleSubType != null) {
            Schema.DescribeFieldResult ruleSubTypeDescribe = ruleSubType.getDescribe();
            Type innerType = Type.forName(ruleSubTypeDescribe.getName());
            SObject innerSobjectRecord = (SObject)JSON.deserialize(JSON.serialize(sobjectMap), innerType);
            sobjectRecord = (SObject)JSON.deserialize(JSON.serialize(new Map<String, Object>()), t);
            sobjectRecord.putSObject(ruleSubType, innerSobjectRecord);
        }
        else {
            sobjectRecord = (SObject)JSON.deserialize(JSON.serialize(sobjectMap), t);
        }
        result.add(sobjectRecord);
        return result;
    }

    private static final Map<Integer, String> MAP_EXPRESSIONS = new Map<Integer, String>{
            60 => '1',
            240 => '4',
            480 => '8',
            1440 => '24',
            10080 => '168'
    };

    public static Map<String, Object> getScheduleBulkAPIBatch() {
        Integer cronParameter;
        if (String.isNotBlank(ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c)) {
            for (Integer key : MAP_EXPRESSIONS.keySet()) {
                if (ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c == MAP_EXPRESSIONS.get(key)) {
                    cronParameter = key;
                }
            }
        }
        return new Map<String, Object>{'cronParameter' => cronParameter};
    }

    public static Map<String, Object> abortScheduleBulkAPIBatch() {
        ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c = null;
        upsert ConfigUtil.PHAROS_SETTINGS;
        return new Map<String, Object>{'abort' => true};
    }

    private static final String DEFAULT_BULK_FREQUENCY_HOURS = '4';

    public static Map<String, Object> scheduleBulkAPIBatch(Object data) {
        if (!PermissionsUtil.AsyncProcessErrorTracking) return new Map<String, Object>();
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        try {
            if (Integer.valueOf(input.get('cronParameter')) == 0) {
                BulkAPIJobBatchScheduler.getInstance(null).forceStartBatch();
            } else if (MAP_EXPRESSIONS.containsKey(Integer.valueOf(input.get('cronParameter')))) {
                ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c = MAP_EXPRESSIONS.get(Integer.valueOf(input.get('cronParameter')));
                upsert ConfigUtil.PHAROS_SETTINGS;
            }
        } catch (Exception e) {
            ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c = DEFAULT_BULK_FREQUENCY_HOURS;
            upsert ConfigUtil.PHAROS_SETTINGS;
        }
        return new Map<String, Object>{'isScheduled' => true};
    }

    public static Map<String, Object> runJobBatchImmediately() {
        JobBatch.getInstance().forceStartBatch();
        return new Map<String, Object>{'isScheduled' => true};
    }

    // data for logs charts
    public static String getOccurrenceLogs(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        Log__c currentLog = (Log__c)JSON.deserialize(JSON.serialize(input.get('currentLog')), Log__c.class);
        String showDays = (input.get('showDays') != null) ? (String)input.get('showDays') : null;
        Date endDate;
        Date startDate;

        currentLog = [
            SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
            FROM Log__c
            WHERE Id = :currentLog.Id
        ];

        if (showDays == '7' || showDays == '30' || showDays == '60' || showDays == '180') {
            endDate = Date.today();
            startDate = endDate.addDays(-1 * Integer.valueOf(showDays));
        } else {
            endDate = Date.today();
            startDate = endDate.addDays(-30);
        }

        List<Log__c> logsWithHash1 = [
            SELECT Id, Created_At__c
            FROM Log__c
            WHERE (Hash_1__c = :currentLog.Hash_1__c AND
                      Organization_Id__c = :currentLog.Organization_Id__c AND
                  Hash_1__c != null AND
                  DAY_ONLY(Created_At__c) >= :startDate AND
                  DAY_ONLY(Created_At__c) <= :endDate) OR
                  Id = :currentLog.Id
            ORDER BY Created_At__c];
        List<Log__c> logsWithHash2 = [
            SELECT Id, Created_At__c
            FROM Log__c
            WHERE Hash_2__c = :currentLog.Hash_2__c AND
                  Organization_Id__c = :currentLog.Organization_Id__c AND
                  Hash_2__c != null AND
                  DAY_ONLY(Created_At__c) >= :startDate AND
                  DAY_ONLY(Created_At__c) <= :endDate AND
                  Id != :currentLog.Id
            ORDER BY Created_At__c];
        List<Log__c> logsWithHash3 = [
            SELECT Id, Created_At__c
            FROM Log__c
            WHERE Hash_3__c = :currentLog.Hash_3__c AND
                  Organization_Id__c = :currentLog.Organization_Id__c AND
                  Hash_3__c != null AND
                  DAY_ONLY(Created_At__c) >= :startDate AND
                  DAY_ONLY(Created_At__c) <= :endDate AND
                  Id != :currentLog.Id
            ORDER BY Created_At__c];

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('hash1', logsWithHash1);
        dataMap.put('hash2', logsWithHash2);
        dataMap.put('hash3', logsWithHash3);
        String result = JSON.serialize(dataMap);
        return result;
    }

    public static String getInstalledVersion() {
        String result = 'Unmanaged';
        if(isManaged()) {
            try {
                result = System.requestVersion().major() + '.' + System.requestVersion().minor() +
                    ((System.requestVersion().patch() != null) ? ('.' + System.requestVersion().patch()) : '');
            }
            catch(Exception e) {}
        }
        return result;
    }

    public static Boolean isManaged(){
        return ConfigUtil.PHAROS_PACKAGE_PUBLISHER_NAMESPACE == ConfigUtil.getNameSpace();
    }

    public static SubscriptionInfo getSubscriptionInfo() {
        SubscriptionInfo info = new SubscriptionInfo();
        info.edition = PermissionsUtil.ChargifyProductEdition;

        List<PackageLicense> currentLicense = [
            SELECT Id, Status, IsProvisioned, AllowedLicenses, UsedLicenses, ExpirationDate, CreatedDate, NamespacePrefix
            FROM PackageLicense
            WHERE NamespacePrefix = :ConfigUtil.NS
            LIMIT 1
        ];
        if(!currentLicense.isEmpty()) {
            info.status = currentLicense.get(0).Status;
            info.expired = currentLicense.get(0).ExpirationDate;
        }

        return info;
    }

    public class SubscriptionInfo {
        public String edition;
        public String status;
        public DateTime expired;

        public SubscriptionInfo(){}
    }

    public class SensitiveDataMaskWrapper {
        public String id;
        public String name;
        public String regex;
        public String description;

        public SensitiveDataMaskWrapper() {}

        public SensitiveDataMaskWrapper(SensitiveDataMask__c mask) {
            id = mask.Name;
            name = mask.Name;
            regex = mask.Regex__c;
            description = mask.Description__c;
        }
    }

    public class ChangeTrackingSettings {
        public Boolean gitChangeTracking;

        public ChangeTrackingSettings(Change_Tracking__c settings) {
            this.gitChangeTracking = settings.Git_Change_Tracking__c;
        }
    }

    public class SObjectsCreateResponse {
        public String id;
        public Boolean success;
    }

    public class DebugLogServiceSettings {
        public Boolean enabled;
        public String traceWindow;
        public DateTime lastCreatedLog;
        public DateTime lastProcessedLog;

        public DebugLogServiceSettings(Debug_Log_Service_Flag__c settings) {
            this.enabled = settings.Enabled__c;
            this.traceWindow = settings.Trace_Window__c;
            this.lastCreatedLog = settings.Last_Created_Log__c;
            this.lastProcessedLog = settings.Last_Processed_Log__c;
        }
    }

    public static DebugLogServiceSettings getDebugLogServiceSettings() {
        DebugLogServiceSettings settings = new DebugLogServiceSettings(ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS);
        return settings;
    }

    public static String saveDebugLogServiceSettings(Object debugLogServiceSettingsObject) {
        DebugLogServiceSettings settings = (DebugLogServiceSettings)JSON.deserialize(JSON.serialize(debugLogServiceSettingsObject), DebugLogServiceSettings.class);

        if (settings.enabled != null) {
            ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Enabled__c = settings.enabled;
        }
        if (settings.traceWindow != null) {
            ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Trace_Window__c = settings.traceWindow;
        }

        AdminService.upsertRemoteSiteSetting(TraceService.DEBUG_LOG_SERVICE_NAME, TraceService.DEBUG_LOG_SERVICE_ENDPOINT, TraceService.DEBUG_LOG_SERVICE_DESCRIPTION);

        DatabaseUtils.getInstance().performUpsertDML(new List<Debug_Log_Service_Flag__c>{ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS}, Schema.SObjectType.Debug_Log_Service_Flag__c, true);

        return Constants.UI.RESULT_SUCCESS;
    }


    public class AdminServiceException extends Exception {}
    public class AdminServiceValidationException extends Exception {}

    public static PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper getPlatformEventSubscriberConfigLogEvent() {
        PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper result;
        try {
            result = new PlatformEventSubscriberConfigService(Log_Event__e.SObjectType).getPlatformEventSubscriberConfig(true);
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'getPlatformEventSubscriberConfigLogEvent');
        }
        return result;
    }

    public static PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper getPlatformEventSubscriberConfigAIEvent() {
        PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper result;
        try {
            result = new PlatformEventSubscriberConfigService(AI_Event__e.SObjectType).getPlatformEventSubscriberConfig(true);
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'getPlatformEventSubscriberConfigAIEvent');
        }
        return result;
    }

    public static PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper setPlatformEventSubscriberConfigLogEvent(String userId) {
        PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper result;
        try {
            result = new PlatformEventSubscriberConfigService(Log_Event__e.SObjectType).setPlatformEventSubscriberConfig(userId);
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'setPlatformEventSubscriberConfigLogEvent');
        }
        return result;
    }

    public static PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper setPlatformEventSubscriberConfigAIEvent(String userId) {
        PlatformEventSubscriberConfigService.PlatformEventSubscriberConfigWrapper result;
        try {
            result = new PlatformEventSubscriberConfigService(AI_Event__e.SObjectType).setPlatformEventSubscriberConfig(userId);
        } catch (HttpUtils.HttpUtilsException e) {
            debugSession(e, 'setPlatformEventSubscriberConfigAIEvent');
        }
        return result;
    }

    public static void debugSession(HttpUtils.HttpUtilsException e, String apexName) {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
        Log__c errorLog = Logger.getInstance().getInternalError(
                e,
                null,
                AdminService.class.getName(),
                apexName
        );
        String orgId = UserInfo.getOrganizationId().substring(0, 15);
        String sessionDetails = ConfigUtil.USER_SESSION_ID?.substring(15);
        String sessionDetailsRevers = ConfigUtil.USER_SESSION_ID?.substring(15)?.reverse();
        String accessToken = corg?.Access_Token__c?.substring(15);
        String accessTokenRevers = corg?.Access_Token__c?.substring(15)?.reverse();
        String selfOrgToken = ConnectedOrgService.getSelfConnectedOrgAccessToken()?.substring(15);
        String selfOrgTokenRevers = ConnectedOrgService.getSelfConnectedOrgAccessToken()?.substring(15)?.reverse();

        errorLog.Details__c = String.format(
                'USER_SESSION_ID: {0} {1} [{2}]\n' +
                        'Use_Oauth_for_Self_Org: {3}\n' +
                        'Client_Key isNotBlank: {4}\n' +
                        'Client_Secret isNotBlank: {5}\n' +
                        'Access_Token isNotBlank: {6}\n' +
                        'Access_Token: {0} {7} [{8}]\n' +
                        'Access_Token: {0} {9} [{10}]\n' +
                        '\n{11}'
                ,
                new List<String>{
                        orgId,
                        sessionDetails,
                        sessionDetailsRevers,
                        String.valueOf(ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c),
                        String.valueOf(String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c)),
                        String.valueOf(String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c)),
                        String.valueOf(String.isNotBlank(corg?.Access_Token__c)),
                        accessToken,
                        accessTokenRevers,
                        selfOrgToken,
                        selfOrgTokenRevers,
                        errorLog.Details__c
                }
        );
        Logger.getInstance().add(errorLog);
    }

    public class FlowWrapper {
        public String apiName;
        public String label;
        public String versionNumber;
        public String namespacePrefix;

        public List<FlowVersionWrapper> versions;

        public FlowWrapper(FlowDefinitionView flowDefinitionView) {
            this.apiName = flowDefinitionView?.ApiName;
            this.label = flowDefinitionView?.Label;
            this.versionNumber = (String.isNotBlank(flowDefinitionView?.ActiveVersionId)) ? String.valueOf(flowDefinitionView?.VersionNumber) : null;
            this.namespacePrefix = flowDefinitionView?.NamespacePrefix;
            this.versions = new List<FlowVersionWrapper>();
        }

        public void addVersion(FlowVersionView flowVersionView) {
            this.versions.add(new FlowVersionWrapper(flowVersionView));
        }
    }

    public class FlowVersionWrapper {
        public String versionNumber;
        public String status;
        public String label;

        public FlowVersionWrapper(FlowVersionView flowVersionView) {
            this.versionNumber = String.valueOf(flowVersionView?.VersionNumber);
            this.status = flowVersionView?.Status;
            this.label = this.versionNumber + ' (' + this.status + ')';
        }
    }

    public static List<FlowDefinitionView> getFlowDefinitionByApiName(String flowApiName) {
        return [
            SELECT Id, ApiName, Label, VersionNumber, ActiveVersionId, NamespacePrefix, DurableId
            FROM FlowDefinitionView 
            WHERE ApiName = :flowApiName
            LIMIT 1
        ];
    }

    public static List<FlowVersionView> getFlowVersionByDefenitionIdAndVersion(String flowId, Integer versionNumber) {
        return [
            SELECT Id, VersionNumber, Status, FlowDefinitionViewId, DurableId
            FROM FlowVersionView
            WHERE FlowDefinitionViewId = :flowId AND VersionNumber = :versionNumber
            LIMIT 1
        ];
    }

    public static Object addFlowLogging(Object data) {
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String selectedFlowApiName = (String)dataMap.get('selectedFlow');
        String selectedVersion = (String)dataMap.get('selectedVersion');
        Integer selectedVersionNumber = Integer.valueOf(selectedVersion);

        List<FlowDefinitionView> flows = getFlowDefinitionByApiName(selectedFlowApiName);
        if(flows.isEmpty()) {
            throw new AdminServiceException('Flow with api name ' + selectedFlowApiName + ' not found');
        }

        List<FlowVersionView> flowVersions = getFlowVersionByDefenitionIdAndVersion(flows.get(0).DurableId, selectedVersionNumber);
        if(flowVersions.isEmpty()) {
            throw new AdminServiceException('Flow version with api name ' + selectedFlowApiName + ' and version number ' + selectedVersion + ' not found');
        }

        String prefix = (String.isNotBlank(flows.get(0).NamespacePrefix)) ? flows.get(0).NamespacePrefix + '__' : '';
        String flowFullApiName = prefix + flows.get(0).ApiName + '-' + flowVersions.get(0).VersionNumber;
        String flowArea = (String)dataMap.get('flowArea');
        String flowType = (String)dataMap.get('flowType');
        Boolean newFlowVersion = (Boolean)dataMap.get('newFlowVersion');

        FlowLogService service = new FlowLogService();
        Map<String, Object> params = new Map<String, Object>{
            'operation' => 'ADD_LOGGING',
            'flowApiName' => flowFullApiName,
            'functionalArea' => flowArea,
            'flowType' => flowType,
            'versionInfo' => (newFlowVersion ? 'NEW_VERSION' : 'CURRENT_VERSION')
        };
        Map<String, Object> result = service.invoke(params);
        Boolean success = (Boolean)result.get('success');
        if(!success) {
            String message = (String)result.get('message');
            throw new AdminServiceException(message);
        }
        
        Integer newCreatedVersion = Integer.valueOf(result.get('newVersionNumber'));
        flowVersions = getFlowVersionByDefenitionIdAndVersion(flows.get(0).DurableId, newCreatedVersion);        

        String url = '{0}/builder_platform_interaction/flowBuilder.app?isFromAloha=true&flowDefId={1}&flowId={2}';
        url = String.format(url, new List<String>{
            System.Url.getOrgDomainUrl().toExternalForm(),
            flows.get(0).DurableId.left(15),
            flowVersions.get(0).DurableId
        });
        
        Map<String, Object> response = new Map<String, Object>{
            'success' => success,
            'message' => (String)result.get('message'),
            'url' => url
        };
        return response;
    }

    public static List<FlowWrapper> getFlowWithVersions() {
        List<FlowWrapper> flowWrappers = new List<FlowWrapper>();
        List<FlowDefinitionView> flows = [
            SELECT Id, ApiName, Label, VersionNumber, InstalledPackageName, ActiveVersionId, NamespacePrefix, DurableId
            FROM FlowDefinitionView 
            WHERE IsTemplate = false AND ManageableState = 'unmanaged' AND TriggerType != 'RecordBeforeSave' 
            ORDER BY Label ASC
            LIMIT 1000
        ];

        Set<String> durableIds = new Set<String>();
        for(FlowDefinitionView flow : flows) {
            if(String.isNotBlank(flow?.DurableId) && flow?.DurableId?.startsWith('300')) {
               durableIds.add(flow?.DurableId);
            }
        }

        Map<String, List<FlowVersionView>> flowVersionsMap = new Map<String, List<FlowVersionView>>();
        List<FlowVersionView> flowVersions = [
            SELECT Id, VersionNumber, Status, FlowDefinitionViewId
            FROM FlowVersionView
            WHERE FlowDefinitionViewId IN :durableIds
            ORDER BY VersionNumber DESC
        ];

        for(FlowVersionView flowVersion : flowVersions) {
            if(!flowVersionsMap.containsKey(flowVersion?.FlowDefinitionViewId)) {
                flowVersionsMap.put(flowVersion?.FlowDefinitionViewId, new List<FlowVersionView>());
            }
            flowVersionsMap.get(flowVersion?.FlowDefinitionViewId).add(flowVersion);
        }

        for (FlowDefinitionView flow : flows) {
            FlowWrapper flowWrapper = new FlowWrapper(flow);
            if(flowVersionsMap.containsKey(flow?.DurableId)) {
                for (FlowVersionView flowVersion : flowVersionsMap.get(flow?.DurableId)) {
                    flowWrapper.addVersion(flowVersion);
                }
            }
            if(!flowWrapper?.versions?.isEmpty()) {
                flowWrappers.add(flowWrapper);
            }
        }
        return flowWrappers;
    }

    public static PharosRunningUserWrapper getPharosRunningUserWrapper() {
        return new PharosRunningUserWrapper();
    }

    public static Boolean resetScheduleJobs() {
        Boolean result = false;
        for (CronTrigger currentCronTrigger : getCronTriggers()) {
            try {
                System.abortJob(currentCronTrigger.Id);
            } catch (StringException e) {}
        }

        LogServiceScheduler.runLogServiceSchedulerModes();

        result = true;

        return result;
    }

    public static Boolean resetEmailAddressContextUser() {
        Boolean result = false;

        List<EmailServicesAddress> addresses = emailServicesSelector.getPackageAllAddresses();
        if (addresses.isEmpty()) {
            return true;
        }

        Map<String, ApexEmailNotification> apexEmailNotificationByEmail = getApexEmailNotificationByEmailMap();

        List<EmailServicesAddress> addressesToDelete = new List<EmailServicesAddress>();
        EmailServicesAddress addressToUpdate;

        for (EmailServicesAddress currentEmailServicesAddress : addresses) {
            Boolean isEmailNotificationEqualsEmailFromEmailServiceAddress =
                !apexEmailNotificationByEmail.isEmpty()
                && apexEmailNotificationByEmail.containsKey(EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(currentEmailServicesAddress));

            if (isEmailNotificationEqualsEmailFromEmailServiceAddress) {
                if (isEmailServicesAddressResetNeeded(currentEmailServicesAddress)) {
                    addressToUpdate = currentEmailServicesAddress;
                }
            } else {
                addressesToDelete.add(currentEmailServicesAddress);
            }
        }
        
        EmailServicesService.emailServicesAddressService.deleteEmailServicesAddresses(addressesToDelete);

        if (addressToUpdate != null) {
            EmailServicesService.emailServicesAddressService.updateEmailServicesAddress(addressToUpdate);
        }

        result = true;

        return result;
    }

    private static Boolean isEmailServicesAddressResetNeeded(EmailServicesAddress emailServicesAddress) {
        return emailServicesAddress.isActive
            && (
                !emailServicesAddress.RunAsUserId.equals(UserInfo.getUserId())
                || !emailServicesAddress.DeveloperName.equals(ConfigUtil.EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME)
            );
    }

    public class PharosRunningUserWrapper {
        public User currentUser;
        public List<PharosRunningUserScheduleInfoWrapper> scheduleInfoWrappers;
        public List<PharosRunningUserEmailServiceInfoWrapper> emailServiceInfoWrappers;

        public PharosRunningUserWrapper() {
            this.currentUser = getUserInfo();
            this.scheduleInfoWrappers = this.getPharosRunningUserScheduleInfoWrappers();
            this.emailServiceInfoWrappers = this.getPharosRunningUserEmailServiceInfoWrappers();
        }

        private List<PharosRunningUserScheduleInfoWrapper> getPharosRunningUserScheduleInfoWrappers() {
            List<PharosRunningUserScheduleInfoWrapper> pharosRunningUserScheduleInfoWrapper =
                new List<PharosRunningUserScheduleInfoWrapper>();

            for (CronTrigger currentCronTrigger : getCronTriggers()) {
                pharosRunningUserScheduleInfoWrapper.add(new PharosRunningUserScheduleInfoWrapper(currentCronTrigger));
            }

            return pharosRunningUserScheduleInfoWrapper;
        }

        private List<PharosRunningUserEmailServiceInfoWrapper> getPharosRunningUserEmailServiceInfoWrappers() {
            List<PharosRunningUserEmailServiceInfoWrapper> emailServiceInfoWrappers =
                new List<PharosRunningUserEmailServiceInfoWrapper>();

            Map<String, ApexEmailNotification> apexEmailNotificationByEmail = getApexEmailNotificationByEmailMap();
            List<EmailServicesAddress> addresses = emailServicesSelector.getPackageAllActiveAddresses();
            Map<Id, User> userNameByUserIdMap = new Map<Id, User>(getUsersByUserIds(getEmailServicesAddressRunAsUserIds(addresses)));
            for (EmailServicesAddress currentEmailServicesAddress : addresses) {
                if (!apexEmailNotificationByEmail.isEmpty() && apexEmailNotificationByEmail.containsKey(EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(currentEmailServicesAddress))) {
                    emailServiceInfoWrappers.add(new PharosRunningUserEmailServiceInfoWrapper(
                        currentEmailServicesAddress,
                        userNameByUserIdMap.get(currentEmailServicesAddress.RunAsUserId)
                    ));
                }
            }

            return emailServiceInfoWrappers;
        }

        private Set<Id> getEmailServicesAddressRunAsUserIds(List<EmailServicesAddress> addresses) {
            Set<Id> userIds = new Set<Id>();
            for (EmailServicesAddress currentEmailServicesAddress : addresses) {
                userIds.add(currentEmailServicesAddress.RunAsUserId);
            }

            return userIds;
        }
    }

    public class PharosRunningUserScheduleInfoWrapper {
        public Id jobId;
        public String jobName;
        public String submittedBy;
        public Datetime submittedDate;
        public Datetime nextSchduledRunDate;

        public PharosRunningUserScheduleInfoWrapper(CronTrigger cronTrigger) {
            this.jobId = cronTrigger.Id;
            this.jobName = cronTrigger.CronJobDetail.Name;
            this.submittedBy = cronTrigger.LastModifiedBy.Name; // last modified or owner? when owner we need additional logic to take users by owner Id.
            this.submittedDate = cronTrigger.StartTime;
            this.nextSchduledRunDate = cronTrigger.NextFireTime;
        }
    }

    public class PharosRunningUserEmailServiceInfoWrapper {
        public String emailServiceName;
        public String contextUser;
        public String emailAddress;

        public PharosRunningUserEmailServiceInfoWrapper(EmailServicesAddress emailServicesAddress, User user) {
            this.emailServiceName = emailServicesAddress.DeveloperName;
            this.contextUser = user.Name;
            this.emailAddress = EmailServicesService.emailServicesAddressService.getEmailFromEmailServiceAddress(emailServicesAddress);
        }
    }

    private static List<CronTrigger> getCronTriggers() {
        return [
            SELECT Id, CronJobDetail.Name, NextFireTime, StartTime, OwnerId, LastModifiedBy.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name IN :Constants.JOBS.PHAROS_LOG_SERVICE_SCHEDULER_MODE_JOB_NAMES
            ORDER BY CronJobDetail.Name ASC
        ];
    }

    private static List<User> getUsersByUserIds(Set<Id> userIds) {
        return [SELECT Name FROM User WHERE Id IN :userIds];
    }

    private static Map<String, ApexEmailNotification> getApexEmailNotificationByEmailMap() {
        Map<String, ApexEmailNotification> apexEmailNotificationByEmail = new Map<String, ApexEmailNotification>();
        for (ApexEmailNotification currentApexEmailNotification : emailServicesSelector.getApexEmailNotificationsWithNotBlankEmail()) {
            apexEmailNotificationByEmail.put(currentApexEmailNotification.Email, currentApexEmailNotification);
        }
        return apexEmailNotificationByEmail;
    }

    public class MetadataChatSettings {
        public Boolean openAiConfigured;
        public Boolean gitConfigured;
        public Boolean changeTrackingConfigured;
        public Boolean codebaseIndexed;
        public Boolean logsIndexed;
        public Boolean indexingInProgress;
        public Boolean trustedSiteReady;

        public MetadataChatSettings(Boolean openAiConfigured, Boolean gitConfigured, Boolean changeTrackingConfigured, Boolean codebaseIndexed, Boolean logsIndexed, Boolean indexingInProgress, Boolean trustedSiteReady) {
            this.openAiConfigured = openAiConfigured;
            this.gitConfigured = gitConfigured;
            this.changeTrackingConfigured = changeTrackingConfigured;
            this.codebaseIndexed = codebaseIndexed;
            this.logsIndexed = logsIndexed;
            this.indexingInProgress = indexingInProgress;
            this.trustedSiteReady = trustedSiteReady;
        }

        public MetadataChatSettings(Boolean trustedSiteReady) {
            this.trustedSiteReady = trustedSiteReady;
        }
    }

    public static MetadataChatSettings getMetadataChatSettings() {
        Map<String, MetadataServiceUtil.CspTrustedSiteWrapper> trustedSites = MetadataServiceUtil.getCspTrustedSitesMap();
        Boolean trustedSiteReady = trustedSites.containsKey(PharosChatController.CHAT_WEBSOCKET_URL);
        
        String orgId = UserInfo.getOrganizationId();
        String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
        Boolean openAiConfigured = ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c && String.isNotBlank(openAiKey) && OpenAI.validateToken(openAiKey);
        Boolean gitConfigured = GitHubUtils.validateGitHubConnection().gitValid;
        Boolean changeTrackingConfigured = ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c;
        
        upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.AI_NAME, Constants.REMOTE_SITE_SETTINGS.AI_URL, Constants.REMOTE_SITE_SETTINGS.AI_DESCRIPTION);
        PharosChatController.NamespaceStatusResponse namespaceStatus = PharosChatController.getNamespaceStatus(orgId);
        Boolean codebaseIndexed = namespaceStatus?.empty != null && !namespaceStatus?.empty;
        Boolean logsIndexed = namespaceStatus?.logsEmpty != null && !namespaceStatus?.logsEmpty;
        Boolean indexingInProgress = namespaceStatus?.indexingInProgress != null && namespaceStatus?.indexingInProgress;
        
        // Check for running or recently completed batch jobs
        if (!indexingInProgress) {
            List<String> batchClassesToCheck = new List<String>();
            if (!codebaseIndexed) {
                batchClassesToCheck.add('GitHubCommitBatch');
            }
            if (!logsIndexed) {
                batchClassesToCheck.add('AIChatIndexBatch');
            }
            
            if (!batchClassesToCheck.isEmpty()) {
                DateTime recencyThreshold = DateTime.now().addMinutes(-1);
                List<AsyncApexJob> recentJobs = [
                    SELECT ApexClass.Name, Status, CompletedDate
                    FROM AsyncApexJob 
                    WHERE ApexClass.Name IN :batchClassesToCheck 
                    AND (Status IN (:Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PREPARING, :Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PROCESSING) 
                         OR (Status = :Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_COMPLETED AND CompletedDate >= :recencyThreshold))
                ];
                
                if (recentJobs?.isEmpty() == false) {
                    indexingInProgress = true;
                }
            }
        }
        
        return new MetadataChatSettings(openAiConfigured, gitConfigured, changeTrackingConfigured, codebaseIndexed, logsIndexed, indexingInProgress, trustedSiteReady);
    }

    public static MetadataChatSettings setupMetadataChatTrustedSite() {
        MetadataServiceUtil.upsertCspTrustedSite('Pharos_Chat_Websocket', PharosChatController.CHAT_WEBSOCKET_URL, 'Pharos chat websocket connection');
        return new MetadataChatSettings(true);
    }

    public static MetadataChatSettings setupMetadataChatIndex() {
        MetadataChatSettings settings = getMetadataChatSettings();
        if (settings.indexingInProgress) return settings;
        if (!settings.codebaseIndexed) {
            Map<String, Boolean> result = pushGitChanges();
            if (result.get('changesPushed') || result.get('jobAlreadyRunning')) {
                settings.indexingInProgress = true;
            }
        }
        if (!settings.logsIndexed) {
            AIChatIndexBatch.getInstance().startBatch();
            settings.indexingInProgress = true;
        }
        return settings;
    }
}