global with sharing virtual class FlowExceptionParser implements IErrorParser {

    public static final String FLOW_EXCEPTION = 'FlowException';
    public static final String FLOW_CATEGORY = 'Flow';
    public static final String PROCESS_BUILDER_CATEGORY = 'Process Builder';
    public static final String PROCESS_BUILDER_EXCEPTION = 'ProcessBuilderException';
    public static final String PARSER_AREA_FLOW = 'Flow';
    public static final String PARSER_AREA_PROCESS_BUILDER = 'Process Builder';
    public static final String PARSER_TOKEN = 'Flow Details';
    public static final String PARSER_SYSTEM_PREFIX = 'System.';
    public static final String PARSER_SUMMARY_UNDEFINED = 'Undefined';

    public static final String PB_TYPE_RECORD_CHANGE_PROCESS = 'Record Change Process';
    public static final String PB_TYPE_PLATFORM_EVENT_PROCESS = 'Platform Event Process';
    public static final String PB_TYPE_INVOCABLE_PROCESS = 'Invocable Process';
    public static final String UNDEFINED_TYPE = 'Undefined';
    public static final String HANDLED_ERROR_TOKEN = 'Error Handled';

    // GLOBAL

    global FlowExceptionParser() {}

    global virtual void init(String errorBody, String emailSubject, String emailSentFrom) {
        this.originalMessage = (String.isNotBlank(errorBody)) ? errorBody.stripHtmlTags() : errorBody;
        this.stacktrace = errorBody;
        this.emailSubject = emailSubject;
    }

    global virtual Boolean canProcess() {
        String msg = getError();
        return !String.isBlank(msg) && msg.containsIgnoreCase(PARSER_TOKEN);
    }

    global virtual void process() {
        parseErrorMessage();
    }

    global virtual String getError() {
        return this.originalMessage;
    }

    global virtual String getErrorSummary() {
        return this.summary;
    }

    public static String getValueForHash(String inputValue) {
        if(String.isNotBlank(inputValue)) {
            // remove flow guid
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_GUID_PATTERN, '');
            // remove times
            inputValue = inputValue.replaceAll(LogService.REGEX_TIME_PATTERN, '');
            // remove all IDs (pseudo Ids)
            inputValue = inputValue.replaceAll(LogService.REGEX_ID_PATTERN, '');
            // remove all Non-alphanum characters and whitespaces
            inputValue = inputValue.replaceAll(LogService.REGEX_NON_ALPHANUMERIC_PATTERN, '');
            // remove all numbers
            inputValue = inputValue.replaceAll(LogService.REGEX_ALL_NUMBERS_PATTERN, '');
            // remove current user
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_CURRENT_USER, '');
            // remove running user
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_RUNNING_USER, '');
        }
        return inputValue;
    }

    global virtual String getErrorDetails() {
        return this.originalMessage;
    }

    global virtual String getVisualforcePage() {
        return this.visualforcePage;
    }

    global virtual String getRelatedId() {
        return this.relatedId;
    }

    global virtual String getRelatedObjectType() {
        return this.relatedObjectType;
    }

    global virtual String getAsyncJobName() {
        return this.asyncJobName;
    }

    global virtual String getAsyncJobId() {
        return this.asyncJobId;
    }

    global virtual String getErrorType() {
        return this.errorType;
    }

    global virtual String getArea() {
        return this.area;
    }

    global virtual String getUserId() {
        return this.userId;
    }

    global virtual String getOrganizationId() {
        return this.organizationId;
    }

    global virtual String getStackTrace() {
        return this.stacktrace;
    }

    global virtual String parseStackTrace() {
        return null;
    }

    global virtual String getMethodName() {
        return this.operation;
    }

    global virtual String getHash1() {
        String value = getFlowApiName() + getFlowVersion() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()) + getFlowErrorElement());
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getHash2() {
        String value = getFlowVersion() + getFlowApiName() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()));
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getHash3() {
        String value = getFlowApiName() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()));
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getPendingJobsInfo() {
        return null;
    }

    global virtual Decimal getTotalActiveSessions() {
        return null;
    }

    global virtual String getAuditTrail() {
        return null;
    }

    global virtual String getInstalledPackagesInfo() {
        return null;
    }

    global virtual String getNamespace() {
        return this.namespace;
    }

    global virtual String getDeploymentsInfo() {
        return null;
    }

    global virtual String getSalesforceErrorId() {
        return this.salesforceErrorId;
    }

    global virtual String getFlowVersion() {
        return this.flowVersion;
    }

    private String getCategory() {
        return this.category;
    }

    private String getFlowApiName() {
        return this.flowApiName;
    }

    private String getRelatedObjects() {
        return this.relatedObjects;
    }

    private String getInterviewGUID() {
        return this.interviewGUID;
    }

    private String getDuration() {
        return this.duration;
    }

    private String getFlowErrorElement() {
        return this.flowErrorElement;
    }

    global virtual List<ICustomErrorInfo> getCustomInfo() {
        List<ICustomErrorInfo> customFields = new List<ICustomErrorInfo>{
            new CategoryField(this.getCategory()),
            new FlowApiNameField(this.getFlowApiName()),
            new RelatedObjectsField(this.getRelatedObjects()),
            new InterviewGUIDField(this.getInterviewGUID()),
            new DurationField(this.getDuration())
        };
        if(isLogLevelFieldAvailable()) {
            customFields.add(new LogLevelField(DEFAULT_LOG_LEVEL));
        }
        return customFields;
    }

    public class FlowApiNameField implements  ICustomErrorInfo {
        public String flowAPIName;
        public FlowApiNameField(String value) {
            this.flowAPIName = value;
        }
        public String getValue() {
            return this.flowAPIName;
        }
        public String getLogFieldName() {
            return Schema.sObjectType.Log__c.fields.Flow_API_Name__c.getName();
        }
    }

    public class CategoryField implements ICustomErrorInfo {
        public String category;
        public CategoryField(String value) {
            this.category = value;
        }
        public String getValue() {
            return this.category;
        }
        public String getLogFieldName() {
            return Schema.sObjectType.Log__c.fields.Category__c.getName();
        }
    }

    public class RelatedObjectsField implements ICustomErrorInfo {
        public String relatedObjects;
        public RelatedObjectsField(String value) {
            this.relatedObjects = value;
        }
        public String getValue() {
            return this.relatedObjects;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Related_Objects__c.getName();
        }
    }

    public class InterviewGUIDField implements ICustomErrorInfo {
        public String interviewGUID;
        public InterviewGUIDField(String value) {
            this.interviewGUID = value;
        }
        public String getValue() {
            return this.interviewGUID;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Interview_GUID_External__c.getName();
        }
    }

    public class DurationField implements ICustomErrorInfo {
        public String duration;
        public DurationField(String value) {
            this.duration = value.replace(' seconds', '');
        }
        public String getValue() {
            return this.duration;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Duration__c.getName();
        }
    }

    @TestVisible
    private static String LOG_LEVEL_FIELD_NAME = 'Log_Level__c';
    private static final String DEFAULT_LOG_LEVEL = 'ERROR';
    @TestVisible
    private static String LOG_LEVEL_FIELD_API_NAME = ConfigUtil.prefixCurrentOrgNamespace(LOG_LEVEL_FIELD_NAME);

    @TestVisible
    private static Boolean isLogLevelFieldAvailable() {
        return Schema.sObjectType.Log__c.fields.getMap().containsKey(LOG_LEVEL_FIELD_API_NAME.toLowerCase());
    }

    public class LogLevelField implements ICustomErrorInfo {
        public String logLevel;
        public LogLevelField(String value) {
            this.logLevel = value;
        }
        public String getValue() {
            return this.logLevel;
        }
        public String getLogFieldName() {
            return LOG_LEVEL_FIELD_API_NAME;
        }
    }

    global virtual List<Queueable> getAsyncMethods(Id logId) {
        List<Queueable> asyncMethods = new List<Queueable>();
        return asyncMethods;
    }

    global class FlowExceptionParserException extends Exception {}

    // PRIVATE
    public String originalMessage = null;
    public String emailSubject;
    private String summary;
    private String visualforcePage;
    private String relatedId;
    private String relatedObjectType;
    private String relatedObjects;
    private String area;
    private String userId;
    private String organizationId;
    private String asyncJobName;
    private String asyncJobId;
    private String stacktrace;
    private String errorType;
    private String operation;
    private String flowVersion;
    private String salesforceErrorId;
    private String flowApiName;
    private String namespace;
    private String flowErrorElement;
    private String category;
    private String interviewGUID;
    private String duration;

    private void parseErrorMessage() {
        FlowService.FlowStacktraceParser parser = new FlowService.FlowStacktraceParser(getStackTrace());
        FlowService.FlowStacktraceInfo stackTraceInfo = parser.parse();

        if (stackTraceInfo != null && !stackTraceInfo.stacktraceElements.isEmpty()) {
            FlowService.FlowStacktraceElement lastElement = stackTraceInfo.stacktraceElements.get(stackTraceInfo.stacktraceElements.size() - 1);
            String operation =  lastElement.apiType;
            if(String.isNotBlank(operation)) {
                this.operation = operation;
            }
        }
        
        this.area = PARSER_AREA_FLOW;
        this.category = FLOW_CATEGORY;

        String flowType = stackTraceInfo?.flowDetails?.type;
        if(String.isNotBlank(flowType) &&
            (flowType.containsIgnoreCase(PB_TYPE_RECORD_CHANGE_PROCESS)
                || flowType.containsIgnoreCase(PB_TYPE_PLATFORM_EVENT_PROCESS)
                || flowType.containsIgnoreCase(PB_TYPE_INVOCABLE_PROCESS))) {
            this.category = PROCESS_BUILDER_CATEGORY;
            this.area = PARSER_AREA_PROCESS_BUILDER;
        }

        if(String.isNotBlank(flowType)) {
            this.errorType = flowType;
        }
        if(String.isBlank(this.errorType)) {
            this.errorType = UNDEFINED_TYPE;
        }

        String summaryValue = stackTraceInfo?.errorMessage;
        this.summary = (String.isNotBlank(summaryValue)) ? summaryValue.abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH) : this.emailSubject;
        if(this.emailSubject.startsWith(FlowService.FLOW_ERROR_MESSAGE_SEPARATOR)) {
            this.summary = this.emailSubject?.removeStart(FlowService.FLOW_ERROR_MESSAGE_SEPARATOR)?.abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH);
        }
        this.userId = stackTraceInfo?.flowInterviewDetails?.currentUserId;
        this.interviewGUID = stackTraceInfo?.flowInterviewDetails?.interviewGUID;
        this.duration = stackTraceInfo?.flowInterviewDetails?.duration;
        this.organizationId = stackTraceInfo?.flowDetails?.orgId;
        this.salesforceErrorId = stackTraceInfo?.salesforceErrorId;
        this.flowVersion = stackTraceInfo?.flowDetails?.version;
        this.flowApiName = stackTraceInfo?.flowDetails?.flowApiName;

        // somepackagenamespace__SomeFlowApiName
        if(String.isNotBlank(this.flowApiName)) {
            List<String> parts = this.flowApiName?.split('__', 2);
            if(parts != null && parts?.size() == 2) {
                this.namespace = parts.get(0);
            }
        }

        List<String> executionPathList = getFlowExecutionPathList();
        if(!executionPathList.isEmpty()) {
            Set<String> executionPathSet = new Set<String>();
            for(String pathElement : executionPathList) {
                executionPathSet.add(pathElement);
            }
            this.flowErrorElement = executionPathList.get(executionPathList.size() - 1);
        }

        this.relatedId = stackTraceInfo?.howTheInterviewStarted?.recordId;
        this.relatedObjectType = stackTraceInfo?.howTheInterviewStarted?.recordName;

        ConfigUtil.HTMLStringRowIterator rIterator = new ConfigUtil.HTMLStringRowIterator(String.isNotBlank(stackTraceInfo?.errorMessage) ? stackTraceInfo?.errorMessage : this.emailSubject);
        Pattern p = Constants.GLOBAL_VARIABLE.PATTERN_SOBJECT_ID;
        Set<String> relatedIds = new Set<String>();

        String stacktraceRow;
        while(rIterator.hasNext()) {
            stacktraceRow = rIterator.next();
            Set<String> relatedIdsFromMessage = ConfigUtil.getRelatedSObjectIds(stacktraceRow, false);
            relatedIds.addAll(relatedIdsFromMessage);
        }
        if (!relatedIds.isEmpty()) this.relatedObjects = JSON.serialize(relatedIds);
    }

    private List<String> getFlowExecutionPathList() {
        List<String> executionPathList = FlowService.getFlowExecutionPath(getStackTrace());
        return executionPathList;
    }
}