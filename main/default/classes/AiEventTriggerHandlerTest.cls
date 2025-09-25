@isTest
private class AiEventTriggerHandlerTest {
    @isTest
    static void testAiEventHandler() {
        // Create test data for Issue__c
        Issue__c testIssue = new Issue__c(Description__c = 'Test Issue');
        insert testIssue;

        // Create test data for AI_Event__e
        AI_Event__e testEvent = new AI_Event__e(
            Record_Id__c = testIssue.Id,
            Method__c = 'TestMethod',
            Result__c = '{"key": "value"}'
        );

        // Create a list of AI_Event__e and add the test event
        List<AI_Event__e> events = new List<AI_Event__e>{ testEvent };

        // Execute the method with the test data
        Test.startTest();
        AiEventTriggerHandler.aiEventHandler(events); // Assuming 'AiEventTriggerHandler' is your class name
        Test.stopTest();

        // Assert that a ContentVersion record was created
        List<ContentVersion> cvList = [SELECT Id, PathOnClient, Description FROM ContentVersion WHERE Title = :testIssue.Description__c + '_TestMethod.json'];
        System.assertEquals(1, cvList.size(), 'Expected one ContentVersion to be created.');

        // Assert that the PathOnClient is correctly set
        if (!cvList.isEmpty()) {
            ContentVersion cv = cvList[0];
            System.assertEquals(testIssue.Description__c + '_TestMethod.json', cv.PathOnClient, 'ContentVersion PathOnClient does not match expected value.');
            
            // Assert that a ContentDocumentLink was created for the ContentVersion
            List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :testEvent.Record_Id__c];
            System.assertEquals(1, cdlList.size(), 'Expected one ContentDocumentLink to be created for the ContentVersion.');
        }
    }
}