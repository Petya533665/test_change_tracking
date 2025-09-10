public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final String S3_REMOTE_SITE_NAME = 'Pharos_AI_S3_Bucket';
    private static final String S3_REMOTE_SITE_URL = 'https://ai-pharos-index.s3.amazonaws.com';
    private static final String S3_REMOTE_SITE_DESCRIPTION = 'S3 Bucket for Pharos AI indexing purposes';

    private static final Integer MAX_LOGS_PER_BATCH = 40; //TODO: change to 200
    
    private String uploadId;
    private String objectKey;
    private List<String> presignedUrls = new List<String>();
    private List<Map<String, Object>> uploadedParts = new List<Map<String, Object>>();
    
    private static Chat_Index_Settings__c settingsInstance = null;
    private static Chat_Index_Settings__c SETTINGS {
        get {
            if (settingsInstance == null) {
                Chat_Index_Settings__c settings = Chat_Index_Settings__c.getOrgDefaults();
                if (settings == null || settings.Id == null) {
                    settings = new Chat_Index_Settings__c();
                    settings.ProcessedLogHashes__c = 0;
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

    private static ChatIndexBatch instance = null;
    public static ChatIndexBatch getInstance(JobType jobType) {
        if (instance == null) {
            instance = new ChatIndexBatch(jobType, Logger.getInstance());
        }
        return instance; 
    }

    private ChatIndexBatch(JobType jobType, Logger logger) {
        super(logger);
        BATCH_SCOPE = MAX_LOGS_PER_BATCH;
        this.runJobType = jobType;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('ChatIndexBatch', this);
    }

    public override Integer getIterationsCount() {
        Integer count = [SELECT COUNT() FROM Log_Index__c];
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            count = count - (Integer)SETTINGS.ProcessedLogHashes__c;
        }
        return count;
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MetadataChatEnabled;
    }

    public Iterable<SObject> start(Database.BatchableContext batchableContext) {
        AdminService.upsertRemoteSiteSetting(S3_REMOTE_SITE_NAME, S3_REMOTE_SITE_URL, S3_REMOTE_SITE_DESCRIPTION);
        
        Integer itemsCount = getIterationsCount();
        initiateMultipartUpload(Math.max(1, itemsCount / BATCH_SCOPE));
        
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
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
        if (scope == null || scope.isEmpty()) {
            return;
        }
        
        System.debug('++++ChatIndexBatch: Executing batch with ' + scope.size() + ' records');
        try {
            List<Map<String, Object>> transformedLogs = getTransformedLogs(scope);
            uploadBatchAsPart(transformedLogs);
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('++++ChatIndexBatch: Finishing batch job');
        
        try {
            completeMultipartUpload();
            if (runJobType == JobType.LOG_INDEX_UPDATE) {
                SETTINGS.ProcessedLogHashes__c = [SELECT COUNT() FROM Log_Index__c];
                update SETTINGS;
            }
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), 'finish');
        }

        this.loggerInstance?.flush();
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
            System.debug('++++ChatIndexBatch: Initiating multipart upload');
            AWSChatServiceRequest request = new AWSChatServiceRequest(UserInfo.getOrganizationId(), partsCount);
            Map<String, String> headers = GitHubUtils.authHeaders();
            headers.putAll(HttpUtils.getHeadersContentTypeJSON());
            String response = HttpUtils.post(INDEX_MANAGER_LOGS_ENDPOINT, JSON.serialize(request), headers, 200);
            
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response);
            this.uploadId = (String) responseBody.get('upload_id');
            this.objectKey = (String) responseBody.get('object_key');
            this.presignedUrls = (List<String>) responseBody.get('parts');
            System.debug('++++ChatIndexBatch: Multipart upload initiated - UploadId: ' + this.uploadId + ', ObjectKey: ' + this.objectKey + ', Parts: ' + this.presignedUrls.size());
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), 'initiateMultipartUpload');
            throw e;
        }
    }
    
    private void uploadBatchAsPart(List<Map<String, Object>> batchLogs) {
        try {
            System.debug('++++ChatIndexBatch: Uploading batch as part');
            Integer partIndex = uploadedParts.size();
            String presignedUrl = this.presignedUrls[partIndex];
            String partJSON = createArrayPart(batchLogs, partIndex);
            
            HttpUtils.put(presignedUrl, partJSON, HttpUtils.getHeadersContentTypeJSON(), 200);
            String etag = HttpUtils.responseHeaders.get('ETag');
            
            Map<String, Object> partInfo = new Map<String, Object>{
                'ETag' => etag,
                'PartNumber' => partIndex + 1
            };
            uploadedParts.add(partInfo);
            
            System.debug('++++ChatIndexBatch: Part ' + partIndex + ' uploaded successfully');
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), 'uploadBatchAsPart');
            throw e;
        }
    }
    
    private String createArrayPart(List<Map<String, Object>> batchLogs, Integer partIndex) {
        String arrayJSON = JSON.serialize(batchLogs);
        if (this.presignedUrls.size() == 1) {
            return arrayJSON;
        }
        
        // Remove outer brackets from the JSON array
        String objectsJSON = arrayJSON.substring(1, arrayJSON.length() - 1);
        if (partIndex == 0) {
            return '[' + objectsJSON;
        } else if (partIndex == this.presignedUrls.size() - 1) {
            return objectsJSON + ']';
        } else {
            return ',' + objectsJSON;
        }
    }
    
    
    private void completeMultipartUpload() {
        try {
            System.debug('++++ChatIndexBatch: Completing multipart upload with ' + uploadedParts.size() + ' parts');
            AWSChatServiceRequest request = new AWSChatServiceRequest(this.objectKey, this.uploadId, this.uploadedParts);
            Map<String, String> headers = GitHubUtils.authHeaders();
            headers.putAll(HttpUtils.getHeadersContentTypeJSON());
            HttpUtils.post(INDEX_MANAGER_LOGS_ENDPOINT, JSON.serialize(request), headers, 200);
            System.debug('++++ChatIndexBatch: Multipart upload completed successfully');
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), 'completeMultipartUpload');
            throw e;
        }
    }

    public class AWSChatServiceRequest {
        public String oid;
        public Integer parts_count;
        public String object_key;
        public String upload_id;
        public List<Map<String, Object>> parts;

        public AWSChatServiceRequest(String oid, Integer partsCount) {
            this.oid = oid;
            this.parts_count = partsCount;
        }

        public AWSChatServiceRequest(String objectKey, String uploadId, List<Map<String, Object>> parts) {
            this.object_key = objectKey;
            this.upload_id = uploadId;
            this.parts = parts;
        }
    }
}