public with sharing class DigestService {
    public static final String DIGEST_METHOD = 'digest';
    private static final String PREPARE_DIGEST_ENDPOINT = PharosChatController.CHAT_ENV_URL + '/prepare-digest';
    private static final String CACHE_KEY_TEST_DIGEST = 'TestDigest';
    private static final Integer CACHE_TTL_SECONDS = 3600;

    private static void clearTestDigestCache() {
        Cache.OrgPartition partition = CacheUtils.getOrgPartition();
        partition.put(CACHE_KEY_TEST_DIGEST, '', CACHE_TTL_SECONDS);
    }

    public static Map<String, Object> prepareDigest(Object data) {
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        String prompt = (String) input.get('prompt');
        String ruleId = (String) input.get('rule_id');

        // Expects frontend dates in yyyy-MM-dd format
        Date dateFrom = input.get('date_from') == null ? null : Date.valueOf((String) input.get('date_from'));
        Date dateTo = input.get('date_to') == null ? null : Date.valueOf((String) input.get('date_to'));

        return prepareDigest(ruleId, prompt, dateFrom, dateTo);
    }

    public static Map<String, Object> prepareDigest(String ruleId, String userPrompt, Date dateFrom, Date dateTo) {
        try {
            if (ruleId == null) {
                clearTestDigestCache();
            }
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

    public static void storeTestDigest(String digest) {
        Cache.OrgPartition partition = CacheUtils.getOrgPartition();
        CacheUtils.putCacheValue(partition, CACHE_KEY_TEST_DIGEST, digest, CACHE_TTL_SECONDS);
    }

    public static Map<String, Object> getTestDigest() {
        Cache.OrgPartition partition = CacheUtils.getOrgPartition();
        String result = (String) CacheUtils.getCacheValue(partition, CACHE_KEY_TEST_DIGEST);
        if (String.isBlank(result)) {
            return new Map<String, Object>{ 'success' => false };
        }
        clearTestDigestCache();
        return new Map<String, Object>{ 'success' => true, 'result' => result };
    }
}