@IsTest
public with sharing class RuleTriggerHelperTest {
    
    @IsTest
    static void test_validateMaxActiveRules_successfulActivation_monitoring() {
        // Setup: Set limit to 5 monitoring rules
        PermissionsUtil.MaxMonitoringRules = 5;
        
        // Create 4 existing active monitoring rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 4; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test Monitoring Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
                Index__c = i + 1
            ));
        }
        insert existingRules;
        
        Test.startTest();
        
        // Try to activate a new monitoring rule (should succeed - 4 + 1 = 5, which is <= 5)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 5
        );
        
        // Insert should succeed without errors
        insert newRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(1, insertedRules.size(), 'Rule should be inserted successfully when limit is not exceeded');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_limitExceeded_monitoring() {
        // Setup: Set limit to 5 monitoring rules
        PermissionsUtil.MaxMonitoringRules = 5;
        
        // Create 5 existing active monitoring rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 5; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test Monitoring Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
                Index__c = i + 1
            ));
        }
        insert existingRules;
        
        Test.startTest();
        
        // Try to activate a new monitoring rule (should fail - 5 + 1 = 6, which is > 5)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 6
        );
        
        // Insert should fail with error
        try {
            insert newRule;
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Max number of active rules reached: 5'), 
                'Error message should contain limit value');
        }
        
        // Verify rule was not inserted
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(0, insertedRules.size(), 'Rule should not be inserted when limit is exceeded');
        
        Test.stopTest();
    }
    
    @IsTest
    static void test_validateMaxActiveRules_updateFromInactiveToActive() {
        // Setup: Set limit to 3 archival rules
        PermissionsUtil.MaxArchivalRules = 3;
        
        // Create 2 existing active archival rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 2; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test Archival Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_ARCHIVAL,
                Index__c = i + 1
            ));
        }
        insert existingRules;
        
        // Create an inactive rule
        Rule__c inactiveRule = new Rule__c(
            Name__c = 'Inactive Archival Rule',
            Active__c = false,
            Type__c = Constants.RULE_SOBJECT.TYPE_ARCHIVAL,
            Index__c = 3
        );
        insert inactiveRule;
        
        Test.startTest();
        
        // Activate the inactive rule (should succeed - 2 + 1 = 3, which is <= 3)
        inactiveRule.Active__c = true;
        update inactiveRule;
        
        Test.stopTest();
        
        // Verify rule was updated successfully
        Rule__c updatedRule = [SELECT Active__c FROM Rule__c WHERE Id = :inactiveRule.Id];
        Assert.isTrue(updatedRule.Active__c, 'Rule should be activated successfully when within limit');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_jiraUpdateAndAzureShareLimit() {
        // Setup: Set limit to 4 jira rules (shared between JIRA_UPDATE and AZURE_DEV_OPS)
        PermissionsUtil.MaxJiraRules = 4;
        
        // Create 2 existing active JIRA_UPDATE rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 2; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test JIRA Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE,
                Index__c = i + 1
            ));
        }
        // Create 1 existing active AZURE_DEV_OPS rule
        existingRules.add(new Rule__c(
            Name__c = 'Test Azure Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS,
            Index__c = 3
        ));
        insert existingRules;
        
        Test.startTest();
        
        // Try to activate a new AZURE_DEV_OPS rule (should succeed - 2 + 1 + 1 = 4, which is <= 4)
        Rule__c newAzureRule = new Rule__c(
            Name__c = 'New Azure Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS,
            Index__c = 4
        );
        
        insert newAzureRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newAzureRule.Id];
        Assert.areEqual(1, insertedRules.size(), 
            'Should insert successfully when JIRA_UPDATE and AZURE_DEV_OPS share limit and total is within limit');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_jiraUpdateAndAzureExceedLimit() {
        // Setup: Set limit to 3 jira rules
        PermissionsUtil.MaxJiraRules = 3;
        
        // Create 2 existing active JIRA_UPDATE rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 2; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test JIRA Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE,
                Index__c = i + 1
            ));
        }
        // Create 1 existing active AZURE_DEV_OPS rule
        existingRules.add(new Rule__c(
            Name__c = 'Test Azure Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS,
            Index__c = 3
        ));
        insert existingRules;
        
        Test.startTest();
        
        // Try to activate a new JIRA_UPDATE rule (should fail - 2 + 1 + 1 = 4, which is > 3)
        Rule__c newJiraRule = new Rule__c(
            Name__c = 'New JIRA Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE,
            Index__c = 4
        );
        
        // Insert should fail with error
        try {
            insert newJiraRule;
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Max number of active rules reached: 3'), 
                'Error message should contain limit value');
        }
        
        // Verify rule was not inserted
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newJiraRule.Id];
        Assert.areEqual(0, insertedRules.size(), 
            'Rule should not be inserted when JIRA_UPDATE and AZURE_DEV_OPS combined exceed shared limit');
        
        Test.stopTest();
    }
    
    @IsTest
    static void test_validateMaxActiveRules_notificationRule() {
        // Setup: Set limit to 2 notification rules
        PermissionsUtil.MaxNotificationRules = 2;
        
        // Create 1 existing active notification rule
        Rule__c existingRule = new Rule__c(
            Name__c = 'Test Notification Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_NOTIFICATION,
            Index__c = 1
        );
        insert existingRule;
        
        Test.startTest();
        
        // Try to activate a new notification rule (should succeed - 1 + 1 = 2, which is <= 2)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Notification Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_NOTIFICATION,
            Index__c = 2
        );
        
        insert newRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(1, insertedRules.size(), 'Should insert successfully for notification rule within limit');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_unlimitedLimit() {
        // Setup: Set limit to 0 (unlimited)
        PermissionsUtil.MaxMonitoringRules = 0;
        
        // Create 10 existing active monitoring rules
        List<Rule__c> existingRules = new List<Rule__c>();
        for (Integer i = 0; i < 10; i++) {
            existingRules.add(new Rule__c(
                Name__c = 'Test Monitoring Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
                Index__c = i + 1
            ));
        }
        insert existingRules;
        
        Test.startTest();
        
        // Try to activate a new monitoring rule (should succeed - unlimited)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 11
        );
        
        insert newRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(1, insertedRules.size(), 'Should insert successfully when limit is unlimited (0)');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_doesNotValidateInactiveRule() {
        // Setup: Set limit to 1 monitoring rule
        PermissionsUtil.MaxMonitoringRules = 1;
        
        // Create 1 existing active monitoring rule
        Rule__c existingRule = new Rule__c(
            Name__c = 'Test Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 1
        );
        insert existingRule;
        
        Test.startTest();
        
        // Try to create an inactive rule (should not validate)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Inactive Monitoring Rule',
            Active__c = false,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 2
        );
        
        insert newRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully (validation should not run for inactive rules)
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(1, insertedRules.size(), 'Should insert inactive rules without validation');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_doesNotValidateWhenAlreadyActive() {
        // Setup: Set limit to 1 monitoring rule
        PermissionsUtil.MaxMonitoringRules = 1;
        
        // Create an active rule
        Rule__c existingRule = new Rule__c(
            Name__c = 'Test Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 1
        );
        insert existingRule;
        
        Test.startTest();
        
        // Update the rule but keep it active (should not validate)
        existingRule.Name__c = 'Updated Name';
        update existingRule;
        
        Test.stopTest();
        
        // Verify rule was updated successfully (validation should not run when rule stays active)
        Rule__c updatedRule = [SELECT Name__c FROM Rule__c WHERE Id = :existingRule.Id];
        Assert.areEqual('Updated Name', updatedRule.Name__c, 
            'Should update successfully when rule was already active and remains active');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_multipleRulesSimultaneously() {
        // Setup: Set limit to 3 monitoring rules
        PermissionsUtil.MaxMonitoringRules = 3;
        
        // Create 1 existing active monitoring rule
        Rule__c existingRule = new Rule__c(
            Name__c = 'Test Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 1
        );
        insert existingRule;
        
        Test.startTest();
        
        // Try to activate 2 new monitoring rules simultaneously (should succeed - 1 + 2 = 3, which is <= 3)
        List<Rule__c> newRules = new List<Rule__c>();
        for (Integer i = 0; i < 2; i++) {
            newRules.add(new Rule__c(
                Name__c = 'New Monitoring Rule ' + i,
                Active__c = true,
                Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
                Index__c = i + 2
            ));
        }
        
        insert newRules;
        
        Test.stopTest();
        
        // Verify rules were inserted successfully
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id IN :newRules];
        Assert.areEqual(2, insertedRules.size(), 
            'Should insert multiple rules successfully when activated simultaneously within limit');
    }
    
    @IsTest
    static void test_validateMaxActiveRules_doesNotValidateNonMaxActiveRuleTypes() {
        // Setup: Set limit to 1 monitoring rule
        PermissionsUtil.MaxMonitoringRules = 1;
        
        // Create 1 existing active monitoring rule
        Rule__c existingRule = new Rule__c(
            Name__c = 'Test Monitoring Rule',
            Active__c = true,
            Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING,
            Index__c = 1
        );
        insert existingRule;
        
        Test.startTest();
        
        // Try to create a rule with a type that is not in MAX_ACTIVE_RULE_TYPES (should not validate)
        Rule__c newRule = new Rule__c(
            Name__c = 'New Rule',
            Active__c = true,
            Type__c = 'SomeOtherType', // Not in MAX_ACTIVE_RULE_TYPES
            Index__c = 2
        );
        
        insert newRule;
        
        Test.stopTest();
        
        // Verify rule was inserted successfully (validation should not run for non-max-active rule types)
        List<Rule__c> insertedRules = [SELECT Id FROM Rule__c WHERE Id = :newRule.Id];
        Assert.areEqual(1, insertedRules.size(), 
            'Should insert successfully for rules with types not in MAX_ACTIVE_RULE_TYPES');
    }
}