public with sharing class Constants {
    
    public static final GlobalVariable GLOBAL_VARIABLE { 
        get { return GLOBAL_VARIABLE == null ? (GLOBAL_VARIABLE = new GlobalVariable()) : GLOBAL_VARIABLE; }
        private set;
    }

    public static final AIEventSObject AI_EVENT_SOBJECT { 
        get { return AI_EVENT_SOBJECT == null ? (AI_EVENT_SOBJECT = new AIEventSObject()) : AI_EVENT_SOBJECT; }
        private set;
    }

    public static final IssueSObject ISSUE_SOBJECT { 
        get { return ISSUE_SOBJECT == null ? (ISSUE_SOBJECT = new IssueSObject()) : ISSUE_SOBJECT; }
        private set;
    }
    
    public static final Jobs JOBS { 
        get { return JOBS == null ? (JOBS = new Jobs()) : JOBS; }
        private set;
    }
    
    public static final LogSObject LOG_SOBJECT { 
        get { return LOG_SOBJECT == null ? (LOG_SOBJECT = new LogSObject()) : LOG_SOBJECT; }
        private set;
    }

    public static final LogEventSObject LOG_EVENT_SOBJECT { 
        get { return LOG_EVENT_SOBJECT == null ? (LOG_EVENT_SOBJECT = new LogEventSObject()) : LOG_EVENT_SOBJECT; }
        private set;
    }

    public static final LogIndexSObject LOG_INDEX_SOBJECT { 
        get { return LOG_INDEX_SOBJECT == null ? (LOG_INDEX_SOBJECT = new LogIndexSObject()) : LOG_INDEX_SOBJECT; }
        private set;
    }

    public static final LogeerSettingsSObject LOGGER_SETTINGS_SOBJECT { 
        get { return LOGGER_SETTINGS_SOBJECT == null ? (LOGGER_SETTINGS_SOBJECT = new LogeerSettingsSObject()) : LOGGER_SETTINGS_SOBJECT; }
        private set;
    }

    public static final Metadata METADATA { 
        get { return METADATA == null ? (METADATA = new Metadata()) : METADATA; }
        private set;
    }

    public static final RemoteSiteSettings REMOTE_SITE_SETTINGS {
        get { return REMOTE_SITE_SETTINGS == null ? (REMOTE_SITE_SETTINGS = new RemoteSiteSettings()) : REMOTE_SITE_SETTINGS; }
        private set;
    }

    public static final StaticResourceSObject STATIC_RESOURCE_SOBJECT {
        get { return STATIC_RESOURCE_SOBJECT == null ? (STATIC_RESOURCE_SOBJECT = new StaticResourceSObject()) : STATIC_RESOURCE_SOBJECT; }
        private set;
    }

    public static final TraceResultSObject TRACE_RESULT_SOBJECT { 
        get { return TRACE_RESULT_SOBJECT == null ? (TRACE_RESULT_SOBJECT = new TraceResultSObject()) : TRACE_RESULT_SOBJECT; }
        private set;
    }

    public static final UI UI { 
        get { return UI == null ? (UI = new UI()) : UI; }
        private set;
    }

    public inherited sharing class GlobalVariable {
        public final String BASE_URL = System.Url.getOrgDomainUrl().toExternalForm();
        public final String NEWLINE_CHARACTERS = '\r\n';
        public final Integer TEXT_FIELD_MAX_LENGTH = 255;

        public final String SYMBOL_AT = '@';

        public final String SALESFORCE_DOMAIN = 'my.salesforce.com';
        public final String CUSTOM_DOMAIN_SYMBOLS = '--';

        public final Pattern PATTERN_SOBJECT_ID = Pattern.compile('([a-zA-Z0-9]{15,18})');

        public final Map<String, String> RFC2822_MONTHS = new Map<String, String> {
            'Jan' => '01',
            'Feb' => '02',
            'Mar' => '03',
            'Apr' => '04',
            'May' => '05',
            'Jun' => '06',
            'Jul' => '07',
            'Aug' => '08',
            'Sep' => '09',
            'Oct' => '10',
            'Nov' => '11',
            'Dec' => '12'    
        };
    }

    public inherited sharing class AIEventSObject extends SObjectTypeConstants {
        public final String TRIGGER_NAME_AI_EVENT = 'AiEventTrigger';

        private AIEventSObject() {
            this.objectType = AI_Event__e.SObjectType;
        }
    }

    public inherited sharing class IssueSObject extends SObjectTypeConstants {
        private IssueSObject() {
            this.objectType = Issue__c.SObjectType;
        }
    }
    
    public inherited sharing class Jobs {
        public final String ASYNC_APEX_JOB_PROCESS_STATUS_PROCESSING = 'Processing';
        public final String ASYNC_APEX_JOB_PROCESS_STATUS_PREPARING = 'Preparing';
        public final String ASYNC_APEX_JOB_PROCESS_STATUS_QUEUED = 'Queued';
        public final String ASYNC_APEX_JOB_PROCESS_STATUS_HOLDING = 'Holding';

        public final String ASYNC_APEX_JOB_PROCESS_TYPE_SCHEDULED_APEX = 'ScheduledApex';
        public final String ASYNC_APEX_JOB_PROCESS_TYPE_BATCH_APEX_WORKER = 'BatchApexWorker';
    
        public final String CRON_EXP_DEBUG_LOG_SERVICE_SCHEDULER_1 = '0 55 * * * ?';
        public final String CRON_EXP_DEBUG_LOG_SERVICE_SCHEDULER_2 = '0 25 * * * ?';
        public final String CRON_EXP_PHAROS_LOG_SERVICE_SCHEDULER_MODE = '0 {0} * * * ?';

        public final String JOB_NAME_ARCHIVAL_SCHEDULER = 'ArchivalServiceScheduler';
        public final String JOB_NAME_ERROR_EMAIL_REPORT_SCHEDULER = 'ErrorEmailReportScheduler';
        public final String JOB_NAME_JIRA_RESOLUTION_SCHEDULER = 'JiraResolutionServiceScheduler';
        public final String JOB_NAME_LOG_POST_PROCESSING_BATCH_SCHEDULER = 'LogPostProcessingBatchScheduler';
        public final String JOB_NAME_MANAGE_TOKENS_SERVICE_SCHEDULER1 = 'ManageTokensServiceScheduler1';
        public final String JOB_NAME_MANAGE_TOKENS_SERVICE_SCHEDULER2 = 'ManageTokensServiceScheduler2';
        public final String JOB_NAME_MONITORING_SERVICE_SCHEDULER = 'MonitoringServiceScheduler';
        public final String JOB_NAME_PHAROS_BULK_API_SCHEDULER = 'Pharos Bulk API';
        public final String JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER = 'PharosLogServiceScheduler';
        public final String JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_1 = 'PharosLogServiceSchedulerMode1';
        public final String JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_2 = 'PharosLogServiceSchedulerMode2';
        public final String JOB_NAME_TRACE_BATCH_SERVICE_SCHEDULER = 'TraceBatchServiceScheduler';
        
        public final Set<String> ASYNC_APEX_JOB_PROCESS_STATUSES = new Set<String> {
            ASYNC_APEX_JOB_PROCESS_STATUS_PROCESSING,
            ASYNC_APEX_JOB_PROCESS_STATUS_PREPARING,
            ASYNC_APEX_JOB_PROCESS_STATUS_QUEUED,
            ASYNC_APEX_JOB_PROCESS_STATUS_HOLDING
        };

        public final Set<String> ASYNC_APEX_JOB_PROCESS_TYPES = new Set<String> {
            ASYNC_APEX_JOB_PROCESS_TYPE_SCHEDULED_APEX,
            ASYNC_APEX_JOB_PROCESS_TYPE_BATCH_APEX_WORKER
        };

        public final Set<String> PHAROS_LOG_SERVICE_SCHEDULER_MODE_JOB_NAMES = new Set<String>{
            JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_1,
            JOB_NAME_PHAROS_LOG_SERVICE_SCHEDULER_MODE_2
        };
    }
    
    public inherited sharing class LogSObject extends SObjectTypeConstants {
        public final String PHAROS_CATEGORY = 'Pharos Error';
        public final String PHAROS_AREA = 'Pharos';
        public final String LIMITS;
        public final String CREATED_AT;
        public final String CATEGORY;
        public final String AREA;

        private LogSObject() {
            this.objectType = Log__c.SObjectType;
            this.CREATED_AT = Schema.SObjectType.Log__c.fields.Created_At__c.getName();
            this.CATEGORY = Schema.SObjectType.Log__c.fields.Category__c.getName();
            this.AREA = Schema.SObjectType.Log__c.fields.Area__c.getName();
            this.LIMITS = Schema.SObjectType.Log__c.fields.Limits__c.getName();
        }
    }

    public inherited sharing class LogEventSObject extends SObjectTypeConstants {
        public final String TRIGGER_NAME_LOG_EVENT = 'LogEventTrigger';

        private LogEventSObject() {
            this.objectType = Log_Event__e.SObjectType;
        }
    }

    public inherited sharing class LogIndexSObject extends SObjectTypeConstants {
        public final Integer MAX_SIZE_KEY_HASH = 45; // TODO: move to LOG -?
        public final Integer MAX_SIZE_KEY_ORG_ID = 15; // TODO: move to LOG -?
        public final String TYPE_HASH1 = 'A'; //A-Z; default Type - A

        private LogIndexSObject() {
            this.objectType = Log_Index__c.SObjectType;
        }
    }

    public inherited sharing class LogeerSettingsSObject {
        public final String ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_PENDING = 'Pending';
        public final String ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ENABLED = 'Enabled';
        public final String ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_ERROR = 'Error';
        public final String ENABLE_EMAIL_TO_CASE_ERROR_TRACKING_STATUS_DISABLED = null;
    }

    public inherited sharing class Metadata {
        public final String FAILED_NO_ERRORS_MESSAGE = 'Request failed with no specified error.';

        public final String HANDLE_SAVE_RESULT_KEY_ERROR = 'Error ';
        public final String HANDLE_SAVE_RESULT_KEY_ERRORS = 'Errors ';
        public final String HANDLE_SAVE_RESULT_KEY_COMPONENTS = 'occured processing component ';
        public final String HANDLE_SAVE_RESULT_KEY_FIELDS = ' Fields ';
    }

    public inherited sharing class RemoteSiteSettings {
        public final String PHAROS_API_NAME = 'Pharos_ai_API';
        public final String PHAROS_API_DESCRIPTION = 'Remote site setting for Pharos API function endpoints. Enables callouts to Pharos services.';
        public final String PHAROS_API_API_URL = 'https://api.pharos.ai/';

        public final String GIT_SFDX_API_NAME = 'Pharos_ai_SFDX_API_token_URL';
        public final String GIT_SFDX_API_DESCRIPTION = 'Pharos.ai - SFDX integration URL';
        public final String GIT_SFDX_API_URL = 'https://sfdx.pharos.ai';

        public final String GIT_HUB_API_NAME = 'Pharos_ai_GitHub_API_token_URL';
        public final String GIT_HUB_API_DESCRIPTION = 'Pharos.ai - GitHubAPI integration URL';
        public final String GIT_HUB_API_URL = 'https://api.github.com';

        public final String GIT_HUB_NAME = 'Pharos_ai_GitHub_token_URL';
        public final String GIT_HUB_DESCRIPTION = 'Pharos.ai - GitHub integration URL';
        public final String GIT_HUB_URL = 'https://github.com';

        public final String AZURE_DO_REST_API_NAME = 'Pharos_ai_AzureDO_REST_API_URL';
        public final String AZURE_DO_REST_API_DESCRIPTION = 'Pharos.ai - AzureDevOps integration REST API URL';
        public final String AZURE_DO_REST_API_URL = 'https://dev.azure.com';

        public final String AZURE_DO_API_TOKEN_REQUEST_NAME = 'Pharos_ai_AzureDO_API_token_URL';
        public final String AZURE_DO_API_TOKEN_REQUEST_DESCRIPTION = 'Pharos.ai - AzureDevOps integration API token URL';
        public final String AZURE_DO_API_TOKEN_REQUEST_URL = 'https://app.vssps.visualstudio.com/oauth2/authorize';

        public final String GRAPH_API_TOKEN_REQUEST_NAME = 'Pharos_ai_Graph_API_token_URL';
        public final String GRAPH_API_TOKEN_REQUEST_DESCRIPTION = 'Pharos.ai - Graph integration API token URL';
        public final String GRAPH_API_TOKEN_REQUEST_URL = 'https://login.microsoftonline.com';

        public final String GRAPH_API_REQUEST_NAME = 'Pharos_ai_Graph_API_URL';
        public final String GRAPH_API_REQUEST_DESCRIPTION = 'Pharos.ai - Graph integration API URL';
        public final String GRAPH_API_REQUEST_URL = 'https://graph.microsoft.com';

        public final String SLACK_API_NAME = 'Pharos_ai_Slack_API_URL';
        public final String SLACK_DESCRIPTION = 'Pharos.ai - Slack integration API login URL';
        public final String SLACK_API_URL = 'https://slack.com';

        public final String PAGER_DUTY_API_NAME = 'Pharos_ai_PagerDuty_API_URL';
        public final String PAGER_DUTY_DESCRIPTION = 'Pharos.ai - PagerDuty integration API login URL';
        public final String PAGER_DUTY_URL = 'https://api.pagerduty.com';
        public final String PAGER_DUTY_EVENT_API_NAME = 'Pharos_ai_PagerDutyEvent_API_URL';
        public final String PAGER_DUTY_EVENT_DESCRIPTION = 'Pharos.ai - PagerDutyEvent integration API login URL';
        public final String PAGER_DUTY_EVENT_URL = 'https://events.pagerduty.com';

        public final String OPEN_AI_NAME = 'Pharos_ai_OpenAI_URL';
        public final String OPEN_AI_DESCRIPTION = 'Pharos.ai - OpenAI integration API login URL';
        public final String OPEN_AI_URL = 'https://api.openai.com';

        public final String AI_NAME = 'Pharos_ai_AI';
        public final String AI_DESCRIPTION = 'Pharos.ai - AI integration API login URL';
        public final String AI_URL = 'https://ai.pharos.ai';

        public final String JIRA_NAME = 'Pharos_ai_Jira_API_URL';
        public final String JIRA_DESCRIPTION = 'Pharos.ai - Jira integration API login URL';

        public final String SPLUNK_WEB_NAME = 'Pharos_ai_SplunkWeb_URL';
        public final String SPLUNK_WEB_DESCRIPTION = 'Pharos.ai - SplunkWeb integration API login URL';
        public final String SPLUNK_API_NAME = 'Pharos_ai_Splunk_API_URL';
        public final String SPLUNK_API_DESCRIPTION = 'Pharos.ai - Splunk integration API login URL';
        public final String SPLUNK_API_PORT = ':8089';
        public final String SPLUNK_EVENT_COLLECTOR_NAME = 'Pharos_ai_SplunkEventCollector_API_URL';
        public final String SPLUNK_EVENT_COLLECTOR_DESCRIPTION = 'Pharos.ai - SplunkEventCollector integration API login URL';
        public final String SPLUNK_EVENT_COLLECTOR_PORT = ':8088';

        public final String JIRA_CLOUD_API_NAME = 'Pharos_ai_JIRA_CLOUD_API_URL';
        public final String JIRA_CLOUD_API_DESCRIPTION = 'Pharos.ai - Jira integration API login URL';
        public final String JIRA_CLOUD_API_URL = 'https://api.atlassian.com';
        public final String JIRA_CLOUD_OAUTH_NAME = 'Pharos_ai_JIRA_CLOUD_OAUTH_URL';
        public final String JIRA_CLOUD_OAUTH_DESCRIPTION = 'Pharos.ai - Jira integration OAuth URL';
    }

    public inherited sharing class StaticResourceSObject extends SObjectTypeConstants {
        public final String RESOURCE_NAME_APEX_UTIL = 'ApexUtilSource';
        public final String RESOURCE_NAME_APEX_UTIL_TEST = 'ApexUtilTestSource';
        public final String RESOURCE_NAME_METADATA_CONNECTED_APP_PAYLOAD = 'ConnectedAppMetadataPayload';
        public final String RESOURCE_NAME_METADATA_REMOTE_SITE_PAYLOAD = 'RemoteSiteSettingsPayload';

        private StaticResourceSObject() {
            this.objectType = StaticResource.SObjectType;
        }
    }

    public inherited sharing class TraceResultSObject extends SObjectTypeConstants {
        private TraceResultSObject() {
            this.objectType = Trace_Result__c.SObjectType;
        }
    }

    public inherited sharing class UI {
        public final String RESULT_SUCCESS = 'success';

        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG0 = 'flag0';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG1 = 'flag1';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG2 = 'flag2';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG3 = 'flag3';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG4 = 'flag4';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG5 = 'flag5';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG6 = 'flag6';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG7 = 'flag7';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_FLAG8 = 'flag8';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS = 'progress';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_PASSTHROUGHT_MODE_ENABLED = 'passthroughtModeEnabled';
        public final String CONFIGURATION_OVERVIEW_DATA_KEY_INTEGRATION_PROGRESS = 'integrationProgress';

        public final Map<String, Object> CONFIGURATION_OVERVIEW_DATA = new Map<String, Object>{
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG0 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG1 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG2 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG3 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG4 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG5 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG6 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG7 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_FLAG8 => false,
            CONFIGURATION_OVERVIEW_DATA_KEY_PROGRESS => 0
        };
    }
    
    public inherited sharing virtual class SObjectTypeConstants {
        private SObjectType objectType;

        public final SObjectType SOBJECT_TYPE {
            get { return this.objectType; }
        }

        public final String SOBJECT_TYPE_NAME {
            get { return this.objectType.getDescribe().getName(); }
        }
    }
}