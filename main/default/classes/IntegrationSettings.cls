public with sharing class IntegrationSettings {

    public enum JIRA_FORM_TYPE { CLOUD, API, PAT, SETTINGS }

    public static final AzureDevOps AZURE_DEVOPS {
        get { return AZURE_DEVOPS == null ? (AZURE_DEVOPS = new AzureDevOps()) : AZURE_DEVOPS; }
        private set;
    }

    public static final GitHub GIT_HUB {
        get { return GIT_HUB == null ? (GIT_HUB = new GitHub()) : GIT_HUB; }
        private set;
    }
    
    public static final Jira JIRA {
        get { return JIRA == null ? (JIRA = new Jira()) : JIRA; }
        private set;
    }

    public static final OpenAISettingsService OPEN_AI {
        get { return OPEN_AI == null ? (OPEN_AI = new OpenAISettingsService()) : OPEN_AI; }
        private set;
    }

    public static final PagerDuty PAGER_DUTY {
        get { return PAGER_DUTY == null ? (PAGER_DUTY = new PagerDuty()) : PAGER_DUTY; }
        private set;
    }

    public static final Slack SLACK {
        get { return SLACK == null ? (SLACK = new Slack()) : SLACK; }
        private set;
    }

    public static final Splunk SPLUNK {
        get { return SPLUNK == null ? (SPLUNK = new Splunk()) : SPLUNK; }
        private set;
    }

    public static final Teams TEAMS {
        get { return TEAMS == null ? (TEAMS = new Teams()) : TEAMS; }
        private set;
    }

    public class AzureDevOps {
        public AzureDevOpsSettings getAzureDevOpsSettings() {
            AzureDevOpsSettings azureDevOpsSettings = new AzureDevOpsSettings(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS);
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(AzureService.AZURE_DEVOPS_API_SETTINGS_NAME);
            if (mdtSettings != null) {
                HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, 'Assertion');
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
                bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, mdtSettings.Extended_Scope__c);

                Map<String, Object> state = new Map<String, Object>{
                    'redirectUrl' => ConfigUtil.URL_VF_CALLBACK_PAGE_SETTINGS,
                    'isAzureDevOps' => true
                };

                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_STATE, EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state))));
                azureDevOpsSettings.oAuthEndpoint = AzureService.AZURE_DEVOPS_API_AUTHORIZE_ENDPOINT + bodyParams.toStringParameters('?');
                
                try {
                    AzureService.AzureDevOpsMyProfile myProfile = AzureService.getMyProfile(AzureService.OAUTH_API_TOKEN);
                    azureDevOpsSettings.isConnectionValid = true;
                } catch(Exception e) {
                    azureDevOpsSettings.isConnectionValid = false;
                }
                
            }
            return azureDevOpsSettings;
        }

        public String saveAzureDevOpsSettings(Object azureSettingsObject) {
            AzureDevOpsSettings azureSettings = (AzureDevOpsSettings)JSON.deserialize(JSON.serialize(azureSettingsObject), AzureDevOpsSettings.class);

            if (azureSettings.autoJiraTaskLabelsFromHashes != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Generate_Similarity_Labels__c = azureSettings.autoJiraTaskLabelsFromHashes;
            }
            if (azureSettings.autoRelateTicketsWithSimilarErrors != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c = azureSettings.autoRelateTicketsWithSimilarErrors;
            }
            if (azureSettings.createUniqueTicketsByOrg != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Create_Unique_Tickets_by_Org__c = azureSettings.createUniqueTicketsByOrg;
            }
            if (azureSettings.automaticallyUpdateIssuePriority != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c = azureSettings.automaticallyUpdateIssuePriority;
            }
            if (azureSettings.automaticallyUpdateTicketPriority != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c = azureSettings.automaticallyUpdateTicketPriority;
            }
            if (azureSettings.synchronizeCompletedStatus != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c = azureSettings.synchronizeCompletedStatus;
            }
            if (azureSettings.synchronizeDuplicateTicketsAndIssues != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c = azureSettings.synchronizeDuplicateTicketsAndIssues;
            }
            if (azureSettings.synchronizeRelatedTicketsAndIssues != null) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c = azureSettings.synchronizeRelatedTicketsAndIssues;
            }

            DatabaseUtils.getInstance().performUpsertDML(new List<Azure_Dev_Ops_API_Settings__c>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS}, Schema.SObjectType.Azure_Dev_Ops_API_Settings__c, true);

            return Constants.UI.RESULT_SUCCESS;
        }

        public String resetAzureDevOpsSettings() {
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c = null;
            
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Generate_Similarity_Labels__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Create_Unique_Tickets_by_Org__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c = false;
            ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c = false;

            DatabaseUtils.getInstance().performUpsertDML(new List<Azure_Dev_Ops_API_Settings__c>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS}, Schema.SObjectType.Azure_Dev_Ops_API_Settings__c, true);

            GraphAPIService.upsertGraphAPITokenRecords(GraphAPIService.AZURE_DEVOPS_API_TOKEN_TYPE_API_TOKEN, '', false, Logger.getInstance());
            GraphAPIService.upsertGraphAPITokenRecords(GraphAPIService.AZURE_DEVOPS_API_TOKEN_TYPE_REFRESH_TOKEN, '', true, Logger.getInstance());

            return Constants.UI.RESULT_SUCCESS;
        }
    }

    public class GitHub {
        public final String GIT_API_REPOSITORY_NAME_NOT_FOUND = 'Repository name not found';
        public final String GIT_API_BRANCH_NAME_NOT_FOUND = 'Branch name not found';

        public GitHubSettings resetGitHubSettings() {
            ConfigUtil.GIT_API_SETTINGS.Token__c = null;
            ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c = null;
            ConfigUtil.GIT_API_SETTINGS.Username__c = null;
            ConfigUtil.GIT_API_SETTINGS.Reponame__c = null;
            ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = null;
            ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = null;
            DatabaseUtils.getInstance().performUpsertDML(new List<Git_API_Settings__c>{ConfigUtil.GIT_API_SETTINGS}, Schema.SObjectType.Git_API_Settings__c, true);
            return getGitHubSettings();
        }

        public GitHubSettings setGitHubSettings(Object data) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            if (input.get('enabled') != null) {
                ConfigUtil.GIT_API_SETTINGS.Enabled__c = Boolean.valueOf(input.get('enabled'));
            }
            ConfigUtil.GIT_API_SETTINGS.Token__c = input.get('apiToken') != null ? String.valueOf(input.get('apiToken')) : null;
            String newBranchName = input.get('branchName') != null ? String.valueOf(input.get('branchName')) : null;
            String repositoryUrl = input.get('repositoryUrl') != null ? String.valueOf(input.get('repositoryUrl')) : null;
            List<String> ownerRepo = GitHubUtils.getOwnerAndRepositoryNameFromUrl(repositoryUrl);
            String newOwner = ownerRepo.get(0);
            String newRepoName = ownerRepo.get(1);

            if (this.isNewRepoNameOrBranchName(newRepoName, newBranchName)) {
                ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = null;
            }

            ConfigUtil.GIT_API_SETTINGS.Reponame__c = newRepoName;
            ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = newBranchName;
            ConfigUtil.GIT_API_SETTINGS.Username__c = newOwner;

            // validate repository name and related branch name
            String reponameError;
            String branchNameError;
            if (String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Username__c) && String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Reponame__c)) {
                try {
                    List<GitHubUtils.GitReposInfo> repos = GitHubUtils.getReposInfos(ConfigUtil.GIT_API_SETTINGS.Username__c, ConfigUtil.GIT_API_SETTINGS.Reponame__c);
                    System.assert(String.isNotBlank(repos.get(0).name));
                } catch(Exception e) {
                    reponameError = GIT_API_REPOSITORY_NAME_NOT_FOUND;
                    ConfigUtil.GIT_API_SETTINGS.Reponame__c = null;
                    ConfigUtil.GIT_API_SETTINGS.Username__c = null;
                }
            }
            else {
                reponameError = GIT_API_REPOSITORY_NAME_NOT_FOUND;
                ConfigUtil.GIT_API_SETTINGS.Reponame__c = null;
                ConfigUtil.GIT_API_SETTINGS.Username__c = null;
            }
            if (String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Username__c) && String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Branch_Name__c)) {
                try {
                    List<GitHubUtils.GitRepoBranchInfo> branches = GitHubUtils.getRepoBranchesInfos(newOwner, ConfigUtil.GIT_API_SETTINGS.Reponame__c, ConfigUtil.GIT_API_SETTINGS.Branch_Name__c);
                    System.assert(String.isNotBlank(branches.get(0).name));
                } catch(Exception e) {
                    branchNameError = GIT_API_BRANCH_NAME_NOT_FOUND;
                }
            }
            if (String.isNotBlank(reponameError) || String.isNotBlank(branchNameError)) {
                GitHubSettings settings = getGitHubSettings();
                settings.reponameError = reponameError;
                settings.branchNameError = branchNameError;
                return settings;
            }

            DatabaseUtils.getInstance().performUpsertDML(new List<Git_API_Settings__c>{ConfigUtil.GIT_API_SETTINGS}, Schema.SObjectType.Git_API_Settings__c, true);
            return getGitHubSettings();
        }

        public GitHubSettings getGitHubSettings() {
            GitHubSettings gitSettings = new GitHubSettings(ConfigUtil.GIT_API_SETTINGS);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GitHubUtils.GIT_API_SETTINGS_NAME);
            if (mdtSettings != null) {
                HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
                bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, mdtSettings.Scope__c);

                Map<String, Object> state = new Map<String, Object>{
                    'redirectUrl' => ConfigUtil.URL_VF_CALLBACK_PAGE_SETTINGS,
                    'isGitAPI' => true
                };

                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_STATE, EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state))));
                gitSettings.oAuthEndpoint = GitHubUtils.GIT_API_AUTHORIZE_ENDPOINT + bodyParams.toStringParameters('?');
            }
            return gitSettings;
        }

        private Boolean isNewRepoNameOrBranchName(String newRepoName, String newBranchName) {
            return ConfigUtil.GIT_API_SETTINGS.Reponame__c != newRepoName || ConfigUtil.GIT_API_SETTINGS.Branch_Name__c != newBranchName;
        }
    }

    public class Jira {

        public final String ERROR_MESSAGE_JIRA_CONNECTION_COULD_NOT_BE_ESTABLISHED = 
            'Jira connection could not be established, please check the Logs tab for more details. Or add a custom priority mapping via custom settings.';
        public final String ERROR_MESSAGE_JIRA_TOKEN_IS_EMPTY_OR_INVALID = 'Jira Token is empty or invalid';

        public JIRA_FORM_TYPE getFormType(Object jiraSettingsObject) {
            Map<String, Object> obj = (Map<String, Object>)jiraSettingsObject;
            if (obj.containsKey('apiform') && obj.containsKey('baseUrl') && obj.containsKey('apiToken') && obj.containsKey('username')) {
                return JIRA_FORM_TYPE.API;
            }
            if (obj.containsKey('apiform') && obj.containsKey('baseUrl') && obj.containsKey('apiToken')) {
                return JIRA_FORM_TYPE.PAT;
            }
            if (obj.containsKey('cloudform')) {
                return JIRA_FORM_TYPE.CLOUD;
            }
            if (!obj.containsKey('cloudform') && !obj.containsKey('apiform') && obj.containsKey('autoJiraTaskLabelsFromHashes')) {
                return JIRA_FORM_TYPE.SETTINGS;
            }
            return null;
        }

        public String saveJiraSettings(Object jiraSettingsObject) {
            JiraSettings jiraSettings = (JiraSettings)JSON.deserialize(JSON.serialize(jiraSettingsObject), JiraSettings.class);
            switch on this.getFormType(jiraSettingsObject) {
                when API, PAT {
                    if (jiraSettings?.username == JiraService.JIRA_CLOUD_OAUTH_USERNAME) {
                        jiraSettings.username = '';
                        jiraSettings.apiToken = '';
                    }
                    if (jiraSettings?.apiToken?.length() > 255) {
                        jiraSettings.apiToken = jiraSettings.apiToken.abbreviate(255);
                    }
                    if (String.isNotBlank(jiraSettings.username) && jiraSettings.username != ConfigUtil.JIRA_SETTINGS.Jira_Username__c) {
                        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = jiraSettings.username;
                    }
                    if (String.isBlank(jiraSettings?.username) && String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Username__c)) {
                        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = jiraSettings?.username;
                    }
                    if (String.isNotBlank(jiraSettings.apiToken) && jiraSettings.apiToken != ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c) {
                        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = jiraSettings.apiToken;
                    }
                    if (String.isNotBlank(jiraSettings.baseUrl) && jiraSettings.baseUrl != ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c) {
                        jiraSettings.baseUrl = jiraSettings.baseUrl?.endsWith('/') 
                            ? jiraSettings.baseUrl.removeEnd('/')
                            : jiraSettings.baseUrl;
                        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = jiraSettings.baseUrl;
                        // TODO: Change after refactroing
                        AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.JIRA_NAME, jiraSettings.baseUrl, Constants.REMOTE_SITE_SETTINGS.JIRA_DESCRIPTION);
                    }
                }
                when SETTINGS {
                    if (jiraSettings.autoJiraTaskLabelsFromHashes != null) {
                        ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c = jiraSettings.autoJiraTaskLabelsFromHashes;
                    }
                    if (jiraSettings.autoRelateTicketsWithSimilarErrors != null) {
                        ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c = jiraSettings.autoRelateTicketsWithSimilarErrors;
                    }
                    if (jiraSettings.createUniqueTicketsByOrg != null) {
                        ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c = jiraSettings.createUniqueTicketsByOrg;
                    }
                    if (jiraSettings.automaticallyUpdateIssuePriority != null) {
                        ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c = jiraSettings.automaticallyUpdateIssuePriority;
                    }
                    if (jiraSettings.automaticallyUpdateTicketPriority != null) {
                        ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c = jiraSettings.automaticallyUpdateTicketPriority;
                    }
                    if (jiraSettings.synchronizeCompletedStatus != null) {
                        ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c = jiraSettings.synchronizeCompletedStatus;
                    }
                    if (jiraSettings.synchronizeDuplicateTicketsAndIssues != null) {
                        ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c = jiraSettings.synchronizeDuplicateTicketsAndIssues;
                    }
                    if (jiraSettings.synchronizeRelatedTicketsAndIssues != null) {
                        ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c = jiraSettings.synchronizeRelatedTicketsAndIssues;
                    }
                }
                when CLOUD {}
            }

            JiraSettings validationCalls = this.validateJiraSetting(true, jiraSettings);

            DatabaseUtils.getInstance().performUpsertDML(new List<Jira_Settings__c>{ConfigUtil.JIRA_SETTINGS}, Schema.SObjectType.Jira_Settings__c, true);

            return Constants.UI.RESULT_SUCCESS;
        }

        public JiraSettings validateJiraSetting(Boolean throwError, JiraSettings jiraSettings) {
            ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = jiraSettings.baseUrl;
            ConfigUtil.JIRA_SETTINGS.Jira_Username__c = jiraSettings.username;
            if (ConfigUtil.JIRA_SETTINGS.Jira_Username__c != JiraService.JIRA_CLOUD_OAUTH_USERNAME) {
                ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = jiraSettings.apiToken;
            }

            if (ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c != null
                && String.isNotBlank(JiraService.JIRA_OAUTH_TOKEN)) {
                try {
                    // recalculate endpoint and call service
                    JiraService.JIRA_API_URL = null;
                    
                    JiraService.JiraServiceInterface service = JiraService.getService(true);
                    JiraService.validateConnectionToJiraSettings();
                    jiraSettings.projects = service.getProjects();
                    jiraSettings.priorities = service.getPriorities();
                    jiraSettings.prioritySchemes = service.getPrioritySchemes();
                    jiraSettings.isConnectionValid = true;
                }
                catch(Exception e) {
                    if (throwError) {
                        Log__c errorLog = Logger.getInstance().getInternalError(e, null, AdminService.class.getName(), 'validateJiraSetting');
                        errorLog.Summary__c = ('Failed Jira Authentication: ' + errorLog.Summary__c).abbreviate(Constants.GLOBAL_VARIABLE.TEXT_FIELD_MAX_LENGTH);
                        Logger.getInstance().internalError(errorLog, true);
                        throw new IntegrationSettingsException(ERROR_MESSAGE_JIRA_CONNECTION_COULD_NOT_BE_ESTABLISHED);
                    }
                    else {
                        jiraSettings.connectionErrorMessage = e.getMessage();
                        jiraSettings.isConnectionValid = false;
                        Logger.getInstance().internalError(e, null, true, AdminService.class.getName(), 'validateJiraSetting');
                    }
                }
            }
            else {
                if (throwError) {
                    throw new IntegrationSettingsException(ERROR_MESSAGE_JIRA_TOKEN_IS_EMPTY_OR_INVALID);
                }
                jiraSettings.isConnectionValid = false;
            }
            return jiraSettings;
        }

        public JiraSettings getJiraSettings() {
            JiraSettings jiraSettings = validateJiraSetting(false, new JiraSettings(ConfigUtil.JIRA_SETTINGS));

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance('Jira');
            if (mdtSettings != null) {
                HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
                bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, mdtSettings.Scope__c);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, HttpUtils.HTTP_URL_PARAM_CODE);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_PROMPT, HttpUtils.HTTP_URL_PARAM_PROMPT_CONSENT);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_AUDIENCE, HttpUtils.HTTP_URL_PARAM_AUDIENCE_JIRA_API);

                Map<String, Object> state = new Map<String, Object>{
                    'redirectUrl' => System.Url.getOrgDomainUrl().toExternalForm() + '/apex/' + ConfigUtil.getNameSpacePrefix() + 'Settings',
                    'isJira' => true
                };

                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_STATE, EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state))));
                jiraSettings.oAuthEndpoint = JiraService.JIRA_CLOUD_AUTHORIZE_ENDPOINT + bodyParams.toStringParameters('?');
            }

            return jiraSettings;
        }

        public String resetJiraSettings() {
            ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c = null;
            ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = null;
            ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = null;
            ConfigUtil.JIRA_SETTINGS.Jira_Username__c = null;
            ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c = false;
            ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c = false;
            ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c = false;
            ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c = false;
            ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c = false;
            ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c = false;
            ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c = false;
            ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c = false;

            DatabaseUtils.getInstance().performUpsertDML(new List<Jira_Settings__c>{ConfigUtil.JIRA_SETTINGS}, Schema.SObjectType.Jira_Settings__c, true);

            GraphAPIService.upsertGraphAPITokenRecords(JiraService.JIRA_API_TOKEN_TYPE_API_TOKEN, '', false, Logger.getInstance());
            GraphAPIService.upsertGraphAPITokenRecords(JiraService.JIRA_API_TOKEN_TYPE_REFRESH_TOKEN, '', true, Logger.getInstance());

            return Constants.UI.RESULT_SUCCESS;
        }
    }

    // TODO: Rename after delete the OpenAI class from the package
    public class OpenAISettingsService {
        public OpenAISettings getOpenAISettings() {
            OpenAISettings openAISettings = new OpenAISettings(ConfigUtil.OPEN_AI_SETTINGS);
            return openAISettings;
        }

        public OpenAISettings setOpenAISettings(Object data) {
            OpenAISettings input = (OpenAISettings)JSON.deserialize(JSON.serialize(data), OpenAISettings.class);
            ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = input.enabled;
            ConfigUtil.OPEN_AI_SETTINGS.Token__c = input.token;
            if (ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c) {
                // TODO: Change after refactroing
                AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.AI_NAME, Constants.REMOTE_SITE_SETTINGS.AI_URL, Constants.REMOTE_SITE_SETTINGS.AI_DESCRIPTION);
                // TODO: Change after refactroing
                AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.OPEN_AI_NAME, Constants.REMOTE_SITE_SETTINGS.OPEN_AI_URL, Constants.REMOTE_SITE_SETTINGS.OPEN_AI_DESCRIPTION);
            }
            DatabaseUtils.getInstance().performUpsertDML(new List<OpenAI_Settings__c>{ConfigUtil.OPEN_AI_SETTINGS}, Schema.SObjectType.OpenAI_Settings__c, true);
            return getOpenAISettings();
        }

        public Map<String, Boolean> validateOpenAIToken(Object data) {
            OpenAISettings input = (OpenAISettings)JSON.deserialize(JSON.serialize(data), OpenAISettings.class);
            return new Map<String, Boolean>{
                'isValid' => OpenAI.validateToken(input.token)
            };
        }
    }

    public class PagerDuty {

        public PagerDutySettings getPagerDutySettings() {
            PagerDutySettings settings = new PagerDutySettings(ConfigUtil.PAGER_DUTY_SETTINGS);
            try {
                getPagerDutyServices();
                settings.isConnectionValid = true;
            }
            catch(Exception e) {
                settings.isConnectionValid = false;
            }
            return settings;
        }

        public List<Object> getPagerDutyServices() {
            return PagerDutyService.getServices();
        }

        public String savePagerDutySettings(Object payload) {

            PagerDutySettings pdSettings = (PagerDutySettings)JSON.deserialize(JSON.serialize(payload), PagerDutySettings.class);

            if (String.isNotBlank(pdSettings.token) && pdSettings.token != ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c) {
                ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c = pdSettings.token;
            }
            ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c = pdSettings.enabled;
            ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_ID__c = pdSettings.serviceId;
            ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_Integration_Key__c = pdSettings.serviceIntegrationKey;
            ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_User_Email__c = pdSettings.userEmail;
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_API_NAME, Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_URL, Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_DESCRIPTION);
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_EVENT_API_NAME, Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_EVENT_URL, Constants.REMOTE_SITE_SETTINGS.PAGER_DUTY_EVENT_DESCRIPTION);
            DatabaseUtils.getInstance().performUpsertDML(new List<Pager_Duty_Settings__c>{ConfigUtil.PAGER_DUTY_SETTINGS}, Schema.SObjectType.Pager_Duty_Settings__c, true);
            return Constants.UI.RESULT_SUCCESS;
        }
    }

    public class Slack {

        public SlackSettings getSlackSettings() {
            String defaultTemplate = (String.isNotBlank(ConfigUtil.SLACK_SETTINGS.Slack_Message_Template__c))
                ? ConfigUtil.SLACK_SETTINGS.Slack_Message_Template__c
                : ConfigUtil.SLACK_DEFAULT_MESSAGE_TEMPLATE;

            SlackSettings settings = new SlackSettings(ConfigUtil.SLACK_SETTINGS, defaultTemplate);
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance('Slack');
            String clientId = (String.isNotBlank(ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Id__c))
                    ? ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Id__c
                    : mdtSettings.Client_Id__c;
            if (mdtSettings != null) {
                HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, clientId);
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_SCOPE, mdtSettings.Scope__c);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);

                Map<String, Object> state = new Map<String, Object>{
                    'redirectUrl' => System.Url.getOrgDomainUrl().toExternalForm() + '/apex/' + ConfigUtil.getNameSpacePrefix() + 'Settings',
                    'isSlack' => true
                };

                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_STATE, EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state))));
                settings.oAuthEndpoint = ConfigUtil.SLACK_AUTHORIZE_URL_V2 + bodyParams.toStringParameters('?');

                try {
                    SlackService.SlackUsersResponse user = SlackService.getUsers(null);
                    settings.isConnectionValid = true;
                }
                catch(Exception e) {
                    settings.isConnectionValid = false;
                }
            }
            return settings;
        }

        public Object getSlackChannels(Object cursor) {
            return SlackService.getChannels(String.valueOf(cursor));
        }

        public Object getSlackUsers(Object cursor) {
            return SlackService.getUsers(String.valueOf(cursor));
        }

        public String saveSlackSettings(Object payload) {
            SlackSettings slackSettings = (SlackSettings)JSON.deserialize(JSON.serialize(payload), SlackSettings.class);
            ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c = slackSettings.slackEnabled;
            if (String.isNotBlank(slackSettings.slackToken) && slackSettings.slackToken != ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c) {
                ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c = slackSettings.slackToken;
            }
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.SLACK_API_NAME, Constants.REMOTE_SITE_SETTINGS.SLACK_API_URL, Constants.REMOTE_SITE_SETTINGS.SLACK_DESCRIPTION);
            DatabaseUtils.getInstance().performUpsertDML(new List<Slack_Settings__c>{ConfigUtil.SLACK_SETTINGS}, Schema.SObjectType.Slack_Settings__c, true);

            return Constants.UI.RESULT_SUCCESS;
        }
    }

    public class Splunk {
        public SplunkSettings getSplunkSettings() {
            SplunkSettings splunkSettings = new SplunkSettings(ConfigUtil.SPLUNK_SETTINGS);
            List<String> availableSplunkFields = ConfigUtil.getAvailableSplunkFields();

            SObjectType logType = ConfigUtil.MAP_GD.get(Log__c.getSObjectType().getDescribe().getName());
            Map<String,Schema.SObjectField> mfields = logType.getDescribe().fields.getMap();

            List<Map<String, String>> fieldsProcessed = new List<Map<String, String>>();
            for (String k : availableSplunkFields) {
                fieldsProcessed.add(new Map<String, String>{
                    ConfigUtil.PICKLIST_KEY_NAME => mfields.get(k).getDescribe().getName(),
                    ConfigUtil.PICKLIST_KEY_LABEL => mfields.get(k).getDescribe().getLabel()
                });
            }
            splunkSettings.logFields = fieldsProcessed;
            splunkSettings.config = SplunkService.getLogFieldsForSplunk();
            return splunkSettings;
        }

        public Boolean validateSplunkEventCollectorConnection(Object indataObj) {
            // TODO: Revisit, plan settings
            // Map<String, Object> indata = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(indataObj));
            // SplunkService.sendLog(new List<Log__c>{new Log__c(Summary__c = 'Test Log Message From "Pharos" App.')});
            return true;
        }

        public SplunkSettings saveSplunkSettings(Object splunkSettingsObject) {
            SplunkSettings indata = (SplunkSettings)JSON.deserialize(JSON.serialize(splunkSettingsObject), SplunkSettings.class);
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.SPLUNK_WEB_NAME, indata.url, Constants.REMOTE_SITE_SETTINGS.SPLUNK_WEB_DESCRIPTION);
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.SPLUNK_API_NAME, indata.url + Constants.REMOTE_SITE_SETTINGS.SPLUNK_API_PORT, Constants.REMOTE_SITE_SETTINGS.SPLUNK_API_DESCRIPTION);
            // TODO: Change after refactroing
            AdminService.upsertRemoteSiteSetting(Constants.REMOTE_SITE_SETTINGS.SPLUNK_EVENT_COLLECTOR_NAME, indata.url + Constants.REMOTE_SITE_SETTINGS.SPLUNK_EVENT_COLLECTOR_PORT, Constants.REMOTE_SITE_SETTINGS.SPLUNK_EVENT_COLLECTOR_DESCRIPTION);
            ConfigUtil.SPLUNK_SETTINGS.Splunk_Enabled__c = indata.enabled;
            ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c = indata.url;
            ConfigUtil.SPLUNK_SETTINGS.Splunk_Token__c= indata.token;
            ConfigUtil.SPLUNK_SETTINGS.Splunk_Event_Collector_Token__c= indata.ecToken;
            DatabaseUtils.getInstance().performUpsertDML(new List<Splunk_Settings__c>{ConfigUtil.SPLUNK_SETTINGS}, Schema.SObjectType.Splunk_Settings__c, true);

            ConfigUtil.setSplunkFields(indata.config);
            ConfigUtil.initSplunkFields();
            ConfigUtil.initSplunkSettings();

            return getSplunkSettings();
        }

        public SplunkSettings setSplunkSettings(Object splunkData) {
            Map<String, Object> indata = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(splunkData));
            ConfigUtil.SPLUNK_SETTINGS.Splunk_Enabled__c = (Boolean)indata.get('enabled');
            DatabaseUtils.getInstance().performUpsertDML(new List<Splunk_Settings__c>{ConfigUtil.SPLUNK_SETTINGS}, Schema.SObjectType.Splunk_Settings__c, true);
            return getSplunkSettings();
        }
    }

    public class Teams {
        public Object getTeams(String nextLink) {
            return GraphAPIService.getTeams(nextLink);
        }

        public Object getTeamById(String id) {
            return GraphAPIService.getTeamById(id);
        }

        public List<Object> getTeamChannels(String teamId) {
            return GraphAPIService.getChannels(teamId);
        }

        public TeamsSettings setTeamsSettings(Object data) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            ConfigUtil.GRAPH_API_SETTINGS.Enabled__c = Boolean.valueOf(input.get('enabled'));
            TeamsSettings result = getTeamsSettings();
            result.enabled = ConfigUtil.GRAPH_API_SETTINGS.Enabled__c;
            DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c, true);
            return result;
        }

        public TeamsSettings getTeamsSettings() {
            TeamsSettings teamsSettings = new TeamsSettings(ConfigUtil.GRAPH_API_SETTINGS);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GraphAPIService.GRAPH_API_SETTINGS_NAME);
            if (mdtSettings != null) {
                HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, GraphAPIService.GRAPH_API_TOKEN_RESPONSE_TYPE_CODE);
                bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_MODE, GraphAPIService.GRAPH_API_TOKEN_RESPONSE_MODE_QUERY);
                bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, GraphAPIService.GRAPH_API_SCOPE);

                Map<String, Object> state = new Map<String, Object>{
                    'redirectUrl' => ConfigUtil.URL_VF_CALLBACK_PAGE_SETTINGS,
                    'isGraphDelegated' => true
                };

                bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_STATE, EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state))));
                teamsSettings.oAuthEndpoint = GraphAPIService.GRAPH_API_AUTHORIZE_ENDPOINT + bodyParams.toStringParameters('?');

                try {
                    GraphAPIService.Organization organization = GraphAPIService.getOrganization(GraphAPIService.OAUTH_API_TOKEN);
                    teamsSettings.isConnectionValid = String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS?.Tenant_Id__c);
                }
                catch(Exception e) {
                    teamsSettings.isConnectionValid = false;
                }
            }
            return teamsSettings;
        }
    }

    public class AzureDevOpsSettings {
        public String apiToken;
        public Boolean isConnectionValid;
        public Boolean enabled;
        public String oAuthEndpoint;
        public Boolean isCacheAvailable;
        public Boolean autoJiraTaskLabelsFromHashes;
        public Boolean autoRelateTicketsWithSimilarErrors;
        public Boolean createUniqueTicketsByOrg;
        public Boolean automaticallyUpdateIssuePriority;
        public Boolean automaticallyUpdateTicketPriority;
        public Boolean synchronizeCompletedStatus;
        public Boolean synchronizeDuplicateTicketsAndIssues;
        public Boolean synchronizeRelatedTicketsAndIssues;

        public AzureDevOpsSettings(Azure_Dev_Ops_API_Settings__c settings) {
            this.apiToken = AzureService.OAUTH_API_TOKEN;
            this.enabled = settings.Enabled__c;
            this.isCacheAvailable = CacheUtils.isCacheAvailable;
            this.oAuthEndpoint = '';
            this.autoJiraTaskLabelsFromHashes = settings.Auto_Generate_Similarity_Labels__c;
            this.autoRelateTicketsWithSimilarErrors = settings.Auto_Relate_Tickets_With_Similar_Errors__c;
            this.createUniqueTicketsByOrg = settings.Create_Unique_Tickets_by_Org__c;
            this.automaticallyUpdateIssuePriority = settings.Automatically_update_Issue_priority__c;
            this.automaticallyUpdateTicketPriority = settings.Automatically_update_ticket_priority__c;
            this.synchronizeCompletedStatus = settings.Synchronize_completed_Status__c;
            this.synchronizeDuplicateTicketsAndIssues = settings.Synchronize_duplicate_tickets_and_issues__c;
            this.synchronizeRelatedTicketsAndIssues = settings.Synchronize_related_tickets_and_issues__c;
        }
    }

    public class GitHubSettings {
        public String apiToken;
        public String oauthToken;
        public String repositoryUrl;
        public String reponame;
        public String branchName;
        public Boolean isConnectionValid;
        public Boolean enabled;
        public String oAuthEndpoint;
        public String reponameError;
        public String branchNameError;

        public GitHubSettings(Git_API_Settings__c settings) {
            this.apiToken = settings.Token__c;
            this.oauthToken = settings.oAuth_Token__c;
            this.enabled = settings.Enabled__c;
            this.reponame = settings.Reponame__c;
            this.branchName = settings.Branch_Name__c;
            this.repositoryUrl = GitHubUtils.getRepositoryUrlFromOwnerAndRepositoryName(
                new List<String>{settings.Username__c, settings.Reponame__c}
            );
        }
    }

    public class JiraSettings {
        public String baseUrl;
        public String apiToken;
        public String username;
        public Boolean autoJiraTaskLabelsFromHashes;
        public Boolean autoRelateTicketsWithSimilarErrors;
        public Boolean createUniqueTicketsByOrg;
        public Boolean automaticallyUpdateIssuePriority;
        public Boolean automaticallyUpdateTicketPriority;
        public Boolean synchronizeCompletedStatus;
        public Boolean synchronizeDuplicateTicketsAndIssues;
        public Boolean synchronizeRelatedTicketsAndIssues;
        public String oAuthEndpoint;

        public Boolean isConnectionValid;
        public String connectionErrorMessage;

        public List<JiraService.JiraProject> projects;
        public List<JiraService.JiraPriority> priorities;
        public List<JiraService.JiraPriorityScheme> prioritySchemes;

        public JiraSettings() {}

        public JiraSettings(Jira_Settings__c jiraSettings) {
            this.baseUrl = jiraSettings.Jira_Base_Url__c;
            this.apiToken = JiraService.JIRA_OAUTH_TOKEN;
            this.username = jiraSettings.Jira_Username__c;
            this.autoJiraTaskLabelsFromHashes = jiraSettings.Auto_Generate_Similarity_Labels__c;
            this.autoRelateTicketsWithSimilarErrors = jiraSettings.Auto_Relate_Tickets_With_Similar_Errors__c;
            this.createUniqueTicketsByOrg = jiraSettings.Create_Unique_Tickets_by_Org__c;
            this.automaticallyUpdateIssuePriority = jiraSettings.Automatically_update_Issue_priority__c;
            this.automaticallyUpdateTicketPriority = jiraSettings.Automatically_update_ticket_priority__c;
            this.synchronizeCompletedStatus = jiraSettings.Synchronize_completed_Status__c;
            this.synchronizeDuplicateTicketsAndIssues = jiraSettings.Synchronize_duplicate_tickets_and_issues__c;
            this.synchronizeRelatedTicketsAndIssues = jiraSettings.Synchronize_related_tickets_and_issues__c;
        }
    }

    public class OpenAISettings {
        public Boolean enabled = false;
        public String token;

        public OpenAISettings() {}

        public OpenAISettings(OpenAI_Settings__c openAISettings) {
            this.enabled = openAISettings.OpenAI_Enabled__c;
            this.token = openAISettings.Token__c;
        }
    }

    public class PagerDutySettings {
        public Boolean enabled;
        public String token;
        public String serviceId;
        public String serviceIntegrationKey;
        public String userEmail;
        public Boolean isConnectionValid;

        public PagerDutySettings() {}

        public PagerDutySettings(Pager_Duty_Settings__c pagerDutySettings) {
            this.enabled = pagerDutySettings.PagerDuty_Enabled__c;
            this.token = pagerDutySettings.PagerDuty_API_Token__c;
            this.serviceId = pagerDutySettings.PagerDuty_Service_ID__c;
            this.serviceIntegrationKey = pagerDutySettings.PagerDuty_Service_Integration_Key__c;
            this.userEmail = pagerDutySettings.PagerDuty_User_Email__c;
        }
    }

    public class SlackSettings {
        public Boolean slackEnabled;
        public Boolean slackNewLogsEnabled;
        public String slackToken;
        public String slackChannelId;
        public String template;
        public String oAuthEndpoint;
        public Boolean isConnectionValid;

        public SlackSettings() {}

        public SlackSettings(Slack_Settings__c slackSettings, String template) {
            this.slackEnabled = slackSettings.Slack_Enabled__c;
            this.slackNewLogsEnabled = slackSettings.Slack_New_Logs_Enabled__c;
            this.slackToken = slackSettings.Slack_API_Token__c;
            this.slackChannelId = slackSettings.Slack_Channel_ID__c;
            this.template = template;
        }
    }

    public class SplunkSettings {
        public Boolean enabled = false;
        public String url;
        public String token;
        public String ecToken;
        public List<Map<String, String>> logFields;
        public List<String> config;

        public SplunkSettings() {}

        public SplunkSettings(Splunk_Settings__c splunkSettings) {
            this.enabled = splunkSettings.Splunk_Enabled__c;
            this.url = splunkSettings.Splunk_Url__c;
            this.token = splunkSettings.Splunk_Token__c;
            this.ecToken = splunkSettings.Splunk_Event_Collector_Token__c;
            this.logFields = new List<Map<String, String>>();
        }
    }

    public class TeamsSettings {
        public String apiToken;
        public Boolean isConnectionValid;
        public Boolean enabled;
        public String oAuthEndpoint;
        public Boolean isCacheAvailable;

        public TeamsSettings(Graph_API_Settings__c settings) {
            this.apiToken = GraphAPIService.OAUTH_API_TOKEN;
            this.enabled = settings.Enabled__c;
            this.isCacheAvailable = CacheUtils.isCacheAvailable;
        }
    }

    public class IntegrationSettingsException extends Exception {}
}