public without sharing class ChatIndexBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    private static final String INDEX_MANAGER_ENDPOINT = Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index';
    private static final String INDEX_MANAGER_LOGS_ENDPOINT = INDEX_MANAGER_ENDPOINT + '/logs';
    
    private static ChatIndexBatch instance = null;
    private String lastProcessedId = null;
    private List<Log__c> allUniqueLogs = null;

    public static ChatIndexBatch getInstance() {
        if (instance == null) {
            instance = new ChatIndexBatch(Logger.getInstance());
        }
        return instance;
    }

    private ChatIndexBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('ChatIndexBatch', this);
    }

    public override Integer getIterationsCount() {
        return 1;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        // Get all unique logs at once and store them for execute method
        List<Log__c> allUniqueLogs = getUniqueLogs(lastProcessedId); 
        this.allUniqueLogs = allUniqueLogs;
        
        // Return a simple query that will be processed in chunks
        if (allUniqueLogs == null || allUniqueLogs.isEmpty()) {
            return Database.getQueryLocator('SELECT Id FROM Log__c WHERE Id = null LIMIT 0');
        }
        
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>{'Id'})
            .add(QBuilder.condition('Id').isIn(new List<Id>(new Map<Id, Log__c>(allUniqueLogs).keySet())))
            .addLimit(1); // Only need one record to trigger execute
        
        return Database.getQueryLocator(qb.build());
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        if (scope == null || scope.isEmpty() || allUniqueLogs == null || allUniqueLogs.isEmpty()) {
            return;
        }
        
        try {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            
            List<Map<String, Object>> cleanedLogs = transformLogsForAWS(allUniqueLogs);
            String logsJSON = JSON.serialize(cleanedLogs);
            AWSChatServiceResponse response = startAwsChatService(corg, logsJSON);
            
            if (response != null && response.statusCode == 200) {
                setLastProcessedId(allUniqueLogs.get(allUniqueLogs.size() - 1).Id);
            }
            
            // Clear the logs to prevent multiple calls
            allUniqueLogs = null;
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, ChatIndexBatch.class.getName(), ':execute');
        }
    }

    public void finish(Database.BatchableContext BC) {
        this.loggerInstance?.flush();
    }

    private List<Log__c> getUniqueLogs(String lastProcessedId) {
        DateTime lastHour = DateTime.now().addYears(-3);
        QBuilder uniqueIdsQb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>{'MIN(Id) minId'})
            .add(QBuilder.condition('Hash_1__c').isNotNull())
            .add(QBuilder.condition('CreatedDate').isGreaterOrEquals(lastHour));     
            
        if (String.isNotBlank(lastProcessedId)) {
            uniqueIdsQb.add(QBuilder.condition('Id').isGreaterThan(lastProcessedId));
        }
        
        String uniqueIdsQuery = uniqueIdsQb.build() + ' GROUP BY Hash_1__c ORDER BY MIN(Id) ASC LIMIT 1000';
        
        // Execute the first query to get IDs of unique logs
        List<AggregateResult> uniqueIds = Database.query(uniqueIdsQuery);
        Set<Id> logIds = new Set<Id>();
        for (AggregateResult ar : uniqueIds) {
            logIds.add((Id)ar.get('minId'));
        }
        
        if (logIds.isEmpty()) {
            return new List<Log__c>();
        }
        
        // Second query to get the full records of unique logs
        Set<String> fields = new Set<String>{
            'Id', 'Name', 'Hash_1__c', 'Summary__c', 'Details__c', 'Type__c', 'Category__c', 'Area__c', 'Created_At__c'
        };
        
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(fields)
            .add(QBuilder.condition('Id').isIn(new List<Id>(logIds)))
            .add(QBuilder.orderBy('Id').ascending());
        
        List<Log__c> result = Database.query(qb.build());
        
        return result;
    }



    private void setLastProcessedId(String lastProcessedId) {
        if (String.isNotBlank(lastProcessedId)) {
            this.lastProcessedId = lastProcessedId;
        }
    }

    private List<Map<String, Object>> transformLogsForAWS(List<Log__c> logs) {
        List<Map<String, Object>> cleanedLogs = new List<Map<String, Object>>();
        for (Log__c log : logs) {
            Map<String, Object> cleanedLog = new Map<String, Object>();
            cleanedLog.put('id', log.Id);
            cleanedLog.put('name', log.Name);
            cleanedLog.put('hash1', log.Hash_1__c);
            cleanedLog.put('summary', log.Summary__c);
            cleanedLog.put('details', log.Details__c);
            cleanedLog.put('category', log.Category__c);
            cleanedLog.put('area', log.Area__c);
            cleanedLogs.add(cleanedLog);
        }
        return cleanedLogs;
    }

    public AWSChatServiceResponse startAwsChatService(Connected_Org__c corg, String logsJSON) {
        AWSChatServiceResponse result;
        try {
            if (PermissionsUtil.MetadataChatEnabled) {
                AWSChatServiceRequest request = new AWSChatServiceRequest(corg, logsJSON);
                Map<String, String> headers = GitHubUtils.authHeaders();
                headers.putAll(HttpUtils.getHeadersContentTypeJSON());

                System.debug('++++endpoint: ' + INDEX_MANAGER_LOGS_ENDPOINT);
                System.debug('++++request: ' + JSON.serialize(request));
                System.debug('++++headers: ' + headers);
                
                String response = HttpUtils.post(
                    INDEX_MANAGER_LOGS_ENDPOINT,
                    JSON.serialize(request),
                    headers,
                    201
                );
                
                System.debug('++++response: ' + response);
                if (String.isNotBlank(response)) {
                    result = (AWSChatServiceResponse)JSON.deserialize(response, AWSChatServiceResponse.class);
                } else {
                    result = new AWSChatServiceResponse();
                    result.statusCode = 500;
                    result.body = 'Empty response from Lambda service';
                }
            }
        }
        catch(Exception e) {
            this.loggerInstance?.add(loggerInstance.getInternalError(e, null, ChatIndexBatch.class.getName(), 'startAwsChatService'));
        }
        return result;
    }

    public class AWSChatServiceResponse {
        public Integer statusCode;
        public String body;
    
        public AWSChatServiceResponse(){}
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