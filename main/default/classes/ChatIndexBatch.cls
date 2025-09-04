public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final Integer MAX_LOGS_PER_BATCH = 200;
    
    private static ChatIndexBatch instance = null;

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
        Integer hashCounts = [SELECT COUNT() FROM Log_Index__c WHERE Hash__c != NULL];
        return Math.max(1, Math.ceil(hashCounts / MAX_LOGS_PER_BATCH).intValue());
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MetadataChatEnabled;
    }

    public Iterable<SObject> start(Database.BatchableContext batchableContext) {
        // Get ids of unique logs using aggregate query
        List<AggregateResult> uniqueIds = [
            SELECT MIN(Id)
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
            transformedLog.put('details', log.Details__c);
            transformedLogs.add(transformedLog);
        }
        return transformedLogs;
    }

    public void startAwsChatService(Connected_Org__c corg, String logsJSON) {
        try {
            AWSChatServiceRequest request = new AWSChatServiceRequest(corg, logsJSON);
            Map<String, String> headers = GitHubUtils.authHeaders();
            headers.putAll(HttpUtils.getHeadersContentTypeJSON());

            HttpUtils.post(
                INDEX_MANAGER_LOGS_ENDPOINT,
                JSON.serialize(request),
                headers,
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