public with sharing class AIAnalysisService {

	public enum Analysis {
		BASIC,
		CODE_EXPLAIN,
		FLOW,
		FLOW_EXPLAIN,
		AUDIT_TRAIL
	}

	private enum Category {
		APEX,
		ERROR,
		INTEGRATION,
		FLOW,
		PROCESS_BUILDER
	}

	private enum Status {
		NOT_STARTED,
		IN_PROGRESS,
		NOT_APPLICABLE,
		CONFIGURATION_REQUIRED,
		COMPLETED,
		FAILED,
		PENDING
	}

	public static final String BASIC_ANALYSIS = 'basic';
	public static final String CODE_EXPLAIN_ANALYSIS = 'code_explain';
	public static final String FLOW_ANALYSIS = 'flow';
	public static final String FLOW_EXPLAIN_ANALYSIS = 'flow_explain';
	public static final String AUDIT_TRAIL_ANALYSIS = 'audit_trail';

	public static final Map<String, Analysis> ANALYSIS_MAP = new Map<String, Analysis>{
			BASIC_ANALYSIS => Analysis.BASIC,
			CODE_EXPLAIN_ANALYSIS => Analysis.CODE_EXPLAIN,
			FLOW_ANALYSIS => Analysis.FLOW,
			FLOW_EXPLAIN_ANALYSIS => Analysis.FLOW_EXPLAIN,
			AUDIT_TRAIL_ANALYSIS => Analysis.AUDIT_TRAIL
	};

	public static final Map<String, String> ANALYSIS_TITLE_MAP = new Map<String, String>{
			BASIC_ANALYSIS => 'Basic Analysis',
			CODE_EXPLAIN_ANALYSIS => 'Code Explanation',
			FLOW_ANALYSIS => 'Process Analysis',
			FLOW_EXPLAIN_ANALYSIS => 'Flow Explanation',
			AUDIT_TRAIL_ANALYSIS => 'Change History Analysis'
	};

	private static final String APEX_CATEGORY = 'Apex';
	private static final String ERROR_CATEGORY = 'Error';
	private static final String INTEGRATION_CATEGORY = 'Integration';
	private static final String FLOW_CATEGORY = 'Flow';
	private static final String PROCESS_BUILDER_CATEGORY = 'Process Builder';

	private static final Map<String, Category> CATEGORY_MAP = new Map<String, Category>{
			APEX_CATEGORY => Category.APEX,
			ERROR_CATEGORY => Category.ERROR,
			INTEGRATION_CATEGORY => Category.INTEGRATION,
			FLOW_CATEGORY => Category.FLOW,
			PROCESS_BUILDER_CATEGORY => Category.PROCESS_BUILDER
	};

	public static final String NOT_STARTED_STATUS = 'Not Started';
	public static final String IN_PROGRESS_STATUS = 'In Progress';
	public static final String NOT_APPLICABLE_STATUS = 'Not Applicable';
	public static final String CONFIGURATION_REQUIRED_STATUS = 'Configuration Required';
	public static final String COMPLETED_STATUS = 'Completed';
	public static final String FAILED_STATUS = 'Failed';
	public static final String PENDING_STATUS = 'Pending';

	public static final String AWS_ERROR_STATUS = 'error';
	public static final Integer ANALYSIS_TIMEOUT_MIN = 30;

	private static final Set<String>  CODE_ANALYSIS_CATEGORIES = new Set<String> {APEX_CATEGORY, ERROR_CATEGORY, INTEGRATION_CATEGORY};
	private static final Set<String>  FLOW_ANALYSIS_CATEGORIES = new Set<String> {FLOW_CATEGORY, PROCESS_BUILDER_CATEGORY};

	// CONFIGURE NEEDED
	public static final String ISSUE_ANALYSIS_DISABLED_MESSAGE = 'Issue Analysis is not available for your org. For pricing and enablement please contact sales@pharos.ai.';
	public static final String CONFIGURE_OPEN_AI_SETTINGS_MESSAGE = 'To utilize Issue Analysis first configure the OpenAI settings under Pharos Admin -> Integrations -> OpenAI. To request an OpenAI token please reach out to success@pharos.ai';
	private static final String CONFIGURE_CHANGE_TRACKING_MESSAGE = 'Code and flow analysis requires Change Tracking feature to be enabled in Pharos Admin -> Change Tracking.  If that menu option is not available please contact success@pharos.ai for enablement.';

	private static final Map<String, Status> STATUS_MAP = new Map<String, Status>{
			NOT_STARTED_STATUS => Status.NOT_STARTED,
			IN_PROGRESS_STATUS => Status.IN_PROGRESS,
			NOT_APPLICABLE_STATUS => Status.NOT_APPLICABLE,
			CONFIGURATION_REQUIRED_STATUS => Status.CONFIGURATION_REQUIRED,
			COMPLETED_STATUS => Status.COMPLETED,
			FAILED_STATUS => Status.FAILED,
			PENDING_STATUS => Status.PENDING
	};

	private final Issue__c issue;
	private final Map<Analysis, AIAnalysisServiceInterface> strategies;

	public AIAnalysisService(Issue__c issue) {
		this.issue = issue;
		this.strategies = new Map<Analysis, AIAnalysisServiceInterface>();
		for (Analysis analysis : Analysis.values()) {
			this.strategies.put(analysis, getAIAnalysisServiceInterface(analysis, this.issue));
		}
	}

	public void inProgress() {
		for (AIAnalysisServiceInterface strategy : this.strategies.values()) {
			strategy.inProgress();
		}
	}

	public void analysis() {
		for (AIAnalysisServiceInterface strategy : this.strategies.values()) {
			strategy.analysis();
		}
	}

	public void issueStatus() {
		List<AnalysisStatusDetails> analysisStatusesDetails = new List<AnalysisStatusDetails>();
		issue.Analysis_Status__c = NOT_STARTED_STATUS;
		for (AIAnalysisServiceInterface strategy : this.strategies.values()) {
			AnalysisStatusDetails analysisStatusDetails = strategy.getAnalysisStatusDetails();
			if (analysisStatusDetails.status == IN_PROGRESS_STATUS) issue.Analysis_Status__c = IN_PROGRESS_STATUS;
			if (issue.Analysis_Status__c != IN_PROGRESS_STATUS
					&& analysisStatusDetails.status == COMPLETED_STATUS) issue.Analysis_Status__c = COMPLETED_STATUS;
			if (issue.Analysis_Status__c != IN_PROGRESS_STATUS
					&& issue.Analysis_Status__c != COMPLETED_STATUS
					&& analysisStatusDetails.status == FAILED_STATUS) issue.Analysis_Status__c = FAILED_STATUS;
			analysisStatusesDetails.add(analysisStatusDetails);
		}
		issue.Analysis_Statuses_Details__c = JSON.serialize(analysisStatusesDetails);
	}

	public void setContentDocumentId(String analysis, String contentDocumentId) {
		this.strategies.get(ANALYSIS_MAP.get(analysis)).setContentDocumentId(contentDocumentId);
	}

	public void setResult(String analysis, String status, String result) {
		this.strategies.get(ANALYSIS_MAP.get(analysis)).setResult(status, result);
	}

	public ContentVersion createContentVersion(String analysis) {
		return this.strategies.get(ANALYSIS_MAP.get(analysis)).createContentVersion();
	}

	public void setVersionData(String analysis, String versionData) {
		this.strategies.get(ANALYSIS_MAP.get(analysis)).setVersionData(versionData);
	}

	public String getFormattedData(String analysis, String context) {
		System.debug('++++++getFormattedData args: ' + analysis + context);
		return this.strategies.get(ANALYSIS_MAP.get(analysis)).getFormattedData(context);
	}

	public interface AIAnalysisServiceInterface {
		void inProgress();
		void analysis();
		void changeStatus(String status, String message);
		void setContentDocumentId(String contentDocumentId);
		void setResult(String status, String result);
		void setVersionData(String versionData);
		ContentVersion createContentVersion();
		AnalysisStatusDetails getAnalysisStatusDetails();
		String getFormattedData(String context);
	}

	public abstract class AIAnalysisServiceAbstract implements AIAnalysisServiceInterface {
		private final Analysis analysis;
		private final Issue__c issue;
		private AnalysisStatusDetails analysisStatusDetails;
		private String result;
		private String contentDocumentId;
		private String versionData;
		public AIAnalysisServiceAbstract(String analysis, Issue__c issue) {
			this.analysis = ANALYSIS_MAP.get(analysis);
			this.issue = issue;
			if (String.isNotBlank(this.issue.Analysis_Statuses_Details__c)) {
				List<AnalysisStatusDetails> analysisStatusesDetails = new List<AnalysisStatusDetails>();
				try {
					analysisStatusesDetails = (List<AnalysisStatusDetails>)JSON.deserialize(this.issue.Analysis_Statuses_Details__c, List<AnalysisStatusDetails>.class);
				} catch (JSONException e) {
					// catch JSON deserialize issue
				}
				AnalysisStatusDetails analysisStatusDetails;
				for (AnalysisStatusDetails asd : analysisStatusesDetails) {
					if (asd.analysis == String.valueOf(analysis)) {
						analysisStatusDetails = asd;
						break;
					}
				}
				this.analysisStatusDetails = analysisStatusDetails;
			}
			if (this.analysisStatusDetails == null) {
				this.analysisStatusDetails = new AnalysisStatusDetails();
				this.analysisStatusDetails.analysis = analysis;
				changeStatus(NOT_STARTED_STATUS);
			}
			if (this.analysisStatusDetails.status == CONFIGURATION_REQUIRED_STATUS || this.analysisStatusDetails.status == NOT_APPLICABLE_STATUS) {
				changeStatus(NOT_STARTED_STATUS);
			}
			// CONFIGURATION_REQUIRED
			if (!PermissionsUtil.IssueAnalysisEnabled) {
				changeStatus(CONFIGURATION_REQUIRED_STATUS, ISSUE_ANALYSIS_DISABLED_MESSAGE);
			}
			if (!ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c || String.isBlank(ConfigUtil.OPEN_AI_SETTINGS.Token__c)) {
				changeStatus(CONFIGURATION_REQUIRED_STATUS, CONFIGURE_OPEN_AI_SETTINGS_MESSAGE);
			}
		}
		public virtual void changeStatus(String status) {
			analysisStatusDetails.status = status;
		}
		public virtual void changeStatus(String status, String message) {
			analysisStatusDetails.status = status;
			analysisStatusDetails.message = message;
		}
		public virtual void setLastAnalysisTimestamp() {
			analysisStatusDetails.lastAnalysisTimestamp = System.now().getTime();
		}
		public virtual void inProgress() {
			if (analysisStatusDetails.status == IN_PROGRESS_STATUS && !isTimeoutOver()) {
				changeStatus(PENDING_STATUS);
			} else if (analysisStatusDetails.status == NOT_STARTED_STATUS
					|| analysisStatusDetails.status == COMPLETED_STATUS
					|| analysisStatusDetails.status == FAILED_STATUS
					|| (analysisStatusDetails.status == IN_PROGRESS_STATUS && isTimeoutOver())
					|| (analysisStatusDetails.status == PENDING_STATUS && isTimeoutOver())
			) {
				changeStatus(IN_PROGRESS_STATUS);
				setLastAnalysisTimestamp();
			}
		}
		public virtual void analysis() {
			if (analysisStatusDetails.status == IN_PROGRESS_STATUS) {
				RequestInterface requestInterface = getRequestInterface(analysis, issue);
				requestInterface.startAnalysis();
			}
		}
		public virtual Boolean isTimeoutOver() {
			return analysisStatusDetails.lastAnalysisTimestamp == null || ((System.now().getTime() - analysisStatusDetails.lastAnalysisTimestamp) / 1000 / 60 >= ANALYSIS_TIMEOUT_MIN);
		}
		public virtual AnalysisStatusDetails getAnalysisStatusDetails() {
			return analysisStatusDetails;
		}
		public virtual void setContentDocumentId(String contentDocumentId) {
			this.contentDocumentId = contentDocumentId;
		}
		public virtual void setResult(String status, String result) {
			if (status == AWS_ERROR_STATUS) {
				changeStatus(FAILED_STATUS, result);
			} else {
				this.result = result;
			}
		}
		public virtual void setVersionData(String versionData) {
			this.versionData = versionData;
		}
		public virtual String getFormattedData(String context) {
			if (versionData != null && analysisStatusDetails.status == COMPLETED_STATUS) {
				try {
					ResponseInterface responseInterface = getResponseInterface(analysis, versionData);
					responseInterface.setContext(context);
					return responseInterface.getFormattedData();
				} catch (JSONException e) {
				}
			}
			return null;
		}
		public virtual ContentVersion createContentVersion() {
			ContentVersion contentVersion;
			if (String.isNotBlank(result)) {
				changeStatus(COMPLETED_STATUS, null);
				String title = AIAnalysis.getTitleString(issue.Name, analysisStatusDetails.analysis);
				contentVersion = new ContentVersion();
				if (String.isNotBlank(contentDocumentId)) contentVersion.ContentDocumentId = contentDocumentId;
				contentVersion.PathOnClient = title + '.json';
				contentVersion.VersionData = Blob.valueOf(result);
				contentVersion.Description = title;
				contentVersion.ContentLocation = 'S';
				contentVersion.IsMajorVersion = true;
			}
			return contentVersion;
		}
	}

	// APEX ABSTRACT
	public abstract class ApexAIAnalysisServiceAbstract extends AIAnalysisServiceAbstract {
		public ApexAIAnalysisServiceAbstract(String analysis, Issue__c issue) {
			super(analysis, issue);
			// APPLICABLE
			if (CODE_ANALYSIS_CATEGORIES.contains(issue.Category__c)) {
				// CONFIGURATION_REQUIRED
				if (!ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c) {
					changeStatus(CONFIGURATION_REQUIRED_STATUS, CONFIGURE_CHANGE_TRACKING_MESSAGE);
				}
			} else {
				changeStatus(NOT_APPLICABLE_STATUS, null);
			}
		}
	}

	// FLOW ABSTRACT
	public abstract class FlowAIAnalysisServiceAbstract extends AIAnalysisServiceAbstract {
		public FlowAIAnalysisServiceAbstract(String analysis, Issue__c issue) {
			super(analysis, issue);
			// APPLICABLE
			if (!FLOW_ANALYSIS_CATEGORIES.contains(issue.Category__c)) {
				changeStatus(NOT_APPLICABLE_STATUS, null);
			}
		}
	}

	// BASIC
	public class BasicAIAnalysisService extends AIAnalysisServiceAbstract {
		public BasicAIAnalysisService(String analysis, Issue__c issue) {
			super(analysis, issue);
		}
	}

	// CODE_EXPLAIN
	public class CodeExplainAIAnalysisService extends ApexAIAnalysisServiceAbstract {
		public CodeExplainAIAnalysisService(String analysis, Issue__c issue) {
			super(analysis, issue);
		}
	}

	// FLOW
	public class FlowAIAnalysisService extends FlowAIAnalysisServiceAbstract {
		public FlowAIAnalysisService(String analysis, Issue__c issue) {
			super(analysis, issue);
		}
	}

	// FLOW_EXPLAIN
	public class FlowExplainAIAnalysisService extends FlowAIAnalysisServiceAbstract {
		public FlowExplainAIAnalysisService(String analysis, Issue__c issue) {
			super(analysis, issue);
		}
	}

	// AUDIT_TRAIL
	public class AuditTrailAIAnalysisService extends AIAnalysisServiceAbstract {
		public AuditTrailAIAnalysisService(String analysis, Issue__c issue) {
			super(analysis, issue);
			if (String.isBlank(issue.Log__r.Setup_Audit_Trail__c)) {
				changeStatus(NOT_APPLICABLE_STATUS, null);
			}
			if (CODE_ANALYSIS_CATEGORIES.contains(issue.Category__c)) {
				// CONFIGURATION_REQUIRED
				if (!ConfigUtil.CHANGE_TRACKING_SETTINGS.Git_Change_Tracking__c) {
					changeStatus(CONFIGURATION_REQUIRED_STATUS, CONFIGURE_CHANGE_TRACKING_MESSAGE);
				}
			}
		}
	}

	public class AnalysisStatusDetails {
		public String analysis;
		public String status;
		public String message;
		public Long lastAnalysisTimestamp;
	}

	private static AIAnalysisServiceInterface getAIAnalysisServiceInterface(Analysis analysis, Issue__c issue) {
		switch on analysis {
			when BASIC {
				return new BasicAIAnalysisService(BASIC_ANALYSIS, issue);
			}
			when CODE_EXPLAIN {
				return new CodeExplainAIAnalysisService(CODE_EXPLAIN_ANALYSIS, issue);
			}
			when FLOW {
				return new FlowAIAnalysisService(FLOW_ANALYSIS, issue);
			}
			when FLOW_EXPLAIN {
				return new FlowExplainAIAnalysisService(FLOW_EXPLAIN_ANALYSIS, issue);
			}
			when AUDIT_TRAIL {
				return new AuditTrailAIAnalysisService(AUDIT_TRAIL_ANALYSIS, issue);
			}
			when else {
				return null;
			}
		}
	}

	public static final String AI_ANALYSIS_ENDPOINT = 'https://ai.pharos.ai/ai_pharos_ai';

	public static final String OPEN_AI_MODEL = 'o3';

	public interface RequestInterface {
		void startAnalysis();
	}

	public abstract class RequestAbstract implements RequestInterface {
		public String method;
		public String recordId;
		public String logOrgId;
		public String openAiApiKey;
		public String openAiModel;
		public String ns;
		public String instance;
		public String session;
		public Datetime logDate;
		public RequestAbstract(Issue__c issue) {
			this.recordId = issue.Id;
			this.logOrgId = issue.Log__r.Organization_Id__c;
			this.openAiApiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
			this.openAiModel = OPEN_AI_MODEL;
			this.ns = ConfigUtil.nameSpacePrefix; // 'pharos__';
			this.instance = System.Url.getOrgDomainUrl().toExternalForm();
			this.session = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
			this.logDate = issue.First_Occurred_On__c;
		}
		public virtual void startAnalysis() {
			try {
				HttpUtils.post(
						AI_ANALYSIS_ENDPOINT,
						JSON.serialize(this),
						HttpUtils.getHeadersContentTypeJSON(),
						200
				);
			}
			catch(Exception e) {
				Logger.getInstance().addInternalError(e, AIAnalysis.class.getName(), 'startAnalysis');
			}
		}
	}

	public class BasicAnalysisRequest extends RequestAbstract {
		public Issue__c issue;
		public BasicAnalysisRequest(Issue__c issue) {
			super(issue);
			this.method = AIAnalysisService.BASIC_ANALYSIS;
			this.issue = issue;
		}
	}

	public class CodeExplainRequest extends RequestAbstract {
		public String logRelatedObjects;
		public String gitApiKey;
		public String gitRepo;
		public String gitOwner;
		public String gitBranch;
		public CodeExplainRequest(Issue__c issue) {
			super(issue);
			this.method = AIAnalysisService.CODE_EXPLAIN_ANALYSIS;
			this.logRelatedObjects = issue.Log__r.Related_Objects__c;
			this.gitApiKey = (String.isBlank(ConfigUtil.GIT_API_SETTINGS.Token__c))
					? ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c
					: ConfigUtil.GIT_API_SETTINGS.Token__c;
			this.gitRepo = GitHubUtils.GIT_REPONAME;
			this.gitOwner = GitHubUtils.GIT_USERNAME;
			this.gitBranch = GitHubUtils.GIT_API_DEFAULT_BASE_BRANCH_REF;
		}
	}

	public class FlowAnalysisRequest extends RequestAbstract {
		public String flowApiName;
		public String flowVersion;
		public String flowErrorNode;
		public String flowNodesAfterError;
		public FlowAnalysisRequest(Issue__c issue) {
			super(issue);
			this.method = AIAnalysisService.FLOW_ANALYSIS;
			this.flowApiName = issue.Log__r.Flow_API_Name__c;
			this.flowVersion = issue.Log__r.Flow_Version__c;
			if (String.isNotBlank(issue.Log__r.Stacktrace_Parse_Result__c)) {
				FlowService.FlowAiMeta flowAiMeta = FlowService.getFlowAiMeta(issue.Log__r.Stacktrace_Parse_Result__c);
				this.flowErrorNode = flowAiMeta.errorNode;
				this.flowNodesAfterError = JSON.serialize(flowAiMeta.nodesAfterError);
			}
		}
	}

	public class FlowExplainAnalysisRequest extends RequestAbstract {
		public String flowApiName;
		public String flowVersion;
		public FlowExplainAnalysisRequest(Issue__c issue) {
			super(issue);
			this.method = AIAnalysisService.FLOW_EXPLAIN_ANALYSIS;
			this.flowApiName = issue.Log__r.Flow_API_Name__c;
			this.flowVersion = issue.Log__r.Flow_Version__c;
		}
	}

	public class AuditTrailAnalysisRequest extends RequestAbstract {
		public String auditTrail;
		public String logCategory;
		public String flowApiName;
		public String flowVersion;
		public String logRelatedObjects;
		public String gitApiKey;
		public String gitRepo;
		public String gitOwner;
		public String gitBranch;
		public AuditTrailAnalysisRequest(Issue__c issue) {
			super(issue);
			this.method = AIAnalysisService.AUDIT_TRAIL_ANALYSIS;
			this.auditTrail = issue.Log__r.Setup_Audit_Trail__c;
			this.logCategory = issue.Log__r.Category__c;
			if (this.logCategory == 'Flow') {
				this.flowApiName = issue.Log__r.Flow_API_Name__c;
				this.flowVersion = issue.Log__r.Flow_Version__c;
			} else {
				this.logRelatedObjects = issue.Log__r.Related_Objects__c;
				this.gitApiKey = (String.isBlank(ConfigUtil.GIT_API_SETTINGS.Token__c))
						? ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c
						: ConfigUtil.GIT_API_SETTINGS.Token__c;
				this.gitRepo = GitHubUtils.GIT_REPONAME;
				this.gitOwner = GitHubUtils.GIT_USERNAME;
				this.gitBranch = GitHubUtils.GIT_API_DEFAULT_BASE_BRANCH_REF;
			}
		}
	}

	private static RequestInterface getRequestInterface(Analysis analysis, Issue__c issue) {
		switch on analysis {
			when BASIC {
				return new BasicAnalysisRequest(issue);
			}
			when CODE_EXPLAIN {
				return new CodeExplainRequest(issue);
			}
			when FLOW {
				return new FlowAnalysisRequest(issue);
			}
			when FLOW_EXPLAIN {
				return new FlowExplainAnalysisRequest(issue);
			}
			when AUDIT_TRAIL {
				return new AuditTrailAnalysisRequest(issue);
			}
			when else {
				return null;
			}
		}
	}

	public interface ContextFormatterInterface {
		String formatTitle(String title);
		String formatText(String text);
		String formatCode(String code);
		String formatOptions(List<String> options);
		String formatTable(List<AuditTrailAnalysisResult> rows);
	}

	public abstract class ContextFormatterAbstract implements ContextFormatterInterface {

		public virtual String formatTitle(String title) {
			return '<br><h3>' + title + '</h3>';
		}

		public virtual String formatText(String text) {
			return '<p>' + replaceParagraphTag(text) + '</p>\n';
		}

		public virtual String formatCode(String code) {
			return '<code><pre>' + replaceBackticks(code) + '</pre></code>\n';
		}

		public virtual String formatOptions(List<String> options) {
			String formattedOptions = '<ul>';
			for (String option : options) {
				formattedOptions += '<li><p>' + option + '</p></li>';
			}
			formattedOptions += '</ul>';
			return formattedOptions + '\n';
		}

		public virtual String formatTable(List<AuditTrailAnalysisResult> rows) {
			String table = '<br><table style="width: 100%">';
			table += '<thead>' +
					'<tr>' +
					'<th scope="col">ACTION</th>' +
					'<th scope="col">SECTION</th>' +
					'<th scope="col">CREATED&nbsp;BY</th>' +
					'<th scope="col">CREATED&nbsp;DATE</th>' +
					'</tr>' +
					'</thead>';
			table += '<tbody>';
			for (AuditTrailAnalysisResult auditTrailAnalysisResult : rows) {
				table += '<tr style="border-top: 1px solid #e5e5e5; border-bottom: 1px solid #e5e5e5;">' +
						'<td style="white-space: normal">' + auditTrailAnalysisResult.display?.trim() + '</td>' +
						'<td>' + auditTrailAnalysisResult.section?.trim().replaceAll(' ', '&nbsp;') + '</td>' +
						'<td>' + auditTrailAnalysisResult.userName?.trim().replaceAll(' ', '&nbsp;') + '</td>' +
						'<td>' + auditTrailAnalysisResult.createdDate?.trim() + '</td>' +
						'</tr>';
			}
			table += '</tbody>';
			table += '</table>';
			return table;
		}

		public virtual String replaceBackticks(String code) {
			return code.replaceAll('```apex', '').replaceAll('```', '').trim() + '\n';
		}

		public virtual String replaceParagraphTag(String text) {
			return text.replaceAll('<p>', '').replaceAll('</p>', '');
		}

		public virtual String replaceHTMLTags(String text) {
			return text.replaceAll('<br>', '')
					.replaceAll('<p>', '').replaceAll('</p>', '')
					.replaceAll('<strong>', '*').replaceAll('</strong>', '*')
					.replaceAll('<b>', '*').replaceAll('</b>', '*')
					.replaceAll('<em>', '_').replaceAll('</em>', '_')
					.replaceAll('<ul>', '').replaceAll('</ul>', '')
					.replaceAll('<ol>', '').replaceAll('</ol>', '')
					.replaceAll('&nbsp;', ' ').replaceAll('&quot;', '"')
					.replaceAll('&laquo;', '"').replaceAll('&raquo;', '"');
		}

		public virtual String formatSlackRow(AuditTrailAnalysisResult row) {
			return 'Action: ' + row.display + '\n' +
					'Section: ' + row.section + '\n' +
					'Created By: ' + row.userName + '\n' +
					'Created Date: ' + row.createdDate + '\n' +
					'\n';
		}

	}

	public class LwcContextFormatter extends ContextFormatterAbstract {
	}

	public class AzureDevOpsContextFormatter extends ContextFormatterAbstract {
	}

	public class TeamsContextFormatter extends ContextFormatterAbstract {
	}

	public class JiraContextFormatter extends ContextFormatterAbstract {

		public override String formatTitle(String title) {
			return '\nh3. ' + title + '\n';
		}

		public override String formatText(String text) {
			return replaceHTMLTags(text)
					.replaceAll('<code>', '{{').replaceAll('</code>', '}}')
					.replaceAll('<li>', '\n * ').replaceAll('</li>', '') + '\n';
		}

		public override String formatCode(String code) {
			return '{code:borderStyle=solid}\n' +
					replaceBackticks(code) +
					'{code}\n';
		}

		public override String formatOptions(List<String> options) {
			String formattedOptions = '';
			for (String option : options) {
				formattedOptions += '* ' + formatText(option) + '\n';
			}
			return formattedOptions + '\n';
		}

		public override String formatTable(List<AuditTrailAnalysisResult> rows) {
			String table = '\n||ACTION||SECTION||CREATED BY||CREATED DATE||';
			for (AuditTrailAnalysisResult auditTrailAnalysisResult : rows) {
				table += tableRowMarkdown(auditTrailAnalysisResult);
			}
			return table + '\n';
		}

		public String tableRowMarkdown(AuditTrailAnalysisResult auditTrailAnalysisResult) {
			return '\n| ' + auditTrailAnalysisResult.display + ' | ' + auditTrailAnalysisResult.section + ' | ' + auditTrailAnalysisResult.userName + ' | ' + auditTrailAnalysisResult.createdDate + ' |';
		}

	}

	public class SlackContextFormatter extends ContextFormatterAbstract {

		public override String formatTitle(String title) {
			return '\n*' + title + '*\n';
		}

		public override String formatText(String text) {
			return replaceHTMLTags(text)
					.replaceAll('<code>', '`').replaceAll('</code>', '`')
					.replaceAll('<li>', '\n - ').replaceAll('</li>', '') + '\n';
		}

		public override String formatCode(String code) {
			return '```\n' +
					replaceBackticks(code) +
					'```\n';
		}

		public override String formatOptions(List<String> options) {
			String formattedOptions = '';
			for (String option : options) {
				formattedOptions += '- ' + formatText(option);
			}
			return formattedOptions + '\n';
		}

		public override String formatTable(List<AuditTrailAnalysisResult> rows) {
			String message = '';
			for (AuditTrailAnalysisResult row : rows) {
				message += formatSlackRow(row);
			}
			return '\n' + message + '\n';
		}

	}

	public class MarkdownContextFormatter extends ContextFormatterAbstract {

		public override String formatTitle(String title) {
			return '### ' + title + '\n';
		}

		public override String formatText(String text) {
			return replaceHTMLTags(text)
					.replaceAll('<code>', '`').replaceAll('</code>', '`')
					.replaceAll('<li>', '\n - ').replaceAll('</li>', '') + '\n';
		}

		public override String formatCode(String code) {
			return '```\n' +
					replaceBackticks(code) +
					'```\n';
		}

		public override String formatOptions(List<String> options) {
			String formattedOptions = '';
			for (String option : options) {
				formattedOptions += '- ' + formatText(option);
			}
			return formattedOptions + '\n';
		}

		public override String formatTable(List<AuditTrailAnalysisResult> rows) {
			String message = '';
			for (AuditTrailAnalysisResult row : rows) {
				message += formatSlackRow(row);
			}
			return '\n' + message + '\n';
		}

	}

	private static final Map<String, ContextFormatterInterface> FORMATTERS = new Map<String, ContextFormatterInterface>{
			'LWC' => new LwcContextFormatter(),
			'AZURE_DEV_OPS' => new AzureDevOpsContextFormatter(),
			'TEAMS' => new TeamsContextFormatter(),
			'JIRA' => new JiraContextFormatter(),
			'SLACK' => new SlackContextFormatter(),
			'MARKDOWN' => new MarkdownContextFormatter()
	};


	public interface ResponseInterface {
		void setContext(String context);
		String getFormattedData();
	}

	public abstract class ResponseAbstract implements ResponseInterface {
		public String context;
		public ContextFormatterInterface formatter;
		public virtual void setContext(String context) {
			this.context = context;
			this.formatter = FORMATTERS.get(this.context);
		}
		public virtual String getFormattedData() {
			return '';
		}
		public virtual String formatTitle(String title) {
			if (String.isBlank(title)) return '';
			return formatter.formatTitle(title);
		}

		public virtual String formatText(String text) {
			if (String.isBlank(text)) return '';
			return formatter.formatText(text);
		}

		public virtual String formatCode(String code) {
			if (String.isBlank(code)) return '';
			return formatter.formatCode(code);
		}

		public virtual String formatOptions(List<String> options) {
			if (options == null || options.isEmpty()) return '';
			return formatter.formatOptions(options);
		}

		public virtual String formatTable(List<AuditTrailAnalysisResult> rows) {
			if (rows == null || rows.isEmpty()) return '';
			return formatter.formatTable(rows);
		}

	}

	public class BasicAnalysisResponse extends ResponseAbstract {
		public String rootCauseAnalysis;
		public List<String> resolutionOptions;
		public String severityEstimate;
		public String justification;
		public override String getFormattedData() {
			String formattedData = '';
			formattedData += formatTitle('Problem Identification');
			formattedData += formatText(rootCauseAnalysis);
			formattedData += formatTitle('Recommended Solutions');
			formattedData += formatOptions(resolutionOptions);
			formattedData += formatTitle('Severity Level');
			formattedData += formatText(severityEstimate);
			formattedData += formatTitle('Severity Assessment Details');
			formattedData += formatText(justification);
			return formattedData;
		}
	}

	public class ExplainAnalysisResponse extends ResponseAbstract {
		public String title;
		public String summary;
		public String fixed_code;
		public String solution_description;
		public List<ExplainAnalysisSection> sections;
		public override String getFormattedData() {
			String formattedData = '';
			formattedData += formatTitle(title);
			if (String.isNotBlank(summary)) formattedData += formatText(summary);
			if (String.isNotBlank(fixed_code)) {
				formattedData += formatTitle('Fixed Code');
				formattedData += formatCode(fixed_code);
			}
			if (String.isNotBlank(solution_description)) {
				formattedData += formatTitle('Solution Description');
				formattedData += formatText(solution_description);
			}
			for (ExplainAnalysisSection section : sections) {
				formattedData += formatTitle(section.subtitle);
				formattedData += formatText(section.description);
			}
			return formattedData;
		}
	}

	public class AuditTrailAnalysisResponse extends ResponseAbstract {
		public String summary;
		public String relevance;
		public List<AuditTrailAnalysisResult> result;
		public override String getFormattedData() {
			String formattedData = '';
			formattedData += formatTitle('Change Impact Overview');
			formattedData += formatText(summary);
			formattedData += formatTitle('Change Significance');
			formattedData += formatText(relevance);
			formattedData += formatTable(result);
			return formattedData;
		}
	}

	public class ExplainAnalysisSection {
		public String subtitle;
		public String description;
	}

	public class AuditTrailAnalysisResult {
		public String id;
		public String action;
		public String createdDate;
		public String display;
		public String section;
		public String userName;
	}

	public static ResponseInterface getResponseInterface(Analysis analysis, String jsonData) {
		switch on analysis {
			when BASIC {
				return (BasicAnalysisResponse)JSON.deserialize(jsonData, BasicAnalysisResponse.class);
			}
			when CODE_EXPLAIN, FLOW, FLOW_EXPLAIN {
				return (ExplainAnalysisResponse)JSON.deserialize(jsonData, ExplainAnalysisResponse.class);
			}
			when AUDIT_TRAIL {
				return (AuditTrailAnalysisResponse)JSON.deserialize(jsonData, AuditTrailAnalysisResponse.class);
			}
			when else {
				return null;
			}
		}
	}

}