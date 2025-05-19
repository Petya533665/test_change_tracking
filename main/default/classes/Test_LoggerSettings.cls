@isTest
private class Test_LoggerSettings {

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createConnectedOrgSettings();
        TestDataFactory.createConnectedOrg();
    }

    @IsTest
    private static void test_generateTokenForConnectedOrg_positive() {
        LoggerSettingsController loggerSettingsController = new LoggerSettingsController();
        test_generateTokenForConnectedOrg(false, true);
    }

    @IsTest
    private static void test_generateTokenForConnectedOrg_negative() {
        LoggerSettingsController loggerSettingsController = new LoggerSettingsController();
        test_generateTokenForConnectedOrg(false, false);
    }

    @IsTest
    private static void test_generateTokenForConnectedOrg_sandbox_positive() {
        LoggerSettingsController loggerSettingsController = new LoggerSettingsController();
        test_generateTokenForConnectedOrg(true, true);
    }

    private static void test_generateTokenForConnectedOrg(Boolean isSandbox, Boolean isPositive) {
        Test.startTest();
        String loginUrl = isSandbox ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(loginUrl + '/services/oauth2/token', generateTokenMock());
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.setMock(WebServiceMock.class, new TestDataFactory.WebServiceMockImpl());
        ConnectedOrgService.StateDTO stateDTO = new ConnectedOrgService.StateDTO();
        if (isPositive) {
            stateDTO.code = UserInfo.getOrganizationId().left(15);
            stateDTO.loginUrl = loginUrl;
        }
        String output = LoggerSettingsController.generateTokenForConnectedOrg('{"code":"test_code","state":' + JSON.serialize(stateDTO) + ',"redirectUrl":"test_return_url"}');
        Test.stopTest();
        Map<String, Object> mapOutput = (Map<String, Object>)JSON.deserializeUntyped(output);
        if (isPositive) {
            System.assertEquals('ok', mapOutput.get('status'));
        } else {
            System.assertEquals('error', mapOutput.get('status'));
        }
    }

    private static TestDataFactory.SingleRequestMock generateTokenMock() {
        ConnectedOrgService.AuthTokenResponse authTokenResponse = new ConnectedOrgService.AuthTokenResponse();
        authTokenResponse.id = UserInfo.getOrganizationId() + '/test/test/test/' + UserInfo.getOrganizationId();
        authTokenResponse.access_token = 'test_access_token';
        authTokenResponse.refresh_token = 'test_refresh_token';
        authTokenResponse.instance_url = 'test_instance_url';
        TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
                200,
                'OK',
                JSON.serialize(authTokenResponse)
        );
        return singleRequestMock;
    }

}