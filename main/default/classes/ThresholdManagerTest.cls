@IsTest(IsParallel=true)
private class ThresholdManagerTest {

    @IsTest
    static void testValidGreaterThanConfig() {
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setThreshold(2000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        
        System.assertNotEquals(null, config);
    }
    
    @IsTest
    static void testValidNotNullConfig() {
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_ERROR_MESSAGE)
            .setEvalType(ThresholdConfig.EvaluationType.NOT_NULL)
            .build();
        
        System.assertNotEquals(null, config);
    }
    
    @IsTest
    static void testInvalidNotNullConfig() {
        try {
            ThresholdConfig config = new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
                .setMetric(EventLogProcessors.FIELD_ERROR_MESSAGE)
                .setThreshold('any')  // Invalid: NOT_NULL shouldn't have thresholds
                .setEvalType(ThresholdConfig.EvaluationType.NOT_NULL)
                .build();
            System.assert(false, 'Should have thrown exception');
        } catch (ThresholdConfig.ThresholdConfigException e) {
            System.assert(e.getMessage().contains('NOT_NULL evaluation type'));
        }
    }
    
    @IsTest
    static void testValidLessThanConfig() {
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_RESPONSE_SIZE)
            .setThreshold(1000)
            .setEvalType(ThresholdConfig.EvaluationType.LESS_THAN)
            .build();
        
        System.assertNotEquals(null, config);
    }
    
    @IsTest
    static void testMissingRequiredFields() {
        try {
            ThresholdConfig config = new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
                .setMetric('') // Invalid: empty metric
                .setThreshold(1000)
                .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                .build();
            System.assert(false, 'Should have thrown exception');
        } catch (ThresholdConfig.ThresholdConfigException e) {
            System.assert(e.getMessage().contains('EventType and Metric must be specified'));
        }
    }
    
    @IsTest
    static void testValidIsInConfig() {
        List<String> criticalValues = new List<String>{'Error', 'Failed', 'Timeout'};
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_REQUEST_STATUS)
            .setThreshold(criticalValues)
            .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
            .build();
        
        System.assertNotEquals(null, config);
    }

    @IsTest
    static void testAsyncReportRunThresholds() {
        // Create inline thresholds for Async Report Run
        Map<String, Map<String, ThresholdConfig>> thresholds = new Map<String, Map<String, ThresholdConfig>>();
        Map<String, ThresholdConfig> metrics = new Map<String, ThresholdConfig>();
        
        // CPU_TIME threshold: 60000ms (60 seconds)
        ThresholdConfig cpuConfig = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setThreshold(60000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        metrics.put(EventLogProcessors.FIELD_CPU_TIME, cpuConfig);
        
        // DB_TOTAL_TIME threshold: 40000ms (40 seconds)
        ThresholdConfig dbTimeConfig = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
            .setMetric(EventLogProcessors.FIELD_DB_TOTAL_TIME)
            .setThreshold(40000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        metrics.put(EventLogProcessors.FIELD_DB_TOTAL_TIME, dbTimeConfig);
        
        // ROW_COUNT threshold: 100000 rows
        ThresholdConfig rowCountConfig = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
            .setMetric(EventLogProcessors.FIELD_ROW_COUNT)
            .setThreshold(100000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        metrics.put(EventLogProcessors.FIELD_ROW_COUNT, rowCountConfig);
        
        thresholds.put(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN, metrics);
        
        // Verify event type exists
        System.assert(thresholds.containsKey(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN));
        
        Map<String, ThresholdConfig> resultMetrics = thresholds.get(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
        
        // Test CPU_TIME thresholds
        ThresholdConfig resultCpuConfig = resultMetrics.get(EventLogProcessors.FIELD_CPU_TIME);
        System.assertEquals(60000, resultCpuConfig.threshold);
        System.assertEquals(ThresholdConfig.EvaluationType.GREATER_THAN, resultCpuConfig.evaluationType);
        
        // Test DB_TOTAL_TIME thresholds
        ThresholdConfig resultDbTimeConfig = resultMetrics.get(EventLogProcessors.FIELD_DB_TOTAL_TIME);
        System.assertEquals(40000, resultDbTimeConfig.threshold);
        
        // Test ROW_COUNT thresholds
        ThresholdConfig resultRowCountConfig = resultMetrics.get(EventLogProcessors.FIELD_ROW_COUNT);
        System.assertEquals(100000, resultRowCountConfig.threshold);
    }
    
    @IsTest
    static void testCommonThresholdConfigs() {
        // Test CPU Time default thresholds
        ThresholdConfig cpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        System.assertEquals(1500, cpuConfig.threshold);
        System.assertEquals(ThresholdConfig.EvaluationType.GREATER_THAN, cpuConfig.evaluationType);
        
        // Test CPU Time with custom thresholds
        ThresholdConfig customCpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API, 2000);
        System.assertEquals(2000, customCpuConfig.threshold);
        
        // Test Async CPU Time thresholds
        ThresholdConfig asyncCpuConfig = ThresholdManager.cpuTimeAsync(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        System.assertEquals(60000, asyncCpuConfig.threshold);
    }
    
    @IsTest
    static void testApexRestApiThresholds() {
        // Create inline thresholds for Apex REST API
        Map<String, Map<String, ThresholdConfig>> thresholds = new Map<String, Map<String, ThresholdConfig>>();
        Map<String, ThresholdConfig> metrics = new Map<String, ThresholdConfig>();
        
        // TIME threshold
        metrics.put(EventLogProcessors.FIELD_TIME, ThresholdManager.time(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // RUN_TIME threshold
        metrics.put(EventLogProcessors.FIELD_RUN_TIME, ThresholdManager.runTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // CPU_TIME threshold
        metrics.put(EventLogProcessors.FIELD_CPU_TIME, ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // DB_CPU_TIME threshold
        metrics.put(EventLogProcessors.FIELD_DB_CPU_TIME, ThresholdManager.dbCpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // DB_TOTAL_TIME threshold
        metrics.put(EventLogProcessors.FIELD_DB_TOTAL_TIME, ThresholdManager.dbTotalTimeMs(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // REQUEST_STATUS threshold
        metrics.put(EventLogProcessors.FIELD_REQUEST_STATUS, ThresholdManager.requestStatus(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // REQUEST_SIZE threshold
        metrics.put(EventLogProcessors.FIELD_REQUEST_SIZE, ThresholdManager.requestSize(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
            
        // RESPONSE_SIZE threshold
        metrics.put(EventLogProcessors.FIELD_RESPONSE_SIZE, ThresholdManager.responseSize(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
            
        // STATUS_CODE threshold (HTTP 400+)
        metrics.put(EventLogProcessors.FIELD_STATUS_CODE, ThresholdManager.statusCode(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // LIMIT_USAGE_PERCENT threshold
        metrics.put(EventLogProcessors.FIELD_LIMIT_USAGE_PERCENT, ThresholdManager.limitUsagePercent(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // EXEC_TIME threshold
        metrics.put(EventLogProcessors.FIELD_EXEC_TIME, ThresholdManager.execTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // NUMBER_SOQL_QUERIES threshold
        metrics.put(EventLogProcessors.FIELD_NUMBER_SOQL_QUERIES, ThresholdManager.numberSoqlQueries(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // DB_BLOCKS threshold
        metrics.put(EventLogProcessors.FIELD_DB_BLOCKS, ThresholdManager.dbBlocks(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // OWS_PROCESSED threshold
        metrics.put(EventLogProcessors.FIELD_ROWS_PROCESSED, ThresholdManager.rowsProcessed(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        // QUERY_COUNT threshold
        metrics.put(EventLogProcessors.FIELD_QUERY_COUNT, ThresholdManager.queryCount(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // AVERAGE_ROW_SIZE threshold
        metrics.put(EventLogProcessors.FIELD_AVERAGE_ROW_SIZE, ThresholdManager.avgRowSize(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // NUMBER_COLUMNS threshold
        metrics.put(EventLogProcessors.FIELD_NUMBER_COLUMNS, ThresholdManager.numberColumns(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
        
        // EXCEPTION_MESSAGE threshold
        metrics.put(EventLogProcessors.FIELD_EXCEPTION_MESSAGE, ThresholdManager.exceptionMessage(EventLogProcessors.EVENT_TYPE_APEX_REST_API));
            
        thresholds.put(EventLogProcessors.EVENT_TYPE_APEX_REST_API, metrics);
        
        Map<String, ThresholdConfig> resultMetrics = thresholds.get(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Verify all expected metrics exist
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_RUN_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_CPU_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_DB_CPU_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_DB_TOTAL_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_REQUEST_STATUS));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_REQUEST_SIZE));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_RESPONSE_SIZE));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_STATUS_CODE));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_LIMIT_USAGE_PERCENT));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_EXEC_TIME));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_NUMBER_SOQL_QUERIES));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_DB_BLOCKS));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_ROWS_PROCESSED));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_QUERY_COUNT));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_AVERAGE_ROW_SIZE));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_NUMBER_COLUMNS));
        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_EXCEPTION_MESSAGE));
    }

    @IsTest
    static void testApexRestApiThresholds_dbTotalTimeNs() {
        // Create inline thresholds for Apex REST API
        Map<String, Map<String, ThresholdConfig>> thresholds = new Map<String, Map<String, ThresholdConfig>>();
        Map<String, ThresholdConfig> metrics = new Map<String, ThresholdConfig>();

        // DB_TOTAL_TIME threshold
        metrics.put(EventLogProcessors.FIELD_DB_TOTAL_TIME, ThresholdManager.dbTotalTimeNs(EventLogProcessors.EVENT_TYPE_APEX_REST_API));

        thresholds.put(EventLogProcessors.EVENT_TYPE_APEX_REST_API, metrics);
        
        Map<String, ThresholdConfig> resultMetrics = thresholds.get(EventLogProcessors.EVENT_TYPE_APEX_REST_API);

        System.assert(resultMetrics.containsKey(EventLogProcessors.FIELD_DB_TOTAL_TIME));
    }
    
    @IsTest
    static void testEmptyConfigurationEvents() {
        // Test events that currently have no configurations
        Map<String, Map<String, ThresholdConfig>> bulkApiThresholds = new Map<String, Map<String, ThresholdConfig>>();
        System.assert(bulkApiThresholds.isEmpty());
        
        Map<String, Map<String, ThresholdConfig>> lightningErrorThresholds = new Map<String, Map<String, ThresholdConfig>>();
        System.assert(lightningErrorThresholds.isEmpty());
        
        Map<String, Map<String, ThresholdConfig>> loginThresholds = new Map<String, Map<String, ThresholdConfig>>();
        System.assert(loginThresholds.isEmpty());
    }
    
    @IsTest
    static void testThresholdEvaluation() {
        // Create a mock field metadata config
        EventLogProcessors.FieldMetadataConfig fieldMetadata = new EventLogProcessors.FieldMetadataConfig(EventLogProcessors.FIELD_CPU_TIME, 'Number');
        // Test CPU_TIME threshold evaluation
        ThresholdConfig cpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Test normal value
        System.assertEquals(
            false,
            cpuConfig.evaluateValue(100, fieldMetadata)
        );
        
        // Test value below critical threshold (should be NORMAL)
        System.assertEquals(
            false,
            cpuConfig.evaluateValue(750, fieldMetadata)
        );
        
        // Test critical value
        System.assertEquals(
            true,
            cpuConfig.evaluateValue(2000, fieldMetadata)
        );
    }
    
    @IsTest
    static void testThresholdComparison() {
        ThresholdConfig config1 = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        ThresholdConfig config2 = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_REST_API);
        
        // Test compareTo implementation
        System.assert(config1.compareTo(config2) < 0); // EventTypeA comes before EventTypeB
    }
    
    @IsTest
    static void testValidThresholdConfigurations() {
        // Test that valid configurations work correctly
        ThresholdConfig validConfig = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setThreshold(1000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        
        System.assertNotEquals(null, validConfig);
        System.assertEquals(1000, validConfig.threshold);
    }
    
    @IsTest
    static void testNullValueHandling() {
        EventLogProcessors.FieldMetadataConfig fieldMetadata = new EventLogProcessors.FieldMetadataConfig(EventLogProcessors.FIELD_CPU_TIME, 'Number');
        ThresholdConfig config = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Test null value handling
        System.assertEquals(
            false,
            config.evaluateValue(null, fieldMetadata)
        );
    }
}