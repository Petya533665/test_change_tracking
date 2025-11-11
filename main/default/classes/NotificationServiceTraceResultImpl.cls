public class NotificationServiceTraceResultImpl extends NotificationServiceBase {

    public override NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType() {
        return NotificationService.NOTIFICATION_SERVICE_TYPE.TRACE_RESULT;
    }

    public override Schema.SObjectType getRecordSobjectType() {
        return Trace_Result__c.SObjectType;
    }

    public override Boolean isPermissionEnabled() {
        return PermissionsUtil.DebugLogServiceEnabled;
    }

    public override Object notificationBatchInstance() {
        return TraceResultNotificationBatch.getInstance();
    }

    public override void startNotificationBatch() {
        TraceResultNotificationBatch.getInstance().startBatch();
    }

    public override Integer getSObjectRecordsCount() {
        Integer count = getSobjectRecordsCountFromContext();
        if(count != null) return count;

        QBuilder qb = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
            .selectFields(new Set<String>{'COUNT()'})
            .add(String.isNotBlank(getNotificationStatusFieldName()) ? QBuilder.condition(getNotificationStatusFieldName()).equalsTo(Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) : null)
            .addLimit(QUERY_LIMIT);
        return Database.countQuery(qb.build());
    }

    public override Database.QueryLocator getQueryLocator() {
        Database.QueryLocator queryLocator = Database.getQueryLocator([
            SELECT Id, Notification_Integration_Status__c, Executable_Rules__c
            FROM Trace_Result__c
            WHERE Notification_Integration_Status__c = :Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING
            ORDER BY CreatedDate
            LIMIT :QUERY_LIMIT
        ]);
        return queryLocator;
    }

    public override String getOrganizationIdFromSObjectRecord() {
        return UserInfo.getOrganizationId();
    }

    public override String getTicketingStatusFieldName() {
        return null;
    }

    public override void setIterationRecordFailedStatus() {
        Trace_Result__c traceResult = (Trace_Result__c)this.record;
        if(traceResult.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            PermissionsUtil.putSObjectField(traceResult, Schema.SObjectType.Trace_Result__c.fields.Notification_Integration_Status__c, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED);
        }

        // clear running ids in config
        NotificationService.ExecutableRulesConfig config = clearRunningIdsInConfig(traceResult.Id, traceResult);
        PermissionsUtil.putSObjectField(traceResult, Schema.SObjectType.Trace_Result__c.fields.Executable_Rules__c, config.toJSON());

        DatabaseUtils.getInstance().performUpdateDML(new List<Trace_Result__c>{traceResult}, Schema.SObjectType.Trace_Result__c)
                .handleError(NotificationServiceTraceResultImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
    }

    // disabled ticketing
    public override void setRecordFailedStatusThrowBySendErrors() {}
    public override void sendTicketing() {}

    public override Schema.SObjectField getRuleSubTypeSObjectField(RuleUtil.Rule rule) {
        if(rule.subType == Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME) {
            return Trace_Result__c.Issue__c.getDescribe().getSObjectField();
        }
        return null;
    }
}