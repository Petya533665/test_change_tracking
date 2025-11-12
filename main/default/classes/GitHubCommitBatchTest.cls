@IsTest
@TestVisible
private class GitHubCommitBatchTest {

	private static final String TEST_GIT_API_USERNAME = 'someusername';
	private static final String TEST_GIT_API_TOKEN = 'token';
	private static final String TEST_GIT_API_OAUTH_TOKEN = 'oauthtoken';
	private static final String TEST_GIT_API_REPONAME = 'reponame';
	private static final String TEST_GIT_API_BRANCH_NAME = 'master';

	@TestSetup
	private static void testSetup() {
		TestDataFactory.createConnectedOrg();
		
		ConfigUtil.GIT_API_SETTINGS.Username__c = TEST_GIT_API_USERNAME;
		ConfigUtil.GIT_API_SETTINGS.Token__c = TEST_GIT_API_TOKEN;
		ConfigUtil.GIT_API_SETTINGS.oauth_Token__c = TEST_GIT_API_OAUTH_TOKEN;
		ConfigUtil.GIT_API_SETTINGS.Reponame__c = TEST_GIT_API_REPONAME;
		ConfigUtil.GIT_API_SETTINGS.Branch_Name__c = TEST_GIT_API_BRANCH_NAME;
		upsert ConfigUtil.GIT_API_SETTINGS;

		// Setup OpenAI
		ConfigUtil.OPEN_AI_SETTINGS.Token__c = 'test-openai-token';
		upsert ConfigUtil.OPEN_AI_SETTINGS;
	}

	// ============================================
	// Test Batch Execution - Initial Run (no Last_Processed_Date_Time)
	// ============================================
	
	@IsTest
	static void test_batchExecution_initialRun_withApexClass() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		createMockApexClasses(new List<String>{'TestClass'});
		setupPermissions(true, true);
		setHttpMocks();
		
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = null;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		createMockAuditTrail(Datetime.now(), 'TestClass', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.isTrue(String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c), 'Last_Processed_Date_Time__c should be set after initial run');
	}

	// ============================================
	// Test Batch Execution - Subsequent Run with Changes
	// ============================================
	
	@IsTest
	static void test_batchExecution_subsequentRun_withChanges() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		createMockApexClasses(new List<String>{'ChangedClass'});
		setupPermissions(true, true);
		setHttpMocks();

		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;

		createMockAuditTrail(Datetime.now(), 'ChangedClass', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated after processing changes');
	}

	// ============================================
	// Test Batch Execution - No Changes
	// ============================================
	
	@IsTest
	static void test_batchExecution_noChanges() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		setupPermissions(true, true);

		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;

		GitHubCommitBatch.mockAuditTrails = new List<SetupAuditTrail>();

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should not change when no changes detected');
	}

	// ============================================
	// Test Batch Execution - Missing Permissions
	// ============================================
	
	@IsTest
	static void test_batchExecution_missingPermissions() {
		setupPermissions(false, false);

		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should not change when permissions are missing');
	}

	// ============================================
	// Test Batch Execution - Missing Token
	// ============================================
	
	@IsTest
	static void test_batchExecution_missingToken() {
		setupPermissions(true, true);
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		ConfigUtil.GIT_API_SETTINGS.Token__c = null;
		ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c = null;
		upsert ConfigUtil.GIT_API_SETTINGS;

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should not change when token is missing');
	}

	// ============================================
	// Test Batch Execution - Multiple Metadata Types
	// ============================================
	
	@IsTest
	static void test_batchExecution_multipleMetadataTypes() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true,
			GitHubCommitBatch.METADATA_TYPE_APEX_TRIGGER => true
		};
		createMockApexClasses(new List<String>{'TestClass'});
		setupPermissions(true, true);
		setHttpMocks();
		
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = null;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
		dataMapList.add(createAuditTrailData('id1', Datetime.now(), 'TestClass', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS));
		dataMapList.add(createAuditTrailData('id2', Datetime.now().addMinutes(-5), 'TestTrigger', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_TRIGGER));
		GitHubCommitBatch.mockAuditTrails = (List<SetupAuditTrail>)JSON.deserialize(JSON.serialize(dataMapList), List<SetupAuditTrail>.class);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.isTrue(String.isNotBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c), 'Last_Processed_Date_Time__c should be set');
	}

	// ============================================
	// Test Batch Execution - Multiple Classes
	// ============================================
	
	@IsTest
	static void test_batchExecution_multipleApexClasses() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		// Create multiple classes with sizes that will fit in one container
		createMockApexClassesWithSizes(new Map<String, Integer>{
			'TestClass1' => 1000,
			'TestClass2' => 2000,
			'TestClass3' => 3000
		});
		setupPermissions(true, true);
		setHttpMocks();
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
		dataMapList.add(createAuditTrailData('id1', Datetime.now(), 'TestClass1', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS));
		dataMapList.add(createAuditTrailData('id2', Datetime.now().addMinutes(-1), 'TestClass2', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS));
		dataMapList.add(createAuditTrailData('id3', Datetime.now().addMinutes(-2), 'TestClass3', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS));
		GitHubCommitBatch.mockAuditTrails = (List<SetupAuditTrail>)JSON.deserialize(JSON.serialize(dataMapList), List<SetupAuditTrail>.class);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated');
	}

	// ============================================
	// Test Batch Execution - Custom Objects
	// ============================================
	
	@IsTest
	static void test_batchExecution_withCustomObjects() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_CUSTOM_OBJECT => true
		};
		setupPermissions(true, true);
		setHttpMocksWithCustomObjects();
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		// Use Log__c as custom object change
		createMockAuditTrail(Datetime.now(), 'Log', GitHubCommitBatch.AUDIT_TRAIL_SECTION_CUSTOM_OBJECTS);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated');
	}

	// ============================================
	// Test Batch Execution - Standard Objects
	// ============================================
	
	@IsTest
	static void test_batchExecution_withStandardObjects() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_CUSTOM_OBJECT => true
		};
		setupPermissions(true, true);
		setHttpMocks();
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		// Section starts with "Customize" for standard objects
		createMockAuditTrail(Datetime.now(), 'Account', 'Customize Application');

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated');
	}

	// ============================================
	// Test Batch Execution - Metadata via listMetadata
	// ============================================
	
	@IsTest
	static void test_batchExecution_withWorkflowMetadata() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_WORKFLOW => true
		};
		setupPermissions(true, true);
		setHttpMocksWithWorkflow();
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		createMockAuditTrail(Datetime.now(), 'TestWorkflow', GitHubCommitBatch.AUDIT_TRAIL_SECTION_WORKFLOW);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated');
	}

	// ============================================
	// Test Batch Execution - Delete Metadata Change
	// ============================================
	
	@IsTest
	static void test_batchExecution_withDeleteChange() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_WORKFLOW => true
		};
		setupPermissions(true, true);
		setHttpMocksWithWorkflow();
		
		String lastProcessedDateTime = Datetime.now().addDays(-1).formatGMT(Constants.GLOBAL_VARIABLE.DATETIME_FORMAT);
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = lastProcessedDateTime;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		// Audit change with 'delete' keyword
		createMockAuditTrail(Datetime.now(), 'Delete TestWorkflow', GitHubCommitBatch.AUDIT_TRAIL_SECTION_WORKFLOW);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areNotEqual(lastProcessedDateTime, ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c, 'Last_Processed_Date_Time__c should be updated');
	}

	// ============================================
	// Test Batch Execution - AWS Service Error
	// ============================================
	
	@IsTest
	static void test_batchExecution_withAwsServiceError() {
		GitHubCommitBatch.MAP_ENABLED_METADATA = new Map<String, Boolean>{
			GitHubCommitBatch.METADATA_TYPE_APEX_CLASS => true
		};
		createMockApexClasses(new List<String>{'TestClass'});
		setupPermissions(true, true);
		setHttpMocksWithError();
		
		ConfigUtil.GIT_API_SETTINGS.Last_Processed_Date_Time__c = null;
		// Set Token__c to blank to use oAuth_Token__c
		ConfigUtil.GIT_API_SETTINGS.Token__c = null;
		upsert ConfigUtil.GIT_API_SETTINGS;
		
		createMockAuditTrail(Datetime.now(), 'TestClass', GitHubCommitBatch.AUDIT_TRAIL_SECTION_APEX_CLASS);

		Test.startTest();
		GitHubCommitBatch batchInstance = GitHubCommitBatch.getInstance();
		batchInstance.startBatch();
		Test.stopTest();

		Assert.areNotEqual(null, batchInstance, 'Batch instance should not be null');
		Assert.areEqual(1, [SELECT COUNT() FROM Log__c], 'Count of Logs do not match');
	}

	// ============================================
	// Helper Methods
	// ============================================
	
	private static void setupPermissions(Boolean gitHubEnabled, Boolean changeTrackingEnabled) {
		Integer gitHubBit = gitHubEnabled ? 1 : 0;
		Integer changeTrackingBit = changeTrackingEnabled ? 1 : 0;
		Integer issueAnalysisBit = gitHubEnabled ? 1 : 0; // Enable when GitHub is enabled
		Integer metadataChatBit = gitHubEnabled ? 1 : 0; // Enable when GitHub is enabled
		
		// GitHubIntegrationEnabled = index 15, ChangeTrackingEnabled = index 16
		// IssueAnalysisEnabled = index 22, MetadataChatEnabled = index 28
		Integer intValue = PermissionsUtil.getIntegerFromBitmap(new Map<Integer, Integer>{
			0=>0, 1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0,
			12=>0, 13=>0, 14=>0, 15=>gitHubBit, 16=>changeTrackingBit, 17=>0, 18=>0, 19=>0, 20=>0, 21=>0, 22=>issueAnalysisBit, 23=>0,
			24=>0, 25=>0, 26=>0, 27=>0, 28=>metadataChatBit
		});
		PermissionsUtil.FeatureMap1IntValue = intValue;

		ConfigUtil.GIT_API_SETTINGS.Enabled__c = true;
		ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c = changeTrackingEnabled;
		upsert ConfigUtil.GIT_API_SETTINGS;
		upsert ConfigUtil.CHANGE_TRACKING_SETTINGS;
	}

	private static void createMockAuditTrail(Datetime createdDate, String display, String section) {
		Map<String, Object> dataMap = createAuditTrailData('testAuditId', createdDate, display, section);
		GitHubCommitBatch.mockAuditTrails = (List<SetupAuditTrail>)JSON.deserialize(
			JSON.serialize(new List<Map<String, Object>>{ dataMap }), 
			List<SetupAuditTrail>.class
		);
	}

	private static Map<String, Object> createAuditTrailData(String id, Datetime createdDate, String display, String section) {
		return new Map<String, Object>{
			'Id' => id,
			'CreatedDate' => createdDate,
			'Display' => display,
			'Section' => section
		};
	}

	private static void setHttpMocks() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		
		TestDataFactory.SingleRequestMock awsMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{ 'success' => true })
		);
		endpoint2TestResp.put(GitHubUtils.AWS_GIT_SERVICE_ENDPOINT, awsMock);

		// Mock for PharosChatController.getNamespaceStatus
		TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{
				'empty' => false,
				'logsEmpty' => false,
				'indexingInProgress' => false
			})
		);
		endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT, namespaceStatusMock);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
		// Set WebServiceMock for Metadata API
		setMetadataServiceMock();
	}

	private static void setMetadataServiceMock() {
		List<MetadataService.FileProperties> fileProps = new List<MetadataService.FileProperties>();
		MetadataService.FileProperties fp = new MetadataService.FileProperties();
		fp.fullName = 'TestApexClass';
		fp.type_x = GitHubCommitBatch.METADATA_TYPE_APEX_CLASS;
		fileProps.add(fp);
		
		Test.setMock(WebServiceMock.class, new MockMetadataServiceImpl(fileProps));
	}

	private static void setHttpMocksWithCustomObjects() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		
		TestDataFactory.SingleRequestMock awsMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{ 'success' => true })
		);
		endpoint2TestResp.put(GitHubUtils.AWS_GIT_SERVICE_ENDPOINT, awsMock);

		// Mock for PharosChatController.getNamespaceStatus
		TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{
				'empty' => false,
				'logsEmpty' => false,
				'indexingInProgress' => false
			})
		);
		endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT, namespaceStatusMock);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
		// Set WebServiceMock for Custom Objects with namespace
		List<MetadataService.FileProperties> fileProps = new List<MetadataService.FileProperties>();
		MetadataService.FileProperties fp = new MetadataService.FileProperties();
		fp.fullName = 'Log__c';
		fp.type_x = GitHubCommitBatch.METADATA_TYPE_CUSTOM_OBJECT;
		fp.namespacePrefix = ConfigUtil.currentOrgNameSpacePrefix;
		fileProps.add(fp);
		
		Test.setMock(WebServiceMock.class, new MockMetadataServiceImpl(fileProps));
	}

	private static void setHttpMocksWithWorkflow() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		
		TestDataFactory.SingleRequestMock awsMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{ 'success' => true })
		);
		endpoint2TestResp.put(GitHubUtils.AWS_GIT_SERVICE_ENDPOINT, awsMock);

		// Mock for PharosChatController.getNamespaceStatus
		TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{
				'empty' => false,
				'logsEmpty' => false,
				'indexingInProgress' => false
			})
		);
		endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT, namespaceStatusMock);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
		// Set WebServiceMock for Workflow
		List<MetadataService.FileProperties> fileProps = new List<MetadataService.FileProperties>();
		MetadataService.FileProperties fp = new MetadataService.FileProperties();
		fp.fullName = 'TestWorkflow';
		fp.type_x = GitHubCommitBatch.METADATA_TYPE_WORKFLOW;
		fileProps.add(fp);
		
		Test.setMock(WebServiceMock.class, new MockMetadataServiceImpl(fileProps));
	}

	private static void setHttpMocksWithError() {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		
		// Mock AWS Git Service with 404 error
		TestDataFactory.SingleRequestMock awsErrorMock = new TestDataFactory.SingleRequestMock(
			404,
			'Not Found',
			''
		);
		endpoint2TestResp.put(GitHubUtils.AWS_GIT_SERVICE_ENDPOINT, awsErrorMock);

		// Mock for PharosChatController.getNamespaceStatus
		TestDataFactory.SingleRequestMock namespaceStatusMock = new TestDataFactory.SingleRequestMock(
			200,
			'OK',
			JSON.serialize(new Map<String, Object>{
				'empty' => false,
				'logsEmpty' => false,
				'indexingInProgress' => false
			})
		);
		endpoint2TestResp.put(PharosChatController.CHECK_NAMESPACE_STATUS_ENDPOINT, namespaceStatusMock);

		HttpCalloutMock multiCalloutMock = new TestDataFactory.MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		
		// Set WebServiceMock for Metadata API
		setMetadataServiceMock();
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

	private static void createMockApexClassesWithSizes(Map<String, Integer> classNamesWithSizes) {
		GitHubCommitBatch.mockListApexClasses = new List<ApexClass>();

		List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
		for(String className : classNamesWithSizes.keySet()) {
			Map<String, Object> dataMap = new Map<String, Object>();
			dataMap.put('Name', className);
			dataMap.put('LengthWithoutComments', classNamesWithSizes.get(className));
			dataMapList.add(dataMap);
		}
		GitHubCommitBatch.mockListApexClasses = (List<ApexClass>)JSON.deserialize(JSON.serialize(dataMapList), List<ApexClass>.class);
	}

	// Mock class for Metadata Service
	public class MockMetadataServiceImpl implements WebServiceMock {
		private MetadataService.FileProperties[] fileProperties;

		public MockMetadataServiceImpl(MetadataService.FileProperties[] fileProperties) {
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
			String responseType
		) {
			if (request instanceof MetadataService.listMetadata_element) {
				MetadataService.listMetadataResponse_element listResponse = new MetadataService.listMetadataResponse_element();
				listResponse.result = this.fileProperties;
				response.put('response_x', listResponse);
			}
		}
	}
}