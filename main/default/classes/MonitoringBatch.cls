public with sharing class MonitoringBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable, Database.RaisesPlatformEvents {

    private Datetime startTime;
    private Map<Id, MonitoringUtil.Event> eventsMap;
    private List<Id> ruleIds;

    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }

    private static MonitoringBatch instance = null;

    public static MonitoringBatch getInstance() {
        if (instance == null) {
            instance = new MonitoringBatch(Logger.getInstance());
        }
        return instance;
    }

    private MonitoringBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('MonitoringBatch', this);
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MonitoringEnabled && ConfigUtil.SETTINGS.Monitoring_Enabled__c && hasNewLogs() && needRunMonitoringRules();
    }

    public override Integer getIterationsCount() {
        return [SELECT COUNT() FROM Rule__c WHERE Type__c = :MonitoringUtil.RULE_TYPE_MONITORING AND Active__c = TRUE LIMIT :PermissionsUtil.MaxMonitoringRules];
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        startTime = System.now();
        updateLastProcessedLogFlag(startTime);
        return Database.getQueryLocator([
                SELECT Id, Type__c
                FROM Rule__c
                WHERE Type__c = :MonitoringUtil.RULE_TYPE_MONITORING
                AND Active__c = TRUE
                ORDER BY Index__c
                LIMIT :PermissionsUtil.MaxMonitoringRules
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Rule__c> scope) {
        // clear cached rules for Test context
        MonitoringUtil.cachedRules = new Map<String, Map<Id, MonitoringUtil.MonitoringRule>>();
        
        List<MonitoringUtil.MonitoringRule> rules = MonitoringUtil.getMonitoringRules(new List<Id>{scope.get(0).Id});
        Map<Id, MonitoringUtil.Event> eventsMap = MonitoringUtil.getLastCreatedEventsMap();
        Datetime currentTime = Datetime.now();
        Datetime lastProcessedDatetime = null;
        this.eventsMap = eventsMap;
        this.ruleIds = new List<Id>();
        for (MonitoringUtil.MonitoringRule rule : rules) {
            MonitoringUtil.Event event = eventsMap.get(rule.ruleId);
            ruleIds.add(rule.ruleId);
            if (event == null) {
                lastProcessedDatetime = currentTime.addMinutes(-Integer.valueOf(rule.eventTypeInterval));
            } else if(event.createdDate != null && (rule.nextRunTime(event.createdDate) <= currentTime)) {
                lastProcessedDatetime = event.createdDate;
            }
        }
        if (lastProcessedDatetime != null) {
            QBuilder qbCount = getMonitoringLogsQuery(rules.get(0), new Set<String>{'COUNT()'});
            String qbCountQuery = qbCount.build();
            Integer countLogs = Database.countQuery(qbCountQuery);
            Integer limitRows = (countLogs > 45000) ? 45000 : null;
            List<String> logFields = MonitoringUtil.getLogFieldNames(rules);
            QBuilder qb = getMonitoringLogsQuery(rules.get(0), new Set<String>(logFields));
            if (limitRows != null) {
                qb.addLimit(limitRows);
            }
            String qbQuery = qb.build();
            List<Log__c> logs = Database.query(qbQuery);
            MonitoringUtil.evaluateRules(logs, this.ruleIds, this.startTime, eventsMap, loggerInstance);
        }
    }

    public void finish(Database.BatchableContext BC) {
        loggerInstance?.flush();
        if (hasNewLogs() && needRunMonitoringRules()) {
            MonitoringBatch.getInstance().startBatch();
        } else {
            MonitoringUtil.checkStartActionsBatch(false);
        }
    }

    public static QBuilder getMonitoringLogsQuery(MonitoringUtil.MonitoringRule rule, Set<String> logFields) {
        ConfigUtil.BooleanExpressionParser parser = new ConfigUtil.BooleanExpressionParser(rule.filterLogic);
        
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>(logFields));
        for(MonitoringUtil.RuleFilter rf : rule.filters) {
            if(rf.comparisonType == MonitoringUtil.ComparisonType.VALUE && rf.isFilterable) {
                qb.add(rf.toQCondition());
            }
            else {
                parser.removeOperand(String.valueOf(rf.index));
                qb.add(rf.toQCondition(null));
            }
        }
        qb.add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':lastProcessedDatetime'));
        parser.addOperand();
        
		if(!PermissionsUtil.NotificationForPharosErrors) {
			qb.add(QBuilder.condition('Category__c').notEqualsTo(Logger.CATEGORY_PHAROS_ERROR));
            qb.add(QBuilder.condition('Area__c').notEqualsTo(Logger.AREA_PHAROS_ERROR));
            parser.addOperand();
            parser.addOperand();
		}
        qb.setConditionOrder(parser.toConditionString());
        return qb;
    }

    public void updateLastProcessedLogFlag(Datetime lastProcessedLogDateTime) {
        Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
        if (Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Log__c.isCreateable()
                && Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Log__c.isUpdateable()) {
            flag.Last_Processed_Log__c = lastProcessedLogDateTime;
        }
        if (Schema.SObjectType.Monitoring_Batch_Flag__c.isAccessible()
                && Schema.SObjectType.Monitoring_Batch_Flag__c.isCreateable()
                && Schema.SObjectType.Monitoring_Batch_Flag__c.isUpdateable()) {
            DatabaseUtils.getInstance().performUpsertDML(new List<Monitoring_Batch_Flag__c>{flag}, Schema.SObjectType.Monitoring_Batch_Flag__c)
                    .handleError(MonitoringBatch.class.getName(), '.updateLastProcessedLogFlag', loggerInstance);
        }
    }

    public static Boolean hasNewLogs() {
        Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
        if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c == null) {
            return true;
        } else if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c != null) {
            return flag.Last_Created_Log__c > flag.Last_Processed_Log__c;
        }
        return false;
    }

    @TestVisible
    private static Datetime currentTime = Datetime.now();

    public static Boolean needRunMonitoringRules() {
        Boolean needRunBatch = false;

        List<Id> monitoringRuleIds = new List<Id>();
        List<MonitoringUtil.MonitoringRule> monitoringRules = MonitoringUtil.getMonitoringRules(null);
        Map<Id, MonitoringUtil.Event> monitoringEventsMap = MonitoringUtil.getLastCreatedEventsMap();
        Datetime lastProcessedDatetime = null;
        for (MonitoringUtil.MonitoringRule monitoringRule : monitoringRules) {
            MonitoringUtil.Event monitoredEvent = monitoringEventsMap.get(monitoringRule.ruleId);
            if (monitoredEvent == null) {
                monitoringRuleIds.add(monitoringRule.ruleId);
            }
            else if (monitoredEvent.createdDate != null
                    && (monitoringRule.nextRunTime(monitoredEvent.createdDate) <= currentTime)
                    || monitoringRule.nextRunTime(monitoredEvent.createdDate) == null) {

                monitoringRuleIds.add(monitoringRule.ruleId);
                lastProcessedDatetime = (monitoredEvent.createdDate < lastProcessedDatetime && lastProcessedDatetime != null)
                        ? monitoredEvent.createdDate
                        : (lastProcessedDatetime == null ? monitoredEvent.createdDate : lastProcessedDatetime);
            }
        }
        if (!monitoringRuleIds.isEmpty()) {
            if (lastProcessedDatetime == null) {
                // run batch
                needRunBatch = true;
            }
            else {
                // count recordsnextRunTime
                String query = new QBuilder(Log__c.SObjectType)
                        .selectFields(new Set<String>{'count()'})
                        .add(QBuilder.condition('Created_At__c').isGreaterOrEquals(':lastProcessedDatetime'))
                        .add(!PermissionsUtil.NotificationForPharosErrors ? QBuilder.condition('Category__c').notEqualsTo(Logger.CATEGORY_PHAROS_ERROR) : null)
                        .add(!PermissionsUtil.NotificationForPharosErrors ? QBuilder.condition('Area__c').notEqualsTo(Logger.AREA_PHAROS_ERROR) : null)
                        .build();
                Integer countLogs = Database.countQuery(query);

                if(countLogs > 0) {
                    // run batch
                    needRunBatch = true;
                }
            }
        }
        return needRunBatch;
    }
}