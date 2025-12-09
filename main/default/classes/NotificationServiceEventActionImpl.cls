public with sharing class NotificationServiceEventActionImpl extends NotificationServiceBase {

    public override NotificationService.NOTIFICATION_SERVICE_TYPE getServiceType() {
        return NotificationService.NOTIFICATION_SERVICE_TYPE.EVENT_ACTION;
    }

    public override Schema.SObjectType getRecordSobjectType() {
        return EventAction__c.SObjectType;
    }

    public override Boolean isPermissionEnabled() {
        return true; // EventActions don't have specific permission checks
    }

    public override Object notificationBatchInstance() {
        return NotificationBatch.getInstance();
    }

    public override void startNotificationBatch() {
        NotificationBatch.getInstance().startBatch();
    }

    public override Integer getSObjectRecordsCount() {
        Integer count = getSobjectRecordsCountFromContext();
        if(count != null) return count;

        QBuilder qb = new QBuilder(SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE.get(getServiceType()))
            .selectFields(new Set<String>{'COUNT()'})
            .add(QBuilder.condition('Executed_On__c').equalsTo(null))
            .add(QBuilder.condition('Action__c').notEqualsTo(null))
            .addLimit(QUERY_LIMIT);
        return Database.countQuery(qb.build());
    }

    public override Database.QueryLocator getQueryLocator() {
        Database.QueryLocator queryLocator = Database.getQueryLocator([
            SELECT Id, Executed_On__c,  Type__c, Action_Type__c,
                Action__c, Event__c, Contents__c,
                Action__r.Body__c, Action__r.Description__c, Action__r.EmailBody__c,
                Action__r.EmailCC__c, Action__r.EmailTemplateId__c, Action__r.EmailTo__c,
                Action__r.JIRAAssignee__c,Action__r.JIRAAssignee_Id__c,  Action__r.JIRAComponents__c,  Action__r.JIRAEpic__c,
                Action__r.JIRAIssueType__c,  Action__r.JIRALabels__c,  Action__r.JIRAPriority__c,
                Action__r.JIRAProject__c,  Action__r.SlackChannels__c,  Action__r.Subject__c,
                Action__r.Team_Id__c,Action__r.Channel_Id__c, Action__r.Iteration__c,
                Event__r.RecordCount__c, Event__r.Criteria__c, Response__c,
                Event__r.Records__c, Event__r.Grouped_Field_Values__c,
                Event__r.Rule__r.EventTimeInterval__c, Event__r.CreatedDate,
                Action__r.PagerDuty_Type__c, Action__r.Contact__c, Action__r.Additional_Metadata__c,
                Action__r.Action_Type__c, Action__r.SobjectType__c, Action__r.Is_Update__c,
                Action__r.Webhook_URL__c, Action__r.Webhook_Method__c, Action__r.Webhook_Headers__c,
                Action__r.Webhook_Body_Template__c, Action__r.Webhook_Auth_Type__c
            FROM EventAction__c
            WHERE Executed_On__c = NULL AND Action__c != NULL
        ]);
        return queryLocator;
    }

    public override void executeIteration() {
        executeIteration(null);
    }
    
    public override void executeIteration(NotificationService.ActionIteration targetIteration) {
        executeIteration(targetIteration, null);
    }

    public override void executeIteration(NotificationService.ActionIteration targetIteration, NotificationService.BatchContextManager batchContextManager) {
        EventAction__c eventAction = (EventAction__c)this.record;
        String actionType = eventAction.Action_Type__c != null ? eventAction.Action_Type__c : eventAction.Type__c;

        List<AsyncApexJob> manageTokensJob = DatabaseUtils.getCurrentJobs(new List<String>{'ManageTokensBatch'});
        if((RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionType) == RuleUtil.ActionType.TEAMS
            || RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionType) == RuleUtil.ActionType.JIRA)
            && !manageTokensJob.isEmpty()) {
            return;
        }

        Boolean notificationSuccessful = true;
        try {
            sendNotification(actionType, eventAction);
        }
        catch(Exception e) {
            notificationSuccessful = false;
            logger?.addInternalError(e, NotificationService.class.getName(), 'sendNotification');

            // Set Response__c for exceptions - ticketing services need to handle their own success cases
            PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, e.getMessage());
        }
        
        // Always set the execution timestamp
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Executed_On__c, Datetime.now());
        
        // For successful executions, only update the timestamp (ticketing actions already updated their own fields)
        if (notificationSuccessful) {
            // Create a minimal EventAction with just Id and Executed_On__c to avoid overwriting fields set by sendTicketing
            EventAction__c updateRecord = new EventAction__c();
            updateRecord.Id = eventAction.Id;
            updateRecord.Executed_On__c = Datetime.now();
            
            DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{updateRecord}, Schema.SObjectType.EventAction__c)
                .handleError(NotificationServiceEventActionImpl.class.getName(), '.executeIteration', logger);
        } else {
            // For failed executions, update the full record (including Response__c from exception)
            DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
                .handleError(NotificationServiceEventActionImpl.class.getName(), '.executeIteration', logger);
        }
    }

    public void sendNotification(String actionType, EventAction__c eventAction) {
        switch on RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionType) {
            when TEAMS {
                NotificationService.sendTeams(eventAction.Event__c, eventAction.Action__r, this.record);
            }
            when EMAIL {
                NotificationService.sendEmail(new List<Messaging.SingleEmailMessage>{NotificationService.createEmailMessage(eventAction.Event__c, eventAction.Action__r)});
            }
            when SLACK {
                NotificationService.sendSlack(eventAction.Event__c, eventAction.Action__r, this.record);
            }
            when JIRA, AZURE_DEV_OPS {
                NotificationService.sendTicketing(RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionType), eventAction, this.logger, this.record);
            }
            when PAGERDUTY {
                NotificationService.sendPagerDuty(eventAction.Event__c, eventAction.Action__r);
            }
            when WEBHOOK {
                new NotificationService.WebhookActionHandler().execute(eventAction.Event__c, eventAction.Action__r);
            }
        }
    }

        /**
         * Generate action iterations for EventAction processing
         * Supports both standard actions and AutoChart workflow
         * 
         * @param record EventAction__c record to process
         * @return List of ActionIteration objects (AutoChart or standard)
         */
        public override List<NotificationService.ActionIteration> getActionIterations(SObject record) {
            EventAction__c eventAction = (EventAction__c)record;
            List<NotificationService.ActionIteration> iterations = new List<NotificationService.ActionIteration>();
            
            try {
                // Check if the associated Action contains AutoChart fields
                if (eventAction.Action__r != null) {
                    RuleUtil.Action action = new RuleUtil.Action(eventAction.Action__r);
                    

                    
                    if (AutoChart.containsAutoChartFields(action)) {
                        List<String> chartTypes = AutoChart.extractChartTypesFromAction(action);
                        
                        // Create AutoChart iterations for 3-step processing workflow
                        Integer iterationCounter = 1;
                        for (AutoChart.AutoChartStep step : AutoChart.AutoChartStep.values()) {
                            iterationCounter++;
                            AutoChart.AutoChartIteration iteration = new AutoChart.AutoChartIteration(
                                eventAction.Id,
                                iterationCounter,
                                0, // Will be set later in batch processing
                                chartTypes,
                                step
                            );
                            iterations.add(iteration);
                        }
                    } else {
                        // Create regular ActionIteration for non-AutoChart EventAction
                        NotificationService.ActionIteration iteration = new NotificationService.ActionIteration(
                            eventAction.Id,
                            2, // Start from 2 (1 is precalculation)
                            0, // Will be set later in batch processing
                            eventAction.Action_Type__c,
                            eventAction.Action__c
                        );
                        iterations.add(iteration);
                    }
                } else {
                    // No associated Action found for EventAction
                }
            } catch (Exception e) {
                // Return empty list on error to prevent batch failures
            }
            
            // Set total iterations for all
            Integer totalIterations = iterations.size() + 1; // +1 for precalculation iteration
            for (NotificationService.ActionIteration iteration : iterations) {
                iteration.totalIterations = totalIterations;
            }
            
            return iterations;
        }

    public override void setRecordFailedStatusThrowBySendErrors() {
        // EventActions handle errors directly in executeIteration()
    }
    public override void addRecordToUpdateMap(String recordId, Boolean isTicketingRule, NotificationService.ExecutableRulesConfig config) {}


    // EventActions don't use the rule-based system, so we override this to do nothing
    public override void setRecordFailedStatusForEmptyRules() {
        // EventActions handle their own error logic in executeIteration()
    }

    // EventActions have all data pre-loaded from the query, no additional fields needed
    public override List<String> getAdditionalSObjectFields(Schema.SObjectType sobjectType) {
        return new List<String>(); // Return empty list instead of trying to access map
    }

    public override String getOrganizationIdFromSObjectRecord() {
        return UserInfo.getOrganizationId();
    }

    // EventActions don't need the complex record details processing
    public override SObject getSobjectRecordDetails() {
        return this.record; // Return the record as-is since all data is already loaded
    }

    // EventActions handle errors directly in executeIteration, no need for ErrorsHelper
    public override void createLogErrors() {
        // EventActions don't use the ErrorsHelper approach
        // Errors are handled directly in executeIteration() method
        // No additional error processing needed
    }

    // Simple processAction method for EventAction compatibility
    public void processAction(RuleUtil.Action action) {
        // EventActions don't use the ActionProcessor framework
        // This method is here for compatibility but shouldn't be called
        // EventActions are processed directly in executeIteration()
    }

    public void processSpecificAction(List<RuleUtil.Action> actions, String targetActionId, String targetActionType) {
        for (RuleUtil.Action action : actions) {
            if (String.valueOf(action.id) == targetActionId && action.type == targetActionType) {
                processAction(action);
                break;
            }
        }
    }

    public override void setIterationRecordFailedStatus() {
        EventAction__c eventAction = (EventAction__c)this.record;
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Executed_On__c, Datetime.now());
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, NotificationService.PREVENT_RECURSION_RESPONSE_MESSAGE);
        DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
            .handleError(NotificationServiceEventActionImpl.class.getName(), '.setIterationRecordFailedStatus', logger);
    }
}