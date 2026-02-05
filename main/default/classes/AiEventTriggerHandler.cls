public with sharing class AiEventTriggerHandler {

	public static void aiEventHandler(List<AI_Event__e> events) {
		if (events.size() == 1 && events.get(0).Result__c.equals(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT)) {
			TestDataGenerator.createPlatformAIEventTest();

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