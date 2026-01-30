public with sharing class NotificationServiceLogImpl extends NotificationServiceBase {

    public override NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType() {
        return NotificationService.NOTIFICATION_SERVICE_TYPE.LOG;
    }

    public override Schema.SObjectType getRecordSobjectType() {
        return Log__c.SObjectType;
    }

    public override Object notificationBatchInstance() {
        // Check if this Log__c record has AutoChart fields in its actions
        if (this.record != null && hasAutoChartFieldsInActions()) {
            return NotificationBatch.getInstance();
        }
        return JiraNotificationBatch.getInstance();
    }

    public override void startNotificationBatch() {
        // Check if this Log__c record has AutoChart fields in its actions
        if (this.record != null && hasAutoChartFieldsInActions()) {
            NotificationBatch.getInstance().startBatch();
        } else {
            JiraNotificationBatch.getInstance().startBatch();
        }
    }

    /**
     * Check if the current Log record has any actions containing AutoChart merge fields
     * This method determines whether to use standard JiraNotificationBatch or 
     * NotificationBatch for AutoChart processing
     * 
     * OPTIMIZED VERSION: Uses static caching to avoid repeated SOQL queries
     * 
     * @return true if AutoChart fields are found in any executable action
     */
    private Boolean hasAutoChartFieldsInActions() {
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return false;
        }
        
        try {
            Log__c log = (Log__c)this.record;
            if (log == null) {
                return false;
            }
            
            // Get the executable rules config
            NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(log);
            if (config == null || config.getAllRuleIdsToRun().isEmpty()) {
                return false;
            }
            
            // Create cache key from rule IDs (sorted for consistency)
            Set<String> ruleIds = config.getAllRuleIdsToRun();
            List<String> sortedRuleIds = new List<String>(ruleIds);
            sortedRuleIds.sort();
            String cacheKey = String.join(sortedRuleIds, ',');
            
            // Check cache first - AVOID SOQL if already cached
            if (autoChartCache.containsKey(cacheKey)) {
                Boolean cachedResult = autoChartCache.get(cacheKey);
                return cachedResult;
            }
            

            
            // Prevent cache from growing too large
            if (autoChartCache.size() >= MAX_AUTOCHART_CACHE_SIZE) {
                autoChartCache.clear();
            }
            
            // Query the rules to get their actions (only when not cached)
            List<Rule__c> rules = [
                SELECT Id, (SELECT Id,
                                   Action__r.RecordTypeId,
                                   Action__r.Name,
                                   Action__r.Name__c,
                                   Action__r.Action_Type__c,
                                   Action__r.Type__c,
                                   Action__r.Subject__c,
                                   Action__r.Body__c,
                                   Action__r.EmailBody__c
                           FROM RuleActions__r) 
                FROM Rule__c 
                WHERE Id IN :ruleIds
                LIMIT 50  // Reasonable limit to prevent query timeouts
            ];
            
            // Check each action for AutoChart fields
            Boolean hasAutoChart = false;
            Integer actionsChecked = 0;
            for (Rule__c rule : rules) {
                for (RuleAction__c ruleAction : rule.RuleActions__r) {
                    Action__c action = ruleAction.Action__r;
                    if (action != null) {
                        RuleUtil.Action actionWrapper = new RuleUtil.Action(action);
                        actionsChecked++;
                        
                        if (AutoChart.containsAutoChartFields(actionWrapper)) {
                            hasAutoChart = true;
                            break; // Early exit when found
                        }
                    }
                }
                if (hasAutoChart) break; // Early exit if found
            }
            
            // Cache the result for future calls
            autoChartCache.put(cacheKey, hasAutoChart);
            
            return hasAutoChart;
            
        } catch (Exception e) {
            // If there's any error, default to false (JiraNotificationBatch)
            return false;
        }
    }

    public override Database.QueryLocator getQueryLocator() {
        Datetime timestamp = (Test.isRunningTest()) ? null : NotificationService.getNotificationTimeStamp();
        Database.QueryLocator queryLocator = (timestamp != null)
            ? Database.getQueryLocator([
                SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c, Organization_Id__c, 
                       Category__c, Area__c, Originated_From__c
                FROM Log__c
                WHERE CreatedDate < :timestamp
                AND (Jira_Integration_Status__c = :Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING
                OR Notification_Integration_Status__c = :Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING)
                ORDER BY Created_At__c
                LIMIT :QUERY_LIMIT
            ])
            : Database.getQueryLocator([
                SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c, Organization_Id__c,
                       Category__c, Area__c, Originated_From__c
                FROM Log__c
                WHERE Jira_Integration_Status__c = :Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING
                OR Notification_Integration_Status__c = :Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING
                ORDER BY Created_At__c
                LIMIT :QUERY_LIMIT
            ]);
        return queryLocator;
    }
    
    public override String getOrganizationIdFromSObjectRecord() {
        // Log__c log = (Log__c)this.record;
        // return log.Organization_Id__c;
        return UserInfo.getOrganizationId();
    }

    public override void setIterationRecordFailedStatus() {
        Log__c log = (Log__c)this.record;
        if(log.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Jira_Integration_Status__c, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
        }
        if(log.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Notification_Integration_Status__c, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED);
        }

        // clear running ids in config
        NotificationService.ExecutableRulesConfig config = clearRunningIdsInConfig(log.Id, log);
        PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Executable_Rules__c, config.toJSON());

        DatabaseUtils.getInstance().performUpdateDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(NotificationServiceLogImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
    }

    public override String getRuleSobjectType(SObject scopeRecord) {
        return null;
    }

    public override List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType) {
        List<String> result = super.getAdditionalSObjectFields(sobjectType);
        for (ConfigUtil.JiraFieldsMapping fm : ConfigUtil.JIRA_FIELDS_MAPPINGS.jira_fields_mapping) {
            if(fm.sobjectType != null) {
                result.add(fm.logField);
            }
        }
        // Add fields needed for recursion prevention check
        result.add('Category__c');
        result.add('Area__c');
        result.add('Originated_From__c');
        return result;
    }

    public override void setRecordFailedStatusThrowBySendErrors() {
        Log__c log = (Log__c)this.record;
        if(log.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            super.addFailedRecord();
        }
    }

    public override List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();

        for(Log__c log : (List<Log__c>)newList) {
            Log__c oldLog = oldMap != null ? (Log__c)oldMap.get(log.Id) : null;

            // skip started notifications
            if(isRunningNotifications(log, oldLog)) continue;

            // Skip logs originated from notification errors to prevent recursive rule execution
            if(log.Originated_From__c == ConfigUtil.ORIGINATED_FROM_NOTIFICATION_ERROR) continue;

            if(!NotificationService.transactionIds.contains(log.Id)
                && (
                String.isBlank(log.Notification_Integration_Status__c)
                    && ((oldMap == null && isBroadcastLog(log, oldLog))
                    || isRegularErrorLogPostprocessingCompleted(log, oldLog)
                    || (oldMap == null && PermissionsUtil.NotificationForPharosErrors && isInternalErrorLog(log, oldLog))
                )
            )) {
                result.add(log);
            }
        }
        return result;
    }

    public override List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();

        for(Log__c log : (List<Log__c>)newList) {
            Log__c oldLog = oldMap != null ? (Log__c)oldMap.get(log.Id) : null;

            // skip started notifications
            if(isRunningTicketing(log, oldLog)) continue;

            // Skip logs originated from notification errors to prevent recursive rule execution
            if(log.Originated_From__c == ConfigUtil.ORIGINATED_FROM_NOTIFICATION_ERROR) continue;

            if((String.isBlank(log.Jira_Integration_Status__c)
                || (String.isNotBlank(log.Jira_Integration_Status__c)
                && log.Jira_Integration_Status__c == ConfigUtil.EXISTING_TICKET_LINKED_STATUS))
                && ((oldMap == null && isBroadcastLog(log, oldLog))
                || isRegularErrorLogPostprocessingCompleted(log, oldLog))) {
                result.add(log);
            }
        }
        return result;
    }
    
    /**
     * Alternative implementation #2: Lazy evaluation approach
     * Instead of checking upfront, use NotificationBatch by default and switch if needed
     * This completely avoids SOQL in the decision-making process
     */
    @TestVisible
    private Boolean hasAutoChartFieldsInActionsLazy() {
        // Always return true to use NotificationBatch
        // AutoChart detection happens during actual action processing
        // If no AutoChart fields are found during processing, it behaves like JiraNotificationBatch
        return true;
    }
    
    /**
     * Alternative implementation #3: Use passed Action data to avoid SOQL
     * This method can be used when Action data is already available from calling context
     */
    @TestVisible  
    private Boolean hasAutoChartFieldsInActionsWithData(List<RuleUtil.Action> actions) {
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return false;
        }
        
        if (actions == null || actions.isEmpty()) {
            return false;
        }
        
        for (RuleUtil.Action action : actions) {
            if (AutoChart.containsAutoChartFields(action)) {
                return true;
            }
        }
        
        return false;
    }
}