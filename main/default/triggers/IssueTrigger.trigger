trigger IssueTrigger on Issue__c (before insert, before update, before delete, after insert, after update) {
	if (PermissionsUtil.IssueTrackingEnabled) {
		if (Trigger.isBefore && Trigger.isInsert) {
			IssueTriggerHandler.onBeforeInsert(Trigger.new);
		} else if (Trigger.isAfter && Trigger.isInsert) {
			IssueTriggerHandler.onAfterInsert(Trigger.new);
		} else if (Trigger.isBefore && Trigger.isUpdate) {
			IssueTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		} else if (Trigger.isAfter && Trigger.isUpdate) {
			IssueTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
		} else if (Trigger.isBefore && Trigger.isDelete) {
			IssueTriggerHandler.onBeforeDelete(Trigger.oldMap);
		}

		if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
			NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.ISSUE, null).runNotificationRulesHandler(Trigger.new, Trigger.oldMap);
		}
		if (Trigger.isAfter && Trigger.isUpdate) {
			NotificationService.getInstance(NotificationService.NOTIFICATION_SERVICE_TYPE.ISSUE, null).executeNotificationRulesHandler(Trigger.new, Trigger.oldMap);
		}
		Logger.getInstance().flush();
	}
}