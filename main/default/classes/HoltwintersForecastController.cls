/**
 * HoltwintersForecastController - Controller for Holt-Winters forecasting operations and configuration
 * 
 * This controller provides the main interface for Holt-Winters forecasting functionality,
 * handling configuration management, forecast generation, and integration with external
 * services. It serves as the primary entry point for forecasting operations from
 * Lightning Web Components and other Salesforce interfaces.
 * 
 * Key Features:
 * - Forecast configuration management (enable/disable settings)
 * - User activity forecast generation with automatic parameter optimization
 * - Large dataset processing with intelligent batching
 * - Remote site settings management for external API access
 * - Comprehensive error handling and validation
 * - Integration with HoltwintersForecastLambdaService for business logic
 * 
 * Configuration Management:
 * The controller manages forecast settings through custom settings and automatically
 * configures remote site settings when forecasting is enabled. It handles the
 * enablement/disabling of external API access based on feature flags.
 * 
 * Usage Examples:
 * 
 * // Get current forecast configuration
 * Map<String, Object> settings = HoltwintersForecastController.getForecastSetting();
 * Boolean isEnabled = (Boolean) settings.get('isEnabledForecast');
 * 
 * // Update forecast configuration
 * String configJson = '{"isEnabledForecast": true}';
 * Map<String, Object> result = HoltwintersForecastController.updateForecastSetting(configJson);
 * 
 * // Generate user activity forecast
 * Map<String, Object> forecastResult = HoltwintersForecastController.generateUserActivityForecast(
 *     'a0CQy00000ogy31MAA', 7, 90);
 * 
 * // Process large datasets with automatic batching
 * List<Map<String, Datetime>> dateRanges = HoltwintersForecastController.getLogsCountByDayLargeDataset(
 *     'a0CQy00000ogy31MAA', '2024-01-01', '2024-01-31');
 * 
 * // Create automatic trace requests based on forecast data
 * Map<String, Object> traceResult = HoltwintersForecastController.createAutoTraceRequests(
 *     'a0CQy00000ogy31MAA', 7);
 * 
 * Performance Considerations:
 * - Default forecast period: 7 days
 * - Default lookback period: 90 days
 * - Automatic batching for datasets exceeding governor limits
 * - Remote site settings automatically managed
 * - Comprehensive error handling for external API calls
 * 
 * @author Salesforce Development Team
 * @since API Version 62.0
 * @version 1.1
 * @see HoltwintersForecastLambdaService - Core forecasting business logic
 * @see ConfigUtil - Configuration utility for custom settings
 * @see AdminService - Administrative service for remote site management
 * @see Constants - Application constants and configuration values
 */
public with sharing class HoltwintersForecastController {

    // Static variables for forecast configuration
    private static final Integer DEFAULT_FORECAST_DAYS = 7;
    private static final Integer DEFAULT_LOOKBACK_DAYS = 90;

    public static Map<String, Object> getForecastSetting() {
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => ConfigUtil.PHAROS_SETTINGS.EnableForecast__c
        };

        return forecastSetting;
    }

    public static Map<String, Object> updateForecastSetting(String forecastSettingJSON) {
        Map<String, Object> forecastSetting = (Map<String, Object>) JSON.deserializeUntyped(forecastSettingJSON);
        ConfigUtil.PHAROS_SETTINGS.EnableForecast__c = (Boolean) forecastSetting.get('isEnabledForecast');

        Boolean isEnabledRemoteSiteSetting = ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c
            || ConfigUtil.PHAROS_SETTINGS.EnableForecast__c;

        if (isEnabledRemoteSiteSetting) {
            AdminService.upsertRemoteSiteSetting(
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME,
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_API_URL,
                Constants.REMOTE_SITE_SETTINGS.PHAROS_API_DESCRIPTION
            );
        } else {
            MetadataServiceUtil.deleteRemoteSiteSettingsMetadata(
                new List<String>{
                    ConfigUtil.prefixCurrentOrgNamespace(Constants.REMOTE_SITE_SETTINGS.PHAROS_API_NAME
                    )}
            );
        }

        upsert ConfigUtil.PHAROS_SETTINGS;

        forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => ConfigUtil.PHAROS_SETTINGS.EnableForecast__c,
            'isUpdate' => true
        };

        return forecastSetting;
    }

    public static Map<String, Object> getIsEnabledHoltwinters() {
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledHoltwinters' => HoltwintersForecastLambdaService.isEnabled
        };

        return forecastSetting;
    }

    public static Map<String, Object> getLogsCountByDayLargeDataset(String parametersJSON) {

        try {
            HoltwintersForecastParameters params = (HoltwintersForecastParameters) JSON.deserialize(parametersJSON, HoltwintersForecastParameters.class);
            params.setDefaultDates();
            List<Map<String, Datetime>> logsCountByDayLargeDataset = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(
                params.issueId,
                params.startDatetime,
                params.endDatetime
            );

            Map<String, Object> result = new Map<String, Object> {
                'logsCountByDayLargeDataset' => logsCountByDayLargeDataset
            };
            return result;
        } catch (JSONException e) {
            // If any parsing fails, return empty result
            Map<String, Object> result = new Map<String, Object> {
                'logsCountByDayLargeDataset' => new List<Map<String, Datetime>>(),
                'error' => e.getMessage()
            };
            return result;
        }
    }

    public static Map<String, Object> getUserIdToDateTime(String parametersJSON) {

        try {
            HoltwintersForecastParameters params = (HoltwintersForecastParameters) JSON.deserialize(parametersJSON, HoltwintersForecastParameters.class);
            params.setDefaultDates();
            // Validate parameters
            if (!params.isValid()) {
                String errorMessage = params.getValidationErrorMessage();
                return new Map<String, Object> {
                    'userIdToDateTimeData' => new List<HoltwintersForecastLambdaClient.LogEntry>(),
                    'error' => errorMessage
                };
            }

            List<HoltwintersForecastLambdaClient.LogEntry> userIdToDateTimeData = HoltwintersForecastLambdaService.getUserIdToDateTime(
                params.issueId,
                params.startDatetime,
                params.endDatetime
            );

            Map<String, Object> result = new Map<String, Object> {
                'userIdToDateTimeData' => userIdToDateTimeData
            };

            return result;
        } catch (JSONException e) {
            // If any parsing fails, return empty result
            Map<String, Object> result = new Map<String, Object> {
                'userIdToDateTimeData' => new List<HoltwintersForecastLambdaClient.LogEntry>(),
                'error' => e.getMessage()
            };
            return result;
        }
    }

    public static Map<String, Object> createAutoTraceRequests(String parametersJSON) {
        try {
            HoltwintersForecastParameters params = (HoltwintersForecastParameters) JSON.deserialize(parametersJSON, HoltwintersForecastParameters.class);
            params.setDefaultDates();
            // Validate required parameters for this method
            if (String.isBlank(params.issueId) || String.isBlank(params.logsData) || String.isBlank(params.traceScheduleId)) {
                return new Map<String, Object> {
                    'success' => false,
                    'traceRequestsCreated' => 0,
                    'message' => 'Missing required parameters: issueId, logsData, or traceScheduleId'
                };
            }

            List<Trace_Request__c> traceRequestsToDelete = [
                SELECT Id 
                FROM Trace_Request__c 
                WHERE Issue__c = :params.issueId
                    AND Type__c = 'AutoTrace'
            ];

            HoltwintersForecastLambdaClient.LambdaResponse response = HoltwintersForecastLambdaService.forecastUserActivityFromCompressedLogs(
                params.logsData,
                HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY,
                DEFAULT_FORECAST_DAYS,
                DEFAULT_LOOKBACK_DAYS
            );
            // Create AutoTrace requests based on forecast response
            Integer traceRequestsCreated = 0;
            String resultMessage = 'No forecast data available';
            Boolean success = false;
            
            if (response != null && response.forecast != null && !response.forecast.isEmpty()) {
                List<TraceScheduleController.TraceRequest> traceRequestsToCreate = new List<TraceScheduleController.TraceRequest>();
                
                // Collect all time ranges from all dates into a single list
                List<HoltwintersForecastLambdaClient.ActivityTimeRange> allTimeRanges = new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
                for (String dateKey : response.forecast.keySet()) {
                    List<HoltwintersForecastLambdaClient.ActivityTimeRange> timeRanges = response.forecast.get(dateKey);
                    if (timeRanges != null && !timeRanges.isEmpty()) {
                        allTimeRanges.addAll(timeRanges);
                    }
                }
                
                // Merge all overlapping time ranges (regardless of date)
                List<HoltwintersForecastLambdaClient.ActivityTimeRange> mergedTimeRanges = mergeOverlappingTimeRanges(allTimeRanges);

                // Create trace requests for each merged time range
                for (HoltwintersForecastLambdaClient.ActivityTimeRange timeRange : mergedTimeRanges) {
                    TraceScheduleController.TraceRequest traceRequest = createTraceRequest(timeRange, params.traceScheduleId);
                    
                    // Add to list if creation was successful
                    if (traceRequest != null) {
                        traceRequestsToCreate.add(traceRequest);
                    }
                }
                // Save trace requests to database
                if (!traceRequestsToCreate.isEmpty()) {
                    Map<String, Object> saveResult = saveTraceRequestsToDatabase(traceRequestsToCreate, traceRequestsToDelete);
                    success = (Boolean) saveResult.get('success');
                    traceRequestsCreated = (Integer) saveResult.get('traceRequestsCreated');
                    resultMessage = (String) saveResult.get('message');
                } else {
                    resultMessage = 'No valid time ranges found in forecast data for trace request creation';
                }
            }

            Map<String, Object> result = new Map<String, Object> {
                'holtwintersForecast' => response,
                'success' => success,
                'traceRequestsCreated' => traceRequestsCreated,
                'message' => resultMessage
            };

            return result;
        } catch (JSONException e) {
            // If any parsing fails, return error result
            return new Map<String, Object> {
                'holtwintersForecast' => null,
                'success' => false,
                'traceRequestsCreated' => 0,
                'message' => 'Error: ' + e.getMessage()
            };
        }
    }

    /**
     * Merge overlapping time ranges (regardless of date)
     * Two ranges overlap if: start1 < end2 AND start2 < end1
     * Overlapping ranges are merged into a single range with the earliest start and latest end
     */
    private static List<HoltwintersForecastLambdaClient.ActivityTimeRange> mergeOverlappingTimeRanges(
        List<HoltwintersForecastLambdaClient.ActivityTimeRange> timeRanges
    ) {
        if (timeRanges == null || timeRanges.isEmpty()) {
            return new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
        }

        // Create a list with parsed datetimes for sorting
        List<TimeRangeWrapper> wrappers = new List<TimeRangeWrapper>();
        for (HoltwintersForecastLambdaClient.ActivityTimeRange timeRange : timeRanges) {
            Datetime startDt = parseDateTime(timeRange.startDateTime);
            Datetime endDt = parseDateTime(timeRange.endDateTime);
            
            // Skip ranges with invalid dates
            if (startDt != null && endDt != null && startDt <= endDt) {
                wrappers.add(new TimeRangeWrapper(timeRange, startDt, endDt));
            }
        }

        if (wrappers.isEmpty()) {
            return new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
        }

        // Sort by startDateTime (bubble sort for simplicity)
        for (Integer i = 0; i < wrappers.size() - 1; i++) {
            for (Integer j = 0; j < wrappers.size() - i - 1; j++) {
                if (wrappers[j].startDateTime > wrappers[j + 1].startDateTime) {
                    TimeRangeWrapper temp = wrappers[j];
                    wrappers[j] = wrappers[j + 1];
                    wrappers[j + 1] = temp;
                }
            }
        }

        // Merge overlapping ranges
        List<HoltwintersForecastLambdaClient.ActivityTimeRange> merged = new List<HoltwintersForecastLambdaClient.ActivityTimeRange>();
        TimeRangeWrapper current = wrappers[0];

        for (Integer i = 1; i < wrappers.size(); i++) {
            TimeRangeWrapper next = wrappers[i];
            
            // Check if ranges overlap: current.end >= next.start
            if (current.endDateTime >= next.startDateTime) {
                // Merge: extend current range to include next
                if (next.endDateTime > current.endDateTime) {
                    current.endDateTime = next.endDateTime;
                    // Update the original timeRange object with merged endDateTime from next range
                    current.timeRange.endDateTime = next.timeRange.endDateTime;
                    // Update time_range field to reflect merged range (format: "HH:mm-HH:mm")
                    current.timeRange.time_range = formatTimeRange(current.startDateTime, next.endDateTime);
                }
            } else {
                // No overlap, add current to merged list and move to next
                merged.add(current.timeRange);
                current = next;
            }
        }

        // Add the last range
        merged.add(current.timeRange);

        return merged;
    }

    /**
     * Wrapper class to hold time range with parsed datetimes for sorting
     */
    private class TimeRangeWrapper {
        HoltwintersForecastLambdaClient.ActivityTimeRange timeRange;
        Datetime startDateTime;
        Datetime endDateTime;

        TimeRangeWrapper(HoltwintersForecastLambdaClient.ActivityTimeRange timeRange, Datetime startDateTime, Datetime endDateTime) {
            this.timeRange = timeRange;
            this.startDateTime = startDateTime;
            this.endDateTime = endDateTime;
        }
    }


    /**
     * Format time range string from start and end datetimes (format: "HH:mm-HH:mm")
     */
    private static String formatTimeRange(Datetime startDt, Datetime endDt) {
        if (startDt == null || endDt == null) {
            return null;
        }
        // Format: "HH:mm-HH:mm" (e.g., "19:00-22:00")
        // Extract time from datetime strings using formatGmt
        String startTime = startDt.formatGmt('HH:mm');
        String endTime = endDt.formatGmt('HH:mm');
        return startTime + '-' + endTime;
    }

    /**
     * Parse datetime string and return Datetime object
     */
    private static Datetime parseDateTime(String dateTimeString) {
        if (String.isBlank(dateTimeString)) {
            return null;
        }
        return (Datetime) JSON.deserialize('"' + dateTimeString + '"', Datetime.class);
    }

    /**
     * Adjust dates if they are in the past
     */
    private static void adjustPastDates(TraceScheduleController.TraceRequest traceRequest) {
        if (traceRequest.startDate != null && traceRequest.endDate != null) {
            Datetime currentTime = Datetime.now();
            if (traceRequest.endDate < currentTime) {
                traceRequest.startDate = traceRequest.startDate.addDays(1);
                traceRequest.endDate = traceRequest.endDate.addDays(1);
            } else if (currentTime < traceRequest.endDate && currentTime > traceRequest.startDate) {
                traceRequest.startDate = currentTime;
                traceRequest.endDate = traceRequest.endDate.addHours(1);
            }
        }
    }

    /**
     * Create trace request from time range data
     */
    private static TraceScheduleController.TraceRequest createTraceRequest(
        HoltwintersForecastLambdaClient.ActivityTimeRange timeRange, 
        String traceScheduleId
    ) {
        TraceScheduleController.TraceRequest traceRequest = new TraceScheduleController.TraceRequest();
        
        // Set AutoTrace type
        traceRequest.type = 'AutoTrace';
        traceRequest.status = 'New';
        traceRequest.traceSchedule = traceScheduleId;
        
        // Parse dates
        traceRequest.startDate = parseDateTime(timeRange.startDateTime);
        traceRequest.endDate = parseDateTime(timeRange.endDateTime);
        
        // Skip if date parsing failed
        if (traceRequest.startDate == null || traceRequest.endDate == null) {
            return null;
        }
        
        // Adjust dates if they are in the past
        adjustPastDates(traceRequest);
        
        // Set traced entity (user) ID if available
        if (String.isNotBlank(timeRange.userId)) {
            traceRequest.tracedEntityId = timeRange.userId;
        }
        
        return traceRequest;
    }

    /**
     * Save trace requests to database
     */
    private static Map<String, Object> saveTraceRequestsToDatabase(
        List<TraceScheduleController.TraceRequest> traceRequestsToCreate,
        List<Trace_Request__c> traceRequestsToDelete
    ) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Delete existing AutoTrace requests
            DatabaseUtils.getInstance().performDeleteDML(traceRequestsToDelete, Schema.SObjectType.Trace_Request__c)
                .handleError(TraceScheduleController.class.getName(), '.deleteAutoTraceRequests');

            // Create new trace requests
            Map<String, Object> createResult = TraceScheduleController.createTraceRequests(traceRequestsToCreate);
            
            // Check if creation was successful
            if (createResult != null && createResult.containsKey('result')) {
                List<Database.SaveResult> saveResults = (List<Database.SaveResult>) createResult.get('result');
                Integer successCount = 0;
                List<String> errors = new List<String>();
                
                for (Database.SaveResult saveResult : saveResults) {
                    if (saveResult.isSuccess()) {
                        successCount++;
                    } else {
                        for (Database.Error error : saveResult.getErrors()) {
                            errors.add(error.getMessage());
                        }
                    }
                }
                
                if (successCount == traceRequestsToCreate.size()) {
                    result.put('success', true);
                    result.put('traceRequestsCreated', successCount);
                    result.put('message', 'Successfully created ' + successCount + ' AutoTrace requests');
                } else {
                    result.put('success', false);
                    result.put('traceRequestsCreated', successCount);
                    result.put('message', 'Partially created trace requests. Created: ' + successCount + '/' + traceRequestsToCreate.size() + '. Errors: ' + String.join(errors, '; '));
                }
            } else {
                result.put('success', false);
                result.put('traceRequestsCreated', 0);
                result.put('message', 'Failed to create trace requests: Invalid response from createTraceRequests');
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('traceRequestsCreated', 0);
            result.put('message', 'Error creating trace requests: ' + e.getMessage());
        }
        return result;
    }

}