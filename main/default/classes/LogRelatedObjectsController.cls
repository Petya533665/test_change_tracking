public with sharing class LogRelatedObjectsController {

	@AuraEnabled
	public static List<RelatedObject> getRelatedObjects(String recordId) {
		List<RelatedObject> relatedObjects = new List<RelatedObject>();
		List<Log__c> logs = [SELECT Id, Name, Organization_Id__c, Related_Objects__c, Related_Id__c FROM Log__c WHERE Id = :recordId];
		if (!logs.isEmpty()) {
			String instanceUrl;
			if (String.isNotBlank(logs[0].Organization_Id__c)) instanceUrl = ConnectedOrgService.getConnectedOrgById(logs[0].Organization_Id__c)?.Instance_Url__c;
			if (String.isNotBlank(logs[0].Related_Objects__c)) {
				Map<String, List<String>> mapRelatedObjects;
				try {
					mapRelatedObjects = (Map<String, List<String>>)JSON.deserialize(logs[0].Related_Objects__c, Map<String, List<String>>.class);
				} catch (JSONException e) {
					// catch JSON deserialize issue
				}
				if (mapRelatedObjects != null) {
					for (String sObjectName : mapRelatedObjects.keySet()) {
						relatedObjects.add(new RelatedObject(logs[0].Name, instanceUrl, sObjectName.split(':')[0], sObjectName.split(':').size() > 1 ? sObjectName.split(':')[1] : sObjectName.split(':')[0], mapRelatedObjects.get(sObjectName)));
					}
				}
			}
		}
		return relatedObjects;
	}

	public class RelatedObject {
		@AuraEnabled
		public String logName {get;set;}
		@AuraEnabled
		public String instanceUrl {get;set;}
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled
		public String name {get;set;}
		@AuraEnabled
		public List<String> relatedIds {get;set;}
		@AuraEnabled
		public String labelWithCount {get;set;}

		public RelatedObject(String logName, String instanceUrl, String label, String name, List<String> relatedIds) {
			this.logName = logName;
			this.instanceUrl = instanceUrl;
			this.label = label;
			this.name = name;
			this.relatedIds = relatedIds;
			this.labelWithCount = label + ' (' + relatedIds.size() + ')';
		}
	}

}