public with sharing class AiEventTriggerHandler {

	public static void aiEventHandler(List<AI_Event__e> events) {
		if (events.size() == 1 && events.get(0).Result__c.equals(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT)) {
			try {
				throw new HandledException(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT);
			} catch (Exception e) {
				Logger.getInstance().addInternalError(e, AiEventTriggerHandler.class.getName(), 'aiEventHandler');
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