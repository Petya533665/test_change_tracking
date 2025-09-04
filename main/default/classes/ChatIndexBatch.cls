public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String S3_UPLOAD_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/s3/upload';
    
    private static final Integer MAX_AWS_REQUEST_SIZE = 10*1024*1024; //10MB
    private static final Integer ESTIMATED_MAX_LOG_SIZE = 50*1024; //50KB
    private static final Integer MAX_LOGS_PER_BATCH = MAX_AWS_REQUEST_SIZE / ESTIMATED_MAX_LOG_SIZE;
    
    private static ChatIndexBatch instance = null;
    public DateTime startDate = DateTime.now().addMonths(-1); //TODO: Change to addHours(-1)
    
    // S3 Upload state
    private String uploadId = null;
    private Integer partNumber = 1;
    private List<String> etags = new List<String>();

    public static ChatIndexBatch getInstance() {
        if (instance == null) {
            instance = new ChatIndexBatch(Logger.getInstance());
        }
        return instance;
    }

    private ChatIndexBatch(Logger logger) {
        super(logger);
        BATCH_SCOPE = MAX_LOGS_PER_BATCH;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('ChatIndexBatch', this);
    }

    public override Integer getIterationsCount() {
        // Calculate total iterations based on unique hashes and batch size
        List<AggregateResult> hashCounts = [
            SELECT COUNT_DISTINCT(Hash_1__c) uniqueCount
            FROM Log__c 
            WHERE Hash_1__c != NULL 
            AND CreatedDate >= :startDate
        ];
        Integer totalUniqueHashes = hashCounts.isEmpty() ? 0 : (Integer)hashCounts[0].get('uniqueCount');
        return Math.max(1, Math.ceil(totalUniqueHashes / MAX_LOGS_PER_BATCH).intValue());
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MetadataChatEnabled;
    }

    public Iterable<SObject> start(Database.BatchableContext batchableContext) {
        // Get ids of unique logs using aggregate query
        List<AggregateResult> uniqueIds = [
            SELECT MIN(Id) minId
            FROM Log__c 
            WHERE Hash_1__c != NULL 
            AND CreatedDate >= :startDate 
            GROUP BY Hash_1__c 
            ORDER BY MIN(Id) DESC
        ];
        
        // Return the list directly - batch framework will chunk it based on BATCH_SCOPE
        return uniqueIds;
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }
        
        try {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            
            List<Map<String, Object>> transformedLogs = getLogsForAWS(scope);
            String logsJSON = JSON.serialize(transformedLogs);
            
            // Upload chunk to S3
            uploadChunkToS3(corg, logsJSON, partNumber);
            partNumber++;
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        try {
            // Complete the multipart upload
            if (uploadId != null && !etags.isEmpty()) {
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
                completeS3Upload(corg);
            }
        } catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':finish');
        }
        this.loggerInstance?.flush();
    }

    private void uploadChunkToS3(Connected_Org__c corg, String logsJSON, Integer partNum) {
        try {
            if (uploadId == null) {
                // Initialize multipart upload
                uploadId = initiateS3Upload(corg);
            }
            
            // Upload part
            String etag = uploadS3Part(corg, logsJSON, partNum);
            etags.add(etag);
            
        } catch(Exception e) {
            this.loggerInstance?.add(loggerInstance.getInternalError(e, null, ChatIndexBatch.class.getName(), 'uploadChunkToS3'));
        }
    }

    private String initiateS3Upload(Connected_Org__c corg) {
        S3UploadRequest request = new S3UploadRequest(corg, 'initiate');
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        String responseBody = HttpUtils.post(
            S3_UPLOAD_ENDPOINT,
            JSON.serialize(request),
            headers,
            200
        );
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        return (String)responseMap.get('uploadId');
    }

    private String uploadS3Part(Connected_Org__c corg, String logsJSON, Integer partNum) {
        S3PartUploadRequest request = new S3PartUploadRequest(corg, uploadId, partNum, logsJSON);
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        String responseBody = HttpUtils.post(
            S3_UPLOAD_ENDPOINT + '/part',
            JSON.serialize(request),
            headers,
            200
        );
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        return (String)responseMap.get('etag');
    }

    private void completeS3Upload(Connected_Org__c corg) {
        S3CompleteUploadRequest request = new S3CompleteUploadRequest(corg, uploadId, etags);
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        HttpUtils.post(
            S3_UPLOAD_ENDPOINT + '/complete',
            JSON.serialize(request),
            headers,
            200
        );
    }

    private List<Map<String, Object>> getLogsForAWS(List<SObject> scope) {
        Set<Id> logIds = new Set<Id>();
        for (SObject record : scope) {
            // Handle AggregateResult from GROUP BY query
            if (record instanceof AggregateResult) {
                AggregateResult ar = (AggregateResult)record;
                logIds.add((Id)ar.get('minId'));
            } else {
                logIds.add(record.Id);
            }
        }
        
        Set<String> fields = new Set<String>{
            'Id', 'Name', 'Hash_1__c', 'Summary__c', 'Details__c', 'Type__c', 'Category__c', 'Area__c', 'Created_At__c'
        };
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(fields)
            .add(QBuilder.condition('Id').isIn(new List<Id>(logIds)))
            .add(QBuilder.orderBy('Id').ascending());
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

    // Request classes for S3 upload
    public class S3UploadRequest {
        public String oid;
        public String action;

        public S3UploadRequest(Connected_Org__c corg, String action) {
            this.oid = UserInfo.getOrganizationId();
            this.action = action;
        }
    }

    public class S3PartUploadRequest {
        public String oid;
        public String uploadId;
        public Integer partNumber;
        public String data;

        public S3PartUploadRequest(Connected_Org__c corg, String uploadId, Integer partNumber, String data) {
            this.oid = UserInfo.getOrganizationId();
            this.uploadId = uploadId;
            this.partNumber = partNumber;
            this.data = data;
        }
    }

    public class S3CompleteUploadRequest {
        public String oid;
        public String uploadId;
        public List<String> etags;

        public S3CompleteUploadRequest(Connected_Org__c corg, String uploadId, List<String> etags) {
            this.oid = UserInfo.getOrganizationId();
            this.uploadId = uploadId;
            this.etags = etags;
        }
    }
}