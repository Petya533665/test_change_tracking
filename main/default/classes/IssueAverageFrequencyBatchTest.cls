@IsTest
private class IssueAverageFrequencyBatchTest {
    @TestSetup
    private static void testSetup() {
        Issue__c issue = new Issue__c();
        insert issue;

        Log__c first_log = new Log__c();
        first_log.Created_At__c = System.now().addDays(-5);
        first_log.Issue__c = issue.Id;
        insert first_log;

        Log__c second_log = new Log__c();
        second_log.Created_At__c = System.now().addDays(-5);
        second_log.Issue__c = issue.Id;
        insert second_log;

        Log__c third_log = new Log__c();
        third_log.Created_At__c = System.now();
        third_log.Issue__c = issue.Id;
        insert third_log;

        Log__c fourth_log = new Log__c();
        fourth_log.Created_At__c = System.now();
        fourth_log.Issue__c = issue.Id;
        insert fourth_log;
    }

    @IsTest
    private static void test_batch() {
        Test.startTest();
        IssueAverageFrequencyBatch.getInstance(null).forceStartBatch();
        Test.stopTest();
        System.assertEquals(2.50, [SELECT Id, Average_Frequency__c FROM Issue__c][0].Average_Frequency__c);
        System.assertEquals(2, [SELECT Id, Average_Daily_Volume__c FROM Issue__c][0].Average_Daily_Volume__c);
    }
}