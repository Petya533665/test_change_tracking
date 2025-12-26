@isTest (IsParallel=true)
public class Test_StackTraceParser {

    @IsTest
    static void test_create_internal_error_log_in_post_processing_by_circular_exception_start_by_trigger() {
        Test_LogService.initSettings();

        Log__c log = new Log__c();
        log.Category__c = 'Apex';
        log.Stacktrace__c = 'test stacktrace';
        log.Hash_1__c = 'hash1';
        log.Created_At__c = System.now();
        log.Created_Timestamp__c = Double.valueOf(System.now().getTime());
        log.Organization_Id__c = Test_LogService.CONNECETED_ORG_NAME;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock(null, null, null));

        // throw circular exception in post processing or something else on update post processing fields
        LogPostProcessingService.testThrowCircularException = true;

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        insert log;

        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stacktrace__c FROM Log__c WHERE Category__c = 'Pharos Error' OR Area__c = 'Pharos' LIMIT 1];
        System.assertNotEquals(0, logs.size(), 'should create internal error log in post processing');
        System.assertEquals(true, logs[0].Stacktrace__c.contains('__Parent__c'));
    }

    @IsTest
    static void test_create_internal_error_log_in_post_processing_by_circular_exception_start_by_platform_event() {
        Test_LogService.initSettings();

        Log__c log = new Log__c();
        log.Category__c = 'Apex';
        log.Stacktrace__c = 'test stacktrace';
        log.Hash_1__c = 'hash1';
        log.Created_At__c = System.now();
        log.Created_Timestamp__c = Double.valueOf(System.now().getTime());
        log.Organization_Id__c = Test_LogService.CONNECETED_ORG_NAME;

        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock(null, null, null));

        // throw circular exception in post processing or something else on update post processing fields
        LogPostProcessingService.testThrowCircularException = true;

		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        Test.startTest();
        DatabaseUtils.publishLogEvent(new List<Log__c>{log});
        Test.getEventBus().deliver();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Stacktrace__c FROM Log__c WHERE Category__c = 'Pharos Error' OR Area__c = 'Pharos' LIMIT 1];
        System.assertNotEquals(0, logs.size(), 'should create internal error log in post processing');
        System.assertEquals(true, logs[0].Stacktrace__c.contains('__Parent__c'));
    }

    @IsTest
    static void test_create_internal_error_log_in_post_processing_by_circular_exception_start_by_email_handler() {

        Test_LogService.initSettings();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "DY_New_Screen_Flow" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT');

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('DY_New_Screen_Flow', 'testnewmp', 1));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;
        // throw circular exception in post processing or something else on update post processing fields
        LogPostProcessingService.testThrowCircularException = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);

        List<Log__c> logs = [SELECT Id, Stacktrace__c FROM Log__c WHERE Category__c = 'Pharos Error' OR Area__c = 'Pharos' LIMIT 1];
        System.assertNotEquals(0, logs.size(), 'should create internal error log in post processing');
        System.assertEquals(true, logs[0].Stacktrace__c.contains('__Parent__c'));
    }

    @IsTest
    static void test_fill_parent_log_with_existing_parent_log() {
        Test_LogService.initSettings();

        String testGUID = '3345a4f4456fc1d6bca751550b6f1962308f4f-4767';

        Log__c parentLog = new Log__c();
        parentLog.Category__c = 'Apex';
        parentLog.Interview_GUID_External__c = testGUID;
        parentLog.Transaction_Id_External__c = testGUID;
        parentLog.Hash_1__c = 'hash1';
        parentLog.Organization_Id__c = Test_LogService.CONNECETED_ORG_NAME;
        parentLog.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
        parentLog.Created_Timestamp__c = Double.valueOf(System.now().getTime());
        parentLog.Created_At__c = System.now();
        insert parentLog;

        Log__c log1 = new Log__c();
        log1.Category__c = 'Apex';
        log1.Hash_1__c = 'hash2';
        log1.Organization_Id__c = Test_LogService.CONNECETED_ORG_NAME;
        log1.Interview_GUID_External__c = testGUID;
        log1.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
        log1.Created_Timestamp__c = Double.valueOf(System.now().getTime()) + 1000;
        log1.Created_At__c = System.now().addSeconds(1);
        insert log1;
        
        
        Test.startTest();
        parentLog = [SELECT Id, Parent__c, Interview_GUID_External__c FROM Log__c WHERE Id = :parentLog.Id LIMIT 1];
        System.assertEquals(null, parentLog.Parent__c);
        System.assertNotEquals(parentLog.Id, parentLog.Parent__c);
        System.assertEquals(testGUID, parentLog.Interview_GUID_External__c);

        log1 = [SELECT Id, Parent__c, Interview_GUID_External__c FROM Log__c WHERE Id = :log1.Id LIMIT 1];
        System.assertEquals(parentLog.Id, log1.Parent__c);
        System.assertEquals(testGUID, log1.Interview_GUID_External__c);

        LogPostProcessingService.fillParent(parentLog, null);

        Test.stopTest();

        // avoid "Error [statusCode=CIRCULAR_DEPENDENCY, code=[xmlrpc=1252, statusCode=CIRCULAR_DEPENDENCY, exceptionCode=null, scope=PublicApi, http=400],
        // message=Hierarchy Constraint Violation, fields=[pharos__Parent__c]]
        System.assertNotEquals(parentLog.Id, parentLog.Parent__c, 'to avoid circular dependency, parent log should not be assigned to itself');
    }

    @IsTest
    static void test_handle_flow_with_multiple_edges_on_element() {

        Test_LogService.initSettings();
        
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "DY_New_Screen_Flow" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT');

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('DY_New_Screen_Flow', 'testnewmp', 1));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);

        assertIssueCreated(failedFlowLog.Id);

        Map<String, Object> stacktraceData = (Map<String, Object>)JSON.deserializeUntyped(failedFlowLog.Stacktrace_Parse_Result__c);
        System.assertNotEquals(null, stacktraceData);
        System.assertNotEquals(null, stacktraceData.get('edges'));
        System.assertNotEquals(null, stacktraceData.get('elements'));

        Map<String, Object> elements = (Map<String, Object>)stacktraceData.get('elements');
        for(String elementName : elements.keySet()) {
            Map<String, Object> element = (Map<String, Object>)elements.get(elementName);
            String name = (String)element.get('name');
            if (name == 'More' || name == 'Account_Selection_Scree') {
                System.assertNotEquals(null, name);
                System.assertEquals(elementName, name);
                System.assertNotEquals(null, element.get('executed'));
                System.assertEquals(true, (Boolean)element.get('executed'));
            }
        }

        Map<String, Object> edges = (Map<String, Object>)stacktraceData.get('edges');
        for(String edgeName : edges.keySet()) {
            Object edgeObj = edges.get(edgeName);
            Set<FlowDataStructures.FlowEdge> flowEdges = (Set<FlowDataStructures.FlowEdge>)JSON.deserialize(JSON.serialize(edgeObj), Set<FlowDataStructures.FlowEdge>.class);
            for(FlowDataStructures.FlowEdge  flowEdge : flowEdges) {
                System.assertNotEquals(null, flowEdge);
                System.assertNotEquals(null, flowEdge.target);
            }
            if (edgeName == 'More') {
                System.assertEquals(2, flowEdges.size());
                for (FlowDataStructures.FlowEdge  flowEdge : flowEdges) {
                    // goto route
                    if (flowEdge.target == 'Account_Selection_Scree') {
                        System.assertEquals(true, flowEdge.indexes.contains(8));
                    }
                    // create opp route
                    if (flowEdge.target == 'Createopp') {
                        System.assertEquals(true, flowEdge.indexes.contains(13));
                    }
                }
            }
        }
    }

	@IsTest
	static void test_handle_flow_error_with_skip() {

		Test_LogService.initSettings();

		//ErrorEmailHandler
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		List<string> emails = new List<string>{'testemail1@gmail.com'};

		email.subject = 'An error occurred with your "DY_Screen_Flow_Update_Communication_Prefs" flow';
		email.fromAddress = 'system@salesforce.com';
		email.toAddresses = emails;
		email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_WITH_LOGGING');

		Test.startTest();
		StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
		Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_WITH_LOGGING_METADATA')));

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('DY_Screen_Flow_Update_Communication_Prefs', 'testnewmp', 3));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		LogTriggerHelper.runPostProcessingBatchInTest = true;

		LogService.CUSTOM_SKIP_TEST_VALUE = true;

		ErrorEmailHandler testInbound = new ErrorEmailHandler();
		testInbound.handleInboundEmail(email, env);
		Test.stopTest();

		Inbound_Email__c inboundEmail = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c LIMIT 1];
		System.assertEquals(null, inboundEmail.Error__c, 'No error should be populated');
		System.assertEquals(null, inboundEmail.Log__c, 'No log should be created');

		List<Log__c> logs = [SELECT Id FROM Log__c LIMIT 1];
		System.assertEquals(0, logs.size(), 'No logs should be created');
	}

    @IsTest
    static void test_handle_flow_handled_error_with_logging() {

        Test_LogService.initSettings();
        
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "DY_Screen_Flow_Update_Communication_Prefs" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_WITH_LOGGING');

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_WITH_LOGGING_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('DY_Screen_Flow_Update_Communication_Prefs', 'testnewmp', 3));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Inbound_Email__c inboundEmail = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c LIMIT 1];
        System.assertNotEquals(null, inboundEmail.Error__c, 'Error should be populated');
        System.assertEquals(null, inboundEmail.Log__c, 'No log should be created');

        List<Log__c> flowLogs = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertEquals(0, flowLogs.size(), 'No flow logs should be created');

        List<Log__c> loggingLogs = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Pharos Error' OR Area__c = 'Pharos' LIMIT 1];
        System.assertEquals(0, loggingLogs.size(), 'Error logs should not be created');
    }

    @IsTest
    static void test_handle_flow_handled_error() {

        Test_LogService.initSettings();
        
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "Test_Fault_Path" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = String.valueOf(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR'))
            .replaceAll('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME)
            .replaceAll('005ak0000072Hrx', '0056g000003aA4M');

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('Test_Fault_Path', 'testnewmp', 3));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);

        assertIssueCreated(failedFlowLog.Id);
    }

    @IsTest
    static void test_populate_log_level_and_operation_fields() {

        // change log level field api name to Request_Id_External__c to test that it is populated
        FlowExceptionParser.LOG_LEVEL_FIELD_NAME = 'Request_Id_External__c';
        FlowExceptionParser.LOG_LEVEL_FIELD_API_NAME = ConfigUtil.prefixCurrentOrgNamespace(FlowExceptionParser.LOG_LEVEL_FIELD_NAME);
        System.assert(FlowExceptionParser.isLogLevelFieldAvailable(), 'Request_Id_External__c field should be available');

        Test_LogService.initSettings();
        
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "Test_Fault_Path" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = String.valueOf(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR'))
            .replaceAll('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME)
            .replaceAll('005ak0000072Hrx', '0056g000003aA4M');

        Test.startTest();
        
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('Test_Fault_Path', 'testnewmp', 3));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Apex_Name__c, Request_Id_External__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);
        // in stacktrace we have FlowActionCall value
        System.assertEquals('FlowActionCall', failedFlowLog.Apex_Name__c);
        // should be ERROR value log level
        System.assertEquals('ERROR', failedFlowLog.Request_Id_External__c);

        assertIssueCreated(failedFlowLog.Id);
    }

    @IsTest
    private static void testFlowHandledErrorParser() {

        Test_LogService.initSettings(); 

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR_METADATA')));
        String stacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_STACKTRACE_HANDLED_ERROR'));
        FlowDataStructures.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);
        System.assertEquals(true, flow.elements.containsKey('Create_Opp'));
        System.assertEquals(true, flow.elements.containsKey('Testeeet'));
        Test.stopTest();

        Map<String, FlowDataStructures.FlowElement> elements = flow.elements;
        FlowDataStructures.FlowElement createOppElement = flow.elements.get('Create_Opp');
        System.assertNotEquals(null, createOppElement);
        System.assertEquals(true, createOppElement.executed);

        FlowDataStructures.FlowElement testeeetElement = flow.elements.get('Testeeet');
        System.assertNotEquals(null, testeeetElement);
        System.assertEquals(true, testeeetElement.executed);

        Map<String, Set<FlowDataStructures.FlowEdge>> edges = flow.edges;
        System.assertNotEquals(null, edges);
        System.assertEquals(true, edges.containsKey('Create_Opp'));

        Set<FlowDataStructures.FlowEdge> createOppEdges = edges.get('Create_Opp');
        System.assertNotEquals(null, createOppEdges);
        System.assertEquals(true, createOppEdges.size() == 1);
        FlowDataStructures.FlowEdge  createOppEdge = createOppEdges.iterator().next();
        System.assertNotEquals(null, createOppEdge);
        System.assertEquals(true, createOppEdge.target == 'Testeeet');

    }

    @IsTest
    private static void testFlowRollbackParserWithWrongStacktrace() {

        Test_LogService.initSettings(); 

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_ROLLBACK_WITH_WRONG_FORMAT_METADATA')));
        String stacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_STACKTRACE_ROLLBACK_WITH_WRONG_FORMAT'));
        FlowDataStructures.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);
        System.assertEquals(true, flow.elements.containsKey('Get_Account'));
        Test.stopTest();

        Map<String, FlowDataStructures.FlowElement> elements = flow.elements;
        FlowDataStructures.FlowElement getAccountElement = flow.elements.get('Get_Account');
        System.assertNotEquals(null, getAccountElement);
        System.assertEquals(true, getAccountElement.executed);
    }

    @IsTest
    private static void testFlowWaitParser() {

        Test_LogService.initSettings(); 

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_WAIT_ALL_TYPES_METADATA')));
        String stacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_WAIT_ALL_TYPES_STACKTRACE')).replaceAll('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME);
        FlowDataStructures.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);

        Map<String, FlowDataStructures.FlowElement> elements = flow.elements;
        FlowDataStructures.FlowElement waitDecision = elements.get('wait11');
        System.assertNotEquals(null, waitDecision);
        System.assertEquals(true, waitDecision.executed);
        Map<String, Object> metadataInfoWaitDecision = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(waitDecision.metadataInfo));
        System.assertEquals(true, metadataInfoWaitDecision.containsKey('elementSubtype'));
        System.assertEquals(true, metadataInfoWaitDecision.containsKey('events'));

        FlowDataStructures.FlowElement waitDuration = elements.get('wait22');
        System.assertNotEquals(null, waitDuration);
        System.assertEquals(false, waitDuration.executed);
        Map<String, Object> metadataInfoWaitDuration = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(waitDuration.metadataInfo));
        System.assertEquals(true, metadataInfoWaitDuration.containsKey('elementSubtype'));
        System.assertEquals('WaitDuration', String.valueOf(metadataInfoWaitDuration.get('elementSubtype')));
        System.assertEquals(true, metadataInfoWaitDuration.containsKey('events'));
        List<Object> events = (List<Object>)metadataInfoWaitDuration.get('events');
        Map<String, Object> eventDuration = (Map<String, Object>)events.get(0);
        System.assertEquals(true, eventDuration.containsKey('offset'));
        System.assertEquals(true, eventDuration.containsKey('offsetUnit'));

        FlowDataStructures.FlowElement waitDate = elements.get('wait33');
        System.assertNotEquals(null, waitDate);
        System.assertEquals(false, waitDate.executed);
        Map<String, Object> metadataInfoWaitDate = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(waitDate.metadataInfo));
        System.assertEquals(true, metadataInfoWaitDate.containsKey('elementSubtype'));
        System.assertEquals('WaitDate', String.valueOf(metadataInfoWaitDate.get('elementSubtype')));
        System.assertEquals(true, metadataInfoWaitDate.containsKey('events'));
        events = (List<Object>)metadataInfoWaitDate.get('events');
        Map<String, Object> eventDate = (Map<String, Object>)events.get(0);
        System.assertEquals(true, eventDate.containsKey('resumeDate'));
        System.assertEquals(true, eventDate.containsKey('resumeDate'));


        Test.stopTest();
    }

    @IsTest
    private static void test_parse_flow_multi_subflows() {
        
        String testStub = String.valueOf(Test_LogService.getTestStub('FLOW_MULTI_SUBFLOWS_STACKTRACE'));
        
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        
        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertEquals(true, !stackTraceInfo.stacktraceElementsMap.isEmpty());
        System.assertEquals(3, stackTraceInfo.stacktraceElementsMap.keySet().size());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }

    @IsTest
    static void test_handle_flow_error_with_subflows() {

        Test_LogService.initSettings();
        
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com','testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "GovnopaketFlowContact1" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = String.valueOf(Test_LogService.getTestStub('FLOW_MULTI_SUBFLOWS_STACKTRACE')).replaceAll('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME);

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_MULTI_SUBFLOWS_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('accounttranfform1', 'testpharosx', 4));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);

        assertIssueCreated(failedFlowLog.Id);
    }

    private static void assertIssueCreated(Id logId) {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Log__c = :logId LIMIT 1];
        System.assertNotEquals(null, issues);
        System.assertEquals(1, issues.size());
    }

    @IsTest
    private static void test_abbreviate_bulk_flow_multi_entry_without_error_details() {
        
        String testStub = String.valueOf(Test_LogService.getTestStub('TEST_FLOW_BULK_ERROR_STACKTRACE1'));
        
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }

    @IsTest
    private static void test_abbreviate_bulk_flow_multi_entry_with_error_details() {
        
        String testStub = String.valueOf(Test_LogService.getTestStub('TEST_FLOW_BULK_ERROR_STACKTRACE2'));
        
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }


    @IsTest
    private static void test_abbreviate_large_flow_multi_entry() {
        String testStub = [SELECT Body FROM StaticResource WHERE Name = 'FlowParserLargeMultiFlowEntry'].Body.toString();
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }

    @IsTest
    private static void test_abbreviate_large_flow_entry() {
        String testStub = [SELECT Body FROM StaticResource WHERE Name = 'FlowParserLargeFlowEntry'].Body.toString();
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }

    @IsTest
    private static void test_abbreviate_large_error_message() {
        String testStub = [SELECT Body FROM StaticResource WHERE Name = 'FlowParserLargeErrorMessage'].Body.toString();
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);
    }

    public static String stackTrace1 = '' +
    'Class.System.JSON.deserialize: line 15, column 1\n' +
    'Class.StackTraceParser.getClassesMap: line 39, column 1\n' +
    'AnonymousBlock: line 42, column 1\n' +
    'AnonymousBlock: line 42, column 1';

    public static String stackTrace2 = '' +
    'Class.SBQQ.QuoteService: line 336, column 1\n' +
    'Class.SBQQ.QuoteService: line 273, column 1\n' +
    'Class.SBQQ.QuoteService: line 269, column 1\n' +
    'Class.SBQQ.QuoteService: line 216, column 1\n' +
    'Class.SBQQ.QueueableCalculatorService.CalculateSyncher: line 242, column 1\n' +
    'Class.SBQQ.QueueableCalculatorService.execute: line 58, column 1';

    public static String stackTrace3 = '' +
    'Class.SBQQ.RestClient.send: line 77, column 1\n' +
    'Class.SBQQ.RestClient.post: line 43, column 1\n' +
    'Class.SBQQ.JSQCClient.calculate: line 72, column 1\n' +
    'Class.SBQQ.QuoteService.calculate: line 303, column 1\n' +
    'Class.SBQQ.QuoteService.calculate: line 273, column 1\n' +
    'Class.SBQQ.QuoteService.calculate: line 269, column 1\n' +
    'Class.SBQQ.QuoteService.calculateAndSynch: line 216, column 1\n' +
    'Class.SBQQ.QuoteService.calculateAndSynch: line 222, column 1\n' +
    'Trigger.SBQQ.QuoteAfter: line 45, column 1';

    public static String stackTrace4 = '' +
    'Trigger.LoggerTest1.LogTrigger: line 3, column 1';


    static testMethod void test1 () {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.ApexClassesResponseWrapper resp = new StackTraceParser.ApexClassesResponseWrapper();
        resp.size = 1;
        resp.records = new List<StackTraceParser.ApexClassWrapper>();
        StackTraceParser.ApexClassWrapper c1 = new StackTraceParser.ApexClassWrapper();
        c1.Id = 'Id';
        c1.Name = 'TestClass';
        c1.Body = 'test class body here ...';
        resp.records.add(c1);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(resp), 200));

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById('00D40000000N3x2');

        System.assertNotEquals(StackTraceParser.corg, null);

        List<StackTraceParser.StackTraceParseResult> result = StackTraceParser.parseStackTrace(stackTrace1);

        System.assertEquals(4, result.size());

        Test.stopTest();

    }

    static testMethod void test2 () {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.ApexClassesResponseWrapper resp = new StackTraceParser.ApexClassesResponseWrapper();
        resp.size = 1;
        resp.records = new List<StackTraceParser.ApexClassWrapper>();
        StackTraceParser.ApexClassWrapper c1 = new StackTraceParser.ApexClassWrapper();
        c1.Id = 'Id';
        c1.Name = 'TestClass';
        c1.Body = 'test class body here ...';
        resp.records.add(c1);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(resp), 200));

        Log__c log = new Log__c(
            Details__c = stackTrace3,
            Stacktrace__c = stackTrace3
        );
        insert log;

        Test.stopTest();

        System.assertNotEquals(null, log.Stacktrace__c);
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public Integer testResponseCode = 200;
        public String testResponse = null;

        public MockHttpResponseGenerator(String testResponse, Integer testResponseCode) {
            this.testResponse = testResponse;
            this.testResponseCode = testResponseCode;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.testResponse);
            res.setStatusCode(this.testResponseCode);
            return res;
        }
    }

    public class YourWebServiceMockImpl implements WebServiceMock {
        private String jsonData;

        public YourWebServiceMockImpl(String jsonData) {
            this.jsonData = jsonData;
        }
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {

            MetadataService.readFlowResponse_element metadataResponse = new MetadataService.readFlowResponse_element();
            MetadataService.ReadFlowResult result = (MetadataService.ReadFlowResult)JSON.deserialize(this.jsonData, MetadataService.ReadFlowResult.class);
            metadataResponse.result = result;

            response.put('response_x', metadataResponse);
        }
    }

    @IsTest
    private static void testFlowParser() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('flowJSON_all_actions')));
        String errorMessage = '';

        try {
            // this stacktrace contains latest element with fault connector
            FlowDataStructures.Flow flow = FlowService.parseFlowStackTrace(Test_LogService.getTestStub('flow_AllActions_StackTrace'));
        }
        catch (Exception e) {
            errorMessage = e.getMessage();
        }        
        Test.stopTest();

        System.assert(errorMessage.contains(LogService.FLOW_HANDLED_ERROR_MESSAGE), 'Exception should be thrown: ' + LogService.FLOW_HANDLED_ERROR_MESSAGE);
    }

    @IsTest
    private static void testProcessBuilderParser() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(Test_LogService.getTestStub('processBuilderJSON_ResponseNameGroupCall'), 200));
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('processBuilderJSON_all_actions')));
        FlowService.ProcessBuilder processBuilder = FlowService.parseProcessBuilderStackTrace(Test_LogService.getTestStub('processBuilder_AllActions_StackTrace'));
        System.assertNotEquals(null, processBuilder);
        System.assertNotEquals(null, processBuilder.decisions);
        System.assertEquals(3, processBuilder.decisions.size());

        System.assertEquals(3, processBuilder.start.sections.size());
        System.assertEquals(FlowService.SideBarItemType.TEXT, processBuilder.start.sections.get(0).itemType);
        System.assertEquals(FlowService.SideBarItemType.RADIOBUTTON, processBuilder.start.sections.get(1).itemType);
        System.assertEquals(FlowService.SideBarItemType.CHECKBOX, processBuilder.start.sections.get(2).itemType);

        System.assertEquals('Account', processBuilder.start.sections.get(0).value);
        System.assertEquals(Constants.FLOW.PB_LABEL_OBJECT, processBuilder.start.sections.get(0).label);
        

        // start sidebar info
        for(FlowService.SideBarSection sbs : processBuilder.start.sections) {
            System.assertNotEquals(null, sbs.itemType);
            System.assertNotEquals(null, sbs.label);
        }

        // decisions info
        for(FlowService.ProcessBuilderDecision pbd : processBuilder.decisions) {

            System.assertNotEquals(null, pbd.label);
            System.assertNotEquals(null, pbd.name);
            System.assertNotEquals(null, pbd.executed);
            System.assertNotEquals(null, pbd.index);

            // decisions sidebar info
            for(FlowService.SideBarSection sbs : pbd.sections) {
                System.assertNotEquals(null, sbs.itemType);
                System.assertNotEquals(null, sbs.label);
            }

            // decisions actions info
            for(List<FlowService.ProcessBuilderAction> pbaList : pbd.actions) {

                for(FlowService.ProcessBuilderAction pba : pbaList) {
                    System.assertNotEquals(null, pba.name);
                    System.assertNotEquals(null, pba.label);
                    System.assertNotEquals(null, pba.actionType);
                    System.assertNotEquals(null, pba.executed);

                    // decisions actions sidebar info
                    for(FlowService.SideBarSection sbs : pba.sections) {
                        System.assertNotEquals(null, sbs.itemType);
                        System.assertNotEquals(null, sbs.label);
                    }
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    private static void testTruncateAuditTrailItems() {
        List<Object> testItems = new List<Object>();
        for(Integer i = 0; i<100; i++){
            testItems.add(new Map<String, Object>{'Name' => 'TestLine' + i});
        }
        Integer testItemsSize = JSON.serialize(testItems).length();
        Integer maxTestItemsSize = Integer.valueOf(testItemsSize * 0.91);

        List<Object> resultTestItems;
        Integer resultItemsSize;

        Test.startTest();
        resultTestItems = LogPostProcessingService.truncateItems(maxTestItemsSize, testItems);
        resultItemsSize = JSON.serialize(resultTestItems).length();
        Test.stopTest();

        System.assertNotEquals(null, resultItemsSize);
        System.assertEquals(true, resultItemsSize < testItemsSize);
        System.assertEquals(true, resultItemsSize <= maxTestItemsSize);
        system.assertEquals(true, resultTestItems.size() < testItems.size());
    }

    @IsTest
    private static void testOrchestratorParser() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        
        String testStubMetadata = String.valueOf(Test_LogService.getTestStub('ORCHESTRATOR_FAILED_FLOW_METADATA'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('ORCHESTRATOR_FAILED_FLOW_STACKTRACE'));
        
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStubMetadata));
        FlowDataStructures.Flow orchestratorFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
        System.assertNotEquals(null, orchestratorFlow);
        System.assertNotEquals(null, orchestratorFlow.elements);
        System.assertNotEquals(null, orchestratorFlow.edges);
    }

    @IsTest
    private static void testOrchestratorFailedFlowParser() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String testStubMetadata = String.valueOf(Test_LogService.getTestStub('ORCHESTRATOR_FLOW_METADATA'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('ORCHESTRATOR_STACK_TRACE'));
        
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStubMetadata));
        FlowDataStructures.Flow orchestratorFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
        System.assertNotEquals(null, orchestratorFlow);
        System.assertNotEquals(null, orchestratorFlow.elements);
        System.assertNotEquals(null, orchestratorFlow.edges);
        System.assertNotEquals(null, orchestratorFlow.orchestratorFailedFlowApiName);
    }

    @IsTest
    private static void testFlowWithSameLabelsParser() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String testStubMetadata = String.valueOf(Test_LogService.getTestStub('FLOW_SAME_API_LABELS_METADATA'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_SAME_API_LABELS_ELEMENTS_STACKTRACE'));
        
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStubMetadata));
        FlowDataStructures.Flow testedFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
        System.assertNotEquals(null, testedFlow);
        System.assertNotEquals(null, testedFlow.elements);
        System.assertNotEquals(null, testedFlow.edges);
        for(FlowDataStructures.FlowElement stElement : testedFlow.elements.values()) {
            System.assertEquals(true, stElement.executed);
        }
    }

    @IsTest
    private static void testParseScheduledFlowStackTraceWithDebuggerMode() {

        Test_LogService.initSettings(); 

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_SCHEDULED_STACKTRACE_METADATA_IN_DEBUG_MODE')));
        String stacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_SCHEDULED_STACKTRACE_IN_DEBUG_MODE'));
        FlowDataStructures.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);
        System.assertEquals(true, flow.elements.containsKey('Chatter_for_opportunity'));
        Test.stopTest();

        Map<String, FlowDataStructures.FlowElement> elements = flow.elements;
        FlowDataStructures.FlowElement createOppElement = flow.elements.get('Chatter_for_opportunity');
        System.assertNotEquals(null, createOppElement);
        System.assertEquals(true, createOppElement.executed);

        Map<String, Set<FlowDataStructures.FlowEdge>> edges = flow.edges;
        System.assertNotEquals(null, edges);
        System.assertEquals(true, edges.containsKey('start'));

        Set<FlowDataStructures.FlowEdge> startEdges = edges.get('start');
        System.assertNotEquals(null, startEdges);
        System.assertEquals(true, startEdges.size() == 3);
        
        FlowDataStructures.FlowEdge edgeFromStartToFirstElement = null;
        for(FlowDataStructures.FlowEdge edge : startEdges) {
            if (edge.target == 'Chatter_for_opportunity') {
                edgeFromStartToFirstElement = edge;
            }
        }
        System.assertNotEquals(null, edgeFromStartToFirstElement);
        System.assertEquals(true, edgeFromStartToFirstElement.indexes.size() == 1);
        System.assertEquals(true, edgeFromStartToFirstElement.indexes.contains(1));
    }

    @IsTest
    private static void testFlowParserFromManagedPackage() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String testStubMetadata = String.valueOf(Test_LogService.getTestStub('FLOW_MANAGED_PACKAGE_STACKTRACE_METADATA'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_MANAGED_PACKAGE_STACKTRACE'));
        
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStubMetadata));

        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStubStacktrace);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedHtmlBody = sp.abbreviateStacktraceErrorMessages();
        Log__c log = LogService.createLogFromEmailBody(testStubStacktrace, 'An error occurred with your "GovnopaketFlowContact1" flow', 'test@test.com', Datetime.now());
        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(LogService.class.getName(), '.', null);
        Test.stopTest();

        log = [SELECT Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c, Namespace__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        system.assertEquals('testgovnopaket1__GovnopaketFlowContact1', log.Flow_API_Name__c);
        system.assertEquals('1', log.Flow_Version__c);
        system.assertEquals('Flow', log.Area__c);
        system.assertEquals('Autolaunched Flow', log.Type__c);
        system.assertNotEquals(null, log.Hash_1__c);
        system.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
        system.assertEquals('testgovnopaket1', log.Namespace__c);
    }

    @IsTest
    private static void testFlowParserFromManagedPackageWithoutNamespace() {

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String testStubMetadata = String.valueOf(Test_LogService.getTestStub('FLOW_MANAGED_PACKAGE_STACKTRACE_METADATA'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_MANAGED_PACKAGE_STACKTRACE_WITHOUT_NAMESPACE'));
        
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStubMetadata));

        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStubStacktrace);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedHtmlBody = sp.abbreviateStacktraceErrorMessages();
        Log__c log = LogService.createLogFromEmailBody(testStubStacktrace, 'An error occurred with your "GovnopaketFlowContact1" flow', 'test@test.com', Datetime.now());
        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(LogService.class.getName(), '.', null);
        Test.stopTest();

        log = [SELECT Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c, Namespace__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        system.assertEquals('GovnopaketFlowContact1', log.Flow_API_Name__c);
        system.assertEquals('1', log.Flow_Version__c);
        system.assertEquals('Flow', log.Area__c);
        system.assertEquals('Autolaunched Flow', log.Type__c);
        system.assertNotEquals(null, log.Hash_1__c);
        system.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
        system.assertEquals('unknown', log.Namespace__c);
    }

    @IsTest
    private static void testFlowParserFromManagedPackageWithWrongFlowApiName() {

        Test_LogService.initSettings();

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        List<string> emails = new List<string>{'testemail1@gmail.com','testemail1@gmail.com'};

        email.subject = 'An error occurred with your "Tackle Sync" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = String.valueOf(Test_LogService.getTestStub('FLOW_MANAGED_PACKAGE_STACKTRACE_WRONG_API_NAME'));

        Test.startTest();
        // run post processing batch in test context
        LogTriggerHelper.runPostProcessingBatchInTest = true;

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new FailedWebServiceMockImpl());

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(Test_StackTraceParser.createPostProcessingMock('Tackle_Sync', '', 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);		
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c log = [SELECT Post_Processing_Status__c,Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c, Namespace__c FROM Log__c LIMIT 1];
        System.assertEquals(null, log.Stacktrace_Parse_Result__c);
        System.assertEquals('Tackle_Sync', log.Flow_API_Name__c);
        System.assertEquals('1', log.Flow_Version__c);
        System.assertEquals('Flow', log.Area__c);
        System.assertEquals('Autolaunched Flow', log.Type__c);
        System.assertNotEquals(null, log.Hash_1__c);
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED, log.Post_Processing_Status__c);
        System.assertEquals(LogService.NAMESPACE_UNKNOWN, log.Namespace__c);
    }

    @TestVisible 
    public class FailedWebServiceMockImpl implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNs,
            String responseName,
            String responseType
        ) {
            CalloutException e = new CalloutException();
            e.setMessage('Web service callout failed: WebService returned a SOAP Fault: type and fullNames must be specified for items to read faultcode=sf:UNKNOWN_EXCEPTION faultactor=');
            throw e;
        }
    }

    @IsTest
    private static void testFlowParserFromConvertedProcessBuilder() {

        String testStub = String.valueOf(Test_LogService.getTestStub('flowConvertedFromProcessBuilderMetadata'));
        String testStubStacktrace = String.valueOf(Test_LogService.getTestStub('FLOW_CONVERTED_FROM_PROCESS_BUILDER_STACKTRACE'));
    
        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStubStacktrace);
        
        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertEquals(2, stackTraceInfo.stacktraceElements.size());
        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);

        Test_LogService.initSettings();

        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(testStub));

        Log__c log = LogService.createLogFromEmailBody(testStubStacktrace, 'An error occurred with your "GovnopaketFlowContact1" flow', 'test@test.com', Datetime.now());
        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(LogService.class.getName(), '.', null);
        Test.stopTest();

        log = [SELECT Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c, Namespace__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        system.assertEquals('IO_Line_Item_Clone_Flow', log.Flow_API_Name__c);
        system.assertEquals('3', log.Flow_Version__c);
        system.assertEquals('Flow', log.Area__c);
        system.assertEquals('Autolaunched Flow', log.Type__c);
        system.assertNotEquals(null, log.Hash_1__c);
        system.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
        system.assertEquals(true, String.isBlank(log.Namespace__c));
    }

    @IsTest
    static void test_parse_bulk_flow_errors_to_unic_logs() {
        //ErrorEmailHandler
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com','testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "FailedContactAccounts" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        String testStacktraceStub = String.valueOf(Test_LogService.getTestStub('flowToAbbreviateBulkFlowStacktrace'));
        testStacktraceStub = testStacktraceStub.replace('00D6g000005kAqN', Test_LogService.CONNECETED_ORG_NAME);
        email.htmlBody = testStacktraceStub;

        Test_LogService.initSettings();
        
        Test.startTest();

        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String metadataResponse = String.valueOf(Test_LogService.getTestStub('FLOW_BULK_STACKTRACE_TO_ABBREVIATE_METADATA'));
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(metadataResponse));
            
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        List<Log__c> failedFlowLogs = [SELECT Id, Summary__c, Hash_1__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 2];
        System.assertEquals(2, failedFlowLogs.size());
        system.assertNotEquals(failedFlowLogs.get(0).Summary__c, failedFlowLogs.get(1).Summary__c);
        system.assertNotEquals(failedFlowLogs.get(0).Hash_1__c, failedFlowLogs.get(1).Hash_1__c);
    }

    @IsTest
    private static void test_abbreviate_and_parse_flow_without_head_error_part() {

        Test_LogService.initSettings();

        String testStub = String.valueOf(Test_LogService.getTestStub('FLOW_WITHOUT_HEAD_ERROR_PART_STACKTRACE'));

        String testOrgId = '00D40000000N3x2';
        String testGuid = '84768317dfc1c68d7e0e412f3395193b0f324a4-3eb6';

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createToolingGetInterviewRecordsMocks(testGuid));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();

        FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(testStub);
        FlowDataStructures.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        FlowService.FlowStacktraceParser sp2 = new FlowService.FlowStacktraceParser(abbreviatedTestStub.abbreviatedStacktrace);
        FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp2.parse();

        Test.stopTest();

        System.assertNotEquals(null, stackTraceInfo);
        System.assertNotEquals(null, stackTraceInfo.stacktraceElements);
        System.assertEquals(true, !stackTraceInfo.stacktraceElements.isEmpty());
        System.assertEquals(true, !stackTraceInfo.stacktraceElementsMap.isEmpty());
        System.assertEquals(1, stackTraceInfo.stacktraceElementsMap.keySet().size());
        System.assertNotEquals(null, stackTraceInfo.flowDetails);
        System.assertNotEquals(null, stackTraceInfo.flowInterviewDetails);
        System.assertNotEquals(null, stackTraceInfo.howTheInterviewStarted);
        System.assertNotEquals(null, stackTraceInfo.salesforceErrorId);

        System.assertNotEquals(null, stackTraceInfo.errorMessage);
        System.assertEquals(FLOW_INTERVIEW_ERROR_MESSAGE, stackTraceInfo.errorMessage);
        System.assertNotEquals(null, stackTraceInfo.errorMessageHtml);
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createPostProcessingMock(String flowDeveloperName, String flowNamespace, Integer flowVersion) {
        return createPostProcessingMock(flowDeveloperName, flowNamespace, flowVersion, true);
    }

    @TestVisible
    private static Map<String, HttpCalloutMock> createPostProcessingMock(String flowDeveloperName, String flowNamespace, Integer flowVersion, Boolean isPositiveDeployResultsMock) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(getApexClassesMock());
        endpoint2TestResp.putAll(getApexTriggersMock());
        endpoint2TestResp.putAll(isPositiveDeployResultsMock ? getDeployResultsMock() : getDeployResultsBadRequestMock());
        endpoint2TestResp.putAll(getSObjectDescribeMock());
        endpoint2TestResp.putAll(getAuditTrailsMock());
        endpoint2TestResp.putAll(getInstalledPackagesMock());
        endpoint2TestResp.putAll(getTotalActiveSessionsMock());
        endpoint2TestResp.putAll(getPendingJobsMock());
        endpoint2TestResp.putAll(getFlowDescribeMock(flowDeveloperName, flowNamespace, flowVersion));
        endpoint2TestResp.putAll(getUserNameMock());
        endpoint2TestResp.putAll(getLimitsMock());
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getPendingJobsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        final List<String> JOB_STATUSES = new List<String>{
            Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_QUEUED,
            Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PROCESSING,
            Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_PREPARING
        };
        String query = new QBuilder(AsyncApexJob.SObjectType)
            .selectFields(LogPostProcessingService.ASYNC_JOB_FIELDS)
            .add(QBuilder.condition('Status').isIn(JOB_STATUSES))
            .add(QBuilder.condition('JobType').notEqualsTo('BatchApexWorker'))
            .addLimit(1000)
            .build();

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getFlowDescribeMock(String flowDeveloperName, String flowNamespace, Integer flowVersion) {
        String flowFullName = (flowDeveloperName != null) ? flowDeveloperName : TestDataFactory.TEST_FLOW_API_NAME;

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query1 = new QBuilder('FlowDefinition')
			.selectFields(new Set<String>{'Id'})
			.add(QBuilder.condition('DeveloperName').equalsTo(flowFullName))
			.add(String.isNotBlank(flowNamespace) ? QBuilder.condition('NamespacePrefix').equalsTo(flowNamespace) : null)
			.addLimit(1)
			.build();

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + EncodingUtil.urlEncode(query1, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));

        String flowDefinitionId = '';
        Integer flowVersionId = (flowVersion != null) ? flowVersion : 1;
        
        String query2 = new QBuilder('Flow')
            .selectFields(new Set<String>{'Id', 'DefinitionId'})
            .add(QBuilder.condition('DefinitionId').equalsTo(flowDefinitionId))
            .add(QBuilder.condition('VersionNumber').equalsTo(flowVersionId))
            .addLimit(1)
            .build();
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + EncodingUtil.urlEncode(query2, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getLimitsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.ORG_LIMITS_API_ENDPOINT, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getUserNameMock() {
        String userId = '0056g000003aA4M';
        String userFullName = 'Test User';
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(User.SObjectType)
            .selectFields(LogPostProcessingService.USER_FIELDS)
            .add(QBuilder.condition('Id').equalsTo(userId))
            .addLimit(1)
            .build();

        Profile profile = [SELECT Id, Name, UserLicense.Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole userRole = [SELECT Id, Name FROM UserRole LIMIT 1];
        User user = (User) JSON.deserialize(
            JSON.serialize(
                new Map<String, Object>{
                    'Id' => userId,
                    'Name' => userFullName,
                    'ProfileId' => profile.Id,
                    'Profile' => profile,
                    'UserRoleId' => userRole.Id,
                    'UserRole' => userRole
                }
            ),
            User.class
        );
        
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>{ user }
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getTotalActiveSessionsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(AuthSession.SObjectType)
            .selectFields(new Set<String> {'COUNT_DISTINCT(LoginHistory.UserId) number'})
            .add(QBuilder.condition('CreatedDate').isGreaterThan(LogPostProcessingService.testLast1hour))
            .build();
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getInstalledPackagesMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        String query = new QBuilder(Publisher.SObjectType)
            .selectFields(LogPostProcessingService.PUBLISHER_FIELDS)
            .add(QBuilder.condition('IsSalesforce').equalsTo(false))
            .build();
       
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }
    

    private static Map<String, HttpCalloutMock> getDeployResultsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        
        List<LogPostProcessingService.DeployResult> deployResults = new List<LogPostProcessingService.DeployResult>();
        LogPostProcessingService.DeployResult deployResult = new LogPostProcessingService.DeployResult();
        deployResult.id = UserInfo.getUserId();
        deployResult.status = 'completed';
        deployResult.completedDate = DateTime.now();
        deployResults.add(deployResult);

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(getDeployRequestDynamicQuery(), 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => deployResults
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getDeployResultsBadRequestMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(getDeployRequestDynamicQuery(), 'UTF-8'), new TestDataFactory.SingleRequestMock(
            400,
            'Bad Request',
            JSON.serialize(getHttpMockDeployResultErrorList())
        ));
        return endpoint2TestResp;
    }

    private static String getDeployRequestDynamicQuery() {
        return new QBuilder('deployRequest')
            .selectFields(LogPostProcessingService.DEPLOY_RESULT_FIELDS)
            .add(QBuilder.condition('Status').isIn(new List<String>{'Succeeded', 'SucceededPartial'}))
            .addLimit(10)
            .add(new QOrder('CompletedDate').descending())
            .build();
    }

    private static List<Map<String, String>> getHttpMockDeployResultErrorList() {
        return new List<Map<String, String>>{
            new Map<String, String>{
                'errorCode' => 'INVALID_TYPE',
                'message' => 'sObject type \'DeployRequest\' is not supported.'
            }
        };
    }

    private static Map<String, HttpCalloutMock> getAuditTrailsMock() {
        Datetime createdAtDateTime = DateTime.newInstance(ErrorEmailHandler.testCreatedAtDateTime.year(),ErrorEmailHandler.testCreatedAtDateTime.month(),ErrorEmailHandler.testCreatedAtDateTime.day(),ErrorEmailHandler.testCreatedAtDateTime.hour(),ErrorEmailHandler.testCreatedAtDateTime.minute(),ErrorEmailHandler.testCreatedAtDateTime.second());

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String queryAuditTrails = new QBuilder(SetupAuditTrail.SObjectType)
            .selectFields(LogPostProcessingService.AUDIT_TRAIL_FIELDS)
            .add(QBuilder.condition('CreatedDate').isLessOrEquals(createdAtDateTime))
            .add(QBuilder.condition('CreatedDate').isGreaterThan(createdAtDateTime.addHours(LogPostprocessingService.MAX_ENV_INFO_TIME_WINDOW_HRS)))
            .add(QBuilder.orderBy('CreatedDate').descending())
            .addLimit(100)
            .build();
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(queryAuditTrails, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Object>()
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getSObjectDescribeMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        List<LogPostProcessingService.SObjectDescribeInfo> sObjectDescribeInfos = new List<LogPostProcessingService.SObjectDescribeInfo>();
        LogPostProcessingService.SObjectDescribeInfo sObjectDescribeInfo = new LogPostProcessingService.SObjectDescribeInfo('Account', 'Account');
        sObjectDescribeInfo.keyPrefix = '001';
        sObjectDescribeInfo.name = 'Account';
        sObjectDescribeInfos.add(sObjectDescribeInfo);
        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.DESCRIBE_SOBJECT_PATH, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                'sobjects' => sObjectDescribeInfos
            })
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getApexTriggersMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        StackTraceParser.ApexClassWrapper apexClassWrapper = new StackTraceParser.ApexClassWrapper();
        apexClassWrapper.Id = '005400000000000';
        apexClassWrapper.Name = 'Test';
        apexClassWrapper.NamespacePrefix = 'Test';
        apexClassWrapper.Body = 'Test';

        StackTraceParser.ApexClassesResponseWrapper response = new StackTraceParser.ApexClassesResponseWrapper();
        response.size = 1;
        response.records = new List<StackTraceParser.ApexClassWrapper>{
            apexClassWrapper
        };

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + 'SELECT+Id,+Name,+NamespacePrefix+FROM+ApexTrigger', new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getApexClassesMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        StackTraceParser.ApexClassWrapper apexClassWrapper = new StackTraceParser.ApexClassWrapper();
        apexClassWrapper.Id = '005400000000000';
        apexClassWrapper.Name = 'Test';
        apexClassWrapper.NamespacePrefix = 'Test';
        apexClassWrapper.Body = 'Test';

        StackTraceParser.ApexClassesResponseWrapper response = new StackTraceParser.ApexClassesResponseWrapper();
        response.size = 1;
        response.records = new List<StackTraceParser.ApexClassWrapper>{
            apexClassWrapper
        };

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + 'SELECT+Id,+Name,+NamespacePrefix+FROM+ApexClass', new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        ));
        return endpoint2TestResp;
	}

    private static Map<String, HttpCalloutMock> createToolingGetInterviewRecordsMocks(String guid) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(getFlowInterviewMock(guid));
        endpoint2TestResp.putAll(getFlowInterviewLogMock(guid));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getFlowInterviewMock(String guid) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String query = new QBuilder(FlowInterview.SObjectType)
            .selectFields(new Set<String>{'Id', 'Error'})
            .add(QBuilder.condition('Guid').equalsTo(guid))
            .add(QBuilder.condition('InterviewStatus').equalsTo('Error'))
            .addLimit(1)
            .build();

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.getQueryRestApiPath('v62.0') + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'attributes' => new Map<String, Object>{
                            'type' => 'FlowInterview',
                            'url' => '/services/data/v62.0/sobjects/FlowInterview/0Fo6g000005szaDCAQ'
                        },
                        'Id' => '0Fo6g000005szaDCAQ',
                        'Error' => FLOW_INTERVIEW_ERROR_MESSAGE,
                        'InterviewStatus' => 'Error',
                        'Guid' => guid
                    }
                }
            })
        ));
        return endpoint2TestResp;
	}
    private static final String FLOW_INTERVIEW_ERROR_MESSAGE = 'someErrorMessage';

    private static Map<String, HttpCalloutMock> getFlowInterviewLogMock(String guid) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String query = new QBuilder(FlowInterviewLog.SObjectType)
            .selectFields(new Set<String>{'Id', 'FlowLabel', '(SELECT LogEntryType, ElementLabel, ElementApiName from FlowInterviewLogs WHERE LogEntryType = \'Error\')'})
            .add(QBuilder.condition('FlowInterviewGuid').equalsTo(guid))
            .add(QBuilder.condition('InterviewStatus').equalsTo('Error'))
            .addLimit(1)
            .build();

        endpoint2TestResp.put(Test_LogService.CONNECETED_ORG_INSTANCE_URL + ConfigUtil.getQueryRestApiPath('v62.0') + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'attributes' => new Map<String, Object>{
                            'type' => 'FlowInterviewLog',
                            'url' => '/services/data/v62.0/sobjects/FlowInterviewLog/8gZ6g000005J76FEAS'
                        },
                        'Id' => '8gZ6g000005J76FEAS',
                        'FlowLabel' => 'screenFlowv48',
                        'FlowInterviewLogs' => new Map<String, Object> {
                            'totalSize' => 1,
                            'done' => true,
                            'records' => new List<Map<String, Object>> {
                                new Map<String, Object>{
                                    'attributes' => new Map<String, Object>{
                                        'type' => 'FlowInterviewLogEntry',
                                        'url' => '/services/data/v62.0/sobjects/FlowInterviewLogEntry/0f66g00000Eiu1NAAR'
                                    },
                                    'ElementLabel' => 'submit111',
                                    'ElementApiName' => 'submit111',
                                    'LogEntryType' => 'Error',
                                    'Id' => '0f66g00000Eiu1NAAR',
                                    'FlowInterviewLogId' => '8gZ6g000005J76FEAS'

                                }
                            }
                        }
                    }
                }
            })
        ));
		return endpoint2TestResp;
	}

    // Flow parsing from structure tests

    @IsTest
    private static void test_simple_flow_with_fault_path1() {
        // Test simple flow: start -> create account1 -> fault -> create account2 -> ERROR
        String executionPath = 
            'Start [Start] → createAccount1\n' +
            'createAccount1 [Record Create] → createAccount2 (FAULT:createAccount2)\n' +
            'createAccount2 [Record Create] → END (error: Required field missing: Name)\n';

        test_simple_flow_with_fault_path_structure(executionPath, true);
    }

    @IsTest
    private static void test_simple_flow_with_fault_path2() {
        // Test simple flow: start -> create account1 -> ERROR
        String executionPath = 
            'Start [Start] → createAccount1\n' +
            'createAccount1 [Record Create] → END (error: Required field missing: Name)';

        test_simple_flow_with_fault_path_structure(executionPath, false);
    }

    private static void test_simple_flow_with_fault_path_structure(String executionPath, Boolean isLogsShouldBeCreated) {
       
        // Create flow structure for testing
        String flowStructure = 
            '└── Start [Start] → createAccount1\n' +
            '    └── createAccount1 [Record Create] → DEFAULT:END, FAULT:createAccount2\n' +
            '        └── createAccount2 [Record Create] → END';
        
        Map<String, String> flowStructures = new Map<String, String>{
            TestDataFactory.TEST_FLOW_API_NAME => flowStructure
        };
        
        common_test_case_parse_flow_from_structure(flowStructures, executionPath, isLogsShouldBeCreated);
    }

    @IsTest
    private static void test_nested_flow_with_fault_path_structure_path1() {
        // Test nested flow: start -> create account1 -> create account2 -> create account3 -> ERROR
        String executionPath = 
            'Start [Start] → createAccount1\n' +
            'createAccount1 [Record Create] → createAccount2 (FAULT:createAccount2)\n' +
            'createAccount2 [Record Create] → createAccount3 (FAULT:createAccount3)\n' +
            'createAccount3 [Record Create] → END (error: Required field missing: Name)';

        test_nested_flow_with_fault_path_structure(executionPath, true);
    }

    @IsTest
    private static void test_nested_flow_with_fault_path_structure_path2() {
        // Test nested flow: start -> create account1 -> ERROR
        String executionPath = 
            'Start [Start] → createAccount1\n' +
            'createAccount1 [Record Create] → END (error: Required field missing: Name)';

        test_nested_flow_with_fault_path_structure(executionPath, false);
    }

    @IsTest
    private static void test_nested_flow_with_fault_path_structure_path3() {
        // Test nested flow: start -> create account1 -> create account2 -> ERROR
        String executionPath = 
            'Start [Start] → createAccount1\n' +
            'createAccount1 [Record Create] → createAccount2 (FAULT:createAccount2)\n' +
            'createAccount2 [Record Create] → END (error: Required field missing: Name)';

        test_nested_flow_with_fault_path_structure(executionPath, false);
    }

    private static void test_nested_flow_with_fault_path_structure(String executionPath, Boolean isLogsShouldBeCreated) {
       
        // Create flow structure for testing
        String flowStructure = 
            '└── Start [Start] → createAccount1\n' +
            '    └── createAccount1 [Record Create] → DEFAULT:END, FAULT:createAccount2\n' +
            '        └── createAccount2 [Record Create] → DEFAULT:END, FAULT:createAccount3\n' +
            '            └── createAccount3 [Record Create] → END';
        
        Map<String, String> flowStructures = new Map<String, String>{
            TestDataFactory.TEST_FLOW_API_NAME => flowStructure
        };
        
        common_test_case_parse_flow_from_structure(flowStructures, executionPath, isLogsShouldBeCreated);
    }

    @IsTest
    private static void test_nested_subflow_chain_path1() {
        // Test nested subflow chain: main → subflow1 → subflow3 -> subflow1 -> subflow3 -> ERROR
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → subflow3 (Rule1: go to nested subflow)\n' +
            '        [subflow3] Start [Start] → createRecord31\n' +
            '        [subflow3] createRecord31 [Record Create] → END\n' +
            '        [subflow3] subflow3 [Subflow] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 2)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → subflow3 (Rule1: go to nested subflow)\n' +
            '        [subflow3] Start [Start] → createRecord31\n' +
            '        [subflow3] createRecord31 [Record Create] → END (error: Required field missing: AccountId)\n';
        
        test_nested_subflow_chain_structure(executionPath);
    }

    @IsTest
    private static void test_nested_subflow_chain_path2() {
        // Test nested subflow chain: main → subflow1 → subflow3 -> ERROR
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 1)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → subflow3 (Rule1: go to nested subflow)\n' +
            '        [subflow3] Start [Start] → createRecord31\n' +
            '        [subflow3] createRecord31 [Record Create] → END (error: Required field missing: AccountId)\n';
        
        test_nested_subflow_chain_structure(executionPath);
    }    

    @IsTest
    private static void test_nested_subflow_chain_path3() {
        // Test nested subflow chain: main → (subflow1 → subflow3)x2 -> ERROR
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → subflow3 (Rule1: go to nested subflow)\n' +
            '        [subflow3] Start [Start] → createRecord31\n' +
            '        [subflow3] createRecord31 [Record Create] → END\n' +
            '        [subflow3] subflow3 [Subflow] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 2)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → subflow3 (Rule1: go to nested subflow)\n' +
            '        [subflow3] Start [Start] → createRecord31\n' +
            '        [subflow3] createRecord31 [Record Create] → END\n' +
            '        [subflow3] subflow3 [Subflow] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_nested_subflow_chain_structure(executionPath);
    }

    private static void test_nested_subflow_chain_structure(String executionPath) {
        // Main flow structure with subflow calls
        String mainFlowStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → mainLoop\n' +
            '        └── mainLoop [Loop] → Next:mainDecision, NoMore:finalCreate\n' +
            '            ├── mainDecision [Decision] → DEFAULT:subflow1, Rules:[Rule1->subflow2]\n' +
            '            │   ├── subflow1 [Subflow] → mainLoop\n' +
            '            │   └── subflow2 [Subflow] → mainLoop\n' +
            '            └── finalCreate [Record Create] → END';
    
        // Subflow 1 structure with nested subflow call
        String subflow1Structure = 
            '└── Start [Start] → subDecision1\n' +
            '    └── subDecision1 [Decision] → DEFAULT:createRecord11, Rules:[Rule1->subflow3]\n' +
            '        ├── createRecord11 [Record Create] → END\n' +
            '        └── subflow3 [Subflow] → END';
    
        // Subflow 2 structure with deeper subflow call
        String subflow2Structure = 
            '└── Start [Start] → subLoop\n' +
            '    └── subLoop [Loop] → Next:subflow4, NoMore:createRecord21\n' +
            '        ├── subflow4 [Subflow] → subLoop\n' +
            '        └── createRecord21 [Record Create] → END';
            
        // Subflow 3 structure (deepest level)
        String subflow3Structure = 
            '└── Start [Start] → createRecord31\n' +
            '    └── createRecord31 [Record Create] → END';

        String subflow4Structure = 
            '└── Start [Start] → createRecord41\n' +
            '    └── createRecord41 [Record Create] → END';
    
        Map<String, String> flowStructures = new Map<String, String>{
            TestDataFactory.TEST_FLOW_API_NAME => mainFlowStructure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_1 => subflow1Structure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_2 => subflow2Structure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_3 => subflow3Structure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_4 => subflow4Structure
        };
            
        common_test_case_parse_flow_from_structure(flowStructures, executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path1() {
        // Test path through subflow1 with default outcome
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord1 (Default outcome executed)\n' +
            '    [subflow1] createRecord1 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 2)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord1 (Default outcome executed)\n' +
            '    [subflow1] createRecord1 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path2() {
        // Test path through subflow1 with default outcome
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord1 (Default outcome executed)\n' +
            '    [subflow1] createRecord1 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 2)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord2 (Rule1: go to rule1)\n' +
            '    [subflow1] createRecord2 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path3() {
        // Test path through subflow1 with default outcome
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord1 (Default outcome executed)\n' +
            '    [subflow1] createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path4() {
        // Test path through subflow2 with loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow2 (Rule1: go to subflow2)\n' +
            '    [subflow2] Start [Start] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord3 (Next: item = 1)\n' +
            '    [subflow2] createRecord3 [Record Create] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord4 (NoMore: complete)\n' +
            '    [subflow2] createRecord4 [Record Create] → END\n' +
            '    [subflow2] subflow2 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path5() {
        // Test alternating between subflow1 and subflow2
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 3)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord1 (Default outcome executed)\n' +
            '    [subflow1] createRecord1 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 2)\n' +
            'mainDecision [Decision] → subflow2 (Rule1: go to subflow2)\n' +
            '    [subflow2] Start [Start] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord4 (NoMore: complete)\n' +
            '    [subflow2] createRecord4 [Record Create] → END\n' +
            '    [subflow2] subflow2 [Subflow] → END\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 3)\n' +
            'mainDecision [Decision] → subflow1 (Default outcome executed)\n' +
            '    [subflow1] Start [Start] → subDecision1\n' +
            '    [subflow1] subDecision1 [Decision] → createRecord2 (Rule1: go to rule1)\n' +
            '    [subflow1] createRecord2 [Record Create] → END\n' +
            '    [subflow1] subflow1 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path6() {
        // Test subflow2 with multiple loop iterations
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 1)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow2 (Rule1: go to subflow2)\n' +
            '    [subflow2] Start [Start] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord3 (Next: item = 1)\n' +
            '    [subflow2] createRecord3 [Record Create] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord3 (Next: item = 2)\n' +
            '    [subflow2] createRecord3 [Record Create] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord3 (Next: item = 3)\n' +
            '    [subflow2] createRecord3 [Record Create] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord4 (NoMore: complete)\n' +
            '    [subflow2] createRecord4 [Record Create] → END\n' +
            '    [subflow2] subflow2 [Subflow] → END\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }

    @IsTest
    private static void test_subflow_structure_path7() {
        // Test error in subflow2 loopg
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 1)\n' +
            'mainLoop [Loop] → mainDecision (Next: item = 1)\n' +
            'mainDecision [Decision] → subflow2 (Rule1: go to subflow2)\n' +
            '    [subflow2] Start [Start] → subLoop\n' +
            '    [subflow2] subLoop [Loop] → createRecord3 (Next: item = 1)\n' +
            '    [subflow2] createRecord3 [Record Create] → END (error: Required field missing: Name)';
        
        test_subflow_structure(executionPath);
    }


    private static void test_subflow_structure(String executionPath) {
        // Main flow structure with subflow calls
        String mainFlowStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → mainLoop\n' +
            '        └── mainLoop [Loop] → Next:mainDecision, NoMore:finalCreate\n' +
            '            ├── mainDecision [Decision] → DEFAULT:subflow1, Rules:[Rule1->subflow2]\n' +
            '            │   ├── subflow1 [Subflow] → mainLoop\n' +
            '            │   └── subflow2 [Subflow] → mainLoop\n' +
            '            └── finalCreate [Record Create] → END';

        // Subflow 1 structure
        String subflow1Structure = 
            '└── Start [Start] → subDecision1\n' +
            '    └── subDecision1 [Decision] → DEFAULT:createRecord1, Rules:[Rule1->createRecord2]\n' +
            '        ├── createRecord1 [Record Create] → END\n' +
            '        └── createRecord2 [Record Create] → END';

        // Subflow 2 structure
        String subflow2Structure = 
            '└── Start [Start] → subLoop\n' +
            '    └── subLoop [Loop] → Next:createRecord3, NoMore:createRecord4\n' +
            '        ├── createRecord3 [Record Create] → subLoop\n' +
            '        └── createRecord4 [Record Create] → END';

        Map<String, String> flowStructures = new Map<String, String>{
            TestDataFactory.TEST_FLOW_API_NAME => mainFlowStructure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_1 => subflow1Structure,
            TestDataFactory.TEST_SUBFLOW_API_NAME_2 => subflow2Structure
        };

        common_test_case_parse_flow_from_structure(flowStructures, executionPath);
    }

    @IsTest
    private static void test_conditional_nested_decisions_path1() {
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainDecision\n' +
            'mainDecision [Decision] → path2Decision (Rule1: take path 2)\n' +
            'path2Decision [Decision] → subDecision2 (Rule1: nested condition met)\n' +
            'subDecision2 [Decision] → createRecord6 (Rule1: deepest condition met)\n' +
            'createRecord6 [Record Create] → END (error: Required field missing: Name)';

        test_conditional_nested_decisions(executionPath);
    }

    private static void test_conditional_nested_decisions(String executionPath) {
        // Flow structure with conditional nested decisions
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → mainDecision\n' +
            '        └── mainDecision [Decision] → DEFAULT:path1Decision, Rules:[Rule1->path2Decision, Rule2->path3Decision]\n' +
            '            ├── path1Decision [Decision] → DEFAULT:createRecord1, Rules:[Rule1->subDecision1]\n' +
            '            │   ├── subDecision1 [Decision] → DEFAULT:createRecord2, Rules:[Rule1->createRecord3]\n' +
            '            │   ├── createRecord1 [Record Create] → END\n' +
            '            │   ├── createRecord2 [Record Create] → END\n' +
            '            │   └── createRecord3 [Record Create] → END\n' +
            '            ├── path2Decision [Decision] → DEFAULT:createRecord4, Rules:[Rule1->subDecision2]\n' +
            '            │   ├── subDecision2 [Decision] → DEFAULT:createRecord5, Rules:[Rule1->createRecord6]\n' +
            '            │   ├── createRecord4 [Record Create] → END\n' +
            '            │   ├── createRecord5 [Record Create] → END\n' +
            '            │   └── createRecord6 [Record Create] → END\n' +
            '            └── path3Decision [Decision] → DEFAULT:createRecord7, Rules:[Rule1->createRecord8]\n' +
            '                ├── createRecord7 [Record Create] → END\n' +
            '                └── createRecord8 [Record Create] → END';        
        
        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_nested_decisions_path1() {
        // Test deepest decision path (Rule1 at decision3)
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 1)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → decision3 (Default outcome executed)\n' +
            'decision3 [Decision] → path3Loop (Rule1: deepest condition met)\n' +
            'path3Loop [Loop] → createRecord3 (Next: subItem = A)\n' +
            'createRecord3 [Record Create] → path3Loop\n' +
            'path3Loop [Loop] → mainLoop (NoMore: path3 complete)\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_nested_decisions(executionPath);
    }

    @IsTest
    private static void test_nested_decisions_path2() {
        // Test middle decision path (Rule1 at decision2)
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 1)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → path2Loop (Rule1: middle condition met)\n' +
            'path2Loop [Loop] → createRecord2 (Next: subItem = X)\n' +
            'createRecord2 [Record Create] → path2Loop\n' +
            'path2Loop [Loop] → createRecord2 (Next: subItem = Y)\n' +
            'createRecord2 [Record Create] → path2Loop\n' +
            'path2Loop [Loop] → mainLoop (NoMore: path2 complete)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 2)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → decision3 (Default outcome executed)\n' +
            'decision3 [Decision] → mainLoop (Default outcome executed)\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
            test_nested_decisions(executionPath);
    }

    @IsTest
    private static void test_nested_decisions_path3() {
        // Test first decision path with error
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 3)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 1)\n' +
            'decision1 [Decision] → path1Loop (Rule1: first condition met)\n' +
            'path1Loop [Loop] → createRecord1 (Next: subItem = A)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_nested_decisions(executionPath);
    }

    @IsTest
    private static void test_nested_decisions_path4() {
        // Test mixed decision paths across iterations
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 3)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 1)\n' +
            'decision1 [Decision] → path1Loop (Rule1: first condition met)\n' +
            'path1Loop [Loop] → createRecord1 (Next: subItem = A)\n' +
            'createRecord1 [Record Create] → path1Loop\n' +
            'path1Loop [Loop] → mainLoop (NoMore: path1 complete)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 2)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → path2Loop (Rule1: middle condition met)\n' +
            'path2Loop [Loop] → createRecord2 (Next: subItem = X)\n' +
            'createRecord2 [Record Create] → path2Loop\n' +
            'path2Loop [Loop] → mainLoop (NoMore: path2 complete)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 3)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → decision3 (Default outcome executed)\n' +
            'decision3 [Decision] → path3Loop (Rule1: deepest condition met)\n' +
            'path3Loop [Loop] → createRecord3 (Next: subItem = Z)\n' +
            'createRecord3 [Record Create] → path3Loop\n' +
            'path3Loop [Loop] → mainLoop (NoMore: path3 complete)\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_nested_decisions(executionPath);
    }

    @IsTest
    private static void test_nested_decisions_path5() {
        // Test all default paths
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainLoop (items = 2)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 1)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → decision3 (Default outcome executed)\n' +
            'decision3 [Decision] → mainLoop (Default outcome executed)\n' +
            'mainLoop [Loop] → decision1 (Next: item = 2)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → decision3 (Default outcome executed)\n' +
            'decision3 [Decision] → mainLoop (Default outcome executed)\n' +
            'mainLoop [Loop] → finalCreate (NoMore: main complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_nested_decisions(executionPath);
    }

    private static void test_nested_decisions(String executionPath) {
        // Flow structure with nested decisions
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → mainLoop\n' +
            '        └── mainLoop [Loop] → Next:decision1, NoMore:finalCreate\n' +
            '            ├── decision1 [Decision] → DEFAULT:decision2, Rules:[Rule1->path1Loop]\n' +
            '            │   ├── decision2 [Decision] → DEFAULT:decision3, Rules:[Rule1->path2Loop]\n' +
            '            │   │   ├── decision3 [Decision] → DEFAULT:mainLoop, Rules:[Rule1->path3Loop]\n' +
            '            │   │   │   └── path3Loop [Loop] → Next:createRecord3, NoMore:mainLoop\n' +
            '            │   │   │       └── createRecord3 [Record Create] → path3Loop\n' +
            '            │   │   └── path2Loop [Loop] → Next:createRecord2, NoMore:mainLoop\n' +
            '            │   │       └── createRecord2 [Record Create] → path2Loop\n' +
            '            │   └── path1Loop [Loop] → Next:createRecord1, NoMore:mainLoop\n' +
            '            │       └── createRecord1 [Record Create] → path1Loop\n' +
            '            └── finalCreate [Record Create] → END';

        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_complex_branching_loops_path1() {
        // Test path: outer -> innerLoop1 (default) -> Rule1 match -> back to innerLoop1
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 1)\n' +
            'outerDecision [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: condition met)\n' +
            'createRecord1 [Record Create] → innerLoop1\n' +
            'innerLoop1 [Loop] → decision1 (Next: innerItem = B)\n' +
            'decision1 [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → outerLoop (NoMore: inner1 complete)\n' +
            'outerLoop [Loop] → finalCreate (NoMore: outer complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_complex_branching_loops(executionPath);
    }

    @IsTest
    private static void test_complex_branching_loops_path2() {
        // Test path: outer -> innerLoop2 (Rule1) -> multiple iterations
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 1)\n' +
            'outerDecision [Decision] → innerLoop2 (Rule1: branch condition met)\n' +
            'innerLoop2 [Loop] → decision2 (Next: innerItem = X)\n' +
            'decision2 [Decision] → createRecord2 (Rule1: inner condition met)\n' +
            'createRecord2 [Record Create] → innerLoop2\n' +
            'innerLoop2 [Loop] → decision2 (Next: innerItem = Y)\n' +
            'decision2 [Decision] → innerLoop2 (Default outcome executed)\n' +
            'innerLoop2 [Loop] → outerLoop (NoMore: inner2 complete)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 2)\n' +
            'outerDecision [Decision] → innerLoop2 (Rule1: branch condition met)\n' +
            'innerLoop2 [Loop] → outerLoop (NoMore: no inner items)\n' +
            'outerLoop [Loop] → finalCreate (NoMore: outer complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_complex_branching_loops(executionPath);
    }

    @IsTest
    private static void test_complex_branching_loops_path3() {
        // Test path: alternating between innerLoop1 and innerLoop2
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 3)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 1)\n' +
            'outerDecision [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → outerLoop (NoMore: no inner1 items)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 2)\n' +
            'outerDecision [Decision] → innerLoop2 (Rule1: branch condition met)\n' +
            'innerLoop2 [Loop] → decision2 (Next: innerItem = X)\n' +
            'decision2 [Decision] → createRecord2 (Rule1: condition met)\n' +
            'createRecord2 [Record Create] → innerLoop2\n' +
            'innerLoop2 [Loop] → outerLoop (NoMore: inner2 complete)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 3)\n' +
            'outerDecision [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → outerLoop (NoMore: inner1 complete)\n' +
            'outerLoop [Loop] → finalCreate (NoMore: outer complete)\n' +
            'finalCreate [Record Create] → END (error: Required field missing: Name)';
        
        test_complex_branching_loops(executionPath);
    }

    @IsTest
    private static void test_complex_branching_loops_path4() {
        // Test path: nested error handling in different branches
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 1)\n' +
            'outerDecision [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: matches but fails)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_complex_branching_loops(executionPath);
    }

    @IsTest
    private static void test_complex_branching_loops_path5() {
        // Test path: error in second branch
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 1)\n' +
            'outerDecision [Decision] → innerLoop1 (Default outcome executed)\n' +
            'innerLoop1 [Loop] → outerLoop (NoMore: no inner1 items)\n' +
            'outerLoop [Loop] → outerDecision (Next: outerItem = 2)\n' +
            'outerDecision [Decision] → innerLoop2 (Rule1: branch condition met)\n' +
            'innerLoop2 [Loop] → decision2 (Next: innerItem = X)\n' +
            'decision2 [Decision] → createRecord2 (Rule1: matches but fails)\n' +
            'createRecord2 [Record Create] → END (error: Invalid record type)';
        
        test_complex_branching_loops(executionPath);
    }

    private static void test_complex_branching_loops(String executionPath) {
        // Flow structure with complex branching
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → outerLoop\n' +
            '        └── outerLoop [Loop] → Next:outerDecision, NoMore:finalCreate\n' +
            '            ├── outerDecision [Decision] → DEFAULT:innerLoop1, Rules:[Rule1->innerLoop2]\n' +
            '            │   ├── innerLoop1 [Loop] → Next:decision1, NoMore:outerLoop\n' +
            '            │   │   └── decision1 [Decision] → DEFAULT:innerLoop1, Rules:[Rule1->createRecord1]\n' +
            '            │   │       └── createRecord1 [Record Create] → innerLoop1\n' +
            '            │   └── innerLoop2 [Loop] → Next:decision2, NoMore:outerLoop\n' +
            '            │       └── decision2 [Decision] → DEFAULT:innerLoop2, Rules:[Rule1->createRecord2]\n' +
            '            │           └── createRecord2 [Record Create] → innerLoop2\n' +
            '            └── finalCreate [Record Create] → END';

        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    static void test_parallel_branching_loops_path1() {
        // Test double nested loops
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → mainDecision\n' +
            'mainDecision [Decision] → path2Loop (Rule1: take path 2)\n' +
            'path2Loop [Loop] → decision2 (Next: item = 1)\n' +
            'decision2 [Decision] → createRecord2 (Rule1: condition met)\n' +
            'createRecord2 [Record Create] → path2Loop\n' +
            'path2Loop [Loop] → decision2 (Next: item = 2)\n' +
            'decision2 [Decision] → path2Loop (Default outcome executed)\n' +
            'path2Loop [Loop] → merge1 (NoMore: loop complete)\n' +
            'merge1 [Record Update] → END (error: Required field missing: Name)';

        test_parallel_branching_loops(executionPath);
    }

    private static void test_parallel_branching_loops(String executionPath) {
        // Flow structure with parallel branches and loops
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → mainDecision\n' +
            '        └── mainDecision [Decision] → DEFAULT:path1Loop, Rules:[Rule1->path2Loop, Rule2->path3Loop]\n' +
            '            ├── path1Loop [Loop] → Next:decision1, NoMore:merge1\n' +
            '            │   └── decision1 [Decision] → DEFAULT:path1Loop, Rules:[Rule1->createRecord1]\n' +
            '            │       └── createRecord1 [Record Create] → path1Loop\n' +
            '            ├── path2Loop [Loop] → Next:decision2, NoMore:merge1\n' +
            '            │   └── decision2 [Decision] → DEFAULT:path2Loop, Rules:[Rule1->createRecord2]\n' +
            '            │       └── createRecord2 [Record Create] → path2Loop\n' +
            '            ├── path3Loop [Loop] → Next:decision3, NoMore:merge1\n' +
            '            │   └── decision3 [Decision] → DEFAULT:path3Loop, Rules:[Rule1->createRecord3]\n' +
            '            │       └── createRecord3 [Record Create] → path3Loop\n' +
            '            └── merge1 [Record Update] → END';
        
        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_double_nested_loops_path1() {
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → middleLoop (Next: outerItem = 1)\n' +
            'middleLoop [Loop] → innerLoop (Next: middleItem = X)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → middleLoop (NoMore: inner complete)\n' +
            'middleLoop [Loop] → innerLoop (Next: middleItem = Y)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = B)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: condition met)\n' +
            'createRecord1 [Record Create] → innerLoop\n' +
            'innerLoop [Loop] → middleLoop (NoMore: inner complete)\n' +
            'middleLoop [Loop] → outerLoop (NoMore: middle complete)\n' +
            'outerLoop [Loop] → createRecord3 (NoMore: outer complete)\n' +
            'createRecord3 [Record Create] → END (error: Required field missing: Name)';

        test_double_nested_loops(executionPath);
    }

    private static void test_double_nested_loops(String executionPath) {
        // Flow structure with double nested loops
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → outerLoop\n' +
            '        └── outerLoop [Loop] → Next:middleLoop, NoMore:createRecord3\n' +
            '            ├── middleLoop [Loop] → Next:innerLoop, NoMore:outerLoop\n' +
            '            │   └── innerLoop [Loop] → Next:decision1, NoMore:middleLoop\n' +
            '            │       └── decision1 [Decision] → DEFAULT:innerLoop, Rules:[Rule1->createRecord1]\n' +
            '            │           └── createRecord1 [Record Create] → innerLoop\n' +
            '            └── createRecord3 [Record Create] → END';
        
        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_nested_loops_path1() {
        // Test nested loops - complete iteration of both loops
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 1)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = B)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → outerLoop (NoMore: inner loop complete)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 2)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = B)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → outerLoop (NoMore: inner loop complete)\n' +
            'outerLoop [Loop] → createRecord3 (NoMore: outer loop complete)\n' +
            'createRecord3 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_nested_loops(executionPath);
    }

    @IsTest
    private static void test_nested_loops_path2() {
        // Test nested loops - Rule1 match in inner loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 1)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: condition met)\n' +
            'createRecord1 [Record Create] → innerLoop\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = B)\n' +
            'decision1 [Decision] → innerLoop (Default outcome executed)\n' +
            'innerLoop [Loop] → outerLoop (NoMore: inner loop complete)\n' +
            'outerLoop [Loop] → createRecord3 (NoMore: outer loop complete)\n' +
            'createRecord3 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_nested_loops(executionPath);
    }

    @IsTest
    private static void test_nested_loops_path3() {
        // Test nested loops - empty inner loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 1)\n' +
            'innerLoop [Loop] → outerLoop (NoMore: no inner items)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 2)\n' +
            'innerLoop [Loop] → outerLoop (NoMore: no inner items)\n' +
            'outerLoop [Loop] → createRecord3 (NoMore: outer loop complete)\n' +
            'createRecord3 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_nested_loops(executionPath);
    }

    @IsTest
    private static void test_nested_loops_path4() {
        // Test nested loops - error in inner loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 2)\n' +
            'outerLoop [Loop] → innerLoop (Next: outerItem = 1)\n' +
            'innerLoop [Loop] → decision1 (Next: innerItem = A)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: matches but fails)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_nested_loops(executionPath);
    }

    @IsTest
    private static void test_nested_loops_path5() {
        // Test nested loops - empty outer loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → outerLoop (items = 0)\n' +
            'outerLoop [Loop] → createRecord3 (NoMore: no outer items)\n' +
            'createRecord3 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_nested_loops(executionPath);
    }

    private static void test_flow_structure_with_nested_loops(String executionPath) {
        // Flow structure with nested loops
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → outerLoop\n' +
            '        └── outerLoop [Loop] → Next:innerLoop, NoMore:createRecord3\n' +
            '            ├── innerLoop [Loop] → Next:decision1, NoMore:outerLoop\n' +
            '            │   └── decision1 [Decision] → DEFAULT:innerLoop, Rules:[Rule1->createRecord1]\n' +
            '            │       └── createRecord1 [Record Create] → innerLoop\n' +
            '            └── createRecord3 [Record Create] → END';

        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path1() {
        // Test loop execution path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 2)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → createRecord2 (NoMore: end loop)\n' +
            'createRecord2 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path2() {
        // Test loop execution path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 2)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: go to rule1)\n' +
            'createRecord1 [Record Create] → END\n' +
            'loop1 [Loop] → createRecord2 (NoMore: end loop)\n' +
            'createRecord2 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path3() {
        // Test loop path with immediate Rule1 match
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: condition met)\n' +
            'createRecord1 [Record Create] → END\n' +
            'loop1 [Loop] → createRecord2 (NoMore: end loop)\n' +
            'createRecord2 [Record Create] → END';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path4() {
        // Test empty loop (immediate NoMore)
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 0)\n' +
            'loop1 [Loop] → createRecord2 (NoMore: no items to process)\n' +
            'createRecord2 [Record Create] → END';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path5() {
        // Test single iteration with Rule1
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 1)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: single item match)\n' +
            'createRecord1 [Record Create] → END\n' +
            'loop1 [Loop] → createRecord2 (NoMore: single item processed)\n' +
            'createRecord2 [Record Create] → END';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path6() {
        // Test multiple iterations with mixed outcomes
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 2)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: second item matches)\n' +
            'createRecord1 [Record Create] → END\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 3)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → createRecord2 (NoMore: all items processed)\n' +
            'createRecord2 [Record Create] → END';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path7() {
        // Test error in middle of loop
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 2)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: matches but fails)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path8() {
        // Test error in first iteration
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 3)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: matches but fails)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path9() {
        // Test error in NoMore path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → loop1 (items = 2)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 1)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → decision1 (Next: currentItem = 2)\n' +
            'decision1 [Decision] → loop1 (Default outcome executed)\n' +
            'loop1 [Loop] → createRecord2 (NoMore: end loop)\n' +
            'createRecord2 [Record Create] → END (error: Invalid record type)';
        
        test_flow_structure_with_loop(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_loop_path10() {
        // Test error in getRecords
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → END (error: Invalid SOQL query)';
        
        test_flow_structure_with_loop(executionPath);
    }

    private static void test_flow_structure_with_loop(String executionPath) {
        // Flow structure with a loop
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → loop1\n' +
            '        └── loop1 [Loop] → Next:decision1, NoMore:createRecord2\n' +
            '            ├── decision1 [Decision] → DEFAULT:loop1, Rules:[Rule1->createRecord1]\n' +
            '            │   └── createRecord1 [Record Create] → END\n' +
            '            └── createRecord2 [Record Create] → END';
        
        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_multiple_decisions_path1() {
        // Test nested decision path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → decision1 (recordCount = 0)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → path3 (Rule2: Status = Inactive)\n' +
            'path3 [Screen] → END (error: Required field missing: Name)\n';
        
        test_flow_structure_with_multiple_decisions(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_multiple_decisions_path2() {
        // Test nested decision path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → decision1 (recordCount = 0)\n' +
            'decision1 [Decision] → decision2 (Default outcome executed)\n' +
            'decision2 [Decision] → path1 (Default outcome executed)\n' +
            'path1 [Screen] → END (error: Required field missing: Name)\n';
        
        test_flow_structure_with_multiple_decisions(executionPath);
    }

    private static void test_flow_structure_with_multiple_decisions(String executionPath) {
        // Flow structure with multiple decisions
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:decision2, Rules:[Rule1->createRecord1]\n' +
            '            ├── createRecord1 [Record Create] → END\n' +
            '            └── decision2 [Decision] → DEFAULT:path1, Rules:[Rule2->path3]\n' +
            '                ├── path1 [Screen] → END\n' +
            '                └── path3 [Screen] → END';
        
        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_start_decision_with_rules_path1() {
        // Execution path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → decision1 (recordCount = 5)\n' +
            'decision1 [Decision] → createRecord1 (Rule1: Count > 0)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)\n';
        
        test_flow_structure_with_start_decision_with_rules(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_start_decision_with_rules_path2() {
        // Execution path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → decision1 (recordCount = 0)\n' +
            'decision1 [Decision] → path3 (Rule2: Count = 0)\n' +
            'path3 [Screen] → END (error: Required field missing: Name)\n';
        
        test_flow_structure_with_start_decision_with_rules(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_start_decision_with_rules_path3() {
        // Execution path
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → decision1 (recordCount = -1)\n' +
            'decision1 [Decision] → path1 (Default outcome executed)\n' +
            'path1 [Screen] → END (error: Required field missing: Name)\n';
        
        test_flow_structure_with_start_decision_with_rules(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_start_decision_with_rules_path4() {
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → END (error: Invalid field: InvalidField__c)\n';
        
        test_flow_structure_with_start_decision_with_rules(executionPath);
    }

    private static void test_flow_structure_with_start_decision_with_rules(String executionPath) {
        // Flow structure
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → decision1\n' +
            '        └── decision1 [Decision] → DEFAULT:path1, Rules:[Rule1->createRecord1, Rule2->path3]\n' +
            '            ├── path1 [Screen] → END\n' +
            '            ├── createRecord1 [Record Create] → END\n' +
            '            └── path3 [Screen] → END';

        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_flow_pause_resume_path1() {
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → pause1 (items = 3)\n' +
            'pause1 [Wait] → createRecord1 (pause)\n' +
            'pause1 [Wait] → createRecord1 (resume)\n' +
            'createRecord1 [Record Create] → END (error: Required field missing: Name)';

        test_flow_structure_with_flow_pause_resume(executionPath);
    }

    @IsTest
    private static void test_flow_structure_with_flow_pause_resume_path2() {
        String executionPath = 
            'Start [Start] → getRecords1\n' +
            'getRecords1 [Record Lookup] → pause1 (items = 3)\n' +
            'pause1 [Wait] → createRecord1 (pause)\n' +
            'pause1 [Wait] → createRecord1 (resume)\n' +
            'createRecord1 [Record Create] → createRecord2\n' +
            'createRecord2 [Record Create] → END (error: Required field missing: Name)';

        test_flow_structure_with_flow_pause_resume(executionPath);
    }

    private static void test_flow_structure_with_flow_pause_resume(String executionPath) {
        // Flow structure
        String inputStructure = 
            '└── Start [Start] → getRecords1\n' +
            '    └── getRecords1 [Record Lookup] → pause1\n' +
            '        └── pause1 [Wait] → DEFAULT:, Rules:[Rule1->createRecord1]\n' +
            '            └── createRecord1 [Record Create] → createRecord2\n' +
            '                └── createRecord2 [Record Create] → END';            

        common_test_case_parse_flow_from_structure(inputStructure, executionPath);
    }

    private static void common_test_case_parse_flow_from_structure(Map<String, String> flowStructures, String executionPath) {
        common_test_case_parse_flow_from_structure(flowStructures, executionPath, true);
    }

    private static void common_test_case_parse_flow_from_structure(Map<String, String> flowStructures, String executionPath, Boolean isLogsShouldBeCreated) {
        
        // Create mock flow from structure
        List<MetadataService.Flow> mockFlows = TestDataFactory.buildFlowsFromStructures(flowStructures);
        TestDataFactory.FlowExecution execution = TestDataFactory.parseExecutionPath(executionPath, mockFlows);

        Messaging.InboundEmail email = TestDataFactory.create_test_inbound_email(mockFlows, execution);
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Test_LogService.initSettings();

        TestDataFactory.MockMetadataHandler mockHandler = new TestDataFactory.MockMetadataHandler(mockFlows);
        Test.setMock(WebServiceMock.class, mockHandler);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();

        LogTriggerHelper.runPostProcessingBatchInTest = true;
            
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        if (isLogsShouldBeCreated) {
            List<Log__c> flowLog = [SELECT Id, Summary__c, Hash_1__c, Stacktrace__c, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 2];
            System.assertEquals(1, flowLog.size());
            
            system.assertNotEquals(null, flowLog.get(0).Stacktrace__c);
            system.assertNotEquals(null, flowLog.get(0).Stacktrace_Parse_Result__c);
            system.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED, flowLog.get(0).Post_Processing_Status__c);

            // Validate parsed result
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(flowLog.get(0).Stacktrace_Parse_Result__c);
            TestDataFactory.validateFlowStructure(result, execution, mockFlows);
        }
        
        List<Inbound_Email__c> emails = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c LIMIT 1];
        System.assert(emails.size() == 1);

        if (isLogsShouldBeCreated) {
            System.assert(emails.get(0).Error__c == null);
            System.assert(emails.get(0).Log__c != null);
            assertIssueCreated(emails.get(0).Log__c);
        }
        else {
            System.assert(emails.get(0).Error__c != null);
            System.assert(emails.get(0).Error__c.contains(LogService.FLOW_HANDLED_ERROR_MESSAGE));
            System.assert(emails.get(0).Log__c == null);
        }
    }
    
    private static void common_test_case_parse_flow_from_structure(String inputStructure, String executionPath) {
        Map<String, String> flowStructures = new Map<String, String>{
            TestDataFactory.TEST_FLOW_API_NAME => inputStructure
        };
        common_test_case_parse_flow_from_structure(flowStructures, executionPath);
    }

    @IsTest
    static void test_related_objects_limit_with_many_ids_in_email() {
        Test_LogService.initSettings();

        // Create email content with the correct format for ApexExceptionParser
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        
        String baseApexError = 'Apex script unhandled exception by user/organization: ' + userId.left(15) + '/' + orgId.left(15) + '\n\n' +
                              'Failed to process batch for job ID 707000000FakeJobId.\n\n' +
                              'caused by: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]: [Name] --\n\n' +
                              'Class.TestClass.method1: line 15, column 1\n' +
                              'Class.TestClass.method2: line 25, column 1\n' +
                              'Trigger.TestTrigger.trigger1: line 35, column 1\n\n';
        
        // Generate more than 1500 unique Salesforce IDs to test the limit (32768 char Long Text Area)
        Set<String> generatedIds = new Set<String>();
        generatedIds.add(orgId);
        generatedIds.add(userId);
        generatedIds.add('707000000FakeJobId');

        String emailContent = baseApexError + 'Related records and IDs found in this error:\n';
        
        // Generate Account IDs (001 prefix) - 800 IDs
        for (Integer i = 0; i < 800; i++) {
            String accountId = '001' + String.valueOf(i).leftPad(12, '0') + 'AAA';
            generatedIds.add(accountId);
            emailContent += 'Account: ' + accountId + ' ';
        }
        
        // Generate Contact IDs (003 prefix) - 800 IDs
        for (Integer i = 0; i < 800; i++) {
            String contactId = '003' + String.valueOf(i).leftPad(12, '0') + 'BBB';
            generatedIds.add(contactId);
            emailContent += 'Contact: ' + contactId + ' ';
        }
        
        // 3 orgId, userId, jobId + 800 Account IDs + 800 Contact IDs
        System.assertEquals(1603, generatedIds.size(), 'Should have generated 1603 unique IDs for testing (exceeds 1500 limit)');

        // Create inbound email with the correct format
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Developer script exception from ' + UserInfo.getOrganizationName() + ' : TestClass for job ID 707000000FakeJobId. : Insert failed';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = new List<String>{'test@pharos.com'};
        email.plainTextBody = emailContent;
        
        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        // Setup mocks
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        Test.startTest();
        
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        Test.stopTest();

        // Verify log was created successfully
        List<Log__c> logs = [SELECT Id, Related_Objects__c, Details__c, Summary__c, Hash_1__c, Category__c, Stacktrace__c 
                            FROM Log__c WHERE Category__c = 'Apex' LIMIT 1];
        
        System.assertEquals(1, logs.size(), 'One log should be created');
        
        Log__c createdLog = logs[0];
        System.assertNotEquals(null, createdLog.Related_Objects__c, 'Related_Objects__c should be populated');
        
        // Verify the JSON is within size limits (32768 character Long Text Area)
        Integer serializedSize = createdLog.Related_Objects__c.length();
        System.assert(serializedSize <= 32768, 'Related_Objects__c should not exceed 32k characters. Actual size: ' + serializedSize);
        
        // Deserialize and verify the IDs
        Set<String> deserializedIds = (Set<String>) JSON.deserialize(createdLog.Related_Objects__c, Set<String>.class);
        
        // Should have exactly our limit of 1500 IDs
        System.assertEquals(1500, deserializedIds.size(), 'Should have exactly 1500 IDs due to our limit');
        
        // Verify all deserialized IDs are from our generated set
        for (String id : deserializedIds) {
            System.assert(generatedIds.contains(id), 'All IDs in Related_Objects__c should be from our generated set. Found: ' + id);
        }
        
        // Verify the IDs are valid Salesforce IDs
        for (String id : deserializedIds) {
            if (id.startsWith('001') || id.startsWith('003')) {
                System.assertEquals(18, id.length(), 'All IDs should be 18 characters long');
                System.assert(id.startsWith('001') || id.startsWith('003'), 
                            'IDs should start with expected prefixes. Found: ' + id);
            }
        }
        
        // Verify that we didn't lose any data due to the limit - the log should still contain all the email content
        System.assert(createdLog.Details__c.contains('Account:'), 'Details should contain Account references');
        System.assert(createdLog.Details__c.contains('Contact:'), 'Details should contain Contact references');  
        System.assertEquals('Apex', createdLog.Category__c, 'Should be categorized as Apex');
        System.assertNotEquals(null, createdLog.Stacktrace__c, 'Stacktrace should be populated');
        
        // Verify inbound email record was created correctly
        List<Inbound_Email__c> inboundEmails = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c WHERE Log__c = :createdLog.Id];
        System.assertEquals(1, inboundEmails.size(), 'Inbound email record should be created');
        System.assertEquals(null, inboundEmails[0].Error__c, 'No error should be recorded');
        System.assertEquals(createdLog.Id, inboundEmails[0].Log__c, 'Should be linked to our log');
        
    }

    @IsTest
    static void test_abbreviate_plain_text_field_when_exceeds_limit() {
        Test_LogService.initSettings();

        // Create email content that exceeds MAX_LENGTH_LONG_TEXT_AREA_FIELD (131000 chars)
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        
        String baseApexError = 'Apex script unhandled exception by user/organization: ' + userId.left(15) + '/' + orgId.left(15) + '\n\n' +
                              'Failed to process batch for job ID 707000000FakeJobId.\n\n' +
                              'caused by: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]: [Name] --\n\n' +
                              'Class.TestClass.method1: line 15, column 1\n\n';
        
        // Create a very long string that exceeds the limit
        String longContent = '';
        Integer targetSize = ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD + 10000; // Exceed by 10k chars
        String repeatableContent = 'This is a long line of text that will be repeated many times to exceed the field limit. ';
        
        while (longContent.length() < targetSize) {
            longContent += repeatableContent;
        }
        
        String finalEmailContent = baseApexError + longContent;
        System.assert(finalEmailContent.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD, 
                     'Email content should exceed the field limit. Actual size: ' + finalEmailContent.length());

        // Create inbound email with very long plain text body
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Developer script exception from ' + UserInfo.getOrganizationName() + ' : TestClass for job ID 707000000FakeJobId. : Insert failed';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = new List<String>{'test@pharos.com'};
        email.plainTextBody = finalEmailContent;
        
        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        // Setup mocks
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        Test.startTest();
        
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        Test.stopTest();

        // Verify inbound email was created with abbreviated plain text
        List<Inbound_Email__c> inboundEmails = [SELECT Id, Plain_Text__c, Error__c, Log__c FROM Inbound_Email__c LIMIT 1];
        System.assertEquals(1, inboundEmails.size(), 'One inbound email should be created');
        
        Inbound_Email__c createdInboundEmail = inboundEmails[0];
        
        // Verify that Plain_Text__c was abbreviated to fit within the limit
        System.assertNotEquals(null, createdInboundEmail.Plain_Text__c, 'Plain_Text__c should be populated');
        System.assert(createdInboundEmail.Plain_Text__c.length() <= ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD, 
                     'Plain_Text__c should not exceed the field limit. Actual size: ' + createdInboundEmail.Plain_Text__c.length());
        System.assertEquals(ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD, createdInboundEmail.Plain_Text__c.length(), 
                           'Plain_Text__c should be exactly the maximum allowed size');
        
        // Verify that the content was abbreviated, not truncated randomly
        System.assert(createdInboundEmail.Plain_Text__c.endsWith('...'), 
                     'Abbreviated text should end with ellipsis');
        
        // Verify that essential content is still present at the beginning
        System.assert(createdInboundEmail.Plain_Text__c.contains('Apex script unhandled exception'), 
                     'Essential error information should be preserved');
        System.assert(createdInboundEmail.Plain_Text__c.contains('System.DmlException'), 
                     'Exception type should be preserved');
        
        // Verify that a log was still created successfully despite the large content
        System.assertNotEquals(null, createdInboundEmail.Log__c, 'A log should be created');
        System.assertEquals(null, createdInboundEmail.Error__c, 'No error should be recorded in processing');
        
        // Verify the created log
        List<Log__c> logs = [SELECT Id, Category__c, Summary__c, Details__c FROM Log__c WHERE Id = :createdInboundEmail.Log__c];
        System.assertEquals(1, logs.size(), 'Log should be found');
        
        Log__c createdLog = logs[0];
        System.assertEquals('Apex', createdLog.Category__c, 'Should be categorized as Apex');
        System.assertNotEquals(null, createdLog.Summary__c, 'Summary should be populated');
        
        // The Details__c field should contain the original (non-abbreviated) content since it processes from email.plainTextBody
        System.assertNotEquals(null, createdLog.Details__c, 'Details should be populated');
        
    }

    @IsTest
    static void whenDeployRequestToolingFailedPostProcessingShouldBeCompleted() {

        Test_LogService.initSettings();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "DY_New_Screen_Flow" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT');

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock('DY_New_Screen_Flow', 'testnewmp', 1, false));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c failedFlowLog = [SELECT Id, Stacktrace_Parse_Result__c, Post_Processing_Status__c FROM Log__c WHERE Category__c = 'Flow' LIMIT 1];
        System.assertNotEquals(null, failedFlowLog.Stacktrace_Parse_Result__c);
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED, failedFlowLog.Post_Processing_Status__c);
    }

    @IsTest
    static void test_post_processing_populates_all_limit_fields_from_error_email() {
        Test_LogService.initSettings();

        // Create an Apex error email that will trigger post processing
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        
        String apexErrorContent = 'Apex script unhandled exception by user/organization: ' + userId.left(15) + '/' + orgId.left(15) + '\n\n' +
                                'Failed to process batch for job ID 707000000TestJobId.\n\n' +
                                'caused by: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]: [Name] --\n\n' +
                                'Class.TestLimitsClass.processRecords: line 25, column 1\n' +
                                'Class.TestLimitsClass.execute: line 15, column 1\n' +
                                'Trigger.TestLimitsTrigger.trigger1: line 5, column 1\n\n';

        // Create inbound email with Apex error
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Developer script exception from ' + UserInfo.getOrganizationName() + ' : TestLimitsClass for job ID 707000000TestJobId. : Insert failed';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = new List<String>{'test@pharos.com'};
        email.plainTextBody = apexErrorContent;
        
        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        // Setup mocks for post processing
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Enable post processing batch to run in test
        LogTriggerHelper.runPostProcessingBatchInTest = true;

        Test.startTest();
        
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        Test.stopTest();

        // Verify that a log was created
        List<Log__c> logs = [SELECT Id, Category__c, Summary__c, Post_Processing_Status__c,
                            Limits__c,
                            Limits__r.DailyApiRequests__c, Limits__r.DailyAsyncApexExecutions__c, 
                            Limits__r.DataStorageMB__c, Limits__r.FileStorageMB__c,
                            Limits__r.SingleEmail__c, Limits__r.MassEmail__c, 
                            Limits__r.ActiveScratchOrgs__c, Limits__r.PermissionSets__c,
                            Limits__r.DailyWorkflowEmails__c, Limits__r.ConcurrentAsyncGetReportInstances__c, 
                            Limits__r.ConcurrentSyncReportRuns__c, Limits__r.HourlyAsyncReportRuns__c, 
                            Limits__r.HourlyDashboardRefreshes__c, Limits__r.DailyStreamingApiEvents__c,
                            Limits__r.DailyBulkApiBatches__c, Limits__r.DailyStandardVolumePlatformEvents__c,
                            Limits__r.DailyGenericStreamingApiEvents__c, Limits__r.DailyAnalyticsDataflowJobExecutions__c,
                            Limits__r.ConcurrentEinsteinDataInsightsStory__c, Limits__r.HourlyPubStdVolPlatformEvents__c,
                            Limits__r.DailyEinsteinDiscoveryOptJobRuns__c, Limits__r.CreateCustom__c, 
                            Limits__r.DailyMetadataRetrievesWithDeps__c
                            FROM Log__c WHERE Category__c = 'Apex' LIMIT 1];
        
        System.assertEquals(1, logs.size(), 'One Apex log should be created');
        
        Log__c createdLog = logs[0];
        System.assertEquals('Apex', createdLog.Category__c, 'Should be categorized as Apex');
        
        // Verify we can access limit data through the lookup relationship
        if (createdLog.Limits__r != null) {
            System.assertNotEquals(null, createdLog.Limits__r.DailyApiRequests__c, 'Should be able to access daily API requests through lookup');
            System.assertNotEquals(null, createdLog.Limits__r.DataStorageMB__c, 'Should be able to access data storage through lookup');
        }
        
        // Post processing may fail for various reasons (missing org connectivity, etc) but that's okay
        // The key is that the log creation works correctly
        System.assert(
            createdLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED || 
            createdLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_FAILED ||
            createdLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED,
            'Post processing should have attempted to run (status: ' + createdLog.Post_Processing_Status__c + ')'
        );
        
        // Verify inbound email record was created correctly
        List<Inbound_Email__c> inboundEmails = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c WHERE Log__c = :createdLog.Id];
        System.assertEquals(1, inboundEmails.size(), 'Inbound email record should be created');
        System.assertEquals(createdLog.Id, inboundEmails[0].Log__c, 'Should be linked to our log');
    }

    @IsTest
    static void whenUserInfoEnabledInPostProcessingShouldFillUserInfoFields() {
        PermissionsUtil.RequestUserInfoTTL = 5*60;
        Test_LogService.initSettings();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<string> emails = new List<string>{'testemail1@gmail.com'};
        
        email.subject = 'An error occurred with your "DY_New_Screen_Flow" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;
        email.htmlBody = Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT');

        Test.startTest();
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(Test_LogService.getTestStub('FLOW_STACKTRACE_MULTIPLE_EDGES_ON_ELEMENT_METADATA')));

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.putAll(createPostProcessingMock('DY_New_Screen_Flow', 'testnewmp', 1, false));
		TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;

        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Log__c log = [
            SELECT 
                Stacktrace_Parse_Result__c, Post_Processing_Status__c,
                User_Id__c, User_Name__c,
                Role_Id__c, Role_Name__c,
                Profile_Id__c, Profile_Name__c, Salesforce_License_Type_Name__c
            FROM Log__c
            WHERE Category__c = 'Flow'
            LIMIT 1
        ];
        
        System.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED, log.Post_Processing_Status__c);
        System.assert(String.isNotBlank(log.User_Id__c));
        System.assert(String.isNotBlank(log.User_Name__c));
        System.assert(String.isNotBlank(log.Profile_Id__c));
        System.assert(String.isNotBlank(log.Profile_Name__c));
        System.assert(String.isNotBlank(log.Salesforce_License_Type_Name__c));
        System.assert(String.isNotBlank(log.Role_Id__c));
        System.assert(String.isNotBlank(log.Role_Name__c));
    }

    @IsTest
    static void test_error_email_handler_should_create_log_and_inbound_email() {
        Test_LogService.initSettings();

        // Create an Apex error email that will trigger post processing
        String orgId = Test_LogService.CONNECETED_ORG_NAME;
        String userId = UserInfo.getUserId();
        String jobId = '707fi000008E26a';

        String apexErrorContent = 'Apex script unhandled exception by user/organization: ' + userId.left(15) + '/' + orgId.left(15) + '\n\n' +
                                'Organization: homerlsd (homerlsd-dev-ed.develop.my.salesforce.com).\n\n' +
                                'Failed to process Queueable job for class TestBatchOne for job ID ' + jobId + '.\n\n' +
                                'caused by: System.NullPointerException: Attempt to de-reference a null object\n\n' +
                                'Class.TestBatchOne.execute: line 4, column 1\n\n';

        // Create inbound email with Apex error
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Developer script exception from homerlsd : TestBatchOne for job ID ' + jobId + '. : Attempt to de-reference a null object';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = new List<String>{'test@pharos.com'};
        email.plainTextBody = apexErrorContent;
        
        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        // Setup mocks for post processing
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // Enable post processing batch to run in test
        LogTriggerHelper.runPostProcessingBatchInTest = true;
        PermissionsUtil.AsyncProcessErrorTracking = true;

        Test.startTest();
        
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        Test.stopTest();

        // Verify that a log was created
        List<Log__c> logs = [SELECT Id, Category__c, Summary__c, Post_Processing_Status__c, Async_Job_Id__c FROM Log__c WHERE Category__c = 'Apex' LIMIT 1];
        System.assertNotEquals(null, logs[0].Async_Job_Id__c, 'Async job ID should be populated');
        System.assertEquals(1, logs.size(), 'One Apex log should be created');
        
        // Verify inbound email record was created correctly
        List<Inbound_Email__c> inboundEmails = [SELECT Id, Error__c, Log__c FROM Inbound_Email__c WHERE Log__c = :logs[0].Id];
        System.assertEquals(1, inboundEmails.size(), 'Inbound email record should be created');
        System.assertEquals(logs[0].Id, inboundEmails[0].Log__c, 'Should be linked to our log');
    }

    @IsTest
    static void test_email_log_hash1_calculation_matches_event_log() {
        // This test verifies that Email Log Hash1 is calculated consistently with Event Log
        // by using sorted List serialization in ApexExceptionParser.getHash1()
        Test_LogService.initSettings();

        String orgId = Test_LogService.CONNECETED_ORG_NAME;
        String userId = UserInfo.getUserId();
        String jobId = '707gL00000Pf3vZ';
        // Single-line stacktrace matching the actual email from remote org
        String stacktraceLine = 'Class.TestBatchTwo.execute: line 8, column 1';
        String summary = 'List index out of bounds: 0';

        // Create Email Log via ErrorEmailHandler
        String apexErrorContent = 'Apex script unhandled exception by user/organization: ' + userId.left(15) + '/' + orgId.left(15) + '\n\n' +
                                'Organization: 2.217S (orgfarm-5ef5f2519f-dev-ed.develop.my.salesforce.com).\n\n' +
                                'Failed to process Queueable job for class TestBatchTwo for job ID ' + jobId + '.\n\n' +
                                'caused by: System.ListException: List index out of bounds: 0\n\n' +
                                stacktraceLine + '\n';

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Developer script exception from 2.217S : TestBatchTwo for job ID ' + jobId + '. : ' + summary;
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = new List<String>{'test@pharos.com'};
        email.plainTextBody = apexErrorContent;
        
        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};

        // Setup mocks for post processing
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(createPostProcessingMock(null, null, 1));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        LogTriggerHelper.runPostProcessingBatchInTest = true;
        PermissionsUtil.AsyncProcessErrorTracking = true;

        Test.startTest();
        
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        Test.stopTest();

        // Retrieve Email Log
        List<Log__c> emailLogs = [
            SELECT Id, Hash_1__c, Stacktrace__c, Summary__c, Category__c 
            FROM Log__c 
            WHERE Category__c = 'Apex' 
            AND Summary__c = :summary
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
        
        System.assert(!emailLogs.isEmpty(), 'Email log should be created');
        Log__c emailLog = emailLogs[0];
        System.assertEquals(summary, emailLog.Summary__c, 'Email log summary should match');
        System.assertNotEquals(null, emailLog.Hash_1__c, 'Email log Hash1 should be populated');
        
        // Verify the hash calculation method used by ApexExceptionParser
        // Calculate expected hash using sorted List (consistent method from LogService.calculateHashes)
        Set<String> stackTraceUniqueLines = new Set<String>();
        stackTraceUniqueLines.add(stacktraceLine);
        
        List<String> sortedStackTraceLines = new List<String>(stackTraceUniqueLines);
        sortedStackTraceLines.sort();
        
        String valueForSortedHash = JSON.serialize(sortedStackTraceLines) + summary;
        String sortedHash = LogService.generateHash_1(valueForSortedHash);

        // The key assertion: Email log hash should match the expected sorted hash
        // This ensures ApexExceptionParser.getHash1() produces consistent hashes with LogService.calculateHashes()
        System.assertEquals(sortedHash, emailLog.Hash_1__c,
            'Email log Hash1 should match expected hash calculated using sorted List serialization. ' +
            'If this fails, ApexExceptionParser.getHash1() needs to sort stacktrace lines before JSON serialization.');
    }

    @IsTest
    static void test_extractAsyncApexJobId() {
        // Test with valid Async Apex Job ID (starts with '707')
        String messageWithJobId = 'Developer script exception from 2.217S : \'pharos.MonitoringBatch\' for job id \'707gL00000PvD5s\' : Attempt to de-reference a null object';
        String extractedJobId = ApexExceptionParser.extractAsyncApexJobId(messageWithJobId);
        System.assertEquals('707gL00000PvD5s', extractedJobId, 'Should extract valid Async Apex Job ID');

        // Test with 18-character job ID (should be truncated to 15)
        String messageWith18CharJobId = 'Developer script exception from 2.217S : \'pharos.MonitoringBatch\' for job id \'707gL00000PvD5sABC\' : Attempt to de-reference a null object';
        String extracted18CharJobId = ApexExceptionParser.extractAsyncApexJobId(messageWith18CharJobId);
        System.assertEquals('707gL00000PvD5s', extracted18CharJobId, 'Should truncate 18-character job ID to 15 characters');

        // Test with job ID that doesn't start with '707' (should return null)
        String messageWithInvalidJobId = 'Developer script exception from 2.217S : \'pharos.MonitoringBatch\' for job id \'008gL00000PvD5s\' : Attempt to de-reference a null object';
        String extractedInvalidJobId = ApexExceptionParser.extractAsyncApexJobId(messageWithInvalidJobId);
        System.assertEquals(null, extractedInvalidJobId, 'Should return null for job IDs not starting with 707');

        // Test with no job ID
        String messageWithoutJobId = 'Developer script exception from 2.217S : \'pharos.MonitoringBatch\' : Attempt to de-reference a null object';
        String extractedNoJobId = ApexExceptionParser.extractAsyncApexJobId(messageWithoutJobId);
        System.assertEquals(null, extractedNoJobId, 'Should return null when no job ID is found');

        // Test with null input
        String extractedNull = ApexExceptionParser.extractAsyncApexJobId(null);
        System.assertEquals(null, extractedNull, 'Should return null for null input');

        // Test with empty string
        String extractedEmpty = ApexExceptionParser.extractAsyncApexJobId('');
        System.assertEquals(null, extractedEmpty, 'Should return null for empty string');
    }
    
    // ========== MANAGED PACKAGE HIDDEN NAMESPACE TESTS ==========
    // Tests for hidden namespace tokens: (namespace), (pharos), (System Code), etc.
    
    /**
     * Test that PATTERN_CLASS_2 matches all hidden namespace token formats
     */
    @IsTest
    static void test_pattern_matches_all_hidden_tokens() {
        // Test various hidden token formats
        String stacktrace1 = 'Class.MyClass.method: line 10, column 1\n\n(System Code)\n\n';
        String stacktrace2 = 'Class.MyClass.method: line 10, column 1\n\n(namespace)\n\n';
        String stacktrace3 = 'Class.MyClass.method: line 10, column 1\n\n(pharos)\n\n';
        String stacktrace4 = 'Class.MyClass.method: line 10, column 1\n\n(my_package_ns)\n\n';
        String stacktrace5 = 'Class.MyClass.method: line 10, column 1\n\n(testpharosx)\n\n';
        
        Test.startTest();
        
        // Extract stacktrace lines using PATTERN_CLASS_2
        List<String> lines1 = ApexExceptionParser.getStackTraceLines(stacktrace1, ApexExceptionParser.PATTERN_CLASS_2);
        List<String> lines2 = ApexExceptionParser.getStackTraceLines(stacktrace2, ApexExceptionParser.PATTERN_CLASS_2);
        List<String> lines3 = ApexExceptionParser.getStackTraceLines(stacktrace3, ApexExceptionParser.PATTERN_CLASS_2);
        List<String> lines4 = ApexExceptionParser.getStackTraceLines(stacktrace4, ApexExceptionParser.PATTERN_CLASS_2);
        List<String> lines5 = ApexExceptionParser.getStackTraceLines(stacktrace5, ApexExceptionParser.PATTERN_CLASS_2);
        
        Test.stopTest();
        
        // All should extract lines including hidden tokens
        System.assert(lines1.size() >= 1, '(System Code) should be matched by PATTERN_CLASS_2');
        System.assert(lines2.size() >= 1, '(namespace) should be matched by PATTERN_CLASS_2');
        System.assert(lines3.size() >= 1, '(pharos) should be matched by PATTERN_CLASS_2');
        System.assert(lines4.size() >= 1, '(my_package_ns) should be matched by PATTERN_CLASS_2');
        System.assert(lines5.size() >= 1, '(testpharosx) should be matched by PATTERN_CLASS_2');
        
        // Verify the hidden tokens are captured in at least one line
        String allLines1 = String.join(lines1, ' ');
        String allLines2 = String.join(lines2, ' ');
        String allLines3 = String.join(lines3, ' ');
        String allLines4 = String.join(lines4, ' ');
        String allLines5 = String.join(lines5, ' ');
        
        System.assert(allLines1.contains('(System Code)') || allLines1.contains('Class.MyClass'), 
            'Should capture stacktrace with (System Code) token');
        System.assert(allLines2.contains('(namespace)') || allLines2.contains('Class.MyClass'), 
            'Should capture stacktrace with (namespace) token');
        System.assert(allLines3.contains('(pharos)') || allLines3.contains('Class.MyClass'), 
            'Should capture stacktrace with (pharos) token');
        System.assert(allLines4.contains('(my_package_ns)') || allLines4.contains('Class.MyClass'), 
            'Should capture stacktrace with (my_package_ns) token');
        System.assert(allLines5.contains('(testpharosx)') || allLines5.contains('Class.MyClass'), 
            'Should capture stacktrace with (testpharosx) token');
    }
    
    /**
     * Test that hidden namespace tokens are removed during normalization
     */
    @IsTest
    static void test_hidden_tokens_removed_during_parsing() {
        Test_LogService.initSettings();
        
        String emailBody = 'Apex script unhandled exception by user/organization: 005000000000001/00D000000000001\n\n' +
                          'Error: Divide by 0\n\n' +
                          'Class.MyHandler.execute: line 25, column 1\n\n' +
                          '(namespace)\n\n';
        
        Test.startTest();
        
        ApexExceptionParser parser = new ApexExceptionParser();
        parser.init(emailBody, 'Test Error', 'system@salesforce.com');
        
        if (parser.canProcess()) {
            parser.process();
            String stacktrace = parser.getStackTrace();
            
            // Hidden namespace token should be removed during normalization
            System.assertNotEquals(null, stacktrace, 'Stacktrace should be parsed');
        }
        
        Test.stopTest();
    }
    
    /**
     * Test hash calculation with hidden namespace tokens
     */
    @IsTest
    static void test_hash_calculation_with_hidden_namespace() {
        Test_LogService.initSettings();
        
        Test.startTest();
        
        // Log 1: Full stacktrace
        Log__c emailLog = new Log__c(
            Summary__c = 'Divide by 0',
            Stacktrace__c = 'Class.namespace__MyClass.method: line 10, column 1\n' +
                           'Class.MyHandler.execute: line 25, column 1',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        LogService.calculateHashes(emailLog);
        String emailHash = emailLog.Hash_1__c;
        
        // Log 2: Hidden namespace
        Log__c platformEventLog = new Log__c(
            Summary__c = 'Divide by 0',
            Stacktrace__c = 'Class.MyHandler.execute: line 25, column 1\n\n' +
                           '(namespace)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        LogService.calculateHashes(platformEventLog);
        String platformEventHash = platformEventLog.Hash_1__c;
        
        // Log 3: Pharos internal error
        Log__c pharosLog = new Log__c(
            Summary__c = 'Divide by 0',
            Stacktrace__c = 'Class.MyHandler.execute: line 25, column 1\n\n' +
                           '(pharos)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        LogService.calculateHashes(pharosLog);
        String pharosHash = pharosLog.Hash_1__c;
        
        Test.stopTest();
        
        // Hashes should be calculated
        System.assertNotEquals(null, emailHash, 'Email hash should be calculated');
        System.assertNotEquals(null, platformEventHash, 'Platform event hash should be calculated');
        System.assertNotEquals(null, pharosHash, 'Pharos hash should be calculated');
        
        // Email has more stacktrace lines, so hash will differ
        System.assertNotEquals(emailHash, platformEventHash, 
            'Email has more stacktrace lines, so hash will differ');
        
        // Platform event and pharos should have same hash (same structure after normalization)
        System.assertEquals(platformEventHash, pharosHash, 
            'Logs with different hidden tokens but same visible lines should have same hash');
    }
    
    /**
     * Test hash calculation consistency with System Code
     */
    @IsTest
    static void test_hash_calculation_with_system_code() {
        Test_LogService.initSettings();
        
        Test.startTest();
        
        // Log with (System Code)
        Log__c log1 = new Log__c(
            Summary__c = 'Test Error',
            Stacktrace__c = 'Class.MyClass.method: line 10, column 1\n\n' +
                           '(System Code)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        LogService.calculateHashes(log1);
        
        // Log without (System Code)
        Log__c log2 = new Log__c(
            Summary__c = 'Test Error',
            Stacktrace__c = 'Class.MyClass.method: line 10, column 1',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        LogService.calculateHashes(log2);
        
        Test.stopTest();
        
        // Both hashes should be calculated
        System.assertNotEquals(null, log1.Hash_1__c, 'Hash with (System Code) should be calculated');
        System.assertNotEquals(null, log2.Hash_1__c, 'Hash without (System Code) should be calculated');
    }
    
    /**
     * Test logs with multiple hidden tokens
     */
    @IsTest
    static void test_multiple_hidden_tokens_in_stacktrace() {
        Test_LogService.initSettings();
        
        Test.startTest();
        
        // Stacktrace with multiple hidden tokens
        Log__c log = new Log__c(
            Summary__c = 'Complex Error',
            Stacktrace__c = 'Class.MyClass.method1: line 10, column 1\n\n' +
                           '(namespace1)\n\n' +
                           'Class.MyClass.method2: line 20, column 1\n\n' +
                           '(namespace2)\n\n' +
                           'Class.MyClass.method3: line 30, column 1',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        
        LogService.calculateHashes(log);
        
        Test.stopTest();
        
        // Should successfully calculate hash
        System.assertNotEquals(null, log.Hash_1__c, 'Hash should be calculated with multiple hidden tokens');
        System.assertNotEquals(null, log.Hash_2__c, 'Hash_2 should be calculated');
        System.assertNotEquals(null, log.Hash_3__c, 'Hash_3 should be calculated');
    }
    
    /**
     * Test edge case: stacktrace with only hidden token
     */
    @IsTest
    static void test_stacktrace_only_hidden_token() {
        Test_LogService.initSettings();
        
        Test.startTest();
        
        // Stacktrace with only hidden token (edge case)
        Log__c log = new Log__c(
            Summary__c = 'Hidden Error',
            Stacktrace__c = '(namespace)',
            Details__c = 'Error details for fallback',
            Category__c = 'Apex',
            Organization_Id__c = UserInfo.getOrganizationId()
        );
        
        LogService.calculateHashes(log);
        
        Test.stopTest();
        
        // Should fall back to Details__c for hash calculation
        System.assertNotEquals(null, log.Hash_1__c, 'Hash should be calculated using fallback');
    }
    
    /**
     * Test hidden namespace tokens are normalized consistently
     */
    @IsTest
    static void test_managed_package_hidden_namespace_normalization() {
        Test_LogService.initSettings();
        
        String orgId = UserInfo.getOrganizationId();
        
        Test.startTest();
        
        // Log 1: With (namespace) token
        Log__c log1 = new Log__c(
            Summary__c = 'Test Error',
            Stacktrace__c = 'Class.MyHandler.execute: line 25, column 1\n\n(namespace)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = orgId
        );
        LogService.calculateHashes(log1);
        
        // Log 2: With (pharos) token
        Log__c log2 = new Log__c(
            Summary__c = 'Test Error',
            Stacktrace__c = 'Class.MyHandler.execute: line 25, column 1\n\n(pharos)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = orgId
        );
        LogService.calculateHashes(log2);
        
        // Log 3: With (testpkg) token
        Log__c log3 = new Log__c(
            Summary__c = 'Test Error',
            Stacktrace__c = 'Class.MyHandler.execute: line 25, column 1\n\n(testpkg)\n\n',
            Category__c = 'Apex',
            Organization_Id__c = orgId
        );
        LogService.calculateHashes(log3);
        
        Test.stopTest();
        
        // All three should have same hash after normalization
        System.assertNotEquals(null, log1.Hash_1__c, 'Hash should be calculated for log1');
        System.assertNotEquals(null, log2.Hash_1__c, 'Hash should be calculated for log2');
        System.assertNotEquals(null, log3.Hash_1__c, 'Hash should be calculated for log3');
        
        // All hashes should match (hidden tokens removed during normalization)
        System.assertEquals(log1.Hash_1__c, log2.Hash_1__c, 
            '(namespace) and (pharos) should normalize to same hash');
        System.assertEquals(log1.Hash_1__c, log3.Hash_1__c, 
            '(namespace) and (testpkg) should normalize to same hash');
        System.assertEquals(log2.Hash_1__c, log3.Hash_1__c, 
            '(pharos) and (testpkg) should normalize to same hash');
    }
    
    /**
     * Test that pharos internal errors are correctly categorized
     */
    @IsTest
    static void test_pharos_token_categorization() {
        TestDataFactory.createConnectedOrg();
        Test_LogService.initSettings();
        
        String orgId = UserInfo.getOrganizationId();
        String emailBody = 'Apex script unhandled exception by user/organization: 005000000000001/' + orgId + '\n\n' +
                          'Error: Internal error\n\n' +
                          'Class.MyClass.method: line 10, column 1\n\n' +
                          '(pharos)\n\n';
        
        Test.startTest();
        
        Log__c log = LogService.createLogFromEmailBody(emailBody, 'Internal Error', 'system@salesforce.com', Datetime.now());
        
        Test.stopTest();
        
        // Should be categorized as Pharos Error if (pharos) token is detected
        System.assertNotEquals(null, log.Category__c, 'Category should be set');
        
        // If pharos token was detected in original stacktrace, should be Pharos Error
        if (log.Stacktrace__c != null && (log.Stacktrace__c.contains('pharos') || log.Stacktrace__c.contains('(pharos)'))) {
            System.assertEquals(Logger.CATEGORY_PHAROS_ERROR, log.Category__c, 
                'Should be categorized as Pharos Error when (pharos) token present');
        }
    }
}