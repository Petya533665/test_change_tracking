@IsTest
private class EventRecordDetailsControllerTest {

	@IsTest
	static void test_event_getLogsData() {
		createEventWithLogs();
		List<Event__c> events = [SELECT Id FROM Event__c];
		if (!events.isEmpty()) {
			EventRecordDetailsController.getLogsData(events[0].Id);
			System.assertNotEquals(null, EventRecordDetailsController.getLogsData(events[0].Id));
		}
	}

	private static void createEventWithLogs() {
		Rule__c mr1 = new Rule__c();
		mr1.Active__c = true;
		mr1.Type__c = MonitoringUtil.RULE_TYPE_MONITORING;
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

}