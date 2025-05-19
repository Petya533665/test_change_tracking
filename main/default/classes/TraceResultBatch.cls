public without sharing class TraceResultBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts,Database.RaisesPlatformEvents {

    public enum JobType {DELETE_RELATED_RECORDS}
    private JobType runJobType;

    private static TraceResultBatch instance = null;
    private DateTime lastDeleteTraceResultBatchTimeStamp;

    public static TraceResultBatch getInstance(JobType jobType) {
        if (instance == null) {
            instance = new TraceResultBatch(jobType, Logger.getInstance());
        }
        return instance;
    }

    private TraceResultBatch(JobType jobType, Logger logger) {
        super(logger);
        this.runJobType = jobType;
        BATCH_SCOPE = getBatchScope(jobType);
        lastDeleteTraceResultBatchTimeStamp = getLastDeleteTraceResultBatchTimeStamp();
    }

    private static Integer getBatchScope(JobType jobType) {
        switch on jobType {
            when DELETE_RELATED_RECORDS {
                return 10;
            }
        }
        return 200;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('TraceResultBatch', this);
    }

    public override Boolean initialValidation() {
        if (runJobType == TraceResultBatch.JobType.DELETE_RELATED_RECORDS) {
            return this.lastDeleteTraceResultBatchTimeStamp != null;
        }
        return true;
    }

    public override Integer getIterationsCount() {
        if (runJobType == TraceResultBatch.JobType.DELETE_RELATED_RECORDS) {
            return getLastDeleteTraceResultBatchCount(this.lastDeleteTraceResultBatchTimeStamp);
        }
        return 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, IsDeleted, LastModifiedDate, Issue__c
            FROM Trace_Result__c
            WHERE IsDeleted = true
            ALL ROWS
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (runJobType == TraceResultBatch.JobType.DELETE_RELATED_RECORDS) {
            deleteRelatedRecords((List<Trace_Result__c>)scope, this.loggerInstance);
        }
    }

    private void deleteRelatedRecords(List<Trace_Result__c> traceResults, Logger logger) {
        if (!traceResults.isEmpty()) {
            try {
                
                // Collect both Issue and Trace Result IDs
                Set<Id> allRecordIds = new Set<Id>();
                Set<Id> issueIds = new Set<Id>();
                Set<Id> traceResultIds = new Set<Id>();
                
                for(Trace_Result__c tr : traceResults) {
                    traceResultIds.add(tr.Id);
                    if(tr.Issue__c != null) {
                        issueIds.add(tr.Issue__c);
                        allRecordIds.add(tr.Issue__c);
                    }
                    allRecordIds.add(tr.Id);
                }
                
                // Get all ContentDocumentLinks for both Issues and Trace Results
                Map<Id, Set<Id>> contentDocToEntityIds = new Map<Id, Set<Id>>();
                
                for(ContentDocumentLink cdl : [
                    SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Type 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :allRecordIds 
                        AND LinkedEntity.Type != 'User'
                ]) {
                    if(!contentDocToEntityIds.containsKey(cdl.ContentDocumentId)) {
                        contentDocToEntityIds.put(cdl.ContentDocumentId, new Set<Id>());
                    }
                    contentDocToEntityIds.get(cdl.ContentDocumentId).add(cdl.LinkedEntityId);
                }
                
                Set<Id> contentDocsToDelete = new Set<Id>();
                
                // Check each ContentDocument's relationships
                for(Id contentDocId : contentDocToEntityIds.keySet()) {
                    Set<Id> linkedEntityIds = contentDocToEntityIds.get(contentDocId);
                    boolean hasTraceResultLink = false;
                    boolean hasIssueLink = false;
                    
                    for(Id entityId : linkedEntityIds) {
                        if(traceResultIds.contains(entityId)) {
                            hasTraceResultLink = true;
                        }
                        else if(issueIds.contains(entityId)) {
                            hasIssueLink = true;
                        }
                    }
                    
                    // If document has only Issue link and no other links, mark for deletion
                    if(hasIssueLink && !hasTraceResultLink) {
                        contentDocsToDelete.add(contentDocId);
                    }
                }
                
                if(!contentDocsToDelete.isEmpty()) {
                    List<ContentDocument> docsToDelete = [
                        SELECT Id 
                        FROM ContentDocument 
                        WHERE Id IN :contentDocsToDelete
                    ];
                    if(!docsToDelete.isEmpty()) {
                        DatabaseUtils.getInstance().performDeleteDML(docsToDelete, Schema.SObjectType.ContentDocument)
                            .handleError(TraceResultBatch.class.getName(), 'deleteRelatedRecords');
                    }
                }
            }
            catch(Exception e) {
                logger.addInternalError(e, null, TraceResultBatch.class.getName(), 'deleteRelatedRecords');
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        this.loggerInstance?.flush();
        handleRestart();
    }

    private void handleRestart() {
        DateTime lastDeleteTraceResultBatchTimeStamp = getLastDeleteTraceResultBatchTimeStamp();
        if(lastDeleteTraceResultBatchTimeStamp == null) return;

        // If the last delete log batch time stamp is the same as the current time stamp, set the time stamp to 0, to avoid infinite loop
        if (this.lastDeleteTraceResultBatchTimeStamp == lastDeleteTraceResultBatchTimeStamp) {
            putLastDeleteTraceResultBatchTimeStamp(Datetime.newInstance(0));
        }
        // else start a new batch
        else {
            TraceResultBatch.getInstance(JobType.DELETE_RELATED_RECORDS).startBatch();
        }
    }

    public static Integer getLastDeleteTraceResultBatchCount(DateTime lastDeleteTraceResultBatchTimeStamp) {
        if(lastDeleteTraceResultBatchTimeStamp == null) return 0;

        QBuilder qb = new QBuilder(Trace_Result__c.SObjectType)
            .selectFields(new Set<String>{'COUNT()'})
            .add(QBuilder.condition('IsDeleted').equalsTo(true))
            .add(QBuilder.condition('LastModifiedDate').isGreaterOrEquals(':lastDeleteTraceResultBatchTimeStamp'));

        String qbCountQuery = qb.build() + ' ALL ROWS';
        Integer countTraceResults = Database.countQuery(qbCountQuery);
        return countTraceResults;
    }

    public static DateTime getLastDeleteTraceResultBatchTimeStamp() {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP);
        DateTime value = cacheObject != null ? (DateTime)cacheObject : null;
        if(value == Datetime.newInstance(0)) return null;
        return value;
    }

    public static void putLastDeleteTraceResultBatchTimeStamp(DateTime dt) {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        dt = dt == null ? Datetime.newInstance(0) : dt;
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP, dt);
    }
}