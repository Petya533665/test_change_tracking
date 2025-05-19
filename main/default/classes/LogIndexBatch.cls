public without sharing class LogIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts,Database.RaisesPlatformEvents {

    public enum JobType {INIT_INDEXES_BATCH, UPDATE_INTERNAL_FIELD_BATCH, DELETE_ABANDONED_INDEXES_BATCH}
    private JobType runJobType;

    private static LogIndexBatch instance = null;
    private DateTime lastDeleteLogBatchTimeStamp;

    public static LogIndexBatch getInstance(JobType jobType) {
        if (instance == null) {
            instance = new LogIndexBatch(jobType, Logger.getInstance());
        }
        return instance;
    }

    private LogIndexBatch(JobType jobType, Logger logger) {
        super(logger);
        this.runJobType = jobType;
        BATCH_SCOPE = getBatchScope(jobType);
        lastDeleteLogBatchTimeStamp = getLastDeleteLogBatchTimeStamp();
    }

    private static Integer getBatchScope(JobType jobType) {
        switch on jobType {
            when INIT_INDEXES_BATCH, UPDATE_INTERNAL_FIELD_BATCH {
                return 200;
            }
            when DELETE_ABANDONED_INDEXES_BATCH {
                return 100;
            }
        }
        return 200;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('LogIndexBatch', this);
    }

    public override Boolean initialValidation() {
        if (runJobType == LogIndexBatch.JobType.UPDATE_INTERNAL_FIELD_BATCH) {
            return [SELECT COUNT() FROM Log_Index__c WHERE Internal__c = TRUE LIMIT 1] == 0;
        }
        else if (runJobType == LogIndexBatch.JobType.DELETE_ABANDONED_INDEXES_BATCH) {
            return this.lastDeleteLogBatchTimeStamp != null;
        }
        return true;
    }

    public override Integer getIterationsCount() {
        if (runJobType == LogIndexBatch.JobType.DELETE_ABANDONED_INDEXES_BATCH) {
            return getLastDeleteLogBatchCount(this.lastDeleteLogBatchTimeStamp);
        }
        return [SELECT COUNT() FROM Log__c WHERE Hash_1__c != NULL];
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (runJobType == LogIndexBatch.JobType.DELETE_ABANDONED_INDEXES_BATCH) {
            return Database.getQueryLocator([
                SELECT Id, Key__c, Hash__c, Organization_Id__c FROM Log_Index__c
            ]);
        }
		return Database.getQueryLocator([
            SELECT 
                Id, Hash_1__c, Organization_Id__c, Bug_Tracker__c, First_Occurred_On__c, Resolved_On__c, Created_At__c, Area__c, Category__c
            FROM Log__c
            WHERE Hash_1__c != NULL
		]);
	}

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (runJobType == LogIndexBatch.JobType.DELETE_ABANDONED_INDEXES_BATCH) {
            deleteAbandonedLogIndexes((List<Log_Index__c>)scope, this.loggerInstance);
        }
        else if (runJobType == LogIndexBatch.JobType.UPDATE_INTERNAL_FIELD_BATCH || runJobType == LogIndexBatch.JobType.INIT_INDEXES_BATCH) {
            List<Log__c> logs = (List<Log__c>)scope;
            if (!logs.isEmpty()) {
                Set<String> logIndexKeys = new Set<String>();
                for (Log__c log : logs) {
                    logIndexKeys.add(ConfigUtil.getLogIndexKey(log?.Hash_1__c, log?.Organization_Id__c));
                }
                ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(logIndexKeys);
                if (this.runJobType == JobType.INIT_INDEXES_BATCH) {
                    for (Log__c log : logs) {
                        ConfigUtil.LogIndex index = helper.getLogIndex(log);
                        if (index == null) {
                            index = helper.createLogIndex(log);
                        }
                        if (log.First_Occurred_On__c != null && log.First_Occurred_On__c < index.firstOccurredOn) {
                            index.firstOccurredOn = log.First_Occurred_On__c;
                        }
                        if (log.Resolved_On__c != null && (log.Resolved_On__c > index.resolvedOn || index.resolvedOn == null)) {
                            index.resolvedOn = log.Resolved_On__c;
                        }
                        if (log.Bug_Tracker__c != null) {
                            index.bugTracker = log.Bug_Tracker__c;
                        }
                        helper.updateLogIndex(index);
                    }
                }
                if (this.runJobType == JobType.UPDATE_INTERNAL_FIELD_BATCH) {
                    for (Log__c log : logs) {
                        ConfigUtil.LogIndex index = helper.getLogIndex(log);
                        if (log?.Category__c == 'Pharos Error' || log.Area__c == 'Pharos') {
                            index.internal = true;
                        }
                        if (index != null) helper.updateLogIndex(index);
                    }
                }
                helper.saveLogIndexes(this.loggerInstance);
            }
        }
    }

    private void deleteAbandonedLogIndexes(List<Log_Index__c> logIndexes, Logger logger) {
        if (!logIndexes.isEmpty()) {
            try {
                List<Log_Index__c> logIndexesToDelete = new List<Log_Index__c>();

                for (Log_Index__c logIndex : logIndexes) {
                    Boolean uniqueByOrg = ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c;
                    Integer countLogs = uniqueByOrg 
                        ? [SELECT COUNT() FROM Log__c WHERE Hash_1__c = :logIndex.Hash__c AND Organization_Id__c = :logIndex.Organization_Id__c]
                        : [SELECT COUNT() FROM Log__c WHERE Hash_1__c = :logIndex.Hash__c];
                    // If there are no logs for the log index, delete the log index
                    if (countLogs == 0) {
                        logIndexesToDelete.add(logIndex);
                    }
                }

                if (!logIndexesToDelete.isEmpty()) {
                    DatabaseUtils.getInstance().performDeleteDML(logIndexesToDelete, Schema.SObjectType.Log_Index__c)
                        .handleError(LogIndexBatch.class.getName(), 'deleteAbandonedLogIndexes');
                }
			}
			catch (Exception e) {
				logger.addInternalError(e, null, LogIndexBatch.class.getName(), 'deleteAbandonedLogIndexes');
			}
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        this.loggerInstance?.flush();
        handleRestart();
    }

    private void handleRestart() {
        DateTime lastDeleteLogBatchTimeStamp = getLastDeleteLogBatchTimeStamp();
        if(lastDeleteLogBatchTimeStamp == null) return;

        // If the last delete log batch time stamp is the same as the current time stamp, set the time stamp to 0, to avoid infinite loop
        if (this.lastDeleteLogBatchTimeStamp == lastDeleteLogBatchTimeStamp) {
            putLastDeleteLogBatchTimeStamp(Datetime.newInstance(0));
        }
        // else start a new batch
        else {
            LogIndexBatch.getInstance(JobType.DELETE_ABANDONED_INDEXES_BATCH).startBatch();
        }
    }

    public static Integer getLastDeleteLogBatchCount(DateTime lastDeleteLogBatchTimeStamp) {
        if(lastDeleteLogBatchTimeStamp == null) return 0;

        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>{'COUNT()'})
            .add(QBuilder.condition('IsDeleted').equalsTo(true))
            .add(QBuilder.condition('LastModifiedDate').isGreaterOrEquals(':lastDeleteLogBatchTimeStamp'));

        String qbCountQuery = qb.build() + ' ALL ROWS';
        Integer countLogs = Database.countQuery(qbCountQuery);
        return countLogs;
    }

    public static DateTime getLastDeleteLogBatchTimeStamp() {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP);
        DateTime value = cacheObject != null ? (DateTime)cacheObject : null;
        if(value == Datetime.newInstance(0)) return null;
        return value;
    }

    public static void putLastDeleteLogBatchTimeStamp(DateTime dt) {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        dt = dt == null ? Datetime.newInstance(0) : dt;
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP, dt);
    }
}