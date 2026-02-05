public with sharing class RuleTriggerHandler {
    
    private static final String ERROR_MESSAGE_RULE_MAX_ACTIVE_RULES_REACHED = 'Max number of active rules reached: ';

    private static final Set<String> MAX_ACTIVE_RULE_TYPES = new Set<String>{
        Constants.RULE_SOBJECT.TYPE_MONITORING,
		Constants.RULE_SOBJECT.TYPE_ARCHIVAL,
		Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE,
		Constants.RULE_SOBJECT.TYPE_NOTIFICATION,
		Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS
    };
    
    public static void validateMaxActiveRules(List<Rule__c> newRules, Map<Id, Rule__c> oldRuleById) {
        Set<String> maxActiveRuleTypesToCheck = new Set<String>();
        List<Rule__c> rulesToValidateMaxActiveRules = new List<Rule__c>();
        for (Rule__c currentRule : newRules) {
            if (shouldValidateMaxActiveRules(currentRule, oldRuleById)) {
                maxActiveRuleTypesToCheck.add(currentRule.Type__c);
                rulesToValidateMaxActiveRules.add(currentRule);
            }
        }

        // Expand rule types for JIRA_UPDATE and AZURE_DEV_OPS to always include both
        maxActiveRuleTypesToCheck = expandRuleTypesForQuery(maxActiveRuleTypesToCheck);
        
        Map<String, List<Rule__c>> rulesByType = getRulesByType(maxActiveRuleTypesToCheck);
        for (Rule__c currentRule : rulesToValidateMaxActiveRules) {
            Integer countOfMaxLimitRulesForType = getCountOfMaxLimitRulesForType(currentRule.Type__c);
            if (countOfMaxLimitRulesForType == null) {
                continue;
            }

            Integer countOfExistingRules = getCountOfExistingRules(currentRule.Type__c, rulesByType);
            if (countOfExistingRules + 1 > countOfMaxLimitRulesForType) {
                currentRule.addError(ERROR_MESSAGE_RULE_MAX_ACTIVE_RULES_REACHED + countOfMaxLimitRulesForType);
            } else {
                if (!rulesByType.containsKey(currentRule.Type__c)) {
                    rulesByType.put(currentRule.Type__c, new List<Rule__c>());
                }

                rulesByType.get(currentRule.Type__c).add(currentRule);
            }
        }
    }

    private static Boolean shouldValidateMaxActiveRules(Rule__c rule, Map<Id, Rule__c> oldRuleById) {
        return rule.Active__c 
            && (
                oldRuleById == null 
                || rule.Active__c != oldRuleById.get(rule.Id).Active__c
            )
            && String.isNotBlank(rule.Type__c)
            && MAX_ACTIVE_RULE_TYPES.contains(rule.Type__c);
    }

    private static Integer getCountOfMaxLimitRulesForType(String type) {
        RuleUtil.RuleType ruleType = RuleUtil.MAP_RULE_TYPE.get(type);
        Integer limitRules = 100;
        switch on ruleType {
            when MONITORING {
                limitRules = LimitsService.getMaxMonitoringRules();
            }
            when ARCHIVAL {
                limitRules = LimitsService.getMaxArchivalRules();
            }
            when JIRA_UPDATE, AZURE_DEV_OPS {
                limitRules = LimitsService.getMaxJiraRules();
            }
            when NOTIFICATION {
                limitRules = LimitsService.getMaxNotificationRules();
            }
        }

        return limitRules;
    }

    private static Integer getCountOfExistingRules(String type, Map<String, List<Rule__c>> rulesByType) {
        if (isJiraUpdateOrAzureRule(type)) {
            List<Rule__c> jiraRules = rulesByType.get(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE);
            List<Rule__c> azureRules = rulesByType.get(Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS);
            return (jiraRules != null ? jiraRules.size() : 0) + (azureRules != null ? azureRules.size() : 0);
        } else {
            List<Rule__c> rules = rulesByType.get(type);
            return rules != null ? rules.size() : 0;
        }
    }

    private static Boolean isJiraUpdateOrAzureRule(String type) {
        return 
            Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE.equals(type) || Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS.equals(type);
    }

    private static Map<String, List<Rule__c>> getRulesByType(Set<String> ruleTypes) {
        Map<String, List<Rule__c>> rulesByType = new Map<String, List<Rule__c>>();
        for (Rule__c currentRule : getRulesByTypes(ruleTypes)) {
            if (!rulesByType.containsKey(currentRule.Type__c)) {
                rulesByType.put(currentRule.Type__c, new List<Rule__c>());
            }

            rulesByType.get(currentRule.Type__c).add(currentRule);
        }

        return rulesByType;
    }

    private static Set<String> expandRuleTypesForQuery(Set<String> ruleTypes) {
        Set<String> expandedTypes = new Set<String>(ruleTypes);
        if (ruleTypes.contains(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE) || 
            ruleTypes.contains(Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS)) {
            expandedTypes.add(Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE);
            expandedTypes.add(Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS);
        }
        return expandedTypes;
    }

    private static List<Rule__c> getRulesByTypes(Set<String> ruleTypes) {
        return [
            SELECT Type__c, Id
            FROM Rule__c
            WHERE Type__c IN :ruleTypes 
            AND Active__c = TRUE
        ];
    }
}