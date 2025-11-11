public class NotificationServiceIssueImpl extends NotificationServiceBase {

    public override NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType() {
        return NotificationService.NOTIFICATION_SERVICE_TYPE.ISSUE;
    }

    public override Schema.SObjectType getRecordSobjectType() {
        return Issue__c.SObjectType;
    }

    public override Boolean isPermissionEnabled() {
        return PermissionsUtil.IssueNotificationsEnabled;
    }

    public override Object notificationBatchInstance() {
        return IssueNotificationBatch.getInstance();
    }

    public override void startNotificationBatch() {
        IssueNotificationBatch.getInstance().startBatch();
    }

    public override Database.QueryLocator getQueryLocator() {
        Database.QueryLocator queryLocator = Database.getQueryLocator([
            SELECT Id, Jira_Integration_Status__c, Notification_Integration_Status__c, Executable_Rules__c
            FROM Issue__c
            WHERE Jira_Integration_Status__c = :Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING
            OR Notification_Integration_Status__c = :Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING
            ORDER BY CreatedDate
            LIMIT :QUERY_LIMIT
        ]);
        return queryLocator;
    }
    
    public override String getOrganizationIdFromSObjectRecord() {
        return UserInfo.getOrganizationId();
    }

    public override void setIterationRecordFailedStatus() {
        Issue__c issue = (Issue__c)this.record;
        if(issue.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Jira_Integration_Status__c, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
        }
        if(issue.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Notification_Integration_Status__c, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED);
        }
        // clear running ids in config
        NotificationService.ExecutableRulesConfig config = clearRunningIdsInConfig(issue.Id, issue);
        PermissionsUtil.putSObjectField(issue, Schema.SObjectType.Issue__c.fields.Executable_Rules__c, config.toJSON());

        DatabaseUtils.getInstance().performUpdateDML(new List<Issue__c>{issue}, Schema.SObjectType.Issue__c)
            .handleError(NotificationServiceIssueImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
    }

    public override void setRecordFailedStatusThrowBySendErrors() {
        Issue__c issue = (Issue__c)this.record;
        if(issue.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            super.addFailedRecord();
        }
    }

    public override List<SObject> filterRecordsForRunNotificationRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();

        Set<String> updateRuleIds = new Set<String>();
        if(oldMap != null) {
            for(RuleUtil.Rule rule : this.notificationRules) {
                if(rule.isUpdateRule()) {
                    updateRuleIds.add(String.valueOf(rule.id));
                }
            }
        }
        
        for(Issue__c issue : (List<Issue__c>)newList) {
            Issue__c oldIssue = oldMap != null ? (Issue__c)oldMap.get(issue.Id) : null;

            // skip started notifications
            if(isRunningNotifications(issue, oldIssue)) continue;

            NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);

            if(oldMap != null) {
                if(String.isNotBlank(issue.Notification_Integration_Status__c)
                    && issue.Notification_Integration_Status__c != Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING
                    && String.isNotBlank(issue.Executable_Rules__c)) {

                    Set<String> existExecutedRules = new Set<String>(config.getAllExecutedRuleIds());
                    Set<String> updateRuleIdsIssue = new Set<String>(updateRuleIds);
                    updateRuleIdsIssue.removeAll(existExecutedRules);
                    if(!updateRuleIdsIssue.isEmpty()) {
                        result.add(issue);
                    }
                }
                else if(String.isBlank(issue.Notification_Integration_Status__c)
                    && String.isBlank(issue.Executable_Rules__c)) {
                    result.add(issue);
                } 
            }
            else {
                if(String.isBlank(issue.Notification_Integration_Status__c)
                    && (oldMap != null && String.isBlank(issue.Executable_Rules__c))) {
                    result.add(issue);
                }
            }
        }
        return result;
    }

    public override List<SObject> filterRecordsForRunTicketingRules(List<SObject> newList, Map<Id, SObject> oldMap) {
        List<SObject> result = new List<SObject>();

        for(Issue__c issue : (List<Issue__c>)newList) {
            Issue__c oldIssue = oldMap != null ? (Issue__c)oldMap.get(issue.Id) : null;

            // skip started notifications
            if(isRunningTicketing(issue, oldIssue)) continue;

            NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);

            if(!NotificationService.transactionIds.contains(issue.Id)
                && (String.isBlank(issue.Jira_Integration_Status__c)
                || (String.isNotBlank(issue.Jira_Integration_Status__c)
                && config.getRuleIdsToReRun().isEmpty() && config.getRuleIdsToRun().isEmpty()))) {

                result.add(issue);
            }
        }
        return result;
    }
}