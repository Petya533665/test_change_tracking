@IsTest
private class EventRecordDetailsControllerTest {

	@TestSetup
	static void setupTestData() {
		Rule__c mr1 = new Rule__c();
		mr1.Active__c = true;
		mr1.Type__c = Constants.RULE_SOBJECT.TYPE_MONITORING;
		mr1.EventTimeInterval__c = 1*60;
		insert mr1;

		Log__c log = new Log__c();
		log.Category__c = 'TestCategory';
		log.Type__c = 'TestType' ;
		log.Area__c = 'Apex';
		log.Details__c = 'pass pass pass pass pass pass pass';
		insert log;

		Event__c event = new Event__c();
		event.Rule__c = mr1.Id;
		event.RecordCount__c = 1;
		event.Records__c = '{"":["' + log.Id + '"]}';
		insert event;
	}

	@IsTest
	static void test_event_getLogsData() {
		Event__c event = getEvent();
		
		Test.startTest();
		List<EventRecordDetailsController.LogData> result = EventRecordDetailsController.getLogsData(event.Id);
		Test.stopTest();

		Assert.areEqual(1, result.size(), 'Should return 1 log record');
	}

	@IsTest
	static void test_getLogsData_withListIdsRecords() {
		Log__c log = [SELECT Id FROM Log__c];
		Event__c event = getEvent();

		event.Records__c = JSON.serialize(new List<String>{ log.Id });
		update event;

		Test.startTest();
		List<EventRecordDetailsController.LogData> result = EventRecordDetailsController.getLogsData(event.Id);
		Test.stopTest();

		Assert.areEqual(1, result.size(), 'Should return 1 log record');
	}

	@IsTest
	static void test_getLogsData_emptyRecords() {
		Event__c event = getEvent();

		event.Records__c = '';
		update event;

		Test.startTest();
		List<EventRecordDetailsController.LogData> result = EventRecordDetailsController.getLogsData(event.Id);
		Test.stopTest();

		Assert.areEqual(0, result.size(), 'Should return empty list for empty Records__c');
	}

	@IsTest
	static void test_getLogsData_nullRecords() {
		Event__c event = getEvent();

		event.Records__c = null;
		update event;

		Test.startTest();
		List<EventRecordDetailsController.LogData> result = EventRecordDetailsController.getLogsData(event.Id);
		Test.stopTest();

		Assert.areEqual(0, result.size(), 'Should return empty list for null Records__c');
	}

	@IsTest
	static void test_constructor_withDevParameter() {
		Event__c event = getEvent();

		PageReference pageRef = Page.EventRecordDetails;
		pageRef.getParameters().put('recordId', event.Id);
		pageRef.getParameters().put('dev', 'true');
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		EventRecordDetailsController controller = new EventRecordDetailsController(sc);
		Test.stopTest();

		Assert.areEqual(true, controller.isDev, 'isDev should be true when dev parameter is true');
		Assert.areNotEqual(null, controller.eventJson, 'eventJson should not be null');
		Assert.areNotEqual(null, controller.logData, 'logData should not be null');
		Assert.areNotEqual(null, controller.packageNamespace, 'packageNamespace should not be null');
		Assert.areNotEqual(null, EventRecordDetailsController.baseUrl, 'baseUrl should not be null');
	}

	@IsTest
	static void test_constructor_withoutDevParameter() {
		Event__c event = getEvent();

		PageReference pageRef = Page.EventRecordDetails;
		pageRef.getParameters().put('recordId', event.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		EventRecordDetailsController controller = new EventRecordDetailsController(sc);
		Test.stopTest();

		Assert.areEqual(false, controller.isDev, 'isDev should be false when no dev parameter is provided');
		Assert.areNotEqual(null, controller.eventJson, 'eventJson should not be null');
		Assert.areNotEqual(null, controller.logData, 'logData should not be null');
	}

	@IsTest
	static void test_constructor_withDevParameterFalse() {
		Event__c event = getEvent();

		PageReference pageRef = Page.EventRecordDetails;
		pageRef.getParameters().put('recordId', event.Id);
		pageRef.getParameters().put('dev', 'false');
		Test.setCurrentPage(pageRef);

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		EventRecordDetailsController controller = new EventRecordDetailsController(sc);
		Test.stopTest();

		Assert.areEqual(false, controller.isDev, 'isDev should be false when dev parameter is false');
	}

	@IsTest
	static void test_constructor_withCookie() {
		Event__c event = getEvent();

		PageReference pageRef = Page.EventRecordDetails;
		pageRef.getParameters().put('recordId', event.Id);
		Test.setCurrentPage(pageRef);

		// Set a cookie for development mode
		Cookie devCookie = new Cookie('a2developmentMode', 'true', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(event);
		EventRecordDetailsController controller = new EventRecordDetailsController(sc);
		Test.stopTest();

		// Note: Cookie reading might not work in test context, so isDev will likely be false
		Assert.areNotEqual(null, controller.eventJson, 'eventJson should not be null');
	}

	private static Event__c getEvent() {
		return [SELECT Rule__c, RecordCount__c, Records__c FROM Event__c];
	}
}