public with sharing class LogListController {
    public Boolean isDev { get; set; }
    public String packageNamespace {
		get {
			return ConfigUtil.getNameSpacePrefix();
		}
		set;
	}

	private static final Integer DEFAULT_LOGS_QUERY_LIMIT = 100;
	private static final Integer MAX_QUERY_LIMIT = 5000;
	private static final Integer LOG_PERIODS_AMOUNT = 30;

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
		Integer queryLimit = (input.get('limit') != null) ? (Integer)input.get('limit') : DEFAULT_LOGS_QUERY_LIMIT;
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
			query += 'AND Id < :lastId ';
		}
		
		query += 'ORDER BY Id DESC LIMIT :queryLimit';
		
		List<Log__c> logs = Database.query(query);

		List<LogElement> logElements = new List<LogElement>();
		for (Log__c log : logs) {
			logElements.add(new LogElement(log));
		}
		return logElements;
	}

	public class LogChartDataResponse {
		public List<LogChartDataMetric> metrics;
		public List<LogsPerPeriodData> chartData;
	}

	public class LogChartDataMetric {
		public String name;
		public Integer value;

		public LogChartDataMetric(String name, Integer value) {
			this.name = name;
			this.value = value;
		}
	}

	public class LogsPerPeriodData {
		public String timePoint;
		public Map<String, Integer> categoryCounts;

		public LogsPerPeriodData(String timePoint) {
			this.timePoint = timePoint;
			this.categoryCounts = new Map<String, Integer>();
		}
	}

	public static LogChartDataResponse getLogsPerPeriodByCategory(Object data) {
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
		
		// Calculate time period duration
		Long totalMillis = endDateTime.getTime() - startDateTime.getTime();
		Long periodMillis = totalMillis / LOG_PERIODS_AMOUNT;
		
		Map<String, LogsPerPeriodData> logsPerPeriodMap = new Map<String, LogsPerPeriodData>();
		
		// Initialize all 30 periods
		for (Integer i = 0; i < LOG_PERIODS_AMOUNT; i++) {
			DateTime periodStart = startDateTime.addSeconds((Integer)((i * periodMillis) / 1000));
			String periodKey = String.valueOf(periodStart);
			logsPerPeriodMap.put(periodKey, new LogsPerPeriodData(periodKey));
		}
		
		// Process logs in batches to handle more than 5000 records
		// Alternative approach: Use aggregate queries with COUNT and GROUP BY
		// This would be more efficient but requires pre-calculating time periods
		String lastId = null;
		Boolean hasMoreRecords = true;

		// Initialize metrics
		Integer total = 0;
		Integer isNew = 0;
		Integer userImpact = 0;
		Integer objectImpact = 0;
		Integer issues = 0;
		Integer isParent = 0;
		while (hasMoreRecords) {
			String query = 'SELECT Id, Category__c, Created_At__c, Is_New__c, Is_Parent__c, User_Id__c, Related_Object_Type__c, Related_Id__c, Issue__c FROM Log__c ' +
						  'WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime ';
			
			if (lastId != null) {
				query += 'AND Id > :lastId ';
			}
			
			query += 'ORDER BY Id LIMIT ' + MAX_QUERY_LIMIT;
			
			List<Log__c> logsBatch = Database.query(query);
			
			// Count metrics
			total += logsBatch.size();
			for (Log__c log : logsBatch) {
				if (log.Is_New__c == true) {
					isNew++;
				}
				if (log.Is_Parent__c == true) {
					isParent++;
				}
				if (String.isNotBlank(log.User_Id__c)) {
					userImpact++;
				}
				if (String.isNotBlank(log.Related_Object_Type__c) && String.isNotBlank(log.Related_Id__c)) {
					objectImpact++;
				}
				if (String.isNotBlank(log.Issue__c)) {
					issues++;
				}
			}

			// Process this batch
			for (Log__c log : logsBatch) {
				// Calculate which period this log belongs to
				Long logMillis = log.Created_At__c.getTime() - startDateTime.getTime();
				Integer periodIndex = (Integer)(logMillis / periodMillis);
				if (periodIndex >= LOG_PERIODS_AMOUNT) periodIndex = LOG_PERIODS_AMOUNT - 1; // Ensure we don't exceed LOG_PERIODS_AMOUNT periods
				if (periodIndex < 0) continue;
				
				// Create period key
				DateTime periodStart = startDateTime.addSeconds((Integer)((periodIndex * periodMillis) / 1000));
				String periodKey = String.valueOf(periodStart);
				
				String category = log.Category__c != null ? log.Category__c : 'Uncategorized';
				
				if (logsPerPeriodMap.containsKey(periodKey)) {
					LogsPerPeriodData periodData = logsPerPeriodMap.get(periodKey);
					
					if (periodData.categoryCounts.containsKey(category)) {
						periodData.categoryCounts.put(category, periodData.categoryCounts.get(category) + 1);
					} else {
						periodData.categoryCounts.put(category, 1);
					}
				}
			}
			
			// Check if we have more records to process
			if (logsBatch.size() < MAX_QUERY_LIMIT) {
				hasMoreRecords = false;
			} else {
				lastId = logsBatch[logsBatch.size() - 1].Id;
			}
		}
		
		// Filter out periods with empty categoryCounts
		List<LogsPerPeriodData> chartData = new List<LogsPerPeriodData>();
		for (LogsPerPeriodData periodData : logsPerPeriodMap.values()) {
			if (!periodData.categoryCounts.isEmpty()) {
				chartData.add(periodData);
			}
		}
		
		chartData.sort(new LogsPerPeriodDataComparator());

		List<LogChartDataMetric> metrics = new List<LogChartDataMetric>();
		metrics.add(new LogChartDataMetric('Total', total));
		metrics.add(new LogChartDataMetric('Is New', isNew));
		metrics.add(new LogChartDataMetric('User Impact', userImpact));
		metrics.add(new LogChartDataMetric('Object Impact', objectImpact));
		metrics.add(new LogChartDataMetric('Issues', issues));
		metrics.add(new LogChartDataMetric('Is Parent', isParent));

		LogChartDataResponse response = new LogChartDataResponse();
		response.chartData = chartData;
		response.metrics = metrics;
		return response;
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