public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String S3_BUCKET_NAME = 'ai-pharos-index'; // TODO: Replace with your actual S3 bucket name
    private static final String S3_REGION = 'us-west-1'; // TODO: Replace with your S3 region
    
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
        System.debug('++++ChatIndexBatch: startBatch() called');
        DatabaseUtils.executeBatchWithLimitCheck('ChatIndexBatch', this);
    }

    public override Integer getIterationsCount() {
        System.debug('++++ChatIndexBatch: getIterationsCount() called');
        // Calculate total iterations based on unique hashes and batch size
        List<AggregateResult> hashCounts = [
            SELECT COUNT_DISTINCT(Hash_1__c) uniqueCount
            FROM Log__c 
            WHERE Hash_1__c != NULL 
            AND CreatedDate >= :startDate
        ];
        Integer totalUniqueHashes = hashCounts.isEmpty() ? 0 : (Integer)hashCounts[0].get('uniqueCount');
        System.debug('++++ChatIndexBatch: totalUniqueHashes = ' + totalUniqueHashes + ', MAX_LOGS_PER_BATCH = ' + MAX_LOGS_PER_BATCH);
        Integer iterations = Math.max(1, Math.ceil(totalUniqueHashes / MAX_LOGS_PER_BATCH).intValue());
        System.debug('++++ChatIndexBatch: iterations = ' + iterations);
        return iterations;
    }

    public override Boolean initialValidation() {
        System.debug('++++ChatIndexBatch: initialValidation() called');
        Boolean isValid = PermissionsUtil.MetadataChatEnabled;
        System.debug('++++ChatIndexBatch: initialValidation result = ' + isValid);
        return isValid;
    }

    public Iterable<SObject> start(Database.BatchableContext batchableContext) {
        System.debug('++++ChatIndexBatch: start() called');
        System.debug('++++ChatIndexBatch: startDate = ' + startDate);
        // Get ids of unique logs using aggregate query
        List<AggregateResult> uniqueIds = [
            SELECT MIN(Id) minId
            FROM Log__c 
            WHERE Hash_1__c != NULL 
            AND CreatedDate >= :startDate 
            GROUP BY Hash_1__c 
            ORDER BY MIN(Id) DESC
        ];
        System.debug('++++ChatIndexBatch: uniqueIds size = ' + uniqueIds.size());
        // Return the list directly - batch framework will chunk it based on BATCH_SCOPE
        return uniqueIds;
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        System.debug('++++ChatIndexBatch: execute() called');
        System.debug('++++ChatIndexBatch: scope size = ' + (scope != null ? String.valueOf(scope.size()) : 'null'));
        System.debug('++++ChatIndexBatch: partNumber = ' + partNumber);
        
        if (scope == null || scope.isEmpty()) {
            System.debug('++++ChatIndexBatch: scope is null or empty, returning');
            return;
        }
        
        try {
            System.debug('++++ChatIndexBatch: getting Connected_Org__c');
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            System.debug('++++ChatIndexBatch: Connected_Org__c = ' + corg);
            
            System.debug('++++ChatIndexBatch: calling getLogsForAWS');
            List<Map<String, Object>> transformedLogs = getLogsForAWS(scope);
            System.debug('++++ChatIndexBatch: transformedLogs size = ' + transformedLogs.size());
            
            System.debug('++++ChatIndexBatch: serializing logs');
            String logsJSON = JSON.serialize(transformedLogs);
            System.debug('++++ChatIndexBatch: logsJSON length = ' + logsJSON.length());
            
            System.debug('++++ChatIndexBatch: calling uploadChunkToS3');
            uploadChunkToS3(corg, logsJSON, partNumber);
            System.debug('++++ChatIndexBatch: uploadChunkToS3 completed');
            partNumber++;
        }
        catch (Exception e) {
            System.debug('++++ChatIndexBatch: Exception in execute: ' + e.getMessage());
            System.debug('++++ChatIndexBatch: Exception stack trace: ' + e.getStackTraceString());
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('++++ChatIndexBatch: finish() called');
        System.debug('++++ChatIndexBatch: uploadId = ' + uploadId);
        System.debug('++++ChatIndexBatch: etags size = ' + etags.size());
        try {
            // Complete the multipart upload
            if (uploadId != null && !etags.isEmpty()) {
                System.debug('++++ChatIndexBatch: completing S3 upload');
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
                completeS3Upload(corg);
                System.debug('++++ChatIndexBatch: S3 upload completed successfully');
            } else {
                System.debug('++++ChatIndexBatch: no upload to complete - uploadId=' + uploadId + ', etags size=' + etags.size());
            }
        } catch (Exception e) {
            System.debug('++++ChatIndexBatch: Exception in finish: ' + e.getMessage());
            System.debug('++++ChatIndexBatch: Exception stack trace: ' + e.getStackTraceString());
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':finish');
        }
        this.loggerInstance?.flush();
    }

    private void uploadChunkToS3(Connected_Org__c corg, String logsJSON, Integer partNum) {
        System.debug('++++ChatIndexBatch: uploadChunkToS3() called with partNum = ' + partNum);
        try {
            if (uploadId == null) {
                System.debug('++++ChatIndexBatch: initiating S3 upload');
                // Initialize multipart upload
                uploadId = initiateS3Upload(corg);
                System.debug('++++ChatIndexBatch: uploadId = ' + uploadId);
            }
            
            System.debug('++++ChatIndexBatch: uploading S3 part ' + partNum);
            // Upload part
            String etag = uploadS3Part(corg, logsJSON, partNum);
            System.debug('++++ChatIndexBatch: received etag = ' + etag);
            etags.add(etag);
            System.debug('++++ChatIndexBatch: etags size now = ' + etags.size());
            
        } catch(Exception e) {
            System.debug('++++ChatIndexBatch: Exception in uploadChunkToS3: ' + e.getMessage());
            System.debug('++++ChatIndexBatch: Exception stack trace: ' + e.getStackTraceString());
            this.loggerInstance?.add(loggerInstance.getInternalError(e, null, ChatIndexBatch.class.getName(), 'uploadChunkToS3'));
        }
    }

    private String initiateS3Upload(Connected_Org__c corg) {
        System.debug('++++ChatIndexBatch: initiateS3Upload() called');
        String s3Endpoint = 'https://' + S3_BUCKET_NAME + '.s3.' + S3_REGION + '.amazonaws.com';
        System.debug('++++ChatIndexBatch: S3 endpoint = ' + s3Endpoint);
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        String responseBody = HttpUtils.post(
            s3Endpoint + '/logs.json?uploads',
            '', // Empty body for multipart upload initiation
            headers,
            200
        );
        System.debug('++++ChatIndexBatch: initiateS3Upload response = ' + responseBody);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        String uploadId = (String)responseMap.get('uploadId');
        System.debug('++++ChatIndexBatch: extracted uploadId = ' + uploadId);
        return uploadId;
    }

    private String uploadS3Part(Connected_Org__c corg, String logsJSON, Integer partNum) {
        System.debug('++++ChatIndexBatch: uploadS3Part() called with partNum = ' + partNum);
        String s3Endpoint = 'https://' + S3_BUCKET_NAME + '.s3.' + S3_REGION + '.amazonaws.com';
        System.debug('++++ChatIndexBatch: uploadS3Part endpoint = ' + s3Endpoint + '/logs.json?partNumber=' + partNum + '&uploadId=' + uploadId);
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        // Use PUT for uploading parts and send the actual log data
        String responseBody = HttpUtils.put(
            s3Endpoint + '/logs.json?partNumber=' + partNum + '&uploadId=' + uploadId,
            logsJSON, // Send the actual log data
            headers,
            200
        );
        System.debug('++++ChatIndexBatch: uploadS3Part response = ' + responseBody);
        
        // For S3 PUT requests, the ETag is in the response headers, not body
        // We'll need to extract it from headers or use a different approach
        return 'etag-' + partNum; // Placeholder for now
    }

    private void completeS3Upload(Connected_Org__c corg) {
        System.debug('++++ChatIndexBatch: completeS3Upload() called');
        String s3Endpoint = 'https://' + S3_BUCKET_NAME + '.s3.' + S3_REGION + '.amazonaws.com';
        System.debug('++++ChatIndexBatch: completeS3Upload endpoint = ' + s3Endpoint + '/logs.json?uploadId=' + uploadId);
        Map<String, String> headers = GitHubUtils.authHeaders();
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());

        // Build XML body for completing multipart upload
        String xmlBody = '<CompleteMultipartUpload>';
        for (Integer i = 0; i < etags.size(); i++) {
            xmlBody += '<Part><PartNumber>' + (i + 1) + '</PartNumber><ETag>' + etags[i] + '</ETag></Part>';
        }
        xmlBody += '</CompleteMultipartUpload>';

        String responseBody = HttpUtils.post(
            s3Endpoint + '/logs.json?uploadId=' + uploadId,
            xmlBody,
            headers,
            200
        );
        System.debug('++++ChatIndexBatch: completeS3Upload response = ' + responseBody);
    }

    private List<Map<String, Object>> getLogsForAWS(List<SObject> scope) {
        System.debug('++++ChatIndexBatch: getLogsForAWS() called');
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
        System.debug('++++ChatIndexBatch: logIds size = ' + logIds.size());
        
        Set<String> fields = new Set<String>{
            'Id', 'Name', 'Hash_1__c', 'Summary__c', 'Details__c', 'Type__c', 'Category__c', 'Area__c', 'Created_At__c'
        };
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(fields)
            .add(QBuilder.condition('Id').isIn(new List<Id>(logIds)))
            .add(QBuilder.orderBy('Id').ascending());
        String query = qb.build();
        System.debug('++++ChatIndexBatch: getLogsForAWS query = ' + query);
        
        List<Log__c> logs = Database.query(query);
        System.debug('++++ChatIndexBatch: logs size = ' + logs.size());

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
        System.debug('++++ChatIndexBatch: transformedLogs size = ' + transformedLogs.size());
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