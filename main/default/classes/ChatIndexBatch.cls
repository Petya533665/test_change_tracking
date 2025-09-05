public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static final Integer MAX_LOGS_PER_BATCH = 200;
    private static Chat_Index_Settings__c settingsInstance = null;
    private static Chat_Index_Settings__c SETTINGS {
        get {
            if (settingsInstance == null) {
                settingsInstance = getOrCreateSettings();
            }
            return settingsInstance;
        }
        set {
            settingsInstance = value;
        }
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

    private static Chat_Index_Settings__c getOrCreateSettings() {
        try {
            Chat_Index_Settings__c settings = Chat_Index_Settings__c.getOrgDefaults();
            System.debug('++++ChatIndexBatch: getOrCreateSettings - getOrgDefaults returned: ' + settings);
            if (settings == null) {
                System.debug('++++ChatIndexBatch: Creating new Chat_Index_Settings__c record');
                settings = new Chat_Index_Settings__c();
                settings.ProcessedLogHashes__c = 0;
                insert settings;
                System.debug('++++ChatIndexBatch: Created settings with ProcessedLogHashes__c = ' + settings.ProcessedLogHashes__c);
            } else {
                System.debug('++++ChatIndexBatch: Found existing settings with ProcessedLogHashes__c = ' + settings.ProcessedLogHashes__c);
                // Ensure the field is not null
                if (settings.ProcessedLogHashes__c == null) {
                    System.debug('++++ChatIndexBatch: ProcessedLogHashes__c is null, setting to 0');
                    settings.ProcessedLogHashes__c = 0;
                    update settings;
                }
            }
            return settings;
        } catch (Exception e) {
            System.debug('++++ChatIndexBatch: Error in getOrCreateSettings: ' + e.getMessage());
            // Return a default settings object if everything fails
            Chat_Index_Settings__c defaultSettings = new Chat_Index_Settings__c();
            defaultSettings.ProcessedLogHashes__c = 0;
            return defaultSettings;
        }
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
        System.debug('++++ChatIndexBatch: getIterationsCount - total Log_Index__c count: ' + count);
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            System.debug('++++ChatIndexBatch: SETTINGS = ' + SETTINGS);
            System.debug('++++ChatIndexBatch: SETTINGS.ProcessedLogHashes__c = ' + SETTINGS.ProcessedLogHashes__c);
            Integer processedCount = (SETTINGS.ProcessedLogHashes__c != null) ? (Integer)SETTINGS.ProcessedLogHashes__c : 0;
            count = count - processedCount;
            System.debug('++++ChatIndexBatch: calculated count after subtracting processed: ' + count);
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

            if (runJobType == JobType.LOG_INDEX_UPDATE) {
                System.debug('++++ChatIndexBatch: Updating ProcessedLogHashes__c, current value: ' + SETTINGS.ProcessedLogHashes__c);
                SETTINGS.ProcessedLogHashes__c = (SETTINGS.ProcessedLogHashes__c != null ? SETTINGS.ProcessedLogHashes__c : 0) + scope.size();
                System.debug('++++ChatIndexBatch: New ProcessedLogHashes__c value: ' + SETTINGS.ProcessedLogHashes__c);
            }
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (runJobType == JobType.LOG_INDEX_UPDATE) {
            DatabaseUtils.getInstance().performUpdateDML(new List<Chat_Index_Settings__c>{SETTINGS}, Schema.SObjectType.Chat_Index_Settings__c);
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