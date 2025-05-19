public with sharing class AIAnalysisBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private Set<String> issueIds = new Set<String>();

	private static AIAnalysisBatch instance = null;

	public static AIAnalysisBatch getInstance(Set<String> issueIds) {
		if (instance == null) {
			instance = new AIAnalysisBatch(issueIds, Logger.getInstance());
		}
		return instance;
	}

	private AIAnalysisBatch(Set<String> issueIds, Logger logger) {
		super(logger);
		this.issueIds = issueIds;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('AIAnalysisBatch', this);
	}

	public override Boolean initialValidation() {
		String errorMessage = AIAnalysis.checkAnalysisPermission();
		if (String.isNotBlank(errorMessage)) {
			AIAnalysis.getInstance(issueIds).internalError();
		}
		return String.isBlank(AIAnalysis.checkAnalysisPermission());
	}

	public override Integer getIterationsCount() {
		return issueIds.size();
	}

	public Iterable<String> start(Database.BatchableContext BC) {
		return new List<String>(issueIds);
	}

	public void execute(Database.BatchableContext BC, List<String> scope) {
		AIAnalysis analysis = AIAnalysis.getInstance(new Set<String>(scope));
		if (analysis != null) {
			analysis.init();
			analysis.analysis();
		}
	}

	public void finish(Database.BatchableContext BC) {
		this.loggerInstance?.flush();
	}

}