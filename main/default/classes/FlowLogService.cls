public class FlowLogService {

    public class FlowLoggingException extends Exception {}

    @TestVisible
    private static boolean enableTruncateElementName = !Test.isRunningTest();
    private static final String FLOW_METADATA_VERSION = '63.0';
    private static final String TRITON_ACTION_TYPE = 'apex';
    private static final String TRITON_ACTION_NAME = 'TritonFlow';
    private static final String TRITON_ACTION_NAMESPACE = ConfigUtil.currentOrgNameSpacePrefix;
    //'orgnamespaceprefix__TritonFlow';
    private static final String TRITON_LOG_ACTION_NAME = (String.isNotBlank(TRITON_ACTION_NAMESPACE)) ? TRITON_ACTION_NAMESPACE + '__' + TRITON_ACTION_NAME : TRITON_ACTION_NAME;
    private static final String TRITON_LOG_ACTION_TYPE = 'apex';

    private static final String PHAROS_TEMPLATE_MARKER = '_Pharos_Template';
    @TestVisible
    private static final String PHAROS_VARIABLE_NAME = 'Pharos_Full_Stacktrace';
    private static final String PHAROS_VARIABLE_LABEL = 'Pharos Full Stacktrace';

    private static final String LOGGER_INPUT_PARAMETER_FULL_STACKTRACE_NAME = 'fullStacktrace';
    private static final String LOGGER_INPUT_PARAMETER_CATEGORY_NAME = 'category';
    @TestVisible
    private static final String LOGGER_INPUT_PARAMETER_CATEGORY_DEFAULT_VALUE = 'Flow';
    private static final String LOGGER_INPUT_PARAMETER_TYPE_NAME = 'type';
    @TestVisible
    private static final String LOGGER_INPUT_PARAMETER_TYPE_DEFAULT_VALUE = 'Flow';
    private static final String LOGGER_INPUT_PARAMETER_AREA_NAME = 'area';
    private static final String LOGGER_INPUT_PARAMETER_SUMMARY_NAME = 'summary';
    private static final String LOGGER_INPUT_PARAMETER_DETAILS_NAME = 'details';
    private static final String LOGGER_INPUT_PARAMETER_STACKTRACE_NAME = 'stacktrace';
    private static final String LOGGER_INPUT_PARAMETER_GUID_NAME = 'interviewGUID';
    private static final String LOGGER_INPUT_PARAMETER_FLOW_API_NAME = 'flowApiName';
    private static final String LOGGER_INPUT_PARAMETER_LEVEL_NAME = 'level';
    private static final String LOGGER_INPUT_PARAMETER_OPERATION_NAME = 'operation';

    private static final String LOGGER_OUTPUT_PARAMETER_FULL_STACKTRACE_NAME = 'fullStacktrace';

    private static final String END_MARKER = 'END';
    @TestVisible
    private static final String PRE_LOG_MARKER = '_PreLog';
    @TestVisible
    private static final String POST_LOG_MARKER = '_PostLog';
    @TestVisible
    private static final String POST_PRE_LOG_MARKER = '_PostPreLog';
    private static final String LOG_ELEMENT_HASH_MARKER = 'h_';

    private static final String ELEMENT_CONNECTION_FAULT_MARKER = '_FAULT';
    private static final String ELEMENT_CONNECTION_NOMORE_MARKER = '_NOMORE';

    private static final String ELEMENT_TYPE_ASSIGNMENT = 'Assignment';
    private static final String ELEMENT_TYPE_ACTION_CALL = 'Action';
    private static final String ELEMENT_TYPE_DECISION = 'Decision';
    private static final String ELEMENT_TYPE_LOOP = 'Loop';
    private static final String ELEMENT_TYPE_RECORD_CREATE = 'Record Create';
    private static final String ELEMENT_TYPE_RECORD_UPDATE = 'Record Update';
    private static final String ELEMENT_TYPE_RECORD_DELETE = 'Record Delete';
    private static final String ELEMENT_TYPE_RECORD_LOOKUP = 'Record Lookup';
    private static final String ELEMENT_TYPE_RECORD_ROLLBACK = 'Record Rollback';
    private static final String ELEMENT_TYPE_SUBFLOW = 'Subflow';
    private static final String ELEMENT_TYPE_SCREEN = 'Screen';
    private static final String ELEMENT_TYPE_START = 'Start';
    private static final String ELEMENT_TYPE_SCHEDULED_PATH = 'Scheduled Path';
    private static final String ELEMENT_TYPE_FAULT = 'Fault';
    private static final String ELEMENT_TYPE_DECISION_RULE = 'Decision Rule';
    private static final String ELEMENT_TYPE_WAIT = 'Wait';
    private static final String ELEMENT_TYPE_WAIT_EVENT = 'Wait Event';
    private static final String ELEMENT_TYPE_COLLECTION_PROCESSOR = 'Collection Processor';
    private static final String ELEMENT_TYPE_FORMULA = 'Formula';
    private static final String ELEMENT_TYPE_APEX_PLUGIN = 'Apex Plugin';
    private static final String ELEMENT_TYPE_CUSTOM_ERROR = 'Custom Error';
    private static final String ELEMENT_TYPE_TRANSFORM = 'Transform';
    private static final String ELEMENT_TYPE_CHOICE = 'Choice';
    private static final String ELEMENT_TYPE_ORCHESTRATED_STAGE = 'Orchestrated Stage';
    private static final String ELEMENT_TYPE_STAGE_STEP = 'Stage Step';
    private static final String ELEMENT_TYPE_CONSTANT = 'Constant';


    // Log levels mapping
    private static final Map<String, String> ELEMENT_LOG_LEVELS = new Map<String, String>{
        ELEMENT_TYPE_START                => 'INFO',
        ELEMENT_TYPE_SCHEDULED_PATH       => 'INFO',
        ELEMENT_TYPE_DECISION             => 'DEBUG',
        ELEMENT_TYPE_DECISION_RULE        => 'DEBUG',
        ELEMENT_TYPE_SCREEN               => 'DEBUG',
        ELEMENT_TYPE_RECORD_CREATE        => 'DEBUG',
        ELEMENT_TYPE_RECORD_UPDATE        => 'DEBUG',
        ELEMENT_TYPE_RECORD_DELETE        => 'DEBUG',
        ELEMENT_TYPE_RECORD_LOOKUP        => 'DEBUG',
        ELEMENT_TYPE_ACTION_CALL          => 'DEBUG',
        ELEMENT_TYPE_SUBFLOW              => 'DEBUG',
        ELEMENT_TYPE_FAULT                => 'WARNING',
        ELEMENT_TYPE_CUSTOM_ERROR         => 'ERROR',
        ELEMENT_TYPE_ASSIGNMENT           => 'FINER',
        ELEMENT_TYPE_LOOP                 => 'FINER',
        ELEMENT_TYPE_WAIT                 => 'FINER',
        ELEMENT_TYPE_WAIT_EVENT           => 'FINER',
        ELEMENT_TYPE_COLLECTION_PROCESSOR => 'FINER',
        ELEMENT_TYPE_FORMULA              => 'FINER',
        ELEMENT_TYPE_APEX_PLUGIN          => 'FINER',
        ELEMENT_TYPE_TRANSFORM            => 'FINER',
        ELEMENT_TYPE_CHOICE               => 'FINER',
        ELEMENT_TYPE_ORCHESTRATED_STAGE   => 'FINER',
        ELEMENT_TYPE_STAGE_STEP           => 'FINER',
        ELEMENT_TYPE_CONSTANT             => 'FINER'
    };

    private static final String VISUALISATION_NEXT_VALUE = 'Next Value';
    private static final String VISUALISATION_NEXT_VALUE_TARGET = 'Next:';
    private static final String VISUALISATION_NO_MORE_VALUES = 'No More Values';
    private static final String VISUALISATION_NO_MORE_VALUES_TARGET = 'NoMore:';
    private static final String VISUALISATION_DEFAULT_TARGET = 'DEFAULT:';

    public static final String INPUT_PARAMETER_OPERATION = 'operation';
    public static final String INPUT_PARAMETER_FLOW_API_NAME = 'flowApiName';
    public static final String INPUT_PARAMETER_FUNCTIONAL_AREA = 'functionalArea';
    public static final String INPUT_PARAMETER_VERSION_INFO = 'versionInfo';
    public static final String INPUT_PARAMETER_FLOW_TYPE = 'flowType';

    public static final String ERROR_OPERATION_AND_FLOW_API_NAME_REQUIRED = 'Operation and Flow API Name are required';
    public static final String ERROR_INVALID_OPERATION = 'Invalid operation: ';
    public static final String ERROR_FLOW_NOT_FOUND = 'Flow not found: ';
    public static final String ERROR_FUNCTIONAL_AREA_REQUIRED_FOR_ADDING_LOGGING = 'Functional area is required for adding logging';
    public static final String ERROR_NO_RESULTS_FROM_UPSERT = 'No results returned from upsert operation';
    public static final String ERROR_NO_RESULTS_FROM_UPDATE = 'No results returned from update operation';
    public static final String ERROR_UNKNOWN_OPERATION = 'Unknown operation';
    public static final String ERROR_TRITON_ACTION_NOT_AVAILABLE = 'Triton logging actions are not available';
    public static final String ERROR_NO_FLOW_ELEMENTS_TO_PROCESS = 'No flow elements found to process';
    public static final String ERROR_FAILED_TO_ADD_LOGGING = 'Failed to add logging: ';
    public static final String ERROR_FAILED_TO_REMOVE_LOGGING = 'Failed to remove logging: ';
    public static final String ERROR_UNEXPECTED_EXCEPTION = 'Unexpected exception: ';
    public static final String ERROR_FLOW_IS_ACTIVE = 'Flow is active, use NEW_VERSION to create a new version';
    public static final String ERROR_INVALID_FLOW_API_NAME = 'Invalid flow API name: ';
    public static final String ERROR_INVALID_VERSION_TYPE = 'Invalid version type: ';

    public static final String OUTPUT_PARAMETER_SUCCESS = 'success';
    public static final String OUTPUT_PARAMETER_MESSAGE = 'message';
    public static final String OUTPUT_PARAMETER_FLOW_API_NAME = 'flowApiName';
    public static final String OUTPUT_PARAMETER_NEW_VERSION_NUMBER = 'newVersionNumber';
    public static final String OUTPUT_PARAMETER_FLOW_VISUALISATION = 'flowVisualization';
    public static final String OUTPUT_PARAMETER_FLOW_VISUALISATION_BEFORE = 'before';
    public static final String OUTPUT_PARAMETER_FLOW_VISUALISATION_AFTER = 'after';
    public static final String OUTPUT_PARAMETER_WARNINGS = 'warnings';
    public static final String OUTPUT_PARAMETER_MESSAGE_SUCCESSFULLY_ADDED_LOGGING = 'Successfully added logging';
    public static final String OUTPUT_PARAMETER_MESSAGE_SUCCESSFULLY_REMOVED_LOGGING = 'Successfully removed logging';

    private static final String VERSION_NUMBER_SEPARATOR = '-';
    private static final String SOURCE_INFO_KEY = 'Source';
    private static final String TARGET_INFO_KEY = 'Target';
    private static final String SOURCE_TARGET_INFO_REGEX = 'Source:([^,]+),([^,]+),([^|]+)\\|Target:([^,]+),([^,]+),([^|]+)';
    private static final String SOURCE_TARGET_INFO_FORMAT ='Source:{0},{1},{2}|Target:{3},{4},{5}';
    private static final String SOURCE_INFO_EMPTY_VALUE = 'null';
    private static final String SOURCE_INFO_SEPARATOR = '\\:';
    private static final String SOURCE_INFO_CONNECTION_SEPARATOR = '\\.';
    private static final String FLOW_VERSION_STATUS_DRAFT = 'Draft';
    private static final String FLOW_VERSION_STATUS_ACTIVE = 'Active';
    private static final String FLOW_VERSION_STATUS_OBSOLETE = 'Obsolete';
    private static final String FLOW_VERSION_INVALID_DRAFT = 'InvalidDraft';

    private static final String LOG_LABEL_AFTER_BEFORE_FORMAT = 'Log After: {0}, Before: {1}';
    private static final String LOG_LABEL_AFTER_FORMAT = 'Log After: {0}';
    private static final String LOG_LABEL_BEFORE_FORMAT = 'Log Before: {0}';


    public enum Operation {
        ADD_LOGGING,    // add logging to the flow
        REMOVE_LOGGING  // remove logging from the flow
    }

    public enum VersionType {
        NEW_VERSION,    // create a new version,
        CURRENT_VERSION // update the current version
    }

    public class FlowLoggingContext {
        public final MetadataService.Flow flow;
        public final Map<String, FlowElement> flowElements;
        public final String functionalArea;
        public final String flowType;
        public String beforeVisualization;
        public String afterVisualization;
        public final Set<String> processedElements;
        public final List<String> errors;
        public Set<String> connectedElements;
        public final Integer version;
        public final VersionType versionType;

        public final Integer newVersionNumber;
        public final String updatedFlowName;

        public final Map<String, String> subflowsInfo;

        public FlowLoggingContext(MetadataService.Flow flow, 
                                Map<String, FlowElement> flowElements,
                                String functionalArea,
                                Integer version,
                                VersionType versionType,
                                String flowType,
                                Map<String, String> subflowsInfo) {
            this.flow = flow;
            this.flowElements = flowElements;
            this.functionalArea = functionalArea;
            this.beforeVisualization = '';
            this.afterVisualization = '';
            this.errors = new List<String>();
            this.connectedElements = new Set<String>();
            this.version = version;
            this.versionType = versionType;
            this.flowType = flowType;
            this.subflowsInfo = subflowsInfo;

            if(versionType == FlowLogService.VersionType.NEW_VERSION) {
                Integer maxCreatedVersion = getMaxCreatedVersion(flow.fullName);
                this.newVersionNumber = maxCreatedVersion + 1;
                this.updatedFlowName = updateFlowNameWithVersion(flow.fullName, this.newVersionNumber);
            }
            else {
                this.newVersionNumber = version;
                this.updatedFlowName = flow.fullName;
            }
        }
    }

    private static Integer getMaxCreatedVersion(String flowApiName) {
        String flowName = extractFlowName(flowApiName);
        if (String.isBlank(flowName)) return 1;

        List<FlowVersionView> flowVersions = [
            SELECT Id, VersionNumber 
            FROM FlowVersionView
            WHERE FlowDefinitionView.ApiName = :flowName
            ORDER BY VersionNumber DESC
            LIMIT 1
        ];
        return flowVersions?.isEmpty() ? 1 : flowVersions[0].VersionNumber;
    }

    private static String extractFlowName(String flowFullName) {
        List<String> parts = flowFullName?.split(VERSION_NUMBER_SEPARATOR);
        if (parts?.size() == 2) {
            if (parts[0].contains('__')) {
                return parts[0].substringAfterLast('__');
            }
            return parts[0];
        }
        return null;
    }

    private static Integer extractVersionFromFlowApiName(String flowApiName) {
        if (String.isBlank(flowApiName)) return null;
        
        List<String> parts = flowApiName.split(VERSION_NUMBER_SEPARATOR);
        if (parts.size() != 2) return null;
        
        try {
            return Integer.valueOf(parts[1]);
        }
        catch (Exception e) {
            return null;
        }
    }

    private static String updateFlowNameWithVersion(String flowApiName, Integer newVersion) {
        if (String.isBlank(flowApiName)) return flowApiName;
        
        // If flow name already has version, replace it
        if (flowApiName.contains(VERSION_NUMBER_SEPARATOR)) {
            return flowApiName.substringBeforeLast(VERSION_NUMBER_SEPARATOR) + VERSION_NUMBER_SEPARATOR + newVersion;
        }
        
        // If no version exists, append it
        return flowApiName + VERSION_NUMBER_SEPARATOR + newVersion;
    }


    /**
     * Main method to invoke the Flow Log Service
     * @param params Map containing the following parameters:
     *   - operation: String (ADD_LOGGING or REMOVE_LOGGING)
     *   - flowApiName: String (API name of the flow to modify)
     *   - functionalArea: String (functional area for logging)
     *   - versionInfo: String (whether to create new version or use existing inactive latest version)
     * @return Map<String, Object> containing:
     *   - success: Boolean (whether operation was successful)
     *   - message: String (success/error message)
     *   - flowApiName: String (API name of the modified flow)
     *   - newVersionNumber: String (version number of the modified flow)
     */
    public Map<String, Object> invoke(Map<String, Object> params) {
        try {
            // Validate and extract parameters
            String operationStr = (String)params.get(INPUT_PARAMETER_OPERATION);
            String flowApiName = (String)params.get(INPUT_PARAMETER_FLOW_API_NAME);
            String functionalArea = (String)params.get(INPUT_PARAMETER_FUNCTIONAL_AREA);
            String versionInfo = (String)params.get(INPUT_PARAMETER_VERSION_INFO);
            String flowType = (String)params.get(INPUT_PARAMETER_FLOW_TYPE);

            if (String.isBlank(operationStr) || String.isBlank(flowApiName)) {
                return buildError(ERROR_OPERATION_AND_FLOW_API_NAME_REQUIRED);
            }

            // Parse operation
            Operation operation;
            try {
                operation = FlowLogService.Operation.valueOf(operationStr.toUpperCase());
            }
            catch(Exception e) {
                return buildError(ERROR_INVALID_OPERATION + operationStr);
            }

            // Extract version from flow API name
            Integer version = extractVersionFromFlowApiName(flowApiName);
            if (version == null) {
                return buildError(ERROR_INVALID_FLOW_API_NAME + flowApiName);
            }

            // Get flow metadata
            MetadataService.Flow flow = getFlowMetadata(flowApiName);
            if (flow == null) {
                return buildError(ERROR_FLOW_NOT_FOUND + flowApiName);
            }

            // Get subflows info map ApiName -> VersionNumber
            Map<String, String> subflowsInfo = getSubflowsInfo(flow);

            // Parse version type
            FlowLogService.VersionType versionType;
            try {
                versionType = FlowLogService.VersionType.valueOf(versionInfo.toUpperCase());
            }
            catch(Exception e) {
                return buildError(ERROR_INVALID_VERSION_TYPE + versionInfo);
            }
            
            // Check if flow is active or obsolete or invalid draft and version type is CURRENT_VERSION
            // Only allow CURRENT_VERSION if the flow in Draft status
            if((flow.status == FLOW_VERSION_STATUS_ACTIVE || flow.status == FLOW_VERSION_STATUS_OBSOLETE || flow.status == FLOW_VERSION_INVALID_DRAFT) 
                && versionType == FlowLogService.VersionType.CURRENT_VERSION) {
                
                return buildError(ERROR_FLOW_IS_ACTIVE);
            }            

            // Create flow elements map for easier access
            Map<String, FlowLogService.FlowElement> flowElements = convertMetadataFlowToElements(flow);

            // Visualize the flow before logging is added
            FlowLoggingContext context = new FlowLoggingContext(flow, flowElements, functionalArea, version, versionType, flowType, subflowsInfo);
            // Build connected elements set
            buildConnectedElements(context);

            context.beforeVisualization = visualizeFlow(context);

            switch on operation {
                when ADD_LOGGING {
                    if (String.isBlank(functionalArea)) {
                        return buildError(ERROR_FUNCTIONAL_AREA_REQUIRED_FOR_ADDING_LOGGING);
                    }
                    return handleAddLogging(context);
                }
                when REMOVE_LOGGING {
                    return handleRemoveLogging(context);
                }
            }

            return buildError(ERROR_UNKNOWN_OPERATION);
        }
        catch(Exception e) {
            return buildError(ERROR_UNEXPECTED_EXCEPTION + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    /**
     * Handles the add logging operation
     * @param context The flow logging context
     * @return The result map
     */
    private Map<String, Object> handleAddLogging(FlowLoggingContext context) {
        
        try {
            // Validate prerequisites
            validatePrerequisites(context);
                        
            try {
                // remove all logging elements from the flow
                if(flowHasLoggingElements(context)) {
                    removeLoggingElements(context.flow, context.flowElements);
                    mergeLogElementsIntoFlow(context);
                    buildConnectedElements(context);
                }
                
                // Update Flow structure with logging elements
                addLogElementToFlow(context);               

                // Merge logging elements back into the original flow
                mergeLogElementsIntoFlow(context);

                // Save visualization
                context.afterVisualization = visualizeFlow(context);

                // Handle the update flow
                handleUpdateFlow(context);               

                return buildVisualizationResult(context, OUTPUT_PARAMETER_MESSAGE_SUCCESSFULLY_ADDED_LOGGING);
            }
            catch(Exception e) {
                throw e;
            }
        } 
        catch(Exception e) {
            return buildError(ERROR_FAILED_TO_ADD_LOGGING + e.getMessage());
        }
    }    

    private void buildConnectedElements(FlowLoggingContext context) {
        // Find start element and build connected elements set
        FlowElement startElement = findStartElement(context?.flowElements);
        Set<String> connectedElements = new Set<String>();
        if (startElement != null) {
            buildConnectedElementsSet(startElement, context?.flowElements, connectedElements);
            context.connectedElements = connectedElements;
        }
    }

    /**
     * Handles the remove logging operation
     * @param context The flow logging context
     * @return The result map
     */
    private Map<String, Object> handleRemoveLogging(FlowLoggingContext context) {
        try {
            // Save visualization before changes
            context.beforeVisualization = visualizeFlow(context);
            
            // Remove logging elements and restore original connections
            removeLoggingElements(context.flow, context.flowElements);
            
            // Merge changes back into the flow
            mergeLogElementsIntoFlow(context);

            // Save visualization after changes
            context.afterVisualization = visualizeFlow(context);

            // Handle the update flow
            handleUpdateFlow(context);
            
            return buildVisualizationResult(context, OUTPUT_PARAMETER_MESSAGE_SUCCESSFULLY_REMOVED_LOGGING);
        } 
        catch(Exception e) {
            return buildError(ERROR_FAILED_TO_REMOVE_LOGGING + e.getMessage());
        }
    }

    private Boolean flowHasLoggingElements(FlowLoggingContext context) {
        if(context?.flowElements != null) {
            for (String elementName : context?.flowElements?.keySet()) {
                if (isLoggingElement(elementName)) {
                    return true;
                }
            }
        }
        if(context?.flow?.textTemplates != null) {
            for (MetadataService.FlowTextTemplate textTemplate : context.flow.textTemplates) {
                if (textTemplate.name.endsWith(PHAROS_TEMPLATE_MARKER)) {
                    return true;
                }
            }
        }
        if(context?.flow?.variables != null) {
            for (MetadataService.FlowVariable variable : context.flow.variables) {
                if (variable.name.equalsIgnoreCase(PHAROS_VARIABLE_NAME)) {
                    return true;
                }
            }
        }
        return false;
    }

    private void handleUpdateFlow(FlowLoggingContext context) {
        if(context == null || context?.flow == null) {
            return;
        }
        // Set updated flow metadata to Draft and update full name with new version number
        context.flow.status = FLOW_VERSION_STATUS_DRAFT;
        context.flow.fullName = context?.updatedFlowName;
        // force the canvas mode to AUTO_LAYOUT_CANVAS
        updateFlowCanvasMode(context);

        if(context?.version != context?.newVersionNumber) {
            // Upsert the flow and handle the SOAP UpsertResult
            List<MetadataService.UpsertResult> results = upsertFlow(context?.flow);
            handleUpsertResults(results);
        }
        else {
            // Update the flow and handle the SOAP UpdateResult
            List<MetadataService.SaveResult> results = updateFlow(context.flow);
            handleSaveResults(results);
        }
    }

    private void updateFlowCanvasMode(FlowLoggingContext context) {
        if (context?.flow?.processMetadataValues != null) {
            for (MetadataService.FlowMetadataValue metadataValue : context.flow.processMetadataValues) {
                if (metadataValue.name == 'CanvasMode') {
                    metadataValue.value = new MetadataService.FlowElementReferenceOrValue();
                    metadataValue.value.stringValue = 'AUTO_LAYOUT_CANVAS';
                }
            }
        }
    }

    /**
     * Removes logging elements from the flow and restores original connections
     * @param flow The flow to update
     * @param flowElements The map of flow elements
     */
    private void removeLoggingElements(MetadataService.Flow flow, Map<String, FlowElement> flowElements) {
        // First collect all logging elements
        Set<String> loggingElements = new Set<String>();        
        for (String elementName : flowElements.keySet()) {
            if (isLoggingElement(elementName)) {
                loggingElements.add(elementName);
            }
        }

        for (String elementName : flowElements.keySet()) {
            if (isLoggingElement(elementName)) {
                loggingElements.add(elementName);
            }
            else {
                FlowElement element = flowElements.get(elementName);
                restoreElementConnections(element, flowElements);   
            }
        }
                
        // Finally remove all logging elements
        for (String loggingElement : loggingElements) {
            flowElements.remove(loggingElement);
        }

        // Remove action calls that are logging elements
        List<MetadataService.FlowActionCall> actionCallsWithoutLogging = new List<MetadataService.FlowActionCall>();
        if (flow.actionCalls == null) {
            flow.actionCalls = new List<MetadataService.FlowActionCall>();
        }
        for (MetadataService.FlowActionCall actionCall : flow.actionCalls) {
            if (!loggingElements.contains(actionCall.name)) {
                actionCallsWithoutLogging.add(actionCall);
            }
        }
        flow.actionCalls = actionCallsWithoutLogging;
    }
    
    private Map<String, String> getSubflowsInfo(MetadataService.Flow flow) {
        Map<String, String> subflows = new Map<String, String>();
        Set<String> subflowNames = new Set<String>();
        if(flow?.subflows != null) {
            for (MetadataService.FlowSubflow subflow : flow.subflows) {
                subflows.put(subflow.flowName, '');
                subflowNames.add(subflow.flowName.substringAfterLast('__'));
            }
        }

        if (!subflows.isEmpty()) {
            for (FlowDefinitionView flowDefinition : [SELECT ApiName, VersionNumber, NamespacePrefix FROM FlowDefinitionView WHERE ApiName IN :subflowNames]) {
                if(flowDefinition.NamespacePrefix != null) {
                    subflows.put(flowDefinition.NamespacePrefix + '__' + flowDefinition.ApiName, String.valueOf(flowDefinition.VersionNumber));
                }
                else {
                    subflows.put(flowDefinition.ApiName, String.valueOf(flowDefinition.VersionNumber));
                }
            }
        }
        return subflows;
    }

    /**
     * Recursively builds a set of elements connected to the start element
     * @param currentElement Current element being processed
     * @param flowElements Map of all flow elements
     * @param connectedElements Set to store connected element names
     */
    @TestVisible
    private void buildConnectedElementsSet(FlowElement currentElement, 
        Map<String, FlowElement> flowElements, 
        Set<String> connectedElements) {
        
        if (currentElement == null || connectedElements.contains(currentElement.getName())) {
            return;
        }

        connectedElements.add(currentElement.getName());

        // Follow standard target reference
        String target = currentElement.getTargetReference();
        if (target != null && flowElements.containsKey(target)) {
            buildConnectedElementsSet(flowElements.get(target), flowElements, connectedElements);
        }

        String faultElementTarget = currentElement.getFaultTarget();
        if (currentElement.hasFaultTarget() && faultElementTarget != null && flowElements.containsKey(faultElementTarget)) {
            connectedElements.add(currentElement.getName() + ELEMENT_CONNECTION_FAULT_MARKER);
            buildConnectedElementsSet(flowElements.get(faultElementTarget), flowElements, connectedElements);
        }
        
        // Follow scheduled paths
        if (currentElement.getType() == ELEMENT_TYPE_START) {
            if (currentElement.getScheduledPaths() != null && !currentElement.getScheduledPaths().isEmpty()) {
                for (FlowElement path : currentElement.getScheduledPaths().values()) {
                    if (String.isNotBlank(path.getTargetReference())) {
                        buildConnectedElementsSet(path, flowElements, connectedElements);
                    }
                }
            }
        }

        // Follow decision paths
        if (currentElement.getType() == ELEMENT_TYPE_DECISION) {
            // Follow default path
            String defaultTarget = currentElement.getDefaultTarget();
            if (defaultTarget != null && flowElements.containsKey(defaultTarget)) {
                buildConnectedElementsSet(flowElements.get(defaultTarget), flowElements, connectedElements);
            }

            // Follow rule paths
            if (currentElement.getRules() != null) {
                for (FlowElement rule : currentElement.getRules().values()) {
                    String ruleTarget = rule.getTargetReference();
                    if (ruleTarget != null && flowElements.containsKey(ruleTarget)) {
                        buildConnectedElementsSet(flowElements.get(ruleTarget), flowElements, connectedElements);
                    }
                }
            }
        }
        if (currentElement.getType() == ELEMENT_TYPE_WAIT) {
            String waitTarget = currentElement.getDefaultTarget();
            if (waitTarget != null && flowElements.containsKey(waitTarget)) {
                buildConnectedElementsSet(flowElements.get(waitTarget), flowElements, connectedElements);
            }

            String faultTarget = currentElement.getFaultTarget();
            if (faultTarget != null && flowElements.containsKey(faultTarget)) {
                connectedElements.add(currentElement.getName() + ELEMENT_CONNECTION_FAULT_MARKER);
                buildConnectedElementsSet(flowElements.get(faultTarget), flowElements, connectedElements);
            }

            if (currentElement.getEvents() != null) {
                for (FlowElement event : currentElement.getEvents().values()) {
                    String eventTarget = event.getTargetReference();
                    if (eventTarget != null && flowElements.containsKey(eventTarget)) {
                        buildConnectedElementsSet(flowElements.get(eventTarget), flowElements, connectedElements);
                    }
                }
            }
        }

        // Follow loop paths
        if (currentElement.getType() == ELEMENT_TYPE_LOOP) {
            // Follow Next Value path
            String nextTarget = currentElement.getNextValueTarget();
            if (nextTarget != null && flowElements.containsKey(nextTarget)) {
                buildConnectedElementsSet(flowElements.get(nextTarget), flowElements, connectedElements);
            }

            // Follow No More Values path
            String noMoreTarget = currentElement.getNoMoreValuesTarget();
            if (noMoreTarget != null && flowElements.containsKey(noMoreTarget)) {
                connectedElements.add(currentElement.getName() + ELEMENT_CONNECTION_NOMORE_MARKER);
                buildConnectedElementsSet(flowElements.get(noMoreTarget), flowElements, connectedElements);
            }
        }
    }

    /**
     * Parses the log element description to extract source and target information
     * @param description The element description
     * @return Map containing Source and Target information with coordinates
     */
    private Map<String, ElementInfo> parseLogElementDescription(String description) {
        if (String.isBlank(description)) return null;
        
        Map<String, ElementInfo> result = new Map<String, ElementInfo>();
        
        // Updated regex to capture name and coordinates
        Pattern p = Pattern.compile(SOURCE_TARGET_INFO_REGEX);
        Matcher m = p.matcher(description);
        
        if (m.find()) {
            // Source element info
            ElementInfo sourceInfo = new ElementInfo();
            String sourceName = m.group(1) == SOURCE_INFO_EMPTY_VALUE ? null : m.group(1);
            
            if(sourceName.contains('.')) {
                String[] parts = sourceName.split('\\.');                
                sourceInfo.name = parts[0];
                sourceInfo.connectionName = parts[1];
            }
            else if(sourceName.contains(':')) {
                String[] parts = sourceName.split('\\:');
                sourceInfo.name = parts[1];
                sourceInfo.parentName = parts[0];
            }
            else {
                sourceInfo.name = sourceName;
            }
            sourceInfo.y = Integer.valueOf(m.group(2));
            sourceInfo.x = Integer.valueOf(m.group(3));
            result.put(SOURCE_INFO_KEY, sourceInfo);
            
            // Target element info
            ElementInfo targetInfo = new ElementInfo();
            targetInfo.name = m.group(4) == SOURCE_INFO_EMPTY_VALUE ? null : m.group(4);
            targetInfo.y = Integer.valueOf(m.group(5));
            targetInfo.x = Integer.valueOf(m.group(6));
            result.put(TARGET_INFO_KEY, targetInfo);
        }
        
        return result;
    }

    /**
     * Inner class to hold element information including coordinates
     */
    private class ElementInfo {
        public String name;
        public String parentName;
        public String connectionName;
        public Integer x;
        public Integer y;
    }

    private static FlowElement getLastLoggingElement(String target, Map<String, FlowElement> flowElements) {
        if (String.isBlank(target)) return null;
        
        Set<String> visitedElements = new Set<String>();
        String currentTarget = target;

        while (currentTarget != null && !visitedElements.contains(currentTarget)) {
            visitedElements.add(currentTarget);

            FlowElement element = flowElements.get(currentTarget);
            if (element == null) {
                return null;
            }

            if (isLoggingElement(currentTarget)) {
                return element;
            }

            // Follow target reference
            currentTarget = element.getTargetReference();

            if (visitedElements.contains(currentTarget)) {
                return null;
            }
        }

        return null;
    }

    /**
     * Gets the next non-logging element
     * @param target The target element
     * @param flowElements The map of flow elements
     * @return The next non-logging element
     */
    private static String getNextNonLoggingElement(String target, Map<String, FlowElement> flowElements) {
        if (String.isBlank(target)) return null;
        
        Set<String> visitedElements = new Set<String>();
        String currentTarget = target;
        
        while (currentTarget != null && !visitedElements.contains(currentTarget)) {
            visitedElements.add(currentTarget);
            
            FlowElement element = flowElements.get(currentTarget);
            if (element == null) {
                // If element not found, stop traversal and return null
                return null;
            }
            
            if (!isLoggingElement(currentTarget)) {
                return currentTarget;
            }
            
            // Move to next target
            currentTarget = element.getTargetReference();
            
            // Check for circular reference
            if (visitedElements.contains(currentTarget)) {
                return null;
            }
        }
        
        return null;
    }

    /**
     * Restores element connections after removing logging elements
     * @param element The element to restore connections for
     * @param originalConnections Map of original connections with coordinates
     * @param loggingElements Set of logging elements to remove
     */
    private void restoreElementConnections(FlowElement element,
                                         Map<String, FlowElement> flowElements) {

        switch on element.getType() {
            when 'Start' {
                restoreStartConnections(element, flowElements);
            }
            when 'Decision' {
                restoreDecisionConnections(element, flowElements);
            }
            when 'Wait' {
                restoreWaitConnections(element, flowElements);
            }
            when 'Loop' {
                restoreLoopConnections(element, flowElements);
            }
            when else {
                // Restore standard target reference
                if(element.getTargetReference() != null) {
                    String target = getNextNonLoggingElement(element.getTargetReference(), flowElements);
                    FlowElement lastLoggingElement = getLastLoggingElement(element.getTargetReference(), flowElements);
                    element.setTargetReference(target, lastLoggingElement);
                }
                if(element.hasFaultTarget() && element.getFaultTarget() != null) {
                    String faultTarget = getNextNonLoggingElement(element.getFaultTarget(), flowElements);
                    FlowElement lastLoggingElement = getLastLoggingElement(faultTarget, flowElements);
                    element.setFaultTarget(faultTarget, lastLoggingElement);
                }
            }
        }
    }

    /**
     * Restores start element connections
     * @param element The start element
     * @param flowElements The map of flow elements
     */
    private void restoreStartConnections(FlowElement element, 
                                        Map<String, FlowElement> flowElements) {
        // Restore default connector
        String defaultTarget = getNextNonLoggingElement(element.getTargetReference(), flowElements);
        FlowElement lastLoggingElement = getLastLoggingElement(element.getTargetReference(), flowElements);
        element.setTargetReference(defaultTarget, lastLoggingElement);

        // Restore scheduled paths
        if (element.getScheduledPaths() != null) {
            Map<String, FlowElement> updatedScheduledPaths = new Map<String, FlowElement>();

            for (FlowElement path : element.getScheduledPaths().values()) {
                String pathTarget = getNextNonLoggingElement(path.getTargetReference(), flowElements);
                FlowElement lastLoggingElementPath = getLastLoggingElement(path.getTargetReference(), flowElements);
                path.setTargetReference(pathTarget, lastLoggingElementPath);
                updatedScheduledPaths.put(path.getName(), path);
            }
            element.setScheduledPaths(updatedScheduledPaths);
        }
    }

    /**
     * Restores decision element connections
     * @param element The decision element
     * @param flowElements The map of flow elements
     */
    private void restoreDecisionConnections(FlowElement element, 
                                          Map<String, FlowElement> flowElements) {
        // Restore default connector
        String defaultTarget = getNextNonLoggingElement(element.getDefaultTarget(), flowElements);
        FlowElement lastLoggingElement = getLastLoggingElement(element.getDefaultTarget(), flowElements);
        element.setDefaultTarget(defaultTarget, lastLoggingElement);

        // Restore rule connectors
        if (element.getRules() != null) {
            Map<String, FlowElement> updatedRules = new Map<String, FlowElement>();

            for (FlowElement rule : element.getRules().values()) {
                String ruleTarget = getNextNonLoggingElement(rule.getTargetReference(), flowElements);
                FlowElement lastLoggingElementRule = getLastLoggingElement(rule.getTargetReference(), flowElements);
                rule.setTargetReference(ruleTarget, lastLoggingElementRule);
                updatedRules.put(rule.getName(), rule);
            }
            element.setRules(updatedRules);
        }
    }

    /**
     * Restores wait element connections
     * @param element The wait element
     * @param flowElements The map of flow elements
     */
    private void restoreWaitConnections(FlowElement element,
                                        Map<String, FlowElement> flowElements) {
        String defaultTarget = getNextNonLoggingElement(element.getDefaultTarget(), flowElements);
        FlowElement lastLoggingElement = getLastLoggingElement(element.getDefaultTarget(), flowElements);
        element.setDefaultTarget(defaultTarget, lastLoggingElement);

        if(element.hasFaultTarget() && element.getFaultTarget() != null) {
            String faultTarget = getNextNonLoggingElement(element.getFaultTarget(), flowElements);
            FlowElement lastLoggingElementFault = getLastLoggingElement(element.getFaultTarget(), flowElements);
            element.setFaultTarget(faultTarget, lastLoggingElementFault);
        }

        if (element.getEvents() != null) {
            Map<String, FlowElement> updatedEvents = new Map<String, FlowElement>();

            for (FlowElement event : element.getEvents().values()) {
                String eventTarget = getNextNonLoggingElement(event.getTargetReference(), flowElements);
                FlowElement lastLoggingElementEvent = getLastLoggingElement(event.getTargetReference(), flowElements);
                event.setTargetReference(eventTarget, lastLoggingElementEvent);
                updatedEvents.put(event.getName(), event);
            }
            element.setEvents(updatedEvents);
        }
    }

    /**
     * Restores loop element connections
     * @param element The loop element
     * @param flowElements The map of flow elements
     */
    private void restoreLoopConnections(FlowElement element, 
                                      Map<String, FlowElement> flowElements) {
        // Restore Next Value connector
        String nextValueElement = getNextNonLoggingElement(element.getNextValueTarget(), flowElements);
        FlowElement lastLoggingElementNextValue = getLastLoggingElement(element.getNextValueTarget(), flowElements);
        element.setNextValueTarget(nextValueElement, lastLoggingElementNextValue);
        
        // Restore No More Values connector
        String noMoreValuesElement = getNextNonLoggingElement(element.getNoMoreValuesTarget(), flowElements);
        FlowElement lastLoggingElementNoMoreValues = getLastLoggingElement(element.getNoMoreValuesTarget(), flowElements);
        element.setNoMoreValuesTarget(noMoreValuesElement, lastLoggingElementNoMoreValues);
    }

    /**
     * Validates the prerequisites for adding logging
     * @param context The flow logging context
     */
    private void validatePrerequisites(FlowLoggingContext context) {
        List<String> validationErrors = new List<String>();
        
        // Validate Triton action
        if (!isTritonActionAvailable()) {
            validationErrors.add(ERROR_TRITON_ACTION_NOT_AVAILABLE);
        }
        
        // Validate flow elements
        if (context.flowElements.isEmpty()) {
            validationErrors.add(ERROR_NO_FLOW_ELEMENTS_TO_PROCESS);
        }
        
        // TODO: Validate relationships
                
        if (!validationErrors.isEmpty()) {
            throw new FlowLoggingException(String.join(validationErrors, '; '));
        }
    }
    
    /**
     * Checks if the Triton action is available
     * @return True if the Triton action is available, false otherwise
     */
    private Boolean isTritonActionAvailable() {
        try {
            List<ApexClass> tritonClass = (String.isNotBlank(TRITON_ACTION_NAMESPACE)) 
                ? [SELECT Id FROM ApexClass WHERE Name = :TRITON_ACTION_NAME AND NamespacePrefix = :TRITON_ACTION_NAMESPACE.removeEnd('__') LIMIT 1]
                : [SELECT Id FROM ApexClass WHERE Name = :TRITON_ACTION_NAME LIMIT 1];
            return (Test.isRunningTest() || !tritonClass.isEmpty());
        }
        catch(Exception e) {
            return false;
        }
    }

    /**
     * Builds a visualization result map
     * @param context The flow logging context
     * @return The result map
     */
    private Map<String, Object> buildVisualizationResult(FlowLoggingContext context, String message) {
        
        Map<String, Object> result = buildSuccess(
            message + (context.errors.isEmpty() ? '' : ' with warnings'), 
            context.flow.fullName, 
            String.valueOf(context.newVersionNumber)
        );
        
        result.put(OUTPUT_PARAMETER_FLOW_VISUALISATION, new Map<String, String>{
            OUTPUT_PARAMETER_FLOW_VISUALISATION_BEFORE => context.beforeVisualization,
            OUTPUT_PARAMETER_FLOW_VISUALISATION_AFTER => context.afterVisualization
        });
        
        if (!context.errors.isEmpty()) {
            result.put(OUTPUT_PARAMETER_WARNINGS, context.errors);
        }
        
        return result;
    }

    /**
     * Builds an error result map
     * @param message The message to display
     * @return The result map
     */
    private Map<String, Object> buildError(String message) {
        return new Map<String, Object>{
            OUTPUT_PARAMETER_SUCCESS => false,
            OUTPUT_PARAMETER_MESSAGE => message
        };
    }

    /**
     * Builds a success result map
     * @param message The message to display
     * @param flowApiName The API name of the flow
     * @param versionNumber The version number
     * @return The result map
     */
    private Map<String, Object> buildSuccess(String message, String flowApiName, String versionNumber) {
        return new Map<String, Object>{
            OUTPUT_PARAMETER_SUCCESS => true,
            OUTPUT_PARAMETER_MESSAGE => message,
            OUTPUT_PARAMETER_FLOW_API_NAME => flowApiName,
            OUTPUT_PARAMETER_NEW_VERSION_NUMBER => versionNumber
        };
    }

    /**
     * Gets the flow metadata
     * @param flowApiName The API name of the flow
     * @return The flow metadata
     */
    private MetadataService.Flow getFlowMetadata(String flowApiName) {
        if (String.isBlank(flowApiName)) return null;
        
        try {
            MetadataService.MetadataPort service = createMetadataService();
            MetadataService.Flow readResult = 
                (MetadataService.Flow)service.readMetadata('Flow', 
                    new List<String>{ flowApiName }).getRecords()[0];
            
            return readResult;
        }
        catch(Exception e) {
            return null;
        }
    }

    /**
     * Creates a metadata service
     * @return The metadata service
     */
    private MetadataService.MetadataPort createMetadataService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.metadataAPIVersion = FLOW_METADATA_VERSION;
        service.endpoint_x = System.URL.getOrgDomainUrl().toExternalForm() + ConfigUtil.SOAP_ENDPOINT_PREFIX + FLOW_METADATA_VERSION;
        return service;
    }

    /**
     * Updates the flow metadata
     * @param flow The flow metadata to update
     * @return The list of save results
     */
    private List<MetadataService.SaveResult> updateFlow(MetadataService.Flow flow) {
        MetadataService.MetadataPort service = createMetadataService();
        MetadataService.Metadata[] metadataList = new MetadataService.Metadata[] { flow };
        return service.updateMetadata(metadataList);
    }

    /**
     * Upserts the flow metadata
     * @param flow The flow metadata to upsert
     * @return The list of upsert results
     */
    private List<MetadataService.UpsertResult> upsertFlow(MetadataService.Flow flow) {
        MetadataService.MetadataPort service = createMetadataService();
        MetadataService.Metadata[] metadataList = new MetadataService.Metadata[] { flow };
        return service.upsertMetadata(metadataList);
    }

    /**
     * Handles the upsert results
     * @param results The list of upsert results
     */
    private void handleUpsertResults(List<MetadataService.UpsertResult> results) {
        if (results == null || results.isEmpty()) {
            throw new FlowLoggingException(ERROR_NO_RESULTS_FROM_UPSERT);
        }
        
        List<String> errors = new List<String>();
        for (MetadataService.UpsertResult result : results) {
            if (!result.success) {
                for (MetadataService.Error error : result.errors) {
                    errors.add(error.message);
                }
            }
        }
        
        if (!errors.isEmpty()) {
            throw new FlowLoggingException(String.join(errors, '; '));
        }
    }

    private void handleSaveResults(List<MetadataService.SaveResult> results) {
        if (results == null || results.isEmpty()) {
            throw new FlowLoggingException(ERROR_NO_RESULTS_FROM_UPDATE);
        }
        
        List<String> errors = new List<String>();
        for (MetadataService.SaveResult result : results) {
            if (!result.success) {
                for (MetadataService.Error error : result.errors) {
                    errors.add(error.message);
                }
            }
        }
        
        if (!errors.isEmpty()) {
            throw new FlowLoggingException(String.join(errors, '; '));
        }
    }
    
    /**
     * Updates a flow structure to include logging elements
     * @param flowElements Map of flow elements by their names
     */
    public void addLogElementToFlow(FlowLoggingContext context) {
        if (context == null || context?.flowElements == null || context?.flowElements?.isEmpty()) {
            return;
        }
        
        // Process all elements
        for (String elementName : context?.flowElements?.keySet()) {
             
            // Skip disconnected elements
            if (!context.connectedElements.contains(elementName)
                && !context.connectedElements.contains(elementName + ELEMENT_CONNECTION_FAULT_MARKER) 
                && !context.connectedElements.contains(elementName + ELEMENT_CONNECTION_NOMORE_MARKER)) {
                continue;
            }

            FlowElement element = context.flowElements.get(elementName);
            String elementType = element.getType();                       

            // Handle different element types
            if (elementType == ELEMENT_TYPE_START) {
                handleStartElement(element, context.flowElements);
            }
            else if (elementType == ELEMENT_TYPE_DECISION) {
                handleDecisionElement(element, context.flowElements);
            }
            else if (elementType == ELEMENT_TYPE_WAIT) {
                handleWaitElement(element, context.flowElements);
            }
            else if (elementType == ELEMENT_TYPE_LOOP) {
                handleLoopElement(element, context.flowElements);
            }
            else {
                // Handle standard elements (Create, Update, Screen, etc.)
                handleStandardElement(element, context.flowElements);
            }
        }
    }

    private void handleStartElement(FlowElement startElement, Map<String, FlowElement> flowElements) {
        String defaultTarget = startElement.getTargetReference();
        if (defaultTarget != null) {
            FlowElement postPreLog = createLogElement(POST_PRE_LOG_MARKER, startElement, defaultTarget, flowElements);
            postPreLog.setTargetReference(defaultTarget, null);
            flowElements.put(postPreLog.getName(), postPreLog);
            startElement.setTargetReference(postPreLog.getName(), null);
        }

        Map<String, FlowElement> scheduledPaths = startElement.getScheduledPaths();
        if (scheduledPaths != null) {            
            Map<String, FlowElement> updatedScheduledPaths = new Map<String, FlowElement>();            

            for (String pathName : scheduledPaths.keySet()) {
                FlowElement pathElement = scheduledPaths.get(pathName);
                String pathTarget = pathElement.getTargetReference();

                if (pathTarget != END_MARKER && pathTarget != null) {
                    FlowElement preLog = createLogElement(POST_PRE_LOG_MARKER, pathElement, pathTarget, flowElements, startElement);
                    preLog.setTargetReference(pathTarget, null);
                    flowElements.put(preLog.getName(), preLog);
                    pathElement.setTargetReference(preLog.getName(), null);
                    updatedScheduledPaths.put(pathName, pathElement);
                }
                else {
                    updatedScheduledPaths.put(pathName, null);
                }

            }
            startElement.setScheduledPaths(updatedScheduledPaths);
        }
    }

    private void handleWaitElement(FlowElement waitElement, Map<String, FlowElement> flowElements) {
        String defaultTarget = waitElement.getDefaultTarget();
        if (defaultTarget != null) {
            FlowElement postPreLog = createLogElement(POST_PRE_LOG_MARKER, waitElement, defaultTarget, flowElements);
            postPreLog.setTargetReference(defaultTarget, null);
            flowElements.put(postPreLog.getName(), postPreLog);
            waitElement.setDefaultTarget(postPreLog.getName(), null);
        }
        else {
            FlowElement postLog = createLogElement(POST_LOG_MARKER, waitElement, null, flowElements);
            postLog.setTargetReference(null, null);
            flowElements.put(postLog.getName(), postLog);
            waitElement.setDefaultTarget(postLog.getName(), null);
        }

        String faultTarget = waitElement.getFaultTarget();
        if (faultTarget != null) {
            FlowElement faultPostPreLog = createLogElement(POST_PRE_LOG_MARKER, waitElement, faultTarget, flowElements, ELEMENT_CONNECTION_FAULT_MARKER);
            faultPostPreLog.setTargetReference(faultTarget, null);
            flowElements.put(faultPostPreLog.getName(), faultPostPreLog);
            waitElement.setFaultTarget(faultPostPreLog.getName(), null);
        }        

        // Handle decision rules
        Map<String, FlowElement> waitEventElements = waitElement.getEvents();
        if (waitEventElements != null) {
            Map<String, FlowElement> updatedWaitEventElements = new Map<String, FlowElement>();            

            for (String eventName : waitEventElements.keySet()) {
                FlowElement eventElement = waitEventElements.get(eventName);
                String eventTarget = eventElement.getTargetReference();

                if (eventTarget != END_MARKER && eventTarget != null) {
                    FlowElement preLog = createLogElement(POST_PRE_LOG_MARKER, eventElement, eventTarget, flowElements, waitElement);
                    preLog.setTargetReference(eventTarget, null);
                    flowElements.put(preLog.getName(), preLog);
                    eventElement.setTargetReference(preLog.getName(), null);
                    updatedWaitEventElements.put(eventName, eventElement);
                }
                else {
                    updatedWaitEventElements.put(eventName, null);
                }

            }
            waitElement.setEvents(updatedWaitEventElements);
        }        
    }
    
    /**
     * Handles the decision flow element

     * @param decision The flow element to handle
     * @param flowElements The map of flow elements
     */
    private void handleDecisionElement(FlowElement decision, Map<String, FlowElement> flowElements) {
        // Handle default outcome
        String defaultTarget = decision.getDefaultTarget();
        if (defaultTarget != null) {
            FlowElement postPreLog = createLogElement(POST_PRE_LOG_MARKER, decision, defaultTarget, flowElements);
            postPreLog.setTargetReference(defaultTarget, null);
            flowElements.put(postPreLog.getName(), postPreLog);
            decision.setDefaultTarget(postPreLog.getName(), null);
        }
        else {
            // Create post log element
            FlowElement postLog = createLogElement(POST_LOG_MARKER, decision, null, flowElements);
            postLog.setTargetReference(null, null);
            flowElements.put(postLog.getName(), postLog);
            decision.setDefaultTarget(postLog.getName(), null);
        }
        
        // Handle decision rules
        Map<String, FlowElement> ruleElements = decision.getRules();
        if (ruleElements != null) {
            Map<String, FlowElement> updatedRuleElements = new Map<String, FlowElement>();            
            
            for (String ruleName : ruleElements.keySet()) {                
                FlowElement ruleElement = ruleElements.get(ruleName);
                
                String ruleTarget = ruleElement.getTargetReference();
                if (ruleTarget != END_MARKER && ruleTarget != null) {
                    FlowElement preLog = createLogElement(POST_PRE_LOG_MARKER, ruleElement, ruleTarget, flowElements, decision);
                    preLog.setTargetReference(ruleTarget, null);
                    flowElements.put(preLog.getName(), preLog);
                    ruleElement.setTargetReference(preLog.getName(), null);
                    updatedRuleElements.put(ruleName, ruleElement);
                }
                else {
                    updatedRuleElements.put(ruleName, null);
                }
            }
            decision.setRules(updatedRuleElements);
        }
    }
    
    /**
     * Handles the loop flow element
     * @param loopElement The flow element to handle
     * @param flowElements The map of flow elements
     */
    private void handleLoopElement(FlowElement loopElement, Map<String, FlowElement> flowElements) {
        String nextTarget = loopElement.getNextValueTarget();
        String noMoreTarget = loopElement.getNoMoreValuesTarget();
                
        // Handle Next Value path
        if (nextTarget != null) {
            FlowElement postPreLog = createLogElement(POST_PRE_LOG_MARKER, loopElement, nextTarget, flowElements);
            postPreLog.setTargetReference(nextTarget, null);
            flowElements.put(postPreLog.getName(), postPreLog);
            loopElement.setNextValueTarget(postPreLog.getName(), null);
        }
        
        // Handle No More Values path
        if (noMoreTarget == null) {
            FlowElement endPostLog = createLogElement(POST_LOG_MARKER, loopElement, null, flowElements, ELEMENT_CONNECTION_NOMORE_MARKER);
            endPostLog.setTargetReference(null, null);
            flowElements.put(endPostLog.getName(), endPostLog);
            loopElement.setNoMoreValuesTarget(endPostLog.getName(), null);
        }
        else {
            FlowElement endPostLog = createLogElement(POST_PRE_LOG_MARKER, loopElement, noMoreTarget, flowElements, ELEMENT_CONNECTION_NOMORE_MARKER);
            endPostLog.setTargetReference(noMoreTarget, null);
            flowElements.put(endPostLog.getName(), endPostLog);
            loopElement.setNoMoreValuesTarget(endPostLog.getName(), null);
        }
    }
    
    /**
     * Handles the standard flow element
     * @param element The flow element to handle
     * @param flowElements The map of flow elements
     */
    private void handleStandardElement(FlowElement element, Map<String, FlowElement> flowElements) {
        String target = element.getTargetReference();
        String targetOfTarget = flowElements.get(target)?.getTargetReference();
        if (target == null) {
            FlowElement postLog = createLogElement(POST_LOG_MARKER, element, null, flowElements);
            postLog.setTargetReference(null, null);
            flowElements.put(postLog.getName(), postLog);
            element.setTargetReference(postLog.getName(), null);            
        }
        else if (target != null) {
            FlowElement postPreLog = createLogElement(POST_PRE_LOG_MARKER, element, target, flowElements);
            postPreLog.setTargetReference(target, null);
            flowElements.put(postPreLog.getName(), postPreLog);     
            element.setTargetReference(postPreLog.getName(), null);
        }


        String faultTarget = element.getFaultTarget();
        if (element.hasFaultTarget() && faultTarget != null) {
            FlowElement faultPostPreLog = createLogElement(POST_PRE_LOG_MARKER, element, faultTarget, flowElements, ELEMENT_CONNECTION_FAULT_MARKER);
            faultPostPreLog.setTargetReference(faultTarget, null);
            flowElements.put(faultPostPreLog.getName(), faultPostPreLog);
            element.setFaultTarget(faultPostPreLog.getName(), null);
        }
    }
    
    /**
     * Finds the start element in the given map of flow elements
     * @param flowElements The map of flow elements
     * @return The start element
     */
    @TestVisible
    private FlowElement findStartElement(Map<String, FlowElement> flowElements) {
        for (FlowElement element : flowElements.values()) {
            if (element.type == 'Start') {
                return element;
            }
        }
        return null;
    }
    

    /**
     * Creates a log element with the given name and description
     * @param name The name of the log element
     * @param description The description of the log element
     * @return The created log element
     */
    private FlowElement createLogElement(String marker,
                                        FlowElement sourceElement,
                                        String targetElementName,
                                        Map<String, FlowElement> flowElements) {

        return createLogElement(marker, sourceElement, targetElementName, flowElements, null, null);
    }

    private FlowElement createLogElement(String marker,
                                        FlowElement sourceElement,
                                        String targetElementName,
                                        Map<String, FlowElement> flowElements,
                                        FlowElement sourceParentElement) {

        return createLogElement(marker, sourceElement, targetElementName, flowElements, sourceParentElement, null);
    }

    private FlowElement createLogElement(String marker,
                                        FlowElement sourceElement,
                                        String targetElementName,
                                        Map<String, FlowElement> flowElements,
                                        String sourceConnectionName) {

        return createLogElement(marker, sourceElement, targetElementName, flowElements, null, sourceConnectionName);
    }

    private FlowElement createLogElement(String marker,
                                        FlowElement sourceElement,
                                        String targetElementName,
                                        Map<String, FlowElement> flowElements,
                                        FlowElement sourceParentElement,
                                        String sourceConnectionName) {
        if (marker == null) return null;

        String logElementName = '';
        String logElementLabel = '';
        String sourceElementName = sourceElement.getName();
        String sourceElementWithRoute = sourceElement.getName();

        if (marker == POST_PRE_LOG_MARKER) {
            logElementName = (sourceParentElement != null ? sourceParentElement.getName() + '_' : '') +
                sourceElementName + '_' + targetElementName + POST_PRE_LOG_MARKER;
            FlowElement targetElement = flowElements.get(targetElementName);
            logElementLabel = String.format(LOG_LABEL_AFTER_BEFORE_FORMAT, 
                new List<String>{sourceElement.getLabel(), targetElement?.getLabel()});
            
            if (sourceParentElement != null) {
                sourceElementWithRoute = sourceParentElement.getName() + ':' + sourceElement.getName();
            }
            else if (sourceConnectionName != null) {
                sourceElementWithRoute = sourceElement.getName() + '.' + sourceConnectionName.removeStart('_');
            }
        }
        else if (marker == POST_LOG_MARKER) {
            logElementName = sourceElementName + POST_LOG_MARKER;
            logElementLabel = String.format(LOG_LABEL_AFTER_FORMAT, new List<String>{sourceElement.getLabel()});
            if (sourceConnectionName != null) {
                sourceElementWithRoute = sourceElementName + '.' + sourceConnectionName.removeStart('_');
            }
        }
        else if (marker == PRE_LOG_MARKER) {
            logElementName = targetElementName + PRE_LOG_MARKER;
            logElementLabel = String.format(LOG_LABEL_BEFORE_FORMAT, new List<String>{targetElementName});
        }

        logElementName = truncateElementName(logElementName);
        FlowElement targetElement = flowElements.get(targetElementName);
        FlowElement logElement = new FlowElement();
        logElement.setName(logElementName);
        logElement.setLabel(truncateElementLabel(logElementLabel));
        logElement.setType(ELEMENT_TYPE_ACTION_CALL);
        logElement.setSourceType(sourceElement.getType());
        logElement.setConnectionType(sourceConnectionName);
        logElement.setCoordinates(sourceElement.getX(), sourceElement.getY());

        if (sourceElement.getIsGoTo(targetElementName) && targetElementName != null) {
            logElement.setIsGoTo(true, targetElementName);
        }

        // Store source and target info in description for recovery
        logElement.setDescription(String.format(SOURCE_TARGET_INFO_FORMAT, 
            new List<String>{
                sourceElementWithRoute,
                String.valueOf(sourceElement.getY()),
                String.valueOf(sourceElement.getX()),
                targetElementName,
                String.valueOf(targetElement?.getY() ?? 0),
                String.valueOf(targetElement?.getX() ?? 0)
            }
        ));        
        return logElement;
    }

    /**
     * Truncates and sanitizes element name to fit within 80 character limit while preserving uniqueness
     * @param name Original element name
     * @return Truncated and sanitized name
     */
    @TestVisible
    private static String truncateElementName(String name) {
        if (!enableTruncateElementName) return name;

        if (String.isBlank(name)) return name;
        
        // Extract marker type
        String marker = '';
        if (name.endsWith(PRE_LOG_MARKER)) marker = PRE_LOG_MARKER;
        else if (name.endsWith(POST_LOG_MARKER)) marker = POST_LOG_MARKER;
        else if (name.endsWith(POST_PRE_LOG_MARKER)) marker = POST_PRE_LOG_MARKER;
        else if (name.endsWith(PHAROS_TEMPLATE_MARKER)) marker = PHAROS_TEMPLATE_MARKER;
        
        // Remove marker for processing
        String baseName = name.removeEnd(marker);
        
        String hash = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(baseName))
        );
        
        // Reattach marker
        return LOG_ELEMENT_HASH_MARKER + hash + marker;
    }

    /**
     * Truncates element label to fit within 80 character limit while preserving format text
     * @param label Original element label
     * @return Truncated label
     */
    @TestVisible
    private static String truncateElementLabel(String label) {
        if (String.isBlank(label)) return label;
        
        // If already within limit, return as is
        if (label.length() <= 80) return label;
        
        // Check which format is being used
        if (label.startsWith('Log After:') && label.contains('Before:')) {
            // LOG_LABEL_AFTER_BEFORE_FORMAT case
            Integer beforeIndex = label.indexOf('Before:');
            String afterPart = label.substring(0, beforeIndex).trim();
            String beforePart = label.substring(beforeIndex);
            
            // Calculate available space for each part (keeping format text intact)
            Integer formatTextLength = 'Log After: , Before: '.length();
            Integer availableSpace = 80 - formatTextLength;
            
            // Extract element names
            String afterElement = afterPart.substring('Log After: '.length());
            String beforeElement = beforePart.substring('Before: '.length());
            
            // Allocate space proportionally
            Integer afterLength = Math.min(afterElement.length(), availableSpace / 2);
            Integer beforeLength = Math.min(beforeElement.length(), availableSpace - afterLength);
            
            // Adjust after length if before part is shorter than allocated
            if (beforeElement.length() < beforeLength) {
                afterLength = Math.min(afterElement.length(), availableSpace - beforeElement.length());
            }
            
            // Truncate and add ellipsis if needed
            String truncatedAfter = afterElement.length() > afterLength 
                ? afterElement.substring(0, afterLength - 3) + '...' 
                : afterElement;
            String truncatedBefore = beforeElement.length() > beforeLength 
                ? beforeElement.substring(0, beforeLength - 3) + '...' 
                : beforeElement;
            
            return String.format(LOG_LABEL_AFTER_BEFORE_FORMAT, 
                new List<String>{truncatedAfter, truncatedBefore});
        } 
        else if (label.startsWith('Log After:')) {
            // LOG_LABEL_AFTER_FORMAT case
            String afterElement = label.substring('Log After: '.length());
            Integer availableSpace = 80 - 'Log After: '.length();
            
            String truncatedAfter = afterElement.length() > availableSpace 
                ? afterElement.substring(0, availableSpace - 3) + '...' 
                : afterElement;
            
            return String.format(LOG_LABEL_AFTER_FORMAT, new List<String>{truncatedAfter});
        } 
        else if (label.startsWith('Log Before:')) {
            // LOG_LABEL_BEFORE_FORMAT case
            String beforeElement = label.substring('Log Before: '.length());
            Integer availableSpace = 80 - 'Log Before: '.length();
            
            String truncatedBefore = beforeElement.length() > availableSpace 
                ? beforeElement.substring(0, availableSpace - 3) + '...' 
                : beforeElement;
            
            return String.format(LOG_LABEL_BEFORE_FORMAT, new List<String>{truncatedBefore});
        }
        return label;
    }    

    /**
     * Visualizes the flow structure in a tree-like format
     * @param flowElements Map of flow elements by their names
     * @return String representation of the flow structure
     */
    public String visualizeFlow(FlowLoggingContext context) {
        if (context == null || context.flowElements == null || context.flowElements.isEmpty()) {
            return '';
        }

        FlowElement startElement = findStartElement(context.flowElements);
        if (startElement == null) return '';


        VisualizeContext ctx = new VisualizeContext();
        Set<String> visitedElements = new Set<String>();
        
        // Start with the Start element
        visualizeElement(startElement, context.flowElements, '', visitedElements, ctx, true);

        // Then visualize disconnected elements
        if (hasUnprocessedElements(visitedElements, context.flowElements)) {
            ctx.append('\n [Disconnected] \n');
            
            // First process elements with references
            for (String elementName : context.flowElements.keySet()) {
                if (!visitedElements.contains(elementName) && !context.connectedElements.contains(elementName)) {
                    FlowElement element = context.flowElements.get(elementName);
                    if (hasConnectedElements(element, context.flowElements)) {
                        visualizeElement(element, context.flowElements, '    ', visitedElements, ctx, true);
                    }
                }
            }
            
            // Then process remaining elements
            for (String elementName : context.flowElements.keySet()) {
                if (!visitedElements.contains(elementName) && !context.connectedElements.contains(elementName)) {
                    FlowElement element = context.flowElements.get(elementName);
                    visualizeElement(element, context.flowElements, '    ', visitedElements, ctx, true);
                }
            }
        }
        
        return ctx.result;
    }

    private boolean hasUnprocessedElements(Set<String> visitedElements, Map<String, FlowElement> flowElements) {
        for (String elementName : flowElements.keySet()) {
            if (!visitedElements.contains(elementName)) {
                return true;
            }
        }
        return false;
    }

    private boolean hasConnectedElements(FlowElement element, Map<String, FlowElement> flowElements) {
        List<String> targets = new List<String>();
        
        // Collect all targets
        if (String.isNotBlank(element.getTargetReference()) && element.getTargetReference() != END_MARKER) {
            targets.add(element.getTargetReference());
        }
        if (String.isNotBlank(element.getDefaultTarget()) && element.getDefaultTarget() != END_MARKER) {
            targets.add(element.getDefaultTarget());
        }
        if (element.hasFaultTarget() && String.isNotBlank(element.getFaultTarget()) && element.getFaultTarget() != END_MARKER) {
            targets.add(element.getFaultTarget());
        }
        if (String.isNotBlank(element.getNextValueTarget()) && element.getNextValueTarget() != END_MARKER) {
            targets.add(element.getNextValueTarget());
        }
        if (String.isNotBlank(element.getNoMoreValuesTarget()) && element.getNoMoreValuesTarget() != END_MARKER) {
            targets.add(element.getNoMoreValuesTarget());
        }
        if (element.getRules() != null) {
            for (FlowElement rule : element.getRules()?.values()) {
                targets.add(rule.getTargetReference());
            }
        }
        if (element.getEvents() != null) {
            for (FlowElement event : element.getEvents()?.values()) {
                targets.add(event.getTargetReference());
                targets.add(event.getFaultTarget());
            }
        }
        if (element.getStageSteps() != null) {
            for (FlowElement stageStep : element.getStageSteps()?.values()) {
                targets.add(stageStep.getTargetReference());
            }
        }
        return !targets.isEmpty();
    }
    
    /**
     * Context class for visualizing the flow structure
     */
    private class VisualizeContext {
        public String result = '';
        
        public void append(String text) {
            result += text;
        }
    }


    /**
     * Visualizes the given flow element
     * @param element The flow element to visualize
     * @param flowElements The map of flow elements
     * @param indent The indentation string
     * @param visitedElements The set of visited elements
     * @param ctx The visualization context
     * @param isLast Whether this is the last element in the list
     */
    private void visualizeElement(FlowElement element,
                                Map<String, FlowElement> flowElements,
                                String indent,
                                Set<String> visitedElements,
                                VisualizeContext ctx,
                                Boolean isLast) {
        

        if (element == null || visitedElements.contains(element.getName())) {
            return;
        }
        
        // Mark element as visited
        visitedElements.add(element.getName());
        
        // Add element to visualization
        ctx.append(indent);
        if(indent != ' ── ') {
            ctx.append(isLast ? '└── ' : '├── ');
        }
        ctx.append(element.getName());
        ctx.append(' [');
        ctx.append(element.getType());
        ctx.append(']');
        
        // Handle different types of connections
        if (element.getType() == ELEMENT_TYPE_START) {
            visualizeStart(element, flowElements, indent + (isLast ? '    ' : '│   '), visitedElements, ctx);
        }
        else if (element.getType() == ELEMENT_TYPE_DECISION) {
            visualizeDecision(element, flowElements, indent + (isLast ? '    ' : '│   '), visitedElements, ctx);
        }
        else if (element.getType() == ELEMENT_TYPE_WAIT) {
            visualizeWait(element, flowElements, indent + (isLast ? '    ' : '│   '), visitedElements, ctx);
        }
        else if (element.getType() == ELEMENT_TYPE_LOOP) {
            visualizeLoop(element, flowElements, indent + (isLast ? '    ' : '│   '), visitedElements, ctx);
        }
        else {
            visualizeStandard(element, flowElements, indent + (isLast ? '    ' : '│   '), visitedElements, ctx);
        }
    }

    private void visualizeStart(FlowElement startElement,
                                Map<String, FlowElement> flowElements,
                                String indent,
                                Set<String> visitedElements,
                                VisualizeContext ctx) {

        // Add start targets
        List<String> connections = new List<String>();
        
        // Add default target
        connections.add(startElement.getTargetReference() == null ? END_MARKER : startElement.getTargetReference());

        // Add scheduled paths
        if (startElement.getScheduledPaths() != null && !startElement.getScheduledPaths().isEmpty()) {
            List<String> pathConnections = new List<String>();
            for (FlowElement path : startElement.getScheduledPaths().values()) {
                pathConnections.add(path.getName() + '->' + (path.getTargetReference() == null ? END_MARKER : path.getTargetReference()));
            }
            connections.add('Paths:[' + String.join(pathConnections, ', ') + ']');
        }

        // Add connections to visualization
        if (!connections.isEmpty()) {
            ctx.append(' → ' + String.join(connections, ', '));
        }
        ctx.append('\n');

        // Add Fault branch
        if (startElement.getScheduledPaths() != null && !startElement.getScheduledPaths().isEmpty()) {
            List<String> pathConnections = new List<String>();
            for (FlowElement path : startElement.getScheduledPaths().values()) {
                if (String.isNotBlank(path.getTargetReference())) {
                    ctx.append(indent);
                    ctx.append('├── ['+'ScheduledPath'+'] ');
                    ctx.append(path.getName() ?? 'DEFAULT');
                    ctx.append(' → ');
                    ctx.append(path.getTargetReference());
                    ctx.append('\n');                    
                }
            }
        }        

        // Visualize connected elements
        visualizeConnectedElements(startElement, flowElements, indent, visitedElements, ctx);

    }

    private void visualizeWait(FlowElement waitElement,
                                Map<String, FlowElement> flowElements,
                                String indent,
                                Set<String> visitedElements,
                                VisualizeContext ctx) {

        // Add wait targets
        List<String> connections = new List<String>();
            
        // Add default target
        connections.add('DEFAULT:' + (waitElement.getDefaultTarget() == null ? END_MARKER : waitElement.getDefaultTarget()));        

        // Add rule targets
        if (waitElement.getEvents() != null && !waitElement.getEvents().isEmpty()) {
            List<String> eventConnections = new List<String>();
            for (FlowElement event : waitElement.getEvents()?.values()) {
                String target = event.getTargetReference();
                eventConnections.add(event.getName() + '->' + (target == null ? END_MARKER : target));
            }
            if (!eventConnections.isEmpty()) {
                connections.add('Events:[' + String.join(eventConnections, ', ') + ']');
            }
        }

        // Add fault target
        if (String.isNotBlank(waitElement.getFaultTarget())) {
            connections.add('FAULT:' + waitElement.getFaultTarget());
        }

        // Add connections to visualization
        if (!connections.isEmpty()) {
            ctx.append(' → ' + String.join(connections, ', '));
        }
        ctx.append('\n');

        // Add Fault branch
        if (String.isNotBlank(waitElement.getFaultTarget())) {
            ctx.append(indent);
            ctx.append('├── ['+'FAULT'+'] → ');
            ctx.append(waitElement.getFaultTarget());
            ctx.append('\n');            
        }
        
        // Visualize connected elements
        visualizeConnectedElements(waitElement, flowElements, indent, visitedElements, ctx);
    }
    

    /**
     * Visualizes the decision flow element
     * @param decision The flow element to visualize
     * @param flowElements The map of flow elements
     * @param indent The indentation string
     * @param visitedElements The set of visited elements
     * @param ctx The visualization context
     */
    private void visualizeDecision(FlowElement decision,
                                    Map<String, FlowElement> flowElements,
                                    String indent,
                                    Set<String> visitedElements,
                                    VisualizeContext ctx) {
        
        // Add decision targets
        List<String> connections = new List<String>();

        String isGoTo = decision.getIsGoTo(decision.getDefaultTarget()) ? '.GOTO' : '';
        
        // Add default target
        connections.add('DEFAULT:' + (decision.getDefaultTarget() == null ? END_MARKER : decision.getDefaultTarget() + isGoTo));
        
        // Add rule targets
        if (decision.getRules() != null && !decision.getRules().isEmpty()) {
            List<String> ruleConnections = new List<String>();
            for (FlowElement rule : decision.getRules()?.values()) {
                String target = rule.getTargetReference();
                String isGoToRule = rule.getIsGoTo(target) ? '.GOTO' : '';
                ruleConnections.add(rule.getName() + '->' + (target == null ? END_MARKER : target + isGoToRule));
            }
            if (!ruleConnections.isEmpty()) {
                connections.add('Rules:[' + String.join(ruleConnections, ', ') + ']');
            }
        }

        // Add connections to visualization
        if (!connections.isEmpty()) {
            ctx.append(' → ' + String.join(connections, ', '));
        }
        ctx.append('\n');
        
        // Visualize connected elements
        visualizeConnectedElements(decision, flowElements, indent, visitedElements, ctx);
    }
    
    /**
     * Visualizes the loop flow element
     * @param loopElement The flow element to visualize
     * @param flowElements The map of flow elements
     * @param indent The indentation string
     * @param visitedElements The set of visited elements
     * @param ctx The visualization context
     */
    private void visualizeLoop(FlowElement loopElement,
                                Map<String, FlowElement> flowElements,
                                String indent,
                                Set<String> visitedElements,
                                VisualizeContext ctx) {
    
        // Add loop targets
        List<String> connections = new List<String>();
        
        if (String.isNotBlank(loopElement.getNextValueTarget())) {
            connections.add(VISUALISATION_NEXT_VALUE_TARGET + loopElement.getNextValueTarget());
        }
        if (String.isNotBlank(loopElement.getNoMoreValuesTarget())) {
            connections.add(VISUALISATION_NO_MORE_VALUES_TARGET + loopElement.getNoMoreValuesTarget());
        }
        else if (String.isBlank(loopElement.getNoMoreValuesTarget())) {
            connections.add(VISUALISATION_NO_MORE_VALUES_TARGET + END_MARKER);
        }
        
        // Add connections to visualization
        if (!connections.isEmpty()) {
            ctx.append(' → ' + String.join(connections, ', '));
        }
        ctx.append('\n');
        
        // Add Next Value branch
        if (String.isNotBlank(loopElement.getNextValueTarget())) {
            ctx.append(indent);
            ctx.append('├── ['+VISUALISATION_NEXT_VALUE+'] → ');
            ctx.append(loopElement.getNextValueTarget());
            ctx.append('\n');
            FlowElement nextTarget = flowElements.get(loopElement.getNextValueTarget());
            if (nextTarget != null) {
                visualizeElement(nextTarget, flowElements, indent, visitedElements, ctx, false);
            }
        }
        
        // Add No More Values branch
        if (String.isNotBlank(loopElement.getNoMoreValuesTarget())) {
            ctx.append(indent);
            ctx.append('├── ['+VISUALISATION_NO_MORE_VALUES+'] → ');
            ctx.append(loopElement.getNoMoreValuesTarget());
            ctx.append('\n');
            FlowElement noMoreTarget = flowElements.get(loopElement.getNoMoreValuesTarget());
            if (noMoreTarget != null) {
                visualizeElement(noMoreTarget, flowElements, indent, visitedElements, ctx, true);
            }
        }
        else {
            ctx.append(indent);
            ctx.append('└── ['+VISUALISATION_NO_MORE_VALUES+'] → ');
            ctx.append(END_MARKER);
            ctx.append('\n');
        }
    }
    
    /**
     * Visualizes the standard flow element
     * @param element The flow element to visualize
     * @param flowElements The map of flow elements
     * @param indent The indentation string
     * @param visitedElements The set of visited elements
     * @param ctx The visualization context
     */
    private void visualizeStandard(FlowElement element,
                                   Map<String, FlowElement> flowElements,
                                   String indent,
                                   Set<String> visitedElements,
                                   VisualizeContext ctx) {

        List<String> connections = new List<String>();

        if (String.isNotBlank(element.getTargetReference())) {
            String isGoTo = element.getIsGoTo(element.getTargetReference()) ? '.GOTO' : '';
            connections.add(element.getTargetReference() + isGoTo);
        }
        else {
            connections.add(END_MARKER);
        }
        if (String.isNotBlank(element.getFaultTarget())) {
            connections.add('FAULT:' + element.getFaultTarget());
        }

        // Add connections to visualization
        if (!connections.isEmpty()) {
            ctx.append(' → ' + String.join(connections, ', '));
        }
        ctx.append('\n');

        // Add Fault branch
        if (String.isNotBlank(element.getFaultTarget())) {
            ctx.append(indent);
            ctx.append('├── ['+'FAULT'+'] → ');
            ctx.append(element.getFaultTarget());
            ctx.append('\n');            
        }
        
        // Visualize connected elements
        visualizeConnectedElements(element, flowElements, indent, visitedElements, ctx);
    }
    
    /**
     * Visualizes the connected elements of the given flow element
     * @param element The flow element to visualize
     * @param flowElements The map of flow elements
     * @param indent The indentation string
     * @param visitedElements The set of visited elements
     * @param ctx The visualization context
     */
    private void visualizeConnectedElements(FlowElement element,
                                            Map<String, FlowElement> flowElements,
                                            String indent,
                                            Set<String> visitedElements,
                                            VisualizeContext ctx) {        

        List<String> targets = new List<String>();
        
        // Collect all targets
        if (String.isNotBlank(element.getTargetReference()) && element.getTargetReference() != END_MARKER) {
            targets.add(element.getTargetReference());
        }
        if (String.isNotBlank(element.getDefaultTarget()) && element.getDefaultTarget() != END_MARKER) {
            targets.add(element.getDefaultTarget());
        }
        if (String.isNotBlank(element.getFaultTarget()) && element.getFaultTarget() != END_MARKER) {
            targets.add(element.getFaultTarget());
        }
        if (element.getRules() != null) {
            for (FlowElement rule : element.getRules()?.values()) {
                targets.add(rule.getTargetReference());
            }
        }
        if (element.getEvents() != null) {
            for (FlowElement event : element.getEvents()?.values()) {
                targets.add(event.getTargetReference());
            }
        }
        if (element.getScheduledPaths() != null) {
            for (FlowElement path : element.getScheduledPaths()?.values()) {
                targets.add(path.getTargetReference());
            }
        }

        // Visualize each target
        for (Integer i = 0; i < targets.size(); i++) {
            String targetName = targets[i];
            FlowElement targetElement = flowElements.get(targetName);
            if (targetElement != null) {
                visualizeElement(targetElement, flowElements, indent, visitedElements, ctx, i == targets.size() - 1);
            }
        }
    }
    
    /**
     * Simple FlowElement class to represent flow elements
     */
    public class FlowElement {
        private String name;
        private String label;
        private String type;
        private String sourceType;
        private String connectionType;
        private String description;
        private String targetReference;
        private String defaultTarget;
        private String faultTarget;
        private String nextValueTarget;
        private String noMoreValuesTarget;
        private Map<String, Boolean> isGoToTargets;
        
        private Integer x;
        private Integer y;

        private Map<String, FlowElement> rules;
        private Map<String, FlowElement> events;
        private Map<String, FlowElement> stageSteps;
        private Map<String, FlowElement> scheduledPaths;

        private MetadataService.FlowStart startMetadata;
        private MetadataService.FlowRule ruleMetadata;
        private MetadataService.FlowWaitEvent waitEventMetadata;
        private MetadataService.FlowRecordCreate recordCreateMetadata;
        private MetadataService.FlowRecordUpdate recordUpdateMetadata;
        private MetadataService.FlowRecordDelete recordDeleteMetadata;
        private MetadataService.FlowScreen screenMetadata;
        private MetadataService.FlowLoop loopMetadata;
        private MetadataService.FlowAssignment assignmentMetadata;
        private MetadataService.FlowDecision decisionMetadata;
        private MetadataService.FlowActionCall actionCallMetadata;
        private MetadataService.FlowRecordLookup recordLookupMetadata;
        private MetadataService.FlowSubflow subflowMetadata;
        private MetadataService.FlowWait waitMetadata;
        private MetadataService.FlowTransform transformMetadata;
        private MetadataService.FlowChoice choiceMetadata;
        private MetadataService.FlowStage stageMetadata;
        private MetadataService.FlowConstant constantMetadata;
        private MetadataService.FlowApexPluginCall apexPluginCallMetadata;
        private MetadataService.FlowFormula formulaMetadata;
        private MetadataService.FlowCollectionProcessor collectionProcessorMetadata;
        private MetadataService.FlowCustomError customErrorMetadata;
        private MetadataService.FlowOrchestratedStage orchestratedStageMetadata;
        private MetadataService.FlowStageStep orchestratedStageStepMetadata;
        private MetadataService.FlowRecordRollback recordRollbackMetadata;

        public MetadataService.FlowStart getStartMetadata() { return startMetadata; }
        public void setStartMetadata(MetadataService.FlowStart value) { startMetadata = value; }

        public String getName() { return name; }
        public void setName(String value) { name = value; }
        
        public String getLabel() { return label; }
        public void setLabel(String value) { label = value; }
        
        public String getType() { return type; }
        public void setType(String value) { type = value; }

        public String getSourceType() { return sourceType; }
        public void setSourceType(String value) { sourceType = value; }

        public String getConnectionType() { return connectionType; }
        public void setConnectionType(String value) { connectionType = value; }
        
        public String getDescription() { return description; }
        public void setDescription(String value) { description = value; }

        public Boolean getIsGoTo(String target) { 
            if (isGoToTargets == null) {
                isGoToTargets = new Map<String, Boolean>();
            }
            return isGoToTargets.get(target) == null ? false : isGoToTargets.get(target); 
        }
        public void setIsGoTo(Boolean value, String target) { 
            if (isGoToTargets == null) {
                isGoToTargets = new Map<String, Boolean>();
            }
            isGoToTargets.put(target, value);
        }
        
        public String getTargetReference() { return targetReference; }
        public void setTargetReference(String value, FlowElement logElement) {
            targetReference = value;
            if (logElement != null && logElement.getIsGoTo(value)) {
                this.setIsGoTo(logElement.getIsGoTo(value), value);
            }
        }
        public void setTargetReference(MetadataService.FlowConnector connector) {
            if (connector != null) {
                targetReference = connector?.targetReference;
                if (targetReference != null) {
                    setIsGoTo(connector?.isGoTo, targetReference);
                }
            }
        }
        
        public String getDefaultTarget() { return defaultTarget; }
        public void setDefaultTarget(String value, FlowElement logElement) {
            defaultTarget = value;
            if (logElement != null && logElement.getIsGoTo(value)) {
                this.setIsGoTo(logElement.getIsGoTo(value), value);
            }
        }
        public void setDefaultTarget(MetadataService.FlowConnector connector) {
            if (connector != null) {
                defaultTarget = connector?.targetReference;
                if (defaultTarget != null) {
                    setIsGoTo(connector?.isGoTo, defaultTarget);
                }
            }
        }
        public String getFaultTarget() { return faultTarget; }
        public void setFaultTarget(String value, FlowElement logElement) {
            faultTarget = value;
            if (logElement != null && logElement.getIsGoTo(value)) {
                this.setIsGoTo(logElement.getIsGoTo(value), value);
            }
        }
        public void setFaultTarget(MetadataService.FlowConnector connector) {
            if (connector != null) {
                faultTarget = connector?.targetReference;
                if (faultTarget != null) {
                    setIsGoTo(connector?.isGoTo, faultTarget);
                }
            }
        }
        
        public String getNextValueTarget() { return nextValueTarget; }
        public void setNextValueTarget(String value, FlowElement logElement) {
            nextValueTarget = value;
            if (logElement != null && logElement.getIsGoTo(value)) {
                this.setIsGoTo(logElement.getIsGoTo(value), value);
            }
        }
        public void setNextValueTarget(MetadataService.FlowConnector connector) {
            if (connector != null) {
                nextValueTarget = connector?.targetReference;
                setIsGoTo(connector?.isGoTo, nextValueTarget);
            }
        }
        
        public String getNoMoreValuesTarget() { return noMoreValuesTarget; }
        public void setNoMoreValuesTarget(String value, FlowElement logElement) {
            noMoreValuesTarget = value;
            if (logElement != null && logElement.getIsGoTo(value)) {
                this.setIsGoTo(logElement.getIsGoTo(value), value);
            }
        }
        public void setNoMoreValuesTarget(MetadataService.FlowConnector connector) {
            if (connector != null) {
                noMoreValuesTarget = connector?.targetReference;
                setIsGoTo(connector?.isGoTo, noMoreValuesTarget);
            }
        }

        
        public Map<String, FlowElement> getRules() { return rules; }
        public void setRules(Map<String, FlowElement> value) { rules = value; }

        public Map<String, FlowElement> getEvents() { return events; }
        public void setEvents(Map<String, FlowElement> value) { events = value; }

        public MetadataService.FlowRule getRuleMetadata() { return ruleMetadata; }
        public void setRuleMetadata(MetadataService.FlowRule value) { ruleMetadata = value; }

        public Map<String, FlowElement> getScheduledPaths() { return scheduledPaths; }
        public void setScheduledPaths(Map<String, FlowElement> value) { scheduledPaths = value; }

        public MetadataService.FlowWaitEvent getWaitEventMetadata() { return waitEventMetadata; }
        public void setWaitEventMetadata(MetadataService.FlowWaitEvent value) { waitEventMetadata = value; }

        public MetadataService.FlowRecordCreate getRecordCreateMetadata() { return recordCreateMetadata; }
        public void setRecordCreateMetadata(MetadataService.FlowRecordCreate value) { recordCreateMetadata = value; }

        public MetadataService.FlowRecordUpdate getRecordUpdateMetadata() { return recordUpdateMetadata; }
        public void setRecordUpdateMetadata(MetadataService.FlowRecordUpdate value) { recordUpdateMetadata = value; }

        public MetadataService.FlowRecordDelete getRecordDeleteMetadata() { return recordDeleteMetadata; }
        public void setRecordDeleteMetadata(MetadataService.FlowRecordDelete value) { recordDeleteMetadata = value; }

        public MetadataService.FlowScreen getScreenMetadata() { return screenMetadata; }
        public void setScreenMetadata(MetadataService.FlowScreen value) { screenMetadata = value; }

        public MetadataService.FlowLoop getLoopMetadata() { return loopMetadata; }
        public void setLoopMetadata(MetadataService.FlowLoop value) { loopMetadata = value; }

        public MetadataService.FlowAssignment getAssignmentMetadata() { return assignmentMetadata; }
        public void setAssignmentMetadata(MetadataService.FlowAssignment value) { assignmentMetadata = value; }

        public MetadataService.FlowActionCall getActionCallMetadata() { return actionCallMetadata; }
        public void setActionCallMetadata(MetadataService.FlowActionCall value) { actionCallMetadata = value; }

        public MetadataService.FlowRecordLookup getRecordLookupMetadata() { return recordLookupMetadata; }
        public void setRecordLookupMetadata(MetadataService.FlowRecordLookup value) { recordLookupMetadata = value; }

        public MetadataService.FlowSubflow getSubflowMetadata() { return subflowMetadata; }
        public void setSubflowMetadata(MetadataService.FlowSubflow value) { subflowMetadata = value; }

        public MetadataService.FlowWait getWaitMetadata() { return waitMetadata; }
        public void setWaitMetadata(MetadataService.FlowWait value) { waitMetadata = value; }

        public MetadataService.FlowTransform getTransformMetadata() { return transformMetadata; }
        public void setTransformMetadata(MetadataService.FlowTransform value) { transformMetadata = value; }

        public MetadataService.FlowChoice getChoiceMetadata() { return choiceMetadata; }
        public void setChoiceMetadata(MetadataService.FlowChoice value) { choiceMetadata = value; }

        public MetadataService.FlowStage getStageMetadata() { return stageMetadata; }
        public void setStageMetadata(MetadataService.FlowStage value) { stageMetadata = value; }

        public MetadataService.FlowConstant getConstantMetadata() { return constantMetadata; }
        public void setConstantMetadata(MetadataService.FlowConstant value) { constantMetadata = value; }

        public MetadataService.FlowApexPluginCall getApexPluginCallMetadata() { return apexPluginCallMetadata; }
        public void setApexPluginCallMetadata(MetadataService.FlowApexPluginCall value) { apexPluginCallMetadata = value; }

        public MetadataService.FlowFormula getFormulaMetadata() { return formulaMetadata; }
        public void setFormulaMetadata(MetadataService.FlowFormula value) { formulaMetadata = value; }

        public MetadataService.FlowCollectionProcessor getCollectionProcessorMetadata() { return collectionProcessorMetadata; }
        public void setCollectionProcessorMetadata(MetadataService.FlowCollectionProcessor value) { collectionProcessorMetadata = value; }

        public MetadataService.FlowCustomError getCustomErrorMetadata() { return customErrorMetadata; }
        public void setCustomErrorMetadata(MetadataService.FlowCustomError value) { customErrorMetadata = value; }

        public MetadataService.FlowDecision getDecisionMetadata() { return decisionMetadata; }
        public void setDecisionMetadata(MetadataService.FlowDecision value) { decisionMetadata = value; }

        public MetadataService.FlowOrchestratedStage getOrchestratedStageMetadata() { return orchestratedStageMetadata; }
        public void setOrchestratedStageMetadata(MetadataService.FlowOrchestratedStage value) { orchestratedStageMetadata = value; }

        public MetadataService.FlowStageStep getOrchestratedStageStepMetadata() { return orchestratedStageStepMetadata; }
        public void setOrchestratedStageStepMetadata(MetadataService.FlowStageStep value) { orchestratedStageStepMetadata = value; }

        public Map<String, FlowElement> getStageSteps() { return stageSteps; }
        public void setStageSteps(Map<String, FlowElement> value) { stageSteps = value; }

        public MetadataService.FlowRecordRollback getRecordRollbackMetadata() { return recordRollbackMetadata; }
        public void setRecordRollbackMetadata(MetadataService.FlowRecordRollback value) { recordRollbackMetadata = value; }


        public Boolean hasFaultTarget() {
            return getType() == ELEMENT_TYPE_RECORD_CREATE 
                || getType() == ELEMENT_TYPE_RECORD_UPDATE
                || getType() == ELEMENT_TYPE_RECORD_DELETE
                || getType() == ELEMENT_TYPE_RECORD_LOOKUP
                || getType() == ELEMENT_TYPE_WAIT
                || getType() == ELEMENT_TYPE_ACTION_CALL
                || getType() == ELEMENT_TYPE_APEX_PLUGIN
                || getType() == ELEMENT_TYPE_ORCHESTRATED_STAGE;
        }

        public Integer getX() { return x; }
        public void setX(Integer value) { x = value; }

        public Integer getY() { return y; }
        public void setY(Integer value) { y = value; }

        public void setCoordinates(Integer x, Integer y) {
            this.x = x;
            this.y = y;
        }
    }

    /**
     * Converts a MetadataService.Flow into a map of FlowElements
     * @param flow MetadataService.Flow instance
     * @return Map of flow elements
     */
    public Map<String, FlowElement> convertMetadataFlowToElements(MetadataService.Flow flow) {
        if (flow == null) {
            return new Map<String, FlowElement>();
        }

        Map<String, FlowElement> flowElements = new Map<String, FlowElement>();
        
        // Process all flow nodes
        if (flow?.decisions != null) {
            for (MetadataService.FlowDecision decisionElement : flow.decisions) {
                flowElements.put(decisionElement.name, convertDecision(decisionElement));
            }
        }        
        if (flow?.recordCreates != null) {
            for (MetadataService.FlowRecordCreate createElement : flow.recordCreates) {
                flowElements.put(createElement.name, convertRecordCreate(createElement));
            }
        }        
        if (flow?.recordUpdates != null) {
            for (MetadataService.FlowRecordUpdate updateElement : flow.recordUpdates) {
                flowElements.put(updateElement.name, convertRecordUpdate(updateElement));
            }
        }        
        if (flow?.recordDeletes != null) {
            for (MetadataService.FlowRecordDelete deleteElement : flow.recordDeletes) {
                flowElements.put(deleteElement.name, convertRecordDelete(deleteElement));
            }
        }
        if (flow?.recordLookups != null) {
            for (MetadataService.FlowRecordLookup lookupElement : flow.recordLookups) {
                flowElements.put(lookupElement.name, convertRecordLookup(lookupElement));
            }
        }    
        if (flow?.screens != null) {
            for (MetadataService.FlowScreen screenElement : flow.screens) {
                flowElements.put(screenElement.name, convertScreen(screenElement));
            }
        }        
        if (flow?.loops != null) {
            for (MetadataService.FlowLoop loopElement : flow.loops) {
                flowElements.put(loopElement.name, convertLoop(loopElement));
            }
        }        
        if (flow?.assignments != null) {
            for (MetadataService.FlowAssignment assignment : flow.assignments) {
                flowElements.put(assignment.name, convertAssignment(assignment));
            }
        }        
        if (flow?.subflows != null) {
            for (MetadataService.FlowSubflow subflow : flow.subflows) {
                flowElements.put(subflow.name, convertSubflow(subflow));
            }
        }
        if (flow?.actionCalls != null) {
            for (MetadataService.FlowActionCall actionCall : flow.actionCalls) {
                flowElements.put(actionCall.name, convertActionCall(actionCall));
            }
        }        
        if (flow?.transforms != null) {
            for (MetadataService.FlowTransform transform : flow.transforms) {
                flowElements.put(transform.name, convertTransform(transform));
            }
        }
        if (flow?.waits != null) {
            for (MetadataService.FlowWait wait : flow.waits) {
                flowElements.put(wait.name, convertWait(wait));
            }
        }
        if (flow?.collectionProcessors != null) {
            for (MetadataService.FlowCollectionProcessor collectionProcessor : flow.collectionProcessors) {
                flowElements.put(collectionProcessor.name, convertCollectionProcessor(collectionProcessor));
            }
        }
        if (flow?.customErrors != null) {
            for (MetadataService.FlowCustomError customError : flow.customErrors) {
                flowElements.put(customError.name, convertCustomError(customError));
            }
        }
        if (flow?.apexPluginCalls != null) {
            for (MetadataService.FlowApexPluginCall apexPluginCall : flow.apexPluginCalls) {
                flowElements.put(apexPluginCall.name, convertApexPluginCall(apexPluginCall));
            }
        }
        if (flow?.orchestratedStages != null) {
            for (MetadataService.FlowOrchestratedStage orchestratedStage : flow.orchestratedStages) {
                flowElements.put(orchestratedStage.name, convertOrchestratedStage(orchestratedStage));
            }
        }
        if (flow?.recordRollbacks != null) {
            for (MetadataService.FlowRecordRollback recordRollback : flow.recordRollbacks) {
                flowElements.put(recordRollback.name, convertRecordRollback(recordRollback));
            }
        }

        // Add Start element
        flowElements.put(ELEMENT_TYPE_START, convertStartElement(flow));
        
        return flowElements;
    }

    private FlowElement convertStartElement(MetadataService.Flow flow) {
        FlowElement startElement = new FlowElement();
        if(flow?.start != null) {            
            startElement.setName(ELEMENT_TYPE_START);
            startElement.setLabel(ELEMENT_TYPE_START);
            startElement.setType(ELEMENT_TYPE_START);
            startElement.setDescription(flow.start?.description);
            startElement.setTargetReference(flow.start?.connector);
            startElement.setCoordinates(flow.start?.locationX, flow.start?.locationY);
            
            // Handle scheduled paths
            if(flow?.start?.scheduledPaths != null) {
                Map<String, FlowElement> scheduledPaths = new Map<String, FlowElement>();
                for(MetadataService.FlowScheduledPath path : flow.start.scheduledPaths) {
                    FlowElement scheduledPathElement = new FlowElement();
                    scheduledPathElement.setName(path?.name);
                    scheduledPathElement.setLabel(path?.label);
                    scheduledPathElement.setType(ELEMENT_TYPE_SCHEDULED_PATH);
                    scheduledPathElement.setDescription(path?.description);
                    scheduledPathElement.setCoordinates(flow.start?.locationX, flow.start?.locationY);
                    scheduledPathElement.setTargetReference(path?.connector);
                    scheduledPaths.put(path?.name, scheduledPathElement);
                }
                startElement.setScheduledPaths(scheduledPaths);                
            }

            startElement.setStartMetadata(flow.start);
        }
        else if (flow?.startElementReference != null) {
            startElement.setName(ELEMENT_TYPE_START);
            startElement.setLabel(ELEMENT_TYPE_START);
            startElement.setType(ELEMENT_TYPE_START);
            startElement.setDescription(ELEMENT_TYPE_START);
            startElement.setTargetReference(flow.startElementReference, null);
            startElement.setCoordinates(50, 0);
        }
        return startElement;
    }

    private FlowElement convertOrchestratedStage(MetadataService.FlowOrchestratedStage orchestratedStage) {
        FlowElement element = new FlowElement();
        element.setName(orchestratedStage.name);
        element.setLabel(orchestratedStage.label);
        element.setType(ELEMENT_TYPE_ORCHESTRATED_STAGE);
        element.setDescription(orchestratedStage.description);
        element.setCoordinates(orchestratedStage.locationX, orchestratedStage.locationY);
        element.setTargetReference(orchestratedStage.connector);
        element.setFaultTarget(orchestratedStage.faultConnector);

        if (orchestratedStage.stageSteps != null) {
            Map<String, FlowElement> stageStepElements = new Map<String, FlowElement>();
            for (MetadataService.FlowStageStep stageStep : orchestratedStage.stageSteps) {
                FlowElement stageStepElement = new FlowElement();
                stageStepElement.setName(stageStep.name);
                stageStepElement.setLabel(stageStep.label);
                stageStepElement.setType(ELEMENT_TYPE_STAGE_STEP);
                stageStepElement.setDescription(stageStep.description);
                stageStepElement.setCoordinates(orchestratedStage.locationX, orchestratedStage.locationY);
                stageStepElement.setOrchestratedStageStepMetadata(stageStep);
                stageStepElements.put(stageStep.name, stageStepElement);
            }
            element.setStageSteps(stageStepElements);
        }

        element.setOrchestratedStageMetadata(orchestratedStage);

        return element;
    }
    
    /**
     * Converts a MetadataService.FlowDecision into a FlowElement
     * @param decision The MetadataService.FlowDecision to convert
     * @return The converted FlowElement
     */
    private FlowElement convertDecision(MetadataService.FlowDecision decision) {
        FlowElement element = new FlowElement();
        element.setName(decision.name);
        element.setLabel(decision.label);
        element.setType(ELEMENT_TYPE_DECISION);
        element.setDescription(decision.description);
        element.setCoordinates(decision.locationX, decision.locationY);
        
        // Handle default connector
        element.setDefaultTarget(decision.defaultConnector);
        
        // Handle rules
        if (decision.rules != null) {
            Map<String, FlowElement> ruleElements = new Map<String, FlowElement>();
            for (MetadataService.FlowRule rule : decision.rules) {
                if (rule.connector != null) {
                    FlowElement ruleElement = new FlowElement();
                    ruleElement.setName(rule.name);
                    ruleElement.setLabel(rule.label);
                    ruleElement.setType(ELEMENT_TYPE_DECISION_RULE);
                    ruleElement.setCoordinates(decision.locationX, decision.locationY);
                    ruleElement.setTargetReference(rule.connector);
                    ruleElement.setDescription(rule.description);
                    ruleElement.setRuleMetadata(rule);
                    // Add rule to rules map
                    ruleElements.put(rule.name, ruleElement);
                }
            }
            element.setRules(ruleElements);
        }

        element.setDecisionMetadata(decision);
        
        return element;
    }
    
    /**
     * Converts a MetadataService.FlowLoop into a FlowElement
     * @param loopElement The MetadataService.FlowLoop to convert
     * @return The converted FlowElement
     */
    private FlowElement convertLoop(MetadataService.FlowLoop loopElement) {
        FlowElement element = new FlowElement();
        element.setName(loopElement.name);
        element.setLabel(loopElement.label);
        element.setType(ELEMENT_TYPE_LOOP);
        element.setDescription(loopElement.description);
        element.setCoordinates(loopElement.locationX, loopElement.locationY);
        element.setNextValueTarget(loopElement.nextValueConnector);
        element.setNoMoreValuesTarget(loopElement.noMoreValuesConnector);
        element.setLoopMetadata(loopElement);
        
        return element;
    }
    
    /**
     * Converts a MetadataService.FlowRecordCreate into a FlowElement
     * @param createElement The MetadataService.FlowRecordCreate to convert
     * @return The converted FlowElement
     */
    private FlowElement convertRecordCreate(MetadataService.FlowRecordCreate createElement) {
        FlowElement element = new FlowElement();
        element.setName(createElement.name);
        element.setLabel(createElement.label);
        element.setType(ELEMENT_TYPE_RECORD_CREATE);
        element.setDescription(createElement.description);
        element.setCoordinates(createElement.locationX, createElement.locationY);
        element.setTargetReference(createElement.connector);
        element.setFaultTarget(createElement.faultConnector);
        element.setRecordCreateMetadata(createElement);

        return element;
    }

    /**
     * Converts a MetadataService.FlowRecordUpdate into a FlowElement
     * @param updateElement The MetadataService.FlowRecordUpdate to convert
     * @return The converted FlowElement
     */
    private FlowElement convertRecordUpdate(MetadataService.FlowRecordUpdate updateElement) {
        FlowElement element = new FlowElement();
        element.setName(updateElement.name);
        element.setLabel(updateElement.label);
        element.setType(ELEMENT_TYPE_RECORD_UPDATE);
        element.setDescription(updateElement.description);
        element.setCoordinates(updateElement.locationX, updateElement.locationY);
        element.setTargetReference(updateElement.connector);
        element.setFaultTarget(updateElement.faultConnector);
        element.setRecordUpdateMetadata(updateElement);

        return element;
    }
    
    /**
     * Converts a MetadataService.FlowRecordDelete into a FlowElement
     * @param deleteElement The MetadataService.FlowRecordDelete to convert
     * @return The converted FlowElement
     */
    private FlowElement convertRecordDelete(MetadataService.FlowRecordDelete deleteElement) {
        FlowElement element = new FlowElement();
        element.setName(deleteElement.name);
        element.setLabel(deleteElement.label);
        element.setType(ELEMENT_TYPE_RECORD_DELETE);
        element.setDescription(deleteElement.description);
        element.setCoordinates(deleteElement.locationX, deleteElement.locationY);
        element.setTargetReference(deleteElement.connector);
        element.setFaultTarget(deleteElement.faultConnector);
        element.setRecordDeleteMetadata(deleteElement);
        
        return element;
    }

    /**
     * Converts a MetadataService.FlowScreen into a FlowElement
     * @param screenElement The MetadataService.FlowScreen to convert
     * @return The converted FlowElement
     */
    private FlowElement convertScreen(MetadataService.FlowScreen screenElement) {
        FlowElement element = new FlowElement();
        element.setName(screenElement.name);
        element.setLabel(screenElement.label);
        element.setType(ELEMENT_TYPE_SCREEN);
        element.setDescription(screenElement.description);
        element.setCoordinates(screenElement.locationX, screenElement.locationY);
        element.setTargetReference(screenElement.connector);
        element.setScreenMetadata(screenElement);

        return element;
    }
    
    /**
     * Converts a MetadataService.FlowAssignment into a FlowElement
     * @param assignmentElement The MetadataService.FlowAssignment to convert
     * @return The converted FlowElement
     */
    private FlowElement convertAssignment(MetadataService.FlowAssignment assignmentElement) {
        FlowElement element = new FlowElement();
        element.setName(assignmentElement.name);
        element.setLabel(assignmentElement.label);
        element.setType(ELEMENT_TYPE_ASSIGNMENT);
        element.setDescription(assignmentElement.description);
        element.setCoordinates(assignmentElement.locationX, assignmentElement.locationY);
        element.setTargetReference(assignmentElement.connector);
        element.setAssignmentMetadata(assignmentElement);
        
        return element;
    }
    
    /**
     * Converts a MetadataService.FlowSubflow into a FlowElement
     * @param subflowElement The MetadataService.FlowSubflow to convert
     * @return The converted FlowElement
     */
    private FlowElement convertSubflow(MetadataService.FlowSubflow subflowElement) {
        FlowElement element = new FlowElement();
        element.setName(subflowElement.name);
        element.setLabel(subflowElement.label);
        element.setType(ELEMENT_TYPE_SUBFLOW);
        element.setDescription(subflowElement.description);
        element.setCoordinates(subflowElement.locationX, subflowElement.locationY);
        element.setTargetReference(subflowElement.connector);
        element.setSubflowMetadata(subflowElement);
        
        return element;
    }

    /**
     * Converts a MetadataService.FlowActionCall into a FlowElement
     * @param actionCallElement The MetadataService.FlowActionCall to convert
     * @return The converted FlowElement
     */
    private FlowElement convertActionCall(MetadataService.FlowActionCall actionCallElement) {
        FlowElement element = new FlowElement();
        element.setName(actionCallElement.name);
        element.setLabel(actionCallElement.label);
        element.setType(ELEMENT_TYPE_ACTION_CALL);
        element.setDescription(actionCallElement.description);
        element.setCoordinates(actionCallElement.locationX, actionCallElement.locationY);
        element.setTargetReference(actionCallElement.connector);
        element.setFaultTarget(actionCallElement.faultConnector);
        element.setActionCallMetadata(actionCallElement);

        return element;
    }

    /**
     * Converts a MetadataService.FlowApexPluginCall into a FlowElement
     * @param apexPluginCallElement The MetadataService.FlowApexPluginCall to convert
     * @return The converted FlowElement
     */
    private FlowElement convertApexPluginCall(MetadataService.FlowApexPluginCall apexPluginCallElement) {
        FlowElement element = new FlowElement();
        element.setName(apexPluginCallElement.name);
        element.setLabel(apexPluginCallElement.label);
        element.setType(ELEMENT_TYPE_APEX_PLUGIN);
        element.setDescription(apexPluginCallElement.description);
        element.setCoordinates(apexPluginCallElement.locationX, apexPluginCallElement.locationY);
        element.setTargetReference(apexPluginCallElement.connector);
        element.setFaultTarget(apexPluginCallElement.faultConnector);
        element.setApexPluginCallMetadata(apexPluginCallElement);

        return element;
    }

    /**
     * Converts a MetadataService.FlowCustomError into a FlowElement
     * @param customErrorElement The MetadataService.FlowCustomError to convert
     * @return The converted FlowElement
     */
    private FlowElement convertCustomError(MetadataService.FlowCustomError customErrorElement) {
        FlowElement element = new FlowElement();
        element.setName(customErrorElement.name);
        element.setLabel(customErrorElement.label);
        element.setType(ELEMENT_TYPE_CUSTOM_ERROR);
        element.setDescription(customErrorElement.description);
        element.setCoordinates(customErrorElement.locationX, customErrorElement.locationY);
        element.setTargetReference(customErrorElement.connector);
        element.setCustomErrorMetadata(customErrorElement);

        return element;
    }       


    /**
     * Converts a MetadataService.FlowCollectionProcessor into a FlowElement
     * @param collectionProcessorElement The MetadataService.FlowCollectionProcessor to convert
     * @return The converted FlowElement
     */
    private FlowElement convertCollectionProcessor(MetadataService.FlowCollectionProcessor collectionProcessorElement) {
        FlowElement element = new FlowElement();
        element.setName(collectionProcessorElement.name);
        element.setLabel(collectionProcessorElement.label);
        element.setType(ELEMENT_TYPE_COLLECTION_PROCESSOR);
        element.setDescription(collectionProcessorElement.description);
        element.setCoordinates(collectionProcessorElement.locationX, collectionProcessorElement.locationY);
        element.setTargetReference(collectionProcessorElement.connector);
        element.setCollectionProcessorMetadata(collectionProcessorElement);

        return element;
    }

    /**
     * Converts a MetadataService.FlowWait into a FlowElement
     * @param waitElement The MetadataService.FlowWait to convert
     * @return The converted FlowElement
     */
    private FlowElement convertWait(MetadataService.FlowWait waitElement) {
        FlowElement element = new FlowElement();
        element.setName(waitElement.name);
        element.setLabel(waitElement.label);
        element.setType(ELEMENT_TYPE_WAIT);
        element.setDescription(waitElement.description);
        element.setCoordinates(waitElement.locationX, waitElement.locationY);
        element.setDefaultTarget(waitElement.defaultConnector);
        element.setFaultTarget(waitElement.faultConnector);
        element.setWaitMetadata(waitElement);

        if (waitElement.waitEvents != null) {
            Map<String, FlowElement> eventElements = new Map<String, FlowElement>();
            for (MetadataService.FlowWaitEvent event : waitElement.waitEvents) {
                if (event.connector != null) {

                    FlowElement eventElement = new FlowElement();
                    eventElement.setName(event.name);
                    eventElement.setLabel(event.label);
                    eventElement.setType(ELEMENT_TYPE_WAIT_EVENT);
                    eventElement.setCoordinates(waitElement.locationX, waitElement.locationY);
                    eventElement.setTargetReference(event.connector);
                    eventElement.setDescription(event.description);
                    eventElement.setWaitEventMetadata(event);
                    // Add event to events map
                    eventElements.put(event.name, eventElement);

                }
            }
            element.setEvents(eventElements);
        }

        return element;
    }


    /**
     * Converts a MetadataService.FlowTransform into a FlowElement
     * @param transformElement The MetadataService.FlowTransform to convert
     * @return The converted FlowElement
     */
    private FlowElement convertTransform(MetadataService.FlowTransform transformElement) {
        FlowElement element = new FlowElement();
        element.setName(transformElement.name);
        element.setLabel(transformElement.label);
        element.setType(ELEMENT_TYPE_TRANSFORM);
        element.setDescription(transformElement.description);
        element.setCoordinates(transformElement.locationX, transformElement.locationY);
        element.setTargetReference(transformElement.connector);
        element.setTransformMetadata(transformElement);
        
        return element;
    }    


    /**
     * Converts a MetadataService.FlowRecordLookup into a FlowElement
     * @param lookupElement The MetadataService.FlowRecordLookup to convert
     * @return The converted FlowElement
     */
    private FlowElement convertRecordLookup(MetadataService.FlowRecordLookup lookupElement) {
        FlowElement element = new FlowElement();
        element.setName(lookupElement.name);
        element.setLabel(lookupElement.label);
        element.setType(ELEMENT_TYPE_RECORD_LOOKUP);
        element.setDescription(lookupElement.description);
        element.setCoordinates(lookupElement.locationX, lookupElement.locationY);
        element.setTargetReference(lookupElement.connector);
        element.setFaultTarget(lookupElement.faultConnector);
        element.setRecordLookupMetadata(lookupElement);

        return element;
    }

    private FlowElement convertRecordRollback(MetadataService.FlowRecordRollback recordRollbackElement) {
        FlowElement element = new FlowElement();
        element.setName(recordRollbackElement.name);
        element.setLabel(recordRollbackElement.label);
        element.setType(ELEMENT_TYPE_RECORD_ROLLBACK);
        element.setDescription(recordRollbackElement.description);
        element.setCoordinates(recordRollbackElement.locationX, recordRollbackElement.locationY);
        element.setTargetReference(recordRollbackElement.connector);
        element.setRecordRollbackMetadata(recordRollbackElement);

        return element;
    }


    /**
     * Merges logging elements into the original MetadataService.Flow
     * @param originalFlow The original MetadataService.Flow
     * @param flowElements Map of flow elements containing logging elements
     * @return Updated MetadataService.Flow
     */
    public MetadataService.Flow mergeLogElementsIntoFlow(FlowLoggingContext context) {
        if (context?.flow == null || context?.flowElements == null) {
            return context?.flow;
        }

        List<MetadataService.FlowActionCall> actionCalls = new List<MetadataService.FlowActionCall>();
        Map<String, MetadataService.FlowTextTemplate> elementTemplates = new Map<String, MetadataService.FlowTextTemplate>();
        
        // Scale coordinates and sort elements
        List<FlowElementWrapper> sortedElements = scaleCoordinatesAndSort(context.flowElements);
        
        // Process elements in order
        for (FlowElementWrapper wrapper : sortedElements) {
            FlowElement element = wrapper.element;
            
            if (isLoggingElement(element.getName())) {
                MetadataService.FlowTextTemplate flowTemplate = createFlowTemplate(context, element);
                elementTemplates.put(element.getName(), flowTemplate);
                
                MetadataService.FlowActionCall actionCall = createLoggingActionCall(element, context, elementTemplates);
                actionCalls.add(actionCall);
            }
        }
        
        // Update existing elements' connectors
        updateFlowConnectors(context);
        
        // Update action calls
        updateActionCalls(context, actionCalls);

        // Update start element reference
        updateStartElementReference(context);
        
        // Update flow templates and variables
        updateFlowTemplates(context, elementTemplates);

        return context.flow;
    }

    private void updateFlowTemplates(FlowLogService.FlowLoggingContext context, Map<String, MetadataService.FlowTextTemplate> elementTemplates) {
        // add new templates and variables
        if(!elementTemplates.isEmpty()) {
            if(context.flow.textTemplates == null) {
                context.flow.textTemplates = new List<MetadataService.FlowTextTemplate>();
            }
            if(elementTemplates != null && !elementTemplates.isEmpty()) {
                context.flow.textTemplates.addAll(elementTemplates.values());
            }

            if(context.flow.variables == null) {
                context.flow.variables = new List<MetadataService.FlowVariable>();
            }
            context.flow.variables.add(createVariable(PHAROS_VARIABLE_NAME, ''));
        }
        // remove old templates and variables
        else {            
            if(context.flow.textTemplates != null) {
                List<MetadataService.FlowTextTemplate> newTextTemplates = new List<MetadataService.FlowTextTemplate>();
                for(Integer i = 0; i < context.flow.textTemplates.size(); i++) {
                    if(!context.flow.textTemplates[i].name.endsWith(PHAROS_TEMPLATE_MARKER)) {
                        newTextTemplates.add(context.flow.textTemplates[i]);
                    }
                }
                context.flow.textTemplates = newTextTemplates;
            }

            if(context.flow.variables != null) {
                List<MetadataService.FlowVariable> newVariables = new List<MetadataService.FlowVariable>();
                for(Integer i = 0; i < context.flow.variables.size(); i++) {
                    if(context.flow.variables[i].name != PHAROS_VARIABLE_NAME) {
                        newVariables.add(context.flow.variables[i]);
                    }
                }
                context.flow.variables = newVariables;
            }
        }
    }

    private void updateStartElementReference(FlowLogService.FlowLoggingContext context) {
        FlowElement startElement = context.flowElements.get(ELEMENT_TYPE_START);
        if (startElement != null && startElement.getTargetReference() != null) {
            // <extendedErrorCode>BOTH_START_NODE_AND_REFERENCE_FOUND</extendedErrorCode>
            if(context.flow.start != null) {
                if(context.flow.start.connector == null) {
                    context.flow.start.connector = new MetadataService.FlowConnector();
                }
                context.flow.start.connector.targetReference = startElement.getTargetReference();
            }
            else {
                context.flow.startElementReference = startElement.getTargetReference();
            }
        }
    }

    private void updateActionCalls(FlowLogService.FlowLoggingContext context, List<MetadataService.FlowActionCall> actionCalls) {
        // Add new logging actions to the flow
        if(actionCalls != null && !actionCalls.isEmpty()) {
            if (context.flow.actionCalls == null) {
                context.flow.actionCalls = new List<MetadataService.FlowActionCall>();
            }
            context.flow.actionCalls.addAll(actionCalls);
        }
        else {
            if(context.flow.actionCalls != null) {
                List<MetadataService.FlowActionCall> newActionCalls = new List<MetadataService.FlowActionCall>();
                for(Integer i = 0; i < context.flow.actionCalls.size(); i++) {
                    if(!context.flow.actionCalls[i].name.contains(POST_LOG_MARKER) 
                        && !context.flow.actionCalls[i].name.contains(PRE_LOG_MARKER) 
                        && !context.flow.actionCalls[i].name.contains(POST_PRE_LOG_MARKER)) {
                        
                        newActionCalls.add(context.flow.actionCalls[i]);
                    }
                }
                context.flow.actionCalls = newActionCalls;
            }
        }
    }

    private MetadataService.FlowVariable createVariable(String name, String value) {
        MetadataService.FlowVariable variable = new MetadataService.FlowVariable();
        variable.name = name;
        variable.description = 'Pharos Full Stacktrace';
        variable.isInput = true;
        variable.isOutput = true;
        variable.value = new MetadataService.FlowElementReferenceOrValue();
        variable.value.stringValue = ' ';
        variable.dataType = 'String';
        return variable;
    }

    private MetadataService.FlowTextTemplate createFlowTemplate(FlowLogService.FlowLoggingContext context, FlowElement element) {
        MetadataService.FlowTextTemplate flowTemplate = new MetadataService.FlowTextTemplate();
        flowTemplate.name = getTemplateName(element.getName());
        flowTemplate.description = 'Pharos Flow Template for ' + element.getLabel();
        flowTemplate.isViewedAsPlainText = true;
        flowTemplate.text = buildFlowLogTextTemplateBody(context, element);
        return flowTemplate;
    }

    @TestVisible
    private static String getTemplateName(String elementName) {
        return truncateElementName(elementName + PHAROS_TEMPLATE_MARKER);
    }

    /**
     * Checks if the given element name is a logging element
     * @param elementName The name of the element to check
     * @return True if the element name is a logging element, false otherwise
     */
    @TestVisible
    private static Boolean isLoggingElement(String elementName) {
        return elementName?.endsWith(PRE_LOG_MARKER) || 
               elementName?.endsWith(POST_LOG_MARKER) || 
               elementName?.endsWith(POST_PRE_LOG_MARKER) ||
               elementName.startsWith(LOG_ELEMENT_HASH_MARKER);
    }
       
    /**
     * Creates a logging action call for the given flow element
     * @param logElement The flow element to create a logging action call for
     * @return The created logging action call
     */
    private MetadataService.FlowActionCall createLoggingActionCall(FlowElement logElement,
                                               FlowLogService.FlowLoggingContext context,
                                               Map<String, MetadataService.FlowTextTemplate> flowTemplates) {

        MetadataService.FlowActionCall actionCall = new MetadataService.FlowActionCall();
        actionCall.name = logElement.getName();
        actionCall.label = logElement.getLabel();
        actionCall.actionType = TRITON_ACTION_TYPE;
        actionCall.actionName = TRITON_LOG_ACTION_NAME;
        actionCall.locationX = logElement.getX();
        actionCall.locationY = logElement.getY();
        actionCall.description = logElement.getDescription();
        

        // Create connector if there's a target
        if (String.isNotBlank(logElement.getTargetReference())) {
            actionCall.connector = new MetadataService.FlowConnector();
            actionCall.connector.targetReference = logElement.getTargetReference();
            if(logElement.getIsGoTo(logElement.getTargetReference())) {
                actionCall.connector.isGoTo = true;
            }
        }
        
        // Add parameters for logging
        actionCall.inputParameters = new List<MetadataService.FlowActionCallInputParameter>();
        actionCall.inputParameters.addAll(createInputParameters(logElement, context, flowTemplates));
        
        // Add output parameters for logging
        actionCall.outputParameters = new List<MetadataService.FlowActionCallOutputParameter>();
        actionCall.outputParameters.add(createOutputParameter(LOGGER_OUTPUT_PARAMETER_FULL_STACKTRACE_NAME, PHAROS_VARIABLE_NAME));

        return actionCall;
    }

    private List<MetadataService.FlowActionCallInputParameter> createInputParameters(FlowElement logElement,
                                                                  FlowLogService.FlowLoggingContext context,
                                                                  Map<String, MetadataService.FlowTextTemplate> flowTemplates) {
        

        List<MetadataService.FlowActionCallInputParameter> inputParameters = new List<MetadataService.FlowActionCallInputParameter>();
        inputParameters.add(createCategoryInputParameter(logElement));
        inputParameters.add(createTypeInputParameter(logElement, context));
        inputParameters.add(createAreaInputParameter(logElement, context));
        inputParameters.add(createSummaryInputParameter(logElement));
        inputParameters.add(createDetailsInputParameter(logElement));
        inputParameters.add(createInterviewGUIDInputParameter(logElement));
        inputParameters.add(createFlowAPINameInputParameter(logElement, context));
        inputParameters.add(createOperationInputParameter(logElement));
        inputParameters.add(createLevelInputParameter(logElement));
        inputParameters.add(createStacktraceInputParameter(logElement, flowTemplates));
        inputParameters.add(createFullStacktraceInputParameter(logElement));
        
        return inputParameters;
    }

    private MetadataService.FlowActionCallInputParameter createFullStacktraceInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_FULL_STACKTRACE_NAME, toFlowVariable(PHAROS_VARIABLE_NAME));
    }
    
    private MetadataService.FlowActionCallInputParameter createCategoryInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_CATEGORY_NAME, LOGGER_INPUT_PARAMETER_CATEGORY_DEFAULT_VALUE);
    }

    private MetadataService.FlowActionCallInputParameter createTypeInputParameter(FlowElement logElement, FlowLogService.FlowLoggingContext context) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_TYPE_NAME, context.flowType ?? LOGGER_INPUT_PARAMETER_TYPE_DEFAULT_VALUE);
    }

    private MetadataService.FlowActionCallInputParameter createAreaInputParameter(FlowElement logElement, FlowLogService.FlowLoggingContext context) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_AREA_NAME, context.functionalArea);
    }

    private MetadataService.FlowActionCallInputParameter createSummaryInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_SUMMARY_NAME, logElement.getLabel());
    }

    private MetadataService.FlowActionCallInputParameter createDetailsInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_DETAILS_NAME, 'Executed: ' + logElement.getLabel());
    }

    private MetadataService.FlowActionCallInputParameter createStacktraceInputParameter(FlowElement logElement, Map<String, MetadataService.FlowTextTemplate> flowTemplates) {
        MetadataService.FlowTextTemplate flowTemplate = flowTemplates.get(logElement.getName());
        String details = flowTemplate?.text;
        return createInputParameter(LOGGER_INPUT_PARAMETER_STACKTRACE_NAME, toFlowVariable(flowTemplate.name));
    }

    private MetadataService.FlowActionCallInputParameter createInterviewGUIDInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_GUID_NAME, '{!$Flow.InterviewGuid}');
    }

    private MetadataService.FlowActionCallInputParameter createFlowAPINameInputParameter(FlowElement logElement, FlowLogService.FlowLoggingContext context) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_FLOW_API_NAME, context.flow.fullName);
    }

    private MetadataService.FlowActionCallInputParameter createOperationInputParameter(FlowElement logElement) {
        return createInputParameter(LOGGER_INPUT_PARAMETER_OPERATION_NAME, getOperationName(logElement));
    }

    private MetadataService.FlowActionCallInputParameter createLevelInputParameter(FlowElement logElement) {
        String levelValue = getLogLevel(logElement);
        return createInputParameter(LOGGER_INPUT_PARAMETER_LEVEL_NAME, levelValue);
    }

    @TestVisible
    private static String getOperationName(FlowElement logElement) {
        String result = logElement.getSourceType();
        if(result == ELEMENT_TYPE_DECISION_RULE) {
            result = ELEMENT_TYPE_DECISION;
        }
        if(result == ELEMENT_TYPE_WAIT_EVENT) {
            result = ELEMENT_TYPE_WAIT;
        }
        return result;
    }

    @TestVisible
    private static String getLogLevel(FlowElement logElement) {
        String result = 'FINER';
        if (ELEMENT_LOG_LEVELS.containsKey(logElement.getSourceType() ?? logElement.getType())) {
            result = ELEMENT_LOG_LEVELS.get(logElement.getSourceType() ?? logElement.getType());
        }
        if (String.isNotBlank(logElement?.getConnectionType()) && logElement?.getConnectionType()?.contains(ELEMENT_CONNECTION_FAULT_MARKER)) {
            result = 'WARNING';
        }
        return result;
    }

    public class StringBuilder {
        private String buffer;

        public StringBuilder() {
            buffer = '';
        }

        public StringBuilder append(String str) {
            buffer += str;
            return this;
        }

        public override String toString() {
            return buffer;
        }
    }

    private String buildFlowLogTextTemplateBody(FlowLogService.FlowLoggingContext context, FlowElement element) {

        StringBuilder html = new StringBuilder();

        if(element != null && isLoggingElement(element.getName())) {
            Map<String, ElementInfo> elementInfo = parseLogElementDescription(element.getDescription());

            String parentSourceElementName = elementInfo?.get(SOURCE_INFO_KEY)?.parentName;
            String sourceConnectionName = elementInfo?.get(SOURCE_INFO_KEY)?.connectionName;
            String sourceElementName = elementInfo?.get(SOURCE_INFO_KEY)?.name;

            // handle the case where the source element is a loop
            Boolean isLoopOutcomeNoMore = (String.isNotBlank(sourceConnectionName) && sourceConnectionName.endsWith(ELEMENT_CONNECTION_NOMORE_MARKER.removeStart('_')));
         
            FlowElement sourceElement;
            FlowElement ruleElement;

            // get the rule element for the source element (decision - rule, wait - event, start - scheduled path)
            if(parentSourceElementName != null) {
                sourceElement = context.flowElements.get(parentSourceElementName);
                ruleElement = getRuleElement(sourceElement, sourceElementName);
            }
            else {
                sourceElement = context.flowElements.get(sourceElementName);
            }

            // process the source element first
            List<FlowElement> elementToProcessList = new List<FlowElement>();
            if(sourceElement != null) {
                elementToProcessList.add(sourceElement);
            }            
            elementToProcessList.add(element);

            
            for(FlowElement elementToProcess : elementToProcessList) {
                // Element Execution Details
                if (elementToProcess != null) {
                    if(elementToProcess.getType() == ELEMENT_TYPE_START) {
                        html.append(buildStartSection(elementToProcess, context));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_SCREEN) {
                        html.append(buildScreenSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_RECORD_LOOKUP) {
                        html.append(buildRecordLookupSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_RECORD_UPDATE) {
                        html.append(buildRecordUpdateSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_RECORD_CREATE) {
                        html.append(buildRecordCreateSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_RECORD_DELETE) {
                        html.append(buildRecordDeleteSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_DECISION) {
                        html.append(buildDecisionSection(elementToProcess, ruleElement));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_LOOP) {
                        html.append(buildLoopSection(elementToProcess, isLoopOutcomeNoMore));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_ASSIGNMENT) {
                        html.append(buildAssignmentSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_SUBFLOW) {
                        html.append(buildSubflowSection(elementToProcess, context.subflowsInfo));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_WAIT) {
                        html.append(buildWaitSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_COLLECTION_PROCESSOR) {
                        html.append(buildCollectionProcessorSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_FORMULA) {
                        html.append(buildFormulaSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_APEX_PLUGIN) {
                        html.append(buildApexPluginSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_ACTION_CALL) {
                        html.append(buildApexActionSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_CUSTOM_ERROR) {
                        html.append(buildCustomErrorSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_TRANSFORM) {
                        html.append(buildTransformSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_CHOICE) {
                        html.append(buildChoiceSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_ORCHESTRATED_STAGE) {
                        html.append(buildOrchestratedStageSection(elementToProcess));
                    }                    
                    if (elementToProcess.getType() == ELEMENT_TYPE_CONSTANT) {
                        html.append(buildConstantSection(elementToProcess));
                    }
                    if (elementToProcess.getType() == ELEMENT_TYPE_RECORD_ROLLBACK) {
                        html.append(buildRecordRollbackSection(elementToProcess));
                    }
                }
            }
        }               

        return html.toString();
    }

    private FlowElement getRuleElement(FlowElement sourceElement, String sourceElementName) {
        FlowElement ruleElement = null;

        if (sourceElement.getType() == ELEMENT_TYPE_DECISION) {
            for(FlowElement rule : sourceElement.getRules().values()) {
                if(rule.getName() == sourceElementName) {
                    ruleElement = rule;
                    break;
                }
            }
        }
        else if(sourceElement.getType() == ELEMENT_TYPE_WAIT) {
            for(FlowElement event : sourceElement.getEvents().values()) {
                if(event.getName() == sourceElementName) {
                    ruleElement = event;
                    break;
                }
            }
        }
        else if(sourceElement.getType() == ELEMENT_TYPE_START) {
            for(FlowElement scheduledPath : sourceElement.getScheduledPaths().values()) {
                if(scheduledPath.getName() == sourceElementName) {
                    ruleElement = scheduledPath;
                    break;
                }
            }
        }
        return ruleElement;
    }

    private String buildStartSection(FlowElement element, FlowLogService.FlowLoggingContext context) {
        StringBuilder html = new StringBuilder();
        
        // Start HTML document
        html.append('<!DOCTYPE html><html><head><style>\n')
            .append('span,a {\n')
            .append(' font-size: 16px;')
            .append('}')
            .append('</style></head><body><p>\n')
            .append('<span><img src="https://a.sfdcstatic.com/shared/images/c360-nav/mobile_logo.png" alt="Salesforce logo" width="40px"></span><br>')
            .append('<span style="font-size:x-large;font-weight:bold">An Error Occurred with Your "' + context.flow.label + '" Flow</span><br><br>')
            .append('<span>You\'ve received this email because an error occurred while your "' + context.flow.label + '" flow was running. <a >Debug this flow in Flow Builder.</a><br></span><br>')
            .append('\n')
            .append('<span>Error element debug (FlowActionCall).</span><br>')
            .append('<span>Debug: end</span><br>')
            .append('</span><br>')
            .append('<br><a style="background-color:#0176D3;border-radius:4px;color:white;padding:.5rem 1rem;text-decoration:none">Open Flow</a><br>')
            .append('<br></p>\n')
            .append('<hr>\n')
            .append('<br><span style="font-size:x-large;font-weight:bold">Flow Error Details</span><br><br>\n');
          
        // Flow Details section
        html.append(buildFlowDetailsSection(context));
        
        // Flow Interview Details section
        html.append(buildInterviewDetailsSection(context));
        
        // How the Interview Started section
        html.append(buildInterviewStartSection(context));

        return html.toString();
    }    
       
    private String buildFlowDetailsSection(FlowLoggingContext context) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">Flow Details</span><br>\n' +
            '<br><span><span style="font-weight:bold;">Flow API Name: </span>{0}</span><br>\n' +
            '<span><span style="font-weight:bold;">Type: </span>{1}</span><br>\n' +
            '<span><span style="font-weight:bold;">Version: </span>{2}</span><br>\n' +
            '<span><span style="font-weight:bold;">Status: </span>{3}</span><br>\n' +
            '<span><span style="font-weight:bold;">Org: </span>{4} ({5})</span><br>\n' +
            '</p>\n',
            new List<String>{
                context.flow.fullName.split('-')[0],
                context.flow.type,
                String.valueOf(context.newVersionNumber),
                context.flow.status,
                '{!$Organization.Id}',
                '{!$Organization.Name}'
            }
        );
    }
    
    private String buildInterviewDetailsSection(FlowLoggingContext context) {
        return
            '<br><span style="font-weight:bold;">Flow Interview Details</span><br>\n' +
            '<br><span><span style="font-weight:bold;">Interview Label: </span>' + context.flow.label + '</span><br>\n' +
            '<span><span style="font-weight:bold;">Interview GUID: </span>{!$Flow.InterviewGuid}</span><br>\n' +
            '<span><span style="font-weight:bold;">Current User: </span>{!$User.FirstName} {!$User.LastName}</span><br>\n' +
            '<span><span style="font-weight:bold;">Start time: </span>{!$Flow.InterviewStartTime}</span><br>\n' +
            '<span><span style="font-weight:bold;">Duration: </span>0</span><br>\n' +
            '</p>\n';
    }

    private String buildInterviewStartSection(FlowLoggingContext context) {
        String recordContextInfo = (String.isNotBlank(context?.flow?.start?.object_x) ? String.format(
            '<span>Some of this flow\'s variables were set when the interview started.</span><br>\n' +
            '<span>$Record = {0} ({1})</span><br>\n',
            new List<String>{
                context?.flow?.start?.object_x,
                '{!$Record}'
            }
        ) : '');

        return String.format(
            '<br><span style="font-weight:bold;">How the Interview Started</span><br>\n' +
            '<span>{0} ({1}) started the flow interview.</span><br>\n' +
            '<span>API Version for Running the Flow: {2}</span><br>\n' +
            '{3}' +
            '</p>\n',
            new List<String>{
                '{!$User.FirstName} {!$User.LastName}',
                '{!$User.Id}',
                String.valueOf(FLOW_METADATA_VERSION),
                recordContextInfo
            }
        );
    }
    
    private String buildScreenSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">SCREEN: </span>{0}<br>\n' +
            '{1}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                buildScreenFieldsDetails(element)
            }
        );
    }
    
    private String buildRecordLookupSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">GET RECORDS: </span>{0}<br>\n' +
            '<span>Find all {1} records where:</span><br>\n' +
            '{2}\n' +
            '<span>Store the values of these fields: {3}</span><br>\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>{4} ({5})</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getRecordLookupMetadata()?.object_x,
                buildFilterCriteria(element),
                buildFieldOutputAssignments(element),
                element.getName(),
                toFlowVariable(element.getName())
            }
        );
    }

    private String buildRecordUpdateSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">UPDATE RECORDS: </span>{0}<br>\n' +
            '<span>Find all {1} records where:</span><br>\n' +
            '{2}\n' +
            '<span>Update the records\' field values.</span><br>\n' +
            '{3}\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>{4} ({5})</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getRecordUpdateMetadata()?.object_x,
                buildFilterCriteria(element),
                buildFieldInputAssignments(element),
                element.getName(),
                toFlowVariable(element.getName())
            }
        );
    }
    
    private String buildRecordCreateSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">CREATE RECORDS: </span>{0}<br>\n' +
            '<span>Create {1} record(s) with these field values:</span><br>\n' +
            '{2}\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>{3} ({4})</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getRecordCreateMetadata()?.object_x,
                buildFieldInputAssignments(element),
                element.getName(),
                toFlowVariable(element.getName())
            }
        );
    }
    
    private String buildRecordDeleteSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">DELETE RECORDS: </span>{0}<br>\n' +
            '<span>Delete {1} records where:</span><br>\n' +
            '{2}\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>{3} ({4})</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getRecordDeleteMetadata()?.object_x,
                buildFilterCriteria(element),
                element.getName(),
                toFlowVariable(element.getName())
            }
        );
    }
    
    private String buildDecisionSection(FlowElement element, FlowElement ruleElement) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">DECISION: </span>{0}<br>\n' +
            '{1}' +
            '{2}' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                buildDecisionSkippedRules(element, ruleElement),
                buildDecisionExecutedRule(element, ruleElement)
            }
        );
    }

    private String buildDecisionSkippedRules(FlowElement element, FlowElement ruleElement) {
        String skippedRules = '';
        if (!element.getRules().values().isEmpty()) {
            
            for(FlowElement rule : element.getRules().values()) {
                if((ruleElement != null && rule.getName() != ruleElement.getName()) || ruleElement == null) {
                    String skippedRule = String.format(
                        '<span>Skipped this outcome because its conditions weren\'t met: {0}</span><br>\n' +
                        '<span>Outcome conditions: </span><br>\n' +
                        '{1}' +
                        '<span>All conditions must be true ({2})</span><br>\n' +
                        '<br/>\n',
                        new List<String> {
                            rule.getName(),
                            buildDecisionRuleConditions(rule),
                            rule.getRuleMetadata().conditionLogic
                        }
                    );
                    skippedRules += skippedRule;
                }
            }
        }
        return skippedRules;
    }

    private String buildDecisionRuleConditions(FlowElement ruleElement) {
        String conditions = '';
        if (ruleElement?.getRuleMetadata()?.conditions != null) {
            for(MetadataService.FlowCondition condition : ruleElement?.getRuleMetadata()?.conditions) {
                conditions += String.format('<span>{0} ({1}) {2} {3}</span><br>\n',
                    new List<String> {
                        toFlowVariableName(condition.leftValueReference),
                        toFlowVariable(condition.leftValueReference),
                        condition.operator,
                        getElementReferenceOrValue(condition?.rightValue)
                    }
                    );
            }
        }
        return conditions;
    }

    private String buildDecisionExecutedRule(FlowElement element, FlowElement ruleElement) {
        if(ruleElement != null) {
            for(FlowElement rule : element.getRules().values()) {
                if(rule.getName() == ruleElement.getName()) {
                    return String.format(
                        '<span>Outcome executed: {0}</span><br>\n' +
                        '<span>Outcome conditions: </span><br>\n' +
                        '{1}\n' +
                        '<span>All conditions must be true ({2})</span><br>\n',
                        new List<String>{
                            rule.getName(),
                            buildDecisionRuleConditions(rule),
                            rule.getRuleMetadata().conditionLogic
                        }
                    );
                }
            }
        }
        return '<span>Default outcome executed.</span><br>\n';
    }

    private String toFlowVariableName(String value) {
        String result = '{!' + value + '}';
        if (result.startsWith('{!$')) {
            result = result.replaceFirst('\\{!\\$', '\\{! \\$');
        }
        else if (result.startsWith('{!')) {
            result = result.replaceFirst('\\{!', '\\{! ');
        }
        return result;
    }

    private String toFlowVariable(String value) {
        return '{!' + value + '}';
    }

    private String toFlowVariable(String value, String field) {
        return '{!' + value + (String.isNotBlank(field) ? '.' + field : '') + '}';
    }   


    private String buildLoopSection(FlowElement element, Boolean isLoopOutcomeNoMore) {
        if(isLoopOutcomeNoMore) {
            return String.format(
                '<p>\n' +
                '<span style="font-weight:bold;">LOOP: </span>{0}<br>\n' +
                '<span>End Loop.</span><br>\n' +
                '</p>\n',
                new List<String>{
                    element.getName()
                }
            );
        }
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">LOOP: </span>{0}<br>\n' +
            '<span>Loop Through: {1}</span><br>\n' +
            '<span>Current iteration item: {2}</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getName(),
                toFlowVariable(element.getLoopMetadata().collectionReference),
                toFlowVariable(element.getName())
            }
        );
    }
    
    private String buildAssignmentSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">ASSIGNMENT: </span>{0}<br>\n' +
            '{1}\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '{2}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                buildAssignmentDetails(element),
                buildAssignmentResult(element)
            }
        );        
    }

    // Helper methods
    private String buildFilterCriteria(FlowElement element) {
        List<String> criteria = new List<String>();
        
        if (element.getType() == ELEMENT_TYPE_RECORD_LOOKUP && element?.getRecordLookupMetadata()?.filters != null) {
            for (MetadataService.FlowRecordFilter filter : element?.getRecordLookupMetadata()?.filters) {
                criteria.add(String.format('<span>{0} {1} {2}</span><br>',
                    new List<String>{filter.field, filter.operator, getElementReferenceOrValue(filter?.value)}));
            }
        }
        if (element.getType() == ELEMENT_TYPE_RECORD_UPDATE && element?.getRecordUpdateMetadata()?.filters != null) {
            for (MetadataService.FlowRecordFilter filter : element?.getRecordUpdateMetadata()?.filters) {
                criteria.add(String.format('<span>{0} {1} {2}</span><br>',
                    new List<String>{filter.field, filter.operator, getElementReferenceOrValue(filter?.value)}));
            }
        }
        if (element.getType() == ELEMENT_TYPE_RECORD_CREATE && element?.getRecordCreateMetadata()?.filters != null) {
            for (MetadataService.FlowRecordFilter filter : element?.getRecordCreateMetadata()?.filters) {
                criteria.add(String.format('<span>{0} {1} {2}</span><br>',
                    new List<String>{filter.field, filter.operator, getElementReferenceOrValue(filter?.value)}));
            }
        }
        if (element.getType() == ELEMENT_TYPE_RECORD_DELETE && element?.getRecordDeleteMetadata()?.filters != null) {
            for (MetadataService.FlowRecordFilter filter : element?.getRecordDeleteMetadata()?.filters) {
                criteria.add(String.format('<span>{0} {1} {2}</span><br>',
                    new List<String>{filter.field, filter.operator, getElementReferenceOrValue(filter?.value)}));
            }
        }        
        return String.join(criteria, '\n');

    }
    
    private String buildFieldInputAssignments(FlowElement element) {
        List<String> assignments = new List<String>();
        if (element.getType() == ELEMENT_TYPE_RECORD_CREATE && element?.getRecordCreateMetadata()?.inputAssignments != null) {
            for (MetadataService.FlowInputFieldAssignment assignment : element?.getRecordCreateMetadata()?.inputAssignments) {
                assignments.add(String.format('<span>{0} = {1}</span><br>',
                    new List<String>{assignment?.field, getElementReferenceOrValue(assignment?.value)}));
            }
        }
        else if (element.getType() == ELEMENT_TYPE_RECORD_UPDATE && element?.getRecordUpdateMetadata()?.inputAssignments != null) {
            for (MetadataService.FlowInputFieldAssignment assignment : element?.getRecordUpdateMetadata()?.inputAssignments) {
                assignments.add(String.format('<span>{0} = {1}</span><br>',
                    new List<String>{assignment?.field, getElementReferenceOrValue(assignment?.value)}));
            }
        }
        return String.join(assignments, '\n');
    }


    private String buildFieldOutputAssignments(FlowElement element) {

        List<String> assignments = new List<String>();
        if (element.getType() == ELEMENT_TYPE_RECORD_LOOKUP && element?.getRecordLookupMetadata()?.outputAssignments != null) {
            for (MetadataService.FlowOutputFieldAssignment assignment : element?.getRecordLookupMetadata()?.outputAssignments) {
                assignments.add(String.format('<span>{0} = {1}</span><br>',
                    new List<String>{assignment?.field, assignment?.assignToReference}));
            }
        }

        return String.join(assignments, '\n');
    }    
     
    private String buildAssignmentDetails(FlowElement element) {
        List<String> assignments = new List<String>();
        if (element?.getAssignmentMetadata()?.assignmentItems != null) {
            for (MetadataService.FlowAssignmentItem assignment : element?.getAssignmentMetadata()?.assignmentItems) {
                assignments.add(String.format('<span>{0} {1} {2}</span><br>',
                    new List<String>{
                        assignment.assignToReference,
                        assignment.operator,
                        getElementReferenceOrValue(assignment?.value)                        
                    })
                );
            }     
        }
        return String.join(assignments, '\n');
    }
    

    private String buildAssignmentResult(FlowElement element) {
        List<String> assignments = new List<String>();
        if (element?.getAssignmentMetadata()?.assignmentItems != null) {
            for (MetadataService.FlowAssignmentItem assignment : element?.getAssignmentMetadata()?.assignmentItems) {
                assignments.add(String.format('<span>{0} = {2}</span><br>',
                    new List<String>{
                        assignment.assignToReference,
                        assignment.operator,
                        toFlowVariable(assignment.assignToReference)
                    })
                );
            }
        }
        return String.join(assignments, '\n');
    }
    
    private String buildScreenFieldsDetails(FlowElement element) {
        List<String> fieldDetails = new List<String>();
        if (element?.getScreenMetadata()?.fields != null) {
            for (MetadataService.FlowScreenField field : element?.getScreenMetadata()?.fields) {
                // Process each field type with its own method
                String fieldDetail = '';
                
                if (field.fieldType == 'DisplayText') {
                    fieldDetail = buildDisplayTextField(field);
                } else if (field.fieldType == 'InputField' || field.fieldType == 'LargeTextArea' || field.fieldType == 'PasswordField') {
                    fieldDetail = buildInputField(field);
                } else if (field.fieldType == 'RadioButtons' || field.fieldType == 'DropdownBox') {
                    fieldDetail = buildSingleChoiceField(field);
                } else if (field.fieldType == 'MultiSelectCheckboxes' || field.fieldType == 'MultiSelectPicklist') {
                    fieldDetail = buildMultiChoiceField(field);
                } else if (field.fieldType == 'ComponentInstance') {
                    fieldDetail = buildComponentInstanceField(field);
                } else if (field.fieldType == 'RegionContainer') {
                    fieldDetail = buildRegionContainerField(field);
                } else if (field.fieldType == 'Region') {
                    fieldDetail = buildRegionField(field);
                } else if (field.fieldType == 'ObjectProvided') {
                    fieldDetail = buildObjectProvidedField(field);
                } else {
                    // Default handler for other field types
                    fieldDetail = buildGenericField(field);
                }
                
                fieldDetails.add(fieldDetail);
                
                // Recursively process nested fields for regions and containers
                if ((field.fieldType == 'RegionContainer' || field.fieldType == 'Region') && field.fields != null && !field.fields.isEmpty()) {
                    fieldDetails.add('\n<span style="font-weight:bold;">Nested fields:</span><br>\n');
                    
                    for (MetadataService.FlowScreenField nestedField : field.fields) {
                        // Create a temporary FlowElement to represent the nested field
                        FlowElement tempElement = new FlowElement();
                        MetadataService.FlowScreen tempScreen = new MetadataService.FlowScreen();
                        tempScreen.fields = new List<MetadataService.FlowScreenField>{ nestedField };
                        tempElement.setScreenMetadata(tempScreen);
                        
                        // Process the nested field and indent its output
                        String nestedDetails = buildScreenFieldsDetails(tempElement);
                        fieldDetails.add(nestedDetails);
                    }
                }
            }
        }
        return String.join(fieldDetails, '<br>');
    }

    private static final String DISPLAY_TEXT_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Text: {3}</span><br>\n';
    
    // Individual field type builders
    private String buildDisplayTextField(MetadataService.FlowScreenField field) {
        return String.format(DISPLAY_TEXT_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            field.fieldText ?? ''
        });
    }

    private static final String INPUT_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Required: {3}</span><br>\n' +
                          '<span>Value at runtime: {4}</span><br>\n';
    
    private String buildInputField(MetadataService.FlowScreenField field) {
        return String.format(INPUT_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            String.valueOf(field.isRequired),
            '{!' + (field.name ?? '') + '}'
        });
    }

    private static final String SINGLE_CHOICE_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Required: {3}</span><br>\n' +
                          '<span>Choices: {4}</span><br>\n' +
                          '<span>Value at runtime: {5}</span><br>\n';

    private String buildSingleChoiceField(MetadataService.FlowScreenField field) {
        return String.format(SINGLE_CHOICE_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            String.valueOf(field.isRequired),
            formatChoiceReferences(field.choiceReferences),
            '{!' + (field.name ?? '') + '}'
        });
    }

    private static final String MULTI_CHOICE_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Required: {3}</span><br>\n' +
                          '<span>Choices: {4}</span><br>\n' +
                          '<span>Values at runtime: {5}</span><br>\n';
    
    private String buildMultiChoiceField(MetadataService.FlowScreenField field) {
        return String.format(MULTI_CHOICE_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            String.valueOf(field.isRequired),
            formatChoiceReferences(field.choiceReferences),
            '{!' + (field.name ?? '') + '}'
        });
    }

    private static final String COMPONENT_INSTANCE_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Component: {3}</span><br>\n';
    
    private String buildComponentInstanceField(MetadataService.FlowScreenField field) {
        String output = String.format(COMPONENT_INSTANCE_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            field.extensionName ?? 'Unknown Component'
        });
        
        if (field.storeOutputAutomatically) {
            output += '<span>Outputs stored automatically</span><br>\n';
        }
        
        return output;
    }

    private static final String REGION_CONTAINER_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Section Type: {3}</span><br>\n' +
                          '<span>Contains {4} columns</span><br>\n';
    
    private String buildRegionContainerField(MetadataService.FlowScreenField field) {
        return String.format(REGION_CONTAINER_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            field.regionContainerType ?? 'SectionWithHeader',
            String.valueOf(field.fields?.size() ?? 0)
        });
    }

    private static final String REGION_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Column in section</span><br>\n' +
                          '<span>Contains {3} fields</span><br>\n';
    
    private String buildRegionField(MetadataService.FlowScreenField field) {
        return String.format(REGION_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType,
            String.valueOf(field.fields?.size() ?? 0)
        });
    }

    private static final String OBJECT_PROVIDED_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n' +
                          '<span>Object Field: {3}</span><br>\n' +
                          '<span>Value at runtime: {4}</span><br>\n';
    
    private String buildObjectProvidedField(MetadataService.FlowScreenField field) {
        // The field.name can be null for ObjectProvided fields, so we need to use objectFieldReference
        String fieldName = String.isNotBlank(field?.name) ? field?.name : field?.objectFieldReference ?? 'Unknown Field';
        String fieldLabel = String.isNotBlank(field?.fieldText) ? field?.fieldText : field?.objectFieldReference ?? fieldName;

        return String.format(OBJECT_PROVIDED_FIELD_TEMPLATE, new List<String>{
            fieldName,
            fieldLabel,
            field.fieldType,
            field.objectFieldReference ?? 'Unknown Field',
            '{!' + (field?.objectFieldReference ?? '') + '}'
        });
    }

    private static final String GENERIC_FIELD_TEMPLATE = '<span style="font-weight:bold;">{0}: </span>{1}<br>\n' +
                          '<span>Type: {2}</span><br>\n';
    
    private String buildGenericField(MetadataService.FlowScreenField field) {
        return String.format(GENERIC_FIELD_TEMPLATE, new List<String>{
            field.name ?? '',
            field.fieldText ?? field.name ?? '',
            field.fieldType
        });
    }

    private String formatChoiceReferences(List<String> choiceReferences) {
        if (choiceReferences == null || choiceReferences.isEmpty()) {
            return 'None';
        }
        return String.join(choiceReferences, ', ');
    }

    private String buildSubflowSection(FlowElement element, Map<String, String> subflowsInfo) {
        return buildStartSubflowSection(element, subflowsInfo) + buildSubflowEndSection(element, subflowsInfo);
    }
    
    private String buildStartSubflowSection(FlowElement element, Map<String, String> subflowsInfo) {
        String subflowVersion = subflowsInfo.get(element.getSubflowMetadata()?.flowName);
        
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">SUBFLOW: </span>{0}<br>\n' +
            '<span>Enter flow {1} version {2}</span><br>\n' +
            '<span>API Version for Running the Flow: 62</span><br>\n' +
            '<span style="font-weight:bold;">Inputs:</span><br>\n' +
            '{3}\n' +
            '<span style="font-weight:bold;">Outputs:</span><br>\n' +
            '{4}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getSubflowMetadata()?.flowName,
                subflowVersion,
                buildSubflowInputParameters(element),
                buildSubflowOutputParameters(element)
            }
        );
    }

    private String buildSubflowEndSection(FlowElement element, Map<String, String> subflowsInfo) {
        String subflowVersion = subflowsInfo.get(element.getSubflowMetadata()?.flowName);
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">SUBFLOW: </span>{0}<br>\n' +
            '<span>Exit flow {1} version {2}</span><br>\n' +
            '<span>API Version for Running the Flow: 62</span><br>\n' +
            '<span style="font-weight:bold;">Inputs:</span><br>\n' +
            '{3}\n' +
            '<span style="font-weight:bold;">Outputs:</span><br>\n' +
            '{4}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getSubflowMetadata()?.flowName,
                subflowVersion,
                buildSubflowInputParameters(element),
                buildSubflowOutputParameters(element)
            }
        );
    }
    
    private String buildWaitSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">WAIT: </span>{0}<br>\n' +
            '<span>Waiting for: {1}</span><br>\n' +
            '{2}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getWaitMetadata()?.elementSubtype,
                buildWaitEventDetails(element)
            }
        );
    }
    
    private String buildCollectionProcessorSection(FlowElement element) {
        if (element.getCollectionProcessorMetadata()?.collectionProcessorType == 'FilterCollectionProcessor') {
            return String.format(
                '<p>\n' +
                '<span style="font-weight:bold;">COLLECTION FILTER: </span>{0}<br>\n' +
                '<span>Operation: {1}</span><br>\n' +
                '<span>Source Collection: {2}</span><br>\n' +
                '<span>Result Collection: {3}</span><br>\n' +
                '<span>Result: {4}</span><br>\n' +
                '</p>\n',
                new List<String>{
                    element.getLabel(),
                    element.getCollectionProcessorMetadata()?.collectionProcessorType,
                    toFlowVariable(element.getCollectionProcessorMetadata()?.collectionReference),
                    toFlowVariable(element.getCollectionProcessorMetadata()?.assignNextValueToReference),
                    toFlowVariable(element.getName())
                }
            );
        }
        else if (element.getCollectionProcessorMetadata()?.collectionProcessorType == 'SortCollectionProcessor') {
            return String.format(
                '<p>\n' +
                '<span style="font-weight:bold;">COLLECTION SORT: </span>{0}<br>\n' +
                '<span>Operation: {1}</span><br>\n' +
                '<span>Source Collection: {2}</span><br>\n' +
                '<span>Result Collection: {3}</span><br>\n' +
                '</p>\n',
                new List<String>{
                    element.getLabel(),
                    element.getCollectionProcessorMetadata()?.collectionProcessorType,
                    toFlowVariable(element.getName()),
                    toFlowVariable(element.getCollectionProcessorMetadata()?.collectionReference)
                }
            );
        }
        return '';
    }
    
    private String buildFormulaSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">FORMULA: </span>{0}<br>\n' +
            '<span>Formula Expression: {1}</span><br>\n' +
            '<span>Data Type: {2}</span><br>\n' +
            '<span>Scale: {3}</span><br>\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>{4}</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getFormulaMetadata()?.expression,
                element.getFormulaMetadata()?.dataType,
                String.valueOf(element.getFormulaMetadata()?.scale),
                toFlowVariable(element.getName())
            }
        );
    }
    
    private String buildApexPluginSection(FlowElement element) {
        MetadataService.FlowApexPluginCall apexPluginMeta = element.getApexPluginCallMetadata();
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">(APEX): </span>{0}<br>\n' +
            '<span>Apex Class: {1}</span><br>\n' +
            '{2}\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '{3}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                apexPluginMeta?.apexClass,
                buildApexPluginInputParameters(apexPluginMeta?.inputParameters),
                buildApexPluginOutputParameters(apexPluginMeta?.outputParameters)
            }
        );
    }

    private String buildApexPluginInputParameters(List<MetadataService.FlowApexPluginCallInputParameter> inputParams) {
        List<String> params = new List<String>();
        if (inputParams != null) {
            for (MetadataService.FlowApexPluginCallInputParameter param : inputParams) {
                params.add(String.format('<span>  {0} = {1}</span>',
                    new List<String>{param.name, getElementReferenceOrValue(param?.value)}));
            }
        }
        return String.join(params, '<br>\n');
    }

    private String buildApexPluginOutputParameters(List<MetadataService.FlowApexPluginCallOutputParameter> outputParams) {
        List<String> params = new List<String>();
        if (outputParams != null) {
            for (MetadataService.FlowApexPluginCallOutputParameter param : outputParams) {
                params.add(String.format('<span>  {0} => {1}</span>',
                    new List<String>{param.name, toFlowVariable(param.assignToReference)}));
            }
        }
        return String.join(params, '<br>\n');
    }

    private String buildApexActionSection(FlowElement element) {
        MetadataService.FlowActionCall actionMeta = element.getActionCallMetadata();
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">(APEX): </span>{0}<br>\n' +
            '<span style="font-weight:bold;">Inputs:</span><br>\n' +
            (actionMeta?.inputParameters != null ? '{1}\n' : '') +
            '<span style="font-weight:bold;">Outputs:</span><br>\n' +
            (actionMeta?.outputParameters != null ? '{2}\n' : '') +
            '</p>\n',
            new List<String>{
                element.getName(),
                buildActionInputParameters(actionMeta?.inputParameters),
                buildActionOutputParameters(actionMeta?.outputParameters)
            }
        );
    }

    private String buildActionInputParameters(List<MetadataService.FlowActionCallInputParameter> inputParams) {
        List<String> params = new List<String>();
        if (inputParams != null) {
            for (MetadataService.FlowActionCallInputParameter param : inputParams) {
                params.add(String.format('<span>{0} = {1}</span>',
                    new List<String>{param.name, getElementReferenceOrValue(param?.value)}));
            }
        }
        return String.join(params, '<br>\n');
    }

    private String buildActionOutputParameters(List<MetadataService.FlowActionCallOutputParameter> outputParams) {
        List<String> params = new List<String>();
        if (outputParams != null) {
            for (MetadataService.FlowActionCallOutputParameter param : outputParams) {
                params.add(String.format('<span>{0} => {1}</span>',
                    new List<String>{param.name, toFlowVariable(param.assignToReference)}));
            }
        }
        return String.join(params, '<br>\n');
    }
    
    private String buildCustomErrorSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">CUSTOM ERROR: </span>{0}<br>\n' +
            '<span>Message: {1}</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getCustomErrorMetadata()?.customErrorMessages?.get(0)?.errorMessage
            }
        );
    }
    
    // Helper methods for the sections above
    private String buildSubflowInputParameters(FlowElement element) {
        List<String> params = new List<String>();
        if (element.getSubflowMetadata()?.inputAssignments != null) {
            for (MetadataService.FlowSubflowInputAssignment param : element.getSubflowMetadata()?.inputAssignments) {
                params.add(String.format('<span>{0} = {1}</span><br>',
                    new List<String>{param.name, getElementReferenceOrValue(param?.value)}));
            }
        }
        return String.join(params, '\n');
    }
    
    private String buildSubflowOutputParameters(FlowElement element) {
        List<String> params = new List<String>();
        if (element.getSubflowMetadata()?.outputAssignments != null) {
            for (MetadataService.FlowSubflowOutputAssignment param : element.getSubflowMetadata()?.outputAssignments) {
                params.add(String.format('<span>{0} = {1}</span><br>',
                    new List<String>{param.assignToReference, toFlowVariable(param.assignToReference)}));
            }
        }
        return String.join(params, '\n');
    }
    
    private String buildWaitEventDetails(FlowElement element) {
        List<String> events = new List<String>();
        if (element.getWaitMetadata()?.waitEvents != null) {
            for (MetadataService.FlowWaitEvent event : element.getWaitMetadata()?.waitEvents) {
                events.add(String.format('<span>Event Type: {0}</span><br>' +
                    '<span>Condition: {1}</span><br>',
                    new List<String>{event.eventType, event.conditionLogic}));
            }
        }
        return String.join(events, '\n');
    }
      
    private String buildTransformSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">TRANSFORM: </span>{0}<br>\n' +
            '<span>Source Data: {1}</span><br>\n' +
            '<span>Target Data: {2}</span><br>\n' +
            '{3}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                toFlowVariable(element.getName()),
                element.getTransformMetadata()?.objectType,
                buildTransformMappings(element)

            }
        );
    }

    private String buildOrchestratedStageSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">ORCHESTRATED STAGE: </span>{0}<br>\n' +
            '<span>Stage Label: {1}</span><br>\n' +
            '<span>Exit Action: {2}</span><br>\n' +
            '{3}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getOrchestratedStageMetadata()?.label,
                String.valueOf(element.getOrchestratedStageMetadata()?.exitActionName),
                buildOrchestratedStageSteps(element)
            }
        );
    }

    private String buildOrchestratedStageSteps(FlowElement element) {
        List<String> steps = new List<String>();
        if (element.getStageSteps() != null) {
            for (FlowElement stageStep : element.getStageSteps().values()) {
                steps.add(String.format('<span>{0}</span><br>',
                    new List<String>{stageStep.getLabel()}));
            }
        }
        return String.join(steps, '\n');
    }
    
    private String buildChoiceSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">CHOICE: </span>{0}<br>\n' +
            '<span>Data Type: {1}</span><br>\n' +
            '<span>Choices:</span><br>\n' +
            '{2}\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getChoiceMetadata()?.dataType,
                buildChoiceOptions(element)
            }
        );
    }
    
    private String buildStageSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">STAGE: </span>{0}<br>\n' +
            '<span>Stage Label: {1}</span><br>\n' +
            '<span>Stage Order: {2}</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getStageMetadata()?.label,
                String.valueOf(element.getStageMetadata()?.stageOrder)

            }
        );
    }
    
    private String buildConstantSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">CONSTANT: </span>{0}<br>\n' +
            '<span>Data Type: {1}</span><br>\n' +
            '<span>Value: {2}</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel(),
                element.getConstantMetadata()?.dataType,
                getElementReferenceOrValue(element?.getConstantMetadata()?.value)
            }
        );
    }

    private String buildRecordRollbackSection(FlowElement element) {
        return String.format(
            '<p>\n' +
            '<span style="font-weight:bold;">RECORD ROLLBACK: </span>{0}<br>\n' +
            '<span style="font-weight:bold;">Result</span><br>\n' +
            '<span>Pending record changes in the current transaction are rolled back and not saved to the database.</span><br>\n' +
            '</p>\n',
            new List<String>{
                element.getLabel()
            }
        );
    }
    private String buildTransformMappings(FlowElement element) {
        List<String> mappings = new List<String>();
        if (element.getTransformMetadata()?.transformValues != null) {
            for (MetadataService.FlowTransformValue mapping : element.getTransformMetadata()?.transformValues) {
                if (mapping?.transformValueActions != null) {
                    for (MetadataService.FlowTransformValueAction item : mapping?.transformValueActions) {
                        mappings.add(String.format('<span>{0} = {1}</span><br>',
                            new List<String>{
                                item.outputFieldApiName,
                                (item?.value?.elementReference ?? getElementReferenceOrValue(item?.value))
                            }));
                    }
                }
            }
        }
        return String.join(mappings, '\n');
    }
    
    private String buildChoiceOptions(FlowElement element) {

        List<String> options = new List<String>();
        options.add(String.format('<span>Is Required: {0}, Prompt: {1}</span><br>',
            new List<String>{
                String.valueOf(element.getChoiceMetadata()?.userInput.isRequired),
                element.getChoiceMetadata()?.userInput.promptText
            }));
        return String.join(options, '\n');
    }


    public static String getElementReferenceOrValue(MetadataService.FlowElementReferenceOrValue value) {
        if (value == null) return 'null';

        if (value.complexValue != null) {
            return value.complexValue;
        }
        if (value.complexValueType != null) {
            return value.complexValueType;
        }
        if (value.elementReference != null) {
            return value.elementReference;
        }
        if (value.formulaDataType != null) {
            return value.formulaDataType;
        }
        if (value.formulaExpression != null) {
            return value.formulaExpression;
        }
        if (value.transformValueReference != null) {
            return value.transformValueReference;
        }
        if (value.apexValue != null) {
            return value.apexValue;
        }
        if (value.booleanValue != null) {
            return String.valueOf(value.booleanValue);
        }
        if (value.dateTimeValue != null) {
            return String.valueOf(value.dateTimeValue);
        }
        if (value.dateValue != null) {
            return String.valueOf(value.dateValue);
        }
        if (value.numberValue != null) {
            return String.valueOf(value.numberValue);
        }
        if (value.setupReference != null) {
            return value.setupReference;
        }
        if (value.setupReferenceType != null) {
            return value.setupReferenceType;
        }
        if (value.sobjectValue != null) {
            return value.sobjectValue;
        }
        return value.stringValue;
    }
    
    // Optional: Add a method to determine transaction status

    private Boolean hasTransactionError(FlowElement element) {
        if (element == null) return false;
        
        // Check for fault elements
        if (element.getType() == ELEMENT_TYPE_FAULT) return true;
        
        // Check DML operation results
        if (element.getType() == ELEMENT_TYPE_RECORD_CREATE || 
            element.getType() == ELEMENT_TYPE_RECORD_UPDATE || 
            element.getType() == ELEMENT_TYPE_RECORD_DELETE) {
            return true;// TODO:!element.isSuccess();
        }
        
        return false;
    }

    private MetadataService.FlowActionCallInputParameter createInputParameter(String name, String value) {
        MetadataService.FlowActionCallInputParameter param = new MetadataService.FlowActionCallInputParameter();
        param.name = name;
        
        MetadataService.FlowElementReferenceOrValue paramValue = new MetadataService.FlowElementReferenceOrValue();
        paramValue.stringValue = value;
        param.value = paramValue;
        
        return param;
    }

    private MetadataService.FlowActionCallOutputParameter createOutputParameter(String name, String value) {
        MetadataService.FlowActionCallOutputParameter param = new MetadataService.FlowActionCallOutputParameter();
        param.name = name;
        param.assignToReference = value;        
        return param;
    }

    private MetadataService.FlowConnector updateConnectorTargetReference(MetadataService.FlowConnector connector, FlowElement element) {
        return updateConnector(connector, element, element?.getTargetReference());
    }

    private MetadataService.FlowConnector updateConnectorDefaultTarget(MetadataService.FlowConnector connector, FlowElement element) {
        return updateConnector(connector, element, element?.getDefaultTarget());
    }

    private MetadataService.FlowConnector updateConnectorFaultTarget(MetadataService.FlowConnector connector, FlowElement element) {
        return updateConnector(connector, element, element?.getFaultTarget());
    }

    private MetadataService.FlowConnector updateConnectorNextValueTarget(MetadataService.FlowConnector connector, FlowElement element) {
        return updateConnector(connector, element, element?.getNextValueTarget());
    }

    private MetadataService.FlowConnector updateConnectorNoMoreValuesTarget(MetadataService.FlowConnector connector, FlowElement element) {
        return updateConnector(connector, element, element?.getNoMoreValuesTarget());
    }

    private MetadataService.FlowConnector updateConnector(MetadataService.FlowConnector connector, FlowElement element, String targetReference) {
        MetadataService.FlowConnector updatedConnector = connector;

        if (String.isNotBlank(targetReference)) {
            if(updatedConnector == null) {
                updatedConnector = new MetadataService.FlowConnector();
            }
            updatedConnector.targetReference = targetReference;

            if (element?.getIsGoTo(targetReference) != null) {
                updatedConnector.isGoTo = element.getIsGoTo(targetReference);
            }
        }
        else {
            updatedConnector = null;
        }
        return updatedConnector;
    }
    
    /**
     * Updates the connectors of the flow elements
     * @param flow The flow to update
     * @param flowElements The map of flow elements
     */
    private void updateFlowConnectors(FlowLogService.FlowLoggingContext context) {

        if (context.flow?.start?.scheduledPaths != null) {
            FlowElement element = context.flowElements.get(ELEMENT_TYPE_START);
            if (element != null) {

                for(MetadataService.FlowScheduledPath path : context.flow?.start?.scheduledPaths) {
                    for(FlowElement pathElement : element.getScheduledPaths().values()) {
                        if(path?.name == pathElement?.name) {
                            path.connector = updateConnectorTargetReference(path.connector, pathElement);                            
                        }
                    }
                }
            }
        }

        // Update Decision connectors
        if (context.flow.decisions != null) {
            for (MetadataService.FlowDecision decision : context.flow.decisions) {
                FlowElement element = context.flowElements.get(decision.name);
                if (element == null) continue;
                
                // Update default connector
                decision.defaultConnector = updateConnectorDefaultTarget(decision.defaultConnector, element);
                // Update location Y
                decision.locationY = element.getY();

                // Update rule connectors
                if (decision.rules != null && element.getRules() != null) {
                    for (MetadataService.FlowRule rule : decision.rules) {
                        FlowElement ruleTargetElement = element.getRules().get(rule.name);
                        if (ruleTargetElement == null) continue;

                        rule.connector = updateConnectorTargetReference(rule.connector, ruleTargetElement);
                    }
                }
            }
        }

        if (context.flow.waits != null) {
            for (MetadataService.FlowWait wait : context.flow.waits) {
                FlowElement element = context.flowElements.get(wait.name);
                if (element == null) continue;
                
                // Update default connector
                wait.defaultConnector = updateConnectorDefaultTarget(wait.defaultConnector, element);
                // Update fault connector
                wait.faultConnector = updateConnectorFaultTarget(wait.faultConnector, element);
                // Update location Y
                wait.locationY = element.getY();

                // Update rule connectors
                if (wait.waitEvents != null && element.getEvents() != null) {
                    for (MetadataService.FlowWaitEvent event : wait.waitEvents) {
                        FlowElement eventTargetElement = element.getEvents().get(event.name);
                        if (eventTargetElement == null) continue;

                        event.connector = updateConnectorTargetReference(event.connector, eventTargetElement);
                    }
                }
            }
        }
        
        // Update Loop connectors
        if (context.flow.loops != null) {
            for (MetadataService.FlowLoop loopElement : context.flow.loops) {
                FlowElement element = context.flowElements.get(loopElement.name);
                if (element == null) continue;

                loopElement.nextValueConnector = updateConnectorNextValueTarget(loopElement.nextValueConnector, element);
                loopElement.noMoreValuesConnector = updateConnectorNoMoreValuesTarget(loopElement.noMoreValuesConnector, element);
                loopElement.locationY = element.getY();
            }
        }

        if (context.flow.recordLookups != null) {
            for (MetadataService.FlowRecordLookup recordLookup : context.flow.recordLookups) {
                FlowElement element = context.flowElements.get(recordLookup.name);
                if (element == null) continue;

                recordLookup.connector = updateConnectorTargetReference(recordLookup.connector, element);
                recordLookup.faultConnector = updateConnectorFaultTarget(recordLookup.faultConnector, element);
                recordLookup.locationY = element.getY();
            }
        }

        // Update record create connectors
        if (context.flow.recordCreates != null) {
            for (MetadataService.FlowRecordCreate recordCreate : context.flow.recordCreates) {
                FlowElement element = context.flowElements.get(recordCreate.name);
                if (element == null) continue;

                recordCreate.connector = updateConnectorTargetReference(recordCreate.connector, element);
                recordCreate.faultConnector = updateConnectorFaultTarget(recordCreate.faultConnector, element);
                recordCreate.locationY = element.getY();
            }
        }

        // Update record update connectors
        if (context.flow.recordUpdates != null) {
            for (MetadataService.FlowRecordUpdate recordUpdate : context.flow.recordUpdates) {
                FlowElement element = context.flowElements.get(recordUpdate.name);
                if (element == null) continue;

                recordUpdate.connector = updateConnectorTargetReference(recordUpdate.connector, element);
                recordUpdate.faultConnector = updateConnectorFaultTarget(recordUpdate.faultConnector, element);
                recordUpdate.locationY = element.getY();
            }
        }

        // Update record delete connectors
        if (context.flow.recordDeletes != null) {
            for (MetadataService.FlowRecordDelete recordDelete : context.flow.recordDeletes) {
                FlowElement element = context.flowElements.get(recordDelete.name);
                if (element == null) continue;

                recordDelete.connector = updateConnectorTargetReference(recordDelete.connector, element);
                recordDelete.faultConnector = updateConnectorFaultTarget(recordDelete.faultConnector, element);
                recordDelete.locationY = element.getY();
            }
        }

        // Update screen connectors
        if (context.flow.screens != null) {
            for (MetadataService.FlowScreen screen : context.flow.screens) {
                FlowElement element = context.flowElements.get(screen.name);
                if (element == null) continue;

                screen.connector = updateConnectorTargetReference(screen.connector, element);                
                screen.locationY = element.getY();
            }
        }

        // Update assignment connectors
        if (context.flow.assignments != null) {
            for (MetadataService.FlowAssignment assignment : context.flow.assignments) {
                FlowElement element = context.flowElements.get(assignment.name);
                if (element == null) continue;

                assignment.connector = updateConnectorTargetReference(assignment.connector, element);
                assignment.locationY = element.getY();
            }
        }

        // Update subflow connectors
        if (context.flow.subflows != null) {
            for (MetadataService.FlowSubflow subflow : context.flow.subflows) {
                FlowElement element = context.flowElements.get(subflow.name);
                if (element == null) continue;

                subflow.connector = updateConnectorTargetReference(subflow.connector, element);
                subflow.locationY = element.getY();
            }
        }

        // Update transform connectors
        if (context.flow.transforms != null) {
            for (MetadataService.FlowTransform transform : context.flow.transforms) {
                FlowElement element = context.flowElements.get(transform.name);
                if (element == null) continue;

                transform.connector = updateConnectorTargetReference(transform.connector, element);
                transform.locationY = element.getY();
            }
        }

        // Update apex action connectors
        if (context.flow.apexPluginCalls != null) {
            for (MetadataService.FlowApexPluginCall apexCall : context.flow.apexPluginCalls) {
                FlowElement element = context.flowElements.get(apexCall.name);
                if (element == null) continue;

                apexCall.connector = updateConnectorTargetReference(apexCall.connector, element);
                apexCall.faultConnector = updateConnectorFaultTarget(apexCall.faultConnector, element);                
                apexCall.locationY = element.getY();
            }
        }

        // Update wait connectors
        if (context.flow.waits != null) {
            for (MetadataService.FlowWait wait : context.flow.waits) {
                FlowElement element = context.flowElements.get(wait.name);
                if (element == null) continue;

                wait.defaultConnector = updateConnectorDefaultTarget(wait.defaultConnector, element);
                wait.faultConnector = updateConnectorFaultTarget(wait.faultConnector, element);
                wait.locationY = element.getY();
                // Handle wait event connectors
                if (wait.waitEvents != null) {
                    for (MetadataService.FlowWaitEvent event : wait.waitEvents) {
                        // Get target from flowElements map based on event name/type
                        FlowElement eventElement = context.flowElements.get(event.name);
                        if (eventElement == null) continue;

                        event.connector = updateConnectorTargetReference(event.connector, eventElement);
                    }
                }
            }
        }

        // Update collection processor connectors
        if (context.flow.collectionProcessors != null) {
            for (MetadataService.FlowCollectionProcessor processor : context.flow.collectionProcessors) {
                FlowElement element = context.flowElements.get(processor.name);
                if (element == null) continue;

                processor.connector = updateConnectorTargetReference(processor.connector, element);                
                processor.locationY = element.getY();
            }
        }

        // Update stage connectors
        if (context.flow.orchestratedStages != null) {
            for (MetadataService.FlowOrchestratedStage stage : context.flow.orchestratedStages) {
                FlowElement element = context.flowElements.get(stage.name);
                if (element == null) continue;

                stage.connector = updateConnectorTargetReference(stage.connector, element);
                stage.locationY = element.getY();
            }
        }

        if (context.flow.customErrors != null) {
            for (MetadataService.FlowCustomError error : context.flow.customErrors) {
                FlowElement element = context.flowElements.get(error.name);
                if (element == null) continue;

                error.connector = updateConnectorTargetReference(error.connector, element);
                error.locationY = element.getY();
            }
        }

        if(context.flow.actionCalls != null) {
            for(MetadataService.FlowActionCall actionCall : context.flow.actionCalls) {
                FlowElement element = context.flowElements.get(actionCall.name);
                if (element == null) continue;

                actionCall.connector = updateConnectorTargetReference(actionCall.connector, element);
                actionCall.faultConnector = updateConnectorFaultTarget(actionCall.faultConnector, element);                
                actionCall.locationY = element.getY();
            }
        }

        if (context.flow.recordRollbacks != null) {
            for(MetadataService.FlowRecordRollback recordRollback : context.flow.recordRollbacks) {
                FlowElement element = context.flowElements.get(recordRollback.name);
                if (element == null) continue;

                recordRollback.connector = updateConnectorTargetReference(recordRollback.connector, element);
                recordRollback.locationY = element.getY();
            }
        }
    }

    // Add this wrapper class to handle sorting
    private class FlowElementWrapper implements Comparable {
        public FlowElement element;
        
        public FlowElementWrapper(FlowElement elem) {
            this.element = elem;
        }
        
        public Integer compareTo(Object other) {
            FlowElementWrapper otherWrapper = (FlowElementWrapper)other;
            Integer thisY = this.element.getY() != null ? this.element.getY() : 0;
            Integer otherY = otherWrapper.element.getY() != null ? otherWrapper.element.getY() : 0;
            
            if (thisY > otherY) return 1;
            if (thisY < otherY) return -1;
            return 0;
        }
    }

    private static final Integer BASE_Y_SCALE = 1;
    private static final Integer START_Y_POSITION = 250;
    private static final Integer ELEMENT_SPACING = 300; // Base spacing between elements
    private static final Integer LOG_OFFSET = 150; // Offset for logging elements
    private static final Integer TOLERANCE = 20; // Tolerance for grouping elements
    private static final Integer LOG_X_OFFSET = 75; // X offset for multiple logging elements

    private List<FlowElementWrapper> scaleCoordinatesAndSort(Map<String, FlowElement> flowElements) {
        List<FlowElementWrapper> sortedElements = new List<FlowElementWrapper>();
        Map<Integer, List<FlowElement>> yLevelGroups = new Map<Integer, List<FlowElement>>();
        
        // First pass - group elements by Y level with tolerance
        for (FlowElement elem : flowElements.values()) {
            if (elem == null || elem.getY() == null) continue;
            
            Integer elemY = Integer.valueOf(elem.getY());
            String elementName = elem.getName();
            Boolean isLogging = isLoggingElement(elementName);
            
            // For logging elements, find their associated main element's Y
            if (isLogging && elem.getDescription() != null) {
                Map<String, ElementInfo> elementInfo = parseLogElementDescription(elem.getDescription());
                String sourceElementName = elementInfo?.get(SOURCE_INFO_KEY)?.name;
                if (sourceElementName != null && flowElements.containsKey(sourceElementName)) {
                    elemY = Integer.valueOf(flowElements.get(sourceElementName).getY());
                }
            }
            
            Boolean foundGroup = false;
            // Try to find an existing group within tolerance
            for (Integer groupY : yLevelGroups.keySet()) {
                    if (Math.abs(elemY - groupY) <= TOLERANCE) {
                    yLevelGroups.get(groupY).add(elem);
                    foundGroup = true;
                    break;
                }
            }
            
            // If no suitable group found, create new one
            if (!foundGroup) {
                yLevelGroups.put(elemY, new List<FlowElement>{elem});
            }
        }
        
        // Sort Y levels
        List<Integer> sortedY = new List<Integer>(yLevelGroups.keySet());
        sortedY.sort();
        
        Integer currentY = START_Y_POSITION;
        Integer lastGroupY = null;
        
        // Process each Y level group
        for (Integer yLevel : sortedY) {
            List<FlowElement> groupElements = yLevelGroups.get(yLevel);
            
            // Adjust currentY if the gap from the last group is too large
            if (lastGroupY != null) {
                Integer actualGap = yLevel - lastGroupY;
                if (actualGap > (ELEMENT_SPACING - LOG_OFFSET)) {
                    currentY = lastGroupY + (ELEMENT_SPACING - LOG_OFFSET);
                }
            }
            lastGroupY = currentY;
            
            // First process non-logging elements
            for (FlowElement elem : groupElements) {
                if (!isLoggingElement(elem.getName())) {
                    elem.setY(currentY);
                    sortedElements.add(new FlowElementWrapper(elem));
                }
            }
            
            // Group logging elements by source-target pairs
            Map<String, List<FlowElement>> sourceTargetGroups = new Map<String, List<FlowElement>>();
            
            // First group logging elements
            for (FlowElement elem : groupElements) {
                if (isLoggingElement(elem.getName())) {
                    Map<String, ElementInfo> elementInfo = parseLogElementDescription(elem.getDescription());
                    if (elementInfo == null) continue;
                    
                    String sourceElementName = elementInfo?.get(SOURCE_INFO_KEY)?.name;
                    String targetElementName = elementInfo?.get(TARGET_INFO_KEY)?.name;
                    
                    // Create a key for the source-target pair
                    String sourceTargetKey = (sourceElementName != null ? sourceElementName : 'none') + 
                                           '->' + 
                                           (targetElementName != null ? targetElementName : 'none');
                    
                    // Add to the group
                    if (!sourceTargetGroups.containsKey(sourceTargetKey)) {
                        sourceTargetGroups.put(sourceTargetKey, new List<FlowElement>());
                    }
                    sourceTargetGroups.get(sourceTargetKey).add(elem);
                }
            }
            
            // Process each source-target group to center them
            for (String sourceTargetKey : sourceTargetGroups.keySet()) {
                List<FlowElement> elemsInGroup = sourceTargetGroups.get(sourceTargetKey);
                List<String> parts = sourceTargetKey.split('->');
                String sourceElementName = parts[0] != 'none' ? parts[0] : null;
                String targetElementName = parts[1] != 'none' ? parts[1] : null;
                
                FlowElement sourceElement = sourceElementName != null ? flowElements.get(sourceElementName) : null;
                FlowElement targetElement = targetElementName != null ? flowElements.get(targetElementName) : null;
                
                Integer sourceX = sourceElement?.getX();
                Integer targetX = targetElement?.getX();
                
                // Calculate center position between source and target
                Integer centerX;
                if (sourceX != null && targetX != null) {
                    // Center between source and target
                    centerX = (sourceX + targetX) / 2;
                } else if (sourceX != null) {
                    // Use source X if target doesn't exist
                    centerX = sourceX;
                } else if (targetX != null) {
                    // Use target X if source doesn't exist
                    centerX = targetX;
                } else {
                    // Default X position if neither exists
                    centerX = 500;
                }
                
                // Calculate total width needed for all elements
                Integer totalWidth = (elemsInGroup.size() - 1) * LOG_X_OFFSET;
                // Calculate start X to center the group
                Integer startX = centerX - (totalWidth / 2);
                
                // Position each element in the group
                for (Integer i = 0; i < elemsInGroup.size(); i++) {
                    FlowElement elem = elemsInGroup[i];
                    
                    // Set Y coordinate with offset
                    elem.setY(currentY + LOG_OFFSET);
                    
                    // Set X coordinate centered and spaced evenly
                    elem.setX(startX + (i * LOG_X_OFFSET));
                    
                    // Add to sorted elements
                    sortedElements.add(new FlowElementWrapper(elem));
                }
            }
            
            currentY += ELEMENT_SPACING;
        }
        
        return sortedElements;
    }

    // Test method to expose buildScreenFieldsDetails for testing
    @TestVisible
    public Object testBuildScreenFieldsDetails(FlowElement element) {
        return buildScreenFieldsDetails(element);
    }
}