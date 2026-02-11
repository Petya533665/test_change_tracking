trigger RuleTriggerV2 on Rule__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        RuleTriggerHandler.validateMaxActiveRules(Trigger.new, Trigger.oldMap);
    }
}