public with sharing class FlowService {

	public interface FlowStacktraceParserInterface {
		String getFirstLines(String htmlText);
		String getLineValue(String htmlText);
		String getLineValue(String htmlText, String separator);
		List<String> getNameAndId(String htmlText);
		List<String> getNameAndId(String htmlText, String separator);
		Boolean isValidStacktraceElement(String htmlText);
		FlowDataStructures.FlowErrorAbbreviateResult abbreviateStacktraceErrorMessages();
		FlowDataStructures.FlowStacktraceInfo parse();
		String getFlowDetailsToken();
		String getFlowElementErrorStarts();
		String getSingleErrorMessageHtml(String part);
	}

	public class FlowStacktraceParser {
		FlowStacktraceParserInterface impl;

		public FlowStacktraceParser(String data) {
			this.impl = new FlowStacktraceParserWinter24Impl(data);
		}

		public FlowDataStructures.FlowErrorAbbreviateResult abbreviateStacktraceErrorMessages() {
			return this.impl.abbreviateStacktraceErrorMessages();
		}

		public FlowDataStructures.FlowStacktraceInfo parse() {
			return this.impl.parse();
		}
	}

	public class FlowStacktraceParserWinter24Impl extends FlowStacktraceParserDefImpl {

		public FlowStacktraceParserWinter24Impl(String data) {
			super(data);
		}

		public override String getFlowDetailsToken() {
			return Constants.FLOW.PB_ST_FLOW_ERROR_DETAILS;
		}

		public override String getLineValue(String htmlText, String separator) {
			return (htmlText?.indexOf(separator) != -1) ? htmlText?.stripHtmlTags()?.split(separator)?.get(1)?.trim() : null;
		}

		public override List<String> getNameAndId(String htmlText, String separator) {
			String name;
			String id;
			if((htmlText?.indexOf(separator) != -1)) {
				String fullNameAndId = htmlText?.stripHtmlTags()?.split(separator)?.get(1)?.trim();
				if((fullNameAndId?.indexOf('(') != -1)) {
					id = fullNameAndId?.split('\\(')?.get(1)?.left(15);
					name = fullNameAndId?.split('\\(')?.get(0)?.trim();
				}
			}
			return new List<String>{id, name};
		}

		public override String getFlowElementErrorStarts() {
			return 'An Error Occurred with';
		}

		public override String getSingleErrorMessageHtml(String part) {
			String singleErrorMessageHtml;
			
			FlowService.HTMLIterator errorMessageIterator = new FlowService.HTMLIterator(part, Constants.FLOW.HTML_TAG_BREAK_OPEN);
			while (errorMessageIterator.hasNext()) {
				String errorMessageHtml = errorMessageIterator?.next();
				
				String firstLinesPart = getFirstLines(errorMessageHtml);
				if(String.isNotBlank(firstLinesPart) && firstLinesPart.startsWith(Constants.FLOW.PB_ST_FLOW_ERROR_ELEMENT)) {
					// Example: Error element submit (FlowActionCall).
					if(firstLinesPart.startsWith('Error element ') && firstLinesPart.endsWith(').')) {
						String labelAndTypeErrorElement = errorMessageHtml?.stripHtmlTags()?.trim()?.removeStart('Error element ')?.removeEnd('.');
						String labelErrorElement = labelAndTypeErrorElement?.split(' ')?.get(0);
						String typeErrorElement = labelAndTypeErrorElement?.split(' ')?.get(1)?.removeStart('(')?.removeEnd(')');
						this.headErrorStacktraceElement = new FlowDataStructures.FlowStacktraceElement(typeErrorElement, labelErrorElement);
						this.headErrorStacktraceElement.apiType = typeErrorElement;
					}
					errorMessageHtml = errorMessageIterator?.next();

					if(String.isNotBlank(errorMessageHtml) && errorMessageHtml.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR)) {
						List<String> parts = errorMessageHtml.split(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
						Integer lastElementIndex = parts?.size() != 0 ? parts?.size() - 1 : 0;
						singleErrorMessageHtml = parts.get(lastElementIndex);
					}
					else {
						singleErrorMessageHtml = errorMessageHtml;
					}
				}
			}
			
			return singleErrorMessageHtml;
		}
	}

	public with sharing abstract class FlowStacktraceParserDefImpl  implements FlowStacktraceParserInterface {
		private String data;
		private FlowDataStructures.FlowStacktraceElement headErrorStacktraceElement;

		public FlowStacktraceParserDefImpl(String data) {
			this.data = data;
		}

		public abstract String getFlowDetailsToken();
		public abstract String getFlowElementErrorStarts();
		public abstract String getSingleErrorMessageHtml(String part);

		public virtual String getFirstLines(String htmlText) {
			return htmlText?.abbreviate(1000)?.stripHtmlTags()?.replaceAll(Constants.FLOW.HTML_TAG_BACKSLASH, '')?.trim();
		}

		public virtual String getLineValue(String htmlText) {
			return getLineValue(htmlText, ':');
		}

		public virtual String getLineValue(String htmlText, String separator) {
			return (htmlText?.indexOf(separator) != -1) ? htmlText?.split(separator)?.get(1)?.stripHtmlTags()?.trim() : null;
		}

		public virtual List<String> getNameAndId(String htmlText) {
			return getNameAndId(htmlText, ':');
		}

		public virtual List<String> getNameAndId(String htmlText, String separator) {
			String name;
			String id;
			if((htmlText?.indexOf(separator) != -1)) {
				String fullNameAndId = htmlText?.split(separator)?.get(1)?.stripHtmlTags()?.trim();
				if((fullNameAndId?.indexOf('(') != -1)) {
					id = fullNameAndId?.split('\\(')?.get(1)?.left(15);
					name = fullNameAndId?.split('\\(')?.get(0)?.trim();
				}
			}
			return new List<String>{id, name};
		}

		public virtual Boolean isValidStacktraceElement(String htmlText) {
			return (htmlText?.indexOf(':') != -1) && htmlText?.stripHtmlTags()?.split(':')?.size() >= 2;
		}

		public virtual FlowDataStructures.FlowErrorAbbreviateResult abbreviateStacktraceErrorMessages() {
			FlowDataStructures.FlowErrorAbbreviateResult result = new FlowDataStructures.FlowErrorAbbreviateResult();

			String start = '';
			String headErrorPart = '';
			String flowEntry = '';
			String errorOccuredPart = '';
			String transactionRolledBackPart = '';
			String salesforceErrorIdPart = '';
			
			FlowService.HTMLIterator partsIterator = new FlowService.HTMLIterator(data, Constants.FLOW.HTML_TAG_HORIZONTAL_RULE_OPEN);
			while (partsIterator.hasNext()) {
				String part = partsIterator.next();
				String firstLinesPart = getFirstLines(part);

				if(String.isBlank(start)) {
					start = part;
					
					// stacktrace flow entry without head error part
					if(String.isBlank(flowEntry) && String.isNotBlank(firstLinesPart) && firstLinesPart.startsWith(Constants.FLOW.PB_ST_FLOW_DETAILS_WITHOUT_HEADER_ERROR)) {
						flowEntry = part;
						// add template a error occured
						start = start.replace('<body><a', '<body>'+ Constants.FLOW.FLOW_ERROR_START_ERROR_OCCURED);
						// add template for error element
						start = start.replace(Constants.FLOW.FLOW_ERROR_DEBUG_FLOW_BUILDER_PART, Constants.FLOW.FLOW_ERROR_ELEMENT_HEAD_PART);
					}
				}
				else if(String.isBlank(flowEntry) && String.isNotBlank(firstLinesPart) && (firstLinesPart.startsWith(Constants.FLOW.PB_ST_FLOW_ERROR_DETAILS) || firstLinesPart.startsWith(Constants.FLOW.PB_ST_FLOW_DETAILS))) {
					flowEntry = part;
				}
				else if(String.isNotBlank(firstLinesPart) && firstLinesPart.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_PART_OCCURRED)) {
					errorOccuredPart = part;
				}
				else if(String.isNotBlank(firstLinesPart) && firstLinesPart.startsWith(Constants.FLOW.PB_ST_TRANSACTION_ROLLED_BACK)) {
					transactionRolledBackPart = part;
				}
				// last section with salesforce error id
				else if(String.isNotBlank(firstLinesPart) && firstLinesPart.startsWith(Constants.FLOW.PB_ST_SALESFORCE_ERROR_ID)) {
					salesforceErrorIdPart = part;
				}

				// fix bulk html stacktrace without Flow Error Details part
				if(String.isNotBlank(start) && String.isNotBlank(flowEntry)) {
					if(start.contains(Constants.FLOW.PB_ST_FLOW_DETAILS) && !start.contains(Constants.FLOW.PB_ST_FLOW_ERROR_DETAILS)) {
						start = start.replace(Constants.FLOW.FLOW_ERROR_DETAILS_PART_HTML, Constants.FLOW.FLOW_ERROR_FLOW_ERROR_DETAILS_PART_HTML);
						flowEntry = ' ';
					}
				}
			}
			
			if(String.isNotBlank(start) && start.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR)) {
				String fixedStart = '';
				FlowService.HTMLIterator brIterator = new FlowService.HTMLIterator(start, Constants.FLOW.HTML_TAG_BREAK_OPEN);
				while (brIterator.hasNext()) {
					String brPart = brIterator?.next();
					String firstLinesbrPart = getFirstLines(brPart?.stripHtmlTags()?.trim());

					if(String.isNotBlank(firstLinesbrPart) && firstLinesbrPart.startsWith(Constants.FLOW.PB_ST_FLOW_ERROR_ELEMENT)) {
						fixedStart += brPart;
						brPart = brIterator?.next();
						List<String> parts = brPart.split(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
						result.addErrorMessages(parts);
						if(result.errorMessages.size() > 1) {
							fixedStart += String.join(result.errorMessages.values(), Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
						}
						else {
							fixedStart += parts.get(0);
						}
					}
					else {
						fixedStart += brPart;
					}
				}
				if(String.isNotBlank(fixedStart)) {
					start = fixedStart;
				}
			}
			if(String.isNotBlank(errorOccuredPart) && errorOccuredPart.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR)) {
				String fixedErrorOccuredPart = '';
				List<String> parts = errorOccuredPart.split(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
				result.addErrorMessages(parts);
				errorOccuredPart = String.join(result.errorMessages.values(), Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
			}
			result.abbreviatedStacktrace = start  + Constants.FLOW.HTML_TAG_HORIZONTAL_RULE_OPEN + flowEntry + errorOccuredPart + transactionRolledBackPart + salesforceErrorIdPart;

			if(result?.abbreviatedStacktrace?.contains(Constants.FLOW.FLOW_ERROR_HEAD_PART_FLOW_NAME)) {
				replaceTemplatesByFlowInterviewRecordInfo(result);
			}
			return result;
		}

		public virtual List<FlowInterview> getFlowInterviewFromOrgByGUID(Connected_Org__c corg, String guid) {
			String query = new QBuilder(FlowInterview.SObjectType)
				.selectFields(new Set<String>{'Id', 'Error'})
				.add(QBuilder.condition('Guid').equalsTo(guid))
				.add(QBuilder.condition('InterviewStatus').equalsTo('Error'))
				.addLimit(1)
				.build();
			return (List<FlowInterview>)JSON.deserialize(JSON.serialize(LogPostProcessingService.runQueryV62(corg, query)), List<FlowInterview>.class);
		}

		public virtual List<FlowInterviewLog> getFlowInterviewLogsFromOrgByGUID(Connected_Org__c corg, String guid) {
			String query = new QBuilder(FlowInterviewLog.SObjectType)
				.selectFields(new Set<String>{'Id', 'FlowLabel', '(SELECT LogEntryType, ElementLabel, ElementApiName from FlowInterviewLogs WHERE LogEntryType = \'Error\')'})
				.add(QBuilder.condition('FlowInterviewGuid').equalsTo(guid))
				.add(QBuilder.condition('InterviewStatus').equalsTo('Error'))
				.addLimit(1)
				.build();
			return (List<FlowInterviewLog>)JSON.deserialize(JSON.serialize(LogPostProcessingService.runQueryV62(corg, query)), List<FlowInterviewLog>.class);
		}

		public virtual void replaceTemplatesByFlowInterviewRecordInfo(FlowDataStructures.FlowErrorAbbreviateResult result) {
			try {
				String guid = getFlowGUID(result.abbreviatedStacktrace);
				String organizationId = getOrganizationId(result.abbreviatedStacktrace);
				Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(organizationId);

				if(String.isNotBlank(guid) && String.isNotBlank(organizationId) && corg != null) {
					List<FlowInterview> failedInterview = getFlowInterviewFromOrgByGUID(corg, guid);

					if(!failedInterview.isEmpty()) {
						String errorFlowInterviewRecord = failedInterview.get(0)?.Error;
						result.abbreviatedStacktrace = result.abbreviatedStacktrace.replace(Constants.FLOW.FLOW_ERROR_HEAD_PART_OCCURED_ERROR_MESSAGE, errorFlowInterviewRecord);

						List<FlowInterviewLog> failedInterviewLog = getFlowInterviewLogsFromOrgByGUID(corg, guid);
						if(!failedInterview.isEmpty()) {
							String flowName = failedInterviewLog?.get(0)?.FlowLabel;

							if(String.isNotBlank(flowName)) {
								result.abbreviatedStacktrace = result.abbreviatedStacktrace.replace(Constants.FLOW.FLOW_ERROR_HEAD_PART_FLOW_NAME, flowName);
							}

							List<FlowInterviewLogEntry> logEntry = failedInterviewLog?.get(0)?.FlowInterviewLogs;
							String elementApiName = (logEntry != null && !logEntry.isEmpty()) ? logEntry?.get(0)?.ElementApiName : '';
							if(String.isNotBlank(elementApiName)) {
								result.abbreviatedStacktrace = result.abbreviatedStacktrace.replace(Constants.FLOW.FLOW_ERROR_HEAD_PART_OCCURED_ERROR_ELEMENT_NAME, elementApiName);
							}
						}
					}
				}
			}
			catch(Exception e){}
		}

		public virtual String getOrganizationId(String stacktrace) {
			//Org: </span>eee (00D6g000005kAqN)</span><br>
			Matcher pm = Constants.FLOW.PATTERN_FLOW_ORGANIZATION_ID.matcher(stacktrace);
			String orgId;
			try {
				if (pm.find()) {
					orgId = pm.group(1)?.stripHtmlTags()?.trim()?.split('\\(')?.get(1)?.removeEnd(')');
				}
			}
			catch(Exception e) {}
			return orgId;
		}

		public virtual String getFlowGUID(String stacktrace) {
			Matcher pm = Constants.FLOW.PATTERN_FLOW_GUID.matcher(stacktrace);
			String guid;
			try {
				if (pm.find()) {
					guid = pm.group(1)?.stripHtmlTags()?.trim();
				}
			}
			catch(Exception e) {}
			return guid;
		}

		private FlowDataStructures.FlowStacktraceElement getLastStacktraceElement(FlowDataStructures.FlowStacktraceInfo info) {
			return (!info?.stacktraceElements?.isEmpty()) ? info?.stacktraceElements?.get(info.stacktraceElements?.size() - 1) : null;
		}

		private Boolean isResumeFlowElement(FlowDataStructures.FlowStacktraceElement lastElement, String firstLinesPart) {
			return (lastElement != null && String.isNotBlank(firstLinesPart) && firstLinesPart.startsWith(lastElement.type));
		}

		private Boolean isFlowPauseResumeElement(FlowDataStructures.FlowStacktraceElement lastElement, FlowDataStructures.FlowStacktraceElement currentElement) {
			return (lastElement != null && currentElement != null 
				&& lastElement.type == currentElement.type 
				&& lastElement.nameOrLabel == currentElement.nameOrLabel
				&& lastElement.apiType == currentElement.apiType);
		}

		public virtual FlowDataStructures.FlowStacktraceInfo parse() {
			FlowDataStructures.FlowStacktraceInfo info = new FlowDataStructures.FlowStacktraceInfo();
		
			// Use a single pass through the HTML where possible
			FlowService.HTMLIterator partsIterator = new FlowService.HTMLIterator(this.data, Constants.FLOW.HTML_TAG_HORIZONTAL_RULE_OPEN);
			String detailsToken = getFlowDetailsToken();
			
			// with tags to avoid false positives for flows with text templates
			if(!this.data?.containsIgnoreCase('>' + detailsToken + '<')) {
				detailsToken = Constants.FLOW.PB_ST_FLOW_DETAILS;
			}
			
			while (partsIterator.hasNext()) {
				String part = partsIterator.next();
				String firstLinesPart = getFirstLines(part);
				
				// Process different sections based on their starting text
				if(firstLinesPart?.startsWith(detailsToken) 
					|| firstLinesPart?.startsWith(Constants.FLOW.PB_ST_TRANSACTION_ERROR_HANDLED)
					|| isResumeFlowElement(getLastStacktraceElement(info), firstLinesPart)) {
					
					processStacktracePart(info, part, detailsToken);
				}
				else if (firstLinesPart?.startsWith(getFlowElementErrorStarts())) {
					info.errorMessageHtml = getSingleErrorMessageHtml(part);
					info.errorMessage = info.errorMessageHtml?.stripHtmlTags()?.trim();
				}
				else if(firstLinesPart?.startsWith(Constants.FLOW.PB_ST_TRANSACTION_ROLLED_BACK)) {
					info.handledErrorMessage = null;
					info.isHandledError = false;
				}
				else if(firstLinesPart?.startsWith(Constants.FLOW.PB_ST_ERROR_OCCURED)) {
					processErrorMessage(info, part);
				}
				else if(firstLinesPart?.startsWith(Constants.FLOW.PB_ST_SALESFORCE_ERROR_ID)){
					processSalesforceErrorId(info, part);
				}
			}
			
			// Clean up
			partsIterator = null;
			
			// Process head error stacktrace element if present
			processHeadErrorStacktraceElement(info);
			
			// Build flow hierarchy
			buildFlowHierarchy(info);
			
			return info;
		}

		private void processStacktracePart(FlowDataStructures.FlowStacktraceInfo info, String part, String detailsToken) {
			FlowService.HTMLIterator stacktraceIterator = new FlowService.HTMLIterator(part, Constants.FLOW.HTML_TAG_PARAGRAPH_CLOSE);
			
			while (stacktraceIterator.hasNext()) {
				String stacktracePart = stacktraceIterator.next();
				String firstLinesStacktracePart = getFirstLines(stacktracePart);

				
				if(firstLinesStacktracePart?.startsWith(detailsToken)) {
					processFlowDetails(info, stacktracePart);
				}
				else if(firstLinesStacktracePart?.startsWith(Constants.FLOW.PB_ST_FLOW_INTERVIEW_DETAILS)) {
					processFlowInterviewDetails(info, stacktracePart);
				}
				else if(firstLinesStacktracePart?.startsWith(Constants.FLOW.PB_ST_HOW_START)) {
					processHowInterviewStarted(info, stacktracePart);
				}
				else if(firstLinesStacktracePart?.startsWith(Constants.FLOW.PB_ST_TRANSACTION_ERROR_HANDLED)) {
					processHandledError(info, part);
				}
				else if (firstLinesStacktracePart?.startsWith(Constants.FLOW.PB_ST_ORCHESTRATOR_ENTER_STAGE)) {
					processOrchestratorStage(info, stacktracePart);
				}
				else {
					processStacktraceElements(info, stacktracePart);
				}
			}
		}

		private void processFlowDetails(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			// Implementation for flow details processing
			FlowService.HTMLIterator flowDetailsIterator = new FlowService.HTMLIterator(stacktracePart, Constants.FLOW.HTML_TAG_BREAK_OPEN);
			info.flowDetails = new FlowDataStructures.FlowDetails();
			while (flowDetailsIterator.hasNext()) {
				String flowDetailsRow = flowDetailsIterator.next();
				String firstLinesFlowDetailsRow = getFirstLines(flowDetailsRow);

				if(firstLinesFlowDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_FLOW_API_NAME_LABEL)) {
					info.flowDetails.flowApiName = getLineValue(flowDetailsRow);
				}
				else if(firstLinesFlowDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_TYPE_LABEL)) {
					info.flowDetails.type = getLineValue(flowDetailsRow);
				}
				else if(firstLinesFlowDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_VERSION_LABEL)) {
					info.flowDetails.version = getLineValue(flowDetailsRow);
				}
				else if(firstLinesFlowDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_STATUS_LABEL)) {
					info.flowDetails.status = getLineValue(flowDetailsRow);
				}
				else if(firstLinesFlowDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_ORG_LABEL)) {
					List<String> orgNameAndId = getNameAndId(flowDetailsRow);
					info.flowDetails.orgId = orgNameAndId?.get(0);
					info.flowDetails.orgName = orgNameAndId?.get(1);
				}
			}
		}

		private void processFlowInterviewDetails(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			// Implementation for flow interview details processing
			FlowService.HTMLIterator flowInterviewDetailsIterator = new FlowService.HTMLIterator(stacktracePart, Constants.FLOW.HTML_TAG_BREAK_OPEN);
			info.flowInterviewDetails = new FlowDataStructures.FlowInterviewDetails();
			while (flowInterviewDetailsIterator.hasNext()) {
				String flowInterviewDetailsRow = flowInterviewDetailsIterator.next();
				String firstLinesFlowInterviewDetailsRow = getFirstLines(flowInterviewDetailsRow);

				if(firstLinesFlowInterviewDetailsRow?.startsWith(Constants.FLOW.PB_ST_FLOW_VAR_INTERVIEW_LABEL)) {
					info.flowInterviewDetails.interviewLabel = getLineValue(flowInterviewDetailsRow);
				}
				else if(firstLinesFlowInterviewDetailsRow?.startsWith(Constants.FLOW.PB_ST_FLOW_VAR_INTERVIEW_GUID)) {
					info.flowInterviewDetails.interviewGUID = getLineValue(flowInterviewDetailsRow);
				}
				else if(firstLinesFlowInterviewDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_CURRENT_USER_LABEL)) {
					List<String> userNameAndId = getNameAndId(flowInterviewDetailsRow);
					info.flowInterviewDetails.currentUserId = userNameAndId?.get(0);
					info.flowInterviewDetails.currentUserName = userNameAndId?.get(1);
				}
				else if(firstLinesFlowInterviewDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_START_TIME_LABEL)) {
					info.flowInterviewDetails.startTime = getLineValue(flowInterviewDetailsRow);
				}
				else if(firstLinesFlowInterviewDetailsRow?.startsWith(Constants.FLOW.PB_ST_VAR_DURATION_LABEL)) {
					info.flowInterviewDetails.duration = getLineValue(flowInterviewDetailsRow);
				}
			}
		}

		private void processHowInterviewStarted(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			// Implementation for how interview started processing
			FlowService.HTMLIterator howStartedIterator = new FlowService.HTMLIterator(stacktracePart, Constants.FLOW.HTML_TAG_BREAK_OPEN);
			info.howTheInterviewStarted = new FlowDataStructures.HowTheInterviewStarted();
			while (howStartedIterator.hasNext()) {
				String howStartedIteratorRow = howStartedIterator.next();
				String firstLinesHowStartedIteratorRow = getFirstLines(howStartedIteratorRow);

				if(firstLinesHowStartedIteratorRow.startsWith(Constants.FLOW.PB_ST_VAR_RUN_API_LABEL)) {
					info.howTheInterviewStarted.apiVersion = getLineValue(howStartedIteratorRow);
				}
				else if(firstLinesHowStartedIteratorRow.startsWith(Constants.FLOW.PB_ST_VAR_RECORD)) {
					List<String> recordNameAndId = getNameAndId(howStartedIteratorRow, '=');
					info.howTheInterviewStarted.recordId = getRelatedId(recordNameAndId?.get(0));
					info.howTheInterviewStarted.recordName = recordNameAndId?.get(1);
				}
				else if(firstLinesHowStartedIteratorRow.startsWith(Constants.FLOW.PB_ST_VAR_RECORD_ID)) {
					info.howTheInterviewStarted.recordId = getRelatedId(getLineValue(howStartedIteratorRow, '='));
				}
				else if(firstLinesHowStartedIteratorRow.startsWith(Constants.FLOW.PB_ST_VAR_SCHEDULED_PATH)) {
					info.howTheInterviewStarted.scheduledPath = getLineValue(howStartedIteratorRow);
				}
			}
		}

		private void processHandledError(FlowDataStructures.FlowStacktraceInfo info, String part) {
			// Implementation for handled error processing
			FlowService.HTMLIterator errorMessageIterator = new FlowService.HTMLIterator(part, Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN, Constants.FLOW.HTML_TAG_PARAGRAPH_CLOSE);
			while (errorMessageIterator.hasNext()) {
				info.handledErrorMessage = errorMessageIterator?.next()?.stripHtmlTags()?.trim();
				info.isHandledError = true;
				Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
				if (!info.stacktraceElements.isEmpty() && info.stacktraceElements.size() > lastElementIndex) {
					info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_ELEMENT_FAULT_PATH_EXECUTED, true);
				}
				break;
			}
		}

		private void processErrorMessage(FlowDataStructures.FlowStacktraceInfo info, String part) {

			// if error message is already set, do not process the part, for emails with handled errors main error message is already set
			if (String.isNotBlank(info?.errorMessage)) {

				Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
				info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_ELEMENT_FAULT_PATH_EXECUTED, true);
				return;
			}

			FlowService.HTMLIterator errorMessageIterator = new FlowService.HTMLIterator(part, Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN, Constants.FLOW.HTML_TAG_PARAGRAPH_CLOSE);
			while (errorMessageIterator.hasNext()) {
				String errorMessageHtml = errorMessageIterator?.next();
				String singleErrorMessageHtml = extractErrorMessage(errorMessageHtml);
				info.errorMessage = singleErrorMessageHtml?.stripHtmlTags()?.trim();
				info.errorMessageHtml = singleErrorMessageHtml;
				break;
			}
		}

		private String extractErrorMessage(String errorMessageHtml) {
			if (String.isBlank(errorMessageHtml)) {
				return '';
			}
			
			String singleErrorMessageHtml = errorMessageHtml;
			
			// Extract the last part after separator if present
			if (errorMessageHtml.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR)) {
				List<String> parts = errorMessageHtml.split(Constants.FLOW.FLOW_ERROR_MESSAGE_SEPARATOR);
				Integer lastElementIndex = parts?.size() != 0 ? parts?.size() - 1 : 0;
				singleErrorMessageHtml = parts.get(lastElementIndex);
			}
			
			// Extract the part after "occurred" if present
			if (singleErrorMessageHtml.containsIgnoreCase(Constants.FLOW.FLOW_ERROR_MESSAGE_PART_OCCURRED)) {
				List<String> parts = singleErrorMessageHtml.split(Constants.FLOW.FLOW_ERROR_MESSAGE_PART_OCCURRED);
				Integer lastElementIndex = parts?.size() != 0 ? parts?.size() - 1 : 0;
				singleErrorMessageHtml = parts.get(lastElementIndex);
			}
			
			return singleErrorMessageHtml;
		}

		private void processSalesforceErrorId(FlowDataStructures.FlowStacktraceInfo info, String part) {
			FlowService.HTMLIterator salesforceErrorIterator = new FlowService.HTMLIterator(part, Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN, Constants.FLOW.HTML_TAG_PARAGRAPH_CLOSE);
			while (salesforceErrorIterator.hasNext()) {
				info.salesforceErrorId = salesforceErrorIterator?.next()?.stripHtmlTags()?.trim();
				break;
			}
		}

		private void processHeadErrorStacktraceElement(FlowDataStructures.FlowStacktraceInfo info) {
			if (this.headErrorStacktraceElement == null) {
				return;
			}
			
			if (info.stacktraceElements?.isEmpty()) {
				info.stacktraceElements.add(this.headErrorStacktraceElement);
				return;
			}
			
			Integer lastElementIndex = info.stacktraceElements.size() - 1;
			FlowDataStructures.FlowStacktraceElement lastElement = info.stacktraceElements.get(lastElementIndex);
			
			// Add head error element if it doesn't match the last element
			if (lastElement == null || 
				(lastElement.nameOrLabel != this.headErrorStacktraceElement.nameOrLabel && 
				 lastElement.apiType != this.headErrorStacktraceElement.apiType)) {
				info.stacktraceElements.add(this.headErrorStacktraceElement);
			}
		}

		private void processStacktraceElements(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			if(stacktracePart?.containsIgnoreCase(Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN)) {
				String stacktracePartBeforeParagraph = stacktracePart?.substringBefore(Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN);
				if(stacktracePartBeforeParagraph?.length() > 3) {
					processStacktraceElement(info, stacktracePartBeforeParagraph);
				}
				String stacktracePartAfterParagraph = stacktracePart?.substringAfter(Constants.FLOW.HTML_TAG_PARAGRAPH_OPEN);
				if(stacktracePartAfterParagraph?.length() > 3) {
					processStacktraceElement(info, stacktracePartAfterParagraph);
				}
			}
			else {
				processStacktraceElement(info, stacktracePart);
			}
		}

		private void processStacktraceElement(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			FlowService.HTMLIterator stacktraceElementIterator = new FlowService.HTMLIterator(stacktracePart, Constants.FLOW.HTML_TAG_BREAK_OPEN);
			
			while (stacktraceElementIterator.hasNext()) {
				String stacktraceElementIteratorRow = stacktraceElementIterator.next();
				
				switch on stacktraceElementIterator.count {
					when 1 {
						if (isValidStacktraceElement(stacktraceElementIteratorRow)) {
							List<String> typeAndNameElements = stacktraceElementIteratorRow.stripHtmlTags().split(':', 2);
							String type = typeAndNameElements.get(0).trim();
							String apiNameOrLabel = typeAndNameElements.get(1).trim();
							FlowDataStructures.FlowStacktraceElement stacktraceElement = new FlowDataStructures.FlowStacktraceElement(type, apiNameOrLabel);
							
							if(type == Constants.FLOW.PB_ST_ELEMENT_LOOP) {
								String nope = stacktraceElementIterator.next();
								String loopThroughOrEndLoop = stacktraceElementIterator?.next()?.stripHtmlTags()?.trim();
								if(!loopThroughOrEndLoop?.containsIgnoreCase(Constants.FLOW.PB_ST_ELEMENT_LOOP_END)) {
									stacktraceElement.context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, Constants.FLOW.PB_ST_ELEMENT_LOOP_OUTCOME_FOR_EACH);
								}
								else {
									stacktraceElement.context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, Constants.FLOW.PB_ST_ELEMENT_LOOP_OUTCOME_LAST);
								}
							}
							
							// do not add additional PAUSE resume elements
							if (!isFlowPauseResumeElement(getLastStacktraceElement(info), stacktraceElement)) {
								info.stacktraceElements.add(stacktraceElement);
							}
							
							if (info.isHandledError != null && info.isHandledError) {
								info.isHandledError = false;
							}
						}
					}
					when else {
						String stackTraceElementRow = stacktraceElementIteratorRow;
						String firstLinesStackTraceElementRow = getFirstLines(stackTraceElementRow);
						if (firstLinesStackTraceElementRow.startsWith(Constants.FLOW.PB_ST_ELEMENT_RESULT)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							List<String> resultLines = info.stacktraceElements?.get(lastElementIndex)?.context?.get(Constants.FLOW.PB_ST_ELEMENT_RESULT) != null
								? (List<String>)info.stacktraceElements?.get(lastElementIndex)?.context?.get(Constants.FLOW.PB_ST_ELEMENT_RESULT)
								: new List<String>();
							while (stacktraceElementIterator.hasNext()) {
								String resultLine = stacktraceElementIterator?.next().stripHtmlTags()?.trim();
								if(String.isNotBlank(resultLine)) {
									resultLines.add(resultLine);
								}
							}
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_ELEMENT_RESULT, resultLines);
						}
						else if(firstLinesStackTraceElementRow.containsIgnoreCase(Constants.FLOW.PB_ST_DEFAULT_OUTCOME_EXECUTED)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, Constants.FLOW.PB_ST_VAR_DEFAULT_OUTCOME);
						}
						else if(firstLinesStackTraceElementRow.containsIgnoreCase(Constants.FLOW.PB_ST_DEFAULT_OUTCOME)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, Constants.FLOW.PB_ST_VAR_DEFAULT_OUTCOME);
						}
						else if(firstLinesStackTraceElementRow.startsWith(Constants.FLOW.PB_ST_OUTCOME)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							String outcomeName = stacktraceElementIteratorRow.stripHtmlTags().split(':').get(1).trim();
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, outcomeName);
						}
						else if(firstLinesStackTraceElementRow.startsWith(Constants.FLOW.PB_ST_ENTER_FLOW)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							String flowVersion = stacktraceElementIteratorRow.stripHtmlTags().split('version ').get(1).trim().removeEnd('.');
							String flowApiName = stacktraceElementIteratorRow.stripHtmlTags().split('version ').get(0).trim().removeStart('Enter flow ');
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME, flowApiName);
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_VERSION, flowVersion);
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_ENTER_FLOW, true);
						}
						else if(firstLinesStackTraceElementRow.startsWith(Constants.FLOW.PB_ST_EXIT_FLOW)) {
							Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
							String flowVersion = stacktraceElementIteratorRow.stripHtmlTags().split('version ').get(1).trim().removeEnd('.');
							String flowApiName = stacktraceElementIteratorRow.stripHtmlTags().split('version ').get(0).trim().removeStart('Exit flow ');
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME, flowApiName);
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_VERSION, flowVersion);
							info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_ENTER_FLOW, false);
						}
						else if(firstLinesStackTraceElementRow.startsWith(Constants.FLOW.PB_ST_PAUSE_CONFIGURATION)) {
							List<String> pauseConfigurationElements = stacktraceElementIteratorRow.stripHtmlTags().split(':', 2);
							if(pauseConfigurationElements?.size() == 2) {
								String pauseConfigurationName = pauseConfigurationElements.get(1).trim();
								Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
								info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_VAR_OUTCOME, pauseConfigurationName);
							}
						}
					}
				}
			}
		}
		

		private void processOrchestratorStage(FlowDataStructures.FlowStacktraceInfo info, String stacktracePart) {
			// Implementation for orchestrator stage processing
			FlowService.HTMLIterator orchestratorStacktraceIterator = new FlowService.HTMLIterator(stacktracePart, '<span style="font-weight:bold">');
			while (orchestratorStacktraceIterator.hasNext()) {
				String orchestratorElementIteratorRow = orchestratorStacktraceIterator.next();
				FlowService.HTMLIterator stacktraceElementIterator = new FlowService.HTMLIterator(orchestratorElementIteratorRow, Constants.FLOW.HTML_TAG_BREAK_OPEN);
				while (stacktraceElementIterator.hasNext()) {
					String stacktraceElementIteratorRow = stacktraceElementIterator.next();
					switch on stacktraceElementIterator.count {
						when 1 {
							if (isValidStacktraceElement(stacktraceElementIteratorRow)) {
								List<String> typeAndNameElements = stacktraceElementIteratorRow.stripHtmlTags().split(':', 2);
								String type = typeAndNameElements.get(0).trim();
								String apiNameOrLabel = typeAndNameElements.get(1).trim();
								FlowDataStructures.FlowStacktraceElement stacktraceElement = new FlowDataStructures.FlowStacktraceElement(type, apiNameOrLabel);
								info.stacktraceElements.add(stacktraceElement);
							}
							if (stacktraceElementIteratorRow.startsWith('Flow (')) {
								Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
								String subflowApiName = stacktraceElementIteratorRow.stripHtmlTags().removeStart('Flow (').removeEnd(')');
								info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME, subflowApiName);
								info.orchestratorFailedFlowApiName = subflowApiName;
							}
						}
						when else {
							if (stacktraceElementIteratorRow?.stripHtmlTags().startsWith('Action:')) {
								Integer lastElementIndex = info.stacktraceElements?.size() != 0 ? info?.stacktraceElements?.size() - 1 : 0;
								String subflowApiName = stacktraceElementIterator?.next()?.stripHtmlTags()?.trim();
								info.stacktraceElements.get(lastElementIndex).context.put(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME, subflowApiName);
								info.orchestratorFailedFlowApiName = subflowApiName;
							}
						}
					}
				}
			}
		}

		private void buildFlowHierarchy(FlowDataStructures.FlowStacktraceInfo info) {
			String flowFullNameWithVersion = getFlowApiNameWithVersion(info?.flowDetails?.flowApiName, info?.flowDetails?.version);
			info.flowApiNamePool.add(flowFullNameWithVersion);
			Integer indexFlow = info.flowApiNamePool.size() - 1;
			String flowName = (new List<String>(info.flowApiNamePool)).get(indexFlow);
			
			Map<String, String> flowNameMap = new Map<String, String>();
			
			for(FlowDataStructures.FlowStacktraceElement stElem : info.stacktraceElements) {
				if(stElem.type == 'SUBFLOW' && stElem.apiType == 'FlowSubflow') {
					String version = (String)stElem.context.get(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_VERSION);
					String apiName = (String)stElem.context.get(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME);
					Boolean isEnterFlow = (Boolean)stElem.context.get(Constants.FLOW.PB_ST_CONTEXT_ENTER_FLOW);
					
					String flowNameCurrent = getFlowApiNameWithVersion(apiName, version);
					
					// Track parent-child relationships
					if(isEnterFlow) {
						flowNameMap.put(flowNameCurrent, flowName);
					}
					
					if(!info.flowApiNamePool.contains(flowNameCurrent)) {
						info.flowApiNamePool.add(flowNameCurrent);
						
						if(isEnterFlow) {
							ensureFlowStacktraceElementsMapEntry(info, flowName);
							info.stacktraceElementsMap.get(flowName).add(stElem);
						}
					}
					
					if(isEnterFlow) {
						indexFlow = info.flowApiNamePool.size() - 1;
						flowName = (new List<String>(info.flowApiNamePool)).get(indexFlow);
					} else if(!isEnterFlow && flowNameMap.containsKey(flowNameCurrent)) {
						flowName = flowNameMap.get(flowNameCurrent);
					}
				}
				else {
					ensureFlowStacktraceElementsMapEntry(info, flowName);
					info.stacktraceElementsMap.get(flowName).add(stElem);
				}
			}
		}
		
		private void ensureFlowStacktraceElementsMapEntry(FlowDataStructures.FlowStacktraceInfo info, String flowName) {
			if(info.stacktraceElementsMap.get(flowName) == null) {
				info.stacktraceElementsMap.put(flowName, new List<FlowDataStructures.FlowStacktraceElement>());
			}
		}
	}

	public class HTMLIterator implements Iterator<String>, Iterable<String> {
		private String data;
		private String startDelimeter;
		private String endDelimeter;
		private Integer startIndex = 0;
		public Integer count = 0;

		public HTMLIterator(String data, String startDelimeter) {
			this(data, startDelimeter, null);
		}

		public HTMLIterator(String data, String startDelimeter, String endDelimeter) {
			this.data = data;
			this.startDelimeter = startDelimeter;
			this.endDelimeter = endDelimeter;
		}

		public Boolean hasNext() {
			return startIndex < data.length() ? true : false;
		}

		public String next() {
			Integer endIndex = data.indexOf(startDelimeter, startIndex);
			if (count != 0 && endIndex != -1) {
				endIndex += startDelimeter.length();
			}
			if(endDelimeter != null && endIndex != -1) {
				startIndex = endIndex;
				endIndex = data.indexOf(endDelimeter, endIndex);
				if(endIndex != -1) {
					endIndex += endDelimeter.length();
				}
			}
			if (endIndex == -1 ) {
				endIndex = data.length();
			}

			String part = data.substring(startIndex , endIndex);
			startIndex = endIndex;
			count++;
			return part;
		}

		public Iterator<String> iterator() {
			return this;
		}

	}

	public static String getRelatedId(String message) {
		if (String.isBlank(message)) return null;
		Set<String> relatedIds = new Set<String>();
		Pattern p = Constants.GLOBAL_VARIABLE.PATTERN_SOBJECT_ID;
		Matcher pm = p.matcher(message);
		while (pm.find()) {
			relatedIds.add(pm.group(1));
		}
		return !relatedIds.isEmpty() ? new List<String>(relatedIds).get(relatedIds.size() - 1) : null;
	}

	public static List<String> getFlowExecutionPath(String htmlStackTrace) {
		List<String> result = new List<String>();
		FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(htmlStackTrace);
		FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
		for(FlowDataStructures.FlowStacktraceElement ste : stackTraceInfo.stacktraceElements) {
			result.add(ste?.nameOrLabel);
		}
		return new List<String>(result);
	}

	// Process Builder Parser
	public static ProcessBuilder parseProcessBuilderStackTrace(String htmlStackTrace) {
		ProcessBuilder result = null;
		if(!isHtmlStacktrace(htmlStackTrace)) return result;

		FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(htmlStackTrace);
		FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();

		if(String.isNotBlank(stackTraceInfo?.flowDetails?.flowApiName)) {
			ProcessBuilderHelper helper = new ProcessBuilderHelper();
			result = getProcessBuilder(getFlowApiNameWithVersion(stackTraceInfo?.flowDetails?.flowApiName, stackTraceInfo?.flowDetails?.version), helper);
			helper.replaceIdsByNames(result);
			if(!stackTraceInfo?.context?.isEmpty()) {
				result.context.putAll(stackTraceInfo?.context);
			}

			if(stackTraceInfo?.flowDetails != null) {
				result.context.put(Constants.FLOW.PB_ST_VAR_FLOW_API_NAME_NAME, stackTraceInfo?.flowDetails?.flowApiName);
				result.context.put(Constants.FLOW.PB_ST_VAR_TYPE_NAME, stackTraceInfo?.flowDetails?.type);
				result.context.put(Constants.FLOW.PB_ST_VAR_VERSION_NAME, stackTraceInfo?.flowDetails?.version);
				result.context.put(Constants.FLOW.PB_ST_VAR_STATUS_NAME, stackTraceInfo?.flowDetails?.status);
				result.context.put(Constants.FLOW.PB_ST_VAR_ORG_NAME, stackTraceInfo?.flowDetails?.orgName);
			}
			if(stackTraceInfo?.flowInterviewDetails != null) {
				result.context.put(Constants.FLOW.PB_ST_VAR_CURRENT_USER_NAME, stackTraceInfo?.flowInterviewDetails.currentUserName);
				result.context.put(Constants.FLOW.PB_ST_VAR_START_TIME_NAME, stackTraceInfo?.flowInterviewDetails.startTime);
			}
			if(stackTraceInfo?.howTheInterviewStarted != null) {
				result.context.put(Constants.FLOW.PB_ST_VAR_RUN_API_NAME, stackTraceInfo?.howTheInterviewStarted?.apiVersion);
			}

			for(FlowDataStructures.FlowStacktraceElement fse : stackTraceInfo.stacktraceElements) {
				for(ProcessBuilderDecision pbd : result?.decisions) {
					if(pbd.name == fse.nameOrLabel){
						pbd.executed = true;
					}
					if(pbd.executed) {
						for(List<ProcessBuilderAction> pbaList : pbd?.actions) {
							for(ProcessBuilderAction pba : pbaList) {
								if (pba.name == fse.nameOrLabel || pba.label == fse.nameOrLabel) {
									pba.executed = true;
								}
							}
						}
					}
				}
			}

			result.errorMessage = stackTraceInfo?.errorMessage;
			result.errorMessageHtml = stackTraceInfo?.errorMessageHtml;
			try {
				result.apexStackTraceParseResults = StackTraceParser.parseStackTrace(result.errorMessageHtml);
			}
			catch(Exception e) {}
		}

		return result;
	}

	public static String getFlowApiNameWithVersion(String flowApiName, String flowVersion) {
		return flowApiName + (String.isNotBlank(flowVersion) ? ('-' + flowVersion) : '');
	}

	public static ProcessBuilder getProcessBuilder(String flowApiNameWithVersion, ProcessBuilderHelper helper) {
		ProcessBuilder result = new ProcessBuilder();

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.setEndpointAndMetadataAPIVersion(StackTraceParser.corg.Instance_Url__c, Constants.FLOW.PB_CURRENT_SUPPORTED_API_VERSION);
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = ConnectedOrgService.getConnectedOrgAccessToken(StackTraceParser.corg);
		MetadataService.Flow sfdcFlow =
			(MetadataService.Flow) service.readMetadata('Flow',
				new String[] {flowApiNameWithVersion}).getRecords()[0];

		if(sfdcFlow != null && sfdcFlow.fullName != null) {
			result.name = sfdcFlow.fullName;
			result.label = sfdcFlow.label;
			result.processType = sfdcFlow.processType;
			result.start = new ProcessBuilderStart(sfdcFlow.processType, sfdcFlow);
			getDecisions(result, sfdcFlow, helper);
		}
		if(result.decisions != null) {
			result.decisions.sort();
		}
		return result;
	}

	public static String getDecisionLabelByCriteriaName(MetadataService.FlowDecision flowDecision) {
		String result;
		if(flowDecision.rules != null) {
			for(MetadataService.FlowRule flowRule : flowDecision.rules) {
				result = flowRule?.label;
				break;
			}
		}
		return result;
	}

	public static void getDecisions(ProcessBuilder instance, MetadataService.Flow sfdcFlow, ProcessBuilderHelper helper) {
		if(sfdcFlow.decisions != null) {
			for(MetadataService.FlowDecision flowDecision : sfdcFlow.decisions) {
				Object decisionIndex = getProcessMetadataValue(Constants.FLOW.PB_META_KEY_INDEX, flowDecision?.processMetadataValues);
				if(flowDecision != null && decisionIndex != null) {
					ProcessBuilderDecision fDecision = new ProcessBuilderDecision();
					fDecision.name = flowDecision.name;
					fDecision.label = getDecisionLabelByCriteriaName(flowDecision);
					fDecision.index = String.valueOf(decisionIndex);

					addDecisionSections(flowDecision, fDecision, sfdcFlow);

					List<String> firstActionNames = getFirstActionNameFromDecision(flowDecision);
					getDecisionActions(instance, firstActionNames, sfdcFlow, fDecision.actions, new Set<String>(), helper);
					instance.decisions.add(fDecision);

				}
			}
		}
		return;
	}

	public static Set<String> getMainDecisionNames(MetadataService.Flow sfdcFlow) {
		Set<String> result = new Set<String>();
		if(sfdcFlow?.decisions != null) {
			for(MetadataService.FlowDecision flowDecision : sfdcFlow.decisions) {
				Object decisionIndex = getProcessMetadataValue(Constants.FLOW.PB_META_KEY_INDEX, flowDecision?.processMetadataValues);
				if(flowDecision != null && decisionIndex != null) {
					result.add(flowDecision.name);
				}
			}
		}
		return result;
	}

	public static void getDecisionActions(
		ProcessBuilder instance,
		String nextActionName,
		MetadataService.Flow sfdcFlow,
		List<List<ProcessBuilderAction>> actions,
		Set<String> apiNames,
		ProcessBuilderHelper helper) {
		getDecisionActions(instance, new List<String>{nextActionName}, sfdcFlow, actions, apiNames, helper);
	}

	public static void getDecisionActions(
		ProcessBuilder instance,
		List<String> nextActionNames,
		MetadataService.Flow sfdcFlow,
		List<List<ProcessBuilderAction>> actions,
		Set<String> apiNames,
		ProcessBuilderHelper helper) {

		for(String nextActionName : nextActionNames) {

			// check loop metadata
			if(apiNames.contains(nextActionName)) return;

			if(sfdcFlow.decisions != null) {
				for(MetadataService.FlowDecision fDecision : sfdcFlow.decisions) {
					Object decisionIndex = getProcessMetadataValue(Constants.FLOW.PB_META_KEY_INDEX, fDecision.processMetadataValues);
					if(fDecision.name == nextActionName && decisionIndex == null) {
						if(fDecision.rules != null) {
							for(MetadataService.FlowRule flowRule : fDecision.rules) {
								if(flowRule != null && flowRule.connector != null && flowRule.connector.targetReference != null) {
									getDecisionActions(instance, flowRule.connector.targetReference, sfdcFlow, actions, apiNames, helper);
								}
							}
						}
					}
				}
			}

			if(sfdcFlow.waits != null) {
				for(MetadataService.FlowWait flowWait : sfdcFlow.waits) {
					if(flowWait.name == nextActionName) {
						for(MetadataService.FlowWaitEvent flowWaitEvent : flowWait.waitEvents) {
							if(!apiNames.contains(flowWaitEvent.name)) {
								addFlowWaitSections(flowWaitEvent, actions);
								apiNames.add(flowWaitEvent.name);
							}
							if(flowWaitEvent != null && flowWaitEvent.connector != null && flowWaitEvent.connector.targetReference != null) {
								getDecisionActions(instance, flowWaitEvent.connector.targetReference, sfdcFlow, actions, apiNames, helper);
							}
						}
						return;
					}
				}
			}

			if(sfdcFlow.assignments != null) {
				for(MetadataService.FlowAssignment flowAssignment : sfdcFlow.assignments) {
					if(flowAssignment.name == nextActionName) {
						if(!apiNames.contains(flowAssignment.name)) {
							apiNames.add(flowAssignment.name);
						}
						if(flowAssignment.connector != null && flowAssignment.connector.targetReference != null) {
							getDecisionActions(instance, flowAssignment.connector.targetReference, sfdcFlow, actions, apiNames, helper);
						}
						return;
					}
				}
			}

			if(sfdcFlow.actionCalls != null) {
				for(MetadataService.FlowActionCall actionCall : sfdcFlow.actionCalls) {
					if(actionCall.name == nextActionName) {
						if(!apiNames.contains(actionCall.name)) {
							addActionCallSections(actionCall, actions, helper, sfdcFlow);
							apiNames.add(actionCall.name);
						}
						if(actionCall.connector != null && actionCall.connector.targetReference != null) {
							getDecisionActions(instance, actionCall.connector.targetReference, sfdcFlow, actions, apiNames, helper);
						}
						return;
					}
				}
			}

			if(sfdcFlow.recordCreates != null) {
				for(MetadataService.FlowRecordCreate recordCreate : sfdcFlow.recordCreates) {
					if(recordCreate.name == nextActionName) {
						if(!apiNames.contains(recordCreate.name)) {
							addRecordCreateSections(recordCreate, actions, sfdcFlow);
							apiNames.add(recordCreate.name);
						}
						if(recordCreate.connector != null && recordCreate.connector.targetReference != null) {
							getDecisionActions(instance, recordCreate.connector.targetReference, sfdcFlow, actions, apiNames, helper);
						}
						return;
					}
				}
			}

			if(sfdcFlow.recordUpdates != null) {
				for(MetadataService.FlowRecordUpdate recordUpdate : sfdcFlow.recordUpdates) {
					if(recordUpdate.name == nextActionName) {
						if(!apiNames.contains(recordUpdate.name)) {
							addRecordUpdateSections(recordUpdate, actions, sfdcFlow);
							apiNames.add(recordUpdate.name);
						}
						if(recordUpdate.connector != null && recordUpdate.connector.targetReference != null) {
							getDecisionActions(instance, recordUpdate.connector.targetReference, sfdcFlow, actions, apiNames, helper);
						}
						return;
					}
				}
			}
		}
		return;
	}

	public static void addDecisionSections(MetadataService.FlowDecision flowDecision, ProcessBuilderDecision fDecision, MetadataService.Flow sfdcFlow) {
		if(flowDecision.rules != null) {
			for(MetadataService.FlowRule fRule : flowDecision.rules) {

				SideBarSection criteriaNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_CRITERIA_NAME, SideBarItemType.TEXT)
					.addText(fRule.label);
				fDecision.sections.add(criteriaNameSection);

				Boolean isCriteriaFormula = (!fRule.conditions.isEmpty()
					&& fRule.conditions.size() == 1
					&& fRule.conditions.get(0).leftValueReference.startsWith(Constants.FLOW.PB_META_KEY_VALUE_FORMULA_PREFIX)
					&& getFlowFormulaExpression(fRule.conditions.get(0).leftValueReference, sfdcFlow) != 'true');
				Boolean isNoCriteries = (!fRule.conditions.isEmpty()
					&& fRule.conditions.size() == 1
					&& fRule.conditions.get(0).leftValueReference.startsWith(Constants.FLOW.PB_META_KEY_VALUE_FORMULA_PREFIX)
					&& getFlowFormulaExpression(fRule.conditions.get(0).leftValueReference, sfdcFlow) == 'true');
				Boolean isCritariaConditions = !isCriteriaFormula && !isNoCriteries;

				SideBarSection executingCriteriaSection = new SideBarSection(Constants.FLOW.PB_LABEL_CRITERIA_EXECUTING_ACTIONS, SideBarItemType.RADIOBUTTON)
					.addRadioButton(isCritariaConditions, Constants.FLOW.PB_LABEL_CONDITIONS_MET)
					.addRadioButton(isCriteriaFormula, Constants.FLOW.PB_LABEL_FORMULA_EVALUATE)
					.addRadioButton(isNoCriteries, Constants.FLOW.PB_LABEL_NO_CRITERIES);
				fDecision.sections.add(executingCriteriaSection);

				if(isCriteriaFormula) {
					SideBarSection criteriaFormulaSection = new SideBarSection(Constants.FLOW.PB_LABEL_BUILD_FORMULA, SideBarItemType.TEXTAREA)
						.addText(getFlowFormulaValue(fRule.conditions.get(0).leftValueReference, sfdcFlow));
					fDecision.sections.add(criteriaFormulaSection);
				}

				if(isCritariaConditions) {
					SideBarSection conditionsSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_CONDITIONS, SideBarItemType.TABLE);
					Integer indexCounter = 1;
					conditionsSection.addTableHeaders(new List<String>{null, Constants.FLOW.PB_TABLE_LABEL_SOURCE, Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_OPERATOR, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});

					if(fRule.conditions != null) {
						for(MetadataService.FlowCondition fc : fRule.conditions) {
							List<SideBarTableRow> rowObjects = new List<SideBarTableRow>();
							rowObjects.add(new SideBarTableRow(String.valueOf(indexCounter++)));
							rowObjects.add(new SideBarTableRow(fc?.leftValueReference));
							rowObjects.add(new SideBarTableRow(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_TYPE, fc?.processMetadataValues))));
							rowObjects.add(new SideBarTableRow(Constants.FLOW.OPERATORS_MAP.get(fc?.operator)));

							String rowType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, fc?.processMetadataValues));
							rowObjects.add(new SideBarTableRow(rowType));

							String rowValue = String.valueOf(getFlowElementReferenceOrValue(fc?.rightValue));
							rowValue = (rowType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA) ? getFlowFormulaValue(rowValue, sfdcFlow) : rowValue;
							rowObjects.add(new SideBarTableRow(rowValue, (rowType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA)));

							conditionsSection.addTableRows(rowObjects);
						}
					}
					fDecision.sections.add(conditionsSection);

					SideBarSection conditionCriteriaSection = new SideBarSection(Constants.FLOW.PB_LABEL_CRITERIA_EXECUTING_ACTIONS, SideBarItemType.RADIOBUTTON)
						.addRadioButton(fRule.conditionLogic == Constants.FLOW.PB_META_KEY_VALUE_AND, Constants.FLOW.PB_LABEL_ALL_CONDITIONS_MET)
						.addRadioButton(fRule.conditionLogic == Constants.FLOW.PB_META_KEY_VALUE_OR, Constants.FLOW.PB_LABEL_ANY_CONDITIONS_MET)
						.addRadioButton(fRule.conditionLogic != Constants.FLOW.PB_META_KEY_VALUE_AND && fRule.conditionLogic != Constants.FLOW.PB_META_KEY_VALUE_OR, Constants.FLOW.PB_LABEL_CUSTOMIZE_LOGIC);
					fDecision.sections.add(conditionCriteriaSection);
				}
			}
		}
	}

	public static void addFlowWaitSections(MetadataService.FlowWaitEvent flowWaitEvent, List<List<ProcessBuilderAction>> actions) {
		ProcessBuilderAction pba = new ProcessBuilderAction(flowWaitEvent.name, flowWaitEvent.label, Constants.FLOW.PB_ACTION_TYPE_SCHEDULED_ACTION_START);
		pba.setIcon(Constants.FLOW.PB_ICON_SCHEDULED_ACTION);
		MetadataService.FlowWaitEventInputParameter timeOffsetUnit = getInputParameterByName(Constants.FLOW.PB_META_KEY_TIME_OFFSET_UNIT, flowWaitEvent.inputParameters);
		MetadataService.FlowWaitEventInputParameter timeOffset = getInputParameterByName(Constants.FLOW.PB_META_KEY_TIME_OFFSET, flowWaitEvent.inputParameters);
		String sTimeOffsetUnit = String.valueOf(getFlowElementReferenceOrValue(timeOffsetUnit.value));
		String sTimeOffset = String.valueOf(getFlowElementReferenceOrValue(timeOffset.value));
		Integer timeOffsetInteger = Integer.valueOf(sTimeOffset);

		switch on flowWaitEvent.eventType {
			when 'AlarmEvent' {
				SideBarSection timeSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_TIME_FOR_ACTIONS, SideBarItemType.TABLETIME)
					.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(false),
						new SideBarTableRow(''),
						new SideBarTableRow(Constants.FLOW.PB_LABEL_DAYS),
						new SideBarTableRow(Constants.FLOW.PB_LABEL_TIME_AFTER),
						new SideBarTableRow('')
					})
					.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(true),
						new SideBarTableRow(Math.abs(timeOffsetInteger)),
						new SideBarTableRow(sTimeOffsetUnit),
						new SideBarTableRow(Constants.FLOW.PB_LABEL_TIME_FROM_NOW)
					});
				pba.sections.add(timeSection);
				pba.label = timeOffsetInteger + ' ' + sTimeOffsetUnit + ' ' + Constants.FLOW.PB_LABEL_TIME_FROM_NOW;
			}
			when 'DateRefAlarmEvent' {
				MetadataService.FlowWaitEventInputParameter timeFieldColumnEnumOrId = getInputParameterByName(Constants.FLOW.PB_META_KEY_TIME_FIELD_ENUM_OR_ID, flowWaitEvent.inputParameters);
				String sTimeFieldColumnEnumOrId = String.valueOf(getFlowElementReferenceOrValue(timeFieldColumnEnumOrId.value));
				String isBeforeAfter = (timeOffsetInteger < 0) ? Constants.FLOW.PB_LABEL_TIME_BEFORE : Constants.FLOW.PB_LABEL_TIME_AFTER;
				SideBarSection timeSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_TIME_FOR_ACTIONS, SideBarItemType.TABLETIME)
					.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(true),
						new SideBarTableRow(Math.abs(timeOffsetInteger)),
						new SideBarTableRow(sTimeOffsetUnit),
						new SideBarTableRow(isBeforeAfter),
						new SideBarTableRow(sTimeFieldColumnEnumOrId)
					})
					.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(false),
						new SideBarTableRow(''),
						new SideBarTableRow(Constants.FLOW.PB_LABEL_DAYS),
						new SideBarTableRow(Constants.FLOW.PB_LABEL_TIME_FROM_NOW)
					});
				pba.sections.add(timeSection);
				pba.label = Math.abs(timeOffsetInteger) + ' ' + sTimeOffsetUnit + ' ' + isBeforeAfter + ' ' + sTimeFieldColumnEnumOrId;
			}
		}
		actions.add(new List<ProcessBuilderAction>{pba});
	}

	public static void addActionCallSections(MetadataService.FlowActionCall actionCall, List<List<ProcessBuilderAction>> actions, ProcessBuilderHelper helper, MetadataService.Flow sfdcFlow) {
		Integer index = (actions.size() == 0) ? 0 : actions.size() - 1;
		ProcessBuilderAction pba = new ProcessBuilderAction(actionCall.name, actionCall.label, Constants.FLOW.PB_ACTION_TYPE_FLOW_ACTION_CALL);
		Set<String> decisionNames = getMainDecisionNames(sfdcFlow);
		pba.evaluateNextCriteria = (actionCall.connector != null && actionCall.connector.targetReference != null && decisionNames.contains(actionCall.connector.targetReference));

		switch on actionCall.actionType {
			when 'submit' {
				pba.setIcon(Constants.FLOW.PB_ICON_SUBMIT_FOR_APPROVAL);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				SideBarSection objectSection = new SideBarSection(Constants.FLOW.PB_LABEL_OBJECT, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_OBJECT_TYPE, sfdcFlow.processMetadataValues)));
				pba.sections.add(objectSection);

				String selectionType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_SELECTION_TYPE, actionCall.processMetadataValues));
				switch on selectionType {
					when 'firstFound' {
						SideBarSection approvalProcessSection = new SideBarSection(Constants.FLOW.PB_LABEL_APPROVAL_PROCESS, SideBarItemType.TEXT)
							.addText(Constants.FLOW.PB_LABEL_DEFAULT_APPROVAL_PROCESS);
						pba.sections.add(approvalProcessSection);
					}
					when 'selectedProcess' {
						String processSelection = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_PROCESS_SELECTION, actionCall.processMetadataValues));

						SideBarSection approvalProcessSection = new SideBarSection(Constants.FLOW.PB_LABEL_APPROVAL_PROCESS, SideBarItemType.TABLE)
							.addTableHeaders(new List<String>{'', ''})
							.addTableRows(new List<SideBarTableRow>{
								new SideBarTableRow(Constants.FLOW.PB_LABEL_SPECIFIC_APPROVAL_PROCESS),
								new SideBarTableRow(processSelection)
							});
						pba.sections.add(approvalProcessSection);

						if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
							MetadataService.FlowActionCallInputParameter skipEntryCriteria = getInputParameterByName(Constants.FLOW.PB_META_KEY_SKIP_ENTRY_CRITERIA, actionCall.inputParameters);
							Boolean sSkipEntryCriteria = Boolean.valueOf(getFlowElementReferenceOrValue(skipEntryCriteria.value));

							SideBarSection skipEntrySection = new SideBarSection(Constants.FLOW.PB_LABEL_SKIP_ENTRY_CRITERIA, SideBarItemType.CHECKBOX)
								.addCheckBox(sSkipEntryCriteria, Constants.FLOW.PB_LABEL_YES);
							pba.sections.add(skipEntrySection);
						}
					}
				}

				SideBarSection submitterSection = new SideBarSection(Constants.FLOW.PB_LABEL_SUBMITTER, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_SUBMITTER_TYPE, actionCall.processMetadataValues)));
				pba.sections.add(submitterSection);

				if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
					MetadataService.FlowActionCallInputParameter comments = getInputParameterByName(Constants.FLOW.PB_META_KEY_COMMENT, actionCall.inputParameters);
					String sComments = String.valueOf(getFlowElementReferenceOrValue(comments.value));

					SideBarSection commentsSection = new SideBarSection(Constants.FLOW.PB_LABEL_SUBMISSION_COMMENTS, SideBarItemType.TEXTAREA)
						.addText(sComments);
					pba.sections.add(commentsSection);
				}
			}
			when 'flow' {
				pba.setIcon(Constants.FLOW.PB_ICON_FLOW);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				SideBarSection typeSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_FLOW, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_FLOW_SELECTION, actionCall.processMetadataValues)));
				pba.sections.add(typeSection);
			}
			when 'customNotificationAction' {
				pba.setIcon(Constants.FLOW.PB_ICON_CUSTOM_NOTIFICATION);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				SideBarSection typeSection = new SideBarSection(Constants.FLOW.PB_LABEL_NOTIFICATION_TYPE, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_CUSTOM_NOTIFICATION_TYPE, actionCall.processMetadataValues)));
				pba.sections.add(typeSection);

				if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
					MetadataService.FlowActionCallInputParameter title = getInputParameterByName(Constants.FLOW.PB_META_KEY_TITLE, actionCall.inputParameters);
					MetadataService.FlowActionCallInputParameter body = getInputParameterByName(Constants.FLOW.PB_META_KEY_BODY, actionCall.inputParameters);
					String sTitle = String.valueOf(getFlowElementReferenceOrValue(title.value));
					String sBody = String.valueOf(getFlowElementReferenceOrValue(body.value));

					String sRecipientCategory = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_CATEGORY, actionCall.processMetadataValues));
					String recipientCategoryValue = '';
					String sRecipientType = (getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_TYPE, actionCall.processMetadataValues) != null) ? String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_TYPE, actionCall.processMetadataValues)) : '';
					String recipientTypeValue = '';

					switch on sRecipientCategory {
						when 'user' {
							recipientCategoryValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_USER;

							switch on sRecipientType {
								when 'currentUser' {
									recipientTypeValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_USER_CURRENT_USER;
									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, Constants.FLOW.PB_TABLE_LABEL_USER})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(recipientTypeValue)
										});
									pba.sections.add(recipientSection);
								}
								when 'user' {
									recipientTypeValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_USER_FIND_USER;
									String sRecipientSelection = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_SELECTION, actionCall.processMetadataValues));

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, Constants.FLOW.PB_TABLE_LABEL_USER, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(recipientTypeValue),
											new SideBarTableRow(sRecipientSelection)
										});
									pba.sections.add(recipientSection);
								}
								when 'reference' {
									recipientTypeValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_USER_REFERENCE;

									MetadataService.FlowActionCallInputParameter recipientIds = getInputParameterByName(Constants.FLOW.PB_META_KEY_RECIPIENT_IDS, actionCall.inputParameters);
									String sRecipientIds = String.valueOf(getFlowElementReferenceOrValue(recipientIds.value));
									String sRecipientIdsValue = getFlowAssigmentItemValue(sRecipientIds, sfdcFlow);

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, Constants.FLOW.PB_TABLE_LABEL_USER, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(recipientTypeValue),
											new SideBarTableRow(sRecipientIdsValue)
										});
									pba.sections.add(recipientSection);
								}
							}
						}
						when 'owner' {
							recipientCategoryValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_OWNER;
							switch on sRecipientType {
								when 'reference' {
									MetadataService.FlowActionCallInputParameter recipientIds = getInputParameterByName(Constants.FLOW.PB_META_KEY_RECIPIENT_IDS, actionCall.inputParameters);
									String sRecipientIds = String.valueOf(getFlowElementReferenceOrValue(recipientIds.value));
									String sRecipientIdsValue = getFlowAssigmentItemValue(sRecipientIds, sfdcFlow);

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(sRecipientIdsValue)
										});
									pba.sections.add(recipientSection);
								}
							}
						}
						when 'group' {
							recipientCategoryValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_GROUP;

							switch on sRecipientType {
								when 'record' {
									String sRecipientSelection = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_SELECTION, actionCall.processMetadataValues));

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_GROUP, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(sRecipientSelection)
										});
									pba.sections.add(recipientSection);
								}
							}
						}
						when 'queue' {
							recipientCategoryValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE;

							switch on sRecipientType {
								when 'record' {
									recipientTypeValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE_RECORD;
									String sRecipientSelection = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECIPIENT_SELECTION, actionCall.processMetadataValues));

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, Constants.FLOW.PB_TABLE_LABEL_QUEUE, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(recipientTypeValue),
											new SideBarTableRow(sRecipientSelection)
										});
									pba.sections.add(recipientSection);
								}
								when 'reference' {
									recipientTypeValue = Constants.FLOW.PB_LABEL_QA_RECIPIENT_CATEGORY_QUEUE_REFERENCE;

									MetadataService.FlowActionCallInputParameter recipientIds = getInputParameterByName(Constants.FLOW.PB_META_KEY_RECIPIENT_IDS, actionCall.inputParameters);
									String sRecipientIds = String.valueOf(getFlowElementReferenceOrValue(recipientIds.value));
									String sRecipientIdsValue = getFlowAssigmentItemValue(sRecipientIds, sfdcFlow);

									SideBarSection recipientSection = new SideBarSection('', SideBarItemType.TABLE)
										.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_NOTIFICATION_RECIPIENT, Constants.FLOW.PB_TABLE_LABEL_QUEUE, ''})
										.addTableRows(new List<SideBarTableRow>{
											new SideBarTableRow(recipientCategoryValue),
											new SideBarTableRow(recipientTypeValue),
											new SideBarTableRow(sRecipientIdsValue)
										});
									pba.sections.add(recipientSection);
								}
							}
						}
					}

					SideBarSection titleSection = new SideBarSection(Constants.FLOW.PB_LABEL_NOTIFICATION_TITLE, SideBarItemType.TEXTAREA)
						.addText(sTitle);
					pba.sections.add(titleSection);
					SideBarSection bodySection = new SideBarSection(Constants.FLOW.PB_LABEL_NOTIFICATION_BODY, SideBarItemType.TEXTAREA)
						.addText(sBody);
					pba.sections.add(bodySection);
				}
			}
			when 'quickAction' {
				pba.setIcon(Constants.FLOW.PB_ICON_QUICK_ACTION);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				String filterType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_FILTER_TYPE, actionCall.processMetadataValues));
				String quickActionType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_QA_TYPE, actionCall.processMetadataValues));
				String filterTypeValue = '';
				String qaTypeValue = '';

				switch on filterType {
					when 'quickActionType' {
						filterTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_TYPE;
					}
					when 'globalType' {
						filterTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_GLOBAL;
					}
					when 'objectType' {
						filterTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_OBJECT;
					}
				}
				switch on quickActionType {
					when 'create' {
						qaTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_CREATE;
					}
					when 'update' {
						qaTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_UPDATE;
					}
					when 'logACall' {
						qaTypeValue = Constants.FLOW.PB_LABEL_QA_FILTER_LOG_A_CALL;
					}
				}

				SideBarSection actionSection = new SideBarSection('', SideBarItemType.TABLE)
					.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_FILTER_SEARCH_BY, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_ACTION})
					.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(filterTypeValue),
						new SideBarTableRow(qaTypeValue),
						new SideBarTableRow(actionCall.actionName)
					});
				pba.sections.add(actionSection);

				if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
					SideBarSection qaFieldSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_QA_FIELD_VALUES, SideBarItemType.TABLE)
						.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});
					for(MetadataService.FlowActionCallInputParameter ip : actionCall.inputParameters) {
						String fieldLabel = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, ip?.processMetadataValues));
						String rowType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, ip?.processMetadataValues));
						String rowValue = String.valueOf(getFlowElementReferenceOrValue(ip?.value));

						qaFieldSection.addTableRows(new List<SideBarTableRow>{
							new SideBarTableRow(fieldLabel),
							new SideBarTableRow(rowType),
							new SideBarTableRow(rowValue)
						});
					}
					pba.sections.add(qaFieldSection);
				}
			}
			when 'chatterPost' {
				pba.setIcon(Constants.FLOW.PB_ICON_CHATTER);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
					String postToValue;
					String sType;
					MetadataService.FlowActionCallInputParameter subjectNameOrId = getInputParameterByName(Constants.FLOW.PB_META_KEY_SUBJECT_NAME_OR_ID, actionCall.inputParameters);
					MetadataService.FlowActionCallInputParameter ipType = getInputParameterByName(Constants.FLOW.PB_META_KEY_TYPE, actionCall.inputParameters);
					String sSubjectNameOrId = String.valueOf(getFlowElementReferenceOrValue(subjectNameOrId.value));

					if(ipType.value == null) {
						postToValue = Constants.FLOW.PB_LABEL_POST_TO_THIS_RECORD;
						SideBarSection postToSection = new SideBarSection(Constants.FLOW.PB_LABEL_POST_TO, SideBarItemType.TEXT)
							.addText(sSubjectNameOrId);
						pba.sections.add(postToSection);
					}
					else {
						sType = String.valueOf(getFlowElementReferenceOrValue(ipType.value));
						if(sType == Constants.FLOW.PB_META_KEY_VALUE_USER) {
							postToValue = Constants.FLOW.PB_LABEL_POST_TO_CHATTER_USER;
							String userValue = (sSubjectNameOrId.startsWith(Constants.FLOW.PB_META_KEY_VALUE_USER_ID_PREFIX)) ? Constants.FLOW.PB_LABEL_SEARCH_USER : Constants.FLOW.PB_LABEL_SELECT_USER;
							if(sSubjectNameOrId.startsWith(Constants.FLOW.PB_META_KEY_VALUE_USER_ID_PREFIX)) {
								helper.userIds.add(sSubjectNameOrId);
								helper.actionNames.add(actionCall.name);
							}

							SideBarSection postToSection = new SideBarSection('', SideBarItemType.TABLE)
								.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_POST_TO, Constants.FLOW.PB_TABLE_LABEL_USER, null})
								.addTableRows(new List<SideBarTableRow>{
									new SideBarTableRow(postToValue),
									new SideBarTableRow(userValue),
									new SideBarTableRow(sSubjectNameOrId)
								});
							pba.sections.add(postToSection);
						}
						else if(sType == Constants.FLOW.PB_META_KEY_VALUE_GROUP) {
							postToValue = Constants.FLOW.PB_LABEL_POST_TO_CHATTER_GROUP;
							if(sSubjectNameOrId.startsWith(Constants.FLOW.PB_META_KEY_VALUE_GROUP_ID_PREFIX)) {
								helper.groupIds.add(sSubjectNameOrId);
								helper.actionNames.add(actionCall.name);
							}
							SideBarSection postToSection = new SideBarSection('', SideBarItemType.TABLE)
								.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_POST_TO, Constants.FLOW.PB_TABLE_LABEL_GROUP})
								.addTableRows(new List<SideBarTableRow>{
									new SideBarTableRow(postToValue),
									new SideBarTableRow(sSubjectNameOrId)
								});
							pba.sections.add(postToSection);
						}
					}
				}

				String messageWrapperJson = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_TEXT_JSON, actionCall.processMetadataValues));
				if(String.isNotBlank(messageWrapperJson)) {
					Map<String, Object> messageMap = (Map<String, Object>)JSON.deserializeUntyped(messageWrapperJson);
					if(messageMap != null && messageMap.containsKey(Constants.FLOW.PB_META_KEY_MESSAGE)) {
						SideBarSection messageSection = new SideBarSection(Constants.FLOW.PB_LABEL_MESSAGE, SideBarItemType.TEXTAREA)
							.addText(String.valueOf(messageMap.get(Constants.FLOW.PB_META_KEY_MESSAGE)));
						pba.sections.add(messageSection);
					}
				}
			}
			when 'emailAlert' {
				pba.setIcon(Constants.FLOW.PB_ICON_EMAIL_ALERT);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				SideBarSection emailAlertSection = new SideBarSection(Constants.FLOW.PB_LABEL_EMAIL_ALERT, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_EMAIL_ALERT_SELECTION, actionCall.processMetadataValues)));
				pba.sections.add(emailAlertSection);
			}
			when 'apex' {
				pba.setIcon(Constants.FLOW.PB_ICON_APEX);
				SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
					.addText(actionCall.label);
				pba.sections.add(actionNameSection);

				SideBarSection apexClassSection = new SideBarSection(Constants.FLOW.PB_LABEL_APEX_CLASS, SideBarItemType.TEXT)
					.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_APEX_SELECTION, actionCall.processMetadataValues)));
				pba.sections.add(apexClassSection);

				if(actionCall.inputParameters != null && !actionCall.inputParameters.isEmpty()) {
					SideBarSection apexVariablesSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_APEX_VARIABLES, SideBarItemType.TABLE)
						.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});
					for(MetadataService.FlowActionCallInputParameter ip : actionCall.inputParameters) {
						String rowType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, ip?.processMetadataValues));
						String rowTypeLabel = Constants.FLOW.FILTER_TYPE_MAP.get(rowType);
						Boolean isFieldReference = rowType == Constants.FLOW.PB_LABEL_SOBJECT;
						String rowValue;
						if(isFieldReference) {
							String variableName = String.valueOf(getFlowElementReferenceOrValue(ip?.value));
							MetadataService.FlowVariable variable = getFlowVariable(variableName, sfdcFlow);
							rowValue = variable?.objectType;
						}
						rowValue = (isFieldReference) ? rowValue : Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_NULL;

						apexVariablesSection.addTableRows(new List<SideBarTableRow>{
							new SideBarTableRow(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, ip?.processMetadataValues))),
							new SideBarTableRow(rowTypeLabel),
							new SideBarTableRow(rowValue)
						});
					}
					pba.sections.add(apexVariablesSection);
				}
			}
		}
		actions.get(index).add(pba);
	}

	public static void addRecordCreateSections(MetadataService.FlowRecordCreate recordCreate, List<List<ProcessBuilderAction>> actions, MetadataService.Flow sfdcFlow) {
		Integer index = (actions.size() == 0) ? 0 : actions.size() - 1;
		ProcessBuilderAction pba = new ProcessBuilderAction(recordCreate.name, recordCreate.label, Constants.FLOW.PB_ACTION_TYPE_FLOW_RECORD_CREATE);
		Set<String> decisionNames = getMainDecisionNames(sfdcFlow);
		pba.evaluateNextCriteria = (recordCreate.connector != null && recordCreate.connector.targetReference != null && decisionNames.contains(recordCreate.connector.targetReference));
		pba.setIcon(Constants.FLOW.PB_ICON_RECORD_CREATE);
		actions.get(index).add(pba);
		SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
			.addText(recordCreate.label);
		pba.sections.add(actionNameSection);

		SideBarSection apexClassSection = new SideBarSection(Constants.FLOW.PB_LABEL_RECORD_TYPE, SideBarItemType.TEXT)
			.addText(recordCreate.object_x);
		pba.sections.add(apexClassSection);

		if(recordCreate.inputAssignments != null && !recordCreate.inputAssignments.isEmpty()) {
			SideBarSection fieldValuesSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_FIELD_VALUES, SideBarItemType.TABLE)
				.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});
			for(MetadataService.FlowInputFieldAssignment ip : recordCreate.inputAssignments) {
				String fieldLabel = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, ip?.processMetadataValues));
				String fieldType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, ip?.processMetadataValues));
				String fieldTypeLabel = Constants.FLOW.FILTER_TYPE_MAP.get(fieldType);

				String rowValue = Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_NULL;
				if(ip?.value != null) {
					rowValue = String.valueOf(getFlowElementReferenceOrValue(ip.value));
					rowValue = (fieldType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA) ? getFlowFormulaValue(rowValue, sfdcFlow) : rowValue;
					rowValue = (String.isBlank(rowValue)) ? Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_EMPTY_STRING : rowValue;
				}

				fieldValuesSection.addTableRows(new List<SideBarTableRow>{
					new SideBarTableRow(fieldLabel),
					new SideBarTableRow(fieldTypeLabel),
					new SideBarTableRow(rowValue, (fieldType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA))
				});
			}
			pba.sections.add(fieldValuesSection);
		}
	}

	public static void addRecordUpdateSections(MetadataService.FlowRecordUpdate recordUpdate, List<List<ProcessBuilderAction>> actions, MetadataService.Flow sfdcFlow) {
		Integer index = (actions.size() == 0) ? 0 : actions.size() - 1;
		ProcessBuilderAction pba = new ProcessBuilderAction(recordUpdate.name, recordUpdate.label, Constants.FLOW.PB_ACTION_TYPE_FLOW_RECORD_UPDATE);
		Set<String> decisionNames = getMainDecisionNames(sfdcFlow);
		pba.evaluateNextCriteria = (recordUpdate.connector != null && recordUpdate.connector.targetReference != null && decisionNames.contains(recordUpdate.connector.targetReference));
		pba.setIcon(Constants.FLOW.PB_ICON_RECORD_UPDATE);
		actions.get(index).add(pba);
		SideBarSection actionNameSection = new SideBarSection(Constants.FLOW.PB_LABEL_ACTION_NAME, SideBarItemType.TEXT)
			.addText(recordUpdate.label);
		pba.sections.add(actionNameSection);

		SideBarSection recordSection = new SideBarSection(Constants.FLOW.PB_LABEL_RECORD, SideBarItemType.TEXT)
			.addText(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_REFERENCE, recordUpdate.processMetadataValues)));
		pba.sections.add(recordSection);

		if(recordUpdate.filters != null && !recordUpdate.filters.isEmpty()) {
			Boolean hasFilters = false;
			Integer indexCounter = 1;

			SideBarSection filterFiledSection = new SideBarSection(Constants.FLOW.PB_LABEL_FILTER_RECORDS, SideBarItemType.TABLE)
				.addTableHeaders(new List<String>{null, Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_OPERATOR, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});

			for(MetadataService.FlowRecordFilter frf : recordUpdate.filters) {
				Boolean implicit = Boolean.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_IMPLICIT, frf?.processMetadataValues));
				if(!implicit) {
					hasFilters = true;

					String fieldLabel = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, frf?.processMetadataValues));
					String fieldType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, frf?.processMetadataValues));
					String fieldTypeLabel = Constants.FLOW.FILTER_TYPE_MAP.get(fieldType);

					String fieldValue = Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_NULL;
					if(frf?.value != null) {
						String sValue = getFlowElementReferenceOrValue(frf.value) != null ? String.valueOf(getFlowElementReferenceOrValue(frf.value)) : null;
						fieldValue = String.isNotBlank(sValue) ? sValue : Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_EMPTY_STRING;
					}

					filterFiledSection.addTableRows(new List<SideBarTableRow>{
						new SideBarTableRow(String.valueOf(indexCounter++)),
						new SideBarTableRow(fieldLabel),
						new SideBarTableRow(Constants.FLOW.OPERATORS_MAP.get(frf?.operator)),
						new SideBarTableRow(fieldTypeLabel),
						new SideBarTableRow(fieldValue)
					});
				}
			}

			SideBarSection criteriaUpdatingSection = new SideBarSection(Constants.FLOW.PB_LABEL_CRITERIA_UPDATING, SideBarItemType.RADIOBUTTON)
				.addRadioButton(hasFilters, Constants.FLOW.PB_LABEL_CRITERIA_UPDATING_ALL_CONDITIONS)
				.addRadioButton(!hasFilters, Constants.FLOW.PB_LABEL_CRITERIA_UPDATING_NO_CONDITIONS);
			pba.sections.add(criteriaUpdatingSection);

			if(hasFilters) {
				pba.sections.add(filterFiledSection);
			}
		}

		if(recordUpdate.inputAssignments != null && !recordUpdate.inputAssignments.isEmpty()) {
			SideBarSection fieldValuesSection = new SideBarSection(Constants.FLOW.PB_LABEL_SET_NEW_FIELD_VALUES, SideBarItemType.TABLE)
				.addTableHeaders(new List<String>{Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});
			for(MetadataService.FlowInputFieldAssignment ip : recordUpdate.inputAssignments) {
				String fieldLabel = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, ip?.processMetadataValues));
				String fieldType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, ip?.processMetadataValues));
				String fieldTypeLabel = Constants.FLOW.FILTER_TYPE_MAP.get(fieldType);

				String rowValue = Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_NULL;
				if(ip?.value != null) {
					rowValue = String.valueOf(getFlowElementReferenceOrValue(ip.value));
					rowValue = (fieldType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA) ? getFlowFormulaValue(rowValue, sfdcFlow) : rowValue;
					rowValue = (String.isBlank(rowValue)) ? Constants.FLOW.PB_LABEL_GLOBAL_CONSTANT_EMPTY_STRING : rowValue;
				}
				String rowValueLabel = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_LABEL, ip?.processMetadataValues));
				if(String.isNotBlank(rowValueLabel)) {
					pba.context.put(rowValueLabel, rowValue);
				}
				rowValue = (String.isNotBlank(rowValueLabel)) ? rowValueLabel : rowValue;

				fieldValuesSection.addTableRows(new List<SideBarTableRow>{
					new SideBarTableRow(fieldLabel),
					new SideBarTableRow(fieldTypeLabel),
					new SideBarTableRow(rowValue, (fieldType == Constants.FLOW.PB_META_KEY_VALUE_FORMULA))
				});
			}
			pba.sections.add(fieldValuesSection);
		}
	}

	public static MetadataService.FlowWaitEventInputParameter getInputParameterByName(String name, List<MetadataService.FlowWaitEventInputParameter> parameters) {
		for(MetadataService.FlowWaitEventInputParameter ip : parameters) {
			if(ip?.name == name) {
				return ip;
			}
		}
		return null;
	}

	public static MetadataService.FlowActionCallInputParameter getInputParameterByName(String name, List<MetadataService.FlowActionCallInputParameter> parameters) {
		for(MetadataService.FlowActionCallInputParameter ip : parameters) {
			if(ip?.name == name) {
				return ip;
			}
		}
		return null;
	}

	public static MetadataService.FlowVariable getFlowVariable(String name, MetadataService.Flow sfdcFlow) {
		MetadataService.FlowVariable result;
		if(sfdcFlow.variables != null) {
			for(MetadataService.FlowVariable fVariable : sfdcFlow.variables) {
				if(fVariable?.name == name) {
					result = fVariable;
					break;
				}
			}
		}
		return result;
	}

	public static String getFlowAssigmentItemValue(String name, MetadataService.Flow sfdcFlow) {
		String result;
		if(sfdcFlow.assignments != null) {
			for(MetadataService.FlowAssignment assignment : sfdcFlow.assignments) {
				if(assignment?.assignmentItems != null) {
					for(MetadataService.FlowAssignmentItem assignmentItem : assignment.assignmentItems) {
						if(assignmentItem?.assignToReference == name) {
							result = String.valueOf(getFlowElementReferenceOrValue(assignment.assignmentItems.get(0)?.value));
							break;
						}
					}
				}
			}
		}
		return result;
	}

	public static MetadataService.FlowRecordLookup getRecordLookupByName(String recordLookupName, List<MetadataService.FlowRecordLookup> recordLookups) {
		MetadataService.FlowRecordLookup result;

		if(recordLookups != null) {
			for(MetadataService.FlowRecordLookup rl : recordLookups) {
				if(rl?.name == recordLookupName) {
					result = rl;
					break;
				}
			}
		}
		return result;
	}

	public static MetadataService.FlowDecision getDecisionByName(String decisionName, List<MetadataService.FlowDecision> decisions) {
		MetadataService.FlowDecision result;

		if(decisions != null) {
			for(MetadataService.FlowDecision fd : decisions) {
				if(fd?.name == decisionName) {
					result = fd;
					break;
				}
			}
		}
		return result;
	}

	public static List<String> getFirstActionNameFromDecision(MetadataService.FlowDecision flowDecision) {
		List<String> result = new List<String>();

		if(flowDecision.rules != null) {
			for(MetadataService.FlowRule flowRule : flowDecision.rules) {
				if(flowRule != null && flowRule.connector != null && flowRule.connector.targetReference != null) {
					result.add(flowRule.connector.targetReference);
				}
			}
		}
		if(result.isEmpty()) {
			if(flowDecision.defaultConnector != null && flowDecision.defaultConnector.targetReference != null) {
				result.add(flowDecision.defaultConnector.targetReference);
			}
		}
		return result;
	}

	public static String getNextDecisionName(MetadataService.FlowDecision flowDecision) {
		String result;
		if(flowDecision.defaultConnector != null && flowDecision.defaultConnector.targetReference != null) {
			result = flowDecision.defaultConnector.targetReference;
		}
		return result;
	}

	public static String getFlowFormulaValue(String flowFormulaName, MetadataService.Flow sfdcFlow) {
		String result;
		if(sfdcFlow.formulas != null) {
			for(MetadataService.FlowFormula ff : sfdcFlow.formulas) {
				if(ff?.name == flowFormulaName) {
					result = String.valueOf(getProcessMetadataValue('originalFormula', ff?.processMetadataValues));
					break;
				}
			}
		}
		return result;
	}

	public static String getFlowFormulaExpression(String flowFormulaName, MetadataService.Flow sfdcFlow) {
		String result;
		if(sfdcFlow.formulas != null) {
			for(MetadataService.FlowFormula ff : sfdcFlow.formulas) {
				if(ff?.name == flowFormulaName) {
					result = ff?.expression;
					break;
				}
			}
		}
		return result;
	}

	public static Object getProcessMetadataValue(String key, MetadataService.FlowMetadataValue[] processMetadataValues) {
		Object result;
		if(processMetadataValues != null) {
			for(MetadataService.FlowMetadataValue flowValue : processMetadataValues) {
				if(flowValue?.name == key) {
					result = getFlowElementReferenceOrValue(flowValue?.value);
					break;
				}
			}
		}
		return result;
	}

	public static Object getFlowElementReferenceOrValue(MetadataService.FlowElementReferenceOrValue value) {
		Object result;
		if(value == null) return null;
		if(value.booleanValue != null) {
			return value.booleanValue;
		}
		else if(value.dateTimeValue != null) {
			return value.dateTimeValue;
		}
		else if(value.dateValue != null) {
			return value.dateValue;
		}
		else if(value.elementReference != null) {
			return value.elementReference;
		}
		else if(value.numberValue != null) {
			return value.numberValue;
		}
		else if(value.stringValue != null) {
			return value.stringValue;
		}
		else if(value.transformValueReference != null) {
			return value.transformValueReference;
		}
		return result;
	}

	public static MetadataService.FlowDecision getFirstFlowDecision(MetadataService.Flow sfdcFlow) {
		if(sfdcFlow.decisions != null) {
			for(MetadataService.FlowDecision flowDecision : sfdcFlow.decisions) {
				String index = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_INDEX, flowDecision?.processMetadataValues));
				if(Constants.FLOW.PB_META_KEY_VALUE_FIRST_DECISION_INDEX == index) {
					return flowDecision;
				}
			}
		}
		return null;
	}

	public static String getLineValue(List<String> lines, String paramName) {
		return getLineValue(lines, paramName, ':');
	}

	private static String getLineValue(List<String> lines, String paramName, String separator) {
		for(String line : lines) {
			if(String.isNotBlank(line)) {
				if(line.containsIgnoreCase(paramName)) {
					List<String> paramValuePar = line.split(separator);
					if(paramValuePar.size() == 2) {
						String value = paramValuePar.get(1).trim();
						return value;
					}
				}
			}
		}
		return null;
	}

	public Enum SideBarItemType {
		TEXT,
		CHECKBOX,
		RADIOBUTTON,
		TABLE,
		INDEX,
		TEXTAREA,
		TABLETIME
	}

	public class SideBarSection {
		public String label;
		public Object value;
		public SideBarItemType itemType;
		public List<String> headers;
		public List<List<SideBarTableRow>> rows;
		public List<SideBarSimpleRow> items;

		public SideBarSection(String label, SideBarItemType itemType) {
			this.label = label;
			this.itemType = itemType;
		}

		public SideBarSection addText(Object value) {
			this.value = value;
			return this;
		}

		public SideBarSection addCheckBox(Object value, String label) {
			if(this.items == null) {
				this.items = new List<SideBarSimpleRow>();
			}
			this.items.add(new SideBarSimpleRow(value, label));
			return this;
		}

		public SideBarSection addRadioButton(Object value, String label) {
			if(this.items == null) {
				this.items = new List<SideBarSimpleRow>();
			}
			this.items.add(new SideBarSimpleRow(value, label));
			return this;
		}

		public SideBarSection addTableHeaders(List<String> headers) {
			this.headers = headers;
			return this;
		}

		public SideBarSection addTableRows(List<SideBarTableRow> rows) {
			if(this.rows == null) {
				this.rows = new List<List<SideBarTableRow>>();
			}
			this.rows.add(rows);
			return this;
		}
	}

	public class SideBarTableRow {
		public Object v;
		public Boolean f;

		public SideBarTableRow(Object value) {
			this.v = value;
			this.f = false;
		}
		public SideBarTableRow(Object value, Boolean isFunction) {
			this.v = value;
			this.f = isFunction;
		}
	}

	public class SideBarSimpleRow {
		public Object v;
		public String l;

		public SideBarSimpleRow(Object value, String label) {
			this.v = value;
			this.l = label;
		}
	}

	public class ProcessBuilderHelper {
		public List<String> userIds;
		public List<String> groupIds;
		public Map<String, String> mapUsers;
		public Map<String, String> mapGroups;
		public Set<String> actionNames;

		public ProcessBuilderHelper() {
			this.userIds = new List<String>();
			this.groupIds = new List<String>();
			this.mapUsers = new Map<String, String>();
			this.mapGroups = new Map<String, String>();
			this.actionNames = new Set<String>();
		}

		public void replaceIdsByNames(ProcessBuilder result) {
			if(!this.actionNames.isEmpty()) {
				if(!this.userIds.isEmpty()) {
					this.mapUsers = getUserMaps(this.userIds);
				}
				if(!this.groupIds.isEmpty()) {
					this.mapGroups = getGroupMaps(this.groupIds);
				}
			}
			for(ProcessBuilderDecision decision : result.decisions) {
				for(List<ProcessBuilderAction> actions : decision.actions) {
					for(ProcessBuilderAction action : actions) {
						if(this.actionNames.contains(action.name)) {
							for(SideBarSection sideBarSection : action.sections) {
								if(sideBarSection.itemType == SideBarItemType.TABLE) {
									for(List<SideBarTableRow> row : sideBarSection.rows) {
										SideBarTableRow lastCellInRow = row.get(row.size() - 1);
										String idValue = String.valueOf(lastCellInRow.v);
										if(this.userIds.contains(idValue)) {
											String name = this.mapUsers.get(idValue);
											if(String.isNotBlank(name)) {
												row.get(row.size() - 1).v = name;
											}
										}
										if(this.groupIds.contains(idValue)) {
											String name = this.mapGroups.get(idValue);
											if(String.isNotBlank(name)) {
												row.get(row.size() - 1).v = name;
											}
										}
									}
								}
							}
						}
					}
				}
			}

		}
	}

	public class ProcessBuilder {
		public String name;
		public String label;
		public String processType;
		public ProcessBuilderStart start;
		public List<ProcessBuilderDecision> decisions;
		public Map<String, Object> context;
		public List<StackTraceParser.StackTraceParseResult> apexStackTraceParseResults;
		public String errorMessage;
		public String errorMessageHtml;

		public ProcessBuilder(){
			this.start = new ProcessBuilderStart();
			this.decisions = new List<ProcessBuilderDecision>();
			this.context = new Map<String, Object>();
			this.apexStackTraceParseResults = new List<StackTraceParser.StackTraceParseResult>();
		}
	}

	public class ProcessBuilderDecision implements Comparable {
		public String name;
		public String label;
		public String index;
		public Boolean executed;
		public List<List<ProcessBuilderAction>> actions;
		public Map<String, Object> context;

		public List<SideBarSection> sections;

		public ProcessBuilderDecision() {
			this.executed = false;
			this.actions = new List<List<ProcessBuilderAction>>();
			this.actions.add(new List<ProcessBuilderAction>());
			this.context = new Map<String, Object>();

			this.sections = new List<SideBarSection>();
		}

		public Integer compareTo(Object compareTo) {
			ProcessBuilderDecision mf = (ProcessBuilderDecision)compareTo;
			if (Integer.valueOf(this.index) == Integer.valueOf(mf.index)) return 0;
			if (Integer.valueOf(this.index) > Integer.valueOf(mf.index)) return 1;
			return -1;
		}
	}

	public class ProcessBuilderAction {
		public String name;
		public String label;
		public String actionType;
		public Boolean executed;
		public Boolean evaluateNextCriteria;
		public Map<String, Object> context;
		public String icon;

		public List<SideBarSection> sections;

		public ProcessBuilderAction(String name, String label, String actionType) {
			this.name = name;
			this.label = label;
			this.actionType = actionType;
			this.executed = false;
			this.context = new Map<String, Object>();

			this.sections = new List<SideBarSection>();
			this.evaluateNextCriteria = false;
		}

		public void setIcon(String icon) {
			this.icon = icon;
		}

	}

	public class ProcessBuilderStart {
		public String startType;
		public String objectType;
		public String objectVariable;
		public String oldObjectVariable;
		public String triggerType;
		public String eventType;

		public List<SideBarSection> sections;

		public ProcessBuilderStart(){}

		public ProcessBuilderStart(String startType, MetadataService.Flow sfdcFlow) {

			this.startType = startType;
			this.objectType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_OBJECT_TYPE, sfdcFlow.processMetadataValues));
			this.objectVariable = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_OBJECT_VARIABLE, sfdcFlow.processMetadataValues));
			this.oldObjectVariable = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_OLD_OBJECT_VARIABLE, sfdcFlow.processMetadataValues));
			this.triggerType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_TRIGGER_TYPE, sfdcFlow.processMetadataValues));
			this.eventType = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_KEY_EVENT_TYPE, sfdcFlow.processMetadataValues));

			this.sections = new List<SideBarSection>();
			// started from PlatformEvent
			if(String.isNotBlank(this.eventType) && this.eventType != 'null') {
				SideBarSection eventSection = new SideBarSection(Constants.FLOW.PB_LABEL_PLATFORM_EVENT, SideBarItemType.TEXT)
					.addText(this.eventType);

				SideBarSection objectSection = new SideBarSection(Constants.FLOW.PB_LABEL_OBJECT, SideBarItemType.TEXT)
					.addText(this.objectType);

				this.sections.add(eventSection);
				this.sections.add(objectSection);

				String startRefferenceName = sfdcFlow.startElementReference;
				if(String.isNotBlank(startRefferenceName)) {
					MetadataService.FlowRecordLookup recordLookup = getRecordLookupByName(startRefferenceName, sfdcFlow.recordLookups);
					if(recordLookup != null) {
						SideBarSection conditionsSection = new SideBarSection(Constants.FLOW.PB_LABEL_MATCHING_CONDITIONS, SideBarItemType.TABLE);
						Integer indexCounter = 1;
						conditionsSection.addTableHeaders(new List<String>{null, Constants.FLOW.PB_TABLE_LABEL_FIELD, Constants.FLOW.PB_TABLE_LABEL_OPERATOR, Constants.FLOW.PB_TABLE_LABEL_TYPE, Constants.FLOW.PB_TABLE_LABEL_VALUE});

						if(recordLookup.filters != null) {
							for(MetadataService.FlowRecordFilter frf : recordLookup.filters) {
								List<SideBarTableRow> rowObjects = new List<SideBarTableRow>();
								rowObjects.add(new SideBarTableRow(String.valueOf(indexCounter++)));
								rowObjects.add(new SideBarTableRow(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_LEFT_HAND_SIDE_LABEL, frf?.processMetadataValues))));
								rowObjects.add(new SideBarTableRow(Constants.FLOW.OPERATORS_MAP.get(frf?.operator)));
								rowObjects.add(new SideBarTableRow(String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RIGHT_HAND_SIDE_TYPE, frf?.processMetadataValues))));
								rowObjects.add(new SideBarTableRow(getFlowElementReferenceOrValue(frf?.value)));
								conditionsSection.addTableRows(rowObjects);
							}
						}
						this.sections.add(conditionsSection);
					}
				}
			}
			// started from Record change
			else {
				SideBarSection objectSection = new SideBarSection(Constants.FLOW.PB_LABEL_OBJECT, SideBarItemType.TEXT)
					.addText(this.objectType);

				SideBarSection howStartSection = new SideBarSection(Constants.FLOW.PB_LABEL_START_THE_PROCESS, SideBarItemType.RADIOBUTTON)
					.addRadioButton(this.triggerType == Constants.FLOW.PK_KEY_TRIGGER_TYPE_INSERT, Constants.FLOW.PB_LABEL_TRIGGER_TYPE_INSERT)
					.addRadioButton(this.triggerType == Constants.FLOW.PK_KEY_TRIGGER_TYPE_UPDATE, Constants.FLOW.PB_LABEL_TRIGGER_TYPE_UPDATE);

				String recursionValue = String.valueOf(getProcessMetadataValue(Constants.FLOW.PB_META_KEY_RECURSIVE_COUNT_VARIABLE, sfdcFlow.processMetadataValues));
				SideBarSection recursionSection = new SideBarSection(Constants.FLOW.PB_LABEL_RECURSION_RPOCESS, SideBarItemType.CHECKBOX)
					.addCheckBox(recursionValue != 'null', Constants.FLOW.PB_LABEL_YES);

				this.sections.add(objectSection);
				this.sections.add(howStartSection);
				this.sections.add(recursionSection);

			}
		}
	}

	public static Map<String, String> getUserMaps(List<String> userIds) {
		return getUserOrGroupMaps('User', userIds);
	}

	public static Map<String, String> getGroupMaps(List<String> groupIds) {
		return getUserOrGroupMaps('CollaborationGroup', groupIds);
	}

	public static Map<String, String> getUserOrGroupMaps(String objectName, List<String> recordIds) {
		Map<String, String> result = new Map<String, String>();
		String query = new QBuilder(objectName)
			.selectFields(new Set<String>{'Id', 'Name'})
			.add(QBuilder.condition('Id').isIn(recordIds))
			.buildToolingQuery();
		String b = HttpUtils.get(
			StackTraceParser.corg.Instance_Url__c + ConfigUtil.QUERY_REST_API_PATH + query,
			StackTraceParser.getHeaders(),
				200
		);

		Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(b);
		List<Object> recordList = (List<Object>)results.get('records');
		for(Object recordItem : recordList) {
			Map<String, Object> mapRecord = (Map<String, Object>)recordItem;
			String name = (String)mapRecord.get('Name');
			String id = (String)mapRecord.get('Id');
			result.put(id, name);
		}

		return result;
	}

	public static Boolean isHtmlStacktrace(String htmlStacktrace) {
		return (String.isNotBlank(htmlStackTrace) && htmlStacktrace?.startsWithIgnoreCase('<'));
	}

	// First, define the FlowInstance class
	public class FlowInstance implements Comparable {
		public Integer startIndex;
		public Integer endIndex;
		public String parentFlowKey;
		public List<String> childFlowKeys = new List<String>();
		public List<List<Integer>> indexes = new List<List<Integer>>();
		
		public FlowInstance(Integer startIndex) {
			this.startIndex = startIndex;
		}
		
		// Implement the Comparable interface
		public Integer compareTo(Object compareTo) {
			FlowInstance other = (FlowInstance)compareTo;
			if (this.startIndex > other.startIndex) {
				return 1;
			} else if (this.startIndex < other.startIndex) {
				return -1;
			} else {
				return 0;
			}
		}
	}

	/**
     * @description Main method to parse a Flow stacktrace from HTML
     * @param htmlStackTrace HTML string containing the Flow stacktrace
     * @return Flow Parsed Flow object with complete execution information
     */
	public static FlowDataStructures.Flow parseFlowStackTrace(String htmlStackTrace) {
		FlowDataStructures.Flow result = null;
		
		List<FlowDataStructures.Flow> subflows = new List<FlowDataStructures.Flow>();
		if(!isHtmlStacktrace(htmlStackTrace)) return result;
	
		FlowService.FlowStacktraceParser sp = new FlowService.FlowStacktraceParser(htmlStackTrace);
		FlowDataStructures.FlowStacktraceInfo stackTraceInfo = sp.parse();
		
		// Initialize flow instances map
		Map<String, List<FlowInstance>> flowInstances = new Map<String, List<FlowInstance>>();
		for (String flowKey : stackTraceInfo.flowApiNamePool) {
			flowInstances.put(flowKey, new List<FlowInstance>());
		}
		
		// Get all flow API names from the stacktrace
		List<String> allFlowApiNamesList = new List<String>(stackTraceInfo.flowApiNamePool);
		
		// Get flows first to check elements
		List<FlowDataStructures.Flow> flows = getSfdcFlows(allFlowApiNamesList, Constants.FLOW.FLOW_CURRENT_SUPPORTED_API_VERSION);
		Map<String, FlowDataStructures.Flow> flowsByKey = new Map<String, FlowDataStructures.Flow>();
		for(FlowDataStructures.Flow flow : flows) {
			flowsByKey.put(flow.name, flow);
		}
		
		String mainFlowKey = new List<String>(stackTraceInfo.flowApiNamePool)[0];
		
		// Track all subflow enter/exit pairs
		Map<String, List<List<Integer>>> subflowPairs = new Map<String, List<List<Integer>>>();
		List<String> activeFlowStack = new List<String>();
		
		// First pass: identify all subflow enter/exit pairs
		for (Integer i = 0; i < stackTraceInfo.stacktraceElements.size(); i++) {
			FlowDataStructures.FlowStacktraceElement element = stackTraceInfo.stacktraceElements[i];
			
			if (element.apiType == 'FlowSubflow') {
				Boolean isEnterFlow = (Boolean)element.context.get(Constants.FLOW.PB_ST_CONTEXT_ENTER_FLOW);
				String flowApiName = (String)element.context.get(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_NAME);
				String flowVersion = (String)element.context.get(Constants.FLOW.PB_ST_CONTEXT_FLOW_API_VERSION);
				String subflowKey = flowApiName + '-' + flowVersion;
				
				if (isEnterFlow) {
					// Add to active stack
					activeFlowStack.add(subflowKey + ':' + i);
				} else {
					// Find matching enter position
					Integer enterPos = -1;
					String stackEntry = null;
					
					// Find the most recent entry for this subflow
					for (Integer j = activeFlowStack.size() - 1; j >= 0; j--) {
						if (activeFlowStack[j].startsWith(subflowKey + ':')) {
							stackEntry = activeFlowStack[j];
							enterPos = Integer.valueOf(stackEntry.substring(stackEntry.indexOf(':') + 1));
							activeFlowStack.remove(j);
							break;
						}
					}
					
					if (enterPos != -1) {
						// Record the pair
						if (!subflowPairs.containsKey(subflowKey)) {
							subflowPairs.put(subflowKey, new List<List<Integer>>());
						}
						subflowPairs.get(subflowKey).add(new List<Integer>{enterPos, i});
					}
				}
			}
		}
		
		// Create main flow instance
		FlowInstance mainInstance = new FlowInstance(0);
		mainInstance.parentFlowKey = null;
		// Set the end index to the last element in the stacktrace
		mainInstance.endIndex = stackTraceInfo.stacktraceElements.size() - 1;
		flowInstances.get(mainFlowKey).add(mainInstance);
		
		// Create instances for each subflow based on enter/exit pairs
		for (String flowKey : subflowPairs.keySet()) {
			for (List<Integer> pair : subflowPairs.get(flowKey)) {
				FlowInstance instance = new FlowInstance(pair[0]);
				instance.endIndex = pair[1];
				flowInstances.get(flowKey).add(instance);
			}
		}
		
		// Handle any remaining flows in the active stack (flows that were entered but never exited)
		for (String stackEntry : activeFlowStack) {
			String[] parts = stackEntry.split(':');
			String flowKey = parts[0];
			Integer startIndex = Integer.valueOf(parts[1]);
			
			// Create an instance for this flow
			FlowInstance instance = new FlowInstance(startIndex);
			
			// For flows that were entered but never exited, set end index to the last element
			// or to the last element before any child flow starts
			Integer endIndex = stackTraceInfo.stacktraceElements.size() - 1;
			
			// Add to flow instances
			instance.endIndex = endIndex;
			flowInstances.get(flowKey).add(instance);
		}
		
		// Build the flow hierarchy
		// First, identify which flows are called by which other flows
		Map<String, Set<String>> flowCalls = new Map<String, Set<String>>();
		Map<String, String> flowCallers = new Map<String, String>(); // Track which flow calls each flow
		
		for (Integer i = 0; i < stackTraceInfo.stacktraceElements.size(); i++) {
			FlowDataStructures.FlowStacktraceElement element = stackTraceInfo.stacktraceElements[i];
			
			if (element.apiType == 'FlowSubflow' && (Boolean)element.context.get('enterFlow')) {
				String calledFlowKey = (String)element.context.get('flowApiName') + '-' + (String)element.context.get('apiVersion');
								
				// Find which flow is making this call
				String callerFlowKey = null;
				FlowInstance callerInstance = null;
				
				// First check if we're in a subflow
				for (String flowKey : flowInstances.keySet()) {
					if (flowKey == calledFlowKey) continue; // Skip the flow we're checking
					
					for (FlowInstance instance : flowInstances.get(flowKey)) {
						
						if (i >= instance.startIndex && (instance.endIndex == -1 || i <= instance.endIndex)) {
							// This is the most immediate caller
							if (callerFlowKey == null || 
								(callerInstance != null && instance.startIndex > callerInstance.startIndex)) {
								callerFlowKey = flowKey;
								callerInstance = instance;
							}
						}
					}
				}
				
				// If no caller found, use the main flow
				if (callerFlowKey == null) {
					callerFlowKey = mainFlowKey;
				}
				
				// Record the call
				if (!flowCalls.containsKey(callerFlowKey)) {
					flowCalls.put(callerFlowKey, new Set<String>());
				}
				flowCalls.get(callerFlowKey).add(calledFlowKey);
				
				// Record the caller for this flow
				flowCallers.put(calledFlowKey, callerFlowKey);
			}
		}
				
		// Now set parent-child relationships for each instance
		for (String flowKey : flowInstances.keySet()) {
			for (FlowInstance instance : flowInstances.get(flowKey)) {
				// Set parent flow key
				instance.parentFlowKey = flowCallers.get(flowKey);
				
				// Initialize child flow keys
				instance.childFlowKeys = new List<String>();
			}
		}
		
		// Set child flow keys
		for (String callerFlowKey : flowCalls.keySet()) {
			for (String calledFlowKey : flowCalls.get(callerFlowKey)) {
				// Find the instances where this call happens
				for (FlowInstance callerInstance : flowInstances.get(callerFlowKey)) {
					for (FlowInstance calledInstance : flowInstances.get(calledFlowKey)) {
												
						// Check if the called instance is within the caller instance's range
						if (calledInstance.startIndex >= callerInstance.startIndex && 
							calledInstance.endIndex <= callerInstance.endIndex) {
							
							// This caller instance calls this called instance
							if (!callerInstance.childFlowKeys.contains(calledFlowKey)) {
								callerInstance.childFlowKeys.add(calledFlowKey);
							}
							
							// Set the parent flow key for the called instance
							calledInstance.parentFlowKey = callerFlowKey;
							
							// Also check if this called flow has its own child flows
							// This is the key part we're adding to fix the issue
							if (flowCalls.containsKey(calledFlowKey)) {
								for (String nestedCalledFlowKey : flowCalls.get(calledFlowKey)) {
									for (FlowInstance nestedCalledInstance : flowInstances.get(nestedCalledFlowKey)) {
										// Check if the nested called instance is within this called instance's range
										if (nestedCalledInstance.startIndex >= calledInstance.startIndex && 
											nestedCalledInstance.endIndex <= calledInstance.endIndex) {
											
											// This called instance calls this nested called instance
											if (!calledInstance.childFlowKeys.contains(nestedCalledFlowKey)) {
												calledInstance.childFlowKeys.add(nestedCalledFlowKey);
											}
											
											// Update the parent flow key for the nested called instance
											nestedCalledInstance.parentFlowKey = calledFlowKey;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		// Determine the index ranges for each flow instance
		for (String flowKey : flowInstances.keySet()) {
			for (FlowInstance instance : flowInstances.get(flowKey)) {
				// Initialize indexes list
				instance.indexes = new List<List<Integer>>();
				
				// Get all child flow instances
				List<FlowInstance> childInstances = new List<FlowInstance>();
				for (String childFlowKey : instance.childFlowKeys) {
					for (FlowInstance childInstance : flowInstances.get(childFlowKey)) {
						if (childInstance.startIndex >= instance.startIndex && 
							childInstance.endIndex <= instance.endIndex) {
							childInstances.add(childInstance);
						}
					}
				}
				
				// Sort child instances by start index
				childInstances.sort();
				
				// Calculate index ranges for this instance
				Integer currentStart = instance.startIndex;
				
				// If there are no child instances, the range is simple
				if (childInstances.isEmpty()) {
					instance.indexes.add(new List<Integer>{currentStart, instance.endIndex});
				}
				else {
					// Handle ranges between child instances
					for (FlowInstance childInstance : childInstances) {
						// Add range before this child instance
						if (currentStart < childInstance.startIndex) {
							instance.indexes.add(new List<Integer>{currentStart, childInstance.startIndex});
						}
						
						// Update current start to after this child instance
						currentStart = childInstance.endIndex;
					}
					
					// Add final range after all child instances
					if (currentStart <= instance.endIndex) {
						instance.indexes.add(new List<Integer>{currentStart, instance.endIndex});
					}
				}
			}
		}
		
		// Process the flows in order
		List<Map<String, Object>> allRanges = new List<Map<String, Object>>();
		Integer globalIndex = 1;
		
		// Collect all ranges with their associated flow information
		for (String flowKey : flowInstances.keySet()) {
			List<FlowInstance> instances = flowInstances.get(flowKey);
			if (instances.isEmpty() || flowsByKey.get(flowKey) == null) continue;
			
			Integer instanceIndex = 0;
			for (FlowInstance instance : flowInstances.get(flowKey)) {
				Integer finalIndex = -1;					

				for (List<Integer> indexRange : instance.indexes) {
					Map<String, Object> rangeInfo = new Map<String, Object>{
						'flowKey' => flowKey,
						'instance' => instance,
						'instanceIndex' => instanceIndex,
						'range' => indexRange,
						'startIndex' => indexRange[0],
						'finalIndex' => finalIndex
					};
					allRanges.add(rangeInfo);                        
				}
				instanceIndex++;
			}
		}

		// Sort ranges by start index
		sortRangesByStartIndex(allRanges);

		// Keep track of processed flow instances
		Map<String, FlowDataStructures.Flow> processedFlows = new Map<String, FlowDataStructures.Flow>();

		// Process flows in order of their index ranges
		for (Map<String, Object> rangeInfo : allRanges) {
			String flowKey = (String)rangeInfo.get('flowKey');
			FlowInstance instance = (FlowInstance)rangeInfo.get('instance');
			Integer instanceIndex = (Integer)rangeInfo.get('instanceIndex');

			List<Integer> range = (List<Integer>)rangeInfo.get('range');
			Integer finalIndex = (Integer)rangeInfo.get('finalIndex');
			// Create a unique key for this flow instance
			String flowInstanceKey = flowKey + '-' + instanceIndex;
			
			FlowDataStructures.Flow sfdcFlow;
			
			if (flowKey == mainFlowKey) {
				// For main flow, always use the same instance
				if (!processedFlows.containsKey(flowInstanceKey)) {
					sfdcFlow = flowsByKey.get(flowKey);
					processedFlows.put(flowInstanceKey, sfdcFlow);
					result = sfdcFlow;
				}
				else {
					sfdcFlow = processedFlows.get(flowInstanceKey);
				}
				
				FlowDataStructures.FlowStackTraceProcessor processor = new FlowDataStructures.FlowStackTraceProcessor(
					sfdcFlow, 
					stackTraceInfo,
					new List<List<Integer>>{range},
					globalIndex
				);
				
				processor.processFlow(finalIndex);
				globalIndex = processor.getGlobalIndex();
				
				updateFlowContext(sfdcFlow, stackTraceInfo);
			}
			else {
				// For subflows, check if we've already processed this instance
				if (!processedFlows.containsKey(flowInstanceKey)) {
					// First time seeing this instance, create a new flow
					sfdcFlow = flowsByKey.get(flowKey).deepClone();
					sfdcFlow.context.put('instanceIndex', instanceIndex);
					processedFlows.put(flowInstanceKey, sfdcFlow);
					subflows.add(sfdcFlow);
				}
				else {
					// We've seen this instance before, use the existing flow
					sfdcFlow = processedFlows.get(flowInstanceKey);
				}
				
				FlowDataStructures.FlowStackTraceProcessor processor = new FlowDataStructures.FlowStackTraceProcessor(
					sfdcFlow, 
					stackTraceInfo,
					new List<List<Integer>>{range},
					globalIndex
				);
				processor.processFlow(finalIndex);
				globalIndex = processor.getGlobalIndex();
			}
		}
		
		finalizeResult(result, subflows, stackTraceInfo);

		return result;
	}	

	private static void sortRangesByStartIndex(List<Map<String, Object>> ranges) {
		// Simple bubble sort by startIndex
		for (Integer i = 0; i < ranges.size(); i++) {
			for (Integer j = 0; j < ranges.size() - 1 - i; j++) {
				Integer start1 = (Integer)ranges[j].get('startIndex');
				Integer start2 = (Integer)ranges[j+1].get('startIndex');
				
				if (start1 > start2) {
					Map<String, Object> temp = ranges[j];
					ranges[j] = ranges[j+1];
					ranges[j+1] = temp;
				}
			}
		}
	}

	/**
     * @description Builds a map of Flow objects keyed by their API names
     * @param sfdcFlows List of Flow objects retrieved from Salesforce
     * @param flowApiNamesForRetrieve List of API names to map
     * @return Map<String, Flow> Map of Flow objects keyed by API name
     */
	public static Map<String, FlowDataStructures.Flow> buildFlowsMap(List<FlowDataStructures.Flow> sfdcFlows, List<String> flowApiNamesForRetrieve) {
        Map<String, FlowDataStructures.Flow> sfdcFlowsMap = new Map<String, FlowDataStructures.Flow>();
        for(FlowDataStructures.Flow sfdcFlow : sfdcFlows) {
			if(flowApiNamesForRetrieve.contains(sfdcFlow?.name)) {
                sfdcFlowsMap.put(sfdcFlow?.name, sfdcFlow);
            }
            else {
                for(String sfFlowName : flowApiNamesForRetrieve) {
                    String sfName = sfFlowName.split('-').get(0);
                    if(sfName?.startsWith(sfdcFlow?.name) || sfName?.endsWith(sfdcFlow?.name)) {
                        sfdcFlowsMap.put(sfName, sfdcFlow);
                        break;
                    }
                }
            }
        }
        return sfdcFlowsMap;
    }

	/**
     * @description Retrieves a Flow object from the map, handling hyphenated names
     * @param sfdcFlowsMap Map of Flow objects
     * @param sfdcFlowName API name to look up
     * @return Flow The retrieved Flow object or null if not found
     */
    public static FlowDataStructures.Flow getFlow(Map<String, FlowDataStructures.Flow> sfdcFlowsMap, String sfdcFlowName) {
        FlowDataStructures.Flow sfdcFlow = sfdcFlowsMap.get(sfdcFlowName);
        if(sfdcFlow == null && sfdcFlowName.contains('-')) {
            String sfName = sfdcFlowName.split('-').get(0);
            sfdcFlow = sfdcFlowsMap.get(sfName);
        }
        return sfdcFlow;
    }

    /**
     * @description Updates the context of a Flow with information from the stacktrace
     * @param sfdcFlow Flow object to update
     * @param stackTraceInfo Stacktrace information containing context details
     */
	public static void updateFlowContext(FlowDataStructures.Flow sfdcFlow, FlowDataStructures.FlowStacktraceInfo stackTraceInfo) {
        if(sfdcFlow?.name?.startsWith(stackTraceInfo?.flowDetails?.flowApiName)) {
            if(stackTraceInfo?.flowDetails != null) {
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_FLOW_API_NAME_NAME, stackTraceInfo?.flowDetails?.flowApiName);
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_TYPE_NAME, stackTraceInfo?.flowDetails?.type);
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_VERSION_NAME, stackTraceInfo?.flowDetails?.version);
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_STATUS_NAME, stackTraceInfo?.flowDetails?.status);
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_ORG_NAME, stackTraceInfo?.flowDetails?.orgName);
            }
            if(stackTraceInfo?.flowInterviewDetails != null) {
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_CURRENT_USER_NAME, stackTraceInfo?.flowInterviewDetails.currentUserName);
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_START_TIME_NAME, stackTraceInfo?.flowInterviewDetails.startTime);
            }
            if(stackTraceInfo?.howTheInterviewStarted != null) {
                sfdcFlow.context.put(Constants.FLOW.PB_ST_VAR_RUN_API_NAME, stackTraceInfo?.howTheInterviewStarted?.apiVersion);
            }
        }
    }

	/**
     * @description Determines if a Flow is the main flow or a subflow
     * @param sfdcFlow Flow to check
     * @param stackTraceInfo Stacktrace information for comparison
     * @return Boolean True if main flow, False if subflow
     */
    public static Boolean isMainFlow(FlowDataStructures.Flow sfdcFlow, FlowDataStructures.FlowStacktraceInfo stackTraceInfo) {
        return sfdcFlow?.name?.startsWith(stackTraceInfo?.flowDetails?.flowApiName) 
            || stackTraceInfo?.flowDetails?.flowApiName?.endsWith(sfdcFlow?.name);
    }

	/**
     * @description Finalizes the result Flow object with subflows and error information
     * @param result Main Flow object to finalize
     * @param subflows List of subflows to add
     * @param stackTraceInfo Stacktrace information containing error details
     */
    public static void finalizeResult(FlowDataStructures.Flow result, List<FlowDataStructures.Flow> subflows, FlowDataStructures.FlowStacktraceInfo stackTraceInfo) {
        if (result != null) {
            result.subflows.addAll(subflows);
            result.errorMessage = stackTraceInfo?.errorMessage;
            result.errorMessageHtml = stackTraceInfo?.errorMessageHtml;
            result.orchestratorFailedFlowApiName = stackTraceInfo?.orchestratorFailedFlowApiName;
            try {
                result.apexStackTraceParseResults = StackTraceParser.parseStackTrace(result.errorMessageHtml);
            }
            catch(Exception e) {}
        }
    }

	public static List<FlowDataStructures.Flow> getSFDCFlows(List<String> flowApiNames, String metadataApiVersion) {
		List<FlowDataStructures.Flow> results = new List<FlowDataStructures.Flow>();

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.setEndpointAndMetadataAPIVersion(StackTraceParser.corg.Instance_Url__c, metadataApiVersion);
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = ConnectedOrgService.getConnectedOrgAccessToken(StackTraceParser.corg);
		Set<String> flowApiNamesSet = new Set<String>(flowApiNames);
		List<String> flowApiNamesList = new List<String>(flowApiNamesSet);
		List<MetadataService.Flow> sfdcFlows =
			(List<MetadataService.Flow>) service.readMetadata('Flow',
				flowApiNamesList).getRecords();
		
		for(MetadataService.Flow sfdcFlow : sfdcFlows) {
			if(sfdcFlow != null) {					
				FlowDataStructures.Flow result = new FlowDataStructures.Flow();
				result.name = sfdcFlow.fullName;
				result.label = sfdcFlow.label;
				result.description = sfdcFlow.description;
				result.processType = sfdcFlow.processType;
				result.start = new FlowDataStructures.FlowStart(sfdcFlow.processType, sfdcFlow);
				if(result?.start?.startRefference != null) {
					getFlowElements(result, sfdcFlow, result.start.startRefference);
				}
				if(sfdcFlow?.startElementReference != null) {
					result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, sfdcFlow.startElementReference, false);
				}
				if(sfdcFlow?.start?.connector != null && sfdcFlow?.start?.connector?.targetReference != null) {
					result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, sfdcFlow.start.connector.targetReference, 'Run Immediately', sfdcFlow.start.connector.isGoTo);
					getFlowElements(result, sfdcFlow, sfdcFlow.start.connector.targetReference);
				}
				if(sfdcFlow?.start?.scheduledPaths != null) {
					for(MetadataService.FlowScheduledPath scheduledPath : sfdcFlow.start.scheduledPaths) {
						result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, scheduledPath?.connector?.targetReference, scheduledPath?.label, scheduledPath?.name, scheduledPath?.connector?.isGoTo);
						getFlowElements(result, sfdcFlow, scheduledPath?.connector?.targetReference);
					}
				}
				if(sfdcFlow?.variables != null && !sfdcFlow?.variables?.isEmpty()) {
					for(MetadataService.FlowVariable fv : sfdcFlow?.variables) {
						FlowDataStructures.FlowVariable nfv = new FlowDataStructures.FlowVariable();
						nfv.name = fv.name;
						nfv.description = fv.description;
						nfv.apexClass = fv.apexClass;
						nfv.isCollection = fv.isCollection;
						nfv.isInput = fv.isInput;
						nfv.isOutput = fv.isOutput;
						nfv.objectType = fv.objectType;
						nfv.dataType = fv.dataType;
						result.variables.add(nfv);
					}
				}
				for(FlowDataStructures.FlowElement fe : result?.elements?.values()) {
					result.labelToApiMap.put(fe.label, fe.name);
				}
				results.add(result);					
			}
		}
		
		return results;
	}

	public static FlowDataStructures.Flow getSFDCFlow(String flowApiNameWithVersion) {
		return getSFDCFlow(flowApiNameWithVersion, Constants.FLOW.FLOW_CURRENT_SUPPORTED_API_VERSION);
	}

	public static FlowDataStructures.Flow getSFDCFlow(String flowApiNameWithVersion, String metadataApiVersion) {
		FlowDataStructures.Flow result = new FlowDataStructures.Flow();

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.setEndpointAndMetadataAPIVersion(StackTraceParser.corg.Instance_Url__c, metadataApiVersion);
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = ConnectedOrgService.getConnectedOrgAccessToken(StackTraceParser.corg);
		MetadataService.Flow sfdcFlow =
			(MetadataService.Flow) service.readMetadata('Flow',
				new String[] {flowApiNameWithVersion}).getRecords()[0];

		if(sfdcFlow != null && sfdcFlow.fullName != null) {
			result.name = sfdcFlow.fullName;
			result.label = sfdcFlow.label;
			result.processType = sfdcFlow.processType;
			result.start = new FlowDataStructures.FlowStart(sfdcFlow.processType, sfdcFlow);
			if(result?.start?.startRefference != null) {
				getFlowElements(result, sfdcFlow, result.start.startRefference);
			}
			if(sfdcFlow?.startElementReference != null) {
				result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, sfdcFlow.startElementReference, false);
			}
			if(sfdcFlow?.start?.connector != null && sfdcFlow?.start?.connector?.targetReference != null) {
				result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, sfdcFlow.start.connector.targetReference, 'Run Immediately', sfdcFlow.start.connector.isGoTo);
				getFlowElements(result, sfdcFlow, sfdcFlow.start.connector.targetReference);
			}
			if(sfdcFlow?.start?.scheduledPaths != null) {
				for(MetadataService.FlowScheduledPath scheduledPath : sfdcFlow.start.scheduledPaths) {
					result.addEdge(Constants.FLOW.PB_ST_START_ELEMENT, scheduledPath?.connector?.targetReference, scheduledPath?.label, scheduledPath?.name, scheduledPath?.connector?.isGoTo);
					getFlowElements(result, sfdcFlow, scheduledPath?.connector?.targetReference);
				}
			}
		}
		return result;
	}

	// Extract flow element creation logic into a separate method
	private static FlowDataStructures.FlowElement createFlowElement(String name, String label, String actionType, Integer locationX, Integer locationY, String description, String icon) {
		FlowDataStructures.FlowElement fe = new FlowDataStructures.FlowElement(name, label, actionType, locationX, locationY, description);
		if (String.isNotBlank(icon)) {
			fe.setIcon(icon);
		}
		return fe;
	}

	// Extract common connector handling logic
	private static void handleConnectors(FlowDataStructures.Flow flow, String elementName, MetadataService.FlowConnector connector, 
	                                   MetadataService.FlowConnector faultConnector, MetadataService.Flow sfdcFlow) {
		if (connector != null && connector.targetReference != null) {
			flow.addEdge(elementName, connector.targetReference, connector.isGoTo);
			getFlowElements(flow, sfdcFlow, connector.targetReference);
		}
		
		if (faultConnector != null && faultConnector.targetReference != null) {
			flow.addEdge(elementName, faultConnector.targetReference, Constants.FLOW.PB_ST_VAR_FAULT, true, faultConnector.isGoTo);
			getFlowElements(flow, sfdcFlow, faultConnector.targetReference);
		}
	}

	public static void getFlowElements(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (String.isBlank(nextRefferenceName) || flow.edges.containsKey(nextRefferenceName)) {
			return;
		}

		handleOrchestratedStages(flow, sfdcFlow, nextRefferenceName);
        handleCollectionProcessors(flow, sfdcFlow, nextRefferenceName);
		handleCustomErrors(flow, sfdcFlow, nextRefferenceName);
		handleWaits(flow, sfdcFlow, nextRefferenceName);
		handleTransforms(flow, sfdcFlow, nextRefferenceName);
		handleRecordUpdates(flow, sfdcFlow, nextRefferenceName);
		handleRecordCreates(flow, sfdcFlow, nextRefferenceName);
		handleRecordLookups(flow, sfdcFlow, nextRefferenceName);
		handleRecordDeletes(flow, sfdcFlow, nextRefferenceName);
		handleDecisions(flow, sfdcFlow, nextRefferenceName);
		handleAssignments(flow, sfdcFlow, nextRefferenceName);
		handleScreens(flow, sfdcFlow, nextRefferenceName);
		handleSubflows(flow, sfdcFlow, nextRefferenceName);
		handleActionCalls(flow, sfdcFlow, nextRefferenceName);
		handleLoops(flow, sfdcFlow, nextRefferenceName);
		handleRecordRollbacks(flow, sfdcFlow, nextRefferenceName);		
	}

	private static void handleOrchestratedStages(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.orchestratedStages != null) {
			for (MetadataService.FlowOrchestratedStage stage : sfdcFlow.orchestratedStages) {
				if (stage != null && nextRefferenceName == stage.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(stage.name, stage.label, 'FlowOrchestratedStage', 
													stage.locationX, stage.locationY, stage.description, Constants.FLOW.FLOW_ELEMENT_ICON_ORCHESTRATED_STAGE);
					addFlowOrchestratedStagesInfo(fe, stage);
					fe.setHasFaultConnector(stage.faultConnector != null && stage.faultConnector.targetReference != null);
					flow.elements.put(stage.name, fe);
					handleConnectors(flow, nextRefferenceName, stage.connector, stage.faultConnector, sfdcFlow);

				}
			}
		}
	}

	private static void handleCollectionProcessors(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.collectionProcessors != null) {
			for (MetadataService.FlowCollectionProcessor cp : sfdcFlow.collectionProcessors) {
				if (cp != null && nextRefferenceName == cp.name) {
					String icon = cp.elementSubtype == Constants.FLOW.FLOW_ELEMENT_SORT_COLLECTION_PROCESSOR ? 
						Constants.FLOW.FLOW_ELEMENT_ICON_SORT_COLLECTION_PROCESSOR : Constants.FLOW.FLOW_ELEMENT_ICON_FILTER_COLLECTION_PROCESSOR;
						
					FlowDataStructures.FlowElement fe = createFlowElement(cp.name, cp.label, Constants.FLOW.FLOW_ELEMENT_COLLECTION_PROCESSOR,
													cp.locationX, cp.locationY, cp.description, icon);
					
					if (cp.elementSubtype == Constants.FLOW.FLOW_ELEMENT_SORT_COLLECTION_PROCESSOR) {
						addFlowSortCollectionProcessorInfo(fe, cp);
					} else if (cp.elementSubtype == Constants.FLOW.FLOW_ELEMENT_FILTER_COLLECTION_PROCESSOR) {
						addFlowFilterCollectionProcessorInfo(fe, cp, sfdcFlow);
					}
					
					flow.elements.put(cp.name, fe);
					handleConnectors(flow, nextRefferenceName, cp.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleCustomErrors(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.customErrors != null) {
			for (MetadataService.FlowCustomError customError : sfdcFlow.customErrors) {
				if (customError != null && nextRefferenceName == customError.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(customError.name, customError.label, 'FlowCustomError',
													customError.locationX, customError.locationY, customError.description, Constants.FLOW.FLOW_ELEMENT_ICON_CUSTOM_ERROR);
					addFlowCustomErrorInfo(fe, customError);
					flow.elements.put(customError.name, fe);
					handleConnectors(flow, nextRefferenceName, customError.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleWaits(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.waits != null) {
			for (MetadataService.FlowWait wait : sfdcFlow.waits) {
				if (wait != null && nextRefferenceName == wait.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(wait.name, wait.label, 'FlowWait',
													wait.locationX, wait.locationY, wait.description, Constants.FLOW.FLOW_ELEMENT_ICON_WAIT);
					fe.setHasFaultConnector(wait.faultConnector != null && wait.faultConnector.targetReference != null);
					addFlowWaitInfo(fe, wait);
					flow.elements.put(wait.name, fe);

					// Handle decision outcomes
					if (wait.waitEvents != null) {
						for (MetadataService.FlowWaitEvent waitEvent : wait.waitEvents) {
							if (waitEvent.connector != null && waitEvent.connector.targetReference != null) {
								flow.addEdge(wait.name, waitEvent.connector.targetReference, waitEvent.label, waitEvent.name, waitEvent.connector.isGoTo);
								getFlowElements(flow, sfdcFlow, waitEvent.connector.targetReference);
							}
						}
					}
					
					// Handle default outcome
					if (wait.defaultConnector != null && wait.defaultConnector.targetReference != null) {
						flow.addDefaultEdge(wait.name, wait.defaultConnector.targetReference, wait.defaultConnector.isGoTo);
						getFlowElements(flow, sfdcFlow, wait.defaultConnector.targetReference);
					}
					if(wait.faultConnector != null && wait.faultConnector.targetReference != null) {
						flow.addEdge(wait.name, wait.faultConnector.targetReference, Constants.FLOW.PB_ST_VAR_FAULT, true, wait.faultConnector.isGoTo);
						getFlowElements(flow, sfdcFlow, wait.faultConnector.targetReference);
					}
				}
			}
		}

	}

	private static void handleTransforms(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.transforms != null) {
			for (MetadataService.FlowTransform transform : sfdcFlow.transforms) {
				if (transform != null && nextRefferenceName == transform.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(transform.name, transform.label, 'FlowTransform',
													transform.locationX, transform.locationY, transform.description, Constants.FLOW.FLOW_ELEMENT_ICON_TRANSFORM);
					addFlowTransformInfo(fe, transform);
					flow.elements.put(transform.name, fe);
					handleConnectors(flow, nextRefferenceName, transform.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleRecordUpdates(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.recordUpdates != null) {
			for (MetadataService.FlowRecordUpdate recordUpdate : sfdcFlow.recordUpdates) {
				if (recordUpdate != null && nextRefferenceName == recordUpdate.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(recordUpdate.name, recordUpdate.label, 'FlowRecordUpdate',
													recordUpdate.locationX, recordUpdate.locationY, recordUpdate.description, Constants.FLOW.FLOW_ELEMENT_ICON_RECORD_UPDATE);
					addRecordsUpdateInfo(fe, recordUpdate, sfdcFlow);
					fe.setHasFaultConnector(recordUpdate.faultConnector != null && recordUpdate.faultConnector.targetReference != null);
					flow.elements.put(recordUpdate.name, fe);
					handleConnectors(flow, nextRefferenceName, recordUpdate.connector, recordUpdate.faultConnector, sfdcFlow);
				}
			}
		}
	}

	private static void handleRecordCreates(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.recordCreates != null) {
			for (MetadataService.FlowRecordCreate recordCreate : sfdcFlow.recordCreates) {
				if (recordCreate != null && nextRefferenceName == recordCreate.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(recordCreate.name, recordCreate.label, 'FlowRecordCreate',
													recordCreate.locationX, recordCreate.locationY, recordCreate.description, Constants.FLOW.FLOW_ELEMENT_ICON_RECORD_CREATE);
					addRecordsCreateInfo(fe, recordCreate, sfdcFlow);
					fe.setHasFaultConnector(recordCreate.faultConnector != null && recordCreate.faultConnector.targetReference != null);
					flow.elements.put(recordCreate.name, fe);
					handleConnectors(flow, nextRefferenceName, recordCreate.connector, recordCreate.faultConnector, sfdcFlow);
				}
			}
		}
	}

	private static void handleRecordLookups(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.recordLookups != null) {
			for (MetadataService.FlowRecordLookup recordLookup : sfdcFlow.recordLookups) {
				if (recordLookup != null && nextRefferenceName == recordLookup.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(recordLookup.name, recordLookup.label, 'FlowRecordLookup',
													recordLookup.locationX, recordLookup.locationY, recordLookup.description, Constants.FLOW.FLOW_ELEMENT_ICON_RECORD_LOOKUP);
					addRecordsLookupInfo(fe, recordLookup);
					fe.setHasFaultConnector(recordLookup.faultConnector != null && recordLookup.faultConnector.targetReference != null);
					flow.elements.put(recordLookup.name, fe);
					handleConnectors(flow, nextRefferenceName, recordLookup.connector, recordLookup.faultConnector, sfdcFlow);
				}
			}
		}
	}

	private static void handleRecordDeletes(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.recordDeletes != null) {
			for (MetadataService.FlowRecordDelete recordDelete : sfdcFlow.recordDeletes) {
				if (recordDelete != null && nextRefferenceName == recordDelete.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(recordDelete.name, recordDelete.label, 'FlowRecordDelete',
													recordDelete.locationX, recordDelete.locationY, recordDelete.description, Constants.FLOW.FLOW_ELEMENT_ICON_RECORD_DELETE);
					addRecordsDeleteInfo(fe, recordDelete, sfdcFlow);
					fe.setHasFaultConnector(recordDelete.faultConnector != null && recordDelete.faultConnector.targetReference != null);
					flow.elements.put(recordDelete.name, fe);
					handleConnectors(flow, nextRefferenceName, recordDelete.connector, recordDelete.faultConnector, sfdcFlow);
				}
			}
		}
	}

	private static void handleRecordRollbacks(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.recordRollbacks != null) {
			for (MetadataService.FlowRecordRollback recordRollback : sfdcFlow.recordRollbacks) {
				if (recordRollback != null && nextRefferenceName == recordRollback.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(recordRollback.name, recordRollback.label, 'FlowRecordRollback',
													recordRollback.locationX, recordRollback.locationY, recordRollback.description, Constants.FLOW.FLOW_ELEMENT_ICON_ROLL_BACK_RECORDS);
					addRecordsRollbackInfo(fe, recordRollback, sfdcFlow);
					flow.elements.put(recordRollback.name, fe);
					handleConnectors(flow, nextRefferenceName, recordRollback.connector, null, sfdcFlow);
				}
			}
		}
	}


	private static void handleDecisions(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.decisions != null) {
			for (MetadataService.FlowDecision decision : sfdcFlow.decisions) {
				if (decision != null && nextRefferenceName == decision.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(decision.name, decision.label, 'FlowDecision',
													decision.locationX, decision.locationY, decision.description, Constants.FLOW.FLOW_ELEMENT_ICON_DECISION);
					addDecisionInfo(fe, decision);
					flow.elements.put(decision.name, fe);
					
					// Handle decision outcomes
					if (decision.rules != null) {
						for (MetadataService.FlowRule rule : decision.rules) {
							if (rule.connector != null && rule.connector.targetReference != null) {
								flow.addEdge(decision.name, rule.connector.targetReference, rule.label, rule.name, rule.connector.isGoTo);
								getFlowElements(flow, sfdcFlow, rule.connector.targetReference);
							}
						}
					}
					
					// Handle default outcome
					if (decision.defaultConnector != null && decision.defaultConnector.targetReference != null) {
						flow.addDefaultEdge(decision.name, decision.defaultConnector.targetReference, decision.defaultConnector.isGoTo);
						getFlowElements(flow, sfdcFlow, decision.defaultConnector.targetReference);
					}
				}
			}
		}
	}

	private static void handleAssignments(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.assignments != null) {
			for (MetadataService.FlowAssignment assignment : sfdcFlow.assignments) {
				if (assignment != null && nextRefferenceName == assignment.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(assignment.name, assignment.label, 'FlowAssignment',
													assignment.locationX, assignment.locationY, assignment.description, Constants.FLOW.FLOW_ELEMENT_ICON_ASSIGNMENT);
					addAssignmentInfo(fe, assignment);
					flow.elements.put(assignment.name, fe);
					handleConnectors(flow, nextRefferenceName, assignment.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleScreens(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.screens != null) {
			for (MetadataService.FlowScreen screen : sfdcFlow.screens) {
				if (screen != null && nextRefferenceName == screen.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(screen.name, screen.label, 'FlowScreen',
													screen.locationX, screen.locationY, screen.description, Constants.FLOW.FLOW_ELEMENT_ICON_SCREEN);
					addScreenInfo(fe, screen);
					flow.elements.put(screen.name, fe);
					handleConnectors(flow, nextRefferenceName, screen.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleSubflows(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.subflows != null) {
			for (MetadataService.FlowSubflow subflow : sfdcFlow.subflows) {
				if (subflow != null && nextRefferenceName == subflow.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(subflow.name, subflow.label, 'FlowSubflow',
													subflow.locationX, subflow.locationY, subflow.description, Constants.FLOW.FLOW_ELEMENT_ICON_SUB_FLOW);
					addSubflowInfo(fe, subflow);
					flow.elements.put(subflow.name, fe);
					handleConnectors(flow, nextRefferenceName, subflow.connector, null, sfdcFlow);
				}
			}
		}
	}

	private static void handleActionCalls(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.actionCalls != null) {
			for (MetadataService.FlowActionCall actionCall : sfdcFlow.actionCalls) {
				if (actionCall != null && nextRefferenceName == actionCall.name) {
					String icon = getActionIcon(actionCall.actionType);
					FlowDataStructures.FlowElement fe = createFlowElement(actionCall.name, actionCall.label, 'FlowActionCall',
													actionCall.locationX, actionCall.locationY, actionCall.description, icon);
					addFlowActionInfo(fe, actionCall);
					fe.setHasFaultConnector(actionCall.faultConnector != null && actionCall.faultConnector.targetReference != null);
					flow.elements.put(actionCall.name, fe);
					handleConnectors(flow, nextRefferenceName, actionCall.connector, actionCall.faultConnector, sfdcFlow);

				}
			}
		}
	}

	private static string getActionIcon(string actionType) {
		string icon = Constants.FLOW.FLOW_ELEMENT_ICON_ACTION;
		if (actionType == 'apex') {
			icon = Constants.FLOW.FLOW_ELEMENT_ICON_ACTION_APEX;
		} else if (actionType == 'findMatchingIndividuals') {
			icon = Constants.FLOW.FLOW_ELEMENT_ICON_ACTION_SEARCH;
		}
		return icon;
	}


	private static void handleLoops(FlowDataStructures.Flow flow, MetadataService.Flow sfdcFlow, String nextRefferenceName) {
		if (sfdcFlow.loops != null) {
			for (MetadataService.FlowLoop loopElement : sfdcFlow.loops) {
				if (loopElement != null && nextRefferenceName == loopElement.name) {
					FlowDataStructures.FlowElement fe = createFlowElement(loopElement.name, loopElement.label, 'FlowLoop',
												loopElement.locationX, loopElement.locationY, loopElement.description, Constants.FLOW.FLOW_ELEMENT_ICON_LOOP);
					addFlowLoopInfo(fe, loopElement);
					flow.elements.put(loopElement.name, fe);

					// Handle loop paths
					if (loopElement.nextValueConnector != null && loopElement.nextValueConnector.targetReference != null) {
						flow.addEdge(loopElement.name, loopElement.nextValueConnector.targetReference, 'For Each Item', loopElement.nextValueConnector.isGoTo);
						getFlowElements(flow, sfdcFlow, loopElement.nextValueConnector.targetReference);
					}

					if (loopElement.noMoreValuesConnector != null && loopElement.noMoreValuesConnector.targetReference != null) {
						flow.addEdge(loopElement.name, loopElement.noMoreValuesConnector.targetReference, 'After Last Item', loopElement.noMoreValuesConnector.isGoTo);
						getFlowElements(flow, sfdcFlow, loopElement.noMoreValuesConnector.targetReference);
					}
				}
			}
		}
	}

	public class OrchestratedStagesInfo {
		public String label;
		public String name;
		public String description;
		public String conditionLabel;
		public List<StageStepsInfo> stageSteps;
		public String exitActionType;
		public String exitConditionLogic;

		public OrchestratedStagesInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.stageSteps = new List<StageStepsInfo>();
		}
	}

	public class StageStepsInfo {
		public String label;
		public String name;
		public String description;
		public String actionName;
		public String actionType;
		public String conditionValue;
		public String conditionLabel;
		public String assignee;
		public String assigneeType;
		public String exitActionName;
		public String exitActionType;
		public String recordId;

		public StageStepsInfo(String label, String name, String actionName, String actionType, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.actionName = actionName;
			this.actionType = actionType;
		}
	}

	public static void addFlowOrchestratedStagesInfo(FlowDataStructures.FlowElement element, MetadataService.FlowOrchestratedStage flowOrchestratedStage) {
		OrchestratedStagesInfo result = new OrchestratedStagesInfo(flowOrchestratedStage.label, flowOrchestratedStage.name, flowOrchestratedStage.description);

		if(flowOrchestratedStage.stageSteps != null) {
			for(MetadataService.FlowStageStep stageStep : flowOrchestratedStage.stageSteps) {
				StageStepsInfo stageStepInfo = new StageStepsInfo(
					stageStep?.label,
					stageStep?.name,
					stageStep?.actionName,
					stageStep?.actionType,
					stageStep?.description
				);
				if(stageStep?.entryActionType != null && stageStep?.entryActionType == 'evaluationFlow') {
					stageStepInfo.conditionLabel = 'When the specified evaluation flow returns True, the step starts';
					stageStepInfo.conditionValue = stageStep?.entryActionName;
				}
				else if(stageStep?.entryConditions != null && !stageStep?.entryConditions?.isEmpty()) {
					stageStepInfo.conditionLabel = 'When another step is marked Complete, the step starts';
					for(MetadataService.FlowCondition condition : stageStep.entryConditions) {
						if(String.isNotBlank(condition?.leftValueReference)) {
							List<String> parts = condition?.leftValueReference?.split('\\.');
							for(MetadataService.FlowStageStep step : flowOrchestratedStage.stageSteps) {
								if(step.name == parts.get(0)) {
									stageStepInfo.conditionValue = step?.label;
									break;
								}
							}
						}
					}
				}
				else {
					stageStepInfo.conditionLabel = 'When the stage starts, the step starts';
				}

				if(stageStep?.assignees != null && !stageStep?.assignees?.isEmpty()) {
					for(MetadataService.FlowStageStepAssignee stageStepAssignee : stageStep.assignees) {
						stageStepInfo.assigneeType = stageStepAssignee?.assigneeType;
						stageStepInfo.assignee = String.valueOf(getFlowElementReferenceOrValue(stageStepAssignee?.assignee));
					}
				}

				if(stageStep?.inputParameters != null && !stageStep?.inputParameters?.isEmpty()) {
					for(MetadataService.FlowStageStepInputParameter inputParameter : stageStep?.inputParameters) {
						if(inputParameter?.name == 'ActionInput__RecordId') {
							stageStepInfo.recordId = String.valueOf(getFlowElementReferenceOrValue(inputParameter?.value));
						}
					}
				}

				result.stageSteps.add(stageStepInfo);
			}
			result.exitConditionLogic = flowOrchestratedStage.exitConditionLogic;
		}
		element.metadataInfo = result;
	}

	public class FlowRecordDeleteInfo {
		public String label;
		public String name;
		public String description;
		public String objectName;
		public String inputReference;
		public Boolean useTheIDsStored;
		public Boolean specifyConditions;

		public String conditionLogic;
		public String conditionName;
		public String conditionLabel;
		public List<FlowDataStructures.FlowRecordFilterInfo> conditions;

		public FlowRecordDeleteInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.conditions = new List<FlowDataStructures.FlowRecordFilterInfo>();
		}
	}

	public static void addRecordsDeleteInfo(FlowDataStructures.FlowElement element, MetadataService.FlowRecordDelete flowRecordDelete, MetadataService.Flow sfdcFlow) {
		FlowRecordDeleteInfo result = new FlowRecordDeleteInfo(flowRecordDelete.label, flowRecordDelete.name, flowRecordDelete.description);
		result.inputReference = flowRecordDelete.inputReference;
		result.objectName = flowRecordDelete?.object_x == null ? sfdcFlow?.start?.object_x : flowRecordDelete?.object_x;

		if(flowRecordDelete.filters != null) {
			for(MetadataService.FlowRecordFilter filter : flowRecordDelete.filters) {
				result.conditions.add(new FlowDataStructures.FlowRecordFilterInfo(
					filter?.field,
					filter?.operator,
					String.valueOf(getFlowElementReferenceOrValue(filter?.value))
				));
			}
			result.conditionLogic = flowRecordDelete.filterLogic;
			if(result.conditionLogic == null) {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_EMPTY_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
			}
			else if(result.conditionLogic == 'and') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
			}
			else if(result.conditionLogic == 'or') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
			}
			else {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
				result.conditionName = flowRecordDelete.filterLogic;
				result.conditionLogic = flowRecordDelete.filterLogic;
			}
		}
		result.specifyConditions = (!result.conditions.isEmpty());
		result.useTheIDsStored = !result.specifyConditions;

		element.metadataInfo = result;
	}

	public class FlowRecordRollbackInfo {
		public String label;
		public String name;
		public String description;
		public String elementSubtype;
		

		public FlowRecordRollbackInfo(String label, String name, String description, String elementSubtype) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.elementSubtype = elementSubtype;
		}
	}

	public static void addRecordsRollbackInfo(FlowDataStructures.FlowElement element, MetadataService.FlowRecordRollback flowRecordRollback, MetadataService.Flow sfdcFlow) {
		FlowRecordRollbackInfo result = new FlowRecordRollbackInfo(flowRecordRollback.label, flowRecordRollback.name, flowRecordRollback.description, flowRecordRollback.elementSubtype);
		element.metadataInfo = result;
	}

	public class FlowSubFlowInfo {
		public String label;
		public String name;
		public String description;
		public String flowName;
		public Boolean manuallyAssignVariables;
		public List<FlowSubflowInputAssignmentInfo> inputAssignments;
		public List<FlowSubflowOutputAssignmentInfo> outputAssignments;

		public FlowSubFlowInfo(String label, String name, String flowName, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.flowName = flowName;
			this.inputAssignments = new List<FlowSubflowInputAssignmentInfo>();
			this.outputAssignments = new List<FlowSubflowOutputAssignmentInfo>();
		}
	}

	public class FlowSubflowInputAssignmentInfo {
		public String name;
		public Object value;

		public FlowSubflowInputAssignmentInfo(String name, Object value) {
			this.name = name;
			this.value = value;
		}
	}

	public class FlowSubflowOutputAssignmentInfo {
		public String name;
		public String assignToReference;

		public FlowSubflowOutputAssignmentInfo(String name, String assignToReference) {
			this.name = name;
			this.assignToReference = assignToReference;
		}
	}

	public class FlowCustomErrorInfo {
		public String label;
		public String name;
		public String description;
		public List<FlowCustomErrorMessage> customErrorMessages;

		public FlowCustomErrorInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.customErrorMessages = new List<FlowCustomErrorMessage>();
		}
	}

	public class FlowCustomErrorMessage {
		public String errorMessage;
        public String fieldSelection;
        public Boolean isFieldError;

		public FlowCustomErrorMessage(String errorMessage, String fieldSelection, Boolean isFieldError) {
			this.errorMessage = errorMessage;
			this.fieldSelection = fieldSelection;
			this.isFieldError = isFieldError;
		}
	}

	public static void addFlowCustomErrorInfo(FlowDataStructures.FlowElement element, MetadataService.FlowCustomError flowCustomError) {
		FlowCustomErrorInfo result = new FlowCustomErrorInfo(flowCustomError.label, flowCustomError.name, flowCustomError.description);
		if(flowCustomError.customErrorMessages != null) {
			for(MetadataService.FlowCustomErrorMessage ia : flowCustomError.customErrorMessages) {
				result.customErrorMessages.add(new FlowCustomErrorMessage(
					ia?.errorMessage,
					ia?.fieldSelection,
					ia?.isFieldError
				));
			}
		}
		element.metadataInfo = result;
	}

	public class FlowSortCollectionInfo {
		public String label;
		public String name;
		public String description;
		public List<FlowCollectionSortOption> sortOptions;
		public Integer limit_x;
		public String elementSubtype;
		public String collectionReference;

		public FlowSortCollectionInfo(String label, String name, String collectionReference, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.collectionReference = collectionReference;
			this.sortOptions = new List<FlowCollectionSortOption>();
		}
	}

	public class FlowCollectionSortOption {
		public String sortField;
		public String sortOrder;
		public Boolean doesPutEmptyStringAndNullFirst;

		public FlowCollectionSortOption(MetadataService.FlowCollectionSortOption sortOption) {
			this.sortField = sortOption.sortField;
			this.sortOrder = sortOption.sortOrder;
			this.doesPutEmptyStringAndNullFirst = sortOption.doesPutEmptyStringAndNullFirst;
		}
	}

	public class FlowFilterCollectionInfo {
		public String label;
		public String name;
		public List<FlowFilterCollectionConditionInfo> conditions;
		// api name of lookup element 
		public String collectionReference;
		public String assignNextValueToReference;
		public String assignNextValueToReferenceDataType;
		public String assignNextValueToReferenceObjectType;
		public Boolean assignNextValueToReferenceIsCollection;
		public String conditionLogic;
		public String conditionName;
		public String conditionLabel;
		public String elementSubtype;

		public FlowFilterCollectionInfo(String label, String name) {
			this.label = label;
			this.name = name;
			this.conditions = new List<FlowFilterCollectionConditionInfo>();
		}
	}

	public class FlowFilterCollectionConditionInfo {
		public String field;
		public String operator;
		public Object value;

		public FlowFilterCollectionConditionInfo(String field, String operator, Object value) {
			this.field = field;
			this.operator = Constants.FLOW.FLOW_COMPRASION_OPERATOR_MAPPING.get(operator);
			this.value = value;
		}
	}

	public static void  addFlowFilterCollectionProcessorInfo(FlowDataStructures.FlowElement element, MetadataService.FlowCollectionProcessor filterCollection, MetadataService.Flow sfdcFlow) {
		FlowFilterCollectionInfo result = new FlowFilterCollectionInfo(filterCollection.label, filterCollection.name);
		result.collectionReference = filterCollection.collectionReference;
		result.assignNextValueToReference = filterCollection.assignNextValueToReference;
		result.elementSubtype = filterCollection.elementSubtype;
		if(String.isNotBlank(result.assignNextValueToReference)) {
			MetadataService.FlowVariable flowVariable = getFlowVariable(result.assignNextValueToReference, sfdcFlow);
			if(flowVariable != null) {
				result.assignNextValueToReferenceDataType = flowVariable.dataType;
				result.assignNextValueToReferenceObjectType = flowVariable.objectType;
				result.assignNextValueToReferenceIsCollection = flowVariable.isCollection;
			}
		}

		if(filterCollection.conditions != null) {
			result.conditionLogic = filterCollection.conditionLogic;
			if(result.conditionLogic == null) {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_PAUSE_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
			}
			else if(result.conditionLogic == 'and') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
			}
			else if(result.conditionLogic == 'or') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
			}
			else {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
				result.conditionName = filterCollection.conditionLogic;
				result.conditionLogic = filterCollection.conditionLogic;
			}
			
			for(MetadataService.FlowCondition condition : filterCollection.conditions) {
				result.conditions.add(new FlowFilterCollectionConditionInfo(
					condition?.leftValueReference,
					condition?.operator,
					String.valueOf(getFlowElementReferenceOrValue(condition?.rightValue))
				));
			}
		}
		element.metadataInfo = result;
	}

	public static void addFlowSortCollectionProcessorInfo(FlowDataStructures.FlowElement element, MetadataService.FlowCollectionProcessor sortCollection) {
		FlowSortCollectionInfo result = new FlowSortCollectionInfo(sortCollection.label, sortCollection.name, sortCollection.collectionReference, sortCollection.description);
		if(sortCollection.sortOptions != null) {
			for(MetadataService.FlowCollectionSortOption so : sortCollection.sortOptions) {
				result.sortOptions.add(new FlowCollectionSortOption(so));
			}
		}
		result.elementSubtype = sortCollection.elementSubtype;
		if(sortCollection.limit_x != null) {
			result.limit_x = sortCollection.limit_x;
		}
		element.metadataInfo = result;
	}

	public static void addSubFlowInfo(FlowDataStructures.FlowElement element, MetadataService.FlowSubflow subFlow) {
		FlowSubFlowInfo result = new FlowSubFlowInfo(subFlow.label, subFlow.name, subFlow.flowName, subFlow.description);
		if(subFlow.inputAssignments != null) {
			for(MetadataService.FlowSubflowInputAssignment ia : subFlow.inputAssignments) {
				result.inputAssignments.add(new FlowSubflowInputAssignmentInfo(
					ia?.name,
					String.valueOf(getFlowElementReferenceOrValue(ia?.value))
				));
			}
		}
		if(subflow.outputAssignments != null) {
			for(MetadataService.FlowSubflowOutputAssignment ia : subFlow.outputAssignments) {
				result.outputAssignments.add(new FlowSubflowOutputAssignmentInfo(
					ia?.name,
					ia?.assignToReference
				));
			}
			result.manuallyAssignVariables = !result.outputAssignments.isEmpty();
		}
		element.metadataInfo = result;
	}

	public class FlowWaitInfo {
		public String label;
		public String name;
		public String description;
		public List<FlowWaitEventInfo> events;
		public String defaultConnectorLabel;
		public String elementSubtype;
		public String timeZoneId;

		public FlowWaitInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.events = new List<FlowWaitEventInfo>();
		}
	}

	public class FlowWaitEventInfo {

		public String name;
		public String label;
		public String description;
		public String eventType;
		public String conditionLogic;
		public String conditionName;
		public String conditionLabel;

		//WaitDuration
		public Integer offset;
		public String offsetUnit;

		//WaitDate
		public Date resumeDate;
		public String resumeTime;

		public List<FlowWaitEventConditionInfo> conditions;
		public List<FlowWaitEventInputParameterInfo> inputParameters;
		public List<FlowWaitEventOutputParameterInfo> outputParameters;

		public FlowWaitEventInfo(String label, String name, String eventType, String description){
			this.name = name;
			this.label = label;
			this.description = description;
			this.eventType = eventType;
			this.conditions = new List<FlowWaitEventConditionInfo>();
			this.inputParameters = new List<FlowWaitEventInputParameterInfo>();
			this.outputParameters = new List<FlowWaitEventOutputParameterInfo>();
		}
	}

	public class FlowWaitEventConditionInfo {
		public String resource;
		public String operator;
		public Object value;

		public FlowWaitEventConditionInfo(String resource, String operator, Object value) {
			this.resource = resource;
			this.operator = Constants.FLOW.FLOW_COMPRASION_OPERATOR_MAPPING.get(operator);
			this.value = value;
		}
	}

	public class FlowWaitEventInputParameterInfo {
		public String name;
		public String value;

		public FlowWaitEventInputParameterInfo(String name, String value) {
			this.name = name;
			this.value = value;
		}
	}

	public class FlowWaitEventOutputParameterInfo {
		public String name;
		public String assignToReference;

		public FlowWaitEventOutputParameterInfo(String name, String assignToReference) {
			this.name = name;
			this.assignToReference = assignToReference;
		}
	}

	public static String getFlowWaitEventLabel(MetadataService.FlowWaitEvent fwe, MetadataService.FlowWait flowWait) {
		String waitEventLabel = fwe?.label;
		// clear default labels (el_0, el_1, el_...)
		if(String.isNotBlank(flowWait?.elementSubtype) && (flowWait?.elementSubtype == 'WaitDuration' || flowWait?.elementSubtype == 'WaitDate')) {
			waitEventLabel = null;
		}
		return waitEventLabel;
	}

	public static void addFlowWaitInfo(FlowDataStructures.FlowElement element, MetadataService.FlowWait flowWait) {
		String label = (String.isNotBlank(flowWait?.elementSubtype)) ? '' : flowWait?.label;
		FlowWaitInfo result = new FlowWaitInfo(label, flowWait.name, flowWait.description);
		result.defaultConnectorLabel = flowWait.defaultConnectorLabel;
		result.elementSubtype = flowWait.elementSubtype;
		result.timeZoneId = flowWait.timeZoneId;
		element.setIcon('wait');

		if(flowWait.waitEvents != null) {
			for(MetadataService.FlowWaitEvent fwe : flowWait.waitEvents) {
				FlowWaitEventInfo fwEventInfo = new FlowWaitEventInfo(getFlowWaitEventLabel(fwe, flowWait), fwe?.name, fwe?.eventType, fwe?.description);

				fwEventInfo.offset = fwe.offset;
				fwEventInfo.offsetUnit = fwe.offsetUnit;

				fwEventInfo.resumeDate = fwe.resumeDate;
				fwEventInfo.resumeTime = fwe.resumeTime;

				if(fwe != null && fwe.conditions != null) {
					fwEventInfo.conditionLogic = fwe.conditionLogic;
					if(fwEventInfo.conditionLogic == null) {
						fwEventInfo.conditionLabel = Constants.FLOW.FLOW_CONDITION_PAUSE_LABEL;
						fwEventInfo.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
					}
					else if(fwEventInfo.conditionLogic == 'and') {
						fwEventInfo.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
						fwEventInfo.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
					}
					else if(fwEventInfo.conditionLogic == 'or') {
						fwEventInfo.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
						fwEventInfo.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
					}
					else {
						fwEventInfo.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
						fwEventInfo.conditionName = fwe.conditionLogic;
						fwEventInfo.conditionLogic = fwe.conditionLogic;
					}
					if(fwe.conditions != null) {
						for(MetadataService.FlowCondition condition : fwe.conditions) {
							fwEventInfo.conditions.add(new FlowWaitEventConditionInfo(
								condition?.leftValueReference,
								condition?.operator,
								String.valueOf(getFlowElementReferenceOrValue(condition?.rightValue))
							));
						}
					}
				}

				if(fwe.inputParameters != null) {
					for(MetadataService.FlowWaitEventInputParameter ip : fwe.inputParameters) {
						fwEventInfo.inputParameters.add(new FlowWaitEventInputParameterInfo(
							ip?.name,
							String.valueOf(getFlowElementReferenceOrValue(ip?.value))
						));
					}
				}
				if(fwe.outputParameters != null) {
					for(MetadataService.FlowWaitEventOutputParameter ip : fwe.outputParameters) {
						fwEventInfo.outputParameters.add(new FlowWaitEventOutputParameterInfo(
							ip?.name,
							ip?.assignToReference
						));
					}
				}
				result.events.add(fwEventInfo);
			}
		}

		element.metadataInfo = result;
	}

	public class FlowTransformInfo {
		public String label;
		public String name;
		public String description;
		public String elementSubtype;

		public String apexClass;
        public String dataType;
        public Boolean isCollection;
        public String objectType;
        public Integer scale;
        public FlowTransformValueInfo[] transformValues;

		public FlowTransformInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
		}
	}

	public class FlowTransformValueActionInfo {
		public String name;
		public String outputFieldApiName;
		public String transformType;
		public String value;
		public String formulaDataType;
		public String formulaExpression;

		public FlowTransformValueActionInfo() {}
	}

	public class FlowTransformValueInfo {
		public String transformValueDescription;
		public String transformValueLabel;
		public String transformValueName;
		public List<FlowTransformValueActionInfo> transformValueActions;

		public FlowTransformValueInfo() {
			this.transformValueActions = new List<FlowTransformValueActionInfo>();
		}
	}

	public static void addFlowTransformInfo(FlowDataStructures.FlowElement element, MetadataService.FlowTransform flowTransform) {
		FlowTransformInfo result = new FlowTransformInfo(flowTransform.label, flowTransform.name, flowTransform.description);
		result.elementSubtype = flowTransform.elementSubtype;
		result.description = flowTransform.description;
		result.apexClass = flowTransform.apexClass;
		result.dataType = flowTransform.dataType;
		result.isCollection = flowTransform.isCollection;
		result.objectType = flowTransform.objectType;
		result.transformValues = new List<FlowTransformValueInfo>();

		if(!flowTransform.transformValues?.isEmpty()) {
			for(MetadataService.FlowTransformValue tfv : flowTransform.transformValues) {
				FlowTransformValueInfo tfvi = new FlowTransformValueInfo();
				tfvi.transformValueDescription = tfv.transformValueDescription;
				tfvi.transformValueLabel = tfv.transformValueLabel;
				tfvi.transformValueName = tfv.transformValueName;

				for(MetadataService.FlowTransformValueAction tfva : tfv.transformValueActions) {
					FlowTransformValueActionInfo tfvai = new FlowTransformValueActionInfo();
					tfvai.name = tfva.name;
					tfvai.outputFieldApiName = tfva.outputFieldApiName;
					tfvai.transformType = tfva.transformType;
					tfvai.value = String.valueOf(getFlowElementReferenceOrValue(tfva?.value));
					if(String.isNotBlank(tfva?.value?.formulaDataType)) {
						tfvai.formulaDataType = tfva?.value?.formulaDataType;
					}
					if(String.isNotBlank(tfva?.value?.formulaExpression)) {
						tfvai.formulaExpression = tfva?.value?.formulaExpression;
					}
					tfvi.transformValueActions.add(tfvai);
				}

				result.transformValues.add(tfvi);
			}
		}
		element.metadataInfo = result;
	}
	

	public class FlowLoopInfo {
		public String label;
		public String name;
		public String description;
		public String collectionVariable;
		public String iterationDirection;
		public Boolean firstItemToLastItem;
		public Boolean lastItemToFirstItem;
		public String loopVariable;

		public FlowLoopInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
		}
	}

	public static void addFlowLoopInfo(FlowDataStructures.FlowElement element, MetadataService.FlowLoop flowLoop) {
		FlowLoopInfo result = new FlowLoopInfo(flowLoop.label, flowLoop.name, flowLoop.description);
		result.collectionVariable = flowLoop.collectionReference;
		result.loopVariable = flowLoop.assignNextValueToReference;
		result.iterationDirection = flowLoop.iterationOrder;
		result.firstItemToLastItem = 'Asc' == result.iterationDirection;
		result.lastItemToFirstItem = !result.firstItemToLastItem;
		element.metadataInfo = result;
	}


	public class FlowActionInfo {
		public String label;
		public String name;
		public String description;
		public String actionName;
		public String actionType;
		public List<FlowActionCallInputParameterInfo> assignments;

		public FlowActionInfo(String label, String name, String actionName, String actionType, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.actionName = actionName;
			this.actionType = actionType;
			this.assignments = new List<FlowActionCallInputParameterInfo>();
		}
	}

	public class FlowActionCallInputParameterInfo {
		public String name;
		public Object value;

		public FlowActionCallInputParameterInfo(String name, Object value) {
			this.name = name;
			this.value = value;
		}
	}

	public static void addFlowActionInfo(FlowDataStructures.FlowElement element, MetadataService.FlowActionCall flowAction) {
		FlowActionInfo result = new FlowActionInfo(flowAction.label, flowAction.name, flowAction.actionName, flowAction.actionType, flowAction.description);
		if(flowAction.inputParameters != null) {
			for(MetadataService.FlowActionCallInputParameter ia : flowAction.inputParameters) {
				result.assignments.add(new FlowActionCallInputParameterInfo(
					ia?.name,
					String.valueOf(getFlowElementReferenceOrValue(ia?.value))
				));
			}
		}
		element.metadataInfo = result;
	}

	public static void addRecordsUpdateInfo(FlowDataStructures.FlowElement element, MetadataService.FlowRecordUpdate flowRecordUpdate, MetadataService.Flow sfdcFlow) {
		FlowDataStructures.FlowRecordUpdateInfo result = new FlowDataStructures.FlowRecordUpdateInfo(flowRecordUpdate.label, flowRecordUpdate.name, flowRecordUpdate?.object_x == null ? sfdcFlow?.start?.object_x : flowRecordUpdate?.object_x, flowRecordUpdate.description);

		if(flowRecordUpdate.filters != null) {
			for(MetadataService.FlowRecordFilter filter : flowRecordUpdate.filters) {
				result.conditions.add(new FlowDataStructures.FlowRecordFilterInfo(
					filter?.field,
					filter?.operator,
					String.valueOf(getFlowElementReferenceOrValue(filter?.value))
				));
			}
			result.conditionLogic = flowRecordUpdate.filterLogic;
			if(result.conditionLogic == null) {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_EMPTY_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
			}
			else if(result.conditionLogic == 'and') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
			}
			else if(result.conditionLogic == 'or') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
			}
			else {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
				result.conditionName = flowRecordUpdate.filterLogic;
				result.conditionLogic = flowRecordUpdate.filterLogic;
			}
		}

		if(flowRecordUpdate.inputAssignments != null) {
			for(MetadataService.FlowInputFieldAssignment inputFieldAssignment : flowRecordUpdate.inputAssignments) {
				result.assignments.add(new FlowDataStructures.FlowInputFieldAssignmentInfo(
					inputFieldAssignment?.field,
					String.valueOf(getFlowElementReferenceOrValue(inputFieldAssignment?.value))
				));
			}
		}

		result.specifyConditionsToIdentifyRecords = (!result.assignments.isEmpty());
		result.useTheIDs = !result.specifyConditionsToIdentifyRecords;
		result.inputReference = flowRecordUpdate?.inputReference;

		element.metadataInfo = result;
	}

	public static void addRecordsCreateInfo(FlowDataStructures.FlowElement element, MetadataService.FlowRecordCreate flowRecordCreate, MetadataService.Flow sfdcFlow) {
		FlowDataStructures.FlowRecordCreateInfo result = new FlowDataStructures.FlowRecordCreateInfo(flowRecordCreate.label, flowRecordCreate.name, flowRecordCreate?.object_x == null ? sfdcFlow?.start?.object_x : flowRecordCreate?.object_x, flowRecordCreate.description);

		if(flowRecordCreate.inputAssignments != null) {
			for(MetadataService.FlowInputFieldAssignment ia : flowRecordCreate.inputAssignments) {
				result.assignments.add(new FlowDataStructures.FlowInputFieldAssignmentInfo(
					ia?.field,
					String.valueOf(getFlowElementReferenceOrValue(ia?.value))
				));
			}
			if(!flowRecordCreate.inputAssignments.isEmpty()) {
				result.oneRecordsCreate = true;
			}
		}
		if(String.isNotBlank(flowRecordCreate?.assignRecordIdToReference)) {
			result.manuallyAssignVariables = true;
			result.assignRecordIdToReference = flowRecordCreate?.assignRecordIdToReference;
		}
		if(String.isNotBlank(flowRecordCreate?.inputReference)) {
			result.useAllValuesFromRecord = true;
			result.inputReference = flowRecordCreate?.inputReference;

			MetadataService.FlowVariable flowVariable = getFlowVariable(flowRecordCreate?.inputReference, sfdcFlow);
			if(flowVariable != null && String.isBlank(result.objectName) && flowVariable?.objectType != null) {
				result.objectName = flowVariable?.objectType;
			}
			if(flowVariable != null && flowVariable?.isCollection) {
				result.multipleRecordsCreate = true;
			}
			else if(flowVariable != null && !flowVariable?.isCollection) {
				result.oneRecordsCreate = true;
			}
		}

		element.metadataInfo = result;
	}

	public class FlowRecordLookupInfo {
		public String label;
		public String description;
		public String apiName;
		public String objectName;
		public String conditionLogic;
		public String conditionLabel;
		public String conditionName;
		public List<FlowDataStructures.FlowRecordFilterInfo> conditions;
		public List<FlowOutputFieldAssignmentInfo> assignments;
		public String sortOrder;
		public String sortBy;

		public Boolean onlyFirstRecord;
		public Boolean allRecords;
		public Boolean storeAllFields;
		public Boolean chooseFieldsAndLetSalesforceDoTheRest;
		public Boolean chooseFieldsAndAssignVariables;
		public String storeVariable;
		public Boolean storeTogether;
		public Boolean storeSeparateVariables;
		public Boolean noRecordsAreReturned;

		public List<String> queriedFields;

		public  FlowRecordLookupInfo() {
			this.conditions = new List<FlowDataStructures.FlowRecordFilterInfo>();
			this.assignments = new List<FlowOutputFieldAssignmentInfo>();
			this.queriedFields = new List<String>();
		}

	}

	public class FlowOutputFieldAssignmentInfo {
		public String field;
		public String variable;

		public FlowOutputFieldAssignmentInfo(String field, String variable) {
			this.field = field;
			this.variable = variable;
		}
	}

	public static void addRecordsLookupInfo(FlowDataStructures.FlowElement element, MetadataService.FlowRecordLookup flowRecordLookup) {
		FlowRecordLookupInfo result = new FlowRecordLookupInfo();
		result.label = flowRecordLookup.label;
		result.description = flowRecordLookup.description;
		result.apiName = flowRecordLookup.name;
		result.objectName = flowRecordLookup.object_x;

		result.allRecords = flowRecordLookup.getFirstRecordOnly == false; 
  		result.onlyFirstRecord = !result.allRecords;
		result.storeAllFields = true;



		if(String.isNotBlank(flowRecordLookup.outputReference)) {
			result.storeVariable = flowRecordLookup.outputReference;
			result.noRecordsAreReturned = flowRecordLookup.assignNullValuesIfNoRecordsFound;

			if(flowRecordLookup.queriedFields != null) {
				for(String qField : flowRecordLookup.queriedFields) {
					result.queriedFields.add(qField);
				}
				result.chooseFieldsAndAssignVariables = !flowRecordLookup.queriedFields.isEmpty();
				result.storeAllFields = !result.chooseFieldsAndAssignVariables;
				result.storeTogether = true;
			}
		}
		else {
			if(flowRecordLookup.queriedFields != null) {
				for(String qField : flowRecordLookup.queriedFields) {
					result.queriedFields.add(qField);
				}
				result.chooseFieldsAndLetSalesforceDoTheRest = !flowRecordLookup.queriedFields.isEmpty();
				result.storeAllFields = !result.chooseFieldsAndLetSalesforceDoTheRest;
			}
		}

		if(flowRecordLookup.filters != null) {
			for(MetadataService.FlowRecordFilter filter : flowRecordLookup.filters) {
				result.conditions.add(new FlowDataStructures.FlowRecordFilterInfo(
					filter?.field,
					filter?.operator,
					String.valueOf(getFlowElementReferenceOrValue(filter?.value))
				));
			}

			result.conditionLogic = flowRecordLookup.filterLogic;
			if(result.conditionLogic == null) {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_EMPTY_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
			}
			else if(result.conditionLogic == 'and') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
			}
			else if(result.conditionLogic == 'or') {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
				result.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
			}
			else {
				result.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
				result.conditionName = flowRecordLookup.filterLogic;
				result.conditionLogic = flowRecordLookup.filterLogic;
			}
		}
		result.sortOrder = flowRecordLookup.sortOrder;
		result.sortBy = flowRecordLookup.sortField;

		if(flowRecordLookup.outputAssignments != null) {
			for(MetadataService.FlowOutputFieldAssignment outputFieldAssignment : flowRecordLookup.outputAssignments) {
				result.assignments.add(new FlowOutputFieldAssignmentInfo(
					outputFieldAssignment?.field,
					outputFieldAssignment?.assignToReference
				));
			}

			result.chooseFieldsAndAssignVariables = !flowRecordLookup.outputAssignments.isEmpty();
			result.storeAllFields = !result.chooseFieldsAndAssignVariables;
			result.storeSeparateVariables = true;
		}

		element.metadataInfo = result;
	}

	public class FlowDecisionInfo {
		public String name;
		public String label;
		public String description;
		public List<FlowDecisionOutcomeInfo> outcomes;

		public FlowDecisionInfo(){
			this.outcomes = new List<FlowDecisionOutcomeInfo>();
		}

	}

	public class FlowDecisionOutcomeInfo {
		public String label;
		public String name;
		public String description;
		public String condition;
		public String conditionLogic;
		public String conditionName;
		public String conditionLabel;
		public List<FlowConditionInfo> conditions;

		public FlowDecisionOutcomeInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
			this.conditions = new List<FlowConditionInfo>();
		}
	}

	public class FlowConditionInfo {
		public String resource;
		public String operator;
		public Object value;

		public FlowConditionInfo(String resource, String operator, Object value) {
			this.resource = resource;
			this.operator = Constants.FLOW.FLOW_COMPRASION_OPERATOR_MAPPING.get(operator);
			this.value = value;
		}
	}



	public static void addDecisionInfo(FlowDataStructures.FlowElement element, MetadataService.FlowDecision flowDecision) {
		FlowDecisionInfo result = new FlowDecisionInfo();
		result.name = flowDecision.name;
		result.label = flowDecision.label;
		result.description = flowDecision.description;

		if(flowDecision.rules != null) {
			for(MetadataService.FlowRule rule : flowDecision.rules) {
				FlowDecisionOutcomeInfo fdo = new FlowDecisionOutcomeInfo(rule?.label, rule?.name, rule?.description);

				fdo.condition = rule?.conditionLogic;
				if(rule.conditionLogic == null) {
					fdo.conditionLabel = Constants.FLOW.FLOW_CONDITION_EMPTY_LABEL;
					fdo.conditionName = Constants.FLOW.FLOW_CONDITION_EMPTY;
				}
				else if(rule.conditionLogic == 'and') {
					fdo.conditionLabel = Constants.FLOW.FLOW_CONDITION_AND_LABEL;
					fdo.conditionName = Constants.FLOW.FLOW_CONDITION_AND;
				}
				else if(rule.conditionLogic == 'or') {
					fdo.conditionLabel = Constants.FLOW.FLOW_CONDITION_OR_LABEL;
					fdo.conditionName = Constants.FLOW.FLOW_CONDITION_OR;
				}
				else {
					fdo.conditionLabel = Constants.FLOW.FLOW_CONDITION_CUSTOM_LABEL;
					fdo.conditionName = rule.conditionLogic;
					fdo.conditionLogic = rule.conditionLogic;
				}

				if(rule.conditions != null) {
					for(MetadataService.FlowCondition fc : rule.conditions) {
						FlowConditionInfo fci = new FlowConditionInfo(
							fc?.leftValueReference,
							fc?.operator,
							String.valueOf(getFlowElementReferenceOrValue(fc?.rightValue))
						);
						fdo.conditions.add(fci);
					}
				}

				result.outcomes.add(fdo);
			}
		}

		element.metadataInfo = result;
	}

	public class FlowScreenFieldInfo {
		public String name;
		public String extensionName;

		public FlowScreenFieldInfo(String name, String extensionName) {
			this.name = name;
			this.extensionName = extensionName;
		}
	}

	public class FlowScreenInfo {
		public String label;
		public String name;
		public String description;
		public Boolean showHeader;
		public Boolean showFooter;
		public Boolean nextOrFinish;
		public Boolean previous;
		public Boolean pause;
		public String helpText;
		public FlowScreenFieldInfo[] fields;

		public FlowScreenInfo(String label, String name, String description) {
			this.label = label;
			this.name = name;
			this.description = description;
		}
	}

	public static void addScreenInfo(FlowDataStructures.FlowElement element, MetadataService.FlowScreen flowScreen) {
		FlowScreenInfo result = new FlowScreenInfo(flowScreen.label, flowScreen.name, flowScreen.description);
		result.showHeader = flowScreen.showHeader;
		result.showFooter = flowScreen.showFooter;
		result.nextOrFinish = flowScreen.allowFinish;
		result.previous = flowScreen.allowBack;
		result.pause = flowScreen.allowPause;
		result.helpText = flowScreen.helpText;
		result.fields = new List<FlowScreenFieldInfo>();
		if (flowScreen.fields != null) {
			for(MetadataService.FlowScreenField f : flowScreen.fields) {
				FlowScreenFieldInfo screenInfo = new FlowScreenFieldInfo(
					f?.name,
					f?.extensionName
				);
				result.fields.add(screenInfo);
			}
		}
		element.metadataInfo = result;
	}

	public static void addAssignmentInfo(FlowDataStructures.FlowElement element, MetadataService.FlowAssignment flowAssignment) {
		FlowDataStructures.FlowAssignmentInfo result = new FlowDataStructures.FlowAssignmentInfo(flowAssignment.label, flowAssignment.name, flowAssignment.description);

		if(flowAssignment.assignmentItems != null) {
			for(MetadataService.FlowAssignmentItem fai : flowAssignment.assignmentItems) {
				result.assignments.add(new FlowDataStructures.FlowAssignmentsItemInfo(
					fai?.assignToReference,
					fai?.operator,
					String.valueOf(getFlowElementReferenceOrValue(fai?.value))
				));
			}
		}
		element.metadataInfo = result;
	}

	public static FlowDataStructures.FlowAiMeta getFlowAiMeta(String stacktrace) {
		FlowDataStructures.RawFlowData flowData = (FlowDataStructures.RawFlowData) JSON.deserialize(stacktrace, FlowDataStructures.RawFlowData.class);
		FlowDataStructures.FlowAiMeta result = new FlowDataStructures.FlowAiMeta();
		String errorNode;
		List<String> nodesAfterError = new List<String>();

		if (flowData.edges != null) {
			errorNode = getErrorNode(flowData.edges);
		}

		if (errorNode != null) {
			List<String> queue = getElementsQueue(flowData.edges, errorNode);
			for (String n : queue) {
				if (n != errorNode) {
					nodesAfterError.add(n);
				}
			}
		}

		result.errorNode = errorNode;
		result.nodesAfterError = nodesAfterError;

		return result;
	}

	public static String getErrorNode(Map<String, List<FlowDataStructures.RawEdge>> edges) {
		String resultTarget = null;
		Integer maxIndex = -1;

		for (String key : edges.keySet()) {
			List<FlowDataStructures.RawEdge> edgeList = edges.get(key);
			for (FlowDataStructures.RawEdge edge : edgeList) {
				if (edge.indexes != null && !edge.indexes.isEmpty()) {
					for (Integer index : edge.indexes) {
						if (index > maxIndex) {
							maxIndex = index;
							resultTarget = edge.target;
						}
					}
				}
			}
		}
		return resultTarget;
	}

	public static List<String> getElementsQueue(Map<String, List<FlowDataStructures.RawEdge>> edges, String startNode) {
		Map<String, List<String>> queueMap = new Map<String, List<String>>();
		Set<String> visited = new Set<String>();

		for (String edge : edges.keySet()) {
			List<String> targets = new List<String>();
			for (FlowDataStructures.RawEdge e : edges.get(edge)) {
				targets.add(e.target);
			}
			queueMap.put(edge, targets);
		}
		return getElementsFromNode(startNode, queueMap, visited);
	}

	public static List<String> getElementsFromNode(String node, Map<String, List<String>> queueMap, Set<String> visited) {
		if (visited.contains(node)) {
			return new List<String>();
		}
		List<String> result = new List<String>();
		result.add(node);
		visited.add(node);
		if (queueMap.containsKey(node)) {
			for (String target : queueMap.get(node)) {
				result.addAll(getElementsFromNode(target, queueMap, visited));
			}
		}
		return result;
	}
}