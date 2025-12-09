/**
 * ChartGeneratorImageLambdaClient - Generates chart images using AWS Lambda
 * 
 * Lambda Response Format:
 * - Success: {"OCCURRENCE_LAST_7_DAYS": "base64image", "OCCURRENCE_LOGS_LAST_7_DAYS": "base64image"}
 * - Error: {"message": "error message", "error": "error details"}
 * 
 * Input Format:
 * {
 *   "OCCURRENCE_LAST_7_DAYS": {
 *     "SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE": "[{\"logCount\":3,\"date\":\"24.06.2025\"}]"
 *   },
 *   "OCCURRENCE_LAST_30_DAYS": {
 *     "SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE": "[{\"logCount\":6,\"date\":\"9.06.2025\"},{\"logCount\":3,\"date\":\"24.06.2025\"}]"
 *   }
 * }
 * 
 * Usage Examples:
 * 
 * // Generate charts
 * ChartGeneratorImageLambdaClient client = new ChartGeneratorImageLambdaClient();
 * client.generateMultipleChartImages(chartConfig);
 * 
 * // Access images using ChartService.Chart enum values:
 * ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name() => image1
 * ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name() => image2
 * ChartService.Chart.OCCURRENCE_LOGS_LAST_7_DAYS.name() => image3
 * 
 * // Get specific chart images:
 * Blob chart7Days = client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name());
 * Blob chart30Days = client.getBlobImageForChart(ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name());
 * 
 * // Get base64 strings:
 * String chart7DaysBase64 = client.getBase64ImageForChart(ChartService.Chart.OCCURRENCE_LAST_7_DAYS.name());
 * String chart30DaysBase64 = client.getBase64ImageForChart(ChartService.Chart.OCCURRENCE_LAST_30_DAYS.name());
 */
public with sharing class ChartGeneratorImageLambdaClient {
   
    private static final String URL_ENDPOINT = 'https://api.pharos.ai/generate-chart-v2'; 

    private Map<String, String> chartImages;
    private LambdaErrorResponse errorResponse;
    private Map<String, String> metadata;


    public ChartGeneratorImageLambdaClient() {
    }
    
    /**
     * Set metadata to be sent with the request (e.g., issueId, recordId)
     * @param metadata Map containing metadata fields (e.g., {'issueId' => 'ISS-123', 'recordId' => 'a0X...'})
     * @return ChartGeneratorImageLambdaClient instance for method chaining
     */
    public ChartGeneratorImageLambdaClient setMetadata(Map<String, String> metadata) {
        this.metadata = metadata;
        return this;
    }
    
    /**
     * Get the metadata that was set
     * @return Map of metadata fields
     */
    public Map<String, String> getMetadata() {
        return this.metadata != null ? this.metadata : new Map<String, String>();
    }

    /**
     * Generate chart images based on chart configuration string
     * @param chartConfig JSON string containing chart configuration
     * @return ChartGeneratorImageLambdaClient instance for method chaining
     */
    public ChartGeneratorImageLambdaClient generateChartImagesBasedStringChartConfig(String chartConfig) {
        if (String.isBlank(chartConfig)) {
            throw new ChartGeneratorException('Chart Config is required');
        }
        
        try {
            // Parse chart config to add metadata if available
            String requestBody = chartConfig;
            if (this.metadata != null && !this.metadata.isEmpty()) {
                Map<String, Object> configMap = (Map<String, Object>) JSON.deserializeUntyped(chartConfig);
                // Add metadata as _metadata field
                Map<String, String> metadataCopy = new Map<String, String>(this.metadata);
                configMap.put('_metadata', metadataCopy);
                requestBody = JSON.serialize(configMap);
            }
            
            //HttpUtils.enableHttpDebug = true;
            String response = HttpUtils.post(
                URL_ENDPOINT,
                requestBody,
                HttpUtils.getHeadersWithApiKeyAndJson(),
                200
            );

            if (String.isBlank(response)) {
                throw new ChartGeneratorException('Empty response from Lambda function');
            }

            // Parse the response
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            
            // Check if this is an error response (contains message and error fields)
            if (responseMap.containsKey('message') && responseMap.containsKey('error')) {
                this.errorResponse = new LambdaErrorResponse();
                this.errorResponse.message = (String) responseMap.get('message');
                this.errorResponse.error = (String) responseMap.get('error');
                this.errorResponse.statusCode = 500; // Default error status code
                
                // Extract metadata from error response if available
                if (responseMap.containsKey('metadata')) {
                    Object metadataObj = responseMap.get('metadata');
                    if (metadataObj instanceof Map<String, Object>) {
                        Map<String, Object> metadataMap = (Map<String, Object>) metadataObj;
                        this.errorResponse.metadata = new Map<String, String>();
                        for (String key : metadataMap.keySet()) {
                            Object value = metadataMap.get(key);
                            if (value != null) {
                                this.errorResponse.metadata.put(key, String.valueOf(value));
                            }
                        }
                    }
                }
                
                // Build error message with metadata context if available
                String errorMsg = 'Lambda Error: ' + this.errorResponse.message + ' - ' + this.errorResponse.error;
                if (this.errorResponse.metadata != null && !this.errorResponse.metadata.isEmpty()) {
                    errorMsg += ' [Metadata: ' + JSON.serialize(this.errorResponse.metadata) + ']';
                }
                
                throw new ChartGeneratorException(errorMsg);
            }

            // Parse as successful chart response
            this.chartImages = new Map<String, String>();
            
            // Extract chart data from response
            for (String key : responseMap.keySet()) {
                Object value = responseMap.get(key);
                if (value instanceof String) {
                    String base64Image = (String) value;
                    if (String.isNotBlank(base64Image)) {
                        this.chartImages.put(key, base64Image);
                    }
                }
            }
            
            if (this.chartImages.isEmpty()) {
                throw new ChartGeneratorException('No valid chart images found in Lambda response');
            }
            
            return this;

        } catch (Exception e) {
            if (e instanceof ChartGeneratorException) {
                throw e;
            }
            throw new ChartGeneratorException('Error calling Lambda function: ' + e.getMessage());
        }
    }

    /**
     * Get blob image for specific chart type
     * @param chartType ChartService.Chart enum value as string (e.g., 'OCCURRENCE_LAST_7_DAYS')
     * @return Blob containing the chart image
     */
    public Blob getBlobImageForChart(String chartType) {
        if (this.chartImages != null && this.chartImages.containsKey(chartType)) {
            String base64Image = this.chartImages.get(chartType);
            if (String.isNotBlank(base64Image)) {
                return EncodingUtil.base64Decode(base64Image);
            }
        }
        throw new ChartGeneratorException('Chart image not found for type: ' + chartType);
    }

    /**
     * Get base64 image string for specific chart type
     * @param chartType ChartService.Chart enum value as string (e.g., 'OCCURRENCE_LAST_7_DAYS')
     * @return Base64 encoded image string
     */
    public String getBase64ImageForChart(String chartType) {
        if (this.chartImages != null && this.chartImages.containsKey(chartType)) {
            String base64Image = this.chartImages.get(chartType);
            if (String.isNotBlank(base64Image)) {
                return base64Image;
            }
        }
        throw new ChartGeneratorException('Chart image not found for type: ' + chartType);
    }

    /**
     * Get all available chart types
     * @return Set of chart type strings
     */
    public Set<String> getAvailableChartTypes() {
        if (this.chartImages != null) {
            return this.chartImages.keySet();
        }
        return new Set<String>();
    }

    /**
     * Check if response contains charts
     * @return true if charts are available, false otherwise
     */
    public Boolean hasCharts() {
        return this.chartImages != null && !this.chartImages.isEmpty();
    }

    /**
     * Check if there was an error response
     * @return true if error occurred, false otherwise
     */
    public Boolean hasError() {
        return this.errorResponse != null;
    }

    /**
     * Get error response details
     * @return LambdaErrorResponse object
     */
    public LambdaErrorResponse getErrorResponse() {
        return this.errorResponse;
    }

    /**
     * Generate chart images for multiple chart types using new input format
     * @param chartConfigs Map of chart type to chart configuration with nested system report data
     * @return ChartGeneratorImageLambdaClient instance for method chaining
     */
    public ChartGeneratorImageLambdaClient generateMultipleChartImages(Map<String, Object> chartConfigs) {
        if (chartConfigs == null || chartConfigs.isEmpty()) {
            throw new ChartGeneratorException('Chart configurations are required');
        }
        
        String chartConfigJson = JSON.serialize(chartConfigs);
        return generateChartImagesBasedStringChartConfig(chartConfigJson);
    }

    /**
     * Generate chart image for specific chart type using ChartService.Chart enum
     * @param chartType ChartService.Chart enum value
     * @param systemReportData Map containing system report data (e.g., {"SYSTEM_CHART_LOG_OCCURRENCE_BY_ISSUE": "data"})
     * @return ChartGeneratorImageLambdaClient instance for method chaining
     */
    public ChartGeneratorImageLambdaClient generateChartImageForType(ChartService.Chart chartType, Map<String, Object> systemReportData) {
        if (chartType == null || systemReportData == null || systemReportData.isEmpty()) {
            throw new ChartGeneratorException('Chart type and system report data are required');
        }
        
        Map<String, Object> configs = new Map<String, Object>{
            chartType.name() => systemReportData
        };
        
        return generateMultipleChartImages(configs);
    }

    /**
     * Generate chart image for specific chart type and system report
     * @param chartType ChartService.Chart enum value
     * @param systemReport ReportService.SystemReport enum value
     * @param reportData JSON string containing the report data
     * @return ChartGeneratorImageLambdaClient instance for method chaining
     */
    public ChartGeneratorImageLambdaClient generateChartImageForTypeAndReport(ChartService.Chart chartType, ReportService.SystemReport systemReport, String reportData) {
        if (chartType == null || systemReport == null || String.isBlank(reportData)) {
            throw new ChartGeneratorException('Chart type, system report, and report data are required');
        }
        
        Map<String, Object> systemReportData = new Map<String, Object>{
            systemReport.name() => reportData
        };
        
        return generateChartImageForType(chartType, systemReportData);
    }

    /**
     * Legacy method for backward compatibility - gets the first available chart
     * @return Blob containing the first chart image
     */
    public Blob getBlobImage() {
        if (this.chartImages != null && !this.chartImages.isEmpty()) {
            String firstChartType = new List<String>(this.chartImages.keySet())[0];
            return getBlobImageForChart(firstChartType);
        }
        throw new ChartGeneratorException('No chart images available');
    }

    /**
     * Legacy method for backward compatibility - gets the first available chart
     * @return Base64 encoded image string
     */
    public String getBase64Image() {
        if (this.chartImages != null && !this.chartImages.isEmpty()) {
            String firstChartType = new List<String>(this.chartImages.keySet())[0];
            return getBase64ImageForChart(firstChartType);
        }
        throw new ChartGeneratorException('No chart images available');
    }

    /**
    * Set chart images from external source (for caching scenarios)
    * @param images Map of chart type to base64 image string
    */
    public void setChartImages(Map<String, String> images) {
        this.chartImages = images;
    }

    /**
     * Get all chart images as a map
     * @return Map of chart type to base64 image string
     */
    public Map<String, String> getChartImages() {
        return this.chartImages != null ? this.chartImages : new Map<String, String>();
    }

    public class LambdaErrorResponse {
        public Integer statusCode;
        public String message;
        public String error;
        public Map<String, String> metadata; // Contains issueId, recordId, etc. when available
    }

    public class ChartGeneratorException extends Exception {}
}