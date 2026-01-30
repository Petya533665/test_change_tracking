public with sharing abstract class NotificationServiceBase implements NotificationServiceInterface {
    
    // Batch processing constants
    public static final Integer QUERY_LIMIT = 200;
    public static final Integer MAX_NOTIFICATION_ATTEMPTS = 2;
    
    // Cache for AutoChart field detection to avoid repeated SOQL queries
    // Key: JSON serialized Set<String> of rule IDs, Value: Boolean hasAutoChart
    public static Map<String, Boolean> autoChartCache = new Map<String, Boolean>();
    public static final Integer MAX_AUTOCHART_CACHE_SIZE = 1000; // Prevent memory issues
    
    // SObject type mapping for service types
    public static final Map<NotificationService.NOTIFICATION_SERVICE_TYPE, Schema.SObjectType> SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE = new Map<NotificationService.NOTIFICATION_SERVICE_TYPE, Schema.SObjectType>{
        NotificationService.NOTIFICATION_SERVICE_TYPE.LOG => Log__c.SObjectType,
        NotificationService.NOTIFICATION_SERVICE_TYPE.ISSUE => Issue__c.SObjectType,
        NotificationService.NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => Trace_Result__c.SObjectType,
        NotificationService.NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => EventAction__c.SObjectType
    };
    
    private String recordId;
    protected SObject record;
    protected Logger logger;
    protected Map<Id, SObject> toUpdateRecordsMap = new Map<Id, SObject>();
    protected transient NotificationService.ErrorsHelper logErrors;
    protected List<RuleUtil.Rule> notificationRules = new List<RuleUtil.Rule>();
    protected List<RuleUtil.Rule> ticketingRules = new List<RuleUtil.Rule>();
    protected List<RuleUtil.Rule> jiraRules = new List<RuleUtil.Rule>();
    protected List<RuleUtil.Rule> azureDevOpsRules = new List<RuleUtil.Rule>();
    protected Boolean shouldMarkForRecursionPrevention = false;

    public abstract Object notificationBatchInstance();
    public abstract void setRecordFailedStatusThrowBySendErrors();
    public abstract String getOrganizationIdFromSObjectRecord();
    public abstract void setIterationRecordFailedStatus();
    public abstract Database.QueryLocator getQueryLocator();
    public abstract NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType();
    public abstract Schema.SObjectType getRecordSobjectType();
    
    public virtual Boolean isPermissionEnabled() {
        return true;
    }

    /**
     * Check if a record was previously rate-limited by examining Slack integration status
     */
    public virtual Boolean isRecordRateLimited(SObject record) {
        try {
            String slackStatus = (String) record.get('Slack_Integration_Status__c');
            return slackStatus != null && slackStatus.toLowerCase().contains('rate limit');
        } catch (Exception e) {
            // If field doesn't exist or any other error, assume not rate-limited
            return false;
        }
    }

    public virtual void setLogger(Logger logger) {
        this.logger = logger;
    }

    public virtual void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config) {

        SObject recordToUpdate = this.toUpdateRecordsMap.containsKey(recordId)
            ? this.toUpdateRecordsMap.get(recordId)
            : this.getRecordSobjectType().newSObject();
        recordToUpdate.put('Id', recordId);

        NotificationService.addToMapCountRecordsByType(this.getRecordSobjectType());

        if(isTicketingRule) {
            recordToUpdate.put(getTicketingStatusFieldName(), Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING);
        }
        else {
            recordToUpdate.put(getNotificationStatusFieldName(), Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING);
        }
        if(recordToUpdate.get(getExecutableRulesFieldName()) != null) {
            NotificationService.ExecutableRulesConfig existConfig = NotificationService.getExecutableRuleConfig(recordToUpdate);
            config.mergeConfig(existConfig);
        }
        recordToUpdate.put(getExecutableRulesFieldName(), config.toJSON());
        NotificationService.mapConfigsInTransaction.put(recordId, config);
        this.toUpdateRecordsMap.put(recordId, recordToUpdate);
    }

    public virtual void init(SObject scopeRecord) {
        this.recordId = String.valueOf(scopeRecord.get('Id'));
        this.record = scopeRecord;
        this.logErrors = new NotificationService.ErrorsHelper(scopeRecord);
    }

    public virtual String getExecutableRulesFieldName() {
        return 'Executable_Rules__c';
    }

    public virtual String getNotificationStatusFieldName() {
        return 'Notification_Integration_Status__c';
    }

    public virtual String getTicketingStatusFieldName() {
        return 'Jira_Integration_Status__c';
    }

    public virtual String getJobName() {
        return NotificationService.BATCH_SERVICE_MAPPING_BY_TYPE.get(getServiceType())?.replaceFirst(ConfigUtil.NS_CLASS, '');
    }

    public virtual Boolean isJobRunning() {
        List<AsyncApexJob> currentJobs = DatabaseUtils.getCurrentJobs(new List<String>{getJobName()});
        return !currentJobs.isEmpty();
    }

    public virtual void startNotificationBatch() {}

    public virtual Integer getSobjectRecordsCountFromContext() {
        if(NotificationService.mapCountRecordsByType != null
            && NotificationService.mapCountRecordsByType.containsKey(getServiceType())) {
            return NotificationService.mapCountRecordsByType.get(getServiceType());
        }
        return null;
    }

    public virtual Integer getSObjectRecordsCount() {
        Integer count = getSobjectRecordsCountFromContext();
        if (count != null) return count;

        QBuilder qb = new QBuilder(NotificationService.SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
            .selectFields(new Set<String>{'COUNT()'})
            .add(String.isNotBlank(getTicketingStatusFieldName()) ? QBuilder.condition(getTicketingStatusFieldName()).equalsTo(Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) : null)
            .add(String.isNotBlank(getNotificationStatusFieldName()) ? QBuilder.condition(getNotificationStatusFieldName()).equalsTo(Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) : null)
            .addLimit(QUERY_LIMIT);
        qb.setConditionOrder('1 OR 2');
        return Database.countQuery(qb.build());
    }

    public virtual Integer getCountIterations(Database.BatchableContext info) {
        String organizationId = getOrganizationIdFromSObjectRecord();
        String recordKey = CacheUtils.KEY_NOTIFICATION_OBJECT_TRACKING + ':' + this.recordId;

        CacheUtils cacheUtil = new CacheUtils(organizationId);

        Object cacheObject = cacheUtil.getValue(recordKey);
        Integer count = cacheObject != null ? (Integer)cacheObject : 1;
        cacheUtil.putValue(recordKey, count);
        return count;
    }
    
    public virtual Integer getCountIterations(Database.BatchableContext info, NotificationService.BatchContextManager batchContext) {
        if (batchContext != null) {
            return batchContext.getNotificationAttempts(this.recordId) + 1;
        }
        return 1;
    }

    public virtual void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, NotificationService.BatchContextManager batchContextManager) {
        if (scope == null || scope.isEmpty()) {
            return; // Skip processing for empty scope
        }
        
        init(scope.get(0));
        
        // Get the current action iteration from batch context manager
        NotificationService.ActionIteration currentIteration = batchContextManager != null ?
            batchContextManager.getIterationContext(this.recordId) : null;
        
        // Apply MAX_NOTIFICATION_ATTEMPTS check using batchContext
        Integer countIterations = getCountIterations(info, batchContextManager);
        
        // Check if this record was previously rate-limited and if Slack is still rate-limited
        Boolean isRateLimitedRecord = isRecordRateLimited(scope.get(0));
        Boolean shouldSkipDueToRateLimit = isRateLimitedRecord && SlackService.isCurrentlyRateLimited();
        
        if (shouldSkipDueToRateLimit) {
            // Skip processing this record while Slack is still rate-limited
            // Track this as a rate limit event to prevent infinite batch rescheduling
            if (batchContextManager instanceof NotificationService.BaseBatchContextManager) {
                NotificationService.BaseBatchContextManager batchManager = (NotificationService.BaseBatchContextManager) batchContextManager;
                NotificationService.BatchExecutionStats stats = batchManager.getBatchStats();
                stats.trackSlackAction(this.recordId);
                stats.trackSlackRateLimit(this.recordId, 'Record skipped due to active Slack rate limit', SlackService.getRateLimitExpiryTime());
            }
            return;
        }
        
        if (countIterations <= MAX_NOTIFICATION_ATTEMPTS) {

            // track records with notification attempts
            batchContextManager?.addRecordNotificationAttempt(this.recordId);

            if (NotificationService.isAutoChartIteration(currentIteration)) {
                // Handle AutoChart iteration - 3-step chart processing workflow
                AutoChart.AutoChartIteration autoChartIteration = NotificationService.toAutoChartIteration(currentIteration);
                
                try {
                    AutoChart.AutoChartActionProcessor processor = new AutoChart.AutoChartActionProcessor(
                        this.recordId, this.logErrors, batchContextManager);
                    
                    processor.processAutoChartIteration(autoChartIteration);
                    
                    // Successfully completed AutoChart step
                    
                } catch (Exception e) {
                    // Log the error but don't fail the entire batch
                    // Continue processing without specific error logging to avoid method signature issues
                    throw e; // Re-throw to maintain existing error handling flow
                }
                
            } else {
                // Handle regular notification iteration
                executeIteration(currentIteration, batchContextManager);
            }
        } else {
            // Exceeded max attempts - fail the record
            setIterationRecordFailedStatus();
        }
        
        // Clean up context
        if (currentIteration != null && batchContextManager != null) {
            batchContextManager.clearIterationContext(this.recordId);
        }
    }

    public virtual NotificationService.ExecutableRulesConfig clearRunningIdsInConfig(String recordId, SObject record) {
        NotificationService.ExecutableRulesConfig config;
        if (NotificationService.mapConfigsInTransaction.containsKey(String.valueOf(recordId))) {
            config = NotificationService.mapConfigsInTransaction.get(String.valueOf(recordId));
        } else {
            config = NotificationService.getExecutableRuleConfig(record);
        }
        
        config.clearRunningIds();
        return config;
    }

    public virtual void finish(Database.BatchableContext info) {
        if (!Test.isRunningTest()) {
            this.logger?.flush();
            this.startNotificationBatch();
        }
    }

    public virtual void finish(Database.BatchableContext info, NotificationService.BatchContextManager batchContextManager) {
        Boolean hasRateLimitSummary = false;
        Boolean shouldRescheduleBatch = true;

        if (batchContextManager != null && batchContextManager instanceof NotificationService.BaseBatchContextManager) {
            NotificationService.BaseBatchContextManager batchManager = (NotificationService.BaseBatchContextManager) batchContextManager;

            if(!batchManager?.getRecordsWithNotificationAttempts()?.isEmpty()) {
                for (String recordId : batchManager.getRecordsWithNotificationAttempts()) {
                    NotificationService.incrementNotificationAttempts(recordId);
                }
            }

            NotificationService.BatchExecutionStats stats = batchManager.getBatchStats();

            if (stats.hasRateLimitEvents()) {
                logSlackRateLimitSummary(stats);
                hasRateLimitSummary = true;
                shouldRescheduleBatch = false;
            }
        }

        if (!Test.isRunningTest() || hasRateLimitSummary) {
            this.logger?.flush();
        }

        if (!Test.isRunningTest() && shouldRescheduleBatch) {
            this.startNotificationBatch();
        }
    }

    protected virtual void logSlackRateLimitSummary(NotificationService.BatchExecutionStats stats) {
        String summary = String.format(
            'Slack Rate Limit Impact - {0} of {1} actions affected, {2} pending',
            new List<String>{
                String.valueOf(stats.rateLimitedSlackActions),
                String.valueOf(stats.totalSlackActions),
                String.valueOf(stats.getPendingSlackActions())
            }
        );

        String details = buildRateLimitDetails(stats);

        if (this.logger != null) {
            Log__c log = LogBuilder.getInstance()
                .category('Pharos Error')
                .summary(summary)
                .area('Pharos')
                .type('Rate Limit Summary')
                .details(details)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), NotificationService.class.getName() + ':logSlackRateLimitSummary')
                .attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.getName(), JSON.serialize(stats.affectedRecordIds))
                .build();
            this.logger.add(log);
        }
    }

    protected virtual String buildRateLimitDetails(NotificationService.BatchExecutionStats stats) {
        List<String> detailLines = new List<String>();
        detailLines.add('=== SLACK RATE LIMIT BATCH SUMMARY ===');
        detailLines.add('Batch Timestamp: ' + DateTime.now().formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT) + ' UTC');
        detailLines.add('Total Slack Actions in Batch: ' + stats.totalSlackActions);
        detailLines.add('Rate Limited Actions: ' + stats.rateLimitedSlackActions);
        detailLines.add('Successful Actions: ' + stats.successfulSlackActions);
        detailLines.add('Failed Actions: ' + stats.failedSlackActions);
        detailLines.add('Pending Actions (Will Retry): ' + stats.getPendingSlackActions());
        detailLines.add('Success Rate: ' + stats.getSuccessRate().format() + '%');
        detailLines.add('Affected Records: ' + stats.affectedRecordIds.size());

        if (stats.affectedRecordIds.size() <= 10) {
            detailLines.add('Record IDs: ' + String.join(new List<String>(stats.affectedRecordIds), ', '));
        } else {
            List<String> recordIdList = new List<String>(stats.affectedRecordIds);
            List<String> firstTenRecords = new List<String>();
            for (Integer i = 0; i < 10 && i < recordIdList.size(); i++) {
                firstTenRecords.add(recordIdList[i]);
            }
            detailLines.add('Record IDs (first 10): ' + String.join(firstTenRecords, ', ') + '...');
        }

        if (!stats.rateLimitEvents.isEmpty()) {
            detailLines.add('');
            detailLines.add('=== RATE LIMIT EVENTS ===');
            for (NotificationService.RateLimitEvent event : stats.rateLimitEvents) {
                detailLines.add('Time: ' + event.timestamp.formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT) + ' UTC');
                detailLines.add('Record: ' + event.recordId);
                detailLines.add('Message: ' + event.message);
                if (event.retryAfter != null) {
                    detailLines.add('Retry After: ' + event.retryAfter.formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT) + ' UTC');
                }
                detailLines.add('---');
            }
        }

        return String.join(detailLines, '\n').abbreviate(ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD);
    }

    public virtual void populateRules() {
        NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(this.record);
        List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
        String ruleSobjectType = getRuleSobjectType(this.record);

        if(executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
            executableRulesIds.addAll(config.getAllExecutedRuleIds());
        }
        
        this.notificationRules = RuleUtil.getNotificationRules(executableRulesIds, ruleSobjectType);
        this.ticketingRules = getTicketingRules(executableRulesIds, ruleSobjectType);
    }

    public virtual void executeIteration() {
        executeIteration(null);
    }
    
    public virtual void executeIteration(NotificationService.ActionIteration targetIteration) {
        executeIteration(targetIteration, null);
    }

    public virtual void executeIteration(NotificationService.ActionIteration targetIteration, NotificationService.BatchContextManager batchContextManager) {
        populateRules();
        
        if (hasRunningManageTokenJobAndRelatedActions() && !BlurModeService.isAvailableNotifications24hr()) {
            return;
        }

        setRecordFailedStatusForEmptyRules();
        this.record = getSObjectRecordDetails();
        
        List<Messaging.SingleEmailMessage> emailMessages;
        
        if (targetIteration != null && targetIteration.iterationNumber > 1) {
            executeActionIteration(targetIteration, batchContextManager);
            emailMessages = new List<Messaging.SingleEmailMessage>();
        } else {
            Boolean includeAllSlackInFirstIteration = Test.isRunningTest() || NotificationService.disableIteratorExpansion;
            emailMessages = sendNotifications(targetIteration, includeAllSlackInFirstIteration, batchContextManager);
            sendTicketing();
        }
        
        sendEmailMessages(emailMessages);
        createLogErrors();
        BlurModeService.incrementNotifications24hrCounter();
    }

    public virtual void createLogErrors() {
        NotificationService.transactionIds.add(this.record.Id);

        this.logErrors.createErrors(this.record, this.toUpdateRecordsMap, this.logger);
        if (!this.toUpdateRecordsMap.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(new List<SObject>(this.toUpdateRecordsMap.values()))
                .handleError(NotificationServiceBase.class.getName(), '.createLogErrors', logger);
            this.toUpdateRecordsMap.clear();
        }
    }

    public virtual void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages) {
        if(!emailMessages.isEmpty()) {
            try {
                NotificationService.sendEmail(emailMessages);
            }
            catch (Exception e) {
                List<System.Exception> exceptions = this.logErrors.emailExceptions.get(this.recordId) != null
                    ? logErrors.emailExceptions.get(this.recordId)
                    : new List<System.Exception>();
                exceptions.add(e);
                this.logErrors.emailExceptions.put(this.recordId, exceptions);
            }
        }
    }

    public virtual void sendTicketing() {
        String ticketId;
        if(this.ticketingRules.isEmpty()) {
            setRecordFailedStatusThrowBySendErrors();
        }
        else if(!this.ticketingRules.isEmpty()) {
            RuleUtil.Rule rule = this.ticketingRules.size() > 0 ? this.ticketingRules.get(0) : null;
            if (rule == null) {
                setRecordFailedStatusThrowBySendErrors();
                return;
            }
            for(RuleUtil.Action action : rule.actions) {
                switch on RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type) {
                    when JIRA, AZURE_DEV_OPS {
                        try {
                            // Recursion prevention:
                            // Internal Pharos Error logs created by ticketing failures must be marked with
                            // ORIGINATED_FROM_NOTIFICATION_ERROR to avoid recursive rule execution.
                            TicketingService service = new TicketingService(
                                RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type),
                                this.logger,
                                true
                            );
                            TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(this.recordId, action.fields);
                            TicketingService.TicketCreateResult newTicket = service.createTicket(data);
                            ticketId = newTicket.id;

                            break;
                        }
                        catch (Exception e) {
                            this.logErrors.ticketingExceptions.put(this.recordId, e);
                            logger?.add(logger.getInternalError(
                                e,
                                this.recordId,
                                NotificationService.class.getName(),
                                'ticketingExceptions',
                                true
                            ));
                        }
                    }
                    when JIRA_TICKET_COMMENT, AZURE_DEV_OPS_WORK_ITEM_COMMENT {
                        try {
                            // Recursion prevention:
                            // Internal Pharos Error logs created by ticketing comment failures must be marked with
                            // ORIGINATED_FROM_NOTIFICATION_ERROR to avoid recursive rule execution.
                            TicketingService service = new TicketingService(
                                RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(action.type),
                                this.logger,
                                true
                            );
                            TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(
                                this.recordId, 
                                action.fields
                            );
                            service.createTicketComment(data);
                            ticketId = 'comment';
                        }
                        catch(Exception e) {
                            this.logErrors.ticketingExceptions.put(this.recordId, e);
                            logger?.add(logger.getInternalError(
                                e,
                                this.recordId,
                                NotificationService.class.getName(),
                                'ticketingExceptions',
                                true
                            ));
                        }
                    }
                }
            }
            if(ticketId == null) {
                setRecordFailedStatusThrowBySendErrors();
            }
        }
    }

    public virtual List<Messaging.SingleEmailMessage> sendNotifications() {
        return sendNotifications(null, true);
    }
    
    public virtual List<Messaging.SingleEmailMessage> sendNotifications(NotificationService.ActionIteration targetIteration, Boolean includeAllSlackActions) {
        return sendNotifications(targetIteration, includeAllSlackActions, null);
    }

    public virtual List<Messaging.SingleEmailMessage> sendNotifications(NotificationService.ActionIteration targetIteration, Boolean includeAllSlackActions, NotificationService.BatchContextManager batchContextManager) {
        if(this.notificationRules.isEmpty()) {
            return new List<Messaging.SingleEmailMessage>();
        }

        RuleUtil.Rule rule = this.notificationRules.size() > 0 ? this.notificationRules.get(0) : null;
        if (rule == null) {
            return new List<Messaging.SingleEmailMessage>();
        }

        NotificationService.ActionProcessor processor;
        if (batchContextManager != null) {
            processor = new NotificationService.ActionProcessor(this.recordId, this.logErrors, this.record, batchContextManager);
        } else {
            processor = new NotificationService.ActionProcessor(this.recordId, this.logErrors, this.record);
        }

        return processor.processActionsWithSlackStrategy(rule.actions, includeAllSlackActions);
    }

    public virtual void setRecordFailedStatusForEmptyRules() {
        if(this.notificationRules.isEmpty() && this.ticketingRules.isEmpty()) {
            SObject failedRecord = PermissionsUtil.newSObject(this.logErrors.sObjectType);
            PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrId, recordId);
            PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrNotificationIntegrationStatus, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED);
            PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrJiraIntegrationStatus, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
            this.toUpdateRecordsMap.put(this.recordId, failedRecord);
        }
    }

    public virtual List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType) {
        List<String> result = new List<String>();
        List<String> additionalFields = NotificationService.BATCH_LOCATOR_ADDITIONAL_FIELDS_BY_SOBJECT_TYPE.get(sobjectType);
        if (additionalFields != null) {
            result.addAll(additionalFields);
        }
        return result;
    }

    public virtual List<SObject> getSObjectRecordDetails(List<SObject> records) {
        List<RuleUtil.Rule> rules = new List<RuleUtil.Rule>();
        rules.addAll(this.notificationRules);
        rules.addAll(this.jiraRules);
        rules.addAll(this.azureDevOpsRules);

        List<RuleUtil.Rule> rulesWithSubType = new List<RuleUtil.Rule>();
        Schema.SObjectField subTypeField;
        for(RuleUtil.Rule rule : rules) {
            // Defensive null check to avoid NPEs from malformed test data or inputs
            if (rule == null) {
                continue;
            }
            if(rule.sobjectType != getRuleSObjectTypeValue()) continue;
            subTypeField = getRuleSubTypeSObjectField(rule);
            if(subTypeField != null) {
                rulesWithSubType.add(rule);
            }
        }

        if(!rulesWithSubType.isEmpty()) {
            List<String> sobjectFieldNames = new List<String>();
            Schema.DescribeFieldResult dfr = subTypeField.getDescribe();
            List<Schema.sObjectType> targetReferences = dfr.getReferenceTo();
            Schema.DescribeSObjectResult dsr = targetReferences.get(0).getDescribe();
            List<String> fields = RuleUtil.getSObjectFieldNames(RuleUtil.getSObjectFields(dsr, rulesWithSubType), rulesWithSubType);
            fields.add(getExecutableRulesFieldName());
            for(String field : fields) {
                String fullFieldName = dfr.getRelationshipName() + '.' + field;
                sobjectFieldNames.add(fullFieldName);
            }
            if(!sobjectFieldNames.isEmpty()) {
                String query = new QBuilder(NotificationService.SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
                    .selectFields(new Set<String>(sobjectFieldNames))
                    .add(QBuilder.condition('Id').isIn(':records'))
                    .build();
                List<SObject> recordsList = Database.query(query);
                Map<Id, SObject> recordstMap = new Map<Id, SObject>(records);
                for(SObject so : recordsList) {
                    Id soId = (Id)so.get('Id');
                    SObject sourceSO = recordstMap.get(soId);
                    Map<String, Object> sourceSOMap = sourceSO.getPopulatedFieldsAsMap();
                    for(String fn : sourceSOMap.keySet()) {
                        try {
                            so.put(fn, sourceSOMap.get(fn));
                        }
                        catch(Exception e) {}
                    }
                }
                return recordsList;
            }
        }

        return records;
    }

    public virtual SObject getSobjectRecordDetails() {
        List<String> sobjectFieldNames = new List<String>();

        List<String> notificationFields = RuleUtil.getSObjectFieldNames(RuleUtil.getSObjectFields(this.record.getSObjectType().getDescribe(), this.notificationRules), this.notificationRules);
        List<String> ticketingFields = RuleUtil.getSObjectFieldNames(RuleUtil.getSObjectFields(this.record.getSObjectType().getDescribe(), this.ticketingRules), this.ticketingRules);

        sobjectFieldNames.addAll(notificationFields);
        sobjectFieldNames.addAll(ticketingFields);
        sobjectFieldNames.addAll(getAdditionalSObjectFields(this.record.getSObjectType()));

        String query = new QBuilder(this.record.getSObjectType())
            .selectFields(new Set<String>(sobjectFieldNames))
            .add(QBuilder.condition('Id').equalsTo(this.recordId))
            .build();
        List<SObject> records = Database.query(query);
        return records.get(0);
    }

    public virtual Boolean hasRunningManageTokenJobAndRelatedActions() {
        List<AsyncApexJob> manageTokensJob = DatabaseUtils.getCurrentJobs(new List<String>{'ManageTokensBatch'});
        return ((hasTeamsActions(this.notificationRules) || hasTicketingAction(this.ticketingRules)) && !manageTokensJob.isEmpty());
    }

    public virtual Boolean hasTeamsActions(List<RuleUtil.Rule> notificationRules) {
        Set<RuleUtil.ActionType> notificationsRuleActionTypes = (!notificationRules.isEmpty())
            ? notificationRules.get(0).getRuleActionTypes()
            : new Set<RuleUtil.ActionType>();

        return notificationsRuleActionTypes?.contains(RuleUtil.ActionType.TEAMS);
    }

    public virtual Boolean hasTicketingAction(List<RuleUtil.Rule> ticketingRules) {
        return !ticketingRules.isEmpty();
    }

    public virtual List<RuleUtil.Rule> getTicketingRules(List<String> executableRulesIds, String ruleSobjectType){
        List<RuleUtil.Rule> ticketingRules = new List<RuleUtil.Rule>();
        List<RuleUtil.Rule> jiraRules = RuleUtil.getJiraRules(executableRulesIds, ruleSobjectType);
        List<RuleUtil.Rule> azureRules = RuleUtil.getAzureDevOpsRules(executableRulesIds, ruleSobjectType);
        if(!jiraRules.isEmpty()) {
            ticketingRules.addAll(jiraRules);
        }
        if(!azureRules.isEmpty()) {
            ticketingRules.addAll(azureRules);
        }
        return ticketingRules;
    }

    public virtual String getRuleSobjectType(SObject scopeRecord) {
        return scopeRecord.getSObjectType().getDescribe().getName();
    }

    public virtual void addFailedRecord() {
        SObject failedRecord = (this.toUpdateRecordsMap.containsKey(this.recordId))
            ? toUpdateRecordsMap.get(this.recordId)
            : PermissionsUtil.newSObject(this.logErrors.sObjectType);
        PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrId, this.recordId);
        PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrBugTracker, null);
        PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrJiraIntegrationStatus, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
        this.toUpdateRecordsMap.put(this.recordId, failedRecord);
    }

    public virtual List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();
        result.addAll(newList);
        return result;
    }

    public virtual List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();
        result.addAll(newList);
        return result;
    }

    public virtual List<SObject> filterRecordsForExecuteNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();
        for(SObject record : newList) {
            SObject oldRecord = (oldMap != null ? oldMap.get(String.valueOf(record.get('Id'))) : null);
            if(isSObjectNotificationsPending(record, oldRecord)) {
                result.add(record);
                break;
            }
        }
        return result;
    }

    public virtual List<SObject> filterRecordsForExecuteTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();
        for(SObject record : newList) {
            SObject oldRecord = (oldMap != null ? oldMap.get(String.valueOf(record.get('Id'))) : null);
            if(isSObjectTicketingPending(record, oldRecord)) {
                result.add(record);
                break;
            }
        }
        return result;
    }

    public virtual String getRuleSObjectTypeValue() {
        return NotificationService.RULE_SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType());
    }

    public virtual Schema.SObjectField getRuleSubTypeSObjectField(RuleUtil.Rule rule) {
        return null;
    }

    public virtual void applyNotificationRules(List<SObject> toNotifications, Map<Id, SObject> oldMap) {
        assignNotificationRules(this.notificationRules, toNotifications, oldMap);
    }

    public virtual void applyJiraRules(List<SObject> toTicketing, Map<Id, SObject> oldMap) {
        if(PermissionsUtil.JiraIntegrationEnabled) {
            assignNotificationRules(this.jiraRules, toTicketing, oldMap);
        }
    }

    public virtual void applyAzureDevOpsRules(List<SObject> toTicketing, Map<Id, SObject> oldMap) {
        if(PermissionsUtil.AzureDevOpsIntegrationEnabled) {
            assignNotificationRules(this.azureDevOpsRules, toTicketing, oldMap);
        }
    }

    public virtual void updateFiredRecords() {
        if (!this.toUpdateRecordsMap.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(new List<SObject>(this.toUpdateRecordsMap.values()))
                .handleError(NotificationServiceBase.class.getName(), '.updateFiredRecords', logger);
            this.toUpdateRecordsMap.clear();
        }
    }

    public virtual void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        if(!isPermissionEnabled()) return;
        this.toUpdateRecordsMap = new Map<Id, SObject>();

        this.notificationRules = RuleUtil.getNotificationRules(null, getRuleSObjectTypeValue());
        this.jiraRules = RuleUtil.getJiraRules(null, getRuleSObjectTypeValue());
        this.azureDevOpsRules = RuleUtil.getAzureDevOpsRules(null, getRuleSObjectTypeValue());

        List<SObject> toNotifications = filterRecordsForRunNotificationRules(newList, oldMap);
        List<SObject> toTicketing = filterRecordsForRunTicketingRules(newList, oldMap);

        toNotifications = getSObjectRecordDetails(toNotifications);
        toTicketing = getSObjectRecordDetails(toTicketing);
        
        applyNotificationRules(toNotifications, oldMap);
        applyJiraRules(toTicketing, oldMap);
        applyAzureDevOpsRules(toTicketing, oldMap);
        updateFiredRecords();
    }

    public virtual void executeNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        if(!isPermissionEnabled()) return;
        this.toUpdateRecordsMap = new Map<Id, SObject>();
        
        List<SObject> toNotifications = filterRecordsForExecuteNotificationRules(newList, oldMap);
        List<SObject> toTicketing = filterRecordsForExecuteTicketingRules(newList, oldMap);

        if(!System.isFuture() && (!toNotifications.isEmpty() || !toTicketing.isEmpty())) {
            startNotificationBatch();
        }
    }

    public virtual Boolean isTicketingRule(RuleUtil.Rule rule) {
        return rule.type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE || rule.type == Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS;
    }

    public virtual void assignNotificationRules(List<RuleUtil.Rule> rules, List<SObject> records) {
        assignNotificationRules(rules, records, null);
    }

    public virtual void assignNotificationRules(List<RuleUtil.Rule> rules, List<SObject> records, Map<Id, SObject> oldMap) {

        if (rules == null || rules.isEmpty() || records == null || records.isEmpty()) {
            return;
        }

        for(SObject record : records) {
            if (record == null) {
                continue;
            }
            Id recordId = (Id)record.get('Id');
            if (recordId == null) {
                continue;
            }
            SObject oldSObject = (oldMap != null && oldMap.containsKey(recordId)) ? oldMap.get(recordId) : null;
            NotificationService.ExecutableRulesConfig config =
                (NotificationService.mapConfigsInTransaction != null && NotificationService.mapConfigsInTransaction.containsKey(recordId))
                ? NotificationService.mapConfigsInTransaction.get(recordId)
                : NotificationService.getExecutableRuleConfig(record);
            if (config == null) {
                config = new NotificationService.ExecutableRulesConfig();
            }
            Set<String> executedRuleIds = (config.getAllExecutedRuleIds() != null) ? config.getAllExecutedRuleIds() : new Set<String>();
            Set<String> runRuleIds = (config.getAllRuleIdsToRun() != null) ? config.getAllRuleIdsToRun() : new Set<String>();
            Set<String> ruleIdsToReRun = (config.getRuleIdsToReRun() != null) ? config.getRuleIdsToReRun() : new Set<String>();
            Set<String> newIssueIds = (NotificationService.newIssueInTransactionIds != null) ? NotificationService.newIssueInTransactionIds : new Set<String>();

            for(RuleUtil.Rule rule : rules) {
                if (rule == null) {
                    continue;
                }
                if(rule.isUpdateRule() &&
                    (oldMap == null || rule.sobjectType != Schema.SObjectType.Issue__c.getName())) {
                    continue;
                }
                if(rule.isUpdateRule() && oldMap != null && executedRuleIds.contains(rule.id)) {
                    continue;
                }
                if(!rule.isUpdateRule() && oldMap != null && rule.type == Constants.RULE_SOBJECT.TYPE_NOTIFICATION
                    && executedRuleIds.contains(rule.id)) {
                    continue;
                }
                if(String.isBlank((String)rule.id)) {
                    continue;
                }
                if(runRuleIds.contains((String)rule.id)) {
                    continue;
                }

                Boolean issueHasFiredInsertNotificationRule = false;
                for(RuleUtil.Rule r : rules) {
                    if (r == null) {
                        continue;
                    }
                    if(!r.isUpdateRule()
                        && r.sobjectType == Schema.SObjectType.Issue__c.getName()
                        && executedRuleIds.contains((String)r.id)
                        && r.type == Constants.RULE_SOBJECT.TYPE_NOTIFICATION) {

                        issueHasFiredInsertNotificationRule = true;
                        break;
                    }
                }

                Boolean firstFireTicketingRuleOnIssue = (!rule.isUpdateRule()
                    && (rule.type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE
                    || rule.type == Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS)
                    && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                    && oldMap != null
                    && newIssueIds.contains(String.valueOf(recordId))
                    && ruleIdsToReRun.isEmpty()
                    && !executedRuleIds.contains((String)rule.id));

                Boolean reRunTicketingRuleOnIssue = (!rule.isUpdateRule()
                    && (rule.type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE
                    || rule.type == Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS)
                    && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                    && oldMap != null
                    && !ruleIdsToReRun.isEmpty()
                    && executedRuleIds.contains((String)rule.id));

                if(!rule.isUpdateRule()
                    && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                    && (rule.type == Constants.RULE_SOBJECT.TYPE_JIRA_UPDATE
                    || rule.type == Constants.RULE_SOBJECT.TYPE_AZURE_DEV_OPS)
                    && firstFireTicketingRuleOnIssue == false
                    && reRunTicketingRuleOnIssue == false) {

                    continue;
                }
                if(!rule.isUpdateRule()
                    && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                    && rule.type == Constants.RULE_SOBJECT.TYPE_NOTIFICATION
                    && issueHasFiredInsertNotificationRule == true) {
                    continue;
                }

                if(rule.sobjectType != getRuleSObjectTypeValue()) continue;
                Schema.SObjectField subTypeField = getRuleSubTypeSObjectField(rule);

                Set<Id> firedIds = oldSObject == null
                    ? rule.applyNotificationRules(new List<SObject>{record}, subTypeField)
                    : rule.applyNotificationRules(new List<SObject>{record}, subTypeField, new Map<Id, SObject>{recordId => oldSObject});
                Set<RuleUtil.ActionType> ruleActionTypes = rule.getRuleActionTypes();
    
                if(firedIds.contains(recordId)) {

                    if(!isTicketingRule(rule)) {
                        Boolean noTeamsActions = !ruleActionTypes.contains(RuleUtil.ActionType.TEAMS);
                        Boolean hasTeamsActionAndDisabledPermission = ruleActionTypes.contains(RuleUtil.ActionType.TEAMS) && !PermissionsUtil.TeamsIntegrationEnabled;
                        Boolean noSlackActions = !ruleActionTypes.contains(RuleUtil.ActionType.SLACK);
                        Boolean hasSlackActionAndDisabledPermission = ruleActionTypes.contains(RuleUtil.ActionType.SLACK) && !PermissionsUtil.SlackIntegrationEnabled;
                        Boolean noPagerDutyActions = !ruleActionTypes.contains(RuleUtil.ActionType.PAGERDUTY);
                        Boolean hasPagerDutyActionAndDisabledPermission = ruleActionTypes.contains(RuleUtil.ActionType.PAGERDUTY) && !PermissionsUtil.PagerDutyIntegrationEnabled;
                        Boolean noWebhookActions = !ruleActionTypes.contains(RuleUtil.ActionType.WEBHOOK);
                        Boolean hasWebhookActionAndDisabledPermission = ruleActionTypes.contains(RuleUtil.ActionType.WEBHOOK) && !PermissionsUtil.WebhookIntegrationEnabled;
                        
                        Boolean hasEmailAction = ruleActionTypes.contains(RuleUtil.ActionType.EMAIL);
    
                        if((noTeamsActions || hasTeamsActionAndDisabledPermission)
                            && (noSlackActions || hasSlackActionAndDisabledPermission)
                            && (noPagerDutyActions || hasPagerDutyActionAndDisabledPermission)
                            && (noWebhookActions || hasWebhookActionAndDisabledPermission)
                            && !hasEmailAction ) break;
                    }

                    config.addToRun((String)rule.id);
                    addRecordToUpdateMap(recordId, isTicketingRule(rule), config);
                    if (NotificationService.transactionIds == null) {
                        NotificationService.transactionIds = new Set<String>();
                    }
                    NotificationService.transactionIds.add(String.valueOf(recordId));
                    break;
                }
            }
        }
    }
    
    public virtual String addExecutableRuleId(String ruleValue, Set<String> addedRuleIds) {
        Set<String> existRuleIds = String.isBlank(ruleValue)
            ? new Set<String>()
            : (Set<String>)JSON.deserialize(ruleValue, Set<String>.class);
        existRuleIds.addAll(addedRuleIds);
        return JSON.serialize(existRuleIds);
    }

    public virtual Boolean isSObjectRecordPending(SObject record, SObject oldRecord, String fieldName, String pendingStatus) {
        if(String.isBlank(fieldName)) return false;
        String statusNewValue = record.get(fieldName) != null ? String.valueOf(record.get(fieldName)) : null;
        String statusOldValue = (oldRecord != null && oldRecord.get(fieldName) != null) ? String.valueOf(oldRecord.get(fieldName)) : null;
        if(oldRecord != null
            && (statusOldValue != statusNewValue
            && statusNewValue == pendingStatus)) {
            return true;
        }
        return false;
    }
    
    public virtual Boolean isSObjectNotificationsPending(SObject record, SObject oldRecord) {
        return isSObjectRecordPending(record, oldRecord, getNotificationStatusFieldName(), Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING);
    }
    
    public virtual Boolean isSObjectTicketingPending(SObject record, SObject oldRecord) {
        return isSObjectRecordPending(record, oldRecord, getTicketingStatusFieldName(), Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING);
    }

    public virtual List<NotificationService.ActionIteration> getActionIterations(SObject record) {
        List<NotificationService.ActionIteration> iterations = new List<NotificationService.ActionIteration>();
        
        NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(record);
        List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
        
        if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
            executableRulesIds.addAll(config.getAllExecutedRuleIds());
        }
        
        String ruleSobjectType = getRuleSobjectType(record);
        List<RuleUtil.Rule> notificationRules = RuleUtil.getNotificationRules(executableRulesIds, ruleSobjectType);
        List<RuleUtil.Rule> ticketingRules = getTicketingRules(executableRulesIds, ruleSobjectType);
        
        Integer iterationCounter = 1;
        
        for (RuleUtil.Rule rule : notificationRules) {
            if (rule.actions != null) {
                for (RuleUtil.Action action : rule.actions) {
                    iterationCounter++;
                    NotificationService.ActionIteration iteration = new NotificationService.ActionIteration(
                        (String)record.get('Id'),
                        iterationCounter,
                        0,
                        action.type,
                        String.valueOf(action.id)
                    );
                    iterations.add(iteration);
                }
            }
        }
        
        for (RuleUtil.Rule rule : ticketingRules) {
            if (rule.actions != null) {
                for (RuleUtil.Action action : rule.actions) {
                    iterationCounter++;
                    NotificationService.ActionIteration iteration = new NotificationService.ActionIteration(
                        (String)record.get('Id'),
                        iterationCounter,
                        0,
                        action.type,
                        String.valueOf(action.id)
                    );
                    iterations.add(iteration);
                }
            }
        }
        
        List<NotificationService.ActionIteration> autoChartIterations = AutoChart.getAutoChartIterations(record, executableRulesIds, ruleSobjectType);
        if (!autoChartIterations.isEmpty()) {
            iterations.addAll(autoChartIterations);
        }
        
        Integer totalIterations = iterations.size() + 1;
        for (NotificationService.ActionIteration iteration : iterations) {
            iteration.totalIterations = totalIterations;
        }
        
        return iterations;
    }

    public virtual void executeActionIteration(NotificationService.ActionIteration iteration) {
        executeActionIteration(iteration, null);
    }

    public virtual void executeActionIteration(NotificationService.ActionIteration iteration, NotificationService.BatchContextManager batchContextManager) {
        executeSlackActionIteration(iteration, batchContextManager);
    }

    private void executeSlackActionIteration(NotificationService.ActionIteration iteration, NotificationService.BatchContextManager batchContextManager) {
        if (iteration.actionType != Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION) {
            return;
        }
        
        if (iteration.iterationNumber > 1) {
            NotificationService.safeSleep(1000);
        }
        
        populateRules();
        this.record = getSObjectRecordDetails();
        
        if (!this.notificationRules.isEmpty()) {
            RuleUtil.Rule rule = this.notificationRules.get(0);

            NotificationService.ActionProcessor processor;
            if (batchContextManager != null) {
                processor = new NotificationService.ActionProcessor(this.recordId, this.logErrors, this.record, batchContextManager);
            } else {
                processor = new NotificationService.ActionProcessor(this.recordId, this.logErrors, this.record);
            }

            processor.processSpecificAction(rule.actions, iteration.actionId, iteration.actionType);
            
            createLogErrors();
            BlurModeService.incrementNotifications24hrCounter();
        }
    }
    
    // Static helper methods for record filtering
    public static Boolean isBroadcastLog(Log__c newLog, Log__c oldLog) {
        if(newLog.Originated_From__c == ConfigUtil.ORIGINATED_FROM_BROADCAST && oldLog == null) {
            return true;
        }
        return false;
    }

    public static Boolean isInternalErrorLog(Log__c newLog, Log__c oldLog) {
        if(newLog.Category__c == Logger.CATEGORY_PHAROS_ERROR && newLog.Area__c == Logger.AREA_PHAROS_ERROR) {
            return true;
        }
        return false;
    }

    public static Boolean isRegularErrorLogPostprocessingCompleted(Log__c newLog, Log__c oldLog) {
        if(newLog.Type__c != Constants.FLOW.FLOW_TYPE_ORCHESTRATOR && oldLog != null && newLog.Post_Processing_Status__c != oldLog.Post_Processing_Status__c
            && newLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Log__c newLog, Log__c oldLog) {
        if(newLog.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Log__c newLog, Log__c oldLog) {
        if(newLog.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }
}