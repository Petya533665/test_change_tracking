@IsTest(IsParallel=true)
private class EventLogProcessorsTest {
    
    private class TestBatchProcessor implements EventLogProcessors.IBatchProcessor {
        public List<EventLogProcessors.IBaseEventData> processedRecords { get; private set; }
        
        public TestBatchProcessor() {
            this.processedRecords = new List<EventLogProcessors.IBaseEventData>();
        }
        
        public void processBatchEventDataResults(List<EventLogProcessors.IBaseEventData> batchResults, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
            if (batchResults != null) {
                this.processedRecords.addAll(batchResults);
            }
        }
    }

    @IsTest
    static void testProcessBatchEventLogData() {
        // Prepare test data - example for WaveInteraction Event
        String csvHeader = 'NUM_CLICKS,NUM_SESSIONS,READ_TIME,TOTAL_TIME,RECORD_ID,' +
                          'TAB_ID,TYPE,VIEW_MODE,WAVE_SESSION_ID,WAVE_TIMESTAMP,' +
                          'CPU_TIME,RUN_TIME,CLIENT_IP,REQUEST_ID,URI,' +
                          'URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'USER_ID_DERIVED,USER_ID,TIMESTAMP\n';
        
        // Create 25 records to test batch processing
        List<String> dataRows = new List<String>();
        for(Integer i = 0; i < 25; i++) {
            String csvData = String.format(
                '"{0}","2","300","450","0FK123000000ABCD",' +
                '"TAB-789","DashboardInteraction","explore","WAVE-SESSION-123","16426944",' +
                '"1000","1500","192.168.1.1","WAVE-INT-{1}","/analytics/dashboard/01Z123000000ABCD",' +
                '"URI-1","LOGIN-ABC","SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z",' +
                '"005xx000001234AAA","005xx000001234AAA","20130715233322.670"',
                new List<Object>{i + 1, i}
            );
            dataRows.add(csvData);
        }
        
        // Create test file content
        String fileContent = csvHeader + String.join(dataRows, '\n');
        SObject logFile = createTestEventLogFile(
            EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION, 
            fileContent
        );
        
        // Create processor and test batch processor
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(
            EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION
        );
        
        // Process the test data
        Test.startTest();
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(25, results.size(), 'Should have processed all 25 records');
        System.assertEquals(25, batchProcessor.processedRecords.size(), 
            'Batch processor should have received all records');
        
        // Verify batching (should have 3 batches: 10 + 10 + 5)
        Set<String> uniqueRequestIds = new Set<String>();
        for(EventLogProcessors.IBaseEventData record : batchProcessor.processedRecords) {
            EventLogProcessors.WaveInteractionEventData waveData = 
                (EventLogProcessors.WaveInteractionEventData)record;
            uniqueRequestIds.add(waveData.requestId);
        }
        System.assertEquals(25, uniqueRequestIds.size(), 'Should have unique request IDs');
        
        // Verify data integrity of processed records
        for(Integer i = 0; i < batchProcessor.processedRecords.size(); i++) {
            EventLogProcessors.WaveInteractionEventData waveData = 
                (EventLogProcessors.WaveInteractionEventData)batchProcessor.processedRecords[i];
            
            // Verify key fields
            System.assertEquals('WAVE-INT-' + i, waveData.requestId, 
                'Request ID should match for record ' + i);
            System.assertEquals(i + 1, waveData.numClicks, 
                'Number of clicks should match for record ' + i);
            System.assertEquals('DashboardInteraction', waveData.type);
            System.assertEquals('explore', waveData.viewMode);
        }
    }

    @IsTest
    static void testSOAPAPIEventProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,API_TYPE,API_VERSION,ENTITY_NAME,METHOD_NAME,' +
                          'EXCEPTION_MESSAGE,CPU_TIME,DB_BLOCKS,DB_CPU_TIME,DB_TOTAL_TIME,' +
                          'REQUEST_SIZE,RESPONSE_SIZE,ROWS_PROCESSED,RUN_TIME,REQUEST_STATUS,' +
                          'URI,URI_ID_DERIVED,CLIENT_IP,CLIENT_NAME,USER_TYPE,' +
                          'USER_ID_DERIVED,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'REQ-123,Enterprise,54.0,Account,create,' +
                        'null,1000,50,300,800,' +
                        '2048,4096,100,1500,SUCCESS,' +
                        '/services/Soap/c/54.0/00D123,SOAP_API_1,192.168.1.1,TestApp,Standard,' +
                        '005xx000001234AAA,abc123,def456,00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_API, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.SOAPAPIEventData soapData = 
            (EventLogProcessors.SOAPAPIEventData)results[0];
        
        // Verify all fields
        System.assertEquals('REQ-123', soapData.requestId);
        System.assertEquals('Enterprise', soapData.apiType);
        System.assertEquals('54.0', soapData.apiVersion);
        System.assertEquals('Account', soapData.entityName);
        System.assertEquals('create', soapData.methodName);
        System.assertEquals('null', soapData.exceptionMessage);
        System.assertEquals(1000, soapData.cpuTime);
        System.assertEquals(50, soapData.dbBlocks);
        System.assertEquals(300, soapData.dbCpuTime);
        System.assertEquals(800, soapData.dbTotalTime);
        System.assertEquals(2048, soapData.requestSize);
        System.assertEquals(4096, soapData.responseSize);
        System.assertEquals(100, soapData.rowsProcessed);
        System.assertEquals(1500, soapData.runTime);
        System.assertEquals('SUCCESS', soapData.requestStatus);
        System.assertEquals('/services/Soap/c/54.0/00D123', soapData.uri);
        System.assertEquals('SOAP_API_1', soapData.uriIdDerived);
        System.assertEquals('192.168.1.1', soapData.clientIp);
        System.assertEquals('TestApp', soapData.clientName);
        System.assertEquals('Standard', soapData.userType);
        System.assertEquals('005xx000001234AAA', soapData.userIdDerived);
        System.assertEquals('abc123', soapData.loginKey);
        System.assertEquals('def456', soapData.sessionKey);
        System.assertEquals('00D123456789012345', soapData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), soapData.timestampDerived);
    }

    @IsTest
    static void testApexCalloutProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,USER_ID_DERIVED,METHOD,TYPE,URL,' +
                          'CPU_TIME,REQUEST_SIZE,RESPONSE_SIZE,TIME,STATUS_CODE,' +
                          'SUCCESS,URI,URI_ID_DERIVED,CLIENT_IP,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'CALLOUT-123,005xx000001234AAA,POST,REST,https://api.example.com/data,' +
                        '500,1024,2048,750,200,' +
                        '1,/apex/MyClass.makeCallout,CALLOUT_1,192.168.1.1,abc123,' +
                        'def456,00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexCalloutData calloutData = 
            (EventLogProcessors.ApexCalloutData)results[0];
        
        // Verify all fields
        System.assertEquals('CALLOUT-123', calloutData.requestId);
        System.assertEquals('005xx000001234AAA', calloutData.userIdDerived);
        System.assertEquals('POST', calloutData.method);
        System.assertEquals('REST', calloutData.type);
        System.assertEquals('https://api.example.com/data', calloutData.url);
        System.assertEquals(500, calloutData.cpuTime);
        System.assertEquals(1024, calloutData.requestSize);
        System.assertEquals(2048, calloutData.responseSize);
        System.assertEquals(750, calloutData.timeValue);
        System.assertEquals(200, calloutData.statusCode);
        System.assertEquals('1', calloutData.success);
        System.assertEquals('/apex/MyClass.makeCallout', calloutData.uri);
        System.assertEquals('CALLOUT_1', calloutData.uriIdDerived);
        System.assertEquals('192.168.1.1', calloutData.clientIp);
        System.assertEquals('abc123', calloutData.loginKey);
        System.assertEquals('def456', calloutData.sessionKey);
        System.assertEquals('00D123456789012345', calloutData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), calloutData.timestampDerived);
    }

    @IsTest
    static void testApexExecutionProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,QUIDDITY,USER_ID_DERIVED,CALLOUT_TIME,CPU_TIME,' +
                          'DB_TOTAL_TIME,EXEC_TIME,RUN_TIME,ENTRY_POINT,IS_LONG_RUNNING_REQUEST,' +
                          'NUMBER_SOQL_QUERIES,ORGANIZATION_ID,URI,URI_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,CLIENT_IP,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'APEX-123,FUTURE,005xx000001234AAA,100,2000,' +
                        '1500,3000,3500,MyClass.executeMethod,false,' +
                        '5,00D123456789012345,/apex/MyClass,APEX_EXEC_1,abc123,' +
                        'def456,192.168.1.1,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_EXECUTION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_EXECUTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexExecutionData execData = 
            (EventLogProcessors.ApexExecutionData)results[0];
        
        // Verify all fields
        System.assertEquals('APEX-123', execData.requestId);
        System.assertEquals('FUTURE', execData.quiddity);
        System.assertEquals('005xx000001234AAA', execData.userIdDerived);
        System.assertEquals(100, execData.calloutTime);
        System.assertEquals(2000, execData.cpuTime);
        System.assertEquals(1500, execData.dbTotalTime);
        System.assertEquals(3000, execData.execTime);
        System.assertEquals(3500, execData.runTime);
        System.assertEquals('MyClass.executeMethod', execData.entryPoint);
        System.assertEquals(false, execData.isLongRunningRequest);
        System.assertEquals(5, execData.numberSoqlQueries);
        System.assertEquals('00D123456789012345', execData.organizationId);
        System.assertEquals('/apex/MyClass', execData.uri);
        System.assertEquals('APEX_EXEC_1', execData.uriIdDerived);
        System.assertEquals('abc123', execData.loginKey);
        System.assertEquals('def456', execData.sessionKey);
        System.assertEquals('192.168.1.1', execData.clientIp);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), execData.timestampDerived);
    }

    @IsTest
    static void testApexRestApiEventProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,USER_ID_DERIVED,METHOD,MEDIA_TYPE,CONNECTED_APP_ID,' +
                          'ENTITY_NAME,EXCEPTION_MESSAGE,CPU_TIME,DB_BLOCKS,DB_CPU_TIME,' +
                          'DB_TOTAL_TIME,REQUEST_SIZE,RESPONSE_SIZE,ROWS_PROCESSED,RUN_TIME,' +
                          'NUMBER_FIELDS,STATUS_CODE,USER_AGENT,REQUEST_STATUS,URI,' +
                          'URI_ID_DERIVED,CLIENT_IP,CLIENT_NAME,USER_TYPE,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'REST-123,005xx000001234AAA,POST,application/json,0H0xx0000004CAp,' +
                        'Account,null,1500,75,500,' +
                        '800,1024,2048,50,2000,' +
                        '10,200,1,SUCCESS,/services/apexrest/v1/accounts,' +
                        'APEX_REST_1,192.168.1.1,TestClient,Standard,abc123,' +
                        'def456,00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_REST_API, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexRestApiEventData restData = 
            (EventLogProcessors.ApexRestApiEventData)results[0];
        
        // Verify all fields
        System.assertEquals('REST-123', restData.requestId);
        System.assertEquals('005xx000001234AAA', restData.userIdDerived);
        System.assertEquals('POST', restData.method);
        System.assertEquals('application/json', restData.mediaType);
        System.assertEquals('0H0xx0000004CAp', restData.connectedAppId);
        System.assertEquals('Account', restData.entityName);
        System.assertEquals('null', restData.exceptionMessage);
        System.assertEquals(1500, restData.cpuTime);
        System.assertEquals(75, restData.dbBlocks);
        System.assertEquals(500, restData.dbCpuTime);
        System.assertEquals(800, restData.dbTotalTime);
        System.assertEquals(1024, restData.requestSize);
        System.assertEquals(2048, restData.responseSize);
        System.assertEquals(50, restData.rowsProcessed);
        System.assertEquals(2000, restData.runTime);
        System.assertEquals(10, restData.numberFields);
        System.assertEquals(200, restData.statusCode);
        System.assertEquals(1, restData.userAgent);
        System.assertEquals('SUCCESS', restData.requestStatus);
        System.assertEquals('/services/apexrest/v1/accounts', restData.uri);
        System.assertEquals('APEX_REST_1', restData.uriIdDerived);
        System.assertEquals('192.168.1.1', restData.clientIp);
        System.assertEquals('TestClient', restData.clientName);
        System.assertEquals('Standard', restData.userType);
        System.assertEquals('abc123', restData.loginKey);
        System.assertEquals('def456', restData.sessionKey);
        System.assertEquals('00D123456789012345', restData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), restData.timestampDerived);
    }

    @IsTest
    static void testApexSOAPApiEventProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,USER_ID_DERIVED,CLASS_NAME,METHOD_NAME,QUERY,' +
                          'EVENT_TYPE,CPU_TIME,DB_TOTAL_TIME,RUN_TIME,LIMIT_USAGE_PERCENT,' +
                          'REQUEST_STATUS,URI,URI_ID_DERIVED,CLIENT_IP,CLIENT_NAME,' +
                          'USER_TYPE,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'SOAP-123,005xx000001234AAA,MyWebService,getData,SELECT Id FROM Account,' +
                        'WebService,1500,800,2000,75.5,' +
                        'SUCCESS,/services/Soap/class/MyWebService,SOAP_API_1,192.168.1.1,TestApp,' +
                        'Standard,abc123,def456,00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_SOAP, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_SOAP);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexSOAPApiEventData soapData = 
            (EventLogProcessors.ApexSOAPApiEventData)results[0];
        
        // Verify all fields
        System.assertEquals('SOAP-123', soapData.requestId);
        System.assertEquals('005xx000001234AAA', soapData.userIdDerived);
        System.assertEquals('MyWebService', soapData.className);
        System.assertEquals('getData', soapData.methodName);
        System.assertEquals('SELECT Id FROM Account', soapData.query);
        System.assertEquals('WebService', soapData.eventType);
        System.assertEquals(1500, soapData.cpuTime);
        System.assertEquals(800, soapData.dbTotalTime);
        System.assertEquals(2000, soapData.runTime);
        System.assertEquals(75.5, soapData.limitUsagePercent);
        System.assertEquals('SUCCESS', soapData.requestStatus);
        System.assertEquals('/services/Soap/class/MyWebService', soapData.uri);
        System.assertEquals('SOAP_API_1', soapData.uriIdDerived);
        System.assertEquals('192.168.1.1', soapData.clientIp);
        System.assertEquals('TestApp', soapData.clientName);
        System.assertEquals('Standard', soapData.userType);
        System.assertEquals('abc123', soapData.loginKey);
        System.assertEquals('def456', soapData.sessionKey);
        System.assertEquals('00D123456789012345', soapData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), soapData.timestampDerived);
    }

    @IsTest
    static void testApexTriggerProcessor() {
        // Prepare test data
        String csvHeader = 'TRIGGER_ID,TRIGGER_NAME,TRIGGER_TYPE,ENTITY_NAME,CPU_TIME,' +
                          'DB_TOTAL_TIME,EXEC_TIME,REQUEST_ID,REQUEST_STATUS,URI,' +
                          'URI_ID_DERIVED,CLIENT_IP,USER_TYPE,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = '01q123456789ABCD,AccountTrigger,after insert,Account,1500,' +
                        '800,2000,TRIG-123,SUCCESS,/services/data/v57.0/sobjects/Account,' +
                        'TRIGGER_1,192.168.1.1,Standard,abc123,def456,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexTriggerData triggerData = 
            (EventLogProcessors.ApexTriggerData)results[0];
        
        // Verify all fields
        System.assertEquals('01q123456789ABCD', triggerData.triggerId);
        System.assertEquals('AccountTrigger', triggerData.triggerName);
        System.assertEquals('after insert', triggerData.triggerType);
        System.assertEquals('Account', triggerData.entityName);
        System.assertEquals(1500, triggerData.cpuTime);
        System.assertEquals(800, triggerData.dbTotalTime);
        System.assertEquals(2000, triggerData.execTime);
        System.assertEquals('TRIG-123', triggerData.requestId);
        System.assertEquals('SUCCESS', triggerData.requestStatus);
        System.assertEquals('/services/data/v57.0/sobjects/Account', triggerData.uri);
        System.assertEquals('TRIGGER_1', triggerData.uriIdDerived);
        System.assertEquals('192.168.1.1', triggerData.clientIp);
        System.assertEquals('Standard', triggerData.userType);
        System.assertEquals('abc123', triggerData.loginKey);
        System.assertEquals('def456', triggerData.sessionKey);
        System.assertEquals('00D123456789012345', triggerData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), triggerData.timestampDerived);
    }

    @IsTest
    static void testApexUnexpectedExceptionProcessor() {
        // Prepare test data
        String csvHeader = 'EXCEPTION_CATEGORY,EXCEPTION_MESSAGE,EXCEPTION_TYPE,STACK_TRACE,' +
                          'REQUEST_ID,ORGANIZATION_ID,USER_ID,USER_ID_DERIVED,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'APEX_CODE,List index out of bounds: 0,System.ListException,' +
                        'Class.MyClass.processData: line 15\\nClass.MyClass.execute: line 5,' +
                        'EXC-123,00D123456789012345,005xx000001234AAA,005xx000001234AAA,' +
                        '2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApexUnexpectedExceptionData exceptionData = 
            (EventLogProcessors.ApexUnexpectedExceptionData)results[0];
        
        // Verify all fields
        System.assertEquals('APEX_CODE', exceptionData.exceptionCategory);
        System.assertEquals('List index out of bounds: 0', exceptionData.exceptionMessage);
        System.assertEquals('System.ListException', exceptionData.exceptionType);
        System.assertEquals('Class.MyClass.processData: line 15\\nClass.MyClass.execute: line 5', 
                          exceptionData.stackTrace);
        System.assertEquals('EXC-123', exceptionData.requestId);
        System.assertEquals('00D123456789012345', exceptionData.organizationId);
        System.assertEquals('005xx000001234AAA', exceptionData.userId);
        System.assertEquals('005xx000001234AAA', exceptionData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), exceptionData.timestampDerived);
    }

    @IsTest
    static void testApiTotalUsageProcessor() {
        // Prepare test data
        String csvHeader = 'API_FAMILY,API_RESOURCE,API_VERSION,CLIENT_IP,CLIENT_NAME,' +
                          'CONNECTED_APP_ID,CONNECTED_APP_NAME,HTTP_METHOD,STATUS_CODE,' +
                          'COUNTS_AGAINST_API_LIMIT,ENTITY_NAME,USER_NAME,REQUEST_ID,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'REST,/services/data,57,192.168.1.1,TestClient,' +
                        '0H0xx0000004CAp,MyConnectedApp,GET,200,' +
                        'true,Account,john.doe@example.com,API-123,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,' +
                        '20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ApiTotalUsageData apiData = 
            (EventLogProcessors.ApiTotalUsageData)results[0];
        
        // Verify all fields
        System.assertEquals('REST', apiData.apiFamily);
        System.assertEquals('/services/data', apiData.apiResource);
        System.assertEquals(57, apiData.apiVersion);
        System.assertEquals('192.168.1.1', apiData.clientIp);
        System.assertEquals('TestClient', apiData.clientName);
        System.assertEquals('0H0xx0000004CAp', apiData.connectedAppId);
        System.assertEquals('MyConnectedApp', apiData.connectedAppName);
        System.assertEquals('GET', apiData.httpMethod);
        System.assertEquals(200, apiData.statusCode);
        System.assertEquals(true, apiData.countsAgainstApiLimit);
        System.assertEquals('Account', apiData.entityName);
        System.assertEquals('john.doe@example.com', apiData.userName);
        System.assertEquals('API-123', apiData.requestId);
        System.assertEquals('00D123456789012345', apiData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), apiData.timestampDerived);
    }

    @IsTest
    static void testAsyncReportRunEventProcessor() {
        // Prepare test data
        String csvHeader = 'REPORT_ID,REPORT_ID_DERIVED,DASHBOARD_ID,AVERAGE_ROW_SIZE,ROW_COUNT,' +
                          'NUMBER_BUCKETS,NUMBER_COLUMNS,NUMBER_EXCEPTION_FILTERS,DISPLAY_TYPE,' +
                          'RENDERING_TYPE,ORIGIN,SORT,CPU_TIME,DB_TOTAL_TIME,DB_BLOCKS,' +
                          'DB_CPU_TIME,RUN_TIME,ENTITY_NAME,ORGANIZATION_ID,URI,' +
                          'URI_ID_DERIVED,REQUEST_ID,REQUEST_STATUS,CLIENT_IP,LOGIN_KEY,' +
                          'SESSION_KEY,USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '00OB0000000XXXXX,00OB0000000XXXXX,01ZB0000000YYYYY,256,1000,' +
                        '5,10,3,SUMMARY,HTML,Dashboard,ACCOUNT_NAME,2000,1500,100,' +
                        '800,3000,Account,00D123456789012345,/analytics/reportAsync/00OB0000000XXXXX,' +
                        'REPORT_1,REQ-123,SUCCESS,192.168.1.1,abc123,' +
                        'def456,005xx000001234AAA,Standard,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.AsyncReportRunEventData reportData = 
            (EventLogProcessors.AsyncReportRunEventData)results[0];
        
        // Verify all fields
        System.assertEquals('00OB0000000XXXXX', reportData.reportId);
        System.assertEquals('00OB0000000XXXXX', reportData.reportIdDerived);
        System.assertEquals('01ZB0000000YYYYY', reportData.dashboardId);
        System.assertEquals(256, reportData.averageRowSize);
        System.assertEquals(1000, reportData.rowCount);
        System.assertEquals(5, reportData.numberBuckets);
        System.assertEquals(10, reportData.numberColumns);
        System.assertEquals(3, reportData.numberExceptionFilters);
        System.assertEquals('SUMMARY', reportData.displayType);
        System.assertEquals('HTML', reportData.renderingType);
        System.assertEquals('Dashboard', reportData.origin);
        System.assertEquals('ACCOUNT_NAME', reportData.sortValue);
        System.assertEquals(2000, reportData.cpuTime);
        System.assertEquals(1500, reportData.dbTotalTime);
        System.assertEquals(100, reportData.dbBlocks);
        System.assertEquals(800, reportData.dbCpuTime);
        System.assertEquals(3000, reportData.runTime);
        System.assertEquals('Account', reportData.entityName);
        System.assertEquals('00D123456789012345', reportData.organizationId);
        System.assertEquals('/analytics/reportAsync/00OB0000000XXXXX', reportData.uri);
        System.assertEquals('REPORT_1', reportData.uriIdDerived);
        System.assertEquals('REQ-123', reportData.requestId);
        System.assertEquals('SUCCESS', reportData.requestStatus);
        System.assertEquals('192.168.1.1', reportData.clientIp);
        System.assertEquals('abc123', reportData.loginKey);
        System.assertEquals('def456', reportData.sessionKey);
        System.assertEquals('005xx000001234AAA', reportData.userIdDerived);
        System.assertEquals('Standard', reportData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), reportData.timestampDerived);
    }

    @IsTest
    static void testBlockedRedirectProcessor() {
        // Prepare test data
        String csvHeader = 'BLOCKED_URI,BLOCKED_URI_DOMAIN,REQUEST_ID,ORIGIN,REFERRER,' +
                          'MALFORMED_URL,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'https://malicious-site.com/redirect,malicious-site.com,BLOCK-123,' +
                        'https://myorg.salesforce.com,https://myorg.salesforce.com/home,' +
                        'false,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT, fileContent);
        
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.BlockedRedirectData redirectData = 
            (EventLogProcessors.BlockedRedirectData)results[0];
        
        // Verify all fields
        System.assertEquals('https://malicious-site.com/redirect', redirectData.blockedUri);
        System.assertEquals('malicious-site.com', redirectData.blockedUriDomain);
        System.assertEquals('BLOCK-123', redirectData.requestId);
        System.assertEquals('https://myorg.salesforce.com', redirectData.origin);
        System.assertEquals('https://myorg.salesforce.com/home', redirectData.referrer);
        System.assertEquals(false, redirectData.malformedUrl);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), redirectData.timestampDerived);
    }

    @IsTest
    static void testBulkApiEventProcessor() {
        // Prepare test data
        String csvHeader = 'BATCH_ID,JOB_ID,ENTITY_TYPE,OPERATION_TYPE,MESSAGE,' +
                          'CPU_TIME,ROWS_PROCESSED,RUN_TIME,NUMBER_FAILURES,SUCCESS,' +
                          'REQUEST_ID,URI,URI_ID_DERIVED,CLIENT_IP,USER_ID_DERIVED,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '751B000000XXXXX,750B000000YYYYY,Account,INSERT,Batch completed successfully,' +
                        '5000,1000,8000,0,true,' +
                        'BULK-123,/services/async/54.0/job/750B000000YYYYY/batch,BULK_API_1,192.168.1.1,005xx000001234AAA,' +
                        'abc123,def456,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_BULK_API, fileContent);
        
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_BULK_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.BulkApiEventData bulkData = 
            (EventLogProcessors.BulkApiEventData)results[0];
        
        // Verify all fields
        System.assertEquals('751B000000XXXXX', bulkData.batchId);
        System.assertEquals('750B000000YYYYY', bulkData.jobId);
        System.assertEquals('Account', bulkData.entityType);
        System.assertEquals('INSERT', bulkData.operationType);
        System.assertEquals('Batch completed successfully', bulkData.message);
        System.assertEquals(5000, bulkData.cpuTime);
        System.assertEquals(1000, bulkData.rowsProcessed);
        System.assertEquals(8000, bulkData.runTime);
        System.assertEquals(0, bulkData.numberFailures);
        System.assertEquals(true, bulkData.success);
        System.assertEquals('BULK-123', bulkData.requestId);
        System.assertEquals('/services/async/54.0/job/750B000000YYYYY/batch', bulkData.uri);
        System.assertEquals('BULK_API_1', bulkData.uriIdDerived);
        System.assertEquals('192.168.1.1', bulkData.clientIp);
        System.assertEquals('005xx000001234AAA', bulkData.userIdDerived);
        System.assertEquals('abc123', bulkData.loginKey);
        System.assertEquals('def456', bulkData.sessionKey);
        System.assertEquals('00D123456789012345', bulkData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), bulkData.timestampDerived);
    }

    @IsTest
    static void testAuraRequestProcessor() {
        // Prepare test data
        String csvHeader = 'ACTION_MESSAGE,REQUEST_ID,REQUEST_METHOD,REQUEST_STATUS,CPU_TIME,' +
                          'DB_TOTAL_TIME,RUN_TIME,URI,URI_ID_DERIVED,CLIENT_IP,' +
                          'USER_AGENT,USER_ID_DERIVED,USER_TYPE,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'aura://ComponentController/ACTION$getComponent,AURA-123,POST,SUCCESS,1500,' +
                        '800,2000,/aura,AURA_REQUEST_1,192.168.1.1,' +
                        '1,005xx000001234AAA,Standard,abc123,def456,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_AURA_REQUEST, fileContent);
        
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_AURA_REQUEST);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.AuraRequestData auraData = 
            (EventLogProcessors.AuraRequestData)results[0];
        
        // Verify all fields
        System.assertEquals('aura://ComponentController/ACTION$getComponent', auraData.actionMessage);
        System.assertEquals('AURA-123', auraData.requestId);
        System.assertEquals('POST', auraData.requestMethod);
        System.assertEquals('SUCCESS', auraData.requestStatus);
        System.assertEquals(1500, auraData.cpuTime);
        System.assertEquals(800, auraData.dbTotalTime);
        System.assertEquals(2000, auraData.runTime);
        System.assertEquals('/aura', auraData.uri);
        System.assertEquals('AURA_REQUEST_1', auraData.uriIdDerived);
        System.assertEquals('192.168.1.1', auraData.clientIp);
        System.assertEquals(1, auraData.userAgent);
        System.assertEquals('005xx000001234AAA', auraData.userIdDerived);
        System.assertEquals('Standard', auraData.userType);
        System.assertEquals('abc123', auraData.loginKey);
        System.assertEquals('def456', auraData.sessionKey);
        System.assertEquals('00D123456789012345', auraData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), auraData.timestampDerived);
    }

    @IsTest
    static void testBulkApiRequestProcessor() {
        // Prepare test data
        String csvHeader = 'API_VERSION,CONCURRENCY_MODE,BATCH_ID,JOB_ID,OPERATION_TYPE,' +
                          'ERROR_MESSAGE,REQUEST_ID,REQUEST_PATH,STATUS_CODE,SUCCESS,' +
                          'CPU_TIME,RUN_TIME,CLIENT_IP,CLIENT_NAME,CONNECTED_APP_ID,' +
                          'URI,URI_ID_DERIVED,USER_ID_DERIVED,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '54,Parallel,751B000000XXXXX,750B000000YYYYY,INSERT,' +
                        'null,BULK-123,/services/async/v54.0/job,200,true,' +
                        '1500,3000,192.168.1.1,BulkDataLoader,0H0xx0000004CAp,' +
                        '/services/async/54.0/job/750B000000YYYYY,BULK_REQ_1,005xx000001234AAA,' +
                        'abc123,def456,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST, fileContent);
        
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.BulkApiRequestData bulkRequestData = 
            (EventLogProcessors.BulkApiRequestData)results[0];
        
        // Verify all fields
        System.assertEquals(54, bulkRequestData.apiVersion);
        System.assertEquals('Parallel', bulkRequestData.concurrencyMode);
        System.assertEquals('751B000000XXXXX', bulkRequestData.batchId);
        System.assertEquals('750B000000YYYYY', bulkRequestData.jobId);
        System.assertEquals('INSERT', bulkRequestData.operationType);
        System.assertEquals('null', bulkRequestData.errorMessage);
        System.assertEquals('BULK-123', bulkRequestData.requestId);
        System.assertEquals('/services/async/v54.0/job', bulkRequestData.requestPath);
        System.assertEquals(200, bulkRequestData.statusCode);
        System.assertEquals(true, bulkRequestData.success);
        System.assertEquals(1500, bulkRequestData.cpuTime);
        System.assertEquals(3000, bulkRequestData.runTime);
        System.assertEquals('192.168.1.1', bulkRequestData.clientIp);
        System.assertEquals('BulkDataLoader', bulkRequestData.clientName);
        System.assertEquals('0H0xx0000004CAp', bulkRequestData.connectedAppId);
        System.assertEquals('/services/async/54.0/job/750B000000YYYYY', bulkRequestData.uri);
        System.assertEquals('BULK_REQ_1', bulkRequestData.uriIdDerived);
        System.assertEquals('005xx000001234AAA', bulkRequestData.userIdDerived);
        System.assertEquals('abc123', bulkRequestData.loginKey);
        System.assertEquals('def456', bulkRequestData.sessionKey);
        System.assertEquals('00D123456789012345', bulkRequestData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), bulkRequestData.timestampDerived);
    }

    @IsTest
    static void testBulkApi2Processor() {
        // Prepare test data
        String csvHeader = 'JOB_ID,JOB_STATUS,ENTITY_TYPE,OPERATION_TYPE,CPU_TIME,' +
                          'RUN_TIME,RECORDS_PROCESSED,RECORDS_FAILED,RESULT_SIZE_MB,REQUEST_ID,' +
                          'URI,URI_ID_DERIVED,CLIENT_IP,USER_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '750B000000YYYYY,Completed,Account,INSERT,5000,' +
                        '8000,1000,5,25,BULK2-123,' +
                        '/services/data/v57.0/jobs/ingest/750B000000YYYYY,BULK2_JOB_1,192.168.1.1,005xx000001234AAA,abc123,' +
                        'def456,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_BULK_API_2, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_BULK_API_2);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.BulkApi2Data bulk2Data = 
            (EventLogProcessors.BulkApi2Data)results[0];
        
        // Verify all fields
        System.assertEquals('750B000000YYYYY', bulk2Data.jobId);
        System.assertEquals('Completed', bulk2Data.jobStatus);
        System.assertEquals('Account', bulk2Data.entityType);
        System.assertEquals('INSERT', bulk2Data.operationType);
        System.assertEquals(5000, bulk2Data.cpuTime);
        System.assertEquals(8000, bulk2Data.runTime);
        System.assertEquals(1000, bulk2Data.recordsProcessed);
        System.assertEquals(5, bulk2Data.recordsFailed);
        System.assertEquals(25, bulk2Data.resultSizeMb);
        System.assertEquals('BULK2-123', bulk2Data.requestId);
        System.assertEquals('/services/data/v57.0/jobs/ingest/750B000000YYYYY', bulk2Data.uri);
        System.assertEquals('BULK2_JOB_1', bulk2Data.uriIdDerived);
        System.assertEquals('192.168.1.1', bulk2Data.clientIp);
        System.assertEquals('005xx000001234AAA', bulk2Data.userIdDerived);
        System.assertEquals('abc123', bulk2Data.loginKey);
        System.assertEquals('def456', bulk2Data.sessionKey);
        System.assertEquals('00D123456789012345', bulk2Data.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), bulk2Data.timestampDerived);
    }

    @IsTest
    static void testChangeSetOperationProcessor() {
        // Prepare test data
        String csvHeader = 'CHANGE_SET_NAME,OPERATION,TARGET_ORG_ID,CPU_TIME,RUN_TIME,' +
                          'REQUEST_ID,URI,URI_ID_DERIVED,CLIENT_IP,USER_ID_DERIVED,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'Release_2024_01,Upload,00D987654321098765,1500,3000,' +
                        'CS-123,/changeSet/Release_2024_01,CHANGE_SET_1,192.168.1.1,005xx000001234AAA,' +
                        'abc123,def456,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ChangeSetOperationData changeSetData = 
            (EventLogProcessors.ChangeSetOperationData)results[0];
        
        // Verify all fields
        System.assertEquals('Release_2024_01', changeSetData.changeSetName);
        System.assertEquals('Upload', changeSetData.operation);
        System.assertEquals('00D987654321098765', changeSetData.targetOrgId);
        System.assertEquals(1500, changeSetData.cpuTime);
        System.assertEquals(3000, changeSetData.runTime);
        System.assertEquals('CS-123', changeSetData.requestId);
        System.assertEquals('/changeSet/Release_2024_01', changeSetData.uri);
        System.assertEquals('CHANGE_SET_1', changeSetData.uriIdDerived);
        System.assertEquals('192.168.1.1', changeSetData.clientIp);
        System.assertEquals('005xx000001234AAA', changeSetData.userIdDerived);
        System.assertEquals('abc123', changeSetData.loginKey);
        System.assertEquals('def456', changeSetData.sessionKey);
        System.assertEquals('00D123456789012345', changeSetData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), changeSetData.timestampDerived);
    }

    @IsTest
    static void testConcurrentLongRunningApexLimitProcessor() {
        // Prepare test data
        String csvHeader = 'NUMBER_REQUESTS,REQUESTS_LIMIT,REQUEST_ID,REQUEST_URI,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '8,10,APEX-123,/apex/LongRunningPage,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';                 // Org & Timestamp
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ConcurrentLongRunningApexLimitData limitData = 
            (EventLogProcessors.ConcurrentLongRunningApexLimitData)results[0];
        
        // Verify all fields
        System.assertEquals(8, limitData.numberRequests);
        System.assertEquals(10, limitData.requestsLimit);
        System.assertEquals('APEX-123', limitData.requestId);
        System.assertEquals('/apex/LongRunningPage', limitData.requestUri);
        System.assertEquals('00D123456789012345', limitData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), limitData.timestampDerived);
    }

    @IsTest
    static void testConsoleEventProcessor() {
        // Prepare test data
        String csvHeader = 'CONSOLE_ID,CONSOLE_ID_DERIVED,LICENSE_CONTEXT,COMPONENT_ID,COMPONENT_ID_DERIVED,' +
                          'RECORD_ID,RECORD_ID_DERIVED,CPU_TIME,DB_TOTAL_TIME,RUN_TIME,' +
                          'REQUEST_ID,REQUEST_STATUS,URI,URI_ID_DERIVED,CLIENT_IP,' +
                          'USER_ID_DERIVED,USER_TYPE,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,' +
                          'TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '2F0xx0000004CAp,ServiceConsole,Service_Cloud,1FC3x000000XXXXX,CustomComponent,' +
                        '001xx000003YYYYY,Account.001xx000003YYYYY,1500,800,2000,' +
                        'CONSOLE-123,SUCCESS,/console/jsp/runtime_sales,CONSOLE_1,192.168.1.1,' +
                        '005xx000001234AAA,Standard,abc123,def456,00D123456789012345,' +
                        '2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONSOLE, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONSOLE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ConsoleEventData consoleData = 
            (EventLogProcessors.ConsoleEventData)results[0];
        
        // Verify all fields
        System.assertEquals('2F0xx0000004CAp', consoleData.consoleId);
        System.assertEquals('ServiceConsole', consoleData.consoleIdDerived);
        System.assertEquals('Service_Cloud', consoleData.licenseContext);
        System.assertEquals('1FC3x000000XXXXX', consoleData.componentId);
        System.assertEquals('CustomComponent', consoleData.componentIdDerived);
        System.assertEquals('001xx000003YYYYY', consoleData.recordId);
        System.assertEquals('Account.001xx000003YYYYY', consoleData.recordIdDerived);
        System.assertEquals(1500, consoleData.cpuTime);
        System.assertEquals(800, consoleData.dbTotalTime);
        System.assertEquals(2000, consoleData.runTime);
        System.assertEquals('CONSOLE-123', consoleData.requestId);
        System.assertEquals('SUCCESS', consoleData.requestStatus);
        System.assertEquals('/console/jsp/runtime_sales', consoleData.uri);
        System.assertEquals('CONSOLE_1', consoleData.uriIdDerived);
        System.assertEquals('192.168.1.1', consoleData.clientIp);
        System.assertEquals('005xx000001234AAA', consoleData.userIdDerived);
        System.assertEquals('Standard', consoleData.userType);
        System.assertEquals('abc123', consoleData.loginKey);
        System.assertEquals('def456', consoleData.sessionKey);
        System.assertEquals('00D123456789012345', consoleData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), consoleData.timestampDerived);
    }

    @IsTest
    static void testContentDistributionProcessor() {
        // Prepare test data
        String csvHeader = 'DELIVERY_ID,DELIVERY_LOCATION,VERSION_ID,ACTION,RELATED_ENTITY_ID,' +
                          'REQUEST_ID,USER_ID_DERIVED,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '068xx000001YYYYY,/sfc/dist/version/renditionDownload,069xx000002ZZZZZ,download,001xx000003XXXXX,' +
                        'DIST-123,005xx000001234AAA,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ContentDistributionData distributionData = 
            (EventLogProcessors.ContentDistributionData)results[0];
        
        // Verify all fields
        System.assertEquals('068xx000001YYYYY', distributionData.deliveryId);
        System.assertEquals('/sfc/dist/version/renditionDownload', distributionData.deliveryLocation);
        System.assertEquals('069xx000002ZZZZZ', distributionData.versionId);
        System.assertEquals('download', distributionData.action);
        System.assertEquals('001xx000003XXXXX', distributionData.relatedEntityId);
        System.assertEquals('DIST-123', distributionData.requestId);
        System.assertEquals('005xx000001234AAA', distributionData.userIdDerived);
        System.assertEquals('00D123456789012345', distributionData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), distributionData.timestampDerived);
    }

    @IsTest
    static void testContentDocumentLinkProcessor() {
        // Prepare test data
        String csvHeader = 'DOCUMENT_ID,SHARED_WITH_ENTITY_ID,SHARING_OPERATION,SHARING_PERMISSION,' +
                          'REQUEST_ID,USER_ID_DERIVED,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '069xx000001YYYYY,001xx000002ZZZZZ,INSERT,ViewOnly,' +
                        'LINK-123,005xx000001234AAA,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ContentDocumentLinkData linkData = 
            (EventLogProcessors.ContentDocumentLinkData)results[0];
        
        // Verify all fields
        System.assertEquals('069xx000001YYYYY', linkData.documentId);
        System.assertEquals('001xx000002ZZZZZ', linkData.sharedWithEntityId);
        System.assertEquals('INSERT', linkData.sharingOperation);
        System.assertEquals('ViewOnly', linkData.sharingPermission);
        System.assertEquals('LINK-123', linkData.requestId);
        System.assertEquals('005xx000001234AAA', linkData.userIdDerived);
        System.assertEquals('00D123456789012345', linkData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), linkData.timestampDerived);
    }

    @IsTest
    static void testContentTransferProcessor() {
        // Prepare test data
        String csvHeader = 'DOCUMENT_ID,DOCUMENT_ID_DERIVED,VERSION_ID,VERSION_ID_DERIVED,' +
                          'FILE_TYPE,FILE_PREVIEW_TYPE,SIZE_BYTES,TRANSACTION_TYPE,' +
                          'REQUEST_ID,USER_ID_DERIVED,ORGANIZATION_ID,EVENT_TYPE,' +
                          'TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '069xx000001YYYYY,SalesPresentation.pdf,068xx000002ZZZZZ,v2,' +
                        'PDF,THUMB_720,1048576,UPLOAD,' +
                        'TRANSFER-123,005xx000001234AAA,00D123456789012345,Content_Transfer,' +
                        '2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ContentTransferData transferData = 
            (EventLogProcessors.ContentTransferData)results[0];
        
        // Verify all fields
        System.assertEquals('069xx000001YYYYY', transferData.documentId);
        System.assertEquals('SalesPresentation.pdf', transferData.documentIdDerived);
        System.assertEquals('068xx000002ZZZZZ', transferData.versionId);
        System.assertEquals('v2', transferData.versionIdDerived);
        System.assertEquals('PDF', transferData.fileType);
        System.assertEquals('THUMB_720', transferData.filePreviewType);
        System.assertEquals(1048576, transferData.sizeBytes);
        System.assertEquals('UPLOAD', transferData.transactionType);
        System.assertEquals('TRANSFER-123', transferData.requestId);
        System.assertEquals('005xx000001234AAA', transferData.userIdDerived);
        System.assertEquals('00D123456789012345', transferData.organizationId);
        System.assertEquals('Content_Transfer', transferData.eventType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), transferData.timestampDerived);
    }

    @IsTest
    static void testContinuationCalloutSummaryProcessor() {
        // Prepare test data
        String csvHeader = 'CONTINUATION_ID,DURATION,SUCCESS,ORIGIN_REQUEST_ID,REQUEST_ID,' +
                          'REQUEST_FORM_SIZE,RESPONSE_SIZE,VF_CONTROLLER_SIZE,STATUS_CODE,URL,' +
                          'USER_ID_DERIVED,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '07Lxx000000XXXXX,1500,true,ORIG-123,CONT-456,' +
                        '2048,4096,1024,200,https://api.example.com/data,' +
                        '005xx000001234AAA,00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ContinuationCalloutSummaryData continuationData = 
            (EventLogProcessors.ContinuationCalloutSummaryData)results[0];
        
        // Verify all fields
        System.assertEquals('07Lxx000000XXXXX', continuationData.continuationId);
        System.assertEquals(1500, continuationData.duration);
        System.assertEquals(true, continuationData.success);
        System.assertEquals('ORIG-123', continuationData.originRequestId);
        System.assertEquals('CONT-456', continuationData.requestId);
        System.assertEquals('2048', continuationData.requestFormSize);
        System.assertEquals('4096', continuationData.responseSize);
        System.assertEquals('1024', continuationData.vfControllerSize);
        System.assertEquals('200', continuationData.statusCode);
        System.assertEquals('https://api.example.com/data', continuationData.url);
        System.assertEquals('005xx000001234AAA', continuationData.userIdDerived);
        System.assertEquals('00D123456789012345', continuationData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), continuationData.timestampDerived);
    }

    @IsTest
    static void testCorsViolationProcessor() {
        // Prepare test data
        String csvHeader = 'HOST,ORIGIN,REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'myorg.salesforce.com,https://unauthorized-domain.com,CORS-123,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CORS_VIOLATION, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CORS_VIOLATION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.CorsViolationData corsData = 
            (EventLogProcessors.CorsViolationData)results[0];
        
        // Verify all fields
        System.assertEquals('myorg.salesforce.com', corsData.host);
        System.assertEquals('https://unauthorized-domain.com', corsData.origin);
        System.assertEquals('CORS-123', corsData.requestId);
        System.assertEquals('00D123456789012345', corsData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), corsData.timestampDerived);
    }

    @IsTest
    static void testCspViolationProcessor() {
        // Prepare test data
        String csvHeader = 'BLOCKED_URI,BLOCKED_URI_DOMAIN,COLUMN_NUMBER,LINE_NUMBER,CONTEXT,' +
                          'DIRECTIVE,DISPOSITION,SOURCE,SOURCE_FILE,RESOURCE_SAMPLE,' +
                          'REQUEST_ID,EVENT_TYPE,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'https://unsafe-site.com/script.js,unsafe-site.com,45,123,inline,' +
                        'script-src,enforce,inline-script,/apex/MyPage.page,<script>alert();</script>,' +
                        'CSP-123,Content_Security_Policy,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_CSP_VIOLATION, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_CSP_VIOLATION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.CspViolationData cspData = 
            (EventLogProcessors.CspViolationData)results[0];
        
        // Verify all fields
        System.assertEquals('https://unsafe-site.com/script.js', cspData.blockedUri);
        System.assertEquals('unsafe-site.com', cspData.blockedUriDomain);
        System.assertEquals(45, cspData.columnNumber);
        System.assertEquals(123, cspData.lineNumber);
        System.assertEquals('inline', cspData.context);
        System.assertEquals('script-src', cspData.directive);
        System.assertEquals('enforce', cspData.disposition);
        System.assertEquals('inline-script', cspData.source);
        System.assertEquals('/apex/MyPage.page', cspData.sourceFile);
        System.assertEquals('<script>alert();</script>', cspData.resourceSample);
        System.assertEquals('CSP-123', cspData.requestId);
        System.assertEquals('Content_Security_Policy', cspData.eventType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), cspData.timestampDerived);
    }

    @IsTest
    static void testDashboardEventProcessor() {
        // Prepare test data
        String csvHeader = 'DASHBOARD_ID,DASHBOARD_ID_DERIVED,DASHBOARD_COMPONENT_ID,DASHBOARD_TYPE,' +
                          'REPORT_ID,REPORT_ID_DERIVED,IS_SCHEDULED,IS_SUCCESS,' +
                          'CPU_TIME,RUN_TIME,REQUEST_ID,URI,URI_ID_DERIVED,' +
                          'USER_ID_DERIVED,VIEWING_USER_ID,LOGIN_KEY,SESSION_KEY,CLIENT_IP,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '01ZB000000XXXXX,Sales_Performance,01YB000000YYYYY,Dynamic,' +
                        '00OB000000ZZZZZ,Monthly_Revenue,false,true,' +
                        '2000,3500,DASH-123,/analytics/dashboard/01ZB000000XXXXX,DASHBOARD_1,' +
                        '005xx000001234AAA,005xx000001235BBB,abc123,def456,192.168.1.1,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_DASHBOARD, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_DASHBOARD);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.DashboardEventData dashboardData = 
            (EventLogProcessors.DashboardEventData)results[0];
        
        // Verify all fields
        System.assertEquals('01ZB000000XXXXX', dashboardData.dashboardId);
        System.assertEquals('Sales_Performance', dashboardData.dashboardIdDerived);
        System.assertEquals('01YB000000YYYYY', dashboardData.dashboardComponentId);
        System.assertEquals('Dynamic', dashboardData.dashboardType);
        System.assertEquals('00OB000000ZZZZZ', dashboardData.reportId);
        System.assertEquals('Monthly_Revenue', dashboardData.reportIdDerived);
        System.assertEquals(false, dashboardData.isScheduled);
        System.assertEquals(true, dashboardData.isSuccess);
        System.assertEquals(2000, dashboardData.cpuTime);
        System.assertEquals(3500, dashboardData.runTime);
        System.assertEquals('DASH-123', dashboardData.requestId);
        System.assertEquals('/analytics/dashboard/01ZB000000XXXXX', dashboardData.uri);
        System.assertEquals('DASHBOARD_1', dashboardData.uriIdDerived);
        System.assertEquals('005xx000001234AAA', dashboardData.userIdDerived);
        System.assertEquals('005xx000001235BBB', dashboardData.viewingUserId);
        System.assertEquals('abc123', dashboardData.loginKey);
        System.assertEquals('def456', dashboardData.sessionKey);
        System.assertEquals('192.168.1.1', dashboardData.clientIp);
        System.assertEquals('00D123456789012345', dashboardData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), dashboardData.timestampDerived);
    }

    @IsTest
    static void testDatabaseSaveEventProcessor() {
        // Prepare test data
        String csvHeader = 'DML_TYPE,KEY_PREFIX,FIRST_ENTITY_ID,NUM_ROWS,SAMPLE_FACTOR,' +
                          'LOGIN_KEY,SESSION_KEY,REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = 'INSERT,001,001xx000003XXXXX,100,1.0,' +
                        'abc123,def456,DML-123,00D123456789012345,' +
                        '2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_DATABASE_SAVE, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_DATABASE_SAVE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.DatabaseSaveEventData dmlData = 
            (EventLogProcessors.DatabaseSaveEventData)results[0];
        
        // Verify all fields
        System.assertEquals('INSERT', dmlData.dmlType);
        System.assertEquals('001', dmlData.keyPrefix);
        System.assertEquals('001xx000003XXXXX', dmlData.firstEntityId);
        System.assertEquals(100, dmlData.numRows);
        System.assertEquals(1.0, dmlData.sampleFactor);
        System.assertEquals('abc123', dmlData.loginKey);
        System.assertEquals('def456', dmlData.sessionKey);
        System.assertEquals('DML-123', dmlData.requestId);
        System.assertEquals('00D123456789012345', dmlData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), dmlData.timestampDerived);
    }

    @IsTest
    static void testDocumentAttachmentDownloadsProcessor() {
        // Prepare test data
        String csvHeader = 'ENTITY_ID,FILE_TYPE,REQUEST_ID,USER_ID_DERIVED,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '00Pxx000001XXXXX,PDF,DOWNLOAD-123,005xx000001234AAA,' +
                        '00D123456789012345,2024-01-01T12:00:00Z,20130715233322.670,005xx000001234AAA\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.DocumentAttachmentDownloadsData downloadData = 
            (EventLogProcessors.DocumentAttachmentDownloadsData)results[0];
        
        // Verify all fields
        System.assertEquals('00Pxx000001XXXXX', downloadData.entityId);
        System.assertEquals('PDF', downloadData.fileType);
        System.assertEquals('DOWNLOAD-123', downloadData.requestId);
        System.assertEquals('005xx000001234AAA', downloadData.userIdDerived);
        System.assertEquals('00D123456789012345', downloadData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), downloadData.timestampDerived);
    }

    @IsTest
    static void testExternalCustomApexCalloutProcessor() {
        // Prepare test data
        String csvHeader = '"ACTION","ENTITY","EXECUTE_MS","FETCH_MS","TOTAL_MS",' +
                          '"THROUGHPUT","FILTER","LIMIT","OFFSET","ORDER_BY",' +
                          '"SELECT","SUBQUERIES","ROWS","ROWS_FETCHED","STATUS","MESSAGE",' +
                          '"REQUEST_ID","ORGANIZATION_ID","TIMESTAMP_DERIVED","TIMESTAMP","USER_ID"\n';
                          
        String csvData = '"query","Account","150","300","450",' +
                        '"1000.50","Name LIKE \'%Test%\'","100","0","Name ASC",' +
                        '"Id,Name,Phone","2","500","450","true","Success",' +
                        '"CALLOUT-123","00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ExternalCustomApexCalloutData calloutData = 
            (EventLogProcessors.ExternalCustomApexCalloutData)results[0];
        
        // Verify all fields
        System.assertEquals('query', calloutData.action);
        System.assertEquals('Account', calloutData.entity);
        System.assertEquals(150, calloutData.executeMs);
        System.assertEquals(300, calloutData.fetchMs);
        System.assertEquals(450, calloutData.totalMs);
        System.assertEquals(1000.50, calloutData.throughput);
        System.assertEquals('Name LIKE \'%Test%\'', calloutData.filter);
        System.assertEquals(100, calloutData.limitValue);
        System.assertEquals(0, calloutData.offset);
        System.assertEquals('Name ASC', calloutData.orderBy);
        System.assertEquals('Id,Name,Phone', calloutData.selectValue);
        System.assertEquals(2, calloutData.subqueries);
        System.assertEquals(500, calloutData.rows);
        System.assertEquals(450, calloutData.rowsFetched);
        System.assertEquals(true, calloutData.status);
        System.assertEquals('Success', calloutData.message);
        System.assertEquals('CALLOUT-123', calloutData.requestId);
        System.assertEquals('00D123456789012345', calloutData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), calloutData.timestampDerived);
    }

    @IsTest
    static void testExternalCrossOrgCalloutProcessor() {
        // Prepare test data
        String csvHeader = 'ACTION,ENTITY,EXECUTE_MS,FETCH_MS,TOTAL_MS,' +
                          'THROUGHPUT,FILTER,LIMIT,OFFSET,ORDER_BY,' +
                          'SELECT,SUBQUERIES,MESSAGE,ROWS,ROWS_FETCHED,' +
                          'STATUS,USING_MRU,REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"query","Contact","200","400","600",' +
                        '"850.75","Email LIKE \'%.com\'","200","50","LastName ASC",' +
                        '"Id,FirstName,LastName,Email","1","Success","1000","950",' +
                        '"true","true","CROSSORG-123","00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ExternalCrossOrgCalloutData calloutData = 
            (EventLogProcessors.ExternalCrossOrgCalloutData)results[0];
        
        // Verify all fields
        System.assertEquals('query', calloutData.action);
        System.assertEquals('Contact', calloutData.entity);
        System.assertEquals(200, calloutData.executeMs);
        System.assertEquals(400, calloutData.fetchMs);
        System.assertEquals(600, calloutData.totalMs);
        System.assertEquals(850.75, calloutData.throughput);
        System.assertEquals('Email LIKE \'%.com\'', calloutData.filter);
        System.assertEquals(200, calloutData.limitValue);
        System.assertEquals(50, calloutData.offset);
        System.assertEquals('LastName ASC', calloutData.orderBy);
        System.assertEquals('Id,FirstName,LastName,Email', calloutData.selectValue);
        System.assertEquals(1, calloutData.subqueries);
        System.assertEquals('Success', calloutData.message);
        System.assertEquals(1000, calloutData.rows);
        System.assertEquals(950, calloutData.rowsFetched);
        System.assertEquals(true, calloutData.status);
        System.assertEquals(true, calloutData.usingMru);
        System.assertEquals('CROSSORG-123', calloutData.requestId);
        System.assertEquals('00D123456789012345', calloutData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), calloutData.timestampDerived);
    }

    @IsTest
    static void testExternalDataSourceCalloutProcessor() {
        // Prepare test data
        String csvHeader = 'DATA_SOURCE_NAME,PROVIDER_TYPE,EXTERNAL_OBJECT,TABLE_NAME,ACTION,' +
                          'OPERATION,FILTER,SELECT,ORDER_BY,SEARCH,LIMIT,OFFSET,' +
                          'FETCH_MS,TOTAL_MS,RESPONSE_SIZE,THROUGHPUT,ROWS_FETCHED,' +
                          'STATUS,STATUS_CODE,MESSAGE,NEXT_LINK,PARENT_CALLOUT,' +
                          'REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"External_SQL","OData","Customer","customers","query",' +
                        '"READ","Name eq \'Test\'","Id,Name,Email","Name ASC","Test",100,50,' +
                        '"300","500","15360","1024.50","75",' +
                        '"true","200","Success","/next-page","PARENT-456",' +
                        '"EDS-123","00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ExternalDataSourceCalloutData calloutData = 
            (EventLogProcessors.ExternalDataSourceCalloutData)results[0];
        
        // Verify all fields
        System.assertEquals('External_SQL', calloutData.dataSourceName);
        System.assertEquals('OData', calloutData.providerType);
        System.assertEquals('Customer', calloutData.externalObject);
        System.assertEquals('customers', calloutData.tableName);
        System.assertEquals('query', calloutData.action);
        System.assertEquals('READ', calloutData.operation);
        System.assertEquals('Name eq \'Test\'', calloutData.filter);
        System.assertEquals('Id,Name,Email', calloutData.selectValue);
        System.assertEquals('Name ASC', calloutData.orderBy);
        System.assertEquals('Test', calloutData.search);
        System.assertEquals(100, calloutData.limitValue);
        System.assertEquals(50, calloutData.offset);
        System.assertEquals(300, calloutData.fetchMs);
        System.assertEquals(500, calloutData.totalMs);
        System.assertEquals(15360, calloutData.responseSize);
        System.assertEquals(1024.50, calloutData.throughput);
        System.assertEquals(75, calloutData.rowsFetched);
        System.assertEquals(true, calloutData.status);
        System.assertEquals(200, calloutData.statusCode);
        System.assertEquals('Success', calloutData.message);
        System.assertEquals('/next-page', calloutData.nextLink);
        System.assertEquals('PARENT-456', calloutData.parentCallout);
        System.assertEquals('EDS-123', calloutData.requestId);
        System.assertEquals('00D123456789012345', calloutData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), calloutData.timestampDerived);
    }

    @IsTest
    static void testExternalODataCalloutProcessor() {
        // Prepare test data
        String csvHeader = 'ACTION,BYTES,ENTITY,EXECUTE_MS,FETCH_MS,TOTAL_MS,' +
                          'THROUGHPUT,EXPAND,FILTER,LIBRARY,LIMIT,NEXT_LINK,' +
                          'OFFSET,ORDER_BY,SEARCH,SELECT,PROVIDER_TYPE,' +
                          'RATE_LIMIT_USAGE_PERCENT,MESSAGE,ROWS,ROWS_FETCHED,' +
                          'STATUS,REQUESTS,PARENT_CALLOUT,REQUEST_ID,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"query","15360","Account","200","300","500",' +
                        '"1024.50","contacts","Name eq \'Test\'","SharePoint","100","/next-page",' +
                        '"50","Name ASC","Test","Id,Name,Email","SharePoint365",' +
                        '"75","Success","1000","950",' +
                        '"true","5","PARENT-456","ODATA-123",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ExternalODataCalloutData calloutData = 
            (EventLogProcessors.ExternalODataCalloutData)results[0];
        
        // Verify all fields
        System.assertEquals('query', calloutData.action);
        System.assertEquals(15360, calloutData.bytes);
        System.assertEquals('Account', calloutData.entity);
        System.assertEquals(200, calloutData.executeMs);
        System.assertEquals(300, calloutData.fetchMs);
        System.assertEquals(500, calloutData.totalMs);
        System.assertEquals(1024.50, calloutData.throughput);
        System.assertEquals('contacts', calloutData.expand);
        System.assertEquals('Name eq \'Test\'', calloutData.filter);
        System.assertEquals('SharePoint', calloutData.library);
        System.assertEquals(100, calloutData.limitValue);
        System.assertEquals('/next-page', calloutData.nextLink);
        System.assertEquals(50, calloutData.offset);
        System.assertEquals('Name ASC', calloutData.orderBy);
        System.assertEquals('Test', calloutData.search);
        System.assertEquals('Id,Name,Email', calloutData.selectValue);
        System.assertEquals('SharePoint365', calloutData.providerType);
        System.assertEquals(75, calloutData.rateLimitUsagePercent);
        System.assertEquals('Success', calloutData.message);
        System.assertEquals(1000, calloutData.rows);
        System.assertEquals(950, calloutData.rowsFetched);
        System.assertEquals(true, calloutData.status);
        System.assertEquals(5, calloutData.requests);
        System.assertEquals('PARENT-456', calloutData.parentCallout);
        System.assertEquals('ODATA-123', calloutData.requestId);
        System.assertEquals('00D123456789012345', calloutData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), calloutData.timestampDerived);
    }

    @IsTest
    static void testFlowExecutionEventProcessor() {
        // Prepare test data
        String csvHeader = 'PROCESS_TYPE,FLOW_VERSION_ID,FLOW_LOAD_TIME,TOTAL_EXECUTION_TIME,' +
                          'NUMBER_OF_INTERVIEWS,NUMBER_OF_ERRORS,REQUEST_ID,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"Flow","301xx000000001AAA","150","2500",' +
                        '"5","1","FLOW-123",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';             // Org & Timestamp
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.FlowExecutionEventData flowData = 
            (EventLogProcessors.FlowExecutionEventData)results[0];
        
        // Verify all fields
        System.assertEquals('Flow', flowData.processType);
        System.assertEquals('301xx000000001AAA', flowData.flowVersionId);
        System.assertEquals(150, flowData.flowLoadTime);
        System.assertEquals(2500, flowData.totalExecutionTime);
        System.assertEquals(5, flowData.numberOfInterviews);
        System.assertEquals(1, flowData.numberOfErrors);
        System.assertEquals('FLOW-123', flowData.requestId);
        System.assertEquals('00D123456789012345', flowData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), flowData.timestampDerived);
    }

    @IsTest
    static void testGroupMembershipProcessor() {
        // Prepare test data
        String csvHeader = 'CLIENT_IP,CPU_TIME,RUN_TIME,GROUP_ID,GROUP_TYPE,' +
                          'MEMBER_ID,OPERATION,LOGIN_KEY,SESSION_KEY,REQUEST_ID,' +
                          'URI,URI_ID_DERIVED,USER_ID_DERIVED,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"192.168.1.1","150","300","00Gxx000000001AAA","Regular",' +
                        '"005xx000001234AAA","Add","abc123","def456","GROUP-123",' +
                        '"/services/data/v57.0/groups/members","GROUP_MEMBER_1","005xx000001235BBB",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.GroupMembershipData groupData = 
            (EventLogProcessors.GroupMembershipData)results[0];
        
        // Verify all fields
        System.assertEquals('192.168.1.1', groupData.clientIp);
        System.assertEquals(150, groupData.cpuTime);
        System.assertEquals(300, groupData.runTime);
        System.assertEquals('00Gxx000000001AAA', groupData.groupId);
        System.assertEquals('Regular', groupData.groupType);
        System.assertEquals('005xx000001234AAA', groupData.memberId);
        System.assertEquals('Add', groupData.operation);
        System.assertEquals('abc123', groupData.loginKey);
        System.assertEquals('def456', groupData.sessionKey);
        System.assertEquals('GROUP-123', groupData.requestId);
        System.assertEquals('/services/data/v57.0/groups/members', groupData.uri);
        System.assertEquals('GROUP_MEMBER_1', groupData.uriIdDerived);
        System.assertEquals('005xx000001235BBB', groupData.userIdDerived);
        System.assertEquals('00D123456789012345', groupData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), groupData.timestampDerived);
    }

    @IsTest
    static void testHostnameRedirectsProcessor() {
        // Prepare test data
        String csvHeader = 'REQUEST_ID,CLIENT_IP,SOURCE_HOSTNAME,TARGET_HOSTNAME,PATH,' +
                          'REDIRECT_REASON,IS_BLOCKED_REDIRECTION,REFERRER,ORIGIN,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"REDIRECT-123","192.168.1.1","old.mysite.com","new.mysite.com","/products",' +
                        '"Domain Migration","false","https://google.com","https://old.mysite.com",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.HostnameRedirectsData redirectData = 
            (EventLogProcessors.HostnameRedirectsData)results[0];
        
        // Verify all fields
        System.assertEquals('REDIRECT-123', redirectData.requestId);
        System.assertEquals('192.168.1.1', redirectData.clientIp);
        System.assertEquals('old.mysite.com', redirectData.sourceHostname);
        System.assertEquals('new.mysite.com', redirectData.targetHostname);
        System.assertEquals('/products', redirectData.path);
        System.assertEquals('Domain Migration', redirectData.redirectReason);
        System.assertEquals(false, redirectData.isBlockedRedirection);
        System.assertEquals('https://google.com', redirectData.referrer);
        System.assertEquals('https://old.mysite.com', redirectData.origin);
        System.assertEquals('00D123456789012345', redirectData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), redirectData.timestampDerived);
    }

    @IsTest
    static void testInsecureExternalAssetsProcessor() {
        // Prepare test data
        String csvHeader = 'ASSET_TYPE,INSECURE_URI,TYPE,DOCUMENT_URI,DISPOSITION,' +
                          'CLIENT_IP,NETWORK_ID,CPU_TIME,RUN_TIME,UNIQUE_ID,' +
                          'LOGIN_KEY,ORGANIZATION_ID,REQUEST_ID,URI,URI_ID_DERIVED,' +
                          'SESSION_KEY,USER_ID_DERIVED,TIMESTAMP_DERIVED,TIMESTAMP,USER_ID\n';
                          
        String csvData = '"Image","http://unsecure.com/image.jpg","Mixed Content","https://mysite.com/page","Blocked",' +
                        '"192.168.1.1","0DB000000000001","150","300","ASSET-UNIQUE-123",' +
                        '"LOGIN-ABC","00D123456789012345","INSECURE-123","/apex/mypage","URI-1",' +
                        '"SESSION-XYZ","005xx000001234AAA","2024-01-01T12:00:00Z","20130715233322.670","005xx000001234AAA"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS, fileContent);
        // Process the test data
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.InsecureExternalAssetsData assetData = 
            (EventLogProcessors.InsecureExternalAssetsData)results[0];
        
        // Verify all fields
        System.assertEquals('Image', assetData.assetType);
        System.assertEquals('http://unsecure.com/image.jpg', assetData.insecureUri);
        System.assertEquals('Mixed Content', assetData.type);
        System.assertEquals('https://mysite.com/page', assetData.documentUri);
        System.assertEquals('Blocked', assetData.disposition);
        System.assertEquals('192.168.1.1', assetData.clientIp);
        System.assertEquals('0DB000000000001', assetData.networkId);
        System.assertEquals(150, assetData.cpuTime);
        System.assertEquals(300, assetData.runTime);
        System.assertEquals('ASSET-UNIQUE-123', assetData.uniqueId);
        System.assertEquals('LOGIN-ABC', assetData.loginKey);
        System.assertEquals('00D123456789012345', assetData.organizationId);
        System.assertEquals('INSECURE-123', assetData.requestId);
        System.assertEquals('/apex/mypage', assetData.uri);
        System.assertEquals('URI-1', assetData.uriIdDerived);
        System.assertEquals('SESSION-XYZ', assetData.sessionKey);
        System.assertEquals('005xx000001234AAA', assetData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), assetData.timestampDerived);
    }

    @IsTest
    static void testInsufficientAccessProcessor() {
        // Prepare test data
        String csvHeader = 'ACCESS_ERROR,ERROR_DESCRIPTION,ERROR_TIMESTAMP,REQUESTED_ACCESS_LEVEL,' +
                          'ENTITY_TYPE,RECORD_ID,ACTUAL_LOGGED_IN_USER_ID,USER_ID_DERIVED,' +
                          'ORGANIZATION_ID,REQUEST_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"INSUFFICIENT_ACCESS_OR_READONLY","User does not have access to the record","2024-01-01 12:00:00",' +
                        '"Edit","Account","001xx000003G9yzAAC","005xx000001234AAA","005xx000001235BBB",' +
                        '"00D123456789012345","ACCESS-123","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.InsufficientAccessData accessData = 
            (EventLogProcessors.InsufficientAccessData)results[0];
        
        // Verify all fields
        System.assertEquals('INSUFFICIENT_ACCESS_OR_READONLY', accessData.accessError);
        System.assertEquals('User does not have access to the record', accessData.errorDescription);
        System.assertEquals('2024-01-01 12:00:00', accessData.errorTimestamp);
        System.assertEquals('Edit', accessData.requestedAccessLevel);
        System.assertEquals('Account', accessData.entityType);
        System.assertEquals('001xx000003G9yzAAC', accessData.recordId);
        System.assertEquals('005xx000001234AAA', accessData.actualLoggedInUserId);
        System.assertEquals('005xx000001235BBB', accessData.userIdDerived);
        System.assertEquals('00D123456789012345', accessData.organizationId);
        System.assertEquals('ACCESS-123', accessData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), accessData.timestampDerived);
    }

    @IsTest
    static void testKnowledgeArticleViewProcessor() {
        // Prepare test data
        String csvHeader = 'ARTICLE_ID,ARTICLE_STATUS,ARTICLE_VERSION,ARTICLE_VERSION_ID,LAST_VERSION,' +
                          'CONTEXT,ENTITY,LANGUAGE,LARGE_LANGUAGE_MODEL,SESSION_ID,' +
                          'USER_ID_DERIVED,USER_TYPE,REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"kA0xx0000004CAIAA2","Published","3","ka0xx0000004CAIAA2","true",' +
                        '"Internal","FAQ__kav","en_US","GPT-4","gHJ8k000000000123",' +
                        '"005xx000001234AAA","Standard","KNOW-123","00D123456789012345","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.KnowledgeArticleViewData articleData = 
            (EventLogProcessors.KnowledgeArticleViewData)results[0];
        
        // Verify all fields
        System.assertEquals('kA0xx0000004CAIAA2', articleData.articleId);
        System.assertEquals('Published', articleData.articleStatus);
        System.assertEquals(3, articleData.articleVersion);
        System.assertEquals('ka0xx0000004CAIAA2', articleData.articleVersionId);
        System.assertEquals(true, articleData.lastVersion);
        System.assertEquals('Internal', articleData.context);
        System.assertEquals('FAQ__kav', articleData.entity);
        System.assertEquals('en_US', articleData.language);
        System.assertEquals('GPT-4', articleData.largeLanguageModel);
        System.assertEquals('gHJ8k000000000123', articleData.sessionId);
        System.assertEquals('005xx000001234AAA', articleData.userIdDerived);
        System.assertEquals('Standard', articleData.userType);
        System.assertEquals('KNOW-123', articleData.requestId);
        System.assertEquals('00D123456789012345', articleData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), articleData.timestampDerived);
    }

    @IsTest
    static void testLightningErrorProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,' +
                          'PAGE_START_TIME,PAGE_URL,BROWSER_NAME,BROWSER_VERSION,CLIENT_GEO,' +
                          'CLIENT_ID,CLIENT_IP,DEVICE_ID,DEVICE_MODEL,DEVICE_PLATFORM,' +
                          'DEVICE_SESSION_ID,CONNECTION_TYPE,COMPONENT_NAME,MESSAGE,STACK_TRACE,' +
                          'UI_EVENT_ID,UI_EVENT_SEQUENCE_NUM,UI_EVENT_SOURCE,UI_EVENT_TIMESTAMP,UI_EVENT_TYPE,' +
                          'OS_NAME,OS_VERSION,SDK_APP_TYPE,SDK_APP_VERSION,SDK_VERSION,' +
                          'LOGIN_KEY,SESSION_KEY,USER_ID_DERIVED,USER_TYPE,USER_AGENT,' +
                          'TIMESTAMP_DERIVED,USER_ID,TIMESTAMP,REQUEST_ID,ORGANIZATION_ID\n';
                          
        String csvData = '"Sales","LightningSales","Record","001xx000003G9yzAAC","Account",' +
                        '"1704110400000","/lightning/r/Account/001xx000003G9yzAAC/view","Chrome","120.0.0.0","US",' +
                        '"C6B9A3B5","192.168.1.1","D4F5E6","iPhone 13","iOS",' +
                        '"DS789","WiFi","c:accountDetailsComponent","TypeError: Cannot read property","Error: at line 10",' +
                        '"UI123","1","user-interaction","1704110400123","error",' +
                        '"iOS","16.0","Lightning","1.0","3.2",' +
                        '"LOGIN-ABC","SESSION-XYZ","005xx000001234AAA","Standard","Mozilla/5.0 iPhone",' +
                        '"2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670","LIGHTNING-123","00D123456789012345"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LightningErrorData errorData = 
            (EventLogProcessors.LightningErrorData)results[0];
        
        // Verify all fields
        System.assertEquals('Sales', errorData.appName);
        System.assertEquals('LightningSales', errorData.pageAppName);
        System.assertEquals('Record', errorData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', errorData.pageEntityId);
        System.assertEquals('Account', errorData.pageEntityType);
        System.assertEquals(1704110400000L, errorData.pageStartTime);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', errorData.pageUrl);
        System.assertEquals('Chrome', errorData.browserName);
        System.assertEquals('120.0.0.0', errorData.browserVersion);
        System.assertEquals('US', errorData.clientGeo);
        System.assertEquals('C6B9A3B5', errorData.clientId);
        System.assertEquals('192.168.1.1', errorData.clientIp);
        System.assertEquals('D4F5E6', errorData.deviceId);
        System.assertEquals('iPhone 13', errorData.deviceModel);
        System.assertEquals('iOS', errorData.devicePlatform);
        System.assertEquals('DS789', errorData.deviceSessionId);
        System.assertEquals('WiFi', errorData.connectionType);
        System.assertEquals('c:accountDetailsComponent', errorData.componentName);
        System.assertEquals('TypeError: Cannot read property', errorData.message);
        System.assertEquals('Error: at line 10', errorData.stackTrace);
        System.assertEquals('UI123', errorData.uiEventId);
        System.assertEquals(1, errorData.uiEventSequenceNum);
        System.assertEquals('user-interaction', errorData.uiEventSource);
        System.assertEquals(1704110400123L, errorData.uiEventTimestamp);
        System.assertEquals('error', errorData.uiEventType);
        System.assertEquals('iOS', errorData.osName);
        System.assertEquals('16.0', errorData.osVersion);
        System.assertEquals('Lightning', errorData.sdkAppType);
        System.assertEquals('1.0', errorData.sdkAppVersion);
        System.assertEquals('3.2', errorData.sdkVersion);
        System.assertEquals('LOGIN-ABC', errorData.loginKey);
        System.assertEquals('SESSION-XYZ', errorData.sessionKey);
        System.assertEquals('005xx000001234AAA', errorData.userIdDerived);
        System.assertEquals('Standard', errorData.userType);
        System.assertEquals('Mozilla/5.0 iPhone', errorData.userAgent);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), errorData.timestampDerived);
    }

    @IsTest
    static void testLightningInteractionProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,' +
                          'PAGE_START_TIME,PAGE_URL,TARGET_UI_ELEMENT,PARENT_UI_ELEMENT,GRAND_PARENT_UI_ELEMENT,' +
                          'COMPONENT_NAME,RELATED_LIST,RECORD_ID,RECORD_TYPE,UI_EVENT_ID,' +
                          'UI_EVENT_SEQUENCE_NUM,UI_EVENT_SOURCE,UI_EVENT_TIMESTAMP,UI_EVENT_TYPE,DURATION,' +
                          'BROWSER_NAME,BROWSER_VERSION,CLIENT_GEO,CLIENT_ID,CLIENT_IP,' +
                          'DEVICE_ID,DEVICE_MODEL,DEVICE_PLATFORM,DEVICE_SESSION_ID,CONNECTION_TYPE,' +
                          'OS_NAME,OS_VERSION,SDK_APP_TYPE,SDK_APP_VERSION,SDK_VERSION,' +
                          'LOGIN_KEY,SESSION_KEY,USER_ID_DERIVED,USER_TYPE,USER_AGENT,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP,REQUEST_ID\n';
                          
        String csvData = '"Sales","LightningSales","Record","001xx000003G9yzAAC","Account",' +
                        '"1704110400","/lightning/r/Account/001xx000003G9yzAAC/view","save-button","form-section","record-detail",' +
                        '"c:accountDetailsComponent","Contacts","","Account","UI123",' +
                        '"1","user-interaction","1704110500","click","250",' +
                        '"Chrome","120.0.0.0","US","C6B9A3B5","192.168.1.1",' +
                        '"D4F5E6","iPhone 13","iOS","DS789","WiFi",' +
                        '"iOS","16.0","Lightning","1.0","3.2",' +
                        '"LOGIN-ABC","SESSION-XYZ","005xx000001234AAA","Standard","Mozilla/5.0 iPhone",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670","LIGHTNING-123"\n';
        // TODO: Need to handle the RECORD_ID field
        // RECORD_ID "["001xx000003G9yzAAC","001xx000003G9yzAAD"]"
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LightningInteractionData interactionData = 
            (EventLogProcessors.LightningInteractionData)results[0];
        
        // Verify all fields
        System.assertEquals('Sales', interactionData.appName);
        System.assertEquals('LightningSales', interactionData.pageAppName);
        System.assertEquals('Record', interactionData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', interactionData.pageEntityId);
        System.assertEquals('Account', interactionData.pageEntityType);
        System.assertEquals(1704110400, interactionData.pageStartTime);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', interactionData.pageUrl);
        System.assertEquals('save-button', interactionData.targetUiElement);
        System.assertEquals('form-section', interactionData.parentUiElement);
        System.assertEquals('record-detail', interactionData.grandParentUiElement);
        System.assertEquals('c:accountDetailsComponent', interactionData.componentName);
        System.assertEquals('Contacts', interactionData.relatedList);
        //System.assertEquals(new List<String>{'001xx000003G9yzAAC', '001xx000003G9yzAAD'}, interactionData.recordId);
        System.assertEquals('Account', interactionData.recordType);
        System.assertEquals('UI123', interactionData.uiEventId);
        System.assertEquals(1, interactionData.uiEventSequenceNum);
        System.assertEquals('user-interaction', interactionData.uiEventSource);
        System.assertEquals(1704110500, interactionData.uiEventTimestamp);
        System.assertEquals('click', interactionData.uiEventType);
        System.assertEquals(250, interactionData.duration);
        System.assertEquals('Chrome', interactionData.browserName);
        System.assertEquals('120.0.0.0', interactionData.browserVersion);
        System.assertEquals('US', interactionData.clientGeo);
        System.assertEquals('C6B9A3B5', interactionData.clientId);
        System.assertEquals('192.168.1.1', interactionData.clientIp);
        System.assertEquals('D4F5E6', interactionData.deviceId);
        System.assertEquals('iPhone 13', interactionData.deviceModel);
        System.assertEquals('iOS', interactionData.devicePlatform);
        System.assertEquals('DS789', interactionData.deviceSessionId);
        System.assertEquals('WiFi', interactionData.connectionType);
        System.assertEquals('iOS', interactionData.osName);
        System.assertEquals('16.0', interactionData.osVersion);
        System.assertEquals('Lightning', interactionData.sdkAppType);
        System.assertEquals('1.0', interactionData.sdkAppVersion);
        System.assertEquals('3.2', interactionData.sdkVersion);
        System.assertEquals('LOGIN-ABC', interactionData.loginKey);
        System.assertEquals('SESSION-XYZ', interactionData.sessionKey);
        System.assertEquals('005xx000001234AAA', interactionData.userIdDerived);
        System.assertEquals('Standard', interactionData.userType);
        System.assertEquals('Mozilla/5.0 iPhone', interactionData.userAgent);
        System.assertEquals('00D123456789012345', interactionData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), interactionData.timestampDerived);
    }

    @IsTest
    static void testLightningLoggerProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,PAGE_URL,' +
                          'BROWSER_NAME,BROWSER_VERSION,CLIENT_GEO,CLIENT_ID,DEVICE_MODEL,' +
                          'DEVICE_PLATFORM,DEVICE_SESSION_ID,CONNECTION_TYPE,OS_NAME,OS_VERSION,' +
                          'SDK_APP_TYPE,SDK_APP_VERSION,SDK_VERSION,MESSAGE,SEQUENCE,' +
                          'UI_EVENT_TIMESTAMP,UI_EVENT_RELATIVE_TIMESTAMP,LOGIN_KEY,SESSION_KEY,USER_ID_DERIVED,' +
                          'USER_TYPE,REQUEST_ID,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Sales","Record","001xx000003G9yzAAC","Account","/lightning/r/Account/001xx000003G9yzAAC/view",' +
                        '"Chrome","120.0.0.0","US","C6B9A3B5","iPhone 13",' +
                        '"iOS","DS789","WiFi","iOS","16.0",' +
                        '"Lightning","1.0","3.2","Component loaded successfully","1",' +
                        '"1704110400","500","LOGIN-ABC","SESSION-XYZ","005xx000001234AAA",' +
                        '"Standard","LOG-123","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LightningLoggerData loggerData = 
            (EventLogProcessors.LightningLoggerData)results[0];
        
        // Verify all fields
        System.assertEquals('Sales', loggerData.appName);
        System.assertEquals('Record', loggerData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', loggerData.pageEntityId);
        System.assertEquals('Account', loggerData.pageEntityType);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', loggerData.pageUrl);
        System.assertEquals('Chrome', loggerData.browserName);
        System.assertEquals('120.0.0.0', loggerData.browserVersion);
        System.assertEquals('US', loggerData.clientGeo);
        System.assertEquals('C6B9A3B5', loggerData.clientId);
        System.assertEquals('iPhone 13', loggerData.deviceModel);
        System.assertEquals('iOS', loggerData.devicePlatform);
        System.assertEquals('DS789', loggerData.deviceSessionId);
        System.assertEquals('WiFi', loggerData.connectionType);
        System.assertEquals('iOS', loggerData.osName);
        System.assertEquals('16.0', loggerData.osVersion);
        System.assertEquals('Lightning', loggerData.sdkAppType);
        System.assertEquals('1.0', loggerData.sdkAppVersion);
        System.assertEquals('3.2', loggerData.sdkVersion);
        System.assertEquals('Component loaded successfully', loggerData.message);
        System.assertEquals(1, loggerData.sequence);
        System.assertEquals(1704110400, loggerData.uiEventTimestamp);
        System.assertEquals(500, loggerData.uiEventRelativeTimestamp);
        System.assertEquals('LOGIN-ABC', loggerData.loginKey);
        System.assertEquals('SESSION-XYZ', loggerData.sessionKey);
        System.assertEquals('005xx000001234AAA', loggerData.userIdDerived);
        System.assertEquals('Standard', loggerData.userType);
        System.assertEquals('LOG-123', loggerData.requestId);
        System.assertEquals('00D123456789012345', loggerData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), loggerData.timestampDerived);
    }

    @IsTest
    static void testLightningPageViewProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,' +
                          'PAGE_START_TIME,PAGE_URL,PREVPAGE_APP_NAME,PREVPAGE_CONTEXT,PREVPAGE_ENTITY_ID,' +
                          'PREVPAGE_ENTITY_TYPE,PREVPAGE_URL,DURATION,EFFECTIVE_PAGE_TIME,EFFECTIVE_PAGE_TIME_DEVIATION,' +
                          'EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE,EFFECTIVE_PAGE_TIME_DEVIATION_REASON,TARGET_UI_ELEMENT,PARENT_UI_ELEMENT,GRANDPARENT_UI_ELEMENT,' +
                          'UI_EVENT_ID,UI_EVENT_SEQUENCE_NUM,UI_EVENT_SOURCE,UI_EVENT_TIMESTAMP,BROWSER_NAME,' +
                          'BROWSER_VERSION,CLIENT_GEO,CLIENT_ID,CLIENT_IP,DEVICE_ID,' +
                          'DEVICE_MODEL,DEVICE_PLATFORM,DEVICE_SESSION_ID,CONNECTION_TYPE,OS_NAME,' +
                          'OS_VERSION,SDK_APP_TYPE,SDK_APP_VERSION,SDK_VERSION,LOGIN_KEY,' +
                          'SESSION_KEY,USER_ID_DERIVED,USER_TYPE,USER_AGENT,REQUEST_ID,' +
                          'TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Sales","LightningSales","Record","001xx000003G9yzAAC","Account",' +
                        '"1704110400","/lightning/r/Account/001xx000003G9yzAAC/view","Sales","List","",' +
                        '"Account","/lightning/o/Account/list","2500","2.35","true",' +
                        '"BACKGROUND_TIME","Tab Inactive","view-button","form-section","record-detail",' +
                        '"UI123","1","navigation","1704110500","Chrome",' +
                        '"120.0.0.0","US","C6B9A3B5","192.168.1.1","D4F5E6",' +
                        '"iPhone 13","iOS","DS789","WiFi","iOS",' +
                        '"16.0","Lightning","1.0","3.2","LOGIN-ABC",' +
                        '"SESSION-XYZ","005xx000001234AAA","Standard","Mozilla/5.0 iPhone","PAGE-123",' +
                        '"2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LightningPageViewData pageViewData = 
            (EventLogProcessors.LightningPageViewData)results[0];
        
        // Verify all fields
        System.assertEquals('Sales', pageViewData.appName);
        System.assertEquals('LightningSales', pageViewData.pageAppName);
        System.assertEquals('Record', pageViewData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', pageViewData.pageEntityId);
        System.assertEquals('Account', pageViewData.pageEntityType);
        System.assertEquals(1704110400L, pageViewData.pageStartTime);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', pageViewData.pageUrl);
        System.assertEquals('Sales', pageViewData.prevPageAppName);
        System.assertEquals('List', pageViewData.prevPageContext);
        System.assertEquals('', pageViewData.prevPageEntityId);
        System.assertEquals('Account', pageViewData.prevPageEntityType);
        System.assertEquals('/lightning/o/Account/list', pageViewData.prevPageUrl);
        System.assertEquals(2500, pageViewData.duration);
        System.assertEquals(2.35, pageViewData.effectivePageTime);
        System.assertEquals(true, pageViewData.effectivePageTimeDeviation);
        System.assertEquals('BACKGROUND_TIME', pageViewData.effectivePageTimeDeviationErrorType);
        System.assertEquals('Tab Inactive', pageViewData.effectivePageTimeDeviationReason);
        System.assertEquals('view-button', pageViewData.targetUiElement);
        System.assertEquals('form-section', pageViewData.parentUiElement);
        System.assertEquals('record-detail', pageViewData.grandparentUiElement);
        System.assertEquals('UI123', pageViewData.uiEventId);
        System.assertEquals(1, pageViewData.uiEventSequenceNum);
        System.assertEquals('navigation', pageViewData.uiEventSource);
        System.assertEquals(1704110500L, pageViewData.uiEventTimestamp);
        System.assertEquals('Chrome', pageViewData.browserName);
        System.assertEquals('120.0.0.0', pageViewData.browserVersion);
        System.assertEquals('US', pageViewData.clientGeo);
        System.assertEquals('C6B9A3B5', pageViewData.clientId);
        System.assertEquals('192.168.1.1', pageViewData.clientIp);
        System.assertEquals('D4F5E6', pageViewData.deviceId);
        System.assertEquals('iPhone 13', pageViewData.deviceModel);
        System.assertEquals('iOS', pageViewData.devicePlatform);
        System.assertEquals('DS789', pageViewData.deviceSessionId);
        System.assertEquals('WiFi', pageViewData.connectionType);
        System.assertEquals('iOS', pageViewData.osName);
        System.assertEquals('16.0', pageViewData.osVersion);
        System.assertEquals('Lightning', pageViewData.sdkAppType);
        System.assertEquals('1.0', pageViewData.sdkAppVersion);
        System.assertEquals('3.2', pageViewData.sdkVersion);
        System.assertEquals('LOGIN-ABC', pageViewData.loginKey);
        System.assertEquals('SESSION-XYZ', pageViewData.sessionKey);
        System.assertEquals('005xx000001234AAA', pageViewData.userIdDerived);
        System.assertEquals('Standard', pageViewData.userType);
        System.assertEquals('Mozilla/5.0 iPhone', pageViewData.userAgent);
        System.assertEquals('PAGE-123', pageViewData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), pageViewData.timestampDerived);
    }

    @IsTest
    static void testLightningPerformanceProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_START_TIME,DURATION,UI_EVENT_ID,UI_EVENT_SOURCE,' +
                          'UI_EVENT_TIMESTAMP,UI_EVENT_TYPE,BROWSER_NAME,BROWSER_VERSION,CLIENT_GEO,' +
                          'CLIENT_ID,CLIENT_IP,DEVICE_ID,DEVICE_MODEL,DEVICE_PLATFORM,' +
                          'DEVICE_SESSION_ID,CONNECTION_TYPE,OS_NAME,OS_VERSION,SDK_APP_TYPE,' +
                          'SDK_APP_VERSION,SDK_VERSION,LOGIN_KEY,SESSION_KEY,USER_ID_DERIVED,' +
                          'USER_TYPE,USER_AGENT,REQUEST_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Sales","1704110400","2500","PERF123","page-load",' +
                        '"1704110500","performance","Chrome","120.0.0.0","US",' +
                        '"C6B9A3B5","192.168.1.1","D4F5E6","iPhone 13","iOS",' +
                        '"DS789","WiFi","iOS","16.0","Lightning",' +
                        '"1.0","3.2","LOGIN-ABC","SESSION-XYZ","005xx000001234AAA",' +
                        '"Standard","Mozilla/5.0 iPhone","PERF-123","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LightningPerformanceData perfData = 
            (EventLogProcessors.LightningPerformanceData)results[0];
        
        // Verify all fields
        System.assertEquals('Sales', perfData.appName);
        System.assertEquals(1704110400L, perfData.pageStartTime);
        System.assertEquals(2500, perfData.duration);
        System.assertEquals('PERF123', perfData.uiEventId);
        System.assertEquals('page-load', perfData.uiEventSource);
        System.assertEquals(1704110500L, perfData.uiEventTimestamp);
        System.assertEquals('performance', perfData.uiEventType);
        System.assertEquals('Chrome', perfData.browserName);
        System.assertEquals('120.0.0.0', perfData.browserVersion);
        System.assertEquals('US', perfData.clientGeo);
        System.assertEquals('C6B9A3B5', perfData.clientId);
        System.assertEquals('192.168.1.1', perfData.clientIp);
        System.assertEquals('D4F5E6', perfData.deviceId);
        System.assertEquals('iPhone 13', perfData.deviceModel);
        System.assertEquals('iOS', perfData.devicePlatform);
        System.assertEquals('DS789', perfData.deviceSessionId);
        System.assertEquals('WiFi', perfData.connectionType);
        System.assertEquals('iOS', perfData.osName);
        System.assertEquals('16.0', perfData.osVersion);
        System.assertEquals('Lightning', perfData.sdkAppType);
        System.assertEquals('1.0', perfData.sdkAppVersion);
        System.assertEquals('3.2', perfData.sdkVersion);
        System.assertEquals('LOGIN-ABC', perfData.loginKey);
        System.assertEquals('SESSION-XYZ', perfData.sessionKey);
        System.assertEquals('005xx000001234AAA', perfData.userIdDerived);
        System.assertEquals('Standard', perfData.userType);
        System.assertEquals('Mozilla/5.0 iPhone', perfData.userAgent);
        System.assertEquals('PERF-123', perfData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), perfData.timestampDerived);
    }

    @IsTest
    static void testLoginEventProcessor() {
        // Prepare test data
        String csvHeader = 'API_TYPE,API_VERSION,AUTHENTICATION_METHOD_REFERENCE,AUTHENTICATION_SERVICE_ID,LOGIN_STATUS,' +
                          'LOGIN_SUB_TYPE,LOGIN_TYPE,LOGIN_URL,BROWSER_TYPE,CIPHER_SUITE,' +
                          'TLS_PROTOCOL,CLIENT_IP,SOURCE_IP,FORWARDED_FOR_IP,CPU_TIME,' +
                          'DB_TOTAL_TIME,RUN_TIME,REQUEST_STATUS,URI,URI_ID_DERIVED,' +
                          'USER_NAME,USER_TYPE,USER_ID_DERIVED,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP,REQUEST_ID\n';
                          
        String csvData = '"SOAP","54.0","pwd","AUTH-123","Success",' +
                        '"UI","Application","https://login.salesforce.com","Chrome","ECDHE-RSA-AES256-GCM-SHA384",' +
                        '"TLSv1.3","192.168.1.1","10.0.0.1","203.0.113.1","1000",' +
                        '"300","1500","Success","/services/Soap/u/54.0","URI-1",' +
                        '"user@example.com","Standard","005xx000001234AAA","LOGIN-ABC","SESSION-XYZ",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670","REQ-123"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LOGIN, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LOGIN);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LoginEventData loginData = 
            (EventLogProcessors.LoginEventData)results[0];
        
        // Verify all fields
        System.assertEquals('SOAP', loginData.apiType);
        System.assertEquals('54.0', loginData.apiVersion);
        System.assertEquals('pwd', loginData.authMethodRef);
        System.assertEquals('AUTH-123', loginData.authServiceId);
        System.assertEquals('Success', loginData.loginStatus);
        System.assertEquals('UI', loginData.loginSubType);
        System.assertEquals('Application', loginData.loginType);
        System.assertEquals('https://login.salesforce.com', loginData.loginUrl);
        System.assertEquals('Chrome', loginData.browserType);
        System.assertEquals('ECDHE-RSA-AES256-GCM-SHA384', loginData.cipherSuite);
        System.assertEquals('TLSv1.3', loginData.tlsProtocol);
        System.assertEquals('192.168.1.1', loginData.clientIp);
        System.assertEquals('10.0.0.1', loginData.sourceIp);
        System.assertEquals('203.0.113.1', loginData.forwardedForIp);
        System.assertEquals(1000, loginData.cpuTime);
        System.assertEquals(300, loginData.dbTotalTime);
        System.assertEquals(1500, loginData.runTime);
        System.assertEquals('Success', loginData.requestStatus);
        System.assertEquals('REQ-123', loginData.requestId);
        System.assertEquals('/services/Soap/u/54.0', loginData.uri);
        System.assertEquals('URI-1', loginData.uriIdDerived);
        System.assertEquals('user@example.com', loginData.userName);
        System.assertEquals('Standard', loginData.userType);
        System.assertEquals('005xx000001234AAA', loginData.userIdDerived);
        System.assertEquals('LOGIN-ABC', loginData.loginKey);
        System.assertEquals('SESSION-XYZ', loginData.sessionKey);
        System.assertEquals('00D123456789012345', loginData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), loginData.timestampDerived);
    }

    @IsTest
    static void testLoginAsProcessor() {
        // Prepare test data
        String csvHeader = 'DELEGATED_USER_ID,DELEGATED_USER_ID_DERIVED,DELEGATED_USER_NAME,CLIENT_IP,' +
                          'CPU_TIME,RUN_TIME,URI,URI_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,EVENT_TYPE,REQUEST_ID,TIMESTAMP_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"005xx000001235BBB","005xx000001235BBB","standard.user@example.com","192.168.1.1",' +
                        '"1000","1500","/services/data/v54.0/sobjects/User/005xx000001235BBB","URI-1","LOGIN-ABC",' +
                        '"SESSION-XYZ","00D123456789012345","Login-As","LOGINAS-123","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LOGIN_AS, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LOGIN_AS);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LoginAsData loginAsData = 
            (EventLogProcessors.LoginAsData)results[0];
        
        // Verify all fields
        System.assertEquals('005xx000001235BBB', loginAsData.delegatedUserId);
        System.assertEquals('005xx000001235BBB', loginAsData.delegatedUserIdDerived);
        System.assertEquals('standard.user@example.com', loginAsData.delegatedUserName);
        System.assertEquals('192.168.1.1', loginAsData.clientIp);
        System.assertEquals(1000, loginAsData.cpuTime);
        System.assertEquals(1500, loginAsData.runTime);
        System.assertEquals('/services/data/v54.0/sobjects/User/005xx000001235BBB', loginAsData.uri);
        System.assertEquals('URI-1', loginAsData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', loginAsData.loginKey);
        System.assertEquals('SESSION-XYZ', loginAsData.sessionKey);
        System.assertEquals('00D123456789012345', loginAsData.organizationId);
        System.assertEquals('Login-As', loginAsData.eventType);
        System.assertEquals('LOGINAS-123', loginAsData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), loginAsData.timestampDerived);
    }

    @IsTest
    static void testLogoutProcessor() {
        // Prepare test data
        String csvHeader = 'API_TYPE,API_VERSION,APP_TYPE,CLIENT_VERSION,PLATFORM_TYPE,' +
                          'RESOLUTION_TYPE,SESSION_LEVEL,SESSION_TYPE,USER_INITIATED_LOGOUT,BROWSER_TYPE,' +
                          'CLIENT_IP,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,EVENT_TYPE,' +
                          'REQUEST_ID,TIMESTAMP_DERIVED,SOURCE_IP,LOGIN_TYPE,PLATFORM,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"SOAP","54.0","1","120","2",' +
                        '"1","STANDARD","Application","true","Chrome",' +
                        '"192.168.1.1","LOGIN-ABC","SESSION-XYZ","00D123456789012345","Logout",' +
                        '"LOGOUT-123","2024-01-01T12:00:00Z","10.0.0.1","UI","Web",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_LOGOUT, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_LOGOUT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.LogoutEventData logoutData = 
            (EventLogProcessors.LogoutEventData)results[0];
        
        // Verify all fields
        System.assertEquals('SOAP', logoutData.apiType);
        System.assertEquals('54.0', logoutData.apiVersion);
        System.assertEquals(1, logoutData.appType);
        System.assertEquals(120, logoutData.clientVersion);
        System.assertEquals(2, logoutData.platformType);
        System.assertEquals(1, logoutData.resolutionType);
        System.assertEquals('STANDARD', logoutData.sessionLevel);
        System.assertEquals('Application', logoutData.sessionType);
        System.assertEquals(true, logoutData.userInitiatedLogout);
        System.assertEquals('Chrome', logoutData.browserType);
        System.assertEquals('192.168.1.1', logoutData.clientIp);
        System.assertEquals('LOGIN-ABC', logoutData.loginKey);
        System.assertEquals('SESSION-XYZ', logoutData.sessionKey);
        System.assertEquals('00D123456789012345', logoutData.organizationId);
        System.assertEquals('Logout', logoutData.eventType);
        System.assertEquals('LOGOUT-123', logoutData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), logoutData.timestampDerived);
    }

    @IsTest
    static void testMetadataApiOperationProcessor() {
        // Prepare test data
        String csvHeader = 'API_VERSION,CLIENT_ID,CLIENT_IP,CPU_TIME,RUN_TIME,' +
                          'OPERATION,EVENT_TYPE,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,' +
                          'REQUEST_ID,URI,URI_ID_DERIVED,TIMESTAMP_DERIVED,METADATA_TYPE,STATUS,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"54.0","API-CLIENT-123","192.168.1.1","1000","1500",' +
                        '"deploy","MetadataApiOperation","LOGIN-ABC","SESSION-XYZ","00D123456789012345",' +
                        '"META-123","/services/data/v54.0/metadata/deployRequest/0Af1x00001234567","URI-1","2024-01-01T12:00:00Z","ApexClass","Success",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.MetadataApiOperationData metadataData = 
            (EventLogProcessors.MetadataApiOperationData)results[0];
        
        // Verify all fields
        System.assertEquals('54.0', metadataData.apiVersion);
        System.assertEquals('API-CLIENT-123', metadataData.clientId);
        System.assertEquals('192.168.1.1', metadataData.clientIp);
        System.assertEquals(1000, metadataData.cpuTime);
        System.assertEquals(1500, metadataData.runTime);
        System.assertEquals('deploy', metadataData.operation);
        System.assertEquals('MetadataApiOperation', metadataData.eventType);
        System.assertEquals('LOGIN-ABC', metadataData.loginKey);
        System.assertEquals('SESSION-XYZ', metadataData.sessionKey);
        System.assertEquals('00D123456789012345', metadataData.organizationId);
        System.assertEquals('META-123', metadataData.requestId);
        System.assertEquals('/services/data/v54.0/metadata/deployRequest/0Af1x00001234567', metadataData.uri);
        System.assertEquals('URI-1', metadataData.uriIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), metadataData.timestampDerived);
    }

    @IsTest
    static void testMultiblockReportProcessor() {
        // Prepare test data
        String csvHeader = 'MASTER_REPORT_ID,HAS_CHART,CPU_TIME,DB_TOTAL_TIME,RUN_TIME,' +
                          'CLIENT_IP,REQUEST_ID,REQUEST_STATUS,URI,URI_ID_DERIVED,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID_DERIVED,' +
                          'USER_TYPE,REPORT_ID,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"00OB0000000ABCD","true","1000","500","1500",' +
                        '"192.168.1.1","REP-123","Success","/services/data/v54.0/analytics/reports/00OB0000000ABCD","URI-1",' +
                        '"LOGIN-ABC","SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA",' +
                        '"Standard","00OB0000000ABCD","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.MultiblockReportData reportData = 
            (EventLogProcessors.MultiblockReportData)results[0];
        
        // Verify all fields
        System.assertEquals('00OB0000000ABCD', reportData.masterReportId);
        System.assertEquals(true, reportData.hasChart);
        System.assertEquals(1000, reportData.cpuTime);
        System.assertEquals(500, reportData.dbTotalTime);
        System.assertEquals(1500, reportData.runTime);
        System.assertEquals('192.168.1.1', reportData.clientIp);
        System.assertEquals('REP-123', reportData.requestId);
        System.assertEquals('Success', reportData.requestStatus);
        System.assertEquals('/services/data/v54.0/analytics/reports/00OB0000000ABCD', reportData.uri);
        System.assertEquals('URI-1', reportData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', reportData.loginKey);
        System.assertEquals('SESSION-XYZ', reportData.sessionKey);
        System.assertEquals('00D123456789012345', reportData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), reportData.timestampDerived);
        System.assertEquals('005xx000001234AAA', reportData.userIdDerived);
        System.assertEquals('Standard', reportData.userType);
    }

    @IsTest
    static void testNamedCredentialProcessor() {
        // Prepare test data
        String csvHeader = 'NAMED_CREDENTIAL_NAME,CALLER_PACKAGE_NAMESPACE,CLIENT_IP,CPU_TIME,RUN_TIME,' +
                          'REQUEST_ID,URI,URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,NAMED_CREDENTIAL_ID,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"ExternalAPICredential","myNamespace","192.168.1.1","1000","1500",' +
                        '"CRED-123","/services/data/v54.0/callout/ExternalAPICredential","URI-1","LOGIN-ABC","SESSION-XYZ",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","0Xx000000000123","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.NamedCredentialData credentialData = 
            (EventLogProcessors.NamedCredentialData)results[0];
        
        // Verify all fields
        System.assertEquals('ExternalAPICredential', credentialData.namedCredentialName);
        System.assertEquals('myNamespace', credentialData.callerPackageNamespace);
        System.assertEquals('192.168.1.1', credentialData.clientIp);
        System.assertEquals(1000, credentialData.cpuTime);
        System.assertEquals(1500, credentialData.runTime);
        System.assertEquals('CRED-123', credentialData.requestId);
        System.assertEquals('/services/data/v54.0/callout/ExternalAPICredential', credentialData.uri);
        System.assertEquals('URI-1', credentialData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', credentialData.loginKey);
        System.assertEquals('SESSION-XYZ', credentialData.sessionKey);
        System.assertEquals('00D123456789012345', credentialData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), credentialData.timestampDerived);
    }

    @IsTest
    static void testOneCommerceUsageProcessor() {
        // Prepare test data
        String csvHeader = 'B2B_EDITION,B2B_VERSION,WEB_STORE_ID,WEB_STORE_TYPE,BROWSER_DEVICE_TYPE,' +
                          'OS_VERSION,OPERATION,OPERATION_STAGE,OPERATION_STATE,OPERATION_STATUS,' +
                          'OPERATION_TIME,IS_RETRY,COUNT,CONTEXT_ID,CONTEXT_MAP,' +
                          'CORRELATION_ID,EFFECTIVE_ACCOUNT_ID,ERROR_CODE,ERROR_MESSAGE,CPU_TIME,' +
                          'DB_TOTAL_TIME,RUN_TIME,REQUEST_ID,REQUEST_STATUS,URI,' +
                          'URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,SERVICE_NAME,ORGANIZATION_ID,' +
                          'USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,ONE_COMMERCE_USAGE_ID,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Enterprise","2.0","0ZB000000000123","B2B","Desktop",' +
                        '"16.0","checkout","payment","processing","success",' +
                        '"1500","false","1","CTX-123","{\"cartId\":\"abc123\"}",' +
                        '"COR-123","001xx000003G9yzAAC","","","1000",' +
                        '"500","2000","REQ-123","Success","/services/data/v54.0/commerce/checkout",' +
                        '"URI-1","LOGIN-ABC","SESSION-XYZ","CommerceCheckout","00D123456789012345",' +
                        '"005xx000001234AAA","Standard","2024-01-01T12:00:00Z","OCU-123","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.OneCommerceUsageData commerceData = 
            (EventLogProcessors.OneCommerceUsageData)results[0];
        
        // Verify all fields
        System.assertEquals('Enterprise', commerceData.b2bEdition);
        System.assertEquals('2.0', commerceData.b2bVersion);
        System.assertEquals('0ZB000000000123', commerceData.webStoreId);
        System.assertEquals('B2B', commerceData.webStoreType);
        System.assertEquals('Desktop', commerceData.browserDeviceType);
        System.assertEquals('16.0', commerceData.osVersion);
        System.assertEquals('checkout', commerceData.operation);
        System.assertEquals('payment', commerceData.operationStage);
        System.assertEquals('processing', commerceData.operationState);
        System.assertEquals('success', commerceData.operationStatus);
        System.assertEquals(1500, commerceData.operationTime);
        System.assertEquals(false, commerceData.isRetry);
        System.assertEquals(1, commerceData.count);
        System.assertEquals('CTX-123', commerceData.contextId);
        System.assertEquals('{"cartId":"abc123"}', commerceData.contextMap);
        System.assertEquals('COR-123', commerceData.correlationId);
        System.assertEquals('001xx000003G9yzAAC', commerceData.effectiveAccountId);
        System.assertEquals('', commerceData.errorCode);
        System.assertEquals('', commerceData.errorMessage);
        System.assertEquals(1000, commerceData.cpuTime);
        System.assertEquals(500, commerceData.dbTotalTime);
        System.assertEquals(2000, commerceData.runTime);
        System.assertEquals('REQ-123', commerceData.requestId);
        System.assertEquals('Success', commerceData.requestStatus);
        System.assertEquals('/services/data/v54.0/commerce/checkout', commerceData.uri);
        System.assertEquals('URI-1', commerceData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', commerceData.loginKey);
        System.assertEquals('SESSION-XYZ', commerceData.sessionKey);
        System.assertEquals('CommerceCheckout', commerceData.serviceName);
        System.assertEquals('00D123456789012345', commerceData.organizationId);
        System.assertEquals('005xx000001234AAA', commerceData.userIdDerived);
        System.assertEquals('Standard', commerceData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), commerceData.timestampDerived);
    }

    @IsTest
    static void testPackageInstallProcessor() {
        // Prepare test data
        String csvHeader = 'CLIENT_IP,CPU_TIME,RUN_TIME,EVENT_TYPE,LOGIN_KEY,' +
                          'FAILURE_TYPE,IS_MANAGED,IS_PUSH,IS_RELEASED,IS_SUCCESSFUL,' +
                          'PACKAGE_NAME,OPERATION_TYPE,SESSION_KEY,ORGANIZATION_ID,REQUEST_ID,' +
                          'URI,URI_ID_DERIVED,TIMESTAMP_DERIVED,PACKAGE_ID,PACKAGE_VERSION,STATUS,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"192.168.1.1","1000","1500","PackageInstall","LOGIN-ABC",' +
                        '"","true","false","true","true",' +
                        '"MyAwesomePackage","install","SESSION-XYZ","00D123456789012345","PKG-123",' +
                        '"/services/data/v54.0/tooling/package/install/0Ho000000000123","URI-1","2024-01-01T12:00:00Z","033000000000AAA","1.2.3","Success",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.PackageInstallData packageData = 
            (EventLogProcessors.PackageInstallData)results[0];
        
        // Verify all fields
        System.assertEquals('192.168.1.1', packageData.clientIp);
        System.assertEquals(1000, packageData.cpuTime);
        System.assertEquals(1500, packageData.runTime);
        System.assertEquals('PackageInstall', packageData.eventType);
        System.assertEquals('LOGIN-ABC', packageData.loginKey);
        System.assertEquals('', packageData.failureType);
        System.assertEquals(true, packageData.isManaged);
        System.assertEquals(false, packageData.isPush);
        System.assertEquals(true, packageData.isReleased);
        System.assertEquals(true, packageData.isSuccessful);
        System.assertEquals('MyAwesomePackage', packageData.packageName);
        System.assertEquals('install', packageData.operationType);
        System.assertEquals('SESSION-XYZ', packageData.sessionKey);
        System.assertEquals('00D123456789012345', packageData.organizationId);
        System.assertEquals('PKG-123', packageData.requestId);
        System.assertEquals('/services/data/v54.0/tooling/package/install/0Ho000000000123', packageData.uri);
        System.assertEquals('URI-1', packageData.uriIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), packageData.timestampDerived);
    }

    @IsTest
    static void testPermissionUpdateProcessor() {
        // Prepare test data
        String csvHeader = 'PERMISSION_TYPE,UPDATE_TYPE,DESCRIPTION,CONTEXT,FEATURE_ID,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,REQUEST_ID,TIMESTAMP_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"CustomObject","Grant","Granted access to Account object","Setup UI","ACCOUNT_ACCESS",' +
                        '"LOGIN-ABC","SESSION-XYZ","00D123456789012345","PERM-123","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.PermissionUpdateData permissionData = 
            (EventLogProcessors.PermissionUpdateData)results[0];
        
        // Verify all fields
        System.assertEquals('CustomObject', permissionData.permissionType);
        System.assertEquals('Grant', permissionData.updateType);
        System.assertEquals('Granted access to Account object', permissionData.description);
        System.assertEquals('Setup UI', permissionData.context);
        System.assertEquals('ACCOUNT_ACCESS', permissionData.featureId);
        System.assertEquals('LOGIN-ABC', permissionData.loginKey);
        System.assertEquals('SESSION-XYZ', permissionData.sessionKey);
        System.assertEquals('00D123456789012345', permissionData.organizationId);
        System.assertEquals('PERM-123', permissionData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), permissionData.timestampDerived);
    }

    @IsTest
    static void testPlatformEncryptionProcessor() {
        // Prepare test data
        String csvHeader = 'ACTION,KEY_TYPE,KEY_ID,KEY_ID_DERIVED,METHOD,' +
                          'CLIENT_IP,CPU_TIME,RUN_TIME,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,REQUEST_ID,URI,URI_ID_DERIVED,TIMESTAMP_DERIVED,' +
                          'USER_ID_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"GENERATE_KEY","TENANT_SECRET","TS-123","TS-123-DERIVED","HSM",' +
                        '"192.168.1.1","1000","1500","LOGIN-ABC","SESSION-XYZ",' +
                        '"00D123456789012345","ENC-123","/services/data/v54.0/tooling/sobjects/TenantSecret","URI-1","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.PlatformEncryptionData encryptionData = 
            (EventLogProcessors.PlatformEncryptionData)results[0];
        
        // Verify all fields
        System.assertEquals('GENERATE_KEY', encryptionData.action);
        System.assertEquals('TENANT_SECRET', encryptionData.keyType);
        System.assertEquals('TS-123', encryptionData.keyId);
        System.assertEquals('TS-123-DERIVED', encryptionData.keyIdDerived);
        System.assertEquals('HSM', encryptionData.method);
        System.assertEquals('192.168.1.1', encryptionData.clientIp);
        System.assertEquals(1000, encryptionData.cpuTime);
        System.assertEquals(1500, encryptionData.runTime);
        System.assertEquals('LOGIN-ABC', encryptionData.loginKey);
        System.assertEquals('SESSION-XYZ', encryptionData.sessionKey);
        System.assertEquals('00D123456789012345', encryptionData.organizationId);
        System.assertEquals('ENC-123', encryptionData.requestId);
        System.assertEquals('/services/data/v54.0/tooling/sobjects/TenantSecret', encryptionData.uri);
        System.assertEquals('URI-1', encryptionData.uriIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), encryptionData.timestampDerived);
        System.assertEquals('005xx000001234AAA', encryptionData.userIdDerived);
    }

    @IsTest
    static void testPricingEventProcessor() {
        // Prepare test data
        String csvHeader = 'PRICING_API_ENDPOINT,PRICING_DETAILS,PRICING_ERROR_CODE,PRICING_LOG_NAME,PRICING_PROCEDURE,' +
                          'PRICING_STATUS,CPU_TIME,RUN_TIME,CLIENT_IP,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,REQUEST_ID,URI,URI_ID_DERIVED,' +
                          'TIMESTAMP_DERIVED,USER_ID_DERIVED,PRICING_EVENT_TYPE,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"/services/data/v54.0/commerce/pricing/calculate","Pricing element was processed.","","PricingCalculation","CalculatePrice",' +
                        '"Success","1000","1500","192.168.1.1","LOGIN-ABC",' +
                        '"SESSION-XYZ","00D123456789012345","PRICE-123","/services/data/v54.0/commerce/pricing/calculate","URI-1",' +
                        '"2024-01-01T12:00:00Z","005xx000001234AAA","Calculate","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_PRICING, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_PRICING);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.PricingEventData pricingData = 
            (EventLogProcessors.PricingEventData)results[0];
        
        // Verify all fields
        System.assertEquals('/services/data/v54.0/commerce/pricing/calculate', pricingData.pricingApiEndpoint);
        System.assertEquals('Pricing element was processed.', pricingData.pricingDetails);
        System.assertEquals('', pricingData.pricingErrorCode);
        System.assertEquals('PricingCalculation', pricingData.pricingLogName);
        System.assertEquals('CalculatePrice', pricingData.pricingProcedure);
        System.assertEquals('Success', pricingData.pricingStatus);
        System.assertEquals(1000, pricingData.cpuTime);
        System.assertEquals(1500, pricingData.runTime);
        System.assertEquals('192.168.1.1', pricingData.clientIp);
        System.assertEquals('LOGIN-ABC', pricingData.loginKey);
        System.assertEquals('SESSION-XYZ', pricingData.sessionKey);
        System.assertEquals('00D123456789012345', pricingData.organizationId);
        System.assertEquals('PRICE-123', pricingData.requestId);
        System.assertEquals('/services/data/v54.0/commerce/pricing/calculate', pricingData.uri);
        System.assertEquals('URI-1', pricingData.uriIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), pricingData.timestampDerived);
        System.assertEquals('005xx000001234AAA', pricingData.userIdDerived);
    }

    @IsTest
    static void testQueuedExecutionProcessor() {
        // Prepare test data
        String csvHeader = 'ENTRY_POINT,JOB_ID,REQUEST_STATUS,CPU_TIME,DB_TOTAL_TIME,' +
                          'RUN_TIME,CLIENT_IP,LOGIN_KEY,SESSION_KEY,REQUEST_ID,' +
                          'URI,URI_ID_DERIVED,ORGANIZATION_ID,TIMESTAMP,USER_ID,' +
                          'USER_TYPE,USER_ID_DERIVED,TIMESTAMP_DERIVED\n';
                          
        String csvData = '"BatchApexClass.execute","7070x000000ABCD","Success","1000","500",' +
                        '"1500","192.168.1.1","LOGIN-ABC","SESSION-XYZ","QUEUE-123",' +
                        '"/services/data/v54.0/jobs/apex/7070x000000ABCD","URI-1","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA",' +
                        '"Standard","005xx000001234AAA","2024-01-01T12:00:00Z"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.QueuedExecutionData queueData = 
            (EventLogProcessors.QueuedExecutionData)results[0];
        
        // Verify all fields
        System.assertEquals('BatchApexClass.execute', queueData.entryPoint);
        System.assertEquals('7070x000000ABCD', queueData.jobId);
        System.assertEquals('Success', queueData.requestStatus);
        System.assertEquals(1000, queueData.cpuTime);
        System.assertEquals(500, queueData.dbTotalTime);
        System.assertEquals(1500, queueData.runTime);
        System.assertEquals('192.168.1.1', queueData.clientIp);
        System.assertEquals('LOGIN-ABC', queueData.loginKey);
        System.assertEquals('SESSION-XYZ', queueData.sessionKey);
        System.assertEquals('QUEUE-123', queueData.requestId);
        System.assertEquals('/services/data/v54.0/jobs/apex/7070x000000ABCD', queueData.uri);
        System.assertEquals('URI-1', queueData.uriIdDerived);
        System.assertEquals('00D123456789012345', queueData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), queueData.timestampDerived);
        System.assertEquals('005xx000001234AAA', queueData.userIdDerived);
        System.assertEquals('Standard', queueData.userType);
    }

    @IsTest
    static void testReportEventProcessor() {
        // Prepare test data
        String csvHeader = 'REPORT_ID,REPORT_ID_DERIVED,DISPLAY_TYPE,RENDERING_TYPE,ORIGIN,' +
                          'SORT,ENTITY_NAME,AVERAGE_ROW_SIZE,ROW_COUNT,NUMBER_BUCKETS,' +
                          'NUMBER_COLUMNS,UI_NUMBER_COLUMNS,NUMBER_EXCEPTION_FILTERS,CPU_TIME,DB_BLOCKS,' +
                          'DB_CPU_TIME,DB_TOTAL_TIME,RUN_TIME,REQUEST_ID,REQUEST_STATUS,' +
                          'URI,URI_ID_DERIVED,CLIENT_IP,USER_ID_DERIVED,USER_TYPE,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"00OB0000000ABCD","00OB0000000ABCD","Tabular","HTML","ReportBuilder",' +
                        '"Account.Name ASC","Account","150","1000","5",' +
                        '"8","6","2","1000","50",' +
                        '"300","500","1500","REP-123","Success",' +
                        '"/services/data/v54.0/analytics/reports/00OB0000000ABCD","URI-1","192.168.1.1","005xx000001234AAA","Standard",' +
                        '"LOGIN-ABC","SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_REPORT, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_REPORT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ReportEventData reportData = 
            (EventLogProcessors.ReportEventData)results[0];
        
        // Verify all fields
        System.assertEquals('00OB0000000ABCD', reportData.reportId);
        System.assertEquals('00OB0000000ABCD', reportData.reportIdDerived);
        System.assertEquals('Tabular', reportData.displayType);
        System.assertEquals('HTML', reportData.renderingType);
        System.assertEquals('ReportBuilder', reportData.origin);
        System.assertEquals('Account.Name ASC', reportData.sortValue);
        System.assertEquals('Account', reportData.entityName);
        System.assertEquals(150, reportData.averageRowSize);
        System.assertEquals(1000, reportData.rowCount);
        System.assertEquals(5, reportData.numberBuckets);
        System.assertEquals(8, reportData.numberColumns);
        System.assertEquals(6, reportData.uiNumberColumns);
        System.assertEquals(2, reportData.numberExceptionFilters);
        System.assertEquals(1000, reportData.cpuTime);
        System.assertEquals(50, reportData.dbBlocks);
        System.assertEquals(300, reportData.dbCpuTime);
        System.assertEquals(500, reportData.dbTotalTime);
        System.assertEquals(1500, reportData.runTime);
        System.assertEquals('REP-123', reportData.requestId);
        System.assertEquals('Success', reportData.requestStatus);
        System.assertEquals('/services/data/v54.0/analytics/reports/00OB0000000ABCD', reportData.uri);
        System.assertEquals('URI-1', reportData.uriIdDerived);
        System.assertEquals('192.168.1.1', reportData.clientIp);
        System.assertEquals('005xx000001234AAA', reportData.userIdDerived);
        System.assertEquals('Standard', reportData.userType);
        System.assertEquals('LOGIN-ABC', reportData.loginKey);
        System.assertEquals('SESSION-XYZ', reportData.sessionKey);
        System.assertEquals('00D123456789012345', reportData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), reportData.timestampDerived);
    }

    @IsTest
    static void testReportExportEventProcessor() {
        // Prepare test data
        String csvHeader = 'REPORT_DESCRIPTION,CLIENT_IP,CLIENT_INFO,CPU_TIME,RUN_TIME,' +
                          'REQUEST_ID,URI,URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,USER_ID_DERIVED,TIMESTAMP_DERIVED,REPORT_ID,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Monthly Sales Summary,Created by: John Doe","192.168.1.1","Mozilla/5.0 (Windows NT 10.0)","1000","1500",' +
                        '"EXP-123","/services/data/v54.0/analytics/reports/00OB0000000ABCD/export","URI-1","LOGIN-ABC","SESSION-XYZ",' +
                        '"00D123456789012345","005xx000001234AAA","2024-01-01T12:00:00Z","00OB0000000ABCD","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_REPORT_EXPORT, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_REPORT_EXPORT);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.ReportExportEventData exportData = 
            (EventLogProcessors.ReportExportEventData)results[0];
        
        // Verify all fields
        System.assertEquals('Monthly Sales Summary,Created by: John Doe', exportData.reportDescription);
        System.assertEquals('192.168.1.1', exportData.clientIp);
        System.assertEquals('Mozilla/5.0 (Windows NT 10.0)', exportData.clientInfo);
        System.assertEquals(1000, exportData.cpuTime);
        System.assertEquals(1500, exportData.runTime);
        System.assertEquals('EXP-123', exportData.requestId);
        System.assertEquals('/services/data/v54.0/analytics/reports/00OB0000000ABCD/export', exportData.uri);
        System.assertEquals('URI-1', exportData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', exportData.loginKey);
        System.assertEquals('SESSION-XYZ', exportData.sessionKey);
        System.assertEquals('00D123456789012345', exportData.organizationId);
        System.assertEquals('005xx000001234AAA', exportData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), exportData.timestampDerived);
    }

    @IsTest
    static void testRestApiProcessor() {
        // Prepare test data
        String csvHeader = 'METHOD,MEDIA_TYPE,STATUS_CODE,ENTITY_NAME,NUMBER_FIELDS,' +
                          'ROWS_PROCESSED,CONNECTED_APP_ID,CLIENT_IP,CLIENT_NAME,USER_AGENT,' +
                          'REQUEST_SIZE,RESPONSE_SIZE,REQUEST_STATUS,EXCEPTION_MESSAGE,CPU_TIME,' +
                          'DB_BLOCKS,DB_CPU_TIME,DB_TOTAL_TIME,RUN_TIME,REQUEST_ID,' +
                          'URI,URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,' +
                          'TIMESTAMP_DERIVED,USER_ID_DERIVED,USER_TYPE,ENDPOINT,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"POST","application/json","200","Account","10",' +
                        '"50","0H9xx0000004CAKCA2","192.168.1.1","SalesforceAPI","1",' +
                        '"1024","2048","Success","","1000",' +
                        '"50","300","500","1500","REST-123",' +
                        '"/services/data/v54.0/sobjects/Account","URI-1","LOGIN-ABC","SESSION-XYZ","00D123456789012345",' +
                        '"2024-01-01T12:00:00Z","005xx000001234AAA","Standard","/services/data/v54.0/sobjects/Account","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_REST_API, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_REST_API);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.RestApiData restData = 
            (EventLogProcessors.RestApiData)results[0];
        
        // Verify all fields
        System.assertEquals('POST', restData.method);
        System.assertEquals('application/json', restData.mediaType);
        System.assertEquals(200, restData.statusCode);
        System.assertEquals('Account', restData.entityName);
        System.assertEquals(10, restData.numberFields);
        System.assertEquals(50, restData.rowsProcessed);
        System.assertEquals('0H9xx0000004CAKCA2', restData.connectedAppId);
        System.assertEquals('192.168.1.1', restData.clientIp);
        System.assertEquals('SalesforceAPI', restData.clientName);
        System.assertEquals(1, restData.userAgent);
        System.assertEquals(1024, restData.requestSize);
        System.assertEquals(2048, restData.responseSize);
        System.assertEquals('Success', restData.requestStatus);
        System.assertEquals('', restData.exceptionMessage);
        System.assertEquals(1000, restData.cpuTime);
        System.assertEquals(50, restData.dbBlocks);
        System.assertEquals(300, restData.dbCpuTime);
        System.assertEquals(500, restData.dbTotalTime);
        System.assertEquals(1500, restData.runTime);
        System.assertEquals('REST-123', restData.requestId);
        System.assertEquals('/services/data/v54.0/sobjects/Account', restData.uri);
        System.assertEquals('URI-1', restData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', restData.loginKey);
        System.assertEquals('SESSION-XYZ', restData.sessionKey);
        System.assertEquals('00D123456789012345', restData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), restData.timestampDerived);
        System.assertEquals('005xx000001234AAA', restData.userIdDerived);
        System.assertEquals('Standard', restData.userType);
    }

    @IsTest
    static void testSandboxProcessor() {
        // Prepare test data
        String csvHeader = 'CURRENT_SANDBOX_ORG_ID,PENDING_SANDBOX_ORG_ID,SANDBOX_ID,ORGANIZATION_ID,' +
                          'STATUS,REQUEST_ID,USER_ID_DERIVED,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"00D000000000123","00D000000000456","0GR000000000789","00D123456789012345",' +
                        '"Creating","SBX-123","005xx000001234AAA","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_SANDBOX, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_SANDBOX);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.SandboxData sandboxData = 
            (EventLogProcessors.SandboxData)results[0];
        
        // Verify all fields
        System.assertEquals('00D000000000123', sandboxData.currentSandboxOrgId);
        System.assertEquals('00D000000000456', sandboxData.pendingSandboxOrgId);
        System.assertEquals('0GR000000000789', sandboxData.sandboxId);
        System.assertEquals('00D123456789012345', sandboxData.organizationId);
        System.assertEquals('Creating', sandboxData.status);
        System.assertEquals('SBX-123', sandboxData.requestId);
        System.assertEquals('005xx000001234AAA', sandboxData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), sandboxData.timestampDerived);
    }

    @IsTest
    static void testSearchEventProcessor() {
        // Prepare test data
        String csvHeader = 'SEARCH_QUERY,QUERY_ID,NUM_RESULTS,PREFIXES_SEARCHED,ORGANIZATION_ID,' +
                          'REQUEST_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"FIND {John Doe} IN ALL FIELDS","SRCH-123","25","name,email,phone,account",' +
                        '"00D123456789012345","REQ-123","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_SEARCH, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_SEARCH);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.SearchEventData searchData = 
            (EventLogProcessors.SearchEventData)results[0];
        
        // Verify all fields
        System.assertEquals('FIND {John Doe} IN ALL FIELDS', searchData.searchQuery);
        System.assertEquals('SRCH-123', searchData.queryId);
        System.assertEquals(25, searchData.numResults);
        System.assertEquals('name,email,phone,account', searchData.prefixesSearched);
        System.assertEquals('00D123456789012345', searchData.organizationId);
        System.assertEquals('REQ-123', searchData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), searchData.timestampDerived);
    }

    @IsTest
    static void testSearchClickEventProcessor() {
        // Prepare test data
        String csvHeader = 'CLICKED_RECORD_ID,RANK,QUERY_ID,ORGANIZATION_ID,' +
                          'REQUEST_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"001xx000003G9yzAAC","3","SRCH-123","00D123456789012345",' +
                        '"CLICK-123","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_SEARCH_CLICK, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_SEARCH_CLICK);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.SearchClickEventData clickData = 
            (EventLogProcessors.SearchClickEventData)results[0];
        
        // Verify all fields
        System.assertEquals('001xx000003G9yzAAC', clickData.clickedRecordId);
        System.assertEquals(3, clickData.rank);
        System.assertEquals('SRCH-123', clickData.queryId);
        System.assertEquals('00D123456789012345', clickData.organizationId);
        System.assertEquals('CLICK-123', clickData.requestId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), clickData.timestampDerived);
    }

    @IsTest
    static void testSitesEventProcessor() {
        // Prepare test data
        String csvHeader = 'PAGE_NAME,SITE_ID,HTTP_METHOD,HTTP_HEADERS,REQUEST_TYPE,' +
                          'REQUEST_STATUS,QUERY,URI,URI_ID_DERIVED,IS_API,' +
                          'IS_ERROR,IS_FIRST_REQUEST,IS_GUEST,IS_SECURE,CPU_TIME,' +
                          'DB_TOTAL_TIME,RUN_TIME,CLIENT_IP,LOGIN_KEY,SESSION_KEY,' +
                          'ORGANIZATION_ID,REQUEST_ID,USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"HomePage","0DM000000000123","GET","User-Agent: Mozilla/5.0","Page",' +
                        '"Success","param1=value1","https://mysite.force.com/home","URI-1","false",' +
                        '"false","true","false","true","1000",' +
                        '"500","1500","192.168.1.1","LOGIN-ABC","SESSION-XYZ",' +
                        '"00D123456789012345","SITE-123","005xx000001234AAA","Standard","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_SITES, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_SITES);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.SitesEventData sitesData = 
            (EventLogProcessors.SitesEventData)results[0];
        
        // Verify all fields
        System.assertEquals('HomePage', sitesData.pageName);
        System.assertEquals('0DM000000000123', sitesData.siteId);
        System.assertEquals('GET', sitesData.httpMethod);
        System.assertEquals('User-Agent: Mozilla/5.0', sitesData.httpHeaders);
        System.assertEquals('Page', sitesData.requestType);
        System.assertEquals('Success', sitesData.requestStatus);
        System.assertEquals('param1=value1', sitesData.query);
        System.assertEquals('https://mysite.force.com/home', sitesData.uri);
        System.assertEquals('URI-1', sitesData.uriIdDerived);
        System.assertEquals(false, sitesData.isApi);
        System.assertEquals(false, sitesData.isError);
        System.assertEquals(true, sitesData.isFirstRequest);
        System.assertEquals(false, sitesData.isGuest);
        System.assertEquals(true, sitesData.isSecure);
        System.assertEquals(1000, sitesData.cpuTime);
        System.assertEquals(500, sitesData.dbTotalTime);
        System.assertEquals(1500, sitesData.runTime);
        System.assertEquals('192.168.1.1', sitesData.clientIp);
        System.assertEquals('LOGIN-ABC', sitesData.loginKey);
        System.assertEquals('SESSION-XYZ', sitesData.sessionKey);
        System.assertEquals('00D123456789012345', sitesData.organizationId);
        System.assertEquals('SITE-123', sitesData.requestId);
        System.assertEquals('005xx000001234AAA', sitesData.userIdDerived);
        System.assertEquals('Standard', sitesData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), sitesData.timestampDerived);
    }

    @IsTest
    static void testTimeBasedWorkflowProcessor() {
        // Prepare test data
        String csvHeader = 'TYPE,DATA,LOG_GROUP_ID,NUMBER_OF_RECORDS,CPU_TIME,' +
                          'RUN_TIME,CLIENT_IP,REQUEST_ID,URI,URI_ID_DERIVED,' +
                          'LOGIN_KEY,SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"WorkflowTimeEvaluation","Email_Alert","WF-GROUP-123","50","1000",' +
                        '"1500","192.168.1.1","WF-123","/services/data/v54.0/workflow/time-triggers","URI-1",' +
                        '"LOGIN-ABC","SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.TimeBasedWorkflowData workflowData = 
            (EventLogProcessors.TimeBasedWorkflowData)results[0];
        
        // Verify all fields
        System.assertEquals('WorkflowTimeEvaluation', workflowData.type);
        System.assertEquals('Email_Alert', workflowData.data);
        System.assertEquals('WF-GROUP-123', workflowData.logGroupId);
        System.assertEquals(50, workflowData.numberOfRecords);
        System.assertEquals(1000, workflowData.cpuTime);
        System.assertEquals(1500, workflowData.runTime);
        System.assertEquals('192.168.1.1', workflowData.clientIp);
        System.assertEquals('WF-123', workflowData.requestId);
        System.assertEquals('/services/data/v54.0/workflow/time-triggers', workflowData.uri);
        System.assertEquals('URI-1', workflowData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', workflowData.loginKey);
        System.assertEquals('SESSION-XYZ', workflowData.sessionKey);
        System.assertEquals('00D123456789012345', workflowData.organizationId);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), workflowData.timestampDerived);
        System.assertEquals('005xx000001234AAA', workflowData.userIdDerived);
    }

    @IsTest
    static void testTransactionSecurityProcessor() {
        // Prepare test data
        String csvHeader = 'POLICY_ID,POLICY_ID_DERIVED,RESULT,CPU_TIME,RUN_TIME,' +
                          'CLIENT_IP,REQUEST_ID,URI,URI_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,USER_ID_DERIVED,EVENT_TIMESTAMP,TIMESTAMP_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"0NIxx0000004CAKCA2","0NIxx0000004CAKCA2","Block","1000","1500",' +
                        '"192.168.1.1","SEC-123","/services/data/v54.0/sobjects/Account","URI-1","LOGIN-ABC",' +
                        '"SESSION-XYZ","00D123456789012345","005xx000001234AAA","2024-01-01T11:00:00Z","2024-01-01T12:00:00Z",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.TransactionSecurityData securityData = 
            (EventLogProcessors.TransactionSecurityData)results[0];
        
        // Verify all fields
        System.assertEquals('0NIxx0000004CAKCA2', securityData.policyId);
        System.assertEquals('0NIxx0000004CAKCA2', securityData.policyIdDerived);
        System.assertEquals('Block', securityData.result);
        System.assertEquals(1000, securityData.cpuTime);
        System.assertEquals(1500, securityData.runTime);
        System.assertEquals('192.168.1.1', securityData.clientIp);
        System.assertEquals('SEC-123', securityData.requestId);
        System.assertEquals('/services/data/v54.0/sobjects/Account', securityData.uri);
        System.assertEquals('URI-1', securityData.uriIdDerived);
        System.assertEquals('LOGIN-ABC', securityData.loginKey);
        System.assertEquals('SESSION-XYZ', securityData.sessionKey);
        System.assertEquals('00D123456789012345', securityData.organizationId);
        System.assertEquals('005xx000001234AAA', securityData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 11, 0, 0), securityData.eventTimestamp);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), securityData.timestampDerived);
    }

    @IsTest
    static void testUITelemetryNavigationTimingProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,PAGE_URL,' +
                          'URL,BROWSER_NAME,BROWSER_VERSION,INITIATOR_TYPE,NAVIGATION_TYPE,' +
                          'REDIRECT_COUNT,RENDER_BLOCKING_STATUS,DEVICE_MODEL,DEVICE_PLATFORM,DEVICE_SESSION_ID,' +
                          'OS_NAME,OS_VERSION,CLIENT_GEO,CLIENT_ID,CLIENT_IP,' +
                          'CONNECTION_TYPE,NEXT_HOP_PROTOCOL,DECODED_BODY_SIZE,ENCODED_BODY_SIZE,RESPONSE_STATUS,' +
                          'TRANSFER_SIZE,CONNECT_END,CONNECT_START,DOM_COMPLETE,DOM_CONTENT_LOADED_EVENT_END,' +
                          'DOM_CONTENT_LOADED_EVENT_START,DOM_INTERACTIVE,DOMAIN_LOOKUP_END,DOMAIN_LOOKUP_START,DURATION,' +
                          'FETCH_START,FIRST_INTERIM_RESPONSE_START,LOAD_EVENT_END,LOAD_EVENT_START,REDIRECT_END,' +
                          'REDIRECT_START,REQUEST_START,RESPONSE_END,RESPONSE_START,SECURE_CONNECT_START,' +
                          'START_TIME,UNLOAD_EVENT_END,UNLOAD_EVENT_START,WORKER_START,SDK_APP_TYPE,' +
                          'SDK_APP_VERSION,SDK_VERSION,UI_EVENT_RELATIVE_TIMESTAMP,UI_EVENT_TIMESTAMP,UI_ROOT_ACTIVITY_ID,' +
                          'UI_THREAD_RESPONSE_DELAY,LOGIN_KEY,SESSION_KEY,SERVER_REQUEST_ID,ORGANIZATION_ID,' +
                          'REQUEST_ID,USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Sales","Record","001xx000003G9yzAAC","Account","/lightning/r/Account/001xx000003G9yzAAC/view",' +  // Page Info
                        '"https://myorg.lightning.force.com/lightning/r/Account/001xx000003G9yzAAC/view","Chrome","120.0.0.0","navigation","navigate",' +  // Browser Info
                        '"2","blocking","iPhone","iOS","DS-123ABC",' +                                 // Device Info
                        '"iOS","16.0","US-East","CL-123","192.168.1.1",' +                           // Location & Client
                        '"4g","h2","50000","45000","200",' +                                         // Connection & Response
                        '"55000","1000","800","5000","3000",' +                                      // Timing 1
                        '"2800","2500","600","400","6000",' +                                        // Timing 2
                        '"100","1200","5500","5200","1100",' +                                       // Timing 3
                        '"900","1300","4800","4000","950",' +                                        // Timing 4
                        '"0","700","500","200","iOS",' +                                             // Timing 5 & SDK
                        '"2.0.0","1.5.0","1500","1642694400000","ACT-ROOT-123",' +                  // SDK & UI Event
                        '"300","LOGIN-ABC","SESSION-XYZ","SERVER-REQ-123","00D123456789012345",' +   // Session Info
                        '"UI-123","005xx000001234AAA","Standard","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n'; // User Info

        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.UITelemetryNavigationTimingData timingData = 
            (EventLogProcessors.UITelemetryNavigationTimingData)results[0];
        
        // Verify fields (grouped by category)
        // Page Information
        System.assertEquals('Sales', timingData.appName);
        System.assertEquals('Record', timingData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', timingData.pageEntityId);
        System.assertEquals('Account', timingData.pageEntityType);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', timingData.pageUrl);
        System.assertEquals('https://myorg.lightning.force.com/lightning/r/Account/001xx000003G9yzAAC/view', timingData.url);

        // Browser Information
        System.assertEquals('Chrome', timingData.browserName);
        System.assertEquals('120.0.0.0', timingData.browserVersion);
        System.assertEquals('navigation', timingData.initiatorType);
        System.assertEquals('navigate', timingData.navigationType);
        System.assertEquals(2, timingData.redirectCount);
        System.assertEquals('blocking', timingData.renderBlockingStatus);

        // Device Information
        System.assertEquals('iPhone', timingData.deviceModel);
        System.assertEquals('iOS', timingData.devicePlatform);
        System.assertEquals('DS-123ABC', timingData.deviceSessionId);
        System.assertEquals('iOS', timingData.osName);
        System.assertEquals('16.0', timingData.osVersion);

        // Location and Network
        System.assertEquals('US-East', timingData.clientGeo);
        System.assertEquals('CL-123', timingData.clientId);
        System.assertEquals('192.168.1.1', timingData.clientIp);
        System.assertEquals('4g', timingData.connectionType);
        System.assertEquals('h2', timingData.nextHopProtocol);

        // Response Metrics
        System.assertEquals(50000, timingData.decodedBodySize);
        System.assertEquals(45000, timingData.encodedBodySize);
        System.assertEquals(200, timingData.responseStatus);
        System.assertEquals(55000, timingData.transferSize);

        // Navigation Timing
        System.assertEquals(1000, timingData.connectEnd);
        System.assertEquals(800, timingData.connectStart);
        System.assertEquals(5000, timingData.domComplete);
        System.assertEquals(3000, timingData.domContentLoadedEventEnd);
        System.assertEquals(2800, timingData.domContentLoadedEventStart);
        System.assertEquals(2500, timingData.domInteractive);
        System.assertEquals(600, timingData.domainLookupEnd);
        System.assertEquals(400, timingData.domainLookupStart);
        System.assertEquals(6000, timingData.duration);

        // SDK Information
        System.assertEquals('iOS', timingData.sdkAppType);
        System.assertEquals('2.0.0', timingData.sdkAppVersion);
        System.assertEquals('1.5.0', timingData.sdkVersion);

        // Session Information
        System.assertEquals('LOGIN-ABC', timingData.loginKey);
        System.assertEquals('SESSION-XYZ', timingData.sessionKey);
        System.assertEquals('SERVER-REQ-123', timingData.serverRequestId);
        System.assertEquals('00D123456789012345', timingData.organizationId);
        System.assertEquals('UI-123', timingData.requestId);

        // User Information
        System.assertEquals('005xx000001234AAA', timingData.userIdDerived);
        System.assertEquals('Standard', timingData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), timingData.timestampDerived);
    }

    @IsTest
    static void testUITelemetryResourceTimingProcessor() {
        // Prepare test data
        String csvHeader = 'APP_NAME,PAGE_CONTEXT,PAGE_ENTITY_ID,PAGE_ENTITY_TYPE,PAGE_URL,' +
                          'URL,BROWSER_NAME,BROWSER_VERSION,INITIATOR_TYPE,RENDER_BLOCKING_STATUS,' +
                          'DEVICE_MODEL,DEVICE_PLATFORM,DEVICE_SESSION_ID,OS_NAME,OS_VERSION,' +
                          'CLIENT_GEO,CLIENT_ID,CLIENT_IP,CONNECTION_TYPE,NEXT_HOP_PROTOCOL,' +
                          'DECODED_BODY_SIZE,ENCODED_BODY_SIZE,RESPONSE_STATUS,TRANSFER_SIZE,CONNECT_END,' +
                          'CONNECT_START,DOMAIN_LOOKUP_END,DOMAIN_LOOKUP_START,DURATION,FETCH_START,' +
                          'FIRST_INTERIM_RESPONSE_START,REDIRECT_END,REDIRECT_START,REQUEST_START,RESPONSE_END,' +
                          'RESPONSE_START,SECURE_CONNECT_START,START_TIME,WORKER_START,SDK_APP_TYPE,' +
                          'SDK_APP_VERSION,SDK_VERSION,UI_EVENT_RELATIVE_TIMESTAMP,UI_EVENT_TIMESTAMP,UI_ROOT_ACTIVITY_ID,' +
                          'UI_THREAD_RESPONSE_DELAY,LOGIN_KEY,SESSION_KEY,SERVER_REQUEST_ID,ORGANIZATION_ID,' +
                          'REQUEST_ID,USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"Sales","Record","001xx000003G9yzAAC","Account","/lightning/r/Account/001xx000003G9yzAAC/view",' +  // Page Info
                        '"https://myorg.lightning.force.com/resource/styles.css","Chrome","120.0.0.0","css","blocking",' +      // Resource Info
                        '"iPhone","iOS","DS-123ABC","iOS","16.0",' +                                                           // Device Info
                        '"US-East","CL-123","192.168.1.1","4g","h2",' +                                                       // Network Info
                        '"25000","20000","200","30000","1000",' +                                                             // Response Metrics
                        '"800","600","400","1500","100",' +                                                                    // Timing 1
                        '"1200","1100","900","1300","4800",' +                                                                // Timing 2
                        '"4000","950","0","200","iOS",' +                                                                     // Timing 3 & SDK
                        '"2.0.0","1.5.0","1500","1642694400000","ACT-ROOT-123",' +                                           // SDK & UI Event
                        '"300","LOGIN-ABC","SESSION-XYZ","SERVER-REQ-123","00D123456789012345",' +                           // Session Info
                        '"RES-123","005xx000001234AAA","Standard","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';  // User Info

        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.UITelemetryResourceTimingData resourceData = 
            (EventLogProcessors.UITelemetryResourceTimingData)results[0];
        
        // Verify fields (grouped by category)
        // Page Information
        System.assertEquals('Sales', resourceData.appName);
        System.assertEquals('Record', resourceData.pageContext);
        System.assertEquals('001xx000003G9yzAAC', resourceData.pageEntityId);
        System.assertEquals('Account', resourceData.pageEntityType);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', resourceData.pageUrl);
        System.assertEquals('https://myorg.lightning.force.com/resource/styles.css', resourceData.url);

        // Browser and Resource Information
        System.assertEquals('Chrome', resourceData.browserName);
        System.assertEquals('120.0.0.0', resourceData.browserVersion);
        System.assertEquals('css', resourceData.initiatorType);
        System.assertEquals('blocking', resourceData.renderBlockingStatus);

        // Device Information
        System.assertEquals('iPhone', resourceData.deviceModel);
        System.assertEquals('iOS', resourceData.devicePlatform);
        System.assertEquals('DS-123ABC', resourceData.deviceSessionId);
        System.assertEquals('iOS', resourceData.osName);
        System.assertEquals('16.0', resourceData.osVersion);

        // Network Information
        System.assertEquals('US-East', resourceData.clientGeo);
        System.assertEquals('CL-123', resourceData.clientId);
        System.assertEquals('192.168.1.1', resourceData.clientIp);
        System.assertEquals('4g', resourceData.connectionType);
        System.assertEquals('h2', resourceData.nextHopProtocol);

        // Resource Metrics
        System.assertEquals(25000, resourceData.decodedBodySize);
        System.assertEquals(20000, resourceData.encodedBodySize);
        System.assertEquals(200, resourceData.responseStatus);
        System.assertEquals(30000, resourceData.transferSize);

        // Resource Timing
        System.assertEquals(1000, resourceData.connectEnd);
        System.assertEquals(800, resourceData.connectStart);
        System.assertEquals(600, resourceData.domainLookupEnd);
        System.assertEquals(400, resourceData.domainLookupStart);
        System.assertEquals(1500, resourceData.duration);
        System.assertEquals(100, resourceData.fetchStart);
        System.assertEquals(1200, resourceData.firstInterimResponseStart);
        System.assertEquals(1100, resourceData.redirectEnd);
        System.assertEquals(900, resourceData.redirectStart);
        System.assertEquals(1300, resourceData.requestStart);
        System.assertEquals(4800, resourceData.responseEnd);
        System.assertEquals(4000, resourceData.responseStart);
        System.assertEquals(950, resourceData.secureConnectStart);
        System.assertEquals(0, resourceData.startTime);
        System.assertEquals(200, resourceData.workerStart);

        // SDK Information
        System.assertEquals('iOS', resourceData.sdkAppType);
        System.assertEquals('2.0.0', resourceData.sdkAppVersion);
        System.assertEquals('1.5.0', resourceData.sdkVersion);

        // UI Event Information
        System.assertEquals(1500, resourceData.uiEventRelativeTimestamp);
        System.assertEquals(1642694400000L, resourceData.uiEventTimestamp);
        System.assertEquals('ACT-ROOT-123', resourceData.uiRootActivityId);
        System.assertEquals(300, resourceData.uiThreadResponseDelay);

        // Session Information
        System.assertEquals('LOGIN-ABC', resourceData.loginKey);
        System.assertEquals('SESSION-XYZ', resourceData.sessionKey);
        System.assertEquals('SERVER-REQ-123', resourceData.serverRequestId);
        System.assertEquals('00D123456789012345', resourceData.organizationId);
        System.assertEquals('RES-123', resourceData.requestId);

        // User Information
        System.assertEquals('005xx000001234AAA', resourceData.userIdDerived);
        System.assertEquals('Standard', resourceData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), resourceData.timestampDerived);
    }

    @IsTest
    static void testUriEventProcessor() {
        // Prepare test data
        String csvHeader = 'CLIENT_IP,CPU_TIME,RUN_TIME,DB_BLOCKS,DB_CPU_TIME,' +
                          'DB_TOTAL_TIME,REQUEST_ID,REQUEST_STATUS,URI,URI_ID_DERIVED,' +
                          'REFERRER_URI,LOGIN_KEY,SESSION_KEY,USER_ID_DERIVED,USER_TYPE,' +
                          'ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID,TIMESTAMP\n';
                          
        String csvData = '"192.168.1.1","1000","1500","50","300",' +
                        '"500","URI-123","Success","/lightning/r/Account/001xx000003G9yzAAC/view","URI-1",' +
                        '"/lightning/o/Account/list","LOGIN-ABC","SESSION-XYZ","005xx000001234AAA","Standard",' +
                        '"00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_URI, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_URI);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.UriEventData uriData = 
            (EventLogProcessors.UriEventData)results[0];
        
        // Verify fields (grouped by category)
        // Client Information
        System.assertEquals('192.168.1.1', uriData.clientIp);

        // Performance Metrics
        System.assertEquals(1000, uriData.cpuTime);
        System.assertEquals(1500, uriData.runTime);
        System.assertEquals(50, uriData.dbBlocks);
        System.assertEquals(300, uriData.dbCpuTime);
        System.assertEquals(500, uriData.dbTotalTime);

        // Request Information
        System.assertEquals('URI-123', uriData.requestId);
        System.assertEquals('Success', uriData.requestStatus);
        System.assertEquals('/lightning/r/Account/001xx000003G9yzAAC/view', uriData.uri);
        System.assertEquals('URI-1', uriData.uriIdDerived);
        System.assertEquals('/lightning/o/Account/list', uriData.referrerUri);

        // Session Information
        System.assertEquals('LOGIN-ABC', uriData.loginKey);
        System.assertEquals('SESSION-XYZ', uriData.sessionKey);

        // User Information
        System.assertEquals('005xx000001234AAA', uriData.userIdDerived);
        System.assertEquals('Standard', uriData.userType);

        // Organization Information
        System.assertEquals('00D123456789012345', uriData.organizationId);

        // Timestamp
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), uriData.timestampDerived);
    }
    
    @IsTest
    static void testVisualforceRequestProcessor() {
        // Prepare test data
        String csvHeader = 'PAGE_NAME,MANAGED_PACKAGE_NAMESPACE,VIEW_STATE_SIZE,CONTROLLER_TYPE,' +
                          'HTTP_METHOD,IS_AJAX_REQUEST,IS_FIRST_REQUEST,QUERY,REQUEST_SIZE,' +
                          'REQUEST_TYPE,RESPONSE_SIZE,REQUEST_STATUS,CPU_TIME,RUN_TIME,' +
                          'DB_BLOCKS,DB_CPU_TIME,DB_TOTAL_TIME,CLIENT_IP,USER_AGENT,URI,' +
                          'URI_ID_DERIVED,LOGIN_KEY,SESSION_KEY,REQUEST_ID,ORGANIZATION_ID,' +
                          'USER_ID_DERIVED,USER_TYPE,TIMESTAMP_DERIVED,'+
                          'TIMESTAMP,USER_ID\n';
                          
        String csvData = 'MyVFPage,myns,50000,1,' +
                        'GET,true,true,SELECT Id FROM Account,1024,' +
                        'PAGE,2048,SUCCESS,1000,3000,' +
                        '100,500,2000,192.168.1.1,1,/apex/MyVFPage,' +
                        'VF_PAGE_1,abc123,def456,req123,00D123456789012345,' +
                        '005xx000001234AAA,Standard,2024-01-01T12:00:00Z,'+
                        '20130715233322.670,005xx000001234AAA\n';

        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.VisualforceRequestProcessor processor = (EventLogProcessors.VisualforceRequestProcessor)EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.VisualforceRequestData vfData = 
            (EventLogProcessors.VisualforceRequestData)results[0];
        
        // Verify all fields
        System.assertNotEquals(null, vfData.timestamp);
        System.assertEquals('005xx000001234AAA', vfData.userId);
        System.assertEquals('MyVFPage', vfData.pageName);
        System.assertEquals('myns', vfData.managedPackageNamespace);
        System.assertEquals(50000, vfData.viewStateSize);
        System.assertEquals(1, vfData.controllerType);
        System.assertEquals('GET', vfData.httpMethod);
        System.assertEquals(true, vfData.isAjaxRequest);
        System.assertEquals(true, vfData.isFirstRequest);
        System.assertEquals('SELECT Id FROM Account', vfData.query);
        System.assertEquals(1024, vfData.requestSize);
        System.assertEquals('PAGE', vfData.requestType);
        System.assertEquals(2048, vfData.responseSize);
        System.assertEquals('SUCCESS', vfData.requestStatus);
        System.assertEquals(1000, vfData.cpuTime);
        System.assertEquals(3000, vfData.runTime);
        System.assertEquals(100, vfData.dbBlocks);
        System.assertEquals(500, vfData.dbCpuTime);
        System.assertEquals(2000, vfData.dbTotalTime);
        System.assertEquals('192.168.1.1', vfData.clientIp);
        System.assertEquals(1, vfData.userAgent);
        System.assertEquals('/apex/MyVFPage', vfData.uri);
        System.assertEquals('VF_PAGE_1', vfData.uriIdDerived);
        System.assertEquals('abc123', vfData.loginKey);
        System.assertEquals('def456', vfData.sessionKey);
        System.assertEquals('req123', vfData.requestId);
        System.assertEquals('00D123456789012345', vfData.organizationId);
        System.assertEquals('005xx000001234AAA', vfData.userIdDerived);
        System.assertEquals('Standard', vfData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), vfData.timestampDerived);
    }

    @IsTest
    static void testWaveChangeEventProcessor() {
        // Prepare test data
        String csvHeader = 'ANALYTICS_MODE,PAGE_CONTEXT,PAGE_ID,RECORDING_ID,SAVED_VIEW_ID,' +
                          'TAB_ID,TYPE,VIEW_MODE,WAVE_SESSION_ID,WAVE_TIMESTAMP,' +
                          'IS_NEW,REOPEN_COUNT,IS_MOBILE,CPU_TIME,RUN_TIME,' +
                          'CLIENT_IP,REQUEST_ID,URI,URI_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID_DERIVED,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"dashboard","Sales Analytics","0FK123000000ABCD","REC-123","VIEW-456",' +
                        '"TAB-789","DashboardStateChange","view","WAVE-SESSION-123","16426944",' +
                        '"true","2","false","1000","1500",' +
                        '"192.168.1.1","WAVE-123","/analytics/dashboard/01Z123000000ABCD","URI-1","LOGIN-ABC",' +
                        '"SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_WAVE_CHANGE, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_WAVE_CHANGE);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.WaveChangeEventData waveData = 
            (EventLogProcessors.WaveChangeEventData)results[0];
        
        // Verify fields (grouped by category)
        // Analytics Context
        System.assertEquals('dashboard', waveData.analyticsMode);
        System.assertEquals('Sales Analytics', waveData.pageContext);
        System.assertEquals('0FK123000000ABCD', waveData.pageId);
        System.assertEquals('REC-123', waveData.recordId);
        System.assertEquals('VIEW-456', waveData.savedViewId);
        System.assertEquals('TAB-789', waveData.tabId);

        // Wave Event Details
        System.assertEquals('DashboardStateChange', waveData.type);
        System.assertEquals('view', waveData.viewMode);
        System.assertEquals('WAVE-SESSION-123', waveData.waveSessionId);
        System.assertEquals(16426944, waveData.waveTimestamp);

        // State Information
        System.assertEquals(true, waveData.isNew);
        System.assertEquals(2, waveData.reopencount);
        System.assertEquals(false, waveData.isMobile);

        // Performance Metrics
        System.assertEquals(1000, waveData.cpuTime);
        System.assertEquals(1500, waveData.runTime);

        // Request Information
        System.assertEquals('192.168.1.1', waveData.clientIp);
        System.assertEquals('WAVE-123', waveData.requestId);
        System.assertEquals('/analytics/dashboard/01Z123000000ABCD', waveData.uri);
        System.assertEquals('URI-1', waveData.uriIdDerived);

        // Session Information
        System.assertEquals('LOGIN-ABC', waveData.loginKey);
        System.assertEquals('SESSION-XYZ', waveData.sessionKey);
        System.assertEquals('00D123456789012345', waveData.organizationId);

        // User Information
        System.assertEquals('005xx000001234AAA', waveData.userIdDerived);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), waveData.timestampDerived);
    }

    @IsTest
    static void testWaveDownloadEventProcessor() {
        // Prepare test data
        String csvHeader = 'ASSET_ID,ASSET_TYPE,DATASET_IDS,DOWNLOAD_ERROR,DOWNLOAD_FORMAT,' +
                          'NUMBER_OF_RECORDS,CPU_TIME,RUN_TIME,CLIENT_IP,WAVE_SESSION_ID,' +
                          'WAVE_TIMESTAMP,REQUEST_ID,URI,URI_ID_DERIVED,LOGIN_KEY,' +
                          'SESSION_KEY,ORGANIZATION_ID,TIMESTAMP_DERIVED,USER_ID_DERIVED,USER_TYPE,' +
                          'USER_ID,TIMESTAMP\n';
                          
        String csvData = '"0FK123000000ABCD","dashboard","0Fb123,0Fb456","",' +
                        '"CSV","1000","2000","2500","192.168.1.1","WAVE-SESSION-123",' +
                        '"16426944","WAVE-DL-123","/analytics/download/0FK123000000ABCD","URI-1","LOGIN-ABC",' +
                        '"SESSION-XYZ","00D123456789012345","2024-01-01T12:00:00Z","005xx000001234AAA","Standard",' +
                        '"005xx000001234AAA","20130715233322.670"\n';
        
        // Create test file content
        String fileContent = csvHeader + csvData;
        SObject logFile = createTestEventLogFile(EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD, fileContent);
        
        // Process the test data
        Test.startTest();
        EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD);
        TestBatchProcessor batchProcessor = new TestBatchProcessor();
        processor.batchProcessLogFile(logFile, batchProcessor);
        List<EventLogProcessors.IBaseEventData> results = batchProcessor.processedRecords;
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should have processed one record');
        
        EventLogProcessors.WaveDownloadEventData downloadData = 
            (EventLogProcessors.WaveDownloadEventData)results[0];
        
        // Verify fields (grouped by category)
        // Asset Information
        System.assertEquals('0FK123000000ABCD', downloadData.assetId);
        System.assertEquals('dashboard', downloadData.assetType);
        System.assertEquals('0Fb123,0Fb456', downloadData.datasetIds);
        System.assertEquals('', downloadData.downloadError);
        System.assertEquals('CSV', downloadData.downloadFormat);
        System.assertEquals(1000, downloadData.numberOfRecords);

        // Performance Metrics
        System.assertEquals(2000, downloadData.cpuTime);
        System.assertEquals(2500, downloadData.runTime);

        // Client Information
        System.assertEquals('192.168.1.1', downloadData.clientIp);

        // Wave Session Details
        System.assertEquals('WAVE-SESSION-123', downloadData.waveSessionId);
        System.assertEquals(16426944, downloadData.waveTimestamp);

        // Request Information
        System.assertEquals('WAVE-DL-123', downloadData.requestId);
        System.assertEquals('/analytics/download/0FK123000000ABCD', downloadData.uri);
        System.assertEquals('URI-1', downloadData.uriIdDerived);

        // Session Information
        System.assertEquals('LOGIN-ABC', downloadData.loginKey);
        System.assertEquals('SESSION-XYZ', downloadData.sessionKey);
        System.assertEquals('00D123456789012345', downloadData.organizationId);

        // User Information
        System.assertEquals('005xx000001234AAA', downloadData.userIdDerived);
        System.assertEquals('Standard', downloadData.userType);
        System.assertEquals(Datetime.newInstanceGmt(2024, 1, 1, 12, 0, 0), downloadData.timestampDerived);
    }

    @IsTest
    static void testCSVParser() {
        // Test CSV with quoted values
        String csvHeader = '"FIELD1","FIELD2","FIELD3"\n';
        String csvData = '"value1","value,2","value3"\n' +
                        '"value4","value5","value6"\n';
        String fileContent = csvHeader + csvData;

        EventLogProcessors.CSVParser parser = new EventLogProcessors.CSVParser();
        parser.parse(fileContent);

        // Parse the CSV content
        List<String> headers = parser.getHeaders();
        List<String> row = parser.next();
        
        // Verify headers
        System.assertEquals(3, headers.size(), 'Should have 3 header columns');
        System.assertEquals('FIELD1', headers[0], 'First header should match');
        System.assertEquals('FIELD2', headers[1], 'Second header should match');
        System.assertEquals('FIELD3', headers[2], 'Third header should match');
        
        // Verify first row
        System.assertEquals(3, row.size(), 'First row should have 3 columns');
        System.assertEquals('value1', row[0], 'First value should match');
        System.assertEquals('value,2', row[1], 'Second value should match (with comma)');
        System.assertEquals('value3', row[2], 'Third value should match');
        
        // Verify second row
        row = parser.next();
        System.assertEquals(3, row.size(), 'Second row should have 3 columns');
        System.assertEquals('value4', row[0], 'Fourth value should match');
        System.assertEquals('value5', row[1], 'Fifth value should match');
        System.assertEquals('value6', row[2], 'Sixth value should match');
        
        // Test handling of empty values
        String emptyValuesCsv = '"value1","","value3"\n';
        fileContent = csvHeader + emptyValuesCsv;
        parser = new EventLogProcessors.CSVParser();
        parser.parse(fileContent);
        headers = parser.getHeaders();
        row = parser.next();

        System.assertEquals(3, row.size(), 'Row with empty value should have 3 column');
        System.assertEquals('value1', row[0], 'First value should match');
        System.assertEquals('', row[1], 'Empty value should be preserved');
        System.assertEquals('value3', row[2], 'Third value should match');
        
        // Test handling of quoted values with special characters
        String specialCharsCsv = '"value1","value\nwith\nlinebreaks","value,with,commas"\n';
        fileContent = csvHeader + specialCharsCsv;
        parser = new EventLogProcessors.CSVParser();
        parser.parse(fileContent);
        headers = parser.getHeaders();
        row = parser.next();

        System.assertEquals('value1', row[0], 'First value should match');
        System.assertEquals('value\nwith\nlinebreaks', row[1], 'Value with linebreaks should be preserved');
        System.assertEquals('value,with,commas', row[2], 'Value with commas should be preserved');

        String mixCsv = csvHeader + specialCharsCsv + emptyValuesCsv;
        parser = new EventLogProcessors.CSVParser();
        parser.parse(mixCsv);
        headers = parser.getHeaders();
        row = parser.next();

        System.assertEquals('value1', row[0], 'First value should match');
        System.assertEquals('value\nwith\nlinebreaks', row[1], 'Value with linebreaks should be preserved');
        System.assertEquals('value,with,commas', row[2], 'Value with commas should be preserved');
        
        row = parser.next();
        System.assertEquals('value1', row[0], 'First value should match');
        System.assertEquals('', row[1], 'Empty value should be preserved');
        System.assertEquals('value3', row[2], 'Third value should match');
    }

    @IsTest
    static void testCSVParserPerformance() {
        // Arrange
        Integer numRows = 10000;
        Integer numFields = 10;
        Integer fieldSize = 100;
        String csvContent = generateCSV(numRows, numFields, fieldSize);
        
        EventLogProcessors.CSVParser parser = new EventLogProcessors.CSVParser();
        
        Test.startTest();
        Integer cpuTime = Limits.getCpuTime();
        Integer heapSize = Limits.getHeapSize();
        parser.parse(csvContent);
        List<String> headers = parser.getHeaders();

        Integer rowIndex = 0;
        for (Iterator<List<String>> iter = parser.iterator(); iter.hasNext(); ) {
            List<String> row = iter.next();
            rowIndex++;
        }
        Test.stopTest();
        
        // Assert
        System.assertEquals(numFields, headers.size());
        System.assertEquals(numRows, rowIndex);
        Integer usedCpuTime = Limits.getCpuTime() - cpuTime;
        Integer usedHeapSize = Limits.getHeapSize() - heapSize;
        System.assert(usedCpuTime < 10000, 'CPU Time used should be less than 10000');
        System.assert(usedHeapSize < 6000000, 'Heap Size used should be less than 6000000');
    }

    private static String generateCSV(Integer numRows, Integer numFields, Integer fieldSize) {
        List<String> rows = new List<String>();
        // Generate header row
        List<String> headerFields = new List<String>();
        for (Integer i = 0; i < numFields; i++) {
            headerFields.add('Header' + i);
        }
        rows.add(String.join(headerFields, ','));
        
        // Generate data rows
        for (Integer i = 0; i < numRows; i++) {
            List<String> rowFields = new List<String>();
            for (Integer j = 0; j < numFields; j++) {
                rowFields.add('abcdefghijklmnopqrstuvwxyz');
            }
            rows.add(String.join(rowFields, ','));
        }
        return String.join(rows, '\n');
    }
    
    private static SObject createTestEventLogFile(String eventType, String content) {
        // Create mock EventLogFile data
        Map<String, Object> testData = EventMonitoringUtil.createTestEventLogData(
            eventType,
            Date.today(),
            Blob.valueOf(content)
        );
        
        // Create Account with mock data stored in Description field
        Account mockAccount = new Account(Name = 'Mock EventLog: ' + eventType);
        mockAccount.Description = JSON.serialize(testData);
        return (SObject)mockAccount;
    }
}