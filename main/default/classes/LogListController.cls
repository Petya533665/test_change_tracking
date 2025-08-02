public with sharing class LogListController {
    public Boolean isDev { get; set; }
    public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

    public LogListController() {
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

    public class RemoteActionResponse {
		public Object params;
		public Object data;
		public String error;
		public String stack;
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
			if (method == 'getLogs') {
				response.data = getLogs();
			} else {
				response.error = 'Action not found';
			}
			result = JSON.serialize(response);
			Logger.getInstance().flush();
		}
		catch(Exception e) {
			response.error = e.getMessage();
			response.stack = e.getStackTraceString();
			Logger.getInstance().internalError(e, LogListController.class.getName(), 'remoteActionHandler' + (String.isNotBlank(methodName) ? '.' + methodName : ''));
		}
		finally {
			try {
				result = JSON.serialize(response);
			}
			catch(Exception e) {
				Logger.getInstance().internalError(e, LogListController.class.getName(), 'remoteActionHandler.serializeResponse');
			}
		}
		return result;
	}

	public class LogElement {
		public String name;
		public String category;
		public String type;
		public String summary;
		public Boolean isNew;
		public DateTime createdAt;

		public LogElement(Log__c log) {
			this.name = log.Name;
			this.category = log.Category__c;
			this.type = JSON.serialize(log);
			this.summary = log.Summary__c;
			this.isNew = log.Is_New__c;
			this.createdAt = log.Created_At__c;
		}
	}

	@RemoteAction
	public static List<LogElement> getLogs() {
		List<Log__c> logs = [
			SELECT Name, Category__c, Type__c, Summary__c, Is_New__c, Created_At__c
			FROM Log__c
			ORDER BY Name DESC 
			LIMIT 20
		];

		List<LogElement> logElements = new List<LogElement>();
		for (Log__c log : logs) {
			logElements.add(new LogElement(log));
		}
		return logElements;
	}
}