global with sharing class ErrorEmailHandler implements Messaging.InboundEmailHandler {

    public static Integer MAX_LENGTH_LONG_TEXT_AREA_FIELD = 131000;
    private static Logger loggerInstance = Logger.getInstance();

    public static Map<String, String> mapStacktrace = new Map<String, String>();
    public static Map<String, String> mapStacktraceParseResult = new Map<String, String>();

    @TestVisible
    private static final DateTime testCreatedAtDateTime = Datetime.now();

    // GLOBAL
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope env) {
        String s = email.subject;
        //TODO LOG-1736
        //Datetime createdAtDateTime = ConfigUtil.getDateTimeFromEmailHeader(email);
        Datetime createdAtDateTime = (Test.isRunningTest()) ? testCreatedAtDateTime : System.now();
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Inbound_Email__c inboundEmail = (Inbound_Email__c)PermissionsUtil.newSObject(Schema.SObjectType.Inbound_Email__c);
        
        // handle extra size of plain text body, over max size Long Text Area field
        String plainTextBody = email.plainTextBody;
        if(plainTextBody != null && plainTextBody.length() > MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
            plainTextBody = plainTextBody.abbreviate(MAX_LENGTH_LONG_TEXT_AREA_FIELD);
        }
        PermissionsUtil.putSObjectField(inboundEmail, Schema.sObjectType.Inbound_Email__c.fields.Plain_Text__c, maskContent(plainTextBody));
        
        FlowDataStructures.FlowErrorAbbreviateResult abbreviateResult = new FlowDataStructures.FlowErrorAbbreviateResult();
        abbreviateResult.abbreviatedStacktrace = email?.htmlBody;
        
        // handle extra size of flow errors, over max size Rich Text Area field
        if(email?.htmlBody != null 
            && email?.htmlBody?.startsWithIgnoreCase('<') 
            && (email?.htmlBody?.length() > MAX_LENGTH_LONG_TEXT_AREA_FIELD 
                || !email?.htmlBody?.contains(Constants.FLOW.PB_ST_FLOW_ERROR_DETAILS)
                || email?.htmlBody?.contains(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR)
            )) {
            FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(email.htmlBody);
            abbreviateResult = sp.abbreviateStacktraceErrorMessages();
        }
       
        PermissionsUtil.putSObjectField(inboundEmail, Schema.sObjectType.Inbound_Email__c.fields.Html_Body__c, maskContent(abbreviateResult.abbreviatedStacktrace));
        
        PermissionsUtil.putSObjectField(inboundEmail, Schema.sObjectType.Inbound_Email__c.fields.Subject__c, s.abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH));
        PermissionsUtil.putSObjectField(inboundEmail, Schema.sObjectType.Inbound_Email__c.fields.From__c, email.fromAddress + (String.isNotBlank(email.fromName) ? ' (' + email.fromName + ')' : ''));

        if (ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c) {
            PassthroughtModeService.sendInboundEmail(inboundEmail);
        }
        else {
            processEmail(new List<Inbound_Email__c>{inboundEmail}, null, createdAtDateTime, email, abbreviateResult);
        }

        result.success = true;
        return result;
    }

    public static String getEmailBody(Inbound_Email__c inboundEmail) {
        String body;
        if (String.isNotBlank(inboundEmail.Html_Body__c)
            && inboundEmail.Html_Body__c.startsWithIgnoreCase('<')
            && !inboundEmail.Html_Body__c.startsWithIgnoreCase('<html')) {
            body = inboundEmail.Html_Body__c;
        }
        else if (String.isNotBlank(inboundEmail.Plain_Text__c)
            && (String.isBlank(inboundEmail.Html_Body__c)
                || (String.isNotBlank(inboundEmail.Html_Body__c) 
                && (!inboundEmail.Html_Body__c.startsWithIgnoreCase('<') || inboundEmail.Html_Body__c.startsWithIgnoreCase('<html'))))) {
            body = inboundEmail.Plain_Text__c;
        }
        return body;
    }

    public static void processEmail(List<Inbound_Email__c> inboundEmails) {
        processEmail(inboundEmails, null, null, null, null, false);
    }
    public static void processEmail(List<Inbound_Email__c> inboundEmails, String incomeOrganizationId) {
        processEmail(inboundEmails, incomeOrganizationId, null, null, null, false);
    }
    public static void processEmail(List<Inbound_Email__c> inboundEmails,
                                    String incomeOrganizationId,
                                    DateTime createdAtDateTime,
                                    Messaging.inboundEmail email,
                                    FlowDataStructures.FlowErrorAbbreviateResult abbreviateResult) {
        processEmail(inboundEmails, incomeOrganizationId, createdAtDateTime, email, abbreviateResult, false);
    }
    public static void processEmail(List<Inbound_Email__c> inboundEmails,
                                    String incomeOrganizationId,
                                    DateTime createdAtDateTime,
                                    Messaging.inboundEmail email,
                                    FlowDataStructures.FlowErrorAbbreviateResult abbreviateResult,
                                    Boolean isRoutedFromPassthroughMode) {
                                       
        Inbound_Email__c inboundEmail = inboundEmails.get(0);

        List<Log__c> logsToAsyncJob = new List<Log__c>();
        List<Log__c> logsToPostProcessing = new List<Log__c>();
        List<Log__c> createdLogs = new List<Log__c>();

        String body = getEmailBody(inboundEmail);
        String fullErrorMessage;

        try {
            if(isChangeEmail(inboundEmail.Subject__c)) {
                AdminService.handleChangeUserEmail(inboundEmail.Subject__c, inboundEmail.Plain_Text__c);
            }
            else {
                Datetime createdAt = createdAtDateTime != null ? createdAtDateTime : Datetime.now();
                Log__c log;
                
                // multiply errors in email
                if(abbreviateResult?.errorMessages != null && !abbreviateResult?.errorMessages?.isEmpty()) {
                    for(String errorMessage : abbreviateResult.errorMessages.values()) {
                        log = LogService.createLogFromEmailBody(body, Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR + errorMessage, inboundEmail.From__c, createdAt, incomeOrganizationId, loggerInstance);
                        
                        if (log != null) {
                            if (String.isNotBlank(log.Async_Job_Id__c)) {
                                logsToAsyncJob.add(log);
                            }
                            // process large stacktrace
                            // and all flow error to determinate fault path and skip create logs if this error is fault path
                            else if (!isRoutedFromPassthroughMode
                                && (log?.Stacktrace__c?.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD
                                    || log.Category__c == FlowExceptionParser.FLOW_CATEGORY)) {
                                
                                // enable post processing for stacktrace only
                                log.Post_Processing_Settings__c = LogPostProcessingService.POST_PROCESSING_SETTINGS_STACKTRACE_ONLY;
                                logsToPostProcessing.add(log);
                            }
                            else {
                                createdLogs.add(log);
                            }
                        }
                    }
                }
                // regular emails
                else {
                    log = LogService.createLogFromEmailBody(body, inboundEmail.Subject__c, inboundEmail.From__c, createdAt, incomeOrganizationId, loggerInstance);

                    if (log != null) {
                        if (String.isNotBlank(log.Async_Job_Id__c)) {
                            logsToAsyncJob.add(log);
                        }
                        // process large stacktrace
                        // and all flow error to determinate fault path and skip create logs if this error is fault path
                        else if (!isRoutedFromPassthroughMode 
                            && (log?.Stacktrace__c?.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD
                                || log.Category__c == FlowExceptionParser.FLOW_CATEGORY)) {

                            // enable post processing for stacktrace only
                            log.Post_Processing_Settings__c = LogPostProcessingService.POST_PROCESSING_SETTINGS_STACKTRACE_ONLY;
                            logsToPostProcessing.add(log);
                        }
                        else {
                            createdLogs.add(log);
                        }
                    }
                }
                if (!logsToAsyncJob.isEmpty()) {
                    JobBatch.asyncApexJobHandler(logsToAsyncJob);
                    // Set the lookup to the last async job log (matching behavior of createdLogs)
                    Log__c lastAsyncLog = logsToAsyncJob.get(logsToAsyncJob.size() - 1);
                    if (String.isNotBlank(lastAsyncLog?.Id)) {
                        PermissionsUtil.putSObjectField(inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Log__c, lastAsyncLog.Id);
                    }
                }
                // post processing for errors with large stacktrace
                if(!logsToPostProcessing.isEmpty()) {
                    List<LogPostProcessingService.LogPostProcessingResult> results = LogPostProcessingService.doLogPostProcessing(logsToPostProcessing, loggerInstance, false);
                    for(LogPostProcessingService.LogPostProcessingResult result : results) {

                        // if no errors, enable post processing for all settings except stacktrace
                        // if errors, process all settings
                        for(Log__c logResult : result.logs) {                            
                            logResult.Post_Processing_Settings__c = (result.errors.isEmpty() 
                                ? LogPostProcessingService.POST_PROCESSING_SETTINGS_ALL_SETTINGS_EXCEPT_STACKTRACE
                                : null);
                            // reset post processing status
                            logResult.Post_Processing_Status__c = null;
                            createdLogs.add(logResult);
                        }
                        
                        // if error is in handled fault path, skip create additional internal logs
                        for(Exception error : result.errors) {
                            if (error?.getMessage()?.containsIgnoreCase(LogService.FLOW_HANDLED_ERROR_MESSAGE)) {
                                throw new LogService.LogException(LogService.FLOW_HANDLED_ERROR_MESSAGE);
                            }
                        }
                    }
                }
                PermissionsUtil.putSObjectField(inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Error__c, null);

                if(!createdLogs.isEmpty()) {
                    for(Log__c logItem : createdLogs) {
                        if(logItem?.Stacktrace__c?.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
                            Integer index = mapStacktrace.size();
                            mapStacktrace.put(String.valueOf(index), logItem.Stacktrace__c);
                            PermissionsUtil.putSObjectField(logItem, Schema.sObjectType.Log__c.fields.Stacktrace__c, String.valueOf(index));
                        }
                        if(logItem?.Stacktrace_Parse_Result__c?.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
                            Integer index = mapStacktraceParseResult.size();
                            mapStacktraceParseResult.put(String.valueOf(index), logItem.Stacktrace_Parse_Result__c);
                            PermissionsUtil.putSObjectField(logItem, Schema.sObjectType.Log__c.fields.Stacktrace_Parse_Result__c, String.valueOf(index));
                        }
                    }
                    DatabaseUtils.getInstance().performInsertDML(createdLogs, Schema.SObjectType.Log__c)
                        .handleError(LogService.class.getName(), '.createLogFromEmailBody', loggerInstance);

                    for(Log__c logItem : createdLogs) {
                        if(String.isNotBlank(logItem?.Stacktrace__c) 
                            && logItem?.Stacktrace__c?.isNumeric()
                            && mapStacktrace.containsKey(logItem?.Stacktrace__c)) {
                            
                            mapStacktrace.put(logItem.Id, mapStacktrace.get(logItem.Stacktrace__c));
                            mapStacktrace.remove(logItem.Stacktrace__c);
                        }
                        if(String.isNotBlank(logItem?.Stacktrace_Parse_Result__c)
                            && logItem?.Stacktrace_Parse_Result__c?.isNumeric()
                            && mapStacktraceParseResult.containsKey(logItem?.Stacktrace_Parse_Result__c)) {
                            
                            mapStacktraceParseResult.put(logItem.Id, mapStacktraceParseResult.get(logItem.Stacktrace_Parse_Result__c));
                            mapStacktraceParseResult.remove(logItem.Stacktrace_Parse_Result__c);
                        }
                        
                        PermissionsUtil.putSObjectField(inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Log__c, logItem.Id);
                    }
                    
                    if(!mapStacktrace.isEmpty()) {
                        createStacktraceCV(mapStacktrace, loggerInstance);
                    }
                    if(!mapStacktraceParseResult.isEmpty()) {
                        createStacktraceParseResultCV(mapStacktraceParseResult, loggerInstance);
                    }
                }
            }
        }
        catch(Exception e) {
            fullErrorMessage = e.getMessage();
            PermissionsUtil.putSObjectField(inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Error__c, fullErrorMessage.abbreviate(131071));
            // if error is handled fault path, skip create additional internal logs
            if(fullErrorMessage.containsIgnoreCase(LogService.FLOW_HANDLED_ERROR_MESSAGE)) {
                fullErrorMessage = null;
            }
        }

        if(inboundEmail?.Html_Body__c != null && inboundEmail?.Html_Body__c?.length() > MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
            PermissionsUtil.putSObjectField(inboundEmail, Schema.sObjectType.Inbound_Email__c.fields.Html_Body__c, inboundEmail.Html_Body__c.abbreviate(MAX_LENGTH_LONG_TEXT_AREA_FIELD));
        }

        DatabaseUtils upsertUtilResult = DatabaseUtils.getInstance().performUpsertDML(new List<Inbound_Email__c>{inboundEmail}, Schema.SObjectType.Inbound_Email__c)
            .handleError(ErrorEmailHandler.class.getName(), '.processEmail', loggerInstance);
        createInboundEmailInternalLog(email, upsertUtilResult?.upsertResults, loggerInstance);
        createInternalLog(fullErrorMessage, inboundEmail, loggerInstance);
        loggerInstance?.flush();
    }

    public static void createStacktraceParseResultCV(Map<String, String> dataByLogId, Logger logger) {
		List<ContentVersion> cvList = new List<ContentVersion>();
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

		List<String> logIds = new List<String>();

		for(String logId : dataByLogId.keySet()) {
			ContentVersion cv = new ContentVersion();
			cv.PathOnClient = STACK_TRACE_PARSE_RESULT_CV_NAME;
			cv.VersionData = Blob.valueOf(dataByLogId.get(logId));
			cv.Description = STACK_TRACE_PARSE_RESULT_CV_NAME;
			cv.ContentLocation = 'S';
			cvList.add(cv);
			logIds.add(logId);
		}

		DatabaseUtils.getInstance().performInsertDML(cvList, Schema.SObjectType.ContentVersion)
			.handleError(LogPostProcessingService.class.getName(), '.createStacktraceParseResultCV', logger);

		List<ContentVersion> cvListWithDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList];
		for(Integer i = 0; i < cvListWithDocumentId.size(); i++) {
			Id contentDocumentId = cvListWithDocumentId.get(i)?.ContentDocumentId;
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = contentDocumentId;
			cdl.LinkedEntityId = logIds.get(i);
			cdl.ShareType = 'V';
			cdlList.add(cdl);
		}

		DatabaseUtils.getInstance().performInsertDML(cdlList, Schema.SObjectType.ContentDocumentLink)
			.handleError(LogPostProcessingService.class.getName(), '.createStacktraceParseResultCV', logger);
		
	}

    public static final String STACK_TRACE_CV_NAME = 'Stacktrace.html';
    public static final String STACK_TRACE_PARSE_RESULT_CV_NAME = 'StacktraceParseResult.json';

    public static void createStacktraceCV(Map<String, String> dataByLogId, Logger logger) {
		List<ContentVersion> cvList = new List<ContentVersion>();
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

		List<String> logIds = new List<String>();

		for(String logId : dataByLogId.keySet()) {
			ContentVersion cv = new ContentVersion();
			cv.PathOnClient = STACK_TRACE_CV_NAME;
			cv.VersionData = Blob.valueOf(dataByLogId.get(logId));
			cv.Description = STACK_TRACE_CV_NAME;
			cv.ContentLocation = 'S';
			cvList.add(cv);
			logIds.add(logId);
		}

		DatabaseUtils.getInstance().performInsertDML(cvList, Schema.SObjectType.ContentVersion)
			.handleError(LogPostProcessingService.class.getName(), '.createStacktraceCV', logger);

		List<ContentVersion> cvListWithDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList];
		for(Integer i = 0; i < cvListWithDocumentId.size(); i++) {
			Id contentDocumentId = cvListWithDocumentId.get(i)?.ContentDocumentId;
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = contentDocumentId;
			cdl.LinkedEntityId = logIds.get(i);
			cdl.ShareType = 'V';
			cdlList.add(cdl);
		}

		DatabaseUtils.getInstance().performInsertDML(cdlList, Schema.SObjectType.ContentDocumentLink)
			.handleError(LogPostProcessingService.class.getName(), '.createStacktraceCV', logger);
		
	}

    public static void createInboundEmailInternalLog(Messaging.inboundEmail email, Database.UpsertResult[] upsertResults, Logger loggerInst) {
        if(upsertResults == null || upsertResults.isEmpty()) return;

        String summary = 'Failed to create Inbound Email';
        String details = '';

        for(Database.UpsertResult upsertResult : upsertResults) {
            if(!upsertResult.isSuccess()) {
                for (Database.Error error : upsertResult.getErrors()) {
                    details = error.getMessage();
                    break;
                }
            }
        }

        if(String.isBlank(details)) return;

        Log__c log = LogBuilder.getInstance()
            .category(Logger.CATEGORY_PHAROS_ERROR)
            .summary(summary)
            .area(Logger.AREA_PHAROS_ERROR)
            .type('Error Email Handler')
            .details(details?.abbreviate(MAX_LENGTH_LONG_TEXT_AREA_FIELD))
            .build();
        
        DatabaseUtils.getInstance().performInsertDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
            .handleError(ErrorEmailHandler.class.getName(), '.createInboundEmailInternalLog');
        
        createInboundEmailCV(log.Id, email, loggerInst);
    }

    public static String createInboundEmailCV(Id relatedId, Messaging.inboundEmail inboundEmail, Logger loggerInst) {
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'InboundEmail.json';
        cv.VersionData = Blob.valueOf(JSON.serialize(inboundEmail));
        cv.Description = 'InboundEmail.json';
        cv.ContentLocation = 'S';
        DatabaseUtils.getInstance().performInsertDML(new List<ContentVersion>{cv}, Schema.SObjectType.ContentVersion)
            .handleError(ErrorEmailHandler.class.getName(), '.createInboundEmailCV', loggerInst);
        if (String.isNotBlank(cv.Id)) {
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = relatedId;
            cdl.ShareType = 'V';
            DatabaseUtils.getInstance().performInsertDML(new List<ContentDocumentLink>{cdl}, Schema.SObjectType.ContentDocumentLink)
                .handleError(ErrorEmailHandler.class.getName(), '.createInboundEmailCV', loggerInst);
        }
        return cv.Id;
    }

    public static void createInternalLog(String fullErrorMessage, Inbound_Email__c email, Logger loggerInst) {
        if(String.isBlank(fullErrorMessage)) return;

        String summary = ('Failed to create Log for Inbound Email: ' + fullErrorMessage).abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH);
        String details = fullErrorMessage + Constants.GLOBAL_VARIABLE.NEWLINE_CHARACTERS;
        if (String.isNotBlank(email?.Html_Body__c)
            && email?.Html_Body__c.startsWithIgnoreCase('<')) {
            details += email.Html_Body__c;
        }
        else if (String.isNotBlank(email?.Plain_Text__c)
            && (String.isBlank(email?.Html_Body__c)
                || (String.isNotBlank(email?.Html_Body__c) && !email?.Html_Body__c.startsWithIgnoreCase('<')))) {
            details += email.Plain_Text__c;
        }
        Log__c log = LogBuilder.getInstance()
            .category(Logger.CATEGORY_PHAROS_ERROR)
            .summary(summary)
            .area(Logger.AREA_PHAROS_ERROR)
            .type('Email Parser')
            .details(details?.abbreviate(MAX_LENGTH_LONG_TEXT_AREA_FIELD))
            .attribute(Schema.SObjectType.Log__c.fields.Related_Id__c.getName(), email?.Id)
            .build();
        if (String.isNotBlank(email?.Id)) {
            PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Related_Object_Type__c, Schema.SObjectType.Inbound_Email__c.getLabel());
        }
        loggerInst.add(log);
    }

    public static String maskContent(String text) {
        Map<String, SensitiveDataMask__c> masks = SensitiveDataMask__c.getAll();
        for (SensitiveDataMask__c mask : masks.values()) {
            try {
                text = text.replaceAll(mask.Regex__c, '********');
            } catch(Exception e) {}
        }
        return text;
    }

    public class ErrorEmailHandlerException extends Exception {}

    private static final String CHANGE_EMAIL_SUBJECT_MARKER = 'Finish changing your Salesforce account’s email address';

    public static Boolean isChangeEmail(String subject) {
        return (String.isNotBlank(subject) && subject.containsIgnoreCase(CHANGE_EMAIL_SUBJECT_MARKER));
    }

}