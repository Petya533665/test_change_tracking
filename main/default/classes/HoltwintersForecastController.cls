public with sharing class HoltwintersForecastController {

    // Static variables for forecast configuration
    private static final Integer DEFAULT_FORECAST_DAYS = 7;
    private static final Integer DEFAULT_LOOKBACK_DAYS = 90;

    public static String getForecastSetting() {
        Map<String, Object> forecastSetting = new Map<String, Object> {
            'isEnabledForecast' => ConfigUtil.PHAROS_SETTINGS.EnableForecast__c
        };

        return JSON.serialize(forecastSetting);
    }

    public static String updateForecastSetting(String forecastSettingJSON) {
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

        return JSON.serialize(forecastSetting);
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
            HoltwintersForecastLambdaClient.SeasonalityType seasonalityType = HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY;

            List<HoltwintersForecastLambdaClient.LogEntry> logsData = (List<HoltwintersForecastLambdaClient.LogEntry>) JSON.deserialize(
                params.logsData, List<HoltwintersForecastLambdaClient.LogEntry>.class
            );
            
            HoltwintersForecastLambdaClient.LambdaResponse response = HoltwintersForecastLambdaService.generateUserActivityForecast(
                logsData,
                seasonalityType,
                DEFAULT_FORECAST_DAYS,
                DEFAULT_LOOKBACK_DAYS
            );

            // Create AutoTrace requests based on forecast response
            Integer traceRequestsCreated = 0;
            String resultMessage = 'No forecast data available';
            Boolean success = false;
            
            if (response != null && response.forecast != null && !response.forecast.isEmpty()) {
                List<TraceScheduleController.TraceRequest> traceRequestsToCreate = new List<TraceScheduleController.TraceRequest>();
                
                // Iterate through each date in the forecast
                for (String dateKey : response.forecast.keySet()) {
                    List<HoltwintersForecastLambdaClient.ActivityTimeRange> timeRanges = response.forecast.get(dateKey);
                    
                    if (timeRanges != null) {
                        // Create trace requests for each predicted activity time range
                        for (HoltwintersForecastLambdaClient.ActivityTimeRange timeRange : timeRanges) {
                            TraceScheduleController.TraceRequest traceRequest = createTraceRequest(timeRange, params.traceScheduleId);
                            
                            // Add to list if creation was successful
                            if (traceRequest != null) {
                                traceRequestsToCreate.add(traceRequest);
                            }
                        }
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