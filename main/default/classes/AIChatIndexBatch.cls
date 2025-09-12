public without sharing class AIChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final String S3_REMOTE_SITE_NAME = 'Pharos_AI_S3_Bucket';
    private static final String S3_REMOTE_SITE_URL = 'https://ai-pharos-index.s3.amazonaws.com';
    private static final String S3_REMOTE_SITE_DESCRIPTION = 'S3 Bucket for Pharos AI indexing purposes';

    private static final Integer MAX_LOGS_PER_BATCH = 100;
    private static final Integer HEAP_SIZE_THRESHOLD = 7 * 1024 * 1024; //7MB
    
    private String uploadId;
    private String objectKey;
    private List<String> presignedUrls = new List<String>();
    private List<Map<String, Object>> uploadedParts = new List<Map<String, Object>>();
    private List<Map<String, Object>> logBuffer = new List<Map<String, Object>>();
    private Integer currentPartIndex = 0;
    private Integer totalBatches = 0;
    private Integer currentBatchNumber = 0;
    private Integer deletedLogCount = 0;
    private Boolean onlyDeletedLogsPresent = false;
    
    private AI_Chat_Index_Settings__c settingsInstance = null;
    private AI_Chat_Index_Settings__c SETTINGS {
        get {
            if (settingsInstance == null) {
                AI_Chat_Index_Settings__c settings = AI_Chat_Index_Settings__c.getOrgDefaults();
                if (settings == null || settings.Id == null) {
                    settings = new AI_Chat_Index_Settings__c();
                    settings.ProcessedLogHashes__c = 0;
                    settings.LastLogUpdateTimestamp__c = DateTime.newInstance(1970, 1, 1);
                    insert settings;
                }
                settingsInstance = settings;
            }
            return settingsInstance;
        }
        private set;
    }

    public enum JobType {LOG_INDEX_FULL_UPSERT, LOG_INDEX_UPDATE}
    private JobType runJobType;

    private static AIChatIndexBatch instance = null;
    public static AIChatIndexBatch getInstance() {
        return getInstance(JobType.LOG_INDEX_UPDATE);
    }
    public static AIChatIndexBatch getInstance(JobType jobType) {
        if (instance == null || instance.runJobType != jobType) {
            instance = new AIChatIndexBatch(jobType, Logger.getInstance());
        }
        return instance; 
    }

    private AIChatIndexBatch(JobType jobType, Logger logger) {
        super(logger);
        BATCH_SCOPE = MAX_LOGS_PER_BATCH;
        this.runJobType = jobType;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('AIChatIndexBatch', this);
    }

    public override Integer getIterationsCount() {
        Integer count = [SELECT COUNT() FROM Log_Index__c];
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            count = count - (Integer)SETTINGS.ProcessedLogHashes__c;

            this.deletedLogCount = [
                SELECT COUNT()
                FROM Log_Index__c
                WHERE IsDeleted = true AND LastModifiedDate > :SETTINGS.LastLogUpdateTimestamp__c
                ALL ROWS
            ];
            if (count == 0 && this.deletedLogCount > 0) {
                count = 1;
                this.onlyDeletedLogsPresent = true;
            }
        }
        return count;
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MetadataChatEnabled;
    }

    public Iterable<SObject> start(Database.BatchableContext batchableContext) {
        AdminService.upsertRemoteSiteSetting(S3_REMOTE_SITE_NAME, S3_REMOTE_SITE_URL, S3_REMOTE_SITE_DESCRIPTION);
        
        Integer itemsCount = getIterationsCount();
        this.totalBatches = Integer.valueOf(Math.ceil(itemsCount / Decimal.valueOf(BATCH_SCOPE)));
        initiateMultipartUpload(this.totalBatches);
        
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            if (this.onlyDeletedLogsPresent) {
                return new List<SObject>();
            }

            List<Log_Index__c> newLogIndexes = [
                SELECT Hash__c
                FROM Log_Index__c
                ORDER BY Id DESC
                LIMIT :itemsCount
            ];
            List<String> newHashes = new List<String>();
            for (Log_Index__c logIndex : newLogIndexes) {
                newHashes.add(logIndex.Hash__c);
            }

            List<AggregateResult> uniqueIds = [
                SELECT MIN(Id) uniqueId
                FROM Log__c
                WHERE Hash_1__c IN :newHashes
                GROUP BY Hash_1__c
                ORDER BY MIN(Id) DESC
            ];
            return uniqueIds;
        }
        
        List<AggregateResult> uniqueIds = [
            SELECT MIN(Id) uniqueId
            FROM Log__c
            WHERE Hash_1__c != NULL
            GROUP BY Hash_1__c
            ORDER BY MIN(Id) DESC
        ];
        return uniqueIds;
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        try {
            this.currentBatchNumber++;
            List<Map<String, Object>> transformedLogs = getTransformedLogs(scope);
            logBuffer.addAll(transformedLogs);
            
            Boolean isLastBatch = this.currentBatchNumber == this.totalBatches;
            if (Limits.getHeapSize() > HEAP_SIZE_THRESHOLD || (isLastBatch && !logBuffer.isEmpty())) {
                uploadCurrentPart(isLastBatch);
            }
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, AIChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        try {
            if (this.onlyDeletedLogsPresent) {
                uploadCurrentPart(true);
            }
            completeMultipartUpload();
            
            if (runJobType == JobType.LOG_INDEX_UPDATE) {
                SETTINGS.ProcessedLogHashes__c = [SELECT COUNT() FROM Log_Index__c];
                SETTINGS.LastLogUpdateTimestamp__c = DateTime.now();
                update SETTINGS;
            }
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, AIChatIndexBatch.class.getName(), 'finish');
        }

        this.loggerInstance?.flush();
    }
    
    private void uploadCurrentPart(Boolean lastPart) {
        try {
            String presignedUrl = this.presignedUrls[currentPartIndex];
            String partJSON = createArrayPart(logBuffer, currentPartIndex, lastPart);
            if (lastPart && this.deletedLogCount > 0) {
                List<Log_Index__c> deletedLogIndexes = [
                    SELECT Hash__c
                    FROM Log_Index__c
                    WHERE IsDeleted = true
                    AND LastModifiedDate > :SETTINGS.LastLogUpdateTimestamp__c
                    ALL ROWS
                ];
                List<String> deletedHashes = new List<String>();
                for (Log_Index__c deletedLogIndex : deletedLogIndexes) {
                    String hash = deletedLogIndex.Hash__c;
                    if (!deletedHashes.contains(hash) && [SELECT COUNT() FROM Log__c WHERE Hash_1__c = :hash] == 0) {
                        deletedHashes.add(hash);
                    }
                }

                if (this.onlyDeletedLogsPresent) {
                    partJSON = '{"deletedHashes":' + JSON.serialize(deletedHashes) + '}';
                } else {
                    partJSON = partJSON.substring(0, partJSON.length() - 1) + ',"deletedHashes":' + JSON.serialize(deletedHashes) + '}';
                }
            }

            HttpUtils.put(presignedUrl, partJSON, null, 200);
            String etag = HttpUtils.responseHeaders.get('ETag');
            
            Map<String, Object> partInfo = new Map<String, Object>{
                'ETag' => etag,
                'PartNumber' => currentPartIndex + 1
            };
            uploadedParts.add(partInfo);
            
            logBuffer.clear();
            currentPartIndex++;
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, AIChatIndexBatch.class.getName(), 'uploadCurrentPart');
            throw e;
        }
    }

    private String createArrayPart(List<Map<String, Object>> batchLogs, Integer partIndex, Boolean lastPart) {
        if (batchLogs.isEmpty()) {
            return '';
        }
        String arrayJSON = JSON.serialize(batchLogs);
        
        // Remove outer brackets from the JSON array
        String objectsJSON = arrayJSON.substring(1, arrayJSON.length() - 1);
        if (!lastPart) {
            return partIndex == 0 ? '{"logs":[' + objectsJSON : ',' + objectsJSON;
        } else {
            return partIndex == 0 ? '{"logs":[' + objectsJSON + ']}' : ',' + objectsJSON + ']}';
        }
    }

    private List<Map<String, Object>> getTransformedLogs(List<SObject> scope) {
        Set<Id> logIds = new Set<Id>();
        for (SObject record : scope) {
            logIds.add((Id)record.get('uniqueId'));
        }
        
        Set<String> fields = new Set<String>{
            'Id', 'Name', 'Hash_1__c', 'Summary__c', 'Details__c', 'Type__c', 'Category__c', 'Area__c', 'Created_At__c'
        };
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(fields)
            .add(QBuilder.condition('Id').isIn(new List<Id>(logIds)));
        List<Log__c> logs = Database.query(qb.build());

        List<Map<String, Object>> transformedLogs = new List<Map<String, Object>>();
        for (Log__c log : logs) {
            Map<String, Object> transformedLog = new Map<String, Object>();
            transformedLog.put('id', log.Id);
            transformedLog.put('name', log.Name);
            transformedLog.put('hash1', log.Hash_1__c);
            transformedLog.put('summary', log.Summary__c);
            transformedLog.put('category', log.Category__c);
            transformedLog.put('area', log.Area__c);
            transformedLog.put('created_at', log.Created_At__c);
            transformedLog.put('details', log.Details__c);
            transformedLogs.add(transformedLog);
        }
        return transformedLogs;
    }

    private void initiateMultipartUpload(Integer partsCount) {
        try {
            Map<String, Object> request = new Map<String, Object>{
                'oid' => UserInfo.getOrganizationId(),
                'parts_count' => partsCount
            };
            String response = HttpUtils.post(INDEX_MANAGER_LOGS_ENDPOINT, JSON.serialize(request), GitHubUtils.authHeaders(), 200);
            
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response);
            this.uploadId = (String) responseBody.get('upload_id');
            this.objectKey = (String) responseBody.get('object_key');
            this.presignedUrls = (List<String>)JSON.deserialize(JSON.serialize(responseBody.get('parts')), List<String>.class);
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, AIChatIndexBatch.class.getName(), 'initiateMultipartUpload');
            throw e;
        }
    }
    
    private void completeMultipartUpload() {
        try {
            Map<String, Object> request = new Map<String, Object>{
                'object_key' => this.objectKey,
                'upload_id' => this.uploadId,
                'parts' => this.uploadedParts
            };
            HttpUtils.post(INDEX_MANAGER_LOGS_ENDPOINT, JSON.serialize(request), GitHubUtils.authHeaders(), 200);
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, AIChatIndexBatch.class.getName(), 'completeMultipartUpload');
            throw e;
        }
    }
}