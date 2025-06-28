public with sharing class AiEventTriggerHandler {

	public static void aiEventHandler(List<AI_Event__e> events) {
		System.debug('++++AiEventTriggerHandler.aiEventHandler called with events count: ' + events.size());
		System.debug('++++AiEventTriggerHandler.aiEventHandler events: ' + events);
		
		if (events.size() == 1 && events.get(0).Result__c.equals(TestDataGenerator.TEST_PLATFORM_EVENT_AI_EVENT_RESULT)) {
			System.debug('++++AiEventTriggerHandler.aiEventHandler processing test event');
			TestDataGenerator.createPlatformAIEventTest();
			return;
		}

		System.debug('++++AiEventTriggerHandler.aiEventHandler calling AIAnalysis.getInstance with events');
		AIAnalysis analysis = AIAnalysis.getInstance(events);
		System.debug('++++AiEventTriggerHandler.aiEventHandler got AIAnalysis instance: ' + (analysis != null));
		
		if (analysis != null) {
			System.debug('++++AiEventTriggerHandler.aiEventHandler calling analysis.init()');
			analysis.init();
			System.debug('++++AiEventTriggerHandler.aiEventHandler calling analysis.createContentVersions()');
			analysis.createContentVersions();
			System.debug('++++AiEventTriggerHandler.aiEventHandler calling analysis.flush()');
			analysis.flush();
			System.debug('++++AiEventTriggerHandler.aiEventHandler completed successfully');
		} else {
			System.debug('++++AiEventTriggerHandler.aiEventHandler ERROR: AIAnalysis instance is null!');
		}
	}

}