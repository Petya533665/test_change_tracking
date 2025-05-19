public with sharing class TraceRetentionBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<TraceRetentionRunWrapper>,Database.Stateful, Database.AllowsCallouts, Schedulable, Database.RaisesPlatformEvents {

	public void execute(SchedulableContext sc) {
		LogServiceScheduler.rescheduleCronTriggers();
	}

    private TraceService traceServiceInst;
    private TraceService.OrganizationStorageHelper storageHelper;

	private static TraceRetentionBatch instance = null;

	public static TraceRetentionBatch getInstance(TraceService.OrganizationStorageHelper helper) {
		if (instance == null) {
			instance = new TraceRetentionBatch(helper, Logger.getInstance());
		}
		return instance;
	}

    private TraceRetentionBatch(TraceService.OrganizationStorageHelper helper, Logger logger) {
	    super(logger);
        this.traceServiceInst = TraceService.getInstance();
        this.storageHelper = helper;
	    BATCH_SCOPE = 200;
    }

	public override void startBatch() {
		DatabaseUtils.executeBatchWithLimitCheck('TraceRetentionBatch', this);
	}

	public override Boolean initialValidation() {
		return ConfigUtil.DEBUG_LOG_SERVICE_SETTINGS?.Enabled__c && PermissionsUtil.DebugLogServiceEnabled;
	}

	public override Integer getIterationsCount() {
		return storageHelper.totalRetentionRuns;
	}

    public enum TraceRetentionRunType {DELETE_APEX_LOGS}
    
    public class TraceRetentionRunWrapper {
		public TraceRetentionRunType type;
        public String sourceId;

		public TraceRetentionRunWrapper(TraceRetentionRunType type, String sourceId) {
			this.type = type;
            this.sourceId = sourceId;
		}
	}

    public class TraceRetentionRunIterable implements Iterable<TraceRetentionRunWrapper> {

		private List<TraceRetentionRunWrapper> traceRetentionRuns;

		public TraceRetentionRunIterable() {
			this.traceRetentionRuns = new List<TraceRetentionRunWrapper>();
		}

		public TraceRetentionRunIterable(List<TraceRetentionRunWrapper> traceRetentionRuns) {
			this.traceRetentionRuns = traceRetentionRuns;
		}

		public Iterator<TraceRetentionRunWrapper> iterator() {
			return new TraceRetentionRunIterator(this.traceRetentionRuns);
		}
	}

	public class TraceRetentionRunIterator implements Iterator<TraceRetentionRunWrapper> {
		private List<TraceRetentionRunWrapper> traceRetentionRuns;
		private Integer index;

		public TraceRetentionRunIterator(List<TraceRetentionRunWrapper> defaults) {
			this.traceRetentionRuns = defaults == null ? new List<TraceRetentionRunWrapper>() : defaults;
			this.index = 0;
		}

		public TraceRetentionRunIterator() {
			this(new List<TraceRetentionRunWrapper>());
		}

		public Boolean hasNext() {
			return this.index < traceRetentionRuns.size() ? true : false;
		}

		public TraceRetentionRunWrapper next() {
			return this.traceRetentionRuns[this.index++];
		}
	}

    public static List<TraceRetentionRunWrapper> getTraceRetentionRuns(TraceService.OrganizationStorageHelper helper) {
		List<TraceRetentionRunWrapper> result = new List<TraceRetentionRunWrapper>();
    
        for(String sourceId : helper.sourcesForRetentionRun) {
            for(Integer runsPerOrg = 0; runsPerOrg < helper.mapRetentionRuns.get(sourceId); runsPerOrg++) {
                result.add(new TraceRetentionRunWrapper(TraceRetentionBatch.TraceRetentionRunType.DELETE_APEX_LOGS, sourceId));
            }
        }
        return result;
    }


    public Iterable<TraceRetentionRunWrapper> start(Database.BatchableContext batchableContext) {
		TraceRetentionRunIterable iterable = new TraceRetentionRunIterable(getTraceRetentionRuns(this.storageHelper));
		return iterable;
	}

    public void execute(Database.BatchableContext batchableContext, List<TraceRetentionRunWrapper> scope) {
        TraceRetentionRunWrapper runInstance = (TraceRetentionRunWrapper)scope.get(0);
        if(runInstance.type == TraceRetentionBatch.TraceRetentionRunType.DELETE_APEX_LOGS) {
            try {
                Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(runInstance.sourceId);
                this.traceServiceInst.setConnectedOrgById(runInstance.sourceId);
                List<ApexLog> logs = TraceService.getDebugApexLogsForDelete(corg, BATCH_SCOPE);
                if(!logs.isEmpty()) {
                    Set<Id> logIds = (new Map<Id, ApexLog>(logs)).keySet();
                    List<Database.DeleteResult> deleteResults = this.traceServiceInst.deleteDebugLogs(logIds);
                }
            }
            catch(Exception e) {
                this.traceServiceInst?.loggerInstance?.add(this.traceServiceInst.loggerInstance.getInternalError(e, runInstance.sourceId, TraceRetentionBatch.class.getName(), 'execute.deleteDebugLogs'));
            }
        }
    }

	public void finish(Database.BatchableContext batchableContext) {
		this.traceServiceInst?.loggerInstance?.flush();
        if(!Test.isRunningTest()) {
            TraceService.checkTraceServiceRun();
        }
	}
}