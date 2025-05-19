trigger ActionTrigger on Action__c (before insert, before update) {

  if (Trigger.isBefore && Trigger.isInsert) {
  }

  if (Trigger.isBefore && Trigger.isUpdate) {
  }

}