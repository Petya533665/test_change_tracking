public with sharing class LogLimitsChartController {

	@AuraEnabled
	public static List<LimitInfo> getLimitsChartData(String recordId) {
		List<Log__c> logs = getLogs(recordId);
		if (logs == null || logs.isEmpty()) return null;
		List<LimitInfo> limitInfos = new List<LimitInfo>();
		for (String limitFieldName : MAX_LIMIT_FIELD_NAME_MAP.keySet()) {
			List<LimitInfoItem> limitInfoItems = new List<LimitInfoItem>();
			for (Log__c log : logs) {
				LimitInfoItem limitInfoItem = new LimitInfoItem(log);
				limitInfoItems.add(limitInfoItem);
				Integer valueLimit = Integer.valueOf(log.get(limitFieldName));
				Integer maxLimit = Integer.valueOf(log.get(MAX_LIMIT_FIELD_NAME_MAP.get(limitFieldName)));
				limitInfoItem.addLimits(valueLimit, maxLimit);
			}
			limitInfos.add(new LimitInfo(limitFieldName, limitInfoItems));
		}
		return limitInfos.isEmpty() ? null : limitInfos;
	}

	private static Set<String> LOG_FIELDS = new Set<String>{
			'Id', 'Name', 'Category__c', 'Apex_Name__c'
	};

	public static List<Log__c> getLogs(String recordId) {
		LOG_FIELDS.addAll(LIMIT_LABELS_BY_API_NAME_MAP.keySet());
		String query = new QBuilder(Log__c.SObjectType)
				.selectFields(LOG_FIELDS)
				.add(QBuilder.condition('Parent__c').equalsTo(recordId))
				.add(QBuilder.orderBy('Created_Timestamp__c').ascending().nullsLast())
				.build();
		try {
			return Database.query(query);
		} catch (QueryException e) {
			return null;
		}
	}

	// limit field api names
	private static final String SOQL_QUERIES_NAME = 'SOQL_Queries__c';
	private static final String SOQL_QUERIES_LIMIT_NAME = 'SOQL_Queries_Limit__c';
	private static final String SOQL_ROWS_NAME = 'SOQL_Rows__c';
	private static final String SOQL_ROWS_LIMIT_NAME = 'SOQL_Rows_Limit__c';
	private static final String SOQL_AGGREGATES_NAME = 'SOQL_Aggregates__c';
	private static final String SOQL_AGGREGATES_LIMIT_NAME = 'SOQL_Aggregates_Limit__c';
	private static final String DML_STATEMENTS_NAME = 'DML_Statements__c';
	private static final String DML_STATEMENTS_LIMIT_NAME = 'DML_Statements_Limit__c';
	private static final String DML_ROWS_NAME = 'DML_Rows__c';
	private static final String DML_ROWS_LIMIT_NAME = 'DML_Rows_Limit__c';
	private static final String CPU_TIME_NAME = 'CPU_Time__c';
	private static final String CPU_TIME_LIMIT_NAME = 'CPU_Time_Limit__c';
	private static final String HEAP_SIZE_NAME = 'Heap_Size__c';
	private static final String HEAP_SIZE_LIMIT_NAME = 'Heap_Size_Limit__c';
	private static final String CALLOUTS_NAME = 'Callouts__c';
	private static final String CALLOUTS_LIMIT_NAME = 'Callouts_Limit__c';
	private static final String SOSL_QUERIES_NAME = 'SOSL_Queries__c';
	private static final String SOSL_QUERIES_LIMIT_NAME = 'SOSL_Queries_Limit__c';
	private static final String FUTURE_CALLS_NAME = 'Future_Calls__c';
	private static final String FUTURE_CALLS_LIMIT_NAME = 'Future_Calls_Limit__c';
	private static final String QUEUEABLE_JOBS_NAME = 'Queueable_Jobs__c';
	private static final String QUEUEABLE_JOBS_LIMIT_NAME = 'Queueable_Jobs_Limit__c';
	private static final String EMAIL_INVOCATIONS_NAME = 'Email_Invocations__c';
	private static final String EMAIL_INVOCATIONS_LIMIT_NAME = 'Email_Invocations_Limit__c';
	private static final String PUSH_NOTIFICATIONS_NAME = 'Push_Notifications__c';
	private static final String PUSH_NOTIFICATIONS_LIMIT_NAME = 'Push_Notifications_Limit__c';
	private static final String BATCH_JOBS_NAME = 'Batch_Jobs__c';
	private static final String BATCH_JOBS_LIMIT_NAME = 'Batch_Jobs_Limit__c';
	private static final String PUBLISH_IMMEDIATE_DML_NAME = 'Publish_Immediate_DML__c';
	private static final String PUBLISH_IMMEDIATE_DML_LIMIT_NAME = 'Publish_Immediate_DML_Limit__c';

	// limit field labels
	private static final String SOQL_QUERIES_LABEL = 'SOQL Queries';
	private static final String SOQL_QUERIES_LIMIT_LABEL = 'SOQL Queries Limit';
	private static final String SOQL_ROWS_LABEL = 'SOQL Rows';
	private static final String SOQL_ROWS_LIMIT_LABEL = 'SOQL Rows Limit';
	private static final String SOQL_AGGREGATES_LABEL = 'SOQL Aggregates';
	private static final String SOQL_AGGREGATES_LIMIT_LABEL = 'SOQL Aggregates Limit';
	private static final String DML_STATEMENTS_LABEL = 'DML Statements';
	private static final String DML_STATEMENTS_LIMIT_LABEL = 'DML Statements Limit';
	private static final String DML_ROWS_LABEL = 'DML Rows';
	private static final String DML_ROWS_LIMIT_LABEL = 'DML Rows Limit';
	private static final String CPU_TIME_LABEL = 'CPU Time';
	private static final String CPU_TIME_LIMIT_LABEL = 'CPU Time Limit';
	private static final String HEAP_SIZE_LABEL = 'Heap Size';
	private static final String HEAP_SIZE_LIMIT_LABEL = 'Heap Size Limit';
	private static final String CALLOUTS_LABEL = 'Callouts';
	private static final String CALLOUTS_LIMIT_LABEL = 'Callouts Limit';
	private static final String SOSL_QUERIES_LABEL = 'SOSL Queries';
	private static final String SOSL_QUERIES_LIMIT_LABEL = 'SOSL Queries Limit';
	private static final String FUTURE_CALLS_LABEL = 'Future Calls';
	private static final String FUTURE_CALLS_LIMIT_LABEL = 'Future Calls Limit';
	private static final String QUEUEABLE_JOBS_LABEL = 'Queueable Jobs';
	private static final String QUEUEABLE_JOBS_LIMIT_LABEL = 'Queueable Jobs Limit';
	private static final String EMAIL_INVOCATIONS_LABEL = 'Email Invocations';
	private static final String EMAIL_INVOCATIONS_LIMIT_LABEL = 'Email Invocations Limit';
	private static final String PUSH_NOTIFICATIONS_LABEL = 'Push Notifications';
	private static final String PUSH_NOTIFICATIONS_LIMIT_LABEL = 'Push Notifications Limit';
	private static final String BATCH_JOBS_LABEL = 'Batch Jobs';
	private static final String BATCH_JOBS_LIMIT_LABEL = 'Batch Jobs Limit';
	private static final String PUBLISH_IMMEDIATE_DML_LABEL = 'Publish Immediate DML';
	private static final String PUBLISH_IMMEDIATE_DML_LIMIT_LABEL = 'Publish Immediate DML Limit';

	private static final Map<String, String> LIMIT_LABELS_BY_API_NAME_MAP = new Map<String, String>{
			SOQL_QUERIES_NAME => SOQL_QUERIES_LABEL,
			SOQL_QUERIES_LIMIT_NAME => SOQL_QUERIES_LIMIT_LABEL,
			SOQL_ROWS_NAME => SOQL_ROWS_LABEL,
			SOQL_ROWS_LIMIT_NAME => SOQL_ROWS_LIMIT_LABEL,
			SOQL_AGGREGATES_NAME => SOQL_AGGREGATES_LABEL,
			SOQL_AGGREGATES_LIMIT_NAME => SOQL_AGGREGATES_LIMIT_LABEL,
			DML_STATEMENTS_NAME => DML_STATEMENTS_LABEL,
			DML_STATEMENTS_LIMIT_NAME => DML_STATEMENTS_LIMIT_LABEL,
			DML_ROWS_NAME => DML_ROWS_LABEL,
			DML_ROWS_LIMIT_NAME => DML_ROWS_LIMIT_LABEL,
			CPU_TIME_NAME => CPU_TIME_LABEL,
			CPU_TIME_LIMIT_NAME => CPU_TIME_LIMIT_LABEL,
			HEAP_SIZE_NAME => HEAP_SIZE_LABEL,
			HEAP_SIZE_LIMIT_NAME => HEAP_SIZE_LIMIT_LABEL,
			CALLOUTS_NAME => CALLOUTS_LABEL,
			CALLOUTS_LIMIT_NAME => CALLOUTS_LIMIT_LABEL,
			SOSL_QUERIES_NAME => SOSL_QUERIES_LABEL,
			SOSL_QUERIES_LIMIT_NAME => SOSL_QUERIES_LIMIT_LABEL,
			FUTURE_CALLS_NAME => FUTURE_CALLS_LABEL,
			FUTURE_CALLS_LIMIT_NAME => FUTURE_CALLS_LIMIT_LABEL,
			QUEUEABLE_JOBS_NAME => QUEUEABLE_JOBS_LABEL,
			QUEUEABLE_JOBS_LIMIT_NAME => QUEUEABLE_JOBS_LIMIT_LABEL,
			EMAIL_INVOCATIONS_NAME => EMAIL_INVOCATIONS_LABEL,
			EMAIL_INVOCATIONS_LIMIT_NAME => EMAIL_INVOCATIONS_LIMIT_LABEL,
			PUSH_NOTIFICATIONS_NAME => PUSH_NOTIFICATIONS_LABEL,
			PUSH_NOTIFICATIONS_LIMIT_NAME => PUSH_NOTIFICATIONS_LIMIT_LABEL,
			BATCH_JOBS_NAME => BATCH_JOBS_LABEL,
			BATCH_JOBS_LIMIT_NAME => BATCH_JOBS_LIMIT_LABEL,
			PUBLISH_IMMEDIATE_DML_NAME => PUBLISH_IMMEDIATE_DML_LABEL,
			PUBLISH_IMMEDIATE_DML_LIMIT_NAME => PUBLISH_IMMEDIATE_DML_LIMIT_LABEL
	};

	private static final Set<String> LIMIT_FIELDS = new Set<String>{
			SOQL_QUERIES_NAME,
			SOQL_ROWS_NAME,
			SOQL_AGGREGATES_NAME,
			DML_STATEMENTS_NAME,
			DML_ROWS_NAME,
			CPU_TIME_NAME,
			HEAP_SIZE_NAME,
			CALLOUTS_NAME,
			SOSL_QUERIES_NAME,
			FUTURE_CALLS_NAME,
			QUEUEABLE_JOBS_NAME,
			EMAIL_INVOCATIONS_NAME,
			PUSH_NOTIFICATIONS_NAME,
			BATCH_JOBS_NAME,
			PUBLISH_IMMEDIATE_DML_NAME
	};

	private static final Set<String> MAX_LIMIT_FIELDS = new Set<String>{
			SOQL_QUERIES_LIMIT_NAME,
			SOQL_ROWS_LIMIT_NAME,
			SOQL_AGGREGATES_LIMIT_NAME,
			DML_STATEMENTS_LIMIT_NAME,
			DML_ROWS_LIMIT_NAME,
			CPU_TIME_LIMIT_NAME,
			HEAP_SIZE_LIMIT_NAME,
			CALLOUTS_LIMIT_NAME,
			SOSL_QUERIES_LIMIT_NAME,
			FUTURE_CALLS_LIMIT_NAME,
			QUEUEABLE_JOBS_LIMIT_NAME,
			EMAIL_INVOCATIONS_LIMIT_NAME,
			PUSH_NOTIFICATIONS_LIMIT_NAME,
			BATCH_JOBS_LIMIT_NAME,
			PUBLISH_IMMEDIATE_DML_LIMIT_NAME
	};

	private static final Map<String, String> MAX_LIMIT_FIELD_NAME_MAP = new Map<String, String>{
			SOQL_QUERIES_NAME => SOQL_QUERIES_LIMIT_NAME,
			SOQL_ROWS_NAME => SOQL_ROWS_LIMIT_NAME,
			SOQL_AGGREGATES_NAME => SOQL_AGGREGATES_LIMIT_NAME,
			DML_STATEMENTS_NAME => DML_STATEMENTS_LIMIT_NAME,
			DML_ROWS_NAME => DML_ROWS_LIMIT_NAME,
			CPU_TIME_NAME => CPU_TIME_LIMIT_NAME,
			HEAP_SIZE_NAME => HEAP_SIZE_LIMIT_NAME,
			CALLOUTS_NAME => CALLOUTS_LIMIT_NAME,
			SOSL_QUERIES_NAME => SOSL_QUERIES_LIMIT_NAME,
			FUTURE_CALLS_NAME => FUTURE_CALLS_LIMIT_NAME,
			QUEUEABLE_JOBS_NAME => QUEUEABLE_JOBS_LIMIT_NAME,
			EMAIL_INVOCATIONS_NAME => EMAIL_INVOCATIONS_LIMIT_NAME,
			PUSH_NOTIFICATIONS_NAME => PUSH_NOTIFICATIONS_LIMIT_NAME,
			BATCH_JOBS_NAME => BATCH_JOBS_LIMIT_NAME,
			PUBLISH_IMMEDIATE_DML_NAME => PUBLISH_IMMEDIATE_DML_LIMIT_NAME
	};
	
	public class LimitInfo {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public List<LimitInfoItem> items;
		public LimitInfo(String name, List<LimitInfoItem> items) {
			this.name = name;
			this.label = LIMIT_LABELS_BY_API_NAME_MAP.get(name);
			this.items = items;
			
		}
	}
	
	public class LimitInfoItem {
		@AuraEnabled
		public String recordId;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String category;
		@AuraEnabled
		public String operation;
		@AuraEnabled
		public Integer value;
		@AuraEnabled
		public Integer max;
		@AuraEnabled
		public Double percentage;
		public LimitInfoItem(Log__c log) {
			this.recordId = log.Id;
			this.name = log.Name;
			this.category = log.Category__c;
			this.operation = log.Apex_Name__c;
		}
		public void addLimits(Integer value, Integer max) {
			if (value == null || max == null || max == 0) {
				this.value = 0;
				this.max = 0;
				this.percentage = 0;
			} else {
				this.value = value;
				this.max = max;
				this.percentage = (max > 0) ? ((value * 100.0) / max).setScale(2) : 0;
			}
		}
	}

}