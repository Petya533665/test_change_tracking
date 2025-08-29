trigger LogTrigger on Log__c (after insert, before insert, before update, after update, before delete, after delete) {

    if(Trigger.isBefore && Trigger.isInsert) {
        LogTriggerHelper.populateDefaults(Trigger.new);
        LogTriggerHelper.populateRelatedObjects(Trigger.new);
        LogService.copyLogFlagsFields(Trigger.new);
        LogTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LogService.assignRecordTypes(Trigger.new, Trigger.oldMap);
        LogTriggerHelper.checkPostProcessingSettings(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
        LogTriggerHelper.updateBroadcastStatus(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        LogTriggerHelper.onBeforeDelete(Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        LogTriggerHelper.onAfterDelete(Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        LogTriggerHelper.assignParent(Trigger.new);
        LogTriggerHelper.updateLastCreatedLogFlag(Trigger.new);
        LogTriggerHelper.createContentDocumentLinks(Trigger.new);
        MonitoringBatch.getInstance().startBatch();
        LogService.runAsyncMethods(Trigger.new);
        LogTriggerHelper.runPostProcessing(Trigger.new);
    }

    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.LOG, null).runNotificationRulesHandler(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.LOG, null).executeNotificationRulesHandler(Trigger.new, Trigger.oldMap);
        LogTriggerHelper.runBroadcast(Trigger.new, Trigger.oldMap);
    }
    if(PermissionsUtil.IssueTrackingEnabled
        && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

        if(Trigger.isInsert) {
            LogTriggerHandler.onAfterInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            LogTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    Logger.getInstance().flush();
}