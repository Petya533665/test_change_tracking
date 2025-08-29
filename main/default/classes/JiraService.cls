public without sharing class JiraService {
    
    public class JiraServiceException extends Exception {}

    public ENUM JIRA_SERVICE_TYPE {
        JIRA_SERVICE_HOSTED_9_4_14,
        JIRA_SERVICE_CLOUD
    }

    public ENUM JIRA_SERVICE_AUTH_TYPE {
        JIRA_HOSTED,
        JIRA_CLOUD,
        JIRA_PAT
    }

    private JiraServiceInterface strategy;
    private Logger logger;

    public JiraService(JIRA_SERVICE_TYPE serviceType, Logger logger) {
        this.logger = logger;
        this.strategy = TYPE_TO_SERVICE.get(serviceType);
    }

    public static JiraService getInstance(JIRA_SERVICE_TYPE serviceType, Logger logger) {
        return new JiraService(serviceType, logger);
    }

    public static JiraService getInstance(Logger logger) {
        JIRA_SERVICE_TYPE serviceType = isCloudJiraInstance() 
            ? JiraService.JIRA_SERVICE_TYPE.JIRA_SERVICE_CLOUD
            : JiraService.JIRA_SERVICE_TYPE.JIRA_SERVICE_HOSTED_9_4_14;
        return new JiraService(serviceType, logger);
    }

    public static JiraService getInstance() {
        return getInstance(null);
    }

    public static JiraServiceInterface getService(Boolean enableHttpDebug) {
        HTTPUtils.enableHttpDebug = enableHttpDebug;
        return getInstance(null).strategy;
    }

    public static JiraServiceInterface getService() {
        return getService(false);
    }

    public static JiraServiceInterface getService(Logger logger) {
        return getInstance(logger).strategy;
    }

    private static final Map<JIRA_SERVICE_TYPE, JiraServiceInterface> TYPE_TO_SERVICE = new Map<JIRA_SERVICE_TYPE, JiraServiceInterface>{
        JIRA_SERVICE_TYPE.JIRA_SERVICE_HOSTED_9_4_14 => new JiraService_Hosted_9_4_14_Impl(),
        JIRA_SERVICE_TYPE.JIRA_SERVICE_CLOUD => new JiraService_CloudImpl()
    };

    public interface JiraServiceInterface {
        
        List<JiraProject> getProjects();
        JiraProject getProject(String projectOrKeyId);
        List<JiraProjectIssueType> getProjectIssueTypes(String projectOrKeyId);
        List<JiraProjectComponent> getProjectComponents(String projectOrKeyId, String query);
        List<JiraProjectIssueField> getProjectIssueFields(String projectOrKeyId, String issueType);
        List<JiraProjectIssueField> getProjectIssueFields(List<JiraProjectIssueType> issueTypes, String issueTypeId);
        Map<String, JiraProjectIssueField> getProjectIssueCustomFields(String projectOrKeyId, String issueType);
        Map<String, JiraProjectIssueField> getProjectIssueCustomFields(List<JiraProjectIssueField> mapFields);
        Map<String, JiraProjectIssueField> getProjectIssueCustomFields(List<JiraProjectIssueType> issueTypes, String issueTypeId);
        List<JiraProjectUser> getProjectAssignableUsers(String projectKey, String queryOrUsername);
        List<JiraPriority> getPriorities();
        List<JiraPriorityScheme> getPrioritySchemes();
        List<JiraIssue> getEpics(String projectOrKeyId, String query);
        JiraResourceWrapper getJiraAvailableResources();
        JiraIssue getJiraIssueByKey(String taskKey, Logger logger);
        JiraIssue getJiraIssueByKey(String taskKey, Logger logger, Boolean throwNotFoundException);
        String getJiraIssueByKeyRaw(String taskKey, Logger logger);

        String getCreateIssueCommentEndpoint(String taskKey);
        String getCreateIssueAttachmentEndpoint(String taskKey);
        String getCreateIssueEndpoint();
        String getProjectsEndpoint();
        String getProjectEndpoint(String projectOrKeyId);
        String getProjectComponentsEndpoint(String projectOrKeyId, String query);
        String getProjectIssueTypesEndpoint(String projectOrKeyId);
        String getProjectIssueFieldsEndpoint(String projectOrKeyId, String issueType);
        String getProjectIssueFieldsEndpoint(String projectOrKeyId, String issueType, Integer startAt, Integer maxResults);
        String getPrioritiesEndpoint();
        String getPrioritySchemesEndpoint();
        String getPutJiraTaskPropertiesEndpoint(String issueKey);
        String getIssueEndpoint(String issueKey);
        String getExpandedIssueEndpoint(String issueKey);
        String getLinkIssuesEndpoint();
        String getUnLinkIssueEndpoint(String linkId);
        String getJQLEndpoint(String jql);
        String getEpicsEndpoint(String projectOrKeyId, String query);
        String getSearchIssueByLabelEndpoint(String label, String projectOrKeyId);
        String getBulkResolutionTasksEndpoint(List<String> taskKeys);
        String getProjectAssignableUsersEndpoint(String projectOrKeyId, String queryOrUsername);

        void linkIssuesAsRelates(String inwardIssueKey, String outwardIssueKey);
        void linkIssuesAsDuplicates(String inwardIssueKey, String outwardIssueKey);
        void unLinkIssue(String linkId);
        JiraIssue searchIssueByHash2(String label, String projectOrKeyId);
        JiraIssue searchIssueByHash3(String label, String projectOrKeyId);
        List<JiraResourceWrapper> getJiraEndpoint(String token);
        List<JiraResourceWrapper> getJiraEndpoint();
        List<Object> getBulkResolutionTasks(List<String> taskKeys, Logger logger);
        Map<String, DateTime> getResolutionDatetimeByTaskKey(List<String> taskKeys, Logger logger);
        void putJiraTaskPriority(String taskKey, String taskPriorityName);
        void putJiraTaskProperties(String issueKey, Id recordId);
        void createNewTicketComment(String comment, String issueKey);
        String addAttachment(Blob fileBlob, String fileName, String issueKey);
        String addCommentToIssueWithAttachments(String message, String issueKey, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient);
        Object transformCustomFieldValue(String rawValue, JiraProjectIssueField field, Logger logger);
        Boolean isJiraCustomFieldHasAllowedType(JiraProjectIssueField field);
    }

    public static final String URL_PATH_SLASH = '/';

    public static JIRA_SERVICE_AUTH_TYPE getJIRAServiceAuthType() {
        if(ConfigUtil.JIRA_SETTINGS.Jira_Username__c == JIRA_CLOUD_OAUTH_USERNAME) {
            return JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD;
        }
        else if (String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Username__c) 
            && String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c)) {
            return JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED;
        }
        else if (String.isBlank(ConfigUtil.JIRA_SETTINGS.Jira_Username__c) 
            && String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c)) {
            return JIRA_SERVICE_AUTH_TYPE.JIRA_PAT;
        }
        return null;
    }

    public static String JIRA_API_URL {
        get {
            if(JIRA_API_URL == null) {
                JIRA_SERVICE_AUTH_TYPE authType = getJIRAServiceAuthType();
                JIRA_API_URL = (String.isNotBlank(JIRA_OAUTH_TOKEN) && authType == JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD)
                    ? ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c
                    : ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c;
                JIRA_API_URL = JIRA_API_URL != null && JIRA_API_URL?.endsWith(URL_PATH_SLASH) 
                    ? JIRA_API_URL?.removeEnd(URL_PATH_SLASH)
                    : JIRA_API_URL;
            }
            return JIRA_API_URL;
        }
        set;
    }

    public static String JIRA_OAUTH_TOKEN {
        get {
            JIRA_SERVICE_AUTH_TYPE authType = getJIRAServiceAuthType();
            switch on authType {
                when JIRA_CLOUD {
                    JIRA_OAUTH_TOKEN = JiraService.getDecryptedJiraTokenFromCache();
                    if (JIRA_OAUTH_TOKEN == null) {
                        JIRA_OAUTH_TOKEN = JiraService.getApiTokenFromSettings();
                    }
                }
                when JIRA_HOSTED, JIRA_PAT {
                    JIRA_OAUTH_TOKEN = ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c;
                }
            }
            return JIRA_OAUTH_TOKEN;
        }
        set;
    }

    public static String JIRA_OAUTH_REFRESH_TOKEN {
        get {
            if (JIRA_OAUTH_REFRESH_TOKEN == null) {
                JIRA_OAUTH_REFRESH_TOKEN = JiraService.getApiRefreshTokenFromSettings();
            }
            return JIRA_OAUTH_REFRESH_TOKEN;
        }
        set;
    }

    public static final String JIRA_SETTINGS_OBJECT_NAME = 'Pharos_Jira_Settings__mdt';
    public static final String JIRA_SETTINGS_OBJECT_FIELD_JIRA_UI_ENDPOINT = 'Jira_UI_Endpoint__c';

    public static String toCustomJiraUiEndpoint(String jiraTaskUrl) {
        if(String.isBlank(jiraTaskUrl)) {
            return null;
        }
        // other ticketing systems (azure)
        if(!JiraSyncBatch.isJiraTaskUrl(jiraTaskUrl)) {
            return jiraTaskUrl;
        }

        if(String.isNotBlank(JIRA_UI_ENDPOINT)) {
            String ticketId = JiraService.getIssueKeyByUrl(jiraTaskUrl);
            return JIRA_UI_ENDPOINT + '/browse/' + ticketId;
        }

        return jiraTaskUrl;
    }

    public static String getJiraSettingsQuery() {
        String query = null;
        String objectName = ConfigUtil.prefixCurrentOrgNamespace(JIRA_SETTINGS_OBJECT_NAME);

        if(ConfigUtil.MAP_GD.containsKey(objectName)) {
            String jiraUiEndpoint = ConfigUtil.prefixCurrentOrgNamespace(JIRA_SETTINGS_OBJECT_FIELD_JIRA_UI_ENDPOINT);
            query = new QBuilder(objectName)
                .selectFields(new Set<String>{jiraUiEndpoint})
                .build();
        }
        return query;
    }

    @TestVisible
    private static List<JiraSettingsSObjectWrapper> JIRA_SETTINGS_TEST_RECORDS;

    public class JiraSettingsSObjectWrapper {
        public String jiraUiEndpoint;

        public JiraSettingsSObjectWrapper(String jiraUiEndpoint) {
            this.jiraUiEndpoint = jiraUiEndpoint;
        }
    }

    private static List<JiraSettingsSObjectWrapper> getJiraSettingsRecords() {
        List<JiraSettingsSObjectWrapper> result = new List<JiraSettingsSObjectWrapper>();
        String query = getJiraSettingsQuery();
        List<SObject> records = (String.isNotBlank(query) ? Database.query(query) : new List<SObject>());
        for(SObject obj : records) {
            String jiraUiEndpointApiName = ConfigUtil.prefixCurrentOrgNamespace(JIRA_SETTINGS_OBJECT_FIELD_JIRA_UI_ENDPOINT);
            String jiraUiEndpointValue = obj.get(jiraUiEndpointApiName) != null ? String.valueOf(obj.get(jiraUiEndpointApiName)) : null;
            if(String.isNotBlank(jiraUiEndpointValue)) {
                JiraSettingsSObjectWrapper wrp = new JiraSettingsSObjectWrapper(jiraUiEndpointValue);
                result.add(wrp);
            }
        }
        return (Test.isRunningTest()) ? JIRA_SETTINGS_TEST_RECORDS : result;
    }

    public static String JIRA_UI_ENDPOINT {
        get {
            if(JIRA_UI_ENDPOINT == null) {
                JIRA_UI_ENDPOINT = '';
                List<JiraSettingsSObjectWrapper> records = getJiraSettingsRecords();
                if(records != null) {
                    for(JiraSettingsSObjectWrapper wrp : records) {
                        JIRA_UI_ENDPOINT = wrp.jiraUiEndpoint;
                        break;
                    }
                }
            }
            return JIRA_UI_ENDPOINT;
        }
        set;
    }

    public static final String ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_NAME = 'Pharos_Jira_Priority_Mapping__mdt';
    public static final String ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PROJECT_KEY = 'Project_Key__c';
    public static final String ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PRIORITY_IDS = 'Priorities__c';

    public static String getJiraPriorityMappingQuery() {
        String query = null;
        String objectName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_NAME);

        if(ConfigUtil.MAP_GD.containsKey(objectName)) {
            String projectKey = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PROJECT_KEY);
            String priorityIds = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PRIORITY_IDS);

            query = new QBuilder(objectName)
                .selectFields(new Set<String>{projectKey, priorityIds})
                .build();
        }

        return query;
    }

    @TestVisible
    private static List<JiraMappingSObjectWrapper> JIRA_PRIORITY_MAPPING_TEST_RECORDS;

    public class JiraMappingSObjectWrapper {
        public String projectKey;
        public String priorityIds;

        public JiraMappingSObjectWrapper(String projectKey, String priorityIds) {
            this.projectKey = projectKey;
            this.priorityIds = priorityIds;
        }
    }

    private static List<JiraMappingSObjectWrapper> getJiraMappingRecords() {
        List<JiraMappingSObjectWrapper> result = new List<JiraMappingSObjectWrapper>();
        String query = getJiraPriorityMappingQuery();
        List<SObject> records = (String.isNotBlank(query) ? Database.query(query) : new List<SObject>());
        for(SObject obj : records) {
            String projectKeyApiName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PROJECT_KEY);
            String priorityIdsApiName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_MAPPING_PRIORITY_MDT_OBJECT_FIELD_PRIORITY_IDS);

            String projectKey = obj.get(projectKeyApiName) != null ? String.valueOf(obj.get(projectKeyApiName)) : null;
            String priorityIds = obj.get(priorityIdsApiName) != null ? String.valueOf(obj.get(priorityIdsApiName)) : null;
            if(String.isNotBlank(projectKey) && String.isNotBlank(priorityIds)) {
                JiraMappingSObjectWrapper wrp = new JiraMappingSObjectWrapper(projectKey, priorityIds);
                result.add(wrp);
            }
        }
        return (Test.isRunningTest()) ? JIRA_PRIORITY_MAPPING_TEST_RECORDS : result;
    }

    public static List<JiraService.JiraPriorityScheme> JIRA_PRIORITY_MAPPING {
        get {
            if(JIRA_PRIORITY_MAPPING == null) {
                JIRA_PRIORITY_MAPPING = new List<JiraService.JiraPriorityScheme>();
                List<JiraMappingSObjectWrapper> records = getJiraMappingRecords();
                if(records != null) {
                    for(JiraMappingSObjectWrapper wrp : records) {
                        List<String> priorityIdsList = new List<String>();
                        for (String priorityId : wrp.priorityIds?.split(',')) {
                            priorityIdsList.add(priorityId?.trim());
                        }
                        JiraService.JiraPriorityScheme scheme = new JiraService.JiraPriorityScheme();
                        scheme.projectKeys = new List<String>{wrp.projectKey};
                        scheme.optionIds = priorityIdsList;
                        JIRA_PRIORITY_MAPPING.add(scheme);
                    }
                }
            }
            return JIRA_PRIORITY_MAPPING;
        }
        set;
    }

    public static final String ADDITIONAL_JIRA_HEADER_MDT_OBJECT_NAME = 'Pharos_Jira_Headers__mdt';
    public static final String ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_VALUE = 'Value__c';
    public static final String ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_NAME = 'Name__c';

    public static String getAdditionalJiraHeadersQuery() {
        String query = null;
        String objectName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_HEADER_MDT_OBJECT_NAME);

        if(ConfigUtil.MAP_GD.containsKey(objectName)) {
            String fieldValue = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_VALUE);
            String fieldName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_NAME);

            query = new QBuilder(objectName)
                .selectFields(new Set<String>{fieldValue, fieldName})
                .build();
        }

        return query;
    }


    public static Map<String, String> ADDITIONAL_JIRA_HEADERS {
        get {
            if(ADDITIONAL_JIRA_HEADERS == null) {
                try {
                    ADDITIONAL_JIRA_HEADERS = new Map<String, String>();
                    String query = getAdditionalJiraHeadersQuery();
                    if(String.isNotBlank(query)) {
                        for(Sobject obj : Database.query(query)) {
                            String nameApiName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_NAME);
                            String valueApiName = ConfigUtil.prefixCurrentOrgNamespace(ADDITIONAL_JIRA_HEADER_MDT_OBJECT_FIELD_VALUE);

                            String name = obj.get(nameApiName) != null ? String.valueOf(obj.get(nameApiName)) : null;
                            String value = obj.get(valueApiName) != null ? String.valueOf(obj.get(valueApiName)) : null;

                            if(String.isNotBlank(name) && String.isNotBlank(value)) {
                                ADDITIONAL_JIRA_HEADERS.put(name, value);
                            }
                        }
                    }
                }
                catch(Exception e){}
            }
            return ADDITIONAL_JIRA_HEADERS;
        }
        set;
    }

    public static Map<String, String> JIRA_HEADERS {
        get {
            JIRA_HEADERS = new Map<String, String>();
            if(!ADDITIONAL_JIRA_HEADERS.isEmpty()) {
                JIRA_HEADERS.putAll(ADDITIONAL_JIRA_HEADERS);
            }
            JIRA_SERVICE_AUTH_TYPE authType = getJIRAServiceAuthType();
            switch on authType {
                when JIRA_CLOUD, JIRA_PAT {
                    JIRA_HEADERS.putAll(HttpUtils.getHeadersAuthorizationAcceptJson('Bearer ' + JIRA_OAUTH_TOKEN));
                    JIRA_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
                }
                when JIRA_HOSTED {
                    Blob headerValue = Blob.valueOf(ConfigUtil.JIRA_SETTINGS.Jira_Username__c + ':' + JIRA_OAUTH_TOKEN);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    JIRA_HEADERS.putAll(HttpUtils.getHeadersAuthorizationAcceptJson(authorizationHeader));
                    JIRA_HEADERS.putAll(HttpUtils.getHeadersContentTypeJSON());
                }
            }
            return JIRA_HEADERS;
        }
        set;
    }

    public static final String API_VERSION = '2';
    public static final String API_REST = '/rest/api/';
    public static final String API_PROJECT = '/project/';
    public static final String API_PROJECT_COMPONENTS = '/components';
    public static final String API_PROJECT_COMPONENT = '/component';
    public static final String API_ISSUE_CREATE_META = '/issue/createmeta';
    public static final String API_ISSUE_CREATE_COMMENT = '/comment';
    public static final String API_ISSUE_CREATE_ATTACHMENTS = '/attachments';
    public static final String API_ISSUE_CREATE_META_ISSUE_TYPES = '/issue/createmeta/{0}/issuetypes';
    public static final String API_ISSUE_LINK = '/issueLink';
    public static final String API_ISSUE = '/issue/';
    public static final String API_ISSUE_CREATE = '/issue';
    public static final String API_ISSUE_EXPANDED_PARAMETER = '?expand=renderedFields';
    public static final String API_ISSUE_PROPERTIES = '/properties/pharos_log';
    public static final String API_USER_SEARCH_BY_PROJECT = '/user/assignable/search?project=';
    public static final String API_PRIORITIES = '/priority';
    public static final String API_PRIORITY_SCHEMES = '/priorityschemes?expand=schemes.projectKeys';
    public static final String API_JQL_SEARCH = '/search';
    public static String API_REST_BASE =  JIRA_API_URL + API_REST + API_VERSION;

    public static final String JIRA_CLOUD_API_RESOURCES_ENDPOINT = 'https://api.atlassian.com/oauth/token/accessible-resources';
    public static final String LINK_ISSUE_TYPE_RELATES = 'Relates';
    public static final String LINK_ISSUE_TYPE_DUPLICATE = 'Duplicate';
    public static final String JIRA_API_JQL = 'jql';
    public static final String JIRA_API_JQL_MAX_RESULTS = 'maxResults';
    public static final String JIRA_API_JQL_MAX_RESULTS_DEFAULT_VALUE = '100';
    public static final String JIRA_API_JQL_VALIDATE_QUERY = 'validateQuery';
    public static final String JIRA_API_JQL_VALIDATE_QUERY_DEFAULT_VALUE = 'false';
    public static final String JIRA_API_JQL_ISSUES = 'issues';
    public static final String JIRA_API_JQL_ISSUE_KEY = 'key';
    public static final String JIRA_API_JQL_ISSUE_FIELDS = 'fields';
    public static final String JIRA_API_JQL_ISSUE_RESOLUTION_DATE = 'resolutiondate';
    public static final String API_PAGINATION_MAX_RESULTS = 'maxResults';
    public static final String API_PAGINATION_START_AT = 'startAt';
    public static final String API_PAGINATION_MAX_RESULTS_DEFAULT_VALUE = '200';
    public static final String API_PAGINATION_START_AT_DEFAULT_VALUE = '0';
    public static final Integer API_PAGINATION_MAX_CALLS = 5; // 5 call by 200 fields = 1000 fields


    public abstract class JiraServiceDefaultImpl implements JiraServiceInterface {

        public virtual String getProjectsEndpoint() {
            return API_REST_BASE + API_ISSUE_CREATE_META;
        }

        public virtual String getProjectEndpoint(String projectOrKeyId) {
            return API_REST_BASE + API_PROJECT + projectOrKeyId;
        }

        public virtual String getProjectComponentsEndpoint(String projectOrKeyId, String query) {
            String endpoint = API_REST_BASE + API_PROJECT + projectOrKeyId;
            if(String.isNotBlank(query)) {
                endpoint += API_PROJECT_COMPONENT + '?query=' + EncodingUtil.urlEncode(query?.trim(), 'UTF-8');
            }
            else {
                endpoint += API_PROJECT_COMPONENTS;
            }
            return endpoint;
        }

        public virtual String getProjectIssueTypesEndpoint(String projectOrKeyId) {
            String projectIssueTypes = String.format(API_ISSUE_CREATE_META_ISSUE_TYPES, new List<String>{projectOrKeyId});
            return JIRA_API_URL + API_REST + API_VERSION + projectIssueTypes;
        }

        public virtual String getProjectIssueFieldsEndpoint(String projectOrKeyId, String issueType) {
            return getProjectIssueFieldsEndpoint(projectOrKeyId, issueType, null, null);
        }

        public virtual String getProjectIssueFieldsEndpoint(String projectOrKeyId, String issueType, Integer startAt, Integer maxResults) {
            return getProjectIssueTypesEndpoint(projectOrKeyId)
                + '/' + issueType
                + '?' + API_PAGINATION_MAX_RESULTS + '=' + (maxResults != null ? String.valueOf(maxResults) : API_PAGINATION_MAX_RESULTS_DEFAULT_VALUE)
                + '&' + API_PAGINATION_START_AT + '=' + (startAt != null ? String.valueOf(startAt) : API_PAGINATION_START_AT_DEFAULT_VALUE);
        }

        public virtual String getProjectAssignableUsersEndpoint(String projectKey, String query) {
            String endpoint = API_REST_BASE + API_USER_SEARCH_BY_PROJECT + projectKey;
            if(String.isNotBlank(query)) {
                endpoint += '&query=' + EncodingUtil.urlEncode(query?.trim(), 'UTF-8');
            }
            return endpoint;
        }

        public virtual String getPrioritiesEndpoint() {
            return API_REST_BASE + API_PRIORITIES;
        }

        public virtual String getPrioritySchemesEndpoint() {
            return API_REST_BASE + API_PRIORITY_SCHEMES;
        }

        public virtual String getPutJiraTaskPropertiesEndpoint(String issueKey) {
            return API_REST_BASE + API_ISSUE + issueKey + API_ISSUE_PROPERTIES;
        }

        public virtual String getIssueEndpoint(String issueKey) {
            return API_REST_BASE + API_ISSUE + issueKey;
        }

        public virtual String getExpandedIssueEndpoint(String issueKey) {
            return getIssueEndpoint(issueKey + API_ISSUE_EXPANDED_PARAMETER);
        }

        public virtual String getCreateIssueAttachmentEndpoint(String issueKey) {
            return API_REST_BASE + API_ISSUE + issueKey + API_ISSUE_CREATE_ATTACHMENTS;
        }

        public virtual String getCreateIssueCommentEndpoint(String issueKey) {
            return API_REST_BASE + API_ISSUE + issueKey + API_ISSUE_CREATE_COMMENT;
        }

        public virtual String getLinkIssuesEndpoint() {
            return API_REST_BASE + API_ISSUE_LINK;
        }

        public virtual String getUnLinkIssueEndpoint(String linkId) {
            return API_REST_BASE + API_ISSUE_LINK + '/' + linkId;
        }

        public virtual String getJQLEndpoint(String jql) {
            HttpUtils.HttpURLParameters queryParams = new HttpUtils.HttpURLParameters();
            queryParams.addEncodedParameter(JIRA_API_JQL, jql);
            return API_REST_BASE + API_JQL_SEARCH + queryParams.toStringParameters('?');
        }

        public virtual String getEpicsEndpoint(String projectOrKeyId, String query) {
            String jql = 'project="' + projectOrKeyId + '" AND issuetype="Epic"';
            if(String.isNotBlank(query)) {
                // limit search to epic key if it starts with the project key
                // like PTP-123
                if (query.startsWith(projectOrKeyId + '-')) {
                    jql += ' AND key = "' + EncodingUtil.urlEncode(query.trim(), 'UTF-8') + '"';
                }
                // like 123, auto-complete will return the epic key
                else if (query.isNumeric()) {
                    jql += ' AND key = "' + EncodingUtil.urlEncode(projectOrKeyId + '-' + query.trim(), 'UTF-8') + '"';
                }
                // like "test epic", auto-complete will return the epic summary
                else {
                    jql += ' AND summary ~ "' + EncodingUtil.urlEncode(query.trim(), 'UTF-8') + '"';
                }
            }
            return getJQLEndpoint(jql);
        }

        public virtual String getSearchIssueByLabelEndpoint(String label, String projectOrKeyId) {
            String jql = 'project = \'' + projectOrKeyId + '\' AND labels = ' + label + ' AND statusCategory != \'done\' ORDER BY created ASC';
            return getJQLEndpoint(jql);
        }

        // /rest/api/2/search?jql=KEY%20IN%20(key1,key2,...,keyN)&fields=status&maxResults=100)
        public virtual String getBulkResolutionTasksEndpoint(List<String> taskKeys) {
            String jql = 'KEY IN (' + String.join(taskKeys, ',') + ')';
            HttpUtils.HttpURLParameters queryParams = new HttpUtils.HttpURLParameters();
            queryParams.addEncodedParameter(JIRA_API_JQL, jql);
            queryParams.addParameter(JIRA_API_JQL_ISSUE_FIELDS, JIRA_API_JQL_ISSUE_RESOLUTION_DATE);
            queryParams.addParameter(JIRA_API_JQL_MAX_RESULTS, JIRA_API_JQL_MAX_RESULTS_DEFAULT_VALUE);
            queryParams.addParameter(JIRA_API_JQL_VALIDATE_QUERY, JIRA_API_JQL_VALIDATE_QUERY_DEFAULT_VALUE);
            return API_REST_BASE + API_JQL_SEARCH + queryParams.toStringParameters('?');
        }

        public virtual String getCreateIssueEndpoint() {
            return API_REST_BASE + API_ISSUE_CREATE;
        }

        private virtual String getApiData(String endpoint) {
            return getApiData(endpoint, JIRA_HEADERS);
        }

        private virtual String getApiData(String endpoint, Map<String, String> headers) {
            String b = HttpUtils.get(
                endpoint,
                headers,
                200
            );
            return b;
        }

        private virtual void putApiData(String endpoint, Map<String, Object> bodyObject) {
            putApiData(endpoint, bodyObject, 201);
        }

        private virtual void putApiData(String endpoint, Map<String, Object> bodyObject, Integer responseCode) {
            String b = HttpUtils.put(
                endpoint,
                JSON.serialize(bodyObject),
                JIRA_HEADERS,
                responseCode
            );
        }

        private virtual void postApiData(String endpoint, Map<String, Object> bodyObject) {
            String b = HttpUtils.post(
                endpoint,
                JSON.serialize(bodyObject),
                JIRA_HEADERS,
                201
            );
        }

        private virtual void deleteApiData(String endpoint) {
            String b = HttpUtils.del(
                endpoint,
                JIRA_HEADERS,
                204
            );
        }

        private virtual List<JiraProject> deserializeProjects(String jsonData) {
            List<JiraProject> result = new List<JiraProject>();
            result = ((JiraProjectList)JSON.deserialize(jsonData, JiraProjectList.class)).projects;
            return result;
        }
        
        public virtual List<JiraProject> getProjects() {
            List<JiraProject> result = new List<JiraProject>();
            String b = getApiData(getProjectsEndpoint());
            result = deserializeProjects(b);
            for(JiraProject jiraProject : result) {
                JiraService.removeJiraIssueTypes(jiraProject);
            }
            return result;
        }

        public virtual JiraProject getProject(String projectOrKeyId) {
            JiraProject result;
            String b = getApiData(getProjectEndpoint(projectOrKeyId));
            result = (JiraProject)JSON.deserialize(b, JiraProject.class);
            JiraService.removeJiraIssueTypes(result);
            return result;
        }

        public virtual List<JiraProjectIssueType> getProjectIssueTypes(String projectOrKeyId) {
            List<JiraProjectIssueType> result = new List<JiraProjectIssueType>();
            String b = getApiData(getProjectIssueTypesEndpoint(projectOrKeyId));
            JiraProjectIssueTypesWrapper wrapper = (JiraProjectIssueTypesWrapper)JSON.deserialize(b, JiraProjectIssueTypesWrapper.class);
            result = wrapper.issueTypes;
            removeJiraIssueTypes(result);
            return result;
        }

        public virtual List<JiraProjectIssueField> getProjectIssueFields(String projectOrKeyId, String issueType) {
            List<JiraProjectIssueField> result = new List<JiraProjectIssueField>();
            Integer startAt = Integer.valueOf(API_PAGINATION_START_AT_DEFAULT_VALUE);
            Integer maxResults = Integer.valueOf(API_PAGINATION_MAX_RESULTS_DEFAULT_VALUE);
            Integer callCount = 0;
            Boolean hasMoreData = true;

            while (hasMoreData && callCount < API_PAGINATION_MAX_CALLS) {
                String b = getApiData(getProjectIssueFieldsEndpoint(projectOrKeyId, issueType, startAt, maxResults));
                JiraProjectIssueTypeFieldsWrapper wrapper = (JiraProjectIssueTypeFieldsWrapper)JSON.deserialize(b, JiraProjectIssueTypeFieldsWrapper.class);

                if (wrapper != null && wrapper.getFields() != null && !wrapper.getFields().isEmpty()) {
                    result.addAll(wrapper.getFields());

                    // Check if we have more data based on total count
                    hasMoreData = (startAt + wrapper.getFields().size()) < wrapper.total;
                    startAt += maxResults;
                } else {
                    hasMoreData = false;
                }

                callCount++;
            }

            return result;
        }

        public virtual List<JiraProjectIssueField> getProjectIssueFields(List<JiraProjectIssueType> issueTypes, String issueTypeId) {
            List<JiraProjectIssueField> result = new List<JiraProjectIssueField>();
            for(JiraProjectIssueType issueType : issueTypes) {
                if(issueType.id == issueTypeId && issueType?.fields != null && !issueType?.fields?.isEmpty()) {
                    result = issueType.fields.values();
                    break;
                }
            }
            return result;
        }
        
        public virtual Map<String, JiraProjectIssueField> getProjectIssueCustomFields(String projectOrKeyId, String issueType) {
            Map<String, JiraProjectIssueField> result = new Map<String, JiraProjectIssueField>();
            result = getProjectIssueCustomFields(getProjectIssueFields(projectOrKeyId, issueType));
            return result;
        }

        public virtual Map<String, JiraProjectIssueField> getProjectIssueCustomFields(List<JiraProjectIssueType> issueTypes, String issueTypeId) {
            Map<String, JiraProjectIssueField> result = new Map<String, JiraProjectIssueField>();
            for(JiraProjectIssueType issueType : issueTypes) {
                if(issueType.id == issueTypeId && issueType?.fields != null && !issueType?.fields?.isEmpty()) {
                    result = getProjectIssueCustomFields(issueType.fields.values());
                    break;
                }
            }
            return result;
        }

        public virtual Map<String, JiraProjectIssueField> getProjectIssueCustomFields(List<JiraProjectIssueField> fields) {
            Map<String, JiraProjectIssueField> result = new Map<String, JiraProjectIssueField>();
            for(JiraProjectIssueField field : fields) {
                if(field?.key != null && field?.key?.startsWith('customfield') && field?.operations?.contains('set') && isJiraCustomFieldHasAllowedType(field)) {
                    result.put(field.key, field);
                }
                else if (field?.fieldId != null && field?.fieldId?.startsWith('customfield') && field?.operations?.contains('set') && isJiraCustomFieldHasAllowedType(field)) {
                    field.key = field.fieldId;
                    result.put(field.key, field);
                }
            }
            return result;
        }

        public virtual Boolean isJiraCustomFieldHasAllowedType(JiraProjectIssueField field) {
            if (field?.schema?.custom == null) {
                return false;
            }

            // Use the plugin pattern to determine if field type is supported
            return getSupportedFieldTypes().contains(field.schema.custom);
        }

        public virtual Set<String> getSupportedFieldTypes() {
            return FIELD_TRANSFORMERS.keySet();
        }

        public virtual Object transformCustomFieldValue(String rawValue, JiraProjectIssueField field, Logger logger) {
            if (String.isBlank(rawValue) || field?.schema?.custom == null) {
                return rawValue;
            }

            try {
                JiraFieldTransformer transformer = getFieldTransformer(field.schema.custom);
                if (transformer != null) {
                    JiraFieldValidationResult validationResult = transformer.validateInput(rawValue);
                    if (!validationResult.isValid) {
                        logger?.add(logger.getInternalError(
                            new JiraServiceException('Invalid field value: ' + validationResult.errorMessage),
                            null,
                            JiraService.class.getName(),
                            'transformCustomFieldValue'
                        ));
                        return rawValue; // Return original value if validation fails
                    }
                    return transformer.transform(rawValue);
                }
                return rawValue; // Return as-is if no transformer found
            } catch (Exception e) {
                logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'transformCustomFieldValue'));
                return rawValue; // Fallback to original value
            }
        }

        private virtual JiraFieldTransformer getFieldTransformer(String customType) {
            return FIELD_TRANSFORMERS.get(customType);
        }

        private final Map<String, JiraFieldTransformer> FIELD_TRANSFORMERS = new Map<String, JiraFieldTransformer>{
            'com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes' => new MultiCheckboxTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:multiselect' => new MultiSelectTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:select' => new SelectTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:radiobuttons' => new RadioButtonTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:datepicker' => new DatePickerTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:datetime' => new DateTimeTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:float' => new NumberTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:textarea' => new TextAreaTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:textfield' => new TextFieldTransformer(),
            'com.atlassian.jira.plugin.system.customfieldtypes:url' => new UrlTransformer()
        };

        public virtual List<JiraProjectComponent> getProjectComponents(String projectOrKeyId, String query) {
            List<JiraProjectComponent> result = new List<JiraProjectComponent>();
            String b = getApiData(getProjectComponentsEndpoint(projectOrKeyId, query));
            if (String.isNotBlank(query)) {
                JiraProjectComponentPaginatedResponse paginatedResponse = (JiraProjectComponentPaginatedResponse)JSON.deserialize(b, JiraProjectComponentPaginatedResponse.class);
                result = paginatedResponse?.values;
            }
            else {
                result = (List<JiraProjectComponent>)JSON.deserialize(b, List<JiraProjectComponent>.class);
            }
            return result;
        }

        public virtual List<JiraProjectUser> getProjectAssignableUsers(String projectKey, String query) {
            List<JiraProjectUser> result = new List<JiraProjectUser>();
            String b = getApiData(getProjectAssignableUsersEndpoint(projectKey, query));
            result = (List<JiraProjectUser>)JSON.deserialize(b, List<JiraProjectUser>.class);
            for(JiraProjectUser ju : result) {
                if(ju.accountId == null && ju.name != null) {
                    ju.accountId = ju.name;
                }
            }
            return result;
        }

        public virtual List<JiraPriority> getPriorities() {
            List<JiraPriority> result = new List<JiraPriority>();
            String b = getApiData(getPrioritiesEndpoint());
            result = (List<JiraPriority>)JSON.deserialize(b, List<JiraPriority>.class);
            return result;
        }

        public virtual List<JiraPriorityScheme> getPrioritySchemes() {
            List<JiraPriorityScheme> result = new List<JiraPriorityScheme>();
            String b = getApiData(getPrioritySchemesEndpoint());
            JiraPrioritySchemeWrapper wrapp = (JiraPrioritySchemeWrapper)JSON.deserialize(b, JiraPrioritySchemeWrapper.class);
            result = wrapp.schemes;
            return result;
        }

        public virtual List<JiraIssue> getEpics(String projectOrKeyId, String query) {
            List<JiraIssue> result = new List<JiraIssue>();
            String b = getApiData(getEpicsEndpoint(projectOrKeyId, query));
            JQLResponse jqlResponse = (JQLResponse)JSON.deserialize(b, JQLResponse.class);
            result = jqlResponse?.issues;
            return result;
        }

        public virtual JiraIssue searchIssueByHash2(String label, String projectOrKeyId) {
            return searchIssueByLabel('\'h2_' + label + '\'', projectOrKeyId);
        }

        public virtual JiraIssue searchIssueByHash3(String label, String projectOrKeyId) {
            return searchIssueByLabel('\'h3_' + label + '\'', projectOrKeyId);
        }

        public virtual void createNewTicketComment(String comment, String issueKey) {

            String b = HttpUtils.post(
                JiraService.getService().getCreateIssueCommentEndpoint(issueKey),
                comment,
                JiraService.JIRA_HEADERS,
                201
            );
        }

        public virtual String addCommentToIssueWithAttachments(String message, String issueKey, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {
            if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {
                for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                    if (chart != null && String.isNotBlank(chart)) {
                        ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);

                        if (chartEnum != null) {
                            Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                            String fileName = HttpUtils.getNameAttachment(chartEnum.name() + '.png');
                            addAttachment(chartBlob, fileName, issueKey);
                            message += '\n!' + fileName + '!';
                        } else {
                            // Chart type not found in enum
                        }
                    }
                }
            }
            return message;
        }



        public virtual String addAttachment(Blob fileBlob, String fileName, String issueKey) {
            String boundary = '----WebKitFormBoundary' + System.currentTimeMillis();

            Map<String, String> headers = new Map<String, String>(JiraService.JIRA_HEADERS);
            headers.put('Content-Type', 'application/octet-stream');
            headers.put('X-Atlassian-Token', 'no-check');
            headers.put('Content-Type', 'multipart/form-data; boundary=' + boundary);


            String endpoint = JiraService.getService().getCreateIssueAttachmentEndpoint(issueKey);

            Blob bodyBlob = HttpUtils.getMultipartFormData(boundary, fileBlob, fileName);

            String bb = HttpUtils.postputBlobBody(
                endpoint,
                bodyBlob,
                headers,
                200
            );

            return fileName;
        }

        private virtual JiraIssue searchIssueByLabel(String label, String projectOrKeyId) {
            String b = getApiData(getSearchIssueByLabelEndpoint(label, projectOrKeyId));
            JQLResponse resp = (JQLResponse)JSON.deserialize(b, JQLResponse.class);
            if (resp?.total > 0) {
                return resp.issues[0];
            }
            return null;
        }

        public virtual void putJiraTaskProperties(String issueKey, Id recordId) {
            Map<String, Object> bodyObject = new Map<String, Object>{
                'id' => recordId,
                'instance' => Constants.GLOBAL_VARIABLE.BASE_URL,
                'org_id' => UserInfo.getOrganizationId(),
                'is_sandbox' => ConfigUtil.currentOrgIsSandbox,
                'is_enabled' => true
            };
            putApiData(getPutJiraTaskPropertiesEndpoint(issueKey), bodyObject);
        }

        public virtual void putJiraTaskPriority(String taskKey, String taskPriorityName) {
            Map<String, Object> bodyObject = new Map<String, Object>{
                'fields' => new Map<String, Object> {
                    'priority' => new Map<String, Object> {
                        'name' => taskPriorityName
                    }
                }
            };
            putApiData(getIssueEndpoint(taskKey), bodyObject, 204);
        }

        public virtual JiraResourceWrapper getJiraAvailableResources() {
            JiraResourceWrapper result;
            String b = getApiData(JIRA_CLOUD_API_RESOURCES_ENDPOINT);
            List<JiraResourceWrapper> resp = (List<JiraResourceWrapper>)JSON.deserialize(b, List<JiraResourceWrapper>.class);
            result = (!resp?.isEmpty()) ? resp?.get(0) : null;
            return result;
        }

        public virtual List<JiraResourceWrapper> getJiraEndpoint() {
            List<JiraResourceWrapper> result = new List<JiraResourceWrapper>();
            String b = getApiData(ConfigUtil.JIRA_CLOUD_API_RESOURCES_ENDPOINT);
            result = (List<JiraResourceWrapper>)JSON.deserialize(b, List<JiraResourceWrapper>.class);
            return result;
        }

        public virtual List<JiraResourceWrapper> getJiraEndpoint(String token) {
            List<JiraResourceWrapper> result = new List<JiraResourceWrapper>();
            String b = getApiData(ConfigUtil.JIRA_CLOUD_API_RESOURCES_ENDPOINT,
                HttpUtils.getHeadersAuthorizationAcceptJson('Bearer ' + token));
            result = (List<JiraResourceWrapper>)JSON.deserialize(b, List<JiraResourceWrapper>.class);
            return result;
        }

        public virtual String getJiraIssueByKeyRaw(String taskKey, Logger logger) {
            String jiraIssueRaw;
            try {
                jiraIssueRaw = getApiData(getExpandedIssueEndpoint(taskKey));
            }
            catch(HttpUtils.HttpUtilsException e) {
                // catch and skip
                // 429, Jira API Request has been rate limited"
                // 404, Returned if the issue is not found or the user does not have permission to view it.
                if(!e?.getMessage()?.containsIgnoreCase('"code":429') 
                    && !e.getMessage()?.contains('404: ')) {
                    logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getJiraIssueByKeyRaw'));
                }
            }
            catch(Exception e) {
                logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getJiraIssueByKeyRaw'));
            }
            return jiraIssueRaw;
        }

        public virtual JiraIssue getJiraIssueByKey(String taskKey, Logger logger) {
            return getJiraIssueByKey(taskKey, logger, false);
        }

        public virtual JiraIssue getJiraIssueByKey(String taskKey, Logger logger, Boolean throwNotFoundException) {
            JiraIssue jiraIssue;
            try {
                String b = getApiData(getExpandedIssueEndpoint(taskKey));
                jiraIssue = (JiraIssue)JSON.deserialize(b, JiraIssue.class);
            }
            catch(HttpUtils.HttpUtilsException e) {
                if(throwNotFoundException && e.getMessage()?.contains('404: ')) {
                    throw e;
                }
                // catch and skip
                // 429, Jira API Request has been rate limited"
                // 404, Returned if the issue is not found or the user does not have permission to view it.
                if(!e?.getMessage()?.containsIgnoreCase('"code":429') 
                    && !e.getMessage()?.contains('404: ')) {
                    logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getJiraIssueByKey'));
                }
            }
            catch(Exception e) {
                if(throwNotFoundException && e.getMessage()?.contains('404: ')) {
                    throw e;
                }
                logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getJiraIssueByKey'));
            }
            return jiraIssue;
        }

        public virtual void linkIssuesAsRelates(String inwardIssueKey, String outwardIssueKey) {
            linkIssuesAsLinkType(inwardIssueKey, outwardIssueKey, LINK_ISSUE_TYPE_RELATES);
        }

        public virtual void linkIssuesAsDuplicates(String inwardIssueKey, String outwardIssueKey) {
            linkIssuesAsLinkType(inwardIssueKey, outwardIssueKey, LINK_ISSUE_TYPE_DUPLICATE);
        }

        private virtual void linkIssuesAsLinkType(String inwardIssueKey, String outwardIssueKey, String typeName) {
            Map<String, Object> bodyObject = new Map<String, Object>{
                'outwardIssue' => new Map<String, Object>{
                    'key' => outwardIssueKey
                },
                'inwardIssue' => new Map<String, Object>{
                    'key' => inwardIssueKey
                },
                'type' => new Map<String, Object>{
                    'name' => typeName
                }
            };
            postApiData(getLinkIssuesEndpoint(), bodyObject);
        }

        public virtual void unLinkIssue(String linkId) {
            deleteApiData(getUnLinkIssueEndpoint(linkId));
        }

        public virtual Map<String, DateTime> getResolutionDatetimeByTaskKey(List<String> taskKeys, Logger logger) {
            Map<String, DateTime> result = new Map<String, DateTime>();
    
            List<Object> issues = getBulkResolutionTasks(taskKeys, logger);
            if(!issues.isEmpty()) {
                for(Object issueObject : issues) {
                    try {
                        Map<String, Object> issue = (Map<String, Object>)issueObject;
                        String key = (String)issue.get(JIRA_API_JQL_ISSUE_KEY);
    
                        Map<String, Object> fields = (Map<String, Object>)issue.get(JIRA_API_JQL_ISSUE_FIELDS);
                        if(fields.containsKey(JIRA_API_JQL_ISSUE_RESOLUTION_DATE) && fields.get(JIRA_API_JQL_ISSUE_RESOLUTION_DATE) != null) {
                            String dateTimeString = String.valueOf(fields.get(JIRA_API_JQL_ISSUE_RESOLUTION_DATE));
                            DateTime resolutionDatetime = parseJiraDateTime(dateTimeString, logger);
    
                            result.put(key, resolutionDatetime);
                        }
                    }
                    catch(Exception e) {
                        logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getResolutionDatetimeByTaskKey'));
                    }
                }
            }
            return result;
        }
    
        public virtual List<Object> getBulkResolutionTasks(List<String> taskKeys, Logger logger) {
            List<Object> issues = new List<Object>();
            if(!taskKeys.isEmpty()) {
                try {
                    String b = getApiData(getBulkResolutionTasksEndpoint(taskKeys));
                    Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(b);
                    issues = (List<Object>)data.get(JIRA_API_JQL_ISSUES);
                }
                catch(HttpUtils.HttpUtilsException e) {
                    // catch and skip Jira API Request has been rate limited"
                    if(!e?.getMessage()?.containsIgnoreCase('"code":429')) {
                        logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getBulkResolutionTasks'));
                    }
                }
                catch(Exception e) {
                    logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getBulkResolutionTasks'));
                }
            }
            return issues;
        }
    }

    public class JiraService_CloudImpl extends JiraServiceDefaultImpl {
        
        public override String getProjectEndpoint(String projectOrKeyId) {
            return API_REST_BASE + API_PROJECT + projectOrKeyId + '?expand=projects.issuetypes.fields';
        }

        public override List<JiraPriorityScheme> getPrioritySchemes() {
            return null;
        }
    }

    public class JiraService_Hosted_9_4_14_Impl extends JiraServiceDefaultImpl {
        
        public override String getProjectsEndpoint() {
            return JIRA_API_URL + API_REST + API_VERSION + API_PROJECT;
        }

        public override String getPrioritiesEndpoint() {
            return JIRA_API_URL + API_REST + API_VERSION + API_PRIORITIES;
        }

        public override String getPrioritySchemesEndpoint() {
            return JIRA_API_URL + API_REST + API_VERSION + API_PRIORITY_SCHEMES;
        }

        public override List<JiraPriorityScheme> getPrioritySchemes() {
            return (!JIRA_PRIORITY_MAPPING?.isEmpty())
                ? JIRA_PRIORITY_MAPPING
                : super.getPrioritySchemes();
        }

        public override List<JiraProject> getProjects() {
            List<JiraProject> result = new List<JiraProject>();
            String b = getApiData(getProjectsEndpoint());
            result = deserializeProjects(b);
            return result;
        }

        public override List<JiraProject> deserializeProjects(String jsonData) {
            List<JiraProject> result = new List<JiraProject>();
            result = (List<JiraProject>)JSON.deserialize(jsonData, List<JiraProject>.class);
            return result;
        }

        public override List<JiraProjectIssueType> getProjectIssueTypes(String projectOrKeyId) {
            List<JiraProjectIssueType> result = new List<JiraProjectIssueType>();
            String b = getApiData(getProjectIssueTypesEndpoint(projectOrKeyId));
            JiraProjectIssueTypesWrapperValues wrapper = (JiraProjectIssueTypesWrapperValues)JSON.deserialize(b, JiraProjectIssueTypesWrapperValues.class);
            result = wrapper.values;
            removeJiraIssueTypes(result);
            return result;
        }

        public override String getProjectAssignableUsersEndpoint(String projectKey, String username) {
            String endpoint = API_REST_BASE + API_USER_SEARCH_BY_PROJECT + projectKey;
            if(String.isNotBlank(username)) {
                endpoint += '&username=' + EncodingUtil.urlEncode(username?.trim(), 'UTF-8');
            }
            return endpoint;
        }

        public override List<JiraProjectComponent> getProjectComponents(String projectOrKeyId, String query) {
            List<JiraProjectComponent> result = new List<JiraProjectComponent>();
            String b = getApiData(getProjectComponentsEndpoint(projectOrKeyId, null));
            result = (List<JiraProjectComponent>)JSON.deserialize(b, List<JiraProjectComponent>.class);
            return result;
        }
    }

    public class NewTaskCreatedResponse {
        public String id;
        public String key;
        public String self;
    }

    public class JQLResponse {
        public Integer total;
        public List<JiraIssue> issues;
    }

    public class JiraIssue {
        public String id;
        public String key;
        public String resolutiondate;
        public JiraIssueFields fields;
    }

    public class JiraIssueLink {
        public String id;
        public JiraIssueLinkType type;
        public JiraIssueOutwardInward outwardIssue;
        public JiraIssueOutwardInward inwardIssue;
    }

    public class JiraIssueOutwardInward {
        public String id;
        public String key;
        public String self;
        public JiraIssueOutwardInwardFields fields;
    }

    public class JiraIssueOutwardInwardFields {
        public JiraIssueOutwardInwardFieldsStatus status;
    }

    public class JiraIssueOutwardInwardFieldsStatus {
        public String iconUrl;
        public String name;
    }

    public class JiraIssueLinkType {
        public String id;
        public String name;
        public String inward;
        public String outward;
    }

    public class JiraIssueFields {
        public String summary;
        public JiraIssueStatus status;
        public JiraPriority priority;
        public List<JiraIssueLink> issuelinks;
    }

    public class JiraIssueStatus {
        public String id;
        public String name;
        public JiraIssueStatusCategory statusCategory;
    }

    public class JiraIssueStatusCategory {
        public String id;
        public String key;
    }

    public class JiraPriority {
        public String id;
        public String self;
        public String statusColor;
        public String description;
        public String iconUrl;
        public String name;
    }

    public class JiraPriorityScheme {
        public String id;
        public String self;
        public List<String> optionIds;
        public List<String> projectKeys;
        public String description;
        public String name;
    }

    public class JiraPrioritySchemeWrapper {
        public Integer startAt;
        public Integer maxResults;
        public Integer total;
        public List<JiraPriorityScheme> schemes;
    }

    public class JiraProjectList {
        public List<JiraProject> projects;
    }

    public class JiraProject {
        public String id;
        public String key;
        public String name;
        public List<JiraProjectIssueType> issueTypes;
    }

    public class JiraProjectIssueTypesWrapper {
        public Integer startAt;
        public Integer maxResults;
        public Integer total;
        public List<JiraProjectIssueType> issueTypes;
    }

    public class JiraProjectIssueTypesWrapperValues {
        public Integer startAt;
        public Integer maxResults;
        public Integer total;
        public List<JiraProjectIssueType> values;
    }

    public class JiraProjectIssueType {
        public String id;
        public String name;
        public Map<String, JiraProjectIssueField> fields;
    }

    public class JiraProjectIssueTypeFieldsWrapper {
        public Integer startAt;
        public Integer maxResults;
        public Integer total;
        // cloud version
        public List<JiraProjectIssueField> fields;
        // hosted version
        public List<JiraProjectIssueField> values;

        public List<JiraProjectIssueField> getFields() {
            return (this.fields != null && !this.fields.isEmpty()) ? this.fields : this.values;
        }
    }

    public class JiraProjectIssueField {
        // schema of the field
        public JiraProjectIssueFieldSchema schema;
        // allowed operations {set, add, remove}
        public List<String> operations;
        // allowed values
        public List<JiraProjectIssueFieldAllowedValue> allowedValues;

        public Boolean required;
        public String name;
        // api version 3
        public String key;
        // api version 2
        public String fieldId;
    }

    public class JiraProjectIssueFieldSchema {
        public String type;
        public String items;
        public String custom;
        public String customId;
    }

    public class JiraProjectIssueFieldAllowedValue {
        // "http://jira.teties.com/rest/api/2/customFieldOption/10100"
        public String self;
        // "true"
        public String value;
        // "10100"
        public String id;
        // false/true
        public Boolean disabled;
    }

    public class JiraProjectUser {
        public String accountId;
        public String key;
        public String name;
        public String emailAddress;
        public String displayName;
        public Boolean active;
    }

    public class JiraProjectComponentPaginatedResponse {
        public Boolean isLast;
        public Integer maxResults;
        public String nextPage;
        public String self;
        public Integer startAt;
        public Integer total;
        public List<JiraProjectComponent> values;
    }

    public class JiraProjectComponent {
        public String id;
        public String name;
        public String description;
    }

    public class JiraEpic {
        public String id;
        public String key;
        public JiraEpicFields fields;
    }

    public class JiraEpicFields {
        public String summary;
    }

    public class JiraResourceWrapper {
        public String id;
        public String url;
        public String name;
    }

    public static ConnectedOrgService.AuthTokenResponse getJiraAPIToken(String authCode, String clientId, String clientSecret, String endpoint) {
        Map<String, Object> body = new Map<String, Object>{
            'grant_type' => 'authorization_code',
            'client_id' => clientId,
            'client_secret' => clientSecret,
            'code' => authCode,
            'redirect_uri' => LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY
        };
        String b = HttpUtils.post(
            endpoint ,
            json.serialize(body),
            HttpUtils.getHeadersContentTypeJSON(),
            200
        );

        ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
        return resp;
    }

    public static ConnectedOrgService.AuthTokenResponse getJiraRefreshAPIToken(String refreshToken, String clientId, String clientSecret, String endpoint) {
        Map<String, Object> body = new Map<String, Object>{
            'grant_type' => 'refresh_token',
            'client_id' => clientId,
            'client_secret' => clientSecret,
            'refresh_token' => refreshToken
        };
        String b = HttpUtils.post(
            endpoint ,
            json.serialize(body),
            HttpUtils.getHeadersContentTypeJSON(),
            200
        );

        ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
        return resp;
    }

    public static final String JIRA_ROTATE_TOKEN_STATUS_COMPLETED = 'Completed';
    public class JiraManageTokens {

        public Boolean completed = false;

        public JiraManageTokens() {}

        public void flushSettings(Logger logger) {
            if(this.completed) {
                try {
                    GraphAPIService.saveListTokenRecordSettings(true, logger);
                }
                catch(Exception e) {
                    logger?.add(logger.getInternalError(e, null, JiraManageTokens.class.getName(), 'flushSettings'));
                }
            }
        }

        public Boolean isUnlocked(Logger logger) {
            String lockedJobId = getLockedJobId(logger);
            Boolean isUnlocked = String.isBlank(lockedJobId) || lockedJobId == JIRA_ROTATE_TOKEN_STATUS_COMPLETED;
            return isUnlocked;
        }

        public void rotateTokens(Logger logger, String asyncApexJobId) {
            rotateTokens(logger, asyncApexJobId, false);
        }

        public void rotateTokens(Logger logger, String asyncApexJobId, Boolean forceRefresh) {
            if(forceRefresh || (needRotateTokens() && !isJiraAccessTokenAvailable())) {
                try {
                    if(isUnlocked(logger)) {
                        setLockedJobId(asyncApexJobId, logger);
                        this.completed = validateAndRefreshJiraOauthToken(logger, false);
                        setLockedJobId(JIRA_ROTATE_TOKEN_STATUS_COMPLETED, logger);
                    }
                }
                catch(Exception e) {
                    logger?.add(logger.getInternalError(e, null, JiraManageTokens.class.getName(), 'rotateTokens'));
                }
            }
        }

        private void setLockedJobId(String asyncApexJobId, Logger logger) {
            try {
                String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
                Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
                if (isCacheAvailableForKey) {
                    CacheUtils.putCacheValue(keyCache, asyncApexJobId, CacheUtils.getTTLValue(CacheUtils.KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID));
                }
            }
            catch(Exception e) {
                logger?.add(logger.getInternalError(e, null, JiraManageTokens.class.getName(), 'setLockedJobId'));
            }
        }

        public String getLockedJobId(Logger logger) {
            String lockedJobId;
            try {
                String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
                Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
                if (isCacheAvailableForKey) {
                    Object cacheObject = CacheUtils.getCacheValue(keyCache);
                    if (cacheObject != null) {
                        lockedJobId = String.valueOf(cacheObject);
                    }
                }
            }
            catch(Exception e) {
                logger?.add(logger.getInternalError(e, null, JiraManageTokens.class.getName(), 'getLockedJobId'));
            }
            return lockedJobId;
        }

        private Boolean needRotateTokens() {
           return ConfigUtil.JIRA_SETTINGS.Jira_Username__c == JIRA_CLOUD_OAUTH_USERNAME;
        }

        private Boolean isJiraAccessTokenAvailable() {
            Boolean result = false;

            // reset settings
            JIRA_OAUTH_REFRESH_TOKEN = null;
            JIRA_OAUTH_TOKEN = null;

            try {
                JiraService.JiraResourceWrapper resources = JiraService.getInstance(null).strategy.getJiraAvailableResources();
                result = true;
            }
            catch(HttpUtils.HttpUtilsException e){
                result = false;
            }
            return result;
        }
    }

    public static final String JIRA_CLOUD_AUTHORIZE_ENDPOINT = 'https://auth.atlassian.com/authorize';
    public static final String JIRA_CLOUD_OAUTH_ENDPOINT = 'https://auth.atlassian.com/oauth/token';
    public static final String JIRA_CLOUD_SETTINGS_NAME = 'Jira';
    public static final String JIRA_CLOUD_OAUTH_USERNAME = 'oAuthUser';

    public static Boolean validateAndRefreshJiraOauthToken(Logger logger, Boolean withDML) {
        if (ConfigUtil.JIRA_SETTINGS.Jira_Username__c == JIRA_CLOUD_OAUTH_USERNAME) {
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(JIRA_CLOUD_SETTINGS_NAME);
            String clientId = mdtSettings.Client_Id__c;
            String clientSecret = mdtSettings.Client_Secret__c;
            String endpoint = JIRA_CLOUD_OAUTH_ENDPOINT;
            try {
                ConnectedOrgService.AuthTokenResponse refreshOauthToken = getJiraRefreshAPIToken(JIRA_OAUTH_REFRESH_TOKEN, clientId, clientSecret, endpoint);
                JiraService.putEncryptedJiraTokenToCache(logger, ConfigUtil.JIRA_SETTINGS, refreshOauthToken.access_token);

                JiraService.putApiTokenToSettings(refreshOauthToken.access_token, withDML, logger);
                JiraService.putApiRefreshTokenToSettings(refreshOauthToken.refresh_token, withDML, logger);
                return true;
            }
            catch(Exception e) {
                logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'getJiraRefreshAPIToken'));
            }
        }
        return false;
    }

    public static final String JIRA_API_TOKEN_TYPE_API_TOKEN = 'jira_api_token';
    public static final String JIRA_API_TOKEN_TYPE_REFRESH_TOKEN = 'jira_refresh_token';

    public static String getApiTokenFromSettings() {
        return GraphAPIService.getApiTokenValueFromSettings(JIRA_API_TOKEN_TYPE_API_TOKEN);
    }

    public static String getApiRefreshTokenFromSettings() {
        return GraphAPIService.getApiTokenValueFromSettings(JIRA_API_TOKEN_TYPE_REFRESH_TOKEN);
    }

    public static void putApiTokenToSettings(String token, Boolean withDML, Logger logger) {
        if(String.isNotBlank(token)) {
            GraphAPIService.upsertGraphAPITokenRecords(JIRA_API_TOKEN_TYPE_API_TOKEN, token, withDML, logger);
        }
    }

    public static void putApiRefreshTokenToSettings(String refreshToken, Boolean withDML, Logger logger) {
        if(String.isNotBlank(refreshToken)) {
            GraphAPIService.upsertGraphAPITokenRecords(JIRA_API_TOKEN_TYPE_REFRESH_TOKEN, refreshToken, withDML, logger);
        }
    }

    public static String getAlphanumericString(String input) {
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(input);
        String result = matcher.replaceAll('');
        return result;
    }

    public static String getJiraInstanceKey(String jiraInstance) {
        return EncodingUtil.base64Encode(Crypto.generateDigest('SHA3-256', Blob.valueOf(String.valueOf(jiraInstance))));
    }

    public static void putEncryptedJiraTokenToCache(Logger logger, Jira_Settings__c jiraSettings, String token) {
        try {
            if (String.isNotBlank(token) && String.isNotBlank(jiraSettings.Jira_API_Url__c)) {
                String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_JIRA_TOKEN, getAlphanumericString(jiraSettings.Jira_API_Url__c), '');
                Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_JIRA_TOKEN, keyCache);
                if (isCacheAvailableForKey) {
                    Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(getJiraInstanceKey(getAlphanumericString(jiraSettings.Jira_API_Url__c))), Blob.valueOf(token));
                    CacheUtils.putCacheValue(keyCache, encryptedToken, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_ENCRYPTED_JIRA_TOKEN));
                }
            }
        } catch (Exception e) {
            logger?.add(logger.getInternalError(e, jiraSettings.Jira_API_Url__c, JiraService.class.getName(), 'putEncryptedJiraTokenToCache'));
        }
    }

    public static String getDecryptedJiraTokenFromCache() {
        try {
            if(String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c)) {
                String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_JIRA_TOKEN, getAlphanumericString(ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c), '');
                Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_JIRA_TOKEN, keyCache);
                if (isCacheAvailableForKey) {
                    Object cacheObject = CacheUtils.getCacheValue(keyCache);
                    if (cacheObject != null) {
                        Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(getJiraInstanceKey(getAlphanumericString(ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c))), (Blob)cacheObject);
                        return decryptedToken.toString();
                    }
                }
            }
        }
        catch (Exception e) {
            Logger.getInstance().internalError(e, JiraService.JIRA_API_URL, true, ConnectedOrgService.class.getName(), 'getDecryptedJiraTokenFromCache');
        }
        return null;
    }


    public static final Set<String> SKIP_JIRA_ISSUE_TYPES = new Set<String>{'Epic','Sub-task','Subtask'};
    public static void removeJiraIssueTypes(JiraProject jp) {
        if(jp.issueTypes != null && !jp.issueTypes.isEmpty()) {
            for(Integer i = 0; i < jp.issueTypes.size(); i++) {
                if(SKIP_JIRA_ISSUE_TYPES.contains(jp.issueTypes.get(i).name)) {
                    jp.issueTypes.remove(i);
                }
            }
        }
    }

    public static void removeJiraIssueTypes(List<JiraProjectIssueType> issueTypes) {
        if(issueTypes != null && !issueTypes.isEmpty()) {
            for(Integer i = 0; i < issueTypes.size(); i++) {
                if(SKIP_JIRA_ISSUE_TYPES.contains(issueTypes.get(i).name)) {
                    issueTypes.remove(i);
                }
            }
        }
    }

    public static void validateConnectionToJiraSettings() {
        if (String.isBlank(JIRA_OAUTH_TOKEN)) {
            throw new JiraServiceException('JIRA token not found.');
        }
        else if (String.isBlank(ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c)) {
            throw new JiraServiceException('JIRA endpoint not found.');
        }
    }

    public static Boolean projectHasPriorityField(List<JiraService.JiraProjectIssueField> allFields) {
        for(JiraService.JiraProjectIssueField field : allFields) {
            if(field.name == 'priority') {
                return true;
            }
        }
        return false;
    }

    public static final Pattern JIRA_HASH_PATTERN = Pattern.compile('^[a-zA-Z0-9]{6}:[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$');
    public static Boolean isJiraHashId(String assignee) {
        Boolean result = false;
        Matcher m = JIRA_HASH_PATTERN.matcher(assignee);
        result = m.find();
        return result;
    }

    public static Boolean isCloudJiraInstance() {
        Boolean result = String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c)
            && ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c.startsWith('https://')
            && ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c.endsWith('.atlassian.net');
        return result;
    }

    public static String getIssueKeyByUrl(String taskUrl) {
        String taskKey = null;
        try {
            /* taskUrl example: https://goldenratio.atlassian.net/browse/PTD-2 */
            taskKey = taskUrl.split('/browse/')[1];
        } catch(Exception e) {
            throw new JiraServiceException('Invalid Jira Task URL: ' + String.valueOf(taskUrl));
        }
        return taskKey;
    }

    public static List<String> getJiraKeys(List<Log__c> logs, Logger logger) {
        Set<String> keys = new Set<String>();
        for(Log__c log : logs) {
            try {
                String taskKey = JiraService.getIssueKeyByUrl(log.Bug_Tracker__c);
                if(String.isNotBlank(taskKey)) {
                    keys.add(taskKey);
                }
            }
            catch(Exception e) {
                logger?.add(logger.getInternalError(e, log.Id, JiraService.class.getName(), 'getJiraKeys'));
            }
        }
        return new List<String>(keys);
    }

    // '2020-04-24T10:41:33.239-0700'
    public static final Pattern JIRA_DATE_TIME_PATTERN = Pattern.compile('(?i)(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).(\\d{3})([-+])(\\d{4})');

    public static DateTime parseJiraDateTime(String dateTimeString, Logger logger) {
        DateTime result = null;

        try {
            Pattern dt = JIRA_DATE_TIME_PATTERN;
            Matcher m = dt.matcher(dateTimeString);
            if (m.find()) {
                Integer year = Integer.valueOf(m.group(1));
                Integer month = Integer.valueOf(m.group(2));
                Integer day = Integer.valueOf(m.group(3));
                Integer hour = Integer.valueOf(m.group(4));
                Integer minute = Integer.valueOf(m.group(5));
                Integer second = Integer.valueOf(m.group(6));
                Integer mills = Integer.valueOf(m.group(7));
                String timeZone = m.group(8);
                String timeZoneHour = m.group(9).substring(0, 2);
                String timeZoneMinute = m.group(9).substring(2, 4);

                result = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
                if ('-' == timeZone) {
                    result = result.addHours(-Integer.valueOf(timeZoneHour));
                    result = result.addMinutes(-Integer.valueOf(timeZoneMinute));
                } else if ('+' == timeZone) {
                    result = result.addHours(Integer.valueOf(timeZoneHour));
                    result = result.addMinutes(Integer.valueOf(timeZoneMinute));
                }
            }
        }
        catch(Exception e) {
            logger?.add(logger.getInternalError(e, null, JiraService.class.getName(), 'parseJiraDateTime'));
        }
        return result;
    }

    public class JWTParser {
        public JWTHeader header;
        public JWTPayload payload;

        public JWTParser(String token) {
            if(String.isNotBlank(token)) {
                List<String> parts = token.split('\\.');
                if(!parts.isEmpty() && parts.size() == 3) {
                    try {
                        String header = EncodingUtil.base64Decode(parts.get(0)).toString();
                        this.header = (JWTHeader)JSON.deserialize(header, JWTHeader.class);
                    }
                    catch(Exception e){}
                    try {
                        String payload = EncodingUtil.base64Decode(parts.get(1)).toString();
                        this.payload = (JWTPayload)JSON.deserialize(payload, JWTPayload.class);
                    }
                    catch(Exception e){}
                }
            }
        }
    }

    public class JWTHeader {
        public String kid;
        public String alg;
    }

    public class JWTPayload {
        public String jti;
        public String sub;
        public Long nbf;
        public Long iat;
        public Long exp;
        public String aud;
    }

    // JIRA Field Transformer Plugin Pattern
    public interface JiraFieldTransformer {
        Object transform(String rawValue);
        JiraFieldValidationResult validateInput(String rawValue);
    }

    public class JiraFieldValidationResult {
        public Boolean isValid;
        public String errorMessage;

        public JiraFieldValidationResult(Boolean isValid, String errorMessage) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }

        public JiraFieldValidationResult(Boolean isValid) {
            this(isValid, null);
        }
    }

    // Base transformer class with common functionality
    public abstract class BaseJiraFieldTransformer implements JiraFieldTransformer {
        public abstract Object transform(String rawValue);

        public virtual JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Value cannot be blank');
            }
            return new JiraFieldValidationResult(true);
        }

        protected virtual String formatDateForJira(String rawValue, Boolean includeTime) {
            if (String.isBlank(rawValue)) {
                return null;
            }

            try {
                DateTime dt = null;

                // Try ISO format first (2023-04-13T19:03:25.153Z)
                if (rawValue.contains('T') && rawValue.contains('Z')) {
                    dt = (DateTime)JSON.deserialize('"' + rawValue + '"', DateTime.class);
                }
                // Try date only format (2023-04-13)
                else if (Pattern.matches('\\d{4}-\\d{2}-\\d{2}', rawValue)) {
                    List<String> parts = rawValue.split('-');
                    dt = DateTime.newInstance(
                        Integer.valueOf(parts[0]),
                        Integer.valueOf(parts[1]),
                        Integer.valueOf(parts[2])
                    );
                }
                // Try datetime format without timezone (2023-04-13 19:03:25)
                else if (rawValue.contains(' ') && rawValue.split(' ').size() == 2) {
                    String[] dateTimeParts = rawValue.split(' ');
                    String[] dateParts = dateTimeParts[0].split('-');
                    String[] timeParts = dateTimeParts[1].split(':');

                    if (dateParts.size() == 3 && timeParts.size() >= 2) {
                        Integer hour = Integer.valueOf(timeParts[0]);
                        Integer minute = Integer.valueOf(timeParts[1]);
                        Integer second = timeParts.size() > 2 ? Integer.valueOf(timeParts[2]) : 0;

                        dt = DateTime.newInstance(
                            Integer.valueOf(dateParts[0]),
                            Integer.valueOf(dateParts[1]),
                            Integer.valueOf(dateParts[2]),
                            hour, minute, second
                        );
                    }
                }

                if (dt != null) {
                    if (includeTime) {
                        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'+0000\'');
                    } else {
                        return dt.formatGmt('yyyy-MM-dd');
                    }
                }

            } catch (Exception e) {
                // Return null if parsing fails
            }

            return rawValue; // Return original if all parsing fails
        }
    }

    // Multi-checkbox transformer
    public class MultiCheckboxTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            List<String> values = rawValue.split(',');
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String value : values) {
                if (String.isNotBlank(value?.trim())) {
                    result.add(new Map<String, String>{'id' => value.trim()});
                }
            }
            return result;
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Multi-checkbox value cannot be blank');
            }

            List<String> values = rawValue.split(',');
            for (String value : values) {
                if (String.isBlank(value?.trim())) {
                    return new JiraFieldValidationResult(false, 'Multi-checkbox contains empty values');
                }
            }
            return new JiraFieldValidationResult(true);
        }
    }

    // Multi-select transformer
    public class MultiSelectTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            List<String> values = rawValue.split(',');
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String value : values) {
                if (String.isNotBlank(value?.trim())) {
                    result.add(new Map<String, String>{'id' => value.trim()});
                }
            }
            return result;
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Multi-select value cannot be blank');
            }

            List<String> values = rawValue.split(',');
            for (String value : values) {
                if (String.isBlank(value?.trim())) {
                    return new JiraFieldValidationResult(false, 'Multi-select contains empty values');
                }
            }
            return new JiraFieldValidationResult(true);
        }
    }

    // Select transformer
    public class SelectTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return new Map<String, String>{'id' => rawValue};
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Select value cannot be blank');
            }
            return new JiraFieldValidationResult(true);
        }
    }

    // Radio button transformer
    public class RadioButtonTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return new Map<String, String>{'id' => rawValue};
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Radio button value cannot be blank');
            }
            return new JiraFieldValidationResult(true);
        }
    }

    // Date picker transformer
    public class DatePickerTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return formatDateForJira(rawValue, false);
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Date value cannot be blank');
            }

            // Validate date format
            if (!Pattern.matches('\\d{4}-\\d{2}-\\d{2}', rawValue) &&
                !rawValue.contains('T') &&
                !rawValue.contains(' ')) {
                return new JiraFieldValidationResult(false, 'Invalid date format. Expected: YYYY-MM-DD, YYYY-MM-DD HH:mm:ss, or ISO format');
            }

            return new JiraFieldValidationResult(true);
        }
    }

    // DateTime transformer
    public class DateTimeTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return formatDateForJira(rawValue, true);
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'DateTime value cannot be blank');
            }

            // Validate datetime format
            if (!rawValue.contains('T') &&
                !rawValue.contains(' ') &&
                !Pattern.matches('\\d{4}-\\d{2}-\\d{2}', rawValue)) {
                return new JiraFieldValidationResult(false, 'Invalid datetime format. Expected: YYYY-MM-DD HH:mm:ss, YYYY-MM-DD, or ISO format');
            }

            return new JiraFieldValidationResult(true);
        }
    }

    // Number transformer
    public class NumberTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            try {
                return Decimal.valueOf(rawValue);
            } catch (Exception e) {
                return rawValue; // Fallback to string if not numeric
            }
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'Number value cannot be blank');
            }

            try {
                Decimal.valueOf(rawValue);
                return new JiraFieldValidationResult(true);
            } catch (Exception e) {
                return new JiraFieldValidationResult(false, 'Invalid number format: ' + rawValue);
            }
        }
    }

    // Text area transformer
    public class TextAreaTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return rawValue;
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            // Text areas can be blank, so just return true
            return new JiraFieldValidationResult(true);
        }
    }

    // Text field transformer
    public class TextFieldTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return rawValue;
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            // Text fields can be blank, so just return true
            return new JiraFieldValidationResult(true);
        }
    }

    // URL transformer
    public class UrlTransformer extends BaseJiraFieldTransformer {
        public override Object transform(String rawValue) {
            return rawValue;
        }

        public override JiraFieldValidationResult validateInput(String rawValue) {
            if (String.isBlank(rawValue)) {
                return new JiraFieldValidationResult(false, 'URL value cannot be blank');
            }

            // Basic URL validation
            if (!rawValue.startsWith('http://') && !rawValue.startsWith('https://')) {
                return new JiraFieldValidationResult(false, 'URL must start with http:// or https://');
            }

            return new JiraFieldValidationResult(true);
        }
    }
}