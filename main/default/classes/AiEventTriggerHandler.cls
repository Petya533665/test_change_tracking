public with sharing class AiEventTriggerHandler {

	public static void aiEventHandler(List<AI_Event__e> events) {
		if (events.size() == 1) {
			AI_Event__e event = events.get(0);
			if (event.Result__c.equals(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT)) {
				TestDataGenerator.createPlatformAIEventTest();
			} else if (event.Method__c.equals(DigestService.DIGEST_METHOD)) {
				if (event.Record_Id__c != null) {
					DigestService.setDigest(event.Record_Id__c, event.Result__c);
					//TODO: send notification
				} else {
					DigestService.storeTestDigest(event.Result__c);
				}
			}
			return;
		}

		AIAnalysis analysis = AIAnalysis.getInstance(events);
		if (analysis != null) {
			analysis.init();
			analysis.createContentVersions();
			analysis.flush();
		}
	}

}