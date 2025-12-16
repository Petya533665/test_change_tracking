public with sharing class LimitsService {

	private static final String DAILY_ASYNC_APEX_EXECUTIONS_LIMIT = 'DailyAsyncApexExecutions';
	private static final String SINGLE_EMAIL_LIMIT = 'SingleEmail';

	private static final String LIMIT_KEY_REMAINING = 'Remaining';
	private static final String LIMIT_KEY_MAX = 'Max';
	private static final String LIMIT_KEY_USED = 'Used';

	// Create mapping between Limits__c fields and OrgLimits keys
	public static final Map<String, Schema.DescribeFieldResult> FIELD_MAP = new Map<String, Schema.DescribeFieldResult>{
		'ActiveScratchOrgs' => Limits__c.ActiveScratchOrgs__c.getDescribe(),
		'AnalyticsExternalDataSizeMB' => Limits__c.AnalyticsExternalDataSizeMB__c.getDescribe(),
		'ConcurrentAsyncGetReportInstances' => Limits__c.ConcurrentAsyncGetReportInstances__c.getDescribe(),
		'ConcurrentEinsteinDataInsightsStoryCreation' => Limits__c.ConcurrentEinsteinDataInsightsStory__c.getDescribe(),
		'ConcurrentEinsteinDiscoveryStoryCreation' => Limits__c.ConcurrentEinsteinDiscoveryStory__c.getDescribe(),
		'ConcurrentSyncReportRuns' => Limits__c.ConcurrentSyncReportRuns__c.getDescribe(),
		'CreateCustom' => Limits__c.CreateCustom__c.getDescribe(),
		'DailyAnalyticsDataflowJobExecutions' => Limits__c.DailyAnalyticsDataflowJobExecutions__c.getDescribe(),
		'DailyAnalyticsUploadedFilesSizeMB' => Limits__c.DailyAnalyticsUploadedFilesSizeMB__c.getDescribe(),
		'DailyFunctionsApiCallLimit' => Limits__c.DailyFunctionsApiCallLimit__c.getDescribe(),
		'DailyApiRequests' => Limits__c.DailyApiRequests__c.getDescribe(),
		'DailyAsyncApexExecutions' => Limits__c.DailyAsyncApexExecutions__c.getDescribe(),
		'DailyAsyncApexTests' => Limits__c.DailyAsyncApexTests__c.getDescribe(),
		'DailyBulkApiBatches' => Limits__c.DailyBulkApiBatches__c.getDescribe(),
		'DailyBulkV2QueryFileStorageMB' => Limits__c.DailyBulkV2QueryFileStorageMB__c.getDescribe(),
		'DailyBulkV2QueryJobs' => Limits__c.DailyBulkV2QueryJobs__c.getDescribe(),
		'DailyDeliveredPlatformEvents' => Limits__c.DailyDeliveredPlatformEvents__c.getDescribe(),
		'DailyDurableGenericStreamingApiEvents' => Limits__c.DailyDurableGenericStreamingApiEvents__c.getDescribe(),
		'DailyDurableStreamingApiEvents' => Limits__c.DailyDurableStreamingApiEvents__c.getDescribe(),
		'DailyEinsteinDataInsightsStoryCreation' => Limits__c.DailyEinsteinDataInsightsStoryCreation__c.getDescribe(),
		'DailyEinsteinDiscoveryOptimizationJobRuns' => Limits__c.DailyEinsteinDiscoveryOptJobRuns__c.getDescribe(),
		'DailyEinsteinDiscoveryPredictAPICalls' => Limits__c.DailyEinsteinDiscoveryPredictAPICalls__c.getDescribe(),
		'DailyEinsteinDiscoveryPredictionsByCDC' => Limits__c.DailyEinsteinDiscoveryPredictionsByCDC__c.getDescribe(),
		'DailyEinsteinDiscoveryStoryCreation' => Limits__c.DailyEinsteinDiscoveryStoryCreation__c.getDescribe(),
		'DailyGenericStreamingApiEvents' => Limits__c.DailyGenericStreamingApiEvents__c.getDescribe(),
		'DailyMetadataRetrievesWithDependencies' => Limits__c.DailyMetadataRetrievesWithDeps__c.getDescribe(),
		'DailyScratchOrgs' => Limits__c.DailyScratchOrgs__c.getDescribe(),
		'DailyStandardVolumePlatformEvents' => Limits__c.DailyStandardVolumePlatformEvents__c.getDescribe(),
		'DailyStreamingApiEvents' => Limits__c.DailyStreamingApiEvents__c.getDescribe(),
		'DailyWorkflowEmails' => Limits__c.DailyWorkflowEmails__c.getDescribe(),
		'DataStorageMB' => Limits__c.DataStorageMB__c.getDescribe(),
		'DurableStreamingApiConcurrentClients' => Limits__c.DurableStreamingApiConcurrentClients__c.getDescribe(),
		'FileStorageMB' => Limits__c.FileStorageMB__c.getDescribe(),
		'HourlyAsyncReportRuns' => Limits__c.HourlyAsyncReportRuns__c.getDescribe(),
		'HourlyDashboardRefreshes' => Limits__c.HourlyDashboardRefreshes__c.getDescribe(),
		'HourlyDashboardResults' => Limits__c.HourlyDashboardResults__c.getDescribe(),
		'HourlyDashboardStatuses' => Limits__c.HourlyDashboardStatuses__c.getDescribe(),
		'HourlyLongTermIdMapping' => Limits__c.HourlyLongTermIdMapping__c.getDescribe(),
		'HourlyManagedContentPublicRequests' => Limits__c.HourlyManagedContentPublicRequests__c.getDescribe(),
		'HourlyODataCallout' => Limits__c.HourlyODataCallout__c.getDescribe(),
		'HourlyPublishedPlatformEvents' => Limits__c.HourlyPublishedPlatformEvents__c.getDescribe(),
		'HourlyPublishedStandardVolumePlatformEvents' => Limits__c.HourlyPubStdVolPlatformEvents__c.getDescribe(),
		'HourlyShortTermIdMapping' => Limits__c.HourlyShortTermIdMapping__c.getDescribe(),
		'HourlySyncReportRuns' => Limits__c.HourlySyncReportRuns__c.getDescribe(),
		'HourlyTimeBasedWorkflow' => Limits__c.HourlyTimeBasedWorkflow__c.getDescribe(),
		'MassEmail' => Limits__c.MassEmail__c.getDescribe(),
		'MonthlyEinsteinDiscoveryStoryCreation' => Limits__c.MonthlyEinsteinDiscoveryStoryCreation__c.getDescribe(),
		'MonthlyPlatformEventsUsageEntitlement' => Limits__c.MonthlyPlatformEventsUsageEntitlement__c.getDescribe(),
		'Package2VersionCreates' => Limits__c.Package2VersionCreates__c.getDescribe(),
		'Package2VersionCreatesWithoutValidation' => Limits__c.Package2VersionCreatesWithoutValidation__c.getDescribe(),
		'PermissionSets' => Limits__c.PermissionSets__c.getDescribe(),
		'PlatformEventTriggersWithParallelProcessing' => Limits__c.PlatformEventTriggersParallel__c.getDescribe(),
		'PrivateConnectOutboundCalloutHourlyLimitMB' => Limits__c.PrivateConnectOutboundCalloutMB__c.getDescribe(),
		'SingleEmail' => Limits__c.SingleEmail__c.getDescribe(),
		'StreamingApiConcurrentClients' => Limits__c.StreamingApiConcurrentClients__c.getDescribe()
	};

	public static Integer getAvailableSingleEmail() {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit asyncLimit = mapOrgLimits.get(SINGLE_EMAIL_LIMIT);
		return asyncLimit.getLimit() - asyncLimit.getValue();
	}

	public static Boolean isAvailableSingleEmail(Double percentLimit) {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit emailLimit = mapOrgLimits.get(SINGLE_EMAIL_LIMIT);
		return (emailLimit.getLimit() * percentLimit) > emailLimit.getValue();
	}

	public static Integer getAvailableQuantityAsyncApexExecutions() {
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		System.OrgLimit asyncLimit = mapOrgLimits.get(DAILY_ASYNC_APEX_EXECUTIONS_LIMIT);
		return asyncLimit.getLimit() - asyncLimit.getValue();
	}

    public static final Integer MAX_COUNT_HOLDING_BATCH_APEX_JOBS = 100;

	public static Boolean isFlexQueueSlotAvailable() {
        return getCountHoldingBatchApexJobs() < MAX_COUNT_HOLDING_BATCH_APEX_JOBS;
    }

	// The flex queue will only hold up to 100 jobs at a time. Once this limit is reached, you will see this error when a batch apex job is submitted
	// You've exceeded the limit of 100 jobs in the flex queue
	public static Integer getCountHoldingBatchApexJobs() {
        return [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
            AND Status = :Constants.JOBS.ASYNC_APEX_JOB_PROCESS_STATUS_HOLDING
        ];
    }

	public static Integer getMaxIssues() {
		if (PermissionsUtil.MaxIssues == 0) return null;
		return PermissionsUtil.MaxIssues;
	}

	public static Integer getMaxJiraRules() {
		if (PermissionsUtil.MaxJiraRules == 0) return null;
		return PermissionsUtil.MaxJiraRules;
	}

	public static Integer getMaxMonitoringRules() {
		if (PermissionsUtil.MaxMonitoringRules == 0) return null;
		return PermissionsUtil.MaxMonitoringRules;
	}

	public static Integer getMaxArchivalRules() {
		if (PermissionsUtil.MaxArchivalRules == 0) return null;
		return PermissionsUtil.MaxArchivalRules;
	}

	public static Integer getMaxConnectedOrgs() {
		if (PermissionsUtil.MaxConnectedOrgs == 0) return null;
		return PermissionsUtil.MaxConnectedOrgs;
	}

	public static Integer getMaxNotificationRules() {
		if (PermissionsUtil.MaxNotificationRules == 0) return null;
		return PermissionsUtil.MaxNotificationRules;
	}

	public static Integer getAvailableNotifications24hr() {
		if (PermissionsUtil.MaxNotifications24hr == 0) return null;
		Integer notifications24hr = Integer.valueOf(ConfigUtil.SETTINGS.Notifications_24hr_Counter__c != null ? ConfigUtil.SETTINGS.Notifications_24hr_Counter__c : 0);
		return PermissionsUtil.MaxNotifications24hr - notifications24hr;
	}

	// NEW: Primary method for populating Limits__c records
	public static void populateLimits(Limits__c limitsRecord, Logger logger) {
		Map<String, System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		
		// Populate the Limits__c fields with the corresponding current usage values
		for (String limitKey : FIELD_MAP.keySet()) {
			System.OrgLimit orgLimit = mapOrgLimits.get(limitKey);
			if (orgLimit != null) {
				Schema.DescribeFieldResult limitsFieldDescribe = FIELD_MAP.get(limitKey);
				// Store the current usage value
				PermissionsUtil.putSObjectField(limitsRecord, limitsFieldDescribe, orgLimit.getValue());
			}
		}
	}

	/**
	 * Creates Limits__c records for logs and assigns them to the logs
	 * This method is used by both HourlyLimitsBatch and LogTriggerHandler
	 */
	public static void createLimitsForLogs(List<Log__c> newLogs, Boolean processLocalOrgLimits, Boolean processRemoteOrgLimits, Logger logger) {
		List<Limits__c> newLimitsRecords = new List<Limits__c>();
		Map<String, Limits__c> limitsByOrgId = new Map<String, Limits__c>();
		
		// Group logs by organization ID for efficient processing
		Map<String, List<Log__c>> logsByOrgId = new Map<String, List<Log__c>>();
		Map<String, Connected_Org__c> connectedOrgsByOrgId = new Map<String, Connected_Org__c>();
		
		// Group logs that need limits records
		for (Log__c log : newLogs) {
			// Skip non-hourly limits batch logs
			if (log.Category__c != HourlyLimitsBatch.CATEGORY || log.Type__c != HourlyLimitsBatch.TYPE) {
				continue;
			}
			
			if (log.Created_Timestamp__c != null && log.Limits__c == null) {
				String orgId = log.Organization_Id__c;
				Boolean isLocalOrg = orgId == UserInfo.getOrganizationId().left(15);
				
				// Process local org limits
				if (isLocalOrg && processLocalOrgLimits) {
					if (!logsByOrgId.containsKey(orgId)) {
						logsByOrgId.put(orgId, new List<Log__c>());
					}
					logsByOrgId.get(orgId).add(log);
				}
				// Process remote org limits
				else if (!isLocalOrg && processRemoteOrgLimits) {
					if (!logsByOrgId.containsKey(orgId)) {
						logsByOrgId.put(orgId, new List<Log__c>());
						Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(orgId);
						if (corg != null) {
							connectedOrgsByOrgId.put(orgId, corg);
						}
					}
					logsByOrgId.get(orgId).add(log);
				}
			}
		}
		
		// Process local orgs - create only ONE limits record for all local logs
		if (processLocalOrgLimits) {
			Boolean hasLocalLogs = false;
			String localOrgId = UserInfo.getOrganizationId().left(15);
			
			// Check if we have any local logs
			for (String orgId : logsByOrgId.keySet()) {
				if (orgId == localOrgId) {
					hasLocalLogs = true;
					break;
				}
			}
			
			// Create one limits record for all local logs
			if (hasLocalLogs) {
				Limits__c localLimit = new Limits__c();
				
				// Populate all limit fields using LimitsService
				populateLimits(localLimit, logger);
				
				newLimitsRecords.add(localLimit);
				limitsByOrgId.put(localOrgId, localLimit);
			}
		}
		
		// Process remote orgs - create one limits record per remote org
		for (String orgId : logsByOrgId.keySet()) {
			Boolean isLocalOrg = orgId == UserInfo.getOrganizationId().left(15);
			
			if (!isLocalOrg && connectedOrgsByOrgId.containsKey(orgId)) {
				Connected_Org__c corg = connectedOrgsByOrgId.get(orgId);
				
				// Create one limits record per remote org
				Limits__c remoteLimit = new Limits__c();
				
				// Populate all limit fields using REST API (one callout per org)
				populateLimits(remoteLimit, corg, logger);
				
				newLimitsRecords.add(remoteLimit);
				limitsByOrgId.put(orgId, remoteLimit);
			}
		}
		
		// Insert the new limits records in bulk
		if (!newLimitsRecords.isEmpty()) {
			insert newLimitsRecords;
			
			// Assign the newly created limits records back to the logs
			for (Log__c log : newLogs) {
				// Only assign to hourly snapshot logs
				if (log.Category__c == HourlyLimitsBatch.CATEGORY && 
					log.Type__c == HourlyLimitsBatch.TYPE &&
					log.Created_Timestamp__c != null && 
					log.Limits__c == null) {
					String orgId = log.Organization_Id__c;
					Limits__c createdLimit = limitsByOrgId.get(orgId);
					if (createdLimit != null) {
						log.Limits__c = createdLimit.Id;
					}
				}
			}
		}
	}

	/**
	 * Populates limits using REST API for remote orgs
	 * This method calls the Salesforce REST API to get current limits data
	 */
	public static void populateLimits(Limits__c limitsRecord, Connected_Org__c corg, Logger logger) {
		if (corg == null) {
			// Fallback to local limits if no connected org provided
			populateLimits(limitsRecord, logger);
			return;
		}

		try {
			// Use HttpUtils to call REST API to get limits data
			String endpoint = corg.Instance_Url__c + ConfigUtil.ORG_LIMITS_API_ENDPOINT;
			String accessToken = ConnectedOrgService.getConnectedOrgAccessToken(corg);
			
			String responseBody = HttpUtils.get(
				endpoint,
				HttpUtils.getHeadersAuthorizationAcceptJson(HttpUtils.AUTH_TYPE_BEARER + accessToken),
				200
			);
			
			Map<String, Object> limitsData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
			
			// Populate the Limits__c fields with the REST API data
			for (String limitKey : FIELD_MAP.keySet()) {
				Schema.DescribeFieldResult limitsFieldDescribe = FIELD_MAP.get(limitKey);
				
				if (limitsData.containsKey(limitKey)) {
					Map<String, Object> limitInfo = (Map<String, Object>) limitsData.get(limitKey);
					
					if (limitInfo.containsKey(LIMIT_KEY_REMAINING) && limitInfo.containsKey(LIMIT_KEY_MAX)) {
						Integer remaining = (Integer) limitInfo.get(LIMIT_KEY_REMAINING);
						Integer max = (Integer) limitInfo.get(LIMIT_KEY_MAX);
						Integer used = max - remaining;
						
						// Store current usage (used value)
						PermissionsUtil.putSObjectField(limitsRecord, limitsFieldDescribe, used);
					}
				}
			}
			
		} catch (Exception e) {
			logger?.addInternalError(e, null, 'LimitsService', '.populateLimits');
		}
	}

}