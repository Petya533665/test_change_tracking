public with sharing class DigestService {
    public static final String DIGEST_METHOD = 'digest';
    public static final String TEST_DIGEST_PREFIX = 'TestDigest';
    public static final String PREPARE_DIGEST_ENDPOINT = PharosChatController.CHAT_ENV_URL + '/prepare-digest';
    private static final Integer CACHE_TTL_SECONDS = 300;

    public static Map<String, Object> prepareDigest(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String prompt = (String) input.get('prompt');
        String ruleId = (String) input.get('ruleId');

        // Expects frontend dates in yyyy-MM-dd format
        Date dateFrom = input.get('dateFrom') == null ? null : Date.valueOf((String) input.get('dateFrom'));
        Date dateTo = input.get('dateTo') == null ? null : Date.valueOf((String) input.get('dateTo'));

        return prepareDigest(ruleId, prompt, dateFrom, dateTo);
    }

    public static Map<String, Object> prepareDigest(String ruleId, String userPrompt, Date dateFrom, Date dateTo) {
        try {
            // Send init-chat request to initialize OpenAI and get session_id
            String orgId = UserInfo.getOrganizationId();
            String openAiKey = ConfigUtil.OPEN_AI_SETTINGS.Token__c;
            PharosChatController.sendInitChatRequest(orgId, openAiKey);

            if (dateTo == null) {
                dateTo = Date.today();
            }
            if (dateFrom == null) {
                dateFrom = dateTo.addDays(-7);
            }

            Map<String, String> data = PharosChatController.getSendMessageData(ruleId);
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

    public static void storeTestDigest(String key, String digest) {
        CacheUtils.putCacheValue(key, digest, CACHE_TTL_SECONDS);
    }

    public static Map<String, Object> getTestDigest(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String key = (String) input.get('key');
        if (String.isBlank(key)) {
            return new Map<String, Object>{ 'success' => false };
        }
        Cache.OrgPartition partition = CacheUtils.getOrgPartition();
        String result = (String) CacheUtils.getCacheValue(partition, key);
        if (String.isBlank(result)) {
            return new Map<String, Object>{ 'success' => false };
        }
        partition.remove(key);
        return new Map<String, Object>{ 'success' => true, 'result' => result };
    }
}