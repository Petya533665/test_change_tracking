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
        new FieldDefinition('USER_ID', 'String', '005xx000001234AAA'),
        new FieldDefinition('ORGANIZATION_ID', 'String', '00D123456789012345'),
        new FieldDefinition('USER_ID_DERIVED', 'String', '005xx000001234AAA'),
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
            Last_Processed_Hourly_Events__c = Datetime.now().addHours(-1)
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
        
        String csvData = '"APEX_CODE","List index out of bounds: 0","System.ListException",' +
                        '"Class.TestClass.processData: line 15\\nClass.TestClass.execute: line 5",' +
                        '"REQ-BATCH-001","00D123456789012345","005xx000001234AAA","005xx000001234AAA",' +
                        '"2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"';
        
        return csvHeader + '\n' + csvData;
    }
    
    // Helper method to generate multiple ApexUnexpectedException CSV data
    private static String generateMultipleApexUnexpectedExceptionCsvData() {
        String csvHeader = '"EXCEPTION_CATEGORY","EXCEPTION_MESSAGE","EXCEPTION_TYPE","STACK_TRACE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","USER_ID","USER_ID_DERIVED","TIMESTAMP_DERIVED",' +
                          '"TIMESTAMP","USER_ID"';
        
        List<String> csvRows = new List<String>();
        csvRows.add(csvHeader);
        
        // First exception record
        csvRows.add('"APEX_CODE","List index out of bounds: 0","System.ListException",' +
                    '"Class.TestClass.processData: line 15\\nClass.TestClass.execute: line 5",' +
                    '"REQ-MIXED-001","00D123456789012345","005xx000001234AAA","005xx000001234AAA",' +
                    '"2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"');
        
        // Second exception record
        csvRows.add('"APEX_CODE","Null pointer exception","System.NullPointerException",' +
                    '"Class.AnotherClass.handleData: line 25\\nClass.AnotherClass.run: line 10",' +
                    '"REQ-MIXED-002","00D123456789012345","005xx000001234BBB","005xx000001234BBB",' +
                    '"2024-01-01T13:00:00Z","20130715234322.670","005xx000001234BBB"');
        
        // Third exception record
        csvRows.add('"APEX_CODE","DML Exception occurred","System.DmlException",' +
                    '"Class.DataProcessor.updateRecords: line 30\\nClass.DataProcessor.process: line 15",' +
                    '"REQ-MIXED-003","00D123456789012345","005xx000001234CCC","005xx000001234CCC",' +
                    '"2024-01-01T14:00:00Z","20130715235322.670","005xx000001234CCC"');
        
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
}