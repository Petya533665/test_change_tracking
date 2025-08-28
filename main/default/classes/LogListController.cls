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
	private static final String DEFAULT_LOGS_SORT = 'Id,DESC';

	public class RemoteActionResponse {
		public Object params;
		public Object data;
		public String error;
		public String stack;
	}

	public class Organization {
		public String id;
		public String name;

		public Organization(String id, String name) {
			this.id = id;
			this.name = name;
		}
	}

	private static final Map<String, String> LOG_FIELD_MAPPING = new Map<String, String>{
		'name' => 'Name',
		'category' => 'Category__c',
		'type' => 'Type__c',
		'summary' => 'Summary__c',
		'isNew' => 'Is_New__c',
		'createdAt' => 'Created_At__c',
		'area' => 'Area__c',
		'apexName' => 'Apex_Name__c',
		'flowApiName' => 'Flow_API_Name__c',
		'userName' => 'User_Name__c'
	};

	public class LogElement {
		public String id;
		public String name;
		public String category;
		public String type;
		public String summary;
		public Boolean isNew;
		public DateTime createdAt;
		public String area;
		public String apexName;
		public String flowApiName;
		public String userName;
		public String viewFieldValue;

		public LogElement(Log__c log, String view) {
			this.id = log.Id;
			this.name = log.Name;
			this.category = log.Category__c;
			this.type = log.Type__c;
			this.summary = log.Summary__c;
			this.isNew = log.Is_New__c;
			this.createdAt = log.Created_At__c;
			this.area = log.Area__c;
			this.apexName = log.Apex_Name__c;
			this.flowApiName = log.Flow_API_Name__c;
			this.userName = log.User_Name__c;
			this.viewFieldValue = getViewValue(log, view);
		}
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
		public Map<String, Integer> groupCounts;

		public LogsPerPeriodData(String timePoint) {
			this.timePoint = timePoint;
			this.groupCounts = new Map<String, Integer>();
		}
	}

	public class Filter {
		public String id;
		public String name;
		public String title;
		public String type;
		public String operator;
		public String value;
		
		public Filter(String name, String type, String operator, String value) {
			this.name = name;
			this.type = type;
			this.operator = operator;
			this.value = value;
		}
		
		public Filter(Object filterObj) {
			Map<String, Object> filterMap = (Map<String, Object>)filterObj;
			this.id = (String)filterMap.get('id');
			this.name = (String)filterMap.get('name');
			this.title = (String)filterMap.get('title');
			this.type = (String)filterMap.get('type');
			this.operator = (String)filterMap.get('operator');
			this.value = (String)filterMap.get('value');
		}
		
		public Boolean isValid() {
			return String.isNotBlank(name) && String.isNotBlank(operator) && value != null;
		}
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
			} else if (method == 'getOrganizations') {
				response.data = getOrganizations();
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

	public static List<Organization> getOrganizations() {
		List<AggregateResult> results = [
			SELECT Organization_Id__c id, Organization_Name__c name
			FROM Log__c
			WHERE Organization_Id__c != null AND Organization_Name__c != null
			GROUP BY Organization_Id__c, Organization_Name__c
			ORDER BY Organization_Name__c
		];
		
		List<Organization> organizations = new List<Organization>();
		Organization currentOrg = null;
		String currentOrgId = UserInfo.getOrganizationId();
		
		for (AggregateResult result : results) {
			String organizationId = (String) result.get('id');
			String organizationName = (String) result.get('name');
			if (String.isNotBlank(organizationId) && String.isNotBlank(organizationName)) {
				Organization org = new Organization(organizationId, organizationName);
				
				if (organizationId == currentOrgId) {
					currentOrg = org;
				} else {
					organizations.add(org);
				}
			}
		}
		
		if (currentOrg != null) {
			organizations.add(0, currentOrg);
		}
		
		return organizations;
	}

	private static String mapLogElementToLogField(String field) {
		return LOG_FIELD_MAPPING.containsKey(field) ? LOG_FIELD_MAPPING.get(field) : field;
	}

	public static List<LogElement> getLogs(Object data) {
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		String orgId = (input.get('orgId') != null) ? (String)input.get('orgId') : null;
		String view = (input.get('view') != null) ? (String)input.get('view') : 'Category';
		String fromDatetime = (input.get('from') != null) ? (String)input.get('from') : null;
		String toDatetime = (input.get('to') != null) ? (String)input.get('to') : null;
		Integer queryLimit = (input.get('limit') != null) ? (Integer)input.get('limit') : DEFAULT_LOGS_QUERY_LIMIT;
		String lastId = (input.get('lastId') != null) ? (String)input.get('lastId') : null;
		String sortStr = (input.get('sort') != null) ? (String)input.get('sort') : DEFAULT_LOGS_SORT;
		List<Object> filters = (input.get('filters') != null) ? (List<Object>)input.get('filters') : new List<Object>();
		
		DateTime startDateTime = DateTime.now().addDays(-30);
		DateTime endDateTime = DateTime.now();
		if (String.isNotBlank(fromDatetime)) {
			startDateTime = DateTime.valueOf(fromDatetime);
		}
		if (String.isNotBlank(toDatetime)) {
			endDateTime = DateTime.valueOf(toDatetime);
		}
		
		String baseQuery = 'SELECT Id, Name, Category__c, Type__c, Summary__c, Is_New__c, Created_At__c, Flow_API_Name__c, Area__c, Apex_Name__c, User_Name__c ' +
						  'FROM Log__c ' +
						  'WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime ';
		
		if (String.isNotBlank(orgId)) {
			baseQuery += 'AND Organization_Id__c = :orgId ';
		}

		if (view == 'Flow API Name') {
			baseQuery += 'AND Category__c = \'Flow\' ';
		}
		
		if (String.isNotBlank(lastId)) {
			baseQuery += 'AND Id < :lastId ';
		}
		
		Map<String, Object> filterResult = applyFiltersToQuery(baseQuery, filters);
		String query = (String)filterResult.get('query');
		Map<String, Object> bindVariables = (Map<String, Object>)filterResult.get('bindVariables');
		
		String mappedSort = mapLogElementToLogField(sortStr.split(',')[0]) + ' ' + sortStr.split(',')[1];
		query += ' ORDER BY ' + mappedSort + ' LIMIT :queryLimit';
		
		Map<String, Object> allBindVariables = new Map<String, Object>{
			'startDateTime' => startDateTime,
			'endDateTime' => endDateTime,
			'queryLimit' => queryLimit
		};
		if (String.isNotBlank(lastId)) {
			allBindVariables.put('lastId', lastId);
		}
		if (String.isNotBlank(orgId)) {
			allBindVariables.put('orgId', orgId);
		}
		allBindVariables.putAll(bindVariables);
		
		List<Log__c> logs = Database.queryWithBinds(query, allBindVariables, AccessLevel.USER_MODE);

		List<LogElement> logElements = new List<LogElement>();
		for (Log__c log : logs) {
			logElements.add(new LogElement(log, view));
		}
		return logElements;
	}

	public static LogChartDataResponse getLogsPerPeriodByCategory(Object data) {
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		String orgId = (input.get('orgId') != null) ? (String)input.get('orgId') : null;
		String view = (input.get('view') != null) ? (String)input.get('view') : 'Category';
		String fromDatetime = (input.get('from') != null) ? (String)input.get('from') : null;
		String toDatetime = (input.get('to') != null) ? (String)input.get('to') : null;
		List<Object> filters = (input.get('filters') != null) ? (List<Object>)input.get('filters') : new List<Object>();
		
		DateTime startDateTime = DateTime.now().addDays(-30);
		DateTime endDateTime = DateTime.now();
		if (String.isNotBlank(fromDatetime)) {
			startDateTime = DateTime.valueOf(fromDatetime);
		}
		if (String.isNotBlank(toDatetime)) {
			endDateTime = DateTime.valueOf(toDatetime);
		}
		
		Long totalMillis = endDateTime.getTime() - startDateTime.getTime();
		Long periodMillis = totalMillis / LOG_PERIODS_AMOUNT;
		Map<String, LogsPerPeriodData> logsPerPeriodMap = new Map<String, LogsPerPeriodData>();
		
		// Initialize all periods
		for (Integer i = 0; i < LOG_PERIODS_AMOUNT; i++) {
			DateTime periodStart = startDateTime.addSeconds((Integer)((i * periodMillis) / 1000));
			String periodKey = String.valueOf(periodStart);
			logsPerPeriodMap.put(periodKey, new LogsPerPeriodData(periodKey));
		}
		
		// Initialize metrics
		Integer total = 0;
		Integer isNew = 0;
		Integer userImpact = 0;
		Integer objectImpact = 0;
		Integer issues = 0;
		Integer isParent = 0;
		
		// Process logs in batches to handle more than 5000 records
		String lastId = null;
		Boolean hasMoreRecords = true;
		while (hasMoreRecords) {
			String baseQuery = 'SELECT Id, Category__c, Type__c, Area__c, Apex_Name__c, User_Name__c, Flow_API_Name__c, Created_At__c, Is_New__c, Is_Parent__c, User_Id__c, Related_Object_Type__c, Related_Id__c, Summary__c, Issue__c FROM Log__c ' +
							  'WHERE Created_At__c >= :startDateTime AND Created_At__c <= :endDateTime ';
			
			if (String.isNotBlank(orgId)) {
				baseQuery += 'AND Organization_Id__c = :orgId ';
			}

			if (view == 'Flow API Name') {
				baseQuery += 'AND Category__c = \'Flow\' ';
			}
			
			if (lastId != null) {
				baseQuery += 'AND Id > :lastId ';
			}
			
			Map<String, Object> filterResult = applyFiltersToQuery(baseQuery, filters);
			String query = (String)filterResult.get('query');
			Map<String, Object> bindVariables = (Map<String, Object>)filterResult.get('bindVariables');
			
			query += ' ORDER BY Id LIMIT ' + MAX_QUERY_LIMIT;
			
			// Prepare all bind variables
			Map<String, Object> allBindVariables = new Map<String, Object>{
				'startDateTime' => startDateTime,
				'endDateTime' => endDateTime
			};
			if (lastId != null) {
				allBindVariables.put('lastId', lastId);
			}
			if (String.isNotBlank(orgId)) {
				allBindVariables.put('orgId', orgId);
			}
			allBindVariables.putAll(bindVariables);
			
			List<Log__c> logsBatch = Database.queryWithBinds(query, allBindVariables, AccessLevel.USER_MODE);
			
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

			for (Log__c log : logsBatch) {
				// Calculate which period this log belongs to
				Long logMillis = log.Created_At__c.getTime() - startDateTime.getTime();
				Integer periodIndex = (Integer)(logMillis / periodMillis);
				if (periodIndex >= LOG_PERIODS_AMOUNT) periodIndex = LOG_PERIODS_AMOUNT - 1; // Ensure we don't exceed LOG_PERIODS_AMOUNT periods
				if (periodIndex < 0) continue;
				
				// Create period key
				DateTime periodStart = startDateTime.addSeconds((Integer)((periodIndex * periodMillis) / 1000));
				String periodKey = String.valueOf(periodStart);
				
				// Get the appropriate field value based on view
				String viewValue = getViewValue(log, view);

				if (logsPerPeriodMap.containsKey(periodKey)) {
					LogsPerPeriodData periodData = logsPerPeriodMap.get(periodKey);
					
					if (periodData.groupCounts.containsKey(viewValue)) {
						periodData.groupCounts.put(viewValue, periodData.groupCounts.get(viewValue) + 1);
					} else {
						periodData.groupCounts.put(viewValue, 1);
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
		
		// Filter out periods with empty groupCounts
		List<LogsPerPeriodData> chartData = new List<LogsPerPeriodData>();
		for (LogsPerPeriodData periodData : logsPerPeriodMap.values()) {
			if (!periodData.groupCounts.isEmpty()) {
				chartData.add(periodData);
			}
		}

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
	
	private static String getViewValue(Log__c log, String view) {
		switch on view {
			when 'Type' {
				return log.Type__c != null ? log.Type__c : 'Unknown';
			}
			when 'Area' {
				return log.Area__c != null ? log.Area__c : 'Unknown';
			}
			when 'User' {
				return log.User_Name__c != null ? log.User_Name__c : 'Unknown';
			}
			when 'Fingerprint' {
				return log.Summary__c != null ? log.Summary__c : 'Unknown';
			}
			when 'Operation' {
				return log.Apex_Name__c != null ? log.Apex_Name__c : 'Unknown';
			}
			when 'Flow API Name' {
				return log.Flow_API_Name__c != null ? log.Flow_API_Name__c : 'Unknown';
			}
			when else {
				return log.Category__c != null ? log.Category__c : 'Uncategorized';
			}
		}
	}

	private static Map<String, Object> applyFiltersToQuery(String baseQuery, List<Object> filters) {
		Map<String, Object> filterResult = buildFilterConditions(filters);
		String whereClause = (String)filterResult.get('whereClause');
		Map<String, Object> bindVariables = (Map<String, Object>)filterResult.get('bindVariables');
		
		String completeQuery = baseQuery + whereClause;
		
		return new Map<String, Object>{
			'query' => completeQuery,
			'bindVariables' => bindVariables
		};
	}

	private static Map<String, Object> buildFilterConditions(List<Object> filters) {
		if (filters == null || filters.isEmpty()) {
			return new Map<String, Object>{
				'whereClause' => '',
				'bindVariables' => new Map<String, Object>()
			};
		}
		
		// Convert to Filter objects and group by field name
		Map<String, List<Filter>> filtersByField = new Map<String, List<Filter>>();
		
		for (Object filterObj : filters) {
			Filter filter = new Filter(filterObj);
			
			if (!filter.isValid()) {
				continue;
			}
			
			if (!filtersByField.containsKey(filter.name)) {
				filtersByField.put(filter.name, new List<Filter>());
			}
			filtersByField.get(filter.name).add(filter);
		}
		
		List<String> fieldConditions = new List<String>();
		Map<String, Object> bindVariables = new Map<String, Object>();
		Integer bindIndex = 0;
		
		// Process each field's filters
		for (String fieldName : filtersByField.keySet()) {
			List<Filter> fieldFilters = filtersByField.get(fieldName);
			String mappedField = LOG_FIELD_MAPPING.get(fieldName);
			
			if (String.isBlank(mappedField)) {
				continue;
			}
			
			List<String> orConditions = new List<String>();
			
			// Build OR conditions for the same field
			for (Filter filter : fieldFilters) {
				// Handle multiple values for string filters with equals/not equals operators
				if (filter.type == 'string' && (filter.operator == 'equals' || filter.operator == 'not equals to')) {
					List<String> conditions = buildMultipleValueConditions(mappedField, filter.operator, filter.value, bindIndex, bindVariables);
					if (!conditions.isEmpty()) {
						orConditions.addAll(conditions);
						bindIndex += conditions.size();
					}
				} else {
					String condition = buildCondition(mappedField, filter.operator, filter.value, filter.type, bindIndex, bindVariables);
					if (String.isNotBlank(condition)) {
						orConditions.add(condition);
						bindIndex++;
					}
				}
			}
			
			// Combine OR conditions for this field
			if (!orConditions.isEmpty()) {
				if (orConditions.size() == 1) {
					fieldConditions.add(orConditions[0]);
				} else {
					fieldConditions.add('(' + String.join(orConditions, ' OR ') + ')');
				}
			}
		}

		// Combine all field conditions with AND
		String whereClause = fieldConditions.isEmpty() ? '' : ' AND ' + String.join(fieldConditions, ' AND ');
		
		return new Map<String, Object>{
			'whereClause' => whereClause,
			'bindVariables' => bindVariables
		};
	}

	private static List<String> buildMultipleValueConditions(String field, String operator, String value, Integer bindIndex, Map<String, Object> bindVariables) {
		List<String> conditions = new List<String>();
		
		// Split by comma and trim whitespace
		List<String> values = new List<String>();
		for (String val : value.split(',')) {
			String trimmedVal = val.trim();
			if (String.isNotBlank(trimmedVal)) {
				values.add(trimmedVal);
			}
		}
		
		if (values.isEmpty()) {
			return conditions;
		}
		
		// Build condition for each value
		for (Integer i = 0; i < values.size(); i++) {
			String bindVarName = 'filter' + (bindIndex + i);
			bindVariables.put(bindVarName, values[i]);
			
			if (operator == 'equals') {
				conditions.add(field + ' = :' + bindVarName);
			} else if (operator == 'not equals to') {
				conditions.add(field + ' != :' + bindVarName);
			}
		}
		
		return conditions;
	}

	private static String buildCondition(String field, String operator, String value, String type, Integer bindIndex, Map<String, Object> bindVariables) {
		String bindVarName = 'filter' + bindIndex;
		
		switch on operator.toLowerCase() {
			when 'equals' {
				if (type == 'boolean') {
					Boolean boolValue = Boolean.valueOf(value);
					bindVariables.put(bindVarName, boolValue);
					return field + ' = :' + bindVarName;
				} else {
					bindVariables.put(bindVarName, value);
					return field + ' = :' + bindVarName;
				}
			}
			when 'not equals to' {
				if (type == 'boolean') {
					Boolean boolValue = Boolean.valueOf(value);
					bindVariables.put(bindVarName, boolValue);
					return field + ' != :' + bindVarName;
				} else {
					bindVariables.put(bindVarName, value);
					return field + ' != :' + bindVarName;
				}
			}
			when 'less than' {
				bindVariables.put(bindVarName, value);
				return field + ' < :' + bindVarName;
			}
			when 'greater than' {
				bindVariables.put(bindVarName, value);
				return field + ' > :' + bindVarName;
			}
			when 'less or equal' {
				bindVariables.put(bindVarName, value);
				return field + ' <= :' + bindVarName;
			}
			when 'greater or equal' {
				bindVariables.put(bindVarName, value);
				return field + ' >= :' + bindVarName;
			}
			when 'contains' {
				bindVariables.put(bindVarName, '%' + value + '%');
				return field + ' LIKE :' + bindVarName;
			}
			when 'does not contain' {
				bindVariables.put(bindVarName, '%' + value + '%');
				return '(NOT ' + field + ' LIKE :' + bindVarName + ')';
			}
			when 'starts with' {
				bindVariables.put(bindVarName, value + '%');
				return field + ' LIKE :' + bindVarName;
			}
			when else {
				return '';
			}
		}
	}
}