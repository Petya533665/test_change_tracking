public class EventLogProcessingBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<EventLogFileType>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents, Schedulable  {
    
    // Configurable settings for enhanced deduplication
    public class EnhancedDeduplicationSettings {
        public Boolean enableEmailEventDeduplication = true;
        public Integer timingToleranceSeconds = 1;
        public Boolean preserveAllEventLogs = true;
        public Set<String> eventTypesToCheck = EventLogProcessors.EVENT_TYPES_TO_CHECK_DUPLICATES;
        
        // New chunking settings
        public Integer baseChunkSize = 1000;
        public Integer maxChunkSize = 5000;
        public Double smallFileThresholdBytes = 102400.0; // 100 KB
        public Double mediumFileThresholdBytes = 512000.0; // 500 KB
        public Double largeFileThresholdBytes = 2048000.0; // 2 MB
        public Double recordsPerKB = 10.0; // Estimated records per KB
    }
    
    // Instance of deduplication settings
    private EnhancedDeduplicationSettings dedupSettings = new EnhancedDeduplicationSettings();

    private Logger logger;
    private Datetime lastProcessedHourlyDateTime;
    private Boolean isEnabled;
    
    /**
     * Allow external configuration of deduplication settings
     * @param settings Custom deduplication settings
     */
    public void configureDeduplication(EnhancedDeduplicationSettings settings) {
        if (settings != null) {
            this.dedupSettings = settings;
        }
    }

    /**
     * Constructor for the EventLogProcessingBatch
     * @param logger Logger
     */
    private EventLogProcessingBatch(Logger logger) {
        this.logger = logger;
        this.lastProcessedHourlyDateTime = ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c;
        this.isEnabled = PermissionsUtil.EventMonitoringEnabled && ConfigUtil.EVENT_MONITORING_SETTINGS.Enabled__c;
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
     * Class to represent an event type with chunking information
     */
    public class EventLogFileType {
		public String type;
		public String logFileId;
		public Double logFileLengthBytes;
		public Integer estimatedRecordCount;
		public Integer chunkSize;
		public Integer startRow;
		public Integer endRow;

		public EventLogFileType(String type) {
			this.type = type;
		}
		
		public EventLogFileType(String type, String logFileId, Double logFileLengthBytes) {
			this.type = type;
			this.logFileId = logFileId;
			this.logFileLengthBytes = logFileLengthBytes;
			this.estimatedRecordCount = this.calculateEstimatedRecordCount(logFileLengthBytes);
			this.chunkSize = this.calculateOptimalChunkSize(logFileLengthBytes);
			this.startRow = 0;
			this.endRow = this.chunkSize;
		}
		
		/**
		 * Calculate optimal chunk size based on file size
		 */
		public Integer calculateOptimalChunkSize(Double fileSizeBytes) {
			// Convert bytes to KB for easier calculations
			Double fileSizeKB = fileSizeBytes / 1024.0;
			
			// Adjust based on file size
			if (fileSizeKB <= 100) {
				return 500; // Small files: smaller chunks
			} else if (fileSizeKB <= 500) {
				return 1000; // Medium files: standard chunks
			} else if (fileSizeKB <= 2000) {
				return 2000; // Large files: larger chunks
			} else {
				return 5000; // Very large files: maximum chunks
			}
		}
		
		/**
		 * Calculate estimated record count based on file size
		 */
		public Integer calculateEstimatedRecordCount(Double fileSizeBytes) {
			// Convert bytes to KB for easier calculations
			Double fileSizeKB = fileSizeBytes / 1024.0;
			
			// Rough estimation: 1KB ≈ 10-20 records (depending on field count)
			// Conservative estimate: 1KB = 10 records
			return Integer.valueOf(Math.round(fileSizeKB * 10));
		}
	}

    /**
     * Iterable for the event types in batchable start method with chunking support
     */ 
    public class EventLogFileTypeIterable implements Iterable<EventLogFileType> {

		private List<EventLogFileType> chunkedMembers;

		public EventLogFileTypeIterable() {
			this.chunkedMembers = new List<EventLogFileType>();
		}

		public EventLogFileTypeIterable(List<EventLogFileType> enabledMembers) {
			this.chunkedMembers = createChunkedMembers(enabledMembers);
		}
		
		private List<EventLogFileType> createChunkedMembers(List<EventLogFileType> members) {
			List<EventLogFileType> chunked = new List<EventLogFileType>();
			
			if (members == null || members.isEmpty()) {
				return chunked;
			}
			
			// Extract all event types for bulk query
			List<String> eventTypes = new List<String>();
			for (EventLogFileType member : members) {
				eventTypes.add(member.type);
			}
			
			// Bulk query all event logs for all event types
			List<SObject> allEventLogs = EventMonitoringUtil.getEventLogs(eventTypes);
			
			// Group event logs by event type for efficient processing
			Map<String, List<SObject>> eventLogsByType = new Map<String, List<SObject>>();
			for (SObject logFile : allEventLogs) {
				String eventType = EventMonitoringUtil.getStringValue(logFile, EventMonitoringUtil.EVENT_LOG_FILE_EVENT_TYPE);
				if (String.isNotBlank(eventType)) {
					if (!eventLogsByType.containsKey(eventType)) {
						eventLogsByType.put(eventType, new List<SObject>());
					}
					eventLogsByType.get(eventType).add(logFile);
				}
			}
			
			// Process each member and create chunks
			for (EventLogFileType member : members) {
				List<SObject> eventLogs = eventLogsByType.get(member.type);
				if (eventLogs != null) {
					for (SObject logFile : eventLogs) {
						Double fileSizeBytes = EventMonitoringUtil.getDoubleValue(
							logFile, 
							EventMonitoringUtil.EVENT_LOG_FILE_LOG_FILE_LENGTH
						);
						
						if (fileSizeBytes != null && fileSizeBytes > 0) { 
							// Create chunks based on file size
							List<EventLogFileType> fileChunks = createFileChunks(
								member.type, 
								logFile, 
								fileSizeBytes
							);
							chunked.addAll(fileChunks);
						} else {
							// Fallback to original behavior for files without size info
							chunked.add(member);
						}
					}
				} else {
					// No event logs found for this type, add the member as is
					chunked.add(member);
				}
			}
			
			return chunked;
		}

		public Iterator<EventLogFileType> iterator() {
			return new EventLogFileTypeIterator(this.chunkedMembers);
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
        return EventMonitoringUtil.isEventLogFileAvailable() 
            && PermissionsUtil.EventMonitoringEnabled 
            && this.isEnabled 
            && this.lastProcessedHourlyDateTime != null;
    }

    /**
     * Get the number of iterations for the batch, which is the number of chunks
     * @return Integer
     */
    public override Integer getIterationsCount() {
        // Create a temporary iterable to count chunks
        EventLogFileTypeIterable tempIterable = new EventLogFileTypeIterable(EventMonitoringUtil.getEnabledMembers());
        Integer count = 0;
        for (EventLogFileType chunk : tempIterable) {
            count++;
        }
        return count;
    }

    /**
     * Get the event logs for the batch
     * @param enabledMembers List<EventLogFileType>
     * @return List<SObject>
     */
    private List<SObject> getEventLogs(List<EventLogFileType> enabledMembers) {
        if (enabledMembers == null || enabledMembers.isEmpty()) {
            return new List<SObject>();
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
        for (EventLogFileType chunk : scope) {
            try {
                // Each chunk is processed individually in its own batch iteration
                String eventType = chunk.type;
                
                // Get event logs for this specific event type
                List<SObject> eventLogs = EventMonitoringUtil.getEventLogs(eventType);
                
                // Find the specific log file by ID
                SObject logFile = null;
                for (SObject log : eventLogs) {
                    String logId = EventMonitoringUtil.getStringValue(log, EventMonitoringUtil.EVENT_LOG_FILE_ID);
                    if (logId == chunk.logFileId) {
                        logFile = log;
                        break;
                    }
                }
                
                if (logFile == null) continue;
                
                // Create processor and event processor for this chunk  
                EventLogProcessors.EventLogProcessor processor = EventLogProcessors.createProcessor(eventType);
                EventMonitoringProcessors.IEventLogProcessor eventProcessor = EventMonitoringProcessors.createProcessor(eventType);
                EventLogProcessors.BatchEventDataProcessor batchProcessor = 
                    new EventLogProcessors.BatchEventDataProcessor(eventProcessor, this.logger);
                
                // Process the specific chunk with start and end row boundaries
                processor.batchProcessLogFileSObject(logFile, batchProcessor, chunk.startRow, chunk.endRow);
                
                // Process deduplication for this chunk
                processEnhancedDeduplication(eventType);
                
            } catch (Exception e) {
                this.logger.add(this.logger.getInternalError(e, chunk?.logFileId, EventLogProcessingBatch.class.getName(), 'Error processing log file chunk'));
            }
        }

        // kick off the logger flush
        this.logger.flush();
    }

    /**
     * Create file chunks based on file size
     * @param eventType The event type
     * @param logFile The log file SObject
     * @param fileSizeBytes The file size in bytes
     * @return List<EventLogFileType> List of chunks
     */
    private static List<EventLogFileType> createFileChunks(
        String eventType, 
        SObject logFile, 
        Double fileSizeBytes
    ) {
        List<EventLogFileType> chunks = new List<EventLogFileType>();
        String logFileId = EventMonitoringUtil.getStringValue(
            logFile, 
            EventMonitoringUtil.EVENT_LOG_FILE_ID
        );
        
        // Create a temporary instance to calculate chunk sizes
        EventLogFileType tempChunk = new EventLogFileType(eventType, logFileId, fileSizeBytes);
        Integer chunkSize = tempChunk.chunkSize;
        Integer estimatedRecords = tempChunk.estimatedRecordCount;
        Integer totalChunks = Integer.valueOf(Math.ceil(Double.valueOf(estimatedRecords) / Double.valueOf(chunkSize)));
        
        // Ensure we always have at least 1 chunk
        if (totalChunks <= 0) {
            totalChunks = 1;
        }
        
        for (Integer i = 0; i < totalChunks; i++) {
            EventLogFileType chunk = new EventLogFileType(eventType, logFileId, fileSizeBytes);
            chunk.startRow = i * chunkSize;
            chunk.endRow = Math.min((i + 1) * chunkSize, estimatedRecords);
            chunk.chunkSize = chunk.endRow - chunk.startRow;
            chunks.add(chunk);
        }
        
        return chunks;
    }

    /**
     * Enhanced deduplication with Request_Id population and timing analysis
     * Maintains optimized flow after CSV processing is complete
     * @param eventType The event type being processed
     */
    private void processEnhancedDeduplication(String eventType) {
        try {
            // Only run deduplication for enabled event types
            if (!dedupSettings.enableEmailEventDeduplication || 
                !dedupSettings.eventTypesToCheck.contains(eventType)) {
                return;
            }
            
            // Get all logs from the logger queue (new logs without IDs)
            List<Log__c> allLogs = new List<Log__c>(this.logger.logsQueue);
            
            if (allLogs.isEmpty()) {
                return;
            }
            
            // Convert dedupSettings to Map for EventLogProcessors
            Map<String, Object> dedupSettingsMap = new Map<String, Object>{
                'enableEmailEventDeduplication' => dedupSettings.enableEmailEventDeduplication,
                'timingToleranceSeconds' => dedupSettings.timingToleranceSeconds,
                'preserveAllEventLogs' => dedupSettings.preserveAllEventLogs,
                'eventTypesToCheck' => dedupSettings.eventTypesToCheck
            };
            
            // Apply enhanced deduplication
            List<Log__c> deduplicatedLogs = EventLogProcessors.processEnhancedDeduplication(eventType, dedupSettingsMap, this.logger, allLogs);
            
            // Replace the logger queue with deduplicated logs
            this.logger.logsQueue.clear();
            this.logger.logsQueue.addAll(deduplicatedLogs);
            
        } catch (Exception e) {
            this.logger.add(this.logger.getInternalError(e, null, EventLogProcessingBatch.class.getName(), 'Error processing enhanced deduplication'));
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // after all event logs are processed, save the incremented by 1 hour
        // last processed hourly datetime
        EventMonitoringUtil.saveLastProcessedHourlyDateTime(this.lastProcessedHourlyDateTime);
    }
}