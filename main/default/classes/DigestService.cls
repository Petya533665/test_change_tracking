public with sharing class DigestService {
    public static final String DIGEST_METHOD = 'digest';
    private static final String PREPARE_DIGEST_ENDPOINT = PharosChatController.CHAT_ENV_URL + '/prepare-digest';
    private static final String TEST_DIGEST_TITLE = 'Test_Digest';

    public static Map<String, Object> prepareDigest(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String prompt = (String) input.get('prompt');

        // Expects frontend dates in yyyy-MM-dd format
        Date dateFrom = input.get('date_from') == null ? null : Date.valueOf((String) input.get('date_from'));
        Date dateTo = input.get('date_to') == null ? null : Date.valueOf((String) input.get('date_to'));

        return prepareDigest(prompt, dateFrom, dateTo);
    }

    public static Map<String, Object> prepareDigest(String userPrompt, Date dateFrom, Date dateTo) {
        try {
            // Send init-chat request to initialize OpenAI and get session_id
            String orgId = UserInfo.getOrganizationId();
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
            PharosChatController.sendInitChatRequest(orgId, openAiKey);

            if (dateTo == null) {
                dateTo = Date.today();
            }
            if (dateFrom == null) {
                dateFrom = dateTo.addDays(-60);
            }

            Map<String, String> data = PharosChatController.getSendMessageData(null);
            data.put('session_id', orgId);
            data.put('prompt', userPrompt);
            data.put('date_from', String.valueOf(dateFrom));
            data.put('date_to', String.valueOf(dateTo));

            HttpUtils.post(
                PREPARE_DIGEST_ENDPOINT,
                JSON.serialize(data),
                HttpUtils.getHeadersWithApiKeyAndJson(),
                200
            );
            return new Map<String, Object>{'success' => true};
        } catch (Exception e) {
            Logger.getInstance().addInternalError(e, PharosChatController.class.getName(), 'prepareDigest');
            return new Map<String, Object>{'success' => false, 'error' => e.getMessage()};
        }
    }

    private static void deleteOldTestDigestDocuments() {
        List<ContentVersion> existingTestDigests = [
            SELECT ContentDocumentId FROM ContentVersion
            WHERE Title = :TEST_DIGEST_TITLE AND IsLatest = true
        ];
        if (existingTestDigests.isEmpty()) return;
        Set<Id> docIds = new Set<Id>();
        for (ContentVersion cv : existingTestDigests) {
            docIds.add(cv.ContentDocumentId);
        }
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN :docIds];
        DatabaseUtils.getInstance().performDeleteDML(documents, Schema.SObjectType.ContentDocument, true);
    }

    public static void storeTestDigest(String digest) {
        deleteOldTestDigestDocuments();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = TEST_DIGEST_TITLE + '.txt';
        contentVersion.Title = TEST_DIGEST_TITLE;
        contentVersion.VersionData = Blob.valueOf(digest);
        DatabaseUtils.getInstance().performInsertDML(new List<ContentVersion>{contentVersion}, Schema.SObjectType.ContentVersion, true);
    }

    public static Map<String, Object> getTestDigest() {
        List<ContentVersion> contentVersions = [
            SELECT Id, VersionData, ContentDocumentId
            FROM ContentVersion
            WHERE Title = :TEST_DIGEST_TITLE AND IsLatest = true
            LIMIT 1
        ];
        if (contentVersions.isEmpty()) {
            return new Map<String, Object>{'success' => false};
        }
        String result = contentVersions[0].VersionData.toString();
        Id docId = contentVersions[0].ContentDocumentId;
        DatabaseUtils.getInstance().performDeleteDML(new List<ContentDocument>{new ContentDocument(Id = docId)}, Schema.SObjectType.ContentDocument, true);
        return new Map<String, Object>{'success' => true, 'result' => result};
    }
}