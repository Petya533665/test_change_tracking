public with sharing class AzureService {

	public class AzureServiceException extends Exception {}

	public static String FROMAT_WORK_ITEM_URL = 'https://dev.azure.com/{0}/{1}/_workitems/edit/{2}';
    public static final String AZURE_DEVOPS_API_SETTINGS_NAME = 'AzureDevOps';
    public static final String AZURE_DEVOPS_API_GET_TOKEN_ENDPOINT = 'https://app.vssps.visualstudio.com/oauth2/token';
    public static final String AZURE_DEVOPS_API_AUTHORIZE_ENDPOINT = 'https://app.vssps.visualstudio.com/oauth2/authorize';

	public static final String AZURE_DEVOPS_API_TOKEN_GRANT_TYPE_REFRESH = 'refresh_token';
	public static final String GRAPH_API_TOKEN_GRANT_TYPE_AUTHORIZATION_CODE = 'authorization_code';
	public static final String GRAPH_API_TOKEN_GRANT_TYPE_CLIENT_CREDENTIALS = 'client_credentials';

    public static final String AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER = 'Bearer ';
    public static final String AZURE_DEVOPS_REST_API_VERSION = 'api-version=7.0';
    public static final String AZURE_DEVOPS_REST_API_ENDPOINT = 'https://app.vssps.visualstudio.com/';
    public static final String AZURE_DEVOPS_REST_API_MY_PROFILE = AZURE_DEVOPS_REST_API_ENDPOINT + '_apis/profile/profiles/me?' + AZURE_DEVOPS_REST_API_VERSION;
    //https://app.vssps.visualstudio.com/_apis/accounts?memberId={publicAlias}&api-version=6.0
    public static String AZURE_DEVOPS_REST_API_MY_ACCOUNTS = AZURE_DEVOPS_REST_API_ENDPOINT + '_apis/accounts';
	//https://dev.azure.com/{organization}/{project}/_apis/wit/workitemtypes?api-version=7.0
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitemtypes?' + AZURE_DEVOPS_REST_API_VERSION;
	//https://dev.azure.com/{organization}/_apis/projects?api-version=7.0
	public static String AZURE_DEVOPS_REST_API_PROJECT = 'https://dev.azure.com/{0}/_apis/projects?' + AZURE_DEVOPS_REST_API_VERSION;
	//GET https://dev.azure.com/{organization}/_apis/work/processes/{processId}/workItemTypes/{witRefName}/fields?api-version=7.1-preview.2
	public static String AZURE_DEVOPS_REST_API_PROCESS_WORK_ITEM_TYPE_FIELDS = 'https://dev.azure.com/{0}/_apis/work/processes/{1}/workItemTypes/{2}/fields?api-version=7.1-preview.2';
	//https://dev.azure.com/{organization}/_apis/projects/{projectId}/teams?api-version=7.0
    public static String AZURE_DEVOPS_REST_API_TEAMS = 'https://dev.azure.com/{0}/_apis/projects/{1}/teams?' + AZURE_DEVOPS_REST_API_VERSION;
	//GET https://dev.azure.com/{organization}/_apis/projects/{projectId}/properties?api-version=4.1-preview.1
	public static String AZURE_DEVOPS_REST_API_PROJECT_PROPERTIES = 'https://dev.azure.com/{0}/_apis/projects/{1}/properties?api-version=7.0-preview.1';
	//https://dev.azure.com/{organization}/_apis/projects/{projectId}/teams/{teamId}/members?api-version=7.0
    public static String AZURE_DEVOPS_REST_API_TEAM_MEMBERS = 'https://dev.azure.com/{0}/_apis/projects/{1}/teams/{2}/members?' + AZURE_DEVOPS_REST_API_VERSION;
	public static final String HTTP_SKIP_PARAMETER = '&$skip';
	public static final String HTTP_SKIP_PARAMETER_DEFAULT_VALUE = '0';
	//GET https://dev.azure.com/{organization}/{project}/_apis/work/boards/{board}/columns?api-version=7.1-preview.2
	public static String AZURE_DEVOPS_REST_API_BOARD_COLUMNS = 'https://dev.azure.com/{0}/{1}/{2}/_apis/work/boards/{3}/columns?' + AZURE_DEVOPS_REST_API_VERSION;
	public static String AZURE_DEVOPS_REST_API_TEAM_SETTINGS = 'https://dev.azure.com/{0}/{1}/{2}/_apis/work/teamsettings?' + AZURE_DEVOPS_REST_API_VERSION;
	public static String AZURE_DEVOPS_REST_API_BOARD_SETTINGS = 'https://dev.azure.com/{0}/{1}/{2}/_apis/work/boards/{3}?' + AZURE_DEVOPS_REST_API_VERSION;

	//https://dev.azure.com/{organization}/{project}/_apis/wit/workitems/${type}?api-version=5.1
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems/${2}?' + AZURE_DEVOPS_REST_API_VERSION;

	//https://dev.azure.com/{organization}/{project}/_apis/wit/workitems/{id}?api-version=7.0
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM_ID = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems/{2}?' + AZURE_DEVOPS_REST_API_VERSION;
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems/{2}?' + AZURE_DEVOPS_REST_API_VERSION + '&$expand=All';

	//https://dev.azure.com/{organization}/{project}/_apis/wit/workitems?ids={ids}&fields={fields}&asOf={asOf}&$expand={$expand}&errorPolicy={errorPolicy}&api-version=7.0
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM_LIST = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems?ids={2}&' + AZURE_DEVOPS_REST_API_VERSION;

	//POST https://dev.azure.com/{organization}/{project}/{team}/_apis/wit/wiql?api-version=5.1
	public static String AZURE_DEVOPS_REST_API_WIQL = 'https://dev.azure.com/{0}/{1}/_apis/wit/wiql?' + AZURE_DEVOPS_REST_API_VERSION;

	public static String AZURE_DEVOPS_REST_API_ITERATION = 'https://dev.azure.com/{0}/{1}/_apis/wit/classificationnodes/{2}?$depth=5&' + AZURE_DEVOPS_REST_API_VERSION;

	public static String AZURE_DEVOPS_ITERATIONS = 'Iterations';

	public static String AZURE_DEVOPS_AREAS = 'Areas';
	
	public static String AZURE_DEVOPS_PROCESS_TEMPLATE_TYPE = 'System.ProcessTemplateType';

	//GET https://dev.azure.com/{organization}/_apis/work/processes?api-version=7.1-preview.2
	public static String AZURE_DEVOPS_REST_API_PROCESSES_LIST = 'https://dev.azure.com/{0}/_apis/work/processes?' + AZURE_DEVOPS_REST_API_VERSION;

	//GET https://dev.azure.com/{organization}/_apis/work/processes/{processId}/workitemtypes?api-version=7.1-preview.2
	public static String AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE_BY_PROCESS = 'https://dev.azure.com/{0}/_apis/work/processes/{1}/workitemtypes?' + AZURE_DEVOPS_REST_API_VERSION;

	//GET https://dev.azure.com/{organization}/{project}/{team}/_apis/work/boards?api-version=7.1
	public static String AZURE_DEVOPS_REST_API_BOARDS = 'https://dev.azure.com/{0}/{1}/{2}/_apis/work/boards?api-version=7.0';

	// Work Item Type Names - Centralized constants to avoid hardcoding
	public static final String WORK_ITEM_TYPE_BUG = 'Bug';

	// Team Bugs Behavior Constants
	public static final String BUGS_BEHAVIOR_OFF = 'off';
	public static final String BUGS_BEHAVIOR_AS_TASKS = 'asTasks';
	public static final String BUGS_BEHAVIOR_AS_REQUIREMENTS = 'asRequirements';

	// Parameter Names Constants
	public static final String PARAM_PROJECT_ID = 'projectId';
	public static final String PARAM_TEAM_ID = 'teamId';
	public static final String PARAM_BOARD_ID = 'boardId';
	public static final String PARAM_ORGANIZATION_ID = 'organizationId';

	// JSON Field Names Constants
	public static final String JSON_FIELD_ID = 'id';
	public static final String JSON_FIELD_NAME = 'name';
	public static final String JSON_FIELD_VALUE = 'value';
	public static final String JSON_FIELD_COLUMNS = 'columns';
	public static final String JSON_FIELD_STATE_MAPPINGS = 'stateMappings';
	public static final String JSON_FIELD_ALLOWED_MAPPINGS = 'allowedMappings';
	public static final String JSON_FIELD_BUGS_BEHAVIOR = 'bugsBehavior';

	// Board Column Types Constants
	public static final String BOARD_COLUMN_TYPE_INCOMING = 'incoming';
	public static final String BOARD_COLUMN_TYPE_IN_PROGRESS = 'inProgress';
	public static final String BOARD_COLUMN_TYPE_OUTGOING = 'outgoing';

	// Board Mapping Types Constants
	public static final String BOARD_MAPPING_INCOMING = 'Incoming';
	public static final String BOARD_MAPPING_IN_PROGRESS = 'InProgress';
	public static final String BOARD_MAPPING_OUTGOING = 'Outgoing';

    public static String OAUTH_API_REFRESH_TOKEN {
		get {
			OAUTH_API_REFRESH_TOKEN = GraphApiService.getAzureDevOpsApiRefreshTokenFromSettings();
			return OAUTH_API_REFRESH_TOKEN;
		}
		set;
	}

	public static String OAUTH_API_TOKEN {
		get {
			String cacheToken = getDecryptedAzureDevOpsTokenFromCache();
			OAUTH_API_TOKEN = String.isBlank(cacheToken) ? GraphApiService.getAzureDevOpsApiTokenFromSettings() : cacheToken;
			return OAUTH_API_TOKEN;
		}
		set;
	}

	public static String getAzureDevOpsInstanceKey(String azureOrganizationId) {
		return EncodingUtil.base64Encode(Crypto.generateDigest('SHA3-256', Blob.valueOf(String.valueOf(azureOrganizationId))));
	}

	public static void putEncryptedAzureDevOpsTokenToCache(Logger logger, Azure_Dev_Ops_API_Settings__c azureSettings, String token) {
		try {
			if(PermissionsUtil.AzureDevOpsIntegrationEnabled && String.isNotBlank(token)) {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN, getAzureDevOpsInstanceKey(azureSettings.Organization_Id__c), '');
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN, keyCache);
				if (isCacheAvailableForKey) {
					Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(getAzureDevOpsInstanceKey(azureSettings.Organization_Id__c)), Blob.valueOf(token));
					CacheUtils.putCacheValue(keyCache, encryptedToken, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN));
				}
			}
		} catch (Exception e) {
			logger?.add(logger.getInternalError(e, azureSettings.Id, AzureService.class.getName(), 'putEncryptedAzureDevOpsTokenToCache'));
		}
	}

	public static String getDecryptedAzureDevOpsTokenFromCache() {
		try {
			if(PermissionsUtil.AzureDevOpsIntegrationEnabled && String.isNotBlank(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c)) {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN, getAzureDevOpsInstanceKey(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c), '');
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_AZURE_DEV_OPS_TOKEN, keyCache);
				if (isCacheAvailableForKey) {
					Object cacheObject = CacheUtils.getCacheValue(keyCache);
					if (cacheObject != null) {
						Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(getAzureDevOpsInstanceKey(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c)), (Blob)cacheObject);
						return decryptedToken.toString();
					}
				}
			}
			return null;
		}
		catch (Exception e) {
			Logger.getInstance().internalError(e, ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Id, true, AzureService.class.getName(), 'getDecryptedAzureDevOpsTokenFromCache');
		}
		return null;
	}

	public static Boolean validateAndRefreshAzureDevOpsApiOauthToken(Logger logger, Boolean withDML) {
		if (PermissionsUtil.AzureDevOpsIntegrationEnabled
			&& String.isNotBlank(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c)) {
			try {
				refreshOAuthToken(logger, withDML);
				return true;
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, ConfigUtil.GRAPH_API_SETTINGS.Id, AzureService.class.getName(), 'validateAndRefreshAzureDevOpsApiOauthToken'));
			}
		}
		return false;
	}

	public static void refreshOAuthToken(Logger logger, Boolean withDML) {
		OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(AzureService.AZURE_DEVOPS_API_SETTINGS_NAME);
		String endpoint = GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT;

		HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REFRESH_TOKEN, OAUTH_API_REFRESH_TOKEN);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, mdtSettings.Client_Secret__c);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, GraphAPIService.GRAPH_API_TOKEN_GRANT_TYPE_REFRESH);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, GraphAPIService.GRAPH_API_TOKEN_RESPONSE_TYPE_CODE);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
		bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, GraphAPIService.AZURE_DEVOPS_API_SCOPE);

		String b = HttpUtils.post(
			endpoint,
			bodyParams.toStringParameters(),
			HttpUtils.getHeadersContentTypeFormUrlencoded(),
			200
		);
		ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);

		AzureService.putEncryptedAzureDevOpsTokenToCache(logger, ConfigUtil.AZURE_DEV_OPS_API_SETTINGS, resp.access_token);
		GraphAPIService.putAzureDevOpsApiTokenToSettings(resp.access_token, false, logger);
		GraphAPIService.putAzureDevOpsApiRefreshTokenToSettings(resp.refresh_token, false, logger);
		GraphAPIService.saveListTokenRecordSettings(withDml, logger);

		if (withDML) {
			DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c)
					.handleError(AdminService.class.getName(), '.refreshOAuthToken', logger);
		}
	}

	public static final String AZURE_DEV_OPS_API_ROTATE_TOKEN_STATUS_COMPLETED = 'Completed';
	public class AzureDevOpsApiManageTokens {

		public Boolean completed = false;

		public AzureDevOpsApiManageTokens() {}

		public void flushSettings(Logger logger) {
			if(this.completed) {
				try {
					GraphAPIService.saveListTokenRecordSettings(true, logger);
					DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c)
							.handleError(AdminService.class.getName(), '.flushSettings', logger);
				}
				catch (Exception e) {
					logger?.addInternalError(e, null, AzureService.class.getName(), 'flushSettings');
				}
			}
		}

		public Boolean isUnlocked(Logger logger) {
			String lockedJobId = getLockedJobId(logger);
			Boolean isUnlocked = String.isBlank(lockedJobId) || lockedJobId == AZURE_DEV_OPS_API_ROTATE_TOKEN_STATUS_COMPLETED;
			return isUnlocked;
		}

		public void rotateTokens(Logger logger, String asyncApexJobId) {
			rotateTokens(logger, asyncApexJobId, false);
		}

		public void rotateTokens(Logger logger, String asyncApexJobId, Boolean forceRefresh) {
			if(forceRefresh || !isAzureDevOpsAPIAccessTokenAvailable()) {
				try {
					if(isUnlocked(logger)) {
						setLockedJobId(asyncApexJobId, logger);
						Boolean result = validateAndRefreshAzureDevOpsApiOauthToken(logger, false);
						completed = result;
						setLockedJobId(AZURE_DEV_OPS_API_ROTATE_TOKEN_STATUS_COMPLETED, logger);
					}
				}
				catch (Exception e) {
					logger?.add(logger.getInternalError(e, null, AzureService.class.getName(), 'rotateTokens'));
				}
			}
		}

		private void setLockedJobId(String asyncApexJobId, Logger logger) {
			try {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
				if (isCacheAvailableForKey) {
					CacheUtils.putCacheValue(keyCache, asyncApexJobId, CacheUtils.getTTLValue(CacheUtils.KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID));
				}
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, null, AzureService.class.getName(), 'setLockedJobId'));
			}
		}

		public String getLockedJobId(Logger logger) {
			String lockedJobId;
			try {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_AZURE_DEV_OPS_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
				if (isCacheAvailableForKey) {
					Object cacheObject = CacheUtils.getCacheValue(keyCache);
					if (cacheObject != null) {
						lockedJobId = String.valueOf(cacheObject);
					}
				}
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, null, AzureService.class.getName(), 'getLockedJobId'));
			}
			return lockedJobId;
		}

		private Boolean isAzureDevOpsAPIAccessTokenAvailable() {
			Boolean result = false;

			try {
				AzureDevOpsMyProfile myProfile = getMyProfile(OAUTH_API_TOKEN);
				result = true;
			}
			catch (HttpUtils.HttpUtilsException e) {
				result = false;
			}
			return result;
		}
	}

	public static List<AzureDevOpsProcess> getOrganizationProcesses(String organization) {
		List<AzureDevOpsProcess> result = new List<AzureDevOpsProcess>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_PROCESSES_LIST, new List<String>{organization});
		String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsProcessWrapper ow = (AzureDevOpsProcessWrapper)JSON.deserialize(b, AzureDevOpsProcessWrapper.class);
		result = ow.value;
		return result;
	}

	public class AzureDevOpsProcessWrapper {
		public Integer count;
		public List<AzureDevOpsProcess> value;
	}

	public class AzureDevOpsProcess {
		public String typeId;
		public String name;
		public String description;
		public Boolean isEnabled;
		public Boolean isDefault;
		public String parentProcessTypeId;
		public String customizationType;
    }

	public class AzureDevOpsProcessWorkItemTypeWrapper {
		public Integer count;
		public List<AzureDevOpsProcessWorkItemType> value;
	}

	public class AzureDevOpsProcessWorkItemType {
		public String referenceName;
		public String name;
		public String description;
		public String url;
		public Boolean isDefault;
		public String icon;
		public String color;
		public String customization;
		public String inherits;
		public Boolean isDisabled;
	}

	public static List<AzureDevOpsProcessWorkItemType> getOrganizationProcessesWorkItemTypes(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String processId = (String)ss?.get('processId');
		return getOrganizationProcessesWorkItemTypes(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, processId);
	}

	public static List<AzureDevOpsProcessWorkItemType> getOrganizationProcessesWorkItemTypes(String organization, String processId) {
		List<AzureDevOpsProcessWorkItemType> result = new List<AzureDevOpsProcessWorkItemType>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE_BY_PROCESS, new List<String>{organization, processId});
		String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsProcessWorkItemTypeWrapper ow = (AzureDevOpsProcessWorkItemTypeWrapper)JSON.deserialize(b, AzureDevOpsProcessWorkItemTypeWrapper.class);
		result = ow.value;
		return result;
	}

	/**
	 * Common validation method to ensure work item types match between API and UI.
	 * This method performs comprehensive checks:
	 * 1. Team permissions and access
	 * 2. Board configuration and column settings (optional)
	 * 3. Work item type field requirements
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param processId The Azure DevOps process ID
	 * @param teamId The Azure DevOps team ID (required for validation)
	 * @param boardId The Azure DevOps board ID (optional, used for board-specific filtering)
	 * @return AzureDevOpsConfigurationValidationResult Comprehensive validation result containing all validation details
	 */
	public static AzureDevOpsConfigurationValidationResult validateWorkItemTypeConfiguration(String organization, String projectId, String processId, String teamId, String boardId) {
		AzureDevOpsConfigurationValidationResult validationResult = new AzureDevOpsConfigurationValidationResult();
		validationResult.isValid = true;
		validationResult.hasTeamAccess = false;
		validationResult.hasBoardConfiguration = false;
		validationResult.hasRequiredFields = false;

		// Validate required parameters - only teamId is required, boardId is optional
		if (String.isBlank(teamId)) {
			validationResult.isValid = false;
			return validationResult;
		}

		try {
			// Step 1: Get all work item types from process using existing method
			List<AzureDevOpsProcessWorkItemType> allWorkItemTypes = getOrganizationProcessesWorkItemTypes(organization, processId);
			validationResult.totalWorkItemTypes = allWorkItemTypes.size();

			// Step 2: Check team permissions and access for specific team
			validationResult.teamAccessValidation = validateTeamAccess(organization, projectId, teamId);
			validationResult.hasTeamAccess = validationResult.teamAccessValidation.isValid;

			// Step 3: Check board configuration for specific team and board (optional)
			validationResult.boardConfigurationValidation = validateBoardConfiguration(organization, projectId, teamId, boardId);
			validationResult.hasBoardConfiguration = validationResult.boardConfigurationValidation.isValid;

			// Step 4: Filter work item types based on all validations
			validationResult.filteredWorkItemTypes = filterWorkItemTypesByConfiguration(allWorkItemTypes, validationResult);
			validationResult.filteredWorkItemTypeCount = validationResult.filteredWorkItemTypes.size();

		} catch (Exception e) {
			validationResult.isValid = false;
		}

		return validationResult;
	}

	/**
	 * Validates team access and permissions for a specific team using Team Settings API.
	 * This method retrieves team settings and extracts configuration information including
	 * bug behavior settings that affect work item type visibility.
	 * 
	 * Based on: https://learn.microsoft.com/en-us/rest/api/azure/devops/work/teamsettings/get?view=azure-devops-rest-7.1&tabs=HTTP
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID
	 * @return AzureDevOpsTeamAccessValidation Team access validation result with team settings information
	 */
	private static AzureDevOpsTeamAccessValidation validateTeamAccess(String organization, String projectId, String teamId) {
		AzureDevOpsTeamAccessValidation validation = new AzureDevOpsTeamAccessValidation();
		validation.isValid = true;

		if (String.isBlank(teamId)) {
			validation.isValid = false;
			return validation;
		}

		try {
			// Get team settings using the official Team Settings API
			String teamSettingsEndpoint = String.format(AZURE_DEVOPS_REST_API_TEAM_SETTINGS, 
				new List<String>{organization, projectId, teamId});
			String teamSettingsResponse = HttpUtils.get(teamSettingsEndpoint, 
				HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN), 200);

			// Parse team settings response using untyped JSON first to handle complex nested objects
			Map<String, Object> teamSettingsData = (Map<String, Object>)JSON.deserializeUntyped(teamSettingsResponse);

			if (teamSettingsData != null) {
				validation.isValid = true;

				// Extract team settings information for bug behaviors and other configurations
				if (teamSettingsData.containsKey(JSON_FIELD_BUGS_BEHAVIOR)) {
					validation.bugsBehavior = String.valueOf(teamSettingsData.get(JSON_FIELD_BUGS_BEHAVIOR));
				}

			} else {
				validation.isValid = false;
			}
		} catch (Exception e) {
			validation.isValid = false;
		}

		return validation;
	}

	/**
	 * Validates board configuration and column settings for a specific team and board (board is optional).
	 * Board settings can filter work item types in several ways:
	 * 1. Board columns configuration (which work item types can be in which columns)
	 * 2. Board settings (which work item types are enabled for the board)
	 * 3. Column rules (field-based filtering)
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID
	 * @param boardId The Azure DevOps board ID (optional)
	 * @return AzureDevOpsBoardConfigurationValidation Board configuration validation result
	 */
	private static AzureDevOpsBoardConfigurationValidation validateBoardConfiguration(String organization, String projectId, String teamId, String boardId) {
		AzureDevOpsBoardConfigurationValidation validation = new AzureDevOpsBoardConfigurationValidation();
		validation.isValid = true;

		if (String.isBlank(teamId)) {
			validation.isValid = false;
			return validation;
		}

		try {
			// Get boards for the specific team
			List<AzureDevOpsBoardReference> boards = getTeamBoards(organization, projectId, teamId);

			if (boards == null || boards.isEmpty()) {
				validation.isValid = false;
			} else {
				// Only validate specific board if boardId is provided
				if (String.isNotBlank(boardId)) {
					Boolean boardExists = false;

					for (AzureDevOpsBoardReference board : boards) {
						if (board.id == boardId) {
							boardExists = true;
							break;
						}
					}

					if (boardExists) {
						// Validate board columns and settings that affect work item type visibility
						validation = validateBoardColumnsAndSettings(organization, projectId, teamId, boardId, validation);
					} else {
						validation.isValid = false;
					}
				}
			}

		} catch (Exception e) {
			validation.isValid = false;
		}

		return validation;
	}

	/**
	 * Validates board columns and settings that affect work item type visibility.
	 * This method checks board-specific settings and column configurations that can
	 * filter which work item types are visible on the board.
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID
	 * @param boardId The Azure DevOps board ID
	 * @param validation The board configuration validation object to update
	 * @return AzureDevOpsBoardConfigurationValidation Updated board configuration validation result
	 */
	private static AzureDevOpsBoardConfigurationValidation validateBoardColumnsAndSettings(String organization, String projectId, String teamId, String boardId, AzureDevOpsBoardConfigurationValidation validation) {
		// First, get board-specific settings
		validation = validateBoardSpecificSettings(organization, projectId, teamId, boardId, validation);

		// Then validate board columns
		try {
			// Get board columns configuration - use the board name if available, otherwise use board ID
			String columnsEndpoint = String.format(AZURE_DEVOPS_REST_API_BOARD_COLUMNS, 
				new List<String>{organization, projectId, teamId, boardId});
			String columnsResponse = HttpUtils.get(columnsEndpoint, 
				HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN), 200);

			// Parse columns response
			Map<String, Object> columnsData = (Map<String, Object>)JSON.deserializeUntyped(columnsResponse);
			List<Object> columns = (List<Object>)columnsData.get('value');

			if (columns != null && !columns.isEmpty()) {
				validation.isValid = true;
			} else {
				validation.isValid = false;
			}

		} catch (Exception e) {
			validation.isValid = false;
		}

		return validation;
	}

	/**
	 * Validates board-specific settings that control work item type visibility.
	 * This method checks board-level configurations that can hide/show specific work item types
	 * and extracts allowed work item types from board settings.
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID
	 * @param boardId The Azure DevOps board ID
	 * @param validation The board configuration validation object to update
	 * @return AzureDevOpsBoardConfigurationValidation Updated board configuration validation result
	 */
	private static AzureDevOpsBoardConfigurationValidation validateBoardSpecificSettings(String organization, String projectId, String teamId, String boardId, AzureDevOpsBoardConfigurationValidation validation) {
		try {
			// First, get available boards to validate the board ID
			String boardsEndpoint = String.format(AZURE_DEVOPS_REST_API_BOARDS, 
			new List<String>{organization, projectId, teamId});
			String boardsResponse = HttpUtils.get(boardsEndpoint, 
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN), 200);

			// Parse available boards response to get valid board ID
			String validBoardId = boardId;
			if (boardsResponse != null && boardsResponse != '') {
				try {
					Map<String, Object> boardsData = (Map<String, Object>) JSON.deserializeUntyped(boardsResponse);
					if (boardsData.containsKey('value')) {
						List<Object> boards = (List<Object>) boardsData.get('value');
						if (boards != null && !boards.isEmpty()) {
							for(Object board : boards) {
								Map<String, Object> boardMap = (Map<String, Object>) board;
								if (boardMap.containsKey('id')) {
									String remoteBoardId = String.valueOf(boardMap.get('id'));
									if (remoteBoardId == boardId) {
										validBoardId = remoteBoardId;
										if (boardMap.containsKey('name')) {
											String boardName = String.valueOf(boardMap.get('name'));
											validation.boardName = boardName;
										}
										break;
									}
								}
							}
						}
					}
				} catch (Exception e) {}
			}

			// Get board-specific settings using valid board ID
			String boardSettingsEndpoint = String.format(AZURE_DEVOPS_REST_API_BOARD_SETTINGS, 
			new List<String>{organization, projectId, teamId, validBoardId});

			String boardSettingsResponse = HttpUtils.get(boardSettingsEndpoint, 
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN), 200);

			// Parse board settings response
			Map<String, Object> boardSettingsData = (Map<String, Object>)JSON.deserializeUntyped(boardSettingsResponse);

			if (boardSettingsData != null) {
				// Check for board name first
				if (boardSettingsData.containsKey(JSON_FIELD_NAME)) {
					String boardName = String.valueOf(boardSettingsData.get(JSON_FIELD_NAME));
					validation.boardName = boardName;
				}

				// Extract allowed work item types from stateMappings
				Set<String> allowedWorkItemTypes = new Set<String>();

				// Check for stateMappings which contain the allowed work item types
				if (boardSettingsData.containsKey(JSON_FIELD_COLUMNS)) {
					List<Object> columns = (List<Object>)boardSettingsData.get(JSON_FIELD_COLUMNS);
					if (columns != null && !columns.isEmpty()) {
						// Get work item types from the first column's stateMappings
						Map<String, Object> firstColumn = (Map<String, Object>)columns[0];
						if (firstColumn.containsKey(JSON_FIELD_STATE_MAPPINGS)) {
							Map<String, Object> stateMappings = (Map<String, Object>)firstColumn.get(JSON_FIELD_STATE_MAPPINGS);
							allowedWorkItemTypes.addAll(stateMappings.keySet());
						}
					}
				}

				// Also check allowedMappings for additional work item types
				if (boardSettingsData.containsKey(JSON_FIELD_ALLOWED_MAPPINGS)) {
					Map<String, Object> allowedMappings = (Map<String, Object>)boardSettingsData.get(JSON_FIELD_ALLOWED_MAPPINGS);
					if (allowedMappings.containsKey(BOARD_MAPPING_INCOMING)) {
						Map<String, Object> incomingMappings = (Map<String, Object>)allowedMappings.get(BOARD_MAPPING_INCOMING);
						allowedWorkItemTypes.addAll(incomingMappings.keySet());
					}
					if (allowedMappings.containsKey(BOARD_MAPPING_IN_PROGRESS)) {
						Map<String, Object> inProgressMappings = (Map<String, Object>)allowedMappings.get(BOARD_MAPPING_IN_PROGRESS);
						allowedWorkItemTypes.addAll(inProgressMappings.keySet());
					}
					if (allowedMappings.containsKey(BOARD_MAPPING_OUTGOING)) {
						Map<String, Object> outgoingMappings = (Map<String, Object>)allowedMappings.get(BOARD_MAPPING_OUTGOING);
						allowedWorkItemTypes.addAll(outgoingMappings.keySet());
					}
				}

				// Store the allowed work item types for filtering
				if (!allowedWorkItemTypes.isEmpty()) {
					validation.allowedWorkItemTypes = new List<String>(allowedWorkItemTypes);
				}

				validation.isValid = true;
			} else {
				validation.isValid = false;
			}

		} catch (Exception e) {
			validation.isValid = false;
		}

		return validation;
	}

	/**
	 * Filters work item types based on configuration validation results.
	 * This method uses dynamic filtering based on work item type properties rather than hardcoded names
	 * and also considers board settings that may filter work item types.
	 * 
	 * @param allTypes List of all work item types from the process
	 * @param validation Configuration validation result containing team and board settings
	 * @return List<AzureDevOpsProcessWorkItemType> Filtered list of work item types that pass all validation criteria
	 */
	private static List<AzureDevOpsProcessWorkItemType> filterWorkItemTypesByConfiguration(List<AzureDevOpsProcessWorkItemType> allTypes, AzureDevOpsConfigurationValidationResult validation) {
		List<AzureDevOpsProcessWorkItemType> filteredTypes = new List<AzureDevOpsProcessWorkItemType>();

		for (AzureDevOpsProcessWorkItemType wit : allTypes) {
			// Include work item types based on their properties and characteristics
			if (shouldIncludeWorkItemType(wit, validation)) {
				// Additional check: if board validation indicates restrictions, be more selective
				if (hasBoardRestrictions(validation)) {
					if (isWorkItemTypeAllowedInBoard(wit, validation)) {
						filteredTypes.add(wit);
					}
				} else {
					filteredTypes.add(wit);
				}
			}
		}

		validation.filteredWorkItemTypeCount = filteredTypes.size();
		return filteredTypes;
	}

	/**
	 * Determines if a work item type should be included based on its properties.
	 * This method evaluates work item types based on their customization type, team settings,
	 * and configuration to determine if they should be visible in the UI.
	 * 
	 * @param wit The work item type to evaluate
	 * @param validation Configuration validation result containing team and board settings
	 * @return Boolean True if the work item type should be included, false otherwise
	 */
	private static Boolean shouldIncludeWorkItemType(AzureDevOpsProcessWorkItemType wit, AzureDevOpsConfigurationValidationResult validation) {

		// If the work item type is disabled, it should not be included
		if (wit.isDisabled) {
			return false;
		}

		// Second check: Is this work item type affected by team settings (bugs behavior, etc.)?
		if (isWorkItemTypeHiddenByTeamSettings(wit, validation)) {
			return false;
		}

		// Always include inherited types (they are typically visible in UI)
		if (wit.customization == 'inherited') {
			return true;
		}

		// Include custom/system types that have proper field configuration
		if (wit.customization == 'custom' || wit.customization == 'system') {
			return isWorkItemTypeProperlyConfigured(wit);
		}

		return false;
	}

	/**
	 * Determines if a work item type is properly configured for UI visibility.
	 * This method checks if a custom work item type has the necessary configuration
	 * to be displayed in the UI, including name, referenceName.
	 * 
	 * @param wit The work item type to evaluate
	 * @return Boolean True if the work item type is properly configured, false otherwise
	 */
	private static Boolean isWorkItemTypeProperlyConfigured(AzureDevOpsProcessWorkItemType wit) {
		// Check if the work item type has a meaningful name (not empty or null)
		// Check if it has a valid reference name
		if (String.isBlank(wit.name) || String.isBlank(wit.referenceName)) {
			return false;
		}

		return true;
	}

	/**
	 * Checks if board validation indicates restrictions that may filter work item types.
	 * This method determines if the board configuration has explicit restrictions
	 * on which work item types are allowed.
	 * 
	 * @param validation Configuration validation result containing board settings
	 * @return Boolean True if board has restrictions, false otherwise
	 */
	private static Boolean hasBoardRestrictions(AzureDevOpsConfigurationValidationResult validation) {
		if (validation.boardConfigurationValidation != null && 
			validation.boardConfigurationValidation.allowedWorkItemTypes != null && 
			!validation.boardConfigurationValidation.allowedWorkItemTypes.isEmpty()) {
			return true;
		}
		return false;
	}

	/**
	 * Determines if a work item type is likely allowed in board based on common patterns.
	 * This method checks board-specific allowed work item types if available,
	 * and falls back to common patterns for work item type customization.
	 * 
	 * @param wit The work item type to evaluate
	 * @param validation Configuration validation result containing board settings
	 * @return Boolean True if the work item type is likely allowed in the board, false otherwise
	 */
	private static Boolean isWorkItemTypeAllowedInBoard(AzureDevOpsProcessWorkItemType wit, AzureDevOpsConfigurationValidationResult validation) {
		// First check: If board has explicit allowed work item types, use that list
		if (validation.boardConfigurationValidation != null && 
			validation.boardConfigurationValidation.allowedWorkItemTypes != null && 
			!validation.boardConfigurationValidation.allowedWorkItemTypes.isEmpty()) {

			// Check if this work item type is in the explicitly allowed list
			// Board settings use work item type names (not reference names)
			for (String allowedType : validation.boardConfigurationValidation.allowedWorkItemTypes) {
				if (wit.name == allowedType) {
					return true;
				}
			}
			return false;
		}

		// Inherited, system, and custom types are allowed
		if (wit.customization == 'inherited' || wit.customization == 'system' || wit.customization == 'custom') {
			return true;
		}
		
		return false;
	}

	/**
	 * Determines if a work item type is hidden by team settings (bugs behavior, etc.).
	 * This method uses team access validation data to check if a work item type
	 * should be hidden based on team configuration, such as bug behavior settings.
	 * 
	 * @param wit The work item type to evaluate
	 * @param validation Configuration validation result containing team settings
	 * @return Boolean True if the work item type is hidden by team settings, false otherwise
	 */
	private static Boolean isWorkItemTypeHiddenByTeamSettings(AzureDevOpsProcessWorkItemType wit, AzureDevOpsConfigurationValidationResult validation) {
		// Use team access validation data instead of making separate API calls
		if (validation.teamAccessValidation != null && validation.teamAccessValidation.isValid) {
			String bugsBehavior = validation.teamAccessValidation.bugsBehavior;

			// If bugs are disabled and this is a Bug work item type, filter it out
			if (String.isNotBlank(bugsBehavior) && bugsBehavior == BUGS_BEHAVIOR_OFF && 
				(wit.referenceName.contains('Bug') || wit.name == WORK_ITEM_TYPE_BUG)) {
				return true; // Hidden by team settings
			}
		}

		return false; // Not hidden
	}

	/**
	 * Enhanced method to get work item types with comprehensive configuration validation.
	 * This method performs validation based on team settings, board configuration, and field requirements
	 * to return only work item types that are properly configured and accessible.
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param processId The Azure DevOps process ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID (required for validation)
	 * @param boardId The Azure DevOps board ID (optional, used for board-specific filtering)
	 * @return List<AzureDevOpsProcessWorkItemType> Filtered list of work item types that pass validation
	 */
	public static List<AzureDevOpsProcessWorkItemType> getOrganizationProcessesWorkItemTypesWithValidation(String organization, String processId, String projectId, String teamId, String boardId) {
		// Perform comprehensive configuration validation
		AzureDevOpsConfigurationValidationResult validation = validateWorkItemTypeConfiguration(organization, projectId, processId, teamId, boardId);

		// If validation fails, return unfiltered work item types using existing method
		if (!validation.isValid) {
			return getOrganizationProcessesWorkItemTypes(organization, processId);
		}

		// Return filtered work item types that match UI expectations
		return validation.filteredWorkItemTypes;
	}

	/**
	 * Gets boards for a specific team in Azure DevOps.
	 * This method retrieves all boards available for the specified team.
	 * 
	 * @param organization The Azure DevOps organization ID
	 * @param projectId The Azure DevOps project ID
	 * @param teamId The Azure DevOps team ID
	 * @return List<AzureDevOpsBoardReference> List of boards available for the team
	 */
	public static List<AzureDevOpsBoardReference> getTeamBoards(String organization, String projectId, String teamId) {
		List<AzureDevOpsBoardReference> result = new List<AzureDevOpsBoardReference>();

		try {
			String endpoint = String.format(AZURE_DEVOPS_REST_API_BOARDS, new List<String>{organization, projectId, teamId});
			String response = HttpUtils.get(endpoint, 
				HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN), 200);

			// Parse the response - boards are returned in a wrapper object with 'value' property
			AzureDevOpsBoardWrapper wrapper = (AzureDevOpsBoardWrapper)JSON.deserialize(response, AzureDevOpsBoardWrapper.class);
			if (wrapper != null && wrapper.value != null) {
				result = wrapper.value;
			}
		} catch (Exception e) {}

		return result;
	}

	/**
	 * Remote action method to get Azure DevOps work item types with comprehensive validation.
	 * This method performs validation based on team settings, board configuration, and field requirements
	 * to return only work item types that are properly configured and accessible.
	 * 
	 * @param data A map containing the following parameters:
	 *             - projectId: The Azure DevOps project ID
	 *             - teamId: The Azure DevOps team ID (required)
	 *             - boardId: The Azure DevOps board ID (optional)
	 * @return List<AzureDevOpsProcessWorkItemType> Filtered list of work item types that pass validation
	 * @throws Exception Returns empty list on any error
	 */
	public static List<AzureDevOpsProcessWorkItemType> getAzureDevOpsWorkItemTypesWithValidation(Object data) {
		try {
			Map<String, Object> params = (Map<String, Object>)data;
			if (params == null) {
				return new List<AzureDevOpsProcessWorkItemType>();
			}

			Object projectIdObj = params.get(PARAM_PROJECT_ID);
			Object teamIdObj = params.get(PARAM_TEAM_ID);
			Object boardIdObj = params.get(PARAM_BOARD_ID);

			if (projectIdObj == null || teamIdObj == null) {
				return new List<AzureDevOpsProcessWorkItemType>();
			}

			String projectId = String.valueOf(projectIdObj);
			String teamId = String.valueOf(teamIdObj);

			// Extract board ID from object if needed
			String boardId = null;
			if (boardIdObj != null) {
				if (boardIdObj instanceof Map<String, Object>) {
					Map<String, Object> boardObj = (Map<String, Object>)boardIdObj;
					Object boardIdValue = boardObj.get(JSON_FIELD_ID);
					boardId = boardIdValue != null ? String.valueOf(boardIdValue) : null;
				} else {
					boardId = String.valueOf(boardIdObj);
				}
			}

			if (String.isBlank(projectId) || String.isBlank(teamId)) {
				return new List<AzureDevOpsProcessWorkItemType>();
			}

			// Get organization from settings
			String organization = ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c;
			if (String.isBlank(organization)) {
				return new List<AzureDevOpsProcessWorkItemType>();
			}

			// Get process ID for the project
			List<AzureDevOpsProjectProperty> projectProperties = getOrganizationProjectProperties(organization, projectId);
			String processId = null;
			for (AzureDevOpsProjectProperty prop : projectProperties) {
				if (prop.name == AZURE_DEVOPS_PROCESS_TEMPLATE_TYPE) {
					processId = prop.value;
					break;
				}
			}

			if (String.isBlank(processId)) {
				return new List<AzureDevOpsProcessWorkItemType>();
			}

			// Use the validation method with team and board parameters
			return getOrganizationProcessesWorkItemTypesWithValidation(organization, processId, projectId, teamId, boardId);

		} catch (Exception e) {
			return new List<AzureDevOpsProcessWorkItemType>();
		}
	}

	/**
	 * Remote action method to get team boards in Azure DevOps.
	 * This method is designed to be called from JavaScript/UI components.
	 * 
	 * @param ss A map containing the following parameters:
	 *           - projectId: The Azure DevOps project ID
	 *           - teamId: The Azure DevOps team ID
	 * @return List<AzureDevOpsBoardReference> List of boards available for the team
	 * @throws Exception Returns empty list on any error
	 */
	public static List<AzureDevOpsBoardReference> getTeamBoards(Object ss) {
		try {
			Map<String, Object> data = (Map<String, Object>)ss;
			if (data == null) {
				return new List<AzureDevOpsBoardReference>();
			}

			Object projectIdObj = data.get(PARAM_PROJECT_ID);
			Object teamIdObj = data.get(PARAM_TEAM_ID);

			if (projectIdObj == null || teamIdObj == null) {
				return new List<AzureDevOpsBoardReference>();
			}

			String projectId = String.valueOf(projectIdObj);
			String teamId = String.valueOf(teamIdObj);

			if (String.isBlank(projectId) || String.isBlank(teamId)) {
				return new List<AzureDevOpsBoardReference>();
			}

			// Get organization from settings
			String organization = ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c;
			if (String.isBlank(organization)) {
				return new List<AzureDevOpsBoardReference>();
			}

			return getTeamBoards(organization, projectId, teamId);
		} catch (Exception e) {
			return new List<AzureDevOpsBoardReference>();
		}
	}

	public class AzureDevOpsProjectPropertyWrapper {
		public Integer count;
		public List<AzureDevOpsProjectProperty> value;
	}

	public class AzureDevOpsProjectProperty {
		public String name;
		public String value;
	}

	public static List<AzureDevOpsProjectProperty> getOrganizationProjectProperties(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String projectId = (String)ss?.get('projectId');
		return getOrganizationProjectProperties(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId);
	}

	public static List<AzureDevOpsProjectProperty> getOrganizationProjectProperties(String organization, String projectId) {
		List<AzureDevOpsProjectProperty> result = new List<AzureDevOpsProjectProperty>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_PROJECT_PROPERTIES, new List<String>{organization, projectId});
		String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsProjectPropertyWrapper ow = (AzureDevOpsProjectPropertyWrapper)JSON.deserialize(b, AzureDevOpsProjectPropertyWrapper.class);
		result = ow.value;
		return result;
	}

	public class AzureDevOpsProcessWorkItemTypeFieldWrapper {
		public Integer count;
		public List<AzureDevOpsProcessWorkItemTypeField> value;
	}

	public class AzureDevOpsProcessWorkItemTypeField {
		public String name;
		public String referenceName;
		public String type;
		public Boolean required;
		public String defaultValue;
		public String url;
		public String customization;
	}

	public static List<AzureDevOpsProcessWorkItemTypeField> getOrganizationProcessWorkItemTypeFields(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String processId = (String)ss?.get('processId');
		String workItemTypeId = (String)ss?.get('workItemTypeId');
		return getOrganizationProcessWorkItemTypeFields(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, processId, workItemTypeId);
	}

	public static List<AzureDevOpsProcessWorkItemTypeField> getOrganizationProcessWorkItemTypeFields(String organization, String processId, String workItemTypeId) {
		List<AzureDevOpsProcessWorkItemTypeField> result = new List<AzureDevOpsProcessWorkItemTypeField>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_PROCESS_WORK_ITEM_TYPE_FIELDS, new List<String>{organization, processId, workItemTypeId});
		String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsProcessWorkItemTypeFieldWrapper ow = (AzureDevOpsProcessWorkItemTypeFieldWrapper)JSON.deserialize(b, AzureDevOpsProcessWorkItemTypeFieldWrapper.class);
		result = ow.value;
		return result;
	}

	

    public static AzureDevOpsMyProfile getMyProfile(String oAuthToken) {
		AzureDevOpsMyProfile result;

		String b = HttpUtils.get(
			AZURE_DEVOPS_REST_API_MY_PROFILE ,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + oAuthToken),
			200
		);
		AzureDevOpsMyProfile ow = (AzureDevOpsMyProfile)JSON.deserialize(b, AzureDevOpsMyProfile.class);
		result = ow;
		return result;
	}

    public static List<AzureDevOpsAccount> getAccountsByOwnerId(String ownerId, String oAuthToken) {
		List<AzureDevOpsAccount> result = new List<AzureDevOpsAccount>();

        String endpoint = AZURE_DEVOPS_REST_API_MY_ACCOUNTS + '?memberId='+ ownerId + '&'+ AZURE_DEVOPS_REST_API_VERSION;
		String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + oAuthToken),
			200
		);
		AzureDevOpsAccountWrapper ow = (AzureDevOpsAccountWrapper)JSON.deserialize(b, AzureDevOpsAccountWrapper.class);
		result = ow.value;
		return result;
	}

    public class AzureDevOpsMyProfile {
        public String displayName;
        public String publicAlias;
        public String emailAddress;
        public String id;
        public String timeStamp;
    }

    public class AzureDevOpsAccountWrapper {
        public Integer count;
        public List<AzureDevOpsAccount> value;
    }

    public class AzureDevOpsAccount {
        public String accountId;
        public String accountUri;
        public String accountName;
    }

	public static List<AzureDevOpsProject> getProjects(String organization) {
		List<AzureDevOpsProject> result = new List<AzureDevOpsProject>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_PROJECT, new List<String>{organization});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsProjectWrapper ow = (AzureDevOpsProjectWrapper)JSON.deserialize(b, AzureDevOpsProjectWrapper.class);
		result = ow.value;
		return result;
	}

	public class AzureDevOpsProjectWrapper {
        public Integer count;
        public List<AzureDevOpsProject> value;
    }

    public class AzureDevOpsProject {
        public String id;
        public String name;
        public String description;
		public String url;
		public String state;

    }

	public static List<AzureDevOpsWorkItemType> getWorkItemTypes(String organization, String project) {
		List<AzureDevOpsWorkItemType> result = new List<AzureDevOpsWorkItemType>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_TYPE, new List<String>{organization, EncodingUtil.urlEncode(project, 'UTF-8')});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsWorkItemTypeWrapper ow = (AzureDevOpsWorkItemTypeWrapper)JSON.deserialize(b, AzureDevOpsWorkItemTypeWrapper.class);
		result = ow.value;
		return result;
	}

	public class AzureDevOpsWorkItemTypeWrapper {
        public Integer count;
        public List<AzureDevOpsWorkItemType> value;
    }

    public class AzureDevOpsWorkItemType {
        public String name;
        public String referenceName;
        public String description;
		public Boolean isDisabled;
    }

	public static List<AzureDevOpsTeam> getProjectTeams(String organization, String projectId) {
		List<AzureDevOpsTeam> result = new List<AzureDevOpsTeam>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_TEAMS, new List<String>{organization, projectId});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsTeamWrapper ow = (AzureDevOpsTeamWrapper)JSON.deserialize(b, AzureDevOpsTeamWrapper.class);
		result = ow.value;
		return result;
	}

	public class AzureDevOpsTeamWrapper {
        public List<AzureDevOpsTeam> value;
    }

    public class AzureDevOpsTeam {
        public String id;
        public String name;
		public String url;
        public String description;
		public String identityUrl;
    }

	public class WorkItemClassificationNode {
        public List<WorkItemClassificationNode> children;
		public String name;
		public Boolean hasChildren;
		public Integer id;
    }

	public class WorkItemClassificationNodes {
		public WorkItemClassificationNode iterations;
		public WorkItemClassificationNode areas;
	}

	public static WorkItemClassificationNodes getClassificationNodes(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String projectId = (String)ss?.get('projectId');
		return getClassificationNodes(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId);
	}

    public static WorkItemClassificationNodes getClassificationNodes(String organization, String projectId) {
        String iterationsEndpoint = String.format(AZURE_DEVOPS_REST_API_ITERATION, new List<String>{organization, projectId, AZURE_DEVOPS_ITERATIONS});
        String areasEndpoint = String.format(AZURE_DEVOPS_REST_API_ITERATION, new List<String>{organization, projectId, AZURE_DEVOPS_AREAS});
        String iterationsB = HttpUtils.get(
            iterationsEndpoint,
            HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
            200
        );
		String areasB = HttpUtils.get(
            areasEndpoint,
            HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
            200
        );

        WorkItemClassificationNode iow = (WorkItemClassificationNode) JSON.deserialize(iterationsB, WorkItemClassificationNode.class);
        WorkItemClassificationNode aow = (WorkItemClassificationNode) JSON.deserialize(areasB, WorkItemClassificationNode.class);

		WorkItemClassificationNodes resp = new WorkItemClassificationNodes();
		resp.iterations = iow;
		resp.areas = aow;
        return resp;
    }

	public static List<AzureDevOpsTeamMember> getProjectTeamMembers(String organization, String projectId, String teamId) {
		return getProjectTeamMembers(organization, projectId, teamId, HTTP_SKIP_PARAMETER_DEFAULT_VALUE);
	}

	public static List<AzureDevOpsTeamMember> getProjectTeamMembers(String organization, String projectId, String teamId, String skip) {
		AzureDevOpsTeamMemberWrapper ow = getProjectTeamMemberWrapper(organization, projectId, teamId, skip);
		return ow.value;
	}

	public static List<AzureDevOpsProject> getProjects() {
		return getProjects(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c);
	}
	
	public static List<AzureDevOpsTeam> getProjectTeams(Object data) {
		try {
			Map<String, Object> ss = (Map<String, Object>)data;
			if (ss == null) {
				return new List<AzureDevOpsTeam>();
			}

			Object projectIdObj = ss.get('projectId');
			if (projectIdObj == null) {
				return new List<AzureDevOpsTeam>();
			}

			String projectId = String.valueOf(projectIdObj);
			if (String.isBlank(projectId)) {
				return new List<AzureDevOpsTeam>();
			}

			return getProjectTeams(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId);
		} catch (Exception e) {
			return new List<AzureDevOpsTeam>();
		}
	}

	public static AzureDevOpsTeamMemberWrapper getProjectTeamMemberWrapper(Object data) {
		try {
			Map<String, Object> ss = (Map<String, Object>)data;
			if (ss == null) {
				return new AzureDevOpsTeamMemberWrapper();
			}

			Object projectIdObj = ss.get('projectId');
			Object teamIdObj = ss.get('teamId');
			Object skipObj = ss.get('skip');

			String projectId = projectIdObj != null ? String.valueOf(projectIdObj) : null;
			String teamId = teamIdObj != null ? String.valueOf(teamIdObj) : null;
			String skip = skipObj != null ? String.valueOf(skipObj) : null;

			return getProjectTeamMemberWrapper(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId, teamId, skip);
		} catch (Exception e) {
			return new AzureDevOpsTeamMemberWrapper();
		}
	}

	public static List<AzureDevOpsWorkItemType> getWorkItemTypes(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String projectId = (String)ss?.get('projectId');
		return getWorkItemTypes(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId);
	}

	public static AzureDevOpsTeamMemberWrapper getProjectTeamMemberWrapper(String organization, String projectId, String teamId, String skip) {
		String endpoint = String.format(AZURE_DEVOPS_REST_API_TEAM_MEMBERS, new List<String>{organization, projectId, teamId});
		if(HTTP_SKIP_PARAMETER_DEFAULT_VALUE != skip) {
			endpoint += HTTP_SKIP_PARAMETER + '=' +skip;
		}
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsTeamMemberWrapper ow = (AzureDevOpsTeamMemberWrapper)JSON.deserialize(b, AzureDevOpsTeamMemberWrapper.class);
		return ow;
	}

	public class AzureDevOpsTeamMemberWrapper {
        public List<AzureDevOpsTeamMember> value;
		public Integer count;
    }

    public class AzureDevOpsTeamMember {
        public Boolean isTeamAdmin;
        public AzureDevOpsTeamMemberIdentity identity;
    }

	public class AzureDevOpsTeamMemberIdentity {
        public String id;
		public String displayName;
        public String uniqueName;
		public String url;
		public String imageUrl;
		public AzureDevOpsWorkItemReferenceLinks links;
    }

	public static final String WORK_ITEM_TYPE_FIELD_ASSIGNED_TO = 'System.AssignedTo';
	public static final String WORK_ITEM_TYPE_FIELD_TITLE = 'System.Title';
	public static final String WORK_ITEM_TYPE_FIELD_DESCRIPTION = 'System.Description';
	public static final String WORK_ITEM_TYPE_FIELD_PRIORITY = 'Microsoft.VSTS.Common.Priority';
	public static final String WORK_ITEM_TYPE_FIELD_TAG = 'System.Tags';
	public static final String WORK_ITEM_TYPE_FIELD_ITERATION = 'System.IterationPath';
	public static final String WORK_ITEM_TYPE_FIELD_AREA = 'System.AreaPath';
	public static final String WORK_ITEM_TYPE_FIELD_RELATED_LINK = 'System.LinkTypes.Related';
	public static final String WORK_ITEM_TYPE_FIELD_RELATED_CHILD_LINK = 'System.LinkTypes.Hierarchy-Forward';
	public static final String WORK_ITEM_TYPE_FIELD_RELATED_PARENT_LINK = 'System.LinkTypes.Hierarchy-Reverse';
	public static final String WOKR_ITEM_TYPE_FIELD_DUPLICATE_CHILD_LINK = 'System.LinkTypes.Duplicate-Forward';
	public static final String WOKR_ITEM_TYPE_FIELD_DUPLICATE_PARENT_LINK = 'System.LinkTypes.Duplicate-Reverse';

	public static final String WORK_ITEM_TYPE_OPERATION_ADD = 'add';
	public static final String WORK_ITEM_TYPE_OPERATION_COPY = 'copy';
	public static final String WORK_ITEM_TYPE_OPERATION_MOVE = 'move';
	public static final String WORK_ITEM_TYPE_OPERATION_REMOVE = 'remove';
	public static final String WORK_ITEM_TYPE_OPERATION_REPLACE = 'replace';

	public static final String WOKR_ITEM_REQUEST_PATH_FIELDS = '/fields/';
	public static final String WOKR_ITEM_REQUEST_PATH_RELATIONS = '/relations/-';
	public static final String WOKR_ITEM_REQUEST_PATH_RELATION = '/relations/';

	public class AzureDevOpsWorkItemRequestBody {
		public String op;
		public String path;
		public Object value;

		public AzureDevOpsWorkItemRequestBody(String op, String path, Object value) {
			this.op = op;
			this.path = path;
			this.value = value;
		}
	}

	public static Map<String, DateTime> getResolutionDatetimeByWorkItemId(String organization, String projectId, List<String> workItemIds, Logger logger) {
        Map<String, DateTime> result = new Map<String, DateTime>();

        List<AzureDevOpsWorkItem> projectWorkItemList = getProjectWorkItemList(organization, projectId, workItemIds);
        if(!projectWorkItemList?.isEmpty()) {
            for(AzureDevOpsWorkItem workItem : projectWorkItemList) {
                try {
					if(String.isNotBlank(workItem?.fields?.ClosedDate)) {
						DateTime resolutionDatetime = AzureService.parseAzureDevOpsDateTime(workItem?.fields?.ClosedDate, logger);
						result.put(workItem.id, resolutionDatetime);
					}
                }
                catch(Exception e) {
                    logger?.add(logger.getInternalError(e, null, AzureService.class.getName(), 'getResolutionDatetimeByWorkItemId'));
                }
            }
        }
        return result;
    }

	public static List<AzureDevOpsWorkItem> getProjectWorkItemList(String organization, String projectId, List<String> workItemIds) {
		List<AzureDevOpsWorkItem> result = new List<AzureDevOpsWorkItem>();

		String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_LIST, new List<String>{organization, projectId, String.join(workItemIds, ',')});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsWorkItemWrapper ow = (AzureDevOpsWorkItemWrapper)JSON.deserialize(replaceSystemField(b), AzureDevOpsWorkItemWrapper.class);
		result = ow.value;
		return result;
	}

	public static AzureDevOpsWorkItem getProjectWorkItem(String organization, String projectId, String workItemId) {
		AzureDevOpsWorkItem result;

		String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_ID_EXPAND_ALL, new List<String>{organization, projectId, workItemId});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsWorkItem ow = (AzureDevOpsWorkItem)JSON.deserialize(replaceSystemField(b), AzureDevOpsWorkItem.class);
		result = ow;
		return result;
	}

	public static AzureDevOpsWorkItemCommentsWrap getProjectWorkItemComments(String organization, String projectId, String workItemId) {
		AzureDevOpsWorkItemCommentsWrap result;

		String endpoint = String.format(AzureApiClient.AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENTS, new List<String>{organization, projectId, workItemId});
        String b = HttpUtils.get(
			endpoint,
			HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
			200
		);
		AzureDevOpsWorkItemCommentsWrap wic = (AzureDevOpsWorkItemCommentsWrap)JSON.deserialize(replaceSystemField(b), AzureDevOpsWorkItemCommentsWrap.class);
		result = wic;
		return result;
	}

	public static AzureDevOpsWorkItem updateWorkItemPriority(String organization, String projectId, String workItemId, String priority) {
		List<AzureService.AzureDevOpsWorkItemRequestBody> workItemRequest = new List<AzureService.AzureDevOpsWorkItemRequestBody>();
		workItemRequest.add(new AzureService.AzureDevOpsWorkItemRequestBody(
			AzureService.WORK_ITEM_TYPE_OPERATION_ADD, '/fields/' + AzureService.WORK_ITEM_TYPE_FIELD_PRIORITY, Integer.valueOf(priority))
		);
		return updateProjectWorkItem(organization, projectId, workItemId, workItemRequest);
	}

	public static AzureDevOpsWorkItem updateProjectWorkItem(String organization, String projectId, String workItemId, List<AzureService.AzureDevOpsWorkItemRequestBody> workItemRequest) {
		AzureDevOpsWorkItem result;

		Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN);
		headers.putAll(HttpUtils.getHeadersContentTypeJSONPatch());
		String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_ID, new List<String>{organization, projectId, workItemId});
        String b = HttpUtils.patch(
			endpoint,
			JSON.serialize(workItemRequest),
			headers,
			200
		);
		AzureService.AzureDevOpsWorkItem updatedWorkItem = (AzureService.AzureDevOpsWorkItem)JSON.deserialize(AzureService.replaceSystemField(b), AzureService.AzureDevOpsWorkItem.class);
		result = updatedWorkItem;
		return result;
	}

	public static String replaceSystemField(String inputJSON) {
        return inputJSON.replace('System.','').replace('Microsoft.VSTS.Common.', '').replace('Microsoft.VSTS.Scheduling.', '').replace('_links', 'links');
    }

	public class AzureDevOpsWorkItemWrapper {
        public Integer count;
        public List<AzureDevOpsWorkItem> value;
    }
	
	public class AzureDevOpsWorkItem {
		public String id;
		public Integer rev;
		public AzureDevOpsWorkItemFields fields;
		public AzureDevOpsWorkItemReferenceLinks links;
		public List<AzureDevOpsWorkItemRelation> relations;
		public String url;
		public String organizationName;
	}

	public class AzureDevOpsWorkItemRelation {
		public String rel;
		public String url;
	}

	public class AzureDevOpsWorkItemCommentsWrap {
		public Integer totalCount;
		public Integer count;
		public List<AzureDevOpsWorkItemComment> comments;
	}

	public class AzureDevOpsWorkItemComment {
		public Integer workItemId;
		public String id;
		public String text;
		public AzureDevOpsTeamMemberIdentity createdBy;
	}

	public class AzureDevOpsWorkItemReferenceLinks {
		public AzureDevOpsWorkItemReferenceLink self;
		public AzureDevOpsWorkItemReferenceLink workItemComments;
		public AzureDevOpsWorkItemReferenceLink avatar;
		public AzureDevOpsWorkItemReferenceLink html;
	}

	public class AzureDevOpsWorkItemReferenceLink {
		public String href;
	}

	public class AzureDevOpsWorkItemFields {
		public String AreaPath;
		public String TeamProject;
		public String IterationPath;
		public String WorkItemType;
		public String State;
		public String Reason;
		public String CreatedDate;
		public String ChangedDate;
		public Integer CommentCount;
		public String Title;
		public String BoardColumn;
		public Boolean BoardColumnDone;

		public String StateChangeDate;
		public String ClosedDate;
		public String Priority;
		public String Description;
		public Integer Parent;
		public String Tags;
		public String StartDate;
		public String TargetDate;
		public AzureDevOpsTeamMemberIdentity CreatedBy;
	}

	// https://dev.azure.com/pharos-ai/Test%20Project/_workitems/edit/5
	// ["https:","","dev.azure.com","pharos-ai","Test%20Project","_workitems","edit","5"]
	// https://dev.azure.com/pharos-ai/4bba36f1-8657-4c67-8978-259734a3d2f1/_apis/wit/workItems/245
	// (https:, , dev.azure.com, pharos-ai, 4bba36f1-8657-4c67-8978-259734a3d2f1, _apis, wit, workItems, 245)
	public class WorkItemUrlParser {
		public String organizationName;
		public String projectIdOrName;
		public String workItemId;

		public WorkItemUrlParser(String url) {
			if(String.isNotBlank(url)) {
				List<String> parts = url.split('/');
				if(parts.size() == 8) {
					this.organizationName = parts.get(3);
					this.projectIdOrName = parts.get(4);
					this.workItemId = parts.get(7);
				}
				if(parts.size() == 9) {
					this.organizationName = parts.get(3);
					this.projectIdOrName = parts.get(4);
					this.workItemId = parts.get(8);
				}
			}
		}
	}

	public class AzureDevOpsWorkItemQueryResult {
		public String queryType;
		public String asOf;
		public List<AzureDevOpsWorkItemReference> workItems;
	}

	public class AzureDevOpsWorkItemReference {
		public String id;
		public String url;
	}

	public class AzureDevOpsWIQLRequestBody {
		public String query;
		
		public AzureDevOpsWIQLRequestBody(String query) {
			this.query = query;
		}
	}

	//Select [System.Id], [System.Title], [System.State] From WorkItems Where [Tags] Contains 'tag1' OR [Tags] Contains 'tag2'
	public static String getWIQLRequestSelectWorkItemsByTags(List<String> tags) {
		String q = 'Select [System.Id], [System.Title], [System.State] From WorkItems Where ';
		List<String> whereParts = new List<String>();
		for(String tag : tags) {
			whereParts.add('[Tags] Contains \'' + tag + '\'');
		}
		return (q + String.join(whereParts, ' OR '));
	}

	//"Select [System.Id], [System.Title], [System.State] From WorkItems Where [System.WorkItemType] = 'Epic'" AND [System.Title] = 'Production Issues'"
	public static String getWIQLRequestSelectEpicWorkItems(String title) {
		String q = 'Select [System.Id], [System.Title], [System.State] From WorkItems Where [System.WorkItemType] = \'Epic\'';
		if(String.isNotBlank(title)) {
			q += ' AND [System.Title] = \'' + title + '\'';
		}
		return q;
	}

	public static AzureDevOpsWorkItemQueryResult queryByWIQL(String organization, String projectId, String query) {
		AzureDevOpsWorkItemQueryResult result;
		String endpoint = String.format(AZURE_DEVOPS_REST_API_WIQL, new List<String>{organization, projectId});
		Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN);
		headers.putAll(HttpUtils.getHeadersContentTypeJSON());
		AzureDevOpsWIQLRequestBody WIQLRequest = new AzureDevOpsWIQLRequestBody(query);

        String b = HttpUtils.post(
			endpoint,
			JSON.serialize(WIQLRequest),
			headers,
			200
		);
		result = (AzureDevOpsWorkItemQueryResult)JSON.deserialize(replaceSystemField(b), AzureDevOpsWorkItemQueryResult.class);
		return result;
	}

	public static List<AzureDevOpsWorkItemReference> searchEpics(Object data) {
		Map<String, Object> ss = (Map<String, Object>)data;
		String projectId = (String)ss?.get('projectId');
		String title = ss?.get('title') != null ? (String)ss?.get('title') : null;

		String epicsQuery = AzureService.getWIQLRequestSelectEpicWorkItems(title);
		AzureService.AzureDevOpsWorkItemQueryResult epicsResults = AzureService.queryByWIQL(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c, projectId, epicsQuery);
		return epicsResults.workItems;
	}

	// "2023-04-13T19:03:25.153Z"
    public static final Pattern JIRA_DATE_TIME_PATTERN = Pattern.compile('(?i)(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2}).(\\d{2,3})Z');

    public static DateTime parseAzureDevOpsDateTime(String dateTimeString, Logger logger) {
        DateTime result = null;
		if(String.isBlank(dateTimeString)) return null;

        try {
            Pattern dt = JIRA_DATE_TIME_PATTERN;
            Matcher m = dt.matcher(dateTimeString);
            if (m.find()) {
                Integer year = Integer.valueOf(m.group(1));
                Integer month = Integer.valueOf(m.group(2));
                Integer day = Integer.valueOf(m.group(3));
                Integer hour = Integer.valueOf(m.group(4));
                Integer minute = Integer.valueOf(m.group(5));
                Integer second = Integer.valueOf(m.group(6));
                Integer mills = Integer.valueOf(m.group(7));

                result = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
            }
        }
        catch(Exception e) {
            logger?.add(logger.getInternalError(e, null, AzureService.class.getName(), 'parseAzureDevOpsDateTime'));
        }
        return result;
    }

	/**
	 * Configuration validation result class
	 */
	public class AzureDevOpsConfigurationValidationResult {
		public Boolean isValid;
		public Boolean hasTeamAccess;
		public Boolean hasBoardConfiguration;
		public Boolean hasRequiredFields;
		public Integer totalWorkItemTypes;
		public Integer filteredWorkItemTypeCount;
		public List<AzureDevOpsProcessWorkItemType> filteredWorkItemTypes;
		public AzureDevOpsTeamAccessValidation teamAccessValidation;
		public AzureDevOpsBoardConfigurationValidation boardConfigurationValidation;
	}

	/**
	 * Team access validation result class
	 */
	public class AzureDevOpsTeamAccessValidation {
		public Boolean isValid;
		public String bugsBehavior;
	}

	/**
	 * Board configuration validation result class
	 */
	public class AzureDevOpsBoardConfigurationValidation {
		public Boolean isValid;
		public List<String> allowedWorkItemTypes;
		public String boardName;
	}

	/**
	 * Board reference class matching Microsoft API response format
	 * Based on: https://learn.microsoft.com/en-us/rest/api/azure/devops/work/boards/list?view=azure-devops-rest-7.1#boardreference
	 */
	public class AzureDevOpsBoardReference {
		public String id;
		public String name;
		public String url;
	}

	/**
	 * Board wrapper class for API response
	 */
	public class AzureDevOpsBoardWrapper {
		public List<AzureDevOpsBoardReference> value;
	}

}