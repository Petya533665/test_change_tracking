public with sharing class IssueNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, NotificationService.BatchContextManager {

    private NotificationService notificationServiceImpl;
    private NotificationService.BaseBatchContextManager contextManager = new BaseBatchContextManagerImpl();
    
    // Concrete implementation of the abstract base class
    private class BaseBatchContextManagerImpl extends NotificationService.BaseBatchContextManager {}

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
        Boolean slackRateLimited = SlackService.isCurrentlyRateLimited();
        NotificationService.ActionIterationIterable iterable = (NotificationService.ActionIterationIterable) this.notificationServiceImpl.getIterableForBatch(this, slackRateLimited);
        NotificationService.ActionIterationIterator iterator = (NotificationService.ActionIterationIterator) iterable.iterator();
        return iterator.count();
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        Boolean slackRateLimited = SlackService.isCurrentlyRateLimited();
        return this.notificationServiceImpl.getIterableForBatch(this, slackRateLimited);
    }

    public void execute(Database.BatchableContext info, List<SObject> scope) {
        // Now each scope contains a single record with its iteration context
        this.notificationServiceImpl.batchExecuteIteration(info, scope, this.contextManager);
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

    public Set<String> getRecordsWithNotificationAttempts() {
        return contextManager.getRecordsWithNotificationAttempts();
    }

    public void addRecordNotificationAttempt(String recordId) {
        contextManager.addRecordNotificationAttempt(recordId);
    }

    public void finish(Database.BatchableContext info) {
        this.notificationServiceImpl.finish(info, this.contextManager);
    }
}