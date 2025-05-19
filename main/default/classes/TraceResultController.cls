public with sharing class TraceResultController {

	public String contentDocumentId { get; set; }
	public String contentVersionId { get; set; }
	public String contentVersionFlowId { get; set; }

	public Boolean isDev { get; set; }

	public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

	public static String baseUrl {
        get {return System.URL.getOrgDomainUrl().toExternalForm();}
        set;
    }

	@AuraEnabled
	public static String getNameSpacePrefix() {
		return ConfigUtil.getNameSpacePrefix();
	}

	@AuraEnabled
	public static List<DebugLog> getDebugLogs(String recordId) {
		Set<String> contentDocumentIds = new Set<String>();
		for (ContentDocumentLink contentDocumentLink : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.FileType = 'JSON']) {
			contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
		}
		List<DebugLog> debugLogs = new List<DebugLog>();
		for (ContentDocument contentDocument : [SELECT Id, Title, Description, CreatedDate, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocumentIds]) {
			debugLogs.add(new DebugLog(contentDocument));
		}
		return debugLogs;
	}

	public TraceResultController(ApexPages.StandardController stdController) {
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
			if (method == 'getApexClassById') {
				response.data = getApexClassById(data);
			} else if (method == 'getApexTriggerById') {
				response.data = getApexTriggerById(data);
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

	public static Map<String, Object> getApexClassById(Object data) {
		Map<String, Object> output = new Map<String, Object>();
		if (data != null) {
			String apexClassId = (String)JSON.deserializeUntyped(JSON.serialize(data));
			List<ApexClass> apexClasses = [SELECT Id, Name, Body FROM ApexClass WHERE Id = :apexClassId];
			output.put('apexClasses', apexClasses);
		}
		return output;
	}

	public static Map<String, Object> getApexTriggerById(Object data) {
		Map<String, Object> output = new Map<String, Object>();
		if (data != null) {
			String apexTriggerId = (String)JSON.deserializeUntyped(JSON.serialize(data));
			List<ApexTrigger> apexTriggers = [SELECT Id, Name, Body FROM ApexTrigger WHERE Id = :apexTriggerId];
			output.put('apexTriggers', apexTriggers);
		}
		return output;
	}

	public class DebugLog {
		@AuraEnabled
		public String contentDocumentId {get; set;}
		@AuraEnabled
		public Datetime contentDocumentCreatedDate {get; set;}
		@AuraEnabled
		public String user {get; set;}
		@AuraEnabled
		public String application {get; set;}
		@AuraEnabled
		public String request {get; set;}
		@AuraEnabled
		public String operation {get; set;}
		@AuraEnabled
		public String status {get; set;}
		@AuraEnabled
		public Integer duration {get; set;}
		@AuraEnabled
		public Integer logSize {get; set;}
		@AuraEnabled
		public String startTime {get; set;}
		@AuraEnabled
		public String timeZone {get; set;}
		@AuraEnabled
		public String Title {get; set;}
		@AuraEnabled
		public String contentVersionId {get; set;}
		@AuraEnabled
		public Boolean isFlow {get; set;}

		public DebugLog() {}

		public DebugLog(ContentDocument contentDocument) {
			this.contentDocumentId = contentDocument.Id;
			this.contentDocumentCreatedDate = contentDocument.CreatedDate;
			this.contentVersionId = contentDocument.LatestPublishedVersionId;
			this.Title = contentDocument.Title;
			this.isFlow = contentDocument.Title.contains('flow');
			if (String.isNotBlank(contentDocument.Description)) {
				Map<String, Object> debugLogInfo = (Map<String, Object>)JSON.deserializeUntyped(contentDocument.Description);
				this.user = (String)debugLogInfo.get('user');
				this.application = (String)debugLogInfo.get('application');
				this.request = (String)debugLogInfo.get('request');
				this.operation = (String)debugLogInfo.get('operation');
				this.status = (String)debugLogInfo.get('status');
				this.duration = (Integer)debugLogInfo.get('duration');
				this.logSize = (Integer)debugLogInfo.get('logSize');
				this.startTime = (String)debugLogInfo.get('startTime');
				this.timeZone = UserInfo.getTimeZone().getID();
			}
		}
	}

	public class RemoteActionResponse {
		public Object params;
		public Object data;
		public String error;
		public String stack;
	}

}