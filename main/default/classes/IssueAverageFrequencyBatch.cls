public with sharing class IssueAverageFrequencyBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {

	private String queryLocator;
	private List<Issue__c> issuesToUpdate;

	private static final Integer QUERY_LIMIT = 5000;

	private static IssueAverageFrequencyBatch instance = null;

	public static IssueAverageFrequencyBatch getInstance(String queryLocator) {
		if (instance == null) {
			instance = new IssueAverageFrequencyBatch(queryLocator, Logger.getInstance());
		}
		return instance;
	}

	private IssueAverageFrequencyBatch(String queryLocator, Logger logger) {
		super(logger);
		this.queryLocator = queryLocator;
		this.issuesToUpdate = new List<Issue__c>();
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('IssueAverageFrequencyBatch', this);
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Issue__c WHERE Id > :queryLocator];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id FROM Issue__c WHERE Id > :queryLocator ORDER BY Id LIMIT :QUERY_LIMIT]);
	}

	public void execute(Database.BatchableContext BC, List<Issue__c> scope) {
		Id issueId = scope[0].Id;
		queryLocator = issueId;
		List<AggregateResult> aggregateResults = [
				SELECT COUNT(Id) count_group, DAY_ONLY(convertTimezone(Created_At__c)) created_at
				FROM Log__c
				WHERE Issue__c = :issueId
				OR (Issue__r.Related_Issue__c = :issueId AND Issue__r.Status__c = 'Duplicate')
				GROUP BY DAY_ONLY(convertTimezone(Created_At__c))
				ORDER BY DAY_ONLY(convertTimezone(Created_At__c)) ASC
		];
		Integer i = 0;
		Decimal countLogs = 0;
		Decimal days = 0;
		for (AggregateResult aggregateResult : aggregateResults) {
			i++;
			countLogs += Integer.valueOf(aggregateResult.get('count_group'));
			days += Date.valueOf(aggregateResult.get('created_at')).daysBetween(i < aggregateResults.size() ? Date.valueOf(aggregateResults[i].get('created_at')) : Date.today());
		}
		Decimal frequency = !aggregateResults.isEmpty() ? days / aggregateResults.size() : 0;
		Decimal dailyVolume = !aggregateResults.isEmpty() ? countLogs / aggregateResults.size() : 0;
		issuesToUpdate.add(new Issue__c(
				Id = issueId,
				Average_Frequency__c = frequency.setScale(2),
				Average_Daily_Volume__c = dailyVolume.setScale(2)
		));
	}

	public void finish(Database.BatchableContext BC) {
		DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
				.handleError(IssueAverageFrequencyBatch.class.getName(), 'finish');
		loggerInstance.flush();
		if (!Test.isRunningTest()) IssueAverageFrequencyBatch.getInstance(queryLocator).startBatch();
	}

}