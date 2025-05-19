@IsTest
private class BulkAPIJobBatchTest {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrg();
    }

    private static final String GET_ALL_JOBS_ENDPOINT_BULK_API_V1 = 'https://test_Instance_Url/services/data/v54.0/jobs/ingest';
    private static final String GET_JOBS_ENDPOINT_BULK_API_V1 = 'https://test_Instance_Url/services/data/v54.0/jobs/ingest/{0}';
    private static final String GET_BATCHES_ENDPOINT_BULK_API_V1 = 'https://test_Instance_Url/services/async/52.0/job/{0}/batch';
    private static final String GET_BATCH_RESULT_ENDPOINT_BULK_API_V1 = 'https://test_Instance_Url/services/async/52.0/job/{0}/batch/testBatchId/result';
    private static final String GET_BATCH_REQUEST_ENDPOINT_BULK_API_V1 = 'https://test_Instance_Url/services/async/52.0/job/{0}/batch/testBatchId/request';

    private static final String GET_ALL_JOBS_ENDPOINT_BULK_API_V2 = 'https://test_Instance_Url/services/data/v54.0/jobs/ingest';
    private static final String GET_JOBS_ENDPOINT_BULK_API_V2 = 'https://test_Instance_Url/services/data/v54.0/jobs/ingest/{0}';
    private static final String GET_FAILED_RESULTS_ENDPOINT_BULK_API_V2 = 'https://test_Instance_Url/services/data/v52.0/jobs/ingest/{0}/failedResults';

    @IsTest
    private static void test_bulk_api_v1_xml() {
        test_bulk_api_v1(TestDataGenerator.TEST_JOB_ID, 'XML', 'Classic');
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
        System.assertEquals(2, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    @IsTest
    private static void test_bulk_api_v1_json() {
        test_bulk_api_v1(TestDataGenerator.TEST_JOB_ID, 'JSON', 'Classic');
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
        System.assertEquals(2, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    @IsTest
    private static void test_bulk_api_v1_csv() {
        test_bulk_api_v1(TestDataGenerator.TEST_JOB_ID, 'CSV', 'Classic');
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
        System.assertEquals(2, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    @IsTest
    private static void test_bulk_api_v1_csv_failed_mid_execute() {
        test_bulk_api_v1(TestDataGenerator.TEST_1_JOB_ID, 'CSV', 'Classic');
        System.assertEquals(2, [SELECT Id FROM Log__c].size());
        System.assertEquals(3, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(3, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(3, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    @IsTest
    private static void test_bulk_api_v1_xml_failed_last_execute() {
        test_bulk_api_v1(TestDataGenerator.TEST_2_JOB_ID, 'XML', 'Classic');
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
        System.assertEquals(2, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    @IsTest
    private static void test_bulk_api_v2_csv() {
        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(GET_ALL_JOBS_ENDPOINT_BULK_API_V2, getAllJobsMock(TestDataGenerator.TEST_JOB_ID, 'CSV', 'V2Ingest'));
        endpoint2TestResp.put(String.format(GET_JOBS_ENDPOINT_BULK_API_V2, new List<String>{TestDataGenerator.TEST_JOB_ID}), getJobsMock(TestDataGenerator.TEST_JOB_ID, 'CSV', 'V2Ingest'));
        endpoint2TestResp.put(String.format(GET_FAILED_RESULTS_ENDPOINT_BULK_API_V2, new List<String>{TestDataGenerator.TEST_JOB_ID}), getJobFailedRecordResultsCSVMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        BulkAPIJobBatchScheduler.getInstance(null).forceStartBatch();
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
        System.assertEquals(2, [SELECT Id FROM ContentVersion].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocument].size());
        System.assertEquals(2, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Log__c)].size());
    }

    private static void test_bulk_api_v1(String jobId, String contentType, String jobType) {
        Test.startTest();
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(GET_ALL_JOBS_ENDPOINT_BULK_API_V1, getAllJobsMock(jobId, contentType, jobType));
        endpoint2TestResp.put(String.format(GET_JOBS_ENDPOINT_BULK_API_V1, new List<String>{jobId}), getJobsMock(jobId, contentType, jobType));
        endpoint2TestResp.put(String.format(GET_BATCHES_ENDPOINT_BULK_API_V1, new List<String>{jobId}), contentType == 'JSON' ? getBatchesJSONMock() : getBatchesXMLMock(jobId));
        endpoint2TestResp.put(String.format(GET_BATCH_RESULT_ENDPOINT_BULK_API_V1, new List<String>{jobId}), getBatchResult(contentType));
        endpoint2TestResp.put(String.format(GET_BATCH_REQUEST_ENDPOINT_BULK_API_V1, new List<String>{jobId}), getBatchRequest(contentType));
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        BulkAPIJobBatchScheduler.getInstance(null).forceStartBatch();
        Test.stopTest();
    }

    private static TestDataFactory.SingleRequestMock getBatchResult(String contentType) {
        TestDataFactory.SingleRequestMock singleRequestMock;
        switch on contentType {
            when 'CSV' {
                singleRequestMock = getBatchResultCSVMock();
            }
            when 'JSON' {
                singleRequestMock = getBatchResultJSONMock();
            }
            when 'XML' {
                singleRequestMock = getBatchResultXMLMock();
            }
        }
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchRequest(String contentType) {
        TestDataFactory.SingleRequestMock singleRequestMock;
        switch on contentType {
            when 'CSV' {
                singleRequestMock = getBatchRequestCSVMock();
            }
            when 'JSON' {
                singleRequestMock = getBatchRequestJSONMock();
            }
            when 'XML' {
                singleRequestMock = getBatchRequestXMLMock();
            }
        }
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getAllJobsMock(String jobId, String contentType, String jobType) {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{' +
                        '"done":true,' +
                        '"records":' +
                        '[' +
                        '{' +
                        '"id":"' + jobId + '",' +
                        '"operation":"insert",' +
                        '"object":"Lead",' +
                        '"state":"Closed",' +
                        '"contentType":"' + contentType + '",' +
                        '"apiVersion":52.0,' +
                        '"jobType":"' + jobType + '",' +
                        '"systemModstamp":' + JSON.serialize(System.now()) +
                        '}' +
                        '],' +
                        '"nextRecordsUrl":null' +
                        '}'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getJobsMock(String jobId, String contentType, String jobType) {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{' +
                        '"id":"' + jobId + '",' +
                        '"operation":"insert",' +
                        '"object":"Lead",' +
                        '"state":"Closed",' +
                        '"contentType":"' + contentType + '",' +
                        '"apiVersion":52.0,' +
                        '"jobType":"' + jobType + '",' +
                        '"numberRecordsProcessed":1,' +
                        '"numberRecordsFailed":1' +
                        '}'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchesXMLMock(String jobId) {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '<?xml version="1.0" encoding="UTF-8"?>' +
                        '<batchInfoList xmlns="http://www.force.com/2009/06/asyncapi/dataload">' +
                        '<batchInfo>' +
                        '<id>testBatchId</id>' +
                        '<jobId>' + jobId + '</jobId>' +
                        '<state>Completed</state>' +
                        '<numberRecordsProcessed>1</numberRecordsProcessed>' +
                        '<numberRecordsFailed>1</numberRecordsFailed>' +
                        '</batchInfo>' +
                        '</batchInfoList>'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchResultXMLMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '<?xml version="1.0" encoding="UTF-8"?>' +
                        '<results xmlns="http://www.force.com/2009/06/asyncapi/dataload">' +
                        '<result>' +
                        '<errors>' +
                        '<message>Industry cannot be blank!</message>' +
                        '<statusCode>FIELD_CUSTOM_VALIDATION_EXCEPTION</statusCode>' +
                        '</errors>' +
                        '<success>false</success>' +
                        '<created>false</created>' +
                        '</result>' +
                        '</results>'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchRequestXMLMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '<?xml version="1.0" encoding="UTF-8"?>' +
                        '<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                        '<sObject>' +
                        '<Status>New</Status>' +
                        '<Industry></Industry>' +
                        '<Company>Test Inc.</Company>' +
                        '<LastName>TestLastName</LastName>' +
                        '<Description>TestDescription</Description>' +
                        '</sObject>' +
                        '</sObjects>'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchesJSONMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '{' +
                        '"batchInfo":' +
                        '[{' +
                        '"id":"testBatchId",' +
                        '"jobId":"testJobId",' +
                        '"numberRecordsFailed":1,' +
                        '"numberRecordsProcessed":1,' +
                        '"state":"Completed"' +
                        '}]' +
                        '}'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchResultJSONMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '[' +
                        '{' +
                        '"success":false,' +
                        '"created":false,' +
                        '"id":null,' +
                        '"errors":' +
                        '[{' +
                        '"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION",' +
                        '"message":"Industry cannot be blank!",' +
                        '"fields":[]' +
                        '}]' +
                        '}' +
                        ']'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchRequestJSONMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '[' +
                        '{' +
                        '"Status":"New",' +
                        '"Industry":"",' +
                        '"Company":"BigLife Inc.",' +
                        '"LastName":"TestLastName",' +
                        '"Description":"TestDescription"' +
                        '}' +
                        ']'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchResultCSVMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '"Id","Success","Created","Error"\n' +
                        '"","false","false","FIELD_CUSTOM_VALIDATION_EXCEPTION:Industry cannot be blank!:--"'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getBatchRequestCSVMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '"Company","Industry","LastName","Status","Description"\n' +
                        '"Test, Inc.",,"TestLastName","New","TestDescription"'
        );
        return singleRequestMock;
    }

    private static TestDataFactory.SingleRequestMock getJobFailedRecordResultsCSVMock() {
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                '"sf__Id","sf__Error","Company","Industry","LastName","Status","Description"\n' +
                        '"","FIELD_CUSTOM_VALIDATION_EXCEPTION:Industry cannot be blank!:--","Test, Inc.",,"TestLastName","New","TestDescription"'
        );
        return singleRequestMock;
    }

}