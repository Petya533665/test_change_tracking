public with sharing class NotificationService {

    public ENUM NOTIFICATION_SERVICE_TYPE {LOG, ISSUE, TRACE_RESULT, EVENT_ACTION}
    
    public enum ActionStatus {
        PENDING,
        COMPLETED,
        RATE_LIMITED,
        FAILED
    }
    private Logger logger;
    private NotificationServiceInterface strategy;

    public static final Integer QUERY_LIMIT = 200;
    public static final Integer MAX_NOTIFICATION_ATTEMPTS = 2;

    public static Set<String> transactionIds = new Set<String>();
    public static Set<String> newIssueInTransactionIds = new Set<String>();
    public static Map<String, NotificationService.ExecutableRulesConfig> mapConfigsInTransaction = new Map<String, NotificationService.ExecutableRulesConfig>();

    public static Map<NOTIFICATION_SERVICE_TYPE, Integer> mapCountRecordsByType = new Map<NOTIFICATION_SERVICE_TYPE, Integer>();
    
    // Test visible flag to control iterator expansion behavior
    @TestVisible
    private static Boolean disableIteratorExpansion = false;
    
    /**
     * Safe sleep utility for rate limiting with governor limit protection
     * Sleeps for specified milliseconds to help with API rate limiting
     */
    @TestVisible
    private static void safeSleep(Integer milliseconds) {
        // Skip sleep in test context to avoid timeouts
        if (Test.isRunningTest()) {
            return;
        }
        
        // Limit sleep time to prevent governor limit issues (max 5 seconds)
        Integer sleepTime = Math.min(milliseconds, 5000);
        
        Long startTime = System.currentTimeMillis();
        Long endTime = startTime + sleepTime;
        
        // Simple busy wait loop with CPU time checks
        while (System.currentTimeMillis() < endTime) {
            // Check CPU time to prevent governor limit violations
            if (Limits.getCpuTime() > (Limits.getLimitCpuTime() * 0.8)) {
                break; // Exit if approaching CPU limit
            }
            
            // Small iteration to prevent infinite tight loop
            Integer dummy = Math.mod(System.now().millisecond(), 1000);
        }
    }
    
    // Interface for batch context management
    public interface BatchContextManager {
        void setIterationContext(String recordId, ActionIteration iteration);
        ActionIteration getIterationContext(String recordId);
        void clearIterationContext(String recordId);
    }
    
    // Base implementation of BatchContextManager to eliminate duplicate code across batch classes
    public abstract class BaseBatchContextManager implements BatchContextManager {
        // Instance variables to store iteration contexts between batch executions
        protected Map<String, List<ActionIteration>> recordIterationQueues = new Map<String, List<ActionIteration>>();
        protected Map<String, ActionIteration> recordCurrentIterations = new Map<String, ActionIteration>();
        
        public void setIterationContext(String recordId, ActionIteration iteration) {
            // Add to the queue for this record
            if (!this.recordIterationQueues.containsKey(recordId)) {
                this.recordIterationQueues.put(recordId, new List<ActionIteration>());
            }
            this.recordIterationQueues.get(recordId).add(iteration);
            
            // If this is the first iteration added, set it as current
            if (!this.recordCurrentIterations.containsKey(recordId)) {
                this.recordCurrentIterations.put(recordId, iteration);
            }
        }
        
        public ActionIteration getIterationContext(String recordId) {
            return this.recordCurrentIterations.get(recordId);
        }
        
        public void clearIterationContext(String recordId) {
            // Move to next iteration instead of fully clearing
            List<ActionIteration> queue = this.recordIterationQueues.get(recordId);
            if (queue != null && !queue.isEmpty()) {
                // Remove the completed iteration from the queue
                queue.remove(0);
                
                if (!queue.isEmpty()) {
                    // Set the next iteration as current
                    ActionIteration nextIteration = queue[0];
                    this.recordCurrentIterations.put(recordId, nextIteration);
                } else {
                    // No more iterations, clear everything
                    this.recordCurrentIterations.remove(recordId);
                    this.recordIterationQueues.remove(recordId);
                }
            }
        }
    }
    
    // Test helper methods for controlling iterator behavior
    @TestVisible
    public static void enableIteratorExpansionForTests() {
        disableIteratorExpansion = false; // Enable expansion by setting disable flag to false
    }
    
    @TestVisible
    public static void disableIteratorExpansionForTests() {
        disableIteratorExpansion = true; // Disable expansion by setting disable flag to true (default test behavior)
    }

    public static void incrementCountRecords(NOTIFICATION_SERVICE_TYPE serviceType) {
        if(NotificationService.mapCountRecordsByType.get(serviceType) == null) {
            NotificationService.mapCountRecordsByType.put(serviceType, 1);
        }
        else {
            Integer counter = NotificationService.mapCountRecordsByType.get(serviceType);
            NotificationService.mapCountRecordsByType.put(serviceType, counter++);
        }
    }
    public static void addToMapCountRecordsByType(Schema.SObjectType sobjectType) {
        if(sobjectType == Log__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.LOG);
        }
        if(sobjectType == Issue__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.ISSUE);
        }
        if(sobjectType == Trace_Result__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.TRACE_RESULT);
        }
    }

    public NotificationService(NOTIFICATION_SERVICE_TYPE serviceType, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE.get(serviceType);
    }

    public static NotificationService getInstance(NOTIFICATION_SERVICE_TYPE serviceType, Logger logger) {
        return new NotificationService(serviceType, logger);
    }

    public NotificationService(String className, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE_BY_NAME.get(className);
    }

    public void startNotificationBatch() {
        this.strategy.startNotificationBatch();
    }

    public Boolean isPermissionEnabled() {
        return this.strategy.isPermissionEnabled();
    }

    public Integer getSObjectRecordsCount() {
        return this.strategy.getSObjectRecordsCount();
    }

    public Database.QueryLocator getQueryLocator() {
        return this.strategy.getQueryLocator();
    }

    public void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, BatchContextManager batchContextManager) {
        this.strategy.batchExecuteIteration(info, scope, batchContextManager);
    }

    public void finish(Database.BatchableContext info) {
        this.strategy.finish(info);
    }

    public void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.strategy.runNotificationRulesHandler(newList, oldMap);
    }

    public void executeNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.strategy.executeNotificationRulesHandler(newList, oldMap);
    }

    public static DateTime getNotificationTimeStamp() {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_NOTIFICATION_TIMESTAMP);
        DateTime value = cacheObject != null ? (DateTime)cacheObject : null;
        if(value == Datetime.newInstance(0)) return null;
        return value;
    }

    public static void putNotificationTimeStamp(DateTime dt) {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        dt = dt == null ? Datetime.newInstance(0) : dt;
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_NOTIFICATION_TIMESTAMP, dt);
    }


    public interface NotificationServiceInterface {

        String getNotificationStatusFieldName();
        String getTicketingStatusFieldName();
        Boolean isPermissionEnabled();

        // notifications batches
        void startNotificationBatch();
        void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, BatchContextManager batchContextManager);
        void finish(Database.BatchableContext info);
        Object notificationBatchInstance();
        void executeIteration();
        void executeIteration(ActionIteration targetIteration);
        void setIterationRecordFailedStatus();
        NotificationService.ExecutableRulesConfig clearRunningIdsInConfig(String recordId, SObject record);
        void setRecordFailedStatusThrowBySendErrors();
        void sendTicketing();
        Integer getSObjectRecordsCount();
        Integer getSobjectRecordsCountFromContext();
        String getRuleSobjectType(SObject scopeRecord);
        List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType);
        Database.QueryLocator getQueryLocator();
        NOTIFICATION_SERVICE_TYPE getServiceType();

        // trigger hanlder logic
        List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap);
        List<SObject> filterRecordsForExecuteNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap);
        List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap);
        List<SObject> filterRecordsForExecuteTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap);
        void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap);
        void executeNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap);
        void assignNotificationRules(List<MonitoringUtil.MonitoringRule> rules, List<SObject> records);

        void applyNotificationRules(List<SObject> toNotifications, Map<Id, SObject> oldMap);
        void applyJiraRules(List<SObject> toTicketing, Map<Id, SObject> oldMap);
        void applyAzureDevOpsRules(List<SObject> toTicketing, Map<Id, SObject> oldMap);
        void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config);
        Schema.SObjectField getRuleSubTypeSObjectField(MonitoringUtil.MonitoringRule rule);
        Schema.SObjectType getRecordSobjectType();

        // Action iteration methods
        List<ActionIteration> getActionIterations(SObject record);
        void executeActionIteration(ActionIteration iteration);
        
        // Bulk rule loading
        List<MonitoringUtil.MonitoringRule> getTicketingRules(List<String> executableRulesIds, String ruleSobjectType);
    }


    public abstract class NotificationServiceDefaultImpl implements NotificationServiceInterface {
        
        private String recordId;
        private SObject record;
        private Logger logger;
        private Map<Id, SObject> toUpdateRecordsMap = new Map<Id, SObject>();
        private transient ErrorsHelper logErrors;
        private List<MonitoringUtil.MonitoringRule> notificationRules = new List<MonitoringUtil.MonitoringRule>();
        private List<MonitoringUtil.MonitoringRule> ticketingRules = new List<MonitoringUtil.MonitoringRule>();
        private List<MonitoringUtil.MonitoringRule> jiraRules = new List<MonitoringUtil.MonitoringRule>();
        private List<MonitoringUtil.MonitoringRule> azureDevOpsRules = new List<MonitoringUtil.MonitoringRule>();

        public abstract Object notificationBatchInstance();
        public abstract void setRecordFailedStatusThrowBySendErrors();
        public abstract String getOrganizationIdFromSObjectRecord();
        public abstract void setIterationRecordFailedStatus();
        public abstract Database.QueryLocator getQueryLocator();
        public abstract NOTIFICATION_SERVICE_TYPE getServiceType();
        public abstract Schema.SObjectType getRecordSobjectType();
        
        public virtual Boolean isPermissionEnabled() {
            return true;
        }

        public virtual void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config) {

            SObject recordToUpdate = this.toUpdateRecordsMap.containsKey(recordId)
                ? this.toUpdateRecordsMap.get(recordId)
                : this.getRecordSobjectType().newSObject();
            recordToUpdate.put('Id', recordId);

            NotificationService.addToMapCountRecordsByType(this.getRecordSobjectType());

            if(isTicketingRule) {
                recordToUpdate.put(getTicketingStatusFieldName(), MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING);
            }
            else {
                recordToUpdate.put(getNotificationStatusFieldName(), MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING);
            }
            if(recordToUpdate.get(getExecutableRulesFieldName()) != null) {
                NotificationService.ExecutableRulesConfig existConfig = NotificationService.getExecutableRuleConfig(recordToUpdate);
                config.mergeConfig(existConfig);
            }
            recordToUpdate.put(getExecutableRulesFieldName(), config.toJSON());
            mapConfigsInTransaction.put(recordId, config);
            this.toUpdateRecordsMap.put(recordId, recordToUpdate);
        }

        public virtual void init(SObject scopeRecord) {
            this.recordId = String.valueOf(scopeRecord.get('Id'));
            this.record = scopeRecord;
            this.logErrors = new ErrorsHelper(scopeRecord);
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
            return BATCH_SERVICE_MAPPING_BY_TYPE.get(getServiceType())?.replaceFirst(ConfigUtil.NS_CLASS, '');
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

            QBuilder qb = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
                .selectFields(new Set<String>{'COUNT()'})
                .add(String.isNotBlank(getTicketingStatusFieldName()) ? QBuilder.condition(getTicketingStatusFieldName()).equalsTo(MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) : null)
                .add(String.isNotBlank(getNotificationStatusFieldName()) ? QBuilder.condition(getNotificationStatusFieldName()).equalsTo(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) : null)
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

        public virtual void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, BatchContextManager batchContextManager) {
            init(scope.get(0));
            
            // Get the current action iteration from batch context manager
            ActionIteration currentIteration = batchContextManager != null ? 
                batchContextManager.getIterationContext(this.recordId) : null;
            
            // Apply MAX_NOTIFICATION_ATTEMPTS check to ALL iterations
            Integer countIterations = getCountIterations(info);
            if (countIterations <= MAX_NOTIFICATION_ATTEMPTS) {
                if (currentIteration == null || currentIteration.iterationNumber == 1) {
                    // First iteration or no context: process actions (include Slack in tests)
                    executeIteration(currentIteration);
                } else {
                    // Subsequent iterations: process specific Slack action
                    executeIteration(currentIteration);
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
                // Use the latest config from transaction cache (includes completed actions)
                config = NotificationService.mapConfigsInTransaction.get(String.valueOf(recordId));
            } else {
                // Fallback to parsing from record field
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

        public virtual void populateRules() {
            NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(this.record);
            List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
            String ruleSobjectType = getRuleSobjectType(this.record);

            if(executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                executableRulesIds.addAll(config.getAllExecutedRuleIds());
            }
            
            this.notificationRules = MonitoringUtil.getNotificationRules(executableRulesIds, ruleSobjectType);
            this.ticketingRules = getTicketingRules(executableRulesIds, ruleSobjectType);
        }

        public virtual void executeIteration() {
            executeIteration(null);
        }
        
        public virtual void executeIteration(ActionIteration targetIteration) {
            populateRules();
            
            // avoid don't execute actions with currently running refresh tokens job
            // PermissionsUtil.MaxNotifications24hr
            if (hasRunningManageTokenJobAndRelatedActions() && !BlurModeService.isAvailableNotifications24hr()) {
                return;
            }

            setRecordFailedStatusForEmptyRules();
            this.record = getSObjectRecordDetails();
            
            List<Messaging.SingleEmailMessage> emailMessages;
            
            if (targetIteration != null && targetIteration.iterationNumber > 1) {
                // Subsequent iterations: process specific action only
                executeActionIteration(targetIteration);
                emailMessages = new List<Messaging.SingleEmailMessage>();
            } else {
                // First iteration: process all non-Slack actions + one Slack action (if expansion disabled)
                Boolean includeAllSlackInFirstIteration = Test.isRunningTest() || disableIteratorExpansion;
                emailMessages = sendNotifications(targetIteration, includeAllSlackInFirstIteration);
                sendTicketing();
            }
            
            // send email after all callouts
            // avoid System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
            sendEmailMessages(emailMessages);

            createLogErrors();
            BlurModeService.incrementNotifications24hrCounter();
        }

        public virtual void createLogErrors() {
            // skip re-evaluate in execute batch
            NotificationService.transactionIds.add(this.record.Id);

            this.logErrors.createErrors(this.record, this.toUpdateRecordsMap, this.logger);
            if (!this.toUpdateRecordsMap.isEmpty()) {
                DatabaseUtils.getInstance().performUpdateDML(new List<SObject>(this.toUpdateRecordsMap.values()))
                        .handleError(NotificationServiceDefaultImpl.class.getName(), '.createLogErrors', logger);
                this.toUpdateRecordsMap.clear();
            }
        }

        public virtual void sendEmailMessages(List<Messaging.SingleEmailMessage> emailMessages) {
            if(!emailMessages.isEmpty()) {
                try {
                    sendEmail(emailMessages);
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
                MonitoringUtil.MonitoringRule rule = this.ticketingRules.get(0);
                for(MonitoringUtil.Action action : rule.actions) {
                    switch on MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(action.type) {
                        when JIRA, AZURE_DEV_OPS {
                            try {
                                TicketingService service = new TicketingService(MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(action.type), this.logger);
                                TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(this.recordId, action.fields);
                                TicketingService.TicketCreateResult newTicket = service.createTicket(data);
                                ticketId = newTicket.id;
    
                                break;
                            }
                            catch (Exception e) {
                                this.logErrors.ticketingExceptions.put(this.recordId, e);
                                logger?.add(logger.getInternalError(e, this.recordId, NotificationService.class.getName(), 'ticketingExceptions'));
                                incrementFailedIterations(this.recordId);
                            }
                        }
                        when JIRA_TICKET_COMMENT, AZURE_DEV_OPS_WORK_ITEM_COMMENT {
                            try {
                                TicketingService service = new TicketingService(MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(action.type), this.logger);
                                    TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(this.recordId, action.fields);
                                    service.createTicketComment(data);
                                    ticketId = 'comment';
                            }
                            catch(Exception e) {
                                this.logErrors.ticketingExceptions.put(this.recordId, e);
                                logger?.add(logger.getInternalError(e, this.recordId, NotificationService.class.getName(), 'ticketingExceptions'));
                                incrementFailedIterations(this.recordId);
                            }
                        }
                    }
                }
                // not executed records started by ticketing rules
                // mark as error, avoid rerun batch
                if(ticketId == null) {
                    setRecordFailedStatusThrowBySendErrors();
                }
            }
        }

        public virtual List<Messaging.SingleEmailMessage> sendNotifications() {
            return sendNotifications(null, true);
        }
        
        public virtual List<Messaging.SingleEmailMessage> sendNotifications(ActionIteration targetIteration, Boolean includeAllSlackActions) {
            if(this.notificationRules.isEmpty()) {
                return new List<Messaging.SingleEmailMessage>();
            }

            MonitoringUtil.MonitoringRule rule = this.notificationRules.get(0);
            ActionProcessor processor = new ActionProcessor(this.recordId, this.logErrors, this.record);
            
            return processor.processActionsWithSlackStrategy(rule.actions, includeAllSlackActions);
        }

        public virtual void setRecordFailedStatusForEmptyRules() {
            if(this.notificationRules.isEmpty() && this.ticketingRules.isEmpty()) {
                SObject failedRecord = PermissionsUtil.newSObject(this.logErrors.sObjectType);
                PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrId, recordId);
                PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrNotificationIntegrationStatus, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED);
                PermissionsUtil.putSObjectField(failedRecord, this.logErrors.dfrJiraIntegrationStatus, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
                this.toUpdateRecordsMap.put(this.recordId, failedRecord);
            }
        }

        public virtual List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType) {
            List<String> result = new List<String>();
            result.addAll(BATCH_LOCATOR_ADDITIONAL_FIELDS_BY_SOBJECT_TYPE.get(sobjectType));
            return result;
        }

        public virtual List<SObject> getSObjectRecordDetails(List<SObject> records) {
            List<MonitoringUtil.MonitoringRule> rules = new List<MonitoringUtil.MonitoringRule>();
            rules.addAll(this.notificationRules);
            rules.addAll(this.jiraRules);
            rules.addAll(this.azureDevOpsRules);

            List<MonitoringUtil.MonitoringRule> rulesWithSubType = new List<MonitoringUtil.MonitoringRule>();
            Schema.SObjectField subTypeField;
            for(MonitoringUtil.MonitoringRule rule : rules) {
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
                List<String> fields = MonitoringUtil.getSObjectFieldNames(MonitoringUtil.getSObjectFields(dsr, rulesWithSubType), rulesWithSubType);
                fields.add(getExecutableRulesFieldName());
                for(String field : fields) {
                    String fullFieldName = dfr.getRelationshipName() + '.' + field;
                    sobjectFieldNames.add(fullFieldName);
                }
                if(!sobjectFieldNames.isEmpty()) {
                    String query = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
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

            List<String> notificationFields = MonitoringUtil.getSObjectFieldNames(MonitoringUtil.getSObjectFields(this.record.getSObjectType().getDescribe(), this.notificationRules), this.notificationRules);
            List<String> ticketingFields = MonitoringUtil.getSObjectFieldNames(MonitoringUtil.getSObjectFields(this.record.getSObjectType().getDescribe(), this.ticketingRules), this.ticketingRules);

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

        public virtual Boolean hasTeamsActions(List<MonitoringUtil.MonitoringRule> notificationRules) {
            Set<MonitoringUtil.ActionType> notificationsRuleActionTypes = (!notificationRules.isEmpty())
            ? notificationRules.get(0).getRuleActionTypes()
            : new Set<MonitoringUtil.ActionType>();

            return notificationsRuleActionTypes?.contains(MonitoringUtil.ActionType.TEAMS);
        }

        public virtual Boolean hasTicketingAction(List<MonitoringUtil.MonitoringRule> ticketingRules) {
            return !ticketingRules.isEmpty();
        }

        public virtual List<MonitoringUtil.MonitoringRule> getTicketingRules(List<String> executableRulesIds, String ruleSobjectType){
            List<MonitoringUtil.MonitoringRule> ticketingRules = new List<MonitoringUtil.MonitoringRule>();
            List<MonitoringUtil.MonitoringRule> jiraRules = MonitoringUtil.getJiraRules(executableRulesIds, ruleSobjectType);
            List<MonitoringUtil.MonitoringRule> azureRules = MonitoringUtil.getAzureDevOpsRules(executableRulesIds, ruleSobjectType);
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

        // trigger logic handlers
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
            return RULE_SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType());
        }

        public virtual Schema.SObjectField getRuleSubTypeSObjectField(MonitoringUtil.MonitoringRule rule) {
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
                        .handleError(NotificationServiceDefaultImpl.class.getName(), '.updateFiredRecords', logger);
                this.toUpdateRecordsMap.clear();
            }
        }

        public virtual void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
            if(!isPermissionEnabled()) return;
            this.toUpdateRecordsMap = new Map<Id, SObject>();

            this.notificationRules = MonitoringUtil.getNotificationRules(null, getRuleSObjectTypeValue());
            this.jiraRules = MonitoringUtil.getJiraRules(null, getRuleSObjectTypeValue());
            this.azureDevOpsRules = MonitoringUtil.getAzureDevOpsRules(null, getRuleSObjectTypeValue());

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

        public virtual Boolean isTicketingRule(MonitoringUtil.MonitoringRule rule) {
            return rule.ruleType == MonitoringUtil.RULE_TYPE_JIRA_UPDATE || rule.ruleType == MonitoringUtil.RULE_TYPE_AZURE_DEV_OPS;
        }

        public virtual void assignNotificationRules(List<MonitoringUtil.MonitoringRule> rules, List<SObject> records) {
            assignNotificationRules(rules, records, null);
        }

        public virtual void assignNotificationRules(List<MonitoringUtil.MonitoringRule> rules, List<SObject> records, Map<Id, SObject> oldMap) {

            for(SObject record : records) {
                Id recordId = (Id)record.get('Id');
                SObject oldSObject = (oldMap != null && oldMap.containsKey(recordId)) ? oldMap.get(recordId) : null;
                NotificationService.ExecutableRulesConfig config = (mapConfigsInTransaction.containsKey(recordId))
                    ? mapConfigsInTransaction.get(recordId)
                    : NotificationService.getExecutableRuleConfig(record);

                for(MonitoringUtil.MonitoringRule rule : rules) {
                    // skip update rules on insert handlers
                    if(rule.isUpdateRule() &&
                        (oldMap == null || rule.sobjectType != Schema.SObjectType.Issue__c.getName())) {
                        continue;
                    }
                    // skip re-evaluate update rules
                    if(rule.isUpdateRule() && oldMap != null && config.getAllExecutedRuleIds().contains(rule.ruleId)) {
                        continue;
                    }
                    // skip re-evaluate already executed notification rules
                    if(!rule.isUpdateRule() && oldMap != null && rule.ruleType == MonitoringUtil.RULE_TYPE_NOTIFICATION 
                      && config.getAllExecutedRuleIds().contains(rule.ruleId)) {
                        continue;
                    }
                    // skip already executed rules
                    if(config.getAllRuleIdsToRun().contains(rule.ruleId)) {
                        continue;
                    }

                    // check if issue has fired insert notification rule
                    // issue should has only one fired insert notification rule
                    Boolean issueHasFiredInsertNotificationRule = false;
                    for(MonitoringUtil.MonitoringRule r : rules) {
                        if(!r.isUpdateRule()
                            && r.sobjectType == Schema.SObjectType.Issue__c.getName()
                            && config.getAllExecutedRuleIds().contains(r.ruleId)
                            && r.ruleType == MonitoringUtil.RULE_TYPE_NOTIFICATION) {

                            issueHasFiredInsertNotificationRule = true;
                            break;
                        }
                    }

                    // first fire ticketing rule on issue
                    Boolean firstFireTicketingRuleOnIssue = (!rule.isUpdateRule() 
                        && (rule.ruleType == MonitoringUtil.RULE_TYPE_JIRA_UPDATE 
                            || rule.ruleType == MonitoringUtil.RULE_TYPE_AZURE_DEV_OPS)
                        && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                        && oldMap != null
                        && NotificationService.newIssueInTransactionIds.contains(recordId)
                        && config.getRuleIdsToReRun().isEmpty()
                        && !config.getAllExecutedRuleIds().contains(rule.ruleId));

                    // re-run ticketing rule on issue, regressed issue
                    Boolean reRunTicketingRuleOnIssue = (!rule.isUpdateRule() 
                        && (rule.ruleType == MonitoringUtil.RULE_TYPE_JIRA_UPDATE 
                            || rule.ruleType == MonitoringUtil.RULE_TYPE_AZURE_DEV_OPS)
                        && rule.sobjectType == Schema.SObjectType.Issue__c.getName() 
                        && oldMap != null 
                        && !config.getRuleIdsToReRun().isEmpty()
                        && config.getAllExecutedRuleIds().contains(rule.ruleId));
                    
                    if(!rule.isUpdateRule() 
                        && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                        && (rule.ruleType == MonitoringUtil.RULE_TYPE_JIRA_UPDATE 
                            || rule.ruleType == MonitoringUtil.RULE_TYPE_AZURE_DEV_OPS)
                        && firstFireTicketingRuleOnIssue == false
                        && reRunTicketingRuleOnIssue == false) {

                        continue;
                    }
                    // skip re-evaluate insert notification rules on issue
                    if(!rule.isUpdateRule() 
                        && rule.sobjectType == Schema.SObjectType.Issue__c.getName()
                        && rule.ruleType == MonitoringUtil.RULE_TYPE_NOTIFICATION
                        && issueHasFiredInsertNotificationRule == true) {
                        continue;
                    }

                    // filter rules by SObject Type
                    if(rule.sobjectType != getRuleSObjectTypeValue()) continue;
                    Schema.SObjectField subTypeField = getRuleSubTypeSObjectField(rule);
    
                    Set<Id> firedIds = oldSObject == null 
                        ? rule.applyNotificationRules(new List<SObject>{record}, subTypeField)
                        : rule.applyNotificationRules(new List<SObject>{record}, subTypeField, new Map<Id, SObject>{recordId => oldSObject});
                    Set<MonitoringUtil.ActionType> ruleActionTypes = rule.getRuleActionTypes();
    
                    if(firedIds.contains(recordId)) {

                        if(!isTicketingRule(rule)) {
                            Boolean noTeamsActions = !ruleActionTypes.contains(MonitoringUtil.ActionType.TEAMS);
                            Boolean hasTeamsActionAndDisabledPermission = ruleActionTypes.contains(MonitoringUtil.ActionType.TEAMS) && !PermissionsUtil.TeamsIntegrationEnabled;
                            Boolean noSlackActions = !ruleActionTypes.contains(MonitoringUtil.ActionType.SLACK);
                            Boolean hasSlackActionAndDisabledPermission = ruleActionTypes.contains(MonitoringUtil.ActionType.SLACK) && !PermissionsUtil.SlackIntegrationEnabled;
                            Boolean noPagerDutyActions = !ruleActionTypes.contains(MonitoringUtil.ActionType.PAGERDUTY);
                            Boolean hasPagerDutyActionAndDisabledPermission = ruleActionTypes.contains(MonitoringUtil.ActionType.PAGERDUTY) && !PermissionsUtil.PagerDutyIntegrationEnabled;
                            Boolean hasEmailAction = ruleActionTypes.contains(MonitoringUtil.ActionType.EMAIL);
    
                            if((noTeamsActions || hasTeamsActionAndDisabledPermission)
                                && (noSlackActions || hasSlackActionAndDisabledPermission)
                                && (noPagerDutyActions || hasPagerDutyActionAndDisabledPermission)
                                && !hasEmailAction) break;
                        }

                        config.addToRun(rule.ruleId);
                        addRecordToUpdateMap(recordId, isTicketingRule(rule), config);
                        NotificationService.transactionIds.add(recordId);
                        // fire only first evaluated rule
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
            return isSObjectRecordPending(record, oldRecord, getNotificationStatusFieldName(), MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING);
        }
    
        public virtual Boolean isSObjectTicketingPending(SObject record, SObject oldRecord) {
            return isSObjectRecordPending(record, oldRecord, getTicketingStatusFieldName(), MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING);
        }

        // Action iteration methods
        public virtual List<ActionIteration> getActionIterations(SObject record) {
            List<ActionIteration> iterations = new List<ActionIteration>();
            
            // Get executable rules for this record
            NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(record);
            List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
            
            if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                executableRulesIds.addAll(config.getAllExecutedRuleIds());
            }
            
            // Use getRuleSobjectType to get the correct type for each service
            String ruleSobjectType = getRuleSobjectType(record);
            List<MonitoringUtil.MonitoringRule> notificationRules = MonitoringUtil.getNotificationRules(executableRulesIds, ruleSobjectType);
            List<MonitoringUtil.MonitoringRule> ticketingRules = getTicketingRules(executableRulesIds, ruleSobjectType);
            
            Integer iterationCounter = 1; // Start from 1 (0 reserved for precalculation)
            
            // Add notification actions
            for (MonitoringUtil.MonitoringRule rule : notificationRules) {
                if (rule.actions != null) {
                    for (MonitoringUtil.Action action : rule.actions) {
                        iterationCounter++;
                        ActionIteration iteration = new ActionIteration(
                            (String)record.get('Id'), 
                            iterationCounter, 
                            0, // Will be set later
                            action.type,
                            action.actionId
                        );
                        iterations.add(iteration);
                    }
                }
            }
            
            // Add ticketing actions
            for (MonitoringUtil.MonitoringRule rule : ticketingRules) {
                if (rule.actions != null) {
                    for (MonitoringUtil.Action action : rule.actions) {
                        iterationCounter++;
                        ActionIteration iteration = new ActionIteration(
                            (String)record.get('Id'), 
                            iterationCounter, 
                            0, // Will be set later
                            action.type,
                            action.actionId
                        );
                        iterations.add(iteration);
                    }
                }
            }
            
            // Set total iterations for all
            Integer totalIterations = iterations.size() + 1; // +1 for precalculation iteration
            for (ActionIteration iteration : iterations) {
                iteration.totalIterations = totalIterations;
            }
            
            return iterations;
        }

        public virtual void executeActionIteration(ActionIteration iteration) {
            // Execute only Slack actions in subsequent iterations
            // First iteration already handles all non-Slack actions + one Slack action
            executeSlackActionIteration(iteration);
        }
        
        private void executeSlackActionIteration(ActionIteration iteration) {
            // Only process Slack actions in subsequent iterations
            if (iteration.actionType != MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION) {
                return; // Skip non-Slack actions
            }
            
            // Add 1-second sleep before individual Slack sends to help with rate limiting
            // This only applies to subsequent iterations (iteration 2+), not the first iteration
            if (iteration.iterationNumber > 1) {
                safeSleep(1000); // Sleep for 1 second
            }
            
            populateRules();
            this.record = getSObjectRecordDetails();
            
            if (!this.notificationRules.isEmpty()) {
                MonitoringUtil.MonitoringRule rule = this.notificationRules.get(0);
                ActionProcessor processor = new ActionProcessor(this.recordId, this.logErrors, this.record);
                processor.processSpecificAction(rule.actions, iteration.actionId, iteration.actionType);
                
                // IMPORTANT: Process errors after action execution
                createLogErrors();
                BlurModeService.incrementNotifications24hrCounter();
            }
        }
    }

    public class NotificationServiceLogImpl extends NotificationServiceDefaultImpl {

        public override NOTIFICATION_SERVICE_TYPE getServiceType() {
            return NOTIFICATION_SERVICE_TYPE.LOG;
        }

        public override Schema.SObjectType getRecordSobjectType() {
            return Log__c.SObjectType;
        }

        public override Object notificationBatchInstance() {
            return JiraNotificationBatch.getInstance();
        }

        public override void startNotificationBatch() {
            JiraNotificationBatch.getInstance().startBatch();
        }

        public override Database.QueryLocator getQueryLocator() {
            Datetime timestamp = (Test.isRunningTest()) ? null : NotificationService.getNotificationTimeStamp();
            Database.QueryLocator queryLocator = (timestamp != null)
            ? Database.getQueryLocator([
                SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c, Organization_Id__c
                FROM Log__c
                WHERE CreatedDate < :timestamp 
                    AND (Jira_Integration_Status__c = :MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING
                    OR Notification_Integration_Status__c = :MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING)
                ORDER BY Created_At__c
                LIMIT :QUERY_LIMIT
            ])
            : Database.getQueryLocator([
                SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c, Organization_Id__c
                FROM Log__c
                WHERE Jira_Integration_Status__c = :MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING
                    OR Notification_Integration_Status__c = :MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING
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
            if(log.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Jira_Integration_Status__c, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
            }
            if(log.Notification_Integration_Status__c == MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Notification_Integration_Status__c, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED);
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
            return result;
        }

        public override void setRecordFailedStatusThrowBySendErrors() {
            Log__c log = (Log__c)this.record;
            if(log.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
                super.addFailedRecord();
            }
        }

        public override List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<SObject> result = new List<SObject>();

            for(Log__c log : (List<Log__c>)newList) {
                Log__c oldLog = oldMap != null ? (Log__c)oldMap.get(log.Id) : null;
    
                // skip started notifications
                if(isRunningNotifications(log, oldLog)) continue;

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
    }

    public class NotificationServiceIssueImpl extends NotificationServiceDefaultImpl {

        public override NOTIFICATION_SERVICE_TYPE getServiceType() {
            return NOTIFICATION_SERVICE_TYPE.ISSUE;
        }

        public override Schema.SObjectType getRecordSobjectType() {
            return Issue__c.SObjectType;
        }

        public override Boolean isPermissionEnabled() {
            return PermissionsUtil.IssueNotificationsEnabled;
        }

        public override Object notificationBatchInstance() {
            return IssueNotificationBatch.getInstance();
        }

        public override void startNotificationBatch() {
            IssueNotificationBatch.getInstance().startBatch();
        }

        public override Database.QueryLocator getQueryLocator() {
            Database.QueryLocator queryLocator = Database.getQueryLocator([
                SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c
                FROM Issue__c
                WHERE Jira_Integration_Status__c = :MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING
                    OR Notification_Integration_Status__c = :MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING
                ORDER BY CreatedDate
                LIMIT :QUERY_LIMIT
            ]);
            return queryLocator;
        }
        
        public override String getOrganizationIdFromSObjectRecord() {
            return UserInfo.getOrganizationId();
        }

        public override void setIterationRecordFailedStatus() {
            Issue__c issue = (Issue__c)this.record;
            if(issue.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
                PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Jira_Integration_Status__c, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
            }
            if(issue.Notification_Integration_Status__c == MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
                PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Notification_Integration_Status__c, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED);
            }
            // clear running ids in config
            NotificationService.ExecutableRulesConfig config = clearRunningIdsInConfig(issue.Id, issue);
            PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Executable_Rules__c, config.toJSON());

            DatabaseUtils.getInstance().performUpdateDML(new List<Issue__c>{issue}, Schema.SObjectType.Issue__c)
                    .handleError(NotificationServiceIssueImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
        }

        public override void setRecordFailedStatusThrowBySendErrors() {
            Issue__c issue = (Issue__c)this.record;
            if(issue.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
                super.addFailedRecord();
            }
        }

        public override List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<SObject> result = new List<SObject>();

            Set<String> updateRuleIds = new Set<String>();
            if(oldMap != null) {
                for(MonitoringUtil.MonitoringRule rule : this.notificationRules) {
                    if(rule.isUpdateRule()) {
                        updateRuleIds.add(rule.ruleId);
                    }
                }
            }
            
            for(Issue__c issue : (List<Issue__c>)newList) {
                Issue__c oldIssue = oldMap != null ? (Issue__c)oldMap.get(issue.Id) : null;
    
                // skip started notifications
                if(isRunningNotifications(issue, oldIssue)) continue;

                NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);

                if(oldMap != null) {
                    if(String.isNotBlank(issue.Notification_Integration_Status__c) 
                        && issue.Notification_Integration_Status__c != MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING
                        && String.isNotBlank(issue.Executable_Rules__c)) {

                        Set<String> existExecutedRules = new Set<String>(config.getAllExecutedRuleIds());
                        Set<String> updateRuleIdsIssue = new Set<String>(updateRuleIds);
                        updateRuleIdsIssue.removeAll(existExecutedRules);
                        if(!updateRuleIdsIssue.isEmpty()) {
                            result.add(issue);
                        }
                    }
                    else if(String.isBlank(issue.Notification_Integration_Status__c)
                        && String.isBlank(issue.Executable_Rules__c)) {
                        result.add(issue);
                    } 
                }
                else {
                    if(String.isBlank(issue.Notification_Integration_Status__c)
                        && (oldMap != null && String.isBlank(issue.Executable_Rules__c))) {
                        result.add(issue);
                    }
                }
            }
            return result;
        }

        public override List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<SObject> result = new List<SObject>();

            for(Issue__c issue : (List<Issue__c>)newList) {
                Issue__c oldIssue = oldMap != null ? (Issue__c)oldMap.get(issue.Id) : null;
    
                // skip started notifications
                if(isRunningTicketing(issue, oldIssue)) continue;

                NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);
    
                if(!NotificationService.transactionIds.contains(issue.Id) 
                    && (String.isBlank(issue.Jira_Integration_Status__c) 
                    || (String.isNotBlank(issue.Jira_Integration_Status__c) 
                        && config.getRuleIdsToReRun().isEmpty() && config.getRuleIdsToRun().isEmpty()))) {
                    
                    result.add(issue);
                }
            }
            return result;
        }
    }

    public class NotificationServiceTraceResultImpl extends NotificationServiceDefaultImpl {

        public override NOTIFICATION_SERVICE_TYPE getServiceType() {
            return NOTIFICATION_SERVICE_TYPE.TRACE_RESULT;
        }

        public override Schema.SObjectType getRecordSobjectType() {
            return Trace_Result__c.SObjectType;
        }

        public override Boolean isPermissionEnabled() {
            return PermissionsUtil.DebugLogServiceEnabled;
        }

        public override Object notificationBatchInstance() {
            return TraceResultNotificationBatch.getInstance();
        }

        public override void startNotificationBatch() {
            TraceResultNotificationBatch.getInstance().startBatch();
        }

        public override Integer getSObjectRecordsCount() {
            Integer count = getSobjectRecordsCountFromContext();
            if(count != null) return count;

            QBuilder qb = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
                    .selectFields(new Set<String>{'COUNT()'})
                    .add(String.isNotBlank(getNotificationStatusFieldName()) ? QBuilder.condition(getNotificationStatusFieldName()).equalsTo(MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) : null)
                    .addLimit(QUERY_LIMIT);
            return Database.countQuery(qb.build());
        }

        public override Database.QueryLocator getQueryLocator() {
            Database.QueryLocator queryLocator = Database.getQueryLocator([
                SELECT Id, Notification_Integration_Status__c, Executable_Rules__c
                FROM Trace_Result__c
                    WHERE Notification_Integration_Status__c = :MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING
                ORDER BY CreatedDate
                LIMIT :QUERY_LIMIT
            ]);
            return queryLocator;
        }

        public override String getOrganizationIdFromSObjectRecord() {
            return UserInfo.getOrganizationId();
        }

        public override String getTicketingStatusFieldName() {
            return null;
        }

        public override void setIterationRecordFailedStatus() {
            Trace_Result__c traceResult = (Trace_Result__c)this.record;
            if(traceResult.Notification_Integration_Status__c == MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
                PermissionsUtil.putSObjectField(traceResult, Schema.SObjectType.Trace_Result__c.fields.Notification_Integration_Status__c, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED);
            }

            // clear running ids in config
            NotificationService.ExecutableRulesConfig config = clearRunningIdsInConfig(traceResult.Id, traceResult);
            PermissionsUtil.putSObjectField(traceResult, Schema.SObjectType.Trace_Result__c.fields.Executable_Rules__c, config.toJSON());

            DatabaseUtils.getInstance().performUpdateDML(new List<Trace_Result__c>{traceResult}, Schema.SObjectType.Trace_Result__c)
                    .handleError(NotificationServiceTraceResultImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
        }

        // disabled ticketing
        public override void setRecordFailedStatusThrowBySendErrors() {}
        public override void sendTicketing() {}

        public override Schema.SObjectField getRuleSubTypeSObjectField(MonitoringUtil.MonitoringRule rule) {
            if(rule.ruleSubType == ConfigUtil.ISSUE_SOBJECT_NAME) {
                return Trace_Result__c.Issue__c.getDescribe().getSObjectField();
            }
            return null;
        }
    }

    public class NotificationServiceEventActionImpl extends NotificationServiceDefaultImpl {

        public override NOTIFICATION_SERVICE_TYPE getServiceType() {
            return NOTIFICATION_SERVICE_TYPE.EVENT_ACTION;
        }

        public override Schema.SObjectType getRecordSobjectType() {
            return null;
        }

        public override Object notificationBatchInstance() {
            return NotificationBatch.getInstance();
        }

        public override void startNotificationBatch() {
            NotificationBatch.getInstance().startBatch();
        }

        public override Integer getSObjectRecordsCount() {
            Integer count = getSobjectRecordsCountFromContext();
            if(count != null) return count;

            QBuilder qb = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
                    .selectFields(new Set<String>{'COUNT()'})
                    .add(QBuilder.condition('Executed_On__c').equalsTo(null))
                    .add(QBuilder.condition('Action__c').notEqualsTo(null))
                    .addLimit(QUERY_LIMIT);
            return Database.countQuery(qb.build());
        }

        public override Database.QueryLocator getQueryLocator() {
            Database.QueryLocator queryLocator = Database.getQueryLocator([
                SELECT Id, Executed_On__c,  Type__c, Action_Type__c,
                    Action__c, Event__c, Contents__c,
                    Action__r.Body__c, Action__r.Description__c, Action__r.EmailBody__c,
                    Action__r.EmailCC__c, Action__r.EmailTemplateId__c, Action__r.EmailTo__c,
                    Action__r.JIRAAssignee__c,Action__r.JIRAAssignee_Id__c,  Action__r.JIRAComponents__c,  Action__r.JIRAEpic__c,
                    Action__r.JIRAIssueType__c,  Action__r.JIRALabels__c,  Action__r.JIRAPriority__c,
                    Action__r.JIRAProject__c,  Action__r.SlackChannels__c,  Action__r.Subject__c,
                    Action__r.Team_Id__c,Action__r.Channel_Id__c,
                    Event__r.RecordCount__c, Event__r.Criteria__c, Response__c,
                    Event__r.Records__c, Event__r.Grouped_Field_Values__c,
                    Event__r.Rule__r.EventTimeInterval__c, Event__r.CreatedDate,
                    Action__r.PagerDuty_Type__c, Action__r.Contact__c, Action__r.Additional_Metadata__c,
                    Action__r.Action_Type__c, Action__r.SobjectType__c, Action__r.Is_Update__c
                FROM EventAction__c
                WHERE Executed_On__c = NULL AND Action__c != NULL
            ]);
            return queryLocator;
        }

        public override void executeIteration() {
            executeIteration(null);
        }
        
        public override void executeIteration(ActionIteration targetIteration) {
            EventAction__c eventAction = (EventAction__c)this.record;
            String actionType = eventAction.Action_Type__c != null ? eventAction.Action_Type__c : eventAction.Type__c;

            List<AsyncApexJob> manageTokensJob = DatabaseUtils.getCurrentJobs(new List<String>{'ManageTokensBatch'});
            if((MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(actionType) == MonitoringUtil.ActionType.TEAMS
                || MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(actionType) == MonitoringUtil.ActionType.JIRA)
                && !manageTokensJob.isEmpty()) {
                return;
            }

            Boolean notificationSuccessful = true;
            try {
                sendNotification(actionType, eventAction);
            }
            catch(Exception e) {
                notificationSuccessful = false;
                logger?.addInternalError(e, NotificationService.class.getName(), 'sendNotification');
                
                // Always set Response__c for exceptions - ticketing services need to handle their own success cases
                PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, e.getMessage());
                
                DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
                        .handleError(NotificationServiceEventActionImpl.class.getName(), '.executeIteration', logger);
            }
            
            // Always set the execution timestamp
            PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Executed_On__c, Datetime.now());
            
            // For successful executions, only update the timestamp (ticketing actions already updated their own fields)
            if (notificationSuccessful) {
                // Create a minimal EventAction with just Id and Executed_On__c to avoid overwriting fields set by sendTicketing
                EventAction__c updateRecord = new EventAction__c();
                updateRecord.Id = eventAction.Id;
                updateRecord.Executed_On__c = Datetime.now();
                
                DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{updateRecord}, Schema.SObjectType.EventAction__c)
                        .handleError(NotificationServiceEventActionImpl.class.getName(), '.executeIteration', logger);
            } else {
                // For failed executions, update the full record
                DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
                        .handleError(NotificationServiceEventActionImpl.class.getName(), '.executeIteration', logger);
            }
        }

        public void sendNotification(String actionType, EventAction__c eventAction) {
            switch on MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(actionType) {
                when TEAMS {
                    sendTeams(eventAction.Event__c, eventAction.Action__r);
                }
                when EMAIL {
                    sendEmail(new List<Messaging.SingleEmailMessage>{createEmailMessage(eventAction.Event__c, eventAction.Action__r)});
                }
                when SLACK {
                    sendSlack(eventAction.Event__c, eventAction.Action__r);
                }
                when JIRA, AZURE_DEV_OPS {
                    sendTicketing(MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(actionType), eventAction, this.logger);
                }
                when PAGERDUTY {
                    sendPagerDuty(eventAction.Event__c, eventAction.Action__r);
                }
            }
        }

        public override String getOrganizationIdFromSObjectRecord() {
            return UserInfo.getOrganizationId();
        }

        public override void setIterationRecordFailedStatus() {
            EventAction__c eventAction = (EventAction__c)this.record;
            PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Executed_On__c, Datetime.now());
            PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, PREVENT_RECURSION_RESPONSE_MESSAGE);
            DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
                    .handleError(NotificationServiceEventActionImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
        }

        public override void setRecordFailedStatusThrowBySendErrors() {}
        public override void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config) {}
        
        // EventActions don't use the rule-based system, so we override this to do nothing
        public override void setRecordFailedStatusForEmptyRules() {
            // EventActions handle their own error logic in executeIteration()
        }
        
        // EventActions have all data pre-loaded from the query, no additional fields needed
        public override List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType) {
            return new List<String>(); // Return empty list instead of trying to access map
        }
        
        // EventActions don't need the complex record details processing
        public override SObject getSobjectRecordDetails() {
            return this.record; // Return the record as-is since all data is already loaded
        }
        
        // EventActions handle errors directly in executeIteration, no need for ErrorsHelper
        public override void createLogErrors() {
            // EventActions don't use the ErrorsHelper approach
            // Errors are handled directly in executeIteration() method
            // No additional error processing needed
        }

        // Simple processAction method for EventAction compatibility
        public void processAction(MonitoringUtil.Action action) {
            // EventActions don't use the ActionProcessor framework
            // This method is here for compatibility but shouldn't be called
            // EventActions are processed directly in executeIteration()
        }

        public void processSpecificAction(List<MonitoringUtil.Action> actions, String targetActionId, String targetActionType) {
            for (MonitoringUtil.Action action : actions) {
                if (action.actionId == targetActionId && action.type == targetActionType) {
                    processAction(action);
                    break;
                }
            }
        }
    }

    public static void incrementFailedIterations(String recordId) {
        String recordKey = CacheUtils.KEY_NOTIFICATION_OBJECT_TRACKING + ':' + recordId;
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());

        Object cacheObject = cacheUtil.getValue(recordKey);
        Integer count = cacheObject != null ? (Integer)cacheObject + 1 : 1;
        cacheUtil.putValue(recordKey, count);
    }

    public class ErrorsHelper {

        public Map<Id, List<System.Exception>> emailExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> slackExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> pagerDutyExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> teamsExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, System.Exception> ticketingExceptions = new Map<Id, System.Exception>();
        public Schema.DescribeSObjectResult sObjectType;
        public Schema.DescribeFieldResult dfrId;
        public Schema.DescribeFieldResult dfrBugTracker;
        public Schema.DescribeFieldResult dfrJiraIntegrationStatus;
        public Schema.DescribeFieldResult dfrNotificationIntegrationStatus;
        public Schema.DescribeFieldResult dfrEmailIntegrationStatus;
        public Schema.DescribeFieldResult dfrPagerDutyIntegrationStatus;
        public Schema.DescribeFieldResult dfrSlackIntegrationStatus;
        public Schema.DescribeFieldResult dfrTeamsIntegrationStatus;
        public Schema.DescribeFieldResult dfrExecutableRules;

        public ErrorsHelper(SObject sobjectRecord) {
            if(sobjectRecord.getSObjectType() == Schema.sObjectType.Log__c.SObjectType) {
                sObjectType = Schema.sObjectType.Log__c;
                dfrId = Schema.sObjectType.Log__c.fields.Id;
                dfrBugTracker = Schema.sObjectType.Log__c.fields.Bug_Tracker__c;
                dfrJiraIntegrationStatus = Schema.sObjectType.Log__c.fields.Jira_Integration_Status__c;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Log__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = Schema.sObjectType.Log__c.fields.Email_Integration_Status__c;
                dfrPagerDutyIntegrationStatus = Schema.sObjectType.Log__c.fields.PagerDuty_Integration_Status__c;
                dfrSlackIntegrationStatus = Schema.sObjectType.Log__c.fields.Slack_Integration_Status__c;
                dfrTeamsIntegrationStatus = Schema.sObjectType.Log__c.fields.Teams_Integration_Status__c;
                dfrExecutableRules = Schema.sObjectType.Log__c.fields.Executable_Rules__c;
            }
            else if(sobjectRecord.getSObjectType() == Schema.sObjectType.Issue__c.SObjectType) {
                sObjectType = Schema.sObjectType.Issue__c;
                dfrId = Schema.sObjectType.Issue__c.fields.Id;
                dfrBugTracker = Schema.sObjectType.Issue__c.fields.Bug_Tracker__c;
                dfrJiraIntegrationStatus = Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c;
                dfrPagerDutyIntegrationStatus = Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c;
                dfrSlackIntegrationStatus = Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c;
                dfrTeamsIntegrationStatus = Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c;
                dfrExecutableRules = Schema.sObjectType.Issue__c.fields.Executable_Rules__c;
            }
            else if(sobjectRecord.getSObjectType() == Schema.sObjectType.Trace_Result__c.SObjectType) {
                sObjectType = Schema.sObjectType.Trace_Result__c;
                dfrId = Schema.sObjectType.Trace_Result__c.fields.Id;
                dfrBugTracker = null;
                dfrJiraIntegrationStatus = null;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Trace_Result__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = null;
                dfrPagerDutyIntegrationStatus = null;
                dfrSlackIntegrationStatus = null;
                dfrTeamsIntegrationStatus = null;
                dfrExecutableRules = Schema.sObjectType.Trace_Result__c.fields.Executable_Rules__c;
            }
        }

        public void createErrors(SObject record, Map<Id, SObject> toUpdateRecordsMap, Logger logger) {
            Id recordId = (String)record.get('Id');
            SObject failedRecord = (toUpdateRecordsMap.containsKey(recordId))
                ? toUpdateRecordsMap.get(recordId)
                : PermissionsUtil.newSObject(sObjectType);
            PermissionsUtil.putSObjectField(failedRecord, dfrId, recordId);

            // Get the latest action state from transaction cache or from record
            NotificationService.ExecutableRulesConfig config;
            if (NotificationService.mapConfigsInTransaction.containsKey(String.valueOf(recordId))) {
                // Use the latest config from transaction cache (includes completed actions)
                config = NotificationService.mapConfigsInTransaction.get(String.valueOf(recordId));
            } else {
                // Fallback to parsing from record field
                config = NotificationService.getExecutableRuleConfig(record);
            }
            
            config.clearRunningIds();
            PermissionsUtil.putSObjectField(failedRecord, dfrExecutableRules, config.toJSON());

            List<System.Exception> emailExceptionsList = emailExceptions.get(recordId);
            List<System.Exception> slackExceptionsList = slackExceptions.get(recordId);
            List<System.Exception> pagerDutyExceptionsList = pagerDutyExceptions.get(recordId);
            List<System.Exception> teamsExceptionsList = teamsExceptions.get(recordId);

            if(emailExceptionsList != null && !emailExceptions.isEmpty()) {
                for(System.Exception e : emailExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'emailExceptions'));
                }
            }
            if(slackExceptionsList != null && !slackExceptionsList.isEmpty()) {
                for(System.Exception e : slackExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'slackExceptions'));
                }
            }
            if(pagerDutyExceptionsList != null && !pagerDutyExceptionsList.isEmpty()) {
                for(System.Exception e : pagerDutyExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'pagerDutyExceptions'));
                }
            }
            if(teamsExceptionsList != null && !teamsExceptionsList.isEmpty()) {
                for(System.Exception e : teamsExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'teamsExceptions'));
                }
            }

            if((emailExceptionsList == null || emailExceptionsList.isEmpty())
                && (teamsExceptionsList == null || teamsExceptionsList.isEmpty())
                && (slackExceptionsList == null || slackExceptionsList.isEmpty())
                && (pagerDutyExceptionsList == null || pagerDutyExceptionsList.isEmpty())) {

                PermissionsUtil.putSObjectField(failedRecord, dfrNotificationIntegrationStatus, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_COMPLETED);
            }
            else {
                String emailExceptionValue = (emailExceptionsList != null && !emailExceptionsList.isEmpty())
                    ? emailExceptionsList.get(0).getMessage().abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD)
                    : null;
                String pagerDutyExceptionValue = (pagerDutyExceptionsList != null && !pagerDutyExceptionsList.isEmpty())
                    ? pagerDutyExceptionsList.get(0).getMessage().abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD)
                    : null;
                String slackExceptionValue = (slackExceptionsList != null && !slackExceptionsList.isEmpty())
                    ? slackExceptionsList.get(0).getMessage().abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD)
                    : null;
                String teamsExceptionValue = (teamsExceptionsList != null && !teamsExceptionsList.isEmpty())
                    ? teamsExceptionsList.get(0).getMessage().abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD)
                    : null;
                if(dfrEmailIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrEmailIntegrationStatus, emailExceptionValue);
                }
                if(dfrPagerDutyIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrPagerDutyIntegrationStatus, pagerDutyExceptionValue);
                }
                if(dfrSlackIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrSlackIntegrationStatus, slackExceptionValue);
                }
                if(dfrSlackIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrTeamsIntegrationStatus, teamsExceptionValue);
                }
                PermissionsUtil.putSObjectField(failedRecord, dfrNotificationIntegrationStatus, MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED);

                incrementFailedIterations(recordId);
            }
            toUpdateRecordsMap.put(recordId, failedRecord);
        }
    }

    public static Messaging.SingleEmailMessage createEmailMessage(String recordId, Action__c action) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (action.EmailTemplateId__c != null && action.Contact__c != null) {
            mail.setTargetObjectId(action.Contact__c);
            mail.setTemplateId(action.EmailTemplateId__c);
            mail.setWhatId(recordId);
        }
        else {
            mail.setBccSender(false);
            mail.setUseSignature(false);
            List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.EmailBody__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
            mail.setSubject(mergedMessages.get(0));
            mail.setHtmlBody(mergedMessages.get(1));
            mail.setToAddresses(new List<String>{action.EmailTo__c});
        }
        if (action.EmailCC__c != null)  mail.setCcAddresses(new List<String>{action.EmailCC__c});
        return mail;
    }

    public static void sendEmail(List<Messaging.SingleEmailMessage> emailMessages) {
        if (!Test.isRunningTest()) Messaging.sendEmail(emailMessages);
    }

    public static void sendTeams(String recordId, Action__c action) {
        if(!PermissionsUtil.TeamsIntegrationEnabled || !ConfigUtil.GRAPH_API_SETTINGS.Enabled__c) {
            return;
        }

        GraphAPIService.GraphApiSetting settings = new GraphAPIService.GraphApiSetting(action.Team_Id__c, action.Channel_Id__c);
        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);
        GraphAPIService.ChatMessage chatMessage = new GraphAPIService.ChatMessage(subject, body);
        GraphAPIService.sendChannelMessage(settings.teamId, settings.channelId, chatMessage);
    }

    public static void sendSlack(String recordId, Action__c action) {
        if(!PermissionsUtil.SlackIntegrationEnabled) {
            return;
        }
        
        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);
        String message = subject + ConfigUtil.NEW_LINE_CARRIAGE_RETURN + body;
        SlackService.sendMessageToSlack(message, action.SlackChannels__c);
    }

    public static void sendPagerDuty(String recordId, Action__c action) {
        if(!PermissionsUtil.PagerDutyIntegrationEnabled) {
            return;
        }

        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);

        if (action.PagerDuty_Type__c == 'Incident')
            PagerDutyService.createIncident(subject,  body);
        else if (action.PagerDuty_Type__c == 'Event')
            PagerDutyService.createEvent(recordId, subject,  body);
    }

    public static void sendTicketing(MonitoringUtil.ActionType actionType, EventAction__c eventAction, Logger logger) {
        TicketingService service = new TicketingService(actionType, logger);
        TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(eventAction);
        TicketingService.TicketCreateResult newTicket = service.createTicket(data);
        
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, newTicket.id);
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Delivered_to__c, newTicket.url);
        DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
                .handleError(NotificationService.class.getName(), '.sendTicketing', logger);
    }

    public static final String PREVENT_RECURSION_RESPONSE_MESSAGE = 'Prevent recursion';

    private static final Map<Schema.SObjectType, List<String>> BATCH_LOCATOR_ADDITIONAL_FIELDS_BY_SOBJECT_TYPE = new Map<Schema.SObjectType, List<String>>{
        Log__c.SObjectType => new List<String>{'Hash_1__c','Organization_Id__c','Bug_Tracker__c','Hash_2__c','Hash_3__c','Jira_Integration_Status__c','Notification_Integration_Status__c', 'Executable_Rules__c'},
        Issue__c.SObjectType => new List<String>{'Description__c', 'Summary__c', 'Key__c', 'Bug_Tracker__c','Jira_Integration_Status__c','Notification_Integration_Status__c', 'Executable_Rules__c'},
        Trace_Result__c.SObjectType => new List<String>{'Notification_Integration_Status__c', 'Issue__c', 'Executable_Rules__c'}
    };

    private static final Map<NOTIFICATION_SERVICE_TYPE, NotificationServiceInterface> TYPE_TO_SERVICE = new Map<NOTIFICATION_SERVICE_TYPE, NotificationServiceInterface>{
        NOTIFICATION_SERVICE_TYPE.LOG => new NotificationServiceLogImpl(),
        NOTIFICATION_SERVICE_TYPE.ISSUE => new NotificationServiceIssueImpl(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => new NotificationServiceTraceResultImpl(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => new NotificationServiceEventActionImpl()
    };

    private static final Map<NOTIFICATION_SERVICE_TYPE, String> BATCH_SERVICE_MAPPING_BY_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, String>{
        NOTIFICATION_SERVICE_TYPE.LOG => JiraNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.ISSUE => IssueNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => TraceResultNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => NotificationBatch.class.getName()
    };

    private static final Map<NOTIFICATION_SERVICE_TYPE, Schema.SObjectType> SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, Schema.SObjectType>{
        NOTIFICATION_SERVICE_TYPE.LOG => Log__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.ISSUE => Issue__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => Trace_Result__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => EventAction__c.SObjectType
    };

    private static final Map<String, NotificationServiceInterface> TYPE_TO_SERVICE_BY_NAME = new Map<String, NotificationServiceInterface>{
        JiraNotificationBatch.class.getName() => new NotificationServiceLogImpl(),
        IssueNotificationBatch.class.getName() => new NotificationServiceIssueImpl(),
        TraceResultNotificationBatch.class.getName() => new NotificationServiceTraceResultImpl(),
        NotificationBatch.class.getName() => new NotificationServiceEventActionImpl()
    };

    private static final Map<NOTIFICATION_SERVICE_TYPE, String> RULE_SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, String>{
        NOTIFICATION_SERVICE_TYPE.LOG => null, // default null
        NOTIFICATION_SERVICE_TYPE.ISSUE => Schema.SObjectType.Issue__c.getName(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => Schema.SObjectType.Trace_Result__c.getName(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => null
    };


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
        if(newLog.Type__c != FlowService.FLOW_TYPE_ORCHESTRATOR && oldLog != null && newLog.Post_Processing_Status__c != oldLog.Post_Processing_Status__c
            && newLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Notification_Integration_Status__c == MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Log__c newLog, Log__c oldLog) {
        if(newLog.Notification_Integration_Status__c == MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Log__c newLog, Log__c oldLog) {
        if(newLog.Jira_Integration_Status__c == MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static List<String> renderMergeFields(String objId, List<String> messages, MergeFieldSettings settings) {
        return (new MergeFields(new Map<String, MergeFieldSettings>{
                objId => settings
        })).parse(objId, messages);
    }

    public static Map<String, List<String>> renderMergeFields(Map<String, List<String>> contentsMap) {
        return (new MergeFields()).parse(contentsMap);
    }

    public static Map<String, List<String>> renderMergeFields(Map<String, List<String>> contentsMap, Map<String, MergeFieldSettings> mergeFieldSettingsMap) {
        return (new MergeFields(mergeFieldSettingsMap)).parse(contentsMap);
    }

    public enum NotificationContext {
        EMAIL,
        SLACK,
        JIRA,
        TEAMS,
        AZURE_DEV_OPS,
        PAGERDUTY
    }

    public static final Map<String, NotificationContext> MAP_NOTIFICATION_CONTEXTS_BY_ACTION_TYPE = new Map<String, NotificationContext> {
            RuleUtil.ACTION_TYPE_EMAIL_NOTIFICATION => NotificationContext.EMAIL,
            RuleUtil.ACTION_TYPE_SLACK_NOTIFICATION => NotificationContext.SLACK,
            RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION => NotificationContext.JIRA,
            RuleUtil.ACTION_TYPE_JIRA_TICKET_COMMENT => NotificationContext.JIRA,
            RuleUtil.ACTION_TYPE_TEAMS_NOTIFICATION => NotificationContext.TEAMS,
            RuleUtil.ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION => NotificationContext.AZURE_DEV_OPS,
            RuleUtil.ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT => NotificationContext.AZURE_DEV_OPS,
            RuleUtil.ACTION_TYPE_PAGERDUTY_NOTIFICATION => NotificationContext.PAGERDUTY
    };

    public class MergeFieldSettings {
        public final NotificationContext notificationContext;

        public MergeFieldSettings(){}

        public MergeFieldSettings(String actionType){
            notificationContext = MAP_NOTIFICATION_CONTEXTS_BY_ACTION_TYPE.get(actionType);
        }
    }

    public class MergeFields {
        private final Map<String, MergeFieldSettings> mergeFieldSettingsMap;

        public MergeFields(){
            this(new Map<String, MergeFieldSettings>());
        }

        public MergeFields(Map<String, MergeFieldSettings> mergeFieldSettingsMap) {
            this.mergeFieldSettingsMap = mergeFieldSettingsMap;
        }

        public List<String> parse(String objId, List<String> contents) {
            return parse(new Map<String, List<String>>{
                objId => contents
            }).get(objId);
        }

        public Map<String, List<String>> parse(Map<String, List<String>> contentsMap) {
            Map<String, List<String>> result = new Map<String, List<String>>();
            Set<String> allFields = new Set<String>();

            Set<String> ids = contentsMap?.keySet();
            String objectAPIName = (!ids.isEmpty()) ? getObjectAPI((new List<String>(ids)).get(0)) : null;
            for (List<String> contentList : contentsMap?.values()) {
                if (contentList != null) {
                    for (String content : contentList) {
                        if (String.isNotBlank(content)) {
                            allFields.addAll(getFields(content, objectAPIName));
                        }
                    }
                }
            }

            if (String.isNotBlank(objectAPIName) && !allFields.isEmpty()) {
                Boolean needMergeAnalysis = false;
                Set<String> filteredFields = new Set<String>();
                for (String field : allFields) {
                    if (field.endsWith('.Link')) {
                        filteredFields.add(field.removeEnd('.Link'));
                    } else if (field == 'Analysis') {
                        needMergeAnalysis = true;
                    } else if (field != 'Link') {
                        filteredFields.add(field);
                    }
                }
                AIAnalysis analysis;
                if (needMergeAnalysis) {
                    analysis = AIAnalysis.getInstance(new Set<String>(ids));
                    if (analysis != null) {
                        analysis.init();
                        analysis.setVersionData();
                    }
                }
                String query = new QBuilder(objectAPIName)
                    .selectFields(filteredFields)
                    .add(QBuilder.condition('Id').isIn(':ids'))
                    .build();
                for (SObject obj : Database.query(query)) {
                    String objId = (String)obj.get('Id');
                    List<String> contents = contentsMap.get(objId);

                    Map<String, String> tempMap = new Map<String, String>();
                    for (String field : allFields) {
                        if (field == 'Link') {
                            tempMap.put(field, formatLinkField(objId));
                        } else if (field.endsWith('.Link')) {
                            tempMap.put(field, formatLinkField(String.valueOf(getFieldValue(obj, field.removeEnd('.Link')))));
                        } else if (field == 'Analysis' && analysis != null && this.mergeFieldSettingsMap?.containsKey(objId)) {
                            tempMap.put(field, analysis.getFormattedData(objId, this.mergeFieldSettingsMap.get(objId).notificationContext.name()));
                        } else {
                            tempMap.put(field, String.valueOf(getFieldValue(obj, field)));
                        }
                    }
                    List<String> contentList = new List<String>();
                    for (String content : contents) {
                        contentList.add(matchContent(content, tempMap, objectAPIName));
                    }
                    result.put(objId, contentList);
                }
            }
            else if(String.isNotBlank(objectAPIName) && allFields.isEmpty()) {
                result = contentsMap;
            }
            return result;
        }

        private final String ADO_LINK_FORMAT = '<a href=\"{0}\" target=\"_blank\">{0}</a>';
        private final String TEAMS_LINK_FORMAT = '<a href=\"{0}\" target=\"_blank\">{0}</a>';

        private String formatLinkField(String objId) {
            if(String.isNotBlank(objId)) {
                String link = ConfigUtil.BASE_URL + '/' + objId;
                if (this.mergeFieldSettingsMap?.containsKey(objId)
                        && this.mergeFieldSettingsMap.get(objId).notificationContext == NotificationContext.AZURE_DEV_OPS) {
                    link = String.format(ADO_LINK_FORMAT, new List<String>{link});
                }
                else if (this.mergeFieldSettingsMap?.containsKey(objId)
                        && this.mergeFieldSettingsMap.get(objId).notificationContext == NotificationContext.TEAMS) {
                    link = String.format(TEAMS_LINK_FORMAT, new List<String>{link});
                }
                return link;
            }
            return '';
        }

        public Object getFieldValue(SObject entity, String fieldName) {
            if(entity == null) {
                return null;
            }

            if(fieldName.contains('.')) {
                return getFieldValue(entity.getSObject(fieldName.substringBefore('.')), fieldName.substringAfter('.'));
            }
            else {
                return entity.get(fieldName);
            }
        }

        private Set<String> getFields(String content, String objectAPIName) {
            Set<String> fieldAPINames = new Set<String>();
            String markerStart = '{!' + objectAPIName + '.';
            String markerEnd = '}';
            Integer startIndex = content.indexOf(markerStart);
    
            while (startIndex != -1) {
                Integer endIndex = content.indexOf(markerEnd, startIndex + markerStart.length());
                if (endIndex != -1) {
                    String mergeField = content.substring(startIndex + markerStart.length(), endIndex);
                    fieldAPINames.add(mergeField);
                    startIndex = content.indexOf(markerStart, endIndex + markerEnd.length());
                }
                else {
                    break;
                }
            }
    
            return fieldAPINames;
        }

        private String matchContent(String content, Map<String, String> objValues, String objectAPIName) {
            if(content == null) return '';
            for(String keyFieldName : objValues.keySet()) {
                String fieldValue = objValues.get(keyFieldName);
                fieldValue = fieldValue == null ? '' : fieldValue;
                String fullName = '{!' + objectAPIName + '.' + keyFieldName + '}';
                content = content.replace(fullName, fieldValue);
            }
            return content;
        }

        private String getObjectAPI(String recordId) {
            String keyCode  = recordId.subString(0,3);
            Map<String, Schema.SObjectType> gd = ConfigUtil.MAP_GD;
            for(Schema.SObjectType objectInstance : gd.values()) {
                if(objectInstance.getDescribe().getKeyPrefix() != null && objectInstance.getDescribe().getKeyPrefix().equals(keyCode)) {
                    return objectInstance.getDescribe().getName();
                }
            }
            return null;
        }
    }

    public static ExecutableRulesConfig getExecutableRuleConfig(SObject sObjectRecord) {
        ExecutableRulesConfig result = new ExecutableRulesConfig();
        String executableRulesValue = '';
        try {
            executableRulesValue = String.valueOf(sObjectRecord.get('Executable_Rules__c'));
        }
        catch(Exception e) {}
        
        if(String.isBlank(executableRulesValue)) {
            return result;
        }
        else if (executableRulesValue.startsWith('[')) {
            List<String> oldRuleIds = new List<String>();
            try {
                oldRuleIds = (List<String>)JSON.deserialize(executableRulesValue, List<String>.class);
            }
            catch(Exception e){}
            result.init();
            result.a.addAll(oldRuleIds);
        }
        else if (executableRulesValue.startsWith('{')) {
            try {
                result = (ExecutableRulesConfig)JSON.deserialize(executableRulesValue, ExecutableRulesConfig.class);
                result.init();
            }
            catch(Exception e){}
        }
        else {
            return result;
        }
        return result;
    }

    public class ExecutableRulesConfig {
        // rule Ids to run
        public Set<String> r;
        // rule Ids for re-run (ticketing rules)
        public Set<String> rr;
        // all rule Ids
        public Set<String> a;
        // completed action IDs (minimal storage for duplicate prevention)
        public Set<String> c;

        public ExecutableRulesConfig() {
            this.r = new Set<String>();
            this.rr = new Set<String>();
            this.a = new Set<String>();
            this.c = new Set<String>();
        }



        public void init() {
            if(this.r == null) {
                this.r = new Set<String>();
            }
            if(this.rr == null) {
                this.rr = new Set<String>();
            }
            if(this.a == null) {
                this.a = new Set<String>();
            }
            if(this.c == null) {
                this.c = new Set<String>();
            }
        }

        public void addToRun(Set<String> ruleIds) {
            this.r.addAll(ruleIds);
            this.a.addAll(ruleIds);
        }

        public void addToReRun(Set<String> ruleIds) {
            this.rr.addAll(ruleIds);
            this.a.addAll(ruleIds);
        }

        public void addToRun(String ruleId) {
            this.r.add(ruleId);
            this.a.add(ruleId);
        }

        public void addToReRun(String ruleId) {
            this.rr.add(ruleId);
            this.a.add(ruleId);
        }

        public Set<String> getAllExecutedRuleIds() {
            return this.a;
        }

        public Set<String> getRuleIdsToRun() {
            return this.r;
        }

        public Set<String> getRuleIdsToReRun() {
            return this.rr;
        }

        public Set<String> getAllRuleIdsToRun() {
            Set<String> all =new Set<String>();
            all.addAll(this.r);
            all.addAll(this.rr);
            return all;
        }

        public void clearRunningIds() {
            this.r = new Set<String>();
            this.rr = new Set<String>();
        }

        public String toJSON() {
            return JSON.serialize(this);
        }

        public void mergeConfig(ExecutableRulesConfig configToMerge) {
            if(!configToMerge?.r?.isEmpty()) {
                this.r.addAll(configToMerge.r);
            }
            if(!configToMerge?.rr?.isEmpty()) {
                this.rr.addAll(configToMerge.rr);
            }
            if(!configToMerge?.a?.isEmpty()) {
                this.a.addAll(configToMerge.a);
            }
            if(!configToMerge?.c?.isEmpty()) {
                this.c.addAll(configToMerge.c);
            }
        }

        // Minimal action completion tracking (for duplicate prevention only)
        public void markActionCompleted(String actionId) {
            if (String.isNotBlank(actionId)) {
                this.c.add(actionId);
            }
        }

        public Boolean isActionCompleted(String actionId) {
            return String.isNotBlank(actionId) && this.c.contains(actionId);
        }

        public Boolean hasCompletedActions() {
            return !this.c.isEmpty();
        }

        public List<String> getCompletedActions() {
            return new List<String>(this.c);
        }

        public void clearCompletedActions() {
            this.c.clear();
        }

        public Boolean hasCompletedAction(String actionId) {
            return isActionCompleted(actionId);
        }

        // Context-aware Slack action processing (use runtime context instead of stored types)
        public Boolean hasSlackActionsToProcess(List<MonitoringUtil.Action> actions) {
            if (actions == null) return false;
            
            for (MonitoringUtil.Action action : actions) {
                if (action.type == MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION 
                    && !isActionCompleted(action.actionId)) {
                    return true;
                }
            }
            return false;
        }

        public List<String> getPendingSlackActions(List<MonitoringUtil.Action> actions) {
            List<String> pendingSlackActions = new List<String>();
            if (actions == null) return pendingSlackActions;
            
            for (MonitoringUtil.Action action : actions) {
                if (action.type == MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION 
                    && !isActionCompleted(action.actionId)) {
                    pendingSlackActions.add(action.actionId);
                }
            }
            return pendingSlackActions;
        }
    }

    // Simplified state management utility methods
    public static void persistActionState(String recordId, ExecutableRulesConfig config) {
        if (String.isBlank(recordId) || config == null) {
            return;
        }
        
        try {
            // Update transaction cache only - DML will be handled by createErrors method
            mapConfigsInTransaction.put(recordId, config);
                           
        } catch (Exception e) {
            // Log error but don't fail the entire process
            Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'persistActionState');
        }
    }
    
    private static Schema.SObjectType getRecordSObjectType(String recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }
        
        String keyPrefix = recordId.substring(0, 3);
        
        // Check common types
        if (keyPrefix == Log__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Log__c.SObjectType;
        } else if (keyPrefix == Issue__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Issue__c.SObjectType;
        } else if (keyPrefix == Trace_Result__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Trace_Result__c.SObjectType;
        }
        
        // Default to Log__c if unknown
        return Log__c.SObjectType;
    }

    // Action iteration tracking for custom iterator
    public class ActionIteration {
        public String recordId;
        public Integer iterationNumber;
        public Integer totalIterations;
        public String actionType;
        public String actionId;
        
        public ActionIteration(String recordId, Integer iterationNumber, Integer totalIterations) {
            this.recordId = recordId;
            this.iterationNumber = iterationNumber;
            this.totalIterations = totalIterations;
        }
        
        public ActionIteration(String recordId, Integer iterationNumber, Integer totalIterations, String actionType, String actionId) {
            this(recordId, iterationNumber, totalIterations);
            this.actionType = actionType;
            this.actionId = actionId;
        }
    }
    
    /**
     * Interface for handling different types of notification actions
     */
    public interface ActionHandler {
        void execute(String recordId, Action__c actionFields);
        void handleException(String recordId, Exception e, ErrorsHelper logErrors);
        String getActionType();
    }

    /**
     * Centralized exception handling utility for notification actions
     */
    public class ActionExceptionHandler {
        public void executeWithExceptionHandling(
            ActionHandler handler, 
            String recordId, 
            Action__c actionFields, 
            ErrorsHelper logErrors
        ) {
            try {
                handler.execute(recordId, actionFields);
            } catch (Exception e) {
                handler.handleException(recordId, e, logErrors);
            }
        }
    }

    /**
     * Email notification action handler
     * Note: Email actions are handled differently since they need to be collected and sent in batches
     */
    public class EmailActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            // Email actions are handled separately in sendNotifications method
            // This handler is for consistency but actual execution happens elsewhere
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.emailExceptions.get(recordId) != null
                ? logErrors.emailExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.emailExceptions.put(recordId, exceptions);
        }

        public String getActionType() {
            return MonitoringUtil.ACTION_TYPE_EMAIL_NOTIFICATION;
        }
    }

    /**
     * Slack notification action handler
     */
    public class SlackActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            // SlackService.sendMessageToSlack() already handles rate limiting internally
            sendSlack(recordId, actionFields);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.slackExceptions.get(recordId) != null
                ? logErrors.slackExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.slackExceptions.put(recordId, exceptions);
        }

        public String getActionType() {
            return MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION;
        }
    }

    /**
     * Teams notification action handler
     */
    public class TeamsActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            sendTeams(recordId, actionFields);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.teamsExceptions.get(recordId) != null
                ? logErrors.teamsExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.teamsExceptions.put(recordId, exceptions);
        }

        public String getActionType() {
            return MonitoringUtil.ACTION_TYPE_TEAMS_NOTIFICATION;
        }
    }

    /**
     * PagerDuty notification action handler
     */
    public class PagerDutyActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            sendPagerDuty(recordId, actionFields);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.pagerDutyExceptions.get(recordId) != null
                ? logErrors.pagerDutyExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.pagerDutyExceptions.put(recordId, exceptions);
        }

        public String getActionType() {
            return MonitoringUtil.ACTION_TYPE_PAGERDUTY_NOTIFICATION;
        }
    }

    /**
     * Registry for managing action handlers
     */
    public class ActionHandlerRegistry {
        private Map<String, ActionHandler> handlers = new Map<String, ActionHandler>();
        
        public ActionHandlerRegistry() {
            registerHandler(new EmailActionHandler());
            registerHandler(new SlackActionHandler());
            registerHandler(new TeamsActionHandler());
            registerHandler(new PagerDutyActionHandler());
        }
        
        private void registerHandler(ActionHandler handler) {
            handlers.put(handler.getActionType(), handler);
        }
        
        public ActionHandler getHandler(String actionType) {
            return handlers.get(actionType);
        }
        
        public Boolean hasHandler(String actionType) {
            return handlers.containsKey(actionType);
        }
        
        public Set<String> getSupportedActionTypes() {
            return handlers.keySet();
        }
    }

    /**
     * Centralized action processor that replaces duplicate switch statement logic
     * Enhanced with rate limiting support
     */
    public class ActionProcessor {
        private String recordId;
        private ErrorsHelper logErrors;
        private ActionHandlerRegistry registry;
        private ActionExceptionHandler exceptionHandler;
        private ExecutableRulesConfig config;
        private SObject record; // Add record reference to load config from database
        
        public ActionProcessor(String recordId, ErrorsHelper logErrors) {
            this.recordId = recordId;
            this.logErrors = logErrors;
            this.registry = new ActionHandlerRegistry();
            this.exceptionHandler = new ActionExceptionHandler();
            
            // Get config from transaction cache first
            this.config = mapConfigsInTransaction.get(recordId);
            if (this.config == null) {
                // Fallback: try to get the record and load config from Executable_Rules__c field
                this.config = loadConfigFromRecord(recordId);
            }
        }
        
        /**
         * Constructor that accepts the record directly (more efficient)
         */
        public ActionProcessor(String recordId, ErrorsHelper logErrors, SObject record) {
            this.recordId = recordId;
            this.logErrors = logErrors;
            this.registry = new ActionHandlerRegistry();
            this.exceptionHandler = new ActionExceptionHandler();
            this.record = record;
            
            // Get config from transaction cache first
            this.config = mapConfigsInTransaction.get(recordId);
            if (this.config == null) {
                // Load config from the provided record
                this.config = NotificationService.getExecutableRuleConfig(record);
            }
        }
        
        /**
         * Load configuration from record in database
         */
        private ExecutableRulesConfig loadConfigFromRecord(String recordId) {
            try {
                // Determine record type and query appropriately
                Schema.SObjectType recordType = getRecordSObjectType(recordId);
                if (recordType == null) {
                    return new ExecutableRulesConfig(); // Fallback to empty config
                }
                
                String query = 'SELECT Id, Executable_Rules__c FROM ' + recordType.getDescribe().getName() + ' WHERE Id = :recordId LIMIT 1';
                List<SObject> records = Database.query(query);
                
                if (!records.isEmpty()) {
                    return NotificationService.getExecutableRuleConfig(records[0]);
                }
            } catch (Exception e) {
                // Log error but don't fail the entire process
                Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'loadConfigFromRecord');
            }
            
            // Fallback to empty config if record not found or error occurred
            return new ExecutableRulesConfig();
        }
        
        /**
         * Process a single action using the appropriate handler with rate limit awareness
         */
        public void processAction(MonitoringUtil.Action action) {
            ActionHandler handler = registry.getHandler(action.type);
            if (handler != null) {
                exceptionHandler.executeWithExceptionHandling(handler, this.recordId, action.fields, this.logErrors);
            }
        }
        
        /**
         * Process actions with Slack iteration strategy enhanced with rate limiting support
         */
        public List<Messaging.SingleEmailMessage> processActionsWithSlackStrategy(
            List<MonitoringUtil.Action> actions, 
            Boolean includeAllSlackActions
        ) {
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            Boolean slackActionProcessed = false;
            
            for (MonitoringUtil.Action action : actions) {
                String actionType = action.type;
                
                if (actionType == MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION) {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.actionId)) {
                        continue; // Skip already completed actions
                    }
                    
                    Boolean shouldProcessSlackAction = includeAllSlackActions || !slackActionProcessed;
                    if (shouldProcessSlackAction) {
                        try {
                            processAction(action);
                            markActionCompleted(action.actionId);
                            slackActionProcessed = true;
                        } catch (Exception e) {
                            // SlackService.sendMessageToSlack() already handles rate limits internally
                            // If we get a rate limit exception, we'll handle it normally through error processing
                            throw e;
                        }
                    }
                } 
                // Special handling for EMAIL actions to collect messages
                else if (actionType == MonitoringUtil.ACTION_TYPE_EMAIL_NOTIFICATION) {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.actionId)) {
                        continue; // Skip already completed actions
                    }
                    
                    emailMessages.add(createEmailMessage(this.recordId, action.fields));
                    // Mark email action as completed (they don't fail with rate limits)
                    if (action.actionId != null) {
                        markActionCompleted(action.actionId);
                    }
                }
                // Handle all other actions
                else {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.actionId)) {
                        continue; // Skip already completed actions
                    }
                    
                    processAction(action);
                    // Mark non-Slack actions as completed (they don't have rate limits)
                    if (action.actionId != null) {
                        markActionCompleted(action.actionId);
                    }
                }
            }
            
            // Persist action state after processing
            persistActionState(this.recordId, this.config);
            
            return emailMessages;
        }
        
        /**
         * Process a specific action by action ID (for iteration-specific processing)
         */
        public void processSpecificAction(List<MonitoringUtil.Action> actions, String targetActionId, String targetActionType) {
            Boolean actionFound = false;
            for (MonitoringUtil.Action action : actions) {
                if (action.actionId == targetActionId && action.type == targetActionType) {
                    // Check if action was already completed
                    if (hasCompletedAction(action.actionId)) {
                        return; // Skip already completed actions
                    }
                    
                    try {
                        processAction(action);
                        markActionCompleted(action.actionId);
                        persistActionState(this.recordId, this.config);
                        actionFound = true;
                    } catch (Exception e) {
                        // SlackService.sendMessageToSlack() already handles rate limits internally
                        // Just re-throw for normal error handling
                        throw e;
                    }
                    break;
                }
            }
        }
        
        /**
         * Check if a specific action has been completed
         */
        private Boolean hasCompletedAction(String actionId) {
            if (String.isBlank(actionId) || this.config == null) {
                return false;
            }
            return this.config.isActionCompleted(actionId);
        }
        
        /**
         * Mark an action as completed
         */
        private void markActionCompleted(String actionId) {
            if (String.isNotBlank(actionId) && this.config != null) {
                this.config.markActionCompleted(actionId);
            }
        }
        

        

    }

    // Action iteration delegation methods
    public List<ActionIteration> getActionIterations(SObject record) {
        return this.strategy.getActionIterations(record);
    }

    public void executeActionIteration(ActionIteration iteration) {
        this.strategy.executeActionIteration(iteration);
    }
    
    // Get Iterable for batch processing with custom iterations
    public Iterable<SObject> getIterableForBatch() {
        return new ActionIterationIterable(this, null, false);
    }
    
    // Get Iterable for batch processing with custom iterations and batch context manager
    public Iterable<SObject> getIterableForBatch(BatchContextManager batchContextManager) {
        return new ActionIterationIterable(this, batchContextManager, false);
    }
    
    // Get Iterable for batch processing with rate limiting awareness
    public Iterable<SObject> getIterableForBatch(BatchContextManager batchContextManager, Boolean slackRateLimited) {
        return new ActionIterationIterable(this, batchContextManager, slackRateLimited);
    }
    
    // Custom Iterable that expands records based on action count with rate limiting awareness
    public class ActionIterationIterable implements Iterable<SObject> {
        private NotificationService notificationServiceImpl;
        private BatchContextManager batchContextManager;
        private Boolean slackRateLimited;
        
        public ActionIterationIterable(NotificationService notificationServiceImpl, BatchContextManager batchContextManager, Boolean slackRateLimited) {
            this.notificationServiceImpl = notificationServiceImpl;
            this.batchContextManager = batchContextManager;
            this.slackRateLimited = slackRateLimited != null ? slackRateLimited : false;
        }
        
        public Iterator<SObject> iterator() {
            return new ActionIterationIterator(this.notificationServiceImpl, this.batchContextManager, this.slackRateLimited);
        }
    }
    
    // Custom Iterator that returns multiple iterations per record with rate limiting awareness
    public class ActionIterationIterator implements Iterator<SObject> {
        private List<IterationWrapper> expandedRecords;
        private Integer currentIndex = 0;
        private BatchContextManager batchContextManager;
        private Boolean slackRateLimited;
        
        public ActionIterationIterator(NotificationService notificationServiceImpl, BatchContextManager batchContextManager, Boolean slackRateLimited) {
            this.batchContextManager = batchContextManager;
            this.slackRateLimited = slackRateLimited != null ? slackRateLimited : false;
            this.expandedRecords = buildExpandedRecordListBulk(notificationServiceImpl);
        }
        
        public Boolean hasNext() {
            return currentIndex < expandedRecords.size();
        }
        
        public SObject next() {
            if (hasNext()) {
                IterationWrapper wrapper = expandedRecords[currentIndex++];
                
                // Set the iteration context using batch context manager
                if (this.batchContextManager != null) {
                    this.batchContextManager.setIterationContext(wrapper.recordId, wrapper.iteration);
                }
                
                return wrapper.record;
            }
            return null;
        }
        
        private List<IterationWrapper> buildExpandedRecordListBulk(NotificationService notificationServiceImpl) {
            List<IterationWrapper> result = new List<IterationWrapper>();
            
            // Step 1: Bulk load all records
            List<SObject> allRecords = getAllRecordsFromLocator(notificationServiceImpl);
            
            if (allRecords.isEmpty()) {
                return result;
            }
            
            // Step 2: Bulk load all action iterations for all records
            Map<String, List<NotificationService.ActionIteration>> recordToActionIterations = 
                bulkGetActionIterations(notificationServiceImpl, allRecords);
            
            // Step 3: Build expanded record list using cached data
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                
                // Check if this record should be filtered during Slack rate limiting
                if (this.slackRateLimited && !hasNonSlackActions(record, recordToActionIterations.get(recordId))) {
                    // Skip records with only Slack actions during rate limiting
                    continue;
                }
                
                // Add first iteration for precalculation and non-Slack actions
                NotificationService.ActionIteration firstIteration = new NotificationService.ActionIteration(recordId, 1, 0);
                result.add(new IterationWrapper(record, firstIteration));
                
                // Skip expansion if disabled (defaults to true in test context)
                if (Test.isRunningTest() && disableIteratorExpansion) {
                    continue;
                }
                
                // Get cached action iterations for this record
                List<NotificationService.ActionIteration> actionIterations = recordToActionIterations.get(recordId);
                if (actionIterations == null) {
                    continue;
                }
                
                // Add individual iterations for REMAINING Slack actions (skip first one since it's processed in first iteration)
                // Skip Slack iterations during rate limiting
                Integer slackIterationNumber = 2;
                Integer slackActionCount = 0;
                for (NotificationService.ActionIteration iteration : actionIterations) {
                    if (iteration.actionType == MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION) {
                        slackActionCount++;
                        // Skip the first Slack action since it's processed in the first iteration
                        // Also skip all Slack iterations during rate limiting
                        if (slackActionCount > 1 && !this.slackRateLimited) {
                            NotificationService.ActionIteration slackAction = new NotificationService.ActionIteration(
                                recordId, 
                                slackIterationNumber++, 
                                0, 
                                iteration.actionType, 
                                iteration.actionId
                            );
                            result.add(new IterationWrapper(record, slackAction));
                        }
                    }
                }
            }
            return result;
        }
        
        /**
         * Check if a record has any non-Slack actions
         */
        private Boolean hasNonSlackActions(SObject record, List<NotificationService.ActionIteration> actionIterations) {
            try {
                // For EventAction__c records, check Action_Type__c directly
                if (record.getSObjectType() == EventAction__c.SObjectType) {
                    String actionType = (String)record.get('Action_Type__c');
                    if (String.isBlank(actionType)) {
                        actionType = (String)record.get('Type__c');
                    }
                    return actionType != MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION;
                }
                
                // For other record types, check action iterations
                if (actionIterations == null || actionIterations.isEmpty()) {
                    return true; // Assume has non-Slack actions if no iterations
                }
                
                // Check if any action is non-Slack
                for (NotificationService.ActionIteration iteration : actionIterations) {
                    if (iteration.actionType != MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION) {
                        return true; // Found non-Slack action
                    }
                }
                
                return false; // Only Slack actions found
                
            } catch (Exception e) {
                // If error checking, assume record has non-Slack actions to be safe
                return true;
            }
        }
        
        private List<SObject> getAllRecordsFromLocator(NotificationService notificationServiceImpl) {
            List<SObject> allRecords = new List<SObject>();
            Database.QueryLocator originalLocator = notificationServiceImpl.getQueryLocator();
            Database.QueryLocatorIterator originalIterator = originalLocator.iterator();
            
            while (originalIterator.hasNext()) {
                allRecords.add(originalIterator.next());
            }
            
            return allRecords;
        }
        
        private Map<String, List<NotificationService.ActionIteration>> bulkGetActionIterations(
            NotificationService notificationServiceImpl, 
            List<SObject> allRecords
        ) {
            Map<String, List<NotificationService.ActionIteration>> result = 
                new Map<String, List<NotificationService.ActionIteration>>();
            
            if (allRecords.isEmpty()) {
                return result;
            }
            
            // Step 1: Collect all executable rule IDs for all records
            Set<String> allExecutableRuleIds = new Set<String>();
            Map<String, NotificationService.ExecutableRulesConfig> recordToConfig = 
                new Map<String, NotificationService.ExecutableRulesConfig>();
            
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(record);
                recordToConfig.put(recordId, config);
                
                List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
                if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                    executableRulesIds.addAll(config.getAllExecutedRuleIds());
                }
                allExecutableRuleIds.addAll(executableRulesIds);
            }
            
            // Step 2: Bulk load all rules once (avoid repeated SOQL queries)
            String ruleSobjectType = notificationServiceImpl.strategy.getRuleSobjectType(allRecords[0]);
            List<MonitoringUtil.MonitoringRule> allNotificationRules = 
                MonitoringUtil.getNotificationRules(new List<String>(allExecutableRuleIds), ruleSobjectType);
            List<MonitoringUtil.MonitoringRule> allTicketingRules = 
                notificationServiceImpl.strategy.getTicketingRules(new List<String>(allExecutableRuleIds), ruleSobjectType);
            
            // Step 3: Create maps for fast lookup
            Map<String, List<MonitoringUtil.MonitoringRule>> ruleIdToNotificationRules = groupRulesByRuleId(allNotificationRules);
            Map<String, List<MonitoringUtil.MonitoringRule>> ruleIdToTicketingRules = groupRulesByRuleId(allTicketingRules);
            
            // Step 4: Generate action iterations for each record using cached rules
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                NotificationService.ExecutableRulesConfig config = recordToConfig.get(recordId);
                
                List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
                if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                    executableRulesIds.addAll(config.getAllExecutedRuleIds());
                }
                
                List<NotificationService.ActionIteration> actionIterations = 
                    buildActionIterationsForRecord(recordId, executableRulesIds, ruleIdToNotificationRules, ruleIdToTicketingRules);
                result.put(recordId, actionIterations);
            }
            
            return result;
        }
        
        private Map<String, List<MonitoringUtil.MonitoringRule>> groupRulesByRuleId(List<MonitoringUtil.MonitoringRule> rules) {
            Map<String, List<MonitoringUtil.MonitoringRule>> result = new Map<String, List<MonitoringUtil.MonitoringRule>>();
            for (MonitoringUtil.MonitoringRule rule : rules) {
                if (!result.containsKey(rule.ruleId)) {
                    result.put(rule.ruleId, new List<MonitoringUtil.MonitoringRule>());
                }
                result.get(rule.ruleId).add(rule);
            }
            return result;
        }
        
        private List<NotificationService.ActionIteration> buildActionIterationsForRecord(
            String recordId, 
            List<String> executableRulesIds,
            Map<String, List<MonitoringUtil.MonitoringRule>> ruleIdToNotificationRules,
            Map<String, List<MonitoringUtil.MonitoringRule>> ruleIdToTicketingRules
        ) {
            List<NotificationService.ActionIteration> iterations = new List<NotificationService.ActionIteration>();
            Integer iterationCounter = 1; // Start from 1 (0 reserved for precalculation)
            
            // Add notification actions
            for (String ruleId : executableRulesIds) {
                List<MonitoringUtil.MonitoringRule> notificationRules = ruleIdToNotificationRules.get(ruleId);
                if (notificationRules != null) {
                    for (MonitoringUtil.MonitoringRule rule : notificationRules) {
                        if (rule.actions != null) {
                            for (MonitoringUtil.Action action : rule.actions) {
                                iterationCounter++;
                                ActionIteration iteration = new ActionIteration(
                                    recordId, 
                                    iterationCounter, 
                                    0, // Will be set later
                                    action.type,
                                    action.actionId
                                );
                                iterations.add(iteration);
                            }
                        }
                    }
                }
            }
            
            // Add ticketing actions
            for (String ruleId : executableRulesIds) {
                List<MonitoringUtil.MonitoringRule> ticketingRules = ruleIdToTicketingRules.get(ruleId);
                if (ticketingRules != null) {
                    for (MonitoringUtil.MonitoringRule rule : ticketingRules) {
                        if (rule.actions != null) {
                            for (MonitoringUtil.Action action : rule.actions) {
                                iterationCounter++;
                                ActionIteration iteration = new ActionIteration(
                                    recordId, 
                                    iterationCounter, 
                                    0, // Will be set later
                                    action.type,
                                    action.actionId
                                );
                                iterations.add(iteration);
                            }
                        }
                    }
                }
            }
            
            // Set total iterations for all
            Integer totalIterations = iterations.size() + 1; // +1 for precalculation iteration
            for (ActionIteration iteration : iterations) {
                iteration.totalIterations = totalIterations;
            }
            
            return iterations;
        }
    }
    
    // Helper class to wrap record with its iteration context
    public class IterationWrapper {
        public SObject record;
        public NotificationService.ActionIteration iteration;
        public String recordId;
        
        public IterationWrapper(SObject record, NotificationService.ActionIteration iteration) {
            this.record = record;
            this.iteration = iteration;
            this.recordId = (String)record.get('Id');
        }
    }
}