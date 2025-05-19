public with sharing class IssueRelatedListController {

	private static Set<String> ISSUE_FIELDS = new Set<String>{
			Issue__c.Name.getDescribe().getName()
	};

	private static String RELATED_ISSUE_API_NAME = ConfigUtil.nameSpacePrefix + 'Related_Issue__c';
	private static String RELATED_ISSUES_API_NAME = ConfigUtil.nameSpacePrefix + 'Related_Issues__r';

	@AuraEnabled
	public static void unlinkRelatedIssue(String recordId) {
		List<Issue__c> issues = [SELECT Id, Related_Issue__c FROM Issue__c WHERE Id = :recordId];
		if (!issues.isEmpty()) {
			issues[0].Related_Issue__c = null;
			DatabaseUtils.getInstance().performUpdateDML(issues, Schema.SObjectType.Issue__c)
					.handleError(IssueRelatedListController.class.getName(), '.unlinkRelatedIssue');
			Logger.getInstance().flush();
		}
	}

	@AuraEnabled
	public static DataTable getDataTable(String recordId, String fields) {
		DataTable dataTable = new DataTable();
		Map<String, SObjectField> sObjectFieldMap = Schema.Issue__c.getSObjectType().getDescribe().fields.getMap();
		for (String issueField : ISSUE_FIELDS) {
			SObjectField sObjectField = sObjectFieldMap.containsKey(issueField) ? sObjectFieldMap.get(issueField) : sObjectFieldMap.get(ConfigUtil.nameSpacePrefix + issueField);
			if (String.isNotBlank(String.valueOf(sObjectField))) {
				dataTable.addColumn(sObjectField);
			}
		}
		if (String.isNotBlank(fields)) {
			for (String field : fields.split(',')) {
				SObjectField sObjectField = sObjectFieldMap.containsKey(field) ? sObjectFieldMap.get(field) : sObjectFieldMap.get(ConfigUtil.nameSpacePrefix + field);
				if (String.isNotBlank(String.valueOf(sObjectField)) && ISSUE_FIELDS.add(sObjectField.getDescribe().getName())) {
					dataTable.addColumn(sObjectField);
				}
			}
		}
		List<String> recordIds = new List<String>();
		List<Issue__c> issues = [SELECT Id, Related_Issue__c FROM Issue__c WHERE Id = :recordId];
		if (!issues.isEmpty() && String.isNotBlank(issues[0].Related_Issue__c)) {
			dataTable.parentData = getIssues(new List<String>{issues[0].Related_Issue__c});
			for (Issue__c parentIssue : dataTable.parentData) {
				for (Issue__c relatedIssue : parentIssue.Related_Issues__r) {
					recordIds.add(relatedIssue.Id);
				}
			}
		}
		dataTable.childData = getIssues(!recordIds.isEmpty() ? recordIds : new List<String>{recordId});
		return dataTable;
	}

	private static List<Issue__c> getIssues(List<String> recordIds) {
		String query = new QBuilder(Issue__c.SObjectType)
				.selectFields(ISSUE_FIELDS)
				.addSubquery(new QBuilder(RELATED_ISSUES_API_NAME)
						.selectFields(ISSUE_FIELDS))
				.add(QBuilder.condition(Issue__c.Id.getDescribe().getName()).isIn(recordIds))
				.build();
		return Database.query(query);
	}

	public class DataTable {
		@AuraEnabled
		public List<DataTableColumns> columns {get;set;}
		@AuraEnabled
		public List<Issue__c> parentData {get;set;}
		@AuraEnabled
		public List<Issue__c> childData {get;set;}
		@AuraEnabled
		public String children {get;set;}
		@AuraEnabled
		public String related {get;set;}

		public DataTable() {
			columns = new List<DataTableColumns>();
			children = RELATED_ISSUES_API_NAME;
			related = RELATED_ISSUE_API_NAME;
		}

		public void addColumn(SObjectField sObjectField) {
			columns.add(
					new DataTableColumns(
							sObjectField.getDescribe().getLabel(),
							sObjectField.getDescribe().getName(),
							String.valueOf(sObjectField.getDescribe().getType())
					)
			);
		}
	}

	public class DataTableColumns {
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled
		public String fieldName {get;set;}
		@AuraEnabled
		public String type {get;set;}

		public DataTableColumns(String label, String fieldName, String type) {
			this.label = label;
			this.fieldName = fieldName;
			this.type = type;
		}
	}

}