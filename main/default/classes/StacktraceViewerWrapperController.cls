public with sharing class StacktraceViewerWrapperController {

    public Log__c log { get; set; }
	public String packageNamespace { get {return ConfigUtil.getNameSpacePrefix();} set; }
	public Boolean isDev { get; set; }
	public Boolean isBlurMode { get; set; }
	public String stacktraceCvId { get; set; }
	public String stacktraceParseResultCvId { get; set; }

	public StacktraceViewerWrapperController(ApexPages.StandardController stdController) {
		this.log = [
			SELECT Id, Name, Flow_Link__c, Stacktrace__c, Stacktrace_Parse_Result__c, Type__c, Category__c,
			(SELECT Id, ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.PathOnClient FROM ContentDocumentLinks)
			FROM Log__c
			WHERE Id = :stdController.getId()
		];
		for(ContentDocumentLink cdl : log?.ContentDocumentLinks) {
			if(cdl?.ContentDocument?.LatestPublishedVersion?.PathOnClient == ErrorEmailHandler.STACK_TRACE_CV_NAME) {
				this.stacktraceCvId = cdl.ContentDocument.LatestPublishedVersion.Id;
			}
			if(cdl?.ContentDocument?.LatestPublishedVersion?.PathOnClient == ErrorEmailHandler.STACK_TRACE_PARSE_RESULT_CV_NAME) {
				this.stacktraceParseResultCvId = cdl.ContentDocument.LatestPublishedVersion.Id;
			}
		}

		isDev = ConfigUtil.initializeDevelopmentMode(ApexPages.currentPage());
		isBlurMode = !BlurModeService.isAvailableDebugView(this.log.Id);
	}
}