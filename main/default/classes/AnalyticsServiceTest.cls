@IsTest
private class AnalyticsServiceTest {

    @IsTest
    static void testCalculateMetrics() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id user1 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(0);
        Id user2 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(1);

        List<Id> mockLogIds = TestDataFactory.getFakeIds(Account.SObjectType, 5);
        List<Id> mockIssueIds = TestDataFactory.getFakeIds(Case.SObjectType, 4);
        List<Id> mockAdminIds = TestDataFactory.getFakeIds(User.SObjectType, 3);
        
        Test.startTest();
        
        // Create test data - LOG views (5 unique records, 8 total views)
        for(Integer i = 1; i <= 5; i++) {
            Id recordId = mockLogIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.LOG, recordId);
            if(i <= 3) {
                service.trackPageView(user2, AnalyticsService.PageType.LOG, recordId); // 3 shared views
            }
        }
        
        // ISSUE views (4 unique records, 8 total views)
        for(Integer i = 1; i <= 4; i++) {
            Id recordId = mockIssueIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.ISSUE, recordId);
            if(i <= 2) {
                service.trackPageView(user2, AnalyticsService.PageType.ISSUE, recordId);
                service.trackPageView(user2, AnalyticsService.PageType.ISSUE, recordId); // Double views
            }
        }
        
        // ADMIN views (3 unique records, 3 total views)
        for(Integer i = 1; i <= 3; i++) {
            Id recordId = mockAdminIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.ADMIN, recordId);
        }
        
        // Calculate and unpack metrics
        AnalyticsService.AnalyticsMetrics metrics = service.calculateMetrics();
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Map<String, Object> unpackedMetrics = AnalyticsService.unpackMetrics(metrics.firstMetric, metrics.secondMetric);
        
        Test.stopTest();
        
        // Verify metrics
        System.assertEquals(8, unpackedMetrics.get('logTotalViews'), 'Should have 8 total log views (5 from user1 + 3 from user2)');
        System.assertEquals(5, unpackedMetrics.get('logUniqueViews'), 'Should have 5 unique log records');
        System.assertEquals(2, unpackedMetrics.get('logTotalUsers'), 'Should have 2 users with log views');
        
        System.assertEquals(8, unpackedMetrics.get('issueTotalViews'), 'Should have 8 total issue views (4 from user1 + 4 from user2)');
        System.assertEquals(4, unpackedMetrics.get('issueUniqueViews'), 'Should have 4 unique issue records');
        System.assertEquals(2, unpackedMetrics.get('issueTotalUsers'), 'Should have 2 users with issue views');
        
        System.assertEquals(3, unpackedMetrics.get('adminTotalViews'), 'Should have 3 total admin views');
        System.assertEquals(1, unpackedMetrics.get('adminTotalUsers'), 'Should have 1 user with admin views');
    }

    @IsTest
    static void testMetricsLimits() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id userId = UserInfo.getUserId();
        List<Id> mockLogIds = TestDataFactory.getFakeIds(Account.SObjectType, 200);
        List<Id> mockIssueIds = TestDataFactory.getFakeIds(Case.SObjectType, 200);
        List<Id> mockAdminIds = TestDataFactory.getFakeIds(User.SObjectType, 200);
        
        // When - Create more views than our bit limits allow
        Test.startTest();
        for(Integer i = 1; i <= 200; i++) {
            service.trackPageView(userId, AnalyticsService.PageType.LOG, mockLogIds.get(i - 1));
            service.trackPageView(userId, AnalyticsService.PageType.ISSUE, mockIssueIds.get(i - 1));
            service.trackPageView(userId, AnalyticsService.PageType.ADMIN, mockAdminIds.get(i - 1));
        }
        
        AnalyticsService.AnalyticsMetrics metrics = service.calculateMetrics();
        Map<String, Object> unpackedMetrics = AnalyticsService.unpackMetrics(metrics.firstMetric, metrics.secondMetric);
        Test.stopTest();
        
        // Then - Verify we don't exceed our bit limits
        System.assert((Long)unpackedMetrics.get('logTotalViews') <= 127, 'Log total views should not exceed 7 bits');
        System.assert((Long)unpackedMetrics.get('logUniqueViews') <= 127, 'Log unique views should not exceed 7 bits');
        System.assert((Long)unpackedMetrics.get('logTotalUsers') <= 31, 'Log total users should not exceed 5 bits');
        System.assert((Long)unpackedMetrics.get('issueTotalViews') <= 127, 'Issue total views should not exceed 7 bits');
        System.assert((Long)unpackedMetrics.get('issueUniqueViews') <= 127, 'Issue unique views should not exceed 7 bits');
        System.assert((Long)unpackedMetrics.get('issueTotalUsers') <= 31, 'Issue total users should not exceed 5 bits');
        System.assert((Long)unpackedMetrics.get('adminTotalViews') <= 127, 'Admin total views should not exceed 7 bits');
        System.assert((Long)unpackedMetrics.get('adminTotalUsers') <= 31, 'Admin total users should not exceed 5 bits');
    }
    
    @IsTest
    static void testTrackPageView() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id mockUserId = TestDataFactory.getFakeIds(User.SObjectType, 1).get(0);
        Id mockRecordId = TestDataFactory.getFakeIds(Account.SObjectType, 1).get(0);
        
        // When
        Test.startTest();
        service.trackPageView(mockUserId, AnalyticsService.PageType.LOG, mockRecordId);
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Test.stopTest();
        
        // Then
        System.assert(allViews.containsKey(mockUserId), 'Should have views for user');
        System.assert(allViews.get(mockUserId).containsKey('log'), 'Should have log views');
        System.assertEquals(1, allViews.get(mockUserId).get('log').get(mockRecordId), 'Should have one view');
    }
    
    @IsTest
    static void testMultiplePageViews() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id mockUserId = TestDataFactory.getFakeIds(User.SObjectType, 1).get(0);
        Id mockLogId = TestDataFactory.getFakeIds(Account.SObjectType, 1).get(0);
        Id mockIssueId = TestDataFactory.getFakeIds(Case.SObjectType, 1).get(0);
        
        // When
        Test.startTest();
        // Track multiple views of different types
        service.trackPageView(mockUserId, AnalyticsService.PageType.LOG, mockLogId);
        service.trackPageView(mockUserId, AnalyticsService.PageType.LOG, mockLogId);
        service.trackPageView(mockUserId, AnalyticsService.PageType.ISSUE, mockIssueId);
        
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Test.stopTest();
        
        // Then
        System.assertEquals(2, allViews.get(mockUserId).get('log').get(mockLogId), 'Should have two views for the log');
        System.assertEquals(1, allViews.get(mockUserId).get('issue').get(mockIssueId), 'Should have one view for the issue');
        System.assertEquals(0, allViews.get(mockUserId).get('admin').size(), 'Should have no admin views');
    }
    
    @IsTest
    static void testAggregatedPageViews() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id mockUserId1 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(0);
        Id mockUserId2 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(1);
        Id mockLogId1 = TestDataFactory.getFakeIds(Account.SObjectType, 2).get(0);
        Id mockLogId2 = TestDataFactory.getFakeIds(Account.SObjectType, 2).get(1);
        Id mockIssueId = TestDataFactory.getFakeIds(Case.SObjectType, 1).get(0);
        
        Test.startTest();
        
        // When - Track views for different users and records
        service.trackPageView(mockUserId1, AnalyticsService.PageType.LOG, mockLogId1);
        service.trackPageView(mockUserId1, AnalyticsService.PageType.LOG, mockLogId1); // Second view of same record
        service.trackPageView(mockUserId2, AnalyticsService.PageType.LOG, mockLogId2);
        service.trackPageView(mockUserId1, AnalyticsService.PageType.ISSUE, mockIssueId);
        
        // Get aggregated views
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Test.stopTest();

        // Then
        System.assertEquals(2, allViews.get(mockUserId1).get('log').get(mockLogId1), 'Should have two unique log records viewed');
        System.assertEquals(1, allViews.get(mockUserId1).get('issue').get(mockIssueId), 'Should have one unique issue record viewed');
        System.assertEquals(0, allViews.get(mockUserId1).get('admin').size(), 'Should have no admin records viewed');
    }

    @IsTest
    static void testMaxViewLimit() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id mockUserId = UserInfo.getUserId();
        List<Id> mockLogIds = TestDataFactory.getFakeIds(Account.SObjectType, 150);
        
        // When
        Test.startTest();
        // Track views for more than 100 different records
        for(Id mockId : mockLogIds) {
            service.trackPageView(mockUserId, AnalyticsService.PageType.LOG, mockId);
        }
        
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Test.stopTest();
        
        // Then
        System.assertEquals(100, allViews.get(mockUserId).get('log').size(), 'Should be capped at 100 unique record views');
        
        // Verify all records have view count of 1
        for(Integer viewCount : allViews.get(mockUserId).get('log').values()) {
            System.assertEquals(1, viewCount, 'Each record should have exactly one view');
        }
        
        // Verify other page types are empty
        System.assertEquals(0, allViews.get(mockUserId).get('issue').size(), 'Should have no issue views');
        System.assertEquals(0, allViews.get(mockUserId).get('admin').size(), 'Should have no admin views');
    }

    @IsTest
    static void testTrackPageView_LimitPerType() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id mockUserId = TestDataFactory.getFakeIds(User.SObjectType, 1).get(0);
        List<Id> mockLogIds = TestDataFactory.getFakeIds(Account.SObjectType, 101);
        List<Id> mockIssueIds = TestDataFactory.getFakeIds(Case.SObjectType, 101);
        List<Id> mockAdminIds = TestDataFactory.getFakeIds(User.SObjectType, 101);

        Set<Id> mockLogIdsSet = new Set<Id>(mockLogIds);
        system.assertEquals(101, mockLogIdsSet.size());

        // When - Add 101 records for each type
        Test.startTest();
        for(Integer i = 0; i < 101; i++) {
            service.trackPageView(mockUserId, AnalyticsService.PageType.LOG, mockLogIds.get(i));
            service.trackPageView(mockUserId, AnalyticsService.PageType.ISSUE, mockIssueIds.get(i));
            service.trackPageView(mockUserId, AnalyticsService.PageType.ADMIN, mockAdminIds.get(i));
        }
        
        Map<String, Map<String, Map<String, Integer>>> allViews = service.getAggregatedPageViews();
        Test.stopTest();
        
        // Then
        System.assertEquals(100, allViews.get(mockUserId).get('log').size(), 'Should be limited to 100 log views');
        System.assertEquals(100, allViews.get(mockUserId).get('issue').size(), 'Should be limited to 100 issue views');
        System.assertEquals(100, allViews.get(mockUserId).get('admin').size(), 'Should be limited to 100 admin views');

        // Verify view counts
        for(String recordId : allViews.get(mockUserId).get('log').keySet()) {
            System.assertEquals(1, allViews.get(mockUserId).get('log').get(recordId), 'Each log record should have 1 view');
        }
        for(String recordId : allViews.get(mockUserId).get('issue').keySet()) {
            System.assertEquals(1, allViews.get(mockUserId).get('issue').get(recordId), 'Each issue record should have 1 view');
        }
        for(String recordId : allViews.get(mockUserId).get('admin').keySet()) {
            System.assertEquals(1, allViews.get(mockUserId).get('admin').get(recordId), 'Each admin record should have 1 view');
        }
    }

    @IsTest
    static void test_metrics_batch_feature_parameters() {
        // Given
        AnalyticsService service = AnalyticsService.getInstance();
        Id user1 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(0);
        Id user2 = TestDataFactory.getFakeIds(User.SObjectType, 2).get(1);
        
        // Create test data
        setupTestMetricsData(service, user1, user2);
        
        // Capture initial values
        Integer metrics5Before = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_9_NAME);
        Integer metrics6Before = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_11_NAME);
        
        // When
        Test.startTest();
        MetricsBatch.calculateOrgMetrics5();
        MetricsBatch.calculateOrgMetrics6();
        Test.stopTest();
        
        // Then
        Integer metrics5After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_9_NAME);
        Integer metrics6After = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_11_NAME);
        
        // Verify metrics were updated
        System.assertNotEquals(metrics5Before, metrics5After, 'Metrics5 should be updated');
        System.assertNotEquals(metrics6Before, metrics6After, 'Metrics6 should be updated');
        
        // Verify unpacked values
        Map<String, Object> unpackedMetrics = AnalyticsService.unpackMetrics(metrics5After, metrics6After);
        verifyUnpackedMetrics(unpackedMetrics);
    }
    
    private static void setupTestMetricsData(AnalyticsService service, Id user1, Id user2) {
        List<Id> mockLogIds = TestDataFactory.getFakeIds(Account.SObjectType, 5);
        List<Id> mockIssueIds = TestDataFactory.getFakeIds(Case.SObjectType, 4);
        List<Id> mockAdminIds = TestDataFactory.getFakeIds(User.SObjectType, 3);
        // LOG views (5 unique records, 8 total views)
        for(Integer i = 1; i <= 5; i++) {
            Id recordId = mockLogIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.LOG, recordId);
            if(i <= 3) {
                service.trackPageView(user2, AnalyticsService.PageType.LOG, recordId);
            }
        }
        
        // ISSUE views (4 unique records, 8 total views)
        for(Integer i = 1; i <= 4; i++) {
            Id recordId = mockIssueIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.ISSUE, recordId);
            if(i <= 2) {
                service.trackPageView(user2, AnalyticsService.PageType.ISSUE, recordId);
                service.trackPageView(user2, AnalyticsService.PageType.ISSUE, recordId);
            }
        }
        
        // ADMIN views (3 unique records, 3 total views)
        for(Integer i = 1; i <= 3; i++) {
            Id recordId = mockAdminIds.get(i - 1);
            service.trackPageView(user1, AnalyticsService.PageType.ADMIN, recordId);
        }
    }
    
    private static void verifyUnpackedMetrics(Map<String, Object> metrics) {
        // Verify LOG metrics
        System.assertEquals(8, metrics.get('logTotalViews'), 
            'Should have 8 total log views (5 from user1 + 3 from user2)');
        System.assertEquals(5, metrics.get('logUniqueViews'), 
            'Should have 5 unique log records');
        System.assertEquals(2, metrics.get('logTotalUsers'), 
            'Should have 2 users with log views');
        
        // Verify ISSUE metrics
        System.assertEquals(8, metrics.get('issueTotalViews'), 
            'Should have 8 total issue views (4 from user1 + 4 from user2)');
        System.assertEquals(4, metrics.get('issueUniqueViews'), 
            'Should have 4 unique issue records');
        System.assertEquals(2, metrics.get('issueTotalUsers'), 
            'Should have 2 users with issue views');
        
        // Verify ADMIN metrics
        System.assertEquals(3, metrics.get('adminTotalViews'), 
            'Should have 3 total admin views');
        System.assertEquals(1, metrics.get('adminTotalUsers'), 
            'Should have 1 user with admin views');
    }
    
    @IsTest
    static void test_metrics_batch_feature_parameters_empty() {
        // Given - No analytics data
        
        // When
        Test.startTest();
        MetricsBatch.calculateOrgMetrics5();
        MetricsBatch.calculateOrgMetrics6();
        Test.stopTest();
        
        // Then
        Integer metrics5 = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_9_NAME);
        Integer metrics6 = FeatureManagement.checkPackageIntegerValue(PermissionsUtil.FEATURE_PARAM_MAP_11_NAME);
        
        Map<String, Object> unpackedMetrics = AnalyticsService.unpackMetrics(metrics5, metrics6);
        
        // Verify all metrics are zero
        System.assertEquals(0, unpackedMetrics.get('logTotalViews'), 'Should have no log views');
        System.assertEquals(0, unpackedMetrics.get('logUniqueViews'), 'Should have no unique log records');
        System.assertEquals(0, unpackedMetrics.get('logTotalUsers'), 'Should have no users with log views');
        System.assertEquals(0, unpackedMetrics.get('issueTotalViews'), 'Should have no issue views');
        System.assertEquals(0, unpackedMetrics.get('issueUniqueViews'), 'Should have no unique issue records');
        System.assertEquals(0, unpackedMetrics.get('issueTotalUsers'), 'Should have no users with issue views');
        System.assertEquals(0, unpackedMetrics.get('adminTotalViews'), 'Should have no admin views');
        System.assertEquals(0, unpackedMetrics.get('adminTotalUsers'), 'Should have no users with admin views');
    }
}