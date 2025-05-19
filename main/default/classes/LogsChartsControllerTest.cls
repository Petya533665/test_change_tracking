@IsTest
private class LogsChartsControllerTest {

    @TestSetup
    private static void testSetup() {
        Log__c log = new Log__c();
        log.Hash_1__c = 'test_hash1';
        log.Hash_2__c = 'test_hash2';
        log.Hash_3__c = 'test_hash3';
        insert log;
    }

    @IsTest
    private static void test_LogsChartsWrapperController() {
        List<Log__c> lstLogs = [SELECT Id FROM Log__c];
        if (!lstLogs.isEmpty()) {
            PageReference pageReference = Page.LogsChartsWrapper;
            Test.setCurrentPage(pageReference);
            pageReference.getParameters().put('recordId', String.valueOf(lstLogs[0].Id));
            ApexPages.StandardController standardController = new  ApexPages.StandardController(lstLogs[0]);
            LogsChartsWrapperController logsChartsWrapperController = new LogsChartsWrapperController(standardController);
        }
    }

    @IsTest
    private static void test_LogsChartsController() {
        List<Log__c> lstLogs = [SELECT Id FROM Log__c];
        if (!lstLogs.isEmpty()) {
            PageReference pageReference = Page.LogsChartsWrapper;
            Test.setCurrentPage(pageReference);
            pageReference.getParameters().put('recordId', String.valueOf(lstLogs[0].Id));
            ApexPages.StandardController standardController = new  ApexPages.StandardController(lstLogs[0]);
            LogsChartsWrapperController logsChartsController = new LogsChartsWrapperController(standardController);
        }
    }

    @IsTest
    private static void test_remoteActionHandler() {
        List<Log__c> lstLogs = [SELECT Id FROM Log__c];
        if (!lstLogs.isEmpty()) {
            test_remoteActionHandler('{"method":"get_test_logs","data":{"showDays":7,"logId":"test_bad_id"}}', false);
            test_remoteActionHandler('{"method":"getOccurrenceLogs","data":{"showDays":7,"logId":"test_bad_id"}}', true);
            test_remoteActionHandler('{"method":"getOccurrenceLogs","data":{"showDays":1,"logId":"' + lstLogs[0].Id + '"}}', true);
            test_remoteActionHandler('{"method":"getOccurrenceLogs","data":{"showDays":7,"logId":"' + lstLogs[0].Id + '"}}', true);
            test_remoteActionHandler('{"method":"getTimingLogs","data":{"showRange":1,"logId":"' + lstLogs[0].Id + '"}}', true);
            test_remoteActionHandler('{"method":"getTimingLogs","data":{"showRange":10,"logId":"' + lstLogs[0].Id + '"}}', true);
        }
    }

    private static void test_remoteActionHandler(String input, Boolean isPositive) {
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(LogsChartsWrapperController.remoteActionHandler(input));
        if (isPositive) {
            System.assertEquals(true, response.get('data') != null);
            System.assertEquals(false, String.isNotBlank((String)response.get('error')));
        } else {
            System.assertEquals(true, String.isNotBlank((String)response.get('error')));
        }
    }

}