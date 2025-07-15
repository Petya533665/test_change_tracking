public with sharing class MonitoringUtil {

    public static final Integer EVENT_CHART_MAX_RECORDS = 9000;
    public static final String EVENT_RT_MONITORING = 'Monitoring';
    public static final String EVENT_RT_ARCHIVAL = 'Archival';

    public Enum RuleType {
        MONITORING,
        ARCHIVAL,
        JIRA_UPDATE,
        NOTIFICATION,
        BROADCAST,
        AZURE_DEV_OPS
    }
    public static final String RULE_TYPE_MONITORING = 'Monitoring';
    public static final String RULE_TYPE_ARCHIVAL = 'Archival';
    public static final String RULE_TYPE_JIRA_UPDATE = 'JIRA Update';
    public static final String RULE_TYPE_AZURE_DEV_OPS = 'Azure Dev Ops';
    public static final String RULE_TYPE_NOTIFICATION = 'Notification';
    public static final String RULE_TYPE_BROADCAST = 'Broadcast';
    public static final Set<String> IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS = new Set<String>{RULE_TYPE_JIRA_UPDATE, RULE_TYPE_NOTIFICATION, RULE_TYPE_BROADCAST, RULE_TYPE_AZURE_DEV_OPS};
    public static Map<String, RuleType> ruleTypeMap = new Map<String, RuleType> {
        RULE_TYPE_MONITORING => RuleType.MONITORING,
        RULE_TYPE_ARCHIVAL => RuleType.ARCHIVAL,
        RULE_TYPE_JIRA_UPDATE => RuleType.JIRA_UPDATE,
        RULE_TYPE_NOTIFICATION => RuleType.NOTIFICATION,
        RULE_TYPE_BROADCAST => RuleType.BROADCAST,
        RULE_TYPE_AZURE_DEV_OPS => RuleType.AZURE_DEV_OPS
    };


    public Enum ComparisonOperator {
        EQUAL,
        NOT_EQUAL,
        GREATER_THAN,
        GREATER_OR_EQUAL,
        LESS_THAN,
        LESS_OR_EQUAL,
        CONTAINS,
        DOESNT_CONTAIN,
        IS_CHANGED
    }
    public static final String COMPARISON_OPERATOR_EQUAL = 'Equal';
    public static final String COMPARISON_OPERATOR_NOT_EQUAL = 'Not equal';
    public static final String COMPARISON_OPERATOR_GREATER_THEN = 'Greater than';
    public static final String COMPARISON_OPERATOR_GREATER_OR_EQUAL = 'Greater or equal';
    public static final String COMPARISON_OPERATOR_LESS_THAN = 'Less than';
    public static final String COMPARISON_OPERATOR_LESS_OR_EQUAL = 'Less or equal';
    public static final String COMPARISON_OPERATOR_CONTAINS = 'Contains';
    public static final String COMPARISON_OPERATOR_DOSENT_CONTAINS = 'Doesn\'t Contain';
    public static final String COMPARISON_OPERATOR_ISCHANGED = 'Is Changed';
    public static Map<String, ComparisonOperator> comparisonOperatorMap = new Map<String, ComparisonOperator> {
        COMPARISON_OPERATOR_EQUAL => ComparisonOperator.EQUAL,
        COMPARISON_OPERATOR_NOT_EQUAL => ComparisonOperator.NOT_EQUAL,
        COMPARISON_OPERATOR_GREATER_THEN => ComparisonOperator.GREATER_THAN,
        COMPARISON_OPERATOR_GREATER_OR_EQUAL => ComparisonOperator.GREATER_OR_EQUAL,
        COMPARISON_OPERATOR_LESS_THAN => ComparisonOperator.LESS_THAN,
        COMPARISON_OPERATOR_LESS_OR_EQUAL => ComparisonOperator.LESS_OR_EQUAL,
        COMPARISON_OPERATOR_CONTAINS => ComparisonOperator.CONTAINS,
        COMPARISON_OPERATOR_DOSENT_CONTAINS => ComparisonOperator.DOESNT_CONTAIN,
        COMPARISON_OPERATOR_ISCHANGED => ComparisonOperator.IS_CHANGED
    };

    public Enum AggregateType {
        COUNT,
        AVERAGE
    }
    public static final Map<String, AggregateType> MAP_AGGREGATETYPES_BY_STRINGS = new Map<String, AggregateType> {
        'Count' => AggregateType.COUNT,
        'Average' => AggregateType.AVERAGE
    };

    public Enum ComparisonType {
        FIELD,
        VALUE
    }
    public static final String COMPARISON_TYPE_FIELD = 'Field';
    public static final String COMPARISON_TYPE_VALUE = 'Value';
    public static final Map<String, ComparisonType> MAP_COMPARISONTYPES_BY_STRINGS = new Map<String, ComparisonType> {
        COMPARISON_TYPE_FIELD => ComparisonType.FIELD,
        COMPARISON_TYPE_VALUE => ComparisonType.VALUE
    };

    public Enum FieldType {
        FT_DOUBLE,
        FT_DATE,
        FT_DATETIME,
        FT_ID,
        FT_REFERENCE,
        FT_TEXTAREA,
        FT_URL,
        FT_PICKLIST,
        FT_STRING,
        FT_NUMBER,
        FT_BOOLEAN
    }
    public static final String FIELD_TYPE_DOUBLE = 'DOUBLE';
    public static final String FIELD_TYPE_DATE = 'DATE';
    public static final String FIELD_TYPE_DATETIME = 'DATETIME';
    public static final String FIELD_TYPE_ID = 'ID';
    public static final String FIELD_TYPE_REFERENCE = 'REFERENCE';
    public static final String FIELD_TYPE_TEXTAREA = 'TEXTAREA';
    public static final String FIELD_TYPE_URL = 'URL';
    public static final String FIELD_TYPE_PICKLIST = 'PICKLIST';
    public static final String FIELD_TYPE_STRING = 'STRING';
    public static final String FIELD_TYPE_NUMBER = 'NUMBER';
    public static final String FIELD_TYPE_BOOLEAN = 'BOOLEAN';
    public static final Map<String, FieldType> MAP_FIELDTYPES_BY_STRINGS = new Map<String, FieldType> {
        FIELD_TYPE_DOUBLE => FieldType.FT_DOUBLE,
        FIELD_TYPE_DATE => FieldType.FT_DATE,
        FIELD_TYPE_DATETIME => FieldType.FT_DATETIME,
        FIELD_TYPE_ID => FieldType.FT_ID,
        FIELD_TYPE_REFERENCE => FieldType.FT_REFERENCE,
        FIELD_TYPE_TEXTAREA => FieldType.FT_TEXTAREA,
        FIELD_TYPE_URL => FieldType.FT_URL,
        FIELD_TYPE_PICKLIST => FieldType.FT_PICKLIST,
        FIELD_TYPE_STRING => FieldType.FT_STRING,
        FIELD_TYPE_NUMBER => FieldType.FT_NUMBER,
        FIELD_TYPE_BOOLEAN => FieldType.FT_BOOLEAN
    };

    public Enum ActionSubType {
        DEFAULT_ACTION
    }


    public static final String ACTION_SUBTYPE_DEFAULT = 'Default';

    public static final Map<String, ActionSubType> MAP_ACTIONSUBTYPES_BY_STRINGS = new Map<String, ActionSubType> {
        ACTION_SUBTYPE_DEFAULT => ActionSubType.DEFAULT_ACTION
    };

    public Enum ActionType {
        EMAIL,
        SLACK,
        JIRA,
        PAGERDUTY,
        REMOVAL,
        ARCHIVAL_TO_BIG_OBJECT,
        EXTERNAL_ARCHIVAL,
        TEAMS,
        AZURE_DEV_OPS,
        JIRA_TICKET_COMMENT,
        AZURE_DEV_OPS_WORK_ITEM_COMMENT
    }
    public static final String ACTION_TYPE_TEAMS_NOTIFICATION = 'Teams Notification';
    public static final String ACTION_TYPE_EMAIL_NOTIFICATION = 'Email Notification';
    public static final String ACTION_TYPE_SLACK_NOTIFICATION = 'Slack Notification';
    public static final String ACTION_TYPE_JIRA_NOTIFICATION = 'Jira Notification';
    public static final String ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION = 'Azure Dev Ops Notification';
    public static final String ACTION_TYPE_PAGERDUTY_NOTIFICATION = 'PagerDuty Notification';
    public static final String ACTION_TYPE_REMOVAL = 'Removal';
    public static final String ACTION_TYPE_LOCAL_ARCHIVAL = 'Local Archival';
    public static final String ACTION_TYPE_EXTERNAL_ARCHIVAL = 'External Archival';
    public static final String ACTION_TYPE_JIRA_TICKET_COMMENT = 'JIRA Ticket Comment';
    public static final String ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT = 'Azure Dev Ops Work Item Comment';
    public static final String ACTION_SUB_TYPE_NOTIFICATION = 'Notification';
    public static final Map<String, ActionType> MAP_ACTIONTYPES_BY_STRINGS = new Map<String, ActionType> {
        ACTION_TYPE_EMAIL_NOTIFICATION => ActionType.EMAIL,
        ACTION_TYPE_SLACK_NOTIFICATION => ActionType.SLACK,
        ACTION_TYPE_JIRA_NOTIFICATION => ActionType.JIRA,
        ACTION_TYPE_PAGERDUTY_NOTIFICATION => ActionType.PAGERDUTY,
        ACTION_TYPE_REMOVAL => ActionType.REMOVAL,
        ACTION_TYPE_LOCAL_ARCHIVAL => ActionType.ARCHIVAL_TO_BIG_OBJECT,
        ACTION_TYPE_EXTERNAL_ARCHIVAL => ActionType.EXTERNAL_ARCHIVAL,
        ACTION_TYPE_TEAMS_NOTIFICATION => ActionType.TEAMS,
        ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION => ActionType.AZURE_DEV_OPS,
        ACTION_TYPE_JIRA_TICKET_COMMENT => ActionType.JIRA_TICKET_COMMENT,
        ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT => ActionType.AZURE_DEV_OPS_WORK_ITEM_COMMENT
    };
    public static Map<String, List<String>> ruleTypeActionsMap = new Map<String, List<String>> {
        RULE_TYPE_MONITORING => new List<String>{
            ACTION_TYPE_EMAIL_NOTIFICATION,
            ACTION_TYPE_SLACK_NOTIFICATION,
            ACTION_TYPE_JIRA_NOTIFICATION,
            ACTION_TYPE_PAGERDUTY_NOTIFICATION,
            ACTION_TYPE_TEAMS_NOTIFICATION,
            ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION,
            ACTION_TYPE_JIRA_TICKET_COMMENT,
            ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
        },
        RULE_TYPE_ARCHIVAL => new List<String>{
            ACTION_TYPE_REMOVAL,
            ACTION_TYPE_LOCAL_ARCHIVAL,
            ACTION_TYPE_EXTERNAL_ARCHIVAL
        },
        RULE_TYPE_JIRA_UPDATE => new List<String>{
            ACTION_TYPE_JIRA_NOTIFICATION,
            ACTION_TYPE_JIRA_TICKET_COMMENT
        },
        RULE_TYPE_AZURE_DEV_OPS => new List<String>{
            ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION,
            ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
        },
        RULE_TYPE_NOTIFICATION => new List<String>{
            ACTION_TYPE_EMAIL_NOTIFICATION,
            ACTION_TYPE_SLACK_NOTIFICATION,
            ACTION_TYPE_PAGERDUTY_NOTIFICATION,
            ACTION_TYPE_TEAMS_NOTIFICATION,
            ACTION_TYPE_JIRA_TICKET_COMMENT,
            ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT
        }
    };

    private static final Integer MAX_SIZE_TEXTAREA_FILED = 32000;
    private static final Integer MAX_SIZE_IDS_TEXTAREA_FILED = 131000;
    private static final List<String> ACTION_BATCH_CLASS_NAMES = new List<String> {'NotificationBatch', 'ArchivalBatch'};
    private static final String NOTIFICATION_BATCH_JOB_TYPE = 'BatchApex';
    private static final List<String> NOTIFICATION_BATCH_INACTIVE_STATUSES = new List<String> {
        'Queued', 'Processing', 'Preparing', 'Holding'
    };
    private static final List<String> REQUIRED_RULE_FIELDS = new List<String> {
        'Id', 'CreatedDate', 'Created_At__c'
    };
    private static final List<String> REQUIRED_ISSUE_RULE_FIELDS = new List<String> {
        'Id', 'CreatedDate'
    };
    private static final List<String> REQUIRED_TRACE_RESULT_RULE_FIELDS = new List<String> {
        'Id', 'CreatedDate'
    };
    public static final String RULE_SUB_TYPE_FREQUENCY = 'Frequency';
    public static final String RULE_SUB_TYPE_IMPACT = 'Impact';
    public static final String RULE_SUB_TYPE_SPIKE = 'Spike';

    public static final String RULE_ISSUE_SOBJECT_TYPE_FIELD = Schema.SObjectType.Issue__c.getName();

    public static  List<Log__c> getLogs(DateTime lastProcessedDateTime, List<MonitoringUtil.MonitoringRule> rules) {
        List<String> logFields = getLogFields(rules);
        DateTime dt = lastProcessedDateTime;
        String query = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>(logFields))
            .add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':dt'))
            .build();
        List<Log__c> logs = Database.query(query);
        return logs;
    }

    public static String getPackageLogObjectName() {
        return Log__c.getSObjectType().getDescribe().getName();
    }

    public static List<String> getLogFieldNames(List<MonitoringUtil.MonitoringRule> rules) {
        return getSObjectFieldNames(getLogFields(rules), rules);
    }

    public static List<String> getIssueFieldNames(List<MonitoringUtil.MonitoringRule> rules) {
        return getSObjectFieldNames(getIssueFields(rules), rules);
    }

    public static List<String> getSObjectFieldNames(List<String> sobjectFields, List<MonitoringUtil.MonitoringRule> rules) {
        List<String> result = new List<String>();
        for(String fieldName : sobjectFields) {
            String logFieldLocalName = fieldName.replace(ConfigUtil.nameSpacePrefix, '');
            result.add(logFieldLocalName);
        }
        return result;
    }

    public static List<String> getLogFields(List<MonitoringUtil.MonitoringRule> rules) {
        return getSObjectFields(Log__c.sObjectType.getDescribe(), rules);
    }

    public static List<String> getIssueFields(List<MonitoringUtil.MonitoringRule> rules) {
        return getSObjectFields(Issue__c.sObjectType.getDescribe(), rules);
    }

    public static List<String> getTraceResultFields(List<MonitoringUtil.MonitoringRule> rules) {
        return getSObjectFields(Trace_Result__c.sObjectType.getDescribe(), rules);
    }

    public static Map<String, Set<String>> REQUIRED_SOBJECT_FIELDS_BY_NAME = new Map<String, Set<String>>{
        String.valueOf(Log__c.SObjectType) => new Set<String>(REQUIRED_RULE_FIELDS),
        String.valueOf(Issue__c.SObjectType) => new Set<String>(REQUIRED_ISSUE_RULE_FIELDS),
        String.valueOf(Trace_Result__c.SObjectType) => new Set<String>(REQUIRED_TRACE_RESULT_RULE_FIELDS)
    };

    public static List<String> getSObjectFields(Schema.DescribeSObjectResult dsr, List<MonitoringUtil.MonitoringRule> rules) {
        List<String> result = new List<String>();
        Set<String> filterFields = REQUIRED_SOBJECT_FIELDS_BY_NAME.get(dsr.getName());

        Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
        Set<String> logFieldsSet = fieldsMap.keySet();

        for(MonitoringUtil.MonitoringRule rule : rules) {
            for(RuleFilter filter : rule.filters) {
                if(logFieldsSet.contains(filter.fieldName.toLowerCase())) {
                    filterFields.add(filter.fieldName);
                }
            }
            if(rule?.groupFieldNames != null) {
                for(String groupFiledName : rule.groupFieldNames) {
                    if(logFieldsSet.contains(groupFiledName.toLowerCase())) {
                        filterFields.add(groupFiledName);
                    }
                }
            }
            // remove extra created_at field
            if(rule.ruleType == RULE_TYPE_ARCHIVAL) {
                filterFields.remove(Schema.SObjectType.Log__c.fields.Created_At__c.getName());
            }
        }
        result = new List<String>(filterFields);

        return result;
    }

    public static final String NOTIFICATION_INTEGRATION_STATUS_PENDING = 'Pending';
    public static final String NOTIFICATION_INTEGRATION_STATUS_FAILED = 'Failed';
    public static final String NOTIFICATION_INTEGRATION_STATUS_COMPLETED = 'Completed';
    public static final String JIRA_INTEGRATION_STATUS_PENDING = 'Ticket Pending';


    public static void evaluateArchivalRules(List<MonitoringRule> rules, List<Log__c> logs, Logger logger) {
        List<MonitoringRule> toCreateEvents = new List<MonitoringRule>();
        List<Event__c> newEvents = new List<Event__c>();
        List<EventAction__c> newEventActions = new List<EventAction__c>();
        for (MonitoringRule rule : rules) {
            rule.applyArchivalRules(logs);
            if (!rule.archivalLogs.isEmpty()) {
                rule.populateCriteria();
                toCreateEvents.add(rule);
            }
        }
        if (!toCreateEvents.isEmpty()) {
            newEvents = createEvents(toCreateEvents);
            newEventActions = createEventActions(toCreateEvents, logger);
        }
    }

    public static void evaluateRules(
        List<Log__c> logs,
        List<Id> ruleIds,
        Datetime runDateTime,
        Map<Id, MonitoringUtil.Event> eventsMap,
        Logger logger) {

        List<MonitoringRule> rules = getMonitoringRules(ruleIds);
        List<MonitoringRule> toCreateEvents = new List<MonitoringRule>();
        List<Event__c> newEvents = new List<Event__c>();
        List<EventAction__c> newEventActions = new List<EventAction__c>();

        applyRulesFilters(rules, logs, runDateTime, eventsMap);
        toCreateEvents = filterRulesByTresholds(rules);
        if (!toCreateEvents.isEmpty()) {
            newEvents = createEvents(toCreateEvents);
            newEventActions = createEventActions(toCreateEvents, logger);
        }
    }

    private static void applyRulesFilters(
            List<MonitoringRule> rules,
            List<Log__c> logs,
            DateTime runDatetime,
            Map<Id, MonitoringUtil.Event> eventsMap) {

        applyRulesFilters(rules, logs, runDatetime, eventsMap, true);
    }

    private static void applyRulesFilters(
        List<MonitoringRule> rules,
        List<Log__c> logs,
        DateTime runDatetime,
        Map<Id, MonitoringUtil.Event> eventsMap,
        Boolean checkLogsInterval) {

        for(MonitoringRule rule : rules) {
            if(rule.sobjectType != null) continue;

            switch on rule.aggregateType {
                when COUNT {
                    if(rule.aggregateInterval != null || rule.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                        List<List<Log__c>> logsIntervals = splitLogsByInterval(runDatetime, logs, rule, eventsMap, checkLogsInterval);
                        Integer countIntervals = logsIntervals.size();
                        Integer currentInterval = 1;

                        for(List<Log__c> logsInterval : logsIntervals) {
                            rule.applyFilters(logsInterval, currentInterval, countIntervals, runDatetime, eventsMap, checkLogsInterval);
                            currentInterval += 1;
                        }
                    }
                    else {
                        rule.applyFilters(logs, 1, 1, runDatetime, eventsMap, checkLogsInterval);
                    }
                }
                when AVERAGE {
                    List<List<Log__c>> logsIntervals = splitLogsByInterval(runDatetime, logs, rule, eventsMap, checkLogsInterval);
                    Integer countIntervals = logsIntervals.size();
                    Integer currentInterval = 1;

                    for(List<Log__c> logsInterval : logsIntervals) {
                        rule.applyFilters(logsInterval, currentInterval, countIntervals, runDatetime, eventsMap, checkLogsInterval);
                        currentInterval += 1;
                    }

                    if(rule.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                        for(Integer interval : rule.groupValues.keySet()) {
                            for(String key : rule.groupValues.get(interval).keySet()) {
                                Decimal groupValue = rule.groupValues.get(interval).get(key);
                                groupValue = groupValue / countIntervals;
                                rule.groupValues.get(interval).put(key, groupValue);
                            }
                        }
                    }
                }
            }
        }
    }


    private static List<MonitoringRule> filterRulesByTresholds(List<MonitoringRule> rules) {
        List<MonitoringRule> result = new List<MonitoringRule>();
        for(MonitoringRule rule : rules) {
            Boolean ruleResult = false;

            if(!rule.groupFieldNames.isEmpty() || rule.aggregateInterval != null || rule.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                for(Integer interval : rule.groupValues.keySet()) {
                    Boolean intervalGroupResult = false;

                    for(String key : rule.groupValues.get(interval).keySet()) {
                        Boolean ruleGroupResult = false;
                        Decimal groupValue = rule.groupValues.get(interval).get(key);
                        Set<String> groupRecordIds = rule.groupRecordIds.get(key);
                        if(groupRecordIds == null) {
                            groupRecordIds = new Set<String>();
                        }

                        switch on rule.comparisonOperatorType {
                            when EQUAL {
                                ruleGroupResult = groupValue == rule.threshold;
                            }
                            when NOT_EQUAL {
                                ruleGroupResult = groupValue != rule.threshold;
                            }
                            when GREATER_THAN {
                                ruleGroupResult = groupValue > rule.threshold;
                            }
                            when GREATER_OR_EQUAL {
                                ruleGroupResult = groupValue >= rule.threshold;
                            }
                            when LESS_THAN {
                                ruleGroupResult = groupValue < rule.threshold;
                            }
                            when LESS_OR_EQUAL {
                                ruleGroupResult = groupValue <= rule.threshold;
                            }
                        }

                        if(ruleGroupResult) {
                            rule.value += groupValue;
							rule.recordIds.addAll(groupRecordIds);
                            intervalGroupResult = true;
                        }
                        else {
                            rule.groupValues.get(interval).remove(key);
                            rule.groupRecordIds.remove(key);
                        }
                    }

                    if(intervalGroupResult) {
                        ruleResult = true;
                    }
                    else {
                        ruleResult = false;
                        break;
                    }
                }
            }
            else {
                switch on rule.comparisonOperatorType {
                    when EQUAL {
                        ruleResult = rule.value == rule.threshold;
                    }
                    when NOT_EQUAL {
                        ruleResult = rule.value != rule.threshold;
                    }
                    when GREATER_THAN {
                        ruleResult = rule.value > rule.threshold;
                    }
                    when GREATER_OR_EQUAL {
                        ruleResult = rule.value >= rule.threshold;
                    }
                    when LESS_THAN {
                        ruleResult = rule.value < rule.threshold;
                    }
                    when LESS_OR_EQUAL {
                        ruleResult = rule.value <= rule.threshold;
                    }
                }
            }

            // create Monitoring Events
            if(ruleResult) {
                rule.populateCriteria();
                result.add(rule);
            }
        }
		// split rules by key groups
        Map<String, MonitoringRule> mapRulesByGroupKey = new Map<String, MonitoringRule>();
        for(MonitoringRule rule : result) {
            if(!rule.groupFieldNames.isEmpty() || rule.aggregateInterval != null || rule.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                for(Integer interval : rule.groupValues.keySet()) {
                    for (String key : rule.groupValues.get(interval).keySet()) {
                        Decimal groupValue = rule.groupValues.get(interval).get(key);
                        Set<String> groupRecordIds = rule.groupRecordIds.get(key);

                        MonitoringRule groupKeyRule = mapRulesByGroupKey.get(key);
                        if(groupKeyRule == null) {
                            groupKeyRule = new MonitoringRule(rule);
                            groupKeyRule.groupValues.put(interval, new Map<String, Decimal>());

                        }
                        groupKeyRule.groupValues.put(interval, new Map<String, Decimal>());
                        groupKeyRule.groupRecordIds.put(key, groupRecordIds);
                        groupKeyRule.groupValues.get(interval).put(key, groupValue);
                        mapRulesByGroupKey.put(key, groupKeyRule);
                    }
                }
            }
        }
        if(!mapRulesByGroupKey.isEmpty()) {
            return mapRulesByGroupKey.values();
        }

        return result;
    }

    public static List<List<Log__c>> splitLogsByInterval(
            DateTime runTime,
            List<Log__c> logs,
            MonitoringUtil.MonitoringRule rule,
            Map<Id, MonitoringUtil.Event> eventsMap) {

        return splitLogsByInterval(runTime, logs, rule, eventsMap, true);
    }

    public static List<List<Log__c>> splitLogsByInterval(
        DateTime runTime,
        List<Log__c> logs,
        MonitoringUtil.MonitoringRule rule,
        Map<Id, MonitoringUtil.Event> eventsMap,
        Boolean checkLogIntervalTime) {

        Integer eventTypeInterval = Integer.valueOf(rule.eventTypeInterval);
        Integer intervalInMinutes = Integer.valueOf(rule.aggregateInterval);
        Integer countIntervals = (intervalInMinutes != 0) ? eventTypeInterval / intervalInMinutes : 0;
        MonitoringUtil.Event event = (eventsMap != null && eventsMap.get(rule.ruleId) != null)
            ? eventsMap.get(rule.ruleId)
            : null;

        DateTime runTimeLocal = runTime;
        List<List<Log__c>> result = new List<List<Log__c>>();
        DateTime lastProcessDatetime = event != null ? event.createdDate : null;
        Map<Long, List<Log__c>> mapLogsByIntervals = new Map<Long, List<Log__c>>();

        for(Integer i = 0; i < countIntervals; i++) {
            Integer hours = intervalInMinutes / 60;
            Integer minutes = Math.mod(intervalInMinutes, 60);

            Datetime roundedDateTimeByInterval = runTimeLocal.addMinutes(
                runTimeLocal.minute() > 30
                    ? - (runTimeLocal.minute() - minutes)
                    : - runTimeLocal.minute()
            );
            if(hours != 0) {
                Integer nearHour = ((roundedDateTimeByInterval.hour() / hours) * hours);
                roundedDateTimeByInterval = roundedDateTimeByInterval.addHours( -(roundedDateTimeByInterval.hour() - nearHour));
            }

            Long roundedMills = roundedDateTimeByInterval.getTime();
            roundedMills = roundedMills/100000*100000;
            mapLogsByIntervals.put(roundedMills, new List<Log__c>());
            runTimeLocal = runTimeLocal.addMinutes(-intervalInMinutes);
        }



        for(Log__c log : logs) {
            if(checkLogIntervalTime && !inCurrentInterval(log.Created_At__c, runTime, lastProcessDatetime, eventTypeInterval)) {
                continue;
            }

            Integer hours = intervalInMinutes / 60;
            Integer minutes = Math.mod(intervalInMinutes, 60);

            Datetime roundedDateTimeByInterval = log.Created_At__c.addMinutes(
                log.Created_At__c.minute() > 30
                    ? - (log.Created_At__c.minute() - minutes)
                    : - log.Created_At__c.minute()
            );
            if(hours != 0) {
                Integer nearHour = ((roundedDateTimeByInterval.hour() / hours) * hours);
                roundedDateTimeByInterval = roundedDateTimeByInterval.addHours( -(roundedDateTimeByInterval.hour() - nearHour));
            }

            Long roundedMills = roundedDateTimeByInterval.getTime();
            roundedMills = roundedMills/100000*100000;
            List<Log__c> logsByMills = mapLogsByIntervals.get(roundedMills) != null
                ? mapLogsByIntervals.get(roundedMills)
                : new List<Log__c>();

            logsByMills.add(log);
            mapLogsByIntervals.put(roundedMills, logsByMills);
        }
        for(List<Log__c> logsList : mapLogsByIntervals.values()) {
            result.add(logsList);
        }
        return result;
    }


    public static List<EventAction__c> createEventActions(List<MonitoringRule> rules, Logger logger) {
        List<EventAction__c> newEventActions = new List<EventAction__c>();
        for(MonitoringRule monitoringRule : rules) {

            if(IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(monitoringRule.ruleType)) continue;

            for(Action action : monitoringRule.actions) {
                EventAction__c newEventAction = new EventAction__c();
                newEventAction.Action_Type__c = action.type;
                newEventAction.Event__c = monitoringRule.eventId;
                newEventAction.Contents__c = action.content;
                newEventAction.Action__c = action.actionId;
                newEventAction.Subject__c = action.fields.Subject__c;
                newEventAction.Body__c = action.fields.Body__c;

                switch on action.actionType {
                    when TEAMS {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_TEAMS + action.fields.Channel_Id__c;
                    }
                    when SLACK {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_SLACK + action.fields.SlackChannels__c.split(',');
                    }
                    when JIRA {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_JIRA;
                    }
                    when EMAIL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_EMAIL + action.fields.EmailTo__c;
                    }
                    when PAGERDUTY {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_PAGER_DUTY + action.fields.PagerDuty_Type__c + ' :';
                    }
                    when REMOVAL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_REMOVAL;
                    }
                    when ARCHIVAL_TO_BIG_OBJECT {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_LOCAL_ARCHIVAL;
                    }
                    when EXTERNAL_ARCHIVAL {
                        newEventAction.Delivered_to__c = ConfigUtil.EVENT_ACTION_DELIVERED_TO_SPLUNK;
                    }
                }

                if ((action.actionType == ActionType.SLACK
                        && PermissionsUtil.SlackIntegrationEnabled
                        && ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c
                        && ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c != null)
                    || (action.actionType == ActionType.TEAMS
                        && PermissionsUtil.TeamsIntegrationEnabled
                        && ConfigUtil.GRAPH_API_SETTINGS.Enabled__c)
                    || (action.actionType == ActionType.JIRA && PermissionsUtil.JiraIntegrationEnabled)
                    || action.actionType == ActionType.EMAIL
                    || (action.actionType == ActionType.PAGERDUTY && PermissionsUtil.PagerDutyIntegrationEnabled)
                    || (action.actionType == ActionType.REMOVAL && PermissionsUtil.ArchivalEnabled)
                    || (action.actionType == ActionType.ARCHIVAL_TO_BIG_OBJECT && PermissionsUtil.ArchivalEnabled)
                    || (action.actionType == ActionType.EXTERNAL_ARCHIVAL && PermissionsUtil.SplunkIntegrationEnabled)) {

                    newEventActions.add(newEventAction);
                }
            }
        }

        if(!newEventActions.isEmpty()) {
            Map<String, List<String>> contentsMap = new Map<String, List<String>>();
            for(EventAction__c newEventAction : newEventActions) {
                contentsMap.put(newEventAction.Event__c, new List<String>{newEventAction.Subject__c, newEventAction.Body__c});
            }
            Map<String, List<String>> renderResult = NotificationService.renderMergeFields(contentsMap);
            for(EventAction__c newEventAction : newEventActions) {
                List<String> renderedMessages = renderResult.get(newEventAction.Event__c);
                newEventAction.Subject__c = renderedMessages.get(0);
                newEventAction.Body__c = renderedMessages.get(1);
            }
            newEventActions = DatabaseUtils.getInstance().performInsertDML(newEventActions, Schema.SObjectType.EventAction__c)
                    .handleError(MonitoringUtil.class.getName(), '.createEventActions', logger).getSuccessSObjects();
        }
        return newEventActions;
    }

    public static void checkStartActionsBatch() {
        checkStartActionsBatch(System.isBatch());
    }

    public static void checkStartActionsBatch(Boolean isBatchContext) {
        if (!isBatchContext) {
            List<EventAction__c> sendlist = [
                SELECT Id, Type__c, Action_Type__c
                FROM EventAction__c
                WHERE Event__r.Rule__r.Active__c = TRUE 
                    AND Executed_On__c = NULL
                    AND Action__c != NULL
                ORDER BY Index__c DESC
                LIMIT 1
            ];
            Boolean startBatch = !sendlist.isEmpty();
            Boolean freeSlotBatch = false;

            List<AsyncApexJob> active_batches = [
                SELECT Id FROM AsyncApexJob
                WHERE
                    ApexClass.Name IN :ACTION_BATCH_CLASS_NAMES
                    AND Status IN :NOTIFICATION_BATCH_INACTIVE_STATUSES
                    AND JobType = :NOTIFICATION_BATCH_JOB_TYPE
                LIMIT 1
            ];
            freeSlotBatch = active_batches.isEmpty();

            if(startBatch && freeSlotBatch) {
                String actionType = sendlist.get(0).Action_Type__c != null ? sendlist.get(0).Action_Type__c : sendlist.get(0).Type__c;
                switch on MonitoringUtil.MAP_ACTIONTYPES_BY_STRINGS.get(actionType) {
                    when EMAIL, SLACK, PAGERDUTY, JIRA, TEAMS {
                        NotificationBatch.getInstance().startBatch();
                    }
                    when REMOVAL, ARCHIVAL_TO_BIG_OBJECT {
                        ArchivalBatch.getInstance(sendlist.get(0), 200).startBatch();
                    }
                    when EXTERNAL_ARCHIVAL {
                        ArchivalBatch.getInstance(sendlist.get(0), 1).startBatch();
                    }
                }
            }
        }
    }

    public static String getnotificationDescription(EventAction__c eventAction) {
        return getnotificationDescription(eventAction, false);
    }


    public static String getnotificationDescription(EventAction__c eventAction, Boolean is_HTML) {
        String symb = is_HTML ? '<br/>' : '\n';
        String notificationDescription = symb + URL.getOrgDomainUrl().toExternalForm() + '/' + eventAction.Event__c + symb + symb
            + eventAction.Event__r.Criteria__c  + symb
            + 'Number of Records = ' + eventAction.Event__r.RecordCount__c + symb;
        return notificationDescription;
    }

    public static List<Event__c> createEvents(List<MonitoringRule> rules) {
        List<Event__c> newEvents = new List<Event__c>();
        Map<String, List<Log__c>> mapRuleLogs = getMapRuleLogs(rules);
        Schema.DescribeSObjectResult eventDescribe = Schema.SObjectType.Event__c;
        Map<String,Schema.RecordTypeInfo> rtMapByName = eventDescribe.getRecordTypeInfosByName();
        Id rtMonitoringId =  rtMapByName.get(EVENT_RT_MONITORING).getRecordTypeId();
        Id rtArchivalId =  rtMapByName.get(EVENT_RT_ARCHIVAL).getRecordTypeId();

        for(MonitoringRule monitoringRule : rules) {

            if(IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(monitoringRule.ruleType)) continue;

            Event__c newEvent = new Event__c();
            newEvent.RecordTypeId = (monitoringRule.ruleType == RULE_TYPE_ARCHIVAL) ? rtArchivalId : rtMonitoringId;
            newEvent.Criteria__c = monitoringRule.criteria;

            if(monitoringRule.ruleType == RULE_TYPE_ARCHIVAL) {
                // Fix: Added null check for archivalLogs
                List<Id> archivalLogsToProcess = monitoringRule.archivalLogs != null ? monitoringRule.archivalLogs : new List<Id>();
                newEvent.RecordCount__c = archivalLogsToProcess.size();
                newEvent.Records__c = JSON.serialize(archivalLogsToProcess).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
            }
            else {
                // Fix: Added null check for recordIds
                newEvent.RecordCount__c = monitoringRule.recordIds != null ? monitoringRule.recordIds.size() : 0;
                if(monitoringRule.groupRecordIds != null && !monitoringRule.groupRecordIds.isEmpty()) {
                    newEvent.Records__c = JSON.serialize(monitoringRule.groupRecordIds).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
                    newEvent.Grouped_Field_Values__c = JSON.serialize(monitoringRule.groupRecordIds.keySet()).abbreviate(MAX_SIZE_TEXTAREA_FILED);
                    // Fix: Added null check for individual Set<String> values in the collection
                    Set<String> firstGroupRecordSet = null;
                    if (monitoringRule.groupRecordIds != null && !monitoringRule.groupRecordIds.isEmpty() && monitoringRule.groupRecordIds.values() != null && !monitoringRule.groupRecordIds.values().isEmpty()) {
                        for (Set<String> recordSet : monitoringRule.groupRecordIds.values()) {
                            if (recordSet != null) {
                                firstGroupRecordSet = recordSet;
                                break;
                            }
                        }
                    }
                    newEvent.RecordCount__c = (firstGroupRecordSet != null) ? firstGroupRecordSet.size() : 0;
                }
                else {
                    // Fix: Added null check for recordIds serialization
                    Set<String> recordIdsToSerialize = monitoringRule.recordIds != null ? monitoringRule.recordIds : new Set<String>();
                    newEvent.Records__c = JSON.serialize(recordIdsToSerialize).abbreviate(MAX_SIZE_IDS_TEXTAREA_FILED);
                }
                // Fix: Added null checks for aggregateTypeString and value
                String aggregateTypeStr = monitoringRule.aggregateTypeString != null ? monitoringRule.aggregateTypeString : 'Unknown';
                String valueStr = '0';
                try {
                    valueStr = monitoringRule.value != null ? monitoringRule.value.toPlainString() : '0';
                } catch (Exception e) {
                    // Fallback if value access fails
                    valueStr = '0';
                }
                newEvent.Description__c = 'Rule Id:' + monitoringRule.ruleId
                        + ' ' + aggregateTypeStr + ':' + valueStr;
                // Fix: Added null checks for groupFieldNames and groupValues
                if(monitoringRule.groupFieldNames != null && !monitoringRule.groupFieldNames.isEmpty()) {
                    Map<Integer, Map<String, Decimal>> groupValuesToSerialize = monitoringRule.groupValues != null ? monitoringRule.groupValues : new Map<Integer, Map<String, Decimal>>();
                    newEvent.Description__c += json.serialize(groupValuesToSerialize);
                }
                newEvent.Description__c = newEvent.Description__c.abbreviate(255);

                Map<String, Integer> actionsMap = new Map<String, Integer>();
                // Fix: Added null check for actions collection
                if (monitoringRule.actions != null) {
                    for(Action ent : monitoringRule.actions) {
                        if (ent != null && ent.type != null) {
                            Integer actionCount = actionsMap.get(ent.type) != null ? actionsMap.get(ent.type) : 0;
                            actionCount += 1;
                            actionsMap.put(ent.type, actionCount);
                        }
                    }
                }
                if(!actionsMap.isEmpty()) {
                    newEvent.Actions__c = JSON.serialize(actionsMap);
                }
                if(mapRuleLogs.get(monitoringRule.ruleId) != null) {
                    newEvent.Event_Details__c = getEventDetails(mapRuleLogs.get(monitoringRule.ruleId));
                }
            }

            newEvent.Rule__c = monitoringRule.ruleId;
            newEvents.add(newEvent);
        }

        if(!newEvents.isEmpty()) {
            insert newEvents;

            for(Integer i = 0; i < newEvents.size(); i++) {
                if(IGNORE_RULE_TYPES_FOR_MONITORING_EVENTS.contains(rules.get(i).ruleType)) continue;
                rules.get(i).eventId = newEvents.get(i).Id;
            }
        }

        return newEvents;
    }

    private static String getEventDetails(List<Log__c> ruleLogs) {
        String result = '';
        for(Log__c log : ruleLogs) {
            result +=  '\n' + log.Summary__c + '\n';
            result += 'Link to Log:' + URL.getOrgDomainUrl().toExternalForm() + '/' + log.Id + '\n';
        }
        return result;
    }

    @TestVisible
    private static Map<String, List<Log__c>> getMapRuleLogs(List<MonitoringRule> rules) {
        Map<String, List<Log__c>> result = new Map<String, List<Log__c>>();
        Set<Id> allRecordIds = new Set<Id>();
        final Integer limitLogsPerRule = 5;
        Map<String, String> mapRuleIdbyLogId = new Map<String, String>();

        for(MonitoringRule monitoringRule : rules) {
            Integer logsPerRule = 0;
            if(monitoringRule.groupRecordIds != null && !monitoringRule.groupRecordIds.isEmpty() && monitoringRule.groupRecordIds.values() != null) {
                for(Set<String> logIdList : monitoringRule.groupRecordIds.values()) {
                    if(logIdList != null) {
                        for(String logId : logIdList) {
                            if(logId != null) {
                                allRecordIds.add(logId);
                                mapRuleIdbyLogId.put(logId, monitoringRule.ruleId);
                                logsPerRule += 1;
                                if(logsPerRule > limitLogsPerRule) break;
                            }
                        }
                    }
                    if(logsPerRule > limitLogsPerRule) break;
                }
            }
            else if (monitoringRule.recordIds != null && !monitoringRule.recordIds.isEmpty()) {
                for(String logId : monitoringRule.recordIds) {
                    if(logId != null) {
                        allRecordIds.add(logId);
                        mapRuleIdbyLogId.put(logId, monitoringRule.ruleId);
                        logsPerRule += 1;
                        if(logsPerRule > limitLogsPerRule) break;
                    }
                }
            }
        }

        if(!allRecordIds.isEmpty()) {
            List<Log__c> logs = [SELECT Id, Summary__c FROM Log__c WHERE Id IN :allRecordIds];
            for(Log__c log : logs) {
                String ruleId = mapRuleIdbyLogId.get(log.Id);
                if(ruleId != null) {
                    List<Log__c> ruleLogs = (result.get(ruleId) != null) ? result.get(ruleId) : new List<Log__c>();
                    ruleLogs.add(log);
                    result.put(ruleId, ruleLogs);
                }
            }
        }
        return result;
    }

    public static List<MonitoringRule> getArchivalRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_ARCHIVAL, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_ARCHIVAL, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getMonitoringRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_MONITORING, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_MONITORING, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getJiraRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_JIRA_UPDATE, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_JIRA_UPDATE, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getAzureDevOpsRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_AZURE_DEV_OPS, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_AZURE_DEV_OPS, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getAzureDevOpsRules(List<Id> ruleIds, String sobjectType) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_AZURE_DEV_OPS, sobjectType);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_AZURE_DEV_OPS, sobjectType);
        }
        return rules;
    }

    public static List<MonitoringRule> getJiraRules(List<Id> ruleIds, String sobjectType) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_JIRA_UPDATE, sobjectType);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_JIRA_UPDATE, sobjectType);
        }
        return rules;
    }

    public static List<MonitoringRule> getNotificationRules(List<Id> ruleIds, String sobjectType) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_NOTIFICATION, sobjectType);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_NOTIFICATION, sobjectType);
        }
        return rules;
    }

    public static List<MonitoringRule> getNotificationRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_NOTIFICATION, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_NOTIFICATION, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getBroadcastRules(List<Id> ruleIds) {
        List<MonitoringRule> rules = getRulesFromCache(ruleIds, RULE_TYPE_BROADCAST, null);
        if(rules == null) {
            rules = getRules(ruleIds, RULE_TYPE_BROADCAST, null);
        }
        return rules;
    }

    public static List<MonitoringRule> getRules(List<Id> ruleIds, String ruleType) {
        return getRules(ruleIds, ruleType, null);
    }

    public static List<MonitoringRule> getRules(List<Id> ruleIds, String ruleType, String sobjectType) {
        List<MonitoringRule> result = new List<MonitoringRule>();

        List<Rule__c> rules = getRuleRecords(ruleIds, ruleType);
        for(Rule__c rule : rules) {
            MonitoringRule mr = new MonitoringRule(rule)
                .addFilters(rule.RuleFilters__r)
                .addActions(rule.RuleActions__r);
            addRulesToCache(new List<MonitoringRule>{mr}, ruleType);

            if(rule.SObjectType__c == sobjectType) {
                result.add(mr);
            }
        }
        if((rules == null || rules.isEmpty()) && cachedRules?.get(ruleType) == null && ruleIds == null) {
            addRulesToCache(new List<MonitoringRule>(), ruleType);
        }
        return result;
    }

    public static Map<String, Map<Id, MonitoringRule>> cachedRules = new Map<String, Map<Id, MonitoringRule>>();

    public static List<MonitoringRule> getRulesFromCache(List<Id> ruleIds, String ruleType, String sobjectType) {
        List<MonitoringRule> result;

        Map<Id, MonitoringRule> rulesByType = cachedRules?.get(ruleType);
        if(!cachedRules?.containsKey(ruleType) && rulesByType == null) {
            return result;
        }
        if(cachedRules?.containsKey(ruleType) && rulesByType == null) {
            return new List<MonitoringRule>();
        }
        if(ruleIds == null) {
            result = cachedRules.get(ruleType)?.values();
        }
        else {
            result = new List<MonitoringRule>();
            Set<Id> ruleIdsToRetrieve = new Set<Id>();

            for(Id ruleId : ruleIds) {
                if(rulesByType.containsKey(ruleId)) {
                    result.add(rulesByType.get(ruleId));
                }
                else {
                    ruleIdsToRetrieve.add(ruleId);
                }
            }
            if(!ruleIdsToRetrieve.isEmpty()) {
                List<MonitoringRule> additionalRules = getRules(new List<Id>(ruleIdsToRetrieve), ruleType, sobjectType);
                result.addAll(additionalRules);
            }
        }
        return result;
    }

    public static void addRulesToCache(List<MonitoringRule> rules, String ruleType) {
        Map<Id, MonitoringRule> allExistRules = cachedRules.get(ruleType);
        if(rules != null && !rules.isEmpty()) {
            if(allExistRules == null) {
                allExistRules = new Map<Id, MonitoringRule>();
            }
            for(MonitoringRule rule : rules) {
                if(!allExistRules.containsKey(rule.ruleId)) {
                    allExistRules.put(rule.ruleId, rule);
                }
            }
        }
        cachedRules.put(ruleType, allExistRules);
    }

    public static Map<Id, Event> getLastCreatedEventsMap() {
        Map<Id, Event> result = new Map<Id, Event>();
        List<AggregateResult> events = [
            SELECT MAX(CreatedDate) CreatedDate, Rule__c RuleId
            FROM Event__c
            GROUP BY Rule__c
        ];
        for(AggregateResult event : events) {
            DateTime createdDate = (DateTime)event.get('CreatedDate');
            Id ruleId = (Id)event.get('RuleId');
            if (ruleId != null && createdDate != null) {
                Event maxEvent = new Event(createdDate, ruleId);
                result.put(ruleId, maxEvent);
            }
        }
        return result;
    }

    private static Boolean inCurrentInterval(
        Datetime createdDateTime,
        DateTime runTime,
        DateTime lastProcessedDateTime,
        Decimal eventTypeInterval) {

        DateTime startTime;
        DateTime endTime;

        if(lastProcessedDateTime == null) {
            startTime = (eventTypeInterval != null)
                ? runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval))
                : null;
            endTime = runTime;
        }
        else {
            startTime = eventTypeInterval != null
                ? (lastProcessedDateTime >= runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval))
                    ? lastProcessedDateTime
                    : runTime.addMinutes(-1*Integer.valueOf(eventTypeInterval)))
                : lastProcessedDateTime;
            endTime = runTime;
        }
        return createdDateTime <= endTime && createdDateTime >= startTime;
    }

    public static List<Rule__c> getRuleRecords(List<Id> ruleIds, String ruleType) {
        List<Rule__c> rules;
        Integer limitRules = 0;
        if(ruleType == RULE_TYPE_ARCHIVAL) {
            limitRules = PermissionsUtil.MaxArchivalRules;
        }
        else if(ruleType == RULE_TYPE_MONITORING) {
            limitRules = PermissionsUtil.MaxMonitoringRules;
        }
        else if(ruleType == RULE_TYPE_JIRA_UPDATE || ruleType == RULE_TYPE_AZURE_DEV_OPS) {
            limitRules = PermissionsUtil.MaxJiraRules;
        }
        else if(ruleType == RULE_TYPE_NOTIFICATION) {
            limitRules = PermissionsUtil.MaxNotificationRules;
        }
        else if (ruleType == RULE_TYPE_BROADCAST) {
            limitRules = PermissionsUtil.MaxConnectedOrgs;
        }

        if(ruleIds != null) {
            rules = [
                SELECT Id, AggregateInterval__c,
                    AggregateType__c,  ComparisonOperator__c,
                    Threshold__c, FilterLogic__c,
                    EventTimeInterval__c,
                    Type__c, Subtype__c, Related_Id__c, SObjectType__c,
                    Is_Update__c,
                (SELECT Id, Index__c, ComparisonOperator__c,
                    FieldName__c, Value__c, Is_Old__c, 
                    Comparison_Type__c, Field_Type__c
                FROM RuleFilters__r ORDER BY Index__c ASC NULLS LAST
                ),
                (SELECT Id, Action__r.Type__c,
                    Action__r.Action_Type__c,
                    Action__r.Subtype__c,
                    Action__r.Body__c,
                    Action__r.CreatedDate__c,
                    Action__r.Description__c,
                    Action__r.EmailBody__c,
                    Action__r.EmailCC__c,
                    Action__r.EmailTemplateId__c,
                    Action__r.EmailTo__c,
                    Action__r.JIRAAssignee__c,
                    Action__r.JIRAAssignee_Id__c,
                    Action__r.JIRAComponents__c,
                    Action__r.JIRAEpic__c,
                    Action__r.JIRAIssueType__c,
                    Action__r.JIRALabels__c,
                    Action__r.JIRAPriority__c,
                    Action__r.JIRAProject__c,
                    Action__r.SlackChannels__c,
                    Action__r.Subject__c,
                    Action__r.PagerDuty_Type__c,
                    Action__r.Team_Id__c,
                    Action__r.Channel_Id__c,
                    Action__r.Additional_Metadata__c,
                    Action__r.Iteration__c,
                    Action__r.Is_Update__c
                FROM RuleActions__r
                )
                FROM Rule__c
                WHERE Active__c = true
                    AND Is_Not_Valid__c = false
                    AND Id IN :ruleIds
                    AND Type__c = :ruleType
                ORDER BY Index__c ASC nulls last
                LIMIT :limitRules
            ];
        }
        else {
            rules = [
                SELECT Id, AggregateInterval__c,
                    AggregateType__c,  ComparisonOperator__c,
                    Threshold__c, FilterLogic__c,
                    EventTimeInterval__c,
                    Type__c, Subtype__c, Related_Id__c, SObjectType__c,
                    Is_Update__c,
                (SELECT Id, Index__c, ComparisonOperator__c,
                    FieldName__c, Value__c, Is_Old__c,
                    Comparison_Type__c, Field_Type__c
                FROM RuleFilters__r ORDER BY Index__c ASC NULLS LAST
                ),
                (SELECT Id, Action__r.Type__c,
                    Action__r.Action_Type__c,
                    Action__r.Subtype__c,
                    Action__r.Body__c,
                    Action__r.CreatedDate__c,
                    Action__r.Description__c,
                    Action__r.EmailBody__c,
                    Action__r.EmailCC__c,
                    Action__r.EmailTemplateId__c,
                    Action__r.EmailTo__c,
                    Action__r.JIRAAssignee__c,
                    Action__r.JIRAAssignee_Id__c,
                    Action__r.JIRAComponents__c,
                    Action__r.JIRAEpic__c,
                    Action__r.JIRAIssueType__c,
                    Action__r.JIRALabels__c,
                    Action__r.JIRAPriority__c,
                    Action__r.JIRAProject__c,
                    Action__r.SlackChannels__c,
                    Action__r.Subject__c,
                    Action__r.PagerDuty_Type__c,
                    Action__r.Team_Id__c,
                    Action__r.Channel_Id__c,
                    Action__r.Additional_Metadata__c,
                    Action__r.Iteration__c,
                    Action__r.Is_Update__c
                FROM RuleActions__r
                )
                FROM Rule__c
                WHERE
                    Active__c = true
                    AND Is_Not_Valid__c = false
                    AND Type__c = :ruleType
                ORDER BY Index__c ASC nulls last
                LIMIT :limitRules
            ];
        }
        return rules;
    }

    public class Action {

        public String type;
        public String subtype;
        public ActionType actionType;
        public ActionSubType actionSubType;
        public String content;
        public Id actionId;
        public Action__c fields;
        public Boolean isUpdate;

        public Action(){}

        public Action(Action__c action) {
            this.type = action.Action_Type__c != null ? action.Action_Type__c : action.Type__c;
            this.subtype = action.Subtype__c;
            this.actionType = MAP_ACTIONTYPES_BY_STRINGS.get(this.type);
            this.actionId = action.Id;
            this.actionSubType = MAP_ACTIONSUBTYPES_BY_STRINGS.get(this.subtype);
            this.fields = action;
            this.isUpdate = action?.Is_Update__c == null ? false : action.Is_Update__c;

            switch on this.actionType {
                when JIRA {
                    Map<String, Object> contentMap = new Map<String, Object>();
                    contentMap.put('Assignee', action.JIRAAssignee__c);
                    contentMap.put('Components', action.JIRAComponents__c);
                    contentMap.put('Epic', action.JIRAEpic__c);
                    contentMap.put('IssueType', action.JIRAIssueType__c);
                    contentMap.put('Labels', action.JIRALabels__c);
                    contentMap.put('Priority', action.JIRAPriority__c);
                    contentMap.put('Project', action.JIRAProject__c);
                    this.content = JSON.serialize(contentMap);
                }
                when SLACK {
                    Map<String, Object> contentMap = new Map<String, Object>();
                    contentMap.put('SlackChannel', action.SlackChannels__c);
                    contentMap.put('Subject', action.Subject__c);
                    contentMap.put('Body', action.Body__c);
                    this.content = JSON.serialize(contentMap);
                }
                when EMAIL {
                    Map<String, Object> contentMap = new Map<String, Object>();
                    contentMap.put('TO', action.EmailTo__c);
                    contentMap.put('CC', action.EmailCC__c);
                    contentMap.put('Subject', action.Subject__c);
                    contentMap.put('Message', action.EmailBody__c);
                    this.content = JSON.serialize(contentMap);
                }
                when PAGERDUTY {
                    Map<String, Object> contentMap = new Map<String, Object>();
                    contentMap.put('Type', null);
                    contentMap.put('Date', null);
                    contentMap.put('Service', null);
                    contentMap.put('Assigned', null);
                    this.content = JSON.serialize(contentMap);
                }
                when REMOVAL, EXTERNAL_ARCHIVAL, ARCHIVAL_TO_BIG_OBJECT {
                    this.content = this.type;
                }
            }
        }
    }

    public class Event {

        public Datetime createdDate;
        public Id ruleId;

        public Event(Datetime createdDate, Id ruleId) {
            this.createdDate = createdDate;
            this.ruleId = ruleId;
        }
    }

    public class MonitoringRule {

        public Id ruleId;
        public String ruleType;
        public String ruleSubType;
        public Boolean isUpdateRule;
        public String relatedId;
        public Decimal eventTypeInterval;
        public Decimal aggregateInterval;
        public String aggregateTypeString;
        public MonitoringUtil.AggregateType aggregateType;
        public String comparisonOperator;
        public MonitoringUtil.ComparisonOperator comparisonOperatorType;
        public Decimal threshold;
        @TestVisible
        private Decimal value;
        @TestVisible
        private Map<Integer, Map<String, Decimal>> groupValues;
        @TestVisible 
        private Map<String, Set<String>> groupRecordIds;
        public Set<String> groupFieldNames;
        public List<Id> archivalLogs;
        public String sobjectType;

        public String filterLogic;
        public List<RuleFilter> filters;

        public Integer maxIndex;
        public Set<String> recordIds;
        public String criteria;

        public Id eventId;
        public List<Action> actions;

        public MonitoringRule(){}

        public MonitoringRule(MonitoringRule rule){
            this.maxIndex = rule.maxIndex;
            this.value = 0;
            this.groupValues = new Map<Integer, Map<String, Decimal>>();
            this.groupRecordIds = new Map<String, Set<String>>();
            this.criteria = rule.criteria;
            this.recordIds = new Set<String>();
            this.groupFieldNames = rule.groupFieldNames;
            this.ruleId = rule.ruleId;
            this.ruleType = rule.ruleType;
            this.ruleSubType = rule.ruleSubType;
            this.relatedId = rule.relatedId;
            this.eventTypeInterval = rule.eventTypeInterval;
            this.aggregateInterval = rule.aggregateInterval;
            this.aggregateTypeString = rule.aggregateTypeString;
            this.aggregateType = rule.aggregateType;
            this.comparisonOperator = rule.comparisonOperator;
            this.comparisonOperatorType = rule.comparisonOperatorType;
            this.threshold = rule.threshold;
            this.filterLogic = rule.filterLogic;
            this.filters = rule.filters;
            this.actions = rule.actions;
            this.archivalLogs = rule.archivalLogs;
            this.sobjectType = rule.sobjectType;
            this.isUpdateRule = rule.isUpdateRule == null ? false : rule.isUpdateRule;
        }

        public MonitoringRule(Rule__c rule) {
            this.maxIndex = 0;
            this.value = 0;
            this.groupValues = new Map<Integer, Map<String, Decimal>>();
            this.groupRecordIds = new Map<String, Set<String>>();
            this.criteria = '';
            this.recordIds = new Set<String>();
            this.groupFieldNames = new Set<String>();
            this.ruleId = rule.Id;
            this.ruleType = rule.Type__c;
            this.ruleSubType = rule.Subtype__c;
            this.relatedId = rule.Related_Id__c;
            this.eventTypeInterval = rule.EventTimeInterval__c;
            this.aggregateInterval = rule.AggregateInterval__c;
            this.aggregateTypeString = rule.AggregateType__c;
            this.aggregateType = MAP_AGGREGATETYPES_BY_STRINGS.get(this.aggregateTypeString);
            this.comparisonOperator = rule.ComparisonOperator__c;
            this.comparisonOperatorType = MonitoringUtil.comparisonOperatorMap.get(this.comparisonOperator);
            this.threshold = rule.Threshold__c;
            this.filterLogic = rule.FilterLogic__c;
            this.filters = new List<RuleFilter>();
            this.actions = new List<Action>();
            this.archivalLogs = new List<Id>();
            this.sobjectType = rule.SobjectType__c;
            this.isUpdateRule = rule.Is_Update__c;
        }

        public MonitoringRule addActions(List<RuleAction__c> actions) {
            for(RuleAction__c action : actions) {
                if(action.Action__r != null) {
                    Action wrAction = new Action(action.Action__r);
                    this.actions.add(wrAction);
                }
            }
            return this;
        }

        private String minutesToLabel(String minutes) {
            Integer mns = Integer.valueOf(minutes);
            Integer days = mns / 60 / 24 ;
            Integer hours = (mns - days * 60 * 24) / 60 ;
            Integer mins = mns - days * 60 * 24 - hours * 60 ;
            String label = ((days != 0) ? days + '(Days) ' : '') + ((hours != 0) ? hours + '(Hours) ' : '') + ((mins != 0) ? mins + '(Minutes)' : '');
            return label;
        }

        public MonitoringRule addFilters(List<RuleFilter> rulesFilters) {
            this.maxIndex = 0;
            for(RuleFilter rf : rulesFilters) {
                if(this.ruleType == RULE_TYPE_ARCHIVAL && rf.index == 1) {
                    rf.value = minutesToLabel(rf.value);
                }
                switch on rf.comparisonType {
                    when VALUE {
                        this.filters.add(rf);
                        this.maxIndex = Math.max(this.maxIndex, Integer.valueOf(rf.index));
                    }
                    when FIELD {
                        this.groupFieldNames.add(rf.fieldName);
                    }
                }
            }
            this.filters.sort();
            buildDefaultANDFilter();
            return this;
        }

        public MonitoringRule addFilters(List<RuleFilter__c> rulesFilter) {
            for(RuleFilter__c ruleFilter : rulesFilter) {
                RuleFilter rf = new RuleFilter(ruleFilter, this.sobjectType);
                if(this.ruleType == RULE_TYPE_ARCHIVAL && rf.index == 1) {
                    rf.value = minutesToLabel(rf.value);
                }
                switch on rf.comparisonType {
                    when VALUE {
                        this.filters.add(rf);
                        this.maxIndex = Math.max(this.maxIndex, Integer.valueOf(rf.index));
                    }
                    when FIELD {
                        this.groupFieldNames.add(rf.fieldName);
                    }
                }
            }
            this.filters.sort();
            buildDefaultANDFilter();
            return this;
        }

        public List<RuleFilter> getQueryableFilters() {
            List<RuleFilter> result = new List<RuleFilter>();
            for(RuleFilter rf : this.filters) {
                if(rf.comparisonType == ComparisonType.VALUE && rf.isFilterable) {
                    result.add(rf);
                }
            }
            return result;
        }

        public Integer getIndexesCount() {
            return this.maxIndex;
        }

        public DateTime nextRunTime(DateTime currentTime) {
            if(this.eventTypeInterval == null) return null;
            return currentTime.addMinutes(Integer.valueOf(this.eventTypeInterval));
        }

        public void buildDefaultANDFilter() {
            if(String.isBlank(this.filterLogic)) {
                List<Integer> indexFilter = new List<Integer>();
                Integer indexesCount = getIndexesCount();
                if(this.ruleType == RULE_TYPE_ARCHIVAL) {
                    indexesCount += -1;
                }
                for(Integer i = 1; i <= indexesCount; i++) {
                    indexFilter.add(i);
                }
                this.filterLogic = String.join(indexFilter, ' AND ');
                if(this.ruleType == RULE_TYPE_ARCHIVAL && String.isBlank(this.filterLogic)) {
                    this.filterLogic = '1';
                }
            }
        }

        public void populateCriteria() {
            List<String> filterValues = new String[getIndexesCount()];
            for(RuleFilter filter : this.filters) {
                if(filter.comparisonType == ComparisonType.VALUE) {
                    if(this.ruleType == RULE_TYPE_ARCHIVAL && filter.index == 1) {
                        Integer index = this.filters.size() - 1;
                        filterValues.set(index, filter.getStringFilter());
                    }
                    else {
                        Integer index = Integer.valueOf(filter.index) - (this.ruleType == RULE_TYPE_ARCHIVAL ? 2 : 1);
                        filterValues.set(index, filter.getStringFilter());
                    }
                }
            }
            if(String.isNotBlank(this.filterLogic) && this.ruleType == RULE_TYPE_ARCHIVAL) {
                ConfigUtil.BooleanExpressionParser parser = new ConfigUtil.BooleanExpressionParser(this.filterLogic);
                Set<String> existOperands = parser.getOperands();
                if(!existOperands.contains(String.valueOf(this.filters.size()))) {
                    parser.addOperand(String.valueOf(this.filters.size()));
                    this.filterLogic = parser.toConditionString();
                }
            }
            this.criteria = (String.isNotBlank(this.filterLogic))
                ? FilterEvaluator.substituteValues(this.filterLogic, filterValues)
                : '';

            if(!this.groupFieldNames.isEmpty()) {
                this.criteria += ' GROUP BY ' + String.join(new List<String>(this.groupFieldNames), ',');
            }
        }

        private String getFisrtGroupByKey(Map<String, Object> objectMap) {
            String result = '';
            List<String> groupFieldsLocal = new List<String>{(new List<String>(this.groupFieldNames)).get(0)};
            for(String fieldName : groupFieldsLocal) {
                result += String.valueOf(objectMap.get(fieldName));
            }
            return result;
        }

        private String getGroupKey(Map<String, Object> objectMap) {
            String result = '';
            for(String fieldName : this.groupFieldNames) {
                result += String.valueOf(objectMap.get(fieldName));
            }
            return result;
        }

        private String getGroupByKey(Map<String, Object> objectMap) {
            String result = '';
            List<String> groupFieldsLocal = new List<String>(this.groupFieldNames);
            if(this.groupFieldNames.size() > 1) {
                groupFieldsLocal.remove(0);
            }
            for(String fieldName : groupFieldsLocal) {
                result += String.valueOf(objectMap.get(fieldName));
            }
            return result;
        }

        public Boolean isUpdateRule() {
            return this.isUpdateRule;
        }

        public Set<Id> applyNotificationRules(List<SObject> records) {
            return applyNotificationRules(records, null, null);
        }

        public Set<Id> applyNotificationRules(List<SObject> records, Schema.SObjectField subField) {
            return applyNotificationRules(records, null, null);
        }

        public Set<Id> applyNotificationRules(List<SObject> records, Schema.SObjectField subField, Map<Id, SObject> oldRecords) {
            Set<Id> result = new Set<Id>();
            for(SObject record : records) {
                Id recordId = (Id)record.get('Id');
                Map<String, Object> objectMap = (subField != null)
                    ? record.getSObject(subField).getPopulatedFieldsAsMap()
                    : record.getPopulatedFieldsAsMap();
                Map<String, Object> oldObjectMap = (oldRecords != null && oldRecords.containsKey(recordId) && oldRecords.get(recordId) != null)
                    ? oldRecords.get(recordId).getPopulatedFieldsAsMap()
                    : null;
                List<Boolean> booleanValues = new Boolean[getIndexesCount()];

                for(RuleFilter filter : this.filters) {
                    if(filter.comparisonType == ComparisonType.VALUE) {
                        Boolean booleanValue = false;
                        if(filter.comparisonOperatorType == MonitoringUtil.ComparisonOperator.IS_CHANGED) {
                            Object oldValue = oldRecords?.get(recordId)?.get(filter.fieldName);
                            Object newValue = record?.get(filter.fieldName);
                            booleanValue = oldValue != newValue;
                        }
                        else {
                            booleanValue = filter.evaluateFilter((oldObjectMap != null && filter.isOld) ? oldObjectMap : objectMap);
                        }
                        Integer index = Integer.valueOf(filter.index) - 1;
                        booleanValues.set(index, booleanValue);
                    }
                }
                Boolean rulesResult = (String.isNotBlank(this.filterLogic))
                    ? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
                    : true;

                if(rulesResult) {
                    result.add(String.valueOf(record.get('Id')));
                }
            }
            return result;
        }

        public Set<MonitoringUtil.ActionType> getRuleActionTypes() {
            Set<MonitoringUtil.ActionType> result = new Set<MonitoringUtil.ActionType>();
            for(Action action : this.actions) {
                result.add(action.actionType);
            }
            return result;
        }

        public void applyArchivalRules(List<Log__c> logs) {

            for(Log__c log : logs) {
                Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
                List<Boolean> booleanValues = new Boolean[getIndexesCount()];

                for(RuleFilter filter : this.filters) {
                    if(filter.comparisonType == ComparisonType.VALUE) {
                        Integer index = Integer.valueOf(filter.index) - 1;
                        if(filter.isFilterable || filter.index == 1) {
                            booleanValues.set(index, true);
                        }
                        else {
                            Boolean booleanValue = filter.evaluateFilter(objectMap);
                            booleanValues.set(index, booleanValue);
                        }
                    }
                }

                Boolean rulesResult = (String.isNotBlank(this.filterLogic))
                    ? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
                    : true;

                if(rulesResult) {
                    this.archivalLogs.add(log.Id);
                }
            }
        }

        public List<Log__c> applyBroadcastRuleFilters(List<Log__c> logs) {
            List<Log__c> result = new List<Log__c>();

            for(Log__c log : logs) {
                Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
                List<Boolean> booleanValues = new Boolean[getIndexesCount()];

                for(RuleFilter filter : this.filters) {
                    if(filter.comparisonType == ComparisonType.VALUE) {
                        Boolean booleanValue = filter.evaluateFilter(objectMap);
                        Integer index = Integer.valueOf(filter.index) - 1;
                        booleanValues.set(index, booleanValue);
                    }
                }

                Boolean rulesResult = (String.isNotBlank(this.filterLogic))
                        ? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
                        : true;

                if(rulesResult) {
                    result.add(log);
                }
            }
            return result;
        }

        public List<Log__c> applyRuleFilters(List<Log__c> logs) {
            List<Log__c> result = new List<Log__c>();

            for(Log__c log : logs) {
                Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
                List<Boolean> booleanValues = new Boolean[getIndexesCount()];

                for(RuleFilter filter : this.filters) {
                    if(filter.comparisonType == ComparisonType.VALUE) {
                        Boolean booleanValue = (filter.isFilterable) ? true : filter.evaluateFilter(objectMap);
                        Integer index = Integer.valueOf(filter.index) - 1;
                        booleanValues.set(index, booleanValue);
                    }
                }

                Boolean rulesResult = (String.isNotBlank(this.filterLogic))
                    ? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
                    : true;

                if(rulesResult) {
                    result.add(log);
                }
            }
            return result;
        }

        public void applyFilters(
                List<Log__c> logs,
                Integer currentInterval,
                Integer countIntervals,
                DateTime runDateTime,
                Map<Id, MonitoringUtil.Event> eventsMap) {

            applyFilters(logs, currentInterval, countIntervals, runDateTime, eventsMap, true);
        }

        public void applyFilters(
            List<Log__c> logs,
            Integer currentInterval,
            Integer countIntervals,
            DateTime runDateTime,
            Map<Id, MonitoringUtil.Event> eventsMap,
            Boolean checkLogsInterval) {

            Decimal intervalValue = 0;
            Map<Integer, Map<String, Decimal>> intervalValues = new Map<Integer, Map<String, Decimal>>();
            Map<Integer, Map<String, Set<String>>> impactIntervalValues = new Map<Integer, Map<String, Set<String>>>();

            MonitoringUtil.Event lastEvent = eventsMap.get(this.ruleId);
            DateTime lastProcessDatetime = lastEvent != null ? lastEvent.createdDate : null;

            for(Log__c log : logs) {
                Map<String, Object> objectMap = log.getPopulatedFieldsAsMap();
                if(checkLogsInterval && !inCurrentInterval(log.Created_At__c, runDateTime, lastProcessDatetime, this.eventTypeInterval)) {
                    continue;
                }

                List<Boolean> booleanValues = new Boolean[getIndexesCount()];
                for(RuleFilter filter : this.filters) {
                    if(filter.comparisonType == ComparisonType.VALUE) {
                        Boolean booleanValue = filter.evaluateFilter(objectMap);
                        Integer index = Integer.valueOf(filter.index) - 1;
                        booleanValues.set(index, booleanValue);
                    }
                }

                Boolean rulesResult = (String.isNotBlank(this.filterLogic))
                    ? FilterEvaluator.evaluate(this.filterLogic, booleanValues)
                    : true;

                if(rulesResult) {
                    if(!this.groupFieldNames.isEmpty() || this.aggregateInterval != null || this.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                        if(this.ruleSubType == RULE_SUB_TYPE_IMPACT) {
                            String groupKey = getGroupByKey(objectMap);
                            String countKey = getFisrtGroupByKey(objectMap);
                            if(String.isNotBlank(countKey) && countKey != 'null') {
                                Map<String, Set<String>> currentIntervalImpactIntervalValues = impactIntervalValues.get(currentInterval) != null
                                    ? impactIntervalValues.get(currentInterval)
                                    : new Map<String, Set<String>>();

                                Set<String> unicCountKeys = currentIntervalImpactIntervalValues.get(groupKey) != null
                                    ? currentIntervalImpactIntervalValues.get(groupKey)
                                    : new Set<String>();
                                unicCountKeys.add(countKey);
                                currentIntervalImpactIntervalValues.put(groupKey, unicCountKeys);
                                impactIntervalValues.put(currentInterval, currentIntervalImpactIntervalValues);

                                Set<String> intervalRecordIds = (this.groupRecordIds.get(groupKey) != null)
                                    ? this.groupRecordIds.get(groupKey)
                                    : new Set<String>();
                                intervalRecordIds.add(log.Id);
                                this.groupRecordIds.put(groupKey, intervalRecordIds);
                            }
                        }
                        else {
                            String key = getGroupKey(objectMap);
                            Map<String, Decimal> currentIntervalIntervalValues = intervalValues.get(currentInterval) != null
                                ? intervalValues.get(currentInterval)
                                : new Map<String, Decimal>();
                            Decimal groupIntervalValue = (currentIntervalIntervalValues.get(key) != null) ? currentIntervalIntervalValues.get(key) : 0;
                            groupIntervalValue += 1;
                            currentIntervalIntervalValues.put(key, groupIntervalValue);
                            intervalValues.put(currentInterval, currentIntervalIntervalValues);

                            Set<String> intervalRecordIds = (this.groupRecordIds.get(key) != null)
                                ? this.groupRecordIds.get(key)
                                : new Set<String>();
                            intervalRecordIds.add(log.Id);
                            this.groupRecordIds.put(key, intervalRecordIds);
                        }
                    }
                    else {
                        intervalValue += 1;
                        this.recordIds.add(log.Id);
                    }
                }
            }
            if(logs.isEmpty()) {
                if(!this.groupFieldNames.isEmpty() || this.aggregateInterval != null || this.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                    this.groupValues.put(currentInterval, new Map<String, Decimal>{'' => 0});
                    this.groupRecordIds.put('', new Set<String>());
                }
            }
            switch on this.aggregateType {
                when COUNT {
                    if(!this.groupFieldNames.isEmpty() || this.aggregateInterval != null || this.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                        if(this.ruleSubType == RULE_SUB_TYPE_IMPACT) {
                            for(Integer interval : impactIntervalValues.keySet()) {
                                for(String countKey : impactIntervalValues.get(interval).keySet()) {
                                    Integer unicKeySize = impactIntervalValues.get(interval).get(countKey).size();
                                    Map<String, Decimal> intervalGroupValues = this.groupValues.get(interval) != null
                                        ? this.groupValues.get(interval)
                                        : new Map<String, Decimal>();
                                    intervalGroupValues.put(countKey, unicKeySize);
                                    this.groupValues.put(interval, intervalGroupValues);
                                }
                            }
                        }
                        else {
                            for(Integer interval : intervalValues.keySet()) {
                                Map<String, Decimal> intervalGroupValues = this.groupValues.get(interval) != null
                                    ? this.groupValues.get(interval)
                                    : new Map<String, Decimal>();
                                Map<String, Decimal> currentIntervalValues = intervalValues.get(interval);
                                intervalGroupValues.putAll(currentIntervalValues);
                                this.groupValues.put(interval, intervalGroupValues);
                            }
                        }
                    }
                    else {
                        this.value += Integer.valueOf(intervalValue);
                    }
                }
                when AVERAGE {
                    if(!this.groupFieldNames.isEmpty() || this.aggregateInterval != null || this.ruleSubType == RULE_SUB_TYPE_FREQUENCY) {
                        if(this.ruleSubType == RULE_SUB_TYPE_IMPACT) {
                            for(Integer interval : impactIntervalValues.keySet()) {
                                for(String countKey : impactIntervalValues.get(interval).keySet()) {
                                    Integer unicKeySize1 = impactIntervalValues.get(interval).get(countKey).size();

                                    Decimal unicKeySize2 = (this.groupValues.get(interval) != null
                                        && this.groupValues.get(interval).get(countKey) != null)
                                            ? this.groupValues.get(interval).get(countKey)
                                            : 0;
                                    Decimal resultValue = unicKeySize1 + unicKeySize2;
                                    Map<String, Decimal> intervalGroupValues = this.groupValues.get(interval) != null
                                        ? this.groupValues.get(interval)
                                        : new Map<String, Decimal>();
                                    intervalGroupValues.put(countKey, resultValue);
                                    this.groupValues.put(interval, intervalGroupValues);
                                }
                            }
                        }
                        else {
                            for(Integer interval : intervalValues.keySet()) {
                                for(String key : intervalValues.get(interval).keySet()) {
                                    Decimal keyValue1 = intervalValues.get(interval).get(key);
                                    Decimal keyValue2 = (this.groupValues.get(interval) != null
                                        && this.groupValues.get(interval).get(key) != null)
                                            ? this.groupValues.get(interval).get(key)
                                            : 0;
                                    Decimal resultValue = keyValue1 + keyValue2;
                                    Map<String, Decimal> intervalGroupValues = this.groupValues.get(interval) != null
                                            ? this.groupValues.get(interval)
                                            : new Map<String, Decimal>();
                                    intervalGroupValues.put(key, resultValue);
                                    this.groupValues.put(interval, intervalGroupValues);
                                }
                            }
                        }
                        if(currentInterval == countIntervals) {
                            for(Integer interval : this.groupValues.keySet()) {
                                for(String key : this.groupValues.get(interval).keySet()) {
                                    Decimal keyValue = this.groupValues.get(interval).get(key);
                                    keyValue = keyValue / countIntervals;
                                    this.groupValues.get(interval).put(key, keyValue);
                                }
                            }
                        }
                    }
                    else {
                        this.value += intervalValue;
                        if(currentInterval == countIntervals) {
                            this.value = this.value / countIntervals;
                        }
                    }
                }
            }
        }
    }

    public static Map<MonitoringUtil.ComparisonOperator, QCondition.ComparisonOperator> filterToConditionMap = new Map<MonitoringUtil.ComparisonOperator, QCondition.ComparisonOperator>{
        MonitoringUtil.ComparisonOperator.EQUAL => QCondition.ComparisonOperator.EQUALS,
        MonitoringUtil.ComparisonOperator.NOT_EQUAL => QCondition.ComparisonOperator.NOT_EQUALS,
        MonitoringUtil.ComparisonOperator.GREATER_THAN => QCondition.ComparisonOperator.GREATER_THAN,
        MonitoringUtil.ComparisonOperator.GREATER_OR_EQUAL => QCondition.ComparisonOperator.GREATER_OR_EQUAL,
        MonitoringUtil.ComparisonOperator.LESS_THAN => QCondition.ComparisonOperator.LESS_THAN,
        MonitoringUtil.ComparisonOperator.LESS_OR_EQUAL => QCondition.ComparisonOperator.LESS_OR_EQUAL
    };


    public class RuleFilter implements Comparable{

        public Decimal index;
        public String comparisonOperator;
        public MonitoringUtil.ComparisonType comparisonType;
        public MonitoringUtil.ComparisonOperator comparisonOperatorType;
        public String fieldName;
        public String value;
        public MonitoringUtil.FieldType fieldType;
        public Boolean isFilterable;
        public Boolean isOld;

        public RuleFilter(){}
        public RuleFilter(Decimal index, String comparisonType, String comparisonOperator, String fieldName, String value, String sobjectType, Boolean isOld) {
            this(index, MAP_COMPARISONTYPES_BY_STRINGS.get(comparisonType), comparisonOperator, fieldName, value, sobjectType, isOld);
        }
        public RuleFilter(Decimal index, MonitoringUtil.ComparisonType comparisonType, String comparisonOperator, String fieldName, String value, String sobjectType, Boolean isOld) {
            this.index = index;
            this.comparisonType = comparisonType;
            this.comparisonOperator = comparisonOperator;
            this.comparisonOperatorType = MonitoringUtil.comparisonOperatorMap.get(this.comparisonOperator);
            this.fieldName = fieldName;
            this.value = value;
            this.isOld = isOld;

            Boolean isLogField = sobjectType == null
                && String.isNotBlank(this.fieldName)
                && ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase()) != null;
            Boolean isIssueField = (sobjectType == Constants.ISSUE_SOBJECT.SOBJECT_TYPE_NAME || sobjectType == Constants.TRACE_RESULT_SOBJECT.SOBJECT_TYPE_NAME)
                && String.isNotBlank(this.fieldName)
                && ConfigUtil.MAP_ISSUE_FIELDS.get(this.fieldName.toLowerCase()) != null;
            Boolean isTraceResultField = sobjectType == Constants.TRACE_RESULT_SOBJECT.SOBJECT_TYPE_NAME
                && String.isNotBlank(this.fieldName)
                && ConfigUtil.MAP_TRACE_RESULT_FIELDS.get(this.fieldName.toLowerCase()) != null;

            String dt;
            Schema.DescribeFieldResult fieldDR;
            if(isLogField) {
                dt = String.valueOf(ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase()).getType());
                fieldDR = ConfigUtil.MAP_LOG_FIELDS.get(this.fieldName.toLowerCase());
            }
            else if (isIssueField) {
                dt = String.valueOf(ConfigUtil.MAP_ISSUE_FIELDS.get(this.fieldName.toLowerCase()).getType());
                fieldDR = ConfigUtil.MAP_ISSUE_FIELDS.get(this.fieldName.toLowerCase());
            }
            else if (isTraceResultField) {
                dt = String.valueOf(ConfigUtil.MAP_TRACE_RESULT_FIELDS.get(this.fieldName.toLowerCase()).getType());
                fieldDR = ConfigUtil.MAP_TRACE_RESULT_FIELDS.get(this.fieldName.toLowerCase());
            }
            this.fieldType = MAP_FIELDTYPES_BY_STRINGS.get(dt);

            this.isFilterable = fieldDR != null && fieldDR.isFilterable()
                && this.comparisonOperatorType != MonitoringUtil.ComparisonOperator.CONTAINS
                && this.comparisonOperatorType != MonitoringUtil.ComparisonOperator.DOESNT_CONTAIN;
        }

        public RuleFilter(RuleFilter__c ruleFilter) {
            this(ruleFilter, null);
        }

        public RuleFilter(RuleFilter__c ruleFilter, String sobjectType) {
            this(ruleFilter.Index__c, ruleFilter.Comparison_Type__c, ruleFilter.ComparisonOperator__c, ruleFilter.FieldName__c, ruleFilter.Value__c, sobjectType, ruleFilter.Is_Old__c);
        }

        public QCondition toQCondition() {
            QCondition.ComparisonOperator comparisonOperator = filterToConditionMap.get(this.comparisonOperatorType);
            return toQCondition(comparisonOperator);
        }

        public QCondition toQCondition(QCondition.ComparisonOperator comparisonOperator) {
            QCondition condition = new QCondition(this.fieldName);
            Object fieldValue = this.value;
            switch on this.fieldType {
                when FT_DOUBLE, FT_NUMBER {
                    fieldValue = Decimal.valueOf(this.value);
                }
                when FT_DATE {
                    fieldValue = Date.valueOf(this.value);
                }
                when FT_DATETIME {
                    fieldValue = Datetime.valueOf(this.value);
                }
                when FT_BOOLEAN {
                    fieldValue = Boolean.valueOf(this.value);
                }
            }
            comparisonOperator = comparisonOperator == null ? QCondition.ComparisonOperator.NOP : comparisonOperator;
            condition.setOperatorValue(
                comparisonOperator,
                fieldValue
            );
            return condition;
        }

        private String getStringValue(Object obj) {
            String reString = '';
            if(obj != null) {
                reString = obj.toString();
            }
            return reString;
        }

        private Decimal getDecimalValue(Object obj) {
            Decimal result = null;
            if(obj != null) {
                result = Decimal.valueOf(String.valueOf(obj));
            }
            return result;
        }

        private Date getDateValue(Object obj) {
            Date result = null;
            if(obj != null) {
                result = (Date)obj;
            }
            return result;
        }

        private Date getDateValue(String obj) {
            Date result = null;
            if(obj != null) {
                result = Date.valueOf(obj);
            }
            return result;
        }

        private DateTime getDateTimeValue(Object obj) {
            DateTime result = null;
            if(obj != null) {
                result = (DateTime)obj;
            }
            return result;
        }

        private DateTime getDateTimeValue(String obj) {
            DateTime result = null;
            if(obj != null) {
                try {
                    result = Datetime.valueOfGMT(obj);
                }
                catch(Exception e) {}
                finally {
                    if(result == null) {
                        try {
                            result = (DateTime)JSON.deserialize(obj, DateTime.class);
                        }
                        catch(Exception e) {}
                    }
                }
            }
            return result;
        }

        public String getStringFilter() {
            String result = '';

            String valLeft = this.fieldName;
            String valRight = this.value;
            String operator = '';

            switch on this.comparisonOperatorType {
                when EQUAL {
                    result = valLeft + ' = ' + valRight;
                }
                when NOT_EQUAL {
                    result = valLeft + ' != ' + valRight;
                }
                when GREATER_THAN {
                    result = valLeft + ' > ' + valRight;
                }
                when GREATER_OR_EQUAL {
                    result = valLeft + ' >= ' + valRight;
                }
                when LESS_THAN {
                    result = valLeft + ' < ' + valRight;
                }
                when LESS_OR_EQUAL {
                    result = valLeft + ' <= ' + valRight;
                }
                when CONTAINS {
                    result = valLeft + ' CONTAINS(' + valRight + ')';
                }
                when DOESNT_CONTAIN {
                    result = valLeft + ' NOT CONTAINS(' + valRight + ')';
                }
                when else {
                    // undefined comparison operator
                }
            }
            return result;
        }

        public Boolean evaluateFilter(Map<String, Object> objectMap) {
            Boolean result = false;

            Object valLeft = objectMap.get(this.fieldName);
            Object valRight = this.value;
            ComparisonOperator operatorOldOrNew = this.comparisonOperatorType;

            switch on this.fieldType {
                when FT_BOOLEAN {
                    switch on operatorOldOrNew {
                        when EQUAL {
                            result = getStringValue(valLeft) == valRight;
                        }
                        when NOT_EQUAL {
                            result = getStringValue(valLeft) != valRight;
                        }
                        when else {
                            // undefined comparison operator
                        }
                    }
                }
                when FT_ID, FT_PICKLIST, FT_REFERENCE, FT_STRING, FT_TEXTAREA, FT_URL {
                    switch on operatorOldOrNew {
                        when EQUAL {
                            result = getStringValue(valLeft) == valRight;
                        }
                        when NOT_EQUAL {
                            result = getStringValue(valLeft) != valRight;
                        }
                        when CONTAINS {
                            result = getStringValue(valLeft).containsIgnoreCase(getStringValue(valRight));
                        }
                        when DOESNT_CONTAIN {
                            result = !getStringValue(valLeft).containsIgnoreCase(getStringValue(valRight));
                        }
                        when else {
                            // undefined comparison operator
                        }
                    }
                }
                when FT_NUMBER, FT_DOUBLE {
                    switch on operatorOldOrNew {
                        when EQUAL {
                            result = getDecimalValue(valLeft) == getDecimalValue(valRight);
                        }
                        when NOT_EQUAL {
                            result = getDecimalValue(valLeft) != getDecimalValue(valRight);
                        }
                        when GREATER_THAN {
                            result = getDecimalValue(valLeft) > getDecimalValue(valRight);
                        }
                        when GREATER_OR_EQUAL {
                            result = getDecimalValue(valLeft) >= getDecimalValue(valRight);
                        }
                        when LESS_THAN {
                            result = getDecimalValue(valLeft) < getDecimalValue(valRight);
                        }
                        when LESS_OR_EQUAL {
                            result = getDecimalValue(valLeft) <= getDecimalValue(valRight);
                        }
                        when CONTAINS {
                            result = getStringValue(valLeft).containsIgnoreCase(getStringValue(valRight));
                        }
                        when DOESNT_CONTAIN {
                            result = !getStringValue(valLeft).containsIgnoreCase(getStringValue(valRight));
                        }
                        when else {
                            // undefined comparison operator
                        }
                    }
                }
                when FT_DATE {
                    switch on operatorOldOrNew {
                        when EQUAL {
                            result = getDateValue(valLeft) == getDateValue(String.valueOf(valRight));
                        }
                        when NOT_EQUAL {
                            result = getDateValue(valLeft) != getDateValue(String.valueOf(valRight));
                        }
                        when GREATER_THAN {
                            result = getDateValue(valLeft) > getDateValue(String.valueOf(valRight));
                        }
                        when GREATER_OR_EQUAL {
                            result = getDateValue(valLeft) >= getDateValue(String.valueOf(valRight));
                        }
                        when LESS_THAN {
                            result = getDateValue(valLeft) < getDateValue(String.valueOf(valRight));
                        }
                        when LESS_OR_EQUAL {
                            result = getDateValue(valLeft) <= getDateValue(String.valueOf(valRight));
                        }
                        when else {
                            // undefined comparison operator
                        }
                    }
                }
                when FT_DATETIME {
                    switch on operatorOldOrNew {
                        when EQUAL {
                            result = getDateTimeValue(valLeft) == getDateTimeValue(String.valueOf(valRight));
                        }
                        when NOT_EQUAL {
                            result = getDateTimeValue(valLeft) != getDateTimeValue(String.valueOf(valRight));
                        }
                        when GREATER_THAN {
                            result = getDateTimeValue(valLeft) > getDateTimeValue(String.valueOf(valRight));
                        }
                        when GREATER_OR_EQUAL {
                            result = getDateTimeValue(valLeft) >= getDateTimeValue(String.valueOf(valRight));
                        }
                        when LESS_THAN {
                            result = getDateTimeValue(valLeft) < getDateTimeValue(String.valueOf(valRight));
                        }
                        when LESS_OR_EQUAL {
                            result = getDateTimeValue(valLeft) <= getDateTimeValue(String.valueOf(valRight));
                        }
                        when else {
                            // undefined comparison operator
                        }
                    }
                }
            }

            return result;
        }

        public Integer compareTo(Object compareTo) {
            RuleFilter that = (RuleFilter)compareTo;
            if (this.index == that.index) return 0;
            if (this.index == null) return 1;
            if (that.index == null) return -1;
            return (this.index > that.index) ? 1 : -1;
        }
    }

    public class ChartData {
        public Map<Long, ChartDataInterval> mapIntervals;
        public List<Map<String, Object>> logs;
        public Integer countLogs;
        public ChartData() {
            this.mapIntervals = new Map<Long, ChartDataInterval>();
            this.logs = new List<Map<String, Object>>();
            this.countLogs = 0;
        }
    }

    public class ChartDataInterval {
        public Decimal value;
        public Map<Integer, Map<String, Decimal>> logValues;

        public ChartDataInterval() {
            this.logValues = new Map<Integer, Map<String, Decimal>>();
            this.value = 0;
        }
    }

    public static  List<Log__c> getLogs(List<MonitoringUtil.MonitoringRule> rules, DateTime startTime, DateTime endTime, Integer limitLogs) {
        List<String> logFields = getLogFieldNames(rules);
        logFields.add('Created_At__c');
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>(logFields))
                .add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':startTime'))
                .add(QBuilder.condition('Created_At__c').isLessOrEquals(':endTime'))
                .addLimit(limitLogs)
                .build();
        List<Log__c> logs = Database.query(query);
        return logs;
    }

    public static ChartData getChartData(Id ruleId, Id eventId, DateTime startTime, DateTime endTime, Boolean stdInterval) {
        List<MonitoringUtil.MonitoringRule> rules = MonitoringUtil.getMonitoringRules(new List<Id>{ruleId});
        if(rules.get(0).ruleSubType == RULE_SUB_TYPE_SPIKE) {
            ChartData result = new ChartData();
            List<String> logFields = getLogFieldNames(rules);
            logFields.add('Created_At__c');
            logFields.add('Hash_1__c');
            logFields.add('Summary__c');
            String eventLogsQuery = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>(logFields))
                .add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':startTime'))
                .add(QBuilder.condition('Created_At__c').isLessOrEquals(':endTime'))
                .add(QBuilder.orderBy('Created_At__c').ascending())
                .addLimit(EVENT_CHART_MAX_RECORDS)
                .build();
            ChartData resultData = new ChartData();
            for(Log__c log : rules.get(0).applyRuleFilters(Database.query(eventLogsQuery))) {
                resultData.logs.add(new Map<String, Object> {'CreatedDate' => log.Created_At__c});
            }

            resultData.countLogs = resultData.logs.size();
            return resultData;
        }
        else {
            return getImpactChartData(ruleId, eventId, startTime, endTime, stdInterval);
        }
    }

    public static ChartData getImpactChartData(Id ruleId, Id eventId, DateTime startTime, DateTime endTime, Boolean stdInterval) {
        ChartData result = new ChartData();

        List<MonitoringUtil.MonitoringRule> rules = MonitoringUtil.getMonitoringRules(new List<Id>{ruleId});
        Rule__c rule = [SELECT Id, EventTimeInterval__c FROM Rule__c WHERE Id = :ruleId];
        Event__c event = [SELECT Id, CreatedDate, Records__c FROM Event__c WHERE Id = :eventId];
        Set<String> eventRecordIds = parseIds(event.Records__c);
        Integer eventInterval = Integer.valueOf(rule.EventTimeInterval__c);
        DateTime eventEndDate = event.CreatedDate;
        DateTime eventStartDate = eventEndDate.addMinutes(-eventInterval);

        List<Log__c> logsBeforeEvent = getLogs(rules, startTime, eventStartDate, EVENT_CHART_MAX_RECORDS/2);
        List<Log__c> logsAfterEvent = getLogs(rules, eventEndDate, endTime, EVENT_CHART_MAX_RECORDS/2);
        Map<Long, List<Log__c>> logsBefore = (stdInterval) ? splitLogsBySeconds(logsBeforeEvent) : splitLogsByInterval(eventInterval, logsBeforeEvent);
        Map<Long, List<Log__c>> logsAfter = (stdInterval) ? splitLogsBySeconds(logsAfterEvent) : splitLogsByInterval(eventInterval, logsAfterEvent);

        List<String> logFields = getLogFieldNames(rules);
        logFields.add('Created_At__c');
        String eventLogsQuery = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>(logFields))
            .add(QBuilder.condition('Id').isIn(':eventRecordIds'))
            .addLimit(EVENT_CHART_MAX_RECORDS)
            .build();
        List<Log__c> eventLogs = Database.query(eventLogsQuery);
        Map<Long, List<Log__c>> logsEvent = new Map<Long, List<Log__c>>{eventEndDate.getTime() => eventLogs};

        addIntervalsToChart(rules, result, logsBefore);
        addIntervalsToChart(rules, result, logsEvent);
        addIntervalsToChart(rules, result, logsAfter);
        result.countLogs = logsBeforeEvent.size() + logsAfterEvent.size() + eventLogs.size();

        return result;
    }

    public static void addIntervalsToChart(List<MonitoringRule> rules, ChartData result, Map<Long, List<Log__c>> logsByInterval) {
        for(Long datetimeLong : logsByInterval.keySet()) {
            MonitoringUtil.MonitoringRule cloneRule = rules.get(0).clone();

            List<Log__c> logsInterval = logsByInterval.get(datetimeLong);
            cloneRule.value = 0;
            cloneRule.groupValues = new Map<Integer, Map<String, Decimal>>();
            applyRulesFilters(new List<MonitoringUtil.MonitoringRule>{cloneRule}, logsInterval, DateTime.now(), new Map<Id, MonitoringUtil.Event>(), false);

            ChartDataInterval interval = new ChartDataInterval();
            interval.logValues = cloneRule.groupValues;
            interval.value = cloneRule.value;
            if(!interval.logValues.isEmpty()) {
                interval.value = 0;
                for(Map<String, Decimal> intervalCounts : interval.logValues.values()) {
                    for(Decimal listCounts : intervalCounts.values()) {
                        interval.value += listCounts;
                    }
                }
            }
            result.mapIntervals.put(datetimeLong, interval);
        }
    }

    public static Map<Long, List<Log__c>> splitLogsByInterval(Integer intervalInMinutes, List<Log__c> logs) {

        Map<Long, List<Log__c>> result = new Map<Long, List<Log__c>>();
        for(Log__c log : logs) {

            Integer hours = intervalInMinutes / 60;
            Integer minutes = Math.mod(intervalInMinutes, 60);

            Datetime roundedDateTimeByInterval = log.Created_At__c.addMinutes(
                log.Created_At__c.minute() > 30
                    ? - (log.Created_At__c.minute() - minutes)
                    : - log.Created_At__c.minute()
            );
            if(hours != 0) {
                Integer nearHour = ((roundedDateTimeByInterval.hour() / hours) * hours);
                roundedDateTimeByInterval = roundedDateTimeByInterval.addHours( -(roundedDateTimeByInterval.hour() - nearHour));
            }

            Long roundedMills = roundedDateTimeByInterval.getTime();
            roundedMills = roundedMills/100000*100000;
            List<Log__c> logsByMills = result.get(roundedMills) != null
                    ? result.get(roundedMills)
                    : new List<Log__c>();

            logsByMills.add(log);
            result.put(roundedMills, logsByMills);
        }
        return result;
    }

    public static Map<Long, List<Log__c>> splitLogsBySeconds(List<Log__c> logs) {

        Map<Long, List<Log__c>> result = new Map<Long, List<Log__c>>();
        for(Log__c log : logs) {

            Long roundedMills = log.Created_At__c.getTime();
            List<Log__c> logsByMills = result.get(roundedMills) != null
                    ? result.get(roundedMills)
                    : new List<Log__c>();

            logsByMills.add(log);
            result.put(roundedMills, logsByMills);
        }
        return result;
    }

    public static Set<String> parseIds(String input) {
        Set<String> result = new Set<String>();

        if(input.startsWith('{')) {
            Map<String, List<String>> idsMap = (Map<String, List<String>>)System.JSON.deserialize(input, Map<String, List<String>>.class);
            for(List<String> ids : idsMap.values()) {
                result.addAll(ids);
            }
        }
        else {
            List<String> ids = (List<String>)System.JSON.deserialize(input, List<String>.class);
            result.addAll(ids);
        }
        return result;
    }
}