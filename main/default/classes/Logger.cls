global with sharing class Logger {

    public static final String CATEGORY_PHAROS_ERROR = 'Pharos Error';
    public static final String AREA_PHAROS_ERROR = 'Pharos';
    
    // Governor Limit Warning Constants
    public static final String WARNING_TYPE_GOVERNOR_LIMIT = 'Governor Limit Warning';
    public static final String WARNING_SUMMARY_QUEUEABLE_LIMIT = 'Queueable Job Limit Reached';
    public static final String WARNING_SUMMARY_CALLOUT_LIMIT = 'HTTP Callout Limit Reached';
    public static final String WARNING_CONTEXT_PASSTHROUGH = 'Passthrough mode enabled';
    public static final String WARNING_FALLBACK_PLATFORM_EVENTS = 'Falling back to platform events';
    
    // Governor Limit Warning Details Format Strings
    private static final String WARNING_DETAILS_QUEUEABLE_FORMAT = 
        'Queueable job limit reached ({0}/{1}). {2} to prevent log loss. Original logs count: {3}';
    private static final String WARNING_DETAILS_CALLOUT_FORMAT = 
        'HTTP callout limit reached ({0}/{1}). {2} to prevent exception. Original logs count: {3}\nContext: {4}.';

    /**
     * Get instance of the Logger.
     * Lazy loaded singleton.
     */
    global static Logger getInstance() {
        if (instance == null) {
            instance = new Logger();
        }
        return instance;
    }

    /**
     * Save log record to a buffer.
     * @param log -- log record to add.
     */
    global void add(Log__c log) {
        this.logsQueue.add(log);
    }

    /**
     * Persist buffered log records synchronously.
     * This method will perform a dml instantly.
     * 
     * Context-aware behavior:
     * - In trigger context (including platform event triggers) with passthrough mode: Uses async Queueable
     * - In all other contexts: Uses synchronous processing
     * 
     * This prevents "Callout from triggers are currently not supported" exceptions when
     * passthrough mode attempts HTTP callouts from trigger execution contexts.
     */
    global void flush() {
        // Check if we're in a trigger context (regular or platform event) AND passthrough mode is enabled
        // Trigger.isExecuting returns true for: Object triggers, Platform Event triggers
        // For testing: testOverrideTriggerContext can override the actual trigger context
        Boolean isTriggerContext = (testOverrideTriggerContext != null) ? testOverrideTriggerContext : Trigger.isExecuting;
        
        if (isTriggerContext && ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
            // Use async flush to prevent "Callout from triggers are currently not supported" exception
            // The AsyncLogSave Queueable has Database.AllowsCallouts interface for HTTP callouts
            asyncFlushInternal();
        } else {
            // Normal synchronous flush for: Batch, Queueable, Future, Scheduled, and direct invocations
            // These contexts either allow callouts directly or don't need them
            flushInternal();
        }
    }

    /**
     * Persist buffered log records asynchronously.
     * This method will perform a dml in a Queueable.
     */
    global void flushAsync() {
        asyncFlushInternal();
    }

    /**
     * Obtain a stack trace of the current execution.
     * Use this method to log stack traces when there's no Exception available.
     * Use the param to remove unwanted lines from the stack trace.
     * E.g. log util invocations that are not useful for debugging.
     * @param topOffset - number of stack trace lines to remove from the top.
     */
    global String getCurrentStackTrace(Integer topOffset) {
        return getCurrentStackTraceInternal(Math.Max(topOffset,0) + 1);
    }

    // PUBLIC
    public List<Log__c> logsQueue = new List<Log__c>();

    private static Logger instance = null;
    
    /**
     * Test support: Override trigger context detection for testing.
     * null = use actual Trigger.isExecuting value
     * true = simulate trigger context
     * false = simulate non-trigger context
     */
    @TestVisible
    private Boolean testOverrideTriggerContext = null;

    private Logger() {
    }
    
    /**
     * Test support: Set the trigger context override value for testing
     * Call on the logger instance: Logger.getInstance().setTestTriggerContext(true)
     */
    @TestVisible
    public void setTestTriggerContext(Boolean value) {
        this.testOverrideTriggerContext = value;
    }

    private String getCurrentStackTraceInternal(Integer topOffset) {
        String st;
        try {
            Integer i = 1/0;
        } catch (Exception e) {
            st = e.getStackTraceString();
        }
        if(String.isBlank(st)) return null;

        String[] lines = new String[0];
        Integer count = 0;
        topOffset++;
        for(String stLine : st.split('\n')) {
            if(count >= topOffset) {
                lines.add(stLine);
            }
            count++;
        }
        return String.join(lines, '\n');
    }

    /**
     * Async flush with queueable limit protection.
     * If queueable limit is reached, falls back to platform event publishing.
     */
    private void asyncFlushInternal() {
        // Check if we've hit the queueable jobs limit for this transaction
        if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            // Fallback: Use platform events instead of queueable
            // This ensures logs are never lost due to governor limits
            Log__c warningLog = getInstance().createGovernorLimitWarningQueueable(this.logsQueue.size());
            this.logsQueue.add(warningLog);
            DatabaseUtils.publishLogEvent(this.logsQueue);
            this.logsQueue.clear();
        } else {
            // Normal queueable execution with callout capability
            System.enqueueJob(new AsyncLogSave(this.logsQueue));
        }
    }

    private void flushInternal() {
        flushInternal(this.logsQueue);
    }

    /**
     * Internal flush implementation with callout limit protection.
     * Checks governor limits before attempting HTTP callouts in passthrough mode.
     */
    private static void flushInternal(Log__c[] logsQueue) {
        if(logsQueue == null || logsQueue.size() == 0) return;

        //set org id on all the logs
        PermissionsUtil.putSObjectFields(logsQueue, Schema.SObjectType.Log__c.fields.Organization_Id__c, UserInfo.getOrganizationId().left(15), false);
        PermissionsUtil.putSObjectFields(logsQueue, Schema.SObjectType.Log__c.fields.User_Id__c, UserInfo.getUserId(), false);

        if (ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
            // Check callout limits before attempting HTTP callout
            if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
                // Callout limit reached - fallback to platform events
                // This prevents "Too many callouts" exceptions
                Log__c warningLog = getInstance().createGovernorLimitWarningCallout(logsQueue.size());  
                logsQueue.add(warningLog);
                DatabaseUtils.publishLogEvent(logsQueue);
            } else {
                // Safe to make HTTP callout
                PassthroughtModeService.sendLogs(logsQueue);
            }
            logsQueue.clear();
            return;
        }

        DatabaseUtils.publishLogEvent(logsQueue);

        logsQueue.clear();
        return;
    }

    public class AsyncLogSave implements Queueable, Database.AllowsCallouts {
        public List<Log__c> logsQueue = new List<Log__c>();
        public AsyncLogSave(List<Log__c> logsQueue) {
            this.logsQueue = logsQueue;
        }
        public void execute(QueueableContext context) {
            Logger.flushInternal(logsQueue);
        }
    }

    public void internalError(Exception e) {
        internalError(e, null);
    }

    public void internalError(Exception e, String relatedObjectId) {
        internalError(e, relatedObjectId, false);
    }

    public void internalError(Exception e, String area, String apexName) {
        internalError(e, null, true, area, apexName);
    }

    public void internalError(Exception e, String relatedObjectId, Boolean directInsert) {
        internalError(e, relatedObjectId, directInsert, null, null);
    }

    public void internalError(Exception e, String relatedObjectId, Boolean directInsert, String area, String apexName) {
        Log__c log = getInternalError(e, relatedObjectId, area, apexName);
        if (!directInsert) {
            DatabaseUtils.publishLogEvent(new List<Log__c>{log});
        } else {
            LogEventTriggerHandler.addOrgInfoForManualLog(new List<Log__c>{log}, Datetime.now());
            DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c);
        }
    }

    public void internalError(Log__c log, Boolean directInsert) {
        if (!directInsert) {
            DatabaseUtils.publishLogEvent(new List<Log__c>{log});
        } else {
            LogEventTriggerHandler.addOrgInfoForManualLog(new List<Log__c>{log}, Datetime.now());
            DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c);
        }
    }

    /**
     * Create an internal Pharos error log with standard attributes.
     * Helper method to reduce duplication across different error/warning log types.
     * @param summary - Log summary
     * @param type - Log type
     * @param details - Log details
     * @param apexName - The method/class where the log originated
     * @return Log__c record ready to be added to queue
     */
    private Log__c createInternalLog(String summary, String type, String details, String apexName) {
        return LogBuilder.getInstance()
            .category(CATEGORY_PHAROS_ERROR)
            .summary(summary)
            .area(AREA_PHAROS_ERROR)
            .type(type)
            .details(details)
            .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
            .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), apexName)
            .build();
    }

    /**
     * Create a queueable job limit warning log.
     * Used when queueable job limit is reached and system falls back to platform events.
     * @param logsCount - Number of logs in the queue
     * @return Log__c record ready to be added to queue
     */
    public Log__c createGovernorLimitWarningQueueable(Integer logsCount) {
        String details = String.format(
            WARNING_DETAILS_QUEUEABLE_FORMAT,
            new List<String>{
                String.valueOf(Limits.getQueueableJobs()),
                String.valueOf(Limits.getLimitQueueableJobs()),
                WARNING_FALLBACK_PLATFORM_EVENTS,
                String.valueOf(logsCount)
            }
        );
        
        return createInternalLog(WARNING_SUMMARY_QUEUEABLE_LIMIT, WARNING_TYPE_GOVERNOR_LIMIT, details, 'Logger:asyncFlushInternal');
    }
    
    /**
     * Create a HTTP callout limit warning log.
     * Used when callout limit is reached in passthrough mode and system falls back to platform events.
     * @param logsCount - Number of logs in the queue
     * @return Log__c record ready to be added to queue
     */
    public Log__c createGovernorLimitWarningCallout(Integer logsCount) {
        String details = String.format(
            WARNING_DETAILS_CALLOUT_FORMAT,
            new List<String>{
                String.valueOf(Limits.getCallouts()),
                String.valueOf(Limits.getLimitCallouts()),
                WARNING_FALLBACK_PLATFORM_EVENTS,
                String.valueOf(logsCount),
                WARNING_CONTEXT_PASSTHROUGH
            }
        );
        
        return createInternalLog(WARNING_SUMMARY_CALLOUT_LIMIT, WARNING_TYPE_GOVERNOR_LIMIT, details, 'Logger:flushInternal');
    }

    public Log__c getInternalError(Exception e, String relatedObjectId, String area, String apexName) {
        String details = String.valueOf(e) + Constants.GLOBAL_VARIABLE.NEWLINE_CHARACTERS + e.getStackTraceString();
        details = (HttpUtils.enableHttpDebug)
           ? details + Constants.GLOBAL_VARIABLE.NEWLINE_CHARACTERS + HttpUtils.getHttpDebugInfo()
           : details;
        Log__c log = LogBuilder.getInstance()
                .category(CATEGORY_PHAROS_ERROR)
                .summary(e.getMessage())
                .area(AREA_PHAROS_ERROR)
                .type(String.isBlank(e.getTypeName()) ? AREA_PHAROS_ERROR : e.getTypeName())
                .stackTrace(e.getStackTraceString())
                .details(details)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), area + ':' + apexName)
                .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), String.isNotBlank(relatedObjectId) ? relatedObjectId.abbreviate(18) : relatedObjectId)
                .build();
        if (String.isNotBlank(relatedObjectId) && Schema.SObjectType.Log__c.getKeyPrefix() == relatedObjectId.substring(0, 3)) {
            PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Object_Type__c, Schema.SObjectType.Log__c.getLabel());
        }
        return log;
    }

    public Log__c getInternalError(Database.SaveResult[] srList, String relatedObjectId, String area, String apexName) {
        Log__c log;
        for(Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    log = LogBuilder.getInstance()
                        .category(CATEGORY_PHAROS_ERROR)
                        .summary(err.getMessage())
                        .area(AREA_PHAROS_ERROR)
                        .type(AREA_PHAROS_ERROR)
                        .stackTrace(err.getFields()?.toString())
                        .details(String.valueOf(err))
                        .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                        .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), area + ':' + apexName)
                        .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), String.isNotBlank(relatedObjectId) ? relatedObjectId.abbreviate(18) : relatedObjectId)
                        .build();
                    if (String.isNotBlank(relatedObjectId) && Schema.SObjectType.Log__c.getKeyPrefix() == relatedObjectId.substring(0, 3)) {
                        PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Object_Type__c, Schema.SObjectType.Log__c.getLabel());
                    }
                    break;
                }
            }
        }
        return log;
    }

    public void addInternalError(Exception e, String area, String apexName) {
        getInstance().add(getInternalError(e, null, area, apexName));
    }

    public void addInternalError(Exception e, String relatedObjectId, String area, String apexName) {
        getInstance().add(getInternalError(e, relatedObjectId, area, apexName));
    }

    public void addInternalErrors(Database.SaveResult[] saveResults, String area, String apexName) {
        List<Log__c> internalErrors = getInternalErrors(saveResults, area, apexName);
        for (Log__c log : internalErrors) {
            getInstance().add(log);
        }
    }

    public List<Log__c> getInternalErrors(Database.SaveResult[] saveResults, String area, String apexName) {
        List<Log__c> logs = new List<Log__c>();
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                Log__c log;
                for (Database.Error error : saveResult.getErrors()) {
                    log = createInternalLog(saveResult.getId(), error, area, apexName);
                    break;
                }
                logs.add(log);
            }
        }
        return logs;
    }

    public void addInternalErrors(Database.UpsertResult[] upsertResults, String area, String apexName) {
        List<Log__c> internalErrors = getInternalErrors(upsertResults, area, apexName);
        for (Log__c log : internalErrors) {
            getInstance().add(log);
        }
    }

    public List<Log__c> getInternalErrors(Database.UpsertResult[] upsertResults, String area, String apexName) {
        List<Log__c> logs = new List<Log__c>();
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (!upsertResult.isSuccess()) {
                Log__c log;
                for (Database.Error error : upsertResult.getErrors()) {
                    log = createInternalLog(upsertResult.getId(), error, area, apexName);
                    break;
                }
                logs.add(log);
            }
        }
        return logs;
    }

    public void addInternalErrors(Database.DeleteResult[] deleteResults, String area, String apexName) {
        List<Log__c> internalErrors = getInternalErrors(deleteResults, area, apexName);
        for (Log__c log : internalErrors) {
            getInstance().add(log);
        }
    }

    public List<Log__c> getInternalErrors(Database.DeleteResult[] deleteResults, String area, String apexName) {
        List<Log__c> logs = new List<Log__c>();
        for (Database.DeleteResult deleteResult : deleteResults) {
            if (!deleteResult.isSuccess()) {
                Log__c log;
                for (Database.Error error : deleteResult.getErrors()) {
                    log = createInternalLog(deleteResult.getId(), error, area, apexName);
                    break;
                }
                logs.add(log);
            }
        }
        return logs;
    }

    public Log__c createInternalLog(Id recordId, Database.Error error, String area, String apexName) {
        return LogBuilder.getInstance()
                .category(CATEGORY_PHAROS_ERROR)
                .summary(error.getMessage())
                .area(AREA_PHAROS_ERROR)
                .type(AREA_PHAROS_ERROR)
                .stackTrace(error.getFields()?.toString())
                .details(String.valueOf(error))
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), area + ':' + apexName)
                .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), recordId)
                .attribute(Schema.SObjectType.Log__c.fields.Related_Object_Type__c.getName(), recordId?.getSobjectType().getDescribe().getLabel())
                .build();
    }

    global class IssueAnalysis {
        @InvocableVariable(Label='Issue Ids' Required=true)
        global List<Id> issueIds;
    }

    @InvocableMethod(Category='Logging' Label='Issue Analysis' Description='Start Issue analysis from a flow or process builder'
    IconName='resource:pharos_logo_simple:icon')
    global static void startAnalysis(List<IssueAnalysis> issueAnalyses) {
        Set<String> issueIds = new Set<String>();
        String keyPrefix = Issue__c.getSObjectType().getDescribe().keyPrefix;
        Set<String> invalidIds = new Set<String>();
        for (IssueAnalysis issueAnalysis : issueAnalyses) {
            for (Id issueId : issueAnalysis.issueIds) {
                try {
                    String recordId = Id.valueOf(issueId);
                    if (recordId.startsWith(keyPrefix)) {
                        issueIds.add(recordId);
                    } else {
                        invalidIds.add(issueId);
                    }
                } catch (StringException e) {
                    invalidIds.add(issueId);
                }
            }
        }
        if (!invalidIds.isEmpty()) {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            Logger.getInstance().add(LogBuilder.getInstance()
                    .category(Logger.CATEGORY_PHAROS_ERROR)
                    .summary(INVALID_ISSUE_IDS_SUMMARY)
                    .details(String.format(INVALID_ISSUE_IDS_DETAILS, new List<String>{JSON.serialize(invalidIds)}))
                    .area(Logger.AREA_PHAROS_ERROR)
                    .type('Issue Analysis')
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.name, corg?.Name)
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Name__c.name, corg?.Title__c)
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Url__c.name, corg?.Instance_Url__c)
                    .createIssue()
                    .build());
            Logger.getInstance().flush();
        }
        if (!issueIds.isEmpty()) {
            OpenAIController.startAnalysis(issueIds);
        }
    }

    public static String INVALID_ISSUE_IDS_SUMMARY = 'Invalid Issue Ids provided for analysis.';
    public static String INVALID_ISSUE_IDS_DETAILS = 'The following issue ids are invalid: {0}\n' +
            'Please double check issue analysis invocable parameters in your flow.';

}