public with sharing class AIAnalysisBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private AIAnalysis analysis;

	private static final Integer QUERY_LIMIT = 1;

	private static AIAnalysisBatch instance = null;

	public static AIAnalysisBatch getInstance() {
		if (instance == null) {
			instance = new AIAnalysisBatch(Logger.getInstance());
		}
		return instance;
	}

	private AIAnalysisBatch(Logger logger) {
		super(logger);
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('AIAnalysisBatch', this);
	}

	public override Boolean initialValidation() {
		return String.isBlank(AIAnalysis.checkAnalysisPermission());
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Issue__c WHERE Analysis_Status__c = :AIAnalysisService.IN_PROGRESS_STATUS LIMIT :QUERY_LIMIT];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id FROM Issue__c WHERE Analysis_Status__c = :AIAnalysisService.IN_PROGRESS_STATUS LIMIT :QUERY_LIMIT]);
	}

	public void execute(Database.BatchableContext BC, List<Issue__c> scope) {
		Set<String> issueIds = new Set<String>();
		for (Issue__c issue : scope) {
			issueIds.add(issue.Id);
		}
		analysis = AIAnalysis.getInstance(issueIds);
		if (analysis != null) {
			analysis.init();
			analysis.analysis();
		}
	}

	public void finish(Database.BatchableContext BC) {
		if (analysis != null) {
			analysis.Pending();
			analysis.flush();
		}
		this.loggerInstance?.flush();
		AIAnalysisBatch.getInstance().startBatch();
	}

}