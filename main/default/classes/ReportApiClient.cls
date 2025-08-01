/**
 * @description Client class for interacting with the Salesforce Analytics API to execute reports.
 * This class provides a fluent interface for building and executing report requests with
 * proper authentication and error handling.
 * 
 * @author Pharos Development Team
 * @since 1.0
 */
public with sharing class ReportApiClient {
    /** Base URL for the Salesforce Analytics API */
    private static final String REPORT_URL = '/services/data/v61.0/analytics/reports/';
    /** The full endpoint URL for the report execution */
    private String reportEndPoint;
    /** The ID of the report to execute */
    private String reportId;
    /** HTTP headers for the API request */
    private Map<String, String> headers;
    /** The JSON payload for the report request */
    private String payload;
    /** The HTTP response from the API call */
    private HttpResponse response;

    /**
     * @description Constructor that initializes the ReportApiClient with default headers
     * including authorization and content type.
     */
    public ReportApiClient() {
        this.headers = new Map<String, String>();
        this.headers.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
        this.headers.put('Content-Type', 'application/json');
    }

    /**
     * @description Sets the report ID for this client instance.
     * 
     * @param reportId The Salesforce Report ID to execute
     * @return ReportApiClient - Returns this instance for method chaining
     */
    public ReportApiClient setReportId(String reportId) {
        this.reportId = reportId;
        return this;
    }

    /**
     * @description Builds the full endpoint URL for the report execution using the current
     * org's domain and the report ID.
     * 
     * @return ReportApiClient - Returns this instance for method chaining
     */
    public ReportApiClient buildCurrentOrgUrl() {
        this.reportEndPoint = getDomain() + REPORT_URL + reportId;
        return this;
    }

    /**
     * @description Sets custom HTTP headers for the API request.
     * 
     * @param headers Map of header names to header values
     * @return ReportApiClient - Returns this instance for method chaining
     */
    public ReportApiClient setHeaders(Map<String, String> headers) {
        this.headers = headers;
        return this;
    }

    /**
     * @description Sets the JSON payload for the report request.
     * 
     * @param payload The JSON string payload for the report request
     * @return ReportApiClient - Returns this instance for method chaining
     */
    public ReportApiClient setPayload(String payload) {
        this.payload = payload;
        return this;
    }

    /**
     * @description Executes the report by sending an HTTP POST request to the Salesforce Analytics API.
     * This method validates that both payload and endpoint are set before making the request.
     * 
     * @return ReportApiClient - Returns this instance for method chaining
     * @throws IllegalArgumentException if payload or reportEndPoint is blank
     * 
     * @example
     * ReportApiClient client = new ReportApiClient()
     *     .setReportId('00O1234567890ABC')
     *     .buildCurrentOrgUrl()
     *     .buildReportPayload(filters)
     *     .executeReport();
     */
    public ReportApiClient executeReport() {
        if (String.isBlank(this.payload)) {
            throw new IllegalArgumentException('Payload is required. Use setPayload() method.');
        }
        if (String.isBlank(this.reportEndPoint)) {
            throw new IllegalArgumentException('Report endpoint is required. Use buildCurrentOrgUrl() method.');
        }
        this.response = HttpUtils.send(
            reportEndPoint,
            'POST',
            this.headers,
            this.payload
        );

        // Check for HTTP errors
        if (this.response != null && this.response.getStatusCode() >= 400) {
            // HTTP error occurred
        }

        return this;
    }

    /**
     * @description Gets the raw HTTP response from the API call.
     * 
     * @return HttpResponse - The HTTP response object
     */
    public HttpResponse getResponse() {
        return this.response;
    }
    
    /**
     * @description Checks if the API call was successful based on the HTTP status code.
     * 
     * @return Boolean - True if status code is between 200-299, false otherwise
     */
    public Boolean isSuccess() {
        return this.response != null && this.response.getStatusCode() >= 200 && this.response.getStatusCode() < 300;
    }
    
    /**
     * @description Gets the response body as a string from the API call.
     * 
     * @return String - The response body, or null if no response exists
     */
    public String getResponseBody() {
        return this.response != null ? this.response.getBody() : null;
    }
    
    /**
     * @description Gets the HTTP status code from the API response.
     * 
     * @return Integer - The HTTP status code, or null if no response exists
     */
    public Integer getStatusCode() {
        return this.response != null ? this.response.getStatusCode() : null;
    }

    /**
     * @description Creates a filter for filtering logs by issue key.
     * 
     * @param issueKey The issue key to filter by
     * @return Map<String, Object> - Filter map with column, operator, and value
     */
    public static Map<String, Object> createIssueFilter(String issueKey) {
        return createFilter(Schema.SObjectType.Log__c.getName() + '.' + Schema.SObjectType.Log__c.fields.Issue__c.getName(), 'equals', issueKey);
    }

    /**
     * @description Builds the JSON payload for the report request using the provided filters.
     * This method creates the proper structure expected by the Salesforce Analytics API.
     * 
     * @param filters List of filters to apply to the report
     * @return ReportApiClient - Returns this instance for method chaining
     * 
     * @example
     * List<Map<String, Object>> filters = new List<Map<String, Object>>{
     *     new Map<String, Object>{'column' => 'Log__c.Created_At__c', 'operator' => 'greaterOrEqual', 'value' => DateTime.now().addDays(-7)}
     * };
     * ReportApiClient client = new ReportApiClient().buildReportPayload(filters);
     */
    public ReportApiClient buildReportPayload(List<Map<String, Object>> filters) {
        Map<String, Object> reportMetadata = new Map<String, Object>{
            'reportFilters' => filters
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'reportMetadata' => reportMetadata
        };
        this.payload = JSON.serialize(requestBody);
        return this;
    }

    /**
     * @description Creates a filter map for report filtering with validation.
     * 
     * @param column The field name to filter on (e.g., 'Log__c.Created_At__c')
     * @param operator The filter operator (e.g., 'equals', 'greaterOrEqual', 'lessOrEqual')
     * @param value The value to filter by
     * @return Map<String, Object> - Filter map with column, operator, and value
     * @throws IllegalArgumentException if column or operator is blank
     * 
     * @example
     * Map<String, Object> filter = ReportApiClient.createFilter('Log__c.Created_At__c', 'greaterOrEqual', DateTime.now().addDays(-7));
     * // Returns: {'column' => 'Log__c.Created_At__c', 'operator' => 'greaterOrEqual', 'value' => 2024-01-08T10:00:00Z}
     */
    public static Map<String, Object> createFilter(String column, String operator, Object value) {
        if (String.isBlank(column)) {
            throw new IllegalArgumentException('Column parameter cannot be blank');
        }
        if (String.isBlank(operator)) {
            throw new IllegalArgumentException('Operator parameter cannot be blank');
        }
        
        return new Map<String, Object>{
            'column' => column,
            'operator' => operator,
            'value' => value
        };
    }

    /**
     * @description Creates a list of filters for date range filtering.
     * This method creates two filters: one for the start date (greaterOrEqual) and one for the end date (lessOrEqual).
     * 
     * @param column The date field name to filter on (e.g., 'Log__c.Created_At__c')
     * @param startDateTime The start date for the range (inclusive)
     * @param endDateTime The end date for the range (inclusive)
     * @return List<Map<String, Object>> - List of filters for the date range
     * @throws IllegalArgumentException if column is blank
     * 
     * @example
     * DateTime start = DateTime.now().addDays(-7);
     * DateTime end = DateTime.now();
     * List<Map<String, Object>> filters = ReportApiClient.createDateRangeFilters('Log__c.Created_At__c', start, end);
     * // Returns: [{'column' => 'Log__c.Created_At__c', 'operator' => 'greaterOrEqual', 'value' => start}, 
     * //           {'column' => 'Log__c.Created_At__c', 'operator' => 'lessOrEqual', 'value' => end}]
     */
    public static List<Map<String, Object>> createDateRangeFilters(String column, DateTime startDateTime, DateTime endDateTime) {
        List<Map<String, Object>> filters = new List<Map<String, Object>>();
        
        if (String.isBlank(column)) {
            throw new IllegalArgumentException('Column parameter cannot be blank');
        }
        
        if (startDateTime != null) {
            filters.add(createFilter(column, 'greaterOrEqual', startDateTime));
        }
        
        if (endDateTime != null) {
            filters.add(createFilter(column, 'lessOrEqual', endDateTime));
        }
        
        return filters;
    }



    /**
     * @description Gets the current org's domain URL for API calls.
     * 
     * @return String - The org's domain URL (e.g., 'https://yourorg.my.salesforce.com')
     */
    private static String getDomain() {
        return System.Url.getOrgDomainUrl().toExternalForm();
    }


}