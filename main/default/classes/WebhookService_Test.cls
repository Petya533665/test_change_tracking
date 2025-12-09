/**
 * Test class for WebhookService
 */
@isTest
private class WebhookService_Test {
    
    // Mock HTTP callout for successful webhook
    private class WebhookSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"status": "success", "id": "12345"}');
            return res;
        }
    }
    
    // Mock HTTP callout for failed webhook
    private class WebhookFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            res.setBody('{"error": "Invalid request"}');
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        // Create test log record
        Log__c testLog = new Log__c(
            Summary__c = 'Test error message',
            Type__c = 'Error',
            Category__c = 'Test Category',
            Area__c = 'Test Area'
        );
        insert testLog;
    }
    
    @isTest
    static void testWebhookConfigFromAction_Success() {
        // Create action with webhook configuration
        Action__c action = new Action__c(
            Action_Type__c = 'Webhook Notification',
            Webhook_URL__c = 'https://api.example.com/webhook',
            Webhook_Method__c = 'POST',
            Webhook_Headers__c = '{"X-Custom-Header": "test-value"}',
            Webhook_Body_Template__c = '{"message": "{!Log__c.Summary__c}"}',
            Webhook_Auth_Type__c = 'Bearer'
        );
        
        // Save token to custom settings
        Logger logger = Logger.getInstance();
        WebhookService.putWebhookTokenToSettings('https://api.example.com/webhook', 'test-token', true, logger);
        GraphAPIService.saveListTokenRecordSettings(true, logger);
        
        Test.startTest();
        WebhookService.WebhookConfig config = WebhookService.buildConfigFromAction(action);
        Test.stopTest();
        
        System.assertEquals('https://api.example.com/webhook', config.url, 'URL should match');
        System.assertEquals('POST', config.method, 'Method should match');
        System.assertEquals('application/json', config.contentType, 'Content type should match');
        System.assert(config.headers.containsKey('X-Custom-Header'), 'Should have custom header');
        System.assertEquals('test-value', config.headers.get('X-Custom-Header'), 'Header value should match');
        System.assertNotEquals(null, config.authConfig, 'Auth config should be set');
    }
    
    @isTest
    static void testWebhookConfigFromAction_InvalidJson() {
        // Create action with invalid JSON headers
        Action__c action = new Action__c(
            Action_Type__c = 'Webhook Notification',
            Webhook_URL__c = 'https://api.example.com/webhook',
            Webhook_Headers__c = 'invalid json',
            Webhook_Body_Template__c = '{"message": "test"}'
        );
        
        Test.startTest();
        WebhookService.WebhookConfig config = WebhookService.buildConfigFromAction(action);
        Test.stopTest();
        
        System.assertEquals(0, config.headers.size(), 'Should have empty headers map on invalid JSON');
    }
    
    @isTest
    static void testWebhookConfigValidation() {
        // Test valid config
        WebhookService.WebhookConfig validConfig = new WebhookService.WebhookConfig();
        validConfig.url = 'https://api.example.com/webhook';
        System.assert(validConfig.isValid(), 'Valid config should pass validation');
        
        // Test invalid config - no URL
        WebhookService.WebhookConfig invalidConfig = new WebhookService.WebhookConfig();
        System.assert(!invalidConfig.isValid(), 'Config without URL should fail validation');
        
        // Test invalid config - malformed URL
        WebhookService.WebhookConfig malformedConfig = new WebhookService.WebhookConfig();
        malformedConfig.url = 'not-a-valid-url';
        System.assert(!malformedConfig.isValid(), 'Config with malformed URL should fail validation');
    }
    
    @isTest
    static void testWebhookAuthConfig_Bearer() {
        WebhookService.WebhookAuthConfig authConfig = new WebhookService.WebhookAuthConfig('Bearer', 'test-token');
        
        HttpRequest req = new HttpRequest();
        authConfig.applyAuth(req);
        
        System.assertEquals('Bearer test-token', req.getHeader('Authorization'), 'Should set Bearer token');
    }
    
    @isTest
    static void testWebhookAuthConfig_Basic() {
        String encodedCreds = EncodingUtil.base64Encode(Blob.valueOf('user:pass'));
        WebhookService.WebhookAuthConfig authConfig = new WebhookService.WebhookAuthConfig('Basic', encodedCreds);
        
        HttpRequest req = new HttpRequest();
        authConfig.applyAuth(req);
        
        System.assertEquals('Basic ' + encodedCreds, req.getHeader('Authorization'), 'Should set Basic auth');
    }
    
    @isTest
    static void testWebhookAuthConfig_ApiKey() {
        WebhookService.WebhookAuthConfig authConfig = new WebhookService.WebhookAuthConfig('API_Key', 'X-API-Key:secret-key');
        
        HttpRequest req = new HttpRequest();
        authConfig.applyAuth(req);
        
        System.assertEquals('secret-key', req.getHeader('X-API-Key'), 'Should set API key header');
    }
    
    @isTest
    static void testWebhookAuthConfig_Custom() {
        WebhookService.WebhookAuthConfig authConfig = new WebhookService.WebhookAuthConfig('Custom', 'Token abc123');
        
        HttpRequest req = new HttpRequest();
        authConfig.applyAuth(req);
        
        System.assertEquals('Token abc123', req.getHeader('Authorization'), 'Should set custom auth header');
    }
    
    @isTest
    static void testWebhookAuthConfig_None() {
        WebhookService.WebhookAuthConfig authConfig = new WebhookService.WebhookAuthConfig('None', '');
        
        HttpRequest req = new HttpRequest();
        authConfig.applyAuth(req);
        
        System.assertEquals(null, req.getHeader('Authorization'), 'Should not set any auth header');
    }
    
    @isTest
    static void testSendWebhook_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WebhookSuccessMock());
        
        // Get test log
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        
        // Create webhook configuration
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        config.url = 'https://api.example.com/webhook';
        config.method = 'POST';
        config.bodyTemplate = '{"log_id": "{!Log__c.Id}"}';
        
        Test.startTest();
        WebhookService.WebhookResponse response = WebhookService.sendWebhook(testLog.Id, config);
        Test.stopTest();
        
        System.assert(response.success, 'Webhook should succeed');
        System.assertEquals(200, response.statusCode, 'Status code should be 200');
        System.assert(response.body.contains('success'), 'Response should contain success');
    }
    
    @isTest
    static void testSendWebhook_Failure() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WebhookFailureMock());
        
        // Get test log
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        
        // Create webhook configuration
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        config.url = 'https://api.example.com/webhook';
        config.method = 'POST';
        config.bodyTemplate = '{"log_id": "{!Log__c.Id}"}';
        
        Test.startTest();
        WebhookService.WebhookResponse response = WebhookService.sendWebhook(testLog.Id, config);
        Test.stopTest();
        
        System.assert(!response.success, 'Webhook should fail');
        System.assertEquals(400, response.statusCode, 'Status code should be 400');
        System.assertNotEquals(null, response.errorMessage, 'Should have error message');
    }
    
    @isTest
    static void testSendWebhook_InvalidConfig() {
        // Get test log
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        
        // Create invalid configuration (no URL)
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        
        Test.startTest();
        try {
            WebhookService.sendWebhook(testLog.Id, config);
            System.assert(false, 'Should have thrown exception');
        } catch (WebhookService.WebhookException e) {
            System.assert(e.getMessage().contains('Invalid webhook configuration'), 'Should have validation error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendWebhook_WithHeaders() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WebhookSuccessMock());
        
        // Get test log
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        
        // Create webhook configuration with custom headers
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        config.url = 'https://api.example.com/webhook';
        config.method = 'POST';
        config.headers.put('X-Custom-Header', 'custom-value');
        config.headers.put('X-Request-ID', 'test-123');
        config.bodyTemplate = '{"log_id": "{!Log__c.Id}"}';
        
        Test.startTest();
        WebhookService.WebhookResponse response = WebhookService.sendWebhook(testLog.Id, config);
        Test.stopTest();
        
        System.assert(response.success, 'Webhook should succeed');
    }
    
    @isTest
    static void testSendWebhook_WithAuthentication() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WebhookSuccessMock());
        
        // Get test log
        Log__c testLog = [SELECT Id FROM Log__c LIMIT 1];
        
        // Create webhook configuration with authentication
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        config.url = 'https://api.example.com/webhook';
        config.method = 'POST';
        config.authConfig = new WebhookService.WebhookAuthConfig('Bearer', 'test-token');
        config.bodyTemplate = '{"log_id": "{!Log__c.Id}"}';
        
        Test.startTest();
        WebhookService.WebhookResponse response = WebhookService.sendWebhook(testLog.Id, config);
        Test.stopTest();
        
        System.assert(response.success, 'Webhook should succeed');
    }
    
    @isTest
    static void testIsValidJsonTemplate() {
        // Valid JSON
        System.assert(WebhookService.isValidJsonTemplate('{"key": "value"}'), 'Valid JSON should pass');
        
        // Valid JSON with merge fields
        System.assert(WebhookService.isValidJsonTemplate('{"id": "{!Log__c.Id}"}'), 'JSON with merge fields should pass');
        
        // Empty string
        System.assert(WebhookService.isValidJsonTemplate(''), 'Empty string should pass');
        
        // Invalid JSON
        System.assert(!WebhookService.isValidJsonTemplate('not json'), 'Invalid JSON should fail');
    }
    
    @isTest
    static void testWebhookResponse_Success() {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(200);
        httpResponse.setStatus('OK');
        httpResponse.setBody('{"status": "success"}');
        
        WebhookService.WebhookResponse response = new WebhookService.WebhookResponse(httpResponse);
        
        System.assert(response.success, 'Should be successful');
        System.assertEquals(200, response.statusCode, 'Status code should match');
        System.assertEquals(null, response.errorMessage, 'Should not have error message');
    }
    
    @isTest
    static void testWebhookResponse_Failure() {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(500);
        httpResponse.setStatus('Internal Server Error');
        httpResponse.setBody('{"error": "Server error"}');
        
        WebhookService.WebhookResponse response = new WebhookService.WebhookResponse(httpResponse);
        
        System.assert(!response.success, 'Should not be successful');
        System.assertEquals(500, response.statusCode, 'Status code should match');
        System.assertNotEquals(null, response.errorMessage, 'Should have error message');
    }
    
    @isTest
    static void testWebhookResponse_Exception() {
        Exception e = new System.CalloutException('Connection timeout');
        
        WebhookService.WebhookResponse response = new WebhookService.WebhookResponse(e);
        
        System.assert(!response.success, 'Should not be successful');
        System.assertEquals(0, response.statusCode, 'Status code should be 0');
        System.assert(response.errorMessage.contains('Connection timeout'), 'Should have exception message');
    }
    
    @isTest
    static void testMergeFieldsWithSpecialCharacters() {
        // Create a Log record with special characters (newlines, quotes, backslashes)
        Log__c testLog = new Log__c(
            Summary__c = 'Test with "quotes" and \\backslashes\\',
            Details__c = 'Line 1\nLine 2\nLine 3\n"Quoted text"\nMore text',
            Type__c = 'Error',
            Category__c = 'Flow'
        );
        insert testLog;
        
        // Set up mock for HTTP callout
        Test.setMock(HttpCalloutMock.class, new WebhookSuccessMock());
        
        // Dynamically get object and field names with namespace prefix
        String logObjectName = Log__c.SObjectType.getDescribe().getName();
        String summaryFieldName = Schema.SObjectType.Log__c.fields.Summary__c.getName();
        String detailsFieldName = Schema.SObjectType.Log__c.fields.Details__c.getName();
        String typeFieldName = Schema.SObjectType.Log__c.fields.Type__c.getName();
        
        // Create webhook config with JSON template containing merge fields (with dynamic namespace)
        WebhookService.WebhookConfig config = new WebhookService.WebhookConfig();
        config.url = 'https://example.com/webhook';
        config.method = 'POST';
        config.bodyTemplate = '{\n' +
            '  "summary": "{!' + logObjectName + '.' + summaryFieldName + '}",\n' +
            '  "details": "{!' + logObjectName + '.' + detailsFieldName + '}",\n' +
            '  "type": "{!' + logObjectName + '.' + typeFieldName + '}"\n' +
            '}';
        
        Test.startTest();
        WebhookService.WebhookResponse response = WebhookService.sendWebhook(testLog.Id, config);
        Test.stopTest();
        
        System.assert(response.success, 'Webhook should succeed');
        
        // Verify the rendered body is valid JSON (can be parsed)
        try {
            Map<String, Object> parsedBody = (Map<String, Object>)JSON.deserializeUntyped(response.requestBody);
            System.assertNotEquals(null, parsedBody, 'Body should be parseable JSON');
            
            // Verify special characters are properly escaped
            String summary = (String)parsedBody.get('summary');
            String details = (String)parsedBody.get('details');
            
            System.assert(summary.contains('"quotes"'), 'Should contain quotes');
            System.assert(summary.contains('\\backslashes\\'), 'Should contain backslashes');
            System.assert(details.contains('\n'), 'Should contain newlines (as escaped \\n in JSON)');
            System.assert(details.contains('"Quoted text"'), 'Should contain quoted text');
        } catch (Exception e) {
            System.assert(false, 'Body should be valid JSON, but got exception: ' + e.getMessage());
        }
    }
}