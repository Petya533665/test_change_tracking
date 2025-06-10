@IsTest
private class LogServiceBatchTest {

    @TestSetup
    private static void testSetup() {
        Logger_Settings__c settings = Logger_Settings__c.getOrgDefaults();
        settings.Service_Scheduler_Enabled__c = true;
        insert settings;

        TestDataFactory.createConnectedOrgSettings();
        TestDataFactory.createConnectedOrg();
    }

    @IsTest
    public static void test_metrics_batch_feature_parameter2() {
        Integer metrics2 = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_6_NAME);
        Test.startTest();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(getPlatformEventConfigMockURL(), getPlatformEventConfigMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        List<MetadataService.CaseSettings> records = new List<MetadataService.CaseSettings>();
        MetadataService.CaseSettings settings = new MetadataService.CaseSettings();
        settings.emailToCase = new MetadataService.EmailToCaseSettings();
        settings.emailToCase.enableEmailToCase = false;
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl(records));

        MetricsBatch.calculateOrgMetrics2();
        Test.stopTest();
        Integer metrics2After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_6_NAME);
        System.assertNotEquals(metrics2, metrics2After);
    }

    @IsTest
    public static void test_metrics_batch_feature_parameter1() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            TestDataFactory.createTestNotificationLog();
        }
        Integer metrics1 = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_5_NAME);

        Test.startTest();
        MetricsBatch.calculateOrgMetrics();
        Test.stopTest();
        Integer metrics1After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_5_NAME);
        System.assertNotEquals(metrics1, metrics1After);
    }

    @IsTest
    public static void test_metrics_batch_feature_parameter3() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            TestDataFactory.createTestNotificationLog();
        }

        Integer metrics3 = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_7_NAME);

        Test.startTest();
        MetricsBatch.calculateOrgMetrics3();
        Test.stopTest();
        Integer metrics3After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_7_NAME);
        System.assertNotEquals(metrics3, metrics3After);
    }

    @IsTest
    public static void test_metrics_batch_feature_parameter4() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            TestDataFactory.createTestNotificationLog();
        }
        Integer metrics4 = null;

        Test.startTest();
        MetricsBatch.calculateOrgMetrics4();
        Test.stopTest();
        Integer metrics4After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_8_NAME);
        System.assertNotEquals(metrics4, metrics4After);
    }

    @IsTest
    public static void test_scheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addSeconds(30);
        String cronExp = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('testLogServiceScheduler', cronExp, new LogServiceScheduler());
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, cronTrigger.CronExpression);
        System.assertEquals(0, cronTrigger.TimesTriggered);
        System.assertEquals(dt, cronTrigger.NextFireTime);
        Test.stopTest();
    }

    @IsTest
    private static void test_batch_error_handler() {
        Log__c log = new Log__c();
        log.Hash_1__c = 'hash1';
        log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED;
        insert log;

        Test.startTest();
        LogPostProcessingBatch.getInstance().startBatch();
        Test.stopTest();

        log = [SELECT Post_Processing_Status__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_FAILED, log.Post_Processing_Status__c);
    }

    @IsTest
    private static void test_batch_error_handler_flow_type() {
        Log__c log = new Log__c();
        log.Hash_1__c = 'hash1';
        log.Category__c = FlowExceptionParser.FLOW_CATEGORY;
        log.Area__c = FlowExceptionParser.FLOW_CATEGORY;
        log.Stacktrace__c = 'abrakadabra';
        log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED;
        insert log;

        Test.startTest();
        LogPostProcessingBatch.getInstance().startBatch();
        Test.stopTest();

        log = [SELECT Post_Processing_Status__c, Stacktrace_Parse_Result__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_FAILED, log.Post_Processing_Status__c);
        System.assertEquals(JSON.serialize(null), log.Stacktrace_Parse_Result__c);
    }

    @IsTest
    private static void test_post_processing_batch_process_builder() {
        test_post_processing_batch(FlowExceptionParser.PROCESS_BUILDER_CATEGORY);
    }

    @IsTest
    private static void test_post_processing_batch_flow() {
        test_post_processing_batch(FlowExceptionParser.FLOW_CATEGORY);
    }

    @IsTest
    private static void test_post_processing_batch_integration() {
        test_post_processing_batch(LogPostProcessingService.CATEGORY_INTEGRATION);
    }

    @IsTest
    private static void test_post_processing_batch_bulk() {
        test_post_processing_batch(BulkAPIJobBatchService.BULK_API);
    }

    @IsTest
    private static void test_post_processing_batch_other() {
        test_post_processing_batch('Other');
    }

    private static void test_post_processing_batch(String category) {
        Test.startTest();
        Log__c log = new Log__c();
        log.Hash_1__c = 'hash1';
        log.Category__c = category;
        log.Type__c = 'Custom';
        log.Organization_Id__c = UserInfo.getOrganizationId().left(15);
        log.Post_Processing_Status__c = LogPostProcessingService.POST_PROCESSING_STATUS_NEEDED;
        insert log;


        LogPostProcessingBatch.getInstance().startBatch();
        Test.stopTest();

        log = [SELECT Post_Processing_Status__c FROM Log__c WHERE Id = :log.Id LIMIT 1];
        System.assertEquals(LogPostProcessingService.POST_PROCESSING_STATUS_FAILED, log.Post_Processing_Status__c);
    }

    @IsTest
    public static void test_batch_positive() {
        test_batch(true);
    }

    @IsTest
    public static void test_batch_negative() {
        test_batch(false);
    }

    private static void test_batch(Boolean isPositive) {
        Test.startTest();
        updateConnectedOrg();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://test_Identity_Url', isPositive ? getIdentityMock() : invalidGrantMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LogServiceBatch.getInstance().startBatch();
        Test.stopTest();
        List<Connected_Org__c> lstConnectedOrgs = [SELECT Id, Access_Token__c FROM Connected_Org__c LIMIT 1];
        if (!lstConnectedOrgs.isEmpty()) {
            System.assertEquals('test_Access_Token', lstConnectedOrgs[0].Access_Token__c);
        }
    }

    @IsTest
    public static void test_batch_refresh_token_positive() {
        test_batch_refresh_token(true);
    }

    @IsTest
    public static void test_batch_refresh_token_negative() {
        test_batch_refresh_token(false);
    }

    private static void test_batch_refresh_token(Boolean isPositive) {
        Test.startTest();
        updateConnectedOrg();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://test_Identity_Url', badOAuthTokenMock());
        endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT, isPositive ? refreshTokenMock() : invalidGrantMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        LogServiceBatch.getInstance().startBatch();
        Test.stopTest();
        List<Connected_Org__c> lstConnectedOrgs = [SELECT Id, Access_Token__c FROM Connected_Org__c LIMIT 1];
        if (!lstConnectedOrgs.isEmpty()) {
            if (isPositive) {
                System.assertEquals('test_new_Access_Token', lstConnectedOrgs[0].Access_Token__c);
            } else {
                System.assertEquals('test_Access_Token', lstConnectedOrgs[0].Access_Token__c);
            }
        }
    }

    private static void updateConnectedOrg() {
        List<Connected_Org__c> lstConnectedOrgs = [SELECT Id, Scheduler_Enabled__c FROM Connected_Org__c LIMIT 1];
        if (!lstConnectedOrgs.isEmpty()) {
            lstConnectedOrgs[0].Scheduler_Enabled__c = true;
            update lstConnectedOrgs;
        }
    }

    private static TestDataFactory.SingleRequestMock getIdentityMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{}'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock refreshTokenMock() {
        ConnectedOrgService.AuthTokenResponse authTokenResponse = new ConnectedOrgService.AuthTokenResponse();
        authTokenResponse.access_token = 'test_new_Access_Token';
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(authTokenResponse)
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock badOAuthTokenMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                403,
                'Forbidden',
                'Bad_OAuth_Token'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock invalidGrantMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                400,
                'Bad Request',
                'invalid_grant'
        );
        return singleRequestMock;
    }

    private static String getPlatformEventConfigMockURL() {
        PlatformEventSubscriberConfigService configService = new PlatformEventSubscriberConfigService(Log_Event__e.SObjectType);
        String triggerId = configService.getTriggerId();
        String query = new QBuilder('PlatformEventSubscriberConfig')
            .selectFields(new Set<String>{'Id','UserId', 'PlatformEventConsumerId', 'DeveloperName', 'MasterLabel','BatchSize'})
            .add(QBuilder.condition('DeveloperName').equalsTo(configService.PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME))
            .add(QBuilder.condition('PlatformEventConsumerId').equalsTo(triggerId))
            .addLimit(1)
            .build();
        return System.Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(query, 'UTF-8');
    }

    private static TestDataFactory.SingleRequestMock getPlatformEventConfigMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{'Id'=>'platformEventId'}
                }
            })
        );
        return singleRequestMock;
    }

    public class YourWebServiceMockImpl implements WebServiceMock {
        private MetadataService.CaseSettings[] records;

        public YourWebServiceMockImpl(MetadataService.CaseSettings[] records) {
            this.records = records;
        }
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            MetadataService.readCaseSettingsResponse_element metadataResponse = new MetadataService.readCaseSettingsResponse_element();
            MetadataService.ReadCaseSettingsResult result = new MetadataService.ReadCaseSettingsResult();
            result.records = this.records;
            metadataResponse.result = result;

            response.put('response_x', metadataResponse);
        }
    }

    @IsTest
    private static void test_reduce_cache_item_Deploy_Result_local(){
        TestDataFactory.createConnectedOrg();
        test_reduce_cache_item_Deploy_Result(UserInfo.getOrganizationId().left(15));
    }
    @IsTest
    private static void test_reduce_cache_item_Deploy_Result_external(){
        TestDataFactory.createConnectedOrgPassthrought();
        test_reduce_cache_item_Deploy_Result(TestDataFactory.EXTERNAL_CONNECTED_ORG_ID);
    }
    private static void test_reduce_cache_item_Deploy_Result(String orgId) {

        Log__c testLog = new Log__c();
        testLog.Hash_1__c = 'somehash1';
        testLog.Post_Processing_Settings__c = null;
        testLog.Organization_Id__c = orgId;
        insert testLog;
        testLog = [SELECT Id, Post_Processing_Settings__c,Organization_Id__c,Hash_1__c FROM Log__c WHERE Id =:testLog.Id LIMIT 1];

        Map<String, HttpCalloutMock> endpoint2TestResp = getPostprocessingServiceDeployResultMock();
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;
        // enable cache for deployment jobs
        PermissionsUtil.RequestDeploymentJobsTTL = 5*60;

        LogPostProcessingService.corg = ConnectedOrgService.getConnectedOrgById(testLog.Organization_ID__c);
        LogPostProcessingService.fillDeployResult(testLog, null);
        Test.stopTest();

        List<LogPostProcessingService.DeployResult> logDeployResults = (List<LogPostProcessingService.DeployResult>) JSON.deserialize(testLog.Deploy_Results__c, List<LogPostProcessingService.DeployResult>.class);
        System.assertNotEquals(test_deploy_result_count, logDeployResults.size());
        System.assertEquals(true, logDeployResults.size() < test_deploy_result_count);

        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(testLog.Organization_ID__c);
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        List<LogPostProcessingService.DeployResult> cacheDeployResults = (List<LogPostProcessingService.DeployResult>)cacheUtil.getValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS);
        System.assertNotEquals(test_deploy_result_count, cacheDeployResults.size());
        System.assertEquals(true, cacheDeployResults.size() < test_deploy_result_count);
    }

    private static final Integer test_deploy_result_count = 100;
    private static Map<String, HttpCalloutMock> getPostprocessingServiceDeployResultMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        List<LogPostProcessingService.DeployResult> deployResults = new List<LogPostProcessingService.DeployResult>();
        for(Integer i = 0; i < test_deploy_result_count; i++) {
            LogPostProcessingService.DeployResult deployResult = new LogPostProcessingService.DeployResult();
            deployResult.id = String.valueOf(UserInfo.getUserId() + i);
            deployResult.status = 'completed';
            deployResult.completedDate = DateTime.now();
            deployResults.add(deployResult);
        }

        String query = new QBuilder('deployRequest')
            .selectFields(LogPostProcessingService.DEPLOY_RESULT_FIELDS)
            .add(QBuilder.condition('Status').isIn(new List<String>{'Succeeded', 'SucceededPartial'}))
            .addLimit(10)
            .add(new QOrder('CompletedDate').descending())
            .build();

        endpoint2TestResp.put(TestDataFactory.CONNECTED_ORG_INSTANCE_URL + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.TOOLING_ITEMS_KEY_RECORDS => deployResults
            })
        ));
        return endpoint2TestResp;
    }

    @IsTest
    private static void test_put_cache_item_describe_sobject() {
        Map<String, LogPostProcessingService.SObjectDescribeInfo> mapSObjectDescribeInfo = new Map<String, LogPostProcessingService.SObjectDescribeInfo> {
            '005' => new LogPostProcessingService.SObjectDescribeInfo('User', 'Users'),
            '001' => new LogPostProcessingService.SObjectDescribeInfo('Account', 'Accounts'),
            '003' => new LogPostProcessingService.SObjectDescribeInfo('Contact', 'Contacts'),
            '006' => new LogPostProcessingService.SObjectDescribeInfo('Opportunity', 'Opportunities'),
            '00D' => new LogPostProcessingService.SObjectDescribeInfo('Organization', 'Organizations'),
            '00e' => new LogPostProcessingService.SObjectDescribeInfo('Profile', 'Profiles'),
            '0KD' => new LogPostProcessingService.SObjectDescribeInfo('TabDefinition', 'TabDefinitions'),
            '012' => new LogPostProcessingService.SObjectDescribeInfo('RecordType', 'RecordTypes')
        };
        // enable cache for describe sobjects
        PermissionsUtil.RequestSobjectDescribeTTL = 5*60;

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_SOBJECT_DESCRIBE, mapSObjectDescribeInfo);
        Integer mapSObjectDescribeSizeBefore = mapSObjectDescribeInfo.size();

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Integer itemsToRemove = CacheUtils.getCountToRemove(mapSObjectDescribeInfo.size(), CacheUtils.ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT);
        // should be 1 item
        System.assertEquals(1, itemsToRemove);

        //add extra cache item
        mapSObjectDescribeInfo.put('00Q', new LogPostProcessingService.SObjectDescribeInfo('Lead', 'Leads'));
        Integer mapSObjectDescribeSizeAfter = mapSObjectDescribeInfo.size();
        System.assertEquals(true, mapSObjectDescribeSizeAfter > mapSObjectDescribeSizeBefore);
        System.assertEquals(1, mapSObjectDescribeSizeAfter - mapSObjectDescribeSizeBefore);

        cacheUtil.putValue(CacheUtils.KEY_REQUEST_SOBJECT_DESCRIBE, mapSObjectDescribeInfo);
        Test.stopTest();

        Map<String, LogPostProcessingService.SObjectDescribeInfo> cachedValue = (Map<String, LogPostProcessingService.SObjectDescribeInfo>)cacheUtil.getValue(CacheUtils.KEY_REQUEST_SOBJECT_DESCRIBE);

        // size should be equal
        // first item should be removed
        // new item should be added to last index
        System.assertEquals(mapSObjectDescribeSizeBefore, cachedValue.size());
        List<String> cachedValueKeys = new List<String>(cachedValue.keySet());
        System.assertEquals('001', cachedValueKeys.get(0));
        System.assertEquals('003', cachedValueKeys.get(1));
        System.assertEquals('006', cachedValueKeys.get(2));
        System.assertEquals('00D', cachedValueKeys.get(3));
        System.assertEquals('00e', cachedValueKeys.get(4));
        System.assertEquals('0KD', cachedValueKeys.get(5));
        System.assertEquals('012', cachedValueKeys.get(6));
        System.assertEquals('00Q', cachedValueKeys.get(7));
    }

    @IsTest
    private static void test_put_cache_item_user_info() {
        Map<String, String> mapUsers = new Map<String, String> {
            '005000000000001' => 'username1',
            '005000000000002' => 'username2',
            '005000000000003' => 'username3',
            '005000000000004' => 'username4',
            '005000000000005' => 'username5',
            '005000000000006' => 'username6',
            '005000000000007' => 'username7',
            '005000000000008' => 'username8'
        };
        // enable cache for describe sobjects
        PermissionsUtil.RequestUserInfoTTL = 5*60;

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_USER_INFO, mapUsers);
        Integer mapUsersSizeBefore = mapUsers.size();

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Integer itemsToRemove = CacheUtils.getCountToRemove(mapUsers.size(), CacheUtils.ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT);
        // should be 1 item
        System.assertEquals(1, itemsToRemove);

        //add extra cache item
        mapUsers.put('005000000000009', 'username9');
        Integer mapUsersSizeAfter = mapUsers.size();
        System.assertEquals(true, mapUsersSizeAfter > mapUsersSizeBefore);
        System.assertEquals(1, mapUsersSizeAfter - mapUsersSizeBefore);

        cacheUtil.putValue(CacheUtils.KEY_REQUEST_USER_INFO, mapUsers);
        Test.stopTest();

        Map<String, String> cachedValue = (Map<String, String>)cacheUtil.getValue(CacheUtils.KEY_REQUEST_USER_INFO);

        // size should be equal
        // first item should be removed
        // new item should be added to last index
        System.assertEquals(mapUsersSizeBefore, cachedValue.size());
        List<String> cachedValueKeys = new List<String>(cachedValue.keySet());
        System.assertEquals('005000000000002', cachedValueKeys.get(0));
        System.assertEquals('005000000000003', cachedValueKeys.get(1));
        System.assertEquals('005000000000004', cachedValueKeys.get(2));
        System.assertEquals('005000000000005', cachedValueKeys.get(3));
        System.assertEquals('005000000000006', cachedValueKeys.get(4));
        System.assertEquals('005000000000007', cachedValueKeys.get(5));
        System.assertEquals('005000000000008', cachedValueKeys.get(6));
        System.assertEquals('005000000000009', cachedValueKeys.get(7));
    }

    @IsTest
    private static void test_put_cache_item_counter_info_with_value_map() {
        Map<String, Integer> mapLogCounter = new Map<String, Integer> {
            '005000000000001' => 1,
            '005000000000002' => 2,
            '005000000000003' => 3,
            '005000000000004' => 4,
            '005000000000005' => 5,
            '005000000000006' => 6,
            '005000000000007' => 7,
            '005000000000008' => 8
        };

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        cacheUtil.putValue(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING, mapLogCounter);

        Integer mapLogCounterSizeBefore = mapLogCounter.size();

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Integer itemsToRemove = CacheUtils.getCountToRemove(mapLogCounter.size(), CacheUtils.ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT);
        // should be 1 item
        System.assertEquals(1, itemsToRemove);

        //add extra cache item
        mapLogCounter.put('005000000000009', 9);
        Integer mapLogCounterSizeAfter = mapLogCounter.size();
        System.assertEquals(true, mapLogCounterSizeAfter > mapLogCounterSizeBefore);
        System.assertEquals(1, mapLogCounterSizeAfter - mapLogCounterSizeBefore);

        cacheUtil.putValue(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING, mapLogCounter);
        Test.stopTest();

        Map<String, Integer> cachedValue = (Map<String, Integer>)cacheUtil.getValue(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING);

        // size should be equal
        // first item should be removed
        // new item should be added to last index
        System.assertEquals(mapLogCounterSizeBefore, cachedValue.size());
        List<String> cachedValueKeys = new List<String>(cachedValue.keySet());
        System.assertEquals('005000000000002', cachedValueKeys.get(0));
        System.assertEquals('005000000000003', cachedValueKeys.get(1));
        System.assertEquals('005000000000004', cachedValueKeys.get(2));
        System.assertEquals('005000000000005', cachedValueKeys.get(3));
        System.assertEquals('005000000000006', cachedValueKeys.get(4));
        System.assertEquals('005000000000007', cachedValueKeys.get(5));
        System.assertEquals('005000000000008', cachedValueKeys.get(6));
        System.assertEquals('005000000000009', cachedValueKeys.get(7));
    }

    @IsTest
    private static void test_put_cache_item_counter_info_without_value_map() {

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);


        cacheUtil.putValue(
                CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING,
                corg?.Name + '005000000000001' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING,
                1
        );

        cacheUtil.putValue(
                CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING,
                corg?.Name + '005000000000002' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING,
                2
        );

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Test.stopTest();

        Integer count = (Integer) CacheUtils.getCacheValue(
                corg?.Name + '005000000000001' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING
        );
        System.assertEquals(1, count, 'Should be 1');

        count = (Integer) CacheUtils.getCacheValue(corg?.Name + '005000000000002' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING);
        System.assertEquals(2, count, 'Should be 2');

        count = (Integer) cacheUtil.getValue(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING, corg?.Name + '005000000000001' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING);
        System.assertEquals(1, count, 'Should be 1');

        count = (Integer) cacheUtil.getValue(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING, corg?.Name + '005000000000002' + CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING);
        System.assertEquals(2, count, 'Should be 2');

    }

    @IsTest
    private static void test_put_cache_item_flow_describe_info() {
        Map<String, LogPostProcessingService.FlowDescribeInfo> mapFlowInfo = new Map<String, LogPostProcessingService.FlowDescribeInfo> {
            '300000000000001' => new LogPostProcessingService.FlowDescribeInfo('Version1', 'Defenition1'),
            '300000000000002' => new LogPostProcessingService.FlowDescribeInfo('Version2', 'Defenition2'),
            '300000000000003' => new LogPostProcessingService.FlowDescribeInfo('Version3', 'Defenition3'),
            '300000000000004' => new LogPostProcessingService.FlowDescribeInfo('Version4', 'Defenition4'),
            '300000000000005' => new LogPostProcessingService.FlowDescribeInfo('Version5', 'Defenition5'),
            '300000000000006' => new LogPostProcessingService.FlowDescribeInfo('Version6', 'Defenition6'),
            '300000000000007' => new LogPostProcessingService.FlowDescribeInfo('Version7', 'Defenition7'),
            '300000000000008' => new LogPostProcessingService.FlowDescribeInfo('Version8', 'Defenition8')
        };
        // enable cache for flow describe
        PermissionsUtil.RequestSobjectDescribeTTL = 5*60;

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_FLOW_DESCRIBE, mapFlowInfo);
        Integer mapFlowInfoSizeBefore = mapFlowInfo.size();

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Integer itemsToRemove = CacheUtils.getCountToRemove(mapFlowInfo.size(), CacheUtils.ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT);
        // should be 1 item
        System.assertEquals(1, itemsToRemove);

        //add extra cache item
        mapFlowInfo.put('300000000000009', new LogPostProcessingService.FlowDescribeInfo('Version9', 'Defenition9'));
        Integer mapFlowInfoSizeAfter = mapFlowInfo.size();
        System.assertEquals(true, mapFlowInfoSizeAfter > mapFlowInfoSizeBefore);
        System.assertEquals(1, mapFlowInfoSizeAfter - mapFlowInfoSizeBefore);

        cacheUtil.putValue(CacheUtils.KEY_REQUEST_FLOW_DESCRIBE, mapFlowInfo);
        Test.stopTest();

        Map<String, LogPostProcessingService.FlowDescribeInfo> cachedValue = (Map<String, LogPostProcessingService.FlowDescribeInfo>)cacheUtil.getValue(CacheUtils.KEY_REQUEST_FLOW_DESCRIBE);

        // size should be equal
        // first item should be removed
        // new item should be added to last index
        System.assertEquals(mapFlowInfoSizeBefore, cachedValue.size());
        List<String> cachedValueKeys = new List<String>(cachedValue.keySet());
        System.assertEquals('300000000000002', cachedValueKeys.get(0));
        System.assertEquals('300000000000003', cachedValueKeys.get(1));
        System.assertEquals('300000000000004', cachedValueKeys.get(2));
        System.assertEquals('300000000000005', cachedValueKeys.get(3));
        System.assertEquals('300000000000006', cachedValueKeys.get(4));
        System.assertEquals('300000000000007', cachedValueKeys.get(5));
        System.assertEquals('300000000000008', cachedValueKeys.get(6));
        System.assertEquals('300000000000009', cachedValueKeys.get(7));
    }

    @IsTest
    private static void test_put_cache_item_deploy_result_info() {
        List<LogPostProcessingService.DeployResult> listDeployResults = new List<LogPostProcessingService.DeployResult>();
        for(Integer i = 1; i<9; i++) {
            LogPostProcessingService.DeployResult dl = new LogPostProcessingService.DeployResult();
            dl.id = '10000000000000' + String.valueOf(i);
            dl.status = 'somestatus';
            listDeployResults.add(dl);
        }
        // enable cache for deploy results
        PermissionsUtil.RequestDeploymentJobsTTL = 5*60;

        TestDataFactory.createConnectedOrg();
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        CacheUtils cacheUtil = new CacheUtils(corg.Name);
        cacheUtil.putValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS, listDeployResults);
        Integer deployResultsSizeBefore = listDeployResults.size();

        Test.startTest();
        // enable emulate cache.ItemSizeLimitExceededException with 2.5% overlimit
        CacheUtils.THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = true;

        Integer itemsToRemove = CacheUtils.getCountToRemove(listDeployResults.size(), CacheUtils.ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT);
        // should be 1 item
        System.assertEquals(1, itemsToRemove);

        //add extra cache item
        LogPostProcessingService.DeployResult dl = new LogPostProcessingService.DeployResult();
        dl.id = '100000000000009';
        dl.status = 'somestatus';
        listDeployResults.add(dl);

        Integer deployResultsSizeAfter = listDeployResults.size();
        System.assertEquals(true, deployResultsSizeAfter > deployResultsSizeBefore);
        System.assertEquals(1, deployResultsSizeAfter - deployResultsSizeBefore);

        cacheUtil.putValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS, listDeployResults);
        Test.stopTest();

        List<LogPostProcessingService.DeployResult> cachedValue = (List<LogPostProcessingService.DeployResult>)cacheUtil.getValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS);

        // size should be equal
        // first item should be removed
        // new item should be added to last index
        System.assertEquals(deployResultsSizeBefore, cachedValue.size());
        System.assertEquals('100000000000002', cachedValue.get(0).id);
        System.assertEquals('100000000000003', cachedValue.get(1).id);
        System.assertEquals('100000000000004', cachedValue.get(2).id);
        System.assertEquals('100000000000005', cachedValue.get(3).id);
        System.assertEquals('100000000000006', cachedValue.get(4).id);
        System.assertEquals('100000000000007', cachedValue.get(5).id);
        System.assertEquals('100000000000008', cachedValue.get(6).id);
        System.assertEquals('100000000000009', cachedValue.get(7).id);
    }
}