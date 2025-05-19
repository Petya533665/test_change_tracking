public with sharing class BulkAPIJobBatchService {

    public static final String BULK_API = 'Bulk API';

    public static final String TYPE_BULK_API_V1 = 'Bulk API v1';
    public static final String TYPE_BULK_API_V2 = 'Bulk API v2';
    public static final String JOB_TYPE_BULK_API_V1 = 'Classic';
    public static final String JOB_TYPE_BULK_API_V2 = 'V2Ingest';

    public static final String SOBJECT_ID_MASK = '***************';
    public static final String DIGIT_MASK = '*';

    public static final String HEADER = 'header';
    public static final String TOTAL_RECORDS = 'total_records';

    public static final String BULK_JOB_PREFIX = 'bulk_job_';
    public static final String BULK_JOB_SUMMARY_PREFIX = 'bulk_job_summary_';

    public static final Integer BULK_LOGS_QUERY_WINDOW_DAYS = -3;

    public static final String DEFAULT_LINE_ENDING = '\n';
    public static final String DEFAULT_COLUMN_DELIMITER = ',';
    public static final Pattern ESC_PATTERN = Pattern.compile('(")');

    public static final Map<String, String> MAP_DELIMITERS = new Map<String, String>{
            'BACKQUOTE' => '`',
            'CARET' => '^',
            'COMMA' => ',',
            'PIPE' => '|',
            'SEMICOLON' => ';',
            'TAB' => '  '
    };

    public static final Map<String, String> MAP_LINE_ENDINGS = new Map<String, String>{
            'LF' => '\n',
            'CRLF' => '\r\n'
    };

    public enum ContentType {
        CSV,
        JSON,
        XML,
        ZIP_CSV,
        ZIP_JSON,
        ZIP_XML
    }
    public static final String CONTENT_TYPE_CSV = 'CSV';
    public static final String CONTENT_TYPE_JSON = 'JSON';
    public static final String CONTENT_TYPE_XML = 'XML';
    public static final String CONTENT_TYPE_ZIP_CSV = 'ZIP_CSV';
    public static final String CONTENT_TYPE_ZIP_JSON = 'ZIP_JSON';
    public static final String CONTENT_TYPE_ZIP_XML = 'ZIP_XML';
    public static final Map<String, ContentType> MAP_CONTENT_TYPE = new Map<String, ContentType>{
            CONTENT_TYPE_CSV => ContentType.CSV,
            CONTENT_TYPE_JSON => ContentType.JSON,
            CONTENT_TYPE_XML => ContentType.XML,
            CONTENT_TYPE_ZIP_CSV => ContentType.ZIP_CSV,
            CONTENT_TYPE_ZIP_JSON => ContentType.ZIP_JSON,
            CONTENT_TYPE_ZIP_XML => ContentType.ZIP_XML
    };

    public static Boolean isPassthroughMode() {
        return ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c && String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c);
    }

    public static Log__c createLog(Connected_Org__c corg, Job job, Set<String> setErrorCodes, Set<String> setRelatedIds, Logger logger) {
        String type = '';
        if (job.jobType == JOB_TYPE_BULK_API_V1) {
            type = TYPE_BULK_API_V1;
        } else if (job.jobType == JOB_TYPE_BULK_API_V2) {
            type = TYPE_BULK_API_V2;
        }
        List<String> lstErrorCodes = new List<String>(setErrorCodes);
        lstErrorCodes.sort();
        BulkAPIProperty bulkAPIProperty = new BulkAPIProperty();
        bulkAPIProperty.apiVersion = type;
        if (String.isNotBlank(job.systemModstamp)) {
            try {
                bulkAPIProperty.validUntilDate = Datetime.valueOfGmt(job.systemModstamp.replace('T', ' ').replace('.000', '').replace('+0000', '')).addDays(7);
            } catch (Exception e) {
                logger?.addInternalError(e, job.id, BulkAPIJobBatchService.class.getName(), 'createLog');
            }
        }
        List<User> users = [SELECT Id, Name FROM User WHERE Id = :job.createdById];
        SObjectType sObjectType = Schema.getGlobalDescribe().get(job.obj);
        String area = sObjectType != null ? sObjectType.getDescribe().getLabelPlural() : job.obj;
        return LogBuilder.getInstance()
                .category('Bulk API')
                .summary(getSummary(job, lstErrorCodes))
                .area(area)
                .type(type)
                .attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.Name, JSON.serialize(setRelatedIds))
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.Name, corg.Name)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Name__c.Name, corg.Title__c)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Url__c.Name, corg.Instance_Url__c)
                .attribute(Schema.SObjectType.Log__c.fields.Async_Job_Id__c.Name, job.id)
                .attribute(Schema.SObjectType.Log__c.fields.Apex_Name__c.Name, job.operation)
                .attribute(Schema.SObjectType.Log__c.fields.Stacktrace__c.Name, JSON.serialize(bulkAPIProperty))
                .attribute(Schema.SObjectType.Log__c.fields.User_Id__c.Name, job.createdById)
                .attribute(Schema.SObjectType.Log__c.fields.User_Name__c.Name, !users.isEmpty() ? users[0].Name : null)
                .attribute(Schema.SObjectType.Log__c.fields.Hash__c.Name, LogService.generateHash_0(String.join(lstErrorCodes, ',')))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_1__c.Name, LogService.generateHash_1(job.obj + job.operation + job.jobType + job.apiVersion + String.join(lstErrorCodes, ',')))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_2__c.Name, LogService.generateHash_2(job.obj + job.operation + job.jobType + job.apiVersion))
                .attribute(Schema.SObjectType.Log__c.fields.Hash_3__c.Name, LogService.generateHash_3(job.obj + job.operation + job.jobType))
                .createIssue()
                .build();
    }

    public static void insertLog(List<Log__c> logs, Logger logger) {
        if (isPassthroughMode()) {
            PassthroughtModeService.sendLogs(logs);
        } else {
            DatabaseUtils.getInstance().performInsertDML(logs, Schema.SObjectType.Log__c)
                    .handleError(BulkAPIJobBatchService.class.getName(), '.insertLog', logger);
        }
    }

    public static String getSummary(Job job, List<String> lstErrorCodes) {
        return job.obj + ' (' + job.operation + ') ' + job.numberRecordsProcessed + '/' + job.numberRecordsFailed + ' : ' + String.join(new List<String>(lstErrorCodes), ',');
    }

    public static void createContentVersion(Job job, Blob contentVersionBlob, Boolean isSummary, Logger logger) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.Title = (isSummary ? BULK_JOB_SUMMARY_PREFIX : BULK_JOB_PREFIX) + job.id + '.' + job.contentType.remove('ZIP_');
        contentVersion.PathOnClient = (isSummary ? BULK_JOB_SUMMARY_PREFIX : BULK_JOB_PREFIX) + job.id + '.' + job.contentType.remove('ZIP_');
        insertContentVersion(contentVersion, contentVersionBlob, logger);
    }

    public static void insertContentVersion(ContentVersion contentVersion, Blob contentVersionBlob, Logger logger) {
        if (isPassthroughMode()) {
            PassthroughtModeService.sendContentVersion(new ContentVersionWrapper(contentVersion, contentVersionBlob.toString()));
        } else {
            contentVersion.VersionData = contentVersionBlob;
            DatabaseUtils.getInstance().performInsertDML(new List<ContentVersion>{contentVersion}, Schema.SObjectType.ContentVersion)
                    .handleError(BulkAPIJobBatchService.class.getName(), '.insertContentVersion', logger);
        }
    }

    public static void createContentDocumentLinks(Set<String> setJobIds) {
        Set<String> setSearchStrings = new Set<String>();
        for (String jobId : setJobIds) {
            setSearchStrings.add(BULK_JOB_PREFIX + jobId + '%');
            setSearchStrings.add(BULK_JOB_SUMMARY_PREFIX + jobId + '%');
        }
        List<ContentVersion> lstContentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title LIKE :setSearchStrings];
        if (!lstContentVersions.isEmpty()) {
            Set<String> setContentDocumentIds = new Set<String>();
            List<ContentDocumentLink> lstContentDocumentLinks = new List<ContentDocumentLink>();
            for (Log__c log : [SELECT Id, Async_Job_Id__c FROM Log__c WHERE Async_Job_Id__c IN :setJobIds]) {
                for (ContentVersion contentVersion : lstContentVersions) {
                    if (contentVersion.Title.contains(log.Async_Job_Id__c)) {
                        setContentDocumentIds.add(contentVersion.ContentDocumentId);
                        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                        contentDocumentLink.LinkedEntityId = log.Id;
                        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
                        contentDocumentLink.ShareType = 'V';
                        lstContentDocumentLinks.add(contentDocumentLink);
                    }
                }
            }
            List<ContentDocumentLink> lstContentDocumentLinksExist = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :setContentDocumentIds];
            List<ContentDocumentLink> lstContentDocumentLinksForInsert = new List<ContentDocumentLink>();
            for (ContentDocumentLink contentDocumentLink : lstContentDocumentLinks) {
                Boolean exist = false;
                for (ContentDocumentLink contentDocumentLinkExist : lstContentDocumentLinksExist) {
                    if (contentDocumentLink.ContentDocumentId == contentDocumentLinkExist.ContentDocumentId && contentDocumentLink.LinkedEntityId == contentDocumentLinkExist.LinkedEntityId) {
                        exist = true;
                        break;
                    }
                }
                if (!exist) {
                    lstContentDocumentLinksForInsert.add(contentDocumentLink);
                }
            }
            if (!lstContentDocumentLinksForInsert.isEmpty()) {
                insert lstContentDocumentLinksForInsert;
            }
        }
    }

    public static List<Log__c> getLogsLastFewDays(List<String> asyncJobIds) {
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>{'Id', Log__c.Async_Job_Id__c.getDescribe().getName()})
                .add(QBuilder.condition(Log__c.Async_Job_Id__c.getDescribe().getName()).isIn(asyncJobIds))
                .add(QBuilder.condition(Log__c.Created_At__c.getDescribe().getName()).isGreaterOrEquals(System.now().addDays(BULK_LOGS_QUERY_WINDOW_DAYS)))
                .build();
        return (List<Log__c>)JSON.deserialize(JSON.serialize(runQuery(ConnectedOrgService.getPassthroughConnectedOrg(), query)), List<Log__c>.class);
    }

    public static List<Object> runQuery(Connected_Org__c corg, String q) {
        return isPassthroughMode() ? HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), q) : Database.query(q);
    }

    public static List<String> rowSplitter(String row, Pattern pattern) {
        List<String> lstRowParts = new List<String>();
        for (String rowPart : pattern.split(row, -1)) {
            lstRowParts.add(String.isNotBlank(rowPart) && rowPart.startsWith('"') && rowPart.endsWith('"') ? rowPart.substring(1, rowPart.length() - 1) : rowPart);
        }
        return lstRowParts;
    }

    public class RowIterator implements Iterator<String>, Iterable<String> {

        private String fileData;
        private String lineEnding = DEFAULT_LINE_ENDING;
        private Integer index = 0;

        public RowIterator(String fileData, String lineEnding) {
            this.fileData = fileData;
            this.lineEnding = lineEnding;
        }

        public Boolean hasNext() {
            return fileData.length() > index && fileData.length() > 2 ? true : false;
        }

        public String next() {
            // Detect the line ending, for example file could have mixed line endings ("Text \n Area","Text"\n)
            String row;
            Integer currentIndex = index;
            while (String.isBlank(row)) {
                Integer key = fileData.indexOf(lineEnding, currentIndex);
                if (key == -1) key = fileData.length();
                String subRow = fileData.substring(index, key);
                if (Math.mod(subRow.countMatches('"'), 2) == 0) row = fileData.substring(index, fileData.length() > key ? key + 1 : key);
                currentIndex = key + 1;
            }
            index = 0;
            fileData = fileData.substringAfter(row);
            return row.removeEnd('\r\n').removeEnd('\n').removeEnd('\r');
        }

        public Iterator<String> iterator() {
            return this;
        }

    }

    public class Job {
        public String id;
        public String apiVersion;
        public String contentType;
        public String jobType;
        public String columnDelimiter;
        public String lineEnding;
        public String obj;
        public String operation;
        public String createdById;
        public String systemModstamp;
        public Long numberRecordsFailed;
        public Long numberRecordsProcessed;
        public Job() {}
        public Job(Job job) {
            id = job.id;
            apiVersion = job.apiVersion;
            contentType = job.contentType;
            jobType = job.jobType;
            columnDelimiter = job.columnDelimiter;
            lineEnding = job.lineEnding;
            obj = job.obj;
            operation = job.operation;
            createdById = job.createdById;
            systemModstamp = job.systemModstamp;
            numberRecordsFailed = job.numberRecordsFailed;
            numberRecordsProcessed = job.numberRecordsProcessed;
        }
    }

    public class JobWithBatches {
        public Job job;
        public Set<String> setBatchIds;
        public JobWithBatches(Job job, Set<String> setBatchIds) {
            this.job = job;
            this.setBatchIds = setBatchIds;
        }
    }

    public class ContentVersionWrapper {
        public ContentVersion contentVersion;
        public String contentVersionData;
        public ContentVersionWrapper(ContentVersion contentVersion, String contentVersionData) {
            this.contentVersion = contentVersion;
            this.contentVersionData = contentVersionData;
        }
    }

    public class BulkAPIProperty {
        public String apiVersion;
        public Datetime validUntilDate;
    }

}