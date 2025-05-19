public with sharing class LogTriggerHandler {

	public static void onAfterInsert(List<Log__c> newLogs) {
		issueTracker(newLogs, null);
	}

	public static void onAfterUpdate(List<Log__c> newLogs, Map<Id, Log__c> oldLogsMap) {
		issueTracker(newLogs, oldLogsMap);
	}

	private static void issueTracker(List<Log__c> newLogs, Map<Id, Log__c> oldLogsMap) {
		List<Log__c> logs = new List<Log__c>();
		for (Log__c log : newLogs) {
			Log__c oldLog = (oldLogsMap != null && oldLogsMap.get(log.Id) != null) ? oldLogsMap.get(log.Id) : null;
			if (!log.Do_Not_Create_Issue__c && (isBroadcastLog(log, oldLog)	|| isRegularErrorLogPostprocessingCompleted(log, oldLog))) {
				logs.add(log);
			}
		}
		Map<String, List<Log__c>> mapLogsByHash = IssueService.getMapLogsByHash(logs);
		Map<String, Issue__c> mapIssuesByHash = IssueService.getMapIssuesByHash(mapLogsByHash);
		IssueService.issueTracker(mapLogsByHash, mapIssuesByHash, Logger.getInstance());
	}

	private static Boolean isBroadcastLog(Log__c newLog, Log__c oldLog) {
		if (newLog.Originated_From__c == IssueService.ORIGINATED_FROM_BROADCAST && oldLog == null) {
			return true;
		}
		return false;
	}

	private static Boolean isRegularErrorLogPostprocessingCompleted(Log__c newLog, Log__c oldLog) {
		if (oldLog != null
				&& newLog.Type__c != FlowService.FLOW_TYPE_ORCHESTRATOR
				&& newLog.Post_Processing_Status__c != oldLog.Post_Processing_Status__c
				&& newLog.Post_Processing_Status__c == IssueService.POST_PROCESSING_STATUS_COMPLETED) {
			return true;
		}
		return false;
	}

}