public with sharing class BroadcastBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<BroadcastData>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private Set<Log__c> logsToUpdate = new Set<Log__c>();
	private Map<String, Exception> mapExceptionsByCorgName = new Map<String, Exception>();
	private Map<String, List<String>> mapLogIdsByCorgName = new Map<String, List<String>>();

	private static final String EXCEPTION_INVALID_SESSION_ID = 'INVALID_SESSION_ID';

	private static BroadcastBatch instance = null;

	public static BroadcastBatch getInstance() {
		if (instance == null) {
			instance = new BroadcastBatch(Logger.getInstance());
		}
		return instance;
	}

	private BroadcastBatch(Logger logger) {
		super(logger);
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('BroadcastBatch', this);
	}

	public override Boolean initialValidation() {
		List<Connected_Org__c> corgs = ConnectedOrgService.getBroadcastConnectedOrgs(ConnectedOrgService.BROADCAST_SEND_TO);
		return !corgs.isEmpty();
	}

	public override Integer getIterationsCount() {
		List<Connected_Org__c> corgs = ConnectedOrgService.getBroadcastConnectedOrgs(ConnectedOrgService.BROADCAST_SEND_TO);
		Integer logsCount = [SELECT COUNT() FROM Log__c WHERE Broadcast_Status__c = :BroadcastService.BROADCAST_STATUS_NEEDED AND Originated_From__c = NULL LIMIT :BroadcastService.queryLimit];
		return logsCount*corgs.size();
	}

	public Iterable<BroadcastData> start(Database.BatchableContext BC) {
		return new CustomIterable(loggerInstance);
	}

	public void execute(Database.BatchableContext BC, List<BroadcastData> scope) {
		Log__c log;
		ContentVersion contentVersion;
		if (scope[0].data instanceof Log__c) {
			log = (Log__c)scope[0].data;
		} else if (scope[0].data instanceof ContentVersion) {
			contentVersion = new ContentVersion();
			contentVersion.ContentLocation = ((ContentVersion)scope[0].data).ContentLocation;
			contentVersion.Title = ((ContentVersion)scope[0].data).Title;
			contentVersion.PathOnClient = ((ContentVersion)scope[0].data).PathOnClient;
		}
		String body = JSON.serialize(new Map<String, Object>{
				'logs' => log == null ? null : getFormattedLogs((new List<Log__c>{log}).deepClone()),
				'mapRecordTypesById' => log == null ? null : scope[0].mapRecordTypesById,
				'contentVersionWrapper' => contentVersion == null ? null : new BulkAPIJobBatchService.ContentVersionWrapper(contentVersion, ((ContentVersion)scope[0].data).VersionData.toString()),
				'organizationId' => UserInfo.getOrganizationId()
		});
		try {
			String b = HttpUtils.post(
					scope[0].corg.Instance_Url__c + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?' + ConfigUtil.PARAMS_TYPE + '=' + ConfigUtil.TYPE_BROADCAST,
					body,
					ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(scope[0].corg)),
					200
			);
		}
		catch (Exception e) {
			if (log != null) {
				mapExceptionsByCorgName.put(scope[0].corg.Name, e);
				if (mapLogIdsByCorgName.containsKey(scope[0].corg.Name)) {
					mapLogIdsByCorgName.get(scope[0].corg.Name).add(log.Id);
				} else {
					mapLogIdsByCorgName.put(scope[0].corg.Name, new List<String>{log.Id});
				}
			}
		}
		if (log != null) {
			log.Broadcast_Status__c = BroadcastService.BROADCAST_STATUS_COMPLETED;
			logsToUpdate.add(log);
		}
	}

	public void finish(Database.BatchableContext BC) {
		DatabaseUtils.getInstance().performUpdateDML(new List<Log__c>(logsToUpdate), Schema.SObjectType.Log__c)
				.handleError(BroadcastBatch.class.getName(), 'finish', loggerInstance);
		List<Connected_Org__c> corgsToUpdate = new List<Connected_Org__c>();
		for (String corgName : mapExceptionsByCorgName.keySet()) {
			Log__c log = loggerInstance?.getInternalError(mapExceptionsByCorgName.get(corgName), corgName, BroadcastBatch.class.getName(), 'finish');
			if (log != null) {
				log.Related_Objects__c = JSON.serialize(new Map<String, List<String>>{Log__c.SObjectType.getDescribe().getName() => mapLogIdsByCorgName.get(corgName)});
				loggerInstance?.add(log);
			}
			if (mapExceptionsByCorgName.get(corgName).getMessage().contains(EXCEPTION_INVALID_SESSION_ID)) {
				Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(corgName);
				corg.Connection_Valid__c = false;
				corgsToUpdate.add(corg);
			}
		}
		DatabaseUtils.getInstance().performUpdateDML(corgsToUpdate, Schema.SObjectType.Connected_Org__c)
				.handleError(BroadcastBatch.class.getName(), 'finish', loggerInstance);
		loggerInstance?.flush();
		BroadcastBatch.getInstance().startBatch();
	}

	private List<Log__c> getFormattedLogs(List<Log__c> logs) {
		for (Log__c log : logs) {
			if (String.isBlank(log.Organization_Url__c)) {
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Organization_Url__c, System.Url.getOrgDomainUrl().toExternalForm());
			}
			if (String.isBlank(log.User_Id__c) || String.isBlank(log.User_Name__c)) {
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.User_Id__c, UserInfo.getUserId());
				PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.User_Name__c, UserInfo.getName());
			}
			log.Jira_Integration_Status__c = null;
			log.Bug_Tracker__c = null;
			log.Notification_Integration_Status__c = null;
			log.PagerDuty_Integration_Status__c = null;
			log.Slack_Integration_Status__c = null;
			log.Email_Integration_Status__c = null;
		}
		return logs;
	}

	public class CustomIterable implements Iterable<BroadcastData> {

		private Logger loggerInstance;

		public CustomIterable(Logger logger) {
			this.loggerInstance = logger;
		}

		public Iterator<BroadcastData> iterator() {
			List<BroadcastData> lstBroadcastData = new List<BroadcastData>();
			Map<String, RuleUtil.Rule> mapRulesByRelatedId = getMapRulesByRelatedId();
			Map<String, String> mapRecordTypesById = getMapRecordTypesById();
			List<Log__c> logs = getLogs();
			Map<Id, Log__c> mapLogsToUpdate = new Map<Id, Log__c>();
			mapLogsToUpdate.putAll(logs);
			Set<String> setSearchStrings = new Set<String>();
			for (Log__c log : logs) {
				if (String.isNotBlank(log.Async_Job_Id__c)) {
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_PREFIX + log.Async_Job_Id__c + '.JSON');
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_SUMMARY_PREFIX + log.Async_Job_Id__c + '.JSON');
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_PREFIX + log.Async_Job_Id__c + '.CSV');
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_SUMMARY_PREFIX + log.Async_Job_Id__c + '.CSV');
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_PREFIX + log.Async_Job_Id__c + '.XML');
					setSearchStrings.add(BulkAPIJobBatchService.BULK_JOB_SUMMARY_PREFIX + log.Async_Job_Id__c + '.XML');
				}
			}
			List<ContentVersion> contentVersions = [SELECT Id, Title, ContentLocation, PathOnClient, VersionData FROM ContentVersion WHERE Title IN :setSearchStrings];
			for (Connected_Org__c corg : ConnectedOrgService.getBroadcastConnectedOrgs(ConnectedOrgService.BROADCAST_SEND_TO)) {
				for (Log__c log : mapRulesByRelatedId.containsKey(corg.Id) ? mapRulesByRelatedId.get(corg.Id).applyBroadcastRuleFilters(logs) : logs) {
					mapLogsToUpdate.remove(log.Id);
					for (ContentVersion contentVersion : contentVersions) {
						if (String.isNotBlank(log.Async_Job_Id__c) && contentVersion.Title.contains(log.Async_Job_Id__c)) {
							lstBroadcastData.add(new BroadcastData(corg, contentVersion, mapRecordTypesById));
						}
					}
					lstBroadcastData.add(new BroadcastData(corg, log, mapRecordTypesById));
				}
			}
			for (Log__c log : mapLogsToUpdate.values()) {
				log.Broadcast_Status__c = null;
			}
			DatabaseUtils.getInstance().performUpdateDML(mapLogsToUpdate.values(), Schema.SObjectType.Log__c)
					.handleError(BroadcastBatch.class.getName(), 'iterator', loggerInstance);
			return new CustomIterator(lstBroadcastData);
		}

		public List<Log__c> getLogs() {
			String query = new QBuilder(Log__c.SObjectType)
					.selectFields(new Set<String>{'FIELDS(ALL)'})
					.add(QBuilder.condition(Log__c.Broadcast_Status__c.getDescribe().getName()).equalsTo(BroadcastService.BROADCAST_STATUS_NEEDED))
					.add(QBuilder.condition(Log__c.Originated_From__c.getDescribe().getName()).isNull())
					.addLimit(BroadcastService.queryLimit)
					.build();
			String b = HttpUtils.get(
					Url.getOrgDomainUrl().toExternalForm() + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'),
					HttpUtils.getHeaders(ConnectedOrgService.getSelfConnectedOrgAccessToken()),
					200
			);
			Map<String, Object> mapRecords = (Map<String, Object>)JSON.deserializeUntyped(b);
			return (List<Log__c>)JSON.deserialize(JSON.serialize(mapRecords.get('records')), List<Log__c>.class);
		}

		public Map<String, RuleUtil.Rule> getMapRulesByRelatedId() {
			Map<String, RuleUtil.Rule> mapRulesByRelatedId = new Map<String, RuleUtil.Rule>();
			for (RuleUtil.Rule rule : RuleUtil.getRuleWrappers(RuleUtil.RULE_TYPE_BROADCAST)) {
				mapRulesByRelatedId.put(rule.relatedId, rule);
			}
			return mapRulesByRelatedId;
		}

		public Map<String, String> getMapRecordTypesById() {
			Map<String, String> mapRecordTypesById = new Map<String, String>();
			for (String id : Schema.SObjectType.Log__c.getRecordTypeInfosById().keySet()) {
				mapRecordTypesById.put(id, Schema.SObjectType.Log__c.getRecordTypeInfosById().get(id).getName());
			}
			return mapRecordTypesById;
		}

	}

	public class CustomIterator implements Iterator<BroadcastData> {

		private List<BroadcastData> lstBroadcastData;
		private Integer currentIndex;

		public CustomIterator(List<BroadcastData> lstBroadcastData) {
			this.lstBroadcastData = lstBroadcastData;
			this.currentIndex = 0;
		}

		public Boolean hasNext() {
			return currentIndex < lstBroadcastData.size();
		}

		public BroadcastData next() {
			if (hasNext()) {
				return lstBroadcastData[currentIndex++];
			} else {
				throw new NoSuchElementException();
			}
		}


	}

	public class BroadcastData {
		public Connected_Org__c corg;
		public SObject data;
		public Map<String, String> mapRecordTypesById;
		public BroadcastData(Connected_Org__c corg, SObject data, Map<String, String> mapRecordTypesById) {
			this.corg = corg;
			this.data = data;
			this.mapRecordTypesById = mapRecordTypesById;
		}
	}

}