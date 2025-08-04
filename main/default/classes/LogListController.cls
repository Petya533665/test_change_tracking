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
			} else if (method == 'getLogsPerDayByCategory') {
				response.data = getLogsPerDayByCategory(data);
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
		public String id;
		public String name;
		public String category;
		public String type;
		public String summary;
		public Boolean isNew;
		public DateTime createdAt;

		public LogElement(Log__c log) {
			this.id = log.Id;
			this.name = log.Name;
			this.category = log.Category__c;
			this.type = log.Type__c;
			this.summary = log.Summary__c;
			this.isNew = log.Is_New__c;
			this.createdAt = log.Created_At__c;
		}
	}

	public static List<LogElement> getLogs() {
		List<Log__c> logs = [
			SELECT Id, Name, Category__c, Type__c, Summary__c, Is_New__c, Created_At__c
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

	public class LogsPerDayData {
		public String timePoint;
		public Map<String, Integer> categoryCounts;

		public LogsPerDayData(String timePoint) {
			this.timePoint = timePoint;
			this.categoryCounts = new Map<String, Integer>();
		}
	}

	public static List<LogsPerDayData> getLogsPerDayByCategory(Object data) {
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		String fromDatetime = (input.get('from') != null) ? (String)input.get('from') : null;
		String toDatetime = (input.get('to') != null) ? (String)input.get('to') : null;
		
		// Set default date range (last 30 days) if not provided
		DateTime startDateTime = DateTime.now().addDays(-30);
		DateTime endDateTime = DateTime.now();
		
		// Parse provided dates if available
		if (String.isNotBlank(fromDatetime)) {
			startDateTime = DateTime.valueOf(fromDatetime);
		}
		if (String.isNotBlank(toDatetime)) {
			endDateTime = DateTime.valueOf(toDatetime);
		}
		
		List<Log__c> logs = [
			SELECT Id, Category__c, Created_At__c
			FROM Log__c
			WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime
			ORDER BY Created_At__c DESC
		];

		Map<String, LogsPerDayData> logsPerDayMap = new Map<String, LogsPerDayData>();
		
		for (Log__c log : logs) {
			String dateKey = log.Created_At__c.date().format();
			String category = log.Category__c != null ? log.Category__c : 'Uncategorized';
			
			if (!logsPerDayMap.containsKey(dateKey)) {
				logsPerDayMap.put(dateKey, new LogsPerDayData(String.valueOf(log.Created_At__c)));
			}
			
			LogsPerDayData dayData = logsPerDayMap.get(dateKey);
			
			if (dayData.categoryCounts.containsKey(category)) {
				dayData.categoryCounts.put(category, dayData.categoryCounts.get(category) + 1);
			} else {
				dayData.categoryCounts.put(category, 1);
			}
		}
		
		List<LogsPerDayData> result = new List<LogsPerDayData>(logsPerDayMap.values());
		result.sort(new LogsPerDayDataComparator());
		
		return result;
	}

	public class LogsPerDayDataComparator implements Comparator<LogsPerDayData> {
		public Integer compare(LogsPerDayData a, LogsPerDayData b) {
			DateTime dateTimeA = DateTime.valueOfGmt(a.timePoint);
			DateTime dateTimeB = DateTime.valueOfGmt(b.timePoint);
			if (dateTimeB > dateTimeA) return 1;
			if (dateTimeB < dateTimeA) return -1;
			return 0;
		}
	}
}