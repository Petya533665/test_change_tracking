public with sharing class BulkAPIJobChunksBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private String queryLocator;
    private Boolean rescheduleRequired;
    private Set<String> setJobWithBatchIds = new Set<String>();
    private Map<String, BulkAPIJobBatchService.Job> mapJobs = new Map<String, BulkAPIJobBatchService.Job>();
    private String batchId;
    private BulkAPIJobBatchService.Job job;
    private BulkAPIJobBatchService.Job previousJob;
    private Connected_Org__c corg;

    private String urlBatchRequest = '/services/async/{1}/job/{0}/batch/{2}/request';
    private String urlBatchResult = '/services/async/{1}/job/{0}/batch/{2}/result';
    private String urlJobFailedResults = '/services/data/v{1}/jobs/ingest/{0}/failedResults';

    private Blob contentVersionBlob;
    private Blob contentVersionSummaryBlob;
    private Blob previousContentVersionSummaryBlob;
    private Set<String> setRelatedIds = new Set<String>();
    private Set<String> setErrorCodes = new Set<String>();
    private Set<String> setSummaryErrors = new Set<String>();
    private Map<String, String> mapSummaryErrors = new Map<String, String>();
    private Map<String, String> previousMapSummaryErrors = new Map<String, String>();
    private Map<String, Integer> mapSummaryErrorsCounter = new Map<String, Integer>();
    private Map<String, Integer> previousMapSummaryErrorsCounter = new Map<String, Integer>();
    private static Map<Integer, String> mapErrors = new Map<Integer, String>();

    private static final Integer RELATED_ENTRIES_LIMIT = 50;

    private static final String REGEX_SPLITTER = '(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)';

    private static final String CSV_ROW_SUMMARY_FORMAT = '"{0}",{1},"{2}"';

    private Integer XML_STRING_LENGTH = 1000000;

    private List<Log__c> lstLogs = new List<Log__c>();

    private static BulkAPIJobChunksBatch instance = null;

    public static BulkAPIJobChunksBatch getInstance(List<BulkAPIJobBatchService.JobWithBatches> lstJobWithBatches, String queryLocator, Boolean rescheduleRequired) {
        if (instance == null) {
            instance = new BulkAPIJobChunksBatch(lstJobWithBatches, queryLocator, rescheduleRequired, Logger.getInstance());
        }
        return instance;
    }

    private BulkAPIJobChunksBatch(List<BulkAPIJobBatchService.JobWithBatches> lstJobWithBatches, String queryLocator, Boolean rescheduleRequired, Logger logger) {
        super(logger);
        Set<String> setJobWithBatchIds = new Set<String>();
        Map<String, BulkAPIJobBatchService.Job> mapJobs = new Map<String, BulkAPIJobBatchService.Job>();
        for (BulkAPIJobBatchService.JobWithBatches jobWithBatches : lstJobWithBatches) {
            mapJobs.put(jobWithBatches.job.id, jobWithBatches.job);
            if (jobWithBatches.setBatchIds != null) {
                for (String batchId : jobWithBatches.setBatchIds) {
                    setJobWithBatchIds.add(jobWithBatches.job.id + '_' + batchId);
                }
            }
            else {
                setJobWithBatchIds.add(jobWithBatches.job.id + '_');
            }
        }
        this.setJobWithBatchIds = setJobWithBatchIds;
        this.mapJobs = mapJobs;
        this.queryLocator = queryLocator;
        this.rescheduleRequired = rescheduleRequired;
        corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('BulkAPIJobChunksBatch', this);
    }

    public override Integer getIterationsCount() {
        return setJobWithBatchIds.size();
    }

    public Iterable<String> start(Database.BatchableContext BC) {
        List<String> lstJobWithBatchIds = new List<String>(setJobWithBatchIds);
        lstJobWithBatchIds.sort();
        return lstJobWithBatchIds;
    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
        if (corg != null) {
            String jobWithBatchId = scope[0];
            List<String> splitJobWithBatchId = jobWithBatchId.split('_');
            String jobId = splitJobWithBatchId[0];
            if (job != null && job.id != jobId && mapJobs.containsKey(job.id) && !mapSummaryErrorsCounter.isEmpty()) {
                previousJob = new BulkAPIJobBatchService.Job(job);
                if (contentVersionSummaryBlob != null) previousContentVersionSummaryBlob = Blob.valueOf(contentVersionSummaryBlob.toString());
                previousMapSummaryErrors = new Map<String, String>(mapSummaryErrors);
                previousMapSummaryErrorsCounter = new Map<String, Integer>(mapSummaryErrorsCounter);
                createLog();
            } else if (jobId == TestDataGenerator.TEST_1_JOB_ID) {
                job = TestDataGenerator.generateJob(TestDataGenerator.TEST_JOB_ID);
                previousJob = TestDataGenerator.generateJob(TestDataGenerator.TEST_JOB_ID);
                previousMapSummaryErrors = TestDataGenerator.MAP_SUMMARY_ERRORS;
                previousMapSummaryErrorsCounter = TestDataGenerator.MAP_SUMMARY_ERRORS_COUNTER;
                createLog();
            }
            setJobWithBatchIds.remove(jobWithBatchId);
            job = mapJobs.get(jobId);
            if (splitJobWithBatchId.size() > 1) {
                batchId = splitJobWithBatchId[1];
                switch on BulkAPIJobBatchService.MAP_CONTENT_TYPE.get(job.contentType) {
                    when XML, ZIP_XML {
                        parseResultXml();
                        parseRequestXml();
                    }
                    when JSON, ZIP_JSON {
                        parseResultJSON();
                        parseRequestJSON();
                    }
                    when CSV, ZIP_CSV {
                        parseResultCSV();
                        parseRequestCSV();
                    }
                }
            } else {
                getJobFailedRecordResults();
            }
            if (jobId != TestDataGenerator.TEST_2_JOB_ID) {
                if (contentVersionBlob != null) {
                    createContentVersion();
                }
                if (!JSON.serialize(setJobWithBatchIds).contains(job.id)) {
                    if (!mapSummaryErrorsCounter.isEmpty()) createContentVersionSummary(false);
                    createLog();
                }
                if (!previousMapSummaryErrorsCounter.isEmpty()) createContentVersionSummary(true);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (!mapSummaryErrorsCounter.isEmpty()) {
            if (contentVersionBlob != null) createContentVersion();
            createContentVersionSummary(false);
            createLog();
        }
        Set<String> setFailedJobIds = new Set<String>();
        for (String failedJobWithBatchId : setJobWithBatchIds) {
            setFailedJobIds.add(failedJobWithBatchId.split('_')[0]);
        }
        CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
        Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_FAILED_JOB_IDS);
        if (cacheObject != null) {
            setFailedJobIds.addAll((Set<String>)cacheObject);
        }
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_FAILED_JOB_IDS, setFailedJobIds);
        BulkAPIJobBatchService.insertLog(lstLogs, loggerInstance);
        loggerInstance?.flush();
        if (rescheduleRequired) {
            BulkAPIJobBatchScheduler.getInstance(queryLocator).startBatch();
        }
    }

    private void createContentVersion() {
        BulkAPIJobBatchService.createContentVersion(job, contentVersionBlob, false, loggerInstance);
        contentVersionBlob = null;
    }

    private void createContentVersionSummary(Boolean isPrevious) {
        Blob contentVersionSummaryBlob = isPrevious ? previousContentVersionSummaryBlob : contentVersionSummaryBlob ;
        BulkAPIJobBatchService.Job job = isPrevious ? previousJob : job;
        Map<String, String> mapSummaryErrors = isPrevious ? previousMapSummaryErrors : mapSummaryErrors;
        Map<String, Integer> mapSummaryErrorsCounter = isPrevious ? previousMapSummaryErrorsCounter : mapSummaryErrorsCounter;
        if (job.jobType == BulkAPIJobBatchService.JOB_TYPE_BULK_API_V1) {
            switch on BulkAPIJobBatchService.MAP_CONTENT_TYPE.get(job.contentType) {
                when XML, ZIP_XML {
                    Dom.Document summaryDocument = new Dom.Document();
                    if (contentVersionSummaryBlob != null) {
                        summaryDocument.load(contentVersionSummaryBlob.toString());
                        for (Dom.XmlNode sObjectElement : summaryDocument.getRootElement().getChildElements()) {
                            for (Dom.XmlNode sObjectFieldElement : sObjectElement.getChildElements()) {
                                if (sObjectFieldElement.getName() == 'errors') {
                                    for (Dom.XmlNode sObjectErrorElement : sObjectFieldElement.getChildElements()) {
                                        if (sObjectErrorElement.getName() == 'statusCode' && mapSummaryErrorsCounter.containsKey(sObjectErrorElement.getText())) {
                                            sObjectFieldElement.addChildElement(BulkAPIJobBatchService.TOTAL_RECORDS, null, null).addTextNode(String.valueOf(mapSummaryErrorsCounter.get(sObjectErrorElement.getText())));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    contentVersionSummaryBlob = Blob.valueOf(summaryDocument.toXmlString());
                }
                when JSON, ZIP_JSON {
                    List<Object> lstSummaryErrors = new List<Object>();
                    for (String errorCode : mapSummaryErrorsCounter.keySet()) {
                        if (mapSummaryErrors.containsKey(errorCode)) {
                            Map<String, Object> summaryObj = (Map<String, Object>)JSON.deserializeUntyped(mapSummaryErrors.get(errorCode));
                            summaryObj.put(BulkAPIJobBatchService.TOTAL_RECORDS, mapSummaryErrorsCounter.get(errorCode));
                            lstSummaryErrors.add(summaryObj);
                        }
                    }
                    contentVersionSummaryBlob = Blob.valueOf(JSON.serialize(lstSummaryErrors));
                }
                when CSV, ZIP_CSV {
                    List<String> lstSummaryErrors = new List<String>();
                    lstSummaryErrors.add(mapSummaryErrors.get(BulkAPIJobBatchService.HEADER));
                    for (String errorCode : mapSummaryErrorsCounter.keySet()) {
                        if (mapSummaryErrors.containsKey(errorCode)) lstSummaryErrors.add(String.format(CSV_ROW_SUMMARY_FORMAT, new List<String>{errorCode, mapSummaryErrors.get(errorCode), String.valueOf(mapSummaryErrorsCounter.get(errorCode))}));
                    }
                    contentVersionSummaryBlob = Blob.valueOf(String.join(lstSummaryErrors, BulkAPIJobBatchService.DEFAULT_LINE_ENDING));
                }
            }
        }
        BulkAPIJobBatchService.createContentVersion(job, contentVersionSummaryBlob, true, loggerInstance);
        this.contentVersionSummaryBlob = null;
        this.mapSummaryErrorsCounter = new Map<String, Integer>();
        this.mapSummaryErrors = new Map<String, String>();
        setSummaryErrors = new Set<String>();
        if (isPrevious) {
            this.previousMapSummaryErrorsCounter = new Map<String, Integer>();
            this.previousMapSummaryErrors = new Map<String, String>();
            previousContentVersionSummaryBlob = null;
            previousJob = null;
        }
    }

    private void createLog() {
        lstLogs.add(BulkAPIJobBatchService.createLog(corg, job, setErrorCodes, setRelatedIds, loggerInstance));
        setRelatedIds = new Set<String>();
        setErrorCodes = new Set<String>();
    }

    private void getJobFailedRecordResults() {
        String responseBody = HttpUtils.get(
                corg.Instance_Url__c + String.format(urlJobFailedResults, new List<String>{job.id, job.apiVersion}),
                ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg)),
                200
        );
        Integer counter = 0;
        List<String> lstSummaryErrors = new List<String>();
        Map<String, String> mapSummaryErrorRows = new Map<String, String>();
        String rowDelimiter = String.isNotBlank(job.lineEnding) && BulkAPIJobBatchService.MAP_LINE_ENDINGS.containsKey(job.lineEnding) ? BulkAPIJobBatchService.MAP_LINE_ENDINGS.get(job.lineEnding) : '\n';
        String columnDelimiter = String.isNotBlank(job.columnDelimiter) && BulkAPIJobBatchService.MAP_DELIMITERS.containsKey(job.columnDelimiter) ? BulkAPIJobBatchService.MAP_DELIMITERS.get(job.columnDelimiter) : ',';
        String regex = columnDelimiter + REGEX_SPLITTER;
        Pattern pattern = Pattern.compile(regex);
        BulkAPIJobBatchService.RowIterator rowIterator = new BulkAPIJobBatchService.RowIterator(responseBody,rowDelimiter);
        while (rowIterator.hasNext()) {
            String row = rowIterator.next();
            if (counter == 0 && lstSummaryErrors.isEmpty()) {
                lstSummaryErrors.add(row + ',' + BulkAPIJobBatchService.TOTAL_RECORDS);
            } else if (counter != 0) {
                List<String> lstRowParts = BulkAPIJobBatchService.rowSplitter(row, pattern);
                if (lstRowParts.size() > 1 && String.isNotBlank(lstRowParts[1])) {
                    if (String.isNotBlank(lstRowParts[0]) && setRelatedIds.size() < RELATED_ENTRIES_LIMIT) setRelatedIds.add(lstRowParts[0]);
                    String errorCode = lstRowParts[1].split(':')[0];
                    setErrorCodes.add(errorCode);
                    mapSummaryErrorsCounter.put(errorCode, mapSummaryErrorsCounter.containsKey(errorCode) ? mapSummaryErrorsCounter.get(errorCode) + 1 : 1);
                    if (!mapSummaryErrorRows.containsKey(errorCode)) mapSummaryErrorRows.put(errorCode, row);
                }
            }
            counter++;
        }
        for (String errorCode : mapSummaryErrorRows.keySet()) {
            lstSummaryErrors.add(mapSummaryErrorRows.get(errorCode) + ',"' + mapSummaryErrorsCounter.get(errorCode) + '"');
        }
        rowIterator = null;
        contentVersionBlob = Blob.valueOf(responseBody);
        contentVersionSummaryBlob = Blob.valueOf(String.join(lstSummaryErrors, '\n'));
    }

    private String getBatchResult() {
        return HttpUtils.get(
                corg.Instance_Url__c + String.format(urlBatchResult, new List<String>{job.id, job.apiVersion, batchId}),
                new Map<String, String>{'X-SFDC-Session' => ConnectedOrgService.getSelfConnectedOrgAccessToken()},
                200
        );
    }

    private String getBatchRequest() {
        return HttpUtils.get(
                corg.Instance_Url__c + String.format(urlBatchRequest, new List<String>{job.id, job.apiVersion, batchId}),
                new Map<String, String>{'X-SFDC-Session' => ConnectedOrgService.getSelfConnectedOrgAccessToken()},
                200
        );
    }

    private void parseResultXml() {
        Dom.Document resultDocument = new Dom.Document();
        resultDocument.load(getBatchResult());
        String xmlns = resultDocument.getRootElement().getNamespace();
        Integer counter = 0;
        for (Dom.XmlNode sObjectElement : resultDocument.getRootElement().getChildElements()) {
            if (sObjectElement.getChildElement('errors', xmlns) != null) {
                Dom.XmlNode idElement = sObjectElement.getChildElement('id', xmlns);
                if (idElement != null) {
                    if (String.isNotBlank(idElement.getText()) && setRelatedIds.size() < RELATED_ENTRIES_LIMIT) setRelatedIds.add(idElement.getText());
                }
                Dom.Document errorDocument = new Dom.Document();
                errorDocument.createRootElement('errors', xmlns, null);
                for (Dom.XmlNode errorElement : sObjectElement.getChildElement('errors', xmlns).getChildElements()) {
                    errorDocument.getRootElement().addChildElement(errorElement.getName(), errorElement.getNamespace(), null).addTextNode(errorElement.getText());
                }
                mapErrors.put(counter, errorDocument.toXmlString());
                String errorCode = errorDocument.getRootElement().getChildElement('statusCode', xmlns) != null ? errorDocument.getRootElement().getChildElement('statusCode', xmlns).getText() : '';
                if (String.isNotBlank(errorCode)) {
                    setErrorCodes.add(errorCode);
                    mapSummaryErrorsCounter.put(errorCode, mapSummaryErrorsCounter.containsKey(errorCode) ? mapSummaryErrorsCounter.get(errorCode) + 1 : 1);
                }
            }
            counter++;
        }
    }

    private void parseRequestXml() {
        Dom.Document requestDocument = new Dom.Document();
        requestDocument.load(getBatchRequest());
        Integer counter = 0;
        XmlStreamWriter xmlStreamWriter;
        Dom.Document summaryDocument = new Dom.Document();
        if (contentVersionSummaryBlob != null) {
            summaryDocument.load(contentVersionSummaryBlob.toString());
        } else {
            Dom.XmlNode newRootElement = summaryDocument.createRootElement('sObjects', null, null);
            newRootElement.setNamespace('', requestDocument.getRootElement().getNamespace());
        }
        for (Dom.XmlNode sObjectElement : requestDocument.getRootElement().getChildElements()) {
            if (mapErrors.containsKey(counter)) {
                if (xmlStreamWriter == null) {
                    xmlStreamWriter = new XmlStreamWriter();
                    xmlStreamWriter.writeStartDocument('UTF-8', '1.0');
                    xmlStreamWriter.writeStartElement(null, 'sObjects', null);
                }
                Dom.Document errorDocument = new Dom.Document();
                errorDocument.load(mapErrors.get(counter));
                String xmlns = errorDocument.getRootElement().getNamespace();
                String errorCode = errorDocument.getRootElement().getChildElement('statusCode', xmlns) != null ? errorDocument.getRootElement().getChildElement('statusCode', xmlns).getText() : '';
                xmlStreamWriter.writeStartElement(null, 'sObject', null);
                Dom.XmlNode summarySObjectElement;
                if (mapSummaryErrorsCounter.containsKey(errorCode) && setSummaryErrors.add(errorCode)) {
                    summarySObjectElement = summaryDocument.getRootElement().addChildElement('sObject', null, null);
                }
                for (Dom.XmlNode sObjectFieldElement : sObjectElement.getChildElements()) {
                    xmlStreamWriter.writeStartElement(null, sObjectFieldElement.getName(), null);
                    xmlStreamWriter.writeCharacters(sObjectFieldElement.getText());
                    xmlStreamWriter.writeEndElement();

                    summarySObjectElement?.addChildElement(sObjectFieldElement.getName(), null, null).addTextNode(sObjectFieldElement.getText());
                }
                xmlStreamWriter.writeStartElement(null, 'errors', null);
                Dom.XmlNode summaryErrorsElement = summarySObjectElement?.addChildElement('errors', null, null);
                for (Dom.XmlNode errorElement : errorDocument.getRootElement().getChildElements()) {
                    xmlStreamWriter.writeStartElement(null, errorElement.getName(), null);
                    xmlStreamWriter.writeCharacters(errorElement.getText());
                    xmlStreamWriter.writeEndElement();
                    summaryErrorsElement?.addChildElement(errorElement.getName(), null, null).addTextNode(errorElement.getText());
                }
                xmlStreamWriter.writeEndElement();
                xmlStreamWriter.writeEndElement();
                if (xmlStreamWriter.getXmlString().length() >= XML_STRING_LENGTH) {
                    xmlStreamWriter.writeEndElement();
                    xmlStreamWriter.writeEndDocument();
                    BulkAPIJobBatchService.createContentVersion(job, Blob.valueOf(xmlStreamWriter.getXmlString()), false, loggerInstance);
                    xmlStreamWriter.close();
                    xmlStreamWriter = null;
                }
            }
            counter++;
        }
        if (xmlStreamWriter != null) {
            xmlStreamWriter.writeEndElement();
            xmlStreamWriter.writeEndDocument();
            BulkAPIJobBatchService.createContentVersion(job, Blob.valueOf(xmlStreamWriter.getXmlString()), false, loggerInstance);
            xmlStreamWriter.close();
            xmlStreamWriter = null;
        }
        contentVersionSummaryBlob = Blob.valueOf(summaryDocument.toXmlString());
    }

    private void parseResultJSON() {
        Integer counter = 0;
        for (Object obj : (List<Object>)JSON.deserializeUntyped(getBatchResult())) {
            if (((Map<String, Object>)obj).containsKey('errors') && !((List<Object>)((Map<String, Object>)obj).get('errors')).isEmpty()) {
                String relatedId = String.valueOf(((Map<String, Object>)obj).get('id'));
                if (String.isNotBlank(relatedId) && setRelatedIds.size() < RELATED_ENTRIES_LIMIT) setRelatedIds.add(relatedId);
                mapErrors.put(counter, JSON.serialize(((Map<String, Object>)obj).get('errors')));
                Map<String, Object> mapErrorJSON = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)((Map<String, Object>)obj).get('errors'))[0]));
                String errorCode = (String)mapErrorJSON.get('statusCode');
                setErrorCodes.add(errorCode);
                mapSummaryErrorsCounter.put(errorCode, mapSummaryErrorsCounter.containsKey(errorCode) ? mapSummaryErrorsCounter.get(errorCode) + 1 : 1);
            }
            counter++;
        }
    }

    private void parseRequestJSON() {
        List<Object> lstErrors = new List<Object>();
        if (contentVersionBlob != null) lstErrors = (List<Object>)JSON.deserializeUntyped(contentVersionBlob.toString());
        Integer counter = 0;
        for (Object obj : (List<Object>)JSON.deserializeUntyped(getBatchRequest())) {
            if (mapErrors.containsKey(counter)) {
                ((Map<String, Object>)obj).put('errors', (List<Object>)JSON.deserializeUntyped(mapErrors.get(counter)));
                lstErrors.add(obj);
                Map<String, Object> mapErrorJSON = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(mapErrors.get(counter)))[0]));
                String errorCode = (String)mapErrorJSON.get('statusCode');
                if (mapSummaryErrorsCounter.containsKey(errorCode) && !mapSummaryErrors.containsKey(errorCode)) {
                    mapSummaryErrors.put(errorCode, JSON.serialize(obj));
                }
            }
            counter++;
        }
        contentVersionBlob = Blob.valueOf(JSON.serialize(lstErrors));
    }

    private void parseResultCSV() {
        Integer counter = 0;
        String rowDelimiter = String.isNotBlank(job.lineEnding) && BulkAPIJobBatchService.MAP_LINE_ENDINGS.containsKey(job.lineEnding) ? BulkAPIJobBatchService.MAP_LINE_ENDINGS.get(job.lineEnding) : BulkAPIJobBatchService.DEFAULT_LINE_ENDING;
        String columnDelimiter = String.isNotBlank(job.columnDelimiter) && BulkAPIJobBatchService.MAP_DELIMITERS.containsKey(job.columnDelimiter) ? BulkAPIJobBatchService.MAP_DELIMITERS.get(job.columnDelimiter) : BulkAPIJobBatchService.DEFAULT_COLUMN_DELIMITER;
        String regex = columnDelimiter + REGEX_SPLITTER;
        Pattern pattern = Pattern.compile(regex);
        BulkAPIJobBatchService.RowIterator rowIterator = new BulkAPIJobBatchService.RowIterator(getBatchResult(),rowDelimiter);
        while (rowIterator.hasNext()) {
            String row = rowIterator.next();
            if (counter != 0) {
                List<String> lstRowParts = BulkAPIJobBatchService.rowSplitter(row, pattern);
                if (lstRowParts.size() > 3 && String.isNotBlank(lstRowParts[3])) {
                    mapErrors.put(counter, lstRowParts[3]);
                    if (String.isNotBlank(lstRowParts[0]) && setRelatedIds.size() < RELATED_ENTRIES_LIMIT) setRelatedIds.add(lstRowParts[0]);
                    String errorCode = lstRowParts[3].split(':')[0];
                    setErrorCodes.add(errorCode);
                    mapSummaryErrorsCounter.put(errorCode, mapSummaryErrorsCounter.containsKey(errorCode) ? mapSummaryErrorsCounter.get(errorCode) + 1 : 1);
                }
            }
            counter++;
        }
    }

    private void parseRequestCSV() {
        List<String> lstErrors = new List<String>();
        if (contentVersionBlob != null) {
            BulkAPIJobBatchService.RowIterator rowIterator = new BulkAPIJobBatchService.RowIterator(contentVersionBlob.toString(), BulkAPIJobBatchService.DEFAULT_LINE_ENDING);
            while (rowIterator.hasNext()) {
                lstErrors.add(rowIterator.next());
            }
        }
        Integer counter = 0;
        String rowDelimiter = String.isNotBlank(job.lineEnding) && BulkAPIJobBatchService.MAP_LINE_ENDINGS.containsKey(job.lineEnding) ? BulkAPIJobBatchService.MAP_LINE_ENDINGS.get(job.lineEnding) : BulkAPIJobBatchService.DEFAULT_LINE_ENDING;
        BulkAPIJobBatchService.RowIterator rowIterator = new BulkAPIJobBatchService.RowIterator(getBatchRequest(),rowDelimiter);
        while (rowIterator.hasNext()) {
            String line = rowIterator.next();
            if (counter == 0 && lstErrors.isEmpty()) {
                lstErrors.add('sf__Error,' + line);
                if (!mapSummaryErrors.containsKey(BulkAPIJobBatchService.HEADER)) mapSummaryErrors.put(BulkAPIJobBatchService.HEADER, 'sf__Error,' + line + ',' + BulkAPIJobBatchService.TOTAL_RECORDS);
            } else if (mapErrors.containsKey(counter)) {
                lstErrors.add('"' + mapErrors.get(counter) + '",' + line);
                String errorCode = mapErrors.get(counter).split(':')[0];
                if (mapSummaryErrorsCounter.containsKey(errorCode) && !mapSummaryErrors.containsKey(errorCode)) {
                    mapSummaryErrors.put(errorCode, line);
                }
            }
            counter++;
        }
        contentVersionBlob = Blob.valueOf(String.join(lstErrors, BulkAPIJobBatchService.DEFAULT_LINE_ENDING));
    }

}