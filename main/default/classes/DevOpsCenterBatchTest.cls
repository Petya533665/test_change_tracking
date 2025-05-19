@IsTest
private class DevOpsCenterBatchTest {

	private static final String TEST_DEPLOY_RESULT = '[{"status":"Succeeded","startDate":null,"runTestsEnabled":null,"numberComponentsTotal":null,"numberComponentsDeployed":null,"numberComponentErrors":null,"id":"0Af5e00000XXXXXXX","createdByName":null,"createdBy":null,"completedDate":"2023-04-18T15:56:42.000Z"}]';
	private static final String TEST_DEVOPS_ORG_ID = '00D5e0000019jHHEAY';

	@TestSetup
	private static void testSetup() {
		TestDataFactory.createConnectedOrg();
		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
		corg.Name = TEST_DEVOPS_ORG_ID;
		corg.Title__c = ConnectedOrgService.DEFAULT_DEVOPS_ORG_NAME;
		update corg;
	}

	@IsTest
	private static void test_dev_ops_center_bundle() {
		Test.startTest();
		Connected_Org__c corg = ConnectedOrgService.getDevOpsCenterConnectedOrg();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getDeploymentResultQuery(new Set<String>{'0Af5e00000XXXXXXX'}), 'UTF-8'), getDeploymentResultChangeBundleMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getMergeResultQuery(new Set<String>{'a0ADp000000XXXXXXX'}), 'UTF-8'), getMergeResultMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getWorkItemQuery(new Set<String>(), new Set<String>{'a04Dp000000XXXXXXX'}), 'UTF-8'), getWorkItemBundleMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getProjectQuery(new Set<String>{'a0EDp000000XXXXXXX'}), 'UTF-8'), getProjectMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		Log__c log = new Log__c();
		log.Deploy_Results__c = TEST_DEPLOY_RESULT;
		insert log;

		Issue__c issue = new Issue__c();
		issue.Log__c = log.Id;
		insert issue;

		Test.stopTest();
	}

	@IsTest
	private static void test_dev_ops_center() {
		Test.startTest();
		Connected_Org__c corg = ConnectedOrgService.getDevOpsCenterConnectedOrg();
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getDeploymentResultQuery(new Set<String>{'0Af5e00000XXXXXXX'}), 'UTF-8'), getDeploymentResultMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getMergeResultQuery(new Set<String>{'a0ADp000000XXXXXXX'}), 'UTF-8'), getMergeResultMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getWorkItemQuery(new Set<String>{'a0LDp00000XXXXXXX', 'a0LDp00000XXXXPPP'}, new Set<String>()), 'UTF-8'), getWorkItemMock());
		endpoint2TestResp.put(corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(DevOpsCenterBatch.getProjectQuery(new Set<String>{'a0EDp000000XXXXXXX'}), 'UTF-8'), getProjectMock());
		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		Log__c log = new Log__c();
		log.Deploy_Results__c = TEST_DEPLOY_RESULT;
		insert log;

		Issue__c issue = new Issue__c();
		issue.Log__c = log.Id;
		insert issue;

		Test.stopTest();
	}

	private static TestDataFactory.SingleRequestMock getDeploymentResultChangeBundleMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":1,"done":true,"records":[' +
						'{"attributes":{"type":"sf_devops__Deployment_Result__c","url":"/services/data/v56.0/sobjects/sf_devops__Deployment_Result__c/a07Dp000000XXXXXXX"},"Id":"a07Dp000000XXXXXXX","Name":"DR-000048","sf_devops__Deployment_Id__c":"0Af5e00000XXXXXXXX","sf_devops__Completion_Date__c":"2023-04-18T15:56:45.000+0000","sf_devops__Work_Item_Promotes__r":null,"sf_devops__Change_Bundle_Installs__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"sf_devops__Change_Bundle_Install__c","url":"/services/data/v56.0/sobjects/sf_devops__Change_Bundle_Install__c/a03Dp000000XXXXXXX"},"Id":"a03Dp000000XXXXXXX","Name":"CBI-000012","sf_devops__Merge_Result__c":"a0ADp000000XXXXXXX","sf_devops__Change_Bundle__c":"a04Dp000000XXXXXXX"}]},"sf_devops__Components__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"sf_devops__Deploy_Component__c","url":"/services/data/v56.0/sobjects/sf_devops__Deploy_Component__c/a06Dp0000011XXXXXX"},"Id":"a06Dp0000011XXXXXX","Name":"DC-000053","sf_devops__Deployment_Result__c":"a07Dp000000XXXXXXX","sf_devops__File_Path__c":"force-app/main/default/flows/Account_Approval.flow-meta.xml","sf_devops__Operation__c":"CHANGE","sf_devops__Source_Component__c":"Flow:Account_Approval"}]}}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getDeploymentResultMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":1,"done":true,"records":[' +
						'{"attributes":{"type":"sf_devops__Deployment_Result__c","url":"/services/data/v56.0/sobjects/sf_devops__Deployment_Result__c/a07Dp000000XXXXXXX"},"Id":"a07Dp000000XXXXXXX","Name":"DR-000064","sf_devops__Deployment_Id__c":"0Af5e00000XXXXXXXX","sf_devops__Completion_Date__c":"2023-04-28T12:04:06.000+0000","sf_devops__Work_Item_Promotes__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"sf_devops__Work_Item_Promote__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item_Promote__c/a0KDp000000XXXXXXX"},"Id":"a0KDp000000XXXXXXX","Name":"WIP-000037","sf_devops__Merge_Result__c":"a0ADp000000XXXXXXX","sf_devops__Work_Item__c":"a0LDp00000XXXXXXX"},{"attributes":{"type":"sf_devops__Work_Item_Promote__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item_Promote__c/a0KDp000000XXXXPPP"},"Id":"a0KDp000000XXXXPPP","Name":"WIP-000036","sf_devops__Merge_Result__c":"a0ADp000000XXXXXXX","sf_devops__Work_Item__c":"a0LDp00000XXXXPPP"}]},"sf_devops__Change_Bundle_Installs__r":null,"sf_devops__Components__r":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"sf_devops__Deploy_Component__c","url":"/services/data/v56.0/sobjects/sf_devops__Deploy_Component__c/a06Dp000001XXXXXXX"},"Id":"a06Dp000001XXXXXXX","Name":"DC-000064","sf_devops__Deployment_Result__c":"a07Dp000000XXXXXXX","sf_devops__File_Path__c":"force-app/main/default/triggers/AccountTrigger.trigger-meta.xml","sf_devops__Operation__c":"MANUAL","sf_devops__Source_Component__c":"ApexTrigger:AccountTrigger"},{"attributes":{"type":"sf_devops__Deploy_Component__c","url":"/services/data/v56.0/sobjects/sf_devops__Deploy_Component__c/a06Dp000001XXXXPPP"},"Id":"a06Dp000001XXXXPPP","Name":"DC-000065","sf_devops__Deployment_Result__c":"a07Dp000000XXXXXXX","sf_devops__File_Path__c":"force-app/main/default/classes/AccountTriggerHandler.cls-meta.xml","sf_devops__Operation__c":"MANUAL","sf_devops__Source_Component__c":"ApexClass:AccountTriggerHandler"}]}}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getMergeResultMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":1,"done":true,"records":[{"attributes":{"type":"sf_devops__Merge_Result__c","url":"/services/data/v56.0/sobjects/sf_devops__Merge_Result__c/a0ADp000000XXXXXXX"},"Id":"a0ADp000000XXXXXXX","Name":"MR-000033","sf_devops__Previous_Remote_Reference__c":"fc019530a3eb0336b9fe85e8cf438e3bfee65014","sf_devops__Remote_Reference__c":"fe6d096bd183b1f6d4b32cf581c8e03068f39d7f","sf_devops__Source_Branch_Name__c":"uat","sf_devops__Target_Branch_Name__c":"main"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getWorkItemBundleMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":2,"done":true,"records":[' +
						'{"attributes":{"type":"sf_devops__Work_Item__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item__c/a0LDp00000XXXXXXX"},"Id":"a0LDp00000XXXXXXX","Name":"WI-000020","sf_devops__Change_Bundle__c":"a04Dp000000XXXXXXX","sf_devops__Project__c":"a0EDp000000XXXXXXX","sf_devops__Subject__c":"Create Trigger","sf_devops__Description__c":"<p>Account Trigger</p>"},' +
						'{"attributes":{"type":"sf_devops__Work_Item__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item__c/a0LDp00000XXXXPPP"},"Id":"a0LDp00000XXXXPPP","Name":"WI-000019","sf_devops__Change_Bundle__c":"a04Dp000000XXXXXXX","sf_devops__Project__c":"a0EDp000000XXXXXXX","sf_devops__Subject__c":"Create Trigger Handler","sf_devops__Description__c":"<p>Account Trigger Handler</p>"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getWorkItemMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":2,"done":true,"records":[' +
						'{"attributes":{"type":"sf_devops__Work_Item__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item__c/a0LDp00000XXXXXXX"},"Id":"a0LDp00000XXXXXXX","Name":"WI-000026","sf_devops__Change_Bundle__c":null,"sf_devops__Project__c":"a0EDp000000XXXXXXX","sf_devops__Subject__c":"Create Trigger","sf_devops__Description__c":"<p>Create Trigger</p>"},' +
						'{"attributes":{"type":"sf_devops__Work_Item__c","url":"/services/data/v56.0/sobjects/sf_devops__Work_Item__c/a0LDp00000XXXXPPP"},"Id":"a0LDp00000XXXXPPP","Name":"WI-000027","sf_devops__Change_Bundle__c":null,"sf_devops__Project__c":"a0EDp000000XXXXXXX","sf_devops__Subject__c":"Create Trigger Handler","sf_devops__Description__c":"<p>Create Trigger Handler</p>"}]}'
		);
		return singleRequestMock;
	}

	private static TestDataFactory.SingleRequestMock getProjectMock() {
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				'{"totalSize":1,"done":true,"records":[{"attributes":{"type":"sf_devops__Project__c","url":"/services/data/v56.0/sobjects/sf_devops__Project__c/a0EDp000000XXXXXXX"},"Id":"a0EDp000000XXXXXXX","Name":"Devops Dreamin","sf_devops__Platform_Repository__r":{"attributes":{"type":"sf_devops__Repository__c","url":"/services/data/v56.0/sobjects/sf_devops__Repository__c/a0GDp000000xDX3MAM"},"Id":"a0GDp000000xDX3MAM","Name":"mikita-kniazeu/Devops_Dreamin","sf_devops__Default_Branch__c":"main","sf_devops__GitHub_Owner__c":"mikita-kniazeu","sf_devops__GitHub_Repo__c":"Devops_Dreamin"}}]}'
		);
		return singleRequestMock;
	}

}