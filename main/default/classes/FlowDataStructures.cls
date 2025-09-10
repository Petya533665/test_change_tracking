public with sharing class FlowDataStructures {

    public class FlowErrorAbbreviateResult {
        public Map<String, String> errorMessages;
        public String abbreviatedStacktrace;

        public FlowErrorAbbreviateResult(){}

        public void addErrorMessages(List<String> htmlErrorMessages) {
            if(this.errorMessages == null) {
                this.errorMessages = new Map<String, String>();
            }
            for(String htmlErrorMessage : htmlErrorMessages) {
                String message = htmlErrorMessage?.stripHtmlTags()?.trim();
                String keyMessage = FlowExceptionParser.getValueForHash(LogService.removeExtraErrorDetails(message));
                this.errorMessages.put(keyMessage, message);
            }
        }
    }

    public class FlowStacktraceInfo {

        public FlowDetails flowDetails;
        public FlowInterviewDetails flowInterviewDetails;
        public HowTheInterviewStarted howTheInterviewStarted;

        public List<FlowStacktraceElement> stacktraceElements;
        public Map<String, List<FlowStacktraceElement>> stacktraceElementsMap;
        public Set<String> flowApiNamePool;
        public String errorMessage;
        public String errorMessageHtml;
        public Boolean isHandledError;
        public String handledErrorMessage;
        public String salesforceErrorId;
        public Map<String, Object> context;
        public String orchestratorFailedFlowApiName;

        public FlowStacktraceInfo(){
            this.stacktraceElements = new List<FlowStacktraceElement>();
            this.stacktraceElementsMap = new Map<String, List<FlowStacktraceElement>>();
            this.flowApiNamePool = new Set<String>();
            this.context = new Map<String, Object>();
        }
    }

    public class FlowStacktraceElement {
        public String type;
        public String nameOrLabel;
        public Map<String, Object> context;
        public String apiType;

        public FlowStacktraceElement(String type, String nameOrLabel) {
            this.type = type;
            this.nameOrLabel = nameOrLabel;
            this.context = new Map<String, Object>();
            this.apiType = getAPITypeByLabel(this.type);
        }
        
        private String getAPITypeByLabel(String type) {
            if(type.containsIgnoreCase('UPDATE RECORDS')) {
                return 'FlowRecordUpdate';
            }
            else if(type.containsIgnoreCase('CREATE RECORDS')) {
                return 'FlowRecordCreate';
            }
            else if(type.containsIgnoreCase('GET RECORDS')) {
                return 'FlowRecordLookup';
            }
            else if(type.containsIgnoreCase('SCREEN')) {
                return 'FlowScreen';
            }
            else if(type.containsIgnoreCase('SCREEN')) {
                return 'FlowScreen';
            }
            else if(type.containsIgnoreCase('LOOP')) {
                return 'FlowLoop';
            }
            else if(type.containsIgnoreCase('ASSIGNMENT')) {
                return 'FlowAssignment';
            }
            else if(type.containsIgnoreCase('DECISION')) {
                return 'FlowDecision';
            }
            else if(type.containsIgnoreCase('(FLOWS)')) {
                return 'FlowSubflow';
            }
            else if(type.containsIgnoreCase('SUBFLOW')) {
                return 'FlowSubflow';
            }
            else if(type.containsIgnoreCase('(EMAIL ALERTS)') || type.containsIgnoreCase('(APEX)') || type.endsWith('(APEX)')) {
                return 'FlowActionCall';
            }
            else if(type.containsIgnoreCase('ENTER STAGE')) {
                return 'FlowStage';
            }
            else if(type.containsIgnoreCase('BACKGROUND STEP')) {
                return 'FlowStep';
            }
            else if(type.containsIgnoreCase('SUBMIT FOR APPROVAL')) {
                return 'FlowActionCall';
            }
            else if(type.containsIgnoreCase('DELETE RECORDS')) {
                return 'FlowRecordDelete';
            }
            else if(type.containsIgnoreCase('PAUSE')) {
                return 'FlowWait';
            }
            else if(type.containsIgnoreCase('TRANSFORM')) {
                return 'FlowTransform';
            }
            else if(type.endsWith('(QUICK ACTIONS)')) {
                return 'FlowActionCall';
            }
            else if(type.containsIgnoreCase('ROLL BACK RECORDS')) {
                return 'FlowRecordRollback';
            }

            return '';
        }
    }

    public class FlowDetails {
        public String flowApiName;
        public String type;
        public String version;
        public String status;
        public String orgId;
        public String orgName;
    }

    public class FlowInterviewDetails {
        public String interviewLabel;
        public String interviewGUID;
        public String currentUserId;
        public String currentUserName;
        public String startTime;
        public String duration;
    }

    public class HowTheInterviewStarted {
        public String apiVersion;
        public String recordId;
        public String recordName;
        public String scheduledPath;
    }

    public class FlowStackTraceProcessor {
        private FlowEdgeProcessor edgeProcessor;
        private Map<String, List<FlowElement>> elementsByApiNameOrLabel;
        private Flow flow;
        private FlowStacktraceInfo stackTraceInfo;
        private List<List<Integer>> elementRanges;

        public FlowStackTraceProcessor(Flow flow, FlowStacktraceInfo stackTraceInfo, List<List<Integer>> elementRanges, Integer globalIndex) {
            this.flow = flow;
            this.stackTraceInfo = stackTraceInfo;
            this.edgeProcessor = new FlowEdgeProcessor(globalIndex);
            this.elementsByApiNameOrLabel = new Map<String, List<FlowElement>>();
            this.elementRanges = elementRanges;
            initializeElementsMap();
        }

        public Integer getGlobalIndex() {
            return edgeProcessor.getEdgeIndex();
        }
        
        private void initializeElementsMap() {
            for(String elementName : flow?.elements?.keySet()) {
                FlowElement flowElement = flow.elements.get(elementName);
                addElementToMap(flowElement.name, flowElement);
                addElementToMap(flowElement.label, flowElement);
            }
        }
        
        private void addElementToMap(String key, FlowElement element) {
            if (String.isBlank(key)) return;
            
            List<FlowElement> elements = elementsByApiNameOrLabel.containsKey(key)
                ? elementsByApiNameOrLabel.get(key)
                : new List<FlowElement>();
            elements.add(element);
            elementsByApiNameOrLabel.put(key, elements);
        }

        public void processFlow(Integer finalIndex) {
            edgeProcessor.processStartEdges(flow, stackTraceInfo);
            
            FlowElement nextFlowElement;
            Integer instanceIndex = (Integer)flow.context.get('instanceIndex');
        
            // Get the last index from all ranges for this flow
            if (finalIndex == -1) {
                for (List<Integer> range : elementRanges) {
                    if (range[1] > finalIndex) {
                        finalIndex = range[1];
                    }
                }
            }
            
            // Sort ranges by start index to ensure proper order
            elementRanges.sort();
            
            for (Integer rangeIndex = 0; rangeIndex < elementRanges.size(); rangeIndex++) {
                List<Integer> range = elementRanges[rangeIndex];
                Integer startIdx = range[0];
                Integer endIdx = range[1];
                
                for (Integer i = startIdx; i <= endIdx; i++) {
                    FlowStacktraceElement stackTraceElement = stackTraceInfo.stacktraceElements[i];
                    FlowStacktraceElement nextStackTraceElement = (i < stackTraceInfo.stacktraceElements.size() - 1) 
                        ? stackTraceInfo.stacktraceElements[i+1]
                        : null;
                    Boolean isLastElement = (i == finalIndex);
                    Boolean isLastInRange = (i == endIdx);					
                    
                    FlowElement matchedElement = findMatchingElement(
                        stackTraceElement, 
                        nextFlowElement
                    );

                    FlowElement nextStacktraceFlowElement = (nextStackTraceElement != null) 
                        ? findMatchingElement(
                            nextStackTraceElement,
                            matchedElement
                        )
                        : null;

                    if (matchedElement != null) {
                        // check if last element of stacktrace has fault connector
                        // if so, throw exception to be handled by ErrorEmailHandler
                        if (isLastElement && matchedElement.hasFaultConnector) {
                            throw new LogService.LogException(LogService.FLOW_HANDLED_ERROR_MESSAGE);
                        }

                        updateElementContext(matchedElement, stackTraceElement);
                        nextFlowElement = processElementEdges(
                            matchedElement,
                            stackTraceElement,
                            nextStacktraceFlowElement,
                            isLastElement
                        );
                    }
                }
            }
        }
        
        private FlowElement findMatchingElement(
            FlowStacktraceElement stackTraceElement,
            FlowElement nextFlowElement
        ) {
            // Initialize matchedElements
            List<FlowElement> matchedElements = new List<FlowElement>();
            
            // First try to find by exact name match
            if (nextFlowElement != null) {
                FlowElement element = flow.elements.get(nextFlowElement.name);
                if (element == null) {
                    String apiName = flow.labelToApiMap.get(nextFlowElement.label);
                    if (String.isNotBlank(apiName)) {
                        element = flow.elements.get(apiName);
                    }
                }
                if (element != null) {
                    matchedElements.add(element);
                }
            }
            else {
                FlowElement element = flow.elements.get(stackTraceElement.nameOrLabel);
                if (element == null) {
                    String apiName = flow.labelToApiMap.get(stackTraceElement.nameOrLabel);
                    if (String.isNotBlank(apiName)) {
                        element = flow.elements.get(apiName);
                    }
                }
                if (element != null) {
                    matchedElements.add(element);
                }
            }
            
            // If no exact match, try to find by API type and name
            for (FlowElement element : flow.elements.values()) {
                if (element.name == stackTraceElement.nameOrLabel || element.label == stackTraceElement.nameOrLabel) {
                    if (String.isBlank(stackTraceElement.apiType) || 
                        element.actionType == stackTraceElement.apiType) {
                        matchedElements = new List<FlowElement>{element};
                        break;
                    }
                }
            }			
            return matchedElements.isEmpty() ? null : matchedElements[0];
        }
        
        private void updateElementContext(
            FlowElement flowElement,
            FlowStacktraceElement stackTraceElement
        ) {
            flowElement.executed = true;
            if (!stackTraceElement?.context?.isEmpty()) {
                flowElement?.context?.putAll(stackTraceElement.context);
            }	
        }
        
        private FlowElement processElementEdges(
            FlowElement flowElement,
            FlowStacktraceElement stackTraceElement,
            FlowElement nextStacktraceFlowElement,
            Boolean isLastElement
        ) {
            String outcome = (!stackTraceElement?.context?.isEmpty() && 
                                stackTraceElement?.context?.containsKey(Constants.FLOW.PB_ST_VAR_OUTCOME))
                ? String.valueOf(stackTraceElement?.context?.get(Constants.FLOW.PB_ST_VAR_OUTCOME))
                : null;
                
            Boolean isFaultPath = !stackTraceElement?.context?.isEmpty() && 
                stackTraceElement?.context?.containsKey(Constants.FLOW.PB_ST_ELEMENT_FAULT_PATH_EXECUTED);

            return edgeProcessor.processElementEdges(
                flow,
                flowElement,
                nextStacktraceFlowElement,
                isLastElement,
                outcome,
                isFaultPath
            );
        }
    }

    public class FlowAssignmentInfo {
        public String label;
        public String name;
        public String descirption;
        public List<FlowAssignmentsItemInfo> assignments;

        public FlowAssignmentInfo(String label, String name, String descirption) {
            this.label = label;
            this.name = name;
            this.descirption = descirption;
            this.assignments = new List<FlowAssignmentsItemInfo>();
        }
    }

    public class FlowAssignmentsItemInfo {

        public String variable;
        public String operator;
        public Object value;

        public FlowAssignmentsItemInfo(String variable, String operator, Object value) {
            this.variable = variable;
            this.operator = Constants.FLOW.FLOW_ASSIGNNMENT_OPERATOR_MAPPING.get(operator);
            this.value = value;
        }
    }

    public class FlowEdgeProcessor {
        private Integer edgeIndex;
        
        public FlowEdgeProcessor(Integer globalIndex) {			
            this.edgeIndex = globalIndex;
        }

        public Integer getEdgeIndex() {
            return this.edgeIndex;
        }

        public void setEdgeIndex(Integer edgeIndex) {
            this.edgeIndex = edgeIndex;
        }
        
        public void processStartEdges(Flow flow, FlowStacktraceInfo stackTraceInfo) {
            if (flow?.edges?.containsKey(Constants.FLOW.PB_ST_START_ELEMENT)) {
                for(FlowEdge edge : flow?.edges?.get(Constants.FLOW.PB_ST_START_ELEMENT)) {
                    if(edge.indexes.size() == 1) {
                        return;
                    }
                }
            }
            
            Set<FlowEdge> edges = flow.edges.get(Constants.FLOW.PB_ST_START_ELEMENT);
            FlowElement nextFlowElement;
            
            // Process single edge case
            if (edges?.size() == 1 && String.isBlank(stackTraceInfo?.howTheInterviewStarted?.scheduledPath)) {
                for (FlowEdge edge : edges) {
                    edge.addIndex(edgeIndex++);
                    nextFlowElement = flow.elements?.get(edge.target);
                }
                flow.edges.put(Constants.FLOW.PB_ST_START_ELEMENT, new Set<FlowEdge>(edges));
            }
            
            // Process scheduled path case
            if (String.isNotBlank(stackTraceInfo?.howTheInterviewStarted?.scheduledPath)) {
                for (FlowEdge edge : edges) {
                    if (edge?.label == stackTraceInfo.howTheInterviewStarted.scheduledPath || 
                        edge?.name == stackTraceInfo.howTheInterviewStarted.scheduledPath) {
                        nextFlowElement = flow.elements?.get(edge.target);
                        edge.addIndex(edgeIndex++);
                        break;
                    }
                }
            }
        }
        
        public FlowElement processElementEdges(Flow flow, FlowElement flowElement, 
                                                            FlowElement nextStacktraceFlowElement,
                                                            Boolean isLastStacktraceElement,
                                                            String outcome,
                                                            Boolean isFaultPath) {
            if (isLastStacktraceElement) {
                return null;
            }
            
            Set<FlowEdge> edges = flow?.edges?.get(flowElement?.name);
            FlowElement nextFlowElement;
            
            if (edges?.size() == 1) {
                nextFlowElement = processSingleEdge(flow, edges, isFaultPath);
                flow.edges.put(flowElement.name, new Set<FlowEdge>(edges));
            } 
            else if (edges?.size() > 1) {
                nextFlowElement = processMultipleEdges(flow, edges, outcome, isFaultPath, nextStacktraceFlowElement);
                flow.edges.put(flowElement.name, new Set<FlowEdge>(edges));
            }
            return nextFlowElement;
        }
        
        private FlowElement processSingleEdge(Flow flow, Set<FlowEdge> edges, Boolean isFaultPath) {
            FlowElement nextFlowElement;
            for (FlowEdge edge : edges) {
                if (edge.fault && !isFaultPath) continue;
                edge.addIndex(edgeIndex++);
                nextFlowElement = flow.elements?.get(edge.target);
            }
            return nextFlowElement;
        }
        
        private FlowElement processMultipleEdges(Flow flow, Set<FlowEdge> edges, 
                                                            String outcome, Boolean isFaultPath, FlowElement nextStacktraceFlowElement) {
            FlowElement nextFlowElement;
            
            // Process outcome-based edges
            if (String.isNotBlank(outcome)) {
                for (FlowEdge edge : edges) {
                    if (edge?.label == outcome || edge?.name == outcome || 
                        (outcome == Constants.FLOW.PB_ST_VAR_DEFAULT_OUTCOME && edge.isDefault)) {
                        edge.addIndex(edgeIndex++);
                        nextFlowElement = flow.elements?.get(edge.target);
                        break;
                    }
                }
            }
            
            // Process fault path
            if (isFaultPath) {
                for (FlowEdge edge : edges) {
                    if (edge?.label == Constants.FLOW.PB_ST_VAR_FAULT) {
                        edge.addIndex(edgeIndex++);
                        nextFlowElement = flow.elements?.get(edge.target);
                    }
                }
            }
            
            // Process default path for two edges with no outcome
            if (nextFlowElement == null && edges?.size() > 1 && String.isBlank(outcome) && !isFaultPath) {
                for (FlowEdge edge : edges) {
                    if (edge?.label != Constants.FLOW.PB_ST_VAR_FAULT && edge?.isDefault) {
                        edge.addIndex(edgeIndex++);
                        nextFlowElement = flow.elements?.get(edge.target);
                        break;
                    }
                }
            }

            if (nextFlowElement == null && edges?.size() > 1 && nextStacktraceFlowElement != null) {
                for (FlowEdge edge : edges) {
                    if (edge.target == nextStacktraceFlowElement.name) {
                        edge.addIndex(edgeIndex++);
                        nextFlowElement = flow.elements?.get(edge.target);
                        break;
                    }
                }
            }
            return nextFlowElement;
        }
    }

    public class Flow {
        public String name;
        public String label;
        public String processType;
        public String description;
        public FlowStart start;
        public Map<String, FlowElement> elements;
        public Map<String, Set<FlowEdge>> edges;
        public Map<String, Object> context;
        public List<StackTraceParser.StackTraceParseResult> apexStackTraceParseResults;
        public String errorMessage;
        public String errorMessageHtml;
        public String orchestratorFailedFlowApiName;
        public List<Flow> subflows;
        public List<FlowVariable> variables;
        public Map<String, String> labelToApiMap;

        public Flow() {
            this.elements = new Map<String, FlowElement>();
            this.edges = new Map<String, Set<FlowEdge>>();
            this.apexStackTraceParseResults = new List<StackTraceParser.StackTraceParseResult>();
            this.context = new Map<String, Object>();
            this.subflows = new List<Flow>();
            this.variables = new List<FlowVariable>();
            this.labelToApiMap = new Map<String, String>();
        }

        public Flow deepClone() {
            Flow clonedFlow = new Flow();
            
            // Clone simple properties
            clonedFlow.name = this.name;
            clonedFlow.label = this.label;
            clonedFlow.processType = this.processType;
            clonedFlow.description = this.description;
            clonedFlow.errorMessage = this.errorMessage;
            clonedFlow.errorMessageHtml = this.errorMessageHtml;
            clonedFlow.orchestratorFailedFlowApiName = this.orchestratorFailedFlowApiName;
            clonedFlow.apexStackTraceParseResults = this.apexStackTraceParseResults;
            clonedFlow.labelToApiMap = new Map<String, String>(this.labelToApiMap);
            clonedFlow.start = this.start;

            // Deep clone maps and collections
            clonedFlow.edges = new Map<String, Set<FlowEdge>>();
            for(String key : this.edges.keySet()) {
                Set<FlowEdge> edgeSet = new Set<FlowEdge>();
                for(FlowEdge edge : this.edges.get(key)) {
                    edgeSet.add(edge.deepClone());
                }
                clonedFlow.edges.put(key, edgeSet);
            }
            
            
            clonedFlow.elements = new Map<String, FlowElement>();
            if(this.elements != null) {
                for(String key : this.elements.keySet()) {
                    clonedFlow.elements.put(key, this.elements.get(key).deepClone());
                }
            }
            
            clonedFlow.variables = new List<FlowVariable>();
            if(this.variables != null) {
                for(FlowVariable var : this.variables) {
                    clonedFlow.variables.add(var.deepClone());
                }
            }
            
            clonedFlow.subflows = new List<Flow>();
            if(this.subflows != null) {
                for(Flow subflow : this.subflows) {
                    clonedFlow.subflows.add(subflow.deepClone());
                }
            }			
            
            clonedFlow.context = new Map<String, Object>();
            if(this.context != null) {
                clonedFlow.context.putAll(this.context);
            }
            
            return clonedFlow;
        }

        public void addDefaultEdge(String startPath, String endPath, String edgeLabel, Boolean isGoTo) {
            addEdge(startPath, endPath, edgeLabel, null, false, true, isGoTo);
        }

        public void addDefaultEdge(String startPath, String endPath, Boolean isGoTo) {
            addEdge(startPath, endPath, null, null, false, true, isGoTo);
        }

        public void addEdge(String startPath, String endPath, Boolean isGoTo) {
            addEdge(startPath, endPath, null, false, isGoTo);
        }

        public void addEdge(String startPath, String endPath, String edgeLabel, String edgeName, Boolean isFault, Boolean isGoTo) {
            addEdge(startPath, endPath, edgeLabel, edgeName, isFault, false, isGoTo);
        }

        public void addEdge(String startPath, String endPath, String edgeLabel, String edgeName, Boolean isFault, Boolean isDefault, Boolean isGoTo) {
            Set<FlowEdge> edges = this.edges.get(startPath) != null ? this.edges.get(startPath) : new Set<FlowEdge>();
            FlowEdge fe = new FlowEdge(endPath, edgeLabel, edgeName, isFault, isDefault, isGoTo);
            edges.add(fe);
            this.edges.put(startPath, edges);
        }

        public void addEdge(String startPath, String endPath, String edgeLabel, Boolean isGoTo) {
            addEdge(startPath, endPath, edgeLabel, null, false, isGoTo);
        }

        public void addEdge(String startPath, String endPath, String edgeLabel, String edgeName, Boolean isGoTo) {
            addEdge(startPath, endPath, edgeLabel, edgeName, false, isGoTo);
        }

        public void addEdge(String startPath, String endPath, String edgeLabel, Boolean isFault, Boolean isGoTo) {
            addEdge(startPath, endPath, edgeLabel, null, isFault, false, isGoTo);
        }

    }

    public class FlowVariable {
        public String name;
        public String description;
        public String apexClass;
        public Boolean isCollection;
        public Boolean isInput;
        public Boolean isOutput;
        public String objectType;
        public String dataType;

        public FlowVariable(){}

        public FlowVariable deepClone() {
            FlowVariable cloned = new FlowVariable();
            cloned.name = this.name;
            cloned.description = this.description;
            cloned.apexClass = this.apexClass;
            cloned.isCollection = this.isCollection;
            cloned.isInput = this.isInput;
            cloned.isOutput = this.isOutput;
            cloned.objectType = this.objectType;
            cloned.dataType = this.dataType;
            return cloned;
        }
    }

    public class FlowRecordUpdateInfo {
        public String label;
        public String name;
        public String objectName;
        public String description;

        public Boolean specifyConditionsToIdentifyRecords;
        public Boolean useTheIDs;
        public String inputReference;

        public String conditionLogic;
        public String conditionLabel;
        public String conditionName;
        public List<FlowRecordFilterInfo> conditions;
        public List<FlowInputFieldAssignmentInfo> assignments;


        public FlowRecordUpdateInfo(String label, String name, String objectName, String description) {
            this.label = label;
            this.name = name;
            this.description = description;
            this.objectName = objectName;
            this.conditions = new List<FlowRecordFilterInfo>();
            this.assignments = new List<FlowInputFieldAssignmentInfo>();
        }
    }

    public class FlowEdge {
        public String name;
        public String label;
        public String target;
        public Boolean fault;
        public Boolean isDefault;
        public Boolean isGoTo;
        public List<Integer> indexes;

        public FlowEdge(String target){
            this(target, null);
        }

        public FlowEdge(String target, String label){
            this(target, label, label, false, false, false);
        }

        public FlowEdge() {}

        public FlowEdge(String target, String label, String name, Boolean isFault, Boolean isDefault, Boolean isGoTo) {
            this.target = target;
            this.label = label;
            this.name = name;
            this.indexes = new List<Integer>();
            this.fault = isFault;
            this.isDefault = isDefault;
            this.isGoTo = isGoTo;
            this.label = (this.label == null && isDefault) ? 'Default Path' : this.label;
        }

        public void addIndex(Integer index) {
            this.indexes.add(index);
        }

        public FlowEdge deepClone() {
            FlowEdge cloned = new FlowEdge();
            cloned.name = this.name;
            cloned.label = this.label;
            cloned.target = this.target;
            cloned.fault = this.fault;
            cloned.isDefault = this.isDefault;
            cloned.isGoTo = this.isGoTo;
            cloned.indexes = new List<Integer>(this.indexes);
            return cloned;
        }
    }

    public class FlowScheduledPath {
        public String name;
        public String label;
        public Integer offsetNumber;
        public String offsetUnit;
        public String timeSource;
        public String targetReference;
        public Integer maxBatchSize;
        public String recordField;
        public String pathType;

        public FlowScheduledPath() {}
    }

    public class FlowStart {
        public String startType;
        public String objectType;

        public Location location;
        public String startRefference;

        public Boolean aRecordIsCreated;
        public Boolean aRecordIsUpdated;
        public Boolean aRecordIsCreatedOrUpdated;
        public Boolean aRecordIsDeleted;
        public Boolean runFlowBeforeTheRecordIsSaved;
        public Boolean runFlowAfterTheRecordIsSaved;
        public Boolean runTheFlowEveryTime;
        public Boolean runTheFlowOnlyUpdate;

        public String recordTriggerType;
        public String triggerType;
        public String conditionLogic;
        public String conditionLabel;
        public String conditionName;
        public List<FlowRecordFilterInfo> conditions;

        public String scheduleFrequency;
        public String scheduleStartDate;
        public String scheduleStartTime;

        public FlowScheduledPath[] scheduledPaths;
        public String canvasMode;
        public String flowRunAsUser;
        public String filterFormula;

        public FlowStart(String processType, MetadataService.Flow sfdcFlow) {
            this.triggerType = sfdcFlow?.start?.triggerType;
            this.location = new Location(sfdcFlow?.start?.locationX, sfdcFlow?.start?.locationY);
            this.objectType = sfdcFlow?.start?.object_x;
            if(sfdcFlow?.start?.connector != null && sfdcFlow?.start?.connector?.targetReference != null) {
                this.startRefference = sfdcFlow?.start?.connector?.targetReference;
            }
            // converted Processbuilder to Flow
            if(sfdcFlow?.startElementReference != null) {
                this.startRefference = sfdcFlow.startElementReference;
            }

            this.runTheFlowOnlyUpdate = (sfdcFlow?.start?.doesRequireRecordChangedToMeetCriteria != null && sfdcFlow?.start?.doesRequireRecordChangedToMeetCriteria);
            this.runTheFlowEveryTime = !this.runTheFlowOnlyUpdate;
            this.recordTriggerType = sfdcFlow?.start?.recordTriggerType;
            this.flowRunAsUser = sfdcFlow?.start?.flowRunAsUser;
            this.aRecordIsCreated = (this.recordTriggerType == 'Create');
            this.aRecordIsUpdated = (this.recordTriggerType == 'Update');
            this.aRecordIsCreatedOrUpdated = (this.recordTriggerType == 'CreateAndUpdate');
            this.aRecordIsDeleted = (this.recordTriggerType == 'Delete');
            this.runFlowBeforeTheRecordIsSaved = (this.triggerType == 'RecordBeforeSave');
            this.runFlowAfterTheRecordIsSaved = (this.triggerType == 'RecordAfterSave');

            Object canvasModeObject = FlowService.getProcessMetadataValue('CanvasMode', sfdcFlow?.processMetadataValues);
            this.canvasMode = canvasModeObject != null ? String.valueOf(canvasModeObject) : null;

            if(sfdcFlow?.start?.filters != null) {
                this.conditions = new List<FlowRecordFilterInfo>();
                for(MetadataService.FlowRecordFilter filter : sfdcFlow.start.filters) {
                    this.conditions.add(new FlowRecordFilterInfo(
                        filter?.field,
                        filter?.operator,
                        String.valueOf(FlowService.getFlowElementReferenceOrValue(filter?.value))
                    ));
                }
                this.conditionLogic = sfdcFlow?.start?.filterLogic;
                if(this.conditionLogic == null) {
                    this.conditionLabel = Constants.FLOW.FLOW_CONDITION_EMPTY_LABEL;
                    this.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
                }
                else if(this.conditionLogic == 'and') {
                    this.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
                    this.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
                }
                else if(this.conditionLogic == 'or') {
                    this.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
                    this.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
                }
                else {
                    this.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
                    this.conditionName = sfdcFlow.start.filterLogic;
                    this.conditionLogic = sfdcFlow.start.filterLogic;
                }
            } else if (sfdcFlow?.start?.filterFormula != null){
                this.filterFormula = sfdcFlow?.start?.filterFormula;
                this.conditionLabel = Constants.FLOW.FLOW_CONDITION_FORMULA_LABEL;
                this.conditionName = Constants.FLOW.FLOW_CONDITION_FORMULA;
            }

            if(sfdcFlow?.start?.schedule != null) {
                this.scheduleFrequency = sfdcFlow.start.schedule?.frequency;
                this.scheduleStartDate = sfdcFlow.start.schedule?.startDate;
                this.scheduleStartTime = sfdcFlow.start.schedule?.startTime;
            }

            if(sfdcFlow?.start?.scheduledPaths != null) {
                this.scheduledPaths = new List<FlowScheduledPath>();
                for(MetadataService.FlowScheduledPath fsp : sfdcFlow.start.scheduledPaths) {
                    FlowScheduledPath sp = new FlowScheduledPath();
                    sp.name = fsp?.name;
                    sp.label = fsp?.label;
                    sp.offsetNumber = fsp?.offsetNumber;
                    sp.offsetUnit = fsp?.offsetUnit;
                    sp.timeSource = fsp?.timeSource;
                    sp.recordField = fsp?.recordField;
                    sp.maxBatchSize = fsp?.maxBatchSize;
                    sp.pathType = fsp?.pathType;
                    sp.targetReference = fsp?.connector?.targetReference;
                    this.scheduledPaths.add(sp);
                }
            }
        }
    }

    public class FlowRecordFilterInfo {
        public String field;
        public String operator;
        public Object value;

        public FlowRecordFilterInfo(String field, String operator, Object value){
            this.field = field;
            this.operator = Constants.FLOW.FLOW_RECORD_FILTER_OPERATOR_MAPPING.get(operator);
            this.value = value;
        }
    }

    public class FlowRecordCreateInfo {
        public String label;
        public String name;
        public String objectName;
        public String description;
        public List<FlowInputFieldAssignmentInfo> assignments;

        public Boolean oneRecordsCreate;
        public Boolean multipleRecordsCreate;
        public Boolean useAllValuesFromRecord;
        public Boolean useSeparateResources;
        public Boolean manuallyAssignVariables;

        public String assignRecordIdToReference;
        public String inputReference;


        public FlowRecordCreateInfo(String label, String name, String objectName, String description) {
            this.label = label;
            this.name = name;
            this.description = description;
            this.objectName = objectName;
            this.assignments = new List<FlowInputFieldAssignmentInfo>();
        }
    }

    public class FlowInputFieldAssignmentInfo {
        public String field;
        public Object value;

        public FlowInputFieldAssignmentInfo(String field, Object value) {
            this.field = field;
            this.value = value;
        }
    }

    public class FlowElement {
        public String name;
        public String label;
        public String description;
        public String actionType;
        public Boolean executed;
        public Map<String, Object> context;
        public String icon;
        public Location location;
        public Boolean hasFaultConnector;
        public Object metadataInfo;

        public FlowElement() {}

        public FlowElement(String name, String label, String actionType, Integer locationX, Integer locationY, String description) {
            this.name = name;
            this.label = label;
            this.description = description;
            this.actionType = actionType;
            this.executed = false;
            this.context = new Map<String, Object>();
            this.location = new Location(locationX, locationY);
            this.hasFaultConnector = false;
        }

        public void setIcon(String icon) {
            this.icon = icon;
        }

        public void setHasFaultConnector(Boolean hasFaultConnector) {
            this.hasFaultConnector = hasFaultConnector;
        }

        public FlowElement deepClone() {
            FlowElement cloned = new FlowElement();
            cloned.name = this.name;
            cloned.label = this.label;
            cloned.description = this.description;
            cloned.actionType = this.actionType;
            cloned.executed = this.executed;
            cloned.icon = this.icon;
            cloned.location = new Location(this.location.X, this.location.Y);
            cloned.metadataInfo = this.metadataInfo;
            cloned.context = new Map<String, Object>();
            cloned.hasFaultConnector = this.hasFaultConnector;
            if(this.context != null) {
                cloned.context.putAll(this.context);
            }
            return cloned;
        }
    }

    public class Location {
        public Integer X;
        public Integer Y;

        public Location(Integer x, Integer y) {
            this.X = x;
            this.Y = y;
        }
    }

    public class FlowAiMeta {
        public String errorNode;
        public List<String> nodesAfterError;
    }

    public class RawFlowData {
        public Map<String, List<RawEdge>> edges;
    }

    public class RawEdge {
        public String target;
        public List<Integer> indexes;
    }
}