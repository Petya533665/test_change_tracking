public with sharing class IssueRelatedObjectsController {

	private static final Integer CHUNK_SIZE = 5000;

	private static final String OBJECTS_TYPE = 'Objects';
	private static final String USERS_TYPE = 'Users';

	@AuraEnabled
	public static List<ChunkProperties> getChunkProperties(String recordId) {
		List<ChunkProperties> chunkProperties = new List<ChunkProperties>();
		List<AggregateResult> aggregateResults = [
				SELECT COUNT(Id) log_count, DAY_ONLY(Created_At__c) created_at
				FROM Log__c
				WHERE Issue__c = :recordId OR (Issue__r.Related_Issue__c = :recordId AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE)
				GROUP BY DAY_ONLY(Created_At__c)
		];
		for (AggregateResult aggregateResult : aggregateResults) {
			if (chunkProperties.isEmpty() || chunkProperties[chunkProperties.size() - 1].logCount >= CHUNK_SIZE) {
				chunkProperties.add(new ChunkProperties(0, new Set<String>()));
			}
			ChunkProperties aChunkProperties = chunkProperties[chunkProperties.size() - 1];
			aChunkProperties.logCount += (Integer)aggregateResult.get('log_count');
			aChunkProperties.setCreatedAt.add(String.valueOf(aggregateResult.get('created_at')));
		}
		return chunkProperties;
	}

	@AuraEnabled
	public static List<RelatedObject> getRelatedObjects(String recordId, String type, String aChunkPropertiesJSON) {
		Map<String, RelatedObject> relatedObjects = new Map<String, RelatedObject>();
		ChunkProperties aChunkProperties;
		try {
			aChunkProperties = (ChunkProperties)JSON.deserialize(aChunkPropertiesJSON, ChunkProperties.class);
		} catch (JSONException e) {
			// catch JSON deserialize issue
		}
		if (aChunkProperties != null) {
			Set<Date> setCreatedAt = new Set<Date>();
			for (String createdAt : aChunkProperties.setCreatedAt) {
				setCreatedAt.add(Date.valueOf(createdAt));
			}
			List<Log__c> logs = [
					SELECT Id, Name, Issue__r.Name, Organization_Id__c, Related_Objects__c, User_Id__c, User_Name__c
					FROM Log__c
					WHERE (Issue__c = :recordId OR (Issue__r.Related_Issue__c = :recordId AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE))
					AND DAY_ONLY(Created_At__c) IN :setCreatedAt
			];
			for (Log__c log : logs) {
				Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(log.Organization_Id__c);
				if (type == OBJECTS_TYPE) {
					if (String.isNotBlank(log.Related_Objects__c)) {
						Map<String, List<String>> mapRelatedObjects;
						try {
							mapRelatedObjects = (Map<String, List<String>>)JSON.deserialize(log.Related_Objects__c, Map<String, List<String>>.class);
						} catch (JSONException e) {
							// catch JSON deserialize issue
						}
						if (mapRelatedObjects != null) {
							for (String sObjectName : mapRelatedObjects.keySet()) {
								String key = corg.Instance_Url__c + (sObjectName.split(':').size() > 1 ? sObjectName.split(':')[1] : sObjectName.split(':')[0]);
								if (!relatedObjects.containsKey(key)) {
									relatedObjects.put(key, new RelatedObject());
								}
								RelatedObject relatedObject = relatedObjects.get(key);
								relatedObject.issueName = log.Issue__r.Name;
								relatedObject.instanceUrl = corg.Instance_Url__c;
								relatedObject.sObjectName = sObjectName.split(':').size() > 1 ? sObjectName.split(':')[1] : sObjectName.split(':')[0];
								if (relatedObject.relatedIds == null) {
									relatedObject.relatedIds = new Set<String>(mapRelatedObjects.get(sObjectName));
								} else {
									relatedObject.relatedIds.addAll(mapRelatedObjects.get(sObjectName));
								}
							}
						}
					}
				} else if (type == USERS_TYPE) {
					if (String.isNotBlank(log.User_Id__c) && String.isNotBlank(log.User_Name__c)) {
						String key = corg.Instance_Url__c + log.User_Id__c;
						RelatedObject relatedObject = new RelatedObject();
						relatedObject.issueName = log.Issue__r.Name;
						relatedObject.instanceUrl = corg.Instance_Url__c;
						relatedObject.userId = log.User_Id__c;
						relatedObject.userName = log.User_Name__c;
						relatedObjects.put(key, relatedObject);
					}
				}
			}
		}
		return relatedObjects.values();
	}

	public class ChunkProperties {
		@AuraEnabled
		public Integer logCount {get; set;}
		@AuraEnabled
		public Set<String> setCreatedAt {get; set;}
		public ChunkProperties(Integer logCount, Set<String> setCreatedAt) {
			this.logCount = logCount;
			this.setCreatedAt = setCreatedAt;
		}
	}

	public class RelatedObject {
		@AuraEnabled
		public String issueName {get;set;}
		@AuraEnabled
		public String instanceUrl {get;set;}
		@AuraEnabled
		public String userId {get;set;}
		@AuraEnabled
		public String userName {get;set;}
		@AuraEnabled
		public String sObjectName {get;set;}
		@AuraEnabled
		public Set<String> relatedIds {get;set;}
	}

}