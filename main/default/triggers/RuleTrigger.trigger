trigger RuleTrigger on Rule__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        RuleTriggerHelper.validateMaxActiveRules(Trigger.new, Trigger.oldMap);
    }
}