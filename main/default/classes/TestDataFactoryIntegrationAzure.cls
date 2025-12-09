@IsTest
public with sharing class TestDataFactoryIntegrationAzure {
    
    // Mock constants
    public static final String AZURE_DEV_OPS_MOCK_ACCOUNT_ID = 'testaccount';
    public static final String AZURE_DEV_OPS_MOCK_PROJECT_ID = 'testproject';
    public static final String AZURE_DEV_OPS_MOCK_PROJECT_NAME = 'Test Project';
    public static final String AZURE_DEV_OPS_MOCK_TEAM_ID = 'testteam';
    public static final String AZURE_DEV_OPS_MOCK_TEAM_NAME = 'Test Team';
    public static final String AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID = 'Bug';
    public static final String AZURE_DEV_OPS_MOCK_ISSUE_TYPE_NAME = 'Bug';
    public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_ID = '12345';
    public static final String AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID = '54321';
    public static final String AZURE_DEV_OPS_MOCK_WORK_ITEM_URL = 'https://dev.azure.com/testaccount/testproject/_workitems/edit/12345';
    public static final String AZURE_DEV_OPS_MOCK_PROCESS_ID = 'adcc42ab-9882-485e-a3ed-7678f01f66bc';
    public static final String AZURE_DEV_OPS_MOCK_BOARD_ID = 'testboard';
    public static final String AZURE_DEV_OPS_MOCK_USER_ID = 'test-user-id';
    public static final String AZURE_DEV_OPS_MOCK_USER_NAME = 'Test User';
    public static final String AZURE_DEV_OPS_MOCK_FIELD_ID = 'System.Title';
    public static final String AZURE_DEV_OPS_MOCK_FIELD_NAME = 'Title';
    public static final String AZURE_DEV_OPS_MOCK_EPIC_ID = '99999';
    public static final String AZURE_DEV_OPS_MOCK_EPIC_TITLE = 'Test Epic';

    /**
     * Creates Azure Dev Ops API Settings custom setting with default test values
     */
    public static Azure_Dev_Ops_API_Settings__c createAzureDevOpsApiSettings() {
        return createAzureDevOpsApiSettings(AZURE_DEV_OPS_MOCK_ACCOUNT_ID, true);
    }

    /**
     * Creates Azure Dev Ops API Settings custom setting with custom values
     * @param organizationId - Azure DevOps organization ID
     * @param enabled - Whether the integration is enabled
     */
    public static Azure_Dev_Ops_API_Settings__c createAzureDevOpsApiSettings(String organizationId, Boolean enabled) {
        Azure_Dev_Ops_API_Settings__c azureSettings = new Azure_Dev_Ops_API_Settings__c();
        azureSettings.Organization_Id__c = organizationId;
        azureSettings.Enabled__c = enabled;
        azureSettings.Create_Unique_Tickets_by_Org__c = true;
        azureSettings.Auto_Generate_Similarity_Labels__c = true;
        azureSettings.Auto_Relate_Tickets_With_Similar_Errors__c = true;
        azureSettings.Synchronize_duplicate_tickets_and_issues__c = false;
        azureSettings.Synchronize_related_tickets_and_issues__c = false;
        azureSettings.Synchronize_completed_Status__c = false;
        azureSettings.Automatically_update_Issue_priority__c = false;
        azureSettings.Automatically_update_ticket_priority__c = false;
        insert azureSettings;
        return azureSettings;
    }

    public static void enableAzureDevOpsNotifications() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>1, 1=>1,	2=>1,
            3=>1, 4=>1,	5=>1,
            6=>1, 7=>1,	8=>1,
            9=>1, 10=>0, 11=>0,
            12=>1, 13=>0, 14=>0,
            15=>0, 16=>0, 17=>1,
            18=>1, 19=>0, 20=>1,
            21=>0, 22=>0, 23=>0,
            24=>0, 25=>0, 26=>0,
            27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }

    /**
     * Main method to create all Azure DevOps HTTP mocks
     */
    public static Map<String, HttpCalloutMock> createAzureDevOpsMocks() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        
        // Work Item endpoints
        String newTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID});
        endpoint2TestResp.put(newTicketEndpoint, getNewWorkItemMock());
        
        String existingTicketEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
        endpoint2TestResp.put(existingTicketEndpoint, getExistingWorkItemMock());
        
        String workItemEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_ID, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
        endpoint2TestResp.put(workItemEndpoint, getWorkItemMock());
        
        // Work Item Comment endpoint
        String workItemCommentEndpoint = String.format(AzureApiClient.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
        endpoint2TestResp.put(workItemCommentEndpoint, getWorkItemCommentMock());
        
        // Work Item Comments list endpoint
        String workItemCommentsEndpoint = String.format(AzureApiClient.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENTS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
        endpoint2TestResp.put(workItemCommentsEndpoint, getWorkItemCommentsMock());
        
        // Work Item Attachment endpoint
        String workItemAttachmentEndpoint = String.format(AzureApiClient.AZURE_DEVOPS_REST_API_WORK_ATTACHMENT, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, 'test.png'});
        endpoint2TestResp.put(workItemAttachmentEndpoint, getWorkItemAttachmentMock());
        
        // Project endpoints
        String projectsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_PROJECT, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID});
        endpoint2TestResp.put(projectsEndpoint, getProjectsMock());
        
        String projectPropertiesEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_PROJECT_PROPERTIES, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID});
        endpoint2TestResp.put(projectPropertiesEndpoint, getProjectPropertiesMock());
        
        // Work Item Type endpoints
        String workItemTypesEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, EncodingUtil.urlEncode(AZURE_DEV_OPS_MOCK_PROJECT_ID, 'UTF-8')});
        endpoint2TestResp.put(workItemTypesEndpoint, getWorkItemTypesMock());
        
        // Process endpoints
        String processesEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_PROCESSES_LIST, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID});
        endpoint2TestResp.put(processesEndpoint, getProcessesMock());
        
        String processWorkItemTypesEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE_BY_PROCESS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROCESS_ID});
        endpoint2TestResp.put(processWorkItemTypesEndpoint, getProcessWorkItemTypesMock());
        
        String processWorkItemFieldsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_PROCESS_WORK_ITEM_TYPE_FIELDS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROCESS_ID, AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID});
        endpoint2TestResp.put(processWorkItemFieldsEndpoint, getProcessWorkItemFieldsMock());
        
        // Team endpoints
        String teamsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_TEAMS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID});
        endpoint2TestResp.put(teamsEndpoint, getTeamsMock());
        
        String teamMembersEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_TEAM_MEMBERS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_TEAM_ID});
        endpoint2TestResp.put(teamMembersEndpoint, getTeamMembersMock());
        
        // Team members endpoint with skip parameter
        String teamMembersEndpointWithSkip = teamMembersEndpoint + AzureService.HTTP_SKIP_PARAMETER + '=' + AzureService.HTTP_SKIP_PARAMETER_DEFAULT_VALUE;
        endpoint2TestResp.put(teamMembersEndpointWithSkip, getTeamMembersMock());
        
        // Board endpoints
        String boardsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_BOARDS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_TEAM_ID});
        endpoint2TestResp.put(boardsEndpoint, getBoardsMock());
        
        String boardColumnsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_BOARD_COLUMNS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_TEAM_ID, AZURE_DEV_OPS_MOCK_BOARD_ID});
        endpoint2TestResp.put(boardColumnsEndpoint, getBoardColumnsMock());
        
        String teamSettingsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_TEAM_SETTINGS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_TEAM_ID});
        endpoint2TestResp.put(teamSettingsEndpoint, getTeamSettingsMock());
        
        String boardSettingsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_BOARD_SETTINGS, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_TEAM_ID, AZURE_DEV_OPS_MOCK_BOARD_ID});
        endpoint2TestResp.put(boardSettingsEndpoint, getBoardSettingsMock());
        
        // Classification nodes (Iterations and Areas)
        String iterationsEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_ITERATION, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AzureService.AZURE_DEVOPS_ITERATIONS});
        endpoint2TestResp.put(iterationsEndpoint, getClassificationNodesMock());
        
        String areasEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_ITERATION, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AzureService.AZURE_DEVOPS_AREAS});
        endpoint2TestResp.put(areasEndpoint, getClassificationNodesMock());
        
        // WIQL endpoint
        String wiqlEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WIQL, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID});
        endpoint2TestResp.put(wiqlEndpoint, getWiqlSearchMock());
        
        // Work Item List endpoint
        String workItemListEndpoint = String.format(AzureService.AZURE_DEVOPS_REST_API_WORK_ITEM_LIST, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_WORK_ITEM_ID});
        endpoint2TestResp.put(workItemListEndpoint, getWorkItemListMock());
        
        // Account endpoints
        endpoint2TestResp.put(AzureService.AZURE_DEVOPS_REST_API_MY_PROFILE, getMyProfileMock());
        
        // Mock for getAccountsByOwnerId with memberId parameter
        endpoint2TestResp.put(AzureService.getAccountsByOwnerIdEndpoint(AZURE_DEV_OPS_MOCK_USER_ID), getMyAccountsMock());
        
        return endpoint2TestResp;
    }

    // ========== Work Item Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getNewWorkItemMock() {
        AzureService.AzureDevOpsWorkItem newWorkItem = new AzureService.AzureDevOpsWorkItem();
        newWorkItem.id = AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID;
        newWorkItem.url = String.format(AzureService.FROMAT_WORK_ITEM_URL, 
            new List<String>{AZURE_DEV_OPS_MOCK_ACCOUNT_ID, AZURE_DEV_OPS_MOCK_PROJECT_ID, AZURE_DEV_OPS_MOCK_NEW_WORK_ITEM_ID});
        newWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
        newWorkItem.fields.Title = 'New Test Work Item';
        newWorkItem.fields.State = 'New';
        newWorkItem.fields.Priority = '2';
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(newWorkItem));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getExistingWorkItemMock() {
        AzureService.AzureDevOpsWorkItem existWorkItem = new AzureService.AzureDevOpsWorkItem();
        existWorkItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        existWorkItem.url = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
        existWorkItem.fields = new AzureService.AzureDevOpsWorkItemFields();
        existWorkItem.fields.Title = 'Existing Test Work Item';
        existWorkItem.fields.State = 'Done';
        existWorkItem.fields.Priority = '1';
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(existWorkItem));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemMock() {
        return getExistingWorkItemMock();
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemCommentMock() {
        AzureService.AzureDevOpsWorkItemComment comment = new AzureService.AzureDevOpsWorkItemComment();
        comment.id = '1';
        comment.text = 'Test comment';
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(comment));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemCommentsMock() {
        AzureService.AzureDevOpsWorkItemCommentsWrap commentsWrap = new AzureService.AzureDevOpsWorkItemCommentsWrap();
        commentsWrap.comments = new List<AzureService.AzureDevOpsWorkItemComment>();
        
        AzureService.AzureDevOpsWorkItemComment comment1 = new AzureService.AzureDevOpsWorkItemComment();
        comment1.id = '1';
        comment1.text = 'First test comment';
        commentsWrap.comments.add(comment1);
        
        AzureService.AzureDevOpsWorkItemComment comment2 = new AzureService.AzureDevOpsWorkItemComment();
        comment2.id = '2';
        comment2.text = 'Second test comment';
        commentsWrap.comments.add(comment2);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(commentsWrap));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemListMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> workItems = new List<Object>();
        AzureService.AzureDevOpsWorkItem workItem = new AzureService.AzureDevOpsWorkItem();
        workItem.id = AZURE_DEV_OPS_MOCK_WORK_ITEM_ID;
        workItem.url = AZURE_DEV_OPS_MOCK_WORK_ITEM_URL;
        workItem.fields = new AzureService.AzureDevOpsWorkItemFields();
        workItem.fields.Title = 'Test Work Item';
        workItem.fields.State = 'Closed';
        workItem.fields.ClosedDate = '2023-12-01T10:30:00.000Z';
        workItems.add(workItem);
        
        response.put('value', workItems);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemAttachmentMock() {
        Map<String, Object> attachment = new Map<String, Object>();
        attachment.put('id', 'attachment-id-123');
        attachment.put('url', 'https://dev.azure.com/' + AZURE_DEV_OPS_MOCK_ACCOUNT_ID + '/' + AZURE_DEV_OPS_MOCK_PROJECT_ID + '/_apis/wit/attachments/attachment-id-123');
        
        return new TestDataFactory.SingleRequestMock(201, 'Created', JSON.serialize(attachment));
    }

    // ========== Project Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getProjectsMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> projects = new List<Object>();
        Map<String, Object> project = new Map<String, Object>();
        project.put('id', AZURE_DEV_OPS_MOCK_PROJECT_ID);
        project.put('name', AZURE_DEV_OPS_MOCK_PROJECT_NAME);
        project.put('url', 'https://dev.azure.com/' + AZURE_DEV_OPS_MOCK_ACCOUNT_ID + '/_apis/projects/' + AZURE_DEV_OPS_MOCK_PROJECT_ID);
        projects.add(project);
        
        response.put('value', projects);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getProjectPropertiesMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> properties = new List<Object>();
        Map<String, Object> property = new Map<String, Object>();
        property.put('name', AzureService.AZURE_DEVOPS_PROCESS_TEMPLATE_TYPE);
        property.put('value', AZURE_DEV_OPS_MOCK_PROCESS_ID);
        properties.add(property);
        
        response.put('value', properties);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }

    // ========== Work Item Type Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWorkItemTypesMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> workItemTypes = new List<Object>();
        Map<String, Object> workItemType = new Map<String, Object>();
        workItemType.put('name', AZURE_DEV_OPS_MOCK_ISSUE_TYPE_NAME);
        workItemType.put('referenceName', AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID);
        workItemType.put('description', 'Bug work item type');
        workItemTypes.add(workItemType);
        
        response.put('value', workItemTypes);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }

    // ========== Process Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getProcessesMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> processes = new List<Object>();
        Map<String, Object> process = new Map<String, Object>();
        process.put('typeId', AZURE_DEV_OPS_MOCK_PROCESS_ID);
        process.put('name', 'Agile');
        process.put('isDefault', true);
        processes.add(process);
        
        response.put('value', processes);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getProcessWorkItemTypesMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 3);
        
        List<Object> workItemTypes = new List<Object>();
        
        Map<String, Object> inheritedType = new Map<String, Object>();
        inheritedType.put('referenceName', AZURE_DEV_OPS_MOCK_ISSUE_TYPE_ID);
        inheritedType.put('name', AZURE_DEV_OPS_MOCK_ISSUE_TYPE_NAME);
        inheritedType.put('customization', 'inherited');
        inheritedType.put('isDisabled', false);
        workItemTypes.add(inheritedType);
        
        Map<String, Object> customType = new Map<String, Object>();
        customType.put('referenceName', 'Custom.CustomType');
        customType.put('name', 'Custom Type');
        customType.put('customization', 'custom');
        customType.put('isDisabled', false);
        workItemTypes.add(customType);
        
        Map<String, Object> systemType = new Map<String, Object>();
        systemType.put('referenceName', 'System.Task');
        systemType.put('name', 'Task');
        systemType.put('customization', 'system');
        systemType.put('isDisabled', false);
        workItemTypes.add(systemType);
        
        response.put('value', workItemTypes);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getProcessWorkItemFieldsMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> fields = new List<Object>();
        Map<String, Object> field = new Map<String, Object>();
        field.put('referenceName', AZURE_DEV_OPS_MOCK_FIELD_ID);
        field.put('name', AZURE_DEV_OPS_MOCK_FIELD_NAME);
        field.put('type', 'string');
        field.put('required', true);
        fields.add(field);
        
        response.put('value', fields);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }

    // ========== Team Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getTeamsMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> teams = new List<Object>();
        Map<String, Object> team = new Map<String, Object>();
        team.put('id', AZURE_DEV_OPS_MOCK_TEAM_ID);
        team.put('name', AZURE_DEV_OPS_MOCK_TEAM_NAME);
        teams.add(team);
        
        response.put('value', teams);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getTeamMembersMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> members = new List<Object>();
        Map<String, Object> member = new Map<String, Object>();
        Map<String, Object> identity = new Map<String, Object>();
        identity.put('id', AZURE_DEV_OPS_MOCK_USER_ID);
        identity.put('displayName', AZURE_DEV_OPS_MOCK_USER_NAME);
        member.put('identity', identity);
        members.add(member);
        
        response.put('value', members);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getTeamSettingsMock() {
        Map<String, Object> teamSettings = new Map<String, Object>();
        teamSettings.put('bugsBehavior', AzureService.BUGS_BEHAVIOR_AS_REQUIREMENTS);
        Map<String, Object> backlogIteration = new Map<String, Object>();
        backlogIteration.put('id', 'backlog-iteration-id');
        backlogIteration.put('name', 'Backlog');
        teamSettings.put('backlogIteration', backlogIteration);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(teamSettings));
    }

    // ========== Board Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getBoardsMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> boards = new List<Object>();
        Map<String, Object> board = new Map<String, Object>();
        board.put('id', AZURE_DEV_OPS_MOCK_BOARD_ID);
        board.put('name', 'Test Board');
        boards.add(board);
        
        response.put('value', boards);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getBoardColumnsMock() {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Object> columns = new List<Object>();
        
        Map<String, Object> column1 = new Map<String, Object>();
        column1.put('id', 'column-1');
        column1.put('name', 'New');
        column1.put('columnType', AzureService.BOARD_COLUMN_TYPE_INCOMING);
        columns.add(column1);
        
        Map<String, Object> column2 = new Map<String, Object>();
        column2.put('id', 'column-2');
        column2.put('name', 'Active');
        column2.put('columnType', AzureService.BOARD_COLUMN_TYPE_IN_PROGRESS);
        columns.add(column2);
        
        Map<String, Object> column3 = new Map<String, Object>();
        column3.put('id', 'column-3');
        column3.put('name', 'Closed');
        column3.put('columnType', AzureService.BOARD_COLUMN_TYPE_OUTGOING);
        columns.add(column3);
        
        response.put('value', columns);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getBoardSettingsMock() {
        Map<String, Object> boardSettings = new Map<String, Object>();
        
        boardSettings.put('name', 'Test Board');
        
        Map<String, Object> board = new Map<String, Object>();
        board.put('id', AZURE_DEV_OPS_MOCK_BOARD_ID);
        board.put('name', 'Test Board');
        boardSettings.put('board', board);
        
        List<Object> columns = new List<Object>();
        Map<String, Object> column1 = new Map<String, Object>();
        column1.put('id', 'column-1');
        column1.put('name', 'New');
        Map<String, Object> stateMappings = new Map<String, Object>();
        stateMappings.put('Bug', new Map<String, Object>{'state' => 'New'});
        stateMappings.put('Task', new Map<String, Object>{'state' => 'New'});
        column1.put('stateMappings', stateMappings);
        columns.add(column1);
        boardSettings.put('columns', columns);
        
        Map<String, Object> allowedMappings = new Map<String, Object>();
        Map<String, Object> incomingMappings = new Map<String, Object>();
        incomingMappings.put('Bug', new List<String>{'New'});
        incomingMappings.put('User Story', new List<String>{'New'});
        allowedMappings.put('Incoming', incomingMappings);
        
        Map<String, Object> inProgressMappings = new Map<String, Object>();
        inProgressMappings.put('Bug', new List<String>{'Active', 'In Progress'});
        inProgressMappings.put('Task', new List<String>{'Active'});
        allowedMappings.put('InProgress', inProgressMappings);
        
        Map<String, Object> outgoingMappings = new Map<String, Object>();
        outgoingMappings.put('Bug', new List<String>{'Closed', 'Done'});
        outgoingMappings.put('Task', new List<String>{'Closed'});
        allowedMappings.put('Outgoing', outgoingMappings);
        
        boardSettings.put('allowedMappings', allowedMappings);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(boardSettings));
    }

    // ========== Classification Nodes Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getClassificationNodesMock() {
        Map<String, Object> classificationNode = new Map<String, Object>();
        classificationNode.put('id', 1);
        classificationNode.put('name', 'Test Node');
        classificationNode.put('structureType', 'iteration');
        classificationNode.put('hasChildren', false);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(classificationNode));
    }

    // ========== WIQL Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getWiqlSearchMock() {
        Map<String, Object> response = new Map<String, Object>();
        
        List<Object> workItems = new List<Object>();
        Map<String, Object> workItem = new Map<String, Object>();
        workItem.put('id', Integer.valueOf(AZURE_DEV_OPS_MOCK_WORK_ITEM_ID));
        workItem.put('url', AZURE_DEV_OPS_MOCK_WORK_ITEM_URL);
        workItems.add(workItem);
        
        response.put('workItems', workItems);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }

    // ========== Account Mock Methods ==========
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getMyProfileMock() {
        Map<String, Object> profile = new Map<String, Object>();
        profile.put('id', AZURE_DEV_OPS_MOCK_USER_ID);
        profile.put('displayName', AZURE_DEV_OPS_MOCK_USER_NAME);
        profile.put('emailAddress', 'test@example.com');
        profile.put('publicAlias', 'test-user');
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(profile));
    }
    
    @TestVisible
    private static TestDataFactory.SingleRequestMock getMyAccountsMock() {
        Map<String, Object> response = new Map<String, Object>();
        response.put('count', 1);
        
        List<Object> accounts = new List<Object>();
        Map<String, Object> account = new Map<String, Object>();
        account.put('accountId', AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        account.put('accountName', AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        account.put('accountUri', 'https://dev.azure.com/' + AZURE_DEV_OPS_MOCK_ACCOUNT_ID);
        accounts.add(account);
        
        response.put('value', accounts);
        
        return new TestDataFactory.SingleRequestMock(200, 'OK', JSON.serialize(response));
    }

    // ========== OAuth Token Mock Methods ==========
    
    /**
     * Mock for OAuth token refresh endpoint
     * This mock simulates the response from GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT
     * when refreshing Azure DevOps OAuth tokens
     */
    @TestVisible
    public static TestDataFactory.SingleRequestMock getOAuthRefreshTokenMock() {
        ConnectedOrgService.AuthTokenResponse tokenResponse = new ConnectedOrgService.AuthTokenResponse();
        tokenResponse.access_token = 'mock_azure_devops_access_token_' + String.valueOf(Datetime.now().getTime());
        tokenResponse.refresh_token = 'mock_azure_devops_refresh_token_' + String.valueOf(Datetime.now().getTime());
        tokenResponse.token_type = 'Bearer';
        
        return new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(tokenResponse)
        );
    }
    
    /**
     * Creates mocks for OAuth token operations
     * Use this when testing methods that involve token refresh
     * 
     * Usage:
     *     Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
     *     endpoint2TestResp.putAll(TestDataFactoryIntegrationAzure.createAzureDevOpsOAuthMocks());
     */
    public static Map<String, HttpCalloutMock> createAzureDevOpsOAuthMocks() {
        return new Map<String, HttpCalloutMock>{
            GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT => getOAuthRefreshTokenMock()
        };
    }
}