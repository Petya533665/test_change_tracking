public class HourlyLimitsBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    public static final String CATEGORY = 'Pharos';
    public static final String TYPE = 'HourlyLimitsBatch';
    public static final String DETAILS = 'Hourly Limits Snapshot Created';

    public void execute(SchedulableContext sc) {
        // Schedule to run every hour
        LogServiceScheduler.rescheduleCronTriggers();
        if (needToRunBatch()) {
            Database.executeBatch(this, 1);
        }
    }

    private static HourlyLimitsBatch instance = null;

    public static HourlyLimitsBatch getInstance() {
        if (instance == null) {
            instance = new HourlyLimitsBatch(Logger.getInstance());
        }
        return instance;
    }

    private HourlyLimitsBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('HourlyLimitsBatch', this);
    }

    public override Boolean initialValidation() {
        return PermissionsUtil.MonitoringEnabled && ConfigUtil.SETTINGS.Monitoring_Enabled__c && needToRunBatch();
    }

    public override Integer getIterationsCount() {
        return 3; // Only need three iterations to create hourly limits snapshot (start, execute, finish)
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Return a single dummy record to create one Limits__c record
        return Database.getQueryLocator('SELECT Id FROM Organization LIMIT 1');
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        // do nothing, dml shoudl be fired in finish
    }

    public void finish(Database.BatchableContext BC) {
        try {
            
            // Create a log entry to record the hourly limits snapshot creation
            Log__c hourlyLog = LogBuilder.getInstance()
                .category(CATEGORY)
                .summary(DETAILS)
                .details(DETAILS)
                .type(TYPE)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), UserInfo.getOrganizationId().left(15))
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.getName(), 'HourlyLimitsBatch.finish')
                .build();
            
            loggerInstance?.add(hourlyLog);    
        }
        catch (Exception e) {
            loggerInstance?.addInternalError(e, null, 'HourlyLimitsBatch', '.finish');
        }
        loggerInstance?.flush();
    }

    private static Boolean needToRunBatch() {
        // Check if it's time to run the batch (hourly)
        DateTime lastRun = getLastHourlyLimitsRunTime();
        DateTime now = DateTime.now();
        
        // Run if no previous run or if more than 55 minutes have passed
        return lastRun == null || lastRun.addMinutes(55) <= now;
    }

    private static DateTime getLastHourlyLimitsRunTime() {
        List<Log__c> lastRecords = [
            SELECT Created_At__c 
            FROM Log__c
            WHERE Limits__c != null
                AND Category__c = :CATEGORY
                AND Type__c = :TYPE
            ORDER BY Created_At__c DESC 
            LIMIT 1
        ];
        
        return lastRecords.isEmpty() ? null : lastRecords[0].Created_At__c;
    }
}