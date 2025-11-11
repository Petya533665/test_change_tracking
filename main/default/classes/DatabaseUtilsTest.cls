@IsTest
public with sharing class DatabaseUtilsTest {

    @TestSetup
    static void testSetup() {
        // Create test data for various scenarios
        List<Log__c> testLogs = new List<Log__c>();
        
        for (Integer i = 0; i < 5; i++) {
            Log__c testLog = new Log__c(
                Category__c = 'DatabaseUtilsTest',
                Details__c = 'Test log details ' + i,
                Summary__c = 'Test summary ' + i
            );
            testLogs.add(testLog);
        }
        insert testLogs;
    }

    @IsTest
    static void testGetInstance() {
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        Test.stopTest();
        
        Assert.areNotEqual(null, instance, 'Instance should not be null');
        Assert.isTrue(instance != null, 'Should return DatabaseUtils instance');
    }

    @IsTest
    static void testPerformInsertDML_WithValidData() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performInsertDML(testLogs, false);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
        Assert.areEqual(testLogs.size(), instance.saveResults.size(), 'Should have same number of save results as input records');
    }

    @IsTest
    static void testPerformInsertDML_WithEmptyList() {
        List<Log__c> emptyList = new List<Log__c>();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performInsertDML(emptyList, false);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(null, instance.saveResults, 'Save results should be null for empty list');
    }

    @IsTest
    static void testPerformInsertDML_WithDescribeSObjectResult() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performInsertDML(testLogs, dsr);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
    }

    @IsTest
    static void testPerformInsertDML_WithAllOrNone() {
        // Create new Log__c records without Id for insert test
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 2; i++) {
            Log__c testLog = new Log__c(
                Category__c = 'DatabaseUtilsTestInsert',
                Details__c = 'Test insert details ' + i,
                Summary__c = 'Test insert summary ' + i
            );
            testLogs.add(testLog);
        }
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performInsertDML(testLogs, dsr, true);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
    }

    @IsTest
    static void testPerformInsertImmediateDML() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performInsertImmediateDML(testLogs, dsr);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
    }

    @IsTest
    static void testPerformUpsertDML_WithValidData() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performUpsertDML(testLogs, dsr);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.upsertResults, 'Upsert results should not be null');
    }

    @IsTest
    static void testPerformUpsertDML_WithAllOrNone() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performUpsertDML(testLogs, dsr, true);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.upsertResults, 'Upsert results should not be null');
    }

    @IsTest
    static void testPerformUpsertDML_WithExternalId() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performUpsertDML(testLogs, dsr, Log__c.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.upsertResults, 'Upsert results should not be null');
    }

    @IsTest
    static void testPerformUpdateDML_WithValidData() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performUpdateDML(testLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
    }

    @IsTest
    static void testPerformUpdateDML_WithAllOrNone() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performUpdateDML(testLogs, dsr, true);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.saveResults, 'Save results should not be null');
    }

    @IsTest
    static void testPerformDeleteDML_WithValidData() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performDeleteDML(testLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.deleteResults, 'Delete results should not be null');
    }

    @IsTest
    static void testPerformDeleteDML_WithIds() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        List<Id> testIds = new List<Id>();
        for (Log__c log : testLogs) {
            testIds.add(log.Id);
        }
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        DatabaseUtils result = instance.performDeleteDML(testIds, dsr);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areNotEqual(null, instance.deleteResults, 'Delete results should not be null');
    }

    @IsTest
    static void testGetSuccessSObjects_WithSaveResults() {
        // Create new Log__c records without Id for insert test
        List<Log__c> testLogs = new List<Log__c>();
        for (Integer i = 0; i < 2; i++) {
            Log__c testLog = new Log__c(
                Category__c = 'DatabaseUtilsTestSuccess',
                Details__c = 'Test success details ' + i,
                Summary__c = 'Test success summary ' + i
            );
            testLogs.add(testLog);
        }
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performInsertDML(testLogs, false);
        List<SObject> successObjects = instance.getSuccessSObjects();
        Test.stopTest();
        
        Assert.areNotEqual(null, successObjects, 'Success objects should not be null');
        Assert.areEqual(testLogs.size(), successObjects.size(), 'Should return all successful objects');
    }

    @IsTest
    static void testGetSuccessSObjects_WithUpsertResults() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performUpsertDML(testLogs, dsr);
        List<SObject> successObjects = instance.getSuccessSObjects();
        Test.stopTest();
        
        Assert.areNotEqual(null, successObjects, 'Success objects should not be null');
        Assert.areEqual(testLogs.size(), successObjects.size(), 'Should return all successful objects');
    }

    @IsTest
    static void testGetSuccessSObjects_WithDeleteResults() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performDeleteDML(testLogs);
        List<SObject> successObjects = instance.getSuccessSObjects();
        Test.stopTest();
        
        Assert.areNotEqual(null, successObjects, 'Success objects should not be null');
        Assert.areEqual(testLogs.size(), successObjects.size(), 'Should return all successful objects');
    }

    @IsTest
    static void testHandleError_WithAreaAndApexName() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performInsertDML(testLogs, false);
        DatabaseUtils result = instance.handleError('TestArea', 'TestApexName');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(instance, result, 'Should return same instance');
    }

    @IsTest
    static void testHandleError_WithLogger() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Logger testLogger = Logger.getInstance();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performInsertDML(testLogs, false);
        DatabaseUtils result = instance.handleError('TestArea', 'TestApexName', testLogger);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(instance, result, 'Should return same instance');
    }

    @IsTest
    static void testFilterUpsertResultsDuplicateValue() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performUpsertDML(testLogs, dsr);
        DatabaseUtils result = instance.filterUpsertResultsDuplicateValue('TestField');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(instance, result, 'Should return same instance');
    }

    @IsTest
    static void testFilterUpsertResultsRowLock() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performUpsertDML(testLogs, dsr);
        DatabaseUtils result = instance.filterUpsertResultsRowLock();
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(instance, result, 'Should return same instance');
    }

    @IsTest
    static void testFilterUpsertResults_WithMessageAndStatusCode() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest' LIMIT 2];
        Schema.DescribeSObjectResult dsr = Log__c.SObjectType.getDescribe();
        
        Test.startTest();
        DatabaseUtils instance = DatabaseUtils.getInstance();
        instance.performUpsertDML(testLogs, dsr);
        DatabaseUtils result = instance.filterUpsertResults('TestMessage', System.StatusCode.DUPLICATE_VALUE);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return DatabaseUtils instance');
        Assert.areEqual(instance, result, 'Should return same instance');
    }

    @IsTest
    static void testSplitLogs_WithValidLogs() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest'];
        
        Test.startTest();
        List<List<Log__c>> result = DatabaseUtils.splitLogs(testLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.size() > 0, 'Should have at least one chunk');
        
        // Verify all logs are included
        Integer totalLogs = 0;
        for (List<Log__c> chunk : result) {
            totalLogs += chunk.size();
        }
        Assert.areEqual(testLogs.size(), totalLogs, 'All logs should be included in chunks');
    }

    @IsTest
    static void testSplitLogs_WithEmptyList() {
        List<Log__c> emptyLogs = new List<Log__c>();
        
        Test.startTest();
        List<List<Log__c>> result = DatabaseUtils.splitLogs(emptyLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(1, result.size(), 'Should have one empty chunk');
        Assert.areEqual(0, result[0].size(), 'Chunk should be empty');
    }

    @IsTest
    static void testSplitLogsByEvents_WithValidLogs() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest'];
        
        Test.startTest();
        List<Log_Event__e> result = DatabaseUtils.splitLogsByEvents(testLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.size() > 0, 'Should have at least one event');
        
        // Verify events contain valid JSON
        for (Log_Event__e event : result) {
            Assert.areNotEqual(null, event.Body__c, 'Event body should not be null');
            Assert.areNotEqual('', event.Body__c, 'Event body should not be empty');
        }
    }

    @IsTest
    static void testSplitLogsByEvents_WithEmptyList() {
        List<Log__c> emptyLogs = new List<Log__c>();
        
        Test.startTest();
        List<Log_Event__e> result = DatabaseUtils.splitLogsByEvents(emptyLogs);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        // splitLogs always creates one chunk (even empty), so splitLogsByEvents creates one event
        Assert.areEqual(1, result.size(), 'Should have one event for empty list (empty chunk)');
        
        // Verify the event contains empty JSON array
        Assert.areNotEqual(null, result[0].Body__c, 'Event body should not be null');
        Assert.areEqual('[]', result[0].Body__c, 'Event body should contain empty JSON array');
    }

    @IsTest
    static void testPublishLogEvent_WithValidLogs() {
        List<Log__c> testLogs = [SELECT Id FROM Log__c WHERE Category__c = 'DatabaseUtilsTest'];
        
        Test.startTest();
        DatabaseUtils.publishLogEvent(testLogs);
        Test.stopTest();
        
        // This test verifies the method executes without throwing exceptions
        // The actual publishing is tested by the platform event system
        Assert.isTrue(true, 'Method should execute without exceptions');
    }

    @IsTest
    static void testGetCurrentJobs_WithValidClassNames() {
        List<String> classNames = new List<String>{'TestBatchClass'};
        
        Test.startTest();
        List<AsyncApexJob> result = DatabaseUtils.getCurrentJobs(classNames);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        // Result size depends on actual running jobs, so we just verify it's not null
    }

    @IsTest
    static void testGetCurrentJobs_WithEmptyList() {
        List<String> emptyClassNames = new List<String>();
        
        Test.startTest();
        List<AsyncApexJob> result = DatabaseUtils.getCurrentJobs(emptyClassNames);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Should return empty list for empty input');
    }

    @IsTest
    static void testGetSumTotalJobItems() {
        Test.startTest();
        Integer result = DatabaseUtils.getSumTotalJobItems();
        Test.stopTest();
        
        // Result can be null if there are no batch jobs, which is valid
        Assert.isTrue(result == null || result >= 0, 'Result should be null or non-negative');
    }

    @IsTest
    static void testExecuteBatchWithLimitCheck_WithSingleJobName() {
        // Create a mock batch instance
        DatabaseUtils.PharosBatchImpl mockBatch = new DatabaseUtils.PharosBatchImpl();
        mockBatch.BATCH_SCOPE = 1;
        
        Test.startTest();
        Boolean result = DatabaseUtils.executeBatchWithLimitCheck('TestJob', mockBatch);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        // Result depends on various conditions, so we just verify it's not null
    }

    @IsTest
    static void testExecuteBatchWithLimitCheck_WithMultipleJobNames() {
        // Create a mock batch instance
        DatabaseUtils.PharosBatchImpl mockBatch = new DatabaseUtils.PharosBatchImpl();
        mockBatch.BATCH_SCOPE = 1;
        
        List<String> jobNames = new List<String>{'TestJob1', 'TestJob2'};
        
        Test.startTest();
        Boolean result = DatabaseUtils.executeBatchWithLimitCheck(jobNames, mockBatch);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        // Result depends on various conditions, so we just verify it's not null
    }

    @IsTest
    static void testExecuteBatchWithLimitCheck_WithNullJobNames() {
        // Create a mock batch instance
        DatabaseUtils.PharosBatchImpl mockBatch = new DatabaseUtils.PharosBatchImpl();
        
        Test.startTest();
        Boolean result = DatabaseUtils.executeBatchWithLimitCheck((List<String>)null, mockBatch);
        Test.stopTest();
        
        Assert.areEqual(false, result, 'Should return false for null job names');
    }

    @IsTest
    static void testExecuteBatchWithLimitCheck_WithEmptyJobNames() {
        // Create a mock batch instance
        DatabaseUtils.PharosBatchImpl mockBatch = new DatabaseUtils.PharosBatchImpl();
        
        List<String> emptyJobNames = new List<String>();
        
        Test.startTest();
        Boolean result = DatabaseUtils.executeBatchWithLimitCheck(emptyJobNames, mockBatch);
        Test.stopTest();
        
        Assert.areEqual(false, result, 'Should return false for empty job names');
    }

    @IsTest
    static void testPharosBatchImpl_Constructor() {
        Test.startTest();
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        Test.stopTest();
        
        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(1, batch.BATCH_SCOPE, 'Default batch scope should be 1');
        Assert.areEqual(false, batch.isForceStart, 'Default isForceStart should be false');
    }

    @IsTest
    static void testPharosBatchImpl_ConstructorWithLogger() {
        Logger testLogger = Logger.getInstance();
        
        Test.startTest();
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl(testLogger);
        Test.stopTest();
        
        Assert.areNotEqual(null, batch, 'Batch instance should not be null');
        Assert.areEqual(testLogger, batch.loggerInstance, 'Logger instance should be set');
    }

    @IsTest
    static void testPharosBatchImpl_ForceStartBatch() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        
        Test.startTest();
        batch.forceStartBatch();
        Test.stopTest();
        
        Assert.areEqual(true, batch.isForceStart, 'isForceStart should be true after force start');
    }

    @IsTest
    static void testPharosBatchImpl_InitialValidation() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        
        Test.startTest();
        Boolean result = batch.initialValidation();
        Test.stopTest();
        
        Assert.areEqual(true, result, 'Default initial validation should return true');
    }

    @IsTest
    static void testPharosBatchImpl_GetIterationsCount() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        
        Test.startTest();
        Integer result = batch.getIterationsCount();
        Test.stopTest();
        
        Assert.areEqual(0, result, 'Default iterations count should be 0');
    }

    @IsTest
    static void testPharosBatchImpl_GetJobId() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        batch.jobId = 'TestJobId';
        
        Test.startTest();
        String result = batch.getJobId();
        Test.stopTest();
        
        Assert.areEqual('TestJobId', result, 'Should return set job ID');
    }

    @IsTest
    static void testPharosBatchImpl_SetSchedulerInstance() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        LogServiceScheduler mockScheduler = new LogServiceScheduler();
        
        Test.startTest();
        batch.setSchedulerInstance(mockScheduler);
        Test.stopTest();
        
        Assert.areEqual(mockScheduler, batch.schedulerInstance, 'Scheduler instance should be set');
    }

    @IsTest
    static void testPharosBatchImpl_IsExecutionTime() {
        DatabaseUtils.PharosBatchImpl batch = new DatabaseUtils.PharosBatchImpl();
        
        Test.startTest();
        Boolean result = batch.isExecutionTime('TestJob');
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        // Result depends on current time and job configuration
    }

    @IsTest
    static void testDatabaseUtilsException() {
        Test.startTest();
        try {
            throw new DatabaseUtils.DatabaseUtilsException('Test exception');
        } catch (DatabaseUtils.DatabaseUtilsException e) {
            Assert.areEqual('Test exception', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
}