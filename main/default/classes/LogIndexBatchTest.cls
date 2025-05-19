@IsTest
public with sharing class LogIndexBatchTest {

    private static final String TEST_HASH_1 = 'someTesthash1';
    private static final String TEST_HASH_2 = 'someTesthash2';
    private static final String TEST_ORG_ID = UserInfo.getOrganizationId();
    private static final DateTime CREATED_AT_1 = System.now().addDays(-2);
    private static final DateTime CREATED_AT_2 = System.now().addDays(-1);
    private static final DateTime TEST_FIRST_OCCURRED_ON = CREATED_AT_1;
    private static final String TEST_BUG_TRACKER_1 = 'http://somebugtrackerlink.com';
    private static final DateTime RESOLVED_ON_1 = System.now().addDays(1);

    @IsTest
    private static void test_filter_duplicate_errors() {
        Log__c log1 = new Log__c();
        log1.Created_At__c = CREATED_AT_1;
        log1.Hash_1__c = TEST_HASH_1;
        log1.Organization_Id__c = TEST_ORG_ID;

        Log__c log2 = new Log__c();
        log2.Created_At__c = CREATED_AT_1;
        log2.Hash_1__c = TEST_HASH_1;
        log2.Organization_Id__c = TEST_ORG_ID;

        insert new List<Log__c>{log1, log2};

        Test.startTest();
        String logKey1 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);

        Logger logger = Logger.getInstance();
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logKey1});
        ConfigUtil.LogIndex logIndex1 = new ConfigUtil.LogIndex(TEST_HASH_1, TEST_ORG_ID, CREATED_AT_1);
        helper.saveLogIndexes(logger);
        helper.saveLogIndex(logger, logIndex1);
        Test.stopTest();

        system.assertEquals(0, logger.logsQueue.size());
    }

    @IsTest
    private static void test_bulk_delete_index_positive(){
        List<Log__c> logs = new List<Log__c>();

        for(Integer i = 0; i < 201; i++) {
            Log__c log1 = new Log__c();
            log1.Created_At__c = CREATED_AT_1;
            log1.Hash_1__c = TEST_HASH_1;
            logs.add(log1);
        }
        for(Integer i = 0; i < 201; i++) {
            Log__c log2 = new Log__c();
            log2.Created_At__c = CREATED_AT_2;
            log2.Hash_1__c = TEST_HASH_2;
            logs.add(log2);
        }
        insert logs;

        System.assertEquals(2, [select count() from Log_Index__c]);
        
        Test.startTest();
        delete logs;
        Test.stopTest();

        System.assertEquals(0, [select count() from Log__c where Id IN :logs]);
        System.assertEquals(0, [select count() from Log_Index__c]);

        System.assertEquals(null, LogIndexBatch.getLastDeleteLogBatchTimeStamp());
    }

    @IsTest
    private static void test_delete_index_positive(){
        test_delete_index(true);
    }

    @IsTest
    private static void test_delete_index_negative(){
        test_delete_index(false);
    }

    private static void test_delete_index(Boolean isPositive) {
        Log__c log1 = new Log__c();
        log1.Created_At__c = CREATED_AT_1;
        log1.Hash_1__c = TEST_HASH_1;
        insert log1;

        if(!isPositive) {
            Log__c log12 = new Log__c();
            log12.Created_At__c = CREATED_AT_1;
            log12.Hash_1__c = TEST_HASH_1;
            insert log12;
        }

        log1 = [SELECT Is_New__c FROM Log__c WHERE Id =:log1.Id LIMIT 1];
        system.assertEquals(true, log1.Is_New__c);

        Test.startTest();
        delete log1;
        Test.stopTest();

        Log__c log11 = new Log__c();
        log11.Created_At__c = CREATED_AT_2;
        log11.Hash_1__c = TEST_HASH_1;
        insert log11;

        log11 = [SELECT Is_New__c FROM Log__c WHERE Id =:log11.Id LIMIT 1];
        system.assertEquals(isPositive, log11.Is_New__c);
    }

    @IsTest
    private static void test_create_log_indexes_by_trigger() {
        Log__c log1 = new Log__c();
        log1.Created_At__c = CREATED_AT_1;
        log1.Hash_1__c = TEST_HASH_1;
        Log__c log2 = new Log__c();
        log2.Created_At__c = CREATED_AT_1;
        log2.Hash_1__c = TEST_HASH_2;
        Log__c log21 = new Log__c();
        log21.Created_At__c = CREATED_AT_2;
        log21.Hash_1__c = TEST_HASH_2;

        Test.startTest();
        insert new List<Log__c>{log1, log2, log21};
        Test.stopTest();

        log2 = [SELECT Is_New__c FROM Log__c WHERE Id =:log2.Id LIMIT 1];
        system.assertEquals(true, log2.Is_New__c);

        log21 = [SELECT Is_New__c FROM Log__c WHERE Id =:log21.Id LIMIT 1];
        system.assertEquals(false, log21.Is_New__c);

        String logKey1 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        String logKey2 = ConfigUtil.getLogIndexKey(TEST_HASH_2, TEST_ORG_ID);

        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logKey1, logKey2});
        
        ConfigUtil.LogIndex index1 = helper.getLogIndex(TEST_HASH_1, TEST_ORG_ID);
        System.assertNotEquals(null, index1);
        System.assertEquals(TEST_HASH_1, index1.hash);
        System.assertEquals(TEST_FIRST_OCCURRED_ON, index1.firstOccurredOn);

        ConfigUtil.LogIndex index2 = helper.getLogIndex(TEST_HASH_2, TEST_ORG_ID);
        System.assertNotEquals(null, index2);
        System.assertEquals(TEST_HASH_2, index2.hash);
        System.assertEquals(TEST_FIRST_OCCURRED_ON, index2.firstOccurredOn);
    }
    
    @IsTest
    private static void test_create_log_indexes_by_batch() {

        Log__c log1 = new Log__c();
        log1.Created_At__c = CREATED_AT_1;
        log1.Hash_1__c = null;//TEST_HASH_1;
        Log__c log2 = new Log__c();
        log2.Created_At__c = CREATED_AT_1;
        log2.Hash_1__c = null;//TEST_HASH_2;
        Log__c log21 = new Log__c();
        log21.Created_At__c = CREATED_AT_2;
        log21.Hash_1__c = null;//TEST_HASH_2;
        log21.Bug_Tracker__c = TEST_BUG_TRACKER_1;
        Log__c log22 = new Log__c();
        log22.Created_At__c = CREATED_AT_2;
        log22.Hash_1__c = null;//TEST_HASH_2;
        Log__c log23 = new Log__c();
        log23.Created_At__c = CREATED_AT_2;
        log23.Hash_1__c = null;//TEST_HASH_2;
        log23.Resolved_On__c = RESOLVED_ON_1;
        insert new List<Log__c>{log1, log2, log21, log22, log23};

        log1.Hash_1__c = TEST_HASH_1;
        log2.Hash_1__c = TEST_HASH_2;
        log21.Hash_1__c = TEST_HASH_2;
        log22.Hash_1__c = TEST_HASH_2;
        log23.Hash_1__c = TEST_HASH_2;
        update new List<Log__c>{log1, log2, log21, log22, log23};
        

        Test.startTest();
        LogIndexBatch.getInstance(LogIndexBatch.JobType.INIT_INDEXES_BATCH).startBatch();
        Test.stopTest();

        String logKey1 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        String logKey2 = ConfigUtil.getLogIndexKey(TEST_HASH_2, TEST_ORG_ID);

        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logKey1, logKey2});
        
        ConfigUtil.LogIndex index1 = helper.getLogIndex(TEST_HASH_1, TEST_ORG_ID);
        System.assertNotEquals(null, index1);
        System.assertEquals(TEST_HASH_1, index1.hash);
        System.assertEquals(TEST_FIRST_OCCURRED_ON, index1.firstOccurredOn);

        ConfigUtil.LogIndex index2 = helper.getLogIndex(TEST_HASH_2, TEST_ORG_ID);
        System.assertNotEquals(null, index2);
        System.assertEquals(TEST_HASH_2, index2.hash);
        System.assertEquals(TEST_FIRST_OCCURRED_ON, index2.firstOccurredOn);
        System.assertEquals(TEST_BUG_TRACKER_1, index2.bugTracker);
        System.assertEquals(RESOLVED_ON_1, index2.resolvedOn);
    }
}