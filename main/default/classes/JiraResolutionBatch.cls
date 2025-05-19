public with sharing class JiraResolutionBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>,Database.Stateful, Database.AllowsCallouts, Schedulable, Database.RaisesPlatformEvents {

	public JiraResolutionBatch() {}

	public void execute(SchedulableContext sc) {
		LogServiceScheduler.rescheduleCronTriggers();
	}

	private static JiraResolutionBatch instance = null;

	public static JiraResolutionBatch getInstance() {
		if (instance == null) {
			instance = new JiraResolutionBatch(Logger.getInstance());
		}
		return instance;
	}

	private JiraResolutionBatch(Logger logger) {
		super(logger);
		BATCH_SCOPE = 100;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('JiraResolutionBatch', this);
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Log__c WHERE Bug_Tracker__c != NULL AND Resolved_On__c = NULL];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id, Bug_Tracker__c, Resolved_On__c, Hash_1__c, Organization_Id__c
			FROM Log__c
			WHERE Bug_Tracker__c != NULL AND Resolved_On__c = NULL
			ORDER BY Created_At__c
		]);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope){
		List<Log__c> logs = (List<Log__c>)scope;
		Map<Id, Log__c> toUpdate = new Map<Id, Log__c>();

		List<AsyncApexJob> manageTokensJob = DatabaseUtils.getCurrentJobs(new List<String>{'ManageTokensBatch'});
		if (!manageTokensJob.isEmpty()) {
			return;
		}

		List<Log__c> logsJira = new List<Log__c>();
		List<Log__c> logsAzureDevOps = new List<Log__c>();
		for (Log__c log : logs) {
			if (JiraSyncBatch.isJiraTaskUrl(log.Bug_Tracker__c)) {
				logsJira.add(log);
			}
			else if (JiraSyncBatch.isAzureDevOpsTaskUrl(log.Bug_Tracker__c)) {
				logsAzureDevOps.add(log);
			}
		}
		if (!logsJira.isEmpty()) {
			toUpdate.putAll(processJiraSync(logsJira));
		}
		if (!logsAzureDevOps.isEmpty()) {
			toUpdate.putAll(processAzureDevOpsSync(logsAzureDevOps));
		}
		
		Set<String> logIndexKeys = new Set<String>();
		for (Log__c log : logs) {
			if (toUpdate.containsKey(log.Id)) {
				logIndexKeys.add(ConfigUtil.getLogIndexKey(log.Hash_1__c, log.Organization_Id__c));
			}
		}
		if (!logIndexKeys.isEmpty()) {
			ConfigUtil.LogIndexHelper helper = new ConfigUtil.LogIndexHelper(logIndexKeys);
			for (Log__c log : logs) {
				if (toUpdate.containsKey(log.Id)) {
					ConfigUtil.LogIndex index = helper.getLogIndex(log);
					if (index != null) {
						index.resolvedOn = toUpdate.get(log.Id).Resolved_On__c;
						helper.updateLogIndex(index);
					}
				}
			}
			helper.saveLogIndexes(loggerInstance);
		}

		DatabaseUtils.getInstance().performUpdateDML(toUpdate.values(), Schema.SObjectType.Log__c)
				.handleError(JiraResolutionBatch.class.getName(), 'execute', loggerInstance);
	}

	public void finish(Database.BatchableContext BC) {
		loggerInstance?.flush();
	}

	public List<Log__c> processJiraSync(List<Log__c> logs) {
		List<Log__c> result = new List<Log__c>();

		if (String.isNotBlank(JiraService.JIRA_OAUTH_TOKEN)) {
			List<String> keys = JiraService.getJiraKeys(logs, this.loggerInstance);
			Map<String, Datetime> resolutionDatetimes= JiraService.getService().getResolutionDatetimeByTaskKey(keys, this.loggerInstance);
			for (Log__c log : logs) {
				try {
					String key = JiraService.getIssueKeyByUrl(log.Bug_Tracker__c);
					if (String.isNotBlank(key)) {
						Datetime resolutionDatetime = resolutionDatetimes.get(key);
						if (resolutionDatetime != null) {
							result.add(new Log__c(Id = log.Id, Resolved_On__c = resolutionDatetime));
						}
					}
				}
				catch(Exception e) {
					this.loggerInstance?.add(loggerInstance.getInternalError(e, log.Id, JiraResolutionBatch.class.getName(), 'getResolutionDatetimeByTaskKey'));
				}
			}
		}
		return result;
	}

	public List<Log__c> processAzureDevOpsSync(List<Log__c> logs) {
		List<Log__c> result = new List<Log__c>();

		if (String.isNotBlank(AzureService.OAUTH_API_TOKEN)) {
			List<String> workItemIds = new List<String>();
			String organizationId;
			String projectId;
			for (Log__c log : logs) {
				AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(log.Bug_Tracker__c);
				workItemIds.add(urlWorkItem.workItemId);
				organizationId = urlWorkItem.organizationName;
				projectId = urlWorkItem.projectIdOrName;
			}

			Map<String, Datetime> resolutionDatetimes = AzureService.getResolutionDatetimeByWorkItemId(organizationId, projectId,workItemIds, this.loggerInstance);

			for (Log__c log : logs) {
				try {
					AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(log.Bug_Tracker__c);
					Datetime resolutionDatetime = resolutionDatetimes.get(urlWorkItem.workItemId);
					if (resolutionDatetime != null) {
						result.add(new Log__c(Id = log.Id, Resolved_On__c = resolutionDatetime));
					}
				}
				catch(Exception e) {
					loggerInstance?.addInternalError(e, log.Id, JiraResolutionBatch.class.getName(), 'getResolutionDatetimeByWorkItemId');
				}
			}
		}
		return result;
	}
}