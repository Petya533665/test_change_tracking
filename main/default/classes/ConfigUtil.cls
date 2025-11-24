public with sharing class ConfigUtil {

    public static final String PHAROS_APP_SETTINGS_NAME = 'Pharos';

    public static Logger_Settings__c SETTINGS = Logger_Settings__c.getOrgDefaults();

    public static Map<String, Schema.SObjectType> MAP_GD {
        get {
            if (MAP_GD == null) {
                MAP_GD = Schema.getGlobalDescribe();
            }
            return MAP_GD;
        }
        private set;
    }

    @TestVisible
    public static Map<String, Schema.DescribeFieldResult> MAP_LOG_FIELDS {
        get {
            if(MAP_LOG_FIELDS == null) {
                MAP_LOG_FIELDS = new Map<String, Schema.DescribeFieldResult>();

                Map<String, Schema.SObjectField> sObjectFieldMap = Schema.SObjectType.Log__c.fields.getMap();
                for(String fieldName : sObjectFieldMap.keySet()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldMap.get(fieldName).getDescribe();
                    MAP_LOG_FIELDS.put(fieldName, sObjectFieldDescribe);
                }

            }
            return MAP_LOG_FIELDS;
        }
        private set;
    }

    @TestVisible
    public static Map<String, Schema.DescribeFieldResult> MAP_ISSUE_FIELDS {
        get {
            if(MAP_ISSUE_FIELDS == null) {
                MAP_ISSUE_FIELDS = new Map<String, Schema.DescribeFieldResult>();

                Map<String, Schema.SObjectField> sObjectFieldMap = Schema.SObjectType.Issue__c.fields.getMap();
                for(String fieldName : sObjectFieldMap.keySet()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldMap.get(fieldName).getDescribe();
                    MAP_ISSUE_FIELDS.put(fieldName, sObjectFieldDescribe);
                }

            }
            return MAP_ISSUE_FIELDS;
        }
        private set;
    }

    @TestVisible
    public static Map<String, Schema.DescribeFieldResult> MAP_TRACE_RESULT_FIELDS {
        get {
            if(MAP_TRACE_RESULT_FIELDS == null) {
                MAP_TRACE_RESULT_FIELDS = new Map<String, Schema.DescribeFieldResult>();

                Map<String, Schema.SObjectField> sObjectFieldMap = Schema.SObjectType.Trace_Result__c.fields.getMap();
                for(String fieldName : sObjectFieldMap.keySet()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldMap.get(fieldName).getDescribe();
                    MAP_TRACE_RESULT_FIELDS.put(fieldName, sObjectFieldDescribe);
                }

            }
            return MAP_TRACE_RESULT_FIELDS;
        }
        private set;
    }

    public static String nameSpacePrefix {
        get {
            if(nameSpacePrefix == null) {
              nameSpacePrefix = getNameSpacePrefix();
            }
            return nameSpacePrefix;
        }
        private set;
    }

    public static String URL_VF_CALLBACK_PAGE_SETTINGS {
        get {
            if(URL_VF_CALLBACK_PAGE_SETTINGS == null) {
                URL_VF_CALLBACK_PAGE_SETTINGS = System.URL.getOrgDomainUrl().toExternalForm() + '/apex/' + ConfigUtil.getNameSpacePrefix() + 'Settings';
            }
            return URL_VF_CALLBACK_PAGE_SETTINGS;
        }
        private set;
    }

    public static Boolean currentOrgIsSandbox {
        get {
            if(currentOrgIsSandbox == null) {
              currentOrgIsSandbox = currentOrgIsSandbox();
            }
            return currentOrgIsSandbox;
        }
        private set;
    }

    public static String currentOrgNameSpacePrefix {
        get {
            if(currentOrgNameSpacePrefix == null) {
                currentOrgNameSpacePrefix = [SELECT NamespacePrefix FROM Organization LIMIT 1].NamespacePrefix;
                currentOrgNameSpacePrefix = (currentOrgNameSpacePrefix == null) ? '' : currentOrgNameSpacePrefix;
            }
            return currentOrgNameSpacePrefix;
        }
        private set;
    }

    public static String prefixCurrentOrgNamespace(String postfix) {
        String fullApiName = (String.isNotBlank(ConfigUtil.currentOrgNameSpacePrefix))
            ? (ConfigUtil.currentOrgNameSpacePrefix + '__' + postfix)
            : postfix;
        return fullApiName;
    }

    public static String getNameSpacePrefix() {
        Schema.DescribeSObjectResult dsr = Log__c.sObjectType.getDescribe();
        String namespacePrefix = dsr.getName().remove(dsr.getLocalName());
        return namespacePrefix;
    }

    public static String getNameSpace() {
        return getNameSpacePrefix().replace('__', '');
    }

    public static Boolean currentOrgIsSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static final String NS = getNameSpacePrefix().replace('__', '');
    public static final String NS_CLASS = NS + '.';

    //From Logger

    public static final String JIRA_CLOUD_API_PREFIX = 'https://api.atlassian.com/ex/jira/';
    public static final String JIRA_CLOUD_API_RESOURCES_ENDPOINT = 'https://api.atlassian.com/oauth/token/accessible-resources';

    // From JiraService
    public static final String JIRA_TASK_URL = ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c + '/browse/';
    public static final String EXISTING_TICKET_LINKED_STATUS = 'Existing Ticket Linked';
    public static final String NEW_TICKET_CREATED_STATUS = 'New Ticket Created';
    public static final String TICKET_CREATE_ERROR_STATUS = 'Error';

    // From AdminService
    public static final String SOAP_ENDPOINT_PREFIX = '/services/Soap/m/';
    public static final String REST_API_ITEMS_KEY_NEXT_RECORDS_URL = 'nextRecordsUrl';
    public static final String TOOLING_ITEMS_KEY_RECORDS = 'records';
    public static final String TOOLING_ITEMS_KEY_SOBJECTS = 'sobjects';
    public static final String API_VERSION = 'v56.0';
    public static final String REMOTE_TOOLING_API_ENDPOINT = '/services/data/'+API_VERSION+'/tooling';
    public static final String TOOLING_API_ENDPOINT = Constants.GLOBAL_VARIABLE.BASE_URL + '/services/data/'+API_VERSION+'/tooling';
    public static final String ORG_LIMITS_API_ENDPOINT = '/services/data/'+API_VERSION+'/limits';
    public static final String QUERY_REST_API_PATH = '/services/data/'+API_VERSION+'/query?q=';
    public static String getQueryRestApiPath(String version){
        return '/services/data/'+version+'/query?q=';
    }
    public static final String QUERY_ALL_REST_API_PATH = '/services/data/'+API_VERSION+'/queryAll?q=';
    public static final String DESCRIBE_SOBJECT_PATH = '/services/data/'+API_VERSION+'/sobjects/';
    public static final String REMOTE_TOOLING_ENDPOINT = '/services/data/'+API_VERSION+'/tooling';
    public static final String REMOTE_TOOLING_QUERY_ENDPOINT = REMOTE_TOOLING_API_ENDPOINT + '/query?q=';
    public static final String TOOLING_QUERY_ENDPOINT = TOOLING_API_ENDPOINT + '/query?q=';
    public static final String TOOLING_QUERY_API_ENDPOINT = '/services/data/'+API_VERSION+'/tooling/query?q=';
    public static final String TOOLING_QUERY_GET_DEBUG_LEVELS = 'SELECT+Id,+DeveloperName,+MasterLabel,+Language,+ApexCode,+ApexProfiling,+Callout,+Database,+System,+Validation,+Visualforce,+Workflow+FROM+DebugLevel';
    public static final String TOOLING_QUERY_GET_DEBUG_TRACE_FLAGS = 'SELECT+Id,+StartDate,+CreatedDate,+CreatedById,+ExpirationDate,+LogType,+TracedEntityId,+ApexCode,+ApexProfiling,+Callout,+Database,+System,+Validation,+Visualforce,+Workflow,+DebugLevelId+FROM+TraceFlag';
    public static final String REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL = REMOTE_TOOLING_API_ENDPOINT + '/sobjects/DebugLevel';
    public static final String REMOTE_TOOLING_API_UPDATE_TRACE_FLAG = REMOTE_TOOLING_API_ENDPOINT + '/sobjects/TraceFlag';
    public static final String REMOTE_REST_COMPOSITE_API_DELETE_RECORDS = '/services/data/'+API_VERSION+'/composite/sobjects?ids=';

    public static final String TOOLING_API_UPDATE_DEBUG_LOG_LEVEL = TOOLING_API_ENDPOINT + '/sobjects/DebugLevel';
    public static final String TOOLING_API_UPDATE_TRACE_FLAG = TOOLING_API_ENDPOINT + '/sobjects/TraceFlag';
    public static final String REST_COMPOSITE_API_DELETE_RECORDS = Constants.GLOBAL_VARIABLE.BASE_URL + '/services/data/'+API_VERSION+'/composite/sobjects?ids=';
    public static final String TOOLING_QUERY_GET_EMAIL_APEX_EMAIL_NOTIFICATION = 'SELECT+Id,+Email+FROM+ApexEmailNotification+WHERE+UserId=null';
    public static final String TOOLING_API_CREATE_APEX_EMAIL_NOTIFICATION = TOOLING_API_ENDPOINT + '/sobjects/ApexEmailNotification';
    public static final String TOOLING_API_UPDATE_APEX_EMAIL_NOTIFICATION = TOOLING_API_CREATE_APEX_EMAIL_NOTIFICATION + '/';
    public static final String TOOLING_API_UPDATE_PLATFORM_EVENT_SUBSCRIBER_CONFIG = '/services/data/'+API_VERSION+'/tooling/sobjects/PlatformEventSubscriberConfig';
    public static final String TOOLING_API_GET_FLOW = '/services/data/'+API_VERSION+'/tooling/sobjects/Flow/';
    public static final String OVERRIDE_HTTP_METHOD_PATCH = '?_HttpMethod=PATCH';
    public static final String EMAIL_SERVICES_FUNCTION_ENDPOINT = Constants.GLOBAL_VARIABLE.BASE_URL + '/services/data/'+API_VERSION+'/sobjects/EmailServicesFunction';
    public static final String EMAIL_SERVICES_ADDRESS_ENDPOINT = Constants.GLOBAL_VARIABLE.BASE_URL + '/services/data/'+API_VERSION+'/sobjects/EmailServicesAddress';
    public static final String EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME = 'ErrorEmailHandlerAddress';
    public static final String APEXUTILSOURCE_NOT_FOUND_MESSAGE = 'Static Resource with name ApexUtilSource not found';
    public static final String APEXUTILTESTSOURCE_NOT_FOUND_MESSAGE = 'Static Resource with name ApexUtilTestSource not found';

    public static final String EMAIL_SERVICE_HANDLER_NAME = 'ErrorEmailHandler';

    

    public static final Map<String, String> SF_REST_API_HEADERS {
        get {
            if (SF_REST_API_HEADERS == null) {
                SF_REST_API_HEADERS = HttpUtils.getHeadersAuthorization('Bearer ' + ConnectedOrgService.getSelfConnectedOrgAccessToken());
                SF_REST_API_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
            }
            return SF_REST_API_HEADERS;
        }
        set;
    }

    // From PagerDutyService
    public static Map<String, String> PAGER_DUTY_HEADERS {
        get {
            if(PAGER_DUTY_HEADERS == null) {
                PAGER_DUTY_HEADERS = HttpUtils.getHeadersAuthorizationAcceptPagerDutyJson('Token token=' + ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c);
                PAGER_DUTY_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
                PAGER_DUTY_HEADERS.putAll(HttpUtils.getHeadersFrom(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_User_Email__c));
            }
            return PAGER_DUTY_HEADERS;
        }
        set;
    }

    public static Map<String, String> PAGER_DUTY_EVENTS_HEADERS {
        get {
            if(PAGER_DUTY_EVENTS_HEADERS == null) {
                PAGER_DUTY_EVENTS_HEADERS = HttpUtils.getHeadersAuthorization('Token token=' + ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c);
                PAGER_DUTY_EVENTS_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
            }
            return PAGER_DUTY_EVENTS_HEADERS;
        }
        set;
    }

    public static final List<String> EVENT_SEVERITY = new List<String> {
        'critical',
        'error',
        'warning',
        'info'
    };

    public static final String PAGER_DUTY_INCIDENT_ENDPOINT = 'https://api.pagerduty.com/incidents';
    public static final String PAGER_DUTY_SERVICES_ENDPOINT = 'https://api.pagerduty.com/services';
    public static final String PAGER_DUTY_EVENTS_ENDPOINT = 'https://events.pagerduty.com/v2/enqueue';

    // From SlackService
    public static String SLACK_DEFAULT_MESSAGE_TEMPLATE = 'New Log: {!pharos__Log__c.Name}\n{!pharos__Log__c.Link}';
    public static Map<String, String> SLACK_API_HEADERS  {
        get {
            if(SLACK_API_HEADERS == null) {
                SLACK_API_HEADERS = HttpUtils.getHeadersAuthorization('Bearer ' + ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c);
                SLACK_API_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
            }
            return SLACK_API_HEADERS;
        }
        set;
    }
    public static Map<String, String> SLACK_API_CONVERSATION_LIST_HEADERS {
        get {
            if(SLACK_API_CONVERSATION_LIST_HEADERS == null) {
                SLACK_API_CONVERSATION_LIST_HEADERS = HttpUtils.getHeadersAuthorization('Bearer ' + ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c);
                SLACK_API_CONVERSATION_LIST_HEADERS.putAll(HttpUtils.getHeadersContentTypeFormUrlencoded());
            }
            return SLACK_API_CONVERSATION_LIST_HEADERS;
        }
        set;
    }

    public static final String SLACK_AUTHORIZE_URL = 'https://slack.com/oauth/authorize';
    public static final String SLACK_AUTHORIZE_URL_V2 = 'https://slack.com/oauth/v2/authorize';
    public static final String SLACK_POST_MESSAGE_ENDPOINT = 'https://slack.com/api/chat.postMessage';
    public static final String SLACK_CONVERSATION_INFO_ENDPOINT = 'https://slack.com/api/conversations.info';
    public static final String SLACK_CONVERSATION_LIST_ENDPOINT = 'https://slack.com/api/conversations.list?exclude_archived=true&types=public_channel,private_channel&limit=1000';
    public static final String SLACK_USER_LIST_ENDPOINT = 'https://slack.com/api/users.list?limit=1000';
    public static final String SLACK_GET_UPLOAD_URL_EXTERNAL_ENDPOINT = 'https://slack.com/api/files.getUploadURLExternal';
    public static final String SLACK_FILES_COMPLETE_UPLOAD_EXTERNAL_ENDPOINT = 'https://slack.com/api/files.completeUploadExternal';



    // From SplunkService
    public static final String SPLUNK_TOKEN_ENDPOINT = ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c + '/services/auth/login?output_mode=json';
    public static final Map<String, String> SPLUNK_API_TOKEN_HEADERS = HttpUtils.getHeadersContentTypeFormUrlencoded();
    public static final String SPLUNK_MESSAGES_ENDPOINT = ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c + '/services/messages?output_mode=json';
    public static Map<String, String> SPLUNK_API_HEADERS {
        get {
            if(SPLUNK_API_HEADERS == null) {
                SPLUNK_API_HEADERS = HttpUtils.getHeadersAuthorization('Splunk ' + ConfigUtil.SPLUNK_SETTINGS.Splunk_Token__c);
                SPLUNK_API_HEADERS.putAll(SPLUNK_API_TOKEN_HEADERS);
            }
            return SPLUNK_API_HEADERS;
        }
        set;
    }

    public static final String SPLUNK_COLLECTOR_ENDPOINT = ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c + ':8088/services/collector?output_mode=json';
    public static final Map<String, String> SPLUNK_COLLECTOR_HEADERS {
        get {
            if(SPLUNK_COLLECTOR_HEADERS == null) {
                SPLUNK_COLLECTOR_HEADERS = HttpUtils.getHeadersAuthorization('Splunk ' + ConfigUtil.SPLUNK_SETTINGS.Splunk_Event_Collector_Token__c);
                SPLUNK_COLLECTOR_HEADERS.putAll(HttpUtils.getHeadersContentTypeFormUrlencoded());
            }
            return SPLUNK_COLLECTOR_HEADERS;
        }
        set;
    }

    //From OpenAI
    public static final String OPEN_AI_COMPLETIONS_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.OPEN_AI_URL + '/v1/chat/completions';
    public static final String OPEN_AI_USAGE_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.OPEN_AI_URL + '/v1/usage';
    public static final Map<String, String> OPEN_AI_HEADERS {
        get {
            if(OPEN_AI_HEADERS == null) {
                OPEN_AI_HEADERS = HttpUtils.getHeadersAuthorization('Bearer ' + OPEN_AI_SETTINGS.Token__c);
                OPEN_AI_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
            }
            return OPEN_AI_HEADERS;
        }
        set;
    }

    // From StackTraceParser
    public static String STACKTRACE_BAD_SETTINGS_MESSAGE = 'Connection settings not found. Please setup Logger App.';
    public static String STACKTRACE_BASE_URL {
        get {
            if (String.isBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Instance_Url__c)) {
                throw new StacktraceParser.StackTraceParserException(STACKTRACE_BAD_SETTINGS_MESSAGE);
            }
            return ConfigUtil.CONNECTED_ORGS_SETTINGS.Instance_Url__c + '/services/data/'+API_VERSION+'/tooling';
        }
        set;
    }

    public static String generateUUID4() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    // from ConnectedOrgService
    // move to service or constant class?
    public static String INVALID_OAUTH_STATE_MESSAGE = 'Invalid OAuth State ';
    public static String CONNECTED_ORG_NOT_FOUND_MESSAGE = 'Connected Org not found ';
    public static String CONNECTED_ORG_NOT_SETTED = 'Environment information is not available. Org Id {0} not found. Please set up a connection to this org under Connected Orgs in Pharos Admin.';
    public static String getConnectedOrgNotSetError(String connectedOrgId) {
        return String.format(CONNECTED_ORG_NOT_SETTED, new List<String>{connectedOrgId});
    }
    public static String SF_OAUTH_TOKEN_ENDPOINT = '/services/oauth2/token';
    public static Map<String, String> OAUTH_HEADERS_MAP {
        get {
            if(OAUTH_HEADERS_MAP == null) {
                OAUTH_HEADERS_MAP = HttpUtils.getHeadersContentTypeFormUrlencoded();
                OAUTH_HEADERS_MAP.putAll(HttpUtils.getHeadersAcceptJson());
            }
            return OAUTH_HEADERS_MAP;
        }
        private set;
    }

    public static Map<String, String> getSFRestAPIHeaders(String accessToken) {
        Map<String, String> headers = HttpUtils.getHeadersAuthorization('Bearer ' + accessToken);
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());
        return headers;
    }

    // from PassthroughtModeService and DataDirectionService
    public static String CONNECTED_ORG_NOT_FOUND_PASSTHROUGHMODE = 'Connected Org not found (PassthroughMode)';
    public static String PARAMS_TYPE = 'type';
    public static String TYPE_PASSTHROUGH_MODE = 'passthroughMode';
    public static String TYPE_BROADCAST = 'broadcast';
    public static String ORIGINATED_FROM_BROADCAST = 'Broadcast';
    public static String ORIGINATED_FROM_PASSTHROUGH = 'Passthrough';
    public static String PHAROS_REST_SERVICE_ENDPOINT = '/services/apexrest/' + ConfigUtil.NS + '/logs';

    // Configs

    public class SplunkFieldsConfig {
        public List<String> splunk_fields;
        public SplunkFieldsConfig(){}
    }

    public class JiraFieldsMappingsConfig {
        public List<JiraFieldsMapping> jira_fields_mapping;
        public JiraFieldsMappingsConfig(){}
    }

    public class JiraFieldsMapping {
        public String logField;
        public String jiraField;
        public String issueTypeId;
        public String sobjectType;
        public String projectId;
    }

    public static JiraFieldsMappingsConfig JIRA_FIELDS_MAPPINGS {
        get {
            if (JIRA_FIELDS_MAPPINGS == null) {
                initJiraFieldsMappings();
            }
            return JIRA_FIELDS_MAPPINGS;
        }
        private set;
    }

    public static SplunkFieldsConfig SPLUNK_FIELDS {
        get {
            if (SPLUNK_FIELDS == null) {
                initSplunkFields();
            }
            return SPLUNK_FIELDS;
        }
        private set;
    }

    public static Jira_Settings__c JIRA_SETTINGS {
        get {
            if (JIRA_SETTINGS == null) {
                initJiraSettings();
            }
            return JIRA_SETTINGS;
        }
        set;
    }

    public static Slack_Settings__c SLACK_SETTINGS {
        get {
            if (SLACK_SETTINGS == null) {
                initSlackSettings();
            }
            return SLACK_SETTINGS;
        }
        private set;
    }

    public static Graph_API_Settings__c GRAPH_API_SETTINGS {
        get {
            if (GRAPH_API_SETTINGS == null) {
                initGraphAPISettings();
            }
            return GRAPH_API_SETTINGS;
        }
        private set;
    }

    public static Debug_Log_Service_Flag__c DEBUG_LOG_SERVICE_SETTINGS {
        get {
            if (DEBUG_LOG_SERVICE_SETTINGS == null) {
                initDebugLogServiceSettings();
            }
            return DEBUG_LOG_SERVICE_SETTINGS;
        }
        private set;
    }

    public static Azure_Dev_Ops_API_Settings__c AZURE_DEV_OPS_API_SETTINGS {
        get {
            if (AZURE_DEV_OPS_API_SETTINGS == null) {
                initAzureDevOpsAPISettings();
            }
            return AZURE_DEV_OPS_API_SETTINGS;
        }
        set;
    }

    public static Pager_Duty_Settings__c PAGER_DUTY_SETTINGS {
        get {
            if (PAGER_DUTY_SETTINGS == null) {
                initPagerDutySettings();
            }
            return PAGER_DUTY_SETTINGS;
        }
        private set;
    }

    public static Connected_Orgs_Settings__c CONNECTED_ORGS_SETTINGS {
        get {
            if (CONNECTED_ORGS_SETTINGS == null) {
                initConnectedOrgsSettings();
            }
            return CONNECTED_ORGS_SETTINGS;
        }
        private set;
    }

    public static Splunk_Settings__c SPLUNK_SETTINGS {
        get {
            if (SPLUNK_SETTINGS == null) {
                initSplunkSettings();
            }
            return SPLUNK_SETTINGS;
        }
        private set;
    }

    public static Git_API_Settings__c GIT_API_SETTINGS {
        get {
            if (GIT_API_SETTINGS == null) {
                initGitAPISettings();
            }
            return GIT_API_SETTINGS;
        }
        private set;
    }

    public static Change_Tracking__c CHANGE_TRACKING_SETTINGS {
        get {
            if (CHANGE_TRACKING_SETTINGS == null) {
                initChangeTrackingSettings();
            }
            return CHANGE_TRACKING_SETTINGS;
        }
        private set;
    }

    public static void initChangeTrackingSettings() {
        CHANGE_TRACKING_SETTINGS = Change_Tracking__c.getOrgDefaults();
    }

    public static void initGitAPISettings() {
        GIT_API_SETTINGS = Git_API_Settings__c.getOrgDefaults();
    }

    public static Pharos_Settings__c PHAROS_SETTINGS {
        get {
            if (PHAROS_SETTINGS == null) {
                initPharosSettings();
            }
            return PHAROS_SETTINGS;
        }
        private set;
    }

    public static void initPharosSettings() {
        PHAROS_SETTINGS = Pharos_Settings__c.getOrgDefaults();
    }

    @TestVisible
    public static Event_Monitoring__c EVENT_MONITORING_SETTINGS {
        get {
            if (EVENT_MONITORING_SETTINGS == null) {
                initEventMonitoringSettings();
            }
            return EVENT_MONITORING_SETTINGS;
        }
        private set;
    }

    public static void initEventMonitoringSettings() {
        EVENT_MONITORING_SETTINGS = Event_Monitoring__c.getOrgDefaults();
    }

    public static OpenAI_Settings__c OPEN_AI_SETTINGS {
        get {
            if (OPEN_AI_SETTINGS == null) {
                initOpenAISettings();
            }
            return OPEN_AI_SETTINGS;
        }
        private set;
    }

    public static void initOpenAISettings() {
        OPEN_AI_SETTINGS = OpenAI_Settings__c.getOrgDefaults();
    }

    public static void initSplunkSettings() {
        SPLUNK_SETTINGS = Splunk_Settings__c.getOrgDefaults();
    }

    public static void initJiraSettings() {
        JIRA_SETTINGS = JIRA_Settings__c.getOrgDefaults();
    }

    public static void initConnectedOrgsSettings() {
        CONNECTED_ORGS_SETTINGS = Connected_Orgs_Settings__c.getOrgDefaults();
    }

    public static void initPagerDutySettings() {
        PAGER_DUTY_SETTINGS = Pager_Duty_Settings__c.getOrgDefaults();
    }

    public static void initSlackSettings() {
        SLACK_SETTINGS = Slack_Settings__c.getOrgDefaults();
    }

    public static void initGraphAPISettings() {
        GRAPH_API_SETTINGS = Graph_API_Settings__c.getOrgDefaults();
    }

    public static void initAzureDevOpsAPISettings() {
        AZURE_DEV_OPS_API_SETTINGS = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
    }

    public static void initDebugLogServiceSettings() {
        DEBUG_LOG_SERVICE_SETTINGS = Debug_Log_Service_Flag__c.getOrgDefaults();
    }

    public static void initJiraFieldsMappings() {
        JIRA_FIELDS_MAPPINGS = new JiraFieldsMappingsConfig();
        JIRA_FIELDS_MAPPINGS.jira_fields_mapping = getJiraFieldsMappings();
    }

    public static void initSplunkFields() {
        SPLUNK_FIELDS = new SplunkFieldsConfig();
        SPLUNK_FIELDS.splunk_fields = getSplunkFields();
    }

    public static List<JiraFieldsMapping> getJiraFieldsMappings() {
        List<JiraFieldsMapping> result = new List<JiraFieldsMapping>();

        Map<String, Jira_Fields_Mapping__c> allSettings = Jira_Fields_Mapping__c.getAll();
        for(Jira_Fields_Mapping__c setting : allSettings.values()) {
            JiraFieldsMapping mapping = new JiraFieldsMapping();
            if(String.isNotBlank(setting.Log_Field__c)
                    && String.isNotBlank(setting.Jira_Field__c)) {

                mapping.logField = setting.Log_Field__c;
                mapping.jiraField = setting.Jira_Field__c;
                mapping.issueTypeId = setting.Issue_Type_Id__c;
                mapping.sobjectType = setting.SobjectType__c;
                mapping.projectId = setting.Project_Id__c;
                result.add(mapping);
            }
        }

        return result;
    }

    public static List<String> getSplunkFields() {
        List<String> result = new List<String>();

        Map<String, Splunk_Fields__c> allSettings = Splunk_Fields__c.getAll();
        for(Splunk_Fields__c setting : allSettings.values()) {
            if(String.isNotBlank(setting.Field_Name__c)) {
                result.add(setting.Field_Name__c);
            }
        }

        return result;
    }

    public static void setSplunkFields(List<String> fields) {
        List<Splunk_Fields__c> toUpsert = new List<Splunk_Fields__c>();

        for(String fieldName : fields) {
            toUpsert.add(new Splunk_Fields__c(Name = fieldName, Field_Name__c = fieldName));
        }
        DatabaseUtils.getInstance().performUpsertDML(toUpsert, Schema.SObjectType.Splunk_Fields__c, Splunk_Fields__c.Name, false)
                .handleError(ConfigUtil.class.getName(), '.setSplunkFields');
    }

    public static List<String> getAvailableSplunkFields() {
        List<String> fields = new List<String>();
        List<FieldSetMember> fieldsFS = SObjectType.Log__c.FieldSets.Splunk_Fields.getFields();
        Set<String> skipFieldNames = new Set<String>();
        for(Schema.FieldSetMember fsm : fieldsFS) {
            fields.add(fsm.getFieldPath());
        }
        return fields;
    }

    // AdminService

    public static final String REST_REMOTE_SITE_SETTINGS_QUERY = 'SELECT+Id,IsActive,SiteName,EndpointUrl+FROM+RemoteProxy+WHERE+IsActive+=+TRUE';
    public static final String REST_CSP_TRUSTED_SITES_QUERY = 'SELECT+Id,IsActive,DeveloperName,EndpointUrl+FROM+CspTrustedSite+WHERE+IsActive+=+TRUE';

    public static Map<String, String> getRemoteSiteSettingsHeadersMap(String accessToken) {
        return new Map<String, String> {
            HttpUtils.HEADER_AUTHORIZATION => HttpUtils.AUTH_TYPE_BEARER + accessToken,
            HttpUtils.HEADER_CONTENT_TYPE => HttpUtils.HTTP_CONTENT_TYPE_JSON
        };
    }

    public static Map<String, String> getCspTrustedSitesHeadersMap(String accessToken) {
        return new Map<String, String> {
            HttpUtils.HEADER_AUTHORIZATION => HttpUtils.AUTH_TYPE_BEARER + accessToken,
            HttpUtils.HEADER_CONTENT_TYPE => HttpUtils.HTTP_CONTENT_TYPE_JSON
        };
    }

    public static final String REMOTE_SITE_SETTINGS_KEY_RECORDS = 'records';
    public static final String CSP_TRUSTED_SITES_KEY_RECORDS = 'records';
    public static final String CONNECTED_ORGS_INFO_KEY_SETTINGS = 'settings';
    public static final String CONNECTED_ORGS_INFO_KEY_CONNECTED_ORGS = 'connectedOrgs';
    public static final String CONNECTION_ORG_KEY_CORG = 'corg';
    public static final String CONNECTION_ORG_KEY_CLIENT_KEY = 'clientKey';
    public static final String EXCEPTION_CONNECTED_ORG_NOT_FOUND = 'Connected Org not found';
    public static final String EXCEPTION_CONNECTED_ORG_DELETE_FAIL = 'Org not found. Unable to delete connected org';
    public static final String CONNECTED_ORG_TESTING_KEY_SUCCESS = 'Success!';
    public static final String CONNECTED_ORG_TESTING_KEY_FAIL = 'Connection Test Fail';
    public static final String CURRENT_ORG_IS_SANDBOX_KEY = 'isSandbox';


    public static Map<String, String> REQUEST_CREATE_REMOTE_SITE_SETTINGS_HEADERS_MAP {
        get {
            return new Map<String, String> {
                'SOAPAction' => '""',
                HttpUtils.HEADER_CONTENT_TYPE => 'text/xml'
            };
        }
        private set;
    }

    public static final String EMAIL_SERVICE_DATA_KEY_CONFIRMED  = 'confirmed';

    public static final String LOGGER_WRAPPER_INFO_KEY_CODE = 'code';
    public static final String LOGGER_WRAPPER_INFO_KEY_TEST_CODE = 'testCode';

    public static Map<String, String> getToolingHeaders() {
        return new Map<String, String> {
            HttpUtils.HEADER_AUTHORIZATION => HttpUtils.AUTH_TYPE_BEARER + ConnectedOrgService.getSelfConnectedOrgAccessToken(),
            HttpUtils.HEADER_CONTENT_TYPE => HttpUtils.HTTP_CONTENT_TYPE_JSON
        };
    }

    public static String getRequestBodyCreateEmailServiceFunction(String ehClassId) {
        return '{'+
            '  "IsActive": true,'+
            '  "ApexClassId": "'+ehClassId+'",'+
            '  "FunctionName": "ErrorEmailHandler",'+
            '  "OverLimitAction": "Discard",'+
            '  "AttachmentOption": "All",'+
            '  "AuthorizedSenders": "",'+
            '  "ErrorRoutingAddress": "",'+
            '  "AddressInactiveAction": "Discard",'+
            '  "IsErrorRoutingEnabled": false,'+
            '  "FunctionInactiveAction": "Discard",'+
            '  "IsTextAttachmentsAsBinary": false,'+
            '  "AuthorizationFailureAction": "Discard",'+
            '  "AuthenticationFailureAction": "Discard"'+
        '}';
    }

    public static String getRequestBodyCreateEmailService(String responseId) {
        return JSON.serialize(new Map<String, Object>{
            'DeveloperName' => EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME,
            'IsActive' => true,
            'LocalPart' => EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME,
            'FunctionId' => responseId,
            'RunAsUserId' => UserInfo.getUserId(),
            'AuthorizedSenders' => ''
        });
    }

    public static final String USER_SESSION_ID {
        get {
            if (USER_SESSION_ID == null) {
                if (Test.isRunningTest()) {
                    USER_SESSION_ID = UserInfo.getSessionId();
                } else {
                    String content = Page.getSessionId.getContent().toString();
                    USER_SESSION_ID = content.substring(content.indexOf('START_SESSION_ID') + 'START_SESSION_ID'.length(),
                            content.indexOf('END_SESSION_ID'));
                }

            }
            return USER_SESSION_ID;
        }
        private set;
    }

    public static final String CONFIRM_EMAIL_SERVICE_KEY_VALUE = 'value';
    public static final String CONFIRM_AUTOMATED_FLOW_ERROR_TRACKING_KEY = 'flowErrorTracking';
    public static final String CONFIRM_EVENT_MONITORING_TRACKING_KEY = 'eventMonitoringTracking';
    public static final String CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_KEY = 'emailToCaseTracking';
    public static final String CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_KEY = 'emailToCaseTrackingStatus';
    public static final String CONFIRM_EMAIL_TO_CASE_ERROR_TRACKING_ENABLED_KEY = 'enabledEmailToCaseTracking';

    public static final String BATCH_ERROR_TRACKING_ENABLED = 'batchErrorTrackingEnabled';
    public static final String ERROR_REPORTING_OPT_OUT = 'errorReportingOptOut';
    public static final String USE_OAUTH_FOR_SELF_ORG = 'useOauthForSelfOrg';

    public static final String CREATE_META_REQUEST_DATA_KEY_PROJECT_ID = 'projectId';
    public static final String CREATE_META_REQUEST_DATA_KEY_ISSUE_TYPE_ID = 'issueTypeId';
    public static final String CREATE_META_REQUEST_DATA_KEY_ISSUE_TYPE_IDS = 'issueTypeIds';
    public static final String CREATE_META_REQUEST_DATA_KEY_META = 'meta';
    public static final String CREATE_META_REQUEST_DATA_KEY_COMPONENTS = 'components';
    public static final String CREATE_META_REQUEST_DATA_KEY_EPICS = 'epics';
    public static final String CREATE_META_REQUEST_DATA_KEY_PRIORITIES = 'priorities';
    public static final String CREATE_META_REQUEST_DATA_KEY_FIELDS_MAPPING = 'fieldsMapping';

    public static final String PICKLIST_KEY_NAME = 'name';
    public static final String PICKLIST_KEY_LABEL = 'label';
    public static final String PICKLIST_KEY_VALUE = 'value';
    public static final String PICKLIST_KEY_VALUES = 'values';
    public static final String PICKLIST_KEY_TYPE = 'type';

    public static final String CONNECTED_APP_NAME = 'Pharos.ai';//'PharosApp';
    public static final String CONNECTED_APP_API_NAME = 'Pharos_ai';
    public static final String PHAROS_PACKAGE_PUBLISHER = 'Golden Ratio Systems LLC';
    public static final String PHAROS_PACKAGE_PUBLISHER_NAMESPACE = 'pharos';
    // https://loggertest1.ap4.visual.force.com/apex/pharos__Settings
    public static final String CONNECTED_APP_CALLBACK_PAGE_URL = '/apex/' + ConfigUtil.getNameSpacePrefix() + 'Settings';

    public static final String SENSETIVE_MASK_KEY_ID = 'id';
    public static final String SENSETIVE_MASK_KEY_TEXT = 'text';
    public static final String SENSETIVE_MASK_KEY_REGEX = 'regex';
    public static final String SENSETIVE_MASK_KEY_MASK = '********';

	public static final String SLACK_SERVICE_NAME = 'Slack';
	public static final String PAGER_DUTY_SERVICE_NAME = 'PagerDuty';
    public static final String TEAMS_SERVICE_NAME = 'Teams';
    public static final String WEBHOOK_SERVICE_NAME = 'Webhook';

    public static final String LOG_CATEGORIES_KEY_CATEGORIES = 'categories';
    public static final String LOG_CATEGORIES_KEY_RECORDTYPES = 'recordtypes';
    public static final String LOG_CATEGORIES_KEY_MAPPINGS = 'mappings';

    public static final String MONITORING_APP_KEY_ENABLED = 'enabled';
    public static final String MONITORING_APP_KEY_FREQUENCY = 'frequency';
    public static final String MONITORING_APP_KEY_ENABLED_TYPES = 'enabledTypes';

    public static final String DELETE_MONITORING_RULE_ACTION_KEY_ACTION_RESULT = 'actionResult';

    public static final String EVENT_ACTION_DELIVERED_TO_SLACK = 'Slack Channels:';
    public static final String EVENT_ACTION_DELIVERED_TO_TEAMS = 'Teams Channels:';
    public static final String EVENT_ACTION_DELIVERED_TO_JIRA = 'JIRA Ticket:';
    public static final String EVENT_ACTION_DELIVERED_TO_EMAIL = 'Emails:';
    public static final String EVENT_ACTION_DELIVERED_TO_PAGER_DUTY = 'Pager Duty ';
    public static final String EVENT_ACTION_DELIVERED_TO_REMOVAL = 'Record Removed';
    public static final String EVENT_ACTION_DELIVERED_TO_LOCAL_ARCHIVAL = 'Archival_Log__b Big Object';
    public static final String EVENT_ACTION_DELIVERED_TO_SPLUNK = 'Sent to Splunk';

    public static final String SIMPLE_KEY_WITH_COLON_SEPARATOR = '{0}:{1}';

    public static final Set<String> UNAFFECTED_OBJECTS = new Set<String> {
            'Organization', 'AsyncApexJob', 'FlowOrchestrationStepInstance', 'FlowOrchestrationStageInstance', 'FlowOrchestrationInstance',
            'RecordType', 'Group', 'BusinessHours'
    };
    public static final Set<String> DEFAULT_AREAS = new Set<String> {
            'Pharos', 'Apex', 'Flow', 'Process Builder', 'Async Apex', 'Background Job'
    };

    // Maximum number of related IDs based on JSON size calculation for Long Text Area field (32,768 chars)
    // JSON format: ["id1","id2","id3"] = 2 chars for brackets + (18 chars per ID + 3 chars for quotes and comma) * count - 1 comma
    // Approximately 21 chars per ID + 2 for brackets = ~21 chars per ID
    // 32768 / 21 ≈ 1559, using 1500 for safety buffer
    public static final Integer MAX_RELATED_IDS_COUNT = 1500;

    public static Set<String> getRelatedSObjectIds(String message, Boolean isInternalErrorLog) {
        Set<String> sObjectIds = new Set<String>();
        Pattern p = Constants.GLOBAL_VARIABLE.PATTERN_SOBJECT_ID;
        Matcher pm = p.matcher(message);
        while (pm.find()) {
            try {
                if (sObjectIds.size() >= MAX_RELATED_IDS_COUNT) {
                    break;
                }
                sObjectIds.add(isInternalErrorLog ? Id.valueOf(pm.group(1)) : pm.group(1));
            } catch (Exception e) {
                // catch Invalid id
            }
        }
        return sObjectIds;
    }

    public static void updateTimeZone(List<SObject> sObjects, String fieldName) {
        for (SObject sObj : sObjects) {
            Integer offset = UserInfo.getTimeZone().getOffset((Datetime)sObj.get(fieldName));
            sObj.put(fieldName, ((Datetime)sObj.get(fieldName)).addSeconds(offset/1000));
        }
    }

    public static List<Map<String, Object>> getSObjectWithoutNameSpace(List<SObject> records) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for(SObject record : records) {
            result.add(getSObjectWithoutNameSpace(record.getPopulatedFieldsAsMap()));
        }
        return result;
    }

    public static Map<String, Object> getSObjectWithoutNameSpace(SObject record) {
        return getSObjectWithoutNameSpace(record.getPopulatedFieldsAsMap());
    }

    public static Map<String, Object> getSObjectWithoutNameSpace(Map<String, Object> mapRecord) {
        Map<String, Object> result = new Map<String, Object>();
        for(String fieldName : mapRecord.keySet()) {
            String fieldNameWithoutNameSpace = fieldName?.containsIgnoreCase(ConfigUtil.nameSpacePrefix)
                ? fieldName.remove(ConfigUtil.nameSpacePrefix)
                : fieldName;
            result.put(fieldNameWithoutNameSpace, mapRecord.get(fieldName));
        }
        return result;
    }

    public class BooleanExpressionNode {
        private String value;
        private BooleanExpressionNode left;
        private BooleanExpressionNode right;

        public BooleanExpressionNode(String value) {
            this.value = value;
            this.left = null;
            this.right = null;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }

        public BooleanExpressionNode getLeft() {
            return left;
        }

        public BooleanExpressionNode getRight() {
            return right;
        }

        public void setLeft(BooleanExpressionNode left) {
            this.left = left;
        }

        public void setRight(BooleanExpressionNode right) {
            this.right = right;
        }

        public override String toString() {
            return value;
        }

        public String toTreeString() {
            return toTreeStringHelper(this, 0);
        }

        private String toTreeStringHelper(BooleanExpressionNode node, Integer level) {
            String builder = '';
            if (node != null) {
                for (Integer i = 0; i < level; i++) {
                    builder += '\t';
                }
                builder += node.getValue();
                builder += '\n';
                builder += toTreeStringHelper(node.getLeft(), level + 1);
                builder += toTreeStringHelper(node.getRight(), level + 1);
            }
            return builder;
        }
        public String toConditionString() {
            return toConditionStringHelper(this);
        }

        private String toConditionStringHelper(BooleanExpressionNode node) {
            if (node == null) {
                return '';
            }

            String leftString = toConditionStringHelper(node.getLeft());
            String rightString = toConditionStringHelper(node.getRight());

            if (String.isEmpty(leftString) && String.isEmpty(rightString)) {
                return node.getValue();
            } else if (String.isEmpty(rightString)) {
                return leftString + ' ' + node.getValue();
            } else if (node.getValue().equals(OPERATOR_AND) && rightString.startsWith(OPERATOR_AND)) {
                return leftString + ' ' + node.getValue() + ' ' + rightString.substring(4);
            } else {
                return '(' + leftString + ' ' + node.getValue() + ' ' + rightString + ')';
            }
        }
    }

    private static boolean isOperator(String token) {
        return String.isNotBlank(token) && (token?.equalsIgnoreCase(OPERATOR_AND) || token?.equalsIgnoreCase(OPERATOR_OR));
    }

    public static final String OPERATOR_OR = 'OR';
    public static final String OPERATOR_AND = 'AND';
    public static final String OPEN_PARENTHESIS = '(';
    public static final String CLOSE_PARENTHESIS = ')';
    public static final String EXPRESSION_PARSER_TOKENS = '\\s+|(?<=\\()|(?=\\()|(?<=\\))|(?=\\))';

    public class BooleanExpressionParser {
        private BooleanExpressionNode root;
        private Set<String> operands;
        private Boolean isValid;

        public BooleanExpressionParser(String expression) {
            this.root = parse(expression);
        }

        public BooleanExpressionParser() {
            this.root = null;
        }

        public BooleanExpressionNode parse(String expression) {
            List<String> tokens = tokenize(expression);
            this.root = buildExpressionTree(tokens);
            this.isValid = validateTokens(tokens) && validateExpression(this.root);
            return this.root;
        }

        public Boolean isValidExpression() {
            return this.isValid;
        }

        public Boolean validateExpression(BooleanExpressionNode node) {
            if (isOperator(node?.getValue())) {
                if (node?.getLeft() == null || node?.getRight() == null) {
                    return false;
                }
                return validateExpression(node?.getLeft()) && validateExpression(node?.getRight());
            }
            return true;
        }

        private Boolean validateTokens(List<String> tokens) {
            Boolean allTokensValid = true;
            for(String token : tokens) {
                Boolean tokenValid = (token.equalsIgnoreCase(OPERATOR_OR) 
                    || token.equalsIgnoreCase(OPERATOR_AND)
                    || token.equalsIgnoreCase(OPEN_PARENTHESIS)
                    || token.equalsIgnoreCase(CLOSE_PARENTHESIS)
                    || token.isNumeric());
                allTokensValid = allTokensValid && tokenValid ? allTokensValid : false;
            }
            return allTokensValid;
        }

        private List<String> tokenize(String expression) {
            List<String> tokens = new List<String>();
            String[] parts = expression.split(EXPRESSION_PARSER_TOKENS);
            for (String part : parts) {
                if (String.isNotBlank(part)) {
                    tokens.add(part.trim());
                }
            }
            return tokens;
        }

        private boolean hasPrecedence(String operator1, String operator2) {
            return (operator2.equalsIgnoreCase(OPERATOR_OR) && operator1.equalsIgnoreCase(OPERATOR_AND));
        }

        private BooleanExpressionNode buildExpressionTree(List<String> tokens) {
            List<BooleanExpressionNode> stack = new List<BooleanExpressionNode>();
            List<String> operatorStack = new List<String>();
            this.operands = new Set<String>();
            if(tokens == null) return null;
            for (String token : tokens) {
                if (token.equalsIgnoreCase(OPERATOR_AND) || token.equalsIgnoreCase(OPERATOR_OR)) {
                    while (!operatorStack.isEmpty() && hasPrecedence(token, operatorStack[operatorStack.size() - 1])) {
                        processOperator(stack, operatorStack.remove(operatorStack.size() - 1));
                    }
                    operatorStack.add(token);
                } else if (token.equals(OPEN_PARENTHESIS)) {
                    operatorStack.add(token);
                } else if (token.equals(CLOSE_PARENTHESIS)) {
                    while (!operatorStack.isEmpty() && !operatorStack[operatorStack.size() - 1].equals(OPEN_PARENTHESIS)) {
                        processOperator(stack, operatorStack.remove(operatorStack.size() - 1));
                    }
                    operatorStack.remove(operatorStack.size() - 1); // Discard the opening parentheses
                } else {
                    BooleanExpressionNode node = new BooleanExpressionNode(token);
                    stack.add(node);
                    this.operands.add(token);
                }
            }
            while (!operatorStack.isEmpty()) {
                processOperator(stack, operatorStack.remove(operatorStack.size() - 1));
            }
            return !stack?.isEmpty() ? stack?.remove(0) : null;
        }

        private void processOperator(List<BooleanExpressionNode> stack, String operator) {
            BooleanExpressionNode node = new BooleanExpressionNode(operator);
            if(!stack.isEmpty()) {
                node.setRight(stack.remove(stack.size() - 1));  
            }
            if(!stack.isEmpty()) {
                node.setLeft(stack.remove(stack.size() - 1));
            }
            stack.add(node);
        }

        public void add(BooleanExpressionNode operand, BooleanExpressionNode parent, boolean isLeftChild) {
            if (isLeftChild) {
                parent.setLeft(operand);
            } else {
                parent.setRight(operand);
            }
        }

        public void remove(BooleanExpressionNode operand, BooleanExpressionNode parent) {
            if (parent.getLeft() == operand) {
                parent.setLeft(null);
            } else if (parent.getRight() == operand) {
                parent.setRight(null);
            }
        }

        public Set<String> getOperands() {
            return this.operands;
        }

        public void addOperand() {
            addOperand(String.valueOf(this.operands.size() + 1));
        }

        public void addOperand(String operandNumber) {
            addOperandHelper(root, operandNumber);
        }

        private void addOperandHelper(BooleanExpressionNode parent, String operandNumber) {
            BooleanExpressionNode newNode;
            if(parent == null) {
                newNode = new BooleanExpressionNode(operandNumber);
                root = newNode;
            }
            else {
                if(parent.getRight() == null && parent.getLeft() == null) {
                    newNode = new BooleanExpressionNode(OPERATOR_AND);
                    newNode.setLeft(new BooleanExpressionNode(parent.getValue()));
                    newNode.setRight(new BooleanExpressionNode(operandNumber));
                    root = newNode;
                }
                else if(parent.getRight() != null) {
                    newNode = new BooleanExpressionNode(OPERATOR_AND);
                    newNode.setLeft(parent);
                    newNode.setRight(new BooleanExpressionNode(operandNumber));
                    root = newNode;
                }
                else {
                    newNode = new BooleanExpressionNode(operandNumber);
                    parent.setRight(newNode);
                }
            }
            this.operands.add(operandNumber);
        }

        public String toConditionString() {
            return this.root?.toConditionString();
        }

        public String toTreeString() {
            return this.root.toTreeString();
        }

        public void removeOperand(String operandNumber) {
            removeOperandHelper(root, operandNumber, null, false);
        }

        public void removeOperand(String operandNumber, Boolean remove) {
            removeOperandHelper(root, operandNumber, null, remove);
        }
        

        private void removeOperandHelper(BooleanExpressionNode node, String operandNumber, BooleanExpressionNode parent, Boolean remove) {
            if (node == null) {
                return;
            }

            if (node.getValue().equals(operandNumber)) {
                if(remove) {
                    this.operands.remove(operandNumber);
                }
                if (parent != null) {
                    if (parent.getLeft() == node) {
                        parent.setLeft(null);
                        if (parent.getRight() != null) {
                            parent.setValue(parent.getRight().getValue());
                            parent.setLeft(parent.getRight().getLeft());
                            parent.setRight(parent.getRight().getRight());
                        }
                    } else if (parent.getRight() == node) {
                        parent.setRight(null);
                        if (parent.getLeft() != null) {
                            parent.setValue(parent.getLeft().getValue());
                            parent.setRight(parent.getLeft().getRight());
                            parent.setLeft(parent.getLeft().getLeft());
                        }
                    }
                } else {
                    root = null;
                }
            } else {
                removeOperandHelper(node.getLeft(), operandNumber, node, remove);
                removeOperandHelper(node.getRight(), operandNumber, node, remove);
            }

        }

    }

    public static final Integer LOG_INDEX_MAX_SIZE_KEY_HASH = 45;
    public static final Integer LOG_INDEX_MAX_SIZE_KEY_ORG_ID = 15;
    // public static final Integer LOG_INDEX_MAX_SIZE_KEY_TYPE = 1;
    // default Type - A
    public static final String LOG_INDEX_TYPE_HASH1 = 'A'; //A-Z

    public static String getLogIndexKey(String hash, String organizationId) {
        return getLogIndexKey(hash, organizationId, LOG_INDEX_TYPE_HASH1);
    }
    
    public static String getLogIndexKey(String hash, String organizationId, String keyType) {
        Boolean uniqueByOrg = ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c;
        String orgId = (String.isBlank(organizationId)) ? UserInfo.getOrganizationId() : organizationId;
        String key = (uniqueByOrg) ? hash?.left(LOG_INDEX_MAX_SIZE_KEY_HASH) + orgId?.left(LOG_INDEX_MAX_SIZE_KEY_ORG_ID) : hash?.left(LOG_INDEX_MAX_SIZE_KEY_HASH);
        key += keyType;
        return key;
    }
    
    public with sharing class LogIndexHelper {
        
        private Boolean uniqueByOrg = ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c;

        private Map<String, LogIndex> mapIndexes = new Map<String, LogIndex>();
        private Map<String, Log_Index__c> logIndexes = new Map<String, Log_Index__c>();

        public LogIndexHelper(Set<String> keys) {
            getMapLogIndexes(keys);
        }

        public LogIndex getLogIndex(String key) {
            return this.mapIndexes.get(key);
        }

        public LogIndex getLogIndex(Log__c log) {
            return this.mapIndexes.get(getLogIndexKey(log.Hash_1__c, log.Organization_Id__c));
        }

        public LogIndex getLogIndex(String hash, String organizationId) {
            return this.mapIndexes.get(getLogIndexKey(hash, organizationId));
        }

        public LogIndex createLogIndex(Log__c log) {
            LogIndex newIndex;
            if(log?.Hash_1__c != null) {
                newIndex = new LogIndex(log?.Hash_1__c, log?.Organization_Id__c, log?.Created_At__c);
                if(log?.Resolved_On__c != null) {
                    newIndex.resolvedOn = log?.Resolved_On__c;
                }
                if(String.isNotBlank(log?.Bug_Tracker__c)) {
                    newIndex.bugTracker = log?.Bug_Tracker__c;
                }
                if(log?.Category__c == Logger.CATEGORY_PHAROS_ERROR || log.Area__c == Logger.AREA_PHAROS_ERROR) {
                    newIndex.internal = true;
                }
                this.logIndexes.put(newIndex.key, newIndex.toSObject());
                this.mapIndexes.put(newIndex.key, newIndex);
            }
            return newIndex;
        }

        public void saveLogIndexes(Logger logger) {
            DatabaseUtils.getInstance().performUpsertDML(this.logIndexes.values(), Schema.SObjectType.Log_Index__c, Log_Index__c.Key__c, false)
                .filterUpsertResultsDuplicateValue(Schema.SObjectType.Log_Index__c.fields.Key__c.getName())
                .handleError(ConfigUtil.class.getName(), '.saveLogIndexes', logger);
            if (!this.logIndexes.isEmpty()) this.logIndexes = new Map<String, Log_Index__c>();
        }

        public void updateLogIndex(LogIndex logIndex) {
            this.logIndexes.put(logIndex.key, logIndex.toSObject());
        }

        public void saveLogIndex(Logger logger, LogIndex logIndex) {
            DatabaseUtils.getInstance().performUpsertDML(new List<Log_Index__c>{logIndex.toSObject()}, Schema.SObjectType.Log_Index__c, Log_Index__c.Key__c, false)
                .filterUpsertResultsDuplicateValue(Schema.SObjectType.Log_Index__c.fields.Key__c.getName())
                .handleError(ConfigUtil.class.getName(), '.saveLogIndex', logger);
        }
        
        public void getMapLogIndexes(Set<String> keys) {
            if(!keys.isEmpty()) {
                for(Log_Index__c logIndex : [SELECT Id, Hash__c, Organization_Id__c, Bug_Tracker__c, Resolved_On__c, First_Occurred_On__c, Type__c, Key__c, Internal__c, Reported_to_Pharos_On__c, CV_Reported_to_Pharos_On__c FROM Log_Index__c WHERE Key__c IN :keys]) {
                    LogIndex index = new LogIndex(logIndex);
                    this.mapIndexes.put(index.key, index);
                }
            }
        }
    }

    public class LogIndex {
        public String id;
        public String key;
        public String hash;
        public String organizationId;
        public String bugTracker;
        public String type;
        public DateTime resolvedOn;
        public DateTime firstOccurredOn;
        public Boolean internal;
        public DateTime reportedToPharosOn;
        public DateTime cvreportedToPharosOn;

        public LogIndex(String hash, String organizationId, DateTime firstOccurredOn) {
            this.key = getLogIndexKey(hash, organizationId);
            this.hash = hash;
            this.organizationId = (String.isBlank(organizationId)) ? UserInfo.getOrganizationId() : organizationId;
            this.firstOccurredOn = firstOccurredOn;
            this.type = LOG_INDEX_TYPE_HASH1;
            this.internal = false;
        }

        public LogIndex(Log_Index__c logIndex) {
            this.id = logIndex.Id;
            this.key = logIndex.Key__c;
            this.hash = logIndex.Hash__c;
            this.organizationId = logIndex.Organization_Id__c;
            this.bugTracker = logIndex.Bug_Tracker__c;
            this.firstOccurredOn = logIndex.First_Occurred_On__c;
            this.resolvedOn = logIndex.Resolved_On__c;
            this.type = logIndex.Type__c;
            this.internal = logIndex.Internal__c;
            this.reportedToPharosOn = logIndex.Reported_to_Pharos_On__c;
            this.cvreportedToPharosOn = logIndex.CV_Reported_to_Pharos_On__c;
        }

        public Log_Index__c toSObject() {
            return new Log_Index__c(
                Id = this.id,
                Key__c = this.key,
                Type__c = this.type,
                Hash__c = this.hash,
                Organization_Id__c = this.organizationId,
                Bug_Tracker__c = this.bugTracker,
                First_Occurred_On__c = this.firstOccurredOn,
                Resolved_On__c = this.resolvedOn,
                Internal__c = this.internal,
                Reported_to_Pharos_On__c = this.reportedToPharosOn,
                CV_Reported_to_Pharos_On__c = this.cvreportedToPharosOn
            );
        }
    }

    public static DateTime parseRFC2822(String input) {
        List<String> parts = input.substring(input.indexOf(', ') + 2).split(' ');
        List<String> dateparts = new List<String>{parts[2], parts[1],parts[0]};
        List<String> timeparts = parts[3].split(':');

        dateparts[1] = Constants.GLOBAL_VARIABLE.RFC2822_MONTHS.get(dateparts[1]);
        return DateTime.newInstanceGMT(integer.valueOf(dateParts[0]), 
            integer.valueOf(dateParts[1]),
            integer.valueOf(dateParts[2]),
            integer.valueOf(timeparts[0]),
            integer.valueOf(timeparts[1]),
            integer.valueOf(timeparts[2]));
    }

    public static DateTime getDateTimeFromEmailHeader(Messaging.inboundEmail email) {
        DateTime result;
        if(email != null && !email.headers.isEmpty()) {
            try {
                for(Messaging.InboundEmail.Header header : email.headers) {
                    if(header.name == 'Date') {
                        result = parseRFC2822(header.value);
                        break;
                    }
                }
                
            }
            catch(Exception e){}
        }
        return result;
    }

    public class HTMLStringRowIterator implements Iterator<String>, Iterable<String> {
        private String mData;
        private Integer mindex = 0;
        private String mrowDelimiter = '</p>';
            
        public HTMLStringRowIterator(String fileData) {
            mData = fileData; 
        }

        public HTMLStringRowIterator(String fileData, String rowDelimiter) {
            mData = fileData; 
            mrowDelimiter = rowDelimiter;
        }
            
        public Boolean hasNext() {
            return mindex < mData.length() ? true : false;
        }
        
        public String next() {
            Integer key = mData.indexOf(mrowDelimiter, mindex);
            
            if (key == -1) {
                key = mData.length();
            }

            String row = mData.subString(mindex, key);
            mindex = key + 1;
            return row;
        }

        public Iterator<String> Iterator() {
            return this;
        }
    }

    public static Boolean initializeDevelopmentMode(System.PageReference pageReference) {
        // OWASP: Validate parameter value using allow-list approach
        String isDevParam = pageReference?.getParameters()?.get('dev')?.escapeHtml4();
        if (String.isNotBlank(isDevParam)) {
            // Security: Only accept 'true' or 'false' values (allow-list)
            if (isDevParam.toLowerCase() == 'true' || isDevParam.toLowerCase() == 'false') {
                Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
                pageReference.setCookies(new Cookie[]{ devCookie });
                return Boolean.valueOf(isDevParam);
            }
        } else {
            Cookie devCookie = pageReference.getCookies().get('a2developmentMode');
            return devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
        }

        return false;
    }
}