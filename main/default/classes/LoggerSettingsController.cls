public with sharing class LoggerSettingsController {

    public Connected_Orgs_Settings__c settings { get; set; }
    public Boolean hasConnectedApp { get; set; }
    public Boolean isCode { get; set; }
    public Boolean isSandbox { get; set; }

    public LoggerSettingsController() {
        this.init();
        this.isCode = String.isNotBlank(ApexPages.currentPage().getParameters().get('code'));
        this.isSandbox = ConfigUtil.currentOrgIsSandbox;
    }

    private void init() {
        this.settings = ConfigUtil.CONNECTED_ORGS_SETTINGS;
        hasConnectedApp = String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c) && String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c);
    }

    @RemoteAction
    public static String generateTokenForConnectedOrg(String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            Connected_Org__c corg = ConnectedOrgService.generateTokenForConnectedOrg((String)input.get('code'), input.get('state'), (String)input.get('redirectUrl'));
            output.put('status', 'ok');
            output.put('corg', corg);
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
            if (e instanceof HttpUtils.HttpUtilsException) {
                AdminService.debugSession((HttpUtils.HttpUtilsException)e, 'generateTokenForConnectedOrg');
            }
        }
        Logger.getInstance().flush();
        return JSON.serialize(output);
    }

    public static final String SLACK_OAUTH_ENDPOINT = 'https://slack.com/api/oauth.access';
    public static final String SLACK_OAUTH_ENDPOINT_V2 = 'https://slack.com/api/oauth.v2.access';
    public static final String SLACK_SETTINGS_NAME = 'Slack';

    @RemoteAction
    public static String generateTokenForSlack (String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_SLACK_API_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_SLACK_API_URL, ConfigUtil.REMOTE_SITE_SETTINGS_SLACK_DESCRIPTION);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(SLACK_SETTINGS_NAME);
            String clientId = (String.isNotBlank(ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Id__c))
                ? ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Id__c
                : mdtSettings.Client_Id__c;
            String clientSecret = (String.isNotBlank(ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Secret__c))
                ? ConfigUtil.PHAROS_SETTINGS.Slack_App_Client_Secret__c
                : mdtSettings.Client_Secret__c;
            String endpoint = SLACK_OAUTH_ENDPOINT_V2;
            HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CODE, (String)input.get('code'));
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, clientId);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, clientSecret);
            String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                null,
                200
            );
            ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
            ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c = resp.access_token;
            ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c = true;

            DatabaseUtils.getInstance().performUpsertDML(new List<Slack_Settings__c>{ConfigUtil.SLACK_SETTINGS}, Schema.SObjectType.Slack_Settings__c, true);
            output.put('status', 'ok');
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
        }
        return JSON.serialize(output);
    }

    @RemoteAction
    public static String generateTokenForGraph (String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_TOKEN_REQUEST_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_TOKEN_REQUEST_URL, ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_TOKEN_REQUEST_DESCRIPTION);
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_REQUEST_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_REQUEST_URL, ConfigUtil.REMOTE_SITE_SETTINGS_GRAPH_API_REQUEST_DESCRIPTION);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GraphAPIService.GRAPH_API_SETTINGS_NAME);
            String endpoint = GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT;
            HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CODE, (String)input.get('code'));
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, mdtSettings.Client_Secret__c);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, GraphAPIService.GRAPH_API_TOKEN_GRANT_TYPE_AUTHORIZATION_CODE);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, GraphAPIService.GRAPH_API_TOKEN_RESPONSE_TYPE_CODE);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, (String)input.get('return_url'));
            bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, GraphAPIService.GRAPH_API_SCOPE);

            String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                HttpUtils.getHeadersContentTypeFormUrlencoded(),
                200
            );
            ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
            GraphAPIService.Organization organization = GraphAPIService.getOrganization(resp.access_token);
            ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c = organization.id;

            GraphAPIService.putEncryptedGraphTokenToCache(Logger.getInstance(), ConfigUtil.GRAPH_API_SETTINGS, resp.access_token);
            Logger.getInstance().flush();

            GraphAPIService.putApiTokenToSettings(resp.access_token, false, Logger.getInstance());
            GraphAPIService.putApiRefreshTokenToSettings(resp.refresh_token, false, Logger.getInstance());
            GraphAPIService.saveListTokenRecordSettings(true, Logger.getInstance());
            DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c, true);
            output.put('status', 'ok');
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
        }
        return JSON.serialize(output);
    }

    //https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth?toc=%2Fazure%2Fdevops%2Fmarketplace-extensibility%2Ftoc.json&view=azure-devops
    @RemoteAction
    public static String generateTokenForAzureDevOps (String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_API_TOKEN_REQUEST_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_API_TOKEN_REQUEST_URL, ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_API_TOKEN_REQUEST_DESCRIPTION);
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_REST_API_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_REST_API_URL, ConfigUtil.REMOTE_SITE_SETTINGS_AZURE_DO_REST_API_DESCRIPTION);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(AzureService.AZURE_DEVOPS_API_SETTINGS_NAME);
            String extendedClientSecret = [SELECT Extended_Client_Secret__c FROM OAuthSettings__mdt WHERE DeveloperName =:AzureService.AZURE_DEVOPS_API_SETTINGS_NAME LIMIT 1].Extended_Client_Secret__c;
            String endpoint = AzureService.AZURE_DEVOPS_API_GET_TOKEN_ENDPOINT;
            HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
            bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ASSERTATION_TYPE, HttpUtils.HTTP_URL_PARAM_CLIENT_ASSERTATION_TYPE_VALUE_JWT);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ASSERTATION, extendedClientSecret);
            bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, HttpUtils.HTTP_URL_PARAM_GRANT_TYPE_VALUE_JWT);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_ASSERTATION, (String)input.get('code'));
            bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, (String)input.get('return_url'));

            String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                HttpUtils.getHeadersContentTypeFormUrlencoded(),
                200
            );
            ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);

            AzureService.AzureDevOpsMyProfile myProfile = AzureService.getMyProfile(resp.access_token);
            List<AzureService.AzureDevOpsAccount> myAccounts = AzureService.getAccountsByOwnerId(myProfile.id, resp.access_token);

            if(myAccounts.size() == 1) {
                ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c = myAccounts.get(0).accountName;
            }
            else {
                output.put('azureAccounts', myAccounts);
            }
            
            AzureService.putEncryptedAzureDevOpsTokenToCache(Logger.getInstance(), ConfigUtil.AZURE_DEV_OPS_API_SETTINGS, resp.access_token);
            Logger.getInstance().flush();

            GraphAPIService.putAzureDevOpsApiTokenToSettings(resp.access_token, false, Logger.getInstance());
            GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings(resp.refresh_token, false, Logger.getInstance());
            GraphAPIService.saveListTokenRecordSettings(true, Logger.getInstance());
            DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c, true);
            DatabaseUtils.getInstance().performUpsertDML(new List<Azure_Dev_Ops_API_Settings__c>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS}, Schema.SObjectType.Azure_Dev_Ops_API_Settings__c, true);
            output.put('status', 'ok');
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
        }
        return JSON.serialize(output);
    }

    @RemoteAction
    public static String generateTokenForGitHub(String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_API_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_API_URL, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_API_DESCRIPTION);
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_URL, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_HUB_DESCRIPTION);
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_GIT_SFDX_API_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_SFDX_API_URL, ConfigUtil.REMOTE_SITE_SETTINGS_GIT_SFDX_API_DESCRIPTION);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GitHubUtils.GIT_API_SETTINGS_NAME);
            String endpoint = GitHubUtils.GIT_API_TOKEN_ENDPOINT;
            HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CODE, (String)input.get('code'));
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, mdtSettings.Client_Secret__c);
            bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, (String)input.get('return_url'));

            String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                HttpUtils.getHeadersAcceptJson(),
                200
            );
            ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
            GitHubUtils.GitUserInfo userInfo = GitHubUtils.getGitUserInfo('token ' + resp.access_token);
            ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c = resp.access_token;
            String userOrCompanyName = String.isNotBlank(userInfo.company) ? userInfo.company : userInfo.login;
            ConfigUtil.GIT_API_SETTINGS.Username__c = userOrCompanyName;
            ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
            DatabaseUtils.getInstance().performUpsertDML(new List<Git_API_Settings__c>{ConfigUtil.GIT_API_SETTINGS}, Schema.SObjectType.Git_API_Settings__c, true);
            output.put('status', 'ok');
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
        }
        return JSON.serialize(output);
    }

    public static final String PHAROS_OUATH_CALLBACK_PROXY {
        get {
            return 'https://auth.pharos.ai';
        }
    }

    public static Object setSettingsForAzureDevOpsAccount (Object inputJson) {
        AzureService.AzureDevOpsAccount azureDevOpsAccount = (AzureService.AzureDevOpsAccount)JSON.deserialize(JSON.serialize(inputJson), AzureService.AzureDevOpsAccount.class);
        ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c = azureDevOpsAccount.accountName;
        DatabaseUtils.getInstance().performUpsertDML(new List<Azure_Dev_Ops_API_Settings__c>{ConfigUtil.AZURE_DEV_OPS_API_SETTINGS}, Schema.SObjectType.Azure_Dev_Ops_API_Settings__c, true);
        return true;
    }

    public static Object getAzureDevOpsAccounts() {
        AzureService.AzureDevOpsMyProfile myProfile = AzureService.getMyProfile(AzureService.OAUTH_API_TOKEN);
        List<AzureService.AzureDevOpsAccount> azureDevOpsAccounts = AzureService.getAccountsByOwnerId(myProfile.id, AzureService.OAUTH_API_TOKEN);
        return azureDevOpsAccounts;
    }

    public static Object setSettingsForJiraSite (Object inputJson) {
        JiraService.JiraResourceWrapper jiraSite = (JiraService.JiraResourceWrapper)JSON.deserialize(JSON.serialize(inputJson), JiraService.JiraResourceWrapper.class);
        // remote site settings for cloud site url
        AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_NAME, jiraSite.url, ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_DESCRIPTION);
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = jiraSite.url;
        ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c = ConfigUtil.JIRA_CLOUD_API_PREFIX + jiraSite.id;
        DatabaseUtils.getInstance().performUpsertDML(new List<Jira_Settings__c>{ConfigUtil.JIRA_SETTINGS}, Schema.SObjectType.Jira_Settings__c, true);
        return true;
    }

    public static Object getJiraSites() {
        List<JiraService.JiraResourceWrapper> jiraSites = JiraService.getService().getJiraEndpoint(JiraService.JIRA_OAUTH_TOKEN);
        return jiraSites;
    }

    @RemoteAction
    public static String generateTokenForJira(String inputJson) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        Map<String, Object> output = new Map<String, Object>();
        try {
            // remote site settings for cloud api / oauth endpoint
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_CLOUD_API_NAME, ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_CLOUD_API_URL, ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_CLOUD_API_DESCRIPTION);
            AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_CLOUD_OAUTH_NAME, JiraService.JIRA_CLOUD_OAUTH_ENDPOINT, ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_CLOUD_OAUTH_DESCRIPTION);

            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(JiraService.JIRA_CLOUD_SETTINGS_NAME);
            String clientId = mdtSettings.Client_Id__c;
            String clientSecret = mdtSettings.Client_Secret__c;
            String endpoint = JiraService.JIRA_CLOUD_OAUTH_ENDPOINT;
            String oAuthCode = (String)input.get('code');

            ConnectedOrgService.AuthTokenResponse resp = JiraService.getJiraAPIToken(oAuthCode, clientId, clientSecret, endpoint);

            // get cloud site url
            List<JiraService.JiraResourceWrapper> jiraSites = JiraService.getService().getJiraEndpoint(resp.access_token);

            if(jiraSites.size() == 1) {
                JiraService.JiraResourceWrapper jiraSite = jiraSites.get(0);
                // remote site settings for cloud site url
                AdminService.upsertRemoteSiteSetting(ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_NAME, jiraSite.url, ConfigUtil.REMOTE_SITE_SETTINGS_JIRA_DESCRIPTION);
                ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c = ConfigUtil.JIRA_CLOUD_API_PREFIX + jiraSite.id;
                ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = jiraSite.url;
                output.put('jiraSites', jiraSites);
            }
            else {
                output.put('jiraSites', jiraSites);
            }

            ConfigUtil.JIRA_SETTINGS.Jira_Username__c = JiraService.JIRA_CLOUD_OAUTH_USERNAME;

            JiraService.putEncryptedJiraTokenToCache(Logger.getInstance(), ConfigUtil.JIRA_SETTINGS, resp.access_token);

            JiraService.putApiTokenToSettings(resp.access_token, false, Logger.getInstance());
            JiraService.putApiRefreshTokenToSettings(resp.refresh_token, false, Logger.getInstance());

            GraphAPIService.saveListTokenRecordSettings(true, Logger.getInstance());

            DatabaseUtils.getInstance().performUpsertDML(new List<Jira_Settings__c>{ConfigUtil.JIRA_SETTINGS}, Schema.SObjectType.Jira_Settings__c, true);

            output.put('status', 'ok');
        } catch (Exception e) {
            output.put('status', 'error');
            output.put('message', e.getMessage());
        }
        return JSON.serialize(output);
    }

}