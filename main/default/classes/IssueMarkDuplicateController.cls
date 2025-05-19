public with sharing class IssueMarkDuplicateController {

	private ApexPages.StandardSetController setController;
	public List<Issue__c> issuesToUpdate {get; set;}
	public Boolean isProcessing {get; set;}

	public IssueMarkDuplicateController(ApexPages.StandardSetController setController) {
		this.setController = setController;
		issuesToUpdate = [
				SELECT Id, Name, Related_Issue__c, Related_Issue__r.Name, Status__c, Summary__c, CreatedDate
				FROM Issue__c
				WHERE Id IN :setController.getSelected()
				AND Status__c != :IssueService.ISSUE_STATUS_DUPLICATE
				ORDER BY CreatedDate
		];
		Issue__c relatedIssue;
		for (Issue__c issue : issuesToUpdate) {
			if (relatedIssue == null) {
				relatedIssue = issue;
			} else {
				issue.Related_Issue__c = relatedIssue.Id;
				issue.Related_Issue__r = relatedIssue;
				issue.Status__c = IssueService.ISSUE_STATUS_DUPLICATE;
			}
		}
	}

	public PageReference updateIssues() {
		if (isProcessing != true) {
			isProcessing = true;
			issuesToUpdate = DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
					.handleError(IssueMarkDuplicateController.class.getName(), '.updateIssues').getSuccessSObjects();
			Set<Id> issueIds = (new Map<Id, Issue__c>(issuesToUpdate)).keySet();
			Integer logsCount = [
					SELECT COUNT()
					FROM Log__c
					WHERE Issue__c IN :issueIds
					OR (Issue__r.Related_Issue__c IN :issueIds AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
			];
			if (logsCount >= IssueService.LIMIT_LOGS_CALCULATE_COUNT) {
				IssueImpactBatch.getInstance(issueIds).startBatch();
			} else {
				IssueService.calculateImpactedObjects(issueIds, Logger.getInstance());
			}
		}
		Logger.getInstance().flush();
		return doRedirect();
	}

	public PageReference doRedirect() {
		return new ApexPages.Action('{!List}').invoke();
	}

}