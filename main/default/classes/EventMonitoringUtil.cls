public with sharing class EventMonitoringUtil {
    private static final Integer MAX_RECORDS = 100; // Allow multiple CSV files per hour
    
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
        return getEventLogs(new List<String>{eventType});
    }
    
    public static List<SObject> getEventLogs(List<String> eventTypes) {
        // Handle null parameters or unavailable object
        if (eventTypes == null || eventTypes.isEmpty() || 
            ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c == null ||
            !isEventLogFileAvailable()) {
            return new List<SObject>();
        }
        
        // Handle test context
        if (Test.isRunningTest() && testEventLogs != null && !testEventLogs.isEmpty()) {
            return testEventLogs;
        }
        
        // Last Processed Hourly DateTime
        // DateTime retrieved from database is already in GMT/UTC timezone
        DateTime lastProcessedHourlyDateTimeGMT = ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c;
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
            .add(QBuilder.condition(EVENT_LOG_FILE_EVENT_TYPE).isIn(eventTypes))
            .add(QBuilder.condition(EVENT_LOG_FILE_LOG_DATE).isGreaterOrEquals(lastProcessedHourlyDateTimeGMT))
            .add(QBuilder.condition(EVENT_LOG_FILE_LOG_DATE).isLessThan(lastProcessedHourlyDateTimeGMT.addHours(1)))
            .add(QBuilder.condition(EVENT_LOG_FILE_INTERVAL).equalsTo(INTERVAL_HOURLY))
            .add(QBuilder.orderBy(EVENT_LOG_FILE_LOG_DATE).descending())
            .addLimit(MAX_RECORDS);
        
        // Add Sequence ordering if field is available - prioritize sequence over log date for same hour
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

    /**
     * Get double field value from SObject safely
     * @param record SObject
     * @param fieldName String
     * @return Double
     */
    public static Double getDoubleValue(SObject record, String fieldName) {
        
        Object value = getFieldValue(record, fieldName);
        if (value == null) return null;
        if (value instanceof Double) return (Double)value;
        if (value instanceof Decimal) return ((Decimal)value).doubleValue();
        if (value instanceof Integer) return Double.valueOf((Integer)value);
        if (value instanceof String) return Double.valueOf((String)value);
        return null;
    }

    // Constants for Rule and RuleFilter fields
    public static final String EVENT_MONITORING_TYPE = 'Event Monitoring';
    public static final Decimal FILTER_INDEX = 1;

    // EventLogFile safe access constants and variables
    private static final String EVENT_LOG_FILE_OBJECT_NAME = 'EventLogFile';
    
    // Cache for object availability check
    private static Boolean eventLogFileAvailable = null;
    private static Boolean sequenceFieldAvailable = null;
    private static SObjectType eventLogFileType = null;

    public static final Integer DEFAULT_LOGS_LIMIT_PER_HOUR = 100;
    public static final Integer DEFAULT_LOGS_LIMIT_PER_HOUR_UNLIMITED = null; // no limit

    public static final Map<String, Integer> MAP_DEFAULT_LOGS_LIMIT_PER_HOUR = new Map<String, Integer>{
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => DEFAULT_LOGS_LIMIT_PER_HOUR_UNLIMITED,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_API => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_REST_API => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_LOGIN => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => DEFAULT_LOGS_LIMIT_PER_HOUR,
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => DEFAULT_LOGS_LIMIT_PER_HOUR
    };

    public static final Map<String, Map<String, ThresholdConfig>> MAP_DEFAULT_THRESHOLDS = new Map<String, Map<String, ThresholdConfig>>{
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => new Map<String, ThresholdConfig>{
            'EXCEPTION_MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION)
                .setMetric('EXCEPTION_MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => new Map<String, ThresholdConfig>{
            'MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR)
                .setMetric('MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => new Map<String, ThresholdConfig>{
            'ERROR_DESCRIPTION' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS)
                .setMetric('ERROR_DESCRIPTION')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_API => new Map<String, ThresholdConfig>{
            'EXCEPTION_MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_API)
                .setMetric('EXCEPTION_MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => new Map<String, ThresholdConfig>{
            'EXCEPTION_MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
                .setMetric('EXCEPTION_MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_REST_API => new Map<String, ThresholdConfig>{
            'EXCEPTION_MESSAGE' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_REST_API)
                .setMetric('EXCEPTION_MESSAGE')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold(null)
                .build()
        },
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => new Map<String, ThresholdConfig>{
            'SUCCESS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT)
                .setMetric('SUCCESS')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold('1')
                .build()
        },
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => new Map<String, ThresholdConfig>{
            'REQUEST_STATUS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER)
                .setMetric('REQUEST_STATUS')
                .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
                .setThreshold(new List<String>{'F', 'A', 'N', 'U', 'R'})
                .build()
        },
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => new Map<String, ThresholdConfig>{
            'REQUEST_STATUS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_SOAP)
                .setMetric('REQUEST_STATUS')
                .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
                .setThreshold(new List<String>{'F', 'A', 'N', 'U', 'R'})
                .build()
        },
        EventLogProcessors.EVENT_TYPE_LOGIN => new Map<String, ThresholdConfig>{
            'LOGIN_STATUS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_LOGIN)
                .setMetric('LOGIN_STATUS')
                .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
                .setThreshold('LOGIN_NO_ERROR')
                .build()
        },
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => new Map<String, ThresholdConfig>{
            'REQUEST_STATUS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST)
                .setMetric('REQUEST_STATUS')
                .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
                .setThreshold(new List<String>{'F', 'A', 'N', 'U', 'R'})
                .build()
        },
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => new Map<String, ThresholdConfig>{
            'REQUEST_STATUS' => new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_AURA_REQUEST)
                .setMetric('REQUEST_STATUS')
                .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
                .setThreshold(new List<String>{'F', 'A', 'N', 'U', 'R'})
                .build()
        }
    };

    public static List<Rule__c> getActiveEventMonitoringRules() {
        // Query active rules with their filters
        List<Rule__c> rules = [
            SELECT Id, Name, Type__c, Subtype__c, Logs_Limit__c,
                   (SELECT FieldName__c, ComparisonOperator__c, Value__c, Index__c
                    FROM RuleFilters__r 
                    ORDER BY Index__c ASC)
            FROM Rule__c 
            WHERE Type__c = :EVENT_MONITORING_TYPE
                AND Active__c = true
        ];
        return rules;
    }

    public static Map<String, Integer> getLogsLimitPerHour(List<Rule__c> rules) {
        Map<String, Integer> logsLimitPerHour = new Map<String, Integer>();
        for (Rule__c rule : rules) {
            Integer logsLimit = rule.Logs_Limit__c != null ? Integer.valueOf(rule.Logs_Limit__c) : getDefaultLogsLimitForEventType(rule.Subtype__c);
            logsLimitPerHour.put(rule.Subtype__c, logsLimit);
        }
        return logsLimitPerHour;
    }

    /**
     * Get default logs limit for specific event type
     * @param eventType String
     * @return Integer
     */
    public static Integer getDefaultLogsLimitForEventType(String eventType) {
        if (MAP_DEFAULT_LOGS_LIMIT_PER_HOUR.containsKey(eventType)) {
            return MAP_DEFAULT_LOGS_LIMIT_PER_HOUR.get(eventType);
        }
        return DEFAULT_LOGS_LIMIT_PER_HOUR;
    }

    /**
     * Loads threshold configurations from Rule__c and RuleFilter__c records
     * @return Map<String, Map<String, ThresholdConfig>> - Event type to metric thresholds mapping
     */
    public static Map<String, Map<String, ThresholdConfig>> loadThresholdsFromRules(List<Rule__c> rules) {
        Map<String, Map<String, ThresholdConfig>> thresholds = new Map<String, Map<String, ThresholdConfig>>();
        
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
        ThresholdConfig.EvaluationType evalType = getEvaluationType(filters[0].ComparisonOperator__c);
        for (RuleFilter__c filter : filters) {
            Object thresholdValue = deserializeThresholdValue(filter.Value__c, evalType);
            if (filter.Index__c == FILTER_INDEX) {
                builder.setThreshold(thresholdValue);
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
        
        filters.add(new RuleFilter__c(
            Rule__c = rule.Id,
            FieldName__c = config.metric,
            ComparisonOperator__c = config.evaluationType.name(),
            Value__c = (config.threshold != null) ? String.valueOf(config.threshold) : '',
            Index__c = FILTER_INDEX
        ));
        
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

    /**
     * Serializes threshold values for storage in RuleFilter__c.Value__c
     * Handles special cases like IS_IN which requires JSON serialization of lists
     */
    private static String serializeThresholdValue(Object thresholdValue, ThresholdConfig.EvaluationType evaluationType) {
        if (thresholdValue == null) {
            return null;
        }
        
        // For IS_IN evaluation type, serialize List as JSON
        if (evaluationType == ThresholdConfig.EvaluationType.IS_IN && thresholdValue instanceof List<Object>) {
            return JSON.serialize(thresholdValue);
        }
        
        // For all other types, use standard string conversion
        return String.valueOf(thresholdValue);
    }

    /**
     * Deserializes threshold values from RuleFilter__c.Value__c
     * Handles special cases like IS_IN which requires JSON deserialization to lists
     */
    private static Object deserializeThresholdValue(String serializedValue, ThresholdConfig.EvaluationType evaluationType) {
        if (String.isBlank(serializedValue)) {
            return null;
        }
        
        // For IS_IN evaluation type, deserialize JSON to List
        if (evaluationType == ThresholdConfig.EvaluationType.IS_IN) {
            try {
                return (List<Object>) JSON.deserializeUntyped(serializedValue);
            } catch (Exception e) {
                // Fallback to string value if JSON deserialization fails
                return serializedValue;
            }
        }
        
        // For all other types, return as string
        return serializedValue;
    }

    /**
     * Get default threshold configurations for specific event type
     * @param eventType String
     * @return Map<String, ThresholdConfig>
     */
    private static Map<String, ThresholdConfig> getDefaultThresholdsForEventType(String eventType) {
        if (MAP_DEFAULT_THRESHOLDS.containsKey(eventType)) {
            return MAP_DEFAULT_THRESHOLDS.get(eventType);
        }
        return new Map<String, ThresholdConfig>();
    }

    /**
     * Creates Rule__c with default threshold configurations for an event type
     * @param eventType String
     * @return List<Rule__c> - List of created rules (could be empty if no defaults exist)
     */
    public static List<Rule__c> createDefaultRulesForEventType(String eventType) {
        return createDefaultRulesForEventTypes(new List<String>{eventType});
    }

    /**
     * Bulkified method to create Rule__c with default threshold configurations for multiple event types
     * @param eventTypes List<String>
     * @return List<Rule__c> - List of created rules
     */
    public static List<Rule__c> createDefaultRulesForEventTypes(List<String> eventTypes) {
        Map<String, Integer> eventTypeLogsLimits = new Map<String, Integer>();
        for (String eventType : eventTypes) {
            eventTypeLogsLimits.put(eventType, getDefaultLogsLimitForEventType(eventType));
        }
        return createDefaultRulesForEventTypes(eventTypeLogsLimits);
    }

    /**
     * Bulkified method to create Rule__c with threshold configurations for multiple event types with custom logs limits
     * @param eventTypeLogsLimits Map<String, Integer> - Map of event type to logs limit
     * @return List<Rule__c> - List of created rules
     */
    public static List<Rule__c> createDefaultRulesForEventTypes(Map<String, Integer> eventTypeLogsLimits) {
        List<Rule__c> createdRules = new List<Rule__c>();
        List<RuleFilter__c> allFilters = new List<RuleFilter__c>();
        
        // First, create all Rule__c records
        List<Rule__c> rulesToInsert = new List<Rule__c>();
        Map<String, Map<String, ThresholdConfig>> eventTypeThresholds = new Map<String, Map<String, ThresholdConfig>>();
        
        for (String eventType : eventTypeLogsLimits.keySet()) {
            Map<String, ThresholdConfig> defaultThresholds = getDefaultThresholdsForEventType(eventType);
            
            if (!defaultThresholds.isEmpty()) {
                eventTypeThresholds.put(eventType, defaultThresholds);
                
                Rule__c rule = new Rule__c(
                    Name__c = eventType + ' Event Monitoring Rule',
                    Description__c = 'Default threshold rule for ' + eventType + ' event monitoring',
                    Type__c = EVENT_MONITORING_TYPE,
                    Subtype__c = eventType,
                    Active__c = true,
                    Logs_Limit__c = eventTypeLogsLimits.get(eventType)
                );
                rulesToInsert.add(rule);
            }
        }
        
        // Bulk insert all rules
        if (!rulesToInsert.isEmpty()) {
            insert rulesToInsert;
            createdRules.addAll(rulesToInsert);
            
            // Now create all RuleFilter records
            for (Rule__c rule : rulesToInsert) {
                Map<String, ThresholdConfig> defaultThresholds = eventTypeThresholds.get(rule.Subtype__c);
                
                for (String metric : defaultThresholds.keySet()) {
                    ThresholdConfig config = defaultThresholds.get(metric);
                    String thresholdValue = (config.threshold != null) ? serializeThresholdValue(config.threshold, config.evaluationType) : '';
                    allFilters.add(new RuleFilter__c(
                        Rule__c = rule.Id,
                        FieldName__c = metric,
                        ComparisonOperator__c = config.evaluationType.name(),
                        Value__c = thresholdValue,
                        Index__c = FILTER_INDEX
                    ));
                    
                }
            }
            
            // Bulk insert all filters
            if (!allFilters.isEmpty()) {
                insert allFilters;
            }
        }
        
        return createdRules;
    }

    /**
     * Deletes all Rule__c records for a specific event type
     * @param eventType String
     */
    public static void deleteRulesForEventType(String eventType) {
        deleteRulesForEventTypes(new List<String>{eventType});
    }

    /**
     * Bulkified method to delete all Rule__c records for multiple event types
     * @param eventTypes List<String>
     */
    public static void deleteRulesForEventTypes(List<String> eventTypes) {
        List<Rule__c> rulesToDelete = [
            SELECT Id 
            FROM Rule__c 
            WHERE Type__c = :EVENT_MONITORING_TYPE 
                AND Subtype__c IN :eventTypes
        ];
        
        if (!rulesToDelete.isEmpty()) {
            delete rulesToDelete;
        }
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

        if (PermissionsUtil.EventMonitoringEnabled && ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c) {
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
        if (PermissionsUtil.EventMonitoringEnabled && ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c) {
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

        String enabledEventTypes = ConfigUtil.EVENT_MONITORING_SETTINGS?.Enabled_Types__c;
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
            // Check if it's not already enabled
            boolean wasEnabled = enabledMembersFromSettings[index];
            enabledMembersFromSettings[index] = true;
            
            // Create Rule__c record if not already enabled
            if (!wasEnabled) {
                createDefaultRulesForEventType(eventTypeToEnable);
            }
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
        DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
    }

    public void disableEventType(String eventTypeToDisable) {
        List<Boolean> enabledMembersFromSettings = getEnabledMembersFromSettings();
        Integer index = MAP_ENABLED_EVENT_TYPES.get(eventTypeToDisable);
        if (index != null) {
            // Check if it was enabled before disabling
            boolean wasEnabled = enabledMembersFromSettings[index];
            enabledMembersFromSettings[index] = false;
            
            // Delete Rule__c records if it was enabled
            if (wasEnabled) {
                deleteRulesForEventType(eventTypeToDisable);
            }
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
        DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
    }

    public static List<EventTypeStatus> getEventTypesWithStatus() {
        List<EventTypeStatus> result = new List<EventTypeStatus>();
        List<Boolean> enabledStatuses = getEnabledMembersFromSettings();
        
        // Get existing rules with logs limits
        Map<String, Integer> existingLogsLimits = new Map<String, Integer>();
        List<Rule__c> existingRules = [
            SELECT Subtype__c, Logs_Limit__c 
            FROM Rule__c 
            WHERE Type__c = :EVENT_MONITORING_TYPE
        ];
        
        for (Rule__c rule : existingRules) {
            if (rule.Logs_Limit__c != null) {
                existingLogsLimits.put(rule.Subtype__c, Integer.valueOf(rule.Logs_Limit__c));
            }
        }
        
        for (String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
            // currently skipping all event types that are not in the DEFAULT_ENABLED_EVENT_TYPES
            if (!DEFAULT_ENABLED_EVENT_TYPES.contains(eventType)) {
                continue;
            }
            Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
            Boolean isActive = false;
            if (index != null && index < enabledStatuses.size()) {
                isActive = enabledStatuses[index];
            }
            
            // Get logs limit from existing rule or default
            Integer logsLimit = existingLogsLimits.containsKey(eventType) 
                ? existingLogsLimits.get(eventType) 
                : getDefaultLogsLimitForEventType(eventType);
                
            result.add(new EventTypeStatus(eventType, isActive, logsLimit));
        }
        
        return result;
    }

    public class EventTypeStatus {
        public String name;
        public Boolean active;
        public Integer logsLimit;
        
        public EventTypeStatus(String name, Boolean active, Integer logsLimit) {
            this.name = name;
            this.active = active;
            this.logsLimit = logsLimit;
        }
    }

    /**
     * Enable all types that are present in the list and disable all others
     * Creates Rule__c records for enabled types and deletes them for disabled types
     */
    public static void setEventTypesStatuses(List<EventTypeStatus> eventTypeStatuses) {
        Integer mapSize = MAP_ENABLED_EVENT_TYPES.size();
        List<String> enabledEventTypesList = new List<String>();
        
        for (Integer i = 0; i < mapSize; i++) {
            enabledEventTypesList.add('0');
        }
        
        // Get currently enabled event types
        Set<String> currentlyEnabledTypes = new Set<String>();
        List<Boolean> currentEnabledStatuses = getEnabledMembersFromSettings();
        for (String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
            Integer index = MAP_ENABLED_EVENT_TYPES.get(eventType);
            if (index != null && index < currentEnabledStatuses.size() && currentEnabledStatuses[index]) {
                currentlyEnabledTypes.add(eventType);
            }
        }
        
        // Create maps for new enabled types and their logs limits
        Set<String> newEnabledTypes = new Set<String>();
        Map<String, Integer> newEnabledTypesWithLimits = new Map<String, Integer>();
        
        if (eventTypeStatuses == null) {
            eventTypeStatuses = new List<EventTypeStatus>();
        }
        
        for (EventTypeStatus status : eventTypeStatuses) {
            if (status.active) {
                newEnabledTypes.add(status.name);
                
                // Override logs limit if it exceeds the default maximum
                Integer effectiveLogsLimit = status.logsLimit;
                if (effectiveLogsLimit != null && effectiveLogsLimit > DEFAULT_LOGS_LIMIT_PER_HOUR) {
                    effectiveLogsLimit = DEFAULT_LOGS_LIMIT_PER_HOUR;
                }
                newEnabledTypesWithLimits.put(status.name, effectiveLogsLimit);
                
                // Set enabled status in settings
                Integer index = MAP_ENABLED_EVENT_TYPES.get(status.name);
                if (index != null && index < mapSize) {
                    enabledEventTypesList[index] = '1';
                }
            }
        }

        // Get existing rules to check what needs to be created, updated, or deleted
        Map<String, Rule__c> existingRules = new Map<String, Rule__c>();
        List<Rule__c> allExistingRules = [
            SELECT Id, Subtype__c, Logs_Limit__c 
            FROM Rule__c 
            WHERE Type__c = :EVENT_MONITORING_TYPE
        ];
        for (Rule__c rule : allExistingRules) {
            existingRules.put(rule.Subtype__c, rule);
        }
        
        // Collect event types that need rules created, updated, or deleted
        Map<String, Integer> typesToCreate = new Map<String, Integer>();
        List<Rule__c> rulesToUpdate = new List<Rule__c>();
        List<String> typesToDisable = new List<String>();
        
        // Process newly enabled types
        for (String eventType : newEnabledTypes) {
            Integer newLogsLimit = newEnabledTypesWithLimits.get(eventType);
            
            if (existingRules.containsKey(eventType)) {
                // Rule exists, check if logs limit needs updating
                Rule__c existingRule = existingRules.get(eventType);
                Integer currentLogsLimit = existingRule.Logs_Limit__c != null ? Integer.valueOf(existingRule.Logs_Limit__c) : null;
                
                if (currentLogsLimit != newLogsLimit) {
                    existingRule.Logs_Limit__c = newLogsLimit;
                    existingRule.Active__c = true; // Ensure it's active
                    rulesToUpdate.add(existingRule);
                }
            } else {
                // Rule doesn't exist, need to create it
                typesToCreate.put(eventType, newLogsLimit);
            }
        }
        
        // Process types that need to be disabled
        for (String eventType : currentlyEnabledTypes) {
            if (!newEnabledTypes.contains(eventType)) {
                typesToDisable.add(eventType);
            }
        }
        
        // Bulk create rules for newly enabled event types
        if (!typesToCreate.isEmpty()) {
            createDefaultRulesForEventTypes(typesToCreate);
        }
        
        // Bulk update existing rules with new logs limits
        if (!rulesToUpdate.isEmpty()) {
            update rulesToUpdate;
        }
        
        // Bulk delete rules for newly disabled event types
        if (!typesToDisable.isEmpty()) {
            deleteRulesForEventTypes(typesToDisable);
        }

        ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled_Types__c = String.join(enabledEventTypesList, ',');
        DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
    }

    /**
     * Default enabled event types
     * @return Set<String>
     */
    public static Set<String> DEFAULT_ENABLED_EVENT_TYPES = new Set<String>{
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR,
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS,
        EventLogProcessors.EVENT_TYPE_API,
        EventLogProcessors.EVENT_TYPE_APEX_REST_API,
        EventLogProcessors.EVENT_TYPE_REST_API,
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT,
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER,
        EventLogProcessors.EVENT_TYPE_APEX_SOAP,
        EventLogProcessors.EVENT_TYPE_LOGIN,
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST,
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST
    };

    public static String DEFAULT_ENABLED_EVENT_TYPES_STRING {
        get {
            if(DEFAULT_ENABLED_EVENT_TYPES_STRING == null || String.isBlank(DEFAULT_ENABLED_EVENT_TYPES_STRING)) {
                DEFAULT_ENABLED_EVENT_TYPES_STRING = getAllWithDefaultEnabledEventTypesAsString();
            }
            return DEFAULT_ENABLED_EVENT_TYPES_STRING;
        }
        private set;
    }

    public static String DEFAULT_DISABLED_EVENT_TYPES_STRING {
        get {
            if(DEFAULT_DISABLED_EVENT_TYPES_STRING == null || String.isBlank(DEFAULT_DISABLED_EVENT_TYPES_STRING)) {
                DEFAULT_DISABLED_EVENT_TYPES_STRING = getAllDisabledEventTypesAsString();
            }
            return DEFAULT_DISABLED_EVENT_TYPES_STRING;
        }
        private set;
    }

    public static String getAllWithDefaultEnabledEventTypesAsString() {
        List<String> result = new List<String>();
            
        for(String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
            try {
                String value = (DEFAULT_ENABLED_EVENT_TYPES.contains(eventType)) ? '1' : '0';
                result.add(value);
            }
            catch (Exception e) {
                result.add('0');
            }
        }
        
        return String.join(result, ',');
    }

    public static String getAllDisabledEventTypesAsString() {
        List<String> result = new List<String>();
            
        for(String eventType : MAP_ENABLED_EVENT_TYPES.keySet()) {
            result.add('0');
        }
            
        return String.join(result, ',');
    }

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
                    EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION =>          6,
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
        DatabaseUtils.getInstance().performUpsertDML(new List<Event_Monitoring__c>{ConfigUtil.EVENT_MONITORING_SETTINGS}, Schema.SObjectType.Event_Monitoring__c, true);
    }
}