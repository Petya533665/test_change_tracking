trigger AiEventTrigger on AI_Event__e (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        AiEventTriggerHandler.aiEventHandler(Trigger.new);
    }
    Logger.getInstance().flush();
}