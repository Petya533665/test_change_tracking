@IsTest
public with sharing class HttpResponseWrapperTest {
    
    @IsTest
    static void test_constructor_withHttpResponse() {
        Test.startTest();
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"test": "data"}');
        
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        Test.stopTest();
        
        Assert.areNotEqual(null, wrapper, 'Wrapper should be created');
        Assert.areEqual(response, wrapper.getResponse(), 'Response should match');
    }
    
    @IsTest
    static void test_constructor_withRestResponse() {
        Test.startTest();
        RestResponse restResponse = new RestResponse();
        restResponse.statuscode = 201;
        // Note: RestResponse.headers is not accessible in tests
        restResponse.responseBody = Blob.valueOf('{"test": "data"}');
        
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        Test.stopTest();
        
        Assert.areNotEqual(null, wrapper, 'Wrapper should be created');
        Assert.areEqual(201, wrapper.getStatusCode(), 'StatusCode should match');
    }
    
    @IsTest
    static void test_getResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        HttpResponse result = wrapper.getResponse();
        Test.stopTest();
        
        Assert.areEqual(response, result, 'Should return the same response object');
    }
    
    @IsTest
    static void test_getHeaderKeys_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept', 'application/json');
        response.setHeader('Authorization', 'Bearer token123');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        List<String> headerKeys = wrapper.getHeaderKeys();
        Test.stopTest();
        
        Assert.areNotEqual(null, headerKeys, 'Header keys should not be null');
        Assert.isTrue(headerKeys.contains('Content-Type'), 'Should contain Content-Type header key');
        Assert.isTrue(headerKeys.contains('Accept'), 'Should contain Accept header key');
        Assert.isTrue(headerKeys.contains('Authorization'), 'Should contain Authorization header key');
    }
    
    @IsTest
    static void test_getHeaderKeys_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        // Note: RestResponse.headers is not accessible in tests
        // We'll test with empty headers since we can't populate them
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        List<String> headerKeys = wrapper.getHeaderKeys();
        Test.stopTest();
        
        Assert.areNotEqual(null, headerKeys, 'Header keys should not be null');
        // Since we can't set headers on RestResponse, we expect empty header keys
        Assert.areEqual(0, headerKeys.size(), 'Header keys should be empty for RestResponse');
    }
    
    @IsTest
    static void test_getHeader_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept', 'application/json');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        String contentType = wrapper.getHeader('Content-Type');
        String accept = wrapper.getHeader('Accept');
        String missing = wrapper.getHeader('Missing-Header');
        Test.stopTest();
        
        Assert.areEqual('application/json', contentType, 'Content-Type header should match');
        Assert.areEqual('application/json', accept, 'Accept header should match');
        Assert.areEqual(null, missing, 'Missing header should be null');
    }
    
    @IsTest
    static void test_getHeader_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        // Note: RestResponse.headers is not accessible in tests
        // We'll test with empty headers since we can't populate them
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        String contentType = wrapper.getHeader('Content-Type');
        String accept = wrapper.getHeader('Accept');
        String missing = wrapper.getHeader('Missing-Header');
        Test.stopTest();
        
        // Since we can't set headers on RestResponse, all should be null
        Assert.areEqual(null, contentType, 'Content-Type header should be null for RestResponse');
        Assert.areEqual(null, accept, 'Accept header should be null for RestResponse');
        Assert.areEqual(null, missing, 'Missing header should be null');
    }
    
    @IsTest
    static void test_getHeaders_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept', 'application/json');
        response.setHeader('Authorization', 'Bearer token123');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
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
    static void test_getHeaders_withEmptyHeaders() {
        HttpResponse response = new HttpResponse();
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        Map<String, String> headers = wrapper.getHeaders();
        Test.stopTest();
        
        Assert.areNotEqual(null, headers, 'Headers should not be null');
        Assert.areEqual(0, headers.size(), 'Headers should be empty');
    }
    
    @IsTest
    static void test_getBody_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        String body = '{"test": "data", "number": 123}';
        response.setBody(body);
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(body, result, 'Body should match');
    }
    
    @IsTest
    static void test_getBody_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        String body = '{"test": "data"}';
        restResponse.responseBody = Blob.valueOf(body);
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(body, result, 'Body should match');
    }
    
    @IsTest
    static void test_getBody_withNullRestResponseBody() {
        RestResponse restResponse = new RestResponse();
        restResponse.responseBody = null;
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        String result = wrapper.getBody();
        Test.stopTest();
        
        Assert.areEqual(null, result, 'Body should be null');
    }
    
    @IsTest
    static void test_getBodyAsBlob_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        String body = '{"test": "data"}';
        response.setBody(body);
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        Blob result = wrapper.getBodyAsBlob();
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'BodyAsBlob should not be null');
        Assert.areEqual(body, result.toString(), 'BodyAsBlob content should match');
    }
    
    @IsTest
    static void test_getBodyAsBlob_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        String body = '{"test": "data"}';
        Blob bodyBlob = Blob.valueOf(body);
        restResponse.responseBody = bodyBlob;
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        Blob result = wrapper.getBodyAsBlob();
        Test.stopTest();
        
        Assert.areEqual(bodyBlob, result, 'BodyAsBlob should match');
    }
    
    @IsTest
    static void test_getStatus_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        String status = wrapper.getStatus();
        Test.stopTest();
        
        Assert.areEqual('OK', status, 'Status should match');
    }
    
    @IsTest
    static void test_getStatus_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        String status = wrapper.getStatus();
        Test.stopTest();
        
        Assert.areEqual(null, status, 'Status should be null for RestResponse');
    }
    
    @IsTest
    static void test_getStatusCode_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(201);
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        Integer statusCode = wrapper.getStatusCode();
        Test.stopTest();
        
        Assert.areEqual(201, statusCode, 'StatusCode should match');
    }
    
    @IsTest
    static void test_getStatusCode_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        restResponse.statuscode = 404;
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        Integer statusCode = wrapper.getStatusCode();
        Test.stopTest();
        
        Assert.areEqual(404, statusCode, 'StatusCode should match');
    }
    
    @IsTest
    static void test_formatResponse_withHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"test": "data"}');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(response);
        Map<String, Object> formatted = wrapper.formatResponse();
        Test.stopTest();
        
        Assert.areNotEqual(null, formatted, 'Formatted response should not be null');
        Assert.areNotEqual(null, formatted.get('headerKeys'), 'HeaderKeys should not be null');
        Assert.areNotEqual(null, formatted.get('headers'), 'Headers should not be null');
        Assert.areEqual('{"test": "data"}', formatted.get('body'), 'Body should match');
        Assert.areNotEqual(null, formatted.get('bodyAsBlob'), 'BodyAsBlob should not be null');
        Assert.areEqual('OK', formatted.get('status'), 'Status should match');
        Assert.areEqual(200, formatted.get('statusCode'), 'StatusCode should match');
    }
    
    @IsTest
    static void test_formatResponse_withRestResponse() {
        RestResponse restResponse = new RestResponse();
        restResponse.statuscode = 201;
        // Note: RestResponse.headers is not accessible in tests
        restResponse.responseBody = Blob.valueOf('{"test": "data"}');
        
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper(restResponse);
        Map<String, Object> formatted = wrapper.formatResponse();
        Test.stopTest();
        
        Assert.areNotEqual(null, formatted, 'Formatted response should not be null');
        Assert.areNotEqual(null, formatted.get('headerKeys'), 'HeaderKeys should not be null');
        Assert.areNotEqual(null, formatted.get('headers'), 'Headers should not be null');
        Assert.areEqual('{"test": "data"}', formatted.get('body'), 'Body should match');
        Assert.areNotEqual(null, formatted.get('bodyAsBlob'), 'BodyAsBlob should not be null');
        Assert.areEqual(null, formatted.get('status'), 'Status should be null for RestResponse');
        Assert.areEqual(201, formatted.get('statusCode'), 'StatusCode should match');
    }
    
    @IsTest
    static void test_formatResponse_withNullResponses() {
        Test.startTest();
        HttpResponseWrapper wrapper = new HttpResponseWrapper((HttpResponse)null);
        Map<String, Object> formatted = wrapper.formatResponse();
        Test.stopTest();
        
        Assert.areEqual(null, formatted, 'Formatted response should be null when both responses are null');
    }
}