@IsTest
public with sharing class TraceServiceTest {

    private static final String INSTANCE_URL = 'http://sfdc.com';
    private static final String EXTERNAL_ORG_ID = '00D200000006k0s';

    @TestSetup
    static void makeData(){
        PermissionsUtil.DebugLogServiceEnabled = true;
        setupConnectedOrg();
    }

    private static void setupConnectedOrg() {
        ConnectedOrgService.createConnectedOrg(EXTERNAL_ORG_ID, 'production', 'description', null, null, EXTERNAL_ORG_ID);
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(EXTERNAL_ORG_ID);
        corg.Instance_Url__c = 'http://sfdc.com';
        corg.Access_Token__c = 'someToken';
        corg.Token_Refreshed_At__c = DateTime.now();
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c);
    }

    @IsTest
    private static void test_start_debug_log_service_success() {
        test_start_debug_log_service(true);
    }
    @IsTest
    private static void test_start_debug_log_service_failed() {
        test_start_debug_log_service(false);
    }
    private static void test_start_debug_log_service(Boolean isSuccess) {
        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = DateTime.now().addHours(-1);
        flag.Last_Created_Log__c = DateTime.now();
        upsert flag;

        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(EXTERNAL_ORG_ID);

        Trace_Request__c traceRequest = createTraceRequest(true, true);
        traceRequest.Status__c = TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
        insert traceRequest;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getStartDebugLogServiceMock(isSuccess);
        endpoint2TestResp.putAll(getDebugLogServiceFlagMock(flag));
        endpoint2TestResp.putAll(getConnectedOrgStorageInfoMockEmptyMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        TraceService.DebugLogServiceResponse result;
        
        PermissionsUtil.DebugLogServiceEnabled = true;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        result = traceServiceInstance.startDebugLogService(corg, false, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    private static void test_start_debug_log_service_chunk_success() {
        test_start_debug_log_service_chunk(true);
    }
    @IsTest
    private static void test_start_debug_log_service_chunk_failed() {
        test_start_debug_log_service_chunk(false);
    }
    private static void test_start_debug_log_service_chunk(Boolean isSuccess) {
        Id selfOrgId = UserInfo.getOrganizationId();

        ConnectedOrgService.createConnectedOrg(selfOrgId, 'production', 'description', null, null, selfOrgId);
        Connected_Org__c corg1 = ConnectedOrgService.getConnectedOrgById(selfOrgId);
        corg1.Instance_Url__c = 'http://sfdc.com';
        corg1.Access_Token__c = 'someToken';
        corg1.Token_Refreshed_At__c = DateTime.now();
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg1}, Schema.SObjectType.Connected_Org__c);

        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = DateTime.now().addHours(-1);
        flag.Last_Created_Log__c = DateTime.now();
        upsert flag;

        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(selfOrgId);

        Trace_Request__c traceRequest = createTraceRequest(true, true);
        traceRequest.Status__c = TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
        traceRequest.Source__c = selfOrgId;
        insert traceRequest;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getStartDebugLogServiceMock(isSuccess);
        endpoint2TestResp.putAll(getDebugLogServiceFlagMock(flag));
        endpoint2TestResp.putAll(getConnectedOrgStorageInfoMockEmptyMock());
        endpoint2TestResp.putAll(getStartDebugLogServiceChunkMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        TraceService.DebugLogServiceChunkResponse result;
        
        PermissionsUtil.DebugLogServiceEnabled = true;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(selfOrgId);
        ApexLog apexLog = new ApexLog(Id = '07L6g00000FIak1EAD');
        result = traceServiceInstance.startDebugLogServiceChunk(corg, apexLog);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(isSuccess, result.success);
    }

    @IsTest
    private static void test_start_debug_log_service_scheduler() {
        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = DateTime.now().addHours(-1);
        flag.Last_Created_Log__c = DateTime.now();
        upsert flag;

        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(EXTERNAL_ORG_ID);

        Trace_Request__c traceRequest = createTraceRequest(true, true);
        traceRequest.Status__c = TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
        insert traceRequest;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getStartDebugLogServiceMock(true);
        endpoint2TestResp.putAll(getDebugLogServiceFlagMock(flag));
        endpoint2TestResp.putAll(getConnectedOrgStorageInfoMockEmptyMock());
        endpoint2TestResp.putAll(getApexLogsMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);


        System.assertEquals(true, TraceService.hasNewLogs(corg));
        Integer metricsBefore = PermissionsUtil.getPackageFeatureInteger(PermissionsUtil.FEATURE_DEBUG_LOG_SERVICE_USAGE, 0);
        ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Enabled__c = true;
        PermissionsUtil.DebugLogServiceEnabled = true;
        TraceService tsc = TraceService.getInstance();
        tsc.setConnectedOrgById(EXTERNAL_ORG_ID);
        tsc.startBatch();
        Test.stopTest();
        Integer metricsAfter = PermissionsUtil.getPackageFeatureInteger(PermissionsUtil.FEATURE_DEBUG_LOG_SERVICE_USAGE, 0);
        System.assertNotEquals(metricsBefore, metricsAfter);
    }

    private static Map<String, HttpCalloutMock> getStartDebugLogServiceMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        TraceService.DebugLogServiceResponse response = new TraceService.DebugLogServiceResponse();
        response.traceRequests = new List<TraceService.TraceRequest>();
        response.sendResults = new TraceService.SQSSendResult();
        response.sendResults.successSendRecords = 3;
        response.sendResults.debugLogRecords = 3;
        
        if(!isSuccess) {
            response.sendResults.mapErrors = new Map<String, String>();
        }
        endpoint2TestResp.put(TraceService.DEBUG_LOG_SERVICE_ENDPOINT, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getStartDebugLogServiceChunkMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        TraceService.DebugLogServiceChunkResponse response = new TraceService.DebugLogServiceChunkResponse();
        response.success = isSuccess;
        
        if(!isSuccess) {
            response.name = 'error name';
            response.message = 'error message';
            response.stack = 'error stacktrace';
        }
        endpoint2TestResp.put(TraceService.DEBUG_LOG_SERVICE_CHUNK_ENDPOINT, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(response)
        ));
        return endpoint2TestResp;
    }

    @IsTest
    public static void test_debug_log_retention_batch() {
        Map<String, HttpCalloutMock> endpoint2TestResp = getDeleteTraceFlagMock(true);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        PermissionsUtil.DebugLogServiceEnabled = true;
        TraceService.OrganizationStorageHelper helper = new TraceService.OrganizationStorageHelper();
        TraceRetentionBatch.getInstance(helper).startBatch();
        Test.stopTest();
    }

    @IsTest
    public static void test_debug_log_retention_batch_execute_success() {
        test_debug_log_retention_batch_execute(true);
    }
    @IsTest
    public static void test_debug_log_retention_batch_execute_failed() {
        test_debug_log_retention_batch_execute(false);
    }
    public static void test_debug_log_retention_batch_execute(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getDeleteCompositeMock(true, new List<String>{'07L6g00000DhvpdEAB','07L6g00000DhvpTEAR','07L6g00000DhvmAEAR'});
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        List<TraceRetentionBatch.TraceRetentionRunWrapper> scope = new List<TraceRetentionBatch.TraceRetentionRunWrapper>{
            new TraceRetentionBatch.TraceRetentionRunWrapper(TraceRetentionBatch.TraceRetentionRunType.DELETE_APEX_LOGS, EXTERNAL_ORG_ID)
        };
        TraceService.OrganizationStorageHelper helper = new TraceService.OrganizationStorageHelper();
        TraceRetentionBatch.getInstance(helper).execute(null, scope);
        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getDeleteCompositeMock(Boolean isSuccess, List<String> recordIds) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        List<Map<String, Object>> respMap;
        if(isSuccess) {
            respMap = new List<Map<String, Object>> {
                new Map<String, Object>{
                    'success' => true
                },
                new Map<String, Object>{
                    'success' => true
                },
                new Map<String, Object>{
                    'success' => true
                }
            };
        }
        else {
            respMap = new List<Map<String, Object>> {
                new Map<String, Object>{
                    'success' => true
                },
                new Map<String, Object>{
                    'success' => true
                },
                new Map<String, Object>{
                    'id' => recordIds.get(0),
                    'success' => false,
                    'errors' => new List<Map<String, Object>>{
                        new Map<String, Object>{ 
                            'message' => 'some error',
                            'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                        }
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_REST_COMPOSITE_API_DELETE_RECORDS + String.join(recordIds, ','), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    public class ProcessTraceFlagSettings {
        public Boolean debugLevelExist;
        public Boolean debugLevelDefault;
        public Boolean traceFlagExist;
        public Boolean existTraceFlagExpired;

        public ProcessTraceFlagSettings(Boolean debugLevelExist, Boolean debugLevelDefault, Boolean traceFlagExist, Boolean existTraceFlagExpired) {
            this.debugLevelExist = debugLevelExist;
            this.debugLevelDefault = debugLevelDefault;
            this.traceFlagExist = traceFlagExist;
            this.existTraceFlagExpired = existTraceFlagExpired;
        }
    }

    @IsTest
    private static void process_new_trace_flag1() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, true, false, false);
        process_new_trace_flag(settings);
    }
    @IsTest
    private static void process_new_trace_flag2() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, false, false);
        process_new_trace_flag(settings);
    }
    @IsTest
    private static void process_new_trace_flag3() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, true, false);
        process_new_trace_flag(settings);
    }
    @IsTest
    private static void process_new_trace_flag4() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, true, true);
        process_new_trace_flag(settings);
    }

    private static void process_new_trace_flag(ProcessTraceFlagSettings settings) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getProcessNewTraceFlagMock(settings);
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        Trace_Request__c traceRequest = createTraceRequest(settings.debugLevelDefault, settings.existTraceFlagExpired);
        insert traceRequest;

        Test.startTest();
        traceServiceInstance.processNewTraceFlag(traceRequest);
        Test.stopTest();

        traceRequest = [SELECT Status__c FROM Trace_Request__c WHERE Id = :traceRequest.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS, traceRequest.Status__c);
    }

    @IsTest
    private static void process_new_trace_flag_by_batch1() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, true, false, false);
        process_new_trace_flag_by_batch(settings);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch2() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, false, false);
        process_new_trace_flag_by_batch(settings);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch3() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, true, false);
        process_new_trace_flag_by_batch(settings);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch4() {
        ProcessTraceFlagSettings settings = new ProcessTraceFlagSettings(false, false, true, true);
        process_new_trace_flag_by_batch(settings);
    }

    private static void process_new_trace_flag_by_batch(ProcessTraceFlagSettings settings) {
        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = DateTime.now().addHours(-1);
        flag.Last_Created_Log__c = DateTime.now();
        upsert flag;

        Trace_Request__c traceRequest = createTraceRequest(settings.debugLevelDefault, settings.existTraceFlagExpired);
        insert traceRequest;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getProcessNewTraceFlagMock(settings);
        endpoint2TestResp.putAll(getDebugLogServiceFlagMock(flag));
        endpoint2TestResp.putAll(getConnectedOrgStorageInfoMockEmptyMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Enabled__c = true;
        PermissionsUtil.DebugLogServiceEnabled = true;

        TraceService.checkTraceServiceRun();
        Test.stopTest();

        traceRequest = [SELECT Status__c FROM Trace_Request__c WHERE Id = :traceRequest.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS, traceRequest.Status__c);
    }

    @IsTest
    private static void process_new_trace_flag_by_batch_check_start_time_past_3h() {
        process_new_trace_flag_by_batch_check_start_time(DateTime.now().addHours(-3), DateTime.now().addHours(2), TraceService.TRACE_REQUEST_STATUS_NEW);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch_check_start_time_past_50min() {
        process_new_trace_flag_by_batch_check_start_time(DateTime.now().addMinutes(-50), DateTime.now().addHours(2), TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch_check_start_time_future_10min() {
        process_new_trace_flag_by_batch_check_start_time(DateTime.now().addMinutes(10), DateTime.now().addHours(2), TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch_check_start_time_future_65m() {
        process_new_trace_flag_by_batch_check_start_time(DateTime.now().addMinutes(65), DateTime.now().addHours(2), TraceService.TRACE_REQUEST_STATUS_NEW);
    }
    @IsTest
    private static void process_new_trace_flag_by_batch_check_start_time_future_2h() {
        process_new_trace_flag_by_batch_check_start_time(DateTime.now().addHours(2), DateTime.now().addHours(4), TraceService.TRACE_REQUEST_STATUS_NEW);
    }
    private static void process_new_trace_flag_by_batch_check_start_time(DateTime startTime, DateTime endTime, String expectedStatus) {
        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = DateTime.now().addHours(-2);
        flag.Last_Created_Log__c = DateTime.now();
        upsert flag;

        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c traceRequest1 = createTraceRequest(true, false, schedule1.Id);
        traceRequest1.Start_Date__c = startTime;
        traceRequest1.End_Date__c = endTime;
        traceRequest1.Issue__c = issue1.Id;
        insert traceRequest1;

        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getProcessNewTraceFlagMock(new ProcessTraceFlagSettings(false, true, false, false));
        endpoint2TestResp.putAll(getDebugLogServiceFlagMock(flag));
        endpoint2TestResp.putAll(getConnectedOrgStorageInfoMockEmptyMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Enabled__c = true;
        PermissionsUtil.DebugLogServiceEnabled = true;

        TraceService.checkTraceServiceRun();
        
        Test.stopTest();

        traceRequest1 = [SELECT Status__c FROM Trace_Request__c WHERE Id = :traceRequest1.Id LIMIT 1];
        System.assertEquals(expectedStatus, traceRequest1.Status__c);
    }

    private static Map<String, HttpCalloutMock> getConnectedOrgStorageInfoMockEmptyMock() {
        return getConnectedOrgStorageInfoMock(0, 0, 0);
    }

    private static Map<String, HttpCalloutMock> getConnectedOrgStorageInfoMockFullMock() {
        return getConnectedOrgStorageInfoMock(1200000, 100, 100);
    }

    private static Map<String, HttpCalloutMock> getConnectedOrgStorageInfoMock(Integer totalSumm, Integer totalCount, Integer avgSize) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'SUM(LogLength) totalSumm', 'COUNT(Id) totalCount', 'AVG(LogLength) avgSize'})
            .build();
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'totalSumm' => totalSumm,
                        'totalCount' => totalCount,
                        'avgSize' => avgSize
                    }
                }
            })
        ));
        
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getApexLogsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'Id','StartTime'})
            .add(QBuilder.orderBy('StartTime').descending())
            .addLimit(1)
            .build();
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'Id' => '07L6g00000DhvpdEAB',
                        'StartTime' => DateTime.now()
                    },
                    new Map<String, Object>{
                        'Id' => '07L6g00000DhvpTEAR',
                        'StartTime' => DateTime.now()
                    },
                    new Map<String, Object>{
                        'Id' => '07L6g00000DhvmAEAR',
                        'StartTime' => DateTime.now()
                    }
                }
            })
        ));
        
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getDebugLogServiceFlagMock(Debug_Log_Service_Flag__c flag) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        String query = new QBuilder(Debug_Log_Service_Flag__c.SObjectType)
            .selectFields(new Set<String>{Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Created_Log__c.Name, Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Processed_Log__c.Name})
            .add(QBuilder.condition('SetupOwnerId').equalsTo(EXTERNAL_ORG_ID))
            .build();
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(new Map<String, Object>{
                ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Id.Name => flag.Id,
                        Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Created_Log__c.Name => flag.Last_Created_Log__c,
                        Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Processed_Log__c.Name => flag.Last_Processed_Log__c
                    }
                }
            })
        ));
        
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getProcessNewTraceFlagMock(ProcessTraceFlagSettings settings) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();

        if(settings.debugLevelExist) {
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_LEVELS, new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                        DEFAULT_DEBUG_LEVEL_RECORD
                    }
                })
            ));
        }
        else {
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_LEVELS, new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>()
                })
            ));
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL, new TestDataFactory.SingleRequestMock(
                201,
                'OK',
                JSON.serialize(new Map<String, Object> {
                    'id' => TEST_DEBUG_LEVEL_ID,
                    'success' => true
                })
            ));
        }

        if(settings.traceFlagExist) {
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_TRACE_FLAGS, new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                        DEFAULT_TRACE_FLAG_RECORD
                    }
                })
            ));

            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG + '/' + TEST_TRACE_FLAG_ID + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH, new TestDataFactory.SingleRequestMock(
                204,
                'OK',
                JSON.serialize(new Map<String, Object> {
                    'id' => TEST_TRACE_FLAG_ID,
                    'success' => true
                })
            ));
        }
        else {
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_TRACE_FLAGS, new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(new Map<String, Object>{
                    ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>()
                })
            ));
            endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG, new TestDataFactory.SingleRequestMock(
                201,
                'OK',
                JSON.serialize(new Map<String, Object> {
                    'id' => TEST_TRACE_FLAG_ID,
                    'success' => true
                })
            ));
        }

        return endpoint2TestResp;
    }

    private static final String TEST_DEBUG_LEVEL_ID = 'someDebugLevelId';
    private static final String TEST_TRACE_FLAG_ID = 'someTraceFlagId';
    private static Map<String, Object> DEFAULT_DEBUG_LEVEL_RECORD = new Map<String, Object>{
        'Id' => TEST_DEBUG_LEVEL_ID,
        'Language' => TraceService.DEFAULT_DEBUG_LEVEL_LANGUAGE,
        'DeveloperName' => TraceService.DEFAULT_DEBUG_LEVEL_NAME,
        'MasterLabel' => TraceService.DEFAULT_DEBUG_LEVEL_NAME,
        'ApexCode' => TraceService.DebugLogLevel.FINE.name(),
        'ApexProfiling' => TraceService.DebugLogLevel.FINE.name(),
        'Callout' => TraceService.DebugLogLevel.FINE.name(),
        'Database' => TraceService.DebugLogLevel.FINE.name(),
        'System' => TraceService.DebugLogLevel.FINE.name(),
        'Validation' => TraceService.DebugLogLevel.FINE.name(),
        'Visualforce' => TraceService.DebugLogLevel.FINE.name(),
        'Workflow' => TraceService.DebugLogLevel.FINE.name(),
        'attributes' => new Map<String, Object>{
            'type' => 'DebugLevel'
        }
    };

    private static Map<String, Object> DEFAULT_TRACE_FLAG_RECORD = new Map<String, Object>{
        'Id' => TEST_TRACE_FLAG_ID,
        'DebugLevelId' => TEST_DEBUG_LEVEL_ID,
        'ExpirationDate' => DateTime.now().addHours(-12),
        'StartDate' => DateTime.now(),
        'LogType' => TraceService.DebugLogType.DEVELOPER_LOG.name(),
        'TracedEntityId' => UserInfo.getUserId(),
        'ApexCode' => TraceService.DebugLogLevel.FINE.name(),
        'ApexProfiling' => TraceService.DebugLogLevel.FINE.name(),
        'Callout' => TraceService.DebugLogLevel.FINE.name(),
        'Database' => TraceService.DebugLogLevel.FINE.name(),
        'System' => TraceService.DebugLogLevel.FINE.name(),
        'Validation' => TraceService.DebugLogLevel.FINE.name(),
        'Visualforce' => TraceService.DebugLogLevel.FINE.name(),
        'Workflow' => TraceService.DebugLogLevel.FINE.name(),
        'attributes' => new Map<String, Object>{
            'type' => 'TraceFlag'
        }
    };

    public static Issue__c createIssue() {
        Issue__c issue = new Issue__c();
        issue.Status__c = 'New';
        insert issue;
        return issue;
    }

    public static Trace_Schedule__c createTraceSchedule() {
        return createTraceSchedule(createIssue().Id);
    }

    public static Trace_Schedule__c createTraceSchedule(Id issueId) {
        Trace_Schedule__c result = new Trace_Schedule__c();
        result.Name = 'Test';
        result.Description__c = 'Test';
        result.Issue__c = issueId;
        insert result;
        return result;
    }

    public static Trace_Result__c createTraceResult(Id issueId, Id requestId, Id scheduleId) {
        Trace_Result__c result = new Trace_Result__c();
        result.Issue__c = issueId;
        result.Trace_Request__c = requestId;
        result.Trace_Schedule__c = scheduleId;
        result.Trace_End_Date__c = DateTime.now();
        result.Trace_Start_Date__c = DateTime.now();
        return result;
    }

    public static ContentDocumentLink createTraceResultCV(Id relatedId) {
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'somejson.json';
        cv.VersionData = Blob.valueOf('somedata');
        cv.Description = 'somedetails';
        insert cv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = relatedId;
        cdl.ShareType = 'I';
        insert cdl;
        return cdl;
    }

    public static Trace_Request__c createTraceRequest(Boolean isDefaultDebugLevel, Boolean isExpiredTraceFlag) {
        return createTraceRequest(isDefaultDebugLevel, isExpiredTraceFlag, createTraceSchedule().Id);
    }

    public static Trace_Request__c createTraceRequest(Boolean isDefaultDebugLevel, Boolean isExpiredTraceFlag, String traceScheduleId ) {
        TraceService.DebugLevel defDebugLogLevel = TraceService.createDefaultDebugLevel();
        Trace_Request__c result = new Trace_Request__c();
        result.Trace_Schedule__c = traceScheduleId;
        result.Status__c = TraceService.TRACE_REQUEST_STATUS_NEW;
        result.Traced_Entity_Id__c = UserInfo.getUserId();
        result.Start_Date__c = DateTime.now();
        result.End_Date__c = DateTime.now().addHours(isExpiredTraceFlag ? 12 : 24);
        result.Apex_Code__c = (isDefaultDebugLevel) ? defDebugLogLevel.ApexCode.name() : TraceService.DebugLogLevel.NONE.name();
        result.Apex_Profiling__c = defDebugLogLevel.ApexProfiling.name();
        result.Callout__c = defDebugLogLevel.Callout.name();
        result.System__c = defDebugLogLevel.System_x.name();
        result.Validation__c = defDebugLogLevel.Validation.name();
        result.Visualforce__c = defDebugLogLevel.Visualforce.name();
        result.Workflow__c = defDebugLogLevel.Workflow.name();
        result.Source__c = EXTERNAL_ORG_ID;

        return result;
    }

    @IsTest
    private static void test_insert_debug_level_success() {
        test_insert_debug_level(true);
    }

    @IsTest
    private static void test_insert_debug_level_failed() {
        test_insert_debug_level(false);
    }
   
    private static void test_insert_debug_level(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllDebugLevelsMock();
        endpoint2TestResp.putAll(getInsertDebugLevelMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Database.SaveResult result;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.DebugLevel dl = TraceService.createDefaultDebugLevel();

        Test.startTest();
        result = traceServiceInstance.insertDebugLevel(dl);
        Test.stopTest();

        System.assertEquals(isSuccess, result.isSuccess());
    }

    @IsTest
    private static void test_update_debug_level_success() {
        test_update_debug_level(true);
    }
    @IsTest
    private static void test_update_debug_level_failed() {
        test_update_debug_level(false);
    }

    private static void test_update_debug_level(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllDebugLevelsMock();
        endpoint2TestResp.putAll(getUpdateDebugLevelMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Boolean result;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.DebugLevel dl = TraceService.createDefaultDebugLevel();
        dl.Id = TEST_DEBUG_LEVEL_ID;

        Test.startTest();
        result = traceServiceInstance.updateDebugLevel(dl);
        Test.stopTest();

        System.assertEquals(isSuccess, result);
    }

    @IsTest
    private static void test_delete_debug_level_success() {
        test_delete_debug_level(true);
    }
    @IsTest
    private static void test_delete_debug_level_failed() {
        test_delete_debug_level(false);
    }
    private static void test_delete_debug_level(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllDebugLevelsMock();
        endpoint2TestResp.putAll(getDeleteDebugLevelMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Database.DeleteResult result;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.DebugLevel dl = TraceService.createDefaultDebugLevel();
        dl.Id = TEST_DEBUG_LEVEL_ID;

        Test.startTest();
        result = traceServiceInstance.deleteDebugLevel(dl);
        Test.stopTest();

        System.assertEquals(isSuccess, result.isSuccess());
    }

    @IsTest
    private static void test_insert_trace_flag_success() {
        test_insert_trace_flag(true);
    }
    @IsTest
    private static void test_insert_trace_flag_failed() {
        test_insert_trace_flag(false);
    }
    private static void test_insert_trace_flag(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllTraceFlagsMock();
        endpoint2TestResp.putAll(getGetAllDebugLevelsMock());
        endpoint2TestResp.putAll(getInsertTraceFlagMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Database.SaveResult result;
        
        Test.startTest();
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.TraceFlag tf = traceServiceInstance.createTraceFlag(DateTime.now().addHours(24), DateTime.now());
        result = traceServiceInstance.insertTraceFlag(tf);
        Test.stopTest();

        System.assertEquals(isSuccess, result.isSuccess());
    }

    @IsTest
    private static void test_update_trace_flag_success() {
        test_update_trace_flag(true);
    }
    @IsTest
    private static void test_update_trace_flag_failed() {
        test_update_trace_flag(false);
    }
    private static void test_update_trace_flag(Boolean isSuccess) {
        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllTraceFlagsMock();
        endpoint2TestResp.putAll(getGetAllDebugLevelsMock());
        endpoint2TestResp.putAll(getUpdateTraceFlagMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Boolean result;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.TraceFlag tf = traceServiceInstance.createTraceFlag(DateTime.now().addHours(24), DateTime.now());
        
        tf.Id = TEST_TRACE_FLAG_ID;
        tf.ExpirationDate = DateTime.now().addHours(25);
        tf.StartDate = DateTime.now().addHours(1);
        result = traceServiceInstance.updateTraceFlag(tf);
        Test.stopTest();

        System.assertEquals(isSuccess, result);
    }

    @IsTest
    private static void test_delete_trace_flag_success() {
        test_delete_trace_flag(true);
    }
    @IsTest
    private static void test_delete_trace_flag_failed() {
        test_delete_trace_flag(false);
    }
    private static void test_delete_trace_flag(Boolean isSuccess) {
        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = getGetAllTraceFlagsMock();
        endpoint2TestResp.putAll(getGetAllDebugLevelsMock());
        endpoint2TestResp.putAll(getDeleteTraceFlagMock(isSuccess));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Database.DeleteResult result;
        TraceService traceServiceInstance = TraceService.getInstance();
        traceServiceInstance.setConnectedOrgById(EXTERNAL_ORG_ID);
        TraceService.TraceFlag tf = traceServiceInstance.createTraceFlag(DateTime.now().addHours(24), DateTime.now());
        
        tf.Id = TEST_TRACE_FLAG_ID;
        result = traceServiceInstance.deleteTraceFlag(tf);
        Test.stopTest();

        System.assertEquals(isSuccess, result.isSuccess());
    }

    private static Map<String, HttpCalloutMock> getInsertTraceFlagMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'id' => TEST_TRACE_FLAG_ID,
                'success' => true
            };
            
        }
        else {
            respMap = new Map<String, Object> {
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG, new TestDataFactory.SingleRequestMock(
            201,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getUpdateTraceFlagMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'id' => TEST_TRACE_FLAG_ID,
                'success' => true
            };
            
        }
        else {
            respMap = new Map<String, Object> {
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG + '/' + TEST_TRACE_FLAG_ID + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH, new TestDataFactory.SingleRequestMock(
            isSuccess ? 204 : 500,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getDeleteTraceFlagMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'success' => true
            };
        }
        else {
            respMap = new Map<String, Object> {
                'id' => TEST_TRACE_FLAG_ID,
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG + '/' + TEST_TRACE_FLAG_ID, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getInsertDebugLevelMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'id' => TEST_DEBUG_LEVEL_ID,
                'success' => true
            };
            
        }
        else {
            respMap = new Map<String, Object> {
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL, new TestDataFactory.SingleRequestMock(
            201,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getUpdateDebugLevelMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'id' => TEST_DEBUG_LEVEL_ID,
                'success' => true
            };
        }
        else {
            respMap = new Map<String, Object> {
                'id' => TEST_DEBUG_LEVEL_ID,
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL + '/' + TEST_DEBUG_LEVEL_ID + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH, new TestDataFactory.SingleRequestMock(
            isSuccess ? 204 : 500,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getDeleteDebugLevelMock(Boolean isSuccess) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>();
        if(isSuccess) {
            respMap = new Map<String, Object> {
                'success' => true
            };
        }
        else {
            respMap = new Map<String, Object> {
                'id' => TEST_DEBUG_LEVEL_ID,
                'success' => false,
                'errors' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 
                        'message' => 'some error',
                        'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                    }
                }
            };
        }
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL + '/' + TEST_DEBUG_LEVEL_ID, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getGetAllDebugLevelsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>{
            ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                DEFAULT_DEBUG_LEVEL_RECORD
            }
        };
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_LEVELS, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getGetAllTraceFlagsMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>{
            ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                DEFAULT_TRACE_FLAG_RECORD
            }
        };
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_TRACE_FLAGS, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

    @IsTest
    private static void test_populate_lookups_status_scheduled() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        request1.Start_Date__c = Datetime.now().addDays(1);
        request1.End_Date__c = Datetime.now().addDays(2);
        
        Test.startTest();
        insert request1;
        Test.stopTest();

        schedule1 = [SELECT Status__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_SCHEDULE_STATUS_SCHEDULED, schedule1.Status__c);
    }

    @IsTest
    private static void test_populate_lookups_status_completed() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        request1.Start_Date__c = Datetime.now().addDays(-1);
        request1.End_Date__c = Datetime.now().addDays(-2);
        
        Test.startTest();
        insert request1;
        Test.stopTest();

        schedule1 = [SELECT Status__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_SCHEDULE_STATUS_COMPLETED, schedule1.Status__c);
    }

    @IsTest
    private static void test_populate_lookups_status_in_progress() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        request1.Status__c = TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
        
        Test.startTest();
        insert request1;
        Test.stopTest();

        schedule1 = [SELECT Status__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_SCHEDULE_STATUS_IN_PROGRESS, schedule1.Status__c);
    }

    @IsTest
    private static void test_populate_lookups_issue_id() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        
        Test.startTest();
        insert request1;
        Test.stopTest();

        request1 = [SELECT Issue__c, Start_Date__c, End_Date__c FROM Trace_Request__c WHERE Id =: request1.Id LIMIT 1];
        System.assertEquals(issue1.Id, request1.Issue__c);
        System.assertNotEquals(null, request1.Start_Date__c);
        System.assertNotEquals(null, request1.End_Date__c);
    }

    @IsTest
    private static void test_populate_lookups_dates_on_insert_update() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        insert request1;

        schedule1 = [SELECT Trace_Start_Date__c, Trace_End_Date__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertNotEquals(null, schedule1.Trace_Start_Date__c);
        System.assertNotEquals(null, schedule1.Trace_End_Date__c);

        System.assertEquals(request1.Start_Date__c, schedule1.Trace_Start_Date__c);
        System.assertEquals(request1.End_Date__c, schedule1.Trace_End_Date__c);

        Trace_Request__c request2 = createTraceRequest(true, true, schedule1.Id);
        request2.Start_Date__c = Datetime.now().addDays(1);
        request2.End_Date__c = Datetime.now().addDays(2);
        
        Test.startTest();
        insert request2;
        Test.stopTest();

        schedule1 = [SELECT Trace_Start_Date__c, Trace_End_Date__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertNotEquals(null, schedule1.Trace_Start_Date__c);
        System.assertNotEquals(null, schedule1.Trace_End_Date__c);

        System.assertEquals(request1.Start_Date__c, schedule1.Trace_Start_Date__c);
        System.assertEquals(request2.End_Date__c, schedule1.Trace_End_Date__c);
    }

    @IsTest
    private static void test_populate_lookups_dates_on_delete() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        insert request1;

        schedule1 = [SELECT Trace_Start_Date__c, Trace_End_Date__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertNotEquals(null, schedule1.Trace_Start_Date__c);
        System.assertNotEquals(null, schedule1.Trace_End_Date__c);

        System.assertEquals(request1.Start_Date__c, schedule1.Trace_Start_Date__c);
        System.assertEquals(request1.End_Date__c, schedule1.Trace_End_Date__c);

        Trace_Request__c request2 = createTraceRequest(true, true, schedule1.Id);
        request2.Start_Date__c = Datetime.now().addDays(1);
        request2.End_Date__c = Datetime.now().addDays(2);
        insert request2;
        schedule1 = [SELECT Trace_Start_Date__c, Trace_End_Date__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertNotEquals(null, schedule1.Trace_Start_Date__c);
        System.assertNotEquals(null, schedule1.Trace_End_Date__c);

        System.assertEquals(request1.Start_Date__c, schedule1.Trace_Start_Date__c);
        System.assertEquals(request2.End_Date__c, schedule1.Trace_End_Date__c);
        
        Test.startTest();
        delete request2;
        Test.stopTest();

        schedule1 = [SELECT Trace_Start_Date__c, Trace_End_Date__c FROM Trace_Schedule__c WHERE Id =: schedule1.Id LIMIT 1];
        System.assertNotEquals(null, schedule1.Trace_Start_Date__c);
        System.assertNotEquals(null, schedule1.Trace_End_Date__c);

        System.assertEquals(request1.Start_Date__c, schedule1.Trace_Start_Date__c);
        System.assertEquals(request1.End_Date__c, schedule1.Trace_End_Date__c);
    }

    @IsTest
    private static void test_inactivate_trace_requests() {
        Issue__c issue1 = createIssue();
        Trace_Schedule__c schedule1 = createTraceSchedule(issue1.Id);
        Trace_Request__c request1 = createTraceRequest(true, true, schedule1.Id);
        insert request1;

        Test.startTest();
        schedule1.Status__c = TraceService.TRACE_SCHEDULE_STATUS_INACTIVE;
        update schedule1;
        Test.stopTest();

        request1 = [SELECT Status__c FROM Trace_Request__c WHERE Id =: request1.Id LIMIT 1];
        System.assertEquals(TraceService.TRACE_REQUEST_STATUS_INACTIVE, request1.Status__c);
    }
    
}