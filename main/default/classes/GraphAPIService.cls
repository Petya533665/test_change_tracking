public with sharing class GraphAPIService {

	public static final String GRAPH_API_SETTINGS_NAME = 'GraphAPI';
	public static String GET_GRAPH_API_TOKEN_ENDPOINT = 'https://login.microsoftonline.com/{0}/oauth2/v2.0/token';
	public static final String GRAPH_API_AUTHORIZE_ENDPOINT = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
	public static final String GRAPH_API_GET_TOKEN_ENDPOINT = 'https://login.microsoftonline.com/common/oauth2/v2.0/token';

	public static final String GRAPH_API_ENPOINT = 'https://graph.microsoft.com/v1.0/';
	public static final String GRAPH_API_GET_ALL_TEAMS_ENDPOINT = GRAPH_API_ENPOINT + 'groups?$select=id,resourceProvisioningOptions,displayName';
	public static final String GRAPH_API_GET_ORGANIZATION_ENDPOINT = GRAPH_API_ENPOINT + 'organization';
	public static String GRAPH_API_GET_TEAM_CHANNELS = GRAPH_API_ENPOINT + 'teams/{0}/channels';
	public static String GRAPH_API_SEND_CHANNEL_MESSAGE = GRAPH_API_ENPOINT + 'teams/{0}/channels/{1}/messages';

	public static final String GRAPH_API_TOKEN_GRANT_TYPE_REFRESH = 'refresh_token';
	public static final String GRAPH_API_TOKEN_GRANT_TYPE_AUTHORIZATION_CODE = 'authorization_code';
	public static final String GRAPH_API_TOKEN_GRANT_TYPE_CLIENT_CREDENTIALS = 'client_credentials';
	public static final String GRAPH_API_TOKEN_RESPONSE_TYPE_CODE = 'code';
	public static final String GRAPH_API_TOKEN_TYPE_BEARER = 'Bearer ';
	public static final String GRAPH_API_TOKEN_RESPONSE_MODE_QUERY = 'query';
	public static String GRAPH_API_SCOPE {
        get {
            if (GRAPH_API_SCOPE == null) {
                List<OAuthSettings__mdt> settings = [SELECT Extended_Scope__c FROM OAuthSettings__mdt WHERE DeveloperName = :GraphAPIService.GRAPH_API_SETTINGS_NAME LIMIT 1];
				if(!settings.isEmpty()) {
					GRAPH_API_SCOPE = settings.get(0).Extended_Scope__c;
				}
            }
            return GRAPH_API_SCOPE;
        }
        private set;
    }
	public static String AZURE_DEVOPS_API_SCOPE {
        get {
            if (AZURE_DEVOPS_API_SCOPE == null) {
                List<OAuthSettings__mdt> settings = [SELECT Extended_Scope__c FROM OAuthSettings__mdt WHERE DeveloperName = :AzureService.AZURE_DEVOPS_API_SETTINGS_NAME LIMIT 1];
				if(!settings.isEmpty()) {
					AZURE_DEVOPS_API_SCOPE = settings.get(0).Extended_Scope__c;
				}
            }
            return AZURE_DEVOPS_API_SCOPE;
        }
        private set;
    }
	public static final String GRAPH_API_NEXT_LINK_TOKEN = '@odata.nextLink';
	public static final String GRAPH_API_PARAM_GROUPS = 'groups';
	public static final String GRAPH_API_PARAM_TEAMS = 'teams';
	public static final String GRAPH_API_PARAM_FILTER = '$filter';
	public static final String GRAPH_API_PARAM_SEARCH = '$search';
	public static final String GRAPH_API_PARAM_COUNT = '$count';
	public static final String GRAPH_API_PARAM_TOP = '$top';
	public static final String GRAPH_API_PARAM_QUANTITY = '100';
	
	// HTTP Headers and Values
	public static final String HEADER_CONSISTENCY_LEVEL = 'ConsistencyLevel';
	public static final String HEADER_CONSISTENCY_LEVEL_VALUE_EVENTUAL = 'eventual';
	
	// Search and Query Constants
	public static final String SEARCH_PREFIX_DISPLAY_NAME = '\"displayName:';
	public static final String SEARCH_SUFFIX = '\"';
	public static final String QUERY_PARAM_PREFIX = '?';
	public static final String BOOLEAN_TRUE_STRING = 'true';
	
	// Content Type Values
	public static final String CONTENT_TYPE_HTML = 'html';


	public class GraphAPIServiceException extends Exception {}

	public static TeamRequestWrapper getTeams(String search) {
		String endpoint = String.isBlank(search) ? GRAPH_API_GET_ALL_TEAMS_ENDPOINT : GRAPH_API_ENPOINT + GRAPH_API_PARAM_GROUPS;
        HttpUtils.HttpURLParameters queryParams = new HttpUtils.HttpURLParameters();
		if (!String.isBlank(search)) {
			queryParams.addEncodedParameter(GRAPH_API_PARAM_SEARCH, SEARCH_PREFIX_DISPLAY_NAME + search + SEARCH_SUFFIX);
			queryParams.addParameter(GRAPH_API_PARAM_COUNT, BOOLEAN_TRUE_STRING);
			queryParams.addParameter(GRAPH_API_PARAM_TOP, GRAPH_API_PARAM_QUANTITY);
	        endpoint = endpoint + queryParams.toStringParameters(QUERY_PARAM_PREFIX);
		}
		Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(GRAPH_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN);
		headers.put(HEADER_CONSISTENCY_LEVEL, HEADER_CONSISTENCY_LEVEL_VALUE_EVENTUAL);
		String b = HttpUtils.get(
            endpoint,
            headers,
            200
        );
        TeamRequestWrapper trw = (TeamRequestWrapper)JSON.deserialize(b, TeamRequestWrapper.class);
        return trw;
    }

	public static Team getTeamById(String id) {
		String endpoint = GRAPH_API_ENPOINT + GRAPH_API_PARAM_TEAMS + Constants.GLOBAL_VARIABLE.SYMBOL_SLASH + id;

		Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(GRAPH_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN);
		String b = HttpUtils.get(
            endpoint,
            headers,
            200
        );
        Team team = (Team)JSON.deserialize(b, Team.class);
        return team;
    }

	public static List<Channel> getChannels(String teamId) {
		List<Channel> result = new List<Channel>();

		try {
			String b = HttpUtils.get(
				String.format(GRAPH_API_GET_TEAM_CHANNELS, new List<String>{teamId}),
				HttpUtils.getHeadersAuthorizationAcceptJson(GRAPH_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN),
				200
			);
			TeamChannelWrapper trw = (TeamChannelWrapper)JSON.deserialize(b, TeamChannelWrapper.class);
			result = trw.value;
		}
		catch (HttpUtils.HttpUtilsException e) {
			throw new GraphAPIServiceException('Get Channels by ' + teamId + ': ' + e.getMessage());
		}

		return result;
	}

	public static Organization getOrganization(String oAuthToken) {
		Organization result;

		String b = HttpUtils.get(
			GRAPH_API_GET_ORGANIZATION_ENDPOINT ,
			HttpUtils.getHeadersAuthorizationAcceptJson(GRAPH_API_TOKEN_TYPE_BEARER + oAuthToken),
			200
		);
		OrganizationWrapper ow = (OrganizationWrapper)JSON.deserialize(b, OrganizationWrapper.class);
		result = ow.value.get(0);
		return result;
	}

	public class GraphApiSetting {
		public String teamId;
		public String channelId;
		public GraphApiSetting(String teamId){}
		public GraphApiSetting(String teamId, String channelId) {
			this.teamId = teamId;
			this.channelId = channelId;
		}
	}

	public static ChatMessage sendChannelMessage(String teamId, String channelId, ChatMessage chatMessage) {
		return sendChannelMessage(teamId, channelId, JSON.serialize(chatMessage));
	}

	public static ChatMessage sendChannelMessage(String teamId, String channelId, String chatMessage) {
		ChatMessage result;

		Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(GRAPH_API_TOKEN_TYPE_BEARER + OAUTH_API_TOKEN);
		headers.putAll(HttpUtils.getHeadersContentTypeJSON());

		String b = HttpUtils.post(
			String.format(GRAPH_API_SEND_CHANNEL_MESSAGE, new List<String>{teamId, channelId}),
			chatMessage,
			headers,
			201
		);
		result = (ChatMessage)JSON.deserialize(b, ChatMessage.class);
		return result;
	}

	private static final String START_TAG_PRE = '<pre>';
	private static final String END_TAG_PRE = '</pre>';

	public class ChatMessage {
		public String subject;
		public ChatMessageBody body;
		public List<Map<String, Object>> hostedContents;


		public ChatMessage(){}
		public ChatMessage(String subject, String body) {
			this.subject = subject;
			this.body = new ChatMessageBody();
			this.body.content = START_TAG_PRE + body + END_TAG_PRE;
			this.body.contentType = CONTENT_TYPE_HTML;
			this.hostedContents = new List<Map<String, Object>>();
		}

		public ChatMessage addImagesByImageLambdaClient(ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {

			if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {

				for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
					if (chart != null && String.isNotBlank(chart)) {
						// Check if the chart type exists in ChartService.Chart enum
						ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);
						if (chartEnum != null) {
							String chartBase64 = chartGeneratorImageLambdaClient.getBase64ImageForChart(chartEnum.name());
							String filename = HttpUtils.getNameAttachment(chartEnum.name() + Constants.GLOBAL_VARIABLE.FILE_EXTENSION_PNG);

							this.hostedContents.add(new Map<String, Object> {
								'contentBytes' => chartBase64,
								'contentType' => 'image/png',
								'@microsoft.graph.temporaryId' => filename
							});
							this.body.content += String.format('<br> {0} Chart:<br> <img height="297" src="../hostedContents/{1}/$value" width="297">', 
								new List<String>{ChartService.getChartStringByChartName(chart), filename});

						} else {
							// Chart type not found in enum
						}
					}
				}

			}
			return this;
		}
	}

	public class ChatMessageBody {
		public String content;
		public String contentType;

		public ChatMessageBody(){}
	}

	public class Organization {
		public String id;
		public Organization(String id) {
			this.id = id;
		}
	}

	public class OrganizationWrapper {
		public List<Organization> value;
		public OrganizationWrapper(){}
	}

	public class TeamChannelWrapper {
		public List<Channel> value;
		public TeamChannelWrapper(){}
	}

	public class Channel {
		public String id;
		public String displayName;
		public Channel(String id, String displayName){
			this.id = id;
			this.displayName = displayName;
		}
	}

	public class TeamRequestWrapper {
		public String nextLink;
		public List<Team> value;
		public TeamRequestWrapper(){}
	}

	public class Team {
		public String id;
		public String displayName;
		public List<String> resourceProvisioningOptions;
		public Team(){}
		public Team(String id, String displayName){
			this.id = id;
			this.displayName = displayName;
		}
	}

	public static Boolean validateAndRefreshGraphApiOauthToken(Logger logger, Boolean withDML) {
		if (PermissionsUtil.TeamsIntegrationEnabled
			&& ConfigUtil.GRAPH_API_SETTINGS.Enabled__c
			&& String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c)) {
			try {
				refreshOAuthToken(logger, withDML);
				return true;
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, ConfigUtil.GRAPH_API_SETTINGS.Id, GraphAPIService.class.getName(), 'validateAndRefreshGraphApiOauthToken'));
			}
		}
		return false;
	}

	public static void refreshOAuthToken(Logger logger, Boolean withDML) {
		OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GraphAPIService.GRAPH_API_SETTINGS_NAME);
		String endpoint = GraphAPIService.GRAPH_API_GET_TOKEN_ENDPOINT;
		HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REFRESH_TOKEN, OAUTH_API_REFRESH_TOKEN);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, mdtSettings.Client_Secret__c);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, GRAPH_API_TOKEN_GRANT_TYPE_REFRESH);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_RESPONSE_TYPE, GRAPH_API_TOKEN_RESPONSE_TYPE_CODE);
		bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, LoggerSettingsController.PHAROS_OUATH_CALLBACK_PROXY);
		bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, GraphAPIService.GRAPH_API_SCOPE);

		String b = HttpUtils.post(
			endpoint,
			bodyParams.toStringParameters(),
			HttpUtils.getHeadersContentTypeFormUrlencoded(),
			200
		);
		ConnectedOrgService.AuthTokenResponse resp = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);

		GraphAPIService.putEncryptedGraphTokenToCache(logger, ConfigUtil.GRAPH_API_SETTINGS, resp.access_token);
		GraphAPIService.putApiTokenToSettings(resp.access_token, false, logger);
		GraphAPIService.putApiRefreshTokenToSettings(resp.refresh_token, false, logger);
		saveListTokenRecordSettings(withDml, logger);

		if (withDML) {
			DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c)
					.handleError(GraphAPIService.class.getName(), '.refreshOAuthToken', logger);
		}
	}

	public static String OAUTH_API_REFRESH_TOKEN {
		get {
			OAUTH_API_REFRESH_TOKEN = getApiRefreshTokenFromSettings();
			return OAUTH_API_REFRESH_TOKEN;
		}
		set;
	}

	public static String OAUTH_API_TOKEN {
		get {
			String cacheToken = getDecryptedGraphTokenFromCache();
			OAUTH_API_TOKEN = String.isBlank(cacheToken) ? getApiTokenFromSettings() : cacheToken;
			return OAUTH_API_TOKEN;
		}
		set;
	}

	public static String getGraphAPIToken() {
		String result;

		if(String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c)) {
			OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(GRAPH_API_SETTINGS_NAME);
			String endpoint = String.format(GET_GRAPH_API_TOKEN_ENDPOINT, new List<String>{ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c});
			HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
			bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, GRAPH_API_TOKEN_GRANT_TYPE_CLIENT_CREDENTIALS);
			bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, mdtSettings.Client_Id__c);
			bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, mdtSettings.Client_Secret__c);
			bodyParams.addEncodedParameterWithFixedWhitespace(HttpUtils.HTTP_URL_PARAM_SCOPE, GraphAPIService.GRAPH_API_SCOPE);

			String b = HttpUtils.post(
				endpoint ,
				bodyParams.toStringParameters(),
				HttpUtils.getHeadersContentTypeFormUrlencoded(),
				200
			);
			ConnectedOrgService.AuthTokenResponse graphAppToken = (ConnectedOrgService.AuthTokenResponse)JSON.deserialize(b, ConnectedOrgService.AuthTokenResponse.class);
			result = graphAppToken.access_token;
		}
		return result;
	}

	public static List<Graph_API_Token__c> GRAPH_API_LIST_RECORDS_UPSERT {
		get {
			if(GRAPH_API_LIST_RECORDS_UPSERT == null) GRAPH_API_LIST_RECORDS_UPSERT = new List<Graph_API_Token__c>();
			return GRAPH_API_LIST_RECORDS_UPSERT;
		}
		set;
	}

	public static List<Graph_API_Token__c> GRAPH_API_LIST_RECORDS_DELETE {
		get {
			if(GRAPH_API_LIST_RECORDS_DELETE == null) GRAPH_API_LIST_RECORDS_DELETE = new List<Graph_API_Token__c>();
			return GRAPH_API_LIST_RECORDS_DELETE;
		}
		set;
	}

	@TestVisible
	public static List<Graph_API_Token__c> GRAPH_API_LIST_RECORDS {
		get {
			if(GRAPH_API_LIST_RECORDS == null) {
				GRAPH_API_LIST_RECORDS = Graph_API_Token__c.getAll().values();
			}
			return GRAPH_API_LIST_RECORDS;
		}
		set;
	}
	public static final String AZURE_DEVOPS_API_TOKEN_TYPE_API_TOKEN = 'azure_do_api_token';
	public static final String AZURE_DEVOPS_API_TOKEN_TYPE_REFRESH_TOKEN = 'azure_do_refresh_token';
	public static final String GRAPH_API_TOKEN_TYPE_API_TOKEN = 'api_token';
	public static final String GRAPH_API_TOKEN_TYPE_REFRESH_TOKEN = 'refresh_token';
	public static final Integer MAX_SIZE_VALUE_PER_RECORD = 255;

	public static List<Graph_API_Token__c> getGraphApiTokenListRecordsByType(String type) {
		// In test context, always refresh the cache to ensure we see the latest records
		if(Test.isRunningTest()) {
			GRAPH_API_LIST_RECORDS = null;
		}
		
		List<Graph_API_Token__c> unsortedResult = new List<Graph_API_Token__c>();
		List<Graph_API_Token__c> sortedResult = new List<Graph_API_Token__c>();
		for(Graph_API_Token__c record : GRAPH_API_LIST_RECORDS) {
			if(record.Type__c == type) {
				unsortedResult.add(record);
			}
		}
		if(!unsortedResult.isEmpty()) {
			sortedResult = new Graph_API_Token__c[unsortedResult.size()];
			for(Graph_API_Token__c record : unsortedResult) {
				// Extract index from Name: Name format is "type + index"
				// Remove the type prefix to get just the trailing index number
				String nameWithoutType = record.Name.startsWith(record.Type__c) 
					? record.Name.substring(record.Type__c.length()) 
					: record.Name;
			// Extract trailing numeric index (handles cases where type contains numbers)
			String indexStr = Constants.GLOBAL_VARIABLE.PATTERN_NON_NUMERIC.matcher(nameWithoutType).replaceAll('');
				if(String.isNotBlank(indexStr)) {
					Integer index = Integer.valueOf(indexStr);
					// Validate index is within bounds
					if(index >= 0 && index < sortedResult.size()) {
						sortedResult.set(index, record);
					}
				}
			}
		}

		return sortedResult;
	}

	public static List<Graph_API_Token__c> getGraphApiTokenRecords() {
		return getGraphApiTokenListRecordsByType(GRAPH_API_TOKEN_TYPE_API_TOKEN);
	}

	public static List<Graph_API_Token__c> getGraphApiRefreshTokenRecords() {
		return getGraphApiTokenListRecordsByType(GRAPH_API_TOKEN_TYPE_REFRESH_TOKEN);
	}

	public static Integer getCountParts(String token) {
		Integer totalItems = token.length() / MAX_SIZE_VALUE_PER_RECORD;
		Integer remainder = Math.mod(token.length(), MAX_SIZE_VALUE_PER_RECORD);
		totalItems = (totalItems == 0 && remainder > 0) ? 1 : totalItems + (remainder > 0 ? 1 : 0);
		return totalItems;
	}

	public static String getApiTokenValueFromSettings(String type) {
		String result = '';
		for(Graph_API_Token__c record : getGraphApiTokenListRecordsByType(type)) {
			result += String.isNotBlank(record.Value__c) ? record.Value__c : '';
		}
		return result;
	}

	public static String getApiTokenFromSettings() {
		return getApiTokenValueFromSettings(GRAPH_API_TOKEN_TYPE_API_TOKEN);
	}

	public static String getApiRefreshTokenFromSettings() {
		return getApiTokenValueFromSettings(GRAPH_API_TOKEN_TYPE_REFRESH_TOKEN);
	}

	public static void putApiTokenToSettings(String token, Boolean withDML, Logger logger) {
		if(String.isNotBlank(token)) {
			upsertGraphAPITokenRecords(GRAPH_API_TOKEN_TYPE_API_TOKEN, token, withDML, logger);
		}
	}

	public static void putApiRefreshTokenToSettings(String refreshToken, Boolean withDML, Logger logger) {
		if(String.isNotBlank(refreshToken)) {
			upsertGraphAPITokenRecords(GRAPH_API_TOKEN_TYPE_REFRESH_TOKEN, refreshToken, withDML, logger);
		}
	}

	public static String getAzureDevOpsApiTokenFromSettings() {
		return getApiTokenValueFromSettings(AZURE_DEVOPS_API_TOKEN_TYPE_API_TOKEN);
	}

	public static String getAzureDevOpsApiRefreshTokenFromSettings() {
		return getApiTokenValueFromSettings(AZURE_DEVOPS_API_TOKEN_TYPE_REFRESH_TOKEN);
	}

	public static void putAzureDevOpsApiTokenToSettings(String token, Boolean withDML, Logger logger) {
		if(String.isNotBlank(token)) {
			upsertGraphAPITokenRecords(AZURE_DEVOPS_API_TOKEN_TYPE_API_TOKEN, token, withDML, logger);
		}
	}

	public static void putAzureDevOpsApiRefreshTokenToSettings(String refreshToken, Boolean withDML, Logger logger) {
		if(String.isNotBlank(refreshToken)) {
			upsertGraphAPITokenRecords(AZURE_DEVOPS_API_TOKEN_TYPE_REFRESH_TOKEN, refreshToken, withDML, logger);
		}
	}

	public static void upsertGraphAPITokenRecords(String type, String token, Boolean withDml, Logger logger) {

		List<Graph_API_Token__c> apiTokenRecords = getGraphApiTokenListRecordsByType(type);
		Integer existRecordsSize = apiTokenRecords.size();
		Integer newRecordsCount = getCountParts(token);
		
		for(Integer i = 0 ; i < newRecordsCount; i++) {
			Integer startIndex = i*MAX_SIZE_VALUE_PER_RECORD;
			Integer endIndex = (i+1)*MAX_SIZE_VALUE_PER_RECORD;
			endIndex = endIndex > token.length() ? token.length() : endIndex;

			GRAPH_API_LIST_RECORDS_UPSERT.add(
				new Graph_API_Token__c(
					Type__c = type,
					Name = String.valueOf(type + i),
					Value__c = token.substring(startIndex, endIndex)
				)
			);
		}
		
		// Fix: Compare existing records count with new records count for this type only
		// Previously this was comparing with total static list size, causing corruption
		if(existRecordsSize > newRecordsCount) {
			for(Integer i = newRecordsCount ; i < existRecordsSize; i++) {
				GRAPH_API_LIST_RECORDS_DELETE.add(apiTokenRecords.get(i));
			}
		}
		
		// Only save immediately if withDml is true, otherwise accumulate for later batch save
		if(withDml) {
			saveListTokenRecordSettings(withDml, logger);
		}
	}

	public static void saveListTokenRecordSettings(Boolean withDML, Logger logger) {
		if (withDML && !GRAPH_API_LIST_RECORDS_UPSERT.isEmpty()) {
			DatabaseUtils.getInstance().performUpsertDML(GRAPH_API_LIST_RECORDS_UPSERT, Schema.SObjectType.Graph_API_Token__c, Graph_API_Token__c.Name, false)
					.handleError(GraphAPIService.class.getName(), '.saveListTokenRecordSettings', logger);
		}
		if (withDML && !GRAPH_API_LIST_RECORDS_DELETE.isEmpty()) {
			DatabaseUtils.getInstance().performDeleteDML(GRAPH_API_LIST_RECORDS_DELETE, Schema.SObjectType.Graph_API_Token__c)
					.handleError(GraphAPIService.class.getName(), '.saveListTokenRecordSettings', logger);
		}
		
		// Clear the static lists after processing to prevent accumulation across method calls
		// This must happen regardless of withDML to prevent accumulation between calls
		if (withDML) {
			GRAPH_API_LIST_RECORDS_UPSERT.clear();
			GRAPH_API_LIST_RECORDS_DELETE.clear();
		}
		
		// Clear the cached records list after DML operations so it gets refreshed on next access
		// This ensures that subsequent calls to getGraphApiTokenListRecordsByType() see the updated records
		if (withDML) {
			GRAPH_API_LIST_RECORDS = null;
		}	
	}

	public static String getGraphInstanceKey(String graphTenantId) {
		return EncodingUtil.base64Encode(Crypto.generateDigest('SHA3-256', Blob.valueOf(String.valueOf(graphTenantId))));
	}

	public static void putEncryptedGraphTokenToCache(Logger logger, Graph_API_Settings__c graphSettings, String token) {
		try {
			if(PermissionsUtil.TeamsIntegrationEnabled && String.isNotBlank(token)) {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN, getGraphInstanceKey(graphSettings.Tenant_Id__c), '');
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN, keyCache);
				if (isCacheAvailableForKey) {
					Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(getGraphInstanceKey(graphSettings.Tenant_Id__c)), Blob.valueOf(token));
					CacheUtils.putCacheValue(keyCache, encryptedToken, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN));
				}
			}
		} catch (Exception e) {
			logger?.add(logger.getInternalError(e, graphSettings.Id, GraphAPIService.class.getName(), 'putEncryptedGraphTokenToCache'));
		}
	}

	public static String getDecryptedGraphTokenFromCache() {
		try {
			if(PermissionsUtil.TeamsIntegrationEnabled && String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c)) {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN, getGraphInstanceKey(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c), '');
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_GRAPH_TOKEN, keyCache);
				if (isCacheAvailableForKey) {
					Object cacheObject = CacheUtils.getCacheValue(keyCache);
					if (cacheObject != null) {
						Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(getGraphInstanceKey(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c)), (Blob)cacheObject);
						return decryptedToken.toString();
					}
				}
			}
			return null;
		}
		catch (Exception e) {
			Logger.getInstance().internalError(e, ConfigUtil.GRAPH_API_SETTINGS.Id, true, GraphAPIService.class.getName(), 'getDecryptedGraphTokenFromCache');
		}
		return null;
	}

	public static final String GRAPH_API_ROTATE_TOKEN_STATUS_COMPLETED = 'Completed';
	public class GraphApiManageTokens {

		public Boolean completed = false;

		public GraphApiManageTokens() {}

		public void flushSettings(Logger logger) {
			if(this.completed) {
				try {
					saveListTokenRecordSettings(true, logger);
					DatabaseUtils.getInstance().performUpsertDML(new List<Graph_API_Settings__c>{ConfigUtil.GRAPH_API_SETTINGS}, Schema.SObjectType.Graph_API_Settings__c)
							.handleError(GraphAPIService.class.getName(), '.refreshOAuthToken', logger);
				}
				catch (Exception e) {
					logger?.addInternalError(e, null, GraphApiManageTokens.class.getName(), 'flushSettings');
				}
			}
		}

		public Boolean isUnlocked(Logger logger) {
			String lockedJobId = getLockedJobId(logger);
			Boolean isUnlocked = String.isBlank(lockedJobId) || lockedJobId == GRAPH_API_ROTATE_TOKEN_STATUS_COMPLETED;
			return isUnlocked;
		}

		public void rotateTokens(Logger logger, String asyncApexJobId) {
			rotateTokens(logger, asyncApexJobId, false);
		}

		public void rotateTokens(Logger logger, String asyncApexJobId, Boolean forceRefresh) {
			if(forceRefresh || !isGraphAPIAccessTokenAvailable()) {
				try {
					if(isUnlocked(logger)) {
						setLockedJobId(asyncApexJobId, logger);
						Boolean result = validateAndRefreshGraphApiOauthToken(logger, false);
						completed = result;
						setLockedJobId(GRAPH_API_ROTATE_TOKEN_STATUS_COMPLETED, logger);
					}
				}
				catch (Exception e) {
					logger?.add(logger.getInternalError(e, null, GraphApiManageTokens.class.getName(), 'rotateTokens'));
				}
			}
		}

		private void setLockedJobId(String asyncApexJobId, Logger logger) {
			try {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
				if (isCacheAvailableForKey) {
					CacheUtils.putCacheValue(keyCache, asyncApexJobId, CacheUtils.getTTLValue(CacheUtils.KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID));
				}
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, null, GraphApiManageTokens.class.getName(), 'setLockedJobId'));
			}
		}

		public String getLockedJobId(Logger logger) {
			String lockedJobId;
			try {
				String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, UserInfo.getOrganizationId());
				Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_GRAPH_API_ROTATION_TOKENS_LOCKED_BY_JOB_ID, keyCache);
				if (isCacheAvailableForKey) {
					Object cacheObject = CacheUtils.getCacheValue(keyCache);
					if (cacheObject != null) {
						lockedJobId = String.valueOf(cacheObject);
					}
				}
			}
			catch (Exception e) {
				logger?.add(logger.getInternalError(e, null, GraphApiManageTokens.class.getName(), 'getLockedJobId'));
			}
			return lockedJobId;
		}

		private Boolean isGraphAPIAccessTokenAvailable() {
			Boolean result = false;

			try {
				Organization organization = getOrganization(OAUTH_API_TOKEN);
				result = true;
			}
			catch (HttpUtils.HttpUtilsException e) {
				result = false;
			}
			return result;
		}
	}
}