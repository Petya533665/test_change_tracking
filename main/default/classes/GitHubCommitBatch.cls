public with sharing class GitHubCommitBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<AWSCallTypeWrapper>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    public static final String GIT_API_DEFAULT_BRANCH_NAME_PREFIX = 'OrgMetadataDump';
    public static final String GIT_API_DEFAULT_PULL_REQUEST_NAME_PREFIX = 'Metadata Dump Pull Request';
	public static String GIT_CLONE_ENDPOINT = 'https://{0}:{1}@github.com/{2}/{3}.git';

    public static String GIT_API_DEFAULT_BRANCH_TIMESTAMP {
        get {
            if(GIT_API_DEFAULT_BRANCH_TIMESTAMP == null) {
                GIT_API_DEFAULT_BRANCH_TIMESTAMP = String.valueOf(ConfigUtil.generateUUID4());
            }
            return GIT_API_DEFAULT_BRANCH_TIMESTAMP;
        }
        set;
    }

    public static String GIT_API_DEFAULT_BRANCH_NAME {
        get {
            if(GIT_API_DEFAULT_BRANCH_NAME == null) {
                GIT_API_DEFAULT_BRANCH_NAME = GIT_API_DEFAULT_BRANCH_NAME_PREFIX + GIT_API_DEFAULT_BRANCH_TIMESTAMP;
            }
            return GIT_API_DEFAULT_BRANCH_NAME;
        }
        set;
    }

    public static String GIT_API_DEFAULT_PULL_REQUEST_NAME {
        get {
            if(GIT_API_DEFAULT_PULL_REQUEST_NAME == null) {
                GIT_API_DEFAULT_PULL_REQUEST_NAME = GIT_API_DEFAULT_PULL_REQUEST_NAME_PREFIX + GIT_API_DEFAULT_BRANCH_TIMESTAMP;
            }
            return GIT_API_DEFAULT_PULL_REQUEST_NAME;
        }
        set;
    }

    private Boolean allTransactionsCompleted = true;
    private String lastProcessedId = null;

    private static GitHubCommitBatch instance = null;

    public static GitHubCommitBatch getInstance() {
        if (instance == null) {
            instance = new GitHubCommitBatch(Logger.getInstance());
        }
        return instance;
    }

    private GitHubCommitBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('GitHubCommitBatch', this);
    }

    public override Boolean initialValidation() {
        Boolean hasAuditChangesToStart = false;
        if (PermissionsUtil.GitHubIntegrationEnabled && PermissionsUtil.ChangeTrackingEnabled
                && ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c
                && ConfigUtil.GIT_API_SETTINGS.Enabled__c
                && (ConfigUtil.GIT_API_SETTINGS.Token__c != null || ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c != null)
                && ConfigUtil.GIT_API_SETTINGS.Branch_Name__c != null
                && ConfigUtil.GIT_API_SETTINGS.Reponame__c != null
                && ConfigUtil.GIT_API_SETTINGS.Username__c != null) {

            hasAuditChangesToStart = String.isBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c);

            if (!hasAuditChangesToStart) {
                AuditChangeWrapper lastChanges = getAuditTrails(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c);
                hasAuditChangesToStart = (lastChanges != null && !lastChanges.auditChange.isEmpty());
            }
        }
        return hasAuditChangesToStart;
    }

    public override Integer getIterationsCount() {
        Integer iterationsCount = 0;
        for (String key : MAP_ENABLED_METADATA.keySet()) {
            if (MAP_ENABLED_METADATA.get(key)) {iterationsCount += 1;}
        }
        return iterationsCount;
    }

    public Iterable<AWSCallTypeWrapper> start(Database.BatchableContext batchableContext) {
        AWSCallTypeIterable iterable = new AWSCallTypeIterable(getAWSCallMembers());
        return iterable;
    }

    public Enum AWSCallType {GIT}

    public class AWSCallTypeWrapper {
        public AWSCallType type;

        public AWSCallTypeWrapper(AWSCallType type) {
            this.type = type;
        }
    }

    public static List<AWSCallTypeWrapper> getAWSCallMembers() {
        List<AWSCallTypeWrapper> result = new List<AWSCallTypeWrapper>();
        if(PermissionsUtil.GitHubIntegrationEnabled && PermissionsUtil.ChangeTrackingEnabled) {
            result.add(new AWSCallTypeWrapper(AWSCallType.GIT));
        }
        return result;
    }

    public class AWSCallTypeIterable implements Iterable<AWSCallTypeWrapper> {

        private List<AWSCallTypeWrapper> awsCalls;

        public AWSCallTypeIterable() {
            this.awsCalls = new List<AWSCallTypeWrapper>();
        }

        public AWSCallTypeIterable(List<AWSCallTypeWrapper> awsCalls) {
            this.awsCalls = awsCalls;
        }

        public Iterator<AWSCallTypeWrapper> iterator() {
            return new AWSCallTypeIterator(this.awsCalls);
        }
    }

    public class AWSCallTypeIterator implements Iterator<AWSCallTypeWrapper> {
        private List<AWSCallTypeWrapper> awsCalls;
        private Integer index;

        public AWSCallTypeIterator(List<AWSCallTypeWrapper> defaults) {
            this.awsCalls = defaults == null ? new List<AWSCallTypeWrapper>() : defaults;
            this.index = 0;
        }

        public AWSCallTypeIterator() {
            this(new List<AWSCallTypeWrapper>());
        }

        public Boolean hasNext() {
            return this.index < awsCalls.size();
        }

        public AWSCallTypeWrapper next() {
            return this.awsCalls[this.index++];
        }
    }

    public void execute(Database.BatchableContext info, List<AWSCallTypeWrapper> scope) {
        if (scope == null || scope.isEmpty()) {
            return; // Skip processing for empty scope
        }
        
        AWSCallTypeWrapper token = scope.get(0);
        switch on token?.type {
            when GIT {
                try {
                    Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
                    List<MetadataTypeWrapper> metadata = getMetadataTypeMembers();
					if(!metadata.isEmpty()) {
						String packageXML = GitHubUtils.generatePackageXML(metadata);
						// run lambda service
						AWSGitServiceResponse response = startAwsGitService(corg, packageXML);
                        DatabaseUtils.getInstance().performUpdateDML(new List<Git_API_Settings__c>{ConfigUtil.GIT_API_SETTINGS}, Schema.SObjectType.Git_API_Settings__c)
                                .handleError(GitHubCommitBatch.class.getName(), 'execute', loggerInstance);
					}
                }
                catch (Exception e) {
                    loggerInstance?.addInternalError(e, GitHubCommitBatch.class.getName(), ':execute');
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        loggerInstance?.flush();
    }

    public AWSGitServiceResponse startAwsGitService(Connected_Org__c corg, String packageXML) {
        AWSGitServiceResponse result;
        try {
            if(PermissionsUtil.GitHubIntegrationEnabled && PermissionsUtil.ChangeTrackingEnabled) {
                AWSGitServiceRequest request = new AWSGitServiceRequest(corg, packageXML);
                Map<String, String> headers = GitHubUtils.authHeaders();
                headers.putAll(HttpUtils.getHeadersContentTypeJSON());

                String b = HttpUtils.post(
                    GitHubUtils.AWS_GIT_SERVICE_ENDPOINT,
                    JSON.serialize(request),
                    headers,
                    200
                );
                result = (AWSGitServiceResponse)JSON.deserialize(b, AWSGitServiceResponse.class);
            }
        }
        catch(Exception e) {
            this.loggerInstance?.add(loggerInstance.getInternalError(e, null, GitHubCommitBatch.class.getName(), 'startAwsGitService'));
        }
        return result;
    }

    public class AWSGitServiceResponse {
        public Boolean success;
        public String name;
        public String message;
        public String stack;
    
        public AWSGitServiceResponse(){}
    }

    public class AWSGitServiceRequest {
        public String oid;
        public String instance;
        public String session;
        public String isProd;
        public String indexEmpty;

        public String packageXML;
        public String masterBranchName;
        public String branchName;
        public String prName;
        public String cloneUrl;
        public String gid;
        public String username;
        public String reponame;

        public String openAiApiKey;
        public String pineconeApiKey;
        public String logOrgId;

        public AWSGitServiceRequest(Connected_Org__c corg, String packageXML) {
            this.oid = UserInfo.getOrganizationId();
            this.instance = System.Url.getOrgDomainUrl().toExternalForm();
            this.session = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
            this.packageXML = packageXML;
            
            this.branchName = GitHubCommitBatch.GIT_API_DEFAULT_BRANCH_NAME;
            this.prName = GitHubCommitBatch.GIT_API_DEFAULT_PULL_REQUEST_NAME;
            this.gid = (String.isBlank(ConfigUtil.GIT_API_SETTINGS.Token__c))
                ? ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c
                : ConfigUtil.GIT_API_SETTINGS.Token__c;
			this.cloneUrl = String.format(GIT_CLONE_ENDPOINT, new List<String>{
				GitHubUtils.GIT_USERNAME,
				this.gid,
				GitHubUtils.GIT_USERNAME,
				GitHubUtils.GIT_REPONAME
			});
            this.masterBranchName = GitHubUtils.GIT_API_DEFAULT_BASE_BRANCH_REF;
            this.username = GitHubUtils.GIT_USERNAME;
            this.reponame = GitHubUtils.GIT_REPONAME;
            this.isProd = String.valueOf(ConfigUtil.currentOrgIsSandbox());

            if (PermissionsUtil.IssueAnalysisEnabled) {
                this.openAiApiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
                this.logOrgId = corg.Name;
            }
            if (PermissionsUtil.MetadataChatEnabled) {
                this.indexEmpty = String.valueOf(!PharosChatController.isCodeIndexed(this.oid));
            }
        }
    }

    // soql types
    public static final String METADATA_TYPE_FLOW = 'Flow';
    public static final String METADATA_TYPE_APEX_CLASS = 'ApexClass';
    public static final String METADATA_TYPE_APEX_TRIGGER = 'ApexTrigger';
    public static final String METADATA_TYPE_CUSTOM_OBJECT = 'CustomObject';
    public static final String METADATA_TYPE_APEX_PAGE = 'ApexPage';
    public static final String METADATA_TYPE_APEX_COMPONENT = 'ApexComponent';

    // metadata query types
    public static final String METADATA_TYPE_WORKFLOW = 'Workflow';
    public static final String METADATA_TYPE_APPROVAL_PROCESS = 'ApprovalProcess';
    public static final String METADATA_TYPE_AURA = 'AuraDefinitionBundle';
    public static final String METADATA_TYPE_REMOTE_SITE_SETTINGS = 'RemoteSiteSetting';
    public static final String METADATA_TYPE_CONNECTED_APP = 'ConnectedApp';
    public static final String METADATA_TYPE_NAMED_CREDENTIAL = 'NamedCredential';
    public static final String METADATA_TYPE_CUSTOM_METADATA = 'CustomMetadata';

    public static Map<String, Boolean> MAP_ENABLED_METADATA = new Map<String, Boolean>{
        METADATA_TYPE_FLOW => true,
        METADATA_TYPE_APEX_CLASS => true,
        METADATA_TYPE_APEX_TRIGGER => true,
        METADATA_TYPE_CUSTOM_OBJECT => true,
        METADATA_TYPE_APEX_PAGE => true,
        METADATA_TYPE_APEX_COMPONENT => true,
        METADATA_TYPE_WORKFLOW => true,
        METADATA_TYPE_APPROVAL_PROCESS => true,
        METADATA_TYPE_AURA => true,
        METADATA_TYPE_REMOTE_SITE_SETTINGS => true,
        METADATA_TYPE_CONNECTED_APP => true,
        METADATA_TYPE_NAMED_CREDENTIAL => true,
        METADATA_TYPE_CUSTOM_METADATA => true
    };

    public static final String AUDIT_TRAIL_SECTION_APEX_CLASS = 'Apex Class';
    public static final String AUDIT_TRAIL_SECTION_APEX_TRIGGER = 'Apex Trigger';
    public static final String AUDIT_TRAIL_SECTION_FLOWS = 'Flows';
    public static final String AUDIT_TRAIL_SECTION_CUSTOM_OBJECTS = 'Custom Objects';
    public static final String AUDIT_TRAIL_SECTION_STANDARD_OBJECTS = 'Customize';
    public static final String AUDIT_TRAIL_SECTION_APEX_PAGE = 'Page';
    public static final String AUDIT_TRAIL_SECTION_APEX_COMPONENT = 'Component';
    public static final String AUDIT_TRAIL_SECTION_APPROVAL_PROCESS = 'Approval Process';
    public static final String AUDIT_TRAIL_SECTION_WORKFLOW = 'Workflow Rule';
    public static final String AUDIT_TRAIL_SECTION_AURA = 'Lightning Components';
    public static final String AUDIT_TRAIL_SECTION_REMOTE_SITE_SETTINGS = 'Security Controls';
    public static final String AUDIT_TRAIL_SECTION_CONNECTED_APP = 'Connected Apps';
    public static final String AUDIT_TRAIL_SECTION_CONNECTED_APP2 = 'Application';
    public static final String AUDIT_TRAIL_SECTION_NAMED_CREDENTIAL = 'Named Credentials';
    public static final String AUDIT_TRAIL_SECTION_CUSTOM_METADATA = 'Custom Metadata Types';


    public static Map<String, String> MAP_METADATA_TYPE_BY_AUDIT_ACTION = new Map<String, String>{
        AUDIT_TRAIL_SECTION_FLOWS => METADATA_TYPE_FLOW,
        AUDIT_TRAIL_SECTION_APEX_CLASS => METADATA_TYPE_APEX_CLASS,
        AUDIT_TRAIL_SECTION_APEX_TRIGGER => METADATA_TYPE_APEX_TRIGGER,
        AUDIT_TRAIL_SECTION_CUSTOM_OBJECTS => METADATA_TYPE_CUSTOM_OBJECT,
        AUDIT_TRAIL_SECTION_APEX_PAGE => METADATA_TYPE_APEX_PAGE,
        AUDIT_TRAIL_SECTION_APEX_COMPONENT => METADATA_TYPE_APEX_COMPONENT,
        AUDIT_TRAIL_SECTION_WORKFLOW => METADATA_TYPE_WORKFLOW,
        AUDIT_TRAIL_SECTION_APPROVAL_PROCESS => METADATA_TYPE_APPROVAL_PROCESS,
        AUDIT_TRAIL_SECTION_AURA => METADATA_TYPE_AURA,
        AUDIT_TRAIL_SECTION_REMOTE_SITE_SETTINGS => METADATA_TYPE_REMOTE_SITE_SETTINGS,
        AUDIT_TRAIL_SECTION_CONNECTED_APP => METADATA_TYPE_CONNECTED_APP,
        AUDIT_TRAIL_SECTION_CONNECTED_APP2 => METADATA_TYPE_CONNECTED_APP,
        AUDIT_TRAIL_SECTION_NAMED_CREDENTIAL => METADATA_TYPE_NAMED_CREDENTIAL,
        AUDIT_TRAIL_SECTION_CUSTOM_METADATA => METADATA_TYPE_CUSTOM_METADATA
    };

    public static List<MetadataTypeWrapper> getMetadataTypeMembers() {
        List<MetadataTypeWrapper> result = new List<MetadataTypeWrapper>();
        // return all metadata items
        if(String.isBlank(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c)) {
            result = getDefaultMetadataTypeMembers();
            setLastProcessedId(getAuditTrails(null).lastProcessedId);
        }
        // return only changed metadata
        else {
            AuditChangeWrapper lastChanges = getAuditTrails(ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c);
            if(!lastChanges.auditChange.isEmpty()) {
                result = getFilteredMetadataTypeMembers(lastChanges.auditChange);
                setLastProcessedId(lastChanges.lastProcessedId);
            }
        }
        return result;
    }

    public static void setLastProcessedId(String lastProcessedId) {
        if(String.isNotBlank(lastProcessedId)) {
            ConfigUtil.GIT_API_SETTINGS.Last_Processed_Id__c = lastProcessedId;
        }
    }

    public class AuditChangeWrapper {
        public List<AuditChange> auditChange;
        public String lastProcessedId;

        public AuditChangeWrapper(String lastProcessedId) {
            this.auditChange = new List<AuditChange>();
            this.lastProcessedId = lastProcessedId;
        }

        public AuditChangeWrapper(List<AuditChange> auditChange, String lastProcessedId) {
            this.auditChange = auditChange;
            this.lastProcessedId = lastProcessedId;
        }
    }
    public class AuditChange {
        public String type;
        public List<String> changes;

        public AuditChange(String type) {
            this.type = type;
            this.changes = new List<String>();
        }

        public void addChange(String change) {
            this.changes.add(change);
        }
    }

    public class MetaWrapper {
        public String apiName;
        public Integer size;

        public MetaWrapper(String apiName) {
            this(apiName, 1);
        }
        public MetaWrapper(String apiName, Integer size) {
            this.apiName = apiName;
            this.size = size;
        }
    }

    public static MetadataTypeWrapperContainer getMetaTypeContainer(Boolean permission, String metaType) {
        MetadataTypeWrapperContainer result = new MetadataTypeWrapperContainer();
        if(!permission) return result;

        if(metaType == METADATA_TYPE_APEX_CLASS || metaType == METADATA_TYPE_APEX_TRIGGER || metaType == METADATA_TYPE_CUSTOM_OBJECT) {
            if(METADATA_BUNDLE != null && METADATA_BUNDLE.containsKey(metaType) && METADATA_BUNDLE.get(metaType) != null) {
                for(MetaWrapper item : METADATA_BUNDLE.get(metaType)) {
                    result.addMember(metaType, item.apiName, item.size);
                }
            }
        }
        else {
            result.members = new List<MetadataTypeWrapper>{new MetadataTypeWrapper(metaType, '*')};
        }
        return result;
    }

    public static MetadataTypeWrapperContainer getMetaTypeContainer(Boolean permission, String metaType, List<String> changes) {
        MetadataTypeWrapperContainer result = new MetadataTypeWrapperContainer();
        if(!permission) return result;

        for(String auditChange : changes) {
            if(METADATA_BUNDLE != null && METADATA_BUNDLE.containsKey(metaType) && METADATA_BUNDLE.get(metaType) != null) {
                for(MetaWrapper item : METADATA_BUNDLE.get(metaType)) {
                    String label;
                    String labelPlural;
                    if(metaType == METADATA_TYPE_CUSTOM_OBJECT) {
                        Schema.SObjectType soType = ConfigUtil.MAP_GD.get(item.apiName);
                        if(soType != null) {
                            Schema.DescribeSObjectResult sobjectDescribe = soType.getDescribe();
                            label = sobjectDescribe.getLabel();
                            labelPlural = sobjectDescribe.getLabelPlural();
                        }
                    }
                    if(auditChange.containsIgnoreCase(item.apiName)
                        || (String.isNotBlank(label) && auditChange.containsIgnoreCase(label))
                        || (String.isNotBlank(labelPlural) && auditChange.containsIgnoreCase(labelPlural))) {
                        result.addMember(metaType, item.apiName, item.size);
                    }
                }
            }
        }
        return result;
    }

    public static List<MetadataTypeWrapper> getDefaultMetadataTypeMembers() {
        List<MetadataTypeWrapper> result = new List<MetadataTypeWrapper>();
        for(String metaType : MAP_ENABLED_METADATA.keySet()) {
            MetadataTypeWrapperContainer metaTypeContainer = getMetaTypeContainer(
                MAP_ENABLED_METADATA.get(metaType),
                metaType
            );
            if(!metaTypeContainer.members.isEmpty()) {
                for(MetadataTypeWrapper member : metaTypeContainer.members) {
                    result.add(member);
                }
            }
        }
        return result;
    }

    public static List<MetadataTypeWrapper> getFilteredMetadataTypeMembers(List<AuditChange> auditChanges) {
        List<MetadataTypeWrapper> result = new List<MetadataTypeWrapper>();
        for(AuditChange auditChange : auditChanges) {
            MetadataTypeWrapperContainer metaTypeContainer = getMetaTypeContainer(
                MAP_ENABLED_METADATA.get(auditChange.type),
                auditChange.type,
                auditChange.changes
            );
            if(!metaTypeContainer.members.isEmpty()) {
                for(MetadataTypeWrapper member : metaTypeContainer.members) {
                    result.add(member);
                }
            }
        }
        return result;
    }

    @TestVisible
    private static AuditChangeWrapper testAuditChangeWrapper;

    @TestVisible
    private static List<SetupAuditTrail> mockAuditTrails = new List<SetupAuditTrail>();

    private static List<SetupAuditTrail> getAuditTrailRecords(String lastProcessedId) {
        List<SetupAuditTrail> records;
        if(lastProcessedId == null) {
            records = Test.isRunningTest() ? mockAuditTrails : [
                SELECT Id, Action, CreatedDate, Display, Section
                FROM SetupAuditTrail
                ORDER BY Id DESC
                LIMIT 1
            ];
        }
        else {
            records = new List<SetupAuditTrail>();
            List<SetupAuditTrail> auditTrails = Test.isRunningTest() ? mockAuditTrails : [
                SELECT Id, Action, CreatedDate, Display, Section
                FROM SetupAuditTrail
                WHERE Id > :lastProcessedId
                ORDER BY Id DESC
                LIMIT 2000
            ];
            Set<String> displayFilter = new Set<String>();
            for(SetupAuditTrail sat : auditTrails) {
                if(!displayFilter.contains(sat.Display)) {
                    records.add(sat);
                    displayFilter.add(sat.Display);
                }
            }
        }
        return records;
    }

    public static AuditChangeWrapper getAuditTrails(String lastProcessedId) {
        AuditChangeWrapper result;

        if(testAuditChangeWrapper != null) {
            result = testAuditChangeWrapper;
            return result;
        }
        List<SetupAuditTrail> records = getAuditTrailRecords(lastProcessedId);

        if(lastProcessedId == null) {
            String currentLastProcessedId = records.isEmpty() ? null : records.get(0).Id;
            result = new AuditChangeWrapper(currentLastProcessedId);
        }
        else {
            Integer lastIndex = !records.isEmpty() ? records.size() - 1 : null;
            String currentLastProcessedId = (lastIndex != null) ? records.get(lastIndex).Id : null;

            Map<String, AuditChange> changes = new Map<String, AuditChange>();
            for(SetupAuditTrail record : records) {
                AuditChange change;
                String metaType = MAP_METADATA_TYPE_BY_AUDIT_ACTION.get(record.Section);
                if(metaType == null && record.Section != null && record.Section.startsWith(AUDIT_TRAIL_SECTION_STANDARD_OBJECTS)) {
                    metaType = MAP_METADATA_TYPE_BY_AUDIT_ACTION.get(AUDIT_TRAIL_SECTION_CUSTOM_OBJECTS);
                }
                if(String.isNotBlank(metaType)) {
                    change = changes.get(metaType) != null ? changes.get(metaType) : new AuditChange(metaType);
                    change.addChange(record.Display);
                    changes.put(metaType, change);
                }
            }
            result = new AuditChangeWrapper(changes.values(), currentLastProcessedId);
        }
        return result;
    }

    @TestVisible
    private static final Integer LIMIT_RECORDS_METADATA_TYPE = Test.isRunningTest() ? 1 : 5000;

    public static List<FlowDefinitionView> getListFlows() {
        List<FlowDefinitionView> result = [
            SELECT ApiName, NamespacePrefix, Label, IsActive
            FROM FlowDefinitionView
            WHERE NamespacePrefix = NULL
                OR NamespacePrefix = :ConfigUtil.currentOrgNameSpacePrefix
            LIMIT :LIMIT_RECORDS_METADATA_TYPE
        ];
        return result;
    }

    @TestVisible
    private static List<ApexClass> mockListApexClasses = new List<ApexClass>();

    public static List<ApexClass> getListApexClasses() {
        List<ApexClass> result = Test.isRunningTest() ? mockListApexClasses : [
            SELECT LengthWithoutComments, NamespacePrefix, Name
            FROM ApexClass
            WHERE NamespacePrefix = NULL
                OR NamespacePrefix = :ConfigUtil.currentOrgNameSpacePrefix
            LIMIT :LIMIT_RECORDS_METADATA_TYPE
        ];
        return result;
    }

    public static List<ApexTrigger> getListApexTriggers() {
        List<ApexTrigger> result = [
            SELECT LengthWithoutComments, NamespacePrefix, Name
            FROM ApexTrigger
            WHERE NamespacePrefix = NULL
            OR NamespacePrefix = :ConfigUtil.currentOrgNameSpacePrefix
            LIMIT :LIMIT_RECORDS_METADATA_TYPE
        ];
        return result;
    }

    public static List<ApexPage> getListApexPages() {
        List<ApexPage> result = [
            SELECT Id, NamespacePrefix, Name
            FROM ApexPage
            WHERE NamespacePrefix = NULL
            OR NamespacePrefix = :ConfigUtil.currentOrgNameSpacePrefix
            LIMIT :LIMIT_RECORDS_METADATA_TYPE
        ];
        return result;
    }

    public static List<ApexComponent> getListApexComponents() {
        List<ApexComponent> result = [
            SELECT Id, NamespacePrefix, Name
            FROM ApexComponent
            WHERE NamespacePrefix = NULL
            OR NamespacePrefix = :ConfigUtil.currentOrgNameSpacePrefix
            LIMIT :LIMIT_RECORDS_METADATA_TYPE
        ];
        return result;
    }

    public static Map<String, List<MetaWrapper>> METADATA_BUNDLE {
        get {
            if(METADATA_BUNDLE == null) {
                METADATA_BUNDLE = new Map<String, List<MetaWrapper>>();
                METADATA_BUNDLE.putAll(getMetadata(
                    new List<String>{
                        METADATA_TYPE_REMOTE_SITE_SETTINGS,
                        METADATA_TYPE_CONNECTED_APP,
                        METADATA_TYPE_NAMED_CREDENTIAL
                    }
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    new List<String>{
                        METADATA_TYPE_WORKFLOW,
                        METADATA_TYPE_APPROVAL_PROCESS,
                        METADATA_TYPE_AURA
                    }
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    new List<String>{
                        METADATA_TYPE_CUSTOM_METADATA,
                        METADATA_TYPE_CUSTOM_OBJECT
                    }
                ));

                METADATA_BUNDLE.putAll(getMetadata(
                    METADATA_TYPE_APEX_CLASS,
                    getListApexClasses(),
                    '',
                    'Name',
                    'LengthWithoutComments'
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    METADATA_TYPE_APEX_TRIGGER,
                    getListApexTriggers(),
                    '',
                    'Name',
                    'LengthWithoutComments'
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    METADATA_TYPE_APEX_PAGE,
                    getListApexPages(),
                    '',
                    'Name'
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    METADATA_TYPE_APEX_COMPONENT,
                    getListApexComponents(),
                    '',
                    'Name'
                ));
                METADATA_BUNDLE.putAll(getMetadata(
                    METADATA_TYPE_FLOW,
                    getListFlows(),
                    '',
                    'ApiName'
                ));
            }
            return METADATA_BUNDLE;
        }
        set;
    }

    public static Map<String, List<MetaWrapper>> getMetadata(String type, List<SObject> records, String nameSpaceField, String apiNameField) {
        return getMetadata(type, records, nameSpaceField, apiNameField, '');
    }
    public static Map<String, List<MetaWrapper>> getMetadata(String type, List<SObject> records, String nameSpaceField, String apiNameField, String sizeField) {
        Map<String, List<MetaWrapper>> result = new Map<String, List<MetaWrapper>>();

        for(SObject so : records) {
            List<MetaWrapper> packageItems = result.get(type) != null
                ? result.get(type)
                : new List<MetaWrapper>();
            String apiName = String.isNotBlank(nameSpaceField) ? (String.valueOf(so.get(nameSpaceField)) + '__') : '';
            apiName += String.valueOf(so.get(apiNameField));
            Integer sizeItem = String.isNotBlank(sizeField) ? Integer.valueOf(so.get(sizeField)) : 1;
            packageItems.add(new MetaWrapper(apiName, sizeItem));
            result.put(type, packageItems);
        }
        return result;
    }

    public static Map<String, List<MetaWrapper>> getMetadata(List<String> metadataTypes) {
        Map<String, List<MetaWrapper>> result = new Map<String, List<MetaWrapper>>();

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        for(String metadataType : metadataTypes) {
            MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
            query.type_x = metadataType;
            queries.add(query);
        }
        MetadataService.FileProperties[] fileProperties = GitHubUtils.getMetadataService().listMetadata(queries, GitHubUtils.METADATA_API_VERSION);
        if(fileProperties != null) {
            for(MetadataService.FileProperties fileProperty : fileProperties) {
                List<MetaWrapper> packageItems = result.get(fileProperty.type_x) != null
                    ? result.get(fileProperty.type_x)
                    : new List<MetaWrapper>();
                String fullApiName = fileProperty.fullName;
                if(fileProperty.type_x == METADATA_TYPE_CUSTOM_OBJECT) {
                    fullApiName = (String.isNotBlank(fileProperty.namespacePrefix)
                        && !fileProperty?.fullName?.startsWith(fileProperty.namespacePrefix))
                        ? fileProperty.namespacePrefix + '__' + fileProperty.fullName : fileProperty.fullName;
                }
                packageItems.add(new MetaWrapper(fullApiName));
                result.put(fileProperty.type_x, packageItems);
            }
        }

        return result;
    }

    public static final Integer METADATA_CONTAINER_ITEM_MAX_SIZE = 400000000; //400mb

    public class MetadataTypeWrapperContainer {
        public List<MetadataTypeWrapper> members;
        public Integer currentContainerSize = 0;

        public MetadataTypeWrapperContainer() {
            this.members = new List<MetadataTypeWrapper>();
        }

        public void addMember(String type, String member, Integer size) {
            if(!this.members.isEmpty()
                && this.currentContainerSize <= METADATA_CONTAINER_ITEM_MAX_SIZE
                && (this.currentContainerSize + size) <= METADATA_CONTAINER_ITEM_MAX_SIZE) {

                Integer lastIndex = this.members.size() == 0 ? 0 : this.members.size() - 1;
                this.currentContainerSize = this.currentContainerSize + size;
                this.members.get(lastIndex).addMember(member);
            }
            else {
                this.currentContainerSize = 0;
                this.members.add(new MetadataTypeWrapper(type, member));
            }
        }
    }

    public class MetadataTypeWrapper {
        public String jobId;
        public String type;
        public List<String> member;

        public MetadataTypeWrapper(String type, String member) {
            this.type = type;
            this.member = new List<String>{member};
        }

        public void addMember(String member) {
            this.member.add(member);
        }
    }

}