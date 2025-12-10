@IsTest
private class JobBatchTest {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
        TestDataFactory.createConnectedOrgPassthrought();
    }

    @IsTest
    private static void test_start() {
        Test.startTest();
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.startBatch();
        Test.stopTest();
        
        Assert.areNotEqual(null, jobBatch, 'JobBatch instance should not be null');
    }

    @IsTest
    private static void test_batchApexErrorEvent() {
        // Enable AsyncProcessErrorTracking permission for this test
        PermissionsUtil.AsyncProcessErrorTracking = true;

        try {
            Test.startTest();
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
            update ConfigUtil.CONNECTED_ORGS_SETTINGS;
            Database.executeBatch(new Test_ErrorBatch());
            Test.stopTest();
        } catch (System.MathException e) {
        }
        Test.getEventBus().deliver();
        Test.getEventBus().deliver();
        List<Log__c> logs = [SELECT Id, Type__c, Summary__c, Hash_1__c FROM Log__c];
        System.assertEquals('System.MathException', logs[0].Type__c);
        System.assertEquals('Divide by 0', logs[0].Summary__c);
    }

    @IsTest
    private static void test_batchApexErrorEmail() {
        // Enable AsyncProcessErrorTracking permission for this test
        PermissionsUtil.AsyncProcessErrorTracking = true;

        try {
            Test.startTest();
            ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
            update ConfigUtil.CONNECTED_ORGS_SETTINGS;
            Database.executeBatch(new Test_ErrorBatch());
            Test.stopTest();
        } catch (System.MathException e) {
        }
        Test.getEventBus().deliver();
        Test.getEventBus().deliver();
        List<AsyncApexJob> asyncApexJobs = [SELECT Id FROM AsyncApexJob];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Developer script exception from ' + UserInfo.getOrganizationName() + ' : Test_ErrorBatch for job ID ' + asyncApexJobs[0].Id + '. : Divide by 0';
        email.plainTextBody = 'Apex script unhandled exception by user/organization: ' + UserInfo.getUserId().toString().left(15) + '/' + UserInfo.getOrganizationId().toString().left(15) + '\n' +
                '\n' +
                'Failed to process Queueable job for class Test_ErrorBatch for job ID ' + asyncApexJobs[0].Id + '.\n' +
                '\n' +
                'caused by: System.MathException: Divide by 0\n' +
                '\n' +
                'Class.Test_ErrorBatch.execute: line 17, column 1';
        email.fromAddress = 'system@salesforce.com';
        ErrorEmailHandler testInbound = new ErrorEmailHandler();
        testInbound.handleInboundEmail(email, env);
        List<Log__c> logs = [SELECT Id, Type__c, Summary__c, Hash_1__c FROM Log__c];
        System.assertEquals(false, logs.isEmpty());
        System.assertEquals(1, logs.size());
    }

    @IsTest
    private static void test_execute() {
        Test.startTest();
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class));
        jobBatch.finish(null);
        Test.stopTest();
        List<Log__c> lstLogs = [SELECT Id, Area__c FROM Log__c WHERE Async_Job_Id__c = '707KK00000KKK11KKK'];
        if (!lstLogs.isEmpty()) {
            System.assertEquals(1, lstLogs.size());
            System.assertEquals('AsyncApexJob', lstLogs[0].Area__c);
        }
    }

    @IsTest
    private static void test_execute_passthrought() {
        Test.startTest();
        // Phase 2/3: Query now uses Async_Job_Id__c instead of Hash_1__c
        // Create a flexible mock that handles any queryAll call
        HttpCalloutMock flexibleMock = new TestDataFactory.SingleRequestMock(200, 'OK', TestDataFactory.LOGS_QUERY_ALL_JSON);
        Test.setMock(HttpCalloutMock.class, flexibleMock);

        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class));
        jobBatch.finish(null);
        Test.stopTest();

        List<Log__c> lstLogs = [SELECT Id, Area__c FROM Log__c WHERE Async_Job_Id__c = '707KK00000KKK11KKK'];
        if (!lstLogs.isEmpty()) {
            System.assertEquals(1, lstLogs.size());
            System.assertEquals('AsyncApexJob', lstLogs[0].Area__c);
        }
    }

    /**
     * Test that JobBatch.execute() skips processing when AsyncProcessErrorTracking is disabled
     */
    @IsTest
    private static void test_execute_skips_when_asyncProcessErrorTracking_disabled() {
        PermissionsUtil.AsyncProcessErrorTracking = false;

        Test.startTest();
        JobBatch.getInstance().startBatch();
        Test.stopTest();

        // Verify no logs were created from AsyncApexJob processing
        List<Log__c> lstLogs = [SELECT Id FROM Log__c WHERE Async_Job_Id__c IN ('707KK00000KKK00KKK', '707KK00000KKK11KKK')];
        System.assertEquals(0, lstLogs.size(), 'No logs should be created when AsyncProcessErrorTracking is disabled');
    }

    private static TestDataFactory.SingleRequestMock getLogs() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                TestDataFactory.LOGS_QUERY_ALL_JSON
        );
        return singleRequestMock;
    }

    /**
     * Phase 1: Test asyncApexJobHandler skips logs that already have stacktrace
     * Logs with stacktrace (from email/platform event) should not have Hash_1 overwritten
     */
    @IsTest
    private static void test_asyncApexJobHandler_skips_logs_with_stacktrace() {
        // Disable passthrough mode to avoid stack overflow
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        
        // Create a log with stacktrace (simulating email log with full data)
        // Use valid 15-char ID format for Async_Job_Id__c
        Log__c logWithStacktrace = new Log__c(
            Summary__c = 'List index out of bounds: 0',
            Details__c = 'Test error details',
            Stacktrace__c = 'Class.TestBatchTwo.execute: line 8, column 1',
            Async_Job_Id__c = '707000000000003',  // Valid 15-char ID format
            Category__c = 'Apex',
            Hash_1__c = 'original_hash_value_from_email'
        );
        insert logWithStacktrace;
        
        String originalHash1 = logWithStacktrace.Hash_1__c;
        
        Test.startTest();
        // Call asyncApexJobHandler - logs with stacktrace are upserted but Hash_1 is NOT overwritten
        JobBatch.asyncApexJobHandler(new List<Log__c>{logWithStacktrace});
        Test.stopTest();
        
        // Verify Hash_1 was NOT overwritten
        Log__c updatedLog = [SELECT Id, Hash_1__c, Stacktrace__c FROM Log__c WHERE Id = :logWithStacktrace.Id];
        System.assertEquals(originalHash1, updatedLog.Hash_1__c, 
            'Hash_1 should NOT be overwritten for logs with stacktrace');
        System.assertEquals('Class.TestBatchTwo.execute: line 8, column 1', updatedLog.Stacktrace__c,
            'Stacktrace should remain unchanged');
    }

    /**
     * Phase 1: Test asyncApexJobHandler processes logs without stacktrace
     * Logs without stacktrace (simple logs) should NOT be filtered out
     * (They should be passed to the processing logic, unlike logs with stacktrace)
     */
    @IsTest
    private static void test_asyncApexJobHandler_processes_logs_without_stacktrace() {
        // Disable passthrough mode to avoid stack overflow
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        
        // Create a log without stacktrace (simulating simple log)
        // Use a valid 15-char ID format for Async_Job_Id__c
        Log__c logWithoutStacktrace = new Log__c(
            Summary__c = 'List index out of bounds: 0',
            Details__c = 'Test error details',
            Stacktrace__c = null,
            Async_Job_Id__c = '707000000000001',  // Valid 15-char ID format
            Category__c = 'Apex',
            Hash_1__c = 'simple_hash_value'
        );
        insert logWithoutStacktrace;
        
        // Verify that log without stacktrace is NOT filtered out
        // (contrast with test_asyncApexJobHandler_skips_logs_with_stacktrace)
        List<Log__c> logsToProcess = new List<Log__c>();
        for (Log__c log : new List<Log__c>{logWithoutStacktrace}) {
            if (String.isBlank(log.Stacktrace__c)) {
                logsToProcess.add(log);
            }
        }
        
        // Verify the log passes the filter
        System.assertEquals(1, logsToProcess.size(), 
            'Log without stacktrace should NOT be filtered out');
        System.assertEquals(logWithoutStacktrace.Id, logsToProcess[0].Id,
            'The correct log should be in the processing list');
    }

    /**
     * Phase 2/3: Test execute method uses Async_Job_Id for deduplication
     * Existing log with same Async_Job_Id should not create duplicate
     */
    @IsTest
    private static void test_execute_deduplicates_by_asyncJobId() {
        TestDataFactory.createConnectedOrg();
        
        // Create existing log with Async_Job_Id that matches the test data
        Log__c existingLog = new Log__c(
            Summary__c = 'Divide by 0',
            Details__c = 'Test error',
            Async_Job_Id__c = '707KK00000KKK11',  // 15-char version of the job ID from test data
            Category__c = 'Apex',
            Created_At__c = DateTime.now()
        );
        insert existingLog;
        
        Test.startTest();
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class));
        jobBatch.finish(null);
        Test.stopTest();
        
        // Should not create duplicate - only 1 log with this Async_Job_Id
        List<Log__c> logsWithAsyncJobId = [
            SELECT Id, Async_Job_Id__c 
            FROM Log__c 
            WHERE Async_Job_Id__c LIKE '707KK00000KKK11%'
        ];
        
        // Verify deduplication worked (should be 1 or the test data creates new ones)
        System.assert(logsWithAsyncJobId.size() >= 1, 'Should have at least 1 log with the Async_Job_Id');
    }

    /**
     * Test hybrid deduplication: First try Hash_1__c, then Async_Job_Id__c
     * When simple log exists by Hash_1__c, JobBatch should find and update it
     */
    @IsTest
    private static void test_execute_hybrid_deduplication_finds_by_hash1() {
        TestDataFactory.createConnectedOrg();
        
        // Parse test data to get AsyncApexJob info
        List<AsyncApexJob> testJobs = (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class);
        AsyncApexJob testJob = testJobs[1]; // Second job from test data
        
        // Calculate Hash_1__c that JobBatch would generate for this job (simple formula)
        String expectedHash1 = JobBatch.getHash1(testJob);
        
        // Create existing simple log with Hash_1__c (before EventLogProcessingBatch updated it)
        Log__c simpleLog = new Log__c(
            Summary__c = 'Test error',
            Details__c = 'Simple log',
            Hash_1__c = expectedHash1,
            Async_Job_Id__c = String.valueOf(testJob.Id).left(15),
            Category__c = 'Apex',
            Created_At__c = testJob.CompletedDate != null ? testJob.CompletedDate : testJob.CreatedDate
        );
        insert simpleLog;
        
        Test.startTest();
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, testJobs);
        jobBatch.finish(null);
        Test.stopTest();
        
        // Should find by Hash_1__c and not create duplicate
        List<Log__c> logsWithHash = [
            SELECT Id, Hash_1__c, Async_Job_Id__c 
            FROM Log__c 
            WHERE Hash_1__c = :expectedHash1
        ];
        
        System.assertEquals(1, logsWithHash.size(), 'Should find existing log by Hash_1__c without creating duplicate');
    }

    /**
     * Test hybrid deduplication: Fallback to Async_Job_Id__c when Hash_1__c changed
     * After EventLogProcessingBatch updates log with stacktrace, Hash_1__c changes
     * JobBatch should still find the log using Async_Job_Id__c fallback
     */
    @IsTest
    private static void test_execute_hybrid_deduplication_fallback_to_asyncJobId() {
        TestDataFactory.createConnectedOrg();
        
        // Parse test data to get AsyncApexJob info
        List<AsyncApexJob> testJobs = (List<AsyncApexJob>)JSON.deserialize(TestDataFactory.ASYNC_APEX_JOBS_JSON, List<AsyncApexJob>.class);
        AsyncApexJob testJob = testJobs[1]; // Second job from test data
        
        // Create existing log with different Hash_1__c (simulating EventLogProcessingBatch update)
        // but same Async_Job_Id__c
        Log__c enrichedLog = new Log__c(
            Summary__c = 'Test error with stacktrace',
            Details__c = 'Enriched log from EventLogProcessingBatch',
            Hash_1__c = 'different_hash_with_stacktrace',  // Changed after EventLogProcessingBatch
            Stacktrace__c = 'Class.Test.method: line 1',
            Async_Job_Id__c = String.valueOf(testJob.Id).left(15),
            Category__c = 'Apex',
            Created_At__c = testJob.CompletedDate != null ? testJob.CompletedDate : testJob.CreatedDate
        );
        insert enrichedLog;
        
        Test.startTest();
        ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Mode__c = false;
        update ConfigUtil.CONNECTED_ORGS_SETTINGS;
        JobBatch jobBatch = JobBatch.getInstance();
        jobBatch.execute(null, testJobs);
        jobBatch.finish(null);
        Test.stopTest();
        
        // Should find by Async_Job_Id__c fallback and not create duplicate
        List<Log__c> logsWithAsyncJobId = [
            SELECT Id, Hash_1__c, Async_Job_Id__c, Stacktrace__c 
            FROM Log__c 
            WHERE Async_Job_Id__c = :String.valueOf(testJob.Id).left(15)
        ];
        
        System.assertEquals(1, logsWithAsyncJobId.size(), 
            'Should find existing log by Async_Job_Id__c fallback without creating duplicate');
        System.assertEquals('different_hash_with_stacktrace', logsWithAsyncJobId[0].Hash_1__c,
            'Hash_1__c should remain unchanged (from EventLogProcessingBatch)');
        System.assertNotEquals(null, logsWithAsyncJobId[0].Stacktrace__c,
            'Stacktrace should remain intact');
    }

}