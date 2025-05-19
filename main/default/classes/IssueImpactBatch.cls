public with sharing class IssueImpactBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {

	private Set<Id> issueIds;

	private Map<String, IssueService.IssueWrapper> mapIssueWrappers = new Map<String, IssueService.IssueWrapper>();

	private static IssueImpactBatch instance = null;

	public static IssueImpactBatch getInstance(Set<Id> issueIds) {
		if (instance == null) {
			instance = new IssueImpactBatch(issueIds, Logger.getInstance());
		}
		return instance;
	}

	private IssueImpactBatch(Set<Id> issueIds, Logger logger) {
		super(logger);
		this.issueIds = issueIds;
		BATCH_SCOPE = 2000;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('IssueImpactBatch', this);
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Log__c WHERE Issue__c IN :issueIds OR (Issue__r.Related_Issue__c IN :issueIds AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
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
				OR (Issue__r.Related_Issue__c IN :issueIds AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
		]);
	}

	public void execute(Database.BatchableContext BC, List<Log__c> scope) {
		IssueService.fillImpactedObjects(scope, issueIds, mapIssueWrappers);
	}

	public void finish(Database.BatchableContext BC) {
		IssueService.updateImpactedObjects(issueIds, mapIssueWrappers, loggerInstance);
		loggerInstance?.flush();
	}

}