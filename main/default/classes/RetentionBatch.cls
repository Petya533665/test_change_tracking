public with sharing class RetentionBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Database.RaisesPlatformEvents {

	private static RetentionBatch instance = null;

	public static RetentionBatch getInstance() {
		if (instance == null) {
			instance = new RetentionBatch(Logger.getInstance());
		}
		return instance;
	}

	private RetentionBatch(Logger logger) {
		super(logger);
	}

	public override void startBatch() {
		if (!DatabaseUtils.executeBatchWithLimitCheck('RetentionBatch', this)) finishBatch();
	}

	public override Boolean initialValidation() {
		return PermissionsUtil.ArchivalEnabled && ConfigUtil.SETTINGS.Archival_Enabled__c;
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Rule__c WHERE Type__c = :MonitoringUtil.RULE_TYPE_ARCHIVAL AND Active__c = TRUE LIMIT :PermissionsUtil.MaxArchivalRules];
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
				SELECT Id, Type__c
				FROM Rule__c
				WHERE Type__c = :MonitoringUtil.RULE_TYPE_ARCHIVAL
				AND Active__c = TRUE
				ORDER BY Index__c
				LIMIT :PermissionsUtil.MaxArchivalRules
		]);
	}

	public void execute(Database.BatchableContext BC, List<Rule__c> scope) {
		if (scope == null || scope.isEmpty()) {
			return; // Skip processing for empty scope
		}
		
		List<MonitoringUtil.MonitoringRule> rules = MonitoringUtil.getArchivalRules(new List<Id>{scope.get(0).Id});
		Map<Id, MonitoringUtil.Event> mapEventsByIds = MonitoringUtil.getLastCreatedEventsMap();
		List<String> logFields = MonitoringUtil.getLogFieldNames(rules);
		Datetime currentTime = Datetime.now();
		Integer shiftMinutes = Integer.valueOf(rules.get(0).eventTypeInterval);
		Datetime ruleStartTime = currentTime.addMinutes(-shiftMinutes);
		Datetime lastProcessedDatetime = null;
		for (MonitoringUtil.MonitoringRule rule : rules) {
			MonitoringUtil.Event event = mapEventsByIds.get(rule.ruleId);
			lastProcessedDatetime = (event != null) ? event.createdDate.addMinutes(-shiftMinutes) : null;
		}
		QBuilder qbCount = getArchivalLogsQuery(rules.get(0), new Set<String>{'COUNT()'}, lastProcessedDatetime, ruleStartTime);
		Integer countLogs = Database.countQuery(qbCount.build());
		Integer limitRows = (countLogs > 45000) ? 45000 : null;
		
		QBuilder qb = getArchivalLogsQuery(rules.get(0), new Set<String>(logFields), lastProcessedDatetime, ruleStartTime);
		if (limitRows != null) {
			qb.addLimit(limitRows);
		}
		String qbQuery = qb.build();
		List<Log__c> logs = Database.query(qbQuery);
		if (!logs.isEmpty()) {
			MonitoringUtil.evaluateArchivalRules(rules, logs, loggerInstance);
		}
	}

	public void finish(Database.BatchableContext BC) {
		loggerInstance?.flush();
		MonitoringUtil.checkStartActionsBatch(false);
		if (schedulerInstance != null) {
			schedulerInstance.serviceSchedulerDispatcher();
		}
	}

	public static QBuilder getArchivalLogsQuery(MonitoringUtil.MonitoringRule rule, Set<String> logFields, Datetime lastProcessedDatetime, Datetime ruleStartTime) {
		ConfigUtil.BooleanExpressionParser parser = new ConfigUtil.BooleanExpressionParser(rule.filterLogic);
		QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>(logFields));
		Integer filtrableFields = 0;
		for(MonitoringUtil.RuleFilter rf : rule.filters) {
			if(rf.index == 1) continue;
			if(rf.comparisonType == MonitoringUtil.ComparisonType.VALUE && rf.isFilterable) {
				qb.add(rf.toQCondition());
				filtrableFields++;
			}
			else if(!rf.isFilterable) {
				parser.removeOperand(String.valueOf(rf.index - 1));
				qb.add(rf.toQCondition());
			}
        }
		qb.add(QBuilder.condition('Created_At__c').isLessThan(':ruleStartTime'));
		if(rule.filters.size() > 1) {
			parser.addOperand();
		}
		if(lastProcessedDatetime != null) {
			qb.add(QBuilder.condition('Created_At__c').isGreaterThan(':lastProcessedDatetime'));
			parser.addOperand();
		}
		
		if(parser.toConditionString() != null)
		qb.setConditionOrder(parser.toConditionString());
		return qb;
	}
}