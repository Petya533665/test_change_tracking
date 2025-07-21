public with sharing class PharosChatController {
    public static final String CHAT_ENV_URL = 'https://ai.pharos.ai/chat';
    public static final String CHAT_INIT_ENDPOINT = CHAT_ENV_URL + '/init-chat';
    public static final String CHECK_NAMESPACE_STATUS_ENDPOINT = CHAT_ENV_URL + '/namespace-status';

    public static final String ERROR_OPENAI_NOT_READY = 'OpenAI token is not configured or is invalid. Please set up OpenAI integration first.';
    public static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    public static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    public static final String ERROR_INIT_FAILED = 'Chat initialization has failed.';

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

    @AuraEnabled
    public static InitChatResponse initChat() {
        try {
            String orgId = UserInfo.getOrganizationId();
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;

            List<String> errors = validatePreconditions(orgId, openAiKey);
            if (!errors.isEmpty()) {
                return new InitChatResponse(errors);
            }

            sendInitChatRequest(orgId, openAiKey);
            return new InitChatResponse(orgId);
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'initChat');
            return new InitChatResponse(new List<String>{ERROR_INIT_FAILED});
        }
    }

    public static Boolean isCodeIndexed(String logOrgId) {
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

    private static List<String> validatePreconditions(String orgId, String openAiKey) {
        List<String> errors = new List<String>();

        if (!ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c || String.isBlank(openAiKey) || !OpenAI.validateToken(openAiKey)) {
            errors.add(ERROR_OPENAI_NOT_READY);
        }
        if (!GitHubUtils.validateGitHubConnectionForChat()) {
            errors.add(ERROR_GIT_NOT_INTEGRATED);
        }
        if (!isCodeIndexed(orgId)) {
            errors.add(ERROR_CODE_NOT_INDEXED);
        }
        return errors;
    }

    private static void sendInitChatRequest(String orgId, String openAiKey) {
        String body = JSON.serialize(new Map<String, Object> {
            'session_id' => orgId,
            'openai_key' => openAiKey
        });
        HttpUtils.post(
            CHAT_INIT_ENDPOINT,
            body,
            HttpUtils.getHeadersContentTypeJSON(),
            200
        );
    }

    @AuraEnabled
    public static String getCodeEntityLink(String entity) {
        String type = '';
        String name = entity.replaceAll('\\.cls|\\.js', '');
        if (name.contains('/') || name.contains('(')) {
            return null;
        } else if (name.contains('.')) {
            type = 'field';
        } else if (name.contains('__')) {
            type = 'object';
        } else {
            type = 'other';
        }

        String instance = System.Url.getOrgDomainUrl().toExternalForm();

        switch on type {
            when 'field' {
                String objectName = name.split('\\.').get(0);
                List<EntityDefinition> objects = [SELECT DurableId, QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE :('%' + objectName)];
                if (objects.isEmpty()) return null;

                String fieldName = name.split('\\.').get(1);
                List<FieldDefinition> fields = [SELECT DurableId FROM FieldDefinition
                    WHERE EntityDefinition.QualifiedApiName = :objects[0].QualifiedApiName
                    AND QualifiedApiName LIKE :('%' + fieldName)];
                return fields.isEmpty() ? null : instance + '/lightning/setup/ObjectManager/' + objects[0].DurableId + '/FieldsAndRelationships/' + fields[0].DurableId.split('\\.').get(1) + '/view';
            }
            when 'object' {
                List<EntityDefinition> objects = [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName LIKE :('%' + name)];
                return objects.isEmpty() ? null : instance + '/lightning/setup/ObjectManager/' + objects[0].DurableId + '/view';
            }
            when 'other' {
                // search Apex class first, if not found search LWC component
                List<ApexClass> classes = [SELECT Id FROM ApexClass WHERE Name = :name];
                if (!classes.isEmpty()) {
                    return instance + '/' + classes[0].Id;
                } else {
                    String query = new QBuilder('LightningComponentBundle')
                            .selectFields(new Set<String>{'Id'})
                            .add(QBuilder.condition('DeveloperName').equalsTo(name))
                            .build();
                    List<Object> lwcComponents = HttpUtils.runToolingQuery(instance, ConnectedOrgService.getSelfConnectedOrgAccessToken(), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT);
                    return lwcComponents.isEmpty() ? null : instance + '/lightning/setup/LightningComponentBundles/page?address=/' + ((Map<String, Object>)lwcComponents[0]).get('Id');
                }
            }
            when else {
                return null;
            }
        }
    }
}