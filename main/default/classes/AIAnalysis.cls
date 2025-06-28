public with sharing class AIAnalysis {

	public List<AI_Event__e> events = new List<AI_Event__e>();
	public Map<String, Issue__c> issues = new Map<String, Issue__c>();
	public Map<String, AIAnalysisService> analysisServiceByIssueId = new Map<String, AIAnalysisService>();

	private String errorMessage;

	public static AIAnalysis getInstance(Object input) {
		System.debug('++++AIAnalysis.getInstance input: ' + JSON.serialize(input));
		System.debug('++++AIAnalysis instance already exists: ' + (instance != null));
		
		if (instance != null) {
			System.debug('++++AIAnalysis returning existing instance with issues: ' + instance.issues.keySet());
			System.debug('++++AIAnalysis existing instance events count: ' + (instance.events != null ? instance.events.size() : 0));
		}
		
		if (instance == null) {
			System.debug('++++AIAnalysis creating new instance');
			if (input instanceof Set<Id> || input instanceof Set<String>) {
				instance = new AIAnalysis((Set<String>)input);
			} else if (input instanceof List<AI_Event__e>) {
				instance = new AIAnalysis((List<AI_Event__e>)input);
			} else {
				throw new AIAnalysisException('Unsupported input type: ' + JSON.serialize(input));
			}
			System.debug('++++AIAnalysis new instance created with issues: ' + instance.issues.keySet());
		}
		return instance;
	}

	private static AIAnalysis instance = null;

	private AIAnalysis(Set<String> issueIds) {
		this.issues = getIssues(issueIds);
	}

	private AIAnalysis(List<AI_Event__e> events) {
		System.debug('++++AIAnalysis constructor called with events: ' + events.size());
		this.events = events;
		Set<String> issueIds = new Set<String>();
		for (AI_Event__e event : events) {
			System.debug('++++AIAnalysis processing event - Record_Id__c: ' + event.Record_Id__c + ', Analysis__c: ' + event.Analysis__c + ', Status__c: ' + event.Status__c);
			issueIds.add(event.Record_Id__c);
		}
		System.debug('++++AIAnalysis extracted issue IDs: ' + issueIds);
		this.issues = getIssues(issueIds);
		System.debug('++++AIAnalysis loaded issues: ' + this.issues.keySet());
	}

	public void init() {
		System.debug('++++AIAnalysis.init called');
		System.debug('++++AIAnalysis.init issues count: ' + issues.size());
		System.debug('++++AIAnalysis.init events count: ' + (events != null ? events.size() : 0));
		
		errorMessage = checkAnalysisPermission();
		System.debug('++++AIAnalysis.init permission check result: ' + errorMessage);
		
		if (String.isBlank(errorMessage)) {
			System.debug('++++AIAnalysis.init creating analysis services for issues: ' + issues.keySet());
			for (Issue__c issue : this.issues.values()) {
				this.analysisServiceByIssueId.put(issue.Id, new AIAnalysisService(issue));
			}
			System.debug('++++AIAnalysis.init created analysis services for: ' + analysisServiceByIssueId.keySet());
			
			if (events != null && !events.isEmpty()) {
				System.debug('++++AIAnalysis.init calling setContentDocumentId and setResult');
				setContentDocumentId();
				setResult();
			} else {
				System.debug('++++AIAnalysis.init no events to process');
			}
		} else {
			System.debug('++++AIAnalysis.init calling internalError due to permission issue');
			internalError();
		}
	}

	public void inProgress() {
		if (String.isNotBlank(errorMessage)) return;
		for (AIAnalysisService analysisService : analysisServiceByIssueId.values()) {
			analysisService.inProgress();
		}
	}

	public void analysis() {
		if (String.isNotBlank(errorMessage)) return;
		for (AIAnalysisService analysisService : analysisServiceByIssueId.values()) {
			analysisService.analysis();
		}
	}

	public void createContentVersions() {
		if (String.isNotBlank(errorMessage)) return;
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for (Issue__c issue : issues.values()) {
			for (String analysis : AIAnalysisService.ANALYSIS_MAP.keySet()) {
				ContentVersion contentVersion = analysisServiceByIssueId.get(issue.Id).createContentVersion(analysis);
				if (contentVersion != null) contentVersions.add(contentVersion);
			}
		}
		DatabaseUtils.getInstance().performUpsertDML(contentVersions, Schema.SObjectType.ContentVersion)
				.handleError(AIAnalysis.class.getName(), '.createContentVersions', Logger.getInstance());
		contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions AND IsLatest = TRUE];
		List<ContentDocumentLink> existContentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :issues.keySet()];
		List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
		for (Issue__c issue : issues.values()) {
			for (String analysis : AIAnalysisService.ANALYSIS_MAP.keySet()) {
				String title = getTitleString(issue.Name, analysis);
				for (ContentVersion contentVersion : contentVersions) {
					if (title == contentVersion.Title) {
						Boolean isExist = false;
						for (ContentDocumentLink contentDocumentLink : existContentDocumentLinks) {
							if (contentDocumentLink.ContentDocumentId == contentVersion.ContentDocumentId) {
								isExist = true;
								break;
							}
						}
						if (!isExist) {
							ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
							contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
							contentDocumentLink.LinkedEntityId = issue.Id;
							contentDocumentLink.ShareType = 'I';
							contentDocumentLinks.add(contentDocumentLink);
						}
					}
				}
			}
		}
		DatabaseUtils.getInstance().performInsertDML(contentDocumentLinks, Schema.SObjectType.ContentDocumentLink)
				.handleError(AIAnalysis.class.getName(), '.createContentVersions', Logger.getInstance());
	}

	public void flush() {
		if (String.isNotBlank(errorMessage)) return;
		for (AIAnalysisService analysisService : analysisServiceByIssueId.values()) {
			analysisService.issueStatus();
		}
		DatabaseUtils.getInstance().performUpdateDML(issues.values(), Schema.SObjectType.Issue__c)
				.handleError(AIAnalysis.class.getName(), '.flush', Logger.getInstance());
		Logger.getInstance().flush();
	}

	public static String checkAnalysisPermission() {
		String result;
		if (!PermissionsUtil.IssueAnalysisEnabled) {
			result = AIAnalysisService.ISSUE_ANALYSIS_DISABLED_MESSAGE;
		} else if (!ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c || String.isBlank(ConfigUtil.OPEN_AI_SETTINGS.Token__c)) {
			result = AIAnalysisService.CONFIGURE_OPEN_AI_SETTINGS_MESSAGE;
		}
		return result;
	}

	private static Map<String, Issue__c> getIssues(Set<String> issueIds) {
		return new Map<String, Issue__c>([
				SELECT
						Id,
						Name,
						Category__c,
						Functional_Area__c,
						First_Occurred_On__c,
						Last_Occurred_On__c,
						Impacted_Objects_Count__c,
						Impacted_Users_Count__c,
						Average_Frequency__c,
						Issue_Analysis__c,
						Analysis_Statuses_Details__c,
						Log__c,
						Log__r.Type__c,
						Log__r.Category__c,
						Log__r.Details__c,
						Log__r.Organization_Id__c,
						Log__r.Related_Objects__c,
						Log__r.Flow_API_Name__c,
						Log__r.Flow_Version__c,
						Log__r.Stacktrace_Parse_Result__c,
						Log__r.Stacktrace__c,
						Log__r.Setup_Audit_Trail__c
				FROM Issue__c
				WHERE Id IN :issueIds]);
	}

	private void setContentDocumentId() {
		Map<String, String> contentDocumentIdsByTitle = getContentDocumentIdsByTitle();
		for (Issue__c issue : this.issues.values()) {
			for (String analysis : AIAnalysisService.ANALYSIS_MAP.keySet()) {
				String title = getTitleString(issue.Name, analysis);
				if (contentDocumentIdsByTitle.containsKey(title)) {
					analysisServiceByIssueId.get(issue.Id).setContentDocumentId(analysis, contentDocumentIdsByTitle.get(title));
				}
			}
		}
	}

	private void setResult() {
		System.debug('++++AIAnalysis.setResult called with events count: ' + events.size());
		System.debug('++++AIAnalysis.setResult available analysis services for issues: ' + analysisServiceByIssueId.keySet());
		
		for (AI_Event__e event : events) {
			System.debug('++++AIAnalysis.setResult processing event - Record_Id__c: ' + event.Record_Id__c + ', Analysis__c: ' + event.Analysis__c + ', Status__c: ' + event.Status__c);
			System.debug('++++AIAnalysis.setResult checking if issue exists in analysis services: ' + analysisServiceByIssueId.containsKey(event.Record_Id__c));
			
			if (analysisServiceByIssueId.containsKey(event.Record_Id__c)) {
				try {
					analysisServiceByIssueId.get(event.Record_Id__c).setResult(event.Analysis__c, event.Status__c, event.Result__c);
					System.debug('++++AIAnalysis.setResult successfully set result for event');
				} catch (Exception e) {
					System.debug('++++AIAnalysis.setResult error setting result: ' + e.getMessage());
					System.debug('++++AIAnalysis.setResult error stack trace: ' + e.getStackTraceString());
				}
			} else {
				System.debug('++++AIAnalysis.setResult ERROR: Issue ' + event.Record_Id__c + ' not found in analysis services!');
				System.debug('++++AIAnalysis.setResult available issues: ' + analysisServiceByIssueId.keySet());
			}
		}
	}

	private Map<String, String> getContentDocumentIdsByTitle() {
		Map<String, String> contentDocumentIdsByTitle = new Map<String, String>();
		List<ContentDocumentLink> contentDocumentLinks = [
				SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title
				FROM ContentDocumentLink
				WHERE LinkedEntityId IN :issues.keySet()
		];
		for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
			contentDocumentIdsByTitle.put(contentDocumentLink.ContentDocument.Title, contentDocumentLink.ContentDocumentId);
		}
		return contentDocumentIdsByTitle;
	}

	public void setVersionData() {
		Set<String> titles = new Set<String>();
		for (Issue__c issue : issues.values()) {
			for (String analysis : AIAnalysisService.ANALYSIS_MAP.keySet()) {
				titles.add(getTitleString(issue.Name, analysis));
			}
		}
		List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :issues.keySet()];
		Set<String> contentDocumentIds = new Set<String>();
		for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
			contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
		}
		List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND Title IN :titles AND IsLatest = TRUE];
		for (Issue__c issue : issues.values()) {
			for (ContentVersion contentVersion : contentVersions) {
				if (contentVersion.Title.contains(issue.Name)) {
					analysisServiceByIssueId.get(issue.Id).setVersionData(contentVersion.Title.removeStart(issue.Name + '_'), contentVersion.VersionData.toString());
				}
			}
		}
	}

	public String getFormattedData(String issueId, String context) {
		String convertedData = '';
		for (String analysis : AIAnalysisService.ANALYSIS_MAP.keySet()) {
			String formattedData = getFormattedData(issueId, analysis, context);
			if (formattedData != null) {
				convertedData += formattedData;
			}
		}
		return convertedData;
	}

	public String getFormattedData(String issueId, String analysis, String context) {
		return analysisServiceByIssueId.get(issueId).getFormattedData(analysis, context);
	}

	public static String getTitleString(String issueName, String analysis) {
		return issueName + '_' + analysis;
	}

	public void internalError() {
		Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
		Logger.getInstance().add(LogBuilder.getInstance()
				.category(Logger.CATEGORY_PHAROS_ERROR)
				.summary(errorMessage)
				.details(errorMessage + '\n' + JSON.serialize(issues.keySet()))
				.area(Logger.AREA_PHAROS_ERROR)
				.type('Issue Analysis')
				.attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.name, corg?.Name)
				.attribute(Schema.SObjectType.Log__c.fields.Organization_Name__c.name, corg?.Title__c)
				.attribute(Schema.SObjectType.Log__c.fields.Organization_Url__c.name, corg?.Instance_Url__c)
				.attribute(Schema.SObjectType.Log__c.fields.Related_Objects__c.name, JSON.serialize(issues.keySet()))
				.attribute(Schema.SObjectType.Log__c.fields.Post_Processing_Settings__c.name, '["RO"]')
				.createIssue()
				.build());
	}

	public class AIAnalysisException extends Exception {}

}