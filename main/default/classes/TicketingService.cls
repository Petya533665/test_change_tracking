public with sharing class TicketingService {

    public ENUM TICKETING_SERVICE_TYPE {JIRA, AZURE_DEV_OPS}
    private Logger logger;
    private TicketingServiceInterface strategy;
    private Boolean shouldMarkForRecursionPrevention = false;
    public static final String AZURE_DEV_OPS_ERROR_CREATE_TAGS = 'TF401289:';
    private static final String ERROR_INVALID_AZURE_DEVOPS_WORK_ITEM_URL =
        'Invalid Azure DevOps work item URL in Bug Tracker field. ' +
        'Expected something like https://dev.azure.com/{org}/{project}/_workitems/edit/{id}. ';

    /**
     * Filters chart->report data to only include non-empty datasets.
     * This prevents Lambda 400 errors like "No chart data provided" when reports return empty arrays ("[]").
     *
     * @param input Chart->(SystemReport->JSON string) map
     * @return Filtered map containing only charts that have at least one non-empty report payload
     */
    @TestVisible
    private static Map<ChartService.Chart, Map<ReportService.SystemReport, String>> filterChartDataWithContent(
        Map<ChartService.Chart, Map<ReportService.SystemReport, String>> input
    ) {
        Map<ChartService.Chart, Map<ReportService.SystemReport, String>> result =
            new Map<ChartService.Chart, Map<ReportService.SystemReport, String>>();

        if (input == null || input.isEmpty()) {
            return result;
        }

        for (ChartService.Chart chartKey : input.keySet()) {
            Map<ReportService.SystemReport, String> reports = input.get(chartKey);
            if (reports == null || reports.isEmpty()) {
                continue;
            }

            Map<ReportService.SystemReport, String> filteredReports = new Map<ReportService.SystemReport, String>();
            for (ReportService.SystemReport reportKey : reports.keySet()) {
                String payload = reports.get(reportKey);
                if (hasNonEmptyJsonPayload(payload)) {
                    filteredReports.put(reportKey, payload);
                }
            }

            if (!filteredReports.isEmpty()) {
                result.put(chartKey, filteredReports);
            }
        }

        return result;
    }

    /**
     * Checks whether a JSON payload contains meaningful data.
     * Treats blank / "null" / empty array / empty object as empty.
     */
    @TestVisible
    private static Boolean hasNonEmptyJsonPayload(String payload) {
        if (String.isBlank(payload)) {
            return false;
        }
        String trimmed = payload.trim();
        if (trimmed == 'null' || trimmed == '[]' || trimmed == '{}' ) {
            return false;
        }

        // If it's valid JSON, ensure collections are non-empty.
        try {
            Object parsed = JSON.deserializeUntyped(trimmed);
            if (parsed == null) {
                return false;
            }
            if (parsed instanceof List<Object>) {
                return !((List<Object>) parsed).isEmpty();
            }
            if (parsed instanceof Map<String, Object>) {
                return !((Map<String, Object>) parsed).isEmpty();
            }
        } catch (Exception e) {
            // If not valid JSON for some reason, assume it's meaningful (avoid false negatives).
            return true;
        }

        // Scalars (String/Number/Boolean) are considered meaningful if non-blank at this point.
        return true;
    }

    private static final Map<TICKETING_SERVICE_TYPE, TicketingServiceInterface> TYPE_TO_SERVICE = new Map<TICKETING_SERVICE_TYPE, TicketingServiceInterface>{
        TICKETING_SERVICE_TYPE.JIRA => new TicketingServiceJiraImpl(),
        TICKETING_SERVICE_TYPE.AZURE_DEV_OPS => new TicketingServiceAzureDevOpsImpl()
    };
    private static final Map<RuleUtil.ActionType, TicketingServiceInterface> ACTION_TYPE_TO_SERVICE = new Map<RuleUtil.ActionType, TicketingServiceInterface>{
        RuleUtil.ActionType.JIRA => new TicketingServiceJiraImpl(),
        RuleUtil.ActionType.JIRA_TICKET_COMMENT => new TicketingServiceJiraImpl(),
        RuleUtil.ActionType.AZURE_DEV_OPS => new TicketingServiceAzureDevOpsImpl(),
        RuleUtil.ActionType.AZURE_DEV_OPS_WORK_ITEM_COMMENT => new TicketingServiceAzureDevOpsImpl()
    };

    public TicketingService(RuleUtil.ActionType actionType, Logger logger) {
        this.logger = logger;
        this.strategy = ACTION_TYPE_TO_SERVICE.get(actionType);
    }

    public TicketingService(RuleUtil.ActionType actionType, Logger logger, Boolean shouldMarkForRecursionPrevention) {
        this.logger = logger;
        this.strategy = ACTION_TYPE_TO_SERVICE.get(actionType);
        this.shouldMarkForRecursionPrevention = shouldMarkForRecursionPrevention;
    }

    public TicketingService(TICKETING_SERVICE_TYPE serviceType, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE.get(serviceType);
    }

    public TicketCreateResult createTicket(TicketingServiceInputData data) {
        this.strategy.init(data, this.logger, this.shouldMarkForRecursionPrevention);
        return this.strategy.createTicket();
    }

    public void createTicketComment(TicketingServiceInputData data) {
        this.strategy.init(data, this.logger, this.shouldMarkForRecursionPrevention);
        this.strategy.createTicketComment();
    }

    public class TicketCreateResult {
        public String id;
        public String url;
        public String errorMessage;

        public TicketCreateResult() {
            this('', '');
        }

        public TicketCreateResult(String id, String url) {
            this.id = id;
            this.url = url;
            this.errorMessage = errorMessage;
        }
    }

    public interface TicketingServiceInterface {
        void init(TicketingServiceInputData data, Logger logger, Boolean shouldMarkForRecursionPrevention);
        void linkExistingTickets();
        void handleCreateTicketError(Exception e);
        TicketCreateResult createTicket();
        TicketCreateResult getExistingTickets();
        TicketCreateResult createNewTicket();
        void createTicketComment();
        void createNewTicketComment();
        Boolean isPermissionDisabled();
        Boolean isExistingTicketOpen();
        String getCompletedTicketStatus();
        TicketStatusInfo getTicketStatus();
        void createTicketRelations(TicketCreateResult result);
        
    }

    public class TicketStatusInfo {
        public String status;
        public DateTime resolutionDateTime;

        public TicketStatusInfo(String status, DateTime resolutionDateTime) {
            this.status = status;
            this.resolutionDateTime = resolutionDateTime;
        }
    }

    public class TicketingServiceSettings {
        public Boolean createUniqueTicketsByOrg;
        public Boolean autoRelateTicketsWithSimilarErrors;
        public Boolean autoGenerateSimilarityLabels;

        public TicketingServiceSettings(Jira_Settings__c settings) {
            this.autoGenerateSimilarityLabels = settings.Auto_Generate_Similarity_Labels__c;
            this.autoRelateTicketsWithSimilarErrors = settings.Auto_Relate_Tickets_With_Similar_Errors__c;
            this.createUniqueTicketsByOrg = settings.Create_Unique_Tickets_by_Org__c;
        }

        public TicketingServiceSettings(Azure_Dev_Ops_API_Settings__c settings) {
            this.autoGenerateSimilarityLabels = settings.Auto_Generate_Similarity_Labels__c;
            this.autoRelateTicketsWithSimilarErrors = settings.Auto_Relate_Tickets_With_Similar_Errors__c;
            this.createUniqueTicketsByOrg = settings.Create_Unique_Tickets_by_Org__c;
        }
    }
    
    public with sharing abstract class TicketingServiceDefaultImpl implements TicketingServiceInterface {
        
        private TicketingSObjectWrapper sobjectWrapper;
        private TicketingTaskInfo taskInfo;
        private Logger logger;
        private Boolean shouldMarkForRecursionPrevention = false;
        public TicketingServiceSettings settings;

        public virtual void init(TicketingServiceInputData data, Logger logger, Boolean shouldMarkForRecursionPrevention) {
            this.logger = logger;
            this.shouldMarkForRecursionPrevention = shouldMarkForRecursionPrevention;
            if(String.isNotBlank(data.recordId)) {
                this.sobjectWrapper = new TicketingSobjectWrapper(data.recordId);
                this.taskInfo = new TicketingTaskInfo(data.action, this.sobjectWrapper);
            }
            if(data.eventAction != null) {
                this.taskInfo = new TicketingTaskInfo(data.eventAction);
            }
        }

        public abstract Boolean isPermissionDisabled();
        public abstract TicketCreateResult getExistingTickets();
        public abstract String getCompletedTicketStatus();
        public abstract TicketStatusInfo getTicketStatus();
        public abstract TicketCreateResult createNewTicket();
        public abstract void createNewTicketComment();
        public abstract void createTicketRelations(TicketCreateResult result);

        // If a ticket exists for the same org and is open, do NOT create a new ticket.
        public virtual Boolean isExistingTicketOpen() {
            if (this?.sObjectWrapper?.sObjectRecord?.getSobjectType() == Log__c.SObjectType) {
                List<Log__c> sameOpenLogsByHash1 = getSameOpenLogsByHash1(this.sobjectWrapper, this.settings.createUniqueTicketsByOrg);
                return (!sameOpenLogsByHash1.isEmpty());
            }
            return false;
        }

        public virtual Boolean isEventAction() {
            return this.sobjectWrapper == null && this.taskInfo != null;
        }

        public virtual Boolean isInvalidDataTaskInfo() {
            return this.taskInfo == null;
        }

        public virtual void createTicketComment() {
            try {
                if(isPermissionDisabled()) return;
                if(isInvalidDataTaskInfo()) return;
                createNewTicketComment();
                
                // Only update SObject if we have a wrapper (not for event actions)
                if (this.sObjectWrapper != null) {
                    SObject sObjectRecord = PermissionsUtil.newSObject(this.sObjectWrapper.describeSObjectResult);
                    PermissionsUtil.putSObjectField(sObjectRecord, 'Id', this.sObjectWrapper.id);
                    PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrJiraIntegrationStatus, ConfigUtil.NEW_TICKET_CREATED_STATUS);
                    DatabaseUtils.getInstance().performUpdateDML(new List<SObject>{sObjectRecord}, this.sObjectWrapper.describeSObjectResult)
                            .handleError(TicketingService.class.getName(), '.saveCreatedTicketCommentInfo', logger);
                }
            }
            catch(Exception e) {
                // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
                if (this.logger != null) {
                    Log__c errorLog = this.logger.getInternalError(e, (String)null, TicketingService.class.getName(), 'createTicketComment', this.shouldMarkForRecursionPrevention);
                    this.logger.add(errorLog);
                }
            }
        }

        public virtual TicketCreateResult createTicket() {
            TicketCreateResult result = new TicketCreateResult();
            try {
                if(isPermissionDisabled()) return result;
                if(isInvalidDataTaskInfo()) return result;
                // monitoring from events
                if(isEventAction()) return createNewTicket();

                TicketStatusInfo ticketStatus = getTicketStatus();

                Boolean isLog = this.sObjectWrapper?.sObjectType == Log__c.SObjectType;
                Boolean isIssue = this.sObjectWrapper?.sObjectType == Issue__c.SObjectType;
                
                Boolean isRemoteTicketNotExist = ticketStatus == null;
                Boolean isRemoteTicketNotCompleted = !isRemoteTicketNotExist 
                    && ticketStatus.resolutionDateTime == null
                    && getCompletedTicketStatus() != ticketStatus.status;

                Boolean dontNeedCreateLogTicket = isLog 
                    && ((isRemoteTicketNotExist && String.isNotBlank(getBugTrackerLinkFromLogIndex()))
                    || isRemoteTicketNotCompleted);
                Boolean dontNeedCreateIssueTicket = isIssue && isRemoteTicketNotCompleted;

                if(dontNeedCreateLogTicket || dontNeedCreateIssueTicket) {
                    linkExistingTickets();
                    return getExistingTickets();
                }
                else {
                    result = createNewTicket();
                    createTicketRelations(result);
                    saveCreatedTicketInfo(result, ticketStatus);
                }
            }
            catch(Exception e) {
                handleCreateTicketError(e);
                result = new TicketCreateResult();
                result.errorMessage = e.getMessage();
            }
            return result;
        }

        public virtual String getBugTrackerLinkFromLogIndex() {
            // Only get bug tracker link if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null) {
                return null;
            }
            String key = ConfigUtil.getLogIndexKey(this.sObjectWrapper.hash1, this.sObjectWrapper.organizationId);
            ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{key});
            ConfigUtil.LogIndex index = helper.getLogIndex(key);
            return index?.bugTracker;
        }

        public virtual void handleCreateTicketError(Exception e) {
            // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
            if (this.logger != null) {
                Log__c errorLog = this.logger.getInternalError(e, (String)null, TicketingService.class.getName(), 'createTicket', this.shouldMarkForRecursionPrevention);
                this.logger.add(errorLog);
            }

            // Only update SObject if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null) {
                SObject sObjectRecord = PermissionsUtil.newSObject(this.sObjectWrapper.describeSObjectResult);
                PermissionsUtil.putSObjectField(sObjectRecord, 'Id', this.sObjectWrapper.id);
                PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrBugTracker, null);
                PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrJiraIntegrationStatus, ConfigUtil.TICKET_CREATE_ERROR_STATUS);
                DatabaseUtils.getInstance().performUpdateDML(new List<SObject>{sObjectRecord}, this.sObjectWrapper.describeSObjectResult)
                        .handleError(TicketingService.class.getName(), '.handleCreateTicketError', logger);
            }
        }

        public virtual void saveCreatedTicketInfo(TicketCreateResult result, TicketStatusInfo ticketStatus) {
            String ticketUrl = result.url;

            // Only update SObject if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null) {
                if(this.sObjectWrapper.sObjectType == Log__c.SObjectType) {
                    String logIndexKey = ConfigUtil.getLogIndexKey(this.sObjectWrapper.hash1, this.sObjectWrapper.organizationId);
                    ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logIndexKey});
                    ConfigUtil.LogIndex index = helper.getLogIndex(this.sObjectWrapper.hash1, this.sObjectWrapper.organizationId);
                    if(index != null) {
                        index.bugTracker = ticketUrl;
                        index.resolvedOn = null;
                        helper.saveLogIndex(logger, index);
                    }
                }

                String query = new QBuilder(this.sObjectWrapper.sObjectType)
                    .selectFields(new Set<String>{'Id', this.sObjectWrapper.dfrBugTracker.getName(), this.sObjectWrapper.dfrJiraIntegrationStatus.getName()})
                    .add(QBuilder.condition(this.sObjectWrapper.dfrHash1.getName()).equalsTo(this.sObjectWrapper.hash1))
                    .add(QBuilder.condition(this.sObjectWrapper.dfrHash1.getName()).notEqualsTo(null))
                    .add(QBuilder.condition(this.sObjectWrapper.dfrBugTracker.getName()).equalsTo(null))
                    .add(this.sObjectWrapper.sObjectType == Log__c.SObjectType && this.sObjectWrapper.dfrOrganizationId != null
                        ? QBuilder.condition(this.sObjectWrapper.dfrOrganizationId.getName()).equalsTo(this.sObjectWrapper.organizationId)
                        : null
                    )
                    .add(QBuilder.condition('Id').notEqualsTo(this.sObjectWrapper.id))
                    .build();
                List<SObject> sObjectRecordsToUpdate = new List<SObject>();
                for (SObject sObjectRecordWithHash1 : Database.query(query)) {
                    SObject sObjectRecord = PermissionsUtil.newSObject(this.sObjectWrapper.describeSObjectResult);
                    PermissionsUtil.putSObjectField(sObjectRecord, 'Id', sObjectRecordWithHash1.Id);
                    PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrBugTracker, ticketUrl);
                    PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrJiraIntegrationStatus, ConfigUtil.EXISTING_TICKET_LINKED_STATUS);
                    if(ticketStatus?.resolutionDateTime != null) {
                        PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrResolvedOn, ticketStatus?.resolutionDateTime);
                    }
                    sObjectRecordsToUpdate.add(sObjectRecord);
                }

                if (!sObjectRecordsToUpdate.isEmpty()) {
                    DatabaseUtils.getInstance().performUpdateDML(sObjectRecordsToUpdate, sObjectWrapper.describeSObjectResult)
                            .handleError(TicketingService.class.getName(), '.saveCreatedTicketInfo', logger);
                }
                SObject sObjectRecord = PermissionsUtil.newSObject(this.sObjectWrapper.describeSObjectResult);
                PermissionsUtil.putSObjectField(sObjectRecord, 'Id', this.sObjectWrapper.id);
                PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrBugTracker, ticketUrl);
                PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrJiraIntegrationStatus, ConfigUtil.NEW_TICKET_CREATED_STATUS);
                DatabaseUtils.getInstance().performUpdateDML(new List<SObject>{sObjectRecord}, this.sObjectWrapper.describeSObjectResult)
                        .handleError(TicketingService.class.getName(), '.saveCreatedTicketInfo', logger);
            }
        }

        public virtual void linkExistingTickets() {
            // Only link existing tickets if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null) {
                return;
            }

            SObject sObjectRecord = PermissionsUtil.newSObject(this.sObjectWrapper.describeSObjectResult);
            PermissionsUtil.putSObjectField(sObjectRecord, 'Id', this.sObjectWrapper.id);
            if(sObjectRecord.getSObjectType() == Log__c.SObjectType) {
                this.sObjectWrapper.bugTracker = getBugTrackerLinkFromLogIndex();
                PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrBugTracker, this.sObjectWrapper.bugTracker);
            }
            if(String.isBlank(this.sObjectWrapper.bugTracker)) {
                return;
            }

            PermissionsUtil.putSObjectField(sObjectRecord, this.sObjectWrapper.dfrJiraIntegrationStatus, ConfigUtil.EXISTING_TICKET_LINKED_STATUS);
            DatabaseUtils.getInstance().performUpdateDML(new List<SObject>{sObjectRecord}, this.sObjectWrapper.describeSObjectResult)
                    .handleError(TicketingService.class.getName(), '.linkExistingTickets', logger);

            /*
             Search for other Logs with Hash1 and Empty Bug_Tracker field
            */
            if (sObjectRecord.getSObjectType() == Log__c.SObjectType) {
                List<Log__c> logsWithHash1 = getOtherLogsWithHash1AndEmptyBugTrackerLink((Log__c)sObjectWrapper.sObjectRecord, this.settings.createUniqueTicketsByOrg);
                for (Log__c l : logsWithHash1) {
                    if (String.isBlank(l.Bug_Tracker__c)) {
                        l.Bug_Tracker__c = this.sObjectWrapper.bugTracker;
                        l.Jira_Integration_Status__c = ConfigUtil.EXISTING_TICKET_LINKED_STATUS;
                    }
                }
                DatabaseUtils.getInstance().performUpdateDML(logsWithHash1, Schema.SObjectType.Log__c)
                        .handleError(TicketingService.class.getName(), '.linkExistingTickets', logger);
            }
        }
    }

    public class TicketingServiceInputData {
        public String recordId;
        public EventAction__c eventAction;
        public Action__c action;
        public TicketingTaskInfo taskInfo;

        public TicketingServiceInputData(Id recordId, Action__c action, EventAction__c eventAction) {
            this.recordId = recordId;
            this.action = action;
            this.eventAction = eventAction;
        }

        public TicketingServiceInputData(Id recordId, Action__c action) {
            this(recordId, action, null);
        }
        public TicketingServiceInputData(EventAction__c eventAction) {
            this(null, null, eventAction);
        }
        public void setTaskInfo(TicketingTaskInfo taskInfo) {
            this.taskInfo = taskInfo;
        }
    }

    public class TicketingServiceJiraImpl extends TicketingServiceDefaultImpl {

        private Map<String, Object> bodyRequest;

        public override String getCompletedTicketStatus() {
            return 'done';
        }
        
        public override void init(TicketingServiceInputData data, Logger logger, Boolean shouldMarkForRecursionPrevention) {
            super.init(data, logger, shouldMarkForRecursionPrevention);
            this.settings = new TicketingServiceSettings(ConfigUtil.JIRA_SETTINGS);
        }

        public override Boolean isPermissionDisabled() {
            return !PermissionsUtil.JiraIntegrationEnabled;
        }

        public override TicketStatusInfo getTicketStatus() {
            TicketStatusInfo result;
            // Only get ticket status if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null && this.sObjectWrapper.sObjectRecord.getSobjectType() == Log__c.SObjectType) {
                if(String.isBlank(this.sObjectWrapper.bugTracker)) {
                    this.sObjectWrapper.bugTracker = getBugTrackerLinkFromLogIndex();
                }
                if(String.isNotBlank(this.sObjectWrapper.bugTracker)) {
                    String existingIssueKey = JiraService.getIssueKeyByUrl(this.sObjectWrapper.bugTracker);
                    JiraService.JiraIssue issueInfo = JiraService.getService().getJiraIssueByKey(existingIssueKey, null);
                    DateTime resolutionDateTime = JiraService.parseJiraDateTime(issueInfo.resolutiondate, null);
                    result = new TicketStatusInfo(issueInfo?.fields?.status?.statusCategory?.key, resolutionDateTime);
                }
            }
            return result;
        }

        public override TicketCreateResult getExistingTickets() {
            // Only get existing tickets if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null || String.isBlank(this.sObjectWrapper.bugTracker)) {
                return null;
            }
            String existingIssueKey = JiraService.getIssueKeyByUrl(this.sObjectWrapper.bugTracker);
            return new TicketCreateResult(existingIssueKey, this.sObjectWrapper.bugTracker);
        }

        private void populateCustomFields(Map<String, JiraService.JiraProjectIssueField> allProjectCustomFields) {
            Set<String> projectCustomFields = new Set<String>();
            if(!allProjectCustomFields.isEmpty()) {
                for (JiraService.JiraProjectIssueField f : allProjectCustomFields.values()) {
                    projectCustomFields.add(f.key);
                }
            }
            this.taskInfo.customFields = new Map<String, String>();
            try {
                if (String.isNotBlank(this.taskInfo.additionalMetadata)) {
                    // Use the helper method to parse both old and new formats
                    Map<String, String> customFields = TicketingService.parseAdditionalMetadataForMergeFields(this.taskInfo.additionalMetadata);
                    for (String key : customFields.keySet()) {
                        if (projectCustomFields.contains(key)) {
                            this.taskInfo.customFields.put(key, customFields.get(key));
                        }
                    }
                }
            }
            catch (Exception e) {
                // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
                if (this.logger != null) {
                    Log__c errorLog = this.logger.getInternalError(e, (String)null, JiraService.class.getName(), 'customFields', this.shouldMarkForRecursionPrevention);
                    this.logger.add(errorLog);
                }
            }
            if(this.taskInfo.customFields != null) {
                for (String key : this.taskInfo.customFields.keySet()) {
                    String rawValue = this.taskInfo.customFields.get(key);
                    JiraService.JiraProjectIssueField field = allProjectCustomFields.get(key);
                    Object transformedValue = JiraService.getService(this.logger).transformCustomFieldValue(rawValue, field, this.logger);
                    ((Map<String, Object>)(this.bodyRequest.get(ADFBuilder.ATTR_FIELDS))).put(key, transformedValue);
                }
            }
        }

        private void populateDefaultFields() {
            // For event actions, we don't have an sObjectWrapper, so we can't populate these fields
            if (this.sObjectWrapper != null) {
                this.taskInfo.recordId = this.sObjectWrapper.id;
                this.taskInfo.hash2 = this.sObjectWrapper.hash2;
                this.taskInfo.hash3 = this.sObjectWrapper.hash3;
            }
            Integer detailsFieldLength = Integer.valueOf(ConfigUtil.JIRA_SETTINGS.Jira_Details_Field_Length__c > 0 ? ConfigUtil.JIRA_SETTINGS.Jira_Details_Field_Length__c : 30000);
            this.taskInfo.details = this.taskInfo.details.abbreviate(detailsFieldLength);
	        this.bodyRequest = new Map<String, Object>{
                ADFBuilder.ATTR_FIELDS => new Map<String, Object>{
                    ADFBuilder.ATTR_PROJECT => new Map<String, Object>{
                        'id' => this.taskInfo.projectId
                    },
                    ADFBuilder.ATTR_ISSUE_TYPE => new Map<String, Object>{
                        'id' => this.taskInfo.issueTypeId
                    },
                    ADFBuilder.ATTR_SUMMARY => this.taskInfo.summary,
                    ADFBuilder.ATTR_DESCRIPTION => JiraService.isCloudJiraInstance() ? (this.taskInfo.details != null && this.taskInfo.details.trim().startsWith('{') ? (Object)JSON.deserializeUntyped(this.taskInfo.details) : TicketingService.textToAtlassianDocumentFormatContent(this.taskInfo.details, true)) : this.taskInfo.details
                }
            };
        }

        private void populatePriority(List<JiraService.JiraProjectIssueField> allFields) {
            Boolean hasPriority = JiraService.projectHasPriorityField(allFields);
            if (hasPriority && String.isNotBlank(this.taskInfo.priority)) {
                ((Map<String, Object>)(this.bodyRequest.get('fields'))).put(
                    'priority', new Map<String, Object>{
                        'id' => this.taskInfo.priority
                    }
                );
            }
        }

        private void populateUser() {
            if (String.isNotBlank(this.taskInfo.assignee)) {
                String assigneeKey = (JiraService.isCloudJiraInstance() || JiraService.isJiraHashId(this.taskInfo.assignee)) ? 'id' : 'name';
                ((Map<String, Object>)(this.bodyRequest.get('fields'))).put(
                    'assignee', new Map<String, Object>{
                        assigneeKey => this.taskInfo.assignee
                    }
                );
            }
        }

        private void populateLabels() {
            if(this.settings.autoGenerateSimilarityLabels) {
                List<String> labelsWithHashesList = new List<String>();
                if (String.isNotBlank(this.taskInfo.labels)) {
                    labelsWithHashesList.add(this.taskInfo.labels);
                }
                if (String.isNotBlank(this.taskInfo.hash2)) {
                    labelsWithHashesList.add('h2_' + this.taskInfo.hash2);
                }
                if (String.isNotBlank(this.taskInfo.hash3)) {
                    labelsWithHashesList.add('h3_' + this.taskInfo.hash3);
                }
                this.taskInfo.labels = String.join(labelsWithHashesList, ',');
            }
            if(String.isNotBlank(this.taskInfo.labels)) {
                List<String> labelsList = this.taskInfo.labels.split(',');
                for (Integer i=0; i < labelsList.size(); i++) {
                    labelsList[i] = labelsList[i].trim();
                }
                ((Map<String, Object>)(this.bodyRequest.get('fields'))).put('labels', labelsList);
            }
        }

        private void populateEpic(List<JiraService.JiraProjectIssueField> allProjectFields) {
            if(String.isNotBlank(this.taskInfo.epicId)) {
                JiraService.JiraProjectIssueField epicLinkField;
                JiraService.JiraProjectIssueField parentLinkField;

                if(!allProjectFields.isEmpty()) {
                    for (JiraService.JiraProjectIssueField field : allProjectFields) {
                        if (field.name == 'Epic Link' && (field.fieldId != null || field.key != null)) {
                            epicLinkField = field;
                        }
                        if (field.name == 'Parent' && field.key == 'parent') {
                            parentLinkField = field;
                        }
                    }
                    if(epicLinkField != null) {
                        ((Map<String, Object>)(this.bodyRequest.get('fields'))).put(
                            (epicLinkField.key != null ? epicLinkField.key : epicLinkField.fieldId), this.taskInfo.epicId
                        );
                    }
                    else if (parentLinkField != null) {
                        Map<String, Object> parentObject = new Map<String, Object>{'key' => this.taskInfo.epicId};
                        ((Map<String, Object>)(this.bodyRequest.get('fields'))).put(parentLinkField.key, parentObject);
                    }
                }
            }
        }

        private void populateComponents() {
            if(this.taskInfo.componentIds != null && this.taskInfo.componentIds.size() > 0) {
                List<Map<String, Object>> components = new List<Map<String, Object>>();
                for(String componentId : this.taskInfo.componentIds) {
                    components.add(new Map<String, Object>{'id' => componentId});
                }
                ((Map<String, Object>)(this.bodyRequest.get('fields'))).put('components', components);
            }
        }

        public override void createTicketRelations(TicketCreateResult result) {
            String issueKey = result.id;
            // Only create ticket relations if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null) {
                return;
            }

            if(this.sObjectWrapper.sObjectRecord.getSObjectType() == Issue__c.SObjectType
                && String.isNotBlank(this.sObjectWrapper.bugTracker)) {
                try {
                    String relatedRegressedTicketKey = JiraService.getIssueKeyByUrl(this.sObjectWrapper.bugTracker);
                    JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, relatedRegressedTicketKey);
                }
                catch(Exception e) {
                    // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
                    if (this.logger != null) {
                        Log__c errorLog = this.logger.getInternalError(e, (String)null, JiraService.class.getName(), 'linkIssuesAsRelates', this.shouldMarkForRecursionPrevention);
                        this.logger.add(errorLog);
                    }
                }
            }
            if(this.sObjectWrapper.sObjectRecord.getSObjectType() == Log__c.SObjectType) {
                try {
                    List<Log__c> relatedClosedLogsByHash1 = getRelatedOpenLogsByHash1(this.sobjectWrapper, this.settings.createUniqueTicketsByOrg);
                    if (!relatedClosedLogsByHash1.isEmpty()) {
                        String relatedClosedTicketKey = JiraService.getIssueKeyByUrl(relatedClosedLogsByHash1[0].Bug_Tracker__c);
                        JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, relatedClosedTicketKey);
                    }
                    List<Log__c> relatedOpenLogsByHash1 = getRelatedClosedLogsByHash1(this.sobjectWrapper, this.settings.createUniqueTicketsByOrg);
                    if (!relatedOpenLogsByHash1.isEmpty()) {
                        String relatedOpenTicketKey = JiraService.getIssueKeyByUrl(relatedOpenLogsByHash1[0].Bug_Tracker__c);
                        JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, relatedOpenTicketKey);
                    }
                }
                catch(Exception e) {
                    // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
                    if (this.logger != null) {
                        Log__c errorLog = this.logger.getInternalError(e, (String)null, JiraService.class.getName(), 'linkIssuesAsRelates', this.shouldMarkForRecursionPrevention);
                        this.logger.add(errorLog);
                    }
                }

                try {
                    /* Search for first Jira Issue linked by Hash1 */
                    List<Log__c> firstLogByHash1Available = getOtherLogsWithHash1AndNotEmptyBugTrackerLink(this.sobjectWrapper.id, this.sobjectWrapper.hash1, this.sobjectWrapper.organizationId, this.settings.createUniqueTicketsByOrg);

                    String firstLogByHash1BugTracker = this.sobjectWrapper.bugTracker;
                    if(!firstLogByHash1Available.isEmpty()) {
                        firstLogByHash1BugTracker = firstLogByHash1Available.get(0).Bug_Tracker__c;
                    }
                    if (firstLogByHash1BugTracker != null) {
                        String existingIssueKey = JiraService.getIssueKeyByUrl(firstLogByHash1BugTracker);
                        JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, existingIssueKey);
                    }

                    JiraService.JiraIssue existingIssueWithHash2 = JiraService.getService(this.logger).searchIssueByHash2(this.sobjectWrapper.hash2, this.taskInfo.projectId);
                    if (this.settings.autoRelateTicketsWithSimilarErrors &&
                        existingIssueWithHash2 != null &&
                        issueKey != existingIssueWithHash2.key
                    ){
                        JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, existingIssueWithHash2.key);
                    }

                    JiraService.JiraIssue existingIssueWithHash3 = JiraService.getService(this.logger).searchIssueByHash3(this.sobjectWrapper.hash3, this.taskInfo.projectId);
                    if (this.settings.autoRelateTicketsWithSimilarErrors &&
                        existingIssueWithHash3 != null &&
                        (existingIssueWithHash2 == null || existingIssueWithHash2.key != existingIssueWithHash3.key) &&
                        issueKey != existingIssueWithHash3.key
                    ){
                        JiraService.getService(this.logger).linkIssuesAsRelates(issueKey, existingIssueWithHash3.key);
                    }
                }
                catch(Exception e) {
                    // Mark with ORIGINATED_FROM_NOTIFICATION_ERROR only if parent is already a notification error (prevent recursion)
                    if (this.logger != null) {
                        Log__c errorLog = this.logger.getInternalError(e, (String)null, JiraService.class.getName(), 'linkExistingJiraTasks', this.shouldMarkForRecursionPrevention);
                        this.logger.add(errorLog);
                    }
                }
            }
        }

        public override void createNewTicketComment() {
            // Only create ticket comment if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null && String.isNotBlank(this.sobjectWrapper.bugTracker)) {
                // Safety: do not attempt Jira comment for non-Jira URLs (e.g., Azure DevOps work items).
                if (!JiraSyncBatch.isJiraTaskUrl(this.sobjectWrapper.bugTracker)) {
                    return;
                }
                String issueKey = JiraService.getIssueKeyByUrl(this.sobjectWrapper.bugTracker);
                JiraService.JiraServiceInterface jiraServiceInterface = JiraService.getService();

                List<String> chartsTypeForPrepare = this.taskInfo?.chartsTypeForPrepare;

                String comments = this.taskInfo.details;
                if (chartsTypeForPrepare?.size() > 0) {
                    if (this.sobjectWrapper.sObjectRecord != null) {
                        Map<String, Object> parameters = ReportService.parametersBySObjectRecord(this.sobjectWrapper.sObjectRecord);

                        Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = ReportService.getReportDataByChart(
                            chartsTypeForPrepare,
                            parameters
                        );

                        // Skip chart generation if no chart data available (prevents Lambda 400 errors and recursive logs)
                        chartToChartData = TicketingService.filterChartDataWithContent(chartToChartData);
                        if (chartToChartData.isEmpty()) {
                            jiraServiceInterface.createNewTicketComment(comments, issueKey);
                            return;
                        }

                        // Set metadata for error tracking
                        Map<String, String> metadata = new Map<String, String>();
                        if (this.sobjectWrapper.sObjectRecord != null && String.isNotBlank(this.sobjectWrapper.sObjectRecord.Id)) {
                            metadata.put('recordId', this.sobjectWrapper.sObjectRecord.Id);
                        }
                        // Add Jira issue key to metadata if available
                        if (String.isNotBlank(issueKey)) {
                            metadata.put('issueId', issueKey);
                        }

                        ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient;
                        try {
                            chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                                .setMetadata(metadata)
                                .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                        } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
                            // Fallback: post comment without charts; do not throw to avoid recursive Pharos error logs
                            jiraServiceInterface.createNewTicketComment(comments, issueKey);
                            return;
                        }

                        String comment = jiraServiceInterface.addCommentToIssueWithAttachments(comments, issueKey, chartGeneratorImageLambdaClient);

                        if (JiraService.isCloudJiraInstance()) {
                            if (isJsonString(comment)) {
                                Map<String, Object> parsedComment = (Map<String, Object>)JSON.deserializeUntyped(comment);
                                if (parsedComment.containsKey(ADFBuilder.ATTR_BODY)) {
                                    this.bodyRequest = parsedComment;
                                } else {
                                    // Check if it's already an ADF document (has 'type'='doc' and 'version')
                                    if (parsedComment.containsKey(ADFBuilder.ATTR_TYPE) && parsedComment.get(ADFBuilder.ATTR_TYPE) == ADFBuilder.TYPE_DOC && parsedComment.containsKey(ADFBuilder.ATTR_VERSION)) {
                                        // It's already an ADF document, wrap it in body
                                        this.bodyRequest = new Map<String, Object>{
                                            ADFBuilder.ATTR_BODY => parsedComment
                                        };
                                    } else {
                                        // It's JSON but not ADF format, treat as plain text and convert to ADF
                                        Map<String, Object> adfContent = (Map<String, Object>) TicketingService.textToAtlassianDocumentFormatContent(comment, true);
                                        this.bodyRequest = new Map<String, Object>{
                                            ADFBuilder.ATTR_BODY => adfContent
                                        };
                                    }
                                }
                            } else {
                                // comment is plain text, convert to ADF format
                                Map<String, Object> adfContent = (Map<String, Object>) TicketingService.textToAtlassianDocumentFormatContent(comment, true);
                                this.bodyRequest = new Map<String, Object>{
                                    ADFBuilder.ATTR_BODY => adfContent
                                };
                            }
                            String finalComment = JSON.serialize(this.bodyRequest);
                            jiraServiceInterface.createNewTicketComment(finalComment, issueKey);

                        } else {
                            this.bodyRequest = new Map<String, Object>{
                                ADFBuilder.ATTR_BODY => comment
                            };
                            jiraServiceInterface.createNewTicketComment(JSON.serialize(this.bodyRequest), issueKey);
                        }
                    }
                } else {
                    if (JiraService.isCloudJiraInstance()) {
                        // For Jira Cloud, convert plain text to ADF format
                        Map<String, Object> adfContent = (Map<String, Object>) TicketingService.textToAtlassianDocumentFormatContent(comments, true);
                        this.bodyRequest = new Map<String, Object>{
                            ADFBuilder.ATTR_BODY => adfContent
                        };
                    } else {
                        // For Jira Server, use plain text
                        this.bodyRequest = new Map<String, Object>{
                            ADFBuilder.ATTR_BODY => comments
                        };
                    }
                    jiraServiceInterface.createNewTicketComment(JSON.serialize(this.bodyRequest), issueKey);
                }
            }
        }

        public override TicketCreateResult createNewTicket() {
            TicketCreateResult result = new TicketCreateResult();
            JiraService.JiraProject jiraProject = JiraService.getService(this.logger).getProject(this.taskInfo.projectId);
            List<JiraService.JiraProjectIssueField> allProjectFields = JiraService.getService(this.logger).getProjectIssueFields(this.taskInfo.projectId, this.taskInfo.issueTypeId);
            Map<String, JiraService.JiraProjectIssueField> customFields = JiraService.getService(this.logger).getProjectIssueCustomFields(allProjectFields);

            populateDefaultFields();
            populateCustomFields(customFields);
            populatePriority(allProjectFields);
            populateUser();
            populateLabels();
            populateEpic(allProjectFields);
            populateComponents();

            String b = HttpUtils.post(
                JiraService.getService().getCreateIssueEndpoint(),
                JSON.serialize(this.bodyRequest),
                JiraService.JIRA_HEADERS,
                201
            );
            JiraService.NewTaskCreatedResponse newTaskCreatedResponse = (JiraService.NewTaskCreatedResponse)JSON.deserialize(b, JiraService.NewTaskCreatedResponse.class);
            String issueKey = newTaskCreatedResponse.key;
            
            // Handle chart attachments for new tickets
            List<String> chartsTypeForPrepare = this.taskInfo?.chartsTypeForPrepare;
            if (chartsTypeForPrepare != null && chartsTypeForPrepare.size() > 0) {
                if (this.sobjectWrapper != null && this.sobjectWrapper.sObjectRecord != null) {
                    Map<String, Object> parameters = ReportService.parametersBySObjectRecord(this.sobjectWrapper.sObjectRecord);

                    Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = ReportService.getReportDataByChart(
                        chartsTypeForPrepare,
                        parameters
                    );

                    // Skip chart generation if no chart data available (prevents Lambda 400 errors and recursive logs)
                    chartToChartData = TicketingService.filterChartDataWithContent(chartToChartData);
                    if (chartToChartData.isEmpty()) {
                        // No chart data, skip chart attachment but still return the created ticket
                        return new TicketCreateResult(issueKey, ConfigUtil.JIRA_TASK_URL + issueKey);
                    }

                    // Set metadata for error tracking
                    Map<String, String> metadata = new Map<String, String>();
                    if (this.sobjectWrapper.sObjectRecord != null && String.isNotBlank(this.sobjectWrapper.sObjectRecord.Id)) {
                        metadata.put('recordId', this.sobjectWrapper.sObjectRecord.Id);
                    }
                    if (String.isNotBlank(issueKey)) {
                        metadata.put('issueId', issueKey);
                    }

                    ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient;
                    try {
                        chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                            .setMetadata(metadata)
                            .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                    } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
                        // Fallback: skip chart attachments; do not throw to avoid recursive Pharos error logs
                        return new TicketCreateResult(issueKey, ConfigUtil.JIRA_TASK_URL + issueKey);
                    }

                    // Attach charts and update description
                    updateIssueDescriptionWithCharts(issueKey, this.taskInfo.details, chartGeneratorImageLambdaClient);
                }
            }
            
            return new TicketCreateResult(issueKey, ConfigUtil.JIRA_TASK_URL + issueKey);
        }
        
        private void updateIssueDescriptionWithCharts(String issueKey, String originalDescription, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {
            try {
                JiraService.JiraServiceInterface jiraServiceInterface = JiraService.getService(this.logger);
                
                if (JiraService.isCloudJiraInstance()) {
                    // For Jira Cloud, use ADF format with media nodes
                    List<JiraService.AttachmentResult> attachmentResults = new List<JiraService.AttachmentResult>();
                    
                    if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {
                        for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                            if (chart != null && String.isNotBlank(chart)) {
                                ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);
                                
                                if (chartEnum != null) {
                                    Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                                    if (chartBlob != null) {
                                        String fileName = HttpUtils.getNameAttachment(chartEnum.name() + Constants.GLOBAL_VARIABLE.FILE_EXTENSION_PNG);
                                        JiraService.AttachmentResult result = jiraServiceInterface.addAttachmentWithMediaId(chartBlob, fileName, issueKey);
                                        attachmentResults.add(result);
                                    }
                                }
                            }
                        }
                    }
                    
                    // Create ADF format description with chart attachments
                    Map<String, Object> adfContent = (Map<String, Object>) TicketingService.textToAtlassianDocumentFormatContent(originalDescription, true);
                    List<Object> content = (List<Object>) adfContent.get(ADFBuilder.ATTR_CONTENT);
                    
                    if (content == null) {
                        content = new List<Object>();
                        adfContent.put(ADFBuilder.ATTR_CONTENT, content);
                    }
                    
                    // Add media nodes for each chart attachment
                    if (attachmentResults != null && !attachmentResults.isEmpty()) {
                        for (JiraService.AttachmentResult attachment : attachmentResults) {
                            if (String.isNotBlank(attachment.mediaServicesId)) {
                                Map<String, Object> mediaSingle = new Map<String, Object>{
                                    ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_MEDIA_SINGLE,
                                    ADFBuilder.ATTR_ATTRS => new Map<String, Object>{
                                        'layout' => 'center'
                                    },
                                    ADFBuilder.ATTR_CONTENT => new List<Object>{
                                        new Map<String, Object>{
                                            ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_MEDIA,
                                            ADFBuilder.ATTR_ATTRS => new Map<String, Object>{
                                                ADFBuilder.ATTR_ID => attachment.mediaServicesId,
                                                ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_FILE,
                                                ADFBuilder.ATTR_COLLECTION => '',
                                                'width' => 800,
                                                'height' => 400,
                                                ADFBuilder.ATTR_ALT => attachment.fileName != null ? attachment.fileName : 'Chart image'
                                            }
                                        }
                                    }
                                };
                                content.add(mediaSingle);
                            }
                        }
                    }
                    
                    // Update the issue description
                    Map<String, Object> updateBody = new Map<String, Object>{
                        ADFBuilder.ATTR_FIELDS => new Map<String, Object>{
                            ADFBuilder.ATTR_DESCRIPTION => adfContent
                        }
                    };
                    
                    HttpUtils.put(
                        jiraServiceInterface.getIssueEndpoint(issueKey),
                        JSON.serialize(updateBody),
                        JiraService.JIRA_HEADERS,
                        204
                    );
                } else {
                    // For Jira Server, use the old format
                    String descriptionWithCharts = originalDescription;
                    
                    if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {
                        for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                            if (chart != null && String.isNotBlank(chart)) {
                                ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);
                                
                                if (chartEnum != null) {
                                    Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                                    if (chartBlob != null) {
                                        String fileName = HttpUtils.getNameAttachment(chartEnum.name() + Constants.GLOBAL_VARIABLE.FILE_EXTENSION_PNG);
                                        jiraServiceInterface.addAttachment(chartBlob, fileName, issueKey);
                                        descriptionWithCharts += '\n!' + fileName + '!';
                                    }
                                }
                            }
                        }
                    }
                    
                    // Update the issue description
                    Map<String, Object> updateBody = new Map<String, Object>{
                        ADFBuilder.ATTR_FIELDS => new Map<String, Object>{
                            ADFBuilder.ATTR_DESCRIPTION => descriptionWithCharts
                        }
                    };
                    
                    HttpUtils.put(
                        jiraServiceInterface.getIssueEndpoint(issueKey),
                        JSON.serialize(updateBody),
                        JiraService.JIRA_HEADERS,
                        204
                    );
                }
            } catch (Exception e) {
                if (this.logger != null) {
                    Log__c errorLog = this.logger.getInternalError(e, (String)null, TicketingService.class.getName(), 'updateIssueDescriptionWithCharts', this.shouldMarkForRecursionPrevention);
                    this.logger.add(errorLog);
                }
            }
        }

    }

    public class TicketingServiceAzureDevOpsImpl extends TicketingServiceDefaultImpl {

        private List<AzureService.AzureDevOpsWorkItemRequestBody> workItemRequest;

        public override String getCompletedTicketStatus() {
            return 'Done';
        }

        public override void init(TicketingServiceInputData data, Logger logger, Boolean shouldMarkForRecursionPrevention) {
            super.init(data, logger, shouldMarkForRecursionPrevention);
            this.settings = new TicketingServiceSettings(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS);
        }

        public override Boolean isPermissionDisabled() {
            return !PermissionsUtil.AzureDevOpsIntegrationEnabled;
        }

        public override TicketStatusInfo getTicketStatus() {
            TicketStatusInfo result;
            // Only get ticket status if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null && this.sObjectWrapper.sObjectRecord.getSobjectType() == Log__c.SObjectType) {
                if(String.isBlank(this.sObjectWrapper.bugTracker)) {
                    this.sObjectWrapper.bugTracker = getBugTrackerLinkFromLogIndex();
                }
            }
            if (this.sObjectWrapper != null && String.isNotBlank(this.sObjectWrapper.bugTracker)) {
                AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(sObjectWrapper.bugTracker);
                if(String.isNotBlank(urlWorkItem.organizationName)
                    && String.isNotBlank(urlWorkItem.projectIdOrName)
                    && String.isNotBlank(urlWorkItem.workItemId)) {

                    AzureService.AzureDevOpsWorkItem existWorkItem = AzureService.getProjectWorkItem(urlWorkItem.organizationName, urlWorkItem.projectIdOrName, urlWorkItem.workItemId);

                    //return existWorkItem?.fields?.State;
                    DateTime resolutionDateTime = AzureService.parseAzureDevOpsDateTime(existWorkItem?.fields?.ClosedDate, null);
                    return new TicketStatusInfo(existWorkItem?.fields?.State, resolutionDateTime);
                }
            }
            return result;
        }

        public override TicketCreateResult getExistingTickets() {
            // Only get existing tickets if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null || String.isBlank(this.sObjectWrapper.bugTracker)) {
                return null;
            }
            AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(sObjectWrapper.bugTracker);
            return new TicketCreateResult(urlWorkItem.workItemId, this.sObjectWrapper.bugTracker);
        }

        /**
         * Azure DevOps ticketing must not reuse Jira URLs stored in LogIndex.
         * Only treat a LogIndex bugTracker as "existing" when it is a valid Azure DevOps work item URL.
         */
        public override String getBugTrackerLinkFromLogIndex() {
            String candidate = super.getBugTrackerLinkFromLogIndex();
            if (String.isBlank(candidate)) {
                return null;
            }
            AzureService.WorkItemUrlParser parsed = new AzureService.WorkItemUrlParser(candidate);
            if (String.isBlank(parsed?.organizationName) || String.isBlank(parsed?.projectIdOrName) || String.isBlank(parsed?.workItemId)) {
                return null;
            }
            return candidate;
        }

        private List<String> getRelatedWorkItemIds() {
            Set<String> result = new Set<String>();

            // Only get related work item IDs if we have a wrapper (not for event actions)
            if (this.sObjectWrapper == null) {
                return new List<String>();
            }

            if(this.sObjectWrapper.sObjectRecord.getSObjectType() == Issue__c.SObjectType) {
                if(String.isNotBlank(this.sObjectWrapper?.bugTracker)) {
                    AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(this.sObjectWrapper.bugTracker);
                    if(String.isNotBlank(urlWorkItem?.workItemId)) {
                        result.add(urlWorkItem.workItemId);
                    }
                }
            }

            if(this.sObjectWrapper.sObjectRecord.getSObjectType() == Log__c.SObjectType) {
                Log__c log = (Log__c)this.sObjectWrapper.sObjectRecord;
                List<Log__c> relatedOpenLogsByHash1 = getRelatedOpenLogsByHash1(this.sobjectWrapper, this.settings.createUniqueTicketsByOrg);
                List<Log__c> relatedClosedLogsByHash1 = getRelatedClosedLogsByHash1(this.sobjectWrapper, this.settings.createUniqueTicketsByOrg);

                if (!relatedClosedLogsByHash1.isEmpty()) {
                    AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(relatedClosedLogsByHash1[0].Bug_Tracker__c);
                    if(urlWorkItem != null && String.isNotBlank(urlWorkItem.workItemId)) {
                        result.add(urlWorkItem.workItemId);
                    }
                }
                if (!relatedOpenLogsByHash1.isEmpty()) {
                    AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(relatedOpenLogsByHash1[0].Bug_Tracker__c);
                    if(urlWorkItem != null && String.isNotBlank(urlWorkItem.workItemId)) {
                        result.add(urlWorkItem.workItemId);
                    }
                }
                if(this.settings.autoRelateTicketsWithSimilarErrors) {
                    /* Search for first Jira Issue linked by Hash1 */
                    List<Log__c> firstLogByHash1Available = getOtherLogsWithHash1AndNotEmptyBugTrackerLink(this.sobjectWrapper.id, this.sobjectWrapper.hash1, this.sobjectWrapper.organizationId, this.settings.createUniqueTicketsByOrg);
                    
                    Log__c firstLogByHash1 = firstLogByHash1Available.size() > 0 ? firstLogByHash1Available[0] : log;
                    if(firstLogByHash1.Bug_Tracker__c != null) {
                        AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(firstLogByHash1.Bug_Tracker__c);
                        if(urlWorkItem != null && String.isNotBlank(urlWorkItem.workItemId)) {
                            result.add(urlWorkItem.workItemId);
                        }
                    }
        
                    String hash2Query = AzureService.getWIQLRequestSelectWorkItemsByTags(new List<String>{log.Hash_2__c});
                    AzureService.AzureDevOpsWorkItemQueryResult qrHash2 = AzureService.queryByWIQL(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, hash2Query);
                    if(qrHash2 != null && !qrHash2?.workItems?.isEmpty()) {
                        result.add(qrHash2.workItems.get(0).id);
                    }
        
                    String hash3Query = AzureService.getWIQLRequestSelectWorkItemsByTags(new List<String>{log.Hash_3__c});
                    AzureService.AzureDevOpsWorkItemQueryResult qrHash3 = AzureService.queryByWIQL(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, hash3Query);
                    if(qrHash3 != null && !qrHash3?.workItems?.isEmpty()) {
                        result.add(qrHash3.workItems.get(0).id);
                    }
                }
            }
            return (!result.isEmpty()) ? new List<String>(result) : new List<String>();
        }

        private void populateDefaultFields() {
            // For event actions, we don't have an sObjectWrapper, so we can't populate these fields
            if (this.sObjectWrapper != null) {
                this.taskInfo.recordId = this.sObjectWrapper.id;
                this.taskInfo.hash2 = this.sObjectWrapper.hash2;
                this.taskInfo.hash3 = this.sObjectWrapper.hash3;
            }
            this.workItemRequest = new List<AzureService.AzureDevOpsWorkItemRequestBody>();

            this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_TITLE, this.taskInfo.summary)
            );
            this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_DESCRIPTION, this.taskInfo.details)
            );
        }

        private void populatePriority() {
            if(String.isNotBlank(this.taskInfo.priority)) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_PRIORITY, Integer.valueOf(this.taskInfo.priority))
                );
            }
        }

        private void populateUser() {
            if(String.isNotBlank(this.taskInfo.assignee)) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_ASSIGNED_TO, this.taskInfo.assignee)
                );
            }
        }

        private void populateTags() {
            List<String> tags = new List<String>();
            if(String.isNotBlank(this.taskInfo.labels)) {
                tags.addAll(this.taskInfo.labels.split(','));
            }

            if(this.settings.autoGenerateSimilarityLabels) {
                if (String.isNotBlank(this.taskInfo.hash2)) {
                    tags.add('h2_' + this.taskInfo.hash2);
                }
                if (String.isNotBlank(this.taskInfo.hash3)) {
                    tags.add('h3_' + this.taskInfo.hash3);
                }
            }
            if(tags != null && !tags.isEmpty()) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS +  AzureService.WORK_ITEM_TYPE_FIELD_TAG, String.join(tags, ';')
                ));
            }
        }

        private void populateEpic() {
            String epicWorkItemId = normalizeWorkItemId(this.taskInfo.epicId);
            if(String.isNotBlank(epicWorkItemId)) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_RELATIONS, new Map<String, Object>{
                        'rel' => AzureService.WORK_ITEM_TYPE_FIELD_RELATED_PARENT_LINK,
                        // Azure DevOps relations expect the REST API work item URL (not the UI "/_workitems/edit/" URL).
                        'url' => String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{
                            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c,
                            this.taskInfo.projectId,
                            epicWorkItemId
                        })
                    })
                );
            }
        }

        private void populateArea() {
            if(String.isNotBlank(this.taskInfo.area)) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_AREA, this.taskInfo.area)
                );
            }
        }

        private void populateIteration() {
            if(String.isNotBlank(this.taskInfo.iteration)) {
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_ITERATION, this.taskInfo.iteration)
                );
            }
        }

        private void populateRelatedWorkItems(List<String> relatedWorkItems) {
            for(String relatedWorkItemId : relatedWorkItems) {
                String normalizedRelatedWorkItemId = normalizeWorkItemId(relatedWorkItemId);
                if (String.isBlank(normalizedRelatedWorkItemId)) {
                    continue;
                }
                this.workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                    AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_RELATIONS, new Map<String, Object>{
                        'rel' => AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK,
                        // Azure DevOps relations expect the REST API work item URL (not the UI "/_workitems/edit/" URL).
                        'url' => String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{
                            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c,
                            this.taskInfo.projectId,
                            normalizedRelatedWorkItemId
                        })
                    })
                );
            }
        }

        /**
         * Normalize an Azure DevOps work item identifier that can be stored as:
         * - a numeric ID ("1105")
         * - a UI URL ("https://dev.azure.com/{org}/{project}/_workitems/edit/1105")
         * - a REST URL ("https://dev.azure.com/{org}/{project}/_apis/wit/workItems/1105?...").
         *
         * Azure DevOps relations require a full URL; this helper ensures we only build relation URLs
         * from a valid numeric work item ID. If input can't be normalized, returns null.
         */
        private String normalizeWorkItemId(String workItemIdOrUrl) {
            if (String.isBlank(workItemIdOrUrl)) {
                return null;
            }
            String candidate = workItemIdOrUrl.trim();
            if (candidate.contains('/')) {
                AzureService.WorkItemUrlParser parsed = new AzureService.WorkItemUrlParser(candidate);
                candidate = parsed?.workItemId;
            }
            try {
                // Validate it is numeric (work item id must be a number).
                Integer.valueOf(candidate);
                return candidate;
            } catch (Exception e) {
                return null;
            }
        }

        public override void createNewTicketComment() {

            // Only create ticket comment if we have a wrapper (not for event actions)
            if (this.sObjectWrapper != null && String.isNotBlank(this.sobjectWrapper.bugTracker)) {
                // Safety: do not attempt Azure DevOps comment for non-Azure URLs (e.g., Jira "/browse/").
                if (!JiraSyncBatch.isAzureDevOpsTaskUrl(this.sobjectWrapper.bugTracker)) {
                    return;
                }
                AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(this.sobjectWrapper.bugTracker);
                String workItemId = urlWorkItem.workItemId;
                String projectId = urlWorkItem.projectIdOrName;
                String organizationId = urlWorkItem.organizationName;

                if (String.isBlank(organizationId) || String.isBlank(projectId) || String.isBlank(workItemId)) {
                    throw new AzureService.AzureServiceException(
                        ERROR_INVALID_AZURE_DEVOPS_WORK_ITEM_URL + 'Actual: ' + this.sobjectWrapper.bugTracker
                    );
                }

                AzureApiClient client = new AzureApiClient()
                    .setOrganization(organizationId)
                    .setProject(projectId)
                    .setWorkItem(workItemId);


                if(String.isNotBlank(this.sobjectWrapper.bugTracker)) {

                    List<String> chartsTypeForPrepare = this.taskInfo?.chartsTypeForPrepare;

                    String comments = this.taskInfo.details;


                    if (chartsTypeForPrepare?.size() > 0) {
                        if (this.sobjectWrapper.sObjectRecord != null) {
                            Map<String, Object> parameters = ReportService.parametersBySObjectRecord(this.sobjectWrapper.sObjectRecord);

                            Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = ReportService.getReportDataByChart(
                                chartsTypeForPrepare,
                                parameters
                            );

                            // Skip chart generation if no chart data available (prevents Lambda 400 errors and recursive logs)
                            chartToChartData = TicketingService.filterChartDataWithContent(chartToChartData);
                            if (chartToChartData.isEmpty()) {
                                client.addComment(comments);
                                return;
                            }

                            ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient;
                            try {
                                chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                                    .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                            } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
                                // Fallback: comment without charts; do not throw to avoid recursive Pharos error logs
                                client.addComment(comments);
                                return;
                            }

                            client.addCommentWithAttachments(comments, chartGeneratorImageLambdaClient);
                        }
                    } else {
                        client.addComment(comments);
                    }
                }
            }
        }

        public override TicketCreateResult createNewTicket() {
            TicketCreateResult result = new TicketCreateResult();

            List<String> relatedWorkItems = getRelatedWorkItemIds();
            populateDefaultFields();
            populatePriority();
            populateUser();
            populateTags();
            populateEpic();
            populateArea();
            populateIteration();
            populateRelatedWorkItems(relatedWorkItems);

            // For custom types: full referenceName (e.g., "Test23.Test2WorkItem")
            // For inherited/system types: simple name (e.g., "Issue")
            // We just need to URL encode it here
            String workItemTypeName = EncodingUtil.urlEncode(this.taskInfo.issueTypeId, 'UTF-8').replace('+', '%20');
            String endpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM, new List<String>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, workItemTypeName});
            Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AzureService.AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + AzureService.OAUTH_API_TOKEN);
            headers.putAll(HttpUtils.getHeadersContentTypeJSONPatch());
            String b;

            try {
                b = HttpUtils.post(
                    endpoint,
                    JSON.serialize(this.workItemRequest),
                    headers,
                    200
                );
            }
            catch(HttpUtils.HttpUtilsException e) {
                // catch tag's create error, remove tags, and send again
                if(e.getMessage().contains(AZURE_DEV_OPS_ERROR_CREATE_TAGS)) {
                    for(Integer i = 0; i < this.workItemRequest?.size(); i++){
                        AzureService.AzureDevOpsWorkItemRequestBody item = this.workItemRequest.get(i);
                        if(item?.op == AzureService.WORK_ITEM_TYPE_OPERATION_ADD
                            && item?.path == AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_TAG) {
                            this.workItemRequest.remove(i);
                        }
                    }
                    b = HttpUtils.post(
                        endpoint,
                        JSON.serialize(this.workItemRequest),
                        headers,
                        200
                    );
                }
                else throw e;
            }
            AzureService.AzureDevOpsWorkItem newWorkItem = (AzureService.AzureDevOpsWorkItem)JSON.deserialize(AzureService.replaceSystemField(b), AzureService.AzureDevOpsWorkItem.class);
            String workItemId = newWorkItem.id;
            
            // Handle chart attachments for new work items
            List<String> chartsTypeForPrepare = this.taskInfo?.chartsTypeForPrepare;
            if (chartsTypeForPrepare != null && chartsTypeForPrepare.size() > 0) {
                if (this.sobjectWrapper != null && this.sobjectWrapper.sObjectRecord != null) {
                    Map<String, Object> parameters = ReportService.parametersBySObjectRecord(this.sobjectWrapper.sObjectRecord);

                    Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartToChartData = ReportService.getReportDataByChart(
                        chartsTypeForPrepare,
                        parameters
                    );

                    // Skip chart generation if no chart data available (prevents Lambda 400 errors and recursive logs)
                    chartToChartData = TicketingService.filterChartDataWithContent(chartToChartData);
                    if (chartToChartData.isEmpty()) {
                        // No chart data, skip chart attachment but still create the work item
                        return new TicketCreateResult(workItemId, String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, workItemId}));
                    }

                    // Set metadata for error tracking
                    Map<String, String> metadata = new Map<String, String>();
                    if (this.sobjectWrapper.sObjectRecord != null && String.isNotBlank(this.sobjectWrapper.sObjectRecord.Id)) {
                        metadata.put('recordId', this.sobjectWrapper.sObjectRecord.Id);
                    }
                    if (String.isNotBlank(workItemId)) {
                        metadata.put('workItemId', workItemId);
                    }

                    ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient;
                    try {
                        chartGeneratorImageLambdaClient = new ChartGeneratorImageLambdaClient()
                            .setMetadata(metadata)
                            .generateChartImagesBasedStringChartConfig(JSON.serialize(chartToChartData));
                    } catch (ChartGeneratorImageLambdaClient.ChartGeneratorException e) {
                        // Fallback: skip chart attachments; do not throw to avoid recursive Pharos error logs
                        return new TicketCreateResult(workItemId, String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, workItemId}));
                    }

                    // Attach charts and update description
                    updateWorkItemDescriptionWithCharts(workItemId, this.taskInfo.details, chartGeneratorImageLambdaClient);
                }
            }

            return new TicketCreateResult(workItemId, String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, this.taskInfo.projectId, workItemId}));
        }
        
        private void updateWorkItemDescriptionWithCharts(String workItemId, String originalDescription, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {
            try {
                String organizationId = ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c;
                String projectId = this.taskInfo.projectId;
                
                String descriptionWithCharts = originalDescription;
                
                if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {
                    AzureApiClient client = new AzureApiClient()
                        .setOrganization(organizationId)
                        .setProject(projectId)
                        .setWorkItem(workItemId);
                    
                    for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                        if (chart != null && String.isNotBlank(chart)) {
                            ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);
                            
                            if (chartEnum != null) {
                                Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                                if (chartBlob != null) {
                                    String fileName = HttpUtils.getNameAttachment(chartEnum.name() + Constants.GLOBAL_VARIABLE.FILE_EXTENSION_PNG);
                                    String imageUrl = client.addAttachment(chartBlob, fileName);
                                    if (String.isNotBlank(imageUrl)) {
                                        descriptionWithCharts += String.format(
                                            Constants.GLOBAL_VARIABLE.HTML_IMG_TAG_WITH_QUERY_TEMPLATE,
                                            new List<String>{ imageUrl, Constants.GLOBAL_VARIABLE.IMAGE_QUERY_TINYSRGB, fileName }
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Update the work item description
                if (descriptionWithCharts != originalDescription) {
                    List<AzureService.AzureDevOpsWorkItemRequestBody> updateRequest = new List<AzureService.AzureDevOpsWorkItemRequestBody>();
                    updateRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
                        AzureService.WORK_ITEM_TYPE_OPERATION_REPLACE,
                        AzureService.WOKR_ITEM_REQUEST_PATH_FIELDS + AzureService.WORK_ITEM_TYPE_FIELD_DESCRIPTION,
                        descriptionWithCharts
                    ));
                    
                    AzureService.updateProjectWorkItem(organizationId, projectId, workItemId, updateRequest);
                }
            } catch (Exception e) {
                if (this.logger != null) {
                    Log__c errorLog = this.logger.getInternalError(e, (String)null, TicketingService.class.getName(), 'updateWorkItemDescriptionWithCharts', this.shouldMarkForRecursionPrevention);
                    this.logger.add(errorLog);
                }
            }
        }

        public override void createTicketRelations(TicketCreateResult result) {}

    }

    private static final Map<Schema.SObjectType, Set<String>> MAP_SOBJECT_FIELDS = new Map<Schema.SObjectType, Set<String>> {
        Log__c.SObjectType => new Set<String>{
            'Id',
            'Summary__c',
            'Details__c',
            'Bug_Tracker__c',
            'Hash_1__c',
            'Hash_2__c',
            'Hash_3__c',
            'Jira_Integration_Status__c',
            'Organization_Id__c',
            'Resolved_On__c'
        },
        Issue__c.SObjectType => new Set<String>{
            'Id',
            'Name',
            'Summary__c',
            'Description__c',
            'Bug_Tracker__c',
            'Key__c',
            'Jira_Integration_Status__c',
            'Resolved_On__c'
        }
    };

    /**
     * Parses additionalMetadata supporting both old and new formats
     * Returns Map<String, String> with field values for merge field processing
     */
    private static Map<String, String> parseAdditionalMetadataForMergeFields(String additionalMetadataJSON) {
        Map<String, String> result = new Map<String, String>();
        
        if (String.isBlank(additionalMetadataJSON)) {
            return result;
        }
        
        try {
            // Try new format first: {"fieldKey": {"value": "...", "schema": {...}}}
            Map<String, Object> parsedData = (Map<String, Object>)JSON.deserializeUntyped(additionalMetadataJSON);
            
            for (String fieldKey : parsedData.keySet()) {
                Object fieldData = parsedData.get(fieldKey);
                
                // Check if it's new format (object with value property)
                if (fieldData instanceof Map<String, Object>) {
                    Map<String, Object> fieldMap = (Map<String, Object>)fieldData;
                    if (fieldMap.containsKey('value')) {
                        // New format - extract value
                        String fieldValue = (String)fieldMap.get('value');
                        result.put(fieldKey, fieldValue != null ? fieldValue : '');
                        continue;
                    }
                }
                
                // Old format - use value directly
                result.put(fieldKey, String.valueOf(fieldData));
            }
        } catch (Exception e) {
            // If parsing fails completely, try old format
            try {
                Map<String, String> oldFormat = (Map<String, String>)JSON.deserialize(additionalMetadataJSON, Map<String, String>.class);
                result.putAll(oldFormat);
            } catch (Exception e2) {
                // If both parsing attempts fail, return empty map
            }
        }
        
        return result;
    }

    public with sharing class TicketingSObjectWrapper {
        public String id;
        public String hash1;
        public String hash2;
        public String hash3;
        public String bugTracker;
        public String summary;
        public String details;
        public String organizationId;

        public SObject sObjectRecord;

        public String sObjectTypeName;
        public Schema.SObjectType sObjectType;
        public Schema.DescribeSObjectResult describeSObjectResult;

        public Schema.DescribeFieldResult dfrHash1;
        public Schema.DescribeFieldResult dfrBugTracker;
        public Schema.DescribeFieldResult dfrJiraIntegrationStatus;
        public Schema.DescribeFieldResult dfrOrganizationId;
        public Schema.DescribeFieldResult dfrResolvedOn;

        public TicketingSObjectWrapper(Id recordId) {
            this(Database.query(new QBuilder(recordId.getSobjectType())
            .selectFields(MAP_SOBJECT_FIELDS.get(recordId.getSobjectType()))
            .add(QBuilder.condition('Id').equalsTo(recordId))
            .build()).get(0));
        }

        public TicketingSObjectWrapper(SObject sObjectRecord) {
            this.id = sObjectRecord.Id;
            this.bugTracker = (String)sObjectRecord.get('Bug_Tracker__c');
            this.summary = (String)sObjectRecord.get('Summary__c');

            this.sObjectRecord = sObjectRecord;

            this.sObjectTypeName = sObjectRecord.getSObjectType().getDescribe().getName();
            this.sObjectType = ConfigUtil.MAP_GD.get(this.sObjectTypeName);
            this.describeSObjectResult = this.sObjectType.getDescribe();

            if (this.sObjectRecord.getSObjectType() == Log__c.SObjectType) {
                this.hash1 = (String)sObjectRecord.get('Hash_1__c');
                this.hash2 = (String)sObjectRecord.get('Hash_2__c');
                this.hash3 = (String)sObjectRecord.get('Hash_3__c');
                this.details = (String)sObjectRecord.get('Details__c');
                this.organizationId = (String)sObjectRecord.get('Organization_Id__c');

                this.dfrHash1 = Schema.SObjectType.Log__c.fields.Hash_1__c;
                this.dfrBugTracker = Schema.SObjectType.Log__c.fields.Bug_Tracker__c;
                this.dfrJiraIntegrationStatus = Schema.SObjectType.Log__c.fields.Jira_Integration_Status__c;
                this.dfrOrganizationId = Schema.SObjectType.Log__c.fields.Organization_Id__c;
                this.dfrResolvedOn = Schema.SObjectType.Log__c.fields.Resolved_On__c;
            }

            if (this.sObjectRecord.getSObjectType() == Issue__c.SObjectType) {
                this.hash1 = (String)sObjectRecord.get('Key__c');
                this.details = (String)sObjectRecord.get('Description__c');

                this.dfrHash1 = Schema.SObjectType.Issue__c.fields.Key__c;
                this.dfrBugTracker = Schema.SObjectType.Issue__c.fields.Bug_Tracker__c;
                this.dfrJiraIntegrationStatus = Schema.SObjectType.Issue__c.fields.Jira_Integration_Status__c;
                this.dfrResolvedOn = Schema.SObjectType.Issue__c.fields.Resolved_On__c;
            }
        }
    }

    public class TicketingTaskInfo {
        public String summary;
        public String details;
        public String labels;
        public String priority;
        public String assignee;
        public String epicId;
        public String projectId;
        public String issueTypeId;
        public String iteration;
        public String area;
        public String additionalMetadata;
        public List<String> componentIds;
        public Map<String, String> customFields;
        public List<String> chartsTypeForPrepare;

        public Id recordId;
        public String hash2;
        public String hash3;

        public TicketingTaskInfo() {}

        public TicketingTaskInfo(EventAction__c eventAction) {
            // Use ADF-aware merge field settings for JIRA actions
            List<String> renderMessages = NotificationService.renderMergeFields(
                eventAction.Event__c,
                new List<String>{eventAction.Action__r.Subject__c, eventAction.Action__r.Body__c},
                new NotificationService.MergeFieldSettings(eventAction.Action__r.Action_Type__c));

            AutoChart.AutoChartFieldsResult autoChartFieldsResult = AutoChart.getChartFieldsAndClear(renderMessages);
            renderMessages = autoChartFieldsResult.cleanedMessages;
            this.chartsTypeForPrepare = autoChartFieldsResult.autoChartFields;

            this.summary = renderMessages.get(0)?.abbreviate(255);
            this.details = renderMessages.get(1);
            this.labels = eventAction.Action__r.JIRALabels__c;
            this.priority = eventAction.Action__r.JIRAPriority__c;
            this.assignee = eventAction.Action__r.JIRAAssignee_Id__c;
            this.epicId = eventAction.Action__r.JIRAEpic__c;
            this.iteration = eventAction.Action__r.Iteration__c;
            this.area = eventAction.Action__r.JIRAComponents__c;
            this.projectId = eventAction.Action__r.JIRAProject__c;
            this.issueTypeId = eventAction.Action__r.JIRAIssueType__c;
            this.componentIds = String.isNotBlank(eventAction.Action__r.JIRAComponents__c) ? eventAction.Action__r.JIRAComponents__c.split(',') : new List<String>();
            if (String.isNotBlank(eventAction.Action__r.Additional_Metadata__c)) {
                NotificationService.MergeFieldSettings settings = new NotificationService.MergeFieldSettings(eventAction.Action__r.Action_Type__c, false);
                this.additionalMetadata = getAdditionalMetadata(eventAction.Action__c, eventAction.Event__c, eventAction.Action__r.Additional_Metadata__c, settings);
            }
        }

        public TicketingTaskInfo(Action__c jiraAction, TicketingSObjectWrapper sObjectWrapper) {
            // Use ADF-aware merge field settings for JIRA actions
            List<String> renderMessages = NotificationService.renderMergeFields(
                sObjectWrapper.id,
                new List<String>{jiraAction.Subject__c, jiraAction.Body__c},
                new NotificationService.MergeFieldSettings(jiraAction.Action_Type__c));

            AutoChart.AutoChartFieldsResult autoChartFieldsResult = AutoChart.getChartFieldsAndClear(renderMessages);
            renderMessages = autoChartFieldsResult.cleanedMessages;
            this.chartsTypeForPrepare = autoChartFieldsResult.autoChartFields;

            this.summary = (String.isBlank(jiraAction.Subject__c))
                ? sObjectWrapper.summary
                : renderMessages.get(0);
            if(jiraAction.Action_Type__c == Constants.ACTION_SOBJECT.ACTION_TYPE_JIRA_TICKET_COMMENT || jiraAction.Action_Type__c == Constants.ACTION_SOBJECT.ACTION_TYPE_AZURE_DEV_OPS_WORK_ITEM_COMMENT) {
                this.summary = '';
            }
            this.details = (String.isBlank(jiraAction.Body__c)
                ? Url.getOrgDomainUrl().toExternalForm() + '/' + sObjectWrapper.id + '\n\n' + sObjectWrapper.details
                : renderMessages.get(1));
            if(jiraAction.Action_Type__c == Constants.ACTION_SOBJECT.ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION) {
                this.details = this.details.replaceAll('\n', '</br>');
            }
            this.summary = this.summary.abbreviate(255);
            this.labels = jiraAction.JIRALabels__c;
            this.priority = jiraAction.JIRAPriority__c;
            this.assignee = jiraAction.JIRAAssignee_Id__c;
            this.epicId = jiraAction.JIRAEpic__c;
            this.iteration = jiraAction.Iteration__c;
            this.area = jiraAction.JIRAComponents__c;
            this.projectId = jiraAction.JIRAProject__c;
            this.issueTypeId = jiraAction.JIRAIssueType__c;
            this.componentIds = String.isNotBlank(jiraAction.JIRAComponents__c) ? jiraAction.JIRAComponents__c.split(',') : new List<String>();
            if (String.isNotBlank(jiraAction.Additional_Metadata__c)) {
                NotificationService.MergeFieldSettings settings = new NotificationService.MergeFieldSettings(jiraAction.Action_Type__c, false);
                this.additionalMetadata = getAdditionalMetadata(UserInfo.getUserId(), sObjectWrapper.id, jiraAction.Additional_Metadata__c, settings);
            }
        }

        public String getAdditionalMetadata(String whoId, String whatId, String additionalMetadataJSON, NotificationService.MergeFieldSettings settings) {
            // Parse additional metadata supporting both old and new formats
            Map<String, String> additionalMetadata = TicketingService.parseAdditionalMetadataForMergeFields(additionalMetadataJSON);
            Map<String, List<String>> contentsMap = new Map<String, List<String>>();
            contentsMap.put(whatId, additionalMetadata.values());
            Map<String, NotificationService.MergeFieldSettings> mergeFieldSettingsMap = new Map<String, NotificationService.MergeFieldSettings>{
                whatId => settings
            };
            Map<String, List<String>> renderResult = NotificationService.renderMergeFields(contentsMap, mergeFieldSettingsMap);

            Integer index = 0;

            for (String key : additionalMetadata.keySet()) {
                additionalMetadata.put(key, renderResult.get(whatId).get(index++));
            }
            return JSON.serialize(additionalMetadata);
        }
    }

    public static List<Log__c> getOtherLogsWithHash1AndEmptyBugTrackerLink(Log__c log, Boolean createUniqueTicketsByOrg) {
        /** Search for other Logs with Hash1 and Empty Bug_Tracker field */
        String query = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>{'Id', 'Bug_Tracker__c', 'Jira_Integration_Status__c'})
            .add(QBuilder.condition('Hash_1__c').EqualsTo(log.Hash_1__c))
            .add(QBuilder.condition('Hash_1__c').notEqualsTo(null))
            .add(QBuilder.condition('Bug_Tracker__c').EqualsTo(null))
            .add((createUniqueTicketsByOrg) ? QBuilder.condition('Organization_Id__c').EqualsTo(log.Organization_Id__c) : null)
            .add(QBuilder.condition('Id').notEqualsTo(log.Id))
            .build();
        List<Log__c> logs = Database.query(query);
        return logs;
    }

    public static List<Log__c> getOtherLogsWithHash1AndNotEmptyBugTrackerLink(String logId, String hash1, String organizationId, Boolean createUnicTicketsByOrg) {
        /** Search for other Logs with Hash1 and not Empty Bug_Tracker field */
        String query = new QBuilder(Log__c.SObjectType)
            .selectFields(new Set<String>{'Id', 'Bug_Tracker__c', 'Jira_Integration_Status__c'})
            .add(QBuilder.condition('Hash_1__c').equalsTo(hash1))
            .add(QBuilder.condition('Hash_1__c').notEqualsTo(null))
            .add(QBuilder.condition('Bug_Tracker__c').notEqualsTo(null))
            .add((createUnicTicketsByOrg) ? QBuilder.condition('Organization_Id__c').equalsTo(organizationId) : null)
            .add(QBuilder.condition('Id').notEqualsTo(logId))
            .build();
        List<Log__c> logs = Database.query(query);
        return logs;
    }

    // When creating a ticket,
    // if an open ticket for same hash1 under a different org already exists in JIRA,
    // still create a new ticket and link the open ticket to it.
    public static List<Log__c> getRelatedOpenLogsByHash1(TicketingService.TicketingSObjectWrapper sObjectWrapper, Boolean createUniqueTicketsByOrg) {
        List<Log__c> relatedOpenLogsByHash1 = (!createUniqueTicketsByOrg) ? [
            SELECT Id, Bug_Tracker__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.id
            AND Hash_1__c = :sObjectWrapper.hash1
            AND Resolved_On__c = NULL
            AND Bug_Tracker__c != NULL
            LIMIT 1
        ] : [
            SELECT Id, Bug_Tracker__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.id
                AND Hash_1__c = :sObjectWrapper.hash1
                AND Organization_Id__c != :sObjectWrapper.organizationId
                AND Resolved_On__c = NULL
                AND Bug_Tracker__c != NULL
            LIMIT 1
        ];
        return relatedOpenLogsByHash1;
    }

    // If a ticket exists for the same org and is closed,
    // create a new ticket and relate to the closed one, just like our logic used to work before.
    public static List<Log__c> getRelatedClosedLogsByHash1(TicketingService.TicketingSObjectWrapper sObjectWrapper, Boolean createUniqueTicketsByOrg) {
        List<Log__c> relatedClosedLogsByHash1 = (!createUniqueTicketsByOrg) ? [
            SELECT Id, Bug_Tracker__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.id
                AND Hash_1__c = :sObjectWrapper.hash1
                AND Resolved_On__c != NULL
                AND Bug_Tracker__c != NULL
            LIMIT 1
        ] : [
            SELECT Id, Bug_Tracker__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.id
                AND Hash_1__c = :sObjectWrapper.hash1
                AND Organization_Id__c = :sObjectWrapper.organizationId
                AND Resolved_On__c != NULL
                AND Bug_Tracker__c != NULL
            LIMIT 1
        ];
        return relatedClosedLogsByHash1;
    }

    public static List<Log__c> getSameOpenLogsByHash1(TicketingService.TicketingSObjectWrapper sObjectWrapper, Boolean createUniqueTicketsByOrg) {
        List<Log__c> someOpenLogsByHash1 = (!createUniqueTicketsByOrg) ? [
            SELECT Id, Bug_Tracker__c, Jira_Integration_Status__c, Hash_1__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.Id
                AND Hash_1__c = :sObjectWrapper.hash1
                AND Resolved_On__c = null
                AND Bug_Tracker__c != null
            LIMIT 1
        ] : [
            SELECT Id, Bug_Tracker__c, Jira_Integration_Status__c, Hash_1__c
            FROM Log__c
            WHERE Id != :sObjectWrapper.Id
                AND Hash_1__c = :sObjectWrapper.hash1
                AND Organization_Id__c = :sObjectWrapper.organizationId
                AND Resolved_On__c = null
                AND Bug_Tracker__c != null
            LIMIT 1
        ];
        return someOpenLogsByHash1;
    }

    // Check if string is valid JSON
    private static Boolean isJsonString(String str) {
        if (String.isBlank(str)) {
            return false;
        }
        try {
            JSON.deserializeUntyped(str);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    // Convert text to Atlassian document format content
    public static Object textToAtlassianDocumentFormatContent(String content) {
        return textToAtlassianDocumentFormatContent(content, false);
    }
    
    // Enhanced version with link support
    public static Object textToAtlassianDocumentFormatContent(String content, Boolean supportLinks) {
        if (String.isBlank(content)) {
            return new Map<String, Object>{
                ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_DOC,
                ADFBuilder.ATTR_VERSION => 1,
                ADFBuilder.ATTR_CONTENT => new List<Object>()
            };
        }
        
        // Check if content is already an ADF document JSON string
        // If so, deserialize it instead of treating it as plain text
        if (isJsonString(content)) {
            try {
                Map<String, Object> parsedContent = (Map<String, Object>)JSON.deserializeUntyped(content);
                // Check if it's an ADF document structure
                if (parsedContent.containsKey(ADFBuilder.ATTR_TYPE) && parsedContent.get(ADFBuilder.ATTR_TYPE) == ADFBuilder.TYPE_DOC && parsedContent.containsKey(ADFBuilder.ATTR_VERSION)) {
                    // It's already an ADF document, return it as-is
                    return parsedContent;
                }
            } catch (Exception e) {
                // If deserialization fails (invalid JSON or other error), continue with normal processing
                // This is expected when content is not valid JSON, so we treat it as plain text
                // Log unexpected errors (non-JSON parsing errors) for debugging purposes
                String errorType = e.getTypeName();
                if (errorType != null && !errorType.contains('JSON') && !errorType.contains('Parse')) {
                    Logger.getInstance().addInternalError(e, TicketingService.class.getName(), 'textToAtlassianDocumentFormatContent');
                }
            }
        }
        
        List<Object> paragraphContent;
        if (supportLinks) {
            paragraphContent = parseContentWithLinks(content);
        } else {
            paragraphContent = new List<Object>{
                new Map<String, Object>{
                    ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_TEXT,
                    ADFBuilder.ATTR_TEXT => content
                }
            };
        }
        
        return new Map<String, Object>{
            ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_DOC,
            ADFBuilder.ATTR_VERSION => 1,
            ADFBuilder.ATTR_CONTENT => new List<Object>{
                new Map<String, Object>{
                    ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_PARAGRAPH,
                    ADFBuilder.ATTR_CONTENT => paragraphContent
                }
            }
        };
    }

    public static final Pattern URL_PATTERN = Pattern.compile('(https?://[^\\s]+)');
    // Parse content and create ADF nodes with proper link support
    private static List<Object> parseContentWithLinks(String content) {
        List<Object> nodes = new List<Object>();
        
        // URL regex pattern to match http/https URLs
        Matcher urlMatcher = URL_PATTERN.matcher(content);
        
        Integer lastEnd = 0;
        
        while (urlMatcher.find()) {
            Integer start = urlMatcher.start();
            Integer endPos = urlMatcher.end();
            String url = urlMatcher.group(1);
            
            // Add text before the URL
            if (start > lastEnd) {
                String textBefore = content.substring(lastEnd, start);
                if (String.isNotBlank(textBefore)) {
                    nodes.add(createTextNode(textBefore));
                }
            }
            
            // Add the URL as a link node
            nodes.add(createLinkNode(url, url));
            lastEnd = endPos;
        }
        
        // Add remaining text after the last URL
        if (lastEnd < content.length()) {
            String remainingText = content.substring(lastEnd);
            if (String.isNotBlank(remainingText)) {
                nodes.add(createTextNode(remainingText));
            }
        }
        
        // If no URLs were found, return the original content as text
        if (nodes.isEmpty()) {
            nodes.add(createTextNode(content));
        }
        
        return nodes;
    }
    
    // Create ADF text node
    private static Map<String, Object> createTextNode(String text) {
        return new Map<String, Object>{
            ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_TEXT,
            ADFBuilder.ATTR_TEXT => text
        };
    }
    
    // Create ADF link node
    private static Map<String, Object> createLinkNode(String url, String displayText) {
        return new Map<String, Object>{
            ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_TEXT,
            ADFBuilder.ATTR_TEXT => displayText,
            ADFBuilder.ATTR_MARKS => new List<Object>{
                new Map<String, Object>{
                    ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_LINK,
                    ADFBuilder.ATTR_ATTRS => new Map<String, Object>{
                        ADFBuilder.ATTR_HREF => url
                    }
                }
            }
        };
    }
    
    // Enhanced method to create ADF content with mixed text and links
    public static Object createADFContentWithLinks(List<Map<String, String>> contentParts) {
        List<Object> paragraphContent = new List<Object>();
        
        for (Map<String, String> part : contentParts) {
            String type = part.get(ADFBuilder.ATTR_TYPE);
            String text = part.get(ADFBuilder.ATTR_TEXT);
            String url = part.get('url');
            
            if (type == ADFBuilder.TYPE_LINK && String.isNotBlank(url)) {
                paragraphContent.add(createLinkNode(url, String.isNotBlank(text) ? text : url));
            } else if (type == ADFBuilder.TYPE_TEXT && String.isNotBlank(text)) {
                paragraphContent.add(createTextNode(text));
            }
        }
        
        return new Map<String, Object>{
            ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_DOC,
            ADFBuilder.ATTR_VERSION => 1,
            ADFBuilder.ATTR_CONTENT => new List<Object>{
                new Map<String, Object>{
                    ADFBuilder.ATTR_TYPE => ADFBuilder.TYPE_PARAGRAPH,
                    ADFBuilder.ATTR_CONTENT => paragraphContent
                }
            }
        };
    }

    public static final Pattern LINK_MERGE_FIELD_PATTERN = Pattern.compile('\\{![^}]*\\.Link\\}');
    // Utility method to detect if content contains merge field links
    public static Boolean containsMergeFieldLinks(String content) {
        if (String.isBlank(content)) {
            return false;
        }
        
        // Pattern to match merge fields ending with .Link
        return LINK_MERGE_FIELD_PATTERN.matcher(content).find();
    }
}