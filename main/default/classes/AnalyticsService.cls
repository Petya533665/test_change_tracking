public with sharing class AnalyticsService {
    private static final String KEY_PAGE_VIEWS = 'APV'; // Analytics Page Views
    private static final Integer PAGE_VIEWS_TTL = 24 * 60 * 60; // 24 hours
    private static final Integer MAX_RECORD_VIEWS = 100; // Maximum number of record views per page type
    
    public enum PageType {
        LOG,
        ISSUE,
        ADMIN
    }
    
    private static AnalyticsService instance;
    private AnalyticsService() {}
    
    public static AnalyticsService getInstance() {
        if (instance == null) {
            instance = new AnalyticsService();
        }
        return instance;
    }
    
    private String getCacheKey(Id userId) {
        return KEY_PAGE_VIEWS + userId;
    }


    public void trackLogPageView(Id recordId) {
        try {
            trackPageView(UserInfo.getUserId(), PageType.LOG, recordId);
        }
        catch (Exception e) {}
    }

    public void trackIssuePageView(Id recordId) {
        try {
            trackPageView(UserInfo.getUserId(), PageType.ISSUE, recordId);
        }
        catch (Exception e) {}
    }

    public void trackAdminPageView(Id recordId) {
        try {
            trackPageView(UserInfo.getUserId(), PageType.ADMIN, recordId);
        }
        catch (Exception e) {}
    }
    
    /**
     * Tracks a page view for a specific record
     * @param userId The ID of the user viewing the page
     * @param pageType The type of page being viewed
     * @param recordId The ID of the specific record being viewed
     */
    public void trackPageView(Id userId, PageType pageType, Id recordId) {
        String cacheKey = getCacheKey(userId);
        String pageTypeStr = pageType.name().toLowerCase();
        
        // Get existing view map for this user
        Map<String, Map<String, Integer>> viewMap = (Map<String, Map<String, Integer>>)CacheUtils.getCacheValue(cacheKey);
        if (viewMap == null) {
            viewMap = new Map<String, Map<String, Integer>>();
        }
        
        // Get or create map for this page type
        if (!viewMap.containsKey(pageTypeStr)) {
            viewMap.put(pageTypeStr, new Map<String, Integer>());
        }
        
        Map<String, Integer> recordViews = viewMap.get(pageTypeStr);
        
        // Check if we've hit the 100 record limit for this page type
        if (recordViews.size() >= MAX_RECORD_VIEWS && !recordViews.containsKey(String.valueOf(recordId))) {
            // Skip adding new record if we're at the limit
            return;
        }
        
        // Update view count for this specific record
        String recordKey = String.valueOf(recordId);
        Integer currentViews = recordViews.get(recordKey) ?? 0;
        recordViews.put(recordKey, currentViews + 1);
        
        // Store updated map with 24-hour TTL
        CacheUtils.putCacheValue(cacheKey, viewMap, PAGE_VIEWS_TTL); // PAGE_VIEWS_TTL = 24 * 60 * 60
    }
    
    /**
     * Returns aggregated page views in structure:
     * {
     *   userId => {
     *     pageType => {
     *       recordId => viewCount
     *     }
     *   }
     * }
     */
    public Map<String, Map<String, Map<String, Integer>>> getAggregatedPageViews() {
        Map<String, Map<String, Map<String, Integer>>> results = new Map<String, Map<String, Map<String, Integer>>>();
        
        // Get all cache keys
        Set<String> allKeys = getAllPageViewKeys();
        
        // Process each user's views
        for(String key : allKeys) {
            if(key.startsWith(KEY_PAGE_VIEWS)) {
                String userId = key.substring(KEY_PAGE_VIEWS.length());
                Map<String, Map<String, Integer>> userViews = 
                    (Map<String, Map<String, Integer>>)CacheUtils.getCacheValue(key);
                
                if(userViews != null) {
                    // Initialize user map if needed
                    if(!results.containsKey(userId)) {
                        results.put(userId, new Map<String, Map<String, Integer>>{
                            PageType.LOG.name().toLowerCase() => new Map<String, Integer>(),
                            PageType.ISSUE.name().toLowerCase() => new Map<String, Integer>(),
                            PageType.ADMIN.name().toLowerCase() => new Map<String, Integer>()
                        });
                    }
                    
                    // Add user's views to results
                    for(String pageType : userViews.keySet()) {
                        String pageTypeKey = pageType.toLowerCase();
                        Map<String, Integer> recordViews = userViews.get(pageType);
                        
                        if(recordViews != null) {
                            results.get(userId).get(pageTypeKey).putAll(recordViews);
                        }
                    }
                }
            }
        }
        
        return results;
    }
    
    /**
     * Gets all cache keys related to page views
     * @return Set of cache keys
     */
    private Set<String> getAllPageViewKeys() {
        Set<String> keys = new Set<String>();
        Cache.OrgPartition partition = CacheUtils.getOrgPartition();
        if (partition != null) {
            keys.addAll(partition.getKeys());
        }
        return keys;
    }

    public class AnalyticsMetrics {
        public Long firstMetric = 0;  // 29 bits
        public Long secondMetric = 0;  // 29 bits
    }
    
    public AnalyticsMetrics calculateMetrics() {
        Map<String, Map<String, Map<String, Integer>>> allViews = getAggregatedPageViews();
        AnalyticsMetrics metrics = new AnalyticsMetrics();
        
        // Calculate metrics for each page type
        Map<String, Integer> logMetrics = calculatePageTypeMetrics(allViews, PageType.LOG.name().toLowerCase());
        Map<String, Integer> issueMetrics = calculatePageTypeMetrics(allViews, PageType.ISSUE.name().toLowerCase());
        Map<String, Integer> adminMetrics = calculatePageTypeMetrics(allViews, PageType.ADMIN.name().toLowerCase());
        
        // Pack first metric (29 bits)
        // - Total Log Page Views (7 bits): 0-127
        // - Total Unique Log Page Views (7 bits): 0-127
        // - Total Users with Log Page Views (5 bits): 0-31
        // - Total Issue Page Views (7 bits): 0-127
        // - Unused (3 bits)
        Long firstMetric = 0L;
        firstMetric |= (Math.min(logMetrics.get('totalViews'), 127L) & 127L);
        firstMetric |= (Math.min(logMetrics.get('uniqueViews'), 127L) & 127L) << 7;
        firstMetric |= (Math.min(logMetrics.get('totalUsers'), 31L) & 31L) << 14;
        firstMetric |= (Math.min(issueMetrics.get('totalViews'), 127L) & 127L) << 19;
        metrics.firstMetric = firstMetric;
        
        // Pack second metric (29 bits)
        // - Total Unique Issue Page Views (7 bits): 0-127
        // - Total Users with Issue Page Views (5 bits): 0-31
        // - Total Admin Page Views (7 bits): 0-127
        // - Total Users with Admin Page Views (5 bits): 0-31
        // - Unused (5 bits)
        Long secondMetric = 0L;
        secondMetric |= (Math.min(issueMetrics.get('uniqueViews'), 127L) & 127L);
        secondMetric |= (Math.min(issueMetrics.get('totalUsers'), 31L) & 31L) << 7;
        secondMetric |= (Math.min(adminMetrics.get('totalViews'), 127L) & 127L) << 12;
        secondMetric |= (Math.min(adminMetrics.get('totalUsers'), 31L) & 31L) << 19;
        metrics.secondMetric = secondMetric;
        
        return metrics;
    }
    
    private Map<String, Integer> calculatePageTypeMetrics(
        Map<String, Map<String, Map<String, Integer>>> allViews, 
        String pageType
    ) {
        Map<String, Integer> metrics = new Map<String, Integer>{
            'totalViews' => 0,
            'uniqueViews' => 0,
            'totalUsers' => 0
        };
        
        Set<String> uniqueRecords = new Set<String>();
        Set<String> usersWithViews = new Set<String>();
        
        // Process each user's views
        for(String userId : allViews.keySet()) {
            Map<String, Map<String, Integer>> userViews = allViews.get(userId);
            
            if(userViews.containsKey(pageType)) {
                Map<String, Integer> recordViews = userViews.get(pageType);
                
                if(!recordViews.isEmpty()) {
                    usersWithViews.add(userId);
                    
                    for(String recordId : recordViews.keySet()) {
                        metrics.put('totalViews', 
                            metrics.get('totalViews') + recordViews.get(recordId));
                        uniqueRecords.add(recordId);
                    }
                }
            }
        }
        
        metrics.put('uniqueViews', uniqueRecords.size());
        metrics.put('totalUsers', usersWithViews.size());
        
        return metrics;
    }

    public static Map<String, Object> unpackMetrics(Long firstMetric, Long secondMetric) {
        Map<String, Object> results = new Map<String, Object>();
        
        // Unpack first metric
        results.put('logTotalViews', firstMetric & 127L);
        results.put('logUniqueViews', (firstMetric >> 7) & 127L);
        results.put('logTotalUsers', (firstMetric >> 14) & 31L);
        results.put('issueTotalViews', (firstMetric >> 19) & 127L);
        
        // Unpack second metric
        results.put('issueUniqueViews', secondMetric & 127L);
        results.put('issueTotalUsers', (secondMetric >> 7) & 31L);
        results.put('adminTotalViews', (secondMetric >> 12) & 127L);
        results.put('adminTotalUsers', (secondMetric >> 19) & 31L);
        
        return results;
    }
}