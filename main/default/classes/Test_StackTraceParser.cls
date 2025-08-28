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
            Set<FlowService.FlowEdge> flowEdges = (Set<FlowService.FlowEdge>)JSON.deserialize(JSON.serialize(edgeObj), Set<FlowService.FlowEdge>.class);
            for(FlowService.FlowEdge flowEdge : flowEdges) {
                System.assertNotEquals(null, flowEdge);
                System.assertNotEquals(null, flowEdge.target);
            }
            if (edgeName == 'More') {
                System.assertEquals(2, flowEdges.size());
                for (FlowService.FlowEdge flowEdge : flowEdges) {
                    // goto route
                    if (flowEdge.target == 'Account_Selection_Scree') {
                        System.assertEquals(true, flowEdge.indexes.contains(7));
                    }
                    // create opp route
                    if (flowEdge.target == 'Createopp') {
                        System.assertEquals(true, flowEdge.indexes.contains(12));
                    }
                }
            }
        }
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
        FlowService.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);
        System.assertEquals(true, flow.elements.containsKey('Create_Opp'));
        System.assertEquals(true, flow.elements.containsKey('Testeeet'));
        Test.stopTest();

        Map<String, FlowService.FlowElement> elements = flow.elements;
        FlowService.FlowElement createOppElement = flow.elements.get('Create_Opp');
        System.assertNotEquals(null, createOppElement);
        System.assertEquals(true, createOppElement.executed);

        FlowService.FlowElement testeeetElement = flow.elements.get('Testeeet');
        System.assertNotEquals(null, testeeetElement);
        System.assertEquals(true, testeeetElement.executed);

        Map<String, Set<FlowService.FlowEdge>> edges = flow.edges;
        System.assertNotEquals(null, edges);
        System.assertEquals(true, edges.containsKey('Create_Opp'));

        Set<FlowService.FlowEdge> createOppEdges = edges.get('Create_Opp');
        System.assertNotEquals(null, createOppEdges);
        System.assertEquals(true, createOppEdges.size() == 1);
        FlowService.FlowEdge createOppEdge = createOppEdges.iterator().next();
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
        FlowService.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);
        System.assertEquals(true, flow.elements.containsKey('Get_Account'));
        Test.stopTest();

        Map<String, FlowService.FlowElement> elements = flow.elements;
        FlowService.FlowElement getAccountElement = flow.elements.get('Get_Account');
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
        FlowService.Flow flow = FlowService.parseFlowStackTrace(stacktrace);
        System.assertNotEquals(null, flow);
        System.assertNotEquals(null, flow.elements);
        System.assertNotEquals(null, flow.edges);

        Map<String, FlowService.FlowElement> elements = flow.elements;
        FlowService.FlowElement waitDecision = elements.get('wait11');
        System.assertNotEquals(null, waitDecision);
        System.assertEquals(true, waitDecision.executed);
        Map<String, Object> metadataInfoWaitDecision = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(waitDecision.metadataInfo));
        System.assertEquals(true, metadataInfoWaitDecision.containsKey('elementSubtype'));
        System.assertEquals(true, metadataInfoWaitDecision.containsKey('events'));

        FlowService.FlowElement waitDuration = elements.get('wait22');
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

        FlowService.FlowElement waitDate = elements.get('wait33');
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        
        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        System.assertNotEquals(null, abbreviatedTestStub.abbreviatedStacktrace);
        System.assertEquals(true, testStub.length() > abbreviatedTestStub.abbreviatedStacktrace.length());

        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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
            FlowService.Flow flow = FlowService.parseFlowStackTrace(Test_LogService.getTestStub('flow_AllActions_StackTrace'));
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
        System.assertEquals(FlowService.PB_LABEL_OBJECT, processBuilder.start.sections.get(0).label);
        

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
        FlowService.Flow orchestratorFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
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
        FlowService.Flow orchestratorFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
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
        FlowService.Flow testedFlow = FlowService.parseFlowStackTrace(testStubStacktrace);
        System.assertNotEquals(null, testedFlow);
        System.assertNotEquals(null, testedFlow.elements);
        System.assertNotEquals(null, testedFlow.edges);
        for(FlowService.FlowElement stElement : testedFlow.elements.values()) {
            System.assertEquals(true, stElement.executed);
        }
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
        FlowService.FlowErrorAbbreviateResult abbreviatedHtmlBody = sp.abbreviateStacktraceErrorMessages();
        Log__c log = LogService.createLogFromEmailBody(testStubStacktrace, 'An error occurred with your "GovnopaketFlowContact1" flow', 'test@test.com', Datetime.now());
        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(LogService.class.getName(), '.', null);
        Test.stopTest();

        log = [SELECT Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        system.assertEquals('testgovnopaket1__GovnopaketFlowContact1', log.Flow_API_Name__c);
        system.assertEquals('1', log.Flow_Version__c);
        system.assertEquals('Flow', log.Area__c);
        system.assertEquals('Autolaunched Flow', log.Type__c);
        system.assertNotEquals(null, log.Hash_1__c);
        system.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
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
        
        FlowService.FlowStacktraceInfo stackTraceInfo = sp.parse();
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

        log = [SELECT Salesforce_Error_Id__c, Flow_API_Name__c, Flow_Version__c, Area__c, Type__c , Hash_1__c, Stacktrace_Parse_Result__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        system.assertEquals('IO_Line_Item_Clone_Flow', log.Flow_API_Name__c);
        system.assertEquals('3', log.Flow_Version__c);
        system.assertEquals('Flow', log.Area__c);
        system.assertEquals('Autolaunched Flow', log.Type__c);
        system.assertNotEquals(null, log.Hash_1__c);
        system.assertNotEquals(null, log.Stacktrace_Parse_Result__c);
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
        FlowService.FlowErrorAbbreviateResult abbreviatedTestStub = sp.abbreviateStacktraceErrorMessages();
        FlowService.FlowStacktraceParser sp2 = new FlowService.FlowStacktraceParser(abbreviatedTestStub.abbreviatedStacktrace);
        FlowService.FlowStacktraceInfo stackTraceInfo = sp2.parse();

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
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getPendingJobsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        String query = new QBuilder(AsyncApexJob.SObjectType)
            .selectFields(LogPostProcessingService.ASYNC_JOB_FIELDS)
            .add(QBuilder.condition('Status').isIn(new String[] {'Processing','Preparing','Queued'}))
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

    private static Map<String, HttpCalloutMock> getUserNameMock() {
        String userId = '0056g000003aA4M';
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(User.SObjectType)
            .selectFields(LogPostProcessingService.USER_FIELDS)
            .add(QBuilder.condition('Id').equalsTo(userId))
            .addLimit(1)
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
}