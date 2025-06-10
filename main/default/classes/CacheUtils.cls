public with sharing class CacheUtils {

	public static final Integer DEFAULT_TTL = 0;
	public static final Integer KEY_CACHE_LIMIT = 50;

	public static final String KEY_REQUEST_AUDIT_TRAIL = 'RAT';
	public static final String KEY_REQUEST_AUDIT_TRAIL_TTL = 'RequestAuditTrailTTL';

	public static final String KEY_REQUEST_AUTH_SESSIONS = 'RAS';
	public static final String KEY_REQUEST_AUTH_SESSIONS_TTL = 'RequestAuthSessionsTTL';

	public static final String KEY_REQUEST_PACKAGES_INFO = 'RPI';
	public static final String KEY_REQUEST_PACKAGES_INFO_TTL = 'RequestPackagesInfoTTL';

	public static final String KEY_REQUEST_DEPLOYMENT_JOBS = 'RDJ';
	public static final String KEY_REQUEST_DEPLOYMENT_JOBS_TTL = 'RequestDeploymentJobsTTL';

	public static final String KEY_REQUEST_ASYNC_JOBS = 'RAJ';
	public static final String KEY_REQUEST_ASYNC_JOBS_TTL = 'RequestAsyncJobsTTL';

	public static final String KEY_REQUEST_USER_INFO = 'RUI';
	public static final String KEY_REQUEST_USER_INFO_TTL = 'RequestUserInfoTTL';

	public static final String KEY_REQUEST_SOBJECT_DESCRIBE = 'RSD';
	public static final String KEY_REQUEST_SOBJECT_DESCRIBE_TTL = 'RequestSobjectDescribeTTL';

	public static final String KEY_REQUEST_FLOW_DESCRIBE = 'RFD';
	public static final String KEY_REQUEST_FLOW_DESCRIBE_TTL = 'RequestFlowDescribeTTL';

	public static final String KEY_REQUEST_STACK_TRACE = 'RST';
	public static final String KEY_REQUEST_STACK_TRACE_TTL = 'RequestStackTraceTTL';

	public static final String KEY_REQUEST_ENCRYPTED_TOKEN = 'RET';
	public static final String KEY_REQUEST_ENCRYPTED_TOKEN_TTL = 'RequestEncryptedTokenTTL';

	public static final String KEY_REQUEST_ENCRYPTED_JIRA_TOKEN = 'REJT';
	public static final Integer REQUEST_ENCRYPTED_JIRA_TOKEN_TTL = 60*60; // 60 min
	public static final String KEY_REQUEST_ENCRYPTED_JIRA_REFRESH_TOKEN = 'REJRT';
	public static final Integer REQUEST_ENCRYPTED_JIRA_REFRESH_TOKEN_TTL = 24*60*60; // 24 hours

	public static final String KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN = 'REGT';
	public static final Integer REQUEST_ENCRYPTED_GRAPH_TOKEN_TTL = 60*60; // 60 min

	public static final String KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN = 'READOT';
	public static final Integer REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN_TTL = 60*60; // 60 min

	public static final String KEY_REQUEST_METADATA_RETRIEVE_REQUEST = 'MRR';
	public static final Integer REQUEST_METADATA_RETRIEVE_REQUEST_TTL = 20*60; // 20 min

	public static final String KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID = 'JRTLB';
	public static final Integer JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL = 5*60; // 5 min

	public static final String KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID = 'GALB';
	public static final Integer KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL = 5*60; // 5 min

	public static final String KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID = 'AALB';
	public static final Integer KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL = 5*60; // 5 min

	public static final String KEY_POST_PROCESSING_LOG_TRACKING = 'PPLT';
	public static final Integer KEY_POST_PROCESSING_LOG_TRACKING_TTL = 20*60; // 20 min

	public static final String KEY_ISSUE_TRACKER_LOG_TRACKING = 'ITLT';
	public static final Integer KEY_ISSUE_TRACKER_LOG_TRACKING_TTL = 60*60; // 1 hour, wait for hourly batch process to run

	public static final String KEY_NOTIFICATION_OBJECT_TRACKING = 'NOT';
	public static final Integer KEY_NOTIFICATION_OBJECT_TRACKING_TTL = 24*60*60; // 24 hours

	public static final String KEY_POST_PROCESSING_ORCHESTRATOR_LOG_TRACKING = 'OPPLT';
	public static final Integer KEY_POST_PROCESSING_ORCHESTRATOR_LOG_TRACKING_TTL = 20*60; // 20 min

	public static final String KEY_REQUEST_RELATED_SOBJECT = 'RRS';
	public static final Integer KEY_REQUEST_RELATED_SOBJECT_TTL = 24*60*60; // 24 hours

	public static final String KEY_REQUEST_FAILED_JOB_IDS = 'RFJI';
	public static final Integer KEY_REQUEST_FAILED_JOB_IDS_TTL = 24*60*60; // 24 hours

	public static final String KEY_REQUEST_NOTIFICATION_TIMESTAMP = 'NDTS';
	public static final Integer KEY_REQUEST_NOTIFICATION_TIMESTAMP_TTL = 5*60; // 5 min

	public static final String KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP = 'RLIBT';
	public static final Integer KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP_TTL = 24*60*60; // 24 hours

	public static final String KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP = 'RTRBT';
	public static final Integer KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP_TTL = 24*60*60; // 24 hours

	public static final String PARTITION_NAME = 'PharosPartition';
	public static final String FULL_PARTITION_NAME = Cache.OrgPartition.createFullyQualifiedPartition(ConfigUtil.getNameSpace(), PARTITION_NAME);


	public static final Map<String, Integer> MapRequests {
		get {
			if(MapRequests == null) {
				MapRequests = new Map<String, Integer>();
				MapRequests.put(KEY_REQUEST_AUDIT_TRAIL, PermissionsUtil.RequestAuditTrailTTL);
				MapRequests.put(KEY_REQUEST_AUTH_SESSIONS, PermissionsUtil.RequestAuthSessionsTTL);
				MapRequests.put(KEY_REQUEST_PACKAGES_INFO, PermissionsUtil.RequestPackagesInfoTTL);
				MapRequests.put(KEY_REQUEST_DEPLOYMENT_JOBS, PermissionsUtil.RequestDeploymentJobsTTL);
				MapRequests.put(KEY_REQUEST_ASYNC_JOBS, PermissionsUtil.RequestAsyncJobsTTL);
				MapRequests.put(KEY_REQUEST_USER_INFO, PermissionsUtil.RequestUserInfoTTL);
				MapRequests.put(KEY_REQUEST_SOBJECT_DESCRIBE, PermissionsUtil.RequestSobjectDescribeTTL);
				MapRequests.put(KEY_REQUEST_FLOW_DESCRIBE, PermissionsUtil.RequestSobjectDescribeTTL);
				MapRequests.put(KEY_REQUEST_STACK_TRACE, PermissionsUtil.RequestStackTraceTTL);
				MapRequests.put(KEY_REQUEST_ENCRYPTED_TOKEN, PermissionsUtil.RequestEncryptedTokenTTL);
				MapRequests.put(KEY_REQUEST_ENCRYPTED_JIRA_TOKEN, REQUEST_ENCRYPTED_JIRA_TOKEN_TTL);
				MapRequests.put(KEY_REQUEST_ENCRYPTED_JIRA_REFRESH_TOKEN, REQUEST_ENCRYPTED_JIRA_REFRESH_TOKEN_TTL);
				MapRequests.put(KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN, REQUEST_ENCRYPTED_GRAPH_TOKEN_TTL);
				MapRequests.put(KEY_REQUEST_METADATA_RETRIEVE_REQUEST, REQUEST_METADATA_RETRIEVE_REQUEST_TTL);
				MapRequests.put(KEY_JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID, JIRA_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL);
				MapRequests.put(KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL);
				MapRequests.put(KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID_TTL);
				MapRequests.put(KEY_POST_PROCESSING_LOG_TRACKING, KEY_POST_PROCESSING_LOG_TRACKING_TTL);
				MapRequests.put(KEY_ISSUE_TRACKER_LOG_TRACKING, KEY_ISSUE_TRACKER_LOG_TRACKING_TTL);
				MapRequests.put(KEY_REQUEST_RELATED_SOBJECT, KEY_REQUEST_RELATED_SOBJECT_TTL);
				MapRequests.put(KEY_POST_PROCESSING_ORCHESTRATOR_LOG_TRACKING, KEY_POST_PROCESSING_ORCHESTRATOR_LOG_TRACKING_TTL);
				MapRequests.put(KEY_REQUEST_FAILED_JOB_IDS, KEY_REQUEST_FAILED_JOB_IDS_TTL);
				MapRequests.put(KEY_REQUEST_NOTIFICATION_TIMESTAMP, KEY_REQUEST_NOTIFICATION_TIMESTAMP_TTL);
				MapRequests.put(KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP, KEY_REQUEST_LOG_INDEX_BATCH_TIMESTAMP_TTL);
				MapRequests.put(KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP, KEY_REQUEST_TRACE_RESULT_BATCH_TIMESTAMP_TTL);
			}
			return MapRequests;
		}
		private set;
	}

	private final String orgName;
	private final Map<String, String> keyMap = new Map<String, String>();


	public CacheUtils(String orgName) {
		this.orgName = orgName;
	}

	public Object getValue(String cacheKeyPrefix, String unhashedKey) {
		String hashedKey = getHashedKey(unhashedKey);
		if(isCacheAvailableForKey(cacheKeyPrefix, hashedKey)) {
			return getCacheValue(hashedKey);
		}
		return null;
	}

	public Object getValue(String unhashedKey) {
		String hashedKey = getHashedKey(unhashedKey);
		if(isCacheAvailableForKey(unhashedKey, hashedKey)) {
			return getCacheValue(hashedKey);
		}
		return null;
	}

	public void putValue(String  cacheKeyPrefix, String unhashedKey, Object toPut) {
		String hashedKey = getHashedKey(unhashedKey);
		if(isCacheAvailableForKey(cacheKeyPrefix, hashedKey)) {
			putCacheValue(hashedKey, toPut, getTTLValue(cacheKeyPrefix));
		}

	}

	public void putValue(String unhashedKey, Object toPut) {
		String hashedKey = getHashedKey(unhashedKey);
		if(isCacheAvailableForKey(unhashedKey, hashedKey)) {
			putCacheValue(hashedKey, toPut, getTTLValue(unhashedKey.split(':')[0]));
		}

	}

	public static Boolean isCacheEnabled(String featureName) {
		return (MapRequests.get(featureName) != 0);
	}

	public static Integer getTTLValue(String featureName) {
		return MapRequests.get(featureName);
	}

	public static Boolean isCacheAvailableForKey(String featureName, String keyCache) {
		return (CacheUtils.isCacheEnabled(featureName)
				&& CacheUtils.isCacheAvailable
				&& CacheUtils.isCacheKeyValid(keyCache)
		);
	}

	public static Boolean isCacheAvailable {
		get {
			if (isCacheAvailable == null) {
				isCacheAvailable = false;
				Cache.OrgPartition orgPartition = getOrgPartition();
				if (orgPartition != null && orgPartition.getCapacity() >= 0) {
					try {
						orgPartition.put('TestAvailable', true);
						if (orgPartition.get('TestAvailable') != null) {
							isCacheAvailable = true;
						}
					}
					catch (Exception e) {
						// catch not available cache (skip)
					}
				}
			}
			return isCacheAvailable;
		}
		private set;
	}

	public static Boolean isCacheKeyValid(String key) {
		if(String.isNotBlank(key) && key.isAlphanumeric() && key.length() <= KEY_CACHE_LIMIT) {
			return true;
		}
		return false;
	}

	public static String buildCacheKey(String key, String orgName) {
		return buildCacheKey(key, orgName, '');
	}

	public static String buildCacheKey(String key, String orgName, String subKey) {
		return generateHash(key + orgName + subKey);
	}

	public static String generateHash(String inputString) {
		Blob targetBlob = Blob.valueOf(inputString);
		Blob hash = Crypto.generateDigest('SHA1', targetBlob);
		return EncodingUtil.convertToHex(hash);
	}

	public static Cache.OrgPartition getOrgPartition() {
		String fullPartitionName = Cache.OrgPartition.createFullyQualifiedPartition(ConfigUtil.getNameSpace(), PARTITION_NAME);
		Cache.OrgPartition orgPart = Cache.Org.getPartition(fullPartitionName);
		return orgPart;
	}

	public static void putCacheValue(String keyName, Object cacheValue, Integer ttlSecs) {
		putCacheValue(getOrgPartition(), keyName, cacheValue, ttlSecs);
	}

	public static Boolean THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION = false;
	public static String ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE = 'Value exceeded maximum size limit (100KB): {0} KB, {1}% of limit.';
	public static Decimal ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT = 102.5;

	public static void putCacheValue(Cache.OrgPartition orgPartition, String keyName, Object cacheValue, Integer ttlSecs) {
		if(isCacheAvailable) {
			try {
				if(Test.isRunningTest() && THROW_ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION) {
					throw new Cache.ItemSizeLimitExceededException(String.format(ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE, new List<String>{String.valueOf(ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT), String.valueOf(ITEM_SIZE_LIMIT_EXCEEDED_EXCEPTION_MESSAGE_PERCENT)}));
				}
				orgPartition.put(keyName, cacheValue, ttlSecs);
			}
			catch(Cache.ItemSizeLimitExceededException e) {
				Decimal percentUsageOverLimit = getPercentUsageOverLimit(e.getMessage());
				cacheValue = reduceCacheValue(cacheValue, percentUsageOverLimit);
				orgPartition.put(keyName, cacheValue, ttlSecs);
			}
		}
	}

	//cache.ItemSizeLimitExceededException: Value exceeded maximum size limit (100KB): 102.7 KB, 102.7% of limit.
	public static Decimal getPercentUsageOverLimit(String errorMessage) {
		try {
			String percent = errorMessage.split(', ')?.get(1)?.removeEnd('% of limit.')?.trim();
			return Decimal.valueOf(percent);
		}
		catch(Exception e) {}
		return null;
	}

	public static Object reduceCacheValue(Object cacheValue, Decimal percentOverLimit) {
		Object result = cacheValue;
		if(percentOverLimit != null) {
			if(result instanceOf Map<String, LogPostProcessingService.SObjectDescribeInfo>
					|| result instanceOf Map<String, String>
					|| result instanceOf Map<String, LogPostProcessingService.FlowDescribeInfo>
					|| result instanceOf Map<String, Integer>) {

				result = reduceFirstElementsOfMap(result, percentOverLimit);
			}
			else if(result instanceOf List<LogPostProcessingService.DeployResult>
					|| result instanceOf List<String>
					|| result instanceOf List<SetupAuditTrail>
					|| result instanceOf List<AsyncApexJob>
					|| result instanceOf List<Publisher>
					|| result instanceOf Set<String>) {

				result = reduceFirstElementsOfList(result, percentOverLimit);
			}
		}
		return result;
	}

	public static Integer getCountToRemove(Integer size, Decimal percentOverLimit) {
		Decimal multiplyCoefficientOfObject = 0.15;
		return Integer.valueOf(((size / 100.0) * percentOverLimit) * multiplyCoefficientOfObject);
	}

	public static Object reduceFirstElementsOfMap(Object cacheValue, Decimal percentOverLimit) {
		Map<String, Object> mapObjects = (Map<String, Object>)cacheValue;
		if(!mapObjects.isEmpty()) {
			Integer countToRemove = getCountToRemove(mapObjects.size(), percentOverLimit);
			List<String> keys = new List<String>(mapObjects.keySet());
			for(Integer i = 0; i < countToRemove; i++) {
				mapObjects.remove(keys.get(i));
			}
		}
		return mapObjects;
	}
	public static Object reduceFirstElementsOfList(Object cacheValue, Decimal percentOverLimit) {
		List<Object> listObjects = (List<Object>)cacheValue;
		if(!listObjects.isEmpty()) {
			Integer countToRemove = getCountToRemove(listObjects.size(), percentOverLimit);
			for(Integer i = 0; i < countToRemove; i++) {
				listObjects.remove(i);
			}
		}
		return listObjects;
	}

	public static Object getCacheValue(String keyName) {
		return getCacheValue(getOrgPartition(), keyName);
	}

	public static Object getCacheValue(Cache.OrgPartition orgPartition, String keyName) {
		if(isCacheAvailable) {
			return orgPartition.get(keyName);
		}
		return null;
	}

	private String getHashedKey(String unhashedKey) {
		if(!this.keyMap.containsKey(unhashedKey)) {
			String hashedKey = unhashedKey;
			// skip hashing for tracking keys
			if (!unhashedKey.endsWith(CacheUtils.KEY_POST_PROCESSING_LOG_TRACKING)
				&& !unhashedKey.endsWith(CacheUtils.KEY_ISSUE_TRACKER_LOG_TRACKING)) {
				
				hashedKey = buildCacheKey(unhashedKey, this.orgName);
			}
			this.keyMap.put(unhashedKey, hashedKey);
		}
		return this.keyMap.get(unhashedKey);
	}
}