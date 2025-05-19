public with sharing class BulkAPIJobBatchScheduler extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<JobsResponse>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, Schedulable {

    private static final String START_QUERY_LOCATOR = '/services/data/v54.0/jobs/ingest';
    private String queryLocator = '';
    private Set<String> setJobIds = new Set<String>();
    private Boolean rescheduleRequired = false;
    private static final Set<String> SET_STATES = new Set<String>{'Closed', 'JobComplete'};
    private static final Integer JOB_LIMIT = 100;

    public Set<String> setFailedJobIds = new Set<String>();

    public BulkAPIJobBatchScheduler() {}

    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }

    private static BulkAPIJobBatchScheduler instance = null;

    public static BulkAPIJobBatchScheduler getInstance(String queryLocator) {
        if (instance == null) {
            instance = new BulkAPIJobBatchScheduler(queryLocator, Logger.getInstance());
        }
        return instance;
    }

    private BulkAPIJobBatchScheduler(String queryLocator, Logger logger) {
        super(logger);
        this.queryLocator = String.isNotBlank(queryLocator) ? queryLocator : START_QUERY_LOCATOR;
        this.BATCH_SCOPE = 10;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck(new List<String>{'BulkAPIJobBatchScheduler', 'BulkAPIJobBatch', 'BulkAPIJobChunksBatch'}, this);
    }

    public override Integer getIterationsCount() {
        return System.Limits.getLimitCallouts() - System.Limits.getCallouts();
    }

    public Iterable<JobsResponse> start(Database.BatchableContext BC) {
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_FAILED_JOB_IDS);
        if (cacheObject != null) {
            setFailedJobIds.addAll((Set<String>)cacheObject);
        }
        return new CustomIterable(this.queryLocator, this.loggerInstance);
    }

    public void execute(Database.BatchableContext BC, List<JobsResponse> scope) {
        List<String> asyncJobIds = new List<String>();
        for (JobsResponse jobsResponse : scope) {
            for (Job job : jobsResponse.records) {
                if (System.now().addDays(-1).date() <= job.systemModstamp) {
                    asyncJobIds.add(job.id);
                }
            }
        }
        List<List<String>> chunksAsyncJobIds = splitList(asyncJobIds);
        Set<String> setExistingJobIds = new Set<String>();
        for (List<String> chunkAsyncJobIds : chunksAsyncJobIds) {
            if (!chunkAsyncJobIds.isEmpty()
                    && System.Limits.getLimitQueries() - System.Limits.getQueries() > 0
                    && System.Limits.getLimitCallouts() - System.Limits.getCallouts() > 0) {
                for (Log__c log : BulkAPIJobBatchService.getLogsLastFewDays(chunkAsyncJobIds)) {
                    setExistingJobIds.add(log.Async_Job_Id__c);
                }
                setExistingJobIds.addAll(setFailedJobIds);
            }
        }
        for (JobsResponse jobsResponse : scope) {
            for (Job job : jobsResponse.records) {
                if (!setExistingJobIds.contains(job.id) && System.now().addDays(-1).date() <= job.systemModstamp && SET_STATES.contains(job.state)) {
                    setJobIds.add(job.id);
                }
                if (setJobIds.size() >= JOB_LIMIT) {
                    rescheduleRequired = true;
                    break;
                }
            }
            if (rescheduleRequired) break;
            queryLocator = jobsResponse.nextRecordsUrl;
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (!setJobIds.isEmpty()) {
            BulkAPIJobBatch.getInstance(setJobIds, queryLocator, rescheduleRequired).startBatch();
        }
        this.loggerInstance?.flush();
    }

    public static List<List<String>> splitList(List<String> asyncJobIds) {
        Integer chunkSize = 500;
        List<List<String>> chunksAsyncJobIds = new List<List<String>>();
        for (Integer i = 0; i < Math.ceil(asyncJobIds.size() / Decimal.valueOf(chunkSize)); i++){
            Integer a = i * chunkSize;
            Integer b = (i + 1) * chunkSize;
            b = (b > asyncJobIds.size()) ? asyncJobIds.size() : b;
            List<String> partAsyncJobIds = sliceList(asyncJobIds, a, b);
            if (!partAsyncJobIds.isEmpty()) {
                chunksAsyncJobIds.add(partAsyncJobIds);
            }
        }
        return chunksAsyncJobIds;
    }

    public static String[] sliceList(String[] arr, Integer first, Integer last) {
        String[] res = arr.clone(), temp;
        Integer size = arr.size(),
                startIndex = Math.min(size, Math.max(-1, first < 0 ? size + first : first)),
                endIndex = Math.min(size, Math.max(-1, last < 0 ? size + last : last - 1)),
                offset = Math.max(-1, endIndex - startIndex);
        temp = new String[offset + 1];
        for (Integer h = 0, i = startIndex, j = endIndex; i <= j;) {
            temp[h++] = arr[i++];
        }
        res.clear();
        res.addAll(temp);
        return res;
    }

    public class CustomIterable implements Iterable<JobsResponse> {

        private String queryLocator;
        private Logger loggerInstance;

        public CustomIterable(String queryLocator, Logger logger) {
            this.queryLocator = queryLocator;
            this.loggerInstance = logger;
        }

        public Iterator<JobsResponse> iterator() {
            return new CustomIterator(queryLocator, loggerInstance);
        }

    }

    public class CustomIterator implements Iterator<JobsResponse> {

        private String queryLocator;
        private Connected_Org__c corg;
        private List<JobsResponse> jobsResponses;
        private Integer currentIndex;
        private Logger loggerInstance;

        public CustomIterator(String queryLocator, Logger logger) {
            this.queryLocator = queryLocator;
            this.loggerInstance = logger;
            corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            jobsResponses = new List<JobsResponse>();
            currentIndex = 0;
        }

        public Boolean hasNext() {
            if (corg != null
                    && String.isNotBlank(queryLocator)
                    && System.Limits.getLimitCallouts() - System.Limits.getCallouts() > 0) {
                JobsResponse jobsResponse = getAllJobs();
                if (jobsResponse == null) return false;
                jobsResponses.add(jobsResponse);
                queryLocator = jobsResponses[currentIndex].nextRecordsUrl;
                return true;
            } else {
                return false;
            }
        }

        public JobsResponse next() {
            return jobsResponses[currentIndex++];
        }

        public JobsResponse getAllJobs() {
            String responseBody;
            try {
                Map<String, String> headers = ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg, this.loggerInstance));
                responseBody = HttpUtils.get(
                        corg.Instance_Url__c + queryLocator,
                        headers,
                        200
                );
                return (BulkAPIJobBatchScheduler.JobsResponse)JSON.deserialize(responseBody, BulkAPIJobBatchScheduler.JobsResponse.class);
            }
            catch (Exception e) {
                String logDetails = 'getAllJobs: ' + responseBody + '\n headers: ' + CacheUtils.generateHash(ConnectedOrgService.getSelfConnectedOrgAccessToken());
                loggerInstance?.add(loggerInstance.getInternalError(e, corg?.Name, BulkAPIJobBatchScheduler.class.getName(), logDetails));
            }
            return null;
        }

    }

    public class JobsResponse {
        String nextRecordsUrl;
        public List<Job> records;
    }

    public class Job {
        String id;
        String state;
        Datetime systemModstamp;
    }

}