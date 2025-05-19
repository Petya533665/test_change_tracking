trigger TraceResultTrigger on Trace_Result__c (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isInsert) {
        NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.TRACE_RESULT, null).runNotificationRulesHandler(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.TRACE_RESULT, null).executeNotificationRulesHandler(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isDelete) {
        DateTime minLastModifiedDate = null;
        for(Trace_Result__c traceResult : Trigger.old) {
            if ((minLastModifiedDate == null || traceResult.LastModifiedDate < minLastModifiedDate)) {
                minLastModifiedDate = traceResult.LastModifiedDate;
            }
        }
        if(minLastModifiedDate != null) {
            TraceResultBatch.putLastDeleteTraceResultBatchTimeStamp(minLastModifiedDate);
            TraceResultBatch.getInstance(TraceResultBatch.JobType.DELETE_RELATED_RECORDS).startBatch();
        }
    }
    Logger.getInstance().flush();
}