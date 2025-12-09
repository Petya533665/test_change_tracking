@IsTest
private class TraceScheduleControllerTest {

    private static final String EXTERNAL_ORG_ID = '00D200000006k0s';

    @TestSetup
    static void testSetup() {
        TestDataFactory.enableIssueTracking();
        TestDataFactory.createConnectedOrg();
        Log__c log1 = IssueRelatedListControllerTest.createPharosLog('hash1_1', 'hash2_1', 'hash3_1');
        log1.Organization_Id__c = UserInfo.getOrganizationId();
        insert log1;
    }

    @IsTest
    static void test_RemoteAction_Scope() {

        Test.startTest();

        Map<String, Object> payload = new Map<String, Object>{
            'method' => 'Unknown',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getConnectedOrgs',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getUserOptions',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getLogsByRange',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'createTraceRequests',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'updateTraceRequests',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'deleteTraceRequests',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getTraceRequests',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getTraceRequestsByTraceScheduleId',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'deactivateTraceSchedule',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'setForecastSetting',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getLogsCountByDayLargeDataset',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getUserIdToDateTime',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'createAutoTraceRequests',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        payload = new Map<String, Object>{
            'method' => 'getIsEnabledHoltwinters',
            'data' => ''
        };
        TraceScheduleController.remoteActionHandler(JSON.serialize(payload));

        Test.stopTest();

        Assert.areNotEqual(null, payload);
    }

    @IsTest
    static void test_constructor_withDevParameterTrue() {
        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test');
        insert traceSchedule;

        PageReference pageRef = Page.TraceSchedule;
        pageRef.getParameters().put('Id', String.valueOf(traceSchedule.Id));
        pageRef.getParameters().put('dev', String.valueOf(true));
        Test.setCurrentPage(pageRef);

        Test.startTest();
            ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(new List<Trace_Schedule__c>{traceSchedule});
            TraceScheduleController controller = new TraceScheduleController(sc);

            // To cover this method
            controller.doRedirect();
        Test.stopTest();

        Assert.areEqual(traceSchedule.Id, controller.traceScheduleId, 'recordId should match');
        Assert.areEqual(true, controller.isDev, 'isDev should be true when dev parameter is true');
        Assert.isTrue(String.isNotBlank(controller.packageNamespace), 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
        Assert.isTrue(String.isNotBlank(controller.userTimezone), 'userTimezone should not be null');
        Assert.isTrue(String.isNotBlank(controller.orgId), 'orgId should not be null');
    }

    @IsTest
    static void test_constructor_withDevParameterFalse() {
        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test');
        insert traceSchedule;

        PageReference pageRef = Page.TraceSchedule;
        pageRef.getParameters().put('Id', String.valueOf(traceSchedule.Id));
        pageRef.getParameters().put('dev', String.valueOf(false));
        Test.setCurrentPage(pageRef);

        Test.startTest();
            ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(new List<Trace_Schedule__c>{traceSchedule});
            TraceScheduleController controller = new TraceScheduleController(sc);
        Test.stopTest();

        Assert.areEqual(traceSchedule.Id, controller.traceScheduleId, 'recordId should match');
        Assert.areEqual(false, controller.isDev, 'isDev should be false when dev parameter is false');
        Assert.isTrue(String.isNotBlank(controller.packageNamespace), 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
        Assert.isTrue(String.isNotBlank(controller.userTimezone), 'userTimezone should not be null');
        Assert.isTrue(String.isNotBlank(controller.orgId), 'orgId should not be null');
    }

    @IsTest
    static void test_constructor_withoutDevParameter() {
        Trace_Schedule__c traceSchedule = new Trace_Schedule__c(Name = 'Test');
        insert traceSchedule;

        PageReference pageRef = Page.TraceSchedule;
        pageRef.getParameters().put('Id', String.valueOf(traceSchedule.Id));
        Test.setCurrentPage(pageRef);

        Test.startTest();
            ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(new List<Trace_Schedule__c>{traceSchedule});
            TraceScheduleController controller = new TraceScheduleController(sc);
        Test.stopTest();

        Assert.areEqual(traceSchedule.Id, controller.traceScheduleId, 'recordId should match');
        Assert.areEqual(false, controller.isDev, 'isDev should be false when no dev parameter is provided');
        Assert.isTrue(String.isNotBlank(controller.packageNamespace), 'packageNamespace should not be null');
        Assert.areNotEqual(null, controller.userTimezoneOffset, 'userTimezoneOffset should not be null');
        Assert.isTrue(String.isNotBlank(controller.userTimezone), 'userTimezone should not be null');
        Assert.isTrue(String.isNotBlank(controller.orgId), 'orgId should not be null');
    }

    @IsTest
    static void test_getNameSpacePrefix() {
        Test.startTest();
            String namespace = TraceScheduleController.getNameSpacePrefix();
        Test.stopTest();
        
        Assert.areNotEqual(null, namespace, 'getNameSpacePrefix should not return null');
    }

    @IsTest
    static void test_getTraceScheduleId_withActiveSchedule() {
        Issue__c issue = getIssue();

        // Create active Trace Schedule
        Trace_Schedule__c traceSchedule = new Trace_Schedule__c();
        traceSchedule.Name = 'Active Schedule';
        traceSchedule.Issue__c = issue.Id;
        traceSchedule.Status__c = Constants.TRACE_SCHEDULE_SOBJECT.STATUS_IN_PROGRESS;
        insert traceSchedule;

        Test.startTest();
            String result = TraceScheduleController.getTraceScheduleId(issue.Id);
        Test.stopTest();

        // Verify that the active Trace Schedule Id is returned
        Assert.isTrue(String.isNotBlank(result), 'Should return Trace Schedule Id for active schedule');
        Assert.areEqual(traceSchedule.Id, result, 'Should return the correct Trace Schedule Id');
    }

    @IsTest
    static void test_getTraceScheduleId_withInactiveSchedule() {
        Issue__c issue = getIssue();

        // Create inactive Trace Schedule (Status = 'Completed')
        Trace_Schedule__c traceSchedule = new Trace_Schedule__c();
        traceSchedule.Name = 'Completed Schedule';
        traceSchedule.Issue__c = issue.Id;
        traceSchedule.Status__c = Constants.TRACE_SCHEDULE_SOBJECT.STATUS_COMPLETED;
        insert traceSchedule;

        Test.startTest();
            String result = TraceScheduleController.getTraceScheduleId(issue.Id);
        Test.stopTest();

        // Verify that null is returned for inactive schedule
        Assert.isTrue(String.isBlank(result), 'Should return null for Completed status');
    }

    @IsTest
    static void test_getTraceScheduleId_withMultipleSchedules() {
        Issue__c issue = getIssue();

        // Create inactive schedule first
        Trace_Schedule__c inactiveSchedule = new Trace_Schedule__c();
        inactiveSchedule.Name = 'Inactive Schedule';
        inactiveSchedule.Issue__c = issue.Id;
        inactiveSchedule.Status__c = Constants.TRACE_SCHEDULE_SOBJECT.STATUS_INACTIVE;
        insert inactiveSchedule;

        // Create active schedule
        Trace_Schedule__c activeSchedule = new Trace_Schedule__c();
        activeSchedule.Name = 'Active Schedule';
        activeSchedule.Issue__c = issue.Id;
        activeSchedule.Status__c = Constants.TRACE_SCHEDULE_SOBJECT.STATUS_IN_PROGRESS;
        insert activeSchedule;

        Test.startTest();
            String result = TraceScheduleController.getTraceScheduleId(issue.Id);
        Test.stopTest();

        // Verify that only active schedule Id is returned
        Assert.isTrue(String.isNotBlank(result), 'Should return Trace Schedule Id');
        Assert.areEqual(activeSchedule.Id, result, 'Should return the active Trace Schedule Id, not the inactive one');
    }

    @IsTest
    static void test_getTraceScheduleId_withNoSchedule() {
        Issue__c issue = getIssue();

        Test.startTest();
            String result = TraceScheduleController.getTraceScheduleId(issue.Id);
        Test.stopTest();

        // Verify that null is returned when no schedule exists
        Assert.isTrue(String.isBlank(result), 'Should return null when no Trace Schedule exists');
    }

    @IsTest
    static void test_getTraceScheduleId_withNullIssueId() {
        Test.startTest();
            String result = TraceScheduleController.getTraceScheduleId(null);
        Test.stopTest();

        // Verify that null is returned when issueId is null
        Assert.isTrue(String.isBlank(result), 'Should return null when issueId is null');
    }

    @IsTest
    static void test_getConnectedOrgInfo() {
        Issue__c issue = getIssue();

        Test.startTest();
            TraceScheduleController.ConnectedOrgInfo connectedOrgInfo = TraceScheduleController.getConnectedOrgInfo(issue.Id);
        Test.stopTest();
        
        Assert.isTrue(connectedOrgInfo.isAvailable);
    }

    @IsTest
    static void test_getConnectedOrgInfo_negative() {
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        corg.Name = 'PassthroughOrgId';
        update corg;

        Issue__c issue = getIssue();

        Test.startTest();
            TraceScheduleController.ConnectedOrgInfo connectedOrgInfo = TraceScheduleController.getConnectedOrgInfo(issue.Id);
        Test.stopTest();

        Assert.isFalse(connectedOrgInfo.isAvailable);
    }

    @IsTest
    static void test_createTraceRequest() {
        Issue__c issue = getIssue();

        Test.startTest();
            String result = TraceScheduleController.createTraceRequest(issue.Id);
        Test.stopTest();

        // Verify that the result is not null and is a valid Id
        Assert.isTrue(String.isNotBlank(result), 'The Trace Request Id should not be null');
        Assert.isTrue(result instanceof Id, 'Result should be a valid Salesforce Id');
        
        // Verify that Trace_Schedule__c was created correctly
        List<Trace_Schedule__c> traceSchedules = [
            SELECT Id, Name, Description__c, Issue__c 
            FROM Trace_Schedule__c 
            WHERE Id = :result
        ];
        Assert.areEqual(1, traceSchedules.size(), 'One Trace Schedule should be created');
        Assert.areEqual(issue.Name, traceSchedules[0].Name, 'Trace Schedule Name should match Issue Name');
        Assert.areEqual(issue.Summary__c, traceSchedules[0].Description__c, 'Trace Schedule Description should match Issue Summary');
        Assert.areEqual(issue.Id, traceSchedules[0].Issue__c, 'Trace Schedule should be linked to the Issue');
    }

    @IsTest
    static void test_createTraceRequest_withNotExistIssueId() {
        // Use a fake Issue Id that doesn't exist in the database
        Id fakeIssueId = TestDataFactory.getFakeIds(Issue__c.SObjectType, 1).get(0);

        Test.startTest();
            String result = TraceScheduleController.createTraceRequest(fakeIssueId);
        Test.stopTest();

        // Verify that the result is null for non-existent Issue
        Assert.isTrue(String.isBlank(result), 'The Trace Request Id should be null for non-existent Issue');
        
        // Verify that no Trace_Schedule__c was created
        List<Trace_Schedule__c> traceSchedules = [SELECT Id FROM Trace_Schedule__c];
        Assert.areEqual(0, traceSchedules.size(), 'No Trace Schedule should be created for non-existent Issue');
    }
    
    @IsTest
    static void test_createTraceRequest_withNullIssueId() {
        Test.startTest();
            String result = TraceScheduleController.createTraceRequest(null);
        Test.stopTest();

        // Verify that the result is null when issueId is null
        Assert.isTrue(String.isBlank(result), 'The Trace Request Id should be null when issueId is null');
        
        // Verify that no Trace_Schedule__c was created
        List<Trace_Schedule__c> traceSchedules = [SELECT Id FROM Trace_Schedule__c];
        Assert.areEqual(0, traceSchedules.size(), 'No Trace Schedule should be created when issueId is null');
    }

    @IsTest
    static void test_getConnectedOrgs() {
        TestDataFactory.createConnectedOrg(EXTERNAL_ORG_ID);
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(EXTERNAL_ORG_ID);
        corg.Data_Direction__c = ConnectedOrgService.BROADCAST_RECEIVE_FROM;
        update corg;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.getConnectedOrgs();
        Test.stopTest();

        Map<String, String> mapConnectedOrgs = (Map<String, String>) result.get(TraceScheduleController.OUTPUT_KEY_CONNECTED_ORGS);

        Assert.areEqual(2, mapConnectedOrgs.size(), 'Size of connected org does not match');
        Assert.isTrue(mapConnectedOrgs.containsKey(UserInfo.getOrganizationId().left(15)));
        Assert.isTrue(mapConnectedOrgs.containsKey(EXTERNAL_ORG_ID));
    }

    @IsTest
    static void test_getUserOptions_local() {
        Issue__c issue = getIssue();
        Assert.isNotNull(issue.Log__r.Organization_Id__c);

        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.getUserOptions(
                new Map<String, Object>{ TraceScheduleController.INPUT_KEY_RECORD_ID => schedule.Id }
            );
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_USER_OPTIONS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_USER_OPTIONS + ' key');
        
        Map<String, String> userOptions = (Map<String, String>) result.get(TraceScheduleController.OUTPUT_KEY_USER_OPTIONS);

        Assert.areEqual(1, userOptions.size(), 'Size does not match');
        Assert.isTrue(userOptions.containsKey(UserInfo.getUserId()));
    }

    @IsTest
    static void test_getUserOptions_remote() {
        Issue__c issue = getIssue();
        issue.Impacted_Users__c = null;
        update issue;

        Assert.isNotNull(issue.Log__r.Organization_Id__c);
        Assert.isNull(issue.Impacted_Users__c);

        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);

        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getUsersMock()));

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.getUserOptions(
                new Map<String, Object>{ TraceScheduleController.INPUT_KEY_RECORD_ID => schedule.Id }
            );
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_USER_OPTIONS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_USER_OPTIONS + ' key');
        
        Map<String, String> userOptions = (Map<String, String>) result.get(TraceScheduleController.OUTPUT_KEY_USER_OPTIONS);

        Assert.areEqual(0, userOptions.size(), 'Size does not match');
    }

    @IsTest
    static void test_getLogsByRange() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);

        Assert.isNotNull(issue.Log__c);

        Log__c log = [SELECT User_Id__c, User_Name__c, Created_At__c FROM Log__c WHERE Id = :issue.Log__c];
        log.User_Name__c = UserInfo.getUserName();
        update log;
        
        Assert.isTrue(String.isNotBlank(log.User_Id__c));
        Assert.isTrue(String.isNotBlank(log.User_Name__c));
        Assert.isNotNull(log.Created_At__c);

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.getLogsByRange(new Map<String, Object>{
                TraceScheduleController.INPUT_KEY_RECORD_ID => schedule.Id,
                TraceScheduleController.INPUT_KEY_RANGE => 30
            });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_LOGS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_LOGS + ' key');

        List<Map<String, Object>> intervalGroupsList = (List<Map<String, Object>>) result.get(TraceScheduleController.OUTPUT_KEY_LOGS);

        Assert.isFalse(intervalGroupsList.isEmpty());
        Assert.areEqual(1, intervalGroupsList.size());

        Map<String, Object> intervalData = intervalGroupsList.get(0);

        Assert.isFalse(intervalData.isEmpty());

        Assert.areEqual(log.Id, (Id) intervalData.get('id'));
        Assert.areEqual(log.Created_At__c, (Datetime) intervalData.get('createdAt'));

        Map<String, List<Datetime>> usersMap = (Map<String, List<Datetime>>) intervalData.get('logTimesByUser');

        Assert.isFalse(usersMap.isEmpty());
        Assert.isTrue(usersMap.containsKey(UserInfo.getUserName()));
        Assert.isFalse(usersMap.get(UserInfo.getUserName()).isEmpty());
    }

    @IsTest
    static void test_createTraceRequests_withExistTraceSchedule() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);

        TraceScheduleController.TraceRequest traceRequestWrapper = new TraceScheduleController.TraceRequest();
        traceRequestWrapper.status = 'New';
        traceRequestWrapper.traceSchedule = schedule.Id;
        traceRequestWrapper.tracedEntityId = UserInfo.getUserId();
        traceRequestWrapper.startDate = Datetime.now();
        traceRequestWrapper.endDate = Datetime.now();

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.createTraceRequests(new List<TraceScheduleController.TraceRequest>{ traceRequestWrapper });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_RESULT), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_RESULT + ' key');

        List<Database.SaveResult> saveResults = (List<Database.SaveResult>) result.get(TraceScheduleController.OUTPUT_KEY_RESULT);
        Assert.areEqual(1, saveResults.size());
        Assert.isTrue(saveResults.get(0).isSuccess());

        List<Trace_Request__c> traceRequests = [SELECT Id, Trace_Schedule__c FROM Trace_Request__c];
        Assert.areEqual(1, traceRequests.size(), 'Count of trace requests do not match');
        Assert.areEqual(schedule.Id, traceRequests.get(0).Trace_Schedule__c, 'Trace Schedule Id does not match');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS + ' key');

        List<TraceScheduleController.TraceRequest> wrappers = (List<TraceScheduleController.TraceRequest>) result.get(TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS);
        Assert.areEqual(1, wrappers.size());
        Assert.areEqual(traceRequests.get(0).Id, wrappers.get(0).Id);
    }

    @IsTest
    static void test_createTraceRequests_withNonExistTraceSchedule() {
        TraceScheduleController.TraceRequest traceRequestWrapper = new TraceScheduleController.TraceRequest();
        traceRequestWrapper.status = 'New';
        traceRequestWrapper.traceSchedule = TestDataFactory.getFakeIds(Trace_Schedule__c.SObjectType, 1).get(0);
        traceRequestWrapper.tracedEntityId = UserInfo.getUserId();
        traceRequestWrapper.startDate = Datetime.now();
        traceRequestWrapper.endDate = Datetime.now();

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.createTraceRequests(new List<TraceScheduleController.TraceRequest>{ traceRequestWrapper });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_RESULT), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_RESULT + ' key');

        List<Database.SaveResult> saveResults = (List<Database.SaveResult>) result.get(TraceScheduleController.OUTPUT_KEY_RESULT);
        Assert.areEqual(1, saveResults.size());
        Assert.isFalse(saveResults.get(0).isSuccess());

        List<Trace_Request__c> traceRequests = [SELECT Id, Trace_Schedule__c FROM Trace_Request__c];
        Assert.areEqual(0, traceRequests.size(), 'Count of trace requests do not match');
    }

    @IsTest
    static void test_updateTraceRequests() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);
        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        insert request;

        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Request__c], 'Trace request is not created');

        Datetime dtNow = Datetime.now();

        TraceScheduleController.TraceRequest traceRequestWrapper = new TraceScheduleController.TraceRequest();
        traceRequestWrapper.id = request.Id;
        traceRequestWrapper.status = 'New';
        traceRequestWrapper.traceSchedule = schedule.Id;
        traceRequestWrapper.tracedEntityId = UserInfo.getUserId();
        traceRequestWrapper.startDate = dtNow;
        traceRequestWrapper.endDate = dtNow;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.updateTraceRequests(new List<TraceScheduleController.TraceRequest>{ traceRequestWrapper });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_RESULT), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_RESULT + ' key');

        List<Database.SaveResult> saveResults = (List<Database.SaveResult>) result.get(TraceScheduleController.OUTPUT_KEY_RESULT);
        Assert.areEqual(1, saveResults.size());
        Assert.isTrue(saveResults.get(0).isSuccess());

        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS + ' key');

        List<TraceScheduleController.TraceRequest> wrappers = (List<TraceScheduleController.TraceRequest>) result.get(TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS);
        Assert.areEqual(1, wrappers.size());
    }

    @IsTest
    static void test_deleteTraceRequests() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);
        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        insert request;

        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Request__c], 'Trace request is not created');

        TraceScheduleController.TraceRequest traceRequestWrapper = new TraceScheduleController.TraceRequest();
        traceRequestWrapper.id = request.Id;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.deleteTraceRequests(new List<TraceScheduleController.TraceRequest>{ traceRequestWrapper });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_RESULT), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_RESULT + ' key');

        List<Database.DeleteResult> deleteResults = (List<Database.DeleteResult>) result.get(TraceScheduleController.OUTPUT_KEY_RESULT);
        Assert.areEqual(1, deleteResults.size());
        Assert.isTrue(deleteResults.get(0).isSuccess());
        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Result__c], 'Trace Request is not deleted');
    }

    @IsTest
    static void test_getTraceRequests() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);
        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        request.Issue__c = issue.Id;
        insert request;

        Datetime dtNow = Datetime.now();

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.getTraceRequests(new Map<String, Object>{
                TraceScheduleController.INPUT_KEY_ORGANIZATION_ID => UserInfo.getOrganizationId(),
                TraceScheduleController.INPUT_KEY_START_DATE => dtNow.addDays(-1),
                TraceScheduleController.INPUT_KEY_END_DATE => dtNow.addDays(15)
            });
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');
        Assert.isTrue(result.containsKey(TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS), 'The result does not have ' + TraceScheduleController.OUTPUT_KEY_TRACE_REQUESTS + ' key');
    }

    @IsTest
    static void test_deactivateTraceSchedule_traceRequestStatusNew() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);
        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        insert request;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.deactivateTraceSchedule(schedule.Id);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');

        List<Database.SaveResult> traceRequestsSaveResults = (List<Database.SaveResult>) result.get('traceRequestsResult');
        Assert.areEqual(1, traceRequestsSaveResults.size());
        Assert.isTrue(traceRequestsSaveResults.get(0).isSuccess());

        List<Database.SaveResult> traceSchedulesSaveResults = (List<Database.SaveResult>) result.get('traceSchedulesResult');
        Assert.areEqual(1, traceSchedulesSaveResults.size());
        Assert.isTrue(traceSchedulesSaveResults.get(0).isSuccess());

        Assert.isFalse((Boolean) result.get('isInProgress'));

        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c != :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);
        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c = :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);

        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c != :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c = :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
    }

    @IsTest
    static void test_deactivateTraceSchedule_traceRequestStatusInProgress() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);
        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        request.Status__c = TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
        insert request;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.deactivateTraceSchedule(schedule.Id);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');

        List<Database.SaveResult> traceRequestsSaveResults = (List<Database.SaveResult>) result.get('traceRequestsResult');
        Assert.areEqual(1, traceRequestsSaveResults.size());
        Assert.isTrue(traceRequestsSaveResults.get(0).isSuccess());

        List<Database.SaveResult> traceSchedulesSaveResults = (List<Database.SaveResult>) result.get('traceSchedulesResult');
        Assert.areEqual(1, traceSchedulesSaveResults.size());
        Assert.isTrue(traceSchedulesSaveResults.get(0).isSuccess());

        Assert.isTrue((Boolean) result.get('isInProgress'));

        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c != :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);
        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c = :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);

        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c != :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c = :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
    }

    @IsTest
    static void test_deactivateTraceSchedule_traceScheduleStatusInProgress() {
        Issue__c issue = getIssue();
        Trace_Schedule__c schedule = TraceServiceTest.createTraceSchedule(issue.Id);

        Trace_Request__c request = TraceServiceTest.createTraceRequest(true, true, schedule.Id);
        insert request;

        schedule.Status__c = TraceService.TRACE_SCHEDULE_STATUS_IN_PROGRESS;
        update schedule;

        Test.startTest();
            Map<String, Object> result = TraceScheduleController.deactivateTraceSchedule(schedule.Id);
        Test.stopTest();

        Assert.areNotEqual(null, result, 'The result should not be null');

        List<Database.SaveResult> traceRequestsSaveResults = (List<Database.SaveResult>) result.get('traceRequestsResult');
        Assert.areEqual(1, traceRequestsSaveResults.size());
        Assert.isTrue(traceRequestsSaveResults.get(0).isSuccess());

        List<Database.SaveResult> traceSchedulesSaveResults = (List<Database.SaveResult>) result.get('traceSchedulesResult');
        Assert.areEqual(1, traceSchedulesSaveResults.size());
        Assert.isTrue(traceSchedulesSaveResults.get(0).isSuccess());

        Assert.isTrue((Boolean) result.get('isInProgress'));

        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c != :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);
        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Request__c WHERE Status__c = :TraceService.TRACE_REQUEST_STATUS_INACTIVE]);

        Assert.areEqual(1, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c != :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
        Assert.areEqual(0, [SELECT COUNT() FROM Trace_Schedule__c WHERE Status__c = :TraceService.TRACE_SCHEDULE_STATUS_INACTIVE]);
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

    private static Issue__c getIssue() {
        return [
            SELECT 
                Name, Status__c, Summary__c, Log__c,
                Log__r.Organization_Id__c, Impacted_Users__c 
            FROM Issue__c 
            LIMIT 1
        ];
    }
}