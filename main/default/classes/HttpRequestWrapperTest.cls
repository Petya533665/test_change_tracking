@IsTest
public with sharing class HttpRequestWrapperTest {
    
    @IsTest
    static void test_constructor_withHttpRequest() {
        Test.startTest();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com/api');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"test": "data"}');
        request.setCompressed(true);
        
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        Test.stopTest();
        
        Assert.areNotEqual(null, wrapper, 'Wrapper should be created');
        Assert.areEqual(request, wrapper.getRequest(), 'Request should match');
    }
    
    @IsTest
    static void test_constructor_withRestRequest() {
        Test.startTest();
        RestRequest restRequest = new RestRequest();
        restRequest.resourcePath = '/api/test';
        restRequest.httpMethod = 'GET';
        // Note: RestRequest.headers is final and cannot be set directly
        restRequest.requestBody = Blob.valueOf('{"test": "data"}');
        
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        Test.stopTest();
        
        Assert.areNotEqual(null, wrapper, 'Wrapper should be created');
        Assert.areEqual('GET', wrapper.getMethod(), 'Method should match');
    }
    
    @IsTest
    static void test_constructor_withHttpRequestAndHeaderKeys() {
        Test.startTest();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com/api');
        request.setMethod('POST');
        request.setHeader('Custom-Header', 'custom-value');
        request.setHeader('Content-Type', 'application/json');
        
        Set<String> customHeaderKeys = new Set<String>{'Custom-Header'};
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request, customHeaderKeys);
        Test.stopTest();
        
        Assert.areNotEqual(null, wrapper, 'Wrapper should be created');
        Map<String, String> headers = wrapper.getHeaders();
        Assert.isTrue(headers.containsKey('Custom-Header'), 'Should contain custom header');
        Assert.areEqual('custom-value', headers.get('Custom-Header'), 'Custom header value should match');
    }
    
    @IsTest
    static void test_getRequest() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com/api');
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        HttpRequest result = wrapper.getRequest();
        Test.stopTest();
        
        Assert.areEqual(request, result, 'Should return the same request object');
    }
    
    @IsTest
    static void test_getEndpoint_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com/api');
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        String endpoint = wrapper.getEndpoint();
        Test.stopTest();
        
        Assert.areEqual('https://test.com/api', endpoint, 'Endpoint should match');
    }
    
    @IsTest
    static void test_getEndpoint_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        restRequest.resourcePath = '/api/test';
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        String endpoint = wrapper.getEndpoint();
        Test.stopTest();
        
        Assert.isTrue(endpoint.contains('/api/test'), 'Endpoint should contain resource path');
    }
    
    @IsTest
    static void test_getMethod_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        String method = wrapper.getMethod();
        Test.stopTest();
        
        Assert.areEqual('POST', method, 'Method should match');
    }
    
    @IsTest
    static void test_getMethod_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        restRequest.httpMethod = 'PUT';
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        String method = wrapper.getMethod();
        Test.stopTest();
        
        Assert.areEqual('PUT', method, 'Method should match');
    }
    
    @IsTest
    static void test_getHeaders_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer token123');
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        Map<String, String> headers = wrapper.getHeaders();
        Test.stopTest();
        
        Assert.areNotEqual(null, headers, 'Headers should not be null');
        Assert.isTrue(headers.containsKey('Content-Type'), 'Should contain Content-Type header');
        Assert.isTrue(headers.containsKey('Accept'), 'Should contain Accept header');
        Assert.isTrue(headers.containsKey('Authorization'), 'Should contain Authorization header');
        Assert.areEqual('application/json', headers.get('Content-Type'), 'Content-Type value should match');
        Assert.areEqual('application/json', headers.get('Accept'), 'Accept value should match');
        Assert.areEqual('Bearer token123', headers.get('Authorization'), 'Authorization value should match');
    }
    
    @IsTest
    static void test_getHeaders_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        // Note: RestRequest.headers is final and cannot be set directly
        // We'll test with empty headers since we can't populate them
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        Map<String, String> headers = wrapper.getHeaders();
        Test.stopTest();
        
        Assert.areNotEqual(null, headers, 'Headers should not be null');
        // Since we can't set headers on RestRequest, we expect empty headers
        Assert.areEqual(0, headers.size(), 'Headers should be empty for RestRequest');
    }
    
    @IsTest
    static void test_getHeaders_withEmptyHeaders() {
        HttpRequest request = new HttpRequest();
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        Map<String, String> headers = wrapper.getHeaders();
        Test.stopTest();
        
        Assert.areNotEqual(null, headers, 'Headers should not be null');
        Assert.areEqual(0, headers.size(), 'Headers should be empty');
    }
    
    @IsTest
    static void test_getBody_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        String body = '{"test": "data", "number": 123}';
        request.setBody(body);
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(body, result, 'Body should match');
    }
    
    @IsTest
    static void test_getBody_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        String body = '{"test": "data"}';
        restRequest.requestBody = Blob.valueOf(body);
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(body, result, 'Body should match');
    }
    
    @IsTest
    static void test_getBody_withNullRestRequestBody() {
        RestRequest restRequest = new RestRequest();
        restRequest.requestBody = null;
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(null, result, 'Body should be null');
    }
    
    @IsTest
    static void test_getCompressed_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setCompressed(true);
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        Boolean compressed = wrapper.getCompressed();
        Test.stopTest();
        
        Assert.isTrue(compressed, 'Compressed should be true');
    }
    
    @IsTest
    static void test_getCompressed_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        Boolean compressed = wrapper.getCompressed();
        Test.stopTest();
        
        Assert.isFalse(compressed, 'Compressed should be false for RestRequest');
    }
    
    @IsTest
    static void test_formatRequest_withHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.com/api');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"test": "data"}');
        request.setCompressed(true);
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(request);
        Map<String, Object> formatted = wrapper.formatRequest();
        Test.stopTest();
        
        Assert.areNotEqual(null, formatted, 'Formatted request should not be null');
        Assert.areEqual('https://test.com/api', formatted.get('endpoint'), 'Endpoint should match');
        Assert.areEqual('POST', formatted.get('method'), 'Method should match');
        Assert.areNotEqual(null, formatted.get('headers'), 'Headers should not be null');
        Assert.areEqual('{"test": "data"}', formatted.get('body'), 'Body should match');
        Assert.isTrue((Boolean)formatted.get('compressed'), 'Compressed should be true');
    }
    
    @IsTest
    static void test_formatRequest_withRestRequest() {
        RestRequest restRequest = new RestRequest();
        restRequest.resourcePath = '/api/test';
        restRequest.httpMethod = 'GET';
        // Note: RestRequest.headers is final and cannot be set directly
        restRequest.requestBody = Blob.valueOf('{"test": "data"}');
        
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper(restRequest);
        Map<String, Object> formatted = wrapper.formatRequest();
        Test.stopTest();
        
        Assert.areNotEqual(null, formatted, 'Formatted request should not be null');
        Assert.isTrue(String.valueOf(formatted.get('endpoint')).contains('/api/test'), 'Endpoint should contain resource path');
        Assert.areEqual('GET', formatted.get('method'), 'Method should match');
        Assert.areNotEqual(null, formatted.get('headers'), 'Headers should not be null');
        Assert.areEqual('{"test": "data"}', formatted.get('body'), 'Body should match');
        Assert.isFalse((Boolean)formatted.get('compressed'), 'Compressed should be false');
    }
    
    @IsTest
    static void test_formatRequest_withNullRequests() {
        Test.startTest();
        HttpRequestWrapper wrapper = new HttpRequestWrapper((HttpRequest)null);
        Map<String, Object> formatted = wrapper.formatRequest();
        Test.stopTest();
        
        Assert.areEqual(null, formatted, 'Formatted request should be null when both requests are null');
    }
}