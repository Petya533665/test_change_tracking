@IsTest
public with sharing class ContentPageControllerTest {

    @TestSetup
    static void testSetup() {
        // Create test ContentDocument and ContentVersion records
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        // Get the ContentDocumentId from the inserted ContentVersion
        ContentVersion insertedVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id];
        
        // Create another ContentVersion for the same document to test IsLatest = true
        // When we insert a new version, Salesforce automatically sets IsLatest = true for the new version
        // and IsLatest = false for the previous version
        ContentVersion secondVersion = new ContentVersion(
            Title = 'Test Document Updated',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Updated test file content'),
            ContentDocumentId = insertedVersion.ContentDocumentId,
            IsMajorVersion = true
        );
        insert secondVersion;
    }

    @IsTest
    static void testGetJsonData_WithValidContentDocumentId() {
        // Get the ContentDocumentId from test setup
        ContentVersion latestVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE IsLatest = true LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', latestVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify JSON data is returned
        Assert.areNotEqual('', jsonData, 'JSON data should not be empty');
        Assert.areNotEqual(null, jsonData, 'JSON data should not be null');
        
        // Verify JSON structure contains file extension and data
        Assert.isTrue(jsonData.contains('"txt"'), 'JSON should contain file extension');
        
        // Blob is serialized as base64, so we need to check for base64 representation
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Updated test file content'));
        Assert.isTrue(jsonData.contains(base64Content), 'JSON should contain base64 encoded file content');
    }

    @IsTest
    static void testGetJsonData_WithInvalidContentDocumentId() {
        // Set up page parameters with invalid ContentDocumentId
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', '069000000000000'); // Invalid ID
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify empty string is returned for invalid ID
        Assert.areEqual('', jsonData, 'Should return empty string for invalid ContentDocumentId');
    }

    @IsTest
    static void testGetJsonData_WithNoContentDocumentId() {
        // Set up page without ContentDocumentId parameter
        PageReference pageRef = Page.getContentPage;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify empty string is returned when no parameter is provided
        Assert.areEqual('', jsonData, 'Should return empty string when no ContentDocumentId parameter');
    }

    @IsTest
    static void testGetJsonData_WithBlankContentDocumentId() {
        // Set up page with blank ContentDocumentId parameter
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', '');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify empty string is returned for blank parameter
        Assert.areEqual('', jsonData, 'Should return empty string for blank ContentDocumentId');
    }

    @IsTest
    static void testGetJsonData_WithNonExistentContentDocumentId() {
        // Set up page with non-existent ContentDocumentId
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', '069000000000000AAA'); // Non-existent ID
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify empty string is returned for non-existent ID
        Assert.areEqual('', jsonData, 'Should return empty string for non-existent ContentDocumentId');
    }

    @IsTest
    static void testGetJsonData_ReturnsLatestVersion() {
        // Get the ContentDocumentId from test setup
        ContentVersion latestVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE IsLatest = true LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', latestVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify that the latest version content is returned (not the first version)
        String latestBase64Content = EncodingUtil.base64Encode(Blob.valueOf('Updated test file content'));
        String firstBase64Content = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        
        Assert.isTrue(jsonData.contains(latestBase64Content), 'Should return latest version content');
        Assert.isFalse(jsonData.contains(firstBase64Content), 'Should not return first version content');
    }

    @IsTest
    static void testGetJsonData_WithDifferentFileExtensions() {
        // Create ContentVersion with different file extension
        ContentVersion pdfVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('PDF content'),
            IsMajorVersion = true
        );
        insert pdfVersion;
        
        // Get the ContentDocumentId
        ContentVersion insertedPdfVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :pdfVersion.Id];
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', insertedPdfVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify JSON contains PDF extension
        Assert.isTrue(jsonData.contains('"pdf"'), 'JSON should contain PDF file extension');
        
        // Check for base64 encoded PDF content
        String pdfBase64Content = EncodingUtil.base64Encode(Blob.valueOf('PDF content'));
        Assert.isTrue(jsonData.contains(pdfBase64Content), 'JSON should contain base64 encoded PDF content');
    }

    @IsTest
    static void testGetJsonData_JsonStructure() {
        // Get the ContentDocumentId from test setup
        ContentVersion latestVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE IsLatest = true LIMIT 1];
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', latestVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify JSON structure
        Assert.isTrue(jsonData.startsWith('{'), 'JSON should start with opening brace');
        Assert.isTrue(jsonData.endsWith('}'), 'JSON should end with closing brace');
        Assert.isTrue(jsonData.contains('"txt"'), 'JSON should contain file extension as key');
        
        // Try to deserialize JSON to verify it's valid
        try {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
            Assert.isTrue(jsonMap.containsKey('txt'), 'JSON should contain file extension key');
            
            // Verify the value is a string (base64 encoded blob)
            Object blobValue = jsonMap.get('txt');
            Assert.isTrue(blobValue instanceof String, 'Blob should be serialized as base64 string');
        } catch (Exception e) {
            Assert.isTrue(false, 'JSON should be valid and deserializable: ' + e.getMessage());
        }
    }

    @IsTest
    static void testGetJsonData_WithMinimalVersionData() {
        // Create ContentVersion with minimal VersionData
        ContentVersion minimalVersion = new ContentVersion(
            Title = 'Minimal Document',
            PathOnClient = 'minimal.txt',
            VersionData = Blob.valueOf('X'), // Single character
            IsMajorVersion = true
        );
        insert minimalVersion;
        
        // Get the ContentDocumentId
        ContentVersion insertedMinimalVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :minimalVersion.Id];
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', insertedMinimalVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify JSON is returned with minimal data
        Assert.areNotEqual('', jsonData, 'JSON should not be empty even with minimal VersionData');
        Assert.isTrue(jsonData.contains('"txt"'), 'JSON should contain file extension');
        
        // Check for base64 encoded minimal content
        String minimalBase64Content = EncodingUtil.base64Encode(Blob.valueOf('X'));
        Assert.isTrue(jsonData.contains(minimalBase64Content), 'JSON should contain base64 encoded minimal content');
    }

    @IsTest
    static void testGetJsonData_MultipleVersionsOnlyLatestReturned() {
        // Get the ContentDocumentId from test setup
        ContentVersion latestVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE IsLatest = true LIMIT 1];
        
        // Create additional version - this will become the new latest version
        ContentVersion newLatestVersion = new ContentVersion(
            Title = 'New Latest Version',
            PathOnClient = 'newlatest.txt',
            VersionData = Blob.valueOf('New latest content'),
            ContentDocumentId = latestVersion.ContentDocumentId,
            IsMajorVersion = true
        );
        insert newLatestVersion;
        
        // Set up page parameters
        PageReference pageRef = Page.getContentPage;
        pageRef.getParameters().put('contentDocumentId', latestVersion.ContentDocumentId);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ContentPageController controller = new ContentPageController();
        String jsonData = controller.getJsonData();
        Test.stopTest();
        
        // Verify only the newest latest version is returned
        String newLatestBase64Content = EncodingUtil.base64Encode(Blob.valueOf('New latest content'));
        String previousLatestBase64Content = EncodingUtil.base64Encode(Blob.valueOf('Updated test file content'));
        String firstBase64Content = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        
        Assert.isTrue(jsonData.contains(newLatestBase64Content), 'Should return newest latest version content');
        Assert.isFalse(jsonData.contains(previousLatestBase64Content), 'Should not return previous latest version content');
        Assert.isFalse(jsonData.contains(firstBase64Content), 'Should not return first version content');
    }
}