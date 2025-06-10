public with sharing class RuleExportImportService {
    
    // system fields to exclude from export
    private static final Set<String> SYSTEM_FIELDS = new Set<String>{
        'id', 'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 
        'lastmodifiedbyid', 'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 
        'lastreferenceddate', 'ownerid', 'currencyisocode'
    };

    private static final Id RECORD_TYPE_ID_ACTION_MONITORING = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get('Monitoring').getRecordtypeId();

    public static List<RuleExportImportWizardWrapper> getRuleWizardData() {
        List<RuleExportImportWizardWrapper> wrappers = new List<RuleExportImportWizardWrapper>();
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        try {
            for (Rule__c currentRule : getRules(null, RuleUtil.RULE_TYPES_FOR_IMPORT_EXPORT, true, true)) {
                wrappers.add(new RuleExportImportWizardWrapper(currentRule, globalDescribeMap));
            }
        } catch (Exception e) {
            debugSession(e, 'getRuleWizardData');
        }

        return wrappers;
    }

    /**
     * Delete all rules and actions,
     * used to clean up before importing new rules or for testing
     */
    public static void deleteAllRules() {
        Logger loggerInstance = Logger.getInstance();
        DatabaseUtils.getInstance().performDeleteDML([SELECT Id FROM Rule__c], Schema.SObjectType.Rule__c)
                .handleError(RuleExportImportService.class.getName(), '.deleteAllRules', loggerInstance);
        DatabaseUtils.getInstance().performDeleteDML([SELECT Id FROM Action__c], Schema.SObjectType.Action__c)
                .handleError(RuleExportImportService.class.getName(), '.deleteAllRules', loggerInstance);
    }

    /**
     * Export rules,
     * used to export rules
     */
    public static List<RuleExportImportWrapper> exportRules(List<String> ruleIds) {
        if (ruleIds == null || ruleIds.isEmpty()) {
            return new List<RuleExportImportWrapper>();
        }

        List<RuleExportImportWrapper> exportData = new List<RuleExportImportWrapper>();
        try {
            List<Rule__c> rules = getRules(ruleIds, null, false, false);
            List<String> actionIds = getActionIdsFromRuleActions(rules);
            Map<Id, Action__c> actionsMap = getActionMap(actionIds);        

            // Build export wrappers
            for (Rule__c currentRule : rules) {
                RuleExportImportWrapper wrapper = new RuleExportImportWrapper(currentRule);

                // Clone RuleActions
                for (RuleAction__c currentRuleAction : currentRule.RuleActions__r) {
                    wrapper.ruleActions.add(currentRuleAction.clone(false, true));

                    // Store associated Action
                    if (String.isNotBlank(currentRuleAction.Action__c) && actionsMap.containsKey(currentRuleAction.Action__c)) {
                        wrapper.actions.put(currentRuleAction.Action__c, actionsMap.get(currentRuleAction.Action__c).clone(false, true));
                    }
                    
                }
                
                // Clone RuleFilters
                for (RuleFilter__c currentRuleFilter : currentRule.RuleFilters__r) {
                    wrapper.ruleFilters.add(currentRuleFilter.clone(false, true));
                }
                
                exportData.add(wrapper);
            }
        } catch (Exception e) {
           debugSession(e, 'exportRules');
        }

        return exportData;
    }

    /**
     * Import rules,
     * used to import rules
     */
    public static List<Rule__c> importRules(String jsonStr) {
        if (String.isBlank(jsonStr)) {
            return new List<Rule__c>();
        }

        List<RuleExportImportWrapper> wrappers = new List<RuleExportImportWrapper>();
        try {
            wrappers = deserializeFromJson(jsonStr);
        } catch (Exception e) {
            debugSession(e, 'importRules');
        }

        if (wrappers == null || wrappers.isEmpty()) {
            return new List<Rule__c>();
        }

        RuleImportHelper ruleImportHelper;

        try {
            ruleImportHelper = new RuleImportHelper(wrappers);
            ruleImportHelper.runRulesImport();
        } catch (Exception e) {
            debugSession(e, 'importRules');
        }

        return ruleImportHelper.getNewRules();
    }

    private static List<String> getActionIdsFromRuleActions(List<Rule__c> rules) {
        // Get all Action IDs from RuleActions
        List<String> actionIds = new List<String>();
        for (Rule__c currentRule : rules) {
            for (RuleAction__c currentRuleAction : currentRule.RuleActions__r) {
                Boolean isActionIdNeeded = 
                    String.isNotBlank(currentRuleAction.Action__c) 
                    && !actionIds.contains(currentRuleAction.Action__c);

                if (isActionIdNeeded) {
                    actionIds.add(currentRuleAction.Action__c);
                }
            }
        }

        return actionIds;
    }

    public static List<Rule__c> getRules(List<String> ruleIds, List<String> ruleTypes, Boolean isOrderingNeeded, Boolean isRelationsipFieldNeeded) {
        String query = new QBuilder(Rule__c.SObjectType)
            .selectFields(buildSelectClause(
                    Rule__c.SObjectType,
                    isRelationsipFieldNeeded ? new Set<String>{'CreatedBy.Name'} : new Set<String>()
                ))
            .addSubquery(new QBuilder('RuleActions__r')
                .selectFields(buildSelectClause(
                    RuleAction__c.SObjectType,
                    isRelationsipFieldNeeded ? new Set<String>{'Action__r.Action_Type__c'} : new Set<String>()) 
                ))
            .addSubquery(new QBuilder('RuleFilters__r')
                    .selectFields(buildSelectClause(RuleFilter__c.SObjectType)))
            .add(ruleIds != null && !ruleIds.isEmpty() ? QBuilder.condition('Id').isIn(ruleIds) : null)
            .add(ruleTypes != null && !ruleTypes.isEmpty() ? QBuilder.condition('Type__c').isIn(ruleTypes) : null)
            .add(isOrderingNeeded ? QBuilder.orderBy('Type__c').ascending() : null)
            .add(isOrderingNeeded ? QBuilder.orderBy('SobjectType__c').ascending() : null)
            .add(isOrderingNeeded ? QBuilder.orderBy('Is_Update__c').ascending() : null)
            .add(isOrderingNeeded ? QBuilder.orderBy('Index__c').ascending() : null)
            .build();

        return Database.query(query);
    }

    private static Map<Id, Action__c> getActionMap(List<String> actionIds) {
        String query = new QBuilder(Action__c.SObjectType)
            .selectFields(buildSelectClause(Action__c.SObjectType))
            .add(QBuilder.condition('Id').isIn(actionIds))
            .build();
        return new Map<Id, Action__c>((List<Action__c>)Database.query(query));
    }

    private static Set<String> buildSelectClause(Schema.SObjectType sObjectType) {
        return buildSelectClause(sObjectType, new Set<String>());
    }

    private static Set<String> buildSelectClause(Schema.SObjectType sObjectType, Set<String> customRelationshipFields) {
        Set<String> fields = new Set<String>();
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

        // Add standard fields
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField soField = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = soField.getDescribe();

            // Skip system fields and non-createable fields
            if (!SYSTEM_FIELDS.contains(fieldName.toLowerCase()) && fieldDescribe.isCreateable()) {
                fields.add(fieldName);
            }
        }

        // Add relationship fields
        if (customRelationshipFields != null && !customRelationshipFields.isEmpty()) {
            fields.addAll(customRelationshipFields);
        }

        return fields;
    }

    //TODO: Remove if it's not needed
    // private static String serializeToJson(List<RuleExportImportWrapper> wrappers) {
    //     return JSON.serialize(wrappers);
    // }

    private static List<RuleExportImportWrapper> deserializeFromJson(String jsonStr) {
        return (List<RuleExportImportWrapper>)JSON.deserialize(jsonStr, List<RuleExportImportWrapper>.class);
    }

    private static void debugSession(Exception e, String apexMethodName) {
        Log__c errorLog = Logger.getInstance().getInternalError(
                e,
                null,
                RuleExportImportService.class.getName(),
                apexMethodName
        );

        Logger.getInstance().add(errorLog);
    }

    public class RuleExportImportWizardWrapper {
        public String ruleId;
        public String ruleType;
        public String ruleName;
        public String sobjectName;
        public String actions;
        public String createdBy;
        public Boolean isActive;
        //TODO: Remove
        public Decimal index;
        public Boolean isUpdate;

        public RuleExportImportWizardWrapper(Rule__c rule, Map<String, Schema.SObjectType> globalDescribeMap) {
            this.ruleId = rule.Id;
            this.ruleType = rule.Type__c;
            this.ruleName = rule.Name__c;
            this.sobjectName = this.getSobjectNameBySobjectType(rule.SobjectType__c, globalDescribeMap);
            this.actions = this.getRelatedActionTypes(rule.RuleActions__r);
            this.createdBy = rule.CreatedBy.Name;
            this.isActive = rule.Active__c;
            // TODO: REMOVE
            this.index = rule.Index__c;
            this.isUpdate = rule.Is_Update__c;
        }

        private String getRelatedActionTypes(List<RuleAction__c> ruleActions) {
            Set<String> actionTypes = new Set<String>();
            for (RuleAction__c currentRuleAction : ruleActions) {
                if (String.isNotBlank(currentRuleAction.Action__r.Action_Type__c)) {
                    actionTypes.add(currentRuleAction.Action__r.Action_Type__c);
                }
            }

            return String.join(actionTypes, ', ');
        }

        private String getSobjectNameBySobjectType(String sobjectApiName, Map<String, Schema.SObjectType> globalDescribeMap) {
            return String.isNotBlank(sobjectApiName) 
                ? globalDescribeMap.get(sobjectApiName).getDescribe().getLabel() 
                : SObjectType.Log__c.getLabel();
        }
    }

    public class RuleExportImportWrapper {
        public Rule__c rule;
        public List<RuleAction__c> ruleActions;
        public Map<Id, Action__c> actions;
        public List<RuleFilter__c> ruleFilters;

        public RuleExportImportWrapper() {
            this.rule = new Rule__c();
            this.ruleActions = new List<RuleAction__c>();
            this.actions = new Map<Id, Action__c>();
            this.ruleFilters = new List<RuleFilter__c>();
        }

        public RuleExportImportWrapper(Rule__c sourceRule) {
            this();
            if (sourceRule != null) {
                this.rule = sourceRule.clone(false, true);
            }
        }
    }

    private class RuleImportHelper {
        Logger loggerInstance;
        private List<RuleExportImportWrapper> wrappers;

        // Maps to store relationships and prevent duplicates
        private Map<String, Id> oldToNewActionIds;
        private Map<String, RuleExportImportWrapper> ruleNameToWrapper;
        private Map<String, Action__c> newActionsByKey;

        // Lists to create new data
        private List<Rule__c> rulesToInsert;
        private List<RuleFilter__c> ruleFiltersToInsert;
        private List<RuleAction__c> ruleActionsToInsert;
        
        private RuleImportHelper(List<RuleExportImportWrapper> wrappers) {
            this.loggerInstance = Logger.getInstance();
            this.wrappers = wrappers;
            this.oldToNewActionIds = new Map<String, Id>();
            this.ruleNameToWrapper = new Map<String, RuleExportImportWrapper>();
            this.newActionsByKey = new Map<String, Action__c>();
            this.rulesToInsert = new List<Rule__c>();
            this.ruleFiltersToInsert = new List<RuleFilter__c>();
            this.ruleActionsToInsert = new List<RuleAction__c>();
        }

        private List<Rule__c> getNewRules() {
            return this.rulesToInsert;
        }

        private void runRulesImport() {
            this.buildMapsAndCollectActionCriteria();
            this.processActions();
            this.processRules();
        }

        private void buildMapsAndCollectActionCriteria() {
            for (RuleExportImportWrapper currentWrapper : this.wrappers) {
                if (currentWrapper.rule != null) {
                    this.ruleNameToWrapper.put(currentWrapper.rule.Name__c, currentWrapper);
                }
                if (currentWrapper.actions != null) {
                    for (Id originalActionId : currentWrapper.actions.keySet()) {
                        this.newActionsByKey.put(originalActionId, currentWrapper.actions.get(originalActionId));
                    }
                }
            }
        }

        private void processActions() {
            for (String key : this.newActionsByKey.keySet()) {
                Action__c actionToProcess = this.newActionsByKey.get(key).clone(false, true);
                // update RT to local monitoring RT
                actionToProcess.RecordTypeId = RECORD_TYPE_ID_ACTION_MONITORING;
                // update map with new values 
                this.newActionsByKey.put(key, actionToProcess);
            }

            this.createActions();
        }

        private void createActions() {
            if (!this.newActionsByKey.isEmpty()) {
                DatabaseUtils.getInstance().performInsertDML(this.newActionsByKey.values(), Schema.SObjectType.Action__c)
                    .handleError(RuleExportImportService.class.getName() + '.' + RuleImportHelper.class.getName(), '.createActions', this.loggerInstance);

                // Map new action IDs
                for (String key : this.newActionsByKey.keySet()) {
                    this.oldToNewActionIds.put(key, this.newActionsByKey.get(key).id);
                }
            }
        }

        private void processRules() {
            for (RuleExportImportWrapper currentWrapper : this.wrappers) {
                if (currentWrapper.rule != null) {
                    this.rulesToInsert.add(currentWrapper.rule.clone(false, true));
                }
            }

            this.createRules();
            this.processRuleRelatedRecords();
        }

        private void createRules() {
            DatabaseUtils.getInstance().performInsertDML(this.rulesToInsert, Schema.SObjectType.Rule__c)
                .handleError(RuleExportImportService.class.getName() + '.' + RuleImportHelper.class.getName(), '.createRules', this.loggerInstance);
        }

        private void processRuleRelatedRecords() {
            for (Rule__c rule : this.rulesToInsert) {
                RuleExportImportWrapper wrapper = this.ruleNameToWrapper.get(rule.Name__c);
                if (wrapper != null) {
                    this.processRuleFilters(rule.Id, wrapper);
                    this.processRuleActions(rule.Id, wrapper);
                }
            }

            this.createRuleFilters();
            this.createRuleActions();
        }

        private void processRuleFilters(Id ruleId, RuleExportImportWrapper wrapper) {
            if (wrapper.ruleFilters != null) {
                for (RuleFilter__c currentFilter : wrapper.ruleFilters) {
                    RuleFilter__c newFilter = currentFilter.clone(false, true);
                    newFilter.Rule__c = ruleId;
                    this.ruleFiltersToInsert.add(newFilter);
                }
            }
        }

        private void processRuleActions(Id ruleId, RuleExportImportWrapper wrapper) {
            if (wrapper.ruleActions != null) {
                for (RuleAction__c currentRuleAction : wrapper.ruleActions) {
                    if (currentRuleAction.Action__c != null && this.newActionsByKey.containsKey(currentRuleAction.Action__c)) {
                        String oldActionId = currentRuleAction.Action__c;
                        Id newActionId = this.oldToNewActionIds.get(oldActionId);

                        if (newActionId != null && oldActionId != null) {
                            RuleAction__c newRuleAction = currentRuleAction.clone(false, true);
                            newRuleAction.Rule__c = ruleId;
                            newRuleAction.Action__c = newActionId;
                            this.ruleActionsToInsert.add(newRuleAction);
                        }
                    }
                }
            }
        }

        private void createRuleFilters() {
            DatabaseUtils.getInstance().performInsertDML(this.ruleFiltersToInsert, Schema.SObjectType.RuleFilter__c)
                .handleError(RuleExportImportService.class.getName() + '.' + RuleImportHelper.class.getName(), '.createRuleFilters', this.loggerInstance);
        }

        private void createRuleActions() {
            DatabaseUtils.getInstance().performInsertDML(this.ruleActionsToInsert, Schema.SObjectType.RuleAction__c)
                .handleError(RuleExportImportService.class.getName() + '.' + RuleImportHelper.class.getName(), '.createRuleActions', this.loggerInstance);
        }
    }
}