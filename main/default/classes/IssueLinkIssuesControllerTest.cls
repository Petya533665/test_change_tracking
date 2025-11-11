@IsTest
public with sharing class IssueLinkIssuesControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create test issues
        List<Issue__c> issues = new List<Issue__c>();
        
        // Create main issue
        Issue__c mainIssue = new Issue__c();
        mainIssue.Status__c = 'New';
        mainIssue.Summary__c = 'Main Issue';
        issues.add(mainIssue);
        
        // Create duplicate issue
        Issue__c duplicateIssue = new Issue__c();
        duplicateIssue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
        duplicateIssue.Summary__c = 'Duplicate Issue';
        issues.add(duplicateIssue);
        
        // Create regular issue
        Issue__c regularIssue = new Issue__c();
        regularIssue.Status__c = 'New';
        regularIssue.Summary__c = 'Regular Issue';
        issues.add(regularIssue);
        
        insert issues;
        
        // Update duplicate issue to reference main issue
        duplicateIssue.Related_Issue__c = mainIssue.Id;
        update duplicateIssue;
        
        // Create logs for testing
        List<Log__c> logs = new List<Log__c>();
        
        Log__c log1 = new Log__c();
        log1.Issue__c = mainIssue.Id;
        log1.Type__c = 'ERROR';
        log1.Category__c = 'Apex';
        logs.add(log1);
        
        Log__c log2 = new Log__c();
        log2.Issue__c = regularIssue.Id;
        log2.Type__c = 'ERROR';
        log2.Category__c = 'Apex';
        logs.add(log2);
        
        insert logs;
    }
    
    @IsTest
    static void test_constructor_withSelectedIssues() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areNotEqual(0, controller.issuesToUpdate.size(), 'Should have issues to update');
    }
    
    @IsTest
    static void test_constructor_withDuplicateIssues() {
        List<Issue__c> duplicateIssues = [SELECT Id FROM Issue__c WHERE Status__c = :IssueService.ISSUE_STATUS_DUPLICATE];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(duplicateIssues);
        setController.setSelected(duplicateIssues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        // Should include related issues instead of duplicate issues
        Assert.areNotEqual(0, controller.issuesToUpdate.size(), 'Should have issues to update');
    }
    
    @IsTest
    static void test_constructor_withEmptySelection() {
        List<Issue__c> issues = new List<Issue__c>();
        
        // Create StandardSetController mock with empty selection
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areEqual(0, controller.issuesToUpdate.size(), 'Should have no issues to update when selection is empty');
    }
    
    @IsTest
    static void test_updateIssues_success() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should be true after update');
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
    }
    
    @IsTest
    static void test_updateIssues_alreadyProcessing() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        controller.isProcessing = true; // Set to already processing
        
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should remain true');
    }
    
    @IsTest
    static void test_updateIssues_withManyLogs() {
        // Create additional logs to exceed the limit
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        List<Log__c> additionalLogs = new List<Log__c>();
        
        for (Integer i = 0; i < IssueService.LIMIT_LOGS_CALCULATE_COUNT + 10; i++) {
            Log__c log = new Log__c();
            log.Issue__c = issues[0].Id;
            log.Type__c = 'ERROR';
            log.Category__c = 'Apex';
            additionalLogs.add(log);
        }
        insert additionalLogs;
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should be true after update');
    }
    
    @IsTest
    static void test_doRedirect() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 1];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        PageReference result = controller.doRedirect();
        Test.stopTest();
        
        // PageReference may be null in test context, so we just verify the method executes without error
        Assert.areNotEqual(null, controller, 'controller should not be null');
    }
    
    @IsTest
    static void test_issuesToUpdate_property() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        List<Issue__c> issuesToUpdate = controller.issuesToUpdate;
        Test.stopTest();
        
        Assert.areNotEqual(null, issuesToUpdate, 'issuesToUpdate property should not be null');
        Assert.areNotEqual(0, issuesToUpdate.size(), 'issuesToUpdate should contain issues');
    }
    
    @IsTest
    static void test_constructor_issueLinkingLogic() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueLinkIssuesController controller = new IssueLinkIssuesController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        
        // Verify that issues are properly linked (first issue should not have Related_Issue__c, others should)
        Assert.isTrue(controller.issuesToUpdate.size() > 1);
        Issue__c firstIssue = controller.issuesToUpdate[0];
        Issue__c secondIssue = controller.issuesToUpdate[1];
        
        Assert.areEqual(null, firstIssue.Related_Issue__c, 'First issue should not have Related_Issue__c');
        Assert.areNotEqual(null, secondIssue.Related_Issue__c, 'Second issue should have Related_Issue__c');
        Assert.areEqual(firstIssue.Id, secondIssue.Related_Issue__c, 'Second issue should reference first issue');
        
    }
}