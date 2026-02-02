/**
 * Unit tests for DigestService.
 * @author Cursor
 * @since 1.0
 */
@IsTest
public with sharing class DigestServiceTest {

    private static Map<String, HttpCalloutMock> getHttpMocks(Integer prepareDigestStatusCode) {
        TestDataFactory.SingleRequestMock initChatMock = new TestDataFactory.SingleRequestMock(200, 'OK', '');
        TestDataFactory.SingleRequestMock prepareDigestMock = new TestDataFactory.SingleRequestMock(
            prepareDigestStatusCode,
            prepareDigestStatusCode == 200 ? 'OK' : 'Error',
            ''
        );
        return new Map<String, HttpCalloutMock>{
            PharosChatController.CHAT_INIT_ENDPOINT => initChatMock,
            DigestService.PREPARE_DIGEST_ENDPOINT => prepareDigestMock
        };
    }

    @TestSetup
    static void testSetup() {
        TestDataFactory.createConnectedOrg();
        ConfigUtil.OPEN_AI_SETTINGS.OpenAI_Enabled__c = true;
        ConfigUtil.OPEN_AI_SETTINGS.Token__c = 'test-token';
        upsert ConfigUtil.OPEN_AI_SETTINGS;
    }

    @IsTest
    static void test_prepareDigest_withMap_success() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getHttpMocks(200)));

        Map<String, Object> data = new Map<String, Object>{
            'prompt' => 'Summarize logs',
            'ruleId' => null,
            'dateFrom' => '2025-01-01',
            'dateTo' => '2025-01-15'
        };

        Test.startTest();
        Map<String, Object> result = DigestService.prepareDigest(data);
        Test.stopTest();

        System.assertEquals(true, result.get('success'), 'prepareDigest should return success true');
        System.assertNotEquals(null, result.get('success'), 'Result should contain success key');
    }

    @IsTest
    static void test_prepareDigest_withMap_defaultDates() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getHttpMocks(200)));

        Map<String, Object> data = new Map<String, Object>{
            'prompt' => 'Summarize',
            'ruleId' => null
        };

        Test.startTest();
        Map<String, Object> result = DigestService.prepareDigest(data);
        Test.stopTest();

        System.assertEquals(true, result.get('success'), 'prepareDigest with null dates should use defaults and succeed');
    }

    @IsTest
    static void test_prepareDigest_overload_success() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getHttpMocks(200)));

        Date dateFrom = Date.newInstance(2025, 1, 1);
        Date dateTo = Date.newInstance(2025, 1, 15);

        Test.startTest();
        Map<String, Object> result = DigestService.prepareDigest(null, 'Test prompt', dateFrom, dateTo);
        Test.stopTest();

        System.assertEquals(true, result.get('success'), 'prepareDigest overload should return success true');
    }

    @IsTest
    static void test_prepareDigest_overload_httpError() {
        Test.setMock(HttpCalloutMock.class, new TestDataFactory.MultiRequestMock(getHttpMocks(500)));

        Test.startTest();
        Map<String, Object> result = DigestService.prepareDigest(null, 'Test prompt', Date.today().addDays(-7), Date.today());
        Test.stopTest();

        System.assertEquals(false, result.get('success'), 'prepareDigest should return success false on HTTP error');
        System.assert(result.containsKey('error'), 'Result should contain error message');
        System.assert(String.isNotBlank((String) result.get('error')), 'Error message should not be blank');
    }

    @IsTest
    static void test_prepareDigest_withMap_invalidDate() {
        Map<String, Object> data = new Map<String, Object>{
            'prompt' => 'Summarize',
            'ruleId' => null,
            'dateFrom' => 'not-a-date',
            'dateTo' => '2025-01-15'
        };

        Test.startTest();
        Boolean threw = false;
        try {
            DigestService.prepareDigest(data);
        } catch (TypeException e) {
            threw = true;
            System.assert(e.getMessage().contains('not-a-date'), 'Exception message should mention invalid date');
        }
        Test.stopTest();

        System.assert(threw, 'prepareDigest should throw TypeException for invalid date');
    }

    @IsTest
    static void test_storeTestDigest_and_getTestDigest_roundTrip() {
        // Platform Cache: key must be alphanumeric only and <= 50 chars (CacheUtils.KEY_CACHE_LIMIT)
        String key = 'TDGRoundTrip1';
        String digestContent = 'Test digest content';

        Test.startTest();
        DigestService.storeTestDigest(key, digestContent);
        Map<String, Object> getResult = DigestService.getTestDigest(new Map<String, Object>{ 'key' => key });
        Test.stopTest();

        System.assertEquals(true, getResult.get('success'), 'getTestDigest should succeed when key exists');
        System.assertEquals(digestContent, getResult.get('result'), 'Result should match stored digest');
    }

    @IsTest
    static void test_getTestDigest_keyMissing_returnsFailure() {
        // Platform Cache: alphanumeric key only; use a key that was never stored
        String key = 'TDGMissing1';

        Test.startTest();
        Map<String, Object> result = DigestService.getTestDigest(new Map<String, Object>{ 'key' => key });
        Test.stopTest();

        System.assertEquals(false, result.get('success'), 'getTestDigest should return success false when key is missing');
        System.assert(!result.containsKey('result'), 'Result should not contain result when key is missing');
    }

    @IsTest
    static void test_getTestDigest_keyExists_removesKey() {
        // Platform Cache: alphanumeric key only
        String key = 'TDGRemove1';
        DigestService.storeTestDigest(key, 'One-time digest');

        Test.startTest();
        Map<String, Object> first = DigestService.getTestDigest(new Map<String, Object>{ 'key' => key });
        Map<String, Object> second = DigestService.getTestDigest(new Map<String, Object>{ 'key' => key });
        Test.stopTest();

        System.assertEquals(true, first.get('success'), 'First get should succeed');
        System.assertEquals(false, second.get('success'), 'Second get should fail because key was removed');
    }
}