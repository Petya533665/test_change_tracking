@IsTest(IsParallel=true)
private class ThresholdManagerTest {

    @IsTest
    static void testValidGreaterThanConfig() {
        ThresholdConfig config = new ThresholdConfig.Builder()
            .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
            .setMetric(EventLogProcessors.FIELD_CPU_TIME)
            .setWarningThreshold(1000)
            .setCriticalThreshold(2000)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
        
        System.assertNotEquals(null, config);
    }
    
    @IsTest
    static void testInvalidGreaterThanConfig() {
        try {
            ThresholdConfig config = new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
                .setMetric(EventLogProcessors.FIELD_CPU_TIME)
                .setWarningThreshold(2000)
                .setCriticalThreshold(1000)  // Invalid: warning > critical
                .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                .build();
            System.assert(false, 'Should have thrown exception');
        } catch (ThresholdConfig.ThresholdConfigException e) {
            System.assert(e.getMessage().contains('Invalid threshold range'));
        }
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
                .setWarningThreshold('any')  // Invalid: NOT_NULL shouldn't have thresholds
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
            .setWarningThreshold(2000)
            .setCriticalThreshold(1000)
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
                .setWarningThreshold(1000)
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
            .setCriticalThreshold(criticalValues)
            .setEvalType(ThresholdConfig.EvaluationType.IS_IN)
            .build();
        
        System.assertNotEquals(null, config);
    }

    @IsTest
    static void testAsyncReportRunThresholds() {
        // Get thresholds for Async Report Run
        ThresholdManager.AsyncReportRunThresholdConfig config = new ThresholdManager.AsyncReportRunThresholdConfig();
        Map<String, Map<String, ThresholdConfig>> thresholds = config.getThresholds();
        
        // Verify event type exists
        System.assert(thresholds.containsKey(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN));
        
        Map<String, ThresholdConfig> metrics = thresholds.get(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
        
        // Test CPU_TIME thresholds
        ThresholdConfig cpuConfig = metrics.get(EventLogProcessors.FIELD_CPU_TIME);
        System.assertEquals(30000, cpuConfig.warningThreshold);
        System.assertEquals(60000, cpuConfig.criticalThreshold);
        System.assertEquals(ThresholdConfig.EvaluationType.GREATER_THAN, cpuConfig.evaluationType);
        
        // Test DB_TOTAL_TIME thresholds
        ThresholdConfig dbTimeConfig = metrics.get(EventLogProcessors.FIELD_DB_TOTAL_TIME);
        System.assertEquals(20000, dbTimeConfig.warningThreshold);
        System.assertEquals(40000, dbTimeConfig.criticalThreshold);
        
        // Test ROW_COUNT thresholds
        ThresholdConfig rowCountConfig = metrics.get(EventLogProcessors.FIELD_ROW_COUNT);
        System.assertEquals(50000, rowCountConfig.warningThreshold);
        System.assertEquals(100000, rowCountConfig.criticalThreshold);
    }
    
    @IsTest
    static void testCommonThresholdConfigs() {
        // Test CPU Time default thresholds
        ThresholdConfig cpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        System.assertEquals(500, cpuConfig.warningThreshold);
        System.assertEquals(1500, cpuConfig.criticalThreshold);
        System.assertEquals(ThresholdConfig.EvaluationType.GREATER_THAN, cpuConfig.evaluationType);
        
        // Test CPU Time with custom thresholds
        ThresholdConfig customCpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API, 1000, 2000);
        System.assertEquals(1000, customCpuConfig.warningThreshold);
        System.assertEquals(2000, customCpuConfig.criticalThreshold);
        
        // Test Async CPU Time thresholds
        ThresholdConfig asyncCpuConfig = ThresholdManager.cpuTimeAsync(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        System.assertEquals(30000, asyncCpuConfig.warningThreshold);
        System.assertEquals(60000, asyncCpuConfig.criticalThreshold);
    }
    
    @IsTest
    static void testApexRestApiThresholds() {
        ThresholdManager.ApexRestApiThresholdConfig config = new ThresholdManager.ApexRestApiThresholdConfig();
        Map<String, Map<String, ThresholdConfig>> thresholds = config.getThresholds();
        
        Map<String, ThresholdConfig> metrics = thresholds.get(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Verify all expected metrics exist
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_RUN_TIME));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_CPU_TIME));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_DB_CPU_TIME));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_DB_TOTAL_TIME));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_REQUEST_SIZE));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_RESPONSE_SIZE));
        System.assert(metrics.containsKey(EventLogProcessors.FIELD_STATUS_CODE));
    }
    
    @IsTest
    static void testEmptyConfigurationEvents() {
        // Test events that currently have no configurations
        ThresholdManager.BulkApiThresholdConfig bulkConfig = new ThresholdManager.BulkApiThresholdConfig();
        System.assert(bulkConfig.getThresholds().isEmpty());
        
        ThresholdManager.LightningErrorThresholdConfig lightningConfig = new ThresholdManager.LightningErrorThresholdConfig();
        System.assert(lightningConfig.getThresholds().isEmpty());
        
        ThresholdManager.LoginThresholdConfig loginConfig = new ThresholdManager.LoginThresholdConfig();
        System.assert(loginConfig.getThresholds().isEmpty());
    }
    
    @IsTest
    static void testThresholdEvaluation() {
        // Create a mock field metadata config
        EventLogProcessors.FieldMetadataConfig fieldMetadata = new EventLogProcessors.FieldMetadataConfig(EventLogProcessors.FIELD_CPU_TIME, 'Number');
        // Test CPU_TIME threshold evaluation
        ThresholdConfig cpuConfig = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Test normal value
        System.assertEquals(
            ThresholdConfig.AnomalySeverity.NORMAL,
            cpuConfig.evaluateValue(100, fieldMetadata)
        );
        
        // Test warning value
        System.assertEquals(
            ThresholdConfig.AnomalySeverity.WARNING,
            cpuConfig.evaluateValue(750, fieldMetadata)
        );
        
        // Test critical value
        System.assertEquals(
            ThresholdConfig.AnomalySeverity.CRITICAL,
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
    static void testInvalidThresholdConfigurations() {
        try {
            // Test invalid threshold range
            ThresholdConfig invalidConfig = new ThresholdConfig.Builder()
                .setEventType(EventLogProcessors.EVENT_TYPE_APEX_REST_API)
                .setMetric(EventLogProcessors.FIELD_CPU_TIME)
                .setWarningThreshold(2000)  // Warning higher than critical
                .setCriticalThreshold(1000)
                .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                .build();
            System.assert(false, 'Should have thrown exception');
        } catch (ThresholdConfig.ThresholdConfigException e) {
            System.assert(e.getMessage().contains('Invalid threshold range'));
        }
    }
    
    @IsTest
    static void testNullValueHandling() {
        EventLogProcessors.FieldMetadataConfig fieldMetadata = new EventLogProcessors.FieldMetadataConfig(EventLogProcessors.FIELD_CPU_TIME, 'Number');
        ThresholdConfig config = ThresholdManager.cpuTime(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        
        // Test null value handling
        System.assertEquals(
            ThresholdConfig.AnomalySeverity.NORMAL,
            config.evaluateValue(null, fieldMetadata)
        );
    }
}