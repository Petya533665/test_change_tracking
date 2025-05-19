public with sharing class PharosErrorReportActionController {

	@AuraEnabled(Cacheable=true)
	public static Boolean isAvailableSingleEmail() {
		Boolean EmailDeliverabilityEnabled = true;
		try {
			Messaging.reserveSingleEmailCapacity(1);
		} catch (System.NoAccessException e) {
			EmailDeliverabilityEnabled = false;
		}
		return LimitsService.getAvailableSingleEmail() >= 1 && EmailDeliverabilityEnabled;
	}

	@AuraEnabled
	public static Map<String, Object> getReportedInfo(String recordId) {
		Map<String, Object> reportedInfo = new Map<String, Object>();
		List<Log__c> logs = [SELECT Id, Hash_1__c FROM Log__c WHERE Id = :recordId];
		if (!logs.isEmpty()) {
			List<Log_Index__c> logIndexes = [SELECT Id, Reported_to_Pharos_On__c, CreatedBy.Name FROM Log_Index__c WHERE Hash__c = :logs[0].Hash_1__c AND Reported_to_Pharos_On__c != NULL];
			if (!logIndexes.isEmpty()) {
				reportedInfo.put('reportedToPharosOn', logIndexes[0].Reported_to_Pharos_On__c);
				reportedInfo.put('createdByName', logIndexes[0].CreatedBy.Name);
			}
		}
		return reportedInfo;
	}

	@AuraEnabled
	public static String getErrorEmailAddress() {
		return ErrorEmailReportBatch.PHAROS_ERROR_EMAIL_ADDRESS;
	}

	@AuraEnabled
	public static Integer getTotalOccurrences(String recordId) {
		List<Log__c> logs = [SELECT Id, First_Occurred_On__c, Created_At__c, Hash_1__c FROM Log__c WHERE Id = :recordId];
		if (!logs.isEmpty()) {
			return [
					SELECT COUNT()
					FROM Log__c
					WHERE Hash_1__c = :logs[0].Hash_1__c
			];
		}
		return 0;
	}

	@AuraEnabled
	public static void sendPharosErrorReport(String recordId, String summary, String details, String comments) {
		List<Log__c> logs = [
				SELECT Id, Category__c, Area__c, Summary__c, Details__c, Organization_Id__c, First_Occurred_On__c, Type__c, Created_At__c, Hash_1__c
				FROM Log__c
				WHERE Id = :recordId];
		if (!logs.isEmpty()) {
			logs[0].Summary__c = summary;
			logs[0].Details__c = details;
			ErrorEmailReportBatch.sendEmailReport(logs, new Map<String, String>{recordId => comments}, Logger.getInstance());
		}
		Logger.getInstance().flush();
	}

}