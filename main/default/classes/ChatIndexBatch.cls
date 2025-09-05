public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final Integer MAX_LOGS_PER_BATCH = 200;
    
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
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            Integer newLogsCount = getIterationsCount();
            List<Log_Index__c> newLogIndexes = [
                SELECT Hash__c
                FROM Log_Index__c
                ORDER BY Id DESC
                LIMIT :newLogsCount
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
        
        try {
            List<Map<String, Object>> transformedLogs = getTransformedLogs(scope);
            String logsJSON = JSON.serialize(transformedLogs);
            startAwsChatService(logsJSON);
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('++++ChatIndexBatch: finish, settings = ' + SETTINGS);
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            SETTINGS.ProcessedLogHashes__c = [SELECT COUNT() FROM Log_Index__c];
            System.debug('++++ChatIndexBatch: SETTINGS.ProcessedLogHashes__c = ' + SETTINGS.ProcessedLogHashes__c);
            update SETTINGS;
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

    public void startAwsChatService(String logsJSON) {
        try {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            AWSChatServiceRequest request = new AWSChatServiceRequest(corg, logsJSON);
            Map<String, String> headers = GitHubUtils.authHeaders();
            headers.putAll(HttpUtils.getHeadersContentTypeJSON());

            //TODO: Uncomment this
            // HttpUtils.post(
            //     INDEX_MANAGER_LOGS_ENDPOINT,
            //     JSON.serialize(request),
            //     headers,
            //     200
            // );
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