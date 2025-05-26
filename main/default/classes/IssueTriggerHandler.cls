public with sharing class IssueTriggerHandler {

	public static final String FLOW_CATEGORY = 'Flow';
	public static final String PROCESS_BUILDER_CATEGORY = 'Process Builder';
	public static final Set<System.Quiddity> UNAFFECTED_QUIDDITIES = new Set<System.Quiddity>{
			System.Quiddity.BATCH_ACS,
			System.Quiddity.BATCH_APEX,
			System.Quiddity.BATCH_CHUNK_PARALLEL,
			System.Quiddity.BATCH_CHUNK_SERIAL,
			System.Quiddity.FUTURE,
			System.Quiddity.QUEUEABLE,
			System.Quiddity.RUNTEST_SYNC,
			System.Quiddity.RUNTEST_ASYNC
	};

	/**
	 * @description This is a test-only static variable to throw a DML exception for testing purposes.
	 * @see IssueTriggerHandlerTest for usage.
	 */
	@TestVisible
	private static Boolean throwDmlExceptionForTest = false;

	public static void onBeforeInsert(List<Issue__c> newIssues) {
		updateRecordTypeId(newIssues, null);

		if (Test.isRunningTest() && throwDmlExceptionForTest) {
			// Simulate a DML exception specifically during the Issue upsert phase
			DmlException forcedException = new DmlException();
			forcedException.setMessage('Forced DML exception for testing issue tracker failure.');
			throw forcedException;
		}
	}

	public static void onAfterInsert(List<Issue__c> newIssues) {
		if(!newIssues.isEmpty()) {
			Map<String, Issue__c> mapIssues = new Map<String, Issue__c>(newIssues);
			NotificationService.newIssueInTransactionIds.addAll(mapIssues.keySet());
		}
		
		Map<String, String> mapHashes2ByLogId = getMapHashes2ByLogId(newIssues);
		Map<String, String> mapHashes3ByLogId = getMapHashes3ByLogId(newIssues);
		List<String> statuses = new List<String>{IssueService.ISSUE_STATUS_COMPLETED, IssueService.ISSUE_STATUS_DUPLICATE};
		List<Issue__c> existIssues = [
			SELECT Id, Related_Issue__c, Log__r.Hash_2__c, Log__r.Hash_3__c, Log__r.Category__c, Status__c
			FROM Issue__c
			WHERE (Status__c NOT IN :statuses OR (Id NOT IN :newIssues AND Status__c IN :statuses))
			AND (Log__r.Hash_2__c IN :mapHashes2ByLogId.values() OR (Log__r.Hash_3__c IN :mapHashes3ByLogId.values() AND Log__r.Category__c IN (:FLOW_CATEGORY, :PROCESS_BUILDER_CATEGORY)))
			AND Related_Issue__c = NULL
			ORDER BY CreatedDate
		];
		Map<Id, Issue__c> mapIssues = new Map<Id, Issue__c>(newIssues);
		for (Issue__c newIssue : existIssues) {
			if (mapIssues.containsKey(newIssue.Id)) {
				String hash2IssueId;
				String hash3IssueId;
				for (Issue__c existIssue : existIssues) {
					if (newIssue.Id == existIssue.Id
							|| statuses.contains(existIssue.Status__c)
							|| (String.isNotBlank(existIssue.Related_Issue__c) && existIssue.Related_Issue__c == newIssue.Id)) {
						continue;
					}
					if (mapHashes2ByLogId.containsKey(newIssue.Log__c)
							&& mapHashes2ByLogId.get(newIssue.Log__c) == existIssue.Log__r.Hash_2__c) {
						hash2IssueId = existIssue.Id;
						break;
					}
					if (mapHashes3ByLogId.containsKey(newIssue.Log__c)
							&& mapHashes3ByLogId.get(newIssue.Log__c) == existIssue.Log__r.Hash_3__c) {
						hash3IssueId = existIssue.Id;
					}
				}
				newIssue.Related_Issue__c = String.isNotBlank(hash2IssueId) ? hash2IssueId : hash3IssueId;
			}
		}
		for (Issue__c existIssue : existIssues) {
			if (statuses.contains(existIssue.Status__c) && String.isBlank(existIssue.Related_Issue__c)) {
				String hash2IssueId;
				String hash3IssueId;
				for (Issue__c newIssue : newIssues) {
					if (existIssue.Id == newIssue.Id) continue;
					if (mapHashes2ByLogId.containsKey(newIssue.Log__c)
							&& mapHashes2ByLogId.get(newIssue.Log__c) == existIssue.Log__r.Hash_2__c) {
						hash2IssueId = newIssue.Id;
						break;
					}
					if (mapHashes3ByLogId.containsKey(newIssue.Log__c)
							&& mapHashes3ByLogId.get(newIssue.Log__c) == existIssue.Log__r.Hash_3__c) {
						hash3IssueId = newIssue.Id;
					}
				}
				existIssue.Related_Issue__c = String.isNotBlank(hash2IssueId) ? hash2IssueId : hash3IssueId;
			}
		}
		DatabaseUtils.getInstance().performUpdateDML(existIssues, Schema.SObjectType.Issue__c)
				.handleError(IssueTriggerHandler.class.getName(), '.onAfterInsert');
		// TODO 1643
		// DevOps Center
		try {
			if (!Test.isRunningTest()) {
				Set<String> setIssueIds = new Set<String>();
				for (Issue__c issue : newIssues) {
					setIssueIds.add(issue.Id);
				}
				DevOpsCenterBatch.getInstance(setIssueIds).startBatch();
			}
		} catch (Exception e) {}
	}

	public static void onBeforeUpdate(List<Issue__c> newIssues, Map<Id, Issue__c> oldIssuesMap) {
		updateRecordTypeId(newIssues, oldIssuesMap);
	}

	public static void onAfterUpdate(List<Issue__c> newIssues, Map<Id, Issue__c> oldIssuesMap) {
		Set<Id> setIssueIds = new Set<Id>();
		for (Issue__c issue : newIssues) {
			if (oldIssuesMap.containsKey(issue.Id)
					&& issue.Status__c != oldIssuesMap.get(issue.Id).Status__c
					&& issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE) {
				setIssueIds.add(issue.Id);
			}
		}
		List<Issue__c> issuesToUpdate = [
				SELECT Id, Related_Issue__c, Related_Issue__r.Related_Issue__c
				FROM Issue__c
				WHERE Related_Issue__c IN :setIssueIds
				AND Status__c = :IssueService.ISSUE_STATUS_DUPLICATE
		];
		for (Issue__c issue : issuesToUpdate) {
			issue.Related_Issue__c = issue.Related_Issue__r.Related_Issue__c;
		}
		DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
				.handleError(IssueTriggerHandler.class.getName(), '.onAfterUpdate');

		// push Issue priority to ticketing (jira / azure devops)
		if(ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c
			|| (PermissionsUtil.AzureDevOpsIntegrationEnabled && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c)) {
			
			List<Issue__c> toTicketing = new List<Issue__c>();
			for (Issue__c issue : newIssues) {
				Issue__c oldIssue = oldIssuesMap.get(issue.Id);

				if(issue.Bug_Tracker__c != null 
					&& issue.Priority__c != oldIssue.Priority__c
					&& !issue.Override_Priority__c
					&& !oldIssue.Override_Priority__c) {

					toTicketing.add(issue);
				}
			}
			if(!toTicketing.isEmpty()) {
				JiraSyncBatch.syncTicketingPriorityForIssues(toTicketing);
			}
		}

		// push Issue relates to ticketing (jira / azure devops)
		if((ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c || ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c)
			|| (PermissionsUtil.AzureDevOpsIntegrationEnabled && (ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c || ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c))) {
			
			Set<String> toTicketing = new Set<String>();
			for (Issue__c issue : newIssues) {
				Issue__c oldIssue = oldIssuesMap.get(issue.Id);

				if(issue.Bug_Tracker__c != null
					// link/unlink
					&& (issue.Related_Issue__c != oldIssue.Related_Issue__c
					// duplicate/not a duplicate
					|| (issue.Status__c != oldIssue.Status__c 
						&& (
							// any => duplicate
							(issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE && oldIssue.Status__c != IssueService.ISSUE_STATUS_DUPLICATE)
							// duplicate => not a duplicate
							|| (issue.Status__c != IssueService.ISSUE_STATUS_DUPLICATE && oldIssue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE))
						)
					// change ticket
					|| issue.Bug_Tracker__c != oldIssue.Bug_Tracker__c)) {
					
					if(issue.Related_Issue__c != null) {
						toTicketing.add(issue.Related_Issue__c);
					}
					if(oldIssue.Related_Issue__c != null) {
						toTicketing.add(oldIssue.Related_Issue__c);
					}
					toTicketing.add(issue.Id);
				}
			}
			if(!toTicketing.isEmpty()) {
				JiraSyncBatch.syncTicketingRelationsForIssues(toTicketing);
			}
		}
	}

	private static Map<String, String> getMapHashes2ByLogId(List<Issue__c> issues) {
		Set<String> setLogIds = new Set<String>();
		for (Issue__c issue : issues) {
			if (issue.Related_Issue__c == null) setLogIds.add(issue.Log__c);
		}
		Map<String, String> mapHashes2ByLogId = new Map<String, String>();
		for (Log__c log : [SELECT Id, Hash_2__c FROM Log__c WHERE Id IN :setLogIds]) {
			mapHashes2ByLogId.put(log.Id, log.Hash_2__c);
		}
		return mapHashes2ByLogId;
	}

	private static Map<String, String> getMapHashes3ByLogId(List<Issue__c> issues) {
		Set<String> setLogIds = new Set<String>();
		for (Issue__c issue : issues) {
			if (issue.Related_Issue__c == null) setLogIds.add(issue.Log__c);
		}
		Map<String, String> mapHashes3ByLogId = new Map<String, String>();
		for (Log__c log : [SELECT Id, Hash_3__c FROM Log__c WHERE Id IN :setLogIds AND Category__c IN (:FLOW_CATEGORY, :PROCESS_BUILDER_CATEGORY)]) {
			mapHashes3ByLogId.put(log.Id, log.Hash_3__c);
		}
		return mapHashes3ByLogId;
	}

	public static void updateRecordTypeId(List<Issue__c> newIssues, Map<Id, Issue__c> oldIssuesMap) {
		String issueRecordTypeId = Schema.SObjectType.Issue__c.getRecordTypeInfosByName().get(IssueService.RECORD_TYPE_NAME_ISSUE).getRecordTypeId();
		String duplicateRecordTypeId = Schema.SObjectType.Issue__c.getRecordTypeInfosByName().get(IssueService.RECORD_TYPE_NAME_DUPLICATE).getRecordTypeId();
		for (Issue__c issue : newIssues) {
			if ((oldIssuesMap == null && String.isBlank(issue.RecordTypeId))
					|| (oldIssuesMap != null && ((issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE && oldIssuesMap.get(issue.Id).Status__c != IssueService.ISSUE_STATUS_DUPLICATE)
					|| (issue.Status__c != IssueService.ISSUE_STATUS_DUPLICATE && oldIssuesMap.get(issue.Id).Status__c == IssueService.ISSUE_STATUS_DUPLICATE)))) {
				issue.RecordTypeId = issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE
						? duplicateRecordTypeId
						: issueRecordTypeId;
			}
		}
	}

	public static void onBeforeDelete(Map<Id, Issue__c> oldIssuesMap) {
		List<Issue__c> issuesToUpdate = [SELECT Id, Status__c, Related_Issue__c FROM Issue__c WHERE Id NOT IN :oldIssuesMap.keySet() AND Related_Issue__c IN :oldIssuesMap.keySet()];
		Map<Id, List<Issue__c>> issuesMap = new Map<Id, List<Issue__c>>();
		for (Issue__c issue : issuesToUpdate) {
			if (issuesMap.containsKey(issue.Related_Issue__c)) {
				issuesMap.get(issue.Related_Issue__c).add(issue);
			} else {
				issuesMap.put(issue.Related_Issue__c, new List<Issue__c>{issue});
			}
		}
		for (Id oldIssueId : issuesMap.keySet()) {
			Issue__c newParentIssue;
			for (Issue__c issue : issuesMap.get(oldIssueId)) {
				if (issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE) {
					issue.Status__c = IssueService.ISSUE_STATUS_NEW;
					newParentIssue = issue;
					break;
				}
			}
			for (Issue__c issue : issuesMap.get(oldIssueId)) {
				if (newParentIssue != null && issue.Id != newParentIssue.Id) {
					issue.Related_Issue__c = newParentIssue.Id;
				} else if (String.isNotBlank(oldIssuesMap.get(issue.Related_Issue__c).Related_Issue__c)
						&& !oldIssuesMap.containsKey(oldIssuesMap.get(issue.Related_Issue__c).Related_Issue__c)) {
					issue.Related_Issue__c = oldIssuesMap.get(issue.Related_Issue__c).Related_Issue__c;
				}
			}
		}
		DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
				.handleError(IssueTriggerHandler.class.getName(), '.onBeforeDelete');
		deleteRelatedTraceSchedule(oldIssuesMap.keySet());
		LogTriggerHelper.deleteContentDocument(oldIssuesMap.keySet());
	}

	private static void deleteRelatedTraceSchedule(Set<Id> issueIds) {
		if (!issueIds.isEmpty()) {
			List<Trace_Schedule__c> traceSchedules = [SELECT Id FROM Trace_Schedule__c WHERE Issue__c IN :issueIds];
			List<Trace_Request__c> traceRequests = [SELECT Id FROM Trace_Request__c WHERE Issue__c IN :issueIds];
			List<Trace_Result__c> traceResults = [SELECT Id FROM Trace_Result__c WHERE Issue__c IN :issueIds];

			Set<Id> setContentDocumentIds = new Set<Id>();
			for (ContentDocumentLink contentDocumentLink : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Trace_Result__c WHERE Issue__c IN :issueIds)]) {
				setContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
			}
			List<ContentDocument> lstContentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN :setContentDocumentIds];

			DatabaseUtils.getInstance().performDeleteDML(lstContentDocuments, Schema.SObjectType.ContentDocument)
					.handleError(IssueTriggerHandler.class.getName(), '.deleteRelatedTraceSchedule');
			DatabaseUtils.getInstance().performDeleteDML(traceResults, Schema.SObjectType.Trace_Result__c)
					.handleError(IssueTriggerHandler.class.getName(), '.deleteRelatedTraceSchedule');
			DatabaseUtils.getInstance().performDeleteDML(traceRequests, Schema.SObjectType.Trace_Request__c)
					.handleError(IssueTriggerHandler.class.getName(), '.deleteRelatedTraceSchedule');
			DatabaseUtils.getInstance().performDeleteDML(traceSchedules, Schema.SObjectType.Trace_Schedule__c)
					.handleError(IssueTriggerHandler.class.getName(), '.deleteRelatedTraceSchedule');
		}
	}

}