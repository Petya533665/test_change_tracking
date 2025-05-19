public with sharing class LogPostProcessingBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, Schedulable {

    public LogPostProcessingBatch() {
    }

    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }

    public enum BATCH_MODE {
        REGULAR_POST_PROCESSING,
        FINISH_FAILED_POST_PROCESSING_LOGS
    }

    private final BATCH_MODE currentMode;

    @TestVisible
    private static Boolean testThrowUnhandledException = false;

    private static final Integer QUERY_LIMIT = 200;

    private static LogPostProcessingBatch instance = null;

    public static LogPostProcessingBatch getInstance() {
        if (instance == null) {
            instance = new LogPostProcessingBatch(Logger.getInstance());
        }
        return instance;
    }

    private LogPostProcessingBatch(Logger logger) {
        super(logger);
        Integer logsWithStatusNeededCount = [SELECT COUNT() FROM Log__c WHERE Post_Processing_Status__c = :LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED AND Organization_Id__c != NULL LIMIT :QUERY_LIMIT];
        Integer logsWithStatusExecutedCount = [SELECT COUNT() FROM Log__c WHERE Post_Processing_Status__c = :LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED AND Organization_Id__c != NULL LIMIT :QUERY_LIMIT];
        if (logsWithStatusNeededCount > 0) {
            this.currentMode = BATCH_MODE.REGULAR_POST_PROCESSING;
        } else if (logsWithStatusExecutedCount > 0) {
            this.currentMode = BATCH_MODE.FINISH_FAILED_POST_PROCESSING_LOGS;
        }
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('LogPostProcessingBatch', this);
    }

    public override Boolean initialValidation() {
        return currentMode != null;
    }

    public override Integer getIterationsCount() {
        if (currentMode == BATCH_MODE.REGULAR_POST_PROCESSING) {
            return [SELECT COUNT() FROM Log__c WHERE Post_Processing_Status__c = :LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED AND Organization_Id__c != NULL LIMIT :QUERY_LIMIT];
        } else {
            return [SELECT COUNT() FROM Log__c WHERE Post_Processing_Status__c = :LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED AND Organization_Id__c != NULL LIMIT :QUERY_LIMIT];
        }
    }

    public Database.QueryLocator start(Database.BatchableContext info) {
        List<String> logPostProcessingStatus = (this.currentMode == BATCH_MODE.REGULAR_POST_PROCESSING)
            ? new List<String>{LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED}
            : new List<String>{LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED};
        return Database.getQueryLocator([SELECT Id, Type__c, Organization_Id__c FROM Log__c WHERE Post_Processing_Status__c IN :logPostProcessingStatus AND Organization_Id__c != NULL LIMIT :QUERY_LIMIT]);
    }

    private Map<Id, List<Exception>> exceptionMap = new Map<Id, List<Exception>>();
    private Set<Id> logIdsInTransaction = new Set<Id>();
    private Set<Id> successLogIdsInTransaction = new Set<Id>();
    private Set<Id> orchestratorSuccessLogIdsInTransaction = new Set<Id>();
    private Set<Id> orchestratorWaitingFlowLogIdsInTransaction = new Set<Id>();
    private Set<Id> orchestratorSelfLogIdsInTransaction = new Set<Id>();
    private Set<Id> orchestratorLogIdsForBroadcastInTransaction = new Set<Id>();

    public void execute(Database.BatchableContext BC, List<Log__c> scope) {
        // Counter (stored in cache) to limit Log processing number to 2 and prevent recursion
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(scope[0].Organization_Id__c);
        LogPostProcessingService.PostProcessingLogCounter logCounter = new LogPostProcessingService.PostProcessingLogCounter(corg?.Name);
        logCounter.incrementCounter(scope[0].Id);

        if (corg != null && this.currentMode == BATCH_MODE.REGULAR_POST_PROCESSING && logCounter.getCounter(scope[0].Id) <= 2) {
            this.logIdsInTransaction.add(scope[0].Id);
            try {
                LogPostProcessingService.LogPostProcessingResult result = LogPostProcessingService.doLogPostProcessing(scope[0], loggerInstance);
                this.exceptionMap.put(scope[0].Id, result.errors);

                if (result.errors.isEmpty()) {
                    successLogIdsInTransaction.add(scope[0].Id);
                    if (scope.get(0).Type__c == FlowService.FLOW_TYPE_ORCHESTRATOR) {
                        if (!result.orchestratorLogIdsForBroadcast.isEmpty()) {
                            this.orchestratorLogIdsForBroadcastInTransaction.addAll(result.orchestratorLogIdsForBroadcast);
                        }

                        LogPostProcessingService.PostProcessingOrchestratorLogCounter orchestratorLogCounter = new LogPostProcessingService.PostProcessingOrchestratorLogCounter(corg.Name);
                        switch on orchestratorLogCounter.getCounter(scope[0].Id) {
                            // orchestrator log successfully completed with related flow error
                            when 0 {
                                orchestratorSuccessLogIdsInTransaction.add(scope.get(0).Id);
                            }
                            // rerun postprocessing for orchestrator log error
                            when 1 {
                                orchestratorWaitingFlowLogIdsInTransaction.add(scope[0].Id);
                            }
                            // not find related flow errors, mark orchestrator log error as self error
                            when else {
                                orchestratorSelfLogIdsInTransaction.add(scope[0].Id);
                            }
                        }
                    }
                }
            }
            catch (Exception e) {
                if (loggerInstance != null) loggerInstance.add(loggerInstance.getInternalError(e, scope[0].Id, LogPostProcessingBatch.class.getName(), 'execute'));
                PermissionsUtil.putSObjectField(scope[0], Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_FAILED);
                DatabaseUtils.getInstance().performUpdateDML(new List<Log__c>{scope[0]}, Schema.SObjectType.Log__c)
                        .handleError(LogPostProcessingBatch.class.getName(), 'execute', loggerInstance);
            }
            this.logIdsInTransaction.remove(scope[0].Id);
        }
        else {
            PermissionsUtil.putSObjectField(scope[0], Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_FAILED);
            DatabaseUtils.getInstance().performUpdateDML(new List<Log__c>{scope[0]}, Schema.SObjectType.Log__c)
                    .handleError(LogPostProcessingBatch.class.getName(), 'execute', loggerInstance);
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (this.currentMode == BATCH_MODE.REGULAR_POST_PROCESSING) {
            // if set contains id, log transaction is failed with unexpected exception
            if (!this.logIdsInTransaction.isEmpty()) {
                for (Id logId : new List<Id>(this.logIdsInTransaction)) {
                    List<Exception> exceptions = this.exceptionMap.get(logId) != null ? this.exceptionMap.get(logId) : new List<Exception>();
                    exceptions.add(new System.LimitException());
                    this.exceptionMap.put(logId, exceptions);
                }
            }
            Map<String, Log__c> logsToCompleteFlag = new Map<String, Log__c>();
            List<Log__c> orchestratorLogsToDelete = new List<Log__c>();

            if (!this.exceptionMap.isEmpty()) {
                for (Id logId : this.exceptionMap.keySet()) {
                    Log__c log = (Log__c)PermissionsUtil.newSObject(Schema.sObjectType.Log__c);
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Id, logId);
                    if (this.orchestratorSuccessLogIdsInTransaction.contains(logId)) {
                        orchestratorLogsToDelete.add(log);
                    } else {
                        List<Exception> exceptions = this.exceptionMap.get(logId);
                        PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, !exceptions.isEmpty() ? LogPostProcessingService.POST_PROCESSING_STATUS_FAILED : LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED);
                        logsToCompleteFlag.put(logId, log);
                    }
                }
            }
            for (Id logId : new List<Id>(this.successLogIdsInTransaction)) {
                if (this.exceptionMap.containsKey(logId)) continue;

                Log__c log = (Log__c)PermissionsUtil.newSObject(Schema.sObjectType.Log__c);
                PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Id, logId);

                if (this.orchestratorSuccessLogIdsInTransaction.contains(logId)) {
                    orchestratorLogsToDelete.add(log);
                } else if (this.orchestratorWaitingFlowLogIdsInTransaction.contains(logId)) {
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED);
                    logsToCompleteFlag.put(logId, log);
                } else {
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED);
                    logsToCompleteFlag.put(logId, log);
                }
            }
            if (!orchestratorLogsToDelete.isEmpty()) {
                DatabaseUtils.getInstance().performDeleteDML(orchestratorLogsToDelete, Schema.SObjectType.Log__c)
                        .handleError(LogPostProcessingBatch.class.getName(), 'finish', loggerInstance);
            }
            if (!this.orchestratorLogIdsForBroadcastInTransaction.isEmpty()) {
                for (String relatedFlowLogId : this.orchestratorLogIdsForBroadcastInTransaction) {
                    Log__c relatedFlowLog;
                    if (logsToCompleteFlag.containsKey(relatedFlowLogId)) {
                        relatedFlowLog = logsToCompleteFlag.get(relatedFlowLogId);
                    } else {
                        relatedFlowLog = (Log__c)PermissionsUtil.newSObject(Schema.SObjectType.Log__c);
                        PermissionsUtil.putSObjectField(relatedFlowLog, Schema.SObjectType.Log__c.fields.Id, relatedFlowLogId);
                    }
                    PermissionsUtil.putSObjectField(relatedFlowLog, Schema.SObjectType.Log__c.fields.Broadcast_Status__c, BroadcastService.BROADCAST_STATUS_NEEDED);
                    logsToCompleteFlag.put(relatedFlowLogId, relatedFlowLog);
                }
            }
            if (!logsToCompleteFlag.isEmpty()) {
                DatabaseUtils.getInstance().performUpdateDML(logsToCompleteFlag.values(), Schema.SObjectType.Log__c)
                        .handleError(LogPostProcessingBatch.class.getName(), 'finish', loggerInstance);
            }
            if (loggerInstance != null) loggerInstance.flush();

            LogPostProcessingBatch.getInstance().startBatch();

            if (testThrowUnhandledException) {
                Integer i = 1/0;
            }
        }
    }

}