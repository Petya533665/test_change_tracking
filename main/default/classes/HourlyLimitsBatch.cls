public with sharing class HourlyLimitsBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {

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
        return PermissionsUtil.LimitsMonitoringEnabled && ConfigUtil.SETTINGS.Limits_Monitoring_Enabled__c && needToRunBatch();
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
        loggerInstance?.flushAsync();
    }

    @TestVisible
    private static Boolean needToRunBatch() {
        // Check if it's time to run the batch based on configured frequency
        DateTime lastRun = getLastHourlyLimitsRunTime();
        DateTime now = DateTime.now();
        
        // Get the configured frequency in hours (default to 1 hour if not set or invalid)
        Integer frequencyHours = getFrequencyHours();
        Integer freqTolerance = 5;
        
        // Run if no previous run or if the configured frequency period has passed
        return lastRun == null || lastRun.addHours(frequencyHours).addMinutes(-freqTolerance) <= now;
    }

    public static Integer getFrequencyHours() {
        // Get the configured frequency, default to 1 hour if not set or invalid
        String frequencyStr = ConfigUtil.SETTINGS.Limits_Monitoring_Frequency__c;
        Integer frequency = 1; // Default to 1 hour
        Integer maxFrequency = 23; // Maximum frequency is 23 hours
        Integer minFrequency = 1; // Minimum frequency is 1 hour
        
        if (String.isNotBlank(frequencyStr)) {
            try {
                Integer configuredFrequencyMinutes = Integer.valueOf(frequencyStr);
                Integer configuredFrequencyHours = configuredFrequencyMinutes / 60;
                // Validate range: 1-23 hours
                if (configuredFrequencyHours >= minFrequency && configuredFrequencyHours <= maxFrequency) {
                    frequency = configuredFrequencyHours;
                }
            }
            // use default if invalid
            catch (Exception e) {}
        }
        
        return frequency;
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