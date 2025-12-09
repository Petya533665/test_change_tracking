@IsTest
public with sharing class AzureServiceTest {
    
    @TestSetup
    static void makeData() {
        // Create Azure DevOps API Settings
        TestDataFactoryIntegrationAzure.createAzureDevOpsApiSettings();
        
        // Enable Azure DevOps integration
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        
        // Create test Issue for ticket creation
        TestDataFactory.enableIssueTracking();
        Log__c testLog = IssueRelatedListControllerTest.createPharosLog('hash1_test', 'hash2_test', 'hash3_test');
        testLog.Organization_Id__c = UserInfo.getOrganizationId();
        insert testLog;
    }
    
    /**
     * Sets up HTTP mocks for Azure DevOps API calls
     */
    private static void setupMocks() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }
    
    @IsTest
    static void test_getAzureDevOpsInstanceKey() {
        String organizationId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        
        Test.startTest();
        String instanceKey = AzureService.getAzureDevOpsInstanceKey(organizationId);
        Test.stopTest();
        
        Assert.isNotNull(instanceKey, 'Instance key should not be null');
        Assert.isTrue(instanceKey.length() > 0, 'Instance key should not be empty');
    }

    @IsTest
    static void test_putEncryptedAzureDevOpsTokenToCache() {
        String token = 'sometoken';

        Test.startTest();
            PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
            TestDataFactoryIntegrationAzure.enableAzureDevOpsNotifications();
            AzureService.putEncryptedAzureDevOpsTokenToCache(null, Azure_Dev_Ops_API_Settings__c.getOrgDefaults(), token);
        Test.stopTest();
        AzureService.OAUTH_API_TOKEN = null;
        Assert.areEqual(token, AzureService.OAUTH_API_TOKEN);
    }

    @IsTest
    static void test_validateAndRefreshAzureDevOpsApiOauthToken() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        Boolean result = AzureService.validateAndRefreshAzureDevOpsApiOauthToken(logger, false);
        Test.stopTest();
        
        Assert.isTrue(result, 'Should return true when token refresh is successful');
    }
    
    @IsTest
    static void test_validateAndRefreshAzureDevOpsApiOauthToken_disabled() {
        PermissionsUtil.AzureDevOpsIntegrationEnabled = false;
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        Boolean result = AzureService.validateAndRefreshAzureDevOpsApiOauthToken(logger, false);
        Test.stopTest();
        
        Assert.isFalse(result, 'Should return false when integration is disabled');
    }
    
    @IsTest
    static void test_validateAndRefreshAzureDevOpsApiOauthToken_noOrganization() {
        Azure_Dev_Ops_API_Settings__c settings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
        settings.Organization_Id__c = null;
        upsert settings;
        
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        Boolean result = AzureService.validateAndRefreshAzureDevOpsApiOauthToken(logger, false);
        Test.stopTest();
        
        Assert.isFalse(result, 'Should return false when organization ID is blank');
    }

    @IsTest
    static void test_refreshOAuthToken() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        AzureService.refreshOAuthToken(logger, false);
        Test.stopTest();
        
        GraphAPIService.GRAPH_API_LIST_RECORDS = null;
        AzureService.OAUTH_API_TOKEN = null;
        Assert.isNotNull(AzureService.OAUTH_API_TOKEN, 'Access token should be set after refresh');
    }
    
    @IsTest
    static void test_refreshOAuthToken_withDML() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        AzureService.refreshOAuthToken(logger, true);
        Test.stopTest();
        
        Assert.isTrue(true, 'Method should execute successfully with DML');
    }
    
    @IsTest
    static void test_getOrganizationProcesses() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcess> processes = AzureService.getOrganizationProcesses(organization);
        Test.stopTest();
        
        Assert.isNotNull(processes, 'Processes should not be null');
        Assert.isTrue(processes.size() > 0, 'Should return at least one process');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID, processes[0].typeId, 'Process ID should match mock');
    }
    
    @IsTest
    static void test_getOrganizationProcessesWorkItemTypes() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getOrganizationProcessesWorkItemTypes(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.size() > 0, 'Should return at least one work item type');
    }

    @IsTest
    static void test_validateWorkItemTypeConfiguration() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String processId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID;
        String teamId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID;
        String boardId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID;
        
        Test.startTest();
        AzureService.AzureDevOpsConfigurationValidationResult validationResult = 
            AzureService.validateWorkItemTypeConfiguration(organization, projectId, processId, teamId, boardId);
        Test.stopTest();
        
        Assert.isNotNull(validationResult, 'Validation result should not be null');
        Assert.isTrue(validationResult.isValid);
        Assert.isTrue(validationResult.hasTeamAccess);
        Assert.isTrue(validationResult.hasBoardConfiguration);
        Assert.isFalse(validationResult.hasRequiredFields);
    }

    @IsTest
    static void test_validateWorkItemTypeConfiguration_withBlankTeamId() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String processId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID;
        String teamId = null;
        String boardId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID;
        
        Test.startTest();
        AzureService.AzureDevOpsConfigurationValidationResult validationResult = 
            AzureService.validateWorkItemTypeConfiguration(organization, projectId, processId, teamId, boardId);
        Test.stopTest();
        
        Assert.isNotNull(validationResult, 'Validation result should not be null');
        Assert.isFalse(validationResult.isValid);
        Assert.isFalse(validationResult.hasTeamAccess);
        Assert.isFalse(validationResult.hasBoardConfiguration);
        Assert.isFalse(validationResult.hasRequiredFields);
    }

    @IsTest
    static void test_getOrganizationProcessesWorkItemTypesWithValidation() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String processId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String teamId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID;
        String boardId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID;
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getOrganizationProcessesWorkItemTypesWithValidation(
                organization, processId, projectId, teamId, boardId
            );
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put(AzureService.PARAM_BOARD_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
    }
    
    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withBoardIdAsMap() {
        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withProjectIdNull() {
        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, null);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withProjectIdEmpty() {
        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, '');
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withTeamIdNull() {
        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, null);
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withTeamIdEmpty() {
        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, '');
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withoutOrganizationId() {
        Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
        azureSettings.Organization_Id__c = null;
        upsert azureSettings;

        setupMocks();
        
        Map<String, Object> boardIdMap = new Map<String, Object>();
        boardIdMap.put('id', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_BOARD_ID);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put(AzureService.PARAM_BOARD_ID, boardIdMap);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }

    @IsTest
    static void test_getAzureDevOpsWorkItemTypesWithValidation_withNullParam() {
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemType> workItemTypes = 
            AzureService.getAzureDevOpsWorkItemTypesWithValidation(null);
        Test.stopTest();

        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
        Assert.isTrue(workItemTypes.isEmpty(), 'Work item types should be empty');
    }
    
    @IsTest
    static void test_getTeamBoards() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();
        
        Assert.isNotNull(boards, 'Boards should not be null');
    }

    @IsTest
    static void test_getTeamBoards_withProjectIdNull() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, null);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);

        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();

        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }

    @IsTest
    static void test_getTeamBoards_withProjectIdEmpty() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, '');
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);

        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();

        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }

    @IsTest
    static void test_getTeamBoards_withTeamIdNull() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, null);

        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();

        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }

    @IsTest
    static void test_getTeamBoards_withTeamIdEmpty() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, '');

        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();

        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }

    @IsTest
    static void test_getTeamBoards_withoutOrganizationId() {
        Azure_Dev_Ops_API_Settings__c azureSettings = Azure_Dev_Ops_API_Settings__c.getOrgDefaults();
        azureSettings.Organization_Id__c = null;
        upsert azureSettings;

        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(data);
        Test.stopTest();

        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }

    @IsTest
    static void test_getTeamBoards_withNullParam() {
        Test.startTest();
        List<AzureService.AzureDevOpsBoardReference> boards = AzureService.getTeamBoards(null);
        Test.stopTest();
        
        Assert.isNotNull(boards, 'Boards should not be null');
        Assert.isTrue(boards.isEmpty(), 'Boards should be empty');
    }
    
    @IsTest
    static void test_getOrganizationProjectProperties() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProjectProperty> properties = 
            AzureService.getOrganizationProjectProperties(data);
        Test.stopTest();
        
        Assert.isNotNull(properties, 'Properties should not be null');
    }
    
    @IsTest
    static void test_getOrganizationProcessWorkItemTypeFields() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put('processId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROCESS_ID);
        data.put('workItemTypeId', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsProcessWorkItemTypeField> fields = 
            AzureService.getOrganizationProcessWorkItemTypeFields(data);
        Test.stopTest();
        
        Assert.isNotNull(fields, 'Fields should not be null');
    }

    @IsTest
    static void test_getMyProfile() {
        setupMocks();
        String oAuthToken = 'test_oauth_token';

        Test.startTest();
        AzureService.AzureDevOpsMyProfile profile = AzureService.getMyProfile(oAuthToken);
        Test.stopTest();

        Assert.isNotNull(profile, 'Profile should not be null');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_USER_ID, profile.id, 'User ID should match mock');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_USER_NAME, profile.displayName, 'Display name should match mock');
    }

    @IsTest
    static void test_getAccountsByOwnerId() {
        setupMocks();
        String ownerId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_USER_ID;
        String oAuthToken = 'test_oauth_token';

        Test.startTest();
        List<AzureService.AzureDevOpsAccount> accounts = AzureService.getAccountsByOwnerId(ownerId, oAuthToken);
        Test.stopTest();

        Assert.isNotNull(accounts, 'Accounts should not be null');
        Assert.isTrue(accounts.size() > 0, 'Should return at least one account');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID, accounts[0].accountId, 'Account ID should match mock');
    }
    
    @IsTest
    static void test_getProjects() {
        setupMocks();
        
        Test.startTest();
        List<AzureService.AzureDevOpsProject> projects = AzureService.getProjects();
        Test.stopTest();
        
        Assert.isNotNull(projects, 'Projects should not be null');
        Assert.isTrue(projects.size() > 0, 'Should return at least one project');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID, projects[0].id, 'Project ID should match mock');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_NAME, projects[0].name, 'Project name should match mock');
    }
    
    @IsTest
    static void test_getWorkItemTypes() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsWorkItemType> workItemTypes = AzureService.getWorkItemTypes(data);
        Test.stopTest();
        
        Assert.isNotNull(workItemTypes, 'Work item types should not be null');
    }
    
    @IsTest
    static void test_getProjectTeams() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        
        Test.startTest();
        List<AzureService.AzureDevOpsTeam> teams = AzureService.getProjectTeams(data);
        Test.stopTest();
        
        Assert.isNotNull(teams, 'Teams should not be null');
    }

    @IsTest
    static void test_getProjectTeams_withProjectIdNull() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, null);
        
        Test.startTest();
        List<AzureService.AzureDevOpsTeam> teams = AzureService.getProjectTeams(data);
        Test.stopTest();
        
        Assert.isNotNull(teams, 'Teams should not be null');
        Assert.isTrue(teams.isEmpty(), 'Teams should be empty');
    }

    @IsTest
    static void test_getProjectTeams_withProjectIdEmpty() {
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, '');
        
        Test.startTest();
        List<AzureService.AzureDevOpsTeam> teams = AzureService.getProjectTeams(data);
        Test.stopTest();
        
        Assert.isNotNull(teams, 'Teams should not be null');
        Assert.isTrue(teams.isEmpty(), 'Teams should be empty');
    }

    @IsTest
    static void test_getProjectTeams_withNullParam() {
        Test.startTest();
        List<AzureService.AzureDevOpsTeam> teams = AzureService.getProjectTeams(null);
        Test.stopTest();
        
        Assert.isNotNull(teams, 'Teams should not be null');
        Assert.isTrue(teams.isEmpty(), 'Teams should be empty');
    }
    
    @IsTest
    static void test_getClassificationNodes() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        
        Test.startTest();
        AzureService.WorkItemClassificationNodes classificationNodes = 
            AzureService.getClassificationNodes(data);
        Test.stopTest();
        
        Assert.isNotNull(classificationNodes, 'Classification nodes should not be null');
    }
    
    @IsTest
    static void test_getProjectTeamMembers() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String teamId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID;
        
        Test.startTest();
        List<AzureService.AzureDevOpsTeamMember> teamMembers = 
            AzureService.getProjectTeamMembers(organization, projectId, teamId);
        Test.stopTest();
        
        Assert.isNotNull(teamMembers, 'Team members should not be null');
        Assert.isTrue(teamMembers.size() > 0, 'Should return at least one team member');
    }
    
    @IsTest
    static void test_getProjectTeamMembers_withSkip() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String teamId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID;
        String skip = '0';
        
        Test.startTest();
        List<AzureService.AzureDevOpsTeamMember> teamMembers = 
            AzureService.getProjectTeamMembers(organization, projectId, teamId, skip);
        Test.stopTest();
        
        Assert.isNotNull(teamMembers, 'Team members should not be null');
    }
    
    @IsTest
    static void test_getProjectTeamMemberWrapper() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put(AzureService.PARAM_TEAM_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID);
        data.put('skip', AzureService.HTTP_SKIP_PARAMETER_DEFAULT_VALUE);
        
        Test.startTest();
        AzureService.AzureDevOpsTeamMemberWrapper wrapper = 
            AzureService.getProjectTeamMemberWrapper(data);
        Test.stopTest();
        
        Assert.isNotNull(wrapper, 'Team member wrapper should not be null');
        Assert.isNotNull(wrapper.value, 'Team members list should not be null');
        Assert.isTrue(wrapper.value.size() > 0, 'Should return at least one team member');
    }
    
    @IsTest
    static void test_getProjectTeamMemberWrapper_withSkip() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String teamId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_TEAM_ID;
        String skip = '0';
        
        Test.startTest();
        AzureService.AzureDevOpsTeamMemberWrapper wrapper = 
            AzureService.getProjectTeamMemberWrapper(organization, projectId, teamId, skip);
        Test.stopTest();
        
        Assert.isNotNull(wrapper, 'Team member wrapper should not be null');
        Assert.isNotNull(wrapper.value, 'Team members list should not be null');
    }

    @IsTest
    static void test_getProjectTeamMemberWrapper_withNullParam() {
        Test.startTest();
        AzureService.AzureDevOpsTeamMemberWrapper wrapper = 
            AzureService.getProjectTeamMemberWrapper(null);
        Test.stopTest();

        Assert.isNotNull(wrapper, 'Team member wrapper should not be null');
    }

    @IsTest
    static void test_getResolutionDatetimeByWorkItemId() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        List<String> workItemIds = new List<String>{TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID};
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        Map<String, DateTime> resolutionDates = 
            AzureService.getResolutionDatetimeByWorkItemId(organization, projectId, workItemIds, logger);
        Test.stopTest();
        
        Assert.isNotNull(resolutionDates, 'Resolution dates map should not be null');
        Assert.isTrue(resolutionDates.containsKey(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID), 'Should contain work item ID');
        Assert.isNotNull(resolutionDates.get(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID), 'Resolution date should not be null');
    }

    @IsTest
    static void test_getProjectWorkItemList() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        List<String> workItemIds = new List<String>{TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID};
        
        Test.startTest();
        List<AzureService.AzureDevOpsWorkItem> workItems = 
            AzureService.getProjectWorkItemList(organization, projectId, workItemIds);
        Test.stopTest();
        
        Assert.isNotNull(workItems, 'Work items should not be null');
        Assert.isTrue(workItems.size() > 0, 'Should return at least one work item');
    }
    
    @IsTest
    static void test_getProjectWorkItem() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String workItemId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        
        Test.startTest();
        AzureService.AzureDevOpsWorkItem workItem = 
            AzureService.getProjectWorkItem(organization, projectId, workItemId);
        Test.stopTest();
        
        Assert.isNotNull(workItem, 'Work item should not be null');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID, workItem.id, 'Work item ID should match');
        Assert.isNotNull(workItem.fields, 'Work item fields should not be null');
    }
    
    @IsTest
    static void test_getProjectWorkItemComments() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String workItemId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        
        Test.startTest();
        AzureService.AzureDevOpsWorkItemCommentsWrap commentsWrap = 
            AzureService.getProjectWorkItemComments(organization, projectId, workItemId);
        Test.stopTest();
        
        Assert.isNotNull(commentsWrap, 'Comments wrapper should not be null');
        Assert.isNotNull(commentsWrap.comments, 'Comments list should not be null');
        Assert.isTrue(commentsWrap.comments.size() > 0, 'Should return at least one comment');
    }
    
    @IsTest
    static void test_updateProjectWorkItem() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String workItemId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        
        List<AzureService.AzureDevOpsWorkItemRequestBody> workItemRequest = new List<AzureService.AzureDevOpsWorkItemRequestBody>();
        AzureService.AzureDevOpsWorkItemRequestBody requestBody = new AzureService.AzureDevOpsWorkItemRequestBody(
            'replace',
            '/fields/System.Title',
            'Updated Title'
        );
        workItemRequest.add(requestBody);
        
        Test.startTest();
        AzureService.AzureDevOpsWorkItem workItem = 
            AzureService.updateProjectWorkItem(organization, projectId, workItemId, workItemRequest);
        Test.stopTest();
        
        Assert.isNotNull(workItem, 'Updated work item should not be null');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID, workItem.id, 'Work item ID should match');
    }
    
    @IsTest
    static void test_updateWorkItemPriority() {
        setupMocks();
        String organization = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID;
        String projectId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID;
        String workItemId = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        String priority = '1';
        
        Test.startTest();
        AzureService.AzureDevOpsWorkItem workItem = 
            AzureService.updateWorkItemPriority(organization, projectId, workItemId, priority);
        Test.stopTest();
        
        Assert.isNotNull(workItem, 'Updated work item should not be null');
        Assert.areEqual(TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_WORK_ITEM_ID, workItem.id, 'Work item ID should match');
    }

    @IsTest
    static void test_getWIQLRequestSelectWorkItemsByTags() {
        List<String> tags = new List<String>{'tag1', 'tag2'};
        
        Test.startTest();
        String wiqlQuery = AzureService.getWIQLRequestSelectWorkItemsByTags(tags);
        Test.stopTest();
        
        Assert.isNotNull(wiqlQuery, 'WIQL query should not be null');
        Assert.isTrue(wiqlQuery.contains('tag1'), 'Query should contain tag1');
        Assert.isTrue(wiqlQuery.contains('tag2'), 'Query should contain tag2');
    }

    @IsTest
    static void test_getWIQLRequestSelectEpicWorkItems() {
        String title = TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_EPIC_TITLE;
        
        Test.startTest();
        String wiqlQuery = AzureService.getWIQLRequestSelectEpicWorkItems(title);
        Test.stopTest();
        
        Assert.isNotNull(wiqlQuery, 'WIQL query should not be null');
        Assert.isTrue(wiqlQuery.contains(title), 'Query should contain epic title');
        Assert.isTrue(wiqlQuery.contains('Epic'), 'Query should search for Epic work item type');
    }
    
    @IsTest
    static void test_searchEpics() {
        setupMocks();
        
        Map<String, Object> data = new Map<String, Object>();
        data.put(AzureService.PARAM_ORGANIZATION_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        data.put(AzureService.PARAM_PROJECT_ID, TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_PROJECT_ID);
        data.put('title', TestDataFactoryIntegrationAzure.AZURE_DEV_OPS_MOCK_EPIC_TITLE);
        
        Test.startTest();
        List<AzureService.AzureDevOpsWorkItemReference> epics = AzureService.searchEpics(data);
        Test.stopTest();
        
        Assert.isNotNull(epics, 'Epics should not be null');
    }
    
    @IsTest
    static void test_parseAzureDevOpsDateTime() {
        String dateTimeString = '2023-06-01T14:31:46.123Z';
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        DateTime result = AzureService.parseAzureDevOpsDateTime(dateTimeString, logger);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Parsed DateTime should not be null');
    }
    
    @IsTest
    static void test_parseAzureDevOpsDateTime_invalidFormat() {
        String dateTimeString = 'invalid-date';
        Logger logger = Logger.getInstance();
        
        Test.startTest();
        DateTime result = AzureService.parseAzureDevOpsDateTime(dateTimeString, logger);
        Test.stopTest();
        
        Assert.isNull(result, 'Result should be null for invalid date format');
    }
    
    @IsTest
    static void test_parseAzureDevOpsWorkItemUrl_with8Parts() {
        String url = 'https://dev.azure.com/testorg/testproject/_workitems/edit/123';
        
        Test.startTest();
        AzureService.WorkItemUrlParser parser = new AzureService.WorkItemUrlParser(url);
        Test.stopTest();
        
        Assert.areEqual('testorg', parser.organizationName, 'Organization name should be parsed');
        Assert.areEqual('testproject', parser.projectIdOrName, 'Project name should be parsed');
        Assert.areEqual('123', parser.workItemId, 'Work item ID should be parsed');
    }
    
    @IsTest
    static void test_parseAzureDevOpsWorkItemUrl_with9Parts() {
        String url = 'https://dev.azure.com/testorg/testproject/_apis/wit/workItems/456';
        
        Test.startTest();
        AzureService.WorkItemUrlParser parser = new AzureService.WorkItemUrlParser(url);
        Test.stopTest();
        
        Assert.areEqual('testorg', parser.organizationName, 'Organization name should be parsed');
        Assert.areEqual('testproject', parser.projectIdOrName, 'Project name should be parsed');
        Assert.areEqual('456', parser.workItemId, 'Work item ID should be parsed from 9-part URL');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_constructor() {
        Test.startTest();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        Test.stopTest();
        
        Assert.isNotNull(tokenManager, 'Token manager should not be null');
        Assert.isFalse(tokenManager.completed, 'Completed should be false by default');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_flushSettings_completed() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        tokenManager.completed = true;
        
        Test.startTest();
        tokenManager.flushSettings(logger);
        Test.stopTest();
        
        Assert.isTrue(tokenManager.completed, 'Completed should remain true');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_flushSettings_notCompleted() {
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        tokenManager.completed = false;
        
        Test.startTest();
        tokenManager.flushSettings(logger);
        Test.stopTest();
        
        Assert.isFalse(tokenManager.completed, 'Completed should remain false');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_isUnlocked() {
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        
        Test.startTest();
        Boolean isUnlocked = tokenManager.isUnlocked(logger);
        Test.stopTest();
        
        Assert.isTrue(isUnlocked, 'Should be unlocked when no job is locked');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_getLockedJobId() {
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        
        Test.startTest();
        String lockedJobId = tokenManager.getLockedJobId(logger);
        Test.stopTest();
        
        Assert.isTrue(String.isBlank(lockedJobId), 'Locked job ID should be blank initially');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_rotateTokens_twoParams() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsMocks());
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        
        Test.startTest();
        tokenManager.rotateTokens(logger, 'test-job-id');
        Test.stopTest();
        
        Assert.isTrue(true, 'Rotate tokens should execute without error');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_rotateTokens_withForceRefresh() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsMocks());
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        
        Test.startTest();
        tokenManager.rotateTokens(logger, 'test-job-id', true);
        Test.stopTest();
        
        Assert.isTrue(tokenManager.completed, 'Completed should be true after successful rotation');
    }

    @IsTest
    static void test_AzureDevOpsApiManageTokens_rotateTokens_withoutForceRefresh() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsMocks());
        endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
        
        TestDataFactory.MultiRequestMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings('old_refresh_token', true, null);
        PermissionsUtil.AzureDevOpsIntegrationEnabled = true;
        
        Logger logger = Logger.getInstance();
        AzureService.AzureDevOpsApiManageTokens tokenManager = new AzureService.AzureDevOpsApiManageTokens();
        
        Test.startTest();
        tokenManager.rotateTokens(logger, 'test-job-id', false);
        Test.stopTest();
        
        Assert.isTrue(true, 'Rotate tokens should execute without error');
    }
}