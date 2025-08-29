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
        String issueId;
        Datetime startDatetime;
        Datetime endDatetime;
        
        try {
            // Try to parse as JSON object first
            Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(parametersJSON);
            issueId = (String) parameters.get('issueId');
            
            // Handle date parameters
            if (parameters.containsKey('startDate') && parameters.containsKey('endDate')) {
                String startDateStr = (String) parameters.get('startDate');
                String endDateStr = (String) parameters.get('endDate');
                
                // Parse ISO format dates using valueOfGmt
                startDatetime = (Datetime) JSON.deserialize(startDateStr, Datetime.class);
                endDatetime = (Datetime) JSON.deserialize(endDateStr, Datetime.class);
            } else {
                // Default to last 90 days
                Datetime currentDatetime = System.now();
                startDatetime = currentDatetime.addDays(-DEFAULT_LOOKBACK_DAYS);
                endDatetime = currentDatetime;
            }
        } catch (JSONException e) {
            // If JSON parsing fails, treat as simple issue ID string
            issueId = parametersJSON.replace('"', ''); // Remove quotes if present
            Datetime currentDatetime = System.now();
            startDatetime = currentDatetime.addDays(-90);
            endDatetime = currentDatetime;
        }

        List<Map<String, Datetime>> logsCountByDayLargeDataset = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(
            issueId,
            startDatetime,
            endDatetime
        );

        Map<String, Object> result = new Map<String, Object> {
            'logsCountByDayLargeDataset' => logsCountByDayLargeDataset
        };
        return result;
    }

    public static Map<String, Object> getUserIdToDateTime(String parametersJSON) {
        try {
            Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(parametersJSON);
            String issueId = (String) parameters.get('issueId');
            String startDatetimeStr = (String) parameters.get('startDatetime');
            String endDatetimeStr = (String) parameters.get('endDatetime');
            
            Datetime startDatetime;
            Datetime endDatetime;
            
            // Parse ISO format dates using valueOfGmt
            startDatetime = (Datetime) JSON.deserialize(startDatetimeStr, Datetime.class);
            endDatetime = (Datetime) JSON.deserialize(endDatetimeStr, Datetime.class);

            List<HoltwintersForecastLambdaClient.LogEntry> userIdToDateTimeData = HoltwintersForecastLambdaService.getUserIdToDateTime(
                issueId,
                startDatetime,
                endDatetime
            );

            Map<String, Object> result = new Map<String, Object> {
                'userIdToDateTimeData' => userIdToDateTimeData
            };
            return result;
        } catch (JSONException e) {
            // If JSON parsing fails, return empty result
            Map<String, Object> result = new Map<String, Object> {
                'userIdToDateTimeData' => new List<HoltwintersForecastLambdaClient.LogEntry>()
            };
            return result;
        }
    }

    public static Map<String, Object> createAutoTraceRequests(String parametersJSON) {
         // Extract the forecast logic from createAutoTraceRequests method
         
         Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(parametersJSON);
         String logsDataObject = (String) parameters.get('logsData');
         String traceScheduleId = (String) parameters.get('traceScheduleId');
         String issueId = (String) parameters.get('issueId');

        List<Trace_Request__c> traceRequestsToDelete = [
            SELECT Id 
            FROM Trace_Request__c 
            WHERE Issue__c = :issueId
                AND Type__c = 'AutoTrace'
        ];
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType = HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY;


        List<HoltwintersForecastLambdaClient.LogEntry> logsData = (List<HoltwintersForecastLambdaClient.LogEntry>) JSON.deserialize(
            logsDataObject, List<HoltwintersForecastLambdaClient.LogEntry>.class
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
                        TraceScheduleController.TraceRequest traceRequest = createTraceRequest(timeRange, traceScheduleId);
                        
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
    }

    /**
     * Parse datetime string and return Datetime object
     */
    private static Datetime parseDateTime(String dateTimeString) {
        if (String.isBlank(dateTimeString)) {
            return null;
        }
        
        try {
            return (Datetime) JSON.deserialize('"' + dateTimeString + '"', Datetime.class);
        } catch (JSONException e) {
            return null;
        }
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
            
            result.put('success', true);
            result.put('traceRequestsCreated', traceRequestsToCreate.size());
            result.put('message', 'Successfully created ' + traceRequestsToCreate.size() + ' AutoTrace requests');
        } catch (Exception e) {
            result.put('success', false);
            result.put('traceRequestsCreated', 0);
            result.put('message', 'Error creating trace requests: ' + e.getMessage());
        }
        
        return result;
    }

}