public with sharing class JiraNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private NotificationService notificationServiceImpl;

    private static JiraNotificationBatch instance = null;

    public static JiraNotificationBatch getInstance() {
        if (instance == null) {
            instance = new JiraNotificationBatch(Logger.getInstance());
        }
        return instance;
    }

    private JiraNotificationBatch(Logger logger) {
        super(logger);
        this.notificationServiceImpl = new NotificationService(JiraNotificationBatch.class.getName(), logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('JiraNotificationBatch', this);
    }

    public override Boolean initialValidation() {
        return notificationServiceImpl.isPermissionEnabled() && BlurModeService.isAvailableNotifications24hr() && NotificationService.getNotificationTimeStamp() == null;
    }

    public override Integer getIterationsCount() {
        return notificationServiceImpl.getSObjectRecordsCount();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        NotificationService.putNotificationTimeStamp(Datetime.now());
        return this.notificationServiceImpl.getQueryLocator();
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        this.notificationServiceImpl.batchExecuteIteration(info, scope);
    }

    public void finish(Database.BatchableContext info) {
        NotificationService.putNotificationTimeStamp(null);
        this.notificationServiceImpl.finish(info);
    }
}