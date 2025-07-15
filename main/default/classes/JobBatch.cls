public with sharing class JobBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private static final String INTERNAL_ERROR_DETAILS_COUNTER_NAME = '\nFailures count: ';
    private static final String INTERNAL_ERROR_DETAILS_REGEX_DIGITS = '[0-9]+$';
    private List<Log__c> logs;
    private Connected_Org__c corg;
    private Map<String, Log__c> internalLogByHash = new Map<String, Log__c>();
    private Map<String, Integer> internalLogsCountByHash = new Map<String, Integer>();

    private static final String AREA_ASYNC_APEX = 'Async Apex';
    private static final String AREA_BACKGROUND_JOB = 'Background Job';
    private static final Set<String> BACKGROUND_JOB_TYPES = new Set<String>{'BatchApex', 'BatchApexWorker'};

    public static final Set<String> LOG_FIELDS = new Set<String>{
            Log__c.Id.getDescribe().getName(),
            Log__c.Async_Job_Id__c.getDescribe().getName(),
            Log__c.Details__c.getDescribe().getName(),
            Log__c.Hash__c.getDescribe().getName(),
            Log__c.Hash_1__c.getDescribe().getName(),
            Log__c.Stacktrace__c.getDescribe().getName(),
            Log__c.Created_At__c.getDescribe().getName()
    };

    private static JobBatch instance = null;

    public static JobBatch getInstance() {
        if (instance == null) {
            instance = new JobBatch(Logger.getInstance());
        }
        return instance;
    }

    private JobBatch(Logger logger) {
        super(logger);
        BATCH_SCOPE = 200;
        logs = new List<Log__c>();
        corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('JobBatch', this);
    }

    public override Boolean initialValidation() {
        return ConfigUtil.SETTINGS.Batch_Error_Tracking_Enabled__c;
    }

    public override Integer getIterationsCount() {
        return [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE Status IN ('Completed', 'Failed')
                AND ParentJobId = NULL
                AND (NumberOfErrors > 0 OR (JobType = 'Queueable' AND Status = 'Failed'))
                AND (CompletedDate >= YESTERDAY OR CreatedDate >= YESTERDAY)
        ];
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, JobType, ExtendedStatus, ApexClassId, ApexClass.Name, ApexClass.NamespacePrefix, Status, CompletedDate, CreatedDate
                FROM AsyncApexJob
                WHERE Status IN ('Completed', 'Failed')
                AND ParentJobId = NULL
                AND (NumberOfErrors > 0 OR (JobType = 'Queueable' AND Status = 'Failed'))
                AND (CompletedDate >= YESTERDAY OR CreatedDate >= YESTERDAY)
                ORDER BY CompletedDate
        ]);
    }

    public void execute(Database.BatchableContext BC, List<AsyncApexJob> scope) {
        Set<String> hashes = new Set<String>();
        for (AsyncApexJob asyncApexJob : scope) {
            hashes.add(getHash1(asyncApexJob));
        }
        List<Log__c> existLogs = getLogs(hashes);
        for (AsyncApexJob asyncApexJob : scope) {
            Log__c log;
            Boolean isInternalError = isInternalError(asyncApexJob);
            String hash = getHash1(asyncApexJob);
            for (Log__c existLog : existLogs) {
                if (hash == existLog.Hash_1__c
                        && ((asyncApexJob.CompletedDate != null
                        && existLog.Created_At__c.dateGmt() == asyncApexJob.CompletedDate.dateGmt())
                        || existLog.Created_At__c.dateGmt() == asyncApexJob.CreatedDate.dateGmt())) {
                    log = existLog;
                    break;
                }
            }
            if (isInternalError) {
                String hashByDate = hash + String.valueOfGmt(asyncApexJob.CompletedDate != null ? asyncApexJob.CompletedDate.dateGmt() : asyncApexJob.CreatedDate.dateGmt());
                if (!internalLogByHash.containsKey(hashByDate)) {
                    internalLogByHash.put(hashByDate, log != null ? log : createLog(asyncApexJob, corg));
                }
                internalLogsCountByHash.put(hashByDate, internalLogsCountByHash.get(hashByDate) == null ? 1 : internalLogsCountByHash.get(hashByDate) + 1);
            } else if (log == null) {
                logs.add(createLog(asyncApexJob, corg));
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        for (String hash : internalLogByHash.keySet()) {
            Log__c log = internalLogByHash.get(hash);
            log.Details__c = log.Details__c.replaceFirst(INTERNAL_ERROR_DETAILS_COUNTER_NAME + INTERNAL_ERROR_DETAILS_REGEX_DIGITS, '');
            log.Details__c += '\n' + INTERNAL_ERROR_DETAILS_COUNTER_NAME + internalLogsCountByHash.get(hash);
            logs.add(log);
        }
        if (!logs.isEmpty() && !Test.isRunningTest()) {
            upsertLogs(logs, loggerInstance);
        }
        loggerInstance?.flush();
    }

    private static List<Log__c> getLogs(Set<String> hashes) {
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(LOG_FIELDS)
                .add(QBuilder.condition(Log__c.Hash_1__c.getDescribe().getName()).isIn(new List<String>(hashes)))
                .build();
        return (List<Log__c>)JSON.deserialize(JSON.serialize(
                isPassthroughMode()
                        ? runQueryAll(ConnectedOrgService.getPassthroughConnectedOrg(), ConfigUtil.QUERY_ALL_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new List<Object>())
                        : Database.query(query + ' ALL ROWS')
        ), List<Log__c>.class);
    }

    private static Boolean isPassthroughMode() {
        return ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c && String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c);
    }

    private static List<Object> runQueryAll(Connected_Org__c corg, String path, List<Object> objects) {
        String b = HttpUtils.get(
                corg.Instance_Url__c + path,
                HttpUtils.getHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg)),
                200
        );
        Map<String, Object> objectMap = (Map<String, Object>)JSON.deserializeUntyped(b);
        objects.addAll((List<Object>)objectMap.get(ConfigUtil.TOOLING_ITEMS_KEY_RECORDS));
        if (objectMap.get(ConfigUtil.REST_API_ITEMS_KEY_NEXT_RECORDS_URL) != null) {
            runQueryAll(corg, String.valueOf(objectMap.get(ConfigUtil.REST_API_ITEMS_KEY_NEXT_RECORDS_URL)), objects);
        }
        return objects;
    }

    public static Log__c createLog(AsyncApexJob asyncApexJob, Connected_Org__c corg) {
        Boolean isInternalError = isInternalError(asyncApexJob);
        String jobApexClassName = getJobApexClassName(asyncApexJob);
        String jobExtendedStatus = getJobExtendedStatus(asyncApexJob.ExtendedStatus);
        return LogBuilder.getInstance()
                .category(isInternalError ? Logger.CATEGORY_PHAROS_ERROR : 'Apex')
                .summary(jobExtendedStatus)
                .details(jobExtendedStatus + '\n\nClass: ' + jobApexClassName)
                .area(isInternalError ? Logger.AREA_PHAROS_ERROR : getArea(asyncApexJob))
                .type(asyncApexJob.JobType)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.name, corg?.Name)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Name__c.name, corg?.Title__c)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Url__c.name, corg?.Instance_Url__c)
                .attribute(Schema.SObjectType.Log__c.fields.Async_Job_Id__c.name, asyncApexJob.Id.to15())
                .attribute(Schema.SObjectType.Log__c.fields.Async_Job_Name__c.name, jobApexClassName)
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.name, jobApexClassName)
                .attribute(Schema.SObjectType.Log__c.fields.Namespace__c.name, asyncApexJob.ApexClass.NamespacePrefix)
                .attribute(Schema.SObjectType.Log__c.fields.Hash__c.name, getHash(asyncApexJob))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_1__c.name, getHash1(asyncApexJob))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_2__c.name, getHash2(asyncApexJob))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_3__c.name, getHash3(asyncApexJob))
                .attribute(Schema.SObjectType.Log__c.fields.Created_At__c.name, asyncApexJob.CompletedDate != null ? asyncApexJob.CompletedDate : asyncApexJob.CreatedDate)
                .createIssue()
                .build();
    }

    private static void upsertLogs(List<Log__c> logs, Logger logger) {
        if (isPassthroughMode()) {
            PassthroughtModeService.sendLogs(logs);
        } else {
            DatabaseUtils.getInstance().performUpsertDML(logs, Schema.SObjectType.Log__c)
                    .handleError(JobBatch.class.getName(), '.upsertLogs', logger);
        }
    }

    public static String getJobExtendedStatus(String extendedStatus) {
        return String.isNotBlank(extendedStatus) ? extendedStatus.removeStart('First error:').trim() : extendedStatus;
    }

    public static String getJobApexClassName(AsyncApexJob asyncApexJob) {
        return String.isNotBlank(asyncApexJob.ApexClass.NamespacePrefix) ? asyncApexJob.ApexClass.NamespacePrefix + '.' + asyncApexJob.ApexClass.Name : asyncApexJob.ApexClass.Name;
    }

    public static Boolean isInternalError(AsyncApexJob asyncApexJob) {
        return asyncApexJob.ApexClass != null
                && asyncApexJob.ApexClass.Name != null
                && asyncApexJob.ApexClass.NamespacePrefix != null
                && asyncApexJob.ApexClass.NamespacePrefix == ConfigUtil.NS;
    }

    public static void asyncApexJobHandler(List<Log__c> logs) {
        Set<String> asyncApexJobIds = new Set<String>();
        for (Log__c log : logs) {
            asyncApexJobIds.add(log.Async_Job_Id__c.left(15));
        }
        Map<Id, AsyncApexJob> jobs = getAsyncApexJobsById(asyncApexJobIds);
        Set<String> parentAsyncApexJobIds = new Set<String>();
        for (AsyncApexJob asyncApexJob : jobs.values()) {
            if (String.isNotBlank(asyncApexJob.ParentJobId)) parentAsyncApexJobIds.add(asyncApexJob.ParentJobId);
        }
        Map<Id, AsyncApexJob> parentJobs = getAsyncApexJobsById(parentAsyncApexJobIds);
        Set<String> apexClassNames = new Set<String>();
        for (Log__c log : logs) {
            AsyncApexJob asyncApexJob = getAsyncApexJob(log.Async_Job_Id__c, jobs, parentJobs);
            if (asyncApexJob != null && String.isNotBlank(asyncApexJob.ApexClass?.Name)) {
                apexClassNames.add(asyncApexJob.ApexClass.Name);
            }
        }
        List<ApexClass> apexClasses = [FIND 'Database.RaisesPlatformEvents' IN ALL FIELDS RETURNING ApexClass (Id, Name WHERE Name IN :apexClassNames)][0];
        Set<String> apexClassNamesRaisesPlatformEvents = new Set<String>();
        for (ApexClass apexClass : apexClasses) {
            apexClassNamesRaisesPlatformEvents.add(apexClass.Name);
        }
        List<Log__c> logsToUpsert = new List<Log__c>();
        for (Log__c log : logs) {
            AsyncApexJob asyncApexJob = getAsyncApexJob(log.Async_Job_Id__c, jobs, parentJobs);
            if (asyncApexJob != null) {
                Boolean isInternalError = isInternalError(asyncApexJob);
                if (!isInternalError && !apexClassNamesRaisesPlatformEvents.contains(asyncApexJob.ApexClass.Name)) {
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Async_Job_Id__c, asyncApexJob.Id.to15());
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Area__c, getArea(asyncApexJob));
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Hash__c, getHash(asyncApexJob));
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Hash_1__c, getHash1(asyncApexJob));
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Hash_2__c, getHash2(asyncApexJob));
                    PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Hash_3__c, getHash3(asyncApexJob));
                    logsToUpsert.add(log);
                }
            } else {
                logsToUpsert.add(log);
            }
        }
        if (!logsToUpsert.isEmpty()) upsertLogs(logsToUpsert, Logger.getInstance());
    }

    public static Map<Id, AsyncApexJob> getAsyncApexJobsById(Set<String> asyncApexJobIds) {
        return new Map<Id, AsyncApexJob>(
                [SELECT Id, ParentJobId, JobType, ExtendedStatus, ApexClassId, ApexClass.Name, ApexClass.NamespacePrefix, Status, CompletedDate, CreatedDate FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]
        );
    }

    public static AsyncApexJob getAsyncApexJob(String asyncApexJobId, Map<Id, AsyncApexJob> jobs, Map<Id, AsyncApexJob> parentJobs) {
        AsyncApexJob asyncApexJob = jobs.get(asyncApexJobId);
        if (String.isNotBlank(asyncApexJob?.ParentJobId) && parentJobs.containsKey(asyncApexJob.ParentJobId)) {
            asyncApexJob = parentJobs.get(asyncApexJob.ParentJobId);
        }
        return asyncApexJob;
    }

    public static String getArea(AsyncApexJob asyncApexJob) {
        String jobExtendedStatus = getJobExtendedStatus(asyncApexJob.ExtendedStatus);
        String area = BACKGROUND_JOB_TYPES.contains(asyncApexJob.JobType) ? AREA_BACKGROUND_JOB : AREA_ASYNC_APEX;
        if (String.isNotBlank(jobExtendedStatus)) {
            Matcher matcher = ConfigUtil.SOBJECT_ID_PATTERN.matcher(jobExtendedStatus);
            while (matcher.find()) {
                try {
                    Id temporaryId = Id.valueOf(matcher.group());
                    area = temporaryId.getSobjectType().getDescribe().getName();
                    break;
                } catch (Exception e) {}
            }
        }
        return area;
    }

    public static String getHash(AsyncApexJob asyncApexJob) {
        String jobApexClassName = getJobApexClassName(asyncApexJob);
        String jobExtendedStatus = getJobExtendedStatus(asyncApexJob.ExtendedStatus);
        return LogService.generateHash_0(jobApexClassName + jobExtendedStatus + asyncApexJob.JobType + asyncApexJob.Status);
    }

    public static String getHash1(AsyncApexJob asyncApexJob) {
        String jobApexClassName = getJobApexClassName(asyncApexJob);
        String jobExtendedStatus = getJobExtendedStatus(asyncApexJob.ExtendedStatus);
        return LogService.generateHash_1(jobApexClassName + jobExtendedStatus + asyncApexJob.JobType);
    }

    public static String getHash2(AsyncApexJob asyncApexJob) {
        String jobApexClassName = getJobApexClassName(asyncApexJob);
        String jobExtendedStatus = getJobExtendedStatus(asyncApexJob.ExtendedStatus);
        return LogService.generateHash_1(jobApexClassName + jobExtendedStatus);
    }

    public static String getHash3(AsyncApexJob asyncApexJob) {
        String jobApexClassName = getJobApexClassName(asyncApexJob);
        return LogService.generateHash_1(jobApexClassName);
    }

}