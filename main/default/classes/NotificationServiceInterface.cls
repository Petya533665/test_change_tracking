public interface NotificationServiceInterface {

    String getNotificationStatusFieldName();
    String getTicketingStatusFieldName();
    Boolean isPermissionEnabled();

    void startNotificationBatch();
    void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, NotificationService.BatchContextManager batchContextManager);
    void finish(Database.BatchableContext info);
    void finish(Database.BatchableContext info, NotificationService.BatchContextManager batchContextManager);
    Object notificationBatchInstance();
    void executeIteration();
    void executeIteration(NotificationService.ActionIteration targetIteration);
    void executeIteration(NotificationService.ActionIteration targetIteration, NotificationService.BatchContextManager batchContextManager);
    void setIterationRecordFailedStatus();
    NotificationService.ExecutableRulesConfig clearRunningIdsInConfig(String recordId, SObject record);
    void setRecordFailedStatusThrowBySendErrors();
    void sendTicketing();
    Integer getSObjectRecordsCount();
    Integer getSobjectRecordsCountFromContext();
    String getRuleSobjectType(SObject scopeRecord);
    List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType);
    Database.QueryLocator getQueryLocator();
    NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType();

    List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap);
    List<SObject> filterRecordsForExecuteNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap);
    List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap);
    List<SObject> filterRecordsForExecuteTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap);
    void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap);
    void executeNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap);
    void assignNotificationRules(List<RuleUtil.Rule> rules, List<SObject> records);

    void applyNotificationRules(List<SObject> toNotifications, Map<Id, SObject> oldMap);
    void applyJiraRules(List<SObject> toTicketing, Map<Id, SObject> oldMap);
    void applyAzureDevOpsRules(List<SObject> toTicketing, Map<Id, SObject> oldMap);
    void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config);
    Schema.SObjectField getRuleSubTypeSObjectField(RuleUtil.Rule rule);
    Schema.SObjectType getRecordSobjectType();

    List<NotificationService.ActionIteration> getActionIterations(SObject record);
    void executeActionIteration(NotificationService.ActionIteration iteration);
    void executeActionIteration(NotificationService.ActionIteration iteration, NotificationService.BatchContextManager batchContextManager);

    List<RuleUtil.Rule> getTicketingRules(List<String> executableRulesIds, String ruleSobjectType);
}