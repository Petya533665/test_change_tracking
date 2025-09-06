public class EventMonitoringProcessors {

    // Map of event type to event log processor class
    public static Map<String, Type> processorTypes = new Map<String, Type>{ 
        EventLogProcessors.EVENT_TYPE_API => SOAPApiEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => ApexCalloutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_EXECUTION => ApexExecutionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => ApexRestApiEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => ApexSOAPApiEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => ApexTriggerEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => ApexUnexpectedExceptionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE => ApiTotalUsageEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => AsyncReportRunEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => AuraRequestEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT => BlockedRedirectEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_BULK_API => BulkApiEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST => BulkApiRequestEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_2 => BulkApi2EventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION => ChangeSetOperationEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => ConcurrentLongRunningApexLimitEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONSOLE => ConsoleEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION => ContentDistributionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK => ContentDocumentLinkEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER => ContentTransferEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY => ContinuationCalloutSummaryEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CORS_VIOLATION => CorsViolationEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_CSP_VIOLATION => CspViolationEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_DASHBOARD => DashboardEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_DATABASE_SAVE => DatabaseSaveEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS => DocumentAttachmentDownloadsEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT => ExternalCustomApexCalloutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT => ExternalCrossOrgCalloutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT => ExternalDataSourceCalloutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT => ExternalODataCalloutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION => FlowExecutionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP => GroupMembershipEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS => HostnameRedirectsEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS => InsecureExternalAssetsEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => InsufficientAccessEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW => KnowledgeArticleViewEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => LightningErrorEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION => LightningInteractionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER => LightningLoggerEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW => LightningPageViewEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE => LightningPerformanceEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LOGIN => LoginEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LOGIN_AS => LoginAsEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_LOGOUT => LogoutEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION => MetadataApiOperationEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT => MultiblockReportEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL => NamedCredentialEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE => OneCommerceUsageEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL => PackageInstallEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE => PermissionUpdateEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION => PlatformEncryptionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_PRICING => PricingEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION => QueuedExecutionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_REPORT => ReportEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_REPORT_EXPORT => ReportExportEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_REST_API => RestApiEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_SANDBOX => SandboxEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_SEARCH => SearchEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_SEARCH_CLICK => SearchClickEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_SITES => SitesEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW => TimeBasedWorkflowEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY => TransactionSecurityEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING => UITelemetryNavigationTimingEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING => UITelemetryResourceTimingEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_URI => UriEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => VisualforceRequestEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_WAVE_CHANGE => WaveChangeEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD => WaveDownloadEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION => WaveInteractionEventLogProcessor.class,
        EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE => WavePerformanceEventLogProcessor.class
    };

    public static IEventLogProcessor createProcessor(String eventType) {
        Type processorType = processorTypes.get(eventType);
        if (processorType == null) {
            return null;
        }
        
        return (IEventLogProcessor)processorType.newInstance();
    }

    public static String getLogCategory(String eventType) {
        EventTypeMetadata metadata = EVENT_TYPE_METADATA.get(eventType);
        return metadata != null ? metadata.category : null;
    }

    public static String getLogArea(String eventType) {
        EventTypeMetadata metadata = EVENT_TYPE_METADATA.get(eventType);
        return metadata != null ? metadata.area : null;
    }

    @TestVisible
    public class EventTypeMetadata {
        public String category { get; private set; }
        public String area { get; private set; }

        public EventTypeMetadata(String category, String area) {
            this.category = category;
            this.area = area;
        }
    }

    @TestVisible
    private static final Map<String, EventTypeMetadata> EVENT_TYPE_METADATA = new Map<String, EventTypeMetadata>{
        EventLogProcessors.EVENT_TYPE_API => new EventTypeMetadata('API Usage', 'Development'),
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_APEX_EXECUTION => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => new EventTypeMetadata('Apex', 'Apex'),
        EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE => new EventTypeMetadata('API Usage', 'Monitoring'),
        EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => new EventTypeMetadata('Reporting', 'Reporting'),
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_BULK_API => new EventTypeMetadata('API Usage', 'Integration'),
        EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST => new EventTypeMetadata('API Usage', 'Integration'),
        EventLogProcessors.EVENT_TYPE_BULK_API_2 => new EventTypeMetadata('API Usage', 'Integration'),
        EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION => new EventTypeMetadata('Metadata', 'Development'),
        EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => new EventTypeMetadata('Apex', 'Development'),
        EventLogProcessors.EVENT_TYPE_CONSOLE => new EventTypeMetadata('User Activity', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION => new EventTypeMetadata('Content Management', 'Content'),
        EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK => new EventTypeMetadata('Content Management', 'Content'),
        EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER => new EventTypeMetadata('Content Management', 'Content'),
        EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY => new EventTypeMetadata('Apex', 'Development'),
        EventLogProcessors.EVENT_TYPE_CORS_VIOLATION => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_CSP_VIOLATION => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_DASHBOARD => new EventTypeMetadata('Reporting', 'Reporting'),
        EventLogProcessors.EVENT_TYPE_DATABASE_SAVE => new EventTypeMetadata('Database', 'Development'),
        EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS => new EventTypeMetadata('Content Management', 'Content'),
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT => new EventTypeMetadata('Apex', 'Integration'),
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT => new EventTypeMetadata('Integration', 'Integration'),
        EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT => new EventTypeMetadata('Integration', 'Integration'),
        EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT => new EventTypeMetadata('Integration', 'Integration'),
        EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION => new EventTypeMetadata('Flow', 'Automation'),
        EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW => new EventTypeMetadata('Knowledge', 'Content'),
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE => new EventTypeMetadata('Lightning', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_LOGIN => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_LOGIN_AS => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_LOGOUT => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION => new EventTypeMetadata('Metadata', 'Development'),
        EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT => new EventTypeMetadata('Reporting', 'Reporting'),
        EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL => new EventTypeMetadata('Integration', 'Integration'),
        EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE => new EventTypeMetadata('Commerce', 'Commerce'),
        EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL => new EventTypeMetadata('Metadata', 'Development'),
        EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_PRICING => new EventTypeMetadata('Commerce', 'Commerce'),
        EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION => new EventTypeMetadata('Apex', 'Development'),
        EventLogProcessors.EVENT_TYPE_REPORT => new EventTypeMetadata('Reporting', 'Reporting'),
        EventLogProcessors.EVENT_TYPE_REPORT_EXPORT => new EventTypeMetadata('Reporting', 'Reporting'),
        EventLogProcessors.EVENT_TYPE_REST_API => new EventTypeMetadata('API Usage', 'Integration'),
        EventLogProcessors.EVENT_TYPE_SANDBOX => new EventTypeMetadata('Environment', 'Development'),
        EventLogProcessors.EVENT_TYPE_SEARCH => new EventTypeMetadata('Search', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_SEARCH_CLICK => new EventTypeMetadata('Search', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_SITES => new EventTypeMetadata('Sites', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW => new EventTypeMetadata('Workflow', 'Automation'),
        EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING => new EventTypeMetadata('User Interface', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING => new EventTypeMetadata('User Interface', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_URI => new EventTypeMetadata('Security', 'Security'),
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => new EventTypeMetadata('Visualforce', 'User Interface'),
        EventLogProcessors.EVENT_TYPE_WAVE_CHANGE => new EventTypeMetadata('Analytics', 'Analytics'),
        EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD => new EventTypeMetadata('Analytics', 'Analytics'),
        EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION => new EventTypeMetadata('Analytics', 'Analytics'),
        EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE => new EventTypeMetadata('Analytics', 'Analytics')
    };

    // Event Log Processor Interface
    public interface IEventLogProcessor {
        List<Log__c> findMatches(List<EventLogProcessors.IBaseEventData> events, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig);
    }

    public abstract class BaseEventLog implements IEventLogProcessor {
        protected final String eventType;
        protected ThresholdManager thresholdManagerInstance;
        protected Integer logsLimitPerHour;
        protected Integer currentLogsCount;

        protected LogBuilder eventLogBuilder;

        protected BaseEventLog(String eventType) {
            this.eventType = eventType;
            this.thresholdManagerInstance = ThresholdManager.getInstance();
            this.logsLimitPerHour = thresholdManagerInstance.logsLimitPerHour.get(this.eventType);
            this.currentLogsCount = 0;

            this.eventLogBuilder = LogBuilder.getInstance()
                .type(eventType)
                .category(getLogCategory(eventType))
                .area(getLogArea(eventType));
        }

        public List<Log__c> findMatches(List<EventLogProcessors.IBaseEventData> events, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
            List<Log__c> matches = new List<Log__c>();
            
            for (EventLogProcessors.IBaseEventData event : events) {
                if (logsLimitPerHour != null && currentLogsCount >= logsLimitPerHour) {
                    return matches;
                }

                for (String metric : thresholdManagerInstance.getMetrics(this.eventType)) {
                    ThresholdConfig config = thresholdManagerInstance.getThreshold(this.eventType, metric);
                    Object value = event.getValue(metric);
                    Boolean isMatch = config.evaluateValue(value, fieldMetadataConfig);
                    if (isMatch) {
                        Log__c logRecord = createLogRecord(metric, value, config, event);
                        if (logRecord != null) {
                            matches.add(logRecord);
                            currentLogsCount++;
                        }
                    }
                }
            }
            return matches;
        }

        protected virtual String thresholdExceededString(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            String result = 'threshold exceeded: ';
            switch on config.evaluationType {
                when EQUALS {
                    result += String.format('{0} = {1}', new Object[]{value, config.threshold});
                }
                when GREATER_THAN {
                    result += String.format('{0} > {1}', new Object[]{value, config.threshold});
                }
                when LESS_THAN {
                    result += String.format('{0} < {1}', new Object[]{value, config.threshold});
                }
                when NOT_EQUALS {
                    result += String.format('{0} != {1}', new Object[]{value, config.threshold});
                }
                when NOT_NULL {
                    result += String.format('{0} != null', new Object[]{value});
                }
                when IS_IN {
                    result += String.format('{0} is in {1}', new Object[]{value, config.threshold});
                }
                when else {
                    result += 'undefined threshold evaluation type';
                }
            }
            return result;
        }

        protected virtual String getSummary(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format('{0} {1} {2}', new Object[]{this.eventType, metric, thresholdExceededString(metric, value, config, event)});
        }

        protected virtual String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            String details = String.format(
                '{0} Error: {1} exceeded threshold.\n' +
                'Event Type: {2}\n' +
                'Actual Value: {3}\n' +
                'Threshold: {4}',
                new Object[]{
                    this.eventType,
                    metric,
                    this.eventType,
                    value,
                    config.threshold
                }
            );
            return details;
        }

        protected virtual LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return this.eventLogBuilder
                .summary(getSummary(metric, value, config, event))
                .details(getDetails(metric, value, config, event))
                .attribute(Schema.SObjectType.Log__c.fields.User_Id__c.getName(), ((BaseEventData)event).userId)
                .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.getName(), ((BaseEventData)event).organizationId)
                .attribute(Schema.SObjectType.Log__c.fields.Created_At__c.getName(), ((BaseEventData)event).timestamp)
                .attribute(Schema.SObjectType.Log__c.fields.Request_Id_External__c.getName(), ((BaseEventData)event).requestId);
        }
        
        protected virtual Log__c createLogRecord(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            this.eventLogBuilder = baseLogBuilder(metric, value, config, event);
            return this.eventLogBuilder.tracePoint().build();
        }
    }

    public class SOAPApiEventLogProcessor extends BaseEventLog {
        public SOAPApiEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_API);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.SoapApiEventData soapApiData = (EventLogProcessors.SoapApiEventData)event;
            return String.format(
                'API Error: {0}.\n' +
                'API Type: {1}.\n' +
                'API Version: {2}.\n' +
                'Client Name: {3}.\n' +
                'Method Name: {4}.\n' ,
                new List<Object>{
                    value, 
                    soapApiData.apiType, 
                    soapApiData.apiVersion,
                    soapApiData.clientName,
                    soapApiData.methodName
                }
            );
        }
    }

    public class ApexCalloutEventLogProcessor extends BaseEventLog {
        public ApexCalloutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexCalloutData calloutData = (EventLogProcessors.ApexCalloutData)event;
            return String.format(
                'Apex Callout Error: Success: {0}.\n' +
                'Type: {1}.\n' +
                'Method: {2}.\n' +
                'URL: {3}.\n' +
                'URI: {4}.\n' +
                'Status Code: {5}.\n',
                new List<Object>{
                    value,
                    calloutData.type,
                    calloutData.method,
                    calloutData.url,
                    calloutData.uri,
                    calloutData.statusCode
                }
            );
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexCalloutData calloutData = (EventLogProcessors.ApexCalloutData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, calloutData.uri);
        }
    }

    public class ApexExecutionEventLogProcessor extends BaseEventLog {
        public ApexExecutionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_EXECUTION);
        }
    }

    public class ApexRestApiEventLogProcessor extends BaseEventLog {
        public ApexRestApiEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexRestApiEventData restApiData = (EventLogProcessors.ApexRestApiEventData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, restApiData.uri);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexRestApiEventData restApiData = (EventLogProcessors.ApexRestApiEventData)event;
            return String.format(
                'Apex Rest API Error: {0}.\n' +
                'Entity Name: {1}.\n' +
                'Method: {2}.\n' +
                'URI: {3}.\n' +
                'Query: {4}.\n' +
                'Request Status: {5}.\n' +
                'Status Code: {6}.\n',
                new List<Object>{
                    value,
                    restApiData.entityName,
                    restApiData.method,
                    restApiData.uri,
                    restApiData.query,
                    restApiData.requestStatus,
                    restApiData.statusCode
                }
            );
        }
    }

    public class ApexSOAPApiEventLogProcessor extends BaseEventLog {
        public ApexSOAPApiEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_SOAP);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexSoapApiEventData soapApiData = (EventLogProcessors.ApexSoapApiEventData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, soapApiData.className + '.' + soapApiData.methodName);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexSoapApiEventData soapApiData = (EventLogProcessors.ApexSoapApiEventData)event;
            return String.format(
                'Apex SOAP API Error: {0}.\n' +
                'Class Name: {1}.\n' +
                'Method Name: {2}.\n' +
                'Query: {3}.\n' +
                'URI: {4}.\n' +
                'Request Status: {5}.\n',
                new List<Object>{
                    value,
                    soapApiData.className,
                    soapApiData.methodName,
                    soapApiData.query,
                    soapApiData.uri,
                    soapApiData.requestStatus
                }
            );
        }
    }

    public class ApexTriggerEventLogProcessor extends BaseEventLog {
        public ApexTriggerEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexTriggerData triggerData = (EventLogProcessors.ApexTriggerData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, triggerData.entityName + '.' + triggerData.triggerName);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexTriggerData triggerData = (EventLogProcessors.ApexTriggerData)event;
            return String.format(
                'Apex Trigger Error: {0}.\n' +
                'Entity Name: {1}.\n' +
                'Trigger Name: {2}.\n' +
                'Trigger Type: {3}.\n' +
                'Request Status: {4}.\n',
                new List<Object>{
                    value,
                    triggerData.entityName,
                    triggerData.triggerName,
                    triggerData.triggerType,
                    triggerData.requestStatus
                }
            );
        }
    }

    public class ApexUnexpectedExceptionEventLogProcessor extends BaseEventLog {
        public ApexUnexpectedExceptionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexUnexpectedExceptionData unexpectedExceptionData = (EventLogProcessors.ApexUnexpectedExceptionData)event;

            String logType = 'System.UnexpectedException';
            if (String.isNotBlank(unexpectedExceptionData.exceptionCategory)) {
                logType = 'System.' + unexpectedExceptionData.exceptionCategory;
            }

            String summary = String.valueOf(value);
            if (String.isNotBlank(summary)) {
                // remove first two parts of the summary
                List<String> summaryParts = summary.split(': ');
                if (summaryParts.size() > 2) {
                    List<String> remainingParts = new List<String>();
                    for (Integer i = 2; i < summaryParts.size(); i++) {
                        remainingParts.add(summaryParts.get(i));
                    }
                    summary = String.join(remainingParts, ': ');
                }
            }

            return super.baseLogBuilder(metric, value, config, event)
                .summary(summary)
                .details(String.valueOf(value))
                .stackTrace(unexpectedExceptionData.stackTrace)
                .type(logType)
                .createIssue();
        }
    }

    public class ApiTotalUsageEventLogProcessor extends BaseEventLog {
        public ApiTotalUsageEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE);
        }
    }

    public class AsyncReportRunEventLogProcessor extends BaseEventLog {
        public AsyncReportRunEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
        }
    }

    public class AuraRequestEventLogProcessor extends BaseEventLog {
        public AuraRequestEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_AURA_REQUEST);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.AuraRequestData requestData = (EventLogProcessors.AuraRequestData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, requestData.uri);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.AuraRequestData requestData = (EventLogProcessors.AuraRequestData)event;
            return String.format(
                'Aura Request Error: {0}.\n' +
                'Request Status: {1}.\n' +
                'URI: {2}.\n' +
                'Request Method: {3}.\n' +
                'Action Message: {4}.\n',
                new List<Object>{
                    value,
                    requestData.requestStatus,
                    requestData.uri,
                    requestData.requestMethod,
                    requestData.actionMessage
                }
            );
        }
    }

    public class BlockedRedirectEventLogProcessor extends BaseEventLog {
        public BlockedRedirectEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT);
        }
    }

    public class BulkApiEventLogProcessor extends BaseEventLog {
        public BulkApiEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API);
        }
    }

    public class BulkApiRequestEventLogProcessor extends BaseEventLog {
        public BulkApiRequestEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST);
        }
    }

    public class BulkApi2EventLogProcessor extends BaseEventLog {
        public BulkApi2EventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API_2);
        }
    }

    public class ChangeSetOperationEventLogProcessor extends BaseEventLog {
        public ChangeSetOperationEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION);
        }
    }

    public class ConcurrentLongRunningApexLimitEventLogProcessor extends BaseEventLog {
        public ConcurrentLongRunningApexLimitEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT);
        }
    }

    public class ConsoleEventLogProcessor extends BaseEventLog {
        public ConsoleEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONSOLE);
        }
    }

    public class ContentDistributionEventLogProcessor extends BaseEventLog {
        public ContentDistributionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION);
        }
    }

    public class ContentDocumentLinkEventLogProcessor extends BaseEventLog {
        public ContentDocumentLinkEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK);
        }
    }

    public class ContentTransferEventLogProcessor extends BaseEventLog {
        public ContentTransferEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER);
        }
    }

    public class ContinuationCalloutSummaryEventLogProcessor extends BaseEventLog {
        public ContinuationCalloutSummaryEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY);
        }
    }

    public class CorsViolationEventLogProcessor extends BaseEventLog {
        public CorsViolationEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CORS_VIOLATION);
        }
    }

    public class CspViolationEventLogProcessor extends BaseEventLog {
        public CspViolationEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_CSP_VIOLATION);
        }
    }

    public class DashboardEventLogProcessor extends BaseEventLog {
        public DashboardEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_DASHBOARD);
        }
    }

    public class DatabaseSaveEventLogProcessor extends BaseEventLog {
        public DatabaseSaveEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_DATABASE_SAVE);
        }
    }

    public class DocumentAttachmentDownloadsEventLogProcessor extends BaseEventLog {
        public DocumentAttachmentDownloadsEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS);
        }
    }

    public class ExternalCustomApexCalloutEventLogProcessor extends BaseEventLog {
        public ExternalCustomApexCalloutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT);
        }
    }

    public class ExternalCrossOrgCalloutEventLogProcessor extends BaseEventLog {
        public ExternalCrossOrgCalloutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT);
        }
    }

    public class ExternalDataSourceCalloutEventLogProcessor extends BaseEventLog {
        public ExternalDataSourceCalloutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT);
        }
    }

    public class ExternalODataCalloutEventLogProcessor extends BaseEventLog {
        public ExternalODataCalloutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT);
        }
    }

    public class FlowExecutionEventLogProcessor extends BaseEventLog {
        public FlowExecutionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION);
        }
    }

    public class GroupMembershipEventLogProcessor extends BaseEventLog {
        public GroupMembershipEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP);
        }
    }

    public class HostnameRedirectsEventLogProcessor extends BaseEventLog {
        public HostnameRedirectsEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS);
        }
    }

    public class InsecureExternalAssetsEventLogProcessor extends BaseEventLog {
        public InsecureExternalAssetsEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS);
        }
    }

    public class InsufficientAccessEventLogProcessor extends BaseEventLog {
        public InsufficientAccessEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.InsufficientAccessData errorData = (EventLogProcessors.InsufficientAccessData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, errorData.entityType);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.InsufficientAccessData errorData = (EventLogProcessors.InsufficientAccessData)event;
            return String.format(
                'Insufficient Access Error: {0}.\n' +
                'Error Description: {1}.\n' +
                'Access Error: {2}.\n' +
                'Entity Type: {3}.\n' +
                'Record ID: {4}.\n' +
                'Requested Access Level: {5}.\n',
                new List<Object>{
                    value,
                    errorData.errorDescription,
                    errorData.accessError,
                    errorData.entityType,
                    errorData.recordId,
                    errorData.requestedAccessLevel
                }
            );
        }
    }

    public class KnowledgeArticleViewEventLogProcessor extends BaseEventLog {
        public KnowledgeArticleViewEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW);
        }
    }

    public class LightningErrorEventLogProcessor extends BaseEventLog {
        public LightningErrorEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.LightningErrorData errorData = (EventLogProcessors.LightningErrorData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .stackTrace(errorData.stackTrace)
                .attribute(Constants.LOG_SOBJECT.OPERATION, errorData.pageUrl);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.LightningErrorData errorData = (EventLogProcessors.LightningErrorData)event;
            return String.format(
                'Lightning Error: {0}.\n' +
                'Page URL: {1}.\n' +
                'UI Event: {2}.\n' +
                'Entity Type: {3}.\n' +
                'Entity ID: {4}.\n' +
                'Component Name: {5}.\n' +
                'App Name: {6}.\n' +
                'Message: {7}.\n' +
                'Stack Trace: {8}.\n',
                new List<Object>{
                    value,
                    errorData.pageUrl,
                    errorData.uiEventId,
                    errorData.pageEntityType,
                    errorData.pageEntityId,
                    errorData.componentName,
                    errorData.appName,
                    errorData.message,
                    errorData.stackTrace
                }
            );
        }
    }

    public class LightningInteractionEventLogProcessor extends BaseEventLog {
        public LightningInteractionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION);
        }
    }

    public class LightningLoggerEventLogProcessor extends BaseEventLog {
        public LightningLoggerEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER);
        }
    }

    public class LightningPageViewEventLogProcessor extends BaseEventLog {
        public LightningPageViewEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW);
        }
    }

    public class LightningPerformanceEventLogProcessor extends BaseEventLog {
        public LightningPerformanceEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE);
        }
    }

    public class LoginEventLogProcessor extends BaseEventLog {
        public LoginEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LOGIN);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.LoginEventData loginData = (EventLogProcessors.LoginEventData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, loginData.loginUrl);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.LoginEventData loginData = (EventLogProcessors.LoginEventData)event;
            return String.format(
                'Login Error: {0}.\n' +
                'Login URL: {1}.\n' +
                'Login Status: {2}.\n' +
                'Login Type: {3}.\n' +
                'API Type: {4}.\n' +
                'API Version: {5}.\n' +
                'Request Status: {6}.\n',
                new List<Object>{
                    value,
                    loginData.loginUrl,
                    loginData.loginStatus,
                    loginData.loginType,
                    loginData.apiType,
                    loginData.apiVersion,
                    loginData.requestStatus
                }
            );
        }
    }

    public class LoginAsEventLogProcessor extends BaseEventLog {
        public LoginAsEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LOGIN_AS);
        }
    }

    public class LogoutEventLogProcessor extends BaseEventLog {
        public LogoutEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_LOGOUT);
        }
    }

    public class MetadataApiOperationEventLogProcessor extends BaseEventLog {
        public MetadataApiOperationEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION);
        }
    }

    public class MultiblockReportEventLogProcessor extends BaseEventLog {
        public MultiblockReportEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT);
        }
    }

    public class NamedCredentialEventLogProcessor extends BaseEventLog {
        public NamedCredentialEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL);
        }
    }

    public class OneCommerceUsageEventLogProcessor extends BaseEventLog {
        public OneCommerceUsageEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE);
        }
    }

    public class PackageInstallEventLogProcessor extends BaseEventLog {
        public PackageInstallEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL);
        }
    }

    public class PermissionUpdateEventLogProcessor extends BaseEventLog {
        public PermissionUpdateEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE);
        }
    }

    public class PlatformEncryptionEventLogProcessor extends BaseEventLog {
        public PlatformEncryptionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION);
        }
    }

    public class PricingEventLogProcessor extends BaseEventLog {
        public PricingEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_PRICING);
        }
    }

    public class QueuedExecutionEventLogProcessor extends BaseEventLog {
        public QueuedExecutionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION);
        }
    }

    public class ReportEventLogProcessor extends BaseEventLog {
        public ReportEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_REPORT);
        }
    }

    public class ReportExportEventLogProcessor extends BaseEventLog {
        public ReportExportEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_REPORT_EXPORT);
        }
    }

    public class RestApiEventLogProcessor extends BaseEventLog {
        public RestApiEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_REST_API);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.RestApiData restApiData = (EventLogProcessors.RestApiData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, restApiData.uri);
        }

        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.RestApiData restApiData = (EventLogProcessors.RestApiData)event;
            return String.format(
                'Rest API Error: {0}.\n' +
                'URI: {1}.\n' +
                'Method: {2}.\n' +
                'Query: {3}.\n' +
                'Entity Name: {4}.\n' +
                'Request Status: {5}.\n' +
                'Status Code: {6}.\n',
                new List<Object>{
                    value,
                    restApiData.uri,
                    restApiData.method,
                    restApiData.query,
                    restApiData.entityName,
                    restApiData.requestStatus,
                    restApiData.statusCode
                }
            );
        }
    }

    public class SandboxEventLogProcessor extends BaseEventLog {
        public SandboxEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_SANDBOX);
        }
    }

    public class SearchEventLogProcessor extends BaseEventLog {
        public SearchEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_SEARCH);
        }
    }

    public class SearchClickEventLogProcessor extends BaseEventLog {
        public SearchClickEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_SEARCH_CLICK);
        }
    }

    public class SitesEventLogProcessor extends BaseEventLog {
        public SitesEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_SITES);
        }
    }

    public class TimeBasedWorkflowEventLogProcessor extends BaseEventLog {
        public TimeBasedWorkflowEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW);
        }
    }

    public class TransactionSecurityEventLogProcessor extends BaseEventLog {
        public TransactionSecurityEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY);
        }
    }

    public class UITelemetryNavigationTimingEventLogProcessor extends BaseEventLog {
        public UITelemetryNavigationTimingEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING);
        }
    }

    public class UITelemetryResourceTimingEventLogProcessor extends BaseEventLog {
        public UITelemetryResourceTimingEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING);
        }
    }

    public class UriEventLogProcessor extends BaseEventLog {
        public UriEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_URI);
        }
    }

    public class VisualforceRequestEventLogProcessor extends BaseEventLog {
        public VisualforceRequestEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST);
        }

        protected override LogBuilder baseLogBuilder(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.VisualforceRequestData requestData = (EventLogProcessors.VisualforceRequestData)event;
            return super.baseLogBuilder(metric, value, config, event)
                .attribute(Constants.LOG_SOBJECT.OPERATION, requestData.uri);
        }
        
        protected override String getDetails(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.VisualforceRequestData requestData = (EventLogProcessors.VisualforceRequestData)event;
            return String.format(
                'Visualforce Request Error: {0}.\n' +
                'URI: {1}.\n' +
                'Request Status: {2}.\n' +
                'Page Name: {3}.\n' +
                'Query: {4}.\n' +
                'Controller Type: {5}.\n' +
                'HTTP Method: {6}.\n' +
                'Namespace: {7}.\n' +
                'Request Status: {8}.\n' +
                'Request Type: {9}.\n',
                new List<Object>{
                    value,
                    requestData.uri,
                    requestData.requestStatus,
                    requestData.pageName,
                    requestData.query,
                    requestData.controllerType,
                    requestData.httpMethod,
                    requestData.managedPackageNamespace,
                    requestData.requestStatus,
                    requestData.requestType
                }
            );
        }
    }

    public class WaveChangeEventLogProcessor extends BaseEventLog {
        public WaveChangeEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_CHANGE);
        }
    }

    public class WaveDownloadEventLogProcessor extends BaseEventLog {
        public WaveDownloadEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD);
        }
    }

    public class WaveInteractionEventLogProcessor extends BaseEventLog {
        public WaveInteractionEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION);
        }
    }

    public class WavePerformanceEventLogProcessor extends BaseEventLog {
        public WavePerformanceEventLogProcessor() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE);
        }
    }
}