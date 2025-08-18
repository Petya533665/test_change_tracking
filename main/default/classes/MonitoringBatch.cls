public with sharing class MonitoringBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable, Database.RaisesPlatformEvents {

    @TestVisible
    public DateTime startTime = null;
    public static Datetime currentTime = DateTime.now();
    private MonitoringService.IMonitoringStrategy currentStrategy;

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
        Boolean logpPermissionsEnabled = PermissionsUtil.MonitoringEnabled;
        Boolean limitsPermissionsEnabled = PermissionsUtil.LimitsMonitoringEnabled;
        Boolean logSettingsEnabled = ConfigUtil.SETTINGS.Monitoring_Enabled__c;
        Boolean limitsSettingsEnabled = ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c;
        Boolean shouldRun = MonitoringService.shouldRunMonitoring(currentTime);
        Boolean result = ((logpPermissionsEnabled && logSettingsEnabled) || (limitsPermissionsEnabled && limitsSettingsEnabled)) && shouldRun;
        return result;
    }

    public override Integer getIterationsCount() {
        return MonitoringService.getIterationsCount();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        startTime = DateTime.now();
        currentStrategy = MonitoringService.getActiveStrategy(loggerInstance, currentTime);
        return currentStrategy != null ? currentStrategy.start(bc, startTime) : null;
    }

    public void execute(Database.BatchableContext BC, List<Rule__c> scope) {
        currentStrategy?.execute(BC, scope, currentTime, startTime);
    }

    public void finish(Database.BatchableContext BC) {
        loggerInstance?.flush();
        currentStrategy?.finish(BC, currentTime);
    }
}