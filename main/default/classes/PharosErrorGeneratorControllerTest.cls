@IsTest
private class PharosErrorGeneratorControllerTest {

    @IsTest
    static void test_getErrors() {
        List<String> errors = PharosErrorGeneratorController.getErrors();
        Assert.isFalse(errors.isEmpty());
    }

    @IsTest
    static void test_getLog() {
        String strDatetime = String.valueOfGmt(System.now());
        petriv__Log__c log = new petriv__Log__c();
        log.petriv__Category__c = PharosErrorGeneratorController.FLOW_ERROR_CATEGORY;
        insert log;

        Assert.isFalse(new List<petriv__Log__c>{ PharosErrorGeneratorController.getLog(PharosErrorGeneratorController.FLOW_1_ERROR, strDatetime) }.isEmpty());
    }

    @IsTest
    static void test_generateError_flow_1() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.FLOW_1_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_flow_2() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.FLOW_2_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_processBuilder() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.PROCESS_BUILDER_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_apex() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.APEX_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_integration() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.INTEGRATION_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_restApi() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.REST_API_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_asyncApexJob() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.ASYNC_JOB_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_bulk_api_v1() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.BULK_API_V1_ERROR);
            Test.stopTest();
        } catch (Exception e) {}

        Assert.isTrue(String.isNotBlank(strDatetime));
    }

    @IsTest
    static void test_generateError_bulk_api_v2() {
        String strDatetime;
        try {
            Test.startTest();
                strDatetime = PharosErrorGeneratorController.generateError(PharosErrorGeneratorController.BULK_API_V2_ERROR);
            Test.stopTest();
        } catch (Exception e) {}
        
        Assert.isTrue(String.isNotBlank(strDatetime));
    }
}