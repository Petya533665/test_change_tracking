@IsTest
@TestVisible
private class GitHubCommitBatchTest {

	private static final String TEST_GIT_API_USERNAME = 'someusername';
	@TestVisible
	private static final String TEST_GIT_API_EXT_USERNAME = 'someusername2';
	@TestVisible
	private static final String TEST_GIT_API_TOKEN = 'token';
	private static final String TEST_GIT_API_OAUTH_TOKEN = 'oauthtoken';
	private static final String TEST_GIT_API_REPONAME = 'reponame';
	@TestVisible
	private static final String TEST_GIT_API_EXT_REPONAME = 'reponame2';
	private static final String TEST_GIT_API_BRANCH_NAME = 'master';
	@TestVisible
	private static final String TEST_GIT_API_EXT_BRANCH_NAME = 'master2';

	@TestVisible
	private static final String TEST_GIT_API_EXT_REPOSITORY_URL = 'https://github.com/someusername2/reponame2.git';
	@TestVisible
	private static final String TEST_GIT_API_REPOSITORY_URL = 'https://github.com/someusername/reponame.git';

	@TestSetup
	private static void testSetup() {
		ConfigUtil.GIT_API_SETTINGS.Username__c = TEST_GIT_API_USERNAME;
		ConfigUtil.GIT_API_SETTINGS.Token__c = TEST_GIT_API_TOKEN;
		ConfigUtil.GIT_API_SETTINGS.oauth_Token__c = TEST_GIT_API_OAUTH_TOKEN;
		ConfigUtil.GIT_API_SETTINGS.Reponame__c = TEST_GIT_API_REPONAME;
		ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = TEST_GIT_API_BRANCH_NAME;
		upsert ConfigUtil.GIT_API_SETTINGS;
	}

	@IsTest
	static void test_audit_trail_changes_apex_class() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};

		createMockApexClasses(new List<String>{'someApexClassName','someChangedApexClass'});

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = 'someId';
		upsert ConfigUtil.GIT_API_SETTINGS;

		Map<String, Object> dataMap = new Map<String, Object>();
		dataMap.put('Id', 'someNewTrailId');
		dataMap.put('Display', 'someChangedApexClass');
		dataMap.put('Section', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS);
		List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
		dataMapList.add(dataMap);

		GitHubCommitBatch.mockAuditTrails = (List<SetupAuditTrail>)JSON.deserialize(JSON.serialize(dataMapList), List<SetupAuditTrail>.class);

		Test.startTest();
		List<GitHubCommitBatch.MetadataTypeWrapper> items = GitHubCommitBatch.getMetadataTypeMembers();
		Test.stopTest();
		system.assertEquals(1, items.size());
		system.assertEquals(true, items.get(0).member.contains('someChangedApexClass'));
		system.assertEquals('someNewTrailId', ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c);
	}

	@IsTest
	static void test_get_git_user_info() {
		GitHubUtils.GitUserInfo userInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserEndpoint(), getGitAPIUserMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		userInfo = GitHubUtils.getGitUserInfo(TEST_GIT_API_TOKEN);
		Test.stopTest();

		System.assertEquals(TEST_GIT_API_USERNAME, userInfo.login);
	}

	@IsTest
	static void test_get_git_own_user_repos() {
		List<GitHubUtils.GitReposInfo> reposInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserReposEndpoint(), getGitAPIUserReposMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Map<String, Object> data = new Map<String, Object>{
			'reponame' => null
		};
		reposInfo = GitHubUtils.getReposInfos(data);
		Test.stopTest();

		System.assertEquals(2, reposInfo.size());
		System.assertEquals(TEST_GIT_API_REPONAME, reposInfo.get(0).name);
		System.assertEquals(TEST_GIT_API_EXT_REPONAME, reposInfo.get(1).name);
	}

	@IsTest
	static void test_get_git_user_repos_by_name() {
		List<GitHubUtils.GitReposInfo> reposInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserReposEndpoint(), getGitAPIUserReposMock());
		endpoint2TestResp.put(getGitAPIUserReposByNameEndpoint(TEST_GIT_API_EXT_REPONAME), getGitAPIUserReposByNameMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Map<String, Object> data = new Map<String, Object>{
			'reponame' => TEST_GIT_API_EXT_REPONAME
		};
		reposInfo = GitHubUtils.getReposInfos(data);
		Test.stopTest();

		System.assertEquals(1, reposInfo.size());
		System.assertEquals(TEST_GIT_API_EXT_REPONAME, reposInfo.get(0).name);
	}

	@IsTest
	static void test_get_git_user_own_repo_branches() {
		List<GitHubUtils.GitRepoBranchInfo> repoBranchesInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserOwnRepoBranchesEndpoint(), getGitAPIUserOwnRepoBranchesMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Map<String, Object> data = new Map<String, Object>{
			'reponame' => TEST_GIT_API_REPONAME
		};
		repoBranchesInfo = GitHubUtils.getRepoBranchesInfos(data);
		Test.stopTest();

		System.assertEquals(1, repoBranchesInfo.size());
		System.assertEquals(TEST_GIT_API_BRANCH_NAME, repoBranchesInfo.get(0).name);
	}

	@IsTest
	static void test_get_git_user_ext_repo_branches() {
		List<GitHubUtils.GitRepoBranchInfo> repoBranchesInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserExtRepoBranchesEndpoint(), getGitAPIUserExtRepoBranchesMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Map<String, Object> data = new Map<String, Object>{
			'owner' => TEST_GIT_API_EXT_USERNAME,
			'reponame' => TEST_GIT_API_EXT_REPONAME
		};
		repoBranchesInfo = GitHubUtils.getRepoBranchesInfos(data);
		Test.stopTest();

		System.assertEquals(1, repoBranchesInfo.size());
		System.assertEquals(TEST_GIT_API_EXT_BRANCH_NAME, repoBranchesInfo.get(0).name);
	}

	@IsTest
	static void test_get_git_user_ext_repo_branches_by_name() {
		List<GitHubUtils.GitRepoBranchInfo> repoBranchesInfo;

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(getGitAPIUserExtRepoBranchesByNameEndpoint(), getGitAPIUserExtRepoBranchesByNameMock());

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Map<String, Object> data = new Map<String, Object>{
			'owner' => TEST_GIT_API_EXT_USERNAME,
			'reponame' => TEST_GIT_API_EXT_REPONAME,
			'branchname' => TEST_GIT_API_EXT_BRANCH_NAME
		};
		repoBranchesInfo = GitHubUtils.getRepoBranchesInfos(data);
		Test.stopTest();

		System.assertEquals(1, repoBranchesInfo.size());
		System.assertEquals(TEST_GIT_API_EXT_BRANCH_NAME, repoBranchesInfo.get(0).name);
	}

	@IsTest
	static void test_commit_apex_classes() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		createMockApexClasses(new List<String>{'someApexClassName'});
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	private static void setMocks() {
		MetadataService.RetrieveResult retrieveResult = new MetadataService.RetrieveResult();
		retrieveResult.id = TEST_RETRIEVE_ELEMENT_ID;
		retrieveResult.done = true;
		retrieveResult.status = 'Succeeded';
		retrieveResult.zipFile = TEST_RETRIEVE_RESPONSE_ZIP;
		Test.setMock(WebServiceMock.class, new MetadataRetrieveResultWebServiceMockImpl(retrieveResult, getSubmitRetrieveAsyncResult()));
		
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{
				'success' => true
			})
		);
		endpoint2TestResp.put(GitHubUtils.AWS_GIT_SERVICE_ENDPOINT, singleRequestMock);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	private static String getGitAPIUserEndpoint() {
		return GitHubUtils.GIT_API_USER_INFO;
	}
	private static TestDataFactory.SingleRequestMock getGitAPIUserMock() {
		Map<String, Object> objectUser = new Map<String, Object> {
				'login' => TEST_GIT_API_USERNAME
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
				200,
				'OK',
				JSON.serialize(objectUser)
		);
		return singleRequestMock;
	}

	private static String getGitAPIUserReposEndpoint() {
		return GitHubUtils.GIT_API_REPOS_INFO;
	}
	@TestVisible
	private static String getGitAPIUserReposByNameEndpoint(String reponame) {
		return getGitAPIUserReposByNameEndpoint(GitHubUtils.GIT_USERNAME, reponame);
	}
	@TestVisible
	private static String getGitAPIUserReposByNameEndpoint(String owner, String reponame) {
		return String.format(GitHubUtils.GIT_API_GET_REPOS_INFO, new List<String>{owner, reponame});
	}
	private static TestDataFactory.SingleRequestMock getGitAPIUserReposMock() {
		List<Map<String, Object>> objectRepos = new List<Map<String, Object>>{
			new Map<String, Object> {
				'name' => TEST_GIT_API_REPONAME,
				'archived' => false,
				'disabled' => false,
				'owner' => new Map<String, Object> {
					'login' => TEST_GIT_API_USERNAME
				}
			},
			new Map<String, Object> {
				'name' => 'disabledRepo',
				'archived' => false,
				'disabled' => true,
				'owner' => new Map<String, Object> {
					'login' => TEST_GIT_API_USERNAME
				}
			},
			new Map<String, Object> {
				'name' => 'archivedRepo',
				'archived' => true,
				'disabled' => false,
				'owner' => new Map<String, Object> {
					'login' => TEST_GIT_API_USERNAME
				}
			},
			new Map<String, Object> {
				'name' => TEST_GIT_API_EXT_REPONAME,
				'archived' => false,
				'disabled' => false,
				'owner' => new Map<String, Object> {
					'login' => TEST_GIT_API_EXT_USERNAME
				}
			}
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(objectRepos)
		);
		return singleRequestMock;
	}

	@TestVisible
	private static TestDataFactory.SingleRequestMock getGitAPIUserReposByNameMock() {
		Map<String, Object> objectRepos = new Map<String, Object> {
			'name' => TEST_GIT_API_EXT_REPONAME,
			'archived' => false,
			'disabled' => false,
			'owner' => new Map<String, Object> {
				'login' => TEST_GIT_API_EXT_USERNAME
			}
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(objectRepos)
		);
		return singleRequestMock;
	}

	@Testvisible
	private static String getGitAPIUserExtRepoBranchesByNameEndpoint() {
		return String.format(GitHubUtils.GIT_API_GET_REPO_BRANCHES_INFO, new List<String>{TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME, TEST_GIT_API_EXT_BRANCH_NAME});
	}
	@Testvisible
	private static TestDataFactory.SingleRequestMock getGitAPIUserExtRepoBranchesByNameMock() {
		Map<String, Object> objectRepos = new Map<String, Object> {
			'name' => TEST_GIT_API_EXT_BRANCH_NAME
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(objectRepos)
		);
		return singleRequestMock;
	}

	private static String getGitAPIUserExtRepoBranchesEndpoint() {
		return String.format(GitHubUtils.GIT_API_REPO_BRANCHES_INFO, new List<String>{TEST_GIT_API_EXT_USERNAME, TEST_GIT_API_EXT_REPONAME});
	}
	private static TestDataFactory.SingleRequestMock getGitAPIUserExtRepoBranchesMock() {
		List<Map<String, Object>> objectRepos = new List<Map<String, Object>>{
			new Map<String, Object> {
				'name' => TEST_GIT_API_EXT_BRANCH_NAME
			}
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(objectRepos)
		);
		return singleRequestMock;
	}

	private static String getGitAPIUserOwnRepoBranchesEndpoint() {
		return String.format(GitHubUtils.GIT_API_REPO_BRANCHES_INFO, new List<String>{GitHubUtils.GIT_USERNAME, TEST_GIT_API_REPONAME});
	}
	private static TestDataFactory.SingleRequestMock getGitAPIUserOwnRepoBranchesMock() {
		List<Map<String, Object>> objectRepos = new List<Map<String, Object>>{
			new Map<String, Object> {
				'name' => TEST_GIT_API_BRANCH_NAME
			}
		};

		TestDataFactory.SingleRequestMock singleRequestMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(objectRepos)
		);
		return singleRequestMock;
	}

	static List<GitHubCommitBatch.MetadataTypeWrapper> createPackageItems(String type) {
		List<GitHubCommitBatch.MetadataTypeWrapper> result = new List<GitHubCommitBatch.MetadataTypeWrapper>();
		GitHubCommitBatch.MetadataTypeWrapper wrapper = new GitHubCommitBatch.MetadataTypeWrapper(type, TEST_RETRIEVE_ELEMENT_MEMBER);
		wrapper.jobId = TEST_RETRIEVE_ELEMENT_ID;
		result.add(wrapper);
		return result;
	}

	private static MetadataService.AsyncResult getSubmitRetrieveAsyncResult() {
		MetadataService.AsyncResult asyncResult = new MetadataService.AsyncResult();
		asyncResult.id = TEST_RETRIEVE_ELEMENT_ID;
		asyncResult.done = true;
		return asyncResult;
	}

	@IsTest
	static void test_submit_retrieve_remote_site_settings() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_REMOTE_SITE_SETTINGS => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_workflows() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_WORKFLOW => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_approval_processes() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_APPROVAL_PROCESS => true
		};
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_aura_elements() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_AURA => true
		};
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_connected_apps() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_CONNECTED_APP => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_named_creds() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_NAMED_CREDENTIAL => true
		};
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_custom_metadata() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_CUSTOM_METADATA => true
		};
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	private static void createMockApexClasses(List<String> apexClassNames) {
		GitHubCommitBatch.mockListApexClasses = new List<ApexClass>();

		List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
		for(String className : apexClassNames) {
			Map<String, Object> dataMap = new Map<String, Object>();
			dataMap.put('Name', className);
			dataMap.put('LengthWithoutComments', 1);
			dataMapList.add(dataMap);
		}
		GitHubCommitBatch.mockListApexClasses = (List<ApexClass>)JSON.deserialize(JSON.serialize(dataMapList), List<ApexClass>.class);
	}

	@IsTest
	static void test_submit_retrieve_apex_classes() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		createMockApexClasses(new List<String>{'someApexClassName'});

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_apex_triggers() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_APEX_TRIGGER => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_metadata_flows() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_FLOW => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	@IsTest
	static void test_submit_retrieve_metadata_custom_objects() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
				GitHubCommitBatch.METADATA_TYPE_CUSTOM_OBJECT => true
		};

		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		setMocks();

		Test.startTest();
		Database.executeBatch(batchInstance, 1);
		Test.stopTest();
	}

	public static final String TEST_RETRIEVE_ELEMENT_ID = 'testId';
	public static final String TEST_RETRIEVE_ELEMENT_MEMBER = 'someMember';
	public static final String TEST_RETRIEVE_RESPONSE_ZIP = 'someBase64ZipContent';

	public static final String TEST_WORKFLOW_ELEMENT_API_NAME = 'someWorkflowAPIName';
	public static final String TEST_APPROVAL_PROCESS_ELEMENT_API_NAME = 'someApprovalAPIName';
	public static final String TEST_AURA_ELEMENT_API_NAME = 'someAuraAPIName';
	public static final String TEST_RSS_ELEMENT_API_NAME = 'someRssAPIName';
	public static final String TEST_APP_ELEMENT_API_NAME = 'someAppAPIName';
	public static final String TEST_CREDS_ELEMENT_API_NAME = 'someCredsAPIName';
	public static final String TEST_CUSTOM_METADATA_ELEMENT_API_NAME = 'someCustomMetaPIName';

	public static final Map<String, String> TEST_MAP_DEFAULT_DESCRIBE_LIST_COMPONENTS = new Map<String, String>{
			GitHubCommitBatch.METADATA_TYPE_WORKFLOW => TEST_WORKFLOW_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_APPROVAL_PROCESS => TEST_APPROVAL_PROCESS_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_AURA => TEST_AURA_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_REMOTE_SITE_SETTINGS => TEST_RSS_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_CONNECTED_APP => TEST_APP_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_NAMED_CREDENTIAL => TEST_CREDS_ELEMENT_API_NAME,
			GitHubCommitBatch.METADATA_TYPE_CUSTOM_METADATA => TEST_CUSTOM_METADATA_ELEMENT_API_NAME
	};

	public static List<MetadataService.FileProperties> getDefaultListDescribeElements() {
		List<MetadataService.FileProperties> result = new List<MetadataService.FileProperties>();
		for(String metaType : TEST_MAP_DEFAULT_DESCRIBE_LIST_COMPONENTS.keySet()) {
			MetadataService.FileProperties fp = new MetadataService.FileProperties();
			fp.fullName = TEST_MAP_DEFAULT_DESCRIBE_LIST_COMPONENTS.get(metaType);
			fp.type_x = metaType;
			result.add(fp);
		}
		return result;
	}

	public class MetadataRetrieveResultWebServiceMockImpl implements WebServiceMock {
		private MetadataService.RetrieveResult retrieveResult;
		private MetadataService.AsyncResult asyncResult;
		private MetadataService.FileProperties[] fileProperties;

		public MetadataRetrieveResultWebServiceMockImpl(MetadataService.RetrieveResult retrieveResult, MetadataService.AsyncResult asyncResult) {
			this(retrieveResult, asyncResult, getDefaultListDescribeElements());
		}

		public MetadataRetrieveResultWebServiceMockImpl(MetadataService.RetrieveResult retrieveResult, MetadataService.AsyncResult asyncResult, MetadataService.FileProperties[] fileProperties) {
			this.retrieveResult = retrieveResult;
			this.asyncResult = asyncResult;
			this.fileProperties = fileProperties;
		}
		public void doInvoke(
				Object stub,
				Object request,
				Map<String, Object> response,
				String endpoint,
				String soapAction,
				String requestName,
				String responseNS,
				String responseName,
				String responseType) {

			if(request instanceof MetadataService.listMetadata_element) {
				MetadataService.listMetadataResponse_element listMetadataResponseElement = new MetadataService.listMetadataResponse_element();
				listMetadataResponseElement.result = this.fileProperties;
				response.put('response_x', listMetadataResponseElement);
			}
			else if (request instanceof MetadataService.retrieve_element) {
				MetadataService.retrieveResponse_element retrieveResponseElement = new MetadataService.retrieveResponse_element();
				retrieveResponseElement.result = this.asyncResult;
				response.put('response_x', retrieveResponseElement);
			}
			else if (request instanceof MetadataService.checkRetrieveStatus_element) {
				MetadataService.checkRetrieveStatusResponse_element checkResponseElement = new MetadataService.checkRetrieveStatusResponse_element();
				checkResponseElement.result = this.retrieveResult;
				response.put('response_x', checkResponseElement);
			}

		}
	}
}