/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
public with sharing class MetadataService {
    public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';
    public class ReportTypeColumnTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class DomainWhitelist {
        public String[] domain;
        private String[] domain_type_info = new String[]{'domain',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'domain'};
    }
    public class LiveChatDeployment extends Metadata {
        public String type = 'LiveChatDeployment';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String brandingImage;
        public Integer connectionTimeoutDuration;
        public Integer connectionWarningDuration;
        public Boolean displayQueuePosition;
        public MetadataService.LiveChatDeploymentDomainWhitelist domainWhiteList;
        public Boolean enablePrechatApi;
        public Boolean enableTranscriptSave;
        public String label;
        public String mobileBrandingImage;
        public String site;
        public String windowTitle;
        private String[] brandingImage_type_info = new String[]{'brandingImage',SOAP_M_URI,null,'0','1','false'};
        private String[] connectionTimeoutDuration_type_info = new String[]{'connectionTimeoutDuration',SOAP_M_URI,null,'0','1','false'};
        private String[] connectionWarningDuration_type_info = new String[]{'connectionWarningDuration',SOAP_M_URI,null,'0','1','false'};
        private String[] displayQueuePosition_type_info = new String[]{'displayQueuePosition',SOAP_M_URI,null,'0','1','false'};
        private String[] domainWhiteList_type_info = new String[]{'domainWhiteList',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePrechatApi_type_info = new String[]{'enablePrechatApi',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTranscriptSave_type_info = new String[]{'enableTranscriptSave',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] mobileBrandingImage_type_info = new String[]{'mobileBrandingImage',SOAP_M_URI,null,'0','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'0','1','false'};
        private String[] windowTitle_type_info = new String[]{'windowTitle',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'brandingImage','connectionTimeoutDuration','connectionWarningDuration','displayQueuePosition','domainWhiteList','enablePrechatApi','enableTranscriptSave','label','mobileBrandingImage','site','windowTitle'};
    }
    public class EmailServicesAddress extends Metadata  {
        public String type = 'EmailServicesAddress';
        public String authorizedSenders;
        public String developerName;
        public Boolean isActive;
        public String localPart;
        public String runAsUser;
        private String[] authorizedSenders_type_info = new String[]{'authorizedSenders',SOAP_M_URI,null,'0','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] localPart_type_info = new String[]{'localPart',SOAP_M_URI,null,'1','1','false'};
        private String[] runAsUser_type_info = new String[]{'runAsUser',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'authorizedSenders','developerName','isActive','localPart','runAsUser'};
    }
    public class EmailServicesFunction extends Metadata  {
        public String type = 'EmailServicesFunction';
        public String fullName;
        public String apexClass;
        public String attachmentOption = 'All';
        public String authenticationFailureAction = 'Discard';
        public String authorizationFailureAction = 'Discard';
        public String authorizedSenders;
        public MetadataService.EmailServicesAddress[] emailServicesAddresses = new List<MetadataService.EmailServicesAddress>();
        public String errorRoutingAddress;
        public String functionInactiveAction = 'Discard';
        public String functionName;
        public Boolean isActive = true;
        public Boolean isAuthenticationRequired = false;
        public Boolean isErrorRoutingEnabled = false;
        public Boolean isTextAttachmentsAsBinary = false;
        public Boolean isTlsRequired = false;
        public String overLimitAction = 'Discard';
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
        private String[] attachmentOption_type_info = new String[]{'attachmentOption',SOAP_M_URI,null,'1','1','false'};
        private String[] authenticationFailureAction_type_info = new String[]{'authenticationFailureAction',SOAP_M_URI,null,'1','1','false'};
        private String[] authorizationFailureAction_type_info = new String[]{'authorizationFailureAction',SOAP_M_URI,null,'1','1','false'};
        private String[] authorizedSenders_type_info = new String[]{'authorizedSenders',SOAP_M_URI,null,'0','1','false'};
        private String[] emailServicesAddresses_type_info = new String[]{'emailServicesAddresses',SOAP_M_URI,null,'0','-1','false'};
        private String[] errorRoutingAddress_type_info = new String[]{'errorRoutingAddress',SOAP_M_URI,null,'0','1','false'};
        private String[] functionInactiveAction_type_info = new String[]{'functionInactiveAction',SOAP_M_URI,null,'1','1','false'};
        private String[] functionName_type_info = new String[]{'functionName',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] isAuthenticationRequired_type_info = new String[]{'isAuthenticationRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] isErrorRoutingEnabled_type_info = new String[]{'isErrorRoutingEnabled',SOAP_M_URI,null,'0','1','false'};
        private String[] isTextAttachmentsAsBinary_type_info = new String[]{'isTextAttachmentsAsBinary',SOAP_M_URI,null,'0','1','false'};
        private String[] isTlsRequired_type_info = new String[]{'isTlsRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] overLimitAction_type_info = new String[]{'overLimitAction',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        private String[] field_order_type_info = new String[]{'fullName', 'apexClass','attachmentOption','authenticationFailureAction','authorizationFailureAction','authorizedSenders','emailServicesAddresses','errorRoutingAddress','functionInactiveAction','functionName','isActive','isAuthenticationRequired','isErrorRoutingEnabled','isTextAttachmentsAsBinary','isTlsRequired','overLimitAction'};
    }
    public class ReportFilterItem {
        public String column;
        public Boolean columnToColumn;
        public Boolean isUnlocked;
        public String operator;
        public String snapshot;
        public String value;
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] columnToColumn_type_info = new String[]{'columnToColumn',SOAP_M_URI,null,'0','1','false'};
        private String[] isUnlocked_type_info = new String[]{'isUnlocked',SOAP_M_URI,null,'0','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
        private String[] snapshot_type_info = new String[]{'snapshot',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'column','columnToColumn','isUnlocked','operator','snapshot','value'};
    }
    public class KnowledgeSuggestedArticlesSettings {
        public MetadataService.KnowledgeCaseFieldsSettings caseFields;
        public Boolean useSuggestedArticlesForCase;
        private String[] caseFields_type_info = new String[]{'caseFields',SOAP_M_URI,null,'0','1','false'};
        private String[] useSuggestedArticlesForCase_type_info = new String[]{'useSuggestedArticlesForCase',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'caseFields','useSuggestedArticlesForCase'};
    }
    public class SaveResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    public class ExtendedErrorDetails {
        public String extendedErrorCode;
        private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorCode'};
    }
    public class SessionSettings {
        public Boolean disableTimeoutWarning;
        public Boolean enableCSPOnEmail;
        public Boolean enableCSRFOnGet;
        public Boolean enableCSRFOnPost;
        public Boolean enableCacheAndAutocomplete;
        public Boolean enableClickjackNonsetupSFDC;
        public Boolean enableClickjackNonsetupUser;
        public Boolean enableClickjackNonsetupUserHeaderless;
        public Boolean enableClickjackSetup;
        public Boolean enablePostForSessions;
        public Boolean enableSMSIdentity;
        public Boolean enforceIpRangesEveryRequest;
        public Boolean forceLogoutOnSessionTimeout;
        public Boolean forceRelogin;
        public Boolean lockSessionsToDomain;
        public Boolean lockSessionsToIp;
        public String logoutURL;
        public Boolean securityCentralKillSession;
        public String sessionTimeout;
        private String[] disableTimeoutWarning_type_info = new String[]{'disableTimeoutWarning',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCSPOnEmail_type_info = new String[]{'enableCSPOnEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCSRFOnGet_type_info = new String[]{'enableCSRFOnGet',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCSRFOnPost_type_info = new String[]{'enableCSRFOnPost',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCacheAndAutocomplete_type_info = new String[]{'enableCacheAndAutocomplete',SOAP_M_URI,null,'0','1','false'};
        private String[] enableClickjackNonsetupSFDC_type_info = new String[]{'enableClickjackNonsetupSFDC',SOAP_M_URI,null,'0','1','false'};
        private String[] enableClickjackNonsetupUser_type_info = new String[]{'enableClickjackNonsetupUser',SOAP_M_URI,null,'0','1','false'};
        private String[] enableClickjackNonsetupUserHeaderless_type_info = new String[]{'enableClickjackNonsetupUserHeaderless',SOAP_M_URI,null,'0','1','false'};
        private String[] enableClickjackSetup_type_info = new String[]{'enableClickjackSetup',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePostForSessions_type_info = new String[]{'enablePostForSessions',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSMSIdentity_type_info = new String[]{'enableSMSIdentity',SOAP_M_URI,null,'0','1','false'};
        private String[] enforceIpRangesEveryRequest_type_info = new String[]{'enforceIpRangesEveryRequest',SOAP_M_URI,null,'0','1','false'};
        private String[] forceLogoutOnSessionTimeout_type_info = new String[]{'forceLogoutOnSessionTimeout',SOAP_M_URI,null,'0','1','false'};
        private String[] forceRelogin_type_info = new String[]{'forceRelogin',SOAP_M_URI,null,'0','1','false'};
        private String[] lockSessionsToDomain_type_info = new String[]{'lockSessionsToDomain',SOAP_M_URI,null,'0','1','false'};
        private String[] lockSessionsToIp_type_info = new String[]{'lockSessionsToIp',SOAP_M_URI,null,'0','1','false'};
        private String[] logoutURL_type_info = new String[]{'logoutURL',SOAP_M_URI,null,'0','1','false'};
        private String[] securityCentralKillSession_type_info = new String[]{'securityCentralKillSession',SOAP_M_URI,null,'0','1','false'};
        private String[] sessionTimeout_type_info = new String[]{'sessionTimeout',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'disableTimeoutWarning','enableCSPOnEmail','enableCSRFOnGet','enableCSRFOnPost','enableCacheAndAutocomplete','enableClickjackNonsetupSFDC','enableClickjackNonsetupUser','enableClickjackNonsetupUserHeaderless','enableClickjackSetup','enablePostForSessions','enableSMSIdentity','enforceIpRangesEveryRequest','forceLogoutOnSessionTimeout','forceRelogin','lockSessionsToDomain','lockSessionsToIp','logoutURL','securityCentralKillSession','sessionTimeout'};
    }
    public class SharingOwnerRule extends SharingBaseRule {
        public String type = 'SharingOwnerRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessLevel;
        public MetadataService.AccountSharingRuleSettings accountSettings;
        public String description;
        public String label;
        public MetadataService.SharedTo sharedTo;
        private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] accountSettings_type_info = new String[]{'accountSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'1','1','false'};
        public MetadataService.SharedTo sharedFrom;
        private String[] sharedFrom_type_info = new String[]{'sharedFrom',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessLevel','accountSettings','description','label','sharedTo', 'sharedFrom'};
    }
    public class CustomExperienceTabSet {
        public String[] customTab;
        public String defaultTab;
        public String[] standardTab;
        private String[] customTab_type_info = new String[]{'customTab',SOAP_M_URI,null,'0','-1','false'};
        private String[] defaultTab_type_info = new String[]{'defaultTab',SOAP_M_URI,null,'1','1','false'};
        private String[] standardTab_type_info = new String[]{'standardTab',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customTab','defaultTab','standardTab'};
    }
    public class FieldMappingField {
        public String dataServiceField;
        public String dataServiceObjectName;
        public Integer priority;
        private String[] dataServiceField_type_info = new String[]{'dataServiceField',SOAP_M_URI,null,'1','1','false'};
        private String[] dataServiceObjectName_type_info = new String[]{'dataServiceObjectName',SOAP_M_URI,null,'1','1','false'};
        private String[] priority_type_info = new String[]{'priority',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dataServiceField','dataServiceObjectName','priority'};
    }
    public class CaseSettings extends Metadata {
        public String type = 'CaseSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public String caseAssignNotificationTemplate;
        public Boolean caseAutoProcUser;
        public String caseCloseNotificationTemplate;
        public String caseCommentNotificationTemplate;
        public String caseCreateNotificationTemplate;
        public MetadataService.FeedItemSettings[] caseFeedItemSettings;
        public Boolean caseFeedReadUnreadLtng;
        public Boolean caseMergeInLightning;
        public Boolean closeCaseThroughStatusChange;
        public Boolean defaultCaseFeedLayoutOn;
        public String defaultCaseOwner;
        public String defaultCaseOwnerType;
        public String defaultCaseUser;
        public String emailActionDefaultsHandlerClass;
        public MetadataService.EmailToCaseSettings emailToCase;
        public Boolean enableCaseFeed;
        public Boolean enableCollapseEmailThread;
        public Boolean enableDraftEmails;
        public Boolean enableEarlyEscalationRuleTriggers;
        public Boolean enableEmailActionDefaultsHandler;
        public Boolean enableEmailContactOnCasePost;
        public Boolean enableEscalateQfiToCaseInternal;
        public Boolean enableEscalateQfiToCaseNetworks;
        public Boolean enableExtNetworksCaseFeedEnabled;
        public Boolean enableMultiLangSolnSrchCSS;
        public Boolean enableMultiLangSolnSrchPKB;
        public Boolean enableMultiLangSolution;
        public Boolean enableSolutionCategory;
        public Boolean enableSolutionInlineCategory;
        public Boolean enableSolutionShortSummary;
        public Boolean enableSuggestedArticlesApplication;
        public Boolean enableSuggestedArticlesCustomerPortal;
        public Boolean enableSuggestedArticlesPartnerPortal;
        public Boolean enableSuggestedSolutions;
        public Boolean escalateCaseBefore;
        public Boolean genericMessageEnabled;
        public Boolean keepCaseMergeRecords;
        public Boolean keepRecordTypeOnAssignmentRule;
        public Boolean notifyContactOnCaseComment;
        public Boolean notifyDefaultCaseOwner;
        public Boolean notifyOwnerOnCaseComment;
        public Boolean notifyOwnerOnCaseOwnerChange;
        public Boolean predictiveSupportEnabled;
        public Boolean showEmailAttachmentsInCaseAttachmentsRL;
        public Boolean showFewerCloseActions;
        public String systemUserEmail;
        public Boolean useSystemEmailAddress;
        public Boolean useSystemUserAsDefaultCaseUser;
        public Boolean visibleInCssCheckbox;
        public MetadataService.WebToCaseSettings webToCase;
        private String[] caseAssignNotificationTemplate_type_info = new String[]{'caseAssignNotificationTemplate',SOAP_M_URI,'string','0','1','false'};
        private String[] caseAutoProcUser_type_info = new String[]{'caseAutoProcUser',SOAP_M_URI,'boolean','0','1','false'};
        private String[] caseCloseNotificationTemplate_type_info = new String[]{'caseCloseNotificationTemplate',SOAP_M_URI,'string','0','1','false'};
        private String[] caseCommentNotificationTemplate_type_info = new String[]{'caseCommentNotificationTemplate',SOAP_M_URI,'string','0','1','false'};
        private String[] caseCreateNotificationTemplate_type_info = new String[]{'caseCreateNotificationTemplate',SOAP_M_URI,'string','0','1','false'};
        private String[] caseFeedItemSettings_type_info = new String[]{'caseFeedItemSettings',SOAP_M_URI,'FeedItemSettings','0','-1','false'};
        private String[] caseFeedReadUnreadLtng_type_info = new String[]{'caseFeedReadUnreadLtng',SOAP_M_URI,'boolean','0','1','false'};
        private String[] caseMergeInLightning_type_info = new String[]{'caseMergeInLightning',SOAP_M_URI,'boolean','0','1','false'};
        private String[] closeCaseThroughStatusChange_type_info = new String[]{'closeCaseThroughStatusChange',SOAP_M_URI,'boolean','0','1','false'};
        private String[] defaultCaseFeedLayoutOn_type_info = new String[]{'defaultCaseFeedLayoutOn',SOAP_M_URI,'boolean','0','1','false'};
        private String[] defaultCaseOwner_type_info = new String[]{'defaultCaseOwner',SOAP_M_URI,'string','0','1','false'};
        private String[] defaultCaseOwnerType_type_info = new String[]{'defaultCaseOwnerType',SOAP_M_URI,'string','0','1','false'};
        private String[] defaultCaseUser_type_info = new String[]{'defaultCaseUser',SOAP_M_URI,'string','0','1','false'};
        private String[] emailActionDefaultsHandlerClass_type_info = new String[]{'emailActionDefaultsHandlerClass',SOAP_M_URI,'string','0','1','false'};
        private String[] emailToCase_type_info = new String[]{'emailToCase',SOAP_M_URI,'EmailToCaseSettings','0','1','false'};
        private String[] enableCaseFeed_type_info = new String[]{'enableCaseFeed',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableCollapseEmailThread_type_info = new String[]{'enableCollapseEmailThread',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableDraftEmails_type_info = new String[]{'enableDraftEmails',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEarlyEscalationRuleTriggers_type_info = new String[]{'enableEarlyEscalationRuleTriggers',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEmailActionDefaultsHandler_type_info = new String[]{'enableEmailActionDefaultsHandler',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEmailContactOnCasePost_type_info = new String[]{'enableEmailContactOnCasePost',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEscalateQfiToCaseInternal_type_info = new String[]{'enableEscalateQfiToCaseInternal',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEscalateQfiToCaseNetworks_type_info = new String[]{'enableEscalateQfiToCaseNetworks',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableExtNetworksCaseFeedEnabled_type_info = new String[]{'enableExtNetworksCaseFeedEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableMultiLangSolnSrchCSS_type_info = new String[]{'enableMultiLangSolnSrchCSS',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableMultiLangSolnSrchPKB_type_info = new String[]{'enableMultiLangSolnSrchPKB',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableMultiLangSolution_type_info = new String[]{'enableMultiLangSolution',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSolutionCategory_type_info = new String[]{'enableSolutionCategory',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSolutionInlineCategory_type_info = new String[]{'enableSolutionInlineCategory',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSolutionShortSummary_type_info = new String[]{'enableSolutionShortSummary',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSuggestedArticlesApplication_type_info = new String[]{'enableSuggestedArticlesApplication',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSuggestedArticlesCustomerPortal_type_info = new String[]{'enableSuggestedArticlesCustomerPortal',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSuggestedArticlesPartnerPortal_type_info = new String[]{'enableSuggestedArticlesPartnerPortal',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableSuggestedSolutions_type_info = new String[]{'enableSuggestedSolutions',SOAP_M_URI,'boolean','0','1','false'};
        private String[] escalateCaseBefore_type_info = new String[]{'escalateCaseBefore',SOAP_M_URI,'boolean','0','1','false'};
        private String[] genericMessageEnabled_type_info = new String[]{'genericMessageEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] keepCaseMergeRecords_type_info = new String[]{'keepCaseMergeRecords',SOAP_M_URI,'boolean','0','1','false'};
        private String[] keepRecordTypeOnAssignmentRule_type_info = new String[]{'keepRecordTypeOnAssignmentRule',SOAP_M_URI,'boolean','0','1','false'};
        private String[] notifyContactOnCaseComment_type_info = new String[]{'notifyContactOnCaseComment',SOAP_M_URI,'boolean','0','1','false'};
        private String[] notifyDefaultCaseOwner_type_info = new String[]{'notifyDefaultCaseOwner',SOAP_M_URI,'boolean','0','1','false'};
        private String[] notifyOwnerOnCaseComment_type_info = new String[]{'notifyOwnerOnCaseComment',SOAP_M_URI,'boolean','0','1','false'};
        private String[] notifyOwnerOnCaseOwnerChange_type_info = new String[]{'notifyOwnerOnCaseOwnerChange',SOAP_M_URI,'boolean','0','1','false'};
        private String[] predictiveSupportEnabled_type_info = new String[]{'predictiveSupportEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] showEmailAttachmentsInCaseAttachmentsRL_type_info = new String[]{'showEmailAttachmentsInCaseAttachmentsRL',SOAP_M_URI,'boolean','0','1','false'};
        private String[] showFewerCloseActions_type_info = new String[]{'showFewerCloseActions',SOAP_M_URI,'boolean','0','1','false'};
        private String[] systemUserEmail_type_info = new String[]{'systemUserEmail',SOAP_M_URI,'string','0','1','false'};
        private String[] useSystemEmailAddress_type_info = new String[]{'useSystemEmailAddress',SOAP_M_URI,'boolean','0','1','false'};
        private String[] useSystemUserAsDefaultCaseUser_type_info = new String[]{'useSystemUserAsDefaultCaseUser',SOAP_M_URI,'boolean','0','1','false'};
        private String[] visibleInCssCheckbox_type_info = new String[]{'visibleInCssCheckbox',SOAP_M_URI,'boolean','0','1','false'};
        private String[] webToCase_type_info = new String[]{'webToCase',SOAP_M_URI,'WebToCaseSettings','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','caseAssignNotificationTemplate','caseAutoProcUser','caseCloseNotificationTemplate','caseCommentNotificationTemplate','caseCreateNotificationTemplate','caseFeedItemSettings','caseFeedReadUnreadLtng','caseMergeInLightning','closeCaseThroughStatusChange','defaultCaseFeedLayoutOn','defaultCaseOwner','defaultCaseOwnerType','defaultCaseUser','emailActionDefaultsHandlerClass','emailToCase','enableCaseFeed','enableCollapseEmailThread','enableDraftEmails','enableEarlyEscalationRuleTriggers','enableEmailActionDefaultsHandler','enableEmailContactOnCasePost','enableEscalateQfiToCaseInternal','enableEscalateQfiToCaseNetworks','enableExtNetworksCaseFeedEnabled','enableMultiLangSolnSrchCSS','enableMultiLangSolnSrchPKB','enableMultiLangSolution','enableSolutionCategory','enableSolutionInlineCategory','enableSolutionShortSummary','enableSuggestedArticlesApplication','enableSuggestedArticlesCustomerPortal','enableSuggestedArticlesPartnerPortal','enableSuggestedSolutions','escalateCaseBefore','genericMessageEnabled','keepCaseMergeRecords','keepRecordTypeOnAssignmentRule','notifyContactOnCaseComment','notifyDefaultCaseOwner','notifyOwnerOnCaseComment','notifyOwnerOnCaseOwnerChange','predictiveSupportEnabled','showEmailAttachmentsInCaseAttachmentsRL','showFewerCloseActions','systemUserEmail','useSystemEmailAddress','useSystemUserAsDefaultCaseUser','visibleInCssCheckbox','webToCase'};
    }
    public class readMetadataResponse_element {
        public MetadataService.ReadResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class MiniLayout {
        public String[] fields;
        public MetadataService.RelatedListItem[] relatedLists;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','relatedLists'};
    }
    public class FieldValue {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class LicensedCustomPermissions {
        public String customPermission;
        public String licenseDefinition;
        private String[] customPermission_type_info = new String[]{'customPermission',SOAP_M_URI,null,'1','1','false'};
        private String[] licenseDefinition_type_info = new String[]{'licenseDefinition',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customPermission','licenseDefinition'};
    }
    public class UpsertResult {
        public Boolean created;
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'created','errors','fullName','success'};
    }
    public class ConnectedAppAttribute {
        public String formula;
        public String key;
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'1','1','false'};
        private String[] key_type_info = new String[]{'key',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'formula','key'};
    }
    public class WorkflowFieldUpdate extends WorkflowAction {
        public String type = 'WorkflowFieldUpdate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String field;
        public String formula;
        public String literalValue;
        public String lookupValue;
        public String lookupValueType;
        public String name;
        public Boolean notifyAssignee;
        public String operation;
        public Boolean protected_x;
        public Boolean reevaluateOnChange;
        public String targetObject;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] literalValue_type_info = new String[]{'literalValue',SOAP_M_URI,null,'0','1','false'};
        private String[] lookupValue_type_info = new String[]{'lookupValue',SOAP_M_URI,null,'0','1','false'};
        private String[] lookupValueType_type_info = new String[]{'lookupValueType',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] notifyAssignee_type_info = new String[]{'notifyAssignee',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] reevaluateOnChange_type_info = new String[]{'reevaluateOnChange',SOAP_M_URI,null,'0','1','false'};
        private String[] targetObject_type_info = new String[]{'targetObject',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','field','formula','literalValue','lookupValue','lookupValueType','name','notifyAssignee','operation','protected_x','reevaluateOnChange','targetObject'};
    }
    public class AssignmentRule extends Metadata {
        public String type = 'AssignmentRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public MetadataService.RuleEntry[] ruleEntry;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] ruleEntry_type_info = new String[]{'ruleEntry',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','ruleEntry'};
    }
    public class ValueSettings {
        public String[] controllingFieldValue;
        public String valueName;
        private String[] controllingFieldValue_type_info = new String[]{'controllingFieldValue',SOAP_M_URI,null,'0','-1','false'};
        private String[] valueName_type_info = new String[]{'valueName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingFieldValue','valueName'};
    }
    public class PushNotifications {
        public MetadataService.PushNotification[] pushNotification;
        private String[] pushNotification_type_info = new String[]{'pushNotification',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pushNotification'};
    }
    public class LiveChatButtonDeployments {
        public String[] deployment;
        private String[] deployment_type_info = new String[]{'deployment',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'deployment'};
    }
    public class DataCategoryGroup extends Metadata {
        public String type = 'DataCategoryGroup';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public MetadataService.DataCategory dataCategory;
        public String description;
        public String label;
        public MetadataService.ObjectUsage objectUsage;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] dataCategory_type_info = new String[]{'dataCategory',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] objectUsage_type_info = new String[]{'objectUsage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','dataCategory','description','label','objectUsage'};
    }
    public class DashboardGridComponent {
        public Integer colSpan;
        public Integer columnIndex;
        public MetadataService.DashboardComponent dashboardComponent;
        public Integer rowIndex;
        public Integer rowSpan;
        private String[] colSpan_type_info = new String[]{'colSpan',SOAP_M_URI,null,'1','1','false'};
        private String[] columnIndex_type_info = new String[]{'columnIndex',SOAP_M_URI,null,'1','1','false'};
        private String[] dashboardComponent_type_info = new String[]{'dashboardComponent',SOAP_M_URI,null,'1','1','false'};
        private String[] rowIndex_type_info = new String[]{'rowIndex',SOAP_M_URI,null,'1','1','false'};
        private String[] rowSpan_type_info = new String[]{'rowSpan',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'colSpan','columnIndex','dashboardComponent','rowIndex','rowSpan'};
    }
    public class CustomDataTypeComponent {
        public String developerSuffix;
        public Boolean enforceFieldRequiredness;
        public String label;
        public Integer length;
        public Integer precision;
        public Integer scale;
        public String sortOrder;
        public Integer sortPriority;
        public String type_x;
        private String[] developerSuffix_type_info = new String[]{'developerSuffix',SOAP_M_URI,null,'1','1','false'};
        private String[] enforceFieldRequiredness_type_info = new String[]{'enforceFieldRequiredness',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] length_type_info = new String[]{'length',SOAP_M_URI,null,'0','1','false'};
        private String[] precision_type_info = new String[]{'precision',SOAP_M_URI,null,'0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] sortPriority_type_info = new String[]{'sortPriority',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'developerSuffix','enforceFieldRequiredness','label','length','precision','scale','sortOrder','sortPriority','type_x'};
    }
    public class KnowledgeSitesSettings {
        public String[] site;
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'site'};
    }
    public class SearchLayouts {
        public String[] customTabListAdditionalFields;
        public String[] excludedStandardButtons;
        public String[] listViewButtons;
        public String[] lookupDialogsAdditionalFields;
        public String[] lookupFilterFields;
        public String[] lookupPhoneDialogsAdditionalFields;
        public String[] searchFilterFields;
        public String[] searchResultsAdditionalFields;
        public String[] searchResultsCustomButtons;
        private String[] customTabListAdditionalFields_type_info = new String[]{'customTabListAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] excludedStandardButtons_type_info = new String[]{'excludedStandardButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] listViewButtons_type_info = new String[]{'listViewButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupDialogsAdditionalFields_type_info = new String[]{'lookupDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupFilterFields_type_info = new String[]{'lookupFilterFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupPhoneDialogsAdditionalFields_type_info = new String[]{'lookupPhoneDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchFilterFields_type_info = new String[]{'searchFilterFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchResultsAdditionalFields_type_info = new String[]{'searchResultsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchResultsCustomButtons_type_info = new String[]{'searchResultsCustomButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customTabListAdditionalFields','excludedStandardButtons','listViewButtons','lookupDialogsAdditionalFields','lookupFilterFields','lookupPhoneDialogsAdditionalFields','searchFilterFields','searchResultsAdditionalFields','searchResultsCustomButtons'};
    }
    public class retrieve_element {
        public MetadataService.RetrieveRequest retrieveRequest;
        private String[] retrieveRequest_type_info = new String[]{'retrieveRequest',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'retrieveRequest'};
    }
    public class AssignmentRules extends Metadata {
        public String type = 'AssignmentRules';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AssignmentRule[] assignmentRule;
        private String[] assignmentRule_type_info = new String[]{'assignmentRule',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assignmentRule'};
    }
    public class DeleteResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    public class PackageTypeMembers {
        public String[] members;
        public String name;
        private String[] members_type_info = new String[]{'members',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'members','name'};
    }
    public class DashboardFilter {
        public MetadataService.DashboardFilterOption[] dashboardFilterOptions;
        public String name;
        private String[] dashboardFilterOptions_type_info = new String[]{'dashboardFilterOptions',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dashboardFilterOptions','name'};
    }
    public class ProfileApplicationVisibility {
        public String application;
        public Boolean default_x;
        public Boolean visible;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'application','default_x','visible'};
    }
    public class ReportParam {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class RelatedListItem {
        public String[] customButtons;
        public String[] excludeButtons;
        public String[] fields;
        public String relatedList;
        public String sortField;
        public String sortOrder;
        private String[] customButtons_type_info = new String[]{'customButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedList_type_info = new String[]{'relatedList',SOAP_M_URI,null,'1','1','false'};
        private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customButtons','excludeButtons','fields','relatedList','sortField','sortOrder'};
    }
    public class SynonymDictionary extends Metadata {
        public String type = 'SynonymDictionary';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.SynonymGroup[] groups;
        public Boolean isProtected;
        public String label;
        private String[] groups_type_info = new String[]{'groups',SOAP_M_URI,null,'0','-1','false'};
        private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'groups','isProtected','label'};
    }
    public class WebLinkTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class CustomTabTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class PackageVersion {
        public Integer majorNumber;
        public Integer minorNumber;
        public String namespace;
        private String[] majorNumber_type_info = new String[]{'majorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] minorNumber_type_info = new String[]{'minorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
    }
    public class DescribeMetadataObject {
        public String[] childXmlNames;
        public String directoryName;
        public Boolean inFolder;
        public Boolean metaFile;
        public String suffix;
        public String xmlName;
        private String[] childXmlNames_type_info = new String[]{'childXmlNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] directoryName_type_info = new String[]{'directoryName',SOAP_M_URI,null,'1','1','false'};
        private String[] inFolder_type_info = new String[]{'inFolder',SOAP_M_URI,null,'1','1','false'};
        private String[] metaFile_type_info = new String[]{'metaFile',SOAP_M_URI,null,'1','1','false'};
        private String[] suffix_type_info = new String[]{'suffix',SOAP_M_URI,null,'0','1','false'};
        private String[] xmlName_type_info = new String[]{'xmlName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'childXmlNames','directoryName','inFolder','metaFile','suffix','xmlName'};
    }
    public class LiveAgentSettings extends Metadata {
        public String type = 'LiveAgentSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableLiveAgent;
        private String[] enableLiveAgent_type_info = new String[]{'enableLiveAgent',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableLiveAgent'};
    }
    public class WorkflowFlowAction {
        public String description;
        public String flow;
        public MetadataService.WorkflowFlowActionParameter[] flowInputs;
        public String label;
        public String language;
        public Boolean protected_x;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] flow_type_info = new String[]{'flow',SOAP_M_URI,null,'1','1','false'};
        private String[] flowInputs_type_info = new String[]{'flowInputs',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','flow','flowInputs','label','language','protected_x'};
    }
    public class WaveApplication extends Metadata {
        public String type = 'WaveApplication';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String assetIcon;
        public String description;
        public String folder;
        public String masterLabel;
        public MetadataService.FolderShare[] shares;
        public String templateOrigin;
        public String templateVersion;
        private String[] assetIcon_type_info = new String[]{'assetIcon',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] shares_type_info = new String[]{'shares',SOAP_M_URI,null,'0','-1','false'};
        private String[] templateOrigin_type_info = new String[]{'templateOrigin',SOAP_M_URI,null,'0','1','false'};
        private String[] templateVersion_type_info = new String[]{'templateVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assetIcon','description','folder','masterLabel','shares','templateOrigin','templateVersion'};
    }
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
    public class WorkflowTaskTranslation {
        public String description;
        public String name;
        public String subject;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] subject_type_info = new String[]{'subject',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','subject'};
    }
    public class SearchSettings extends Metadata {
        public String type = 'SearchSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean documentContentSearchEnabled;
        public Boolean optimizeSearchForCJKEnabled;
        public Boolean recentlyViewedUsersForBlankLookupEnabled;
        public MetadataService.SearchSettingsByObject searchSettingsByObject;
        public Boolean sidebarAutoCompleteEnabled;
        public Boolean sidebarDropDownListEnabled;
        public Boolean sidebarLimitToItemsIOwnCheckboxEnabled;
        public Boolean singleSearchResultShortcutEnabled;
        public Boolean spellCorrectKnowledgeSearchEnabled;
        private String[] documentContentSearchEnabled_type_info = new String[]{'documentContentSearchEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] optimizeSearchForCJKEnabled_type_info = new String[]{'optimizeSearchForCJKEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] recentlyViewedUsersForBlankLookupEnabled_type_info = new String[]{'recentlyViewedUsersForBlankLookupEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] searchSettingsByObject_type_info = new String[]{'searchSettingsByObject',SOAP_M_URI,null,'1','1','false'};
        private String[] sidebarAutoCompleteEnabled_type_info = new String[]{'sidebarAutoCompleteEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] sidebarDropDownListEnabled_type_info = new String[]{'sidebarDropDownListEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] sidebarLimitToItemsIOwnCheckboxEnabled_type_info = new String[]{'sidebarLimitToItemsIOwnCheckboxEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] singleSearchResultShortcutEnabled_type_info = new String[]{'singleSearchResultShortcutEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] spellCorrectKnowledgeSearchEnabled_type_info = new String[]{'spellCorrectKnowledgeSearchEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'documentContentSearchEnabled','optimizeSearchForCJKEnabled','recentlyViewedUsersForBlankLookupEnabled','searchSettingsByObject','sidebarAutoCompleteEnabled','sidebarDropDownListEnabled','sidebarLimitToItemsIOwnCheckboxEnabled','singleSearchResultShortcutEnabled','spellCorrectKnowledgeSearchEnabled'};
    }
    public class listMetadata_element {
        public MetadataService.ListMetadataQuery[] queries;
        public Double asOfVersion;
        private String[] queries_type_info = new String[]{'queries',SOAP_M_URI,null,'0','-1','false'};
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'queries','asOfVersion'};
    }
    public class AuraDefinitionBundle extends Metadata {
        public String type = 'AuraDefinitionBundle';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String SVGContent;
        public Double apiVersion;
        public String controllerContent;
        public String description;
        public String designContent;
        public String documentationContent;
        public String helperContent;
        public String markup;
        public String modelContent;
        public MetadataService.PackageVersion[] packageVersions;
        public String rendererContent;
        public String styleContent;
        public String testsuiteContent;
        public String type_x;
        private String[] SVGContent_type_info = new String[]{'SVGContent',SOAP_M_URI,null,'0','1','false'};
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] controllerContent_type_info = new String[]{'controllerContent',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] designContent_type_info = new String[]{'designContent',SOAP_M_URI,null,'0','1','false'};
        private String[] documentationContent_type_info = new String[]{'documentationContent',SOAP_M_URI,null,'0','1','false'};
        private String[] helperContent_type_info = new String[]{'helperContent',SOAP_M_URI,null,'0','1','false'};
        private String[] markup_type_info = new String[]{'markup',SOAP_M_URI,null,'0','1','false'};
        private String[] modelContent_type_info = new String[]{'modelContent',SOAP_M_URI,null,'0','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] rendererContent_type_info = new String[]{'rendererContent',SOAP_M_URI,null,'0','1','false'};
        private String[] styleContent_type_info = new String[]{'styleContent',SOAP_M_URI,null,'0','1','false'};
        private String[] testsuiteContent_type_info = new String[]{'testsuiteContent',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'SVGContent','apiVersion','controllerContent','description','designContent','documentationContent','helperContent','markup','modelContent','packageVersions','rendererContent','styleContent','testsuiteContent','type_x'};
    }
    public class Queue extends Metadata {
        public String type = 'Queue';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean doesSendEmailToMembers;
        public String email;
        public String name;
        public MetadataService.QueueSobject[] queueSobject;
        private String[] doesSendEmailToMembers_type_info = new String[]{'doesSendEmailToMembers',SOAP_M_URI,null,'0','1','false'};
        private String[] email_type_info = new String[]{'email',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] queueSobject_type_info = new String[]{'queueSobject',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'doesSendEmailToMembers','email','name','queueSobject'};
    }
    public class HomePageLayout extends Metadata {
        public String type = 'HomePageLayout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] narrowComponents;
        public String[] wideComponents;
        private String[] narrowComponents_type_info = new String[]{'narrowComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] wideComponents_type_info = new String[]{'wideComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'narrowComponents','wideComponents'};
    }
    public class WaveLens extends MetadataWithContent {
        public String type = 'WaveLens';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String application;
        public String[] datasets;
        public String description;
        public String masterLabel;
        public String templateAssetSourceName;
        public String visualizationType;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] datasets_type_info = new String[]{'datasets',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] templateAssetSourceName_type_info = new String[]{'templateAssetSourceName',SOAP_M_URI,null,'0','1','false'};
        private String[] visualizationType_type_info = new String[]{'visualizationType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'application','datasets','description','masterLabel','templateAssetSourceName','visualizationType'};
    }
    public class QuickActionSendEmailOptions {
        public String defaultEmailTemplateName;
        public Boolean ignoreDefaultEmailTemplateSubject;
        private String[] defaultEmailTemplateName_type_info = new String[]{'defaultEmailTemplateName',SOAP_M_URI,null,'0','1','false'};
        private String[] ignoreDefaultEmailTemplateSubject_type_info = new String[]{'ignoreDefaultEmailTemplateSubject',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'defaultEmailTemplateName','ignoreDefaultEmailTemplateSubject'};
    }
    public class MilestoneType extends Metadata {
        public String type = 'MilestoneType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String recurrenceType;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceType_type_info = new String[]{'recurrenceType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','recurrenceType'};
    }
    public class WeightedSourceCategory {
        public String sourceCategoryApiName;
        public Double weight;
        private String[] sourceCategoryApiName_type_info = new String[]{'sourceCategoryApiName',SOAP_M_URI,null,'1','1','false'};
        private String[] weight_type_info = new String[]{'weight',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sourceCategoryApiName','weight'};
    }
    public class ApprovalProcess extends Metadata {
        public String type = 'ApprovalProcess';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public Boolean allowRecall;
        public MetadataService.ApprovalSubmitter[] allowedSubmitters;
        public MetadataService.ApprovalPageField approvalPageFields;
        public MetadataService.ApprovalStep[] approvalStep;
        public String description;
        public String emailTemplate;
        public Boolean enableMobileDeviceAccess;
        public MetadataService.ApprovalEntryCriteria entryCriteria;
        public MetadataService.ApprovalAction finalApprovalActions;
        public Boolean finalApprovalRecordLock;
        public MetadataService.ApprovalAction finalRejectionActions;
        public Boolean finalRejectionRecordLock;
        public MetadataService.ApprovalAction initialSubmissionActions;
        public String label;
        public MetadataService.NextAutomatedApprover nextAutomatedApprover;
        public String postTemplate;
        public MetadataService.ApprovalAction recallActions;
        public String recordEditability;
        public Boolean showApprovalHistory;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] allowRecall_type_info = new String[]{'allowRecall',SOAP_M_URI,null,'0','1','false'};
        private String[] allowedSubmitters_type_info = new String[]{'allowedSubmitters',SOAP_M_URI,null,'0','-1','false'};
        private String[] approvalPageFields_type_info = new String[]{'approvalPageFields',SOAP_M_URI,null,'0','1','false'};
        private String[] approvalStep_type_info = new String[]{'approvalStep',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] emailTemplate_type_info = new String[]{'emailTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] enableMobileDeviceAccess_type_info = new String[]{'enableMobileDeviceAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] entryCriteria_type_info = new String[]{'entryCriteria',SOAP_M_URI,null,'0','1','false'};
        private String[] finalApprovalActions_type_info = new String[]{'finalApprovalActions',SOAP_M_URI,null,'0','1','false'};
        private String[] finalApprovalRecordLock_type_info = new String[]{'finalApprovalRecordLock',SOAP_M_URI,null,'0','1','false'};
        private String[] finalRejectionActions_type_info = new String[]{'finalRejectionActions',SOAP_M_URI,null,'0','1','false'};
        private String[] finalRejectionRecordLock_type_info = new String[]{'finalRejectionRecordLock',SOAP_M_URI,null,'0','1','false'};
        private String[] initialSubmissionActions_type_info = new String[]{'initialSubmissionActions',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] nextAutomatedApprover_type_info = new String[]{'nextAutomatedApprover',SOAP_M_URI,null,'0','1','false'};
        private String[] postTemplate_type_info = new String[]{'postTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] recallActions_type_info = new String[]{'recallActions',SOAP_M_URI,null,'0','1','false'};
        private String[] recordEditability_type_info = new String[]{'recordEditability',SOAP_M_URI,null,'1','1','false'};
        private String[] showApprovalHistory_type_info = new String[]{'showApprovalHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','allowRecall','allowedSubmitters','approvalPageFields','approvalStep','description','emailTemplate','enableMobileDeviceAccess','entryCriteria','finalApprovalActions','finalApprovalRecordLock','finalRejectionActions','finalRejectionRecordLock','initialSubmissionActions','label','nextAutomatedApprover','postTemplate','recallActions','recordEditability','showApprovalHistory'};
    }
    public class EntitlementProcess extends Metadata {
        public String type = 'EntitlementProcess';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String SObjectType;
        public Boolean active;
        public String businessHours;
        public String description;
        public String entryStartDateField;
        public String exitCriteriaBooleanFilter;
        public MetadataService.FilterItem[] exitCriteriaFilterItems;
        public String exitCriteriaFormula;
        public Boolean isVersionDefault;
        public MetadataService.EntitlementProcessMilestoneItem[] milestones;
        public String name;
        public String versionMaster;
        public String versionNotes;
        public Integer versionNumber;
        private String[] SObjectType_type_info = new String[]{'SObjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] entryStartDateField_type_info = new String[]{'entryStartDateField',SOAP_M_URI,null,'0','1','false'};
        private String[] exitCriteriaBooleanFilter_type_info = new String[]{'exitCriteriaBooleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] exitCriteriaFilterItems_type_info = new String[]{'exitCriteriaFilterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] exitCriteriaFormula_type_info = new String[]{'exitCriteriaFormula',SOAP_M_URI,null,'0','1','false'};
        private String[] isVersionDefault_type_info = new String[]{'isVersionDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] milestones_type_info = new String[]{'milestones',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] versionMaster_type_info = new String[]{'versionMaster',SOAP_M_URI,null,'0','1','false'};
        private String[] versionNotes_type_info = new String[]{'versionNotes',SOAP_M_URI,null,'0','1','false'};
        private String[] versionNumber_type_info = new String[]{'versionNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'SObjectType','active','businessHours','description','entryStartDateField','exitCriteriaBooleanFilter','exitCriteriaFilterItems','exitCriteriaFormula','isVersionDefault','milestones','name','versionMaster','versionNotes','versionNumber'};
    }
    public class CustomApplicationComponents {
        public String alignment;
        public String[] customApplicationComponent;
        private String[] alignment_type_info = new String[]{'alignment',SOAP_M_URI,null,'1','1','false'};
        private String[] customApplicationComponent_type_info = new String[]{'customApplicationComponent',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'alignment','customApplicationComponent'};
    }
    public class ApexTestSuite extends Metadata {
        public String type = 'ApexTestSuite';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] testClassName;
        private String[] testClassName_type_info = new String[]{'testClassName',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'testClassName'};
    }
    public class GlobalQuickActionTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class Holiday {
        public Date activityDate;
        public String[] businessHours;
        public String description;
        public DateTime endTime;
        public Boolean isRecurring;
        public String name;
        public Integer recurrenceDayOfMonth;
        public String[] recurrenceDayOfWeek;
        public Integer recurrenceDayOfWeekMask;
        public Date recurrenceEndDate;
        public String recurrenceInstance;
        public Integer recurrenceInterval;
        public String recurrenceMonthOfYear;
        public Date recurrenceStartDate;
        public String recurrenceType;
        public DateTime startTime;
        private String[] activityDate_type_info = new String[]{'activityDate',SOAP_M_URI,null,'0','1','false'};
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] endTime_type_info = new String[]{'endTime',SOAP_M_URI,null,'0','1','false'};
        private String[] isRecurring_type_info = new String[]{'isRecurring',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceDayOfMonth_type_info = new String[]{'recurrenceDayOfMonth',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceDayOfWeek_type_info = new String[]{'recurrenceDayOfWeek',SOAP_M_URI,null,'0','-1','false'};
        private String[] recurrenceDayOfWeekMask_type_info = new String[]{'recurrenceDayOfWeekMask',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceEndDate_type_info = new String[]{'recurrenceEndDate',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceInstance_type_info = new String[]{'recurrenceInstance',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceInterval_type_info = new String[]{'recurrenceInterval',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceMonthOfYear_type_info = new String[]{'recurrenceMonthOfYear',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceStartDate_type_info = new String[]{'recurrenceStartDate',SOAP_M_URI,null,'0','1','false'};
        private String[] recurrenceType_type_info = new String[]{'recurrenceType',SOAP_M_URI,null,'0','1','false'};
        private String[] startTime_type_info = new String[]{'startTime',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'activityDate','businessHours','description','endTime','isRecurring','name','recurrenceDayOfMonth','recurrenceDayOfWeek','recurrenceDayOfWeekMask','recurrenceEndDate','recurrenceInstance','recurrenceInterval','recurrenceMonthOfYear','recurrenceStartDate','recurrenceType','startTime'};
    }
    public class Layout extends Metadata {
        public String type = 'Layout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] customButtons;
        public MetadataService.CustomConsoleComponents customConsoleComponents;
        public Boolean emailDefault;
        public String[] excludeButtons;
        public MetadataService.FeedLayout feedLayout;
        public String[] headers;
        public MetadataService.LayoutSection[] layoutSections;
        public MetadataService.MiniLayout miniLayout;
        public String[] multilineLayoutFields;
        public MetadataService.PlatformActionList platformActionList;
        public MetadataService.QuickActionList quickActionList;
        public MetadataService.RelatedContent relatedContent;
        public MetadataService.RelatedListItem[] relatedLists;
        public String[] relatedObjects;
        public Boolean runAssignmentRulesDefault;
        public Boolean showEmailCheckbox;
        public Boolean showHighlightsPanel;
        public Boolean showInteractionLogPanel;
        public Boolean showKnowledgeComponent;
        public Boolean showRunAssignmentRulesCheckbox;
        public Boolean showSolutionSection;
        public Boolean showSubmitAndAttachButton;
        public MetadataService.SummaryLayout summaryLayout;
        private String[] customButtons_type_info = new String[]{'customButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] customConsoleComponents_type_info = new String[]{'customConsoleComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] emailDefault_type_info = new String[]{'emailDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] feedLayout_type_info = new String[]{'feedLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] headers_type_info = new String[]{'headers',SOAP_M_URI,null,'0','-1','false'};
        private String[] layoutSections_type_info = new String[]{'layoutSections',SOAP_M_URI,null,'0','-1','false'};
        private String[] miniLayout_type_info = new String[]{'miniLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] multilineLayoutFields_type_info = new String[]{'multilineLayoutFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] platformActionList_type_info = new String[]{'platformActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionList_type_info = new String[]{'quickActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedContent_type_info = new String[]{'relatedContent',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedObjects_type_info = new String[]{'relatedObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] runAssignmentRulesDefault_type_info = new String[]{'runAssignmentRulesDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] showEmailCheckbox_type_info = new String[]{'showEmailCheckbox',SOAP_M_URI,null,'0','1','false'};
        private String[] showHighlightsPanel_type_info = new String[]{'showHighlightsPanel',SOAP_M_URI,null,'0','1','false'};
        private String[] showInteractionLogPanel_type_info = new String[]{'showInteractionLogPanel',SOAP_M_URI,null,'0','1','false'};
        private String[] showKnowledgeComponent_type_info = new String[]{'showKnowledgeComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] showRunAssignmentRulesCheckbox_type_info = new String[]{'showRunAssignmentRulesCheckbox',SOAP_M_URI,null,'0','1','false'};
        private String[] showSolutionSection_type_info = new String[]{'showSolutionSection',SOAP_M_URI,null,'0','1','false'};
        private String[] showSubmitAndAttachButton_type_info = new String[]{'showSubmitAndAttachButton',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryLayout_type_info = new String[]{'summaryLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customButtons','customConsoleComponents','emailDefault','excludeButtons','feedLayout','headers','layoutSections','miniLayout','multilineLayoutFields','platformActionList','quickActionList','relatedContent','relatedLists','relatedObjects','runAssignmentRulesDefault','showEmailCheckbox','showHighlightsPanel','showInteractionLogPanel','showKnowledgeComponent','showRunAssignmentRulesCheckbox','showSolutionSection','showSubmitAndAttachButton','summaryLayout'};
    }
    public class LiveChatButton extends Metadata {
        public String type = 'LiveChatButton';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String animation;
        public String autoGreeting;
        public Integer chasitorIdleTimeout;
        public Integer chasitorIdleTimeoutWarning;
        public String chatPage;
        public String customAgentName;
        public MetadataService.LiveChatButtonDeployments deployments;
        public Boolean enableQueue;
        public String inviteEndPosition;
        public String inviteImage;
        public String inviteStartPosition;
        public Boolean isActive;
        public String label;
        public Integer numberOfReroutingAttempts;
        public String offlineImage;
        public String onlineImage;
        public Boolean optionsCustomRoutingIsEnabled;
        public Boolean optionsHasChasitorIdleTimeout;
        public Boolean optionsHasInviteAfterAccept;
        public Boolean optionsHasInviteAfterReject;
        public Boolean optionsHasRerouteDeclinedRequest;
        public Boolean optionsIsAutoAccept;
        public Boolean optionsIsInviteAutoRemove;
        public Integer overallQueueLength;
        public Integer perAgentQueueLength;
        public String postChatPage;
        public String postChatUrl;
        public String preChatFormPage;
        public String preChatFormUrl;
        public Integer pushTimeOut;
        public String routingType;
        public String site;
        public MetadataService.LiveChatButtonSkills skills;
        public Integer timeToRemoveInvite;
        public String type_x;
        public String windowLanguage;
        private String[] animation_type_info = new String[]{'animation',SOAP_M_URI,null,'0','1','false'};
        private String[] autoGreeting_type_info = new String[]{'autoGreeting',SOAP_M_URI,null,'0','1','false'};
        private String[] chasitorIdleTimeout_type_info = new String[]{'chasitorIdleTimeout',SOAP_M_URI,null,'0','1','false'};
        private String[] chasitorIdleTimeoutWarning_type_info = new String[]{'chasitorIdleTimeoutWarning',SOAP_M_URI,null,'0','1','false'};
        private String[] chatPage_type_info = new String[]{'chatPage',SOAP_M_URI,null,'0','1','false'};
        private String[] customAgentName_type_info = new String[]{'customAgentName',SOAP_M_URI,null,'0','1','false'};
        private String[] deployments_type_info = new String[]{'deployments',SOAP_M_URI,null,'0','1','false'};
        private String[] enableQueue_type_info = new String[]{'enableQueue',SOAP_M_URI,null,'0','1','false'};
        private String[] inviteEndPosition_type_info = new String[]{'inviteEndPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] inviteImage_type_info = new String[]{'inviteImage',SOAP_M_URI,null,'0','1','false'};
        private String[] inviteStartPosition_type_info = new String[]{'inviteStartPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] numberOfReroutingAttempts_type_info = new String[]{'numberOfReroutingAttempts',SOAP_M_URI,null,'0','1','false'};
        private String[] offlineImage_type_info = new String[]{'offlineImage',SOAP_M_URI,null,'0','1','false'};
        private String[] onlineImage_type_info = new String[]{'onlineImage',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsCustomRoutingIsEnabled_type_info = new String[]{'optionsCustomRoutingIsEnabled',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsHasChasitorIdleTimeout_type_info = new String[]{'optionsHasChasitorIdleTimeout',SOAP_M_URI,null,'1','1','false'};
        private String[] optionsHasInviteAfterAccept_type_info = new String[]{'optionsHasInviteAfterAccept',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsHasInviteAfterReject_type_info = new String[]{'optionsHasInviteAfterReject',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsHasRerouteDeclinedRequest_type_info = new String[]{'optionsHasRerouteDeclinedRequest',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsIsAutoAccept_type_info = new String[]{'optionsIsAutoAccept',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsIsInviteAutoRemove_type_info = new String[]{'optionsIsInviteAutoRemove',SOAP_M_URI,null,'0','1','false'};
        private String[] overallQueueLength_type_info = new String[]{'overallQueueLength',SOAP_M_URI,null,'0','1','false'};
        private String[] perAgentQueueLength_type_info = new String[]{'perAgentQueueLength',SOAP_M_URI,null,'0','1','false'};
        private String[] postChatPage_type_info = new String[]{'postChatPage',SOAP_M_URI,null,'0','1','false'};
        private String[] postChatUrl_type_info = new String[]{'postChatUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] preChatFormPage_type_info = new String[]{'preChatFormPage',SOAP_M_URI,null,'0','1','false'};
        private String[] preChatFormUrl_type_info = new String[]{'preChatFormUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] pushTimeOut_type_info = new String[]{'pushTimeOut',SOAP_M_URI,null,'0','1','false'};
        private String[] routingType_type_info = new String[]{'routingType',SOAP_M_URI,null,'1','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'0','1','false'};
        private String[] skills_type_info = new String[]{'skills',SOAP_M_URI,null,'0','1','false'};
        private String[] timeToRemoveInvite_type_info = new String[]{'timeToRemoveInvite',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] windowLanguage_type_info = new String[]{'windowLanguage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'animation','autoGreeting','chasitorIdleTimeout','chasitorIdleTimeoutWarning','chatPage','customAgentName','deployments','enableQueue','inviteEndPosition','inviteImage','inviteStartPosition','isActive','label','numberOfReroutingAttempts','offlineImage','onlineImage','optionsCustomRoutingIsEnabled','optionsHasChasitorIdleTimeout','optionsHasInviteAfterAccept','optionsHasInviteAfterReject','optionsHasRerouteDeclinedRequest','optionsIsAutoAccept','optionsIsInviteAutoRemove','overallQueueLength','perAgentQueueLength','postChatPage','postChatUrl','preChatFormPage','preChatFormUrl','pushTimeOut','routingType','site','skills','timeToRemoveInvite','type_x','windowLanguage'};
    }
    public class Territory2SettingsOpportunityFilter {
        public String apexClassName;
        public Boolean enableFilter;
        public Boolean runOnCreate;
        private String[] apexClassName_type_info = new String[]{'apexClassName',SOAP_M_URI,null,'1','1','true'};
        private String[] enableFilter_type_info = new String[]{'enableFilter',SOAP_M_URI,null,'1','1','false'};
        private String[] runOnCreate_type_info = new String[]{'runOnCreate',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexClassName','enableFilter','runOnCreate'};
    }
    public class ActivitiesSettings extends Metadata {
        public String type = 'ActivitiesSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean allowUsersToRelateMultipleContactsToTasksAndEvents;
        public Boolean enableActivityReminders;
        public Boolean enableClickCreateEvents;
        public Boolean enableDragAndDropScheduling;
        public Boolean enableEmailTracking;
        public Boolean enableGroupTasks;
        public Boolean enableListViewScheduling;
        public Boolean enableLogNote;
        public Boolean enableMultidayEvents;
        public Boolean enableRecurringEvents;
        public Boolean enableRecurringTasks;
        public Boolean enableSidebarCalendarShortcut;
        public Boolean enableSimpleTaskCreateUI;
        public Boolean enableUNSTaskDelegatedToNotifications;
        public String meetingRequestsLogo;
        public Boolean showCustomLogoMeetingRequests;
        public Boolean showEventDetailsMultiUserCalendar;
        public Boolean showHomePageHoverLinksForEvents;
        public Boolean showMyTasksHoverLinks;
        public Boolean showRequestedMeetingsOnHomePage;
        private String[] allowUsersToRelateMultipleContactsToTasksAndEvents_type_info = new String[]{'allowUsersToRelateMultipleContactsToTasksAndEvents',SOAP_M_URI,null,'0','1','false'};
        private String[] enableActivityReminders_type_info = new String[]{'enableActivityReminders',SOAP_M_URI,null,'0','1','false'};
        private String[] enableClickCreateEvents_type_info = new String[]{'enableClickCreateEvents',SOAP_M_URI,null,'0','1','false'};
        private String[] enableDragAndDropScheduling_type_info = new String[]{'enableDragAndDropScheduling',SOAP_M_URI,null,'0','1','false'};
        private String[] enableEmailTracking_type_info = new String[]{'enableEmailTracking',SOAP_M_URI,null,'0','1','false'};
        private String[] enableGroupTasks_type_info = new String[]{'enableGroupTasks',SOAP_M_URI,null,'0','1','false'};
        private String[] enableListViewScheduling_type_info = new String[]{'enableListViewScheduling',SOAP_M_URI,null,'0','1','false'};
        private String[] enableLogNote_type_info = new String[]{'enableLogNote',SOAP_M_URI,null,'0','1','false'};
        private String[] enableMultidayEvents_type_info = new String[]{'enableMultidayEvents',SOAP_M_URI,null,'0','1','false'};
        private String[] enableRecurringEvents_type_info = new String[]{'enableRecurringEvents',SOAP_M_URI,null,'0','1','false'};
        private String[] enableRecurringTasks_type_info = new String[]{'enableRecurringTasks',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSidebarCalendarShortcut_type_info = new String[]{'enableSidebarCalendarShortcut',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSimpleTaskCreateUI_type_info = new String[]{'enableSimpleTaskCreateUI',SOAP_M_URI,null,'0','1','false'};
        private String[] enableUNSTaskDelegatedToNotifications_type_info = new String[]{'enableUNSTaskDelegatedToNotifications',SOAP_M_URI,null,'0','1','false'};
        private String[] meetingRequestsLogo_type_info = new String[]{'meetingRequestsLogo',SOAP_M_URI,null,'0','1','false'};
        private String[] showCustomLogoMeetingRequests_type_info = new String[]{'showCustomLogoMeetingRequests',SOAP_M_URI,null,'0','1','false'};
        private String[] showEventDetailsMultiUserCalendar_type_info = new String[]{'showEventDetailsMultiUserCalendar',SOAP_M_URI,null,'0','1','false'};
        private String[] showHomePageHoverLinksForEvents_type_info = new String[]{'showHomePageHoverLinksForEvents',SOAP_M_URI,null,'0','1','false'};
        private String[] showMyTasksHoverLinks_type_info = new String[]{'showMyTasksHoverLinks',SOAP_M_URI,null,'0','1','false'};
        private String[] showRequestedMeetingsOnHomePage_type_info = new String[]{'showRequestedMeetingsOnHomePage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'allowUsersToRelateMultipleContactsToTasksAndEvents','enableActivityReminders','enableClickCreateEvents','enableDragAndDropScheduling','enableEmailTracking','enableGroupTasks','enableListViewScheduling','enableLogNote','enableMultidayEvents','enableRecurringEvents','enableRecurringTasks','enableSidebarCalendarShortcut','enableSimpleTaskCreateUI','enableUNSTaskDelegatedToNotifications','meetingRequestsLogo','showCustomLogoMeetingRequests','showEventDetailsMultiUserCalendar','showHomePageHoverLinksForEvents','showMyTasksHoverLinks','showRequestedMeetingsOnHomePage'};
    }
    public class ApexComponent extends MetadataWithContent {
        public String type = 'ApexComponent';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public String description;
        public String label;
        public MetadataService.PackageVersion[] packageVersions;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'apiVersion','description','label','packageVersions'};
    }
    public class AutoResponseRule extends Metadata {
        public String type = 'AutoResponseRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public MetadataService.RuleEntry[] ruleEntry;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] ruleEntry_type_info = new String[]{'ruleEntry',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','ruleEntry'};
    }
    public class NamedCredential extends Metadata {
        public String type = 'NamedCredential';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String authProvider;
        public String certificate;
        public String endpoint;
        public String label;
        public String oauthRefreshToken;
        public String oauthScope;
        public String oauthToken;
        public String password;
        public String principalType;
        public String protocol;
        public String username;
        private String[] authProvider_type_info = new String[]{'authProvider',SOAP_M_URI,null,'0','1','false'};
        private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
        private String[] endpoint_type_info = new String[]{'endpoint',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] oauthRefreshToken_type_info = new String[]{'oauthRefreshToken',SOAP_M_URI,null,'0','1','false'};
        private String[] oauthScope_type_info = new String[]{'oauthScope',SOAP_M_URI,null,'0','1','false'};
        private String[] oauthToken_type_info = new String[]{'oauthToken',SOAP_M_URI,null,'0','1','false'};
        private String[] password_type_info = new String[]{'password',SOAP_M_URI,null,'0','1','false'};
        private String[] principalType_type_info = new String[]{'principalType',SOAP_M_URI,null,'1','1','false'};
        private String[] protocol_type_info = new String[]{'protocol',SOAP_M_URI,null,'1','1','false'};
        private String[] username_type_info = new String[]{'username',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'authProvider','certificate','endpoint','label','oauthRefreshToken','oauthScope','oauthToken','password','principalType','protocol','username'};
    }
    public class QuickAction extends Metadata {
        public String type = 'QuickAction';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String canvas;
        public String description;
        public MetadataService.FieldOverride[] fieldOverrides;
        public Integer height;
        public String icon;
        public Boolean isProtected;
        public String label;
        public String lightningComponent;
        public Boolean optionsCreateFeedItem;
        public String page_x;
        public MetadataService.QuickActionLayout quickActionLayout;
        public MetadataService.QuickActionSendEmailOptions quickActionSendEmailOptions;
        public String standardLabel;
        public String successMessage;
        public String targetObject;
        public String targetParentField;
        public String targetRecordType;
        public String type_x;
        public Integer width;
        private String[] canvas_type_info = new String[]{'canvas',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldOverrides_type_info = new String[]{'fieldOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'0','1','false'};
        private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] lightningComponent_type_info = new String[]{'lightningComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] optionsCreateFeedItem_type_info = new String[]{'optionsCreateFeedItem',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionLayout_type_info = new String[]{'quickActionLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionSendEmailOptions_type_info = new String[]{'quickActionSendEmailOptions',SOAP_M_URI,null,'0','1','false'};
        private String[] standardLabel_type_info = new String[]{'standardLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] successMessage_type_info = new String[]{'successMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] targetObject_type_info = new String[]{'targetObject',SOAP_M_URI,null,'0','1','false'};
        private String[] targetParentField_type_info = new String[]{'targetParentField',SOAP_M_URI,null,'0','1','false'};
        private String[] targetRecordType_type_info = new String[]{'targetRecordType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'canvas','description','fieldOverrides','height','icon','isProtected','label','lightningComponent','optionsCreateFeedItem','page_x','quickActionLayout','quickActionSendEmailOptions','standardLabel','successMessage','targetObject','targetParentField','targetRecordType','type_x','width'};
    }
    public class SharingCriteriaRule extends SharingBaseRule {
        public String type = 'SharingCriteriaRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessLevel;
        public MetadataService.AccountSharingRuleSettings accountSettings;
        public String description;
        public String label;
        public MetadataService.SharedTo sharedTo;
        private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] accountSettings_type_info = new String[]{'accountSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'1','1','false'};
        public String booleanFilter;
        public MetadataService.FilterItem[] criteriaItems;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessLevel','accountSettings','description','label','sharedTo', 'booleanFilter','criteriaItems'};
    }
    public class MatchingRules extends Metadata {
        public String type = 'MatchingRules';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.MatchingRule[] matchingRules;
        private String[] matchingRules_type_info = new String[]{'matchingRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'matchingRules'};
    }
    public class Attachment {
        public String content;
        public String name;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'content','name'};
    }
    public class PathAssistantStep {
        public String[] fieldNames;
        public String info;
        public String picklistValueName;
        private String[] fieldNames_type_info = new String[]{'fieldNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] info_type_info = new String[]{'info',SOAP_M_URI,null,'0','1','false'};
        private String[] picklistValueName_type_info = new String[]{'picklistValueName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fieldNames','info','picklistValueName'};
    }
    public class ChannelLayoutItem {
        public String field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    public virtual class CustomValue extends Metadata {
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'1','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'color','default_x','description','isActive','fullName'};
    }
    public class ListView extends Metadata {
        public String type = 'ListView';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String booleanFilter;
        public String[] columns;
        public String division;
        public String filterScope;
        public MetadataService.ListViewFilter[] filters;
        public String label;
        public String language;
        public String queue;
        public MetadataService.SharedTo sharedTo;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] columns_type_info = new String[]{'columns',SOAP_M_URI,null,'0','-1','false'};
        private String[] division_type_info = new String[]{'division',SOAP_M_URI,null,'0','1','false'};
        private String[] filterScope_type_info = new String[]{'filterScope',SOAP_M_URI,null,'1','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] queue_type_info = new String[]{'queue',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'booleanFilter','columns','division','filterScope','filters','label','language','queue','sharedTo'};
    }
    public class CustomApplicationTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class KnowledgeCaseSettings {
        public String articlePDFCreationProfile;
        public MetadataService.KnowledgeCommunitiesSettings articlePublicSharingCommunities;
        public MetadataService.KnowledgeSitesSettings articlePublicSharingSites;
        public MetadataService.KnowledgeSitesSettings articlePublicSharingSitesChatterAnswers;
        public String assignTo;
        public String customizationClass;
        public String defaultContributionArticleType;
        public String editor;
        public Boolean enableArticleCreation;
        public Boolean enableArticlePublicSharingSites;
        public Boolean useProfileForPDFCreation;
        private String[] articlePDFCreationProfile_type_info = new String[]{'articlePDFCreationProfile',SOAP_M_URI,null,'0','1','false'};
        private String[] articlePublicSharingCommunities_type_info = new String[]{'articlePublicSharingCommunities',SOAP_M_URI,null,'0','1','false'};
        private String[] articlePublicSharingSites_type_info = new String[]{'articlePublicSharingSites',SOAP_M_URI,null,'0','1','false'};
        private String[] articlePublicSharingSitesChatterAnswers_type_info = new String[]{'articlePublicSharingSitesChatterAnswers',SOAP_M_URI,null,'0','1','false'};
        private String[] assignTo_type_info = new String[]{'assignTo',SOAP_M_URI,null,'0','1','false'};
        private String[] customizationClass_type_info = new String[]{'customizationClass',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultContributionArticleType_type_info = new String[]{'defaultContributionArticleType',SOAP_M_URI,null,'0','1','false'};
        private String[] editor_type_info = new String[]{'editor',SOAP_M_URI,null,'0','1','false'};
        private String[] enableArticleCreation_type_info = new String[]{'enableArticleCreation',SOAP_M_URI,null,'0','1','false'};
        private String[] enableArticlePublicSharingSites_type_info = new String[]{'enableArticlePublicSharingSites',SOAP_M_URI,null,'0','1','false'};
        private String[] useProfileForPDFCreation_type_info = new String[]{'useProfileForPDFCreation',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'articlePDFCreationProfile','articlePublicSharingCommunities','articlePublicSharingSites','articlePublicSharingSitesChatterAnswers','assignTo','customizationClass','defaultContributionArticleType','editor','enableArticleCreation','enableArticlePublicSharingSites','useProfileForPDFCreation'};
    }
    public class FiscalYearSettings {
        public String fiscalYearNameBasedOn;
        public String startMonth;
        private String[] fiscalYearNameBasedOn_type_info = new String[]{'fiscalYearNameBasedOn',SOAP_M_URI,null,'0','1','false'};
        private String[] startMonth_type_info = new String[]{'startMonth',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fiscalYearNameBasedOn','startMonth'};
    }
    public class Approver {
        public String name;
        public String type_x;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','type_x'};
    }
    public class ObjectNameCaseValue {
        public String article;
        public String caseType;
        public Boolean plural;
        public String possessive;
        public String value;
        private String[] article_type_info = new String[]{'article',SOAP_M_URI,null,'0','1','false'};
        private String[] caseType_type_info = new String[]{'caseType',SOAP_M_URI,null,'0','1','false'};
        private String[] plural_type_info = new String[]{'plural',SOAP_M_URI,null,'0','1','false'};
        private String[] possessive_type_info = new String[]{'possessive',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'article','caseType','plural','possessive','value'};
    }
    public class SiteWebAddress {
        public String certificate;
        public String domainName;
        public Boolean primary;
        private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
        private String[] domainName_type_info = new String[]{'domainName',SOAP_M_URI,null,'1','1','false'};
        private String[] primary_type_info = new String[]{'primary',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'certificate','domainName','primary'};
    }
    public class CompanySettings extends Metadata {
        public String type = 'CompanySettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.FiscalYearSettings fiscalYear;
        private String[] fiscalYear_type_info = new String[]{'fiscalYear',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'fiscalYear'};
    }
    public class LookupFilterTranslation {
        public String errorMessage;
        public String informationalMessage;
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
        private String[] informationalMessage_type_info = new String[]{'informationalMessage',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errorMessage','informationalMessage'};
    }
    public class LetterheadLine {
        public String color;
        public Integer height;
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'color','height'};
    }
    public class ValidationRule extends Metadata {
        public String type = 'ValidationRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String description;
        public String errorConditionFormula;
        public String errorDisplayField;
        public String errorMessage;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] errorConditionFormula_type_info = new String[]{'errorConditionFormula',SOAP_M_URI,null,'1','1','false'};
        private String[] errorDisplayField_type_info = new String[]{'errorDisplayField',SOAP_M_URI,null,'0','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','description','errorConditionFormula','errorDisplayField','errorMessage'};
    }
    public class ChatterAnswersReputationLevel {
        public String name;
        public Integer value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class Role {
        public String parentRole;
        private String[] parentRole_type_info = new String[]{'parentRole',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'parentRole'};
    }
    public class FeedLayoutFilter {
        public String feedFilterName;
        public String feedFilterType;
        public String feedItemType;
        private String[] feedFilterName_type_info = new String[]{'feedFilterName',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilterType_type_info = new String[]{'feedFilterType',SOAP_M_URI,null,'1','1','false'};
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'feedFilterName','feedFilterType','feedItemType'};
    }
    public virtual class WorkflowAction extends Metadata {
    }
    public class State {
        public Boolean active;
        public String integrationValue;
        public String isoCode;
        public String label;
        public Boolean standard;
        public Boolean visible;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] integrationValue_type_info = new String[]{'integrationValue',SOAP_M_URI,null,'1','1','false'};
        private String[] isoCode_type_info = new String[]{'isoCode',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] standard_type_info = new String[]{'standard',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','integrationValue','isoCode','label','standard','visible'};
    }
    public class SupervisorAgentConfigSkills {
        public String[] skill;
        private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'skill'};
    }
    public class describeValueTypeResponse_element {
        public MetadataService.DescribeValueTypeResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ActionOverride {
        public String actionName;
        public String comment;
        public String content;
        public String formFactor;
        public Boolean skipRecordTypeSelect;
        public String type_x;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'0','1','false'};
        private String[] comment_type_info = new String[]{'comment',SOAP_M_URI,null,'0','1','false'};
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'0','1','false'};
        private String[] skipRecordTypeSelect_type_info = new String[]{'skipRecordTypeSelect',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','comment','content','formFactor','skipRecordTypeSelect','type_x'};
    }
    public class Translations extends Metadata {
        public String type = 'Translations';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CustomApplicationTranslation[] customApplications;
        public MetadataService.CustomDataTypeTranslation[] customDataTypeTranslations;
        public MetadataService.CustomLabelTranslation[] customLabels;
        public MetadataService.CustomPageWebLinkTranslation[] customPageWebLinks;
        public MetadataService.CustomTabTranslation[] customTabs;
        public MetadataService.GlobalQuickActionTranslation[] quickActions;
        public MetadataService.ReportTypeTranslation[] reportTypes;
        public MetadataService.ScontrolTranslation[] scontrols;
        private String[] customApplications_type_info = new String[]{'customApplications',SOAP_M_URI,null,'0','-1','false'};
        private String[] customDataTypeTranslations_type_info = new String[]{'customDataTypeTranslations',SOAP_M_URI,null,'0','-1','false'};
        private String[] customLabels_type_info = new String[]{'customLabels',SOAP_M_URI,null,'0','-1','false'};
        private String[] customPageWebLinks_type_info = new String[]{'customPageWebLinks',SOAP_M_URI,null,'0','-1','false'};
        private String[] customTabs_type_info = new String[]{'customTabs',SOAP_M_URI,null,'0','-1','false'};
        private String[] quickActions_type_info = new String[]{'quickActions',SOAP_M_URI,null,'0','-1','false'};
        private String[] reportTypes_type_info = new String[]{'reportTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] scontrols_type_info = new String[]{'scontrols',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customApplications','customDataTypeTranslations','customLabels','customPageWebLinks','customTabs','quickActions','reportTypes','scontrols'};
    }
    public class WebToCaseSettings {
        public String caseOrigin;
        public String defaultResponseTemplate;
        public Boolean enableWebToCase;
        private String[] caseOrigin_type_info = new String[]{'caseOrigin',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultResponseTemplate_type_info = new String[]{'defaultResponseTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] enableWebToCase_type_info = new String[]{'enableWebToCase',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'caseOrigin','defaultResponseTemplate','enableWebToCase'};
    }
    public class CustomMetadata extends Metadata {
        public String type = 'CustomMetadata';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String label;
        public Boolean protected_x;
        public MetadataService.CustomMetadataValue[] values;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'0','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','label','protected_x','values'};
    }
    public class FileProperties {
        public String createdById;
        public String createdByName;
        public DateTime createdDate;
        public String fileName;
        public String fullName;
        public String id;
        public String lastModifiedById;
        public String lastModifiedByName;
        public DateTime lastModifiedDate;
        public String manageableState;
        public String namespacePrefix;
        public String type_x;
        private String[] createdById_type_info = new String[]{'createdById',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedById_type_info = new String[]{'lastModifiedById',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'1','1','false'};
        private String[] manageableState_type_info = new String[]{'manageableState',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
    }
    public class OrderSettings extends Metadata {
        public String type = 'OrderSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableNegativeQuantity;
        public Boolean enableOrders;
        public Boolean enableReductionOrders;
        private String[] enableNegativeQuantity_type_info = new String[]{'enableNegativeQuantity',SOAP_M_URI,null,'0','1','false'};
        private String[] enableOrders_type_info = new String[]{'enableOrders',SOAP_M_URI,null,'0','1','false'};
        private String[] enableReductionOrders_type_info = new String[]{'enableReductionOrders',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableNegativeQuantity','enableOrders','enableReductionOrders'};
    }
    public class ReportTimeFrameFilter {
        public String dateColumn;
        public Date endDate;
        public String interval;
        public Date startDate;
        private String[] dateColumn_type_info = new String[]{'dateColumn',SOAP_M_URI,null,'1','1','false'};
        private String[] endDate_type_info = new String[]{'endDate',SOAP_M_URI,null,'0','1','false'};
        private String[] interval_type_info = new String[]{'interval',SOAP_M_URI,null,'1','1','false'};
        private String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dateColumn','endDate','interval','startDate'};
    }
    public class ContentAssetLink {
        public String access;
        public String name;
        private String[] access_type_info = new String[]{'access',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'access','name'};
    }
    public class StandardValue extends CustomValue {
        public String type = 'StandardValue';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'0','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        public Boolean allowEmail;
        public Boolean closed;
        public Boolean converted;
        public Boolean cssExposed;
        public String forecastCategory;
        public Boolean highPriority;
        public Integer probability;
        public String reverseRole;
        public Boolean reviewed;
        public Boolean won;
        private String[] allowEmail_type_info = new String[]{'allowEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] closed_type_info = new String[]{'closed',SOAP_M_URI,null,'0','1','false'};
        private String[] converted_type_info = new String[]{'converted',SOAP_M_URI,null,'0','1','false'};
        private String[] cssExposed_type_info = new String[]{'cssExposed',SOAP_M_URI,null,'0','1','false'};
        private String[] forecastCategory_type_info = new String[]{'forecastCategory',SOAP_M_URI,null,'0','1','false'};
        private String[] highPriority_type_info = new String[]{'highPriority',SOAP_M_URI,null,'0','1','false'};
        private String[] probability_type_info = new String[]{'probability',SOAP_M_URI,null,'0','1','false'};
        private String[] reverseRole_type_info = new String[]{'reverseRole',SOAP_M_URI,null,'0','1','false'};
        private String[] reviewed_type_info = new String[]{'reviewed',SOAP_M_URI,null,'0','1','false'};
        private String[] won_type_info = new String[]{'won',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','color','default_x','description','isActive', 'allowEmail','closed','converted','cssExposed','forecastCategory','highPriority','probability','reverseRole','reviewed','won'};
    }
    public class ProductSettings extends Metadata {
        public String type = 'ProductSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableCascadeActivateToRelatedPrices;
        public Boolean enableQuantitySchedule;
        public Boolean enableRevenueSchedule;
        private String[] enableCascadeActivateToRelatedPrices_type_info = new String[]{'enableCascadeActivateToRelatedPrices',SOAP_M_URI,null,'0','1','false'};
        private String[] enableQuantitySchedule_type_info = new String[]{'enableQuantitySchedule',SOAP_M_URI,null,'0','1','false'};
        private String[] enableRevenueSchedule_type_info = new String[]{'enableRevenueSchedule',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableCascadeActivateToRelatedPrices','enableQuantitySchedule','enableRevenueSchedule'};
    }
    public class WorkflowTask extends WorkflowAction {
        public String type = 'WorkflowTask';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String assignedTo;
        public String assignedToType;
        public String description;
        public Integer dueDateOffset;
        public Boolean notifyAssignee;
        public String offsetFromField;
        public String priority;
        public Boolean protected_x;
        public String status;
        public String subject;
        private String[] assignedTo_type_info = new String[]{'assignedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] assignedToType_type_info = new String[]{'assignedToType',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] dueDateOffset_type_info = new String[]{'dueDateOffset',SOAP_M_URI,null,'1','1','false'};
        private String[] notifyAssignee_type_info = new String[]{'notifyAssignee',SOAP_M_URI,null,'1','1','false'};
        private String[] offsetFromField_type_info = new String[]{'offsetFromField',SOAP_M_URI,null,'0','1','false'};
        private String[] priority_type_info = new String[]{'priority',SOAP_M_URI,null,'1','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] subject_type_info = new String[]{'subject',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assignedTo','assignedToType','description','dueDateOffset','notifyAssignee','offsetFromField','priority','protected_x','status','subject'};
    }
    public class GlobalValueSetTranslation {
        public MetadataService.ValueTranslation[] valueTranslation;
        private String[] valueTranslation_type_info = new String[]{'valueTranslation',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'valueTranslation'};
    }
    public class deployResponse_element {
        public MetadataService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class FeedItemSettings {
        public Integer characterLimit;
        public Boolean collapseThread;
        public String displayFormat;
        public String feedItemType;
        private String[] characterLimit_type_info = new String[]{'characterLimit',SOAP_M_URI,null,'0','1','false'};
        private String[] collapseThread_type_info = new String[]{'collapseThread',SOAP_M_URI,null,'0','1','false'};
        private String[] displayFormat_type_info = new String[]{'displayFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'characterLimit','collapseThread','displayFormat','feedItemType'};
    }
    public class AgentConfigAssignments {
        public MetadataService.AgentConfigProfileAssignments profiles;
        public MetadataService.AgentConfigUserAssignments users;
        private String[] profiles_type_info = new String[]{'profiles',SOAP_M_URI,null,'0','1','false'};
        private String[] users_type_info = new String[]{'users',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'profiles','users'};
    }
    public class ApprovalStepApprover {
        public MetadataService.Approver[] approver;
        public String whenMultipleApprovers;
        private String[] approver_type_info = new String[]{'approver',SOAP_M_URI,null,'0','-1','false'};
        private String[] whenMultipleApprovers_type_info = new String[]{'whenMultipleApprovers',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'approver','whenMultipleApprovers'};
    }
    public class ApexTrigger extends MetadataWithContent {
        public String type = 'ApexTrigger';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public MetadataService.PackageVersion[] packageVersions;
        public String status;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'apiVersion','packageVersions','status'};
    }
    public class CustomConsoleComponents {
        public MetadataService.PrimaryTabComponents primaryTabComponents;
        public MetadataService.SubtabComponents subtabComponents;
        private String[] primaryTabComponents_type_info = new String[]{'primaryTabComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] subtabComponents_type_info = new String[]{'subtabComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'primaryTabComponents','subtabComponents'};
    }
    public class TouchMobileSettings {
        public Boolean enableTouchAppIPad;
        public Boolean enableTouchAppIPhone;
        public Boolean enableTouchBrowserIPad;
        public Boolean enableTouchIosPhone;
        public Boolean enableVisualforceInTouch;
        private String[] enableTouchAppIPad_type_info = new String[]{'enableTouchAppIPad',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTouchAppIPhone_type_info = new String[]{'enableTouchAppIPhone',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTouchBrowserIPad_type_info = new String[]{'enableTouchBrowserIPad',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTouchIosPhone_type_info = new String[]{'enableTouchIosPhone',SOAP_M_URI,null,'0','1','false'};
        private String[] enableVisualforceInTouch_type_info = new String[]{'enableVisualforceInTouch',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableTouchAppIPad','enableTouchAppIPhone','enableTouchBrowserIPad','enableTouchIosPhone','enableVisualforceInTouch'};
    }
    public class AppMenu extends Metadata {
        public String type = 'AppMenu';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AppMenuItem[] appMenuItems;
        private String[] appMenuItems_type_info = new String[]{'appMenuItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'appMenuItems'};
    }
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    public class Report extends Metadata {
        public String type = 'Report';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ReportAggregate[] aggregates;
        public MetadataService.Report[] block;
        public MetadataService.ReportBlockInfo blockInfo;
        public MetadataService.ReportBucketField[] buckets;
        public MetadataService.ReportChart chart;
        public MetadataService.ReportColorRange[] colorRanges;
        public MetadataService.ReportColumn[] columns;
        public MetadataService.ReportCrossFilter[] crossFilters;
        public String currency_x;
        public MetadataService.ReportDataCategoryFilter[] dataCategoryFilters;
        public String description;
        public String division;
        public MetadataService.ReportFilter filter;
        public String folderName;
        public String format;
        public MetadataService.ReportGrouping[] groupingsAcross;
        public MetadataService.ReportGrouping[] groupingsDown;
        public MetadataService.ReportHistoricalSelector historicalSelector;
        public String name;
        public Integer numSubscriptions;
        public MetadataService.ReportParam[] params;
        public String reportType;
        public String roleHierarchyFilter;
        public Integer rowLimit;
        public String scope;
        public Boolean showCurrentDate;
        public Boolean showDetails;
        public String sortColumn;
        public String sortOrder;
        public String territoryHierarchyFilter;
        public MetadataService.ReportTimeFrameFilter timeFrameFilter;
        public String userFilter;
        private String[] aggregates_type_info = new String[]{'aggregates',SOAP_M_URI,null,'0','-1','false'};
        private String[] block_type_info = new String[]{'block',SOAP_M_URI,null,'0','-1','false'};
        private String[] blockInfo_type_info = new String[]{'blockInfo',SOAP_M_URI,null,'0','1','false'};
        private String[] buckets_type_info = new String[]{'buckets',SOAP_M_URI,null,'0','-1','false'};
        private String[] chart_type_info = new String[]{'chart',SOAP_M_URI,null,'0','1','false'};
        private String[] colorRanges_type_info = new String[]{'colorRanges',SOAP_M_URI,null,'0','-1','false'};
        private String[] columns_type_info = new String[]{'columns',SOAP_M_URI,null,'0','-1','false'};
        private String[] crossFilters_type_info = new String[]{'crossFilters',SOAP_M_URI,null,'0','-1','false'};
        private String[] currency_x_type_info = new String[]{'currency',SOAP_M_URI,null,'0','1','false'};
        private String[] dataCategoryFilters_type_info = new String[]{'dataCategoryFilters',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] division_type_info = new String[]{'division',SOAP_M_URI,null,'0','1','false'};
        private String[] filter_type_info = new String[]{'filter',SOAP_M_URI,null,'0','1','false'};
        private String[] folderName_type_info = new String[]{'folderName',SOAP_M_URI,null,'0','1','false'};
        private String[] format_type_info = new String[]{'format',SOAP_M_URI,null,'1','1','false'};
        private String[] groupingsAcross_type_info = new String[]{'groupingsAcross',SOAP_M_URI,null,'0','-1','false'};
        private String[] groupingsDown_type_info = new String[]{'groupingsDown',SOAP_M_URI,null,'0','-1','false'};
        private String[] historicalSelector_type_info = new String[]{'historicalSelector',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] numSubscriptions_type_info = new String[]{'numSubscriptions',SOAP_M_URI,null,'0','1','false'};
        private String[] params_type_info = new String[]{'params',SOAP_M_URI,null,'0','-1','false'};
        private String[] reportType_type_info = new String[]{'reportType',SOAP_M_URI,null,'1','1','false'};
        private String[] roleHierarchyFilter_type_info = new String[]{'roleHierarchyFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] rowLimit_type_info = new String[]{'rowLimit',SOAP_M_URI,null,'0','1','false'};
        private String[] scope_type_info = new String[]{'scope',SOAP_M_URI,null,'0','1','false'};
        private String[] showCurrentDate_type_info = new String[]{'showCurrentDate',SOAP_M_URI,null,'0','1','false'};
        private String[] showDetails_type_info = new String[]{'showDetails',SOAP_M_URI,null,'0','1','false'};
        private String[] sortColumn_type_info = new String[]{'sortColumn',SOAP_M_URI,null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] territoryHierarchyFilter_type_info = new String[]{'territoryHierarchyFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] timeFrameFilter_type_info = new String[]{'timeFrameFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] userFilter_type_info = new String[]{'userFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'aggregates','block','blockInfo','buckets','chart','colorRanges','columns','crossFilters','currency_x','dataCategoryFilters','description','division','filter','folderName','format','groupingsAcross','groupingsDown','historicalSelector','name','numSubscriptions','params','reportType','roleHierarchyFilter','rowLimit','scope','showCurrentDate','showDetails','sortColumn','sortOrder','territoryHierarchyFilter','timeFrameFilter','userFilter'};
    }
    public class KnowledgeSettings extends Metadata {
        public String type = 'KnowledgeSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.KnowledgeAnswerSettings answers;
        public MetadataService.KnowledgeCaseSettings cases;
        public String defaultLanguage;
        public Boolean enableChatterQuestionKBDeflection;
        public Boolean enableCreateEditOnArticlesTab;
        public Boolean enableExternalMediaContent;
        public Boolean enableKnowledge;
        public MetadataService.KnowledgeLanguageSettings languages;
        public Boolean showArticleSummariesCustomerPortal;
        public Boolean showArticleSummariesInternalApp;
        public Boolean showArticleSummariesPartnerPortal;
        public Boolean showValidationStatusField;
        public MetadataService.KnowledgeSuggestedArticlesSettings suggestedArticles;
        private String[] answers_type_info = new String[]{'answers',SOAP_M_URI,null,'0','1','false'};
        private String[] cases_type_info = new String[]{'cases',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultLanguage_type_info = new String[]{'defaultLanguage',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatterQuestionKBDeflection_type_info = new String[]{'enableChatterQuestionKBDeflection',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCreateEditOnArticlesTab_type_info = new String[]{'enableCreateEditOnArticlesTab',SOAP_M_URI,null,'0','1','false'};
        private String[] enableExternalMediaContent_type_info = new String[]{'enableExternalMediaContent',SOAP_M_URI,null,'0','1','false'};
        private String[] enableKnowledge_type_info = new String[]{'enableKnowledge',SOAP_M_URI,null,'0','1','false'};
        private String[] languages_type_info = new String[]{'languages',SOAP_M_URI,null,'0','1','false'};
        private String[] showArticleSummariesCustomerPortal_type_info = new String[]{'showArticleSummariesCustomerPortal',SOAP_M_URI,null,'0','1','false'};
        private String[] showArticleSummariesInternalApp_type_info = new String[]{'showArticleSummariesInternalApp',SOAP_M_URI,null,'0','1','false'};
        private String[] showArticleSummariesPartnerPortal_type_info = new String[]{'showArticleSummariesPartnerPortal',SOAP_M_URI,null,'0','1','false'};
        private String[] showValidationStatusField_type_info = new String[]{'showValidationStatusField',SOAP_M_URI,null,'0','1','false'};
        private String[] suggestedArticles_type_info = new String[]{'suggestedArticles',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'answers','cases','defaultLanguage','enableChatterQuestionKBDeflection','enableCreateEditOnArticlesTab','enableExternalMediaContent','enableKnowledge','languages','showArticleSummariesCustomerPortal','showArticleSummariesInternalApp','showArticleSummariesPartnerPortal','showValidationStatusField','suggestedArticles'};
    }
    public class StaticResource extends MetadataWithContent {
        public String type = 'StaticResource';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String cacheControl;
        public String contentType;
        public String description;
        private String[] cacheControl_type_info = new String[]{'cacheControl',SOAP_M_URI,null,'1','1','false'};
        private String[] contentType_type_info = new String[]{'contentType',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'cacheControl','contentType','description'};
    }
    public class ReportTypeColumn {
        public Boolean checkedByDefault;
        public String displayNameOverride;
        public String field;
        public String table;
        private String[] checkedByDefault_type_info = new String[]{'checkedByDefault',SOAP_M_URI,null,'1','1','false'};
        private String[] displayNameOverride_type_info = new String[]{'displayNameOverride',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] table_type_info = new String[]{'table',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'checkedByDefault','displayNameOverride','field','table'};
    }
    public class ApprovalStep {
        public Boolean allowDelegate;
        public MetadataService.ApprovalAction approvalActions;
        public MetadataService.ApprovalStepApprover assignedApprover;
        public String description;
        public MetadataService.ApprovalEntryCriteria entryCriteria;
        public String ifCriteriaNotMet;
        public String label;
        public String name;
        public MetadataService.ApprovalStepRejectBehavior rejectBehavior;
        public MetadataService.ApprovalAction rejectionActions;
        private String[] allowDelegate_type_info = new String[]{'allowDelegate',SOAP_M_URI,null,'0','1','false'};
        private String[] approvalActions_type_info = new String[]{'approvalActions',SOAP_M_URI,null,'0','1','false'};
        private String[] assignedApprover_type_info = new String[]{'assignedApprover',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] entryCriteria_type_info = new String[]{'entryCriteria',SOAP_M_URI,null,'0','1','false'};
        private String[] ifCriteriaNotMet_type_info = new String[]{'ifCriteriaNotMet',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] rejectBehavior_type_info = new String[]{'rejectBehavior',SOAP_M_URI,null,'0','1','false'};
        private String[] rejectionActions_type_info = new String[]{'rejectionActions',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowDelegate','approvalActions','assignedApprover','description','entryCriteria','ifCriteriaNotMet','label','name','rejectBehavior','rejectionActions'};
    }
    public class RecordTypeTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class WorkflowActionReference {
        public String name;
        public String type_x;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','type_x'};
    }
    public class FilterItem {
        public String field;
        public String operation;
        public String value;
        public String valueField;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] valueField_type_info = new String[]{'valueField',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','operation','value','valueField'};
    }
    public class OpportunityListFieldsUnselectedSettings {
        public String[] field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    public class ReportChartComponentLayoutItem {
        public Boolean cacheData;
        public String contextFilterableField;
        public String error;
        public Boolean hideOnError;
        public Boolean includeContext;
        public String reportName;
        public Boolean showTitle;
        public String size;
        private String[] cacheData_type_info = new String[]{'cacheData',SOAP_M_URI,null,'0','1','false'};
        private String[] contextFilterableField_type_info = new String[]{'contextFilterableField',SOAP_M_URI,null,'0','1','false'};
        private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
        private String[] includeContext_type_info = new String[]{'includeContext',SOAP_M_URI,null,'0','1','false'};
        private String[] reportName_type_info = new String[]{'reportName',SOAP_M_URI,null,'1','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
        private String[] size_type_info = new String[]{'size',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'cacheData','contextFilterableField','error','hideOnError','includeContext','reportName','showTitle','size'};
    }
    public class StandardValueSetTranslation {
        public MetadataService.ValueTranslation[] valueTranslation;
        private String[] valueTranslation_type_info = new String[]{'valueTranslation',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'valueTranslation'};
    }
    public class ChatterAnswersSettings extends Metadata {
        public String type = 'ChatterAnswersSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean emailFollowersOnBestAnswer;
        public Boolean emailFollowersOnReply;
        public Boolean emailOwnerOnPrivateReply;
        public Boolean emailOwnerOnReply;
        public Boolean enableAnswerViaEmail;
        public Boolean enableChatterAnswers;
        public Boolean enableFacebookSSO;
        public Boolean enableInlinePublisher;
        public Boolean enableReputation;
        public Boolean enableRichTextEditor;
        public String facebookAuthProvider;
        public Boolean showInPortals;
        private String[] emailFollowersOnBestAnswer_type_info = new String[]{'emailFollowersOnBestAnswer',SOAP_M_URI,null,'0','1','false'};
        private String[] emailFollowersOnReply_type_info = new String[]{'emailFollowersOnReply',SOAP_M_URI,null,'0','1','false'};
        private String[] emailOwnerOnPrivateReply_type_info = new String[]{'emailOwnerOnPrivateReply',SOAP_M_URI,null,'0','1','false'};
        private String[] emailOwnerOnReply_type_info = new String[]{'emailOwnerOnReply',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAnswerViaEmail_type_info = new String[]{'enableAnswerViaEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatterAnswers_type_info = new String[]{'enableChatterAnswers',SOAP_M_URI,null,'1','1','false'};
        private String[] enableFacebookSSO_type_info = new String[]{'enableFacebookSSO',SOAP_M_URI,null,'0','1','false'};
        private String[] enableInlinePublisher_type_info = new String[]{'enableInlinePublisher',SOAP_M_URI,null,'0','1','false'};
        private String[] enableReputation_type_info = new String[]{'enableReputation',SOAP_M_URI,null,'0','1','false'};
        private String[] enableRichTextEditor_type_info = new String[]{'enableRichTextEditor',SOAP_M_URI,null,'0','1','false'};
        private String[] facebookAuthProvider_type_info = new String[]{'facebookAuthProvider',SOAP_M_URI,null,'0','1','false'};
        private String[] showInPortals_type_info = new String[]{'showInPortals',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'emailFollowersOnBestAnswer','emailFollowersOnReply','emailOwnerOnPrivateReply','emailOwnerOnReply','enableAnswerViaEmail','enableChatterAnswers','enableFacebookSSO','enableInlinePublisher','enableReputation','enableRichTextEditor','facebookAuthProvider','showInPortals'};
    }
    public class ConnectedAppCanvasConfig {
        public String accessMethod;
        public String canvasUrl;
        public String lifecycleClass;
        public String[] locations;
        public String[] options;
        public String samlInitiationMethod;
        private String[] accessMethod_type_info = new String[]{'accessMethod',SOAP_M_URI,null,'1','1','false'};
        private String[] canvasUrl_type_info = new String[]{'canvasUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] lifecycleClass_type_info = new String[]{'lifecycleClass',SOAP_M_URI,null,'0','1','false'};
        private String[] locations_type_info = new String[]{'locations',SOAP_M_URI,null,'0','-1','false'};
        private String[] options_type_info = new String[]{'options',SOAP_M_URI,null,'0','-1','false'};
        private String[] samlInitiationMethod_type_info = new String[]{'samlInitiationMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'accessMethod','canvasUrl','lifecycleClass','locations','options','samlInitiationMethod'};
    }
    public class QuotasSettings {
        public Boolean showQuotas;
        private String[] showQuotas_type_info = new String[]{'showQuotas',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'showQuotas'};
    }
    public class OrgPreferenceSettings extends Metadata {
        public String type = 'OrgPreferenceSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.OrganizationSettingsDetail[] preferences;
        private String[] preferences_type_info = new String[]{'preferences',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'preferences'};
    }
    public class Community extends Metadata {
        public String type = 'Community';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String chatterAnswersFacebookSsoUrl;
        public String communityFeedPage;
        public String dataCategoryName;
        public String description;
        public String emailFooterDocument;
        public String emailHeaderDocument;
        public String emailNotificationUrl;
        public Boolean enableChatterAnswers;
        public Boolean enablePrivateQuestions;
        public String expertsGroup;
        public String portal;
        public MetadataService.ReputationLevels reputationLevels;
        public Boolean showInPortal;
        public String site;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersFacebookSsoUrl_type_info = new String[]{'chatterAnswersFacebookSsoUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] communityFeedPage_type_info = new String[]{'communityFeedPage',SOAP_M_URI,null,'0','1','false'};
        private String[] dataCategoryName_type_info = new String[]{'dataCategoryName',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] emailFooterDocument_type_info = new String[]{'emailFooterDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] emailHeaderDocument_type_info = new String[]{'emailHeaderDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] emailNotificationUrl_type_info = new String[]{'emailNotificationUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatterAnswers_type_info = new String[]{'enableChatterAnswers',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePrivateQuestions_type_info = new String[]{'enablePrivateQuestions',SOAP_M_URI,null,'0','1','false'};
        private String[] expertsGroup_type_info = new String[]{'expertsGroup',SOAP_M_URI,null,'0','1','false'};
        private String[] portal_type_info = new String[]{'portal',SOAP_M_URI,null,'0','1','false'};
        private String[] reputationLevels_type_info = new String[]{'reputationLevels',SOAP_M_URI,null,'0','1','false'};
        private String[] showInPortal_type_info = new String[]{'showInPortal',SOAP_M_URI,null,'0','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','chatterAnswersFacebookSsoUrl','communityFeedPage','dataCategoryName','description','emailFooterDocument','emailHeaderDocument','emailNotificationUrl','enableChatterAnswers','enablePrivateQuestions','expertsGroup','portal','reputationLevels','showInPortal','site'};
    }
    public class BusinessProcess extends Metadata {
        public String type = 'BusinessProcess';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public Boolean isActive;
        public MetadataService.PicklistValue[] values;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','isActive','values'};
    }
    public class EmailToCaseRoutingAddress {
        public String addressType;
        public String authorizedSenders;
        public String caseOrigin;
        public String caseOwner;
        public String caseOwnerType;
        public String casePriority;
        public Boolean createTask;
        public String emailAddress;
        public String emailServicesAddress;
        public Boolean isVerified;
        public String routingName;
        public Boolean saveEmailHeaders;
        public String taskStatus;
        private String[] addressType_type_info = new String[]{'addressType',SOAP_M_URI,null,'0','1','false'};
        private String[] authorizedSenders_type_info = new String[]{'authorizedSenders',SOAP_M_URI,null,'0','1','false'};
        private String[] caseOrigin_type_info = new String[]{'caseOrigin',SOAP_M_URI,null,'0','1','false'};
        private String[] caseOwner_type_info = new String[]{'caseOwner',SOAP_M_URI,null,'0','1','false'};
        private String[] caseOwnerType_type_info = new String[]{'caseOwnerType',SOAP_M_URI,null,'0','1','false'};
        private String[] casePriority_type_info = new String[]{'casePriority',SOAP_M_URI,null,'0','1','false'};
        private String[] createTask_type_info = new String[]{'createTask',SOAP_M_URI,null,'0','1','false'};
        private String[] emailAddress_type_info = new String[]{'emailAddress',SOAP_M_URI,null,'0','1','false'};
        private String[] emailServicesAddress_type_info = new String[]{'emailServicesAddress',SOAP_M_URI,null,'0','1','false'};
        private String[] isVerified_type_info = new String[]{'isVerified',SOAP_M_URI,null,'0','1','false'};
        private String[] routingName_type_info = new String[]{'routingName',SOAP_M_URI,null,'0','1','false'};
        private String[] saveEmailHeaders_type_info = new String[]{'saveEmailHeaders',SOAP_M_URI,null,'0','1','false'};
        private String[] taskStatus_type_info = new String[]{'taskStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'addressType','authorizedSenders','caseOrigin','caseOwner','caseOwnerType','casePriority','createTask','emailAddress','emailServicesAddress','isVerified','routingName','saveEmailHeaders','taskStatus'};
    }
    public class DataCategory {
        public MetadataService.DataCategory[] dataCategory;
        public String label;
        public String name;
        private String[] dataCategory_type_info = new String[]{'dataCategory',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dataCategory','label','name'};
    }
    public class PermissionSetTabSetting {
        public String tab;
        public String visibility;
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'tab','visibility'};
    }
    public class ReportHistoricalSelector {
        public String[] snapshot;
        private String[] snapshot_type_info = new String[]{'snapshot',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'snapshot'};
    }
    public class PermissionSetUserPermission {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    public class SharingRules extends Metadata {
        public String type = 'SharingRules';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.SharingCriteriaRule[] sharingCriteriaRules;
        public MetadataService.SharingOwnerRule[] sharingOwnerRules;
        public MetadataService.SharingTerritoryRule[] sharingTerritoryRules;
        private String[] sharingCriteriaRules_type_info = new String[]{'sharingCriteriaRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharingOwnerRules_type_info = new String[]{'sharingOwnerRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharingTerritoryRules_type_info = new String[]{'sharingTerritoryRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'sharingCriteriaRules','sharingOwnerRules','sharingTerritoryRules'};
    }
    public class SharingRecalculation {
        public String className;
        private String[] className_type_info = new String[]{'className',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'className'};
    }
    public class CustomLabels extends Metadata {
        public String type = 'CustomLabels';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CustomLabel[] labels;
        private String[] labels_type_info = new String[]{'labels',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'labels'};
    }
    public class RelatedContentItem {
        public MetadataService.LayoutItem layoutItem;
        private String[] layoutItem_type_info = new String[]{'layoutItem',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutItem'};
    }
    public class LiveAgentConfig {
        public Boolean enableLiveChat;
        public Boolean openNewAccountSubtab;
        public Boolean openNewCaseSubtab;
        public Boolean openNewContactSubtab;
        public Boolean openNewLeadSubtab;
        public Boolean openNewVFPageSubtab;
        public MetadataService.PagesToOpen pagesToOpen;
        public Boolean showKnowledgeArticles;
        private String[] enableLiveChat_type_info = new String[]{'enableLiveChat',SOAP_M_URI,null,'0','1','false'};
        private String[] openNewAccountSubtab_type_info = new String[]{'openNewAccountSubtab',SOAP_M_URI,null,'0','1','false'};
        private String[] openNewCaseSubtab_type_info = new String[]{'openNewCaseSubtab',SOAP_M_URI,null,'0','1','false'};
        private String[] openNewContactSubtab_type_info = new String[]{'openNewContactSubtab',SOAP_M_URI,null,'0','1','false'};
        private String[] openNewLeadSubtab_type_info = new String[]{'openNewLeadSubtab',SOAP_M_URI,null,'0','1','false'};
        private String[] openNewVFPageSubtab_type_info = new String[]{'openNewVFPageSubtab',SOAP_M_URI,null,'0','1','false'};
        private String[] pagesToOpen_type_info = new String[]{'pagesToOpen',SOAP_M_URI,null,'0','1','false'};
        private String[] showKnowledgeArticles_type_info = new String[]{'showKnowledgeArticles',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableLiveChat','openNewAccountSubtab','openNewCaseSubtab','openNewContactSubtab','openNewLeadSubtab','openNewVFPageSubtab','pagesToOpen','showKnowledgeArticles'};
    }
    public class RunTestsResult {
        public String apexLogId;
        public MetadataService.CodeCoverageResult[] codeCoverage;
        public MetadataService.CodeCoverageWarning[] codeCoverageWarnings;
        public MetadataService.RunTestFailure[] failures;
        public Integer numFailures;
        public Integer numTestsRun;
        public MetadataService.RunTestSuccess[] successes;
        public Double totalTime;
        private String[] apexLogId_type_info = new String[]{'apexLogId',SOAP_M_URI,null,'0','1','false'};
        private String[] codeCoverage_type_info = new String[]{'codeCoverage',SOAP_M_URI,null,'0','-1','false'};
        private String[] codeCoverageWarnings_type_info = new String[]{'codeCoverageWarnings',SOAP_M_URI,null,'0','-1','false'};
        private String[] failures_type_info = new String[]{'failures',SOAP_M_URI,null,'0','-1','false'};
        private String[] numFailures_type_info = new String[]{'numFailures',SOAP_M_URI,null,'1','1','false'};
        private String[] numTestsRun_type_info = new String[]{'numTestsRun',SOAP_M_URI,null,'1','1','false'};
        private String[] successes_type_info = new String[]{'successes',SOAP_M_URI,null,'0','-1','false'};
        private String[] totalTime_type_info = new String[]{'totalTime',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexLogId','codeCoverage','codeCoverageWarnings','failures','numFailures','numTestsRun','successes','totalTime'};
    }
    public class LicenseDefinition extends Metadata {
        public String type = 'LicenseDefinition';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String aggregationGroup;
        public String description;
        public Boolean isPublished;
        public String label;
        public MetadataService.LicensedCustomPermissions[] licensedCustomPermissions;
        public String licensingAuthority;
        public String licensingAuthorityProvider;
        public Integer minPlatformVersion;
        public String origin;
        public Integer revision;
        public Integer trialLicenseDuration;
        public Integer trialLicenseQuantity;
        private String[] aggregationGroup_type_info = new String[]{'aggregationGroup',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isPublished_type_info = new String[]{'isPublished',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] licensedCustomPermissions_type_info = new String[]{'licensedCustomPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] licensingAuthority_type_info = new String[]{'licensingAuthority',SOAP_M_URI,null,'1','1','false'};
        private String[] licensingAuthorityProvider_type_info = new String[]{'licensingAuthorityProvider',SOAP_M_URI,null,'1','1','false'};
        private String[] minPlatformVersion_type_info = new String[]{'minPlatformVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] origin_type_info = new String[]{'origin',SOAP_M_URI,null,'1','1','false'};
        private String[] revision_type_info = new String[]{'revision',SOAP_M_URI,null,'1','1','false'};
        private String[] trialLicenseDuration_type_info = new String[]{'trialLicenseDuration',SOAP_M_URI,null,'1','1','false'};
        private String[] trialLicenseQuantity_type_info = new String[]{'trialLicenseQuantity',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'aggregationGroup','description','isPublished','label','licensedCustomPermissions','licensingAuthority','licensingAuthorityProvider','minPlatformVersion','origin','revision','trialLicenseDuration','trialLicenseQuantity'};
    }
    public class DashboardGridLayout {
        public MetadataService.DashboardGridComponent[] dashboardGridComponents;
        public Integer numberOfColumns;
        public Integer rowHeight;
        private String[] dashboardGridComponents_type_info = new String[]{'dashboardGridComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] numberOfColumns_type_info = new String[]{'numberOfColumns',SOAP_M_URI,null,'1','1','false'};
        private String[] rowHeight_type_info = new String[]{'rowHeight',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dashboardGridComponents','numberOfColumns','rowHeight'};
    }
    public class AdjustmentsSettings {
        public Boolean enableAdjustments;
        public Boolean enableOwnerAdjustments;
        private String[] enableAdjustments_type_info = new String[]{'enableAdjustments',SOAP_M_URI,null,'1','1','false'};
        private String[] enableOwnerAdjustments_type_info = new String[]{'enableOwnerAdjustments',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableAdjustments','enableOwnerAdjustments'};
    }
    public class SummaryLayoutItem {
        public String customLink;
        public String field;
        public Integer posX;
        public Integer posY;
        public Integer posZ;
        private String[] customLink_type_info = new String[]{'customLink',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] posX_type_info = new String[]{'posX',SOAP_M_URI,null,'1','1','false'};
        private String[] posY_type_info = new String[]{'posY',SOAP_M_URI,null,'0','1','false'};
        private String[] posZ_type_info = new String[]{'posZ',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customLink','field','posX','posY','posZ'};
    }
    public class QuickActionLayoutItem {
        public Boolean emptySpace;
        public String field;
        public String uiBehavior;
        private String[] emptySpace_type_info = new String[]{'emptySpace',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] uiBehavior_type_info = new String[]{'uiBehavior',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'emptySpace','field','uiBehavior'};
    }
    public class DeployDetails {
        public MetadataService.DeployMessage[] componentFailures;
        public MetadataService.DeployMessage[] componentSuccesses;
        public MetadataService.RetrieveResult retrieveResult;
        public MetadataService.RunTestsResult runTestResult;
        private String[] componentFailures_type_info = new String[]{'componentFailures',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentSuccesses_type_info = new String[]{'componentSuccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] retrieveResult_type_info = new String[]{'retrieveResult',SOAP_M_URI,null,'0','1','false'};
        private String[] runTestResult_type_info = new String[]{'runTestResult',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentFailures','componentSuccesses','retrieveResult','runTestResult'};
    }
    public class FlexiPage extends Metadata {
        public String type = 'FlexiPage';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public MetadataService.FlexiPageRegion[] flexiPageRegions;
        public String masterLabel;
        public String pageTemplate;
        public String parentFlexiPage;
        public MetadataService.PlatformActionList platformActionlist;
        public MetadataService.QuickActionList quickActionList;
        public String sobjectType;
        public String type_x;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] flexiPageRegions_type_info = new String[]{'flexiPageRegions',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] pageTemplate_type_info = new String[]{'pageTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] parentFlexiPage_type_info = new String[]{'parentFlexiPage',SOAP_M_URI,null,'0','1','false'};
        private String[] platformActionlist_type_info = new String[]{'platformActionlist',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionList_type_info = new String[]{'quickActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] sobjectType_type_info = new String[]{'sobjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','flexiPageRegions','masterLabel','pageTemplate','parentFlexiPage','platformActionlist','quickActionList','sobjectType','type_x'};
    }
    public class EntitlementProcessMilestoneTimeTrigger {
        public MetadataService.WorkflowActionReference[] actions;
        public Integer timeLength;
        public String workflowTimeTriggerUnit;
        private String[] actions_type_info = new String[]{'actions',SOAP_M_URI,null,'0','-1','false'};
        private String[] timeLength_type_info = new String[]{'timeLength',SOAP_M_URI,null,'0','1','false'};
        private String[] workflowTimeTriggerUnit_type_info = new String[]{'workflowTimeTriggerUnit',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actions','timeLength','workflowTimeTriggerUnit'};
    }
    public class NavigationLinkSet {
        public MetadataService.NavigationMenuItem[] navigationMenuItem;
        private String[] navigationMenuItem_type_info = new String[]{'navigationMenuItem',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'navigationMenuItem'};
    }
    public class PlatformActionList {
        public String actionListContext;
        public MetadataService.PlatformActionListItem[] platformActionListItems;
        public String relatedSourceEntity;
        private String[] actionListContext_type_info = new String[]{'actionListContext',SOAP_M_URI,null,'1','1','false'};
        private String[] platformActionListItems_type_info = new String[]{'platformActionListItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedSourceEntity_type_info = new String[]{'relatedSourceEntity',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionListContext','platformActionListItems','relatedSourceEntity'};
    }
    public class CallCenter extends Metadata {
        public String type = 'CallCenter';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String adapterUrl;
        public String customSettings;
        public String displayName;
        public String displayNameLabel;
        public String internalNameLabel;
        public MetadataService.CallCenterSection[] sections;
        public String version;
        private String[] adapterUrl_type_info = new String[]{'adapterUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] customSettings_type_info = new String[]{'customSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] displayName_type_info = new String[]{'displayName',SOAP_M_URI,null,'1','1','false'};
        private String[] displayNameLabel_type_info = new String[]{'displayNameLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] internalNameLabel_type_info = new String[]{'internalNameLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] sections_type_info = new String[]{'sections',SOAP_M_URI,null,'0','-1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'adapterUrl','customSettings','displayName','displayNameLabel','internalNameLabel','sections','version'};
    }
    public class MarketingActionSettings extends Metadata {
        public String type = 'MarketingActionSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableMarketingAction;
        private String[] enableMarketingAction_type_info = new String[]{'enableMarketingAction',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableMarketingAction'};
    }
    public class AccountSharingRuleSettings {
        public String caseAccessLevel;
        public String contactAccessLevel;
        public String opportunityAccessLevel;
        private String[] caseAccessLevel_type_info = new String[]{'caseAccessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] contactAccessLevel_type_info = new String[]{'contactAccessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] opportunityAccessLevel_type_info = new String[]{'opportunityAccessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'caseAccessLevel','contactAccessLevel','opportunityAccessLevel'};
    }
    public class AgentConfigButtons {
        public String[] button;
        private String[] button_type_info = new String[]{'button',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'button'};
    }
    public class CustomShortcut {
        public String description;
        public String eventName;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] eventName_type_info = new String[]{'eventName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','eventName'};
    }
    public class ArticleTypeChannelDisplay {
        public MetadataService.ArticleTypeTemplate[] articleTypeTemplates;
        private String[] articleTypeTemplates_type_info = new String[]{'articleTypeTemplates',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'articleTypeTemplates'};
    }
    public class WorkflowOutboundMessage extends WorkflowAction {
        public String type = 'WorkflowOutboundMessage';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public String description;
        public String endpointUrl;
        public String[] fields;
        public Boolean includeSessionId;
        public String integrationUser;
        public String name;
        public Boolean protected_x;
        public Boolean useDeadLetterQueue;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] endpointUrl_type_info = new String[]{'endpointUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] includeSessionId_type_info = new String[]{'includeSessionId',SOAP_M_URI,null,'1','1','false'};
        private String[] integrationUser_type_info = new String[]{'integrationUser',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] useDeadLetterQueue_type_info = new String[]{'useDeadLetterQueue',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'apiVersion','description','endpointUrl','fields','includeSessionId','integrationUser','name','protected_x','useDeadLetterQueue'};
    }
    public class WaveDataset extends Metadata {
        public String type = 'WaveDataset';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String application;
        public String description;
        public String masterLabel;
        public String templateAssetSourceName;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] templateAssetSourceName_type_info = new String[]{'templateAssetSourceName',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'application','description','masterLabel','templateAssetSourceName'};
    }
    public class CorsWhitelistOrigin extends Metadata {
        public String type = 'CorsWhitelistOrigin';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String urlPattern;
        private String[] urlPattern_type_info = new String[]{'urlPattern',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'urlPattern'};
    }
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    public class AnalyticSnapshot extends Metadata {
        public String type = 'AnalyticSnapshot';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String groupColumn;
        public MetadataService.AnalyticSnapshotMapping[] mappings;
        public String name;
        public String runningUser;
        public String sourceReport;
        public String targetObject;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] groupColumn_type_info = new String[]{'groupColumn',SOAP_M_URI,null,'0','1','false'};
        private String[] mappings_type_info = new String[]{'mappings',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] runningUser_type_info = new String[]{'runningUser',SOAP_M_URI,null,'0','1','false'};
        private String[] sourceReport_type_info = new String[]{'sourceReport',SOAP_M_URI,null,'1','1','false'};
        private String[] targetObject_type_info = new String[]{'targetObject',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','groupColumn','mappings','name','runningUser','sourceReport','targetObject'};
    }
    public class ReputationPointsRules {
        public MetadataService.ReputationPointsRule[] pointsRule;
        private String[] pointsRule_type_info = new String[]{'pointsRule',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pointsRule'};
    }
    public class ProfileCustomPermissions {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    public class deployRecentValidationResponse_element {
        public String result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class IpRange {
        public String description;
        public String end_x;
        public String start;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] end_x_type_info = new String[]{'end',SOAP_M_URI,null,'0','1','false'};
        private String[] start_type_info = new String[]{'start',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','end_x','start'};
    }
    public class deployRecentValidation_element {
        public String validationId;
        private String[] validationId_type_info = new String[]{'validationId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'validationId'};
    }
    public class ManagedTopics extends Metadata {
        public String type = 'ManagedTopics';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ManagedTopic[] managedTopic;
        private String[] managedTopic_type_info = new String[]{'managedTopic',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'managedTopic'};
    }
    public class FeedFilterCriterion {
        public String feedItemType;
        public String feedItemVisibility;
        public String relatedSObjectType;
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
        private String[] feedItemVisibility_type_info = new String[]{'feedItemVisibility',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedSObjectType_type_info = new String[]{'relatedSObjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'feedItemType','feedItemVisibility','relatedSObjectType'};
    }
    public class ReportBlockInfo {
        public MetadataService.ReportAggregateReference[] aggregateReferences;
        public String blockId;
        public String joinTable;
        private String[] aggregateReferences_type_info = new String[]{'aggregateReferences',SOAP_M_URI,null,'0','-1','false'};
        private String[] blockId_type_info = new String[]{'blockId',SOAP_M_URI,null,'1','1','false'};
        private String[] joinTable_type_info = new String[]{'joinTable',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregateReferences','blockId','joinTable'};
    }
    public virtual class Folder extends Metadata {
        public String accessType;
        public MetadataService.FolderShare[] folderShares;
        public String name;
        public String publicFolderAccess;
        public MetadataService.SharedTo sharedTo;
    }
    public class Branding {
        public String loginFooterText;
        public String loginLogo;
        public String pageFooter;
        public String pageHeader;
        public String primaryColor;
        public String primaryComplementColor;
        public String quaternaryColor;
        public String quaternaryComplementColor;
        public String secondaryColor;
        public String tertiaryColor;
        public String tertiaryComplementColor;
        public String zeronaryColor;
        public String zeronaryComplementColor;
        private String[] loginFooterText_type_info = new String[]{'loginFooterText',SOAP_M_URI,null,'0','1','false'};
        private String[] loginLogo_type_info = new String[]{'loginLogo',SOAP_M_URI,null,'0','1','false'};
        private String[] pageFooter_type_info = new String[]{'pageFooter',SOAP_M_URI,null,'0','1','false'};
        private String[] pageHeader_type_info = new String[]{'pageHeader',SOAP_M_URI,null,'0','1','false'};
        private String[] primaryColor_type_info = new String[]{'primaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] primaryComplementColor_type_info = new String[]{'primaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] quaternaryColor_type_info = new String[]{'quaternaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] quaternaryComplementColor_type_info = new String[]{'quaternaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] secondaryColor_type_info = new String[]{'secondaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] tertiaryColor_type_info = new String[]{'tertiaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] tertiaryComplementColor_type_info = new String[]{'tertiaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] zeronaryColor_type_info = new String[]{'zeronaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] zeronaryComplementColor_type_info = new String[]{'zeronaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'loginFooterText','loginLogo','pageFooter','pageHeader','primaryColor','primaryComplementColor','quaternaryColor','quaternaryComplementColor','secondaryColor','tertiaryColor','tertiaryComplementColor','zeronaryColor','zeronaryComplementColor'};
    }
    public class Profile extends Metadata {
        public String type = 'Profile';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ProfileApplicationVisibility[] applicationVisibilities;
        public MetadataService.ProfileApexClassAccess[] classAccesses;
        public Boolean custom;
        public MetadataService.ProfileCustomPermissions[] customPermissions;
        public String description;
        public MetadataService.ProfileExternalDataSourceAccess[] externalDataSourceAccesses;
        public MetadataService.ProfileFieldLevelSecurity[] fieldPermissions;
        public MetadataService.ProfileLayoutAssignment[] layoutAssignments;
        public MetadataService.ProfileLoginHours loginHours;
        public MetadataService.ProfileLoginIpRange[] loginIpRanges;
        public MetadataService.ProfileObjectPermissions[] objectPermissions;
        public MetadataService.ProfileApexPageAccess[] pageAccesses;
        public MetadataService.ProfileActionOverride[] profileActionOverrides;
        public MetadataService.ProfileRecordTypeVisibility[] recordTypeVisibilities;
        public MetadataService.ProfileTabVisibility[] tabVisibilities;
        public String userLicense;
        public MetadataService.ProfileUserPermission[] userPermissions;
        private String[] applicationVisibilities_type_info = new String[]{'applicationVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] classAccesses_type_info = new String[]{'classAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] custom_type_info = new String[]{'custom',SOAP_M_URI,null,'0','1','false'};
        private String[] customPermissions_type_info = new String[]{'customPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDataSourceAccesses_type_info = new String[]{'externalDataSourceAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] fieldPermissions_type_info = new String[]{'fieldPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] layoutAssignments_type_info = new String[]{'layoutAssignments',SOAP_M_URI,null,'0','-1','false'};
        private String[] loginHours_type_info = new String[]{'loginHours',SOAP_M_URI,null,'0','1','false'};
        private String[] loginIpRanges_type_info = new String[]{'loginIpRanges',SOAP_M_URI,null,'0','-1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] pageAccesses_type_info = new String[]{'pageAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] profileActionOverrides_type_info = new String[]{'profileActionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] recordTypeVisibilities_type_info = new String[]{'recordTypeVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] tabVisibilities_type_info = new String[]{'tabVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] userLicense_type_info = new String[]{'userLicense',SOAP_M_URI,null,'0','1','false'};
        private String[] userPermissions_type_info = new String[]{'userPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'applicationVisibilities','classAccesses','custom','customPermissions','description','externalDataSourceAccesses','fieldPermissions','layoutAssignments','loginHours','loginIpRanges','objectPermissions','pageAccesses','profileActionOverrides','recordTypeVisibilities','tabVisibilities','userLicense','userPermissions'};
    }
    public class KnowledgeLanguage {
        public Boolean active;
        public String defaultAssignee;
        public String defaultAssigneeType;
        public String defaultReviewer;
        public String defaultReviewerType;
        public String name;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultAssignee_type_info = new String[]{'defaultAssignee',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultAssigneeType_type_info = new String[]{'defaultAssigneeType',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultReviewer_type_info = new String[]{'defaultReviewer',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultReviewerType_type_info = new String[]{'defaultReviewerType',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','defaultAssignee','defaultAssigneeType','defaultReviewer','defaultReviewerType','name'};
    }
    public class DeployOptions {
        public Boolean allowMissingFiles;
        public Boolean autoUpdatePackage;
        public Boolean checkOnly;
        public Boolean ignoreWarnings;
        public Boolean performRetrieve;
        public Boolean purgeOnDelete;
        public Boolean rollbackOnError;
        public String[] runTests;
        public Boolean singlePackage;
        public String testLevel;
        private String[] allowMissingFiles_type_info = new String[]{'allowMissingFiles',SOAP_M_URI,null,'1','1','false'};
        private String[] autoUpdatePackage_type_info = new String[]{'autoUpdatePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] performRetrieve_type_info = new String[]{'performRetrieve',SOAP_M_URI,null,'1','1','false'};
        private String[] purgeOnDelete_type_info = new String[]{'purgeOnDelete',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTests_type_info = new String[]{'runTests',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] testLevel_type_info = new String[]{'testLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowMissingFiles','autoUpdatePackage','checkOnly','ignoreWarnings','performRetrieve','purgeOnDelete','rollbackOnError','runTests','singlePackage','testLevel'};
    }
    public class FieldSet extends Metadata {
        public String type = 'FieldSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.FieldSetItem[] availableFields;
        public String description;
        public MetadataService.FieldSetItem[] displayedFields;
        public String label;
        private String[] availableFields_type_info = new String[]{'availableFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
        private String[] displayedFields_type_info = new String[]{'displayedFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availableFields','description','displayedFields','label'};
    }
    public class ProfileLoginHours {
        public String fridayEnd;
        public String fridayStart;
        public String mondayEnd;
        public String mondayStart;
        public String saturdayEnd;
        public String saturdayStart;
        public String sundayEnd;
        public String sundayStart;
        public String thursdayEnd;
        public String thursdayStart;
        public String tuesdayEnd;
        public String tuesdayStart;
        public String wednesdayEnd;
        public String wednesdayStart;
        private String[] fridayEnd_type_info = new String[]{'fridayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] fridayStart_type_info = new String[]{'fridayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayEnd_type_info = new String[]{'mondayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayStart_type_info = new String[]{'mondayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayEnd_type_info = new String[]{'saturdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayStart_type_info = new String[]{'saturdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayEnd_type_info = new String[]{'sundayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayStart_type_info = new String[]{'sundayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayEnd_type_info = new String[]{'thursdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayStart_type_info = new String[]{'thursdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayEnd_type_info = new String[]{'tuesdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayStart_type_info = new String[]{'tuesdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayEnd_type_info = new String[]{'wednesdayEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayStart_type_info = new String[]{'wednesdayStart',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fridayEnd','fridayStart','mondayEnd','mondayStart','saturdayEnd','saturdayStart','sundayEnd','sundayStart','thursdayEnd','thursdayStart','tuesdayEnd','tuesdayStart','wednesdayEnd','wednesdayStart'};
    }
    public class HomePageComponent extends Metadata {
        public String type = 'HomePageComponent';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String body;
        public Integer height;
        public String[] links;
        public String page_x;
        public String pageComponentType;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] body_type_info = new String[]{'body',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] links_type_info = new String[]{'links',SOAP_M_URI,null,'0','-1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] pageComponentType_type_info = new String[]{'pageComponentType',SOAP_M_URI,null,'1','1','false'};
        private String[] showLabel_type_info = new String[]{'showLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] showScrollbars_type_info = new String[]{'showScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'body','height','links','page_x','pageComponentType','showLabel','showScrollbars','width'};
    }
    public class PermissionSetFieldPermissions {
        public Boolean editable;
        public String field;
        public Boolean readable;
        private String[] editable_type_info = new String[]{'editable',SOAP_M_URI,null,'1','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] readable_type_info = new String[]{'readable',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'editable','field','readable'};
    }
    public class RetrieveRequest {
        public Double apiVersion;
        public String[] packageNames;
        public Boolean singlePackage;
        public String[] specificFiles;
        public MetadataService.Package_x unpackaged;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] packageNames_type_info = new String[]{'packageNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] specificFiles_type_info = new String[]{'specificFiles',SOAP_M_URI,null,'0','-1','false'};
        private String[] unpackaged_type_info = new String[]{'unpackaged',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiVersion','packageNames','singlePackage','specificFiles','unpackaged'};
    }
    public class ObjectRelationship {
        public MetadataService.ObjectRelationship join_x;
        public Boolean outerJoin;
        public String relationship;
        private String[] join_x_type_info = new String[]{'join',SOAP_M_URI,null,'0','1','false'};
        private String[] outerJoin_type_info = new String[]{'outerJoin',SOAP_M_URI,null,'1','1','false'};
        private String[] relationship_type_info = new String[]{'relationship',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'join_x','outerJoin','relationship'};
    }
    public class ReportLayoutSection {
        public MetadataService.ReportTypeColumn[] columns;
        public String masterLabel;
        private String[] columns_type_info = new String[]{'columns',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'columns','masterLabel'};
    }
    public class CompactLayout extends Metadata {
        public String type = 'CompactLayout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] fields;
        public String label;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'fields','label'};
    }
    public class VisualizationType {
        public String description;
        public String developerName;
        public String icon;
        public String masterLabel;
        public String scriptBootstrapMethod;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] scriptBootstrapMethod_type_info = new String[]{'scriptBootstrapMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','developerName','icon','masterLabel','scriptBootstrapMethod'};
    }
    public virtual class SharingBaseRule extends Metadata {
        public String accessLevel;
        public MetadataService.AccountSharingRuleSettings accountSettings;
        public String description;
        public String label;
        public MetadataService.SharedTo sharedTo;
    }
    public class AuthProvider extends Metadata {
        public String type = 'AuthProvider';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String authorizeUrl;
        public String consumerKey;
        public String consumerSecret;
        public String customMetadataTypeRecord;
        public String defaultScopes;
        public String errorUrl;
        public String executionUser;
        public String friendlyName;
        public String iconUrl;
        public String idTokenIssuer;
        public Boolean includeOrgIdInIdentifier;
        public String logoutUrl;
        public String plugin;
        public String portal;
        public String providerType;
        public String registrationHandler;
        public Boolean sendAccessTokenInHeader;
        public Boolean sendClientCredentialsInHeader;
        public String tokenUrl;
        public String userInfoUrl;
        private String[] authorizeUrl_type_info = new String[]{'authorizeUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] consumerKey_type_info = new String[]{'consumerKey',SOAP_M_URI,null,'0','1','false'};
        private String[] consumerSecret_type_info = new String[]{'consumerSecret',SOAP_M_URI,null,'0','1','false'};
        private String[] customMetadataTypeRecord_type_info = new String[]{'customMetadataTypeRecord',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultScopes_type_info = new String[]{'defaultScopes',SOAP_M_URI,null,'0','1','false'};
        private String[] errorUrl_type_info = new String[]{'errorUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] executionUser_type_info = new String[]{'executionUser',SOAP_M_URI,null,'0','1','false'};
        private String[] friendlyName_type_info = new String[]{'friendlyName',SOAP_M_URI,null,'1','1','false'};
        private String[] iconUrl_type_info = new String[]{'iconUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] idTokenIssuer_type_info = new String[]{'idTokenIssuer',SOAP_M_URI,null,'0','1','false'};
        private String[] includeOrgIdInIdentifier_type_info = new String[]{'includeOrgIdInIdentifier',SOAP_M_URI,null,'0','1','false'};
        private String[] logoutUrl_type_info = new String[]{'logoutUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] plugin_type_info = new String[]{'plugin',SOAP_M_URI,null,'0','1','false'};
        private String[] portal_type_info = new String[]{'portal',SOAP_M_URI,null,'0','1','false'};
        private String[] providerType_type_info = new String[]{'providerType',SOAP_M_URI,null,'1','1','false'};
        private String[] registrationHandler_type_info = new String[]{'registrationHandler',SOAP_M_URI,null,'0','1','false'};
        private String[] sendAccessTokenInHeader_type_info = new String[]{'sendAccessTokenInHeader',SOAP_M_URI,null,'0','1','false'};
        private String[] sendClientCredentialsInHeader_type_info = new String[]{'sendClientCredentialsInHeader',SOAP_M_URI,null,'0','1','false'};
        private String[] tokenUrl_type_info = new String[]{'tokenUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] userInfoUrl_type_info = new String[]{'userInfoUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'authorizeUrl','consumerKey','consumerSecret','customMetadataTypeRecord','defaultScopes','errorUrl','executionUser','friendlyName','iconUrl','idTokenIssuer','includeOrgIdInIdentifier','logoutUrl','plugin','portal','providerType','registrationHandler','sendAccessTokenInHeader','sendClientCredentialsInHeader','tokenUrl','userInfoUrl'};
    }
    public class RelatedContent {
        public MetadataService.RelatedContentItem[] relatedContentItems;
        private String[] relatedContentItems_type_info = new String[]{'relatedContentItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'relatedContentItems'};
    }
    public class WebLink extends Metadata {
        public String type = 'WebLink';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String availability;
        public String description;
        public String displayType;
        public String encodingKey;
        public Boolean hasMenubar;
        public Boolean hasScrollbars;
        public Boolean hasToolbar;
        public Integer height;
        public Boolean isResizable;
        public String linkType;
        public String masterLabel;
        public String openType;
        public String page_x;
        public String position;
        public Boolean protected_x;
        public Boolean requireRowSelection;
        public String scontrol;
        public Boolean showsLocation;
        public Boolean showsStatus;
        public String url;
        public Integer width;
        private String[] availability_type_info = new String[]{'availability',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayType_type_info = new String[]{'displayType',SOAP_M_URI,null,'1','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'0','1','false'};
        private String[] hasMenubar_type_info = new String[]{'hasMenubar',SOAP_M_URI,null,'0','1','false'};
        private String[] hasScrollbars_type_info = new String[]{'hasScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] hasToolbar_type_info = new String[]{'hasToolbar',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isResizable_type_info = new String[]{'isResizable',SOAP_M_URI,null,'0','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] openType_type_info = new String[]{'openType',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] requireRowSelection_type_info = new String[]{'requireRowSelection',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showsLocation_type_info = new String[]{'showsLocation',SOAP_M_URI,null,'0','1','false'};
        private String[] showsStatus_type_info = new String[]{'showsStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availability','description','displayType','encodingKey','hasMenubar','hasScrollbars','hasToolbar','height','isResizable','linkType','masterLabel','openType','page_x','position','protected_x','requireRowSelection','scontrol','showsLocation','showsStatus','url','width'};
    }

    ///
    // flow start
    public class Flow extends Metadata{
        public String type = 'Flow';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public FlowActionCall[] actionCalls;
        public FlowApexPluginCall[] apexPluginCalls;
        public Double apiVersion;
        public Boolean areMetricsLoggedToDataCloud;
        public FlowAssignment[] assignments;
        public FlowChoice[] choices;
        public FlowCollectionProcessor[] collectionProcessors;
        public FlowConstant[] constants;
        public FlowCustomError[] customErrors;
        public FlowCustomProperty[] customProperties;
        public FlowDecision[] decisions;
        public String description;
        public FlowDynamicChoiceSet[] dynamicChoiceSets;
        public String[] environments;
        public FlowExitRule[] exitRules;
        public FlowExperiment[] experiments;
        public FlowFormula[] formulas;
        public String interviewLabel;
        public Boolean isAdditionalPermissionRequiredToRun;
        public Boolean isOverridable;
        public Boolean isTemplate;
        public String label;
        public FlowLoop[] loops;
        public String migratedFromWorkflowRuleName;
        public FlowOrchestratedStage[] orchestratedStages;
        public String overriddenFlow;
        public FlowMetadataValue[] processMetadataValues;
        public String processType;
        public FlowRecordCreate[] recordCreates;
        public FlowRecordDelete[] recordDeletes;
        public FlowRecordLookup[] recordLookups;
        public FlowRecordRollback[] recordRollbacks;
        public FlowRecordUpdate[] recordUpdates;
        public String runInMode;
        public FlowScreen[] screens;
        public String sourceTemplate;
        public FlowStage[] stages;
        public FlowStart start;
        public String startElementReference;
        public String status;
        public FlowStep[] steps;
        public FlowSubflow[] subflows;
        public FlowTextTemplate[] textTemplates;
        public String timeZoneSidKey;
        public FlowTransform[] transforms;
        public Integer triggerOrder;
        public FlowVariable[] variables;
        public FlowWait[] waits;
        private String[] actionCalls_type_info = new String[]{'actionCalls',SOAP_M_URI,'FlowActionCall','0','-1','false'};
        private String[] apexPluginCalls_type_info = new String[]{'apexPluginCalls',SOAP_M_URI,'FlowApexPluginCall','0','-1','false'};
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,'double','0','1','true'};
        private String[] areMetricsLoggedToDataCloud_type_info = new String[]{'areMetricsLoggedToDataCloud',SOAP_M_URI,'boolean','0','1','false'};
        private String[] assignments_type_info = new String[]{'assignments',SOAP_M_URI,'FlowAssignment','0','-1','false'};
        private String[] choices_type_info = new String[]{'choices',SOAP_M_URI,'FlowChoice','0','-1','false'};
        private String[] collectionProcessors_type_info = new String[]{'collectionProcessors',SOAP_M_URI,'FlowCollectionProcessor','0','-1','false'};
        private String[] constants_type_info = new String[]{'constants',SOAP_M_URI,'FlowConstant','0','-1','false'};
        private String[] customErrors_type_info = new String[]{'customErrors',SOAP_M_URI,'FlowCustomError','0','-1','false'};
        private String[] customProperties_type_info = new String[]{'customProperties',SOAP_M_URI,'FlowCustomProperty','0','-1','false'};
        private String[] decisions_type_info = new String[]{'decisions',SOAP_M_URI,'FlowDecision','0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] dynamicChoiceSets_type_info = new String[]{'dynamicChoiceSets',SOAP_M_URI,'FlowDynamicChoiceSet','0','-1','false'};
        private String[] environments_type_info = new String[]{'environments',SOAP_M_URI,'FlowEnvironment','0','-1','false'};
        private String[] exitRules_type_info = new String[]{'exitRules',SOAP_M_URI,'FlowExitRule','0','-1','false'};
        private String[] experiments_type_info = new String[]{'experiments',SOAP_M_URI,'FlowExperiment','0','-1','false'};
        private String[] formulas_type_info = new String[]{'formulas',SOAP_M_URI,'FlowFormula','0','-1','false'};
        private String[] interviewLabel_type_info = new String[]{'interviewLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] isAdditionalPermissionRequiredToRun_type_info = new String[]{'isAdditionalPermissionRequiredToRun',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isOverridable_type_info = new String[]{'isOverridable',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isTemplate_type_info = new String[]{'isTemplate',SOAP_M_URI,'boolean','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] loops_type_info = new String[]{'loops',SOAP_M_URI,'FlowLoop','0','-1','false'};
        private String[] migratedFromWorkflowRuleName_type_info = new String[]{'migratedFromWorkflowRuleName',SOAP_M_URI,'string','0','1','false'};
        private String[] orchestratedStages_type_info = new String[]{'orchestratedStages',SOAP_M_URI,'FlowOrchestratedStage','0','-1','false'};
        private String[] overriddenFlow_type_info = new String[]{'overriddenFlow',SOAP_M_URI,'string','0','1','false'};
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        private String[] processType_type_info = new String[]{'processType',SOAP_M_URI,'FlowProcessType','0','1','false'};
        private String[] recordCreates_type_info = new String[]{'recordCreates',SOAP_M_URI,'FlowRecordCreate','0','-1','false'};
        private String[] recordDeletes_type_info = new String[]{'recordDeletes',SOAP_M_URI,'FlowRecordDelete','0','-1','false'};
        private String[] recordLookups_type_info = new String[]{'recordLookups',SOAP_M_URI,'FlowRecordLookup','0','-1','false'};
        private String[] recordRollbacks_type_info = new String[]{'recordRollbacks',SOAP_M_URI,'FlowRecordRollback','0','-1','false'};
        private String[] recordUpdates_type_info = new String[]{'recordUpdates',SOAP_M_URI,'FlowRecordUpdate','0','-1','false'};
        private String[] runInMode_type_info = new String[]{'runInMode',SOAP_M_URI,'FlowRunInMode','0','1','false'};
        private String[] screens_type_info = new String[]{'screens',SOAP_M_URI,'FlowScreen','0','-1','false'};
        private String[] sourceTemplate_type_info = new String[]{'sourceTemplate',SOAP_M_URI,'string','0','1','false'};
        private String[] stages_type_info = new String[]{'stages',SOAP_M_URI,'FlowStage','0','-1','false'};
        private String[] start_type_info = new String[]{'start',SOAP_M_URI,'FlowStart','0','1','false'};
        private String[] startElementReference_type_info = new String[]{'startElementReference',SOAP_M_URI,'string','0','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,'FlowVersionStatus','0','1','false'};
        private String[] steps_type_info = new String[]{'steps',SOAP_M_URI,'FlowStep','0','-1','false'};
        private String[] subflows_type_info = new String[]{'subflows',SOAP_M_URI,'FlowSubflow','0','-1','false'};
        private String[] textTemplates_type_info = new String[]{'textTemplates',SOAP_M_URI,'FlowTextTemplate','0','-1','false'};
        private String[] timeZoneSidKey_type_info = new String[]{'timeZoneSidKey',SOAP_M_URI,'string','0','1','false'};
        private String[] transforms_type_info = new String[]{'transforms',SOAP_M_URI,'FlowTransform','0','-1','false'};
        private String[] triggerOrder_type_info = new String[]{'triggerOrder',SOAP_M_URI,'int','0','1','true'};
        private String[] variables_type_info = new String[]{'variables',SOAP_M_URI,'FlowVariable','0','-1','false'};
        private String[] waits_type_info = new String[]{'waits',SOAP_M_URI,'FlowWait','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fullName','actionCalls','apexPluginCalls','apiVersion','assignments','choices','collectionProcessors','constants','customErrors','decisions','description','dynamicChoiceSets','environments','exitRules','experiments','formulas','interviewLabel','isAdditionalPermissionRequiredToRun','isOverridable','isTemplate','label','loops','migratedFromWorkflowRuleName','orchestratedStages','overriddenFlow','processMetadataValues','processType','recordCreates','recordDeletes','recordLookups','recordRollbacks','recordUpdates','runInMode','screens','sourceTemplate','stages','start','startElementReference','status','steps','subflows','textTemplates','timeZoneSidKey','transforms','triggerOrder','variables','waits'};
    }
    public class FlowActionCall {
        public String type = 'FlowActionCall';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowActionCallPath[] actionCallPaths;
        public String actionName;
        public String actionType;
        public FlowConnector connector;
        public FlowDataTypeMapping[] dataTypeMappings;
        public FlowConnector faultConnector;
        public String flowTransactionModel;
        public FlowActionCallInputParameter[] inputParameters;
        public Boolean isWaitUntilCompleted;
        public String nameSegment;
        public Integer offset;
        public String offsetUnit;
        public FlowActionCallOutputParameter[] outputParameters;
        public Boolean storeOutputAutomatically;
        public FlowConnector timeoutConnector;
        public Integer versionSegment;
        private String[] actionCallPaths_type_info = new String[]{'actionCallPaths',SOAP_M_URI,'FlowActionCallPath','0','-1','false'};
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,'string','0','1','false'};
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] dataTypeMappings_type_info = new String[]{'dataTypeMappings',SOAP_M_URI,'FlowDataTypeMapping','0','-1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] flowTransactionModel_type_info = new String[]{'flowTransactionModel',SOAP_M_URI,'FlowTransactionModel','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowActionCallInputParameter','0','-1','false'};
        private String[] isWaitUntilCompleted_type_info = new String[]{'isWaitUntilCompleted',SOAP_M_URI,'boolean','0','1','false'};
        private String[] nameSegment_type_info = new String[]{'nameSegment',SOAP_M_URI,'string','0','1','false'};
        private String[] offset_type_info = new String[]{'offset',SOAP_M_URI,'int','0','1','false'};
        private String[] offsetUnit_type_info = new String[]{'offsetUnit',SOAP_M_URI,'FlowScheduledPathOffsetUnit','0','1','false'};
        private String[] outputParameters_type_info = new String[]{'outputParameters',SOAP_M_URI,'FlowActionCallOutputParameter','0','-1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] timeoutConnector_type_info = new String[]{'timeoutConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] versionSegment_type_info = new String[]{'versionSegment',SOAP_M_URI,'int','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','actionName','actionType','connector','dataTypeMappings','faultConnector','flowTransactionModel','inputParameters','isWaitUntilCompleted','nameSegment','offset','offsetUnit','outputParameters','storeOutputAutomatically','versionSegment'};
    }
    
    public class FlowActionCallInputParameter {
        public String type = 'FlowActionCallInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowActionCallOutputParameter {
        public String type = 'FlowActionCallOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowActionCallPath {
        public String type = 'FlowActionCallPath';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public String pathName;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','1','1','false'};
        private String[] pathName_type_info = new String[]{'pathName',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','connector','pathName'};
    }
    public class FlowApexPluginCall {
        public String type = 'FlowApexPluginCall';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String apexClass;
        public FlowConnector connector;
        public FlowConnector faultConnector;
        public FlowApexPluginCallInputParameter[] inputParameters;
        public FlowApexPluginCallOutputParameter[] outputParameters;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,'string','1','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowApexPluginCallInputParameter','0','-1','false'};
        private String[] outputParameters_type_info = new String[]{'outputParameters',SOAP_M_URI,'FlowApexPluginCallOutputParameter','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','apexClass','connector','faultConnector','inputParameters','outputParameters'};
    }
    
    public class FlowApexPluginCallInputParameter {
        public String type = 'FlowApexPluginCallInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowApexPluginCallOutputParameter {
        public String type = 'FlowApexPluginCallOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowAssignment {
        public String type = 'FlowAssignment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowAssignmentItem[] assignmentItems;
        public FlowConnector connector;
        private String[] assignmentItems_type_info = new String[]{'assignmentItems',SOAP_M_URI,'FlowAssignmentItem','0','-1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','assignmentItems','connector'};
    }
    public class FlowAssignmentItem {
        public String type = 'FlowAssignmentItem';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String operator;
        public FlowElementReferenceOrValue value;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,'FlowAssignmentOperator','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','operator','value'};
    }
    public class FlowBaseElement {
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues'};
    }
    public class FlowCapability {
        public String type = 'FlowCapability';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String capabilityName;
        public FlowCapabilityInput[] inputs;
        private String[] capabilityName_type_info = new String[]{'capabilityName',SOAP_M_URI,'string','1','1','false'};
        private String[] inputs_type_info = new String[]{'inputs',SOAP_M_URI,'FlowCapabilityInput','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','capabilityName','inputs'};
    }
    public class FlowCapabilityInput {
        public String type = 'FlowCapabilityInput';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String capabilityInputName;
        public String dataType;
        public Boolean isCollection;
        private String[] capabilityInputName_type_info = new String[]{'capabilityInputName',SOAP_M_URI,'string','1','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'string','0','1','false'};
        private String[] isCollection_type_info = new String[]{'isCollection',SOAP_M_URI,'boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','capabilityInputName','dataType','isCollection'};
    }
    public class FlowCategory extends Metadata {
        public String type = 'FlowCategory';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public String description;
        public FlowCategoryItems[] flowCategoryItems;
        public String masterLabel;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] flowCategoryItems_type_info = new String[]{'flowCategoryItems',SOAP_M_URI,'FlowCategoryItems','0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fullName','description','flowCategoryItems','masterLabel'};
    }
    public class FlowCategoryItems {
        public String flow;
        private String[] flow_type_info = new String[]{'flow',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'flow'};
    }
    public class FlowChoice {
        public String type = 'FlowChoice';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String choiceText;
        public String dataType;
        public FlowChoiceUserInput userInput;
        public FlowElementReferenceOrValue value;
        private String[] choiceText_type_info = new String[]{'choiceText',SOAP_M_URI,'string','1','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','1','1','false'};
        private String[] userInput_type_info = new String[]{'userInput',SOAP_M_URI,'FlowChoiceUserInput','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','choiceText','dataType','userInput','value'};
    }
    public class FlowChoiceTranslation {
        public String choiceText;
        public String name;
        public FlowChoiceUserInputTranslation userInput;
        private String[] choiceText_type_info = new String[]{'choiceText',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] userInput_type_info = new String[]{'userInput',SOAP_M_URI,'FlowChoiceUserInputTranslation','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'choiceText','name','userInput'};
    }
    public class FlowChoiceUserInput {
        public String type = 'FlowChoiceUserInput';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean isRequired;
        public String promptText;
        public FlowInputValidationRule validationRule;
        private String[] isRequired_type_info = new String[]{'isRequired',SOAP_M_URI,'boolean','0','1','false'};
        private String[] promptText_type_info = new String[]{'promptText',SOAP_M_URI,'string','0','1','false'};
        private String[] validationRule_type_info = new String[]{'validationRule',SOAP_M_URI,'FlowInputValidationRule','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','isRequired','promptText','validationRule'};
    }
    public class FlowChoiceUserInputTranslation {
        public String promptText;
        public FlowInputValidationRuleTranslation validationRule;
        private String[] promptText_type_info = new String[]{'promptText',SOAP_M_URI,'string','0','1','false'};
        private String[] validationRule_type_info = new String[]{'validationRule',SOAP_M_URI,'FlowInputValidationRuleTranslation','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'promptText','validationRule'};
    }
    public class FlowCollectionMapItem {
        public String type = 'FlowCollectionMapItem';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToFieldReference;
        public String operator;
        public FlowElementReferenceOrValue value;
        private String[] assignToFieldReference_type_info = new String[]{'assignToFieldReference',SOAP_M_URI,'string','1','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,'FlowAssignmentOperator','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToFieldReference','operator','value'};
    }
    public class FlowCollectionProcessor {
        public String type = 'FlowCollectionProcessor';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignNextValueToReference;
        public String collectionProcessorType;
        public String collectionReference;
        public String conditionLogic;
        public FlowCondition[] conditions;
        public FlowConnector connector;
        public String formula;
        public Integer limit_x;
        public FlowCollectionMapItem[] mapItems;
        public String outputSObjectType;
        public FlowCollectionSortOption[] sortOptions;
        private String[] assignNextValueToReference_type_info = new String[]{'assignNextValueToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] collectionProcessorType_type_info = new String[]{'collectionProcessorType',SOAP_M_URI,'FlowCollectionProcessorType','1','1','false'};
        private String[] collectionReference_type_info = new String[]{'collectionReference',SOAP_M_URI,'string','1','1','false'};
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,'string','0','1','false'};
        private String[] limit_x_type_info = new String[]{'limit',SOAP_M_URI,'int','0','1','true'};
        private String[] mapItems_type_info = new String[]{'mapItems',SOAP_M_URI,'FlowCollectionMapItem','0','-1','false'};
        private String[] outputSObjectType_type_info = new String[]{'outputSObjectType',SOAP_M_URI,'string','0','1','false'};
        private String[] sortOptions_type_info = new String[]{'sortOptions',SOAP_M_URI,'FlowCollectionSortOption','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','assignNextValueToReference','collectionProcessorType','collectionReference','conditionLogic','conditions','connector','formula','limit_x','mapItems','outputSObjectType','sortOptions'};
    }
    public class FlowCollectionSortOption {
        public String type = 'FlowCollectionSortOption';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean doesPutEmptyStringAndNullFirst;
        public String sortField;
        public String sortOrder;
        private String[] doesPutEmptyStringAndNullFirst_type_info = new String[]{'doesPutEmptyStringAndNullFirst',SOAP_M_URI,'boolean','1','1','false'};
        private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,'string','0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,'SortOrder','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','doesPutEmptyStringAndNullFirst','sortField','sortOrder'};
    }
    public class FlowComplexLiteralTranslation {
        public String customAspectKey;
        public String value;
        private String[] customAspectKey_type_info = new String[]{'customAspectKey',SOAP_M_URI,'string','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customAspectKey','value'};
    }
    public class FlowCondition {
        public String type = 'FlowCondition';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String aggregationOperator;
        public String conditionLogic;
        public String conditionType;
        public FlowCondition[] conditions;
        public String leftValueReference;
        public String operator;
        public FlowElementReferenceOrValue rightValue;
        private String[] aggregationOperator_type_info = new String[]{'aggregationOperator',SOAP_M_URI,'string','0','1','false'};
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditionType_type_info = new String[]{'conditionType',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] leftValueReference_type_info = new String[]{'leftValueReference',SOAP_M_URI,'string','0','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,'FlowComparisonOperator','1','1','false'};
        private String[] rightValue_type_info = new String[]{'rightValue',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','aggregationOperator','conditionLogic','conditionType','conditions','leftValueReference','operator','rightValue'};
    }
    public class FlowConnector {
        public String type = 'FlowConnector';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean isGoTo;
        public String targetReference;
        private String[] isGoTo_type_info = new String[]{'isGoTo',SOAP_M_URI,'boolean','0','1','false'};
        private String[] targetReference_type_info = new String[]{'targetReference',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','isGoTo','targetReference'};
    }
    public class FlowConstant {
        public String type = 'FlowConstant';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String dataType;
        public FlowElementReferenceOrValue value;
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','dataType','value'};
    }
    public class FlowCoverageResult {
        public String[] elementsNotCovered;
        public String flowId;
        public String flowName;
        public String flowNamespace;
        public Integer numElements;
        public Integer numElementsNotCovered;
        public String processType;
        private String[] elementsNotCovered_type_info = new String[]{'elementsNotCovered',SOAP_M_URI,'string','0','-1','false'};
        private String[] flowId_type_info = new String[]{'flowId',SOAP_M_URI,'string','1','1','false'};
        private String[] flowName_type_info = new String[]{'flowName',SOAP_M_URI,'string','1','1','false'};
        private String[] flowNamespace_type_info = new String[]{'flowNamespace',SOAP_M_URI,'string','1','1','true'};
        private String[] numElements_type_info = new String[]{'numElements',SOAP_M_URI,'int','1','1','false'};
        private String[] numElementsNotCovered_type_info = new String[]{'numElementsNotCovered',SOAP_M_URI,'int','1','1','false'};
        private String[] processType_type_info = new String[]{'processType',SOAP_M_URI,'FlowProcessType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementsNotCovered','flowId','flowName','flowNamespace','numElements','numElementsNotCovered','processType'};
    }
    public class FlowCoverageWarning {
        public String flowId;
        public String flowName;
        public String flowNamespace;
        public String message;
        private String[] flowId_type_info = new String[]{'flowId',SOAP_M_URI,'string','1','1','true'};
        private String[] flowName_type_info = new String[]{'flowName',SOAP_M_URI,'string','1','1','true'};
        private String[] flowNamespace_type_info = new String[]{'flowNamespace',SOAP_M_URI,'string','1','1','true'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'flowId','flowName','flowNamespace','message'};
    }
    public class FlowCustomError {
        public String type = 'FlowCustomError';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String description_FlowCustomError;
        public FlowConnector connector;
        public FlowCustomErrorMessage[] customErrorMessages;
        private String[] description_FlowCustomError_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] customErrorMessages_type_info = new String[]{'customErrorMessages',SOAP_M_URI,'FlowCustomErrorMessage','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','description_FlowCustomError','connector','customErrorMessages'};
    }
    public class FlowCustomErrorMessage {
        public String type = 'FlowCustomErrorMessage';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String errorMessage;
        public String fieldSelection;
        public Boolean isFieldError;
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,'string','1','1','false'};
        private String[] fieldSelection_type_info = new String[]{'fieldSelection',SOAP_M_URI,'string','0','1','false'};
        private String[] isFieldError_type_info = new String[]{'isFieldError',SOAP_M_URI,'boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','errorMessage','fieldSelection','isFieldError'};
    }
    public class FlowCustomErrorMessageTranslation {
        public String developerName;
        public String errorMessage;
        public String field;
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,'string','1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,'string','0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'developerName','errorMessage','field'};
    }
    public class FlowCustomProperty {
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class FlowDataTypeMapping {
        public String type = 'FlowDataTypeMapping';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String apexClass;
        public String typeName;
        public String typeValue;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,'string','0','1','false'};
        private String[] typeName_type_info = new String[]{'typeName',SOAP_M_URI,'string','1','1','false'};
        private String[] typeValue_type_info = new String[]{'typeValue',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','apexClass','typeName','typeValue'};
    }
    public class FlowDecision {
        public String type = 'FlowDecision';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector defaultConnector;
        public String defaultConnectorLabel;
        public FlowRule[] rules;
        private String[] defaultConnector_type_info = new String[]{'defaultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] defaultConnectorLabel_type_info = new String[]{'defaultConnectorLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] rules_type_info = new String[]{'rules',SOAP_M_URI,'FlowRule','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','defaultConnector','defaultConnectorLabel','rules'};
    }
    public class FlowDefinition extends Metadata{
        public String type = 'FlowDefinition';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public Integer activeVersionNumber;
        public String description;
        public String masterLabel;
        private String[] activeVersionNumber_type_info = new String[]{'activeVersionNumber',SOAP_M_URI,'int','0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fullName','activeVersionNumber','description','masterLabel'};
    }
    public class FlowDefinitionTranslation {
        public FlowTranslation[] flows;
        public String fullName;
        public String label;
        private String[] flows_type_info = new String[]{'flows',SOAP_M_URI,'FlowTranslation','0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'flows','fullName','label'};
    }
    public class FlowDynamicChoiceSet {
        public String type = 'FlowDynamicChoiceSet';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String collectionReference;
        public String dataType;
        public String displayField;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public Integer limit_x;
        public String object_x;
        public FlowOutputFieldAssignment[] outputAssignments;
        public String picklistField;
        public String picklistObject;
        public String sortField;
        public String sortOrder;
        public String valueField;
        private String[] collectionReference_type_info = new String[]{'collectionReference',SOAP_M_URI,'string','0','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','1','1','false'};
        private String[] displayField_type_info = new String[]{'displayField',SOAP_M_URI,'string','1','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] limit_x_type_info = new String[]{'limit',SOAP_M_URI,'int','0','1','true'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','1','1','false'};
        private String[] outputAssignments_type_info = new String[]{'outputAssignments',SOAP_M_URI,'FlowOutputFieldAssignment','0','-1','false'};
        private String[] picklistField_type_info = new String[]{'picklistField',SOAP_M_URI,'string','0','1','false'};
        private String[] picklistObject_type_info = new String[]{'picklistObject',SOAP_M_URI,'string','0','1','false'};
        private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,'string','0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,'SortOrder','0','1','false'};
        private String[] valueField_type_info = new String[]{'valueField',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','collectionReference','dataType','displayField','filterLogic','filters','limit_x','object_x','outputAssignments','picklistField','picklistObject','sortField','sortOrder','valueField'};
    }
    public class FlowElement {
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','description','name'};
    }
    public class FlowElementReferenceOrValue {
        public String apexValue;
        public Boolean booleanValue;
        public String complexValue;
        public String complexValueType;
        public DateTime dateTimeValue;
        public Date dateValue;
        public String elementReference;
        public String formulaDataType;
        public String formulaExpression;
        public Double numberValue;
        public String setupReference;
        public String setupReferenceType;
        public String sobjectValue;
        public String stringValue;
        public FlowInlineTransform transform;
        public String transformValueReference;
        private String[] apexValue_type_info = new String[]{'apexValue',SOAP_M_URI,'string','0','1','true'};
        private String[] booleanValue_type_info = new String[]{'booleanValue',SOAP_M_URI,'boolean','0','1','true'};
        private String[] complexValue_type_info = new String[]{'complexValue',SOAP_M_URI,'string','0','1','true'};
        private String[] complexValueType_type_info = new String[]{'complexValueType',SOAP_M_URI,'FlowComplexValueType','0','1','true'};
        private String[] dateTimeValue_type_info = new String[]{'dateTimeValue',SOAP_M_URI,'dateTime','0','1','false'};
        private String[] dateValue_type_info = new String[]{'dateValue',SOAP_M_URI,'date','0','1','false'};
        private String[] elementReference_type_info = new String[]{'elementReference',SOAP_M_URI,'string','0','1','false'};
        private String[] formulaDataType_type_info = new String[]{'formulaDataType',SOAP_M_URI,'FlowDataType','0','1','true'};
        private String[] formulaExpression_type_info = new String[]{'formulaExpression',SOAP_M_URI,'string','0','1','true'};
        private String[] numberValue_type_info = new String[]{'numberValue',SOAP_M_URI,'double','0','1','true'};
        private String[] setupReference_type_info = new String[]{'setupReference',SOAP_M_URI,'string','0','1','true'};
        private String[] setupReferenceType_type_info = new String[]{'setupReferenceType',SOAP_M_URI,'string','0','1','true'};
        private String[] sobjectValue_type_info = new String[]{'sobjectValue',SOAP_M_URI,'string','0','1','true'};
        private String[] stringValue_type_info = new String[]{'stringValue',SOAP_M_URI,'string','0','1','false'};
        private String[] transform_type_info = new String[]{'transform',SOAP_M_URI,'FlowInlineTransform','0','1','true'};
        private String[] transformValueReference_type_info = new String[]{'transformValueReference',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexValue','booleanValue','complexValue','complexValueType','dateTimeValue','dateValue','elementReference','formulaDataType','formulaExpression','numberValue','setupReference','setupReferenceType','sobjectValue','stringValue','transform','transformValueReference'};
    }
    public class FlowExitRule {
        public String type = 'FlowExitRule';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowCondition[] conditions;
        public String label;
        public String logicalOperator;
        public Integer ruleOrder;
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] logicalOperator_type_info = new String[]{'logicalOperator',SOAP_M_URI,'string','1','1','false'};
        private String[] ruleOrder_type_info = new String[]{'ruleOrder',SOAP_M_URI,'int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','conditions','label','logicalOperator','ruleOrder'};
    }
    public class FlowExperiment {
        public String type = 'FlowExperiment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Integer duration;
        public String durationUnit;
        public FlowExperimentPath[] paths;
        public Integer testGroupPercentage;
        public String type_x;
        private String[] duration_type_info = new String[]{'duration',SOAP_M_URI,'int','0','1','false'};
        private String[] durationUnit_type_info = new String[]{'durationUnit',SOAP_M_URI,'FlowScheduledPathOffsetUnit','0','1','false'};
        private String[] paths_type_info = new String[]{'paths',SOAP_M_URI,'FlowExperimentPath','0','-1','false'};
        private String[] testGroupPercentage_type_info = new String[]{'testGroupPercentage',SOAP_M_URI,'int','0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,'FlowExperimentType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','duration','durationUnit','paths','testGroupPercentage','type_x'};
    }
    public class FlowExperimentPath {
        public String type = 'FlowExperimentPath';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public String label;
        public Integer percentage;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] percentage_type_info = new String[]{'percentage',SOAP_M_URI,'int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','connector','label','percentage'};
    }
    public class FlowFerovTranslation {
        public FlowComplexLiteralTranslation[] complexValues;
        public String stringValue;
        private String[] complexValues_type_info = new String[]{'complexValues',SOAP_M_URI,'FlowComplexLiteralTranslation','0','-1','false'};
        private String[] stringValue_type_info = new String[]{'stringValue',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'complexValues','stringValue'};
    }
    public class FlowFormula {
        public String type = 'FlowFormula';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String dataType;
        public String expression;
        public Integer scale;
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','0','1','false'};
        private String[] expression_type_info = new String[]{'expression',SOAP_M_URI,'string','1','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,'int','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','dataType','expression','scale'};
    }
    public class FlowInlineTransform {
        public String type = 'FlowInlineTransform';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String apexClass;
        public String dataType;
        public Boolean isCollection;
        public String objectType;
        public FlowTransformValue[] transformValues;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,'string','0','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','0','1','false'};
        private String[] isCollection_type_info = new String[]{'isCollection',SOAP_M_URI,'boolean','0','1','false'};
        private String[] objectType_type_info = new String[]{'objectType',SOAP_M_URI,'string','0','1','false'};
        private String[] transformValues_type_info = new String[]{'transformValues',SOAP_M_URI,'FlowTransformValue','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','apexClass','dataType','isCollection','objectType','transformValues'};
    }
    public class FlowInputFieldAssignment {
        public String type = 'FlowInputFieldAssignment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String field;
        public FlowElementReferenceOrValue value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,'string','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','field','value'};
    }
    public class FlowInputParameterTranslation {
        public String name;
        public FlowFerovTranslation value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowFerovTranslation','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class FlowInputValidationRule {
        public String errorMessage;
        public String formulaExpression;
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,'string','1','1','false'};
        private String[] formulaExpression_type_info = new String[]{'formulaExpression',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errorMessage','formulaExpression'};
    }
    public class FlowInputValidationRuleTranslation {
        public String errorMessage;
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errorMessage'};
    }
    public class FlowLoop {
        public String type = 'FlowLoop';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignNextValueToReference;
        public String collectionReference;
        public String iterationOrder;
        public FlowConnector nextValueConnector;
        public FlowConnector noMoreValuesConnector;
        private String[] assignNextValueToReference_type_info = new String[]{'assignNextValueToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] collectionReference_type_info = new String[]{'collectionReference',SOAP_M_URI,'string','0','1','false'};
        private String[] iterationOrder_type_info = new String[]{'iterationOrder',SOAP_M_URI,'IterationOrder','0','1','false'};
        private String[] nextValueConnector_type_info = new String[]{'nextValueConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] noMoreValuesConnector_type_info = new String[]{'noMoreValuesConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','assignNextValueToReference','collectionReference','iterationOrder','nextValueConnector','noMoreValuesConnector'};
    }
    public class FlowMetadataValue {
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class FlowNode {
        public String type = 'FlowNode';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','elementSubtype','label','locationX','locationY'};
    }
    public class FlowOrchestratedStage {
        public String type = 'FlowOrchestratedStage';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public FlowStageStepExitActionInputParameter[] exitActionInputParameters;
        public String exitActionName;
        public FlowStageStepExitActionOutputParameter[] exitActionOutputParameters;
        public String exitActionType;
        public String exitConditionLogic;
        public FlowCondition[] exitConditions;
        public FlowConnector faultConnector;
        public FlowStageStep[] stageSteps;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] exitActionInputParameters_type_info = new String[]{'exitActionInputParameters',SOAP_M_URI,'FlowStageStepExitActionInputParameter','0','-1','false'};
        private String[] exitActionName_type_info = new String[]{'exitActionName',SOAP_M_URI,'string','0','1','false'};
        private String[] exitActionOutputParameters_type_info = new String[]{'exitActionOutputParameters',SOAP_M_URI,'FlowStageStepExitActionOutputParameter','0','-1','false'};
        private String[] exitActionType_type_info = new String[]{'exitActionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] exitConditionLogic_type_info = new String[]{'exitConditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] exitConditions_type_info = new String[]{'exitConditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] stageSteps_type_info = new String[]{'stageSteps',SOAP_M_URI,'FlowStageStep','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connector','exitActionInputParameters','exitActionName','exitActionOutputParameters','exitActionType','exitConditionLogic','exitConditions','faultConnector','stageSteps'};
    }
    public class FlowOrchestrationStepTranslation {
        public String name;
        public String stepLabel;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] stepLabel_type_info = new String[]{'stepLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','stepLabel'};
    }
    public class FlowOutputFieldAssignment {
        public String type = 'FlowOutputFieldAssignment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String field;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','field'};
    }
    public class FlowRecordCreate {
        public String type = 'FlowRecordCreate';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignRecordIdToReference;
        public FlowConnector connector;
        public Boolean doesUpsert;
        public Boolean doesUpsertAllOrNone;
        public FlowConnector faultConnector;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public FlowInputFieldAssignment[] inputAssignments;
        public String inputReference;
        public String object_x;
        public String operationMultMatchingRecords;
        public String operationOneMatchingRecord;
        public String operationZeroMatchingRecords;
        public Boolean storeOutputAutomatically;
        public String upsertExternalIdField;
        public String upsertStandardIdField;
        private String[] assignRecordIdToReference_type_info = new String[]{'assignRecordIdToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] doesUpsert_type_info = new String[]{'doesUpsert',SOAP_M_URI,'boolean','0','1','false'};
        private String[] doesUpsertAllOrNone_type_info = new String[]{'doesUpsertAllOrNone',SOAP_M_URI,'boolean','0','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] inputAssignments_type_info = new String[]{'inputAssignments',SOAP_M_URI,'FlowInputFieldAssignment','0','-1','false'};
        private String[] inputReference_type_info = new String[]{'inputReference',SOAP_M_URI,'string','0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] operationMultMatchingRecords_type_info = new String[]{'operationMultMatchingRecords',SOAP_M_URI,'string','0','1','false'};
        private String[] operationOneMatchingRecord_type_info = new String[]{'operationOneMatchingRecord',SOAP_M_URI,'string','0','1','false'};
        private String[] operationZeroMatchingRecords_type_info = new String[]{'operationZeroMatchingRecords',SOAP_M_URI,'string','0','1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] upsertExternalIdField_type_info = new String[]{'upsertExternalIdField',SOAP_M_URI,'string','0','1','false'};
        private String[] upsertStandardIdField_type_info = new String[]{'upsertStandardIdField',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','assignRecordIdToReference','connector','doesUpsert','doesUpsertAllOrNone','faultConnector','filterLogic','filters','inputAssignments','inputReference','object_x','operationMultMatchingRecords','operationOneMatchingRecord','operationZeroMatchingRecords','storeOutputAutomatically','upsertExternalIdField','upsertStandardIdField'};
    }
    public class FlowRecordDelete {
        public String type = 'FlowRecordDelete';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public FlowConnector faultConnector;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public String inputReference;
        public String object_x;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] inputReference_type_info = new String[]{'inputReference',SOAP_M_URI,'string','0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connector','faultConnector','filterLogic','filters','inputReference','object_x'};
    }
    public class FlowRecordFilter {
        public String type = 'FlowRecordFilter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String field;
        public String operator;
        public FlowElementReferenceOrValue value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,'string','0','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,'FlowRecordFilterOperator','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','field','operator','value'};
    }
    public class FlowRecordLookup {
        public String type = 'FlowRecordLookup';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean assignNullValuesIfNoRecordsFound;
        public FlowConnector connector;
        public FlowConnector faultConnector;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public Boolean getFirstRecordOnly;
        public FlowElementReferenceOrValue limit_x;
        public String object_x;
        public FlowOutputFieldAssignment[] outputAssignments;
        public String outputReference;
        public String[] queriedFields;
        public String sortField;
        public String sortOrder;
        public Boolean storeOutputAutomatically;
        private String[] assignNullValuesIfNoRecordsFound_type_info = new String[]{'assignNullValuesIfNoRecordsFound',SOAP_M_URI,'boolean','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] getFirstRecordOnly_type_info = new String[]{'getFirstRecordOnly',SOAP_M_URI,'boolean','0','1','false'};
        private String[] limit_x_type_info = new String[]{'limit',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','true'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] outputAssignments_type_info = new String[]{'outputAssignments',SOAP_M_URI,'FlowOutputFieldAssignment','0','-1','false'};
        private String[] outputReference_type_info = new String[]{'outputReference',SOAP_M_URI,'string','0','1','false'};
        private String[] queriedFields_type_info = new String[]{'queriedFields',SOAP_M_URI,'string','0','-1','false'};
        private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,'string','0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,'SortOrder','0','1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','assignNullValuesIfNoRecordsFound','connector','faultConnector','filterLogic','filters','getFirstRecordOnly','limit_x','object_x','outputAssignments','outputReference','queriedFields','sortField','sortOrder','storeOutputAutomatically'};
    }
    public class FlowRecordRollback {
        public String type = 'FlowRecordRollback';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connector'};
    }
    public class FlowRecordUpdate {
        public String type = 'FlowRecordUpdate';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public FlowConnector faultConnector;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public FlowInputFieldAssignment[] inputAssignments;
        public String inputReference;
        public String object_x;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] inputAssignments_type_info = new String[]{'inputAssignments',SOAP_M_URI,'FlowInputFieldAssignment','0','-1','false'};
        private String[] inputReference_type_info = new String[]{'inputReference',SOAP_M_URI,'string','0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connector','faultConnector','filterLogic','filters','inputAssignments','inputReference','object_x'};
    }
    public class FlowRule {
        public String type = 'FlowRule';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String conditionLogic;
        public FlowCondition[] conditions;
        public FlowConnector connector;
        public Boolean doesRequireRecordChangedToMeetCriteria;
        public String label;
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','1','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] doesRequireRecordChangedToMeetCriteria_type_info = new String[]{'doesRequireRecordChangedToMeetCriteria',SOAP_M_URI,'boolean','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','conditionLogic','conditions','connector','doesRequireRecordChangedToMeetCriteria','label'};
    }
    public class FlowSchedule {
        public String frequency;
        public String startDate;//Date startDate;
        public String startTime;//Time startTime;
        private  String[] frequency_type_info = new String[]{'frequency',SOAP_M_URI,'FlowStartFrequency','0','1','false'};
        private  String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,'string','0','1','false'};
        private  String[] startTime_type_info = new String[]{'startTime',SOAP_M_URI,'string','0','1','false'};
        private  String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private  String[] field_order_type_info = new String[]{'frequency','startDate','startTime'};
    }
    public class FlowScheduledPath {
        public String type = 'FlowScheduledPath';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public String label;
        public Integer maxBatchSize;
        public Integer offsetNumber;
        public String offsetUnit;
        public String pathType;
        public String recordField;
        public String timeSource;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] maxBatchSize_type_info = new String[]{'maxBatchSize',SOAP_M_URI,'int','0','1','false'};
        private String[] offsetNumber_type_info = new String[]{'offsetNumber',SOAP_M_URI,'int','0','1','false'};
        private String[] offsetUnit_type_info = new String[]{'offsetUnit',SOAP_M_URI,'FlowScheduledPathOffsetUnit','0','1','false'};
        private String[] pathType_type_info = new String[]{'pathType',SOAP_M_URI,'FlowScheduledPathType','0','1','false'};
        private String[] recordField_type_info = new String[]{'recordField',SOAP_M_URI,'string','0','1','false'};
        private String[] timeSource_type_info = new String[]{'timeSource',SOAP_M_URI,'FlowScheduledPathTimeSource','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','connector','label','maxBatchSize','offsetNumber','offsetUnit','pathType','recordField','timeSource'};
    }
    public class FlowScreen {
        public String type = 'FlowScreen';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowScreenAction[] actions;
        public Boolean allowBack;
        public Boolean allowFinish;
        public Boolean allowPause;
        public String backButtonLabel;
        public FlowConnector connector;
        public FlowScreenField[] fields;
        public String helpText;
        public String nextOrFinishButtonLabel;
        public String pauseButtonLabel;
        public String pausedText;
        public FlowScreenRule[] rules;
        public Boolean showFooter;
        public Boolean showHeader;
        public FlowElementReferenceOrValue stageReference;
        public FlowScreenTrigger[] triggers;
        private String[] actions_type_info = new String[]{'actions',SOAP_M_URI,'FlowScreenAction','0','-1','false'};
        private String[] allowBack_type_info = new String[]{'allowBack',SOAP_M_URI,'boolean','0','1','false'};
        private String[] allowFinish_type_info = new String[]{'allowFinish',SOAP_M_URI,'boolean','0','1','false'};
        private String[] allowPause_type_info = new String[]{'allowPause',SOAP_M_URI,'boolean','0','1','false'};
        private String[] backButtonLabel_type_info = new String[]{'backButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,'FlowScreenField','0','-1','false'};
        private String[] helpText_type_info = new String[]{'helpText',SOAP_M_URI,'string','0','1','false'};
        private String[] nextOrFinishButtonLabel_type_info = new String[]{'nextOrFinishButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] pauseButtonLabel_type_info = new String[]{'pauseButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] pausedText_type_info = new String[]{'pausedText',SOAP_M_URI,'string','0','1','false'};
        private String[] rules_type_info = new String[]{'rules',SOAP_M_URI,'FlowScreenRule','0','-1','false'};
        private String[] showFooter_type_info = new String[]{'showFooter',SOAP_M_URI,'boolean','0','1','false'};
        private String[] showHeader_type_info = new String[]{'showHeader',SOAP_M_URI,'boolean','0','1','false'};
        private String[] stageReference_type_info = new String[]{'stageReference',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] triggers_type_info = new String[]{'triggers',SOAP_M_URI,'FlowScreenTrigger','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','actions','allowBack','allowFinish','allowPause','backButtonLabel','connector','fields','helpText','nextOrFinishButtonLabel','pauseButtonLabel','pausedText','rules','showFooter','showHeader','stageReference','triggers'};
    }
    public class FlowScreenAction {
        public String type = 'FlowScreenAction';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String actionName;
        public String actionType;
        public FlowScreenActionInputParameter[] inputParameters;
        public String label;
        public String nameSegment;
        public Integer versionSegment;
        public String versionString;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,'string','0','1','false'};
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowScreenActionInputParameter','0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] nameSegment_type_info = new String[]{'nameSegment',SOAP_M_URI,'string','0','1','false'};
        private String[] versionSegment_type_info = new String[]{'versionSegment',SOAP_M_URI,'int','0','1','false'};
        private String[] versionString_type_info = new String[]{'versionString',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','actionName','actionType','inputParameters','label','nameSegment','versionSegment','versionString'};
    }
    public class FlowScreenActionInputParameter {
        public String type = 'FlowScreenActionInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowScreenField {
        public String type = 'FlowScreenField';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String[] choiceReferences;
        public String dataType;
        public FlowDataTypeMapping[] dataTypeMappings;
        public String defaultSelectedChoiceReference;
        public FlowElementReferenceOrValue defaultValue;
        public String extensionName;
        public String fieldText;
        public String fieldType;
        public FlowScreenField[] fields;
        public String helpText;
        public FlowScreenFieldInputParameter[] inputParameters;
        public String inputsOnNextNavToAssocScrn;
        public FlowElementReferenceOrValue isDisabled;
        public FlowElementReferenceOrValue isReadOnly;
        public Boolean isRequired;
        public Boolean isVisible;
        public String objectFieldReference;
        public FlowScreenFieldOutputParameter[] outputParameters;
        public String regionContainerType;
        public Integer scale;
        public String sourceTemplateApiName;
        public String sourceTemplateProviderType;
        public Boolean storeOutputAutomatically;
        public FlowInputValidationRule validationRule;
        public FlowVisibilityRule visibilityRule;
        private String[] choiceReferences_type_info = new String[]{'choiceReferences',SOAP_M_URI,'string','0','-1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','0','1','false'};
        private String[] dataTypeMappings_type_info = new String[]{'dataTypeMappings',SOAP_M_URI,'FlowDataTypeMapping','0','-1','false'};
        private String[] defaultSelectedChoiceReference_type_info = new String[]{'defaultSelectedChoiceReference',SOAP_M_URI,'string','0','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] extensionName_type_info = new String[]{'extensionName',SOAP_M_URI,'string','0','1','false'};
        private String[] fieldText_type_info = new String[]{'fieldText',SOAP_M_URI,'string','0','1','false'};
        private String[] fieldType_type_info = new String[]{'fieldType',SOAP_M_URI,'FlowScreenFieldType','1','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,'FlowScreenField','0','-1','false'};
        private String[] helpText_type_info = new String[]{'helpText',SOAP_M_URI,'string','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowScreenFieldInputParameter','0','-1','false'};
        private String[] inputsOnNextNavToAssocScrn_type_info = new String[]{'inputsOnNextNavToAssocScrn',SOAP_M_URI,'FlowScreenFieldInputsRevisited','0','1','false'};
        private String[] isDisabled_type_info = new String[]{'isDisabled',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] isReadOnly_type_info = new String[]{'isReadOnly',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] isRequired_type_info = new String[]{'isRequired',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isVisible_type_info = new String[]{'isVisible',SOAP_M_URI,'boolean','0','1','true'};
        private String[] objectFieldReference_type_info = new String[]{'objectFieldReference',SOAP_M_URI,'string','0','1','false'};
        private String[] outputParameters_type_info = new String[]{'outputParameters',SOAP_M_URI,'FlowScreenFieldOutputParameter','0','-1','false'};
        private String[] regionContainerType_type_info = new String[]{'regionContainerType',SOAP_M_URI,'FlowRegionContainerType','0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,'int','0','1','false'};
        private String[] sourceTemplateApiName_type_info = new String[]{'sourceTemplateApiName',SOAP_M_URI,'string','0','1','false'};
        private String[] sourceTemplateProviderType_type_info = new String[]{'sourceTemplateProviderType',SOAP_M_URI,'string','0','1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] validationRule_type_info = new String[]{'validationRule',SOAP_M_URI,'FlowInputValidationRule','0','1','false'};
        private String[] visibilityRule_type_info = new String[]{'visibilityRule',SOAP_M_URI,'FlowVisibilityRule','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','choiceReferences','dataType','dataTypeMappings','defaultSelectedChoiceReference','defaultValue','extensionName','fieldText','fieldType','fields','helpText','inputParameters','inputsOnNextNavToAssocScrn','isDisabled','isReadOnly','isRequired','isVisible','objectFieldReference','outputParameters','regionContainerType','scale','sourceTemplateApiName','sourceTemplateProviderType','storeOutputAutomatically','validationRule','visibilityRule'};
    }
    public class FlowScreenFieldInputParameter {
        public String type = 'FlowScreenFieldInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowScreenFieldOutputParameter {
        public String type = 'FlowScreenFieldOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowScreenFieldTranslation {
        public String fieldText;
        public String helpText;
        public FlowInputParameterTranslation[] inputParameters;
        public String name;
        public FlowInputValidationRuleTranslation validationRule;
        private String[] fieldText_type_info = new String[]{'fieldText',SOAP_M_URI,'string','0','1','false'};
        private String[] helpText_type_info = new String[]{'helpText',SOAP_M_URI,'string','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowInputParameterTranslation','0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] validationRule_type_info = new String[]{'validationRule',SOAP_M_URI,'FlowInputValidationRuleTranslation','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fieldText','helpText','inputParameters','name','validationRule'};
    }
    public class FlowScreenRule {
        public String type = 'FlowScreenRule';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String conditionLogic;
        public FlowCondition[] conditions;
        public String label;
        public FlowScreenRuleAction[] ruleActions;
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] ruleActions_type_info = new String[]{'ruleActions',SOAP_M_URI,'FlowScreenRuleAction','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','conditionLogic','conditions','label','ruleActions'};
    }
    public class FlowScreenRuleAction {
        public String type = 'FlowScreenRuleAction';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String attribute;
        public String fieldReference;
        public FlowElementReferenceOrValue value;
        private String[] attribute_type_info = new String[]{'attribute',SOAP_M_URI,'string','1','1','false'};
        private String[] fieldReference_type_info = new String[]{'fieldReference',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','attribute','fieldReference','value'};
    }
    public class FlowScreenTranslation {
        public String backButtonLabel;
        public FlowScreenFieldTranslation[] fields;
        public String helpText;
        public String name;
        public String nextOrFinishButtonLabel;
        public String pauseButtonLabel;
        public String pausedText;
        private String[] backButtonLabel_type_info = new String[]{'backButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,'FlowScreenFieldTranslation','0','-1','false'};
        private String[] helpText_type_info = new String[]{'helpText',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] nextOrFinishButtonLabel_type_info = new String[]{'nextOrFinishButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] pauseButtonLabel_type_info = new String[]{'pauseButtonLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] pausedText_type_info = new String[]{'pausedText',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'backButtonLabel','fields','helpText','name','nextOrFinishButtonLabel','pauseButtonLabel','pausedText'};
    }
    public class FlowScreenTrigger {
        public String type = 'FlowScreenTrigger';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String eventName;
        public String eventSource;
        public FlowScreenTriggerHandler[] handlers;
        private String[] eventName_type_info = new String[]{'eventName',SOAP_M_URI,'string','1','1','false'};
        private String[] eventSource_type_info = new String[]{'eventSource',SOAP_M_URI,'string','1','1','false'};
        private String[] handlers_type_info = new String[]{'handlers',SOAP_M_URI,'FlowScreenTriggerHandler','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','eventName','eventSource','handlers'};
    }
    public class FlowScreenTriggerHandler {
        public String type = 'FlowScreenTriggerHandler';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String conditionLogic;
        public FlowCondition[] conditions;
        public String screenActionName;
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] screenActionName_type_info = new String[]{'screenActionName',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','conditionLogic','conditions','screenActionName'};
    }
    public class FlowSettings extends Metadata {
        public String type = 'FlowSettings';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public Boolean canDebugFlowAsAnotherUser;
        public Boolean doesEnforceApexCpuTimeLimit;
        public Boolean doesFormulaEnforceDataAccess;
        public Boolean doesFormulaGenerateHtmlOutput;
        public Boolean enableEmailSimpleRespectProfiles;
        public Boolean enableEmailsimpleSecureProfiles;
        public Boolean enableFlowBREncodedFixEnabled;
        public Boolean enableFlowCustomPropertyEditor;
        public Boolean enableFlowDeployAsActiveEnabled;
        public Boolean enableFlowFieldFilterEnabled;
        public Boolean enableFlowFormulasFixEnabled;
        public Boolean enableFlowInterviewSharingEnabled;
        public Boolean enableFlowNullPreviousValueFix;
        public Boolean enableFlowPauseEnabled;
        public Boolean enableFlowReactiveChoiceOptions;
        public Boolean enableFlowReactiveScreens;
        public Boolean enableFlowUseApexExceptionEmail;
        public Boolean enableFlowViaRestUsesUserCtxt;
        public Boolean enableLightningRuntimeEnabled;
        public Boolean isApexPluginAccessModifierRespected;
        public Boolean isEnhancedFlowListViewVisible;
        public Boolean isFlowBlockAccessToSessionIDEnabled;
        public Boolean isManageFlowRequiredForAutomationCharts;
        public Boolean isSupportRollbackOnErrorForApexInvocableActionsEnabled;
        private String[] canDebugFlowAsAnotherUser_type_info = new String[]{'canDebugFlowAsAnotherUser',SOAP_M_URI,'boolean','0','1','false'};
        private String[] doesEnforceApexCpuTimeLimit_type_info = new String[]{'doesEnforceApexCpuTimeLimit',SOAP_M_URI,'boolean','0','1','false'};
        private String[] doesFormulaEnforceDataAccess_type_info = new String[]{'doesFormulaEnforceDataAccess',SOAP_M_URI,'boolean','0','1','false'};
        private String[] doesFormulaGenerateHtmlOutput_type_info = new String[]{'doesFormulaGenerateHtmlOutput',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEmailSimpleRespectProfiles_type_info = new String[]{'enableEmailSimpleRespectProfiles',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEmailsimpleSecureProfiles_type_info = new String[]{'enableEmailsimpleSecureProfiles',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowBREncodedFixEnabled_type_info = new String[]{'enableFlowBREncodedFixEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowCustomPropertyEditor_type_info = new String[]{'enableFlowCustomPropertyEditor',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowDeployAsActiveEnabled_type_info = new String[]{'enableFlowDeployAsActiveEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowFieldFilterEnabled_type_info = new String[]{'enableFlowFieldFilterEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowFormulasFixEnabled_type_info = new String[]{'enableFlowFormulasFixEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowInterviewSharingEnabled_type_info = new String[]{'enableFlowInterviewSharingEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowNullPreviousValueFix_type_info = new String[]{'enableFlowNullPreviousValueFix',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowPauseEnabled_type_info = new String[]{'enableFlowPauseEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowReactiveChoiceOptions_type_info = new String[]{'enableFlowReactiveChoiceOptions',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowReactiveScreens_type_info = new String[]{'enableFlowReactiveScreens',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowUseApexExceptionEmail_type_info = new String[]{'enableFlowUseApexExceptionEmail',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableFlowViaRestUsesUserCtxt_type_info = new String[]{'enableFlowViaRestUsesUserCtxt',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableLightningRuntimeEnabled_type_info = new String[]{'enableLightningRuntimeEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isApexPluginAccessModifierRespected_type_info = new String[]{'isApexPluginAccessModifierRespected',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isEnhancedFlowListViewVisible_type_info = new String[]{'isEnhancedFlowListViewVisible',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isFlowBlockAccessToSessionIDEnabled_type_info = new String[]{'isFlowBlockAccessToSessionIDEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isManageFlowRequiredForAutomationCharts_type_info = new String[]{'isManageFlowRequiredForAutomationCharts',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isSupportRollbackOnErrorForApexInvocableActionsEnabled_type_info = new String[]{'isSupportRollbackOnErrorForApexInvocableActionsEnabled',SOAP_M_URI,'boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fullName','canDebugFlowAsAnotherUser','doesEnforceApexCpuTimeLimit','doesFormulaEnforceDataAccess','doesFormulaGenerateHtmlOutput','enableEmailSimpleRespectProfiles','enableEmailsimpleSecureProfiles','enableFlowBREncodedFixEnabled','enableFlowCustomPropertyEditor','enableFlowDeployAsActiveEnabled','enableFlowFieldFilterEnabled','enableFlowFormulasFixEnabled','enableFlowInterviewSharingEnabled','enableFlowNullPreviousValueFix','enableFlowPauseEnabled','enableFlowReactiveChoiceOptions','enableFlowReactiveScreens','enableFlowUseApexExceptionEmail','enableFlowViaRestUsesUserCtxt','enableLightningRuntimeEnabled','isApexPluginAccessModifierRespected','isEnhancedFlowListViewVisible','isFlowBlockAccessToSessionIDEnabled','isManageFlowRequiredForAutomationCharts','isSupportRollbackOnErrorForApexInvocableActionsEnabled'};
    }
    public class FlowStage {
        public String type = 'FlowStage';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean isActive;
        public String label;
        public Integer stageOrder;
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,'boolean','1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] stageOrder_type_info = new String[]{'stageOrder',SOAP_M_URI,'int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','isActive','label','stageOrder'};
    }
    public class FlowStageStep {
        public String type = 'FlowStageStep';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String actionName;
        public String actionType;
        public FlowStageStepAssignee[] assignees;
        public Boolean canAssigneeEdit;
        public FlowStageStepEntryActionInputParameter[] entryActionInputParameters;
        public String entryActionName;
        public FlowStageStepEntryActionOutputParameter[] entryActionOutputParameters;
        public String entryActionType;
        public String entryConditionLogic;
        public FlowCondition[] entryConditions;
        public FlowStageStepExitActionInputParameter[] exitActionInputParameters;
        public String exitActionName;
        public FlowStageStepExitActionOutputParameter[] exitActionOutputParameters;
        public String exitActionType;
        public String exitConditionLogic;
        public FlowCondition[] exitConditions;
        public FlowStageStepInputParameter[] inputParameters;
        public String label;
        public FlowStageStepOutputParameter[] outputParameters;
        public Boolean requiresAsyncProcessing;
        public Boolean runAsUser;
        public Boolean shouldLock;
        public String stepSubtype;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,'string','0','1','false'};
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] assignees_type_info = new String[]{'assignees',SOAP_M_URI,'FlowStageStepAssignee','0','-1','false'};
        private String[] canAssigneeEdit_type_info = new String[]{'canAssigneeEdit',SOAP_M_URI,'boolean','0','1','false'};
        private String[] entryActionInputParameters_type_info = new String[]{'entryActionInputParameters',SOAP_M_URI,'FlowStageStepEntryActionInputParameter','0','-1','false'};
        private String[] entryActionName_type_info = new String[]{'entryActionName',SOAP_M_URI,'string','0','1','false'};
        private String[] entryActionOutputParameters_type_info = new String[]{'entryActionOutputParameters',SOAP_M_URI,'FlowStageStepEntryActionOutputParameter','0','-1','false'};
        private String[] entryActionType_type_info = new String[]{'entryActionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] entryConditionLogic_type_info = new String[]{'entryConditionLogic',SOAP_M_URI,'string','1','1','false'};
        private String[] entryConditions_type_info = new String[]{'entryConditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] exitActionInputParameters_type_info = new String[]{'exitActionInputParameters',SOAP_M_URI,'FlowStageStepExitActionInputParameter','0','-1','false'};
        private String[] exitActionName_type_info = new String[]{'exitActionName',SOAP_M_URI,'string','0','1','false'};
        private String[] exitActionOutputParameters_type_info = new String[]{'exitActionOutputParameters',SOAP_M_URI,'FlowStageStepExitActionOutputParameter','0','-1','false'};
        private String[] exitActionType_type_info = new String[]{'exitActionType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] exitConditionLogic_type_info = new String[]{'exitConditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] exitConditions_type_info = new String[]{'exitConditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowStageStepInputParameter','0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] outputParameters_type_info = new String[]{'outputParameters',SOAP_M_URI,'FlowStageStepOutputParameter','0','-1','false'};
        private String[] requiresAsyncProcessing_type_info = new String[]{'requiresAsyncProcessing',SOAP_M_URI,'boolean','0','1','false'};
        private String[] runAsUser_type_info = new String[]{'runAsUser',SOAP_M_URI,'boolean','0','1','false'};
        private String[] shouldLock_type_info = new String[]{'shouldLock',SOAP_M_URI,'boolean','0','1','false'};
        private String[] stepSubtype_type_info = new String[]{'stepSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','actionName','actionType','assignees','canAssigneeEdit','entryActionInputParameters','entryActionName','entryActionOutputParameters','entryActionType','entryConditionLogic','entryConditions','exitActionInputParameters','exitActionName','exitActionOutputParameters','exitActionType','exitConditionLogic','exitConditions','inputParameters','label','outputParameters','requiresAsyncProcessing','runAsUser','shouldLock','stepSubtype'};
    }
    public class FlowStageStepAssignee {
        public String type = 'FlowStageStepAssignee';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowElementReferenceOrValue assignee;
        public String assigneeType;
        private String[] assignee_type_info = new String[]{'assignee',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] assigneeType_type_info = new String[]{'assigneeType',SOAP_M_URI,'FlowStageStepAssigneeType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignee','assigneeType'};
    }
    public class FlowStageStepEntryActionInputParameter {
        public String type = 'FlowStageStepEntryActionInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowStageStepEntryActionOutputParameter {
        public String type = 'FlowStageStepEntryActionOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowStageStepExitActionInputParameter {
        public String type = 'FlowStageStepExitActionInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowStageStepExitActionOutputParameter {
        public String type = 'FlowStageStepExitActionOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowStageStepInputParameter {
        public String type = 'FlowStageStepInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowStageStepOutputParameter {
        public String type = 'FlowStageStepOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowStageTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class FlowStart {
        public String type = 'FlowStart';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowCapability[] capabilityTypes;
        public FlowConnector connector;
        public String dataGraph;
        public FlowDataTypeMapping[] dataTypeMappings;
        public Boolean doesRequireRecordChangedToMeetCriteria;
        public String entryType;
        public String eventName;
        public String eventType;
        public String filterFormula;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public String flowRunAsUser;
        public String form;
        public FlowStartInputParameter[] inputs;
        public String object_x;
        public String objectContainer;
        public Boolean publishSegment;
        public String recordTriggerType;
        public FlowSchedule schedule;
        public FlowScheduledPath[] scheduledPaths;
        public String segment;
        public String triggerType;
        public String triggeringDataGraph;
        public String triggeringDataModelObjectPath;
        private String[] capabilityTypes_type_info = new String[]{'capabilityTypes',SOAP_M_URI,'FlowCapability','0','-1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] dataGraph_type_info = new String[]{'dataGraph',SOAP_M_URI,'string','0','1','false'};
        private String[] dataTypeMappings_type_info = new String[]{'dataTypeMappings',SOAP_M_URI,'FlowDataTypeMapping','0','-1','false'};
        private String[] doesRequireRecordChangedToMeetCriteria_type_info = new String[]{'doesRequireRecordChangedToMeetCriteria',SOAP_M_URI,'boolean','0','1','false'};
        private String[] entryType_type_info = new String[]{'entryType',SOAP_M_URI,'FlowEntryType','0','1','false'};
        private String[] eventName_type_info = new String[]{'eventName',SOAP_M_URI,'string','0','1','false'};
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] filterFormula_type_info = new String[]{'filterFormula',SOAP_M_URI,'string','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] flowRunAsUser_type_info = new String[]{'flowRunAsUser',SOAP_M_URI,'FlowRunAsUser','0','1','false'};
        private String[] form_type_info = new String[]{'form',SOAP_M_URI,'string','0','1','false'};
        private String[] inputs_type_info = new String[]{'inputs',SOAP_M_URI,'FlowStartInputParameter','0','-1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] objectContainer_type_info = new String[]{'objectContainer',SOAP_M_URI,'string','0','1','false'};
        private String[] publishSegment_type_info = new String[]{'publishSegment',SOAP_M_URI,'boolean','0','1','false'};
        private String[] recordTriggerType_type_info = new String[]{'recordTriggerType',SOAP_M_URI,'RecordTriggerType','0','1','false'};
        private String[] schedule_type_info = new String[]{'schedule',SOAP_M_URI,'FlowSchedule','0','1','false'};
        private String[] scheduledPaths_type_info = new String[]{'scheduledPaths',SOAP_M_URI,'FlowScheduledPath','0','-1','false'};
        private String[] segment_type_info = new String[]{'segment',SOAP_M_URI,'string','0','1','false'};
        private String[] triggerType_type_info = new String[]{'triggerType',SOAP_M_URI,'FlowTriggerType','0','1','false'};
        private String[] triggeringDataGraph_type_info = new String[]{'triggeringDataGraph',SOAP_M_URI,'string','0','1','false'};
        private String[] triggeringDataModelObjectPath_type_info = new String[]{'triggeringDataModelObjectPath',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','capabilityTypes','connector','dataGraph','dataTypeMappings','doesRequireRecordChangedToMeetCriteria','entryType','eventName','eventType','filterFormula','filterLogic','filters','flowRunAsUser','form','inputs','object_x','objectContainer','publishSegment','recordTriggerType','schedule','scheduledPaths','segment','triggerType','triggeringDataGraph','triggeringDataModelObjectPath'};
    }
    public class FlowStartInputParameter {
        public String type = 'FlowStartInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowStep {
        public String type = 'FlowStep';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector[] connectors;
        private String[] connectors_type_info = new String[]{'connectors',SOAP_M_URI,'FlowConnector','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connectors'};
    }
    public class FlowSubflow {
        public String type = 'FlowSubflow';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector connector;
        public String flowName;
        public FlowSubflowInputAssignment[] inputAssignments;
        public FlowSubflowOutputAssignment[] outputAssignments;
        public Boolean storeOutputAutomatically;
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] flowName_type_info = new String[]{'flowName',SOAP_M_URI,'string','0','1','false'};
        private String[] inputAssignments_type_info = new String[]{'inputAssignments',SOAP_M_URI,'FlowSubflowInputAssignment','0','-1','false'};
        private String[] outputAssignments_type_info = new String[]{'outputAssignments',SOAP_M_URI,'FlowSubflowOutputAssignment','0','-1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','connector','flowName','inputAssignments','outputAssignments','storeOutputAutomatically'};
    }
    public class FlowSubflowInputAssignment {
        public String type = 'FlowSubflowInputAssignment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowSubflowOutputAssignment {
        public String type = 'FlowSubflowOutputAssignment';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    public class FlowTest extends Metadata {
        public String type = 'FlowTest';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        public String description;
        public String flowApiName;
        public String label;
        public FlowTestPoint[] testPoints;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] flowApiName_type_info = new String[]{'flowApiName',SOAP_M_URI,'string','1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] testPoints_type_info = new String[]{'testPoints',SOAP_M_URI,'FlowTestPoint','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fullName','description','flowApiName','label','testPoints'};
    }
    public class FlowTestAssertion {
        public FlowTestCondition[] conditions;
        public String errorMessage;
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowTestCondition','0','-1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'conditions','errorMessage'};
    }
    public class FlowTestCondition {
        public String leftValueReference;
        public String operator;
        public FlowTestReferenceOrValue rightValue;
        private String[] leftValueReference_type_info = new String[]{'leftValueReference',SOAP_M_URI,'string','1','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,'FlowComparisonOperator','1','1','false'};
        private String[] rightValue_type_info = new String[]{'rightValue',SOAP_M_URI,'FlowTestReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'leftValueReference','operator','rightValue'};
    }
    public class FlowTestParameter {
        public String leftValueReference;
        public String type_x;
        public FlowTestReferenceOrValue value;
        private String[] leftValueReference_type_info = new String[]{'leftValueReference',SOAP_M_URI,'string','1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,'FlowTestParameterType','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowTestReferenceOrValue','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'leftValueReference','type_x','value'};
    }
    public class FlowTestPoint {
        public FlowTestAssertion[] assertions;
        public String elementApiName;
        public FlowTestParameter[] parameters;
        private String[] assertions_type_info = new String[]{'assertions',SOAP_M_URI,'FlowTestAssertion','0','-1','false'};
        private String[] elementApiName_type_info = new String[]{'elementApiName',SOAP_M_URI,'string','1','1','false'};
        private String[] parameters_type_info = new String[]{'parameters',SOAP_M_URI,'FlowTestParameter','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assertions','elementApiName','parameters'};
    }
    public class FlowTestReferenceOrValue {
        public Boolean booleanValue;
        public DateTime dateTimeValue;
        public Date dateValue;
        public Double numberValue;
        public String sobjectValue;
        public String stringValue;
        private String[] booleanValue_type_info = new String[]{'booleanValue',SOAP_M_URI,'boolean','0','1','true'};
        private String[] dateTimeValue_type_info = new String[]{'dateTimeValue',SOAP_M_URI,'dateTime','0','1','false'};
        private String[] dateValue_type_info = new String[]{'dateValue',SOAP_M_URI,'date','0','1','false'};
        private String[] numberValue_type_info = new String[]{'numberValue',SOAP_M_URI,'double','0','1','true'};
        private String[] sobjectValue_type_info = new String[]{'sobjectValue',SOAP_M_URI,'string','0','1','true'};
        private String[] stringValue_type_info = new String[]{'stringValue',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'booleanValue','dateTimeValue','dateValue','numberValue','sobjectValue','stringValue'};
    }
    public class FlowTextTemplate {
        public String type = 'FlowTextTemplate';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public Boolean isViewedAsPlainText;
        public String text;
        private String[] isViewedAsPlainText_type_info = new String[]{'isViewedAsPlainText',SOAP_M_URI,'boolean','0','1','false'};
        private String[] text_type_info = new String[]{'text',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','isViewedAsPlainText','text'};
    }
    public class FlowTextTemplateTranslation {
        public String name;
        public String text;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] text_type_info = new String[]{'text',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','text'};
    }
    public class FlowTransform {
        public String type = 'FlowTransform';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String apexClass;
        public FlowConnector connector;
        public String dataType;
        public Boolean isCollection;
        public String objectType;
        public Integer scale;
        public Boolean storeOutputAutomatically;
        public FlowTransformValue[] transformValues;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,'string','0','1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','0','1','false'};
        private String[] isCollection_type_info = new String[]{'isCollection',SOAP_M_URI,'boolean','0','1','false'};
        private String[] objectType_type_info = new String[]{'objectType',SOAP_M_URI,'string','0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,'int','0','1','false'};
        private String[] storeOutputAutomatically_type_info = new String[]{'storeOutputAutomatically',SOAP_M_URI,'boolean','0','1','false'};
        private String[] transformValues_type_info = new String[]{'transformValues',SOAP_M_URI,'FlowTransformValue','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','apexClass','connector','dataType','isCollection','objectType','scale','storeOutputAutomatically','transformValues'};
    }
    public class FlowTransformValue {
        public String type = 'FlowTransformValue';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowTransformValueAction[] transformValueActions;
        public String transformValueDescription;
        public String transformValueLabel;
        public String transformValueName;
        private String[] transformValueActions_type_info = new String[]{'transformValueActions',SOAP_M_URI,'FlowTransformValueAction','0','-1','false'};
        private String[] transformValueDescription_type_info = new String[]{'transformValueDescription',SOAP_M_URI,'string','0','1','false'};
        private String[] transformValueLabel_type_info = new String[]{'transformValueLabel',SOAP_M_URI,'string','0','1','false'};
        private String[] transformValueName_type_info = new String[]{'transformValueName',SOAP_M_URI,'string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','transformValueActions','transformValueDescription','transformValueLabel','transformValueName'};
    }
    public class FlowTransformValueAction {
        public String type = 'FlowTransformValueAction';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public FlowTransformValueActionInputParameter[] inputParameters;
        public String name;
        public String outputFieldApiName;
        public String transformType;
        public FlowElementReferenceOrValue value;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','0','1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowTransformValueActionInputParameter','0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        private String[] outputFieldApiName_type_info = new String[]{'outputFieldApiName',SOAP_M_URI,'string','0','1','false'};
        private String[] transformType_type_info = new String[]{'transformType',SOAP_M_URI,'FlowTransformValueActionType','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','inputParameters','name','outputFieldApiName','transformType','value'};
    }
    public class FlowTransformValueActionInputParameter {
        public String type = 'FlowTransformValueActionInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowTranslation {
        public FlowChoiceTranslation[] choices;
        public FlowCustomErrorMessageTranslation[] customErrorMessages;
        public String fullName;
        public String label;
        public FlowOrchestrationStepTranslation[] orchestrationSteps;
        public FlowScreenTranslation[] screens;
        public FlowStageTranslation[] stages;
        public FlowTextTemplateTranslation[] textTemplates;
        private String[] choices_type_info = new String[]{'choices',SOAP_M_URI,'FlowChoiceTranslation','0','-1','false'};
        private String[] customErrorMessages_type_info = new String[]{'customErrorMessages',SOAP_M_URI,'FlowCustomErrorMessageTranslation','0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] orchestrationSteps_type_info = new String[]{'orchestrationSteps',SOAP_M_URI,'FlowOrchestrationStepTranslation','0','-1','false'};
        private String[] screens_type_info = new String[]{'screens',SOAP_M_URI,'FlowScreenTranslation','0','-1','false'};
        private String[] stages_type_info = new String[]{'stages',SOAP_M_URI,'FlowStageTranslation','0','-1','false'};
        private String[] textTemplates_type_info = new String[]{'textTemplates',SOAP_M_URI,'FlowTextTemplateTranslation','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'choices','customErrorMessages','fullName','label','orchestrationSteps','screens','stages','textTemplates'};
    }
    public class FlowVariable {
        public String type = 'FlowVariable';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String apexClass;
        public String dataType;
        public Boolean isCollection;
        public Boolean isInput;
        public Boolean isOutput;
        public String objectType;
        public Integer scale;
        public FlowElementReferenceOrValue value;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,'string','0','1','false'};
        private String[] dataType_type_info = new String[]{'dataType',SOAP_M_URI,'FlowDataType','1','1','false'};
        private String[] isCollection_type_info = new String[]{'isCollection',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isInput_type_info = new String[]{'isInput',SOAP_M_URI,'boolean','0','1','false'};
        private String[] isOutput_type_info = new String[]{'isOutput',SOAP_M_URI,'boolean','0','1','false'};
        private String[] objectType_type_info = new String[]{'objectType',SOAP_M_URI,'string','0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,'int','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','apexClass','dataType','isCollection','isInput','isOutput','objectType','scale','value'};
    }
    public class FlowVisibilityRule {
        public String type = 'FlowVisibilityRule';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String conditionLogic;
        public FlowCondition[] conditions;
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','conditionLogic','conditions'};
    }
    public class FlowWait {
        public String type = 'FlowWait';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String elementSubtype;
        public String label;
        public Integer locationX;
        public Integer locationY;
        private String[] elementSubtype_type_info = new String[]{'elementSubtype',SOAP_M_URI,'FlowElementSubtype','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','0','1','false'};
        private String[] locationX_type_info = new String[]{'locationX',SOAP_M_URI,'int','1','1','false'};
        private String[] locationY_type_info = new String[]{'locationY',SOAP_M_URI,'int','1','1','false'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public FlowConnector defaultConnector;
        public String defaultConnectorLabel;
        public FlowConnector faultConnector;
        public String timeZoneId;
        public FlowWaitEvent[] waitEvents;
        private String[] defaultConnector_type_info = new String[]{'defaultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] defaultConnectorLabel_type_info = new String[]{'defaultConnectorLabel',SOAP_M_URI,'string','1','1','false'};
        private String[] faultConnector_type_info = new String[]{'faultConnector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] timeZoneId_type_info = new String[]{'timeZoneId',SOAP_M_URI,'string','0','1','false'};
        private String[] waitEvents_type_info = new String[]{'waitEvents',SOAP_M_URI,'FlowWaitEvent','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'elementSubtype','label','locationX','locationY','description','name','processMetadataValues','defaultConnector','defaultConnectorLabel','faultConnector','timeZoneId','waitEvents'};
    }
    public class FlowWaitEvent {
        public String type = 'FlowWaitEvent';
        private String[] type_att_info = new String[]{'xsi:type'};
        public String description;
        public String name;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,'string','0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String associatedElement;
        public String automationEventName;
        public String automationEventType;
        public String conditionLogic;
        public FlowCondition[] conditions;
        public FlowConnector connector;
        public String eventType;
        public String filterLogic;
        public FlowRecordFilter[] filters;
        public FlowWaitEventInputParameter[] inputParameters;
        public String interactionType;
        public String label;
        public Integer maxBatchSize;
        public String object_x;
        public Integer offset;
        public String offsetUnit;
        public FlowWaitEventOutputParameter[] outputParameters;
        public String recordTriggerType;
        public Date resumeDate;
        public String resumeDateReference;
        public String resumeTime;
        private String[] associatedElement_type_info = new String[]{'associatedElement',SOAP_M_URI,'string','0','1','false'};
        private String[] automationEventName_type_info = new String[]{'automationEventName',SOAP_M_URI,'string','0','1','false'};
        private String[] automationEventType_type_info = new String[]{'automationEventType',SOAP_M_URI,'InvocableActionType','0','1','false'};
        private String[] conditionLogic_type_info = new String[]{'conditionLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] conditions_type_info = new String[]{'conditions',SOAP_M_URI,'FlowCondition','0','-1','false'};
        private String[] connector_type_info = new String[]{'connector',SOAP_M_URI,'FlowConnector','0','1','false'};
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,'string','0','1','false'};
        private String[] filterLogic_type_info = new String[]{'filterLogic',SOAP_M_URI,'string','0','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,'FlowRecordFilter','0','-1','false'};
        private String[] inputParameters_type_info = new String[]{'inputParameters',SOAP_M_URI,'FlowWaitEventInputParameter','0','-1','false'};
        private String[] interactionType_type_info = new String[]{'interactionType',SOAP_M_URI,'FlowWaitInteractionType','0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,'string','1','1','false'};
        private String[] maxBatchSize_type_info = new String[]{'maxBatchSize',SOAP_M_URI,'int','0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,'string','0','1','false'};
        private String[] offset_type_info = new String[]{'offset',SOAP_M_URI,'int','0','1','false'};
        private String[] offsetUnit_type_info = new String[]{'offsetUnit',SOAP_M_URI,'FlowScheduledPathOffsetUnit','0','1','false'};
        private String[] outputParameters_type_info = new String[]{'outputParameters',SOAP_M_URI,'FlowWaitEventOutputParameter','0','-1','false'};
        private String[] recordTriggerType_type_info = new String[]{'recordTriggerType',SOAP_M_URI,'RecordTriggerType','0','1','false'};
        private String[] resumeDate_type_info = new String[]{'resumeDate',SOAP_M_URI,'date','0','1','false'};
        private String[] resumeDateReference_type_info = new String[]{'resumeDateReference',SOAP_M_URI,'string','0','1','false'};
        private String[] resumeTime_type_info = new String[]{'resumeTime',SOAP_M_URI,'time','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','name','processMetadataValues','associatedElement','automationEventName','automationEventType','conditionLogic','conditions','connector','eventType','filterLogic','filters','inputParameters','interactionType','label','maxBatchSize','object_x','offset','offsetUnit','outputParameters','recordTriggerType','resumeDate','resumeDateReference','resumeTime'};
    }
    public class FlowWaitEventInputParameter {
        public String type = 'FlowWaitEventInputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String name;
        public FlowElementReferenceOrValue value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,'FlowElementReferenceOrValue','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','name','value'};
    }
    public class FlowWaitEventOutputParameter {
        public String type = 'FlowWaitEventOutputParameter';
        private String[] type_att_info = new String[]{'xsi:type'};
        public FlowMetadataValue[] processMetadataValues;
        private String[] processMetadataValues_type_info = new String[]{'processMetadataValues',SOAP_M_URI,'FlowMetadataValue','0','-1','false'};
        public String assignToReference;
        public String name;
        private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,'string','1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,'string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'processMetadataValues','assignToReference','name'};
    }
    // flow end
    public class CustomMetadataValue {
        public String field;
        public String value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','value'};
    }
    public class ArticleTypeTemplate {
        public String channel;
        public String page_x;
        public String template;
        private String[] channel_type_info = new String[]{'channel',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] template_type_info = new String[]{'template',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'channel','page_x','template'};
    }
    public class WaveDataflow extends MetadataWithContent {
        public String type = 'WaveDataflow';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String masterLabel;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'description','masterLabel'};
    }
    public class StandardValueSet extends Metadata {
        public String type = 'StandardValueSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean sorted;
        public MetadataService.StandardValue[] standardValue;
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] standardValue_type_info = new String[]{'standardValue',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'sorted','standardValue'};
    }
    public class LetterheadHeaderFooter {
        public String backgroundColor;
        public Integer height;
        public String horizontalAlignment;
        public String logo;
        public String verticalAlignment;
        private String[] backgroundColor_type_info = new String[]{'backgroundColor',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'1','1','false'};
        private String[] horizontalAlignment_type_info = new String[]{'horizontalAlignment',SOAP_M_URI,null,'0','1','false'};
        private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
        private String[] verticalAlignment_type_info = new String[]{'verticalAlignment',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'backgroundColor','height','horizontalAlignment','logo','verticalAlignment'};
    }
    public class PicklistValueTranslation {
        public String masterLabel;
        public String translation;
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] translation_type_info = new String[]{'translation',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','translation'};
    }
    public class CountriesAndStates {
        public MetadataService.Country[] countries;
        private String[] countries_type_info = new String[]{'countries',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'countries'};
    }
    public class PathAssistant {
        public Boolean active;
        public String entityName;
        public String fieldName;
        public String masterLabel;
        public MetadataService.PathAssistantStep[] pathAssistantSteps;
        public String recordTypeName;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] entityName_type_info = new String[]{'entityName',SOAP_M_URI,null,'1','1','false'};
        private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] pathAssistantSteps_type_info = new String[]{'pathAssistantSteps',SOAP_M_URI,null,'0','-1','false'};
        private String[] recordTypeName_type_info = new String[]{'recordTypeName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','entityName','fieldName','masterLabel','pathAssistantSteps','recordTypeName'};
    }
    public class AsyncResult {
        public Boolean done;
        public String id;
        public String message;
        public String state;
        public String statusCode;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'0','1','false'};
        private String[] state_type_info = new String[]{'state',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id','message','state','statusCode'};
    }
    public class XOrgHub extends Metadata {
        public String type = 'XOrgHub';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String label;
        public Boolean lockSharedObjects;
        public String[] permissionSets;
        public MetadataService.XOrgHubSharedObject[] sharedObjects;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] lockSharedObjects_type_info = new String[]{'lockSharedObjects',SOAP_M_URI,null,'1','1','false'};
        private String[] permissionSets_type_info = new String[]{'permissionSets',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharedObjects_type_info = new String[]{'sharedObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'label','lockSharedObjects','permissionSets','sharedObjects'};
    }
    public class CustomLabel extends Metadata {
        public String type = 'CustomLabel';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String categories;
        public String language;
        public Boolean protected_x;
        public String shortDescription;
        public String value;
        private String[] categories_type_info = new String[]{'categories',SOAP_M_URI,null,'0','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'1','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] shortDescription_type_info = new String[]{'shortDescription',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'categories','language','protected_x','shortDescription','value'};
    }
    public class NameSettings extends Metadata {
        public String type = 'NameSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableMiddleName;
        public Boolean enableNameSuffix;
        private String[] enableMiddleName_type_info = new String[]{'enableMiddleName',SOAP_M_URI,null,'0','1','false'};
        private String[] enableNameSuffix_type_info = new String[]{'enableNameSuffix',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableMiddleName','enableNameSuffix'};
    }
    public class EventType extends Metadata {
        public String type = 'EventType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public MetadataService.EventTypeParameter[] fields;
        public String label;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','fields','label'};
    }
    public class checkRetrieveStatusResponse_element {
        public MetadataService.RetrieveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class Territory2Settings extends Metadata {
        public String type = 'Territory2Settings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String defaultAccountAccessLevel;
        public String defaultCaseAccessLevel;
        public String defaultContactAccessLevel;
        public String defaultOpportunityAccessLevel;
        public MetadataService.Territory2SettingsOpportunityFilter opportunityFilterSettings;
        private String[] defaultAccountAccessLevel_type_info = new String[]{'defaultAccountAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultCaseAccessLevel_type_info = new String[]{'defaultCaseAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultContactAccessLevel_type_info = new String[]{'defaultContactAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultOpportunityAccessLevel_type_info = new String[]{'defaultOpportunityAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] opportunityFilterSettings_type_info = new String[]{'opportunityFilterSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'defaultAccountAccessLevel','defaultCaseAccessLevel','defaultContactAccessLevel','defaultOpportunityAccessLevel','opportunityFilterSettings'};
    }
    public class PlatformCachePartition {
        public String description;
        public Boolean isDefaultPartition;
        public String masterLabel;
        public MetadataService.PlatformCachePartitionType[] platformCachePartitionTypes;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isDefaultPartition_type_info = new String[]{'isDefaultPartition',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] platformCachePartitionTypes_type_info = new String[]{'platformCachePartitionTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','isDefaultPartition','masterLabel','platformCachePartitionTypes'};
    }
    public class ConnectedAppIpRange {
        public String description;
        public String end_x;
        public String start;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] end_x_type_info = new String[]{'end',SOAP_M_URI,null,'1','1','false'};
        private String[] start_type_info = new String[]{'start',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','end_x','start'};
    }
    public class ExternalDataSource extends Metadata {
        public String type = 'ExternalDataSource';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String authProvider;
        public String certificate;
        public String customConfiguration;
        public String endpoint;
        public Boolean isWritable;
        public String label;
        public String oauthRefreshToken;
        public String oauthScope;
        public String oauthToken;
        public String password;
        public String principalType;
        public String protocol;
        public String repository;
        public String type_x;
        public String username;
        public String version;
        private String[] authProvider_type_info = new String[]{'authProvider',SOAP_M_URI,null,'0','1','false'};
        private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
        private String[] customConfiguration_type_info = new String[]{'customConfiguration',SOAP_M_URI,null,'0','1','false'};
        private String[] endpoint_type_info = new String[]{'endpoint',SOAP_M_URI,null,'0','1','false'};
        private String[] isWritable_type_info = new String[]{'isWritable',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] oauthRefreshToken_type_info = new String[]{'oauthRefreshToken',SOAP_M_URI,null,'0','1','false'};
        private String[] oauthScope_type_info = new String[]{'oauthScope',SOAP_M_URI,null,'0','1','false'};
        private String[] oauthToken_type_info = new String[]{'oauthToken',SOAP_M_URI,null,'0','1','false'};
        private String[] password_type_info = new String[]{'password',SOAP_M_URI,null,'0','1','false'};
        private String[] principalType_type_info = new String[]{'principalType',SOAP_M_URI,null,'1','1','false'};
        private String[] protocol_type_info = new String[]{'protocol',SOAP_M_URI,null,'1','1','false'};
        private String[] repository_type_info = new String[]{'repository',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] username_type_info = new String[]{'username',SOAP_M_URI,null,'0','1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'authProvider','certificate','customConfiguration','endpoint','isWritable','label','oauthRefreshToken','oauthScope','oauthToken','password','principalType','protocol','repository','type_x','username','version'};
    }
    public class retrieveResponse_element {
        public MetadataService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ComponentInstance {
        public MetadataService.ComponentInstanceProperty[] componentInstanceProperties;
        public String componentName;
        private String[] componentInstanceProperties_type_info = new String[]{'componentInstanceProperties',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentName_type_info = new String[]{'componentName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentInstanceProperties','componentName'};
    }
    public class LayoutSectionTranslation {
        public String label;
        public String section;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] section_type_info = new String[]{'section',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','section'};
    }
    public class MarketingResourceType extends Metadata {
        public String type = 'MarketingResourceType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String masterLabel;
        public String object_x;
        public String provider;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] provider_type_info = new String[]{'provider',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','masterLabel','object_x','provider'};
    }
    public class ApprovalSubmitter {
        public String submitter;
        public String type_x;
        private String[] submitter_type_info = new String[]{'submitter',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'submitter','type_x'};
    }
    public class upsertMetadataResponse_element {
        public MetadataService.UpsertResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ChannelLayout extends Metadata {
        public String type = 'ChannelLayout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] enabledChannels;
        public String label;
        public MetadataService.ChannelLayoutItem[] layoutItems;
        private String[] enabledChannels_type_info = new String[]{'enabledChannels',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] layoutItems_type_info = new String[]{'layoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enabledChannels','label','layoutItems'};
    }
    public class LiveChatDeploymentDomainWhitelist {
        public String[] domain;
        private String[] domain_type_info = new String[]{'domain',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'domain'};
    }
    public class PermissionSetRecordTypeVisibility {
        public String recordType;
        public Boolean visible;
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'recordType','visible'};
    }
    public class cancelDeploy_element {
        public String String_x;
        private String[] String_x_type_info = new String[]{'String',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'String_x'};
    }
    public class ReportFolder extends Folder {
        public String type = 'ReportFolder';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessType;
        public MetadataService.FolderShare[] folderShares;
        public String name;
        public String publicFolderAccess;
        public MetadataService.SharedTo sharedTo;
        private String[] accessType_type_info = new String[]{'accessType',SOAP_M_URI,null,'0','1','false'};
        private String[] folderShares_type_info = new String[]{'folderShares',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] publicFolderAccess_type_info = new String[]{'publicFolderAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessType','folderShares','name','publicFolderAccess','sharedTo'};
    }
    public class DashboardComponentSection {
        public String columnSize;
        public MetadataService.DashboardComponent[] components;
        private String[] columnSize_type_info = new String[]{'columnSize',SOAP_M_URI,null,'1','1','false'};
        private String[] components_type_info = new String[]{'components',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'columnSize','components'};
    }
    public class EscalationRule extends Metadata {
        public String type = 'EscalationRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public MetadataService.RuleEntry[] ruleEntry;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] ruleEntry_type_info = new String[]{'ruleEntry',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','ruleEntry'};
    }
    public class RunTestFailure {
        public String id;
        public String message;
        public String methodName;
        public String name;
        public String namespace;
        public String packageName;
        public Boolean seeAllData;
        public String stackTrace;
        public Double time_x;
        public String type_x;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','true'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] packageName_type_info = new String[]{'packageName',SOAP_M_URI,null,'1','1','false'};
        private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
        private String[] stackTrace_type_info = new String[]{'stackTrace',SOAP_M_URI,null,'1','1','true'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','message','methodName','name','namespace','packageName','seeAllData','stackTrace','time_x','type_x'};
    }
    public class SubtabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    public class ConnectedAppMobileDetailConfig {
        public String applicationBinaryFile;
        public String applicationBinaryFileName;
        public String applicationBundleIdentifier;
        public Integer applicationFileLength;
        public String applicationIconFile;
        public String applicationIconFileName;
        public String applicationInstallUrl;
        public String devicePlatform;
        public String deviceType;
        public String minimumOsVersion;
        public Boolean privateApp;
        public String version;
        private String[] applicationBinaryFile_type_info = new String[]{'applicationBinaryFile',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationBinaryFileName_type_info = new String[]{'applicationBinaryFileName',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationBundleIdentifier_type_info = new String[]{'applicationBundleIdentifier',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationFileLength_type_info = new String[]{'applicationFileLength',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationIconFile_type_info = new String[]{'applicationIconFile',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationIconFileName_type_info = new String[]{'applicationIconFileName',SOAP_M_URI,null,'0','1','false'};
        private String[] applicationInstallUrl_type_info = new String[]{'applicationInstallUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] devicePlatform_type_info = new String[]{'devicePlatform',SOAP_M_URI,null,'1','1','false'};
        private String[] deviceType_type_info = new String[]{'deviceType',SOAP_M_URI,null,'0','1','false'};
        private String[] minimumOsVersion_type_info = new String[]{'minimumOsVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] privateApp_type_info = new String[]{'privateApp',SOAP_M_URI,null,'0','1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'applicationBinaryFile','applicationBinaryFileName','applicationBundleIdentifier','applicationFileLength','applicationIconFile','applicationIconFileName','applicationInstallUrl','devicePlatform','deviceType','minimumOsVersion','privateApp','version'};
    }
    public class PermissionSet extends Metadata {
        public String type = 'PermissionSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.PermissionSetApplicationVisibility[] applicationVisibilities;
        public MetadataService.PermissionSetApexClassAccess[] classAccesses;
        public MetadataService.PermissionSetCustomPermissions[] customPermissions;
        public String description;
        public MetadataService.PermissionSetExternalDataSourceAccess[] externalDataSourceAccesses;
        public MetadataService.PermissionSetFieldPermissions[] fieldPermissions;
        public Boolean hasActivationRequired;
        public String label;
        public String license;
        public MetadataService.PermissionSetObjectPermissions[] objectPermissions;
        public MetadataService.PermissionSetApexPageAccess[] pageAccesses;
        public MetadataService.PermissionSetRecordTypeVisibility[] recordTypeVisibilities;
        public MetadataService.PermissionSetTabSetting[] tabSettings;
        public MetadataService.PermissionSetUserPermission[] userPermissions;
        private String[] applicationVisibilities_type_info = new String[]{'applicationVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] classAccesses_type_info = new String[]{'classAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] customPermissions_type_info = new String[]{'customPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDataSourceAccesses_type_info = new String[]{'externalDataSourceAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] fieldPermissions_type_info = new String[]{'fieldPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] hasActivationRequired_type_info = new String[]{'hasActivationRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] license_type_info = new String[]{'license',SOAP_M_URI,null,'0','1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] pageAccesses_type_info = new String[]{'pageAccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] recordTypeVisibilities_type_info = new String[]{'recordTypeVisibilities',SOAP_M_URI,null,'0','-1','false'};
        private String[] tabSettings_type_info = new String[]{'tabSettings',SOAP_M_URI,null,'0','-1','false'};
        private String[] userPermissions_type_info = new String[]{'userPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'applicationVisibilities','classAccesses','customPermissions','description','externalDataSourceAccesses','fieldPermissions','hasActivationRequired','label','license','objectPermissions','pageAccesses','recordTypeVisibilities','tabSettings','userPermissions'};
    }
    public class WorkflowRule extends Metadata {
        public String type = 'WorkflowRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.WorkflowActionReference[] actions;
        public Boolean active;
        public String booleanFilter;
        public MetadataService.FilterItem[] criteriaItems;
        public String description;
        public String formula;
        public String triggerType;
        public MetadataService.WorkflowTimeTrigger[] workflowTimeTriggers;
        private String[] actions_type_info = new String[]{'actions',SOAP_M_URI,null,'0','-1','false'};
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] triggerType_type_info = new String[]{'triggerType',SOAP_M_URI,null,'1','1','false'};
        private String[] workflowTimeTriggers_type_info = new String[]{'workflowTimeTriggers',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actions','active','booleanFilter','criteriaItems','description','formula','triggerType','workflowTimeTriggers'};
    }
    public class ModerationRule extends Metadata {
        public String type = 'ModerationRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String action;
        public Boolean active;
        public String description;
        public MetadataService.ModeratedEntityField[] entitiesAndFields;
        public String masterLabel;
        public String userMessage;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] entitiesAndFields_type_info = new String[]{'entitiesAndFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] userMessage_type_info = new String[]{'userMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'action','active','description','entitiesAndFields','masterLabel','userMessage'};
    }
    public class ValueTranslation {
        public String masterLabel;
        public String translation;
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] translation_type_info = new String[]{'translation',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','translation'};
    }
    public class PermissionSetApexClassAccess {
        public String apexClass;
        public Boolean enabled;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexClass','enabled'};
    }
    public class CustomTab extends Metadata {
        public String type = 'CustomTab';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ActionOverride[] actionOverrides;
        public String auraComponent;
        public Boolean customObject;
        public String description;
        public String flexiPage;
        public Integer frameHeight;
        public Boolean hasSidebar;
        public String icon;
        public String label;
        public Boolean mobileReady;
        public String motif;
        public String page_x;
        public String scontrol;
        public String splashPageLink;
        public String url;
        public String urlEncodingKey;
        private String[] actionOverrides_type_info = new String[]{'actionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] auraComponent_type_info = new String[]{'auraComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] customObject_type_info = new String[]{'customObject',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] flexiPage_type_info = new String[]{'flexiPage',SOAP_M_URI,null,'0','1','false'};
        private String[] frameHeight_type_info = new String[]{'frameHeight',SOAP_M_URI,null,'0','1','false'};
        private String[] hasSidebar_type_info = new String[]{'hasSidebar',SOAP_M_URI,null,'0','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] mobileReady_type_info = new String[]{'mobileReady',SOAP_M_URI,null,'0','1','false'};
        private String[] motif_type_info = new String[]{'motif',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] splashPageLink_type_info = new String[]{'splashPageLink',SOAP_M_URI,null,'0','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
        private String[] urlEncodingKey_type_info = new String[]{'urlEncodingKey',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionOverrides','auraComponent','customObject','description','flexiPage','frameHeight','hasSidebar','icon','label','mobileReady','motif','page_x','scontrol','splashPageLink','url','urlEncodingKey'};
    }
    public class LiveChatAgentConfig extends Metadata {
        public String type = 'LiveChatAgentConfig';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AgentConfigAssignments assignments;
        public String autoGreeting;
        public Integer capacity;
        public Integer criticalWaitTime;
        public String customAgentName;
        public Boolean enableAgentFileTransfer;
        public Boolean enableAgentSneakPeek;
        public Boolean enableAssistanceFlag;
        public Boolean enableAutoAwayOnDecline;
        public Boolean enableAutoAwayOnPushTimeout;
        public Boolean enableChatConferencing;
        public Boolean enableChatMonitoring;
        public Boolean enableChatTransferToAgent;
        public Boolean enableChatTransferToButton;
        public Boolean enableChatTransferToSkill;
        public Boolean enableLogoutSound;
        public Boolean enableNotifications;
        public Boolean enableRequestSound;
        public Boolean enableSneakPeek;
        public Boolean enableVisitorBlocking;
        public Boolean enableWhisperMessage;
        public String label;
        public String supervisorDefaultAgentStatusFilter;
        public String supervisorDefaultButtonFilter;
        public String supervisorDefaultSkillFilter;
        public MetadataService.SupervisorAgentConfigSkills supervisorSkills;
        public MetadataService.AgentConfigButtons transferableButtons;
        public MetadataService.AgentConfigSkills transferableSkills;
        private String[] assignments_type_info = new String[]{'assignments',SOAP_M_URI,null,'0','1','false'};
        private String[] autoGreeting_type_info = new String[]{'autoGreeting',SOAP_M_URI,null,'0','1','false'};
        private String[] capacity_type_info = new String[]{'capacity',SOAP_M_URI,null,'0','1','false'};
        private String[] criticalWaitTime_type_info = new String[]{'criticalWaitTime',SOAP_M_URI,null,'0','1','false'};
        private String[] customAgentName_type_info = new String[]{'customAgentName',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAgentFileTransfer_type_info = new String[]{'enableAgentFileTransfer',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAgentSneakPeek_type_info = new String[]{'enableAgentSneakPeek',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAssistanceFlag_type_info = new String[]{'enableAssistanceFlag',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAutoAwayOnDecline_type_info = new String[]{'enableAutoAwayOnDecline',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAutoAwayOnPushTimeout_type_info = new String[]{'enableAutoAwayOnPushTimeout',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatConferencing_type_info = new String[]{'enableChatConferencing',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatMonitoring_type_info = new String[]{'enableChatMonitoring',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatTransferToAgent_type_info = new String[]{'enableChatTransferToAgent',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatTransferToButton_type_info = new String[]{'enableChatTransferToButton',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChatTransferToSkill_type_info = new String[]{'enableChatTransferToSkill',SOAP_M_URI,null,'0','1','false'};
        private String[] enableLogoutSound_type_info = new String[]{'enableLogoutSound',SOAP_M_URI,null,'0','1','false'};
        private String[] enableNotifications_type_info = new String[]{'enableNotifications',SOAP_M_URI,null,'0','1','false'};
        private String[] enableRequestSound_type_info = new String[]{'enableRequestSound',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSneakPeek_type_info = new String[]{'enableSneakPeek',SOAP_M_URI,null,'0','1','false'};
        private String[] enableVisitorBlocking_type_info = new String[]{'enableVisitorBlocking',SOAP_M_URI,null,'0','1','false'};
        private String[] enableWhisperMessage_type_info = new String[]{'enableWhisperMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] supervisorDefaultAgentStatusFilter_type_info = new String[]{'supervisorDefaultAgentStatusFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] supervisorDefaultButtonFilter_type_info = new String[]{'supervisorDefaultButtonFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] supervisorDefaultSkillFilter_type_info = new String[]{'supervisorDefaultSkillFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] supervisorSkills_type_info = new String[]{'supervisorSkills',SOAP_M_URI,null,'0','1','false'};
        private String[] transferableButtons_type_info = new String[]{'transferableButtons',SOAP_M_URI,null,'0','1','false'};
        private String[] transferableSkills_type_info = new String[]{'transferableSkills',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assignments','autoGreeting','capacity','criticalWaitTime','customAgentName','enableAgentFileTransfer','enableAgentSneakPeek','enableAssistanceFlag','enableAutoAwayOnDecline','enableAutoAwayOnPushTimeout','enableChatConferencing','enableChatMonitoring','enableChatTransferToAgent','enableChatTransferToButton','enableChatTransferToSkill','enableLogoutSound','enableNotifications','enableRequestSound','enableSneakPeek','enableVisitorBlocking','enableWhisperMessage','label','supervisorDefaultAgentStatusFilter','supervisorDefaultButtonFilter','supervisorDefaultSkillFilter','supervisorSkills','transferableButtons','transferableSkills'};
    }
    public class FieldMapping {
        public String SObjectType;
        public String developerName;
        public MetadataService.FieldMappingRow[] fieldMappingRows;
        public String masterLabel;
        private String[] SObjectType_type_info = new String[]{'SObjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] fieldMappingRows_type_info = new String[]{'fieldMappingRows',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'SObjectType','developerName','fieldMappingRows','masterLabel'};
    }
    public class EmailToCaseSettings {
        public Boolean enableE2CAttachmentAsFile;
        public Boolean enableE2CSourceTracking;
        public Boolean enableEmailToCase;
        public Boolean enableHtmlEmail;
        public Boolean enableOnDemandEmailToCase;
        public Boolean enableThreadIDInBody;
        public Boolean enableThreadIDInSubject;
        public Boolean notifyOwnerOnNewCaseEmail;
        public String overEmailLimitAction;
        public Boolean preQuoteSignature;
        public MetadataService.EmailToCaseRoutingAddress[] routingAddresses;
        public String unauthorizedSenderAction;
        private String[] enableE2CAttachmentAsFile_type_info = new String[]{'enableE2CAttachmentAsFile',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableE2CSourceTracking_type_info = new String[]{'enableE2CSourceTracking',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableEmailToCase_type_info = new String[]{'enableEmailToCase',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableHtmlEmail_type_info = new String[]{'enableHtmlEmail',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableOnDemandEmailToCase_type_info = new String[]{'enableOnDemandEmailToCase',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableThreadIDInBody_type_info = new String[]{'enableThreadIDInBody',SOAP_M_URI,'boolean','0','1','false'};
        private String[] enableThreadIDInSubject_type_info = new String[]{'enableThreadIDInSubject',SOAP_M_URI,'boolean','0','1','false'};
        private String[] notifyOwnerOnNewCaseEmail_type_info = new String[]{'notifyOwnerOnNewCaseEmail',SOAP_M_URI,'boolean','0','1','false'};
        private String[] overEmailLimitAction_type_info = new String[]{'overEmailLimitAction',SOAP_M_URI,'EmailToCaseOnFailureActionType','0','1','false'};
        private String[] preQuoteSignature_type_info = new String[]{'preQuoteSignature',SOAP_M_URI,'boolean','0','1','false'};
        private String[] routingAddresses_type_info = new String[]{'routingAddresses',SOAP_M_URI,'EmailToCaseRoutingAddress','0','-1','false'};
        private String[] unauthorizedSenderAction_type_info = new String[]{'unauthorizedSenderAction',SOAP_M_URI,'EmailToCaseOnFailureActionType','0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableE2CAttachmentAsFile','enableE2CSourceTracking','enableEmailToCase','enableHtmlEmail','enableOnDemandEmailToCase','enableThreadIDInBody','enableThreadIDInSubject','notifyOwnerOnNewCaseEmail','overEmailLimitAction','preQuoteSignature','routingAddresses','unauthorizedSenderAction'};
    }
    public class SecuritySettings extends Metadata {
        public String type = 'SecuritySettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.NetworkAccess networkAccess;
        public MetadataService.PasswordPolicies passwordPolicies;
        public MetadataService.SessionSettings sessionSettings;
        private String[] networkAccess_type_info = new String[]{'networkAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] passwordPolicies_type_info = new String[]{'passwordPolicies',SOAP_M_URI,null,'0','1','false'};
        private String[] sessionSettings_type_info = new String[]{'sessionSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'networkAccess','passwordPolicies','sessionSettings'};
    }
    public class ReportChart {
        public String backgroundColor1;
        public String backgroundColor2;
        public String backgroundFadeDir;
        public MetadataService.ChartSummary[] chartSummaries;
        public String chartType;
        public Boolean enableHoverLabels;
        public Boolean expandOthers;
        public String groupingColumn;
        public String legendPosition;
        public String location;
        public String secondaryGroupingColumn;
        public Boolean showAxisLabels;
        public Boolean showPercentage;
        public Boolean showTotal;
        public Boolean showValues;
        public String size;
        public Double summaryAxisManualRangeEnd;
        public Double summaryAxisManualRangeStart;
        public String summaryAxisRange;
        public String textColor;
        public Integer textSize;
        public String title;
        public String titleColor;
        public Integer titleSize;
        private String[] backgroundColor1_type_info = new String[]{'backgroundColor1',SOAP_M_URI,null,'0','1','false'};
        private String[] backgroundColor2_type_info = new String[]{'backgroundColor2',SOAP_M_URI,null,'0','1','false'};
        private String[] backgroundFadeDir_type_info = new String[]{'backgroundFadeDir',SOAP_M_URI,null,'0','1','false'};
        private String[] chartSummaries_type_info = new String[]{'chartSummaries',SOAP_M_URI,null,'0','-1','false'};
        private String[] chartType_type_info = new String[]{'chartType',SOAP_M_URI,null,'1','1','false'};
        private String[] enableHoverLabels_type_info = new String[]{'enableHoverLabels',SOAP_M_URI,null,'0','1','false'};
        private String[] expandOthers_type_info = new String[]{'expandOthers',SOAP_M_URI,null,'0','1','false'};
        private String[] groupingColumn_type_info = new String[]{'groupingColumn',SOAP_M_URI,null,'0','1','false'};
        private String[] legendPosition_type_info = new String[]{'legendPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] location_type_info = new String[]{'location',SOAP_M_URI,null,'0','1','false'};
        private String[] secondaryGroupingColumn_type_info = new String[]{'secondaryGroupingColumn',SOAP_M_URI,null,'0','1','false'};
        private String[] showAxisLabels_type_info = new String[]{'showAxisLabels',SOAP_M_URI,null,'0','1','false'};
        private String[] showPercentage_type_info = new String[]{'showPercentage',SOAP_M_URI,null,'0','1','false'};
        private String[] showTotal_type_info = new String[]{'showTotal',SOAP_M_URI,null,'0','1','false'};
        private String[] showValues_type_info = new String[]{'showValues',SOAP_M_URI,null,'0','1','false'};
        private String[] size_type_info = new String[]{'size',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryAxisManualRangeEnd_type_info = new String[]{'summaryAxisManualRangeEnd',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryAxisManualRangeStart_type_info = new String[]{'summaryAxisManualRangeStart',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryAxisRange_type_info = new String[]{'summaryAxisRange',SOAP_M_URI,null,'0','1','false'};
        private String[] textColor_type_info = new String[]{'textColor',SOAP_M_URI,null,'0','1','false'};
        private String[] textSize_type_info = new String[]{'textSize',SOAP_M_URI,null,'0','1','false'};
        private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'0','1','false'};
        private String[] titleColor_type_info = new String[]{'titleColor',SOAP_M_URI,null,'0','1','false'};
        private String[] titleSize_type_info = new String[]{'titleSize',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'backgroundColor1','backgroundColor2','backgroundFadeDir','chartSummaries','chartType','enableHoverLabels','expandOthers','groupingColumn','legendPosition','location','secondaryGroupingColumn','showAxisLabels','showPercentage','showTotal','showValues','size','summaryAxisManualRangeEnd','summaryAxisManualRangeStart','summaryAxisRange','textColor','textSize','title','titleColor','titleSize'};
    }
    public class AppMenuItem {
        public String name;
        public String type_x;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','type_x'};
    }
    public class TabLimitConfig {
        public String maxNumberOfPrimaryTabs;
        public String maxNumberOfSubTabs;
        private String[] maxNumberOfPrimaryTabs_type_info = new String[]{'maxNumberOfPrimaryTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] maxNumberOfSubTabs_type_info = new String[]{'maxNumberOfSubTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'maxNumberOfPrimaryTabs','maxNumberOfSubTabs'};
    }
    public class ObjectMapping {
        public String inputObject;
        public MetadataService.ObjectMappingField[] mappingFields;
        public String outputObject;
        private String[] inputObject_type_info = new String[]{'inputObject',SOAP_M_URI,null,'1','1','false'};
        private String[] mappingFields_type_info = new String[]{'mappingFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] outputObject_type_info = new String[]{'outputObject',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'inputObject','mappingFields','outputObject'};
    }
    public class ModeratedEntityField {
        public String entityName;
        public String fieldName;
        public String keywordList;
        private String[] entityName_type_info = new String[]{'entityName',SOAP_M_URI,null,'1','1','false'};
        private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'0','1','false'};
        private String[] keywordList_type_info = new String[]{'keywordList',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'entityName','fieldName','keywordList'};
    }
    public class RecordType extends Metadata {
        public String type = 'RecordType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String businessProcess;
        public String compactLayoutAssignment;
        public String description;
        public String label;
        public MetadataService.RecordTypePicklistValue[] picklistValues;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] businessProcess_type_info = new String[]{'businessProcess',SOAP_M_URI,null,'0','1','false'};
        private String[] compactLayoutAssignment_type_info = new String[]{'compactLayoutAssignment',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','businessProcess','compactLayoutAssignment','description','label','picklistValues'};
    }
    public class EventSettings extends Metadata {
		public String type = 'EventSettings';
		public String fullName;
		private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,'string','0','1','false'};
		public Boolean bypassMeteringBlock;
		public Boolean enableApexLimitEvents;
		public Boolean enableDeleteMonitoringData;
		public Boolean enableDynamicStreamingChannel;
		public Boolean enableEventLogGeneration;
		public Boolean enableEventLogWaveIntegration;
		public Boolean enableLoginForensics;
		public Boolean enableStreamingApi;
		public Boolean enableTransactionSecurityPolicies;
		private String[] bypassMeteringBlock_type_info = new String[]{'bypassMeteringBlock',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableApexLimitEvents_type_info = new String[]{'enableApexLimitEvents',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableDeleteMonitoringData_type_info = new String[]{'enableDeleteMonitoringData',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableDynamicStreamingChannel_type_info = new String[]{'enableDynamicStreamingChannel',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableEventLogGeneration_type_info = new String[]{'enableEventLogGeneration',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableEventLogWaveIntegration_type_info = new String[]{'enableEventLogWaveIntegration',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableLoginForensics_type_info = new String[]{'enableLoginForensics',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableStreamingApi_type_info = new String[]{'enableStreamingApi',SOAP_M_URI,'boolean','0','1','false'};
		private String[] enableTransactionSecurityPolicies_type_info = new String[]{'enableTransactionSecurityPolicies',SOAP_M_URI,'boolean','0','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'fullName','bypassMeteringBlock','enableApexLimitEvents','enableDeleteMonitoringData','enableDynamicStreamingChannel','enableEventLogGeneration','enableEventLogWaveIntegration','enableLoginForensics','enableStreamingApi','enableTransactionSecurityPolicies'};
	}
    public class EventSubscription extends Metadata {
        public String type = 'EventSubscription';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public MetadataService.EventParameterMap[] eventParameters;
        public String eventType;
        public String referenceData;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] eventParameters_type_info = new String[]{'eventParameters',SOAP_M_URI,null,'0','-1','false'};
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'1','1','false'};
        private String[] referenceData_type_info = new String[]{'referenceData',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','eventParameters','eventType','referenceData'};
    }
    public class FieldOverride {
        public String field;
        public String formula;
        public String literalValue;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] literalValue_type_info = new String[]{'literalValue',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','formula','literalValue'};
    }
    public class ProfileTabVisibility {
        public String tab;
        public String visibility;
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'tab','visibility'};
    }
    public class ReportCrossFilter {
        public MetadataService.ReportFilterItem[] criteriaItems;
        public String operation;
        public String primaryTableColumn;
        public String relatedTable;
        public String relatedTableJoinColumn;
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] primaryTableColumn_type_info = new String[]{'primaryTableColumn',SOAP_M_URI,null,'1','1','false'};
        private String[] relatedTable_type_info = new String[]{'relatedTable',SOAP_M_URI,null,'1','1','false'};
        private String[] relatedTableJoinColumn_type_info = new String[]{'relatedTableJoinColumn',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'criteriaItems','operation','primaryTableColumn','relatedTable','relatedTableJoinColumn'};
    }
    public class LookupFilter {
        public Boolean active;
        public String booleanFilter;
        public String description;
        public String errorMessage;
        public MetadataService.FilterItem[] filterItems;
        public String infoMessage;
        public Boolean isOptional;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] filterItems_type_info = new String[]{'filterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] infoMessage_type_info = new String[]{'infoMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] isOptional_type_info = new String[]{'isOptional',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','booleanFilter','description','errorMessage','filterItems','infoMessage','isOptional'};
    }
    public class UiPlugin {
        public String description;
        public String extensionPointIdentifier;
        public Boolean isEnabled;
        public String language;
        public String masterLabel;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] extensionPointIdentifier_type_info = new String[]{'extensionPointIdentifier',SOAP_M_URI,null,'1','1','false'};
        private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','extensionPointIdentifier','isEnabled','language','masterLabel'};
    }
    public class AppBrand {
        public String footerColor;
        public String headerColor;
        public String logo;
        public Integer logoVersion;
        private String[] footerColor_type_info = new String[]{'footerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] headerColor_type_info = new String[]{'headerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
        private String[] logoVersion_type_info = new String[]{'logoVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'footerColor','headerColor','logo','logoVersion'};
    }
    public class ReputationLevelDefinitions {
        public MetadataService.ReputationLevel[] level;
        private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'level'};
    }
    public class CustomPageWebLink extends Metadata {
        public String type = 'CustomPageWebLink';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String availability;
        public String description;
        public String displayType;
        public String encodingKey;
        public Boolean hasMenubar;
        public Boolean hasScrollbars;
        public Boolean hasToolbar;
        public Integer height;
        public Boolean isResizable;
        public String linkType;
        public String masterLabel;
        public String openType;
        public String page_x;
        public String position;
        public Boolean protected_x;
        public Boolean requireRowSelection;
        public String scontrol;
        public Boolean showsLocation;
        public Boolean showsStatus;
        public String url;
        public Integer width;
        private String[] availability_type_info = new String[]{'availability',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayType_type_info = new String[]{'displayType',SOAP_M_URI,null,'1','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'0','1','false'};
        private String[] hasMenubar_type_info = new String[]{'hasMenubar',SOAP_M_URI,null,'0','1','false'};
        private String[] hasScrollbars_type_info = new String[]{'hasScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] hasToolbar_type_info = new String[]{'hasToolbar',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isResizable_type_info = new String[]{'isResizable',SOAP_M_URI,null,'0','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] openType_type_info = new String[]{'openType',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] requireRowSelection_type_info = new String[]{'requireRowSelection',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showsLocation_type_info = new String[]{'showsLocation',SOAP_M_URI,null,'0','1','false'};
        private String[] showsStatus_type_info = new String[]{'showsStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availability','description','displayType','encodingKey','hasMenubar','hasScrollbars','hasToolbar','height','isResizable','linkType','masterLabel','openType','page_x','position','protected_x','requireRowSelection','scontrol','showsLocation','showsStatus','url','width'};
    }
    public class ApprovalAction {
        public MetadataService.WorkflowActionReference[] action;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'action'};
    }
    public class SharingSet extends Metadata {
        public String type = 'SharingSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AccessMapping[] accessMappings;
        public String description;
        public String name;
        public String[] profiles;
        private String[] accessMappings_type_info = new String[]{'accessMappings',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] profiles_type_info = new String[]{'profiles',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'accessMappings','description','name','profiles'};
    }
    public class WaveTemplateBundle {
        public String assetIcon;
        public Double assetVersion;
        public String description;
        public String label;
        public String templateType;
        private String[] assetIcon_type_info = new String[]{'assetIcon',SOAP_M_URI,null,'0','1','false'};
        private String[] assetVersion_type_info = new String[]{'assetVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] templateType_type_info = new String[]{'templateType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assetIcon','assetVersion','description','label','templateType'};
    }
    public class LayoutColumn {
        public MetadataService.LayoutItem[] layoutItems;
        public String reserved;
        private String[] layoutItems_type_info = new String[]{'layoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] reserved_type_info = new String[]{'reserved',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutItems','reserved'};
    }
    public class Error {
        public MetadataService.ExtendedErrorDetails[] extendedErrorDetails;
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
    }
    public class Territory2RuleItem {
        public String field;
        public String operation;
        public String value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','operation','value'};
    }
    public class updateMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class AccountSettings extends Metadata {
        public String type = 'AccountSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableAccountOwnerReport;
        public Boolean enableAccountTeams;
        public Boolean showViewHierarchyLink;
        private String[] enableAccountOwnerReport_type_info = new String[]{'enableAccountOwnerReport',SOAP_M_URI,null,'0','1','false'};
        private String[] enableAccountTeams_type_info = new String[]{'enableAccountTeams',SOAP_M_URI,null,'0','1','false'};
        private String[] showViewHierarchyLink_type_info = new String[]{'showViewHierarchyLink',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableAccountOwnerReport','enableAccountTeams','showViewHierarchyLink'};
    }
    public class ContentAssetVersion {
        public String number_x;
        public String pathOnClient;
        public String zipEntry;
        private String[] number_x_type_info = new String[]{'number',SOAP_M_URI,null,'1','1','false'};
        private String[] pathOnClient_type_info = new String[]{'pathOnClient',SOAP_M_URI,null,'1','1','false'};
        private String[] zipEntry_type_info = new String[]{'zipEntry',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'number_x','pathOnClient','zipEntry'};
    }
    public class CancelDeployResult {
        public Boolean done;
        public String id;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id'};
    }
    public class AgentConfigUserAssignments {
        public String[] user_x;
        private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'user_x'};
    }
    public class EventParameterMap {
        public String parameterName;
        public String parameterValue;
        private String[] parameterName_type_info = new String[]{'parameterName',SOAP_M_URI,null,'1','1','false'};
        private String[] parameterValue_type_info = new String[]{'parameterValue',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'parameterName','parameterValue'};
    }
    public class TransactionSecurityAction {
        public Boolean block;
        public Boolean endSession;
        public MetadataService.TransactionSecurityNotification[] notifications;
        public Boolean twoFactorAuthentication;
        private String[] block_type_info = new String[]{'block',SOAP_M_URI,null,'1','1','false'};
        private String[] endSession_type_info = new String[]{'endSession',SOAP_M_URI,null,'1','1','false'};
        private String[] notifications_type_info = new String[]{'notifications',SOAP_M_URI,null,'0','-1','false'};
        private String[] twoFactorAuthentication_type_info = new String[]{'twoFactorAuthentication',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'block','endSession','notifications','twoFactorAuthentication'};
    }
    public class DashboardFilterColumn {
        public String column;
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'column'};
    }
    public class SharingTerritoryRule extends SharingBaseRule {
        public String type = 'SharingTerritoryRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessLevel;
        public MetadataService.AccountSharingRuleSettings accountSettings;
        public String description;
        public String label;
        public MetadataService.SharedTo sharedTo;
        private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] accountSettings_type_info = new String[]{'accountSettings',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessLevel','accountSettings','description','label','sharedTo'};
    }
    public class WorkflowFlowActionParameter {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class ScontrolTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class PlatformActionListItem {
        public String actionName;
        public String actionType;
        public Integer sortOrder;
        public String subtype;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,null,'1','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
        private String[] subtype_type_info = new String[]{'subtype',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','actionType','sortOrder','subtype'};
    }
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    public class ApprovalEntryCriteria {
        public String booleanFilter;
        public MetadataService.FilterItem[] criteriaItems;
        public String formula;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'booleanFilter','criteriaItems','formula'};
    }
    public class CallCenterItem {
        public String label;
        public String name;
        public String value;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name','value'};
    }
    public class Document extends MetadataWithContent {
        public String type = 'Document';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public Boolean internalUseOnly;
        public String keywords;
        public String name;
        public Boolean public_x;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] internalUseOnly_type_info = new String[]{'internalUseOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] keywords_type_info = new String[]{'keywords',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] public_x_type_info = new String[]{'public',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'description','internalUseOnly','keywords','name','public_x'};
    }
    public class upsertMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class ProfileExternalDataSourceAccess {
        public Boolean enabled;
        public String externalDataSource;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
    }
    public class ValueTypeField {
        public MetadataService.ValueTypeField[] fields;
        public String[] foreignKeyDomain;
        public Boolean isForeignKey;
        public Boolean isNameField;
        public Integer minOccurs;
        public String name;
        public MetadataService.PicklistEntry[] picklistValues;
        public String soapType;
        public Boolean valueRequired;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] foreignKeyDomain_type_info = new String[]{'foreignKeyDomain',SOAP_M_URI,null,'0','-1','false'};
        private String[] isForeignKey_type_info = new String[]{'isForeignKey',SOAP_M_URI,null,'1','1','false'};
        private String[] isNameField_type_info = new String[]{'isNameField',SOAP_M_URI,null,'1','1','false'};
        private String[] minOccurs_type_info = new String[]{'minOccurs',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] soapType_type_info = new String[]{'soapType',SOAP_M_URI,null,'1','1','false'};
        private String[] valueRequired_type_info = new String[]{'valueRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','foreignKeyDomain','isForeignKey','isNameField','minOccurs','name','picklistValues','soapType','valueRequired'};
    }
    public virtual class GlobalPicklistValue extends Metadata {
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'1','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'color','default_x','description','isActive','fullName'};
    }
    public class EmailFolder extends Folder {
        public String type = 'EmailFolder';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessType;
        public MetadataService.FolderShare[] folderShares;
        public String name;
        public String publicFolderAccess;
        public MetadataService.SharedTo sharedTo;
        private String[] accessType_type_info = new String[]{'accessType',SOAP_M_URI,null,'0','1','false'};
        private String[] folderShares_type_info = new String[]{'folderShares',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] publicFolderAccess_type_info = new String[]{'publicFolderAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessType','folderShares','name','publicFolderAccess','sharedTo'};
    }
    public class renameMetadata_element {
        public String type_x;
        public String oldFullName;
        public String newFullName;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] oldFullName_type_info = new String[]{'oldFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] newFullName_type_info = new String[]{'newFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','oldFullName','newFullName'};
    }
    public class DelegateGroup extends Metadata {
        public String type = 'DelegateGroup';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] customObjects;
        public String[] groups;
        public String label;
        public Boolean loginAccess;
        public String[] permissionSets;
        public String[] profiles;
        public String[] roles;
        private String[] customObjects_type_info = new String[]{'customObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] groups_type_info = new String[]{'groups',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] loginAccess_type_info = new String[]{'loginAccess',SOAP_M_URI,null,'1','1','false'};
        private String[] permissionSets_type_info = new String[]{'permissionSets',SOAP_M_URI,null,'0','-1','false'};
        private String[] profiles_type_info = new String[]{'profiles',SOAP_M_URI,null,'0','-1','false'};
        private String[] roles_type_info = new String[]{'roles',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customObjects','groups','label','loginAccess','permissionSets','profiles','roles'};
    }
    public class PicklistValue extends GlobalPicklistValue {
        public String type = 'PicklistValue';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'0','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        public Boolean allowEmail;
        public Boolean closed;
        public String[] controllingFieldValues;
        public Boolean converted;
        public Boolean cssExposed;
        public String forecastCategory;
        public Boolean highPriority;
        public Integer probability;
        public String reverseRole;
        public Boolean reviewed;
        public Boolean won;
        private String[] allowEmail_type_info = new String[]{'allowEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] closed_type_info = new String[]{'closed',SOAP_M_URI,null,'0','1','false'};
        private String[] controllingFieldValues_type_info = new String[]{'controllingFieldValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] converted_type_info = new String[]{'converted',SOAP_M_URI,null,'0','1','false'};
        private String[] cssExposed_type_info = new String[]{'cssExposed',SOAP_M_URI,null,'0','1','false'};
        private String[] forecastCategory_type_info = new String[]{'forecastCategory',SOAP_M_URI,null,'0','1','false'};
        private String[] highPriority_type_info = new String[]{'highPriority',SOAP_M_URI,null,'0','1','false'};
        private String[] probability_type_info = new String[]{'probability',SOAP_M_URI,null,'0','1','false'};
        private String[] reverseRole_type_info = new String[]{'reverseRole',SOAP_M_URI,null,'0','1','false'};
        private String[] reviewed_type_info = new String[]{'reviewed',SOAP_M_URI,null,'0','1','false'};
        private String[] won_type_info = new String[]{'won',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','color','default_x','description','isActive', 'allowEmail','closed','controllingFieldValues','converted','cssExposed','forecastCategory','highPriority','probability','reverseRole','reviewed','won'};
    }
    public class SkillProfileAssignments {
        public String[] profile;
        private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'profile'};
    }
    public class EscalationAction {
        public String assignedTo;
        public String assignedToTemplate;
        public String assignedToType;
        public Integer minutesToEscalation;
        public Boolean notifyCaseOwner;
        public String[] notifyEmail;
        public String notifyTo;
        public String notifyToTemplate;
        private String[] assignedTo_type_info = new String[]{'assignedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] assignedToTemplate_type_info = new String[]{'assignedToTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] assignedToType_type_info = new String[]{'assignedToType',SOAP_M_URI,null,'0','1','false'};
        private String[] minutesToEscalation_type_info = new String[]{'minutesToEscalation',SOAP_M_URI,null,'0','1','false'};
        private String[] notifyCaseOwner_type_info = new String[]{'notifyCaseOwner',SOAP_M_URI,null,'0','1','false'};
        private String[] notifyEmail_type_info = new String[]{'notifyEmail',SOAP_M_URI,null,'0','-1','false'};
        private String[] notifyTo_type_info = new String[]{'notifyTo',SOAP_M_URI,null,'0','1','false'};
        private String[] notifyToTemplate_type_info = new String[]{'notifyToTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assignedTo','assignedToTemplate','assignedToType','minutesToEscalation','notifyCaseOwner','notifyEmail','notifyTo','notifyToTemplate'};
    }
    public class Workflow extends Metadata {
        public String type = 'Workflow';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.WorkflowAlert[] alerts;
        public MetadataService.WorkflowFieldUpdate[] fieldUpdates;
        public MetadataService.WorkflowFlowAction[] flowActions;
        public MetadataService.WorkflowKnowledgePublish[] knowledgePublishes;
        public MetadataService.WorkflowOutboundMessage[] outboundMessages;
        public MetadataService.WorkflowRule[] rules;
        public MetadataService.WorkflowSend[] send;
        public MetadataService.WorkflowTask[] tasks;
        private String[] alerts_type_info = new String[]{'alerts',SOAP_M_URI,null,'0','-1','false'};
        private String[] fieldUpdates_type_info = new String[]{'fieldUpdates',SOAP_M_URI,null,'0','-1','false'};
        private String[] flowActions_type_info = new String[]{'flowActions',SOAP_M_URI,null,'0','-1','false'};
        private String[] knowledgePublishes_type_info = new String[]{'knowledgePublishes',SOAP_M_URI,null,'0','-1','false'};
        private String[] outboundMessages_type_info = new String[]{'outboundMessages',SOAP_M_URI,null,'0','-1','false'};
        private String[] rules_type_info = new String[]{'rules',SOAP_M_URI,null,'0','-1','false'};
        private String[] send_type_info = new String[]{'send',SOAP_M_URI,null,'0','-1','false'};
        private String[] tasks_type_info = new String[]{'tasks',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'alerts','fieldUpdates','flowActions','knowledgePublishes','outboundMessages','rules','send','tasks'};
    }
    public class WorkflowKnowledgePublish extends WorkflowAction {
        public String type = 'WorkflowKnowledgePublish';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String action;
        public String description;
        public String label;
        public String language;
        public Boolean protected_x;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'action','description','label','language','protected_x'};
    }
    public class CustomFieldTranslation {
        public MetadataService.ObjectNameCaseValue[] caseValues;
        public String gender;
        public String help;
        public String label;
        public MetadataService.LookupFilterTranslation lookupFilter;
        public String name;
        public MetadataService.PicklistValueTranslation[] picklistValues;
        public String relationshipLabel;
        public String startsWith;
        private String[] caseValues_type_info = new String[]{'caseValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] gender_type_info = new String[]{'gender',SOAP_M_URI,null,'0','1','false'};
        private String[] help_type_info = new String[]{'help',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] lookupFilter_type_info = new String[]{'lookupFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] relationshipLabel_type_info = new String[]{'relationshipLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] startsWith_type_info = new String[]{'startsWith',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'caseValues','gender','help','label','lookupFilter','name','picklistValues','relationshipLabel','startsWith'};
    }
    public class VisualizationPlugin extends Metadata {
        public String type = 'VisualizationPlugin';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String developerName;
        public String icon;
        public String masterLabel;
        public MetadataService.VisualizationResource[] visualizationResources;
        public MetadataService.VisualizationType[] visualizationTypes;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] visualizationResources_type_info = new String[]{'visualizationResources',SOAP_M_URI,null,'0','-1','false'};
        private String[] visualizationTypes_type_info = new String[]{'visualizationTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','developerName','icon','masterLabel','visualizationResources','visualizationTypes'};
    }
    public class DataPipeline {
        public Double apiVersion;
        public String label;
        public String scriptType;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] scriptType_type_info = new String[]{'scriptType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiVersion','label','scriptType'};
    }
    public class QueueSobject {
        public String sobjectType;
        private String[] sobjectType_type_info = new String[]{'sobjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sobjectType'};
    }
    public class ApexClass extends MetadataWithContent {
        public String type = 'ApexClass';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public MetadataService.PackageVersion[] packageVersions;
        public String status;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'apiVersion','packageVersions','status'};
    }
    public class FieldMappingRow {
        public String SObjectType;
        public MetadataService.FieldMappingField[] fieldMappingFields;
        public String fieldName;
        public String mappingOperation;
        private String[] SObjectType_type_info = new String[]{'SObjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] fieldMappingFields_type_info = new String[]{'fieldMappingFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'1','1','false'};
        private String[] mappingOperation_type_info = new String[]{'mappingOperation',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'SObjectType','fieldMappingFields','fieldName','mappingOperation'};
    }
    public class EntitlementTemplate extends Metadata {
        public String type = 'EntitlementTemplate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String businessHours;
        public Integer casesPerEntitlement;
        public String entitlementProcess;
        public Boolean isPerIncident;
        public Integer term;
        public String type_x;
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','1','false'};
        private String[] casesPerEntitlement_type_info = new String[]{'casesPerEntitlement',SOAP_M_URI,null,'0','1','false'};
        private String[] entitlementProcess_type_info = new String[]{'entitlementProcess',SOAP_M_URI,null,'0','1','false'};
        private String[] isPerIncident_type_info = new String[]{'isPerIncident',SOAP_M_URI,null,'0','1','false'};
        private String[] term_type_info = new String[]{'term',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'businessHours','casesPerEntitlement','entitlementProcess','isPerIncident','term','type_x'};
    }
    public class Group_x extends Metadata {
        public String type = 'Group_x';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean doesIncludeBosses;
        public String name;
        private String[] doesIncludeBosses_type_info = new String[]{'doesIncludeBosses',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'doesIncludeBosses','name'};
    }
    public class KnowledgeLanguageSettings {
        public MetadataService.KnowledgeLanguage[] language;
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'language'};
    }
    public class KnowledgeCaseField {
        public String name;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name'};
    }
    public virtual class Metadata {
        public String fullName;
    }
    public class DebuggingHeader_element {
        public MetadataService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories',SOAP_M_URI,null,'0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class ApprovalPageField {
        public String[] field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    public class PermissionSetApexPageAccess {
        public String apexPage;
        public Boolean enabled;
        private String[] apexPage_type_info = new String[]{'apexPage',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexPage','enabled'};
    }
    public class CustomExperience {
        public Boolean allowInternalUserLogin;
        public MetadataService.CustomExperienceBranding branding;
        public String changePasswordEmailTemplate;
        public String emailFooterLogo;
        public String emailFooterText;
        public String emailSenderAddress;
        public String emailSenderName;
        public Boolean enableErrorPageOverridesForVisualforce;
        public String forgotPasswordEmailTemplate;
        public String picassoSite;
        public String sObjectType;
        public Boolean sendWelcomeEmail;
        public String site;
        public Boolean siteAsContainerEnabled;
        public MetadataService.CustomExperienceTabSet tabs;
        public String urlPathPrefix;
        public String welcomeEmailTemplate;
        private String[] allowInternalUserLogin_type_info = new String[]{'allowInternalUserLogin',SOAP_M_URI,null,'1','1','false'};
        private String[] branding_type_info = new String[]{'branding',SOAP_M_URI,null,'0','1','false'};
        private String[] changePasswordEmailTemplate_type_info = new String[]{'changePasswordEmailTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] emailFooterLogo_type_info = new String[]{'emailFooterLogo',SOAP_M_URI,null,'0','1','false'};
        private String[] emailFooterText_type_info = new String[]{'emailFooterText',SOAP_M_URI,null,'0','1','false'};
        private String[] emailSenderAddress_type_info = new String[]{'emailSenderAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] emailSenderName_type_info = new String[]{'emailSenderName',SOAP_M_URI,null,'1','1','false'};
        private String[] enableErrorPageOverridesForVisualforce_type_info = new String[]{'enableErrorPageOverridesForVisualforce',SOAP_M_URI,null,'1','1','false'};
        private String[] forgotPasswordEmailTemplate_type_info = new String[]{'forgotPasswordEmailTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] picassoSite_type_info = new String[]{'picassoSite',SOAP_M_URI,null,'0','1','false'};
        private String[] sObjectType_type_info = new String[]{'sObjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] sendWelcomeEmail_type_info = new String[]{'sendWelcomeEmail',SOAP_M_URI,null,'1','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'1','1','false'};
        private String[] siteAsContainerEnabled_type_info = new String[]{'siteAsContainerEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] tabs_type_info = new String[]{'tabs',SOAP_M_URI,null,'0','1','false'};
        private String[] urlPathPrefix_type_info = new String[]{'urlPathPrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] welcomeEmailTemplate_type_info = new String[]{'welcomeEmailTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowInternalUserLogin','branding','changePasswordEmailTemplate','emailFooterLogo','emailFooterText','emailSenderAddress','emailSenderName','enableErrorPageOverridesForVisualforce','forgotPasswordEmailTemplate','picassoSite','sObjectType','sendWelcomeEmail','site','siteAsContainerEnabled','tabs','urlPathPrefix','welcomeEmailTemplate'};
    }
    public class ExternalServiceRegistration {
        public String description;
        public String label;
        public String namedCredential;
        public String schema;
        public String schemaType;
        public String schemaUrl;
        public String status;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] namedCredential_type_info = new String[]{'namedCredential',SOAP_M_URI,null,'0','1','false'};
        private String[] schema_type_info = new String[]{'schema',SOAP_M_URI,null,'1','1','false'};
        private String[] schemaType_type_info = new String[]{'schemaType',SOAP_M_URI,null,'1','1','false'};
        private String[] schemaUrl_type_info = new String[]{'schemaUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','label','namedCredential','schema','schemaType','schemaUrl','status'};
    }
    public class ConnectedApp extends Metadata {
        public String type = 'ConnectedApp';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ConnectedAppAttribute[] attributes;
        public MetadataService.ConnectedAppCanvasConfig canvasConfig;
        public String contactEmail;
        public String contactPhone;
        public String description;
        public String iconUrl;
        public String infoUrl;
        public MetadataService.ConnectedAppIpRange[] ipRanges;
        public String label;
        public String logoUrl;
        public MetadataService.ConnectedAppMobileDetailConfig mobileAppConfig;
        public String mobileStartUrl;
        public MetadataService.ConnectedAppOauthConfig oauthConfig;
        public String plugin;
        public MetadataService.ConnectedAppSamlConfig samlConfig;
        public String startUrl;
        private String[] attributes_type_info = new String[]{'attributes',SOAP_M_URI,null,'0','-1','false'};
        private String[] canvasConfig_type_info = new String[]{'canvasConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] contactEmail_type_info = new String[]{'contactEmail',SOAP_M_URI,null,'1','1','false'};
        private String[] contactPhone_type_info = new String[]{'contactPhone',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] iconUrl_type_info = new String[]{'iconUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] infoUrl_type_info = new String[]{'infoUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] ipRanges_type_info = new String[]{'ipRanges',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] logoUrl_type_info = new String[]{'logoUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] mobileAppConfig_type_info = new String[]{'mobileAppConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] mobileStartUrl_type_info = new String[]{'mobileStartUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] oauthConfig_type_info = new String[]{'oauthConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] plugin_type_info = new String[]{'plugin',SOAP_M_URI,null,'0','1','false'};
        private String[] samlConfig_type_info = new String[]{'samlConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] startUrl_type_info = new String[]{'startUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'attributes','canvasConfig','contactEmail','contactPhone','description','iconUrl','infoUrl','ipRanges','label','logoUrl','mobileAppConfig','mobileStartUrl','oauthConfig','plugin','samlConfig','startUrl'};
    }
    public class describeMetadata_element {
        public Double asOfVersion;
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asOfVersion'};
    }
    public class LayoutItem {
        public MetadataService.AnalyticsCloudComponentLayoutItem analyticsCloudComponent;
        public String behavior;
        public String canvas;
        public String component;
        public String customLink;
        public Boolean emptySpace;
        public String field;
        public Integer height;
        public String page_x;
        public MetadataService.ReportChartComponentLayoutItem reportChartComponent;
        public String scontrol;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] analyticsCloudComponent_type_info = new String[]{'analyticsCloudComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] behavior_type_info = new String[]{'behavior',SOAP_M_URI,null,'0','1','false'};
        private String[] canvas_type_info = new String[]{'canvas',SOAP_M_URI,null,'0','1','false'};
        private String[] component_type_info = new String[]{'component',SOAP_M_URI,null,'0','1','false'};
        private String[] customLink_type_info = new String[]{'customLink',SOAP_M_URI,null,'0','1','false'};
        private String[] emptySpace_type_info = new String[]{'emptySpace',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] reportChartComponent_type_info = new String[]{'reportChartComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showLabel_type_info = new String[]{'showLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] showScrollbars_type_info = new String[]{'showScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'analyticsCloudComponent','behavior','canvas','component','customLink','emptySpace','field','height','page_x','reportChartComponent','scontrol','showLabel','showScrollbars','width'};
    }
    public class Portal extends Metadata {
        public String type = 'Portal';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String admin;
        public String defaultLanguage;
        public String description;
        public String emailSenderAddress;
        public String emailSenderName;
        public Boolean enableSelfCloseCase;
        public String footerDocument;
        public String forgotPassTemplate;
        public String headerDocument;
        public Boolean isSelfRegistrationActivated;
        public String loginHeaderDocument;
        public String logoDocument;
        public String logoutUrl;
        public String newCommentTemplate;
        public String newPassTemplate;
        public String newUserTemplate;
        public String ownerNotifyTemplate;
        public String selfRegNewUserUrl;
        public String selfRegUserDefaultProfile;
        public String selfRegUserDefaultRole;
        public String selfRegUserTemplate;
        public Boolean showActionConfirmation;
        public String stylesheetDocument;
        public String type_x;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] admin_type_info = new String[]{'admin',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultLanguage_type_info = new String[]{'defaultLanguage',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] emailSenderAddress_type_info = new String[]{'emailSenderAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] emailSenderName_type_info = new String[]{'emailSenderName',SOAP_M_URI,null,'1','1','false'};
        private String[] enableSelfCloseCase_type_info = new String[]{'enableSelfCloseCase',SOAP_M_URI,null,'0','1','false'};
        private String[] footerDocument_type_info = new String[]{'footerDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] forgotPassTemplate_type_info = new String[]{'forgotPassTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] headerDocument_type_info = new String[]{'headerDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] isSelfRegistrationActivated_type_info = new String[]{'isSelfRegistrationActivated',SOAP_M_URI,null,'0','1','false'};
        private String[] loginHeaderDocument_type_info = new String[]{'loginHeaderDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] logoDocument_type_info = new String[]{'logoDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] logoutUrl_type_info = new String[]{'logoutUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] newCommentTemplate_type_info = new String[]{'newCommentTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] newPassTemplate_type_info = new String[]{'newPassTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] newUserTemplate_type_info = new String[]{'newUserTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] ownerNotifyTemplate_type_info = new String[]{'ownerNotifyTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegNewUserUrl_type_info = new String[]{'selfRegNewUserUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegUserDefaultProfile_type_info = new String[]{'selfRegUserDefaultProfile',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegUserDefaultRole_type_info = new String[]{'selfRegUserDefaultRole',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegUserTemplate_type_info = new String[]{'selfRegUserTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] showActionConfirmation_type_info = new String[]{'showActionConfirmation',SOAP_M_URI,null,'0','1','false'};
        private String[] stylesheetDocument_type_info = new String[]{'stylesheetDocument',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','admin','defaultLanguage','description','emailSenderAddress','emailSenderName','enableSelfCloseCase','footerDocument','forgotPassTemplate','headerDocument','isSelfRegistrationActivated','loginHeaderDocument','logoDocument','logoutUrl','newCommentTemplate','newPassTemplate','newUserTemplate','ownerNotifyTemplate','selfRegNewUserUrl','selfRegUserDefaultProfile','selfRegUserDefaultRole','selfRegUserTemplate','showActionConfirmation','stylesheetDocument','type_x'};
    }
    public class ContentAssetVersions {
        public MetadataService.ContentAssetVersion[] version;
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'version'};
    }
    public class RunTestSuccess {
        public String id;
        public String methodName;
        public String name;
        public String namespace;
        public Boolean seeAllData;
        public Double time_x;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','methodName','name','namespace','seeAllData','time_x'};
    }
    public class PermissionSetExternalDataSourceAccess {
        public Boolean enabled;
        public String externalDataSource;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
    }
    public class CustomDataType extends Metadata {
        public String type = 'CustomDataType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CustomDataTypeComponent[] customDataTypeComponents;
        public String description;
        public String displayFormula;
        public Boolean editComponentsOnSeparateLines;
        public String label;
        public Boolean rightAligned;
        public Boolean supportComponentsInReports;
        private String[] customDataTypeComponents_type_info = new String[]{'customDataTypeComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayFormula_type_info = new String[]{'displayFormula',SOAP_M_URI,null,'0','1','false'};
        private String[] editComponentsOnSeparateLines_type_info = new String[]{'editComponentsOnSeparateLines',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] rightAligned_type_info = new String[]{'rightAligned',SOAP_M_URI,null,'0','1','false'};
        private String[] supportComponentsInReports_type_info = new String[]{'supportComponentsInReports',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customDataTypeComponents','description','displayFormula','editComponentsOnSeparateLines','label','rightAligned','supportComponentsInReports'};
    }
    public class EventDelivery extends Metadata {
        public String type = 'EventDelivery';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.EventParameterMap[] eventParameters;
        public String eventSubscription;
        public String referenceData;
        public String type_x;
        private String[] eventParameters_type_info = new String[]{'eventParameters',SOAP_M_URI,null,'0','-1','false'};
        private String[] eventSubscription_type_info = new String[]{'eventSubscription',SOAP_M_URI,null,'1','1','false'};
        private String[] referenceData_type_info = new String[]{'referenceData',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'eventParameters','eventSubscription','referenceData','type_x'};
    }
    public class ListMetadataQuery {
        public String folder;
        public String type_x;
        private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'folder','type_x'};
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    public class SharedTo {
        public String allCustomerPortalUsers;
        public String allInternalUsers;
        public String allPartnerUsers;
        public String[] group_x;
        public String[] groups;
        public String[] managerSubordinates;
        public String[] managers;
        public String[] portalRole;
        public String[] portalRoleAndSubordinates;
        public String[] queue;
        public String[] role;
        public String[] roleAndSubordinates;
        public String[] roleAndSubordinatesInternal;
        public String[] roles;
        public String[] rolesAndSubordinates;
        public String[] territories;
        public String[] territoriesAndSubordinates;
        public String[] territory;
        public String[] territoryAndSubordinates;
        private String[] allCustomerPortalUsers_type_info = new String[]{'allCustomerPortalUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] allInternalUsers_type_info = new String[]{'allInternalUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] allPartnerUsers_type_info = new String[]{'allPartnerUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] group_x_type_info = new String[]{'group',SOAP_M_URI,null,'0','-1','false'};
        private String[] groups_type_info = new String[]{'groups',SOAP_M_URI,null,'0','-1','false'};
        private String[] managerSubordinates_type_info = new String[]{'managerSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] managers_type_info = new String[]{'managers',SOAP_M_URI,null,'0','-1','false'};
        private String[] portalRole_type_info = new String[]{'portalRole',SOAP_M_URI,null,'0','-1','false'};
        private String[] portalRoleAndSubordinates_type_info = new String[]{'portalRoleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] queue_type_info = new String[]{'queue',SOAP_M_URI,null,'0','-1','false'};
        private String[] role_type_info = new String[]{'role',SOAP_M_URI,null,'0','-1','false'};
        private String[] roleAndSubordinates_type_info = new String[]{'roleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] roleAndSubordinatesInternal_type_info = new String[]{'roleAndSubordinatesInternal',SOAP_M_URI,null,'0','-1','false'};
        private String[] roles_type_info = new String[]{'roles',SOAP_M_URI,null,'0','-1','false'};
        private String[] rolesAndSubordinates_type_info = new String[]{'rolesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] territories_type_info = new String[]{'territories',SOAP_M_URI,null,'0','-1','false'};
        private String[] territoriesAndSubordinates_type_info = new String[]{'territoriesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] territory_type_info = new String[]{'territory',SOAP_M_URI,null,'0','-1','false'};
        private String[] territoryAndSubordinates_type_info = new String[]{'territoryAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allCustomerPortalUsers','allInternalUsers','allPartnerUsers','group_x','groups','managerSubordinates','managers','portalRole','portalRoleAndSubordinates','queue','role','roleAndSubordinates','roleAndSubordinatesInternal','roles','rolesAndSubordinates','territories','territoriesAndSubordinates','territory','territoryAndSubordinates'};
    }
    public class PlatformCachePartitionType {
        public Integer allocatedCapacity;
        public Integer allocatedPurchasedCapacity;
        public Integer allocatedTrialCapacity;
        public String cacheType;
        private String[] allocatedCapacity_type_info = new String[]{'allocatedCapacity',SOAP_M_URI,null,'1','1','false'};
        private String[] allocatedPurchasedCapacity_type_info = new String[]{'allocatedPurchasedCapacity',SOAP_M_URI,null,'1','1','false'};
        private String[] allocatedTrialCapacity_type_info = new String[]{'allocatedTrialCapacity',SOAP_M_URI,null,'1','1','false'};
        private String[] cacheType_type_info = new String[]{'cacheType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allocatedCapacity','allocatedPurchasedCapacity','allocatedTrialCapacity','cacheType'};
    }
    public class ReputationPointsRule {
        public String eventType;
        public Integer points;
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'1','1','false'};
        private String[] points_type_info = new String[]{'points',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'eventType','points'};
    }
    public class QuickActionLayoutColumn {
        public MetadataService.QuickActionLayoutItem[] quickActionLayoutItems;
        private String[] quickActionLayoutItems_type_info = new String[]{'quickActionLayoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionLayoutItems'};
    }
    public class ReputationBranding {
        public String smallImage;
        private String[] smallImage_type_info = new String[]{'smallImage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'smallImage'};
    }
    public class ReputationLevel {
        public MetadataService.ReputationBranding branding;
        public String label;
        public Double lowerThreshold;
        private String[] branding_type_info = new String[]{'branding',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] lowerThreshold_type_info = new String[]{'lowerThreshold',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'branding','label','lowerThreshold'};
    }
    public class ContentAssetRelationships {
        public MetadataService.ContentAssetLink organization;
        private String[] organization_type_info = new String[]{'organization',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'organization'};
    }
    public class ProfileLayoutAssignment {
        public String layout;
        public String recordType;
        private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layout','recordType'};
    }
    public class QuickActionTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class ReportTypeTranslation {
        public String description;
        public String label;
        public String name;
        public MetadataService.ReportTypeSectionTranslation[] sections;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] sections_type_info = new String[]{'sections',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','label','name','sections'};
    }
    public class ActionLinkGroupTemplate extends Metadata {
        public String type = 'ActionLinkGroupTemplate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ActionLinkTemplate[] actionLinkTemplates;
        public String category;
        public String executionsAllowed;
        public Integer hoursUntilExpiration;
        public Boolean isPublished;
        public String name;
        private String[] actionLinkTemplates_type_info = new String[]{'actionLinkTemplates',SOAP_M_URI,null,'0','-1','false'};
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] executionsAllowed_type_info = new String[]{'executionsAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] hoursUntilExpiration_type_info = new String[]{'hoursUntilExpiration',SOAP_M_URI,null,'0','1','false'};
        private String[] isPublished_type_info = new String[]{'isPublished',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionLinkTemplates','category','executionsAllowed','hoursUntilExpiration','isPublished','name'};
    }
    public class ReportDataCategoryFilter {
        public String dataCategory;
        public String dataCategoryGroup;
        public String operator;
        private String[] dataCategory_type_info = new String[]{'dataCategory',SOAP_M_URI,null,'1','1','false'};
        private String[] dataCategoryGroup_type_info = new String[]{'dataCategoryGroup',SOAP_M_URI,null,'1','1','false'};
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dataCategory','dataCategoryGroup','operator'};
    }
    public class ReportBucketFieldSourceValue {
        public String from_x;
        public String sourceValue;
        public String to;
        private String[] from_x_type_info = new String[]{'from',SOAP_M_URI,null,'0','1','false'};
        private String[] sourceValue_type_info = new String[]{'sourceValue',SOAP_M_URI,null,'0','1','false'};
        private String[] to_type_info = new String[]{'to',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'from_x','sourceValue','to'};
    }
    public class ValidationRuleTranslation {
        public String errorMessage;
        public String name;
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errorMessage','name'};
    }
    public class DocumentFolder extends Folder {
        public String type = 'DocumentFolder';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessType;
        public MetadataService.FolderShare[] folderShares;
        public String name;
        public String publicFolderAccess;
        public MetadataService.SharedTo sharedTo;
        private String[] accessType_type_info = new String[]{'accessType',SOAP_M_URI,null,'0','1','false'};
        private String[] folderShares_type_info = new String[]{'folderShares',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] publicFolderAccess_type_info = new String[]{'publicFolderAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessType','folderShares','name','publicFolderAccess','sharedTo'};
    }
    public class createMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class Dashboard extends Metadata {
        public String type = 'Dashboard';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String backgroundEndColor;
        public String backgroundFadeDirection;
        public String backgroundStartColor;
        public MetadataService.DashboardFilter[] dashboardFilters;
        public MetadataService.DashboardGridLayout dashboardGridLayout;
        public String dashboardResultRefreshedDate;
        public String dashboardResultRunningUser;
        public String dashboardType;
        public String description;
        public String folderName;
        public Boolean isGridLayout;
        public MetadataService.DashboardComponentSection leftSection;
        public MetadataService.DashboardComponentSection middleSection;
        public MetadataService.DashboardComponentSection rightSection;
        public String runningUser;
        public String textColor;
        public String title;
        public String titleColor;
        public Integer titleSize;
        private String[] backgroundEndColor_type_info = new String[]{'backgroundEndColor',SOAP_M_URI,null,'1','1','false'};
        private String[] backgroundFadeDirection_type_info = new String[]{'backgroundFadeDirection',SOAP_M_URI,null,'1','1','false'};
        private String[] backgroundStartColor_type_info = new String[]{'backgroundStartColor',SOAP_M_URI,null,'1','1','false'};
        private String[] dashboardFilters_type_info = new String[]{'dashboardFilters',SOAP_M_URI,null,'0','-1','false'};
        private String[] dashboardGridLayout_type_info = new String[]{'dashboardGridLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] dashboardResultRefreshedDate_type_info = new String[]{'dashboardResultRefreshedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] dashboardResultRunningUser_type_info = new String[]{'dashboardResultRunningUser',SOAP_M_URI,null,'0','1','false'};
        private String[] dashboardType_type_info = new String[]{'dashboardType',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] folderName_type_info = new String[]{'folderName',SOAP_M_URI,null,'0','1','false'};
        private String[] isGridLayout_type_info = new String[]{'isGridLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] leftSection_type_info = new String[]{'leftSection',SOAP_M_URI,null,'0','1','false'};
        private String[] middleSection_type_info = new String[]{'middleSection',SOAP_M_URI,null,'0','1','false'};
        private String[] rightSection_type_info = new String[]{'rightSection',SOAP_M_URI,null,'0','1','false'};
        private String[] runningUser_type_info = new String[]{'runningUser',SOAP_M_URI,null,'0','1','false'};
        private String[] textColor_type_info = new String[]{'textColor',SOAP_M_URI,null,'1','1','false'};
        private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'1','1','false'};
        private String[] titleColor_type_info = new String[]{'titleColor',SOAP_M_URI,null,'1','1','false'};
        private String[] titleSize_type_info = new String[]{'titleSize',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'backgroundEndColor','backgroundFadeDirection','backgroundStartColor','dashboardFilters','dashboardGridLayout','dashboardResultRefreshedDate','dashboardResultRunningUser','dashboardType','description','folderName','isGridLayout','leftSection','middleSection','rightSection','runningUser','textColor','title','titleColor','titleSize'};
    }
    public class PersonListSettings {
        public Boolean enablePersonList;
        private String[] enablePersonList_type_info = new String[]{'enablePersonList',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enablePersonList'};
    }
    public class KeyboardShortcuts {
        public MetadataService.CustomShortcut[] customShortcut;
        public MetadataService.DefaultShortcut[] defaultShortcut;
        private String[] customShortcut_type_info = new String[]{'customShortcut',SOAP_M_URI,null,'0','-1','false'};
        private String[] defaultShortcut_type_info = new String[]{'defaultShortcut',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customShortcut','defaultShortcut'};
    }
    public class ManagedTopic {
        public String managedTopicType;
        public String name;
        public String parentName;
        public Integer position;
        public String topicDescription;
        private String[] managedTopicType_type_info = new String[]{'managedTopicType',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] parentName_type_info = new String[]{'parentName',SOAP_M_URI,null,'1','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
        private String[] topicDescription_type_info = new String[]{'topicDescription',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'managedTopicType','name','parentName','position','topicDescription'};
    }
    public class SkillAssignments {
        public MetadataService.SkillProfileAssignments profiles;
        public MetadataService.SkillUserAssignments users;
        private String[] profiles_type_info = new String[]{'profiles',SOAP_M_URI,null,'0','1','false'};
        private String[] users_type_info = new String[]{'users',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'profiles','users'};
    }
    public class WorkflowEmailRecipient {
        public String field;
        public String recipient;
        public String type_x;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] recipient_type_info = new String[]{'recipient',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','recipient','type_x'};
    }
    public class CodeCoverageResult {
        public MetadataService.CodeLocation[] dmlInfo;
        public String id;
        public MetadataService.CodeLocation[] locationsNotCovered;
        public MetadataService.CodeLocation[] methodInfo;
        public String name;
        public String namespace;
        public Integer numLocations;
        public Integer numLocationsNotCovered;
        public MetadataService.CodeLocation[] soqlInfo;
        public MetadataService.CodeLocation[] soslInfo;
        public String type_x;
        private String[] dmlInfo_type_info = new String[]{'dmlInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] locationsNotCovered_type_info = new String[]{'locationsNotCovered',SOAP_M_URI,null,'0','-1','false'};
        private String[] methodInfo_type_info = new String[]{'methodInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] numLocations_type_info = new String[]{'numLocations',SOAP_M_URI,null,'1','1','false'};
        private String[] numLocationsNotCovered_type_info = new String[]{'numLocationsNotCovered',SOAP_M_URI,null,'1','1','false'};
        private String[] soqlInfo_type_info = new String[]{'soqlInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] soslInfo_type_info = new String[]{'soslInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dmlInfo','id','locationsNotCovered','methodInfo','name','namespace','numLocations','numLocationsNotCovered','soqlInfo','soslInfo','type_x'};
    }
    public class RecordTypePicklistValue {
        public String picklist;
        public MetadataService.PicklistValue[] values;
        private String[] picklist_type_info = new String[]{'picklist',SOAP_M_URI,null,'1','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'picklist','values'};
    }
    public class Container {
        public Integer height;
        public Boolean isContainerAutoSizeEnabled;
        public String region;
        public MetadataService.SidebarComponent[] sidebarComponents;
        public String style;
        public String unit;
        public Integer width;
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isContainerAutoSizeEnabled_type_info = new String[]{'isContainerAutoSizeEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] region_type_info = new String[]{'region',SOAP_M_URI,null,'1','1','false'};
        private String[] sidebarComponents_type_info = new String[]{'sidebarComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style',SOAP_M_URI,null,'1','1','false'};
        private String[] unit_type_info = new String[]{'unit',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'height','isContainerAutoSizeEnabled','region','sidebarComponents','style','unit','width'};
    }
    public class FeedLayout {
        public Boolean autocollapsePublisher;
        public Boolean compactFeed;
        public String feedFilterPosition;
        public MetadataService.FeedLayoutFilter[] feedFilters;
        public Boolean fullWidthFeed;
        public Boolean hideSidebar;
        public Boolean highlightExternalFeedItems;
        public MetadataService.FeedLayoutComponent[] leftComponents;
        public MetadataService.FeedLayoutComponent[] rightComponents;
        public Boolean useInlineFiltersInConsole;
        private String[] autocollapsePublisher_type_info = new String[]{'autocollapsePublisher',SOAP_M_URI,null,'0','1','false'};
        private String[] compactFeed_type_info = new String[]{'compactFeed',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilterPosition_type_info = new String[]{'feedFilterPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilters_type_info = new String[]{'feedFilters',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullWidthFeed_type_info = new String[]{'fullWidthFeed',SOAP_M_URI,null,'0','1','false'};
        private String[] hideSidebar_type_info = new String[]{'hideSidebar',SOAP_M_URI,null,'0','1','false'};
        private String[] highlightExternalFeedItems_type_info = new String[]{'highlightExternalFeedItems',SOAP_M_URI,null,'0','1','false'};
        private String[] leftComponents_type_info = new String[]{'leftComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] rightComponents_type_info = new String[]{'rightComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] useInlineFiltersInConsole_type_info = new String[]{'useInlineFiltersInConsole',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'autocollapsePublisher','compactFeed','feedFilterPosition','feedFilters','fullWidthFeed','hideSidebar','highlightExternalFeedItems','leftComponents','rightComponents','useInlineFiltersInConsole'};
    }
    public class NetworkAccess {
        public MetadataService.IpRange[] ipRanges;
        private String[] ipRanges_type_info = new String[]{'ipRanges',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'ipRanges'};
    }
    public class IdeasSettings extends Metadata {
        public String type = 'IdeasSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableChatterProfile;
        public Boolean enableIdeaThemes;
        public Boolean enableIdeas;
        public Boolean enableIdeasReputation;
        public Double halfLife;
        public String ideasProfilePage;
        private String[] enableChatterProfile_type_info = new String[]{'enableChatterProfile',SOAP_M_URI,null,'0','1','false'};
        private String[] enableIdeaThemes_type_info = new String[]{'enableIdeaThemes',SOAP_M_URI,null,'0','1','false'};
        private String[] enableIdeas_type_info = new String[]{'enableIdeas',SOAP_M_URI,null,'0','1','false'};
        private String[] enableIdeasReputation_type_info = new String[]{'enableIdeasReputation',SOAP_M_URI,null,'0','1','false'};
        private String[] halfLife_type_info = new String[]{'halfLife',SOAP_M_URI,null,'0','1','false'};
        private String[] ideasProfilePage_type_info = new String[]{'ideasProfilePage',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableChatterProfile','enableIdeaThemes','enableIdeas','enableIdeasReputation','halfLife','ideasProfilePage'};
    }
    public class ProfileActionOverride {
        public String actionName;
        public String content;
        public String formFactor;
        public String pageOrSobjectType;
        public String recordType;
        public String type_x;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'1','1','false'};
        private String[] pageOrSobjectType_type_info = new String[]{'pageOrSobjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','content','formFactor','pageOrSobjectType','recordType','type_x'};
    }
    public class CustomDataTypeTranslation {
        public MetadataService.CustomDataTypeComponentTranslation[] components;
        public String customDataTypeName;
        public String description;
        public String label;
        private String[] components_type_info = new String[]{'components',SOAP_M_URI,null,'0','-1','false'};
        private String[] customDataTypeName_type_info = new String[]{'customDataTypeName',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'components','customDataTypeName','description','label'};
    }
    public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    public class PostTemplate extends Metadata {
        public String type = 'PostTemplate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean default_x;
        public String description;
        public String[] fields;
        public String label;
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'default_x','description','fields','label'};
    }
    public class ValueSet {
        public String controllingField;
        public Boolean restricted;
        public MetadataService.ValueSetValuesDefinition valueSetDefinition;
        public String valueSetName;
        public MetadataService.ValueSettings[] valueSettings;
        private String[] controllingField_type_info = new String[]{'controllingField',SOAP_M_URI,null,'0','1','false'};
        private String[] restricted_type_info = new String[]{'restricted',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSetDefinition_type_info = new String[]{'valueSetDefinition',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSetName_type_info = new String[]{'valueSetName',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSettings_type_info = new String[]{'valueSettings',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingField','restricted','valueSetDefinition','valueSetName','valueSettings'};
    }
    public class QuickActionList {
        public MetadataService.QuickActionListItem[] quickActionListItems;
        private String[] quickActionListItems_type_info = new String[]{'quickActionListItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionListItems'};
    }
    public class FlexiPageRegion {
        public String appendable;
        public MetadataService.ComponentInstance[] componentInstances;
        public String mode;
        public String name;
        public String prependable;
        public String replaceable;
        public String type_x;
        private String[] appendable_type_info = new String[]{'appendable',SOAP_M_URI,null,'0','1','false'};
        private String[] componentInstances_type_info = new String[]{'componentInstances',SOAP_M_URI,null,'0','-1','false'};
        private String[] mode_type_info = new String[]{'mode',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] prependable_type_info = new String[]{'prependable',SOAP_M_URI,null,'0','1','false'};
        private String[] replaceable_type_info = new String[]{'replaceable',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'appendable','componentInstances','mode','name','prependable','replaceable','type_x'};
    }
    public class PrimaryTabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    public class Territory {
        public String accountAccessLevel;
        public String parentTerritory;
        private String[] accountAccessLevel_type_info = new String[]{'accountAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] parentTerritory_type_info = new String[]{'parentTerritory',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'accountAccessLevel','parentTerritory'};
    }
    public class updateMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class FolderShare {
        public String accessLevel;
        public String sharedTo;
        public String sharedToType;
        private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'1','1','false'};
        private String[] sharedToType_type_info = new String[]{'sharedToType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'accessLevel','sharedTo','sharedToType'};
    }
    public class QuickActionListItem {
        public String quickActionName;
        private String[] quickActionName_type_info = new String[]{'quickActionName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionName'};
    }
    public class SiteDotCom extends MetadataWithContent {
        public String type = 'SiteDotCom';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String label;
        public String siteType;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] siteType_type_info = new String[]{'siteType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'label','siteType'};
    }
    public class MobileSettings extends Metadata {
        public String type = 'MobileSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ChatterMobileSettings chatterMobile;
        public MetadataService.DashboardMobileSettings dashboardMobile;
        public MetadataService.SFDCMobileSettings salesforceMobile;
        public MetadataService.TouchMobileSettings touchMobile;
        private String[] chatterMobile_type_info = new String[]{'chatterMobile',SOAP_M_URI,null,'0','1','false'};
        private String[] dashboardMobile_type_info = new String[]{'dashboardMobile',SOAP_M_URI,null,'0','1','false'};
        private String[] salesforceMobile_type_info = new String[]{'salesforceMobile',SOAP_M_URI,null,'0','1','false'};
        private String[] touchMobile_type_info = new String[]{'touchMobile',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'chatterMobile','dashboardMobile','salesforceMobile','touchMobile'};
    }
    public class ObjectMappingField {
        public String inputField;
        public String outputField;
        private String[] inputField_type_info = new String[]{'inputField',SOAP_M_URI,null,'1','1','false'};
        private String[] outputField_type_info = new String[]{'outputField',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'inputField','outputField'};
    }
    public class DescribeValueTypeResult {
        public Boolean apiCreatable;
        public Boolean apiDeletable;
        public Boolean apiReadable;
        public Boolean apiUpdatable;
        public MetadataService.ValueTypeField parentField;
        public MetadataService.ValueTypeField[] valueTypeFields;
        private String[] apiCreatable_type_info = new String[]{'apiCreatable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiDeletable_type_info = new String[]{'apiDeletable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiReadable_type_info = new String[]{'apiReadable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiUpdatable_type_info = new String[]{'apiUpdatable',SOAP_M_URI,null,'1','1','false'};
        private String[] parentField_type_info = new String[]{'parentField',SOAP_M_URI,null,'0','1','false'};
        private String[] valueTypeFields_type_info = new String[]{'valueTypeFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiCreatable','apiDeletable','apiReadable','apiUpdatable','parentField','valueTypeFields'};
    }
    public class EntitlementSettings extends Metadata {
        public String type = 'EntitlementSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean assetLookupLimitedToActiveEntitlementsOnAccount;
        public Boolean assetLookupLimitedToActiveEntitlementsOnContact;
        public Boolean assetLookupLimitedToSameAccount;
        public Boolean assetLookupLimitedToSameContact;
        public Boolean enableEntitlementVersioning;
        public Boolean enableEntitlements;
        public Boolean entitlementLookupLimitedToActiveStatus;
        public Boolean entitlementLookupLimitedToSameAccount;
        public Boolean entitlementLookupLimitedToSameAsset;
        public Boolean entitlementLookupLimitedToSameContact;
        private String[] assetLookupLimitedToActiveEntitlementsOnAccount_type_info = new String[]{'assetLookupLimitedToActiveEntitlementsOnAccount',SOAP_M_URI,null,'0','1','false'};
        private String[] assetLookupLimitedToActiveEntitlementsOnContact_type_info = new String[]{'assetLookupLimitedToActiveEntitlementsOnContact',SOAP_M_URI,null,'0','1','false'};
        private String[] assetLookupLimitedToSameAccount_type_info = new String[]{'assetLookupLimitedToSameAccount',SOAP_M_URI,null,'0','1','false'};
        private String[] assetLookupLimitedToSameContact_type_info = new String[]{'assetLookupLimitedToSameContact',SOAP_M_URI,null,'0','1','false'};
        private String[] enableEntitlementVersioning_type_info = new String[]{'enableEntitlementVersioning',SOAP_M_URI,null,'1','1','false'};
        private String[] enableEntitlements_type_info = new String[]{'enableEntitlements',SOAP_M_URI,null,'1','1','false'};
        private String[] entitlementLookupLimitedToActiveStatus_type_info = new String[]{'entitlementLookupLimitedToActiveStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] entitlementLookupLimitedToSameAccount_type_info = new String[]{'entitlementLookupLimitedToSameAccount',SOAP_M_URI,null,'0','1','false'};
        private String[] entitlementLookupLimitedToSameAsset_type_info = new String[]{'entitlementLookupLimitedToSameAsset',SOAP_M_URI,null,'0','1','false'};
        private String[] entitlementLookupLimitedToSameContact_type_info = new String[]{'entitlementLookupLimitedToSameContact',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assetLookupLimitedToActiveEntitlementsOnAccount','assetLookupLimitedToActiveEntitlementsOnContact','assetLookupLimitedToSameAccount','assetLookupLimitedToSameContact','enableEntitlementVersioning','enableEntitlements','entitlementLookupLimitedToActiveStatus','entitlementLookupLimitedToSameAccount','entitlementLookupLimitedToSameAsset','entitlementLookupLimitedToSameContact'};
    }
    public class Territory2RuleAssociation {
        public Boolean inherited;
        public String ruleName;
        private String[] inherited_type_info = new String[]{'inherited',SOAP_M_URI,null,'1','1','false'};
        private String[] ruleName_type_info = new String[]{'ruleName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'inherited','ruleName'};
    }
    public class PermissionSetCustomPermissions {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    public class CustomApplicationComponent extends Metadata {
        public String type = 'CustomApplicationComponent';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String buttonIconUrl;
        public String buttonStyle;
        public String buttonText;
        public Integer buttonWidth;
        public Integer height;
        public Boolean isHeightFixed;
        public Boolean isHidden;
        public Boolean isWidthFixed;
        public String visualforcePage;
        public Integer width;
        private String[] buttonIconUrl_type_info = new String[]{'buttonIconUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonStyle_type_info = new String[]{'buttonStyle',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonText_type_info = new String[]{'buttonText',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonWidth_type_info = new String[]{'buttonWidth',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isHeightFixed_type_info = new String[]{'isHeightFixed',SOAP_M_URI,null,'1','1','false'};
        private String[] isHidden_type_info = new String[]{'isHidden',SOAP_M_URI,null,'1','1','false'};
        private String[] isWidthFixed_type_info = new String[]{'isWidthFixed',SOAP_M_URI,null,'1','1','false'};
        private String[] visualforcePage_type_info = new String[]{'visualforcePage',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'buttonIconUrl','buttonStyle','buttonText','buttonWidth','height','isHeightFixed','isHidden','isWidthFixed','visualforcePage','width'};
    }
    public class ComponentInstanceProperty {
        public String name;
        public String type_x;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','type_x','value'};
    }
    public class ChatterMobileSettings {
        public Boolean enablePushNotifications;
        private String[] enablePushNotifications_type_info = new String[]{'enablePushNotifications',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enablePushNotifications'};
    }
    public class WorkflowAlert extends WorkflowAction {
        public String type = 'WorkflowAlert';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] ccEmails;
        public String description;
        public Boolean protected_x;
        public MetadataService.WorkflowEmailRecipient[] recipients;
        public String senderAddress;
        public String senderType;
        public String template;
        private String[] ccEmails_type_info = new String[]{'ccEmails',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] recipients_type_info = new String[]{'recipients',SOAP_M_URI,null,'0','-1','false'};
        private String[] senderAddress_type_info = new String[]{'senderAddress',SOAP_M_URI,null,'0','1','false'};
        private String[] senderType_type_info = new String[]{'senderType',SOAP_M_URI,null,'0','1','false'};
        private String[] template_type_info = new String[]{'template',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'ccEmails','description','protected_x','recipients','senderAddress','senderType','template'};
    }
    public class KnowledgeCaseFieldsSettings {
        public MetadataService.KnowledgeCaseField[] field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    public class EmailTemplate extends MetadataWithContent {
        public String type = 'EmailTemplate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public String[] attachedDocuments;
        public MetadataService.Attachment[] attachments;
        public Boolean available;
        public String description;
        public String encodingKey;
        public String letterhead;
        public String name;
        public MetadataService.PackageVersion[] packageVersions;
        public String style;
        public String subject;
        public String textOnly;
        public String type_x;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'0','1','false'};
        private String[] attachedDocuments_type_info = new String[]{'attachedDocuments',SOAP_M_URI,null,'0','-1','false'};
        private String[] attachments_type_info = new String[]{'attachments',SOAP_M_URI,null,'0','-1','false'};
        private String[] available_type_info = new String[]{'available',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'1','1','false'};
        private String[] letterhead_type_info = new String[]{'letterhead',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style',SOAP_M_URI,null,'1','1','false'};
        private String[] subject_type_info = new String[]{'subject',SOAP_M_URI,null,'0','1','false'};
        private String[] textOnly_type_info = new String[]{'textOnly',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'apiVersion','attachedDocuments','attachments','available','description','encodingKey','letterhead','name','packageVersions','style','subject','textOnly','type_x'};
    }
    public class PushNotification {
        public String[] fieldNames;
        public String objectName;
        private String[] fieldNames_type_info = new String[]{'fieldNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] objectName_type_info = new String[]{'objectName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fieldNames','objectName'};
    }
    public class TransactionSecurityPolicy {
        public MetadataService.TransactionSecurityAction action;
        public Boolean active;
        public String apexClass;
        public String eventType;
        public String executionUser;
        public String resourceName;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'1','1','false'};
        private String[] executionUser_type_info = new String[]{'executionUser',SOAP_M_URI,null,'1','1','false'};
        private String[] resourceName_type_info = new String[]{'resourceName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'action','active','apexClass','eventType','executionUser','resourceName'};
    }
    public class OpportunityListFieldsSelectedSettings {
        public String[] field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    public class Certificate extends MetadataWithContent {
        public String type = 'Certificate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Boolean caSigned;
        public Boolean encryptedWithPlatformEncryption;
        public DateTime expirationDate;
        public Integer keySize;
        public String masterLabel;
        public Boolean privateKeyExportable;
        private String[] caSigned_type_info = new String[]{'caSigned',SOAP_M_URI,null,'1','1','false'};
        private String[] encryptedWithPlatformEncryption_type_info = new String[]{'encryptedWithPlatformEncryption',SOAP_M_URI,null,'0','1','true'};
        private String[] expirationDate_type_info = new String[]{'expirationDate',SOAP_M_URI,null,'0','1','true'};
        private String[] keySize_type_info = new String[]{'keySize',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] privateKeyExportable_type_info = new String[]{'privateKeyExportable',SOAP_M_URI,null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'caSigned','encryptedWithPlatformEncryption','expirationDate','keySize','masterLabel','privateKeyExportable'};
    }
    public class AccessMapping {
        public String accessLevel;
        public String object_x;
        public String objectField;
        public String userField;
        private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] objectField_type_info = new String[]{'objectField',SOAP_M_URI,null,'1','1','false'};
        private String[] userField_type_info = new String[]{'userField',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'accessLevel','object_x','objectField','userField'};
    }
    public class AnalyticSnapshotMapping {
        public String aggregateType;
        public String sourceField;
        public String sourceType;
        public String targetField;
        private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
        private String[] sourceField_type_info = new String[]{'sourceField',SOAP_M_URI,null,'1','1','false'};
        private String[] sourceType_type_info = new String[]{'sourceType',SOAP_M_URI,null,'1','1','false'};
        private String[] targetField_type_info = new String[]{'targetField',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregateType','sourceField','sourceType','targetField'};
    }
    public class DefaultShortcut {
        public String action;
        public Boolean active;
        public String keyCommand;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] keyCommand_type_info = new String[]{'keyCommand',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'action','active','keyCommand'};
    }
    public class WorkspaceMapping {
        public String fieldName;
        public String tab;
        private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'0','1','false'};
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fieldName','tab'};
    }
    public class WorkflowSend extends WorkflowAction {
        public String type = 'WorkflowSend';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String action;
        public String description;
        public String label;
        public String language;
        public Boolean protected_x;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'action','description','label','language','protected_x'};
    }
    public class deleteMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    public class ForecastRangeSettings {
        public Integer beginning;
        public Integer displaying;
        public String periodType;
        private String[] beginning_type_info = new String[]{'beginning',SOAP_M_URI,null,'1','1','false'};
        private String[] displaying_type_info = new String[]{'displaying',SOAP_M_URI,null,'1','1','false'};
        private String[] periodType_type_info = new String[]{'periodType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'beginning','displaying','periodType'};
    }
    public class ListViewFilter {
        public String field;
        public String operation;
        public String value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','operation','value'};
    }
    public class DashboardTableColumn {
        public String aggregateType;
        public Boolean calculatePercent;
        public String column;
        public Integer decimalPlaces;
        public Boolean showTotal;
        public String sortBy;
        private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
        private String[] calculatePercent_type_info = new String[]{'calculatePercent',SOAP_M_URI,null,'0','1','false'};
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] decimalPlaces_type_info = new String[]{'decimalPlaces',SOAP_M_URI,null,'0','1','false'};
        private String[] showTotal_type_info = new String[]{'showTotal',SOAP_M_URI,null,'0','1','false'};
        private String[] sortBy_type_info = new String[]{'sortBy',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregateType','calculatePercent','column','decimalPlaces','showTotal','sortBy'};
    }
    public class Territory2 extends Metadata {
        public String type = 'Territory2';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accountAccessLevel;
        public String caseAccessLevel;
        public String contactAccessLevel;
        public MetadataService.FieldValue[] customFields;
        public String description;
        public String name;
        public String opportunityAccessLevel;
        public String parentTerritory;
        public MetadataService.Territory2RuleAssociation[] ruleAssociations;
        public String territory2Type;
        private String[] accountAccessLevel_type_info = new String[]{'accountAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] caseAccessLevel_type_info = new String[]{'caseAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] contactAccessLevel_type_info = new String[]{'contactAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] customFields_type_info = new String[]{'customFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] opportunityAccessLevel_type_info = new String[]{'opportunityAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] parentTerritory_type_info = new String[]{'parentTerritory',SOAP_M_URI,null,'0','1','false'};
        private String[] ruleAssociations_type_info = new String[]{'ruleAssociations',SOAP_M_URI,null,'0','-1','false'};
        private String[] territory2Type_type_info = new String[]{'territory2Type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'accountAccessLevel','caseAccessLevel','contactAccessLevel','customFields','description','name','opportunityAccessLevel','parentTerritory','ruleAssociations','territory2Type'};
    }
    public class ListPlacement {
        public Integer height;
        public String location;
        public String units;
        public Integer width;
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] location_type_info = new String[]{'location',SOAP_M_URI,null,'1','1','false'};
        private String[] units_type_info = new String[]{'units',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'height','location','units','width'};
    }
    public class PicklistEntry {
        public Boolean active;
        public Boolean defaultValue;
        public String label;
        public String validFor;
        public String value;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] validFor_type_info = new String[]{'validFor',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','defaultValue','label','validFor','value'};
    }
    public class ReportBucketField {
        public String bucketType;
        public String developerName;
        public String masterLabel;
        public String nullTreatment;
        public String otherBucketLabel;
        public String sourceColumnName;
        public Boolean useOther;
        public MetadataService.ReportBucketFieldValue[] values;
        private String[] bucketType_type_info = new String[]{'bucketType',SOAP_M_URI,null,'1','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] nullTreatment_type_info = new String[]{'nullTreatment',SOAP_M_URI,null,'0','1','false'};
        private String[] otherBucketLabel_type_info = new String[]{'otherBucketLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] sourceColumnName_type_info = new String[]{'sourceColumnName',SOAP_M_URI,null,'1','1','false'};
        private String[] useOther_type_info = new String[]{'useOther',SOAP_M_URI,null,'0','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'bucketType','developerName','masterLabel','nullTreatment','otherBucketLabel','sourceColumnName','useOther','values'};
    }
    public class KnowledgeCommunitiesSettings {
        public String[] community;
        private String[] community_type_info = new String[]{'community',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'community'};
    }
    public class OpportunitySettings extends Metadata {
        public String type = 'OpportunitySettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean autoActivateNewReminders;
        public Boolean enableFindSimilarOpportunities;
        public Boolean enableOpportunityTeam;
        public Boolean enableUpdateReminders;
        public MetadataService.FindSimilarOppFilter findSimilarOppFilter;
        public Boolean promptToAddProducts;
        private String[] autoActivateNewReminders_type_info = new String[]{'autoActivateNewReminders',SOAP_M_URI,null,'0','1','false'};
        private String[] enableFindSimilarOpportunities_type_info = new String[]{'enableFindSimilarOpportunities',SOAP_M_URI,null,'0','1','false'};
        private String[] enableOpportunityTeam_type_info = new String[]{'enableOpportunityTeam',SOAP_M_URI,null,'0','1','false'};
        private String[] enableUpdateReminders_type_info = new String[]{'enableUpdateReminders',SOAP_M_URI,null,'0','1','false'};
        private String[] findSimilarOppFilter_type_info = new String[]{'findSimilarOppFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] promptToAddProducts_type_info = new String[]{'promptToAddProducts',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'autoActivateNewReminders','enableFindSimilarOpportunities','enableOpportunityTeam','enableUpdateReminders','findSimilarOppFilter','promptToAddProducts'};
    }
    public class CodeCoverageWarning {
        public String id;
        public String message;
        public String name;
        public String namespace;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','true'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','message','name','namespace'};
    }
    public class CustomLabelTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class KnowledgeAnswerSettings {
        public String assignTo;
        public String defaultArticleType;
        public Boolean enableArticleCreation;
        private String[] assignTo_type_info = new String[]{'assignTo',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultArticleType_type_info = new String[]{'defaultArticleType',SOAP_M_URI,null,'0','1','false'};
        private String[] enableArticleCreation_type_info = new String[]{'enableArticleCreation',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assignTo','defaultArticleType','enableArticleCreation'};
    }
    public class Letterhead extends Metadata {
        public String type = 'Letterhead';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean available;
        public String backgroundColor;
        public String bodyColor;
        public MetadataService.LetterheadLine bottomLine;
        public String description;
        public MetadataService.LetterheadHeaderFooter footer;
        public MetadataService.LetterheadHeaderFooter header;
        public MetadataService.LetterheadLine middleLine;
        public String name;
        public MetadataService.LetterheadLine topLine;
        private String[] available_type_info = new String[]{'available',SOAP_M_URI,null,'1','1','false'};
        private String[] backgroundColor_type_info = new String[]{'backgroundColor',SOAP_M_URI,null,'1','1','false'};
        private String[] bodyColor_type_info = new String[]{'bodyColor',SOAP_M_URI,null,'1','1','false'};
        private String[] bottomLine_type_info = new String[]{'bottomLine',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] footer_type_info = new String[]{'footer',SOAP_M_URI,null,'1','1','false'};
        private String[] header_type_info = new String[]{'header',SOAP_M_URI,null,'1','1','false'};
        private String[] middleLine_type_info = new String[]{'middleLine',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] topLine_type_info = new String[]{'topLine',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'available','backgroundColor','bodyColor','bottomLine','description','footer','header','middleLine','name','topLine'};
    }
    public class AddressSettings extends Metadata {
        public String type = 'AddressSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CountriesAndStates countriesAndStates;
        private String[] countriesAndStates_type_info = new String[]{'countriesAndStates',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'countriesAndStates'};
    }
    public class PathAssistantSettings {
        public Boolean pathAssistantEnabled;
        private String[] pathAssistantEnabled_type_info = new String[]{'pathAssistantEnabled',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pathAssistantEnabled'};
    }
    public class DuplicateRuleMatchRule {
        public String matchRuleSObjectType;
        public String matchingRule;
        public MetadataService.ObjectMapping objectMapping;
        private String[] matchRuleSObjectType_type_info = new String[]{'matchRuleSObjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] matchingRule_type_info = new String[]{'matchingRule',SOAP_M_URI,null,'1','1','false'};
        private String[] objectMapping_type_info = new String[]{'objectMapping',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'matchRuleSObjectType','matchingRule','objectMapping'};
    }
    public class EventTypeParameter {
        public String defaultValue;
        public String description;
        public String label;
        public Integer maxOccurs;
        public Integer minOccurs;
        public String name;
        public String sObjectType;
        public String type_x;
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] maxOccurs_type_info = new String[]{'maxOccurs',SOAP_M_URI,null,'0','1','false'};
        private String[] minOccurs_type_info = new String[]{'minOccurs',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] sObjectType_type_info = new String[]{'sObjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'defaultValue','description','label','maxOccurs','minOccurs','name','sObjectType','type_x'};
    }
    public class QuoteSettings extends Metadata {
        public String type = 'QuoteSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableQuote;
        private String[] enableQuote_type_info = new String[]{'enableQuote',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableQuote'};
    }
    public class CustomExperienceBranding {
        public String loginFooterText;
        public String loginLogo;
        public String pageFooter;
        public String pageHeader;
        public String primaryColor;
        public String primaryComplementColor;
        public String quaternaryColor;
        public String quaternaryComplementColor;
        public String secondaryColor;
        public String tertiaryColor;
        public String tertiaryComplementColor;
        public String zeronaryColor;
        public String zeronaryComplementColor;
        private String[] loginFooterText_type_info = new String[]{'loginFooterText',SOAP_M_URI,null,'0','1','false'};
        private String[] loginLogo_type_info = new String[]{'loginLogo',SOAP_M_URI,null,'0','1','false'};
        private String[] pageFooter_type_info = new String[]{'pageFooter',SOAP_M_URI,null,'0','1','false'};
        private String[] pageHeader_type_info = new String[]{'pageHeader',SOAP_M_URI,null,'0','1','false'};
        private String[] primaryColor_type_info = new String[]{'primaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] primaryComplementColor_type_info = new String[]{'primaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] quaternaryColor_type_info = new String[]{'quaternaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] quaternaryComplementColor_type_info = new String[]{'quaternaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] secondaryColor_type_info = new String[]{'secondaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] tertiaryColor_type_info = new String[]{'tertiaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] tertiaryComplementColor_type_info = new String[]{'tertiaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] zeronaryColor_type_info = new String[]{'zeronaryColor',SOAP_M_URI,null,'1','1','false'};
        private String[] zeronaryComplementColor_type_info = new String[]{'zeronaryComplementColor',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'loginFooterText','loginLogo','pageFooter','pageHeader','primaryColor','primaryComplementColor','quaternaryColor','quaternaryComplementColor','secondaryColor','tertiaryColor','tertiaryComplementColor','zeronaryColor','zeronaryComplementColor'};
    }
    public class BusinessHoursEntry extends Metadata {
        public String type = 'BusinessHoursEntry';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public Boolean default_x;
        public DateTime fridayEndTime;
        public DateTime fridayStartTime;
        public DateTime mondayEndTime;
        public DateTime mondayStartTime;
        public String name;
        public DateTime saturdayEndTime;
        public DateTime saturdayStartTime;
        public DateTime sundayEndTime;
        public DateTime sundayStartTime;
        public DateTime thursdayEndTime;
        public DateTime thursdayStartTime;
        public String timeZoneId;
        public DateTime tuesdayEndTime;
        public DateTime tuesdayStartTime;
        public DateTime wednesdayEndTime;
        public DateTime wednesdayStartTime;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] fridayEndTime_type_info = new String[]{'fridayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] fridayStartTime_type_info = new String[]{'fridayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayEndTime_type_info = new String[]{'mondayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] mondayStartTime_type_info = new String[]{'mondayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayEndTime_type_info = new String[]{'saturdayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] saturdayStartTime_type_info = new String[]{'saturdayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayEndTime_type_info = new String[]{'sundayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] sundayStartTime_type_info = new String[]{'sundayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayEndTime_type_info = new String[]{'thursdayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] thursdayStartTime_type_info = new String[]{'thursdayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] timeZoneId_type_info = new String[]{'timeZoneId',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayEndTime_type_info = new String[]{'tuesdayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] tuesdayStartTime_type_info = new String[]{'tuesdayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayEndTime_type_info = new String[]{'wednesdayEndTime',SOAP_M_URI,null,'0','1','false'};
        private String[] wednesdayStartTime_type_info = new String[]{'wednesdayStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','default_x','fridayEndTime','fridayStartTime','mondayEndTime','mondayStartTime','name','saturdayEndTime','saturdayStartTime','sundayEndTime','sundayStartTime','thursdayEndTime','thursdayStartTime','timeZoneId','tuesdayEndTime','tuesdayStartTime','wednesdayEndTime','wednesdayStartTime'};
    }
    public class NetworkMemberGroup {
        public String[] permissionSet;
        public String[] profile;
        private String[] permissionSet_type_info = new String[]{'permissionSet',SOAP_M_URI,null,'0','-1','false'};
        private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'permissionSet','profile'};
    }
    public class ApexPage extends MetadataWithContent {
        public String type = 'ApexPage';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public Double apiVersion;
        public Boolean availableInTouch;
        public Boolean confirmationTokenRequired;
        public String description;
        public String label;
        public MetadataService.PackageVersion[] packageVersions;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] availableInTouch_type_info = new String[]{'availableInTouch',SOAP_M_URI,null,'0','1','false'};
        private String[] confirmationTokenRequired_type_info = new String[]{'confirmationTokenRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] packageVersions_type_info = new String[]{'packageVersions',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'apiVersion','availableInTouch','confirmationTokenRequired','description','label','packageVersions'};
    }
    public class CustomSite extends Metadata {
        public String type = 'CustomSite';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public Boolean allowHomePage;
        public Boolean allowStandardAnswersPages;
        public Boolean allowStandardIdeasPages;
        public Boolean allowStandardLookups;
        public Boolean allowStandardSearch;
        public String analyticsTrackingCode;
        public String authorizationRequiredPage;
        public String bandwidthExceededPage;
        public String changePasswordPage;
        public String chatterAnswersForgotPasswordConfirmPage;
        public String chatterAnswersForgotPasswordPage;
        public String chatterAnswersHelpPage;
        public String chatterAnswersLoginPage;
        public String chatterAnswersRegistrationPage;
        public String clickjackProtectionLevel;
        public MetadataService.SiteWebAddress[] customWebAddresses;
        public String description;
        public String favoriteIcon;
        public String fileNotFoundPage;
        public String forgotPasswordPage;
        public String genericErrorPage;
        public String guestProfile;
        public String inMaintenancePage;
        public String inactiveIndexPage;
        public String indexPage;
        public String masterLabel;
        public String myProfilePage;
        public String portal;
        public Boolean requireHttps;
        public Boolean requireInsecurePortalAccess;
        public String robotsTxtPage;
        public String rootComponent;
        public String selfRegPage;
        public String serverIsDown;
        public String siteAdmin;
        public MetadataService.SiteRedirectMapping[] siteRedirectMappings;
        public String siteTemplate;
        public String siteType;
        public String subdomain;
        public String urlPathPrefix;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] allowHomePage_type_info = new String[]{'allowHomePage',SOAP_M_URI,null,'1','1','false'};
        private String[] allowStandardAnswersPages_type_info = new String[]{'allowStandardAnswersPages',SOAP_M_URI,null,'0','1','false'};
        private String[] allowStandardIdeasPages_type_info = new String[]{'allowStandardIdeasPages',SOAP_M_URI,null,'1','1','false'};
        private String[] allowStandardLookups_type_info = new String[]{'allowStandardLookups',SOAP_M_URI,null,'1','1','false'};
        private String[] allowStandardSearch_type_info = new String[]{'allowStandardSearch',SOAP_M_URI,null,'1','1','false'};
        private String[] analyticsTrackingCode_type_info = new String[]{'analyticsTrackingCode',SOAP_M_URI,null,'0','1','false'};
        private String[] authorizationRequiredPage_type_info = new String[]{'authorizationRequiredPage',SOAP_M_URI,null,'0','1','false'};
        private String[] bandwidthExceededPage_type_info = new String[]{'bandwidthExceededPage',SOAP_M_URI,null,'0','1','false'};
        private String[] changePasswordPage_type_info = new String[]{'changePasswordPage',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersForgotPasswordConfirmPage_type_info = new String[]{'chatterAnswersForgotPasswordConfirmPage',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersForgotPasswordPage_type_info = new String[]{'chatterAnswersForgotPasswordPage',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersHelpPage_type_info = new String[]{'chatterAnswersHelpPage',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersLoginPage_type_info = new String[]{'chatterAnswersLoginPage',SOAP_M_URI,null,'0','1','false'};
        private String[] chatterAnswersRegistrationPage_type_info = new String[]{'chatterAnswersRegistrationPage',SOAP_M_URI,null,'0','1','false'};
        private String[] clickjackProtectionLevel_type_info = new String[]{'clickjackProtectionLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] customWebAddresses_type_info = new String[]{'customWebAddresses',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] favoriteIcon_type_info = new String[]{'favoriteIcon',SOAP_M_URI,null,'0','1','false'};
        private String[] fileNotFoundPage_type_info = new String[]{'fileNotFoundPage',SOAP_M_URI,null,'0','1','false'};
        private String[] forgotPasswordPage_type_info = new String[]{'forgotPasswordPage',SOAP_M_URI,null,'0','1','false'};
        private String[] genericErrorPage_type_info = new String[]{'genericErrorPage',SOAP_M_URI,null,'0','1','false'};
        private String[] guestProfile_type_info = new String[]{'guestProfile',SOAP_M_URI,null,'0','1','false'};
        private String[] inMaintenancePage_type_info = new String[]{'inMaintenancePage',SOAP_M_URI,null,'0','1','false'};
        private String[] inactiveIndexPage_type_info = new String[]{'inactiveIndexPage',SOAP_M_URI,null,'0','1','false'};
        private String[] indexPage_type_info = new String[]{'indexPage',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] myProfilePage_type_info = new String[]{'myProfilePage',SOAP_M_URI,null,'0','1','false'};
        private String[] portal_type_info = new String[]{'portal',SOAP_M_URI,null,'0','1','false'};
        private String[] requireHttps_type_info = new String[]{'requireHttps',SOAP_M_URI,null,'1','1','false'};
        private String[] requireInsecurePortalAccess_type_info = new String[]{'requireInsecurePortalAccess',SOAP_M_URI,null,'1','1','false'};
        private String[] robotsTxtPage_type_info = new String[]{'robotsTxtPage',SOAP_M_URI,null,'0','1','false'};
        private String[] rootComponent_type_info = new String[]{'rootComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegPage_type_info = new String[]{'selfRegPage',SOAP_M_URI,null,'0','1','false'};
        private String[] serverIsDown_type_info = new String[]{'serverIsDown',SOAP_M_URI,null,'0','1','false'};
        private String[] siteAdmin_type_info = new String[]{'siteAdmin',SOAP_M_URI,null,'0','1','false'};
        private String[] siteRedirectMappings_type_info = new String[]{'siteRedirectMappings',SOAP_M_URI,null,'0','-1','false'};
        private String[] siteTemplate_type_info = new String[]{'siteTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] siteType_type_info = new String[]{'siteType',SOAP_M_URI,null,'1','1','false'};
        private String[] subdomain_type_info = new String[]{'subdomain',SOAP_M_URI,null,'0','1','false'};
        private String[] urlPathPrefix_type_info = new String[]{'urlPathPrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','allowHomePage','allowStandardAnswersPages','allowStandardIdeasPages','allowStandardLookups','allowStandardSearch','analyticsTrackingCode','authorizationRequiredPage','bandwidthExceededPage','changePasswordPage','chatterAnswersForgotPasswordConfirmPage','chatterAnswersForgotPasswordPage','chatterAnswersHelpPage','chatterAnswersLoginPage','chatterAnswersRegistrationPage','clickjackProtectionLevel','customWebAddresses','description','favoriteIcon','fileNotFoundPage','forgotPasswordPage','genericErrorPage','guestProfile','inMaintenancePage','inactiveIndexPage','indexPage','masterLabel','myProfilePage','portal','requireHttps','requireInsecurePortalAccess','robotsTxtPage','rootComponent','selfRegPage','serverIsDown','siteAdmin','siteRedirectMappings','siteTemplate','siteType','subdomain','urlPathPrefix'};
    }
    public class Skill extends Metadata {
        public String type = 'Skill';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.SkillAssignments assignments;
        public String description;
        public String label;
        private String[] assignments_type_info = new String[]{'assignments',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assignments','description','label'};
    }
    public class renameMetadataResponse_element {
        public MetadataService.SaveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class RelatedList {
        public Boolean hideOnDetail;
        public String name;
        private String[] hideOnDetail_type_info = new String[]{'hideOnDetail',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'hideOnDetail','name'};
    }
    public class SynonymGroup {
        public String[] languages;
        public String[] terms;
        private String[] languages_type_info = new String[]{'languages',SOAP_M_URI,null,'0','-1','false'};
        private String[] terms_type_info = new String[]{'terms',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'languages','terms'};
    }
    public class MatchingRule extends Metadata {
        public String type = 'MatchingRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String booleanFilter;
        public String description;
        public String label;
        public MetadataService.MatchingRuleItem[] matchingRuleItems;
        public String ruleStatus;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] matchingRuleItems_type_info = new String[]{'matchingRuleItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] ruleStatus_type_info = new String[]{'ruleStatus',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'booleanFilter','description','label','matchingRuleItems','ruleStatus'};
    }
    public class PasswordPolicies {
        public String apiOnlyUserHomePageURL;
        public String complexity;
        public String expiration;
        public String historyRestriction;
        public String lockoutInterval;
        public String maxLoginAttempts;
        public String minimumPasswordLength;
        public Boolean minimumPasswordLifetime;
        public Boolean obscureSecretAnswer;
        public String passwordAssistanceMessage;
        public String passwordAssistanceURL;
        public String questionRestriction;
        private String[] apiOnlyUserHomePageURL_type_info = new String[]{'apiOnlyUserHomePageURL',SOAP_M_URI,null,'0','1','false'};
        private String[] complexity_type_info = new String[]{'complexity',SOAP_M_URI,null,'0','1','false'};
        private String[] expiration_type_info = new String[]{'expiration',SOAP_M_URI,null,'0','1','false'};
        private String[] historyRestriction_type_info = new String[]{'historyRestriction',SOAP_M_URI,null,'0','1','false'};
        private String[] lockoutInterval_type_info = new String[]{'lockoutInterval',SOAP_M_URI,null,'0','1','false'};
        private String[] maxLoginAttempts_type_info = new String[]{'maxLoginAttempts',SOAP_M_URI,null,'0','1','false'};
        private String[] minimumPasswordLength_type_info = new String[]{'minimumPasswordLength',SOAP_M_URI,null,'0','1','false'};
        private String[] minimumPasswordLifetime_type_info = new String[]{'minimumPasswordLifetime',SOAP_M_URI,null,'0','1','false'};
        private String[] obscureSecretAnswer_type_info = new String[]{'obscureSecretAnswer',SOAP_M_URI,null,'0','1','false'};
        private String[] passwordAssistanceMessage_type_info = new String[]{'passwordAssistanceMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] passwordAssistanceURL_type_info = new String[]{'passwordAssistanceURL',SOAP_M_URI,null,'0','1','false'};
        private String[] questionRestriction_type_info = new String[]{'questionRestriction',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiOnlyUserHomePageURL','complexity','expiration','historyRestriction','lockoutInterval','maxLoginAttempts','minimumPasswordLength','minimumPasswordLifetime','obscureSecretAnswer','passwordAssistanceMessage','passwordAssistanceURL','questionRestriction'};
    }
    public class AnalyticsCloudComponentLayoutItem {
        public String assetType;
        public String devName;
        public String error;
        public String filter;
        public Integer height;
        public Boolean hideOnError;
        public Boolean showSharing;
        public Boolean showTitle;
        public String width;
        private String[] assetType_type_info = new String[]{'assetType',SOAP_M_URI,null,'1','1','false'};
        private String[] devName_type_info = new String[]{'devName',SOAP_M_URI,null,'1','1','false'};
        private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
        private String[] filter_type_info = new String[]{'filter',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
        private String[] showSharing_type_info = new String[]{'showSharing',SOAP_M_URI,null,'0','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assetType','devName','error','filter','height','hideOnError','showSharing','showTitle','width'};
    }
    public class SFDCMobileSettings {
        public Boolean enableMobileLite;
        public Boolean enableUserToDeviceLinking;
        private String[] enableMobileLite_type_info = new String[]{'enableMobileLite',SOAP_M_URI,null,'0','1','false'};
        private String[] enableUserToDeviceLinking_type_info = new String[]{'enableUserToDeviceLinking',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableMobileLite','enableUserToDeviceLinking'};
    }
    public class SharingReason extends Metadata {
        public String type = 'SharingReason';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String label;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'label'};
    }
    public class CustomFeedFilter {
        public MetadataService.FeedFilterCriterion[] criteria;
        public String description;
        public Boolean isProtected;
        public String label;
        private String[] criteria_type_info = new String[]{'criteria',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'criteria','description','isProtected','label'};
    }
    public class ProfileRecordTypeVisibility {
        public Boolean default_x;
        public Boolean personAccountDefault;
        public String recordType;
        public Boolean visible;
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] personAccountDefault_type_info = new String[]{'personAccountDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'default_x','personAccountDefault','recordType','visible'};
    }
    public class DashboardMobileSettings {
        public Boolean enableDashboardIPadApp;
        private String[] enableDashboardIPadApp_type_info = new String[]{'enableDashboardIPadApp',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enableDashboardIPadApp'};
    }
    public class SiteRedirectMapping {
        public String action;
        public Boolean isActive;
        public String source;
        public String target;
        private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] source_type_info = new String[]{'source',SOAP_M_URI,null,'1','1','false'};
        private String[] target_type_info = new String[]{'target',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'action','isActive','source','target'};
    }
    public class AgentConfigProfileAssignments {
        public String[] profile;
        private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'profile'};
    }
    public interface IReadResult {
        MetadataService.Metadata[] getRecords();
    }
    public interface IReadResponseElement {
        IReadResult getResult();
    }
    public class ReadCustomSiteResult implements IReadResult {
        public MetadataService.CustomSite[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomSiteResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomSiteResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadListViewResult implements IReadResult {
        public MetadataService.ListView[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readListViewResponse_element implements IReadResponseElement {
        public MetadataService.ReadListViewResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadInstalledPackageResult implements IReadResult {
        public MetadataService.InstalledPackage[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readInstalledPackageResponse_element implements IReadResponseElement {
        public MetadataService.ReadInstalledPackageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomFieldResult implements IReadResult {
        public MetadataService.CustomField[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomFieldResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomFieldResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFieldSetResult implements IReadResult {
        public MetadataService.FieldSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFieldSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadFieldSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPicklistValueResult implements IReadResult {
        public MetadataService.PicklistValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPicklistValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadPicklistValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadRecordTypeResult implements IReadResult {
        public MetadataService.RecordType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readRecordTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadRecordTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWebLinkResult implements IReadResult {
        public MetadataService.WebLink[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWebLinkResponse_element implements IReadResponseElement {
        public MetadataService.ReadWebLinkResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAddressSettingsResult implements IReadResult {
        public MetadataService.AddressSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAddressSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadAddressSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCaseSettingsResult implements IReadResult {
        public MetadataService.CaseSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCaseSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadCaseSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomObjectResult implements IReadResult {
        public MetadataService.CustomObject[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomObjectResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomObjectResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLayoutResult implements IReadResult {
        public MetadataService.Layout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEmailTemplateResult implements IReadResult {
        public MetadataService.EmailTemplate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEmailTemplateResponse_element implements IReadResponseElement {
        public MetadataService.ReadEmailTemplateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadScontrolResult implements IReadResult {
        public MetadataService.Scontrol[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readScontrolResponse_element implements IReadResponseElement {
        public MetadataService.ReadScontrolResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApexPageResult implements IReadResult {
        public MetadataService.ApexPage[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApexPageResponse_element implements IReadResponseElement {
        public MetadataService.ReadApexPageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApexComponentResult implements IReadResult {
        public MetadataService.ApexComponent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApexComponentResponse_element implements IReadResponseElement {
        public MetadataService.ReadApexComponentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApexClassResult implements IReadResult {
        public MetadataService.ApexClass[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApexClassResponse_element implements IReadResponseElement {
        public MetadataService.ReadApexClassResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApexTriggerResult implements IReadResult {
        public MetadataService.ApexTrigger[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApexTriggerResponse_element implements IReadResponseElement {
        public MetadataService.ReadApexTriggerResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadStaticResourceResult implements IReadResult {
        public MetadataService.StaticResource[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readStaticResourceResponse_element implements IReadResponseElement {
        public MetadataService.ReadStaticResourceResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDocumentResult implements IReadResult {
        public MetadataService.Document[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDocumentResponse_element implements IReadResponseElement {
        public MetadataService.ReadDocumentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomLabelsResult implements IReadResult {
        public MetadataService.CustomLabels[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomLabelsResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomLabelsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomLabelResult implements IReadResult {
        public MetadataService.CustomLabel[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomLabelResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomLabelResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAccountSettingsResult implements IReadResult {
        public MetadataService.AccountSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAccountSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadAccountSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadQueueResult implements IReadResult {
        public MetadataService.Queue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readQueueResponse_element implements IReadResponseElement {
        public MetadataService.ReadQueueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomDataTypeResult implements IReadResult {
        public MetadataService.CustomDataType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomDataTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomDataTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadExternalDataSourceResult implements IReadResult {
        public MetadataService.ExternalDataSource[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readExternalDataSourceResponse_element implements IReadResponseElement {
        public MetadataService.ReadExternalDataSourceResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadGroupResult implements IReadResult {
        public MetadataService.Group_x[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readGroupResponse_element implements IReadResponseElement {
        public MetadataService.ReadGroupResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadBusinessProcessResult implements IReadResult {
        public MetadataService.BusinessProcess[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readBusinessProcessResponse_element implements IReadResponseElement {
        public MetadataService.ReadBusinessProcessResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCompactLayoutResult implements IReadResult {
        public MetadataService.CompactLayout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCompactLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadCompactLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingReasonResult implements IReadResult {
        public MetadataService.SharingReason[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingReasonResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingReasonResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadValidationRuleResult implements IReadResult {
        public MetadataService.ValidationRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readValidationRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadValidationRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadReportTypeResult implements IReadResult {
        public MetadataService.ReportType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readReportTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadReportTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadReportResult implements IReadResult {
        public MetadataService.Report[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readReportResponse_element implements IReadResponseElement {
        public MetadataService.ReadReportResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDashboardResult implements IReadResult {
        public MetadataService.Dashboard[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDashboardResponse_element implements IReadResponseElement {
        public MetadataService.ReadDashboardResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAnalyticSnapshotResult implements IReadResult {
        public MetadataService.AnalyticSnapshot[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAnalyticSnapshotResponse_element implements IReadResponseElement {
        public MetadataService.ReadAnalyticSnapshotResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomPageWebLinkResult implements IReadResult {
        public MetadataService.CustomPageWebLink[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomPageWebLinkResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomPageWebLinkResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadQuickActionResult implements IReadResult {
        public MetadataService.QuickAction[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readQuickActionResponse_element implements IReadResponseElement {
        public MetadataService.ReadQuickActionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFlexiPageResult implements IReadResult {
        public MetadataService.FlexiPage[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFlexiPageResponse_element implements IReadResponseElement {
        public MetadataService.ReadFlexiPageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomTabResult implements IReadResult {
        public MetadataService.CustomTab[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomTabResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomTabResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomApplicationComponentResult implements IReadResult {
        public MetadataService.CustomApplicationComponent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomApplicationComponentResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomApplicationComponentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomApplicationResult implements IReadResult {
        public MetadataService.CustomApplication[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomApplicationResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomApplicationResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPortalResult implements IReadResult {
        public MetadataService.Portal[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPortalResponse_element implements IReadResponseElement {
        public MetadataService.ReadPortalResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLetterheadResult implements IReadResult {
        public MetadataService.Letterhead[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLetterheadResponse_element implements IReadResponseElement {
        public MetadataService.ReadLetterheadResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFlowResult implements IReadResult {
        public MetadataService.Flow[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFlowResponse_element implements IReadResponseElement {
        public MetadataService.ReadFlowResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowResult implements IReadResult {
        public MetadataService.Workflow[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowRuleResult implements IReadResult {
        public MetadataService.WorkflowRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAssignmentRulesResult implements IReadResult {
        public MetadataService.AssignmentRules[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAssignmentRulesResponse_element implements IReadResponseElement {
        public MetadataService.ReadAssignmentRulesResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAssignmentRuleResult implements IReadResult {
        public MetadataService.AssignmentRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAssignmentRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadAssignmentRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAutoResponseRulesResult implements IReadResult {
        public MetadataService.AutoResponseRules[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAutoResponseRulesResponse_element implements IReadResponseElement {
        public MetadataService.ReadAutoResponseRulesResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAutoResponseRuleResult implements IReadResult {
        public MetadataService.AutoResponseRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAutoResponseRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadAutoResponseRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEscalationRulesResult implements IReadResult {
        public MetadataService.EscalationRules[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEscalationRulesResponse_element implements IReadResponseElement {
        public MetadataService.ReadEscalationRulesResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEscalationRuleResult implements IReadResult {
        public MetadataService.EscalationRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEscalationRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadEscalationRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPostTemplateResult implements IReadResult {
        public MetadataService.PostTemplate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPostTemplateResponse_element implements IReadResponseElement {
        public MetadataService.ReadPostTemplateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApprovalProcessResult implements IReadResult {
        public MetadataService.ApprovalProcess[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApprovalProcessResponse_element implements IReadResponseElement {
        public MetadataService.ReadApprovalProcessResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadHomePageComponentResult implements IReadResult {
        public MetadataService.HomePageComponent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readHomePageComponentResponse_element implements IReadResponseElement {
        public MetadataService.ReadHomePageComponentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadHomePageLayoutResult implements IReadResult {
        public MetadataService.HomePageLayout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readHomePageLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadHomePageLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomObjectTranslationResult implements IReadResult {
        public MetadataService.CustomObjectTranslation[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomObjectTranslationResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomObjectTranslationResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadTranslationsResult implements IReadResult {
        public MetadataService.Translations[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readTranslationsResponse_element implements IReadResponseElement {
        public MetadataService.ReadTranslationsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadProfileResult implements IReadResult {
        public MetadataService.Profile[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readProfileResponse_element implements IReadResponseElement {
        public MetadataService.ReadProfileResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPermissionSetResult implements IReadResult {
        public MetadataService.PermissionSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPermissionSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadPermissionSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDataCategoryGroupResult implements IReadResult {
        public MetadataService.DataCategoryGroup[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDataCategoryGroupResponse_element implements IReadResponseElement {
        public MetadataService.ReadDataCategoryGroupResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadRemoteSiteSettingResult implements IReadResult {
        public MetadataService.RemoteSiteSetting[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readRemoteSiteSettingResponse_element implements IReadResponseElement {
        public MetadataService.ReadRemoteSiteSettingResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPackageResult implements IReadResult {
        public MetadataService.Package_x[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPackageResponse_element implements IReadResponseElement {
        public MetadataService.ReadPackageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAuthProviderResult implements IReadResult {
        public MetadataService.AuthProvider[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAuthProviderResponse_element implements IReadResponseElement {
        public MetadataService.ReadAuthProviderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadKnowledgeSettingsResult implements IReadResult {
        public MetadataService.KnowledgeSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readKnowledgeSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadKnowledgeSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingSetResult implements IReadResult {
        public MetadataService.SharingSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSecuritySettingsResult implements IReadResult {
        public MetadataService.SecuritySettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSecuritySettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadSecuritySettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadIdeasSettingsResult implements IReadResult {
        public MetadataService.IdeasSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readIdeasSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadIdeasSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadChatterAnswersSettingsResult implements IReadResult {
        public MetadataService.ChatterAnswersSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readChatterAnswersSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadChatterAnswersSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCommunityResult implements IReadResult {
        public MetadataService.Community[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCommunityResponse_element implements IReadResponseElement {
        public MetadataService.ReadCommunityResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadActivitiesSettingsResult implements IReadResult {
        public MetadataService.ActivitiesSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readActivitiesSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadActivitiesSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadContractSettingsResult implements IReadResult {
        public MetadataService.ContractSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readContractSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadContractSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadOrderSettingsResult implements IReadResult {
        public MetadataService.OrderSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readOrderSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadOrderSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadOpportunitySettingsResult implements IReadResult {
        public MetadataService.OpportunitySettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readOpportunitySettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadOpportunitySettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadProductSettingsResult implements IReadResult {
        public MetadataService.ProductSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readProductSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadProductSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadQuoteSettingsResult implements IReadResult {
        public MetadataService.QuoteSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readQuoteSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadQuoteSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCallCenterResult implements IReadResult {
        public MetadataService.CallCenter[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCallCenterResponse_element implements IReadResponseElement {
        public MetadataService.ReadCallCenterResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEntitlementProcessResult implements IReadResult {
        public MetadataService.EntitlementProcess[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEntitlementProcessResponse_element implements IReadResponseElement {
        public MetadataService.ReadEntitlementProcessResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMilestoneTypeResult implements IReadResult {
        public MetadataService.MilestoneType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMilestoneTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadMilestoneTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEntitlementTemplateResult implements IReadResult {
        public MetadataService.EntitlementTemplate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEntitlementTemplateResponse_element implements IReadResponseElement {
        public MetadataService.ReadEntitlementTemplateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEntitlementSettingsResult implements IReadResult {
        public MetadataService.EntitlementSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEntitlementSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadEntitlementSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadBusinessHoursSettingsResult implements IReadResult {
        public MetadataService.BusinessHoursSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readBusinessHoursSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadBusinessHoursSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadBusinessHoursEntryResult implements IReadResult {
        public MetadataService.BusinessHoursEntry[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readBusinessHoursEntryResponse_element implements IReadResponseElement {
        public MetadataService.ReadBusinessHoursEntryResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadConnectedAppResult implements IReadResult {
        public MetadataService.ConnectedApp[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readConnectedAppResponse_element implements IReadResponseElement {
        public MetadataService.ReadConnectedAppResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAppMenuResult implements IReadResult {
        public MetadataService.AppMenu[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAppMenuResponse_element implements IReadResponseElement {
        public MetadataService.ReadAppMenuResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMobileSettingsResult implements IReadResult {
        public MetadataService.MobileSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMobileSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadMobileSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadNetworkResult implements IReadResult {
        public MetadataService.Network[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readNetworkResponse_element implements IReadResponseElement {
        public MetadataService.ReadNetworkResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCompanySettingsResult implements IReadResult {
        public MetadataService.CompanySettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCompanySettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadCompanySettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadForecastingSettingsResult implements IReadResult {
        public MetadataService.ForecastingSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readForecastingSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadForecastingSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSamlSsoConfigResult implements IReadResult {
        public MetadataService.SamlSsoConfig[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSamlSsoConfigResponse_element implements IReadResponseElement {
        public MetadataService.ReadSamlSsoConfigResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLiveAgentSettingsResult implements IReadResult {
        public MetadataService.LiveAgentSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLiveAgentSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadLiveAgentSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSkillResult implements IReadResult {
        public MetadataService.Skill[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSkillResponse_element implements IReadResponseElement {
        public MetadataService.ReadSkillResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLiveChatDeploymentResult implements IReadResult {
        public MetadataService.LiveChatDeployment[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLiveChatDeploymentResponse_element implements IReadResponseElement {
        public MetadataService.ReadLiveChatDeploymentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLiveChatButtonResult implements IReadResult {
        public MetadataService.LiveChatButton[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLiveChatButtonResponse_element implements IReadResponseElement {
        public MetadataService.ReadLiveChatButtonResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLiveChatAgentConfigResult implements IReadResult {
        public MetadataService.LiveChatAgentConfig[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLiveChatAgentConfigResponse_element implements IReadResponseElement {
        public MetadataService.ReadLiveChatAgentConfigResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSynonymDictionaryResult implements IReadResult {
        public MetadataService.SynonymDictionary[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSynonymDictionaryResponse_element implements IReadResponseElement {
        public MetadataService.ReadSynonymDictionaryResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFolderResult implements IReadResult {
        public MetadataService.Folder[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFolderResponse_element implements IReadResponseElement {
        public MetadataService.ReadFolderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadReportFolderResult implements IReadResult {
        public MetadataService.ReportFolder[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readReportFolderResponse_element implements IReadResponseElement {
        public MetadataService.ReadReportFolderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDashboardFolderResult implements IReadResult {
        public MetadataService.DashboardFolder[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDashboardFolderResponse_element implements IReadResponseElement {
        public MetadataService.ReadDashboardFolderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDocumentFolderResult implements IReadResult {
        public MetadataService.DocumentFolder[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDocumentFolderResponse_element implements IReadResponseElement {
        public MetadataService.ReadDocumentFolderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEmailFolderResult implements IReadResult {
        public MetadataService.EmailFolder[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEmailFolderResponse_element implements IReadResponseElement {
        public MetadataService.ReadEmailFolderResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadRoleOrTerritoryResult implements IReadResult {
        public MetadataService.RoleOrTerritory[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readRoleOrTerritoryResponse_element implements IReadResponseElement {
        public MetadataService.ReadRoleOrTerritoryResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowActionResult implements IReadResult {
        public MetadataService.WorkflowAction[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowActionResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowActionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSiteDotComResult implements IReadResult {
        public MetadataService.SiteDotCom[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSiteDotComResponse_element implements IReadResponseElement {
        public MetadataService.ReadSiteDotComResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowTaskResult implements IReadResult {
        public MetadataService.WorkflowTask[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowTaskResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowTaskResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowSendResult implements IReadResult {
        public MetadataService.WorkflowSend[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowSendResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowSendResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowOutboundMessageResult implements IReadResult {
        public MetadataService.WorkflowOutboundMessage[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowOutboundMessageResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowOutboundMessageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowKnowledgePublishResult implements IReadResult {
        public MetadataService.WorkflowKnowledgePublish[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowKnowledgePublishResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowKnowledgePublishResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowFieldUpdateResult implements IReadResult {
        public MetadataService.WorkflowFieldUpdate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowFieldUpdateResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowFieldUpdateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWorkflowAlertResult implements IReadResult {
        public MetadataService.WorkflowAlert[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWorkflowAlertResponse_element implements IReadResponseElement {
        public MetadataService.ReadWorkflowAlertResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadVisualizationPluginResult implements IReadResult {
        public MetadataService.VisualizationPlugin[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readVisualizationPluginResponse_element implements IReadResponseElement {
        public MetadataService.ReadVisualizationPluginResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomMetadataResult implements IReadResult {
        public MetadataService.CustomMetadata[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomMetadataResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomMetadataResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadNameSettingsResult implements IReadResult {
        public MetadataService.NameSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readNameSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadNameSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMarketingActionSettingsResult implements IReadResult {
        public MetadataService.MarketingActionSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMarketingActionSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadMarketingActionSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomPermissionResult implements IReadResult {
        public MetadataService.CustomPermission[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomPermissionResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomPermissionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadAuraDefinitionBundleResult implements IReadResult {
        public MetadataService.AuraDefinitionBundle[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readAuraDefinitionBundleResponse_element implements IReadResponseElement {
        public MetadataService.ReadAuraDefinitionBundleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCorsWhitelistOriginResult implements IReadResult {
        public MetadataService.CorsWhitelistOrigin[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCorsWhitelistOriginResponse_element implements IReadResponseElement {
        public MetadataService.ReadCorsWhitelistOriginResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadManagedTopicsResult implements IReadResult {
        public MetadataService.ManagedTopics[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readManagedTopicsResponse_element implements IReadResponseElement {
        public MetadataService.ReadManagedTopicsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadTerritory2Result implements IReadResult {
        public MetadataService.Territory2[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readTerritory2Response_element implements IReadResponseElement {
        public MetadataService.ReadTerritory2Result result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadTerritory2ModelResult implements IReadResult {
        public MetadataService.Territory2Model[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readTerritory2ModelResponse_element implements IReadResponseElement {
        public MetadataService.ReadTerritory2ModelResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadTerritory2SettingsResult implements IReadResult {
        public MetadataService.Territory2Settings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readTerritory2SettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadTerritory2SettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadTerritory2TypeResult implements IReadResult {
        public MetadataService.Territory2Type[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readTerritory2TypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadTerritory2TypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadXOrgHubResult implements IReadResult {
        public MetadataService.XOrgHub[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readXOrgHubResponse_element implements IReadResponseElement {
        public MetadataService.ReadXOrgHubResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadActionLinkGroupTemplateResult implements IReadResult {
        public MetadataService.ActionLinkGroupTemplate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readActionLinkGroupTemplateResponse_element implements IReadResponseElement {
        public MetadataService.ReadActionLinkGroupTemplateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadLicenseDefinitionResult implements IReadResult {
        public MetadataService.LicenseDefinition[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLicenseDefinitionResponse_element implements IReadResponseElement {
        public MetadataService.ReadLicenseDefinitionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMarketingResourceTypeResult implements IReadResult {
        public MetadataService.MarketingResourceType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMarketingResourceTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadMarketingResourceTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMatchingRuleResult implements IReadResult {
        public MetadataService.MatchingRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMatchingRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadMatchingRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMatchingRulesResult implements IReadResult {
        public MetadataService.MatchingRules[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMatchingRulesResponse_element implements IReadResponseElement {
        public MetadataService.ReadMatchingRulesResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadNamedCredentialResult implements IReadResult {
        public MetadataService.NamedCredential[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readNamedCredentialResponse_element implements IReadResponseElement {
        public MetadataService.ReadNamedCredentialResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPersonalJourneySettingsResult implements IReadResult {
        public MetadataService.PersonalJourneySettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPersonalJourneySettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadPersonalJourneySettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingRulesResult implements IReadResult {
        public MetadataService.SharingRules[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingRulesResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingRulesResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingBaseRuleResult implements IReadResult {
        public MetadataService.SharingBaseRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingBaseRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingBaseRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingCriteriaRuleResult implements IReadResult {
        public MetadataService.SharingCriteriaRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingCriteriaRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingCriteriaRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingOwnerRuleResult implements IReadResult {
        public MetadataService.SharingOwnerRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingOwnerRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingOwnerRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSharingTerritoryRuleResult implements IReadResult {
        public MetadataService.SharingTerritoryRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingTerritoryRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingTerritoryRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadMetadataWithContentResult implements IReadResult {
        public MetadataService.MetadataWithContent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMetadataWithContentResponse_element implements IReadResponseElement {
        public MetadataService.ReadMetadataWithContentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadDelegateGroupResult implements IReadResult {
        public MetadataService.DelegateGroup[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readDelegateGroupResponse_element implements IReadResponseElement {
        public MetadataService.ReadDelegateGroupResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEventDeliveryResult implements IReadResult {
        public MetadataService.EventDelivery[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEventDeliveryResponse_element implements IReadResponseElement {
        public MetadataService.ReadEventDeliveryResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEventSubscriptionResult implements IReadResult {
        public MetadataService.EventSubscription[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEventSubscriptionResponse_element implements IReadResponseElement {
        public MetadataService.ReadEventSubscriptionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadEventTypeResult implements IReadResult {
        public MetadataService.EventType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readEventTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadEventTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCertificateResult implements IReadResult {
        public MetadataService.Certificate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCertificateResponse_element implements IReadResponseElement {
        public MetadataService.ReadCertificateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadModerationRuleResult implements IReadResult {
        public MetadataService.ModerationRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readModerationRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadModerationRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWaveApplicationResult implements IReadResult {
        public MetadataService.WaveApplication[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWaveApplicationResponse_element implements IReadResponseElement {
        public MetadataService.ReadWaveApplicationResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWaveDatasetResult implements IReadResult {
        public MetadataService.WaveDataset[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWaveDatasetResponse_element implements IReadResponseElement {
        public MetadataService.ReadWaveDatasetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWaveDashboardResult implements IReadResult {
        public MetadataService.WaveDashboard[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWaveDashboardResponse_element implements IReadResponseElement {
        public MetadataService.ReadWaveDashboardResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWaveDataflowResult implements IReadResult {
        public MetadataService.WaveDataflow[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWaveDataflowResponse_element implements IReadResponseElement {
        public MetadataService.ReadWaveDataflowResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWaveLensResult implements IReadResult {
        public MetadataService.WaveLens[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWaveLensResponse_element implements IReadResponseElement {
        public MetadataService.ReadWaveLensResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadOrgPreferenceSettingsResult implements IReadResult {
        public MetadataService.OrgPreferenceSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readOrgPreferenceSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadOrgPreferenceSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadSearchSettingsResult implements IReadResult {
        public MetadataService.SearchSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSearchSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadSearchSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadGlobalValueSetResult implements IReadResult {
        public MetadataService.GlobalValueSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readGlobalValueSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadGlobalValueSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadGlobalPicklistValueResult implements IReadResult {
        public MetadataService.GlobalPicklistValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readGlobalPicklistValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadGlobalPicklistValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadStandardValueSetResult implements IReadResult {
        public MetadataService.StandardValueSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readStandardValueSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadStandardValueSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadStandardValueResult implements IReadResult {
        public MetadataService.StandardValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readStandardValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadStandardValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadCustomValueResult implements IReadResult {
        public MetadataService.CustomValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadApexTestSuiteResult implements IReadResult {
        public MetadataService.ApexTestSuite[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readApexTestSuiteResponse_element implements IReadResponseElement {
        public MetadataService.ReadApexTestSuiteResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadChannelLayoutResult implements IReadResult {
        public MetadataService.ChannelLayout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readChannelLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadChannelLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadContentAssetResult implements IReadResult {
        public MetadataService.ContentAsset[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readContentAssetResponse_element implements IReadResponseElement {
        public MetadataService.ReadContentAssetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFlowSettingsResult implements IReadResult {
        public MetadataService.FlowSettings[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFlowSettingsResponse_element implements IReadResponseElement {
        public MetadataService.ReadFlowSettingsResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadResult {
        public MetadataService.Metadata[] records;
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class ReportBucketFieldValue {
        public MetadataService.ReportBucketFieldSourceValue[] sourceValues;
        public String value;
        private String[] sourceValues_type_info = new String[]{'sourceValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sourceValues','value'};
    }
    public class ProfileApexPageAccess {
        public String apexPage;
        public Boolean enabled;
        private String[] apexPage_type_info = new String[]{'apexPage',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexPage','enabled'};
    }
    public class Scontrol extends MetadataWithContent {
        public String type = 'Scontrol';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String contentSource;
        public String description;
        public String encodingKey;
        public String fileContent;
        public String fileName;
        public String name;
        public Boolean supportsCaching;
        private String[] contentSource_type_info = new String[]{'contentSource',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'1','1','false'};
        private String[] fileContent_type_info = new String[]{'fileContent',SOAP_M_URI,null,'0','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] supportsCaching_type_info = new String[]{'supportsCaching',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'contentSource','description','encodingKey','fileContent','fileName','name','supportsCaching'};
    }
    public class Network extends Metadata {
        public String type = 'Network';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean allowMembersToFlag;
        public String allowedExtensions;
        public MetadataService.Branding branding;
        public String caseCommentEmailTemplate;
        public String changePasswordTemplate;
        public String description;
        public String emailSenderAddress;
        public String emailSenderName;
        public Boolean enableGuestChatter;
        public Boolean enableInvitation;
        public Boolean enableKnowledgeable;
        public Boolean enableNicknameDisplay;
        public Boolean enablePrivateMessages;
        public Boolean enableReputation;
        public Boolean enableSiteAsContainer;
        public String feedChannel;
        public String forgotPasswordTemplate;
        public String logoutUrl;
        public Integer maxFileSizeKb;
        public MetadataService.NavigationLinkSet navigationLinkSet;
        public MetadataService.NetworkMemberGroup networkMemberGroups;
        public String newSenderAddress;
        public String picassoSite;
        public MetadataService.ReputationLevelDefinitions reputationLevels;
        public MetadataService.ReputationPointsRules reputationPointsRules;
        public String selfRegProfile;
        public Boolean selfRegistration;
        public Boolean sendWelcomeEmail;
        public String site;
        public String status;
        public MetadataService.NetworkTabSet tabs;
        public String urlPathPrefix;
        public String welcomeTemplate;
        private String[] allowMembersToFlag_type_info = new String[]{'allowMembersToFlag',SOAP_M_URI,null,'0','1','false'};
        private String[] allowedExtensions_type_info = new String[]{'allowedExtensions',SOAP_M_URI,null,'0','1','false'};
        private String[] branding_type_info = new String[]{'branding',SOAP_M_URI,null,'0','1','false'};
        private String[] caseCommentEmailTemplate_type_info = new String[]{'caseCommentEmailTemplate',SOAP_M_URI,null,'0','1','false'};
        private String[] changePasswordTemplate_type_info = new String[]{'changePasswordTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] emailSenderAddress_type_info = new String[]{'emailSenderAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] emailSenderName_type_info = new String[]{'emailSenderName',SOAP_M_URI,null,'1','1','false'};
        private String[] enableGuestChatter_type_info = new String[]{'enableGuestChatter',SOAP_M_URI,null,'0','1','false'};
        private String[] enableInvitation_type_info = new String[]{'enableInvitation',SOAP_M_URI,null,'0','1','false'};
        private String[] enableKnowledgeable_type_info = new String[]{'enableKnowledgeable',SOAP_M_URI,null,'0','1','false'};
        private String[] enableNicknameDisplay_type_info = new String[]{'enableNicknameDisplay',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePrivateMessages_type_info = new String[]{'enablePrivateMessages',SOAP_M_URI,null,'0','1','false'};
        private String[] enableReputation_type_info = new String[]{'enableReputation',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSiteAsContainer_type_info = new String[]{'enableSiteAsContainer',SOAP_M_URI,null,'0','1','false'};
        private String[] feedChannel_type_info = new String[]{'feedChannel',SOAP_M_URI,null,'0','1','false'};
        private String[] forgotPasswordTemplate_type_info = new String[]{'forgotPasswordTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] logoutUrl_type_info = new String[]{'logoutUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] maxFileSizeKb_type_info = new String[]{'maxFileSizeKb',SOAP_M_URI,null,'0','1','false'};
        private String[] navigationLinkSet_type_info = new String[]{'navigationLinkSet',SOAP_M_URI,null,'0','1','false'};
        private String[] networkMemberGroups_type_info = new String[]{'networkMemberGroups',SOAP_M_URI,null,'0','1','false'};
        private String[] newSenderAddress_type_info = new String[]{'newSenderAddress',SOAP_M_URI,null,'0','1','false'};
        private String[] picassoSite_type_info = new String[]{'picassoSite',SOAP_M_URI,null,'0','1','false'};
        private String[] reputationLevels_type_info = new String[]{'reputationLevels',SOAP_M_URI,null,'0','1','false'};
        private String[] reputationPointsRules_type_info = new String[]{'reputationPointsRules',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegProfile_type_info = new String[]{'selfRegProfile',SOAP_M_URI,null,'0','1','false'};
        private String[] selfRegistration_type_info = new String[]{'selfRegistration',SOAP_M_URI,null,'0','1','false'};
        private String[] sendWelcomeEmail_type_info = new String[]{'sendWelcomeEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'1','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] tabs_type_info = new String[]{'tabs',SOAP_M_URI,null,'1','1','false'};
        private String[] urlPathPrefix_type_info = new String[]{'urlPathPrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] welcomeTemplate_type_info = new String[]{'welcomeTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'allowMembersToFlag','allowedExtensions','branding','caseCommentEmailTemplate','changePasswordTemplate','description','emailSenderAddress','emailSenderName','enableGuestChatter','enableInvitation','enableKnowledgeable','enableNicknameDisplay','enablePrivateMessages','enableReputation','enableSiteAsContainer','feedChannel','forgotPasswordTemplate','logoutUrl','maxFileSizeKb','navigationLinkSet','networkMemberGroups','newSenderAddress','picassoSite','reputationLevels','reputationPointsRules','selfRegProfile','selfRegistration','sendWelcomeEmail','site','status','tabs','urlPathPrefix','welcomeTemplate'};
    }
    public class ActionLinkTemplate {
        public String actionUrl;
        public String headers;
        public Boolean isConfirmationRequired;
        public Boolean isGroupDefault;
        public String label;
        public String labelKey;
        public String linkType;
        public String method;
        public Integer position;
        public String requestBody;
        public String userAlias;
        public String userVisibility;
        private String[] actionUrl_type_info = new String[]{'actionUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] headers_type_info = new String[]{'headers',SOAP_M_URI,null,'0','1','false'};
        private String[] isConfirmationRequired_type_info = new String[]{'isConfirmationRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] isGroupDefault_type_info = new String[]{'isGroupDefault',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] labelKey_type_info = new String[]{'labelKey',SOAP_M_URI,null,'1','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] method_type_info = new String[]{'method',SOAP_M_URI,null,'1','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
        private String[] requestBody_type_info = new String[]{'requestBody',SOAP_M_URI,null,'0','1','false'};
        private String[] userAlias_type_info = new String[]{'userAlias',SOAP_M_URI,null,'0','1','false'};
        private String[] userVisibility_type_info = new String[]{'userVisibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionUrl','headers','isConfirmationRequired','isGroupDefault','label','labelKey','linkType','method','position','requestBody','userAlias','userVisibility'};
    }
    public class EntitlementProcessMilestoneItem {
        public String businessHours;
        public String criteriaBooleanFilter;
        public MetadataService.FilterItem[] milestoneCriteriaFilterItems;
        public String milestoneCriteriaFormula;
        public String milestoneName;
        public String minutesCustomClass;
        public Integer minutesToComplete;
        public MetadataService.WorkflowActionReference[] successActions;
        public MetadataService.EntitlementProcessMilestoneTimeTrigger[] timeTriggers;
        public Boolean useCriteriaStartTime;
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaBooleanFilter_type_info = new String[]{'criteriaBooleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] milestoneCriteriaFilterItems_type_info = new String[]{'milestoneCriteriaFilterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] milestoneCriteriaFormula_type_info = new String[]{'milestoneCriteriaFormula',SOAP_M_URI,null,'0','1','false'};
        private String[] milestoneName_type_info = new String[]{'milestoneName',SOAP_M_URI,null,'0','1','false'};
        private String[] minutesCustomClass_type_info = new String[]{'minutesCustomClass',SOAP_M_URI,null,'0','1','false'};
        private String[] minutesToComplete_type_info = new String[]{'minutesToComplete',SOAP_M_URI,null,'0','1','false'};
        private String[] successActions_type_info = new String[]{'successActions',SOAP_M_URI,null,'0','-1','false'};
        private String[] timeTriggers_type_info = new String[]{'timeTriggers',SOAP_M_URI,null,'0','-1','false'};
        private String[] useCriteriaStartTime_type_info = new String[]{'useCriteriaStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'businessHours','criteriaBooleanFilter','milestoneCriteriaFilterItems','milestoneCriteriaFormula','milestoneName','minutesCustomClass','minutesToComplete','successActions','timeTriggers','useCriteriaStartTime'};
    }
    public class ReportFilter {
        public String booleanFilter;
        public MetadataService.ReportFilterItem[] criteriaItems;
        public String language;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'booleanFilter','criteriaItems','language'};
    }
    public class RetrieveResult {
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public MetadataService.FileProperties[] fileProperties;
        public String id;
        public MetadataService.RetrieveMessage[] messages;
        public String status;
        public Boolean success;
        public String zipFile;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] fileProperties_type_info = new String[]{'fileProperties',SOAP_M_URI,null,'0','-1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] messages_type_info = new String[]{'messages',SOAP_M_URI,null,'0','-1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] zipFile_type_info = new String[]{'zipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','errorMessage','errorStatusCode','fileProperties','id','messages','status','success','zipFile'};
    }
    public class Territory2Model extends Metadata {
        public String type = 'Territory2Model';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.FieldValue[] customFields;
        public String description;
        public String name;
        private String[] customFields_type_info = new String[]{'customFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customFields','description','name'};
    }
    public class SearchSettingsByObject {
        public MetadataService.ObjectSearchSetting[] searchSettingsByObject;
        private String[] searchSettingsByObject_type_info = new String[]{'searchSettingsByObject',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'searchSettingsByObject'};
    }
    public class CustomObject extends Metadata {
        public String type = 'CustomObject';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ActionOverride[] actionOverrides;
        public Boolean allowInChatterGroups;
        public MetadataService.ArticleTypeChannelDisplay articleTypeChannelDisplay;
        public MetadataService.BusinessProcess[] businessProcesses;
        public String compactLayoutAssignment;
        public MetadataService.CompactLayout[] compactLayouts;
        public String customHelp;
        public String customHelpPage;
        public String customSettingsType;
        public String deploymentStatus;
        public Boolean deprecated;
        public String description;
        public Boolean enableActivities;
        public Boolean enableBulkApi;
        public Boolean enableChangeDataCapture;
        public Boolean enableDivisions;
        public Boolean enableEnhancedLookup;
        public Boolean enableFeeds;
        public Boolean enableHistory;
        public Boolean enableReports;
        public Boolean enableSearch;
        public Boolean enableSharing;
        public Boolean enableStreamingApi;
        public String externalDataSource;
        public String externalName;
        public String externalRepository;
        public String externalSharingModel;
        public MetadataService.FieldSet[] fieldSets;
        public MetadataService.CustomField[] fields;
        public String gender;
        public MetadataService.HistoryRetentionPolicy historyRetentionPolicy;
        public Boolean household;
        public String label;
        public MetadataService.ListView[] listViews;
        public MetadataService.CustomField nameField;
        public String pluralLabel;
        public Boolean recordTypeTrackFeedHistory;
        public Boolean recordTypeTrackHistory;
        public MetadataService.RecordType[] recordTypes;
        public MetadataService.SearchLayouts searchLayouts;
        public String sharingModel;
        public MetadataService.SharingReason[] sharingReasons;
        public MetadataService.SharingRecalculation[] sharingRecalculations;
        public String startsWith;
        public MetadataService.ValidationRule[] validationRules;
        public String visibility;
        public MetadataService.WebLink[] webLinks;
        private String[] actionOverrides_type_info = new String[]{'actionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] allowInChatterGroups_type_info = new String[]{'allowInChatterGroups',SOAP_M_URI,null,'0','1','false'};
        private String[] articleTypeChannelDisplay_type_info = new String[]{'articleTypeChannelDisplay',SOAP_M_URI,null,'0','1','false'};
        private String[] businessProcesses_type_info = new String[]{'businessProcesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] compactLayoutAssignment_type_info = new String[]{'compactLayoutAssignment',SOAP_M_URI,null,'0','1','false'};
        private String[] compactLayouts_type_info = new String[]{'compactLayouts',SOAP_M_URI,null,'0','-1','false'};
        private String[] customHelp_type_info = new String[]{'customHelp',SOAP_M_URI,null,'0','1','false'};
        private String[] customHelpPage_type_info = new String[]{'customHelpPage',SOAP_M_URI,null,'0','1','false'};
        private String[] customSettingsType_type_info = new String[]{'customSettingsType',SOAP_M_URI,null,'0','1','false'};
        private String[] deploymentStatus_type_info = new String[]{'deploymentStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] deprecated_type_info = new String[]{'deprecated',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] enableActivities_type_info = new String[]{'enableActivities',SOAP_M_URI,null,'0','1','false'};
        private String[] enableBulkApi_type_info = new String[]{'enableBulkApi',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChangeDataCapture_type_info = new String[]{'enableChangeDataCapture',SOAP_M_URI,null,'0','1','false'};
        private String[] enableDivisions_type_info = new String[]{'enableDivisions',SOAP_M_URI,null,'0','1','false'};
        private String[] enableEnhancedLookup_type_info = new String[]{'enableEnhancedLookup',SOAP_M_URI,null,'0','1','false'};
        private String[] enableFeeds_type_info = new String[]{'enableFeeds',SOAP_M_URI,null,'0','1','false'};
        private String[] enableHistory_type_info = new String[]{'enableHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] enableReports_type_info = new String[]{'enableReports',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSearch_type_info = new String[]{'enableSearch',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSharing_type_info = new String[]{'enableSharing',SOAP_M_URI,null,'0','1','false'};
        private String[] enableStreamingApi_type_info = new String[]{'enableStreamingApi',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'0','1','false'};
        private String[] externalName_type_info = new String[]{'externalName',SOAP_M_URI,null,'0','1','false'};
        private String[] externalRepository_type_info = new String[]{'externalRepository',SOAP_M_URI,null,'0','1','false'};
        private String[] externalSharingModel_type_info = new String[]{'externalSharingModel',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldSets_type_info = new String[]{'fieldSets',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] gender_type_info = new String[]{'gender',SOAP_M_URI,null,'0','1','false'};
        private String[] historyRetentionPolicy_type_info = new String[]{'historyRetentionPolicy',SOAP_M_URI,null,'0','1','false'};
        private String[] household_type_info = new String[]{'household',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] listViews_type_info = new String[]{'listViews',SOAP_M_URI,null,'0','-1','false'};
        private String[] nameField_type_info = new String[]{'nameField',SOAP_M_URI,null,'0','1','false'};
        private String[] pluralLabel_type_info = new String[]{'pluralLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypeTrackFeedHistory_type_info = new String[]{'recordTypeTrackFeedHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypeTrackHistory_type_info = new String[]{'recordTypeTrackHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypes_type_info = new String[]{'recordTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchLayouts_type_info = new String[]{'searchLayouts',SOAP_M_URI,null,'0','1','false'};
        private String[] sharingModel_type_info = new String[]{'sharingModel',SOAP_M_URI,null,'0','1','false'};
        private String[] sharingReasons_type_info = new String[]{'sharingReasons',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharingRecalculations_type_info = new String[]{'sharingRecalculations',SOAP_M_URI,null,'0','-1','false'};
        private String[] startsWith_type_info = new String[]{'startsWith',SOAP_M_URI,null,'0','1','false'};
        private String[] validationRules_type_info = new String[]{'validationRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'0','1','false'};
        private String[] webLinks_type_info = new String[]{'webLinks',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionOverrides','allowInChatterGroups','articleTypeChannelDisplay','businessProcesses','compactLayoutAssignment','compactLayouts','customHelp','customHelpPage','customSettingsType','deploymentStatus','deprecated','description','enableActivities','enableBulkApi','enableChangeDataCapture','enableDivisions','enableEnhancedLookup','enableFeeds','enableHistory','enableReports','enableSearch','enableSharing','enableStreamingApi','externalDataSource','externalName','externalRepository','externalSharingModel','fieldSets','fields','gender','historyRetentionPolicy','household','label','listViews','nameField','pluralLabel','recordTypeTrackFeedHistory','recordTypeTrackHistory','recordTypes','searchLayouts','sharingModel','sharingReasons','sharingRecalculations','startsWith','validationRules','visibility','webLinks'};
    }
    public class DuplicateRuleFilter {
        public String booleanFilter;
        public MetadataService.DuplicateRuleFilterItem[] duplicateRuleFilterItems;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'1','1','true'};
        private String[] duplicateRuleFilterItems_type_info = new String[]{'duplicateRuleFilterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'booleanFilter','duplicateRuleFilterItems'};
    }
    public class LayoutSection {
        public Boolean customLabel;
        public Boolean detailHeading;
        public Boolean editHeading;
        public String label;
        public MetadataService.LayoutColumn[] layoutColumns;
        public String style;
        private String[] customLabel_type_info = new String[]{'customLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] detailHeading_type_info = new String[]{'detailHeading',SOAP_M_URI,null,'0','1','false'};
        private String[] editHeading_type_info = new String[]{'editHeading',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] layoutColumns_type_info = new String[]{'layoutColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customLabel','detailHeading','editHeading','label','layoutColumns','style'};
    }
    public class cancelDeployResponse_element {
        public MetadataService.CancelDeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ProfileObjectPermissions {
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean modifyAllRecords;
        public String object_x;
        public Boolean viewAllRecords;
        private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'0','1','false'};
        private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'0','1','false'};
        private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'0','1','false'};
        private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'0','1','false'};
        private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
    }
    public class ReportGrouping {
        public String aggregateType;
        public String dateGranularity;
        public String field;
        public String sortByName;
        public String sortOrder;
        public String sortType;
        private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
        private String[] dateGranularity_type_info = new String[]{'dateGranularity',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] sortByName_type_info = new String[]{'sortByName',SOAP_M_URI,null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
        private String[] sortType_type_info = new String[]{'sortType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregateType','dateGranularity','field','sortByName','sortOrder','sortType'};
    }
    public class DeployMessage {
        public Boolean changed;
        public Integer columnNumber;
        public String componentType;
        public Boolean created;
        public DateTime createdDate;
        public Boolean deleted;
        public String fileName;
        public String fullName;
        public String id;
        public Integer lineNumber;
        public String problem;
        public String problemType;
        public Boolean success;
        private String[] changed_type_info = new String[]{'changed',SOAP_M_URI,null,'1','1','false'};
        private String[] columnNumber_type_info = new String[]{'columnNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'0','1','false'};
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] deleted_type_info = new String[]{'deleted',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'0','1','false'};
        private String[] lineNumber_type_info = new String[]{'lineNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'0','1','false'};
        private String[] problemType_type_info = new String[]{'problemType',SOAP_M_URI,null,'0','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'changed','columnNumber','componentType','created','createdDate','deleted','fileName','fullName','id','lineNumber','problem','problemType','success'};
    }
    public class PermissionSetObjectPermissions {
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean modifyAllRecords;
        public String object_x;
        public Boolean viewAllRecords;
        private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'1','1','false'};
        private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'1','1','false'};
        private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'1','1','false'};
        private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'1','1','false'};
        private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'1','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
    }
    public class ProfileApexClassAccess {
        public String apexClass;
        public Boolean enabled;
        private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexClass','enabled'};
    }
    public class ProfileLoginIpRange {
        public String description;
        public String endAddress;
        public String startAddress;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] endAddress_type_info = new String[]{'endAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] startAddress_type_info = new String[]{'startAddress',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','endAddress','startAddress'};
    }
    public class ChartSummary {
        public String aggregate;
        public String axisBinding;
        public String column;
        private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'0','1','false'};
        private String[] axisBinding_type_info = new String[]{'axisBinding',SOAP_M_URI,null,'0','1','false'};
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregate','axisBinding','column'};
    }
    public class InstalledPackage extends Metadata {
        public String type = 'InstalledPackage';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String password;
        public String versionNumber;
        private String[] password_type_info = new String[]{'password',SOAP_M_URI,null,'0','1','false'};
        private String[] versionNumber_type_info = new String[]{'versionNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'password','versionNumber'};
    }
    public class NavigationMenuItem {
        public String defaultListViewId;
        public String label;
        public Integer position;
        public Boolean publiclyAvailable;
        public String target;
        public String targetPreference;
        public String type_x;
        private String[] defaultListViewId_type_info = new String[]{'defaultListViewId',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
        private String[] publiclyAvailable_type_info = new String[]{'publiclyAvailable',SOAP_M_URI,null,'0','1','false'};
        private String[] target_type_info = new String[]{'target',SOAP_M_URI,null,'1','1','false'};
        private String[] targetPreference_type_info = new String[]{'targetPreference',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'defaultListViewId','label','position','publiclyAvailable','target','targetPreference','type_x'};
    }
    public class checkRetrieveStatus_element {
        public String asyncProcessId;
        public Boolean includeZip;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeZip_type_info = new String[]{'includeZip',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeZip'};
    }
    public class Country {
        public Boolean active;
        public String integrationValue;
        public String isoCode;
        public String label;
        public Boolean orgDefault;
        public Boolean standard;
        public MetadataService.State[] states;
        public Boolean visible;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] integrationValue_type_info = new String[]{'integrationValue',SOAP_M_URI,null,'1','1','false'};
        private String[] isoCode_type_info = new String[]{'isoCode',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] orgDefault_type_info = new String[]{'orgDefault',SOAP_M_URI,null,'1','1','false'};
        private String[] standard_type_info = new String[]{'standard',SOAP_M_URI,null,'1','1','false'};
        private String[] states_type_info = new String[]{'states',SOAP_M_URI,null,'0','-1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','integrationValue','isoCode','label','orgDefault','standard','states','visible'};
    }
    public class ObjectUsage {
        public String[] object_x;
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'object_x'};
    }
    public class Package_x extends Metadata {
        public String type = 'Package_x';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String apiAccessLevel;
        public String description;
        public String namespacePrefix;
        public MetadataService.ProfileObjectPermissions[] objectPermissions;
        public String packageType;
        public String postInstallClass;
        public String setupWeblink;
        public MetadataService.PackageTypeMembers[] types;
        public String uninstallClass;
        public String version;
        private String[] apiAccessLevel_type_info = new String[]{'apiAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] packageType_type_info = new String[]{'packageType',SOAP_M_URI,null,'0','1','false'};
        private String[] postInstallClass_type_info = new String[]{'postInstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] setupWeblink_type_info = new String[]{'setupWeblink',SOAP_M_URI,null,'0','1','false'};
        private String[] types_type_info = new String[]{'types',SOAP_M_URI,null,'0','-1','false'};
        private String[] uninstallClass_type_info = new String[]{'uninstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'apiAccessLevel','description','namespacePrefix','objectPermissions','packageType','postInstallClass','setupWeblink','types','uninstallClass','version'};
    }
    public class SharingReasonTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class CustomDataTypeComponentTranslation {
        public String developerSuffix;
        public String label;
        private String[] developerSuffix_type_info = new String[]{'developerSuffix',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'developerSuffix','label'};
    }
    public class FeedLayoutComponent {
        public String componentType;
        public Integer height;
        public String page_x;
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','page_x'};
    }
    public class CallCenterSection {
        public MetadataService.CallCenterItem[] items;
        public String label;
        public String name;
        private String[] items_type_info = new String[]{'items',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'items','label','name'};
    }
    public class WaveDashboard extends MetadataWithContent {
        public String type = 'WaveDashboard';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String content;
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        public String application;
        public String description;
        public String masterLabel;
        public String templateAssetSourceName;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] templateAssetSourceName_type_info = new String[]{'templateAssetSourceName',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','content', 'application','description','masterLabel','templateAssetSourceName'};
    }
    public class CustomApplication extends Metadata {
        public String type = 'CustomApplication';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AppActionOverride[] actionOverrides;
        public MetadataService.AppBrand brand;
        public MetadataService.CustomApplicationComponents customApplicationComponents;
        public String defaultLandingTab;
        public String description;
        public String detailPageRefreshMethod;
        public MetadataService.DomainWhitelist domainWhitelist;
        public Boolean enableCustomizeMyTabs;
        public Boolean enableKeyboardShortcuts;
        public Boolean enableListViewHover;
        public Boolean enableListViewReskin;
        public Boolean enableMultiMonitorComponents;
        public Boolean enablePinTabs;
        public Boolean enableTabHover;
        public Boolean enableTabLimits;
        public String footerColor;
        public String[] formFactors;
        public String headerColor;
        public Boolean isServiceCloudConsole;
        public MetadataService.KeyboardShortcuts keyboardShortcuts;
        public String label;
        public MetadataService.ListPlacement listPlacement;
        public String listRefreshMethod;
        public MetadataService.LiveAgentConfig liveAgentConfig;
        public String logo;
        public String navType;
        public String primaryTabColor;
        public MetadataService.PushNotifications pushNotifications;
        public Boolean saveUserSessions;
        public String[] tab;
        public MetadataService.TabLimitConfig tabLimitConfig;
        public String uiType;
        public String utilityBar;
        public MetadataService.WorkspaceMappings workspaceMappings;
        private String[] actionOverrides_type_info = new String[]{'actionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] brand_type_info = new String[]{'brand',SOAP_M_URI,null,'0','1','false'};
        private String[] customApplicationComponents_type_info = new String[]{'customApplicationComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultLandingTab_type_info = new String[]{'defaultLandingTab',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] detailPageRefreshMethod_type_info = new String[]{'detailPageRefreshMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] domainWhitelist_type_info = new String[]{'domainWhitelist',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCustomizeMyTabs_type_info = new String[]{'enableCustomizeMyTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] enableKeyboardShortcuts_type_info = new String[]{'enableKeyboardShortcuts',SOAP_M_URI,null,'0','1','false'};
        private String[] enableListViewHover_type_info = new String[]{'enableListViewHover',SOAP_M_URI,null,'0','1','false'};
        private String[] enableListViewReskin_type_info = new String[]{'enableListViewReskin',SOAP_M_URI,null,'0','1','false'};
        private String[] enableMultiMonitorComponents_type_info = new String[]{'enableMultiMonitorComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePinTabs_type_info = new String[]{'enablePinTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTabHover_type_info = new String[]{'enableTabHover',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTabLimits_type_info = new String[]{'enableTabLimits',SOAP_M_URI,null,'0','1','false'};
        private String[] footerColor_type_info = new String[]{'footerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] formFactors_type_info = new String[]{'formFactors',SOAP_M_URI,null,'0','-1','false'};
        private String[] headerColor_type_info = new String[]{'headerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] isServiceCloudConsole_type_info = new String[]{'isServiceCloudConsole',SOAP_M_URI,null,'0','1','false'};
        private String[] keyboardShortcuts_type_info = new String[]{'keyboardShortcuts',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] listPlacement_type_info = new String[]{'listPlacement',SOAP_M_URI,null,'0','1','false'};
        private String[] listRefreshMethod_type_info = new String[]{'listRefreshMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] liveAgentConfig_type_info = new String[]{'liveAgentConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
        private String[] navType_type_info = new String[]{'navType',SOAP_M_URI,null,'0','1','false'};
        private String[] primaryTabColor_type_info = new String[]{'primaryTabColor',SOAP_M_URI,null,'0','1','false'};
        private String[] pushNotifications_type_info = new String[]{'pushNotifications',SOAP_M_URI,null,'0','1','false'};
        private String[] saveUserSessions_type_info = new String[]{'saveUserSessions',SOAP_M_URI,null,'0','1','false'};
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'0','-1','false'};
        private String[] tabLimitConfig_type_info = new String[]{'tabLimitConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] uiType_type_info = new String[]{'uiType',SOAP_M_URI,null,'0','1','false'};
        private String[] utilityBar_type_info = new String[]{'utilityBar',SOAP_M_URI,null,'0','1','false'};
        private String[] workspaceMappings_type_info = new String[]{'workspaceMappings',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionOverrides','brand','customApplicationComponents','defaultLandingTab','description','detailPageRefreshMethod','domainWhitelist','enableCustomizeMyTabs','enableKeyboardShortcuts','enableListViewHover','enableListViewReskin','enableMultiMonitorComponents','enablePinTabs','enableTabHover','enableTabLimits','footerColor','formFactors','headerColor','isServiceCloudConsole','keyboardShortcuts','label','listPlacement','listRefreshMethod','liveAgentConfig','logo','navType','primaryTabColor','pushNotifications','saveUserSessions','tab','tabLimitConfig','uiType','utilityBar','workspaceMappings'};
    }
    public class DescribeMetadataResult {
        public MetadataService.DescribeMetadataObject[] metadataObjects;
        public String organizationNamespace;
        public Boolean partialSaveAllowed;
        public Boolean testRequired;
        private String[] metadataObjects_type_info = new String[]{'metadataObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] organizationNamespace_type_info = new String[]{'organizationNamespace',SOAP_M_URI,null,'1','1','false'};
        private String[] partialSaveAllowed_type_info = new String[]{'partialSaveAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] testRequired_type_info = new String[]{'testRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadataObjects','organizationNamespace','partialSaveAllowed','testRequired'};
    }
    public class LeadConvertSettings {
        public Boolean allowOwnerChange;
        public String opportunityCreationOptions;
        private String[] allowOwnerChange_type_info = new String[]{'allowOwnerChange',SOAP_M_URI,null,'0','1','false'};
        private String[] opportunityCreationOptions_type_info = new String[]{'opportunityCreationOptions',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowOwnerChange','opportunityCreationOptions'};
    }
    public class OpportunityListFieldsLabelMapping {
        public String field;
        public String label;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','label'};
    }
    public class ReportType extends Metadata {
        public String type = 'ReportType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean autogenerated;
        public String baseObject;
        public String category;
        public Boolean deployed;
        public String description;
        public MetadataService.ObjectRelationship join_x;
        public String label;
        public MetadataService.ReportLayoutSection[] sections;
        private String[] autogenerated_type_info = new String[]{'autogenerated',SOAP_M_URI,null,'0','1','false'};
        private String[] baseObject_type_info = new String[]{'baseObject',SOAP_M_URI,null,'1','1','false'};
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] deployed_type_info = new String[]{'deployed',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] join_x_type_info = new String[]{'join',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] sections_type_info = new String[]{'sections',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'autogenerated','baseObject','category','deployed','description','join_x','label','sections'};
    }
    public class deleteMetadataResponse_element {
        public MetadataService.DeleteResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class CodeLocation {
        public Integer column;
        public Integer line;
        public Integer numExecutions;
        public Double time_x;
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] line_type_info = new String[]{'line',SOAP_M_URI,null,'1','1','false'};
        private String[] numExecutions_type_info = new String[]{'numExecutions',SOAP_M_URI,null,'1','1','false'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'column','line','numExecutions','time_x'};
    }
    public class Keyword {
        public String keyword;
        private String[] keyword_type_info = new String[]{'keyword',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'keyword'};
    }
    public class PermissionSetApplicationVisibility {
        public String application;
        public Boolean visible;
        private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'application','visible'};
    }
    public class AppActionOverride {
        public String pageOrSobjectType;
        private String[] pageOrSobjectType_type_info = new String[]{'pageOrSobjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pageOrSobjectType'};
    }
    public class StandardFieldTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class RoleOrTerritory extends Metadata {
        public String type = 'RoleOrTerritory';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String caseAccessLevel;
        public String contactAccessLevel;
        public String description;
        public Boolean mayForecastManagerShare;
        public String name;
        public String opportunityAccessLevel;
        private String[] caseAccessLevel_type_info = new String[]{'caseAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] contactAccessLevel_type_info = new String[]{'contactAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] mayForecastManagerShare_type_info = new String[]{'mayForecastManagerShare',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] opportunityAccessLevel_type_info = new String[]{'opportunityAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'caseAccessLevel','contactAccessLevel','description','mayForecastManagerShare','name','opportunityAccessLevel'};
    }
    public class LiveChatButtonSkills {
        public String[] skill;
        private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'skill'};
    }
    public class RemoteSiteSetting extends Metadata {
        public String type = 'RemoteSiteSetting';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public Boolean disableProtocolSecurity;
        public Boolean isActive;
        public String url;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] disableProtocolSecurity_type_info = new String[]{'disableProtocolSecurity',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','disableProtocolSecurity','isActive','url'};
    }
    public class ConnectedAppOauthConfig {
        public String callbackUrl;
        public String certificate;
        public String consumerKey;
        public String consumerSecret;
        public String[] scopes;
        private String[] callbackUrl_type_info = new String[]{'callbackUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
        private String[] consumerKey_type_info = new String[]{'consumerKey',SOAP_M_URI,null,'0','1','false'};
        private String[] consumerSecret_type_info = new String[]{'consumerSecret',SOAP_M_URI,null,'0','1','false'};
        private String[] scopes_type_info = new String[]{'scopes',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'callbackUrl','certificate','consumerKey','consumerSecret','scopes'};
    }
    public class ObjectSearchSetting {
        public Boolean enhancedLookupEnabled;
        public Boolean lookupAutoCompleteEnabled;
        public String name;
        public Integer resultsPerPageCount;
        private String[] enhancedLookupEnabled_type_info = new String[]{'enhancedLookupEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] lookupAutoCompleteEnabled_type_info = new String[]{'lookupAutoCompleteEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] resultsPerPageCount_type_info = new String[]{'resultsPerPageCount',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enhancedLookupEnabled','lookupAutoCompleteEnabled','name','resultsPerPageCount'};
    }
    public class VisualizationResource {
        public String description;
        public String file;
        public Integer rank;
        public String type_x;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] file_type_info = new String[]{'file',SOAP_M_URI,null,'1','1','false'};
        private String[] rank_type_info = new String[]{'rank',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','file','rank','type_x'};
    }
    public class NextAutomatedApprover {
        public Boolean useApproverFieldOfRecordOwner;
        public String userHierarchyField;
        private String[] useApproverFieldOfRecordOwner_type_info = new String[]{'useApproverFieldOfRecordOwner',SOAP_M_URI,null,'0','1','false'};
        private String[] userHierarchyField_type_info = new String[]{'userHierarchyField',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'useApproverFieldOfRecordOwner','userHierarchyField'};
    }
    public class ValueSetValuesDefinition {
        public Boolean sorted;
        public MetadataService.CustomValue[] value;
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sorted','value'};
    }
    public class Territory2Rule {
        public Boolean active;
        public String booleanFilter;
        public String name;
        public String objectType;
        public MetadataService.Territory2RuleItem[] ruleItems;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] objectType_type_info = new String[]{'objectType',SOAP_M_URI,null,'1','1','false'};
        private String[] ruleItems_type_info = new String[]{'ruleItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','booleanFilter','name','objectType','ruleItems'};
    }
    public class RetrieveMessage {
        public String fileName;
        public String problem;
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fileName','problem'};
    }
    public class ForecastingCategoryMapping {
        public String forecastingItemCategoryApiName;
        public MetadataService.WeightedSourceCategory[] weightedSourceCategories;
        private String[] forecastingItemCategoryApiName_type_info = new String[]{'forecastingItemCategoryApiName',SOAP_M_URI,null,'1','1','false'};
        private String[] weightedSourceCategories_type_info = new String[]{'weightedSourceCategories',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'forecastingItemCategoryApiName','weightedSourceCategories'};
    }
    public class HistoryRetentionPolicy {
        public Integer archiveAfterMonths;
        public Integer archiveRetentionYears;
        public String description;
        public Integer gracePeriodDays;
        private String[] archiveAfterMonths_type_info = new String[]{'archiveAfterMonths',SOAP_M_URI,null,'1','1','false'};
        private String[] archiveRetentionYears_type_info = new String[]{'archiveRetentionYears',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] gracePeriodDays_type_info = new String[]{'gracePeriodDays',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'archiveAfterMonths','archiveRetentionYears','description','gracePeriodDays'};
    }
    public class WorkspaceMappings {
        public MetadataService.WorkspaceMapping[] mapping;
        private String[] mapping_type_info = new String[]{'mapping',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'mapping'};
    }
    public class Picklist {
        public String controllingField;
        public MetadataService.PicklistValue[] picklistValues;
        public Boolean restrictedPicklist;
        public Boolean sorted;
        private String[] controllingField_type_info = new String[]{'controllingField',SOAP_M_URI,null,'0','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] restrictedPicklist_type_info = new String[]{'restrictedPicklist',SOAP_M_URI,null,'0','1','false'};
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingField','picklistValues','restrictedPicklist','sorted'};
    }
    public class deploy_element {
        public String ZipFile;
        public MetadataService.DeployOptions DeployOptions;
        private String[] ZipFile_type_info = new String[]{'ZipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] DeployOptions_type_info = new String[]{'DeployOptions',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'ZipFile','DeployOptions'};
    }
    public class ReportTypeSectionTranslation {
        public MetadataService.ReportTypeColumnTranslation[] columns;
        public String label;
        public String name;
        private String[] columns_type_info = new String[]{'columns',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'columns','label','name'};
    }
    public class PersonalJourneySettings extends Metadata {
        public String type = 'PersonalJourneySettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableExactTargetForSalesforceApps;
        private String[] enableExactTargetForSalesforceApps_type_info = new String[]{'enableExactTargetForSalesforceApps',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableExactTargetForSalesforceApps'};
    }
    public class CustomPermission extends Metadata {
        public String type = 'CustomPermission';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String connectedApp;
        public String description;
        public String label;
        public MetadataService.CustomPermissionDependencyRequired[] requiredPermission;
        private String[] connectedApp_type_info = new String[]{'connectedApp',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] requiredPermission_type_info = new String[]{'requiredPermission',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'connectedApp','description','label','requiredPermission'};
    }
    public class DuplicateRule {
        public String actionOnInsert;
        public String actionOnUpdate;
        public String alertText;
        public String description;
        public MetadataService.DuplicateRuleFilter duplicateRuleFilter;
        public MetadataService.DuplicateRuleMatchRule[] duplicateRuleMatchRules;
        public Boolean isActive;
        public String masterLabel;
        public String[] operationsOnInsert;
        public String[] operationsOnUpdate;
        public String securityOption;
        public Integer sortOrder;
        private String[] actionOnInsert_type_info = new String[]{'actionOnInsert',SOAP_M_URI,null,'1','1','false'};
        private String[] actionOnUpdate_type_info = new String[]{'actionOnUpdate',SOAP_M_URI,null,'1','1','false'};
        private String[] alertText_type_info = new String[]{'alertText',SOAP_M_URI,null,'1','1','true'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','true'};
        private String[] duplicateRuleFilter_type_info = new String[]{'duplicateRuleFilter',SOAP_M_URI,null,'1','1','true'};
        private String[] duplicateRuleMatchRules_type_info = new String[]{'duplicateRuleMatchRules',SOAP_M_URI,null,'0','-1','true'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] operationsOnInsert_type_info = new String[]{'operationsOnInsert',SOAP_M_URI,null,'0','-1','false'};
        private String[] operationsOnUpdate_type_info = new String[]{'operationsOnUpdate',SOAP_M_URI,null,'0','-1','false'};
        private String[] securityOption_type_info = new String[]{'securityOption',SOAP_M_URI,null,'1','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionOnInsert','actionOnUpdate','alertText','description','duplicateRuleFilter','duplicateRuleMatchRules','isActive','masterLabel','operationsOnInsert','operationsOnUpdate','securityOption','sortOrder'};
    }
    public class AgentConfigSkills {
        public String[] skill;
        private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'skill'};
    }
    public class DeployResult {
        public String canceledBy;
        public String canceledByName;
        public Boolean checkOnly;
        public DateTime completedDate;
        public String createdBy;
        public String createdByName;
        public DateTime createdDate;
        public MetadataService.DeployDetails details;
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public String id;
        public Boolean ignoreWarnings;
        public DateTime lastModifiedDate;
        public Integer numberComponentErrors;
        public Integer numberComponentsDeployed;
        public Integer numberComponentsTotal;
        public Integer numberTestErrors;
        public Integer numberTestsCompleted;
        public Integer numberTestsTotal;
        public Boolean rollbackOnError;
        public Boolean runTestsEnabled;
        public DateTime startDate;
        public String stateDetail;
        public String status;
        public Boolean success;
        private String[] canceledBy_type_info = new String[]{'canceledBy',SOAP_M_URI,null,'0','1','false'};
        private String[] canceledByName_type_info = new String[]{'canceledByName',SOAP_M_URI,null,'0','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] completedDate_type_info = new String[]{'completedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] createdBy_type_info = new String[]{'createdBy',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] details_type_info = new String[]{'details',SOAP_M_URI,null,'1','1','false'};
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] numberComponentErrors_type_info = new String[]{'numberComponentErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsDeployed_type_info = new String[]{'numberComponentsDeployed',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsTotal_type_info = new String[]{'numberComponentsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestErrors_type_info = new String[]{'numberTestErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsCompleted_type_info = new String[]{'numberTestsCompleted',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsTotal_type_info = new String[]{'numberTestsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTestsEnabled_type_info = new String[]{'runTestsEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,null,'0','1','false'};
        private String[] stateDetail_type_info = new String[]{'stateDetail',SOAP_M_URI,null,'0','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'canceledBy','canceledByName','checkOnly','completedDate','createdBy','createdByName','createdDate','details','done','errorMessage','errorStatusCode','id','ignoreWarnings','lastModifiedDate','numberComponentErrors','numberComponentsDeployed','numberComponentsTotal','numberTestErrors','numberTestsCompleted','numberTestsTotal','rollbackOnError','runTestsEnabled','startDate','stateDetail','status','success'};
    }
    public class IdeaReputationLevel {
        public String name;
        public Integer value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    public class EmbeddedServiceConfig {
        public String masterLabel;
        public String site;
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','site'};
    }
    public class PagesToOpen {
        public String[] pageToOpen;
        private String[] pageToOpen_type_info = new String[]{'pageToOpen',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pageToOpen'};
    }
    public class WorkflowTimeTrigger {
        public MetadataService.WorkflowActionReference[] actions;
        public String offsetFromField;
        public String timeLength;
        public String workflowTimeTriggerUnit;
        private String[] actions_type_info = new String[]{'actions',SOAP_M_URI,null,'0','-1','false'};
        private String[] offsetFromField_type_info = new String[]{'offsetFromField',SOAP_M_URI,null,'0','1','false'};
        private String[] timeLength_type_info = new String[]{'timeLength',SOAP_M_URI,null,'0','1','false'};
        private String[] workflowTimeTriggerUnit_type_info = new String[]{'workflowTimeTriggerUnit',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actions','offsetFromField','timeLength','workflowTimeTriggerUnit'};
    }
    public class AutoResponseRules extends Metadata {
        public String type = 'AutoResponseRules';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.AutoResponseRule[] autoResponseRule;
        private String[] autoResponseRule_type_info = new String[]{'autoResponseRule',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'autoResponseRule'};
    }
    public class LayoutTranslation {
        public String layout;
        public String layoutType;
        public MetadataService.LayoutSectionTranslation[] sections;
        private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
        private String[] layoutType_type_info = new String[]{'layoutType',SOAP_M_URI,null,'0','1','false'};
        private String[] sections_type_info = new String[]{'sections',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layout','layoutType','sections'};
    }
    public class DashboardFolder extends Folder {
        public String type = 'DashboardFolder';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String accessType;
        public MetadataService.FolderShare[] folderShares;
        public String name;
        public String publicFolderAccess;
        public MetadataService.SharedTo sharedTo;
        private String[] accessType_type_info = new String[]{'accessType',SOAP_M_URI,null,'0','1','false'};
        private String[] folderShares_type_info = new String[]{'folderShares',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] publicFolderAccess_type_info = new String[]{'publicFolderAccess',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','accessType','folderShares','name','publicFolderAccess','sharedTo'};
    }
    public class ForecastingSettings extends Metadata {
        public String type = 'ForecastingSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String displayCurrency;
        public Boolean enableForecasts;
        public MetadataService.ForecastingCategoryMapping[] forecastingCategoryMappings;
        public MetadataService.ForecastingTypeSettings[] forecastingTypeSettings;
        private String[] displayCurrency_type_info = new String[]{'displayCurrency',SOAP_M_URI,null,'0','1','false'};
        private String[] enableForecasts_type_info = new String[]{'enableForecasts',SOAP_M_URI,null,'0','1','false'};
        private String[] forecastingCategoryMappings_type_info = new String[]{'forecastingCategoryMappings',SOAP_M_URI,null,'0','-1','false'};
        private String[] forecastingTypeSettings_type_info = new String[]{'forecastingTypeSettings',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'displayCurrency','enableForecasts','forecastingCategoryMappings','forecastingTypeSettings'};
    }
    public class ReportAggregateReference {
        public String aggregate;
        private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregate'};
    }
    public class DashboardFilterOption {
        public String operator;
        public String[] values;
        private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'operator','values'};
    }
    public class ConnectedAppSamlConfig {
        public String acsUrl;
        public String certificate;
        public String encryptionCertificate;
        public String encryptionType;
        public String entityUrl;
        public String issuer;
        public String samlNameIdFormat;
        public String samlSubjectCustomAttr;
        public String samlSubjectType;
        private String[] acsUrl_type_info = new String[]{'acsUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
        private String[] encryptionCertificate_type_info = new String[]{'encryptionCertificate',SOAP_M_URI,null,'0','1','false'};
        private String[] encryptionType_type_info = new String[]{'encryptionType',SOAP_M_URI,null,'0','1','false'};
        private String[] entityUrl_type_info = new String[]{'entityUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] issuer_type_info = new String[]{'issuer',SOAP_M_URI,null,'0','1','false'};
        private String[] samlNameIdFormat_type_info = new String[]{'samlNameIdFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] samlSubjectCustomAttr_type_info = new String[]{'samlSubjectCustomAttr',SOAP_M_URI,null,'0','1','false'};
        private String[] samlSubjectType_type_info = new String[]{'samlSubjectType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'acsUrl','certificate','encryptionCertificate','encryptionType','entityUrl','issuer','samlNameIdFormat','samlSubjectCustomAttr','samlSubjectType'};
    }
    public class LiveChatSensitiveDataRule {
        public String actionType;
        public String description;
        public Integer enforceOn;
        public Boolean isEnabled;
        public String pattern;
        public String replacement;
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] enforceOn_type_info = new String[]{'enforceOn',SOAP_M_URI,null,'1','1','false'};
        private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] pattern_type_info = new String[]{'pattern',SOAP_M_URI,null,'1','1','false'};
        private String[] replacement_type_info = new String[]{'replacement',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionType','description','enforceOn','isEnabled','pattern','replacement'};
    }
    public class ApprovalStepRejectBehavior {
        public String type_x;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x'};
    }
    public class XOrgHubSharedObject {
        public String[] fields;
        public String name;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','name'};
    }
    public class createMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class ContentAsset extends Metadata {
        public String type = 'ContentAsset';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String format;
        public String language;
        public String masterLabel;
        public String originNetwork;
        public MetadataService.ContentAssetRelationships relationships;
        public MetadataService.ContentAssetVersions versions;
        private String[] format_type_info = new String[]{'format',SOAP_M_URI,null,'0','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] originNetwork_type_info = new String[]{'originNetwork',SOAP_M_URI,null,'0','1','false'};
        private String[] relationships_type_info = new String[]{'relationships',SOAP_M_URI,null,'0','1','false'};
        private String[] versions_type_info = new String[]{'versions',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'format','language','masterLabel','originNetwork','relationships','versions'};
    }
    public class DuplicateRuleFilterItem {
        public Integer sortOrder;
        public String table;
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
        private String[] table_type_info = new String[]{'table',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sortOrder','table'};
    }
    public class CustomPageWebLinkTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class describeMetadataResponse_element {
        public MetadataService.DescribeMetadataResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class CustomPermissionDependencyRequired {
        public String customPermission;
        public Boolean dependency;
        private String[] customPermission_type_info = new String[]{'customPermission',SOAP_M_URI,null,'1','1','false'};
        private String[] dependency_type_info = new String[]{'dependency',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customPermission','dependency'};
    }
    public class ProfileFieldLevelSecurity {
        public Boolean editable;
        public String field;
        public Boolean readable;
        private String[] editable_type_info = new String[]{'editable',SOAP_M_URI,null,'1','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] readable_type_info = new String[]{'readable',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'editable','field','readable'};
    }
    public class checkDeployStatus_element {
        public String asyncProcessId;
        public Boolean includeDetails;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeDetails_type_info = new String[]{'includeDetails',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeDetails'};
    }
    public virtual class MetadataWithContent extends Metadata {
        public String content;
    }
    public class SkillUserAssignments {
        public String[] user_x;
        private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'user_x'};
    }
    public class checkDeployStatusResponse_element {
        public MetadataService.DeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class DashboardComponent {
        public Boolean autoselectColumnsFromReport;
        public String chartAxisRange;
        public Double chartAxisRangeMax;
        public Double chartAxisRangeMin;
        public MetadataService.ChartSummary[] chartSummary;
        public String componentType;
        public MetadataService.DashboardFilterColumn[] dashboardFilterColumns;
        public MetadataService.DashboardTableColumn[] dashboardTableColumn;
        public String displayUnits;
        public String drillDownUrl;
        public Boolean drillEnabled;
        public Boolean drillToDetailEnabled;
        public Boolean enableHover;
        public Boolean expandOthers;
        public String footer;
        public Double gaugeMax;
        public Double gaugeMin;
        public String[] groupingColumn;
        public String header;
        public Double indicatorBreakpoint1;
        public Double indicatorBreakpoint2;
        public String indicatorHighColor;
        public String indicatorLowColor;
        public String indicatorMiddleColor;
        public String legendPosition;
        public Integer maxValuesDisplayed;
        public String metricLabel;
        public String page_x;
        public Integer pageHeightInPixels;
        public String report;
        public String scontrol;
        public Integer scontrolHeightInPixels;
        public Boolean showPercentage;
        public Boolean showPicturesOnCharts;
        public Boolean showPicturesOnTables;
        public Boolean showTotal;
        public Boolean showValues;
        public String sortBy;
        public String title;
        public Boolean useReportChart;
        private String[] autoselectColumnsFromReport_type_info = new String[]{'autoselectColumnsFromReport',SOAP_M_URI,null,'0','1','false'};
        private String[] chartAxisRange_type_info = new String[]{'chartAxisRange',SOAP_M_URI,null,'0','1','false'};
        private String[] chartAxisRangeMax_type_info = new String[]{'chartAxisRangeMax',SOAP_M_URI,null,'0','1','false'};
        private String[] chartAxisRangeMin_type_info = new String[]{'chartAxisRangeMin',SOAP_M_URI,null,'0','1','false'};
        private String[] chartSummary_type_info = new String[]{'chartSummary',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
        private String[] dashboardFilterColumns_type_info = new String[]{'dashboardFilterColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] dashboardTableColumn_type_info = new String[]{'dashboardTableColumn',SOAP_M_URI,null,'0','-1','false'};
        private String[] displayUnits_type_info = new String[]{'displayUnits',SOAP_M_URI,null,'0','1','false'};
        private String[] drillDownUrl_type_info = new String[]{'drillDownUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] drillEnabled_type_info = new String[]{'drillEnabled',SOAP_M_URI,null,'0','1','false'};
        private String[] drillToDetailEnabled_type_info = new String[]{'drillToDetailEnabled',SOAP_M_URI,null,'0','1','false'};
        private String[] enableHover_type_info = new String[]{'enableHover',SOAP_M_URI,null,'0','1','false'};
        private String[] expandOthers_type_info = new String[]{'expandOthers',SOAP_M_URI,null,'0','1','false'};
        private String[] footer_type_info = new String[]{'footer',SOAP_M_URI,null,'0','1','false'};
        private String[] gaugeMax_type_info = new String[]{'gaugeMax',SOAP_M_URI,null,'0','1','false'};
        private String[] gaugeMin_type_info = new String[]{'gaugeMin',SOAP_M_URI,null,'0','1','false'};
        private String[] groupingColumn_type_info = new String[]{'groupingColumn',SOAP_M_URI,null,'0','-1','false'};
        private String[] header_type_info = new String[]{'header',SOAP_M_URI,null,'0','1','false'};
        private String[] indicatorBreakpoint1_type_info = new String[]{'indicatorBreakpoint1',SOAP_M_URI,null,'0','1','false'};
        private String[] indicatorBreakpoint2_type_info = new String[]{'indicatorBreakpoint2',SOAP_M_URI,null,'0','1','false'};
        private String[] indicatorHighColor_type_info = new String[]{'indicatorHighColor',SOAP_M_URI,null,'0','1','false'};
        private String[] indicatorLowColor_type_info = new String[]{'indicatorLowColor',SOAP_M_URI,null,'0','1','false'};
        private String[] indicatorMiddleColor_type_info = new String[]{'indicatorMiddleColor',SOAP_M_URI,null,'0','1','false'};
        private String[] legendPosition_type_info = new String[]{'legendPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] maxValuesDisplayed_type_info = new String[]{'maxValuesDisplayed',SOAP_M_URI,null,'0','1','false'};
        private String[] metricLabel_type_info = new String[]{'metricLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] pageHeightInPixels_type_info = new String[]{'pageHeightInPixels',SOAP_M_URI,null,'0','1','false'};
        private String[] report_type_info = new String[]{'report',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrolHeightInPixels_type_info = new String[]{'scontrolHeightInPixels',SOAP_M_URI,null,'0','1','false'};
        private String[] showPercentage_type_info = new String[]{'showPercentage',SOAP_M_URI,null,'0','1','false'};
        private String[] showPicturesOnCharts_type_info = new String[]{'showPicturesOnCharts',SOAP_M_URI,null,'0','1','false'};
        private String[] showPicturesOnTables_type_info = new String[]{'showPicturesOnTables',SOAP_M_URI,null,'0','1','false'};
        private String[] showTotal_type_info = new String[]{'showTotal',SOAP_M_URI,null,'0','1','false'};
        private String[] showValues_type_info = new String[]{'showValues',SOAP_M_URI,null,'0','1','false'};
        private String[] sortBy_type_info = new String[]{'sortBy',SOAP_M_URI,null,'0','1','false'};
        private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'0','1','false'};
        private String[] useReportChart_type_info = new String[]{'useReportChart',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'autoselectColumnsFromReport','chartAxisRange','chartAxisRangeMax','chartAxisRangeMin','chartSummary','componentType','dashboardFilterColumns','dashboardTableColumn','displayUnits','drillDownUrl','drillEnabled','drillToDetailEnabled','enableHover','expandOthers','footer','gaugeMax','gaugeMin','groupingColumn','header','indicatorBreakpoint1','indicatorBreakpoint2','indicatorHighColor','indicatorLowColor','indicatorMiddleColor','legendPosition','maxValuesDisplayed','metricLabel','page_x','pageHeightInPixels','report','scontrol','scontrolHeightInPixels','showPercentage','showPicturesOnCharts','showPicturesOnTables','showTotal','showValues','sortBy','title','useReportChart'};
    }
    public class ReportColorRange {
        public String aggregate;
        public String columnName;
        public Double highBreakpoint;
        public String highColor;
        public Double lowBreakpoint;
        public String lowColor;
        public String midColor;
        private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'0','1','false'};
        private String[] columnName_type_info = new String[]{'columnName',SOAP_M_URI,null,'1','1','false'};
        private String[] highBreakpoint_type_info = new String[]{'highBreakpoint',SOAP_M_URI,null,'0','1','false'};
        private String[] highColor_type_info = new String[]{'highColor',SOAP_M_URI,null,'1','1','false'};
        private String[] lowBreakpoint_type_info = new String[]{'lowBreakpoint',SOAP_M_URI,null,'0','1','false'};
        private String[] lowColor_type_info = new String[]{'lowColor',SOAP_M_URI,null,'1','1','false'};
        private String[] midColor_type_info = new String[]{'midColor',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregate','columnName','highBreakpoint','highColor','lowBreakpoint','lowColor','midColor'};
    }
    public class OrganizationSettingsDetail {
        public String settingName;
        public Boolean settingValue;
        private String[] settingName_type_info = new String[]{'settingName',SOAP_M_URI,null,'1','1','false'};
        private String[] settingValue_type_info = new String[]{'settingValue',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'settingName','settingValue'};
    }
    public class SummaryLayout {
        public String masterLabel;
        public Integer sizeX;
        public Integer sizeY;
        public Integer sizeZ;
        public MetadataService.SummaryLayoutItem[] summaryLayoutItems;
        public String summaryLayoutStyle;
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] sizeX_type_info = new String[]{'sizeX',SOAP_M_URI,null,'1','1','false'};
        private String[] sizeY_type_info = new String[]{'sizeY',SOAP_M_URI,null,'0','1','false'};
        private String[] sizeZ_type_info = new String[]{'sizeZ',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryLayoutItems_type_info = new String[]{'summaryLayoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] summaryLayoutStyle_type_info = new String[]{'summaryLayoutStyle',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','sizeX','sizeY','sizeZ','summaryLayoutItems','summaryLayoutStyle'};
    }
    public class GlobalValueSet extends Metadata {
        public String type = 'GlobalValueSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CustomValue[] customValue;
        public String description;
        public String masterLabel;
        public Boolean sorted;
        private String[] customValue_type_info = new String[]{'customValue',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customValue','description','masterLabel','sorted'};
    }
    public class QuickActionLayout {
        public String layoutSectionStyle;
        public MetadataService.QuickActionLayoutColumn[] quickActionLayoutColumns;
        private String[] layoutSectionStyle_type_info = new String[]{'layoutSectionStyle',SOAP_M_URI,null,'1','1','false'};
        private String[] quickActionLayoutColumns_type_info = new String[]{'quickActionLayoutColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutSectionStyle','quickActionLayoutColumns'};
    }
    public class Territory2Type extends Metadata {
        public String type = 'Territory2Type';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String name;
        public Integer priority;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] priority_type_info = new String[]{'priority',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','name','priority'};
    }
    public class listMetadataResponse_element {
        public MetadataService.FileProperties[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class SamlSsoConfig extends Metadata {
        public String type = 'SamlSsoConfig';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String attributeName;
        public String attributeNameIdFormat;
        public String decryptionCertificate;
        public String errorUrl;
        public String executionUserId;
        public String identityLocation;
        public String identityMapping;
        public String issuer;
        public String loginUrl;
        public String logoutUrl;
        public String name;
        public String oauthTokenEndpoint;
        public Boolean redirectBinding;
        public String requestSignatureMethod;
        public String salesforceLoginUrl;
        public String samlEntityId;
        public String samlJitHandlerId;
        public String samlVersion;
        public Boolean userProvisioning;
        public String validationCert;
        private String[] attributeName_type_info = new String[]{'attributeName',SOAP_M_URI,null,'0','1','false'};
        private String[] attributeNameIdFormat_type_info = new String[]{'attributeNameIdFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] decryptionCertificate_type_info = new String[]{'decryptionCertificate',SOAP_M_URI,null,'0','1','false'};
        private String[] errorUrl_type_info = new String[]{'errorUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] executionUserId_type_info = new String[]{'executionUserId',SOAP_M_URI,null,'0','1','false'};
        private String[] identityLocation_type_info = new String[]{'identityLocation',SOAP_M_URI,null,'1','1','false'};
        private String[] identityMapping_type_info = new String[]{'identityMapping',SOAP_M_URI,null,'1','1','false'};
        private String[] issuer_type_info = new String[]{'issuer',SOAP_M_URI,null,'1','1','false'};
        private String[] loginUrl_type_info = new String[]{'loginUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] logoutUrl_type_info = new String[]{'logoutUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] oauthTokenEndpoint_type_info = new String[]{'oauthTokenEndpoint',SOAP_M_URI,null,'0','1','false'};
        private String[] redirectBinding_type_info = new String[]{'redirectBinding',SOAP_M_URI,null,'0','1','false'};
        private String[] requestSignatureMethod_type_info = new String[]{'requestSignatureMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] salesforceLoginUrl_type_info = new String[]{'salesforceLoginUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] samlEntityId_type_info = new String[]{'samlEntityId',SOAP_M_URI,null,'1','1','false'};
        private String[] samlJitHandlerId_type_info = new String[]{'samlJitHandlerId',SOAP_M_URI,null,'0','1','false'};
        private String[] samlVersion_type_info = new String[]{'samlVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] userProvisioning_type_info = new String[]{'userProvisioning',SOAP_M_URI,null,'0','1','false'};
        private String[] validationCert_type_info = new String[]{'validationCert',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'attributeName','attributeNameIdFormat','decryptionCertificate','errorUrl','executionUserId','identityLocation','identityMapping','issuer','loginUrl','logoutUrl','name','oauthTokenEndpoint','redirectBinding','requestSignatureMethod','salesforceLoginUrl','samlEntityId','samlJitHandlerId','samlVersion','userProvisioning','validationCert'};
    }
    public class describeValueType_element {
        public String type_x;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x'};
    }
    public class ReputationLevels {
        public MetadataService.ChatterAnswersReputationLevel[] chatterAnswersReputationLevels;
        public MetadataService.IdeaReputationLevel[] ideaReputationLevels;
        private String[] chatterAnswersReputationLevels_type_info = new String[]{'chatterAnswersReputationLevels',SOAP_M_URI,null,'0','-1','false'};
        private String[] ideaReputationLevels_type_info = new String[]{'ideaReputationLevels',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'chatterAnswersReputationLevels','ideaReputationLevels'};
    }
    public class SidebarComponent {
        public String componentType;
        public Integer height;
        public String label;
        public String lookup;
        public String page_x;
        public MetadataService.RelatedList[] relatedLists;
        public String unit;
        public Integer width;
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] lookup_type_info = new String[]{'lookup',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] unit_type_info = new String[]{'unit',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','label','lookup','page_x','relatedLists','unit','width'};
    }
    public class TransactionSecurityNotification {
        public Boolean inApp;
        public Boolean sendEmail;
        public String user_x;
        private String[] inApp_type_info = new String[]{'inApp',SOAP_M_URI,null,'1','1','false'};
        private String[] sendEmail_type_info = new String[]{'sendEmail',SOAP_M_URI,null,'1','1','false'};
        private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'inApp','sendEmail','user_x'};
    }
    public class ReportColumn {
        public String[] aggregateTypes;
        public String field;
        public Boolean reverseColors;
        public Boolean showChanges;
        private String[] aggregateTypes_type_info = new String[]{'aggregateTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] reverseColors_type_info = new String[]{'reverseColors',SOAP_M_URI,null,'0','1','false'};
        private String[] showChanges_type_info = new String[]{'showChanges',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'aggregateTypes','field','reverseColors','showChanges'};
    }
    public class BusinessHoursSettings extends Metadata {
        public String type = 'BusinessHoursSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.BusinessHoursEntry[] businessHours;
        public MetadataService.Holiday[] holidays;
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','-1','false'};
        private String[] holidays_type_info = new String[]{'holidays',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'businessHours','holidays'};
    }
    public class FieldSetItem {
        public String field;
        public Boolean isFieldManaged;
        public Boolean isRequired;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] isFieldManaged_type_info = new String[]{'isFieldManaged',SOAP_M_URI,null,'0','1','false'};
        private String[] isRequired_type_info = new String[]{'isRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','isFieldManaged','isRequired'};
    }
    public class ProfileUserPermission {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabled','name'};
    }
    public class FindSimilarOppFilter {
        public String[] similarOpportunitiesDisplayColumns;
        public String[] similarOpportunitiesMatchFields;
        private String[] similarOpportunitiesDisplayColumns_type_info = new String[]{'similarOpportunitiesDisplayColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] similarOpportunitiesMatchFields_type_info = new String[]{'similarOpportunitiesMatchFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'similarOpportunitiesDisplayColumns','similarOpportunitiesMatchFields'};
    }
    public class ReportAggregate {
        public String acrossGroupingContext;
        public String calculatedFormula;
        public String datatype;
        public String description;
        public String developerName;
        public String downGroupingContext;
        public Boolean isActive;
        public Boolean isCrossBlock;
        public String masterLabel;
        public String reportType;
        public Integer scale;
        private String[] acrossGroupingContext_type_info = new String[]{'acrossGroupingContext',SOAP_M_URI,null,'0','1','false'};
        private String[] calculatedFormula_type_info = new String[]{'calculatedFormula',SOAP_M_URI,null,'1','1','false'};
        private String[] datatype_type_info = new String[]{'datatype',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] downGroupingContext_type_info = new String[]{'downGroupingContext',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] isCrossBlock_type_info = new String[]{'isCrossBlock',SOAP_M_URI,null,'0','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] reportType_type_info = new String[]{'reportType',SOAP_M_URI,null,'0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'acrossGroupingContext','calculatedFormula','datatype','description','developerName','downGroupingContext','isActive','isCrossBlock','masterLabel','reportType','scale'};
    }
    public class ContractSettings extends Metadata {
        public String type = 'ContractSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean autoCalculateEndDate;
        public String autoExpirationDelay;
        public String autoExpirationRecipient;
        public Boolean autoExpireContracts;
        public Boolean enableContractHistoryTracking;
        public Boolean notifyOwnersOnContractExpiration;
        private String[] autoCalculateEndDate_type_info = new String[]{'autoCalculateEndDate',SOAP_M_URI,null,'0','1','false'};
        private String[] autoExpirationDelay_type_info = new String[]{'autoExpirationDelay',SOAP_M_URI,null,'0','1','false'};
        private String[] autoExpirationRecipient_type_info = new String[]{'autoExpirationRecipient',SOAP_M_URI,null,'0','1','false'};
        private String[] autoExpireContracts_type_info = new String[]{'autoExpireContracts',SOAP_M_URI,null,'0','1','false'};
        private String[] enableContractHistoryTracking_type_info = new String[]{'enableContractHistoryTracking',SOAP_M_URI,null,'0','1','false'};
        private String[] notifyOwnersOnContractExpiration_type_info = new String[]{'notifyOwnersOnContractExpiration',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'autoCalculateEndDate','autoExpirationDelay','autoExpirationRecipient','autoExpireContracts','enableContractHistoryTracking','notifyOwnersOnContractExpiration'};
    }
    public class EscalationRules extends Metadata {
        public String type = 'EscalationRules';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.EscalationRule[] escalationRule;
        private String[] escalationRule_type_info = new String[]{'escalationRule',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'escalationRule'};
    }
    public class NetworkTabSet {
        public String[] customTab;
        public String defaultTab;
        public String[] standardTab;
        private String[] customTab_type_info = new String[]{'customTab',SOAP_M_URI,null,'0','-1','false'};
        private String[] defaultTab_type_info = new String[]{'defaultTab',SOAP_M_URI,null,'1','1','false'};
        private String[] standardTab_type_info = new String[]{'standardTab',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customTab','defaultTab','standardTab'};
    }
    public class EmbeddedServiceLiveAgent {
        public String embeddedServiceConfig;
        public String liveAgentChatUrl;
        public String liveAgentContentUrl;
        public String liveChatButton;
        public String liveChatDeployment;
        public String masterLabel;
        private String[] embeddedServiceConfig_type_info = new String[]{'embeddedServiceConfig',SOAP_M_URI,null,'1','1','false'};
        private String[] liveAgentChatUrl_type_info = new String[]{'liveAgentChatUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] liveAgentContentUrl_type_info = new String[]{'liveAgentContentUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] liveChatButton_type_info = new String[]{'liveChatButton',SOAP_M_URI,null,'1','1','false'};
        private String[] liveChatDeployment_type_info = new String[]{'liveChatDeployment',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'embeddedServiceConfig','liveAgentChatUrl','liveAgentContentUrl','liveChatButton','liveChatDeployment','masterLabel'};
    }
    public class CustomField extends Metadata {
        public String type = 'CustomField';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean caseSensitive;
        public String customDataType;
        public String defaultValue;
        public String deleteConstraint;
        public Boolean deprecated;
        public String description;
        public String displayFormat;
        public Boolean encrypted;
        public Boolean escapeMarkup;
        public String externalDeveloperName;
        public Boolean externalId;
        public String fieldManageability;
        public String formula;
        public String formulaTreatBlanksAs;
        public String inlineHelpText;
        public Boolean isConvertLeadDisabled;
        public Boolean isFilteringDisabled;
        public Boolean isNameField;
        public Boolean isSortingDisabled;
        public String label;
        public Integer length;
        public MetadataService.LookupFilter lookupFilter;
        public String maskChar;
        public String maskType;
        public MetadataService.Picklist picklist;
        public Boolean populateExistingRows;
        public Integer precision;
        public String referenceTargetField;
        public String referenceTo;
        public String relationshipLabel;
        public String relationshipName;
        public Integer relationshipOrder;
        public Boolean reparentableMasterDetail;
        public Boolean required;
        public Boolean restrictedAdminField;
        public Integer scale;
        public Integer startingNumber;
        public Boolean stripMarkup;
        public String summarizedField;
        public MetadataService.FilterItem[] summaryFilterItems;
        public String summaryForeignKey;
        public String summaryOperation;
        public Boolean trackFeedHistory;
        public Boolean trackHistory;
        public Boolean trackTrending;
        public String type_x;
        public Boolean unique;
        public MetadataService.ValueSet valueSet;
        public Integer visibleLines;
        public Boolean writeRequiresMasterRead;
        public Boolean displayLocationInDecimal;
        private String[] caseSensitive_type_info = new String[]{'caseSensitive',SOAP_M_URI,null,'0','1','false'};
        private String[] customDataType_type_info = new String[]{'customDataType',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'0','1','false'};
        private String[] deleteConstraint_type_info = new String[]{'deleteConstraint',SOAP_M_URI,null,'0','1','false'};
        private String[] deprecated_type_info = new String[]{'deprecated',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayFormat_type_info = new String[]{'displayFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] encrypted_type_info = new String[]{'encrypted',SOAP_M_URI,null,'0','1','false'};
        private String[] escapeMarkup_type_info = new String[]{'escapeMarkup',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDeveloperName_type_info = new String[]{'externalDeveloperName',SOAP_M_URI,null,'0','1','false'};
        private String[] externalId_type_info = new String[]{'externalId',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldManageability_type_info = new String[]{'fieldManageability',SOAP_M_URI,null,'0','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] formulaTreatBlanksAs_type_info = new String[]{'formulaTreatBlanksAs',SOAP_M_URI,null,'0','1','false'};
        private String[] inlineHelpText_type_info = new String[]{'inlineHelpText',SOAP_M_URI,null,'0','1','false'};
        private String[] isConvertLeadDisabled_type_info = new String[]{'isConvertLeadDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] isFilteringDisabled_type_info = new String[]{'isFilteringDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] isNameField_type_info = new String[]{'isNameField',SOAP_M_URI,null,'0','1','false'};
        private String[] isSortingDisabled_type_info = new String[]{'isSortingDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] length_type_info = new String[]{'length',SOAP_M_URI,null,'0','1','false'};
        private String[] lookupFilter_type_info = new String[]{'lookupFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] maskChar_type_info = new String[]{'maskChar',SOAP_M_URI,null,'0','1','false'};
        private String[] maskType_type_info = new String[]{'maskType',SOAP_M_URI,null,'0','1','false'};
        private String[] picklist_type_info = new String[]{'picklist',SOAP_M_URI,null,'0','1','false'};
        private String[] populateExistingRows_type_info = new String[]{'populateExistingRows',SOAP_M_URI,null,'0','1','false'};
        private String[] precision_type_info = new String[]{'precision',SOAP_M_URI,null,'0','1','false'};
        private String[] referenceTargetField_type_info = new String[]{'referenceTargetField',SOAP_M_URI,null,'0','1','false'};
        private String[] referenceTo_type_info = new String[]{'referenceTo',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipLabel_type_info = new String[]{'relationshipLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipName_type_info = new String[]{'relationshipName',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipOrder_type_info = new String[]{'relationshipOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] reparentableMasterDetail_type_info = new String[]{'reparentableMasterDetail',SOAP_M_URI,null,'0','1','false'};
        private String[] required_type_info = new String[]{'required',SOAP_M_URI,null,'0','1','false'};
        private String[] restrictedAdminField_type_info = new String[]{'restrictedAdminField',SOAP_M_URI,null,'0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
        private String[] startingNumber_type_info = new String[]{'startingNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] stripMarkup_type_info = new String[]{'stripMarkup',SOAP_M_URI,null,'0','1','false'};
        private String[] summarizedField_type_info = new String[]{'summarizedField',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryFilterItems_type_info = new String[]{'summaryFilterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] summaryForeignKey_type_info = new String[]{'summaryForeignKey',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryOperation_type_info = new String[]{'summaryOperation',SOAP_M_URI,null,'0','1','false'};
        private String[] trackFeedHistory_type_info = new String[]{'trackFeedHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] trackHistory_type_info = new String[]{'trackHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] trackTrending_type_info = new String[]{'trackTrending',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] unique_type_info = new String[]{'unique',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSet_type_info = new String[]{'valueSet',SOAP_M_URI,null,'0','1','false'};
        private String[] visibleLines_type_info = new String[]{'visibleLines',SOAP_M_URI,null,'0','1','false'};
        private String[] writeRequiresMasterRead_type_info = new String[]{'writeRequiresMasterRead',SOAP_M_URI,null,'0','1','false'};
        private String[] displayLocationInDecimal_type_info = new String[]{'displayLocationInDecimal',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'caseSensitive','customDataType','defaultValue','deleteConstraint','deprecated','description','displayFormat','encrypted','escapeMarkup','externalDeveloperName','externalId','fieldManageability','formula','formulaTreatBlanksAs','inlineHelpText','isConvertLeadDisabled','isFilteringDisabled','isNameField','isSortingDisabled','label','length','lookupFilter','maskChar','maskType','picklist','populateExistingRows','precision','referenceTargetField','referenceTo','relationshipLabel','relationshipName','relationshipOrder','reparentableMasterDetail','required','restrictedAdminField','scale','startingNumber','stripMarkup','summarizedField','summaryFilterItems','summaryForeignKey','summaryOperation','trackFeedHistory','trackHistory','trackTrending','type_x','unique','valueSet','visibleLines','writeRequiresMasterRead','displayLocationInDecimal'};
    }
    public class KeywordList {
        public String description;
        public MetadataService.Keyword[] keywords;
        public String masterLabel;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] keywords_type_info = new String[]{'keywords',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','keywords','masterLabel'};
    }
    public class MatchingRuleItem {
        public String blankValueBehavior;
        public String fieldName;
        public String matchingMethod;
        private String[] blankValueBehavior_type_info = new String[]{'blankValueBehavior',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'1','1','false'};
        private String[] matchingMethod_type_info = new String[]{'matchingMethod',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'blankValueBehavior','fieldName','matchingMethod'};
    }
    public class RuleEntry {
        public String assignedTo;
        public String assignedToType;
        public String booleanFilter;
        public String businessHours;
        public String businessHoursSource;
        public MetadataService.FilterItem[] criteriaItems;
        public Boolean disableEscalationWhenModified;
        public MetadataService.EscalationAction[] escalationAction;
        public String escalationStartTime;
        public String formula;
        public Boolean notifyCcRecipients;
        public Boolean overrideExistingTeams;
        public String replyToEmail;
        public String senderEmail;
        public String senderName;
        public String[] team;
        public String template;
        private String[] assignedTo_type_info = new String[]{'assignedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] assignedToType_type_info = new String[]{'assignedToType',SOAP_M_URI,null,'0','1','false'};
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','1','false'};
        private String[] businessHoursSource_type_info = new String[]{'businessHoursSource',SOAP_M_URI,null,'0','1','false'};
        private String[] criteriaItems_type_info = new String[]{'criteriaItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] disableEscalationWhenModified_type_info = new String[]{'disableEscalationWhenModified',SOAP_M_URI,null,'0','1','false'};
        private String[] escalationAction_type_info = new String[]{'escalationAction',SOAP_M_URI,null,'0','-1','false'};
        private String[] escalationStartTime_type_info = new String[]{'escalationStartTime',SOAP_M_URI,null,'0','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] notifyCcRecipients_type_info = new String[]{'notifyCcRecipients',SOAP_M_URI,null,'0','1','false'};
        private String[] overrideExistingTeams_type_info = new String[]{'overrideExistingTeams',SOAP_M_URI,null,'0','1','false'};
        private String[] replyToEmail_type_info = new String[]{'replyToEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] senderEmail_type_info = new String[]{'senderEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] senderName_type_info = new String[]{'senderName',SOAP_M_URI,null,'0','1','false'};
        private String[] team_type_info = new String[]{'team',SOAP_M_URI,null,'0','-1','false'};
        private String[] template_type_info = new String[]{'template',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assignedTo','assignedToType','booleanFilter','businessHours','businessHoursSource','criteriaItems','disableEscalationWhenModified','escalationAction','escalationStartTime','formula','notifyCcRecipients','overrideExistingTeams','replyToEmail','senderEmail','senderName','team','template'};
    }
    public class CustomObjectTranslation extends Metadata {
        public String type = 'CustomObjectTranslation';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ObjectNameCaseValue[] caseValues;
        public MetadataService.CustomFieldTranslation[] fields;
        public String gender;
        public MetadataService.LayoutTranslation[] layouts;
        public String nameFieldLabel;
        public MetadataService.QuickActionTranslation[] quickActions;
        public MetadataService.RecordTypeTranslation[] recordTypes;
        public MetadataService.SharingReasonTranslation[] sharingReasons;
        public MetadataService.StandardFieldTranslation[] standardFields;
        public String startsWith;
        public MetadataService.ValidationRuleTranslation[] validationRules;
        public MetadataService.WebLinkTranslation[] webLinks;
        public MetadataService.WorkflowTaskTranslation[] workflowTasks;
        private String[] caseValues_type_info = new String[]{'caseValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] gender_type_info = new String[]{'gender',SOAP_M_URI,null,'0','1','false'};
        private String[] layouts_type_info = new String[]{'layouts',SOAP_M_URI,null,'0','-1','false'};
        private String[] nameFieldLabel_type_info = new String[]{'nameFieldLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActions_type_info = new String[]{'quickActions',SOAP_M_URI,null,'0','-1','false'};
        private String[] recordTypes_type_info = new String[]{'recordTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharingReasons_type_info = new String[]{'sharingReasons',SOAP_M_URI,null,'0','-1','false'};
        private String[] standardFields_type_info = new String[]{'standardFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] startsWith_type_info = new String[]{'startsWith',SOAP_M_URI,null,'0','1','false'};
        private String[] validationRules_type_info = new String[]{'validationRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] webLinks_type_info = new String[]{'webLinks',SOAP_M_URI,null,'0','-1','false'};
        private String[] workflowTasks_type_info = new String[]{'workflowTasks',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'caseValues','fields','gender','layouts','nameFieldLabel','quickActions','recordTypes','sharingReasons','standardFields','startsWith','validationRules','webLinks','workflowTasks'};
    }
    public class ForecastingTypeSettings {
        public Boolean active;
        public MetadataService.AdjustmentsSettings adjustmentsSettings;
        public String[] displayedCategoryApiNames;
        public MetadataService.ForecastRangeSettings forecastRangeSettings;
        public String[] forecastedCategoryApiNames;
        public Boolean isAmount;
        public Boolean isAvailable;
        public Boolean isQuantity;
        public String[] managerAdjustableCategoryApiNames;
        public String masterLabel;
        public String name;
        public MetadataService.OpportunityListFieldsLabelMapping[] opportunityListFieldsLabelMappings;
        public MetadataService.OpportunityListFieldsSelectedSettings opportunityListFieldsSelectedSettings;
        public MetadataService.OpportunityListFieldsUnselectedSettings opportunityListFieldsUnselectedSettings;
        public String[] ownerAdjustableCategoryApiNames;
        public MetadataService.QuotasSettings quotasSettings;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] adjustmentsSettings_type_info = new String[]{'adjustmentsSettings',SOAP_M_URI,null,'1','1','false'};
        private String[] displayedCategoryApiNames_type_info = new String[]{'displayedCategoryApiNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] forecastRangeSettings_type_info = new String[]{'forecastRangeSettings',SOAP_M_URI,null,'1','1','false'};
        private String[] forecastedCategoryApiNames_type_info = new String[]{'forecastedCategoryApiNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] isAmount_type_info = new String[]{'isAmount',SOAP_M_URI,null,'1','1','false'};
        private String[] isAvailable_type_info = new String[]{'isAvailable',SOAP_M_URI,null,'1','1','false'};
        private String[] isQuantity_type_info = new String[]{'isQuantity',SOAP_M_URI,null,'1','1','false'};
        private String[] managerAdjustableCategoryApiNames_type_info = new String[]{'managerAdjustableCategoryApiNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] opportunityListFieldsLabelMappings_type_info = new String[]{'opportunityListFieldsLabelMappings',SOAP_M_URI,null,'0','-1','false'};
        private String[] opportunityListFieldsSelectedSettings_type_info = new String[]{'opportunityListFieldsSelectedSettings',SOAP_M_URI,null,'1','1','false'};
        private String[] opportunityListFieldsUnselectedSettings_type_info = new String[]{'opportunityListFieldsUnselectedSettings',SOAP_M_URI,null,'1','1','false'};
        private String[] ownerAdjustableCategoryApiNames_type_info = new String[]{'ownerAdjustableCategoryApiNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] quotasSettings_type_info = new String[]{'quotasSettings',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','adjustmentsSettings','displayedCategoryApiNames','forecastRangeSettings','forecastedCategoryApiNames','isAmount','isAvailable','isQuantity','managerAdjustableCategoryApiNames','masterLabel','name','opportunityListFieldsLabelMappings','opportunityListFieldsSelectedSettings','opportunityListFieldsUnselectedSettings','ownerAdjustableCategoryApiNames','quotasSettings'};
    }
    public class MetadataPort {
        public String metadataAPIVersion = '45.0';
        public String endpoint_x = System.URL.getOrgDomainUrl().toExternalForm() + ConfigUtil.SOAP_ENDPOINT_PREFIX + metadataAPIVersion;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x = 120000; // max timeout 2 minutes
        public MetadataService.SessionHeader_element SessionHeader;
        public MetadataService.DebuggingInfo_element DebuggingInfo;
        public MetadataService.DebuggingHeader_element DebuggingHeader;
        public MetadataService.CallOptions_element CallOptions;
        public MetadataService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};

        public void setMetadataAPIVersion(String apiVersion) {
            this.metadataAPIVersion = apiVersion;
            this.endpoint_x = System.URL.getOrgDomainUrl().toExternalForm() + ConfigUtil.SOAP_ENDPOINT_PREFIX + metadataAPIVersion;
        }
        public void setEndpointAndMetadataAPIVersion(String endpoint, String apiVersion) {
            this.metadataAPIVersion = apiVersion;
            this.endpoint_x = endpoint + ConfigUtil.SOAP_ENDPOINT_PREFIX + apiVersion;
        }
        public MetadataService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
            MetadataService.deleteMetadata_element request_x = new MetadataService.deleteMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataService.deleteMetadataResponse_element response_x;
            Map<String, MetadataService.deleteMetadataResponse_element> response_map_x = new Map<String, MetadataService.deleteMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deleteMetadata',
              SOAP_M_URI,
              'deleteMetadataResponse',
              'MetadataService.deleteMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
            MetadataService.renameMetadata_element request_x = new MetadataService.renameMetadata_element();
            request_x.type_x = type_x;
            request_x.oldFullName = oldFullName;
            request_x.newFullName = newFullName;
            MetadataService.renameMetadataResponse_element response_x;
            Map<String, MetadataService.renameMetadataResponse_element> response_map_x = new Map<String, MetadataService.renameMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'renameMetadata',
              SOAP_M_URI,
              'renameMetadataResponse',
              'MetadataService.renameMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.updateMetadata_element request_x = new MetadataService.updateMetadata_element();
            request_x.metadata = metadata;
            MetadataService.updateMetadataResponse_element response_x;
            Map<String, MetadataService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataService.updateMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'updateMetadata',
              SOAP_M_URI,
              'updateMetadataResponse',
              'MetadataService.updateMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            MetadataService.describeMetadata_element request_x = new MetadataService.describeMetadata_element();
            request_x.asOfVersion = asOfVersion;
            MetadataService.describeMetadataResponse_element response_x;
            Map<String, MetadataService.describeMetadataResponse_element> response_map_x = new Map<String, MetadataService.describeMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeMetadata',
              SOAP_M_URI,
              'describeMetadataResponse',
              'MetadataService.describeMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
            MetadataService.checkDeployStatus_element request_x = new MetadataService.checkDeployStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeDetails = includeDetails;
            MetadataService.checkDeployStatusResponse_element response_x;
            Map<String, MetadataService.checkDeployStatusResponse_element> response_map_x = new Map<String, MetadataService.checkDeployStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkDeployStatus',
              SOAP_M_URI,
              'checkDeployStatusResponse',
              'MetadataService.checkDeployStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.RetrieveResult checkRetrieveStatus(String asyncProcessId,Boolean includeZip) {
            MetadataService.checkRetrieveStatus_element request_x = new MetadataService.checkRetrieveStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeZip = includeZip;
            MetadataService.checkRetrieveStatusResponse_element response_x;
            Map<String, MetadataService.checkRetrieveStatusResponse_element> response_map_x = new Map<String, MetadataService.checkRetrieveStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkRetrieveStatus',
              SOAP_M_URI,
              'checkRetrieveStatusResponse',
              'MetadataService.checkRetrieveStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.AsyncResult retrieve(MetadataService.RetrieveRequest retrieveRequest) {
            MetadataService.retrieve_element request_x = new MetadataService.retrieve_element();
            request_x.retrieveRequest = retrieveRequest;
            MetadataService.retrieveResponse_element response_x;
            Map<String, MetadataService.retrieveResponse_element> response_map_x = new Map<String, MetadataService.retrieveResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'retrieve',
              SOAP_M_URI,
              'retrieveResponse',
              'MetadataService.retrieveResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.CancelDeployResult cancelDeploy(String String_x) {
            MetadataService.cancelDeploy_element request_x = new MetadataService.cancelDeploy_element();
            request_x.String_x = String_x;
            MetadataService.cancelDeployResponse_element response_x;
            Map<String, MetadataService.cancelDeployResponse_element> response_map_x = new Map<String, MetadataService.cancelDeployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'cancelDeploy',
              SOAP_M_URI,
              'cancelDeployResponse',
              'MetadataService.cancelDeployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public String deployRecentValidation(String validationId) {
            MetadataService.deployRecentValidation_element request_x = new MetadataService.deployRecentValidation_element();
            request_x.validationId = validationId;
            MetadataService.deployRecentValidationResponse_element response_x;
            Map<String, MetadataService.deployRecentValidationResponse_element> response_map_x = new Map<String, MetadataService.deployRecentValidationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deployRecentValidation',
              SOAP_M_URI,
              'deployRecentValidationResponse',
              'MetadataService.deployRecentValidationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.DescribeValueTypeResult describeValueType(String type_x) {
            MetadataService.describeValueType_element request_x = new MetadataService.describeValueType_element();
            request_x.type_x = type_x;
            MetadataService.describeValueTypeResponse_element response_x;
            Map<String, MetadataService.describeValueTypeResponse_element> response_map_x = new Map<String, MetadataService.describeValueTypeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeValueType',
              SOAP_M_URI,
              'describeValueTypeResponse',
              'MetadataService.describeValueTypeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.SaveResult[] createMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.createMetadata_element request_x = new MetadataService.createMetadata_element();
            request_x.metadata = metadata;
            MetadataService.createMetadataResponse_element response_x;
            Map<String, MetadataService.createMetadataResponse_element> response_map_x = new Map<String, MetadataService.createMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'createMetadata',
              SOAP_M_URI,
              'createMetadataResponse',
              'MetadataService.createMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.AsyncResult deploy(String ZipFile,MetadataService.DeployOptions DeployOptions) {
            MetadataService.deploy_element request_x = new MetadataService.deploy_element();
            request_x.ZipFile = ZipFile;
            request_x.DeployOptions = DeployOptions;
            MetadataService.deployResponse_element response_x;
            Map<String, MetadataService.deployResponse_element> response_map_x = new Map<String, MetadataService.deployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deploy',
              SOAP_M_URI,
              'deployResponse',
              'MetadataService.deployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
            MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataService.IReadResponseElement response_x;
            Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'readMetadata',
              SOAP_M_URI,
              'readMetadataResponse',
              'MetadataService.read' + type_x + 'Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.getResult();
        }
        public MetadataService.UpsertResult[] upsertMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.upsertMetadata_element request_x = new MetadataService.upsertMetadata_element();
            request_x.metadata = metadata;
            MetadataService.upsertMetadataResponse_element response_x;
            Map<String, MetadataService.upsertMetadataResponse_element> response_map_x = new Map<String, MetadataService.upsertMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'upsertMetadata',
              SOAP_M_URI,
              'upsertMetadataResponse',
              'MetadataService.upsertMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.FileProperties[] listMetadata(MetadataService.ListMetadataQuery[] queries,Double asOfVersion) {
            MetadataService.listMetadata_element request_x = new MetadataService.listMetadata_element();
            request_x.queries = queries;
            request_x.asOfVersion = asOfVersion;
            MetadataService.listMetadataResponse_element response_x;
            Map<String, MetadataService.listMetadataResponse_element> response_map_x = new Map<String, MetadataService.listMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'listMetadata',
              SOAP_M_URI,
              'listMetadataResponse',
              'MetadataService.listMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
}