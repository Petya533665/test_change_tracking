@IsTest
public with sharing class PharosErrorGeneratorBatchTest {
    
    @IsTest
    static void test_withThrowException() {
        Exception expetctedException;
        
        try {
            Test.startTest();
                Database.executeBatch(new PharosErrorGeneratorBatch(true));
            Test.stopTest();
        } catch (Exception e) {
            expetctedException = e;
        }

        Assert.isNotNull(expetctedException);
        Assert.areEqual(PharosErrorGeneratorBatch.THROW_EXCEPTION_MESSAGE, expetctedException.getMessage());
    }

    @IsTest
    static void test_withoutThrowException() {
        // Need to create to cover lines
        insert new Triton_Error_Data__c();

        Test.startTest();
            Id jobId = Database.executeBatch(new PharosErrorGeneratorBatch(false));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId];
        Assert.areEqual(1, jobs.size());
        Assert.areEqual('Completed', jobs[0].Status);
    }
}