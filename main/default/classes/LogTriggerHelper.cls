public with sharing class LogTriggerHelper {

    public static void populateDefaults(List<Log__c> newLogs) {
        for (Log__c log : newLogs) {
            if(String.isNotBlank(log.Hash_1__c) && log.Hash_1__c.length() > ConfigUtil.LOG_INDEX_MAX_SIZE_KEY_HASH) {
                log.Hash_1__c = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(log.Hash_1__c)));
            }
            LogPostProcessingService.PostProcessingSettings logSettings = new LogPostProcessingService.PostProcessingSettings(log.Post_Processing_Settings__c);
            if (!isBroadcastLog(log, null) && (!isInternalErrorLog(log, null) || String.isNotBlank(log.Post_Processing_Settings__c))) {
                if (String.isBlank(log.Post_Processing_Status__c)) log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED;
                if (String.isBlank(log.Deploy_Results__c) && logSettings.isEnabled(LogPostProcessingService.DEPLOY_RESULT_KEY)) {
                    log.Deploy_Results__c = LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE;
                    log.Deploy_results_available__c = true;
                }
                if (String.isBlank(log.Setup_Audit_Trail__c) && logSettings.isEnabled(LogPostProcessingService.AUDIT_TRAIL_KEY)) {
                    log.Setup_Audit_Trail__c = LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE;
                    log.Audit_Trail_available__c = true;
                }
                if (String.isBlank(log.Pending_Jobs__c) && logSettings.isEnabled(LogPostProcessingService.PENDING_JOBS_KEY)) {
                    log.Pending_Jobs__c = LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE;
                }
                if (String.isBlank(log.Installed_Packages__c) && logSettings.isEnabled(LogPostProcessingService.INSTALLED_PACKAGES_KEY)) {
                    log.Installed_Packages__c = LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE;
                }
                if (String.isBlank(log.Stacktrace_Parse_Result__c) && logSettings.isEnabled(LogPostProcessingService.STACK_TRACE_KEY)) {
                    log.Stacktrace_Parse_Result__c = LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE;
                    log.Stack_trace_parse_result_available__c = true;
                }
            }
            if (String.isBlank(log.Exception_Codes__c) && String.isNotBlank(log.Summary__c)) {
                log.Exception_Codes__c = String.join(LogService.getExceptionCodesInString(log.Summary__c), ';');
            }
        }
    }

    public static void populateRelatedObjects(List<Log__c> newLogs) {
        for (Log__c log : newLogs) {
            if (!isBroadcastLog(log, null)) {
                Set<String> relatedIds = new Set<String>();
                if (String.isNotBlank(log.Related_Objects__c)) {
                    try {
                        relatedIds.addAll((Set<String>) JSON.deserialize(log.Related_Objects__c, Set<String>.class));
                    } catch (JSONException e) {
                        // catch JSON deserialize issue
                    }
                }
                Pattern p = ConfigUtil.SOBJECT_ID_PATTERN;
                Matcher pm = p.matcher(log.Related_Id__c + ' ' + log.Summary__c + ' ' + log.Details__c);
                while (pm.find()) {
                    try {
                        relatedIds.add(isInternalErrorLog(log, null) ? Id.valueOf(pm.group(1)) : pm.group(1));
                    } catch (Exception e) {
                        // catch Invalid id
                    }
                }
                log.Related_Objects__c = !relatedIds.isEmpty() ? JSON.serialize(relatedIds) : null;
            }
        }
    }

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

    public static void assignParent(List<Log__c> newLogs) {
        try {
            List<Log__c> existLogs = getExistLogsWithSubsequence(newLogs);
            existLogs = getExistLogsWithSubsequence(existLogs);
            Map<String, String> parentLogIdByRequestId = new Map<String, String>();
            Map<String, String> parentLogIdByTransactionId = new Map<String, String>();
            Map<String, String> parentLogIdByInterviewGUID = new Map<String, String>();
            for (Log__c log : existLogs) {
                log.Parent__c = null;
                log.Is_Parent__c = false;
                if (String.isNotBlank(log.Transaction_Id_External__c) && parentLogIdByTransactionId.containsKey(log.Transaction_Id_External__c)) {
                    log.Parent__c = parentLogIdByTransactionId.get(log.Transaction_Id_External__c);
                    if (String.isNotBlank(log.Interview_GUID_External__c)) parentLogIdByInterviewGUID.put(log.Interview_GUID_External__c, log.Parent__c);
                    if (String.isNotBlank(log.Request_Id_External__c)) parentLogIdByRequestId.put(log.Request_Id_External__c, log.Parent__c);
                } else if (String.isNotBlank(log.Interview_GUID_External__c) && parentLogIdByInterviewGUID.containsKey(log.Interview_GUID_External__c)) {
                    log.Parent__c = parentLogIdByInterviewGUID.get(log.Interview_GUID_External__c);
                    if (String.isNotBlank(log.Transaction_Id_External__c)) parentLogIdByTransactionId.put(log.Transaction_Id_External__c, log.Parent__c);
                    if (String.isNotBlank(log.Request_Id_External__c)) parentLogIdByRequestId.put(log.Request_Id_External__c, log.Parent__c);
                } else if (String.isNotBlank(log.Request_Id_External__c) && parentLogIdByRequestId.containsKey(log.Request_Id_External__c)) {
                    log.Parent__c = parentLogIdByRequestId.get(log.Request_Id_External__c);
                    if (String.isNotBlank(log.Transaction_Id_External__c)) parentLogIdByTransactionId.put(log.Transaction_Id_External__c, log.Parent__c);
                    if (String.isNotBlank(log.Interview_GUID_External__c)) parentLogIdByInterviewGUID.put(log.Interview_GUID_External__c, log.Parent__c);
                } else if (String.isNotBlank(log.Transaction_Id_External__c)) {
                    log.Is_Parent__c = true;
                    if (String.isNotBlank(log.Transaction_Id_External__c)) parentLogIdByTransactionId.put(log.Transaction_Id_External__c, log.Id);
                    if (String.isNotBlank(log.Interview_GUID_External__c)) parentLogIdByInterviewGUID.put(log.Interview_GUID_External__c, log.Id);
                    if (String.isNotBlank(log.Request_Id_External__c)) parentLogIdByRequestId.put(log.Request_Id_External__c, log.Id);
                }
            }
            DatabaseUtils.getInstance().performUpdateDML(existLogs, Schema.SObjectType.Log__c)
                    .handleError(LogTriggerHelper.class.getName(), '.assignParent');
        } catch (Exception e) {
            Logger.getInstance().internalError(e, LogTriggerHelper.class.getName(), 'assignParent');
        }
    }

    private static List<Log__c> getExistLogsWithSubsequence(List<Log__c> logs) {
        Set<String> parentIds = new Set<String>();
        Set<String> requestIds = new Set<String>();
        Set<String> transactionIds = new Set<String>();
        Set<String> interviewGUIDs = new Set<String>();
        for (Log__c log : logs) {
            if (String.isNotBlank(log.Parent__c)) parentIds.add(log.Parent__c);
            if (String.isNotBlank(log.Request_Id_External__c)) requestIds.add(log.Request_Id_External__c);
            if (String.isNotBlank(log.Transaction_Id_External__c)) transactionIds.add(log.Transaction_Id_External__c);
            if (String.isNotBlank(log.Interview_GUID_External__c)) interviewGUIDs.add(log.Interview_GUID_External__c);
        }
        if (parentIds.isEmpty() && requestIds.isEmpty() && transactionIds.isEmpty() && interviewGUIDs.isEmpty()) {
            return new List<Log__c>();
        }
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>{'Id', 'Request_Id_External__c', 'Transaction_Id_External__c', 'Interview_GUID_External__c', 'Parent__c', 'Is_Parent__c', 'Created_Timestamp__c'})
                .add(!parentIds.isEmpty() ? QBuilder.condition('Id').isIn(new List<String>(parentIds)) : null)
                .add(!parentIds.isEmpty() ? QBuilder.condition('Parent__c').isIn(new List<String>(parentIds)) : null)
                .add(!requestIds.isEmpty() ? QBuilder.condition('Request_Id_External__c').isIn(new List<String>(requestIds)) : null)
                .add(!transactionIds.isEmpty() ? QBuilder.condition('Transaction_Id_External__c').isIn(new List<String>(transactionIds)) : null)
                .add(!interviewGUIDs.isEmpty() ? QBuilder.condition('Interview_GUID_External__c').isIn(new List<String>(interviewGUIDs)) : null)
                .add(QBuilder.orderBy('Created_Timestamp__c'))
                .setDefaultLogicalOperator('OR')
                .build();
        return Database.query(query);
    }

    public static void updateLastCreatedLogFlag(List<Log__c> newLogs) {
        Datetime maxCratedDateTime = newLogs.get(0).CreatedDate;
        for(Log__c log : newLogs) {
            if(log.CreatedDate > maxCratedDateTime) {
                maxCratedDateTime = log.CreatedDate;
            }
        }
        updateLastCreatedLogFlag(maxCratedDateTime);
    }

    public static void updateLastCreatedLogFlag(Datetime lastCreatedLogDateTime) {
        Monitoring_Batch_Flag__c flag = Monitoring_Batch_Flag__c.getOrgDefaults();
        if (Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Created_Log__c.isCreateable()
            && Schema.SObjectType.Monitoring_Batch_Flag__c.fields.Last_Created_Log__c.isUpdateable()) {
            flag.Last_Created_Log__c = lastCreatedLogDateTime;
        }
        if (Schema.SObjectType.Monitoring_Batch_Flag__c.isAccessible()
            && Schema.SObjectType.Monitoring_Batch_Flag__c.isCreateable()
            && Schema.SObjectType.Monitoring_Batch_Flag__c.isUpdateable()) {
            DatabaseUtils.getInstance().performUpsertDML(new List<Monitoring_Batch_Flag__c>{flag}, Schema.SObjectType.Monitoring_Batch_Flag__c, false)
                .filterUpsertResultsRowLock()
                .handleError(LogTriggerHelper.class.getName(), '.updateLastCreatedLogFlag');
        }
    }

    public static void createContentDocumentLinks(List<Log__c> lstLogs) {
        Set<String> setAsyncJobIds = new Set<String>();
        for (Log__c log : lstLogs) {
            if (String.isNotBlank(log.Async_Job_Id__c)) {
                setAsyncJobIds.add(log.Async_Job_Id__c);
            }
        }
        if (!setAsyncJobIds.isEmpty()) {
            BulkAPIJobBatchService.createContentDocumentLinks(setAsyncJobIds);
        }
    }

    public static void updateBroadcastStatus(List<Log__c> lstLogs, Map<Id, Log__c> oldLogsMap) {
        for (Log__c log : lstLogs) {
            // Check Organization_Id to prevent broadcast logs created by email service per external Apex Exception Email. (LOG-1477)
            if (String.isBlank(log.Originated_From__c)
                    && String.isNotBlank(log.Organization_Id__c) && (log.Organization_Id__c.left(15) == UserInfo.getOrganizationId().left(15))
                    && log.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED
                    && oldLogsMap != null
                    && oldLogsMap.containsKey(log.Id)
                    && log.Post_Processing_Status__c != oldLogsMap.get(log.Id).Post_Processing_Status__c
                    && String.isBlank(log.Broadcast_Status__c)
                    && !ConnectedOrgService.getBroadcastConnectedOrgs(ConnectedOrgService.BROADCAST_SEND_TO).isEmpty())
            {
                log.Broadcast_Status__c = BroadcastService.BROADCAST_STATUS_NEEDED;
            }
        }
    }

    public static void runBroadcast(List<Log__c> newLogs, Map<Id, Log__c> oldLogsMap) {
        Boolean exist = false;
        for (Log__c log : newLogs) {
            if (log.Broadcast_Status__c == BroadcastService.BROADCAST_STATUS_NEEDED 
                && log.Post_Processing_Status__c != oldLogsMap.get(log.Id).Post_Processing_Status__c) {
                exist = true;
                break;
            }
        }
        if (exist) {
            BroadcastBatch.getInstance().startBatch();
        }
    }

    public static void checkPostProcessingSettings(List<Log__c> newLogs) {
        for (Log__c log : newLogs) {
            if (log.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED) {
                Set<String> settings = LogPostProcessingService.getSettings(log.Post_Processing_Settings__c);
                if (settings != null && settings.isEmpty()) {
                    log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED;
                }
            }
        }
    }

    @testVisible
    private static Boolean runPostProcessingBatchInTest = !Test.isRunningTest();

    public static void runPostProcessing(List<Log__c> newLogs) {
        Boolean exist = false;
        for (Log__c log : newLogs) {
            if (log.Post_Processing_Status__c == LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED) {
                exist = true;
                break;
            }
        }
        
        if (exist && runPostProcessingBatchInTest) {
            LogPostProcessingBatch.getInstance().startBatch();
        }
    }

    public static void onBeforeDelete(Map<Id, Log__c> oldLogsMap) {
        deleteContentDocument(oldLogsMap.keySet());
        deleteInboundEmail(oldLogsMap);
    }

    public static void onAfterDelete(Map<Id, Log__c> oldLogsMap) {
        deleteIssue(oldLogsMap);
        deleteLogIndexes(oldLogsMap);
    }

    private static void deleteLogIndexes(Map<Id, Log__c> oldLogsMap) {
        Set<String> logIndexKeys = new Set<String>();
        DateTime minLastModifiedDate = null;

        for(Log__c log : oldLogsMap.values()) {
            if(String.isNotBlank(log?.Hash_1__c)) {
                logIndexKeys.add(ConfigUtil.getLogIndexKey(log?.Hash_1__c, log?.Organization_Id__c));
            }
            if ((minLastModifiedDate == null || log.LastModifiedDate < minLastModifiedDate)) {
                minLastModifiedDate = log.LastModifiedDate;
            }
        }
        if(!logIndexKeys.isEmpty() && minLastModifiedDate != null) {
            LogIndexBatch.putLastDeleteLogBatchTimeStamp(minLastModifiedDate);
            LogIndexBatch.getInstance(LogIndexBatch.JobType.DELETE_ABANDONED_INDEXES_BATCH).startBatch();
        }
    }

    public static void deleteContentDocument(Set<Id> recordIds) {
        Set<String> setContentDocumentIds = new Set<String>();
        for (ContentDocumentLink contentDocumentLink : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds]) {
            setContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
        }
        List<ContentDocument> lstContentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN :setContentDocumentIds];
        DatabaseUtils.getInstance().performDeleteDML(lstContentDocuments, Schema.SObjectType.ContentDocument)
                .handleError(LogTriggerHelper.class.getName(), '.deleteContentDocument');
    }

    private static void deleteInboundEmail(Map<Id, Log__c> oldLogsMap) {
        List<Inbound_Email__c> inboundEmails = [SELECT Id FROM Inbound_Email__c WHERE Log__c IN : oldLogsMap.keySet()];
        DatabaseUtils.getInstance().performDeleteDML(inboundEmails, Schema.SObjectType.Inbound_Email__c)
                .handleError(LogTriggerHelper.class.getName(), '.deleteInboundEmail');
    }

    private static void deleteIssue(Map<Id, Log__c> oldLogsMap) {
        Set<Id> issueIds = new Set<Id>();
        for (Log__c log : oldLogsMap.values()) {
            if (String.isNotBlank(log.Issue__c)) {
                issueIds.add(log.Issue__c);
            }
        }
        List<Issue__c> issuesToDelete = new List<Issue__c>();
        List<Issue__c> issuesToUpdate = new List<Issue__c>();
        Map<String, Integer> logCountByIssueId = new Map<String, Integer>();
        List<AggregateResult> aggregateResults = [SELECT COUNT(Id) count_id, Issue__c issue_id FROM Log__c WHERE Issue__c IN : issueIds GROUP BY Issue__c];
        for (AggregateResult aggregateResult : aggregateResults) {
            logCountByIssueId.put((String)aggregateResult.get('issue_id'), (Integer)aggregateResult.get('count_id'));
        }
        for (Issue__c issue : [SELECT Id, Log__c, (SELECT Id FROM Logs__r ORDER BY Created_At__c LIMIT 1) FROM Issue__c WHERE Id IN :issueIds]) {
            if (issue.Logs__r.isEmpty()) {
                issuesToDelete.add(issue);
            } else {
                issue.Log__c = issue.Logs__r[0].Id;
                issue.Log_Count__c = logCountByIssueId.get(issue.Id);
                issuesToUpdate.add(issue);
            }
        }
        DatabaseUtils.getInstance().performDeleteDML(issuesToDelete, Schema.SObjectType.Issue__c)
                .handleError(LogTriggerHelper.class.getName(), '.deleteIssue');
        DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
                .handleError(LogTriggerHelper.class.getName(), '.deleteIssue');
    }

}