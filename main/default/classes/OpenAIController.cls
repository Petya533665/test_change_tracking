public with sharing class OpenAIController {

	@AuraEnabled
	public static String checkAnalysisPermission() {
		return AIAnalysis.checkAnalysisPermission();
	}

	@AuraEnabled
	public static List<AnalysisStatusDetails> startAnalysis(String recordId) {
		startAnalysis(new Set<String>{recordId});
		return getAnalysis(recordId);
	}

	public static String startAnalysis(Set<String> recordIds) {
		AIAnalysis analysis = AIAnalysis.getInstance(recordIds);
		if (analysis != null) {
			analysis.init();
			analysis.inProgress();
			analysis.flush();
		}
		AIAnalysisBatch instance = AIAnalysisBatch.getInstance();
		instance.startBatch();
		return instance.getJobId();
	}

	@AuraEnabled
	public static String getAnalysisMarkdown(String recordId) {
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails = fetchAnalysisStatuses(recordId);
		if (analysisStatusesDetails == null) {
			return null;
		}
		AIAnalysis analysis = initializeAnalysis(recordId);
		String result = '';
		for (String analysisKey : AIAnalysisService.ANALYSIS_MAP.keySet()) {
			for (AIAnalysisService.AnalysisStatusDetails analysisStatusDetails : analysisStatusesDetails) {
				if (analysisKey.equals(analysisStatusDetails.analysis)
						&& AIAnalysisService.COMPLETED_STATUS.equals(analysisStatusDetails.status)) {
					result += (analysis.getFormattedData(recordId, analysisStatusDetails.analysis, 'MARKDOWN')) + '\n';
				}
			}
		}
		return result.toString();
	}

	@AuraEnabled
	public static List<AnalysisStatusDetails> getAnalysis(String recordId) {
		List<AIAnalysisService.AnalysisStatusDetails> analysisStatusesDetails = fetchAnalysisStatuses(recordId);
		if (analysisStatusesDetails == null) {
			return null;
		}
		AIAnalysis analysis = initializeAnalysis(recordId);
		List<AnalysisStatusDetails> result = new List<AnalysisStatusDetails>();
		for (String analysisKey : AIAnalysisService.ANALYSIS_MAP.keySet()) {
			for (AIAnalysisService.AnalysisStatusDetails analysisStatusDetails : analysisStatusesDetails) {
				if (analysisKey.equals(analysisStatusDetails.analysis)) {
					AnalysisStatusDetails asd = new AnalysisStatusDetails();
					asd.analysis = analysisStatusDetails.analysis;
					asd.status = analysisStatusDetails.status;
					asd.message = analysisStatusDetails.message;
					asd.lastAnalysisTimestamp = analysisStatusDetails.lastAnalysisTimestamp;
					asd.timeout = asd.lastAnalysisTimestamp != null ? ((System.now().getTime() - asd.lastAnalysisTimestamp) / 1000 / 60) > 15 : true;
					asd.result = analysis.getFormattedData(recordId, analysisStatusDetails.analysis, 'LWC');
					result.add(asd);
				}
			}
		}
		return result;
	}

	private static List<AIAnalysisService.AnalysisStatusDetails> fetchAnalysisStatuses(String recordId) {
		List<Issue__c> issues = [SELECT Id, Name, Analysis_Statuses_Details__c FROM Issue__c WHERE Id = :recordId];
		if (issues.isEmpty() || String.isBlank(issues[0].Analysis_Statuses_Details__c)) {
			return null;
		}
		try {
			return (List<AIAnalysisService.AnalysisStatusDetails>) JSON.deserialize(
					issues[0].Analysis_Statuses_Details__c, List<AIAnalysisService.AnalysisStatusDetails>.class
			);
		} catch (JSONException e) {
			return null;
		}
	}

	private static AIAnalysis initializeAnalysis(String recordId) {
		AIAnalysis analysis = AIAnalysis.getInstance(new Set<String>{recordId});
		if (analysis != null) {
			analysis.init();
			analysis.setVersionData();
		}
		return analysis;
	}

	public class AnalysisStatusDetails {
		@AuraEnabled
		public String analysis;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String message;
		@AuraEnabled
		public Long lastAnalysisTimestamp;
		@AuraEnabled
		public Boolean timeout;
		@AuraEnabled
		public String result;
	}

}