public with sharing class TraceResultNotificationBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, NotificationService.BatchContextManager {

    private NotificationService notificationServiceImpl;
    private NotificationService.BaseBatchContextManager contextManager = new BaseBatchContextManagerImpl();
    
    // Concrete implementation of the abstract base class
    private class BaseBatchContextManagerImpl extends NotificationService.BaseBatchContextManager {}

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

    // New methods for notification attempts tracking
    public void incrementNotificationAttempts(String recordId) {
        contextManager.incrementNotificationAttempts(recordId);
    }

    public Integer getNotificationAttempts(String recordId) {
        return contextManager.getNotificationAttempts(recordId);
    }

    public void clearNotificationAttempts(String recordId) {
        contextManager.clearNotificationAttempts(recordId);
    }

    // New methods for chart data
    public void storeChartData(String recordId, String chartData) {
        contextManager.storeChartData(recordId, chartData);
    }

    public String getChartData(String recordId) {
        return contextManager.getChartData(recordId);
    }

    public void clearChartData(String recordId) {
        contextManager.clearChartData(recordId);
    }

    // New methods for chart images
    public void storeChartImages(String recordId, Map<String, String> images) {
        contextManager.storeChartImages(recordId, images);
    }

    public Map<String, String> getChartImages(String recordId) {
        return contextManager.getChartImages(recordId);
    }

    public void clearChartImages(String recordId) {
        contextManager.clearChartImages(recordId);
    }

    // Missing methods for timestamp tracking
    public void setNotificationTimestamp(DateTime timestamp) {
        contextManager.setNotificationTimestamp(timestamp);
    }

    public DateTime getNotificationTimestamp() {
        return contextManager.getNotificationTimestamp();
    }

    public void finish(Database.BatchableContext info) {
        this.notificationServiceImpl.finish(info, this.contextManager);
    }
}