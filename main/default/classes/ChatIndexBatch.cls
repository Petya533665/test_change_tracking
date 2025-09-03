public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final Integer MAX_AWS_REQUEST_SIZE = 10*1024*1024; //10MB
    private static final Integer ESTIMATED_MAX_LOG_SIZE = 5*1024; //5KB
    private static final Integer MAX_LOGS_PER_BATCH = MAX_AWS_REQUEST_SIZE / ESTIMATED_MAX_LOG_SIZE;
    private static final Integer MAX_DETAILS_LENGTH = 4096;
    
    private static ChatIndexBatch instance = null;
    public DateTime startDate = DateTime.now().addHours(-1);

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
        return Math.ceil(totalUniqueHashes / MAX_LOGS_PER_BATCH).intValue();
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        // Get ids of unique logs
        QBuilder uniqueIdsQb = new QBuilder(Log__c.SObjectType)
        .selectFields(new Set<String>{'MIN(Id)'})
        .add(QBuilder.condition('Hash_1__c').isNotNull())
        .add(QBuilder.condition('CreatedDate').isGreaterOrEquals(startDate));
        String uniqueIdsQuery = uniqueIdsQb.build() + ' GROUP BY Hash_1__c ORDER BY MIN(Id) DESC';
        return Database.getQueryLocator(uniqueIdsQuery);
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        if (scope == null || scope.isEmpty() || !PermissionsUtil.MetadataChatEnabled) {
            return;
        }
        
        try {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            
            List<Map<String, Object>> transformedLogs = getLogsForAWS(scope);
            String logsJSON = JSON.serialize(transformedLogs);
            startAwsChatService(corg, logsJSON);
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        this.loggerInstance?.flush();
    }

    private List<Map<String, Object>> getLogsForAWS(List<SObject> scope) {
        Set<Id> logIds = new Set<Id>();
        for (SObject record : scope) {
            logIds.add(record.Id);
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
            
            // Truncate details if over MAX_DETAILS_LENGTH
            String details = log.Details__c;
            if (details != null && details.length() > MAX_DETAILS_LENGTH) {
                details = details.substring(0, MAX_DETAILS_LENGTH) + ' ...';
            }
            transformedLog.put('details', details);
            
            transformedLogs.add(transformedLog);
        }
        return transformedLogs;
    }

    public void startAwsChatService(Connected_Org__c corg, String logsJSON) {
        try {
            AWSChatServiceRequest request = new AWSChatServiceRequest(corg, logsJSON);

            HttpUtils.post(
                INDEX_MANAGER_LOGS_ENDPOINT,
                JSON.serialize(request),
                GitHubUtils.authHeaders(),
                200
            );
        }
        catch(Exception e) {
            this.loggerInstance?.add(loggerInstance.getInternalError(e, null, ChatIndexBatch.class.getName(), 'startAwsChatService'));
        }
    }

    public class AWSChatServiceRequest {
        public String oid;
        public String logs;

        public AWSChatServiceRequest(Connected_Org__c corg, String logs) {
            this.oid = UserInfo.getOrganizationId();
            this.logs = logs;
        }
    }
}