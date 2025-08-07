public with sharing class LogListController {
    public Boolean isDev { get; set; }
    public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

	private static final Integer QUERY_LIMIT = 50;

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
				response.data = getLogs(data);
			} else if (method == 'getLogsPerPeriodByCategory') {
				response.data = getLogsPerPeriodByCategory(data);
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

	public static List<LogElement> getLogs(Object data) {
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		String fromDatetime = (input.get('from') != null) ? (String)input.get('from') : null;
		String toDatetime = (input.get('to') != null) ? (String)input.get('to') : null;
		String lastId = (input.get('lastId') != null) ? (String)input.get('lastId') : null;
		
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
		
		String query = 'SELECT Id, Name, Category__c, Type__c, Summary__c, Is_New__c, Created_At__c ' +
					   'FROM Log__c ' +
					   'WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime ';
		
		// Add pagination condition if lastId is provided
		if (String.isNotBlank(lastId)) {
			query += 'AND Id > :lastId ';
		}
		
		query += 'ORDER BY Id ASC LIMIT :QUERY_LIMIT';
		
		List<Log__c> logs = Database.query(query);

		List<LogElement> logElements = new List<LogElement>();
		for (Log__c log : logs) {
			logElements.add(new LogElement(log));
		}
		return logElements;
	}

	public class LogsPerPeriodData {
		public String timePoint;
		public Map<String, Integer> categoryCounts;

		public LogsPerPeriodData(String timePoint) {
			this.timePoint = timePoint;
			this.categoryCounts = new Map<String, Integer>();
		}
	}

	public static List<LogsPerPeriodData> getLogsPerPeriodByCategory(Object data) {
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
		
		//TODO: handle more than 5000 logs, maybe use count and group by?
		List<Log__c> logs = [
			SELECT Id, Category__c, Created_At__c
			FROM Log__c
			WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime
			ORDER BY Created_At__c DESC
		];

		// Calculate time period duration
		Long totalMillis = endDateTime.getTime() - startDateTime.getTime();
		Long periodMillis = totalMillis / 30;
		
		Map<String, LogsPerPeriodData> logsPerPeriodMap = new Map<String, LogsPerPeriodData>();
		
		for (Log__c log : logs) {
			if (log.Created_At__c == null) continue;
			
			// Calculate which period this log belongs to
			Long logMillis = log.Created_At__c.getTime() - startDateTime.getTime();
			Integer periodIndex = (Integer)(logMillis / periodMillis);
			if (periodIndex >= 30) periodIndex = 29; // Ensure we don't exceed 30 periods
			
			// Create period key
			DateTime periodStart = startDateTime.addSeconds((Integer)((periodIndex * periodMillis) / 1000));
			String periodKey = String.valueOf(periodStart);
			
			String category = log.Category__c != null ? log.Category__c : 'Uncategorized';
			
			if (!logsPerPeriodMap.containsKey(periodKey)) {
				logsPerPeriodMap.put(periodKey, new LogsPerPeriodData(periodKey));
			}
			
			LogsPerPeriodData periodData = logsPerPeriodMap.get(periodKey);
			
			if (periodData.categoryCounts.containsKey(category)) {
				periodData.categoryCounts.put(category, periodData.categoryCounts.get(category) + 1);
			} else {
				periodData.categoryCounts.put(category, 1);
			}
		}
		
		List<LogsPerPeriodData> result = new List<LogsPerPeriodData>(logsPerPeriodMap.values());
		result.sort(new LogsPerPeriodDataComparator());
		
		return result;
	}

	public class LogsPerPeriodDataComparator implements Comparator<LogsPerPeriodData> {
		public Integer compare(LogsPerPeriodData a, LogsPerPeriodData b) {
			DateTime dateTimeA = DateTime.valueOfGmt(a.timePoint);
			DateTime dateTimeB = DateTime.valueOfGmt(b.timePoint);
			if (dateTimeB > dateTimeA) return 1;
			if (dateTimeB < dateTimeA) return -1;
			return 0;
		}
	}
}