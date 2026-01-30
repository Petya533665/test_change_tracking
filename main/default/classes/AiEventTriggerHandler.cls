public with sharing class AiEventTriggerHandler {
	private static final String DIGEST_METHOD = 'digest';

	public static void aiEventHandler(List<AI_Event__e> events) {
		if (events.size() == 1) {
			AI_Event__e event = events.get(0);
			if (event.Result__c.equals(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT)) {
				TestDataGenerator.createPlatformAIEventTest();
			} else if (event.Method__c.equals(DIGEST_METHOD) && event.Record_Id__c != null) {
				//TODO: send notification
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