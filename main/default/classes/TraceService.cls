public without sharing class TraceService extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<TraceServiceRunWrapper>, Database.AllowsCallouts, Schedulable,Database.Stateful, Database.RaisesPlatformEvents {

    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }

    public static final String TRACE_REQUEST_STATUS_NEW = 'New';
    public static final String TRACE_REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    public static final String TRACE_REQUEST_STATUS_INACTIVE = 'Inactive';
    public static final String TRACE_SCHEDULE_STATUS_SCHEDULED = 'Scheduled';
    public static final String TRACE_SCHEDULE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String TRACE_SCHEDULE_STATUS_COMPLETED = 'Completed';
    public static final String TRACE_SCHEDULE_STATUS_INACTIVE = 'Inactive';

    public static final Integer MAX_SIZE_OF_USED_DEBUG_LOGS = 1000*1000*1000; // 1,000 MB of debug logs
    public static final Decimal REQUIRED_PERCENT_FREE_SPACE = 0.50; // 50%, 500 MB

    public static final String DEBUG_LOG_SERVICE_CHUNK_ENDPOINT = 'https://traceapi.pharos.ai/debug-log-service-chunk';

    public static final String DEBUG_LOG_SERVICE_ENDPOINT = 'https://traceapi.pharos.ai/debug-log-service';

    public static final String DEBUG_LOG_SERVICE_NAME = 'Pharos_ai_Trace_Api_Service';
    public static final String DEBUG_LOG_SERVICE_DESCRIPTION = 'Pharos Trace Api Service';
    public static final String SFDC_SERVET_FILE_DOWNLOAD = '/servlet/servlet.FileDownload?file=';

    public static final Integer MAX_LOCAL_LOG_LENGTH = 5000000;


    public Connected_Org__c corg;

    private static TraceService instance = null;

    public static TraceService getInstance() {
        if (instance == null) {
            instance = new TraceService(Logger.getInstance());
        }
        return instance;
    }

    private TraceService(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('TraceService', this);
    }

    public override Boolean initialValidation() {
        return ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS?.Enabled__c && PermissionsUtil.DebugLogServiceEnabled;
    }

    public override Integer getIterationsCount() {
        return getTraceServiceRuns().size();
    }

    public Iterable<TraceServiceRunWrapper> start(Database.BatchableContext batchableContext) {
        TraceServiceRunIterable iterable = new TraceServiceRunIterable(getTraceServiceRuns());
        return iterable;
    }

    public void execute(Database.BatchableContext batchableContext, List<TraceServiceRunWrapper> scope) {
        TraceServiceRunWrapper runInstance = (TraceServiceRunWrapper)scope.get(0);
        if(runInstance.type == TraceService.TraceServiceRunType.LOCAL_RUN_SERVICE) {
            try {
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(runInstance.sourceId);
                ApexLog apexLog = getApexLog(runInstance.apexLogId);

                // run chunk lambda service
                DebugLogServiceChunkResponse response = startDebugLogServiceChunk(corg, apexLog);
                // increase metrics
                if(response != null) {
                    increaseDebugLogServiceUsage(1);
                    upsertLocalFlag(apexLog?.StartTime, corg);
                }
            }
            catch(Exception e){
                loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'execute'));
            }
        }
        else if(runInstance.type == TraceService.TraceServiceRunType.RUN_SERVICE) {
            try {
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(runInstance.sourceId);
                // update last created log flag
                updateLastCreatedLogFlag(corg);

                DebugLogServiceResponse response;
                if(hasNewLogs(corg)) {
                    // run lambda service
                    response = startDebugLogService(corg, runInstance.filterByLogLength, runInstance.lastProcessedLogTime);
                }
                // increase metrics
                if(response != null) {
                    Integer usedMetrics = response?.sendResults?.successSendRecords;
                    increaseDebugLogServiceUsage(usedMetrics);
                }
            }
            catch(Exception e) {
                loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'execute'));
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        // activate / inactivate traceses, delete old debug logs
        loggerInstance?.flush();
        checkTraceServiceRun();
    }

    public static void checkTraceServiceRun() {
        TraceService.OrganizationStorageHelper helper = new TraceService.OrganizationStorageHelper();
        if (!helper.sourcesForDebugLogServiceRun.isEmpty()) {
            TraceBatch.getInstance(helper.sourcesForDebugLogServiceRun).startBatch();
        }
        if (!helper.sourcesForRetentionRun.isEmpty()) {
            TraceRetentionBatch.getInstance(helper).startBatch();
        }
    }

    public static List<TraceServiceRunWrapper> getTraceServiceRuns() {
        List<TraceServiceRunWrapper> result = new List<TraceServiceRunWrapper>();
        List<String> sources = getActiveTraceRequestSources();
        for(String sourceId : sources) {
            if(sourceId == UserInfo.getOrganizationId()) {
                for(ApexLog log : getLocalApexLogs()) {
                    result.add(new TraceServiceRunWrapper(TraceService.TraceServiceRunType.LOCAL_RUN_SERVICE, sourceId, log.Id));
                }
                result.add(new TraceServiceRunWrapper(TraceService.TraceServiceRunType.RUN_SERVICE, sourceId, true, getLastProcessedLogTime()));
            }
            else {
                result.add(new TraceServiceRunWrapper(TraceService.TraceServiceRunType.RUN_SERVICE, sourceId));
            }
        }
        return result;
    }

    public static List<ApexLog> getLocalApexLogs() {
        List<ApexLog> result = new List<ApexLog>();
        DateTime dt = getLastProcessedLogTime();
        result = [SELECT Id FROM ApexLog WHERE StartTime >= :dt AND LogLength < :MAX_LOCAL_LOG_LENGTH ORDER BY StartTime ASC];
        return result;
    }

    public Enum TraceServiceRunType {RUN_SERVICE, LOCAL_RUN_SERVICE}
    
    public class TraceServiceRunWrapper {
        public TraceServiceRunType type;
        public String sourceId;
        public String apexLogId;
        public Boolean filterByLogLength = false;
        public DateTime lastProcessedLogTime;

        public TraceServiceRunWrapper(TraceServiceRunType type, String sourceId) {
            this.type = type;
            this.sourceId = sourceId;
        }

        public TraceServiceRunWrapper(TraceServiceRunType type, String sourceId, Boolean filterByLogLength, DateTime lastProcessedLogTime) {
            this.type = type;
            this.sourceId = sourceId;
            this.filterByLogLength = filterByLogLength;
            this.lastProcessedLogTime = lastProcessedLogTime;
        }

        public TraceServiceRunWrapper(TraceServiceRunType type, String sourceId, String apexLogId) {
            this.type = type;
            this.sourceId = sourceId;
            this.apexLogId = apexLogId;
        }
    }

    public class TraceServiceRunIterable implements Iterable<TraceServiceRunWrapper> {

        private List<TraceServiceRunWrapper> traceServiceRuns;

        public TraceServiceRunIterable() {
            this.traceServiceRuns = new List<TraceServiceRunWrapper>();
        }

        public TraceServiceRunIterable(List<TraceServiceRunWrapper> traceServiceRuns) {
            this.traceServiceRuns = traceServiceRuns;
        }

        public Iterator<TraceServiceRunWrapper> iterator() {
            return new TraceServiceRunIterator(this.traceServiceRuns);
        }
    }

    public class TraceServiceRunIterator implements Iterator<TraceServiceRunWrapper> {
        private List<TraceServiceRunWrapper> traceServiceRuns;
        private Integer index;

        public TraceServiceRunIterator(List<TraceServiceRunWrapper> defaults) {
            this.traceServiceRuns = defaults == null ? new List<TraceServiceRunWrapper>() : defaults;
            this.index = 0;
        }

        public TraceServiceRunIterator() {
            this(new List<TraceServiceRunWrapper>());
        }

        public Boolean hasNext() {
            return this.index < traceServiceRuns.size() ? true : false;
        }

        public TraceServiceRunWrapper next() {
            return this.traceServiceRuns[this.index++];
        }
    }

    public void increaseDebugLogServiceUsage(Integer usedMetrics) {
        if(usedMetrics != null && usedMetrics > 0) {
            try {
                Integer packageUsage = PermissionsUtil.getPackageFeatureInteger(PermissionsUtil.FEATURE_DEBUG_LOG_SERVICE_USAGE, 0);
                packageUsage += usedMetrics;
                FeatureManagement.setPackageIntegerValue(PermissionsUtil.FEATURE_DEBUG_LOG_SERVICE_USAGE, packageUsage);
            }
            catch(Exception e) {
                loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'increaseDebugLogServiceUsage'));
            }
        }
    }

    public Enum DebugLogLevel {
        NONE,
        ERROR,
        WARN,
        INFO,
        DEBUG,
        FINE,
        FINER,
        FINEST
    }

    public static DebugLogLevel getDebugLogLevelByName(String name) {
        DebugLogLevel result;
        try {
            result = DebugLogLevel.valueOf(name);
        }
        catch(System.NoSuchElementException e) {}
        return result;
    }

    public Enum DebugLogType {
        CLASS_TRACING,
        DEVELOPER_LOG,
        PROFILING, // (reserved for future use)
        USER_DEBUG
    }
    
    public static DebugLevel createDefaultDebugLevel() {
        DebugLevel result = new DebugLevel();
        result.ApexCode = DebugLogLevel.FINEST;
        result.ApexProfiling = DebugLogLevel.FINE;
        result.Callout = DebugLogLevel.FINE;
        result.Database = DebugLogLevel.FINE;
        result.System_x = DebugLogLevel.FINE;
        result.Validation = DebugLogLevel.FINE;
        result.Visualforce = DebugLogLevel.FINE;
        result.Workflow = DebugLogLevel.FINER;
        return result;
    }

    public DebugLevel getDefaultDebugLevel() {
        DebugLevel result;
        for(DebugLevel dl : getDebugLevelList()) {
            if(dl?.DeveloperName == DEFAULT_DEBUG_LEVEL_NAME && dl?.MasterLabel == DEFAULT_DEBUG_LEVEL_NAME) {
                result = dl;
                break;
            }
        }
        return result;
    }

    public List<DebugLevel> getDebugLevelList() {
        List<DebugLevel> listLevels = new List<DebugLevel>();
        try {
            String b = HttpUtils.get(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_LEVELS,
                getToolingHeaders(this.corg),
                200
            );
            Map<String, Object> respResults = (Map<String, Object>)JSON.deserializeUntyped(b);
            if (respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS) != null) {
                String jsonResponse = JSON.serialize(respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS));
                listLevels = (List<DebugLevel>)JSON.deserialize(replaceSystemField(jsonResponse), List<DebugLevel>.class);
            }
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'getDebugLevelList'));
        }
        return listLevels;
    }

    public static String replaceSystemField(String inputJSON) {
        return inputJSON.replace('System','System_x');
    }

    public static String restoreSystemField(String inputJSON) {
        return inputJSON.replace('System_x','System');
    }

    public Database.SaveResult insertDebugLevel(DebugLevel debugLevel) {
        Database.SaveResult result;
        try {
            String b = HttpUtils.post(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL,
                restoreSystemField(JSON.serialize(debugLevel)),
                getToolingHeaders(this.corg),
                201
            );
            result = (Database.SaveResult)JSON.deserialize(b, Database.SaveResult.class);
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'insertDebugLevel'));
        }
        return result;
    }

    public Boolean updateDebugLevel(DebugLevel debugLevel) {
        Boolean result = false;
        try {
            String externalId = debugLevel.Id;
            // The Id field should not be specified in the sobject data.
            debugLevel.Id = null;
            String b = HttpUtils.post(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL + '/' + externalId + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
                restoreSystemField(JSON.serialize(debugLevel)),
                getToolingHeaders(this.corg),
                204
            );
            result = true;
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'updateDebugLevel'));
        }
        return result;
    }

    public Database.DeleteResult deleteDebugLevel(DebugLevel debugLevel) {
        Database.DeleteResult result;
        try {
            String b = HttpUtils.del(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_DEBUG_LOG_LEVEL + '/' + debugLevel.Id,
                getToolingHeaders(this.corg),
                200
            );
            result = (Database.DeleteResult)JSON.deserialize(b, Database.DeleteResult.class);
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'deleteDebugLevel'));
        }
        return result;
    }

    public static Map<String, String> getToolingHeaders(Connected_Org__c corg) {
        return new Map<String, String> {
            'Authorization' => 'Bearer ' + ConnectedOrgService.getConnectedOrgAccessToken(corg),
            'Content-Type' => 'application/json'
        };
    }


    public static final String DEFAULT_DEBUG_LEVEL_NAME = 'PharosDefaultLevel';
    public static final String DEFAULT_DEBUG_LEVEL_LANGUAGE = 'en_US';

    public class DebugLevel {

        public String Id;
        public String DeveloperName;
        public String Language; //en_US
        public String MasterLabel;

        public DebugLogLevel ApexCode;
        public DebugLogLevel ApexProfiling;
        public DebugLogLevel Callout;
        public DebugLogLevel Database;
        public DebugLogLevel System_x;
        public DebugLogLevel Validation;
        public DebugLogLevel Visualforce;
        public DebugLogLevel Workflow;

        public DebugLevel() {
            this('');
        }

        public DebugLevel(String tracePrefix) {
            this.Language = DEFAULT_DEBUG_LEVEL_LANGUAGE;
            this.DeveloperName = DEFAULT_DEBUG_LEVEL_NAME + tracePrefix;
            this.MasterLabel = DEFAULT_DEBUG_LEVEL_NAME + tracePrefix;
        }

        public void copyLevels(Trace_Request__c traceRequest) {
            this.ApexCode = getDebugLogLevelByName(traceRequest.Apex_Code__c);
            this.ApexProfiling = getDebugLogLevelByName(traceRequest.Apex_Profiling__c);
            this.Callout = getDebugLogLevelByName(traceRequest.Callout__c);
            this.Database = getDebugLogLevelByName(traceRequest.Database__c);
            this.System_x = getDebugLogLevelByName(traceRequest.System__c);
            this.Validation = getDebugLogLevelByName(traceRequest.Validation__c);
            this.Visualforce = getDebugLogLevelByName(traceRequest.Visualforce__c);
            this.Workflow = getDebugLogLevelByName(traceRequest.Workflow__c);
        }

        public void copyLevels(DebugLevel debugLevel) {
            this.ApexCode = debugLevel.ApexCode;
            this.ApexProfiling = debugLevel.ApexProfiling;
            this.Callout = debugLevel.Callout;
            this.Database = debugLevel.Database;
            this.System_x = debugLevel.System_x;
            this.Validation = debugLevel.Validation;
            this.Visualforce = debugLevel.Visualforce;
            this.Workflow = debugLevel.Workflow;
        }

        public Boolean isLevelsEqualTo(DebugLevel debugLevel) {
            return this.ApexCode == debugLevel.ApexCode
                && this.ApexProfiling == debugLevel.ApexProfiling
                && this.Callout == debugLevel.Callout
                && this.Database == debugLevel.Database
                && this.System_x == debugLevel.System_x
                && this.Validation == debugLevel.Validation
                && this.Visualforce == debugLevel.Visualforce
                && this.Workflow == debugLevel.Workflow;
        }
    }

    public class TraceFlag {

        public String Id;
        public String DebugLevelId;
        public DateTime ExpirationDate;
        public DateTime StartDate;
        public String LogType;
        public String TracedEntityId;

        public DebugLogLevel ApexCode;
        public DebugLogLevel ApexProfiling;
        public DebugLogLevel Callout;
        public DebugLogLevel Database;
        public DebugLogLevel System_x;
        public DebugLogLevel Validation;
        public DebugLogLevel Visualforce;
        public DebugLogLevel Workflow;

        public TraceFlag(){}
    }

    public TraceFlag createTraceFlag(DateTime expirationDate, DateTime startDate) {
        return createTraceFlag(getDefaultDebugLevel().Id, DebugLogType.USER_DEBUG.name(), UserInfo.getUserId(), expirationDate, startDate);
    }
    
    public TraceFlag createTraceFlag(String debugLevelId, String logType, String tracedEntityId, DateTime expirationDate, DateTime startDate) {
        TraceFlag tf = new TraceFlag();
        tf.debugLevelId = debugLevelId;
        tf.logType = logType;
        tf.tracedEntityId = tracedEntityId;
        tf.expirationDate = expirationDate;
        tf.startDate = startDate;
        return tf;
    }

    public Database.SaveResult insertTraceFlag(TraceFlag traceFlag) {
        Database.SaveResult result;
        try {
            String b = HttpUtils.post(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG,
                restoreSystemField(JSON.serialize(traceFlag)),
                getToolingHeaders(this.corg),
                201
            );
            result = (Database.SaveResult)JSON.deserialize(b, Database.SaveResult.class);
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'insertTraceFlag'));
        }
        return result;
    }

    public Boolean updateTraceFlag(TraceFlag traceFlag) {
        Boolean result = false;
        try {
            String externalId = traceFlag.Id;
            // The Id field should not be specified in the sobject data.
            traceFlag.Id = null;
            String b = HttpUtils.post(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG + '/' + externalId + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
                restoreSystemField(JSON.serialize(traceFlag, true)),
                getToolingHeaders(this.corg),
                204
            );
            // 204 No Content
            result = true;
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'updateTraceFlag'));
        }
        return result;
    }

    public Database.DeleteResult deleteTraceFlag(TraceFlag traceFlag) {
        Database.DeleteResult result;
        try {
            String b = HttpUtils.del(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_API_UPDATE_TRACE_FLAG + '/' + traceFlag.Id,
                getToolingHeaders(this.corg),
                200
            );
            result = (Database.DeleteResult)JSON.deserialize(b, Database.DeleteResult.class);
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'deleteTraceFlag'));
        }
        return result;
    }

    public List<TraceFlag> getAllTraceFlags() {
        List<TraceFlag> traceFlags;
        try {
            String b = HttpUtils.get(
                this.corg.Instance_Url__c + ConfigUtil.REMOTE_TOOLING_QUERY_ENDPOINT + ConfigUtil.TOOLING_QUERY_GET_DEBUG_TRACE_FLAGS,
                getToolingHeaders(this.corg),
                200
            );
            Map<String, Object> respResults = (Map<String, Object>)JSON.deserializeUntyped(b);
            if (respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS) != null) {
                String jsonResponse = JSON.serialize(respResults.get(ConfigUtil.REMOTE_SITE_SETTINGS_KEY_RECORDS));
                jsonResponse = jsonResponse.replace('System','System_x');
                traceFlags = (List<TraceFlag>)JSON.deserialize(jsonResponse, List<TraceFlag>.class);
            }
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'getAllTraceFlags'));
        }
        return traceFlags;
    }

    public class SumAggregateResultWrapper {
        public String totalSumm;
        public String totalCount;
        public String avgSize;

        public Integer totalSummInt;
        public Integer totalCountInt;
        public Integer avgSizeInt;

        public SumAggregateResultWrapper(){}

        public SumAggregateResultWrapper convertValues() {
            this.totalSummInt = (String.isNotBlank(this.totalSumm)) ? Double.valueOf(String.valueOf(this.totalSumm)).intValue() : 0;
            this.totalCountInt = (String.isNotBlank(this.totalCount)) ? Double.valueOf(String.valueOf(this.totalCount)).intValue() : 0;
            this.avgSizeInt = (String.isNotBlank(this.avgSize)) ? Double.valueOf(String.valueOf(this.avgSize)).intValue() : 0;
            return this;
        }
    }
    
    public static List<SumAggregateResultWrapper> getSourceStorageInfo(Connected_Org__c corg) {
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'SUM(LogLength) totalSumm', 'COUNT(Id) totalCount', 'AVG(LogLength) avgSize'})
            .build();
        return (List<SumAggregateResultWrapper>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<SumAggregateResultWrapper>.class);
    }

    public static List<Object> runQuery(Connected_Org__c corg, String q) {
        return isThisOrg(corg) ? Database.query(q) : HttpUtils.runToolingQuery(corg.Instance_Url__c, ConnectedOrgService.getConnectedOrgAccessToken(corg), q);
    }

    public static Boolean isThisOrg(Connected_Org__c corg) {
        return UserInfo.getOrganizationId() == Id.valueOf(corg.Name);
    }

    public static DateTime getLastProcessedLogTime() {
        DateTime dt = Debug_Log_Service_Flag__c.getOrgDefaults()?.Last_Processed_Log__c;
        return  (dt == null) ? DateTime.now().addHours(-1) : dt;
    }

    public static Set<String> getActiveTracedEntityIds() {
        Set<String> tracedIds = new Set<String>();
        for(Trace_Request__c tr : [SELECT Traced_Entity_Id__c FROM Trace_Request__c WHERE Status__c = :TRACE_REQUEST_STATUS_IN_PROGRESS]) {
            tracedIds.add(tr.Traced_Entity_Id__c);
        }
        return tracedIds;
    }

    public static List<String> getAllTraceRequestSources() {
        return getAllTraceRequestSources(new List<String>{TRACE_REQUEST_STATUS_NEW, TRACE_REQUEST_STATUS_IN_PROGRESS});
    }

    public static List<String> getActiveTraceRequestSources() {
        return getAllTraceRequestSources(new List<String>{TRACE_REQUEST_STATUS_IN_PROGRESS});
    }

    public static List<String> getAllTraceRequestSources(List<String> statuses) {
        Set<String> sourceIds = new Set<String>();
        for(Trace_Request__c tr : [SELECT Source__c FROM Trace_Request__c WHERE Status__c IN :statuses]) {
            if(tr.Source__c != null) {
                sourceIds.add(tr.Source__c);
            }
        }
        return (sourceIds.isEmpty()) ? new List<String>() : new List<String>(sourceIds);
    }

    public class OrganizationStorageHelper {

        public List<String> sources = new List<String>();
        public Set<String> sourcesForRetentionRun = new Set<String>();
        public Set<String> sourcesForDebugLogServiceRun = new Set<String>();
        public Map<String, SumAggregateResultWrapper> mapInfo = new Map<String, SumAggregateResultWrapper>();
        public Map<String, Integer> mapRetentionRuns = new Map<String, Integer>();
        public Integer totalRetentionRuns = 0;

        public OrganizationStorageHelper() {
            // collect all OrganizationIds from active trace requests
            this.sources = getAllTraceRequestSources();
            
            for(String sourceId : this.sources) {
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(sourceId);
                List<SumAggregateResultWrapper> sourceStorageInfo = getSourceStorageInfo(corg);

                if(!sourceStorageInfo.isEmpty()) {
                    SumAggregateResultWrapper storageInfo = sourceStorageInfo.get(0).convertValues();
                    mapInfo.put(sourceId, storageInfo);

                    if(storageInfo.totalSummInt >= Integer.valueOf(MAX_SIZE_OF_USED_DEBUG_LOGS*REQUIRED_PERCENT_FREE_SPACE)) {
                        sourcesForRetentionRun.add(sourceId);
                        Integer retentionRunsPerOrg = (storageInfo.totalSummInt - Integer.valueOf(MAX_SIZE_OF_USED_DEBUG_LOGS * REQUIRED_PERCENT_FREE_SPACE)) / (storageInfo.avgSizeInt);
                        totalRetentionRuns += retentionRunsPerOrg;
                        mapRetentionRuns.put(sourceId, retentionRunsPerOrg);
                    }
                    else {
                        sourcesForDebugLogServiceRun.add(sourceId);
                    }
                }
            }
        }
    }

    public void setConnectedOrgById(String sourceId) {
        this.corg = ConnectedOrgService.getConnectedOrgById(sourceId);
    }

    public void processNewTraceFlag(Trace_Request__c traceRequest) {
        processNewTraceFlag(traceRequest, false);
    }

    public void processNewTraceFlag(Trace_Request__c newTraceRequest, Boolean checkConsistencyTraceFlag) {

        if(!checkConsistencyTraceFlag) {
            Datetime dtNow = Datetime.now();
            Datetime traceStartDate = newTraceRequest.Start_Date__c;
            // dont process new traces before/after 1h window
            if(traceStartDate.addHours(1) <= dtNow || traceStartDate >= dtNow.addHours(1)) {
                return;
            }
        }

        // connection setup
        setConnectedOrgById(newTraceRequest.Source__c);

        Boolean isDefaultDebugLevel = isDefaultDebugLevel(newTraceRequest);
        DebugLevel traceDebugLevel;
        TraceFlag existTraceFlag; 

        if(isDefaultDebugLevel) {
            traceDebugLevel = getDefaultDebugLevel();
            if(traceDebugLevel == null) {
                traceDebugLevel = createDefaultDebugLevel();
            }
            else {
                DebugLevel defaultLevel = createDefaultDebugLevel();
                if(!traceDebugLevel.isLevelsEqualTo(defaultLevel)) {
                    traceDebugLevel.copyLevels(defaultLevel);
                    Boolean updateResult = updateDebugLevel(traceDebugLevel);
                }
            }
        }
        else {
            traceDebugLevel = new DebugLevel(newTraceRequest.Id);
            traceDebugLevel.copyLevels(newTraceRequest);
        }

        if(String.isBlank(traceDebugLevel?.Id)) {
            Database.SaveResult insertResult = insertDebugLevel(traceDebugLevel);
            if(insertResult.isSuccess()) {
                traceDebugLevel.Id = insertResult.getId();
            }
        }

        for(TraceFlag tf : getAllTraceFlags()) {
            if(tf.LogType == DebugLogType.USER_DEBUG.name() 
                && tf.TracedEntityId?.left(15) == newTraceRequest.Traced_Entity_Id__c?.left(15)) {
                // skip oldest trace flag by ExpirationDate
                if(existTraceFlag != null && existTraceFlag.ExpirationDate > tf.ExpirationDate) {
                    continue;
                }
                existTraceFlag = tf;
            }
        }
            
        Database.SaveResult insertTraceResult;
        Boolean updateTraceResultSuccess;
        if(existTraceFlag == null) {
            existTraceFlag = createTraceFlag(traceDebugLevel.Id, DebugLogType.USER_DEBUG.name(), newTraceRequest.Traced_Entity_Id__c, newTraceRequest.End_Date__c, newTraceRequest.Start_Date__c);

            insertTraceResult = insertTraceFlag(existTraceFlag);
        }
        else {
            Boolean hasChanges = false;
            if(existTraceFlag.ExpirationDate < newTraceRequest.End_Date__c) {
                existTraceFlag.ExpirationDate = newTraceRequest.End_Date__c;
                existTraceFlag.StartDate = newTraceRequest.Start_Date__c;
                hasChanges = true;
            }
            if(existTraceFlag.DebugLevelId != traceDebugLevel.Id) {
                existTraceFlag.DebugLevelId = traceDebugLevel.Id;
                hasChanges = true;
            }

            if(hasChanges) {
                // clear not updatable fields
                existTraceFlag.LogType = null;
                existTraceFlag.TracedEntityId = null;
                existTraceFlag.ApexCode = null;
                existTraceFlag.ApexProfiling = null;
                existTraceFlag.Callout = null;
                existTraceFlag.Database = null;
                existTraceFlag.System_x = null;
                existTraceFlag.Validation = null;
                existTraceFlag.Visualforce = null;
                existTraceFlag.Workflow = null;

                updateTraceResultSuccess = updateTraceFlag(existTraceFlag);
            }
        }

        if (!checkConsistencyTraceFlag && (insertTraceResult == null || insertTraceResult.isSuccess() || updateTraceResultSuccess)) {
            PermissionsUtil.putSObjectField(newTraceRequest, Schema.SObjectType.Trace_Request__c.fields.Status__c, TRACE_REQUEST_STATUS_IN_PROGRESS);
            DatabaseUtils.getInstance().performUpdateDML(new List<Trace_Request__c>{newTraceRequest}, Schema.SObjectType.Trace_Request__c)
                    .handleError(TraceService.class.getName(), '.processNewTraceFlag', loggerInstance);
        }
    }
    public DebugLogLevel ApexCode;
        public DebugLogLevel ApexProfiling;
        public DebugLogLevel Callout;
        public DebugLogLevel Database;
        public DebugLogLevel System_x;
        public DebugLogLevel Validation;
        public DebugLogLevel Visualforce;
        public DebugLogLevel Workflow;

    public static boolean isDefaultDebugLevel(Trace_Request__c traceRequest) {
        DebugLevel defaultDebugLevel = createDefaultDebugLevel();
        return (traceRequest.Apex_Code__c == defaultDebugLevel.ApexCode.name()
            && traceRequest.Apex_Profiling__c == defaultDebugLevel.ApexProfiling.name()
            && traceRequest.Callout__c == defaultDebugLevel.Callout.name()
            && traceRequest.Database__c == defaultDebugLevel.Database.name()
            && traceRequest.System__c == defaultDebugLevel.System_x.name()
            && traceRequest.Validation__c == defaultDebugLevel.Validation.name()
            && traceRequest.Visualforce__c == defaultDebugLevel.Visualforce.name()
            && traceRequest.Workflow__c == defaultDebugLevel.Workflow.name());
    }

    ///services/data/vXX.X/composite/sobjects?ids=recordId,recordId
    public List<Database.DeleteResult> deleteDebugLogs(Set<Id> scopeIds) {
        List<Database.DeleteResult> result;
        try {
            if(!scopeIds.isEmpty()) {
                String recordIds = String.join(new List<Id>(scopeIds), ',');
                String b = HttpUtils.del(
                    this.corg.Instance_Url__c + ConfigUtil.REMOTE_REST_COMPOSITE_API_DELETE_RECORDS + recordIds,
                    getToolingHeaders(this.corg),
                    200
                );
                result = (List<Database.DeleteResult>)JSON.deserialize(b, List<Database.DeleteResult>.class);
            }
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'deleteDebugLogs'));
        }
        return result;
    }

    public class DebugLogServiceChunkResponse {
        public Boolean success;
        public String name;
        public String message;
        public String stack;
    
        public DebugLogServiceChunkResponse(){}
    }

    public class DebugLogServiceResponse {
        public List<TraceRequest> traceRequests;
        public SQSSendResult sendResults;
    
        public DebugLogServiceResponse(){}
    }

    public class SQSSendResult {
        public Integer successSendRecords;
        public Integer debugLogRecords;
        public Map<String, String> mapErrors;

        public SQSSendResult(){}
    }

    public class TraceRequest {
        public String Id;
        public String UserId;
        public String Status;
        public String Category;
        public List<String> StackTraceLines;

        public TraceRequest(){}
    }

    //2022-11-24T11:11:38.000+0000
    //ISO8601 format
    public static final String DATE_TIME_FORMAT_ISO08601 = 'yyyy-MM-dd\'T\'HH:mm:ss';
    public static final String DATE_TIME_FORMAT_ISO08601_TIME_ZONE_UTC = '+0000';
    public static final String DEBUG_LOG_SERVICE_CHUNK = '1000';
    public static final String DEFAULT_TRACE_WINDOW_LOGS = '5';
    public class DebugLogServiceRequest {
        public String oid;
        public String instance;
        public String session;
        public String dt;
        public String ns;
        public String limits;
        public String settingsId;
        public String sourceId;
        public String sourceInstance;
        public String sourceSession;
        public String traceWindow;
        public Boolean filterByLogLength = false;

        public DebugLogServiceRequest(Datetime startTime, Connected_Org__c corg, String settingsId, Boolean filterByLogLength) {
            this.oid = UserInfo.getOrganizationId();
            this.instance = System.Url.getOrgDomainUrl().toExternalForm();
            this.session = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
            this.dt = startTime.formatGmt(DATE_TIME_FORMAT_ISO08601) + DATE_TIME_FORMAT_ISO08601_TIME_ZONE_UTC;
            this.ns = ConfigUtil.nameSpacePrefix; //'pharos__';
            this.limits = DEBUG_LOG_SERVICE_CHUNK;
            this.settingsId = settingsId;
            this.sourceId = corg.Name;
            this.sourceInstance = corg.Instance_Url__c;
            this.sourceSession = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getConnectedOrgAccessToken(corg)));
            this.traceWindow = String.isNotBlank(ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS?.Trace_Window__c)
               ? ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Trace_Window__c : DEFAULT_TRACE_WINDOW_LOGS;
            this.filterByLogLength = filterByLogLength;
        }
    }

    public with sharing class DebugLogServiceChunkRequest {
        public String oid;
        public String instance;
        public String session;
        public String dt;
        public String ns;
        public String limits;
        public String settingsId;
        public String sourceId;
        public String sourceInstance;
        public String sourceSession;
        public String traceWindow;

        public SObject record;
        public String apexLogBody;
        public List<Trace_Request__c> traceRequests;

        public DebugLogServiceChunkRequest(Connected_Org__c corg, ApexLog apexLog) {
            this.oid = UserInfo.getOrganizationId();
            this.instance = System.Url.getOrgDomainUrl().toExternalForm();
            this.session = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
            this.ns = ConfigUtil.nameSpacePrefix; //'pharos__';
            this.limits = DEBUG_LOG_SERVICE_CHUNK;
            this.sourceId = corg.Name;
            this.sourceInstance = corg.Instance_Url__c;
            this.sourceSession = EncodingUtil.base64Encode(Blob.ValueOf(ConnectedOrgService.getConnectedOrgAccessToken(corg)));
            this.traceWindow = String.isNotBlank(ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS?.Trace_Window__c)
               ? ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS.Trace_Window__c : DEFAULT_TRACE_WINDOW_LOGS;

            this.record = apexLog;

            PageReference pageRef = new PageReference(SFDC_SERVET_FILE_DOWNLOAD + apexLog.Id);
            this.apexLogBody = Test.isRunningTest() ? 'testcontent' : EncodingUtil.base64Encode(pageRef.getContent());

            this.traceRequests = [
                SELECT Id,Issue__c,Trace_Schedule__c,Traced_Entity_Id__c,
                    Status__c,Issue__r.Category__c,Issue__r.Log__r.Stacktrace__c,
                    Issue__r.Log__r.Flow_Version_Id__c,Issue__r.Log__r.Async_Job_Id__c,
                    Issue__r.Key__c
                FROM Trace_Request__c
                // process requests which ended no older than -1 hour from now
                WHERE End_Date__c >= :DateTime.now().addHours(-1)
                ORDER BY End_Date__c DESC
                LIMIT 200
            ];
        }
    }

    public ApexLog getApexLog(String apexLogId) {
        return [
            SELECT Id, LogLength, SystemModStamp, LogUserId, Operation, Status, StartTime, DurationMilliseconds
            FROM ApexLog
            WHERE Id =: apexLogId
            LIMIT 1
        ];
    }

    // 29 seconds, after 29 seconds AWS HTTP gateway return 500 error code
    private static final Integer AWS_HTTP_GATEWAY_TIMEOUT_LIMIT = 29;

    private Boolean isAwsHttpGatewayTimeoutIssue(Long startRequestTime, Long stopRequestTime) {
        if(startRequestTime != null && stopRequestTime != null) {
            Integer executionTimeSeconds = (startRequestTime/1000).intValue() - (stopRequestTime/1000).intValue();
            return executionTimeSeconds >= AWS_HTTP_GATEWAY_TIMEOUT_LIMIT;
        }
        return false;
    }

    public DebugLogServiceChunkResponse startDebugLogServiceChunk(Connected_Org__c corg, ApexLog apexLog) {
        DebugLogServiceChunkResponse result;
        Long startRequestTime;
        Long stopRequestTime;
        try {
            if(PermissionsUtil.DebugLogServiceEnabled) {
                DebugLogServiceChunkRequest request = new DebugLogServiceChunkRequest(corg, apexLog);
                startRequestTime = System.currentTimeMillis();
                String b = HttpUtils.post(
                    DEBUG_LOG_SERVICE_CHUNK_ENDPOINT,
                    JSON.serialize(request),
                    HttpUtils.getHeadersWithApiKeyAndJson(),
                    200
                );
                result = (DebugLogServiceChunkResponse)JSON.deserialize(b, DebugLogServiceChunkResponse.class);
            }
        }
        catch(Exception e) {
            stopRequestTime = System.currentTimeMillis();

            // if this is not an aws http-gateway error, create a log
            // if this is an aws http-gateway error, skip this error, because the main lambda code will continue to execute
            if(!isAwsHttpGatewayTimeoutIssue(startRequestTime, stopRequestTime)) {
                loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'startDebugLogServiceChunk'));
            }
        }
        return result;
    }

    public DebugLogServiceResponse startDebugLogService(Connected_Org__c corg, Boolean filterByLogLength, DateTime lastProcessedLogTime){
        DebugLogServiceResponse result;
        try {
            if(PermissionsUtil.DebugLogServiceEnabled) {
                List<Debug_Log_Service_Flag__c> flags = getDebugLogServiceFlag(corg);
                DateTime dt;
                if(lastProcessedLogTime != null) {
                    dt = lastProcessedLogTime;
                } else {
                    dt = (!flags.isEmpty()) ? flags.get(0)?.Last_Processed_Log__c : null;
                }
                if (dt == null) {
                    List<Trace_Request__c> activeTraceRequests = [
                        SELECT Start_Date__c
                        FROM Trace_Request__c
                        WHERE Status__c IN (:TRACE_REQUEST_STATUS_NEW, :TRACE_REQUEST_STATUS_IN_PROGRESS)
                        AND End_Date__c > :DateTime.now()
                        ORDER BY Start_Date__c DESC
                        LIMIT 1
                    ];
                    if (!activeTraceRequests.isEmpty() && activeTraceRequests[0].Start_Date__c != null) {
                        dt = activeTraceRequests[0].Start_Date__c;
                    }
                }

                dt = (dt == null) ? DateTime.now().addHours(-1) : dt;
                String settingsId = (!flags.isEmpty()) ? flags.get(0)?.Id : null;
                DebugLogServiceRequest request = new DebugLogServiceRequest(dt, corg, settingsId, filterByLogLength);
                String b = HttpUtils.post(
                    DEBUG_LOG_SERVICE_ENDPOINT,
                    JSON.serialize(request),
                    HttpUtils.getHeadersWithApiKeyAndJson(),
                    200
                );
                result = (DebugLogServiceResponse)JSON.deserialize(b, DebugLogServiceResponse.class);
            }
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'startDebugLogService'));
        }
        return result;
    }

    public Boolean createDebugLogServiceFlag(Debug_Log_Service_Flag__c flag, Connected_Org__c corg) {
        Boolean result = false;
        try {
            String b = HttpUtils.post(
                corg.Instance_Url__c + ConfigUtil.DESCRIBE_SOBJECT_PATH + Schema.sObjectType.Debug_Log_Service_Flag__c.Name,
                JSON.serialize(flag),
                getToolingHeaders(this.corg),
                201
            );
            result = true;
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'createDebugLogServiceFlag'));
        }
        return result;
    }

    public Boolean updateDebugLogServiceFlag(Debug_Log_Service_Flag__c flag, Connected_Org__c corg) {
        Boolean result = false;
        try {
            String externalId = flag.Id;
            // The Id field should not be specified in the sobject data.
            flag.Id = null;
            String b = HttpUtils.post(
                corg.Instance_Url__c + ConfigUtil.DESCRIBE_SOBJECT_PATH + Schema.sObjectType.Debug_Log_Service_Flag__c.Name + '/' + externalId + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
                JSON.serialize(flag),
                getToolingHeaders(this.corg),
                204
            );
            result = true;
        }
        catch(Exception e) {
            loggerInstance?.add(loggerInstance.getInternalError(e, null, TraceService.class.getName(), 'updateDebugLogServiceFlag'));
        }
        return result;
    }

    public void upsertLocalFlag(Datetime lastProcessedDateTime, Connected_Org__c corg) {
        List<ApexLog> logs = getLastCreatedApexLogs(corg);
        Debug_Log_Service_Flag__c flag = Debug_Log_Service_Flag__c.getOrgDefaults();
        flag.Last_Processed_Log__c = lastProcessedDateTime;
        if(!logs.isEmpty()) {
            if(logs.get(0)?.StartTime != null) {
                flag.Last_Created_Log__c = logs.get(0)?.StartTime;
            }
        }
        DatabaseUtils.getInstance().performUpsertDML(new List<Debug_Log_Service_Flag__c>{flag}, Schema.SObjectType.Debug_Log_Service_Flag__c)
                .handleError(TraceService.class.getName(), '.upsertLocalFlag', loggerInstance);
    }

    public void updateLastCreatedLogFlag(Connected_Org__c corg) {
        List<ApexLog> logs = getLastCreatedApexLogs(corg);
        List<Debug_Log_Service_Flag__c> flags = getDebugLogServiceFlag(corg);
        if(flags.isEmpty()) {
            Debug_Log_Service_Flag__c newFlag = new Debug_Log_Service_Flag__c(SetupOwnerId = corg.Name);
            if(!logs.isEmpty()) {
                if(logs.get(0)?.StartTime != null) {
                    newFlag.Last_Created_Log__c = logs.get(0)?.StartTime;
                }
            }
            createDebugLogServiceFlag(newFlag, corg);
        }
        else if(!logs.isEmpty() && !flags.isEmpty()) {
            Debug_Log_Service_Flag__c flag = flags.get(0);
            DateTime lastCreatedLogDateTime = logs.get(0).StartTime;
            if(lastCreatedLogDateTime != null) {
                flag.Last_Created_Log__c = lastCreatedLogDateTime;
                updateDebugLogServiceFlag(flag, corg);
            }
        }
    }

    public static List<ApexLog> getDebugApexLogsForDelete(Connected_Org__c corg, Integer scope) {
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'Id','StartTime'})
            .add(QBuilder.orderBy('StartTime').ascending())
            .addLimit(scope)
            .build();
        return (List<ApexLog>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<ApexLog>.class);
    }

    public static List<ApexLog> getLastCreatedApexLogs(Connected_Org__c corg) {
        String query = new QBuilder(ApexLog.SObjectType)
            .selectFields(new Set<String>{'Id','StartTime'})
            .add(QBuilder.orderBy('StartTime').descending())
            .addLimit(1)
            .build();
        return (List<ApexLog>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<ApexLog>.class);
    }

    public static List<Debug_Log_Service_Flag__c> getDebugLogServiceFlag(Connected_Org__c corg) {
        String query = new QBuilder(Debug_Log_Service_Flag__c.SObjectType)
            .selectFields(new Set<String>{Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Created_Log__c.Name, Schema.sObjectType.Debug_Log_Service_Flag__c.fields.Last_Processed_Log__c.Name})
            .add(QBuilder.condition('SetupOwnerId').equalsTo(corg.Name))
            .build();
        return (List<Debug_Log_Service_Flag__c>)JSON.deserialize(JSON.serialize(runQuery(corg, query)), List<Debug_Log_Service_Flag__c>.class);
    }

    public static Boolean hasNewLogs(Connected_Org__c corg) {
        Debug_Log_Service_Flag__c flag = getDebugLogServiceFlag(corg).get(0);
        if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c == null) {
            return true;
        } else if (flag.Last_Created_Log__c != null && flag.Last_Processed_Log__c != null) {
            return flag.Last_Created_Log__c > flag.Last_Processed_Log__c;
        }
        return false;
    }

    public List<Database.SaveResult> inactivateTraceRequests() {
        Datetime dtNow = Datetime.now();
        List<Trace_Request__c> traceRequests = [
            SELECT Id, Status__c, End_Date__c 
            FROM Trace_Request__c 
            WHERE End_Date__c < :dtNow
                AND Status__c = :TRACE_REQUEST_STATUS_IN_PROGRESS
        ];
        for (Trace_Request__c tr : traceRequests) {
            tr.Status__c = TRACE_REQUEST_STATUS_INACTIVE;
        }
        return DatabaseUtils.getInstance().performUpdateDML(traceRequests, Schema.SObjectType.Trace_Request__c)
                .handleError(TraceService.class.getName(), '.inactivateTraceRequests', loggerInstance).saveResults;
    }

    public static void setInactiveStatus(List<Trace_Request__c> traceRequests, Map<Id, Trace_Request__c> oldMap) {
        Set<String> scheduleIds = new Set<String>();
        Set<String> inactiveScheduleIds = new Set<String>();

        for(Trace_Request__c tr : traceRequests) {
            Trace_Request__c oldTr = oldMap.get(tr.Id);
            scheduleIds.add(tr.Trace_Schedule__c);
        }

        if(!scheduleIds.isEmpty()) {
            List<Trace_Schedule__c> inactiveTraceSchedulers = [
                SELECT Id
                FROM Trace_Schedule__c
                WHERE Id IN :scheduleIds
                    AND Status__c =:TRACE_SCHEDULE_STATUS_INACTIVE
            ];
            if(!inactiveTraceSchedulers.isEmpty()) {
                inactiveScheduleIds = (new Map<String, Trace_Schedule__c>(inactiveTraceSchedulers)).keySet();
            }
        }

        for(Trace_Request__c tr : traceRequests) {
            Trace_Request__c oldTr = oldMap.get(tr.Id);

            // rollback status to inactive
            if(inactiveScheduleIds.contains(tr.Trace_Schedule__c) || (tr.Status__c != oldTr.Status__c && oldTr.Status__c == TRACE_REQUEST_STATUS_INACTIVE)) {
                tr.Status__c = TRACE_REQUEST_STATUS_INACTIVE;
            }
        }
    }

    public static void setChildrenInactiveStatus(List<Trace_Schedule__c> traceSchedules, Map<Id, Trace_Schedule__c> oldMap) {
        List<String> scheduleIds = new List<String>();

        for (Trace_Schedule__c tr : traceSchedules) {
            Trace_Schedule__c oldTr = oldMap.get(tr.Id);
            if (tr.Status__c != oldTr.Status__c && tr.Status__c == TRACE_SCHEDULE_STATUS_INACTIVE) {
                scheduleIds.add(tr.Id);
            }
            // rollback status to inactive
            if (tr.Status__c != oldTr.Status__c && oldTr.Status__c == TRACE_SCHEDULE_STATUS_INACTIVE) {
                tr.Status__c = TRACE_SCHEDULE_STATUS_INACTIVE;
            }
        }

        if (!scheduleIds.isEmpty()) {
            List<Trace_Request__c> requestsToInactivate = [
                SELECT Id, Status__c
                FROM Trace_Request__c
                WHERE Trace_Schedule__c IN :scheduleIds
                    AND Status__c != :TRACE_REQUEST_STATUS_INACTIVE
            ];
            for (Trace_Request__c tr : requestsToInactivate) {
                tr.Status__c = TRACE_REQUEST_STATUS_INACTIVE;
            }

            if (!requestsToInactivate.isEmpty()) {
                DatabaseUtils.getInstance().performUpdateDML(requestsToInactivate, Schema.SObjectType.Trace_Request__c)
                        .handleError(TraceService.class.getName(), '.setChildrenInactiveStatus');
            }
        }
    }

    public static void populateDefaults(List<Trace_Request__c> traceRequests) {
        DebugLevel defaultDebugLevel = createDefaultDebugLevel();
        for(Trace_Request__c tr : traceRequests) {
            if(tr.Apex_Code__c == null) tr.Apex_Code__c = defaultDebugLevel.ApexCode.name();
            if(tr.Apex_Profiling__c == null) tr.Apex_Profiling__c = defaultDebugLevel.ApexProfiling.name();
            if(tr.Callout__c == null) tr.Callout__c = defaultDebugLevel.Callout.name();
            if(tr.Database__c == null) tr.Database__c = defaultDebugLevel.Database.name();
            if(tr.System__c == null) tr.System__c = defaultDebugLevel.System_x.name();
            if(tr.Validation__c == null) tr.Validation__c = defaultDebugLevel.Validation.name();
            if(tr.Visualforce__c == null) tr.Visualforce__c = defaultDebugLevel.Visualforce.name();
            if(tr.Workflow__c == null) tr.Workflow__c = defaultDebugLevel.Workflow.name();
        }
    }

    public static void populateLookups(List<Trace_Request__c> traceRequests, Map<Id, Trace_Request__c> oldMap) {
        List<Trace_Request__c> result = new List<Trace_Request__c>();
        for(Trace_Request__c tr : traceRequests) {
            Trace_Request__c oldTr = oldMap.get(tr.Id);

            if((tr.Issue__c == null || tr.Issue__c != oldTr.Issue__c)
                || (tr.Status__c != oldTr.Status__c)
                || (tr.End_Date__c != oldTr.End_Date__c)
                || (tr.Start_Date__c != oldTr.Start_Date__c)) {

                result.add(tr);
            }
        }
        if(!result.isEmpty()) {
            populateLookups(result);
        }
    }

    public static void populateLookups(List<Trace_Request__c> traceRequests) {
        Set<String> traceScheduleIds = new Set<String>();
        Map<Id, Trace_Request__c> traceRequestsForUpdate = new Map<Id, Trace_Request__c>();
        Map<Id, Trace_Schedule__c> traceSchedulersForUpdate = new Map<Id, Trace_Schedule__c>();
        List<Trace_Schedule__c> traceSchedulersStatusUpdate = new List<Trace_Schedule__c>();

        for(Trace_Request__c tr : traceRequests) {
            traceScheduleIds.add(tr.Trace_Schedule__c);
        }

        if(!traceScheduleIds.isEmpty()) {
            Map<String, Trace_Schedule__c> mapTraceSchedule = new Map<String, Trace_Schedule__c>([
                SELECT Id, Issue__c, Status__c, Trace_End_Date__c, Trace_Start_Date__c
                FROM Trace_Schedule__c
                WHERE Id IN :traceScheduleIds
            ]);

            // populate Issue
            for(Trace_Request__c tr : traceRequests) {
                Trace_Schedule__c parentSchedule = mapTraceSchedule.get(tr.Trace_Schedule__c);
                String scheduleIssueId = parentSchedule?.Issue__c;
                if(tr.Issue__c == null && scheduleIssueId != null) {
                    traceRequestsForUpdate.put(tr.Id, new Trace_Request__c(Id = tr.Id, Issue__c = scheduleIssueId));
                }
            }

            List<AggregateResult> aggrSchedulers = [
                SELECT MIN(Start_Date__c) minStartDate, MAX(End_Date__c) maxEndDate, Trace_Schedule__c scheduleId
                FROM Trace_Request__c
                WHERE Trace_Schedule__c IN :traceScheduleIds
                GROUP BY Trace_Schedule__c
            ];

            Set<String> traceSchedulersWithRequests = new Set<String>();
            for(AggregateResult agr : aggrSchedulers) {
                String scheduleId = String.valueOf(agr.get('scheduleId'));
                DateTime minStartDate = (DateTime)agr.get('minStartDate');
                DateTime maxEndDate = (DateTime)agr.get('maxEndDate');

                if(String.isNotBlank(scheduleId)) {
                    traceSchedulersWithRequests.add(scheduleId);
                    Trace_Schedule__c traceSchedule = mapTraceSchedule.get(scheduleId);
                    if(traceSchedule != null) {
                        if(traceSchedule.Trace_Start_Date__c == null || minStartDate != traceSchedule.Trace_Start_Date__c) {
                            traceSchedule.Trace_Start_Date__c = minStartDate;
                            traceSchedulersForUpdate.put(traceSchedule.Id, traceSchedule);
                        }
                        if(traceSchedule.Trace_End_Date__c == null || maxEndDate != traceSchedule.Trace_End_Date__c) {
                            traceSchedule = (traceSchedulersForUpdate.containsKey(traceSchedule.Id))
                                ? traceSchedulersForUpdate.get(traceSchedule.Id)
                                : traceSchedule;
                            traceSchedule.Trace_End_Date__c = maxEndDate;
                            traceSchedulersForUpdate.put(traceSchedule.Id, traceSchedule);
                        }
                    }
                }
            }

            for(String scheduleId : traceScheduleIds) {
                if(!traceSchedulersWithRequests.contains(scheduleId)) {
                    traceSchedulersForUpdate.put(scheduleId, new Trace_Schedule__c(Id = scheduleId, Status__c = null, Trace_Start_Date__c = null, Trace_End_Date__c = null));
                }
            }
        }

        if (!traceSchedulersForUpdate.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(traceSchedulersForUpdate.values(), Schema.SObjectType.Trace_Schedule__c)
                    .handleError(TraceService.class.getName(), '.populateLookups');
        }
        if (!traceRequestsForUpdate.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(traceRequestsForUpdate.values(), Schema.SObjectType.Trace_Request__c)
                    .handleError(TraceService.class.getName(), '.populateLookups');
        }

        if(!traceScheduleIds.isEmpty()) {
            DateTime dtNow = DateTime.now();
            Set<Id> statusScheduled = new Set<Id>();
            Set<Id> statusInProgerss = new Set<Id>();
            Set<Id> statusCompleted = new Set<Id>();

            List<AggregateResult> traceRequestScheduled = [
                SELECT Trace_Schedule__c scheduleId
                FROM Trace_Request__c
                WHERE Trace_Schedule__c IN :traceScheduleIds
                    AND Start_Date__c > :dtNow
                GROUP BY Trace_Schedule__c
            ];
            for(AggregateResult agr : traceRequestScheduled) {
                String scheduleId = String.valueOf(agr.get('scheduleId'));
                statusScheduled.add(scheduleId);
            }

            List<AggregateResult> traceRequestInProgerss = [
                SELECT Trace_Schedule__c scheduleId
                FROM Trace_Request__c
                WHERE Trace_Schedule__c IN :traceScheduleIds
                    AND Status__c = :TRACE_REQUEST_STATUS_IN_PROGRESS
                GROUP BY Trace_Schedule__c
            ];
            for(AggregateResult agr : traceRequestInProgerss) {
                String scheduleId = String.valueOf(agr.get('scheduleId'));
                statusInProgerss.add(scheduleId);
            }

            List<AggregateResult> traceRequestCompleted = [
                SELECT Id scheduleId
                FROM Trace_Schedule__c
                WHERE Id IN :traceScheduleIds
                    AND Trace_End_Date__c < :dtNow
                GROUP BY Id
            ];
            for(AggregateResult agr : traceRequestCompleted) {
                String scheduleId = String.valueOf(agr.get('scheduleId'));
                statusCompleted.add(scheduleId);
            }

            for(String traceScheduleId : traceScheduleIds) {
                if(statusScheduled.contains(traceScheduleId)) {
                    traceSchedulersStatusUpdate.add(new Trace_Schedule__c(
                        Id = traceScheduleId,
                        Status__c = TRACE_SCHEDULE_STATUS_SCHEDULED
                    ));
                }
                else if(statusCompleted.contains(traceScheduleId)) {
                    traceSchedulersStatusUpdate.add(new Trace_Schedule__c(
                        Id = traceScheduleId,
                        Status__c = TRACE_SCHEDULE_STATUS_COMPLETED
                    ));
                }
                else if(statusInProgerss.contains(traceScheduleId)) {
                    traceSchedulersStatusUpdate.add(new Trace_Schedule__c(
                        Id = traceScheduleId,
                        Status__c = TRACE_SCHEDULE_STATUS_IN_PROGRESS
                    ));
                }
                else {
                    traceSchedulersStatusUpdate.add(new Trace_Schedule__c(
                        Id = traceScheduleId,
                        Status__c = null
                    ));
                }
            }
        }
        if (!traceSchedulersStatusUpdate.isEmpty()) {
            DatabaseUtils.getInstance().performUpdateDML(traceSchedulersStatusUpdate, Schema.SObjectType.Trace_Schedule__c)
                    .handleError(TraceService.class.getName(), '.populateLookups');
        }
    }

    public static void startTraceRequests(List<Trace_Request__c> traceRequests, Map<Id, Trace_Request__c> oldMap) {
        List<Trace_Request__c> result = new List<Trace_Request__c>();
        Boolean needRunBatch = false;
        for(Trace_Request__c tr : traceRequests) {
            Trace_Request__c oldTr = oldMap != null ? oldMap.get(tr.Id) : null;

            if(oldTr == null 
                && tr.Status__c == TRACE_REQUEST_STATUS_NEW 
                && tr.Start_Date__c != null
                && tr.End_Date__c != null
                && tr.Traced_Entity_Id__c != null) {
                
                needRunBatch = true;
                break;
            }
            else if(oldTr != null
                && tr.Status__c == TRACE_REQUEST_STATUS_NEW
                && (tr.Start_Date__c != oldTr.Start_Date__c
                    || tr.End_Date__c != oldTr.End_Date__c
                    || tr.Traced_Entity_Id__c != oldTr.Traced_Entity_Id__c)) {

                needRunBatch = true;
                break;
            }
        }
        if(needRunBatch) {
            QueueableJobChain chain = new QueueableJobChain();
            chain.chainFirst(new StartTraceServiceBatchQueueable(chain));
            chain.runNext();
        }
    }

    public class StartTraceServiceBatchQueueable extends ChainedQueuable implements Database.AllowsCallouts {
        
        public StartTraceServiceBatchQueueable(QueueableJobChain chain) {
            super(chain);
        }
        public override void execute(QueueableContext context) {
            try {
                checkTraceServiceRun();
            }
            catch (Exception e) {
                Logger.getInstance().internalError(e, null, true, TraceService.class.getName(), 'StartTraceServiceBatchQueueable');
            }
            finally {
                if(chain.hasNext()) {
                    super.execute(context);
                }
            }
        }
    }
}