public class MonitoringService {
    // Static variables at the top
    private static final String STRATEGY_TYPE_MONITORING = 'Monitoring';
    private static final String STRATEGY_TYPE_LIMITS = 'Limits';
    private static final Integer DEFAULT_BATCH_SCOPE = 1;
    private static final String EXCEPTION_UNSUPPORTED_RULE_TYPE = 'Unsupported rule type: ';
    private static final Integer MAX_RECORDS_TO_PROCESS = 45000;
    
    // Instance variables
    private Logger logger;
    private Map<String, IMonitoringStrategy> strategies;
    
    // Constructor
    public MonitoringService(Logger logger) {
        this.logger = logger;
        this.strategies = new Map<String, IMonitoringStrategy>();
    }
    
    // Main service methods
    public static Boolean shouldRunMonitoring(Datetime currentTime) {
        Boolean hasNewLogsResult = hasNewLogs();
        Boolean needRunMonitoringRulesResult = MonitoringService.needRunMonitoringRules(currentTime);
        Boolean hasNewLimitsResult = hasNewLimits();
        Boolean needRunLimitsRulesResult = MonitoringService.needRunLimitsRules(currentTime);
        
        Boolean result = (hasNewLogsResult && needRunMonitoringRulesResult) || 
                        (hasNewLimitsResult && needRunLimitsRulesResult);
        return result;
    }
    
    public static Integer getIterationsCount() {
        Integer monitoringRules = new LogMonitoringStrategy(null).getStrategyIterationsCount();
        Integer limitsRules = new LimitsMonitoringStrategy(null).getStrategyIterationsCount();
        return monitoringRules + limitsRules;
    }
    
    public static IMonitoringStrategy getActiveStrategy(Logger logger, Datetime currentTime) {
        if (needRunMonitoringRules(currentTime)) {
            return new LogMonitoringStrategy(logger);
        } else if (needRunLimitsRules(currentTime)) {
            return new LimitsMonitoringStrategy(logger);
        }
        return new LogMonitoringStrategy(logger);
    }
    
    public void updateLastProcessedFlag(Datetime processedDatetime) {
        // Delegate to the appropriate strategy based on the current context
        // For now, we'll update the log monitoring flag as it's the primary one
        LogMonitoringStrategy logStrategy = new LogMonitoringStrategy(logger);
        logStrategy.updateLastProcessedFlag(processedDatetime);
    }
    
    // Static utility methods
    private static List<Log__c> queryAndProcessLogs(MonitoringUtil.MonitoringRule rule, Datetime lastProcessedDatetime, List<MonitoringUtil.MonitoringRule> rules) {
        QBuilder qbCount = buildMonitoringLogsQuery(rule, new Set<String>{'COUNT()'});
        String qbCountQuery = qbCount.build();
        Integer countLogs = Database.countQuery(qbCountQuery);
        Integer limitRows = (countLogs > MAX_RECORDS_TO_PROCESS) ? MAX_RECORDS_TO_PROCESS : null;
        
        List<String> logFields = MonitoringUtil.getLogFieldNames(rules);
        QBuilder qb = buildMonitoringLogsQuery(rule, new Set<String>(logFields));
        if (limitRows != null) {
            qb.addLimit(limitRows);
        }
        String qbQuery = qb.build();
        return Database.query(qbQuery);
    }
    
    public static QBuilder buildMonitoringLogsQuery(MonitoringUtil.MonitoringRule rule, Set<String> logFields) {
        ConfigUtil.BooleanExpressionParser parser = new ConfigUtil.BooleanExpressionParser(rule.filterLogic);
        
        QBuilder qb = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>(logFields));
        
        for(MonitoringUtil.RuleFilter rf : rule.filters) {
            if(rf.comparisonType == MonitoringUtil.ComparisonType.VALUE && rf.isFilterable) {
                qb.add(rf.toQCondition());
            } else {
                parser.removeOperand(String.valueOf(rf.index));
                qb.add(rf.toQCondition(null));
            }
        }
        
        qb.add(QBuilder.condition(Constants.LOG_SOBJECT.CREATED_AT).isGreaterOrEquals(':lastProcessedDatetime'));
        parser.addOperand();
        
        if(!PermissionsUtil.NotificationForPharosErrors) {
            qb.add(QBuilder.condition(Constants.LOG_SOBJECT.CATEGORY).notEqualsTo(Constants.LOG_SOBJECT.PHAROS_CATEGORY));
            qb.add(QBuilder.condition(Constants.LOG_SOBJECT.AREA).notEqualsTo(Constants.LOG_SOBJECT.PHAROS_AREA));
            parser.addOperand();
            parser.addOperand();
        }
        
        qb.setConditionOrder(parser.toConditionString());
        return qb;
    }
    
    private static Boolean needRunRules(String ruleType, Boolean applyPharosFilter, Datetime currentTime) {        
        Boolean needRunBatch = false;

        List<Id> ruleIds = new List<Id>();
        List<MonitoringUtil.MonitoringRule> rules = (ruleType == MonitoringUtil.RULE_TYPE_MONITORING) 
            ? MonitoringUtil.getMonitoringRules(null) 
            : MonitoringUtil.getLimitsRules(null);
        Map<Id, MonitoringUtil.Event> eventsMap = MonitoringUtil.getLastCreatedEventsMap();

        Datetime lastProcessedDatetime = null;
        
        for (MonitoringUtil.MonitoringRule rule : rules) {
            MonitoringUtil.Event event = eventsMap.get(rule.ruleId);
            if (event == null) {
                ruleIds.add(rule.ruleId);
            }
            else if (event.createdDate != null
                    && (rule.nextRunTime(event.createdDate) <= currentTime)
                    || rule.nextRunTime(event.createdDate) == null) {

                ruleIds.add(rule.ruleId);
                lastProcessedDatetime = (event.createdDate < lastProcessedDatetime && lastProcessedDatetime != null)
                        ? event.createdDate
                        : (lastProcessedDatetime == null ? event.createdDate : lastProcessedDatetime);
            }
        }
        
        if (!ruleIds.isEmpty()) {
            if (lastProcessedDatetime == null) {
                needRunBatch = true;
            }
            else {
                QBuilder qb = new QBuilder(Log__c.SObjectType)
                    .selectFields(new Set<String>{'count()'})
                    .add(QBuilder.condition(Constants.LOG_SOBJECT.CREATED_AT).isGreaterOrEquals(':lastProcessedDatetime'));
                
                if (applyPharosFilter && !PermissionsUtil.NotificationForPharosErrors) {
                    qb.add(QBuilder.condition(Constants.LOG_SOBJECT.CATEGORY).notEqualsTo(Constants.LOG_SOBJECT.PHAROS_CATEGORY));
                    qb.add(QBuilder.condition(Constants.LOG_SOBJECT.AREA).notEqualsTo(Constants.LOG_SOBJECT.PHAROS_AREA));
                }

                if (ruleType == MonitoringUtil.RULE_TYPE_LIMITS) {
                    qb.add(QBuilder.condition(Constants.LOG_SOBJECT.LIMITS).isNotNull());
                }
                
                String query = qb.build();
                Integer countRecords = Database.countQuery(query);

                if(countRecords > 0) {
                    needRunBatch = true;
                }
            }
        }
        return needRunBatch;
    }
    
    public static Boolean needRunMonitoringRules(Datetime currentTime) {
        Boolean result = needRunRules(MonitoringUtil.RULE_TYPE_MONITORING, true, currentTime);
        return result;
    }
    
    public static Boolean needRunLimitsRules(Datetime currentTime) {
        return needRunRules(MonitoringUtil.RULE_TYPE_LIMITS, false, currentTime);
    }
    
    // Utility methods moved from MonitoringBatch
    public static Boolean hasNewLogs() {
        Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
        if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c == null) {
            return true;
        } else if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c != null) {
            return flag.Last_Created_Log__c > flag.Last_Processed_Log__c;
        }
        return false;
    }
    
    public static Boolean hasNewLimits() {
        Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
        if (flag.Last_Created_Log__c != null && flag.Last_Processed_Limits_Log__c == null) {
            return true;
        } else if (flag.Last_Created_Log__c != null && flag.Last_Processed_Limits_Log__c != null) {
            return flag.Last_Created_Log__c > flag.Last_Processed_Limits_Log__c;
        }
        return false;
    }
    
    // Inner interface
    public interface IMonitoringStrategy {
        void processStrategy(List<Rule__c> rules, Map<Id, MonitoringUtil.Event> eventsMap, Datetime currentTime, DateTime startTime);
        Integer getStrategyIterationsCount();
        Datetime getLastProcessedDatetime();
        void updateLastProcessedFlag(Datetime processedDatetime);
        Boolean hasNewData();
        
        // Batch lifecycle methods
        Database.QueryLocator start(Database.BatchableContext bc, DateTime startTime);
        void execute(Database.BatchableContext BC, List<Rule__c> scope, Datetime currentTime, DateTime startTime);
        void finish(Database.BatchableContext BC, Datetime currentTime);
    }
    
    // Abstract base class for monitoring strategies
    public abstract class BaseMonitoringStrategy implements IMonitoringStrategy {
        protected Logger logger;
        
        public BaseMonitoringStrategy(Logger logger) {
            this.logger = logger;
        }
        
        // Abstract methods that must be implemented by subclasses
        public abstract String getRuleType();
        public abstract Boolean hasNewData();
        public abstract Boolean needRunRules(Datetime currentTime);
        public abstract List<MonitoringUtil.MonitoringRule> getRules(List<Id> ruleIds);
        public abstract void evaluateRulesForStrategy(List<Id> ruleIds, List<MonitoringUtil.MonitoringRule> rules, Datetime lastProcessedDatetime, Datetime startTime, Map<Id, MonitoringUtil.Event> eventsMap);
        
        // Common implementation for processStrategySpecific
        public void processStrategySpecific(List<Rule__c> rules, Map<Id, MonitoringUtil.Event> eventsMap, Datetime currentTime, DateTime startTime) {
            List<MonitoringUtil.MonitoringRule> strategyRules = getRules(new List<Id>{rules[0].Id});
            
            Datetime lastProcessedDatetime = calculateLastProcessedDatetime(strategyRules, eventsMap);
            
            if (lastProcessedDatetime != null && !strategyRules.isEmpty()) {
                evaluateRulesForStrategy(new List<Id>{rules[0].Id}, strategyRules, lastProcessedDatetime, startTime, eventsMap);
            }
        }
        
        // Common implementation for processStrategy
        public void processStrategy(List<Rule__c> rules, Map<Id, MonitoringUtil.Event> eventsMap, Datetime currentTime, DateTime startTime) {
            processStrategySpecific(rules, eventsMap, currentTime, startTime);
        }
        
        // Common implementation for getStrategyIterationsCount
        public Integer getStrategyIterationsCount() {
            return [SELECT COUNT() FROM Rule__c 
                WHERE Type__c = :getRuleType() AND Active__c = TRUE 
                LIMIT :PermissionsUtil.MaxMonitoringRules];
        }
        
        // Common implementation for start method
        public virtual Database.QueryLocator start(Database.BatchableContext bc, DateTime startTime) {
            return Database.getQueryLocator([
                SELECT Id, Type__c
                FROM Rule__c
                WHERE Type__c = :getRuleType()
                AND Active__c = TRUE
                ORDER BY Index__c
                LIMIT :PermissionsUtil.MaxMonitoringRules
            ]);
        }
        
        // Common implementation for execute method
        public virtual void execute(Database.BatchableContext BC, List<Rule__c> scope, Datetime currentTime, DateTime startTime) {
            if (scope == null || scope.isEmpty()) {
                return;
            }
            
            // Clear cached rules for Test context
            MonitoringUtil.cachedRules = new Map<String, Map<Id, MonitoringUtil.MonitoringRule>>();
            
            Map<Id, MonitoringUtil.Event> eventsMap = MonitoringUtil.getLastCreatedEventsMap();
            processStrategy(scope, eventsMap, currentTime, startTime);
        }
        
        // Common implementation for finish method
        public virtual void finish(Database.BatchableContext BC, Datetime currentTime) {
            if (hasNewData() && needRunRules(currentTime)) {
                MonitoringBatch.getInstance().startBatch();
            }
            else {
                MonitoringUtil.checkStartActionsBatch(false);
            }
        }
        
        // Common helper method for calculating last processed datetime
        protected Datetime calculateLastProcessedDatetime(List<MonitoringUtil.MonitoringRule> rules, 
                                                        Map<Id, MonitoringUtil.Event> eventsMap) {
            Datetime lastProcessedDatetime = null;
            Datetime currentTime = Datetime.now();
            
            for (MonitoringUtil.MonitoringRule rule : rules) {
                MonitoringUtil.Event event = eventsMap.get(rule.ruleId);
                if (event == null) {
                    lastProcessedDatetime = currentTime.addMinutes(-Integer.valueOf(rule.eventTypeInterval));
                } else if(event.createdDate != null && (rule.nextRunTime(event.createdDate) <= currentTime)) {
                    lastProcessedDatetime = event.createdDate;
                }
            }
            
            return lastProcessedDatetime;
        }
    }
    
    // Inner LogMonitoringStrategy implementation
    public class LogMonitoringStrategy extends BaseMonitoringStrategy {
        
        public LogMonitoringStrategy(Logger logger) {
            super(logger);
        }
        
        public override String getRuleType() {
            return MonitoringUtil.RULE_TYPE_MONITORING;
        }
        
        public override Boolean hasNewData() {
            return MonitoringService.hasNewLogs();
        }
        
        public override Boolean needRunRules(Datetime currentTime) {
            return MonitoringService.needRunMonitoringRules(currentTime);
        }
        
        public override List<MonitoringUtil.MonitoringRule> getRules(List<Id> ruleIds) {
            return MonitoringUtil.getMonitoringRules(ruleIds);
        }
        
        public override void evaluateRulesForStrategy(List<Id> ruleIds, List<MonitoringUtil.MonitoringRule> rules, Datetime lastProcessedDatetime, Datetime startTime, Map<Id, MonitoringUtil.Event> eventsMap) {
            List<Log__c> logs = MonitoringService.queryAndProcessLogs(rules.get(0), lastProcessedDatetime, rules);
            MonitoringUtil.evaluateRules(logs, ruleIds, startTime, eventsMap, logger);
        }
        
        public Datetime getLastProcessedDatetime() {
            Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
            return flag.Last_Processed_Log__c;
        }
        
        public void updateLastProcessedFlag(Datetime processedDatetime) {
            Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
            if (Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Log__c.isCreateable()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Log__c.isUpdateable()) {
                flag.Last_Processed_Log__c = processedDatetime;
            }
            if (Schema.SObjectType.Monitoring_Batch_Flag__c.isAccessible()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.isCreateable()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.isUpdateable()) {
                DatabaseUtils.getInstance().performUpsertDML(
                    new List<Monitoring_Batch_Flag__c>{flag}, 
                    Schema.SObjectType.Monitoring_Batch_Flag__c
                ).handleError(MonitoringService.class.getName(), '.updateLastProcessedFlag', logger);
            }
        }
        
        // Override start to add flag update for log monitoring
        public override Database.QueryLocator start(Database.BatchableContext bc, DateTime startTime) {
            updateLastProcessedFlag(startTime);
            return super.start(bc, startTime);
        }
    }
    
    // Inner LimitsMonitoringStrategy implementation
    public class LimitsMonitoringStrategy extends BaseMonitoringStrategy {
        
        public LimitsMonitoringStrategy(Logger logger) {
            super(logger);
        }
        
        public override String getRuleType() {
            return MonitoringUtil.RULE_TYPE_LIMITS;
        }
        
        public override Boolean hasNewData() {
            return MonitoringService.hasNewLimits();
        }
        
        public override Boolean needRunRules(Datetime currentTime) {
            return MonitoringService.needRunLimitsRules(currentTime);
        }
        
        public override List<MonitoringUtil.MonitoringRule> getRules(List<Id> ruleIds) {
            return MonitoringUtil.getLimitsRules(ruleIds);
        }
        
        public override void evaluateRulesForStrategy(List<Id> ruleIds, List<MonitoringUtil.MonitoringRule> rules, Datetime lastProcessedDatetime, Datetime startTime, Map<Id, MonitoringUtil.Event> eventsMap) {
            List<Log__c> logs = MonitoringService.queryAndProcessLogs(rules.get(0), lastProcessedDatetime, rules);
            MonitoringUtil.evaluateLimitsRules(logs, ruleIds, startTime, eventsMap, logger);
        }
        
        public Datetime getLastProcessedDatetime() {
            Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
            return flag.Last_Processed_Limits_Log__c;
        }
        
        public void updateLastProcessedFlag(Datetime processedDatetime) {
            Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
            if (Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Limits_Log__c.isCreateable()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Processed_Limits_Log__c.isUpdateable()) {
                flag.Last_Processed_Limits_Log__c = processedDatetime;
            }
            if (Schema.SObjectType.Monitoring_Batch_Flag__c.isAccessible()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.isCreateable()
                    && Schema.SObjectType.Monitoring_Batch_Flag__c.isUpdateable()) {
                DatabaseUtils.getInstance().performUpsertDML(
                    new List<Monitoring_Batch_Flag__c>{flag}, 
                    Schema.SObjectType.Monitoring_Batch_Flag__c
                ).handleError(MonitoringService.class.getName(), '.updateLastProcessedFlag', logger);
            }
        }
        
        // Override start to add flag update for limits monitoring
        public override Database.QueryLocator start(Database.BatchableContext bc, DateTime startTime) {
            updateLastProcessedFlag(startTime);
            return super.start(bc, startTime);
        }
    }
    
    // Inner exception class
    public class MonitoringException extends Exception {}
}