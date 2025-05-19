public with sharing class JiraSyncBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private Boolean hasUpdateRules = false;
	private List<Issue__c> regressedIssues = new List<Issue__c>();
	public static Boolean skipSync = false;

	private static JiraSyncBatch instance = null;

	public static JiraSyncBatch getInstance() {
		if (instance == null) {
			instance = new JiraSyncBatch(Logger.getInstance());
		}
		return instance;
	}

	private JiraSyncBatch(Logger logger) {
		super(logger);
		this.hasUpdateRules = hasUpdateRules();
		if (Test.isRunningTest()) BATCH_SCOPE = 2;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('JiraSyncBatch', this);
	}

	public override Boolean initialValidation() {
		return (PermissionsUtil.IssueTrackingEnabled
				&& (ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c
				|| ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c
				|| ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c
				|| ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c))

				|| (PermissionsUtil.AzureDevOpsIntegrationEnabled
				&& (ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c
				|| ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c
				|| ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c
				|| ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c));
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Issue__c WHERE Bug_Tracker__c != NULL];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id, Bug_Tracker__c, Priority__c, Status__c, Override_Priority__c, Executable_Rules__c
			FROM Issue__c
			WHERE Bug_Tracker__c != NULL
			ORDER BY First_Occurred_On__c
		]);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope){
		List<Issue__c> issues = (List<Issue__c>)scope;

		List<AsyncApexJob> manageTokensJob = DatabaseUtils.getCurrentJobs(new List<String>{'ManageTokensBatch'});
		if (!manageTokensJob.isEmpty()) {
			return;
		}

		SynchronizeTicketProcess process = getInstance(issues.get(0), this.loggerInstance);
		process.processSync(this.hasUpdateRules);

		if (!process.getRegressedIssues().isEmpty()) {
			this.regressedIssues.addAll(process.getRegressedIssues());
		}
	}

	public void finish(Database.BatchableContext BC) {
		// kick-off notification/ticketing batches
		DatabaseUtils.getInstance().performUpdateDML(regressedIssues, Schema.SObjectType.Issue__c)
			.handleError(JiraSyncBatch.class.getName(), 'finish', loggerInstance);
		loggerInstance?.flush();
	}

	public static Boolean isJiraTaskUrl(String url) {
		return (String.isNotBlank(url) && url.contains('/browse/'));
	}

	public static Boolean isAzureDevOpsTaskUrl(String url) {
		return (String.isNotBlank(url) && url.contains('/_workitems/edit/'));
	}

	public static void syncTicketingPriorityForIssues(List<Issue__c> issues) {
		if(!skipSync && ((PermissionsUtil.IssueTrackingEnabled && ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c)
			|| (PermissionsUtil.AzureDevOpsIntegrationEnabled && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c))) {
			QueueableJobChain chain = new QueueableJobChain();
			for(Issue__c issue : issues) {
				chain.chainFirst(new TicketingSyncPriorityQueueable(chain, issue));
			}
			chain.runNext();
		}
	}

	public static void syncTicketingRelationsForIssues(Set<String> issueIds) {
		if(!skipSync && ((PermissionsUtil.IssueTrackingEnabled && (ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c || ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c))
			|| (PermissionsUtil.AzureDevOpsIntegrationEnabled && (ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c || ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c)))) {

			List<Issue__c> issues = [SELECT Id, Bug_Tracker__c, Priority__c, Status__c, Override_Priority__c, Executable_Rules__c FROM Issue__c WHERE Id IN:issueIds];
			QueueableJobChain chain = new QueueableJobChain();
			for(Issue__c issue : issues) {
				chain.chainFirst(new TicketingSyncRelationsQueueable(chain, issue));
			}
			chain.runNext();
		}
	}

	public static Boolean hasUpdateRules() {
		String query = new QBuilder(Rule__c.SObjectType)
			.selectFields(new Set<String>{'Id'})
			.add(QBuilder.condition('Active__c').equalsTo(true))
			.add(QBuilder.condition('Is_Update__c').equalsTo(true))
			.add(QBuilder.condition('SobjectType__c').equalsTo(ConfigUtil.ISSUE_SOBJECT_NAME))
			.build();
		return !Database.query(query).isEmpty();
	}

	public static Map<String, String> MAP_ISSUE_PRIORITY_TO_AZURE_PRIORITY = new Map<String, String> {
		'Lowest' => '1',
		'Low' => '1',
		'Medium' => '2',
		'High' => '3',
		'Highest' => '4'
	};

	public static Map<String, String> MAP_AZURE_PRIORITY_TO_ISSUE_PRIORITY = new Map<String, String> {
		'1' => 'Low',
		'2' => 'Medium',
		'3' => 'High',
		'4' => 'Highest'
	};

	public static String convertIssuePriorityToAzureDevOpsPriority(String priority){
		return MAP_ISSUE_PRIORITY_TO_AZURE_PRIORITY.get(priority);
	}

	public static String convertAzureDevOpsPriorityToIssuePriority(String priority){
		return MAP_AZURE_PRIORITY_TO_ISSUE_PRIORITY.get(priority);
	}

	public class TicketingSyncPriorityQueueable extends ChainedQueuable implements Database.AllowsCallouts {
		private Issue__c issue;

		public TicketingSyncPriorityQueueable(QueueableJobChain chain, Issue__c issue) {
			super(chain);
			this.issue = issue;
		}
		public override void execute(QueueableContext context) {
			try {
				SynchronizeSettings settings = new SynchronizeSettings().enablePrioritySfdcToTicketing();
				SynchronizeTicketProcess process = getInstance(settings, this.issue, null);
				process.processSync();
			}
			catch (Exception e) {
				Logger.getInstance().internalError(e, this.issue.Id, true, TicketingSyncPriorityQueueable.class.getName(), 'execute');
			}
			finally {
				if(chain.hasNext()) {
					super.execute(context);
				}
			}
		}
	}

	public class TicketingSyncRelationsQueueable extends ChainedQueuable implements Database.AllowsCallouts {
		private Issue__c issue;

		public TicketingSyncRelationsQueueable(QueueableJobChain chain, Issue__c issue) {
			super(chain);
			this.issue = issue;
		}
		public override void execute(QueueableContext context) {
			try {
				SynchronizeSettings settings = new SynchronizeSettings().enableRelations();
				SynchronizeTicketProcess process = getInstance(settings, this.issue, null);
				process.processSync();
			}
			catch (Exception e) {
				Logger.getInstance().internalError(e, this.issue.Id, true, TicketingSyncRelationsQueueable.class.getName(), 'execute');
			}
			finally {
				if(chain.hasNext()) {
					super.execute(context);
				}
			}
		}
	}

	public static SynchronizeTicketProcess getInstance(Issue__c issue, Logger logger) {
		SynchronizeSettings settings = new SynchronizeSettings().enableAll();
		return getInstance(settings, issue, logger);
	}

	public static SynchronizeTicketProcess getInstance(SynchronizeSettings settings, Issue__c issue, Logger logger) {
		List<Issue__c> issues = [
			SELECT Id, Bug_Tracker__c, Related_Issue__c, Status__c, Priority__c,
				Related_Issue__r.Bug_Tracker__c, Related_Issue__r.Status__c, Executable_Rules__c
			FROM Issue__c 
			WHERE Id =:issue.Id
		];
		issue = issues.get(0);

		if(isJiraTaskUrl(issue?.Bug_Tracker__c)) {
			return new SynchronizeTicketProcessJiraImpl(settings, issue, logger);
		}
		else if(isAzureDevOpsTaskUrl(issue?.Bug_Tracker__c)) {
			return new SynchronizeTicketProcessAzureDevOpsImpl(settings, issue, logger);
		}
		return null;
	}

	public interface SynchronizeTicketProcess {
		Boolean isSynchronizeRelatedTicketsEnabled();
		Boolean isSynchronizeDuplicatedTicketsEnabled();
		Boolean isSynchronizeCompletedStatusEnabled();
		Boolean isSynchronizeAutoUpdateIssuePriorityEnabled();
		Boolean isSynchronizeAutoUpdateTicketPriorityEnabled();
		Boolean isTicketStatusNotCompleted();
		Boolean isOAuthTokenBlank();
		void populateSfdcRelations();
		void populateRemoteRelations();
		void retrieveTicket();
		void syncRelations();
		void syncPriority();
		void syncCompletedStatus();
		void setTicketPriority();
		void processSync();
		void processSync(Boolean hasUpdateRules);
		DateTime getResolutionDatetime();
		String getTicketPriority();
		String getTicketIdFromTicketLink(String bugTrackerLink);
		List<Issue__c> getRegressedIssues();
	}

	public class SynchronizeSettings {
		public Boolean syncRelated;
		public Boolean syncDuplicated;
		public Boolean syncCompletedStatus;
		public Boolean syncPrioritySfdcToTicketing;
		public Boolean syncPriorityTicketingToSfdc;

		public SynchronizeSettings() {
			this.syncRelated = false;
			this.syncDuplicated = false;
			this.syncCompletedStatus = false;
			this.syncPrioritySfdcToTicketing = false;
			this.syncPriorityTicketingToSfdc = false;
		}

		public SynchronizeSettings enableAll() {
			this.syncRelated = true;
			this.syncDuplicated = true;
			this.syncCompletedStatus = true;
			this.syncPriorityTicketingToSfdc = true;
			return this;
		}

		public SynchronizeSettings enablePrioritySfdcToTicketing() {
			this.syncPrioritySfdcToTicketing = true;
			return this;
		}

		public SynchronizeSettings enableRelations() {
			this.syncRelated = true;
			this.syncDuplicated = true;
			return this;
		}
	}

	public class TicketRelationInfo {
		public Set<String> relatedIssueKeys;
		public Set<String> duplicatedIssueKeys;
		public Map<String, String> relatedIssueKeysMap;
		public Map<String, String> duplicatedIssueKeysMap;

		public TicketRelationInfo() {
			this.relatedIssueKeys = new Set<String>();
			this.duplicatedIssueKeys = new Set<String>();
			this.relatedIssueKeysMap = new Map<String, String>();
			this.duplicatedIssueKeysMap = new Map<String, String>();
		}
	}

	public abstract class SynchronizeTicketProcessDefaultImpl implements SynchronizeTicketProcess {
		private SynchronizeSettings settings;
		private Issue__c issue;
		private Logger logger;
		private TicketRelationInfo sfdcRelationInfo;
		private TicketRelationInfo remoteRelationInfo;
		private TicketRelationInfo parentRemoteRelationInfo;
		private String ticketId;
		private Boolean remoteTicketNotFound = false;

		private JiraService.JiraIssue jiraIssue;
		private AzureService.AzureDevOpsWorkItem workItem;
		private AzureService.AzureDevOpsWorkItem parentWorkItem;

		private List<Issue__c> regressedIssues;
		private Map<Id, Issue__c> toUpdate;


		public SynchronizeTicketProcessDefaultImpl(SynchronizeSettings settings, Issue__c issue, Logger logger) {
			this.settings = settings;
			this.issue = issue;
			this.logger = logger;
			this.sfdcRelationInfo = new TicketRelationInfo();
			this.remoteRelationInfo = new TicketRelationInfo();
			this.parentRemoteRelationInfo = new TicketRelationInfo();
			this.regressedIssues = new List<Issue__c>();
			this.toUpdate = new Map<Id, Issue__c>();

			retrieveTicket();

			if(!this.remoteTicketNotFound && (isSynchronizeRelatedTicketsEnabled() || isSynchronizeDuplicatedTicketsEnabled())) {
				populateSfdcRelations();
				populateRemoteRelations();
			}
		}

		public virtual void processSync() {
			this.processSync(false);
		}

		public virtual void processSync(Boolean hasUpdateRules) {
			if (isOAuthTokenBlank()) return;

			// unlink bug tracker link
			if(this.remoteTicketNotFound) {
				this.toUpdate.put(this.issue.Id, new Issue__c(
					Id = this.issue.Id,
					Bug_Tracker__c = null
				));
				DatabaseUtils.getInstance().performUpdateDML(this.toUpdate.values(), Schema.SObjectType.Issue__c)
					.handleError(JiraSyncBatch.class.getName(), '.processSync', logger);
				return;
			}

			syncRelations();
			syncCompletedStatus();
			syncPriority();

			if(!hasUpdateRules) {
				DatabaseUtils.getInstance().performUpdateDML(this.toUpdate.values(), Schema.SObjectType.Issue__c)
					.handleError(JiraSyncBatch.class.getName(), '.processSync', logger);
			}
			else {
				// Issues should be updated in batch finish
				this.regressedIssues = this.toUpdate.values();
			}
		}

		public virtual List<Issue__c> getRegressedIssues() {
			return this.regressedIssues;
		}

		public abstract Boolean isOAuthTokenBlank();
		public abstract void syncRelations();
		public abstract void setTicketPriority();

		public virtual void syncPriority() {
			if(isSynchronizeAutoUpdateIssuePriorityEnabled()) {
				if(issue.Priority__c != getTicketPriority()
					&& getTicketPriority() != null) {
					
					Issue__c issueSO = this.toUpdate.containsKey(this.issue.Id)
						? this.toUpdate.get(this.issue.Id)
						: new Issue__c(Id = this.issue.Id);
					issueSO.Priority__c = getTicketPriority();
					issueSO.Override_Priority__c = true;
					this.toUpdate.put(this.issue.Id, issueSO);
				}
			}
			if(isSynchronizeAutoUpdateTicketPriorityEnabled()) {
				if(issue.Priority__c != getTicketPriority()
					&& getTicketPriority() != null) {
					
					setTicketPriority();
				}
			}
		}

		public abstract String getTicketPriority();
		public abstract DateTime getResolutionDatetime();
		public abstract Boolean isTicketStatusNotCompleted();

		public virtual void syncCompletedStatus() {
			if(isSynchronizeCompletedStatusEnabled()) {
				if(String.isNotBlank(ticketId)) {
					DateTime resolutionDatetime = getResolutionDatetime();
					// When Jira ticket becomes Resolved, update status on the Issue to Completed.
					if(resolutionDatetime != null) {
						this.toUpdate.put(this.issue.Id, new Issue__c(
							Id = this.issue.Id,
							Resolved_On__c = resolutionDatetime,
							Status__c = IssueService.ISSUE_STATUS_COMPLETED
						));
					}
				}
			}
		}

		public abstract Boolean isSynchronizeRelatedTicketsEnabled();
		public abstract Boolean isSynchronizeDuplicatedTicketsEnabled();
		public abstract Boolean isSynchronizeCompletedStatusEnabled();
		public abstract Boolean isSynchronizeAutoUpdateIssuePriorityEnabled();
		public abstract Boolean isSynchronizeAutoUpdateTicketPriorityEnabled();
		public abstract String getTicketIdFromTicketLink(String bugTrackerLink);
		public abstract void retrieveTicket();

		public virtual void populateSfdcRelations() {
			List<Issue__c> relatedAndDuplicatedIssues = [
				SELECT Id, Bug_Tracker__c, Related_Issue__c, Status__c, Priority__c
				FROM Issue__c
				WHERE Bug_Tracker__c != NULL
					AND Related_Issue__c = :this.issue.Id
			];
			for(Issue__c issue : relatedAndDuplicatedIssues) {
				String ticketId = getTicketIdFromTicketLink(issue?.Bug_Tracker__c);
				if(issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE) {
					this.sfdcRelationInfo.duplicatedIssueKeys.add(ticketId);
				}
				else {
					this.sfdcRelationInfo.relatedIssueKeys.add(ticketId);
				}
			}
		}

		public abstract void populateRemoteRelations();
	}

	public class SynchronizeTicketProcessJiraImpl extends SynchronizeTicketProcessDefaultImpl {

		public SynchronizeTicketProcessJiraImpl(SynchronizeSettings settings, Issue__c issue, Logger logger) {
			super(settings, issue, logger);
		}

		public override Boolean isOAuthTokenBlank() {
			return String.isBlank(JiraService.JIRA_OAUTH_TOKEN);
		}
		
		public override Boolean isSynchronizeRelatedTicketsEnabled() {
			return this.settings.syncRelated && ConfigUtil.JIRA_SETTINGS.Synchronize_related_tickets_and_issues__c;
		}

		public override Boolean isSynchronizeDuplicatedTicketsEnabled() {
			return this.settings.syncDuplicated && ConfigUtil.JIRA_SETTINGS.Synchronize_duplicate_tickets_and_issues__c;
		}

		public override Boolean isSynchronizeCompletedStatusEnabled() {
			return this.settings.syncCompletedStatus && ConfigUtil.JIRA_SETTINGS.Synchronize_completed_Status__c;
		}

		public override Boolean isSynchronizeAutoUpdateIssuePriorityEnabled() {
			return this.settings.syncPriorityTicketingToSfdc && ConfigUtil.JIRA_SETTINGS.Automatically_update_Issue_priority__c;
		}

		public override Boolean isSynchronizeAutoUpdateTicketPriorityEnabled() {
			return this.settings.syncPrioritySfdcToTicketing && ConfigUtil.JIRA_SETTINGS.Automatically_update_ticket_priority__c;
		}

		public override String getTicketIdFromTicketLink(String bugTrackerLink) {
			String ticketId;
			if(isJiraTaskUrl(bugTrackerLink)) {
				ticketId = JiraService.getIssueKeyByUrl(bugTrackerLink);
			}
			return ticketId;
		}

		public override void retrieveTicket() {
			try {
				if(isJiraTaskUrl(this.issue?.Bug_Tracker__c)) {
					this.ticketId = JiraService.getIssueKeyByUrl(issue.Bug_Tracker__c);
					this.jiraIssue = JiraService.getService().getJiraIssueByKey(ticketId, logger, true);
				}
			}
			catch(Exception e) {
				if(e.getMessage()?.contains('404: ')) {
					this.remoteTicketNotFound = true;
				}
				this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'retrieveTicket'));
			}
		}

		public override void populateRemoteRelations() {
			if(this.jiraIssue?.fields?.issuelinks != null) {
				for(JiraService.JiraIssueLink issueLink : this.jiraIssue?.fields?.issuelinks) {
					if(issueLink?.inwardIssue != null) {
						if(issueLink?.type?.name == 'Relates') {
							this.remoteRelationInfo.relatedIssueKeys.add(issueLink.inwardIssue.key);
							this.remoteRelationInfo.relatedIssueKeysMap.put(issueLink.inwardIssue.key, issueLink.id);
						}
						else if(issueLink?.type?.name == 'Duplicate') {
							this.remoteRelationInfo.duplicatedIssueKeys.add(issueLink.inwardIssue.key);
							this.remoteRelationInfo.duplicatedIssueKeysMap.put(issueLink.inwardIssue.key, issueLink.id);
						}
					}
				}
			}
		}

		public override void syncRelations() {
			if(isSynchronizeRelatedTicketsEnabled()) {
				// link jira related tickets
				for(String relatedKey : this.sfdcRelationInfo.relatedIssueKeys) {
					if(this.remoteRelationInfo.relatedIssueKeys.contains(relatedKey)) continue;
					try{
						JiraService.getService().linkIssuesAsRelates(relatedKey, ticketId);
					}
					catch(HttpUtils.HttpUtilsException e) {
						// catch and skip Jira API Request has been rate limited"
						if(!e?.getMessage()?.containsIgnoreCase('"code":429')) {
							logger?.add(logger.getInternalError(e, null, JiraSyncBatch.class.getName(), 'syncRelations.linkIssuesAsRelates'));
						}
					}
					catch(Exception e) {
						this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'syncRelations.linkIssuesAsRelates'));
					}
				}
				// unlink jira tickets
				for(String relatedKey : this.remoteRelationInfo.relatedIssueKeysMap.keySet()) {
					if(!this.sfdcRelationInfo.relatedIssueKeys.contains(relatedKey)) {
						try{
							String linkId = this.remoteRelationInfo.relatedIssueKeysMap.get(relatedKey);
							JiraService.getService().unLinkIssue(linkId);
						}
						catch(HttpUtils.HttpUtilsException e) {
							// catch and skip Jira API Request has been rate limited"
							if(!e?.getMessage()?.containsIgnoreCase('"code":429')) {
								logger?.add(logger.getInternalError(e, null, JiraSyncBatch.class.getName(), 'syncRelations.unLinkRelatedIssue'));
							}
						}
						catch(Exception e) {
							this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'syncRelations.unLinkRelatedIssue'));
						}
					}
				}
			}
			if(isSynchronizeDuplicatedTicketsEnabled()) {
				// link jira duplicated tickets
				for(String duplicateKey : this.sfdcRelationInfo.duplicatedIssueKeys) {
					if(this.remoteRelationInfo.duplicatedIssueKeys.contains(duplicateKey)) continue;

					try{
						JiraService.getService().linkIssuesAsDuplicates(ticketId, duplicateKey);
					}
					catch(HttpUtils.HttpUtilsException e) {
						// catch and skip Jira API Request has been rate limited"
						if(!e?.getMessage()?.containsIgnoreCase('"code":429')) {
							logger?.add(logger.getInternalError(e, null, JiraSyncBatch.class.getName(), 'syncRelations.linkIssuesAsDuplicates'));
						}
					}
					catch(Exception e) {
						this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'syncRelations.linkIssuesAsDuplicates'));
					}
				}
				// unlink jira tickets
				for(String duplicateKey : this.remoteRelationInfo.duplicatedIssueKeysMap.keySet()) {
					if(!this.sfdcRelationInfo.duplicatedIssueKeys.contains(duplicateKey)) {
						try{
							String linkId = this.remoteRelationInfo.duplicatedIssueKeysMap.get(duplicateKey);
							JiraService.getService().unLinkIssue(linkId);
						}
						catch(HttpUtils.HttpUtilsException e) {
							// catch and skip Jira API Request has been rate limited"
							if(!e?.getMessage()?.containsIgnoreCase('"code":429')) {
								logger?.add(logger.getInternalError(e, null, JiraSyncBatch.class.getName(), 'syncRelations.unLinkDuplicatedIssue'));
							}
						}
						catch(Exception e) {
							this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'syncRelations.unLinkDuplicatedIssue'));
						}
					}
				}
			}
		}

		public override DateTime getResolutionDatetime() {
			Map<String, DateTime> resolutionDatetimes = JiraService.getService().getResolutionDatetimeByTaskKey(new List<String>{this.ticketId}, this.logger);
			return resolutionDatetimes?.containsKey(this.ticketId) ? resolutionDatetimes.get(this.ticketId) : null;
		}

		public override Boolean isTicketStatusNotCompleted() {
			return this.jiraIssue?.fields?.status?.statusCategory?.key != 'done';
		}

		public override String getTicketPriority() {
			return this.jiraIssue?.fields?.priority?.name;
		}

		public override void setTicketPriority() {
			JiraService.getService().putJiraTaskPriority(this.ticketId, this.issue.Priority__c);
		}
	}

	public class SynchronizeTicketProcessAzureDevOpsImpl extends SynchronizeTicketProcessDefaultImpl {

		private String organizationName;
		private String projectIdOrName;

		public SynchronizeTicketProcessAzureDevOpsImpl(SynchronizeSettings settings, Issue__c issue, Logger logger) {
			super(settings, issue, logger);
		}

		public override Boolean isOAuthTokenBlank() {
			return String.isBlank(AzureService.OAUTH_API_TOKEN);
		}
		
		public override Boolean isSynchronizeRelatedTicketsEnabled() {
			return this.settings.syncRelated && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_related_tickets_and_issues__c;
		}

		public override Boolean isSynchronizeDuplicatedTicketsEnabled() {
			return this.settings.syncDuplicated && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_duplicate_tickets_and_issues__c;
		}

		public override Boolean isSynchronizeCompletedStatusEnabled() {
			return this.settings.syncCompletedStatus && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Synchronize_completed_Status__c;
		}

		public override Boolean isSynchronizeAutoUpdateIssuePriorityEnabled() {
			return this.settings.syncPriorityTicketingToSfdc && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_Issue_priority__c;
		}

		public override Boolean isSynchronizeAutoUpdateTicketPriorityEnabled() {
			return this.settings.syncPrioritySfdcToTicketing && ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Automatically_update_ticket_priority__c;
		}

		public override String getTicketIdFromTicketLink(String bugTrackerLink) {
			String ticketId;
			if(isAzureDevOpsTaskUrl(bugTrackerLink)) {
				AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(bugTrackerLink);
				ticketId = urlWorkItem.workItemId;
			}
			return ticketId;
		}

		public override void retrieveTicket() {
			try {
				if(isAzureDevOpsTaskUrl(this.issue?.Bug_Tracker__c)) {
					AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(issue.Bug_Tracker__c);
					this.ticketId = urlWorkItem.workItemId;
					this.organizationName = urlWorkItem.organizationName;
					this.projectIdOrName = urlWorkItem.projectIdOrName;
					this.workItem = AzureService.getProjectWorkItem(this.organizationName, this.projectIdOrName, this.ticketId);
				}
				if(this.issue?.Related_Issue__c != null 
					&& String.isNotBlank(this.issue?.Related_Issue__r.Bug_Tracker__c)
					&& isAzureDevOpsTaskUrl(this.issue?.Related_Issue__r.Bug_Tracker__c)) {
					
					AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(this.issue?.Related_Issue__r.Bug_Tracker__c);
					this.parentWorkItem = AzureService.getProjectWorkItem(urlWorkItem.organizationName, urlWorkItem.projectIdOrName, urlWorkItem.workItemId);
				}
			}
			catch(Exception e) {
				// TF401232: Work item 140 does not exist, or you do not have permissions to read it.
				if(e.getMessage().contains('TF401232')) {
					this.remoteTicketNotFound = true;
				}
				this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'retrieveTicket'));
			}
		}

		public override void populateRemoteRelations() {
			if(this.workItem?.relations != null) {
				Integer relationIndex = 0;
				for(AzureService.AzureDevOpsWorkItemRelation relation : this.workItem?.relations) {
					AzureService.WorkItemUrlParser relatedUrlWorkItem = new AzureService.WorkItemUrlParser(relation?.url);
					if(AzureService.WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK.endsWith(relation?.rel)) {
						this.remoteRelationInfo.duplicatedIssueKeys.add(relatedUrlWorkItem?.workItemId);
						this.remoteRelationInfo.duplicatedIssueKeysMap.put(relatedUrlWorkItem?.workItemId, String.valueOf(relationIndex));
					}
					else if(AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK.endsWith(relation?.rel) 
						|| AzureService.WORK_ITEM_TYPE_FIELD_RELATED_CHILD_LINK.endsWith(relation?.rel)) {

						this.remoteRelationInfo.relatedIssueKeys.add(relatedUrlWorkItem?.workItemId);
						this.remoteRelationInfo.relatedIssueKeysMap.put(relatedUrlWorkItem?.workItemId, String.valueOf(relationIndex));
					}
					relationIndex++;
				}
			}
			if(this.parentWorkItem != null && this.parentWorkItem?.relations != null) {
				Integer relationIndex =  0;
				for(AzureService.AzureDevOpsWorkItemRelation relation : this.parentWorkItem?.relations) {
					AzureService.WorkItemUrlParser relatedUrlWorkItem = new AzureService.WorkItemUrlParser(relation?.url);
					if(AzureService.WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK.endsWith(relation?.rel)) {
						this.parentRemoteRelationInfo.duplicatedIssueKeys.add(relatedUrlWorkItem?.workItemId);
						this.parentRemoteRelationInfo.duplicatedIssueKeysMap.put(relatedUrlWorkItem?.workItemId, String.valueOf(relationIndex));
					}
					else if(AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK.endsWith(relation?.rel) 
						|| AzureService.WORK_ITEM_TYPE_FIELD_RELATED_CHILD_LINK.endsWith(relation?.rel)) {

						this.parentRemoteRelationInfo.relatedIssueKeys.add(relatedUrlWorkItem?.workItemId);
						this.parentRemoteRelationInfo.relatedIssueKeysMap.put(relatedUrlWorkItem?.workItemId, String.valueOf(relationIndex));
					}
					relationIndex++;
				}
			}
		}

		public override void syncRelations() {
			List<AzureService.AzureDevOpsWorkItemRequestBody> workItemUpdateRequest = new List<AzureService.AzureDevOpsWorkItemRequestBody>();
			if(isSynchronizeRelatedTicketsEnabled()) {
				// link related work intems
				for(String relatedKey : this.sfdcRelationInfo.relatedIssueKeys) {
					if(this.remoteRelationInfo.relatedIssueKeys.contains(relatedKey)) continue;

					workItemUpdateRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
						AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_RELATIONS, new Map<String, Object>{
							'rel' => AzureService.WORK_ITEM_TYPE_FIELD_RELATED_LINK,
							'url' => String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{this.organizationName, this.projectIdOrName, relatedKey})
						})
					);
				}
				// unlink related work items
				for(String relatedKey : this.remoteRelationInfo.relatedIssueKeysMap.keySet()) {
					if(!this.sfdcRelationInfo.relatedIssueKeys.contains(relatedKey) 
						&& !this.parentRemoteRelationInfo.relatedIssueKeysMap.keySet().contains(this.workItem.id)) {

						String relationIndex = this.remoteRelationInfo.relatedIssueKeysMap.get(relatedKey);
						String relationPatch = AzureService.WOKR_ITEM_REQUEST_PATH_RELATION + relationIndex;
						workItemUpdateRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
							AzureService.WORK_ITEM_TYPE_OPERATION_REMOVE, relationPatch, null)
						);
					}
				}
			}
			if(isSynchronizeDuplicatedTicketsEnabled()) {
				// link duplicated work items
				for(String duplicateKey : this.sfdcRelationInfo.duplicatedIssueKeys) {
					if(this.remoteRelationInfo.duplicatedIssueKeys.contains(duplicateKey)) continue;

					workItemUpdateRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
						AzureService.WORK_ITEM_TYPE_OPERATION_ADD, AzureService.WOKR_ITEM_REQUEST_PATH_RELATIONS, new Map<String, Object>{
							'rel' => AzureService.WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK,
							'url' => String.format(AzureService.FROMAT_WORK_ITEM_URL, new List<String>{this.organizationName, this.projectIdOrName, duplicateKey})
						})
					);
				}
				// unlink duplicated work items
				for(String duplicateKey : this.remoteRelationInfo.duplicatedIssueKeysMap.keySet()) {
					if(!this.sfdcRelationInfo.duplicatedIssueKeys.contains(duplicateKey)
						&& !this.parentRemoteRelationInfo.duplicatedIssueKeysMap.keySet().contains(this.workItem.id)) {
						
						String relationIndex = this.remoteRelationInfo.duplicatedIssueKeysMap.get(duplicateKey);
						String relationPatch = AzureService.WOKR_ITEM_REQUEST_PATH_RELATION + relationIndex;
						workItemUpdateRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
							AzureService.WORK_ITEM_TYPE_OPERATION_REMOVE, relationPatch, null)
						);
					}
				}
			}
			if(!workItemUpdateRequest.isEmpty()) {
				try{
					AzureService.updateProjectWorkItem(this.organizationName, this.projectIdOrName, this.ticketId, workItemUpdateRequest);
				}
				catch(Exception e) {
					this.logger?.add(logger.getInternalError(e, issue.Id, JiraSyncBatch.class.getName(), 'syncRelations.updateProjectWorkItem'));
				}
			}
		}

		public override DateTime getResolutionDatetime() {
			DateTime resolutionDatetime = AzureService.parseAzureDevOpsDateTime(this.workItem?.fields?.ClosedDate, this.logger);
			return resolutionDatetime;
		}

		public override Boolean isTicketStatusNotCompleted() {
			return this.workItem?.fields?.State != 'Done';
		}

		public override String getTicketPriority() {
			return convertAzureDevOpsPriorityToIssuePriority(this.workItem?.fields?.Priority);
		}

		public override void setTicketPriority() {
			AzureService.updateWorkItemPriority(this.organizationName, this.projectIdOrName, this.ticketId, convertIssuePriorityToAzureDevOpsPriority(this.issue.Priority__c));
		}
	}
}