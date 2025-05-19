trigger TraceScheduleTrigger on Trace_Schedule__c (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        TraceService.setChildrenInactiveStatus(Trigger.new, Trigger.oldMap);
    }
    Logger.getInstance().flush();
}