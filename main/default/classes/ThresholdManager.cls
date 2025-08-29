public class ThresholdManager {
    private static ThresholdManager instance;
    private Map<String, Map<String, ThresholdConfig>> thresholds;
    public Map<String, Integer> logsLimitPerHour;
    

    public ThresholdManager() {
        initializeThresholds();
    }

    public static ThresholdManager getInstance() {
        if (instance == null) {
            instance = new ThresholdManager();
        }
        return instance;
    }
    
    // Initialize default thresholds
    private void initializeThresholds() {
        List<Rule__c> rules = EventMonitoringUtil.getActiveEventMonitoringRules();
        thresholds = EventMonitoringUtil.loadThresholdsFromRules(rules);
        logsLimitPerHour = EventMonitoringUtil.getLogsLimitPerHour(rules);
    }

    public Set<String> getMetrics(String eventType) {
        if (thresholds.containsKey(eventType)) {
            return thresholds.get(eventType).keySet();
        }
        return new Set<String>();
    }

    // Get threshold configuration
    public ThresholdConfig getThreshold(String eventType, String metric) {
        return thresholds.get(eventType)?.get(metric);
    }

    // common threshold configs

    public static ThresholdConfig time(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_TIME)
            .setThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig cpuTime(String eventType) {
        return cpuTime(eventType, 1500);
    }
    public static ThresholdConfig cpuTime(String eventType, Integer threshold) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setThreshold(threshold)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig cpuTimeAsync(String eventType) {
        return cpuTime(eventType, 60000);
    }
    public static ThresholdConfig runTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_RUN_TIME)
            .setThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbCpuTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_DB_CPU_TIME)
            .setThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbTotalTimeMs(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_DB_TOTAL_TIME)
            .setThreshold(50000) // 50 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbTotalTimeNs(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_DB_TOTAL_TIME)
            .setThreshold(10000) // 10 seconds in ns
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig limitUsagePercent(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_LIMIT_USAGE_PERCENT)
            .setThreshold(80) // 80%
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig requestStatus(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_REQUEST_STATUS)
            .setThreshold('F') // Failed
            .setEvalType(ThresholdConfig.EvaluationType.EQUALS)
            .build();
    }
    public static ThresholdConfig statusCode(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_STATUS_CODE)
            .setThreshold(399) // HTTP 400+
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig execTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_EXEC_TIME)
            .setThreshold(30000) // 30 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig requestSize(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_REQUEST_SIZE)
            .setThreshold(1048576) // 1MB
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig responseSize(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_RESPONSE_SIZE)
            .setThreshold(1048576) // 1MB
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig numberSoqlQueries(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_NUMBER_SOQL_QUERIES)
            .setThreshold(75) // 75 out of 100 limit
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbBlocks(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_DB_BLOCKS)
            .setThreshold(10000) // 10K blocks
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig rowsProcessed(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_ROWS_PROCESSED)
            .setThreshold(50000) // 50K rows
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig queryCount(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_QUERY_COUNT)
            .setThreshold(75) // 75 queries
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig avgRowSize(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_AVERAGE_ROW_SIZE)
            .setThreshold(1000) // 1KB per row
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig numberColumns(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_NUMBER_COLUMNS)
            .setThreshold(50) // 50 columns
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig exceptionMessage(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric(EventLogProcessors.FIELD_EXCEPTION_MESSAGE)
            .setEvalType(ThresholdConfig.EvaluationType.NOT_NULL)
            .build();
    }
}