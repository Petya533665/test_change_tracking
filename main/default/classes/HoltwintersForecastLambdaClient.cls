/**
 * HoltwintersForecastLambdaClient - Generates user activity forecasts using Holt-Winters algorithm via AWS Lambda
 * 
 * AWS Lambda Function: holtwinters-forecast-lambda (v1.0.12)
 * ECR Repository: 385795226412.dkr.ecr.us-west-1.amazonaws.com/holtwinters-forecast-lambda
 * 
 * Features:
 * - Configurable forecast periods (1-30 days)
 * - Multiple seasonality types (daily, weekly, monthly, auto)
 * - ZIP file support for large datasets (95% compression)
 * - Top 3 activity periods per day
 * - Centered time ranges around peak hours
 * - User attribution in responses
 * 
 * Lambda Response Format:
 * - Success: {
 *     "forecast": {
 *       "04-08-2025": [
 *         {
 *           "time_range": "16:30-19:30",
 *           "startDateTime": "2025-08-04T16:30:00",
 *           "endDateTime": "2025-08-04T19:30:00",
 *           "predicted_activity": 0.07697123577669232,
 *           "confidence": "high",
 *           "detected_peak_time": "18:00",
 *           "userId": "005Qy00000JbC5r"
 *         }
 *       ]
 *     },
 *     "seasonality": {"type": "weekly", "description": "Weekly seasonality (7 days)"},
 *     "execution_time_seconds": 0.709,
 *     "logs_processed": 104,
 *     "users_processed": 2,
 *     "total_users": 2
 *   }
 * - Error: {"message": "error message", "error": "error details"}
 * 
 * Input Format:
 * {
 *   "logs": [
 *     {"userId": "005...", "timestamp": "2025-07-17T06:15:00Z"},
 *     {"userId": "005...", "timestamp": "2025-07-17T12:02:00Z"}
 *   ],
 *   "seasonality_type": "daily", // optional: daily, weekly, monthly, auto
 *   "forecast_days": 7 // optional: 1-30 days (default: 7)
 * }
 * 
 * Supported Input Formats:
 * 1. JSON Object with logs array
 * 2. JSON String
 * 3. Base64 Encoded JSON
 * 4. Base64 Encoded ZIP Files (for large datasets)
 * 
 * Usage Examples:
 * 
 * // Generate forecast for user activity
 * HoltwintersForecastLambdaClient client = new HoltwintersForecastLambdaClient();
 * client.generateUserActivityForecast(logsData, SeasonalityType.DAILY);
 * 
 * // Generate forecast with custom period
 * client.generateUserActivityForecast(logsData, SeasonalityType.DAILY, 14);
 * 
 * // Get forecast results
 * Map<String, ActivityForecast> activity = client.getActivityForecast();
 * SeasonalityInfo seasonality = client.getSeasonalityInfo();
 * 
 * // Check if forecast was successful
 * Boolean isSuccess = client.isSuccess();
 */
public with sharing class HoltwintersForecastLambdaClient {
   
    // Error response class for Lambda errors
    public class LambdaErrorResponse {
        public Integer statusCode;
        public String message;
        public String error;
        public String errorCode;
    }

    // Custom exception class
    public class HoltwintersForecastException extends Exception {}
   
    // Seasonality types supported by Lambda
    public enum SeasonalityType {
        DAILY,
        WEEKLY,
        MONTHLY,
        AUTO
    }

    // Wrapper class for log entries
    public class LogEntry {
        @AuraEnabled public String userId;
        @AuraEnabled public String timestamp;
        
        public LogEntry(String userId, String timestamp) {
            this.userId = userId;
            this.timestamp = timestamp;
        }
    }

    // Wrapper class for activity forecast time range
    public class ActivityTimeRange {
        @AuraEnabled public String time_range;
        @AuraEnabled public String startDateTime;
        @AuraEnabled public String endDateTime;
        @AuraEnabled public Decimal predicted_activity;
        @AuraEnabled public String confidence;
        @AuraEnabled public String detected_peak_time;
        @AuraEnabled public String userId;
    }

    // Wrapper class for activity forecast by date
    public class ActivityForecast {
        @AuraEnabled public List<ActivityTimeRange> timeRanges;
    }

    // Wrapper class for seasonality information
    public class SeasonalityInfo {
        @AuraEnabled public String type;
        @AuraEnabled public String description;
    }

    // Wrapper class for execution statistics
    public class ExecutionStats {
        @AuraEnabled public Decimal execution_time_seconds;
        @AuraEnabled public Integer logs_processed;
        @AuraEnabled public Integer users_processed;
        @AuraEnabled public Integer total_users;
    }

    // Wrapper class for Lambda response
    public class LambdaResponse {
        @AuraEnabled public Map<String, List<ActivityTimeRange>> forecast;
        @AuraEnabled public SeasonalityInfo seasonality;
        @AuraEnabled public Decimal execution_time_seconds;
        @AuraEnabled public Integer logs_processed;
        @AuraEnabled public Integer users_processed;
        @AuraEnabled public Integer total_users;
    }
   
    // API Configuration
    private static final String URL_ENDPOINT = 'https://api.pharos.ai/dev/forecast';
    private static final Integer DEFAULT_FORECAST_DAYS = 7;
    private static final Integer MIN_FORECAST_DAYS = 1;
    private static final Integer MAX_FORECAST_DAYS = 30;
    private static final Integer DEFAULT_LOOKBACK_DAYS = 30;
    private static final Integer MIN_LOOKBACK_DAYS = 1;
    private static final Integer MAX_LOOKBACK_DAYS = 365;

    private LambdaResponse lambdaResponse;
    private LambdaErrorResponse errorResponse;
    private Boolean isSuccessful;

    private static final Map<String, String> AUTH_HEADERS {
        get {
            if (AUTH_HEADERS == null) {
                AUTH_HEADERS = new Map<String, String>();
                AWS_Token__mdt mdtSettings = AWS_Token__mdt.getInstance('AWSToken');
                if(mdtSettings != null) {
                    AUTH_HEADERS.put('x-api-key', mdtSettings.Token__c);
                }
            }
            return AUTH_HEADERS;
        }
        private set;
    }

    private static final Map<String, String> HEADERS {
        get {
            if (HEADERS == null) {
                HEADERS = new Map<String, String>();
                HEADERS.putAll(AUTH_HEADERS);
                HEADERS.put('Content-Type', 'application/json; charset=utf-8');
            }
            return HEADERS;
        }
        private set;
    }

    public HoltwintersForecastLambdaClient() {
        // Default constructor
    }

    /**
     * Generate user activity forecast using Holt-Winters algorithm with default forecast and lookback periods
     * @param logsData List of LogEntry objects with userId and timestamp
     * @param seasonalityType Seasonality type enum (DAILY, WEEKLY, MONTHLY, AUTO)
     * @return HoltwintersForecastLambdaClient instance for method chaining
     */
    public HoltwintersForecastLambdaClient generateUserActivityForecast(List<LogEntry> logsData, SeasonalityType seasonalityType) {
        return generateUserActivityForecast(logsData, seasonalityType, DEFAULT_FORECAST_DAYS, DEFAULT_LOOKBACK_DAYS);
    }

    /**
     * Generate user activity forecast using Holt-Winters algorithm with custom forecast period
     * @param logsData List of LogEntry objects with userId and timestamp
     * @param seasonalityType Seasonality type enum (DAILY, WEEKLY, MONTHLY, AUTO)
     * @param forecastDays Number of days to forecast (1-30, default: 7)
     * @return HoltwintersForecastLambdaClient instance for method chaining
     */
    public HoltwintersForecastLambdaClient generateUserActivityForecast(List<LogEntry> logsData, SeasonalityType seasonalityType, Integer forecastDays) {
        return generateUserActivityForecast(logsData, seasonalityType, forecastDays, DEFAULT_LOOKBACK_DAYS);
    }

    /**
     * Generate user activity forecast using Holt-Winters algorithm with custom forecast and lookback periods
     * @param logsData List of LogEntry objects with userId and timestamp
     * @param seasonalityType Seasonality type enum (DAILY, WEEKLY, MONTHLY, AUTO)
     * @param forecastDays Number of days to forecast (1-30, default: 7)
     * @param lookbackDays Number of days back to analyze for forecasting (1-365, default: 30)
     * @return HoltwintersForecastLambdaClient instance for method chaining
     */
    public HoltwintersForecastLambdaClient generateUserActivityForecast(List<LogEntry> logsData, SeasonalityType seasonalityType, Integer forecastDays, Integer lookbackDays) {
        if (logsData == null || logsData.isEmpty()) {
            throw new HoltwintersForecastException('Logs data is required and cannot be empty');
        }
        
        if (seasonalityType == null) {
            seasonalityType = HoltwintersForecastLambdaClient.SeasonalityType.AUTO;
        }
        
        // Validate forecast days (1-30 range)
        if (forecastDays == null || forecastDays < MIN_FORECAST_DAYS || forecastDays > MAX_FORECAST_DAYS) {
            forecastDays = DEFAULT_FORECAST_DAYS; // Default to 7 days for invalid values
        }
        
        // Validate lookback days (1-365 range)
        if (lookbackDays == null || lookbackDays < MIN_LOOKBACK_DAYS || lookbackDays > MAX_LOOKBACK_DAYS) {
            lookbackDays = DEFAULT_LOOKBACK_DAYS; // Default to 30 days for invalid values
        }
        
        try {
            // Build request payload with dynamic date range based on lookbackDays
            Datetime currentTime = System.now();
            Datetime startDate = currentTime.addDays(-lookbackDays);
            
            Map<String, Object> requestPayload = new Map<String, Object>{
                'logs' => logsData,
                'seasonality_type' => seasonalityType.name().toLowerCase(),
                'forecast_days' => forecastDays,
                //'lookback_days' => lookbackDays,
                'start_date' => startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'end_date' => currentTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            };
            
            String payload = JSON.serialize(requestPayload);
            //HttpUtils.enableHttpDebug = true;
            String response = HttpUtils.post(
                URL_ENDPOINT,
                payload,
                HEADERS,
                200
            );

            if (String.isBlank(response)) {
                throw new HoltwintersForecastException('Empty response from Lambda function');
            }
            // Try to parse as successful response first
            try {
                this.lambdaResponse = (LambdaResponse) JSON.deserialize(response, LambdaResponse.class);
                this.isSuccessful = true;
                
            } catch (Exception e) {
                // Try to parse as error response
                Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response);
                
                if (errorMap.containsKey('message') && errorMap.containsKey('error')) {
                    this.errorResponse = new LambdaErrorResponse();
                    this.errorResponse.message = (String) errorMap.get('message');
                    this.errorResponse.error = (String) errorMap.get('error');
                    this.errorResponse.statusCode = 500; // Default error status code
                    this.isSuccessful = false;
                    
                    throw new HoltwintersForecastException('Lambda Error: ' + this.errorResponse.message + ' - ' + this.errorResponse.error);
                } else {
                    // Unknown response format
                    throw new HoltwintersForecastException('Invalid response format from Lambda function');
                }
            }
            
            if (this.lambdaResponse == null || this.lambdaResponse.forecast == null || this.lambdaResponse.forecast.isEmpty()) {
                throw new HoltwintersForecastException('No valid activity forecast data found in Lambda response');
            }
            
            return this;

        } catch (Exception e) {
            if (e instanceof HoltwintersForecastException) {
                throw e;
            }
            throw new HoltwintersForecastException('Error calling Lambda function: ' + e.getMessage());
        }
    }

    /**
     * Get the complete Lambda response
     * @return LambdaResponse object containing all response data
     */
    public LambdaResponse getLambdaResponse() {
        if (this.lambdaResponse != null) {
            return this.lambdaResponse;
        }
        throw new HoltwintersForecastException('No Lambda response available. Call generateUserActivityForecast() first.');
    }

    /**
     * Get the activity forecast results
     * @return Map of ActivityForecast objects by date
     */
    public Map<String, ActivityForecast> getActivityForecast() {
        if (this.lambdaResponse != null && this.lambdaResponse.forecast != null) {
            Map<String, ActivityForecast> result = new Map<String, ActivityForecast>();
            for (String dateKey : this.lambdaResponse.forecast.keySet()) {
                ActivityForecast forecast = new ActivityForecast();
                forecast.timeRanges = this.lambdaResponse.forecast.get(dateKey);
                result.put(dateKey, forecast);
            }
            return result;
        }
        throw new HoltwintersForecastException('No activity forecast data available. Call generateUserActivityForecast() first.');
    }

    /**
     * Get seasonality information
     * @return SeasonalityInfo object containing seasonality type and description
     */
    public SeasonalityInfo getSeasonalityInfo() {
        if (this.lambdaResponse != null && this.lambdaResponse.seasonality != null) {
            return this.lambdaResponse.seasonality;
        }
        throw new HoltwintersForecastException('No seasonality information available. Call generateUserActivityForecast() first.');
    }

    /**
     * Get execution statistics
     * @return ExecutionStats object containing execution time, logs processed, users processed, etc.
     */
    public ExecutionStats getExecutionStats() {
        if (this.lambdaResponse != null) {
            ExecutionStats stats = new ExecutionStats();
            stats.execution_time_seconds = this.lambdaResponse.execution_time_seconds;
            stats.logs_processed = this.lambdaResponse.logs_processed;
            stats.users_processed = this.lambdaResponse.users_processed;
            stats.total_users = this.lambdaResponse.total_users;
            return stats;
        }
        throw new HoltwintersForecastException('No execution statistics available. Call generateUserActivityForecast() first.');
    }





    /**
     * Check if the forecast generation was successful
     * @return Boolean indicating success
     */
    public Boolean isSuccess() {
        return this.isSuccessful != null ? this.isSuccessful : false;
    }

    /**
     * Get error response if forecast failed
     * @return LambdaErrorResponse object
     */
    public LambdaErrorResponse getErrorResponse() {
        return this.errorResponse;
    }

    /**
     * Get the default forecast days configuration
     * @return Integer default forecast days (7)
     */
    public static Integer getDefaultForecastDays() {
        return DEFAULT_FORECAST_DAYS;
    }

    /**
     * Get the minimum forecast days allowed
     * @return Integer minimum forecast days (1)
     */
    public static Integer getMinForecastDays() {
        return MIN_FORECAST_DAYS;
    }

    /**
     * Get the maximum forecast days allowed
     * @return Integer maximum forecast days (30)
     */
    public static Integer getMaxForecastDays() {
        return MAX_FORECAST_DAYS;
    }

    /**
     * Get the default lookback days configuration
     * @return Integer default lookback days (30)
     */
    public static Integer getDefaultLookbackDays() {
        return DEFAULT_LOOKBACK_DAYS;
    }

    /**
     * Get the minimum lookback days allowed
     * @return Integer minimum lookback days (1)
     */
    public static Integer getMinLookbackDays() {
        return MIN_LOOKBACK_DAYS;
    }

    /**
     * Get the maximum lookback days allowed
     * @return Integer maximum lookback days (365)
     */
    public static Integer getMaxLookbackDays() {
        return MAX_LOOKBACK_DAYS;
    }
}