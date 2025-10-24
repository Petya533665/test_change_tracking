public with sharing class LogUtilDemoController {

	public static String LOG_UTIL_DEMO_TRIGGER = 'Log Util Demo (Trigger)';
	public static String LOG_UTIL_DEMO_FLOW = 'Log Util Demo (Flow)';
	public static String LOG_UTIL_DEMO_APEX_CPU = 'Log Util Demo (Apex CPU)';

	@AuraEnabled
	public static String getTransactionId() {
		return Log.instance.startTransaction();
	}

	@AuraEnabled
	public static void scenarioDMLError(String transactionId) {
		Log.instance.resumeTransaction(transactionId);
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'LWC controller (apex) - DML Error', 'LWC controller (apex) - DML Error');
		try {
			ContentVersion contentVersion = new ContentVersion();
			contentVersion.ContentLocation = 'Apex Error';
			contentVersion.Title = 'Apex Error';
			contentVersion.PathOnClient = 'ApexError.pdf';
			insert contentVersion;
		} catch (Exception e) {
			Log.instance.error(Log.Area.Community, e);
		}
	}

	@AuraEnabled
	public static void scenarioTriggerError(String transactionId) {
		Log.instance.resumeTransaction(transactionId);
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'LWC controller (apex) - Trigger Error', 'LWC controller (apex) - Trigger Error');
		try {
			List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 1];
			if (!accounts.isEmpty()) {
				accounts[0].Name = LOG_UTIL_DEMO_TRIGGER;
				update accounts;
			}
		} catch (Exception e) {
			Log.instance.error(Log.Area.Community, e);
		}
	}

	@AuraEnabled
	public static void scenarioFlowError(String transactionId) {
		Log.instance.resumeTransaction(transactionId);
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'LWC controller (apex) - Flow Error', 'LWC controller (apex) - Flow Error');
		try {
			List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 1];
			if (!accounts.isEmpty()) {
				accounts[0].Name = LOG_UTIL_DEMO_FLOW;
				update accounts;
			}
		} catch (Exception e) {
			Log.instance.error(Log.Area.Community, e);
		}
	}

	@AuraEnabled
	public static void scenarioAsyncSync1(String transactionId) {
		Decimal startTime = Double.valueOf(System.now().getTime());
		Log.instance.resumeTransaction(transactionId);
		for (pharos__Log__c log : [SELECT Id FROM pharos__Log__c LIMIT 1000]) {
		}
		Decimal duration = Double.valueOf(System.now().getTime()) - startTime;
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'LWC controller (apex) - Async Sync 1', 'LWC controller (apex) - Async Sync 1', duration);
	}

	@AuraEnabled
	public static void scenarioAsyncSync2(String transactionId) {
		Decimal startTime = Double.valueOf(System.now().getTime());
		Log.instance.resumeTransaction(transactionId);
		for (Account account : [SELECT Id FROM Account LIMIT 1000]) {
		}
		Decimal duration = Double.valueOf(System.now().getTime()) - startTime;
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'LWC controller (apex) - Async Sync 2', 'LWC controller (apex) - Async Sync 2', duration);
	}

	@AuraEnabled
	public static void scenarioApexCPU(String transactionId) {
		Log.instance.resumeTransaction(transactionId);
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'Start - Apex CPU', 'Start - Apex CPU');
		try {
			List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 1];
			if (!accounts.isEmpty()) {
				accounts[0].Name = LOG_UTIL_DEMO_APEX_CPU;
				update accounts;
			}
		} catch (Exception e) {
			Log.instance.error(Log.Area.Community, e);
		}
	}

	@AuraEnabled
	public static void scenarioApexCPU2() {
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'Another class - Apex CPU 1', 'Another class - Apex CPU 1');
		for (pharos__Log__c log : [SELECT Id FROM pharos__Log__c LIMIT 2000]) {
		}
		Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'Another class - Apex CPU 2', 'Another class - Apex CPU 2');
	}

}