public with sharing class SystemOverviewController {

	@TestVisible
	private static final Map<String, String> CODE_INFO_OBJECTS_MAP = new Map<String, String>{
			'ApexClass' => 'Apex Class',
			'ApexTrigger' => 'Apex Trigger',
			'ApexPage' => 'Apex Page',
			'ApexComponent' => 'Apex Component',
			'LightningComponentBundle' => 'LWC',
			'AuraDefinitionBundle' => 'Aura',
			'FlowDefinition' => 'Flow'
	};
	private static final Set<String> CODE_INFO_OBJECTS_TOOLING = new Set<String>{'LightningComponentBundle', 'FlowDefinition'};
	private static final Set<String> CODE_INFO_OBJECTS_MASTER_LABEL = new Set<String>{'LightningComponentBundle', 'AuraDefinitionBundle', 'FlowDefinition'};
	private static final Set<String> CODE_INFO_OBJECTS_NAME = new Set<String>{'ApexClass', 'ApexTrigger', 'ApexPage', 'ApexComponent'};

	@TestVisible
	private static final String CODE_INFO_QUERY = 'SELECT COUNT(Id) count_id, NamespacePrefix namespacePrefix FROM {0} GROUP BY NamespacePrefix';

	private static final String CODE_INFO_DETAILS_QUERY = 'SELECT Name, ApiVersion, NamespacePrefix FROM {0}';
	@TestVisible
	private static final String CODE_INFO_DETAILS_LIGHTNING_QUERY = 'SELECT MasterLabel, ApiVersion, NamespacePrefix FROM {0}';
	@TestVisible
	private static final String CODE_INFO_DETAILS_FLOW_QUERY = 'SELECT MasterLabel, MAX(ApiVersion) ApiVersion, Definition.Id, Definition.NamespacePrefix FROM Flow GROUP BY MasterLabel, Definition.Id, Definition.NamespacePrefix';
	private static final String PROGRESS_COLOR_SUCCESS = '#2e844a';
	private static final String PROGRESS_COLOR_WARNING = '#fe9339';
	private static final String PROGRESS_COLOR_ERROR = '#ea001e';

	private static final String PROFILE_TYPE = 'Profile';
	private static final String PERMISSION_SET_TYPE = 'PermissionSet';

	private static final Map<String, String> RISKY_PERMISSIONS = new Map<String, String>{
			'modifyAllData' => 'Modify All Data',
			'viewAllData' => 'View All Data',
			'resetPasswords' => 'Reset Passwords',
			'dataExport' => 'Data Export',
			'manageSharing' => 'Manage Sharing',
			'manageRoles' => 'Manage Roles',
			'editReadonlyFields' => 'Edit Readonly Fields'
	};

	private static final Map<String, String> RISKY_PERMISSION_FIELDS = new Map<String, String>{
			'modifyAllData' => 'PermissionsModifyAllData',
			'viewAllData' => 'PermissionsViewAllData',
			'resetPasswords' => 'PermissionsResetPasswords',
			'dataExport' => 'PermissionsDataExport',
			'manageSharing' => 'PermissionsManageSharing',
			'manageRoles' => 'PermissionsManageRoles',
			'editReadonlyFields' => 'PermissionsEditReadonlyFields'
	};

	private static final String STANDARD_OBJECTS_TYPE = 'Standard Objects';
	private static final String CUSTOM_OBJECTS_TYPE = 'Custom Objects';
	private static final String CUSTOM_SETTINGS_TYPE = 'Custom Settings';
	private static final String CUSTOM_METADATA_TYPES_TYPE = 'Custom Metadata Types';
	private static final String BIG_OBJECTS_TYPE = 'Big Objects';

	@AuraEnabled
	public static String getNameSpacePrefix() {
		return ConfigUtil.nameSpacePrefix;
	}

	@AuraEnabled
	public static Organization getOrgInfo() {
		return [SELECT Id, Name, OrganizationType, CreatedDate, IsSandbox, LanguageLocaleKey, TimeZoneSidKey FROM Organization];
	}

	@AuraEnabled
	public static UsersInfo getUsersInfo() {
		UsersInfo usersInfo = new UsersInfo();
		usersInfo.numberOfActiveUsers = [SELECT COUNT() FROM User WHERE IsActive = TRUE];
		usersInfo.numberOfNoActivityInLast30Days = [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastLoginDate < LAST_N_DAYS:30];
		usersInfo.numberOfUsers = [SELECT COUNT() FROM User];
		usersInfo.numberOfInactiveUsers = [SELECT COUNT() FROM User WHERE IsActive = FALSE];
		return usersInfo;
	}
	
	@AuraEnabled
	public static List<ChartDataCount> getUsersInfoDetails() {
		List<ChartDataCount> chartDataCounts = new List<ChartDataCount>();
		List<User> users = [SELECT Id, Name, LastLoginDate FROM User WHERE IsActive = TRUE AND LastLoginDate < LAST_N_DAYS:30];
		for (User user : users) {
			ChartDataCount chartDataCount = new ChartDataCount();
			chartDataCount.id = user.Id.to15();
			chartDataCount.name = user.Name;
			chartDataCount.label = user.Name;
			chartDataCount.count = user.LastLoginDate.date().daysBetween(Date.today());
			chartDataCounts.add(chartDataCount);
		}
		return chartDataCounts;
	}

	@AuraEnabled
	public static List<CodeInfo> getCodeInfo() {
		List<CodeInfo> lstCodeInfo = new List<CodeInfo>();
		for (String objectName : CODE_INFO_OBJECTS_MAP.keySet()) {
			CodeInfo codeInfo = new CodeInfo();
			codeInfo.name = objectName;
			codeInfo.label = CODE_INFO_OBJECTS_MAP.get(objectName);
			String query = String.format(CODE_INFO_QUERY, new List<String>{objectName});
			if (CODE_INFO_OBJECTS_TOOLING.contains(objectName)) {
				List<Object> objects = getToolingAPIObjects(query);
				for (Object obj : objects) {
					Map<String, Object> objectMap = (Map<String, Object>)obj;
					codeInfo.namespacePrefix = (String)objectMap.get('namespacePrefix');
					codeInfo.count = (Integer)objectMap.get('count_id');
				}
			} else {
				List<AggregateResult> aggregateResults = Database.query(query);
				for (AggregateResult aggregateResult : aggregateResults) {
					codeInfo.namespacePrefix = (String)aggregateResult.get('namespacePrefix');
					codeInfo.count = (Integer)aggregateResult.get('count_id');
				}
			}
			lstCodeInfo.add(codeInfo);
		}
		return lstCodeInfo;
	}

	@AuraEnabled
	public static List<CodeInfoDetail> getCodeInfoDetails(String objectName) {
		List<CodeInfoDetail> codeInfoDetails = new List<CodeInfoDetail>();
		String query;
		if (objectName == 'FlowDefinition') {
			query = CODE_INFO_DETAILS_FLOW_QUERY;
		} else if (objectName == 'LightningComponentBundle' || objectName == 'AuraDefinitionBundle') {
			query = String.format(CODE_INFO_DETAILS_LIGHTNING_QUERY, new List<String>{objectName});
		} else {
			query = String.format(CODE_INFO_DETAILS_QUERY, new List<String>{objectName});
		}
		if (CODE_INFO_OBJECTS_TOOLING.contains(objectName)) {
			List<Object> objects = getToolingAPIObjects(query);
			for (Object obj : objects) {
				Map<String, Object> objectMap = (Map<String, Object>)obj;
				CodeInfoDetail codeInfoDetail = new CodeInfoDetail();
				codeInfoDetail.name = objectName;
				codeInfoDetail.label = CODE_INFO_OBJECTS_MAP.get(objectName);
				codeInfoDetail.fullName = (String)objectMap.get('MasterLabel');
				codeInfoDetail.namespacePrefix = (String)objectMap.get('NamespacePrefix');
				codeInfoDetail.apiVersion = String.valueOf(objectMap.get('ApiVersion'));
				codeInfoDetails.add(codeInfoDetail);
			}
		} else {
			List<SObject> sObjects = Database.query(query);
			for (SObject sObj : sObjects) {
				CodeInfoDetail codeInfoDetail = new CodeInfoDetail();
				codeInfoDetail.name = objectName;
				codeInfoDetail.label = CODE_INFO_OBJECTS_MAP.get(objectName);
				codeInfoDetail.fullName = objectName == 'AuraDefinitionBundle' ? (String)sObj.get('MasterLabel') : (String)sObj.get('Name');
				codeInfoDetail.namespacePrefix = (String)sObj.get('NamespacePrefix');
				codeInfoDetail.apiVersion = String.valueOf(sObj.get('ApiVersion'));
				codeInfoDetails.add(codeInfoDetail);
			}
		}
		return codeInfoDetails;
	}

	public static List<Object> getToolingAPIObjects(String query) {
		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
		return HttpUtils.runToolingQuery(
				corg == null ? System.Url.getOrgDomainUrl().toExternalForm() : corg.Instance_Url__c,
				corg == null ? ConfigUtil.USER_SESSION_ID : ConnectedOrgService.getConnectedOrgAccessToken(corg),
				query,
				ConfigUtil.TOOLING_QUERY_API_ENDPOINT);
	}

	@AuraEnabled
	public static List<ObjectInfo> getObjectInfo() {
		List<ObjectInfo> objectInfos = new List<ObjectInfo>();
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		for (String objectName : globalDescribe.keySet()) {
			Schema.DescribeSObjectResult describeSObjectResult = globalDescribe.get(objectName).getDescribe();
			String objectType = getObjectType(describeSObjectResult);
			if (String.isNotBlank(objectType)) {
				objectInfos.add(new ObjectInfo(describeSObjectResult, objectType));
			}
		}
		return objectInfos;
	}

	public static String getObjectType(Schema.DescribeSObjectResult describeSObjectResult) {
		if (!describeSObjectResult.isAccessible()
				|| !describeSObjectResult.isCreateable()
				|| !describeSObjectResult.isDeletable()
				|| !describeSObjectResult.isUpdateable()
				|| !describeSObjectResult.isQueryable()
				|| !describeSObjectResult.isSearchable()
				|| describeSObjectResult.isDeprecatedAndHidden()) {
			return null;
		}
		if (describeSObjectResult.isCustom()) {
			if (describeSObjectResult.isCustomSetting()) {
				return CUSTOM_SETTINGS_TYPE;
			} else if (describeSObjectResult.name.endsWith('__mdt')) {
				return CUSTOM_METADATA_TYPES_TYPE;
			} else if (describeSObjectResult.name.endsWith('__b')) {
				return BIG_OBJECTS_TYPE;
			} else {
				return CUSTOM_OBJECTS_TYPE;
			}
		} else {
			if (describeSObjectResult.name.startsWith('Setup') ||
					describeSObjectResult.name.startsWith('Auth') ||
					describeSObjectResult.name.startsWith('Permission') ||
					describeSObjectResult.name.endsWith('Share') ||
					describeSObjectResult.name.endsWith('History') ||
					describeSObjectResult.name.endsWith('Feed') ||
					describeSObjectResult.name.endsWith('Event') ||
					describeSObjectResult.name.endsWith('EventStore') ||
					describeSObjectResult.name.endsWith('__b') ||
					describeSObjectResult.name.contains('Config') ||
					describeSObjectResult.name.contains('Setting')) {
				return null;
			}
		}
		return STANDARD_OBJECTS_TYPE;
	}

	@AuraEnabled
	public static List<ChartDataCount> getSensitivePermissions() {
		List<ChartDataCount> chartDataCounts = new List<ChartDataCount>();
		List<User> users = [
				SELECT Id, Name, Profile.Name, Profile.PermissionsModifyAllData, Profile.PermissionsViewAllData,
						Profile.PermissionsResetPasswords, Profile.PermissionsDataExport,
						Profile.PermissionsManageSharing, Profile.PermissionsManageRoles,
						Profile.PermissionsEditReadonlyFields
				FROM User
				WHERE IsActive = TRUE AND (
						Profile.PermissionsModifyAllData = TRUE OR
						Profile.PermissionsViewAllData = TRUE OR
						Profile.PermissionsResetPasswords = TRUE OR
						Profile.PermissionsDataExport = TRUE OR
						Profile.PermissionsManageSharing = TRUE OR
						Profile.PermissionsManageRoles = TRUE OR
						Profile.PermissionsEditReadonlyFields = TRUE
				)
		];
		for (User user : users) {
			ChartDataCount chartDataCount = new ChartDataCount(user);
			for (String permission : RISKY_PERMISSIONS.keySet()) {
				chartDataCount.addStackingCount(user.Profile.Name, PROFILE_TYPE, permission, Boolean.valueOf(user.Profile.get(RISKY_PERMISSION_FIELDS.get(permission))) ? 1 : 0);
			}
			chartDataCounts.add(chartDataCount);
		}
		List<PermissionSetAssignment> assignments = [
				SELECT AssigneeId, Assignee.Name, Assignee.Profile.Name, PermissionSet.Name,
						PermissionSet.PermissionsModifyAllData, PermissionSet.PermissionsViewAllData,
						PermissionSet.PermissionsResetPasswords, PermissionSet.PermissionsDataExport,
						PermissionSet.PermissionsManageSharing, PermissionSet.PermissionsManageRoles,
						PermissionSet.PermissionsEditReadonlyFields
				FROM PermissionSetAssignment
				WHERE Assignee.IsActive = TRUE AND PermissionSet.IsOwnedByProfile = FALSE AND
				(PermissionSet.PermissionsModifyAllData = TRUE OR
				PermissionSet.PermissionsViewAllData = TRUE OR
				PermissionSet.PermissionsResetPasswords = TRUE OR
				PermissionSet.PermissionsDataExport = TRUE OR
				PermissionSet.PermissionsManageSharing = TRUE OR
				PermissionSet.PermissionsManageRoles = TRUE OR
				PermissionSet.PermissionsEditReadonlyFields = TRUE)
		];
		for (PermissionSetAssignment psa : assignments) {
			ChartDataCount chartDataCount = findOrCreateChartDataCount(chartDataCounts, psa);
			for (String permission : RISKY_PERMISSIONS.keySet()) {
				chartDataCount.addStackingCount(psa.PermissionSet.Name, PERMISSION_SET_TYPE, permission, Boolean.valueOf(psa.PermissionSet.get(RISKY_PERMISSION_FIELDS.get(permission))) ? 1 : 0);
			}
		}
		return chartDataCounts;
	}

	private static ChartDataCount findOrCreateChartDataCount(List<ChartDataCount> chartDataCounts, PermissionSetAssignment psa) {
		for (ChartDataCount chartDataCount : chartDataCounts) {
			if (chartDataCount.id == psa.AssigneeId) {
				return chartDataCount;
			}
		}
		ChartDataCount chartDataCount = new ChartDataCount(psa);
		chartDataCounts.add(chartDataCount);
		return chartDataCount;
	}

	@AuraEnabled
	public static List<ObjectInfo> getObjectInfoDetails(List<ObjectInfo> objectInfos) {
		fillObjectInfoRecordCount(objectInfos);
		fillObjectInfoAutomations(objectInfos);
		return objectInfos;
	}

	private static void fillObjectInfoRecordCount(List<ObjectInfo> objectInfos) {
		for (ObjectInfo objectInfo : objectInfos) {
			String query = new QBuilder(objectInfo.name)
					.selectFields(new Set<String>{'COUNT()'})
					.build();
			try {
				Integer count = Database.countQuery(query);
				objectInfo.recordCount = count;
			} catch (Exception e) {}
		}
	}

	private static void fillObjectInfoAutomations(List<ObjectInfo> objectInfos) {
		// Collect all object names
		Set<String> objectNames = new Set<String>();
		for (ObjectInfo objInfo : objectInfos) {
			objectNames.add(objInfo.name);
		}

		// Query all automations at once
		Map<String, Integer> triggerCounts = getTriggerCounts(objectNames);
		Map<String, Integer> workflowCounts = getWorkflowCounts(objectNames);
		Map<String, Integer> processBuilderCounts = getProcessBuilderCounts(objectNames);
		Map<String, Integer> flowCounts = getFlowCounts(objectNames);

		// Assign counts to each object
		for (ObjectInfo objectInfo : objectInfos) {
			if (triggerCounts.get(objectInfo.name) > 0 || workflowCounts.get(objectInfo.name) > 0 || processBuilderCounts.get(objectInfo.name) > 0 || flowCounts.get(objectInfo.name) > 0) {
				List<ObjectInfoAutomation> automations = new List<ObjectInfoAutomation>();

				addAutomation(automations, 'Trigger', triggerCounts.get(objectInfo.name));
				addAutomation(automations, 'Workflow', workflowCounts.get(objectInfo.name));
				addAutomation(automations, 'Process', processBuilderCounts.get(objectInfo.name));
				addAutomation(automations, 'Flow', flowCounts.get(objectInfo.name));

				objectInfo.automations = automations;
			}
		}
	}

	private static void addAutomation(List<ObjectInfoAutomation> automations, String type, Integer count) {
		ObjectInfoAutomation automation = new ObjectInfoAutomation();
		automation.type = type;
		automation.count = count != null ? count : 0;
		automations.add(automation);
	}

	private static Map<String, Integer> getTriggerCounts(Set<String> objectNames) {
		Map<String, Integer> counts = new Map<String, Integer>();
		for (AggregateResult ar : [
				SELECT TableEnumOrId objectName, COUNT(Id) cnt
				FROM ApexTrigger
				WHERE TableEnumOrId IN :objectNames AND Status = 'Active'
				GROUP BY TableEnumOrId
		]) {
			counts.put((String)ar.get('objectName'), (Integer)ar.get('cnt'));
		}
		return counts;
	}

	private static Map<String, Integer> getWorkflowCounts(Set<String> objectNames) {
		Map<String, Integer> counts = new Map<String, Integer>();
		String objectNamesString = '\'';
		objectNamesString += String.join(new List<String>(objectNames), '\',\'');
		objectNamesString += '\'';
		String query = 'SELECT TableEnumOrId, COUNT(Id) cnt ' +
				'FROM WorkflowRule ' +
				'WHERE TableEnumOrId IN (' + objectNamesString + ') ' +
				'GROUP BY TableEnumOrId';
		List<Object> objects = getToolingAPIObjects(query);
		for (Object obj : objects) {
			Map<String, Object> resultMap = (Map<String, Object>) obj;
			String objectName = (String)resultMap.get('TableEnumOrId');
			Integer count = Integer.valueOf(resultMap.get('cnt'));
			counts.put(objectName, count);
		}
		return counts;
	}
	
	private static final Set<String> PROCESS_BUILDER_TYPES = new Set<String>{'Workflow', 'CustomEvent', 'InvocableProcess'};

	public static Map<String, Integer> getProcessBuilderCounts(Set<String> objectNames) {
		Map<String, Integer> counts = new Map<String, Integer>();
		String query = 'SELECT Id, ProcessType FROM Flow WHERE Status = \'Active\' AND ProcessType IN (\'Workflow\', \'CustomEvent\', \'InvocableProcess\')';
		List<Object> objects = SystemOverviewController.getToolingAPIObjects(query);
		for (Object obj : objects) {
			Map<String, Object> resultMap = (Map<String, Object>) obj;
			Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
			String b = HttpUtils.get(
					(corg == null ? System.Url.getOrgDomainUrl().toExternalForm() : corg.Instance_Url__c) + ConfigUtil.TOOLING_API_GET_FLOW + resultMap.get('Id'),
					ConfigUtil.SF_REST_API_HEADERS,
					200
			);
			FlowWrapper flowWrapper = (FlowWrapper)JSON.deserialize(b, FlowWrapper.class);
			if (flowWrapper != null
					&& flowWrapper.metadata?.processMetadataValues != null
					&& !flowWrapper.metadata.processMetadataValues.isEmpty()
					&& flowWrapper.metadata.processMetadataValues.size() > 1) {
				String stringValue;
				if (flowWrapper.metadata.processMetadataValues[0]?.name == 'ObjectType') {
					stringValue = flowWrapper.metadata.processMetadataValues[0]?.value?.stringValue;
				} else if (flowWrapper.metadata.processMetadataValues[1]?.name == 'ObjectType') {
					stringValue = flowWrapper.metadata.processMetadataValues[1]?.value?.stringValue;
				}
				if (String.isNotBlank(stringValue) && objectNames.contains(stringValue)) {
					if (counts.containsKey(stringValue)) {
						counts.put(stringValue, counts.get(stringValue) + 1);
					} else {
						counts.put(stringValue, 1);
					}
				}
			}
		}
		return counts;
	}

	private static Map<String, Integer> getFlowCounts(Set<String> objectNames) {
		Map<String, Integer> counts = new Map<String, Integer>();
		for (String objectName : objectNames) {
			Integer count = [SELECT COUNT() FROM FlowDefinitionView WHERE IsActive = TRUE AND ProcessType NOT IN :PROCESS_BUILDER_TYPES AND TriggerObjectOrEventId = :objectName];
			counts.put(objectName, count);
		}
		return counts;
	}

	@AuraEnabled
	public static List<RecordCount> getRecordCounts(List<String> objectAPINames) {
		List<RecordCount> recordCounts = new List<RecordCount>();
		for (String objectAPIName : objectAPINames) {
			String query = new QBuilder(objectAPIName)
					.selectFields(new Set<String>{'COUNT()'})
					.build();
			try {
				Integer count = Database.countQuery(query);
				recordCounts.add(new RecordCount(objectAPIName, count));
			} catch (Exception e) {}
		}
		return recordCounts;
	}

	@AuraEnabled
	public static OrgAtAGlance getOrgAtAGlance() {
		OrgAtAGlance orgAtAGlance = new OrgAtAGlance();
		Organization org = [SELECT CreatedDate FROM Organization];
		Integer ageInDays = org.CreatedDate.date().daysBetween(Date.today());
		Decimal ageInYears = ageInDays / 365.0;
		orgAtAGlance.orgAge = ageInYears.setScale(2) + ' years';
		orgAtAGlance.standardObjects = 0;
		orgAtAGlance.customObjects = 0;
		orgAtAGlance.customMetadata = 0;
		orgAtAGlance.customSettings = 0;
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		for (String objectName : globalDescribe.keySet()) {
			Schema.DescribeSObjectResult describeSObjectResult = globalDescribe.get(objectName).getDescribe();
			String objectType = getObjectType(describeSObjectResult);
			if (String.isBlank(objectType)) continue;
			if (objectType.equals(STANDARD_OBJECTS_TYPE)) {
				orgAtAGlance.standardObjects++;
			} else if (objectType.equals(CUSTOM_OBJECTS_TYPE)) {
				orgAtAGlance.customObjects++;
			} else if (objectType.equals(CUSTOM_METADATA_TYPES_TYPE)) {
				orgAtAGlance.customMetadata++;
			} else if (objectType.equals(CUSTOM_SETTINGS_TYPE)) {
				orgAtAGlance.customSettings++;
			}
		}
		orgAtAGlance.workflows = 0;
		String query = 'SELECT COUNT(Id) cnt FROM WorkflowRule';
		List<Object> objects = SystemOverviewController.getToolingAPIObjects(query);
		for (Object obj : objects) {
			Map<String, Object> resultMap = (Map<String, Object>) obj;
			Integer count = Integer.valueOf(resultMap.get('cnt'));
			orgAtAGlance.workflows += count;
		}
		orgAtAGlance.processes = 0;
		orgAtAGlance.flows = 0;
		List<FlowDefinitionView> flowDefinitionViews = [
				SELECT Id, ProcessType
				FROM FlowDefinitionView
				WHERE IsActive = TRUE
		];
		for (FlowDefinitionView flowDefinitionView : flowDefinitionViews) {
			if (flowDefinitionView.ProcessType == 'Workflow'
					|| flowDefinitionView.ProcessType == 'CustomEvent'
					|| flowDefinitionView.ProcessType == 'InvocableProcess') {
				orgAtAGlance.processes++;
			} else if (flowDefinitionView.ProcessType != 'Appointments'
					&& flowDefinitionView.ProcessType != 'RoutingFlow'
					&& flowDefinitionView.ProcessType != 'ManagedContentAuthoringWorkflow') {
				orgAtAGlance.flows++;
			}
		}

		orgAtAGlance.triggers = 0;
		Integer triggerCount = [SELECT COUNT() FROM ApexTrigger WHERE Status = 'Active'];
		orgAtAGlance.triggers = triggerCount;

		orgAtAGlance.linesOfCode = 0;
		List<ApexClass> classes = [SELECT Body FROM ApexClass];
		for (ApexClass cls : classes) {
			if (cls.Body != null) {
				orgAtAGlance.linesOfCode += cls.Body.length() / 80;
			}
		}
		List<ApexTrigger> triggers = [SELECT Body FROM ApexTrigger];
		for (ApexTrigger trg : triggers) {
			if (trg.Body != null) {
				orgAtAGlance.linesOfCode += trg.Body.length() / 80;
			}
		}
		return orgAtAGlance;
	}

	@AuraEnabled
	public static List<ChartDataPercentage> getSystemOrgLimits() {
		List<ChartDataPercentage> chartDataPercentages = new List<ChartDataPercentage>();
		Map<String,System.OrgLimit> mapOrgLimits = OrgLimits.getMap();
		for (String key : mapOrgLimits.keySet()) {
			chartDataPercentages.add(new ChartDataPercentage(mapOrgLimits.get(key)));
		}
		return chartDataPercentages;
	}

	@AuraEnabled
	public static List<ChartDataPercentage> getLicenses() {
		List<ChartDataPercentage> chartDataPercentages = new List<ChartDataPercentage>();
		List<UserLicense> licenses = [SELECT Id, Name, TotalLicenses, UsedLicenses, Status FROM UserLicense];
		for (UserLicense license : licenses) {
			chartDataPercentages.add(new ChartDataPercentage(license));
		}
		return chartDataPercentages;
	}

	@AuraEnabled
	public static List<SObjectOption> getSObjectOptions() {
		List<SObjectOption> sObjectOptions = new List<SObjectOption>();
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		for (String objectName : globalDescribe.keySet()) {
			Schema.DescribeSObjectResult describeSObjectResult = globalDescribe.get(objectName).getDescribe();
			String objectType = getObjectType(describeSObjectResult);
			if (objectType == STANDARD_OBJECTS_TYPE || objectType == CUSTOM_OBJECTS_TYPE) {
				sObjectOptions.add(new SObjectOption(describeSObjectResult, objectType));
			}
		}
		return sObjectOptions;
	}

	@AuraEnabled
	public static List<SObjectOption> getFilteredSObjectOptions(List<SObjectOption> sObjectOptions) {
		List<SObjectOption> filteredSObjectOptions = new List<SObjectOption>();
		for (SObjectOption option : sObjectOptions) {
			String query = new QBuilder(option.value)
					.selectFields(new Set<String>{'COUNT()'})
					.build();
			try {
				if (Database.countQuery(query) > 0) {
					filteredSObjectOptions.add(option);
				}
			} catch (Exception e) {}
		}
		return filteredSObjectOptions;
	}

	@AuraEnabled
	public static List<ChartDataPercentage> getSObjectFields(String sObjectName) {
		List<ChartDataPercentage> chartDataPercentages = new List<ChartDataPercentage>();
		String query = new QBuilder(sObjectName)
				.selectFields(new Set<String>{'COUNT()'})
				.build();
		Integer max;
		try {
			max = Database.countQuery(query);
		} catch (Exception e) {}
		if (max != null) {
			Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
			if (sObjectType != null) {
				Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
				for (String fieldName : fieldMap.keySet()) {
					Schema.DescribeFieldResult describeFieldResult = fieldMap.get(fieldName).getDescribe();
					if (describeFieldResult.isAccessible()
							&& describeFieldResult.isFilterable()
							&& describeFieldResult.getType() != Schema.DisplayType.BOOLEAN
							&& !describeFieldResult.isCalculated()
							&& !describeFieldResult.isAutoNumber()
							&& !fieldName.toLowerCase().contains('id')
							&& !fieldName.toLowerCase().endsWith('date')
							&& !fieldName.toLowerCase().endsWith('time')
							&& !fieldName.toLowerCase().startsWith('system')
							&& !fieldName.toLowerCase().startsWith('last')) {
						chartDataPercentages.add(new ChartDataPercentage(describeFieldResult, max));
					}
				}
			}
		}
		return chartDataPercentages;
	}

	@AuraEnabled
	public static List<ChartDataPercentage> getFilledSObjectFields(String sObjectName, List<ChartDataPercentage> chartDataPercentages) {
		for (ChartDataPercentage chartDataPercentage : chartDataPercentages) {
			chartDataPercentage.value = getCountRecordsWithEmptyField(sObjectName, chartDataPercentage.name);
			chartDataPercentage.setPercentage();
			chartDataPercentage.setColor();
		}
		return chartDataPercentages;
	}

	private static Integer getCountRecordsWithEmptyField(String sObjectName, String fieldName) {
		Integer count = 0;
		String query = new QBuilder(sObjectName)
				.selectFields(new Set<String>{'COUNT()'})
				.add(QBuilder.condition(fieldName).isNull())
				.build();
		try {
			count = Database.countQuery(query);
		} catch (Exception e) {}
		return count;
	}

	public class SObjectOption {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public String namespacePrefix { get; set; }
		@AuraEnabled
		public String type { get; set; }
		public SObjectOption() {}
		public SObjectOption(Schema.DescribeSObjectResult describeSObjectResult, String objectType) {
			this.label = describeSObjectResult.label;
			this.value = describeSObjectResult.name;
			this.type = objectType;
			this.namespacePrefix = value.countMatches('__') > 1 ? value.substringBefore('__') : null;
		}
	}

	public class SObjectEmptyFields {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public List<ChartDataPercentage> chartDataPercentages;
	}

	public class UsersInfo {
		@AuraEnabled
		public Integer numberOfActiveUsers;
		@AuraEnabled
		public Integer numberOfNoActivityInLast30Days;
		@AuraEnabled
		public Integer numberOfUsers;
		@AuraEnabled
		public Integer numberOfInactiveUsers;
	}

	public class CodeInfo {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String namespacePrefix;
		@AuraEnabled
		public Integer count;
	}

	public class CodeInfoDetail {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String fullName;
		@AuraEnabled
		public String apiVersion;
		@AuraEnabled
		public String namespacePrefix;
	}

	public class ChartDataPercentage {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public Integer max { get; set; }
		@AuraEnabled
		public Integer value { get; set; }
		@AuraEnabled
		public Decimal percentage { get; set; }
		@AuraEnabled
		public String color { get; set; }
		public ChartDataPercentage() {}
		public ChartDataPercentage(Schema.DescribeFieldResult describeFieldResult, Integer max) {
			this.label = describeFieldResult.label;
			this.name = describeFieldResult.name;
			this.max = max;
		}
		public ChartDataPercentage(OrgLimit orgLimit) {
			this.label = orgLimit.getName();
			this.name = orgLimit.getName();
			this.max = orgLimit.getLimit();
			this.value = orgLimit.getValue();
			setPercentage();
			setColor();
		}
		public ChartDataPercentage(UserLicense license) {
			this.label = license.Name;
			this.name = license.Name;
			this.max = license.TotalLicenses;
			this.value = license.UsedLicenses;
			setPercentage();
			setColorRevers();
		}
		public void setPercentage() {
			if (this.max == 0) {
				this.percentage = 0;
			} else if (this.value >= this.max) {
				this.percentage = 100;
			} else {
				this.percentage = Decimal.valueOf(value) * 100 / max;
			}
		}
		public void setColor() {
			if (this.percentage <= 50) {
				this.color = PROGRESS_COLOR_SUCCESS;
			} else if (this.percentage <= 80) {
				this.color = PROGRESS_COLOR_WARNING;
			} else {
				this.color = PROGRESS_COLOR_ERROR;
			}
		}
		public void setColorRevers() {
			if (this.percentage <= 50) {
				this.color = PROGRESS_COLOR_ERROR;
			} else if (this.percentage <= 80) {
				this.color = PROGRESS_COLOR_WARNING;
			} else {
				this.color = PROGRESS_COLOR_SUCCESS;
			}
		}
	}

	public class ChartDataCount {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String type {get; set;}
		@AuraEnabled
		public String subName {get; set;}
		@AuraEnabled
		public Integer count {get; set;}
		@AuraEnabled
		public List<ChartDataStackingCount> stackingCounts {get; set;}
		public ChartDataCount() {}
		public ChartDataCount(User user) {
			this.id = user.Id.to15();
			this.name = user.Name;
			this.label = user.Name;
			this.subName = user.Profile.Name;
			this.stackingCounts = new List<ChartDataStackingCount>();
		}
		public ChartDataCount(PermissionSetAssignment psa) {
			this.id = psa.AssigneeId.to15();
			this.name = psa.Assignee.Name;
			this.label = psa.PermissionSet.Name;
			this.subName = psa.Assignee.Profile.Name;
			this.stackingCounts = new List<ChartDataStackingCount>();
		}

		public void addStackingCount(String name, String type, String subName, Integer count) {
			this.stackingCounts.add(new ChartDataStackingCount(name, type, subName, count));
		}
	}

	public class ChartDataStackingCount {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String subName;
		@AuraEnabled
		public Integer count;

		public ChartDataStackingCount(String name, String type, String subName, Integer count) {
			this.name = name;
			this.type = type;
			this.subName = subName;
			this.count = count;
		}
	}

	public class ObjectInfo {
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String type {get; set;}
		@AuraEnabled
		public String namespacePrefix { get; set; }
		@AuraEnabled
		public Integer recordCount {get; set;}
		@AuraEnabled
		public List<ObjectInfoAutomation> automations {get; set;}
		public ObjectInfo() {}
		public ObjectInfo(Schema.DescribeSObjectResult describeSObjectResult, String objectType) {
			this.name = describeSObjectResult.name;
			this.label = describeSObjectResult.label;
			this.type = objectType;
			this.namespacePrefix = name.countMatches('__') > 1 ? name.substringBefore('__') : null;
		}
	}

	public class ObjectInfoAutomation {
		@AuraEnabled
		public String type {get; set;}
		@AuraEnabled
		public Integer count {get; set;}
	}

	public class OrgAtAGlance {
		@AuraEnabled
		public String orgAge;
		@AuraEnabled
		public Integer standardObjects;
		@AuraEnabled
		public Integer customObjects;
		@AuraEnabled
		public Integer customMetadata;
		@AuraEnabled
		public Integer customSettings;
		@AuraEnabled
		public Integer workflows;
		@AuraEnabled
		public Integer processes;
		@AuraEnabled
		public Integer flows;
		@AuraEnabled
		public Integer triggers;
		@AuraEnabled
		public Integer linesOfCode;
	}

	public class RecordCount {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Integer count;
		public RecordCount(String name, Integer count) {
			this.name = name;
			this.count = count;
		}
	}

	public class FlowWrapper {
		MetadataWrapper metadata;
	}
	public class MetadataWrapper {
		List<ProcessMetadataValuesWrapper> processMetadataValues;
	}
	public class ProcessMetadataValuesWrapper {
		String name;
		FlowElementReferenceOrValueWrapper value;
	}
	public class FlowElementReferenceOrValueWrapper {
		String stringValue;
	}

}