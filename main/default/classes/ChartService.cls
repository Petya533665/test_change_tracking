public with sharing class ChartService {

	private final ChartServiceInterface strategy;
//fsdfdsfdsf
//fsdfdsfdsf

//fsdfdsfdsf

//fsdfdsfdsf
//fsdfdsfdsf
//fsdfdsfdsf
//fsdfdsfdsf

	public enum Chart {
		OCCURRENCE,
		OCCURRENCE_LAST_7_DAYS,
		OCCURRENCE_LAST_30_DAYS,
		USER_IMPACT_LAST_30_DAYS,
		USER_IMPACT_LAST_7_DAYS_DETAILS,
		USER_IMPACT_LAST_30_DAYS_DETAILS,
		DATA_IMPACT_LAST_30_DAYS,
		DATA_IMPACT_LAST_30_DAYS_DETAILS,
		TODAYS_USER_IMPACT,
		TODAYS_DATA_IMPACT,
		OCCURRENCE_LOGS,
		OCCURRENCE_LOGS_LAST_7_DAYS,
		OCCURRENCE_LOGS_LAST_30_DAYS,
		TIMING_LOGS,
		EVENT_LOG_RECORDS_BY_TYPE,
		EVENT_LOG_RECORDS_BY_CATEGORY
	}

	private enum Category {
		APEX,
		FLOW,
		PROCESS_BUILDER,
		INTEGRATION,
		BULK_API
	}

	public static final Map<Chart, Map<String, ReportService.SystemReport>> CHART_TO_SYSTEM_REPORTS = new Map<Chart, Map<String, ReportService.SystemReport>> {
		Chart.OCCURRENCE => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE
		},
		Chart.OCCURRENCE_LAST_7_DAYS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE
		},
		Chart.OCCURRENCE_LAST_30_DAYS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE
		},
		Chart.USER_IMPACT_LAST_30_DAYS => new Map<String, ReportService.SystemReport> {

		},
		Chart.USER_IMPACT_LAST_7_DAYS_DETAILS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_LINKED,
			'2' => ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_DUP
		},
		Chart.USER_IMPACT_LAST_30_DAYS_DETAILS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_LINKED,
			'2' => ReportService.SystemReport.SYSTEM_CHART_USER_IMPACT_DETAILS_DUP
		},
		Chart.DATA_IMPACT_LAST_30_DAYS => new Map<String, ReportService.SystemReport> {

		},
		Chart.DATA_IMPACT_LAST_30_DAYS_DETAILS => new Map<String, ReportService.SystemReport> {

		},
		Chart.TODAYS_USER_IMPACT => new Map<String, ReportService.SystemReport> {

		},
		Chart.TODAYS_DATA_IMPACT => new Map<String, ReportService.SystemReport> {

		},
		Chart.OCCURRENCE_LOGS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1,
			'2' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2,
			'3' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3
		},
		Chart.OCCURRENCE_LOGS_LAST_7_DAYS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1,
			'2' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2,
			'3' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3
		},
		Chart.OCCURRENCE_LOGS_LAST_30_DAYS => new Map<String, ReportService.SystemReport> {
			'1' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH1,
			'2' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH2,
			'3' => ReportService.SystemReport.SYSTEM_CHART_LOG_OCCURRENCE_BY_HASH3
		},
		Chart.TIMING_LOGS => new Map<String, ReportService.SystemReport> {

		},
		Chart.EVENT_LOG_RECORDS_BY_TYPE => new Map<String, ReportService.SystemReport> {

		},
		Chart.EVENT_LOG_RECORDS_BY_CATEGORY => new Map<String, ReportService.SystemReport> {

		}
	};

	public static final String ISSUE_CHART_OCCURRENCE = 'Occurrence';
	public static final String ISSUE_CHART_OCCURRENCE_LAST_7_DAYS = 'Occurrence Last 7 Days';
	public static final String ISSUE_CHART_OCCURRENCE_LAST_30_DAYS = 'Occurrence Last 30 Days';
	public static final String ISSUE_CHART_USER_IMPACT_LAST_30_DAYS = 'User Impact Last 30 Days';
	public static final String ISSUE_CHART_USER_IMPACT_LAST_7_DAYS_DETAILS = 'User Impact Last 7 Days Details';
	public static final String ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS = 'User Impact Last 30 Days Details';
	public static final String ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS = 'Data Impact Last 30 Days';
	public static final String ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS = 'Data Impact Last 30 Days Details';

	public static final String ISSUE_CHART_TODAYS_USER_IMPACT = 'Todays User Impact';
	public static final String ISSUE_CHART_TODAYS_DATA_IMPACT = 'Todays Data Impact';

	public static final String LOG_CHART_OCCURRENCE_LOGS = 'Occurrence Logs';
	public static final String LOG_CHART_OCCURRENCE_LOGS_LAST_7_DAYS = 'Occurrence Logs Last 7 Days';
	public static final String LOG_CHART_OCCURRENCE_LOGS_LAST_30_DAYS = 'Occurrence Logs Last 30 Days';
	public static final String LOG_CHART_TIMING_LOGS = 'Timing Logs';

	public static final String CHART_PREFIX_Label = 'System Auto Chart';
	public static final String CHART_PREFIX= 'System_Auto_Chart';

	private static final String EVENT_CHART_EVENT_LOG_RECORDS_BY_TYPE = 'Event Log Records By Type';
	private static final String EVENT_CHART_EVENT_LOG_RECORDS_BY_CATEGORY = 'Event Log Records By Category';

	private static final String STACKTRACE_CHART_APEX = 'Apex';
	private static final String STACKTRACE_CHART_FLOW = 'Flow';
	private static final String STACKTRACE_CHART_PROCESS_BUILDER = 'Process Builder';
	private static final String STACKTRACE_CHART_INTEGRATION = 'Integration';
	private static final String STACKTRACE_CHART_BULK_API = 'Bulk API';

	private static final Map<String, Chart> CHART_MAP = new Map<String, Chart>{
		ISSUE_CHART_OCCURRENCE => Chart.OCCURRENCE,
		ISSUE_CHART_OCCURRENCE_LAST_7_DAYS => Chart.OCCURRENCE_LAST_7_DAYS,
		ISSUE_CHART_OCCURRENCE_LAST_30_DAYS => Chart.OCCURRENCE_LAST_30_DAYS,
		ISSUE_CHART_USER_IMPACT_LAST_30_DAYS => Chart.USER_IMPACT_LAST_30_DAYS,
		ISSUE_CHART_USER_IMPACT_LAST_7_DAYS_DETAILS => Chart.USER_IMPACT_LAST_7_DAYS_DETAILS,
		ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS => Chart.USER_IMPACT_LAST_30_DAYS_DETAILS,
		ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS => Chart.DATA_IMPACT_LAST_30_DAYS,
		ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS => Chart.DATA_IMPACT_LAST_30_DAYS_DETAILS,
		ISSUE_CHART_TODAYS_USER_IMPACT => Chart.TODAYS_USER_IMPACT,
		ISSUE_CHART_TODAYS_DATA_IMPACT => Chart.TODAYS_DATA_IMPACT,
		LOG_CHART_OCCURRENCE_LOGS => Chart.OCCURRENCE_LOGS,
		LOG_CHART_OCCURRENCE_LOGS_LAST_7_DAYS => Chart.OCCURRENCE_LOGS_LAST_7_DAYS,
		LOG_CHART_OCCURRENCE_LOGS_LAST_30_DAYS => Chart.OCCURRENCE_LOGS_LAST_30_DAYS,
		LOG_CHART_TIMING_LOGS => Chart.TIMING_LOGS,
		EVENT_CHART_EVENT_LOG_RECORDS_BY_TYPE => Chart.EVENT_LOG_RECORDS_BY_TYPE,
		EVENT_CHART_EVENT_LOG_RECORDS_BY_CATEGORY => Chart.EVENT_LOG_RECORDS_BY_CATEGORY
	};

	private static final Map<String, Category> CATEGORY_MAP = new Map<String, Category>{
			STACKTRACE_CHART_APEX => Category.APEX,
			STACKTRACE_CHART_FLOW => Category.FLOW,
			STACKTRACE_CHART_PROCESS_BUILDER => Category.PROCESS_BUILDER,
			STACKTRACE_CHART_INTEGRATION => Category.INTEGRATION,
			STACKTRACE_CHART_BULK_API => Category.BULK_API
	};



	public static Chart getChartEnumByChartName(String chartName) {
		List<ChartService.Chart> allCharts = ChartService.Chart.values();
		
		for (ChartService.Chart chart : allCharts) {
			if (chart.name() == chartName) {
				return chart;
			}
		}
		
		return null;
	}

	public static List<AdminService.MergeField> getChartsFields() {
		return new List<AdminService.MergeField> {
			//Issue object
			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + ISSUE_CHART_USER_IMPACT_LAST_7_DAYS_DETAILS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ISSUE_CHART_USER_IMPACT_LAST_7_DAYS_DETAILS)).toString() + '}',
				'issue',
				CHART_PREFIX + '.' + (CHART_MAP.get(ISSUE_CHART_USER_IMPACT_LAST_7_DAYS_DETAILS)).toString()
			),
			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS)).toString()+ '}',
				'issue',
				CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS)).toString()
			),

			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + ISSUE_CHART_OCCURRENCE_LAST_7_DAYS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ISSUE_CHART_OCCURRENCE_LAST_7_DAYS)).toString() + '}',
				'issue',
				CHART_PREFIX + '.' + (CHART_MAP.get(ISSUE_CHART_OCCURRENCE_LAST_7_DAYS)).toString()
			),
			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + ISSUE_CHART_OCCURRENCE_LAST_30_DAYS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.ISSUE_CHART_OCCURRENCE_LAST_30_DAYS)).toString()+ '}',
				'issue',
				CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.ISSUE_CHART_OCCURRENCE_LAST_30_DAYS)).toString()
			),

			//Log object
			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + LOG_CHART_OCCURRENCE_LOGS_LAST_7_DAYS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.LOG_CHART_OCCURRENCE_LOGS_LAST_7_DAYS)).toString() + '}',
				'log',
				CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.LOG_CHART_OCCURRENCE_LOGS_LAST_7_DAYS)).toString()

			),
			new AdminService.MergeField(
				CHART_PREFIX_Label + ' -> ' + LOG_CHART_OCCURRENCE_LOGS_LAST_30_DAYS,
				'{!' + CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.LOG_CHART_OCCURRENCE_LOGS_LAST_30_DAYS)).toString() + '}',
				'log',
				CHART_PREFIX + '.' + (CHART_MAP.get(ChartService.LOG_CHART_OCCURRENCE_LOGS_LAST_30_DAYS)).toString()
			)
		};
	}

	private static final String ALL_RELATED_OPTION = 'All';
	private static final String NONE_RELATED_OPTION = 'None';
	private static final String CHILD_ISSUES_RELATED_OPTION = 'Child Issues';
	private static final String SIBLING_ISSUES_RELATED_OPTION = 'Sibling Issues';

	public static final Integer LAST_7_DAYS_DATE_RANGE = 7;
	public static final Integer LAST_30_DAYS_DATE_RANGE = 30;
	public static final Integer LAST_60_DAYS_DATE_RANGE = 60;
	public static final Integer LAST_6_MONTH_DATE_RANGE = 180;

	public ChartService(String recordId, String chartName, Integer dateRange) {
		strategy = getChartServiceInterface(chartName, isBlurMode(recordId), dateRange);
	}

	public ChartService(ChartDataProperties chartDataProperties) {
		strategy = getChartServiceInterface(chartDataProperties);
	}

	public ChartDataProperties getChartDataProperties(String recordId) {
		return strategy.getChartDataProperties(recordId);
	}

	public ChartDataProperties getChartDataProperties(String recordId, Integer dateRange) {
		return strategy.getChartDataProperties(recordId, dateRange);
	}

	public ChartDataProperties getChartDataProperties(String recordId, Integer dateRange, String related) {
		return strategy.getChartDataProperties(recordId, dateRange, related);
	}

	public List<ChartData> getChartData() {
		return strategy.getChartData();
	}

	public String getChartDataJSON() {
		return strategy.getChartDataJSON();
	}

	public interface ChartServiceInterface {
		ChartDataProperties getChartDataProperties(String recordId);
		ChartDataProperties getChartDataProperties(String recordId, Integer dateRange);
		ChartDataProperties getChartDataProperties(String recordId, Integer dateRange, String related);
		List<ChartData> getChartData();
		String getChartDataJSON();
	}

	public abstract class ChartServiceAbstract implements ChartServiceInterface {

		private final ChartDataProperties chartDataProperties;

		private List<AggregateResult> aggregateResults;

		public ChartServiceAbstract(String chartName) {
			chartDataProperties = new ChartDataProperties();
			chartDataProperties.chartName = chartName;
			chartDataProperties.isBlurMode = false;
		}

		public ChartServiceAbstract(ChartDataProperties chartDataProperties) {
			this.chartDataProperties = chartDataProperties;
		}

		public virtual ChartDataProperties getChartDataProperties(String recordId, Integer dateRange, String related) {
			chartDataProperties.recordId = recordId;
			chartDataProperties.recordIds = getRecordIds(recordId, related);
			chartDataProperties.dateRange = getDateRange(dateRange);
			chartDataProperties.mapDateByLabel = getMapDateByLabel();
			aggregateResults = getAggregateResultLogs();
			chartDataProperties.mapExistDateByLabel = getMapExistDateByLabel();
			return chartDataProperties;
		}

		public virtual List<ChartData> getChartData() {
			return new List<ChartData>();
		}

		private virtual Set<String> getRecordIds(String recordId, String related) {
			return new Set<String>{recordId};
		}

		private virtual Integer getDateRange(Integer dateRange) {
			return dateRange != null ? dateRange : LAST_30_DAYS_DATE_RANGE;
		}

		private virtual Map<String, String> getMapDateByLabel() {
			Map<String, String> mapDateByLabel = new Map<String, String>();
			for (Integer i = chartDataProperties.dateRange - 1; i >= 0; i--) {
				mapDateByLabel.put(System.now().addDays(-i).format('MMM dd'), System.now().addDays(-i).date().format());
			}
			return mapDateByLabel;
		}

		private virtual Map<String, String> getMapExistDateByLabel() {
			Map<String, String> mapExistDateByLabel = new Map<String, String>();
			for (AggregateResult aggregateResult : aggregateResults) {
				Date createdAtDate = Date.valueOf(aggregateResult.get('created_at'));
				Datetime createdAtDatetime = Datetime.newInstanceGmt(createdAtDate.year(), createdAtDate.month(), createdAtDate.day());
				mapExistDateByLabel.put(createdAtDatetime.formatGmt('MMM dd'), createdAtDatetime.formatGmt('YYYY-MM-dd'));
			}
			return mapExistDateByLabel;
		}

		private virtual List<AggregateResult> getAggregateResultLogs() {
			Date createdAt = Date.today().addDays(-chartDataProperties.dateRange);
			return [
					SELECT COUNT(Id) log_count, DAY_ONLY(convertTimezone(Created_At__c)) created_at
					FROM Log__c
					WHERE Issue__c IN :chartDataProperties.recordIds
					AND	DAY_ONLY(convertTimezone(Created_At__c)) >= :createdAt
					GROUP BY DAY_ONLY(convertTimezone(Created_At__c))
					ORDER BY DAY_ONLY(convertTimezone(Created_At__c))];
		}

		public virtual ChartDataProperties getChartDataProperties(String recordId) {
			chartDataProperties.recordId = recordId;
			chartDataProperties.todaysLogsCount = getTodaysLogsCount(recordId);
			return chartDataProperties;
		}

		private virtual Integer getTodaysLogsCount(String recordId) {
			Set<String> setUniqueIds = new Set<String>();
			for (Log__c log : [
					SELECT Id, Related_Id__c, Related_Objects__c, User_Id__c
					FROM Log__c
					WHERE (Issue__c = :recordId OR (Issue__r.Related_Issue__c = :recordId AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE))
					AND Created_At__c = TODAY
			]) {
				if (chartDataProperties.chartName == ISSUE_CHART_TODAYS_DATA_IMPACT) {
					if (String.isNotBlank(log.Related_Id__c)) setUniqueIds.add(log.Related_Id__c);
					if (String.isNotBlank(log.Related_Objects__c)) {
						Map<String, List<String>> mapRelatedObjects;
						try {
							mapRelatedObjects = (Map<String, List<String>>)JSON.deserialize(log.Related_Objects__c, Map<String, List<String>>.class);
							for (String key : mapRelatedObjects.keySet()) {
								setUniqueIds.addAll(mapRelatedObjects.get(key));
							}
						} catch (JSONException e) {
							// catch JSON deserialize issue
						}
					}
				} else {
					if (String.isNotBlank(log.User_Id__c)) setUniqueIds.add(log.User_Id__c);
				}
			}
			return setUniqueIds.size();
		}

		public virtual ChartDataProperties getChartDataProperties(String recordId, Integer dateRange) {
			chartDataProperties.recordId = recordId;
			chartDataProperties.dateRange = dateRange;
			return chartDataProperties;
		}

		public virtual String getChartDataJSON() {
			return null;
		}

		private virtual void updateTimeZone(List<Log__c> logs, String fieldName) {
			for (Log__c log : logs) {
				Integer offset = UserInfo.getTimeZone().getOffset((Datetime)log.get(fieldName));
				log.put(fieldName, ((Datetime)log.get(fieldName)).addSeconds(offset/1000));
			}
		}
	}

	public abstract class BlurModeChartServiceAbstract extends ChartServiceAbstract {
		public BlurModeChartServiceAbstract(String chartName) {
			super(chartName);
			chartDataProperties.isBlurMode = true;
		}
		public BlurModeChartServiceAbstract(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override List<ChartData> getChartData() {
			List<ChartData> chartData = new List<ChartData>();
			Date createdAt = Date.valueOf(chartDataProperties.requestedCreatedAt);
			ChartData aChartData = new ChartData();
			aChartData.detailsLabel = 'Upgrade to Growth';
			aChartData.labels = new List<String>{((Datetime)createdAt).formatGmt('MMM dd')};
			aChartData.detail = new List<Integer>{createdAt.daysBetween(Date.today())};
			aChartData.stack = '1';
			aChartData.recordIds = new List<String>{'Upgrade to Growth'};
			aChartData.sObjectRecordIds = new List<String>{'Upgrade to Growth'};
			chartData.add(aChartData);
			return chartData;
		}
		private override Map<String, String> getMapExistDateByLabel() {
			Map<String, String> mapExistDateByLabel = new Map<String, String>();
			for (Integer i = chartDataProperties.dateRange; i >= 0; i--) {
				Date createdAtDate = Date.today().addDays(-i);
				Datetime createdAtDatetime = Datetime.newInstanceGmt(createdAtDate.year(), createdAtDate.month(), createdAtDate.day());
				mapExistDateByLabel.put(createdAtDatetime.formatGmt('MMM dd'), createdAtDatetime.formatGmt('YYYY-MM-dd'));
			}
			return mapExistDateByLabel;
		}
	}

	// OCCURRENCE
	public class OccurrenceChartService extends ChartServiceAbstract {
		private final String CURRENT_ISSUE_OCCURRENCE_COLOR = 'rgba(244,40,78,1)';
		public OccurrenceChartService(String chartName) {
			super(chartName);
		}
		public OccurrenceChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override List<ChartData> getChartData() {
			List<ChartData> chartData = new List<ChartData>();
			Date createdAt = Date.valueOf(chartDataProperties.requestedCreatedAt);
			List<Log__c> logs = [
					SELECT Id, Issue__c, Issue__r.Name, Created_At__c
					FROM Log__c
					WHERE Issue__c IN :chartDataProperties.recordIds
					AND	DAY_ONLY(convertTimezone(Created_At__c)) = :createdAt
					ORDER BY Created_At__c DESC
			];
			Set<String> labels = new Set<String>();
			for (Log__c log : logs) {
				if (String.isNotBlank(log.Issue__r.Name)) labels.add(log.Issue__r.Name);
			}
			for (String label : labels) {
				ChartData aChartData = new ChartData();
				aChartData.detailsLabel = label;
				aChartData.labels = new List<String>();
				aChartData.detail = new List<Integer>();
				aChartData.stack = '1';
				aChartData.labels.add(((Datetime)createdAt).formatGmt('MMM dd'));
				aChartData.recordIds = new List<String>();
				Boolean isCurrentIssue = false;
				for (Log__c log : logs) {
					if (label == log.Issue__r.Name) {
						aChartData.recordIds.add(String.valueOf(log.Id).left(15));
						if (chartDataProperties.recordId == log.Issue__c) isCurrentIssue = true;
					}
				}
				aChartData.detail.add(aChartData.recordIds.size());
				if (isCurrentIssue) aChartData.bgColor = CURRENT_ISSUE_OCCURRENCE_COLOR;
				chartData.add(aChartData);
			}

			return chartData;
		}

		private override Set<String> getRecordIds(String recordId, String related) {
			Set<String> recordIds = new Set<String>();
			List<Issue__c> currentIssues = [SELECT Id, Related_Issue__c, Related_Issue__r.Related_Issue__c FROM Issue__c WHERE Id = :recordId];
			if (!currentIssues.isEmpty()) {
				Issue__c currentIssue = currentIssues[0];
				for (Issue__c issue : [
						SELECT Id, Related_Issue__c, Related_Issue__r.Related_Issue__c, Status__c
						FROM Issue__c
						WHERE Id = :currentIssue.Id
						OR Id = :currentIssue.Related_Issue__c
						OR Related_Issue__c = :currentIssue.Id
						OR Related_Issue__c = :currentIssue.Related_Issue__c
						OR Related_Issue__c = :currentIssue.Related_Issue__r.Related_Issue__c
						OR Related_Issue__r.Related_Issue__c = :currentIssue.Id
				]) {
					if (String.isBlank(related) || new List<String>{ALL_RELATED_OPTION, NONE_RELATED_OPTION}.contains(related)) {
						if (issue.Id == currentIssue.Id
								|| (issue.Related_Issue__c == currentIssue.Id && issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE)
								|| (String.isNotBlank(currentIssue.Related_Issue__c) && issue.Related_Issue__c == currentIssue.Related_Issue__c)
								|| (String.isNotBlank(currentIssue.Related_Issue__c) && issue.Related_Issue__r.Related_Issue__c == currentIssue.Related_Issue__c && issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE)) {
							recordIds.add(issue.Id);
						}
					}
					if (new List<String>{ALL_RELATED_OPTION, CHILD_ISSUES_RELATED_OPTION}.contains(related)) {
						if (issue.Related_Issue__c == currentIssue.Id
								|| (issue.Related_Issue__r.Related_Issue__c == currentIssue.Id && issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE)) {
							recordIds.add(issue.Id);
						}
					}
					if (new List<String>{ALL_RELATED_OPTION, SIBLING_ISSUES_RELATED_OPTION}.contains(related)) {
						if (issue.Id == currentIssue.Related_Issue__c
								|| (String.isNotBlank(currentIssue.Related_Issue__r.Related_Issue__c) && issue.Related_Issue__c == currentIssue.Related_Issue__r.Related_Issue__c)
								|| (String.isNotBlank(currentIssue.Related_Issue__r.Related_Issue__c) && issue.Related_Issue__r.Related_Issue__c == currentIssue.Related_Issue__r.Related_Issue__c && issue.Status__c == IssueService.ISSUE_STATUS_DUPLICATE)) {
							recordIds.add(issue.Id);
						}
					}
				}
			}
			return recordIds;
		}
	}

	// BLUR MODE // OCCURRENCE
	public class OccurrenceBlurModeChartService extends BlurModeChartServiceAbstract {
		public OccurrenceBlurModeChartService(String chartName) {
			super(chartName);
		}
		public OccurrenceBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
	}

	// USER_IMPACT_LAST_30_DAYS, USER_IMPACT_LAST_30_DAYS_DETAILS
	public class UserImpactChartService extends ChartServiceAbstract {
		public UserImpactChartService(String chartName) {
			super(chartName);
		}
		public UserImpactChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override List<ChartData> getChartData() {
			List<ChartData> chartData = new List<ChartData>();
			Date createdAt = Date.valueOf(chartDataProperties.requestedCreatedAt);
			
			// Refactored query with improved readability
			List<Log__c> logs = getUserImpactLogs(createdAt);
			
			Set<String> labels = new Set<String>();
			for (Log__c log : logs) {
				if (String.isNotBlank(log.User_Name__c)) {
					labels.add(log.User_Name__c);
				}
			}
			for (String label : labels) {
				ChartData aChartData = new ChartData();
				aChartData.detailsLabel = label;
				aChartData.labels = new List<String>();
				aChartData.detail = new List<Integer>();
				aChartData.stack = '1';
				aChartData.labels.add(((Datetime)createdAt).formatGmt('MMM dd'));
				Integer i = 0;
				Set<String> recordIds = new Set<String>();
				Set<String> sObjectRecordIds = new Set<String>();
				for (Log__c log : logs) {
					if (String.isNotBlank(log.User_Name__c) && label == log.User_Name__c) {
						i++;
						recordIds.add(String.valueOf(log.Id).left(15));
						if (String.isNotBlank(log.User_Id__c)) sObjectRecordIds.add(log.User_Id__c);
					}
				}
				aChartData.detail.add(i);
				aChartData.recordIds = new List<String>(recordIds);
				aChartData.sObjectRecordIds = new List<String>(sObjectRecordIds);
				chartData.add(aChartData);
			}
			return chartData;
		}
		
		/**
		 * Retrieves logs for user impact analysis with improved query structure
		 * @param createdAt The date to filter logs by
		 * @return List of Log__c records
		 */
		private List<Log__c> getUserImpactLogs(Date createdAt) {
			return [
				SELECT Id, User_Name__c, User_Id__c, Created_At__c
				FROM Log__c
				WHERE (
					Issue__c IN :chartDataProperties.recordIds
					OR (
						Issue__r.Related_Issue__c IN :chartDataProperties.recordIds
						AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE
					)
				)
				AND DAY_ONLY(convertTimezone(Created_At__c)) = :createdAt
				ORDER BY Created_At__c DESC
			];
		}
	}

	// BLUR MODE // USER_IMPACT_LAST_30_DAYS, USER_IMPACT_LAST_30_DAYS_DETAILS
	public class UserImpactBlurModeChartService extends BlurModeChartServiceAbstract {
		public UserImpactBlurModeChartService(String chartName) {
			super(chartName);
		}
		public UserImpactBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
	}

	// DATA_IMPACT_LAST_30_DAYS, DATA_IMPACT_LAST_30_DAYS_DETAILS
	public class DataImpactChartService extends ChartServiceAbstract {
		public DataImpactChartService(String chartName) {
			super(chartName);
		}
		public DataImpactChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override List<ChartData> getChartData() {
			List<ChartData> chartData = new List<ChartData>();
			Date createdAt = Date.valueOf(chartDataProperties.requestedCreatedAt);
			
			// Refactored query with improved readability
			List<Log__c> logs = getDataImpactLogs(createdAt);
			
			Set<String> labels = new Set<String>();
			for (Log__c log : logs) {
				if (String.isNotBlank(log.Related_Objects__c)) {
					Map<String, List<String>> mapRelatedObjects;
					try {
						mapRelatedObjects = (Map<String, List<String>>)JSON.deserialize(log.Related_Objects__c, Map<String, List<String>>.class);
					} catch (JSONException e) {
						// catch JSON deserialize issue
					}
					if (mapRelatedObjects != null) {
						for (String relatedObject : mapRelatedObjects.keySet()) {
							labels.add(relatedObject.split(':')[0]);
						}
					}
				} else if (String.isNotBlank(log.Related_Object_Type__c)) {
					labels.add(log.Related_Object_Type__c);
				}
			}
			for (String label : labels) {
				ChartData aChartData = new ChartData();
				aChartData.detailsLabel = label;
				aChartData.labels = new List<String>();
				aChartData.detail = new List<Integer>();
				aChartData.stack = '1';
				aChartData.labels.add(((Datetime)createdAt).formatGmt('MMM dd'));
				Integer i = 0;
				Set<String> recordIds = new Set<String>();
				Set<String> sObjectRecordIds = new Set<String>();
				for (Log__c log : logs) {
					if (String.isNotBlank(log.Related_Objects__c)) {
						Map<String, List<String>> mapRelatedObjects;
						try {
							mapRelatedObjects = (Map<String, List<String>>)JSON.deserialize(log.Related_Objects__c, Map<String, List<String>>.class);
						} catch (JSONException e) {
							// catch JSON deserialize issue
						}
						if (mapRelatedObjects != null) {
							for (String relatedObject : mapRelatedObjects.keySet()) {
								if (label == relatedObject.split(':')[0]) {
									i += mapRelatedObjects.get(relatedObject).size();
									recordIds.add(String.valueOf(log.Id).left(15));
									sObjectRecordIds.addAll(mapRelatedObjects.get(relatedObject));
								}
							}
						}
					} else if (String.isNotBlank(log.Related_Object_Type__c) && label == log.Related_Object_Type__c) {
						i++;
						recordIds.add(String.valueOf(log.Id).left(15));
						if (String.isNotBlank(log.Related_Id__c)) sObjectRecordIds.add(log.Related_Id__c);
					}
				}
				aChartData.detail.add(i);
				aChartData.recordIds = new List<String>(recordIds);
				aChartData.sObjectRecordIds = new List<String>(sObjectRecordIds);
				chartData.add(aChartData);
			}
			return chartData;
		}
		
		/**
		 * Retrieves logs for data impact analysis with improved query structure
		 * @param createdAt The date to filter logs by
		 * @return List of Log__c records
		 */
		private List<Log__c> getDataImpactLogs(Date createdAt) {
			return [
				SELECT Id, Related_Objects__c, Related_Object_Type__c, Related_Id__c, Created_At__c
				FROM Log__c
				WHERE (
					Issue__c IN :chartDataProperties.recordIds
					OR (
						Issue__r.Related_Issue__c IN :chartDataProperties.recordIds
						AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE
					)
				)
				AND DAY_ONLY(convertTimezone(Created_At__c)) = :createdAt
				ORDER BY Created_At__c DESC
			];
		}
	}

	// BLUR MODE // DATA_IMPACT_LAST_30_DAYS, DATA_IMPACT_LAST_30_DAYS_DETAILS
	public class DataImpactBlurModeChartService extends BlurModeChartServiceAbstract {
		public DataImpactBlurModeChartService(String chartName) {
			super(chartName);
		}
		public DataImpactBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
	}

	// TODAYS_USER_IMPACT, TODAYS_DATA_IMPACT
	public class TodaysImpactChartService extends ChartServiceAbstract {
		public TodaysImpactChartService(String chartName) {
			super(chartName);
		}
		public TodaysImpactChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
	}

	// BLUR MODE // TODAYS_USER_IMPACT, TODAYS_DATA_IMPACT
	public class TodaysImpactBlurModeChartService extends BlurModeChartServiceAbstract {
		public TodaysImpactBlurModeChartService(String chartName) {
			super(chartName);
		}
		public TodaysImpactBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
	}

	// OCCURRENCE_LOGS
	public class OccurrenceLogsChartService extends ChartServiceAbstract {
		public OccurrenceLogsChartService(String chartName) {
			super(chartName);
		}
		public OccurrenceLogsChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override String getChartDataJSON() {
			Map<String, Object> dataMap = new Map<String, Object>();
			Date endDate;
			Date startDate;
			if (chartDataProperties.dateRange == LAST_7_DAYS_DATE_RANGE || chartDataProperties.dateRange == LAST_30_DAYS_DATE_RANGE || chartDataProperties.dateRange == LAST_60_DAYS_DATE_RANGE || chartDataProperties.dateRange == LAST_6_MONTH_DATE_RANGE) {
				endDate = Date.today();
				startDate = endDate.addDays(-chartDataProperties.dateRange);
			} else {
				endDate = Date.today();
				startDate = endDate.addDays(-LAST_30_DAYS_DATE_RANGE);
			}
			List<Log__c> currentLogs = [
					SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
					FROM Log__c
					WHERE Id = :chartDataProperties.recordId
			];
			if (!currentLogs.isEmpty()) {
				List<Log__c> logsWithHash1 = [
						SELECT Id, Created_At__c
						FROM Log__c
						WHERE (Hash_1__c = :currentLogs[0].Hash_1__c AND
						Organization_Id__c = :currentLogs[0].Organization_Id__c AND
						Hash_1__c != NULL AND
						DAY_ONLY(Created_At__c) >= :startDate AND
						DAY_ONLY(Created_At__c) <= :endDate
						) OR
						Id = :currentLogs[0].Id
						ORDER BY Created_At__c DESC];
				List<Log__c> logsWithHash2 = [
						SELECT Id, Created_At__c
						FROM Log__c
						WHERE Hash_2__c = :currentLogs[0].Hash_2__c AND
						Hash_1__c != :currentLogs[0].Hash_1__c AND
						Organization_Id__c = :currentLogs[0].Organization_Id__c AND
						Hash_2__c != NULL AND
						DAY_ONLY(Created_At__c) >= :startDate AND
						DAY_ONLY(Created_At__c) <= :endDate AND
						Id != :currentLogs[0].Id
						ORDER BY Created_At__c];
				List<Log__c> logsWithHash3 = [
						SELECT Id, Created_At__c
						FROM Log__c
						WHERE Hash_3__c = :currentLogs[0].Hash_3__c AND
						Hash_1__c != :currentLogs[0].Hash_1__c AND
						Hash_2__c != :currentLogs[0].Hash_2__c AND
						Organization_Id__c = :currentLogs[0].Organization_Id__c AND
						Hash_3__c != NULL AND
						DAY_ONLY(Created_At__c) >= :startDate AND
						DAY_ONLY(Created_At__c) <= :endDate AND
						Id != :currentLogs[0].Id
						ORDER BY Created_At__c];
				ConfigUtil.updateTimeZone(logsWithHash1, 'Created_At__c');
				ConfigUtil.updateTimeZone(logsWithHash2, 'Created_At__c');
				ConfigUtil.updateTimeZone(logsWithHash3, 'Created_At__c');
				dataMap.put('hash1', ConfigUtil.getSObjectWithoutNameSpace(logsWithHash1));
				dataMap.put('hash2', ConfigUtil.getSObjectWithoutNameSpace(logsWithHash2));
				dataMap.put('hash3', ConfigUtil.getSObjectWithoutNameSpace(logsWithHash3));
			}

			return JSON.serialize(dataMap);
		}
	}

	// BLUR MODE // OCCURRENCE_LOGS
	public class OccurrenceLogsBlurModeChartService extends BlurModeChartServiceAbstract {
		public OccurrenceLogsBlurModeChartService(String chartName) {
			super(chartName);
		}
		public OccurrenceLogsBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override String getChartDataJSON() {
			Map<String, Object> dataMap = new Map<String, Object>();
			List<Log__c> logs = new List<Log__c>();
			for (Integer i = chartDataProperties.dateRange; i >= 0; i--) {
				i--;
				for (Integer n = 0; n <= i; n++) {
					Log__c log = new Log__c();
					log.Created_At__c = System.now().addDays(-i);
					logs.add(log);
				}
			}
			ConfigUtil.updateTimeZone(logs, 'Created_At__c');
			dataMap.put('hash1', ConfigUtil.getSObjectWithoutNameSpace(logs));
			dataMap.put('hash2', ConfigUtil.getSObjectWithoutNameSpace(logs));
			dataMap.put('hash3', ConfigUtil.getSObjectWithoutNameSpace(logs));
			return JSON.serialize(dataMap);
		}
	}

	// TIMING_LOGS
	public class TimingLogsChartService extends ChartServiceAbstract {
		public TimingLogsChartService(String chartName) {
			super(chartName);
		}
		public TimingLogsChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override String getChartDataJSON() {
			Map<String, Object> dataMap = new Map<String, Object>();
			List<Log__c> currentLogs = [
					SELECT Id, Name, Hash__c, Hash_1__c, Hash_2__c, Hash_3__c, Created_At__c, Summary__c, Organization_Id__c
					FROM Log__c
					WHERE Id = :chartDataProperties.recordId
			];
			if (!currentLogs.isEmpty()) {
				Datetime endDate;
				Datetime startDate;
				Datetime dt = currentLogs[0].Created_At__c;
				if (chartDataProperties.dateRange == 10 || chartDataProperties.dateRange == 30 || chartDataProperties.dateRange == 60) {
					endDate = dt.addMinutes( 1 * Integer.valueOf(chartDataProperties.dateRange));
					startDate = dt.addMinutes( -1 * Integer.valueOf(chartDataProperties.dateRange));
				} else {
					endDate = dt.addMinutes(10);
					startDate = dt.addMinutes(-10);
				}
				List<Log__c> allLogs = [
						SELECT Id, Created_At__c, Hash_1__c, Summary__c
						FROM Log__c
						WHERE Organization_Id__c = :currentLogs[0].Organization_Id__c AND
						Created_At__c >= :startDate AND
						Created_At__c <= :endDate
						ORDER BY Created_At__c];
				ConfigUtil.updateTimeZone(allLogs, 'Created_At__c');
				dataMap.put('allLogs', ConfigUtil.getSObjectWithoutNameSpace(allLogs));
			}
			return JSON.serialize(dataMap);
		}
	}

	// BLUR MODE // TIMING_LOGS
	public class TimingLogsBlurModeChartService extends BlurModeChartServiceAbstract {
		public TimingLogsBlurModeChartService(String chartName) {
			super(chartName);
		}
		public TimingLogsBlurModeChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override String getChartDataJSON() {
			Datetime dt = Datetime.now();
			List<Log__c> logs = [SELECT Id, Created_At__c FROM Log__c WHERE Id = :chartDataProperties.recordId];
			if (!logs.isEmpty()) dt = logs[0].Created_At__c;
			Map<String, Object> dataMap = new Map<String, Object>();
			List<Log__c> allLogs = new List<Log__c>();
			for (Integer i = chartDataProperties.dateRange; i >= 0; i--) {
				for (Integer n = 0; n <= i; n++) {
					Log__c log = new Log__c();
					log.Created_At__c = dt.addMinutes(-i);
					allLogs.add(log);
				}
			}
			ConfigUtil.updateTimeZone(allLogs, 'Created_At__c');
			dataMap.put('allLogs', ConfigUtil.getSObjectWithoutNameSpace(allLogs));
			return JSON.serialize(dataMap);
		}
	}

	// EVENT_LOG_RECORDS_BY_TYPE, EVENT_LOG_RECORDS_BY_CATEGORY
	public class EventLogRecordsChartService extends ChartServiceAbstract {
		private final String EMPTY_LABEL = '-';
		public EventLogRecordsChartService(String chartName) {
			super(chartName);
		}
		public EventLogRecordsChartService(ChartDataProperties chartDataProperties) {
			super(chartDataProperties);
		}
		public override ChartDataProperties getChartDataProperties(String recordId, Integer dateRange, String related) {
			chartDataProperties.recordId = recordId;
			chartDataProperties.recordIds = getRecordIds(recordId, related);
			aggregateResults = getAggregateResultLogs();
			chartDataProperties.mapExistDateByLabel = getMapExistDateByLabel();
			return chartDataProperties;
		}
		public override List<ChartData> getChartData() {
			List<ChartData> chartData = new List<ChartData>();
			List<Event__c> events = [
					SELECT Id, Records__c
					FROM Event__c
					WHERE Id IN :chartDataProperties.recordIds
			];
			Set<String> logRecordIds = new Set<String>();
			for (Event__c event : events) {
				logRecordIds.addAll(EventsChartsWrapperController.parseIds(event.Records__c));
			}
			Date createdAt = Date.valueOf(chartDataProperties.requestedCreatedAt);
			List<Log__c> logs = [
					SELECT Id, Type__c, Category__c, Created_At__c
					FROM Log__c
					WHERE Id IN :logRecordIds
					AND	DAY_ONLY(convertTimezone(Created_At__c)) = :createdAt
					ORDER BY Created_At__c DESC
			];
			Set<String> labels = new Set<String>();
			for (Log__c log : logs) {
				if (chartDataProperties.chartName == EVENT_CHART_EVENT_LOG_RECORDS_BY_TYPE) {
					labels.add(String.isNotBlank(log.Type__c) ? log.Type__c : EMPTY_LABEL);
				} else if (chartDataProperties.chartName == EVENT_CHART_EVENT_LOG_RECORDS_BY_CATEGORY) {
					labels.add(String.isNotBlank(log.Category__c) ? log.Category__c : EMPTY_LABEL);
				}
			}
			for (String label : labels) {
				ChartData aChartData = new ChartData();
				aChartData.detailsLabel = label;
				aChartData.labels = new List<String>();
				aChartData.detail = new List<Integer>();
				aChartData.stack = '1';
				aChartData.labels.add(((Datetime)createdAt).formatGmt('MMM dd'));
				Integer i = 0;
				Set<String> recordIds = new Set<String>();
				for (Log__c log : logs) {
					if ((chartDataProperties.chartName == EVENT_CHART_EVENT_LOG_RECORDS_BY_TYPE && (label == log.Type__c || (label == EMPTY_LABEL && String.isBlank(log.Type__c))))
							|| (chartDataProperties.chartName == EVENT_CHART_EVENT_LOG_RECORDS_BY_CATEGORY && (label == log.Category__c || (label == EMPTY_LABEL && String.isBlank(log.Category__c))))) {
						i++;
						recordIds.add(String.valueOf(log.Id).left(15));
					}
				}
				aChartData.detail.add(i);
				aChartData.recordIds = new List<String>(recordIds);
				aChartData.sObjectRecordIds = new List<String>(recordIds);
				chartData.add(aChartData);
			}
			return chartData;
		}
		private override List<AggregateResult> getAggregateResultLogs() {
			List<Event__c> events = [
					SELECT Id, Records__c
					FROM Event__c
					WHERE Id IN :chartDataProperties.recordIds
			];
			Set<String> logs = new Set<String>();
			for (Event__c event : events) {
				logs.addAll(EventsChartsWrapperController.parseIds(event.Records__c));
			}
			return [
					SELECT COUNT(Id) log_count, DAY_ONLY(convertTimezone(Created_At__c)) created_at
					FROM Log__c
					WHERE Id IN :logs
					GROUP BY DAY_ONLY(convertTimezone(Created_At__c))
					ORDER BY DAY_ONLY(convertTimezone(Created_At__c))];
		}
	}

	private static Boolean isBlurMode(String recordId) {
		return !BlurModeService.isAvailableDebugView(recordId);
	}

	private static ChartServiceInterface getChartServiceInterface(String chartName, Boolean isBlurMode, Integer dateRange) {
		if ((CHART_MAP.get(chartName) == Chart.OCCURRENCE && dateRange == LAST_7_DAYS_DATE_RANGE)
				|| (CHART_MAP.get(chartName) == Chart.OCCURRENCE_LOGS && dateRange == LAST_7_DAYS_DATE_RANGE)
				|| CHART_MAP.get(chartName) == Chart.TODAYS_USER_IMPACT
				|| CHART_MAP.get(chartName) == Chart.TODAYS_DATA_IMPACT) {
			return CHART_TO_SERVICE.get(CHART_MAP.get(chartName));
		}
		return isBlurMode ? BLUR_MODE_CHART_TO_SERVICE.get(CHART_MAP.get(chartName)) : CHART_TO_SERVICE.get(CHART_MAP.get(chartName));
	}

	private static final Map<Chart, ChartServiceInterface> CHART_TO_SERVICE = new Map<Chart, ChartServiceInterface>{
			Chart.OCCURRENCE => new OccurrenceChartService(ISSUE_CHART_OCCURRENCE),
			Chart.USER_IMPACT_LAST_30_DAYS => new UserImpactChartService(ISSUE_CHART_USER_IMPACT_LAST_30_DAYS),
			Chart.USER_IMPACT_LAST_30_DAYS_DETAILS => new UserImpactChartService(ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS),
			Chart.DATA_IMPACT_LAST_30_DAYS => new DataImpactChartService(ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS),
			Chart.DATA_IMPACT_LAST_30_DAYS_DETAILS => new DataImpactChartService(ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS),
			Chart.TODAYS_USER_IMPACT => new TodaysImpactChartService(ISSUE_CHART_TODAYS_USER_IMPACT),
			Chart.TODAYS_DATA_IMPACT => new TodaysImpactChartService(ISSUE_CHART_TODAYS_DATA_IMPACT),
			Chart.OCCURRENCE_LOGS => new OccurrenceLogsChartService(LOG_CHART_OCCURRENCE_LOGS),
			Chart.TIMING_LOGS => new TimingLogsChartService(LOG_CHART_TIMING_LOGS),
			Chart.EVENT_LOG_RECORDS_BY_TYPE => new EventLogRecordsChartService(EVENT_CHART_EVENT_LOG_RECORDS_BY_TYPE),
			Chart.EVENT_LOG_RECORDS_BY_CATEGORY => new EventLogRecordsChartService(EVENT_CHART_EVENT_LOG_RECORDS_BY_CATEGORY)
	};

	private static final Map<Chart, ChartServiceInterface> BLUR_MODE_CHART_TO_SERVICE = new Map<Chart, ChartServiceInterface>{
			Chart.OCCURRENCE => new OccurrenceBlurModeChartService(ISSUE_CHART_OCCURRENCE),
			Chart.USER_IMPACT_LAST_30_DAYS => new UserImpactBlurModeChartService(ISSUE_CHART_USER_IMPACT_LAST_30_DAYS),
			Chart.USER_IMPACT_LAST_30_DAYS_DETAILS => new UserImpactBlurModeChartService(ISSUE_CHART_USER_IMPACT_LAST_30_DAYS_DETAILS),
			Chart.DATA_IMPACT_LAST_30_DAYS => new DataImpactBlurModeChartService(ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS),
			Chart.DATA_IMPACT_LAST_30_DAYS_DETAILS => new DataImpactBlurModeChartService(ISSUE_CHART_DATA_IMPACT_LAST_30_DAYS_DETAILS),
			Chart.TODAYS_USER_IMPACT => new TodaysImpactBlurModeChartService(ISSUE_CHART_TODAYS_USER_IMPACT),
			Chart.TODAYS_DATA_IMPACT => new TodaysImpactBlurModeChartService(ISSUE_CHART_TODAYS_DATA_IMPACT),
			Chart.OCCURRENCE_LOGS => new OccurrenceLogsBlurModeChartService(LOG_CHART_OCCURRENCE_LOGS),
			Chart.TIMING_LOGS => new TimingLogsBlurModeChartService(LOG_CHART_TIMING_LOGS)
	};

	private static ChartServiceInterface getChartServiceInterface(ChartDataProperties chartDataProperties) {
		switch on CHART_MAP.get(chartDataProperties.chartName) {
			when OCCURRENCE {
				return chartDataProperties.isBlurMode
						? (ChartServiceInterface)new OccurrenceBlurModeChartService(chartDataProperties)
						: (ChartServiceInterface)new OccurrenceChartService(chartDataProperties);
			}
			when USER_IMPACT_LAST_30_DAYS, USER_IMPACT_LAST_30_DAYS_DETAILS {
				return chartDataProperties.isBlurMode
						? (ChartServiceInterface)new UserImpactBlurModeChartService(chartDataProperties)
						: (ChartServiceInterface)new UserImpactChartService(chartDataProperties);
			}
			when DATA_IMPACT_LAST_30_DAYS, DATA_IMPACT_LAST_30_DAYS_DETAILS {
				return chartDataProperties.isBlurMode
						? (ChartServiceInterface)new DataImpactBlurModeChartService(chartDataProperties)
						: (ChartServiceInterface)new DataImpactChartService(chartDataProperties);
			}
			when OCCURRENCE_LOGS {
				return chartDataProperties.isBlurMode
						? (ChartServiceInterface)new OccurrenceLogsBlurModeChartService(chartDataProperties)
						: (ChartServiceInterface)new OccurrenceLogsChartService(chartDataProperties);
			}
			when TIMING_LOGS {
				return chartDataProperties.isBlurMode
						? (ChartServiceInterface)new TimingLogsBlurModeChartService(chartDataProperties)
						: (ChartServiceInterface)new TimingLogsChartService(chartDataProperties);
			}
			when EVENT_LOG_RECORDS_BY_TYPE, EVENT_LOG_RECORDS_BY_CATEGORY {
				return new EventLogRecordsChartService(chartDataProperties);
			}
			when else {
				return null;
			}
		}
	}

	public class ChartDataProperties {
		@AuraEnabled
		public String recordId {get; set;}
		@AuraEnabled
		public String chartName {get; set;}
		@AuraEnabled
		public Integer dateRange {get; set;}
		@AuraEnabled
		public Integer todaysLogsCount {get; set;}
		@AuraEnabled
		public String requestedCreatedAt {get; set;}
		@AuraEnabled
		public Set<String> recordIds {get; set;}
		@AuraEnabled
		public List<String> detailsLabels {get; set;}
		@AuraEnabled
		public Map<String, String> mapDateByLabel {get; set;}
		@AuraEnabled
		public Map<String, String> mapExistDateByLabel {get; set;}
		@AuraEnabled
		public Boolean isBlurMode {get; set;}
	}

	public class ChartData {
		@AuraEnabled
		public String detailsLabel {get; set;}
		@AuraEnabled
		public List<String> labels {get; set;}
		@AuraEnabled
		public List<Integer> detail {get; set;}
		@AuraEnabled
		public List<String> recordIds {get; set;}
		@AuraEnabled
		public List<String> sObjectRecordIds {get; set;}
		@AuraEnabled
		public String bgColor {get; set;}
		@AuraEnabled
		public String stack {get; set;}
	}

}