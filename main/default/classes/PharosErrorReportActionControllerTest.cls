@IsTest
public with sharing class PharosErrorReportActionControllerTest {

    @TestSetup
    static void makeData() {
        String orgID = UserInfo.getOrganizationId().left(15);
        Log__c log = new Log__c();
        log.Hash_1__c = 'hash1';
        log.Hash_2__c = 'hash2';
        log.Hash_3__c = 'hash3';
        log.Organization_Id__c = orgID;

        insert log;

        Log_Index__c logIndex = getLogIndex();
        ErrorEmailReportBatch.setReported(new List<Log_Index__c>{ logIndex }, Logger.getInstance());
    }

    @IsTest
    static void test_isAvailableSingleEmail() {
        Boolean result;
        Test.startTest();
            result = PharosErrorReportActionController.isAvailableSingleEmail();
        Test.stopTest();

        Assert.isTrue(result, 'Single email should be available');
    }

    @IsTest
    static void test_getReportedInfo() {
        Log__c log = getLog();
        Log_Index__c logIndex = getLogIndex();

        Map<String, Object> result;
        Test.startTest();
            result = PharosErrorReportActionController.getReportedInfo(log.Id);
        Test.stopTest();

        Assert.isTrue(result != null && !result.isEmpty(), 'Reported info should not be null or empty');
        
        Datetime reportedToPharosOn = (Datetime) result.get(PharosErrorReportActionController.KEY_REPORTED_TO_PHAROS_ON);
        String createdByName = (String) result.get(PharosErrorReportActionController.KEY_CREATED_BY_NAME);
        
        Assert.isTrue(reportedToPharosOn != null, 'The ' + PharosErrorReportActionController.KEY_REPORTED_TO_PHAROS_ON + ' should not be null');
        Assert.areEqual(logIndex.Reported_to_Pharos_On__c, reportedToPharosOn, 'The ' + PharosErrorReportActionController.KEY_REPORTED_TO_PHAROS_ON + ' does not match');

        Assert.isTrue(String.isNotBlank(createdByName), 'The ' + PharosErrorReportActionController.KEY_CREATED_BY_NAME + ' should not be null or empty');
        Assert.areEqual(logIndex.CreatedBy.Name, createdByName, 'The ' + PharosErrorReportActionController.KEY_CREATED_BY_NAME + ' does not match');
    }
    
    @IsTest
    static void test_getErrorEmailAddress() {
        String result;
        Test.startTest();
            result = PharosErrorReportActionController.getErrorEmailAddress();
        Test.stopTest();

        Assert.isTrue(String.isNotBlank(result), 'The email should not be blank');
        Assert.areEqual(ErrorEmailReportBatch.PHAROS_ERROR_EMAIL_ADDRESS, result, 'Error email does not match');
    }

    @IsTest
    static void test_getTotalOccurrences_WithExistingLog() {
        Log__c log = getLog();

        Integer result;
        Test.startTest();
            result = PharosErrorReportActionController.getTotalOccurrences(log.Id);
        Test.stopTest();

        Assert.areEqual(1, result, 'Total Occurrences do not match');
    }

    @IsTest
    static void test_getTotalOccurrences_WithNotExistingLog() {
        Integer result;
        Test.startTest();
            result = PharosErrorReportActionController.getTotalOccurrences(TestDataFactory.getFakeIds(Log__c.SObjectType, 1).get(0));
        Test.stopTest();

        Assert.areEqual(0, result, 'Total Occurrences do not match');
    }

    @IsTest
    static void test_sendPharosErrorReport() {
        Log__c log = getLog();
        Log_Index__c logIndexBefore = getLogIndex();

        Test.startTest();
            PharosErrorReportActionController.sendPharosErrorReport(log.Id, 'test_summary', 'test_details', 'test_comments');
        Test.stopTest();

        Log_Index__c logIndexAfter = getLogIndex();

        Assert.areNotEqual(null, logIndexAfter, 'Log index should still exist after method execution');
        
        Log__c originalLog = [SELECT Id, Summary__c, Details__c FROM Log__c WHERE Id = :log.Id];
        Assert.areNotEqual(null, originalLog, 'Original log should still exist');
    }

    private static Log__c getLog() {
        return [SELECT Id FROM Log__c];
    }

    private static Log_Index__c getLogIndex() {
        return [SELECT Reported_to_Pharos_On__c, CreatedBy.Name FROM Log_Index__c];
    }
}