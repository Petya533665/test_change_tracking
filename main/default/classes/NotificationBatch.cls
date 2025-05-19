public with sharing class NotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private NotificationService notificationServiceImpl;

    private static NotificationBatch instance = null;

    public static NotificationBatch getInstance() {
        if (instance == null) {
            instance = new NotificationBatch(Logger.getInstance());
        }
        return instance;
    }

    private NotificationBatch(Logger logger) {
        super(logger);
        this.notificationServiceImpl = new NotificationService(NotificationBatch.class.getName(), logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('NotificationBatch', this);
    }

    public override Boolean initialValidation() {
        return notificationServiceImpl.isPermissionEnabled() && BlurModeService.isAvailableNotifications24hr();
    }

    public override Integer getIterationsCount() {
        return notificationServiceImpl.getSObjectRecordsCount();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return this.notificationServiceImpl.getQueryLocator();
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        this.notificationServiceImpl.batchExecuteIteration(info, scope);
    }

    public void finish(Database.BatchableContext info) {
        MonitoringUtil.checkStartActionsBatch(false);
    }
}