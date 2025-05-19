@IsTest
private class TraceScheduleControllerTest {

	private static final String EXTERNAL_ORG_ID = '00D200000006k0s';

	@TestSetup
	static void testSetup() {

	}

	@IsTest
	private static void test_getConnectedOrgInfo() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.createConnectedOrg();
		Log__c log1 = IssueRelatedListControllerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		log1.Organization_Id__c = UserInfo.getOrganizationId();
		insert log1;
		List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 1];
		Test.startTest();
		TraceScheduleController.ConnectedOrgInfo connectedOrgInfo = TraceScheduleController.getConnectedOrgInfo(issues.get(0).Id);
		Test.stopTest();
		System.assertEquals(true, connectedOrgInfo.isAvailable);
	}

	@IsTest
	private static void test_getConnectedOrgInfo_negative() {
		TestDataFactory.enableIssueTracking();
		TestDataFactory.createConnectedOrg();
		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
		corg.Name = 'PassthroughOrgId';
		update corg;
		Log__c log1 = IssueRelatedListControllerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		log1.Organization_Id__c = UserInfo.getOrganizationId();
		insert log1;
		List<Issue__c> issues = [SELECT Id FROM Issue__c LIMIT 1];
		Test.startTest();
		TraceScheduleController.ConnectedOrgInfo connectedOrgInfo = TraceScheduleController.getConnectedOrgInfo(issues.get(0).Id);
		Test.stopTest();
		System.assertEquals(false, connectedOrgInfo.isAvailable);
	}

	@IsTest
	private static void test_trace_schedule_controller() {
		Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test');
		insert traceSchedule;

		PageReference testPage = Page.TraceSchedule;
		Test.setCurrentPage(testPage);
		testPage.getParameters().put('Id', String.valueOf(traceSchedule.Id));

		ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(new List<Trace_Schedule__c>{traceSchedule});
		TraceScheduleController ext = new TraceScheduleController(sc);
		System.assertEquals(1, [SELECT Id, Name FROM Trace_Schedule__c WHERE Id = :ext.traceScheduleId LIMIT 1].size());
		System.assertEquals(ConfigUtil.getNameSpacePrefix(), ext.packageNamespace);
		System.assert(!ext.isDev);
	}

	@IsTest
	private static void test_trace_schedule_controller_dev() {
		Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test');
		insert traceSchedule;

		PageReference testPage = Page.TraceSchedule;
		Test.setCurrentPage(testPage);
		testPage.getParameters().put('Id', String.valueOf(traceSchedule.Id));
		testPage.getParameters().put('dev', String.valueOf(true));

		ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(new List<Trace_Schedule__c>{traceSchedule});
		TraceScheduleController ext = new TraceScheduleController(sc);
		System.assertEquals(1, [SELECT Id, Name FROM Trace_Schedule__c WHERE Id = :ext.traceScheduleId LIMIT 1].size());
		System.assertEquals(ConfigUtil.getNameSpacePrefix(), ext.packageNamespace);
		System.assert(ext.isDev);
	}

	@IsTest
	private static void test_retrieve_remote_users_local() {
		TestDataFactory.createConnectedOrg();
		TestDataFactory.enableIssueTracking();
		Log__c log1 = IssueRelatedListControllerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		log1.Organization_Id__c = UserInfo.getOrganizationId();
		insert log1;
		List<Issue__c> issues = [SELECT Id, Related_Issue__c, Log__r.Organization_Id__c FROM Issue__c LIMIT 1];
		Issue__c issue1 = issues.get(0);
		System.assertNotEquals(null, issue1.Log__r.Organization_Id__c);
		Trace_Schedule__c schedule1 = TraceServiceTest.createTraceSchedule(issue1.Id);

		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'getUserOptions');
		input.put('data', new Map<String, Object>{'recordId' => schedule1.Id});

		String response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));

		system.assertNotEquals(null, data);
	}

	@IsTest
	private static void test_retrieve_remote_users_remote() {
		TestDataFactory.createConnectedOrg();
		TestDataFactory.enableIssueTracking();
		
		Log__c log1 = IssueRelatedListControllerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
		log1.Organization_Id__c = UserInfo.getOrganizationId();
		insert log1;

		List<Issue__c> issues = [SELECT Id, Related_Issue__c, Log__r.Organization_Id__c, Impacted_Users__c FROM Issue__c LIMIT 1];
		Issue__c issue1 = issues.get(0);
		issue1.Impacted_Users__c = null;
		update issue1;

		System.assertNotEquals(null, issue1.Log__r.Organization_Id__c);
		System.assertEquals(null, issue1.Impacted_Users__c);

		Trace_Schedule__c schedule1 = TraceServiceTest.createTraceSchedule(issue1.Id);

		Test.startTest();

		Map<String, HttpCalloutMock> endpoint2TestResp = getUsersMock();
        HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Map<String, Object> input = new Map<String, Object>();
		input.put('method', 'getUserOptions');
		input.put('data', new Map<String, Object>{'recordId' => schedule1.Id});

		String response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
		Test.stopTest();

		system.assertNotEquals(null, data);
	}

	private static Map<String, HttpCalloutMock> getUsersMock() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        Map<String, Object> respMap = new Map<String, Object>{
            ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS => new List<Map<String, Object>>{
                new Map<String, Object> {
					'Id' => UserInfo.getUserId(),
					'Name' => UserInfo.getUserName(),
					'attributes' => new Map<String, Object>{
						'type' => 'User'
					}
				}
            }
        };
		String query = new QBuilder(User.SObjectType)
			.selectFields(LogPostProcessingService.USER_FIELDS)
			.addLimit(1000)
			.build();
		query = EncodingUtil.urlEncode(query, 'UTF-8');
        endpoint2TestResp.put(TestDataFactory.CONNECTED_ORG_INSTANCE_URL + ConfigUtil.QUERY_REST_API_PATH + query, new TestDataFactory.SingleRequestMock(
            200,
            'OK',
            JSON.serialize(respMap)
        ));
        return endpoint2TestResp;
    }

	@IsTest
	private static void test_remote_actions() {
		TestDataFactory.createConnectedOrg();
		Issue__c issue = new Issue__c();
		issue.Status__c = 'New';
		insert issue;

		Log__c log = new Log__c();
		log.Category__c = 'TestCategory';
		log.Type__c = 'TestType' ;
		log.Area__c = 'Apex';
		log.Details__c = 'TestDetails';
		log.Organization_Id__c = UserInfo.getOrganizationId();
		log.Issue__c = issue.Id;
		insert log;

		issue.Log__c = log.Id;
		update issue;

		Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test', Issue__c = issue.Id);
		insert traceSchedule;

		List<TraceScheduleController.TraceRequest> traceRequests = new List<TraceScheduleController.TraceRequest>();
		TraceScheduleController.TraceRequest traceRequest = new TraceScheduleController.TraceRequest();
		traceRequest.status = 'New';
		traceRequest.traceSchedule = traceSchedule.Id;
		traceRequest.tracedEntityId = UserInfo.getUserId();
		traceRequest.startDate = Datetime.now();
		traceRequest.endDate = Datetime.now();
		traceRequests.add(traceRequest);

		Map<String, Object> input = new Map<String, Object>();

		input.put('method', 'createTraceRequests');
		input.put('data', traceRequests);
		String response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
		System.assert(((List<Database.SaveResult>)JSON.deserialize(JSON.serialize(data.get('result')), List<Database.SaveResult>.class))[0].success);

		traceRequests = (List<TraceScheduleController.TraceRequest>)JSON.deserialize(JSON.serialize(data.get('traceRequests')), List<TraceScheduleController.TraceRequest>.class);
		traceRequests[0].status = 'In Progress';
		input.put('method', 'updateTraceRequests');
		input.put('data', traceRequests);
		response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
		System.assert(((List<Database.SaveResult>)JSON.deserialize(JSON.serialize(data.get('result')), List<Database.SaveResult>.class))[0].success);

		traceRequests = (List<TraceScheduleController.TraceRequest>)JSON.deserialize(JSON.serialize(data.get('traceRequests')), List<TraceScheduleController.TraceRequest>.class);
		input.put('method', 'deleteTraceRequests');
		input.put('data', traceRequests);
		response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
		System.assert(((List<Database.DeleteResult>)JSON.deserialize(JSON.serialize(data.get('result')), List<Database.DeleteResult>.class))[0].success);

		input.put('method', 'getTraceRequests');
		input.put('data', new Map<String, Object>{'organizationId' => UserInfo.getOrganizationId(), 'startDate' => Datetime.now().format('yyyy-MM-dd'), 'endDate' => Datetime.now().format('yyyy-MM-dd')});
		response = TraceScheduleController.remoteActionHandler(JSON.serialize(input));
		responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
		data = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
		traceRequests = (List<TraceScheduleController.TraceRequest>)JSON.deserialize(JSON.serialize(data.get('traceRequests')), List<TraceScheduleController.TraceRequest>.class);
		System.assert(traceRequests.isEmpty());
	}

}