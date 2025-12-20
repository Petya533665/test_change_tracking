/**
 * NotificationService - Central service for handling various types of notifications
 * 
 * This service manages:
 * - Standard notifications (Email, Slack, Teams, Jira, PagerDuty)
 * - AutoChart integration for automatic chart generation and delivery
 * - Batch processing with rate limiting and error handling
 * - Multi-platform message delivery with context management
 * 
 * AutoChart Integration:
 * - Detects {!System_Auto_Chart.CHART_TYPE} merge fields in actions
 * - Processes charts through 3-step workflow (GET_DATA -> GET_IMAGE -> SEND_MESSAGE)
 * - Supports all notification platforms with chart attachments
 * 
 * @since API Version 59.0
 * @see AutoChart - Dedicated class for chart processing logic
 */
public with sharing class NotificationService {

    // Service type enumeration for different notification contexts
    public enum NOTIFICATION_SERVICE_TYPE {LOG, ISSUE, TRACE_RESULT, EVENT_ACTION}

    private Logger logger;
    @TestVisible
    private NotificationServiceInterface strategy;

    public static Set<String> transactionIds = new Set<String>();
    public static Set<String> newIssueInTransactionIds = new Set<String>();
    public static Map<String, NotificationService.ExecutableRulesConfig> mapConfigsInTransaction = new Map<String, NotificationService.ExecutableRulesConfig>();

    public static Map<NOTIFICATION_SERVICE_TYPE, Integer> mapCountRecordsByType = new Map<NOTIFICATION_SERVICE_TYPE, Integer>();
    
    /**
     * Utility method to check if an ActionIteration is an AutoChart iteration
     * @param iteration ActionIteration to check
     * @return true if this is an AutoChart iteration
     */
    public static Boolean isAutoChartIteration(ActionIteration iteration) {
        return iteration instanceof AutoChart.AutoChartIteration;
    }
    
    /**
     * Utility method to safely cast ActionIteration to AutoChartIteration
     * @param iteration ActionIteration to cast
     * @return AutoChartIteration or null if not an AutoChart iteration
     */
    public static AutoChart.AutoChartIteration toAutoChartIteration(ActionIteration iteration) {
        return isAutoChartIteration(iteration) ? (AutoChart.AutoChartIteration) iteration : null;
    }
    
    // Test visible flag to control iterator expansion behavior
    @TestVisible
    public static Boolean disableIteratorExpansion = false;
    
    // Test visible flag to simulate email limit errors for testing
    @TestVisible
    public static Boolean simulateEmailLimitError = false;
    
    /**
     * Safe sleep utility for rate limiting with governor limit protection
     * Sleeps for specified milliseconds to help with API rate limiting
     */
    @TestVisible
    public static void safeSleep(Integer milliseconds) {
        // Skip sleep in test context to avoid timeouts
        if (Test.isRunningTest()) {
            return;
        }
        
        // Limit sleep time to prevent governor limit issues (max 5 seconds)
        Integer sleepTime = Math.min(milliseconds, 5000);
        
        Long startTime = System.currentTimeMillis();
        Long endTime = startTime + sleepTime;
        
        // Simple busy wait loop with CPU time checks
        while (System.currentTimeMillis() < endTime) {
            // Check CPU time to prevent governor limit violations
            if (Limits.getCpuTime() > (Limits.getLimitCpuTime() * 0.8)) {
                break; // Exit if approaching CPU limit
            }
            
            // Small iteration to prevent infinite tight loop
            Integer dummy = Math.mod(System.now().millisecond(), 1000);
        }
    }
    
    // Interface for batch context management
    public interface BatchContextManager {
        void setIterationContext(String recordId, ActionIteration iteration);
        ActionIteration getIterationContext(String recordId);
        void clearIterationContext(String recordId);
        void addRecordNotificationAttempt(String recordId);
        Set<String> getRecordsWithNotificationAttempts();
        
        // New methods for notification attempts tracking
        void incrementNotificationAttempts(String recordId);
        Integer getNotificationAttempts(String recordId);
        void clearNotificationAttempts(String recordId);

        // New methods for chart data
        void storeChartData(String recordId, String chartData);
        String getChartData(String recordId);
        void clearChartData(String recordId);
        
        // New methods for chart images
        void storeChartImages(String recordId, Map<String, String> images);
        Map<String, String> getChartImages(String recordId);
        void clearChartImages(String recordId);
    }
    
    // Base implementation of BatchContextManager to eliminate duplicate code across batch classes
    public abstract class BaseBatchContextManager implements BatchContextManager {
        // Instance variables to store iteration contexts between batch executions
        protected Map<String, List<ActionIteration>> recordIterationQueues = new Map<String, List<ActionIteration>>();
        protected Map<String, ActionIteration> recordCurrentIterations = new Map<String, ActionIteration>();
        
        protected Set<String> recordWithNotificationAttempts = new Set<String>();

        // Batch execution statistics for rate limit tracking
        protected BatchExecutionStats batchStats = new BatchExecutionStats();
        
        // New fields for data storage
        protected Map<String, Integer> notificationAttempts = new Map<String, Integer>();
        protected Map<String, String> chartDataStorage = new Map<String, String>();
        protected Map<String, Map<String, String>> chartImagesStorage = new Map<String, Map<String, String>>();

        public virtual Set<String> getRecordsWithNotificationAttempts() {
            return this.recordWithNotificationAttempts;
        }

        public virtual void addRecordNotificationAttempt(String recordId) {
            this.recordWithNotificationAttempts.add(recordId);
        }

        public void setIterationContext(String recordId, ActionIteration iteration) {
            // Add to the queue for this record
            if (!this.recordIterationQueues.containsKey(recordId)) {
                this.recordIterationQueues.put(recordId, new List<ActionIteration>());
            }
            this.recordIterationQueues.get(recordId).add(iteration);
            
            // If this is the first iteration added, set it as current
            if (!this.recordCurrentIterations.containsKey(recordId)) {
                this.recordCurrentIterations.put(recordId, iteration);
            }
        }
        
        public ActionIteration getIterationContext(String recordId) {
            return this.recordCurrentIterations.get(recordId);
        }
        
        public void clearIterationContext(String recordId) {
            // Move to next iteration instead of fully clearing
            List<ActionIteration> queue = this.recordIterationQueues.get(recordId);
            if (queue != null && !queue.isEmpty()) {
                // Remove the completed iteration from the queue
                queue.remove(0);
                
                if (!queue.isEmpty()) {
                    // Set the next iteration as current - safe access
                    ActionIteration nextIteration = queue.size() > 0 ? queue[0] : null;
                    if (nextIteration != null) {
                        this.recordCurrentIterations.put(recordId, nextIteration);
                    } else {
                        this.recordCurrentIterations.remove(recordId);
                        this.recordIterationQueues.remove(recordId);
                    }
                } else {
                    // No more iterations, clear everything
                    this.recordCurrentIterations.remove(recordId);
                    this.recordIterationQueues.remove(recordId);
                }
            }
        }

        // Public methods for batch statistics tracking
        public void trackSlackAction(String recordId) {
            this.batchStats.trackSlackAction(recordId);
        }

        public void trackSlackSuccess(String recordId) {
            this.batchStats.trackSlackSuccess(recordId);
        }

        public void trackSlackFailure(String recordId) {
            this.batchStats.trackSlackFailure(recordId);
        }

        public void trackSlackRateLimit(String recordId, String message, DateTime retryAfter) {
            this.batchStats.trackSlackRateLimit(recordId, message, retryAfter);
        }

        public BatchExecutionStats getBatchStats() {
            return this.batchStats;
        }
        
        public void setBatchStats(BatchExecutionStats stats) {
            this.batchStats = stats;
        }
        
        // Notification attempts tracking
        public void incrementNotificationAttempts(String recordId) {
            Integer currentCount = notificationAttempts.get(recordId);
            notificationAttempts.put(recordId, currentCount != null ? currentCount + 1 : 1);
        }
        
        public Integer getNotificationAttempts(String recordId) {
            return notificationAttempts.get(recordId) != null ? notificationAttempts.get(recordId) : 0;
        }
        
        public void clearNotificationAttempts(String recordId) {
            notificationAttempts.remove(recordId);
        }

        // Chart data storage
        public void storeChartData(String recordId, String chartData) {
            chartDataStorage.put(recordId, chartData);
        }
        
        public String getChartData(String recordId) {
            return chartDataStorage.get(recordId);
        }
        
        public void clearChartData(String recordId) {
            chartDataStorage.remove(recordId);
        }
        
        // Chart images storage
        public void storeChartImages(String recordId, Map<String, String> images) {
            chartImagesStorage.put(recordId, images);
        }
        
        public Map<String, String> getChartImages(String recordId) {
            return chartImagesStorage.get(recordId);
        }
        
        public void clearChartImages(String recordId) {
            chartImagesStorage.remove(recordId);
        }
        
        // Cleanup methods
        public void clearAllData() {
            notificationAttempts.clear();
            chartDataStorage.clear();
            chartImagesStorage.clear();
            recordWithNotificationAttempts.clear();
            batchStats = new BatchExecutionStats();
        }
        
        public void clearRecordData(String recordId) {
            clearNotificationAttempts(recordId);
            clearChartData(recordId);
            clearChartImages(recordId);
            recordWithNotificationAttempts.remove(recordId);
        }
    }

    // Batch execution statistics tracking (moved outside of inner class)
    public class BatchExecutionStats {
        public Integer totalSlackActions = 0;
        public Integer successfulSlackActions = 0;
        public Integer failedSlackActions = 0;
        public Integer rateLimitedSlackActions = 0;
        public Set<String> affectedRecordIds = new Set<String>();
        public List<RateLimitEvent> rateLimitEvents = new List<RateLimitEvent>();

        public void trackSlackAction(String recordId) {
            this.totalSlackActions++;
            if (String.isNotBlank(recordId)) {
                this.affectedRecordIds.add(recordId);
            }
        }

        public void trackSlackSuccess(String recordId) {
            this.successfulSlackActions++;
        }

        public void trackSlackFailure(String recordId) {
            this.failedSlackActions++;
        }

        public void trackSlackRateLimit(String recordId, String message, DateTime retryAfter) {
            this.rateLimitedSlackActions++;
            this.rateLimitEvents.add(new RateLimitEvent(recordId, message, retryAfter));
        }

        public Boolean hasRateLimitEvents() {
            return !this.rateLimitEvents.isEmpty();
        }

        public Integer getPendingSlackActions() {
            return this.totalSlackActions - this.successfulSlackActions - this.failedSlackActions;
        }

        public Decimal getSuccessRate() {
            return this.totalSlackActions > 0 ?
                (Decimal.valueOf(this.successfulSlackActions) / Decimal.valueOf(this.totalSlackActions)) * 100 : 0;
        }
    }

    public class RateLimitEvent {
        public String recordId;
        public String message;
        public DateTime timestamp;
        public DateTime retryAfter;

        public RateLimitEvent(String recordId, String message, DateTime retryAfter) {
            this.recordId = recordId;
            this.message = message;
            this.timestamp = DateTime.now();
            this.retryAfter = retryAfter;
        }
    }
    
    // Test helper methods for controlling iterator behavior
    @TestVisible
    public static void enableIteratorExpansionForTests() {
        disableIteratorExpansion = false; // Enable expansion by setting disable flag to false
    }
    
    @TestVisible
    public static void disableIteratorExpansionForTests() {
        disableIteratorExpansion = true; // Disable expansion by setting disable flag to true (default test behavior)
    }

    public static void incrementCountRecords(NOTIFICATION_SERVICE_TYPE serviceType) {
        if(NotificationService.mapCountRecordsByType.get(serviceType) == null) {
            NotificationService.mapCountRecordsByType.put(serviceType, 1);
        }
        else {
            Integer counter = NotificationService.mapCountRecordsByType.get(serviceType);
            NotificationService.mapCountRecordsByType.put(serviceType, counter++);
        }
    }
    public static void addToMapCountRecordsByType(Schema.SObjectType sobjectType) {
        if(sobjectType == Log__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.LOG);
        }
        if(sobjectType == Issue__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.ISSUE);
        }
        if(sobjectType == Trace_Result__c.SObjectType) {
            NotificationService.incrementCountRecords(NOTIFICATION_SERVICE_TYPE.TRACE_RESULT);
        }
    }

    public NotificationService(NOTIFICATION_SERVICE_TYPE serviceType, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE.get(serviceType);
        // Pass logger to strategy if it's a NotificationServiceDefaultImpl
        if (this.strategy instanceof NotificationServiceBase) {
            ((NotificationServiceBase) this.strategy).setLogger(logger);
        }
    }

    public static NotificationService getInstance(NOTIFICATION_SERVICE_TYPE serviceType, Logger logger) {
        return new NotificationService(serviceType, logger);
    }

    public NotificationService(String className, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE_BY_NAME.get(className);
        // Pass logger to strategy if it's a NotificationServiceDefaultImpl
        if (this.strategy instanceof NotificationServiceBase) {
            ((NotificationServiceBase) this.strategy).setLogger(logger);
        }
    }

    public void startNotificationBatch() {
        this.strategy.startNotificationBatch();
    }

    public Boolean isPermissionEnabled() {
        return this.strategy.isPermissionEnabled();
    }

    public Integer getSObjectRecordsCount() {
        return this.strategy.getSObjectRecordsCount();
    }

    public Database.QueryLocator getQueryLocator() {
        return this.strategy.getQueryLocator();
    }

    public void batchExecuteIteration(Database.BatchableContext info, List<SObject> scope, BatchContextManager batchContextManager) {
        this.strategy.batchExecuteIteration(info, scope, batchContextManager);
    }

    public void finish(Database.BatchableContext info) {
        this.strategy.finish(info);
    }

    public void finish(Database.BatchableContext info, BatchContextManager batchContextManager) {
        this.strategy.finish(info, batchContextManager);
    }

    public void runNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.strategy.runNotificationRulesHandler(newList, oldMap);
    }

    public void executeNotificationRulesHandler(List<SObject> newList, Map<Id, SObject> oldMap) {
        this.strategy.executeNotificationRulesHandler(newList, oldMap);
    }

    public static DateTime getNotificationTimeStamp() {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_NOTIFICATION_TIMESTAMP);
        DateTime value = cacheObject != null ? (DateTime)cacheObject : null;
        if(value == Datetime.newInstance(0)) return null;
        return value;
    }

    public static void putNotificationTimeStamp(DateTime dt) {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        dt = dt == null ? Datetime.newInstance(0) : dt;
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_NOTIFICATION_TIMESTAMP, dt);
    }

    public static void incrementNotificationAttempts(String recordId) {
        String recordKey = CacheUtils.KEY_NOTIFICATION_OBJECT_TRACKING + ':' + recordId;
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());

        Object cacheObject = cacheUtil.getValue(recordKey);
        Integer count = cacheObject != null ? (Integer)cacheObject + 1 : 1;
        cacheUtil.putValue(recordKey, count);
    }

    // Parameter-based approach methods

    public static void incrementNotificationAttempts(String recordId, BatchContextManager batchContext) {
        if (batchContext != null) {
            batchContext.incrementNotificationAttempts(recordId);
        }
    }

    public static Integer getNotificationAttempts(String recordId, BatchContextManager batchContext) {
        return batchContext != null ? batchContext.getNotificationAttempts(recordId) : 0;
    }


    // Chart data methods
    public static void storeChartData(String recordId, String chartData, BatchContextManager batchContext) {
        if (batchContext != null) {
            batchContext.storeChartData(recordId, chartData);
        }
    }
    
    public static String getChartData(String recordId, BatchContextManager batchContext) {
        return batchContext != null ? batchContext.getChartData(recordId) : null;
    }
    
    public static void storeChartImages(String recordId, Map<String, String> images, BatchContextManager batchContext) {
        if (batchContext != null) {
            batchContext.storeChartImages(recordId, images);
        }
    }
    
    public static Map<String, String> getChartImages(String recordId, BatchContextManager batchContext) {
        return batchContext != null ? batchContext.getChartImages(recordId) : null;
    }

    public class ErrorsHelper {

        public Map<Id, List<System.Exception>> emailExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> slackExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> pagerDutyExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> teamsExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, List<System.Exception>> webhookExceptions = new Map<Id, List<System.Exception>>();
        public Map<Id, System.Exception> ticketingExceptions = new Map<Id, System.Exception>();
        public Schema.DescribeSObjectResult sObjectType;
        public Schema.DescribeFieldResult dfrId;
        public Schema.DescribeFieldResult dfrBugTracker;
        public Schema.DescribeFieldResult dfrJiraIntegrationStatus;
        public Schema.DescribeFieldResult dfrNotificationIntegrationStatus;
        public Schema.DescribeFieldResult dfrEmailIntegrationStatus;
        public Schema.DescribeFieldResult dfrPagerDutyIntegrationStatus;
        public Schema.DescribeFieldResult dfrSlackIntegrationStatus;
        public Schema.DescribeFieldResult dfrTeamsIntegrationStatus;
        public Schema.DescribeFieldResult dfrWebhookIntegrationStatus;
        public Schema.DescribeFieldResult dfrExecutableRules;

        public ErrorsHelper(SObject sobjectRecord) {
            if(sobjectRecord.getSObjectType() == Schema.sObjectType.Log__c.SObjectType) {
                sObjectType = Schema.sObjectType.Log__c;
                dfrId = Schema.sObjectType.Log__c.fields.Id;
                dfrBugTracker = Schema.sObjectType.Log__c.fields.Bug_Tracker__c;
                dfrJiraIntegrationStatus = Schema.sObjectType.Log__c.fields.Jira_Integration_Status__c;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Log__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = Schema.sObjectType.Log__c.fields.Email_Integration_Status__c;
                dfrPagerDutyIntegrationStatus = Schema.sObjectType.Log__c.fields.PagerDuty_Integration_Status__c;
                dfrSlackIntegrationStatus = Schema.sObjectType.Log__c.fields.Slack_Integration_Status__c;
                dfrTeamsIntegrationStatus = Schema.sObjectType.Log__c.fields.Teams_Integration_Status__c;
                dfrWebhookIntegrationStatus = Schema.sObjectType.Log__c.fields.Webhook_Integration_Status__c;
                dfrExecutableRules = Schema.sObjectType.Log__c.fields.Executable_Rules__c;
            }
            else if(sobjectRecord.getSObjectType() == Schema.sObjectType.Issue__c.SObjectType) {
                sObjectType = Schema.sObjectType.Issue__c;
                dfrId = Schema.sObjectType.Issue__c.fields.Id;
                dfrBugTracker = Schema.sObjectType.Issue__c.fields.Bug_Tracker__c;
                dfrJiraIntegrationStatus = Schema.sObjectType.Issue__c.fields.Jira_Integration_Status__c;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Issue__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = Schema.sObjectType.Issue__c.fields.Email_Integration_Status__c;
                dfrPagerDutyIntegrationStatus = Schema.sObjectType.Issue__c.fields.PagerDuty_Integration_Status__c;
                dfrSlackIntegrationStatus = Schema.sObjectType.Issue__c.fields.Slack_Integration_Status__c;
                dfrTeamsIntegrationStatus = Schema.sObjectType.Issue__c.fields.Teams_Integration_Status__c;
                dfrWebhookIntegrationStatus = Schema.sObjectType.Issue__c.fields.Webhook_Integration_Status__c;
                dfrExecutableRules = Schema.sObjectType.Issue__c.fields.Executable_Rules__c;
            }
            else if(sobjectRecord.getSObjectType() == Schema.sObjectType.Trace_Result__c.SObjectType) {
                sObjectType = Schema.sObjectType.Trace_Result__c;
                dfrId = Schema.sObjectType.Trace_Result__c.fields.Id;
                dfrBugTracker = null;
                dfrJiraIntegrationStatus = null;
                dfrNotificationIntegrationStatus = Schema.sObjectType.Trace_Result__c.fields.Notification_Integration_Status__c;
                dfrEmailIntegrationStatus = null;
                dfrPagerDutyIntegrationStatus = null;
                dfrSlackIntegrationStatus = null;
                dfrTeamsIntegrationStatus = null;
                dfrWebhookIntegrationStatus = null;
                dfrExecutableRules = Schema.sObjectType.Trace_Result__c.fields.Executable_Rules__c;
            }
        }

        public void createErrors(SObject record, Map<Id, SObject> toUpdateRecordsMap, Logger logger) {
            Id recordId = (String)record.get('Id');
            SObject failedRecord = (toUpdateRecordsMap.containsKey(recordId))
                ? toUpdateRecordsMap.get(recordId)
                : PermissionsUtil.newSObject(sObjectType);
            PermissionsUtil.putSObjectField(failedRecord, dfrId, recordId);

            // Get the latest action state from transaction cache or from record
            NotificationService.ExecutableRulesConfig config;
            if (NotificationService.mapConfigsInTransaction.containsKey(String.valueOf(recordId))) {
                // Use the latest config from transaction cache (includes completed actions)
                config = NotificationService.mapConfigsInTransaction.get(String.valueOf(recordId));
            } else {
                // Fallback to parsing from record field
                config = NotificationService.getExecutableRuleConfig(record);
            }
            
            config.clearRunningIds();
            PermissionsUtil.putSObjectField(failedRecord, dfrExecutableRules, config.toJSON());

            List<System.Exception> emailExceptionsList = emailExceptions.get(recordId);
            List<System.Exception> slackExceptionsList = slackExceptions.get(recordId);
            List<System.Exception> pagerDutyExceptionsList = pagerDutyExceptions.get(recordId);
            List<System.Exception> teamsExceptionsList = teamsExceptions.get(recordId);
            List<System.Exception> webhookExceptionsList = webhookExceptions.get(recordId);

            if(emailExceptionsList != null && !emailExceptions.isEmpty()) {
                for(System.Exception e : emailExceptionsList) {
                    // Don't create internal error logs for email limit errors
                    // as they will trigger recursive notifications if NotificationForPharosErrors is enabled
                    if (e.getMessage() != null && 
                        (e.getMessage().toUpperCase().contains('EMAIL_LIMIT_EXCEEDED') ||
                         e.getMessage().toUpperCase().contains('SINGLE_EMAIL_LIMIT'))) {
                        continue; // Skip creating internal error log to prevent recursive loop
                    }
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'emailExceptions'));
                }
            }
            if(slackExceptionsList != null && !slackExceptionsList.isEmpty()) {
                for(System.Exception e : slackExceptionsList) {
                    // do not log rate limit errors, they are handled in the batch class and will be logged by the batch class
                    if(e.getMessage().contains('rate limit')) {
                        continue;
                    }
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'slackExceptions'));
                }
            }
            if(pagerDutyExceptionsList != null && !pagerDutyExceptionsList.isEmpty()) {
                for(System.Exception e : pagerDutyExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'pagerDutyExceptions'));
                }
            }
            if(teamsExceptionsList != null && !teamsExceptionsList.isEmpty()) {
                for(System.Exception e : teamsExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'teamsExceptions'));
                }
            }
            if(webhookExceptionsList != null && !webhookExceptionsList.isEmpty()) {
                for(System.Exception e : webhookExceptionsList) {
                    logger?.add(logger.getInternalError(e, recordId, NotificationService.class.getName(), 'webhookExceptions'));
                }
            }

            // Check if we only have Slack rate limit errors
            Boolean hasOnlySlackRateLimitErrors = false;
            if (slackExceptionsList != null && !slackExceptionsList.isEmpty()) {
                hasOnlySlackRateLimitErrors = true;
                for (System.Exception e : slackExceptionsList) {
                    if (!e.getMessage().toLowerCase().contains('rate limit')) {
                        hasOnlySlackRateLimitErrors = false;
                        break;
                    }
                }
                // Also check that no other exception types exist
                hasOnlySlackRateLimitErrors = hasOnlySlackRateLimitErrors
                    && (emailExceptionsList == null || emailExceptionsList.isEmpty())
                    && (teamsExceptionsList == null || teamsExceptionsList.isEmpty())
                    && (pagerDutyExceptionsList == null || pagerDutyExceptionsList.isEmpty())
                    && (webhookExceptionsList == null || webhookExceptionsList.isEmpty());
            }

            if((emailExceptionsList == null || emailExceptionsList.isEmpty())
                && (teamsExceptionsList == null || teamsExceptionsList.isEmpty())
                && (slackExceptionsList == null || slackExceptionsList.isEmpty())
                && (pagerDutyExceptionsList == null || pagerDutyExceptionsList.isEmpty())
                && (webhookExceptionsList == null || webhookExceptionsList.isEmpty())) {

                PermissionsUtil.putSObjectField(failedRecord, dfrNotificationIntegrationStatus, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_COMPLETED);
            }
            else if (hasOnlySlackRateLimitErrors) {
                // Keep status as PENDING for rate-limited records (don't mark as Failed)
                // This allows them to be retried when rate limit expires
                PermissionsUtil.putSObjectField(failedRecord, dfrNotificationIntegrationStatus, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING);
                
                // Still log the Slack rate limit status for visibility
                String slackExceptionValue = slackExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH);
                if(dfrSlackIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrSlackIntegrationStatus, slackExceptionValue);
                }
            }
            else {
                String emailExceptionValue = (emailExceptionsList != null && !emailExceptionsList.isEmpty())
                    ? emailExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH)
                    : null;
                String pagerDutyExceptionValue = (pagerDutyExceptionsList != null && !pagerDutyExceptionsList.isEmpty())
                    ? pagerDutyExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH)
                    : null;
                String slackExceptionValue = (slackExceptionsList != null && !slackExceptionsList.isEmpty())
                    ? slackExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH)
                    : null;
                String teamsExceptionValue = (teamsExceptionsList != null && !teamsExceptionsList.isEmpty())
                    ? teamsExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH)
                    : null;
                String webhookExceptionValue = (webhookExceptionsList != null && !webhookExceptionsList.isEmpty())
                    ? webhookExceptionsList.get(0).getMessage().abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH)
                    : null;
                if(dfrEmailIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrEmailIntegrationStatus, emailExceptionValue);
                }
                if(dfrPagerDutyIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrPagerDutyIntegrationStatus, pagerDutyExceptionValue);
                }
                if(dfrSlackIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrSlackIntegrationStatus, slackExceptionValue);
                }
                if(dfrTeamsIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrTeamsIntegrationStatus, teamsExceptionValue);
                }
                if(dfrWebhookIntegrationStatus != null) {
                    PermissionsUtil.putSObjectField(failedRecord, dfrWebhookIntegrationStatus, webhookExceptionValue);
                }
                PermissionsUtil.putSObjectField(failedRecord, dfrNotificationIntegrationStatus, Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_FAILED);
            }
            toUpdateRecordsMap.put(recordId, failedRecord);
        }
    }

    public static Messaging.SingleEmailMessage createEmailMessage(String recordId, Action__c action) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (action.EmailTemplateId__c != null && action.Contact__c != null) {
            mail.setTargetObjectId(action.Contact__c);
            mail.setTemplateId(action.EmailTemplateId__c);
            mail.setWhatId(recordId);
        }
        else {
            mail.setBccSender(false);
            mail.setUseSignature(false);
            List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.EmailBody__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
            mail.setSubject(mergedMessages.get(0));
            mail.setHtmlBody(mergedMessages.get(1));
            mail.setToAddresses(new List<String>{action.EmailTo__c});
        }
        if (action.EmailCC__c != null)  mail.setCcAddresses(new List<String>{action.EmailCC__c});
        return mail;
    }

    public static void sendEmail(List<Messaging.SingleEmailMessage> emailMessages) {
        // Test hook to simulate email limit errors
        if (Test.isRunningTest() && simulateEmailLimitError) {
            throw new System.EmailException('SendEmail failed. First exception on row 0; first error: SINGLE_EMAIL_LIMIT_EXCEEDED, Email limit exceeded.: []');
        }
        if (!Test.isRunningTest()) Messaging.sendEmail(emailMessages);
    }

    public static void sendTeams(String recordId, Action__c action) {
        // For two-parameter version, we need to query the record
        try {
            Schema.SObjectType recordType = getRecordSObjectType(recordId);
            if (recordType != null) {
                String query = 'SELECT Id FROM ' + recordType.getDescribe().getName() + ' WHERE Id = :recordId LIMIT 1';
                List<SObject> records = Database.query(query);
                if (!records.isEmpty()) {
                    sendTeams(recordId, action, records[0]);
                }
            }
        } catch (Exception e) {
            // Log error but don't fail the entire process
            Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'sendTeams');
        }
    }

    public static void sendTeams(String recordId, Action__c action, SObject record) {
        if(!PermissionsUtil.TeamsIntegrationEnabled || !ConfigUtil.GRAPH_API_SETTINGS.Enabled__c) {
            return;
        }

        GraphAPIService.GraphApiSetting settings = new GraphAPIService.GraphApiSetting(action.Team_Id__c, action.Channel_Id__c);
        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
        
        // Clean AutoChart fields from messages first
        AutoChart.AutoChartFieldsResult autoChartFieldsResult = AutoChart.getChartFieldsAndClear(mergedMessages);
        mergedMessages = autoChartFieldsResult.cleanedMessages;
        List<String> chartsTypeForPrepare = autoChartFieldsResult.autoChartFields;
        
        // Create chat message with cleaned content
        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);
        GraphAPIService.ChatMessage chatMessage = new GraphAPIService.ChatMessage(subject, body);

        // Only generate charts if AutoChart is enabled and chart fields were found
        if (autoChartFieldsResult?.autoChartFields.isEmpty() || !AutoChart.isEnabled) {
            GraphAPIService.sendChannelMessage(settings.teamId, settings.channelId, chatMessage);
        } else {
            if (record != null) {
                Map<String, Object> parameters = ReportService.parametersBySObjectRecord(record);
                Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = ReportService.getReportDataByChart(
                    chartsTypeForPrepare,
                    parameters
                );

                // Set metadata for error tracking
                Map<String, String> metadata = new Map<String, String>();
                if (record != null && String.isNotBlank(record.Id)) {
                    metadata.put('recordId', record.Id);
                }

                ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                    .setMetadata(metadata)
                    .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                chatMessage.addImagesByImageLambdaClient(chartGeneratorImageLambdaClient);
                GraphAPIService.sendChannelMessage(settings.teamId, settings.channelId, chatMessage);
            }
        }
    }

    public static void sendSlack(String recordId, Action__c action) {
        // For two-parameter version, we need to query the record
        try {
            Schema.SObjectType recordType = getRecordSObjectType(recordId);
            if (recordType != null) {
                String query = 'SELECT Id FROM ' + recordType.getDescribe().getName() + ' WHERE Id = :recordId LIMIT 1';
                List<SObject> records = Database.query(query);
                if (!records.isEmpty()) {
                    sendSlack(recordId, action, records[0]);
                }
            }
        } catch (Exception e) {
            // Log error but don't fail the entire process
            Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'sendSlack');
        }
    }

    public static void sendSlack(String recordId, Action__c action, SObject record) {
        sendSlack(recordId, action, record, null);
    }
    
    public static void sendSlack(String recordId, Action__c action, SObject record, BatchContextManager batchContext) {
        if(!PermissionsUtil.SlackIntegrationEnabled) {
            return;
        }
        
        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));

        AutoChart.AutoChartFieldsResult autoChartFieldsResult = AutoChart.getChartFieldsAndClear(mergedMessages);
        mergedMessages = autoChartFieldsResult.cleanedMessages;
        List<String> chartsTypeForPrepare = autoChartFieldsResult.autoChartFields;

        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);
        String message = subject + Constants.GLOBAL_VARIABLE.NEWLINE_CHARACTERS + body;
        
        // Only generate charts if AutoChart is enabled and chart fields were found
        if (autoChartFieldsResult?.autoChartFields.isEmpty() || !AutoChart.isEnabled) {
            SlackService.sendMessageToSlack(message, action.SlackChannels__c);
        } else {
            if (record != null) {
                // NEW: Check if chart data is already in batchContext
                String cachedChartData = getChartData(recordId, batchContext);
                Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData;
                
                if (String.isNotBlank(cachedChartData)) {
                    // Use cached data from batchContext
                    chartToChartData = (Map<ChartService.Chart, Map<ReportService.SystemReport, String>>) JSON.deserialize(cachedChartData, Map<ChartService.Chart, Map<ReportService.SystemReport, String>>.class);
                } else {
                    // Generate new chart data
                    Map<String, Object> parameters = ReportService.parametersBySObjectRecord(record);
                    chartToChartData = ReportService.getReportDataByChart(chartsTypeForPrepare, parameters);
                    
                    // Store in batchContext for future use
                    storeChartData(recordId, JSON.serialize(chartToChartData), batchContext);
                }

                // NEW: Check if chart images are already in batchContext
                Map<String, String> cachedImages = getChartImages(recordId, batchContext);
                ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient;
                
                if (cachedImages != null && !cachedImages.isEmpty()) {
                    // Use cached images from batchContext
                    chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient();
                    chartGeneratorImageLambdaClient.setChartImages(cachedImages);
                } else {
                    // Generate new images with metadata for error tracking
                    Map<String, String> metadata = new Map<String, String>();
                    if (String.isNotBlank(recordId)) {
                        metadata.put('recordId', recordId);
                    }
                    
                    chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                        .setMetadata(metadata)
                        .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                    
                    // Store images in batchContext for future use
                    Map<String, String> images = chartGeneratorImageLambdaClient.getChartImages();
                    storeChartImages(recordId, images, batchContext);
                }

                SlackService.sendMessageToSlackWithChartAttachments(message, action.SlackChannels__c, chartGeneratorImageLambdaClient);
            }
        }
    }

    public static void sendPagerDuty(String recordId, Action__c action) {
        if(!PermissionsUtil.PagerDutyIntegrationEnabled) {
            return;
        }

        List<String> mergedMessages = renderMergeFields(recordId, new List<String>{action.Subject__c, action.Body__c}, new NotificationService.MergeFieldSettings(action.Action_Type__c));
        
        // Clean AutoChart fields from messages
        AutoChart.AutoChartFieldsResult autoChartFieldsResult = AutoChart.getChartFieldsAndClear(mergedMessages);
        mergedMessages = autoChartFieldsResult.cleanedMessages;
        
        String subject = mergedMessages.get(0);
        String body = mergedMessages.get(1);

        if (action.PagerDuty_Type__c == 'Incident')
            PagerDutyService.createIncident(subject,  body);
        else if (action.PagerDuty_Type__c == 'Event')
            PagerDutyService.createEvent(recordId, subject,  body);
    }

    public static void sendTicketing(RuleUtil.ActionType actionType, EventAction__c eventAction, Logger logger, SObject record) {
        TicketingService service = new TicketingService(actionType, logger);
        TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(eventAction);
        TicketingService.TicketCreateResult newTicket = service.createTicket(data);
        
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Response__c, newTicket.id);
        PermissionsUtil.putSObjectField(eventAction, Schema.SObjectType.EventAction__c.fields.Delivered_to__c, newTicket.url);
        DatabaseUtils.getInstance().performUpdateDML(new List<EventAction__c>{eventAction}, Schema.SObjectType.EventAction__c)
            .handleError(NotificationService.class.getName(), '.sendTicketing', logger);
    }

    public static final String PREVENT_RECURSION_RESPONSE_MESSAGE = 'Prevent recursion';

    /**
     * Detect platform from Action_Type__c field
     * @param actionType The Action_Type__c value
     * @return Platform string ('SLACK', 'TEAMS', 'JIRA', 'AZURE_DEVOPS', 'EMAIL', 'PAGERDUTY')
     */
    public static String detectPlatformFromActionType(String actionType) {
        if (String.isBlank(actionType)) {
            return 'SLACK'; // Default fallback
        }
        
        // Map action types to platforms using string literals for reliability
        if (actionType == 'Slack Notification') {
            return 'SLACK';
        } else if (actionType == 'Teams Notification') {
            return 'TEAMS';
        } else if (actionType == 'Jira Notification' || actionType == 'JIRA Ticket Comment') {
            return 'JIRA';
        } else if (actionType == 'Azure Dev Ops Notification' || actionType == 'Azure Dev Ops Work Item Comment') {
            return 'AZURE_DEVOPS';
        } else if (actionType == 'Email Notification') {
            return 'EMAIL';
        } else if (actionType == 'PagerDuty Notification') {
            return 'PAGERDUTY';
        } else {
            return 'SLACK'; // Default fallback
        }
    }

    public static final Map<Schema.SObjectType, List<String>> BATCH_LOCATOR_ADDITIONAL_FIELDS_BY_SOBJECT_TYPE = new Map<Schema.SObjectType, List<String>>{
        Log__c.SObjectType => new List<String> {
            'Hash_1__c','Organization_Id__c','Bug_Tracker__c','Hash_2__c','Hash_3__c','Jira_Integration_Status__c',
            'Notification_Integration_Status__c', 'Executable_Rules__c', 'Issue__r.Name'
        },
        Issue__c.SObjectType => new List<String> {
            'Name',
            'Description__c', 'Summary__c', 'Key__c', 'Bug_Tracker__c','Jira_Integration_Status__c',
            'Notification_Integration_Status__c', 'Executable_Rules__c'},
        Trace_Result__c.SObjectType => new List<String> {
            'Notification_Integration_Status__c', 'Issue__c', 'Executable_Rules__c'
        }
    };

    private static final Map<NOTIFICATION_SERVICE_TYPE, NotificationServiceInterface> TYPE_TO_SERVICE = new Map<NOTIFICATION_SERVICE_TYPE, NotificationServiceInterface>{
        NOTIFICATION_SERVICE_TYPE.LOG => new NotificationServiceLogImpl(),
        NOTIFICATION_SERVICE_TYPE.ISSUE => new NotificationServiceIssueImpl(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => new NotificationServiceTraceResultImpl(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => new NotificationServiceEventActionImpl()
    };

    public static final Map<NOTIFICATION_SERVICE_TYPE, String> BATCH_SERVICE_MAPPING_BY_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, String>{
        NOTIFICATION_SERVICE_TYPE.LOG => JiraNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.ISSUE => IssueNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => TraceResultNotificationBatch.class.getName(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => NotificationBatch.class.getName()
    };

    public static final Map<NOTIFICATION_SERVICE_TYPE, Schema.SObjectType> SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, Schema.SObjectType>{
        NOTIFICATION_SERVICE_TYPE.LOG => Log__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.ISSUE => Issue__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => Trace_Result__c.SObjectType,
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => EventAction__c.SObjectType
    };

    private static final Map<String, NotificationServiceInterface> TYPE_TO_SERVICE_BY_NAME = new Map<String, NotificationServiceInterface>{
        JiraNotificationBatch.class.getName() => new NotificationServiceLogImpl(),
        IssueNotificationBatch.class.getName() => new NotificationServiceIssueImpl(),
        TraceResultNotificationBatch.class.getName() => new NotificationServiceTraceResultImpl(),
        NotificationBatch.class.getName() => new NotificationServiceEventActionImpl()
    };

    public static final Map<NOTIFICATION_SERVICE_TYPE, String> RULE_SOBJECT_TYPE_MAPPING_BY_SERVICE_TYPE = new Map<NOTIFICATION_SERVICE_TYPE, String>{
        NOTIFICATION_SERVICE_TYPE.LOG => null, // default null
        NOTIFICATION_SERVICE_TYPE.ISSUE => Schema.SObjectType.Issue__c.getName(),
        NOTIFICATION_SERVICE_TYPE.TRACE_RESULT => Schema.SObjectType.Trace_Result__c.getName(),
        NOTIFICATION_SERVICE_TYPE.EVENT_ACTION => null
    };


    public static Boolean isBroadcastLog(Log__c newLog, Log__c oldLog) {
        if(newLog.Originated_From__c == ConfigUtil.ORIGINATED_FROM_BROADCAST && oldLog == null) {
            return true;
        }
        return false;
    }

    public static Boolean isInternalErrorLog(Log__c newLog, Log__c oldLog) {
        if(newLog.Category__c == Logger.CATEGORY_PHAROS_ERROR && newLog.Area__c == Logger.AREA_PHAROS_ERROR) {
            return true;
        }
        return false;
    }

    public static Boolean isRegularErrorLogPostprocessingCompleted(Log__c newLog, Log__c oldLog) {
        if(newLog.Type__c != Constants.FLOW.FLOW_TYPE_ORCHESTRATOR && oldLog != null && newLog.Post_Processing_Status__c != oldLog.Post_Processing_Status__c
            && newLog.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Issue__c newIssue, Issue__c oldIssue) {
        if(newIssue.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningNotifications(Log__c newLog, Log__c oldLog) {
        if(newLog.Notification_Integration_Status__c == Constants.GLOBAL_VARIABLE.NOTIFICATION_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static Boolean isRunningTicketing(Log__c newLog, Log__c oldLog) {
        if(newLog.Jira_Integration_Status__c == Constants.GLOBAL_VARIABLE.JIRA_INTEGRATION_STATUS_PENDING) {
            return true;
        }
        return false;
    }

    public static List<String> renderMergeFields(String objId, List<String> messages, MergeFieldSettings settings) {
        return (new MergeFields(new Map<String, MergeFieldSettings>{
                objId => settings
        })).parse(objId, messages);
    }

    public static Map<String, List<String>> renderMergeFields(Map<String, List<String>> contentsMap) {
        return (new MergeFields()).parse(contentsMap);
    }

    public static Map<String, List<String>> renderMergeFields(Map<String, List<String>> contentsMap, Map<String, MergeFieldSettings> mergeFieldSettingsMap) {
        return (new MergeFields(mergeFieldSettingsMap)).parse(contentsMap);
    }

    public enum NotificationContext {
        EMAIL,
        SLACK,
        JIRA,
        TEAMS,
        AZURE_DEV_OPS,
        PAGERDUTY,
        WEBHOOK
    }

    public static final Map<String, NotificationContext> MAP_NOTIFICATION_CONTEXTS_BY_ACTION_TYPE = new Map<String, NotificationContext> {
            Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION => NotificationContext.EMAIL,
            Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION => NotificationContext.SLACK,
            Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_NOTIFICATION => NotificationContext.JIRA,
            Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_TICKET_COMMENT => NotificationContext.JIRA,
            Constants.ACTION_SOBJECT.ACTION_TYPE_TEAMS_NOTIFICATION => NotificationContext.TEAMS,
            Constants.ACTION_SOBJECT.ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION => NotificationContext.AZURE_DEV_OPS,
            Constants.ACTION_SOBJECT.ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT => NotificationContext.AZURE_DEV_OPS,
            Constants.ACTION_SOBJECT.ACTION_TYPE_PAGERDUTY_NOTIFICATION => NotificationContext.PAGERDUTY,
            Constants.ACTION_SOBJECT.ACTION_TYPE_WEBHOOK_NOTIFICATION => NotificationContext.WEBHOOK
    };

    public class MergeFieldSettings {
        public final NotificationContext notificationContext;
        public final Boolean useADFFormat;

        public MergeFieldSettings() {
            this.useADFFormat = false;
        }

        public MergeFieldSettings(String actionType) {
            notificationContext = MAP_NOTIFICATION_CONTEXTS_BY_ACTION_TYPE.get(actionType);
            this.useADFFormat = (notificationContext == NotificationService.NotificationContext.JIRA && JiraService.isCloudJiraInstance());
        }
        
        public MergeFieldSettings(String actionType, Boolean useADFFormat) {
            notificationContext = MAP_NOTIFICATION_CONTEXTS_BY_ACTION_TYPE.get(actionType);
            this.useADFFormat = useADFFormat;
        }
    }

    public with sharing class MergeFields {
        private final Map<String, MergeFieldSettings> mergeFieldSettingsMap;

        public MergeFields(){
            this(new Map<String, MergeFieldSettings>());
        }

        public MergeFields(Map<String, MergeFieldSettings> mergeFieldSettingsMap) {
            this.mergeFieldSettingsMap = mergeFieldSettingsMap;
        }

        public List<String> parse(String objId, List<String> contents) {
            return parse(new Map<String, List<String>>{
                objId => contents
            }).get(objId);
        }

        public Map<String, List<String>> parse(Map<String, List<String>> contentsMap) {
            Map<String, List<String>> result = new Map<String, List<String>>();
            Set<String> allFields = new Set<String>();

            Set<String> ids = contentsMap?.keySet();
            String objectAPIName = (!ids.isEmpty()) ? getObjectAPI((new List<String>(ids)).get(0)) : null;
            for (List<String> contentList : contentsMap?.values()) {
                if (contentList != null) {
                    for (String content : contentList) {
                        if (String.isNotBlank(content)) {
                            allFields.addAll(getFields(content, objectAPIName));
                        }
                    }
                }
            }

            if (String.isNotBlank(objectAPIName) && !allFields.isEmpty()) {
                Boolean needMergeAnalysis = false;
                Set<String> filteredFields = new Set<String>();
                for (String field : allFields) {
                    if (field.endsWith('.Link')) {
                        filteredFields.add(field.removeEnd('.Link'));
                    } else if (field == 'Analysis') {
                        needMergeAnalysis = true;
                    } else if (field != 'Link') {
                        filteredFields.add(field);
                    }
                }
                AIAnalysis analysis = needMergeAnalysis ? getAIAnalysis(ids) : null;
                String query = new QBuilder(objectAPIName)
                    .selectFields(filteredFields)
                    .add(QBuilder.condition('Id').isIn(':ids'))
                    .build();
                for (SObject obj : Database.query(query)) {
                    String objId = (String)obj.get('Id');
                    List<String> contents = contentsMap.get(objId);
	                String context;
	                Boolean useADFFormat = false;
	                if (this.mergeFieldSettingsMap?.containsKey(objId)) {
		                context = this.mergeFieldSettingsMap.get(objId).notificationContext.name();
		                useADFFormat = this.mergeFieldSettingsMap.get(objId).useADFFormat;
	                }
                    Map<String, String> tempMap = new Map<String, String>();
                    for (String field : allFields) {
                        if (field == 'Link') {
                            tempMap.put(field, formatLinkField(objId));
                        } else if (field.endsWith('.Link')) {
                            tempMap.put(field, formatLinkField(String.valueOf(getFieldValue(obj, field.removeEnd('.Link')))));
                        } else if (field == 'Analysis' && analysis != null && String.isNotBlank(context)) {
	                        if (useADFFormat) {
		                        tempMap.put(field, analysis.getFormattedDataADF(objId, 'JIRA_ADF'));
	                        } else {
		                        tempMap.put(field, analysis.getFormattedData(objId, context));
	                        }
                        } else {
                            tempMap.put(field, String.valueOf(getFieldValue(obj, field)));
                        }
                    }
                    List<String> contentList = new List<String>();

	                if (useADFFormat) {
		                if (!contents.isEmpty() && contents.size() > 0) {
			                contentList.add(matchContent(contents[0], tempMap, objectAPIName));
		                }
		                if (!contents.isEmpty() && contents.size() > 1) {
			                contentList.add(matchContentADF(contents[1], tempMap, objectAPIName));
		                }
	                } else {
		                for (String content : contents) {
			                contentList.add(matchContent(content, tempMap, objectAPIName));
		                }
	                }
                    result.put(objId, contentList);
                }
            }
            else if (String.isNotBlank(objectAPIName) && allFields.isEmpty()) {
                result = contentsMap;
            }
            return result;
        }

        private final String ADO_LINK_FORMAT = '<a href=\"{0}\" target=\"_blank\">{0}</a>';
        private final String TEAMS_LINK_FORMAT = '<a href=\"{0}\" target=\"_blank\">{0}</a>';

        private String formatLinkField(String objId) {
            if(String.isNotBlank(objId)) {
                String link = Constants.GLOBAL_VARIABLE.BASE_URL + '/' + objId;
                
                // Check if we should return ADF format for JIRA
                if (this.mergeFieldSettingsMap?.containsKey(objId)) {
                    MergeFieldSettings settings = this.mergeFieldSettingsMap.get(objId);
                    
                    if (settings.useADFFormat && settings.notificationContext == NotificationService.NotificationContext.JIRA) {
                        // Return raw URL for ADF processing - will be converted to ADF link node later
                        return link;
                    }
                    else if (settings.notificationContext == NotificationService.NotificationContext.AZURE_DEV_OPS) {
                        link = String.format(ADO_LINK_FORMAT, new List<String>{link});
                    }
                    else if (settings.notificationContext == NotificationService.NotificationContext.TEAMS) {
                        link = String.format(TEAMS_LINK_FORMAT, new List<String>{link});
                    }
                }
                return link;
            }
            return '';
        }

	    private AIAnalysis getAIAnalysis(Set<String> ids) {
		    AIAnalysis analysis = AIAnalysis.getInstance(ids);
		    if (analysis != null) {
			    analysis.init();
			    analysis.setVersionData();
		    }
		    return analysis;
	    }

        public Object getFieldValue(SObject entity, String fieldName) {
            if(entity == null) {
                return null;
            }

            if(fieldName.contains('.')) {
                return getFieldValue(entity.getSObject(fieldName.substringBefore('.')), fieldName.substringAfter('.'));
            }
            else {
                return entity.get(fieldName);
            }
        }


        private Set<String> getFields(String content, String objectAPIName) {
            Set<String> fieldAPINames = new Set<String>();
            String markerStart = '{!' + objectAPIName + '.';
            String markerEnd = '}';
            Integer startIndex = content.indexOf(markerStart);
    
            while (startIndex != -1) {
                Integer endIndex = content.indexOf(markerEnd, startIndex + markerStart.length());
                if (endIndex != -1) {
                    String mergeField = content.substring(startIndex + markerStart.length(), endIndex);
                    fieldAPINames.add(mergeField);
                    startIndex = content.indexOf(markerStart, endIndex + markerEnd.length());
                }
                else {
                    break;
                }
            }
    
            return fieldAPINames;
        }

	    private String matchContent(String content, Map<String, String> objValues, String objectAPIName) {
		    if (content == null) return '';
		    for (String keyFieldName : objValues.keySet()) {
			    String fieldValue = objValues.get(keyFieldName);
			    fieldValue = fieldValue == null ? '' : fieldValue;
			    String fullName = '{!' + objectAPIName + '.' + keyFieldName + '}';
			    content = content.replace(fullName, fieldValue);
		    }
		    return content;
	    }

	    private String matchContentADF(String content, Map<String, String> objValues, String objectAPIName) {
		    ADFBuilder builder = new ADFBuilder();

		    if (String.isBlank(content)) {
			    return builder.buildJSON();
		    }

		    if (content == null) {
			    content = '';
		    }

		    String markerStart = '{!' + objectAPIName + '.';
		    String markerEnd = '}';

		    Integer pos = 0;
		    Integer len = content.length();

		    while (pos < len) {
			    Integer start = content.indexOf(markerStart, pos);
			    if (start == -1) {
				    String tail = content.substring(pos);
				    if (String.isNotBlank(tail)) {
					    builder.addText(tail);
				    }
				    break;
			    }

			    if (start > pos) {
				    String before = content.substring(pos, start);
				    if (String.isNotBlank(before)) {
					    builder.addText(before);
				    }
			    }

			    Integer valueStart = start + markerStart.length();
			    Integer valueEnd = content.indexOf(markerEnd, valueStart);
			    if (valueEnd == -1) {
				    String rest = content.substring(start);
				    builder.addText(rest);
				    break;
			    }

			    String fieldName = content.substring(valueStart, valueEnd);
			    String fieldValue = objValues.get(fieldName);
			    fieldValue = fieldValue == null ? '' : fieldValue;
			    if ('Analysis'.equalsIgnoreCase(fieldName) && String.isNotBlank(fieldValue)) {
				    try {
					    Map<String, Object> adfDoc =
							    (Map<String, Object>) JSON.deserializeUntyped(fieldValue);
					    builder.appendDoc(adfDoc);
				    } catch (Exception e) {
					    builder.addText(fieldValue);
				    }
			    }
			    else if ('Link'.equalsIgnoreCase(fieldName) && String.isNotBlank(fieldValue)) {
				    builder.addLink(fieldValue, null);
			    }
			    else {
				    builder.addText(fieldValue);
			    }

			    pos = valueEnd + markerEnd.length();
		    }

		    return builder.buildJSON();
	    }

        private String getObjectAPI(String recordId) {
            String keyCode  = recordId.subString(0,3);
            Map<String, Schema.SObjectType> gd = ConfigUtil.MAP_GD;
            for(Schema.SObjectType objectInstance : gd.values()) {
                if(objectInstance.getDescribe().getKeyPrefix() != null && objectInstance.getDescribe().getKeyPrefix().equals(keyCode)) {
                    return objectInstance.getDescribe().getName();
                }
            }
            return null;
        }

    }

    public static ExecutableRulesConfig getExecutableRuleConfig(SObject sObjectRecord) {
        ExecutableRulesConfig result = new ExecutableRulesConfig();
        String executableRulesValue = '';
        try {
            executableRulesValue = String.valueOf(sObjectRecord.get('Executable_Rules__c'));
        }
        catch(Exception e) {}
        
        if(String.isBlank(executableRulesValue)) {
            return result;
        }
        else if (executableRulesValue.startsWith('[')) {
            List<String> oldRuleIds = new List<String>();
            try {
                oldRuleIds = (List<String>)JSON.deserialize(executableRulesValue, List<String>.class);
            }
            catch(Exception e){}
            result.init();
            result.a.addAll(oldRuleIds);
        }
        else if (executableRulesValue.startsWith('{')) {
            try {
                result = (ExecutableRulesConfig)JSON.deserialize(executableRulesValue, ExecutableRulesConfig.class);
                result.init();
            }
            catch(Exception e){}
        }
        else {
            return result;
        }
        return result;
    }

    public class ExecutableRulesConfig {
        // rule Ids to run
        public Set<String> r;
        // rule Ids for re-run (ticketing rules)
        public Set<String> rr;
        // all rule Ids
        public Set<String> a;
        // completed action IDs (minimal storage for duplicate prevention)
        public Set<String> c;

        public ExecutableRulesConfig() {
            this.r = new Set<String>();
            this.rr = new Set<String>();
            this.a = new Set<String>();
            this.c = new Set<String>();
        }



        public void init() {
            if(this.r == null) {
                this.r = new Set<String>();
            }
            if(this.rr == null) {
                this.rr = new Set<String>();
            }
            if(this.a == null) {
                this.a = new Set<String>();
            }
            if(this.c == null) {
                this.c = new Set<String>();
            }
        }

        public void addToRun(Set<String> ruleIds) {
            this.r.addAll(ruleIds);
            this.a.addAll(ruleIds);
        }

        public void addToReRun(Set<String> ruleIds) {
            this.rr.addAll(ruleIds);
            this.a.addAll(ruleIds);
        }

        public void addToRun(String ruleId) {
            this.r.add(ruleId);
            this.a.add(ruleId);
        }

        public void addToReRun(String ruleId) {
            this.rr.add(ruleId);
            this.a.add(ruleId);
        }

        public Set<String> getAllExecutedRuleIds() {
            return this.a;
        }

        public Set<String> getRuleIdsToRun() {
            return this.r;
        }

        public Set<String> getRuleIdsToReRun() {
            return this.rr;
        }

        public Set<String> getAllRuleIdsToRun() {
            Set<String> all =new Set<String>();
            all.addAll(this.r);
            all.addAll(this.rr);
            return all;
        }

        public void clearRunningIds() {
            this.r = new Set<String>();
            this.rr = new Set<String>();
        }

        public String toJSON() {
            return JSON.serialize(this);
        }

        public void mergeConfig(ExecutableRulesConfig configToMerge) {
            if(!configToMerge?.r?.isEmpty()) {
                this.r.addAll(configToMerge.r);
            }
            if(!configToMerge?.rr?.isEmpty()) {
                this.rr.addAll(configToMerge.rr);
            }
            if(!configToMerge?.a?.isEmpty()) {
                this.a.addAll(configToMerge.a);
            }
            if(!configToMerge?.c?.isEmpty()) {
                this.c.addAll(configToMerge.c);
            }
        }

        // Minimal action completion tracking (for duplicate prevention only)
        public void markActionCompleted(String actionId) {
            if (String.isNotBlank(actionId)) {
                this.c.add(actionId);
            }
        }

        public Boolean isActionCompleted(String actionId) {
            return String.isNotBlank(actionId) && this.c.contains(actionId);
        }

        public Boolean hasCompletedActions() {
            return !this.c.isEmpty();
        }

        public List<String> getCompletedActions() {
            return new List<String>(this.c);
        }

        public void clearCompletedActions() {
            this.c.clear();
        }

        public Boolean hasCompletedAction(String actionId) {
            return isActionCompleted(actionId);
        }

        // Context-aware Slack action processing (use runtime context instead of stored types)
        public Boolean hasSlackActionsToProcess(List<RuleUtil.Action> actions) {
            if (actions == null) return false;
            
            for (RuleUtil.Action action : actions) {
                if (action.type.equals(Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION)
                    && !isActionCompleted(action.id)) {
                    return true;
                }
            }
            return false;
        }

        public List<String> getPendingSlackActions(List<RuleUtil.Action> actions) {
            List<String> pendingSlackActions = new List<String>();
            if (actions == null) return pendingSlackActions;
            
            for (RuleUtil.Action action : actions) {
                if (action.type.equals(Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION)
                    && !isActionCompleted(action.id)) {
                    pendingSlackActions.add(action.id);
                }
            }
            return pendingSlackActions;
        }
    }

    // Simplified state management utility methods
    public static void persistActionState(String recordId, ExecutableRulesConfig config) {
        if (String.isBlank(recordId) || config == null) {
            return;
        }
        
        try {
            // Update transaction cache only - DML will be handled by createErrors method
            mapConfigsInTransaction.put(recordId, config);
                           
        } catch (Exception e) {
            // Log error but don't fail the entire process
            Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'persistActionState');
        }
    }
    
    private static Schema.SObjectType getRecordSObjectType(String recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }
        
        String keyPrefix = recordId.substring(0, 3);
        
        // Check common types
        if (keyPrefix == Log__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Log__c.SObjectType;
        } else if (keyPrefix == Issue__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Issue__c.SObjectType;
        } else if (keyPrefix == Trace_Result__c.SObjectType.getDescribe().getKeyPrefix()) {
            return Trace_Result__c.SObjectType;
        }
        
        // Default to Log__c if unknown
        return Log__c.SObjectType;
    }

    // Action iteration tracking for custom iterator
    public virtual class ActionIteration {
        public String recordId;
        public Integer iterationNumber;
        public Integer totalIterations;
        public String actionType;
        public String actionId;
        
        public ActionIteration(String recordId, Integer iterationNumber, Integer totalIterations) {
            this.recordId = recordId;
            this.iterationNumber = iterationNumber;
            this.totalIterations = totalIterations;
        }
        
        public ActionIteration(String recordId, Integer iterationNumber, Integer totalIterations, String actionType, String actionId) {
            this(recordId, iterationNumber, totalIterations);
            this.actionType = actionType;
            this.actionId = actionId;
        }
    }
    

    

    
    /**
     * Interface for handling different types of notification actions
     */
    public interface ActionHandler {
        void execute(String recordId, Action__c actionFields);
        void execute(String recordId, Action__c actionFields, SObject record);
        void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext);
        void handleException(String recordId, Exception e, ErrorsHelper logErrors);
        void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext);
        String getActionType();
    }


    /**
     * Centralized exception handling utility for notification actions
     */
    public class ActionExceptionHandler {
        public void executeWithExceptionHandling(
            ActionHandler handler, 
            String recordId, 
            Action__c actionFields, 
            SObject record,
            ErrorsHelper logErrors
        ) {
            try {
                handler.execute(recordId, actionFields, record);
            } catch (Exception e) {
                handler.handleException(recordId, e, logErrors);
                // Re-throw the exception so outer code can detect the failure
                throw e;
            }
        }

        public void executeWithExceptionHandling(
            ActionHandler handler,
            String recordId,
            Action__c actionFields,
            ErrorsHelper logErrors,
            BatchContextManager batchContextManager
        ) {
            try {
                handler.execute(recordId, actionFields, null, batchContextManager);
            } catch (Exception e) {
                handler.handleException(recordId, e, logErrors, batchContextManager);
                // Re-throw the exception so outer code can detect the failure
                throw e;
            }
        }

        public void executeWithExceptionHandling(
            ActionHandler handler,
            String recordId,
            Action__c actionFields,
            SObject record,
            ErrorsHelper logErrors,
            BatchContextManager batchContextManager
        ) {
            try {
                handler.execute(recordId, actionFields, record, batchContextManager);
            } catch (Exception e) {
                handler.handleException(recordId, e, logErrors, batchContextManager);
                // Re-throw the exception so outer code can detect the failure
                throw e;
            }
        }
    }

    /**
     * Email notification action handler
     * Note: Email actions are handled differently since they need to be collected and sent in batches
     */
    public class EmailActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            // Email actions are handled separately in sendNotifications method
            // This handler is for consistency but actual execution happens elsewhere
        }

        public void execute(String recordId, Action__c actionFields, SObject record) {
            // Email actions are handled separately in sendNotifications method
            // This handler is for consistency but actual execution happens elsewhere
        }

        public void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext) {
            // Email actions are handled separately in sendNotifications method
            // This handler is for consistency but actual execution happens elsewhere
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.emailExceptions.get(recordId) != null
                ? logErrors.emailExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.emailExceptions.put(recordId, exceptions);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext) {
            // Use the existing exception handling
            handleException(recordId, e, logErrors);
        }

        public String getActionType() {
            return Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION;
        }
    }

    /**
     * Slack notification action handler
     */
    public class SlackActionHandler implements ActionHandler {

        public void execute(String recordId, Action__c actionFields) {
            // SlackService.sendMessageToSlack() already handles rate limiting internally
            sendSlack(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record) {

            // SlackService.sendMessageToSlack() already handles rate limiting internally
            sendSlack(recordId, actionFields, record);
        }

        public void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext) {
            // Track the Slack action attempt
            if (batchContext != null && batchContext instanceof BaseBatchContextManager) {
                ((BaseBatchContextManager) batchContext).trackSlackAction(recordId);
            }

            try {
                // Use parameter-based sendSlack method with batchContext
                sendSlack(recordId, actionFields, record, batchContext);

                // Track successful Slack action
                if (batchContext != null && batchContext instanceof BaseBatchContextManager) {
                    ((BaseBatchContextManager) batchContext).trackSlackSuccess(recordId);
                }
            } catch (Exception e) {
                // Track failed Slack action and check for rate limiting
                if (batchContext != null && batchContext instanceof BaseBatchContextManager) {
                    BaseBatchContextManager batchManager = (BaseBatchContextManager) batchContext;

                    // Check if this is a rate limit exception
                    String errorMessage = e.getMessage();
                    if (errorMessage != null && errorMessage.toLowerCase().contains('rate limit')) {
                        // Extract retry time from error message if available
                        DateTime retryAfter = null;
                        if (errorMessage.contains('Retry after:')) {
                            // Simple parsing - could be enhanced
                            try {
                                List<String> parts = errorMessage.split('Retry after:');
                                if (parts.size() > 1) {
                                    String timeStr = parts[1].trim().split(' ')[0];
                                    Integer seconds = Integer.valueOf(timeStr);
                                    retryAfter = DateTime.now().addSeconds(seconds);
                                }
                            } catch (Exception parseEx) {
                                // Use default retry time if parsing fails
                                retryAfter = DateTime.now().addSeconds(60);
                            }
                        }

                        batchManager.trackSlackRateLimit(recordId, errorMessage, retryAfter);
                    } else {
                        batchManager.trackSlackFailure(recordId);
                    }
                }

                // Re-throw for normal error handling
                throw e;
            }
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.slackExceptions.get(recordId) != null
                ? logErrors.slackExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.slackExceptions.put(recordId, exceptions);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext) {
            // Use the existing exception handling
            handleException(recordId, e, logErrors);
        }

        public String getActionType() {
            return Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION;
        }
    }

    /**
     * Teams notification action handler
     */
    public class TeamsActionHandler implements ActionHandler {

        public void execute(String recordId, Action__c actionFields) {
            sendTeams(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record) {
            sendTeams(recordId, actionFields, record);
        }

        public void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext) {
            sendTeams(recordId, actionFields, record);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.teamsExceptions.get(recordId) != null
                ? logErrors.teamsExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.teamsExceptions.put(recordId, exceptions);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext) {
            // Use the existing exception handling
            handleException(recordId, e, logErrors);
        }

        public String getActionType() {
            return Constants.ACTION_SOBJECT.ACTION_TYPE_TEAMS_NOTIFICATION;
        }
    }

    /**
     * PagerDuty notification action handler
     */
    public class PagerDutyActionHandler implements ActionHandler {
        public void execute(String recordId, Action__c actionFields) {
            sendPagerDuty(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext) {
            sendPagerDuty(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record) {
            sendPagerDuty(recordId, actionFields);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.pagerDutyExceptions.get(recordId) != null
                ? logErrors.pagerDutyExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.pagerDutyExceptions.put(recordId, exceptions);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext) {
            // Use the existing exception handling
            handleException(recordId, e, logErrors);
        }

        public String getActionType() {
            return Constants.ACTION_SOBJECT.ACTION_TYPE_PAGERDUTY_NOTIFICATION;
        }
    }

    /**
     * Webhook notification action handler
     * Supports custom HTTP webhooks with configurable URL, headers, body, and authentication
     */
    public class WebhookActionHandler implements ActionHandler {
        public Map<Id, WebhookService.WebhookResponse> webhookResponses = new Map<Id, WebhookService.WebhookResponse>();

        public void execute(String recordId, Action__c actionFields) {
            sendWebhook(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record) {
            sendWebhook(recordId, actionFields);
        }

        public void execute(String recordId, Action__c actionFields, SObject record, BatchContextManager batchContext) {
            sendWebhook(recordId, actionFields);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors) {
            List<System.Exception> exceptions = logErrors.webhookExceptions.get(recordId) != null
                ? logErrors.webhookExceptions.get(recordId)
                : new List<System.Exception>();
            exceptions.add(e);
            logErrors.webhookExceptions.put(recordId, exceptions);
        }

        public void handleException(String recordId, Exception e, ErrorsHelper logErrors, BatchContextManager batchContext) {
            // Use the existing exception handling
            handleException(recordId, e, logErrors);
        }

        public String getActionType() {
            return Constants.ACTION_SOBJECT.ACTION_TYPE_WEBHOOK_NOTIFICATION;
        }

        private void sendWebhook(String recordId, Action__c actionFields) {
            if (!PermissionsUtil.WebhookIntegrationEnabled) {
                return;
            }

            try {
                // Build webhook configuration from action fields
                WebhookService.WebhookConfig config = WebhookService.buildConfigFromAction(actionFields);

                // Send webhook
                WebhookService.WebhookResponse response = WebhookService.sendWebhook(recordId, config);

                // Store response for potential debugging
                webhookResponses.put(recordId, response);

                // Throw exception if webhook failed
                if (!response.success) {
                    throw new WebhookService.WebhookException(
                        'Webhook failed: ' + response.errorMessage
                    );
                }

            } catch (Exception e) {
                // Log error
                Logger.getInstance()?.addInternalError(
                    e,
                    NotificationService.class.getName(),
                    'sendWebhook'
                );
                throw e; // Re-throw for error handling
            }
        }
    }

    /**
     * Registry for managing standard notification action handlers
     * 
     * Standard Handlers:
     * - EmailActionHandler: Email notifications
     * - SlackActionHandler: Slack messaging
     * - TeamsActionHandler: Microsoft Teams integration
     * - PagerDutyActionHandler: PagerDuty incident management
     * 
     * NOTE: AutoChart handlers are NOT registered here!
     * AutoChart uses its own internal handler management:
     * - AutoChart.AutoChartActionProcessor manages the 3-step workflow
     * - Local handler map: GET_DATA -> GET_IMAGE -> SEND_MESSAGE
     * - No need for global registry registration
     */
    public class ActionHandlerRegistry {
        private Map<String, ActionHandler> handlers = new Map<String, ActionHandler>();
        
        public ActionHandlerRegistry() {
            // Register standard notification handlers
            registerHandler(new EmailActionHandler());
            registerHandler(new SlackActionHandler());
            registerHandler(new TeamsActionHandler());
            registerHandler(new PagerDutyActionHandler());
            registerHandler(new WebhookActionHandler());
            
            // NOTE: AutoChart handlers are NOT registered here
            // They are managed internally by AutoChart.AutoChartActionProcessor
            // which has its own local handler map for the 3-step workflow
        }
        
        private void registerHandler(ActionHandler handler) {
            handlers.put(handler.getActionType(), handler);
        }
        
        public ActionHandler getHandler(String actionType) {
            return handlers.get(actionType);
        }
        
        public Boolean hasHandler(String actionType) {
            return handlers.containsKey(actionType);
        }
        
        public Set<String> getSupportedActionTypes() {
            return handlers.keySet();
        }
    }

    /**
     * Centralized action processor that replaces duplicate switch statement logic
     * Enhanced with rate limiting support
     */
    public with sharing class ActionProcessor {
        private String recordId;
        private ErrorsHelper logErrors;
        private ActionHandlerRegistry registry;
        private ActionExceptionHandler exceptionHandler;
        private ExecutableRulesConfig config;
        private SObject record; // Add record reference to load config from database
        private BatchContextManager batchContextManager;

        public ActionProcessor(String recordId, ErrorsHelper logErrors) {
            this.recordId = recordId;
            this.logErrors = logErrors;
            this.registry = new ActionHandlerRegistry();
            this.exceptionHandler = new ActionExceptionHandler();
            
            // Get config from transaction cache first
            this.config = mapConfigsInTransaction.get(recordId);
            if (this.config == null) {
                // Fallback: try to get the record and load config from Executable_Rules__c field
                this.config = loadConfigFromRecord(recordId);
            }
        }
        
        /**
         * Constructor that accepts the record directly (more efficient)
         */
        public ActionProcessor(String recordId, ErrorsHelper logErrors, SObject record) {
            this.recordId = recordId;
            this.logErrors = logErrors;
            this.registry = new ActionHandlerRegistry();
            this.exceptionHandler = new ActionExceptionHandler();
            this.record = record;
            
            // Get config from transaction cache first
            this.config = mapConfigsInTransaction.get(recordId);
            if (this.config == null) {
                // Load config from the provided record
                this.config = NotificationService.getExecutableRuleConfig(record);
            }
        }
        
        /**
         * Constructor that accepts batch context manager for rate limit tracking
         */
        public ActionProcessor(String recordId, ErrorsHelper logErrors, SObject record, BatchContextManager batchContextManager) {
            this(recordId, logErrors, record);
            this.batchContextManager = batchContextManager;
        }

        /**
         * Load configuration from record in database
         */
        private ExecutableRulesConfig loadConfigFromRecord(String recordId) {
            try {
                // Determine record type and query appropriately
                Schema.SObjectType recordType = getRecordSObjectType(recordId);
                if (recordType == null) {
                    return new ExecutableRulesConfig(); // Fallback to empty config
                }
                
                String query = 'SELECT Id, Executable_Rules__c FROM ' + recordType.getDescribe().getName() + ' WHERE Id = :recordId LIMIT 1';
                List<SObject> records = Database.query(query);
                
                if (!records.isEmpty()) {
                    return NotificationService.getExecutableRuleConfig(records[0]);
                }
            } catch (Exception e) {
                // Log error but don't fail the entire process
                Logger.getInstance()?.addInternalError(e, NotificationService.class.getName(), 'loadConfigFromRecord');
            }
            
            // Fallback to empty config if record not found or error occurred
            return new ExecutableRulesConfig();
        }
        
        /**
         * Process a single action using the appropriate handler with rate limit awareness
         */
        public void processAction(RuleUtil.Action action) {
            ActionHandler handler = registry.getHandler(action.type);
            if (handler != null) {
                exceptionHandler.executeWithExceptionHandling(handler, this.recordId, action.fields, this.record, this.logErrors, this.batchContextManager);
            }
        }

        /**
         * Process actions with Slack iteration strategy enhanced with rate limiting support
         */
        public List<Messaging.SingleEmailMessage> processActionsWithSlackStrategy(
            List<RuleUtil.Action> actions,
            Boolean includeAllSlackActions
        ) {
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            Boolean slackActionProcessed = false;
            
            for (RuleUtil.Action action : actions) {
                String actionType = action.type;
                
                if (actionType.equals(Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION)) {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.id)) {
                        continue; // Skip already completed actions
                    }
                    
                    Boolean shouldProcessSlackAction = includeAllSlackActions || !slackActionProcessed;
                    if (shouldProcessSlackAction) {
                        try {
                            processAction(action);
                            // Only mark as completed if no exception occurred
                            markActionCompleted(action.id);
                            slackActionProcessed = true;
                        } catch (Exception e) {
                            // Don't mark as completed if exception occurred
                            // SlackService.sendMessageToSlack() already handles rate limits internally
                            // If we get a rate limit exception, we'll handle it normally through error processing
                        }
                    }
                } 
                // Special handling for EMAIL actions to collect messages
                else if (actionType.equals(Constants.ACTION_SOBJECT.ACTION_TYPE_EMAIL_NOTIFICATION)) {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.id)) {
                        continue; // Skip already completed actions
                    }
                    
                    emailMessages.add(createEmailMessage(this.recordId, action.fields));
                    // Mark email action as completed (they don't fail with rate limits)
                    if (action.id != null) {
                        markActionCompleted(action.id);
                    }
                }
                // Handle all other actions
                else {
                    // Check if this specific action was already completed
                    if (hasCompletedAction(action.id)) {
                        continue; // Skip already completed actions
                    }
                    
                    try {
                        processAction(action);
                        // Only mark as completed if no exception occurred
                        markActionCompleted(action.id);
                    }
                    catch (Exception e) {
                        // processAction already handles exception, don't throw it
                    }
                }
            }
            
            // Persist action state after processing
            persistActionState(this.recordId, this.config);
            
            return emailMessages;
        }
        
        /**
         * Process a specific action by action ID (for iteration-specific processing)
         */
        public void processSpecificAction(List<RuleUtil.Action> actions, String targetActionId, String targetActionType) {
            Boolean actionFound = false;
            for (RuleUtil.Action action : actions) {
                if (action.id == targetActionId && action.type == targetActionType) {
                    // Check if action was already completed
                    if (hasCompletedAction(action.id)) {
                        return; // Skip already completed actions
                    }
                    
                    try {
                        processAction(action);
                        // Only mark as completed if no exception occurred
                        markActionCompleted(action.id);
                        persistActionState(this.recordId, this.config);
                        actionFound = true;
                    } catch (Exception e) {
                        // Don't mark as completed if exception occurred
                        // SlackService.sendMessageToSlack() already handles rate limits internally
                    }
                    break;
                }
            }
        }
        
        /**
         * Check if a specific action has been completed
         */
        private Boolean hasCompletedAction(String actionId) {
            if (String.isBlank(actionId) || this.config == null) {
                return false;
            }
            return this.config.isActionCompleted(actionId);
        }
        
        /**
         * Mark an action as completed
         */
        private void markActionCompleted(String actionId) {
            if (String.isNotBlank(actionId) && this.config != null) {
                this.config.markActionCompleted(actionId);
            }
        }
    }

    // Action iteration delegation methods
    public List<ActionIteration> getActionIterations(SObject record) {
        return this.strategy.getActionIterations(record);
    }

    public void executeActionIteration(ActionIteration iteration) {
        this.strategy.executeActionIteration(iteration);
    }
    
    // Get Iterable for batch processing with custom iterations
    public Iterable<SObject> getIterableForBatch() {
        return new ActionIterationIterable(this, null, false);
    }
    
    // Get Iterable for batch processing with custom iterations and batch context manager
    public Iterable<SObject> getIterableForBatch(BatchContextManager batchContextManager) {
        return new ActionIterationIterable(this, batchContextManager, false);
    }
    
    // Get Iterable for batch processing with rate limiting awareness
    public Iterable<SObject> getIterableForBatch(BatchContextManager batchContextManager, Boolean slackRateLimited) {
        return new ActionIterationIterable(this, batchContextManager, slackRateLimited);
    }
    
    // Custom Iterable that expands records based on action count with rate limiting awareness
    public class ActionIterationIterable implements Iterable<SObject> {
        private NotificationService notificationServiceImpl;
        private BatchContextManager batchContextManager;
        private Boolean slackRateLimited;
        
        public ActionIterationIterable(NotificationService notificationServiceImpl, BatchContextManager batchContextManager, Boolean slackRateLimited) {
            this.notificationServiceImpl = notificationServiceImpl;
            this.batchContextManager = batchContextManager;
            this.slackRateLimited = slackRateLimited != null ? slackRateLimited : false;
        }
        
        public Iterator<SObject> iterator() {
            return new ActionIterationIterator(this.notificationServiceImpl, this.batchContextManager, this.slackRateLimited);
        }
    }
    
    // Custom Iterator that returns multiple iterations per record with rate limiting awareness
    public class ActionIterationIterator implements Iterator<SObject> {
        private List<IterationWrapper> expandedRecords;
        private Integer currentIndex = 0;
        private BatchContextManager batchContextManager;
        private Boolean slackRateLimited;
        
        public ActionIterationIterator(NotificationService notificationServiceImpl, BatchContextManager batchContextManager, Boolean slackRateLimited) {
            this.batchContextManager = batchContextManager;
            this.slackRateLimited = slackRateLimited != null ? slackRateLimited : false;
            this.expandedRecords = buildExpandedRecordListBulk(notificationServiceImpl);
        }
        
        public Integer count() {
            return expandedRecords?.size() ?? 0;
        }

        public Boolean hasNext() {
            return currentIndex < expandedRecords.size();
        }
        
        public SObject next() {
            if (hasNext()) {
                IterationWrapper wrapper = expandedRecords[currentIndex++];
                
                // Set the iteration context using batch context manager
                if (this.batchContextManager != null) {
                    this.batchContextManager.setIterationContext(wrapper.recordId, wrapper.iteration);
                }
                
                return wrapper.record;
            }
            return null;
        }
        
        private List<IterationWrapper> buildExpandedRecordListBulk(NotificationService notificationServiceImpl) {
            List<IterationWrapper> result = new List<IterationWrapper>();
            
            // Step 1: Bulk load all records
            List<SObject> allRecords = getAllRecordsFromLocator(notificationServiceImpl);
            
            if (allRecords.isEmpty()) {
                return result;
            }
            
            // Step 2: Bulk load all action iterations for all records
            Map<String, List<NotificationService.ActionIteration>> recordToActionIterations = 
                bulkGetActionIterations(notificationServiceImpl, allRecords);
            
            // Step 3: Build expanded record list using cached data
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                
                // Check if this record should be filtered during Slack rate limiting
                if (this.slackRateLimited && !hasNonSlackActions(record, recordToActionIterations.get(recordId))) {
                    // Skip records with only Slack actions during rate limiting
                    continue;
                }
                
                // Add first iteration for precalculation and non-Slack actions
                NotificationService.ActionIteration firstIteration = new NotificationService.ActionIteration(recordId, 1, 0);
                result.add(new IterationWrapper(record, firstIteration));
                
                // Skip expansion if disabled (defaults to true in test context)
                if (Test.isRunningTest() && disableIteratorExpansion) {
                    continue;
                }
                
                // Get cached action iterations for this record
                List<NotificationService.ActionIteration> actionIterations = recordToActionIterations.get(recordId);
                if (actionIterations == null) {
                    continue;
                }
                
                // Add individual iterations for REMAINING Slack actions (skip first one since it's processed in first iteration)
                // Skip Slack iterations during rate limiting
                Integer slackIterationNumber = 2;
                Integer slackActionCount = 0;
                for (NotificationService.ActionIteration iteration : actionIterations) {
                    if (iteration.actionType.equals(Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION)) {
                        slackActionCount++;
                        // Skip the first Slack action since it's processed in the first iteration
                        // Also skip all Slack iterations during rate limiting
                        if (slackActionCount > 1 && !this.slackRateLimited) {
                            NotificationService.ActionIteration slackAction = new NotificationService.ActionIteration(
                                recordId, 
                                slackIterationNumber++, 
                                0, 
                                iteration.actionType, 
                                iteration.actionId
                            );
                            result.add(new IterationWrapper(record, slackAction));
                        }
                    }
                }
            }
            return result;
        }
        
        /**
         * Check if a record has any non-Slack actions
         */
        private Boolean hasNonSlackActions(SObject record, List<NotificationService.ActionIteration> actionIterations) {
            try {
                // For EventAction__c records, check Action_Type__c directly
                if (record.getSObjectType() == EventAction__c.SObjectType) {
                    String actionType = (String)record.get('Action_Type__c');
                    if (String.isBlank(actionType)) {
                        actionType = (String)record.get('Type__c');
                    }
                    return actionType != Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION;
                }
                
                // For other record types, check action iterations
                if (actionIterations == null || actionIterations.isEmpty()) {
                    return true; // Assume has non-Slack actions if no iterations
                }
                
                // Check if any action is non-Slack
                for (NotificationService.ActionIteration iteration : actionIterations) {
                    if (iteration.actionType != Constants.ACTION_SOBJECT.ACTION_TYPE_SLACK_NOTIFICATION) {
                        return true; // Found non-Slack action
                    }
                }
                
                return false; // Only Slack actions found
                
            } catch (Exception e) {
                // If error checking, assume record has non-Slack actions to be safe
                return true;
            }
        }
        
        private List<SObject> getAllRecordsFromLocator(NotificationService notificationServiceImpl) {
            List<SObject> allRecords = new List<SObject>();
            Database.QueryLocator originalLocator = notificationServiceImpl.getQueryLocator();
            Database.QueryLocatorIterator originalIterator = originalLocator.iterator();
            
            while (originalIterator.hasNext()) {
                allRecords.add(originalIterator.next());
            }
            
            return allRecords;
        }
        
        private Map<String, List<NotificationService.ActionIteration>> bulkGetActionIterations(
            NotificationService notificationServiceImpl, 
            List<SObject> allRecords
        ) {
            Map<String, List<NotificationService.ActionIteration>> result = 
                new Map<String, List<NotificationService.ActionIteration>>();
            
            if (allRecords.isEmpty()) {
                return result;
            }
            
            // Step 1: Collect all executable rule IDs for all records
            Set<String> allExecutableRuleIds = new Set<String>();
            Map<String, NotificationService.ExecutableRulesConfig> recordToConfig = 
                new Map<String, NotificationService.ExecutableRulesConfig>();
            
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(record);
                recordToConfig.put(recordId, config);
                
                List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
                if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                    executableRulesIds.addAll(config.getAllExecutedRuleIds());
                }
                allExecutableRuleIds.addAll(executableRulesIds);
            }
            
            // Step 2: Bulk load all rules once (avoid repeated SOQL queries)
            if (allRecords == null || allRecords.isEmpty()) {
                return result;
            }
            String ruleSobjectType = notificationServiceImpl.strategy.getRuleSobjectType(allRecords[0]);
            List<RuleUtil.Rule> allNotificationRules =
                RuleUtil.getNotificationRules(new List<String>(allExecutableRuleIds), ruleSobjectType);
            List<RuleUtil.Rule> allTicketingRules =
                notificationServiceImpl.strategy.getTicketingRules(new List<String>(allExecutableRuleIds), ruleSobjectType);
            
            // Step 3: Create maps for fast lookup
            Map<String, List<RuleUtil.Rule>> ruleIdToNotificationRules = groupRulesByRuleId(allNotificationRules);
            Map<String, List<RuleUtil.Rule>> ruleIdToTicketingRules = groupRulesByRuleId(allTicketingRules);
            
            // Step 4: Generate action iterations for each record using cached rules
            for (SObject record : allRecords) {
                String recordId = (String)record.get('Id');
                NotificationService.ExecutableRulesConfig config = recordToConfig.get(recordId);
                
                List<String> executableRulesIds = new List<String>(config.getAllRuleIdsToRun());
                if (executableRulesIds.isEmpty() && !config.getAllExecutedRuleIds().isEmpty()) {
                    executableRulesIds.addAll(config.getAllExecutedRuleIds());
                }
                
                List<NotificationService.ActionIteration> actionIterations = 
                    buildActionIterationsForRecord(recordId, executableRulesIds, ruleIdToNotificationRules, ruleIdToTicketingRules);
                result.put(recordId, actionIterations);
            }
            
            return result;
        }
        
        private Map<String, List<RuleUtil.Rule>> groupRulesByRuleId(List<RuleUtil.Rule> rules) {
            Map<String, List<RuleUtil.Rule>> result = new Map<String, List<RuleUtil.Rule>>();
            for (RuleUtil.Rule rule : rules) {
                if (!result.containsKey(rule.id)) {
                    result.put(rule.id, new List<RuleUtil.Rule>());
                }
                result.get(rule.id).add(rule);
            }
            return result;
        }
        
        private List<NotificationService.ActionIteration> buildActionIterationsForRecord(
            String recordId, 
            List<String> executableRulesIds,
            Map<String, List<RuleUtil.Rule>> ruleIdToNotificationRules,
            Map<String, List<RuleUtil.Rule>> ruleIdToTicketingRules
        ) {
            List<NotificationService.ActionIteration> iterations = new List<NotificationService.ActionIteration>();
            Integer iterationCounter = 1; // Start from 1 (0 reserved for precalculation)
            
            // Add notification actions
            for (String ruleId : executableRulesIds) {
                List<RuleUtil.Rule> notificationRules = ruleIdToNotificationRules.get(ruleId);
                if (notificationRules != null) {
                    for (RuleUtil.Rule rule : notificationRules) {
                        if (rule.actions != null) {
                            for (RuleUtil.Action action : rule.actions) {
                                iterationCounter++;
                                ActionIteration iteration = new ActionIteration(
                                    recordId, 
                                    iterationCounter, 
                                    0, // Will be set later
                                    action.type,
                                    action.id
                                );
                                iterations.add(iteration);
                            }
                        }
                    }
                }
            }
            
            // Add ticketing actions
            for (String ruleId : executableRulesIds) {
                List<RuleUtil.Rule> ticketingRules = ruleIdToTicketingRules.get(ruleId);
                if (ticketingRules != null) {
                    for (RuleUtil.Rule rule : ticketingRules) {
                        if (rule.actions != null) {
                            for (RuleUtil.Action action : rule.actions) {
                                iterationCounter++;
                                ActionIteration iteration = new ActionIteration(
                                    recordId, 
                                    iterationCounter, 
                                    0, // Will be set later
                                    action.type,
                                    action.id
                                );
                                iterations.add(iteration);
                            }
                        }
                    }
                }
            }
            
            // Add AutoChart iterations - using direct AutoChart static methods (no notificationServiceImpl needed)
            for (String ruleId : executableRulesIds) {
                List<RuleUtil.Rule> notificationRules = ruleIdToNotificationRules.get(ruleId);
                if (notificationRules != null) {
                    for (RuleUtil.Rule rule : notificationRules) {
                        if (rule.actions != null) {
                            for (RuleUtil.Action action : rule.actions) {
                                // Check if this action contains AutoChart merge fields using centralized AutoChart logic
                                if (AutoChart.containsAutoChartFields(action)) {
                                    List<String> chartTypes = AutoChart.extractChartTypesFromAction(action);
                                    for (AutoChart.AutoChartStep step : AutoChart.AutoChartStep.values()) {
                                        iterationCounter++;
                                        AutoChart.AutoChartIteration autoChartIteration = new AutoChart.AutoChartIteration(
                                            recordId,
                                            iterationCounter,
                                            0, // Will be set later
                                            chartTypes,
                                            step
                                        );
                                        iterations.add(autoChartIteration);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Set total iterations for all
            Integer totalIterations = iterations.size() + 1; // +1 for precalculation iteration
            for (ActionIteration iteration : iterations) {
                iteration.totalIterations = totalIterations;
            }
            
            return iterations;
        }
    }
    
    // Helper class to wrap record with its iteration context
    public class IterationWrapper {
        public SObject record;
        public NotificationService.ActionIteration iteration;
        public String recordId;
        
        public IterationWrapper(SObject record, NotificationService.ActionIteration iteration) {
            this.record = record;
            this.iteration = iteration;
            this.recordId = (String)record.get('Id');
        }
    }
}