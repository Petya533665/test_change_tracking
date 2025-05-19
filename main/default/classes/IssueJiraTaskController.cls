public with sharing class IssueJiraTaskController {
	public Issue__c issue { get; set; }
	public Boolean isDev { get; set; }
	public Boolean isBlurMode { get; set; }
	public String blurModeUrlParameter { get; set; }
	public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

	public IssueJiraTaskController(ApexPages.StandardController stdController) {
		this.issue = [
				SELECT Id, Name, Summary__c, Description__c, Bug_Tracker__c, Key__c
				FROM Issue__c
				WHERE Id = :stdController.getId()
		];
		
		String isDevParam = ApexPages.currentPage().getParameters().get('dev');
		isBlurMode = !PermissionsUtil.JiraIntegrationEnabled && !PermissionsUtil.AzureDevOpsIntegrationEnabled;
		if (isBlurMode) {
			blurModeUrlParameter = BlurModeService.getEncryptedUrlParameter();
		}
		if (String.isNotBlank(isDevParam)) {
			Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
			ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
			isDev = Boolean.valueOf(isDevParam);
		} else {
			Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
			isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
		}
	}

	public static TicketingService.TicketCreateResult createTask(Object payload) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(payload));
        RuleUtil.Action action = (RuleUtil.Action)JSON.deserialize(JSON.serialize(input.get('action')), RuleUtil.Action.class);
        Id issueId = (Id)JSON.deserialize(JSON.serialize(input.get('logId')), Id.class);
		TicketingService service;
		if (action.type == RuleUtil.ACTION_TYPE_AZURE_DEV_OPS_NOTIFICATION) {
			service = new TicketingService(TicketingService.TICKETING_SERVICE_TYPE.AZURE_DEV_OPS, null);
		} else if (action.type == RuleUtil.ACTION_TYPE_JIRA_NOTIFICATION) {
			service = new TicketingService(TicketingService.TICKETING_SERVICE_TYPE.JIRA, null);
		}
		TicketingService.TicketingServiceInputData data = new TicketingService.TicketingServiceInputData(issueId, action.getAction(RuleUtil.ACTION_RT_MONITORING));

		JiraSyncBatch.skipSync = true;
		TicketingService.TicketCreateResult result = service.createTicket(data);
		result.url = JiraService.toCustomJiraUiEndpoint(result?.url);
        return result;
    }

	@RemoteAction
	public static String remoteActionHandler(String input) {
		String result;
		RemoteActionResponse response = new RemoteActionResponse();
		String methodName;

		try {

			Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(input);
			response.params = request;

			String method = (String)request.get('method');
			methodName = method;
			Object data = request.get('data');
			if (method == 'getJiraProjectUsers') {
				response.data = JiraService.getService().getProjectAssignableUsers(String.valueOf(data));
			} else if (method == 'getJiraSettings') {
				response.data = AdminService.getJiraSettings();
			} else if (method == 'getCreateMeta') {
				response.data = AdminService.getCreateMeta(data);
			} else if (method == 'getJiraProject') {
                response.data = AdminService.getJiraProject(String.valueOf(data));
            } else if (method == 'getJiraProjectIssueTypes') {
                response.data = AdminService.getJiraProjectIssueTypes(String.valueOf(data));
			} else if (method == 'getMergeFields') {
				response.data = AdminService.getMergeFields();
			} else if (method == 'getIssueDefaultJiraActionTemplate') {
				response.data = AdminService.getIssueDefaultJiraActionTemplate();
			} else if (method == 'createTask') {
				response.data = createTask(data);
			} else if (method == 'getAzureDevOpsProjects') {
				response.data = AzureService.getProjects();
			} else if (method == 'getAzureDevOpsSettings') {
				response.data = AdminService.getAzureDevOpsSettings();
			} else if (method == 'getAzureDevOpsProjectTeams') {
				response.data = AzureService.getProjectTeams(data);
			} else if (method == 'getAzureDevOpsWorkItemTypes') {
				response.data = AzureService.getWorkItemTypes(data);
			} else if (method == 'getAzureDevOpsEpicWorkItems') {
				response.data = AzureService.searchEpics(data);
			} else if (method == 'getAzureDevOpsProjectTeamMemberWrapper') {
				response.data = AzureService.getProjectTeamMemberWrapper(data);
			} else if (method == 'getAzureDevOpsClassificationNodes') {
				response.data = AzureService.getClassificationNodes(data);
			} else if (method == 'getDefaultAzureDevOpsActionTemplate') {
				response.data = AdminService.getDefaultAzureDevOpsActionTemplate();
			} else if (method == 'getIssueDefaultAzureDevOpsActionTemplate') {
				response.data = AdminService.getIssueDefaultAzureDevOpsActionTemplate();
			} else if (method == 'getAppPermissions') {
				response.data = AdminService.getAppPermissions(data);
			} else if (method == 'getOrganizationProjectProperties') {
				response.data = AzureService.getOrganizationProjectProperties(data);
			} else if (method == 'getOrganizationProcessesWorkItemTypes') {
				response.data = AzureService.getOrganizationProcessesWorkItemTypes(data);
			} else if (method == 'getOrganizationProcessWorkItemTypeFields') {
				response.data = AzureService.getOrganizationProcessWorkItemTypeFields(data);
			} else if (method == 'getActionWrappers') {
				response.data = JiraTaskController.getActionWrappers(data);
			} else {
				response.error = 'Action not found';
			}
			result = JSON.serialize(response);
			Logger.getInstance().flush();
		}
		catch(Exception e) {
			response.error = e.getMessage();
			response.stack = e.getStackTraceString();
			Logger.getInstance().internalError(e, TraceResultController.class.getName(), 'remoteActionHandler' + (String.isNotBlank(methodName) ? '.' + methodName : ''));
		}
		finally {
			try {
				result = JSON.serialize(response);
			}
			catch(Exception e) {
				Logger.getInstance().internalError(e, TraceResultController.class.getName(), 'remoteActionHandler.serializeResponse');
			}
		}
		return result;
	}

	public class RemoteActionResponse {
		public Object params;
		public Object data;
		public String error;
		public String stack;
	}
}