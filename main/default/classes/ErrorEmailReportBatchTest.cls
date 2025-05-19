@IsTest
private with sharing class ErrorEmailReportBatchTest {

    private static final String TEST_HASH_1 = 'somehash1';
    private static final String TEST_ORG_ID = UserInfo.getOrganizationId().left(15);
    private static final String TEST_AREA = 'Pharos';
    private static final String TEST_CATEGORY = 'Pharos Error';
    private static final String TEST_TYPE = 'TestType';
    private static final String TEST_DETAILS = 'Some test details';

    @IsTest
    private static void testSendReport_positive() {
        testSendReport(true);
    }

    @IsTest
    private static void testSendReport_negative() {
        testSendReport(false);
    }

    private static void testSendReport(Boolean mandatory) {
        ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c = true;
        ConfigUtil.SETTINGS.Error_Report_CC_emails__c = 'email1@test.cc,email2@test.cc';
        upsert ConfigUtil.SETTINGS;

        Log__c log = new Log__c();
        log.Category__c = TEST_CATEGORY;
        log.Type__c = TEST_TYPE;
        log.Area__c = TEST_AREA;
        log.Details__c = TEST_DETAILS;
        log.Hash_1__c = TEST_HASH_1;
        log.Organization_Id__c = TEST_ORG_ID;
        insert log;

        String logKey1 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logKey1});
        ConfigUtil.LogIndex index1 = helper.getLogIndex(TEST_HASH_1, TEST_ORG_ID);

        System.assertEquals(true, index1.internal);

        Test.startTest();
        if (mandatory) {
            enableErrorReporting();
        }
        PermissionsUtil.MandatoryErrorReportingEnabled = mandatory;
        ErrorEmailReportBatch.getInstance(ErrorEmailReportBatch.JobType.UPLOAD_LOG).forceStartBatch();
        Test.stopTest();

        String logKey2 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        ConfigUtil.LogIndexHelper helper2 = new ConfigUtil.LogIndexHelper(new Set<String>{logKey2});
        ConfigUtil.LogIndex index2 = helper2.getLogIndex(TEST_HASH_1, TEST_ORG_ID);
        if (mandatory) {
            System.assertNotEquals(null, index2.reportedToPharosOn);
        } else {
            System.assertEquals(null, index2.reportedToPharosOn);
        }
    }

    @IsTest
    private static void testSendCVReport_positive() {
        testSendCVReport(true);
    }

    @IsTest
    private static void testSendCVReport_negative() {
        testSendCVReport(false);
    }

    private static void testSendCVReport(Boolean mandatory) {
        ConfigUtil.SETTINGS.Error_Reporting_Opt_out__c = true;
        ConfigUtil.SETTINGS.Error_Report_CC_emails__c = 'email1@test.cc,email2@test.cc';
        upsert ConfigUtil.SETTINGS;

        Log__c log = new Log__c();
        log.Category__c = TEST_CATEGORY;
        log.Type__c = TEST_TYPE;
        log.Area__c = TEST_AREA;
        log.Details__c = TEST_DETAILS;
        log.Hash_1__c = TEST_HASH_1;
        log.Organization_Id__c = TEST_ORG_ID;
        insert log;

        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'InboundEmail.json';
        cv.VersionData = Blob.valueOf(JSON.serialize(log));
        cv.Description = 'InboundEmail.json';
        cv.ContentLocation = 'S';
        insert cv;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = log.Id;
        cdl.ShareType = 'V';
        insert cdl;

        String logKey1 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(new Set<String>{logKey1});
        ConfigUtil.LogIndex index1 = helper.getLogIndex(TEST_HASH_1, TEST_ORG_ID);

        System.assertEquals(true, index1.internal);

        Test.startTest();
        if (mandatory) {
            enableErrorReporting();
        }
        PermissionsUtil.MandatoryErrorReportingEnabled = mandatory;
        ErrorEmailReportBatch.getInstance(ErrorEmailReportBatch.JobType.UPLOAD_RELATED_CV).forceStartBatch();
        Test.stopTest();

        String logKey2 = ConfigUtil.getLogIndexKey(TEST_HASH_1, TEST_ORG_ID);
        ConfigUtil.LogIndexHelper helper2 = new ConfigUtil.LogIndexHelper(new Set<String>{logKey2});
        ConfigUtil.LogIndex index2 = helper2.getLogIndex(TEST_HASH_1, TEST_ORG_ID);
        if (mandatory) {
            System.assertNotEquals(null, index2.cvreportedToPharosOn);
        } else {
            System.assertEquals(null, index2.cvreportedToPharosOn);
        }
    }

    private static void enableErrorReporting() {
        Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
            0=>1, 1=>1,	2=>1,
            3=>1, 4=>1,	5=>1,
            6=>1, 7=>1,	8=>1,
            9=>1, 10=>0, 11=>0,
            12=>1, 13=>0, 14=>0,
            15=>0, 16=>0, 17=>1,
            18=>1, 19=>0, 20=>1,
            21=>0, 22=>0, 23=>0,
            24=>1, 25=>0, 26=>0,
            27=>0, 28=>0
        });
        PermissionsUtil.FeatureMap1IntValue = intValue;
    }
}