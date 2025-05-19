public with sharing class TraceBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable, Database.RaisesPlatformEvents {

	public void execute(SchedulableContext sc) {
		LogServiceScheduler.rescheduleCronTriggers();
	}

    private TraceService traceServiceInst;
    private Set<String> sources;

	private static TraceBatch instance = null;

	public static TraceBatch getInstance(Set<String> sources) {
		if (instance == null) {
			instance = new TraceBatch(sources, Logger.getInstance());
		}
		return instance;
	}

	private TraceBatch(Set<String> sources, Logger logger){
		super(logger);
		this.traceServiceInst = TraceService.getInstance();
        this.sources = sources;
	}

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('TraceBatch', this);
	}

	public override Boolean initialValidation() {
		return ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS?.Enabled__c && PermissionsUtil.DebugLogServiceEnabled;
	}

	public override Integer getIterationsCount() {
		return [SELECT COUNT() FROM Trace_Request__c WHERE Status__c IN (:TraceService.TRACE_REQUEST_STATUS_NEW, :TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS)];
	}

    public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
            SELECT 
                Id, Status__c, SystemModstamp, Traced_Entity_Id__c, Start_Date__c, End_Date__c,
                Apex_Code__c, Apex_Profiling__c, Callout__c, Database__c, System__c, Validation__c,
                Visualforce__c, Workflow__c, Source__c
            FROM Trace_Request__c
            WHERE Status__c IN (:TraceService.TRACE_REQUEST_STATUS_NEW, :TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS)
                AND Source__c IN :this.sources
		]);
	}

    public void execute(Database.BatchableContext BC, List<Trace_Request__c> scope) {
		try {
            if(!scope.isEmpty()) {
                Trace_Request__c traceRequest = (Trace_Request__c)scope.get(0);
                Boolean checkConsistencyTraceFlag = traceRequest.Status__c == TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS;
			    this.traceServiceInst.processNewTraceFlag(traceRequest, checkConsistencyTraceFlag);
            }
        }
        catch(Exception e) {
            String scopeId = (!scope.isEmpty()) ? scope.get(0)?.Id : null;
            this.traceServiceInst?.loggerInstance?.add(this.traceServiceInst.loggerInstance.getInternalError(e, scopeId, TraceBatch.class.getName(), 'execute.processTraceFlag'));
        }
    }

	public void finish(Database.BatchableContext batchableContext) {
        this.traceServiceInst.inactivateTraceRequests();
		this.traceServiceInst?.loggerInstance?.flush();
	}
}