public with sharing class ActionUtil {




    public static Map<String, Object> getActionSettings() {
		AdminService.AzureDevOpsSettings azureDevOpsSettings = AdminService.getAzureDevOpsSettings();
		AdminService.JiraSettings jiraSettings = AdminService.getJiraSettings();

		Map<String, Object> actionSettings = new Map<String, Object>();
		List<RuleUtil.Action> actions = new List<RuleUtil.Action>();
		actionSettings.put('jiraSettings', jiraSettings);

		if (PermissionsUtil.JiraIntegrationEnabled) {
			List<RuleUtil.Action> jiraActions = RuleUtil.getActionWrappers(RuleUtil.RULE_TYPE_JIRA_UPDATE, RuleUtil.MAP_ACTION_SUBTYPES.get(RuleUtil.RULE_TYPE_JIRA_UPDATE));
			
			Map<String, Object> typesByProject = new Map<String, Object>();
			for (RuleUtil.Action action : jiraActions) {
				for (JiraService.JiraProjectMeta project : jiraSettings.projects) {
					if (String.isNotBlank(action.jiraProject) && action.jiraProject == project.id) {
						action.projectLabel = project.name;
						if (String.isNotBlank(action.jiraIssueType)) {
							for (JiraService.JiraIssueType issueType : project.issueTypes) {
								if(action.jiraIssueType == issueType.id) {
									action.typeLabel = issueType.name;
								}
							}
						}
					}
				}
			}
			actions.addAll(jiraActions);
		}








		if (PermissionsUtil.AzureDevOpsIntegrationEnabled) {
			List<AzureService.AzureDevOpsProject> azureProjects = AzureService.getProjects();
			Map<String, String> projectMap = new Map<String, String>(); 

			if (azureDevOpsSettings.isConnectionValid) {
				for (AzureService.AzureDevOpsProject project : azureProjects) {
					projectMap.put(project.id, project.name);
				}
			}

			List<RuleUtil.Action> azureActions = RuleUtil.getActionWrappers(RuleUtil.RULE_TYPE_AZURE_DEV_OPS, RuleUtil.MAP_ACTION_SUBTYPES.get(RuleUtil.RULE_TYPE_AZURE_DEV_OPS));
			for (RuleUtil.Action action : azureActions) {
				action.projectLabel = projectMap.get(action.jiraProject);
			}
			actions.addAll(azureActions);
		}

		actionSettings.put(RuleUtil.KEY_ACTIONS, actions);
		return actionSettings;
	}
}