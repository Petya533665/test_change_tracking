public with sharing class BulkAPIJobBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private String queryLocator;
    private Boolean rescheduleRequired;
    private Set<String> setJobIds;
    private Connected_Org__c corg;
    private String urlJobInfo = '/services/data/v54.0/jobs/ingest/{0}';
    private String urlJobBatches = '/services/async/{1}/job/{0}/batch';
    private List<BulkAPIJobBatchService.JobWithBatches> lstJobWithBatches = new List<BulkAPIJobBatchService.JobWithBatches>();

    private static BulkAPIJobBatch instance = null;

    public static BulkAPIJobBatch getInstance(Set<String> setJobIds, String queryLocator, Boolean rescheduleRequired) {
        if (instance == null) {
            instance = new BulkAPIJobBatch(setJobIds, queryLocator, rescheduleRequired, Logger.getInstance());
        }
        return instance;
    }

    private BulkAPIJobBatch(Logger logger) {
        super(logger);
    }

    private BulkAPIJobBatch(Set<String> setJobIds, String queryLocator, Boolean rescheduleRequired, Logger logger) {
        super(logger);
        this.setJobIds = setJobIds;
        this.queryLocator = queryLocator;
        this.rescheduleRequired = rescheduleRequired;
        corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
        BATCH_SCOPE = Integer.valueOf(System.Limits.getLimitCallouts() / 2);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck(new List<String>{'BulkAPIJobBatch', 'BulkAPIJobChunksBatch'}, this);
    }

    public override Integer getIterationsCount() {
        return System.Limits.getLimitCallouts();
    }

    public Iterable<String> start(Database.BatchableContext BC) {
        return new List<String>(setJobIds);
    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
        if (corg != null) {
            for (String jobId : scope) {
                try {
                    BulkAPIJobBatchService.Job job = getJob(jobId);
                    if (job != null && job.numberRecordsFailed > 0) {
                        if (job.jobType == BulkAPIJobBatchService.JOB_TYPE_BULK_API_V1) {
                            Set<String> setBatchIds = getSetBatchIds(job.id, job.apiVersion);
                            if (setBatchIds != null && !setBatchIds.isEmpty()) {
                                lstJobWithBatches.add(new BulkAPIJobBatchService.JobWithBatches(job, setBatchIds));
                            }
                        } else if (job.jobType == BulkAPIJobBatchService.JOB_TYPE_BULK_API_V2) {
                            lstJobWithBatches.add(new BulkAPIJobBatchService.JobWithBatches(job, null));
                        }
                    }
                }
                catch (Exception e) {
                    this.loggerInstance?.add(loggerInstance.getInternalError(e, jobId, BulkAPIJobBatch.class.getName(), 'execute'));
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (!lstJobWithBatches.isEmpty()) {
            BulkAPIJobChunksBatch.getInstance(lstJobWithBatches, queryLocator, rescheduleRequired).startBatch();
        }
        this.loggerInstance?.flush();
    }

    private BulkAPIJobBatchService.Job getJob(String jobId) {
        String responseBody = HttpUtils.get(
                corg.Instance_Url__c + String.format(urlJobInfo, new List<String>{jobId}),
                ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg)),
                200
        );
        String responseJSON = responseBody.replace('object', 'obj');
        return (BulkAPIJobBatchService.Job)JSON.deserialize(responseJSON, BulkAPIJobBatchService.Job.class);
    }

    private Set<String> getSetBatchIds(String jobId, String apiVersion) {
        String responseBody = HttpUtils.get(
                corg.Instance_Url__c + String.format(urlJobBatches, new List<String>{jobId, apiVersion}),
                new Map<String, String>{'X-SFDC-Session' => ConnectedOrgService.getSelfConnectedOrgAccessToken()},
                200
        );
        Set<String> setBatchIds = new Set<String>();
        if (responseBody.substring(0, 5).contains('<?xml')) {
            Dom.Document document = new Dom.Document();
            document.load(responseBody);
            String xmlns = document.getRootElement().getNamespace();
            for (Dom.XmlNode child : document.getRootElement().getChildElements()) {
                if (Integer.valueOf(child.getChildElement('numberRecordsFailed', xmlns).getText()) > 0) {
                    setBatchIds.add(child.getChildElement('id', xmlns).getText());
                }
            }
        } else {
            for (Batch batch : ((BatchesResponse)JSON.deserialize(responseBody, BatchesResponse.class)).batchInfo) {
                if (batch.numberRecordsFailed > 0) {
                    setBatchIds.add(batch.id);
                }
            }
        }
        return setBatchIds;
    }

    private class BatchesResponse {
        List<Batch> batchInfo;
    }

    private class Batch {
        String id;
        Integer numberRecordsFailed;
    }

}