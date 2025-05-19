public with sharing class ErrorEmailReportBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable, Database.RaisesPlatformEvents {

    public enum JobType {UPLOAD_LOG, UPLOAD_RELATED_CV}
    public static final Integer BATCH_SCOPE_UPLOAD_LOG = 100;
    public static final Integer BATCH_SCOPE_UPLOAD_RELATED_CV = 1;
    public static final String PHAROS_ERROR_EMAIL_ADDRESS = 'errors@pharos.ai';
    public static final String PHAROS_ERROR_EMAIL_SUBJECT = 'Pharos Automated Error Email Report:' + UserInfo.getOrganizationName();
    public static final String PHAROS_ERROR_CV_EMAIL_SUBJECT = 'Pharos Automated Error Email Report CV:' + UserInfo.getOrganizationName();

    private final JobType currentJobType;

    private static final Map<JobType, Integer> MAP_SCOPE_BY_TYPE = new Map<JobType, Integer>{
        JobType.UPLOAD_LOG => BATCH_SCOPE_UPLOAD_LOG,
        JobType.UPLOAD_RELATED_CV => BATCH_SCOPE_UPLOAD_RELATED_CV
    };
    
    private Map<String, String> currentHashes = new Map<String, String>();
    private List<Log_Index__c> currentIndexes = new List<Log_Index__c>();
    private Double currentSizeEmailAttachments = 0;
    private static final Double MAX_SIZE_ATTACHMENTS_PER_EMAIL = 4000000;
    private static final Double LIMIT_USAGE_SEND_SINGLE_EMAIL = 0.8; // 80% of total;

    public class AggregateInfo {
        public String hash1;
        public String minId;
        public Integer totalOccurrences;

        public AggregateInfo(String hash1, String minId, Integer totalOccurrences) {
            this.hash1 = hash1;
            this.minId = minId;
            this.totalOccurrences = totalOccurrences;
        }
    }

    public class AggregateInfoCV {
        public String logId;
        public Decimal sumSize;

        public AggregateInfoCV(String logId, Decimal sumSize) {
            this.logId = logId;
            this.sumSize = sumSize;
        }
    }

    public ErrorEmailReportBatch() {}

    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }

    private static ErrorEmailReportBatch instance = null;

    public static ErrorEmailReportBatch getInstance(JobType jobType) {
        if (instance == null) {
            instance = new ErrorEmailReportBatch(jobType, Logger.getInstance());
        }
        return instance;
    }
    
    private ErrorEmailReportBatch(JobType jobType, Logger logger) {
        super(logger);
        this.currentJobType = jobType;
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('ErrorEmailReportBatch', this);
    }

    public override Boolean initialValidation() {
        if (PermissionsUtil.MandatoryErrorReportingEnabled && ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c) {
            ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c = false;
            DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c, true);
        }
        return !ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c;
    }

    public override Integer getIterationsCount() {
        return getCountErrorToPharosReport(currentJobType);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(this.currentJobType == JobType.UPLOAD_LOG) {
            return Database.getQueryLocator([
                SELECT Id, Hash__c 
                FROM Log_Index__c 
                WHERE Internal__c = TRUE
                    AND Organization_Id__c = :UserInfo.getOrganizationId().left(15)
                    AND Reported_to_Pharos_On__c = NULL
            ]);
        }
        else if (this.currentJobType == JobType.UPLOAD_RELATED_CV) {
            return Database.getQueryLocator([
                SELECT Id, Hash__c
                FROM Log_Index__c
                WHERE Internal__c = TRUE
                    AND Organization_Id__c = :UserInfo.getOrganizationId().left(15)
                    AND CV_Reported_to_Pharos_On__c = NULL
            ]);
        }
        else return null;
	}


	public void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            if(this.currentJobType == JobType.UPLOAD_LOG) {
                List<Log_Index__c> indexes = (List<Log_Index__c>)scope;
                Map<String, AggregateInfo> aggregateInfoMap = getAggregateInfoMap(indexes);
                List<Log__c> logs = getLogsByIndexes(indexes, aggregateInfoMap);
                Map<String, String> comments = createLogsComments(logs, aggregateInfoMap);
                sendEmailReport(logs, comments, indexes, loggerInstance);
            }
            else if (this.currentJobType == JobType.UPLOAD_RELATED_CV) {
                List<Log_Index__c> indexes = (List<Log_Index__c>)scope;
                List<ContentDocumentLink> files = getContentDocumentLinksByIndexes(indexes);
                Map<String, String> mapHashes = getMapLogHashByFileId(files);
                Double filesSize = getFilesSize(files);
                if((this.currentSizeEmailAttachments + filesSize) < MAX_SIZE_ATTACHMENTS_PER_EMAIL) {
                    this.currentHashes.putAll(mapHashes);
                    this.currentIndexes.addAll(indexes);
                    this.currentSizeEmailAttachments += filesSize;
                    
                }
                else {
                    sendEmailReport(this.currentIndexes, this.currentHashes, loggerInstance);
                    this.currentSizeEmailAttachments = 0;
                    this.currentHashes = new Map<String, String>();
                    this.currentIndexes = new List<Log_Index__c>();
                }
            }
        }
        catch (Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, ErrorEmailReportBatch.class.getName(), 'sendEmailReport'));
        }
    }

    public void finish(Database.BatchableContext BC) {
        // send last chunk
        if(this.currentJobType == JobType.UPLOAD_RELATED_CV && !this.currentHashes?.isEmpty()) {
            sendEmailReport(this.currentIndexes, this.currentHashes, loggerInstance);
        }
        if(!Test.isRunningTest() && this.currentJobType == JobType.UPLOAD_LOG) {
            ErrorEmailReportBatch.getInstance(JobType.UPLOAD_RELATED_CV).startBatch();
        }
        loggerInstance?.flush();
    }

    public static Map<String, AggregateInfo> getAggregateInfoMap(List<Log_Index__c> indexes) {
        Map<String, AggregateInfo> result = new Map<String, AggregateInfo>();
        Set<String> hashes = new Set<String>();
        for(Log_Index__c li : indexes) {
            hashes.add(li.Hash__c);
        }
        List<AggregateResult> aggregateResults = [
            SELECT COUNT(Id) totalOccurrences,
                    Hash_1__c hash1,
                    MIN(Id) minId
            FROM Log__c
            WHERE Hash_1__c IN :hashes
                AND Organization_Id__c = :UserInfo.getOrganizationId().left(15)
                AND (Category__c = :Logger.CATEGORY_PHAROS_ERROR
                    OR Area__c = :Logger.AREA_PHAROS_ERROR)
            GROUP BY Hash_1__c];
        for (AggregateResult ar : aggregateResults) {
            String hash1 = (String)ar.get('hash1');
            String minId = (String)ar.get('minId');
            Integer totalOccurrences = (Integer)ar.get('totalOccurrences');
            
            result.put(hash1, new AggregateInfo(hash1, minId, totalOccurrences));
        }
        return result;
    }

    public static List<Log__c> getLogsByIndexes(List<Log_Index__c> logIndexes, Map<String, AggregateInfo> aggregateInfoMap) {
        Set<String> logIds = new Set<String>();
        for(Log_Index__c li : logIndexes) {
            AggregateInfo agrInfo = aggregateInfoMap?.get(li.Hash__c);
            logIds.add(agrInfo.minId);
        }
        return [
            SELECT Id, Category__c, Area__c,
                Summary__c, Details__c, Organization_Id__c,
                First_Occurred_On__c, Type__c, Created_At__c, Hash_1__c
            FROM Log__c 
            WHERE Id IN :logIds
        ]; 
    }

    public static Map<String, String> getMapLogHashByFileId(List<ContentDocumentLink> files) {
        Map<String, String> result = new Map<String, String>();
        Set<String> parentIds = new Set<String>();
        for(ContentDocumentLink file : files) {
            parentIds.add(file.LinkedEntityId);
        }
        List<Log__c> logs = [SELECT Id, Hash_1__c FROM Log__c WHERE Id IN :parentIds];
        for(Log__c log : logs) {
            for(ContentDocumentLink file : files) {
                if(log.Id == file.LinkedEntityId) {
                    result.put(file.Id, log.Hash_1__c);
                }
            }
        }
        return result;
    }

    public static List<ContentDocumentLink> getContentDocumentLinksByIndexes(List<Log_Index__c> logIndexes) {
        Set<String> logHashes = new Set<String>();
        for(Log_Index__c li : logIndexes) {
            logHashes.add(li.Hash__c);
        }
        return [
            SELECT
                LinkedEntityId,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.ContentSize,
                ContentDocument.LatestPublishedVersion.PathOnClient
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN (SELECT Id FROM Log__c WHERE Hash_1__c IN :logHashes)
        ]; 
    }

    public static List<ContentDocumentLink> getFiles(Map<String, String> hashes) {
        return [
            SELECT
                LinkedEntityId,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.VersionData,
                ContentDocument.LatestPublishedVersion.ContentSize,
                ContentDocument.LatestPublishedVersion.PathOnClient
            FROM ContentDocumentLink 
            WHERE Id IN :hashes.keySet()
        ]; 
    }

    public static Integer getCountErrorToPharosReport(JobType jobType) {
        if(jobType == ErrorEmailReportBatch.JobType.UPLOAD_LOG) {
            return [
                SELECT COUNT() 
                FROM Log_Index__c 
                WHERE Internal__c = TRUE
                    AND Organization_Id__c = :UserInfo.getOrganizationId().left(15)
                    AND Reported_to_Pharos_On__c = NULL
                    AND Type__c = :ConfigUtil.LOG_INDEX_TYPE_HASH1
            ];
        }
        else if(jobType == ErrorEmailReportBatch.JobType.UPLOAD_RELATED_CV) {
            return [
                SELECT COUNT() 
                FROM Log_Index__c 
                WHERE Internal__c = TRUE
                    AND Organization_Id__c = :UserInfo.getOrganizationId().left(15)
                    AND CV_Reported_to_Pharos_On__c = NULL
                    AND Type__c = :ConfigUtil.LOG_INDEX_TYPE_HASH1
            ];
        }
        else return 0;
    }

    public static List<Log_Index__c> getIndexesByLogs(List<Log__c> logs) {
        List<Log_Index__c> result = new List<Log_Index__c>();
        Set<String> logIndexKeys = new Set<String>();
        
        for(Log__c log : logs) {
            logIndexKeys.add(ConfigUtil.getLogIndexKey(log?.Hash_1__c, log?.Organization_Id__c));
        }

        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(logIndexKeys);
        for(Log__c log : logs) {
            ConfigUtil.LogIndex index = helper.getLogIndex(log);
            result.add(new Log_Index__c(Id = index.id));
        }
        return result;
    }

    public static void sendEmailReport(List<Log__c> logs, Map<String, String> comments, Logger logger) {
        List<Log_Index__c> indexes = getIndexesByLogs(logs);
        sendEmailReport(logs, comments, indexes, true, logger);
    }

    public static void sendEmailReport(List<Log__c> logs, Map<String, String> comments, List<Log_Index__c> indexes, Logger logger) {
        sendEmailReport(logs, comments, indexes, false, logger);
    }

    public static void sendEmailReport(List<Log__c> logs, Map<String, String> comments, List<Log_Index__c> indexes, Boolean isManualReport, Logger logger) {
        try {
            if(!LimitsService.isAvailableSingleEmail(LIMIT_USAGE_SEND_SINGLE_EMAIL)) return;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>{PHAROS_ERROR_EMAIL_ADDRESS};
            if(String.isNotBlank(ConfigUtil.SETTINGS.Error_Report_CC_emails__c)) {
                List<String> parts = ConfigUtil.SETTINGS.Error_Report_CC_emails__c.split(',');
                toAddresses.addAll(parts);
            }
            email.setSubject(PHAROS_ERROR_EMAIL_SUBJECT);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(getErrorEmailText(comments, isManualReport));
            email.setFileAttachments(createEmailAttachments(logs));
            email.setSaveAsActivity(true);

            Messaging.SendEmailResult[] sendResults =
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            if(!sendResults.isEmpty() && sendResults.get(0).isSuccess()) {
                setReported(indexes, logger);
            }
        }
        catch(Exception e) {
            logger?.add(logger.getInternalError(e, null, ErrorEmailReportBatch.class.getName(), 'sendEmailReportLogs'));
        }
    }

    public static void sendEmailReport(List<Log_Index__c> indexes, Map<String, String> hashes, Logger logger) {
        try {
            if(!LimitsService.isAvailableSingleEmail(LIMIT_USAGE_SEND_SINGLE_EMAIL)) return;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>{PHAROS_ERROR_EMAIL_ADDRESS};
            if(String.isNotBlank(ConfigUtil.SETTINGS.Error_Report_CC_emails__c)) {
                List<String> parts = ConfigUtil.SETTINGS.Error_Report_CC_emails__c.split(',');
                toAddresses.addAll(parts);
            }
            email.setSubject(PHAROS_ERROR_CV_EMAIL_SUBJECT);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(getErrorEmailText());
            email.setFileAttachments(createEmailAttachments(hashes));
            email.setSaveAsActivity(true);

            Messaging.SendEmailResult[] sendResults =
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            if(!sendResults.isEmpty() && sendResults.get(0).isSuccess()) {
                setReportedCV(indexes, logger);
            }
        }
        catch(Exception e) {
            logger?.add(logger.getInternalError(e, null, ErrorEmailReportBatch.class.getName(), 'sendEmailReportCV'));
        }
    }

    public static Double getFilesSize(List<ContentDocumentLink> files) {
        Double result = 0;
        for(ContentDocumentLink file : files) {
            if(String.isNotBlank(file?.ContentDocument?.LatestPublishedVersionId)) {
                result += file.ContentDocument.LatestPublishedVersion.ContentSize;
            }
        }
        return result;
    }

    public static List<Messaging.EmailFileAttachment> createEmailAttachments(Map<String, String> mapHashes) {
        List<Messaging.EmailFileAttachment> result = new List<Messaging.EmailFileAttachment>();

        List<ContentDocumentLink> files = getFiles(mapHashes);

        for(ContentDocumentLink file : files) {
            if(String.isNotBlank(file?.ContentDocument?.LatestPublishedVersionId)) {
                List<String> fileNameParts = new List<String>{
                    mapHashes.get(file.Id),
                    file.ContentDocument.LatestPublishedVersion.PathOnClient
                };
                // hash1---filename.txt
                String fileName = String.join(fileNameParts, '---') + '.txt';
                Blob b = Blob.valueOf(EncodingUtil.base64Encode(file.ContentDocument.LatestPublishedVersion.VersionData));
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(fileName);
                efa.setBody(b);
                result.add(efa);
            }
        }
        return result;
    }

    public static String getErrorEmailText() {
        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put('organizationId', UserInfo.getOrganizationId());
        objectMap.put('organizationName', UserInfo.getOrganizationName());
        objectMap.put('reportedBy', UserInfo.getName());
        return JSON.serialize(objectMap);
    }

    public static String getErrorEmailText(Map<String, String> comments, Boolean isManualReport) {
        Map<String, Object> objectMap = new Map<String, Object>();
        objectMap.put('organizationId', UserInfo.getOrganizationId());
        objectMap.put('organizationName', UserInfo.getOrganizationName());
        objectMap.put('reportedBy', UserInfo.getName());
        objectMap.put('comments', comments);
        objectMap.put('isManualReport', isManualReport);
        return JSON.serialize(objectMap);
    }

    public static final String COMMENTS_FORMAT = 'Total Occurrences: {0}';

    public static Map<String, String> createLogsComments(List<Log__c> logs, Map<String, AggregateInfo> aggregateInfoMap) {
        Map<String, String> result = new Map<String, String>();

        for(Log__c log : logs) {
            AggregateInfo agrInfo = aggregateInfoMap?.get(log.Hash_1__c);
            String comment = String.format(COMMENTS_FORMAT, new List<String>{String.valueOf(agrInfo.totalOccurrences)});
            result.put(log.Id, comment);
        }
        return result;
    }

    public static List<Messaging.EmailFileAttachment> createEmailAttachments(List<Log__c> logs) {
        List<Messaging.EmailFileAttachment> result = new List<Messaging.EmailFileAttachment>();
        for(Log__c log : logs) {
            Blob b = Blob.valueOf(json.serialize(log));
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(log.Id + '.txt');
            efa.setBody(b);
            result.add(efa);
        }
        return result;
    }

    public static void setReported(List<Log_Index__c> indexes, Logger logger) {
        List<Log_Index__c> toUpdate = new List<Log_Index__c>();
        DateTime dt = DateTime.now();
        for(Log_Index__c logIndex : indexes) {
            toUpdate.add(new Log_Index__c(
                Id = logIndex.Id,
                Reported_to_Pharos_On__c = dt
            ));
        }
        DatabaseUtils.getInstance().performUpdateDML(toUpdate, Schema.SObjectType.Log_Index__c)
                .handleError(ErrorEmailReportBatch.class.getName(), '.setReported', logger);
    }

    public static void setReportedCV(List<Log_Index__c> indexes, Logger logger) {
        List<Log_Index__c> toUpdate = new List<Log_Index__c>();
        DateTime dt = DateTime.now();
        for(Log_Index__c logIndex : indexes) {
            toUpdate.add(new Log_Index__c(
                Id = logIndex.Id,
                CV_Reported_to_Pharos_On__c = dt
            ));
        }
        DatabaseUtils.getInstance().performUpdateDML(toUpdate, Schema.SObjectType.Log_Index__c)
            .handleError(ErrorEmailReportBatch.class.getName(), '.setReportedCV', logger);
    }
}