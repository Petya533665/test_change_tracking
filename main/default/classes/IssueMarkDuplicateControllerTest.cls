@IsTest
public with sharing class IssueMarkDuplicateControllerTest {
    
    @TestSetup
    static void testSetup() {
        // Create test issues
        List<Issue__c> issues = new List<Issue__c>();
        
        // Create main issue (will remain as primary)
        Issue__c mainIssue = new Issue__c();
        mainIssue.Status__c = 'New';
        mainIssue.Summary__c = 'Main Issue';
        issues.add(mainIssue);
        
        // Create duplicate issue (already marked as duplicate)
        Issue__c duplicateIssue = new Issue__c();
        duplicateIssue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
        duplicateIssue.Summary__c = 'Duplicate Issue';
        issues.add(duplicateIssue);
        
        // Create regular issues to be marked as duplicates
        Issue__c regularIssue1 = new Issue__c();
        regularIssue1.Status__c = 'New';
        regularIssue1.Summary__c = 'Regular Issue 1';
        issues.add(regularIssue1);
        
        Issue__c regularIssue2 = new Issue__c();
        regularIssue2.Status__c = 'In Progress';
        regularIssue2.Summary__c = 'Regular Issue 2';
        issues.add(regularIssue2);
        
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
        log2.Issue__c = regularIssue1.Id;
        log2.Type__c = 'ERROR';
        log2.Category__c = 'Apex';
        logs.add(log2);
        
        Log__c log3 = new Log__c();
        log3.Issue__c = duplicateIssue.Id;
        log3.Type__c = 'ERROR';
        log3.Category__c = 'Apex';
        logs.add(log3);
        
        insert logs;
    }
    
    @IsTest
    static void test_constructor_withSelectedIssues() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areNotEqual(0, controller.issuesToUpdate.size(), 'Should have issues to update');
    }
    
    @IsTest
    static void test_constructor_excludesDuplicateIssues() {
        List<Issue__c> allIssues = [SELECT Id FROM Issue__c];
        
        // Create StandardSetController mock with all issues (including duplicates)
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(allIssues);
        setController.setSelected(allIssues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        
        Integer originalNonDuplicateCount = [SELECT COUNT() FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE];
        
        Assert.areEqual(originalNonDuplicateCount, controller.issuesToUpdate.size(), 'Should process all non-duplicate issues');
    }
    
    @IsTest
    static void test_constructor_withEmptySelection() {
        List<Issue__c> issues = new List<Issue__c>();
        
        // Create StandardSetController mock with empty selection
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areEqual(0, controller.issuesToUpdate.size(), 'Should have no issues to update when selection is empty');
    }
    
    @IsTest
    static void test_constructor_withOnlyDuplicateIssues() {
        List<Issue__c> duplicateIssues = [SELECT Id FROM Issue__c WHERE Status__c = :IssueService.ISSUE_STATUS_DUPLICATE];
        
        // Create StandardSetController mock with only duplicate issues
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(duplicateIssues);
        setController.setSelected(duplicateIssues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areEqual(0, controller.issuesToUpdate.size(), 'Should have no issues to update when only duplicates are selected');
    }
    
    @IsTest
    static void test_updateIssues_success() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should be true after update');
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
    }
    
    @IsTest
    static void test_updateIssues_alreadyProcessing() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        controller.isProcessing = true; // Set to already processing
        
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should remain true');
    }
    
    @IsTest
    static void test_updateIssues_withManyLogs() {
        // Create additional logs to exceed the limit
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE];
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
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        PageReference result = controller.updateIssues();
        Test.stopTest();
        
        // PageReference may be null in test context, so we check the controller state instead
        Assert.isTrue(controller.isProcessing, 'isProcessing should be true after update');
    }
    
    @IsTest
    static void test_doRedirect() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE LIMIT 1];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        PageReference result = controller.doRedirect();
        Test.stopTest();
        
        // PageReference may be null in test context, so we just verify the method executes without error
        Assert.areNotEqual(null, controller, 'controller should not be null');
    }
    
    @IsTest
    static void test_issuesToUpdate_property() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE LIMIT 2];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        List<Issue__c> issuesToUpdate = controller.issuesToUpdate;
        Test.stopTest();
        
        Assert.areNotEqual(null, issuesToUpdate, 'issuesToUpdate property should not be null');
        Assert.areNotEqual(0, issuesToUpdate.size(), 'issuesToUpdate should contain issues');
    }
    
    @IsTest
    static void test_constructor_duplicateLinkingLogic() {
        List<Issue__c> issues = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE];
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        
        // Verify that issues are properly linked (first issue should not have Related_Issue__c, others should)
        Assert.isTrue(controller.issuesToUpdate.size() > 1);
        Issue__c firstIssue = controller.issuesToUpdate[0];
        Issue__c secondIssue = controller.issuesToUpdate[1];
        
        Assert.areEqual(null, firstIssue.Related_Issue__c, 'First issue should not have Related_Issue__c');
        Assert.areNotEqual(null, secondIssue.Related_Issue__c, 'Second issue should have Related_Issue__c');
        Assert.areEqual(firstIssue.Id, secondIssue.Related_Issue__c, 'Second issue should reference first issue');
        Assert.areEqual(IssueService.ISSUE_STATUS_DUPLICATE, secondIssue.Status__c, 'Second issue should be marked as duplicate');
        
    }
    
    @IsTest
    static void test_constructor_singleIssue() {
        List<Issue__c> singleIssue = [SELECT Id FROM Issue__c WHERE Status__c != :IssueService.ISSUE_STATUS_DUPLICATE LIMIT 1];
        
        // Create StandardSetController mock with single issue
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(singleIssue);
        setController.setSelected(singleIssue);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areEqual(1, controller.issuesToUpdate.size(), 'Should have exactly one issue');
        
        Issue__c issue = controller.issuesToUpdate[0];
        Assert.areEqual(null, issue.Related_Issue__c, 'Single issue should not have Related_Issue__c');
        Assert.areNotEqual(IssueService.ISSUE_STATUS_DUPLICATE, issue.Status__c, 'Single issue should not be marked as duplicate');
    }
    
    @IsTest
    static void test_constructor_orderingByCreatedDate() {
        // Create issues with different CreatedDate values
        List<Issue__c> issues = new List<Issue__c>();
        
        Issue__c issue1 = new Issue__c();
        issue1.Status__c = 'New';
        issue1.Summary__c = 'Issue 1';
        issues.add(issue1);
        
        Issue__c issue2 = new Issue__c();
        issue2.Status__c = 'New';
        issue2.Summary__c = 'Issue 2';
        issues.add(issue2);
        
        insert issues;
        
        // Create StandardSetController mock
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(issues);
        setController.setSelected(issues);
        
        Test.startTest();
        IssueMarkDuplicateController controller = new IssueMarkDuplicateController(setController);
        Test.stopTest();
        
        Assert.areNotEqual(null, controller.issuesToUpdate, 'issuesToUpdate should not be null');
        Assert.areEqual(2, controller.issuesToUpdate.size(), 'Should have two issues');
        
        // Verify ordering (should be ordered by CreatedDate)
        Issue__c firstIssue = controller.issuesToUpdate[0];
        Issue__c secondIssue = controller.issuesToUpdate[1];
        
        Assert.areEqual(null, firstIssue.Related_Issue__c, 'First issue should not have Related_Issue__c');
        Assert.areNotEqual(null, secondIssue.Related_Issue__c, 'Second issue should have Related_Issue__c');
        Assert.areEqual(firstIssue.Id, secondIssue.Related_Issue__c, 'Second issue should reference first issue');
    }
}