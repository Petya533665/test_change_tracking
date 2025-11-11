@IsTest
public with sharing class FlowRestServiceTest {

    @TestSetup
    static void setupTestData() {
        TestDataFactory.createConnectedOrg();
    }

    @IsTest
    static void test_doGet_withFlowType() {
        Test.setMock(WebServiceMock.class, new MockMetadataService());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/flowservice/';
        req.httpMethod = 'GET';
        req.addParameter('flow', 'TestFlow');
        req.addParameter('type', 'flow');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FlowRestService.doGet();
        Test.stopTest();

        Assert.areNotEqual(null, res.responseBody, 'Response body should not be null');
        Assert.areNotEqual(null, res.statusCode, 'Status code should not be null');
    }

    @IsTest
    static void test_doGet_withProcessBuilderType() {
        Test.setMock(WebServiceMock.class, new MockMetadataService());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/flowservice/';
        req.httpMethod = 'GET';
        req.addParameter('flow', 'TestProcessBuilder');
        req.addParameter('type', 'pb');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FlowRestService.doGet();
        Test.stopTest();

        Assert.areNotEqual(null, res.responseBody, 'Response body should not be null');
        Assert.areNotEqual(null, res.statusCode, 'Status code should not be null');
    }

    @IsTest
    static void test_doGet_withoutParameters() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/flowservice/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FlowRestService.doGet();
        Test.stopTest();

        Assert.areNotEqual(null, res.responseBody, 'Response body should not be null');
        Assert.areNotEqual(null, res.statusCode, 'Status code should not be null');
    }

    @IsTest
    static void test_doGet_withNullRequest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/flowservice/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FlowRestService.doGet();
        Test.stopTest();

        Assert.areNotEqual(null, res.responseBody, 'Response body should not be null');
        Assert.areNotEqual(null, res.statusCode, 'Status code should not be null');
    }

    @IsTest
    static void test_getFlowMetadataResult_constructor() {
        Test.setMock(WebServiceMock.class, new MockMetadataService());
        Map<String, String> params = new Map<String, String>{
            'flow' => 'TestFlow',
            'type' => 'flow'
        };

        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult(params);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areNotEqual(null, result.status, 'Status should not be null');
        Assert.areNotEqual(null, result.statusCode, 'Status code should not be null');
    }

    @IsTest
    static void test_getFlowMetadataResult_emptyConstructor() {
        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult();
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Result should not be null');
    }

    @IsTest
    static void test_getFlowMetadataResult_withEmptyParams() {
        Map<String, String> params = new Map<String, String>();

        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult(params);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areNotEqual(null, result.status, 'Status should not be null');
    }

    @IsTest
    static void test_getFlowMetadataResult_withNullFlowParam() {
        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult(null);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areNotEqual(null, result.status, 'Status should not be null');
    }

    @IsTest
    static void test_getFlowMetadataResult_withFlowTypeFlow() {
        Test.setMock(WebServiceMock.class, new MockMetadataService());

        Map<String, String> params = new Map<String, String>{
            'flow' => 'TestFlow-1',
            'type' => 'flow'
        };

        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult(params);
        Test.stopTest();

        Assert.areEqual('TestFlow-1', result.flowFullName, 'Flow full name should match');
        Assert.areEqual('flow', result.flowType, 'Flow type should be flow');
    }

    @IsTest
    static void test_getFlowMetadataResult_withFlowTypeProcessBuilder() {
        Test.setMock(WebServiceMock.class, new MockMetadataService());

        Map<String, String> params = new Map<String, String>{
            'flow' => 'TestPB-1',
            'type' => 'pb'
        };

        Test.startTest();
        FlowRestService.GetFlowMetadataResult result = new FlowRestService.GetFlowMetadataResult(params);
        Test.stopTest();

        Assert.areEqual('TestPB-1', result.flowFullName, 'Flow full name should match');
        Assert.areEqual('pb', result.flowType, 'Flow type should be pb');
    }

    @IsTest
    static void test_constants() {
        Assert.areEqual('flow', FlowRestService.FLOW_API_NAME_PARAMS, 'FLOW_API_NAME_PARAMS should be flow');
        Assert.areEqual('type', FlowRestService.FLOW_TYPE_PARAMS, 'FLOW_TYPE_PARAMS should be type');
        Assert.areEqual('flow api name parameter is invalid', FlowRestService.FLOW_API_NAME_BAD_VALUE);
        Assert.areEqual('flow type parameter is invalid', FlowRestService.FLOW_TYPE_BAD_VALUE);
        Assert.areEqual(200, FlowRestService.STATUS_CODE_SUCCESS, 'STATUS_CODE_SUCCESS should be 200');
        Assert.areEqual(500, FlowRestService.STATUS_CODE_INTERNAL_ERROR, 'STATUS_CODE_INTERNAL_ERROR should be 500');
        Assert.areEqual(400, FlowRestService.STATUS_CODE_BAD_REQUEST, 'STATUS_CODE_BAD_REQUEST should be 400');
        Assert.areEqual('success', FlowRestService.STATUS_SUCCESS, 'STATUS_SUCCESS should be success');
        Assert.areEqual('fail', FlowRestService.STATUS_FAIL, 'STATUS_FAIL should be fail');
        Assert.areEqual('flow', FlowRestService.FLOW_TYPE_FLOW, 'FLOW_TYPE_FLOW should be flow');
        Assert.areEqual('pb', FlowRestService.FLOW_TYPE_PROCESS_BUILDER, 'FLOW_TYPE_PROCESS_BUILDER should be pb');
    }

    @IsTest
    static void test_flowRestServiceException() {
        Test.startTest();
        FlowRestService.FlowRestServiceException ex = new FlowRestService.FlowRestServiceException('Test exception');
        Test.stopTest();

        Assert.areNotEqual(null, ex, 'Exception should not be null');
        Assert.areEqual('Test exception', ex.getMessage(), 'Exception message should match');
    }

    // Mock WebService for SOAP callouts (MetadataService.MetadataPort)
    public class MockMetadataService implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            // Create mock readMetadata response
            MetadataService.Flow mockFlow = new MetadataService.Flow();
            mockFlow.fullName = 'TestFlow';
            mockFlow.label = 'Test Flow Label';
            mockFlow.processType = 'Workflow';
            mockFlow.status = 'Active';
            
            MetadataService.ReadFlowResult readResult = new MetadataService.ReadFlowResult();
            readResult.records = new MetadataService.Flow[] { mockFlow };
            
            MetadataService.readFlowResponse_element responseElement = new MetadataService.readFlowResponse_element();
            responseElement.result = readResult;
            
            response.put('response_x', responseElement);
        }
    }
}