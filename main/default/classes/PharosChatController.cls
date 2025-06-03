public with sharing class PharosChatController {
    public static final String CHAT_ENV_URL = 'https://ai.pharos.ai/chat';
    public static final String CHECK_NAMESPACE_STATUS_ENDPOINT = CHAT_ENV_URL + '/namespace-status';

    public static final String OPEN_AI_SECRET = 'OpenAISecret';

    public static final String ERROR_OPENAI_NOT_READY = 'OpenAI token is not configured or is invalid. Please set up OpenAI integration first.';
    public static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    public static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    public static final String ERROR_INIT_FAILED = 'Chat initialization has failed.';

    @AuraEnabled
    public static string getSfSessionId(){
        return EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
    }

    @AuraEnabled
    public static InitChatResponse initChat() {
        List<String> errorMessages = new List<String>();
        try {
            String orgId = UserInfo.getOrganizationId();
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;

            if (!ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c || String.isBlank(openAiKey)|| !OpenAI.validateToken(openAiKey)) {
                errorMessages.add(ERROR_OPENAI_NOT_READY);
            }
            if (!GitHubUtils.validateGitHubConnectionForChat()) {
                errorMessages.add(ERROR_GIT_NOT_INTEGRATED);
            }
            if (!isCodeIndexed(orgId)) {
                errorMessages.add(ERROR_CODE_NOT_INDEXED);
            }

            if (errorMessages.size() > 0) {
                return new InitChatResponse(errorMessages);
            }

            String ns = ConfigUtil.nameSpacePrefix;
            String instance = System.Url.getOrgDomainUrl().toExternalForm();
            return new InitChatResponse(orgId, ns, instance);
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'initChat');
            errorMessages.add(ERROR_INIT_FAILED);
            return new InitChatResponse(errorMessages);
        }
    }

    public static boolean isCodeIndexed(String logOrgId) {
        try {
            String response = HttpUtils.get(
                    CHECK_NAMESPACE_STATUS_ENDPOINT + '?namespace=' + logOrgId,
                    HttpUtils.getHeadersContentTypeJSON(),
                    200
            );
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response);
            return (Boolean) body.get('empty') == false;
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'isCodeIndexed');
            return false;
        }
    }

    public class InitChatResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<String> errorMessages;
        @AuraEnabled public String sessionId;
        @AuraEnabled public String namespace;
        @AuraEnabled public String instance;

        public InitChatResponse(List<String> errorMessages) {
            this.success = false;
            this.errorMessages = errorMessages;
        }

        public InitChatResponse(String sessionId, String namespace, String instance) {
            this.success = true;
            this.sessionId = sessionId;
            this.namespace = namespace;
            this.instance = instance;
        }
    }
}