@IsTest
private class SystemOverviewControllerTest {

	@TestSetup
	private static void testSetup() {
		TestDataFactory.createConnectedOrg();
	}

	@IsTest
	private static void test_getOrgInfo() {
		Test.startTest();
		Organization org = SystemOverviewController.getOrgInfo();
		Test.stopTest();
		System.assertNotEquals(null, org);
	}

	@IsTest
	private static void test_getUsersInfo() {
		Test.startTest();
		SystemOverviewController.UsersInfo usersInfo = SystemOverviewController.getUsersInfo();
		Test.stopTest();
		System.assertNotEquals(null, usersInfo);
		System.assertNotEquals(null, usersInfo.numberOfActiveUsers);
		System.assertNotEquals(null, usersInfo.numberOfNoActivityInLast30Days);
		System.assertNotEquals(null, usersInfo.numberOfUsers);
		System.assertNotEquals(null, usersInfo.numberOfInactiveUsers);
	}

	@IsTest
	private static void test_getSystemOrgLimits() {
		Test.startTest();
		List<SystemOverviewController.ChartDataPercentage> systemOrgLimits = SystemOverviewController.getSystemOrgLimits();
		Test.stopTest();
		System.assertNotEquals(null, systemOrgLimits);
	}

	@IsTest
	private static void test_getUsersInfoDetails() {
		Test.startTest();
		List<SystemOverviewController.ChartDataCount> chartDataCounts = SystemOverviewController.getUsersInfoDetails();
		Test.stopTest();
		System.assertNotEquals(null, chartDataCounts);
	}

	@IsTest
	private static void test_getNameSpacePrefix() {
		Test.startTest();
		String namespace = SystemOverviewController.getNameSpacePrefix();
		Test.stopTest();
		System.assertNotEquals(null, namespace);
	}

	@IsTest
	private static void test_getSensitivePermissions() {
		Test.startTest();
		List<SystemOverviewController.ChartDataCount> sensitivePermissions = SystemOverviewController.getSensitivePermissions();
		Test.stopTest();
		System.assertNotEquals(null, sensitivePermissions);
	}

	@IsTest
	private static void test_getObjectAPINames() {
		Test.startTest();
		List<String> objectAPINames = SystemOverviewController.getObjectAPINames();
		Test.stopTest();
		System.assertNotEquals(null, objectAPINames);
		System.assert(!objectAPINames.isEmpty());
	}

	@IsTest
	private static void test_getRecordCounts() {
		Test.startTest();
		List<String> objectAPINames = new List<String>{'Account', 'Contact'};
		List<SystemOverviewController.RecordCount> recordCounts = SystemOverviewController.getRecordCounts(objectAPINames);
		Test.stopTest();
		System.assertNotEquals(null, recordCounts);
	}

	@IsTest
	private static void test_getObjectInfo() {
		Test.startTest();
		List<SystemOverviewController.ObjectInfo> objectInfos = SystemOverviewController.getObjectInfo();
		Test.stopTest();
		System.assertNotEquals(null, objectInfos);
		System.assert(!objectInfos.isEmpty());
	}

	@IsTest
	private static void test_getObjectInfoDetails() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String workflowQuery = 'SELECT TableEnumOrId, COUNT(Id) cnt FROM WorkflowRule WHERE TableEnumOrId IN (\'Account\') GROUP BY TableEnumOrId';
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(workflowQuery, 'UTF-8'), getWorkflowRulesMock());

		List<SystemOverviewController.ObjectInfo> objectInfos = new List<SystemOverviewController.ObjectInfo>();
		SystemOverviewController.ObjectInfo info = new SystemOverviewController.ObjectInfo();
		info.name = 'Account';
		objectInfos.add(info);

		Test.startTest();
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		List<SystemOverviewController.ObjectInfo> result = SystemOverviewController.getObjectInfoDetails(objectInfos);
		Test.stopTest();

		System.assertNotEquals(null, result);
		System.assertEquals(1, result.size(), 'Should return details for one object');
	}

	private static TestDataFactory.SingleRequestMock getWorkflowRulesMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"size":1,"totalSize":1,"done":true,"records":[{"TableEnumOrId":"Account","cnt":2}]}'
		);
		return singleRequestMock;
	}


	@IsTest
	private static void test_getOrgAtAGlance() {
		Test.startTest();
		SystemOverviewController.OrgAtAGlance orgAtAGlance = SystemOverviewController.getOrgAtAGlance();
		Test.stopTest();
		System.assertNotEquals(null, orgAtAGlance);
		System.assertNotEquals(null, orgAtAGlance.orgAge);
	}

	@IsTest
	private static void test_getLicenses() {
		Test.startTest();
		List<SystemOverviewController.ChartDataPercentage> licenses = SystemOverviewController.getLicenses();
		Test.stopTest();
		System.assertNotEquals(null, licenses);
	}

	@IsTest
	private static void test_getCodeInfo() {
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String queryLWC = String.format(SystemOverviewController.CODE_INFO_QUERY, new List<String>{'LightningComponentBundle'});
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(queryLWC, 'UTF-8'), getLightningComponentBundle());
		String queryFlow = String.format(SystemOverviewController.CODE_INFO_QUERY, new List<String>{'FlowDefinition'});
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(queryFlow, 'UTF-8'), getFlowDefinition());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		List<SystemOverviewController.CodeInfo> lstCodeInfo = SystemOverviewController.getCodeInfo();
		Test.stopTest();
		System.assertNotEquals(null, lstCodeInfo);
	}

	@IsTest
	private static void test_getCodeInfoDetails() {
		Test.startTest();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		String queryLWC = String.format(SystemOverviewController.CODE_INFO_DETAILS_LIGHTNING_QUERY, new List<String>{'LightningComponentBundle'});
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(queryLWC, 'UTF-8'), getLightningComponentBundleDetails());
		String queryFlow = SystemOverviewController.CODE_INFO_DETAILS_FLOW_QUERY;
		endpoint2TestResp.put('https://test_Instance_Url' + ConfigUtil.TOOLING_QUERY_API_ENDPOINT + EncodingUtil.urlEncode(queryFlow, 'UTF-8'), getFlowDefinitionDetails());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		for (String objectName : SystemOverviewController.CODE_INFO_OBJECTS_MAP.keySet()) {
			List<SystemOverviewController.CodeInfoDetail> codeInfoDetails = SystemOverviewController.getCodeInfoDetails(objectName);
			System.assertNotEquals(null, codeInfoDetails);
		}
		Test.stopTest();
	}

	private static TestDataFactory.SingleRequestMock getLightningComponentBundle() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"AggregateResult","records":[{"attributes":{"type":"AggregateResult"},"count_id":5,"namespacePrefix":"test"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getLightningComponentBundleDetails() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"LightningComponentBundle","records":[{"attributes":{"type":"LightningComponentBundle","url":"/services/data/v56.0/tooling/sobjects/LightningComponentBundle/0Rb5x000001PpppXXX"},"MasterLabel":"test","ApiVersion":56.0,"NamespacePrefix":"test"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getFlowDefinition() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"AggregateResult","records":[{"attributes":{"type":"AggregateResult"},"count_id":10,"namespacePrefix":"test"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getFlowDefinitionDetails() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"size":15,"totalSize":15,"done":true,"queryLocator":null,"entityTypeName":"AggregateResult","records":[{"attributes":{"type":"AggregateResult","url":"/services/data/v56.0/tooling/sobjects/AggregateResult/3005e000001Pp7FXXX"},"MasterLabel":"test","ApiVersion":56.0,"Id":"3005e000001Pp7FXXX","NamespacePrefix":"test"}]}'
		);
		return singleRequestMock;
	}

}