public with sharing class AdminController {

    public Boolean isDev { get; set; }
    public String packageNamespace { get {return Configutil.getNameSpacePrefix();} set; }

    public static String baseUrl {
        get {return System.URL.getOrgDomainUrl().toExternalForm();}
        set;
    }

    public static String salesforceBaseUrl {
        get {return System.URL.getOrgDomainUrl().toExternalForm();}
        set;
    }

    public static String baseRemoteSiteSettings {
        get {return JSON.serialize(AdminService.defaultRemoteSiteSettings);}
        set;
    }

    public static String remoteSiteSettingsPayload {
        get {
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :Constants.STATIC_RESOURCE_SOBJECT.RESOURCE_NAME_METADATA_REMOTE_SITE_PAYLOAD LIMIT 1];
            return sr.Body.toString();
        }
        set;
    }

    public static String blurModeUrlParameter {
        get {return BlurModeService.getEncryptedUrlParameter();}
        set;
    }

    public static Id getOrgId() {
        return UserInfo.getOrganizationId();
    }

    public Integer userTimezoneOffset {
        get {
            return AdminService.getUserTimezoneOffset();
        }
        set;
    }

    public static String getAdminPageInitEvent() {
        AnalyticsService.getInstance().trackAdminPageView(UserInfo.getOrganizationId());
        return 'success';
    }

    public AdminController() {
        String isDevParam = ApexPages.currentPage().getParameters().get('dev')?.escapeHtml4();
        if (String.isNotBlank(isDevParam)) {
            Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
            isDev = Boolean.valueOf(isDevParam);
        } else {
            Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
            isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
        }
    }

    @RemoteAction
    public static String remoteActionHandler(String input) {
        String result;
        RemoteActionResponse response = new RemoteActionResponse();
        String methodName;

        try {
            Map<String, Object> request = (Map<String, Object> )JSON.deserializeUntyped(input);
            response.params = request;

            String method = (String)request.get('method');
            methodName = method;
            Object data = request.get('data');
            if (method.equals('validateEmailServiceData')) {
                response.data = AdminService.validateEmailServiceData();
            } else if (method == 'getEmailServiceData') {
                response.data = AdminService.getEmailServiceData();
            } else if (method == 'createEmailService') {
                response.data = AdminService.createEmailService(data);
            } else if (method == 'getConfigurationOverviewData') {
                response.data = AdminService.getConfigurationOverviewData();
            } else if (method == 'getJiraSettings') {
                response.data = IntegrationSettings.JIRA.getJiraSettings();
            } else if (method == 'getAzureDevOpsSettings') {
                response.data = IntegrationSettings.AZURE_DEVOPS.getAzureDevOpsSettings();
            } else if (method == 'deleteConnectedOrg') {
                response.data = AdminService.deleteConnectedOrg(data);
            } else if (method == 'deleteFakeConnectedOrg') {
                response.data = AdminService.deleteFakeConnectedOrg();
            } else if (method == 'saveJiraSettings') {
                response.data = IntegrationSettings.JIRA.saveJiraSettings(data);
            } else if (method == 'saveAzureDevOpsSettings') {
                response.data = IntegrationSettings.AZURE_DEVOPS.saveAzureDevOpsSettings(data);
            } else if (method == 'resetJiraSettings') {
                response.data = IntegrationSettings.JIRA.resetJiraSettings();
            } else if (method == 'resetAzureDevOpsSettings') {
                response.data = IntegrationSettings.AZURE_DEVOPS.resetAzureDevOpsSettings();
            } else if (method == 'getJiraProjectUsers') {
                response.data = AdminService.getJiraProjectUsers(data);
            } else if (method == 'getJiraProjectComponents') {
                response.data = AdminService.getJiraProjectComponents(data);
            } else if (method == 'getJiraEpics') {
                response.data = AdminService.getJiraEpics(data);
            } else if (method == 'getJiraProject') {
                response.data = AdminService.getJiraProject(String.valueOf(data));
            } else if (method == 'getJiraProjectIssueTypes') {
                response.data = AdminService.getJiraProjectIssueTypes(String.valueOf(data));
            } else if (method == 'getAzureDevOpsProjects') {
                response.data = AzureService.getProjects();
            } else if (method == 'getAzureDevOpsProjectTeams') {
                response.data = AzureService.getProjectTeams(data);
            } else if (method == 'getAzureDevOpsWorkItemTypes') {
                response.data = AzureService.getWorkItemTypes(data);
            } else if (method == 'getOrganizationProjectProperties') {
                response.data = AzureService.getOrganizationProjectProperties(data);
            } else if (method == 'getOrganizationProcessesWorkItemTypes') {
                response.data = AzureService.getOrganizationProcessesWorkItemTypes(data);
            } else if (method == 'getOrganizationProcessWorkItemTypeFields') {
                response.data = AzureService.getOrganizationProcessWorkItemTypeFields(data);
            }  else if (method == 'getAzureDevOpsClassificationNodes') {
                response.data = AzureService.getClassificationNodes(data);
            }  else if (method == 'getAzureDevOpsEpicWorkItems') {
                response.data = AzureService.searchEpics(data);
            } else if (method == 'getAzureDevOpsProjectTeamMemberWrapper') {
                response.data = AzureService.getProjectTeamMemberWrapper(data);
            } else if (method == 'getTeamBoards') {
                response.data = AzureService.getTeamBoards(data);
            } else if (method == 'getAzureDevOpsWorkItemTypesWithValidation') {
                response.data = AzureService.getAzureDevOpsWorkItemTypesWithValidation(data);
            } else if (method == 'createConnectedApp') {
                response.data = AdminService.createConnectedApp(data);
            } else if (method == 'getMasks') {
                response.data = AdminService.getMasks();
            } else if (method == 'saveMask') {
                response.data = AdminService.saveMask(data);
            } else if (method == 'deleteMask') {
                response.data = AdminService.deleteMask(data);
            } else if (method == 'testMask') {
                response.data = AdminService.testMask(data);
            } else if (method == 'getLoggerWrapperInfo') {
                response.data = AdminService.getLoggerWrapperInfo();
            } else if (method == 'getSplunkSettings') {
                response.data = IntegrationSettings.SPLUNK.getSplunkSettings();
            } else if (method == 'saveSplunkSettings') {
                response.data = IntegrationSettings.SPLUNK.saveSplunkSettings(data);
            } else if (method == 'setSplunkSettings') {
                response.data = IntegrationSettings.SPLUNK.setSplunkSettings(data);
            } else if (method == 'validateSplunkEventCollectorConnection') {
                response.data = IntegrationSettings.SPLUNK.validateSplunkEventCollectorConnection(data);
            } else if (method == 'getOpenAISettings') {
                response.data = IntegrationSettings.OPEN_AI.getOpenAISettings();
            } else if (method == 'setOpenAISettings') {
                response.data = IntegrationSettings.OPEN_AI.setOpenAISettings(data);
            } else if (method == 'validateOpenAIToken') {
                response.data = IntegrationSettings.OPEN_AI.validateOpenAIToken(data);
            } else if (method == 'getCreateMeta') {
                response.data = AdminService.getCreateMeta(data);
            } else if (method == 'getConnectedOrgsInfo') {
                response.data = AdminService.getConnectedOrgsInfo();
            } else if (method == 'updatePassthroughtMode') {
                response.data = AdminService.updatePassthroughtMode(data);
            } else if (method == 'createConnectionOrg') {
                response.data = AdminService.createConnectionOrg(data);
            } else if (method == 'updateConnectedOrg') {
                response.data = AdminService.updateConnectedOrg(data);
            } else if (method == 'resetConnectedOrgOauth') {
                response.data = AdminService.resetConnectedOrgOauth(data);
            } else if (method == 'refreshConnectedOrgToken') {
                response.data = AdminService.refreshConnectedOrgToken(data);
            } else if (method == 'testConnectedOrg') {
                response.data = AdminService.testConnectedOrg(data);
            } else if (method == 'getSlackSettings') {
                response.data = IntegrationSettings.SLACK.getSlackSettings();
            } else if (method == 'getSlackChannels') {
                response.data = IntegrationSettings.SLACK.getSlackChannels(data);
            } else if (method == 'getSlackUsers') {
                response.data = IntegrationSettings.SLACK.getSlackUsers(data);
            } else if (method == 'saveSlackSettings') {
                response.data = IntegrationSettings.SLACK.saveSlackSettings(data);
            } else if (method == 'setMonitoringSetting') {
                response.data = AdminService.setMonitoringSetting(data);
            } else if (method == 'setLimitsMonitoringSetting') {
                response.data = AdminService.setLimitsMonitoringSetting(data);
            } else if (method == 'setEventMonitoringSetting') {
                response.data = AdminService.setEventMonitoringSetting(data);
            } else if (method == 'setBatchErrorTrackingSetting') {
                response.data = AdminService.setBatchErrorTrackingSetting(data);
            } else if (method == 'getBatchErrorTrackingSetting') {
                response.data = AdminService.getBatchErrorTrackingSetting(data);
            } else if (method == 'setErrorReportingOptOut') {
                response.data = AdminService.setErrorReportingOptOut(data);
            } else if (method == 'getErrorReportingOptOut') {
                response.data = AdminService.getErrorReportingOptOut();
            } else if (method == 'getPagerDutySettings') {
                response.data = IntegrationSettings.PAGER_DUTY.getPagerDutySettings();
            } else if (method == 'getPagerDutyServices') {
                response.data = IntegrationSettings.PAGER_DUTY.getPagerDutyServices();
            } else if (method == 'savePagerDutySettings') {
                response.data = IntegrationSettings.PAGER_DUTY.savePagerDutySettings(data);
            } else if (method == 'getLogCategories') {
                response.data = AdminService.getLogCategories();
            } else if (method == 'setLogRecordTypeMappings') {
                response.data = AdminService.setLogRecordTypeMappings(data);
            } else if (method == 'deleteLogRecordTypeMappings') {
                response.data = AdminService.deleteLogRecordTypeMappings(data);
            } else if (method == 'deleteRule') {
                response.data = AdminService.deleteRule(data);
            } else if (method == 'deleteRuleAction') {
                response.data = AdminService.deleteRuleAction(data);
            } else if (method == 'deleteAction') {
                response.data = AdminService.deleteAction(data);
            } else if (method == 'setArchivalSetting') {
                response.data = AdminService.setArchivalSetting(data);
            } else if (method == 'getDefaultMonitoringActionTemplate') {
                response.data = AdminService.getDefaultMonitoringActionTemplate();
            } else if (method == 'getTraceResultDefaultSlackActionTemplate') {
                response.data = AdminService.getTraceResultDefaultSlackActionTemplate();
            } else if (method == 'getTraceResultDefaultTeamsActionTemplate') {
                response.data = AdminService.getTraceResultDefaultTeamsActionTemplate();
            } else if (method == 'getDefaultEmailActionTemplate') {
                response.data = AdminService.getDefaultEmailActionTemplate();
            } else if (method == 'getIssueDefaultEmailActionTemplate') {
                response.data = AdminService.getIssueDefaultEmailActionTemplate();
            } else if (method == 'getDefaultSlackActionTemplate') {
                response.data = AdminService.getDefaultSlackActionTemplate();
            } else if (method == 'getDefaultAzureDevOpsActionTemplate') {
                response.data = AdminService.getDefaultAzureDevOpsActionTemplate();
            } else if (method == 'getDefaultJiraActionTemplate') {
                response.data = AdminService.getDefaultJiraActionTemplate();
            } else if (method == 'getIssueDefaultSlackActionTemplate') {
                response.data = AdminService.getIssueDefaultSlackActionTemplate();
            } else if (method == 'getIssueDefaultJiraActionTemplate') {
                response.data = AdminService.getIssueDefaultJiraActionTemplate();
            } else if (method == 'getIssueDefaultAzureDevOpsActionTemplate') {
                response.data = AdminService.getIssueDefaultAzureDevOpsActionTemplate();
            } else if (method == 'getOccurrenceLogs') {
                response.data = AdminService.getOccurrenceLogs(data);
            } else if (method == 'getAppPermissions') {
                response.data = AdminService.getAppPermissions(data);
            } else if (method == 'getSessionSettings') {
                response.data = AdminService.getSessionSettings();
            } else if (method == 'getInstalledVersion') {
                response.data = AdminService.getInstalledVersion();
            } else if (method == 'flowErrorTracking') {
                response.data = AdminService.flowErrorTracking(data);
            } else if (method == 'eventMonitoringTracking') {
                response.data = AdminService.eventMonitoringTracking(data);
            } else if (method == 'emailToCaseTracking') {
                response.data = AdminService.emailToCaseTracking(data);
            } else if (method == 'setupRemoteSiteSettings') {
                response.data = AdminService.setupRemoteSiteSettings();
            } else if (method == 'getMergeFields') {
                response.data = AdminService.getMergeFields();
            } else if (method == 'getRemoteSiteSettings') {
                response.data = AdminService.getRemoteSiteSettings();
            } else if (method == 'getSelfConnectedOrgsInfo') {
                response.data = AdminService.getSelfConnectedOrgsInfo();
            } else if (method == 'startTestExceptionEmail') {
                response.data = TestDataGenerator.sendTestEmailException();
            } else if (method == 'getTestEmailExceptionLog') {
                response.data = TestDataGenerator.getTestEmailExceptionLog();
            } else if (method == 'startPlatformEventTest') {
                response.data = TestDataGenerator.startPlatformEventTest();
            } else if (method == 'getPlatformEventTestLog') {
                response.data = TestDataGenerator.getPlatformEventTestLog();
            } else if (method == 'startPlatformAIEventTest') {
                response.data = TestDataGenerator.startPlatformAIEventTest();
            } else if (method.equals('getPlatformEventTestAIEventLog')) {
                response.data = TestDataGenerator.getPlatformEventTestAIEventLog();
            } else if (method == 'getQuickStartState') {
                response.data = AdminService.getQuickStartState();
            } else if (method == 'setQuickStartState') {
                response.data = AdminService.setQuickStartState(data);
            } else if (method == 'getUserInfo') {
                response.data = AdminService.getUserInfo();
            } else if (method == 'connectedAppSendMeAnEmail') {
                response.data = TestDataGenerator.connectedAppSendMeAnEmail();
            } else if (method == 'getPackageEmailServiceFunctionEmailAddress') {
                response.data = AdminService.getPackageEmailServiceFunctionEmailAddress();
            } else if (method == 'getQSAnotherConnectedOrg') {
                response.data = ConnectedOrgService.getQSAnotherConnectedOrg();
            } else if (method == 'isMyDomainEnabled') {
                response.data = AdminService.isMyDomainEnabled();
            } else if (method == 'createSelfConnectionOrg') {
                response.data = AdminService.createSelfConnectionOrg(data);
            } else if (method == 'createSelfConnectionOrgOauth') {
                response.data = AdminService.createSelfConnectionOrgOauth(data);
            } else if (method == 'getQSAnotherConnectedOrg') {
                response.data = ConnectedOrgService.getQSAnotherConnectedOrg();
            } else if (method == 'getUrlToPlatformEventSubscriberConfigLogEvent') {
                response.data = AdminService.getUrlToPlatformEventSubscriberConfigLogEvent();
            } else if (method.equals('getUrlToPlatformEventSubscriberConfigAIEvent')) {
                response.data = AdminService.getUrlToPlatformEventSubscriberConfigAIEvent();
            } else if (method == 'getAdminActiveUsers') {
                response.data = AdminService.getAdminActiveUsers();
            } else if (method == 'setPlatformEventSubscriberConfigLogEvent') {
                response.data = AdminService.setPlatformEventSubscriberConfigLogEvent(String.valueOf(data));
            } else if (method == 'setPlatformEventSubscriberConfigAIEvent') {
                response.data = AdminService.setPlatformEventSubscriberConfigAIEvent(String.valueOf(data));
            } else if (method == 'getPlatformEventSubscriberConfigLogEvent') {
                response.data = AdminService.getPlatformEventSubscriberConfigLogEvent();
            } else if (method == 'getPlatformEventSubscriberConfigAIEvent') {
                response.data = AdminService.getPlatformEventSubscriberConfigAIEvent();
            } else if (method == 'setActions') {
                response.data = AdminService.setActions(data);
            } else if (method == 'setRuleIndex') {
                response.data = AdminService.setRuleIndex(data);
            } else if (method == 'getRuleSettings') {
                response.data = AdminService.getRuleSettings(data);
            } else if (method == 'setRule') {
                response.data = AdminService.setRule(data);
            } else if (method == 'getScheduleBulkAPIBatch') {
                response.data = AdminService.getScheduleBulkAPIBatch();
            }  else if (method == 'abortScheduleBulkAPIBatch') {
                response.data = AdminService.abortScheduleBulkAPIBatch();
            }  else if (method == 'scheduleBulkAPIBatch') {
                response.data = AdminService.scheduleBulkAPIBatch(data);
            } else if (method == 'resetAllSettingsForRefreshSandbox') {
                response.data = AdminService.resetAllSettingsForRefreshSandbox();
            } else if (method == 'getSubscriptionInfo') {
                response.data = AdminService.getSubscriptionInfo();
            } else if (method == 'checkEmailAccess') {
                response.data = AdminService.checkEmailAccess();
            } else if (method == 'getIsAvailableSingleEmail') {
                response.data = AdminService.getIsAvailableSingleEmail();
            } else if (method == 'getTeamChannels') {
                response.data = IntegrationSettings.TEAMS.getTeamChannels(String.valueOf(data));
            } else if (method == 'getTeams') {
                response.data = IntegrationSettings.TEAMS.getTeams(String.valueOf(data));
            } else if (method == 'getTeamById') {
                response.data = IntegrationSettings.TEAMS.getTeamById(String.valueOf(data));
            } else if (method == 'getTeamsSettings') {
                response.data = IntegrationSettings.TEAMS.getTeamsSettings();
            } else if (method == 'setTeamsSettings') {
                response.data = IntegrationSettings.TEAMS.setTeamsSettings(data);
            } else if (method == 'setGitHubSettings') {
                response.data = IntegrationSettings.GIT_HUB.setGitHubSettings(data);
            } else if (method == 'getGitHubSettings') {
                response.data = IntegrationSettings.GIT_HUB.getGitHubSettings();
            } else if (method == 'resetGitHubSettings') {
                response.data = IntegrationSettings.GIT_HUB.resetGitHubSettings();
            } else if (method == 'validateGitHubConnection') {
                response.data = GitHubUtils.validateGitHubConnection(data);
            } else if (method == 'setChangeTrackingSettings') {
                response.data = AdminService.setChangeTrackingSettings(data);
            } else if (method == 'getChangeTrackingSettings') {
                response.data = AdminService.getChangeTrackingSettings();
            } else if (method == 'pushGitChanges') {
                response.data = AdminService.pushGitChanges();
            } else if (method == 'getDefaultTeamsActionTemplate') {
                response.data = AdminService.getDefaultTeamsActionTemplate();
            } else if (method == 'getIssueDefaultTeamsActionTemplate') {
                response.data = AdminService.getIssueDefaultTeamsActionTemplate();
            } else if (method == 'setSettingsForJiraSite') {
                response.data = LoggerSettingsController.setSettingsForJiraSite(data);
            } else if (method == 'setSettingsForAzureDevOpsAccount') {
                response.data = LoggerSettingsController.setSettingsForAzureDevOpsAccount(data);
            } else if (method == 'getJiraSites') {
                response.data = LoggerSettingsController.getJiraSites();
            } else if (method == 'getAzureDevOpsAccounts') {
                response.data = LoggerSettingsController.getAzureDevOpsAccounts();
            } else if (method == 'getDebugLogServiceSettings') {
                response.data = AdminService.getDebugLogServiceSettings();
            } else if (method == 'saveDebugLogServiceSettings') {
                response.data = AdminService.saveDebugLogServiceSettings(data);
            } else if (method == 'getIssueTicketCommentActionTemplate') {
                response.data = AdminService.getIssueTicketCommentActionTemplate();
            } else if (method == 'getDefaultWebhookActionTemplate') {
                response.data = AdminService.getDefaultWebhookActionTemplate();
            } else if (method == 'getIssueDefaultWebhookActionTemplate') {
                response.data = AdminService.getIssueDefaultWebhookActionTemplate();
            } else if (method == 'getIssueDefaultWebhookUpdateActionTemplate') {
                response.data = AdminService.getIssueDefaultWebhookUpdateActionTemplate();
            } else if (method == 'getDefaultMonitoringWebhookActionTemplate') {
                response.data = AdminService.getDefaultMonitoringWebhookActionTemplate();
            } else if (method == 'getTraceResultDefaultWebhookActionTemplate') {
                response.data = AdminService.getTraceResultDefaultWebhookActionTemplate();
            } else if (method == 'getFlowWithVersions') {
                response.data = AdminService.getFlowWithVersions();
            } else if (method == 'addFlowLogging') {
                response.data = AdminService.addFlowLogging(data);
            } else if (method == 'removeFlowLogging') {
                //response.data = AdminService.removeFlowLogging(data);
            } else if (method.equals('getPharosRunningUserWrapper')) {
                response.data = AdminService.getPharosRunningUserWrapper();
            } else if (method.equals('resetScheduleJobs')) {
                response.data = AdminService.resetScheduleJobs();
            } else if (method.equals('resetEmailAddressContextUser')) {
                response.data = AdminService.resetEmailAddressContextUser();
            } else if (method.equals('getEmailToCaseDefaultCaseUserData')) {
                response.data = AdminService.getEmailToCaseDefaultCaseUserData();
            } else if (method.equals('startErrorTrackingRequiresConfigurationTest')) {
                response.data = TestDataGenerator.startErrorTrackingRequiresConfigurationTest(data);
            } else if (method.equals('getErrorTrackingRequiresConfigurationLog')) {
                response.data = TestDataGenerator.getErrorTrackingRequiresConfigurationLog();
            } else if (method.equals('getRuleWizardData')) {
                response.data = RuleExportImportService.getRuleWizardData();
            } else if (method.equals('exportRules')) {
                response.data = RuleExportImportService.exportRules(
                    (List<String>)JSON.deserialize(JSON.serialize(data), List<String>.class)
                );
            }  else if (method.equals('exportRulesWithDownloadUrl')) {
                response.data = RuleExportImportService.exportRulesWithDownloadUrl(
                        (List<String>)JSON.deserialize(JSON.serialize(data), List<String>.class)
                );
            } else if (method.equals('importRules')) {
                response.data = RuleExportImportService.importRules((String)request.get('data'));
            } else if (method.equals('getMetadataChatSettings')) {
                response.data = AdminService.getMetadataChatSettings();
            } else if (method.equals('setupMetadataChatTrustedSite')) {
                response.data = AdminService.setupMetadataChatTrustedSite();
            } else if (method.equals('setupMetadataChatIndex')) {
                response.data = AdminService.setupMetadataChatIndex();
            } else if (method.equals('getAutoChartSetting')) {
                response.data = AutoChartController.getAutoChartSetting();
            } else if (method.equals('setAutoChartSetting')) {
                response.data = AutoChartController.updateAutoChartSetting((String)request.get('data'));
            } else if (method.equals('getForecastSetting')) {
                response.data = HoltwintersForecastController.getForecastSetting();
            } else if (method.equals('setForecastSetting')) {
                response.data = HoltwintersForecastController.updateForecastSetting((String)request.get('data'));
            } else {
                response.error = 'Action not found';
            }
        }
        catch(Exception e) {
            response.error = e.getMessage();
            response.stack = e.getStackTraceString();
            // don't log validation excpetions
            if (!e?.getTypeName()?.contains('AdminServiceValidationException') && !e?.getTypeName()?.contains('RuleUtilValidationException')) {
                Logger.getInstance().addInternalError(e, AdminController.class.getName(), 'remoteActionHandler' + (String.isNotBlank(methodName) ? '.' + methodName : ''));
            }
        }
        finally {
            try {
                result = JSON.serialize(response);
            }
            catch(Exception e) {
                Logger.getInstance().addInternalError(e, AdminController.class.getName(), 'remoteActionHandler.serializeResponse');
            }
            Logger.getInstance().flush();
        }
        return result;
    }

    public class RemoteActionResponse {
        public Object params;
        public Object data;
        public String error;
        public String stack;
    }
}