/**
 * HoltwintersForecastLambdaService - High-level service for Holt-Winters user activity forecasting
 * 
 * This service provides comprehensive business logic for user activity forecasting using the
 * Holt-Winters exponential smoothing algorithm. It handles data preparation, validation,
 * forecasting operations, and result processing.
 * 
 * Key Features:
 * - User activity data preparation and validation from Salesforce logs
 * - Holt-Winters forecasting with multiple seasonality types (DAILY, WEEKLY, AUTO)
 * - Governor limit management for large datasets (49,900+ records)
 * - Comprehensive error handling and validation
 * - Integration with external Lambda services for computational processing
 * 
 * Algorithm Details:
 * The Holt-Winters method applies triple exponential smoothing to capture:
 * - Level: The baseline value of the time series
 * - Trend: The increasing or decreasing value in the series
 * - Seasonality: The repeating short-term cycle in the data
 * 
 * Usage Examples:
 * 
 * // Basic forecasting with log entries
 * List<HoltwintersForecastLambdaClient.LogEntry> logsData = HoltwintersForecastLambdaService.getUserIdToDateTime(
 *     'a0CQy00000ogy31MAA', System.now().addDays(-30), System.now());
 * HoltwintersForecastLambdaClient.LambdaResponse response = 
 *     HoltwintersForecastLambdaService.generateUserActivityForecast(
 *         logsData, 
 *         HoltwintersForecastLambdaClient.SeasonalityType.WEEKLY, 
 *         7, 90);
 * 
 * // Forecasting with compressed data
 * HoltwintersForecastLambdaClient.LambdaResponse response = 
 *     HoltwintersForecastLambdaService.forecastUserActivityFromCompressedLogs(
 *         compressedLogsData, 
 *         HoltwintersForecastLambdaClient.SeasonalityType.DAILY, 
 *         14, 60);
 * 
 * // Large dataset processing with automatic batching
 * List<Map<String, Datetime>> dateRanges = HoltwintersForecastLambdaService.getLogsCountByDayLargeDataset(
 *     'a0CQy00000ogy31MAA', System.now().addDays(-90), System.now());
 * 
 * Performance Considerations:
 * - Minimum 72 log entries recommended for daily seasonality
 * - Optimal performance with 240+ log entries
 * - Maximum forecast period: 30 days
 * - Maximum lookback period: 365 days
 * - Automatic batching for datasets exceeding 49,000 records
 * 
 * @author Salesforce Development Team
 * @since API Version 62.0
 * @version 1.2
 * @see HoltwintersForecastLambdaClient - Low-level Lambda client for AWS integration
 * @see Log__c - Salesforce object containing user activity data
 * @see HoltwintersForecastLambdaClient.LogEntry - Data transfer object for log entries
 * @see HoltwintersForecastLambdaClient.LambdaResponse - Response object containing forecast results
 */
public with sharing class HoltwintersForecastLambdaService {
    
    public static Boolean isEnabled {
        get {
            return PermissionsUtil.ForecastEnabled && ConfigUtil.PHAROS_SETTINGS.EnableForecast__c;
        }
        private set {}
    }


    public HoltwintersForecastLambdaService() {
        // Initialize service instance for Holt-Winters forecasting operations
    }

    /**
     * Generates user activity forecast from compressed log data using Holt-Winters algorithm
     * 
     * This method processes compressed log data and generates activity forecasts for the specified
     * number of days using the Holt-Winters exponential smoothing algorithm with the specified
     * seasonality type.
     * 
     * @param logsData Compressed log data string containing user activity information
     * @param seasonalityType Type of seasonality to apply (DAILY, WEEKLY, AUTO)
     * @param forecastDays Number of days to forecast into the future (1-30)
     * @param lookbackDays Number of days to look back for historical data (7-365)
     * @return HoltwintersForecastLambdaClient.LambdaResponse containing forecast results and metadata
     * @throws HoltwintersForecastLambdaClient.HoltwintersForecastException if invalid parameters or processing fails
     */
    public static HoltwintersForecastLambdaClient.LambdaResponse forecastUserActivityFromCompressedLogs(
        String logsData,
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType,
        Integer forecastDays,
        Integer lookbackDays
    ) {

        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();

        client.forecastUserActivityFromCompressedLogs(logsData, seasonalityType, forecastDays, lookbackDays);

        return client.getLambdaResponse();
    }

    /**
     * Generates user activity forecast from log entries using Holt-Winters algorithm
     * 
     * This method processes a list of log entries and generates activity forecasts for the specified
     * number of days using the Holt-Winters exponential smoothing algorithm.
     * 
     * @param logsData List of LogEntry objects containing user activity data
     * @param seasonalityType Type of seasonality to apply (DAILY, WEEKLY, AUTO)
     * @param forecastDays Number of days to forecast into the future (1-30)
     * @param lookbackDays Number of days to look back for historical data (7-365)
     * @return HoltwintersForecastLambdaClient.LambdaResponse containing forecast results and metadata
     * @throws HoltwintersForecastLambdaClient.HoltwintersForecastException if invalid parameters or processing fails
     */
    public static HoltwintersForecastLambdaClient.LambdaResponse generateUserActivityForecast(
        List<HoltwintersForecastLambdaClient.LogEntry> logsData,
        HoltwintersForecastLambdaClient.SeasonalityType seasonalityType,
        Integer forecastDays,
        Integer lookbackDays
    ) {

        HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
 
        client.generateUserActivityForecast(logsData, seasonalityType, forecastDays, lookbackDays);

        return client.getLambdaResponse();
    }

    /**
     * Retrieves user activity log entries for a specific issue within a date range
     * 
     * This method fetches log entries from the database for the specified issue and date range,
     * then converts them to LogEntry objects suitable for forecasting analysis.
     * 
     * @param issueId The ID of the issue to retrieve logs for
     * @param startDateTime Start date and time for the log retrieval range
     * @param endDateTime End date and time for the log retrieval range
     * @return List<HoltwintersForecastLambdaClient.LogEntry> containing user activity data
     */
    public static List<HoltwintersForecastLambdaClient.LogEntry> getUserIdToDateTime(String issueId, Datetime startDateTime, Datetime endDateTime) {
        List<Log__c> logs = getLogsForIssue(issueId, startDateTime, endDateTime);
        List<HoltwintersForecastLambdaClient.LogEntry> logsData = convertLogsToEntries(logs);
        
        return logsData;
    }


    /**
     * Get date ranges for large datasets that will result in batches under 49,000 records
     * @param issueId Issue ID to filter logs
     * @param startDate Start date for the range
     * @param endDate End date for the range
     * @return List<Map<String, Datetime>> where each map contains 'startDate' and 'endDate' keys
     */
    public static List<Map<String, Datetime>> getLogsCountByDayLargeDataset(String issueId, Datetime startDate, Datetime endDate) {
        Integer batchSize = 49000; // Maximum records per batch to avoid governor limits
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
                // Add current batch range to the list before exceeding governor limits
                Map<String, Datetime> dateRange = new Map<String, Datetime>{
                    'startDate' => batchStartDate,
                    'endDate' => currentDate
                };
                dateRanges.add(dateRange);
                
                // Reset batch count to previous value to avoid exceeding limits
                batchCount = previousBatchCount;
                
                // Set new batch start date for next iteration
                batchStartDate = currentDate.addDays(-1);
            }
        }
        
        // Add final batch range if there are remaining records to process
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
            LIMIT 49900
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
                String timestamp = log.Created_At__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
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