public with sharing class TraceResultNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private NotificationService notificationServiceImpl;

    private static TraceResultNotificationBatch instance = null;

    public static TraceResultNotificationBatch getInstance() {
        if (instance == null) {
            instance = new TraceResultNotificationBatch(Logger.getInstance());
        }
        return instance;
    }

    private TraceResultNotificationBatch(Logger logger) {
        super(logger);
        this.notificationServiceImpl = new NotificationService(TraceResultNotificationBatch.class.getName(), logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('TraceResultNotificationBatch', this);
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
        this.notificationServiceImpl.finish(info);
    }
}