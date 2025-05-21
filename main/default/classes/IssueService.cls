public with sharing class IssueService {

	public static final String RECORD_TYPE_NAME_ISSUE = 'Issue';
	public static final String RECORD_TYPE_NAME_DUPLICATE = 'Duplicate';
	public static final String ISSUE_STATUS_NEW = 'New';
	public static final String ISSUE_STATUS_COMPLETED = 'Completed';
	public static final String ISSUE_STATUS_DUPLICATE = 'Duplicate';

	public static final String ORIGINATED_FROM_BROADCAST = 'Broadcast';
	public static final String POST_PROCESSING_STATUS_COMPLETED = 'Completed';

	public static final Integer LIMIT_LOGS_CALCULATE_COUNT = 1000;

	public static final Integer MAX_TEXT_AREA_27k_SIZE = 27000;

	public static Map<String, List<Log__c>> getMapLogsByHash(List<Log__c> logs) {
		Map<String, List<Log__c>> mapLogsByHash = new Map<String, List<Log__c>>();
		for (Log__c log : logs) {
			if (String.isNotBlank(log.Hash_1__c)) {
				if (mapLogsByHash.containsKey(log.Hash_1__c)) {
					mapLogsByHash.get(log.Hash_1__c).add(log);
				} else {
					mapLogsByHash.put(log.Hash_1__c, new List<Log__c>{log});
				}
			}
		}
		return mapLogsByHash;
	}

	public static Map<String, Issue__c> getMapIssuesByHash(Map<String, List<Log__c>> mapLogsByHash) {
		Map<String, Issue__c> mapIssuesByHash = new Map<String, Issue__c>();
		if (mapLogsByHash.isEmpty()) return mapIssuesByHash;

		List<Issue__c> issues = [SELECT Id, Bug_Tracker__c, Key__c, Status__c, Executable_Rules__c, Related_Issue__c, Related_Issue__r.Status__c, Notification_Integration_Status__c, Jira_Integration_Status__c FROM Issue__c WHERE Key__c IN :mapLogsByHash.keySet()];
		for (Issue__c issue : issues) {
			if (!mapIssuesByHash.containsKey(issue.Key__c)
					|| (mapIssuesByHash.containsKey(issue.Key__c) && issue.Status__c != ISSUE_STATUS_COMPLETED && issue.Status__c != ISSUE_STATUS_DUPLICATE)) {
				mapIssuesByHash.put(issue.Key__c, issue);
			}
		}
		Map<String, Issue__c> issueToReRunTicketing = new Map<String, Issue__c>();

		for (String hash : mapLogsByHash.keySet()) {
			if (mapIssuesByHash.containsKey(hash)) {
				Issue__c issue = mapIssuesByHash.get(hash);
				// if current issue re-occurs or a duplicate issue of a completed issue re-occurs
				if (issue.Status__c == ISSUE_STATUS_COMPLETED
						|| (issue.Status__c == ISSUE_STATUS_DUPLICATE && String.isNotBlank(issue.Related_Issue__c) && issue.Related_Issue__r.Status__c == ISSUE_STATUS_COMPLETED)) {
					issue.Regressed_On__c = System.now();
					issue.Status__c = ISSUE_STATUS_NEW;
					issue.Resolved_On__c = null;
					if (String.isNotBlank(issue.Executable_Rules__c)) {
						issue.Jira_Integration_Status__c = MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING;
					}
					issueToReRunTicketing.put(issue.Key__c, issue);
				}
			} else {
				Log__c log = mapLogsByHash.get(hash)[0];
				Issue__c issue = new Issue__c(
						Description__c = log.Details__c,
						First_Occurred_On__c = log.First_Occurred_On__c,
						Last_Occurred_On__c = log.Created_At__c,
						Key__c = log.Hash_1__c,
						Log_Count__c = 1,
						Log__c = log.Id,
						Organization_Name__c = log.Organization_Name__c,
						Priority__c = 'Medium',
						Status__c = 'New',
						Summary__c = log.Summary__c
				);
				mapIssuesByHash.put(issue.Key__c, issue);
			}
		}
		if(!issueToReRunTicketing.isEmpty()) {
			List<MonitoringUtil.MonitoringRule> jiraRules = MonitoringUtil.getJiraRules(null, MonitoringUtil.RULE_ISSUE_SOBJECT_TYPE_FIELD);
			List<MonitoringUtil.MonitoringRule> azureDevOpsRules = MonitoringUtil.getAzureDevOpsRules(null, MonitoringUtil.RULE_ISSUE_SOBJECT_TYPE_FIELD);

			for(Issue__c issue : issueToReRunTicketing.values()) {
				NotificationService.ExecutableRulesConfig config = NotificationService.getExecutableRuleConfig(issue);
				String ruleId;
				if(JiraSyncBatch.isJiraTaskUrl(issue.Bug_Tracker__c) && !jiraRules.isEmpty()) {
					ruleId = jiraRules.get(0).ruleId;
				}
				else if(JiraSyncBatch.isAzureDevOpsTaskUrl(issue.Bug_Tracker__c) && !azureDevOpsRules.isEmpty()) {
					ruleId = azureDevOpsRules.get(0).ruleId;
				}
				if(String.isNotBlank(ruleId)) {
					config.addToReRun(ruleId);
					issue.Executable_Rules__c = config.toJSON();
				}
			}
			mapIssuesByHash.putAll(issueToReRunTicketing);
		}
		return mapIssuesByHash;
	}

	public static void issueTracker(Map<String, List<Log__c>> mapLogsByHash, Map<String, Issue__c> mapIssuesByHash, Logger logger) {
		Map<String, Issue__c> successMapIssuesByHash = new Map<String, Issue__c>();
		Issue__c issueToCheckAutonumber;
		List<Issue__c> issuesToUpsert = new List<Issue__c>();
		List<Issue__c> issuesToInsert = new List<Issue__c>();
		List<Issue__c> issuesToUpdate = new List<Issue__c>();
		if (LimitsService.getMaxIssues() != null) {
			if (ConfigUtil.SETTINGS.Last_Issue_Number__c == null && BlurModeService.AVAILABLE_ISSUES_COUNT > 0) {
				for (Issue__c issue : mapIssuesByHash.values()) {
					if (String.isBlank(issue.Id) && issueToCheckAutonumber == null) {
						issueToCheckAutonumber = issue;
						break;
					}
				}
				if (issueToCheckAutonumber != null) {
					List<Issue__c> successIssues = DatabaseUtils.getInstance().performUpsertDML(new List<Issue__c>{issueToCheckAutonumber}, Schema.SObjectType.Issue__c)
							.handleError(IssueService.class.getName(), '.issueTracker', logger).getSuccessSObjects();
					List<Issue__c> issues = [SELECT Id, Name FROM Issue__c WHERE Id IN :successIssues];
					if (!issues.isEmpty()) {
						ConfigUtil.SETTINGS.Last_Issue_Number__c = getHighestIssueNumber(issues);
						DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c)
								.handleError(ConfigUtil.class.getName(), 'issueTracker', logger);
						BlurModeService.AVAILABLE_ISSUES_COUNT = null;
					}
				}
			}
			if (ConfigUtil.SETTINGS.Last_Issue_Number__c != null && BlurModeService.AVAILABLE_ISSUES_COUNT > 0) {
				for (Issue__c issue : mapIssuesByHash.values()) {
					if (String.isBlank(issue.Id) && BlurModeService.AVAILABLE_ISSUES_COUNT > 0) {
						issuesToInsert.add(issue);
						BlurModeService.AVAILABLE_ISSUES_COUNT--;
						if (BlurModeService.AVAILABLE_ISSUES_COUNT == 0) break;
					}
				}
			}
			if (BlurModeService.AVAILABLE_ISSUE_KEYS != null && !BlurModeService.AVAILABLE_ISSUE_KEYS.isEmpty()) {
				for (Issue__c issue : mapIssuesByHash.values()) {
					if (String.isNotBlank(issue.Id) && (issueToCheckAutonumber == null || issueToCheckAutonumber.Id != issue.Id) && BlurModeService.AVAILABLE_ISSUE_KEYS.contains(issue.Key__c)) {
						issuesToUpdate.add(issue);
					}
				}
			}
			if (!issuesToInsert.isEmpty()) issuesToUpsert.addAll(issuesToInsert);
			if (!issuesToUpdate.isEmpty()) issuesToUpsert.addAll(issuesToUpdate);
		} else {
			issuesToUpsert.addAll(mapIssuesByHash.values());
		}
		if (!issuesToUpsert.isEmpty()) {
			List<Issue__c> successIssues = DatabaseUtils.getInstance().performUpsertDML(issuesToUpsert, Schema.SObjectType.Issue__c)
					.handleError(IssueService.class.getName(), '.issueTracker', logger).getSuccessSObjects();
			List<Issue__c> issues = [SELECT Id, Name FROM Issue__c WHERE Id IN :successIssues];
			if (!issues.isEmpty()) {
				Integer highestIssueNumber = getHighestIssueNumber(issues);
				if (highestIssueNumber != null && ConfigUtil.SETTINGS.Last_Issue_Number__c != null && highestIssueNumber > ConfigUtil.SETTINGS.Last_Issue_Number__c) {
					ConfigUtil.SETTINGS.Last_Issue_Number__c = highestIssueNumber;
					DatabaseUtils.getInstance().performUpsertDML(new List<Logger_Settings__c>{ConfigUtil.SETTINGS}, Schema.SObjectType.Logger_Settings__c)
							.handleError(ConfigUtil.class.getName(), 'issueTracker', logger);
					BlurModeService.AVAILABLE_ISSUES_COUNT = null;
				}
			}
			if (issueToCheckAutonumber != null) successMapIssuesByHash.put(issueToCheckAutonumber.Key__c, issueToCheckAutonumber);
			for (Issue__c issue : successIssues) {
				successMapIssuesByHash.put(issue.Key__c, issue);
			}
		}
		List<Log__c> logsToUpdate = new List<Log__c>();
		for (String hash : mapLogsByHash.keySet()) {
			if (successMapIssuesByHash.containsKey(hash)) {
				for (Log__c log : mapLogsByHash.get(hash)) {
					logsToUpdate.add(new Log__c(Id = log.Id, Issue__c = successMapIssuesByHash.get(hash).Id));
				}
			}
		}
		if (!logsToUpdate.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(logsToUpdate, Schema.SObjectType.Log__c)
					.handleError(IssueService.class.getName(), '.issueTracker', logger);
		}
		List<Issue__c> issuesToCalculate = IssueService.calculateLogsCount(successMapIssuesByHash.keySet());
		if (!issuesToCalculate.isEmpty()) {
			List<Issue__c> successIssues = DatabaseUtils.getInstance().performUpdateDML(issuesToCalculate, Schema.SObjectType.Issue__c)
					.handleError(IssueService.class.getName(), '.issueTracker', logger).getSuccessSObjects();
			Set<Id> issueIds = (new Map<Id, Issue__c>(successIssues)).keySet();
			Integer logsCount = [
					SELECT COUNT()
					FROM Log__c
					WHERE Issue__c IN :issueIds
					OR (Issue__r.Related_Issue__c IN :issueIds AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
			];
			if (logsCount >= IssueService.LIMIT_LOGS_CALCULATE_COUNT) {
				IssueImpactBatch.getInstance(issueIds).startBatch();
			} else {
				IssueService.calculateImpactedObjects(issueIds, logger);
			}
		}
	}

	public static Integer getHighestIssueNumber(List<Issue__c> issues) {
		Integer highestIssueNumber = null;
		if (issues == null || issues.isEmpty()) {
			return null;
		}
		for (Issue__c issue : issues) {
			if (issue == null) {
				continue;
			}
			Integer currentIssueNumber = getNumberFromIssueName(issue.Name);
			if (currentIssueNumber != null && (highestIssueNumber == null || highestIssueNumber < currentIssueNumber)) {
				highestIssueNumber = currentIssueNumber;
			}
		}
		return highestIssueNumber;
	}

	public static Integer getNumberFromIssueName(String issueName) {
		if (String.isBlank(issueName)) {
			return null;
		}
		List<String> parts = issueName.split('-');
		if (parts.size() == 2) {
			return Integer.valueOf(parts[1].trim());
		}
		return null;
	}

	public static List<Issue__c> calculateLogsCount(Set<String> hashes) {
		List<Issue__c> issues = [
				SELECT Id, Log_Count__c, Last_Occurred_On__c
				FROM Issue__c
				WHERE Key__c IN :hashes
		];
		List<AggregateResult> aggregateResults = [
				SELECT COUNT(Id) log_count, Issue__c issue_id, Issue__r.Related_Issue__c relate_issue_id
				FROM Log__c
				WHERE Issue__c IN :issues
				OR (Issue__r.Related_Issue__c IN :issues AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
				GROUP BY Issue__c, Issue__r.Related_Issue__c
		];
		for (Issue__c issue : issues) {
			issue.Log_Count__c = 0;
			for (AggregateResult aggregateResult : aggregateResults) {
				if ((Id)aggregateResult.get('issue_id') == issue.Id) {
					issue.Log_Count__c += (Integer)aggregateResult.get('log_count');
				}
				if ((Id)aggregateResult.get('relate_issue_id') == issue.Id) {
					issue.Log_Count__c += (Integer)aggregateResult.get('log_count');
				}
			}
		}
		return issues;
	}

	public static void calculateImpactedObjects(Set<Id> issueIds, Logger logger) {
		List<Log__c> logs = [
				SELECT
						Id,
						Issue__c,
						Issue__r.Related_Issue__c,
						Issue__r.Status__c,
						User_Id__c,
						Related_Object_Type__c,
						Related_Id__c,
						Related_Objects__c,
						Created_At__c,
						Exception_Codes__c
				FROM Log__c
				WHERE Issue__c IN :issueIds
				OR (Issue__r.Related_Issue__c IN :issueIds AND Issue__r.Status__c = :ISSUE_STATUS_DUPLICATE)
		];
		Map<String, IssueWrapper> mapIssueWrappers = new Map<String, IssueWrapper>();
		fillImpactedObjects(logs, issueIds, mapIssueWrappers);
		updateImpactedObjects(issueIds, mapIssueWrappers, logger);
	}

	public static void fillImpactedObjects(List<Log__c> logs, Set<Id> issueIds, Map<String, IssueWrapper> mapIssueWrappers) {
		for (Log__c log : logs) {
			Set<String> issueIdsToCalculate = new Set<String>();
			if (issueIds.contains(log.Issue__c)) {
				issueIdsToCalculate.add(log.Issue__c);
			}
			if (String.isNotBlank(log.Issue__r.Related_Issue__c) && log.Issue__r.Status__c == IssueService.ISSUE_STATUS_DUPLICATE && issueIds.contains(log.Issue__r.Related_Issue__c)) {
				issueIdsToCalculate.add(log.Issue__r.Related_Issue__c);
			}
			for (String issueId : issueIdsToCalculate) {
				IssueWrapper issueWrapper = mapIssueWrappers.containsKey(issueId) ? mapIssueWrappers.get(issueId) : new IssueWrapper();
				if (issueWrapper.lastOccurredOn == null || issueWrapper.lastOccurredOn < log.Created_At__c) {
					issueWrapper.lastOccurredOn = log.Created_At__c;
				}
				if (String.isNotBlank(log.Related_Objects__c)) {
					try {
						Map<String, Set<String>> mapRelatedObjects = (Map<String, Set<String>>)JSON.deserialize(log.Related_Objects__c, Map<String, Set<String>>.class);
						if (issueWrapper.impactedObjects != null) {
							for (String relatedObject : mapRelatedObjects.keySet()) {
								if (issueWrapper.impactedObjects.containsKey(relatedObject)) {
									issueWrapper.impactedObjects.get(relatedObject).addAll(mapRelatedObjects.get(relatedObject));
								} else {
									issueWrapper.impactedObjects.put(relatedObject, mapRelatedObjects.get(relatedObject));
								}
							}
						} else {
							issueWrapper.impactedObjects = mapRelatedObjects;
						}
					} catch (JSONException e) {}
				}
				if (String.isNotBlank(log.Related_Object_Type__c) && String.isNotBlank(log.Related_Id__c)) {
					if (issueWrapper.impactedObjects != null) {
						if (issueWrapper.impactedObjects.containsKey(log.Related_Object_Type__c)) {
							issueWrapper.impactedObjects.get(log.Related_Object_Type__c).add(log.Related_Id__c);
						} else {
							issueWrapper.impactedObjects.put(log.Related_Object_Type__c, new Set<String>{log.Related_Id__c});
						}
					} else {
						issueWrapper.impactedObjects = new Map<String, Set<String>>{log.Related_Object_Type__c => new Set<String>{log.Related_Id__c}};
					}
				}
				if (String.isNotBlank(log.User_Id__c)) {
					if (issueWrapper.impactedUsers != null) {
						issueWrapper.impactedUsers.add(log.User_Id__c);
					} else {
						issueWrapper.impactedUsers = new Set<String>{log.User_Id__c};
					}
				}
				if (String.isNotBlank(log.Exception_Codes__c)) {
					if (issueWrapper.exceptionCodes != null) {
						issueWrapper.exceptionCodes.addAll(log.Exception_Codes__c.split(';'));
					} else {
						issueWrapper.exceptionCodes = new Set<String>(log.Exception_Codes__c.split(';'));
					}
				}
				mapIssueWrappers.put(issueId, issueWrapper);
			}
		}
	}

	public static void updateImpactedObjects(Set<Id> issueIds, Map<String, IssueWrapper> mapIssueWrappers, Logger logger) {
		List<Issue__c> issues = [
				SELECT
						Id,
						Impacted_Users__c,
						Impacted_Users_Count__c,
						Impacted_Objects__c,
						Impacted_Objects_Count__c,
						Impacted_Objects_by_Type__c,
						Last_Occurred_On__c,
						Exception_Codes__c
				FROM Issue__c
				WHERE Id IN :issueIds
		];
		for (Issue__c issue : issues) {
			IssueWrapper issueWrapper = mapIssueWrappers.get(issue.Id);
			if (issueWrapper != null) {
				Set<String> relatedIds = new Set<String>();
				Map<String, Integer> mapImpactedObjectTypes = new Map<String, Integer>();
				if (issueWrapper.impactedObjects != null) {
					for (String impactedObject : issueWrapper.impactedObjects.keySet()) {
						relatedIds.addAll(issueWrapper.impactedObjects.get(impactedObject));
						mapImpactedObjectTypes.put(impactedObject, issueWrapper.impactedObjects.get(impactedObject).size());
					}
				}
				if (issueWrapper.impactedUsers != null) {
					issue.Impacted_Users__c = JSON.serialize(truncateItems(MAX_TEXT_AREA_27k_SIZE, new List<String>(issueWrapper.impactedUsers)));
					issue.Impacted_Users_Count__c = issueWrapper.impactedUsers.size();
				}

				if (!relatedIds.isEmpty()) {
					issue.Impacted_Objects__c = JSON.serialize(truncateItems(MAX_TEXT_AREA_27k_SIZE, new List<String>(relatedIds)));
					issue.Impacted_Objects_Count__c = relatedIds.size();
				}
				if (!mapImpactedObjectTypes.isEmpty()) issue.Impacted_Objects_by_Type__c = JSON.serialize(mapImpactedObjectTypes);
				if (issueWrapper.lastOccurredOn != null) issue.Last_Occurred_On__c = issueWrapper.lastOccurredOn;
				if (issueWrapper.exceptionCodes != null) issue.Exception_Codes__c  = String.join(new List<String>(issueWrapper.exceptionCodes), ';');
			}
		}
		if (!issues.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(issues, Schema.SObjectType.Issue__c)
					.handleError(IssueService.class.getName(), '.updateImpactedObjects', logger);
		}
	}

	public static List<String> truncateItems(Integer maxSize, List<String> items) {
		List<String> result = new List<String>();
		if (items != null) {
			for (String item : items) {
				if ((result.size() + 1) * 15 < maxSize){
					result.add(item.left(15));
				} else {
					break;
				}
			}
		}
		return result;
	}

	public class IssueWrapper {
		public Datetime lastOccurredOn;
		public Map<String, Set<String>> impactedObjects;
		public Set<String> impactedUsers;
		public Set<String> exceptionCodes;
	}

}