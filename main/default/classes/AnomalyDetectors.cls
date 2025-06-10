public class AnomalyDetectors {

    // Map of event type to anomaly detector class
    public static Map<String, Type> detectorTypes = new Map<String, Type>{ 
        EventLogProcessors.EVENT_TYPE_API => SOAPApiEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => ApexCalloutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_EXECUTION => ApexExecutionAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => ApexRestApiEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => ApexSOAPApiEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => ApexTriggerEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => ApexUnexpectedExceptionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE => ApiTotalUsageEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => AsyncReportRunEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => AuraRequestEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT => BlockedRedirectEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_BULK_API => BulkApiEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST => BulkApiRequestEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_2 => BulkApi2EventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION => ChangeSetOperationEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => ConcurrentLongRunningApexLimitEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONSOLE => ConsoleEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION => ContentDistributionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK => ContentDocumentLinkEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER => ContentTransferEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY => ContinuationCalloutSummaryEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CORS_VIOLATION => CorsViolationEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_CSP_VIOLATION => CspViolationEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_DASHBOARD => DashboardEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_DATABASE_SAVE => DatabaseSaveEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS => DocumentAttachmentDownloadsEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT => ExternalCustomApexCalloutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT => ExternalCrossOrgCalloutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT => ExternalDataSourceCalloutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT => ExternalODataCalloutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION => FlowExecutionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP => GroupMembershipEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS => HostnameRedirectsEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS => InsecureExternalAssetsEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => InsufficientAccessEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW => KnowledgeArticleViewEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => LightningErrorEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION => LightningInteractionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER => LightningLoggerEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW => LightningPageViewEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE => LightningPerformanceEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LOGIN => LoginEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LOGIN_AS => LoginAsEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_LOGOUT => LogoutEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION => MetadataApiOperationEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT => MultiblockReportEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL => NamedCredentialEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE => OneCommerceUsageEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL => PackageInstallEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE => PermissionUpdateEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION => PlatformEncryptionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_PRICING => PricingEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION => QueuedExecutionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_REPORT => ReportEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_REPORT_EXPORT => ReportExportEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_REST_API => RestApiEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_SANDBOX => SandboxEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_SEARCH => SearchEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_SEARCH_CLICK => SearchClickEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_SITES => SitesEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW => TimeBasedWorkflowEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY => TransactionSecurityEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING => UITelemetryNavigationTimingEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING => UITelemetryResourceTimingEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_URI => UriEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => VisualforceRequestEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_WAVE_CHANGE => WaveChangeEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD => WaveDownloadEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION => WaveInteractionEventAnomalyDetector.class,
        EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE => WavePerformanceEventAnomalyDetector.class
    };

    public static IAnomalyDetector createDetector(String eventType) {
        Type detectorType = detectorTypes.get(eventType);
        if (detectorType == null) {
            return null;
        }
        
        return (IAnomalyDetector)detectorType.newInstance();
    }
    
    // Base Event Anomaly class
    public class EventAnomaly {
        public String eventType { get; private set; }
        public String metric { get; private set; }
        public Object value { get; private set; }
        public ThresholdConfig.AnomalySeverity severity { get; private set; }
        public String details { get; private set; }
        public String summary { get; private set; }

        public String logCategory { get; private set; }
        public String logArea { get; private set; }
        public String logStackTrace { get; private set; }
        public String logType { get; private set; }

        public String logUserId { get; private set; }
        public String logOrganizationId { get; private set; }
        public DateTime logTimestamp { get; private set; }
        public String logRequestId { get; private set; }
        

        public EventAnomaly(String eventType, String metric, 
                           Object value, ThresholdConfig.AnomalySeverity severity,
                           String details, String summary, String stackTrace, String logType,
                           String logUserId, String logOrganizationId, DateTime logTimestamp, String logRequestId) {
            this.eventType = eventType;
            this.metric = metric;
            this.value = value;
            this.severity = severity;
            this.details = details;
            this.summary = summary;

            this.logCategory = getLogCategory(eventType);
            this.logArea = getLogArea(eventType);
            this.logStackTrace = stackTrace;
            this.logType = logType;

            this.logUserId = logUserId;
            this.logOrganizationId = logOrganizationId;
            this.logTimestamp = logTimestamp;
            this.logRequestId = logRequestId;
        }
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

    // Anomaly Detector Interface
    public interface IAnomalyDetector {
        List<EventAnomaly> detectAnomalies(List<EventLogProcessors.IBaseEventData> events, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig);
    }

    public abstract class BaseAnomalyDetector implements IAnomalyDetector {
        protected final String eventType;
        protected ThresholdManager thresholdManager;

        protected BaseAnomalyDetector(String eventType) {
            this.eventType = eventType;
            this.thresholdManager = new ThresholdManager();
        }

        public List<EventAnomaly> detectAnomalies(List<EventLogProcessors.IBaseEventData> events, EventLogProcessors.FieldMetadataConfig fieldMetadataConfig) {
            List<EventAnomaly> anomalies = new List<EventAnomaly>();
            for (EventLogProcessors.IBaseEventData event : events) {
                for (String metric : thresholdManager.getMetrics(this.eventType)) {
                    ThresholdConfig config = thresholdManager.getThreshold(this.eventType, metric);
                    Object value = event.getValue(metric);
                    ThresholdConfig.AnomalySeverity severity = config.evaluateValue(value, fieldMetadataConfig);
                    if (severity != ThresholdConfig.AnomalySeverity.NORMAL) {
                        anomalies.add(new EventAnomaly(
                            this.eventType,
                            metric,
                            value,
                            severity,
                            generateDescription(metric, value, config, event),
                            generateSummary(metric, value, config, event),
                            generateStackTrace(metric, value, config, event),
                            generateLogType(metric, value, config, event),
                            generateLogUserId(metric, value, config, event),
                            generateLogOrganizationId(metric, value, config, event),
                            generateLogTimestamp(metric, value, config, event),
                            generateLogRequestId(metric, value, config, event)
                        ));
                    }
                }
            }
            return anomalies;
        }

        protected virtual String generateLogType(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return this.eventType;
        }

        protected virtual String generateStackTrace(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return null;
        }

        protected virtual String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                '{4} metric {0} exceeded threshold with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold,
                    this.eventType
                }
            );
        }

        protected virtual String generateSummary(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Event Anomaly: by metric {0}, for event type {1}',
                new List<String>{
                    metric,
                    this.eventType
                }
            );
        }

        protected virtual String generateLogUserId(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return ((BaseEventData)event).userId;
        }

        protected virtual String generateLogOrganizationId(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return ((BaseEventData)event).organizationId;
        }

        protected virtual DateTime generateLogTimestamp(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return ((BaseEventData)event).timestamp;
        }

        protected virtual String generateLogRequestId(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return ((BaseEventData)event).requestId;
        }
    }

    public class SOAPApiEventAnomalyDetector extends BaseAnomalyDetector {
        public SOAPApiEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_API);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.SoapApiEventData soapApiData = (EventLogProcessors.SoapApiEventData)event;
            return String.format(
                'SOAP API {0} anomaly detected with value {1}. ' +
                'API Type: {2}, API Version: {3}. ' +
                'Warning threshold: {4}, Critical threshold: {5}',
                new List<Object>{
                    metric, 
                    value, 
                    soapApiData.apiType, 
                    soapApiData.apiVersion,
                    config.warningThreshold, 
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexCalloutEventAnomalyDetector extends BaseAnomalyDetector {
        public ApexCalloutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_CALLOUT);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexCalloutData calloutData = (EventLogProcessors.ApexCalloutData)event;
            return String.format(
                'Apex Callout {0} anomaly detected with value {1}. ' +
                'URL: {2}, Method: {3}, Type: {4}. ' +
                'Warning threshold: {5}, Critical threshold: {6}',
                new List<Object>{
                    metric,
                    value,
                    calloutData.url,
                    calloutData.method,
                    calloutData.type,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexExecutionAnomalyDetector extends BaseAnomalyDetector {
        public ApexExecutionAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_EXECUTION);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Apex execution metric {0} exceeded threshold with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexRestApiEventAnomalyDetector extends BaseAnomalyDetector {
        public ApexRestApiEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_REST_API);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Apex Rest API {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexSOAPApiEventAnomalyDetector extends BaseAnomalyDetector {
        public ApexSOAPApiEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_SOAP);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Apex SOAP API {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexTriggerEventAnomalyDetector extends BaseAnomalyDetector {
        public ApexTriggerEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_TRIGGER);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Apex Trigger {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class ApexUnexpectedExceptionEventAnomalyDetector extends BaseAnomalyDetector {
        public ApexUnexpectedExceptionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION);
        }

        protected override String generateLogType(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexUnexpectedExceptionData exceptionData = (EventLogProcessors.ApexUnexpectedExceptionData)event;
            if (String.isNotBlank(exceptionData.exceptionCategory)) {
                return 'System.' + exceptionData.exceptionCategory;
            }
            return 'System.UnexpectedException';
        }

        protected override String generateStackTrace(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            EventLogProcessors.ApexUnexpectedExceptionData exceptionData = (EventLogProcessors.ApexUnexpectedExceptionData)event;
            return exceptionData.stackTrace;
        }

        protected override String generateSummary(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
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
            return summary;
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.valueOf(value);
        }
    }

    public class ApiTotalUsageEventAnomalyDetector extends BaseAnomalyDetector {
        public ApiTotalUsageEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'API Total Usage {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class AsyncReportRunEventAnomalyDetector extends BaseAnomalyDetector {
        public AsyncReportRunEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Async Report Run {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class AuraRequestEventAnomalyDetector extends BaseAnomalyDetector {
        public AuraRequestEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_AURA_REQUEST);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Aura Request {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class BlockedRedirectEventAnomalyDetector extends BaseAnomalyDetector {
        public BlockedRedirectEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT);
        }

        protected override String generateDescription(String metric, Object value, ThresholdConfig config, EventLogProcessors.IBaseEventData event) {
            return String.format(
                'Blocked Redirect {0} anomaly detected with value {1}. ' +
                'Warning threshold: {2}, Critical threshold: {3}',
                new List<Object>{
                    metric,
                    value,
                    config.warningThreshold,
                    config.criticalThreshold
                }
            );
        }
    }

    public class BulkApiEventAnomalyDetector extends BaseAnomalyDetector {
        public BulkApiEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API);
        }
    }

    public class BulkApiRequestEventAnomalyDetector extends BaseAnomalyDetector {
        public BulkApiRequestEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST);
        }
    }

    public class BulkApi2EventAnomalyDetector extends BaseAnomalyDetector {
        public BulkApi2EventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_BULK_API_2);
        }
    }

    public class ChangeSetOperationEventAnomalyDetector extends BaseAnomalyDetector {
        public ChangeSetOperationEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION);
        }
    }

    public class ConcurrentLongRunningApexLimitEventAnomalyDetector extends BaseAnomalyDetector {
        public ConcurrentLongRunningApexLimitEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT);
        }
    }

    public class ConsoleEventAnomalyDetector extends BaseAnomalyDetector {
        public ConsoleEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONSOLE);
        }
    }

    public class ContentDistributionEventAnomalyDetector extends BaseAnomalyDetector {
        public ContentDistributionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION);
        }
    }

    public class ContentDocumentLinkEventAnomalyDetector extends BaseAnomalyDetector {
        public ContentDocumentLinkEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK);
        }
    }

    public class ContentTransferEventAnomalyDetector extends BaseAnomalyDetector {
        public ContentTransferEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER);
        }
    }

    public class ContinuationCalloutSummaryEventAnomalyDetector extends BaseAnomalyDetector {
        public ContinuationCalloutSummaryEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY);
        }
    }

    public class CorsViolationEventAnomalyDetector extends BaseAnomalyDetector {
        public CorsViolationEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CORS_VIOLATION);
        }
    }

    public class CspViolationEventAnomalyDetector extends BaseAnomalyDetector {
        public CspViolationEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_CSP_VIOLATION);
        }
    }

    public class DashboardEventAnomalyDetector extends BaseAnomalyDetector {
        public DashboardEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_DASHBOARD);
        }
    }

    public class DatabaseSaveEventAnomalyDetector extends BaseAnomalyDetector {
        public DatabaseSaveEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_DATABASE_SAVE);
        }
    }

    public class DocumentAttachmentDownloadsEventAnomalyDetector extends BaseAnomalyDetector {
        public DocumentAttachmentDownloadsEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS);
        }
    }

    public class ExternalCustomApexCalloutEventAnomalyDetector extends BaseAnomalyDetector {
        public ExternalCustomApexCalloutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT);
        }
    }

    public class ExternalCrossOrgCalloutEventAnomalyDetector extends BaseAnomalyDetector {
        public ExternalCrossOrgCalloutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT);
        }
    }

    public class ExternalDataSourceCalloutEventAnomalyDetector extends BaseAnomalyDetector {
        public ExternalDataSourceCalloutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT);
        }
    }

    public class ExternalODataCalloutEventAnomalyDetector extends BaseAnomalyDetector {
        public ExternalODataCalloutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT);
        }
    }

    public class FlowExecutionEventAnomalyDetector extends BaseAnomalyDetector {
        public FlowExecutionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION);
        }
    }

    public class GroupMembershipEventAnomalyDetector extends BaseAnomalyDetector {
        public GroupMembershipEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP);
        }
    }

    public class HostnameRedirectsEventAnomalyDetector extends BaseAnomalyDetector {
        public HostnameRedirectsEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS);
        }
    }

    public class InsecureExternalAssetsEventAnomalyDetector extends BaseAnomalyDetector {
        public InsecureExternalAssetsEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS);
        }
    }

    public class InsufficientAccessEventAnomalyDetector extends BaseAnomalyDetector {
        public InsufficientAccessEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS);
        }
    }

    public class KnowledgeArticleViewEventAnomalyDetector extends BaseAnomalyDetector {
        public KnowledgeArticleViewEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW);
        }
    }

    public class LightningErrorEventAnomalyDetector extends BaseAnomalyDetector {
        public LightningErrorEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR);
        }
    }

    public class LightningInteractionEventAnomalyDetector extends BaseAnomalyDetector {
        public LightningInteractionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION);
        }
    }

    public class LightningLoggerEventAnomalyDetector extends BaseAnomalyDetector {
        public LightningLoggerEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER);
        }
    }

    public class LightningPageViewEventAnomalyDetector extends BaseAnomalyDetector {
        public LightningPageViewEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW);
        }
    }

    public class LightningPerformanceEventAnomalyDetector extends BaseAnomalyDetector {
        public LightningPerformanceEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE);
        }
    }

    public class LoginEventAnomalyDetector extends BaseAnomalyDetector {
        public LoginEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LOGIN);
        }
    }

    public class LoginAsEventAnomalyDetector extends BaseAnomalyDetector {
        public LoginAsEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LOGIN_AS);
        }
    }

    public class LogoutEventAnomalyDetector extends BaseAnomalyDetector {
        public LogoutEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_LOGOUT);
        }
    }

    public class MetadataApiOperationEventAnomalyDetector extends BaseAnomalyDetector {
        public MetadataApiOperationEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION);
        }
    }

    public class MultiblockReportEventAnomalyDetector extends BaseAnomalyDetector {
        public MultiblockReportEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT);
        }
    }

    public class NamedCredentialEventAnomalyDetector extends BaseAnomalyDetector {
        public NamedCredentialEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL);
        }
    }

    public class OneCommerceUsageEventAnomalyDetector extends BaseAnomalyDetector {
        public OneCommerceUsageEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE);
        }
    }

    public class PackageInstallEventAnomalyDetector extends BaseAnomalyDetector {
        public PackageInstallEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL);
        }
    }

    public class PermissionUpdateEventAnomalyDetector extends BaseAnomalyDetector {
        public PermissionUpdateEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE);
        }
    }

    public class PlatformEncryptionEventAnomalyDetector extends BaseAnomalyDetector {
        public PlatformEncryptionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION);
        }
    }

    public class PricingEventAnomalyDetector extends BaseAnomalyDetector {
        public PricingEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_PRICING);
        }
    }

    public class QueuedExecutionEventAnomalyDetector extends BaseAnomalyDetector {
        public QueuedExecutionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION);
        }
    }

    public class ReportEventAnomalyDetector extends BaseAnomalyDetector {
        public ReportEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_REPORT);
        }
    }

    public class ReportExportEventAnomalyDetector extends BaseAnomalyDetector {
        public ReportExportEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_REPORT_EXPORT);
        }
    }

    public class RestApiEventAnomalyDetector extends BaseAnomalyDetector {
        public RestApiEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_REST_API);
        }
    }

    public class SandboxEventAnomalyDetector extends BaseAnomalyDetector {
        public SandboxEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_SANDBOX);
        }
    }

    public class SearchEventAnomalyDetector extends BaseAnomalyDetector {
        public SearchEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_SEARCH);
        }
    }

    public class SearchClickEventAnomalyDetector extends BaseAnomalyDetector {
        public SearchClickEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_SEARCH_CLICK);
        }
    }

    public class SitesEventAnomalyDetector extends BaseAnomalyDetector {
        public SitesEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_SITES);
        }
    }

    public class TimeBasedWorkflowEventAnomalyDetector extends BaseAnomalyDetector {
        public TimeBasedWorkflowEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW);
        }
    }

    public class TransactionSecurityEventAnomalyDetector extends BaseAnomalyDetector {
        public TransactionSecurityEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY);
        }
    }

    public class UITelemetryNavigationTimingEventAnomalyDetector extends BaseAnomalyDetector {
        public UITelemetryNavigationTimingEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING);
        }
    }

    public class UITelemetryResourceTimingEventAnomalyDetector extends BaseAnomalyDetector {
        public UITelemetryResourceTimingEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING);
        }
    }

    public class UriEventAnomalyDetector extends BaseAnomalyDetector {
        public UriEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_URI);
        }
    }

    public class VisualforceRequestEventAnomalyDetector extends BaseAnomalyDetector {
        public VisualforceRequestEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST);
        }
    }

    public class WaveChangeEventAnomalyDetector extends BaseAnomalyDetector {
        public WaveChangeEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_CHANGE);
        }
    }

    public class WaveDownloadEventAnomalyDetector extends BaseAnomalyDetector {
        public WaveDownloadEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD);
        }
    }

    public class WaveInteractionEventAnomalyDetector extends BaseAnomalyDetector {
        public WaveInteractionEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION);
        }
    }

    public class WavePerformanceEventAnomalyDetector extends BaseAnomalyDetector {
        public WavePerformanceEventAnomalyDetector() {
            super(EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE);
        }
    }
}