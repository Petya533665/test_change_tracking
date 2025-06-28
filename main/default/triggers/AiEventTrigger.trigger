trigger AiEventTrigger on AI_Event__e (after insert) {
    System.debug('++++AiEventTrigger: trigger fired');
    System.debug('++++AiEventTrigger: Trigger.isAfter = ' + Trigger.isAfter + ', Trigger.isInsert = ' + Trigger.isInsert);
    System.debug('++++AiEventTrigger: Trigger.new size = ' + Trigger.new.size());
    System.debug('++++AiEventTrigger: Trigger.new = ' + Trigger.new);
    
    if (Trigger.isAfter && Trigger.isInsert) {
        System.debug('++++AiEventTrigger: calling AiEventTriggerHandler.aiEventHandler');
        try {
            AiEventTriggerHandler.aiEventHandler(Trigger.new);
            System.debug('++++AiEventTrigger: aiEventHandler completed successfully');
        } catch (Exception e) {
            System.debug('++++AiEventTrigger: error in ai event trigger: ' + e.getMessage());
            System.debug('++++AiEventTrigger: error stack trace: ' + e.getStackTraceString());
            Logger.getInstance().addInternalError(e, 'AiEventTrigger', 'trigger execution');
        }
    } else {
        System.debug('++++AiEventTrigger: trigger conditions not met, skipping event processing');
    }
    
    System.debug('++++AiEventTrigger: calling Logger.getInstance().flush()');
    Logger.getInstance().flush();
    System.debug('++++AiEventTrigger: trigger execution completed');
}