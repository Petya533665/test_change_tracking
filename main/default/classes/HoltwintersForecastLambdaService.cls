/**
 * HoltwintersForecastLambdaService - Service class for Holt-Winters user activity forecasting operations
 * 
 * This service provides high-level business logic for:
 * - User activity data preparation and validation
 * - Activity forecast generation with different seasonality types
 * - Result processing and formatting
 * - Error handling and logging
 * - Integration with other services (LogService, ReportService, etc.)
 * - Data quality assessment and parameter recommendations
 * 
 * Usage Examples:
 * 
 * // Generate forecast with specific parameters
 * HoltwintersForecastLambdaService service = new HoltwintersForecastLambdaService();
 * HoltwintersForecastLambdaClient.LambdaResponse response = 
 *     service.generateUserActivityForecast('a0CQy00000ogy31MAA', 
 *         HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY, 7, 90);
 * 
 * // Generate forecast with auto seasonality detection
 * HoltwintersForecastLambdaClient.LambdaResponse response = 
 *     service.generateUserActivityForecast('a0CQy00000ogy31MAA', 7, 90);
 * 
 * // Generate forecast with default 30-day lookback
 * HoltwintersForecastLambdaClient.LambdaResponse response = 
 *     service.generateUserActivityForecast('a0CQy00000ogy31MAA', 7);
 * 
 * // Get forecast statistics
 * Map<String, Object> stats = service.getForecastStatistics('a0CQy00000ogy31MAA', 7);
 * 
 * // Validate data sufficiency
 * Boolean hasData = service.hasSufficientData('a0CQy00000ogy31MAA', 72);
 * 
 * // Get recommended parameters
 * Map<String, Object> recommendations = service.getRecommendedParameters('a0CQy00000ogy31MAA');
 * 
 * @since API Version 62.0
 * @see HoltwintersForecastLambdaClient - Low-level Lambda client
 */
public with sharing class HoltwintersForecastLambdaService {
    
    public static Boolean isEnabled {
        get {
            return PermissionsUtil.ForecastEnabled && ConfigUtil.PHAROS_SETTINGS.EnableForecast__c;
        }
        private set {}
    }


    public HoltwintersForecastLambdaService() {
        // Default constructor
    }

    /**
     * Generate user activity forecast with specific seasonality type, forecast days, and lookback days
     * @param issueId Issue ID to filter logs
     * @param seasonalityType Seasonality type enum (DAILY, WEEKLY, MONTHLY, AUTO)
     * @param forecastDays Number of days to forecast (1-30)
     * @param lookbackDays Number of days back to analyze for forecasting (1-365)
     * @return LambdaResponse object containing forecast data
     */
    public static HoltwintersForecastLambdaClient.LambdaResponse generateUserActivityForecast(
        String issueId,
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType,
        Integer forecastDays,
        Integer lookbackDays
    ) {
        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        
        // Calculate date range for the analysis period using lookbackDays
        Datetime startDate = System.now().addDays(-lookbackDays);
        Datetime endDate =  System.now();
        List<Log__c> logs = getLogsForIssue(issueId, startDate, endDate);
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = convertLogsToEntries(logs);
        
        client.generateUserActivityForecast(logsData, seasonalityType, forecastDays, lookbackDays);

        return client.getLambdaResponse();
    }


    public static HoltwintersForecastLambdaClient.LambdaResponse generateUserActivityForecast(
        List<HoltwintersForecastLambdaClient.LogEntry> logsData,
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType,
        Integer forecastDays,
        Integer lookbackDays
    ) {

        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
        
        // Calculate date range for the analysis period using lookbackDays
        Datetime startDate = System.now().addDays(-lookbackDays);
        Datetime endDate =  System.now();
 
        client.generateUserActivityForecast(logsData, seasonalityType, forecastDays, lookbackDays);

        return client.getLambdaResponse();
    }

    public static List<HoltwintersForecastLambdaClient.LogEntry> getUserIdToDateTime(String issueId, Datetime startDateTime, Datetime endDateTime) {
        List<Log__c> logs = getLogsForIssue(issueId, startDateTime, endDateTime);
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = convertLogsToEntries(logs);
        
        return logsData;
    }

    /**
     * Generate user activity forecast with auto seasonality detection
     * @param issueId Issue ID to filter logs
     * @param forecastDays Number of days to forecast (1-30)
     * @param lookbackDays Number of days back to analyze for forecasting (1-365)
     * @return LambdaResponse object containing forecast data
     */
    public static HoltwintersForecastLambdaClient.LambdaResponse generateUserActivityForecast(
        String issueId,
        Integer forecastDays,
        Integer lookbackDays
    ) {
        return generateUserActivityForecast(
            issueId, 
            HoltwintersForecastLambdaClient.SeasonalityType.AUTO, 
            forecastDays, 
            lookbackDays
        );
    }

    /**
     * Generate user activity forecast with default 30-day lookback
     * @param issueId Issue ID to filter logs
     * @param forecastDays Number of days to forecast (1-30)
     * @return LambdaResponse object containing forecast data
     */
    public static HoltwintersForecastLambdaClient.LambdaResponse generateUserActivityForecast(
        String issueId,
        Integer forecastDays
    ) {
        return generateUserActivityForecast(
            issueId, 
            HoltwintersForecastLambdaClient.SeasonalityType.AUTO, 
            forecastDays, 
            30 // Default lookback days
        );
    }

    /**
     * Get date ranges for large datasets that will result in batches under 49,000 records
     * @param issueId Issue ID to filter logs
     * @param startDate Start date for the range
     * @param endDate End date for the range
     * @return List<Map<String, Datetime>> where each map contains 'startDate' and 'endDate' keys
     */
    public static List<Map<String, Datetime>> getLogsCountByDayLargeDataset(String issueId, Datetime startDate, Datetime endDate) {
        Integer batchSize = 49000;
        Integer batchCount = 0;
        Integer previousBatchCount = 0;
        Datetime batchStartDate = startDate;
        Datetime currentDate;
        Map<String, Integer> logsByDay = getLogsCountByDay(issueId, startDate, endDate);
        List<Map<String, Datetime>> dateRanges = new List<Map<String, Datetime>>();
        
        for (String dateKey : logsByDay.keySet()) {
            // Parse date from "yyyy-MM-dd" format
            currentDate = Datetime.valueOf(dateKey + ' 00:00:00');
            Integer count = logsByDay.get(dateKey);
            
            previousBatchCount = batchCount;
            batchCount += count;
            
            if (batchCount >= batchSize) {
                // Add the batch range to the list (before exceeding limit)
                Map<String, Datetime> dateRange = new Map<String, Datetime>{
                    'startDate' => batchStartDate,
                    'endDate' => currentDate
                };
                dateRanges.add(dateRange);
                
                // Reset batch count to previous value (before exceeding limit)
                batchCount = previousBatchCount;
                
                // Set new batch start date
                batchStartDate = currentDate.addDays(-1);
            }
        }
        
        // Add final batch if there are remaining records
        if (batchCount > 0) {
            Map<String, Datetime> finalRange = new Map<String, Datetime>{
                'startDate' => batchStartDate,
                'endDate' => endDate
            };
            dateRanges.add(finalRange);
        }

        return dateRanges;
    }

    /**
     * Get forecast statistics for a specific issue
     * @param issueId Issue ID to get forecast statistics for
     * @param forecastDays Number of days to forecast (default: 7)
     * @return Map containing forecast statistics
     */
    public static Map<String, Object> getForecastStatistics(String issueId, Integer forecastDays) {
        if (forecastDays == null) {
            forecastDays = 7; // Default to 7 days
        }
        
        try {
            HoltwintersForecastLambdaClient.LambdaResponse response = 
                generateUserActivityForecast(issueId, forecastDays);
            
            if (response != null && response.forecast != null) {
                Map<String, Object> stats = new Map<String, Object>();
                stats.put('totalForecastDays', response.forecast.size());
                stats.put('totalTimeRanges', 0);
                stats.put('highConfidenceRanges', 0);
                stats.put('mediumConfidenceRanges', 0);
                stats.put('lowConfidenceRanges', 0);
                
                for (String dateKey : response.forecast.keySet()) {
                    List<HoltwintersForecastLambdaClient.ActivityTimeRange> timeRanges = 
                        response.forecast.get(dateKey);
                    stats.put('totalTimeRanges', (Integer)stats.get('totalTimeRanges') + timeRanges.size());
                    
                    for (HoltwintersForecastLambdaClient.ActivityTimeRange timeRange : timeRanges) {
                        if (timeRange.confidence == 'high') {
                            stats.put('highConfidenceRanges', (Integer)stats.get('highConfidenceRanges') + 1);
                        } else if (timeRange.confidence == 'medium') {
                            stats.put('mediumConfidenceRanges', (Integer)stats.get('mediumConfidenceRanges') + 1);
                        } else {
                            stats.put('lowConfidenceRanges', (Integer)stats.get('lowConfidenceRanges') + 1);
                        }
                    }
                }
                
                if (response.seasonality != null) {
                    stats.put('seasonalityType', response.seasonality.type);
                    stats.put('seasonalityDescription', response.seasonality.description);
                }
                
                return stats;
            }
        } catch (Exception e) {
            System.debug('Error getting forecast statistics: ' + e.getMessage());
        }
        
        return new Map<String, Object>();
    }

    /**
     * Validate if an issue has sufficient data for forecasting
     * @param issueId Issue ID to validate
     * @param minimumLogs Minimum number of logs required (default: 72)
     * @return Boolean indicating if sufficient data exists
     */
    public static Boolean hasSufficientData(String issueId, Integer minimumLogs) {
        if (minimumLogs == null) {
            minimumLogs = 72; // Default minimum for daily seasonality
        }
        
        try {
            // Check logs for the last 30 days
            Datetime startDate = System.now().addDays(-30);
            Datetime endDate = System.now();
            
            List<Log__c> logs = getLogsForIssue(issueId, startDate, endDate);
            return logs.size() >= minimumLogs;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get recommended forecast parameters based on available data
     * @param issueId Issue ID to analyze
     * @return Map containing recommended parameters
     */
    public static Map<String, Object> getRecommendedParameters(String issueId) {
        Map<String, Object> recommendations = new Map<String, Object>();
        
        try {
            // Check data availability
            Boolean hasMinData = hasSufficientData(issueId, 72);
            Boolean hasOptimalData = hasSufficientData(issueId, 240);
            Boolean hasGoodData = hasSufficientData(issueId, 480);
            
            // Determine recommended seasonality
            String recommendedSeasonality = 'AUTO';
            if (hasGoodData) {
                recommendedSeasonality = 'WEEKLY';
            } else if (hasOptimalData) {
                recommendedSeasonality = 'DAILY';
            } else if (hasMinData) {
                recommendedSeasonality = 'DAILY';
            }
            
            // Determine recommended forecast days
            Integer recommendedForecastDays = 7;
            if (!hasMinData) {
                recommendedForecastDays = 1;
            } else if (!hasOptimalData) {
                recommendedForecastDays = 3;
            }
            
            recommendations.put('recommendedSeasonality', recommendedSeasonality);
            recommendations.put('recommendedForecastDays', recommendedForecastDays);
            recommendations.put('dataQuality', hasGoodData ? 'GOOD' : (hasOptimalData ? 'OPTIMUM' : (hasMinData ? 'MINIMUM' : 'INSUFFICIENT')));
            recommendations.put('hasMinimumData', hasMinData);
            recommendations.put('hasOptimalData', hasOptimalData);
            recommendations.put('hasGoodData', hasGoodData);
            
        } catch (Exception e) {
            recommendations.put('error', e.getMessage());
        }
        
        return recommendations;
    }
    /**
     * Get logs for a specific issue within the date range
     * @param issueId Issue ID to filter logs
     * @param startDate Start date for the range
     * @param endDate End date for the range
     * @return List of Log__c records
     */
    private static List<Log__c> getLogsForIssue(String issueId, Datetime startDate, Datetime endDate) {
        return [
            SELECT
                Id,
                User_Id__c,
                Created_At__c
            FROM Log__c
            WHERE Issue__c = :issueId
            AND Created_At__c >= :startDate
            AND Created_At__c <= :endDate
            ORDER BY Created_At__c ASC
            LIMIT 49999
        ];
    }
    /**
     * Convert Log__c records to LogEntry objects
     * @param logs List of Log__c records
     * @return List of LogEntry objects
     */
    private static List<HoltwintersForecastLambdaClient.LogEntry> convertLogsToEntries(List<Log__c> logs) {
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = new List<HoltwintersForecastLambdaClient.LogEntry>();

        for (Log__c log : logs) {
            if (log.User_Id__c != null && log.Created_At__c != null) {
                String timestamp = log.Created_At__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                logsData.add(new HoltwintersForecastLambdaClient.LogEntry(log.User_Id__c, timestamp));
            }
        }

        return logsData;
    }

    /**
     * Get count of logs by day for a specific issue within date range
     * @param issueId Issue ID to filter logs
     * @param startDate Start date for the range
     * @param endDate End date for the range
     * @return Map<String, Integer> with date as key (YYYY-MM-DD format) and count as value
     */
    @TestVisible
    private static Map<String, Integer> getLogsCountByDay(String issueId, Datetime startDate, Datetime endDate) {
        Map<String, Integer> logsByDay = new Map<String, Integer>();

        List<AggregateResult> results = [
            SELECT
                DAY_ONLY(Created_At__c) day,
                COUNT(Id) logCount
            FROM Log__c
            WHERE Issue__c = :issueId
            AND Created_At__c >= :startDate
            AND Created_At__c <= :endDate
            GROUP BY DAY_ONLY(Created_At__c)
            ORDER BY DAY_ONLY(Created_At__c) ASC
        ];

        for (AggregateResult result : results) {
            Date dayDate = (Date) result.get('day');
            Integer count = (Integer) result.get('logCount');
            Datetime dayDatetime = Datetime.newInstance(dayDate, Time.newInstance(0, 0, 0, 0));
            String dateKey = dayDatetime.format('yyyy-MM-dd');
            logsByDay.put(dateKey, count);
        }

        return logsByDay;
    }

}