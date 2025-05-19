trigger LogEventTrigger on Log_Event__e (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        LogEventTriggerHandler.logEventHandler(Trigger.new);
    }
    Logger.getInstance().flush();
}