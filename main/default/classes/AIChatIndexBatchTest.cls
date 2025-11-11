@IsTest
private class AIChatIndexBatchTest {

    private static final String S3_REMOTE_SITE_URL = 'https://ai.pharos.ai/s3';

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
    }

    private static void createTestLogs(Integer count, String hashPrefix) {
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < count; i++) {
            Log__c log = new Log__c(
                Hash_1__c = hashPrefix + i,
                Created_At__c = DateTime.now()
            );
            testLogs.add(log);
        }
        insert testLogs;
    }

    private static Map<String, HttpCalloutMock> getBaseHttpMocks() {
        TestDataFactory.SingleRequestMock initiateMultipartMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{' +
                '"upload_id": "test_upload_id",' +
                '"object_key": "test_object_key",' +
                '"parts": [' +
                    '"' + S3_REMOTE_SITE_URL + '/part1"' +
                ']' +
            '}'
        );

        TestDataFactory.SingleRequestMock s3UploadMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            'Success'
        );

        return new Map<String, HttpCalloutMock>{
            AIChatIndexBatch.INDEX_MANAGER_LOGS_ENDPOINT => initiateMultipartMock,
            S3_REMOTE_SITE_URL => s3UploadMock,
            S3_REMOTE_SITE_URL + '/part1' => s3UploadMock
        };
    }

    @IsTest
    private static void test_new_settings() {
        createTestLogs(5, 'test');
        AI_Chat_Index_Settings__c settings = new AI_Chat_Index_Settings__c();
        settings.LastLogUpdateTimestamp__c = DateTime.newInstance(1970, 1, 1);
        insert settings;
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));
        Test.startTest();
        Database.executeBatch(AIChatIndexBatch.getInstance());
        Test.stopTest();
        
        AI_Chat_Index_Settings__c updatedSettings = AI_Chat_Index_Settings__c.getOrgDefaults();
        System.assertNotEquals(null, updatedSettings, 'Settings should be updated');
        System.assertNotEquals(null, updatedSettings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be set');
    }

    @IsTest
    private static void test_existing_settings() {
        createTestLogs(5, 'test');
        AI_Chat_Index_Settings__c settings = new AI_Chat_Index_Settings__c();
        DateTime timestamp = DateTime.now().addHours(-1);
        settings.LastLogUpdateTimestamp__c = timestamp;
        insert settings;
        
        createTestLogs(3, 'new');
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));
        Test.startTest();
        Database.executeBatch(AIChatIndexBatch.getInstance());
        Test.stopTest();
        
        AI_Chat_Index_Settings__c updatedSettings = AI_Chat_Index_Settings__c.getOrgDefaults();
        System.assertNotEquals(timestamp, updatedSettings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be updated');
    }

    @IsTest
    private static void test_deleted_logs_only() {
        createTestLogs(5, 'test');
        AI_Chat_Index_Settings__c settings = new AI_Chat_Index_Settings__c();
        DateTime timestamp = DateTime.now().addHours(-1);
        settings.LastLogUpdateTimestamp__c = timestamp;
        insert settings;
        
        List<Log_Index__c> logIndexesToDelete = [SELECT Id, Hash__c FROM Log_Index__c LIMIT 2];
        Set<String> hashesToDelete = new Set<String>();
        for (Log_Index__c logIndex : logIndexesToDelete) {
            hashesToDelete.add(logIndex.Hash__c);
        }
        List<Log__c> logsToDelete = [SELECT Id FROM Log__c WHERE Hash_1__c IN :hashesToDelete];
        delete logsToDelete;
        delete logIndexesToDelete;
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));
        Test.startTest();
        Database.executeBatch(AIChatIndexBatch.getInstance());
        Test.stopTest();
        
        AI_Chat_Index_Settings__c updatedSettings = AI_Chat_Index_Settings__c.getOrgDefaults();
        System.assertNotEquals(timestamp, updatedSettings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be updated');
    }
}