public with sharing class IssueChartController {

	private static final String RECORD_ID_EXCEPTION = 'Record Id is null';

	private static final String TODAYS_USER_IMPACT_CHART = 'Todays User Impact';
	private static final String TODAYS_DATA_IMPACT_CHART = 'Todays Data Impact';

	private static final String NONE_RELATED_OPTION = 'None';
	private static final String ALL_RELATED_OPTION = 'All';
	private static final String CHILD_ISSUES_RELATED_OPTION = 'Child Issues';
	private static final String SIBLING_ISSUES_RELATED_OPTION = 'Sibling Issues';

	@AuraEnabled
	public static Boolean isBlurMode(String recordId) {
		return !BlurModeService.isAvailableDebugView(recordId);
	}

	@AuraEnabled
	public static Boolean isDebugLogServiceEnabled() {
		return PermissionsUtil.DebugLogServiceEnabled;
	}

	@AuraEnabled
	public static String getUrlParameter() {
		return BlurModeService.getEncryptedUrlParameter();
	}

	@AuraEnabled
	public static String getReportId(String reportName) {
		return [SELECT Id, Name FROM Report WHERE Name = :reportName LIMIT 1]?.Id;
	}

	@AuraEnabled
	public static List<Log__c> getLogs(String recordId) {
		if (String.isBlank(recordId)) handleError(RECORD_ID_EXCEPTION);
		List<Log__c> logs = new List<Log__c>();
		logs.addAll(
				[
						SELECT Id, Name, Issue__c, Issue__r.Name, First_Occurred_On__c, User__c, User_Name__c, Related_Object__c, Hash_1__c, Category__c, Stacktrace_Parse_Result__c, Stack_trace_parse_result_available__c, Created_At__c
						FROM Log__c
						WHERE Issue__c =:recordId AND Stack_trace_parse_result_available__c = TRUE
						ORDER BY Created_At__c DESC
						LIMIT 1
				]);
		logs.addAll(
				[
						SELECT Id, Name, Issue__c, Issue__r.Name, First_Occurred_On__c, User__c, User_Name__c, Related_Object__c, Hash_1__c, Category__c, Stacktrace_Parse_Result__c, Stack_trace_parse_result_available__c, Created_At__c
						FROM Log__c
						WHERE Issue__r.Related_Issue__c =:recordId AND Stack_trace_parse_result_available__c = TRUE
						ORDER BY Created_At__c DESC
						LIMIT 1
				]);
		return logs;
	}

	@AuraEnabled
	public static ChartService.ChartDataProperties getTodaysLogsCount(String recordId, String chartName) {
		if (String.isBlank(recordId)) handleError(RECORD_ID_EXCEPTION);
		ChartService chartService = new ChartService(recordId, chartName, null);
		return chartService.getChartDataProperties(recordId);
	}

	@AuraEnabled
	public static String getDateRange(String recordId) {
		if (!BlurModeService.isAvailableDebugView(recordId)) {
			return String.valueOf(ChartService.LAST_7_DAYS_DATE_RANGE);
		}
		Integer dateRange = ChartService.LAST_6_MONTH_DATE_RANGE;
		List<Issue__c> issues = [
				SELECT Id
				FROM Issue__c
				WHERE Id = :recordId
				OR (Related_Issue__c = :recordId AND Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
		];
		List<Log__c> logs = [
				SELECT Id, Created_At__c
				FROM Log__c
				WHERE Issue__c IN :issues
				ORDER BY Created_At__c DESC
				LIMIT 1
		];
		if (!logs.isEmpty()) {
			if (Date.today().addDays(-ChartService.LAST_60_DAYS_DATE_RANGE) <= logs[0].Created_At__c) {
				dateRange = ChartService.LAST_60_DAYS_DATE_RANGE;
			}
			if (Date.today().addDays(-ChartService.LAST_30_DAYS_DATE_RANGE) <= logs[0].Created_At__c) {
				dateRange = ChartService.LAST_30_DAYS_DATE_RANGE;
			}
			if (Date.today().addDays(-ChartService.LAST_7_DAYS_DATE_RANGE) <= logs[0].Created_At__c) {
				dateRange = ChartService.LAST_7_DAYS_DATE_RANGE;
			}
		}
		return String.valueOf(dateRange);
	}

	@AuraEnabled
	public static List<String> getRelated(String recordId) {
		// save analytics metrics to cache
		AnalyticsService.getInstance().trackIssuePageView(recordId);

		List<String> related;
		Boolean existChild = false;
		Boolean existSibling = false;
		for (Issue__c issue : [SELECT Id, Related_Issue__c FROM Issue__c WHERE Id = :recordId OR Related_Issue__c = :recordId]) {
			if (issue.Id != recordId && issue.Related_Issue__c == recordId) existChild = true;
			if (issue.Id == recordId && String.isNotBlank(issue.Related_Issue__c)) existSibling = true;
		}
		if (existChild && existSibling) {
			related = new List<String>{NONE_RELATED_OPTION, ALL_RELATED_OPTION, CHILD_ISSUES_RELATED_OPTION, SIBLING_ISSUES_RELATED_OPTION};
		} else if (existChild) {
			related = new List<String>{NONE_RELATED_OPTION, ALL_RELATED_OPTION, CHILD_ISSUES_RELATED_OPTION};
		} else if (existSibling) {
			related = new List<String>{NONE_RELATED_OPTION, ALL_RELATED_OPTION, SIBLING_ISSUES_RELATED_OPTION};
		}
		return related;
	}

	@AuraEnabled
	public static ChartService.ChartDataProperties getChartDataProperties(String recordId, String chartName, Integer dateRange, String related) {
		if (String.isBlank(recordId)) handleError(RECORD_ID_EXCEPTION);
		ChartService chartService = new ChartService(recordId, chartName, dateRange);
		return chartService.getChartDataProperties(recordId, dateRange, related);
	}

	@AuraEnabled
	public static List<ChartService.ChartData> getChartData(String chartDataPropertiesJSON) {
		if (String.isNotBlank(chartDataPropertiesJSON)) {
			ChartService.ChartDataProperties chartDataProperties = (ChartService.ChartDataProperties)JSON.deserialize(chartDataPropertiesJSON, ChartService.ChartDataProperties.class);
			ChartService chartService = new ChartService(chartDataProperties);
			return chartService.getChartData();
		}
		return new List<ChartService.ChartData>();
	}

	private static void handleError(String errorMessage) {
		AuraHandledException auraHandledException = new AuraHandledException(errorMessage);
		auraHandledException.setMessage(errorMessage);
		throw auraHandledException;
	}

	public class IssueChartControllerException extends Exception {}
}