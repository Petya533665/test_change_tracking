public class ThresholdManager {
    private static ThresholdManager instance;
    private Map<String, Map<String, ThresholdConfig>> thresholds;
    public Map<String, Integer> logsLimitPerHour;
    

    public ThresholdManager() {
        initializeThresholds();
    }

    public static ThresholdManager getInstance() {
        if (instance == null) {
            instance = new ThresholdManager();
        }
        return instance;
    }
    
    @TestVisible
    public static void resetInstance() {
        instance = null;
    }

    // Initialize default thresholds
    private void initializeThresholds() {
        thresholds = new Map<String, Map<String, ThresholdConfig>>();

        if (testThresholds != null) {
            thresholds = testThresholds;
            
            // In testThresholds mode, use default logs limits to avoid interference from Rule__c records
            logsLimitPerHour = new Map<String, Integer>();
            for (String eventType : EventMonitoringUtil.MAP_DEFAULT_LOGS_LIMIT_PER_HOUR.keySet()) {
                logsLimitPerHour.put(eventType, EventMonitoringUtil.MAP_DEFAULT_LOGS_LIMIT_PER_HOUR.get(eventType));
            }
            return;
        }
        List<Rule__c> rules = EventMonitoringUtil.getActiveEventMonitoringRules();
        thresholds = EventMonitoringUtil.loadThresholdsFromRules(rules);
        logsLimitPerHour = EventMonitoringUtil.getLogsLimitPerHour(rules);
    }

    public Set<String> getMetrics(String eventType) {
        if (thresholds.containsKey(eventType)) {
            return thresholds.get(eventType).keySet();
        }
        return new Set<String>();
    }

    // Get threshold configuration
    public ThresholdConfig getThreshold(String eventType, String metric) {
        return thresholds.get(eventType)?.get(metric);
    }

    @TestVisible
    private static  Map<String, Map<String, ThresholdConfig>> testThresholds;

    private static final Map<String, Type> EVENT_TYPE_TO_THRESHOLD_CONFIG = new Map<String, Type>{
        EventLogProcessors.EVENT_TYPE_API => SOAPAPIEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => ApexCalloutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_EXECUTION => ApexExecutionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_REST_API => ApexRestApiThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_SOAP => ApexSOAPApiThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => ApexTriggerThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => ApexUnexpectedExceptionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE => ApiTotalUsageThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => AsyncReportRunThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_AURA_REQUEST => AuraRequestThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT => BlockedRedirectThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_BULK_API => BulkApiThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST => BulkApiRequestThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_BULK_API_2 => BulkApi2ThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION => ChangeSetOperationThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT => ConcurrentLongRunningApexLimitThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONSOLE => ConsoleEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION => ContentDistributionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK => ContentDocumentLinkThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER => ContentTransferThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY => ContinuationCalloutSummaryThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CORS_VIOLATION => CorsViolationThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_CSP_VIOLATION => CspViolationThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_DASHBOARD => DashboardThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_DATABASE_SAVE => DatabaseSaveThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS => DocumentAttachmentDownloadsThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT => ExternalCustomApexCalloutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT => ExternalCrossOrgCalloutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT => ExternalDataSourceCalloutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT => ExternalODataCalloutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION => FlowExecutionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP => GroupMembershipThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS => HostnameRedirectsThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS => InsecureExternalAssetsThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS => InsufficientAccessThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW => KnowledgeArticleViewThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR => LightningErrorThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION => LightningInteractionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER => LightningLoggerThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW => LightningPageViewThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE => LightningPerformanceThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LOGIN => LoginThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LOGIN_AS => LoginAsThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_LOGOUT => LogoutThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION => MetadataApiOperationThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT => MultiblockReportThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL => NamedCredentialThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE => OneCommerceUsageThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL => PackageInstallThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE => PermissionUpdateThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION => PlatformEncryptionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_PRICING => PricingEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION => QueuedExecutionThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_REPORT => ReportEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_REPORT_EXPORT => ReportExportEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_REST_API => RestApiThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_SANDBOX => SandboxThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_SEARCH => SearchEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_SEARCH_CLICK => SearchClickEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_SITES => SitesEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW => TimeBasedWorkflowThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY => TransactionSecurityThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING => UITelemetryNavigationTimingThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING => UITelemetryResourceTimingThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_URI => UriEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST => VisualforceRequestThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_WAVE_CHANGE => WaveChangeEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD => WaveDownloadEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION => WaveInteractionEventThresholdConfig.class,
        EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE => WavePerformanceEventThresholdConfig.class
    };

    public virtual class ThresholdConfigSetup {
        
        public virtual Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class SOAPAPIEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_API;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_API => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeNs(this.eventType),
                    'RUN_TIME' => runTime(this.eventType),
                    'ROWS_PROCESSED' => rowsProcessed(this.eventType),
                    'DB_BLOCKS' => dbBlocks(this.eventType),
                    'REQUEST_SIZE' => requestSize(this.eventType),
                    'RESPONSE_SIZE' => responseSize(this.eventType),
                    'REQUEST_STATUS' => requestStatus(this.eventType),
                    'QUERY_COUNT' => queryCount(this.eventType)
                }
            };
        }
    }

    public class ApexCalloutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_CALLOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_CALLOUT => new Map<String, ThresholdConfig>{
                    'TIME' => time(this.eventType),
                    'CPU_TIME' => cpuTime(this.eventType),
                    'STATUS_CODE' => statusCode(this.eventType),
                    'REQUEST_SIZE' => requestSize(this.eventType),
                    'RESPONSE_SIZE' => responseSize(this.eventType)
                }
            };
        }
    }

    public class ApexExecutionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_EXECUTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_EXECUTION => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeMs(this.eventType),
                    'NUMBER_SOQL_QUERIES' => numberSoqlQueries(this.eventType)
                }
            };
        }
    }

    public class ApexRestApiThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_REST_API;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_REST_API => new Map<String, ThresholdConfig>{
                    'RUN_TIME' => time(this.eventType),
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_CPU_TIME' => dbCpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeNs(this.eventType),
                    'REQUEST_SIZE' => requestSize(this.eventType),
                    'RESPONSE_SIZE' => responseSize(this.eventType),
                    'STATUS_CODE' => statusCode(this.eventType)
                }
            };
        }
    }

    public class ApexSOAPApiThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_SOAP;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_SOAP => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeMs(this.eventType),
                    'RUN_TIME' => runTime(this.eventType),
                    'LIMIT_USAGE_PERCENT' => limitUsagePercent(this.eventType),
                    'REQUEST_STATUS' => requestStatus(this.eventType)
                }
            };
        }
    }

    public class ApexTriggerThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_TRIGGER;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_TRIGGER => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeMs(this.eventType),
                    'EXEC_TIME' => execTime(this.eventType),
                    'REQUEST_STATUS' => requestStatus(this.eventType)
                }
            };
        }
    }

    public class ApexUnexpectedExceptionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_APEX_UNEXPECTED_EXCEPTION => new Map<String, ThresholdConfig>{
                    'EXCEPTION_MESSAGE' => exceptionMessage(this.eventType)
                }
            };
        }
    }

    public class ApiTotalUsageThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_API_TOTAL_USAGE => new Map<String, ThresholdConfig>{
                    'STATUS_CODE' => statusCode(this.eventType)
                }
            };
        }
    }

    public class AsyncReportRunThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('CPU_TIME')
                        .setWarningThreshold(30000)    // 30 seconds
                        .setCriticalThreshold(60000)   // 60 seconds
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'DB_TOTAL_TIME' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('DB_TOTAL_TIME')
                        .setWarningThreshold(20000)    // 20 seconds
                        .setCriticalThreshold(40000)   // 40 seconds
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'DB_CPU_TIME' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('DB_CPU_TIME')
                        .setWarningThreshold(15000)    // 15 seconds
                        .setCriticalThreshold(30000)   // 30 seconds
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'RUN_TIME' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('RUN_TIME')
                        .setWarningThreshold(60000)    // 1 minute
                        .setCriticalThreshold(300000)  // 5 minutes
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'ROW_COUNT' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('ROW_COUNT')
                        .setWarningThreshold(50000)    // 50K rows
                        .setCriticalThreshold(100000)  // 100K rows
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'AVERAGE_ROW_SIZE' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('AVERAGE_ROW_SIZE')
                        .setWarningThreshold(5000)     // 5KB per row
                        .setCriticalThreshold(10000)   // 10KB per row
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'DB_BLOCKS' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('DB_BLOCKS')
                        .setWarningThreshold(1000)     // 1K blocks
                        .setCriticalThreshold(5000)    // 5K blocks
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'NUMBER_COLUMNS' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('NUMBER_COLUMNS')
                        .setWarningThreshold(20)       // 20 columns
                        .setCriticalThreshold(30)      // 30 columns
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build(),
                        
                    'NUMBER_EXCEPTION_FILTERS' => new ThresholdConfig.Builder()
                        .setEventType(EventLogProcessors.EVENT_TYPE_ASYNCHRONOUS_REPORT_RUN)
                        .setMetric('NUMBER_EXCEPTION_FILTERS')
                        .setWarningThreshold(10)       // 10 filters
                        .setCriticalThreshold(20)      // 20 filters
                        .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
                        .build()
                }
            };
        }
    }

    public class AuraRequestThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_AURA_REQUEST;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>{
                EventLogProcessors.EVENT_TYPE_AURA_REQUEST => new Map<String, ThresholdConfig>{
                    'CPU_TIME' => cpuTime(this.eventType),
                    'DB_TOTAL_TIME' => dbTotalTimeNs(this.eventType),
                    'RUN_TIME' => runTime(this.eventType),
                    'REQUEST_STATUS' => requestStatus(this.eventType)
                }
            };
        }
    }

    public class BlockedRedirectThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_BLOCKED_REDIRECT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class BulkApiThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_BULK_API;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class BulkApiRequestThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_BULK_API_REQUEST;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class BulkApi2ThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_BULK_API_2;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ChangeSetOperationThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CHANGE_SET_OPERATION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ConcurrentLongRunningApexLimitThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONCURRENT_LONG_RUNNING_APEX_LIMIT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ConsoleEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONSOLE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ContentDistributionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONTENT_DISTRIBUTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ContentDocumentLinkThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONTENT_DOCUMENT_LINK;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ContentTransferThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONTENT_TRANSFER;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ContinuationCalloutSummaryThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CONTINUATION_CALLOUT_SUMMARY;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class CorsViolationThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CORS_VIOLATION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class CspViolationThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_CSP_VIOLATION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class DashboardThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_DASHBOARD;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class DatabaseSaveThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_DATABASE_SAVE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class DocumentAttachmentDownloadsThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_DOCUMENT_ATTACHMENT_DOWNLOADS;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ExternalCustomApexCalloutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_EXTERNAL_CUSTOM_APEX_CALLOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ExternalCrossOrgCalloutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_EXTERNAL_CROSS_ORG_CALLOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ExternalDataSourceCalloutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_EXTERNAL_DATA_SOURCE_CALLOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ExternalODataCalloutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_EXTERNAL_ODATA_CALLOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class FlowExecutionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_FLOW_EXECUTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class GroupMembershipThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_GROUP_MEMBERSHIP;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class HostnameRedirectsThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_HOSTNAME_REDIRECTS;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class InsecureExternalAssetsThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_INSECURE_EXTERNAL_ASSETS;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class InsufficientAccessThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_INSUFFICIENT_ACCESS;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class KnowledgeArticleViewThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_KNOWLEDGE_ARTICLE_VIEW;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LightningErrorThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LIGHTNING_ERROR;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LightningInteractionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LIGHTNING_INTERACTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LightningLoggerThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LIGHTNING_LOGGER;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LightningPageViewThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LIGHTNING_PAGE_VIEW;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LightningPerformanceThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LIGHTNING_PERFORMANCE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LoginThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LOGIN;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LoginAsThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LOGIN_AS;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class LogoutThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_LOGOUT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class MetadataApiOperationThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_METADATA_API_OPERATION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class MultiblockReportThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_MULTIBLOCK_REPORT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class NamedCredentialThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_NAMED_CREDENTIAL;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class OneCommerceUsageThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_ONE_COMMERCE_USAGE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class PackageInstallThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_PACKAGE_INSTALL;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class PermissionUpdateThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_PERMISSION_UPDATE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class PlatformEncryptionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_PLATFORM_ENCRYPTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class PricingEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_PRICING;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class QueuedExecutionThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_QUEUED_EXECUTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ReportEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_REPORT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class ReportExportEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_REPORT_EXPORT;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class RestApiThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_REST_API;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class SandboxThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_SANDBOX;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class SearchEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_SEARCH;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class SearchClickEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_SEARCH_CLICK;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class SitesEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_SITES;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class TimeBasedWorkflowThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_TIME_BASED_WORKFLOW;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class TransactionSecurityThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_TRANSACTION_SECURITY;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class UITelemetryNavigationTimingThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_NAVIGATION_TIMING;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class UITelemetryResourceTimingThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_UI_TELEMETRY_RESOURCE_TIMING;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class UriEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_URI;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class VisualforceRequestThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_VISUALFORCE_REQUEST;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class WaveChangeEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_WAVE_CHANGE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class WaveDownloadEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_WAVE_DOWNLOAD;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class WaveInteractionEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_WAVE_INTERACTION;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    public class WavePerformanceEventThresholdConfig extends ThresholdConfigSetup {
        public final String eventType = EventLogProcessors.EVENT_TYPE_WAVE_PERFORMANCE;
        public override Map<String, Map<String, ThresholdConfig>> getThresholds() {
            return new Map<String, Map<String, ThresholdConfig>>();
        }
    }

    // common threshold configs

    public static ThresholdConfig time(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('TIME')
            .setWarningThreshold(9000) // 9 seconds
            .setCriticalThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig cpuTime(String eventType) {
        return cpuTime(eventType, 500, 1500);
    }
    public static ThresholdConfig cpuTime(String eventType, Integer warningThreshold, Integer criticalThreshold) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('CPU_TIME')
            .setWarningThreshold(warningThreshold)
            .setCriticalThreshold(criticalThreshold)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig cpuTimeAsync(String eventType) {
        return cpuTime(eventType, 30000, 60000);
    }
    public static ThresholdConfig runTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('RUN_TIME')
            .setWarningThreshold(9000) // 9 seconds
            .setCriticalThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbCpuTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('DB_CPU_TIME')
            .setWarningThreshold(9000) // 9 seconds
            .setCriticalThreshold(10000) // 10 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbTotalTimeMs(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('DB_TOTAL_TIME')
            .setWarningThreshold(20000) // 20 seconds
            .setCriticalThreshold(50000) // 50 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbTotalTimeNs(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('DB_TOTAL_TIME')
            .setWarningThreshold(500000000) // 500ms in nanoseconds
            .setCriticalThreshold(2000000000) // 2s in nanoseconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig numberSoqlQueries(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('NUMBER_SOQL_QUERIES')
            .setWarningThreshold(30) // 30 queries
            .setCriticalThreshold(50) // 50 queries
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig requestSize(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('REQUEST_SIZE')
            .setWarningThreshold(1000000) // 1mb
            .setCriticalThreshold(10000000) // 10mb
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig responseSize(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('RESPONSE_SIZE')
            .setWarningThreshold(1000000) // 1mb
            .setCriticalThreshold(10000000) // 10mb
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig statusCode(String eventType, Integer warningThreshold, Integer criticalThreshold) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('STATUS_CODE')
            .setWarningThreshold(warningThreshold)
            .setCriticalThreshold(criticalThreshold)
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig statusCode(String eventType) {
        return statusCode(eventType, 400, 500);
    }
    public static ThresholdConfig success(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('SUCCESS')
            .setCriticalThreshold(false)
            .setEvalType(ThresholdConfig.EvaluationType.EQUALS)
            .build();
    }
    public static ThresholdConfig requestStatus(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('REQUEST_STATUS')
            .setCriticalThreshold(EventLogProcessors.RequestStatus.SUCCESS.name().left(1))
            .setEvalType(ThresholdConfig.EvaluationType.NOT_EQUALS)
            .build();
    }
    public static ThresholdConfig rowsProcessed(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('ROWS_PROCESSED')
            .setWarningThreshold(50000) // 50K records
            .setCriticalThreshold(100000) // 100K records
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig dbBlocks(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('DB_BLOCKS')
            .setWarningThreshold(1000) // 1K blocks
            .setCriticalThreshold(5000) // 5K blocks
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig queryCount(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('QUERY_COUNT')
            .setWarningThreshold(30) // 30 queries
            .setCriticalThreshold(50) // 50 queries
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig limitUsagePercent(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('LIMIT_USAGE_PERCENT')
            .setWarningThreshold(80) // 80%
            .setCriticalThreshold(90) // 90%
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig execTime(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('EXEC_TIME')
            .setWarningThreshold(10000) // 10 seconds
            .setCriticalThreshold(20000) // 20 seconds
            .setEvalType(ThresholdConfig.EvaluationType.GREATER_THAN)
            .build();
    }
    public static ThresholdConfig exceptionMessage(String eventType) {
        return new ThresholdConfig.Builder()
            .setEventType(eventType)
            .setMetric('EXCEPTION_MESSAGE')
            .setEvalType(ThresholdConfig.EvaluationType.NOT_NULL)
            .build();
    }
}