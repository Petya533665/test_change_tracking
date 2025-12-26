/**
 * WebhookService - Handles HTTP webhook callouts for notification integrations
 * 
 * Features:
 * - Configurable HTTP methods (GET, POST, PUT, PATCH, DELETE)
 * - Support for custom headers and authentication
 * - JSON body templating with merge field support
 * 
 * @since API Version 59.0
 */
public with sharing class WebhookService {
    
    // HTTP Configuration
    private static final Integer TIMEOUT = 10000; // 10 seconds
    private static final String DEFAULT_CONTENT_TYPE = HttpUtils.HTTP_CONTENT_TYPE_JSON;
    
    // Authentication Types
    private static final String AUTH_TYPE_NONE = 'None';
    private static final String AUTH_TYPE_BASIC = 'Basic';
    private static final String AUTH_TYPE_BEARER = 'Bearer';
    private static final String AUTH_TYPE_API_KEY = 'API_Key';
    private static final String AUTH_TYPE_CUSTOM = 'Custom';
    private static final String AUTH_PREFIX_BASIC = 'Basic ';
    
    // Template Processing
    private static final String EMPTY_JSON_OBJECT = '{}';
    private static final String MERGE_FIELD_PLACEHOLDER_PREFIX = '___MERGE_FIELD_';
    private static final String MERGE_FIELD_PLACEHOLDER_SUFFIX = '___';
    private static final String JSON_PLACEHOLDER_VALUE = '"PLACEHOLDER"';
    private static final String JSON_EMPTY_STRING = '""';
    
    // Token Generation
    private static final String WEBHOOK_TOKEN_PREFIX = 'webhook_';
    private static final String DELIMITER_COLON = ':';
    private static final Integer SPLIT_LIMIT_TWO = 2;
    
    // Remote Site Settings
    public static final String WEBHOOK_REMOTE_SITE_PREFIX = 'Webhook_';
    public static final Integer WEBHOOK_REMOTE_SITE_NAME_MAX_LENGTH = 30;
    public static final String WEBHOOK_REMOTE_SITE_DESCRIPTION = 'Auto-generated for webhook action';
    
    /**
     * Webhook configuration wrapper
     */
    public class WebhookConfig {
        public String url;
        public String method;
        public Map<String, String> headers;
        public String bodyTemplate;
        public String contentType;
        public WebhookAuthConfig authConfig;
        
        public WebhookConfig() {
            this.method = HttpUtils.HTTP_METHOD_POST;
            this.headers = new Map<String, String>();
            this.contentType = DEFAULT_CONTENT_TYPE;
        }
        
        /**
         * Validate configuration
         */
        public Boolean isValid() {
            if (String.isBlank(this.url)) {
                return false;
            }
            
            // Validate URL format
            try {
                new Url(this.url);
            } catch (Exception e) {
                return false;
            }
            
            return true;
        }
    }
    
    /**
     * Authentication configuration
     */
    public class WebhookAuthConfig {
        public String authType; // None, Basic, Bearer, API_Key, Custom
        public String authValue;
        public String headerName; // For API_Key type
        
        public WebhookAuthConfig(String authType, String authValue) {
            this.authType = authType;
            this.authValue = authValue;
            
            // Extract header name for API_Key type (format: "X-API-Key:value")
            if (authType == AUTH_TYPE_API_KEY && String.isNotBlank(authValue) && authValue.contains(DELIMITER_COLON)) {
                List<String> parts = authValue.split(DELIMITER_COLON, SPLIT_LIMIT_TWO);
                this.headerName = parts[0].trim();
                this.authValue = parts[1].trim();
            }
        }
        
        /**
         * Apply authentication to HTTP request
         */
        public void applyAuth(HttpRequest req) {
            if (String.isBlank(this.authType) || this.authType == AUTH_TYPE_NONE) {
                return;
            }
            
            if (this.authType == AUTH_TYPE_BASIC) {
                // Format: Basic base64(username:password)
                req.setHeader(HttpUtils.HEADER_AUTHORIZATION, AUTH_PREFIX_BASIC + this.authValue);
            } else if (this.authType == AUTH_TYPE_BEARER) {
                // Format: Bearer <token>
                req.setHeader(HttpUtils.HEADER_AUTHORIZATION, HttpUtils.AUTH_TYPE_BEARER + this.authValue);
            } else if (this.authType == AUTH_TYPE_API_KEY) {
                // Custom header (e.g., X-API-Key: value)
                if (String.isNotBlank(this.headerName)) {
                    req.setHeader(this.headerName, this.authValue);
                }
            } else if (this.authType == AUTH_TYPE_CUSTOM) {
                // Custom authorization header value
                req.setHeader(HttpUtils.HEADER_AUTHORIZATION, this.authValue);
            }
        }
    }
    
    /**
     * Webhook response wrapper
     */
    public class WebhookResponse {
        public Integer statusCode;
        public String body;
        public Boolean success;
        public String errorMessage;
        public Map<String, String> responseHeaders;
        public String requestBody; // For testing purposes
        
        public WebhookResponse(HttpResponse httpResponse) {
            this.statusCode = httpResponse.getStatusCode();
            this.body = httpResponse.getBody();
            this.success = (statusCode >= 200 && statusCode < 300);
            this.responseHeaders = new Map<String, String>();
            
            if (!this.success) {
                this.errorMessage = String.format(
                    'HTTP {0}: {1}',
                    new List<String>{
                        String.valueOf(statusCode),
                        httpResponse.getStatus()
                    }
                );
            }
        }
        
        public WebhookResponse(Exception e) {
            this.success = false;
            this.errorMessage = e.getMessage();
            this.statusCode = 0;
        }
    }
    
    /**
     * Build webhook configuration from Action__c record
     * @param action The Action__c record containing webhook configuration
     * @return WebhookConfig instance
     */
    public static WebhookConfig buildConfigFromAction(Action__c action) {
        WebhookConfig config = new WebhookConfig();
        
        // Required fields
        config.url = action.Webhook_URL__c;
        config.method = String.isNotBlank(action.Webhook_Method__c) 
            ? action.Webhook_Method__c 
            : HttpUtils.HTTP_METHOD_POST;
        config.bodyTemplate = action.Webhook_Body_Template__c;
        
        // Parse headers from JSON
        if (String.isNotBlank(action.Webhook_Headers__c)) {
            try {
                config.headers = (Map<String, String>) JSON.deserialize(
                    action.Webhook_Headers__c, 
                    Map<String, String>.class
                );
            } catch (Exception e) {
                // Log error but continue with empty headers
                Logger.getInstance()?.addInternalError(
                    e, 
                    WebhookService.class.getName(), 
                    'buildConfigFromAction - Invalid headers JSON'
                );
                config.headers = new Map<String, String>();
            }
        }
        
        // Extract Content-Type from headers, or use default
        config.contentType = DEFAULT_CONTENT_TYPE;
        if (config.headers != null) {
            for (String headerKey : config.headers.keySet()) {
                if (headerKey.equalsIgnoreCase('Content-Type')) {
                    config.contentType = config.headers.get(headerKey);
                    break;
                }
            }
        }
        
        // Parse authentication config
        if (String.isNotBlank(action.Webhook_Auth_Type__c)) {
            // Retrieve token from custom settings using action ID
            String authValue = getWebhookTokenFromSettings(action.Id);
            
            config.authConfig = new WebhookAuthConfig(
                action.Webhook_Auth_Type__c,
                authValue
            );
        }
        
        return config;
    }
    
    /**
     * Send webhook with configuration
     * @param recordId The record ID for merge field processing
     * @param config Webhook configuration
     * @return WebhookResponse
     */
    public static WebhookResponse sendWebhook(String recordId, WebhookConfig config) {
        // Validate configuration
        if (!config.isValid()) {
            throw new WebhookException('Invalid webhook configuration: URL is required');
        }
        
        String processedBody = '';
        try {
            // Process merge fields in body template
            processedBody = processMergeFields(recordId, config.bodyTemplate);
            
            // Build HTTP request
            HttpRequest req = buildHttpRequest(config, processedBody);
            
            // Send request
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);
            WebhookResponse response = new WebhookResponse(httpResponse);
            response.requestBody = processedBody; // For testing
            return response;
            
        } catch (Exception e) {
            Logger.getInstance()?.addInternalError(
                e, 
                WebhookService.class.getName(), 
                'sendWebhook'
            );
            WebhookResponse response = new WebhookResponse(e);
            response.requestBody = processedBody; // For testing
            return response;
        }
    }
    
    /**
     * Build HTTP request from configuration
     */
    private static HttpRequest buildHttpRequest(WebhookConfig config, String processedBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.url);
        req.setMethod(config.method);
        req.setTimeout(TIMEOUT);
        
        // Set content type
        req.setHeader(HttpUtils.HEADER_CONTENT_TYPE, config.contentType);
        
        // Set custom headers
        if (config.headers != null && !config.headers.isEmpty()) {
            for (String headerName : config.headers.keySet()) {
                req.setHeader(headerName, config.headers.get(headerName));
            }
        }
        
        // Apply authentication
        if (config.authConfig != null) {
            config.authConfig.applyAuth(req);
        }
        
        // Set body for POST/PUT/PATCH
        if (config.method == HttpUtils.HTTP_METHOD_POST || config.method == HttpUtils.HTTP_METHOD_PUT || config.method == HttpUtils.HTTP_METHOD_PATCH) {
            if (String.isNotBlank(processedBody)) {
                req.setBody(processedBody);
            }
        }
        
        return req;
    }
    
    /**
     * Process merge fields in body template
     * Supports both standard merge fields and JSON templates
     */
    private static String processMergeFields(String recordId, String bodyTemplate) {
        if (String.isBlank(bodyTemplate)) {
            return EMPTY_JSON_OBJECT;
        }
        
        // First, extract all merge field values and their positions
        // We need to escape them before they're inserted into the JSON
        Matcher mergeFieldMatcher = Constants.GLOBAL_VARIABLE.PATTERN_MERGE_FIELD.matcher(bodyTemplate);
        
        // Create a map of merge fields to their escaped values
        Map<String, String> mergeFieldPlaceholders = new Map<String, String>();
        Integer placeholderIndex = 0;
        
        // Replace merge fields with temporary placeholders
        String templateWithPlaceholders = bodyTemplate;
        while (mergeFieldMatcher.find()) {
            String mergeField = mergeFieldMatcher.group();
            String placeholder = MERGE_FIELD_PLACEHOLDER_PREFIX + placeholderIndex + MERGE_FIELD_PLACEHOLDER_SUFFIX;
            mergeFieldPlaceholders.put(placeholder, mergeField);
            templateWithPlaceholders = templateWithPlaceholders.replace(mergeField, placeholder);
            placeholderIndex++;
        }
        
        // Use NotificationService merge field processing on the original template
        List<String> messages = new List<String>{bodyTemplate};
        
        // Use Webhook action type for merge field settings
        NotificationService.MergeFieldSettings settings = 
            new NotificationService.MergeFieldSettings(
                Constants.ACTION_SOBJECT.ACTION_TYPE_WEBHOOK_NOTIFICATION
            );
        
        List<String> processedMessages = NotificationService.renderMergeFields(
            recordId, 
            messages, 
            settings
        );
        
        String renderedBody = processedMessages[0];
        
        // Now escape any special JSON characters that were introduced by merge field values
        // This is needed because merge field values might contain quotes, newlines, etc.
        // We'll do a character-by-character scan to properly escape values within JSON strings
        
        // Try to parse and re-serialize to ensure proper JSON formatting
        try {
            // The issue is that rendered values might have unescaped quotes/newlines
            // We need to escape them properly for JSON
            Object parsedJson = JSON.deserializeUntyped(renderedBody);
            return JSON.serialize(parsedJson);
        } catch (Exception e) {
            // If parsing fails, it means the rendered values broke the JSON syntax
            // We need to manually escape the special characters
            return escapeJsonValues(bodyTemplate, recordId, settings);
        }
    }
    
    /**
     * Helper method to properly escape JSON values after merge field rendering
     */
    private static String escapeJsonValues(String template, String recordId, NotificationService.MergeFieldSettings settings) {
        // Extract merge fields and render them individually
        Matcher mergeFieldMatcher = Constants.GLOBAL_VARIABLE.PATTERN_MERGE_FIELD.matcher(template);
        
        String result = template;
        while (mergeFieldMatcher.find()) {
            String mergeField = mergeFieldMatcher.group();
            
            // Render this specific merge field
            List<String> messages = new List<String>{mergeField};
            List<String> renderedValues = NotificationService.renderMergeFields(recordId, messages, settings);
            String renderedValue = renderedValues[0];
            
            // Escape the rendered value for JSON
            String escapedValue = escapeForJson(renderedValue);
            
            // Replace only the first occurrence (to handle duplicates correctly)
            Integer pos = result.indexOf(mergeField);
            if (pos >= 0) {
                result = result.substring(0, pos) + escapedValue + result.substring(pos + mergeField.length());
            }
        }
        
        return result;
    }
    
    /**
     * Validate JSON body template
     */
    public static Boolean isValidJsonTemplate(String template) {
        if (String.isBlank(template)) {
            return true; // Empty is valid
        }
        
        try {
            // Try to parse as JSON (with merge fields temporarily replaced)
            // Replace quoted merge fields first: "{!Field}" -> "PLACEHOLDER"
            String testJson = Constants.GLOBAL_VARIABLE.PATTERN_MERGE_FIELD_QUOTED.matcher(template).replaceAll(JSON_PLACEHOLDER_VALUE);
            // Then replace any remaining unquoted merge fields: {!Field} -> ""
            testJson = Constants.GLOBAL_VARIABLE.PATTERN_MERGE_FIELD.matcher(testJson).replaceAll(JSON_EMPTY_STRING);
            JSON.deserializeUntyped(testJson);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Helper method to escape special characters for JSON
     * Uses String.escapeEcmaScript() which follows JavaScript/JSON escaping rules
     */
    private static String escapeForJson(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        
        return value.escapeEcmaScript();
    }
    
    /**
     * Generate a safe token type name from action ID
     * Uses action ID to ensure uniqueness per action
     * @param actionId The action record ID
     * @return Safe alphanumeric string for use as token type (action ID based for uniqueness)
     */
    public static String generateWebhookTokenType(String actionId) {
        if (String.isBlank(actionId)) {
            return null;
        }
        
        // Use action ID to ensure uniqueness per action
        // This ensures each action gets its own token storage, even if they share the same URL
        // Format: "webhook_<actionId>" where actionId is 15 or 18 characters
        // Total: 8 (webhook_) + 18 (actionId) = 26 chars max (well within 40 char limit)
        return WEBHOOK_TOKEN_PREFIX + actionId;
    }
    
    /**
     * Save webhook auth token to custom settings
     * @param actionId The action record ID (used to generate unique token type)
     * @param token The token value to save
     * @param withDML Whether to perform DML immediately
     * @param logger Logger instance for error logging
     */
    public static void putWebhookTokenToSettings(String actionId, String token, Boolean withDML, Logger logger) {
        if (String.isNotBlank(actionId) && String.isNotBlank(token)) {
            String tokenType = generateWebhookTokenType(actionId);
            if (String.isNotBlank(tokenType)) {
                GraphAPIService.upsertGraphAPITokenRecords(tokenType, token, withDML, logger);
            }
        }
    }
    
    /**
     * Retrieve webhook auth token from custom settings
     * @param actionId The action record ID (used to generate unique token type)
     * @return The token value, or null if not found
     */
    public static String getWebhookTokenFromSettings(String actionId) {
        if (String.isBlank(actionId)) {
            return null;
        }
        
        String tokenType = generateWebhookTokenType(actionId);
        if (String.isNotBlank(tokenType)) {
            return GraphAPIService.getApiTokenValueFromSettings(tokenType);
        }
        
        return null;
    }
    
    /**
     * Delete webhook auth token from custom settings
     * @param actionIds Set of action record IDs to delete tokens for
     * @param withDML Whether to perform DML immediately
     * @param logger Logger instance for error logging
     */
    public static void deleteWebhookTokensFromSettings(Set<Id> actionIds, Boolean withDML, Logger logger) {
        if (actionIds == null || actionIds.isEmpty()) {
            return;
        }
        
        for (Id actionId : actionIds) {
            if (String.isNotBlank(actionId)) {
                String tokenType = generateWebhookTokenType(actionId);
                if (String.isNotBlank(tokenType)) {
                    // Get all token records for this action and mark them for deletion
                    List<Graph_API_Token__c> tokenRecords = GraphAPIService.getGraphApiTokenListRecordsByType(tokenType);
                    if (!tokenRecords.isEmpty()) {
                        GraphAPIService.GRAPH_API_LIST_RECORDS_DELETE.addAll(tokenRecords);
                    }
                }
            }
        }
        
        // Only save immediately if withDML is true
        if (withDML) {
            GraphAPIService.saveListTokenRecordSettings(withDML, logger);
        }
    }
    
    /**
     * Custom exception for webhook errors
     */
    public class WebhookException extends Exception {}
}