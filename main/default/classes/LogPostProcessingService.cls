public with sharing class LogPostProcessingService {

	public static final String ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE = 'Data not yet available. Please check back in a minute or so.';
	public static final String ERROR_SYSTEM_INFO_LOG_RETRIEVE = 'An error occurred retrieving this information, please check the log records for details.';
	public static final String ERROR_SYSTEM_INFO_AUDIT_TRAIL_NOT_SUPPORTED = 'Setup audit trail is not available. Please log a case with salesforce support to turn on "Enable Setup Audit Trail API" permission in the backend.';
	public static final String PAGE_MONITOR_DEPLOYMENT_URL = '/changemgmt/monitorDeployment.apexp';
	public static final String PAGE_MONITOR_DEPLOYMENT_STATUS_DEPLOYMENT = 'Deployment Status';
	public static final String CATEGORY_INTEGRATION = 'Integration';
	public static final String POST_PROCESSING_STATUS_NEEDED = 'Needed';
	public static final String POST_PROCESSING_STATUS_CUSTOM_NEEDED = 'Custom Needed';
	public static final String POST_PROCESSING_STATUS_COMPLETED = 'Completed';
	public static final String POST_PROCESSING_STATUS_FAILED = 'Failed';
	public static final String POST_PROCESSING_STATUS_EXECUTED = 'Executed';
	public static final String RELATES_KEY_RELATED_ID = 'related_id';
	public static final String RELATES_KEY_RELATED_OBJECTS = 'related_objects';
	public static final String RELATES_KEY_RELATED_OBJECT_TYPE = 'related_object_type';

	@TestVisible
	private static final String AUDIT_TRAIL_SOBJECT = 'SetupAuditTrail';
	public static final Set<String> USER_FIELDS = new Set<String> {
		'Id', 'Name', 'ProfileId', 'Profile.Name', 'Profile.UserLicense.Name', 'UserRoleId', 'UserRole.Name'
	};
	public static final Set<String> AUDIT_TRAIL_FIELDS = new Set<String>{
		'Id','Action','CreatedBy.Name','CreatedDate','Display','Section','DelegateUser'
	};
	@TestVisible
	private static final Set<String> PUBLISHER_FIELDS = new Set<String> {
		'Name', 'NamespacePrefix', 'MajorVersion', 'MinorVersion'
	};
	@TestVisible
	private static final Set<String> ASYNC_JOB_FIELDS = new Set<String> {
		'Id', 'JobType', 'ApexClassID', 'ApexClass.Name', 'Status', 'MethodName'
	};
	@TestVisible
	private static final Set<String> DEPLOY_RESULT_FIELDS = new Set<String> {
		'Id', 'Status', 'CompletedDate'
	};

	public static final String STACK_TRACE_KEY = 'stackTrace';
	public static final String USER_INFO_KEY = 'userInfo';
	public static final String OBJECT_INFO_KEY = 'objectInfo';
	public static final String RELATED_OBJECTS_KEY = 'relatedObjects';
	public static final String FLOW_VERSION_ID_KEY = 'flowVersionId';
	public static final String DEPLOY_RESULT_KEY = 'deployResult';
	public static final String AUDIT_TRAIL_KEY = 'auditTrail';
	public static final String PENDING_JOBS_KEY = 'pendingJobs';
	public static final String TOTAL_ACTIVE_SESSION_KEY = 'totalActiveSession';
	public static final String INSTALLED_PACKAGES_KEY = 'installedPackages';
	public static final String ORG_LIMITS_KEY = 'orgLimits';

	public static final Map<String, String> SETTINGS_ABBREVIATION = new Map<String, String>{
			STACK_TRACE_KEY => 'ST',
			USER_INFO_KEY => 'UI',
			OBJECT_INFO_KEY => 'OI',
			RELATED_OBJECTS_KEY => 'RO',
			FLOW_VERSION_ID_KEY => 'FVI',
			DEPLOY_RESULT_KEY => 'DR',
			AUDIT_TRAIL_KEY => 'AT',
			PENDING_JOBS_KEY => 'PJ',
			TOTAL_ACTIVE_SESSION_KEY => 'TAS',
			INSTALLED_PACKAGES_KEY => 'IP',
			ORG_LIMITS_KEY => 'OL'
	};

	public class PostProcessingSettings {

		private Set<String> settings;
		
		public PostProcessingSettings(String logSettings) {
			this.settings = LogPostProcessingService.getSettings(logSettings);
		}

		public Boolean isEnabled(String key) {
			return this.settings == null || settings.contains(LogPostProcessingService.SETTINGS_ABBREVIATION.get(key));
		}
	}

	public static final String POST_PROCESSING_SETTINGS_STACKTRACE_ONLY = JSON.serialize(new List<String>{LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.STACK_TRACE_KEY)});
	public static final String POST_PROCESSING_SETTINGS_ALL_SETTINGS_EXCEPT_STACKTRACE = JSON.serialize(new List<String>{
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.USER_INFO_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.OBJECT_INFO_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.RELATED_OBJECTS_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.FLOW_VERSION_ID_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.DEPLOY_RESULT_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.AUDIT_TRAIL_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.PENDING_JOBS_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.TOTAL_ACTIVE_SESSION_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.INSTALLED_PACKAGES_KEY),
		LogPostProcessingService.SETTINGS_ABBREVIATION.get(LogPostProcessingService.ORG_LIMITS_KEY)
	});

	public static final Integer MAX_ENV_INFO_TIME_WINDOW_HRS = -48;
	public static final Integer MAX_DELAY_TIME_WINDOW_MNS = 5;

	public static LogPostProcessingResult result;
	public static Connected_Org__c corg;
	public static SObjectDescribeInfo sObjectDescribeInfo;
	public static Set<String> availableNamespaces;

	public static List<Object> runQuery(Connected_Org__c corg, String q) {
		return isThisOrg(corg) ? Database.query(q, AccessLevel.SYSTEM_MODE) : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), q);
	}

	public static List<Object> runQueryV62(Connected_Org__c corg, String q) {
		return runQuery(corg, q, 'v62.0');
	}

	public static List<Object> runQuery(Connected_Org__c corg, String q, String apiVersion) {
		return isThisOrg(corg) ? Database.query(q, AccessLevel.SYSTEM_MODE) : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), q, ConfigUtil.getQueryRestApiPath(apiVersion));
	}

	public class LogPostProcessingResult {
		
		public List<Exception> errors;
		public Set<Id> orchestratorLogIdsForBroadcast;
		public List<Log__c> logs;

		public LogPostProcessingResult() {
			this.errors = new List<Exception>();
			this.orchestratorLogIdsForBroadcast = new Set<Id>();
			this.logs = new List<Log__c>();
		}

		public void addLogs(List<Log__c> logs) {
			this.logs.addAll(logs);
		}

		public void addError(Exception e) {
			this.errors.add(e);
		}

		public void addOrchestartorLogIdForBroadcast(Id logId) {
			this.orchestratorLogIdsForBroadcast.add(logId);
		}
	}

	public static String FLOW_ORCHESTRATOR_STACKTRACE_TOKEN = 'orchestratorStackTrace';
	public static String appendOrchestratorParseResult(String existStacktraceParseResult, FlowDataStructures.Flow flowStackTrace) {
		String result = existStacktraceParseResult;
		try {
			Map<String, Object> mapStackTraceParseResult = (Map<String, Object>)JSON.deserializeUntyped(existStacktraceParseResult);
			mapStackTraceParseResult.put(FLOW_ORCHESTRATOR_STACKTRACE_TOKEN, flowStackTrace);
			result = JSON.serialize(mapStackTraceParseResult);
		} catch (JSONException e) {
			// catch JSON deserialize issue
			return null;
		}
		return result;
	}

	public class PostProcessingOrchestratorLogCounter extends PostProcessingCounter {
		public PostProcessingOrchestratorLogCounter(String corgName) {
			super(corgName, CacheUtils.KEY_POST_PROCESSING_ORCHESTRATOR_LOG_TRACKING);
		}
	}

	public class PostProcessingLogCounter extends PostProcessingCounter {
		public PostProcessingLogCounter(String corgName, String cacheKey) {
			super(corgName, CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING, cacheKey);
		}
	}

	public virtual class PostProcessingCounter {

		private Map<String, Integer> mapCounterByLogId;
		private CacheUtils cacheUtil;
		private String cacheKey;
		private Integer counter;
		private String cacheKeyPrefix;

		public PostProcessingCounter(String corgName, String cacheKeyPrefix, String cacheKey){
			this.cacheKey = cacheKey;
			this.cacheKeyPrefix = cacheKeyPrefix;
			this.mapCounterByLogId = new Map<String, Integer>();
			this.cacheUtil = new CacheUtils(corgName);
			Object counterObj = cacheUtil.getValue(cacheKeyPrefix, cacheKey);
			if (counterObj != null) {
				this.counter = (Integer) counterObj;
			}
		}

		public PostProcessingCounter(String corgName, String cacheKeyPrefix){
			this.cacheKey = cacheKeyPrefix;
			this.mapCounterByLogId = new Map<String, Integer>();
			this.cacheUtil = new CacheUtils(corgName);
			Object cacheObject = cacheUtil.getValue(cacheKeyPrefix);
			if (cacheObject != null) {
				this.mapCounterByLogId = (Map<String, Integer>)cacheObject;
			}
		}

		public PostProcessingCounter incrementCounter() {
			this.counter = this.counter == null ? 0 : this.counter + 1;
			this.cacheUtil.putValue(this.cacheKeyPrefix , this.cacheKey, this.counter);
			return this;
		}

		public PostProcessingCounter incrementCounter(String logId) {
			this.mapCounterByLogId.put(logId, getCounter(logId) + 1);
			this.cacheUtil.putValue(this.cacheKeyPrefix, this.mapCounterByLogId);
			return this;
		}

		public Integer getCounter(String logId) {
			return this.mapCounterByLogId.get(logId) != null ? this.mapCounterByLogId.get(logId) : 0;
		}

		public Integer getCounter() {
			return this.counter != null ? this.counter : 0;
		}
	}

	public static Map<String, String> mapStacktraceParseResult = new Map<String, String>();

	@TestVisible
	private static Boolean testThrowCircularException = false;

	public static List<Log__c> getLogsForPostProcessing(List<Log__c> logs) {
		List<Log__c> availableLogs = [
			SELECT
				Id,
				Created_At__c,
				Summary__c,
				Details__c,
				Deploy_Results__c,
				Setup_Audit_Trail__c,
				Pending_Jobs__c,
				Total_Pending_Jobs__c,
				Total_Active_Sessions__c,
				Installed_Packages__c,
				Organization_Id__c,
				Apex_Name__c,
				Namespace__c,
				User_Id__c,
				Related_Id__c,
				Related_Object_Type__c,
				Related_Objects__c,
				Stacktrace__c,
				Stacktrace_Parse_Result__c,
				Stack_trace_parse_result_available__c,
				Type__c,
				Category__c,
				Area__c,
				Flow_Version_Id__c,
				Flow_API_Name__c,
				Flow_Version__c,
				Post_Processing_Settings__c,
				Is_Parent__c,
				Parent__c,
				Interview_GUID_External__c,
				Created_Timestamp__c,
				Limits__c,
				Limits__r.ActiveScratchOrgs__c,
				Limits__r.AnalyticsExternalDataSizeMB__c,
				Limits__r.ConcurrentAsyncGetReportInstances__c,
				Limits__r.ConcurrentEinsteinDataInsightsStory__c,
				Limits__r.ConcurrentEinsteinDiscoveryStory__c,
				Limits__r.ConcurrentSyncReportRuns__c,
				Limits__r.CreateCustom__c,
				Limits__r.DailyAnalyticsDataflowJobExecutions__c,
				Limits__r.DailyAnalyticsUploadedFilesSizeMB__c,
				Limits__r.DailyFunctionsApiCallLimit__c,
				Limits__r.DailyApiRequests__c,
				Limits__r.DailyAsyncApexExecutions__c,
				Limits__r.DailyAsyncApexTests__c,
				Limits__r.DailyBulkApiBatches__c,
				Limits__r.DailyBulkV2QueryFileStorageMB__c,
				Limits__r.DailyBulkV2QueryJobs__c,
				Limits__r.DailyDeliveredPlatformEvents__c,
				Limits__r.DailyDurableGenericStreamingApiEvents__c,
				Limits__r.DailyDurableStreamingApiEvents__c,
				Limits__r.DailyEinsteinDataInsightsStoryCreation__c,
				Limits__r.DailyEinsteinDiscoveryOptJobRuns__c,
				Limits__r.DailyEinsteinDiscoveryPredictAPICalls__c,
				Limits__r.DailyEinsteinDiscoveryPredictionsByCDC__c,
				Limits__r.DailyEinsteinDiscoveryStoryCreation__c,
				Limits__r.DailyGenericStreamingApiEvents__c,
				Limits__r.DailyMetadataRetrievesWithDeps__c,
				Limits__r.DailyScratchOrgs__c,
				Limits__r.DailyStandardVolumePlatformEvents__c,
				Limits__r.DailyStreamingApiEvents__c,
				Limits__r.DailyWorkflowEmails__c,
				Limits__r.DataStorageMB__c,
				Limits__r.DurableStreamingApiConcurrentClients__c,
				Limits__r.FileStorageMB__c,
				Limits__r.HourlyAsyncReportRuns__c,
				Limits__r.HourlyDashboardRefreshes__c,
				Limits__r.HourlyDashboardResults__c,
				Limits__r.HourlyDashboardStatuses__c,
				Limits__r.HourlyLongTermIdMapping__c,
				Limits__r.HourlyManagedContentPublicRequests__c,
				Limits__r.HourlyODataCallout__c,
				Limits__r.HourlyPublishedPlatformEvents__c,
				Limits__r.HourlyPubStdVolPlatformEvents__c,
				Limits__r.HourlyShortTermIdMapping__c,
				Limits__r.HourlySyncReportRuns__c,
				Limits__r.HourlyTimeBasedWorkflow__c,
				Limits__r.MassEmail__c,
				Limits__r.MonthlyEinsteinDiscoveryStoryCreation__c,
				Limits__r.MonthlyPlatformEventsUsageEntitlement__c,
				Limits__r.Package2VersionCreates__c,
				Limits__r.Package2VersionCreatesWithoutValidation__c,
				Limits__r.PermissionSets__c,
				Limits__r.PlatformEventTriggersParallel__c,
				Limits__r.PrivateConnectOutboundCalloutMB__c,
				Limits__r.SingleEmail__c,
				Limits__r.StreamingApiConcurrentClients__c
			FROM Log__c
			WHERE Id IN :logs
		];
		return availableLogs;
	}

	public static List<LogPostProcessingResult> doLogPostProcessing(List<Log__c> logs, Logger logger) {
		return doLogPostProcessing(logs, logger, true);
	}

	public static List<LogPostProcessingResult> doLogPostProcessing(List<Log__c> logs, Logger logger, Boolean retrieveLogs) {
		List<LogPostProcessingResult> results = new List<LogPostProcessingResult>();
		List<Log__c> logsForUpdate = new List<Log__c>();

		List<Log__c> availableLogs = retrieveLogs ? getLogsForPostProcessing(logs) : logs;

		for(Log__c log : availableLogs) {
			result = new LogPostProcessingResult();

			Log__c orchestratorLog;

			try {
				corg = ConnectedOrgService.getConnectedOrgById(log.Organization_ID__c);
			} catch (Exception e) {
				result.addError(e);
				logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getConnectedOrgById');
			}
			try {
				sObjectDescribeInfo = getSobjectDescribeInfo(log.Related_Id__c);
			} catch (Exception e) {
				result.addError(e);
				logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getSobjectDescribeInfo');
			}
			if (corg != null) {
				LogPostProcessingService.PostProcessingSettings logSettings = new LogPostProcessingService.PostProcessingSettings(log.Post_Processing_Settings__c);
				if (logSettings.isEnabled(USER_INFO_KEY)) fillUserInfo(log, logger);
				if (logSettings.isEnabled(OBJECT_INFO_KEY)) fillArea(log, logger);
				if (logSettings.isEnabled(RELATED_OBJECTS_KEY)) fillRelateObjectType(log, logger);
				if (logSettings.isEnabled(RELATED_OBJECTS_KEY)) fillRelatedObjects(log, logger);
				if (logSettings.isEnabled(FLOW_VERSION_ID_KEY)) fillFlowVersionId(log, logger);
				if (logSettings.isEnabled(DEPLOY_RESULT_KEY)) fillDeployResult(log, logger);
				if (logSettings.isEnabled(AUDIT_TRAIL_KEY)) fillAuditTrail(log, logger);
				if (logSettings.isEnabled(PENDING_JOBS_KEY)) fillPendingJobs(log, logger);
				if (logSettings.isEnabled(PENDING_JOBS_KEY)) fillTotalPendingJobs(log, logger);
				if (logSettings.isEnabled(TOTAL_ACTIVE_SESSION_KEY)) fillTotalActiveSession(log, logger);
				if (logSettings.isEnabled(INSTALLED_PACKAGES_KEY)) fillInstalledPackages(log, logger);
				if (logSettings.isEnabled(STACK_TRACE_KEY)) fillStackTrace(log, orchestratorLog, logger);
				if (logSettings.isEnabled(ORG_LIMITS_KEY)) fillOrgLimitsEnhanced(log, logger);
				if (String.isBlank(log.Parent__c) && String.isNotBlank(log.Interview_GUID_External__c)) fillParent(log, logger);

				// TEST EXCEPTION SIMULATION - CIRCULAR DEPENDENCY ERROR
				// Purpose: Deliberately creates a circular parent reference to test error handling pathways
				// Mechanism: When testThrowCircularException flag is set to true, this sets log.Parent__c = log.Id
				// Effect: Triggers a CIRCULAR_DEPENDENCY DML exception during the DatabaseUtils.performUpdateDML() call
				// Error flow: 1) Exception occurs during DML update
				//             2) DatabaseUtils.handleError() catches and processes it
				//             3) Error is logged via logger?.addInternalError()
				// Actual error details: DML Exception [statusCode=CIRCULAR_DEPENDENCY, code=[xmlrpc=1252, 
				// statusCode=CIRCULAR_DEPENDENCY, exceptionCode=null, scope=PublicApi, http=400],
				// message=Hierarchy Constraint Violation, fields=[pharos__Parent__c]]
				// Note: This is only executed in test context and requires explicit flag activation
				if (Test.isRunningTest() && testThrowCircularException) {
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Parent__c, log.Id);
				}

				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Post_Processing_Status__c, LogPostProcessingService.POST_PROCESSING_STATUS_EXECUTED);

				if(retrieveLogs) {
					if(log.Stacktrace_Parse_Result__c?.length() > ErrorEmailHandler.MAX_LENGTH_LONG_TEXT_AREA_FIELD) {
						Integer index = mapStacktraceParseResult.size();
						mapStacktraceParseResult.put(String.valueOf(index), log.Stacktrace_Parse_Result__c);
						PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Stacktrace_Parse_Result__c, String.valueOf(index));
					}
				}

				// if namespace is blank and stacktrace parse result is not available, set namespace to unknown
				if(String.isBlank(log.Namespace__c) && !log.Stack_trace_parse_result_available__c) {
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Namespace__c, LogService.NAMESPACE_UNKNOWN);
				}

				logsForUpdate = new List<Log__c>{log};
				if (orchestratorLog != null) {
					logsForUpdate.add(orchestratorLog);
				}
				result.addLogs(logsForUpdate);
				results.add(result);
			}
		}

		if(retrieveLogs) {
			DatabaseUtils.getInstance().performUpdateDML(logsForUpdate, Schema.SObjectType.Log__c)
				.handleError(LogPostProcessingService.class.getName(), '.doLogPostProcessing', logger);

			for(Log__c logAfterUpdate : logsForUpdate) {
				if(String.isNotBlank(logAfterUpdate.Stacktrace_Parse_Result__c)
					&& logAfterUpdate.Stacktrace_Parse_Result__c?.isNumeric()
					&& mapStacktraceParseResult.containsKey(logAfterUpdate.Stacktrace_Parse_Result__c)) {
					
					mapStacktraceParseResult.put(logAfterUpdate.Id, mapStacktraceParseResult.get(logAfterUpdate.Stacktrace_Parse_Result__c));
					mapStacktraceParseResult.remove(logAfterUpdate.Stacktrace_Parse_Result__c);
				}
			}
			if(!mapStacktraceParseResult.isEmpty()) {
				ErrorEmailHandler.createStacktraceParseResultCV(mapStacktraceParseResult, logger);
			}
		}

		return results;
	}

	public static LogPostProcessingResult doLogPostProcessing(Log__c log, Logger logger) {
		return doLogPostProcessing(new List<Log__c>{log}, logger).get(0);
	}

	public static void fillOrgLimitsEnhanced(Log__c log, Logger logger) {
		try {
			List<Log__c> logs = new List<Log__c>{log};
			LimitsService.createLimitsForLogs(logs, false, true, logger);
			PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Limits__c, logs.get(0).Limits__c);
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.fillOrgLimitsEnhanced');
		}
		
	}
	public static final String ERROR_MESSAGE_FLOW_NOT_FOUND = 'WebService returned a SOAP Fault: type and fullNames must be specified for items to read';

	public static void fillStackTrace(Log__c log, Log__c orchestratorLogUpdate, Logger logger) {
		if (String.isBlank(log.Stacktrace__c)) {
			PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, null);
			PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, false);
			return;
		}
		try {
			StackTraceParser.corg = corg;
			if (log.Category__c == FlowExceptionParser.PROCESS_BUILDER_CATEGORY) {
				FlowService.ProcessBuilder stackTrace = FlowService.parseProcessBuilderStackTrace(log.Stacktrace__c);
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, JSON.serialize(stackTrace));
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(log.Stacktrace_Parse_Result__c));
			}
			else if (log.Category__c == FlowExceptionParser.FLOW_CATEGORY) {
				
				FlowDataStructures.Flow stackTrace = null;
				try {
					stackTrace = FlowService.parseFlowStackTrace(log.Stacktrace__c);
				}
				catch (Exception e) {
					// if flow not found or not available, set stacktrace parse result to null
					if (e.getMessage().contains(ERROR_MESSAGE_FLOW_NOT_FOUND)) {
						PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, null);
						PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, false);
						return;
					}
					// if other error, throw it
					throw e;
				}

				if (log.Type__c == Constants.FLOW.FLOW_TYPE_ORCHESTRATOR) {
					// if orchestrator flow has related autolanched flow error log
					if (String.isNotBlank(stackTrace.orchestratorFailedFlowApiName)) {
						List<Log__c> relatedFlowLog = [
								SELECT Id, Stacktrace_Parse_Result__c
								FROM Log__c
								WHERE Flow_API_Name__c = :stackTrace.orchestratorFailedFlowApiName
								AND Type__c = :Constants.FLOW.FLOW_TYPE_AUTOLAUNCHED_FLOW
								AND User_Id__c = :log.User_Id__c
								AND CreatedDate >= :Datetime.now().addMinutes(-10)
								ORDER BY CreatedDate DESC
								LIMIT 1
						];
						// related flow postprocessing not completed yet
						if (!relatedFlowLog.isEmpty() && relatedFlowLog.get(0)?.Stacktrace_Parse_Result__c?.startsWith(ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE)) {
							relatedFlowLog.clear();
						}
						// if related flow postprocessing completed, add orchestrator stacktrace to related flow stacktrace
						if (!relatedFlowLog.isEmpty()) {
							try {
								orchestratorLogUpdate = (Log__c) PermissionsUtil.newSObject(Schema.SObjectType.Log__c);
								PermissionsUtil.putSObjectField(orchestratorLogUpdate, Schema.SObjectType.Log__c.fields.Id, relatedFlowLog.get(0).Id);
								PermissionsUtil.putSObjectField(orchestratorLogUpdate, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, appendOrchestratorParseResult(relatedFlowLog.get(0).Stacktrace_Parse_Result__c, stackTrace));
								PermissionsUtil.putSObjectField(orchestratorLogUpdate, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(relatedFlowLog.get(0).Stacktrace_Parse_Result__c));
								result.addOrchestartorLogIdForBroadcast(relatedFlowLog.get(0).Id);
								PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.External_Id__c, log.Id);
							} catch (Exception e){
								result.addError(e);
								logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.orchestratorStackTrace');
							}
						}
						// else increment counter and rerun for this log
						else {
							PostProcessingOrchestratorLogCounter orchestratorCounter = new PostProcessingOrchestratorLogCounter(corg.Name);
							orchestratorCounter.incrementCounter(log.Id);
						}
					}
				}

				// if stacktrace dosen't have any elements, set stacktrace parse result to null and stack_trace_parse_result_available__c to false
				// this happens for Flows that are not available or not found
				if (stackTrace == null || stackTrace?.elements?.isEmpty() || stackTrace?.edges?.isEmpty()) {
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, null);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, false);
				}
				else {
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, JSON.serialize(stackTrace));
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(log.Stacktrace_Parse_Result__c));
				}
			}
			else if (log.Category__c == CATEGORY_INTEGRATION) {
				List<StackTraceParser.StackTraceParseResult> stackTrace = StackTraceParser.parseStackTrace(log.Stacktrace__c);
				try {
					Map<String, Object> mapStackTraceParseResult = new Map<String, Object>();
					if(String.isNotBlank(log?.Stacktrace_Parse_Result__c)) {
						mapStackTraceParseResult = (Map<String, Object>)JSON.deserializeUntyped(log.Stacktrace_Parse_Result__c);
					}

					mapStackTraceParseResult.put('stackTrace', stackTrace);
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, JSON.serialize(mapStackTraceParseResult));
					PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(log?.Stacktrace_Parse_Result__c) && !stackTrace.isEmpty());
				} catch (JSONException e) {
					// catch JSON deserialize issue
				}
			}
			else if (log.Category__c == BulkAPIJobBatchService.BULK_API) {
				List<StackTraceParser.StackTraceParseResult> stackTrace = StackTraceParser.parseStackTrace(log.Stacktrace__c);
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, JSON.serialize(stackTrace));
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(log.Stacktrace_Parse_Result__c));
			}
			else {
				List<StackTraceParser.StackTraceParseResult> stackTrace = StackTraceParser.parseStackTrace(log.Stacktrace__c);
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, JSON.serialize(stackTrace));
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, String.isNotBlank(log.Stacktrace_Parse_Result__c) && !stackTrace.isEmpty());
			}
		} catch (Exception e) {
			PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, ERROR_SYSTEM_INFO_LOG_RETRIEVE);
			PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, false);
			result.addError(e);
			// do not log handled error
			if (!e?.getMessage()?.containsIgnoreCase(LogService.FLOW_HANDLED_ERROR_MESSAGE)) {
				logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.parseStackTrace');
			}
		}
		finally {
			if (log.Stacktrace_Parse_Result__c == LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE) {
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stacktrace_Parse_Result__c, null);
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Stack_trace_parse_result_available__c, false);
			}
		}
	}

	public static void fillUserInfo(Log__c log, Logger logger) {
		try {
			UserInfoWrapper userInfoWrapper = getUserInfo(log.User_Id__c);
			if (userInfoWrapper != null) {
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.User_Name__c, userInfoWrapper.userFullName);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Profile_Id__c, userInfoWrapper.profileId);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Profile_Name__c, userInfoWrapper.profileName);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Role_Id__c, userInfoWrapper.roleId);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Role_Name__c, userInfoWrapper.roleName);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Salesforce_License_Type_Name__c, userInfoWrapper.licenseTypeName);
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getUserInfo');
		}
	}

	public static void fillArea(Log__c log, Logger logger) {
		try {
			if (needsOverrideForDefaultArea(log.Area__c) && sObjectDescribeInfo != null && sObjectDescribeInfo.labelPlural != null){
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Area__c, sObjectDescribeInfo.labelPlural);
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getAreaSobjectLabelPlural');
		}
	}

	public static void fillRelateObjectType(Log__c log, Logger logger) {
		try {
			if (sObjectDescribeInfo != null && sObjectDescribeInfo.label != null) {
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Object_Type__c, sObjectDescribeInfo.label);
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getLabelSobjectDescribeInfo');
		}
	}

	public static void fillRelatedObjects(Log__c log, Logger logger) {
		try {
			Set<String> relatedIds = getRelatedIds(log.Related_Objects__c + ' ' + log.Summary__c + ' ' + log.Details__c);
			Map<String, String> mapRelates = getRelatedObjectsDescribeInfo(relatedIds, log.User_Id__c);
			if (mapRelates != null) {
				if (mapRelates.containsKey(RELATES_KEY_RELATED_ID)) PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Id__c, mapRelates.get(RELATES_KEY_RELATED_ID));
				if (mapRelates.containsKey(RELATES_KEY_RELATED_OBJECTS)) PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Objects__c, mapRelates.get(RELATES_KEY_RELATED_OBJECTS));
				if (mapRelates.containsKey(RELATES_KEY_RELATED_OBJECT_TYPE)) {
					PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Related_Object_Type__c, mapRelates.get(RELATES_KEY_RELATED_OBJECT_TYPE));
					if (needsOverrideForDefaultArea(log.Area__c)) PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Area__c, mapRelates.get(RELATES_KEY_RELATED_OBJECT_TYPE));
				}
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getRelatedObjectsDescribeInfo');
		}
	}

	public static void fillFlowVersionId(Log__c log, Logger logger) {
		try {
			if (String.isNotBlank(log.Flow_API_Name__c) && String.isNotBlank(log.Flow_Version__c)) {
				FlowDescribeInfo flowDescribeInfo = getFlowDescribeInfo(log.Flow_API_Name__c, log.Flow_Version__c);
				if (flowDescribeInfo != null && flowDescribeInfo.versionId != null) {
					PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Flow_Version_Id__c, flowDescribeInfo.versionId);
				}
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getFlowDescribeInfo');
		}
	}

	public static void fillDeployResult(Log__c log, Logger logger) {
		try {
			LogPostProcessingService.PostProcessingSettings logSettings = new LogPostProcessingService.PostProcessingSettings(log.Post_Processing_Settings__c);
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Deploy_results_available__c, logSettings.isEnabled(DEPLOY_RESULT_KEY));

			List<DeployResult> deployments = (List<DeployResult>)truncateItems(MAX_TEXT_AREA_110k_SIZE, getDeployResults());
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Deploy_Results__c, JSON.serialize(deployments));
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Deploy_results_available__c, (deployments != null && !deployments.isEmpty()));
		}
		catch (Exception e) {}
	}

	public static void fillAuditTrail(Log__c log, Logger logger) {
		try {
			LogPostProcessingService.PostProcessingSettings logSettings = new LogPostProcessingService.PostProcessingSettings(log.Post_Processing_Settings__c);
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Audit_Trail_available__c, logSettings.isEnabled(AUDIT_TRAIL_KEY));

			String setupAuditTrails = getSetupAuditTrailInfo(log.Created_At__c);
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c, setupAuditTrails);
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Audit_Trail_available__c, String.isNotBlank(setupAuditTrails));
		}
		catch (Exception e) {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c, ERROR_SYSTEM_INFO_AUDIT_TRAIL_NOT_SUPPORTED);
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Audit_Trail_available__c, false);
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getSetupAuditTrailInfo');
		}
		finally {
			if (log.Setup_Audit_Trail__c == LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE) {
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Setup_Audit_Trail__c, null);
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Audit_Trail_available__c, false);
			}
		}
	}

	public static void fillPendingJobs(Log__c log, Logger logger) {
		try {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Pending_Jobs__c, getPendingJobsInfo());
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getPendingJobsInfo');
		}
		finally {
			if(log.Pending_Jobs__c == LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE) {
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Pending_Jobs__c, null);
			}
		}
	}

	public static void fillTotalPendingJobs(Log__c log, Logger logger) {
		try {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Total_Pending_Jobs__c, log.Pending_Jobs__c.split('\n').size());
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.totalPendingJobs');
		}
	}

	public static void fillTotalActiveSession(Log__c log, Logger logger) {
		try {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Total_Active_Sessions__c, getTotalActiveSessions());
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getTotalActiveSessions');
		}
	}

	public static void fillInstalledPackages(Log__c log, Logger logger) {
		try {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Installed_Packages__c, getInstalledPackages());
			if (String.isNotBlank(log.Apex_Name__c)) {
				List<String> classNameParts = log.Apex_Name__c.split('\\.');
				if (!classNameParts.isEmpty() && !availableNamespaces.isEmpty() && availableNamespaces.contains(classNameParts[0])) {
					PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Namespace__c, classNameParts[0]);
				}
			}
		}
		catch (Exception e) {
			PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Installed_Packages__c, ERROR_SYSTEM_INFO_LOG_RETRIEVE);
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.getInstalledPackages');
		}
		finally {
			if(log.Installed_Packages__c == LogPostProcessingService.ERROR_SYSTEM_INFO_LOG_NOT_AVAILABLE) {
				PermissionsUtil.putSObjectField(log, Schema.sObjectType.Log__c.fields.Installed_Packages__c, null);
			}
		}
	}
	public static void fillParent(Log__c log, Logger logger) {
		try {
			List<Log__c> logs = [SELECT Id, Parent__c FROM Log__c WHERE Parent__c != :log?.Id AND Interview_GUID_External__c = :log.Interview_GUID_External__c LIMIT 1];
			if (!logs.isEmpty()) {
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Is_Parent__c, false);
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Parent__c, logs[0].Parent__c);
			}
		}
		catch (Exception e) {
			result.addError(e);
			logger?.addInternalError(e, log.Id, LogPostProcessingService.class.getName(), '.fillParent');
		}
	}

	public static SObjectDescribeInfo getSobjectDescribeInfo(String relatedId) {
		SObjectDescribeInfo sObjectDescribeInfo;
		if (String.isBlank(relatedId)) return sObjectDescribeInfo;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_SOBJECT_DESCRIBE);
		Map<String, SObjectDescribeInfo> mapSObjectDescribeInfo = cacheObject != null ? (Map<String, SObjectDescribeInfo>)cacheObject : new Map<String, SObjectDescribeInfo>();
		String keyPrefix = relatedId.left(3);
		if (mapSObjectDescribeInfo.containsKey(keyPrefix)) {
			sObjectDescribeInfo = mapSObjectDescribeInfo.get(keyPrefix);
		} else {
			sObjectDescribeInfo = getSobjectDescribeInfoFromOrg(corg, relatedId);
			mapSObjectDescribeInfo.put(keyPrefix, sObjectDescribeInfo);
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_SOBJECT_DESCRIBE, mapSObjectDescribeInfo);
		}
		return sObjectDescribeInfo;
	}

	public static SObjectDescribeInfo getSobjectDescribeInfoFromOrg(Connected_Org__c corg, String relatedId) {
		SObjectDescribeInfo sObjectDescribeInfo;
		if (isThisOrg(corg)) {
			Schema.DescribeSObjectResult describeSObjectResult;
			try {
				describeSObjectResult =  Id.valueOf(relatedId).getSObjectType().getDescribe();
			} catch (Exception e) {
				// catch Invalid Id
			}
			if (describeSObjectResult != null) {
				sObjectDescribeInfo = new SObjectDescribeInfo(describeSObjectResult.getLabel(), describeSObjectResult.getLabelPlural());
			}
		} else {
			String keyPrefix = relatedId.substring(0, 3);
			ExternalSObjectsDescribeInfoWrapper wrapper = HttpUtils.runToolingQuerySObjects(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg));

			for (SObjectDescribeInfo sobjectItem : wrapper?.sobjects) {
				if (sobjectItem?.keyPrefix == keyPrefix) {
					sObjectDescribeInfo = sobjectItem;
				}
			}
		}
		return sObjectDescribeInfo;
	}

	public class ExternalSObjectsDescribeInfoWrapper {
		public List<SObjectDescribeInfo> sobjects;
	}

	public static UserInfoWrapper getUserInfo(String userId) {
		UserInfoWrapper userInfoWrapper;
		if (String.isBlank(userId)) return userInfoWrapper;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_USER_INFO);
		Map<String, UserInfoWrapper> userInfoByUserId = cacheObject != null ? (Map<String, UserInfoWrapper>)cacheObject : new Map<String, UserInfoWrapper>();
		if (userInfoByUserId.containsKey(userId)) {
			userInfoWrapper = userInfoByUserId.get(userId);
		} else {
			List<User> users = getUserNameFromOrg(corg, userId);
			if (users != null && users.size() == 1) {
				userInfoWrapper = new UserInfoWrapper(users.get(0));
				userInfoByUserId.put(userId, userInfoWrapper);
				cacheUtil.putValue(CacheUtils.KEY_REQUEST_USER_INFO, userInfoByUserId);
			}
		}

		return userInfoWrapper;
	}

	public static List<User> getUserNameFromOrg(Connected_Org__c corg, String userId) {
		String query = new QBuilder(User.SObjectType)
				.selectFields(USER_FIELDS)
				.add(QBuilder.condition('Id').equalsTo(userId))
				.addLimit(1)
				.build();
		return (List<User>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<User>.class);
	}

	public static Map<String, String> getRelatedObjectsDescribeInfo(Set<String> relatedIds, String userId) {
		if (relatedIds?.isEmpty()) return null;
		Map<String, SObjectDescribeInfo> mapSObjectDescribeInfo = getSObjectDescribeInfo();
		if (mapSObjectDescribeInfo?.isEmpty()) return null;
		Map<String, String> mapRelates = new Map<String, String>();
		Map<String, List<String>> mapRelatedObjects = new Map<String, List<String>>();
		for (String relatedId : relatedIds) {
			if (mapSObjectDescribeInfo.containsKey(relatedId.left(3))) {
				SObjectDescribeInfo sObjectDescribeInfo = mapSObjectDescribeInfo.get(relatedId.left(3));
				if (ConfigUtil.UNAFFECTED_OBJECTS.contains(sObjectDescribeInfo.name) || (String.isNotBlank(userId) && relatedId.left(15) == userId.left(15))) continue;
				String key = buildSimpleKey(sObjectDescribeInfo.label, sObjectDescribeInfo.name);
				if (mapRelatedObjects.containsKey(key)) {
					mapRelatedObjects.get(key).add(relatedId.left(15));
				}
				else {
					mapRelatedObjects.put(key, new List<String>{relatedId.left(15)});
					if (!mapRelates.containsKey(RELATES_KEY_RELATED_ID)) {
						mapRelates.put(RELATES_KEY_RELATED_ID, relatedId);
						mapRelates.put(RELATES_KEY_RELATED_OBJECT_TYPE, sObjectDescribeInfo.label);
					}
				}
			}
		}
		if (!mapRelatedObjects.isEmpty()) mapRelates.put(RELATES_KEY_RELATED_OBJECTS, JSON.serialize(mapRelatedObjects));
		return mapRelates;
	}

	public static Map<String, SObjectDescribeInfo> getSObjectDescribeInfo() {
		Map<String, SObjectDescribeInfo> mapSObjectDescribeInfo;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		String keyType = buildSimpleKey(CacheUtils.KEY_REQUEST_RELATED_SOBJECT, corg.Name);
		Object cacheObject = cacheUtil.getValue(keyType);
		if (cacheObject != null) {
			mapSObjectDescribeInfo = (Map<String, SObjectDescribeInfo>)cacheObject;
		} else {
			ExternalSObjectsDescribeInfoWrapper wrapper = HttpUtils.runToolingQuerySObjects(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg));
			if (!wrapper?.sobjects.isEmpty()) {
				mapSObjectDescribeInfo = new Map<String, SObjectDescribeInfo>();
				for (SObjectDescribeInfo sObjectDescribeInfo : wrapper?.sobjects) {
					if (String.isNotBlank(sObjectDescribeInfo.keyPrefix)) mapSObjectDescribeInfo.put(sObjectDescribeInfo.keyPrefix, sObjectDescribeInfo);
				}
			}
			if (mapSObjectDescribeInfo != null) cacheUtil.putValue(keyType, mapSObjectDescribeInfo);
		}
		return mapSObjectDescribeInfo;
	}

	public static Set<String> getRelatedIds(String errorMessage) {
		Set<String> relatedIds = new Set<String>();
		Pattern p = Constants.GLOBAL_VARIABLE.PATTERN_SOBJECT_ID;
		Matcher pm = p.matcher(errorMessage);
		while (pm.find()) {
			try {
				String recordId = Id.valueOf(pm.group(1));
				relatedIds.add(recordId);
			} catch (Exception e) {}
		}
		return relatedIds;
	}

	public static FlowDescribeInfo getFlowDescribeInfo(String flowApiName, String flowVersion) {
		FlowDescribeInfo flowDescribeInfo;
		if (String.isBlank(flowApiName) || String.isBlank(flowVersion)) return flowDescribeInfo;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_FLOW_DESCRIBE);
		Map<String, FlowDescribeInfo> mapFlowDescribeInfo = cacheObject != null ? (Map<String, FlowDescribeInfo>)cacheObject : new Map<String, FlowDescribeInfo>();
		String key = flowApiName + ':' + flowVersion;
		if (mapFlowDescribeInfo.containsKey(key)) {
			flowDescribeInfo = mapFlowDescribeInfo.get(key);
		} else {
			flowDescribeInfo = getFlowDescribeInfoFromOrg(corg, flowApiName, flowVersion);
			mapFlowDescribeInfo.put(key, flowDescribeInfo);
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_FLOW_DESCRIBE, mapFlowDescribeInfo);
		}
		return flowDescribeInfo;
	}

	public static FlowDescribeInfo getFlowDescribeInfoFromOrg(Connected_Org__c corg, String flowApiName, String flowVersion) {
		FlowDescribeInfo flowDescribeInfo;
		Integer flowVersionNumber = Integer.valueOf(flowVersion);
		String flowDefinitionId = getFlowDefinitionIdByFlowApiName(flowApiName);

		String query = new QBuilder('Flow')
			.selectFields(new Set<String>{'Id', 'DefinitionId'})
			.add(QBuilder.condition('DefinitionId').equalsTo(flowDefinitionId))
			.add(QBuilder.condition('VersionNumber').equalsTo(flowVersionNumber))
			.addLimit(1)
			.build();

		for (Object sobjectItem : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT)) {
			Map<String, Object> sobjectMap = (Map<String, Object>)sobjectItem;
			flowDescribeInfo = new FlowDescribeInfo((String)sobjectMap.get('Id'), (String)sobjectMap.get('DefinitionId'));
		}
		return flowDescribeInfo;
	}

	public static String getFlowDefinitionIdByFlowApiName(String flowApiName) {
		String result = '';
		List<String> parts = flowApiName?.split('__');
		String flowFullName = (parts.size() == 2) ? parts.get(1) : parts.get(0);
		String flowNamespace = (parts.size() == 2) ? parts.get(0) : null;

		String query = new QBuilder('FlowDefinition')
			.selectFields(new Set<String>{'Id'})
			.add(QBuilder.condition('DeveloperName').equalsTo(flowFullName))
			.add(flowNamespace != null ? QBuilder.condition('NamespacePrefix').equalsTo(flowNamespace) : null)
			.addLimit(1)
			.build();
		for (Object sobjectItem : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT)) {
			Map<String, Object> sobjectMap = (Map<String, Object>)sobjectItem;
			result = (String)sobjectMap.get('Id');
		}
		return result;
	}

	public static List<DeployResult> getDeployResults() {
		List<DeployResult> result = null;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS);
		if (cacheObject != null) {
			result = (List<DeployResult>)cacheObject;
		} else {
			result = getDeployResultsFromOrg();
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_DEPLOYMENT_JOBS, result);
		}
		return result;
	}

	public static List<DeployResult> getDeployResultsFromOrg() {
		String query = new QBuilder('deployRequest')
				.selectFields(DEPLOY_RESULT_FIELDS)
				.add(QBuilder.condition('Status').isIn(new List<String>{'Succeeded', 'SucceededPartial'}))
				.addLimit(10)
				.add(new QOrder('CompletedDate').descending())
				.build();
		List<DeployResult> lstDeployResults = new List<DeployResult>();
		for (Object recordSObject : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT)) {
			DeployResult record = (DeployResult)JSON.deserialize(JSON.serialize(recordSObject), DeployResult.class);
			DeployResult deployResult = new DeployResult();
			deployResult.id = record.id;
			deployResult.status = String.valueOf(record.status);
			deployResult.completedDate = record.completedDate;
			lstDeployResults.add(deployResult);
		}
		return lstDeployResults;
	}

	private static final String EMPTY_AUDIT_TRAIL = '[]';

	public static String getSetupAuditTrailInfo(Datetime createdAt) {
		String result;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_AUDIT_TRAIL);
		if (cacheObject != null) {
			List<SetupAuditTrail> setupAuditTrails = (List<SetupAuditTrail>)JSON.deserialize((String)cacheObject, List<SetupAuditTrail>.class);
			if (!setupAuditTrails.isEmpty() && (createdAt.getTime() - setupAuditTrails[0].CreatedDate.getTime()) / (1000 * 60) < MAX_DELAY_TIME_WINDOW_MNS) {
				result = (String)cacheObject;
			}
		}
		if (result == null) {
			result = getAuditTrailFromOrg(corg, createdAt);
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_AUDIT_TRAIL, result);
		}
		return result != EMPTY_AUDIT_TRAIL ? result : null;
	}

	public static String getAuditTrailFromOrg(Connected_Org__c corg, Datetime createdAt) {
		String query = new QBuilder(AUDIT_TRAIL_SOBJECT)
				.selectFields(AUDIT_TRAIL_FIELDS)
				.add(QBuilder.condition('CreatedDate').isLessOrEquals(createdAt))
				.add(QBuilder.condition('CreatedDate').isGreaterThan(createdAt.addHours(MAX_ENV_INFO_TIME_WINDOW_HRS)))
				.add(QBuilder.orderBy('CreatedDate').descending())
				.addLimit(100)
				.build();
		List<Object> items = runQuery(corg, query);
		return JSON.serialize(truncateItems(MAX_TEXT_AREA_110k_SIZE, items));
	}

	public static String getPendingJobsInfo() {
		List<AsyncApexJob> asyncJobs;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_ASYNC_JOBS);
		if (cacheObject != null) {
			asyncJobs = (List<AsyncApexJob>)cacheObject;
		} else {
			asyncJobs = getPendingJobsInfoFromOrg(corg);
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_ASYNC_JOBS, asyncJobs);
		}
		List<String> pendingJobsList = new List<String>();
		if (asyncJobs != null) {
			for (AsyncApexJob job : asyncJobs) {
				String apexName = (job.MethodName != null) ? job.MethodName : (job.ApexClass != null && job.ApexClass.Name != null ? job.ApexClass.Name : '');
				String jobItem = job.JobType + ' - ' + job.Status + (String.isNotBlank(apexName) ? (' - ' + apexName) : '');
				if (String.join(pendingJobsList, '\n').length() + jobItem.length() < MAX_TEXT_AREA_28k_SIZE){
					pendingJobsList.add(jobItem);
				} else {
					pendingJobsList.add('...');
					pendingJobsList.add('Total: ' + asyncJobs.size());
					break;
				}
			}
		}
		return String.join(pendingJobsList, '\n');
	}

	public static List<AsyncApexJob> getPendingJobsInfoFromOrg(Connected_Org__c corg) {
		String query = new QBuilder(AsyncApexJob.SObjectType)
				.selectFields(ASYNC_JOB_FIELDS)
				.add(QBuilder.condition('Status').isIn(new String[] {'Processing','Preparing','Queued'}))
				.add(QBuilder.condition('JobType').notEqualsTo('BatchApexWorker'))
				.addLimit(1000)
				.build();
		return (List<AsyncApexJob>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<AsyncApexJob>.class);
	}

	public static Decimal getTotalActiveSessions() {
		Decimal result = null;
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_AUTH_SESSIONS);
		if (cacheObject != null) {
			result = (Decimal)cacheObject;
		}
		else {
			result = getTotalActiveSessionsFromOrg(corg);
			if (result != null) {
				cacheUtil.putValue(CacheUtils.KEY_REQUEST_AUTH_SESSIONS, result);
			}
		}
		return result;
	}

	@TestVisible
	private static final DateTime testLast1hour = DateTime.now().addHours(-1);

	public static Decimal getTotalActiveSessionsFromOrg(Connected_Org__c corg) {
		DateTime last1hour = (Test.isRunningTest()) ? testLast1hour : DateTime.now().addHours(-1);
		String query = new QBuilder(AuthSession.SObjectType)
				.selectFields(new Set<String> {'COUNT_DISTINCT(LoginHistory.UserId) number'})
				.add(QBuilder.condition('CreatedDate').isGreaterThan(last1hour))
				.build();
		List<Object> results = runQuery(corg, query);
		if (results != null && results.size() == 1) {
			if (isThisOrg(corg)) {
				AggregateResult result = (AggregateResult)results[0];
				return (Decimal)result.get('number');
			} else {
				Map<String, Object> resultMap = (Map<String, Object>)results[0];
				return (Decimal)resultMap.get('number');
			}
		}
		return null;
	}

	public static String getInstalledPackages() {
		List<Publisher> publishers;
		availableNamespaces = new Set<String>();
		CacheUtils cacheUtil = new CacheUtils(corg.Name);
		Object cacheObject = cacheUtil.getValue(CacheUtils.KEY_REQUEST_PACKAGES_INFO);
		if (cacheObject != null) {
			publishers = (List<Publisher>)cacheObject;
		} else {
			publishers = getInstalledPackagesFromOrg(corg);
			cacheUtil.putValue(CacheUtils.KEY_REQUEST_PACKAGES_INFO, publishers);
		}
		List<String> lines = new List<String>();
		if(publishers != null) {
			for (Publisher p : publishers) {
				String pNamespacePrefix = p.NamespacePrefix != null ? p.NamespacePrefix : 'unmanaged package';
				lines.add(pNamespacePrefix + ' (' + p.MajorVersion + '.' + p.MinorVersion + ')');
				availableNamespaces.add(p.NamespacePrefix);
			}
		}
		return String.join(lines, '\n');
	}

	public static List<Publisher> getInstalledPackagesFromOrg(Connected_Org__c corg) {
		String query = new QBuilder(Publisher.SObjectType)
				.selectFields(PUBLISHER_FIELDS)
				.add(QBuilder.condition('IsSalesforce').equalsTo(false))
				.build();
		return (List<Publisher>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<Publisher>.class);
	}

	public static String buildSimpleKey(String val1, String val2) {
		return String.format(ConfigUtil.SIMPLE_KEY_WITH_COLON_SEPARATOR, new List<Object>{val1, val2});
	}

	public static Boolean isThisOrg(Connected_Org__c corg) {
		return UserInfo.getOrganizationId() == Id.valueOf(corg.Name);
	}

	public static Set<String> getSettings(String postProcessingSettings) {
		Set<String> settings;
		if (String.isNotBlank(postProcessingSettings)) {
			try {
				settings = (Set<String>)JSON.deserialize(postProcessingSettings, Set<String>.class);
			} catch (JSONException e) {
				// catch JSON deserialize issue
			}
		}
		return settings;
	}

	// 90% of LTA 132k Max Size
	public static final Integer MAX_TEXT_AREA_110k_SIZE = 110000;
	// 90% of LTA 32k Max Size
	public static final Integer MAX_TEXT_AREA_28k_SIZE = 28000;
	
	public static List<Object> truncateItems(Integer maxSize, List<Object> items) {
		List<Object> result = new List<Object>();
		Integer totalsize = result.toString().length();
		if(items != null) {
			for(Object o : items) {
				// "item":"value", 4'"' + 1','
				Integer itemSize = o.toString().length() + 5;
				if((totalsize + itemSize) < maxSize){
					result.add(o);
					totalsize += itemSize;
				}
				else break;
			}
		}
		return result;
	}

	public static List<DeployResult> truncateItems(Integer maxSize, List<DeployResult> items) {
		List<DeployResult> result = new List<DeployResult>();
		Integer totalsize = result.toString().length();
		if(items != null) {
			for(DeployResult o : items) {
				Integer itemSize = o.toString().length() + 5;
				if((totalsize + itemSize) < maxSize){
					result.add(o);
					totalsize += itemSize;
				}
				else break;
			}
		}
		return result;
	}

	public static Boolean needsOverrideForDefaultArea(String area) {
		return String.isBlank(area) || ConfigUtil.DEFAULT_AREAS.contains(area);
	}

	public class DeployRequestResponse {
		public List<Metadata.DeployResult> records;
	}

	public class DeployResult {
		public String id;
		public String status;
		public Integer numberComponentsTotal;
		public Integer numberComponentsDeployed;
		public Integer numberComponentErrors;
		public Datetime startDate;
		public Boolean runTestsEnabled;
		public String createdBy;
		public String createdByName;
		public Datetime completedDate;
	}

	public class SObjectDescribeInfo {
		public String name;
		public String keyPrefix;
		public String label;
		public String labelPlural;

		public SObjectDescribeInfo(String label, String labelPlural) {
			this.label = label;
			this.labelPlural = labelPlural;
		}
	}

	public class FlowDescribeInfo {
		public String versionId;
		public String definitionId;

		public FlowDescribeInfo(String versionId, String definitionId) {
			this.versionId = versionId;
			this.definitionId = definitionId;
		}
	}

	public class AsyncApexJobWrapper {
		public String JobType;
		public String Status;
		public ApexClassWrapper ApexClass;
	}

	public class ApexClassWrapper {
		public String Name;
	}

	private class UserInfoWrapper {
		private String userId;
		private String userFullName;
		private String profileId;
		private String profileName;
		private String roleId;
		private String roleName;
		private String licenseTypeName;

		private UserInfoWrapper(User user) {
			this.userId = user.Id;
			this.userFullName = user.Name;
			this.profileId = user.ProfileId;
			this.profileName = user.Profile.Name;
			this.roleId = user.UserRoleId;
			this.roleName = user.UserRole.Name;
			this.licenseTypeName = user.Profile.UserLicense.Name;
		}
	}

	public class LogPostProcessingServiceException extends Exception {}

}