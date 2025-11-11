public class EventLogProcessors {
    // Test variables 
    // These are used to test the EventLogProcessors class, to help evaluate metrics
    // EventLogFieldNames and EventLogFieldTypes is readonly fields on EvnetLogFile
    // They are not used in production
    @TestVisible
    private static String testEventLogFieldNames;
    @TestVisible
    private static String testEventLogFieldTypes;

    // Exception class
    public class EventProcessingException extends Exception {}

    // Event data interface
    public interface IBaseEventData {
        Object getValue(String metric);
    }

    // Batch processor interface
    public interface IBatchProcessor {
        void processBatchEventDataResults(List<IBaseEventData> batchResults, FieldMetadataConfig fieldMetadataConfig);
    }

    // Event types
    public static final String EVENT_TYPE_API = 'API';
    public static final String EVENT_TYPE_APEX_CALLOUT = 'ApexCallout';
    public static final String EVENT_TYPE_APEX_EXECUTION = 'ApexExecution';
    public static final String EVENT_TYPE_APEX_REST_API = 'ApexRestApi';
    public static final String EVENT_TYPE_APEX_SOAP = 'ApexSoap';
    public static final String EVENT_TYPE_APEX_TRIGGER = 'ApexTrigger';
    public static final String EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION = 'ApexUnexpectedException';
    public static final String EVENT_TYPE_API_TOTAL_USAGE = 'ApiTotalUsage';
    public static final String EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN = 'AsynchronousReportRun';
    public static final String EVENT_TYPE_AURA_REQUEST = 'AuraRequest';
    public static final String EVENT_TYPE_BLOCKED_REDIRECT = 'BlockedRedirect';
    public static final String EVENT_TYPE_BULK_API = 'BulkApi';
    public static final String EVENT_TYPE_BULK_API_REQUEST = 'BulkApiRequest';
    public static final String EVENT_TYPE_BULK_API_2 = 'BulkApi2';
    public static final String EVENT_TYPE_CHANGE_SET_OPERATION = 'ChangeSetOperation';
    public static final String EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT = 'ConcurrentLongRunningApexLimit';
    public static final String EVENT_TYPE_CONSOLE = 'Console';
    public static final String EVENT_TYPE_CONTENT_DISTRIBUTION = 'ContentDistribution';
    public static final String EVENT_TYPE_CONTENT_DOCUMENT_LINK = 'ContentDocumentLink';
    public static final String EVENT_TYPE_CONTENT_TRANSFER = 'ContentTransfer';
    public static final String EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY = 'ContinuationCalloutSummary';
    public static final String EVENT_TYPE_CORS_VIOLATION = 'CorsViolation';
    public static final String EVENT_TYPE_CSP_VIOLATION = 'CspViolation';
    public static final String EVENT_TYPE_DASHBOARD = 'Dashboard';
    public static final String EVENT_TYPE_DATABASE_SAVE = 'DatabaseSave';
    public static final String EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS = 'DocumentAttachmentDownloads';
    public static final String EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT = 'ExternalCustomApexCallout';
    public static final String EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT = 'ExternalCrossOrgCallout';
    public static final String EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT = 'ExternalDataSourceCallout';
    public static final String EVENT_TYPE_EXTERNAL_ODATA_CALLOUT = 'ExternalODataCallout';
    public static final String EVENT_TYPE_FLOW_EXECUTION = 'FlowExecution';
    public static final String EVENT_TYPE_GROUP_MEMBERSHIP = 'GroupMembership';
    public static final String EVENT_TYPE_HOSTNAME_REDIRECTS = 'HostnameRedirects';
    public static final String EVENT_TYPE_INSECURE_EXTERNAL_ASSETS = 'InsecureExternalAssets';
    public static final String EVENT_TYPE_INSUFFICIENT_ACCESS = 'InsufficientAccess';
    public static final String EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW = 'KnowledgeArticleView';
    public static final String EVENT_TYPE_LIGHTNING_ERROR = 'LightningError';
    public static final String EVENT_TYPE_LIGHTNING_INTERACTION = 'LightningInteraction';
    public static final String EVENT_TYPE_LIGHTNING_LOGGER = 'LightningLogger';
    public static final String EVENT_TYPE_LIGHTNING_PAGE_VIEW = 'LightningPageView';
    public static final String EVENT_TYPE_LIGHTNING_PERFORMANCE = 'LightningPerformance';
    public static final String EVENT_TYPE_LOGIN = 'Login';
    public static final String EVENT_TYPE_LOGIN_AS = 'LoginAs';
    public static final String EVENT_TYPE_LOGOUT = 'Logout';
    public static final String EVENT_TYPE_METADATA_API_OPERATION = 'MetadataApiOperation';
    public static final String EVENT_TYPE_MULTIBLOCK_REPORT = 'MultiblockReport';
    public static final String EVENT_TYPE_NAMED_CREDENTIAL = 'NamedCredential';
    public static final String EVENT_TYPE_ONE_COMMERCE_USAGE = 'OneCommerceUsage';
    public static final String EVENT_TYPE_PACKAGE_INSTALL = 'PackageInstall';
    public static final String EVENT_TYPE_PERMISSION_UPDATE = 'PermissionUpdate';
    public static final String EVENT_TYPE_PLATFORM_ENCRYPTION = 'PlatformEncryption';
    public static final String EVENT_TYPE_PRICING = 'Pricing';
    public static final String EVENT_TYPE_QUEUED_EXECUTION = 'QueuedExecution';
    public static final String EVENT_TYPE_REPORT = 'Report';
    public static final String EVENT_TYPE_REPORT_EXPORT = 'ReportExport';
    public static final String EVENT_TYPE_REST_API = 'RestApi';
    public static final String EVENT_TYPE_SANDBOX = 'Sandbox';
    public static final String EVENT_TYPE_SEARCH = 'Search';
    public static final String EVENT_TYPE_SEARCH_CLICK = 'SearchClick';
    public static final String EVENT_TYPE_SITES = 'Sites';
    public static final String EVENT_TYPE_TIME_BASED_WORKFLOW = 'TimeBasedWorkflow';
    public static final String EVENT_TYPE_TRANSACTION_SECURITY = 'TransactionSecurity';
    public static final String EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING = 'UITelemetryNavigationTiming';
    public static final String EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING = 'UITelemetryResourceTiming';
    public static final String EVENT_TYPE_URI = 'URI';
    public static final String EVENT_TYPE_VISUALFORCE_REQUEST = 'VisualforceRequest';
    public static final String EVENT_TYPE_WAVE_CHANGE = 'WaveChange';
    public static final String EVENT_TYPE_WAVE_DOWNLOAD = 'WaveDownload';
    public static final String EVENT_TYPE_WAVE_INTERACTION = 'WaveInteraction';
    public static final String EVENT_TYPE_WAVE_PERFORMANCE = 'WavePerformance';

    // Event types to check for duplicates
    // when a errors comes from several sources (Email, Event Log, etc), we need to check for duplicates
    public static final Set<String> EVENT_TYPES_TO_CHECK_DUPLICATES = new Set<String>{
        EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION
    };

    // Event type to processor mapping
    private static final Map<String, Type> EVENT_TYPE_TO_PROCESSOR = new Map<String, Type>{
        EVENT_TYPE_API => SOAPAPIEventProcessor.class,
        EVENT_TYPE_APEX_CALLOUT => ApexCalloutProcessor.class,
        EVENT_TYPE_APEX_EXECUTION => ApexExecutionProcessor.class,
        EVENT_TYPE_APEX_REST_API => ApexRestApiEventProcessor.class,
        EVENT_TYPE_APEX_SOAP => ApexSOAPApiEventProcessor.class,
        EVENT_TYPE_APEX_TRIGGER => ApexTriggerProcessor.class,
        EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => ApexUnexpectedExceptionProcessor.class,
        EVENT_TYPE_API_TOTAL_USAGE => ApiTotalUsageProcessor.class,
        EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => AsyncReportRunEventProcessor.class,
        EVENT_TYPE_AURA_REQUEST => AuraRequestProcessor.class,
        EVENT_TYPE_BLOCKED_REDIRECT => BlockedRedirectProcessor.class,
        EVENT_TYPE_BULK_API => BulkApiEventProcessor.class,
        EVENT_TYPE_BULK_API_REQUEST => BulkApiRequestProcessor.class,
        EVENT_TYPE_BULK_API_2 => BulkApi2Processor.class,
        EVENT_TYPE_CHANGE_SET_OPERATION => ChangeSetOperationProcessor.class,
        EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => ConcurrentLongRunningApexLimitProcessor.class,
        EVENT_TYPE_CONSOLE => ConsoleEventProcessor.class,
        EVENT_TYPE_CONTENT_DISTRIBUTION => ContentDistributionProcessor.class,
        EVENT_TYPE_CONTENT_DOCUMENT_LINK => ContentDocumentLinkProcessor.class,
        EVENT_TYPE_CONTENT_TRANSFER => ContentTransferProcessor.class,
        EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY => ContinuationCalloutSummaryProcessor.class,
        EVENT_TYPE_CORS_VIOLATION => CorsViolationProcessor.class,
        EVENT_TYPE_CSP_VIOLATION => CspViolationProcessor.class,
        EVENT_TYPE_DASHBOARD => DashboardEventProcessor.class,
        EVENT_TYPE_DATABASE_SAVE => DatabaseSaveEventProcessor.class,
        EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS => DocumentAttachmentDownloadsProcessor.class,
        EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT => ExternalCustomApexCalloutProcessor.class,
        EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT => ExternalCrossOrgCalloutProcessor.class,
        EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT => ExternalDataSourceCalloutProcessor.class,
        EVENT_TYPE_EXTERNAL_ODATA_CALLOUT => ExternalODataCalloutProcessor.class,
        EVENT_TYPE_FLOW_EXECUTION => FlowExecutionEventProcessor.class,
        EVENT_TYPE_GROUP_MEMBERSHIP => GroupMembershipProcessor.class,
        EVENT_TYPE_HOSTNAME_REDIRECTS => HostnameRedirectsProcessor.class,
        EVENT_TYPE_INSECURE_EXTERNAL_ASSETS => InsecureExternalAssetsProcessor.class,
        EVENT_TYPE_INSUFFICIENT_ACCESS => InsufficientAccessProcessor.class,
        EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW => KnowledgeArticleViewProcessor.class,
        EVENT_TYPE_LIGHTNING_ERROR => LightningErrorProcessor.class,
        EVENT_TYPE_LIGHTNING_INTERACTION => LightningInteractionProcessor.class,
        EVENT_TYPE_LIGHTNING_LOGGER => LightningLoggerProcessor.class,
        EVENT_TYPE_LIGHTNING_PAGE_VIEW => LightningPageViewProcessor.class,
        EVENT_TYPE_LIGHTNING_PERFORMANCE => LightningPerformanceProcessor.class,
        EVENT_TYPE_LOGIN => LoginEventProcessor.class,
        EVENT_TYPE_LOGIN_AS => LoginAsProcessor.class,
        EVENT_TYPE_LOGOUT => LogoutProcessor.class,
        EVENT_TYPE_METADATA_API_OPERATION => MetadataApiOperationProcessor.class,
        EVENT_TYPE_MULTIBLOCK_REPORT => MultiblockReportProcessor.class,
        EVENT_TYPE_NAMED_CREDENTIAL => NamedCredentialProcessor.class,
        EVENT_TYPE_ONE_COMMERCE_USAGE => OneCommerceUsageProcessor.class,
        EVENT_TYPE_PACKAGE_INSTALL => PackageInstallProcessor.class,
        EVENT_TYPE_PERMISSION_UPDATE => PermissionUpdateProcessor.class,
        EVENT_TYPE_PLATFORM_ENCRYPTION => PlatformEncryptionProcessor.class,
        EVENT_TYPE_PRICING => PricingEventProcessor.class,
        EVENT_TYPE_QUEUED_EXECUTION => QueuedExecutionProcessor.class,
        EVENT_TYPE_REPORT => ReportEventProcessor.class,
        EVENT_TYPE_REPORT_EXPORT => ReportExportEventProcessor.class,
        EVENT_TYPE_REST_API => RestApiProcessor.class,
        EVENT_TYPE_SANDBOX => SandboxProcessor.class,
        EVENT_TYPE_SEARCH => SearchEventProcessor.class,
        EVENT_TYPE_SEARCH_CLICK => SearchClickEventProcessor.class,
        EVENT_TYPE_SITES => SitesEventProcessor.class,
        EVENT_TYPE_TIME_BASED_WORKFLOW => TimeBasedWorkflowProcessor.class,
        EVENT_TYPE_TRANSACTION_SECURITY => TransactionSecurityProcessor.class,
        EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING => UITelemetryNavigationTimingProcessor.class,
        EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING => UITelemetryResourceTimingProcessor.class,
        EVENT_TYPE_URI => UriEventProcessor.class,
        EVENT_TYPE_VISUALFORCE_REQUEST => VisualforceRequestProcessor.class,
        EVENT_TYPE_WAVE_CHANGE => WaveChangeEventProcessor.class,
        EVENT_TYPE_WAVE_DOWNLOAD => WaveDownloadEventProcessor.class,
        EVENT_TYPE_WAVE_INTERACTION => WaveInteractionEventProcessor.class,
        EVENT_TYPE_WAVE_PERFORMANCE => WavePerformanceEventProcessor.class
    };

    public static EventLogProcessor createProcessor(String eventType) {
        // Get the Type from the mapping
        Type processorType = EVENT_TYPE_TO_PROCESSOR.get(eventType);
        
        // If no processor found for event type, throw error
        if (processorType == null) {
            throw new EventProcessingException('No processor found for event type: ' + eventType);
        }
        
        try {
            // Create new instance of the processor
            Object processor = processorType.newInstance();
            // Cast to EventLogProcessor and return
            return (EventLogProcessor)processor;
        }
        catch (Exception e) {
            throw new EventProcessingException(
                'Failed to create processor for event type: ' + eventType + 
                '. Error: ' + e.getMessage()
            );
        }
    }

    /**
     * Batch Event Data Processor
     * 
     * This class is used to process a batch of event data results and find matches.
     * It uses the EventMonitoringProcessors to find matches and logs them using the Logger.
     */
    public class BatchEventDataProcessor implements IBatchProcessor {
        private final EventMonitoringProcessors.IEventLogProcessor eventLogProcessor;
        private Logger logger;
        
        public BatchEventDataProcessor(
            EventMonitoringProcessors.IEventLogProcessor eventLogProcessor,
            Logger logger
        ) {
            this.eventLogProcessor = eventLogProcessor;
            this.logger = logger;
        }

        // Process batch event data results per chunk
        // iterate over the batch results and process them, this is to avoid memory issues
        public void processBatchEventDataResults(List<EventLogProcessors.IBaseEventData> batchResults, FieldMetadataConfig fieldMetadataConfig) {
            if (batchResults == null || batchResults.isEmpty()) return;
            
            try {
                // Get Log__c records directly from event processor
                List<Log__c> logRecords = eventLogProcessor.findMatches(batchResults, fieldMetadataConfig);

                if (logRecords != null && !logRecords.isEmpty()) {
                    for (Log__c logRecord : logRecords) {
                        this.logger.add(logRecord);
                    }
                }
            }
            catch (Exception e) {
                this.logger.add(this.logger.getInternalError(e, null, BatchEventDataProcessor.class.getName(), 'Error processing batch event data results'));
            }
        }
    }

    /**
     * Field Metadata
     * 
     * This class is used to store field metadata for a log file.
     * name=CPU_TIME, type=Number
     * name=STATUS_CODE, type=String
     * name=REQUEST_STATUS, type=String
     * name=SUCCESS, type=Boolean
     * name=EXCEPTION_MESSAGE, type=String
     */
    public class FieldMetadata {
        public String name;
        public String type;

        public FieldMetadata(String name, String type) {
            this.name = name;
            this.type = type;
        }
    }

    /**
     * Field Metadata Builder
     * 
     * This class is used to build field metadata for a log file.
     */
    public class FieldMetadataBuilder {
        private Map<String, FieldMetadata> fields = new Map<String, FieldMetadata>();

        public void addField(String name, String type) {
            fields.put(name, new FieldMetadata(name, type));
        }

        public String getFieldType(String name) {
            return fields.get(name).type;
        }
    }

    /**
     * Field Metadata Config
     * 
     * This class is used to configure field metadata for a log file.
     */
    public class FieldMetadataConfig {
        private FieldMetadataBuilder fieldMetadataBuilder;

        public FieldMetadataConfig(){
            this.fieldMetadataBuilder = new FieldMetadataBuilder();
        }

        public FieldMetadataConfig(String names,String types) {
            this();
            List<String> fieldNames = (names != null) ? names.split(',') : new List<String>();
            List<String> fieldTypes = (types != null) ? types.split(',') : new List<String>();
            
            for(Integer i = 0; i < fieldNames.size() && i < fieldTypes.size(); i++) {
                fieldMetadataBuilder.addField(fieldNames[i], fieldTypes[i]);
            }
        }

        public String getFieldType(String name) {
            return fieldMetadataBuilder.getFieldType(name);
        }

        public void addField(String name, String type) {
            fieldMetadataBuilder.addField(name, type);
        }
    }

    public class FilterField {
        public String name;
        public String label;
        public String type;

        public FilterField(String name, String label, String type) {
            this.name = name;
            this.label = label;
            this.type = type;
        }
    }

    /**
     * Base Event Log Processor
     * 
     * This class is used to process event data from a log file.
     * It uses the CSVParser to parse the log file and the requiredHeaders to validate the headers.
     * It also provides methods to get fields from the log file and to process the log file.
     * 
     * batchProcessLogFile method uses a callback to process the log file.
     */
    public virtual class EventLogProcessor {
        protected final CSVParser csvParser;
        protected final Set<String> requiredHeaders;
        protected FieldMetadataConfig fieldMetadataConfig;
        protected List<FilterField> filterFields;

        public EventLogProcessor() {
            this.csvParser = new CSVParser();
            this.requiredHeaders = new Set<String>{FIELD_TIMESTAMP, FIELD_USER_ID};
            this.filterFields = new List<FilterField>();
        }
        
        public EventLogProcessor(Set<String> additionalHeaders) {
            this();
            this.requiredHeaders.addAll(additionalHeaders);
        }

        public void addFilterField(String name, String label, String type) {
            this.filterFields.add(new FilterField(name, label, type));
        }

        public List<FilterField> getFilterFields() {
            return this.filterFields;
        }

        public virtual Integer getChunkSize() {
            return 10;
        }

        /**
         * Batch Process EventLogFile using SObject for safe access
         * 
         * This method is used to process a log file in batches using SObject for safe field access.
         * It uses the CSVParser to parse the log file and the requiredHeaders to validate the headers.
         * It also provides methods chunk process the csv rows and process them in batches. after processing the batch, it calls the callback to process the batch results.
         */
        public virtual void batchProcessLogFileSObject(SObject logFile, IBatchProcessor batchProcessor) {
            // Process entire file (legacy behavior)
            batchProcessLogFileSObject(logFile, batchProcessor, null, null);
        }

        /**
         * Batch Process EventLogFile using SObject for safe access with chunking support
         * 
         * This method is used to process a log file in chunks using SObject for safe field access.
         * It uses the CSVParser to parse the log file and the requiredHeaders to validate the headers.
         * It processes only the specified range of rows (startRow to endRow) for chunked processing.
         * 
         * @param logFile The log file SObject
         * @param batchProcessor The batch processor callback
         * @param startRow The starting row index (0-based, null for entire file)
         * @param endRow The ending row index (exclusive, null for entire file)
         */
        public virtual void batchProcessLogFileSObject(SObject logFile, IBatchProcessor batchProcessor, Integer startRow, Integer endRow) {
            if (logFile == null) return;

            // Get LogFile blob safely
            Blob logFileBlob = EventMonitoringUtil.getBlobValue(logFile, EventMonitoringUtil.EVENT_LOG_FILE_LOG_FILE);
            if (logFileBlob == null) return;

            // Create field metadata config
            String fieldNames = Test.isRunningTest() ? testEventLogFieldNames : EventMonitoringUtil.getStringValue(logFile, EventMonitoringUtil.EVENT_LOG_FILE_LOG_FILE_FIELD_NAMES);
            String fieldTypes = Test.isRunningTest() ? testEventLogFieldTypes : EventMonitoringUtil.getStringValue(logFile, EventMonitoringUtil.EVENT_LOG_FILE_LOG_FILE_FIELD_TYPES);
            this.fieldMetadataConfig = new FieldMetadataConfig(fieldNames, fieldTypes);

            // field Metadata Config override for Apex Callout
            // in documentation Success field is Boolean but in actual it is String
            String eventType = EventMonitoringUtil.getStringValue(logFile, EventMonitoringUtil.EVENT_LOG_FILE_EVENT_TYPE);
            if (String.isNotBlank(eventType) && eventType == EVENT_TYPE_APEX_CALLOUT) {
                this.fieldMetadataConfig?.addField('SUCCESS', 'String');
            }

            // Parse the log file, retrieve the headers
            csvParser.parse(logFileBlob.toString());
    
            // Validate headers
            List<String> headers = csvParser.getHeaders();
            if (!validateHeaders(headers)) {
                return;
            }

            // Create header map, map the headers to the index of the field
            // this is used to map the csv row to the event data
            // CPU_TIME=>0, STATUS_CODE=>1, REQUEST_STATUS=>2, SUCCESS=>3, EXCEPTION_MESSAGE=>4
            Map<String, Integer> headerMap = createHeaderMap(headers);
    
            Integer rowIndex = 0;
            List<List<String>> csvRows = new List<List<String>>();
            Integer processedRows = 0;

            // Iterate over the csv rows
            for (Iterator<List<String>> iter = csvParser.iterator(); iter.hasNext(); ) {
                List<String> currentRow = iter.next();
                
                // Skip rows before startRow if chunking is enabled
                if (startRow != null && rowIndex < startRow) {
                    rowIndex++;
                    continue;
                }
                
                // Stop processing if we've reached endRow
                if (endRow != null && rowIndex >= endRow) {
                    break;
                }
                
                csvRows.add(currentRow);
                
                // Process batch when it reaches chunk size or when there are no more records
                Integer chunkSize = getChunkSize();
                if (csvRows.size() == chunkSize || !iter.hasNext()) {
                    try {
                        // bulk parse csv row fields to instance of IBaseEventData
                        List<IBaseEventData> batchResults = batchProcessCSVRows(csvRows, headerMap);
                        if (!batchResults.isEmpty()) {
                            // Call the callback with batch results
                            if (batchProcessor != null) {
                                batchProcessor.processBatchEventDataResults(batchResults, fieldMetadataConfig);
                            }
                        }
                    }
                    catch (Exception e) {}
                    processedRows += csvRows.size();
                    csvRows.clear();
                }
                
                rowIndex++;
            }
        }

        // Process batch of csv rows, this is to avoid memory issues
        private List<IBaseEventData> batchProcessCSVRows(List<List<String>> csvRows, Map<String, Integer> headerMap) {
            List<IBaseEventData> batchResults = new List<IBaseEventData>();
            
            for (List<String> fields : csvRows) {
                try {
                    final Map<String, Object> eventData = csvRowToEventData(fields, headerMap);
                    batchResults.add(processCsvRow(eventData, fields, headerMap));
                }
                catch (Exception e) {}
            }
            return batchResults;
        }

        /**
         * CSV Row to Event Data
         * 
         * This method is used to get event data from a csv row.
         * It uses the headerMap to map the csv row to the event data.
         */
        protected virtual Map<String, Object> csvRowToEventData(List<String> fields, Map<String, Integer> headerMap) {
            Map<String, Object> eventData = new Map<String, Object>();
            for (String header : headerMap.keySet()) {
                Integer index = headerMap.get(header);
                String value = fields.get(index)?.removeStart('"')?.removeEnd('"');
                eventData.put(header, value);
            }
            return eventData;
        }
        
        // each event type class shuld override this method to process the csv row
        protected virtual IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            return new BaseEventData(eventData);
        }
        
        private Boolean validateHeaders(List<String> headers) {
            if (headers == null || headers.isEmpty()) return false;
            
            Set<String> headerSet = new Set<String>(headers);
            for (String required : requiredHeaders) {
                if (!headerSet.contains(required)) return false;
            }
            
            return true;
        }
        
        private Map<String, Integer> createHeaderMap(List<String> headers) {
            Map<String, Integer> headerMap = new Map<String, Integer>();
            Integer counter = 0;
            for(String header : headers) {
                headerMap.put(header, counter++);
            }
            return headerMap;
        }
        
        protected String getField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            Integer idx = headerMap.get(fieldName);
            return (idx != null && idx < fields.size()) ? fields[idx]?.trim()?.removeStart('"')?.removeEnd('"') : '';
        }

        protected List<String> getListField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            return String.isNotBlank(value) ? (List<String>)JSON.deserialize(value, List<String>.class) : new List<String>();
        }

        protected Long getLongField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            return String.isNotBlank(value) ? Long.valueOf(value) : 0;
        }

        protected Boolean getBooleanField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            return String.isNotBlank(value) ? Boolean.valueOf(value) : false;
        }
        
        protected Integer getIntegerField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            return String.isNotBlank(value) ? Integer.valueOf(value) : 0;
        }

        protected Decimal getDecimalField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            return String.isNotBlank(value) ? Decimal.valueOf(value) : null;
        }
        
        protected DateTime getDateTimeField(List<String> fields, Map<String, Integer> headerMap, String fieldName) {
            String value = getField(fields, headerMap, fieldName);
            if (String.isBlank(value)) {
                return null;
            }
            
            try {
                // Use JSON.deserialize for clean ISO8601 parsing with millisecond precision
                return (DateTime)JSON.deserialize('"' + value + '"', DateTime.class);
            } catch (Exception e) {
                // Fallback to legacy parsing for non-ISO8601 formats
                try {
                    return DateTime.valueOfGmt(value.replace('T', ' ').replace('Z', ''));
                } catch (Exception ex) {
                    return null;
                }
            }
        }
    }

    // Common Field Constants
    public static final String FIELD_REQUEST_ID = 'REQUEST_ID';
    public static final String FIELD_QUIDDITY = 'QUIDDITY';
    public static final String FIELD_ACTION_MESSAGE = 'ACTION_MESSAGE';
    public static final String FIELD_TIMESTAMP = 'TIMESTAMP';
    public static final String FIELD_TIMESTAMP_DERIVED = 'TIMESTAMP_DERIVED';
    public static final String FIELD_SEQUENCE = 'SEQUENCE';

    // User & Organization Fields
    public static final String FIELD_USER_ID = 'USER_ID';
    public static final String FIELD_USER_ID_DERIVED = 'USER_ID_DERIVED';
    public static final String FIELD_USERNAME = 'USERNAME';
    public static final String FIELD_USER_TYPE = 'USER_TYPE';
    public static final String FIELD_USER_AGENT = 'USER_AGENT';
    public static final String FIELD_ORGANIZATION_ID = 'ORGANIZATION_ID';
    public static final String FIELD_DELEGATED_USER_ID = 'DELEGATED_USER_ID';
    public static final String FIELD_DELEGATED_USER_ID_DERIVED = 'DELEGATED_USER_ID_DERIVED';
    public static final String FIELD_DELEGATED_USER_NAME = 'DELEGATED_USER_NAME';
    public static final String FIELD_USER_NAME = 'USER_NAME';
    
    // Performance Metrics
    public static final String FIELD_CPU_TIME = 'CPU_TIME';
    public static final String FIELD_RUN_TIME = 'RUN_TIME';
    public static final String FIELD_EXEC_TIME = 'EXEC_TIME';
    public static final String FIELD_DURATION = 'DURATION';
    public static final String FIELD_ELAPSED_TIME = 'ELAPSED_TIME';
    public static final String FIELD_PROCESSING_TIME = 'PROCESSING_TIME';
    public static final String FIELD_TIME = 'TIME';
    public static final String FIELD_IS_LONG_RUNNING_REQUEST = 'IS_LONG_RUNNING_REQUEST';
    
    // Request/Response Details
    public static final String FIELD_REQUEST_SIZE = 'REQUEST_SIZE';
    public static final String FIELD_RESPONSE_SIZE = 'RESPONSE_SIZE';
    public static final String FIELD_REQUEST_STATUS = 'REQUEST_STATUS';
    public static final String FIELD_REQUEST_METHOD = 'REQUEST_METHOD';
    public static final String FIELD_REQUEST_TYPE = 'REQUEST_TYPE';
    public static final String FIELD_URL = 'URL';
    public static final String FIELD_IS_API = 'IS_API';
    public static final String FIELD_SITE_ID = 'SITE_ID';
    public static final String FIELD_PAGE_NAME = 'PAGE_NAME';
    public static final String FIELD_STATUS_CODE = 'STATUS_CODE';
    public static final String FIELD_REQUEST_PATH = 'REQUEST_PATH';
    public static final String FIELD_BODY_LENGTH = 'BODY_LENGTH';
    public static final String FIELD_CONTENT_TYPE = 'CONTENT_TYPE';
    public static final String FIELD_IS_SECURE = 'IS_SECURE';
    public static final String FIELD_VIEW_STATE_SIZE = 'VIEW_STATE_SIZE';
    public static final String FIELD_CONTROLLER_TYPE = 'CONTROLLER_TYPE';
    public static final String FIELD_IS_AJAX_REQUEST = 'IS_AJAX_REQUEST';
    public static final String FIELD_MANAGED_PACKAGE_NAMESPACE = 'MANAGED_PACKAGE_NAMESPACE';
    // URI & Endpoint Information
    public static final String FIELD_URI = 'URI';
    public static final String FIELD_URI_ID_DERIVED = 'URI_ID_DERIVED';
    public static final String FIELD_ENDPOINT = 'ENDPOINT';
    public static final String FIELD_TARGET_URL = 'TARGET_URL';
    public static final String FIELD_REDIRECT_URL = 'REDIRECT_URL';
    public static final String FIELD_REFERRER_URI = 'REFERRER_URI';
    public static final String FIELD_REQUEST_URI = 'REQUEST_URI';

    // Database Performance
    public static final String FIELD_DB_TOTAL_TIME = 'DB_TOTAL_TIME';
    public static final String FIELD_DB_CPU_TIME = 'DB_CPU_TIME';
    public static final String FIELD_DB_BLOCKS = 'DB_BLOCKS';
    public static final String FIELD_DB_COMMITS = 'DB_COMMITS';
    public static final String FIELD_DB_ROLLBACKS = 'DB_ROLLBACKS';
    public static final String FIELD_DB_NUM_ROWS = 'DB_NUM_ROWS';
    
    // SOQL & Query Related
    public static final String FIELD_NUMBER_SOQL_QUERIES = 'NUMBER_SOQL_QUERIES';
    public static final String FIELD_QUERY_COUNT = 'QUERY_COUNT';
    public static final String FIELD_QUERY_ID = 'QUERY_ID';
    public static final String FIELD_QUERY_PARAMETERS = 'QUERY_PARAMETERS';
    public static final String FIELD_ROWS_PROCESSED = 'ROWS_PROCESSED';
    public static final String FIELD_ROW_COUNT = 'ROW_COUNT';
    public static final String FIELD_NUMBER_FIELDS = 'NUMBER_FIELDS';
    // API Related
    public static final String FIELD_API_TYPE = 'API_TYPE';
    public static final String FIELD_API_VERSION = 'API_VERSION';
    public static final String FIELD_API_FAMILY = 'API_FAMILY';
    public static final String FIELD_API_RESOURCE = 'API_RESOURCE';


    // Bulk API
    public static final String FIELD_BATCH_ID = 'BATCH_ID';
    public static final String FIELD_JOB_ID = 'JOB_ID';
    public static final String FIELD_CONCURRENCY_MODE = 'CONCURRENCY_MODE';
    public static final String FIELD_NUMBER_FAILURES = 'NUMBER_FAILURES';

    // Client Information
    public static final String FIELD_CLIENT_NAME = 'CLIENT_NAME';
    public static final String FIELD_CLIENT_IP = 'CLIENT_IP';
    public static final String FIELD_CLIENT_ID = 'CLIENT_ID';
    public static final String FIELD_CLIENT_VERSION = 'CLIENT_VERSION';
    public static final String FIELD_CLIENT_INFO = 'CLIENT_INFO';
    public static final String FIELD_SOURCE_HOSTNAME = 'SOURCE_HOSTNAME';
    public static final String FIELD_TARGET_HOSTNAME = 'TARGET_HOSTNAME';
    public static final String FIELD_PATH = 'PATH';
    public static final String FIELD_REDIRECT_REASON = 'REDIRECT_REASON';
    public static final String FIELD_IS_BLOCKED_REDIRECTION = 'IS_BLOCKED_REDIRECTION';
    public static final String FIELD_REFERRER = 'REFERRER';
    public static final String FIELD_ORIGIN = 'ORIGIN';
    public static final String FIELD_HOST = 'HOST';
    public static final String FIELD_MALFORMED_URL = 'MALFORMED_URL';
    public static final String FIELD_BLOCKED_URI = 'BLOCKED_URI';
    public static final String FIELD_BLOCKED_URI_DOMAIN = 'BLOCKED_URI_DOMAIN';

    // Csp Violation
    public static final String FIELD_SOURCE = 'SOURCE';
    public static final String FIELD_SOURCE_FILE = 'SOURCE_FILE';
    public static final String FIELD_COLUMN_NUMBER = 'COLUMN_NUMBER';
    public static final String FIELD_DIRECTIVE = 'DIRECTIVE';
    public static final String FIELD_RESOURCE_SAMPLE = 'RESOURCE_SAMPLE';

    // Session & Authentication
    public static final String FIELD_SESSION_KEY = 'SESSION_KEY';
    public static final String FIELD_SESSION_LEVEL = 'SESSION_LEVEL';
    public static final String FIELD_SESSION_TYPE = 'SESSION_TYPE';
    public static final String FIELD_LOGIN_KEY = 'LOGIN_KEY';
    public static final String FIELD_LOGIN_STATUS = 'LOGIN_STATUS';
    public static final String FIELD_LOGIN_TYPE = 'LOGIN_TYPE';
    public static final String FIELD_AUTH_METHOD = 'AUTH_METHOD';
    public static final String FIELD_AUTH_SERVICE_ID = 'AUTH_SERVICE_ID';
    public static final String FIELD_NETWORK_ID = 'NETWORK_ID';
    public static final String FIELD_UNIQUE_ID = 'UNIQUE_ID';

    // Namespace & Package
    public static final String FIELD_PACKAGE_VERSION_NUMBER = 'PACKAGE_VERSION_NUMBER';
    public static final String FIELD_EVENT_TYPE = 'EVENT_TYPE';
    public static final String FIELD_FAILURE_TYPE = 'FAILURE_TYPE';
    public static final String FIELD_IS_MANAGED = 'IS_MANAGED';
    public static final String FIELD_IS_PUSH = 'IS_PUSH';
    public static final String FIELD_IS_RELEASED = 'IS_RELEASED';
    public static final String FIELD_IS_SUCCESSFUL = 'IS_SUCCESSFUL';
    public static final String FIELD_NAMESPACE = 'NAMESPACE';
    public static final String FIELD_PACKAGE_NAME = 'PACKAGE_NAME';
    public static final String FIELD_PACKAGE_VERSION = 'PACKAGE_VERSION';
    public static final String FIELD_CLASS_NAME = 'CLASS_NAME';
    public static final String FIELD_QUERY = 'QUERY';
    
    // Trigger
    public static final String FIELD_TRIGGER_ID = 'TRIGGER_ID';
    public static final String FIELD_TRIGGER_NAME = 'TRIGGER_NAME';
    public static final String FIELD_TRIGGER_TYPE = 'TRIGGER_TYPE';
   
    // Method Information
    public static final String FIELD_METHOD_NAME = 'METHOD_NAME';
    public static final String FIELD_METHOD = 'METHOD';
    public static final String FIELD_HTTP_METHOD = 'HTTP_METHOD';
    public static final String FIELD_HTTP_HEADERS = 'HTTP_HEADERS';
    public static final String FIELD_MEDIA_TYPE = 'MEDIA_TYPE';
    public static final String FIELD_CONNECTED_APP_ID = 'CONNECTED_APP_ID';
    public static final String FIELD_IS_FIRST_REQUEST = 'IS_FIRST_REQUEST';
    public static final String FIELD_IS_GUEST = 'IS_GUEST';
    public static final String FIELD_IS_ERROR = 'IS_ERROR';
    public static final String FIELD_COUNTS_AGAINST_API_LIMIT = 'COUNTS_AGAINST_API_LIMIT';
    // Encryption Information
    public static final String FIELD_ACTION = 'ACTION';
    public static final String FIELD_KEY_ID = 'KEY_ID';
    public static final String FIELD_KEY_ID_DERIVED = 'KEY_ID_DERIVED';
    public static final String FIELD_KEY_TYPE = 'KEY_TYPE';
    
    // Limit Usage
    public static final String FIELD_LIMIT_USAGE_PERCENT = 'LIMIT_USAGE_PERCENT';
    
    // Report/Dashboard Specific
    public static final String FIELD_REPORT_DESCRIPTION = 'REPORT_DESCRIPTION';
    public static final String FIELD_REPORT_ID = 'REPORT_ID';
    public static final String FIELD_REPORT_NAME = 'REPORT_NAME';
    public static final String FIELD_DASHBOARD_ID = 'DASHBOARD_ID';
    public static final String FIELD_DASHBOARD_NAME = 'DASHBOARD_NAME';
    public static final String FIELD_FOLDER_ID = 'FOLDER_ID';
    public static final String FIELD_AVERAGE_ROW_SIZE = 'AVERAGE_ROW_SIZE';
    public static final String FIELD_REPORT_ID_DERIVED = 'REPORT_ID_DERIVED';
    public static final String FIELD_DASHBOARD_TYPE = 'DASHBOARD_TYPE';
    public static final String FIELD_DASHBOARD_ID_DERIVED = 'DASHBOARD_ID_DERIVED';
    public static final String FIELD_DASHBOARD_COMPONENT_ID = 'DASHBOARD_COMPONENT_ID';
    public static final String FIELD_IS_SCHEDULED = 'IS_SCHEDULED';
    public static final String FIELD_IS_SUCCESS = 'IS_SUCCESS';
    public static final String FIELD_VIEWING_USER_ID = 'VIEWING_USER_ID';
    public static final String FIELD_SORT = 'SORT';
    public static final String FIELD_DISPLAY_TYPE = 'DISPLAY_TYPE';
    public static final String FIELD_RENDERING_TYPE = 'RENDERING_TYPE';
    public static final String FIELD_NUMBER_BUCKETS = 'NUMBER_BUCKETS';
    public static final String FIELD_NUMBER_COLUMNS = 'NUMBER_COLUMNS';
    public static final String FIELD_UI_NUMBER_COLUMNS = 'UI_NUMBER_COLUMNS';
    public static final String FIELD_NUMBER_EXCEPTION_FILTERS = 'NUMBER_EXCEPTION_FILTERS';

    // Document
    public static final String FIELD_DOCUMENT_ID = 'DOCUMENT_ID';
    public static final String FIELD_DOCUMENT_URI = 'DOCUMENT_URI';
    public static final String FIELD_SHARED_WITH_ENTITY_ID = 'SHARED_WITH_ENTITY_ID';
    public static final String FIELD_SHARING_OPERATION = 'SHARING_OPERATION';
    public static final String FIELD_SHARING_PERMISSION = 'SHARING_PERMISSION';
    public static final String FIELD_VERSION_ID = 'VERSION_ID';
    public static final String FIELD_VERSION_ID_DERIVED = 'VERSION_ID_DERIVED';
    public static final String FIELD_DOCUMENT_ID_DERIVED = 'DOCUMENT_ID_DERIVED';
    public static final String FIELD_FILE_PREVIEW_TYPE = 'FILE_PREVIEW_TYPE';
    public static final String FIELD_SIZE_BYTES = 'SIZE_BYTES';
    public static final String FIELD_TRANSACTION_TYPE = 'TRANSACTION_TYPE';

    // Asset
    public static final String FIELD_ASSET_ID = 'ASSET_ID';
    public static final String FIELD_DISPOSITION = 'DISPOSITION';
    public static final String FIELD_TYPE = 'TYPE';
    public static final String FIELD_ASSET_TYPE = 'ASSET_TYPE';
    public static final String FIELD_INSECURE_URI = 'INSECURE_URI';
    public static final String FIELD_DATASET_IDS = 'DATASET_IDS';
    public static final String FIELD_DOWNLOAD_ERROR = 'DOWNLOAD_ERROR';
    public static final String FIELD_DOWNLOAD_FORMAT = 'DOWNLOAD_FORMAT';

    // Wave
    public static final String FIELD_NUM_CLICKS = 'NUM_CLICKS';
    public static final String FIELD_NUM_SESSIONS = 'NUM_SESSIONS';
    public static final String FIELD_READ_TIME = 'READ_TIME';
    public static final String FIELD_TOTAL_TIME = 'TOTAL_TIME';
    public static final String FIELD_WAVE_SESSION_ID = 'WAVE_SESSION_ID';
    public static final String FIELD_WAVE_TIMESTAMP = 'WAVE_TIMESTAMP';
    public static final String FIELD_TAB_ID = 'TAB_ID';
    public static final String FIELD_SAVED_VIEW_ID = 'SAVED_VIEW_ID';
    public static final String FIELD_RECORDING_ID = 'RECORDING_ID';
    public static final String FIELD_PAGE_ID = 'PAGE_ID';
    public static final String FIELD_IS_INITIAL = 'IS_INITIAL';
    public static final String FIELD_VIEW_MODE = 'VIEW_MODE';
    public static final String FIELD_IS_MOBILE = 'IS_MOBILE';
    public static final String FIELD_REOPEN_COUNT = 'REOPEN_COUNT';
    public static final String FIELD_EPT = 'EPT';
    public static final String FIELD_IS_NEW = 'IS_NEW';
    public static final String FIELD_NUMBER_OF_RECORDS = 'NUMBER_OF_RECORDS';
    public static final String FIELD_ANALYTICS_MODE = 'ANALYTICS_MODE';
    public static final String FIELD_NAME = 'NAME';
    // Geolocation
    public static final String FIELD_COUNTRY_CODE = 'COUNTRY_CODE';
    public static final String FIELD_COUNTRY_NAME = 'COUNTRY_NAME';
    public static final String FIELD_CITY = 'CITY';
    public static final String FIELD_POSTAL_CODE = 'POSTAL_CODE';
    public static final String FIELD_SUBDIVISION = 'SUBDIVISION';
    public static final String FIELD_CLIENT_GEO = 'CLIENT_GEO';
    
    // Network & Connection
    public static final String FIELD_CONNECTION_TYPE = 'CONNECTION_TYPE';
    public static final String FIELD_TLS_PROTOCOL = 'TLS_PROTOCOL';
    public static final String FIELD_CIPHER_SUITE = 'CIPHER_SUITE';
    public static final String FIELD_NETWORK_TYPE = 'NETWORK_TYPE';
    public static final String FIELD_ORIGIN_REQUEST_ID = 'ORIGIN_REQUEST_ID';
    public static final String FIELD_CONTINUATION_ID = 'CONTINUATION_ID';
    public static final String FIELD_VF_CONTROLLER_SIZE = 'VF_CONTROLLER_SIZE';
    public static final String FIELD_REQUEST_FORM_SIZE = 'REQUEST_FORM_SIZE';
    
    // Metadata & Schema
    public static final String FIELD_METADATA_JSON = 'METADATA_JSON';
    public static final String FIELD_SCHEMA_TYPE = 'SCHEMA_TYPE';
    public static final String FIELD_SCHEMA_NAME = 'SCHEMA_NAME';
    public static final String FIELD_FIELD_NAMES = 'FIELD_NAMES';
    
    // File & Content
    public static final String FIELD_FILE_NAME = 'FILE_NAME';
    public static final String FIELD_FILE_TYPE = 'FILE_TYPE';
    public static final String FIELD_FILE_SIZE = 'FILE_SIZE';
    public static final String FIELD_CONTENT_LENGTH = 'CONTENT_LENGTH';
    
    // Time & Date
    public static final String FIELD_START_TIME = 'START_TIME';
    public static final String FIELD_END_TIME = 'END_TIME';
    public static final String FIELD_LOG_TIME = 'LOG_TIME';
    public static final String FIELD_EVENT_DATE = 'EVENT_DATE';
    
    // Identifiers & References
    public static final String FIELD_CORRELATION_ID = 'CORRELATION_ID';
    public static final String FIELD_TRANSACTION_ID = 'TRANSACTION_ID';
    public static final String FIELD_REFERENCE_ID = 'REFERENCE_ID';
    public static final String FIELD_PARENT_ID = 'PARENT_ID';
    public static final String FIELD_CONSOLE_ID = 'CONSOLE_ID';
    public static final String FIELD_CONSOLE_ID_DERIVED = 'CONSOLE_ID_DERIVED';
    public static final String FIELD_LICENSE_CONTEXT = 'LICENSE_CONTEXT';
    public static final String FIELD_CONTEXT = 'CONTEXT';
    public static final String FIELD_APP_TYPE = 'APP_TYPE';

    // Knowledge
    public static final String FIELD_ARTICLE_ID = 'ARTICLE_ID';
    public static final String FIELD_ARTICLE_VERSION_ID = 'ARTICLE_VERSION_ID';
    public static final String FIELD_ARTICLE_STATUS = 'ARTICLE_STATUS';
    public static final String FIELD_ARTICLE_VERSION = 'ARTICLE_VERSION';
    public static final String FIELD_LAST_VERSION = 'LAST_VERSION';
    public static final String FIELD_LANGUAGE = 'LANGUAGE';
    public static final String FIELD_LARGE_LANGUAGE_MODEL = 'LARGE_LANGUAGE_MODEL';

    // Permission & Update Types
    public static final String FIELD_PERMISSION_TYPE = 'PERMISSION_TYPE';
    public static final String FIELD_UPDATE_TYPE = 'UPDATE_TYPE';
    public static final String FIELD_DESCRIPTION = 'DESCRIPTION';
    public static final String FIELD_FEATURE_ID = 'FEATURE_ID';

    // Lightning/UI Specific
    public static final String FIELD_PAGE_URL = 'PAGE_URL';
    public static final String FIELD_PAGE_START_TIME = 'PAGE_START_TIME';
    public static final String FIELD_PAGE_END_TIME = 'PAGE_END_TIME';
    public static final String FIELD_PAGE_CONTEXT = 'PAGE_CONTEXT';
    public static final String FIELD_COMPONENT_NAME = 'COMPONENT_NAME';
    public static final String FIELD_COMPONENT_ID = 'COMPONENT_ID';
    public static final String FIELD_COMPONENT_ID_DERIVED = 'COMPONENT_ID_DERIVED';
    public static final String FIELD_EFFECTIVE_PAGE_TIME = 'EFFECTIVE_PAGE_TIME';
    public static final String FIELD_APP_NAME = 'APP_NAME';
    public static final String FIELD_PAGE_APP_NAME = 'PAGE_APP_NAME';
    public static final String FIELD_PREVPAGE_APP_NAME = 'PREVPAGE_APP_NAME';
    public static final String FIELD_PAGE_ENTITY_ID = 'PAGE_ENTITY_ID';
    public static final String FIELD_PAGE_ENTITY_TYPE = 'PAGE_ENTITY_TYPE';
    public static final String FIELD_PREVPAGE_ENTITY_TYPE = 'PREVPAGE_ENTITY_TYPE';
    public static final String FIELD_PREVPAGE_URL = 'PREVPAGE_URL';
    public static final String FIELD_PREVPAGE_ENTITY_ID = 'PREVPAGE_ENTITY_ID';
    public static final String FIELD_PREVPAGE_CONTEXT = 'PREVPAGE_CONTEXT';
    public static final String FIELD_EFFECTIVE_PAGE_TIME_DEVIATION = 'EFFECTIVE_PAGE_TIME_DEVIATION';
    public static final String FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE = 'EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE';
    public static final String FIELD_TARGET_UI_ELEMENT = 'TARGET_UI_ELEMENT';
    public static final String FIELD_PARENT_UI_ELEMENT = 'PARENT_UI_ELEMENT';
    public static final String FIELD_GRANDPARENT_UI_ELEMENT = 'GRANDPARENT_UI_ELEMENT';
    public static final String FIELD_UI_EVENT_ID = 'UI_EVENT_ID';
    public static final String FIELD_UI_EVENT_SEQUENCE_NUM = 'UI_EVENT_SEQUENCE_NUM';
    public static final String FIELD_UI_EVENT_SOURCE = 'UI_EVENT_SOURCE';
    public static final String FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_REASON = 'EFFECTIVE_PAGE_TIME_DEVIATION_REASON';
    public static final String FIELD_UI_EVENT_TYPE = 'UI_EVENT_TYPE';
    public static final String FIELD_UI_EVENT_TIMESTAMP = 'UI_EVENT_TIMESTAMP';
    public static final String FIELD_RELATED_LIST = 'RELATED_LIST';
    public static final String FIELD_RECORD_TYPE = 'RECORD_TYPE';
    public static final String FIELD_GRAND_PARENT_UI_ELEMENT = 'GRAND_PARENT_UI_ELEMENT';


    // Browser & Device Information
    public static final String FIELD_BROWSER_TYPE = 'BROWSER_TYPE';
    public static final String FIELD_BROWSER_VERSION = 'BROWSER_VERSION';
    public static final String FIELD_BROWSER_NAME = 'BROWSER_NAME';
    public static final String FIELD_PLATFORM_TYPE = 'PLATFORM_TYPE';
    public static final String FIELD_RESOLUTION_TYPE = 'RESOLUTION_TYPE';
    public static final String FIELD_USER_INITIATED_LOGOUT = 'USER_INITIATED_LOGOUT';
    public static final String FIELD_DEVICE_ID = 'DEVICE_ID';
    public static final String FIELD_DEVICE_MODEL = 'DEVICE_MODEL';
    public static final String FIELD_DEVICE_PLATFORM = 'DEVICE_PLATFORM';
    public static final String FIELD_DEVICE_SESSION_ID = 'DEVICE_SESSION_ID';
    public static final String FIELD_OS_NAME = 'OS_NAME';
    public static final String FIELD_OS_VERSION = 'OS_VERSION';
    public static final String FIELD_SDK_APP_TYPE = 'SDK_APP_TYPE';
    public static final String FIELD_SDK_APP_VERSION = 'SDK_APP_VERSION';
    public static final String FIELD_SDK_VERSION = 'SDK_VERSION';
    public static final String FIELD_BROWSER_DEVICE_TYPE = 'BROWSER_DEVICE_TYPE';
    
    // Process Type
    public static final String FIELD_PROCESS_TYPE = 'PROCESS_TYPE';

    // Flow Specific
    public static final String FIELD_FLOW_NAME = 'FLOW_NAME';
    public static final String FIELD_FLOW_VERSION_ID = 'FLOW_VERSION_ID';
    public static final String FIELD_FLOW_LOAD_TIME = 'FLOW_LOAD_TIME';
    public static final String FIELD_TOTAL_EXECUTION_TIME = 'TOTAL_EXECUTION_TIME';
    public static final String FIELD_NUMBER_OF_INTERVIEWS = 'NUMBER_OF_INTERVIEWS';
    public static final String FIELD_NUMBER_OF_ERRORS = 'NUMBER_OF_ERRORS';

    // Group Specific
    public static final String FIELD_GROUP_TYPE = 'GROUP_TYPE';
    public static final String FIELD_GROUP_ID = 'GROUP_ID';
    public static final String FIELD_MEMBER_ID = 'MEMBER_ID';
    
    // Operation
    public static final String FIELD_OPERATION = 'OPERATION';
    public static final String FIELD_OPERATION_STAGE = 'OPERATION_STAGE';
    public static final String FIELD_OPERATION_STATE = 'OPERATION_STATE';
    public static final String FIELD_OPERATION_STATUS = 'OPERATION_STATUS';
    public static final String FIELD_OPERATION_TIME = 'OPERATION_TIME';
    public static final String FIELD_OPERATION_TYPE = 'OPERATION_TYPE';
    
    // Error & Exception Information
    public static final String FIELD_ERROR_CODE = 'ERROR_CODE';
    public static final String FIELD_MESSAGE = 'MESSAGE';
    public static final String FIELD_ERROR_TYPE = 'ERROR_TYPE';
    public static final String FIELD_ERROR_MESSAGE = 'ERROR_MESSAGE';
    public static final String FIELD_EXCEPTION_TYPE = 'EXCEPTION_TYPE';
    public static final String FIELD_EXCEPTION_MESSAGE = 'EXCEPTION_MESSAGE';
    public static final String FIELD_STACK_TRACE = 'STACK_TRACE';
    public static final String FIELD_LINE_NUMBER = 'LINE_NUMBER';
    public static final String FIELD_EXCEPTION_CATEGORY = 'EXCEPTION_CATEGORY';
    
    // Success & Status
    public static final String FIELD_SUCCESS = 'SUCCESS';
    public static final String FIELD_STATUS = 'STATUS';
    public static final String FIELD_RESULT = 'RESULT';
    
    // Entity Information
    public static final String FIELD_ENTITY = 'ENTITY';
    public static final String FIELD_ENTITY_NAME = 'ENTITY_NAME';
    public static final String FIELD_ENTRY_POINT = 'ENTRY_POINT';
    public static final String FIELD_ENTITY_TYPE = 'ENTITY_TYPE';
    public static final String FIELD_ENTITY_ID = 'ENTITY_ID';
    public static final String FIELD_OBJECT_TYPE = 'OBJECT_TYPE';
    public static final String FIELD_RECORD_ID = 'RECORD_ID';
    public static final String FIELD_RECORD_ID_DERIVED = 'RECORD_ID_DERIVED';
    public static final String FIELD_ACTUAL_LOGGED_IN_USER_ID = 'ACTUAL_LOGGED_IN_USER_ID';
    public static final String FIELD_REQUESTED_ACCESS_LEVEL = 'REQUESTED_ACCESS_LEVEL';
    public static final String FIELD_ERROR_TIMESTAMP = 'ERROR_TIMESTAMP';
    public static final String FIELD_ERROR_DESCRIPTION = 'ERROR_DESCRIPTION';
    public static final String FIELD_ACCESS_ERROR = 'ACCESS_ERROR';

    // DML
    public static final String FIELD_DML_TYPE = 'DML_TYPE';
    public static final String FIELD_KEY_PREFIX = 'KEY_PREFIX';
    public static final String FIELD_FIRST_ENTITY_ID = 'FIRST_ENTITY_ID';
    public static final String FIELD_NUM_ROWS = 'NUM_ROWS';
    public static final String FIELD_SAMPLE_FACTOR = 'SAMPLE_FACTOR';

    // Pricing
    public static final String FIELD_PRICING_API_ENDPOINT = 'PRICING_API_ENDPOINT';
    public static final String FIELD_PRICING_DETAILS = 'PRICING_DETAILS';
    public static final String FIELD_PRICING_ERROR_CODE = 'PRICING_ERROR_CODE';
    public static final String FIELD_PRICING_LOG_NAME = 'PRICING_LOG_NAME';
    public static final String FIELD_PRICING_PROCEDURE = 'PRICING_PROCEDURE';
    public static final String FIELD_PRICING_STATUS = 'PRICING_STATUS';

    // UI telemetry
    public static final String FIELD_INITIATOR_TYPE = 'INITIATOR_TYPE';
    public static final String FIELD_NAVIGATION_TYPE = 'NAVIGATION_TYPE';
    public static final String FIELD_RENDER_BLOCKING_STATUS = 'RENDER_BLOCKING_STATUS';
    public static final String FIELD_NEXT_HOP_PROTOCOL = 'NEXT_HOP_PROTOCOL';
    public static final String FIELD_DECODED_BODY_SIZE = 'DECODED_BODY_SIZE';
    public static final String FIELD_ENCODED_BODY_SIZE = 'ENCODED_BODY_SIZE';
    public static final String FIELD_RESPONSE_STATUS = 'RESPONSE_STATUS';
    public static final String FIELD_TRANSFER_SIZE = 'TRANSFER_SIZE';
    public static final String FIELD_CONNECT_END = 'CONNECT_END';
    public static final String FIELD_CONNECT_START = 'CONNECT_START';
    public static final String FIELD_REDIRECT_COUNT = 'REDIRECT_COUNT';
    public static final String FIELD_DOM_COMPLETE = 'DOM_COMPLETE';
    public static final String FIELD_DOM_CONTENT_LOADED_EVENT_START = 'DOM_CONTENT_LOADED_EVENT_START';
    public static final String FIELD_DOM_INTERACTIVE = 'DOM_INTERACTIVE';
    public static final String FIELD_DOMAIN_LOOKUP_END = 'DOMAIN_LOOKUP_END';
    public static final String FIELD_DOMAIN_LOOKUP_START = 'DOMAIN_LOOKUP_START';
    public static final String FIELD_FETCH_START = 'FETCH_START';
    public static final String FIELD_FIRST_INTERIM_RESPONSE_START = 'FIRST_INTERIM_RESPONSE_START';
    public static final String FIELD_LOAD_EVENT_END = 'LOAD_EVENT_END';
    public static final String FIELD_LOAD_EVENT_START = 'LOAD_EVENT_START';
    public static final String FIELD_REDIRECT_END = 'REDIRECT_END';
    public static final String FIELD_REDIRECT_START = 'REDIRECT_START';
    public static final String FIELD_RESPONSE_END = 'RESPONSE_END';
    public static final String FIELD_RESPONSE_START = 'RESPONSE_START';
    public static final String FIELD_REQUEST_START = 'REQUEST_START';
    public static final String FIELD_SERVER_REQUEST_ID = 'SERVER_REQUEST_ID';
    public static final String FIELD_SECURE_CONNECT_START = 'SECURE_CONNECT_START';
    public static final String FIELD_UNLOAD_EVENT_END = 'UNLOAD_EVENT_END';
    public static final String FIELD_UNLOAD_EVENT_START = 'UNLOAD_EVENT_START';
    public static final String FIELD_WORKER_START = 'WORKER_START';
    public static final String FIELD_UI_EVENT_RELATIVE_TIMESTAMP = 'UI_EVENT_RELATIVE_TIMESTAMP';
    public static final String FIELD_UI_ROOT_ACTIVITY_ID = 'UI_ROOT_ACTIVITY_ID';
    public static final String FIELD_UI_THREAD_RESPONSE_DELAY = 'UI_THREAD_RESPONSE_DELAY';
    public static final String FIELD_DOM_CONTENT_LOADED_EVENT_END = 'DOM_CONTENT_LOADED_EVENT_END';
    public static final String FIELD_POLICY_ID = 'POLICY_ID';
    public static final String FIELD_POLICY_ID_DERIVED = 'POLICY_ID_DERIVED';
    public static final String FIELD_EVENT_TIMESTAMP = 'EVENT_TIMESTAMP';
    public static final String FIELD_DELIVERY_ID = 'DELIVERY_ID';
    public static final String FIELD_DELIVERY_LOCATION = 'DELIVERY_LOCATION';
    public static final String FIELD_RELATED_ENTITY_ID = 'RELATED_ENTITY_ID';
    public static final String FIELD_NUMBER_REQUESTS = 'NUMBER_REQUESTS';
    public static final String FIELD_REQUESTS_LIMIT = 'REQUESTS_LIMIT';
    public static final String FIELD_SESSION_ID = 'SESSION_ID';

    // Callout
    public static final String FIELD_CALLOUT_TIME = 'CALLOUT_TIME';
    public static final String FIELD_EXECUTE_MS = 'EXECUTE_MS';
    public static final String FIELD_FETCH_MS = 'FETCH_MS';
    public static final String FIELD_TOTAL_MS = 'TOTAL_MS';
    public static final String FIELD_THROUGHPUT = 'THROUGHPUT';
    public static final String FIELD_USING_MRU = 'USING_MRU';
    public static final String FIELD_LIMIT = 'LIMIT';
    public static final String FIELD_FILTER = 'FILTER';
    public static final String FIELD_OFFSET = 'OFFSET';
    public static final String FIELD_ORDER_BY = 'ORDER_BY';
    public static final String FIELD_SELECT = 'SELECT';
    public static final String FIELD_SUBQUERIES = 'SUBQUERIES';
    public static final String FIELD_ROWS = 'ROWS';
    public static final String FIELD_ROWS_FETCHED = 'ROWS_FETCHED';
    public static final String FIELD_NEXT_LINK = 'NEXT_LINK';
    public static final String FIELD_PARENT_CALLOUT = 'PARENT_CALLOUT';
    public static final String FIELD_DATA_SOURCE_NAME = 'DATA_SOURCE_NAME';
    public static final String FIELD_PROVIDER_TYPE = 'PROVIDER_TYPE';
    public static final String FIELD_EXTERNAL_OBJECT = 'EXTERNAL_OBJECT';
    public static final String FIELD_TABLE_NAME = 'TABLE_NAME';
    public static final String FIELD_SEARCH = 'SEARCH';
    public static final String FIELD_RATE_LIMIT_USAGE_PERCENT = 'RATE_LIMIT_USAGE_PERCENT';
    public static final String FIELD_REQUESTS = 'REQUESTS';
    public static final String FIELD_LIBRARY = 'LIBRARY';
    public static final String FIELD_EXPAND = 'EXPAND';
    public static final String FIELD_BYTES = 'BYTES';

    // Sandbox
    public static final String FIELD_CURRENT_SANDBOX_ORG_ID = 'CURRENT_SANDBOX_ORG_ID';
    public static final String FIELD_PENDING_SANDBOX_ORG_ID = 'PENDING_SANDBOX_ORG_ID';
    public static final String FIELD_SANDBOX_ID = 'SANDBOX_ID';
    public static final String FIELD_CHANGE_SET_NAME = 'CHANGE_SET_NAME';
    public static final String FIELD_TARGET_ORG_ID = 'TARGET_ORG_ID';
    public static final String FIELD_JOB_STATUS = 'JOB_STATUS';
    public static final String FIELD_RECORDS_PROCESSED = 'RECORDS_PROCESSED';
    public static final String FIELD_RECORDS_FAILED = 'RECORDS_FAILED';
    public static final String FIELD_RESULT_SIZE_MB = 'RESULT_SIZE_MB';
    public static final String FIELD_CONNECTED_APP_NAME = 'CONNECTED_APP_NAME';

    // Search Click
    public static final String FIELD_NUM_RESULTS = 'NUM_RESULTS';
    public static final String FIELD_CLICKED_RECORD_ID = 'CLICKED_RECORD_ID';
    public static final String FIELD_RANK = 'RANK';
    public static final String FIELD_SEARCH_QUERY = 'SEARCH_QUERY';
    public static final String FIELD_PREFIXES_SEARCHED = 'PREFIXES_SEARCHED';

    // Login Event
    public static final String FIELD_AUTHENTICATION_METHOD_REFERENCE = 'AUTHENTICATION_METHOD_REFERENCE';
    public static final String FIELD_AUTHENTICATION_SERVICE_ID = 'AUTHENTICATION_SERVICE_ID';
    public static final String FIELD_LOGIN_SUB_TYPE = 'LOGIN_SUB_TYPE';
    public static final String FIELD_LOGIN_URL = 'LOGIN_URL';
    public static final String FIELD_SOURCE_IP = 'SOURCE_IP';
    public static final String FIELD_FORWARDED_FOR_IP = 'FORWARDED_FOR_IP';

    // B2B
    public static final String FIELD_B2B_EDITION = 'B2B_EDITION';
    public static final String FIELD_B2B_VERSION = 'B2B_VERSION';
    public static final String FIELD_WEB_STORE_ID = 'WEB_STORE_ID';
    public static final String FIELD_WEB_STORE_TYPE = 'WEB_STORE_TYPE';


    public static final String FIELD_IS_RETRY = 'IS_RETRY';
    public static final String FIELD_CONTEXT_ID = 'CONTEXT_ID';
    public static final String FIELD_COUNT = 'COUNT';
    public static final String FIELD_CONTEXT_MAP = 'CONTEXT_MAP';
    public static final String FIELD_EFFECTIVE_ACCOUNT_ID = 'EFFECTIVE_ACCOUNT_ID';
    public static final String FIELD_SERVICE_NAME = 'SERVICE_NAME';
    public static final String FIELD_NAMED_CREDENTIAL_NAME = 'NAMED_CREDENTIAL_NAME';
    public static final String FIELD_CALLER_PACKAGE_NAMESPACE = 'CALLER_PACKAGE_NAMESPACE';
    public static final String FIELD_CALLER_PACKAGE_VERSION = 'CALLER_PACKAGE_VERSION';
    public static final String FIELD_CALLER_PACKAGE_NAME = 'CALLER_PACKAGE_NAME';
    public static final String FIELD_MASTER_REPORT_ID = 'MASTER_REPORT_ID';
    public static final String FIELD_HAS_CHART = 'HAS_CHART';
    public static final String FIELD_DATA = 'DATA';
    public static final String FIELD_LOG_GROUP_ID = 'LOG_GROUP_ID';

    // Event Data classes
    
    public enum Success {
        TRUE_VALUE,
        FALSE_VALUE
    }

    // Enum for request status values
    public enum RequestStatus {
        BLANK,          // Empty or null value
        UNDEFINED,      // U - Undefined
        SUCCESS,        // S - Success
        FAILURE,        // F - Failure (4xx or 5xx HTTP codes)
        AUTH_ERROR,     // A - Authorization Error
        REDIRECT,       // R - Redirect (3xx HTTP codes)
        NOT_FOUND       // N - Not Found (404)
    }

    public static RequestStatus getRequestStatusValue(RequestStatus status) {
        return convertRequestStatus(status.name().left(1));
    }

    // Helper method to convert string status to enum
    private static RequestStatus convertRequestStatus(String statusRaw) {
        if (String.isBlank(statusRaw)) return RequestStatus.BLANK;
        
        switch on statusRaw.toUpperCase() {
            when 'S' { return RequestStatus.SUCCESS; }
            when 'F' { return RequestStatus.FAILURE; }
            when 'U' { return RequestStatus.UNDEFINED; }
            when 'A' { return RequestStatus.AUTH_ERROR; }
            when 'R' { return RequestStatus.REDIRECT; }
            when 'N' { return RequestStatus.NOT_FOUND; }
            when else { return RequestStatus.UNDEFINED; }
        }
    }

    // Enum for user license types
    public enum UserType {
        CSN_ONLY,              // Chatter Free and moderator users
        CSP_LITE_PORTAL,       // Customer portal/Experience Cloud users
        CUSTOMER_SUCCESS,      // Customer portal users
        GUEST,                 // Unauthenticated site users
        POWER_CUSTOMER_SUCCESS,// Power customer portal users
        POWER_PARTNER,         // Partner portal users
        SELF_SERVICE,          // Self-service portal users
        STANDARD,              // Standard, Platform, and admin users
        UNDEFINED              // Unknown or undefined type
    }

    // Helper method to convert string user type to enum
    public static UserType convertUserType(String userTypeRaw) {
        if (String.isBlank(userTypeRaw)) return UserType.UNDEFINED;
        
        switch on userTypeRaw {
            when 'CsnOnly' { return UserType.CSN_ONLY; }
            when 'CspLitePortal' { return UserType.CSP_LITE_PORTAL; }
            when 'CustomerSuccess' { return UserType.CUSTOMER_SUCCESS; }
            when 'Guest' { return UserType.GUEST; }
            when 'PowerCustomerSuccess' { return UserType.POWER_CUSTOMER_SUCCESS; }
            when 'PowerPartner' { return UserType.POWER_PARTNER; }
            when 'SelfService' { return UserType.SELF_SERVICE; }
            when 'Standard' { return UserType.STANDARD; }
            when else { return UserType.UNDEFINED; }
        }
    }

    // Enum for API types
    public enum ApiType {
        APEX_CLASS,         // D - Apex Class
        SOAP_ENTERPRISE,    // E - SOAP Enterprise
        SOAP_METADATA,      // M - SOAP Metadata
        SOAP_PARTNER,       // P - SOAP Partner
        SOAP_APEX,          // S - SOAP Apex
        SOAP_TOOLING,       // T - SOAP Tooling
        FEED,              // f - Feed
        LIVE_AGENT,        // l - Live Agent
        SOAP_CLIENT_SYNC,   // p - SOAP ClientSync
        UNDEFINED          // Unknown type
    }

    // Helper method to convert string API type to enum
    private static ApiType convertApiType(String apiTypeRaw) {
        if (String.isBlank(apiTypeRaw)) return ApiType.UNDEFINED;
        
        switch on apiTypeRaw {
            when 'D' { return ApiType.APEX_CLASS; }
            when 'E' { return ApiType.SOAP_ENTERPRISE; }
            when 'M' { return ApiType.SOAP_METADATA; }
            when 'P' { return ApiType.SOAP_PARTNER; }
            when 'S' { return ApiType.SOAP_APEX; }
            when 'T' { return ApiType.SOAP_TOOLING; }
            when 'f' { return ApiType.FEED; }
            when 'l' { return ApiType.LIVE_AGENT; }
            when 'p' { return ApiType.SOAP_CLIENT_SYNC; }
            when else { return ApiType.UNDEFINED; }
        }
    }

    // Enum for execution context types (Quiddity)
    public enum Quiddity {
        ACS_BATCH_APEX,           // A - ACS Batch Apex
        BULK_API,                 // B - Bulk API and Bulk API 2.0
        BATCH_APEX_START,         // BA - Start method of Batch Apex
        SCHEDULED_APEX,           // C - Scheduled Apex
        COMMERCE_INTEGRATION,     // CI - Commerce Integration
        DISCOVERABLE_LOGIN,       // DL - Discoverable Login page
        INBOUND_EMAIL,            // E - Inbound Email Service
        FUTURE,                   // F - Future
        FUNCTION_CALLBACK,        // FC - Function Callback
        APEX_REST,                // H - Apex REST
        INVOCABLE_ACTION,         // I - Invocable Action
        QUICK_ACTION,             // K - Quick Action
        LIGHTNING,                // L - Lightning
        REMOTE_ACTION,            // M - Remote Action
        PARALLEL_BATCH_APEX,      // P - Bulk Apex jobs in parallel
        PLATFORM_EVENT_CALLBACK,  // PEPC - Platform Event Publish Callback
        POST_INSTALL_SCRIPT,      // PI - Post install script
        QUEUEABLE,                // Q - Queueable
        QUEUEABLE_FINALIZER,      // QTXF - Transaction Finalizer
        SYNCHRONOUS,              // R - Synchronous uncategorized
        QUERY_LOCATOR_BATCH,      // S - QueryLocator Batch Apex
        TEST_ASYNC,               // TA - Tests Async
        TEST_DEPLOYMENT,          // TD - Tests Deployment
        TEST_SYNC,                // TS - Tests Synchronous
        UNDEFINED,                // UD - Undefined
        VISUALFORCE,              // V - Visualforce
        SOAP_WEB_SERVICES,        // W - SOAP Webservices
        EXECUTE_ANONYMOUS         // X - Execute Anonymous
    }

    // Helper method to convert string quiddity to enum
    private static Quiddity convertQuiddity(String quiddityStr) {
        if (String.isBlank(quiddityStr)) return Quiddity.UNDEFINED;
        
        switch on quiddityStr {
            when 'A' { return Quiddity.ACS_BATCH_APEX; }
            when 'B' { return Quiddity.BULK_API; }
            when 'BA' { return Quiddity.BATCH_APEX_START; }
            when 'C' { return Quiddity.SCHEDULED_APEX; }
            when 'CI' { return Quiddity.COMMERCE_INTEGRATION; }
            when 'DL' { return Quiddity.DISCOVERABLE_LOGIN; }
            when 'E' { return Quiddity.INBOUND_EMAIL; }
            when 'F' { return Quiddity.FUTURE; }
            when 'FC' { return Quiddity.FUNCTION_CALLBACK; }
            when 'H' { return Quiddity.APEX_REST; }
            when 'I' { return Quiddity.INVOCABLE_ACTION; }
            when 'K' { return Quiddity.QUICK_ACTION; }
            when 'L' { return Quiddity.LIGHTNING; }
            when 'M' { return Quiddity.REMOTE_ACTION; }
            when 'P' { return Quiddity.PARALLEL_BATCH_APEX; }
            when 'PEPC' { return Quiddity.PLATFORM_EVENT_CALLBACK; }
            when 'PI' { return Quiddity.POST_INSTALL_SCRIPT; }
            when 'Q' { return Quiddity.QUEUEABLE; }
            when 'QTXF' { return Quiddity.QUEUEABLE_FINALIZER; }
            when 'R' { return Quiddity.SYNCHRONOUS; }
            when 'S' { return Quiddity.QUERY_LOCATOR_BATCH; }
            when 'TA' { return Quiddity.TEST_ASYNC; }
            when 'TD' { return Quiddity.TEST_DEPLOYMENT; }
            when 'TS' { return Quiddity.TEST_SYNC; }
            when 'UD' { return Quiddity.UNDEFINED; }
            when 'V' { return Quiddity.VISUALFORCE; }
            when 'W' { return Quiddity.SOAP_WEB_SERVICES; }
            when 'X' { return Quiddity.EXECUTE_ANONYMOUS; }
            when else { return Quiddity.UNDEFINED; }
        }
    }

    // Enum for callout types
    public enum CalloutType {
        REST,          // REST callout
        AJAX,          // AJAX callout
        UNDEFINED      // Unknown type
    }

    // Helper method to convert string type to enum
    private static CalloutType convertCalloutType(String typeStr) {
        if (String.isBlank(typeStr)) return CalloutType.UNDEFINED;
        
        switch on typeStr.toUpperCase() {
            when 'REST' { return CalloutType.REST; }
            when 'AJAX' { return CalloutType.AJAX; }
            when else { return CalloutType.UNDEFINED; }
        }
    }

    public enum CalloutStatusCode {
        OK,
        CREATED,
        NO_CONTENT,
        BAD_REQUEST,
        UNAUTHORIZED,
        FORBIDDEN,
        NOT_FOUND,
        INTERNAL_SERVER_ERROR,
        SERVICE_UNAVAILABLE,
        UNDEFINED
    }

    public static CalloutStatusCode convertCalloutStatusCode(Integer statusCode) {
        if (statusCode == null) return CalloutStatusCode.UNDEFINED;
        
        switch on statusCode {
            when 200 { return CalloutStatusCode.OK; }
            when 201 { return CalloutStatusCode.CREATED; }
            when 204 { return CalloutStatusCode.NO_CONTENT; }
            when 400 { return CalloutStatusCode.BAD_REQUEST; }
            when 401 { return CalloutStatusCode.UNAUTHORIZED; }
            when 403 { return CalloutStatusCode.FORBIDDEN; }
            when 404 { return CalloutStatusCode.NOT_FOUND; }
            when 500 { return CalloutStatusCode.INTERNAL_SERVER_ERROR; }
            when 503 { return CalloutStatusCode.SERVICE_UNAVAILABLE; }
            when else { return CalloutStatusCode.UNDEFINED; }
        }
    }

    // Enums for report execution context
    public enum DisplayType {
        DASHBOARD,      // D - Dashboard
        SHOW_DETAILS,   // S - Show Details
        HIDE_DETAILS,   // H - Hide Details
        UNDEFINED       // Unknown type
    }

    public enum RenderingType {
        WEB,           // W - Web (HTML)
        EMAIL,         // E - Email
        PRINTABLE,     // P - Printable
        EXCEL,         // X - Excel
        CSV,           // C - Comma-separated values
        JSON,          // J - JavaScript Object Notation
        DUMMY_DATA,    // D - Dummy data
        UNDEFINED      // Unknown type
    }

    public enum Origin {
        MOBILE_DASHBOARD,                   // ReportOpenedFromMobileDashboard
        DASHBOARD_COMPONENT_UPDATED,        // DashboardComponentUpdated
        DASHBOARD_COMPONENT_PREVIEW,        // DashboardComponentPreviewed
        SYNC_API,                           // ReportRunUsingSynchronousApi
        ASYNC_API,                          // ReportRunUsingAsynchronousApi
        APEX_SYNC_API,                      // ReportRunUsingApexSynchronousApi
        APEX_ASYNC_API,                     // ReportRunUsingApexAsynchronousApi
        EXPORTED,                           // ReportExported
        CLASSIC,                            // ReportRunFromClassic
        MOBILE,                             // ReportRunFromMobile
        LIGHTNING,                          // ReportRunFromLightning
        REST_API,                           // ReportRunFromRestApi
        PREVIEW,                            // ReportPreviewed
        SCHEDULED,                          // ReportScheduled
        PROBE_QUERY,                        // ProbeQuery
        REPORTING_SNAPSHOT,                 // ReportRunFromReportingSnapshot
        ASYNC_EXPORT,                       // ReportExportedAsynchronously
        EXCEL_CONNECTOR,                    // ReportExportedUsingExcelConnector
        VF_CHART,                           // ChartRenderedOnVisualforcePage
        EMBEDDED_ANALYTICS,                 // ChartRenderedInEmbeddedAnalyticsApp
        NOTIFICATION,                       // ReportRunAndNotificationSent
        HOME_PAGE_CHART,                    // ChartRenderedOnHomePage
        WAVE_TRENDING,                      // ReportResultsAddedToWaveTrending
        CAMPAIGN,                           // ReportAddedToCampaign
        EINSTEIN_DISCOVERY,                 // ReportResultsAddedToEinsteinDiscovery
        UNKNOWN,                            // Unknown
        TEST                                // Test
    }

    private static Origin convertOrigin(String originRaw) {
        if (String.isBlank(originRaw)) return Origin.UNKNOWN;
        
        switch on originRaw {
            when 'ReportOpenedFromMobileDashboard' { return Origin.MOBILE_DASHBOARD; }
            when 'DashboardComponentUpdated' { return Origin.DASHBOARD_COMPONENT_UPDATED; }
            when 'DashboardComponentPreviewed' { return Origin.DASHBOARD_COMPONENT_PREVIEW; }
            when 'ReportRunUsingSynchronousApi' { return Origin.SYNC_API; }
            when 'ReportRunUsingAsynchronousApi' { return Origin.ASYNC_API; }
            when 'ReportRunUsingApexSynchronousApi' { return Origin.APEX_SYNC_API; }
            when 'ReportRunUsingApexAsynchronousApi' { return Origin.APEX_ASYNC_API; }
            when 'ReportExported' { return Origin.EXPORTED; }
            when 'ReportRunFromClassic' { return Origin.CLASSIC; }
            when 'ReportRunFromMobile' { return Origin.MOBILE; }
            when 'ReportRunFromLightning' { return Origin.LIGHTNING; }
            when 'ReportRunFromRestApi' { return Origin.REST_API; }
            when 'ReportPreviewed' { return Origin.PREVIEW; }
            when 'ReportScheduled' { return Origin.SCHEDULED; }
            when 'ProbeQuery' { return Origin.PROBE_QUERY; }
            when 'ReportRunFromReportingSnapshot' { return Origin.REPORTING_SNAPSHOT; }
            when 'ReportExportedAsynchronously' { return Origin.ASYNC_EXPORT; }
            when 'ReportExportedUsingExcelConnector' { return Origin.EXCEL_CONNECTOR; }
            when 'ChartRenderedOnVisualforcePage' { return Origin.VF_CHART; }
            when 'ChartRenderedInEmbeddedAnalyticsApp' { return Origin.EMBEDDED_ANALYTICS; }
            when 'ReportRunAndNotificationSent' { return Origin.NOTIFICATION; }
            when 'ChartRenderedOnHomePage' { return Origin.HOME_PAGE_CHART; }
            when 'ReportResultsAddedToWaveTrending' { return Origin.WAVE_TRENDING; }
            when 'ReportAddedToCampaign' { return Origin.CAMPAIGN; }
            when 'ReportResultsAddedToEinsteinDiscovery' { return Origin.EINSTEIN_DISCOVERY; }
            when 'Test' { return Origin.TEST; }
            when else { return Origin.UNKNOWN; }
        }
    }

    // Helper methods for type conversion
    private static DisplayType convertDisplayType(String displayTypeRaw) {
        if (String.isBlank(displayTypeRaw)) return DisplayType.UNDEFINED;
        
        switch on displayTypeRaw {
            when 'D' { return DisplayType.DASHBOARD; }
            when 'S' { return DisplayType.SHOW_DETAILS; }
            when 'H' { return DisplayType.HIDE_DETAILS; }
            when else { return DisplayType.UNDEFINED; }
        }
    }

    private static RenderingType convertRenderingType(String renderingTypeRaw) {
        if (String.isBlank(renderingTypeRaw)) return RenderingType.UNDEFINED;
        
        switch on renderingTypeRaw {
            when 'W' { return RenderingType.WEB; }
            when 'E' { return RenderingType.EMAIL; }
            when 'P' { return RenderingType.PRINTABLE; }
            when 'X' { return RenderingType.EXCEL; }
            when 'C' { return RenderingType.CSV; }
            when 'J' { return RenderingType.JSON; }
            when 'D' { return RenderingType.DUMMY_DATA; }
            when else { return RenderingType.UNDEFINED; }
        }
    }

     // Enum for trigger types
     public enum TriggerType {
        AFTER_INSERT,
        AFTER_UPDATE,
        BEFORE_INSERT,
        BEFORE_UPDATE,
        UNDEFINED
    }

    // Helper method to convert string trigger type to enum
    private static TriggerType convertTriggerType(String triggerTypeRaw) {
        if (String.isBlank(triggerTypeRaw)) return TriggerType.UNDEFINED;
        
        switch on triggerTypeRaw {
            when 'AfterInsert' { return TriggerType.AFTER_INSERT; }
            when 'AfterUpdate' { return TriggerType.AFTER_UPDATE; }
            when 'BeforeInsert' { return TriggerType.BEFORE_INSERT; }
            when 'BeforeUpdate' { return TriggerType.BEFORE_UPDATE; }
            when else { return TriggerType.UNDEFINED; }
        }
    }

    // Enum for common limit exception categories
    public enum LimitExceptionCategory {
        CPU_TIME,
        HEAP_SIZE,
        SOQL_QUERIES,
        QUERY_ROWS,
        DML_STATEMENTS,
        CALLOUTS,
        CUSTOM_EXCEPTION,
        OTHER,
        UNDEFINED
    }

    // Helper method to parse limit exception category
    private static LimitExceptionCategory parseLimitExceptionCategory(String category) {
        if (String.isBlank(category)) return LimitExceptionCategory.UNDEFINED;
        
        if (category.startsWith('LimitException:')) {
            String limitType = category.substringAfter('LimitException:').trim();
            switch on limitType {
                when 'CpuTime' { return LimitExceptionCategory.CPU_TIME; }
                when 'HeapSize' { return LimitExceptionCategory.HEAP_SIZE; }
                when 'Queries' { return LimitExceptionCategory.SOQL_QUERIES; }
                when 'QueryRows' { return LimitExceptionCategory.QUERY_ROWS; }
                when 'DmlStatements' { return LimitExceptionCategory.DML_STATEMENTS; }
                when 'Callouts' { return LimitExceptionCategory.CALLOUTS; }
                when else { return LimitExceptionCategory.OTHER; }
            }
        } else if (category == 'CustomException') {
            return LimitExceptionCategory.CUSTOM_EXCEPTION;
        }
        
        return LimitExceptionCategory.OTHER;
    }

    // Enum for API families
    public enum ApiFamily {
        REST_API,
        SOAP_API,
        BULK_API,
        UNDEFINED
    }

    // Helper method to convert string API family to enum
    private static ApiFamily convertApiFamily(String apiFamilyRaw) {
        if (String.isBlank(apiFamilyRaw)) return ApiFamily.UNDEFINED;
        
        switch on apiFamilyRaw.toUpperCase() {
            when 'REST' { return ApiFamily.REST_API; }
            when 'SOAP' { return ApiFamily.SOAP_API; }
            when 'BULK' { return ApiFamily.BULK_API; }
            when else { return ApiFamily.UNDEFINED; }
        }
    }

    public enum ChangeSetOperationType {
        DELETE_TYPE,
        DEPLOY_TYPE,
        UPLOAD_TYPE,
        VALIDATE_TYPE,
        UNDEFINED
    }

    private static ChangeSetOperationType convertChangeSetOperation(String operationTypeRaw) {
        if (String.isBlank(operationTypeRaw)) return ChangeSetOperationType.UNDEFINED;
        
        switch on operationTypeRaw {
            when 'DELETE' { return ChangeSetOperationType.DELETE_TYPE; }
            when 'DEPLOY' { return ChangeSetOperationType.DEPLOY_TYPE; }
            when 'UPLOAD' { return ChangeSetOperationType.UPLOAD_TYPE; }
            when 'VALIDATE' { return ChangeSetOperationType.VALIDATE_TYPE; }
            when else { return ChangeSetOperationType.UNDEFINED; }
        }
    }

    public enum ContentDistributionAction {
        VIEW_ACTION,
        INSERT_ACTION,
        UPDATE_ACTION,
        UNDEFINED
    }

    private static ContentDistributionAction convertContentDistributionAction(String actionRaw) {
        if (String.isBlank(actionRaw)) return ContentDistributionAction.UNDEFINED;
        
        switch on actionRaw {
            when 'VIEW' { return ContentDistributionAction.VIEW_ACTION; }
            when 'INSERT' { return ContentDistributionAction.INSERT_ACTION; }
            when 'UPDATE' { return ContentDistributionAction.UPDATE_ACTION; }
            when else { return ContentDistributionAction.UNDEFINED; }
        }
    }

    public enum SharingOperationType {
        INSERT_TYPE,
        UPDATE_TYPE,
        DELETE_TYPE,
        UNDEFINED
    }

    private static SharingOperationType convertSharingOperationType(String operationTypeRaw) {
        if (String.isBlank(operationTypeRaw)) return SharingOperationType.UNDEFINED;
        
        switch on operationTypeRaw {
            when 'INSERT' { return SharingOperationType.INSERT_TYPE; }
            when 'UPDATE' { return SharingOperationType.UPDATE_TYPE; }
            when 'DELETE' { return SharingOperationType.DELETE_TYPE; }
            when else { return SharingOperationType.UNDEFINED; }
        }
    }

    public enum SharingPermissionType {
        VIEWER,
        COLLABORATOR,
        INFERRED,
        UNDEFINED
    }

    private static SharingPermissionType convertSharingPermissionType(String permissionTypeRaw) {
        if (String.isBlank(permissionTypeRaw)) return SharingPermissionType.UNDEFINED;
        
        switch on permissionTypeRaw {
            when 'V' { return SharingPermissionType.VIEWER; }
            when 'C' { return SharingPermissionType.COLLABORATOR; }
            when 'I' { return SharingPermissionType.INFERRED; }
            when else { return SharingPermissionType.UNDEFINED; }
        }
    }

    public enum ContentTransferTransactionType {
        VERSION_DOWNLOAD_ACTION,
        VERSION_DOWNLOAD_API,
        VERSION_RENDITION_DOWNLOAD,
        UNDEFINED
    }

    private static ContentTransferTransactionType convertContentTransferTransactionType(String transactionTypeRaw) {
        if (String.isBlank(transactionTypeRaw)) return ContentTransferTransactionType.UNDEFINED;
        
        switch on transactionTypeRaw {
            when 'VersionDownloadAction' { return ContentTransferTransactionType.VERSION_DOWNLOAD_ACTION; }
            when 'VersionDownloadApi' { return ContentTransferTransactionType.VERSION_DOWNLOAD_API; }
            when 'VersionRenditionDownload' { return ContentTransferTransactionType.VERSION_RENDITION_DOWNLOAD; }
            when else { return ContentTransferTransactionType.UNDEFINED; }
        }
    }

    public enum ContinuationCalloutStatusCode {
        TIMEOUT_REACHED,
        CONNECTION_FAILURE,
        EXCEPTION_OCCURRED,
        RESPONSE_NOT_ARRIVED,
        RESPONSE_SIZE_TOO_LARGE,
        SUCCESS,
        UNKNOWN
    }

    private static ContinuationCalloutStatusCode convertContinuationCalloutStatusCode(String statusCodeRaw) {
        if (String.isBlank(statusCodeRaw)) return ContinuationCalloutStatusCode.UNKNOWN;
        
        switch on statusCodeRaw {
            when '2000' { return ContinuationCalloutStatusCode.TIMEOUT_REACHED; }
            when '2001' { return ContinuationCalloutStatusCode.CONNECTION_FAILURE; }
            when '2002' { return ContinuationCalloutStatusCode.EXCEPTION_OCCURRED; }
            when '2003' { return ContinuationCalloutStatusCode.RESPONSE_NOT_ARRIVED; }
            when '2004' { return ContinuationCalloutStatusCode.RESPONSE_SIZE_TOO_LARGE; }
            when '200' { return ContinuationCalloutStatusCode.SUCCESS; }
            when else { return ContinuationCalloutStatusCode.UNKNOWN; }
        }
    }

    public enum CspViolationDisposition {
        ENFORCE,
        REPORT,
        UNDEFINED
    }

    private static CspViolationDisposition convertCspViolationDisposition(String dispositionRaw) {
        if (String.isBlank(dispositionRaw)) return CspViolationDisposition.UNDEFINED;
        
        switch on dispositionRaw {
            when 'enforce' { return CspViolationDisposition.ENFORCE; }
            when 'report' { return CspViolationDisposition.REPORT; }
            when else { return CspViolationDisposition.UNDEFINED; }
        }
    }

    public enum DashboardType {
        RUN_AS_RUNNING_USER,
        RUN_AS_CONTEXT_USER,
        RUN_AS_SPECIFIC_USER,
        UNDEFINED
    }

    private static DashboardType convertDashboardType(String dashboardTypeRaw) {
        if (String.isBlank(dashboardTypeRaw)) return DashboardType.UNDEFINED;
        
        switch on dashboardTypeRaw {
            when 'R' { return DashboardType.RUN_AS_RUNNING_USER; }
            when 'C' { return DashboardType.RUN_AS_CONTEXT_USER; }
            when 'S' { return DashboardType.RUN_AS_SPECIFIC_USER; }
            when else { return DashboardType.UNDEFINED; }
        }
    }

    // Enum for Metadata API Operation types
    public enum MetadataApiOperationType {
        META_DEPLOY,
        META_LIST,
        META_RETRIEVE,
        META_SYNCHRONOUS_CREATE,
        META_SYNCHRONOUS_READ,
        META_SYNCHRONOUS_UPSERT,
        UNDEFINED
    }

    private static MetadataApiOperationType convertMetadataApiOperationType(String operationTypeRaw) {
        if (String.isBlank(operationTypeRaw)) return MetadataApiOperationType.UNDEFINED;
        
        switch on operationTypeRaw {
            when 'meta_deploy' { return MetadataApiOperationType.META_DEPLOY; }
            when 'meta_list' { return MetadataApiOperationType.META_LIST; }
            when 'meta_retrieve' { return MetadataApiOperationType.META_RETRIEVE; }
            when 'meta_synchronous_create' { return MetadataApiOperationType.META_SYNCHRONOUS_CREATE; }
            when 'meta_synchronous_read' { return MetadataApiOperationType.META_SYNCHRONOUS_READ; }
            when 'meta_synchronous_upsert' { return MetadataApiOperationType.META_SYNCHRONOUS_UPSERT; }
            when else { return MetadataApiOperationType.UNDEFINED; }
        }
    }

    public enum PackageOperationType {
        INSTALL,
        UPGRADE,
        EXPORT_TYPE,
        UNINSTALL,
        VALIDATE_PACKAGE,
        INIT_EXPORT_PKG_CONTROLLER,
        UNDEFINED
    }

    private static PackageOperationType convertPackageOperationType(String operationTypeRaw) {
        if (String.isBlank(operationTypeRaw)) return PackageOperationType.UNDEFINED;
        
        switch on operationTypeRaw {
            when 'INSTALL' { return PackageOperationType.INSTALL; }
            when 'UPGRADE' { return PackageOperationType.UPGRADE; }
            when 'EXPORT' { return PackageOperationType.EXPORT_TYPE; }
            when 'UNINSTALL' { return PackageOperationType.UNINSTALL; }
            when 'VALIDATE_PACKAGE' { return PackageOperationType.VALIDATE_PACKAGE; }
            when 'INIT_EXPORT_PKG_CONTROLLER' { return PackageOperationType.INIT_EXPORT_PKG_CONTROLLER; }
            when else { return PackageOperationType.UNDEFINED; }
        }
    }

    // Enum for Asset Types
    public enum InsecureAssetType {
        BASE_URI,
        CONNECT,
        FONT,
        FRAME_ANCESTOR,
        FRAME,
        IMAGE,
        MEDIA,
        OBJECT_TYPE,
        OTHER,
        PLUGIN_TYPES,
        SCRIPT,
        STYLE
    }

    private static InsecureAssetType convertInsecureAssetType(String assetTypeRaw) {
        if (String.isBlank(assetTypeRaw)) return InsecureAssetType.OTHER;
        
        switch on assetTypeRaw {
            when 'Base URI' { return InsecureAssetType.BASE_URI; }
            when 'Connect' { return InsecureAssetType.CONNECT; }
            when 'Font' { return InsecureAssetType.FONT; }
            when 'Frame Ancestor' { return InsecureAssetType.FRAME_ANCESTOR; }
            when 'Frame' { return InsecureAssetType.FRAME; }
            when 'Image' { return InsecureAssetType.IMAGE; }
            when 'Media' { return InsecureAssetType.MEDIA; }
            when 'Object' { return InsecureAssetType.OBJECT_TYPE; }
            when 'Plugin Types' { return InsecureAssetType.PLUGIN_TYPES; }
            when 'Script' { return InsecureAssetType.SCRIPT; }
            when 'Style' { return InsecureAssetType.STYLE; }
            when else { return InsecureAssetType.OTHER; }
        }
    }

    // Enum for Page Types
    public enum InsecurePageType {
        APPSERVER,      // Page without My Domain
        COMMUNITIES,    // Experience Cloud site
        EMAIL,          // Email preview
        LOGIN,          // Login page
        MYDOMAIN,       // Page on My Domain
        SITES,          // Customer site
        STATIC_CONTENT, // Static content
        UNKNOWN         // Other type
    }

    private static InsecurePageType convertInsecurePageType(String pageTypeRaw) {
        if (String.isBlank(pageTypeRaw)) return InsecurePageType.UNKNOWN;
        
        switch on pageTypeRaw {
            when 'Appserver' { return InsecurePageType.APPSERVER; }
            when 'Communities' { return InsecurePageType.COMMUNITIES; }
            when 'Email' { return InsecurePageType.EMAIL; }
            when 'Login' { return InsecurePageType.LOGIN; }
            when 'Mydomain' { return InsecurePageType.MYDOMAIN; }
            when 'Sites' { return InsecurePageType.SITES; }
            when 'Static' { return InsecurePageType.STATIC_CONTENT; }
            when else { return InsecurePageType.UNKNOWN; }
        }
    }

    // Enum for CSP Disposition
    public enum CSPDisposition {
        ENFORCE,     // Content-Security-Policy header
        REPORT,      // Content-Security-Policy-Report-Only header
        UNDEFINED
    }

    private static CSPDisposition convertCSPDisposition(String dispositionRaw) {
        if (String.isBlank(dispositionRaw)) return CSPDisposition.UNDEFINED;
        
        switch on dispositionRaw {
            when 'enforce' { return CSPDisposition.ENFORCE; }
            when 'report' { return CSPDisposition.REPORT; }
            when else { return CSPDisposition.UNDEFINED; }
        }
    }

    // Enum for Access Error Types
    public enum AccessErrorType {
        DATA_NOT_AVAILABLE,  // Record no longer accessible
        INVALID_TYPE,        // Record type doesn't exist
        NO_ACCESS           // User lacks required access level
    }

    private static AccessErrorType convertAccessErrorType(String errorTypeRaw) {
        if (String.isBlank(errorTypeRaw)) return AccessErrorType.NO_ACCESS;
        
        switch on errorTypeRaw {
            when 'DATA_NOT_AVAILABLE' { return AccessErrorType.DATA_NOT_AVAILABLE; }
            when 'INVALID_TYPE' { return AccessErrorType.INVALID_TYPE; }
            when 'NO_ACCESS' { return AccessErrorType.NO_ACCESS; }
            when else { return AccessErrorType.NO_ACCESS; }
        }
    }

    // Enum for Required Access Levels
    public enum RequiredAccessLevel {
        DELETE_LEVEL,
        FULL_LEVEL,
        READ_LEVEL,
        TRANSFER_LEVEL,
        WRITE_LEVEL,
        UNDEFINED
    }

    private static RequiredAccessLevel convertRequiredAccessLevel(String accessLevelRaw) {
        if (String.isBlank(accessLevelRaw)) return RequiredAccessLevel.UNDEFINED;
        
        switch on accessLevelRaw {
            when 'DELETE' { return RequiredAccessLevel.DELETE_LEVEL; }
            when 'FULL' { return RequiredAccessLevel.FULL_LEVEL; }
            when 'READ' { return RequiredAccessLevel.READ_LEVEL; }
            when 'TRANSFER' { return RequiredAccessLevel.TRANSFER_LEVEL; }
            when 'WRITE' { return RequiredAccessLevel.WRITE_LEVEL; }
            when else { return RequiredAccessLevel.UNDEFINED; }
        }
    }

    // Event Data Classes
    //---------------------------------

    public class BlockedRedirectData extends BaseEventData {
        public String eventType = EVENT_TYPE_BLOCKED_REDIRECT;
        // URI Information
        public String blockedUri { get; private set; }         // BLOCKED_URI: Full target URL that was blocked
        public String blockedUriDomain { get; private set; }   // BLOCKED_URI_DOMAIN: Domain of blocked URL
        
        // Request Details
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String origin { get; private set; }             // ORIGIN: Origin that caused the request
        public String referrer { get; private set; }           // REFERRER: Address from which request came
        
        // URL Validation
        public Boolean malformedUrl { get; private set; }      // MALFORMED_URL: If URL failed syntax check
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public BlockedRedirectData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class AuraRequestData extends BaseEventData {
        public String eventType = EVENT_TYPE_AURA_REQUEST;
        // Action details
        public String actionMessage { get; private set; }      // ACTION_MESSAGE: Action names and times
        
        // Request information
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String requestMethod { get; private set; }      // REQUEST_METHOD: HTTP method (GET/POST)
        public String requestStatus { get; private set; }      // REQUEST_STATUS: Request status (S/F/U/A/R/N)
        public RequestStatus requestStatusEnum { get; private set; }
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time in milliseconds
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: Database time in nanoseconds
        public Integer runTime { get; private set; }           // RUN_TIME: Total request time in milliseconds
        
        // URI information
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        public Integer userAgent { get; private set; }         // USER_AGENT: Client type code
        
        // User information
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }           // USER_TYPE: User license category
        public UserType userTypeEnum { get; private set; }
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public AuraRequestData(Map<String, Object> eventData) {
            super(eventData);
            
            this.requestStatusEnum = convertRequestStatus(requestStatus);
            this.userTypeEnum = convertUserType(userType);
        }
    }

    public class ApiTotalUsageData extends BaseEventData {
        public String eventType = EVENT_TYPE_API_TOTAL_USAGE;
        // API identification
        public String apiFamily { get; private set; }          // API_FAMILY: Raw API family string
        public ApiFamily apiFamilyEnum { get; private set; }   // API_FAMILY: Parsed enum
        public String apiResource { get; private set; }        // API_RESOURCE: API method/resource
        public Integer apiVersion { get; private set; }        // API_VERSION: API version number
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        public String clientName { get; private set; }         // CLIENT_NAME: Client name
        public String connectedAppId { get; private set; }     // CONNECTED_APP_ID: Connected app ID
        public String connectedAppName { get; private set; }   // CONNECTED_APP_NAME: Connected app name
        
        // Request details
        public String httpMethod { get; private set; }         // HTTP_METHOD: HTTP method
        public Integer statusCode { get; private set; }        // STATUS_CODE: HTTP status code
        public Boolean countsAgainstApiLimit { get; private set; } // COUNTS_AGAINST_API_LIMIT
        public String entityName { get; private set; }         // ENTITY_NAME: Accessed objects
        
        // User information
        public String userName { get; private set; }           // USER_NAME: Username
        
        // Transaction information
        public String requestId { get; private set; }          // REQUEST_ID: Transaction ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ApiTotalUsageData(Map<String, Object> eventData) {
            super(eventData);
            
            this.apiFamilyEnum = convertApiFamily(this.apiFamily);
        }
    }

    public class ApexUnexpectedExceptionData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        // Exception details
        public String exceptionCategory { get; private set; }      // EXCEPTION_CATEGORY: Exception category
        public LimitExceptionCategory limitCategory { get; private set; } // Parsed limit category
        public String exceptionMessage { get; private set; }       // EXCEPTION_MESSAGE: Exception message
        public String exceptionType { get; private set; }          // EXCEPTION_TYPE: Exception class type
        public String stackTrace { get; private set; }             // STACK_TRACE: Exception stack trace
        
        // Transaction information
        public String requestId { get; private set; }              // REQUEST_ID: Unique transaction ID
        public String organizationId { get; private set; }         // ORGANIZATION_ID: 15-char org ID
        public String userIdDerived { get; private set; }         // USER_ID_DERIVED: 18-char user ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; }     // TIMESTAMP_DERIVED: ISO8601 time
        
        // Hash for deduplication testing
        public String hash1 { get; private set; }                  // HASH_1: Pre-calculated hash for test deduplication

        public ApexUnexpectedExceptionData(Map<String, Object> eventData) {
            super(eventData);
            
            this.limitCategory = parseLimitExceptionCategory(exceptionCategory);
            
            // If base timestamp is null but we have timestampDerived, use that
            if (this.timestamp == null && this.timestampDerived != null) {
                this.timestamp = this.timestampDerived;
            }
        }
    }

    public class ApexCalloutData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_CALLOUT;
        // Required fields
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String userId { get; private set; }             // USER_ID: 15-character user ID
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-character user ID
        
        // Callout details
        public String method { get; private set; }             // METHOD: HTTP method (GET, POST, etc.)
        public String type { get; private set; }               // TYPE: Raw callout type
        public CalloutType typeEnum { get; private set; }      // TYPE: Parsed callout type enum
        public String url { get; private set; }                // URL: Callout endpoint URL
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time used (ms)
        public Integer requestSize { get; private set; }       // REQUEST_SIZE: Request body size (bytes)
        public Integer responseSize { get; private set; }      // RESPONSE_SIZE: Response size (bytes)
        public Integer timeValue { get; private set; }         // TIME: Request duration (ms)
        public Integer statusCode { get; private set; }        // STATUS_CODE: HTTP status code
        public CalloutStatusCode statusCodeEnum { get; private set; }
        public String success { get; private set; }           // SUCCESS: If callout completed (1/0)
        
        // Request information
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ApexCalloutData(Map<String, Object> eventData) {
            super(eventData);
            
            this.typeEnum = convertCalloutType(this.type);
            this.statusCodeEnum = convertCalloutStatusCode(this.statusCode);
        }
    }

    public class SOAPAPIEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_API;
        // Required fields
        public String requestId { get; private set; }           // REQUEST_ID: Unique transaction ID
        public String apiType { get; private set; }             // API_TYPE: Raw API type value
        public ApiType apiTypeEnum { get; private set; }        // API_TYPE: Parsed API type enum
        
        // API Details
        public String apiVersion { get; private set; }         // API_VERSION: API version used
        public String entityName { get; private set; }         // ENTITY_NAME: Object accessed
        public String methodName { get; private set; }         // METHOD_NAME: Calling method name
        public String exceptionMessage { get; private set; }   // EXCEPTION_MESSAGE: Error details
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time used (ms)
        public Integer dbBlocks { get; private set; }          // DB_BLOCKS: Database block usage
        public Integer dbCpuTime { get; private set; }         // DB_CPU_TIME: Database CPU time (ms)
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: Total DB time (ns)
        public Integer requestSize { get; private set; }       // REQUEST_SIZE: Request body size (bytes)
        public Integer responseSize { get; private set; }      // RESPONSE_SIZE: Response size (bytes)
        public Integer rowsProcessed { get; private set; }     // ROWS_PROCESSED: Number of rows processed
        public Integer runTime { get; private set; }           // RUN_TIME: Total request time (ms)
        
        // Request information
        public String requestStatus { get; private set; }      // REQUEST_STATUS: Request status
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        public String clientName { get; private set; }         // CLIENT_NAME: Client name
        public String userType { get; private set; }           // USER_TYPE: User license category
        
        // User information
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-char user ID
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public SOAPAPIEventData(Map<String, Object> eventData) {
            super(eventData);

            this.apiTypeEnum = convertApiType(this.apiType);
        }
    }
    
    public class ApexSOAPApiEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_SOAP;
        // Required fields
        public String requestId { get; private set; }          // REQUEST_ID: Unique ID for transaction
        public String userId { get; private set; }             // USER_ID: 15-character user ID
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-character user ID
        
        // API Details
        public String className { get; private set; }          // CLASS_NAME: Apex class name (including namespace)
        public String methodName { get; private set; }         // METHOD_NAME: Name of calling Apex method
        public String query { get; private set; }              // QUERY: SOQL query if performed
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time used (ms)
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: Database processing time (ms)
        public Integer runTime { get; private set; }           // RUN_TIME: Total request time (ms)
        public Decimal limitUsagePercent { get; private set; } // LIMIT_USAGE_PERCENT: Percentage of Apex SOAP calls used
        
        // Request information
        public String requestStatus { get; private set; }      // REQUEST_STATUS: Status of request (S/F/U/A/R/N)
        public RequestStatus requestStatusEnum { get; private set; }
        public String uri { get; private set; }                // URI: URI of the request
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-character URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: IP address of client
        public String clientName { get; private set; }         // CLIENT_NAME: Name of client using services
        public String userType { get; private set; }           // USER_TYPE: Category of user license
        public UserType userTypeEnum { get; private set; }
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Ties together events in login session
        public String sessionKey { get; private set; }         // SESSION_KEY: User's unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-character org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: Access time in ISO8601 format

        public ApexSOAPApiEventData(Map<String, Object> eventData) {
            super(eventData);

            this.requestStatusEnum = convertRequestStatus(requestStatus);
            this.userTypeEnum = convertUserType(userType);
        }
    }
    
    public class ApexExecutionData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_EXECUTION;
        // Required fields
        public String requestId { get; private set; }          // REQUEST_ID: Unique ID for transaction
        public String quiddity { get; private set; }           // QUIDDITY: Type of outer execution
        public Quiddity quiddityEnum { get; private set; }
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-character user ID
        
        // Timing metrics
        public Integer calloutTime { get; private set; }       // CALLOUT_TIME: Time spent on webservice callouts (ms)
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time used for request (ms)
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: Time spent on database operations (ms)
        public Integer execTime { get; private set; }          // EXEC_TIME: End-to-end Apex execution time (ms)
        public Integer runTime { get; private set; }           // RUN_TIME: Total request time (ms)
        
        // Execution context
        public String entryPoint { get; private set; }         // ENTRY_POINT: Entry point for Apex execution
        public Boolean isLongRunningRequest { get; private set; } // IS_LONG_RUNNING_REQUEST: If request counts against long-running limit
        public Integer numberSoqlQueries { get; private set; } // NUMBER_SOQL_QUERIES: Number of SOQL queries executed
        
        // Organization and URI info
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-character org ID
        public String uri { get; private set; }                // URI: URI of the page receiving request
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-character URI ID
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Ties together events in login session
        public String sessionKey { get; private set; }         // SESSION_KEY: User's unique session ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: IP address of client
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: Access time in ISO8601 format

        public ApexExecutionData(Map<String, Object> eventData) {
            super(eventData);

            this.quiddityEnum = convertQuiddity(this.quiddity);
        }
    }

    public class LogoutEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_LOGOUT;
        // API Information
        public String apiType { get; private set; }          // API_TYPE: API request type
        public String apiVersion { get; private set; }       // API_VERSION: API version
        
        // Application Information
        public Integer appType { get; private set; }         // APP_TYPE: Application type
        public Integer clientVersion { get; private set; }   // CLIENT_VERSION: Client version
        public Integer platformType { get; private set; }    // PLATFORM_TYPE: Client platform
        public Integer resolutionType { get; private set; }  // RESOLUTION_TYPE: Screen resolution
        
        // Session Information
        public String requestId { get; private set; }        // REQUEST_ID: Unique transaction ID
        public String sessionKey { get; private set; }       // SESSION_KEY: User's unique session ID
        public String loginKey { get; private set; }        // LOGIN_KEY: Session event chain
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        public String sessionLevel { get; private set; }     // SESSION_LEVEL: Security level
        public String sessionType { get; private set; }      // SESSION_TYPE: Session type
        public Boolean userInitiatedLogout { get; private set; } // USER_INITIATED_LOGOUT
        
        // Client Information
        public String browserType { get; private set; }      // BROWSER_TYPE: Browser identifier
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userName { get; private set; }         // USER_NAME: Login username
        public String userType { get; private set; }         // USER_TYPE: User license type

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        public LogoutEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class LoginEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_LOGIN;
        // API Information
        public String apiType { get; private set; }          // API_TYPE: API request type
        public String apiVersion { get; private set; }       // API_VERSION: API version used
        
        // Authentication Information
        public String authMethodRef { get; private set; }    // AUTHENTICATION_METHOD_REFERENCE
        public String authServiceId { get; private set; }    // AUTHENTICATION_SERVICE_ID
        public String loginStatus { get; private set; }      // LOGIN_STATUS: Login result
        public String loginSubType { get; private set; }     // LOGIN_SUB_TYPE: Login flow
        public String loginType { get; private set; }        // LOGIN_TYPE: Access type
        public String loginUrl { get; private set; }         // LOGIN_URL: Login page URL
        
        // Security Information
        public String browserType { get; private set; }      // BROWSER_TYPE: Browser identifier
        public String cipherSuite { get; private set; }      // CIPHER_SUITE: TLS cipher
        public String tlsProtocol { get; private set; }      // TLS_PROTOCOL: TLS version
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP
        public String sourceIp { get; private set; }         // SOURCE_IP: Original IP
        public String forwardedForIp { get; private set; }   // FORWARDED_FOR_IP: X-Forwarded-For
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: DB time (ns)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Request Information
        public String requestStatus { get; private set; }    // REQUEST_STATUS: Request result
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: URI ID

        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }       // SESSION_KEY: User's unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        // User Information
        public String userName { get; private set; }         // USER_NAME: Login username
        public String userType { get; private set; }         // USER_TYPE: User license type
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        
        public LoginEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class BulkApiEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_BULK_API;
        // Bulk API Operation Details
        public String batchId { get; private set; }           // BATCH_ID: 15-char Bulk API batch ID
        public String jobId { get; private set; }             // JOB_ID: 15-char Bulk API job ID
        public String entityType { get; private set; }        // ENTITY_TYPE: Type of entity used
        public String operationType { get; private set; }     // OPERATION_TYPE: Type of Bulk API operation
        public String message { get; private set; }           // MESSAGE: Success or error message
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }          // CPU_TIME: CPU time in milliseconds
        public Integer rowsProcessed { get; private set; }    // ROWS_PROCESSED: Number of rows processed
        public Integer runTime { get; private set; }          // RUN_TIME: Request time in milliseconds
        public Integer numberFailures { get; private set; }   // NUMBER_FAILURES: Number of failures
        public Boolean success { get; private set; }          // SUCCESS: Whether batch was successful
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID
        
        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public BulkApiEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class ReportExportEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_REPORT_EXPORT;
        // Report Information
        public String reportDescription { get; private set; } // REPORT_DESCRIPTION: Report details
        
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        public String clientInfo { get; private set; }       // CLIENT_INFO: Client details
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        public ReportExportEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class VisualforceRequestData extends BaseEventData {
        public String eventType = EVENT_TYPE_VISUALFORCE_REQUEST;
        // Page Information
        public String pageName { get; private set; }         // PAGE_NAME: VF page name
        public String managedPackageNamespace { get; private set; } // MANAGED_PACKAGE_NAMESPACE
        public Integer viewStateSize { get; private set; }   // VIEW_STATE_SIZE: VF state size
        
        // Controller Information
        public Integer controllerType { get; private set; }  // CONTROLLER_TYPE: Controller type
        
        // Request Details
        public String httpMethod { get; private set; }       // HTTP_METHOD: GET/POST/etc
        public Boolean isAjaxRequest { get; private set; }   // IS_AJAX_REQUEST: Partial page
        public Boolean isFirstRequest { get; private set; }  // IS_FIRST_REQUEST: First VF txn
        public String query { get; private set; }           // QUERY: Query string
        public Integer requestSize { get; private set; }     // REQUEST_SIZE: Request body size
        public String requestType { get; private set; }      // REQUEST_TYPE: Request category
        public Integer responseSize { get; private set; }    // RESPONSE_SIZE: Response size
        public String requestStatus { get; private set; }    // REQUEST_STATUS: S/F/U/A/R/N
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        public Integer dbBlocks { get; private set; }        // DB_BLOCKS: DB block usage
        public Integer dbCpuTime { get; private set; }       // DB_CPU_TIME: DB CPU time (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: DB time (ns)
        
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP
        public Integer userAgent { get; private set; }       // USER_AGENT: Client type code
        
        // URI Information
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: License category

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public VisualforceRequestData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class LightningLoggerData extends BaseEventData {
        public String eventType = EVENT_TYPE_LIGHTNING_LOGGER;
        // Application Information
        public String appName { get; private set; }          // APP_NAME: Application name
        public String pageContext { get; private set; }      // PAGE_CONTEXT: Component context
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID: Entity ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE: Entity type
        public String pageUrl { get; private set; }          // PAGE_URL: Relative URL
        
        // Client Information
        public String browserName { get; private set; }      // BROWSER_NAME: Browser name
        public String browserVersion { get; private set; }   // BROWSER_VERSION: Browser version
        public String clientGeo { get; private set; }        // CLIENT_GEO: Client geolocation
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Device Information
        public String deviceModel { get; private set; }      // DEVICE_MODEL: Device model
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM: Platform info
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID: Session ID
        public String connectionType { get; private set; }   // CONNECTION_TYPE: Network type
        
        // System Information
        public String osName { get; private set; }           // OS_NAME: Operating system
        public String osVersion { get; private set; }        // OS_VERSION: OS version
        public String sdkAppType { get; private set; }       // SDK_APP_TYPE: SDK app type
        public String sdkAppVersion { get; private set; }    // SDK_APP_VERSION: App version
        public String sdkVersion { get; private set; }       // SDK_VERSION: SDK version
        
        // Event Information
        public String message { get; private set; }          // MESSAGE: Logger message
        public Integer sequence { get; private set; }        // SEQUENCE: Event sequence
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP: Event time
        public Decimal uiEventRelativeTimestamp { get; private set; } // UI_EVENT_RELATIVE_TIMESTAMP
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Login session key
        public String sessionKey { get; private set; }       // SESSION_KEY: User session key
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // User Information
        public String userId { get; private set; }           // USER_ID: 15-char user ID
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: User license type

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public LightningLoggerData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class LightningInteractionData extends BaseEventData {
        public String eventType = EVENT_TYPE_LIGHTNING_INTERACTION;
        // Application Information
        public String appName { get; private set; }          // APP_NAME: Application name
        public String pageAppName { get; private set; }      // PAGE_APP_NAME: App Launcher name
        public String pageContext { get; private set; }      // PAGE_CONTEXT: Page context
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID: Entity ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE: Entity type
        public Long pageStartTime { get; private set; }      // PAGE_START_TIME: Page load time
        public String pageUrl { get; private set; }          // PAGE_URL: Relative URL
        
        // UI Element Information
        public String targetUiElement { get; private set; }   // TARGET_UI_ELEMENT: Target element
        public String parentUiElement { get; private set; }   // PARENT_UI_ELEMENT: Parent scope
        public String grandparentUiElement { get; private set; } // GRANDPARENT_UI_ELEMENT: Grandparent scope
        public String componentName { get; private set; }     // COMPONENT_NAME: Component name
        public String relatedList { get; private set; }      // RELATED_LIST: Related list type
        
        // Record Information
        public List<String> recordId { get; private set; }   // RECORD_ID: Record IDs array
        public String recordType { get; private set; }       // RECORD_TYPE: Record object type
        
        // Event Information
        public String uiEventId { get; private set; }        // UI_EVENT_ID: Event type ID
        public Integer uiEventSequenceNum { get; private set; } // UI_EVENT_SEQUENCE_NUM: Sequence
        public String uiEventSource { get; private set; }    // UI_EVENT_SOURCE: User action
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP: Event time
        public String uiEventType { get; private set; }      // UI_EVENT_TYPE: Interaction type
        public Integer duration { get; private set; }        // DURATION: Duration in ms
        
        // Client Information
        public String browserName { get; private set; }      // BROWSER_NAME: Browser name
        public String browserVersion { get; private set; }   // BROWSER_VERSION: Browser version
        public String clientGeo { get; private set; }        // CLIENT_GEO: Client geolocation
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Device Information
        public String deviceId { get; private set; }         // DEVICE_ID: Unique device ID
        public String deviceModel { get; private set; }      // DEVICE_MODEL: Device model
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM: Platform info
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID: Session ID
        public String connectionType { get; private set; }   // CONNECTION_TYPE: Network type
        
        // System Information
        public String osName { get; private set; }           // OS_NAME: Operating system
        public String osVersion { get; private set; }        // OS_VERSION: OS version
        public String sdkAppType { get; private set; }       // SDK_APP_TYPE: SDK app type
        public String sdkAppVersion { get; private set; }    // SDK_APP_VERSION: App version
        public String sdkVersion { get; private set; }       // SDK_VERSION: SDK version
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Login session key
        public String sessionKey { get; private set; }       // SESSION_KEY: User session key
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: User license type
        public String userAgent { get; private set; }        // USER_AGENT: Client type code

        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public LightningInteractionData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class LightningPageViewData extends BaseEventData {
        public String eventType = EVENT_TYPE_LIGHTNING_PAGE_VIEW;
        // Current Page Information
        public String appName { get; private set; }          // APP_NAME: Application name
        public String pageAppName { get; private set; }      // PAGE_APP_NAME: App Launcher name
        public String pageContext { get; private set; }      // PAGE_CONTEXT: Page component
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID: Entity ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE: Entity type
        public Long pageStartTime { get; private set; }      // PAGE_START_TIME: Load start time
        public String pageUrl { get; private set; }          // PAGE_URL: Relative URL
        
        // Previous Page Information
        public String prevPageAppName { get; private set; }  // PREVPAGE_APP_NAME: Previous app
        public String prevPageContext { get; private set; }  // PREVPAGE_CONTEXT: Previous context
        public String prevPageEntityId { get; private set; } // PREVPAGE_ENTITY_ID: Previous ID
        public String prevPageEntityType { get; private set; } // PREVPAGE_ENTITY_TYPE: Previous type
        public String prevPageUrl { get; private set; }      // PREVPAGE_URL: Previous URL
        
        // Performance Metrics
        public Integer duration { get; private set; }        // DURATION: Load duration
        public Decimal effectivePageTime { get; private set; } // EFFECTIVE_PAGE_TIME: EPT
        public Boolean effectivePageTimeDeviation { get; private set; } // EFFECTIVE_PAGE_TIME_DEVIATION
        public String effectivePageTimeDeviationErrorType { get; private set; } // EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE
        public String effectivePageTimeDeviationReason { get; private set; } // EFFECTIVE_PAGE_TIME_DEVIATION_REASON
        
        // UI Element Information
        public String targetUiElement { get; private set; }   // TARGET_UI_ELEMENT: Target element
        public String parentUiElement { get; private set; }   // PARENT_UI_ELEMENT: Parent scope
        public String grandparentUiElement { get; private set; } // GRANDPARENT_UI_ELEMENT: Grandparent
        
        // Event Information
        public String uiEventId { get; private set; }        // UI_EVENT_ID: Event type ID
        public Integer uiEventSequenceNum { get; private set; } // UI_EVENT_SEQUENCE_NUM: Sequence
        public String uiEventSource { get; private set; }    // UI_EVENT_SOURCE: Page type (mobile)
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP: Event time
        
        // Client Information
        public String browserName { get; private set; }      // BROWSER_NAME: Browser name
        public String browserVersion { get; private set; }   // BROWSER_VERSION: Browser version
        public String clientGeo { get; private set; }        // CLIENT_GEO: Client geolocation
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Device Information
        public String deviceId { get; private set; }         // DEVICE_ID: Unique device ID
        public String deviceModel { get; private set; }      // DEVICE_MODEL: Device model
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM: Platform info
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID: Session ID
        public String connectionType { get; private set; }   // CONNECTION_TYPE: Network type
        
        // System Information
        public String osName { get; private set; }           // OS_NAME: Operating system
        public String osVersion { get; private set; }        // OS_VERSION: OS version
        public String sdkAppType { get; private set; }       // SDK_APP_TYPE: SDK app type
        public String sdkAppVersion { get; private set; }    // SDK_APP_VERSION: App version
        public String sdkVersion { get; private set; }       // SDK_VERSION: SDK version

        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Login session key
        public String sessionKey { get; private set; }       // SESSION_KEY: User session key
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: User license type
        public String userAgent { get; private set; }        // USER_AGENT: Client type code

        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public LightningPageViewData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class LightningErrorData extends BaseEventData {
        public String eventType = EVENT_TYPE_LIGHTNING_ERROR;
        // Application Information
        public String appName { get; private set; }          // APP_NAME: Application name
        public String pageAppName { get; private set; }      // PAGE_APP_NAME: App Launcher name
        public String pageContext { get; private set; }      // PAGE_CONTEXT: Page context
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID: Entity ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE: Entity type
        public Long pageStartTime { get; private set; }      // PAGE_START_TIME: Page load time
        public String pageUrl { get; private set; }          // PAGE_URL: Relative URL
        
        // Browser Information
        public String browserName { get; private set; }      // BROWSER_NAME: Browser name
        public String browserVersion { get; private set; }   // BROWSER_VERSION: Browser version
        
        // Client Information
        public String clientGeo { get; private set; }        // CLIENT_GEO: Client geolocation
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Device Information
        public String deviceId { get; private set; }         // DEVICE_ID: Unique device ID
        public String deviceModel { get; private set; }      // DEVICE_MODEL: Device model
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM: Platform info
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID: Session ID
        public String connectionType { get; private set; }   // CONNECTION_TYPE: Network type
        
        // Error Information
        public String componentName { get; private set; }    // COMPONENT_NAME: Component name
        public String message { get; private set; }          // MESSAGE: Error message
        public String stackTrace { get; private set; }       // STACK_TRACE: Stack trace
        
        // UI Event Information
        public String uiEventId { get; private set; }        // UI_EVENT_ID: Event type ID
        public Integer uiEventSequenceNum { get; private set; } // UI_EVENT_SEQUENCE_NUM: Sequence
        public String uiEventSource { get; private set; }    // UI_EVENT_SOURCE: Error source
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP: Event time
        public String uiEventType { get; private set; }      // UI_EVENT_TYPE: Event type
        
        // System Information
        public String osName { get; private set; }           // OS_NAME: Operating system
        public String osVersion { get; private set; }        // OS_VERSION: OS version
        public String sdkAppType { get; private set; }       // SDK_APP_TYPE: SDK app type
        public String sdkAppVersion { get; private set; }    // SDK_APP_VERSION: App version
        public String sdkVersion { get; private set; }       // SDK_VERSION: SDK version
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Login session key
        public String sessionKey { get; private set; }       // SESSION_KEY: User session key
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: User license type
        public String userAgent { get; private set; }        // USER_AGENT: Client type code

        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public LightningErrorData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ExternalODataCalloutData extends BaseEventData {
        public String eventType = EVENT_TYPE_EXTERNAL_ODATA_CALLOUT;
        // Action Information
        public String action { get; private set; }           // ACTION: Callout action
        
        // Response Information
        public Integer bytes { get; private set; }           // BYTES: Result set size
        
        // Entity Information
        public String entity { get; private set; }           // ENTITY: External object name
        
        // Performance Metrics
        public Integer executeMs { get; private set; }       // EXECUTE_MS: Preparation time
        public Integer fetchMs { get; private set; }         // FETCH_MS: Retrieval time
        public Integer totalMs { get; private set; }         // TOTAL_MS: Total time
        public Decimal throughput { get; private set; }      // THROUGHPUT: Records per second
        
        // Query Parameters
        public String expand { get; private set; }           // EXPAND: Reserved
        public String filter { get; private set; }           // FILTER: WHERE/$filter clause
        public String library { get; private set; }          // LIBRARY: Reserved
        public Integer limitValue { get; private set; }      // LIMIT: Max rows ($top)
        public String nextLink { get; private set; }         // NEXT_LINK: OData pagination
        public Integer offset { get; private set; }          // OFFSET: Rows to skip ($skip)
        public String orderBy { get; private set; }          // ORDERBY: Sort ($orderby)
        public String search { get; private set; }           // SEARCH: SOSL condition
        public String selectValue { get; private set; }      // SELECT: Fields ($select)
        
        // Provider Information
        public String providerType { get; private set; }     // PROVIDER_TYPE: OData version
        
        // Rate Limiting
        public Decimal rateLimitUsagePercent { get; private set; } // RATE_LIMIT_USAGE_PERCENT
        
        // Result Information
        public String message { get; private set; }          // MESSAGE: Error message
        public Integer rows { get; private set; }            // ROWS: Total records
        public Integer rowsFetched { get; private set; }     // ROWS_FETCHED: Records in page
        public Boolean status { get; private set; }          // STATUS: Success indicator
        public Integer requests { get; private set; }        // REQUESTS: Reserved
        
        // Pagination Information
        public String parentCallout { get; private set; }    // PARENT_CALLOUT: Initial callout ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userId { get; private set; }           // USER_ID: 15-char user ID

        public ExternalODataCalloutData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ExternalDataSourceCalloutData extends BaseEventData {
        public String eventType = EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT;
        // Data Source Information
        public String dataSourceName { get; private set; }    // DATA_SOURCE_NAME: External data source name
        public String providerType { get; private set; }      // PROVIDER_TYPE: amazonDynamodb/amazonAthena
        public String externalObject { get; private set; }    // EXTERNAL_OBJECT: External object name
        public String tableName { get; private set; }         // TABLE_NAME: AWS table name
        
        // Action Information
        public String action { get; private set; }            // ACTION: query/insert/delete/update/upsert
        public String operation { get; private set; }         // OPERATION: Operation being performed
        
        // Query Parameters
        public String filter { get; private set; }            // FILTER: WHERE clause conditions
        public String selectValue { get; private set; }            // SELECT: Fields being queried
        public String orderBy { get; private set; }           // ORDERBY: Sort specifications
        public String search { get; private set; }            // SEARCH: Search query string
        public Integer limitValue { get; private set; }       // LIMIT: Maximum rows to return
        public Integer offset { get; private set; }           // OFFSET: Rows to skip (Athena only)
        
        // Performance Metrics
        public Integer fetchMs { get; private set; }          // FETCH_MS: Result retrieval time
        public Integer totalMs { get; private set; }          // TOTAL_MS: Total operation time
        public Integer responseSize { get; private set; }     // RESPONSE_SIZE: Response size in bytes
        public Decimal throughput { get; private set; }       // THROUGHPUT: Records per second
        
        // Result Information
        public Integer rowsFetched { get; private set; }      // ROWS_FETCHED: Number of records fetched
        public Boolean status { get; private set; }           // STATUS: Success (1) or failure (0)
        public Integer statusCode { get; private set; }       // STATUS_CODE: HTTP response code
        public String message { get; private set; }           // MESSAGE: Error or warning message
        
        // Pagination Information
        public String nextLink { get; private set; }          // NEXT_LINK: Next page token
        public String parentCallout { get; private set; }     // PARENT_CALLOUT: Initial callout ID
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // User and Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ExternalDataSourceCalloutData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ExternalCrossOrgCalloutData extends BaseEventData {
        public String eventType = EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT;
        // Action Information
        public String action { get; private set; }           // ACTION: Callout action
        
        // Entity Information
        public String entity { get; private set; }           // ENTITY: External object name
        
        // Performance Metrics
        public Integer executeMs { get; private set; }       // EXECUTE_MS: Preparation time
        public Integer fetchMs { get; private set; }         // FETCH_MS: Retrieval time
        public Integer totalMs { get; private set; }         // TOTAL_MS: Total time
        public Decimal throughput { get; private set; }      // THROUGHPUT: Reserved
        
        // Query Parameters
        public String filter { get; private set; }           // FILTER: WHERE clause
        public String havingValue { get; private set; }      // HAVING: Reserved
        public Integer limitValue { get; private set; }      // LIMIT: Max rows
        public Integer offset { get; private set; }          // OFFSET: Rows to skip
        public String orderBy { get; private set; }          // ORDERBY: Sort specification
        public String selectValue { get; private set; }      // SELECT: Fields list
        public Integer subqueries { get; private set; }      // SUBQUERIES: Number of subqueries
        
        // Result Information
        public String message { get; private set; }          // MESSAGE: Error/warning message
        public Integer rows { get; private set; }            // ROWS: Total records
        public Integer rowsFetched { get; private set; }     // ROWS_FETCHED: Reserved
        public Boolean status { get; private set; }          // STATUS: Success indicator
        public Boolean usingMru { get; private set; }        // USING_MRU: Reserved
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        public ExternalCrossOrgCalloutData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ExternalCustomApexCalloutData extends BaseEventData {
        public String eventType = EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT;
        // Action Information
        public String action { get; private set; }           // ACTION: query/upsert/delete
        public String entity { get; private set; }           // ENTITY: External object name
        
        // Performance Metrics
        public Integer executeMs { get; private set; }       // EXECUTE_MS: Preparation and execution time
        public Integer fetchMs { get; private set; }         // FETCH_MS: Result retrieval time
        public Integer totalMs { get; private set; }         // TOTAL_MS: Total operation time
        public Decimal throughput { get; private set; }      // THROUGHPUT: Records per second
        
        // Query Parameters
        public String filter { get; private set; }           // FILTER: WHERE clause conditions
        public Integer limitValue { get; private set; }      // LIMIT: Maximum rows to return
        public Integer offset { get; private set; }          // OFFSET: Rows to skip
        public String orderBy { get; private set; }          // ORDERBY: Sort specifications
        public String selectValue { get; private set; }    // SELECT: Fields being queried
        public Integer subqueries { get; private set; }      // SUBQUERIES: Reserved for future
        
        // Result Information
        public Integer rows { get; private set; }            // ROWS: Total records in result set
        public Integer rowsFetched { get; private set; }     // ROWS_FETCHED: Actual rows retrieved
        public Boolean status { get; private set; }          // STATUS: Success (1) or failure (0)
        public String message { get; private set; }          // MESSAGE: Error or warning message
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Unique transaction ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ExternalCustomApexCalloutData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class DocumentAttachmentDownloadsData extends BaseEventData {
        public String eventType = EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS;
        // Entity Information
        public String entityId { get; private set; }          // ENTITY_ID: 15-char entity ID
        public String fileType { get; private set; }          // FILE_TYPE: Type of file or attachment
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public DocumentAttachmentDownloadsData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class DatabaseSaveEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_DATABASE_SAVE;
        // DML Information
        public String dmlType { get; private set; }           // DML_TYPE: Type of DML statement
        public String keyPrefix { get; private set; }         // KEY_PREFIX: Key prefix of saved entity
        public String firstEntityId { get; private set; }     // FIRST_ENTITY_ID: First ID logged in update
        public Integer numRows { get; private set; }          // NUM_ROWS: Number of entities saved
        public Decimal sampleFactor { get; private set; }     // SAMPLE_FACTOR: Ratio of entities logged
        
        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Globally unique request ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public DatabaseSaveEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class DashboardEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_DASHBOARD;
        // Dashboard Information
        public String dashboardId { get; private set; }        // DASHBOARD_ID: 15-char dashboard ID
        public String dashboardIdDerived { get; private set; } // DASHBOARD_ID_DERIVED: 18-char dashboard ID
        public String dashboardComponentId { get; private set; } // DASHBOARD_COMPONENT_ID: 15-char component ID
        public String dashboardType { get; private set; }      // DASHBOARD_TYPE: R/C/S
        public DashboardType dashboardTypeEnum { get; private set; }
        // Report Information
        public String reportId { get; private set; }           // REPORT_ID: 15-char report ID
        public String reportIdDerived { get; private set; }    // REPORT_ID_DERIVED: 18-char report ID
        
        // Execution Status
        public Boolean isScheduled { get; private set; }       // IS_SCHEDULED: Whether dashboard was scheduled
        public Boolean isSuccess { get; private set; }         // IS_SUCCESS: Whether execution was successful
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time in milliseconds
        public Integer runTime { get; private set; }           // RUN_TIME: Total runtime in milliseconds
        
        // Request Information
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // User Information
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-char running user ID
        public String viewingUserId { get; private set; }      // VIEWING_USER_ID: ID of viewing user
        
        // Session Information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        
        // Client Information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        
        // Organization Information
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public DashboardEventData(Map<String, Object> eventData) {
            super(eventData);
            
            this.dashboardTypeEnum = convertDashboardType(this.dashboardType);
        }
    }

    public class CspViolationData extends BaseEventData {
        public String eventType = EVENT_TYPE_CSP_VIOLATION;
        // Blocked Resource Information
        public String blockedUri { get; private set; }        // BLOCKED_URI: Full string of blocked resource
        public String blockedUriDomain { get; private set; }  // BLOCKED_URI_DOMAIN: Domain of blocked URI
        
        // Violation Location
        public Integer columnNumber { get; private set; }     // COLUMN_NUMBER: Column where violation occurred
        public Integer lineNumber { get; private set; }       // LINE_NUMBER: Line where violation occurred
        
        // CSP Context and Policy
        public String context { get; private set; }           // CONTEXT: Always "Lightning"
        public String directive { get; private set; }         // DIRECTIVE: CSP directive that blocked request
        public String disposition { get; private set; }       // DISPOSITION: enforce/report
        public CspViolationDisposition dispositionEnum { get; private set; }
        // Source Information
        public String source { get; private set; }            // SOURCE: Page where violation originated
        public String sourceFile { get; private set; }        // SOURCE_FILE: URL of script (if applicable)
        public String resourceSample { get; private set; }    // RESOURCE_SAMPLE: Sample of violating resource
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public CspViolationData(Map<String, Object> eventData) {
            super(eventData);
            
            this.dispositionEnum = convertCspViolationDisposition(this.disposition);
        }
    }

    public class CorsViolationData extends BaseEventData {
        public String eventType = EVENT_TYPE_CORS_VIOLATION;
        // CORS Information
        public String host { get; private set; }             // HOST: URL of requested Salesforce resource
        public String origin { get; private set; }           // ORIGIN: URL of site making the cross-origin request
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Unique transaction ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public CorsViolationData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ContinuationCalloutSummaryData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY;
        // Continuation Information
        public String continuationId { get; private set; }    // CONTINUATION_ID: Unique sequence ID
        public Integer duration { get; private set; }         // DURATION: Total duration in milliseconds
        public Boolean success { get; private set; }          // SUCCESS: Whether continuation was successful
        
        // Request Information
        public String originRequestId { get; private set; }   // ORIGIN_REQUEST_ID: ID of initiating request
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String requestFormSize { get; private set; }   // REQUEST_FORM_SIZE: Space-separated sizes in bytes
        public String responseSize { get; private set; }      // RESPONSE_SIZE: Space-separated sizes in bytes
        public String vfControllerSize { get; private set; }  // VF_CONTROLLER_SIZE: Space-separated sizes in bytes
        
        // Callout Information
        public String statusCode { get; private set; }        // STATUS_CODE: Space-separated status codes
        public ContinuationCalloutStatusCode statusCodeEnum { get; private set; }
        public String url { get; private set; }              // URL: Space-separated endpoint URLs
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ContinuationCalloutSummaryData(Map<String, Object> eventData) {
            super(eventData);
            
            this.statusCodeEnum = convertContinuationCalloutStatusCode(statusCode);
        }
    }
    
    public class ContentTransferData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONTENT_TRANSFER;
        // Document Information
        public String documentId { get; private set; }        // DOCUMENT_ID: 15-char document ID
        public String documentIdDerived { get; private set; } // DOCUMENT_ID_DERIVED: 18-char document ID
        public String versionId { get; private set; }         // VERSION_ID: 15-char version ID
        public String versionIdDerived { get; private set; }  // VERSION_ID_DERIVED: 18-char version ID
        
        // File Information
        public String fileType { get; private set; }          // FILE_TYPE: Content type of file version
        public String filePreviewType { get; private set; }   // FILE_PREVIEW_TYPE: Content type of preview
        public Integer sizeBytes { get; private set; }        // SIZE_BYTES: Size of file transfer in bytes
        
        // Transaction Information
        public String transactionType { get; private set; }   // TRANSACTION_TYPE: Operation performed
        public ContentTransferTransactionType transactionTypeEnum { get; private set; }
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ContentTransferData(Map<String, Object> eventData) {
            super(eventData);
            
            this.transactionTypeEnum = convertContentTransferTransactionType(transactionType);
        }
    }
    
    public class KnowledgeArticleViewData extends BaseEventData {
        public String eventType = EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW;
        // Article Information
        public String articleId { get; private set; }         // ARTICLE_ID: 15-char article ID
        public String articleStatus { get; private set; }     // ARTICLE_STATUS: D/O/A
        public Integer articleVersion { get; private set; }   // ARTICLE_VERSION: Version number
        public String articleVersionId { get; private set; }  // ARTICLE_VERSION_ID: Version ID
        public Boolean lastVersion { get; private set; }      // LAST_VERSION: Is latest version
        
        // Article Context
        public String context { get; private set; }           // CONTEXT: Apex/API/empty
        public String entity { get; private set; }            // ENTITY: Requested entity
        public String language { get; private set; }          // LANGUAGE: ISO language code
        public String largeLanguageModel { get; private set; } // LARGE_LANGUAGE_MODEL: LLM name
        
        // Session Information
        public String sessionId { get; private set; }         // SESSION_ID: Request session ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }          // USER_TYPE: A/C/P/G
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Transaction ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public KnowledgeArticleViewData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    // Login As Events
    public class LoginAsData extends BaseEventData {
        public String eventType = EVENT_TYPE_LOGIN_AS;
        // Delegated User Information
        public String delegatedUserId { get; private set; }      // DELEGATED_USER_ID: 15-char ID
        public String delegatedUserIdDerived { get; private set; } // DELEGATED_USER_ID_DERIVED: 18-char ID
        public String delegatedUserName { get; private set; }    // DELEGATED_USER_NAME: Username
        
        // Network Information
        public String clientIp { get; private set; }            // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }            // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }            // RUN_TIME: Total time (ms)
        
        // Request Information
        public String uri { get; private set; }                 // URI: Request URI
        public String uriIdDerived { get; private set; }        // URI_ID_DERIVED: URI ID

        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public LoginAsData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class OneCommerceUsageData extends BaseEventData {
        public String eventType = EVENT_TYPE_ONE_COMMERCE_USAGE;
        // Commerce Information
        public String b2bEdition { get; private set; }       // B2B_EDITION: Lightning/CCRZ
        public String b2bVersion { get; private set; }       // B2B_VERSION: Version info
        public String webstoreId { get; private set; }       // WEBSTORE_ID: Store ID
        public String webstoreType { get; private set; }     // WEBSTORE_TYPE: B2B/B2C/OMS
        
        // Browser/Device Information
        public String browserDeviceType { get; private set; } // BROWSER_DEVICE_TYPE
        public String osVersion { get; private set; }        // OS_VERSION
        
        // Operation Information
        public String operation { get; private set; }        // OPERATION: B2B service name
        public String operationStage { get; private set; }   // OPERATION_STAGE
        public String operationState { get; private set; }   // OPERATION_STATE
        public String operationStatus { get; private set; }  // OPERATION_STATUS
        public Integer operationTime { get; private set; }   // OPERATION_TIME (ms)
        public Boolean isRetry { get; private set; }        // IS_RETRY
        public Integer count { get; private set; }          // COUNT: Records affected
        
        // Context Information
        public String contextId { get; private set; }        // CONTEXT_ID: Business domain value
        public String contextMap { get; private set; }       // CONTEXT_MAP: JSON context
        public String correlationId { get; private set; }    // CORRELATION_ID
        public String effectiveAccountId { get; private set; } // EFFECTIVE_ACCOUNT_ID
        
        // Error Information
        public String errorCode { get; private set; }        // ERROR_CODE
        public String errorMessage { get; private set; }     // ERROR_MESSAGE
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME (ms)
        public Integer runTime { get; private set; }         // RUN_TIME (ms)
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID
        public String requestStatus { get; private set; }    // REQUEST_STATUS
        public String uri { get; private set; }              // URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY
        public String sessionKey { get; private set; }       // SESSION_KEY
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP
        
        // Service Information
        public String serviceName { get; private set; }      // SERVICE_NAME
        
        // Timestamp Information
        public String timestamp { get; private set; }        // TIMESTAMP
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED
        
        // User Information
        public String userId { get; private set; }           // USER_ID
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED
        public String userType { get; private set; }         // USER_TYPE

        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        public OneCommerceUsageData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class NamedCredentialData extends BaseEventData {
        public String eventType = EVENT_TYPE_NAMED_CREDENTIAL;
        // Named Credential Information
        public String namedCredentialName { get; private set; }    // NAMED_CREDENTIAL_NAME
        public String callerPackageNamespace { get; private set; } // CALLER_PACKAGE_NAMESPACE
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public NamedCredentialData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class MultiblockReportData extends BaseEventData {
        public String eventType = EVENT_TYPE_MULTIBLOCK_REPORT;
        // Report Information
        public String masterReportId { get; private set; }   // MASTER_REPORT_ID: 15-char report ID
        public Boolean hasChart { get; private set; }        // HAS_CHART: Chart presence flag
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: Database time (ns)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String requestStatus { get; private set; }    // REQUEST_STATUS: Request status
        public RequestStatus requestStatusEnum { get; private set; }
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }         // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }

        public MultiblockReportData(Map<String, Object> eventData) {
            super(eventData);

            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
            this.userTypeEnum = convertUserType(this.userType);
        }
    }
    
    public class MetadataApiOperationData extends BaseEventData {
        public String eventType = EVENT_TYPE_METADATA_API_OPERATION;
        // API Information
        public String apiVersion { get; private set; }       // API_VERSION: API version used
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics  
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Operation Details
        public String operation { get; private set; }        // OPERATION: Operation type
        public MetadataApiOperationType operationEnum { get; private set; }
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: URI ID
        
        // Session Information
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public MetadataApiOperationData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class RestApiData extends BaseEventData {
        public String eventType = EVENT_TYPE_REST_API;
        // API Information
        public String method { get; private set; }           // METHOD: HTTP method
        public String mediaType { get; private set; }        // MEDIA_TYPE: Response media type
        public Integer statusCode { get; private set; }      // STATUS_CODE: HTTP status code
        public String entityName { get; private set; }       // ENTITY_NAME: Object accessed
        public Integer numberFields { get; private set; }    // NUMBER_FIELDS: Field count
        public Integer rowsProcessed { get; private set; }   // ROWS_PROCESSED: Row count
        public String query { get; private set; }            // QUERY: Query string
        
        // Connected App Information
        public String connectedAppId { get; private set; }   // CONNECTED_APP_ID: 15-char app ID
        
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        public String clientName { get; private set; }       // CLIENT_NAME: Client name
        public Integer userAgent { get; private set; }       // USER_AGENT: Client type code
        
        // Request/Response Metrics
        public Integer requestSize { get; private set; }     // REQUEST_SIZE: Request body size
        public Integer responseSize { get; private set; }    // RESPONSE_SIZE: Response size
        public String requestStatus { get; private set; }    // REQUEST_STATUS: S/F/U/A/R/N
        public RequestStatus requestStatusEnum { get; private set; }
        public String exceptionMessage { get; private set; } // EXCEPTION_MESSAGE: Error details
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer dbBlocks { get; private set; }        // DB_BLOCKS: DB block usage
        public Integer dbCpuTime { get; private set; }       // DB_CPU_TIME: DB CPU time (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: Total DB time (ns)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }         // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        
        public RestApiData(Map<String, Object> eventData) {
            super(eventData);
            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
            this.userTypeEnum = convertUserType(this.userType);
        }
    }

    public class WavePerformanceEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_WAVE_PERFORMANCE;
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer ept { get; private set; }            // EPT: Experienced page time (ms)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Asset Information
        public String name { get; private set; }            // NAME: Asset title/query string
        public String recordId { get; private set; }        // RECORD_ID: Analytics object ID
        public String tabId { get; private set; }           // TAB_ID: Analytics tab ID
        public String type { get; private set; }            // TYPE: Analytics object type (deprecated v59.0)
        public String viewMode { get; private set; }        // VIEW_MODE: Asset view mode
        public Boolean isInitial { get; private set; }      // IS_INITIAL: Initial load flag
        
        // Analytics Session
        public String waveSessionId { get; private set; }   // WAVE_SESSION_ID: Analytics session
        public Integer waveTimestamp { get; private set; }  // WAVE_TIMESTAMP: Log time
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        public String queryId { get; private set; }         // QUERY_ID: Deprecated in v50.0
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userId { get; private set; }          // USER_ID: 15-char user ID
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public WavePerformanceEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class WaveInteractionEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_WAVE_INTERACTION;
        // Interaction Metrics
        public Integer numClicks { get; private set; }      // NUM_CLICKS: Click count
        public Integer numSessions { get; private set; }    // NUM_SESSIONS: Return count
        public Integer readTime { get; private set; }       // READ_TIME: Tab active time
        public Integer totalTime { get; private set; }      // TOTAL_TIME: Total open time
        
        // Analytics Information
        public String recordId { get; private set; }        // RECORD_ID: Analytics object ID
        public String tabId { get; private set; }           // TAB_ID: Analytics tab ID
        public String type { get; private set; }            // TYPE: Analytics object type
        public String viewMode { get; private set; }        // VIEW_MODE: Asset view mode
        public String waveSessionId { get; private set; }   // WAVE_SESSION_ID: Analytics session
        public Integer waveTimestamp { get; private set; }  // WAVE_TIMESTAMP: Log time
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public WaveInteractionEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class WaveDownloadEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_WAVE_DOWNLOAD;
        // Asset Information
        public String assetId { get; private set; }         // ASSET_ID: Downloaded asset ID
        public String assetType { get; private set; }       // ASSET_TYPE: Asset type
        public String datasetIds { get; private set; }      // DATASET_IDS: Used dataset IDs
        
        // Download Information
        public String downloadError { get; private set; }    // DOWNLOAD_ERROR: Error message
        public String downloadFormat { get; private set; }   // DOWNLOAD_FORMAT: Export format
        public Integer numberOfRecords { get; private set; } // NUMBER_OF_RECORDS: Export count
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Analytics Session
        public String waveSessionId { get; private set; }   // WAVE_SESSION_ID: Analytics session
        public Integer waveTimestamp { get; private set; }  // WAVE_TIMESTAMP: Log time
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }        // USER_TYPE: User license type

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public WaveDownloadEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }
    
    public class WaveChangeEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_WAVE_CHANGE;
        // Analytics Information
        public String analyticsMode { get; private set; }    // ANALYTICS_MODE: Display location
        public String pageContext { get; private set; }      // PAGE_CONTEXT: Display context
        public String pageId { get; private set; }          // PAGE_ID: Dashboard page ID
        public String recordId { get; private set; }        // RECORD_ID: Analytics object ID
        public String savedViewId { get; private set; }     // SAVED_VIEW_ID: Saved view ID
        public String tabId { get; private set; }           // TAB_ID: Analytics tab ID
        public String type { get; private set; }            // TYPE: Analytics object type
        public String viewMode { get; private set; }        // VIEW_MODE: Asset view mode
        public String waveSessionId { get; private set; }   // WAVE_SESSION_ID: Analytics session
        public Integer waveTimestamp { get; private set; }  // WAVE_TIMESTAMP: Log generation time
        
        // Navigation Information
        public Boolean isNew { get; private set; }          // IS_NEW: New/existing page
        public Integer reopenCount { get; private set; }    // REOPEN_COUNT: Page reopen count
        public Boolean isMobile { get; private set; }       // IS_MOBILE: Mobile access flag
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601
        
        public WaveChangeEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class PricingEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_PRICING;
        // Pricing Information
        public String pricingApiEndpoint { get; private set; }    // PRICING_API_ENDPOINT
        public String pricingDetails { get; private set; }        // PRICING_DETAILS
        public String pricingErrorCode { get; private set; }      // PRICING_ERROR_CODE
        public String pricingLogName { get; private set; }        // PRICING_LOG_NAME
        public String pricingProcedure { get; private set; }      // PRICING_PROCEDURE
        public String pricingStatus { get; private set; }         // PRICING_STATUS
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public PricingEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class PlatformEncryptionData extends BaseEventData {
        public String eventType = EVENT_TYPE_PLATFORM_ENCRYPTION;
        // Encryption Information
        public String action { get; private set; }           // ACTION: Event name/type
        public String keyType { get; private set; }          // KEY_TYPE: Tenant secret type
        public String keyId { get; private set; }            // KEY_ID: 15-char tenant secret ID
        public String keyIdDerived { get; private set; }     // KEY_ID_DERIVED: 18-char key ID
        public String method { get; private set; }           // METHOD: Active state change
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public PlatformEncryptionData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class PermissionUpdateData extends BaseEventData {
        public String eventType = EVENT_TYPE_PERMISSION_UPDATE;
        // Permission Information
        public String permissionType { get; private set; }   // PERMISSION_TYPE
        public String updateType { get; private set; }       // UPDATE_TYPE
        public String description { get; private set; }      // DESCRIPTION
        public String context { get; private set; }          // CONTEXT (reserved)
        
        // Feature Information
        public String featureId { get; private set; }        // FEATURE_ID: Profile/PermSet ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public PermissionUpdateData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class PackageInstallData extends BaseEventData {
        public String eventType = EVENT_TYPE_PACKAGE_INSTALL;
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Event Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        
        // Package Information
        public String failureType { get; private set; }      // FAILURE_TYPE: Error category
        public Boolean isManaged { get; private set; }       // IS_MANAGED: Is managed package
        public Boolean isPush { get; private set; }          // IS_PUSH: Is push upgrade
        public Boolean isReleased { get; private set; }      // IS_RELEASED: Is released package
        public Boolean isSuccessful { get; private set; }    // IS_SUCCESSFUL: Install success
        public String packageName { get; private set; }      // PACKAGE_NAME: Package name
        public String operationType { get; private set; }    // OPERATION_TYPE: Package operation
        public PackageOperationType operationTypeEnum { get; private set; }
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: URI ID
        
        // Session Information
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        
        public PackageInstallData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class UriEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_URI;
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Database Metrics
        public Integer dbBlocks { get; private set; }        // DB_BLOCKS: Database block usage
        public Integer dbCpuTime { get; private set; }       // DB_CPU_TIME: DB CPU time (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: Total DB time (ns)
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String requestStatus { get; private set; }    // REQUEST_STATUS: S/F/U/A/R/N
        public RequestStatus requestStatusEnum { get; private set; }
        
        // URI Information
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        public String referrerUri { get; private set; }      // REFERRER_URI: Referring page
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601
        
        public UriEventData(Map<String, Object> eventData) {
            super(eventData);

            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
            this.userTypeEnum = convertUserType(this.userType);
        }
    }

    public class TimeBasedWorkflowData extends BaseEventData {
        public String eventType = EVENT_TYPE_TIME_BASED_WORKFLOW;
        // Workflow Information
        public String type { get; private set; }            // TYPE: UIDEL/ERRDEL/DELETE/PROC
        public String data { get; private set; }            // DATA: Queue activity details
        public String logGroupId { get; private set; }      // LOG_GROUP_ID: Commit/rollback marker
        public Integer numberOfRecords { get; private set; } // NUMBER_OF_RECORDS: Processed count
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char user ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public TimeBasedWorkflowData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class UITelemetryResourceTimingData extends BaseEventData {
        public String eventType = EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING;
        // Application Information
        public String appName { get; private set; }          // APP_NAME
        public String pageContext { get; private set; }      // PAGE_CONTEXT
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE
        public String pageUrl { get; private set; }          // PAGE_URL
        public String url { get; private set; }              // URL
        
        // Browser Information
        public String browserName { get; private set; }      // BROWSER_NAME
        public String browserVersion { get; private set; }   // BROWSER_VERSION
        public String initiatorType { get; private set; }    // INITIATOR_TYPE
        public String renderBlockingStatus { get; private set; } // RENDER_BLOCKING_STATUS
        
        // Device Information
        public String deviceModel { get; private set; }      // DEVICE_MODEL
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID
        public String osName { get; private set; }          // OS_NAME
        public String osVersion { get; private set; }        // OS_VERSION
        
        // Network Information
        public String clientGeo { get; private set; }       // CLIENT_GEO
        public String clientId { get; private set; }        // CLIENT_ID
        public String clientIp { get; private set; }        // CLIENT_IP
        public String connectionType { get; private set; }   // CONNECTION_TYPE
        public String nextHopProtocol { get; private set; } // NEXT_HOP_PROTOCOL
        
        // Resource Metrics
        public Integer decodedBodySize { get; private set; } // DECODED_BODY_SIZE
        public Integer encodedBodySize { get; private set; } // ENCODED_BODY_SIZE
        public Integer transferSize { get; private set; }    // TRANSFER_SIZE
        public Integer responseStatus { get; private set; }  // RESPONSE_STATUS
        
        // Timing Metrics
        public Integer connectEnd { get; private set; }      // CONNECT_END
        public Integer connectStart { get; private set; }    // CONNECT_START
        public Integer domainLookupEnd { get; private set; } // DOMAIN_LOOKUP_END
        public Integer domainLookupStart { get; private set; } // DOMAIN_LOOKUP_START
        public Integer duration { get; private set; }        // DURATION
        public Integer fetchStart { get; private set; }      // FETCH_START
        public Integer firstInterimResponseStart { get; private set; } // FIRST_INTERIM_RESPONSE_START
        public Integer redirectEnd { get; private set; }     // REDIRECT_END
        public Integer redirectStart { get; private set; }   // REDIRECT_START
        public Integer requestStart { get; private set; }    // REQUEST_START
        public Integer responseEnd { get; private set; }     // RESPONSE_END
        public Integer responseStart { get; private set; }   // RESPONSE_START
        public Integer secureConnectStart { get; private set; } // SECURE_CONNECT_START
        public Integer startTime { get; private set; }       // START_TIME
        public Integer workerStart { get; private set; }     // WORKER_START
        
        // SDK Information
        public String sdkAppType { get; private set; }      // SDK_APP_TYPE
        public String sdkAppVersion { get; private set; }   // SDK_APP_VERSION
        public String sdkVersion { get; private set; }      // SDK_VERSION
        
        // UI Event Information
        public Decimal uiEventRelativeTimestamp { get; private set; } // UI_EVENT_RELATIVE_TIMESTAMP
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP
        public String uiRootActivityId { get; private set; } // UI_ROOT_ACTIVITY_ID
        public Integer uiThreadResponseDelay { get; private set; } // UI_THREAD_RESPONSE_DELAY
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY
        public String sessionKey { get; private set; }      // SESSION_KEY
        public String serverRequestId { get; private set; } // SERVER_REQUEST_ID
        public String organizationId { get; private set; }  // ORGANIZATION_ID
        public String requestId { get; private set; }       // REQUEST_ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED
        public String userType { get; private set; }        // USER_TYPE
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED

        public UITelemetryResourceTimingData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class UITelemetryNavigationTimingData extends BaseEventData {
        public String eventType = EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING;
        // Application Information
        public String appName { get; private set; }          // APP_NAME
        public String pageContext { get; private set; }      // PAGE_CONTEXT
        public String pageEntityId { get; private set; }     // PAGE_ENTITY_ID
        public String pageEntityType { get; private set; }   // PAGE_ENTITY_TYPE
        public String pageUrl { get; private set; }          // PAGE_URL
        public String url { get; private set; }              // URL
        
        // Browser Information
        public String browserName { get; private set; }      // BROWSER_NAME
        public String browserVersion { get; private set; }   // BROWSER_VERSION
        public String initiatorType { get; private set; }    // INITIATOR_TYPE
        public String navigationType { get; private set; }   // NAVIGATION_TYPE
        public Integer redirectCount { get; private set; }   // REDIRECT_COUNT
        public String renderBlockingStatus { get; private set; } // RENDER_BLOCKING_STATUS
        
        // Device Information
        public String deviceModel { get; private set; }      // DEVICE_MODEL
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID
        public String osName { get; private set; }          // OS_NAME
        public String osVersion { get; private set; }        // OS_VERSION
        
        // Network Information
        public String clientGeo { get; private set; }       // CLIENT_GEO
        public String clientId { get; private set; }        // CLIENT_ID
        public String clientIp { get; private set; }        // CLIENT_IP
        public String connectionType { get; private set; }   // CONNECTION_TYPE
        public String nextHopProtocol { get; private set; } // NEXT_HOP_PROTOCOL
        
        // Response Metrics
        public Integer decodedBodySize { get; private set; } // DECODED_BODY_SIZE
        public Integer encodedBodySize { get; private set; } // ENCODED_BODY_SIZE
        public Integer responseStatus { get; private set; }  // RESPONSE_STATUS
        public Integer transferSize { get; private set; }    // TRANSFER_SIZE
        
        // Timing Metrics
        public Integer connectEnd { get; private set; }      // CONNECT_END
        public Integer connectStart { get; private set; }    // CONNECT_START
        public Integer domComplete { get; private set; }     // DOM_COMPLETE
        public Integer domContentLoadedEventEnd { get; private set; }   // DOM_CONTENT_LOADED_EVENT_END
        public Integer domContentLoadedEventStart { get; private set; } // DOM_CONTENT_LOADED_EVENT_START
        public Integer domInteractive { get; private set; }  // DOM_INTERACTIVE
        public Integer domainLookupEnd { get; private set; } // DOMAIN_LOOKUP_END
        public Integer domainLookupStart { get; private set; } // DOMAIN_LOOKUP_START
        public Integer duration { get; private set; }        // DURATION
        public Integer fetchStart { get; private set; }      // FETCH_START
        public Integer firstInterimResponseStart { get; private set; } // FIRST_INTERIM_RESPONSE_START
        public Integer loadEventEnd { get; private set; }    // LOAD_EVENT_END
        public Integer loadEventStart { get; private set; }  // LOAD_EVENT_START
        public Integer redirectEnd { get; private set; }     // REDIRECT_END
        public Integer redirectStart { get; private set; }   // REDIRECT_START
        public Integer requestStart { get; private set; }    // REQUEST_START
        public Integer responseEnd { get; private set; }     // RESPONSE_END
        public Integer responseStart { get; private set; }   // RESPONSE_START
        public Integer secureConnectStart { get; private set; } // SECURE_CONNECT_START
        public Integer startTime { get; private set; }       // START_TIME
        public Integer unloadEventEnd { get; private set; }  // UNLOAD_EVENT_END
        public Integer unloadEventStart { get; private set; } // UNLOAD_EVENT_START
        public Integer workerStart { get; private set; }     // WORKER_START
        
        // SDK Information
        public String sdkAppType { get; private set; }      // SDK_APP_TYPE
        public String sdkAppVersion { get; private set; }   // SDK_APP_VERSION
        public String sdkVersion { get; private set; }      // SDK_VERSION
        
        // UI Event Information
        public Decimal uiEventRelativeTimestamp { get; private set; } // UI_EVENT_RELATIVE_TIMESTAMP
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP
        public String uiRootActivityId { get; private set; } // UI_ROOT_ACTIVITY_ID
        public Integer uiThreadResponseDelay { get; private set; } // UI_THREAD_RESPONSE_DELAY
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY
        public String sessionKey { get; private set; }      // SESSION_KEY
        public String serverRequestId { get; private set; } // SERVER_REQUEST_ID
        public String organizationId { get; private set; }  // ORGANIZATION_ID
        public String requestId { get; private set; }       // REQUEST_ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED
        public String userType { get; private set; }        // USER_TYPE
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED

        public UITelemetryNavigationTimingData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class TransactionSecurityData extends BaseEventData {
        public String eventType = EVENT_TYPE_TRANSACTION_SECURITY;
        // Policy Information
        public String policyId { get; private set; }         // POLICY_ID: 15-char policy ID
        public String policyIdDerived { get; private set; }  // POLICY_ID_DERIVED: 18-char ID
        public String result { get; private set; }           // RESULT: Policy evaluation outcome
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer evaluationTimeMs { get; private set; } // EVALUATION_TIME_MS: Policy eval time
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        
        // Timestamp Information
        public DateTime eventTimestamp { get; private set; }   // EVENT_TIMESTAMP: Event generation time
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public TransactionSecurityData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ContentDistributionData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONTENT_DISTRIBUTION;
        // Content Information
        public String deliveryId { get; private set; }        // DELIVERY_ID: 15-char content delivery ID
        public String deliveryLocation { get; private set; }  // DELIVERY_LOCATION: Location of delivery
        public String versionId { get; private set; }         // VERSION_ID: 15-char content version ID
        
        // Action Information
        public String action { get; private set; }            // ACTION: Action used (VIEW/INSERT/UPDATE)
        public ContentDistributionAction actionEnum { get; private set; }
        // Related Information
        public String relatedEntityId { get; private set; }   // RELATED_ENTITY_ID: 15-char related record ID
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ContentDistributionData(Map<String, Object> eventData) {
            super(eventData);
            
            this.actionEnum = convertContentDistributionAction(action);
        }
    }

    public class ConsoleEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONSOLE;
        // Console Information
        public String consoleId { get; private set; }         // CONSOLE_ID: 15-char console ID
        public String consoleIdDerived { get; private set; }  // CONSOLE_ID_DERIVED: 18-char console ID
        public String licenseContext { get; private set; }    // LICENSE_CONTEXT: Console license context
        
        // Component Information
        public String componentId { get; private set; }       // COMPONENT_ID: 15-char component ID
        public String componentIdDerived { get; private set; } // COMPONENT_ID_DERIVED: 18-char component ID
        // Record Information
        public String recordId { get; private set; }          // RECORD_ID: 15-char record ID
        public String recordIdDerived { get; private set; }   // RECORD_ID_DERIVED: 18-char record ID
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }          // CPU_TIME: CPU time in milliseconds
        public Integer dbTotalTime { get; private set; }      // DB_TOTAL_TIME: Database time in nanoseconds
        public Integer runTime { get; private set; }          // RUN_TIME: Request time in milliseconds
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String requestStatus { get; private set; }     // REQUEST_STATUS: Request status (S/F/U/A/R/N)
        public RequestStatus requestStatusEnum { get; private set; }
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID
        
        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }          // USER_TYPE: Category of user license
        public UserType userTypeEnum { get; private set; }

        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ConsoleEventData(Map<String, Object> eventData) {
            super(eventData);
            
            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
        }
    }

    public class ConcurrentLongRunningApexLimitData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT;
        // Request Metrics
        public Integer numberRequests { get; private set; }   // NUMBER_REQUESTS: Count of long-running requests
        public Integer requestsLimit { get; private set; }    // REQUESTS_LIMIT: Maximum allowed long-running requests
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String requestUri { get; private set; }        // REQUEST_URI: URI of terminated Apex request
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ConcurrentLongRunningApexLimitData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ReportEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_REPORT;
        // Report Identification
        public String reportId { get; private set; }         // REPORT_ID: 15-char report ID
        public String reportIdDerived { get; private set; }  // REPORT_ID_DERIVED: 18-char ID
        
        // Report Configuration
        public String displayType { get; private set; }      // DISPLAY_TYPE: D/S/H
        public String renderingType { get; private set; }    // RENDERING_TYPE: W/E/P/X/C/J/D
        public String origin { get; private set; }           // ORIGIN: Execution context
        public String sortValue { get; private set; }        // SORT: Sort column and order
        public String entityName { get; private set; }       // ENTITY_NAME: Affected object
        
        // Report Metrics
        public Integer averageRowSize { get; private set; }  // AVERAGE_ROW_SIZE: Bytes per row
        public Integer rowCount { get; private set; }        // ROW_COUNT: Number of rows
        public Integer numberBuckets { get; private set; }   // NUMBER_BUCKETS: Bucket count
        public Integer numberColumns { get; private set; }   // NUMBER_COLUMNS: Column count
        public Integer uiNumberColumns { get; private set; } // UI_NUMBER_COLUMNS: UI columns
        public Integer numberExceptionFilters { get; private set; } // NUMBER_EXCEPTION_FILTERS
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer dbBlocks { get; private set; }        // DB_BLOCKS: DB block usage
        public Integer dbCpuTime { get; private set; }       // DB_CPU_TIME: DB CPU time (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: Total DB time (ns)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String requestStatus { get; private set; }    // REQUEST_STATUS: S/F/U/A/R/N
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Client Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }         // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601
        
        public ReportEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ApexRestApiEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_REST_API;
        // Required fields
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String userIdDerived { get; private set; }      // USER_ID_DERIVED: 18-character user ID
        
        // API Details
        public String method { get; private set; }             // METHOD: HTTP method (GET, POST, etc.)
        public String mediaType { get; private set; }          // MEDIA_TYPE: Response media type
        public String connectedAppId { get; private set; }     // CONNECTED_APP_ID: Connected app's ID
        public String entityName { get; private set; }         // ENTITY_NAME: Accessed API objects
        public String exceptionMessage { get; private set; }   // EXCEPTION_MESSAGE: Error details
        public String query { get; private set; }              // QUERY: Query string
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time used (ms)
        public Integer dbBlocks { get; private set; }          // DB_BLOCKS: Database block usage
        public Integer dbCpuTime { get; private set; }         // DB_CPU_TIME: Database CPU time (ms)
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: Total DB time (ns)
        public Integer requestSize { get; private set; }       // REQUEST_SIZE: Request body size (bytes)
        public Integer responseSize { get; private set; }      // RESPONSE_SIZE: Response size (bytes)
        public Integer rowsProcessed { get; private set; }     // ROWS_PROCESSED: Number of rows
        public Integer runTime { get; private set; }           // RUN_TIME: Total request time (ms)
        public Integer numberFields { get; private set; }      // NUMBER_FIELDS: Number of fields/columns
        public Integer statusCode { get; private set; }        // STATUS_CODE: HTTP status code
        public Integer userAgent { get; private set; }         // USER_AGENT: Client type code
        
        // Request information
        public String requestStatus { get; private set; }      // REQUEST_STATUS: Request status
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        public String clientName { get; private set; }         // CLIENT_NAME: Client name
        public String userType { get; private set; }           // USER_TYPE: User license category
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ApexRestApiEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class AsyncReportRunEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN;
        // Report identification
        public String reportId { get; private set; }           // REPORT_ID: 15-char report ID
        public String reportIdDerived { get; private set; }    // REPORT_ID_DERIVED: 18-char report ID
        public String dashboardId { get; private set; }        // DASHBOARD_ID: Dashboard ID
        
        // Report metrics
        public Integer averageRowSize { get; private set; }    // AVERAGE_ROW_SIZE: Avg row size in bytes
        public Integer rowCount { get; private set; }          // ROW_COUNT: Number of rows processed
        public Integer numberBuckets { get; private set; }     // NUMBER_BUCKETS: Number of buckets
        public Integer numberColumns { get; private set; }     // NUMBER_COLUMNS: Number of columns
        public Integer numberExceptionFilters { get; private set; } // NUMBER_EXCEPTION_FILTERS
        
        // Report configuration
        public String displayType { get; private set; }     // DISPLAY_TYPE: Raw display type
        public DisplayType displayTypeEnum { get; private set; }   // DISPLAY_TYPE: Parsed enum
        public String renderingType { get; private set; }   // RENDERING_TYPE: Raw rendering type
        public RenderingType renderingTypeEnum { get; private set; } // RENDERING_TYPE: Parsed enum
        public String origin { get; private set; }          // ORIGIN: Raw origin value
        public Origin originEnum { get; private set; }             // ORIGIN: Parsed enum
        public String sortValue { get; private set; }               // SORT: Sort column and order
        public String entityName { get; private set; }             // ENTITY_NAME: Affected object
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time in ms
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: DB round trip time
        public Integer dbBlocks { get; private set; }          // DB_BLOCKS: DB block usage
        public Integer dbCpuTime { get; private set; }         // DB_CPU_TIME: DB CPU time
        public Integer runTime { get; private set; }

        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String requestStatus { get; private set; }     // REQUEST_STATUS: Request status (S/F/U/A/R/N)
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID

        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address

        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }          // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }

        // Session Information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        public AsyncReportRunEventData(Map<String, Object> eventData) {
            super(eventData);
            
            this.displayTypeEnum = convertDisplayType(this.displayType);
            this.renderingTypeEnum = convertRenderingType(renderingType);
            this.originEnum = convertOrigin(origin);
        }
    }

    public class InsufficientAccessData extends BaseEventData {
        public String eventType = EVENT_TYPE_INSUFFICIENT_ACCESS;
        // Error Information
        public String accessError { get; private set; }      // ACCESS_ERROR: Error type
        public AccessErrorType accessErrorEnum { get; private set; }
        public String errorDescription { get; private set; } // ERROR_DESCRIPTION: Error details
        public String errorTimestamp { get; private set; }   // ERROR_TIMESTAMP: Error time in GMT
        
        // Access Information
        public String requestedAccessLevel { get; private set; }    // REQUESTED_ACCESS_LEVEL
        public RequiredAccessLevel accessLevelEnum { get; private set; }
        
        // Record Information
        public String entityType { get; private set; }       // ENTITY_TYPE: Object type
        public String recordId { get; private set; }         // RECORD_ID: Inaccessible record ID
        
        // User Information
        public String actualLoggedInUserId { get; private set; }  // ACTUAL_LOGGED_IN_USER_ID
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public InsufficientAccessData(Map<String, Object> eventData) {
            super(eventData);

            this.accessErrorEnum = convertAccessErrorType(accessError);
            this.accessLevelEnum = convertRequiredAccessLevel(requestedAccessLevel);
        }
    }

    public class InsecureExternalAssetsData extends BaseEventData {
        public String eventType = EVENT_TYPE_INSECURE_EXTERNAL_ASSETS;
        // Asset Information
        public String assetType { get; private set; }        // ASSET_TYPE: Type of insecure asset
        public InsecureAssetType assetTypeEnum { get; private set; }
        public String insecureUri { get; private set; }      // INSECURE_URI: Insecure asset URL
        
        // Page Information
        public String type { get; private set; }             // TYPE: Salesforce page type
        public InsecurePageType pageTypeEnum { get; private set; }
        public String documentUri { get; private set; }      // DOCUMENT_URI: Page URL without query
        
        // CSP Information
        public String disposition { get; private set; }      // DISPOSITION: CSP header type
        public CSPDisposition dispositionEnum { get; private set; }
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        public String networkId { get; private set; }        // NETWORK_ID: Experience Cloud site ID
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Event Information
        public String uniqueId { get; private set; }         // UNIQUE_ID: 32-char event log file ID
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public InsecureExternalAssetsData(Map<String, Object> eventData) {
            super(eventData);

            this.assetTypeEnum = convertInsecureAssetType(assetType);
            this.pageTypeEnum = convertInsecurePageType(type);
            this.dispositionEnum = convertCSPDisposition(disposition);
        }
    }

    public class HostnameRedirectsData extends BaseEventData {
        public String eventType = EVENT_TYPE_HOSTNAME_REDIRECTS;
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Hostname Information
        public String sourceHostname { get; private set; }   // SOURCE_HOSTNAME: Original hostname
        public String targetHostname { get; private set; }   // TARGET_HOSTNAME: Redirect target
        public String path { get; private set; }            // PATH: URL path without query string
        
        // Redirect Information
        public String redirectReason { get; private set; }   // REDIRECT_REASON: Reason for redirect
        public Boolean isBlockedRedirection { get; private set; } // IS_BLOCKED_REDIRECTION: Block status
        
        // Request Context
        public String referrer { get; private set; }        // REFERRER: Request referrer URL
        public String origin { get; private set; }          // ORIGIN: Request origin
         
        public HostnameRedirectsData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class GroupMembershipData extends BaseEventData {
        public String eventType = EVENT_TYPE_GROUP_MEMBERSHIP;

        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Group Information
        public String groupId { get; private set; }          // GROUP_ID: Group ID
        public String groupType { get; private set; }        // GROUP_TYPE: R or Q
        
        // Member Information
        public String memberId { get; private set; }         // MEMBER_ID: Added/removed member ID
        
        // Operation Information
        public String operation { get; private set; }        // OPERATION: Add/Delete operation
        
        // Event Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain identifier
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Session Information
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID

        public GroupMembershipData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class FlowExecutionEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_FLOW_EXECUTION;
        // Flow Information
        public String processType { get; private set; }       // PROCESS_TYPE: Type of flow
        public String flowVersionId { get; private set; }     // FLOW_VERSION_ID: Flow version ID
        
        // Performance Metrics
        public Integer flowLoadTime { get; private set; }     // FLOW_LOAD_TIME: Metadata load time (ms)
        public Integer totalExecutionTime { get; private set; } // TOTAL_EXECUTION_TIME: Total execution time (ms)
        
        // Execution Statistics
        public Integer numberOfInterviews { get; private set; } // NUMBER_OF_INTERVIEWS: Interview count
        public Integer numberOfErrors { get; private set; }     // NUMBER_OF_ERRORS: Error count
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: Derived from event timestamp

        public FlowExecutionEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class SitesEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_SITES;

        // Site Information// Page Information
        public String pageName { get; private set; }        // PAGE_NAME: Visualforce page name
        public String siteId { get; private set; }          // SITE_ID: 15-char site ID
        
        // Request Information
        public String httpMethod { get; private set; }      // HTTP_METHOD: GET/POST/PUT etc.
        public String httpHeaders { get; private set; }     // HTTP_HEADERS: Request headers
        public String requestType { get; private set; }     // REQUEST_TYPE: page/content/PDF
        public String requestStatus { get; private set; }   // REQUEST_STATUS: S/F/U/A/R/N
        public RequestStatus requestStatusEnum { get; private set; }
        public String query { get; private set; }           // QUERY: SOQL query if any
        public String uri { get; private set; }             // URI: Request URI
        public String uriIdDerived { get; private set; }    // URI_ID_DERIVED: 18-char URI ID
        
        // Request Flags
        public Boolean isApi { get; private set; }          // IS_API: API/Web Services request
        public Boolean isError { get; private set; }        // IS_ERROR: Error page
        public Boolean isFirstRequest { get; private set; } // IS_FIRST_REQUEST: First VF transaction
        public Boolean isGuest { get; private set; }        // IS_GUEST: Unauthenticated request
        public Boolean isSecure { get; private set; }       // IS_SECURE: Secure request
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }        // CPU_TIME: CPU usage (ms)
        public Integer dbTotalTime { get; private set; }    // DB_TOTAL_TIME: DB round trip (ns)
        public Integer runTime { get; private set; }        // RUN_TIME: Total time (ms)
        
        // Client Information
        public String clientIp { get; private set; }        // CLIENT_IP: Client IP address
        
        // Session Information
        public String loginKey { get; private set; }        // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }      // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }   // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }        // USER_TYPE: License category
        public UserType userTypeEnum { get; private set; }
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public SitesEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class SearchClickEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_SEARCH_CLICK;
        // Click Information
        public String clickedRecordId { get; private set; } // CLICKED_RECORD_ID: Selected record
        public Integer rank { get; private set; }           // RANK: Result ranking
        
        // Search Information
        public String queryId { get; private set; }         // QUERY_ID: Related search query ID
        
        // Organization Information
        public String organizationId { get; private set; }  // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }       // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public SearchClickEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class SearchEventData extends BaseEventData {
        public String eventType = EVENT_TYPE_SEARCH;

        // Search Information
        public String searchQuery { get; private set; }      // SEARCH_QUERY: First 100 chars
        public String queryId { get; private set; }          // QUERY_ID: Unique search ID
        public Integer numResults { get; private set; }      // NUM_RESULTS: Result count
        public String prefixesSearched { get; private set; } // PREFIXES_SEARCHED: Key prefixes
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601

        public SearchEventData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class SandboxData extends BaseEventData {
        public String eventType = EVENT_TYPE_SANDBOX;
        
        // Sandbox Organization Information
        public String currentSandboxOrgId { get; private set; }  // CURRENT_SANDBOX_ORG_ID
        public String pendingSandboxOrgId { get; private set; }  // PENDING_SANDBOX_ORG_ID
        public String sandboxId { get; private set; }            // SANDBOX_ID
        
        // Organization Information
        public String organizationId { get; private set; }       // ORGANIZATION_ID: 15-char org ID
        
        // Status Information
        public String status { get; private set; }               // STATUS: Sandbox copy status
        
        // Request Information
        public String requestId { get; private set; }            // REQUEST_ID: Transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }        // USER_ID_DERIVED: 18-char user ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; }   // TIMESTAMP_DERIVED: ISO8601


        public SandboxData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ApexTriggerData extends BaseEventData {
        public String eventType = EVENT_TYPE_APEX_TRIGGER;
        // Trigger identification
        public String triggerId { get; private set; }          // TRIGGER_ID: 15-char trigger ID
        public String triggerName { get; private set; }        // TRIGGER_NAME: Name with optional namespace
        public String triggerType { get; private set; }     // TRIGGER_TYPE: Raw trigger type
        public TriggerType triggerTypeEnum { get; private set; }   // TRIGGER_TYPE: Parsed enum
        
        // Context information
        public String entityName { get; private set; }         // ENTITY_NAME: Affected object name
        
        // Performance metrics
        public Integer cpuTime { get; private set; }           // CPU_TIME: CPU time in ms
        public Integer dbTotalTime { get; private set; }       // DB_TOTAL_TIME: DB processing time
        public Integer execTime { get; private set; }          // EXEC_TIME: Total execution time
        
        // Request information
        public String requestId { get; private set; }          // REQUEST_ID: Unique transaction ID
        public String requestStatus { get; private set; }      // REQUEST_STATUS: Request status
        public RequestStatus requestStatusEnum { get; private set; }
        public String uri { get; private set; }                // URI: Request URI
        public String uriIdDerived { get; private set; }       // URI_ID_DERIVED: 18-char URI ID
        
        // Client information
        public String clientIp { get; private set; }           // CLIENT_IP: Client IP address
        public String userType { get; private set; }           // USER_TYPE: User license category
        public UserType userTypeEnum { get; private set; }
        
        // Session information
        public String loginKey { get; private set; }           // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }         // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }     // ORGANIZATION_ID: 15-char org ID
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: Derived from event timestamp

        public ApexTriggerData(Map<String, Object> eventData) {
            super(eventData);
            
            this.triggerTypeEnum = convertTriggerType(this.triggerType);
            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
            this.userTypeEnum = convertUserType(this.userType);
        }
    }

    public class ChangeSetOperationData extends BaseEventData {
        public String eventType = EVENT_TYPE_CHANGE_SET_OPERATION;
        // Change Set Information
        public String changeSetName { get; private set; }     // CHANGE_SET_NAME: Name of the change set
        public String operation { get; private set; }         // OPERATION: Operation being performed (DELETE/DEPLOY/UPLOAD/VALIDATE)
        public ChangeSetOperationType operationEnum { get; private set; }
        public String targetOrgId { get; private set; }       // TARGET_ORG_ID: 15-char ID of receiving org
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }          // CPU_TIME: CPU time in milliseconds
        public Integer runTime { get; private set; }          // RUN_TIME: Request time in milliseconds
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID
        
        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ChangeSetOperationData(Map<String, Object> eventData) {
            super(eventData);
            
            this.operationEnum = convertChangeSetOperation(operation);
        }
    }

    public class BulkApi2Data extends BaseEventData {
        public String eventType = EVENT_TYPE_BULK_API_2;
        // Job Information
        public String jobId { get; private set; }             // JOB_ID: 15-char Bulk API 2.0 job ID
        public String jobStatus { get; private set; }         // JOB_STATUS: Current job status
        public String entityType { get; private set; }        // ENTITY_TYPE: Type of entity used
        public String operationType { get; private set; }     // OPERATION_TYPE: Type of operation
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }          // CPU_TIME: CPU time in milliseconds
        public Integer runTime { get; private set; }          // RUN_TIME: Request time in milliseconds
        
        // Record Processing Statistics
        public Integer recordsProcessed { get; private set; } // RECORDS_PROCESSED: Number of records processed
        public Integer recordsFailed { get; private set; }    // RECORDS_FAILED: Number of failed records
        public Integer resultSizeMb { get; private set; }     // RESULT_SIZE_MB: Size of query results in MB
        
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID
        
        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public BulkApi2Data(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class BulkApiRequestData extends BaseEventData {
        public String eventType = EVENT_TYPE_BULK_API_REQUEST;
        // API Information
        public Integer apiVersion { get; private set; }       // API_VERSION: The API version
        public String concurrencyMode { get; private set; }   // CONCURRENCY_MODE: Selected concurrency mode
        
        // Bulk API Operation Details
        public String batchId { get; private set; }           // BATCH_ID: 15-char Bulk API batch ID
        public String jobId { get; private set; }             // JOB_ID: 15-char Bulk API job ID
        public String operationType { get; private set; }     // OPERATION_TYPE: Type of Bulk API operation
        public String errorMessage { get; private set; }      // ERROR_MESSAGE: Entity type used
        
        // Request Details
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        public String requestPath { get; private set; }       // REQUEST_PATH: Path of the request
        public Integer statusCode { get; private set; }       // STATUS_CODE: HTTP Status code
        public Boolean success { get; private set; }          // SUCCESS: Whether batch was successful
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }          // CPU_TIME: CPU time in milliseconds
        public Integer runTime { get; private set; }          // RUN_TIME: Request time in milliseconds
        
        // Client Information
        public String clientIp { get; private set; }          // CLIENT_IP: Client IP address
        public String clientName { get; private set; }        // CLIENT_NAME: Name of client making request
        public String connectedAppId { get; private set; }    // CONNECTED_APP_ID: Connected app ID
        
        // URI Information
        public String uri { get; private set; }               // URI: Request URI
        public String uriIdDerived { get; private set; }      // URI_ID_DERIVED: 18-char URI ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Session Information
        public String loginKey { get; private set; }          // LOGIN_KEY: Session event chain
        public String sessionKey { get; private set; }        // SESSION_KEY: Unique session ID
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public BulkApiRequestData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class ContentDocumentLinkData extends BaseEventData {
        public String eventType = EVENT_TYPE_CONTENT_DOCUMENT_LINK;
        // Document Information
        public String documentId { get; private set; }        // DOCUMENT_ID: 15-char document ID
        
        // Sharing Information
        public String sharedWithEntityId { get; private set; } // SHARED_WITH_ENTITY_ID: Entity shared with
        public String sharingOperation { get; private set; }   // SHARING_OPERATION: Type of sharing (INSERT/UPDATE/DELETE)
        public SharingOperationType sharingOperationEnum { get; private set; }
        public String sharingPermission { get; private set; }  // SHARING_PERMISSION: Permission level (V/C/I)
        public SharingPermissionType sharingPermissionEnum { get; private set; }
        // Request Information
        public String requestId { get; private set; }         // REQUEST_ID: Unique transaction ID
        
        // User Information
        public String userIdDerived { get; private set; }     // USER_ID_DERIVED: 18-char user ID
        
        // Organization Information
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time

        public ContentDocumentLinkData(Map<String, Object> eventData) {
            super(eventData);
            
            this.sharingOperationEnum = convertSharingOperationType(sharingOperation);
            this.sharingPermissionEnum = convertSharingPermissionType(sharingPermission);
        }
    }

    public class QueuedExecutionData extends BaseEventData {
        public String eventType = EVENT_TYPE_QUEUED_EXECUTION;
        // Execution Information
        public String entryPoint { get; private set; }       // ENTRY_POINT: Apex class name
        public String jobId { get; private set; }            // JOB_ID: Batch job ID
        public String requestStatus { get; private set; }    // REQUEST_STATUS
        public RequestStatus requestStatusEnum { get; private set; }
        
        // Performance Metrics
        public Integer cpuTime { get; private set; }         // CPU_TIME: CPU usage (ms)
        public Integer dbTotalTime { get; private set; }     // DB_TOTAL_TIME: DB time (ns)
        public Integer runTime { get; private set; }         // RUN_TIME: Total time (ms)
        
        // Network Information
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Session chain ID
        public String sessionKey { get; private set; }       // SESSION_KEY: Unique session ID
        
        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID
        public String uri { get; private set; }              // URI: Request URI
        public String uriIdDerived { get; private set; }     // URI_ID_DERIVED: 18-char URI ID
        
        // Organization Information
        public String organizationId { get; private set; }   // ORGANIZATION_ID: 15-char org ID
        
        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        // User Information
        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char user ID
        public String userType { get; private set; }         // USER_TYPE: License category
        
        public QueuedExecutionData(Map<String, Object> eventData) {
            super(eventData);

            this.requestStatusEnum = convertRequestStatus(this.requestStatus);
        }
    }

    public class LightningPerformanceData extends BaseEventData {
        public String eventType = EVENT_TYPE_LIGHTNING_PERFORMANCE;
        // Application Information
        public String appName { get; private set; }          // APP_NAME: Application name
        
        // Performance Metrics
        public Long pageStartTime { get; private set; }      // PAGE_START_TIME: Load start time
        public Integer duration { get; private set; }        // DURATION: Duration since start
        
        // Event Information
        public String uiEventId { get; private set; }        // UI_EVENT_ID: Event type ID
        public String uiEventSource { get; private set; }    // UI_EVENT_SOURCE: User action
        public Long uiEventTimestamp { get; private set; }   // UI_EVENT_TIMESTAMP: Event time
        public String uiEventType { get; private set; }      // UI_EVENT_TYPE: Performance type
        
        // Client Information
        public String browserName { get; private set; }      // BROWSER_NAME: Browser name
        public String browserVersion { get; private set; }   // BROWSER_VERSION: Browser version
        public String clientGeo { get; private set; }        // CLIENT_GEO: Client geolocation
        public String clientId { get; private set; }         // CLIENT_ID: API client ID
        public String clientIp { get; private set; }         // CLIENT_IP: Client IP address
        
        // Device Information
        public String deviceId { get; private set; }         // DEVICE_ID: Unique device ID
        public String deviceModel { get; private set; }      // DEVICE_MODEL: Device model
        public String devicePlatform { get; private set; }   // DEVICE_PLATFORM: Platform info
        public String deviceSessionId { get; private set; }  // DEVICE_SESSION_ID: Session ID
        public String connectionType { get; private set; }   // CONNECTION_TYPE: Network type
        
        // System Information
        public String osName { get; private set; }           // OS_NAME: Operating system
        public String osVersion { get; private set; }        // OS_VERSION: OS version
        public String sdkAppType { get; private set; }       // SDK_APP_TYPE: SDK app type
        public String sdkAppVersion { get; private set; }    // SDK_APP_VERSION: App version
        public String sdkVersion { get; private set; }       // SDK_VERSION: SDK version
        
        // Session Information
        public String loginKey { get; private set; }         // LOGIN_KEY: Login session key
        public String sessionKey { get; private set; }       // SESSION_KEY: User session key
        public String organizationId { get; private set; }    // ORGANIZATION_ID: 15-char org ID

        public String userIdDerived { get; private set; }    // USER_ID_DERIVED: 18-char ID
        public String userType { get; private set; }         // USER_TYPE: User license type
        public String userAgent { get; private set; }        // USER_AGENT: Client type code

        // Request Information
        public String requestId { get; private set; }        // REQUEST_ID: Transaction ID

        // Timestamp Information
        public DateTime timestampDerived { get; private set; } // TIMESTAMP_DERIVED: ISO8601 time
        
        public LightningPerformanceData(Map<String, Object> eventData) {
            super(eventData);
        }
    }

    public class BulkApiRequestProcessor extends EventLogProcessor {
        public BulkApiRequestProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'number');
            this.addFilterField(FIELD_CONCURRENCY_MODE, 'Concurrency Mode', 'string');
            this.addFilterField(FIELD_BATCH_ID, 'Batch ID', 'string');
            this.addFilterField(FIELD_JOB_ID, 'Job ID', 'string');
            this.addFilterField(FIELD_OPERATION_TYPE, 'Operation Type', 'string');
            this.addFilterField(FIELD_ERROR_MESSAGE, 'Error Message', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_PATH, 'Request Path', 'string');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_SUCCESS, 'Success', 'boolean');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_CONNECTED_APP_ID, 'Connected App ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            BulkApiRequestData data = new BulkApiRequestData(eventData);
            data.apiVersion = getIntegerField(fields, headerMap, FIELD_API_VERSION);
            data.concurrencyMode = getField(fields, headerMap, FIELD_CONCURRENCY_MODE);
            data.batchId = getField(fields, headerMap, FIELD_BATCH_ID);
            data.jobId = getField(fields, headerMap, FIELD_JOB_ID);
            data.operationType = getField(fields, headerMap, FIELD_OPERATION_TYPE);
            data.errorMessage = getField(fields, headerMap, FIELD_ERROR_MESSAGE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestPath = getField(fields, headerMap, FIELD_REQUEST_PATH);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.success = getBooleanField(fields, headerMap, FIELD_SUCCESS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.connectedAppId = getField(fields, headerMap, FIELD_CONNECTED_APP_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ChangeSetOperationProcessor extends EventLogProcessor {
        public ChangeSetOperationProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CHANGE_SET_NAME, 'Change Set Name', 'string');
            this.addFilterField(FIELD_OPERATION, 'Operation', 'string');
            this.addFilterField(FIELD_TARGET_ORG_ID, 'Target Org ID', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ChangeSetOperationData data = new ChangeSetOperationData(eventData);
            data.changeSetName = getField(fields, headerMap, FIELD_CHANGE_SET_NAME);
            data.operation = getField(fields, headerMap, FIELD_OPERATION);
            data.targetOrgId = getField(fields, headerMap, FIELD_TARGET_ORG_ID);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class BulkApi2Processor extends EventLogProcessor {
        public BulkApi2Processor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_JOB_ID, 'Job ID', 'string');
            this.addFilterField(FIELD_JOB_STATUS, 'Job Status', 'string');
            this.addFilterField(FIELD_ENTITY_TYPE, 'Entity Type', 'string');
            this.addFilterField(FIELD_OPERATION_TYPE, 'Operation Type', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_RECORDS_PROCESSED, 'Records Processed', 'number');
            this.addFilterField(FIELD_RECORDS_FAILED, 'Records Failed', 'number');
            this.addFilterField(FIELD_RESULT_SIZE_MB, 'Result Size MB', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }
        
        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            BulkApi2Data data = new BulkApi2Data(eventData);
            data.jobId = getField(fields, headerMap, FIELD_JOB_ID);
            data.jobStatus = getField(fields, headerMap, FIELD_JOB_STATUS);
            data.entityType = getField(fields, headerMap, FIELD_ENTITY_TYPE);
            data.operationType = getField(fields, headerMap, FIELD_OPERATION_TYPE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.recordsProcessed = getIntegerField(fields, headerMap, FIELD_RECORDS_PROCESSED);
            data.recordsFailed = getIntegerField(fields, headerMap, FIELD_RECORDS_FAILED);
            data.resultSizeMb = getIntegerField(fields, headerMap, FIELD_RESULT_SIZE_MB);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    /**
     * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_apitotalusage.htm
     */
    public class ApiTotalUsageProcessor extends EventLogProcessor {
        public ApiTotalUsageProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_API_FAMILY, 'API Family', 'string');
            this.addFilterField(FIELD_API_RESOURCE, 'API Resource', 'string');
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_CONNECTED_APP_ID, 'Connected App ID', 'string');
            this.addFilterField(FIELD_CONNECTED_APP_NAME, 'Connected App Name', 'string');
            this.addFilterField(FIELD_HTTP_METHOD, 'HTTP Method', 'string');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_COUNTS_AGAINST_API_LIMIT, 'Counts Against API Limit', 'boolean');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_USER_NAME, 'User Name', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApiTotalUsageData data = new ApiTotalUsageData(eventData);
            data.apiFamily = getField(fields, headerMap, FIELD_API_FAMILY);
            data.apiResource = getField(fields, headerMap, FIELD_API_RESOURCE);
            data.apiVersion = getIntegerField(fields, headerMap, FIELD_API_VERSION);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.connectedAppId = getField(fields, headerMap, FIELD_CONNECTED_APP_ID);
            data.connectedAppName = getField(fields, headerMap, FIELD_CONNECTED_APP_NAME);
            data.httpMethod = getField(fields, headerMap, FIELD_HTTP_METHOD);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.countsAgainstApiLimit = getBooleanField(fields, headerMap, FIELD_COUNTS_AGAINST_API_LIMIT);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.userName = getField(fields, headerMap, FIELD_USER_NAME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ApexUnexpectedExceptionProcessor extends EventLogProcessor {
        public ApexUnexpectedExceptionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_EXCEPTION_CATEGORY, 'Exception Category', 'string');
            this.addFilterField(FIELD_EXCEPTION_MESSAGE, 'Exception Message', 'string');
            this.addFilterField(FIELD_EXCEPTION_TYPE, 'Exception Type', 'string');
            this.addFilterField(FIELD_STACK_TRACE, 'Stack Trace', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID, 'User ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexUnexpectedExceptionData data = new ApexUnexpectedExceptionData(eventData);
            data.exceptionCategory = getField(fields, headerMap, FIELD_EXCEPTION_CATEGORY);
            data.exceptionMessage = getField(fields, headerMap, FIELD_EXCEPTION_MESSAGE);
            data.exceptionType = getField(fields, headerMap, FIELD_EXCEPTION_TYPE);
            data.stackTrace = getField(fields, headerMap, FIELD_STACK_TRACE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userId = getField(fields, headerMap, FIELD_USER_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.hash1 = getField(fields, headerMap, 'HASH_1');
            
            return data;
        }
    }

    public class ApexTriggerProcessor extends EventLogProcessor {
        public ApexTriggerProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_TRIGGER_ID, 'Trigger ID', 'string');
            this.addFilterField(FIELD_TRIGGER_NAME, 'Trigger Name', 'string');
            this.addFilterField(FIELD_TRIGGER_TYPE, 'Trigger Type', 'string');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_EXEC_TIME, 'Exec Time', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }
        
        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexTriggerData data = new ApexTriggerData(eventData);
            data.triggerId = getField(fields, headerMap, FIELD_TRIGGER_ID);
            data.triggerName = getField(fields, headerMap, FIELD_TRIGGER_NAME);
            data.triggerType = getField(fields, headerMap, FIELD_TRIGGER_TYPE);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.execTime = getIntegerField(fields, headerMap, FIELD_EXEC_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class SitesEventProcessor extends EventLogProcessor {
        public SitesEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_PAGE_NAME, 'Page Name', 'string');
            this.addFilterField(FIELD_SITE_ID, 'Site ID', 'string');
            this.addFilterField(FIELD_HTTP_METHOD, 'HTTP Method', 'string');
            this.addFilterField(FIELD_HTTP_HEADERS, 'HTTP Headers', 'string');
            this.addFilterField(FIELD_REQUEST_TYPE, 'Request Type', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_QUERY, 'Query', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_IS_API, 'Is API', 'boolean');
            this.addFilterField(FIELD_IS_ERROR, 'Is Error', 'boolean');
            this.addFilterField(FIELD_IS_FIRST_REQUEST, 'Is First Request', 'boolean');
            this.addFilterField(FIELD_IS_GUEST, 'Is Guest', 'boolean');
            this.addFilterField(FIELD_IS_SECURE, 'Is Secure', 'boolean');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            SitesEventData data = new SitesEventData(eventData);
            data.pageName = getField(fields, headerMap, FIELD_PAGE_NAME);
            data.siteId = getField(fields, headerMap, FIELD_SITE_ID);
            data.httpMethod = getField(fields, headerMap, FIELD_HTTP_METHOD);
            data.httpHeaders = getField(fields, headerMap, FIELD_HTTP_HEADERS);
            data.requestType = getField(fields, headerMap, FIELD_REQUEST_TYPE);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.query = getField(fields, headerMap, FIELD_QUERY);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.isApi = getBooleanField(fields, headerMap, FIELD_IS_API);
            data.isError = getBooleanField(fields, headerMap, FIELD_IS_ERROR);
            data.isFirstRequest = getBooleanField(fields, headerMap, FIELD_IS_FIRST_REQUEST);
            data.isGuest = getBooleanField(fields, headerMap, FIELD_IS_GUEST);
            data.isSecure = getBooleanField(fields, headerMap, FIELD_IS_SECURE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class SearchClickEventProcessor extends EventLogProcessor {
        public SearchClickEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CLICKED_RECORD_ID, 'Clicked Record ID', 'string');
            this.addFilterField(FIELD_RANK, 'Rank', 'number');
            this.addFilterField(FIELD_QUERY_ID, 'Query ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            SearchClickEventData data = new SearchClickEventData(eventData);
            data.clickedRecordId = getField(fields, headerMap, FIELD_CLICKED_RECORD_ID);
            data.rank = getIntegerField(fields, headerMap, FIELD_RANK);
            data.queryId = getField(fields, headerMap, FIELD_QUERY_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class SearchEventProcessor extends EventLogProcessor {
        public SearchEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_SEARCH_QUERY, 'Search Query', 'string');
            this.addFilterField(FIELD_QUERY_ID, 'Query ID', 'string');
            this.addFilterField(FIELD_NUM_RESULTS, 'Num Results', 'number');
            this.addFilterField(FIELD_PREFIXES_SEARCHED, 'Prefixes Searched', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            SearchEventData data = new SearchEventData(eventData);
            data.searchQuery = getField(fields, headerMap, FIELD_SEARCH_QUERY);
            data.queryId = getField(fields, headerMap, FIELD_QUERY_ID);
            data.numResults = getIntegerField(fields, headerMap, FIELD_NUM_RESULTS);
            data.prefixesSearched = getField(fields, headerMap, FIELD_PREFIXES_SEARCHED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class SandboxProcessor extends EventLogProcessor {
        public SandboxProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CURRENT_SANDBOX_ORG_ID, 'Current Sandbox Org ID', 'string');
            this.addFilterField(FIELD_PENDING_SANDBOX_ORG_ID, 'Pending Sandbox Org ID', 'string');
            this.addFilterField(FIELD_SANDBOX_ID, 'Sandbox ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_STATUS, 'Status', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }
        
        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            SandboxData data = new SandboxData(eventData);
            data.currentSandboxOrgId = getField(fields, headerMap, FIELD_CURRENT_SANDBOX_ORG_ID);
            data.pendingSandboxOrgId = getField(fields, headerMap,  FIELD_PENDING_SANDBOX_ORG_ID);
            data.sandboxId = getField(fields, headerMap, FIELD_SANDBOX_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.status = getField(fields, headerMap, FIELD_STATUS);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ApexCalloutProcessor extends EventLogProcessor {
        public ApexCalloutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_METHOD, 'Method', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_URL, 'URL', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_REQUEST_SIZE, 'Request Size', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_TIME, 'Time', 'string');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_SUCCESS, 'Success', 'boolean');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexCalloutData data = new ApexCalloutData(eventData);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.method = getField(fields, headerMap, FIELD_METHOD);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.url = getField(fields, headerMap, FIELD_URL);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.requestSize = getIntegerField(fields, headerMap, FIELD_REQUEST_SIZE);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.timeValue = getIntegerField(fields, headerMap, FIELD_TIME);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.success = getField(fields, headerMap, FIELD_SUCCESS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class SOAPAPIEventProcessor extends EventLogProcessor {
        public SOAPAPIEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_API_TYPE, 'API Type', 'string');
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'string');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_METHOD_NAME, 'Method Name', 'string');
            this.addFilterField(FIELD_EXCEPTION_MESSAGE, 'Exception Message', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'Db Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'Db CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_REQUEST_SIZE, 'Request Size', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_ROWS_PROCESSED, 'Rows Processed', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            SOAPAPIEventData data = new SOAPAPIEventData(eventData);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.apiType = getField(fields, headerMap, FIELD_API_TYPE);
            data.apiVersion = getField(fields, headerMap, FIELD_API_VERSION);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.methodName = getField(fields, headerMap, FIELD_METHOD_NAME);
            data.exceptionMessage = getField(fields, headerMap, FIELD_EXCEPTION_MESSAGE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.requestSize = getIntegerField(fields, headerMap, FIELD_REQUEST_SIZE);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.rowsProcessed = getIntegerField(fields, headerMap, FIELD_ROWS_PROCESSED);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ApexSOAPApiEventProcessor extends EventLogProcessor {
        public ApexSOAPApiEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_CLASS_NAME, 'Class Name', 'string');
            this.addFilterField(FIELD_METHOD_NAME, 'Method Name', 'string');
            this.addFilterField(FIELD_QUERY, 'Query', 'string');
            this.addFilterField(FIELD_EVENT_TYPE, 'Event Type', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_LIMIT_USAGE_PERCENT, 'Limit Usage Percent', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');

        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexSOAPApiEventData data = new ApexSOAPApiEventData(eventData);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.className = getField(fields, headerMap, FIELD_CLASS_NAME);
            data.methodName = getField(fields, headerMap, FIELD_METHOD_NAME);
            data.query = getField(fields, headerMap, FIELD_QUERY);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.limitUsagePercent = getDecimalField(fields, headerMap, FIELD_LIMIT_USAGE_PERCENT);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ApexExecutionProcessor extends EventLogProcessor {
        public ApexExecutionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_QUIDDITY, 'Quiddity', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_CALLOUT_TIME, 'Callout Time', 'number');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_EXEC_TIME, 'Exec Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_ENTRY_POINT, 'Entry Point', 'string');
            this.addFilterField(FIELD_IS_LONG_RUNNING_REQUEST, 'Is Long Running Request', 'boolean');
            this.addFilterField(FIELD_NUMBER_SOQL_QUERIES, 'Number SOQL Queries', 'number');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexExecutionData data = new ApexExecutionData(eventData);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.quiddity = getField(fields, headerMap, FIELD_QUIDDITY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.calloutTime = getIntegerField(fields, headerMap, FIELD_CALLOUT_TIME);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.execTime = getIntegerField(fields, headerMap, FIELD_EXEC_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.entryPoint = getField(fields, headerMap, FIELD_ENTRY_POINT);
            data.isLongRunningRequest = getBooleanField(fields, headerMap, FIELD_IS_LONG_RUNNING_REQUEST);
            data.numberSoqlQueries = getIntegerField(fields, headerMap, FIELD_NUMBER_SOQL_QUERIES);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class BulkApiEventProcessor extends EventLogProcessor {
        public BulkApiEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_BATCH_ID, 'Batch ID', 'string');
            this.addFilterField(FIELD_JOB_ID, 'Job ID', 'string');
            this.addFilterField(FIELD_ENTITY_TYPE, 'Entity Type', 'string');
            this.addFilterField(FIELD_OPERATION_TYPE, 'Operation Type', 'string');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_ROWS_PROCESSED, 'Rows Processed', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_NUMBER_FAILURES, 'Number Failures', 'number');
            this.addFilterField(FIELD_SUCCESS, 'Success', 'boolean');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            BulkApiEventData data = new BulkApiEventData(eventData);
            data.batchId = getField(fields, headerMap, FIELD_BATCH_ID);
            data.jobId = getField(fields, headerMap, FIELD_JOB_ID);
            data.entityType = getField(fields, headerMap, FIELD_ENTITY_TYPE);
            data.operationType = getField(fields, headerMap, FIELD_OPERATION_TYPE);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.rowsProcessed = getIntegerField(fields, headerMap, FIELD_ROWS_PROCESSED);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.numberFailures = getIntegerField(fields, headerMap, FIELD_NUMBER_FAILURES);
            data.success = getBooleanField(fields, headerMap, FIELD_SUCCESS);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ReportExportEventProcessor extends EventLogProcessor {
        public ReportExportEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REPORT_DESCRIPTION, 'Report Description', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_INFO, 'Client Info', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ReportExportEventData data = new ReportExportEventData(eventData);
            data.reportDescription = getField(fields, headerMap, FIELD_REPORT_DESCRIPTION);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientInfo = getField(fields, headerMap, FIELD_CLIENT_INFO);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class VisualforceRequestProcessor extends EventLogProcessor {
        public VisualforceRequestProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_PAGE_NAME, 'Page Name', 'string');
            this.addFilterField(FIELD_MANAGED_PACKAGE_NAMESPACE, 'Managed Package Namespace', 'string');
            this.addFilterField(FIELD_VIEW_STATE_SIZE, 'View State Size', 'number');
            this.addFilterField(FIELD_CONTROLLER_TYPE, 'Controller Type', 'number');
            this.addFilterField(FIELD_HTTP_METHOD, 'Http Method', 'string');
            this.addFilterField(FIELD_IS_AJAX_REQUEST, 'Is Ajax Request', 'boolean');
            this.addFilterField(FIELD_IS_FIRST_REQUEST, 'Is First Request', 'boolean');
            this.addFilterField(FIELD_QUERY, 'Query', 'string');
            this.addFilterField(FIELD_REQUEST_SIZE, 'Request Size', 'number');
            this.addFilterField(FIELD_REQUEST_TYPE, 'Request Type', 'string');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'Cpu Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'string');
            this.addFilterField(FIELD_DB_BLOCKS, 'Db Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'Db Cpu Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'Db Total Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            VisualforceRequestData data = new VisualforceRequestData(eventData);
            data.pageName = getField(fields, headerMap, FIELD_PAGE_NAME);
            data.managedPackageNamespace = getField(fields, headerMap, FIELD_MANAGED_PACKAGE_NAMESPACE);
            data.viewStateSize = getIntegerField(fields, headerMap, FIELD_VIEW_STATE_SIZE);
            data.controllerType = getIntegerField(fields, headerMap, FIELD_CONTROLLER_TYPE);
            data.httpMethod = getField(fields, headerMap, FIELD_HTTP_METHOD);
            data.isAjaxRequest = getBooleanField(fields, headerMap, FIELD_IS_AJAX_REQUEST);
            data.isFirstRequest = getBooleanField(fields, headerMap, FIELD_IS_FIRST_REQUEST);
            data.query = getField(fields, headerMap, FIELD_QUERY);
            data.requestSize = getIntegerField(fields, headerMap, FIELD_REQUEST_SIZE);
            data.requestType = getField(fields, headerMap, FIELD_REQUEST_TYPE);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userAgent = getIntegerField(fields, headerMap, FIELD_USER_AGENT);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LightningLoggerProcessor extends EventLogProcessor {
        public LightningLoggerProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_SEQUENCE, 'Sequence', 'number');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_UI_EVENT_RELATIVE_TIMESTAMP, 'UI Event Relative Timestamp', 'number');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LightningLoggerData data = new LightningLoggerData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.sequence = getIntegerField(fields, headerMap, FIELD_SEQUENCE);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiEventRelativeTimestamp = getIntegerField(fields, headerMap, FIELD_UI_EVENT_RELATIVE_TIMESTAMP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LightningInteractionProcessor extends EventLogProcessor {
        public LightningInteractionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_APP_NAME, 'Page App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_START_TIME, 'Page Start Time', 'number');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_TARGET_UI_ELEMENT, 'Target UI Element', 'string');
            this.addFilterField(FIELD_PARENT_UI_ELEMENT, 'Parent UI Element', 'string');
            this.addFilterField(FIELD_GRAND_PARENT_UI_ELEMENT, 'Grand Parent UI Element', 'string');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_DEVICE_ID, 'Device ID', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LightningInteractionData data = new LightningInteractionData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageAppName = getField(fields, headerMap, FIELD_PAGE_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageStartTime = getIntegerField(fields, headerMap, FIELD_PAGE_START_TIME);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.targetUiElement = getField(fields, headerMap, FIELD_TARGET_UI_ELEMENT);
            data.parentUiElement = getField(fields, headerMap, FIELD_PARENT_UI_ELEMENT);
            data.grandParentUiElement = getField(fields, headerMap, FIELD_GRAND_PARENT_UI_ELEMENT);
            data.componentName = getField(fields, headerMap, FIELD_COMPONENT_NAME);
            data.relatedList = getField(fields, headerMap, FIELD_RELATED_LIST);
            data.recordId = getListField(fields, headerMap, FIELD_RECORD_ID);
            data.recordType = getField(fields, headerMap, FIELD_RECORD_TYPE);
            data.uiEventId = getField(fields, headerMap, FIELD_UI_EVENT_ID);
            data.uiEventSequenceNum = getIntegerField(fields, headerMap, FIELD_UI_EVENT_SEQUENCE_NUM);
            data.uiEventSource = getField(fields, headerMap, FIELD_UI_EVENT_SOURCE);
            data.uiEventTimestamp = getIntegerField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiEventType = getField(fields, headerMap, FIELD_UI_EVENT_TYPE);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.deviceId = getField(fields, headerMap, FIELD_DEVICE_ID);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userAgent = getField(fields, headerMap, FIELD_USER_AGENT);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ExternalODataCalloutProcessor extends EventLogProcessor {
        public ExternalODataCalloutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_BYTES, 'Bytes', 'number');
            this.addFilterField(FIELD_ENTITY, 'Entity', 'string');
            this.addFilterField(FIELD_EXECUTE_MS, 'Execute MS', 'number');
            this.addFilterField(FIELD_FETCH_MS, 'Fetch MS', 'number');
            this.addFilterField(FIELD_TOTAL_MS, 'Total MS', 'number');
            this.addFilterField(FIELD_THROUGHPUT, 'Throughput', 'number');
            this.addFilterField(FIELD_EXPAND, 'Expand', 'string');
            this.addFilterField(FIELD_FILTER, 'Filter', 'string');
            this.addFilterField(FIELD_LIBRARY, 'Library', 'string');
            this.addFilterField(FIELD_LIMIT, 'Limit', 'number');
            this.addFilterField(FIELD_NEXT_LINK, 'Next Link', 'string');
            this.addFilterField(FIELD_OFFSET, 'Offset', 'number');
            this.addFilterField(FIELD_ORDER_BY, 'Order By', 'string');
            this.addFilterField(FIELD_SEARCH, 'Search', 'string');
            this.addFilterField(FIELD_SELECT, 'Select', 'string');
            this.addFilterField(FIELD_PROVIDER_TYPE, 'Provider Type', 'string');
            this.addFilterField(FIELD_RATE_LIMIT_USAGE_PERCENT, 'Rate Limit Usage Percent', 'number');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_ROWS, 'Rows', 'number');
            this.addFilterField(FIELD_ROWS_FETCHED, 'Rows Fetched', 'number');
            this.addFilterField(FIELD_STATUS, 'Status', 'boolean');
            this.addFilterField(FIELD_REQUESTS, 'Requests', 'number');
            this.addFilterField(FIELD_PARENT_CALLOUT, 'Parent Callout', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ExternalODataCalloutData data = new ExternalODataCalloutData(eventData);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.bytes = getIntegerField(fields, headerMap, FIELD_BYTES);
            data.entity = getField(fields, headerMap, FIELD_ENTITY);
            data.executeMs = getIntegerField(fields, headerMap, FIELD_EXECUTE_MS);
            data.fetchMs = getIntegerField(fields, headerMap, FIELD_FETCH_MS);
            data.totalMs = getIntegerField(fields, headerMap, FIELD_TOTAL_MS);
            data.throughput = getDecimalField(fields, headerMap, FIELD_THROUGHPUT);
            data.expand = getField(fields, headerMap, FIELD_EXPAND);
            data.filter = getField(fields, headerMap, FIELD_FILTER);
            data.library = getField(fields, headerMap, FIELD_LIBRARY);
            data.limitValue = getIntegerField(fields, headerMap, FIELD_LIMIT);
            data.nextLink = getField(fields, headerMap, FIELD_NEXT_LINK);
            data.offset = getIntegerField(fields, headerMap, FIELD_OFFSET);
            data.orderBy = getField(fields, headerMap, FIELD_ORDER_BY);
            data.search = getField(fields, headerMap, FIELD_SEARCH);
            data.selectValue = getField(fields, headerMap, FIELD_SELECT);
            data.providerType = getField(fields, headerMap, FIELD_PROVIDER_TYPE);
            data.rateLimitUsagePercent = getIntegerField(fields, headerMap, FIELD_RATE_LIMIT_USAGE_PERCENT);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.rows = getIntegerField(fields, headerMap, FIELD_ROWS);
            data.rowsFetched = getIntegerField(fields, headerMap, FIELD_ROWS_FETCHED);
            data.status = getBooleanField(fields, headerMap, FIELD_STATUS);
            data.requests = getIntegerField(fields, headerMap, FIELD_REQUESTS);
            data.parentCallout = getField(fields, headerMap, FIELD_PARENT_CALLOUT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ExternalDataSourceCalloutProcessor extends EventLogProcessor {
        public ExternalDataSourceCalloutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_DATA_SOURCE_NAME, 'Data Source Name', 'string');
            this.addFilterField(FIELD_PROVIDER_TYPE, 'Provider Type', 'string');
            this.addFilterField(FIELD_EXTERNAL_OBJECT, 'External Object', 'string');
            this.addFilterField(FIELD_TABLE_NAME, 'Table Name', 'string');
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_OPERATION, 'Operation', 'string');
            this.addFilterField(FIELD_FILTER, 'Filter', 'string');
            this.addFilterField(FIELD_SELECT, 'Select', 'string');
            this.addFilterField(FIELD_ORDER_BY, 'Order By', 'string');
            this.addFilterField(FIELD_SEARCH, 'Search', 'string');
            this.addFilterField(FIELD_LIMIT, 'Limit', 'number');
            this.addFilterField(FIELD_OFFSET, 'Offset', 'number');
            this.addFilterField(FIELD_FETCH_MS, 'Fetch MS', 'number');
            this.addFilterField(FIELD_TOTAL_MS, 'Total MS', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_THROUGHPUT, 'Throughput', 'number');
            this.addFilterField(FIELD_ROWS_FETCHED, 'Rows Fetched', 'number');
            this.addFilterField(FIELD_STATUS, 'Status', 'boolean');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_NEXT_LINK, 'Next Link', 'string');
            this.addFilterField(FIELD_PARENT_CALLOUT, 'Parent Callout', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ExternalDataSourceCalloutData data = new ExternalDataSourceCalloutData(eventData);
            data.dataSourceName = getField(fields, headerMap, FIELD_DATA_SOURCE_NAME);
            data.providerType = getField(fields, headerMap, FIELD_PROVIDER_TYPE);
            data.externalObject = getField(fields, headerMap, FIELD_EXTERNAL_OBJECT);
            data.tableName = getField(fields, headerMap, FIELD_TABLE_NAME);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.operation = getField(fields, headerMap, FIELD_OPERATION);
            data.filter = getField(fields, headerMap, FIELD_FILTER);
            data.selectValue = getField(fields, headerMap, FIELD_SELECT);
            data.orderBy = getField(fields, headerMap, FIELD_ORDER_BY);
            data.search = getField(fields, headerMap, FIELD_SEARCH);
            data.limitValue = getIntegerField(fields, headerMap, FIELD_LIMIT);
            data.offset = getIntegerField(fields, headerMap, FIELD_OFFSET);
            data.fetchMs = getIntegerField(fields, headerMap, FIELD_FETCH_MS);
            data.totalMs = getIntegerField(fields, headerMap, FIELD_TOTAL_MS);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.throughput = getDecimalField(fields, headerMap, FIELD_THROUGHPUT);
            data.rowsFetched = getIntegerField(fields, headerMap, FIELD_ROWS_FETCHED);
            data.status = getBooleanField(fields, headerMap, FIELD_STATUS);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.nextLink = getField(fields, headerMap, FIELD_NEXT_LINK);
            data.parentCallout = getField(fields, headerMap, FIELD_PARENT_CALLOUT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ExternalCrossOrgCalloutProcessor extends EventLogProcessor {
        public ExternalCrossOrgCalloutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_ENTITY, 'Entity', 'string');
            this.addFilterField(FIELD_EXECUTE_MS, 'Execute MS', 'number');
            this.addFilterField(FIELD_FETCH_MS, 'Fetch MS', 'number');
            this.addFilterField(FIELD_TOTAL_MS, 'Total MS', 'number');
            this.addFilterField(FIELD_THROUGHPUT, 'Throughput', 'number');
            this.addFilterField(FIELD_FILTER, 'Filter', 'string');
            this.addFilterField(FIELD_LIMIT, 'Limit', 'number');
            this.addFilterField(FIELD_OFFSET, 'Offset', 'number');
            this.addFilterField(FIELD_ORDER_BY, 'Order By', 'string');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_ROWS, 'Rows', 'number');
            this.addFilterField(FIELD_ROWS_FETCHED, 'Rows Fetched', 'number');
            this.addFilterField(FIELD_STATUS, 'Status', 'boolean');
            this.addFilterField(FIELD_USING_MRU, 'Using MRU', 'boolean');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ExternalCrossOrgCalloutData data = new ExternalCrossOrgCalloutData(eventData);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.entity = getField(fields, headerMap, FIELD_ENTITY);
            data.executeMs = getIntegerField(fields, headerMap, FIELD_EXECUTE_MS);
            data.fetchMs = getIntegerField(fields, headerMap, FIELD_FETCH_MS);
            data.totalMs = getIntegerField(fields, headerMap, FIELD_TOTAL_MS);
            data.throughput = getDecimalField(fields, headerMap, FIELD_THROUGHPUT);
            data.filter = getField(fields, headerMap, FIELD_FILTER);
            data.limitValue = getIntegerField(fields, headerMap, FIELD_LIMIT);
            data.offset = getIntegerField(fields, headerMap, FIELD_OFFSET);
            data.orderBy = getField(fields, headerMap, FIELD_ORDER_BY);
            data.selectValue = getField(fields, headerMap, FIELD_SELECT);
            data.subqueries = getIntegerField(fields, headerMap, FIELD_SUBQUERIES);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.rows = getIntegerField(fields, headerMap, FIELD_ROWS);
            data.rowsFetched = getIntegerField(fields, headerMap, FIELD_ROWS_FETCHED);
            data.status = getBooleanField(fields, headerMap, FIELD_STATUS);
            data.usingMru = getBooleanField(fields, headerMap, FIELD_USING_MRU);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ExternalCustomApexCalloutProcessor extends EventLogProcessor {
        public ExternalCustomApexCalloutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_ENTITY, 'Entity', 'string');
            this.addFilterField(FIELD_EXECUTE_MS, 'Execute MS', 'number');
            this.addFilterField(FIELD_FETCH_MS, 'Fetch MS', 'number');
            this.addFilterField(FIELD_TOTAL_MS, 'Total MS', 'number');
            this.addFilterField(FIELD_THROUGHPUT, 'Throughput', 'number');
            this.addFilterField(FIELD_FILTER, 'Filter', 'string');
            this.addFilterField(FIELD_LIMIT, 'Limit', 'number');
            this.addFilterField(FIELD_OFFSET, 'Offset', 'number');
            this.addFilterField(FIELD_ORDER_BY, 'Order By', 'string');
            this.addFilterField(FIELD_SELECT, 'Select', 'string');
            this.addFilterField(FIELD_SUBQUERIES, 'Subqueries', 'number');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_ROWS, 'Rows', 'number');
            this.addFilterField(FIELD_ROWS_FETCHED, 'Rows Fetched', 'number');
            this.addFilterField(FIELD_STATUS, 'Status', 'boolean');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ExternalCustomApexCalloutData data = new ExternalCustomApexCalloutData(eventData);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.entity = getField(fields, headerMap, FIELD_ENTITY);
            data.executeMs = getIntegerField(fields, headerMap, FIELD_EXECUTE_MS);
            data.fetchMs = getIntegerField(fields, headerMap, FIELD_FETCH_MS);
            data.totalMs = getIntegerField(fields, headerMap, FIELD_TOTAL_MS);
            data.throughput = getDecimalField(fields, headerMap, FIELD_THROUGHPUT);
            data.filter = getField(fields, headerMap, FIELD_FILTER);
            data.limitValue = getIntegerField(fields, headerMap, FIELD_LIMIT);
            data.offset = getIntegerField(fields, headerMap, FIELD_OFFSET);
            data.orderBy = getField(fields, headerMap, FIELD_ORDER_BY);
            data.selectValue = getField(fields, headerMap, FIELD_SELECT);
            data.subqueries = getIntegerField(fields, headerMap, FIELD_SUBQUERIES);
            data.rows = getIntegerField(fields, headerMap, FIELD_ROWS);
            data.rowsFetched = getIntegerField(fields, headerMap, FIELD_ROWS_FETCHED);
            data.status = getBooleanField(fields, headerMap, FIELD_STATUS);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class DocumentAttachmentDownloadsProcessor extends EventLogProcessor {
        public DocumentAttachmentDownloadsProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ENTITY_ID, 'Entity ID', 'string');
            this.addFilterField(FIELD_FILE_TYPE, 'File Type', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            DocumentAttachmentDownloadsData data = new DocumentAttachmentDownloadsData(eventData);
            data.entityId = getField(fields, headerMap, FIELD_ENTITY_ID);
            data.fileType = getField(fields, headerMap, FIELD_FILE_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class DatabaseSaveEventProcessor extends EventLogProcessor {
        public DatabaseSaveEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_DML_TYPE, 'DML Type', 'string');
            this.addFilterField(FIELD_KEY_PREFIX, 'Key Prefix', 'string');
            this.addFilterField(FIELD_FIRST_ENTITY_ID, 'First Entity ID', 'string');
            this.addFilterField(FIELD_NUM_ROWS, 'Num Rows', 'number');
            this.addFilterField(FIELD_SAMPLE_FACTOR, 'Sample Factor', 'number');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            DatabaseSaveEventData data = new DatabaseSaveEventData(eventData);
            data.dmlType = getField(fields, headerMap, FIELD_DML_TYPE);
            data.keyPrefix = getField(fields, headerMap, FIELD_KEY_PREFIX);
            data.firstEntityId = getField(fields, headerMap, FIELD_FIRST_ENTITY_ID);
            data.numRows = getIntegerField(fields, headerMap, FIELD_NUM_ROWS);
            data.sampleFactor = getDecimalField(fields, headerMap, FIELD_SAMPLE_FACTOR);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }   

    public class DashboardEventProcessor extends EventLogProcessor {
        public DashboardEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_DASHBOARD_ID, 'Dashboard ID', 'string');
            this.addFilterField(FIELD_DASHBOARD_ID_DERIVED, 'Dashboard ID Derived', 'string');
            this.addFilterField(FIELD_DASHBOARD_COMPONENT_ID, 'Dashboard Component ID', 'string');
            this.addFilterField(FIELD_DASHBOARD_TYPE, 'Dashboard Type', 'string');
            this.addFilterField(FIELD_REPORT_ID, 'Report ID', 'string');
            this.addFilterField(FIELD_REPORT_ID_DERIVED, 'Report ID Derived', 'string');
            this.addFilterField(FIELD_IS_SCHEDULED, 'Is Scheduled', 'boolean');
            this.addFilterField(FIELD_IS_SUCCESS, 'Is Success', 'boolean');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_VIEWING_USER_ID, 'Viewing User ID', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            DashboardEventData data = new DashboardEventData(eventData);
            data.dashboardId = getField(fields, headerMap, FIELD_DASHBOARD_ID);
            data.dashboardIdDerived = getField(fields, headerMap, FIELD_DASHBOARD_ID_DERIVED);
            data.dashboardComponentId = getField(fields, headerMap, FIELD_DASHBOARD_COMPONENT_ID);
            data.dashboardType = getField(fields, headerMap, FIELD_DASHBOARD_TYPE);
            data.reportId = getField(fields, headerMap, FIELD_REPORT_ID);
            data.reportIdDerived = getField(fields, headerMap, FIELD_REPORT_ID_DERIVED);
            data.isScheduled = getBooleanField(fields, headerMap, FIELD_IS_SCHEDULED);
            data.isSuccess = getBooleanField(fields, headerMap, FIELD_IS_SUCCESS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.viewingUserId = getField(fields, headerMap, FIELD_VIEWING_USER_ID);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class CspViolationProcessor extends EventLogProcessor {
        public CspViolationProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_BLOCKED_URI, 'Blocked URI', 'string');
            this.addFilterField(FIELD_BLOCKED_URI_DOMAIN, 'Blocked URI Domain', 'string');
            this.addFilterField(FIELD_COLUMN_NUMBER, 'Column Number', 'number');
            this.addFilterField(FIELD_LINE_NUMBER, 'Line Number', 'number');
            this.addFilterField(FIELD_CONTEXT, 'Context', 'string');
            this.addFilterField(FIELD_DIRECTIVE, 'Directive', 'string');
            this.addFilterField(FIELD_DISPOSITION, 'Disposition', 'string');
            this.addFilterField(FIELD_SOURCE, 'Source', 'string');
            this.addFilterField(FIELD_SOURCE_FILE, 'Source File', 'string');
            this.addFilterField(FIELD_RESOURCE_SAMPLE, 'Resource Sample', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            CspViolationData data = new CspViolationData(eventData);
            data.blockedUri = getField(fields, headerMap, FIELD_BLOCKED_URI);
            data.blockedUriDomain = getField(fields, headerMap, FIELD_BLOCKED_URI_DOMAIN);
            data.columnNumber = getIntegerField(fields, headerMap, FIELD_COLUMN_NUMBER);
            data.lineNumber = getIntegerField(fields, headerMap, FIELD_LINE_NUMBER);
            data.context = getField(fields, headerMap, FIELD_CONTEXT);
            data.directive = getField(fields, headerMap, FIELD_DIRECTIVE);
            data.disposition = getField(fields, headerMap, FIELD_DISPOSITION);
            data.source = getField(fields, headerMap, FIELD_SOURCE);
            data.sourceFile = getField(fields, headerMap, FIELD_SOURCE_FILE);
            data.resourceSample = getField(fields, headerMap, FIELD_RESOURCE_SAMPLE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class CorsViolationProcessor extends EventLogProcessor {
        public CorsViolationProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_HOST, 'Host', 'string');
            this.addFilterField(FIELD_ORIGIN, 'Origin', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            CorsViolationData data = new CorsViolationData(eventData);
            data.host = getField(fields, headerMap, FIELD_HOST);
            data.origin = getField(fields, headerMap, FIELD_ORIGIN);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ContinuationCalloutSummaryProcessor extends EventLogProcessor {
        public ContinuationCalloutSummaryProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_CONTINUATION_ID, 'Continuation ID', 'string');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_SUCCESS, 'Success', 'boolean');
            this.addFilterField(FIELD_ORIGIN_REQUEST_ID, 'Origin Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_FORM_SIZE, 'Request Form Size', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_VF_CONTROLLER_SIZE, 'VF Controller Size', 'number');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_URL, 'URL', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ContinuationCalloutSummaryData data = new ContinuationCalloutSummaryData(eventData);
            data.continuationId = getField(fields, headerMap, FIELD_CONTINUATION_ID);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.success = getBooleanField(fields, headerMap, FIELD_SUCCESS);
            data.originRequestId = getField(fields, headerMap, FIELD_ORIGIN_REQUEST_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestFormSize = getField(fields, headerMap, FIELD_REQUEST_FORM_SIZE);
            data.responseSize = getField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.vfControllerSize = getField(fields, headerMap, FIELD_VF_CONTROLLER_SIZE);
            data.statusCode = getField(fields, headerMap, FIELD_STATUS_CODE);
            data.url = getField(fields, headerMap, FIELD_URL);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ContentTransferProcessor extends EventLogProcessor {
        public ContentTransferProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_DOCUMENT_ID, 'Document ID', 'string');
            this.addFilterField(FIELD_DOCUMENT_ID_DERIVED, 'Document ID Derived', 'string');
            this.addFilterField(FIELD_VERSION_ID, 'Version ID', 'string');
            this.addFilterField(FIELD_VERSION_ID_DERIVED, 'Version ID Derived', 'string');
            this.addFilterField(FIELD_FILE_TYPE, 'File Type', 'string');
            this.addFilterField(FIELD_FILE_PREVIEW_TYPE, 'File Preview Type', 'string');
            this.addFilterField(FIELD_SIZE_BYTES, 'Size Bytes', 'number');
            this.addFilterField(FIELD_TRANSACTION_TYPE, 'Transaction Type', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ContentTransferData data = new ContentTransferData(eventData);
            data.documentId = getField(fields, headerMap, FIELD_DOCUMENT_ID);
            data.documentIdDerived = getField(fields, headerMap, FIELD_DOCUMENT_ID_DERIVED);
            data.versionId = getField(fields, headerMap, FIELD_VERSION_ID);
            data.versionIdDerived = getField(fields, headerMap, FIELD_VERSION_ID_DERIVED);
            data.fileType = getField(fields, headerMap, FIELD_FILE_TYPE);
            data.filePreviewType = getField(fields, headerMap, FIELD_FILE_PREVIEW_TYPE);
            data.sizeBytes = getIntegerField(fields, headerMap, FIELD_SIZE_BYTES);
            data.transactionType = getField(fields, headerMap, FIELD_TRANSACTION_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LoginAsProcessor extends EventLogProcessor {
        public LoginAsProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_DELEGATED_USER_ID, 'Delegated User ID', 'string');
            this.addFilterField(FIELD_DELEGATED_USER_ID_DERIVED, 'Delegated User ID Derived', 'string');
            this.addFilterField(FIELD_DELEGATED_USER_NAME, 'Delegated User Name', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LoginAsData data = new LoginAsData(eventData);
            data.delegatedUserId = getField(fields, headerMap, FIELD_DELEGATED_USER_ID);
            data.delegatedUserIdDerived = getField(fields, headerMap, FIELD_DELEGATED_USER_ID_DERIVED);
            data.delegatedUserName = getField(fields, headerMap, FIELD_DELEGATED_USER_NAME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LoginEventProcessor extends EventLogProcessor {
        public LoginEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_API_TYPE, 'API Type', 'string');
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'string');
            this.addFilterField(FIELD_AUTHENTICATION_METHOD_REFERENCE, 'Authentication Method Reference', 'string');
            this.addFilterField(FIELD_AUTHENTICATION_SERVICE_ID, 'Authentication Service ID', 'string');
            this.addFilterField(FIELD_LOGIN_STATUS, 'Login Status', 'string');
            this.addFilterField(FIELD_LOGIN_SUB_TYPE, 'Login Sub Type', 'string');
            this.addFilterField(FIELD_LOGIN_TYPE, 'Login Type', 'string');
            this.addFilterField(FIELD_LOGIN_URL, 'Login URL', 'string');
            this.addFilterField(FIELD_BROWSER_TYPE, 'Browser Type', 'string');
            this.addFilterField(FIELD_CIPHER_SUITE, 'Cipher Suite', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_SOURCE_IP, 'Source IP', 'string');
            this.addFilterField(FIELD_FORWARDED_FOR_IP, 'Forwarded For IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_NAME, 'User Name', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        public override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LoginEventData data = new LoginEventData(eventData);
            data.apiType = getField(fields, headerMap, FIELD_API_TYPE);
            data.apiVersion = getField(fields, headerMap, FIELD_API_VERSION);
            data.authMethodRef = getField(fields, headerMap, FIELD_AUTHENTICATION_METHOD_REFERENCE);
            data.authServiceId = getField(fields, headerMap, FIELD_AUTHENTICATION_SERVICE_ID);
            data.loginStatus = getField(fields, headerMap, FIELD_LOGIN_STATUS);
            data.loginSubType = getField(fields, headerMap, FIELD_LOGIN_SUB_TYPE);
            data.loginType = getField(fields, headerMap, FIELD_LOGIN_TYPE);
            data.loginUrl = getField(fields, headerMap, FIELD_LOGIN_URL);
            data.browserType = getField(fields, headerMap, FIELD_BROWSER_TYPE);
            data.cipherSuite = getField(fields, headerMap, FIELD_CIPHER_SUITE);
            data.tlsProtocol = getField(fields, headerMap, FIELD_TLS_PROTOCOL);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.sourceIp = getField(fields, headerMap, FIELD_SOURCE_IP);
            data.forwardedForIp = getField(fields, headerMap, FIELD_FORWARDED_FOR_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.userName = getField(fields, headerMap, FIELD_USER_NAME);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ReportEventProcessor extends EventLogProcessor {
        public ReportEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REPORT_ID, 'Report ID', 'string');
            this.addFilterField(FIELD_REPORT_ID_DERIVED, 'Report ID Derived', 'string');
            this.addFilterField(FIELD_DISPLAY_TYPE, 'Display Type', 'string');
            this.addFilterField(FIELD_RENDERING_TYPE, 'Rendering Type', 'string');
            this.addFilterField(FIELD_ORIGIN, 'Origin', 'string');
            this.addFilterField(FIELD_SORT, 'Sort', 'string');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_AVERAGE_ROW_SIZE, 'Average Row Size', 'number');
            this.addFilterField(FIELD_ROW_COUNT, 'Row Count', 'number');
            this.addFilterField(FIELD_NUMBER_BUCKETS, 'Number Buckets', 'number');
            this.addFilterField(FIELD_NUMBER_COLUMNS, 'Number Columns', 'number');
            this.addFilterField(FIELD_UI_NUMBER_COLUMNS, 'UI Number Columns', 'number');
            this.addFilterField(FIELD_NUMBER_EXCEPTION_FILTERS, 'Number Exception Filters', 'number');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'DB Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'DB CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }
        public override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ReportEventData data = new ReportEventData(eventData);
            data.reportId = getField(fields, headerMap, FIELD_REPORT_ID);
            data.reportIdDerived = getField(fields, headerMap, FIELD_REPORT_ID_DERIVED);
            data.displayType = getField(fields, headerMap, FIELD_DISPLAY_TYPE);
            data.renderingType = getField(fields, headerMap, FIELD_RENDERING_TYPE);
            data.origin = getField(fields, headerMap, FIELD_ORIGIN);
            data.sortValue = getField(fields, headerMap, FIELD_SORT);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.averageRowSize = getIntegerField(fields, headerMap, FIELD_AVERAGE_ROW_SIZE);
            data.rowCount = getIntegerField(fields, headerMap, FIELD_ROW_COUNT);
            data.numberBuckets = getIntegerField(fields, headerMap, FIELD_NUMBER_BUCKETS);
            data.numberColumns = getIntegerField(fields, headerMap, FIELD_NUMBER_COLUMNS);
            data.uiNumberColumns = getIntegerField(fields, headerMap, FIELD_UI_NUMBER_COLUMNS);
            data.numberExceptionFilters = getIntegerField(fields, headerMap, FIELD_NUMBER_EXCEPTION_FILTERS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class OneCommerceUsageProcessor extends EventLogProcessor {
        public OneCommerceUsageProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_B2B_EDITION, 'B2B Edition', 'string');
            this.addFilterField(FIELD_B2B_VERSION, 'B2B Version', 'string');
            this.addFilterField(FIELD_WEB_STORE_ID, 'Web Store ID', 'string');
            this.addFilterField(FIELD_WEB_STORE_TYPE, 'Web Store Type', 'string');
            this.addFilterField(FIELD_BROWSER_DEVICE_TYPE, 'Browser Device Type', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_OPERATION, 'Operation', 'string');
            this.addFilterField(FIELD_OPERATION_STAGE, 'Operation Stage', 'string');
            this.addFilterField(FIELD_OPERATION_STATE, 'Operation State', 'string');
            this.addFilterField(FIELD_OPERATION_STATUS, 'Operation Status', 'string');
            this.addFilterField(FIELD_OPERATION_TIME, 'Operation Time', 'number');
            this.addFilterField(FIELD_IS_RETRY, 'Is Retry', 'boolean');
            this.addFilterField(FIELD_COUNT, 'Count', 'number');
            this.addFilterField(FIELD_CONTEXT_ID, 'Context ID', 'string');
            this.addFilterField(FIELD_CONTEXT_MAP, 'Context Map', 'string');
            this.addFilterField(FIELD_CORRELATION_ID, 'Correlation ID', 'string');
            this.addFilterField(FIELD_EFFECTIVE_ACCOUNT_ID, 'Effective Account ID', 'string');
            this.addFilterField(FIELD_ERROR_CODE, 'Error Code', 'string');
            this.addFilterField(FIELD_ERROR_MESSAGE, 'Error Message', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            OneCommerceUsageData data = new OneCommerceUsageData(eventData);
            data.b2bEdition = getField(fields, headerMap, FIELD_B2B_EDITION);
            data.b2bVersion = getField(fields, headerMap, FIELD_B2B_VERSION);
            data.webStoreId = getField(fields, headerMap, FIELD_WEB_STORE_ID);
            data.webStoreType = getField(fields, headerMap, FIELD_WEB_STORE_TYPE);
            data.browserDeviceType = getField(fields, headerMap, FIELD_BROWSER_DEVICE_TYPE);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.operation = getField(fields, headerMap, FIELD_OPERATION);
            data.operationStage = getField(fields, headerMap, FIELD_OPERATION_STAGE);
            data.operationState = getField(fields, headerMap, FIELD_OPERATION_STATE);
            data.operationStatus = getField(fields, headerMap, FIELD_OPERATION_STATUS);
            data.operationTime = getIntegerField(fields, headerMap, FIELD_OPERATION_TIME);
            data.isRetry = getBooleanField(fields, headerMap, FIELD_IS_RETRY);
            data.count = getIntegerField(fields, headerMap, FIELD_COUNT);
            data.contextId = getField(fields, headerMap, FIELD_CONTEXT_ID);
            data.contextMap = getField(fields, headerMap, FIELD_CONTEXT_MAP);
            data.correlationId = getField(fields, headerMap, FIELD_CORRELATION_ID);
            data.effectiveAccountId = getField(fields, headerMap, FIELD_EFFECTIVE_ACCOUNT_ID);
            data.errorCode = getField(fields, headerMap, FIELD_ERROR_CODE);
            data.errorMessage = getField(fields, headerMap, FIELD_ERROR_MESSAGE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID); 
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.serviceName = getField(fields, headerMap, FIELD_SERVICE_NAME);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class NamedCredentialProcessor extends EventLogProcessor {
        public NamedCredentialProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_NAMED_CREDENTIAL_NAME, 'Named Credential Name', 'string');
            this.addFilterField(FIELD_CALLER_PACKAGE_NAMESPACE, 'Caller Package Namespace', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            NamedCredentialData data = new NamedCredentialData(eventData);
            data.namedCredentialName = getField(fields, headerMap, FIELD_NAMED_CREDENTIAL_NAME);
            data.callerPackageNamespace = getField(fields, headerMap, FIELD_CALLER_PACKAGE_NAMESPACE);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class MultiblockReportProcessor extends EventLogProcessor {
        public MultiblockReportProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_MASTER_REPORT_ID, 'Master Report ID', 'string');
            this.addFilterField(FIELD_HAS_CHART, 'Has Chart', 'boolean');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            MultiblockReportData data = new MultiblockReportData(eventData);
            data.masterReportId = getField(fields, headerMap, FIELD_MASTER_REPORT_ID);
            data.hasChart = getBooleanField(fields, headerMap, FIELD_HAS_CHART);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            return data;
        }
    }

    public class MetadataApiOperationProcessor extends EventLogProcessor {
        public MetadataApiOperationProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_OPERATION, 'Operation', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            MetadataApiOperationData data = new MetadataApiOperationData(eventData);
            data.apiVersion = getField(fields, headerMap, FIELD_API_VERSION);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.operation = getField(fields, headerMap, FIELD_OPERATION);
            data.operationEnum = convertMetadataApiOperationType(data.operation);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class RestApiProcessor extends EventLogProcessor {
        public RestApiProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_METHOD, 'Method', 'string');
            this.addFilterField(FIELD_MEDIA_TYPE, 'Media Type', 'string');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_NUMBER_FIELDS, 'Number Fields', 'number');
            this.addFilterField(FIELD_ROWS_PROCESSED, 'Rows Processed', 'number');
            this.addFilterField(FIELD_CONNECTED_APP_ID, 'Connected App ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_REQUEST_SIZE, 'Request Size', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_EXCEPTION_MESSAGE, 'Exception Message', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'DB Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'DB CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            RestApiData data = new RestApiData(eventData);
            data.method = getField(fields, headerMap, FIELD_METHOD);
            data.query = getField(fields, headerMap, FIELD_QUERY);
            data.mediaType = getField(fields, headerMap, FIELD_MEDIA_TYPE);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.numberFields = getIntegerField(fields, headerMap, FIELD_NUMBER_FIELDS);
            data.rowsProcessed = getIntegerField(fields, headerMap, FIELD_ROWS_PROCESSED);
            data.connectedAppId = getField(fields, headerMap, FIELD_CONNECTED_APP_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.userAgent = getIntegerField(fields, headerMap, FIELD_USER_AGENT);
            data.requestSize = getIntegerField(fields, headerMap, FIELD_REQUEST_SIZE);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.exceptionMessage = getField(fields, headerMap, FIELD_EXCEPTION_MESSAGE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            return data;
        }
    }

    public class TimeBasedWorkflowProcessor extends EventLogProcessor {
        public TimeBasedWorkflowProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_DATA, 'Data', 'string');
            this.addFilterField(FIELD_LOG_GROUP_ID, 'Log Group ID', 'string');
            this.addFilterField(FIELD_NUMBER_OF_RECORDS, 'Number of Records', 'number');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            TimeBasedWorkflowData data = new TimeBasedWorkflowData(eventData);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.data = getField(fields, headerMap, FIELD_DATA);
            data.logGroupId = getField(fields, headerMap, FIELD_LOG_GROUP_ID);
            data.numberOfRecords = getIntegerField(fields, headerMap, FIELD_NUMBER_OF_RECORDS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            return data;
        }
    }

    public class UITelemetryResourceTimingProcessor extends EventLogProcessor {
        public UITelemetryResourceTimingProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_URL, 'URL', 'string');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_INITIATOR_TYPE, 'Initiator Type', 'string');
            this.addFilterField(FIELD_RENDER_BLOCKING_STATUS, 'Render Blocking Status', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_NEXT_HOP_PROTOCOL, 'Next Hop Protocol', 'string');
            this.addFilterField(FIELD_DECODED_BODY_SIZE, 'Decoded Body Size', 'number');
            this.addFilterField(FIELD_ENCODED_BODY_SIZE, 'Encoded Body Size', 'number');
            this.addFilterField(FIELD_RESPONSE_STATUS, 'Response Status', 'number');
            this.addFilterField(FIELD_TRANSFER_SIZE, 'Transfer Size', 'number');
            this.addFilterField(FIELD_CONNECT_END, 'Connect End', 'number');
            this.addFilterField(FIELD_CONNECT_START, 'Connect Start', 'number');
            this.addFilterField(FIELD_DOMAIN_LOOKUP_END, 'Domain Lookup End', 'number');
            this.addFilterField(FIELD_DOMAIN_LOOKUP_START, 'Domain Lookup Start', 'number');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_FETCH_START, 'Fetch Start', 'number');
            this.addFilterField(FIELD_FIRST_INTERIM_RESPONSE_START, 'First Interim Response Start', 'number');
            this.addFilterField(FIELD_REDIRECT_END, 'Redirect End', 'number');
            this.addFilterField(FIELD_REDIRECT_START, 'Redirect Start', 'number');
            this.addFilterField(FIELD_REQUEST_START, 'Request Start', 'number');
            this.addFilterField(FIELD_RESPONSE_END, 'Response End', 'number');
            this.addFilterField(FIELD_RESPONSE_START, 'Response Start', 'number');
            this.addFilterField(FIELD_SECURE_CONNECT_START, 'Secure Connect Start', 'number');
            this.addFilterField(FIELD_START_TIME, 'Start Time', 'number');
            this.addFilterField(FIELD_WORKER_START, 'Worker Start', 'number');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_UI_EVENT_RELATIVE_TIMESTAMP, 'UI Event Relative Timestamp', 'number');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_UI_ROOT_ACTIVITY_ID, 'UI Root Activity ID', 'string');
            this.addFilterField(FIELD_UI_THREAD_RESPONSE_DELAY, 'UI Thread Response Delay', 'number');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            UITelemetryResourceTimingData data = new UITelemetryResourceTimingData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.url = getField(fields, headerMap, FIELD_URL);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.initiatorType = getField(fields, headerMap, FIELD_INITIATOR_TYPE);
            data.renderBlockingStatus = getField(fields, headerMap, FIELD_RENDER_BLOCKING_STATUS);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.nextHopProtocol = getField(fields, headerMap, FIELD_NEXT_HOP_PROTOCOL);
            data.decodedBodySize = getIntegerField(fields, headerMap, FIELD_DECODED_BODY_SIZE);
            data.encodedBodySize = getIntegerField(fields, headerMap, FIELD_ENCODED_BODY_SIZE);
            data.responseStatus = getIntegerField(fields, headerMap, FIELD_RESPONSE_STATUS);
            data.transferSize = getIntegerField(fields, headerMap, FIELD_TRANSFER_SIZE);
            data.connectEnd = getIntegerField(fields, headerMap, FIELD_CONNECT_END);
            data.connectStart = getIntegerField(fields, headerMap, FIELD_CONNECT_START);
            data.domainLookupEnd = getIntegerField(fields, headerMap, FIELD_DOMAIN_LOOKUP_END);
            data.domainLookupStart = getIntegerField(fields, headerMap, FIELD_DOMAIN_LOOKUP_START);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.fetchStart = getIntegerField(fields, headerMap, FIELD_FETCH_START);
            data.firstInterimResponseStart = getIntegerField(fields, headerMap, FIELD_FIRST_INTERIM_RESPONSE_START);
            data.redirectEnd = getIntegerField(fields, headerMap, FIELD_REDIRECT_END);
            data.redirectStart = getIntegerField(fields, headerMap, FIELD_REDIRECT_START);
            data.requestStart = getIntegerField(fields, headerMap, FIELD_REQUEST_START);
            data.responseEnd = getIntegerField(fields, headerMap, FIELD_RESPONSE_END);
            data.responseStart = getIntegerField(fields, headerMap, FIELD_RESPONSE_START);
            data.secureConnectStart = getIntegerField(fields, headerMap, FIELD_SECURE_CONNECT_START);
            data.startTime = getIntegerField(fields, headerMap, FIELD_START_TIME);
            data.workerStart = getIntegerField(fields, headerMap, FIELD_WORKER_START);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.uiEventRelativeTimestamp = getIntegerField(fields, headerMap, FIELD_UI_EVENT_RELATIVE_TIMESTAMP);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiRootActivityId = getField(fields, headerMap, FIELD_UI_ROOT_ACTIVITY_ID);
            data.uiThreadResponseDelay = getIntegerField(fields, headerMap, FIELD_UI_THREAD_RESPONSE_DELAY);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.serverRequestId = getField(fields, headerMap, FIELD_SERVER_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class UITelemetryNavigationTimingProcessor extends EventLogProcessor {
        public UITelemetryNavigationTimingProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_URL, 'URL', 'string');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_INITIATOR_TYPE, 'Initiator Type', 'string');
            this.addFilterField(FIELD_NAVIGATION_TYPE, 'Navigation Type', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_NEXT_HOP_PROTOCOL, 'Next Hop Protocol', 'string');
            this.addFilterField(FIELD_DECODED_BODY_SIZE, 'Decoded Body Size', 'number');
            this.addFilterField(FIELD_ENCODED_BODY_SIZE, 'Encoded Body Size', 'number');
            this.addFilterField(FIELD_RESPONSE_STATUS, 'Response Status', 'number');
            this.addFilterField(FIELD_TRANSFER_SIZE, 'Transfer Size', 'number');
            this.addFilterField(FIELD_CONNECT_END, 'Connect End', 'number');
            this.addFilterField(FIELD_CONNECT_START, 'Connect Start', 'number');
            this.addFilterField(FIELD_DOM_COMPLETE, 'DOM Complete', 'number');
            this.addFilterField(FIELD_DOM_CONTENT_LOADED_EVENT_END, 'DOM Content Loaded Event End', 'number');
            this.addFilterField(FIELD_DOM_CONTENT_LOADED_EVENT_START, 'DOM Content Loaded Event Start', 'number');
            this.addFilterField(FIELD_DOM_INTERACTIVE, 'DOM Interactive', 'number');
            this.addFilterField(FIELD_DOMAIN_LOOKUP_END, 'Domain Lookup End', 'number');
            this.addFilterField(FIELD_DOMAIN_LOOKUP_START, 'Domain Lookup Start', 'number');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_FETCH_START, 'Fetch Start', 'number');
            this.addFilterField(FIELD_FIRST_INTERIM_RESPONSE_START, 'First Interim Response Start', 'number');
            this.addFilterField(FIELD_LOAD_EVENT_END, 'Load Event End', 'number');
            this.addFilterField(FIELD_LOAD_EVENT_START, 'Load Event Start', 'number');
            this.addFilterField(FIELD_REDIRECT_END, 'Redirect End', 'number');
            this.addFilterField(FIELD_REDIRECT_START, 'Redirect Start', 'number');
            this.addFilterField(FIELD_REQUEST_START, 'Request Start', 'number');
            this.addFilterField(FIELD_RESPONSE_END, 'Response End', 'number');
            this.addFilterField(FIELD_RESPONSE_START, 'Response Start', 'number');
            this.addFilterField(FIELD_SECURE_CONNECT_START, 'Secure Connect Start', 'number');
            this.addFilterField(FIELD_START_TIME, 'Start Time', 'number');
            this.addFilterField(FIELD_UNLOAD_EVENT_END, 'Unload Event End', 'number');
            this.addFilterField(FIELD_UNLOAD_EVENT_START, 'Unload Event Start', 'number');
            this.addFilterField(FIELD_WORKER_START, 'Worker Start', 'number');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_UI_EVENT_RELATIVE_TIMESTAMP, 'UI Event Relative Timestamp', 'number');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_UI_ROOT_ACTIVITY_ID, 'UI Root Activity ID', 'string');
            this.addFilterField(FIELD_UI_THREAD_RESPONSE_DELAY, 'UI Thread Response Delay', 'number');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            UITelemetryNavigationTimingData data = new UITelemetryNavigationTimingData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.url = getField(fields, headerMap, FIELD_URL);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.initiatorType = getField(fields, headerMap, FIELD_INITIATOR_TYPE);
            data.navigationType = getField(fields, headerMap, FIELD_NAVIGATION_TYPE);
            data.redirectCount = getIntegerField(fields, headerMap, FIELD_REDIRECT_COUNT);
            data.renderBlockingStatus = getField(fields, headerMap, FIELD_RENDER_BLOCKING_STATUS);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.nextHopProtocol = getField(fields, headerMap, FIELD_NEXT_HOP_PROTOCOL);
            data.decodedBodySize = getIntegerField(fields, headerMap, FIELD_DECODED_BODY_SIZE);
            data.encodedBodySize = getIntegerField(fields, headerMap, FIELD_ENCODED_BODY_SIZE);
            data.responseStatus = getIntegerField(fields, headerMap, FIELD_RESPONSE_STATUS);
            data.transferSize = getIntegerField(fields, headerMap, FIELD_TRANSFER_SIZE);
            data.connectEnd = getIntegerField(fields, headerMap, FIELD_CONNECT_END);
            data.connectStart = getIntegerField(fields, headerMap, FIELD_CONNECT_START);
            data.domComplete = getIntegerField(fields, headerMap, FIELD_DOM_COMPLETE);
            data.domContentLoadedEventEnd = getIntegerField(fields, headerMap, FIELD_DOM_CONTENT_LOADED_EVENT_END);
            data.domContentLoadedEventStart = getIntegerField(fields, headerMap, FIELD_DOM_CONTENT_LOADED_EVENT_START);
            data.domInteractive = getIntegerField(fields, headerMap, FIELD_DOM_INTERACTIVE);
            data.domainLookupEnd = getIntegerField(fields, headerMap, FIELD_DOMAIN_LOOKUP_END);
            data.domainLookupStart = getIntegerField(fields, headerMap, FIELD_DOMAIN_LOOKUP_START);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.fetchStart = getIntegerField(fields, headerMap, FIELD_FETCH_START);
            data.firstInterimResponseStart = getIntegerField(fields, headerMap, FIELD_FIRST_INTERIM_RESPONSE_START);
            data.loadEventEnd = getIntegerField(fields, headerMap, FIELD_LOAD_EVENT_END);
            data.loadEventStart = getIntegerField(fields, headerMap, FIELD_LOAD_EVENT_START);
            data.redirectEnd = getIntegerField(fields, headerMap, FIELD_REDIRECT_END);
            data.redirectStart = getIntegerField(fields, headerMap, FIELD_REDIRECT_START);
            data.requestStart = getIntegerField(fields, headerMap, FIELD_REQUEST_START);
            data.responseEnd = getIntegerField(fields, headerMap, FIELD_RESPONSE_END);
            data.responseStart = getIntegerField(fields, headerMap, FIELD_RESPONSE_START);
            data.secureConnectStart = getIntegerField(fields, headerMap, FIELD_SECURE_CONNECT_START);
            data.startTime = getIntegerField(fields, headerMap, FIELD_START_TIME);
            data.unloadEventEnd = getIntegerField(fields, headerMap, FIELD_UNLOAD_EVENT_END);
            data.unloadEventStart = getIntegerField(fields, headerMap, FIELD_UNLOAD_EVENT_START);
            data.workerStart = getIntegerField(fields, headerMap, FIELD_WORKER_START);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.uiEventRelativeTimestamp = getIntegerField(fields, headerMap, FIELD_UI_EVENT_RELATIVE_TIMESTAMP);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiRootActivityId = getField(fields, headerMap, FIELD_UI_ROOT_ACTIVITY_ID);
            data.uiThreadResponseDelay = getIntegerField(fields, headerMap, FIELD_UI_THREAD_RESPONSE_DELAY);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.serverRequestId = getField(fields, headerMap, FIELD_SERVER_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class TransactionSecurityProcessor extends EventLogProcessor {
        public TransactionSecurityProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_POLICY_ID, 'Policy ID', 'string');
            this.addFilterField(FIELD_POLICY_ID_DERIVED, 'Policy ID Derived', 'string');
            this.addFilterField(FIELD_RESULT, 'Result', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_EVENT_TIMESTAMP, 'Event Timestamp', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            TransactionSecurityData data = new TransactionSecurityData(eventData);
            data.policyId = getField(fields, headerMap, FIELD_POLICY_ID);
            data.policyIdDerived = getField(fields, headerMap, FIELD_POLICY_ID_DERIVED);
            data.result = getField(fields, headerMap, FIELD_RESULT);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.eventTimestamp = getDateTimeField(fields, headerMap, FIELD_EVENT_TIMESTAMP);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ContentDistributionProcessor extends EventLogProcessor {
        public ContentDistributionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_DELIVERY_ID, 'Delivery ID', 'string');
            this.addFilterField(FIELD_DELIVERY_LOCATION, 'Delivery Location', 'string');
            this.addFilterField(FIELD_VERSION_ID, 'Version ID', 'string');
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_RELATED_ENTITY_ID, 'Related Entity ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ContentDistributionData data = new ContentDistributionData(eventData);
            data.deliveryId = getField(fields, headerMap, FIELD_DELIVERY_ID);
            data.deliveryLocation = getField(fields, headerMap, FIELD_DELIVERY_LOCATION);
            data.versionId = getField(fields, headerMap, FIELD_VERSION_ID);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.relatedEntityId = getField(fields, headerMap, FIELD_RELATED_ENTITY_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ConsoleEventProcessor extends EventLogProcessor {
        public ConsoleEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CONSOLE_ID, 'Console ID', 'string');
            this.addFilterField(FIELD_CONSOLE_ID_DERIVED, 'Console ID Derived', 'string');
            this.addFilterField(FIELD_LICENSE_CONTEXT, 'License Context', 'string');
            this.addFilterField(FIELD_COMPONENT_ID, 'Component ID', 'string');
            this.addFilterField(FIELD_COMPONENT_ID_DERIVED, 'Component ID Derived', 'string');
            this.addFilterField(FIELD_RECORD_ID, 'Record ID', 'string');
            this.addFilterField(FIELD_RECORD_ID_DERIVED, 'Record ID Derived', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ConsoleEventData data = new ConsoleEventData(eventData);
            data.consoleId = getField(fields, headerMap, FIELD_CONSOLE_ID);
            data.consoleIdDerived = getField(fields, headerMap, FIELD_CONSOLE_ID_DERIVED);
            data.licenseContext = getField(fields, headerMap, FIELD_LICENSE_CONTEXT);
            data.componentId = getField(fields, headerMap, FIELD_COMPONENT_ID);
            data.componentIdDerived = getField(fields, headerMap, FIELD_COMPONENT_ID_DERIVED);
            data.recordId = getField(fields, headerMap, FIELD_RECORD_ID);
            data.recordIdDerived = getField(fields, headerMap, FIELD_RECORD_ID_DERIVED);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ConcurrentLongRunningApexLimitProcessor extends EventLogProcessor {
        public ConcurrentLongRunningApexLimitProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_NUMBER_REQUESTS, 'Number Requests', 'number');
            this.addFilterField(FIELD_REQUESTS_LIMIT, 'Requests Limit', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_URI, 'Request URI', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ConcurrentLongRunningApexLimitData data = new ConcurrentLongRunningApexLimitData(eventData);
            data.numberRequests = getIntegerField(fields, headerMap, FIELD_NUMBER_REQUESTS);
            data.requestsLimit = getIntegerField(fields, headerMap, FIELD_REQUESTS_LIMIT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestUri = getField(fields, headerMap, FIELD_REQUEST_URI);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class KnowledgeArticleViewProcessor extends EventLogProcessor {
        public KnowledgeArticleViewProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ARTICLE_ID, 'Article ID', 'string');
            this.addFilterField(FIELD_ARTICLE_STATUS, 'Article Status', 'string');
            this.addFilterField(FIELD_ARTICLE_VERSION, 'Article Version', 'number');
            this.addFilterField(FIELD_ARTICLE_VERSION_ID, 'Article Version ID', 'string');
            this.addFilterField(FIELD_LAST_VERSION, 'Last Version', 'boolean');
            this.addFilterField(FIELD_CONTEXT, 'Context', 'string');
            this.addFilterField(FIELD_ENTITY, 'Entity', 'string');
            this.addFilterField(FIELD_LANGUAGE, 'Language', 'string');
            this.addFilterField(FIELD_LARGE_LANGUAGE_MODEL, 'Large Language Model', 'string');
            this.addFilterField(FIELD_SESSION_ID, 'Session ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            KnowledgeArticleViewData data = new KnowledgeArticleViewData(eventData);
            data.articleId = getField(fields, headerMap, FIELD_ARTICLE_ID);
            data.articleStatus = getField(fields, headerMap, FIELD_ARTICLE_STATUS);
            data.articleVersion = getIntegerField(fields, headerMap, FIELD_ARTICLE_VERSION);
            data.articleVersionId = getField(fields, headerMap, FIELD_ARTICLE_VERSION_ID);
            data.lastVersion = getBooleanField(fields, headerMap, FIELD_LAST_VERSION);
            data.context = getField(fields, headerMap, FIELD_CONTEXT);
            data.entity = getField(fields, headerMap, FIELD_ENTITY);
            data.language = getField(fields, headerMap, FIELD_LANGUAGE);
            data.largeLanguageModel = getField(fields, headerMap, FIELD_LARGE_LANGUAGE_MODEL);
            data.sessionId = getField(fields, headerMap, FIELD_SESSION_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LogoutProcessor extends EventLogProcessor {
        public LogoutProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_API_TYPE, 'API Type', 'string');
            this.addFilterField(FIELD_API_VERSION, 'API Version', 'string');
            this.addFilterField(FIELD_APP_TYPE, 'App Type', 'number');
            this.addFilterField(FIELD_CLIENT_VERSION, 'Client Version', 'number');
            this.addFilterField(FIELD_PLATFORM_TYPE, 'Platform Type', 'number');
            this.addFilterField(FIELD_RESOLUTION_TYPE, 'Resolution Type', 'number');
            this.addFilterField(FIELD_SESSION_LEVEL, 'Session Level', 'string');
            this.addFilterField(FIELD_SESSION_TYPE, 'Session Type', 'string');
            this.addFilterField(FIELD_USER_INITIATED_LOGOUT, 'User Initiated Logout', 'boolean');
            this.addFilterField(FIELD_BROWSER_TYPE, 'Browser Type', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_EVENT_TYPE, 'Event Type', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LogoutEventData data = new LogoutEventData(eventData);
            data.apiType = getField(fields, headerMap, FIELD_API_TYPE);
            data.apiVersion = getField(fields, headerMap, FIELD_API_VERSION);
            data.appType = getIntegerField(fields, headerMap, FIELD_APP_TYPE);
            data.clientVersion = getIntegerField(fields, headerMap, FIELD_CLIENT_VERSION);
            data.platformType = getIntegerField(fields, headerMap, FIELD_PLATFORM_TYPE);
            data.resolutionType = getIntegerField(fields, headerMap, FIELD_RESOLUTION_TYPE);
            data.sessionLevel = getField(fields, headerMap, FIELD_SESSION_LEVEL);
            data.sessionType = getField(fields, headerMap, FIELD_SESSION_TYPE);
            data.userInitiatedLogout = getBooleanField(fields, headerMap, FIELD_USER_INITIATED_LOGOUT);
            data.browserType = getField(fields, headerMap, FIELD_BROWSER_TYPE);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class PricingEventProcessor extends EventLogProcessor {
        public PricingEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_PRICING_API_ENDPOINT, 'Pricing API Endpoint', 'string');
            this.addFilterField(FIELD_PRICING_DETAILS, 'Pricing Details', 'string');
            this.addFilterField(FIELD_PRICING_ERROR_CODE, 'Pricing Error Code', 'string');
            this.addFilterField(FIELD_PRICING_LOG_NAME, 'Pricing Log Name', 'string');
            this.addFilterField(FIELD_PRICING_PROCEDURE, 'Pricing Procedure', 'string');
            this.addFilterField(FIELD_PRICING_STATUS, 'Pricing Status', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            PricingEventData data = new PricingEventData(eventData);
            data.pricingApiEndpoint = getField(fields, headerMap, FIELD_PRICING_API_ENDPOINT);
            data.pricingDetails = getField(fields, headerMap, FIELD_PRICING_DETAILS);
            data.pricingErrorCode = getField(fields, headerMap, FIELD_PRICING_ERROR_CODE);
            data.pricingLogName = getField(fields, headerMap, FIELD_PRICING_LOG_NAME);
            data.pricingProcedure = getField(fields, headerMap, FIELD_PRICING_PROCEDURE);
            data.pricingStatus = getField(fields, headerMap, FIELD_PRICING_STATUS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            return data;
        }
    }

    public class PlatformEncryptionProcessor extends EventLogProcessor {
        public PlatformEncryptionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ACTION, 'Action', 'string');
            this.addFilterField(FIELD_KEY_TYPE, 'Key Type', 'string');
            this.addFilterField(FIELD_KEY_ID, 'Key ID', 'string');
            this.addFilterField(FIELD_KEY_ID_DERIVED, 'Key ID Derived', 'string');
            this.addFilterField(FIELD_METHOD, 'Method', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            PlatformEncryptionData data = new PlatformEncryptionData(eventData);
            data.action = getField(fields, headerMap, FIELD_ACTION);
            data.keyType = getField(fields, headerMap, FIELD_KEY_TYPE);
            data.keyId = getField(fields, headerMap, FIELD_KEY_ID);
            data.keyIdDerived = getField(fields, headerMap, FIELD_KEY_ID_DERIVED);
            data.method = getField(fields, headerMap, FIELD_METHOD);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            return data;
        }
    }

    public class PermissionUpdateProcessor extends EventLogProcessor {
        public PermissionUpdateProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_PERMISSION_TYPE, 'Permission Type', 'string');
            this.addFilterField(FIELD_UPDATE_TYPE, 'Update Type', 'string');
            this.addFilterField(FIELD_DESCRIPTION, 'Description', 'string');
            this.addFilterField(FIELD_CONTEXT, 'Context', 'string');
            this.addFilterField(FIELD_FEATURE_ID, 'Feature ID', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            PermissionUpdateData data = new PermissionUpdateData(eventData);
            data.permissionType = getField(fields, headerMap, FIELD_PERMISSION_TYPE);
            data.updateType = getField(fields, headerMap, FIELD_UPDATE_TYPE);
            data.description = getField(fields, headerMap, FIELD_DESCRIPTION);
            data.context = getField(fields, headerMap, FIELD_CONTEXT);
            data.featureId = getField(fields, headerMap, FIELD_FEATURE_ID);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class PackageInstallProcessor extends EventLogProcessor {
        public PackageInstallProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_EVENT_TYPE, 'Event Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_FAILURE_TYPE, 'Failure Type', 'string');
            this.addFilterField(FIELD_IS_MANAGED, 'Is Managed', 'boolean');
            this.addFilterField(FIELD_IS_PUSH, 'Is Push', 'boolean');
            this.addFilterField(FIELD_IS_RELEASED, 'Is Released', 'boolean');
            this.addFilterField(FIELD_IS_SUCCESSFUL, 'Is Successful', 'boolean');
            this.addFilterField(FIELD_PACKAGE_NAME, 'Package Name', 'string');
            this.addFilterField(FIELD_OPERATION_TYPE, 'Operation Type', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            PackageInstallData data = new PackageInstallData(eventData);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.eventType = getField(fields, headerMap, FIELD_EVENT_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.failureType = getField(fields, headerMap, FIELD_FAILURE_TYPE);
            data.isManaged = getBooleanField(fields, headerMap, FIELD_IS_MANAGED);
            data.isPush = getBooleanField(fields, headerMap, FIELD_IS_PUSH);
            data.isReleased = getBooleanField(fields, headerMap, FIELD_IS_RELEASED);
            data.isSuccessful = getBooleanField(fields, headerMap, FIELD_IS_SUCCESSFUL);
            data.packageName = getField(fields, headerMap, FIELD_PACKAGE_NAME);
            data.operationType = getField(fields, headerMap, FIELD_OPERATION_TYPE);
            data.operationTypeEnum = convertPackageOperationType(data.operationType);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class UriEventProcessor extends EventLogProcessor {
        public UriEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'DB Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'DB CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_REFERRER_URI, 'Referrer URI', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            UriEventData data = new UriEventData(eventData);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.referrerUri = getField(fields, headerMap, FIELD_REFERRER_URI);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class WavePerformanceEventProcessor extends EventLogProcessor {
        public WavePerformanceEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_EPT, 'EPT', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_NAME, 'Name', 'string');
            this.addFilterField(FIELD_RECORD_ID, 'Record ID', 'string');
            this.addFilterField(FIELD_TAB_ID, 'Tab ID', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_VIEW_MODE, 'View Mode', 'string');
            this.addFilterField(FIELD_IS_INITIAL, 'Is Initial', 'boolean');
            this.addFilterField(FIELD_WAVE_SESSION_ID, 'Wave Session ID', 'string');
            this.addFilterField(FIELD_WAVE_TIMESTAMP, 'Wave Timestamp', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_QUERY_ID, 'Query ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID, 'User ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            WavePerformanceEventData data = new WavePerformanceEventData(eventData);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.ept = getIntegerField(fields, headerMap, FIELD_EPT);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.name = getField(fields, headerMap, FIELD_NAME);
            data.recordId = getField(fields, headerMap, FIELD_RECORD_ID);
            data.tabId = getField(fields, headerMap, FIELD_TAB_ID);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.viewMode = getField(fields, headerMap, FIELD_VIEW_MODE);
            data.isInitial = getBooleanField(fields, headerMap, FIELD_IS_INITIAL);
            data.waveSessionId = getField(fields, headerMap, FIELD_WAVE_SESSION_ID);
            data.waveTimestamp = getIntegerField(fields, headerMap, FIELD_WAVE_TIMESTAMP);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.queryId = getField(fields, headerMap, FIELD_QUERY_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.userId = getField(fields, headerMap, FIELD_USER_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class WaveInteractionEventProcessor extends EventLogProcessor {
        public WaveInteractionEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_NUM_CLICKS, 'Num Clicks', 'number');
            this.addFilterField(FIELD_NUM_SESSIONS, 'Num Sessions', 'number');
            this.addFilterField(FIELD_READ_TIME, 'Read Time', 'number');
            this.addFilterField(FIELD_TOTAL_TIME, 'Total Time', 'number');
            this.addFilterField(FIELD_RECORD_ID, 'Record ID', 'string');
            this.addFilterField(FIELD_TAB_ID, 'Tab ID', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_VIEW_MODE, 'View Mode', 'string');
            this.addFilterField(FIELD_WAVE_SESSION_ID, 'Wave Session ID', 'string');
            this.addFilterField(FIELD_WAVE_TIMESTAMP, 'Wave Timestamp', 'number');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            WaveInteractionEventData data = new WaveInteractionEventData(eventData);
            data.numClicks = getIntegerField(fields, headerMap, FIELD_NUM_CLICKS);
            data.numSessions = getIntegerField(fields, headerMap, FIELD_NUM_SESSIONS);
            data.readTime = getIntegerField(fields, headerMap, FIELD_READ_TIME);
            data.totalTime = getIntegerField(fields, headerMap, FIELD_TOTAL_TIME);
            data.recordId = getField(fields, headerMap, FIELD_RECORD_ID);
            data.tabId = getField(fields, headerMap, FIELD_TAB_ID);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.viewMode = getField(fields, headerMap, FIELD_VIEW_MODE);
            data.waveSessionId = getField(fields, headerMap, FIELD_WAVE_SESSION_ID);
            data.waveTimestamp = getIntegerField(fields, headerMap, FIELD_WAVE_TIMESTAMP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            return data;
        }
    }

    public class WaveDownloadEventProcessor extends EventLogProcessor {
        public WaveDownloadEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ASSET_ID, 'Asset ID', 'string');
            this.addFilterField(FIELD_ASSET_TYPE, 'Asset Type', 'string');
            this.addFilterField(FIELD_DATASET_IDS, 'Dataset IDs', 'string');
            this.addFilterField(FIELD_DOWNLOAD_ERROR, 'Download Error', 'string');
            this.addFilterField(FIELD_DOWNLOAD_FORMAT, 'Download Format', 'string');
            this.addFilterField(FIELD_NUMBER_OF_RECORDS, 'Number of Records', 'number');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            WaveDownloadEventData data = new WaveDownloadEventData(eventData);
            data.assetId = getField(fields, headerMap, FIELD_ASSET_ID);
            data.assetType = getField(fields, headerMap, FIELD_ASSET_TYPE);
            data.datasetIds = getField(fields, headerMap, FIELD_DATASET_IDS);
            data.downloadError = getField(fields, headerMap, FIELD_DOWNLOAD_ERROR);
            data.downloadFormat = getField(fields, headerMap, FIELD_DOWNLOAD_FORMAT);
            data.numberOfRecords = getIntegerField(fields, headerMap, FIELD_NUMBER_OF_RECORDS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.waveSessionId = getField(fields, headerMap, FIELD_WAVE_SESSION_ID);
            data.waveTimestamp = getIntegerField(fields, headerMap, FIELD_WAVE_TIMESTAMP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            return data;
        }
    }

    public class WaveChangeEventProcessor extends EventLogProcessor {
        public WaveChangeEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ANALYTICS_MODE, 'Analytics Mode', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ID, 'Page ID', 'string');
            this.addFilterField(FIELD_RECORDING_ID, 'Recording ID', 'string');
            this.addFilterField(FIELD_SAVED_VIEW_ID, 'Saved View ID', 'string');
            this.addFilterField(FIELD_TAB_ID, 'Tab ID', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_VIEW_MODE, 'View Mode', 'string');
            this.addFilterField(FIELD_WAVE_SESSION_ID, 'Wave Session ID', 'string');
            this.addFilterField(FIELD_WAVE_TIMESTAMP, 'Wave Timestamp', 'number');
            this.addFilterField(FIELD_IS_NEW, 'Is New', 'boolean');
            this.addFilterField(FIELD_REOPEN_COUNT, 'Reopen Count', 'number');
            this.addFilterField(FIELD_IS_MOBILE, 'Is Mobile', 'boolean');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            WaveChangeEventData data = new WaveChangeEventData(eventData);
            data.analyticsMode = getField(fields, headerMap, FIELD_ANALYTICS_MODE);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageId = getField(fields, headerMap, FIELD_PAGE_ID);
            data.recordId = getField(fields, headerMap, FIELD_RECORDING_ID);
            data.savedViewId = getField(fields, headerMap, FIELD_SAVED_VIEW_ID);
            data.tabId = getField(fields, headerMap, FIELD_TAB_ID);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.viewMode = getField(fields, headerMap, FIELD_VIEW_MODE);
            data.waveSessionId = getField(fields, headerMap, FIELD_WAVE_SESSION_ID);
            data.waveTimestamp = getIntegerField(fields, headerMap, FIELD_WAVE_TIMESTAMP);
            data.isNew = getBooleanField(fields, headerMap, FIELD_IS_NEW);
            data.reopencount = getIntegerField(fields, headerMap, FIELD_REOPEN_COUNT);
            data.isMobile = getBooleanField(fields, headerMap, FIELD_IS_MOBILE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            return data;
        }
    }

    public class LightningErrorProcessor extends EventLogProcessor {
        public LightningErrorProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_APP_NAME, 'Page App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_START_TIME, 'Page Start Time', 'number');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_DEVICE_ID, 'Device ID', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_COMPONENT_NAME, 'Component Name', 'string');
            this.addFilterField(FIELD_MESSAGE, 'Message', 'string');
            this.addFilterField(FIELD_STACK_TRACE, 'Stack Trace', 'string');
            this.addFilterField(FIELD_UI_EVENT_ID, 'UI Event ID', 'string');
            this.addFilterField(FIELD_UI_EVENT_SEQUENCE_NUM, 'UI Event Sequence Num', 'number');
            this.addFilterField(FIELD_UI_EVENT_SOURCE, 'UI Event Source', 'string');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_UI_EVENT_TYPE, 'UI Event Type', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LightningErrorData data = new LightningErrorData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageAppName = getField(fields, headerMap, FIELD_PAGE_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageStartTime = getLongField(fields, headerMap, FIELD_PAGE_START_TIME);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.deviceId = getField(fields, headerMap, FIELD_DEVICE_ID);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.componentName = getField(fields, headerMap, FIELD_COMPONENT_NAME);
            data.message = getField(fields, headerMap, FIELD_MESSAGE);
            data.stackTrace = getField(fields, headerMap, FIELD_STACK_TRACE);
            data.uiEventId = getField(fields, headerMap, FIELD_UI_EVENT_ID);
            data.uiEventSequenceNum = getIntegerField(fields, headerMap, FIELD_UI_EVENT_SEQUENCE_NUM);
            data.uiEventSource = getField(fields, headerMap, FIELD_UI_EVENT_SOURCE);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiEventType = getField(fields, headerMap, FIELD_UI_EVENT_TYPE);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userAgent = getField(fields, headerMap, FIELD_USER_AGENT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LightningPerformanceProcessor extends EventLogProcessor {
        public LightningPerformanceProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_START_TIME, 'Page Start Time', 'number');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_UI_EVENT_ID, 'UI Event ID', 'string');
            this.addFilterField(FIELD_UI_EVENT_SOURCE, 'UI Event Source', 'string');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_UI_EVENT_TYPE, 'UI Event Type', 'string');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_DEVICE_ID, 'Device ID', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LightningPerformanceData data = new LightningPerformanceData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageStartTime = getLongField(fields, headerMap, FIELD_PAGE_START_TIME);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.uiEventId = getField(fields, headerMap, FIELD_UI_EVENT_ID);
            data.uiEventSource = getField(fields, headerMap, FIELD_UI_EVENT_SOURCE);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.uiEventType = getField(fields, headerMap, FIELD_UI_EVENT_TYPE);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.deviceId = getField(fields, headerMap, FIELD_DEVICE_ID);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userAgent = getField(fields, headerMap, FIELD_USER_AGENT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class LightningPageViewProcessor extends EventLogProcessor {
        public LightningPageViewProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_APP_NAME, 'App Name', 'string');
            this.addFilterField(FIELD_PAGE_APP_NAME, 'Page App Name', 'string');
            this.addFilterField(FIELD_PAGE_CONTEXT, 'Page Context', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_ID, 'Page Entity ID', 'string');
            this.addFilterField(FIELD_PAGE_ENTITY_TYPE, 'Page Entity Type', 'string');
            this.addFilterField(FIELD_PAGE_START_TIME, 'Page Start Time', 'number');
            this.addFilterField(FIELD_PAGE_URL, 'Page URL', 'string');
            this.addFilterField(FIELD_PREVPAGE_APP_NAME, 'PrevPage App Name', 'string');
            this.addFilterField(FIELD_PREVPAGE_CONTEXT, 'PrevPage Context', 'string');
            this.addFilterField(FIELD_PREVPAGE_ENTITY_ID, 'PrevPage Entity ID', 'string');
            this.addFilterField(FIELD_PREVPAGE_ENTITY_TYPE, 'PrevPage Entity Type', 'string');
            this.addFilterField(FIELD_PREVPAGE_URL, 'PrevPage URL', 'string');
            this.addFilterField(FIELD_DURATION, 'Duration', 'number');
            this.addFilterField(FIELD_EFFECTIVE_PAGE_TIME, 'Effective Page Time', 'number');
            this.addFilterField(FIELD_EFFECTIVE_PAGE_TIME_DEVIATION, 'Effective Page Time Deviation', 'boolean');
            this.addFilterField(FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE, 'Effective Page Time Deviation Error Type', 'string');
            this.addFilterField(FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_REASON, 'Effective Page Time Deviation Reason', 'string');
            this.addFilterField(FIELD_TARGET_UI_ELEMENT, 'Target UI Element', 'string');
            this.addFilterField(FIELD_PARENT_UI_ELEMENT, 'Parent UI Element', 'string');
            this.addFilterField(FIELD_GRANDPARENT_UI_ELEMENT, 'Grandparent UI Element', 'string');
            this.addFilterField(FIELD_UI_EVENT_ID, 'UI Event ID', 'string');
            this.addFilterField(FIELD_UI_EVENT_SEQUENCE_NUM, 'UI Event Sequence Num', 'number');
            this.addFilterField(FIELD_UI_EVENT_SOURCE, 'UI Event Source', 'string');
            this.addFilterField(FIELD_UI_EVENT_TIMESTAMP, 'UI Event Timestamp', 'number');
            this.addFilterField(FIELD_BROWSER_NAME, 'Browser Name', 'string');
            this.addFilterField(FIELD_BROWSER_VERSION, 'Browser Version', 'string');
            this.addFilterField(FIELD_CLIENT_GEO, 'Client Geo', 'string');
            this.addFilterField(FIELD_CLIENT_ID, 'Client ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_DEVICE_ID, 'Device ID', 'string');
            this.addFilterField(FIELD_DEVICE_MODEL, 'Device Model', 'string');
            this.addFilterField(FIELD_DEVICE_PLATFORM, 'Device Platform', 'string');
            this.addFilterField(FIELD_DEVICE_SESSION_ID, 'Device Session ID', 'string');
            this.addFilterField(FIELD_CONNECTION_TYPE, 'Connection Type', 'string');
            this.addFilterField(FIELD_OS_NAME, 'OS Name', 'string');
            this.addFilterField(FIELD_OS_VERSION, 'OS Version', 'string');
            this.addFilterField(FIELD_SDK_APP_TYPE, 'SDK App Type', 'string');
            this.addFilterField(FIELD_SDK_APP_VERSION, 'SDK App Version', 'string');
            this.addFilterField(FIELD_SDK_VERSION, 'SDK Version', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            LightningPageViewData data = new LightningPageViewData(eventData);
            data.appName = getField(fields, headerMap, FIELD_APP_NAME);
            data.pageAppName = getField(fields, headerMap, FIELD_PAGE_APP_NAME);
            data.pageContext = getField(fields, headerMap, FIELD_PAGE_CONTEXT);
            data.pageEntityId = getField(fields, headerMap, FIELD_PAGE_ENTITY_ID);
            data.pageEntityType = getField(fields, headerMap, FIELD_PAGE_ENTITY_TYPE);
            data.pageStartTime = getLongField(fields, headerMap, FIELD_PAGE_START_TIME);
            data.pageUrl = getField(fields, headerMap, FIELD_PAGE_URL);
            data.prevPageAppName = getField(fields, headerMap, FIELD_PREVPAGE_APP_NAME);
            data.prevPageContext = getField(fields, headerMap, FIELD_PREVPAGE_CONTEXT);
            data.prevPageEntityId = getField(fields, headerMap, FIELD_PREVPAGE_ENTITY_ID);
            data.prevPageEntityType = getField(fields, headerMap, FIELD_PREVPAGE_ENTITY_TYPE);
            data.prevPageUrl = getField(fields, headerMap, FIELD_PREVPAGE_URL);
            data.duration = getIntegerField(fields, headerMap, FIELD_DURATION);
            data.effectivePageTime = getDecimalField(fields, headerMap, FIELD_EFFECTIVE_PAGE_TIME);
            data.effectivePageTimeDeviation = getBooleanField(fields, headerMap, FIELD_EFFECTIVE_PAGE_TIME_DEVIATION);
            data.effectivePageTimeDeviationErrorType = getField(fields, headerMap, FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_ERROR_TYPE);
            data.effectivePageTimeDeviationReason = getField(fields, headerMap, FIELD_EFFECTIVE_PAGE_TIME_DEVIATION_REASON);
            data.targetUiElement = getField(fields, headerMap, FIELD_TARGET_UI_ELEMENT);
            data.parentUiElement = getField(fields, headerMap, FIELD_PARENT_UI_ELEMENT);
            data.grandparentUiElement = getField(fields, headerMap, FIELD_GRANDPARENT_UI_ELEMENT);
            data.uiEventId = getField(fields, headerMap, FIELD_UI_EVENT_ID);
            data.uiEventSequenceNum = getIntegerField(fields, headerMap, FIELD_UI_EVENT_SEQUENCE_NUM);
            data.uiEventSource = getField(fields, headerMap, FIELD_UI_EVENT_SOURCE);
            data.uiEventTimestamp = getLongField(fields, headerMap, FIELD_UI_EVENT_TIMESTAMP);
            data.browserName = getField(fields, headerMap, FIELD_BROWSER_NAME);
            data.browserVersion = getField(fields, headerMap, FIELD_BROWSER_VERSION);
            data.clientGeo = getField(fields, headerMap, FIELD_CLIENT_GEO);
            data.clientId = getField(fields, headerMap, FIELD_CLIENT_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.deviceId = getField(fields, headerMap, FIELD_DEVICE_ID);
            data.deviceModel = getField(fields, headerMap, FIELD_DEVICE_MODEL);
            data.devicePlatform = getField(fields, headerMap, FIELD_DEVICE_PLATFORM);
            data.deviceSessionId = getField(fields, headerMap, FIELD_DEVICE_SESSION_ID);
            data.connectionType = getField(fields, headerMap, FIELD_CONNECTION_TYPE);
            data.osName = getField(fields, headerMap, FIELD_OS_NAME);
            data.osVersion = getField(fields, headerMap, FIELD_OS_VERSION);
            data.sdkAppType = getField(fields, headerMap, FIELD_SDK_APP_TYPE);
            data.sdkAppVersion = getField(fields, headerMap, FIELD_SDK_APP_VERSION);
            data.sdkVersion = getField(fields, headerMap, FIELD_SDK_VERSION);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.userAgent = getField(fields, headerMap, FIELD_USER_AGENT);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class ContentDocumentLinkProcessor extends EventLogProcessor {
        public ContentDocumentLinkProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_DOCUMENT_ID, 'Document ID', 'string');
            this.addFilterField(FIELD_SHARED_WITH_ENTITY_ID, 'Shared With Entity ID', 'string');
            this.addFilterField(FIELD_SHARING_OPERATION, 'Sharing Operation', 'string');
            this.addFilterField(FIELD_SHARING_PERMISSION, 'Sharing Permission', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ContentDocumentLinkData data = new ContentDocumentLinkData(eventData);
            data.documentId = getField(fields, headerMap, FIELD_DOCUMENT_ID);
            data.sharedWithEntityId = getField(fields, headerMap, FIELD_SHARED_WITH_ENTITY_ID);
            data.sharingOperation = getField(fields, headerMap, FIELD_SHARING_OPERATION);
            data.sharingPermission = getField(fields, headerMap, FIELD_SHARING_PERMISSION);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class QueuedExecutionProcessor extends EventLogProcessor {
        public QueuedExecutionProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ENTRY_POINT, 'Entry Point', 'string');
            this.addFilterField(FIELD_JOB_ID, 'Job ID', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            QueuedExecutionData data = new QueuedExecutionData(eventData);
            data.entryPoint = getField(fields, headerMap, FIELD_ENTRY_POINT);
            data.jobId = getField(fields, headerMap, FIELD_JOB_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            return data;
        }
    }

    public class ApexRestApiEventProcessor extends EventLogProcessor {
        public ApexRestApiEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_METHOD, 'Method', 'string');
            this.addFilterField(FIELD_MEDIA_TYPE, 'Media Type', 'string');
            this.addFilterField(FIELD_CONNECTED_APP_ID, 'Connected App ID', 'string');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_EXCEPTION_MESSAGE, 'Exception Message', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'DB Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'DB CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_REQUEST_SIZE, 'Request Size', 'number');
            this.addFilterField(FIELD_RESPONSE_SIZE, 'Response Size', 'number');
            this.addFilterField(FIELD_ROWS_PROCESSED, 'Rows Processed', 'number');
            this.addFilterField(FIELD_NUMBER_FIELDS, 'Number Fields', 'number');
            this.addFilterField(FIELD_STATUS_CODE, 'Status Code', 'number');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'number');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CLIENT_NAME, 'Client Name', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            ApexRestApiEventData data = new ApexRestApiEventData(eventData);
            data.query = getField(fields, headerMap, FIELD_QUERY);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.method = getField(fields, headerMap, FIELD_METHOD);
            data.mediaType = getField(fields, headerMap, FIELD_MEDIA_TYPE);
            data.connectedAppId = getField(fields, headerMap, FIELD_CONNECTED_APP_ID);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.exceptionMessage = getField(fields, headerMap, FIELD_EXCEPTION_MESSAGE);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.requestSize = getIntegerField(fields, headerMap, FIELD_REQUEST_SIZE);
            data.responseSize = getIntegerField(fields, headerMap, FIELD_RESPONSE_SIZE);
            data.rowsProcessed = getIntegerField(fields, headerMap, FIELD_ROWS_PROCESSED);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.numberFields = getIntegerField(fields, headerMap, FIELD_NUMBER_FIELDS);
            data.statusCode = getIntegerField(fields, headerMap, FIELD_STATUS_CODE);
            data.userAgent = getIntegerField(fields, headerMap, FIELD_USER_AGENT);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.clientName = getField(fields, headerMap, FIELD_CLIENT_NAME);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    /**
     * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_asyncreportrun.htm
     */
    public class AsyncReportRunEventProcessor extends EventLogProcessor {
        public AsyncReportRunEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REPORT_ID, 'Report ID', 'string');
            this.addFilterField(FIELD_REPORT_ID_DERIVED, 'Report ID Derived', 'string');
            this.addFilterField(FIELD_DASHBOARD_ID, 'Dashboard ID', 'string');
            this.addFilterField(FIELD_AVERAGE_ROW_SIZE, 'Average Row Size', 'number');
            this.addFilterField(FIELD_ROW_COUNT, 'Row Count', 'number');
            this.addFilterField(FIELD_NUMBER_BUCKETS, 'Number Buckets', 'number');
            this.addFilterField(FIELD_NUMBER_COLUMNS, 'Number Columns', 'number');
            this.addFilterField(FIELD_NUMBER_EXCEPTION_FILTERS, 'Number Exception Filters', 'number');
            this.addFilterField(FIELD_DISPLAY_TYPE, 'Display Type', 'string');
            this.addFilterField(FIELD_RENDERING_TYPE, 'Rendering Type', 'string');
            this.addFilterField(FIELD_ORIGIN, 'Origin', 'string');
            this.addFilterField(FIELD_SORT, 'Sort', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_DB_BLOCKS, 'DB Blocks', 'number');
            this.addFilterField(FIELD_DB_CPU_TIME, 'DB CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_ENTITY_NAME, 'Entity Name', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            AsyncReportRunEventData data = new AsyncReportRunEventData(eventData);
            data.reportId = getField(fields, headerMap, FIELD_REPORT_ID);
            data.reportIdDerived = getField(fields, headerMap, FIELD_REPORT_ID_DERIVED);
            data.dashboardId = getField(fields, headerMap, FIELD_DASHBOARD_ID);
            data.averageRowSize = getIntegerField(fields, headerMap, FIELD_AVERAGE_ROW_SIZE);
            data.rowCount = getIntegerField(fields, headerMap, FIELD_ROW_COUNT);
            data.numberBuckets = getIntegerField(fields, headerMap, FIELD_NUMBER_BUCKETS);
            data.numberColumns = getIntegerField(fields, headerMap, FIELD_NUMBER_COLUMNS);
            data.numberExceptionFilters = getIntegerField(fields, headerMap, FIELD_NUMBER_EXCEPTION_FILTERS);
            data.displayType = getField(fields, headerMap, FIELD_DISPLAY_TYPE);
            data.renderingType = getField(fields, headerMap, FIELD_RENDERING_TYPE);
            data.origin = getField(fields, headerMap, FIELD_ORIGIN);
            data.sortValue = getField(fields, headerMap, FIELD_SORT);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.dbBlocks = getIntegerField(fields, headerMap, FIELD_DB_BLOCKS);
            data.dbCpuTime = getIntegerField(fields, headerMap, FIELD_DB_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.entityName = getField(fields, headerMap, FIELD_ENTITY_NAME);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class BlockedRedirectProcessor extends EventLogProcessor {
        public BlockedRedirectProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_BLOCKED_URI, 'Blocked URI', 'string');
            this.addFilterField(FIELD_BLOCKED_URI_DOMAIN, 'Blocked URI Domain', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORIGIN, 'Origin', 'string');
            this.addFilterField(FIELD_REFERRER, 'Referrer', 'string');
            this.addFilterField(FIELD_MALFORMED_URL, 'Malformed URL', 'boolean');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            BlockedRedirectData data = new BlockedRedirectData(eventData);
            data.blockedUri = getField(fields, headerMap, FIELD_BLOCKED_URI);
            data.blockedUriDomain = getField(fields, headerMap, FIELD_BLOCKED_URI_DOMAIN);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.origin = getField(fields, headerMap, FIELD_ORIGIN);
            data.referrer = getField(fields, headerMap, FIELD_REFERRER);
            data.malformedUrl = getBooleanField(fields, headerMap, FIELD_MALFORMED_URL);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class AuraRequestProcessor extends EventLogProcessor {
        public AuraRequestProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ACTION_MESSAGE, 'Action Message', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_REQUEST_METHOD, 'Request Method', 'string');
            this.addFilterField(FIELD_REQUEST_STATUS, 'Request Status', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_DB_TOTAL_TIME, 'DB Total Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_USER_AGENT, 'User Agent', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            AuraRequestData data = new AuraRequestData(eventData);
            data.actionMessage = getField(fields, headerMap, FIELD_ACTION_MESSAGE);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.requestMethod = getField(fields, headerMap, FIELD_REQUEST_METHOD);
            data.requestStatus = getField(fields, headerMap, FIELD_REQUEST_STATUS);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.dbTotalTime = getIntegerField(fields, headerMap, FIELD_DB_TOTAL_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.userAgent = getIntegerField(fields, headerMap, FIELD_USER_AGENT);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.userType = getField(fields, headerMap, FIELD_USER_TYPE);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class InsufficientAccessProcessor extends EventLogProcessor {
        public InsufficientAccessProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ACCESS_ERROR, 'Access Error', 'string');
            this.addFilterField(FIELD_ERROR_DESCRIPTION, 'Error Description', 'string');
            this.addFilterField(FIELD_ERROR_TIMESTAMP, 'Error Timestamp', 'string');
            this.addFilterField(FIELD_REQUESTED_ACCESS_LEVEL, 'Requested Access Level', 'string');
            this.addFilterField(FIELD_ENTITY_TYPE, 'Entity Type', 'string');
            this.addFilterField(FIELD_RECORD_ID, 'Record ID', 'string');
            this.addFilterField(FIELD_ACTUAL_LOGGED_IN_USER_ID, 'Actual Logged In User ID', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            InsufficientAccessData data = new InsufficientAccessData(eventData);
            data.accessError = getField(fields, headerMap, FIELD_ACCESS_ERROR);
            data.errorDescription = getField(fields, headerMap, FIELD_ERROR_DESCRIPTION);
            data.errorTimestamp = getField(fields, headerMap, FIELD_ERROR_TIMESTAMP);
            data.requestedAccessLevel = getField(fields, headerMap, FIELD_REQUESTED_ACCESS_LEVEL);
            data.entityType = getField(fields, headerMap, FIELD_ENTITY_TYPE);
            data.recordId = getField(fields, headerMap, FIELD_RECORD_ID);
            data.actualLoggedInUserId = getField(fields, headerMap, FIELD_ACTUAL_LOGGED_IN_USER_ID);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class InsecureExternalAssetsProcessor extends EventLogProcessor {
        public InsecureExternalAssetsProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_ASSET_TYPE, 'Asset Type', 'string');
            this.addFilterField(FIELD_INSECURE_URI, 'Insecure URI', 'string');
            this.addFilterField(FIELD_TYPE, 'Type', 'string');
            this.addFilterField(FIELD_DOCUMENT_URI, 'Document URI', 'string');
            this.addFilterField(FIELD_DISPOSITION, 'Disposition', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_NETWORK_ID, 'Network ID', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_UNIQUE_ID, 'Unique ID', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            InsecureExternalAssetsData data = new InsecureExternalAssetsData(eventData);
            data.assetType = getField(fields, headerMap, FIELD_ASSET_TYPE);
            data.insecureUri = getField(fields, headerMap, FIELD_INSECURE_URI);
            data.type = getField(fields, headerMap, FIELD_TYPE);
            data.documentUri = getField(fields, headerMap, FIELD_DOCUMENT_URI);
            data.disposition = getField(fields, headerMap, FIELD_DISPOSITION);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.networkId = getField(fields, headerMap, FIELD_NETWORK_ID);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.uniqueId = getField(fields, headerMap, FIELD_UNIQUE_ID);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class HostnameRedirectsProcessor extends EventLogProcessor {
        public HostnameRedirectsProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_SOURCE_HOSTNAME, 'Source Hostname', 'string');
            this.addFilterField(FIELD_TARGET_HOSTNAME, 'Target Hostname', 'string');
            this.addFilterField(FIELD_PATH, 'Path', 'string');
            this.addFilterField(FIELD_REDIRECT_REASON, 'Redirect Reason', 'string');
            this.addFilterField(FIELD_IS_BLOCKED_REDIRECTION, 'Is Blocked Redirection', 'boolean');
            this.addFilterField(FIELD_REFERRER, 'Referrer', 'string');
            this.addFilterField(FIELD_ORIGIN, 'Origin', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            HostnameRedirectsData data = new HostnameRedirectsData(eventData);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.sourceHostname = getField(fields, headerMap,  FIELD_SOURCE_HOSTNAME);
            data.targetHostname = getField(fields, headerMap, FIELD_TARGET_HOSTNAME);
            data.path = getField(fields, headerMap, FIELD_PATH);
            data.redirectReason = getField(fields, headerMap, FIELD_REDIRECT_REASON);
            data.isBlockedRedirection = getBooleanField(fields, headerMap, FIELD_IS_BLOCKED_REDIRECTION);
            data.referrer = getField(fields, headerMap, FIELD_REFERRER);
            data.origin = getField(fields, headerMap, FIELD_ORIGIN);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class GroupMembershipProcessor extends EventLogProcessor {
        public GroupMembershipProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_CLIENT_IP, 'Client IP', 'string');
            this.addFilterField(FIELD_CPU_TIME, 'CPU Time', 'number');
            this.addFilterField(FIELD_RUN_TIME, 'Run Time', 'number');
            this.addFilterField(FIELD_GROUP_ID, 'Group ID', 'string');
            this.addFilterField(FIELD_GROUP_TYPE, 'Group Type', 'string');
            this.addFilterField(FIELD_MEMBER_ID, 'Member ID', 'string');
            this.addFilterField(FIELD_OPERATION, 'Operation', 'string');
            this.addFilterField(FIELD_LOGIN_KEY, 'Login Key', 'string');
            this.addFilterField(FIELD_SESSION_KEY, 'Session Key', 'string');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_URI, 'URI', 'string');
            this.addFilterField(FIELD_URI_ID_DERIVED, 'URI ID Derived', 'string');
            this.addFilterField(FIELD_USER_ID_DERIVED, 'User ID Derived', 'string');
            this.addFilterField(FIELD_USER_TYPE, 'User Type', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            GroupMembershipData data = new GroupMembershipData(eventData);
            data.clientIp = getField(fields, headerMap, FIELD_CLIENT_IP);
            data.cpuTime = getIntegerField(fields, headerMap, FIELD_CPU_TIME);
            data.runTime = getIntegerField(fields, headerMap, FIELD_RUN_TIME);
            data.groupId = getField(fields, headerMap, FIELD_GROUP_ID);
            data.groupType = getField(fields, headerMap, FIELD_GROUP_TYPE);
            data.memberId = getField(fields, headerMap, FIELD_MEMBER_ID);
            data.operation = getField(fields, headerMap, FIELD_OPERATION);
            data.loginKey = getField(fields, headerMap, FIELD_LOGIN_KEY);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.uri = getField(fields, headerMap, FIELD_URI);
            data.uriIdDerived = getField(fields, headerMap, FIELD_URI_ID_DERIVED);
            data.userIdDerived = getField(fields, headerMap, FIELD_USER_ID_DERIVED);
            data.sessionKey = getField(fields, headerMap, FIELD_SESSION_KEY);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    public class FlowExecutionEventProcessor extends EventLogProcessor {
        public FlowExecutionEventProcessor() {
            super(new Set<String>{FIELD_REQUEST_ID});
            this.addFilterField(FIELD_PROCESS_TYPE, 'Process Type', 'string');
            this.addFilterField(FIELD_FLOW_VERSION_ID, 'Flow Version ID', 'string');
            this.addFilterField(FIELD_FLOW_LOAD_TIME, 'Flow Load Time', 'number');
            this.addFilterField(FIELD_TOTAL_EXECUTION_TIME, 'Total Execution Time', 'number');
            this.addFilterField(FIELD_NUMBER_OF_INTERVIEWS, 'Number of Interviews', 'number');
            this.addFilterField(FIELD_NUMBER_OF_ERRORS, 'Number of Errors', 'number');
            this.addFilterField(FIELD_REQUEST_ID, 'Request ID', 'string');
            this.addFilterField(FIELD_ORGANIZATION_ID, 'Organization ID', 'string');
            this.addFilterField(FIELD_TIMESTAMP_DERIVED, 'Timestamp Derived', 'string');
        }

        protected override IBaseEventData processCsvRow(Map<String, Object> eventData, List<String> fields, Map<String, Integer> headerMap) {
            FlowExecutionEventData data = new FlowExecutionEventData(eventData);
            data.processType = getField(fields, headerMap, FIELD_PROCESS_TYPE);
            data.flowVersionId = getField(fields, headerMap, FIELD_FLOW_VERSION_ID);
            data.flowLoadTime = getIntegerField(fields, headerMap, FIELD_FLOW_LOAD_TIME);
            data.totalExecutionTime = getIntegerField(fields, headerMap, FIELD_TOTAL_EXECUTION_TIME);
            data.numberOfInterviews = getIntegerField(fields, headerMap, FIELD_NUMBER_OF_INTERVIEWS);
            data.numberOfErrors = getIntegerField(fields, headerMap, FIELD_NUMBER_OF_ERRORS);
            data.requestId = getField(fields, headerMap, FIELD_REQUEST_ID);
            data.organizationId = getField(fields, headerMap, FIELD_ORGANIZATION_ID);
            data.timestampDerived = getDateTimeField(fields, headerMap, FIELD_TIMESTAMP_DERIVED);
            return data;
        }
    }

    // CSV Parser for handling log file content
    private final static String COMMA = ',';
    private final static String CR = '\r';
    private final static String LF = '\n';
    private final static String CRLF = '\r\n';
    private final static String QUOTE = '"';
    private final static String DOUBLE_QUOTE = '""';

    private static String convertLineEndings(String str) {
        return str.replace(CRLF, LF).replace(CR, LF);
    }
        
    public class CSVParser implements Iterable<List<String>>, Iterator<List<String>> {
        
        private String csvString;
        private Integer csvStringLength;
        private Integer position = 0;
        private Iterator<List<String>> it;
        private List<String> headers;
        
        public CSVParser() {
            this.headers = new List<String>();
        }
        
        public void parse(String content) {
            if (String.isBlank(content)) return;
            
            this.csvString = content.trim();
            this.csvStringLength = this.csvString.length();
            this.it = iterator();
            
            // Parse headers from first line
            if (this.hasNext()) {
                this.headers = this.next();
            }
        }
        
        public List<String> getHeaders() {
            return this.headers;
        }
        
        public Iterator<List<String>> iterator() {
            return this;
        }
        
        public Boolean hasNext() {
            return position < csvStringLength;
        }
        
        public List<String> next() {
            List<String> values = new List<String>();
            position = readLine(position, values);
            return values;
        }
        
        private Integer readLine(Integer position, List<String> values) {
            Integer startPos = position;
            
            String currentValue;
            Integer cAt, nlAt, foundAt;
            
            List<String> tmpValues = new List<String>();
            while (position < csvStringLength) {
                cAt = csvString.indexOf(COMMA, position);
                nlAt = csvString.indexOf(LF, position);
                foundAt = Math.min(cAt, nlAt);
                
                if (foundAt < 0) {
                    foundAt = Math.max(cAt, nlAt);
                }
                if (foundAt < 0) {
                    currentValue = csvString.substring(startPos);
                    position = csvStringLength;
                }
                else {
                    currentValue = csvString.substring(startPos, foundAt);
                    position = foundAt + 1;
                }
                
                if (!currentValue.startsWith(QUOTE)) {
                    tmpValues.add(currentValue);
                    
                    if (foundAt == nlAt) {
                        break;
                    }
                    startPos = position;
                }
                else if (currentValue == DOUBLE_QUOTE) {
                    tmpValues.add('');
                    if (foundAt == nlAt) {
                        break;
                    }
                    startPos = position;
                }
                else if (currentValue.endsWith(QUOTE)) {
                    Integer lastIndex = currentValue.length() - 1;
                    currentValue = currentValue.substring(1, lastIndex);
                    
                    // Handle escaped quotes
                    Integer doubleQuotedQuotesIndex = currentValue.indexOf(DOUBLE_QUOTE);
                    if (doubleQuotedQuotesIndex >= 0) {
                        currentValue = currentValue.replace(DOUBLE_QUOTE, QUOTE);
                    }
                    
                    tmpValues.add(currentValue);
                    if (foundAt == nlAt) {
                        break;
                    }
                    startPos = position;
                }
            }
            values.addAll(tmpValues);
            return position;
        }
    }

    // ==========================================
    // Enhanced Deduplication Methods
    // ==========================================

    /**
     * Process event logs with email awareness - Request_Id population and timing analysis
     * @param eventLogs List of event logs from CSV processing
     * @param dedupSettings Deduplication settings
     * @param logger Logger instance for logging
     * @return List of event logs that should be created
     */
    public static List<Log__c> processEventLogsWithEmailAwareness(List<Log__c> eventLogs, Map<String, Object> dedupSettings, Logger logger) {
        List<Log__c> logsToCreate = new List<Log__c>();
        Map<Id, Log__c> emailLogsToUpdateMap = new Map<Id, Log__c>(); // Use Map to prevent duplicates
        
        if (eventLogs.isEmpty()) {
            return logsToCreate;
        }
        
        // Build maps for bulk processing
        Map<String, DateTime> hashToTimestampMap = new Map<String, DateTime>();
        Map<String, String> hashToRequestIdMap = new Map<String, String>();
        Set<String> requestIdsToCheck = new Set<String>();
        
        for (Log__c log : eventLogs) {
            if (String.isNotBlank(log.Hash_1__c)) {
                DateTime logTimestamp = log.Created_At__c;
                String requestId = log.Request_Id_External__c;
                
                hashToTimestampMap.put(log.Hash_1__c, logTimestamp);
                if (String.isNotBlank(requestId)) {
                    hashToRequestIdMap.put(log.Hash_1__c, requestId);
                    requestIdsToCheck.add(requestId);
                }
            }
        }
        
        if (!hashToTimestampMap.isEmpty()) {
            // STAGE 1: Fast filter - Check for existing Request_Ids (prevents duplicate processing)
            Set<String> existingRequestIds = getExistingRequestIds(requestIdsToCheck);
            
            // STAGE 2: Bulkified - Get ALL existing logs for all hashes at once (NO SOQL IN LOOP)
            Map<String, List<EmailLogTimingInfo>> allExistingEmailLogTimings = getAllExistingEmailLogTimings(hashToTimestampMap);
            
            // Process each event log
            for (Log__c eventLog : eventLogs) {
                String hash = eventLog.Hash_1__c;
                String requestId = eventLog.Request_Id_External__c;
                
                // Skip if Request_Id already exists (fast filter)
                if (String.isNotBlank(requestId) && existingRequestIds.contains(requestId)) {
                    continue;
                }
                
                // Get existing email logs with timing info for this hash
                List<EmailLogTimingInfo> existingEmailLogTimings = allExistingEmailLogTimings.get(hash);
                
                if (existingEmailLogTimings != null && !existingEmailLogTimings.isEmpty()) {
                    // Analyze timing match
                    LogMatchingResult result = analyzeLogMatching(eventLog, existingEmailLogTimings, dedupSettings);
                    
                    if (result.hasTimingMatch && result.emailLogMatch != null) {
                        // Update email log with Request_Id_External__c (use Map to prevent duplicates)
                        result.emailLogMatch.emailLog.Request_Id_External__c = requestId;
                        emailLogsToUpdateMap.put(result.emailLogMatch.emailLog.Id, result.emailLogMatch.emailLog);
                    } else {
                        // No timing match, create event log
                        logsToCreate.add(eventLog);
                    }
                } else {
                    // No existing email logs, create event log
                    logsToCreate.add(eventLog);
                }
            }
            
            // Bulk update email logs with Request_Id_External__c
            if (!emailLogsToUpdateMap.isEmpty()) {
                List<Log__c> emailLogsToUpdate = emailLogsToUpdateMap.values();
                DatabaseUtils.getInstance().performUpdateDML(emailLogsToUpdate, Schema.SObjectType.Log__c)
                    .handleError(EventLogProcessors.class.getName(), '.processEventLogsWithEmailAwareness', logger);
            }
        } else {
            logsToCreate = eventLogs;
        }
        
        return logsToCreate;
    }

    /**
     * Get ALL existing logs for all hashes with timing information (NO SOQL IN LOOP)
     * @param hashToTimestampMap Map of hash1 values to their event log timestamps
     * @return Map of hash1 to list of existing log timing information
     */
    public static Map<String, List<EmailLogTimingInfo>> getAllExistingEmailLogTimings(Map<String, DateTime> hashToTimestampMap) {
        Map<String, List<EmailLogTimingInfo>> timingInfoMap = new Map<String, List<EmailLogTimingInfo>>();
        
        if (hashToTimestampMap.isEmpty()) {
            return timingInfoMap;
        }
        
        // Use hourly time window from custom settings with +/- 10 minute tolerance
        DateTime lastProcessedHourlyTime = ConfigUtil.EVENT_MONITORING_SETTINGS.Last_Processed_Hourly_Events__c;
        
        DateTime windowStart;
        DateTime windowEnd;
        
        if (lastProcessedHourlyTime != null) {
            // Use custom settings hourly time window with +/- 10 minute tolerance
            windowStart = lastProcessedHourlyTime.addMinutes(-10);
            windowEnd = lastProcessedHourlyTime.addHours(1).addMinutes(10);
        } else {
            // Fallback to original logic if custom setting is not available
            DateTime earliestTime = null;
            DateTime latestTime = null;
            
            for (DateTime timestamp : hashToTimestampMap.values()) {
                if (earliestTime == null || timestamp < earliestTime) {
                    earliestTime = timestamp;
                }
                if (latestTime == null || timestamp > latestTime) {
                    latestTime = timestamp;
                }
            }
            
            // Expand window by 1 hour on each side (Salesforce event log CSV window)
            windowStart = earliestTime.addHours(-1);
            windowEnd = latestTime.addHours(1);
        }
        
        // SINGLE QUERY to get ALL existing logs for ALL hashes within the hourly time window
        List<Log__c> existingLogs = [
            SELECT Id, Hash_1__c, CreatedDate, Organization_Id__c, Created_At__c,
                   (SELECT Id, CreatedDate FROM Inbound_Emails__r ORDER BY CreatedDate ASC)
            FROM Log__c 
            WHERE Hash_1__c IN :hashToTimestampMap.keySet()
            AND Created_At__c >= :windowStart
            AND Created_At__c <= :windowEnd
            AND Request_Id_External__c = null
            ORDER BY Hash_1__c, Created_At__c
        ];
        
        for (Log__c existingLog : existingLogs) {
            EmailLogTimingInfo timingInfo = new EmailLogTimingInfo();
            timingInfo.logId = existingLog.Id;
            timingInfo.logCreatedDate = existingLog.CreatedDate;
            timingInfo.logCreatedAt = existingLog.Created_At__c;
            timingInfo.hash = existingLog.Hash_1__c;
            timingInfo.organizationId = existingLog.Organization_Id__c;
            
            // Get ALL inbound email creation dates
            timingInfo.inboundEmailDates = new List<DateTime>();
            for (Inbound_Email__c inboundEmail : existingLog.Inbound_Emails__r) {
                timingInfo.inboundEmailDates.add(inboundEmail.CreatedDate);
            }
            
            // Store ALL existing logs for this hash
            if (!timingInfoMap.containsKey(existingLog.Hash_1__c)) {
                timingInfoMap.put(existingLog.Hash_1__c, new List<EmailLogTimingInfo>());
            }
            timingInfoMap.get(existingLog.Hash_1__c).add(timingInfo);
        }
        
        return timingInfoMap;
    }

    /**
     * Check if Request_Id_External__c values already exist in the system
     * @param requestIdsToCheck Set of Request_Id_External__c values to check
     * @return Set of Request_Id_External__c values that already exist
     */
    public static Set<String> getExistingRequestIds(Set<String> requestIdsToCheck) {
        Set<String> existingRequestIds = new Set<String>();
        
        if (requestIdsToCheck.isEmpty()) {
            return existingRequestIds;
        }
        
        for (Log__c existingLog : [
            SELECT Request_Id_External__c 
            FROM Log__c 
            WHERE Request_Id_External__c IN :requestIdsToCheck
        ]) {
            if (String.isNotBlank(existingLog?.Request_Id_External__c)) {
                existingRequestIds.add(existingLog.Request_Id_External__c);
            }
        }
        
        return existingRequestIds;
    }

    /**
     * Analyze timing matches between an event log and existing email logs
     * @param eventLog The event log to analyze
     * @param emailLogsForHash List of existing email logs with same hash1
     * @param dedupSettings Deduplication settings
     * @return LogMatchingResult with analysis results
     */
    public static LogMatchingResult analyzeLogMatching(Log__c eventLog, List<EmailLogTimingInfo> emailLogsForHash, Map<String, Object> dedupSettings) {
        LogMatchingResult result = new LogMatchingResult();
        result.eventLogHash = eventLog.Hash_1__c;
        result.eventLogTimestamp = eventLog.Created_At__c;
        result.emailLogsCount = emailLogsForHash != null ? emailLogsForHash.size() : 0;
        
        if (emailLogsForHash == null || emailLogsForHash.isEmpty()) {
            return result;
        }
        
        Integer timingToleranceSeconds = (Integer)dedupSettings.get('timingToleranceSeconds');
        
        // Analyze each email log for timing matches
        for (EmailLogTimingInfo emailInfo : emailLogsForHash) {
            EmailLogMatch emailMatch = new EmailLogMatch();
            emailMatch.emailLogId = emailInfo.logId;
            emailMatch.emailLogCreatedAt = emailInfo.logCreatedAt;
            emailMatch.emailLogCreatedDate = emailInfo.logCreatedDate;
            emailMatch.inboundEmailDates = emailInfo.inboundEmailDates;
            
            // Initialize Boolean fields to prevent null pointer exceptions
            emailMatch.isWithinTolerance = false;
            emailMatch.inboundEmailWithinTolerance = false;
            
            // Create the email log object for update
            emailMatch.emailLog = new Log__c();
            emailMatch.emailLog.Id = emailInfo.logId;
            
            // Check log Created_At timing
            if (emailInfo.logCreatedAt != null) {
                Long timeDiffMillis = Math.abs(eventLog.Created_At__c.getTime() - emailInfo.logCreatedAt.getTime());
                emailMatch.timeDifferenceSeconds = timeDiffMillis / 1000.0;
                emailMatch.isWithinTolerance = timeDiffMillis <= (timingToleranceSeconds * 1000);
            }
            
            // Check inbound email timing (priority over log timing)
            if (emailInfo.inboundEmailDates != null && !emailInfo.inboundEmailDates.isEmpty()) {
                Long closestDiffMillis = null;
                for (DateTime inboundDate : emailInfo.inboundEmailDates) {
                    Long diffMillis = Math.abs(eventLog.Created_At__c.getTime() - inboundDate.getTime());
                    if (closestDiffMillis == null || diffMillis < closestDiffMillis) {
                        closestDiffMillis = diffMillis;
                    }
                }
                emailMatch.closestInboundEmailDiff = closestDiffMillis != null ? closestDiffMillis / 1000.0 : null;
                emailMatch.inboundEmailWithinTolerance = closestDiffMillis != null && closestDiffMillis <= (timingToleranceSeconds * 1000);
                
            }
            
            result.emailLogMatches.add(emailMatch);
            
            // Determine if this is a timing match (prioritize inbound email timing)
            Boolean isTimingMatch = (emailMatch.inboundEmailWithinTolerance == true) || (emailMatch.isWithinTolerance == true);
            
            
            if (isTimingMatch && !result.hasTimingMatch) {
                result.hasTimingMatch = true;
                result.emailLogMatch = emailMatch;
            }
        }
        
        return result;
    }

    /**
     * Enhanced deduplication with Request_Id population and timing analysis
     * Maintains optimized flow after CSV processing is complete
     * @param eventType The event type being processed
     * @param dedupSettings Deduplication settings as Map
     * @param logger Logger instance for logging
     * @param allLogs All logs from the logger queue
     * @return List of final logs to keep after deduplication
     */
    public static List<Log__c> processEnhancedDeduplication(String eventType, Map<String, Object> dedupSettings, Logger logger, List<Log__c> allLogs) {
        try {
            // Check if deduplication is enabled and event type is configured
            Boolean enableEmailEventDeduplication = (Boolean)dedupSettings.get('enableEmailEventDeduplication');
            Set<String> eventTypesToCheck = (Set<String>)dedupSettings.get('eventTypesToCheck');
            
            if (!enableEmailEventDeduplication || !eventTypesToCheck.contains(eventType)) {
                return allLogs;
            }

            if (allLogs.isEmpty()) {
                return allLogs;
            }
            
            // Separate event logs (have Request_Id_External__c) from other logs
            List<Log__c> eventLogs = new List<Log__c>();
            List<Log__c> otherLogs = new List<Log__c>();
            
            for (Log__c log : allLogs) {
                String requestId = log.Request_Id_External__c;
                if (String.isNotBlank(requestId)) {
                    eventLogs.add(log);
                } else {
                    otherLogs.add(log);
                }
            }
            
            // Process event logs with email awareness
            List<Log__c> finalEventLogsToKeep = processEventLogsWithEmailAwareness(eventLogs, dedupSettings, logger);
            
            // Combine final results
            List<Log__c> finalLogsToKeep = new List<Log__c>();
            finalLogsToKeep.addAll(finalEventLogsToKeep);
            finalLogsToKeep.addAll(otherLogs); // Keep all other logs as-is

            return finalLogsToKeep;
        }
        catch (Exception e) {
            logger?.add(logger?.getInternalError(e, null, EventLogProcessors.class.getName(), 'Error processing enhanced deduplication'));
            return allLogs; // Return original logs if error occurs
        }
    }

    // ==========================================
    // Helper Classes for Enhanced Deduplication
    // ==========================================

    // Helper class to store email log timing information
    public class EmailLogTimingInfo {
        public String logId;
        public String hash;
        public String organizationId;
        public DateTime logCreatedDate;
        public DateTime logCreatedAt;
        public List<DateTime> inboundEmailDates;
    }

    // Helper class to store log matching analysis results
    public class LogMatchingResult {
        public String eventLogHash;
        public DateTime eventLogTimestamp;
        public Integer emailLogsCount;
        public Boolean hasTimingMatch;
        public EmailLogMatch emailLogMatch;
        public List<EmailLogMatch> emailLogMatches;
        
        public LogMatchingResult() {
            this.emailLogMatches = new List<EmailLogMatch>();
            this.hasTimingMatch = false;
        }
    }

    // Helper class to store individual email log match details
    public class EmailLogMatch {
        public String emailLogId;
        public DateTime emailLogCreatedAt;
        public DateTime emailLogCreatedDate;
        public List<DateTime> inboundEmailDates;
        public Decimal timeDifferenceSeconds;
        public Boolean isWithinTolerance;
        public Boolean inboundEmailWithinTolerance;
        public Decimal closestInboundEmailDiff;
        
        public Log__c emailLog;
    }
}