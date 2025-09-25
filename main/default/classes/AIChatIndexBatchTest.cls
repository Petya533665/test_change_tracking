@IsTest
private class AIChatIndexBatchTest {

    private static final Integer LOGS_AMOUNT = 5;

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
        
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < LOGS_AMOUNT; i++) {
            Log__c log = new Log__c(
                Hash_1__c = 'test_hash_' + i,
                Created_At__c = DateTime.now(),
                Category__c = 'Test',
                Type__c = 'Test',
                Area__c = 'Test',
                Summary__c = 'Test Summary ' + i,
                Details__c = 'Test Details ' + i
            );
            testLogs.add(log);
        }
        insert testLogs;
        
        List<Log_Index__c> logIndexes = new List<Log_Index__c>();
        for (Log__c log : testLogs) {
            Log_Index__c logIndex = new Log_Index__c(
                Hash__c = log.Hash_1__c,
                Key__c = 'test_key_' + log.Hash_1__c,
                Organization_Id__c = UserInfo.getOrganizationId(),
                Type__c = 'T'
            );
            logIndexes.add(logIndex);
        }
        insert logIndexes;
    }

    private static Map<String, HttpCalloutMock> getBaseHttpMocks() {
        TestDataFactory.SingleRequestMock initiateMultipartMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{' +
                '"upload_id": "test_upload_id",' +
                '"object_key": "test_object_key",' +
                '"parts": [' +
                    '"https://ai-pharos-index.s3.amazonaws.com/part1",' +
                    '"https://ai-pharos-index.s3.amazonaws.com/part2"' +
                ']' +
            '}'
        );

        TestDataFactory.SingleRequestMock s3UploadMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            'Success'
        );

        TestDataFactory.SingleRequestMock remoteSiteSettingsMock = new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            '{"records": [{"Id": "test-id", "IsActive": true, "SiteName": "' + Constants.REMOTE_SITE_SETTINGS.AI_NAME + '", "EndpointUrl": "' + Constants.REMOTE_SITE_SETTINGS.AI_URL + '"}]}'
        );

        return new Map<String, HttpCalloutMock>{
            Constants.REMOTE_SITE_SETTINGS.AI_URL + '/index/logs' => initiateMultipartMock,
            'https://ai-pharos-index.s3.amazonaws.com' => s3UploadMock,
            ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_REMOTE_SITE_SETTINGS_QUERY => remoteSiteSettingsMock
        };
    }

    @IsTest
    private static void test_empty_settings() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));

        Test.startTest();
        Database.executeBatch(AIChatIndexBatch.getInstance());
        Test.stopTest();
        
        // Verify settings were created and updated
        AI_Chat_Index_Settings__c settings = AI_Chat_Index_Settings__c.getOrgDefaults();
        System.assertNotEquals(null, settings, 'Settings should be created');
        System.assertEquals(LOGS_AMOUNT, settings.ProcessedLogHashes__c, 'Should process all 5 logs');
        System.assertNotEquals(null, settings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be set');
    }

    @IsTest
    private static void test_filled_settings() {
        AI_Chat_Index_Settings__c settings = new AI_Chat_Index_Settings__c();
        settings.ProcessedLogHashes__c = 2;
        settings.LastLogUpdateTimestamp__c = DateTime.now().addHours(-1);
        insert settings;
        
        List<Log__c> additionalLogs = new List<Log__c>();
        for (Integer i = 5; i < 8; i++) {
            Log__c log = new Log__c(
                Hash_1__c = 'additional_hash_' + i,
                Created_At__c = DateTime.now(),
                Category__c = 'Test',
                Type__c = 'Test',
                Area__c = 'Test',
                Summary__c = 'Additional Summary ' + i,
                Details__c = 'Additional Details ' + i
            );
            additionalLogs.add(log);
        }
        insert additionalLogs;
        
        List<Log_Index__c> additionalIndexes = new List<Log_Index__c>();
        for (Log__c log : additionalLogs) {
            Log_Index__c logIndex = new Log_Index__c(
                Hash__c = log.Hash_1__c,
                Key__c = 'additional_key_' + log.Hash_1__c,
                Organization_Id__c = UserInfo.getOrganizationId(),
                Type__c = 'T'
            );
            additionalIndexes.add(logIndex);
        }
        insert additionalIndexes;
        
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getBaseHttpMocks()));

        Test.startTest();
        Database.executeBatch(AIChatIndexBatch.getInstance());
        Test.stopTest();
        
        AI_Chat_Index_Settings__c updatedSettings = AI_Chat_Index_Settings__c.getOrgDefaults();
        System.assertEquals(LOGS_AMOUNT + 3, updatedSettings.ProcessedLogHashes__c, 'Should process all 8 logs (5 original + 3 additional)');
        System.assertNotEquals(null, updatedSettings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be updated');
    }

    @IsTest
    private static void test_deleted_logs_only() {
        AI_Chat_Index_Settings__c settings = new AI_Chat_Index_Settings__c();
        settings.ProcessedLogHashes__c = LOGS_AMOUNT;
        settings.LastLogUpdateTimestamp__c = DateTime.now().addHours(-1);
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
        System.assertEquals(LOGS_AMOUNT - 2, updatedSettings.ProcessedLogHashes__c, 'Should reflect the remaining 3 logs');
        System.assertNotEquals(null, updatedSettings.LastLogUpdateTimestamp__c, 'LastLogUpdateTimestamp should be updated');
    }
}