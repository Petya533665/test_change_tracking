public with sharing class IssueTrackerBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {

	public Map<String, List<Log__c>> mapLogsByHash;
	public Map<String, Issue__c> mapIssuesByHash;

	private static final Integer QUERY_LIMIT = 1000;

	private static IssueTrackerBatch instance = null;

	public static IssueTrackerBatch getInstance() {
		if (instance == null) {
			instance = new IssueTrackerBatch(Logger.getInstance());
		}
		return instance;
	}

	private IssueTrackerBatch(Logger logger) {
		super(logger);
		BATCH_SCOPE = QUERY_LIMIT;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('IssueTrackerBatch', this);
	}

	public override Boolean initialValidation() {
		return PermissionsUtil.IssueTrackingEnabled;
	}

	public override Integer getIterationsCount() {
		if (LimitsService.getMaxIssues() == null || BlurModeService.AVAILABLE_ISSUES_COUNT > 0) {
			return [
				SELECT COUNT()
				FROM Log__c	
				WHERE Issue__c = NULL 
					AND Hash_1__c != NULL 
					AND Do_Not_Create_Issue__c = FALSE 
					AND Post_Processing_Status__c = :IssueService.POST_PROCESSING_STATUS_COMPLETED
					AND Issue_Tracker_Status__c != :IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED
				LIMIT :QUERY_LIMIT
			];
		}
		if (LimitsService.getMaxIssues() != null && BlurModeService.AVAILABLE_ISSUES_COUNT <= 0 && BlurModeService.AVAILABLE_ISSUE_KEYS != null && !BlurModeService.AVAILABLE_ISSUE_KEYS.isEmpty()) {
			return [
				SELECT COUNT()
				FROM Log__c
				WHERE Issue__c = NULL 
					AND Hash_1__c != NULL 
					AND Hash_1__c IN :BlurModeService.AVAILABLE_ISSUE_KEYS 
					AND Do_Not_Create_Issue__c = FALSE 
					AND Post_Processing_Status__c = :IssueService.POST_PROCESSING_STATUS_COMPLETED
					AND Issue_Tracker_Status__c != :IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED
				LIMIT :QUERY_LIMIT
			];
		}
		return 0;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if (LimitsService.getMaxIssues() == null || BlurModeService.AVAILABLE_ISSUES_COUNT > 0) {
			return Database.getQueryLocator([
					SELECT Id, Summary__c, Details__c, Hash_1__c, Organization_Name__c, First_Occurred_On__c, Created_At__c,
						Issue_Tracker_Status__c	
					FROM Log__c
					WHERE Issue__c = NULL
					AND Hash_1__c != NULL
					AND Do_Not_Create_Issue__c = FALSE
					AND Post_Processing_Status__c = :IssueService.POST_PROCESSING_STATUS_COMPLETED
					AND Issue_Tracker_Status__c != :IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED
					ORDER BY Created_At__c DESC
					LIMIT :QUERY_LIMIT
			]);
		}
		if (LimitsService.getMaxIssues() != null && BlurModeService.AVAILABLE_ISSUES_COUNT <= 0 && BlurModeService.AVAILABLE_ISSUE_KEYS != null && !BlurModeService.AVAILABLE_ISSUE_KEYS.isEmpty()) {
			return Database.getQueryLocator([
					SELECT Id, Summary__c, Details__c, Hash_1__c, Organization_Name__c, First_Occurred_On__c, Created_At__c,
						Issue_Tracker_Status__c
					FROM Log__c
					WHERE Issue__c = NULL
					AND Hash_1__c != NULL
					AND Hash_1__c IN :BlurModeService.AVAILABLE_ISSUE_KEYS
					AND Do_Not_Create_Issue__c = FALSE
					AND Post_Processing_Status__c = :IssueService.POST_PROCESSING_STATUS_COMPLETED
					AND Issue_Tracker_Status__c != :IssueService.LOG_ISSUE_TRACKER_STATUS_FAILED
					ORDER BY Created_At__c DESC
					LIMIT :QUERY_LIMIT
			]);
		}
		return null;
	}

	public void execute(Database.BatchableContext BC, List<Log__c> scope) {
		mapLogsByHash = IssueService.getMapLogsByHash(scope);
		mapIssuesByHash = IssueService.getMapIssuesByHash(mapLogsByHash);
	}

	public void finish(Database.BatchableContext BC) {
		IssueService.issueTracker(mapLogsByHash, mapIssuesByHash, loggerInstance);
		loggerInstance?.flush();
		IssueTrackerBatch.getInstance().startBatch();
	}
}