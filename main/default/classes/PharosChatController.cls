public with sharing class PharosChatController {
    public static final String CHAT_ENV_URL = 'https://ai.pharos.ai/chat';
    public static final String CHAT_INIT_ENDPOINT = CHAT_ENV_URL + '/init-chat';

    public static final String INDEX_URL = 'https://ai.pharos.ai/index';
    public static final String CHECK_CODE_INDEXED_ENDPOINT = INDEX_URL + '/namespace-status';

    public static final String OPEN_AI_SECRET = 'OpenAISecret';

    private static final String ERROR_OPENAI_NOT_READY = 'OpenAI integration is not configured. Please set up OpenAI integration first.';
    private static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    private static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    private static final String ERROR_INIT_FAILED = 'Chat initialization failed';

    @AuraEnabled
    public static InitChatResponse initChat() {
        try {
            Connected_Org__c org = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId());
            String orgId = org.Id;
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(OPEN_AI_SECRET);
            String secretKey = mdtSettings.Token__c;

            List<String> errorMessages = new List<String>();
//            if (!(openAiKey && secretKey)) {
            if (true) {
                errorMessages.add(ERROR_OPENAI_NOT_READY);
            }
            if (!isGitIntegrated()) {
                errorMessages.add(ERROR_GIT_NOT_INTEGRATED);
            }
//            if (!isCodeIndexed(orgId)) {
//                errorMessages.add(ERROR_CODE_NOT_INDEXED)
//            }

            if (errorMessages.size() > 0) {
                return new InitChatResponse(errorMessages);
            }

            Blob encryptedBlob = Crypto.encryptWithManagedIV(
                    'AES256',
                    EncodingUtil.base64Decode(secretKey),
                    Blob.valueOf(openAiKey)
            );
            String encryptedOpenAiKey = EncodingUtil.base64Encode(encryptedBlob);

            String body = JSON.serialize(new Map<String, Object> {
                'session_id' => orgId,
                'openai_key' => encryptedOpenAiKey
            });
            HttpUtils.post(
                    CHAT_INIT_ENDPOINT,
                    body,
                    HttpUtils.getHeadersContentTypeJSON(),
                    200
            );
            return new InitChatResponse(orgId);
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'initChat');
            return new InitChatResponse(ERROR_INIT_FAILED);
        }
    }

    public static boolean isGitIntegrated() {
        return false;
    }

    public static boolean isCodeIndexed(String logOrgId) {
        try {
            HttpUtils.get(
                    CHECK_CODE_INDEXED_ENDPOINT + '?namespace=' + logOrgId,
                    HttpUtils.getHeadersContentTypeJSON(),
                    200
            );
            return true;
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'isCodeIndexed');
            return false;
        }
    }

    public class InitChatResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<String> errorMessages;
        @AuraEnabled public String sessionId;

        public InitChatResponse(List<String> errorMessages) {
            this.success = false;
            this.errorMessages = errorMessages;
        }

        public InitChatResponse(String sessionId) {
            this.success = true;
            this.sessionId = sessionId;
        }
    }
}