trigger TraceRequestTrigger on Trace_Request__c (before insert, after insert, before update, after update, after delete) {
    if(Trigger.isBefore && Trigger.isInsert) {
        TraceService.populateDefaults(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isInsert) {
        TraceService.populateLookups(Trigger.new);
        TraceService.startTraceRequests(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.isBefore && Trigger.isUpdate) {
        TraceService.setInactiveStatus(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isUpdate) {
       TraceService.populateLookups(Trigger.new, Trigger.oldMap);
       TraceService.startTraceRequests(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete) {
        TraceService.populateLookups(Trigger.old);
    }
    Logger.getInstance().flush();
}