global with sharing class Logger {

    public static final String CATEGORY_PHAROS_ERROR = 'Pharos Error';
    public static final String AREA_PHAROS_ERROR = 'Pharos';

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
     */
    global void flush() {
        flushInternal();
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

    private Logger() {
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

    private void asyncFlushInternal() {
        System.enqueueJob(new AsyncLogSave(this.logsQueue));
    }

    private void flushInternal() {
        flushInternal(this.logsQueue);
    }

    private static void flushInternal(Log__c[] logsQueue) {
        if(logsQueue == null || logsQueue.size() == 0) return;

        //set org id on all the logs
        PermissionsUtil.putSObjectFields(logsQueue, Schema.SObjectType.Log__c.fields.Organization_Id__c, UserInfo.getOrganizationId().left(15), false);
        PermissionsUtil.putSObjectFields(logsQueue, Schema.SObjectType.Log__c.fields.User_Id__c, UserInfo.getUserId(), false);

        if (ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
            PassthroughtModeService.sendLogs(logsQueue);
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

    public Log__c getInternalError(Exception e, String relatedObjectId, String area, String apexName) {
        String details = String.valueOf(e) + ConfigUtil.NEW_LINE_CARRIAGE_RETURN + e.getStackTraceString();
        details = (HttpUtils.enableHttpDebug)
           ? details + ConfigUtil.NEW_LINE_CARRIAGE_RETURN + HttpUtils.getHttpDebugInfo()
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