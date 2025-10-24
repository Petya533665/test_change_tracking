public with sharing class PlatformEventBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

	private final Boolean shouldThrow;
	public PlatformEventBatch(Boolean shouldThrow) {
		this.shouldThrow = shouldThrow;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		if (this.shouldThrow) {
			throw new IllegalArgumentException('Platform Event Error');
		}
		return Database.getQueryLocator([SELECT Id FROM Account]);
	}

	public void execute(Database.BatchableContext bc, List<SObject> records) {
		// no-op for now
	}

	public void finish(Database.BatchableContext bc) {
		// another no-op
	}
}