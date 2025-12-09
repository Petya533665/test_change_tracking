@IsTest
private class RuleExportImportServiceTest {

    private static final String SOBJECT_ISSUE_NAME = SObjectType.Issue__c.getName();
    
    @TestSetup
    static void setupTestData() {
        // Create test Actions
        List<Action__c> actions = new List<Action__c>{
            new Action__c(
                Name__c = 'Test Action 1',
                Action_Type__c = 'Email Notification',
                SobjectType__c = SOBJECT_ISSUE_NAME,
                Description__c = 'Test Action 1 Description'
            ),
            new Action__c(
                Name__c = 'Test Action 2',
                Action_Type__c = 'Slack Notification',
                SobjectType__c = SOBJECT_ISSUE_NAME,
                Description__c = 'Test Action 2 Description'
            ),
            new Action__c(
                Name__c = 'Test Action 3',
                Action_Type__c = 'Teams Notification',
                SobjectType__c = SOBJECT_ISSUE_NAME,
                Description__c = 'Test Action 3 Description'
            )
        };
        insert actions;
        
        // Create test Rules
        List<Rule__c> rules = new List<Rule__c>{
            new Rule__c(
                Description__c = 'Test Description 1',
                Active__c = true,
                Name__c = 'TEST_RULE_1',
                Index__c = 1,
                Type__c = 'Monitoring',
                SobjectType__c = SOBJECT_ISSUE_NAME
            ),
            new Rule__c(
                Description__c = 'Test Description 2',
                Active__c = false,
                Name__c = 'TEST_RULE_2',
                Index__c = 2,
                Type__c = 'Monitoring',
                SobjectType__c = SOBJECT_ISSUE_NAME
            )
        };
        insert rules;
        
        // Create test RuleFilters
        List<RuleFilter__c> filters = new List<RuleFilter__c>{
            new RuleFilter__c(
                Rule__c = rules[0].Id,
                FieldName__c = 'Name',
                ComparisonOperator__c = 'equals',
                Value__c = 'Test'
            ),
            new RuleFilter__c(
                Rule__c = rules[1].Id,
                FieldName__c = 'Email',
                ComparisonOperator__c = 'contains',
                Value__c = '@test.com'
            )
        };
        insert filters;
        
        // Create test RuleActions
        List<RuleAction__c> ruleActions = new List<RuleAction__c>{
            new RuleAction__c(
                Rule__c = rules[0].Id,
                Action__c = actions[0].Id
            ),
            new RuleAction__c(
                Rule__c = rules[0].Id,
                Action__c = actions[1].Id
            ),
            new RuleAction__c(
                Rule__c = rules[1].Id,
                Action__c = actions[2].Id
            )
        };
        insert ruleActions;
    }

    @IsTest
    static void testDeleteAllRules() {
        RuleExportImportService.deleteAllRules();

        Assert.areEqual(0, [SELECT Id FROM Rule__c].size(), 'Number of Rules does not match');
        Assert.areEqual(0, [SELECT Id FROM Action__c].size(), 'Number of Actions does not match');
    }

    @IsTest
    static void testGetRuleWizardData() {
        List<RuleExportImportService.RuleExportImportWizardWrapper> wrappers = RuleExportImportService.getRuleWizardData();

        List<Rule__c> rules = [SELECT Id FROM Rule__c ORDER BY Index__c];
        Assert.areEqual(rules.size(), wrappers.size(), 'Number of wizard records does not match');
        Assert.areEqual(rules.get(0).Id, wrappers.get(0).ruleId, 'Rule Id does not match');
        Assert.areEqual(rules.get(1).Id, wrappers.get(1).ruleId, 'Rule Id does not match');
    }

    @IsTest
    static void testExportRulesWithNullOrEmptyRuleIds() {
        Assert.isTrue(RuleExportImportService.exportRules(null).isEmpty(), 'List of exported rules is not empty');
        Assert.isTrue(RuleExportImportService.exportRules(new List<String>()).isEmpty(), 'List of exported rules is not empty');
    }

    @IsTest
    static void testExportRulesWithInvaliedRuleIdsToCatchException() {
        List<RuleExportImportService.RuleExportImportWrapper> wrappers = RuleExportImportService.exportRules(new List<String>{ 'InvalidId' });
        Test.startTest();
            Logger.getInstance().flush();
        Test.stopTest();
        
        Assert.areEqual(1, [SELECT Id FROM Log__c].size(), 'Number of Logs does not match');
    }
    
    @IsTest
    static void testExportRules() { 
        List<String> ruleIds = new List<String>();
        for (Rule__c currentRule : [SELECT Id FROM Rule__c]) {
            ruleIds.add(currentRule.Id);
        }
        
        List<RuleExportImportService.RuleExportImportWrapper> wrappers = RuleExportImportService.exportRules(ruleIds);
        
        // Find and Verify first rule (TEST_RULE_1)
        RuleExportImportService.RuleExportImportWrapper wrapperForRule1 = null;
        for (RuleExportImportService.RuleExportImportWrapper w : wrappers) {
            if (w.rule != null && w.rule.Name__c.equals('TEST_RULE_1')) {
                wrapperForRule1 = w;
                break;
            }
        }
        Assert.areNotEqual(null, wrapperForRule1, 'Wrapper for TEST_RULE_1 not found in deserialized data');
        
        Rule__c originalRule1 = [
            SELECT Id, Description__c, Active__c, Name__c, Index__c, Type__c, SobjectType__c,
                   (SELECT Id, Action__c FROM RuleActions__r ORDER BY Action__r.Name__c), // Order for consistency
                   (SELECT Id, FieldName__c, ComparisonOperator__c, Value__c FROM RuleFilters__r ORDER BY FieldName__c) // Order for consistency
            FROM Rule__c
            WHERE Name__c = 'TEST_RULE_1'
        ];
        
        // Verify Rule fields
        Assert.areEqual(originalRule1.Description__c, wrapperForRule1.rule.Description__c, 'Rule description should match');
        Assert.areEqual(originalRule1.Active__c, wrapperForRule1.rule.Active__c, 'Rule active status should match');
        Assert.areEqual(originalRule1.Name__c, wrapperForRule1.rule.Name__c, 'Rule name should match');
        Assert.areEqual(originalRule1.Index__c, wrapperForRule1.rule.Index__c, 'Rule index should match');
        Assert.areEqual(originalRule1.Type__c, wrapperForRule1.rule.Type__c, 'Rule type should match');
        // Note: SobjectType__c is not queried in exportRules, so we skip this assertion
        
        // Verify RuleActions
        Assert.areEqual(originalRule1.RuleActions__r.size(), wrapperForRule1.ruleActions.size(), 'Rule TEST_RULE_1 should have correct number of rule actions');
        
        // Verify RuleFilters
        Assert.areEqual(originalRule1.RuleFilters__r.size(), wrapperForRule1.ruleFilters.size(), 'Rule TEST_RULE_1 should have correct number of filters');
        if (!originalRule1.RuleFilters__r.isEmpty() && !wrapperForRule1.ruleFilters.isEmpty()){
            RuleFilter__c originalFilter1 = originalRule1.RuleFilters__r[0];
            RuleFilter__c exportedFilter1 = wrapperForRule1.ruleFilters[0]; // Assumes order is preserved by export/deserialize
            Assert.areEqual(originalFilter1.FieldName__c, exportedFilter1.FieldName__c, 'Filter field should match');
            Assert.areEqual(originalFilter1.ComparisonOperator__c, exportedFilter1.ComparisonOperator__c, 'Filter operator should match');
            Assert.areEqual(originalFilter1.Value__c, exportedFilter1.Value__c, 'Filter value should match');
        }
        
        // Verify Actions in the map for wrapperForRule1
        Assert.areEqual(originalRule1.RuleActions__r.size(), wrapperForRule1.actions.size(), 'Rule TEST_RULE_1 wrapper should have correct number of actions in map');
        Set<Id> originalRule1ActionIds = new Set<Id>();
        for (RuleAction__c ra : originalRule1.RuleActions__r) {
            originalRule1ActionIds.add(ra.Action__c);
        }

        // Get original data for comparison
        Map<Id, Action__c> originalActions = new Map<Id, Action__c>([
            SELECT Id, Name__c, Action_Type__c, SobjectType__c, Description__c
            FROM Action__c
        ]);
        for (Id actionIdInWrapper : wrapperForRule1.actions.keySet()) {
            Assert.isTrue(originalRule1ActionIds.contains(actionIdInWrapper), 'Action ID from wrapper map (' + actionIdInWrapper + ') not found in original rule actions for TEST_RULE_1');
            Action__c originalAction = originalActions.get(actionIdInWrapper);
            Action__c exportedAction = wrapperForRule1.actions.get(actionIdInWrapper);
            Assert.areNotEqual(null, originalAction, 'Original action for ID ' + actionIdInWrapper + ' not found in map');
            Assert.areNotEqual(null, exportedAction, 'Exported action for ID ' + actionIdInWrapper + ' not found in wrapper');
            Assert.areEqual(originalAction.Name__c, exportedAction.Name__c, 'Action name should match');
            Assert.areEqual(originalAction.Action_Type__c, exportedAction.Action_Type__c, 'Action type should match');
            Assert.areEqual(originalAction.SobjectType__c, exportedAction.SobjectType__c, 'Action sobject type should match');
            Assert.areEqual(originalAction.Description__c, exportedAction.Description__c, 'Action description should match');
        }
    }
    
    @IsTest
    static void testImportRules() {
        PermissionsUtil.RuleImportExport = true;
        // Store original data for comparison before any export or deletion
        Map<String, Rule__c> originalRulesByName = new Map<String, Rule__c>();
        List<String> ruleIds = new List<String>();
        for (Rule__c rule : [
            SELECT Id, Description__c, Active__c, Name__c, Index__c, Type__c, SobjectType__c,
                   (SELECT Id, Action__c, Action__r.Name__c, Action__r.Action_Type__c, Action__r.SobjectType__c, Action__r.Description__c FROM RuleActions__r ORDER BY Action__r.Name__c), 
                   (SELECT Id, FieldName__c, ComparisonOperator__c, Value__c FROM RuleFilters__r ORDER BY FieldName__c) 
            FROM Rule__c
            ORDER BY Name__c // Order rules themselves for predictable originalRulesByName keyset iteration if needed
        ]) {
            originalRulesByName.put(rule.Name__c, rule);
            ruleIds.add(rule.Id);
        }

        String jsonStr = JSON.serialize(RuleExportImportService.exportRules(ruleIds));

        RuleExportImportService.deleteAllRules();

        // Verify deletion before import
        Assert.areEqual(0, [SELECT COUNT() FROM Rule__c], 'All rules should be deleted before import');
        Assert.areEqual(0, [SELECT COUNT() FROM Action__c], 'All actions should be deleted before import');
        Assert.areEqual(0, [SELECT COUNT() FROM RuleAction__c], 'All rule actions should be deleted before import');
        Assert.areEqual(0, [SELECT COUNT() FROM RuleFilter__c], 'All rule filters should be deleted before import');

        
        RuleExportImportService.importRules(jsonStr);
        
        // Verify imported rules by querying them back from the DB
        List<Rule__c> importedDbRules = [
            SELECT Id, Description__c, Active__c, Name__c, Index__c, Type__c, SobjectType__c,
                   (SELECT Id, Action__c, Action__r.Name__c, Action__r.Action_Type__c, Action__r.SobjectType__c, Action__r.Description__c FROM RuleActions__r ORDER BY Action__r.Name__c),
                   (SELECT Id, FieldName__c, ComparisonOperator__c, Value__c FROM RuleFilters__r ORDER BY FieldName__c)
            FROM Rule__c
            ORDER BY Name__c // Order main rules for consistent iteration and comparison
        ];
        
        Assert.areEqual(originalRulesByName.size(), importedDbRules.size(), 
            'Should import same number of rules as originally existed. Expected: ' + originalRulesByName.size() + ', Actual: ' + importedDbRules.size());
        
        // Verify each imported rule and its related records
        for (Rule__c importedRule : importedDbRules) {
            Rule__c originalRule = originalRulesByName.get(importedRule.Name__c);
            Assert.areNotEqual(null, originalRule, 'Should find original rule for name: ' + importedRule.Name__c);
            
            // Verify Rule fields
            Assert.areEqual(originalRule.Description__c, importedRule.Description__c, 'Rule description should match for ' + importedRule.Name__c);
            Assert.areEqual(originalRule.Active__c, importedRule.Active__c, 'Rule active status should match for ' + importedRule.Name__c);
            Assert.areEqual(originalRule.Index__c, importedRule.Index__c, 'Rule index should match for ' + importedRule.Name__c);
            Assert.areEqual(originalRule.Type__c, importedRule.Type__c, 'Rule type should match for ' + importedRule.Name__c);
            // Note: SobjectType__c is not queried in exportRules, so we skip this assertion
            
            // Verify RuleActions (count and content via Action Name)
            Assert.areEqual(originalRule.RuleActions__r.size(), importedRule.RuleActions__r.size(), 
                'Rule ' + importedRule.Name__c + ' should have ' + originalRule.RuleActions__r.size() + ' actions');
            
            for (Integer i = 0; i < originalRule.RuleActions__r.size(); i++) {
                RuleAction__c originalRA = originalRule.RuleActions__r[i];
                RuleAction__c importedRA = importedRule.RuleActions__r[i]; // Relies on ORDER BY Action__r.Name__c
                
                Assert.areEqual(originalRA.Action__r.Name__c, importedRA.Action__r.Name__c, 'Action name for RuleAction should match for rule ' + importedRule.Name__c);
                // Since actions are recreated by import, compare their details
                Assert.areEqual(originalRA.Action__r.Action_Type__c, importedRA.Action__r.Action_Type__c, 'Action Type should match for action ' + importedRA.Action__r.Name__c);
                Assert.areEqual(originalRA.Action__r.SobjectType__c, importedRA.Action__r.SobjectType__c, 'SobjectType should match for action ' + importedRA.Action__r.Name__c);
                Assert.areEqual(originalRA.Action__r.Description__c, importedRA.Action__r.Description__c, 'Description should match for action ' + importedRA.Action__r.Name__c);
            }
            
            // Verify RuleFilters (count and content)
            Assert.areEqual(originalRule.RuleFilters__r.size(), importedRule.RuleFilters__r.size(), 
                'Rule ' + importedRule.Name__c + ' should have same number of filters');
            for (Integer i = 0; i < importedRule.RuleFilters__r.size(); i++) {
                RuleFilter__c originalRF = originalRule.RuleFilters__r[i];
                RuleFilter__c importedRF = importedRule.RuleFilters__r[i]; // Relies on ORDER BY FieldName__c

                Assert.areEqual(originalRF.FieldName__c, importedRF.FieldName__c, 'Filter field should match for ' + importedRule.Name__c);
                Assert.areEqual(originalRF.ComparisonOperator__c, importedRF.ComparisonOperator__c, 'Filter operator should match for ' + importedRule.Name__c);
                Assert.areEqual(originalRF.Value__c, importedRF.Value__c, 'Filter value should match for ' + importedRule.Name__c);
            }
        }
    }

    @IsTest
    static void testImportRulesWithInvalidJson() {
        PermissionsUtil.RuleImportExport = true;
        Test.startTest();
            List<Rule__c> importedRules = RuleExportImportService.importRules('{');
            Logger.getInstance().flush();
        Test.stopTest();
        
        Assert.areEqual(1, [SELECT Id FROM Log__c].size(), 'Number of Logs does not match');

        Assert.areNotEqual(null, importedRules, 'Imported rules list should not be null.');
        Assert.areEqual(0, importedRules.size(), 'Should return an empty list of rules for empty wrapper list.');
    }

    @IsTest
    static void testImportRulesWithBlankJson() {
        PermissionsUtil.RuleImportExport = true;
        Test.startTest();
        List<Rule__c> importedRules = RuleExportImportService.importRules('');
        Test.stopTest();

        Assert.areNotEqual(null, importedRules, 'Imported rules list should not be null.');
        Assert.areEqual(0, importedRules.size(), 'Should return an empty list of rules for empty wrapper list.');
    }

    @IsTest
    static void testImportRulesWithEmptyWrappers() {
        PermissionsUtil.RuleImportExport = true;
        Test.startTest();
        List<Rule__c> importedRules = RuleExportImportService.importRules(JSON.serialize(new List<RuleExportImportService.RuleExportImportWrapper>()));
        Test.stopTest();

        Assert.areNotEqual(null, importedRules, 'Imported rules list should not be null.');
        Assert.areEqual(0, importedRules.size(), 'Should return an empty list of rules for empty wrapper list.');
    }
}