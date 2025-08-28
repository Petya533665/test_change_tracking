public with sharing class DevOpsCenterController {

	private static final String PUBLISHER_FIELD_NAME = 'Name';
	private static final String PUBLISHER_FIELD_PREFIX = 'NamespacePrefix';

	private static final Set<String> PUBLISHER_FIELDS = new Set<String> {
			PUBLISHER_FIELD_NAME, PUBLISHER_FIELD_PREFIX
	};

	public static final String IS_VALID_KEY = 'isValid';

	public String sourceControlMetadata { get; set; }
	public Boolean isDev { get; set; }

	public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

	public DevOpsCenterController(ApexPages.StandardController stdController) {
		String recordId = ApexPages.currentPage().getParameters().get('recordId');
		List<Issue__c> issues = [SELECT Id, Source_Control_Metadata__c FROM Issue__c WHERE Id = :recordId];
		if (!issues.isEmpty()) {
			this.sourceControlMetadata = issues[0].Source_Control_Metadata__c;
		}
		String isDevParam = ApexPages.currentPage().getParameters().get('dev');
		if (String.isNotBlank(isDevParam)) {
			Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
			ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
			isDev = Boolean.valueOf(isDevParam);
		} else {
			Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
			isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
		}
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
			if (method == 'getGitHubSettings') {
				response.data = AdminService.getGitHubSettings();
			} else if (method == 'validateDevOpsCenter') {
				response.data = validateDevOpsCenter();
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

	public static Map<String, Object> validateDevOpsCenter() {
		Boolean isValid = false;
		try {
			Connected_Org__c corg = ConnectedOrgService.getDevOpsCenterConnectedOrg();
			String query = new QBuilder(Publisher.SObjectType)
					.selectFields(PUBLISHER_FIELDS)
					.add(QBuilder.condition(PUBLISHER_FIELD_NAME).equalsTo('Salesforce'))
					.add(QBuilder.condition(PUBLISHER_FIELD_PREFIX).equalsTo('sf_devops'))
					.build();
			List<Publisher> publishers = (List<Publisher>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<Publisher>.class);
			isValid = !publishers.isEmpty();
		} catch (Exception e) {}
		return new Map<String, Object>{
				IS_VALID_KEY => isValid
		};
	}

	public static List<Object> runQuery(Connected_Org__c corg, String q) {
		Boolean isThisOrg = UserInfo.getOrganizationId() == Id.valueOf(corg.Name);
		return isThisOrg ? Database.query(q) : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), q);
	}

	public class RemoteActionResponse {
		public Object params;
		public Object data;
		public String error;
		public String stack;
	}

}