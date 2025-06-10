public class EventLogProcessingBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<EventLogFileType>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, Schedulable  {

    private Logger logger;
    private Datetime lastProcessedHourlyDateTime;
    private Boolean isEnabled;

    /**
     * Constructor for the EventLogProcessingBatch
     * @param logger Logger
     */
    private EventLogProcessingBatch(Logger logger) {
        this.logger = logger;
        this.lastProcessedHourlyDateTime = ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c;
        this.isEnabled = ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c;
    }

    /**
     * Singleton instance of the EventLogProcessingBatch
     */
    private static EventLogProcessingBatch instance = null;

    /**
     * Get the singleton instance of the EventLogProcessingBatch
     * @return EventLogProcessingBatch
     */
    public static EventLogProcessingBatch getInstance() {
        if (instance == null) {
            instance = new EventLogProcessingBatch(Logger.getInstance());
        }
        return instance;
    }

    /**
     * Class to represent an event type, where type is the event type name
     */
    public class EventLogFileType {
		public String type;

		public EventLogFileType(String type) {
			this.type = type;
		}
	}

    /**
     * Iterable for the event types in batchable start method
     */ 
    public class EventLogFileTypeIterable implements Iterable<EventLogFileType> {

		private List<EventLogFileType> enabledMembers;

		public EventLogFileTypeIterable() {
			this.enabledMembers = new List<EventLogFileType>();
		}

		public EventLogFileTypeIterable(List<EventLogFileType> enabledMembers) {
			this.enabledMembers = enabledMembers;
		}

		public Iterator<EventLogFileType> iterator() {
			return new EventLogFileTypeIterator(this.enabledMembers);
		}
	}

    /**
     * Iterator for the event types in batchable start method
     */
    public class EventLogFileTypeIterator implements Iterator<EventLogFileType> {
		private List<EventLogFileType> enabledMembers;
		private Integer index;

		public EventLogFileTypeIterator(List<EventLogFileType> enabledMembers) {
			this.enabledMembers = enabledMembers == null ? new List<EventLogFileType>() : enabledMembers;
			this.index = 0;
		}

		public EventLogFileTypeIterator() {
			this(new List<EventLogFileType>());
		}

		public Boolean hasNext() {
			return this.index < enabledMembers.size() ? true : false;
		}

		public EventLogFileType next() {
			return this.enabledMembers[this.index++];
		}
	}

    /**
     * Start the batch from LogsServiceScheduler manager
     */
    public override void startBatch() {
        DatabaseUtils.executeBatchWithLimitCheck('EventLogProcessingBatch', this);
    }

    /**
     * Initial validation for the batch
     * @return Boolean
     */

    public override Boolean initialValidation() {
        return PermissionsUtil.EventMonitoringEnabled && this.isEnabled && this.lastProcessedHourlyDateTime != null;
    }

    /**
     * Get the number of iterations for the batch, which is the number of enabled event types
     * @return Integer
     */
    public override Integer getIterationsCount() {
        return EventMonitoringUtil.getEnabledMembers()?.size();
    }

    /**
     * Get the event logs for the batch
     * @param enabledMembers List<EventLogFileType>
     * @return List<EventLogFile>
     */
    private List<EventLogFile> getEventLogs(List<EventLogFileType> enabledMembers) {
        if (enabledMembers == null || enabledMembers.isEmpty()) {
            return new List<EventLogFile>();
        }
        String eventType = enabledMembers[0].type;
        return EventMonitoringUtil.getEventLogs(eventType);
    }

    /**
     * Start the batch uses iterator to get the enabled event types
     * @param batchableContext Database.BatchableContext
     * @return Iterable<EventLogFileType>
     */
    public Iterable<EventLogFileType> start(Database.BatchableContext batchableContext) {
		EventLogFileTypeIterable iterable = new EventLogFileTypeIterable(EventMonitoringUtil.getEnabledMembers());
		return iterable;
	}

    /**
     * Execute the batch from LogsServiceScheduler manager
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        LogServiceScheduler.rescheduleCronTriggers();
    }
    
    /**
     * Execute the batch, which is the main logic for the batch
     * process the event logs and detect anomalies then create logs
     * @param BC Database.BatchableContext
     * @param scope List<EventLogFileType>
     */
    public void execute(Database.BatchableContext BC, List<EventLogFileType> scope) {
        List<EventLogFile> eventLogs = getEventLogs(scope);
        
        for (EventLogFile logFile : eventLogs) {
            try {
                // Create a processor for the log file
                EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(logFile.EventType);

                // Create a detector for the event type
                AnomalyDetectors.IAnomalyDetector detector = AnomalyDetectors.createDetector(logFile.EventType);

                // Process the log file in batches
                EventLogProcessors.BatchEventDataProcessor batchProcessor = new EventLogProcessors.BatchEventDataProcessor(detector, this.logger);
                
                // Process the log file with batch callback
                processor.batchProcessLogFile(logFile, batchProcessor);
            }
            catch (Exception e) {
                this.logger.add(this.logger.getInternalError(e, logFile.Id, EventLogProcessingBatch.class.getName(), 'Error processing log file'));
            }
        }

        // kick off the logger flush
        this.logger.flush();
    }

    public void finish(Database.BatchableContext BC) {
        // after all event logs are processed, save the incremented by 1 hour
        // last processed hourly datetime
        EventMonitoringUtil.saveLastProcessedHourlyDateTime(this.lastProcessedHourlyDateTime);
    }
}