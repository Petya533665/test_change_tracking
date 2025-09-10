@IsTest
private class Test_Email2CaseParser {

    private static final String LOG_FIELD_API_NAME_CATEGORY = Log__c.Category__c.getDescribe().getName();
    
    @IsTest
    static void test_constructor() {
        Email2CaseParser parser = new Email2CaseParser();
        Assert.isNotNull(parser, 'Parser should be created successfully');
    }
    
    @IsTest
    static void test_init_withValidData() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        Test.startTest();
            parser.init(errorBody, emailSubject, emailSentFrom);
        Test.stopTest();
        
        Assert.areEqual(' Invalid email format ', parser.getError(), 'Error should be extracted correctly with leading and trailing spaces');
        Assert.areEqual('Email-to-Case', parser.getCategory(), 'Category should be set correctly');
    }
    
    @IsTest
    static void test_init_withEmptyErrorBody() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = '';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        Test.startTest();
            parser.init(errorBody, emailSubject, emailSentFrom);
        Test.stopTest();
        
        Assert.isTrue(String.isBlank(parser.getError()), 'Error should be empty when errorBody is blank');
    }
    
    @IsTest
    static void test_init_withoutErrorMarkers() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Some random error message without proper markers';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        Test.startTest();
            parser.init(errorBody, emailSubject, emailSentFrom);
        Test.stopTest();
        
        Assert.isTrue(String.isBlank(parser.getError()), 'Error should be empty when markers are not found');
    }
    
    @IsTest
    static void test_canProcess_withValidSubject() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            Boolean canProcess = parser.canProcess();
        Test.stopTest();
        
        Assert.isTrue(canProcess, 'Should be able to process when subject contains Email-to-Case marker');
    }
    
    @IsTest
    static void test_canProcess_withInvalidSubject() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Regular email subject without marker';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            Boolean canProcess = parser.canProcess();
        Test.stopTest();
        
        Assert.isFalse(canProcess, 'Should not be able to process when subject does not contain Email-to-Case marker');
    }
    
    @IsTest
    static void test_canProcess_withBlankSubject() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = '';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            Boolean canProcess = parser.canProcess();
        Test.stopTest();
        
        Assert.isFalse(canProcess, 'Should not be able to process when subject is blank');
    }
    
    @IsTest
    static void test_process() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            parser.process();
        Test.stopTest();
        
        // process() method is empty, so we just verify it doesn't throw an exception
        Assert.isTrue(true, 'Process method should execute without errors');
    }
    
    @IsTest
    static void test_getError() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String error = parser.getError();
        Test.stopTest();
        
        Assert.areEqual(' Invalid email format ', error, 'Should return extracted error message with leading and trailing spaces');
    }
    
    @IsTest
    static void test_getErrorSummary() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String summary = parser.getErrorSummary();
        Test.stopTest();
        
        Assert.areEqual('Email to Case Failure', summary, 'Should return correct error summary');
    }
    
    @IsTest
    static void test_getErrorDetails() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body with details';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String details = parser.getErrorDetails();
        Test.stopTest();
        
        Assert.areEqual('Test error body with details', details, 'Should return original error body');
    }
    
    @IsTest
    static void test_getErrorType() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String errorType = parser.getErrorType();
        Test.stopTest();
        
        Assert.areEqual('Error', errorType, 'Should return correct error type');
    }
    
    @IsTest
    static void test_getStackTrace() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String stackTrace = parser.getStackTrace();
        Test.stopTest();
        
        Assert.areEqual(' Invalid email format ', stackTrace, 'Should return extracted error as stack trace with leading and trailing spaces');
    }
    
    @IsTest
    static void test_getArea() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String area = parser.getArea();
        Test.stopTest();
        
        Assert.areEqual('Cases', area, 'Should return correct area');
    }
    
    @IsTest
    static void test_getCategory() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String category = parser.getCategory();
        Test.stopTest();
        
        Assert.areEqual('Email-to-Case', category, 'Should return correct category');
    }
    
    @IsTest
    static void test_getOrganizationId() {
        Email2CaseParser parser = new Email2CaseParser();
        
        Test.startTest();
            String orgId = parser.getOrganizationId();
        Test.stopTest();
        
        Assert.areEqual(UserInfo.getOrganizationId(), orgId, 'Should return current organization ID');
    }
    
    @IsTest
    static void test_getCustomInfo() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'Test error body';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            List<ICustomErrorInfo> customInfo = parser.getCustomInfo();
        Test.stopTest();
        
        Assert.isNotNull(customInfo, 'Custom info should not be null');
        Assert.areEqual(1, customInfo.size(), 'Should return one custom info item');
        
        ICustomErrorInfo categoryField = customInfo[0];
        Assert.areEqual('Email-to-Case', categoryField.getValue(), 'Category field should have correct value');
        Assert.areEqual(LOG_FIELD_API_NAME_CATEGORY, categoryField.getLogFieldName(), 'Category field should have correct field name');
    }
    
    @IsTest
    static void test_getHash1() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String hash1 = parser.getHash1();
        Test.stopTest();
        
        Assert.isNotNull(hash1, 'Hash1 should not be null');
        Assert.isTrue(String.isNotBlank(hash1), 'Hash1 should not be blank');
    }
    
    @IsTest
    static void test_getHash2() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String hash2 = parser.getHash2();
        Test.stopTest();
        
        Assert.isNotNull(hash2, 'Hash2 should not be null');
        Assert.isTrue(String.isNotBlank(hash2), 'Hash2 should not be blank');
    }
    
    @IsTest
    static void test_getHash3() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Invalid email format From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(errorBody, emailSubject, emailSentFrom);
        
        Test.startTest();
            String hash3 = parser.getHash3();
        Test.stopTest();
        
        Assert.isNotNull(hash3, 'Hash3 should not be null');
        Assert.isTrue(String.isNotBlank(hash3), 'Hash3 should not be blank');
    }
    
    @IsTest
    static void test_CategoryField_constructor() {
        Test.startTest();
            Email2CaseParser.CategoryField categoryField = new Email2CaseParser.CategoryField('Test Category');
        Test.stopTest();
        
        Assert.isNotNull(categoryField, 'CategoryField should be created successfully');
        Assert.areEqual('Test Category', categoryField.category, 'Category should be set correctly');
    }
    
    @IsTest
    static void test_CategoryField_getValue() {
        Email2CaseParser.CategoryField categoryField = new Email2CaseParser.CategoryField('Test Category');
        
        Test.startTest();
            String value = categoryField.getValue();
        Test.stopTest();
        
        Assert.areEqual('Test Category', value, 'Should return correct category value');
    }
    
    @IsTest
    static void test_CategoryField_getLogFieldName() {
        Email2CaseParser.CategoryField categoryField = new Email2CaseParser.CategoryField('Test Category');
        
        Test.startTest();
            String fieldName = categoryField.getLogFieldName();
        Test.stopTest();
        
        Assert.areEqual(LOG_FIELD_API_NAME_CATEGORY, fieldName, 'Should return correct field name');
    }
    
    @IsTest
    static void test_integration_scenario() {
        Email2CaseParser parser = new Email2CaseParser();
        String errorBody = 'The following errors were encountered while processing an incoming email: Field validation failed: [Email] Invalid email format From: user@example.com';
        String emailSubject = 'Email-to-Case: Support Request #123';
        String emailSentFrom = 'noreply@salesforce.com';
        
        Test.startTest();
            parser.init(errorBody, emailSubject, emailSentFrom);
            
            Boolean canProcess = parser.canProcess();
            Assert.isTrue(canProcess, 'Should be able to process valid email-to-case error');
            
            parser.process();
            
            String error = parser.getError();
            String summary = parser.getErrorSummary();
            String details = parser.getErrorDetails();
            String errorType = parser.getErrorType();
            String area = parser.getArea();
            String category = parser.getCategory();
            String orgId = parser.getOrganizationId();
            String stackTrace = parser.getStackTrace();
        
            List<ICustomErrorInfo> customInfo = parser.getCustomInfo();
            
            String hash1 = parser.getHash1();
            String hash2 = parser.getHash2();
            String hash3 = parser.getHash3();
        Test.stopTest();
        
                 // Verify all values
         Assert.areEqual(' Field validation failed: [Email] Invalid email format ', error, 'Error should be extracted correctly with leading and trailing spaces');
         Assert.areEqual('Email to Case Failure', summary, 'Summary should be correct');
         Assert.areEqual(errorBody, details, 'Details should match original error body');
         Assert.areEqual('Error', errorType, 'Error type should be correct');
         Assert.areEqual('Cases', area, 'Area should be correct');
         Assert.areEqual('Email-to-Case', category, 'Category should be correct');
         Assert.areEqual(UserInfo.getOrganizationId(), orgId, 'Organization ID should be correct');
         Assert.areEqual(' Field validation failed: [Email] Invalid email format ', stackTrace, 'Stack trace should match error with leading and trailing spaces');
        
        Assert.isNotNull(customInfo, 'Custom info should not be null');
        Assert.areEqual(1, customInfo.size(), 'Should have one custom info item');
        
        Assert.isNotNull(hash1, 'Hash1 should not be null');
        Assert.isNotNull(hash2, 'Hash2 should not be null');
        Assert.isNotNull(hash3, 'Hash3 should not be null');
    }
    
    @IsTest
    static void test_edge_cases() {
        Email2CaseParser parser = new Email2CaseParser();
        
        // Test with null values
        Test.startTest();
            parser.init(null, null, null);
        Test.stopTest();
        
        Assert.areEqual('', parser.getError(), 'Error should be empty with null input');
        Assert.isFalse(parser.canProcess(), 'Should not process with null subject');
        
        // Test with very long error message
        String longErrorBody = 'The following errors were encountered while processing an incoming email: ' + 
            'A'.repeat(1000) + ' From: test@example.com';
        String emailSubject = 'Email-to-Case: Test Case';
        String emailSentFrom = 'sender@example.com';
        
        parser.init(longErrorBody, emailSubject, emailSentFrom);
        
        String error = parser.getError();
        Assert.isTrue(error.length() > 0, 'Should extract error from long message');
        Assert.isTrue(error.length() < longErrorBody.length(), 'Extracted error should be shorter than original');
    }
}