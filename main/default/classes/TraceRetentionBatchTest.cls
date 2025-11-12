@IsTest
public with sharing class TraceRetentionBatchTest {
    private static final String INSTANCE_URL = 'http://sfdc.com';
    private static final String EXTERNAL_ORG_ID = '00D200000006k0s';

    @TestSetup
    static void makeData() {
        setupConnectedOrg();
    }

    // ============================================
    // Test Batch Execution - Successful Run
    // ============================================

    @IsTest
    static void test_batchExecution_successfulRun() {
        enableDebugLogService();
        setupDebugLogServiceSettings(true);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(1);
        setHttpMocks(true, createMockApexLogIds(3));
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(1, helper.totalRetentionRuns, 'Total retention runs should be 1');
        Assert.areEqual(0, [SELECT COUNT() FROM Log__c], 'Error log should not be created');
    }

    // ============================================
    // Test Batch Execution - Missing Permissions
    // ============================================

    @IsTest
    static void test_batchExecution_missingPermissions() {
        disableDebugLogService();
        setupDebugLogServiceSettings(true);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(1);
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(0, [SELECT COUNT() FROM Log__c], 'Error log should not be created');
    }

    // ============================================
    // Test Batch Execution - Settings Disabled
    // ============================================

    @IsTest
    static void test_batchExecution_settingsDisabled() {
        enableDebugLogService();
        setupDebugLogServiceSettings(false);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(1);
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(0, [SELECT COUNT() FROM Log__c], 'Error log should not be created');
    }

    // ============================================
    // Test Batch Execution - Delete Error
    // ============================================

    @IsTest
    static void test_batchExecution_withDeleteError() {
        enableDebugLogService();
        setupDebugLogServiceSettings(true);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(1);
        setHttpMocks(false, createMockApexLogIds(3));
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(1, [SELECT COUNT() FROM Log__c], 'Error log should be created');
    }

    // ============================================
    // Test Batch Execution - Multiple Runs
    // ============================================

    @IsTest
    static void test_batchExecution_multipleRuns() {
        enableDebugLogService();
        setupDebugLogServiceSettings(true);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(3);
        setHttpMocks(true, createMockApexLogIds(3));
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(3, helper.totalRetentionRuns, 'Total retention runs should be 3');
        Assert.areEqual(0, [SELECT COUNT() FROM Log__c], 'Error log should not be created');
    }

    // ============================================
    // Test Batch Execution - No Logs to Delete
    // ============================================

    @IsTest
    static void test_batchExecution_noLogsToDelete() {
        enableDebugLogService();
        setupDebugLogServiceSettings(true);
        
        TraceService.OrganizationStorageHelper helper = createStorageHelper(1);
        setHttpMocks(true, new List<Id>());
        
        Test.startTest();
        TraceRetentionBatch batch = TraceRetentionBatch.getInstance(helper);
        batch.startBatch();
        Test.stopTest();

        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(0, [SELECT COUNT() FROM Log__c], 'Error log should not be created');
    }

    // ============================================
    // Helper Methods
    // ============================================

    private static void enableDebugLogService() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>0, 1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0,
            10=>0, 11=>0, 12=>0, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>1,
            20=>0, 21=>0, 22=>0, 23=>0, 24=>0, 25=>0, 26=>0, 27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }

    private static void disableDebugLogService() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>0, 1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0,
            10=>0, 11=>0, 12=>0, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0,
            20=>0, 21=>0, 22=>0, 23=>0, 24=>0, 25=>0, 26=>0, 27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }

    private static void setupDebugLogServiceSettings(Boolean enabled) {
        ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Enabled__c = enabled;
        upsert ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS;
    }

    private static void setupConnectedOrg() {
        ConnectedOrgService.createConnectedOrg(EXTERNAL_ORG_ID, 'production', 'description', null, null, EXTERNAL_ORG_ID);
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(EXTERNAL_ORG_ID);
        corg.Instance_Url__c = INSTANCE_URL;
        corg.Access_Token__c = 'someToken';
        corg.Token_Refreshed_At__c = DateTime.now();
        DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c);
    }

    private static TraceService.OrganizationStorageHelper createStorageHelper(Integer runsPerOrg) {
        TraceService.OrganizationStorageHelper helper = new TraceService.OrganizationStorageHelper();
        helper.sourcesForRetentionRun = new Set<String>{ EXTERNAL_ORG_ID };
        helper.mapRetentionRuns = new Map<String, Integer>{ EXTERNAL_ORG_ID => runsPerOrg };
        helper.totalRetentionRuns = runsPerOrg;
        return helper;
    }

    private static List<Id> createMockApexLogIds(Integer count) {
        return TestDataFactory.getFakeIds(ApexLog.SObjectType, count);
    }

    private static void setHttpMocks(Boolean isSuccess, List<Id> recordIds) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        
        // Mock for Tooling Query API (getDebugApexLogsForDelete)
        endpoint2TestResp.putAll(getToolingQueryMock(isSuccess, recordIds));
        
        if (!recordIds.isEmpty()) {
            endpoint2TestResp.putAll(getDeleteCompositeMock(recordIds));
        }
        
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }

    private static Map<String, HttpCalloutMock> getToolingQueryMock(Boolean isSuccessQuery, List<Id> recordIds) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (Id logId : recordIds) {
            records.add(new Map<String, Object>{
                'Id' => String.valueOf(logId),
                'StartTime' => DateTime.now().addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
            });
        }
        
        Map<String, Object> queryResponse = isSuccessQuery 
            ? new Map<String, Object>{
                'size' => records.size(),
                'totalSize' => records.size(),
                'done' => true,
                'queryLocator' => null,
                'entityTypeName' => 'ApexLog',
                'records' => records
            }
            : new Map<String, Object>();
        
        TestDataFactory.SingleRequestMock queryMock = new TestDataFactory.SingleRequestMock(
            isSuccessQuery ? 200 : 404,
            isSuccessQuery ? 'OK' : 'Not Found',
            JSON.serialize(queryResponse)
        );
        
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'Id','StartTime'})
            .add(QBuilder.orderBy('StartTime').ascending())
            .addLimit(TraceRetentionBatch.BATCH_SCOPE)
            .build();
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), queryMock);
        
        return endpoint2TestResp;
    }

    private static Map<String, HttpCalloutMock> getDeleteCompositeMock(List<Id> recordIds) {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        List<Map<String, Object>> respMap = new List<Map<String, Object>>();
        
        for (Integer i = 0; i < recordIds.size(); i++) {
            respMap.add(new Map<String, Object>{ 'success' => true });
        }
        
        endpoint2TestResp.put(INSTANCE_URL + ConfigUtil.REMOTE_REST_COMPOSITE_API_DELETE_RECORDS + String.join(recordIds, ','), new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }
}