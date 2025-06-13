public with sharing class PharosChatController {
    public static final String CHAT_ENV_URL = 'https://oa9kb839ng.execute-api.us-east-2.amazonaws.com/production';
    public static final String CHAT_INIT_ENDPOINT = CHAT_ENV_URL + '/init-chat';
    public static final String CHECK_NAMESPACE_STATUS_ENDPOINT = CHAT_ENV_URL + '/namespace-status';

    public static final String OPEN_AI_SECRET = 'OpenAISecret';

    public static final String ERROR_OPENAI_NOT_READY = 'OpenAI token is not configured or is invalid. Please set up OpenAI integration first.';
    public static final String ERROR_GIT_NOT_INTEGRATED = 'Git integration is not configured. Please set up Git integration first.';
    public static final String ERROR_CODE_NOT_INDEXED = 'Codebase is not indexed. Please wait for indexing to complete.';
    public static final String ERROR_INIT_FAILED = 'Chat initialization has failed.';

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

            String namespace = ConfigUtil.nameSpacePrefix;
            String instance = System.Url.getOrgDomainUrl().toExternalForm();
            String session = EncodingUtil.base64Encode(Blob.valueOf(ConnectedOrgService.getSelfConnectedOrgAccessToken()));
            String body = JSON.serialize(new Map<String, Object> {
                'session_id' => orgId,
                'sf_namespace' => namespace,
                'sf_instance' => instance,
                'sf_session' => session
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
            errorMessages.add(ERROR_INIT_FAILED);
            return new InitChatResponse(errorMessages);
        }
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

        String namespacePrefix = ConfigUtil.nameSpacePrefix;
        String instance = System.Url.getOrgDomainUrl().toExternalForm();

        switch on type {
            when 'field' {
                String objectName = namespacePrefix + name.split('\\.').get(0);
                List<EntityDefinition> objects = [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName = :objectName];
                if (objects.isEmpty()) return null;

                String fieldName = namespacePrefix + name.split('\\.').get(1);
                List<FieldDefinition> fields = [SELECT DurableId FROM FieldDefinition
                    WHERE EntityDefinition.QualifiedApiName = :objectName
                    AND QualifiedApiName = :fieldName];
                return fields.isEmpty() ? null : instance + '/lightning/setup/ObjectManager/' + objects[0].DurableId + '/FieldsAndRelationships/' + fields[0].DurableId.split('\\.').get(1) + '/view';
            }
            when 'object' {
                String objectName = namespacePrefix + name;
                List<EntityDefinition> objects = [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName = :objectName];
                return objects.isEmpty() ? null : instance + '/lightning/setup/ObjectManager/' + objects[0].DurableId + '/view';
            }
            when 'other' {
                // search Apex class first, if not found search LWC component
                String namespace = namespacePrefix.replace('__', '');
                List<ApexClass> classes = [SELECT Id FROM ApexClass WHERE Name = :name AND NamespacePrefix = :namespace];
                if (!classes.isEmpty()) {
                    return instance + '/' + classes[0].Id;
                } else {
                    String query = new QBuilder('LightningComponentBundle')
                            .selectFields(new Set<String>{'Id'})
                            .add(QBuilder.condition('DeveloperName').equalsTo(name))
                            .add(QBuilder.condition('NamespacePrefix').equalsTo(namespace))
                            .build();
                    List<Object> lwcComponents = HttpUtils.runToolingQuery(instance, ConnectedOrgService.getSelfConnectedOrgAccessToken(), query);
                    return lwcComponents.isEmpty() ? null : instance + '/lightning/setup/LightningComponentBundles/page?address=/' + ((Map<String, Object>)lwcComponents[0]).get('Id');
                }
            }
            when else {
                return null;
            }
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