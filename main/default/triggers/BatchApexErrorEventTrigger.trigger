trigger BatchApexErrorEventTrigger on BatchApexErrorEvent (after insert) {
	if(Trigger.isAfter && Trigger.isInsert) {
		BatchApexErrorEventTriggerHandler.handleErrorEvents(Trigger.new);
	}
}