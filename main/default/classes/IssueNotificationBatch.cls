public with sharing class IssueNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private NotificationService notificationServiceImpl;

    private static IssueNotificationBatch instance = null;

    public static IssueNotificationBatch getInstance() {
        if (instance == null) {
            instance = new IssueNotificationBatch(Logger.getInstance());
        }
        return instance;
    }

    private IssueNotificationBatch(Logger logger) {
        super(logger);
        this.notificationServiceImpl = new NotificationService(IssueNotificationBatch.class.getName(), logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('IssueNotificationBatch', this);
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