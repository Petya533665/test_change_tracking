public with sharing class AIAnalysisBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private Set<String> issueIds = new Set<String>();

	private static AIAnalysisBatch instance = null;

	public static AIAnalysisBatch getInstance(Set<String> issueIds) {
		System.debug('++++AIAnalysisBatch.getInstance called with issue IDs: ' + issueIds);
		System.debug('++++AIAnalysisBatch instance already exists: ' + (instance != null));
		
		if (instance != null) {
			System.debug('++++AIAnalysisBatch returning existing instance with issue IDs: ' + instance.issueIds);
		}
		
		if (instance == null) {
			System.debug('++++AIAnalysisBatch creating new instance');
			instance = new AIAnalysisBatch(issueIds, Logger.getInstance());
			System.debug('++++AIAnalysisBatch new instance created with issue IDs: ' + instance.issueIds);
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
		System.debug('++++AIAnalysisBatch.execute called with scope: ' + scope);
		System.debug('++++AIAnalysisBatch.execute scope size: ' + scope.size());
		
		AIAnalysis analysis = AIAnalysis.getInstance(new Set<String>(scope));
		System.debug('++++AIAnalysisBatch.execute got AIAnalysis instance: ' + (analysis != null));
		
		if (analysis != null) {
			System.debug('++++AIAnalysisBatch.execute calling analysis.init() and analysis.analysis()');
			analysis.init();
			analysis.analysis();
		} else {
			System.debug('++++AIAnalysisBatch.execute ERROR: AIAnalysis instance is null!');
		}
	}

	public void finish(Database.BatchableContext BC) {
		this.loggerInstance?.flush();
	}

}