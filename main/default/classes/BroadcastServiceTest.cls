@IsTest
private class BroadcastServiceTest {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
    }

    @IsTest
    private static void test_start_with_filters() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'sendTo';
        update corg;
        Rule__c rule = new Rule__c(
                Type__c = 'Broadcast',
                Related_Id__c = corg.Id,
                Index__c = 1,
                Active__c = true
        );
        insert rule;
        RuleFilter__c ruleFilter = new RuleFilter__c(
                Rule__c = rule.Id,
                FieldName__c = Log__c.Type__c.getDescribe().getName(),
                Field_Type__c = String.valueOf(Log__c.Type__c.getDescribe().getType()),
                ComparisonOperator__c = 'Equal',
                Comparison_Type__c = 'Value',
                Index__c = 1,
                Value__c = 'Test'
        );
        insert ruleFilter;
        Log__c log = new Log__c(
                Type__c = 'Test',
                Broadcast_Status__c = BroadcastService.BROADCAST_STATUS_NEEDED
        );
        insert log;
        Test.startTest();
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>{'FIELDS(ALL)'})
                .add(QBuilder.condition(Log__c.Broadcast_Status__c.getDescribe().getName()).equalsTo(BroadcastService.BROADCAST_STATUS_NEEDED))
                .add(QBuilder.condition(Log__c.Originated_From__c.getDescribe().getName()).isNull())
                .addLimit(BroadcastService.queryLimit)
                .build();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{"records":[{"attributes":{"type":"Log__c"},"Id":"' + log.Id + '","' + Log__c.Type__c.getDescribe().getName() + '":"Test"}]}'
        ));
        endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?' + ConfigUtil.PARAMS_TYPE + '=' + ConfigUtil.TYPE_BROADCAST, sendLogMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        BroadcastBatch.getInstance().startBatch();
        Test.stopTest();
    }

    @IsTest
    private static void test_update_status_positive() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'sendTo';
        update corg;
        Test.startTest();
        test_update_broadcast_status();
        Test.stopTest();
        System.assertEquals('Completed', [SELECT Id, Broadcast_Status__c FROM Log__c][0].Broadcast_Status__c);
    }

    @IsTest
    private static void test_update_status_negative() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        Test.startTest();
        test_update_broadcast_status();
        Test.stopTest();
        System.assertEquals(null, [SELECT Id, Broadcast_Status__c FROM Log__c][0].Broadcast_Status__c);
    }

    private static void test_update_broadcast_status() {
        Log__c log = new Log__c(
                Type__c = 'Test',
                Category__c = 'Test',
                Organization_Id__c = UserInfo.getOrganizationId()
        );
        insert log;
        String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>{'FIELDS(ALL)'})
                .add(QBuilder.condition(Log__c.Broadcast_Status__c.getDescribe().getName()).equalsTo(BroadcastService.BROADCAST_STATUS_NEEDED))
                .add(QBuilder.condition(Log__c.Originated_From__c.getDescribe().getName()).isNull())
                .addLimit(BroadcastService.queryLimit)
                .build();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'), new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{"records":[{"attributes":{"type":"Log__c"},"Id":"' + log.Id + '","' + Log__c.Type__c.getDescribe().getName() + '":"Test"}]}'
        ));
        endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?' + ConfigUtil.PARAMS_TYPE + '=' + ConfigUtil.TYPE_BROADCAST, sendLogMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        log.Post_Processing_Status__c = 'Completed';
        update log;
    }

    @IsTest
    private static void test_parse_incoming_data_logs() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        Test.startTest();
        BroadcastService.IncomingData incomingData = new BroadcastService.IncomingData();
        incomingData.logs = new List<Log__c>{new Log__c()};
        Map<String, String> mapRecordTypesById = new Map<String, String>();
        for (String id : Schema.SObjectType.Log__c.getRecordTypeInfosById().keySet()) {
            mapRecordTypesById.put(id, Schema.SObjectType.Log__c.getRecordTypeInfosById().get(id).getName());
        }
        incomingData.mapRecordTypesById = mapRecordTypesById;
        incomingData.organizationId = UserInfo.getOrganizationId().left(15);
        BroadcastService.parseIncomingData(incomingData);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

    @IsTest
    private static void test_parse_incoming_data_content_version() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Data_Direction__c = 'receiveFrom';
        update corg;
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.Title = 'test_title';
        contentVersion.PathOnClient = 'test_path';
        BroadcastService.IncomingData incomingData = new BroadcastService.IncomingData();
        incomingData.contentVersionWrapper = new BulkAPIJobBatchService.ContentVersionWrapper(contentVersion, 'test');
        incomingData.organizationId = UserInfo.getOrganizationId().left(15);
        BroadcastService.parseIncomingData(incomingData);
        System.assertEquals(1, [SELECT Id FROM ContentVersion].size());
    }

    private static TestDataFactory.SingleRequestMock sendLogMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                'Done'
        );
        return singleRequestMock;
    }

}