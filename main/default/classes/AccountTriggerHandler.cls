public with sharing class AccountTriggerHandler {

	public static void beforeUpdate(List<Account> newList, Map<Id, Account> oldMap) {
		for (Account account : newList) {
			if (account.Name == LogUtilDemoController.LOG_UTIL_DEMO_TRIGGER || account.Name == LogUtilDemoController.LOG_UTIL_DEMO_FLOW || account.Name == LogUtilDemoController.LOG_UTIL_DEMO_APEX_CPU) {
				Log.instance.debug(Log.Type.AccountTrigger, Log.Area.Accounts, 'Account Before Update - Trigger Error', 'Account Before Update - Trigger Error');
			}
			if (account.Name == LogUtilDemoController.LOG_UTIL_DEMO_APEX_CPU) {
				LogUtilDemoController.scenarioApexCPU2();
			}
		}
	}

	public static void afterUpdate(List<Account> newList, Map<Id, Account> oldMap) {
		for (Account account : newList) {
			if (account.Name == LogUtilDemoController.LOG_UTIL_DEMO_TRIGGER) {
				account.addError(LogUtilDemoController.LOG_UTIL_DEMO_TRIGGER);
			}
		}
	}

}