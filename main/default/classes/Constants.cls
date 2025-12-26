@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class Constants {
    
    public static final GlobalVariable GLOBAL_VARIABLE { 
        get { return GLOBAL_VARIABLE == null ? (GLOBAL_VARIABLE = new GlobalVariable()) : GLOBAL_VARIABLE; }
        private set;
    }

    public static final ActionSobject ACTION_SOBJECT {
        get { return ACTION_SOBJECT == null ? (ACTION_SOBJECT = new ActionSobject()) : ACTION_SOBJECT; }
        private set;
    }

    public static final AIEventSObject AI_EVENT_SOBJECT { 
        get { return AI_EVENT_SOBJECT == null ? (AI_EVENT_SOBJECT = new AIEventSObject()) : AI_EVENT_SOBJECT; }
        private set;
    }

    public static final EventSObject EVENT_SOBJECT { 
        get { return EVENT_SOBJECT == null ? (EVENT_SOBJECT = new EventSObject()) : EVENT_SOBJECT; }
        private set;
    }

    public static final Flow FLOW { 
        get { return FLOW == null ? (FLOW = new Flow()) : FLOW; }
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

    public static final RuleSObject RULE_SOBJECT {
        get { return RULE_SOBJECT == null ? (RULE_SOBJECT = new RuleSObject()) : RULE_SOBJECT; }
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

    public static final TraceScheduleSObject TRACE_SCHEDULE_SOBJECT { 
        get { return TRACE_SCHEDULE_SOBJECT == null ? (TRACE_SCHEDULE_SOBJECT = new TraceScheduleSObject()) : TRACE_SCHEDULE_SOBJECT; }
        private set;
    }

    public static final UI UI { 
        get { return UI == null ? (UI = new UI()) : UI; }
        private set;
    }

    public static final UserSObject USER_SOBJECT { 
        get { return USER_SOBJECT == null ? (USER_SOBJECT = new UserSObject()) : USER_SOBJECT; }
        private set;
    }

    public inherited sharing class GlobalVariable {
        public final String BASE_URL = System.Url.getOrgDomainUrl().toExternalForm();
        public final String NEWLINE_CHARACTERS = '\r\n';
        public final Integer TEXT_FIELD_MAX_LENGTH = 255;

        public final String SYMBOL_AT = '@';
        public final String SYMBOL_UNDERSCORE = '_';
        public final String SYMBOL_DOT = '.';
        public final String SYMBOL_COLON = ':';
        public final String SYMBOL_SLASH = '/';
        public final String SYMBOL_DASH = '-';
        
        // URL Protocol Constants
        public final String URL_PROTOCOL_SEPARATOR = '://';
        public final String URL_PROTOCOL_HTTPS = 'https://';
        public final String URL_PROTOCOL_HTTP = 'http://';

        public final String SALESFORCE_DOMAIN = 'my.salesforce.com';
        public final String CUSTOM_DOMAIN_SYMBOLS = '--';

        public final Pattern PATTERN_SOBJECT_ID = Pattern.compile('([a-zA-Z0-9]{15,18})');
        public final Pattern PATTERN_MERGE_FIELD = Pattern.compile('\\{![^}]+\\}');
        public final Pattern PATTERN_MERGE_FIELD_QUOTED = Pattern.compile('"\\{![^}]+\\}"');
        public final Pattern PATTERN_NON_ALPHANUMERIC = Pattern.compile('[^a-zA-Z0-9]');
        public final Pattern PATTERN_NON_NUMERIC = Pattern.compile('[^0-9]');

        public final String DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';

        public final String NOTIFICATION_INTEGRATION_STATUS_PENDING = 'Pending';
        public final String NOTIFICATION_INTEGRATION_STATUS_FAILED = 'Failed';
        public final String NOTIFICATION_INTEGRATION_STATUS_COMPLETED = 'Completed';

        public final String JIRA_INTEGRATION_STATUS_PENDING = 'Ticket Pending';

        public final String CHARTS_NOT_AVAILABLE_MESSAGE = '*Note: Charts are not available due to missing data.*';

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

    public inherited sharing class ActionSObject extends SObjectTypeConstants {
        public final String RT_MONITORING = 'Monitoring';
        public final String RT_ARCHIVAL = 'Archival';

        public final String SUBTYPE_DEFAULT = 'Default';
        public final String SUBTYPE_NOTIFICATION = 'Notification';

        public final String ACTION_TYPE_TEAMS_NOTIFICATION = 'Teams Notification';
        public final String ACTION_TYPE_EMAIL_NOTIFICATION = 'Email Notification';
        public final String ACTION_TYPE_SLACK_NOTIFICATION = 'Slack Notification';
        public final String ACTION_TYPE_JIRA_NOTIFICATION = 'Jira Notification';
        public final String ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION = 'Azure Dev Ops Notification';
        public final String ACTION_TYPE_PAGERDUTY_NOTIFICATION = 'PagerDuty Notification';
        public final String ACTION_TYPE_REMOVAL = 'Removal';
        public final String ACTION_TYPE_LOCAL_ARCHIVAL = 'Local Archival';
        public final String ACTION_TYPE_EXTERNAL_ARCHIVAL = 'External Archival';
        public final String ACTION_TYPE_JIRA_TICKET_COMMENT = 'JIRA Ticket Comment';
        public final String ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT = 'Azure Dev Ops Work Item Comment';
        public final String ACTION_TYPE_WEBHOOK_NOTIFICATION = 'Webhook Notification';
        
        private ActionSObject() {
            this.objectType = Action__c.SObjectType;
        }
    }

    public inherited sharing class AIEventSObject extends SObjectTypeConstants {
        public final String TRIGGER_NAME_AI_EVENT = 'AiEventTrigger';

        private AIEventSObject() {
            this.objectType = AI_Event__e.SObjectType;
        }
    }

    public inherited sharing class EventSObject extends SObjectTypeConstants {
        public final String RT_MONITORING = 'Monitoring';
        public final String RT_ARCHIVAL = 'Archival';

        private EventSObject() {
            this.objectType = Event__c.SObjectType;
        }
    }

    public inherited sharing class Flow {
        public final String HTML_TAG_HORIZONTAL_RULE_OPEN = '<hr>';
        public final String HTML_TAG_BREAK_OPEN = '<br>';
        public final String HTML_TAG_PARAGRAPH_OPEN = '<p>';
        public final String HTML_TAG_PARAGRAPH_CLOSE = '</p>';
        public final String HTML_TAG_BACKSLASH = '\n';

        public final String FLOW_TYPE_ORCHESTRATOR = 'Flow Orchestration';
        public final String FLOW_TYPE_AUTOLAUNCHED_FLOW = 'Autolaunched Flow';
        public final String FLOW_ERROR_MESSAGE_PART_OCCURRED = 'occurred: ';
        public final String FLOW_ERROR_MESSAGE_SEPARATOR = '---';

        public final String FLOW_ERROR_DETAILS_PART_HTML = '<span style="font-weight:bold;">Flow Details</span><br>';
        public final String FLOW_ERROR_FLOW_ERROR_DETAILS_PART_HTML = '<hr>\n'+
        '<br><span style="font-size:x-large;font-weight:bold">Flow Error Details</span><br><br>\n'+
        '<p>\n'+
        '<span style="font-weight:bold;">Flow Details</span><br>';
        public final String FLOW_ERROR_HEAD_PART_OCCURED_ERROR_MESSAGE = 'FLOW_ERROR_HEAD_PART_OCCURED_ERROR_MESSAGE';
        public final String FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_NAME = 'FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_NAME';
        public final String FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_TYPE = 'FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_TYPE';
        public final String FLOW_ERROR_HEAD_PART_FLOW_NAME = 'FLOW_ERROR_HEAD_PART_FLOW_NAME';

        public final String FLOW_ERROR_START_ERROR_OCCURED = '<span style="font-size:x-large;font-weight:bold">An Error Occurred with' + 'Your "'+FLOW_ERROR_HEAD_PART_FLOW_NAME+'" Flow</span><br><br>\n'+
        '<span>You\'ve received this email because an error occurred while your "'+FLOW_ERROR_HEAD_PART_FLOW_NAME+'" flow was running. <a ';

        public final String FLOW_ERROR_DEBUG_FLOW_BUILDER_PART = 'Debug this flow in Flow Builder.</a><br><p>';
        public final String FLOW_ERROR_ELEMENT_HEAD_PART = 'Debug this flow in Flow Builder.</a><br></span><br>\n' +
        '<span>Error element '+FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_NAME+' ('+FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_TYPE+').</span><br>\n'+
        '<span>'+FLOW_ERROR_HEAD_PART_OCCURED_ERROR_MESSAGE+'</span><br>';

        public final Pattern PATTERN_FLOW_ORGANIZATION_ID = Pattern.compile('Org: ([\\s\\S]+?)[\\n|\\r\\n|\\r]');
        public final Pattern PATTERN_FLOW_GUID = Pattern.compile('Interview GUID: ([\\s\\S]+?)[\\n|\\r\\n|\\r]');

        // Flow parser
        public final String FLOW_CURRENT_SUPPORTED_API_VERSION = '63.0';
        public final String FLOW_CONDITION_EMPTY = '';
        public final String FLOW_CONDITION_EMPTY_LABEL = 'None—Get All Contact Records';
        public final String FLOW_CONDITION_PAUSE_LABEL = 'Always Pause Flow—No Conditions';
        public final String FLOW_CONDITION_OR = 'OR';
        public final String FLOW_CONDITION_FORMULA = 'Formula';
        public final String FLOW_CONDITION_OR_LABEL = 'Any Condition Is Met (OR)';
        public final String FLOW_CONDITION_AND = 'AND';
        public final String FLOW_CONDITION_AND_LABEL = 'All Conditions Are Met (AND)';
        public final String FLOW_CONDITION_CUSTOM_LABEL = 'Custom Condition Logic Is Met';
        public final String FLOW_CONDITION_FORMULA_LABEL = 'Formula Evaluets to True';

        public final String FLOW_ELEMENT_COLLECTION_PROCESSOR = 'FlowCollectionProcessor';
        public final String FLOW_ELEMENT_SORT_COLLECTION_PROCESSOR = 'SortCollectionProcessor';
        public final String FLOW_ELEMENT_FILTER_COLLECTION_PROCESSOR = 'FilterCollectionProcessor';
        public final String FLOW_ELEMENT_ICON_SORT_COLLECTION_PROCESSOR = 'sort_collection';
        public final String FLOW_ELEMENT_ICON_FILTER_COLLECTION_PROCESSOR = 'filter_collection';
        public final String FLOW_ELEMENT_ICON_ROLL_BACK_RECORDS = 'roll_back_records';
        public final String FLOW_ELEMENT_ICON_DECISION = 'decision';
        public final String FLOW_ELEMENT_ICON_RECORD_DELETE = 'record_delete';
        public final String FLOW_ELEMENT_ICON_RECORD_UPDATE = 'record_update';
        public final String FLOW_ELEMENT_ICON_RECORD_LOOKUP = 'record_lookup';
        public final String FLOW_ELEMENT_ICON_RECORD_CREATE = 'record_create';
        public final String FLOW_ELEMENT_ICON_TRANSFORM = 'transform';
        public final String FLOW_ELEMENT_ICON_WAIT = 'wait';
        public final String FLOW_ELEMENT_ICON_ORCHESTRATED_STAGE = 'orchestrated_stage';
        public final String FLOW_ELEMENT_ICON_CUSTOM_ERROR = 'custom_error';
        public final String FLOW_ELEMENT_ICON_SUB_FLOW = 'sub_flow';
        public final String FLOW_ELEMENT_ICON_ACTION = 'action';
        public final String FLOW_ELEMENT_ICON_ACTION_SEARCH = 'search_bold';
        public final String FLOW_ELEMENT_ICON_ACTION_APEX = 'apex';
        public final String FLOW_ELEMENT_ICON_ASSIGNMENT = 'assignment';
        public final String FLOW_ELEMENT_ICON_SCREEN = 'screen';
        public final String FLOW_ELEMENT_ICON_LOOP = 'loop';

        public final Map<String, String> OPERATORS_MAP = new Map<String, String>{
            'EqualTo' => 'Equals',
            'NotEqualTo' => 'Does not equal',
            'StartsWith' => 'Starts with',
            'EndsWith' => 'Ends With',
            'Contains' => 'Contains',
            'IsNull' => 'Is null',
            'GreaterThan' => 'Greater than',
            'GreaterThanOrEqualTo' => 'Greater than or equal',
            'LessThan' => 'Less than',
            'LessThanOrEqualTo' => 'Less than or equal'
        };

        public final Map<String, String> FILTER_TYPE_MAP = new Map<String, String>{
            'String' => 'String',
            'Reference' => 'Field Reference',
            'GlobalConstant' => 'Global Constant',
            'Formula' => 'Formula',
            'Picklist' => 'Picklist',
            'DateTime' => 'Date/Time',
            'Date' => 'Date',
            'Currency' => 'Currency',
            'Number' => 'Number',
            'ID' => 'ID',
            'User' => 'User',
            'Boolean' => 'Boolean',
            'Queue' => 'Queue'
        };
        
        /**
         * <xsd:simpleType name="FlowRecordFilterOperator">
            <xsd:restriction base="xsd:string">
            <xsd:enumeration value="EqualTo"/>
            <xsd:enumeration value="NotEqualTo"/>
            <xsd:enumeration value="GreaterThan"/>
            <xsd:enumeration value="LessThan"/>
            <xsd:enumeration value="GreaterThanOrEqualTo"/>
            <xsd:enumeration value="LessThanOrEqualTo"/>
            <xsd:enumeration value="StartsWith"/>
            <xsd:enumeration value="EndsWith"/>
            <xsd:enumeration value="Contains"/>
            <xsd:enumeration value="IsNull"/>
            <xsd:enumeration value="IsChanged"/>
            <xsd:enumeration value="In"/>
            <xsd:enumeration value="NotIn"/>
            </xsd:restriction>
            </xsd:simpleType>
        */
        public final Map<String, String> FLOW_RECORD_FILTER_OPERATOR_MAPPING = new Map<String, String>{
            'EqualTo' => 'Equals',
            'NotEqualTo' => 'Does Not Equal',
            'GreaterThan' => 'Greater Than',
            'LessThan' => 'Less Than',
            'GreaterThanOrEqualTo' => 'Greater Than or Equal',
            'LessThanOrEqualTo' => 'Less Than or Equal',
            'StartsWith' => 'Starts With',
            'EndsWith' => 'Ends With',
            'Contains' => 'Contains',
            'IsNull' => 'Is Null',
            'IsChanged' => 'Is Changed',
            'In' => 'In',
            'NotIn' => 'Not In'
        };
        
        /**
         * <xsd:simpleType name="FlowComparisonOperator">
            <xsd:restriction base="xsd:string">
            <xsd:enumeration value="None"/>
            <xsd:enumeration value="EqualTo"/>
            <xsd:enumeration value="NotEqualTo"/>
            <xsd:enumeration value="GreaterThan"/>
            <xsd:enumeration value="LessThan"/>
            <xsd:enumeration value="GreaterThanOrEqualTo"/>
            <xsd:enumeration value="LessThanOrEqualTo"/>
            <xsd:enumeration value="StartsWith"/>
            <xsd:enumeration value="EndsWith"/>
            <xsd:enumeration value="Contains"/>
            <xsd:enumeration value="IsNull"/>
            <xsd:enumeration value="IsChanged"/>
            <xsd:enumeration value="WasSet"/>
            <xsd:enumeration value="WasSelected"/>
            <xsd:enumeration value="WasVisited"/>
            <xsd:enumeration value="In"/>
            <xsd:enumeration value="NotIn"/>
            <xsd:enumeration value="IsBlank"/>
            <xsd:enumeration value="IsEmpty"/>
            </xsd:restriction>
            </xsd:simpleType>
        */
        public final Map<String, String> FLOW_COMPRASION_OPERATOR_MAPPING = new Map<String, String>{
            'None' => '',
            'EqualTo' => 'Equals',
            'NotEqualTo' => 'Does Not Equal',
            'GreaterThan' => 'Greater Than',
            'LessThan' => 'Less Than',
            'GreaterThanOrEqualTo' => 'Greater Than or Equal',
            'LessThanOrEqualTo' => 'Less Than or Equal',
            'StartsWith' => 'Starts With',
            'EndsWith' => 'Ends With',
            'Contains' => 'Contains',
            'IsNull' => 'Is Null',
            'IsChanged' => 'Is Changed',
            'WasSet' => 'Was Set',
            'WasSelected' => 'Was Selected',
            'WasVisited' => 'Was Visited',
            'In' => 'In',
            'NotIn' => 'Not In',
            'IsBlank' => 'Is Blank',
            'IsEmpty' => 'Is Empty'
        };

        /**
         * <xsd:simpleType name="FlowAssignmentOperator">
            <xsd:restriction base="xsd:string">
            <xsd:enumeration value="None"/>
            <xsd:enumeration value="Assign"/>
            <xsd:enumeration value="Add"/>
            <xsd:enumeration value="Subtract"/>
            <xsd:enumeration value="AddItem"/>
            <xsd:enumeration value="RemoveFirst"/>
            <xsd:enumeration value="RemoveBeforeFirst"/>
            <xsd:enumeration value="RemoveAfterFirst"/>
            <xsd:enumeration value="RemoveAll"/>
            <xsd:enumeration value="AddAtStart"/>
            <xsd:enumeration value="RemoveUncommon"/>
            <xsd:enumeration value="AssignCount"/>
            <xsd:enumeration value="RemovePosition"/>
            </xsd:restriction>
            </xsd:simpleType>
        */
        public final Map<String, String> FLOW_ASSIGNNMENT_OPERATOR_MAPPING = new Map<String, String>{
            'None' => '',
            'Assign' => 'Equals',
            'Add' => 'Add',
            'Subtract' => 'Subtract',
            'AddItem' => 'Add Item',
            'RemoveFirst' => 'Remove First',
            'RemoveBeforeFirst' => 'Remove Before First',
            'RemoveAfterFirst' => 'Remove After First',
            'RemoveAll' => 'Remove All',
            'AddAtStart' => 'Add At Start',
            'RemoveUncommon' => 'Remove Uncommon',
            'AssignCount' => 'Equals Count',
            'RemovePosition' => 'Remove Position'
        };

        public final String PB_CURRENT_SUPPORTED_API_VERSION = '54.0';

        public final String PB_ACTION_TYPE_FLOW_RECORD_UPDATE = 'FlowRecordUpdate';
        public final String PB_ACTION_TYPE_FLOW_RECORD_CREATE = 'FlowRecordCreate';
        public final String PB_ACTION_TYPE_FLOW_ACTION_CALL = 'FlowActionCall';
        public final String PB_ACTION_TYPE_SCHEDULED_ACTION_START = 'FlowWait';

        public final String PB_ICON_RECORD_UPDATE = 'update_record';
        public final String PB_ICON_RECORD_CREATE = 'create_record';
        public final String PB_ICON_APEX = 'apex';
        public final String PB_ICON_EMAIL_ALERT = 'send_email';
        public final String PB_ICON_CHATTER = 'chatter';
        public final String PB_ICON_QUICK_ACTION = 'quick_actions';
        public final String PB_ICON_CUSTOM_NOTIFICATION = 'custom_notification';
        public final String PB_ICON_FLOW = 'launch_flow';
        public final String PB_ICON_SUBMIT_FOR_APPROVAL = 'submit_approval';
        public final String PB_ICON_SCHEDULED_ACTION = 'clock';

        public final String PB_KEY_OBJECT_TYPE = 'ObjectType';
        public final String PB_KEY_OBJECT_VARIABLE = 'ObjectVariable';
        public final String PB_KEY_OLD_OBJECT_VARIABLE = 'OldObjectVariable';
        public final String PB_KEY_TRIGGER_TYPE = 'TriggerType';
        public final String PB_KEY_EVENT_TYPE = 'EventType';

        public final String PK_KEY_TRIGGER_TYPE_INSERT = 'onCreateOnly';
        public final String PK_KEY_TRIGGER_TYPE_UPDATE = 'onAllChanges';

        public final String PB_LABEL_PLATFORM_EVENT = 'Platform Event';
        public final String PB_LABEL_OBJECT = 'Object';
        public final String PB_LABEL_MATCHING_CONDITIONS = 'Matching Conditions';
        public final String PB_LABEL_START_THE_PROCESS = 'Start the process';
        public final String PB_LABEL_TRIGGER_TYPE_INSERT = 'only when a record is created';
        public final String PB_LABEL_TRIGGER_TYPE_UPDATE = 'when a record is created or edited';
        public final String PB_LABEL_RECURSION_RPOCESS = 'Recursion - Allow process to evaluate a record multiple times in a single save operation?';
        public final String PB_LABEL_YES = 'Yes';
        public final String PB_LABEL_SKIP_ENTRY_CRITERIA = 'Skip the entry criteria for this process?';
        public final String PB_LABEL_APPROVAL_PROCESS = 'Approval Process';
        public final String PB_LABEL_DEFAULT_APPROVAL_PROCESS = 'Default approval process';
        public final String PB_LABEL_SPECIFIC_APPROVAL_PROCESS = 'Specific approval process';
        public final String PB_LABEL_SET_NEW_FIELD_VALUES = 'Set new field values for the records you update';
        public final String PB_LABEL_CRITERIA_UPDATING = 'Criteria for Updating Records';
        public final String PB_LABEL_CRITERIA_UPDATING_ALL_CONDITIONS = 'Updated records meet all conditions';
        public final String PB_LABEL_CRITERIA_UPDATING_NO_CONDITIONS = 'No criteria—just update the records!';
        public final String PB_LABEL_FILTER_RECORDS = 'Filter the records you update based on these conditions';
        public final String PB_LABEL_RECORD = 'Record';
        public final String PB_LABEL_ACTION_NAME = 'Action Name';
        public final String PB_LABEL_DAYS = 'Days';
        public final String PB_LABEL_TIME_FROM_NOW = 'From now';
        public final String PB_LABEL_SET_TIME_FOR_ACTIONS = 'Set Time for Actions to Execute';
        public final String PB_LABEL_TIME_BEFORE = 'Before';
        public final String PB_LABEL_TIME_AFTER = 'After';
        public final String PB_LABEL_SUBMISSION_COMMENTS = 'Submission Comments';
        public final String PB_LABEL_SUBMITTER = 'Submitter';
        public final String PB_LABEL_ACTION_FLOW = 'Flow';
        public final String PB_LABEL_RECORD_TYPE = 'Record Type';
        public final String PB_LABEL_SET_FIELD_VALUES = 'Set Field Values';
        public final String PB_LABEL_GLOBAL_CONSTANT_NULL = '$GlobalConstant.Null';
        public final String PB_LABEL_GLOBAL_CONSTANT_EMPTY_STRING = '$GlobalConstant.EmptyString';
        public final String PB_LABEL_SOBJECT = 'SObject';
        public final String PB_LABEL_SET_APEX_VARIABLES = 'Set Apex Variables';
        public final String PB_LABEL_APEX_CLASS = 'Apex Class';
        public final String PB_LABEL_EMAIL_ALERT = 'Email Alert';
        public final String PB_LABEL_MESSAGE = 'Message';
        public final String PB_LABEL_POST_TO = 'Post to';
        public final String PB_LABEL_POST_TO_CHATTER_GROUP = 'Chatter Group';
        public final String PB_LABEL_POST_TO_CHATTER_USER = 'User';
        public final String PB_LABEL_POST_TO_THIS_RECORD = 'This Record';
        public final String PB_LABEL_SEARCH_USER = 'Search for a user';
        public final String PB_LABEL_SELECT_USER = 'Select a user from a record';
        public final String PB_LABEL_SET_QA_FIELD_VALUES = 'Set Quick Action Field Values';
        public final String PB_LABEL_QA_FILTER_TYPE = 'Type';
        public final String PB_LABEL_QA_FILTER_GLOBAL = 'Global';
        public final String PB_LABEL_QA_FILTER_OBJECT = 'Object';
        public final String PB_LABEL_QA_FILTER_CREATE = 'Create a Record';
        public final String PB_LABEL_QA_FILTER_UPDATE = 'Update a Record';
        public final String PB_LABEL_QA_FILTER_LOG_A_CALL = 'Log a Call';
        public final String PB_LABEL_NOTIFICATION_TITLE = 'Notification Title';
        public final String PB_LABEL_NOTIFICATION_BODY = 'Notification Body';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_USER = 'User';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_OWNER = 'Owner';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_GROUP = 'Group';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE = 'Queue';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_USER_CURRENT_USER = 'Current User';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_USER_FIND_USER = 'Find User';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_USER_REFERENCE = 'User Field from a Record';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE_RECORD = 'Find Queue';
        public final String PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE_REFERENCE = 'Queue Field from a Record';
        public final String PB_LABEL_NOTIFICATION_TYPE = 'Notification Type';
        public final String PB_LABEL_SET_CONDITIONS = 'Set Conditions';
        public final String PB_LABEL_BUILD_FORMULA = 'Build Formula';
        public final String PB_LABEL_ALL_CONDITIONS_MET = 'All of the conditions are met (AND)';
        public final String PB_LABEL_ANY_CONDITIONS_MET = 'Any of the conditions are met (OR)';
        public final String PB_LABEL_CRITERIA_EXECUTING_ACTIONS = 'Criteria for Executing Actions';
        public final String PB_LABEL_CUSTOMIZE_LOGIC = 'Customize the logic';

        public final String PB_TABLE_LABEL_FIELD = 'Field';
        public final String PB_TABLE_LABEL_SOURCE = 'Source';
        public final String PB_TABLE_LABEL_OPERATOR = 'Operator';
        public final String PB_TABLE_LABEL_TYPE = 'Type';
        public final String PB_TABLE_LABEL_VALUE = 'Value';
        public final String PB_TABLE_LABEL_POST_TO = 'Post to';
        public final String PB_TABLE_LABEL_GROUP = 'Group';
        public final String PB_TABLE_LABEL_USER = 'User';
        public final String PB_TABLE_LABEL_FILTER_SEARCH_BY = 'Filter Search By';
        public final String PB_TABLE_LABEL_ACTION = 'Action';
        public final String PB_TABLE_LABEL_NOTIFICATION_RECIPIENT = 'Notification Recipient';
        public final String PB_TABLE_LABEL_QUEUE = 'Queue';
        public final String PB_LABEL_CRITERIA_NAME = 'Criteria Name';
        public final String PB_LABEL_CONDITIONS_MET = 'Conditions are met';
        public final String PB_LABEL_FORMULA_EVALUATE = 'Formula evaluates to true';
        public final String PB_LABEL_NO_CRITERIES = 'No criteria—just execute the actions!';

        public final String PB_META_KEY_LEFT_HAND_SIDE_LABEL = 'leftHandSideLabel';
        public final String PB_META_KEY_LEFT_HAND_SIDE_TYPE = 'leftHandSideType';
        public final String PB_META_KEY_RIGHT_HAND_SIDE_TYPE = 'rightHandSideType';
        public final String PB_META_KEY_RIGHT_HAND_SIDE_LABEL = 'rightHandSideLabel';
        public final String PB_META_KEY_RECURSIVE_COUNT_VARIABLE = 'RecursiveCountVariable';
        public final String PB_META_KEY_IMPLICIT = 'implicit';
        public final String PB_META_KEY_REFERENCE = 'reference';
        public final String PB_META_KEY_APEX_SELECTION = 'apexSelection';
        public final String PB_META_KEY_EMAIL_ALERT_SELECTION = 'emailAlertSelection';
        public final String PB_META_KEY_TEXT_JSON = 'textJson';
        public final String PB_META_KEY_MESSAGE = 'message';
        public final String PB_META_KEY_SUBJECT_NAME_OR_ID = 'subjectNameOrId';
        public final String PB_META_KEY_TYPE = 'type';
        public final String PB_META_KEY_FILTER_TYPE = 'filterType';
        public final String PB_META_KEY_QA_TYPE = 'quickActionType';
        public final String PB_META_KEY_RECIPIENT_IDS = 'recipientIds';
        public final String PB_META_KEY_RECIPIENT_SELECTION = 'recipientSelection';
        public final String PB_META_KEY_RECIPIENT_TYPE = 'recipientType';
        public final String PB_META_KEY_RECIPIENT_CATEGORY = 'recipientCategory';
        public final String PB_META_KEY_TITLE = 'title';
        public final String PB_META_KEY_BODY = 'body';
        public final String PB_META_KEY_CUSTOM_NOTIFICATION_TYPE = 'customNotifTypeName';
        public final String PB_META_KEY_FLOW_SELECTION = 'flowSelection';
        public final String PB_META_KEY_COMMENT = 'comment';
        public final String PB_META_KEY_SUBMITTER_TYPE = 'submitterType';
        public final String PB_META_KEY_SKIP_ENTRY_CRITERIA = 'skipEntryCriteria';
        public final String PB_META_KEY_PROCESS_SELECTION = 'processSelection';
        public final String PB_META_KEY_SELECTION_TYPE = 'selectionType';
        public final String PB_META_KEY_TIME_FIELD_ENUM_OR_ID = 'TimeFieldColumnEnumOrId';
        public final String PB_META_KEY_TIME_OFFSET ='TimeOffset';
        public final String PB_META_KEY_TIME_OFFSET_UNIT ='TimeOffsetUnit';
        public final String PB_META_KEY_VALUE_AND = 'and';
        public final String PB_META_KEY_VALUE_OR = 'or';
        public final String PB_META_KEY_VALUE_FORMULA = 'Formula';
        public final String PB_META_KEY_INDEX = 'index';

        public final String PB_META_KEY_VALUE_USER = 'USER';
        public final String PB_META_KEY_VALUE_GROUP = 'GROUP';
        public final String PB_META_KEY_VALUE_USER_ID_PREFIX = '005';
        public final String PB_META_KEY_VALUE_GROUP_ID_PREFIX = '0F9';
        public final String PB_META_KEY_VALUE_FORMULA_PREFIX = 'formula_';
        public final String PB_META_KEY_VALUE_FIRST_DECISION_INDEX = '0.0';

        public final String PB_ST_ERROR_OCCURED = 'Error Occurred:';
        public final String PB_ST_TRANSACTION_ROLLED_BACK = 'Transaction Rolled Back';
        public final String PB_ST_TRANSACTION_ERROR_HANDLED = 'Error Handled';
        public final String PB_ST_ORCHESTRATOR_ENTER_STAGE = 'ENTER STAGE:';
        public final String PB_ST_SALESFORCE_ERROR_ID ='Salesforce Error ID:';
        public final String PB_ST_HOW_START = 'How the Interview Started';
        public final String PB_ST_FLOW_INTERVIEW_DETAILS = 'Flow Interview Details';
        public final String PB_ST_FLOW_VAR_INTERVIEW_LABEL = 'Interview Label';
        public final String PB_ST_FLOW_VAR_INTERVIEW_GUID = 'Interview GUID';
        public final String PB_ST_FLOW_DETAILS = 'Flow Details';
        public final String PB_ST_FLOW_DETAILS_WITHOUT_HEADER_ERROR = 'Debug this flow in Flow Builder. Flow Details';
        public final String PB_ST_FLOW_ERROR_DETAILS = 'Flow Error Details';
        public final String PB_ST_FLOW_ERROR_ELEMENT = 'Error element';
        public final String PB_ST_VAR_FLOW_API_NAME_LABEL = 'Flow API Name';
        public final String PB_ST_VAR_FLOW_API_NAME_NAME = 'FlowAPIName';
        public final String PB_ST_VAR_TYPE_LABEL = 'Type';
        public final String PB_ST_VAR_TYPE_NAME = 'Type';
        public final String PB_ST_VAR_STATUS_LABEL = 'Status';
        public final String PB_ST_VAR_STATUS_NAME = 'Status';
        public final String PB_ST_VAR_ORG_LABEL = 'Org';
        public final String PB_ST_VAR_ORG_NAME = 'Org';
        public final String PB_ST_VAR_VERSION_LABEL = 'Version';
        public final String PB_ST_VAR_VERSION_NAME = 'Version';
        public final String PB_ST_VAR_CURRENT_USER_LABEL = 'Current User';
        public final String PB_ST_VAR_CURRENT_USER_NAME = 'CurrentUser';
        public final String PB_ST_VAR_DURATION_LABEL = 'Duration';
        public final String PB_ST_VAR_START_TIME_LABEL = 'Start time';
        public final String PB_ST_VAR_START_TIME_NAME = 'StartTime';
        public final String PB_ST_VAR_RUN_API_LABEL = 'API Version for Running the Flow';
        public final String PB_ST_VAR_RUN_API_NAME = 'APIVersionforRunningtheFlow';
        public final String PB_ST_VAR_RECORD = '$Record';
        public final String PB_ST_VAR_RECORD_ID = 'recordId';
        public final String PB_ST_VAR_SCHEDULED_PATH = 'Scheduled Path';
        public final String PB_ST_ELEMENT_RESULT = 'Result';
        public final String PB_ST_DEFAULT_OUTCOME = 'Default outcome executed';
        public final String PB_ST_DEFAULT_OUTCOME_EXECUTED = 'default path was executed';
        public final String PB_ST_OUTCOME = 'Outcome executed';
        public final String PB_ST_VAR_OUTCOME = 'Outcome';
        public final String PB_ST_VAR_DEFAULT_OUTCOME = 'Default Outcome';
        public final String PB_ST_ELEMENT_LOOP = 'LOOP';
        public final String PB_ST_ELEMENT_LOOP_END = 'End Loop.';
        public final String PB_ST_ELEMENT_LOOP_OUTCOME_FOR_EACH = 'For Each Item';
        public final String PB_ST_ELEMENT_LOOP_OUTCOME_LAST = 'After Last Item';
        public final String PB_ST_ELEMENT_FAULT_PATH_EXECUTED = 'FaultPathExecuted';
        public final String PB_ST_START_ELEMENT = 'start';
        public final String PB_ST_VAR_FAULT = 'Fault';
        public final String PB_ST_ENTER_FLOW = 'Enter flow';
        public final String PB_ST_EXIT_FLOW = 'Exit flow';
        public final String PB_ST_PAUSE_CONFIGURATION = 'Pause Configuration:';
        public final String PB_ST_CONTEXT_ENTER_FLOW = 'enterFlow';
        public final String PB_ST_CONTEXT_FLOW_API_NAME = 'flowApiName';
        public final String PB_ST_CONTEXT_FLOW_API_VERSION = 'apiVersion';
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
        public final String ASYNC_APEX_JOB_PROCESS_STATUS_COMPLETED = 'Completed';

        public final String ASYNC_APEX_JOB_PROCESS_TYPE_SCHEDULED_APEX = 'ScheduledApex';
        public final String ASYNC_APEX_JOB_PROCESS_TYPE_BATCH_APEX_WORKER = 'BatchApexWorker';
        public final String ASYNC_APEX_JOB_PROCESS_TYPE_BATCH_APEX = 'BatchApex';
    
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
        public final String OPERATION;
        public final String ORIGINATED_FROM;

        private LogSObject() {
            this.objectType = Log__c.SObjectType;
            this.CREATED_AT = Schema.SObjectType.Log__c.fields.Created_At__c.getName();
            this.CATEGORY = Schema.SObjectType.Log__c.fields.Category__c.getName();
            this.AREA = Schema.SObjectType.Log__c.fields.Area__c.getName();
            this.LIMITS = Schema.SObjectType.Log__c.fields.Limits__c.getName();
            this.OPERATION = Schema.SObjectType.Log__c.fields.Apex_Name__c.getName();
            this.ORIGINATED_FROM = Schema.SObjectType.Log__c.fields.Originated_From__c.getName();
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

    public inherited sharing class RuleSObject extends SObjectTypeConstants {
        public final String SUB_TYPE_FREQUENCY = 'Frequency';
        public final String SUB_TYPE_IMPACT = 'Impact';
        public final String SUB_TYPE_SPIKE = 'Spike';
        public final String SUB_TYPE_THRESHOLD = 'Threshold';

        public final String TYPE_MONITORING = 'Monitoring';
        public final String TYPE_ARCHIVAL = 'Archival';
        public final String TYPE_JIRA_UPDATE = 'JIRA Update';
        public final String TYPE_AZURE_DEV_OPS = 'Azure Dev Ops';
        public final String TYPE_NOTIFICATION = 'Notification';
        public final String TYPE_EVENT_MONITORING = 'Event Monitoring';
        public final String TYPE_BROADCAST = 'Broadcast';
        public final String TYPE_LIMITS = 'Limits';

        private RuleSObject() {
            this.objectType = Rule__c.SObjectType;
        }
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

    public inherited sharing class TraceScheduleSObject extends SObjectTypeConstants {
        public final String STATUS_IN_PROGRESS = 'In Progress';
        public final String STATUS_COMPLETED = 'Completed';
        public final String STATUS_INACTIVE = 'Inactive';
        
        private TraceScheduleSObject() {
            this.objectType = Trace_Schedule__c.SObjectType;
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

    public inherited sharing class UserSObject extends SObjectTypeConstants {
        private UserSObject() {
            this.objectType = User.SObjectType;
        }
    }
    
    // Monitoring Configuration Constants
    public static final Monitoring MONITORING {
        get { return MONITORING == null ? (MONITORING = new Monitoring()) : MONITORING; }
        private set;
    }
    
    public inherited sharing class Monitoring {
        // Query window buffer (minutes) for capturing limits snapshots
        // Production data shows HourlyLimitsBatch runs with ~60 min gap ±15 seconds variance
        // This buffer ensures we capture all snapshots even with timing delays
        public Integer QUERY_WINDOW_BUFFER_MINUTES = 2;
        
        // Spike detection window buffer (minutes) for filtering logs
        // Handles second-level variance in production (e.g., 60.22 min gaps)
        // Ensures logs at -60min 13sec are included in -60min spike detection window
        public Integer SPIKE_DETECTION_BUFFER_MINUTES = 1;
    }
    
    // SOQL Query Limits Configuration
    public static final QueryLimits QUERY_LIMITS {
        get { return QUERY_LIMITS == null ? (QUERY_LIMITS = new QueryLimits()) : QUERY_LIMITS; }
        private set;
    }
    
    public inherited sharing class QueryLimits {
        // Standard limit for singleton queries (Organization, etc.)
        public final Integer SINGLETON_QUERY_LIMIT = 1;
        
        // Standard limit for small reference data (UserLicense, TenantUsageEntitlement, etc.)
        public final Integer SMALL_DATA_QUERY_LIMIT = 1000;
        
        // Standard limit for large queries (ApexClass, ApexTrigger, Events, Rules, Actions)
        public final Integer LARGE_DATA_QUERY_LIMIT = 10000;

        // Used for safe check for aggregate result query
        public final Integer MAX_COUNT_FOR_SAFE_AGGREGATE_RESULT_QUERY = 49000;

        // Used for all rules query limit
        public final Integer MAX_RULES_RECORDS_QUERY_LIMIT = 255;
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