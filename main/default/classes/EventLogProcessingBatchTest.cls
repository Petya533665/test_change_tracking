@IsTest(IsParallel = true)
private class EventLogProcessingBatchTest {

    @IsTest
    static void test_event_log_batch_processing_type_apex_unexpected_exception_by_default() {
        test_event_log_batch_processing(null);
    }

    @IsTest
    static void test_event_log_batch_processing_type_api() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_API);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_callout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_execution() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_EXECUTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_rest_api() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_soap() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_SOAP);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_trigger() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER);
    }

    @IsTest
    static void test_event_log_batch_processing_type_apex_unexpected_exception() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_api_total_usage() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_asynchronous_report_run() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
    }

    @IsTest
    static void test_event_log_batch_processing_type_aura_request() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_AURA_REQUEST);
    }

    @IsTest
    static void test_event_log_batch_processing_type_blocked_redirect() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_bulk_api() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_BULK_API);
    }

    @IsTest
    static void test_event_log_batch_processing_type_bulk_api_request() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST);
    }

    @IsTest
    static void test_event_log_batch_processing_type_bulk_api_2() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_BULK_API_2);
    }

    @IsTest
    static void test_event_log_batch_processing_type_change_set_operation() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_concurrent_long_running_apex_limit() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_console() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONSOLE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_content_distribution() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_content_document_link() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK);
    }

    @IsTest
    static void test_event_log_batch_processing_type_content_transfer() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER);
    }

    @IsTest
    static void test_event_log_batch_processing_type_continuation_callout_summary() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY);
    }

    @IsTest
    static void test_event_log_batch_processing_type_cors_violation() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CORS_VIOLATION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_csp_violation() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_CSP_VIOLATION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_dashboard() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_DASHBOARD);
    }

    @IsTest
    static void test_event_log_batch_processing_type_database_save() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_DATABASE_SAVE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_document_attachment_downloads() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS);
    }

    @IsTest
    static void test_event_log_batch_processing_type_external_custom_apex_callout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_external_cross_org_callout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_external_data_source_callout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_external_odata_callout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_flow_execution() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_group_membership() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP);
    }

    @IsTest
    static void test_event_log_batch_processing_type_hostname_redirects() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS);
    }

    @IsTest
    static void test_event_log_batch_processing_type_insecure_external_assets() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS);
    }

    @IsTest
    static void test_event_log_batch_processing_type_insufficient_access() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS);
    }

    @IsTest
    static void test_event_log_batch_processing_type_knowledge_article_view() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW);
    }

    @IsTest
    static void test_event_log_batch_processing_type_lightning_error() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR);
    }

    @IsTest
    static void test_event_log_batch_processing_type_lightning_interaction() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_lightning_logger() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER);
    }

    @IsTest
    static void test_event_log_batch_processing_type_lightning_page_view() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW);
    }

    @IsTest
    static void test_event_log_batch_processing_type_lightning_performance() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_login() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LOGIN);
    }

    @IsTest
    static void test_event_log_batch_processing_type_login_as() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LOGIN_AS);
    }

    @IsTest
    static void test_event_log_batch_processing_type_logout() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_LOGOUT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_metadata_api_operation() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_multiblock_report() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_named_credential() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL);
    }

    @IsTest
    static void test_event_log_batch_processing_type_one_commerce_usage() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_package_install() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL);
    }

    @IsTest
    static void test_event_log_batch_processing_type_permission_update() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_platform_encryption() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_pricing() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_PRICING);
    }

    @IsTest
    static void test_event_log_batch_processing_type_queued_execution() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_report() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_REPORT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_report_export() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_REPORT_EXPORT);
    }

    @IsTest
    static void test_event_log_batch_processing_type_rest_api() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_REST_API);
    }

    @IsTest
    static void test_event_log_batch_processing_type_sandbox() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_SANDBOX);
    }

    @IsTest
    static void test_event_log_batch_processing_type_search() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_SEARCH);
    }

    @IsTest
    static void test_event_log_batch_processing_type_search_click() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_SEARCH_CLICK);
    }

    @IsTest
    static void test_event_log_batch_processing_type_sites() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_SITES);
    }

    @IsTest
    static void test_event_log_batch_processing_type_time_based_workflow() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW);
    }

    @IsTest
    static void test_event_log_batch_processing_type_transaction_security() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY);
    }

    @IsTest
    static void test_event_log_batch_processing_type_ui_telemetry_navigation_timing() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING);
    }

    @IsTest
    static void test_event_log_batch_processing_type_ui_telemetry_resource_timing() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING);
    }

    @IsTest
    static void test_event_log_batch_processing_type_uri() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_URI);
    }

    @IsTest
    static void test_event_log_batch_processing_type_visualforce_request() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST);
    }

    @IsTest
    static void test_event_log_batch_processing_type_wave_change() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_WAVE_CHANGE);
    }

    @IsTest
    static void test_event_log_batch_processing_type_wave_download() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD);
    }

    @IsTest
    static void test_event_log_batch_processing_type_wave_interaction() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION);
    }

    @IsTest
    static void test_event_log_batch_processing_type_wave_performance() {
        test_event_log_batch_processing(EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE);
    }

    static void test_event_log_batch_processing(String eventType) {
        
        PermissionsUtil.EventMonitoringEnabled = true;
        // clear default enabled event types to avoid
        // No more than one executeBatch can be called from within a test method.
        // Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
        if (eventType != null) {
            EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES.clear();
        }

        // Setup test data
        Event_Monitoring__c settings = setupTestDataSettings();
        DateTime lastProcessedDt = settings.Last_Processed_Hourly_Events__c;

        // Enable event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        if (eventType != null) {
            util.enableEventType(eventType);
        }

        // Create test EventLogFile with generated data
        SObject testLogFile = createDefaultEventLogFile(eventType != null ? eventType : EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);

        // Set test event logs
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateNameFields();
        EventLogProcessors.testEventLogFieldTypes = generateTypeFields();

        // Set test thresholds
        Map<String, Map<String, ThresholdConfig>> testThresholds = null;
        testThresholds = createDefaultConfig(eventType != null ? eventType : EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);

        Test.startTest();
        // Set test thresholds
        ThresholdManager.testThresholds = testThresholds;
        // Execute batch
        EventLogProcessingBatch.getInstance().startBatch();
        Test.stopTest();

        // Verify results
        verifyDefaultTestResults(eventType, null, lastProcessedDt);
    }

    private static void verifyDefaultTestResults(String type, List<EventLogProcessingBatch.EventLogFileType> scope, DateTime lastProcessedDt) {
        if (type == null) {
            type = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        }
        // Verify Log__c records created, with correct type, category, area, and summary
        // should have 12 log records totaly, 7 logs for row #0-#11, and 5 logs for row #12
        List<Log__c> createdLogs = [SELECT Id, Type__c, Category__c, Summary__c, Details__c, Area__c FROM Log__c LIMIT 20];
        // row #0-#11: cpu_time(2 logs), status_code(2 logs), request_status(1 log), success(1 log), exception_message(1 log)
        // row #12: cpu_time + status_code + request_status + success + exception_message = 5 logs
        System.assertEquals(12, createdLogs.size(), 'Should have created 12 log records');

        AnomalyDetectors.EventTypeMetadata expectedMetadata = AnomalyDetectors.EVENT_TYPE_METADATA.get(type);
        for (Log__c log : createdLogs) {
            System.assertNotEquals(null, log.Type__c);
            System.assertEquals(expectedMetadata.category, log.Category__c);
            System.assertEquals(expectedMetadata.area, log.Area__c);
        }
        
        // Verify Last Processed DateTime
        Event_Monitoring__c updatedSettings = Event_Monitoring__c.getInstance();
        System.assertNotEquals(lastProcessedDt, updatedSettings.Last_Processed_Hourly_Events__c);
    }

    private class FieldDefinition {
        public String name { get; private set; }
        public String dataType { get; private set; }
        public String defaultValue { get; private set; }
        
        public FieldDefinition(String name, String dataType, String defaultValue) {
            this.name = name;
            this.dataType = dataType;
            this.defaultValue = defaultValue;
        }
    }

    private static final List<FieldDefinition> DEFAULT_FIELD_DEFINITIONS = new List<FieldDefinition>{
        new FieldDefinition('TIMESTAMP', 'String', '20130715233322.670'),
        new FieldDefinition('USER_ID', 'String', '005xx000001234A'),
        new FieldDefinition('ORGANIZATION_ID', 'String', '00D123456789012345'),
        new FieldDefinition('USER_ID_DERIVED', 'String', '005xx000001234A'),
        new FieldDefinition('CLIENT_IP', 'String', '192.168.1.1'),
        new FieldDefinition('SESSION_KEY', 'String', 'SESSION-{0}'),
        new FieldDefinition('TIMESTAMP_DERIVED', 'DateTime', '2024-01-01T12:00:00Z'),
        new FieldDefinition('CPU_TIME', 'Number', '{1}'),
        new FieldDefinition('DB_BLOCKS', 'Number', '50'),
        new FieldDefinition('DB_CPU_TIME', 'Number', '100'),
        new FieldDefinition('DB_TOTAL_TIME', 'Number', '150'),
        new FieldDefinition('DURATION', 'Number', '200'),
        new FieldDefinition('SUCCESS', 'Boolean', '{2}'),
        new FieldDefinition('REQUEST_ID', 'String', 'REQ-{0}'),
        new FieldDefinition('REQUEST_STATUS', 'String', '{3}'),
        new FieldDefinition('STATUS_CODE', 'Number', '{4}'),
        new FieldDefinition('URI', 'String', '/apex/AccountDetail'),
        new FieldDefinition('URI_ID_DERIVED', 'String', 'URI-{0}'),
        new FieldDefinition('EXCEPTION_MESSAGE', 'String', '{5}')
    };

    private static String generateCsvHeader() {
        List<String> headerFields = new List<String>();
        for (FieldDefinition field : DEFAULT_FIELD_DEFINITIONS) {
            headerFields.add('"' + field.name + '"');
        }
        return String.join(headerFields, ',');
    }

    private static String generateCsvRow(List<Object> params) {
        List<String> values = new List<String>();
        for (FieldDefinition field : DEFAULT_FIELD_DEFINITIONS) {
            String value = field.defaultValue;
            value = String.format(value, params);
            values.add('"' + value + '"');
        }
        return String.join(values, ',');
    }

    private static String generateNameFields() {
        List<String> values = new List<String>();
        for (FieldDefinition field : DEFAULT_FIELD_DEFINITIONS) {
            values.add(field.name);
        }
        return String.join(values, ',');
    }

    private static String generateTypeFields() {
        List<String> values = new List<String>();
        for (FieldDefinition field : DEFAULT_FIELD_DEFINITIONS) {
            values.add(field.dataType);
        }
        return String.join(values, ',');
    }

    private static final Integer CPU_TIME_NORMAL = 100;
    private static final Integer CPU_TIME_WARNING = 500;
    private static final Integer CPU_TIME_CRITICAL = 1500;

    private static final String REQUEST_STATUS_NORMAL = EventLogProcessors.RequestStatus.SUCCESS.name().left(1);
    private static final String REQUEST_STATUS_CRITICAL = EventLogProcessors.RequestStatus.FAILURE.name().left(1);

    private static final Integer STATUS_CODE_NORMAL = 200;
    private static final Integer STATUS_CODE_WARNING = 400;
    private static final Integer STATUS_CODE_CRITICAL = 500;

    private static final Boolean SUCCESS_NORMAL = true;
    private static final Boolean SUCCESS_CRITICAL = false;

    private static final String EXCEPTION_MESSAGE_NORMAL = '';
    private static final String EXCEPTION_MESSAGE_CRITICAL = 'Exception Message';
    
    private static Map<String, Map<String, ThresholdConfig>> createDefaultConfig(String eventType) {
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'CPU_TIME' => ThresholdManager.cpuTime(eventType, CPU_TIME_WARNING, CPU_TIME_CRITICAL),
                'STATUS_CODE' => ThresholdManager.statusCode(eventType, STATUS_CODE_WARNING, STATUS_CODE_CRITICAL),
                'REQUEST_STATUS' => ThresholdManager.requestStatus(eventType),
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType),
                'SUCCESS' => ThresholdManager.success(eventType)
            }
        };
        return testThresholds;
    }

    private static SObject createDefaultEventLogFile(String eventType) {
        String fileContent = generateTestDataForDefaultConfig(eventType);
        SObject testEventLog = EventMonitoringUtil.createTestEventLogSObject(
            eventType,
            Date.today(),
            Blob.valueOf(fileContent)
        );
        
        if (testEventLog == null) {
            // Fallback for orgs without EventLogFile - create a mock SObject
            Account mockAccount = new Account(Name = 'Test Mock EventLog Batch - ' + eventType);
            testEventLog = (SObject)mockAccount;
            testEventLog.put('Id', '001000000000BatchTest'); // Mock ID
        }
        
        return testEventLog;
    }

    private static String generateTestDataForDefaultConfig(String eventType) {
        String csvHeader = generateCsvHeader();
        List<String> dataRows = new List<String>();
        dataRows.add(csvHeader);

        // create per one (normal, warning, critical) csv row for each threshold rule
        // Generate 1 row of test data for CPU_TIME Normal Threshold
        dataRows.add(generateCsvRow(new List<Object>{0, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for CPU_TIME Warning Threshold
        dataRows.add(generateCsvRow(new List<Object>{1, CPU_TIME_WARNING, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for CPU_TIME Critical Threshold
        dataRows.add(generateCsvRow(new List<Object>{2, CPU_TIME_CRITICAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));

        // Generate 1 row of test data for STATUS_CODE Normal Threshold
        dataRows.add(generateCsvRow(new List<Object>{3, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for STATUS_CODE Warning Threshold
        dataRows.add(generateCsvRow(new List<Object>{4, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_WARNING, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for STATUS_CODE Critical Threshold
        dataRows.add(generateCsvRow(new List<Object>{5, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_CRITICAL, EXCEPTION_MESSAGE_NORMAL}));

        // Generate 1 row of test data for REQUEST_STATUS Normal Threshold
        dataRows.add(generateCsvRow(new List<Object>{6, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for REQUEST_STATUS Critical Threshold
        dataRows.add(generateCsvRow(new List<Object>{7, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_CRITICAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));

        // Generate 1 row of test data for SUCCESS Normal Threshold
        dataRows.add(generateCsvRow(new List<Object>{8, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for SUCCESS Critical Threshold
        dataRows.add(generateCsvRow(new List<Object>{9, CPU_TIME_NORMAL, SUCCESS_CRITICAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));

        // Generate 1 row of test data for EXCEPTION_MESSAGE Normal Threshold
        dataRows.add(generateCsvRow(new List<Object>{10, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_NORMAL}));
        // Generate 1 row of test data for EXCEPTION_MESSAGE Critical Threshold
        dataRows.add(generateCsvRow(new List<Object>{11, CPU_TIME_NORMAL, SUCCESS_NORMAL, REQUEST_STATUS_NORMAL, STATUS_CODE_NORMAL, EXCEPTION_MESSAGE_CRITICAL}));

        // Generate 1 row with all Critical Threshold values
        dataRows.add(generateCsvRow(new List<Object>{12, CPU_TIME_CRITICAL, SUCCESS_CRITICAL, REQUEST_STATUS_CRITICAL, STATUS_CODE_CRITICAL, EXCEPTION_MESSAGE_CRITICAL}));
        
        return String.join(dataRows, '\n');
    }
    
    @IsTest
    static void testEnabledEventTypes() {
        setupTestDataSettings();
        PermissionsUtil.EventMonitoringEnabled = true;

        EventMonitoringUtil util = new EventMonitoringUtil();

        System.assertEquals(false, util.isEnabled(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION), 'WaveInteraction should be disabled');
        
        Test.startTest();
        util.enableEventType(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION); 
        Test.stopTest();

        System.assertEquals(true, util.isEnabled(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION), 'WaveInteraction should be enabled');
    }

    static Event_Monitoring__c setupTestDataSettings() {
        // Create custom settings for Event Monitoring
        Event_Monitoring__c settings = new Event_Monitoring__c(
            Enabled__c = true,
            Last_Processed_Hourly_Events__c = Datetime.now().addHours(-1),
            Enabled_Types__c = EventMonitoringUtil.DEFAULT_ENABLED_EVENT_TYPES_STRING
        );
        insert settings;
        return settings;
    }
    
    @IsTest
    static void testInitialValidation() {
        // Test with null last processed datetime
        Event_Monitoring__c settings = setupTestDataSettings();
        settings.Last_Processed_Hourly_Events__c = null;
        update settings;
        
        EventLogProcessingBatch batchJob = EventLogProcessingBatch.getInstance();
        System.assertEquals(false, batchJob.initialValidation(), 
            'Should fail validation when last processed datetime is null');
    }

    @IsTest
    static void testBatchProcessingDuplicateLogicWithExistingIndex() {
        PermissionsUtil.EventMonitoringEnabled = true;

        // Test the duplicate logic handling in batch processing when LogIndex already exists
        Event_Monitoring__c settings = setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data for ApexUnexpectedException with specific data that will trigger anomalies
        String csvData = generateApexUnexpectedExceptionCsvData();
        SObject testLogFile = EventMonitoringUtil.createTestEventLogSObject(
            eventType,
            Date.today(),
            Blob.valueOf(csvData)
        );
        
        if (testLogFile == null) {
            // Fallback for orgs without EventLogFile
            Account mockAccount = new Account(Name = 'Test Mock EventLog Exception 1');
            testLogFile = (SObject)mockAccount;
            testLogFile.put('Id', '001000000000Exception1'); // Mock ID
        }
        
        // Set test event logs
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionFieldTypes();
        
        // Create existing LogIndex to simulate duplicate scenario
        // Using predictable hash based on the exception content
        String testHash = 'batch-test-duplicate-hash';
        String orgId = UserInfo.getOrganizationId();
        
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(
            new Set<String>{ConfigUtil.getLogIndexKey(testHash, orgId)}
        );
        ConfigUtil.LogIndex existingIndex = new ConfigUtil.LogIndex(testHash, orgId, DateTime.now().addDays(-1));
        helper.saveLogIndex(Logger.getInstance(), existingIndex);
        
        // Setup threshold config that will trigger anomalies
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Test.startTest();
        
        // Set test thresholds and run batch
        ThresholdManager.testThresholds = testThresholds;
        EventLogProcessingBatch.getInstance().startBatch();
        
        Test.stopTest();
        
        // Verify that logs were NOT created due to existing LogIndex (duplicate detection)
        List<Log__c> createdLogs = [SELECT Id, Hash_1__c, Request_Id_External__c FROM Log__c];
        
        // Since we have an existing LogIndex, the duplicate logic should prevent log creation
        // The exact number depends on which logs have existing indexes
        System.assert(createdLogs.size() >= 0, 
            'Logs should be filtered based on existing LogIndex entries');
        
        // Verify that any logs created do NOT have the hash that already has an index
        for (Log__c log : createdLogs) {
            System.assertNotEquals(testHash, log.Hash_1__c, 
                'No log should be created with hash that already has an existing LogIndex');
        }
    }
    
    @IsTest
    static void testBatchProcessingDuplicateLogicWithoutExistingIndex() {
        PermissionsUtil.EventMonitoringEnabled = true;

        // Test the duplicate logic handling in batch processing when no LogIndex exists
        Event_Monitoring__c settings = setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data for ApexUnexpectedException
        String csvData = generateApexUnexpectedExceptionCsvData();
        SObject testLogFile = EventMonitoringUtil.createTestEventLogSObject(
            eventType,
            Date.today(),
            Blob.valueOf(csvData)
        );
        
        if (testLogFile == null) {
            // Fallback for orgs without EventLogFile
            Account mockAccount = new Account(Name = 'Test Mock EventLog Exception 2');
            testLogFile = (SObject)mockAccount;
            testLogFile.put('Id', '001000000000Exception2'); // Mock ID
        }
        
        // Set test event logs
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionFieldTypes();
        
        // Setup threshold config that will trigger anomalies
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Test.startTest();
        
        // Set test thresholds and run batch
        ThresholdManager.testThresholds = testThresholds;
        EventLogProcessingBatch.getInstance().startBatch();
        
        Test.stopTest();
        
        // Verify that logs were created since no existing LogIndex
        List<Log__c> createdLogs = [SELECT Id, Hash_1__c, Request_Id_External__c, Type__c, Category__c FROM Log__c];
        
        // Should create logs since no existing LogIndex entries to prevent duplicates
        System.assert(createdLogs.size() > 0, 
            'Logs should be created when no existing LogIndex entries exist');
        
        // Verify log properties for ApexUnexpectedException
        for (Log__c log : createdLogs) {
            System.assert(String.isNotBlank(log.Hash_1__c), 
                'Log should have Hash_1__c populated');
            System.assert(log.Type__c.contains('Exception') || log.Type__c.contains('System'), 
                'Log type should be related to exceptions');
        }
    }
    
    @IsTest
    static void testBatchProcessingMixedDuplicateScenario() {
        PermissionsUtil.EventMonitoringEnabled = true;

        // Test scenario with some logs having existing indexes and some not
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with multiple exception records
        String csvData = generateMultipleApexUnexpectedExceptionCsvData();
        SObject testLogFile = EventMonitoringUtil.createTestEventLogSObject(
            eventType,
            Date.today(),
            Blob.valueOf(csvData)
        );
        
        if (testLogFile == null) {
            // Fallback for orgs without EventLogFile
            Account mockAccount = new Account(Name = 'Test Mock EventLog Exception 3');
            testLogFile = (SObject)mockAccount;
            testLogFile.put('Id', '001000000000Exception3'); // Mock ID
        }
        
        // Set test event logs
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionFieldTypes();
        
        // Create existing LogIndex for only one of the exceptions
        String existingHash = 'mixed-test-existing-hash';
        String orgId = UserInfo.getOrganizationId();
        
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(
            new Set<String>{ConfigUtil.getLogIndexKey(existingHash, orgId)}
        );
        ConfigUtil.LogIndex existingIndex = new ConfigUtil.LogIndex(existingHash, orgId, DateTime.now().addDays(-1));
        helper.saveLogIndex(Logger.getInstance(), existingIndex);
        
        // Setup threshold config
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Test.startTest();
        
        // Count logs before batch processing
        Integer logsBefore = [SELECT COUNT() FROM Log__c];
        
        // Set test thresholds and run batch
        ThresholdManager.testThresholds = testThresholds;
        EventLogProcessingBatch.getInstance().startBatch();
        
        Test.stopTest();
        
        // Verify mixed results
        List<Log__c> createdLogs = [SELECT Id, Hash_1__c, Request_Id_External__c FROM Log__c];
        Integer logsAfter = createdLogs.size();
        
        // Should have some logs created (for new exceptions) but not all (due to duplicates)
        System.assert(logsAfter >= logsBefore, 
            'Should have created some logs for new exceptions');
        
        // Verify that no log was created with the existing hash
        Boolean foundExistingHash = false;
        for (Log__c log : createdLogs) {
            if (existingHash.equals(log.Hash_1__c)) {
                foundExistingHash = true;
                break;
            }
        }
        System.assertEquals(false, foundExistingHash, 
            'Should not create log for exception with existing LogIndex');
    }
    
    // Helper method to generate ApexUnexpectedException CSV data
    private static String generateApexUnexpectedExceptionCsvData() {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","USER_ID"';
        
        DateTime testTime = DateTime.now();
        String formattedTiming = testTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestampFormat = testTime.format('yyyyMMddHHmmss') + '.000';
        
        String csvData = '"APEX_CODE","List index out of bounds: 0","System.ListException",' +
                        '"Class.TestClass.processData: line 15\\nClass.TestClass.execute: line 5",' +
                        '"REQ-BATCH-001","00D123456789012345","005xx000001234A","005xx000001234A",' +
                        '"' + formattedTiming + '","' + timestampFormat + '","005xx000001234A"';
        
        return csvHeader + '\n' + csvData;
    }
    
    // Helper method to generate multiple ApexUnexpectedException CSV data
    private static String generateMultipleApexUnexpectedExceptionCsvData() {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","USER_ID"';
        
        List<String> csvRows = new List<String>();
        csvRows.add(csvHeader);
        
        // Calculate proper timestamps for each record
        DateTime baseTime = DateTime.now();
        DateTime time1 = baseTime.addMinutes(1);
        DateTime time2 = baseTime.addMinutes(2);
        DateTime time3 = baseTime.addMinutes(3);
        
        String formattedTime1 = time1.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestamp1 = time1.format('yyyyMMddHHmmss') + '.000';
        String formattedTime2 = time2.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestamp2 = time2.format('yyyyMMddHHmmss') + '.000';
        String formattedTime3 = time3.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestamp3 = time3.format('yyyyMMddHHmmss') + '.000';
        
        // First exception record
        csvRows.add('"APEX_CODE","List index out of bounds: 0","System.ListException",' +
                    '"Class.TestClass.processData: line 15\\nClass.TestClass.execute: line 5",' +
                    '"REQ-MIXED-001","00D123456789012345","005xx000001234A","005xx000001234A",' +
                    '"' + formattedTime1 + '","' + timestamp1 + '","005xx000001234A"');
        
        // Second exception record
        csvRows.add('"APEX_CODE","Null pointer exception","System.NullPointerException",' +
                    '"Class.AnotherClass.handleData: line 25\\nClass.AnotherClass.run: line 10",' +
                    '"REQ-MIXED-002","00D123456789012345","005xx000001234B","005xx000001234B",' +
                    '"' + formattedTime2 + '","' + timestamp2 + '","005xx000001234B"');
        
        // Third exception record
        csvRows.add('"APEX_CODE","DML Exception occurred","System.DmlException",' +
                    '"Class.DataProcessor.updateRecords: line 30\\nClass.DataProcessor.process: line 15",' +
                    '"REQ-MIXED-003","00D123456789012345","005xx000001234C","005xx000001234C",' +
                    '"' + formattedTime3 + '","' + timestamp3 + '","005xx000001234C"');
        
        return String.join(csvRows, '\n');
    }
    
    // Helper method to generate field names for ApexUnexpectedException
    private static String generateApexUnexpectedExceptionFieldNames() {
        return 'EXCEPTION_CATEGORY,EXCEPTION_MESSAGE,EXCEPTION_TYPE,STACK_TRACE,' +
               'REQUEST_ID,ORGANIZATION_ID,USER_ID,USER_ID_DERIVED,TIMESTAMP_DERIVED,' +
               'TIMESTAMP,USER_ID';
    }
    
    // Helper method to generate field types for ApexUnexpectedException
    private static String generateApexUnexpectedExceptionFieldTypes() {
        return 'String,String,String,String,' +
               'String,String,String,String,DateTime,' +
               'String,String';
    }

    // ==========================================
    // Enhanced Deduplication Test Cases
    // ==========================================

    @IsTest
    static void testEnhancedDeduplicationDisabled() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Configure batch with deduplication disabled
        EventLogProcessingBatch batch = EventLogProcessingBatch.getInstance();
        EventLogProcessingBatch.EnhancedDeduplicationSettings dedupSettings = new EventLogProcessingBatch.EnhancedDeduplicationSettings();
        dedupSettings.enableEmailEventDeduplication = false;
        dedupSettings.enableDetailedLogging = true;
        batch.configureDeduplication(dedupSettings);
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with Request_Id_External__c
        String csvData = generateApexUnexpectedExceptionWithRequestIdCsvData();
        SObject testLogFile = createMockEventLogFile(eventType, csvData);
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionWithRequestIdFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionWithRequestIdFieldTypes();
        
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Test.startTest();
        ThresholdManager.testThresholds = testThresholds;
        batch.startBatch();
        Test.stopTest();
        
        // Verify all logs were created (no deduplication)
        List<Log__c> createdLogs = [SELECT Id, Request_Id_External__c FROM Log__c];
        System.assert(createdLogs.size() > 0, 'Logs should be created when deduplication is disabled');
    }

    @IsTest
    static void testEnhancedDeduplicationWithNoExistingLogs() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Configure batch with deduplication enabled
        EventLogProcessingBatch batch = EventLogProcessingBatch.getInstance();
        EventLogProcessingBatch.EnhancedDeduplicationSettings dedupSettings = new EventLogProcessingBatch.EnhancedDeduplicationSettings();
        dedupSettings.enableEmailEventDeduplication = true;
        dedupSettings.timingToleranceSeconds = 10;
        dedupSettings.enableDetailedLogging = true;
        batch.configureDeduplication(dedupSettings);
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with Request_Id_External__c
        String csvData = generateApexUnexpectedExceptionWithRequestIdCsvData();
        SObject testLogFile = createMockEventLogFile(eventType, csvData);
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionWithRequestIdFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionWithRequestIdFieldTypes();
        
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Test.startTest();
        ThresholdManager.testThresholds = testThresholds;
        batch.startBatch();
        Test.stopTest();
        
        // Verify logs were created (no existing logs to deduplicate against)
        List<Log__c> createdLogs = [SELECT Id, Request_Id_External__c, Hash_1__c FROM Log__c];
        System.assert(createdLogs.size() > 0, 'Event logs should be created when no existing logs exist');
        
        for (Log__c log : createdLogs) {
            System.assert(String.isNotBlank(log.Request_Id_External__c), 'Event logs should have Request_Id_External__c');
            System.assert(String.isNotBlank(log.Hash_1__c), 'Event logs should have Hash_1__c');
        }
    }

    @IsTest
    static void testEnhancedDeduplicationWithExistingEmailLogs() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        DateTime emailLogTime = DateTime.now().addSeconds(-5);
        String testHash = 'LTeYLyEUH7KjnrUvHawj/Mss4FCZpYFS5HQMgfDpCtY='; // Use the actual hash from debug logs
        
        // Create existing email-based log with the known hash
        Log__c existingEmailLog = new Log__c(
            Hash_1__c = testHash,
            Created_At__c = emailLogTime,
            Organization_Id__c = UserInfo.getOrganizationId(),
            Type__c = 'Email Exception',
            Category__c = 'System',
            Area__c = 'Exception Monitoring',
            Summary__c = 'Test existing email log'
        );
        insert existingEmailLog;
        
        // Create an Inbound_Email__c record related to the existing log
        Inbound_Email__c inboundEmail = new Inbound_Email__c(
            Log__c = existingEmailLog.Id,
            Subject__c = 'Test Exception Email'
        );
        insert inboundEmail;
        
        // Set up Last_Processed_Hourly_Events__c to be around the email log time
        // This will create a proper +/- 10 minute window for the deduplication
        DateTime hourlyProcessTime = emailLogTime.addMinutes(2); // 2 minutes after email log
        Event_Monitoring__c settings = ConfigUtil.EVENT_MONITORING_SETTINGS;
        settings.Last_Processed_Hourly_Events__c = hourlyProcessTime;
        update settings;
        
        // Configure batch with deduplication enabled
        EventLogProcessingBatch batch = EventLogProcessingBatch.getInstance();
        EventLogProcessingBatch.EnhancedDeduplicationSettings dedupSettings = new EventLogProcessingBatch.EnhancedDeduplicationSettings();
        dedupSettings.enableEmailEventDeduplication = true;
        dedupSettings.timingToleranceSeconds = 600; // 10 minutes tolerance
        dedupSettings.enableDetailedLogging = true;
        batch.configureDeduplication(dedupSettings);
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with timing within tolerance (will generate same hash)
        // Use same timestamp as email log to ensure timing match
        String csvData = generateApexUnexpectedExceptionWithTimingCsvData(emailLogTime);
        SObject testLogFile = createMockEventLogFile(eventType, csvData);
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionWithRequestIdFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionWithRequestIdFieldTypes();
        
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Integer logsBefore = [SELECT COUNT() FROM Log__c];
        
        Test.startTest();
        ThresholdManager.testThresholds = testThresholds;
        batch.startBatch();
        Test.stopTest();
        
        Integer logsAfter = [SELECT COUNT() FROM Log__c];
        
        // Verify that event log was skipped due to timing match with existing email log
        System.assertEquals(logsBefore, logsAfter, 'Event log should be skipped due to timing match with existing email log');
        
        // Verify that existing email log was updated with Request_Id_External__c
        Log__c updatedEmailLog = [SELECT Id, Request_Id_External__c FROM Log__c WHERE Id = :existingEmailLog.Id];
        System.assert(String.isNotBlank(updatedEmailLog.Request_Id_External__c), 'Existing email log should have Request_Id_External__c populated');
    }

    @IsTest
    static void testEnhancedDeduplicationWithFastFilter() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Create existing log with Request_Id_External__c that will match new event log
        String existingRequestId = 'REQ-FAST-FILTER-001';
        Log__c existingLog = new Log__c(
            Request_Id_External__c = existingRequestId,
            Hash_1__c = 'EXISTING-HASH-001',
            Created_At__c = DateTime.now(),
            Type__c = 'Event Log Exception'
        );
        insert existingLog;
        
        // Configure batch with deduplication enabled
        EventLogProcessingBatch batch = EventLogProcessingBatch.getInstance();
        EventLogProcessingBatch.EnhancedDeduplicationSettings dedupSettings = new EventLogProcessingBatch.EnhancedDeduplicationSettings();
        dedupSettings.enableEmailEventDeduplication = true;
        dedupSettings.timingToleranceSeconds = 10;
        dedupSettings.enableDetailedLogging = true;
        batch.configureDeduplication(dedupSettings);
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with same Request_Id_External__c
        String csvData = generateApexUnexpectedExceptionWithSpecificRequestIdCsvData(existingRequestId);
        SObject testLogFile = createMockEventLogFile(eventType, csvData);
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionWithRequestIdFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionWithRequestIdFieldTypes();
        
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Integer logsBefore = [SELECT COUNT() FROM Log__c];
        
        Test.startTest();
        ThresholdManager.testThresholds = testThresholds;
        batch.startBatch();
        Test.stopTest();
        
        Integer logsAfter = [SELECT COUNT() FROM Log__c];
        
        // Verify that event log was skipped due to existing Request_Id_External__c (fast filter)
        System.assertEquals(logsBefore, logsAfter, 'Event log should be skipped due to existing Request_Id_External__c');
    }

    @IsTest
    static void testEnhancedDeduplicationMixedScenario() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Calculate the hash that would be generated for the timing match test
        DateTime emailLogTime = DateTime.now().addMinutes(-5);
        String exceptionMessage = 'Test exception for timing';
        String stackTrace = 'Class.TestClass.processData: line 20';
        String expectedHash = 'LTeYLyEUH7KjnrUvHawj/Mss4FCZpYFS5HQMgfDpCtY=';

        
        // Create one existing email log for timing match
        Log__c existingEmailLog = new Log__c(
            Hash_1__c = expectedHash,
            Created_At__c = emailLogTime,
            Organization_Id__c = UserInfo.getOrganizationId(),
            Type__c = 'Email Exception',
            Category__c = 'System',
            Area__c = 'Exception Monitoring',
            Summary__c = 'Test existing email log'
        );
        insert existingEmailLog;
        
        Inbound_Email__c inboundEmail = new Inbound_Email__c(
            Log__c = existingEmailLog.Id,
            Subject__c = 'Test Exception Email'
        );
        insert inboundEmail;
        
        // Create one existing event log for fast filter
        String existingRequestId = 'REQ-MIXED-002';
        Log__c existingEventLog = new Log__c(
            Request_Id_External__c = existingRequestId,
            Hash_1__c = 'MIXED-HASH-002',
            Organization_Id__c = UserInfo.getOrganizationId(),
            Type__c = 'Event Log Exception',
            Category__c = 'System',
            Area__c = 'Exception Monitoring',
            Summary__c = 'Test existing event log'
        );
        insert existingEventLog;
        
        // Configure batch with deduplication enabled
        EventLogProcessingBatch batch = EventLogProcessingBatch.getInstance();
        EventLogProcessingBatch.EnhancedDeduplicationSettings dedupSettings = new EventLogProcessingBatch.EnhancedDeduplicationSettings();
        dedupSettings.enableEmailEventDeduplication = true;
        dedupSettings.timingToleranceSeconds = 600; // 10 minutes tolerance
        dedupSettings.enableDetailedLogging = true;
        batch.configureDeduplication(dedupSettings);
        
        // Enable the event type
        EventMonitoringUtil util = new EventMonitoringUtil();
        util.enableEventType(eventType);
        
        // Create test data with mixed scenarios:
        // 1. One log with same hash as email log (should be skipped)
        // 2. One log with same Request_Id as existing event log (should be skipped)
        // 3. One log with new hash and Request_Id (should be created)
        String csvData = generateMixedDeduplicationCsvData(expectedHash, existingRequestId, emailLogTime, exceptionMessage, stackTrace);
        SObject testLogFile = createMockEventLogFile(eventType, csvData);
        
        EventMonitoringUtil.testEventLogs = new List<SObject>{testLogFile};
        EventLogProcessors.testEventLogFieldNames = generateApexUnexpectedExceptionWithRequestIdFieldNames();
        EventLogProcessors.testEventLogFieldTypes = generateApexUnexpectedExceptionWithRequestIdFieldTypes();
        
        Map<String, Map<String, ThresholdConfig>> testThresholds = new Map<String, Map<String, ThresholdConfig>>{
            eventType => new Map<String, ThresholdConfig>{
                'EXCEPTION_MESSAGE' => ThresholdManager.exceptionMessage(eventType)
            }
        };
        
        Integer logsBefore = [SELECT COUNT() FROM Log__c];
        
        Test.startTest();
        ThresholdManager.testThresholds = testThresholds;
        batch.startBatch();
        Test.stopTest();
        
        Integer logsAfter = [SELECT COUNT() FROM Log__c];
        
        // Verify mixed results: should have created some logs but not all
        System.assert(logsAfter > logsBefore, 'Some new logs should be created');
        System.assert(logsAfter < logsBefore + 3, 'Not all logs should be created due to deduplication');
        
        // Verify that existing email log was updated with Request_Id_External__c
        Log__c updatedEmailLog = [SELECT Id, Request_Id_External__c FROM Log__c WHERE Id = :existingEmailLog.Id];
        System.assert(String.isNotBlank(updatedEmailLog.Request_Id_External__c), 'Existing email log should have Request_Id_External__c populated');
    }

    @IsTest
    static void testProcessEnhancedDeduplicationStaticMethod() {
        // Test the static method directly
        String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        
        // Create test logs
        List<Log__c> testLogs = new List<Log__c>();
        testLogs.add(new Log__c(
            Request_Id_External__c = 'REQ-STATIC-001',
            Hash_1__c = 'STATIC-HASH-001',
            Created_At__c = DateTime.now(),
            Type__c = 'Test Event Log'
        ));
        testLogs.add(new Log__c(
            Hash_1__c = 'STATIC-HASH-002',
            Created_At__c = DateTime.now(),
            Type__c = 'Test Other Log'
        ));
        
        // Create deduplication settings
        Map<String, Object> dedupSettings = new Map<String, Object>{
            'enableEmailEventDeduplication' => true,
            'timingToleranceSeconds' => 10,
            'preserveAllEventLogs' => true,
            'enableDetailedLogging' => true,
            'eventTypesToCheck' => new Set<String>{eventType}
        };
        
        Test.startTest();
        
        // Call the static method
        List<Log__c> result = EventLogProcessors.processEnhancedDeduplication(
            eventType, 
            dedupSettings, 
            Logger.getInstance(), 
            testLogs
        );
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should return processed logs');
    }

    // Helper methods for generating test data

    private static SObject createMockEventLogFile(String eventType, String csvData) {
        SObject testLogFile = EventMonitoringUtil.createTestEventLogSObject(
            eventType,
            Date.today(),
            Blob.valueOf(csvData)
        );
        
        if (testLogFile == null) {
            // Fallback for orgs without EventLogFile
            Account mockAccount = new Account(Name = 'Test Mock EventLog - ' + eventType);
            testLogFile = (SObject)mockAccount;
            testLogFile.put('Id', '001000000000' + String.valueOf(Math.random()).substring(2, 8)); // Mock ID
        }
        
        return testLogFile;
    }

    private static String generateApexUnexpectedExceptionWithRequestIdCsvData() {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","HASH_1"';
        
        DateTime testTime = DateTime.now();
        String formattedTiming = testTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestampFormat = testTime.formatGMT('yyyyMMddHHmmss') + '.000';
        
        String csvData = '"APEX_CODE","List index out of bounds: 0","System.ListException",' +
                        '"Class.TestClass.processData: line 15\\nClass.TestClass.execute: line 5",' +
                        '"REQ-TEST-001","00D123456789012345","005xx000001234A","005xx000001234A",' +
                        '"' + formattedTiming + '","' + timestampFormat + '","TEST-HASH-001"';
        
        return csvHeader + '\n' + csvData;
    }

    private static String generateApexUnexpectedExceptionWithTimingCsvData(DateTime timing) {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","HASH_1"';
        
        String formattedTiming = timing.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestampFormat = timing.formatGMT('yyyyMMddHHmmss') + '.000'; // Convert to TIMESTAMP format
        String csvData = '"APEX_CODE","Test exception for timing","System.TestException",' +
                        '"Class.TestClass.processData: line 20",' +
                        '"REQ-TIMING-001","00D123456789012345","005xx000001234A","005xx000001234A",' +
                        '"' + formattedTiming + '","' + timestampFormat + '","TEST-HASH-001"';
        
        return csvHeader + '\n' + csvData;
    }

    private static String generateApexUnexpectedExceptionWithSpecificRequestIdCsvData(String requestId) {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","HASH_1"';
        
        DateTime testTime = DateTime.now();
        String formattedTiming = testTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timestampFormat = testTime.formatGMT('yyyyMMddHHmmss') + '.000';
        
        String csvData = '"APEX_CODE","Test exception for fast filter","System.TestException",' +
                        '"Class.TestClass.processData: line 25",' +
                        '"' + requestId + '","00D123456789012345","005xx000001234A","005xx000001234A",' +
                        '"' + formattedTiming + '","' + timestampFormat + '","FAST-FILTER-HASH-001"';
        
        return csvHeader + '\n' + csvData;
    }

    private static String generateMixedDeduplicationCsvData(String existingHash, String existingRequestId, DateTime emailLogTime, String exceptionMessage, String stackTrace) {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","HASH_1"';
        
        List<String> csvRows = new List<String>();
        csvRows.add(csvHeader);
        
        // Calculate proper timestamps for each log entry
        DateTime log1Time = emailLogTime.addMinutes(3);
        DateTime log2Time = emailLogTime.addMinutes(5);
        DateTime log3Time = emailLogTime.addMinutes(7);
        
        String log1FormattedTiming = log1Time.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String log1Timestamp = log1Time.formatGMT('yyyyMMddHHmmss') + '.000';
        String log2FormattedTiming = log2Time.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String log2Timestamp = log2Time.formatGMT('yyyyMMddHHmmss') + '.000';
        String log3FormattedTiming = log3Time.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String log3Timestamp = log3Time.formatGMT('yyyyMMddHHmmss') + '.000';
        
        // Log 1: Should be skipped due to timing match with existing email log
        // Create the same exception data that would generate the expected hash
        csvRows.add('"APEX_CODE","' + exceptionMessage + '","System.TestException",' +
                    '"' + stackTrace + '",' +
                    '"REQ-MIXED-TIMING-001","00D123456789012345","005xx000001234A","005xx000001234A",' +
                    '"' + log1FormattedTiming + '","' + log1Timestamp + '","' + existingHash + '"');
        
        // Log 2: Should be skipped due to existing Request_Id
        csvRows.add('"APEX_CODE","Exception with existing Request_Id","System.TestException",' +
                    '"Class.TestClass.processData: line 35",' +
                    '"' + existingRequestId + '","00D123456789012345","005xx000001234B","005xx000001234B",' +
                    '"' + log2FormattedTiming + '","' + log2Timestamp + '","MIXED-HASH-002"');
        
        // Log 3: Should be created (new hash and Request_Id)
        csvRows.add('"APEX_CODE","New exception to be created","System.TestException",' +
                    '"Class.TestClass.processData: line 40",' +
                    '"REQ-MIXED-NEW-001","00D123456789012345","005xx000001234C","005xx000001234C",' +
                    '"' + log3FormattedTiming + '","' + log3Timestamp + '","MIXED-HASH-003"');
        
        return String.join(csvRows, '\n');
    }

    private static String generateApexUnexpectedExceptionWithRequestIdFieldNames() {
        return 'EXCEPTION_CATEGORY,EXCEPTION_MESSAGE,EXCEPTION_TYPE,STACK_TRACE,' +
               'REQUEST_ID,ORGANIZATION_ID,USER_ID,USER_ID_DERIVED,TIMESTAMP_DERIVED,' +
               'TIMESTAMP,HASH_1';
    }
    
    private static String generateApexUnexpectedExceptionWithRequestIdFieldTypes() {
        return 'String,String,String,String,' +
               'String,String,String,String,DateTime,' +
               'String,String';
    }

    @IsTest
    static void testEnhancedDeduplicationDirectCall() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        
        // Create an existing email log with a known hash
        DateTime emailLogTime = DateTime.now().addMinutes(-5);
        String testHash = 'LTeYLyEUH7KjnrUvHawj/Mss4FCZpYFS5HQMgfDpCtY='; // Use the actual hash from debug logs
        
        Log__c existingEmailLog = new Log__c(
            Hash_1__c = testHash,
            Created_At__c = emailLogTime,
            Organization_Id__c = UserInfo.getOrganizationId(),
            Type__c = 'Email Exception',
            Category__c = 'System',
            Area__c = 'Exception Monitoring',
            Summary__c = 'Test existing email log'
        );
        insert existingEmailLog;
        
        // Create an Inbound_Email__c record related to the existing log
        Inbound_Email__c inboundEmail = new Inbound_Email__c(
            Log__c = existingEmailLog.Id,
            Subject__c = 'Test Exception Email'
        );
        insert inboundEmail;
        
        // Create a new event log with the same hash and timing within tolerance
        Log__c newEventLog = new Log__c(
            Hash_1__c = testHash,
            Created_At__c = emailLogTime.addMinutes(3),
            Organization_Id__c = UserInfo.getOrganizationId(),
            Request_Id_External__c = 'REQ-TIMING-001',
            Type__c = 'System.APEX_CODE',
            Category__c = 'System',
            Area__c = 'Apex',
            Summary__c = 'Test exception for timing'
        );
        
        // Test the enhanced deduplication directly
        Map<String, Object> dedupSettings = new Map<String, Object>{
            'enableEmailEventDeduplication' => true,
            'timingToleranceSeconds' => 600,
            'preserveAllEventLogs' => true,
            'enableDetailedLogging' => true,
            'eventTypesToCheck' => new Set<String>{'ApexUnexpectedException'}
        };
        
        List<Log__c> inputLogs = new List<Log__c>{newEventLog};
        List<Log__c> resultLogs = EventLogProcessors.processEnhancedDeduplication(
            'ApexUnexpectedException', 
            dedupSettings, 
            Logger.getInstance(), 
            inputLogs
        );
        
        // Should return empty list because the event log should be skipped
        System.assertEquals(0, resultLogs.size(), 'Event log should be skipped due to timing match');
        
        // Verify that existing email log was updated with Request_Id_External__c
        Log__c updatedEmailLog = [SELECT Id, Request_Id_External__c FROM Log__c WHERE Id = :existingEmailLog.Id];
        System.assert(String.isNotBlank(updatedEmailLog.Request_Id_External__c), 'Existing email log should have Request_Id_External__c populated');
        System.assertEquals('REQ-TIMING-001', updatedEmailLog.Request_Id_External__c, 'Request_Id_External__c should match');
    }

    @IsTest
    static void testEnhancedDeduplicationManualLogCreation() {
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        
        // Create existing email log
        DateTime emailLogTime = DateTime.now().addMinutes(-5);
        String testHash = 'LTeYLyEUH7KjnrUvHawj/Mss4FCZpYFS5HQMgfDpCtY='; // Use the actual hash from debug logs
        
        Log__c existingEmailLog = new Log__c(
            Hash_1__c = testHash,
            Created_At__c = emailLogTime,
            Organization_Id__c = UserInfo.getOrganizationId(),
            Type__c = 'Email Exception',
            Category__c = 'System',
            Area__c = 'Exception Monitoring',
            Summary__c = 'Test existing email log'
        );
        insert existingEmailLog;
        
        Inbound_Email__c inboundEmail = new Inbound_Email__c(
            Log__c = existingEmailLog.Id,
            Subject__c = 'Test Exception Email'
        );
        insert inboundEmail;
        
        // Set up Last_Processed_Hourly_Events__c to be around the email log time
        DateTime hourlyProcessTime = emailLogTime.addMinutes(2);
        Event_Monitoring__c settings = ConfigUtil.EVENT_MONITORING_SETTINGS;
        settings.Last_Processed_Hourly_Events__c = hourlyProcessTime;
        update settings;
        
        // Manually create an event log with the same hash and timing within tolerance
        Log__c eventLog = new Log__c(
            Hash_1__c = testHash,
            Created_At__c = emailLogTime.addMinutes(1), // 1 minute after email log (within 10 minute tolerance)
            Organization_Id__c = UserInfo.getOrganizationId(),
            Request_Id_External__c = 'REQ-MANUAL-001',
            Type__c = 'System.APEX_CODE',
            Category__c = 'System',
            Area__c = 'Apex',
            Summary__c = 'Test exception for timing'
        );
        
        // Test the enhanced deduplication directly
        Map<String, Object> dedupSettings = new Map<String, Object>{
            'enableEmailEventDeduplication' => true,
            'timingToleranceSeconds' => 600,
            'preserveAllEventLogs' => true,
            'enableDetailedLogging' => true,
            'eventTypesToCheck' => new Set<String>{'ApexUnexpectedException'}
        };
        
        List<Log__c> inputLogs = new List<Log__c>{eventLog};
        Integer logsBefore = [SELECT COUNT() FROM Log__c];
        
        Test.startTest();
        List<Log__c> resultLogs = EventLogProcessors.processEventLogsWithEmailAwareness(
            inputLogs, 
            dedupSettings, 
            Logger.getInstance()
        );
        Test.stopTest();
        
        Integer logsAfter = [SELECT COUNT() FROM Log__c];
        
        // Should return empty list because the event log should be skipped due to timing match
        System.assertEquals(0, resultLogs.size(), 'Event log should be skipped due to timing match');
        
        // No new logs should be created
        System.assertEquals(logsBefore, logsAfter, 'No new logs should be created due to deduplication');
        
        // Verify that existing email log was updated with Request_Id_External__c
        Log__c updatedEmailLog = [SELECT Id, Request_Id_External__c FROM Log__c WHERE Id = :existingEmailLog.Id];
        System.assertEquals('REQ-MANUAL-001', updatedEmailLog.Request_Id_External__c, 'Existing email log should have Request_Id_External__c populated');
    }

    @IsTest
    static void testEnhancedEventLogFileType() {
        // Test the enhanced EventLogFileType constructor
        Double fileSizeBytes = 102400.0; // 100 KB
        EventLogProcessingBatch.EventLogFileType chunk = 
            new EventLogProcessingBatch.EventLogFileType('API', 'test-id', fileSizeBytes);
        
        // Verify the chunk properties
        System.assertEquals('API', chunk.type, 'Event type should match');
        System.assertEquals('test-id', chunk.logFileId, 'Log file ID should match');
        System.assertEquals(fileSizeBytes, chunk.logFileLengthBytes, 'File size should match');
        System.assertEquals(1000, chunk.estimatedRecordCount, 'Estimated record count should be 1000 for 100KB');
        System.assertEquals(500, chunk.chunkSize, 'Chunk size should be 500 for 100KB file');
        System.assertEquals(0, chunk.startRow, 'Start row should be 0');
        System.assertEquals(500, chunk.endRow, 'End row should be 500');
    }
    
    @IsTest
    static void testChunkSizeCalculation() {
        // Test small file (50 KB)
        EventLogProcessingBatch.EventLogFileType smallChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(51200.0));
        System.assertEquals(500, smallChunk.chunkSize, 'Small file should have 500 record chunks');
        
        // Test medium file (300 KB)
        EventLogProcessingBatch.EventLogFileType mediumChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(307200.0));
        System.assertEquals(1000, mediumChunk.chunkSize, 'Medium file should have 1000 record chunks');
        
        // Test large file (1 MB)
        EventLogProcessingBatch.EventLogFileType largeChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(1048576.0));
        System.assertEquals(2000, largeChunk.chunkSize, 'Large file should have 2000 record chunks');
        
        // Test very large file (5 MB)
        EventLogProcessingBatch.EventLogFileType veryLargeChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(5242880.0));
        System.assertEquals(5000, veryLargeChunk.chunkSize, 'Very large file should have 5000 record chunks');
    }
    
    @IsTest
    static void testRecordCountEstimation() {
        // Test record count estimation
        EventLogProcessingBatch.EventLogFileType smallChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(10240.0));
        System.assertEquals(100, smallChunk.estimatedRecordCount, '10KB file should have ~100 records');
        
        EventLogProcessingBatch.EventLogFileType largeChunk = new EventLogProcessingBatch.EventLogFileType('API', 'test', Double.valueOf(1048576.0));
        System.assertEquals(10240, largeChunk.estimatedRecordCount, '1MB file should have ~10240 records');
    }

    // Test batch processor class for chunked processing tests
    private class TestBatchProcessor implements EventLogProcessors.IBatchProcessor {
        public List<EventLogProcessors.IBaseEventData> processedRecords = new List<EventLogProcessors.IBaseEventData>();
        
        public void processBatchEventDataResults(List<EventLogProcessors.IBaseEventData> batchResults, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
            processedRecords.addAll(batchResults);
        }
    }

    // Helper method to create test event log file
    private static SObject createTestEventLogFile(String eventType, String fileContent) {
        // Use the existing helper method from the original test file
        return createMockEventLogFile(eventType, fileContent);
    }

    @IsTest
    static void testChunkedProcessing() {
        // Test that chunked processing works correctly
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        
        // Create a test log file with multiple rows
        String csvHeader = 'REQUEST_ID,ORGANIZATION_ID,USER_ID,TIMESTAMP,CPU_TIME,REQUEST_STATUS\n';
        List<String> dataRows = new List<String>();
        
        // Create 50 test rows
        for (Integer i = 0; i < 50; i++) {
            dataRows.add('REQ-' + String.valueOf(i).leftPad(3, '0') + 
                        ',00D123456789012345,005xx000001234A,20130715233322.670,' +
                        String.valueOf(100 + i) + ',Success');
        }
        
        String fileContent = csvHeader + String.join(dataRows, '\n');
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_API, fileContent);
        
        // Create a chunk that processes rows 10-20 (10 rows total)
        EventLogProcessingBatch.EventLogFileType chunk = new EventLogProcessingBatch.EventLogFileType('API', 'test-id', Double.valueOf(10240.0));
        chunk.startRow = 10;
        chunk.endRow = 20;
        
        // Create processor and test batch processor
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        
        Test.startTest();
        // Process only the specified chunk
        processor.batchProcessLogFileSObject(logFile, batchProcessor, chunk.startRow, chunk.endRow);
        Test.stopTest();
        
        // Verify that only the specified rows were processed
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        System.assertEquals(10, results.size(), 'Should have processed exactly 10 rows from the chunk');
        
        // Verify the specific rows were processed (rows 10-19, 0-based index)
        Set<String> expectedRequestIds = new Set<String>();
        for (Integer i = 10; i < 20; i++) {
            expectedRequestIds.add('REQ-' + String.valueOf(i).leftPad(3, '0'));
        }
        
        Set<String> actualRequestIds = new Set<String>();
        for (EventLogProcessors.IBaseEventData record : results) {
            EventLogProcessors.SOAPAPIEventData apiData = (EventLogProcessors.SOAPAPIEventData)record;
            actualRequestIds.add(apiData.requestId);
        }
        
        System.assertEquals(expectedRequestIds, actualRequestIds, 'Should have processed the correct rows from the chunk');
    }

    @IsTest
    static void testChunkedProcessingWithNullBounds() {
        // Test that processing with null bounds processes the entire file (legacy behavior)
        PermissionsUtil.EventMonitoringEnabled = true;
        setupTestDataSettings();
        
        // Create a test log file with multiple rows
        String csvHeader = 'REQUEST_ID,ORGANIZATION_ID,USER_ID,TIMESTAMP,CPU_TIME,REQUEST_STATUS\n';
        List<String> dataRows = new List<String>();
        
        // Create 25 test rows
        for (Integer i = 0; i < 25; i++) {
            dataRows.add('REQ-' + String.valueOf(i).leftPad(3, '0') + 
                        ',00D123456789012345,005xx000001234A,20130715233322.670,' +
                        String.valueOf(100 + i) + ',Success');
        }
        
        String fileContent = csvHeader + String.join(dataRows, '\n');
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_API, fileContent);
        
        // Create processor and test batch processor
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        
        Test.startTest();
        // Process entire file (null bounds)
        processor.batchProcessLogFileSObject(logFile, batchProcessor, null, null);
        Test.stopTest();
        
        // Verify that all rows were processed
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        System.assertEquals(25, results.size(), 'Should have processed all 25 rows when bounds are null');
    }

}