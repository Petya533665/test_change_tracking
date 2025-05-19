public with sharing class DevOpsCenterBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

	private Connected_Org__c corg;
	private Set<String> setIssueIds;
	private List<Issue__c> issuesToUpdate;

	private static final String WORK_ITEM_URL = '/sf_devops/DevOpsCenter.app?projectId={0}&workItemId={1}';

	private static final String RECORDS = 'records';

	private static final String DEPLOYMENT_RESULT_OBJECT_API_NAME = 'sf_devops__Deployment_Result__c';
	private static final String MERGE_RESULT_OBJECT_API_NAME = 'sf_devops__Merge_Result__c';
	private static final String WORK_ITEM_OBJECT_API_NAME = 'sf_devops__Work_Item__c';
	private static final String PROJECT_OBJECT_API_NAME = 'sf_devops__Project__c';
	private static final String WORK_ITEM_PROMOTES_RELATED_OBJECT_API_NAME = 'sf_devops__Work_Item_Promotes__r';
	private static final String CHANGE_BUNDLE_INSTALLS_RELATED_OBJECT_API_NAME = 'sf_devops__Change_Bundle_Installs__r';
	private static final String COMPONENTS_RELATED_OBJECT_API_NAME = 'sf_devops__Components__r';
	private static final String PLATFORM_REPOSITORY_RELATED_OBJECT_API_NAME = 'sf_devops__Platform_Repository__r';

	private static final String ID_FIELD_API_NAME = 'Id';
	private static final String NAME_FIELD_API_NAME = 'Name';
	private static final String DEPLOYMENT_ID_FIELD_API_NAME = 'sf_devops__Deployment_Id__c';
	private static final String COMPLETION_DATE_FIELD_API_NAME = 'sf_devops__Completion_Date__c';
	private static final String MERGE_RESULT_FIELD_API_NAME = 'sf_devops__Merge_Result__c';
	private static final String WORK_ITEM_FIELD_API_NAME = 'sf_devops__Work_Item__c';
	private static final String CHANGE_BUNDLE_FIELD_API_NAME = 'sf_devops__Change_Bundle__c';
	private static final String DEPLOYMENT_RESULT_FIELD_API_NAME = 'sf_devops__Deployment_Result__c';
	private static final String FILE_PATH_FIELD_API_NAME = 'sf_devops__File_Path__c';
	private static final String OPERATION_FIELD_API_NAME = 'sf_devops__Operation__c';
	private static final String SOURCE_COMPONENT_FIELD_API_NAME = 'sf_devops__Source_Component__c';
	private static final String PREVIOUS_REMOTE_REFERENCE_FIELD_API_NAME = 'sf_devops__Previous_Remote_Reference__c';
	private static final String REMOTE_REFERENCE_FIELD_API_NAME = 'sf_devops__Remote_Reference__c';
	private static final String SOURCE_BRANCH_NAME_FIELD_API_NAME = 'sf_devops__Source_Branch_Name__c';
	private static final String TARGET_BRANCH_NAME_FIELD_API_NAME = 'sf_devops__Target_Branch_Name__c';
	private static final String PROJECT_FIELD_API_NAME = 'sf_devops__Project__c';
	private static final String SUBJECT_FIELD_API_NAME = 'sf_devops__Subject__c';
	private static final String DESCRIPTION_FIELD_API_NAME = 'sf_devops__Description__c';
	private static final String DEFAULT_BRANCH_FIELD_API_NAME = 'sf_devops__Default_Branch__c';
	private static final String GITHUB_OWNER_FIELD_API_NAME = 'sf_devops__GitHub_Owner__c';
	private static final String GITHUB_REPO_FIELD_API_NAME = 'sf_devops__GitHub_Repo__c';

	private static final Set<String> DEPLOYMENT_RESULT_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Deployment_Id__c',
			'sf_devops__Completion_Date__c'
	};

	private static final Set<String> WORK_ITEM_PROMOTE_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Merge_Result__c',
			'sf_devops__Work_Item__c'
	};

	private static final Set<String> CHANGE_BUNDLE_INSTALL_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Merge_Result__c',
			'sf_devops__Change_Bundle__c'
	};

	private static final Set<String> COMPONENT_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Deployment_Result__c',
			'sf_devops__File_Path__c',
			'sf_devops__Operation__c',
			'sf_devops__Source_Component__c'
	};

	private static final Set<String> MERGE_RESULT_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Previous_Remote_Reference__c',
			'sf_devops__Remote_Reference__c',
			'sf_devops__Source_Branch_Name__c',
			'sf_devops__Target_Branch_Name__c'
	};

	private static final Set<String> WORK_ITEM_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Change_Bundle__c',
			'sf_devops__Project__c',
			'sf_devops__Subject__c',
			'sf_devops__Description__c'
	};

	private static final Set<String> PROJECT_FIELDS = new Set<String>{
			'Id',
			'Name',
			'sf_devops__Platform_Repository__r.Id',
			'sf_devops__Platform_Repository__r.Name',
			'sf_devops__Platform_Repository__r.sf_devops__Default_Branch__c',
			'sf_devops__Platform_Repository__r.sf_devops__GitHub_Owner__c',
			'sf_devops__Platform_Repository__r.sf_devops__GitHub_Repo__c'
	};

	private static DevOpsCenterBatch instance = null;

	public static DevOpsCenterBatch getInstance(Set<String> setIssueIds) {
		if (instance == null) {
			instance = new DevOpsCenterBatch(setIssueIds, Logger.getInstance());
		}
		return instance;
	}

	private DevOpsCenterBatch(Set<String> setIssueIds, Logger logger) {
		super(logger);
		this.corg = ConnectedOrgService.getDevOpsCenterConnectedOrg();
		this.setIssueIds = setIssueIds;
		this.issuesToUpdate = new List<Issue__c>();
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('DevOpsCenterBatch', this);
	}

	public override Boolean initialValidation() {
		return Boolean.valueOf(DevOpsCenterController.validateDevOpsCenter().get(DevOpsCenterController.IS_VALID_KEY));
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Issue__c WHERE Id IN :setIssueIds];
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, Log__c FROM Issue__c WHERE Id IN :setIssueIds]);
	}

	public void execute(Database.BatchableContext BC, List<Issue__c> scope) {
		if (corg != null) {
			List<LogPostProcessingService.DeployResult> deployResults = getDeployResults(scope[0].Log__c);
			if (deployResults != null && !deployResults.isEmpty()) {
				Set<String> deployResultIds = new Set<String>();
				for (LogPostProcessingService.DeployResult deployResult : deployResults) {
					deployResultIds.add(String.valueOf(deployResult.id));
				}
				String deploymentResultQuery = getDeploymentResultQuery(deployResultIds);
				List<Object> deploymentResultRecords = runQuery(corg, deploymentResultQuery);
				List<DeploymentResult> deploymentResults = new List<DeploymentResult>();
				fillDeploymentResultWrapper(deploymentResults, deploymentResultRecords);
				Set<String> workItemIds = new Set<String>();
				Set<String> changeBundleIds = new Set<String>();
				Set<String> mergeResultIds = new Set<String>();
				for (DeploymentResult deploymentResult : deploymentResults) {
					if (deploymentResult.workItemPromotes != null) {
						for (WorkItemPromote workItemPromote : deploymentResult.workItemPromotes) {
							mergeResultIds.add(workItemPromote.mergeResult);
							workItemIds.add(workItemPromote.workItem);
						}
					}
					if (deploymentResult.changeBundleInstalls != null) {
						for (ChangeBundleInstall changeBundleInstall : deploymentResult.changeBundleInstalls) {
							mergeResultIds.add(changeBundleInstall.mergeResult);
							changeBundleIds.add(changeBundleInstall.changeBundle);
						}
					}
				}
				String mergeResultQuery = getMergeResultQuery(mergeResultIds);
				List<Object> mergeResultRecords = runQuery(corg, mergeResultQuery);
				fillMergeResultWrapper(deploymentResults, mergeResultRecords);
				String workItemQuery = getWorkItemQuery(workItemIds, changeBundleIds);
				List<Object> workItemRecords = runQuery(corg, workItemQuery);
				Set<String> projectIds = new Set<String>();
				fillWorkItemWrapper(deploymentResults, workItemRecords, projectIds, corg.Instance_Url__c);
				String projectQuery = getProjectQuery(projectIds);
				List<Object> projectRecords = runQuery(corg, projectQuery);
				fillProjectWrapper(deploymentResults, projectRecords);
				if (!deploymentResults.isEmpty()) {
					issuesToUpdate.add(new Issue__c(Id = scope[0].Id, Source_Control_Metadata__c = JSON.serialize(deploymentResults), DevOps_Center_Metadata_Available__c = true));
				}
			}
		}
	}

	public void finish(Database.BatchableContext BC) {
		if (!issuesToUpdate.isEmpty()) {
			DatabaseUtils.getInstance().performUpdateDML(issuesToUpdate, Schema.SObjectType.Issue__c)
					.handleError(DevOpsCenterBatch.class.getName(), 'finish', loggerInstance);
		}
		loggerInstance?.flush();
	}

	public static void fillDeploymentResultWrapper(List<DeploymentResult> deploymentResults, List<Object> deploymentResultRecords) {
		for (Object deploymentResultRecord : deploymentResultRecords) {
			Map<String, Object> mapDeploymentResultRecord = (Map<String, Object>)deploymentResultRecord;
			DeploymentResult deploymentResult = new DeploymentResult();
			deploymentResult.id = (String)mapDeploymentResultRecord.get(ID_FIELD_API_NAME);
			deploymentResult.name = (String)mapDeploymentResultRecord.get(NAME_FIELD_API_NAME);
			deploymentResult.deploymentId = (String)mapDeploymentResultRecord.get(DEPLOYMENT_ID_FIELD_API_NAME);
			deploymentResult.completionDate = (String)mapDeploymentResultRecord.get(COMPLETION_DATE_FIELD_API_NAME);
			if (mapDeploymentResultRecord.get(WORK_ITEM_PROMOTES_RELATED_OBJECT_API_NAME) != null) {
				if (deploymentResult.workItemPromotes == null) deploymentResult.workItemPromotes = new List<WorkItemPromote>();
				Map<String, Object> mapWorkItemPromotes = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapDeploymentResultRecord.get(WORK_ITEM_PROMOTES_RELATED_OBJECT_API_NAME)));
				List<Object> workItemPromoteRecords = (List<Object>)mapWorkItemPromotes.get(RECORDS);
				for (Object workItemPromoteRecord : workItemPromoteRecords) {
					Map<String, Object> mapWorkItemPromoteRecord = (Map<String, Object>)workItemPromoteRecord;
					WorkItemPromote workItemPromote = new WorkItemPromote();
					workItemPromote.id = (String)mapWorkItemPromoteRecord.get(ID_FIELD_API_NAME);
					workItemPromote.name = (String)mapWorkItemPromoteRecord.get(NAME_FIELD_API_NAME);
					workItemPromote.mergeResult = (String)mapWorkItemPromoteRecord.get(MERGE_RESULT_FIELD_API_NAME);
					workItemPromote.workItem = (String)mapWorkItemPromoteRecord.get(WORK_ITEM_FIELD_API_NAME);
					deploymentResult.workItemPromotes.add(workItemPromote);
				}
			}
			if (mapDeploymentResultRecord.get(CHANGE_BUNDLE_INSTALLS_RELATED_OBJECT_API_NAME) != null) {
				if (deploymentResult.changeBundleInstalls == null) deploymentResult.changeBundleInstalls = new List<ChangeBundleInstall>();
				Map<String, Object> mapChangeBundleInstalls = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapDeploymentResultRecord.get(CHANGE_BUNDLE_INSTALLS_RELATED_OBJECT_API_NAME)));
				List<Object> changeBundleInstallRecords = (List<Object>)mapChangeBundleInstalls.get(RECORDS);
				for (Object changeBundleInstallRecord : changeBundleInstallRecords) {
					Map<String, Object> mapChangeBundleInstallRecord = (Map<String, Object>)changeBundleInstallRecord;
					ChangeBundleInstall changeBundleInstall = new ChangeBundleInstall();
					changeBundleInstall.id = (String)mapChangeBundleInstallRecord.get(ID_FIELD_API_NAME);
					changeBundleInstall.name = (String)mapChangeBundleInstallRecord.get(NAME_FIELD_API_NAME);
					changeBundleInstall.mergeResult = (String)mapChangeBundleInstallRecord.get(MERGE_RESULT_FIELD_API_NAME);
					changeBundleInstall.changeBundle = (String)mapChangeBundleInstallRecord.get(CHANGE_BUNDLE_FIELD_API_NAME);
					deploymentResult.changeBundleInstalls.add(changeBundleInstall);
				}
			}
			if (mapDeploymentResultRecord.get(COMPONENTS_RELATED_OBJECT_API_NAME) != null) {
				if (deploymentResult.deployComponents == null) deploymentResult.deployComponents = new List<DeployComponent>();
				Map<String, Object> mapDeployComponents = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapDeploymentResultRecord.get(COMPONENTS_RELATED_OBJECT_API_NAME)));
				List<Object> deployComponentRecords = (List<Object>)mapDeployComponents.get(RECORDS);
				for (Object deployComponentRecord : deployComponentRecords) {
					Map<String, Object> mapDeployComponentRecord = (Map<String, Object>)deployComponentRecord;
					DeployComponent deployComponent = new DeployComponent();
					deployComponent.id = (String)mapDeployComponentRecord.get(ID_FIELD_API_NAME);
					deployComponent.name = (String)mapDeployComponentRecord.get(NAME_FIELD_API_NAME);
					deployComponent.deploymentResult = (String)mapDeployComponentRecord.get(DEPLOYMENT_RESULT_FIELD_API_NAME);
					deployComponent.filePath = (String)mapDeployComponentRecord.get(FILE_PATH_FIELD_API_NAME);
					deployComponent.operation = (String)mapDeployComponentRecord.get(OPERATION_FIELD_API_NAME);
					deployComponent.sourceComponent = (String)mapDeployComponentRecord.get(SOURCE_COMPONENT_FIELD_API_NAME);
					deploymentResult.deployComponents.add(deployComponent);
				}
			}
			deploymentResults.add(deploymentResult);
		}
	}

	public static void fillMergeResultWrapper(List<DeploymentResult> deploymentResults, List<Object> mergeResultRecords) {
		for (Object mergeResultRecord : mergeResultRecords) {
			Map<String, Object> mapMergeResultRecord = (Map<String, Object>)mergeResultRecord;
			MergeResult mergeResult = new MergeResult();
			mergeResult.id = (String)mapMergeResultRecord.get(ID_FIELD_API_NAME);
			mergeResult.name = (String)mapMergeResultRecord.get(NAME_FIELD_API_NAME);
			mergeResult.previousRemoteReference = (String)mapMergeResultRecord.get(PREVIOUS_REMOTE_REFERENCE_FIELD_API_NAME);
			mergeResult.remoteReference = (String)mapMergeResultRecord.get(REMOTE_REFERENCE_FIELD_API_NAME);
			mergeResult.sourceBranchName = (String)mapMergeResultRecord.get(SOURCE_BRANCH_NAME_FIELD_API_NAME);
			mergeResult.targetBranchName = (String)mapMergeResultRecord.get(TARGET_BRANCH_NAME_FIELD_API_NAME);
			for (DeploymentResult deploymentResult : deploymentResults) {
				Boolean exist = false;
				if (deploymentResult.workItemPromotes != null) {
					for (WorkItemPromote workItemPromote : deploymentResult.workItemPromotes) {
						if (mergeResult.id == workItemPromote.mergeResult) {
							exist = true;
							break;
						}
					}
				}
				if (deploymentResult.changeBundleInstalls != null) {
					for (ChangeBundleInstall changeBundleInstall : deploymentResult.changeBundleInstalls) {
						if (mergeResult.id == changeBundleInstall.mergeResult) {
							exist = true;
							break;
						}
					}
				}
				if (exist) {
					deploymentResult.mergeResult = mergeResult;
				}
			}
		}
	}

	public static void fillWorkItemWrapper(List<DeploymentResult> deploymentResults, List<Object> mergeResultRecords, Set<String> projectIds, String instanceUrl) {
		for (Object workItemRecord : mergeResultRecords) {
			Map<String, Object> mapWorkItemRecord = (Map<String, Object>)workItemRecord;
			WorkItem workItem = new WorkItem();
			workItem.id = (String)mapWorkItemRecord.get(ID_FIELD_API_NAME);
			workItem.name = (String)mapWorkItemRecord.get(NAME_FIELD_API_NAME);
			workItem.changeBundle = (String)mapWorkItemRecord.get(CHANGE_BUNDLE_FIELD_API_NAME);
			workItem.project = (String)mapWorkItemRecord.get(PROJECT_FIELD_API_NAME);
			workItem.subject = (String)mapWorkItemRecord.get(SUBJECT_FIELD_API_NAME);
			workItem.description = (String)mapWorkItemRecord.get(DESCRIPTION_FIELD_API_NAME);
			workItem.url = instanceUrl + String.format(WORK_ITEM_URL, new List<String>{workItem.project, workItem.id});
			for (DeploymentResult deploymentResult : deploymentResults) {
				Boolean exist = false;
				if (deploymentResult.workItemPromotes != null) {
					for (WorkItemPromote workItemPromote : deploymentResult.workItemPromotes) {
						if (workItem.id == workItemPromote.workItem) {
							exist = true;
							break;
						}
					}
				}
				if (deploymentResult.changeBundleInstalls != null && String.isNotBlank(workItem.changeBundle)) {
					for (ChangeBundleInstall changeBundleInstall : deploymentResult.changeBundleInstalls) {
						if (workItem.changeBundle == changeBundleInstall.changeBundle) {
							exist = true;
							break;
						}
					}
				}
				if (exist) {
					if (deploymentResult.workItems == null) {
						deploymentResult.workItems = new List<WorkItem>{workItem};
					} else {
						deploymentResult.workItems.add(workItem);
					}
				}
			}
			projectIds.add(workItem.project);
		}
	}

	public static void fillProjectWrapper(List<DeploymentResult> deploymentResults, List<Object> projectRecords) {
		for (Object projectRecord : projectRecords) {
			Map<String, Object> mapProjectRecord = (Map<String, Object>)projectRecord;
			Project project = new Project();
			project.id = (String)mapProjectRecord.get(ID_FIELD_API_NAME);
			project.name = (String)mapProjectRecord.get(NAME_FIELD_API_NAME);
			Map<String, Object> mapRepository = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapProjectRecord.get(PLATFORM_REPOSITORY_RELATED_OBJECT_API_NAME)));
			Repository repository = new Repository();
			repository.id = (String)mapRepository.get(ID_FIELD_API_NAME);
			repository.name = (String)mapRepository.get(NAME_FIELD_API_NAME);
			repository.defaultBranch = (String)mapRepository.get(DEFAULT_BRANCH_FIELD_API_NAME);
			repository.gitHubOwner = (String)mapRepository.get(GITHUB_OWNER_FIELD_API_NAME);
			repository.gitHubRepo = (String)mapRepository.get(GITHUB_REPO_FIELD_API_NAME);
			project.platformRepository = repository;
			for (DeploymentResult deploymentResult : deploymentResults) {
				Boolean exist = false;
				if (deploymentResult.workItems != null) {
					for (WorkItem workItem : deploymentResult.workItems) {
						if (project.id == workItem.project) {
							exist = true;
							break;
						}
					}
					if (exist) deploymentResult.project = project;
				}
			}
		}
	}

	public static List<Object> runQuery(Connected_Org__c corg, String query) {
		return ConnectedOrgService.isSelfConnectedOrg(corg) ? Database.query(query) : getDevOpsCenterData(corg, query);
	}

	public static List<Object> getDevOpsCenterData(Connected_Org__c corg, String query) {
		Map<String, String> headers = ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg));
		String b = HttpUtils.get(
				corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + EncodingUtil.urlEncode(query, 'UTF-8'),
				headers,
				200
		);
		Map<String, Object> objectMap = (Map<String, Object>)JSON.deserializeUntyped(b);
		return (List<Object>)objectMap.get(RECORDS);
	}

	public static List<LogPostProcessingService.DeployResult> getDeployResults(String logId) {
		List<Log__c> logs = [SELECT Id, Deploy_Results__c FROM Log__c WHERE Id = :logId];
		if (!logs.isEmpty()) {
			return (List<LogPostProcessingService.DeployResult>)JSON.deserialize(logs[0].Deploy_Results__c, List<LogPostProcessingService.DeployResult>.class);
		}
		return null;
	}

	public static String getDeploymentResultQuery(Set<String> deployResultIds) {
		String query = new QBuilder(DEPLOYMENT_RESULT_OBJECT_API_NAME)
				.selectFields(DEPLOYMENT_RESULT_FIELDS)
				.addSubquery(new QBuilder(WORK_ITEM_PROMOTES_RELATED_OBJECT_API_NAME)
						.selectFields(WORK_ITEM_PROMOTE_FIELDS))
				.addSubquery(new QBuilder(CHANGE_BUNDLE_INSTALLS_RELATED_OBJECT_API_NAME)
						.selectFields(CHANGE_BUNDLE_INSTALL_FIELDS))
				.addSubquery(new QBuilder(COMPONENTS_RELATED_OBJECT_API_NAME)
						.selectFields(COMPONENT_FIELDS))
				.add(QBuilder.condition(DEPLOYMENT_ID_FIELD_API_NAME).isIn(new List<String>(deployResultIds)))
				.build();
		return query;
	}

	public static String getMergeResultQuery(Set<String> mergeResultIds) {
		String query = new QBuilder(MERGE_RESULT_OBJECT_API_NAME)
				.selectFields(MERGE_RESULT_FIELDS)
				.add(QBuilder.condition(ID_FIELD_API_NAME).isIn(new List<String>(mergeResultIds)))
				.build();
		return query;
	}

	public static String getWorkItemQuery(Set<String> workItemIds, Set<String> changeBundleIds) {
		String query = new QBuilder(WORK_ITEM_OBJECT_API_NAME)
				.selectFields(WORK_ITEM_FIELDS)
				.add(!workItemIds.isEmpty() ? QBuilder.condition(ID_FIELD_API_NAME).isIn(new List<String>(workItemIds)) : null)
				.add(!changeBundleIds.isEmpty() ? QBuilder.condition(CHANGE_BUNDLE_FIELD_API_NAME).isIn(new List<String>(changeBundleIds)) : null)
				.build();
		if (!workItemIds.isEmpty() && !changeBundleIds.isEmpty())query = query.replaceAll(' AND ', ' OR ');
		return query;
	}

	public static String getProjectQuery(Set<String> projectIds) {
		String query = new QBuilder(PROJECT_OBJECT_API_NAME)
				.selectFields(PROJECT_FIELDS)
				.add(QBuilder.condition(ID_FIELD_API_NAME).isIn(new List<String>(projectIds)))
				.build();
		return query;
	}

	public class DeploymentResult {
		public String id;
		public String name;
		public String deploymentId;
		public String completionDate;
		public MergeResult mergeResult;
		public Project project;
		public List<WorkItem> workItems;
		public List<WorkItemPromote> workItemPromotes;
		public List<ChangeBundleInstall> changeBundleInstalls;
		public List<DeployComponent> deployComponents;
	}

	public class WorkItemPromote {
		public String id;
		public String name;
		public String mergeResult;
		public String workItem;
	}

	public class ChangeBundleInstall {
		public String id;
		public String name;
		public String mergeResult;
		public String changeBundle;
	}

	public class DeployComponent {
		public String id;
		public String name;
		public String deploymentResult;
		public String filePath;
		public String operation;
		public String sourceComponent;
	}

	public class MergeResult {
		public String id;
		public String name;
		public String previousRemoteReference;
		public String remoteReference;
		public String sourceBranchName;
		public String targetBranchName;
	}

	public class WorkItem {
		public String id;
		public String name;
		public String changeBundle;
		public String project;
		public String subject;
		public String description;
		public String url;
	}

	public class Project {
		public String id;
		public String name;
		public Repository platformRepository;
	}

	public class Repository {
		public String id;
		public String name;
		public String defaultBranch;
		public String gitHubOwner;
		public String gitHubRepo;
	}

}