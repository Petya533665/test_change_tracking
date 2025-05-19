global with sharing class LogsChartsWrapperController {
    public Boolean isDev { get; set; }
	public Boolean isBlurMode { get; set; }
	public String blurModeUrlParameter { get; set; }
	public Log__c currentLog { get; set; }
	public String packageNamespace { get {return ConfigUtil.getNameSpacePrefix();} set; }

	private static final Integer LAST_7_DAYS_DATE_RANGE = 7;
	private static final Integer LAST_30_DAYS_DATE_RANGE = 30;
	private static final Integer LAST_60_DAYS_DATE_RANGE = 60;
	private static final Integer LAST_6_MONTH_DATE_RANGE = 180;

	private static final String LABEL_SAME = 'Same';
	private static final String LABEL_SIMILAR = 'Similar';
	private static final String LABEL_POSSIBLY_RELATED = 'Possibly Related';
	private static final String LABEL_TIMING = 'Timing';
	private static final String REPORT_NAME_SUMMARY_BY_DATE_HASH1 = 'Summary by Date Filtered 1';
	private static final String REPORT_NAME_SUMMARY_BY_DATE_HASH2 = 'Summary by Date Filtered 2';
	private static final String REPORT_NAME_SUMMARY_BY_DATE_HASH3 = 'Summary by Date Filtered 3';
	private static final String REPORT_NAME_SUMMARY_BY_TIMING = 'Summary by Timing';
	private static final String URL_REPORT_TIMING = '/lightning/r/Report/{0}/view?fv0={1}&fv1={2}';
	private static final String URL_REPORT_HASH1 = '/lightning/r/Report/{0}/view?fv0={1}&fv1={2}&fv2={3}';
	private static final String URL_REPORT_HASH2 = '/lightning/r/Report/{0}/view?fv0={1}&fv1={2}&fv2={3}&fv3={4}';
	private static final String URL_REPORT_HASH3 = '/lightning/r/Report/{0}/view?fv0={1}&fv1={2}&fv2={3}&fv3={4}&fv4={5}';

    public LogsChartsWrapperController(ApexPages.StandardController stdController) {
	    String recordId = ApexPages.currentPage().getParameters().get('recordId');
		// save analytics metrics to cache
		AnalyticsService.getInstance().trackLogPageView(recordId);

        String isDevParam = ApexPages.currentPage().getParameters().get('dev');
        if (String.isNotBlank(isDevParam)) {
            isDev = Boolean.valueOf(isDevParam);
        } else {
            Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
            isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
		}
		currentLog = [
			SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
		    FROM Log__c
			WHERE Id = :recordId
		];
	    ConfigUtil.updateTimeZone(new List<Log__c>{currentLog}, 'Created_At__c');
	    isBlurMode = !BlurModeService.isAvailableDebugView(this.currentLog.Id);
		if (isBlurMode) {
			blurModeUrlParameter = BlurModeService.getEncryptedUrlParameter();
		}
    }

    @RemoteAction
	global static String remoteActionHandler(String input) {
		Map<String, Object> request = (Map<String, Object> )JSON.deserializeUntyped(input);
		RemoteActionResponse response = new RemoteActionResponse();
		response.params = request;
		String method = (String)request.get('method');
		Object data = request.get('data');
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
		try {
			if (method == 'getDateRange') {
				String logId = (String)payload.get('logId');
				output.put('dateRange', JSON.deserializeUntyped(getDateRange(logId)));
			} else if (method == 'getOccurrenceLogs') {
				String logId = (String)payload.get('logId');
				Integer showDays = (Integer)payload.get('showDays');
				output.put('occurrenceLogs', JSON.deserializeUntyped(getChartDataJSON(logId, ChartService.LOG_CHART_OCCURRENCE_LOGS, showDays)));
			} else if (method == 'getTimingLogs') {
				String logId = (String) payload.get('logId');
				Integer showRange = (Integer) payload.get('showRange');
				output.put('timingLogs', JSON.deserializeUntyped(getChartDataJSON(logId, ChartService.LOG_CHART_TIMING_LOGS, showRange)));
				output.put('timeZone', UserInfo.getTimeZone().getOffset(Datetime.now())/(3600*1000));
			} else if (method == 'getReportUrl') {
				String logId = (String)payload.get('logId');
				String label = (String)payload.get('label');
				String logDate = (String)payload.get('date');
				output.put('reportUrl', JSON.deserializeUntyped(getReportUrl(logId, label, logDate)));
			} else {
				response.error = 'Action not found';
			}
		} catch (Exception e) {
			response.error = e.getMessage();
			response.stack = e.getStackTraceString();
			Logger.getInstance().internalError(e, LogsChartsWrapperController.class.getName(), 'remoteActionHandler');
		}
		response.data = output;
		return JSON.serialize(response);
	}

	private static String getChartDataJSON(String recordId, String chartName, Integer range) {
		ChartService chartService = new ChartService(recordId, chartName, range);
		chartService.getChartDataProperties(recordId, range);
		return chartService.getChartDataJSON();
	}

	public static String getDateRange(String currentLogId) {
		if (!BlurModeService.isAvailableDebugView(currentLogId)) {
			return JSON.serialize(LAST_7_DAYS_DATE_RANGE);
		}
		Integer dateRange = LAST_6_MONTH_DATE_RANGE;
		List<Log__c> currentLogs = [
				SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
				FROM Log__c
				WHERE Id = :currentLogId
		];
		List<Log__c> logs = [
				SELECT Id, Created_At__c
				FROM Log__c
				WHERE Organization_Id__c = :currentLogs[0].Organization_Id__c
				AND (Hash_1__c = :currentLogs[0].Hash_1__c
				OR (Hash_2__c = :currentLogs[0].Hash_2__c AND Hash_1__c != :currentLogs[0].Hash_1__c)
				OR (Hash_3__c = :currentLogs[0].Hash_3__c AND Hash_1__c != :currentLogs[0].Hash_1__c AND Hash_2__c != :currentLogs[0].Hash_2__c))
				ORDER BY Created_At__c DESC
				LIMIT 1
		];
		if (!logs.isEmpty()) {
			if (Datetime.now().addDays(-LAST_60_DAYS_DATE_RANGE) <= logs[0].Created_At__c.dateGmt()) dateRange = LAST_60_DAYS_DATE_RANGE;
			if (Datetime.now().addDays(-LAST_30_DAYS_DATE_RANGE) <= logs[0].Created_At__c.dateGmt()) dateRange = LAST_30_DAYS_DATE_RANGE;
			if (Datetime.now().addDays(-LAST_7_DAYS_DATE_RANGE) <= logs[0].Created_At__c.dateGmt()) dateRange = LAST_7_DAYS_DATE_RANGE;
		}
		return JSON.serialize(dateRange);
	}

	private static String getReportUrl(String logId, String label, String logDate) {
		String reportUrl = '';
		List<Log__c> currentLogs = [
				SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
				FROM Log__c
				WHERE Id = :logId
		];
		if (!currentLogs.isEmpty()) {
			if (label == LABEL_SAME) {
				String reportId = getReportId(REPORT_NAME_SUMMARY_BY_DATE_HASH1);
				if (String.isNotBlank(reportId)) reportUrl = String.format(URL_REPORT_HASH1, new List<String>{reportId, currentLogs[0].Hash_1__c, logDate, currentLogs[0].Organization_Id__c});
			} else if (label == LABEL_SIMILAR) {
				String reportId = getReportId(REPORT_NAME_SUMMARY_BY_DATE_HASH2);
				if (String.isNotBlank(reportId)) reportUrl = String.format(URL_REPORT_HASH2, new List<String>{reportId, currentLogs[0].Hash_1__c, currentLogs[0].Hash_2__c, logDate, currentLogs[0].Organization_Id__c});
			} else if (label == LABEL_POSSIBLY_RELATED) {
				String reportId = getReportId(REPORT_NAME_SUMMARY_BY_DATE_HASH3);
				if (String.isNotBlank(reportId)) reportUrl = String.format(URL_REPORT_HASH3, new List<String>{reportId, currentLogs[0].Hash_1__c, currentLogs[0].Hash_2__c, currentLogs[0].Hash_3__c, logDate, currentLogs[0].Organization_Id__c});
			} else if (label == LABEL_TIMING) {
				String reportId = getReportId(REPORT_NAME_SUMMARY_BY_TIMING);
				if (String.isNotBlank(reportId)) reportUrl = String.format(URL_REPORT_TIMING, new List<String>{reportId, logDate, currentLogs[0].Organization_Id__c});
			}
		}
		return JSON.serialize(reportUrl);
	}

	private static String getReportId(String reportName) {
		return [SELECT Id, Name FROM Report WHERE Name = :reportName LIMIT 1]?.Id;
	}

    public class RemoteActionResponse {
        public Object params;
        public Object data;
        public String error;
        public String stack;
    }

}