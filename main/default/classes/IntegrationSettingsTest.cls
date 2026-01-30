@IsTest
public with sharing class IntegrationSettingsTest {
    // TODO: Remove dependency with AdminService

    private static final String JIRA_MOCK_REST_ENDPOINT = 'https://test.atlassian.net';

    private static final String TEST_GRAPH_API_TEAM_ID = 'someTestGraphTeamId';
    private static final String TEST_GRAPH_API_TEAM_DISPLAY_NAME = 'someTestGraphTeamLabel';
    private static final String TEST_GRAPH_API_TEAM_CHANNEL_ID = 'someTestGraphChannelTeamId';
	private static final String TEST_GRAPH_API_TEAM_CHANNEL_DISPLAY_NAME = 'someTestGraphTeamChannelLabel';

    private static final String CUSTOM_SETTING_OPEN_AI_TOKEN = 'test_token';

    private static final String CUSTOM_SETTING_PAGER_DUTY_TOKEN = 'test_token';
    private static final String CUSTOM_SETTING_PAGER_DUTY_SERVICE_ID = 'test_serviceId';
    private static final String CUSTOM_SETTING_PAGER_DUTY_SERVICE_INTEGRATION_KEY = 'test_serviceKey';
    private static final String CUSTOM_SETTING_PAGER_DUTY_USER_EMAIL = 'test_email@test.test';

    private static final String CUSTOM_SETTING_SPLUNK_URL = 'test_url';
    private static final String CUSTOM_SETTING_SPLUNK_TOKEN = 'test_token';
    private static final String CUSTOM_SETTING_SPLUNK_EVENT_COLLECTOR_TOKEN = 'test_eventCollectorToken';

    private static final String SLACK_CHANNEL_NAME = 'Test Pharos Channel';
    private static final String SLACK_CHANNEL_ID = 'C1AD0CDA4';
    private static final String SLACK_CHANNEL_NEXT_CURSOR = 'dGVhbTpDUlBKVzFRVEM=';
    private static final String SLACK_CHANNEL_EMPTY_CURSOR = null;

    private static final String TEST_GIT_API_EXT_USERNAME = 'someusername2';
    private static final String TEST_GIT_API_TOKEN = 'token';
    private static final String TEST_GIT_API_OAUTH_TOKEN = 'oauthtoken';
    private static final String TEST_GIT_API_EXT_REPONAME = 'reponame2';
    private static final String TEST_GIT_API_EXT_BRANCH_NAME = 'master2';
    private static final String TEST_GIT_API_EXT_REPOSITORY_URL = 'https://github.com/someusername2/reponame2.git';
    
    @TestSetup
    private static void testSetup() {
        Git_API_Settings__c gitApiSettings = Git_API_Settings__c.getOrgDefaults();
        gitApiSettings.Enabled__c = true;
        gitApiSettings.Username__c = TEST_GIT_API_EXT_USERNAME;
        gitApiSettings.Token__c = TEST_GIT_API_TOKEN;
        gitApiSettings.oAuth_Token__c = TEST_GIT_API_OAUTH_TOKEN;
        gitApiSettings.Last_Processed_Date_Time__c = Datetime.now().formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
        upsert gitApiSettings;

        Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
        jiraSettings.Jira_Base_Url__c = JIRA_MOCK_REST_ENDPOINT;
        jiraSettings.Jira_API_Url__c = JIRA_MOCK_REST_ENDPOINT;
        jiraSettings.Jira_Username__c = JiraService.JIRA_CLOUD_OAUTH_USERNAME;
        insert jiraSettings;

        Pager_Duty_Settings__c pagerDutySettings = Pager_Duty_Settings__c.getOrgDefaults();
        pagerDutySettings.PagerDuty_Enabled__c = true;
        pagerDutySettings.PagerDuty_API_Token__c = CUSTOM_SETTING_PAGER_DUTY_TOKEN;
        pagerDutySettings.PagerDuty_Service_ID__c = CUSTOM_SETTING_PAGER_DUTY_SERVICE_ID;
        pagerDutySettings.PagerDuty_Service_Integration_Key__c = CUSTOM_SETTING_PAGER_DUTY_SERVICE_INTEGRATION_KEY;
        pagerDutySettings.PagerDuty_User_Email__c = CUSTOM_SETTING_PAGER_DUTY_USER_EMAIL;
        upsert pagerDutySettings;

        Splunk_Settings__c splunkSettings = Splunk_Settings__c.getOrgDefaults();
        splunkSettings.Splunk_Enabled__c = true;
        splunkSettings.Splunk_Url__c = CUSTOM_SETTING_SPLUNK_URL;
        splunkSettings.Splunk_Token__c = CUSTOM_SETTING_SPLUNK_TOKEN;
        splunkSettings.Splunk_Event_Collector_Token__c = CUSTOM_SETTING_SPLUNK_EVENT_COLLECTOR_TOKEN;
        upsert splunkSettings;

        Splunk_Fields__c splunkFields = new Splunk_Fields__c();
        splunkFields.Name = 'Id';
        splunkFields.Field_Name__c = 'Id';
        upsert splunkFields;

        OpenAI_Settings__c openAISettings = OpenAI_Settings__c.getOrgDefaults();
        openAISettings.OpenAI_Enabled__c = true;
        openAISettings.Token__c = CUSTOM_SETTING_OPEN_AI_TOKEN;
        upsert openAISettings;

        String oauthToken = AdminService.generateRandomString(1000);
        JiraService.putApiTokenToSettings(oauthToken, true, null);
    }

    // Azure DevOps Tests
    @IsTest
    static void getAzureDevOpsSettings_ConnectionValid() {
        IntegrationSettings.AzureDevOpsSettings result;

        Test.setMock(
            HttpCalloutMock.class, 
            new TestDataFactory.MultiRequestMock(
                new Map<String, HttpCalloutMock>{
                    AzureService.AZURE_DEVOPS_REST_API_MY_PROFILE => new TestDataFactory.SingleRequestMock(
                        200,
                        'OK',
                        JSON.serialize(new AzureService.AzureDevOpsMyProfile())
                    )
                }
            )
        );

        Test.startTest();
            result = (IntegrationSettings.AzureDevOpsSettings) IntegrationSettings.AZURE_DEVOPS.getAzureDevOpsSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result.oAuthEndpoint);
        Assert.isTrue(result.isConnectionValid);
    }

    @IsTest
    static void getAzureDevOpsSettings_ConnectionInvalid() {
        IntegrationSettings.AzureDevOpsSettings result;

        Test.setMock(
            HttpCalloutMock.class, 
            new TestDataFactory.MultiRequestMock(
                new Map<String, HttpCalloutMock>{
                    AzureService.AZURE_DEVOPS_REST_API_MY_PROFILE => new TestDataFactory.SingleRequestMock(
                        404,
                        'Not Found',
                        JSON.serialize(new AzureService.AzureDevOpsMyProfile())
                    )
                }
            )
        );

        Test.startTest();
            result = (IntegrationSettings.AzureDevOpsSettings) IntegrationSettings.AZURE_DEVOPS.getAzureDevOpsSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result.oAuthEndpoint);
        Assert.isFalse(result.isConnectionValid);
    }

    @IsTest
    static void resetAzureDevOpsSettings() {
        Azure_Dev_Ops_API_Settings__c azureDevOpsApiSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
        azureDevOpsApiSettings.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        azureDevOpsApiSettings.Auto_Generate_Similarity_Labels__c = true;
        azureDevOpsApiSettings.Auto_Relate_Tickets_With_Similar_Errors__c = true;
        azureDevOpsApiSettings.Create_Unique_Tickets_by_Org__c = true;
        azureDevOpsApiSettings.Automatically_update_Issue_priority__c = true;
        azureDevOpsApiSettings.Automatically_update_ticket_priority__c = true;
        azureDevOpsApiSettings.Synchronize_completed_Status__c = true;
        azureDevOpsApiSettings.Synchronize_duplicate_tickets_and_issues__c = true;
        azureDevOpsApiSettings.Synchronize_related_tickets_and_issues__c = true;
        upsert azureDevOpsApiSettings;

        String result;
        Test.startTest();
            result = IntegrationSettings.AZURE_DEVOPS.resetAzureDevOpsSettings();
        Test.stopTest();

        Assert.areEqual(Constants.UI.RESULT_SUCCESS, result);
        Assert.isFalse(String.isNotBlank(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c));
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Generate_Similarity_Labels__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Create_Unique_Tickets_by_Org__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c);
        Assert.isFalse(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c);
    }

    @IsTest
    static void saveAzureDevOpsSettings() {
        String result;
        IntegrationSettings.AzureDevOpsSettings data = new IntegrationSettings.AzureDevOpsSettings(new Azure_Dev_Ops_API_Settings__c());
        data.autoJiraTaskLabelsFromHashes = true;
        data.autoRelateTicketsWithSimilarErrors = true;
        data.createUniqueTicketsByOrg = true;
        data.automaticallyUpdateIssuePriority = true;
        data.automaticallyUpdateTicketPriority = true;
        data.synchronizeCompletedStatus = true;
        data.synchronizeDuplicateTicketsAndIssues = true;
        data.synchronizeRelatedTicketsAndIssues = true;

        Test.startTest();
            result = IntegrationSettings.AZURE_DEVOPS.saveAzureDevOpsSettings(data);
        Test.stopTest();

        Assert.areEqual(Constants.UI.RESULT_SUCCESS, result);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Generate_Similarity_Labels__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Create_Unique_Tickets_by_Org__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c);
        Assert.isTrue(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c);
    }

    // Git Hub Tests
    @IsTest
    static void resetGitHubSettings() {
        Git_API_Settings__c gitApiSettings = Git_API_Settings__c.getOrgDefaults();
        gitApiSettings.Reponame__c = TEST_GIT_API_EXT_REPOSITORY_URL;
        gitApiSettings.Branch_Name__c = TEST_GIT_API_EXT_BRANCH_NAME;
        upsert gitApiSettings;

        Test.startTest();
            IntegrationSettings.GIT_HUB.resetGitHubSettings();
        Test.stopTest();

        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Token__c));
        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c));
        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Username__c));
        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Reponame__c));
        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Branch_Name__c));
        Assert.isTrue(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c));
    }

    @IsTest
    static void getGitHubSettings() {
        IntegrationSettings.GitHubSettings settings;

        Test.startTest();
            settings = IntegrationSettings.GIT_HUB.getGitHubSettings();
        Test.stopTest();

        Assert.areNotEqual(null, settings.oAuthEndpoint);
    }

    @IsTest
    static void setGitHubSettings() {
        IntegrationSettings.GitHubSettings settings;
        Test.startTest();
            settings = IntegrationSettings.GIT_HUB.getGitHubSettings();
            settings.enabled = true;
            IntegrationSettings.GIT_HUB.setGitHubSettings(settings);
        Test.stopTest();
        Assert.areEqual(true, ConfigUtil.GIT_API_SETTINGS.Enabled__c);
    }

    @IsTest
    static void setGitHubSettings_WithResetByRepoOrBranchName() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(getGitAPIUserReposByNameEndpoint(TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME), getGitAPIUserReposByNameMock());
        endpoint2TestResp.put(getGitAPIUserExtRepoBranchesByNameEndpoint(), getGitAPIUserExtRepoBranchesByNameMock());

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
            Map<String, Object> inputSettings = new Map<String, Object>{
                'repositoryUrl' => TEST_GIT_API_EXT_REPOSITORY_URL,
                'branchName' => TEST_GIT_API_EXT_BRANCH_NAME
            };
            IntegrationSettings.GIT_HUB.setGitHubSettings(inputSettings);
        Test.stopTest();
        Assert.areEqual(null, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c);
    }

    @IsTest
    static void setGitHubSettings_ValidateRepositoryName() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(getGitAPIUserReposByNameEndpoint(TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME), getGitAPIUserReposByNameNotFoundMock());
        endpoint2TestResp.put(getGitAPIUserExtRepoBranchesByNameEndpoint(), getGitAPIUserExtRepoBranchesByNameNotFoundMock());

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
            Map<String, Object> inputSettings = new Map<String, Object>{
                'repositoryUrl' => TEST_GIT_API_EXT_REPOSITORY_URL,
                'branchName' => TEST_GIT_API_EXT_BRANCH_NAME
            };
            IntegrationSettings.GitHubSettings settings = IntegrationSettings.GIT_HUB.setGitHubSettings(inputSettings);
        Test.stopTest();
        
        Assert.areNotEqual(null, settings);
        Assert.areEqual(IntegrationSettings.GIT_HUB.GIT_API_REPOSITORY_NAME_NOT_FOUND, settings.reponameError);
        Assert.areEqual(null, settings.branchNameError);
    }

    @IsTest
    static void setGitHubSettings_ValidateBranchName() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(getGitAPIUserReposByNameEndpoint(TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME), getGitAPIUserReposByNameMock());
        endpoint2TestResp.put(getGitAPIUserExtRepoBranchesByNameEndpoint(), getGitAPIUserExtRepoBranchesByNameNotFoundMock());

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
            Map<String, Object> inputSettings = new Map<String, Object>{
                'repositoryUrl' => TEST_GIT_API_EXT_REPOSITORY_URL,
                'branchName' => TEST_GIT_API_EXT_BRANCH_NAME
            };

            IntegrationSettings.GitHubSettings settings = IntegrationSettings.GIT_HUB.setGitHubSettings(inputSettings);
        Test.stopTest();

        Assert.areNotEqual(null, settings);
        Assert.areEqual(null, settings.reponameError);
        Assert.areEqual(IntegrationSettings.GIT_HUB.GIT_API_BRANCH_NAME_NOT_FOUND, settings.branchNameError);
    }

    // Jira Tests
    @IsTest
    static void getJiraSettings() {
        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        IntegrationSettings.JiraSettings result;
        Test.startTest();
            result = IntegrationSettings.JIRA.getJiraSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result.oAuthEndpoint);
        Assert.isTrue(result.isConnectionValid);
    }

    @IsTest
    static void validateJiraSetting_withoutThrowError() {
        IntegrationSettings.JiraSettings settings = new IntegrationSettings.JiraSettings();
        Test.startTest();
            settings = IntegrationSettings.JIRA.validateJiraSetting(false, new IntegrationSettings.JiraSettings(ConfigUtil.JIRA_SETTINGS));
        Test.stopTest();

        Assert.isFalse(settings.isConnectionValid);
        Assert.isTrue(String.isNotBlank(settings.connectionErrorMessage));
        Assert.areEqual(1, [SELECT COUNT() FROM Log__c]);
    }

    @IsTest
    static void validateJiraSetting_withoutThrowErrorWithEmptyBaseUrl() {
        IntegrationSettings.JiraSettings settings = new IntegrationSettings.JiraSettings();
        Test.startTest();
            settings = IntegrationSettings.JIRA.validateJiraSetting(false, settings);
        Test.stopTest();

        Assert.isFalse(settings.isConnectionValid);
    }

    @IsTest
    static void validateJiraSetting_withThrowError() {
        IntegrationSettings.JiraSettings settings = new IntegrationSettings.JiraSettings();
        String errorMessage;
        Test.startTest();
            try {
                settings = IntegrationSettings.JIRA.validateJiraSetting(true, new IntegrationSettings.JiraSettings(ConfigUtil.JIRA_SETTINGS));
            } catch(Exception ex) {
                errorMessage = ex.getMessage();
            }     
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(errorMessage));
        Assert.areEqual(IntegrationSettings.JIRA.ERROR_MESSAGE_JIRA_CONNECTION_COULD_NOT_BE_ESTABLISHED, errorMessage);

        List<Log__c> logs = [SELECT Summary__c FROM Log__c];
        Assert.areEqual(1, logs.size());
        Assert.isTrue(logs.get(0).Summary__c.contains('Failed Jira Authentication:'));
    }

    @IsTest
    static void validateJiraSetting_withThrowErrorWithEmptyBaseUrl() {
        String errorMessage;
        Test.startTest();
            try {
                IntegrationSettings.JIRA.validateJiraSetting(true, new IntegrationSettings.JiraSettings());
            } catch(Exception ex) {
                errorMessage = ex.getMessage();
            }    
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(errorMessage));
        Assert.areEqual(IntegrationSettings.JIRA.ERROR_MESSAGE_JIRA_TOKEN_IS_EMPTY_OR_INVALID, errorMessage);
    }

    @IsTest
    static void saveJiraSettings_apiFromCloudSettings() {
        Assert.areEqual(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        Map<String, Object> inputSettings = new Map<String, Object>{
            'baseUrl' => JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT,
            'username' => 'someusername',
            'apiToken' => 'sometoken',
            'apiform' => ''
        };

        // setup mocks
        JiraService.JIRA_API_URL = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = 'someusername';
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_HOSTED, JiraService.getJIRAServiceAuthType(), 'should be hosted api');
        Assert.areEqual(true, JiraService.getService().getProjectsEndpoint().contains(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT));
        mocks.putAll(JiraNotificationBatchTest.createJiraMocks());
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        // after mocks setup should be CLOUD from init setup
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');


        Test.startTest();
            IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
        Test.stopTest();

        for (HttpRequest request : multiCalloutMock.getRequests()) {
            if (request.getEndpoint().startsWith(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT)) {
                Assert.areEqual(true, request.getEndpoint().contains('/api/2/'), 'should be v2 api');
            }
        }

        Assert.areEqual(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        Assert.areEqual('someusername', ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
    }

    @IsTest
    static void saveJiraSettings_patFromCloudSettings() {
        Assert.areEqual(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        String newHostedJiraEndpoint = 'https://someurl.com';
        Map<String, Object> inputSettings = new Map<String, Object>{
            'baseUrl' => newHostedJiraEndpoint,
            'apiToken' => 'sometoken',
            'apiform' => ''
        };

        // setup mocks
        JiraService.JIRA_API_URL = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = null;
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
        Assert.areEqual(true, JiraService.getService().getProjectsEndpoint().contains(newHostedJiraEndpoint), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(newHostedJiraEndpoint));
        mocks.putAll(getJiraSettingsMock(false));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        // after mocks setup should be CLOUD from init setup
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');
        
        Test.startTest();
            IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
        Test.stopTest();

        for (HttpRequest request : multiCalloutMock.getRequests()) {
            if (request.getEndpoint().startsWith(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT)) {
                Assert.areEqual(true, request.getEndpoint().contains('/api/2/'), 'should be v2 api');
            }
        }

        Assert.areEqual('https://someurl.com', ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
    }

    @IsTest
    static void saveJiraSettings_patFromEmptySettings() {
        Assert.areEqual(true, JiraService.isCloudJiraInstance(), 'should be cloud from init setup');
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD, JiraService.getJIRAServiceAuthType(), 'should be CLOUD');

        // clear cloud config
        Jira_Settings__c jiraSettings = Jira_Settings__c.getOrgDefaults();
        jiraSettings.Jira_Base_Url__c = null;
        jiraSettings.Jira_API_Url__c = null;
        jiraSettings.Jira_Username__c = null;
        update jiraSettings;
        ConfigUtil.JIRA_SETTINGS = null;

        Assert.areEqual(null, JiraService.getJIRAServiceAuthType(), 'should be null');


        String newHostedJiraEndpoint = 'https://someurl.com';
        Map<String, Object> inputSettings = new Map<String, Object>{
            'baseUrl' => newHostedJiraEndpoint,
            'apiToken' => 'sometoken',
            'apiform' => ''
        };

        // setup mocks
        JiraService.JIRA_API_URL = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c = newHostedJiraEndpoint;
        ConfigUtil.JIRA_SETTINGS.Jira_Username__c = null;
        ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c = 'sometoken';
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
        Assert.areEqual(true, JiraService.getService().getProjectsEndpoint().contains(newHostedJiraEndpoint), 'mocks should be configured to new api url' + JiraService.getService().getProjectsEndpoint());

        Map<String, HttpCalloutMock> mocks = new Map<String, HttpCalloutMock>();
        mocks.putAll(getRemoteSiteSettingsMock(newHostedJiraEndpoint));
        mocks.putAll(getJiraSettingsMock(false));
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(mocks);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        // after mocks setup should be empty
        JiraService.JIRA_API_URL = null;
        ConfigUtil.JIRA_SETTINGS = null;
        Assert.areEqual(null, JiraService.getJIRAServiceAuthType(), 'should be null');
        
        Test.startTest();
            IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
        Test.stopTest();

        for (HttpRequest request : multiCalloutMock.getRequests()) {
            if (request.getEndpoint().startsWith(JiraNotificationBatchTest.JIRA_MOCK_REST_ENDPOINT)) {
                Assert.areEqual(true, request.getEndpoint().contains('/api/2/'), 'should be v2 api');
            }
        }

        Assert.areEqual('https://someurl.com', ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual('sometoken', ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        Assert.areEqual(JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_PAT, JiraService.getJIRAServiceAuthType(), 'should be PAT');
    }

    @IsTest
    static void saveJiraSettings_cloud() {
        Map<String, Object> inputSettings = new Map<String, Object>{
            'oauthToken' => 'sometoken',
            'cloudform' => ''
        };
        Test.startTest();
            try {
                IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
            } catch(Exception e) {}
            
        Test.stopTest();

        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
    }

    @IsTest
    static void saveJiraSettings_settings() {
        Map<String, Object> inputSettings = new Map<String, Object>{
            'autoJiraTaskLabelsFromHashes' => true,
            'autoRelateTicketsWithSimilarErrors' => true,
            'createUniqueTicketsByOrg' => false,
            'automaticallyUpdateIssuePriority' => true,
            'automaticallyUpdateTicketPriority' => true,
            'synchronizeCompletedStatus' => true,
            'synchronizeDuplicateTicketsAndIssues' => true,
            'synchronizeRelatedTicketsAndIssues' => true
        };

        Test.startTest();
            try {
                IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
            } catch (Exception e) {}
        Test.stopTest();

        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        Assert.areEqual(false, ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c);
    }

    @IsTest
    static void saveJiraSettings_cloudSettings() {
        Map<String, HttpCalloutMock> endpoint2TestResp = getJiraSettingsMock(true);
    	TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
    	Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Map<String, Object> inputSettings = new Map<String, Object>{
            'baseUrl' => JIRA_MOCK_REST_ENDPOINT,
            'username' => JiraService.JIRA_CLOUD_OAUTH_USERNAME,
            'oauthToken' => AdminService.generateRandomString(1000),
            'autoJiraTaskLabelsFromHashes' => true,
            'autoRelateTicketsWithSimilarErrors' => true,
            'createUniqueTicketsByOrg' => false
        };
        Test.startTest();
            IntegrationSettings.JIRA.saveJiraSettings(inputSettings);
        Test.stopTest();

        Assert.areEqual(JiraService.JIRA_CLOUD_OAUTH_USERNAME, ConfigUtil.JIRA_SETTINGS.Jira_Username__c);
        Assert.areEqual(null, ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c);
        Assert.areEqual(true, ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        Assert.areEqual(false, ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c);
    }

    @IsTest
    static void resetJiraSettings() {
        String result;
        Test.startTest();
            result = IntegrationSettings.JIRA.resetJiraSettings();
        Test.stopTest();

        Assert.areEqual(Constants.UI.RESULT_SUCCESS, result);
        Assert.isFalse(String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c));
        Assert.isFalse(String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c));
        Assert.isFalse(String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Token__c));
        Assert.isFalse(String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Username__c));
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Auto_Generate_Similarity_Labels__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Auto_Relate_Tickets_With_Similar_Errors__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Create_Unique_Tickets_by_Org__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c);
        Assert.isFalse(ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c);
    }

    // Open AI Tests
    @IsTest
    static void getOpenAISettings() {
        IntegrationSettings.OpenAISettings result;
        Test.startTest();
            result = IntegrationSettings.OPEN_AI.getOpenAISettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.enabled);
        Assert.areEqual(CUSTOM_SETTING_OPEN_AI_TOKEN, result.token);
    }

    @IsTest
    static void validateOpenAIToken() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(openAiValidationMock()));

        Map<String, Boolean> result;
        Test.startTest();
            result = IntegrationSettings.OPEN_AI.validateOpenAIToken(IntegrationSettings.OPEN_AI.getOpenAISettings());
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.get('isValid'));
    }

    @IsTest
    static void setOpenAISettings() {
        IntegrationSettings.OpenAISettings inputData = new IntegrationSettings.OpenAISettings();
        inputData.enabled = true;
        inputData.token = '';

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock()));
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        IntegrationSettings.OpenAISettings result;
        Test.startTest();
            result = IntegrationSettings.OPEN_AI.setOpenAISettings(inputData);
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.enabled);
        Assert.isTrue(String.isBlank(result.token));
    }

    // Pager Duty Tests
    @IsTest
    static void getPagerDutySettings_ConnectionValid() {
        String pagerDutyServiceWrapperId = 'pagerDutyServiceWrapperId';
        String pagerDutyServiceWrapperName = 'pagerDutyServiceWrapperName';

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getPagerDutyMock(pagerDutyServiceWrapperId, pagerDutyServiceWrapperName, true)));

        IntegrationSettings.PagerDutySettings result;
        Test.startTest();
            result = (IntegrationSettings.PagerDutySettings) IntegrationSettings.PAGER_DUTY.getPagerDutySettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.isConnectionValid);
    }

    @IsTest
    static void getPagerDutySettings_ConnectionInvalid() {
        String pagerDutyServiceWrapperId = 'pagerDutyServiceWrapperId';
        String pagerDutyServiceWrapperName = 'pagerDutyServiceWrapperName';

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getPagerDutyMock(pagerDutyServiceWrapperId, pagerDutyServiceWrapperName, false)));

        IntegrationSettings.PagerDutySettings result;
        Test.startTest();
            result = (IntegrationSettings.PagerDutySettings) IntegrationSettings.PAGER_DUTY.getPagerDutySettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isFalse(result.isConnectionValid);
    }

    @IsTest
    static void getPagerDutyServices() {
        String pagerDutyServiceWrapperId = 'pagerDutyServiceWrapperId';
        String pagerDutyServiceWrapperName = 'pagerDutyServiceWrapperName';

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getPagerDutyMock(pagerDutyServiceWrapperId, pagerDutyServiceWrapperName, true)));

        List<PagerDutyService.PagerDutyServiceWrapper> testWrappers;
        Test.startTest();
            testWrappers = (List<PagerDutyService.PagerDutyServiceWrapper>) IntegrationSettings.PAGER_DUTY.getPagerDutyServices();
        Test.stopTest();

        Assert.areNotEqual(null, testWrappers);
        Assert.isFalse(testWrappers.isEmpty());
        Assert.areEqual(1, testWrappers.size());
        Assert.areEqual(pagerDutyServiceWrapperId, testWrappers.get(0).id);
        Assert.areEqual(pagerDutyServiceWrapperName, testWrappers.get(0).name);
    }
    
    @IsTest
    static void savePagerDutySettings() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock()));
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        IntegrationSettings.PagerDutySettings data = new IntegrationSettings.PagerDutySettings();
        data.enabled = true;
        data.token = 'new';
        data.serviceId = 'new';
        data.serviceIntegrationKey = 'new';
        data.userEmail = 'new';

        String result;
        Test.startTest();
            result = IntegrationSettings.PAGER_DUTY.savePagerDutySettings(data);
        Test.stopTest();

        Assert.areEqual(Constants.UI.RESULT_SUCCESS, result);
        Assert.areNotEqual(CUSTOM_SETTING_PAGER_DUTY_TOKEN, ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c);
        Assert.areNotEqual(CUSTOM_SETTING_PAGER_DUTY_SERVICE_ID, ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_ID__c);
        Assert.areNotEqual(CUSTOM_SETTING_PAGER_DUTY_SERVICE_INTEGRATION_KEY, ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_Integration_Key__c);
        Assert.areNotEqual(CUSTOM_SETTING_PAGER_DUTY_USER_EMAIL, ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_User_Email__c);
        Assert.isTrue(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c);
    }

    // Slack Tests
    @IsTest
    static void getSlackSettings_ConnectionValid() {
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackUsersMock(true));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        IntegrationSettings.SlackSettings result;
        Test.startTest();
            result = IntegrationSettings.SLACK.getSlackSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result.oAuthEndpoint);
        Assert.isTrue(result.isConnectionValid);
    }

    @IsTest
    static void getSlackSettings_ConnectionInvalid() {
        TestDataFactory.createSlackSettings();
        Slack_Settings__c slackSettings = Slack_Settings__c.getOrgDefaults();
        slackSettings.Slack_Message_Template__c = '';
        upsert slackSettings;

        Pharos_Settings__c pharosSettings = Pharos_Settings__c.getOrgDefaults();
        pharosSettings.Slack_App_Client_Id__c = 'slackAppClientId';
        upsert pharosSettings;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackUsersMock(false));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        IntegrationSettings.SlackSettings result;
        Test.startTest();
            result = IntegrationSettings.SLACK.getSlackSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result.oAuthEndpoint);
        Assert.isFalse(result.isConnectionValid);
    }

    @IsTest
    static void test_sendMessageToSlackWithChartAttachments_fallsBackWhenUploadUrlInvalid() {
        // Given
        TestDataFactory.createSlackSettings();
        PermissionsUtil.SlackIntegrationEnabled = true;

        ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
        Blob fakeImageBlob = Blob.valueOf('fakeimage');
        client.setChartImages(new Map<String, String>{
            ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name() => EncodingUtil.base64Encode(fakeImageBlob)
        });

        Map<String, HttpCalloutMock> endpoint2Mock = new Map<String, HttpCalloutMock>{
            // Return a valid JSON body with ok=false so SlackService.getUploadUrl() returns empty string.
            ConfigUtil.SLACK_GET_UPLOAD_URL_EXTERNAL_ENDPOINT => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{"ok":false,"error":"invalid_auth"}'
            ),
            // Fallback plain message post must still succeed.
            ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{"ok":true}'
            )
        };

        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2Mock);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        // When
        Test.startTest();
        SlackService.sendMessageToSlackWithChartAttachments('hello', 'C123', client);
        Test.stopTest();

        // Then
        Assert.areNotEqual(
            null,
            multiCalloutMock.getRequest(ConfigUtil.SLACK_GET_UPLOAD_URL_EXTERNAL_ENDPOINT),
            'Upload URL endpoint should be called'
        );
        Assert.areNotEqual(
            null,
            multiCalloutMock.getRequest(ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT),
            'Should fall back to chat.postMessage when attachments fail'
        );
    }

    @IsTest
    static void getSlackChannels_byNameFailedByBadJson() {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQueryFailedByBadJSON(query));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SlackService.SlackChannelsResponse result;
        Exception expectedException;
        Test.startTest();
            try {
                result = (SlackService.SlackChannelsResponse) IntegrationSettings.SLACK.getSlackChannels(query);
            } catch(Exception ex) {
                expectedException = ex;
            }
        Test.stopTest();

        Assert.areEqual(null, result);
        Assert.areNotEqual(null, expectedException);
        Assert.isTrue(expectedException.getMessage().contains('Unexpected character'));
    }

    @IsTest
    private static void getSlackChannels_byNameFailedByJiraRateLimitError() {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQueryFailedByToManyRequests(query));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SlackService.SlackChannelsResponse result;
        Exception expectedException;
        Test.startTest();
            try {
                result = (SlackService.SlackChannelsResponse) IntegrationSettings.SLACK.getSlackChannels(query);
            } catch(Exception ex) {
                expectedException = ex;
            }
        Test.stopTest();

        Assert.areEqual(null, result);
        Assert.areNotEqual(null, expectedException);
        Assert.isTrue(expectedException.getMessage().contains('429'));
        Assert.isTrue(expectedException.getMessage().contains('Too many requests'));
    }

    @IsTest
    static void getSlackChannels_byQueryFoundSuccess() {
        getSlackChannels_byQuerySuccess(true);
    }

    @IsTest
    static void getSlackChannels_byQueryNotFoundSuccess() {
        getSlackChannels_byQuerySuccess(false);
    }

    private static void getSlackChannels_byQuerySuccess(Boolean foundChannelSuccess) {
        String resp;
        String query = SLACK_CHANNEL_NAME;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByQuery(query, foundChannelSuccess));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SlackService.SlackChannelsResponse result;
        Test.startTest();
            result = (SlackService.SlackChannelsResponse) IntegrationSettings.SLACK.getSlackChannels(query);
        Test.stopTest();

        Assert.isTrue(result.ok);

        if (foundChannelSuccess) {
            Assert.areNotEqual(true, result.channels.isEmpty());
            Assert.areEqual(SLACK_CHANNEL_ID, result.channels.get(0).id);
            Assert.areEqual(SLACK_CHANNEL_NAME, result.channels.get(0).name);
        } else {
            Assert.areEqual(true, result.channels.isEmpty());
        }
    }

    @IsTest
    static void getSlackChannels_retrieveAllSuccess() {
        getSlackChannels_retrieveSuccess(SLACK_CHANNEL_EMPTY_CURSOR);
    }

    @IsTest
    static void getSlackChannels_retrieveByCursorSuccess() {
        getSlackChannels_retrieveSuccess(SLACK_CHANNEL_NEXT_CURSOR);
    }

    private static void getSlackChannels_retrieveSuccess(String cursor) {
        String resp;
        TestDataFactory.createSlackSettings();

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackChannelsByCursor(cursor));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SlackService.SlackChannelsResponse result;
        Test.startTest();
            result = (SlackService.SlackChannelsResponse) IntegrationSettings.SLACK.getSlackChannels(cursor);
        Test.stopTest();

        Assert.areEqual(true, result.ok);
        Assert.areNotEqual(true, result.channels.isEmpty());
        Assert.areEqual(SLACK_CHANNEL_ID, result.channels.get(0).id);
        Assert.areEqual(SLACK_CHANNEL_NAME, result.channels.get(0).name);
        Assert.areNotEqual(null, result.response_metadata.next_cursor);
    }

    @IsTest
    private static void getSlackUsers() {
        SlackService.SlackUsersResponse result;

        ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c = 'someTestToken';
        upsert ConfigUtil.SLACK_SETTINGS;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getSlackUsersMock(true));
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
            result = (SlackService.SlackUsersResponse) IntegrationSettings.SLACK.getSlackUsers(null);
        Test.stopTest();
        
        Assert.areNotEqual(null, result);
        Assert.areEqual(true, result.ok);
        Assert.areNotEqual(null, result.members);
        Assert.areNotEqual(null, result.response_metadata);
        Assert.areEqual('nextCursor', result.response_metadata.next_cursor);
        Assert.areEqual('someUserName1', result.members.get(0).name);
        Assert.areEqual('someUserName2', result.members.get(1).name);
    }

    @IsTest
    static void saveSlackSettings() {
        String result;

        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        
        IntegrationSettings.SlackSettings data = new IntegrationSettings.SlackSettings();
        data.slackEnabled = true;
        data.slackToken = 'sometoken';

        Test.startTest();
            result = IntegrationSettings.SLACK.saveSlackSettings(data);
        Test.stopTest();

        Assert.areEqual(Constants.UI.RESULT_SUCCESS, result);
        Assert.isTrue(ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c);
        Assert.areEqual('sometoken', ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c);
    }

    // Splunk Tests
    @IsTest
    static void getSplunkSettings() {
        IntegrationSettings.SplunkSettings result;

        Test.startTest();
            result = IntegrationSettings.SPLUNK.getSplunkSettings();
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.enabled);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_URL, result.url);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_TOKEN, result.token);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_EVENT_COLLECTOR_TOKEN, result.ecToken);
        Assert.isTrue(result.logFields.isEmpty());
        Assert.isFalse(result.config.isEmpty());
    }

    @IsTest
    static void setSplunkSettings() {
        IntegrationSettings.SplunkSettings result;

        Test.startTest();
            result = IntegrationSettings.SPLUNK.setSplunkSettings(new Map<String, Object>{ 'enabled' => false });
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isFalse(result.enabled);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_URL, result.url);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_TOKEN, result.token);
        Assert.areEqual(CUSTOM_SETTING_SPLUNK_EVENT_COLLECTOR_TOKEN, result.ecToken);
        Assert.isTrue(result.logFields.isEmpty());
        Assert.isFalse(result.config.isEmpty());
    }

    @IsTest
    static void saveSplunkSettings() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getRemoteSiteSettingsMock()));
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());

        IntegrationSettings.SplunkSettings inputData = new IntegrationSettings.SplunkSettings();
        inputData.enabled = false;
        inputData.url = 'newUrl';
        inputData.token = 'newToken';
        inputData.ecToken = 'newEventCollectorToken';
        inputData.config = new List<String>();
        inputData.logFields = new List<Map<String, String>>();

        Test.startTest();
            IntegrationSettings.SPLUNK.saveSplunkSettings(inputData);
        Test.stopTest();

        Assert.isFalse(ConfigUtil.SPLUNK_SETTINGS.Splunk_Enabled__c);
        Assert.areNotEqual(CUSTOM_SETTING_SPLUNK_URL, ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c);
        Assert.areNotEqual(CUSTOM_SETTING_SPLUNK_TOKEN, ConfigUtil.SPLUNK_SETTINGS.Splunk_Token__c);
        Assert.areNotEqual(CUSTOM_SETTING_SPLUNK_EVENT_COLLECTOR_TOKEN, ConfigUtil.SPLUNK_SETTINGS.Splunk_Event_Collector_Token__c);
    }

    @IsTest
    static void validateSplunkEventCollectorConnection() {
        Boolean result;

        Test.startTest();
            result = IntegrationSettings.SPLUNK.validateSplunkEventCollectorConnection(new Map<String, Object>());
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result);
    }

    // Teams Tests
    @IsTest
    static void getTeamsSettings_ConnectionValid() {
        Graph_API_Settings__c graphApiSettings = Graph_API_Settings__c.getOrgDefaults();
        graphApiSettings.Tenant_Id__c = 'tenantId';
        upsert graphApiSettings;

        IntegrationSettings.TeamsSettings settings;

        GraphAPIService.OrganizationWrapper organizationWrapper = new GraphAPIService.OrganizationWrapper();
        organizationWrapper.value = new List<GraphAPIService.Organization>{
            new GraphAPIService.Organization('testId')
        };

        Test.setMock(
            HttpCalloutMock.class, 
            new TestDataFactory.MultiRequestMock(
                new Map<String, HttpCalloutMock>{
                    GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT => new TestDataFactory.SingleRequestMock(
                        200,
                        'OK',
                        JSON.serialize(organizationWrapper)
                    )
                }
            )
        );

        Test.startTest();
            settings = IntegrationSettings.TEAMS.getTeamsSettings();
        Test.stopTest();

        Assert.areNotEqual(null, settings);
        Assert.areNotEqual(null, settings.oAuthEndpoint);
        Assert.isTrue(settings.isConnectionValid);
    }

    @IsTest
    static void getTeamsSettings_ConnectionInvalid() {
        Graph_API_Settings__c graphApiSettings = Graph_API_Settings__c.getOrgDefaults();
        graphApiSettings.Tenant_Id__c = 'tenantId';
        upsert graphApiSettings;

        IntegrationSettings.TeamsSettings settings;

        GraphAPIService.OrganizationWrapper organizationWrapper = new GraphAPIService.OrganizationWrapper();
        organizationWrapper.value = new List<GraphAPIService.Organization>{
            new GraphAPIService.Organization('testId')
        };

        Test.setMock(
            HttpCalloutMock.class, 
            new TestDataFactory.MultiRequestMock(
                new Map<String, HttpCalloutMock>{
                    GraphAPIService.GRAPH_API_GET_ORGANIZATION_ENDPOINT => new TestDataFactory.SingleRequestMock(
                        404,
                        'Not Found',
                        JSON.serialize(organizationWrapper)
                    )
                }
            )
        );

        Test.startTest();
            settings = IntegrationSettings.TEAMS.getTeamsSettings();
        Test.stopTest();

        Assert.areNotEqual(null, settings);
        Assert.areNotEqual(null, settings.oAuthEndpoint);
        Assert.isFalse(settings.isConnectionValid);
    }

    @IsTest
    static void setTeamsSettings() {
        Graph_API_Settings__c graphApiSettings = Graph_API_Settings__c.getOrgDefaults();
        graphApiSettings.Enabled__c = false;
        upsert graphApiSettings;

        Map<String, Object> inputSettings = new Map<String, Object>{
            'enabled' => true
        };

        IntegrationSettings.TeamsSettings settings;

        Test.startTest();
            settings = IntegrationSettings.TEAMS.setTeamsSettings(inputSettings);
        Test.stopTest();

        Assert.areNotEqual(null, settings);
        Assert.isTrue(ConfigUtil.GRAPH_API_SETTINGS.Enabled__c);
    }

    @IsTest
    static void getTeams() {
        GraphAPIService.TeamRequestWrapper wrapper;

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(
            new Map<String, HttpCalloutMock>{
                GraphAPIService.GRAPH_API_GET_ALL_TEAMS_ENDPOINT => getAllTeamsMock()
            }
        ));

        Test.startTest();
            wrapper = (GraphAPIService.TeamRequestWrapper) IntegrationSettings.TEAMS.getTeams('');
        Test.stopTest();

        Assert.areNotEqual(null, wrapper);
        Assert.areNotEqual(null, wrapper.value);
        Assert.areEqual(1, wrapper.value.size());
    }

    @IsTest
    static void getTeamById() {
        String teamId = 'testTeamId';
        String teamDisplayName = 'testDisplayName';

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(new Map<String, HttpCalloutMock>{
            GraphAPIService.GRAPH_API_ENPOINT + GraphAPIService.GRAPH_API_PARAM_TEAMS + '/' + teamId => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new GraphAPIService.Team(teamId, teamDisplayName))
            )
        }));

        GraphAPIService.Team testTeam;
        Test.startTest();
            testTeam = (GraphAPIService.Team) IntegrationSettings.TEAMS.getTeamById(teamId);
        Test.stopTest();

        Assert.areNotEqual(null, testTeam);
        Assert.areEqual(teamId, testTeam.id);
        Assert.areEqual(teamDisplayName, testTeam.displayName);

    }

    @IsTest
    static void getTeamChannels() {
        List<GraphAPIService.Channel> testChannels;
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(new Map<String, HttpCalloutMock>{
            String.format(GraphAPIService.GRAPH_API_GET_TEAM_CHANNELS, new List<String>{ TEST_GRAPH_API_TEAM_ID }) => getChannelsMock()
        }));

        Test.startTest();
            testChannels = (List<GraphAPIService.Channel>) IntegrationSettings.TEAMS.getTeamChannels(TEST_GRAPH_API_TEAM_ID);
        Test.stopTest();

        Assert.areNotEqual(null, testChannels);
        Assert.areEqual(1, testChannels.size());
    }

    private static String getGitAPIUserReposByNameEndpoint(String reponame) {
        return getGitAPIUserReposByNameEndpoint(GitHubUtils.GIT_USERNAME, reponame);
    }

    private static String getGitAPIUserReposByNameEndpoint(String owner, String reponame) {
        return String.format(GitHubUtils.GIT_API_GET_REPOS_INFO, new List<String>{owner, reponame});
    }

    private static String getGitAPIUserExtRepoBranchesByNameEndpoint() {
        return String.format(GitHubUtils.GIT_API_GET_REPO_BRANCHES_INFO, new List<String>{TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME, TEST_GIT_API_EXT_BRANCH_NAME});
    }

    private static TestDataFactory.SingleRequestMock getGitAPIUserReposByNameMock() {
        Map<String, Object> objectRepos = new Map<String, Object> {
            'name' => TEST_GIT_API_EXT_REPONAME,
            'archived' => false,
            'disabled' => false,
            'owner' => new Map<String, Object> {
                'login' => TEST_GIT_API_EXT_USERNAME
            }
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(objectRepos)
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getGitAPIUserExtRepoBranchesByNameMock() {
        Map<String, Object> objectRepos = new Map<String, Object> {
            'name' => TEST_GIT_API_EXT_BRANCH_NAME
        };

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(objectRepos)
        );
        return singleRequestMock;
    }

    // Global Mocks
    private static Map<String, HttpCalloutMock> getRemoteSiteSettingsMock() {
        return getRemoteSiteSettingsMock('someURL');
    }

    private static Map<String, HttpCalloutMock> getRemoteSiteSettingsMock(String endpointUrl) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        MetadataServiceUtil.RemoteSiteSettingsWrapper wrapper1 = new MetadataServiceUtil.RemoteSiteSettingsWrapper();
        wrapper1.Id = 'someId';
        wrapper1.IsActive = true;
        wrapper1.SiteName = 'someSiteName';
        wrapper1.EndpointUrl = endpointUrl;
        data.put(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS, new List<MetadataServiceUtil.RemoteSiteSettingsWrapper>());
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(data)
        );
        result.put(ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY, singleRequestMock);
        return result;
    }

    // Git Hub Mocks
    private static TestDataFactory.SingleRequestMock getGitAPIUserReposByNameNotFoundMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            404,
            'OK',
            'some error message'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getGitAPIUserExtRepoBranchesByNameNotFoundMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            404,
            'OK',
            'some error message'
        );
        return singleRequestMock;
    }

    // Jira Mocks
    private static Map<String, HttpCalloutMock> getJiraSettingsMock(Boolean isCloud) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(JiraService.getService().getProjectsEndpoint(), getProjectsMock(isCloud));
        endpoint2TestResp.put(JiraService.getService().getProjectEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID), JiraNotificationBatchTest.getProjectMock());
        endpoint2TestResp.put(JiraService.getService().getProjectIssueTypesEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID), JiraNotificationBatchTest.getProjectIssueTypesMock());
        endpoint2TestResp.put(JiraService.getService().getProjectIssueFieldsEndpoint(JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID, JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID), JiraNotificationBatchTest.getProjectIssueFieldsMock());
        endpoint2TestResp.put(JiraService.getService().getPrioritySchemesEndpoint(), JiraNotificationBatchTest.createPrioritySchemesMock());
        endpoint2TestResp.put(JiraService.getService().getPrioritiesEndpoint(), JiraNotificationBatchTest.createPrioritiesMock());
        return endpoint2TestResp;
    }

    private static JiraNotificationBatchTest.SingleRequestMock getProjectsMock(Boolean isCloud) {
        List<JiraService.JiraProject> projects = new List<JiraService.JiraProject>();
        JiraService.JiraProject testProject = new JiraService.JiraProject();
        testProject.id = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;
        testProject.key = JiraNotificationBatchTest.JIRA_MOCK_PROJECT_ID;

        JiraService.JiraProjectIssueField jiraField = new JiraService.JiraProjectIssueField();
        jiraField.required = false;
        jiraField.name = JiraNotificationBatchTest.JIRA_MOCK_EPICK_NAME;
        jiraField.key = JiraNotificationBatchTest.JIRA_MOCK_EPICK_ID;

        List<JiraService.JiraProjectIssueType> issueTypes = new List<JiraService.JiraProjectIssueType>();
        JiraService.JiraProjectIssueType testIssueType = new JiraService.JiraProjectIssueType();
        testIssueType.id = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID;
        testIssueType.name = JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_NAME;
        testIssueType.fields = new Map<String, JiraService.JiraProjectIssueField>{JiraNotificationBatchTest.JIRA_MOCK_ISSUE_TYPE_ID => jiraField};

        issueTypes.add(testIssueType);
        testProject.issueTypes = issueTypes;
        projects.add(testProject);

        JiraService.JiraProjectList listResp = new JiraService.JiraProjectList();
        listResp.projects = projects;

        JiraNotificationBatchTest.SingleRequestMock getProjectsRespMock = new JiraNotificationBatchTest.SingleRequestMock(
            200,
            'OK',
            isCloud ? JSON.serialize(listResp) : JSON.serialize(projects)
        );
        return getProjectsRespMock;
    }

    // Open AI Mocks
    private static Map<String, HttpCalloutMock> openAiValidationMock() {
        return new Map<String, HttpCalloutMock>{
            ConfigUtil.OPEN_AI_USAGE_ENDPOINT => new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                ''
            )
        };
    }

    // Pager Duty Mocks
    private static Map<String, HttpCalloutMock> getPagerDutyMock(String pagerDutyServiceWrapperId, String pagerDutyServiceWrapperName, Boolean isValidMock) {
        PagerDutyService.PagerDutyServiceWrapper pagerDutyServiceWrapper = new PagerDutyService.PagerDutyServiceWrapper();
        pagerDutyServiceWrapper.id = pagerDutyServiceWrapperId;
        pagerDutyServiceWrapper.name = pagerDutyServiceWrapperName;

        PagerDutyService.PagerDutyServicesResponse pagerDutyServicesResponse = new PagerDutyService.PagerDutyServicesResponse();
        pagerDutyServicesResponse.services = new List<PagerDutyService.PagerDutyServiceWrapper>{ pagerDutyServiceWrapper };

        return new Map<String, HttpCalloutMock>{
            ConfigUtil.PAGER_DUTY_SERVICES_ENDPOINT => new TestDataFactory.SingleRequestMock(
                isValidMock ? 200 : 404,
                isValidMock ? 'OK' : 'Not Found',
                JSON.serialize(pagerDutyServicesResponse)
            )
        };
    }

    // Slack Mocks
    private static Map<String, HttpCalloutMock> getSlackUsersMock(Boolean isConnectionValid) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        Map<String, Object> data = new Map<String, Object>();

        SlackService.SlackUsersResponse wrapper1 = new SlackService.SlackUsersResponse();
        SlackService.SlackUser user1 = new SlackService.SlackUser();
        user1.id = 'someSlackId1';
        user1.name = 'someUserName1';
        SlackService.SlackUser user2 = new SlackService.SlackUser();
        user2.id = 'someSlackId2';
        user2.name = 'someUserName2';
        wrapper1.members = new List<SlackService.SlackUser>{user1, user2};
        wrapper1.ok = true;
        wrapper1.response_metadata = new SlackService.SlackChannelsResponseMetadata();
        wrapper1.response_metadata.next_cursor = 'nextCursor';

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            isConnectionValid ? 200 : 404,
            isConnectionValid ? 'OK' : 'Not Found',
            JSON.serialize(wrapper1)
        );
        result.put(ConfigUtil.SLACK_USER_LIST_ENDPOINT, singleRequestMock);
        return result;
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQueryFailedByBadJSON(String query) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '<!DOCTYPE html><html><body><h1>some server error</h1></body>'
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQueryFailedByToManyRequests(String query) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            429,
            'OK',
            'Too many requests'
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByQuery(String query, Boolean foundChannelSuccess) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        SlackService.SlackChannelResponse resp = new SlackService.SlackChannelResponse();
        resp.ok = true;

        SlackService.SlackChannel channel1 = new SlackService.SlackChannel();
        channel1.id = SLACK_CHANNEL_ID;
        channel1.name = SLACK_CHANNEL_NAME;
        resp.channel = foundChannelSuccess ? channel1 : null;

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(resp)
        );
        String endpoint = ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + query;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    private static Map<String, HttpCalloutMock> getSlackChannelsByCursor(String cursor) {
        Map<String, HttpCalloutMock> result = new Map<String, HttpCalloutMock>();

        SlackService.SlackChannelsResponse resp = new SlackService.SlackChannelsResponse();
        resp.channels = new List<SlackService.SlackChannel>();
        resp.ok = true;
        resp.response_metadata = new SlackService.SlackChannelsResponseMetadata();
        resp.response_metadata.next_cursor = SLACK_CHANNEL_NEXT_CURSOR;

        SlackService.SlackChannel channel1 = new SlackService.SlackChannel();
        channel1.id = SLACK_CHANNEL_ID;
        channel1.name = SLACK_CHANNEL_NAME;
        resp.channels.add(channel1);

        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(resp)
        );
        String endpoint = String.isNotBlank(cursor) ? (ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT + '&cursor=' + cursor) : ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT;
        result.put(endpoint, singleRequestMock);
        return result;
    }

    // Teams Mocks
    private static TestDataFactory.SingleRequestMock getAllTeamsMock() {
        GraphAPIService.TeamRequestWrapper wrapper = new GraphAPIService.TeamRequestWrapper();
        wrapper.value = new List<GraphAPIService.Team>{
            new GraphAPIService.Team(TEST_GRAPH_API_TEAM_ID, TEST_GRAPH_API_TEAM_DISPLAY_NAME)
        };
        return new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(wrapper)
        );
    }

    private static TestDataFactory.SingleRequestMock getChannelsMock() {
        GraphAPIService.TeamChannelWrapper wrapper = new GraphAPIService.TeamChannelWrapper();
        wrapper.value = new List<GraphAPIService.Channel>{
            new GraphAPIService.Channel(TEST_GRAPH_API_TEAM_CHANNEL_ID, TEST_GRAPH_API_TEAM_CHANNEL_DISPLAY_NAME)
        };
        return new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(wrapper)
        );
    }
}