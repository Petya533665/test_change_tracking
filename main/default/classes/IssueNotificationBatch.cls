public with sharing class IssueNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, NotificationService.BatchContextManager {

    private NotificationService notificationServiceImpl;
    private NotificationService.BaseBatchContextManager contextManager = new BaseBatchContextManagerImpl();
    
    // Concrete implementation of the abstract base class
    private class BaseBatchContextManagerImpl extends NotificationService.BaseBatchContextManager {
        // No additional implementation needed - inherits all methods from base class
    }

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

    public Iterable<SObject> start(Database.BatchableContext bc) {
        Boolean slackRateLimited = SlackService.isCurrentlyRateLimited();
        return this.notificationServiceImpl.getIterableForBatch(this, slackRateLimited);
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        // Now each scope contains a single record with its iteration context
        this.notificationServiceImpl.batchExecuteIteration(info, scope, this);
    }

    // BatchContextManager interface implementation - delegate to contextManager
    public void setIterationContext(String recordId, NotificationService.ActionIteration iteration) {
        contextManager.setIterationContext(recordId, iteration);
    }
    
    public NotificationService.ActionIteration getIterationContext(String recordId) {
        return contextManager.getIterationContext(recordId);
    }
    
    public void clearIterationContext(String recordId) {
        contextManager.clearIterationContext(recordId);
    }

    public void finish(Database.BatchableContext info) {
        this.notificationServiceImpl.finish(info);
    }
}