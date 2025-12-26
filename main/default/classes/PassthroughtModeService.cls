public with sharing class PassthroughtModeService {

    private static final String EXCEPTION_INVALID_SESSION_ID = 'INVALID_SESSION_ID';
    // Recursion guard to prevent infinite loop when logging passthrough errors
    private static Boolean isHandlingPassthroughError = false;

    private static Connected_Org__c getPassthroughConnectedOrg() {
        Connected_Org__c corg = ConnectedOrgService.getPassthroughConnectedOrg();
        if (corg == null) {
            throw new PassthroughtModeServiceException(ConfigUtil.CONNECTED_ORG_NOT_FOUND_PASSTHROUGHMODE);
        }
        return corg;
    }

    /**
     * Send inbound email to target org with pre-calculated simple hashes
     * @param inboundEmail The email to send
     * @param asyncJobIdToSimpleHash Map of AsyncApexJobId -> simple hash (for dual index creation at target org)
     */
    public static void sendInboundEmail(Inbound_Email__c inboundEmail, Map<String, String> asyncJobIdToSimpleHash) {
        Connected_Org__c corg = getPassthroughConnectedOrg();
        String body = JSON.serialize(new Map<String, Object>{
            'inboundEmail' => inboundEmail,
            'organizationId' => UserInfo.getOrganizationId(),
            'asyncJobIdToSimpleHash' => asyncJobIdToSimpleHash
        });
        sendPassthroughData(corg, body);
    }

    public static void sendLog(Log__c log) {
        sendLogs(new List<Log__c>{log});
    }

    public static void sendLogs(List<Log__c> logs) {
        Connected_Org__c corg = getPassthroughConnectedOrg();
        String body = JSON.serialize(new Map<String, Object>{
            'logs' => logs,
            'organizationId' => UserInfo.getOrganizationId()
        });
        sendPassthroughData(corg, body);
    }

    public static void sendContentVersion(BulkAPIJobBatchService.ContentVersionWrapper contentVersionWrapper) {
        Connected_Org__c corg = getPassthroughConnectedOrg();
        String body = JSON.serialize(new Map<String, Object>{
                'contentVersionWrapper' => contentVersionWrapper,
                'organizationId' => UserInfo.getOrganizationId()
        });
        sendPassthroughData(corg, body);
    }

    private static void sendPassthroughData(Connected_Org__c corg, String body) {
        try {
            HttpUtils.HttpURLParameters queryParams = new HttpUtils.HttpURLParameters();
            queryParams.addEncodedParameter(ConfigUtil.PARAMS_TYPE, ConfigUtil.TYPE_PASSTHROUGH_MODE);
            String b = HttpUtils.post(
                    corg.Instance_Url__c + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + queryParams.toStringParameters('?'),
                    body,
                    ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg)),
                    200
            );
        }
        catch (Exception e) {
            if (e.getMessage().contains(EXCEPTION_INVALID_SESSION_ID)) {
                corg.Connection_Valid__c = false;
                DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c)
                        .handleError(PassthroughtModeService.class.getName(), '.sendPassthroughData');
            }
            // Prevent infinite recursion: only log error if not already handling a passthrough error
            if (!isHandlingPassthroughError) {
                isHandlingPassthroughError = true;
                try {
                    Logger.getInstance().addInternalError(e, PassthroughtModeService.class.getName(), '.sendPassthroughData');
                    Logger.getInstance().flush();
                } finally {
                    isHandlingPassthroughError = false;
                }
            }
        }
    }

    public static void parseIncomingData(IncomingLogData data) {
        if (data.logs != null) {
            PermissionsUtil.putSObjectFields(data.logs, Schema.SObjectType.Log__c.fields.Originated_From__c, ConfigUtil.ORIGINATED_FROM_PASSTHROUGH, true);
            LogEventTriggerHandler.addOrgInfoForManualLog(data.logs, Datetime.now());
            DatabaseUtils.getInstance().performUpsertDML(data.logs, Schema.SObjectType.Log__c)
                    .handleError(PassthroughtModeService.class.getName(), '.parseIncomingData');
        }
        else if (data.inboundEmail != null) {
            PermissionsUtil.putSObjectField(data.inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Id, null);
            PermissionsUtil.putSObjectField(data.inboundEmail, Schema.SObjectType.Inbound_Email__c.fields.Pharos_Org_ID__c, data.organizationId);
            // Becouse of the passthrough mode, we need to set the isRoutedFromPassthroughMode to true,
            // to avoid System.CalloutException: Callout loop not allowed in ErrorEmailHandler
            // Salesforce A  ----Callout----> Salesforce B  ----Callout----> Webservice (Error happened here)
            // Post processing logic will be executed in regular async job (LogPostProcessingBatch).
            // Pass asyncJobIdToSimpleHash from source org to enable dual index creation
            ErrorEmailHandler.processEmail(new List<Inbound_Email__c>{data.inboundEmail}, data.organizationId, null, null, null, true, data.asyncJobIdToSimpleHash);
        }
        else if (data.contentVersionWrapper != null) {
            ContentVersion contentVersion = data.contentVersionWrapper.contentVersion;
            contentVersion.VersionData = Blob.valueOf(data.contentVersionWrapper.contentVersionData);
            DatabaseUtils.getInstance().performInsertDML(new List<ContentVersion>{contentVersion}, Schema.SObjectType.ContentVersion)
                    .handleError(PassthroughtModeService.class.getName(), '.parseIncomingData');
        }
    }

    public class IncomingLogData {
        public List<Log__c> logs;
        public Inbound_Email__c inboundEmail;
        public BulkAPIJobBatchService.ContentVersionWrapper contentVersionWrapper;
        public String organizationId;
        // Map of AsyncApexJobId -> simple hash (pre-calculated at source org)
        // Used at target org to create dual indexes (simple hash -> correct hash lookup)
        public Map<String, String> asyncJobIdToSimpleHash;

        public IncomingLogData() {
            this.logs = new List<Log__c>();
            this.asyncJobIdToSimpleHash = new Map<String, String>();
        }

    }

    public class PassthroughtModeServiceException extends Exception {}

}