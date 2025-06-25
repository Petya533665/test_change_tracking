public with sharing class EventMonitoringUtil {
    private static final Integer MAX_RECORDS = 1;
    
    private static final String INTERVAL_HOURLY = 'Hourly';
    private static final String INTERVAL_DAILY = 'Daily';
    
    public EventMonitoringUtil() {}

    @TestVisible
    public static List<SObject> testEventLogs = new List<SObject>();

    public static final String EVENT_LOG_FILE_ID = 'Id';
    public static final String EVENT_LOG_FILE_EVENT_TYPE = 'EventType';
    public static final String EVENT_LOG_FILE_LOG_DATE = 'LogDate';
    public static final String EVENT_LOG_FILE_LOG_FILE_LENGTH = 'LogFileLength';
    public static final String EVENT_LOG_FILE_LOG_FILE = 'LogFile';
    public static final String EVENT_LOG_FILE_CREATED_DATE = 'CreatedDate';
    public static final String EVENT_LOG_FILE_INTERVAL = 'Interval';
    public static final String EVENT_LOG_FILE_LOG_FILE_FIELD_NAMES = 'LogFileFieldNames';
    public static final String EVENT_LOG_FILE_LOG_FILE_FIELD_TYPES = 'LogFileFieldTypes';
    public static final String EVENT_LOG_FILE_SEQUENCE = 'Sequence';

    public static List<SObject> getEventLogs(String eventType) {
        // Handle null parameters or unavailable object
        if (eventType == null || 
            ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c == null ||
            !isEventLogFileAvailable()) {
            return new List<SObject>();
        }
        
        // Handle test context
        if (Test.isRunningTest() && testEventLogs != null && !testEventLogs.isEmpty()) {
            return testEventLogs;
        }
        
        // Last Processed Hourly DateTime
        Datetime lastProcessedHourlyDateTime = ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c;
        
        // Build dynamic query using QBuilder
        Set<String> selectFields = new Set<String>{
            EVENT_LOG_FILE_ID, EVENT_LOG_FILE_EVENT_TYPE, EVENT_LOG_FILE_LOG_DATE, EVENT_LOG_FILE_LOG_FILE_LENGTH, EVENT_LOG_FILE_LOG_FILE,
            EVENT_LOG_FILE_CREATED_DATE, EVENT_LOG_FILE_INTERVAL, EVENT_LOG_FILE_LOG_FILE_FIELD_NAMES, EVENT_LOG_FILE_LOG_FILE_FIELD_TYPES
        };
        
        // Add Sequence field if available
        if (isSequenceFieldAvailable()) {
            selectFields.add(EVENT_LOG_FILE_SEQUENCE);
        }
        
        QBuilder queryBuilder = new QBuilder(getEventLogFileType())
            .selectFields(selectFields)
            .add(QBuilder.condition(EVENT_LOG_FILE_EVENT_TYPE).equalsTo(eventType))
            .add(QBuilder.condition(EVENT_LOG_FILE_LOG_DATE).isGreaterOrEquals(String.valueOf(lastProcessedHourlyDateTime)))
            .add(QBuilder.condition(EVENT_LOG_FILE_INTERVAL).equalsTo(INTERVAL_HOURLY))
            .add(QBuilder.orderBy(EVENT_LOG_FILE_LOG_DATE).descending())
            .addLimit(MAX_RECORDS);
        
        // Add Sequence ordering if field is available
        if (isSequenceFieldAvailable()) {
            queryBuilder.add(QBuilder.orderBy(EVENT_LOG_FILE_SEQUENCE).ascending());
        }
        
        try {
            return Database.query(queryBuilder.build());
        } catch (Exception e) {
            // Log error and return empty list
            Logger.getInstance().add(Logger.getInstance().getInternalError(
                e, null, EventMonitoringUtil.class.getName(), 'Error querying EventLogFile'
            ));
            return new List<SObject>();
        }
    }

    /**
     * Legacy method for backward compatibility - deprecated
     * @deprecated Use getEventLogs(String eventType) instead which returns List<SObject>
     * Note: This method uses dynamic casting to avoid EventLogFile reference issues in orgs without the object
     */
    public static List<SObject> getEventLogsLegacy(String eventType) {
        return getEventLogs(eventType);
    }

    /**
     * Check if EventLogFile object is available in the org
     * @return Boolean
     */
    public static Boolean isEventLogFileAvailable() {
        if (eventLogFileAvailable == null) {
            try {
                Type eventLogFileObjectType = Type.forName(EVENT_LOG_FILE_OBJECT_NAME);
                if (eventLogFileObjectType != null) {
                    SObject instance = (SObject)eventLogFileObjectType.newInstance();
                    eventLogFileType = instance.getSObjectType();
                    eventLogFileAvailable = true;
                } else {
                    eventLogFileAvailable = false;
                }
            } catch (Exception e) {
                eventLogFileAvailable = false;
            }
        }
        return eventLogFileAvailable;
    }
    
    /**
     * Check if Sequence field is available on EventLogFile
     * @return Boolean
     */
    public static Boolean isSequenceFieldAvailable() {
        if (sequenceFieldAvailable == null) {
            if (!isEventLogFileAvailable()) {
                sequenceFieldAvailable = false;
            } else {
                try {
                    Map<String, Schema.SObjectField> fieldMap = eventLogFileType.getDescribe().fields.getMap();
                    sequenceFieldAvailable = fieldMap.containsKey(EVENT_LOG_FILE_SEQUENCE);
                } catch (Exception e) {
                    sequenceFieldAvailable = false;
                }
            }
        }
        return sequenceFieldAvailable;
    }
    
    /**
     * Get EventLogFile SObjectType if available
     * @return SObjectType
     */
    public static SObjectType getEventLogFileType() {
        if (isEventLogFileAvailable()) {
            return eventLogFileType;
        }
        return null;
    }
    
    /**
     * Create test Map that mimics EventLogFile structure for testing
     * @param eventType String
     * @param logDate Date
     * @param logFileContent Blob
     * @return Map<String, Object>
     */
    @TestVisible
    public static Map<String, Object> createTestEventLogData(String eventType, Date logDate, Blob logFileContent) {
        return new Map<String, Object>{
            EVENT_LOG_FILE_EVENT_TYPE => eventType,
            EVENT_LOG_FILE_LOG_DATE => logDate,
            EVENT_LOG_FILE_LOG_FILE => logFileContent != null ? logFileContent.toString() : '', // Store as String for JSON serialization
            EVENT_LOG_FILE_LOG_FILE_LENGTH => logFileContent != null ? logFileContent.size() : 0,
            EVENT_LOG_FILE_LOG_FILE_FIELD_NAMES => null, // Will use test field names from processors
            EVENT_LOG_FILE_LOG_FILE_FIELD_TYPES => null, // Will use test field types from processors
            EVENT_LOG_FILE_ID => '001000000MockELF', // Mock ID for testing
            EVENT_LOG_FILE_CREATED_DATE => Datetime.now(),
            EVENT_LOG_FILE_INTERVAL => 'Hourly'
        };
    }

    /**
     * Compatibility wrapper for createTestEventLogSObject - creates SObject with mock data
     * @param eventType String
     * @param logDate Date
     * @param logFileContent Blob
     * @return SObject
     */
    @TestVisible
    public static SObject createTestEventLogSObject(String eventType, Date logDate, Blob logFileContent) {
        Map<String, Object> testData = createTestEventLogData(eventType, logDate, logFileContent);
        Account mockAccount = new Account(Name = 'Mock EventLog: ' + eventType);
        mockAccount.Description = JSON.serialize(testData);
        return (SObject)mockAccount;
    }


    
    /**
     * Get field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return Object
     */
    public static Object getFieldValue(SObject record, String fieldName) {
        
        // Check if this is a mock EventLogFile (has mock data in Description field)
        if (record != null && Test.isRunningTest()) {
            String description = (String)record.get('Description');
            if (String.isNotBlank(description) && description.startsWith('{')) {
                Map<String, Object> mockFieldValues = (Map<String, Object>)JSON.deserializeUntyped(description);
                if (mockFieldValues.containsKey(fieldName)) {
                    return mockFieldValues.get(fieldName);
                }
            }
        }
        
        return record?.get(fieldName);
    }
    
    /**
     * Get string field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return String
     */
    public static String getStringValue(SObject record, String fieldName) {
        Object value = getFieldValue(record, fieldName);
        return value != null ? String.valueOf(value) : null;
    }
    
    /**
     * Get datetime field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return Datetime
     */
    public static Datetime getDatetimeValue(SObject record, String fieldName) {
        Object value = getFieldValue(record, fieldName);
        return value != null ? (Datetime)value : null;
    }
    
    /**
     * Get blob field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return Blob
     */
    public static Blob getBlobValue(SObject record, String fieldName) {
        
        Object value = getFieldValue(record, fieldName);
        if (value == null) return null;
        
        // Handle Blob value directly
        if (value instanceof Blob) return (Blob)value;
        
        // Handle String value from mock EventLogFile data only (convert to Blob)
        if (Test.isRunningTest() && value instanceof String && fieldName == EVENT_LOG_FILE_LOG_FILE) {
            String stringValue = (String)value;
            // Convert LogFile String content to Blob for mock data
            if (String.isNotBlank(stringValue)) {
                return Blob.valueOf(stringValue);
            }
        }
        
        return null;
    }
    
    /**
     * Get integer field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return Integer
     */
    public static Integer getIntegerValue(SObject record, String fieldName) {
        
        Object value = getFieldValue(record, fieldName);
        if (value == null) return null;
        if (value instanceof Integer) return (Integer)value;
        if (value instanceof Decimal) return ((Decimal)value).intValue();
        if (value instanceof String) return Integer.valueOf((String)value);
        return null;
    }

    // Constants for Rule and RuleFilter fields
    public static final String EVENT_MONITORING_TYPE = 'Event Monitoring';
    private static final String RULE_ACTIVE = 'Active__c';
    private static final String RULE_TYPE = 'Type__c';            // stores "EventMonitoring" constant
    private static final String RULE_SUBTYPE = 'Subtype__c';      // stores event type
    
    private static final String FILTER_FIELD = 'FieldName__c';    // stores metric
    private static final String FILTER_OPERATOR = 'ComparisonOperator__c';  // stores evaluationType
    private static final String FILTER_VALUE = 'Value__c';        // stores threshold values
    private static final String FILTER_INDEX = 'Index__c';        // 1 for critical, 2 for warning
    
    public static final Decimal CRITICAL_INDEX = 1;
    public static final Decimal WARNING_INDEX = 2;

    // EventLogFile safe access constants and variables
    private static final String EVENT_LOG_FILE_OBJECT_NAME = 'EventLogFile';
    
    // Cache for object availability check
    private static Boolean eventLogFileAvailable = null;
    private static Boolean sequenceFieldAvailable = null;
    private static SObjectType eventLogFileType = null;

    public static final Map<String, Map<String, ThresholdConfig>> MAP_DEFAULT_THRESHOLDS = new Map<String, Map<String, ThresholdConfig>>{
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => new Map<String, ThresholdConfig>{
            'EXCEPTION_MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION)
                .setMetric('EXCEPTION_MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setCriticalThreshold(null)
                .build()
        }
    };

    /**
     * Loads threshold configurations from Rule__c and RuleFilter__c records
     * @return Map<String, Map<String, ThresholdConfig>> - Event type to metric thresholds mapping
     */
    public static Map<String, Map<String, ThresholdConfig>> loadThresholdsFromRules() {
        Map<String, Map<String, ThresholdConfig>> thresholds = new Map<String, Map<String, ThresholdConfig>>();
        
        // Query active rules with their filters
        List<Rule__c> rules = [
            SELECT Id, Name, Type__c, Subtype__c,
                   (SELECT FieldName__c, ComparisonOperator__c, Value__c, Index__c 
                    FROM RuleFilters__r 
                    ORDER BY Index__c ASC)
            FROM Rule__c 
            WHERE Type__c = :EVENT_MONITORING_TYPE
                AND Active__c = true
        ];
        
        for (Rule__c rule : rules) {
            if (rule.RuleFilters__r.isEmpty()) continue;
            
            // Group filters by metric (FieldName__c)
            Map<String, List<RuleFilter__c>> metricFilters = new Map<String, List<RuleFilter__c>>();
            for (RuleFilter__c filter : rule.RuleFilters__r) {
                if (!metricFilters.containsKey(filter.FieldName__c)) {
                    metricFilters.put(filter.FieldName__c, new List<RuleFilter__c>());
                }
                metricFilters.get(filter.FieldName__c).add(filter);
            }
            
            // Create threshold configs for each metric
            for (String metric : metricFilters.keySet()) {
                ThresholdConfig config = createThresholdFromFilters(
                    rule.Subtype__c, 
                    metric, 
                    metricFilters.get(metric)
                );
                
                if (!thresholds.containsKey(rule.Subtype__c)) {
                    thresholds.put(rule.Subtype__c, new Map<String, ThresholdConfig>());
                }
                thresholds.get(rule.Subtype__c).put(metric, config);
            }
        }

        // add default thresholds if they are not already in the thresholds map
        if (!MAP_DEFAULT_THRESHOLDS.isEmpty()) {
            for (String eventType : MAP_DEFAULT_THRESHOLDS.keySet()) {
                if (!thresholds.containsKey(eventType)) {
                    thresholds.put(eventType, MAP_DEFAULT_THRESHOLDS.get(eventType));
                }
            }
        }
        
        return thresholds;
    }

    /**
     * Creates a ThresholdConfig from RuleFilter__c records
     */
    private static ThresholdConfig createThresholdFromFilters(
        String eventType, 
        String metric, 
        List<RuleFilter__c> filters
    ) {
        ThresholdConfig.Builder builder = new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(metric);
        
        // Set evaluation type from first filter (should be same for all filters of the metric)
        if (!filters.isEmpty()) {
            builder.setEvalType(getEvaluationType(filters[0].ComparisonOperator__c));
        }
        
        // Set thresholds based on filter index
        for (RuleFilter__c filter : filters) {
            if (filter.Index__c == CRITICAL_INDEX) {
                builder.setCriticalThreshold(filter.Value__c);
            } else if (filter.Index__c == WARNING_INDEX) {
                builder.setWarningThreshold(filter.Value__c);
            }
        }
        
        return builder.build();
    }

    /**
     * Saves a ThresholdConfig as Rule__c and RuleFilter__c records
     */
    public static Rule__c saveThresholdAsRule(ThresholdConfig config) {
        // Create or update Rule
        Rule__c rule = new Rule__c(
            Name__c = config.eventType + ' Threshold Rule',
            Description__c = 'Threshold rule for ' + config.eventType,
            Type__c = EVENT_MONITORING_TYPE,
            Subtype__c = config.eventType,
            Active__c = true
        );
        
        insert rule;
        
        // Create RuleFilter records for thresholds
        List<RuleFilter__c> filters = new List<RuleFilter__c>();
        
        // Critical threshold filter
        if (config.criticalThreshold != null) {
            filters.add(new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = config.metric,
                ComparisonOperator__c = config.evaluationType.name(),
                Value__c = String.valueOf(config.criticalThreshold),
                Index__c = CRITICAL_INDEX
            ));
        }
        
        // Warning threshold filter
        if (config.warningThreshold != null) {
            filters.add(new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = config.metric,
                ComparisonOperator__c = config.evaluationType.name(),
                Value__c = String.valueOf(config.warningThreshold),
                Index__c = WARNING_INDEX
            ));
        }

        if (config.criticalThreshold == null 
            && config.warningThreshold == null 
            && config.evaluationType == ThresholdConfig.EvaluationType.NOT_NULL) {
            // add a filter for the metric with a value of ''
            filters.add(new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = config.metric,
                ComparisonOperator__c = config.evaluationType.name(),
                Value__c = '',
                Index__c = CRITICAL_INDEX
            ));
        }
        
        if (!filters.isEmpty()) {
            insert filters;
        }
        
        return rule;
    }

    /**
     * Converts string evaluation type to ThresholdConfig.EvaluationType
     */
    private static ThresholdConfig.EvaluationType getEvaluationType(String evalTypeStr) {
        return ThresholdConfig.EvaluationType.valueOf(evalTypeStr);
    }


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

    public static Map<String, List<EventLogProcessors.FilterField>> getEventMonitoringFields() {
        Map<String, List<EventLogProcessors.FilterField>> result = new Map<String, List<EventLogProcessors.FilterField>>();

        if (ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c) {
            List<Boolean> enabledEventTypes = getEnabledMembersFromSettings();
            // get the enabled event types index from the MAP_ENABLED_EVENT_TYPES
            // if the index is in the enabledEventTypes, add the event type to the result
            for (String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
                Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
                if (enabledEventTypes[index]) {
                    try {
                        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(eventType);
                        result.put(eventType, processor.getFilterFields());
                    }
                    catch (Exception e) {}
                }
            }
		}
        return result;
    }

    /**
     * Get the enabled event types from the settings
     * used in the EventLogProcessingBatch
     * @return List<EventLogProcessingBatch.EventLogFileType>
     */
    public static List<EventLogProcessingBatch.EventLogFileType> getEnabledMembers() {
        List<EventLogProcessingBatch.EventLogFileType> result = new List<EventLogProcessingBatch.EventLogFileType>();
        if (ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c) {
            List<Boolean> enabledEventTypes = getEnabledMembersFromSettings();
            // get the enabled event types index from the MAP_ENABLED_EVENT_TYPES
            // if the index is in the enabledEventTypes, add the event type to the result
            for (String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
                Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
                if (enabledEventTypes[index]) {
                    result.add(new EventLogProcessingBatch.EventLogFileType(eventType));
                }
            }
		}
        return result;
    }

    /**
     * Get the enabled event types from the settings
     * value is a comma separated list of '1' and '0'
     * '1' is enabled, empty or null is disabled
     * @return List<Boolean>
     */
    public static List<Boolean> getEnabledMembersFromSettings() {
        List<Boolean> result = new List<Boolean>();
        if (ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c) {
            String enabledEventTypes = ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c;
            List<String> enabledEventTypesList = String.isNotBlank(enabledEventTypes)
                ? new List<String>(enabledEventTypes.split(','))
                : new List<String>();
            for(Integer i = 0; i < MAP_ENABLED_EVENT_TYPES.size(); i++) {
                try {
                    result.add(Boolean.valueOf(enabledEventTypesList[i] == '1'));
                }
                catch (Exception e) {
                    result.add(false);
                }
            }
            for (String eventType : DEFAULT_ENABLED_EVENT_TYPES) {
                Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
                if (index != null) {
                    result[index] = true;
                }
            }
        }
        return result;
    }

    public Boolean isEnabled(String eventType) {
        List<Boolean> enabledMembersFromSettings = getEnabledMembersFromSettings();
        Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
        if (index != null) {
            return enabledMembersFromSettings[index];
        }
        return false;
    }

    public void enableEventType(String eventTypeToEnable) {
        List<Boolean> enabledMembersFromSettings = getEnabledMembersFromSettings();
        Integer index = MAP_ENABLED_EVENT_TYPES.get(eventTypeToEnable);
        if (index != null) {
            enabledMembersFromSettings[index] = true;
        }
        List<String> enabledTypes = new List<String>();
        for (Integer i = 0; i < enabledMembersFromSettings.size(); i++) {
            if (enabledMembersFromSettings[i]) {
                enabledTypes.add('1');
            } else {
                enabledTypes.add('0');
            }
        }
        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = String.join(enabledTypes, ',');
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
    }

    /**
     * Default enabled event types
     * @return Set<String>
     */
    public static Set<String> DEFAULT_ENABLED_EVENT_TYPES = new Set<String>{
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION
    };

    /**
     * Map of event types to their indexes used in the settings
     * @return Map<String, Integer>
     */
    public static Map<String, Integer> MAP_ENABLED_EVENT_TYPES {
        get {
            if (MAP_ENABLED_EVENT_TYPES == null) {
                MAP_ENABLED_EVENT_TYPES = new Map<String, Integer>{
                    EventLogProcessors.EVENT_TYPE_API =>                                0,
                    EventLogProcessors.EVENT_TYPE_APEX_CALLOUT =>                       1,
                    EventLogProcessors.EVENT_TYPE_APEX_EXECUTION =>                     2,
                    EventLogProcessors.EVENT_TYPE_APEX_REST_API =>                      3,
                    EventLogProcessors.EVENT_TYPE_APEX_SOAP =>                          4,
                    EventLogProcessors.EVENT_TYPE_APEX_TRIGGER =>                       5,
                    EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION =>          6, // enabled by default
                    EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE =>                    7,
                    EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN =>            8,
                    EventLogProcessors.EVENT_TYPE_AURA_REQUEST =>                       9,
                    EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT =>                   10,
                    EventLogProcessors.EVENT_TYPE_BULK_API =>                           11,
                    EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST =>                   12,
                    EventLogProcessors.EVENT_TYPE_BULK_API_2 =>                         13,
                    EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION =>               14,
                    EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => 15,
                    EventLogProcessors.EVENT_TYPE_CONSOLE =>                            16,
                    EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION =>               17,
                    EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK =>              18,
                    EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER =>                   19,
                    EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY =>       20,
                    EventLogProcessors.EVENT_TYPE_CORS_VIOLATION =>                     21,
                    EventLogProcessors.EVENT_TYPE_CSP_VIOLATION =>                      22,
                    EventLogProcessors.EVENT_TYPE_DASHBOARD =>                          23,
                    EventLogProcessors.EVENT_TYPE_DATABASE_SAVE =>                      24,
                    EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS =>      25,
                    EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT =>       26,
                    EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT =>         27,
                    EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT =>       28,
                    EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT =>             29,
                    EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION =>                     30,
                    EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP =>                   31,
                    EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS =>                 32,
                    EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS =>           33,
                    EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS =>                34,
                    EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW =>             35,
                    EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR =>                    36,
                    EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION =>              37,
                    EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER =>                   38,
                    EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW =>                39,
                    EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE =>              40,
                    EventLogProcessors.EVENT_TYPE_LOGIN =>                              41,
                    EventLogProcessors.EVENT_TYPE_LOGIN_AS =>                           42,
                    EventLogProcessors.EVENT_TYPE_LOGOUT =>                             43,
                    EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION =>             44,
                    EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT =>                  45,
                    EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL =>                   46,
                    EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE =>                 47,
                    EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL =>                    48,
                    EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE =>                  49,
                    EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION =>                50,
                    EventLogProcessors.EVENT_TYPE_PRICING =>                            51,
                    EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION =>                   52,
                    EventLogProcessors.EVENT_TYPE_REPORT =>                             53,
                    EventLogProcessors.EVENT_TYPE_REPORT_EXPORT =>                      54,
                    EventLogProcessors.EVENT_TYPE_REST_API =>                           55,
                    EventLogProcessors.EVENT_TYPE_SANDBOX =>                            56,
                    EventLogProcessors.EVENT_TYPE_SEARCH =>                             57,
                    EventLogProcessors.EVENT_TYPE_SEARCH_CLICK =>                       58,
                    EventLogProcessors.EVENT_TYPE_SITES =>                              59,
                    EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW =>                60,
                    EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY =>               61,
                    EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING =>     62,
                    EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING =>       63,
                    EventLogProcessors.EVENT_TYPE_URI =>                                64,
                    EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST =>                65,
                    EventLogProcessors.EVENT_TYPE_WAVE_CHANGE =>                        66,
                    EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD =>                      67,
                    EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION =>                   68,
                    EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE =>                   69
                };
            }
            return MAP_ENABLED_EVENT_TYPES;
        }
        private set;
    }

    public static void saveLastProcessedHourlyDateTime(Datetime lastProcessedHourlyDateTime) {
        // increment the last processed hourly datetime
        lastProcessedHourlyDateTime = lastProcessedHourlyDateTime.addHours(1);
        // save the last processed hourly datetime
        ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c = lastProcessedHourlyDateTime;
        update ConfigUtil.EVENT_MONITORING_SETTINGS;
    }
}