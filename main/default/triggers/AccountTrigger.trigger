trigger AccountTrigger on Account(before insert , before update, after update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

}