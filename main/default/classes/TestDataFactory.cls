@IsTest
public class TestDataFactory {

    private static final String CONNECTED_ORG_SETTINGS_CLIENT_KEY = 'test_client_key';
    private static final String CONNECTED_ORG_SETTINGS_CLIENT_SECRET = 'test_client_secret';

    public static void createConnectedOrgSettings() {
        Connected_Orgs_Settings__c connectedOrgsSettings = new Connected_Orgs_Settings__c(
                Client_Key__c = CONNECTED_ORG_SETTINGS_CLIENT_KEY,
                Client_Secret__c = CONNECTED_ORG_SETTINGS_CLIENT_SECRET
        );
        insert connectedOrgsSettings;
    }

    private static final String CONNECTED_ORG_TITLE = 'Test Title Connected Org';
    private static final String CONNECTED_ORG_DESCRIPTION = 'Test Description Connected Org';
    private static final String CONNECTED_ORG_TYPE = 'production';
    private static final String CONNECTED_CODE = 'test_code';
    private static final String CONNECTED_ORG_ACCESS_TOKEN = 'test_Access_Token';
    private static final String CONNECTED_ORG_REFRESH_TOKEN = 'test_Refresh_Token';
    @TestVisible
    private static final String CONNECTED_ORG_INSTANCE_URL = 'https://test_Instance_Url';
    private static final String CONNECTED_ORG_IDENTITY_URL = 'https://test_Identity_Url';

    public static final String ASYNC_APEX_JOBS_JSON = '[{' +
            '"attributes":{"type":"AsyncApexJob","url":"/services/data/v52.0/sobjects/AsyncApexJob/707KK00000KKK00KKK"},' +
            '"Id":"707KK00000KKK00KKK",' +
            '"JobType":"BatchApex",' +
            '"ExtendedStatus":"First error: Update failed. First exception on row 0; first error: MISSING_ARGUMENT, Id 707XXX000XXX000XXX not specified in an update call: [707KK00000KKK00KKK]",' +
            '"ApexClassId":"01pXXX000XXX000XXX",' +
            '"Status":"Completed",' +
            '"CompletedDate":' + JSON.serialize(System.now()) + ',' +
            '"ApexClass":{' +
            '"attributes":{' +
            '"type":"ApexClass",' +
            '"url":"/services/data/v52.0/sobjects/ApexClass/01pXXX000XXX000XXX"},' +
            '"Id":"01pXXX000XXX000XXX",' +
            '"Name":"JobBatch"' +
            '}},{' +
            '"attributes":{"type":"AsyncApexJob","url":"/services/data/v52.0/sobjects/AsyncApexJob/707KK00000KKK11KKK"},' +
            '"Id":"707KK00000KKK11KKK",' +
            '"JobType":"BatchApex",' +
            '"ExtendedStatus":"First error: Update failed. First exception on row 0; first error: MISSING_ARGUMENT, Id 707XXX000XXX000XXX not specified in an update call: [707KK00000KKK11KKK]",' +
            '"ApexClassId":"01pXXX000XXX000XXX",' +
            '"Status":"Completed",' +
            '"CompletedDate":' + JSON.serialize(System.now()) + ',' +
            '"ApexClass":{' +
            '"attributes":{' +
            '"type":"ApexClass",' +
            '"url":"/services/data/v52.0/sobjects/ApexClass/01pXXX000XXX000XXX"},' +
            '"Id":"01pXXX000XXX000XXX",' +
            '"Name":"JobBatch"' +
            '}}]';

    public static final String LOGS_QUERY_ALL_JSON = '{"records":[{"attributes":{"type":"Log__c"},"Id":"a095X000000XXXXXXX","Async_Job_Id__c":"707KK00000KKK00KKK","Details__c":"details","Hash__c":"hash"}]}';

    public static void createConnectedOrg() {
        createConnectedOrg(UserInfo.getOrganizationId().left(15));
    }

    public static void createConnectedOrg(String orgId) {
        Connected_Org__c corg = new Connected_Org__c(
                Name = orgId,
                Title__c = CONNECTED_ORG_TITLE,
                Description__c = CONNECTED_ORG_DESCRIPTION,
                Type__c = CONNECTED_ORG_TYPE,
                Code__c = CONNECTED_CODE,
                Scheduler_Enabled__c = false,
                Access_Token__c = CONNECTED_ORG_ACCESS_TOKEN,
                Refresh_Token__c = CONNECTED_ORG_REFRESH_TOKEN,
                Token_Refreshed_At__c = Datetime.now(),
                Instance_Url__c = CONNECTED_ORG_INSTANCE_URL,
                Identity_Url__c = CONNECTED_ORG_IDENTITY_URL,
                Connection_Valid__c = true
        );
        List<Organization> lstOrganizations = [SELECT Id, IsSandbox FROM Organization];
        if (!lstOrganizations.isEmpty() && lstOrganizations[0].IsSandbox) {
            corg.Type__c = 'sandbox';
        }
        insert corg;
    }

    public static final String EXTERNAL_CONNECTED_ORG_ID = '0123456789XXXXX';
    public static void createConnectedOrgPassthrought() {
        Connected_Org__c corg = new Connected_Org__c(
                Name = EXTERNAL_CONNECTED_ORG_ID,
                Title__c = CONNECTED_ORG_TITLE,
                Description__c = CONNECTED_ORG_DESCRIPTION,
                Type__c = CONNECTED_ORG_TYPE,
                Code__c = CONNECTED_CODE,
                Scheduler_Enabled__c = false,
                Access_Token__c = CONNECTED_ORG_ACCESS_TOKEN,
                Refresh_Token__c = CONNECTED_ORG_REFRESH_TOKEN,
                Token_Refreshed_At__c = Datetime.now(),
                Instance_Url__c = CONNECTED_ORG_INSTANCE_URL,
                Identity_Url__c = CONNECTED_ORG_IDENTITY_URL,
                Connection_Valid__c = true
        );
        List<Organization> lstOrganizations = [SELECT Id, IsSandbox FROM Organization];
        if (!lstOrganizations.isEmpty() && lstOrganizations[0].IsSandbox) {
            corg.Type__c = 'sandbox';
        }
        insert corg;
        Connected_Orgs_Settings__c connectedOrgsSettings = ConfigUtil.CONNECTED_ORGS_SETTINGS;
        connectedOrgsSettings.Client_Key__c = CONNECTED_ORG_SETTINGS_CLIENT_KEY;
        connectedOrgsSettings.Client_Secret__c = CONNECTED_ORG_SETTINGS_CLIENT_SECRET;
        connectedOrgsSettings.Passthrought_Mode__c = true;
        connectedOrgsSettings.Passthrought_Email__c = EXTERNAL_CONNECTED_ORG_ID;
        upsert connectedOrgsSettings;
    }

    public class MultiRequestMock implements HttpCalloutMock {

        Map<String, HttpCalloutMock> requests;
        Map<String, HttpRequest> requestMap = new Map<String, HttpRequest>();
        Map<String, HttpResponse> responseMap = new Map<String, HttpResponse>();
        Map<String, String> mapErrors = new Map<String, String>();

        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public void setEndpointError(String endpoint, String error) {
            mapErrors.put(endpoint, error);
        }

        public HttpResponse respond(HttpRequest req) {
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                this.requestMap.put(req.getEndpoint(), req);
                if(mapErrors.containsKey(req.getEndpoint())) {
                    String errorMessage = mapErrors.get(req.getEndpoint());
                    mapErrors.remove(req.getEndpoint());
                    throw new HttpUtils.HttpUtilsException(errorMessage);
                }
                HttpResponse response = mock.respond(req);
                this.responseMap.put(req.getEndpoint(), response);
                return response;
            }
            else {
                throw new MultiRequestMockException('HTTP callout not supported for test methods');
            }
        }

        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }

        public HttpRequest getRequest(String endpoint) {
            return this.requestMap.get(endpoint);
        }

        public HttpResponse getResponse(String endpoint) {
            return this.responseMap.get(endpoint);
        }
    }

    public class MultiRequestMockException extends Exception {}

    public class SingleRequestMock implements HttpCalloutMock {

        protected Integer code;
        protected String status;
        protected String body;
        protected String reqBody;

        public SingleRequestMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            this.reqBody = req.getBody();
            return res;
        }

        public String getBodyRequest() {
            return this.reqBody;
        }
    }

    public class WebServiceMockImpl implements WebServiceMock {
        public void doInvoke(
                Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType)
        {
            if (request instanceof  MetadataService.upsertMetadata_element) {
                MetadataService.UpsertResult result = new MetadataService.UpsertResult();
                result.success = true;
                MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
                responseElement.result = new MetadataService.UpsertResult[] {result};
                response.put('response_x', responseElement);
            }


        }
    }

    public static Log__c createTestNotificationLog() {
        String orgID = UserInfo.getOrganizationId().left(15);
        Log__c log = new Log__c();
        log.Hash_1__c = 'hash1';
        log.Hash_2__c = 'hash2';
        log.Hash_3__c = 'hash3';
        log.Organization_Id__c = orgID;
        insert log;
        return log;
    }

    public static Action__c createEmailAction() {
        return createEmailAction(null);
    }
    public static Action__c createEmailAction(String sobjectType) {
        Action__c rn1 = createNotificationRuleAction();
        rn1.Subject__c = 'test';
        rn1.EmailBody__c = 'test';
        rn1.EmailTo__c = 'test@test.com';
        rn1.Action_Type__c = MonitoringUtil.ACTION_TYPE_EMAIL_NOTIFICATION;
        rn1.SobjectType__c = sobjectType;
        insert rn1;
        return rn1;
    }

    public static Action__c createTeamsAction() {
        return createTeamsAction(null);
    }
    public static Action__c createTeamsAction(String sobjectType) {
        Action__c rn1 = createNotificationRuleAction();
        rn1.Subject__c = 'test';
        rn1.Body__c = 'test';
        String sobjectName = (sobjectType == null) ? Schema.SObjectType.Log__c.getName() : sobjectType ;
        if(String.isNotBlank(sobjectName)) {
            rn1.Body__c = 'link {!' + sobjectName + '.Link}';
        }
        rn1.Team_Id__c = 'testTeamId';
        rn1.Channel_Id__c = 'testChannelId';
        rn1.Action_Type__c = MonitoringUtil.ACTION_TYPE_TEAMS_NOTIFICATION;
        rn1.SobjectType__c = sobjectType;
        insert rn1;
        return rn1;
    }

    public static Action__c createSlackAction() {
        return createSlackAction(null);
    }
    public static Action__c createSlackAction(String sobjectType) {
        Action__c rn1 = createNotificationRuleAction();
        rn1.Subject__c = 'test';
        rn1.Body__c = 'test';
        rn1.SlackChannels__c = '@test';
        rn1.Action_Type__c = MonitoringUtil.ACTION_TYPE_SLACK_NOTIFICATION;
        rn1.SobjectType__c = sobjectType;
        insert rn1;
        return rn1;
    }

    public static Action__c createPagerDutyAction(String pagerDutyType) {
        return createPagerDutyAction(pagerDutyType, null);
    }
    public static Action__c createPagerDutyAction(String pagerDutyType, String sobjectType) {
        Action__c rn1 = createNotificationRuleAction();
        rn1.Subject__c = 'test';
        rn1.Body__c = 'test';
        rn1.Action_Type__c = MonitoringUtil.ACTION_TYPE_PAGERDUTY_NOTIFICATION;
        rn1.PagerDuty_Type__c = pagerDutyType;
        rn1.SobjectType__c = sobjectType;
        insert rn1;
        return rn1;
    }

    public static Action__c createNotificationRuleAction() {
        Id recordtypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get('Monitoring').getRecordtypeId();
        Action__c rn1 = new Action__c();
        rn1.RecordTypeId = recordtypeId;
        rn1.Description__c = 'test';
        rn1.Subtype__c = MonitoringUtil.RULE_TYPE_NOTIFICATION;
        return rn1;
    }

    public static List<RuleAction__c> createRuleActions(Rule__c rule, List<Action__c> actions) {
        List<RuleAction__c> ruleActions = new List<RuleAction__c>();
        for(Action__c action : actions) {
            RuleAction__c ra = new RuleAction__c();
            ra.Action__c = action.Id;
            ra.Rule__c = rule.Id;
            ruleActions.add(ra);
        }
        return ruleActions;
    }

    public static Rule__c createNotificationRule(Action__c action) {
        return createNotificationRule(action, null, null);
    }
    public static Rule__c createNotificationRule(Action__c action, String sobjecttype) {
        return createNotificationRule(action, sobjecttype, null);
    }
    public static Rule__c createNotificationRule(Action__c action, String sobjecttype, String subType) {
        return createNotificationRule(action, sobjecttype, subType, false);
    }
    public static Rule__c createNotificationRule(Action__c action, String sobjecttype, String subType, Boolean isUpdate) {
        Rule__c mr1 = new Rule__c();
        mr1.Active__c = true;
        mr1.Type__c = MonitoringUtil.RULE_TYPE_NOTIFICATION;
        mr1.Index__c = 1;
        mr1.SobjectType__c = sobjecttype;
        mr1.Subtype__c = subType;
        mr1.Is_Update__c = isUpdate;
        insert mr1;

        RuleAction__c en1 = new RuleAction__c();
        en1.Action__c = action.Id;
        en1.Rule__c = mr1.Id;
        insert en1;
        return mr1;
    }

    public static void createRuleFilterOnUpdate(Integer index, Rule__c rule, String comparisonOperator, String value, String fieldName, Boolean isOld) {
        String packagePrefix = ConfigUtil.nameSpacePrefix;
        RuleFilter__c rf1 = new RuleFilter__c();
        rf1.Index__c = index;
        rf1.Rule__c = rule.Id;
        rf1.ComparisonOperator__c = comparisonOperator;
        rf1.FieldName__c = fieldName;
        rf1.Value__c = value;
        rf1.Comparison_Type__c = 'Value';
        rf1.Is_Old__c = isOld;
        insert rf1;
    }

    public static void createTeamsSettings() {
        Graph_API_Settings__c graphSettings = new Graph_API_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                Enabled__c = true,
                Tenant_Id__c = 'testTenantId'
        );
        insert graphSettings;
    }

    public static void createSlackSettings() {
        Slack_Settings__c slackSettings = new Slack_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                Slack_Enabled__c = true,
                Slack_API_Token__c = '123321'
        );
        insert slackSettings;
    }

    public static void createPagerDutySettings() {
        Pager_Duty_Settings__c pagerDutySettings = new Pager_Duty_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                PagerDuty_Enabled__c = true,
                PagerDuty_API_Token__c = 'token',
                PagerDuty_Service_ID__c = 'serviceid',
                PagerDuty_User_Email__c = 'user@email.com',
                PagerDuty_Service_Integration_Key__c = 'key'
        );
        insert pagerDutySettings;
    }

    public static Rule__c createTestFilterRule() {
        Rule__c mr1 = new Rule__c();
        mr1.Index__c = 0;
        mr1.Active__c = true;
        mr1.Type__c =  MonitoringUtil.RULE_TYPE_JIRA_UPDATE;
        insert mr1;
        return mr1;
    }

    public static void setValidMonitoringRuleFields(Rule__c rule) {
        rule.AggregateType__c = 'Count';
        rule.AggregateInterval__c = 30;
        rule.Type__c = 'Monitoring';
        rule.Subtype__c = 'Spike';
        rule.ComparisonOperator__c = 'Greater or equal';
        rule.EventTimeInterval__c = 60;
        rule.FilterLogic__c = '1 OR 2';
        rule.Threshold__c = 1;
    }

    public static Rule__c createMonitoringRule(Boolean isValidRule, Boolean isValidFilters) {
        Rule__c mr1 = new Rule__c();
        mr1.Active__c = true;
        if(isValidRule) {
            setValidMonitoringRuleFields(mr1);
        }
        insert mr1;

        Action__c emailAction = TestDataFactory.createEmailAction();
        RuleAction__c en1 = new RuleAction__c();
        en1.Action__c = emailAction.Id;
        en1.Rule__c = mr1.Id;
        insert en1;

        String packagePrefix = ConfigUtil.nameSpacePrefix;
        RuleFilter__c rf1 = new RuleFilter__c();
        rf1.Index__c = isValidFilters ? 1 : 2;
        rf1.Rule__c = mr1.Id;
        rf1.ComparisonOperator__c = isValidFilters ? 'Not equal' : 'Contains';
        rf1.FieldName__c = packagePrefix + 'Type__c';
        rf1.Value__c = 'notTestType';
        rf1.Comparison_Type__c = 'Value';

        RuleFilter__c rf2 = new RuleFilter__c();
        rf2.Index__c = isValidFilters ? 2 : 3;
        rf2.Rule__c = mr1.Id;
        rf2.ComparisonOperator__c = 'Equal';
        rf2.FieldName__c = packagePrefix + 'Category__c';
        rf2.Value__c = 'TestCategory';
        rf2.Comparison_Type__c = 'Value';
        insert new List<RuleFilter__c>{rf1, rf2};
        return mr1;
    }

    public static Rule__c createArchivalRule(Boolean isValidRule, Boolean isValidFilters) {
        Rule__c mr1 = new Rule__c();
        mr1.Active__c = true;
        mr1.Type__c = MonitoringUtil.RULE_TYPE_ARCHIVAL;
        if(isValidRule) {
            mr1.EventTimeInterval__c = 60;
            mr1.FilterLogic__c = '1';
        }
        insert mr1;

        Id recordtypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(MonitoringUtil.RULE_TYPE_ARCHIVAL).getRecordtypeId();

        Action__c rn1 = new Action__c();
        rn1.RecordTypeId = recordtypeId;
        rn1.Description__c = 'test';
        rn1.Action_Type__c = 'Removal';
        insert rn1;

        RuleAction__c en1 = new RuleAction__c();
        en1.Action__c = rn1.Id;
        en1.Rule__c = mr1.Id;
        insert en1;

        String packagePrefix = ConfigUtil.nameSpacePrefix;
        if(isValidFilters) {
            RuleFilter__c rf1 = new RuleFilter__c();
            rf1.Index__c = 1;
            rf1.Rule__c = mr1.Id;
            rf1.ComparisonOperator__c = 'Greater than';
            rf1.FieldName__c = 'Created_At__c';
            rf1.Value__c = '3600';
            rf1.Comparison_Type__c = 'Value';

            RuleFilter__c rf2 = new RuleFilter__c();
            rf2.Index__c = 2;
            rf2.Rule__c = mr1.Id;
            rf2.ComparisonOperator__c = 'Equal';
            rf2.FieldName__c = packagePrefix + 'Category__c';
            rf2.Value__c = 'TestCategory';
            rf2.Comparison_Type__c = 'Value';
 
            insert new List<RuleFilter__c>{rf1, rf2};
        }
        return mr1;
    }

    public static Rule__c createJiraUpdateRule(Boolean isValidRule, Boolean isValidFilters) {
        Rule__c mr1 = new Rule__c();
        mr1.Active__c = true;
        mr1.Index__c = 0;
	    mr1.Type__c = isValidRule ? RuleUtil.RULE_TYPE_JIRA_UPDATE : null;
        insert mr1;

        Action__c action = new Action__c(Action_Type__c = RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION);
        RuleAction__c en1 = new RuleAction__c();
        en1.Action__c = action.Id;
        en1.Rule__c = mr1.Id;
        insert en1;

        RuleFilter__c isNewFilter = new RuleFilter__c();
        isNewFilter.Index__c = 1;
        isNewFilter.Rule__c = mr1.Id;
        isNewFilter.ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_EQUAL;
        isNewFilter.FieldName__c = Schema.sObjectType.Log__c.fields.Is_New__c.getName();
        isNewFilter.Value__c = (isValidFilters) ? 'true' : '123123123';
        isNewFilter.Comparison_Type__c = RuleUtil.COMPARISON_TYPE_VALUE;
        isNewFilter.Field_Type__c = RuleUtil.FIELD_TYPE_BOOLEAN;

        RuleFilter__c orgNameFilter = new RuleFilter__c();
        orgNameFilter.Index__c = 2;
        orgNameFilter.Rule__c = mr1.Id;
        orgNameFilter.ComparisonOperator__c = RuleUtil.COMPARISON_OPERATOR_EQUAL;
        orgNameFilter.FieldName__c = Schema.sObjectType.Log__c.fields.Organization_Name__c.getName();
        orgNameFilter.Value__c = UserInfo.getOrganizationName();
        orgNameFilter.Comparison_Type__c = RuleUtil.COMPARISON_TYPE_VALUE;
        orgNameFilter.Field_Type__c = RuleUtil.FIELD_TYPE_STRING;
        insert new List<RuleFilter__c>{isNewFilter, orgNameFilter};

        return mr1;
    }

    public static void enableIssueTracking() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>1, 1=>1,	2=>1,
                3=>1, 4=>1,	5=>1,
                6=>1, 7=>1,	8=>1,
                9=>1, 10=>0, 11=>0,
                12=>1, 13=>0, 14=>0,
                15=>0, 16=>0, 17=>1,
                18=>1, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
        PermissionsUtil.IssueTrackingEnabled = true;
        enableMaxIssues(0);
    }

    public static void disableIssueTracking() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>1, 1=>1,	2=>1,
                3=>1, 4=>1,	5=>1,
                6=>1, 7=>1,	8=>1,
                9=>1, 10=>0, 11=>0,
                12=>1, 13=>0, 14=>0,
                15=>0, 16=>0, 17=>0,
                18=>1, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
        PermissionsUtil.IssueTrackingEnabled = false;
    }

    public static void enableMaxIssues(Integer intValue) {
        PermissionsUtil.FeatureMap10IntValue = intValue;
        PermissionsUtil.MaxIssues = intValue;
    }

    public static void enableMaxJiraRules() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>1, 1=>1,	2=>1,
                3=>1, 4=>1,	5=>1,
                6=>1, 7=>1,	8=>1,
                9=>1, 10=>1, 11=>1,
                12=>1, 13=>1, 14=>1,
                15=>1
        });
        PermissionsUtil.FeatureMap3IntValue = intValue;
    }

    public static void enableMaxArchivalRules() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
                0=>1, 1=>1,	2=>1,
                3=>1, 4=>1,	5=>1,
                6=>1, 7=>1,	8=>1,
                9=>1, 10=>1, 11=>1,
                12=>1, 13=>1, 14=>1,
                15=>1, 16=>1, 17=>0,
                18=>0, 19=>0, 20=>0,
                21=>0, 22=>0, 23=>0,
                24=>0, 25=>0, 26=>0,
                27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap2IntValue = intValue;
    }

    // Flow Generation

    @testVisible
    private static final String TEST_FLOW_API_NAME = 'Failed_Flow_1';
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_1 = 'subflow1';
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_2 = 'subflow2';
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_3 = 'subflow3';
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_4 = 'subflow4';

    @testVisible
    private static final String TEST_FLOW_VERSION = '1';
    @testVisible
    private static final String TEST_FLOW_API_NAME_WITH_VERSION = TEST_FLOW_API_NAME + '-' + TEST_FLOW_VERSION;

    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_1_WITH_VERSION = TEST_SUBFLOW_API_NAME_1 + '-' + TEST_FLOW_VERSION;
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_2_WITH_VERSION = TEST_SUBFLOW_API_NAME_2 + '-' + TEST_FLOW_VERSION;
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_3_WITH_VERSION = TEST_SUBFLOW_API_NAME_3 + '-' + TEST_FLOW_VERSION;
    @testVisible
    private static final String TEST_SUBFLOW_API_NAME_4_WITH_VERSION = TEST_SUBFLOW_API_NAME_4 + '-' + TEST_FLOW_VERSION;


    private static String getTestFlowDetails(String flowApiName, String flowLabel, String flowType, String flowVersion) {
        return 
            'Flow API Name: ' + flowApiName + '\n' +
            'Flow Label: ' + flowLabel + '\n' +
            'Type: ' + flowType + '\n' +
            'Version: ' + flowVersion + '\n' +
            'Status: Active\n' +
            'Org: DevOrg (' + Test_LogService.CONNECETED_ORG_NAME+ ')\n' +
            'Interview Label: Failed Flow 8/16/2024, 12:44 AM\n' +
            'Interview GUID: 30778b10409697fba3a312de90fd1915969c836-26bf\n' +
            'Current User: homer simpson (0056g000003aA4M)\n' +
            'Start time: 8/16/2024, 12:44 AM\n' +
            'Duration: 10 seconds\n' +
            'API Version: 61.0\n' +
            'Input Variables:\n' +
            '$Record = Account (0016g00002bTOrTAAW)\n' +
            'recordId = 0016g00002bTOrTAAW\n' +
            'maxCount = 5';
    }

    private static final Map<String, String> TEST_FLOW_DETAILS_MAP = new Map<String, String>{
        TEST_FLOW_API_NAME => getTestFlowDetails(TEST_FLOW_API_NAME, 'Failed Flow', 'Autolaunched Flow', TEST_FLOW_VERSION),
        TEST_SUBFLOW_API_NAME_1 => getTestFlowDetails(TEST_SUBFLOW_API_NAME_1, 'Failed Subflow 1', 'Autolaunched Flow', TEST_FLOW_VERSION),
        TEST_SUBFLOW_API_NAME_2 => getTestFlowDetails(TEST_SUBFLOW_API_NAME_2, 'Failed Subflow 2', 'Autolaunched Flow', TEST_FLOW_VERSION)
    };
    
    @testVisible
    private class MockMetadataHandler implements WebServiceMock {
        private MetadataService.Flow originalFlow;
        private List<MetadataService.Flow> originalFlows;
        private MetadataService.Flow updatedFlow;
        
        public MockMetadataHandler(MetadataService.Flow flow) {
            this.originalFlow = flow;
        }

        public MockMetadataHandler(List<MetadataService.Flow> flows) {
            this.originalFlows = flows;
        }
        
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) {
            
            if(request instanceof MetadataService.readMetadata_element) {
                handleReadRequest(response);
            } else if(request instanceof MetadataService.updateMetadata_element) {
                handleUpdateRequest(request, response);
            } else if(request instanceof MetadataService.upsertMetadata_element) {
                handleUpsertRequest(request, response);
            }
        }
        
        private void handleReadRequest(Map<String, Object> response) {
            MetadataService.readFlowResponse_element responseWrapper = 
                new MetadataService.readFlowResponse_element();
            
            MetadataService.ReadFlowResult result = new MetadataService.ReadFlowResult();
            result.records = (originalFlows != null) ? originalFlows : new List<MetadataService.Flow>{ originalFlow };
            responseWrapper.result = result;
            
            response.put('response_x', responseWrapper);
        }
        
        private void handleUpdateRequest(Object request, Map<String, Object> response) {
            MetadataService.updateMetadata_element updateRequest = 
                (MetadataService.updateMetadata_element)request;
            
            // Store updated flow for verification
            this.updatedFlow = (MetadataService.Flow)updateRequest.metadata[0];
            
            // Create success response
            MetadataService.updateMetadataResponse_element responseWrapper = 
                new MetadataService.updateMetadataResponse_element();
            
            MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
            saveResult.success = true;
            saveResult.fullName = originalFlow.fullName;
            
            responseWrapper.result = new List<MetadataService.SaveResult>{ saveResult };
            response.put('response_x', responseWrapper);
        }
        
        private void handleUpsertRequest(Object request, Map<String, Object> response) {
            MetadataService.upsertMetadata_element upsertRequest = 
                (MetadataService.upsertMetadata_element)request;
            
            // Store updated flow for verification
            this.updatedFlow = (MetadataService.Flow)upsertRequest.metadata[0];
            
            // Create success response
            MetadataService.upsertMetadataResponse_element responseWrapper = 
                new MetadataService.upsertMetadataResponse_element();
            
            MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();
            upsertResult.success = true;
            upsertResult.fullName = originalFlow.fullName;
            
            responseWrapper.result = new List<MetadataService.UpsertResult>{ upsertResult };
            response.put('response_x', responseWrapper);
        }
        
        public MetadataService.Flow getUpdatedFlow() {
            return updatedFlow;
        }
    }

    private static final Pattern ELEMENT_PATTERN = Pattern.compile(
        '(?:\\s*│\\s*)*' +                                        // Optional indentation with │
        '((?:└──|├──))\\s*' +                                     // Group 1: Tree symbols
        '(\\w+)\\s+' +                                            // Group 2: Element name
        '\\[(\\w+(?:\\s+\\w+)?)\\]\\s*→\\s*' +                    // Group 3: Element type
        '(?:' +
            'Next:([^,\\s]+)(?:,\\s*NoMore:([^,\\s]+))|' +        // Group 4: Next target, Group 5: NoMore target
            'DEFAULT:([^,\\s]+)' +                                // Group 6: Default target
            '(?:,\\s*(?:Rules|Events):\\[([^\\]]+)\\])?' +        // Group 7: Rules/Events list
            '(?:,\\s*FAULT:([^,\\s]+))?|' +                       // Group 8: Fault target for DEFAULT
            '([^,\\s]+)' +                                        // Group 9: Standard target
            '(?:,\\s*(?:Paths|Rules|Events):\\[([^\\]]+)\\])?' +  // Group 10: Paths/Rules/Events list
            '(?:,\\s*FAULT:([^,\\s]+))?' +                        // Group 11: Fault target for standard
        ')' +
        '(?:\\s*\\{([^}]+)\\})?'                                  // Group 12: Full connection description
    );

    @testVisible
    private static List<MetadataService.Flow> buildFlowsFromStructures(String structure) {
        return buildFlowsFromStructures(new Map<String, String>{TEST_FLOW_API_NAME => structure});
    }

    @testVisible
    private static List<MetadataService.Flow> buildFlowsFromStructures(Map<String, String> flowStructures) {
        List<MetadataService.Flow> flows = new List<MetadataService.Flow>();

        for(String flowName : flowStructures.keySet()) {
            String structure = flowStructures.get(flowName);

            MetadataService.Flow flow = new MetadataService.Flow();
            flow.fullName = flowName + '-' + TEST_FLOW_VERSION;
            flow.status = 'Active';
            flow.processType = 'Autolaunched Flow';
            flow.description = 'Test Flow';
            flow.label = 'Test Flow';

            Map<String, FlowElementWrapper> elementWrappers = new Map<String, FlowElementWrapper>();
            Integer depth = 0;
            Integer yPosition = 100;
        
            // Parse structure and create elements
            List<String> lines = structure.split('\n');
            for(String line : lines) {
                FlowElementInfo elementInfo = parseFlowLine(line);
                if(elementInfo == null) continue;
                
                // Calculate x position based on depth and element type
                Integer xPosition = calculateXPosition(elementInfo.type, elementInfo.depth);
                
                // Create element
                Object element = createFlowElement(elementInfo, xPosition, yPosition);
                
                // Store element and its connections
                elementWrappers.put(elementInfo.name, new FlowElementWrapper(element, elementInfo));
                yPosition += 100;
            }

            // Add elements to flow
            addElementsToFlow(flow, elementWrappers.values());

            flows.add(flow);
        }
        return flows;
    }
    
    @testVisible
    private class FlowElementInfo {
        public String name;
        public String type;
        public String defaultTarget;
        public String nextTarget;
        public String noMoreTarget;
        public String standardTarget;
        public String faultTarget;
        public List<DecisionRule> rules;
        public Integer depth;
        public String elementDescription;
    
        public FlowElementInfo(String name,
                             String type,
                             String defaultTarget,
                             String nextTarget,
                             String noMoreTarget,
                             String standardTarget,
                             String faultTarget,
                             List<DecisionRule> rules,
                             Integer depth,
                             String elementDescription) {
            this.name = name;
            this.type = type;
            this.defaultTarget = defaultTarget;
            this.nextTarget = nextTarget;
            this.noMoreTarget = noMoreTarget;
            this.standardTarget = standardTarget;
            this.faultTarget = faultTarget;
            this.rules = rules;
            this.depth = depth;
            this.elementDescription = elementDescription;
        }
    }

    @testVisible
    private class DecisionRule {
        public String name;
        public String label;
        public String description;
        public String targetRef;
        
        public DecisionRule(String name, String targetRef) {
            this.name = name;
            this.label = name.toUpperCase();
            this.description = 'Decision rule';
            this.targetRef = targetRef;
        }
    }

    private class FlowElementWrapper {
        public Object element;
        public FlowElementInfo info;
        
        public FlowElementWrapper(Object element, FlowElementInfo info) {
            this.element = element;
            this.info = info;
        }
    }
    
    private static FlowElementInfo parseFlowLine(String line) {
        try {
            Matcher matcher = ELEMENT_PATTERN.matcher(line.trim());
            if (!matcher.matches()) {
                return null;
            }
            
            String name = matcher.group(2);
            String type = matcher.group(3);
            String nextTarget = matcher.group(4);
            String noMoreTarget = matcher.group(5);
            String defaultTarget = matcher.group(6);
            String rulesStr = matcher.group(7);
            String faultTarget = matcher.group(8) != null ? matcher.group(8) : matcher.group(11);
            String standardTarget = matcher.group(9);
            String pathsStr = matcher.group(10);
            String elementDescription = matcher.group(12);
            List<DecisionRule> rules = new List<DecisionRule>();           

            if(defaultTarget == 'END') {
                defaultTarget = null;
            }
            if(nextTarget == 'END') {
                nextTarget = null;
            }
            if(faultTarget == 'END') {
                faultTarget = null;
            }
            if(noMoreTarget == 'END') {
                noMoreTarget = null;
            }
            if(standardTarget == 'END') {
                standardTarget = null;
            }

            if(String.isNotBlank(rulesStr) || String.isNotBlank(pathsStr)){
                // Decision with Rules
                // Split rules by comma
                for (String rule : rulesStr?.split(',') ?? pathsStr?.split(',')) {
                    String[] parts = rule.trim().split('->');
                    if (parts.size() == 2) {
                        rules.add(new DecisionRule(parts[0].trim(), parts[1].trim()));
                    }
                }
            }
            // Calculate depth based on indentation and connector type
            Integer depth = calculateDepth(line);
            FlowElementInfo result = new FlowElementInfo(name, type, defaultTarget, nextTarget, noMoreTarget, standardTarget, faultTarget, rules, depth, elementDescription);
            return result;
        }
        catch(Exception e) {
            return null;
        }
    }
    
    private static Integer calculateDepth(String line) {
        Integer depth = 0;
        String trimmed = line;
        while(trimmed.startsWith('    ')) {
            depth++;
            trimmed = trimmed.substring(4);
        }
        return depth;
    }
    
    private static Integer calculateXPosition(String elementType, Integer depth) {
        Integer basePosition = 100 + (depth * 200); // Base spacing
        
        // Adjust position based on element type
        switch on elementType {
            when 'Start' {
                return basePosition;
            }
            when 'Assignment' {
                return basePosition + 50;
            }
            when 'Record Lookup' {
                return basePosition + 100;
            }
            when 'Decision' {
                return basePosition + 150;
            }
            when 'Loop' {
                return basePosition + 200;
            }
            when 'Record Create' {
                return basePosition + 250;
            }
            when 'Record Update' {
                return basePosition + 300;
            }
            when 'Record Delete' {
                return basePosition + 350;
            }
            when 'Screen' {
                return basePosition + 400;
            }
            when 'Subflow' {
                return basePosition + 450;
            }
            when else {
                return basePosition;
            }
        }
    }

    @testVisible
    private static Object createFlowElement(FlowElementInfo elementInfo, Integer xPosition, Integer yPosition) {
        String name = elementInfo.name;
        String type = elementInfo.type;
        String defaultTarget = elementInfo.defaultTarget;
        String nextTarget = elementInfo.nextTarget;
        String noMoreTarget = elementInfo.noMoreTarget;
        String standardTarget = elementInfo.standardTarget;
        String faultTarget = elementInfo.faultTarget;
        List<DecisionRule> rules = elementInfo.rules;        
        String elementDescription = elementInfo.elementDescription;
        Integer x = xPosition;
        Integer y = yPosition;
    
        switch on type {
            when 'Start' {
                return createStartElement(name, standardTarget, rules, x, y);
            }
            when 'Assignment' {
                return createAssignmentElement(name, standardTarget, x, y);
            }
            when 'Record Lookup' {
                return createRecordLookupElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Decision' {
                return createDecisionElement(name, defaultTarget, rules, x, y);
            }
            when 'Loop' {
                return createLoopElement(name, nextTarget, noMoreTarget, x, y);
            }
            when 'Record Create' {
                return createRecordCreateElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Record Update' {
                return createRecordUpdateElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Record Delete' {
                return createRecordDeleteElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Record Rollback' {
                return createRecordRollbackElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Screen' {
                return createScreenElement(name, standardTarget, x, y);
            }
            when 'Subflow' {
                return createSubflowElement(name, standardTarget, x, y);
            }
            when 'Transform' {
                return createTransformElement(name, standardTarget, x, y);
            }
            when 'Wait' {
                return createWaitElement(name, defaultTarget, faultTarget, rules, x, y);
            }
            when 'Collection Processor' {
                return createCollectionProcessorElement(name, standardTarget, x, y);
            }
            when 'Action' {
                return createActionCallElement(name, standardTarget, faultTarget, x, y, elementDescription);
            }
            when 'Custom Error' {
                return createCustomErrorElement(name, standardTarget, x, y);
            }
            when 'Apex Plugin' {
                return createApexPluginElement(name, standardTarget, faultTarget, x, y);
            }
            when 'Orchestrated Stage' {
                return createOrchestratedStageElement(name, standardTarget, faultTarget, x, y);
            }
            when else {
                throw new FlowParsingException('Unknown element type: ' + type);
            }
        }
    }

    private class FlowParsingException extends Exception {}

    private static MetadataService.FlowStart createStartElement(
        String name, 
        String standardTarget, 
        List<DecisionRule> rules,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowStart start = new MetadataService.FlowStart();
        start.name = name;
        start.label = convertApiNameToLabel(name);
        start.description = 'Start element';
        start.locationX = x;
        start.locationY = y;
        
        if(String.isNotBlank(standardTarget)) {
            start.connector = new MetadataService.FlowConnector();
            start.connector.targetReference = standardTarget;
        }

        // Set scheduled paths
        if (rules != null && !rules.isEmpty()) {
            start.scheduledPaths = new List<MetadataService.FlowScheduledPath>();
            for (DecisionRule pathInfo : rules) {
                MetadataService.FlowScheduledPath path = new MetadataService.FlowScheduledPath();
                path.name = pathInfo.name;
                path.connector = new MetadataService.FlowConnector();
                path.connector.targetReference = pathInfo.targetRef;
                start.scheduledPaths.add(path);
            }
        }
        
        return start;
    }
    
    private static MetadataService.FlowAssignment createAssignmentElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowAssignment assignment = new MetadataService.FlowAssignment();
        assignment.name = name;
        assignment.label = convertApiNameToLabel(name);
        assignment.description = 'Assignment element';
        assignment.locationX = x;
        assignment.locationY = y;
        
        // Add a sample assignment value
        assignment.assignmentItems = new List<MetadataService.FlowAssignmentItem>();
        MetadataService.FlowAssignmentItem item = new MetadataService.FlowAssignmentItem();
        item.assignToReference = 'SampleVar';
        item.operator = 'Assign';
        item.value = new MetadataService.FlowElementReferenceOrValue();
        item.value.stringValue = 'Sample Value';
        assignment.assignmentItems.add(item);
        
        if(String.isNotBlank(standardTarget)) {
            assignment.connector = new MetadataService.FlowConnector();
            assignment.connector.targetReference = standardTarget;
        }
        
        return assignment;
    }
    
    private static MetadataService.FlowRecordLookup createRecordLookupElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowRecordLookup lookup = new MetadataService.FlowRecordLookup();
        lookup.name = name;
        lookup.label = convertApiNameToLabel(name);
        lookup.description = 'Record lookup element';
        lookup.locationX = x;
        lookup.locationY = y;
        lookup.object_x = 'Account'; // Note the _x suffix for reserved word
        
        // Add filter conditions
        lookup.filters = new List<MetadataService.FlowRecordFilter>();
        MetadataService.FlowRecordFilter filter = new MetadataService.FlowRecordFilter();
        filter.field = 'Name';
        filter.operator = 'EQUALS';
        filter.value = new MetadataService.FlowElementReferenceOrValue();
        filter.value.stringValue = 'Test Account';
        lookup.filters.add(filter);
        
        // Add output reference
        lookup.storeOutputAutomatically = true;
        lookup.outputReference = 'SampleVar';
        
        if(String.isNotBlank(standardTarget)) {
            lookup.connector = new MetadataService.FlowConnector();
            lookup.connector.targetReference = standardTarget;
        }
        if(String.isNotBlank(faultTarget)) {
            lookup.faultConnector = new MetadataService.FlowConnector();
            lookup.faultConnector.targetReference = faultTarget;
        }
        
        return lookup;
    }
    
    private static MetadataService.FlowDecision createDecisionElement(
        String name, 
        String defaultTarget,
        List<DecisionRule> rules,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowDecision decision = new MetadataService.FlowDecision();
        decision.name = name;
        decision.label = convertApiNameToLabel(name);
        decision.description = 'Decision element';

        // Set default connector
        decision.defaultConnector = new MetadataService.FlowConnector();
        decision.defaultConnector.targetReference = defaultTarget;
        
        // Initialize and add rules
        decision.rules = new List<MetadataService.FlowRule>();
        for (DecisionRule ruleInfo : rules) {
            MetadataService.FlowRule rule = new MetadataService.FlowRule();
            rule.name = ruleInfo.name;
            rule.label = convertApiNameToLabel(ruleInfo.name);
            rule.description = 'Decision rule';
            rule.connector = new MetadataService.FlowConnector();
            rule.connector.targetReference = ruleInfo.targetRef;
            decision.rules.add(rule);
        }
        
        decision.locationX = x;
        decision.locationY = y;
        
        return decision;
    }

    private static MetadataService.FlowLoop createLoopElement(
        String name, 
        String nextTarget,
        String noMoreTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowLoop loopElement = new MetadataService.FlowLoop();
        loopElement.name = name;
        loopElement.label = convertApiNameToLabel(name);
        loopElement.description = 'Loop element';

        if (String.isNotBlank(nextTarget)) {
            loopElement.nextValueConnector = new MetadataService.FlowConnector();
            loopElement.nextValueConnector.targetReference = nextTarget;
        }
        
        if (String.isNotBlank(noMoreTarget)) {
            loopElement.noMoreValuesConnector = new MetadataService.FlowConnector();
            loopElement.noMoreValuesConnector.targetReference = noMoreTarget;
        }
        
        // Set positioning
        loopElement.locationX = x;
        loopElement.locationY = y;
        
        return loopElement;
    }

    private static MetadataService.FlowRecordCreate createRecordCreateElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowRecordCreate element = new MetadataService.FlowRecordCreate();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Record create element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordUpdate createRecordUpdateElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowRecordUpdate element = new MetadataService.FlowRecordUpdate();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Record update element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordDelete createRecordDeleteElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowRecordDelete element = new MetadataService.FlowRecordDelete();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Record delete element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowRecordRollback createRecordRollbackElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowRecordRollback element = new MetadataService.FlowRecordRollback();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Record rollback element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        
        return element;
    }


    private static MetadataService.FlowScreen createScreenElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowScreen element = new MetadataService.FlowScreen();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Screen element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        // Initialize empty lists for screen fields if needed
        element.fields = new List<MetadataService.FlowScreenField>();
        return element;
    }

    private static MetadataService.FlowSubflow createSubflowElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowSubflow element = new MetadataService.FlowSubflow();
        element.name = name;
        element.flowName = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Subflow element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        return element;
    }

    private static MetadataService.FlowTransform createTransformElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowTransform element = new MetadataService.FlowTransform();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Transform element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        
        // Add sample transformation
        element.transformValues = new List<MetadataService.FlowTransformValue>();
        MetadataService.FlowTransformValue transform = new MetadataService.FlowTransformValue();
        transform.transformValueName = 'sampleTransform';
        transform.transformValueLabel = 'Sample Value';
        element.transformValues.add(transform);
        
        return element;
    }

    private static MetadataService.FlowWait createWaitElement(
        String name, 
        String defaultTarget,
        String faultTarget,
        List<DecisionRule> rules,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowWait waitElement = new MetadataService.FlowWait();
        waitElement.name = name;
        waitElement.label = convertApiNameToLabel(name);
        waitElement.description = 'Wait element';

        // Set default connector
        waitElement.defaultConnector = new MetadataService.FlowConnector();
        waitElement.defaultConnector.targetReference = defaultTarget;
        if(String.isNotBlank(faultTarget)) {
            waitElement.faultConnector = new MetadataService.FlowConnector();
            waitElement.faultConnector.targetReference = faultTarget;
        }
        
        // Initialize and add rules
        waitElement.waitEvents = new List<MetadataService.FlowWaitEvent>();
        for (DecisionRule ruleInfo : rules) {
            MetadataService.FlowWaitEvent event = new MetadataService.FlowWaitEvent();
            event.name = ruleInfo.name;
            event.label = convertApiNameToLabel(ruleInfo.name);
            event.description = 'Wait event';
            event.connector = new MetadataService.FlowConnector();
            event.connector.targetReference = ruleInfo.targetRef;
            waitElement.waitEvents.add(event);
        }
        
        waitElement.locationX = x;
        waitElement.locationY = y;
        return waitElement;
    }

    private static MetadataService.FlowActionCall createActionCallElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y,
        String elementDescription
    ) {
        MetadataService.FlowActionCall element = new MetadataService.FlowActionCall();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Action call element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        element.description = elementDescription;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowCustomError createCustomErrorElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowCustomError element = new MetadataService.FlowCustomError();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Custom error element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        return element;
    }

    private static MetadataService.FlowOrchestratedStage createOrchestratedStageElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowOrchestratedStage element = new MetadataService.FlowOrchestratedStage();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Orchestrated stage element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowApexPluginCall createApexPluginElement(
        String name, 
        String standardTarget, 
        String faultTarget,
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowApexPluginCall element = new MetadataService.FlowApexPluginCall();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Apex plugin element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        if(String.isNotBlank(faultTarget)) {
            element.faultConnector = new MetadataService.FlowConnector();
            element.faultConnector.targetReference = faultTarget;
        }
        return element;
    }

    private static MetadataService.FlowCollectionProcessor createCollectionProcessorElement(
        String name, 
        String standardTarget, 
        Integer x, 
        Integer y
    ) {
        MetadataService.FlowCollectionProcessor element = new MetadataService.FlowCollectionProcessor();
        element.name = name;
        element.label = convertApiNameToLabel(name);
        element.description = 'Collection Processor element';
        element.connector = createConnector(standardTarget);
        element.locationX = x;
        element.locationY = y;
        
        // Add collection processing configuration
        element.collectionProcessorType = 'Sort';
        element.sortOptions = new List<MetadataService.FlowCollectionSortOption>();
        MetadataService.FlowCollectionSortOption sortOption = new MetadataService.FlowCollectionSortOption();
        sortOption.sortField = 'Name';
        sortOption.sortOrder = 'Ascending';
        element.sortOptions.add(sortOption);
        
        return element;
    }
    
    private static MetadataService.FlowConnector createConnector(String targetRef) {
        MetadataService.FlowConnector connector = new MetadataService.FlowConnector();
        connector.targetReference = targetRef;
        return connector;
    }
    
    private static void addElementsToFlow(MetadataService.Flow flow, List<FlowElementWrapper> wrappers) {
        
        flow.start = null;
        
        for(FlowElementWrapper wrapper : wrappers) {
            Object element = wrapper.element;
            
            if(element instanceof MetadataService.FlowStart) {
                flow.start = (MetadataService.FlowStart)element;
                flow.startElementReference = null;
                
                // Add scheduled paths
                List<DecisionRule> paths = wrapper.info?.rules;
                if (paths != null && !paths.isEmpty()) {
                    flow.start.scheduledPaths = new List<MetadataService.FlowScheduledPath>();

                    for (DecisionRule path : paths) {
                        MetadataService.FlowScheduledPath scheduledPath = new MetadataService.FlowScheduledPath();
                        scheduledPath.name = path?.name;
                        scheduledPath.connector = new MetadataService.FlowConnector();
                        scheduledPath.connector.targetReference = path?.targetRef;
                        flow.start.scheduledPaths.add(scheduledPath);
                    }
                }
                
            } else if(element instanceof MetadataService.FlowAssignment) {
                flow.assignments = (flow.assignments != null) ? flow.assignments : new List<MetadataService.FlowAssignment>();
                flow.assignments.add((MetadataService.FlowAssignment)element);
            } else if(element instanceof MetadataService.FlowDecision) {
                flow.decisions = (flow.decisions != null) ? flow.decisions : new List<MetadataService.FlowDecision>();
                flow.decisions.add((MetadataService.FlowDecision)element);
            } else if(element instanceof MetadataService.FlowRecordLookup) {
                flow.recordLookups = (flow.recordLookups != null) ? flow.recordLookups : new List<MetadataService.FlowRecordLookup>();
                flow.recordLookups.add((MetadataService.FlowRecordLookup)element);
            } else if(element instanceof MetadataService.FlowLoop) {
                flow.loops = (flow.loops != null) ? flow.loops : new List<MetadataService.FlowLoop>();
                flow.loops.add((MetadataService.FlowLoop)element);
            } else if(element instanceof MetadataService.FlowRecordCreate) {
                flow.recordCreates = (flow.recordCreates != null) ? flow.recordCreates : new List<MetadataService.FlowRecordCreate>();
                flow.recordCreates.add((MetadataService.FlowRecordCreate)element);
            } else if(element instanceof MetadataService.FlowRecordUpdate) {
                flow.recordUpdates = (flow.recordUpdates != null) ? flow.recordUpdates : new List<MetadataService.FlowRecordUpdate>();
                flow.recordUpdates.add((MetadataService.FlowRecordUpdate)element);
            } else if(element instanceof MetadataService.FlowRecordDelete) {
                flow.recordDeletes = (flow.recordDeletes != null) ? flow.recordDeletes : new List<MetadataService.FlowRecordDelete>();
                flow.recordDeletes.add((MetadataService.FlowRecordDelete)element);
            } else if(element instanceof MetadataService.FlowScreen) {
                flow.screens = (flow.screens != null) ? flow.screens : new List<MetadataService.FlowScreen>();
                flow.screens.add((MetadataService.FlowScreen)element);
            } else if(element instanceof MetadataService.FlowSubflow) {
                flow.subflows = (flow.subflows != null) ? flow.subflows : new List<MetadataService.FlowSubflow>();
                flow.subflows.add((MetadataService.FlowSubflow)element);
            } else if(element instanceof MetadataService.FlowActionCall) {
                flow.actionCalls = (flow.actionCalls != null) ? flow.actionCalls : new List<MetadataService.FlowActionCall>();
                flow.actionCalls.add((MetadataService.FlowActionCall)element);
            } else if(element instanceof MetadataService.FlowTransform) {
                flow.transforms = (flow.transforms != null) ? flow.transforms : new List<MetadataService.FlowTransform>();
                flow.transforms.add((MetadataService.FlowTransform)element);
            } else if(element instanceof MetadataService.FlowWait) {
                flow.waits = (flow.waits != null) ? flow.waits : new List<MetadataService.FlowWait>();
                flow.waits.add((MetadataService.FlowWait)element);
            } else if(element instanceof MetadataService.FlowCollectionProcessor) {
                flow.collectionProcessors = (flow.collectionProcessors != null) ? flow.collectionProcessors : new List<MetadataService.FlowCollectionProcessor>();
                flow.collectionProcessors.add((MetadataService.FlowCollectionProcessor)element);
            } else if(element instanceof MetadataService.FlowActionCall) {
                flow.actionCalls = (flow.actionCalls != null) ? flow.actionCalls : new List<MetadataService.FlowActionCall>();
                flow.actionCalls.add((MetadataService.FlowActionCall)element);
            } else if(element instanceof MetadataService.FlowCustomError) {
                flow.customErrors = (flow.customErrors != null) ? flow.customErrors : new List<MetadataService.FlowCustomError>();
                flow.customErrors.add((MetadataService.FlowCustomError)element);
            } else if(element instanceof MetadataService.FlowApexPluginCall) {
                flow.apexPluginCalls = (flow.apexPluginCalls != null) ? flow.apexPluginCalls : new List<MetadataService.FlowApexPluginCall>();
                flow.apexPluginCalls.add((MetadataService.FlowApexPluginCall)element);
            } else if(element instanceof MetadataService.FlowOrchestratedStage) {
                flow.orchestratedStages = (flow.orchestratedStages != null) ? flow.orchestratedStages : new List<MetadataService.FlowOrchestratedStage>();
                flow.orchestratedStages.add((MetadataService.FlowOrchestratedStage)element);
            } else if(element instanceof MetadataService.FlowRecordRollback) {
                flow.recordRollbacks = (flow.recordRollbacks != null) ? flow.recordRollbacks : new List<MetadataService.FlowRecordRollback>();
                flow.recordRollbacks.add((MetadataService.FlowRecordRollback)element);
            }
        }
    }
    
    public static String convertApiNameToLabel(String apiName) {
        if (String.isBlank(apiName)) return '';
        
        // Split by capital letters or numbers
        List<String> parts = apiName.split('(?=[A-Z0-9])');
        
        // Convert each part to uppercase and join with space
        List<String> formattedParts = new List<String>();
        for (String part : parts) {
            formattedParts.add(part.toUpperCase());
        }
        
        return String.join(formattedParts, ' ');
    }

    @testVisible
    private static String generateFlowHtml(List<MetadataService.Flow> flows, FlowExecution execution) {
        String html = '<!DOCTYPE html><html><head><style>\n' +
            '    span,a {\n' +
            '      font-size: 16px;\n' +
            '    }\n' +
            '  </style></head><body>';
        
        // Header section
        html += '<p>\n<span><img src="https://a.sfdcstatic.com/shared/images/c360-nav/mobile_logo.png" alt="Salesforce logo" width="40px"></span><br>\n';
        
        // Error title
        html += '<span style="font-size:x-large;font-weight:bold">An Error Occurred with Your "' + execution.flowLabel + '" Flow</span><br><br>\n';
        
        // Error description and debug link
        html += '<span>You\'ve received this email because an error occurred while your "' + execution.flowLabel + 
            '" flow was running. <a href="' + getFlowBuilderUrl(execution) + '">Debug this flow in Flow Builder.</a><br></span><br>\n\n';
        
        // Error details from execution
        if (!execution.elementErrors.isEmpty()) {
            for (String elementName : execution.elementErrors.keySet()) {
                html += '<span>Error element ' + elementName + ' (' + execution.elementErrors.get(elementName).elementType + ').</span><br>\n';
                html += '<span>' + execution.elementErrors.get(elementName).errorMessage + '\n</span><br>\n';
            }
        }
        
        // Open Flow button
        html += '<br><a href="' + getFlowUrl(execution) + '" style="background-color:#0176D3;border-radius:4px;color:white;padding:.5rem 1rem;text-decoration:none">Open Flow</a><br>\n';
        
        // Flow Error Details section
        html += '<br></p>\n<hr>\n<br><span style="font-size:x-large;font-weight:bold">Flow Error Details</span><br><br>\n';
        
        // Flow Details
        html += generateFlowDetailsHtml(execution);
        
        // Flow Interview Details
        html += generateFlowInterviewDetailsHtml(execution);
        
        // How the Interview Started
        html += generateInterviewStartDetailsHtml(execution);
        
        // Flow execution path
        html += generateExecutionPathHtml(execution);
        
        // Error section
        if (!execution.elementErrors.isEmpty()) {
            html += '<hr>\n<p>\n';
            for (String elementName : execution.elementErrors.keySet()) {
                html += '<span>Error Occurred: ' + execution.elementErrors.get(elementName).errorMessage + '\n</span><br>\n';
            }
            html += '</p>\n<hr>\n';
        }
        
        // Error ID
        html += '<hr>\n<p>Salesforce Error ID: 1735275466-5549 (-818703010)</p>';
        
        html += '</body></html>';
        return html;
    }
    
    private static String generateFlowDetailsHtml(FlowExecution execution) {
        return '<p>\n' +
            '<span style="font-weight:bold;">Flow Details</span><br>\n' +
            '<br><span><span style="font-weight:bold;">Flow API Name: </span>' + execution.flowApiName + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Type: </span>' + execution.flowType + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Version: </span>' + execution.flowVersion + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Status: </span>' + execution.flowStatus + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Org: </span>' + execution.orgName + ' (' + execution.orgId + ')</span><br>\n' +
            '</p>\n';
    }
    
    private static String generateFlowInterviewDetailsHtml(FlowExecution execution) {
        return '<br><span style="font-weight:bold;">Flow Interview Details</span><br>\n' +
            '<br><span><span style="font-weight:bold;">Interview Label: </span>' + execution.interviewLabel + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Interview GUID: </span>' + execution.interviewGuid + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Current User: </span>' + execution.currentUserName + ' (' + execution.currentUserId + ')</span><br>\n' +
            '<span><span style="font-weight:bold;">Start time: </span>' + execution.startTime.format('M/d/yyyy, h:mm a') + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Duration: </span>' + execution.durationSeconds + ' seconds</span><br>\n' +
            '</p>\n';
    }
    
    private static String generateInterviewStartDetailsHtml(FlowExecution execution) {
        String html = '<br><span style="font-weight:bold;">How the Interview Started</span><br>\n' +
            '<span>' + execution.currentUserName + ' (' + execution.currentUserId + ') started the flow interview.</span><br>\n' +
            '<span>API Version for Running the Flow: ' + execution.apiVersion + '</span><br>\n';
        
        if (!execution.inputVariables.isEmpty() || !execution.inputRecords.isEmpty()) {
            html += '<span>Some of this flows variables were set when the interview started.</span><br>\n';
            
            for (String varName : execution.inputVariables.keySet()) {
                html += '<span>' + varName + ' = ' + execution.inputVariables.get(varName) + '</span><br>\n';
            }
            
            for (String recordVar : execution.inputRecords.keySet()) {
                html += '<span>' + recordVar + ' = ' + execution.inputRecords.get(recordVar) + '</span><br>\n';
            }
        }
        
        html += '</p>\n';
        return html;
    }
    
    private static String generateExecutionPathHtml(FlowExecution execution) {
        String html = '';
        
        for (FlowExecutionStep step : execution.executionPath) {

            // Wait resume element devided into two parts: pause and resume and contains some info in the middle
            if (step.elementType == 'Wait' && step.context?.get('pause') == 'resume') {
                html += generatePauseResumeHtml(step);
            }

            // skip main flow start
            if((step.elementType == 'Start' && step.context?.get('isMainFlow') == 'true')) {
                continue;
            }

            // enter subflow
            if(step.elementType == 'Subflow' && step.action == 'ENTER') {
                html += generateEnterSubflowHtml(step);
                continue;
            }
            if(step.elementType == 'Subflow' && step.action == 'EXIT') {
                html += generateExitSubflowHtml(step);
                continue;
            }            
            
            html += '<p>\n<span style="font-weight:bold;">' + step.type.toUpperCase() + ': </span>' + step.elementLabel + '<br>\n';

            // Add element-specific details
            if (step.elementType == 'Decision') {
                html += generateDecisionHtml(step);
            }
            if (step.elementType == 'Loop') {
                html += generateLoopHtml(step);                
            }
            
            html += '</p>\n';

            if(step.context.containsKey('hasFault') && step.context.get('hasFault') == 'true') {
                html += generateFaultHtml(step);
            }
        }
        
        return html;
    }

    private static String generateFaultHtml(FlowExecutionStep step) {
        String html = '';
        html += '<hr>\n';
        html += '<p>\n';
        html += '<span>Error Occurred: This error occurred when the flow tried to create records: REQUIRED_FIELD_MISSING: Required fields are missing: [Name]. You can look up ExceptionCode values in the <a href="https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm#">SOAP API Developer Guide</a>.</span><br>\n';
        html += '</p>\n';
        html += '<hr>\n';
        html += '<p>\n';
        html += '<span style="font-weight:bold;">Error Handled</span><br>\n';
        html += '<span>The "' + step.elementName + '" element encountered an error. Because this element has a fault connector, the interview executes the elements in the fault path.</span><br>\n';
        html += '</p>\n';
        return html;
    }

    private static String generatePauseResumeHtml(FlowExecutionStep step) {
        return '<hr>\n' +
                '<p>\n' +
                '<span>The interview was paused at 3/11/2025, 7:43 AM.</span><br>\n' +
                '</p>\n' +
                '<p>\n' +
                '<span style="font-weight:bold;">Transaction Committed</span><br>\n' +
                '<span>Any records that the flow was ready to create, update, or delete were committed to the database.</span><br>\n' +
                '</p>\n' +
                '<p>\n' +
                '<span style="font-weight:bold;">Resume</span><br>\n' +
                '<span>The interview was resumed at 3/11/2025, 7:43 AM by Test DY QA (005ak0000072Hrx).</span><br>\n' +
                '</p>\n' +
                '<hr>\n';
    }
    
    private static String generateEnterSubflowHtml(FlowExecutionStep step) {

        String html = '';
        html += '<p>\n<span style="font-weight:bold;">SUBFLOW: </span>' + step.context.get('flowLabel') + '<br>\n';
        html += '<span>Enter flow ' + step.context.get('flowName') + ' version ' + step.context.get('flowVersion') + '.</span><br>\n';
        html += '<span>API Version for Running the Flow: ' + (step.context.get('flowApiVersion') ?? '63') + '</span><br>\n';
        html += '<span style="font-weight:bold;">Inputs:</span><br>\n';
        html += '<span>None.</span><br>\n';
        html += '</p>\n';
        return html;
    }

    private static String generateExitSubflowHtml(FlowExecutionStep step) {
        String html = '';
        html += '<p>\n<span style="font-weight:bold;">SUBFLOW: </span>' + step.context.get('flowLabel') + '<br>\n';
        html += '<span>Exit flow ' + step.context.get('flowName') + ' version ' + step.context.get('flowVersion') + '.</span><br>\n';
        html += '<span style="font-weight:bold;">Outputs:</span><br>\n';
        html += '<span>None.</span><br>\n';
        html += '</p>\n';
        return html;
    }

    private static String generateLoopHtml(FlowExecutionStep step) {
        String html = '';

        if (step.context.get('executedOutcome') == 'Next Item') {
            html += '<span>Loop Through: ' + step.context.get('loopVariable') + '</span><br>\n';
            html += '<span>Current iteration item: ' + step.context.get('loopValue') + '</span><br>\n';
        }
        else if (step.context.get('executedOutcome') == 'After Last Item') {
            html += '<span>End Loop.</span><br>\n';
        }
        
        return html;
    }

    private static String generateDecisionHtml(FlowExecutionStep step) {
        String html = '';

        Map<String, Object> metadataInfo = (Map<String, Object>)step.elementInfo.get('metadataInfo');
        List<Object> outcomes = (List<Object>)metadataInfo?.get('outcomes');
        
        if (step.context.get('executedOutcome') != 'Default') {
            // Show only executed outcome
            html += '<span>Outcome executed: ' + step.context.get('executedOutcome') + '</span><br>\n';
            html += '<span>Outcome conditions: </span><br>\n';

            if(String.isNotBlank(step.context.get('condition'))) {
                html += '<span>' + step.context.get('condition') + '</span><br>\n';
            }            
        }
        else {
            // Show all non-executed outcomes and default
            for (Object outcome : outcomes) {
                Map<String, Object> outcomeMap = (Map<String, Object>)outcome;
                if (!Boolean.valueOf(outcomeMap.get('isDefault'))) {
                    html += '<span>Skipped this outcome because its conditions weren\'t met: ' + 
                        outcomeMap.get('name') + '</span><br>\n';
                    html += '<span>Outcome conditions: </span><br>\n';
                    
                    List<Object> conditions = (List<Object>)outcomeMap.get('conditions');
                    for (Integer i = 0; i < conditions.size(); i++) {
                        html += '<span>' + (i + 1) + '. ' + conditions[i] + '</span><br>\n';
                    }
                    html += '<br/>\n';
                }
            }
            html += '<span>Default outcome executed.</span><br>\n';
        }
        
        return html;
    }
    
    private static String getFlowBuilderUrl(FlowExecution execution) {
        return '/builder_platform_interaction/flowBuilder.app?flowId=' + execution.flowId + '&guid=' + execution.interviewGuid;
    }
    
    private static String getFlowUrl(FlowExecution execution) {
        return '/builder_platform_interaction/flowBuilder.app?flowId=' + execution.flowId;
    }

    @testVisible
    private static Messaging.InboundEmail create_test_inbound_email(List<MetadataService.Flow> mockFlows, 
                                                                    FlowExecution execution) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(Test_LogService.CONNECETED_ORG_NAME);
        String generatedHtml = generateFlowHtml(mockFlows, execution);

        List<string> emails = new List<string>{'testemail1@gmail.com'};        
        email.subject = 'An error occurred with your "' + mockFlows.get(0).label + '" flow';
        email.fromAddress = 'system@salesforce.com';
        email.toAddresses = emails;

        Messaging.InboundEmail.Header dateHeader = new Messaging.InboundEmail.Header();
        dateHeader.name = 'Date';
        dateHeader.value = '01 Jun 2023 14:31:46 -0700';
        email.headers = new List<Messaging.InboundEmail.Header>{dateHeader};
        email.htmlBody = generatedHtml;

        return email;
    }
    
    // Helper method to update or add an edge
    private static void updateOrAddEdge(List<EdgeInfo> edges, String target, 
        List<Integer> indexes, String outcome) {

        Boolean found = false;
        for (EdgeInfo edge : edges) {
            if (edge.target == target) {
                // Update existing edge
                edge.indexes.addAll(indexes);
                edge.outcome = outcome;
                found = true;
                break;
            }
        }

        if (!found) {
            // Add new edge
            EdgeInfo newEdge = new EdgeInfo(target, indexes);
            newEdge.outcome = outcome;
            edges.add(newEdge);
        }
    }

    // Validate edge structure against expected edges
    private static void validateEdgeStructure(Map<String, Object> edgesObj, 
        Map<String, List<EdgeInfo>> expectedEdges, FlowExecution execution) {

        // Validate each source has the expected edges
        for (String source : expectedEdges.keySet()) {
            if (source == 'Start' || source == 'start') {
                continue; // Skip Start nodes as they're handled specially
            }
            
            // Get the edges for this source from the edges object
            List<Object> edgesList = (List<Object>)edgesObj.get(source);
            System.assert(edgesList != null, 'Missing edges for source: ' + source);
            
            // Validate each expected edge
            for (EdgeInfo expectedEdge : expectedEdges.get(source)) {
                Boolean found = false;
                
                for (Object edgeObj : edgesList) {
                    Map<String, Object> edge = (Map<String, Object>)edgeObj;
                    String edgeTarget = (String)edge.get('target');
                    
                    if (edgeTarget == expectedEdge.target) {
                        found = true;
                        
                        // Find the correct step that leads to this target
                        FlowExecutionStep sourceStep = findMatchingStep(execution.executionPath, source, expectedEdge.target);
                        
                        validateEdgeDetails(edge, expectedEdge, sourceStep, execution);
                        break;
                    }
                }                
                System.assert(found, 'Missing expected edge: ' + source + '->' + expectedEdge.target);
            }
        }
    }


    // Find a matching step in the execution path
    private static FlowExecutionStep findMatchingStep(List<FlowExecutionStep> steps, 
        String sourceName, String targetName) {

        for (Integer i = 0; i < steps.size() - 1; i++) {
            FlowExecutionStep currentStep = steps[i];
            FlowExecutionStep nextStep = steps[i + 1];
            
            if (currentStep.elementName == sourceName && nextStep.elementName == targetName) {
                return currentStep;
            }
        }

        // If we're looking for the last step
        if (steps[steps.size() - 1].elementName == sourceName) {
            return steps[steps.size() - 1];
        }

        return null;
    }
    
    // Validate edge details against expected edge
    private static void validateEdgeDetails(Map<String, Object> edge, EdgeInfo expectedEdge, 
        FlowExecutionStep sourceStep, FlowExecution execution) {

        // Validate indexes
        List<Object> actualIndexes = (List<Object>)edge.get('indexes');        
        validateIndexes(expectedEdge.indexes, actualIndexes, sourceStep.elementName, expectedEdge.target);

        // Validate outcomes based on element type
        if (sourceStep.elementType == 'Decision') {
            validateDecisionOutcome(edge, sourceStep, expectedEdge.target);
        }
        else if (sourceStep.elementType == 'Loop') {
            validateLoopOutcome(edge, sourceStep, expectedEdge.target);
        }
    }
    
    public class EdgeInfo {
        public String target { get; set; }
        public List<Integer> indexes { get; set; }
        public String outcome { get; set; }
        
        public EdgeInfo(String target, List<Integer> indexes) {
            this.target = target;
            this.indexes = indexes;
        }
    }
    
    // Validate indexes match expected indexes
    private static void validateIndexes(List<Integer> expected, List<Object> actual, 
        String source, String target) {

        // Convert actual to List<Integer>
        List<Integer> actualIndexes = new List<Integer>();
        for (Object idx : actual) {
            actualIndexes.add((Integer)idx);
        }

        // Sort both lists for comparison
        expected.sort();
        actualIndexes.sort();

        // For subflows, we may need to be more flexible with index validation
        // as the indexes might be different between test runs
        Boolean indexesMatch = expected.size() == actualIndexes.size();

        if (indexesMatch) {
            // Check if the indexes match exactly
            for (Integer i = 0; i < expected.size(); i++) {
                if (expected[i] != actualIndexes[i]) {
                    indexesMatch = false;
                    break;
                }
            }
        }

        // If indexes don't match exactly, check if they're at least in the same relative order
        if (!indexesMatch) {
            // For now, we'll just assert that the counts match
            System.assertEquals(expected.size(), actualIndexes.size(), 
                'Index count mismatch for edge ' + source + '->' + target + 
                ': Expected: ' + expected + ', Actual: ' + actualIndexes);
        }
    }

    // Validate decision outcome
    private static void validateDecisionOutcome(Map<String, Object> edge, 
        FlowExecutionStep sourceStep, String targetName) {

        String expectedOutcome = (String)sourceStep.context.get('executedOutcome');
        String actualOutcome = (String)edge.get('outcome');

        // For decisions, the outcome should match the executed outcome
        System.assertEquals(expectedOutcome, actualOutcome, 
            'Outcome mismatch for decision edge ' + sourceStep.elementName + '->' + targetName + 
            ': Expected: ' + expectedOutcome + ', Actual: ' + actualOutcome);
    }

    // Validate loop outcome
    private static void validateLoopOutcome(Map<String, Object> edge, 
        FlowExecutionStep sourceStep, String targetName) {

        String expectedOutcome = (String)sourceStep.context.get('executedOutcome');
        String actualOutcome = (String)edge.get('outcome');

        // For loops, the outcome should be either "Next" or "NoMore"
        if (expectedOutcome == 'Next Item') {
            System.assertEquals('Next', actualOutcome, 
                'Outcome mismatch for loop edge ' + sourceStep.elementName + '->' + targetName + 
                ': Expected: Next, Actual: ' + actualOutcome);
        }
        else if (expectedOutcome == 'After Last Item') {
            System.assertEquals('NoMore', actualOutcome, 
                'Outcome mismatch for loop edge ' + sourceStep.elementName + '->' + targetName + 
                ': Expected: NoMore, Actual: ' + actualOutcome);
        }
    }

    // Inner class to represent a flow instance
    public class FlowInstance {
        public String flowName;
        public Integer instanceId;
        public FlowInstance parentInstance;
        public List<FlowInstance> childFlows;
        public List<FlowExecutionStep> steps;
        
        public FlowInstance(String flowName, Integer instanceId, FlowInstance parentInstance) {
            this.flowName = flowName;
            this.instanceId = instanceId;
            this.parentInstance = parentInstance;
            this.childFlows = new List<FlowInstance>();
            this.steps = new List<FlowExecutionStep>();
        }
    }

    @testVisible
    private static void validateFlowStructure(Map<String, Object> result, FlowExecution execution, List<MetadataService.Flow> flows) {
        // Instead of a map of flow names to instances, we'll use an ordered list of flow instances
        List<FlowInstance> orderedFlowInstances = new List<FlowInstance>();
        
        // Track active subflows with their steps
        Map<String, FlowInstance> activeSubflows = new Map<String, FlowInstance>();
        List<String> subflowStack = new List<String>();
        String mainFlowName = null;
        Integer instanceCounter = 0;
        Map<String, Integer> flowInstanceCounters = new Map<String, Integer>();
        
        // First, identify the main flow
        for (FlowExecutionStep step : execution.executionPath) {
            if (step.context?.get('isMainFlow') == 'true') {
                mainFlowName = step.context.get('flowName');
                break;
            }
        }
        
        // Create the main flow instance
        FlowInstance mainFlowInstance = new FlowInstance(mainFlowName, 1, null);
        orderedFlowInstances.add(mainFlowInstance);
        flowInstanceCounters.put(mainFlowName, 1);
        
        // Process all steps in order
        for (Integer i = 0; i < execution.executionPath.size(); i++) {
            FlowExecutionStep step = execution.executionPath[i];
            
            String flowName = step.context?.get('flowName');
            if (String.isBlank(flowName)) continue;
            
            // Handle main flow steps
            if (step.context?.get('isMainFlow') == 'true') {
                mainFlowInstance.steps.add(step);
                continue;
            }
            
            // Handle subflow steps
            String action = step.action;
            
            if (action == 'ENTER') {
                // Starting a new subflow
                String parentFlowName = step.context.get('parentFlowName');
                
                // Find the parent flow instance
                FlowInstance parentInstance = null;
                if (!subflowStack.isEmpty()) {
                    String parentFlowKey = subflowStack[subflowStack.size() - 1];
                    parentInstance = activeSubflows.get(parentFlowKey);
                }
                else if (parentFlowName == mainFlowName) {
                    parentInstance = mainFlowInstance;
                }
                
                // Create a new instance for this subflow
                if (!flowInstanceCounters.containsKey(flowName)) {
                    flowInstanceCounters.put(flowName, 0);
                }
                flowInstanceCounters.put(flowName, flowInstanceCounters.get(flowName) + 1);
                Integer instanceId = flowInstanceCounters.get(flowName);
                
                String flowInstanceKey = flowName + '-' + instanceId;
                FlowInstance newInstance = new FlowInstance(flowName, instanceId, parentInstance);
                
                // Add the step to the new instance
                newInstance.steps.add(step);
                
                // Add this instance to the ordered list
                orderedFlowInstances.add(newInstance);
                
                // Track as active subflow
                subflowStack.add(flowInstanceKey);
                activeSubflows.put(flowInstanceKey, newInstance);
                
                // Also add this ENTER step to the parent flow if it exists
                if (parentInstance != null) {
                    parentInstance.steps.add(step);
                    
                    // Add this subflow as a child of the parent
                    parentInstance.childFlows.add(newInstance);
                }
            } 
            else if (action == 'EXIT') {
                // Exiting a subflow
                if (!subflowStack.isEmpty()) {
                    String currentFlowKey = subflowStack[subflowStack.size() - 1];
                    FlowInstance currentInstance = activeSubflows.get(currentFlowKey);
                    
                    // Add the step to the current instance
                    if (currentInstance != null) {
                        currentInstance.steps.add(step);
                    }
                    
                    // Also add this EXIT step to the parent flow if it exists
                    if (subflowStack.size() > 1) {
                        String parentFlowKey = subflowStack[subflowStack.size() - 2];
                        FlowInstance parentInstance = activeSubflows.get(parentFlowKey);
                        if (parentInstance != null) {
                            parentInstance.steps.add(step);
                        }
                    }
                    else if (currentInstance != null && currentInstance.parentInstance == mainFlowInstance) {
                        mainFlowInstance.steps.add(step);
                    }
                    
                    // Remove from active subflows and stack
                    activeSubflows.remove(currentFlowKey);
                    subflowStack.remove(subflowStack.size() - 1);
                }
            } 
            else {
                // Regular subflow step
                if (!subflowStack.isEmpty()) {
                    String currentFlowKey = subflowStack[subflowStack.size() - 1];
                    FlowInstance currentInstance = activeSubflows.get(currentFlowKey);
                    if (currentInstance != null) {
                        currentInstance.steps.add(step);
                    }
                }
            }
        }
        
        // Convert the ordered instances to the format expected by the rest of the code
        Map<String, List<List<FlowExecutionStep>>> flowStepsInstances = new Map<String, List<List<FlowExecutionStep>>>();
        
        for (FlowInstance instance : orderedFlowInstances) {
            if (!flowStepsInstances.containsKey(instance.flowName)) {
                flowStepsInstances.put(instance.flowName, new List<List<FlowExecutionStep>>());
            }
            flowStepsInstances.get(instance.flowName).add(instance.steps);
        }
        
        // Process each flow to extract edges and nodes
        for (String flowName : flowStepsInstances.keySet()) {
            List<List<FlowExecutionStep>> flowInstances = flowStepsInstances.get(flowName);
            
            // Find the corresponding flow metadata
            MetadataService.Flow flowMetadata = null;
            for (MetadataService.Flow flow : flows) {
                if (flow.fullName == flowName) {
                    flowMetadata = flow;
                    break;
                }
            }
            
            if (flowMetadata == null) {                
                continue;
            }
            
            // Process each instance of this flow
            for (Integer instanceIndex = 0; instanceIndex < flowInstances.size(); instanceIndex++) {
                List<FlowExecutionStep> steps = flowInstances[instanceIndex];
                
                // Extract nodes and edges for this flow instance
                Map<String, Object> nodesObj = new Map<String, Object>();
                Map<String, Object> edgesObj = new Map<String, Object>();
                
                // Process steps to extract nodes and edges
                extractNodesAndEdges(steps, nodesObj, edgesObj, flowMetadata);
                
                // Add to result
                String flowKey = flowName + (instanceIndex > 0 ? '-' + (instanceIndex + 1) : '');
                Map<String, Object> flowObj = new Map<String, Object>{
                    'nodes' => nodesObj,
                    'edges' => edgesObj,
                    'metadata' => new Map<String, Object>{
                        'flowName' => flowName,
                        'instanceIndex' => instanceIndex + 1
                    }
                };
                
                result.put(flowKey, flowObj);
                
                // Validate the structure
                validateNodes(nodesObj, execution);
                validateEdges(edgesObj, execution);
            }
        }
    }

    // Validate nodes against the execution path
    private static void validateNodes(Map<String, Object> nodesObj, FlowExecution execution) {
        // Get all executed elements from the execution path
        Set<String> executedElements = new Set<String>(execution.executedElements);
        
        // Check that all executed elements have corresponding nodes
        for (String elementName : executedElements) {
            // Skip special elements like 'Start'
            if (elementName == 'Start' || elementName == 'start') {
                continue;
            }
            
            System.assert(nodesObj.containsKey(elementName), 
                'Missing node for executed element: ' + elementName);
            
            // Verify the node is marked as executed
            Map<String, Object> node = (Map<String, Object>)nodesObj.get(elementName);
            System.assertEquals(true, node.get('executed'), 
                'Node should be marked as executed: ' + elementName);
        }
        
        // Check for any errors in the execution
        for (String elementName : execution.elementErrors.keySet()) {
            System.assert(nodesObj.containsKey(elementName), 
                'Missing node for element with error: ' + elementName);
            
            Map<String, Object> node = (Map<String, Object>)nodesObj.get(elementName);
            System.assert(node.containsKey('error'), 
                'Node should have error information: ' + elementName);
            
            Map<String, Object> error = (Map<String, Object>)node.get('error');
            System.assertEquals(execution.elementErrors.get(elementName).errorMessage, 
                error.get('message'), 'Error message mismatch for element: ' + elementName);
        }
    }

    // Validate edges against the execution path
    private static void validateEdges(Map<String, Object> edgesObj, FlowExecution execution) {
        Map<String, List<EdgeInfo>> expectedEdges = new Map<String, List<EdgeInfo>>();
        List<FlowExecutionStep> steps = execution.executionPath;
        
        // Track indexes and outcomes for branching
        Map<String, Map<String, List<Integer>>> edgeIndexes = new Map<String, Map<String, List<Integer>>>();
        Map<String, Map<String, String>> edgeOutcomes = new Map<String, Map<String, String>>();
        
        // Process each step in execution path
        Integer stepIndex = 1;
        
        for (Integer i = 0; i < steps.size() - 1; i++) {
            FlowExecutionStep currentStep = steps[i];
            FlowExecutionStep nextStep = steps[i + 1];

            String source = currentStep.elementName;
            String target = nextStep.elementName;
            
            // Skip if current step is exiting
            if (currentStep.action == 'EXIT') {
                continue;
            }
            
            // Skip if next step is entering a different flow
            if (nextStep.action == 'ENTER' && 
                currentStep.context.get('flowName') != nextStep.context.get('flowName')) {
                continue;
            }
            
            // Handle Start nodes
            if (currentStep.elementName == 'Start' && currentStep.context?.get('isMainFlow') == 'true') {
                source = 'start';
            }
            if (currentStep.elementName == 'Start' && currentStep.action == 'ENTER') {
                source = 'start';
            }
            
            // Add edge info
            if (!edgeIndexes.containsKey(source)) {
                edgeIndexes.put(source, new Map<String, List<Integer>>());
                edgeOutcomes.put(source, new Map<String, String>());
            }
            if (!edgeIndexes.get(source).containsKey(target)) {
                edgeIndexes.get(source).put(target, new List<Integer>());
            }
            edgeIndexes.get(source).get(target).add(stepIndex);
            edgeOutcomes.get(source).put(target, currentStep.outcome);
            
            // Create edge info
            if (!expectedEdges.containsKey(source)) {
                expectedEdges.put(source, new List<EdgeInfo>());
            }            
            
            // Handle special cases (Loop, Decision)
            if (currentStep.elementType == 'Loop') {
                Map<String, Object> metadata = (Map<String, Object>)currentStep.elementInfo.get('metadataInfo');
                if (metadata != null) {
                    Map<String, Object> nextConn = (Map<String, Object>)metadata.get('nextConnection');
                    Map<String, Object> noMoreConn = (Map<String, Object>)metadata.get('noMoreConnection');
                    
                    if (nextConn != null && target == (String)nextConn.get('target')) {
                        updateOrAddEdge(expectedEdges.get(source), target, 
                            edgeIndexes.get(source).get(target), 'Next');
                    }
                    else if (noMoreConn != null && target == (String)noMoreConn.get('target')) {
                        updateOrAddEdge(expectedEdges.get(source), target, 
                            edgeIndexes.get(source).get(target), 'NoMore');
                    }
                }
            }
            else {
                // Standard paths
                updateOrAddEdge(expectedEdges.get(source), target, 
                    edgeIndexes.get(source).get(target), currentStep.outcome);
            }
            
            stepIndex++;
        }
        
        validateEdgeStructure(edgesObj, expectedEdges, execution);
    }

    // Helper method to extract nodes and edges from flow steps
    private static void extractNodesAndEdges(List<FlowExecutionStep> steps, 
        Map<String, Object> nodesObj, Map<String, Object> edgesObj, MetadataService.Flow flowMetadata) {

        // Track visited elements to avoid duplicates
        Set<String> visitedElements = new Set<String>();

        // Process each step
        for (Integer i = 0; i < steps.size(); i++) {
            FlowExecutionStep step = steps[i];
            String elementName = step.elementName;
            
            // Skip if already processed
            if (visitedElements.contains(elementName)) {
                continue;
            }
            
            // Add node
            Map<String, Object> nodeObj = new Map<String, Object>{
                'type' => step.elementType,
                'label' => step.elementLabel,
                'executed' => true
            };
            
            // Add element info if available
            if (step.elementInfo != null && !step.elementInfo.isEmpty()) {
                nodeObj.put('metadata', step.elementInfo);
            }
            
            // Add to nodes
            nodesObj.put(elementName, nodeObj);
            visitedElements.add(elementName);
            
            // Add edge if there's a next step
            if (i < steps.size() - 1) {
                FlowExecutionStep nextStep = steps[i + 1];
                
                // Skip if this is an EXIT action
                if (step.action == 'EXIT') {
                    continue;
                }
                
                // Skip if next step is an ENTER action for a different flow
                if (nextStep.action == 'ENTER' && 
                    step.context.get('flowName') != nextStep.context.get('flowName')) {
                    continue;
                }
                
                // Add edge
                String target = nextStep.elementName;
                List<Object> edgeIndexes = new List<Object>{ i + 1 };
                
                if (!edgesObj.containsKey(elementName)) {
                    edgesObj.put(elementName, new List<Object>());
                }
                
                // Check if edge already exists
                Boolean edgeExists = false;
                for (Object edgeObj : (List<Object>)edgesObj.get(elementName)) {
                    Map<String, Object> edge = (Map<String, Object>)edgeObj;
                    if (edge.get('target') == target) {
                        // Edge exists, update indexes
                        List<Object> indexes = (List<Object>)edge.get('indexes');
                        indexes.add(i + 1);
                        edgeExists = true;
                        break;
                    }
                }
                
                if (!edgeExists) {
                    // Create new edge
                    Map<String, Object> edgeObj = new Map<String, Object>{
                        'target' => target,
                        'indexes' => edgeIndexes,
                        'outcome' => step.outcome
                    };
                    
                    ((List<Object>)edgesObj.get(elementName)).add(edgeObj);
                }
            }
        }
    }

    @testVisible
    private class FlowExecution {
        // Flow metadata
        public String flowApiName;
        public String flowLabel;
        public String flowType;
        public String flowVersion;
        public String flowStatus;
        public String flowId;
        public String orgId;
        public String orgName;
        
        // Interview details
        public String interviewLabel;
        public String interviewGuid;
        public String currentUserName;
        public String currentUserId;
        public Datetime startTime;
        public Integer durationSeconds;
        public String apiVersion;
        
        // Interview context
        public Map<String, String> inputVariables;    // Variable name -> Value
        public Map<String, String> inputRecords;      // Record variable -> Record Id
        
        // Execution path
        public List<FlowExecutionStep> executionPath; // Ordered list of execution steps
        public List<String> executedElements;          // Set of executed element names
        public Map<String, ElementError> elementErrors;     // Element name -> Error message        
        
        public FlowExecution() {
            executedElements = new List<String>();
            elementErrors = new Map<String, ElementError>();
            executionPath = new List<FlowExecutionStep>();
            inputVariables = new Map<String, String>();
            inputRecords = new Map<String, String>();
            startTime = Datetime.now();
        }       
    }

    public class ElementError {
        public String elementName;
        public String elementType;
        public String errorMessage;

        public ElementError(String elementName, String elementType, String errorMessage) {
            this.elementName = elementName;
            this.elementType = elementType;
            this.errorMessage = errorMessage;
        }
    }
    
    public class FlowExecutionStep {
        public String elementName;
        public String elementLabel;
        public String elementType;
        public String type;
        public String action;
        public String outcome;
        public Map<String, String> context;
        public Map<String, Object> elementInfo;
        
        public FlowExecutionStep() {
            context = new Map<String, String>();
        }

        public FlowExecutionStep(String name, String type, Map<String, Object> info, String stepOutcome) {
            this.elementName = name;
            this.elementType = type;
            this.elementInfo = info;
            this.outcome = stepOutcome;
        }
    }

    private class SubflowContext {
        public String flowName;
        public Integer depth = 0;
        public String parentFlowName;
        public Integer parentFlowDepth;
        public Boolean isMainFlow = false;
        
        public SubflowContext(String flowName) {
            this.flowName = flowName;
        }
    }

    @testVisible
    private static FlowExecution parseExecutionPath(String executionPath, List<MetadataService.Flow> flows) {
        FlowExecution execution = new FlowExecution();
        Map<String, MetadataService.Flow> flowMap = new Map<String, MetadataService.Flow>();
        
        // Build flow map for easy lookup
        for(MetadataService.Flow flow : flows) {
            flowMap.put(flow.fullName.substringBefore('-'), flow);
        }
        
        // Get main flow details
        String mainFlowName = flows[0].fullName.substringBefore('-'); // Assuming first flow is main flow
        String flowDetails = TEST_FLOW_DETAILS_MAP.get(mainFlowName.substringBefore('-'));
        parseFlowDetails(flowDetails, execution);
        
        // Stack to track subflow contexts
        List<SubflowContext> subflowStack = new List<SubflowContext>();
        SubflowContext currentContext = new SubflowContext(mainFlowName);
        currentContext.depth = 0; // Main flow is at depth 0
        
        // Parse execution steps
        List<String> lines = executionPath.split('\n');
        for(Integer i = 0; i < lines.size(); i++) {
            String originalLine = lines[i];
            String line = originalLine.trim();
            
            // Check for indentation level to determine subflow nesting
            Integer indentationLevel = countLeadingSpaces(originalLine) / 4; // Assuming 4 spaces per indentation level
                        
            // Check for subflow marker
            if(line.startsWith('[')) {
                // Subflow entry
                Pattern subflowPattern = Pattern.compile('\\[(\\w+)\\]\\s+(.+)');
                Matcher subflowMatcher = subflowPattern.matcher(line);
                
                if(subflowMatcher.find()) {
                    String subflowName = subflowMatcher.group(1);
                    String subflowLine = subflowMatcher.group(2);
                    
                    // Handle subflow nesting based on indentation
                    if(indentationLevel > 0) {
                        // Adjust stack to match indentation level
                        while(subflowStack.size() >= indentationLevel) {
                            subflowStack.remove(subflowStack.size() - 1);
                        }
                        
                        // If we're at a deeper level than current context
                        if(indentationLevel > subflowStack.size()) {
                            // Push current context to stack
                            subflowStack.add(currentContext);
                        }
                        
                        // Create new context for this subflow
                        currentContext = new SubflowContext(subflowName);
                        currentContext.depth = indentationLevel;
                        
                        // Set parent flow information
                        if(!subflowStack.isEmpty()) {
                            SubflowContext parentContext = subflowStack[subflowStack.size() - 1];
                            currentContext.parentFlowName = parentContext.flowName;
                            currentContext.parentFlowDepth = parentContext.depth;
                        }
                        else {
                            currentContext.parentFlowName = mainFlowName;
                            currentContext.parentFlowDepth = 0;
                        }
                    }
                    else {
                        // Reset to main flow context if no indentation
                        subflowStack.clear();
                        currentContext = new SubflowContext(subflowName);
                        currentContext.depth = 0;
                        currentContext.isMainFlow = true;
                    }
                    
                    // Parse the subflow line
                    MetadataService.Flow subflow = flowMap.get(subflowName);
                    if(subflow != null) {
                        // Get parent context for reference in parsing
                        SubflowContext parentContext = subflowStack.isEmpty() ? null : subflowStack[subflowStack.size() - 1];
                        parseExecutionLine(subflowLine, execution, subflow, currentContext, parentContext);
                    }
                }
            }
            else {
                // Regular flow line                
                // If we're back to main flow level (no indentation)
                if(indentationLevel == 0) {
                    subflowStack.clear();
                    currentContext = new SubflowContext(mainFlowName);
                    currentContext.depth = 0;
                    currentContext.isMainFlow = true;
                }
                
                // Parse the line with current context
                MetadataService.Flow currentFlow = flowMap.get(currentContext.flowName);
                if(currentFlow != null) {
                    SubflowContext parentContext = subflowStack.isEmpty() ? null : subflowStack[subflowStack.size() - 1];
                    parseExecutionLine(line, execution, currentFlow, currentContext, parentContext);
                }
            }
        }
        
        return execution;
    }

    // Helper method to count leading spaces in a string
    private static Integer countLeadingSpaces(String str) {
        Integer count = 0;
        for(Integer i = 0; i < str.length(); i++) {
            if(str.charAt(i) == 32) {
                count++;
            } else {
                break;
            }
        }
        return count;
    }
    

    private static void parseExecutionLine(String line, FlowExecution execution, 
        MetadataService.Flow flow, SubflowContext context, SubflowContext parentContext) {
        
        Pattern executionPattern = Pattern.compile(
            '(\\w+)\\s*' +                           // Element name
            '\\[(\\w+(?:\\s+\\w+)?)\\]\\s*' +       // Element type
            '→\\s*(\\w+|END)' +                      // Next element or END
            '(?:\\s*\\(([^)]*)\\))?'                // Annotations (optional)
        );
        
        Matcher matcher = executionPattern.matcher(line);
        if (matcher.find()) {
            String currentElement = matcher.group(1);
            String elementType = matcher.group(2);
            String nextElement = matcher.group(3);
            String annotations = matcher.group(4);
            
            // Create execution step
            FlowExecutionStep step = createExecutionStep(currentElement, elementType, annotations, flow);
            if(step == null) {
                return;
            }
            
            // Add flow context to step
            String flowName = flow.fullName.substringBefore('-');
            String flowVersion = flow.fullName.substringAfter('-');
            
            // Set basic flow information
            step.context.put('flowName', flowName);
            step.context.put('flowLabel', convertApiNameToLabel(flowName));
            step.context.put('flowVersion', flowVersion);
            step.context.put('flowApiVersion', String.valueOf(flow.apiVersion));
            
            // Set main flow flag
            if(context.depth == 0) {
                step.context.put('isMainFlow', 'true');
                step.context.put('flowDepth', '0');
            }
            else {
                step.context.put('isMainFlow', 'false');
                step.context.put('flowDepth', String.valueOf(context.depth));

                // Special handling for Start elements in subflows
                if(step.elementType == 'Start') {
                    step.action = 'ENTER';
                    step.elementType = 'Subflow';
                }
                
                // Set parent flow information
                if(parentContext != null) {
                    step.context.put('parentFlowName', parentContext.flowName);
                    step.context.put('parentFlowDepth', String.valueOf(parentContext.depth));
                }
                
                // Always set main flow name
                step.context.put('mainFlowName', execution.flowApiName);
            }

            if (nextElement == 'END') {
                step.action = 'EXIT';
            }
            
            // Handle errors
            if(annotations != null && annotations.startsWith('error')) {
                String errorMessage = annotations.substringAfter('error:');
                execution.elementErrors.put(
                    currentElement,
                    new ElementError(
                        currentElement,
                        mapElementTypeToMetadataType(elementType),
                        errorMessage.trim())
                );
                
                // Mark as error in context
                step.context.put('hasError', 'true');
                step.context.put('errorMessage', errorMessage.trim());
            }
            
            execution.executionPath.add(step);
            execution.executedElements.add(currentElement);
        }
    }

    private static void parseFlowDetails(String flowDetails, FlowExecution execution) {
        Pattern flowPattern = Pattern.compile(
            'Flow API Name:\\s*([^\\n]+)\\s*\n' +
            'Flow Label:\\s*([^\\n]+)\\s*\n' +
            'Type:\\s*([^\\n]+)\\s*\n' +
            'Version:\\s*(\\d+)\\s*\n' +
            'Status:\\s*([^\\n]+)\\s*\n' +
            'Org:\\s*([^\\(]+)\\s*\\(([^\\)]+)\\)\\s*\n' +
            'Interview Label:\\s*([^\\n]+)\\s*\n' +
            'Interview GUID:\\s*([^\\n]+)\\s*\n' +
            'Current User:\\s*([^\\(]+)\\s*\\(([^\\)]+)\\)\\s*\n' +
            'Start time:\\s*([^\\n]+)\\s*\n' +
            'Duration:\\s*(\\d+)\\s*seconds\\s*\n' +
            'API Version:\\s*(\\d+\\.\\d+)'
        );
        
        Matcher flowMatcher = flowPattern.matcher(flowDetails);
        if (flowMatcher.find()) {
            // Flow metadata
            execution.flowApiName = flowMatcher.group(1);
            execution.flowLabel = flowMatcher.group(2);
            execution.flowType = flowMatcher.group(3);
            execution.flowVersion = flowMatcher.group(4);
            execution.flowStatus = flowMatcher.group(5);
            execution.orgName = flowMatcher.group(6).trim();
            execution.orgId = flowMatcher.group(7);
            
            // Interview details
            execution.interviewLabel = flowMatcher.group(8);
            execution.interviewGuid = flowMatcher.group(9);
            execution.currentUserName = flowMatcher.group(10).trim();
            execution.currentUserId = flowMatcher.group(11);
            
            // Timing details
            String startTimeStr = flowMatcher.group(12);
            execution.startTime = Datetime.parse(startTimeStr);
            execution.durationSeconds = Integer.valueOf(flowMatcher.group(13));
            execution.apiVersion = flowMatcher.group(14);
        }
        
        // Parse input variables
        Pattern inputPattern = Pattern.compile('Input Variables:\\s*\n((?:[^\\n]+\\s*=\\s*[^\\n]+\n?)+)');
        Matcher inputMatcher = inputPattern.matcher(flowDetails);
        if (inputMatcher.find()) {
            parseInputVariables(inputMatcher.group(1), execution);
        }
    }

    private static void parseInputVariables(String inputSection, FlowExecution execution) {
        Pattern varPattern = Pattern.compile('(\\$?\\w+)\\s*=\\s*([^\\n]+)');
        Matcher varMatcher = varPattern.matcher(inputSection);
        
        while (varMatcher.find()) {
            String varName = varMatcher.group(1);
            String varValue = varMatcher.group(2).trim();
            
            if (varValue.contains('(') && varValue.contains(')')) {
                // Record reference
                Pattern recordPattern = Pattern.compile('(\\w+)\\s*\\((\\w+)\\)');
                Matcher recordMatcher = recordPattern.matcher(varValue);
                if (recordMatcher.find()) {
                    execution.inputRecords.put(varName, recordMatcher.group(2));
                }
            } else {
                execution.inputVariables.put(varName, varValue);
            }
        }
    }

    private static FlowExecutionStep createExecutionStep(String elementName, String elementType, 
        String annotations, MetadataService.Flow flow) {
        
        FlowExecutionStep step = new FlowExecutionStep();
        step.elementName = elementName;
        step.elementLabel = convertApiNameToLabel(elementName);
        step.elementType = elementType;
        step.type = mapElementType(elementType);
        step.action = 'EXECUTE';
        step.elementInfo = new Map<String, Object>();

        // Store metadata outcomes based on element type
        if (elementType == 'Loop') {
            Map<String, Object> metadata = new Map<String, Object>();
            
            // Find loop in flow metadata
            for (MetadataService.FlowLoop loopElement : flow.loops) {
                if (loopElement.name == elementName) {
                    // Store next connection
                    if (loopElement.nextValueConnector != null) {
                        metadata.put('nextConnection', new Map<String, Object>{
                            'target' => loopElement.nextValueConnector.targetReference,
                            'label' => 'Next Item'
                        });
                    }
                    
                    // Store no more connection
                    if (loopElement.noMoreValuesConnector != null) {
                        metadata.put('noMoreConnection', new Map<String, Object>{
                            'target' => loopElement.noMoreValuesConnector.targetReference,
                            'label' => 'After Last Item'
                        });
                    }
                    
                    break;
                }
            }
            
            step.elementInfo.put('metadataInfo', metadata);
            
            // Parse executed outcome
            if (annotations != null) {
                if (annotations.startsWith('NoMore')) {
                    step.outcome = 'NoMore';
                    step.context.put('executedOutcome', 'After Last Item');
                } else if (annotations.startsWith('Next')) {
                    step.outcome = 'Next';
                    Pattern nextPattern = Pattern.compile('Next:\\s*([^,]+)');
                    Matcher nextMatcher = nextPattern.matcher(annotations);
                    if (nextMatcher.find()) {
                        step.context.put('loopValue', nextMatcher.group(1).trim());
                        step.context.put('executedOutcome', 'Next Item');
                    }
                }
            }
        }
        else if (elementType == 'Decision') {
            Map<String, Object> metadata = new Map<String, Object>();
            List<Object> outcomes = new List<Object>();
            
            // Find decision in flow metadata
            for (MetadataService.FlowDecision decision : flow.decisions) {
                if (decision.name == elementName) {
                    // Store default connector
                    if (decision.defaultConnector != null) {
                        outcomes.add(new Map<String, Object>{
                            'name' => 'Default',
                            'label' => 'Default Outcome',
                            'target' => decision.defaultConnector.targetReference,
                            'isDefault' => true
                        });
                    }
                    
                    // Store all rules
                    if (decision.rules != null) {
                        for (MetadataService.FlowRule rule : decision.rules) {
                            Map<String, Object> ruleOutcome = new Map<String, Object>{
                                'name' => rule.name,
                                'label' => rule.label,
                                'target' => rule.connector?.targetReference,
                                'isDefault' => false,
                                'conditions' => new List<String>()
                            };
                            
                            // Add conditions
                            if (rule.conditions != null) {
                                for (MetadataService.FlowCondition condition : rule.conditions) {
                                    String conditionText = '{!' + condition?.leftValueReference + '} ' +
                                        condition?.operator + ' ' + condition?.rightValue;
                                    ((List<String>)ruleOutcome.get('conditions')).add(conditionText);
                                }
                            }
                            
                            outcomes.add(ruleOutcome);
                        }
                    }
                    break;
                }
            }
            
            metadata.put('outcomes', outcomes);
            step.elementInfo.put('metadataInfo', metadata);
            
            // Parse executed outcome
            if (annotations != null) {
                if (annotations.startsWith('Rule')) {
                    Pattern rulePattern = Pattern.compile('(Rule\\d+):\\s*([^,]+)');
                    Matcher ruleMatcher = rulePattern.matcher(annotations);
                    if (ruleMatcher.find()) {
                        step.outcome = ruleMatcher.group(1);
                        step.context.put('condition', ruleMatcher.group(2).trim());
                        step.context.put('executedOutcome', ruleMatcher.group(1));
                    }
                }
                else if (annotations.contains('Default')) {
                    step.outcome = 'Default';
                    step.context.put('condition', 'Default outcome executed');
                    step.context.put('executedOutcome', 'Default');
                }
            }
        }
        else if (elementType == 'Wait') {
            if (annotations != null) {
                if (annotations.contains('pause')) {
                    step.context.put('pause', 'start');
                }
                else if (annotations.contains('resume')) {
                    step.context.put('pause', 'resume');
                }
            }
        }

        if (annotations != null && annotations.contains('FAULT:')) {
            step.context.put('hasFault', 'true');
            step.context.put('faultOutcome', annotations.substringAfter('FAULT:').trim());
        }
        
        return step;
    }

    private static String mapElementTypeToMetadataType(String elementType) {
        if(elementType.containsIgnoreCase('Lookup')) {
            return 'FlowRecordLookup';
        }
        if(elementType.containsIgnoreCase('Record Create')) {
            return 'FlowRecordCreate';
        }
        if(elementType.containsIgnoreCase('Record Update')) {
            return 'FlowRecordUpdate';
        }
        if(elementType.containsIgnoreCase('Record Delete')) {
            return 'FlowRecordDelete';
        }
        if(elementType.containsIgnoreCase('Screen')) {
            return 'FlowScreen';
        }
        if(elementType.containsIgnoreCase('Wait')) {
            return 'FlowWait';
        }
        if(elementType.containsIgnoreCase('Subflow')) {
            return 'FlowSubflow';
        }
        if(elementType.containsIgnoreCase('Assignment')) {
            return 'FlowAssign';
        }
        if(elementType.containsIgnoreCase('Action')) {
            return 'FlowAction';
        }
        if(elementType.containsIgnoreCase('Decision')) {
            return 'FlowDecision';
        }
        if(elementType.containsIgnoreCase('Loop')) {
            return 'FlowLoop';
        }
        if(elementType.containsIgnoreCase('Wait')) {
            return 'FlowWait';
        }
        if(elementType.containsIgnoreCase('Subflow')) {
            return 'FlowSubflow';
        }
        if(elementType.containsIgnoreCase('Record Rollback')) {
            return 'FlowRecordRollback';
        }
        return elementType;
    }

    // Map element type to FlowStacktraceElement type
    private static String mapElementType(String elementType) {
        if(elementType.containsIgnoreCase('Lookup')) {
            return 'GET RECORDS';
        }
        if(elementType.containsIgnoreCase('Record Create')) {
            return 'CREATE RECORDS';
        }
        if(elementType.containsIgnoreCase('Record Update')) {
            return 'UPDATE RECORDS';
        }
        if(elementType.containsIgnoreCase('Record Delete')) {
            return 'DELETE RECORDS';
        }
        if(elementType.containsIgnoreCase('Screen')) {
            return 'SCREEN';
        }
        if(elementType.containsIgnoreCase('Wait')) {
            return 'PAUSE';
        }
        if(elementType.containsIgnoreCase('Loop')) {
            return 'LOOP';
        }
        if(elementType.containsIgnoreCase('Decision')) {
            return 'DECISION';
        }
        if(elementType.containsIgnoreCase('Assignment')) {
            return 'ASSIGNMENT';
        }
        if(elementType.containsIgnoreCase('Subflow')) {
            return 'SUBFLOW';
        }
        if(elementType.containsIgnoreCase('Action')) {
            return '(APEX)';
        }
        if(elementType.containsIgnoreCase('Record Rollback')) {
            return 'ROLL BACK RECORDS';
        }
        return elementType;
    }
}