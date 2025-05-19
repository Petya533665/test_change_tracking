public with sharing class ManageTokensBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<TokenTypeWrapper>,Schedulable,Database.Stateful, Database.AllowsCallouts,Database.RaisesPlatformEvents {

	public ManageTokensBatch() {}

	public void execute(SchedulableContext sc) {
		LogServiceScheduler.rescheduleCronTriggers();
	}

	private static ManageTokensBatch instance = null;

	public static ManageTokensBatch getInstance() {
		if (instance == null) {
			instance = new ManageTokensBatch(Logger.getInstance());
		}
		return instance;
	}

	private ManageTokensBatch(Logger logger) {
		super(logger);
	}

	public override void startBatch() {
		if (!DatabaseUtils.executeBatchWithLimitCheck('ManageTokensBatch', this)) finishBatch();
	}

	public override Integer getIterationsCount() {
		return getTokenMembers().size();
	}

	public Iterable<TokenTypeWrapper> start(Database.BatchableContext batchableContext) {
		TokenTypeIterable iterable = new TokenTypeIterable(getTokenMembers());
		return iterable;
	}

	public void execute(Database.BatchableContext batchableContext, List<TokenTypeWrapper> scope) {
		TokenTypeWrapper token = scope.get(0);
		switch on token?.type {
			when JIRA {
				debugJiraTokensTokens('before', loggerInstance);
				JiraService.JiraManageTokens jiraManageTokens = new JiraService.JiraManageTokens();
				jiraManageTokens.rotateTokens(loggerInstance, batchableContext.getJobId(), true);
				jiraManageTokens.flushSettings(loggerInstance);
				debugJiraTokensTokens('after', loggerInstance);
			}
			when TEAMS {
				GraphAPIService.GraphApiManageTokens graphManageTokens = new GraphAPIService.GraphApiManageTokens();
				graphManageTokens.rotateTokens(loggerInstance, batchableContext.getJobId(), true);
				graphManageTokens.flushSettings(loggerInstance);
			}
			when AZURE_DEV_OPS {
				AzureService.AzureDevOpsApiManageTokens azureManageTokens = new AzureService.AzureDevOpsApiManageTokens();
				azureManageTokens.rotateTokens(loggerInstance, batchableContext.getJobId(), true);
				azureManageTokens.flushSettings(loggerInstance);
			}
		}
	}

	public void finish(Database.BatchableContext batchableContext) {
		loggerInstance?.flush();
		finishBatch();
	}

	public static void debugJiraTokensTokens(String type, Logger logger) {
		if (PermissionsUtil.DebugJiraRefreshTokensEnabled) {
			JiraService.JWTParser tokenParser = new JiraService.JWTParser(JiraService.JIRA_OAUTH_TOKEN);
			JiraService.JWTParser refreshTokenParser = new JiraService.JWTParser(JiraService.JIRA_OAUTH_REFRESH_TOKEN);
			
			Log__c logToken = LogBuilder.getInstance().summary('Jira Token ' + type).details(JSON.serialize('Access Token:\n' + tokenParser.payload + '\n\nRefresh Token:\n' + refreshTokenParser.payload)).category('Pharos Error').area('Pharos').stacktrace(' ').attribute(Schema.sObjectType.Log__c.fields.Post_Processing_Status__c.getName().toLowerCase(), LogPostProcessingService.POST_PROCESSING_STATUS_COMPLETED).attribute(Schema.sObjectType.Log__c.fields.Hash_1__c.getName().toLowerCase(), 'JiraToken').build();
			logger.add(logToken);
		}
	}

	public enum TokenType {JIRA, TEAMS, AZURE_DEV_OPS}

	public class TokenTypeWrapper {
		public TokenType type;

		public TokenTypeWrapper(TokenType type) {
			this.type = type;
		}
	}

	public static List<TokenTypeWrapper> getTokenMembers() {
		List<TokenTypeWrapper> result = new List<TokenTypeWrapper>();
		if (String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_API_Url__c)
			&& JiraService.getJIRAServiceAuthType() == JiraService.JIRA_SERVICE_AUTH_TYPE.JIRA_CLOUD) {

			result.add(new TokenTypeWrapper(TokenType.JIRA));
		}
		if (PermissionsUtil.TeamsIntegrationEnabled
			&& ConfigUtil.GRAPH_API_SETTINGS.Enabled__c
			&& String.isNotBlank(ConfigUtil.GRAPH_API_SETTINGS.Tenant_Id__c)) {

			result.add(new TokenTypeWrapper(TokenType.TEAMS));
		}
		if (PermissionsUtil.AzureDevOpsIntegrationEnabled
			&& String.isNotBlank(ConfigUtil.AZURE_DEV_OPS_API_SETTINGS.Organization_Id__c)) {

			result.add(new TokenTypeWrapper(TokenType.AZURE_DEV_OPS));
		}
		return result;
	}

	public class TokenTypeIterable implements Iterable<TokenTypeWrapper> {

		private List<TokenTypeWrapper> tokens;

		public TokenTypeIterable() {
			this.tokens = new List<TokenTypeWrapper>();
		}

		public TokenTypeIterable(List<TokenTypeWrapper> tokens) {
			this.tokens = tokens;
		}

		public Iterator<TokenTypeWrapper> iterator() {
			return new TokenTypeIterator(this.tokens);
		}
	}

	public class TokenTypeIterator implements Iterator<TokenTypeWrapper> {
		private List<TokenTypeWrapper> tokens;
		private Integer index;

		public TokenTypeIterator(List<TokenTypeWrapper> defaults) {
			this.tokens = defaults == null ? new List<TokenTypeWrapper>() : defaults;
			this.index = 0;
		}

		public TokenTypeIterator() {
			this(new List<TokenTypeWrapper>());
		}

		public Boolean hasNext() {
			return this.index < tokens.size() ? true : false;
		}

		public TokenTypeWrapper next() {
			return this.tokens[this.index++];
		}
	}
}