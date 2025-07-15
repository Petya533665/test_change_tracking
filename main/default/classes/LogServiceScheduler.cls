public with sharing class LogServiceScheduler implements Schedulable, Database.AllowsCallouts {

    public enum SCHEDULER_MODE {RECURRING, ONCE, SCHEDULER_MODE_1, SCHEDULER_MODE_2}

    private SCHEDULER_MODE currentMode;

    public LogServiceScheduler() {
        this.currentMode = SCHEDULER_MODE.RECURRING;
    }

    public LogServiceScheduler(SCHEDULER_MODE schedulerMode) {
        this.currentMode = schedulerMode;
    }

    public void execute(SchedulableContext SC) {
        // TODO reschedule
        try {
            if (currentMode == SCHEDULER_MODE.RECURRING || currentMode == SCHEDULER_MODE.ONCE) {
                rescheduleCronTriggers();
            } else if (currentMode == SCHEDULER_MODE.SCHEDULER_MODE_1 || currentMode == SCHEDULER_MODE.SCHEDULER_MODE_2) {
                queueJobs = getQueueJobs();
                scopeJobs = getScopeJobs();
                serviceSchedulerDispatcher();
            }
        } catch (Exception e) {
            Logger.getInstance().internalError(e, LogServiceScheduler.class.getName(), 'execute');
        }
        if (currentMode == SCHEDULER_MODE.SCHEDULER_MODE_1) {
            BlurModeService.increment24hrCounter();
        }
    }

    private static final Set<String> CRON_TRIGGER_NAMES = new Set<String>{
            ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_NAME,
            ConfigUtil.LOG_POST_PROCESSING_BATCH_SCHEDULER_NAME,
            ConfigUtil.ERROR_EMAIL_REPORT_SCHEDULER_NAME,
            ConfigUtil.MONITORING_SERVICE_SCHEDULER_NAME,
            ConfigUtil.JIRA_RESOLUTION_SCHEDULER_NAME,
            ConfigUtil.ARCHIVAL_SCHEDULER_NAME,
            ConfigUtil.MANAGE_TOKENS_SERVICE_SCHEDULER1_NAME,
            ConfigUtil.MANAGE_TOKENS_SERVICE_SCHEDULER2_NAME,
            ConfigUtil.TRACE_BATCH_SERVICE_SCHEDULER_NAME,
            ConfigUtil.DEBUG_LOG_SERVICE_SCHEDULER_CRON_EXP1,
            ConfigUtil.DEBUG_LOG_SERVICE_SCHEDULER_CRON_EXP2
    };

    private static final Integer LOG_SERVICE_SCHEDULER_FREQUENCY_START_TIME = 15;

    public static void rescheduleCronTriggers() {
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :CRON_TRIGGER_NAMES];
        for (CronTrigger cronTrigger : cronTriggers) {
            //ignore, job already aborted
            try {
                System.abortJob(cronTrigger.Id);
            } catch (StringException e) {}
        }
        cronTriggers = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = :ConfigUtil.PHAROS_BULK_API_SCHEDULER_NAME];
        if (!cronTriggers.isEmpty() && MAP_EXPRESSIONS.containsKey(cronTriggers[0].CronExpression)) {
            ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c = MAP_EXPRESSIONS.get(cronTriggers[0].CronExpression);
            upsert ConfigUtil.PHAROS_SETTINGS;
            //ignore, job already aborted
            try {
                System.abortJob(cronTriggers[0].Id);
            } catch (StringException e) {}
        }
        if ([
                SELECT COUNT()
                FROM CronTrigger
                WHERE CronJobDetail.Name = :ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_1_NAME
                OR CronJobDetail.Name = :ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_2_NAME
        ] == 0) {
            runLogServiceSchedulerModes();
        }
    }

    public static void runLogServiceSchedulerModes() {
        String logServiceSchedulerStartTime = ConfigUtil.PHAROS_SETTINGS.Log_Service_Scheduler_Cron_Exp__c;
        Integer frequency;
        try {
            frequency = Integer.valueOf(logServiceSchedulerStartTime);
        } catch (Exception e) {}
        if (frequency == null) frequency = LOG_SERVICE_SCHEDULER_FREQUENCY_START_TIME;
        AdminService.runScheduler(
                ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_1_NAME,
                String.format(ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_CRON_EXP, new List<Object>{String.valueOf(frequency)}),
                String.format(ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_CRON_EXP, new List<Object>{String.valueOf(frequency)}),
                new LogServiceScheduler(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_1)
        );
        AdminService.runScheduler(
                ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_2_NAME,
                String.format(ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_CRON_EXP, new List<Object>{String.valueOf(frequency + 30)}),
                String.format(ConfigUtil.PHAROS_LOG_SERVICE_SCHEDULER_MODE_CRON_EXP, new List<Object>{String.valueOf(frequency + 30)}),
                new LogServiceScheduler(LogServiceScheduler.SCHEDULER_MODE.SCHEDULER_MODE_2)
        );
    }

    private static final Map<String, String> MAP_EXPRESSIONS = new Map<String, String>{
            '0 0 * * * ?' => '1',
            '0 0 0,4,8,12,16,20 * * ?' => '4',
            '0 0 0,8,16 * * ?' => '8',
            '0 0 0 * * ?' => '24',
            '0 0 0 ? * SUN' => '168'
    };

    public static Map<String, String> FREQUENCY_HOURS = new Map<String, String>{
            'LogPostProcessingBatch' => ConfigUtil.PHAROS_SETTINGS.Log_Post_Processing_Batch_Cron_Exp__c,
            'JiraResolutionBatch' => ConfigUtil.PHAROS_SETTINGS.Jira_Scheduler_Cron_Exp__c,
            'ErrorEmailReportBatch' => ConfigUtil.PHAROS_SETTINGS.Error_Email_Report_Batch_Cron_Exp__c,
            'BulkAPIJobBatchScheduler' => ConfigUtil.PHAROS_SETTINGS.Archival_Scheduler_Cron_Exp__c
    };

    public static Map<String, String> FREQUENCY_HOURS_DEFAULT = new Map<String, String>{
            'IssueAverageFrequencyBatch' => '6',
            'MetricsBatch' => '24',
            'ErrorEmailReportBatch' => '168',
            'BulkAPIJobBatchScheduler' => '0'
    };

    private Set<DatabaseUtils.PharosBatchImpl> queueJobs = new Set<DatabaseUtils.PharosBatchImpl>();
    private Set<DatabaseUtils.PharosBatchImpl> scopeJobs = new Set<DatabaseUtils.PharosBatchImpl>();

    public Set<DatabaseUtils.PharosBatchImpl> getQueueJobs() {
        switch on currentMode {
            when SCHEDULER_MODE_1 {
                return new Set<DatabaseUtils.PharosBatchImpl>{
                        LogServiceBatch.getInstance(),
                        ManageTokensBatch.getInstance(),
                        RetentionBatch.getInstance()
                };
            }
            when SCHEDULER_MODE_2 {
                return new Set<DatabaseUtils.PharosBatchImpl>{
                        ManageTokensBatch.getInstance()
                };
            }
            when else {
                return new Set<DatabaseUtils.PharosBatchImpl>();
            }
        }
    }

    public Set<DatabaseUtils.PharosBatchImpl> getScopeJobs() {
        switch on currentMode {
            when SCHEDULER_MODE_1 {
                return new Set<DatabaseUtils.PharosBatchImpl>{
                        MonitoringBatch.getInstance(),
                        EventLogProcessingBatch.getInstance(),
                        JiraNotificationBatch.getInstance(),
                        IssueNotificationBatch.getInstance(),
                        TraceResultNotificationBatch.getInstance(),
                        BroadcastBatch.getInstance(),
                        JobBatch.getInstance(),
                        GitHubCommitBatch.getInstance(),
                        IssueTrackerBatch.getInstance(),
                        JiraSyncBatch.getInstance(),
                        TraceService.getInstance()
                };
            }
            when SCHEDULER_MODE_2 {
                return new Set<DatabaseUtils.PharosBatchImpl>{
                        LogPostProcessingBatch.getInstance(),
                        ErrorEmailReportBatch.getInstance(ErrorEmailReportBatch.JobType.UPLOAD_LOG),
                        JiraResolutionBatch.getInstance(),
                        MetricsBatch.getInstance(),
                        IssueAverageFrequencyBatch.getInstance(null),
                        TraceService.getInstance(),
                        BulkAPIJobBatchScheduler.getInstance(null),
                        TraceBatch.getInstance(null)
                };
            }
            when else {
                return new Set<DatabaseUtils.PharosBatchImpl>();
            }
        }
    }

    public void serviceSchedulerDispatcher() {
        DatabaseUtils.PharosBatchImpl pharosBatch;
        if (!queueJobs.isEmpty()) {
            pharosBatch = queueJobs.iterator().next();
            queueJobs.remove(pharosBatch);
            pharosBatch.setSchedulerInstance(this);
            pharosBatch.startBatch();
        } else if (!getScopeJobs().isEmpty()) {
            for (DatabaseUtils.PharosBatchImpl pharosBatchImpl : scopeJobs) {
                pharosBatch = pharosBatchImpl;
                pharosBatch.startBatch();
            }
        }
    }

}