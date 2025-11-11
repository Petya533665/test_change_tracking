@IsTest
public with sharing class LogRelatedObjectsControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create Connected Org using TestDataFactory
        TestDataFactory.createConnectedOrg();
        
        // Create Log with Related Objects (with colon format)
        Map<String, List<Id>> relatedObjectsMap1 = new Map<String, List<Id>>();
        relatedObjectsMap1.put('Account:Accounts', TestDataFactory.getFakeIds(Account.SObjectType, 2));
        relatedObjectsMap1.put('Contact:Contacts', TestDataFactory.getFakeIds(Contact.SObjectType, 3));

        Log__c logWithRelatedObjects = new Log__c();
        logWithRelatedObjects.Type__c = 'ERROR';
        logWithRelatedObjects.Category__c = 'Apex';
        logWithRelatedObjects.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        logWithRelatedObjects.Related_Objects__c = JSON.serialize(relatedObjectsMap1);
        logWithRelatedObjects.Originated_From__c = ConfigUtil.ORIGINATED_FROM_BROADCAST; // Bypass trigger
        insert logWithRelatedObjects;
        
        // Create Log with Related Objects (without colon format)
        Map<String, List<Id>> relatedObjectsMap2 = new Map<String, List<Id>>();
        relatedObjectsMap2.put('Opportunity', TestDataFactory.getFakeIds(Opportunity.SObjectType, 1));
        relatedObjectsMap2.put('Lead', TestDataFactory.getFakeIds(Lead.SObjectType, 2));

        Log__c logWithSimpleObjects = new Log__c();
        logWithSimpleObjects.Type__c = 'INFO';
        logWithSimpleObjects.Category__c = 'Flow';
        logWithSimpleObjects.Related_Objects__c = JSON.serialize(relatedObjectsMap2);
        logWithSimpleObjects.Originated_From__c = ConfigUtil.ORIGINATED_FROM_BROADCAST; // Bypass trigger
        insert logWithSimpleObjects;
        
        // Create Log without Related Objects
        Log__c logWithoutRelatedObjects = new Log__c();
        logWithoutRelatedObjects.Type__c = 'DEBUG';
        logWithoutRelatedObjects.Category__c = 'API';
        insert logWithoutRelatedObjects;
        
        // Create Log with invalid JSON (bypass trigger to preserve invalid JSON)
        Log__c logWithInvalidJson = new Log__c();
        logWithInvalidJson.Type__c = 'ERROR';
        logWithInvalidJson.Category__c = 'InvalidJSON';
        logWithInvalidJson.Related_Objects__c = '{invalid json}';
        logWithInvalidJson.Originated_From__c = ConfigUtil.ORIGINATED_FROM_BROADCAST; // Bypass trigger
        insert logWithInvalidJson;
        
        // Create Log with empty Related Objects
        Log__c logWithEmptyRelatedObjects = new Log__c();
        logWithEmptyRelatedObjects.Type__c = 'WARN';
        logWithEmptyRelatedObjects.Category__c = 'Validation';
        logWithEmptyRelatedObjects.Related_Objects__c = JSON.serialize(new Map<String, List<Id>>());
        logWithEmptyRelatedObjects.Originated_From__c = ConfigUtil.ORIGINATED_FROM_BROADCAST; // Bypass trigger
        insert logWithEmptyRelatedObjects;
    }
    
    @IsTest
    static void test_getRelatedObjects_withValidRelatedObjectsAndColon() {
        Log__c log = [SELECT Id, Related_Objects__c FROM Log__c WHERE Type__c = 'ERROR' AND Category__c = 'Apex' LIMIT 1];
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects should not be null');
        Assert.areEqual(2, relatedObjects.size(), 'Should return 2 related object types');
        
        // Find Account related object
        LogRelatedObjectsController.RelatedObject accountObj = null;
        LogRelatedObjectsController.RelatedObject contactObj = null;
        for (LogRelatedObjectsController.RelatedObject obj : relatedObjects) {
            if (obj.name == 'Accounts') {
                accountObj = obj;
            } else if (obj.name == 'Contacts') {
                contactObj = obj;
            }
        }
        
        Assert.areNotEqual(null, accountObj, 'Account related object should exist');
        Assert.areEqual('Account', accountObj.label, 'Label should be Account');
        Assert.areEqual('Accounts', accountObj.name, 'Name should be Accounts');
        Assert.areEqual(2, accountObj.relatedIds.size(), 'Should have 2 account IDs');
        Assert.areEqual('Account (2)', accountObj.labelWithCount, 'Label with count should match');
        Assert.areNotEqual(null, accountObj.instanceUrl, 'Instance URL should not be null');
        Assert.isTrue(accountObj.instanceUrl.contains('test_Instance_Url'), 'Instance URL should match');
        
        Assert.areNotEqual(null, contactObj, 'Contact related object should exist');
        Assert.areEqual('Contact', contactObj.label, 'Label should be Contact');
        Assert.areEqual('Contacts', contactObj.name, 'Name should be Contacts');
        Assert.areEqual(3, contactObj.relatedIds.size(), 'Should have 3 contact IDs');
        Assert.areEqual('Contact (3)', contactObj.labelWithCount, 'Label with count should match');
    }
    
    @IsTest
    static void test_getRelatedObjects_withValidRelatedObjectsWithoutColon() {
        Log__c log = [SELECT Id FROM Log__c WHERE Type__c = 'INFO' AND Category__c = 'Flow' LIMIT 1];
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects should not be null');
        Assert.areEqual(2, relatedObjects.size(), 'Should return 2 related object types');
        
        // Find Opportunity related object
        LogRelatedObjectsController.RelatedObject oppObj = null;
        LogRelatedObjectsController.RelatedObject leadObj = null;
        for (LogRelatedObjectsController.RelatedObject obj : relatedObjects) {
            if (obj.name == 'Opportunity') {
                oppObj = obj;
            } else if (obj.name == 'Lead') {
                leadObj = obj;
            }
        }
        
        Assert.areNotEqual(null, oppObj, 'Opportunity related object should exist');
        Assert.areEqual('Opportunity', oppObj.label, 'Label should be Opportunity');
        Assert.areEqual('Opportunity', oppObj.name, 'Name should be Opportunity');
        Assert.areEqual(1, oppObj.relatedIds.size(), 'Should have 1 opportunity ID');
        Assert.areEqual('Opportunity (1)', oppObj.labelWithCount, 'Label with count should match');
        
        Assert.areNotEqual(null, leadObj, 'Lead related object should exist');
        Assert.areEqual('Lead', leadObj.label, 'Label should be Lead');
        Assert.areEqual('Lead', leadObj.name, 'Name should be Lead');
        Assert.areEqual(2, leadObj.relatedIds.size(), 'Should have 2 lead IDs');
        Assert.areEqual('Lead (2)', leadObj.labelWithCount, 'Label with count should match');
    }
    
    @IsTest
    static void test_getRelatedObjects_withoutRelatedObjects() {
        Log__c log = [SELECT Id FROM Log__c WHERE Type__c = 'DEBUG' AND Category__c = 'API' LIMIT 1];
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(0, relatedObjects.size(), 'Should return empty list when no related objects');
    }
    
    @IsTest
    static void test_getRelatedObjects_withInvalidJson() {
        Log__c log = [SELECT Id FROM Log__c WHERE Type__c = 'ERROR' AND Category__c = 'InvalidJSON' LIMIT 1];
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(0, relatedObjects.size(), 'Should return empty list when JSON is invalid');
    }
    
    @IsTest
    static void test_getRelatedObjects_withEmptyRelatedObjects() {
        Log__c log = [SELECT Id FROM Log__c WHERE Type__c = 'WARN' AND Category__c = 'Validation' LIMIT 1];
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(0, relatedObjects.size(), 'Should return empty list when related objects map is empty');
    }
    
    @IsTest
    static void test_getRelatedObjects_withNullRecordId() {
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(null);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(0, relatedObjects.size(), 'Should return empty list for null record ID');
    }
    
    @IsTest
    static void test_getRelatedObjects_withInvalidRecordId() {
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects('invalid_id_12345');
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(0, relatedObjects.size(), 'Should return empty list for invalid record ID');
    }
    
    @IsTest
    static void test_getRelatedObjects_withoutConnectedOrg() {
        // Create log without Organization_Id__c
        Log__c log = new Log__c();
        log.Type__c = 'INFO';
        log.Category__c = 'Test';
        log.Originated_From__c = ConfigUtil.ORIGINATED_FROM_BROADCAST; // Bypass trigger
        insert log;
        
        // Update with Map format after insert
        List<Id> caseIds = TestDataFactory.getFakeIds(Case.SObjectType, 1);
        Map<String, List<Id>> relatedObjectsMap = new Map<String, List<Id>>();
        relatedObjectsMap.put('Case', caseIds);
        log.Related_Objects__c = JSON.serialize(relatedObjectsMap);
        update log;
        
        Test.startTest();
        List<LogRelatedObjectsController.RelatedObject> relatedObjects = LogRelatedObjectsController.getRelatedObjects(log.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, relatedObjects, 'Related objects list should not be null');
        Assert.areEqual(1, relatedObjects.size(), 'Should return 1 related object');
        Assert.areEqual(null, relatedObjects[0].instanceUrl, 'Instance URL should be null when no connected org');
    }
    
    @IsTest
    static void test_relatedObject_constructor() {
        List<String> testIds = new List<String>();
        for (Id accountId : TestDataFactory.getFakeIds(Account.SObjectType, 3)) {
            testIds.add(String.valueOf(accountId));
        }
        
        Test.startTest();
        LogRelatedObjectsController.RelatedObject relatedObj = new LogRelatedObjectsController.RelatedObject(
            'LOG-12345',
            'https://example.salesforce.com',
            'Account',
            'Accounts',
            testIds
        );
        Test.stopTest();
        
        Assert.areEqual('LOG-12345', relatedObj.logName, 'Log name should match');
        Assert.areEqual('https://example.salesforce.com', relatedObj.instanceUrl, 'Instance URL should match');
        Assert.areEqual('Account', relatedObj.label, 'Label should match');
        Assert.areEqual('Accounts', relatedObj.name, 'Name should match');
        Assert.areEqual(3, relatedObj.relatedIds.size(), 'Related IDs count should match');
        Assert.areEqual('Account (3)', relatedObj.labelWithCount, 'Label with count should be correct');
    }
    
    @IsTest
    static void test_relatedObject_constructor_withEmptyIds() {
        List<String> emptyIds = new List<String>();
        
        Test.startTest();
        LogRelatedObjectsController.RelatedObject relatedObj = new LogRelatedObjectsController.RelatedObject(
            'LOG-00000',
            null,
            'Contact',
            'Contact',
            emptyIds
        );
        Test.stopTest();
        
        Assert.areEqual('LOG-00000', relatedObj.logName, 'Log name should match');
        Assert.areEqual(null, relatedObj.instanceUrl, 'Instance URL should be null');
        Assert.areEqual('Contact', relatedObj.label, 'Label should match');
        Assert.areEqual('Contact', relatedObj.name, 'Name should match');
        Assert.areEqual(0, relatedObj.relatedIds.size(), 'Related IDs should be empty');
        Assert.areEqual('Contact (0)', relatedObj.labelWithCount, 'Label with count should show zero');
    }
}