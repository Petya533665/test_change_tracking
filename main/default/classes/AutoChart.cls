/**
 * AutoChart service for handling automatic chart generation and delivery
 * This class encapsulates all AutoChart-related functionality including:
 * - Chart field detection and extraction
 * - 3-step chart processing workflow
 * - Integration with various messaging platforms
 */
public with sharing class AutoChart {
    public static Boolean isEnabled {
        get {
            return PermissionsUtil.AutoChartEnabled && ConfigUtil.PHAROS_SETTINGS.EnableNotificationCharts__c;
        }
        private set {}
    }
    
    // AutoChart step enum for 3-step processing
    public enum AutoChartStep {
        GET_DATA,      // Step 1: Get data for ALL chart types from reports
        GET_IMAGE,     // Step 2: Get images for ALL charts from Lambda
        SEND_MESSAGE   // Step 3: Send message with ALL charts
    }
    
    /**
     * AutoChart iteration for 3-step chart processing
     * Extends ActionIteration to support chart-specific data
     */
    public class AutoChartIteration extends NotificationService.ActionIteration {
        public List<String> chartTypes;  // All chart types for this record
        public String chartData;         // Combined data for all charts
        public Map<String, String> chartImages; // Images for each chart type
        public AutoChartStep currentStep;
        
        public AutoChartIteration(String recordId, Integer iterationNumber, Integer totalIterations, 
                                 List<String> chartTypes, AutoChartStep step) {
            super(recordId, iterationNumber, totalIterations, 'AUTOCHART', String.join(chartTypes, ','));
            this.chartTypes = chartTypes;
            this.currentStep = step;
        }
    }
    
    /**
     * AutoChart Action Processor for handling 3-step chart processing
     * Coordinates the execution of different AutoChart steps
     */
    public class AutoChartActionProcessor {
        private String recordId;
        private NotificationService.ErrorsHelper logErrors;
        private NotificationService.BatchContextManager batchContextManager;
        
        public AutoChartActionProcessor(String recordId, NotificationService.ErrorsHelper logErrors, NotificationService.BatchContextManager batchContextManager) {
            this.recordId = recordId;
            this.logErrors = logErrors;
            this.batchContextManager = batchContextManager;
            // No need for handlers map - using direct method calls for better performance
        }
        
        public void processAutoChartIteration(AutoChartIteration iteration) {
            try {
                // Direct method calls instead of handler pattern - more efficient!
                switch on iteration.currentStep {
                    when GET_DATA {
                        processDataRetrieval(iteration);
                    }
                    when GET_IMAGE {
                        processImageGeneration(iteration);
                    }
                    when SEND_MESSAGE {
                        processMessageSending(iteration);
                    }
                }
            } catch (Exception e) {
                throw e;
            }
        }
        
        /**
         * Direct method for data retrieval - no handler overhead
         */
        private void processDataRetrieval(AutoChartIteration iteration) {
            AutoChartDataRetrievalHandler handler = new AutoChartDataRetrievalHandler();
            Action__c actionFields = createActionFieldsForIteration(iteration);
            handler.execute(recordId, actionFields, null, batchContextManager);
        }
        
        /**
         * Direct method for image generation - no handler overhead
         */
        private void processImageGeneration(AutoChartIteration iteration) {
            AutoChartImageGenerationHandler handler = new AutoChartImageGenerationHandler();
            Action__c actionFields = createActionFieldsForIteration(iteration);
            handler.execute(recordId, actionFields, null, batchContextManager);
        }
        
        /**
         * Direct method for message sending - no handler overhead
         */
        private void processMessageSending(AutoChartIteration iteration) {
            AutoChartMessageSenderHandler handler = new AutoChartMessageSenderHandler();
            Action__c actionFields = createActionFieldsForIteration(iteration);
            handler.execute(recordId, actionFields, null, batchContextManager);
        }
        
        private Action__c createActionFieldsForIteration(AutoChartIteration iteration) {
            Action__c action = new Action__c();
            // Store chart types in a custom field or use a different approach
            // For now, we'll use the existing fields
            action.Subject__c = 'AutoChart: ' + String.join(iteration.chartTypes, ',');
            action.Body__c = 'Processing charts for types: ' + String.join(iteration.chartTypes, ',');
            return action;
        }
    }
    
    /**
     * AutoChart Data Retrieval Handler - Step 1: Get data for ALL chart types from reports
     */
    public class AutoChartDataRetrievalHandler implements NotificationService.ActionHandler {
        
        public void execute(String recordId, Action__c actionFields, SObject record, NotificationService.BatchContextManager batchContext) {
            try {
                // Get all chart types for this record
                List<String> chartTypes = getChartTypesFromAction(actionFields);
                
                // Step 1: Get data for ALL chart types from reports
                Map<String, Object> parameters = ReportService.parametersBySObjectRecord(record);
                
                Map<ChartService.Chart, Map<ReportService.SystemReport, String>> chartData = 
                    ReportService.getReportDataByChart(chartTypes, parameters);
                
                // Store combined chart data in batchContext for next iteration
                String chartDataJson = JSON.serialize(chartData);
                
                batchContext.storeChartData(recordId, chartDataJson);
                
            } catch (Exception e) {
                throw e;
            }
        }
        
        public void execute(String recordId, Action__c actionFields) {
            execute(recordId, actionFields, null, null);
        }
        
        public void execute(String recordId, Action__c actionFields, SObject record) {
            execute(recordId, actionFields, record, null);
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors) {
            // Handle AutoChart data retrieval exceptions
            throw e; // Re-throw for batch processing
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors, NotificationService.BatchContextManager batchContext) {
            // Handle AutoChart data retrieval exceptions
            throw e; // Re-throw for batch processing
        }
        
        public String getActionType() {
            return 'AUTOCHART_DATA_RETRIEVAL';
        }
    }
    
    /**
     * AutoChart Image Generation Handler - Step 2: Get images for ALL charts from Lambda
     */
    public class AutoChartImageGenerationHandler implements NotificationService.ActionHandler {
        
        public void execute(String recordId, Action__c actionFields, SObject record, NotificationService.BatchContextManager batchContext) {
            try {
                // Get all chart types for this record
                List<String> chartTypes = getChartTypesFromAction(actionFields);
                
                // Retrieve combined chart data from previous iteration
                String chartDataJson = batchContext.getChartData(recordId);
                
                if (String.isBlank(chartDataJson)) {
                    throw new CalloutException('No chart data found for record: ' + recordId);
                }
                
                // Step 2: Get images for ALL charts from Lambda
                ChartGeneratorImageLambdaClient lambdaClient = new ChartGeneratorImageLambdaClient()
                    .generateChartImagesBasedStringChartConfig(chartDataJson);
                
                // Store all chart images in batchContext for next iteration
                Map<String, String> chartImages = new Map<String, String>();
                for (String chartType : chartTypes) {
                    String chartImageBase64 = lambdaClient.getBase64ImageForChart(chartType);
                    chartImages.put(chartType, chartImageBase64);
                }
                
                batchContext.storeChartImages(recordId, chartImages);
                
            } catch (Exception e) {
                throw e;
            }
        }
        
        public void execute(String recordId, Action__c actionFields) {
            execute(recordId, actionFields, null, null);
        }
        
        public void execute(String recordId, Action__c actionFields, SObject record) {
            execute(recordId, actionFields, record, null);
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors) {
            // Handle AutoChart image generation exceptions
            throw e; // Re-throw for batch processing
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors, NotificationService.BatchContextManager batchContext) {
            // Handle AutoChart image generation exceptions
            throw e; // Re-throw for batch processing
        }
        
        public String getActionType() {
            return 'AUTOCHART_IMAGE_GENERATION';
        }
    }
    
    /**
     * AutoChart Message Sending Handler - Step 3: Send message with ALL charts
     * 
     * This handler integrates with existing NotificationService methods to send messages
     * with chart attachments across different platforms:
     * - Slack: Uses NotificationService.sendSlack() with BatchContextManager
     * - Teams: Uses NotificationService.sendTeams() with built-in chart support  
     * - Email: Uses EmailActionHandler for batch email processing
     * - Jira: Uses NotificationService.sendTicketing() via TicketingService
     * - Azure DevOps: Uses NotificationService.sendTicketing() via TicketingService
     * - PagerDuty: Uses NotificationService.sendPagerDuty() (text only, no chart support)
     */
    public class AutoChartMessageSenderHandler implements NotificationService.ActionHandler {
        
        public void execute(String recordId, Action__c actionFields, SObject record, NotificationService.BatchContextManager batchContext) {
            try {
                // Get all chart types for this record
                List<String> chartTypes = getChartTypesFromAction(actionFields);
                
                // Retrieve all chart images from previous iteration
                Map<String, String> chartImages = batchContext.getChartImages(recordId);
                
                if (chartImages == null || chartImages.isEmpty()) {
                    throw new CalloutException('No chart images found for record: ' + recordId);
                }
                
                // Step 3: Send message with ALL charts
                // Detect platform from Action_Type__c field
                String platform = NotificationService.detectPlatformFromActionType(actionFields.Action_Type__c);
                switch on platform {
                    when 'SLACK' {
                        sendSlackMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when 'TEAMS' {
                        sendTeamsMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when 'JIRA' {
                        sendJiraMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when 'AZURE_DEVOPS' {
                        sendAzureDevOpsMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when 'EMAIL' {
                        sendEmailMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when 'PAGERDUTY' {
                        sendPagerDutyMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                    when else {
                        // Default to Slack if platform is not recognized
                        sendSlackMessageWithCharts(recordId, actionFields, chartImages, batchContext);
                    }
                }
                
                // Clean up data from batchContext
                batchContext.clearChartData(recordId);
                batchContext.clearChartImages(recordId);
                
            } catch (Exception e) {
                throw e;
            }
        }
        
        public void execute(String recordId, Action__c actionFields) {
            execute(recordId, actionFields, null, null);
        }
        
        public void execute(String recordId, Action__c actionFields, SObject record) {
            execute(recordId, actionFields, record, null);
        }
        
        private void sendSlackMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // Use existing NotificationService.sendSlack with BatchContextManager for chart support
                // The chart images are already in batchContext from previous step
                SObject record = getRecordById(recordId);
                NotificationService.sendSlack(recordId, actionFields, record, batchContext);
            } catch (Exception e) {
                throw e;
            }
        }
        
        private void sendTeamsMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // Use existing NotificationService.sendTeams 
                // Teams method doesn't have BatchContextManager parameter, but chart logic is built-in
                SObject record = getRecordById(recordId);
                NotificationService.sendTeams(recordId, actionFields, record);
                

            } catch (Exception e) {
                throw e;
            }
        }
        
        private void sendJiraMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // For Jira, we need to use TicketingService which supports chart attachments
                // Create an EventAction for Jira processing
                EventAction__c eventAction = new EventAction__c(
                    Action__c = actionFields.Id,
                    Action_Type__c = actionFields.Action_Type__c,
                    Executed_On__c = System.now()
                );
                
                // Get the action type enum
                RuleUtil.ActionType actionType = RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionFields.Action_Type__c);
                
                if (actionType != null) {
                    SObject record = getRecordById(recordId);
                    Logger logger = Logger.getInstance();
                    
                    // Use existing sendTicketing method which supports charts through TicketingService
                    NotificationService.sendTicketing(actionType, eventAction, logger, record);
                    
                } else {
                    // Unknown action type for Jira
                }
            } catch (Exception e) {
                throw e;
            }
        }
        
        private void sendAzureDevOpsMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // For Azure DevOps, we need to use TicketingService which supports chart attachments
                // Create an EventAction for Azure DevOps processing
                EventAction__c eventAction = new EventAction__c(
                    Action__c = actionFields.Id,
                    Action_Type__c = actionFields.Action_Type__c,
                    Executed_On__c = System.now()
                );
                
                // Get the action type enum
                RuleUtil.ActionType actionType = RuleUtil.MAP_ACTION_TYPES_BY_STRINGS.get(actionFields.Action_Type__c);
                
                if (actionType != null) {
                    SObject record = getRecordById(recordId);
                    Logger logger = Logger.getInstance();
                    
                    // Use existing sendTicketing method which supports charts through TicketingService
                    NotificationService.sendTicketing(actionType, eventAction, logger, record);
                    
                } else {
                    // Unknown action type for Azure DevOps
                }
            } catch (Exception e) {
                throw e;
            }
        }
        
        private void sendEmailMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // Use EmailActionHandler for email notifications
                // Email actions are handled differently - they are collected and sent in batches
                // Charts in emails need special handling through merge field processing
                NotificationService.EmailActionHandler emailHandler = new NotificationService.EmailActionHandler();
                
                SObject record = getRecordById(recordId);
                emailHandler.execute(recordId, actionFields, record, batchContext);
            } catch (Exception e) {
                throw e;
            }
        }
        
        private void sendPagerDutyMessageWithCharts(String recordId, Action__c actionFields, Map<String, String> chartImages, NotificationService.BatchContextManager batchContext) {
            try {
                // Use existing NotificationService.sendPagerDuty
                // Note: PagerDuty doesn't support chart attachments like Slack/Teams
                // Charts are processed but only text content is sent
                NotificationService.sendPagerDuty(recordId, actionFields);
            } catch (Exception e) {
                throw e;
            }
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors) {
            // Handle AutoChart message sending exceptions
            throw e; // Re-throw for batch processing
        }
        
        public void handleException(String recordId, Exception e, NotificationService.ErrorsHelper logErrors, NotificationService.BatchContextManager batchContext) {
            // Handle AutoChart message sending exceptions
            throw e; // Re-throw for batch processing
        }
        
        public String getActionType() {
            return 'AUTOCHART_MESSAGE_SENDING';
        }
    }
    
    /**
     * Utility methods for AutoChart field detection and processing
     */
    
    /**
     * Check if action contains AutoChart merge fields
     * @param action RuleUtil.Action to check
     * @return true if AutoChart fields are found
     */
    public static Boolean containsAutoChartFields(RuleUtil.Action action) {
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return false;
        }
        
        String subject = action.fields?.Subject__c;
        String body = action.fields?.Body__c;
        
        String pattern = '\\{!'+ ChartService.CHART_PREFIX + '\\.[^}]+\\}';
        System.Pattern regex = System.Pattern.compile(pattern);
        
        Boolean subjectContainsChart = String.isNotBlank(subject) && regex.matcher(subject).find();
        Boolean bodyContainsChart = String.isNotBlank(body) && regex.matcher(body).find();
        
        return subjectContainsChart || bodyContainsChart;
    }
    
    /**
     * Extract chart types from action fields
     * @param action RuleUtil.Action to extract from
     * @return List of chart type strings
     */
    public static List<String> extractChartTypesFromAction(RuleUtil.Action action) {
        List<String> chartTypes = new List<String>();
        
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return chartTypes;
        }
        
        String subject = action.fields?.Subject__c;
        String body = action.fields?.Body__c;
        
        String pattern = '\\{!'+ ChartService.CHART_PREFIX + '\\.([^}]+)\\}';
        System.Pattern regex = System.Pattern.compile(pattern);
        
        if (String.isNotBlank(subject)) {
            System.Matcher matcher = regex.matcher(subject);
            while (matcher.find()) {
                String chartType = matcher.group(1);
                chartTypes.add(chartType);
            }
        }
        
        if (String.isNotBlank(body)) {
            System.Matcher matcher = regex.matcher(body);
            while (matcher.find()) {
                String chartType = matcher.group(1);
                chartTypes.add(chartType);
            }
        }
        
        return chartTypes;
    }
    
    /**
     * Parse chart types from action fields (internal method for handlers)
     * @param actionFields Action__c fields
     * @return List of chart type strings
     */
    public static List<String> getChartTypesFromAction(Action__c actionFields) {
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return new List<String>();
        }
        
        // Parse chart types from action fields
        // For now, extract from Subject field as a workaround
        String subject = actionFields.Subject__c;
        if (String.isNotBlank(subject) && subject.startsWith('AutoChart: ')) {
            String chartTypesString = subject.substring('AutoChart: '.length());
            return chartTypesString.split(',');
        }
        return new List<String>();
    }
    
    /**
     * Generate AutoChart iterations for a record
     * @param record SObject record to process
     * @param executableRulesIds List of rule IDs to check
     * @param ruleSobjectType Rule SObject type
     * @return List of AutoChart iterations
     */
    public static List<NotificationService.ActionIteration> getAutoChartIterations(SObject record, List<String> executableRulesIds, String ruleSobjectType) {
        List<NotificationService.ActionIteration> iterations = new List<NotificationService.ActionIteration>();
        
        // Check if AutoChart feature is enabled
        if (!AutoChart.isEnabled) {
            return iterations;
        }
        
        if (executableRulesIds.isEmpty()) {
            return iterations;
        }
        
        // Get notification rules and extract AutoChart actions
        List<RuleUtil.Rule> notificationRules = RuleUtil.getNotificationRules(executableRulesIds, ruleSobjectType);
        
        Integer iterationCounter = 1;
        Integer autoChartActionsFound = 0;
        
        for (RuleUtil.Rule rule : notificationRules) {
            if (rule.actions != null) {
                for (RuleUtil.Action action : rule.actions) {
                    // Check if this action contains AutoChart merge fields
                    if (containsAutoChartFields(action)) {
                        autoChartActionsFound++;
                        List<String> chartTypes = extractChartTypesFromAction(action);
                        
                        // Create iterations for each step of the 3-step process
                        for (AutoChartStep step : AutoChartStep.values()) {
                            iterationCounter++;
                            AutoChartIteration iteration = new AutoChartIteration(
                                (String)record.get('Id'),
                                iterationCounter,
                                0, // Will be set later
                                chartTypes,
                                step
                            );
                            iterations.add(iteration);
                        }
                    }
                }
            }
        }
        
        // Set total iterations for all
        Integer totalIterations = iterations.size() + 1; // +1 for precalculation iteration
        for (NotificationService.ActionIteration iteration : iterations) {
            iteration.totalIterations = totalIterations;
        }
        
        return iterations;
    }
    
    /**
     * Remove AutoChart merge fields from content and return cleaned content with extracted fields
     * @param content String content to process
     * @return AutoChartFieldsResult with cleaned content and extracted fields
     */
    public static AutoChartFieldsResult removeAutoChartMergeFieldsWithList(String content) {
        if (String.isBlank(content)) return new AutoChartFieldsResult(new List<String>(), new List<String>());
        String pattern = '\\{!'+ ChartService.CHART_PREFIX + '\\.[^}]+\\}';
        List<String> found = new List<String>();
        System.Pattern regex = System.Pattern.compile(pattern);
        System.Matcher matcher = regex.matcher(content);
        while (matcher.find()) {
            String fullMatch = matcher.group();
            // Remove {! and } to get just the field name
            String cleanedField = fullMatch.removeStart('{!').removeEnd('}');
            // Extract only the part after the dot (the actual chart field name)
            if (cleanedField.contains('.')) {
                cleanedField = cleanedField.substringAfter('.');
            }
            found.add(cleanedField);
        }
        String cleaned = content;
        for (String match : found) {
            // Add back the {! and } for replacement since we need the full pattern
            String fullPattern = '{!' + ChartService.CHART_PREFIX + '.' + match + '}';
            cleaned = cleaned.replace(fullPattern, '');
        }
        return new AutoChartFieldsResult(new List<String>{cleaned}, found);
    }
    
    /**
     * Process multiple messages and extract AutoChart fields
     * @param mergedMessages List of messages to process
     * @return AutoChartFieldsResult with cleaned messages and extracted fields
     */
    public static AutoChartFieldsResult getChartFieldsAndClear(List<String> mergedMessages) {
        List<String> cleanedMessages = new List<String>();
        List<String> autoChartFieldsList = new List<String>();

        if (mergedMessages != null) {
            for (String message : mergedMessages) {
                if (String.isNotBlank(message)) {
                    AutoChartFieldsResult acResult = removeAutoChartMergeFieldsWithList(message);
                    cleanedMessages.addAll(acResult.cleanedMessages);
                    autoChartFieldsList.addAll(acResult.autoChartFields);
                } else {
                    cleanedMessages.add(message);
                }
            }
        }

        return new AutoChartFieldsResult(cleanedMessages, autoChartFieldsList);
    }
    
    /**
     * Helper method to get SObject record by ID
     * Determines the SObject type and queries the record
     * 
     * @param recordId The record ID to query
     * @return SObject record or null if not found
     */
    private static SObject getRecordById(String recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }
        
        try {
            String keyPrefix = recordId.substring(0, 3);
            
            // Check common types
            if (keyPrefix == Log__c.SObjectType.getDescribe().getKeyPrefix()) {
                return [SELECT Id FROM Log__c WHERE Id = :recordId LIMIT 1];
            } else if (keyPrefix == Issue__c.SObjectType.getDescribe().getKeyPrefix()) {
                return [SELECT Id FROM Issue__c WHERE Id = :recordId LIMIT 1];
            } else if (keyPrefix == Trace_Result__c.SObjectType.getDescribe().getKeyPrefix()) {
                return [SELECT Id FROM Trace_Result__c WHERE Id = :recordId LIMIT 1];
            } else if (keyPrefix == EventAction__c.SObjectType.getDescribe().getKeyPrefix()) {
                return [SELECT Id FROM EventAction__c WHERE Id = :recordId LIMIT 1];
            }
            
            // If unknown type, return null
            return null;
            
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Result class for AutoChart field processing
     */
    public class AutoChartFieldsResult {
        public List<String> cleanedMessages;
        public List<String> autoChartFields;
        
        public AutoChartFieldsResult(List<String> cleanedMessages, List<String> autoChartFields) {
            this.cleanedMessages = cleanedMessages;
            this.autoChartFields = autoChartFields;
        }
    }
}