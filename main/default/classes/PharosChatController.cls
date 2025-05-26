public with sharing class PharosChatController {
    public static final String CHAT_ENV_URL = 'https://ai.pharos.ai/chat';
    public static final String CHAT_INIT_ENDPOINT = CHAT_ENV_URL + '/init-chat';
    public static final String CHECK_NAMESPACE_STATUS_ENDPOINT = CHAT_ENV_URL + '/namespace-status';

    public static final String OPEN_AI_SECRET = 'OpenAISecret';

    private static final String ERROR_OPENAI_NOT_READY = 'OpenAI token is not configured or is invalid. Please set up OpenAI integration first.';
    private static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    private static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    private static final String ERROR_INIT_FAILED = 'Chat initialization has failed.';

    @AuraEnabled
    public static InitChatResponse initChat() {
        List<String> errorMessages = new List<String>();
        try {
            String orgId = UserInfo.getOrganizationId();
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
            OAuthSettings__mdt mdtSettings = OAuthSettings__mdt.getInstance(OPEN_AI_SECRET);
            String secretKey = mdtSettings.Token__c;

            if (String.isBlank(openAiKey) || String.isBlank(secretKey) || !OpenAI.validateToken(openAiKey)) {
                errorMessages.add(ERROR_OPENAI_NOT_READY);
            }
            Boolean gitConfigPresent = GitHubUtils.GIT_USERNAME != null && GitHubUtils.GIT_REPONAME != null && ConfigUtil.GIT_API_SETTINGS.Branch_Name__c != null;
            if (!gitConfigPresent || !GitHubUtils.validateGitHubConnection()) {
                errorMessages.add(ERROR_GIT_NOT_INTEGRATED);
            }
            if (!isCodeIndexed(orgId)) {
                errorMessages.add(ERROR_CODE_NOT_INDEXED);
            }

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
            errorMessages.add(e.getMessage());
            errorMessages.add(e.getStackTraceString());
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