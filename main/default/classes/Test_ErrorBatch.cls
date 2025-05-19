public with sharing class Test_ErrorBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, Name FROM ApexClass LIMIT 1]);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		System.debug(1/0);
	}

	public void finish(Database.BatchableContext BC) {}

}