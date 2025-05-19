public without sharing class PostInstallClass implements InstallHandler {

	private Version previousVersion;

	public void onInstall(InstallContext context) {
		if(context.previousVersion() != null) {
			previousVersion = context.previousVersion();
			doUpgrade();
		}
		else {
			doInstall();
		}
	}

	private void doUpgrade() {
		if (isInstalledVersionAfter(new Version(1, 589))) {
			// populate action type field on old jira action rules
			RuleUtil.updateOldJiraRuleActionTypeField();
		}
		if (isInstalledVersionBefore(new Version(1, 755))) {
			// create log indexes < 1.755
			LogIndexBatch.getInstance(LogIndexBatch.JobType.INIT_INDEXES_BATCH).startBatch();
		}
		else if (isInstalledVersionBefore(new Version(1, 790))) {
			// create log indexes < 1.790
			LogIndexBatch.getInstance(LogIndexBatch.JobType.UPDATE_INTERNAL_FIELD_BATCH).startBatch();
		}
		if (isInstalledVersionBefore(new Version(1, 850, 3))) {
			clearPendingIssues();
		}
	}

	public static void clearPendingIssues() {
		List<Issue__c> issues = [SELECT Id, Jira_Integration_Status__c 
			FROM Issue__c 
			WHERE Jira_Integration_Status__c = :MonitoringUtil.JIRA_INTEGRATION_STATUS_PENDING
		];
		for(Issue__c issue : issues) {
			issue.Jira_Integration_Status__c = MonitoringUtil.NOTIFICATION_INTEGRATION_STATUS_FAILED;
		}
		Database.update(issues, false);
	}

	private void doInstall() {}

	private Boolean isInstalledVersionBefore(Version version) {
		return previousVersion.compareTo(version) < 0;
	}

	private Boolean isInstalledVersionAfter(Version version) {
		return previousVersion.compareTo(version) > 0;
	}
}