public without sharing class SlackService {

    /**
     * Container for Slack API rate limit information
     * Contains retry timing information for proper handling
     */
    public class RateLimitInfo {
        public Integer retryAfterSeconds;
        public DateTime retryAfterTime;
        public String actionId;
        public String message;
        public Boolean isRateLimited;
        public DateTime expiryTime;
        
        public RateLimitInfo() {
            this.isRateLimited = false;
            this.retryAfterSeconds = null;
            this.expiryTime = null;
        }
        
        public RateLimitInfo(String message) {
            this();
            this.message = message;
            this.actionId = null;
        }
        
        public RateLimitInfo(String message, Integer retryAfter) {
            this(message);
            this.retryAfterSeconds = retryAfter;
            this.retryAfterTime = retryAfter != null ? DateTime.now().addSeconds(retryAfter) : null;
        }
        
        public RateLimitInfo(String message, Integer retryAfter, String actionId) {
            this(message, retryAfter);
            this.actionId = actionId;
        }
        
        public Boolean hasRetryInfo() {
            return this.retryAfterSeconds != null && this.retryAfterTime != null;
        }
        
        public Boolean isExpired() {
            return this.retryAfterTime != null && DateTime.now() >= this.retryAfterTime;
        }
        
        public String getMessage() {
            return this.message;
        }
    }

    // Cache keys for rate limit state
    private static final String RATE_LIMIT_STATUS_KEY = 'SRL:Status';
    private static final String RATE_LIMIT_RETRY_AFTER_KEY = 'SRL:RetryAfter';
    private static final String RATE_LIMIT_TIMESTAMP_KEY = 'SRL:Timestamp';
    
    // TTL for rate limit cache entries (default 1 hour)
    private static final Integer RATE_LIMIT_CACHE_TTL = 60 * 60; // 1 hour

    /**
     * Check if Slack API is currently rate limited
     */
    public static Boolean isCurrentlyRateLimited() {
        try {
            CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
            
            // Check if rate limit is active
            Object statusObj = cacheUtil.getValue(RATE_LIMIT_STATUS_KEY);
            if (statusObj == null) {
                return false; // No rate limit state cached
            }
            
            Boolean isRateLimited = (Boolean)statusObj;
            if (!isRateLimited) {
                return false; // Rate limit state is false
            }
            
            // Check if rate limit has expired
            Object timestampObj = cacheUtil.getValue(RATE_LIMIT_TIMESTAMP_KEY);
            if (timestampObj == null) {
                // No timestamp, assume expired and clear state
                clearRateLimitState();
                return false;
            }
            
            DateTime expiryTime = (DateTime)timestampObj;
            if (DateTime.now() >= expiryTime) {
                // Rate limit has expired, clear state
                clearRateLimitState();
                return false;
            }
            
            return true; // Still rate limited
            
        } catch (Exception e) {
            // If there's any error, assume no rate limit
            return false;
        }
    }
    
    /**
     * Get the time when the current rate limit will expire
     */
    public static DateTime getRateLimitExpiryTime() {
        try {
            CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
            Object timestampObj = cacheUtil.getValue(RATE_LIMIT_TIMESTAMP_KEY);
            return timestampObj != null ? (DateTime)timestampObj : null;
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Set rate limit state based on Slack API response
     */
    public static void setRateLimitState(Integer retryAfterSeconds) {
        if (retryAfterSeconds == null || retryAfterSeconds <= 0) {
            return;
        }
        
        try {
            CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
            DateTime expiryTime = DateTime.now().addSeconds(retryAfterSeconds);
            
            // Cache the rate limit state
            cacheUtil.putValue(RATE_LIMIT_STATUS_KEY, true);
            cacheUtil.putValue(RATE_LIMIT_RETRY_AFTER_KEY, retryAfterSeconds);
            cacheUtil.putValue(RATE_LIMIT_TIMESTAMP_KEY, expiryTime);
            
        } catch (Exception e) {
            // Log error but don't throw - rate limiting is a best effort feature
        }
    }
    
    /**
     * Clear the rate limit state (called when rate limit expires or is resolved)
     */
    public static void clearRateLimitState() {
        try {
            CacheUtils cacheUtil = new CacheUtils(UserInfo.getOrganizationId());
            
            // Set status to false rather than removing to avoid cache misses
            cacheUtil.putValue(RATE_LIMIT_STATUS_KEY, false);
            cacheUtil.putValue(RATE_LIMIT_RETRY_AFTER_KEY, 0);
            cacheUtil.putValue(RATE_LIMIT_TIMESTAMP_KEY, DateTime.now());
            
        } catch (Exception e) {
            // Log error but don't throw
        }
    }
    
    /**
     * Check if we can make a Slack request (combines rate limit check with permission check)
     */
    public static Boolean canMakeSlackRequest() {
        // Check if Slack integration is enabled
        if (!PermissionsUtil.SlackIntegrationEnabled) {
            return false;
        }
        
        // Check rate limit status
        return !isCurrentlyRateLimited();
    }
    
    /**
     * Parse HTTP response to check for rate limiting
     */
    public static RateLimitInfo parseRateLimitResponse(HttpResponse response) {
        RateLimitInfo info = new RateLimitInfo();

        if (response == null) {
            info.isRateLimited = false;
            return info;
        }
        
        // Check for HTTP 429 status code
        if (response.getStatusCode() == 429) {
            info.isRateLimited = true;
            
            // Extract Retry-After header
            String retryAfterHeader = response.getHeader('Retry-After');
            if (String.isNotBlank(retryAfterHeader)) {
                try {
                    info.retryAfterSeconds = Integer.valueOf(retryAfterHeader);
                    info.expiryTime = DateTime.now().addSeconds(info.retryAfterSeconds);
                } catch (Exception e) {
                    // Default to 60 seconds if header is malformed
                    info.retryAfterSeconds = 60;
                    info.expiryTime = DateTime.now().addSeconds(60);
                }
            } else {
                // Default to 60 seconds if no Retry-After header
                info.retryAfterSeconds = 60;
                info.expiryTime = DateTime.now().addSeconds(60);
            }
        } else {
            info.isRateLimited = false;
        }
        
        return info;
    }

    public static void sendMessageToSlack(String message, String slack_channel_id) {

        if(!PermissionsUtil.SlackIntegrationEnabled) return;

        // Pre-flight check for rate limiting
        if (!canMakeSlackRequest()) {
            DateTime retryTime = getRateLimitExpiryTime();
            String retryMessage = retryTime != null ? 
                'Slack API is currently rate limited. Retry after: ' + retryTime.format() :
                'Slack API is currently rate limited';
            throw new CalloutException(retryMessage);
        }

        if (!ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c ||
            ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c == null ||
            slack_channel_id == null) {
            throw new SlackServiceException('Slack settings are invalid');
        }

        Map<String, Object> payload = new Map<String, Object>{
            'channel' => slack_channel_id,
            'text' => message
        };

        // Use HttpUtils.send to get the full HttpResponse for rate limit detection
        HttpResponse response = HttpUtils.send(
            ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT,
            'POST',
            ConfigUtil.SLACK_API_HEADERS,
            JSON.serialize(payload)
        );

        // Check for rate limiting in the response
        RateLimitInfo rateLimitInfo = parseRateLimitResponse(response);
            
        if (rateLimitInfo.isRateLimited) {
            setRateLimitState(rateLimitInfo.retryAfterSeconds);
            throw new CalloutException(
                'Slack API rate limit hit. Retry after: ' + rateLimitInfo.retryAfterSeconds + ' seconds'
            );
        }

        // Check for successful response
        if (response.getStatusCode() != 200) {
            throw new SlackServiceException(response.getStatusCode() + ': ' + response.getBody());
        }

        // Process successful response body if needed
        String responseBody = response.getBody();
        // Additional processing can be added here if needed
    }

    public static Boolean isValidChannel(String slackChannelId) {
        Boolean result = false;
        SlackChannelsResponse resp = getChannels(null);
        if(resp?.response_metadata?.next_cursor == null) {
            return true;
        }
        List<SlackService.SlackChannel> channels = resp?.channels;
        if(channels != null) {
            for(SlackService.SlackChannel sc : channels) {
                if(slackChannelId == sc.id) {
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    public static SlackUsersResponse getUsers(String cursor) {
        if (ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c == null) {
            throw new SlackServiceException('Slack Token not found');
        }
        String endpoint = String.isNotBlank(cursor) ? (ConfigUtil.SLACK_USER_LIST_ENDPOINT + '&cursor=' + cursor) : ConfigUtil.SLACK_USER_LIST_ENDPOINT;
        String b = HttpUtils.get(
            endpoint,
            ConfigUtil.SLACK_API_CONVERSATION_LIST_HEADERS,
            200
        );
        SlackUsersResponse resp = (SlackUsersResponse)JSON.deserialize(b, SlackUsersResponse.class);
        resp?.members?.sort();
        return resp;
    }

    public class SlackUser implements Comparable {
        public String id;
        public String name;
        public String team_id;
        public Boolean is_admin;
        public Boolean is_owner;
        public Boolean is_restricted;
        public Boolean is_ultra_restricted;
        public Boolean is_bot;
        public Boolean is_app_user;

        public Integer compareTo(Object compareTo) {
            SlackUser compareToEmp = (SlackUser)compareTo;
            if (name == compareToEmp.name) return 0;
            if (name > compareToEmp.name) return 1;
            return -1;
        }
    }

    public class SlackUsersResponse {
        public Boolean ok;
        public List<SlackUser> members;
        public SlackChannelsResponseMetadata response_metadata;
    }

    public static Boolean isCursor(String cursor) {
        try {
            String res = EncodingUtil.base64Decode(cursor).toString();
            return res.contains(':');
        }
        catch(Exception e) {}
        return false;
    }

    public static SlackChannelsResponse getChannels(String cursor) {
        if (ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c == null) {
            throw new SlackServiceException('Slack Token not found');
        }

        // check if user input is channelid
        if(String.isNotBlank(cursor) && !isCursor(cursor)) {
            try {
                String b = HttpUtils.get(
                    ConfigUtil.SLACK_CONVERSATION_INFO_ENDPOINT + '?channel=' + cursor,
                    ConfigUtil.SLACK_API_CONVERSATION_LIST_HEADERS,
                    200
                );
                SlackChannelResponse respChannel = (SlackChannelResponse)JSON.deserialize(b, SlackChannelResponse.class);
                if(respChannel != null && respChannel.ok) {
                    SlackChannelsResponse resp = new SlackChannelsResponse();
                    resp.ok = respChannel.ok;
                    resp.channels = (respChannel.channel != null) 
                        ? new List<SlackChannel>{respChannel.channel}
                        : new List<SlackChannel>();
                    return resp;
                }
            }
            catch(HttpUtils.HttpUtilsException e) {
                throw e;
            }
            catch(JSONException e) {
                throw e;
            }
            catch(Exception e) {}
        }

        // reset cursor if user input is name of channel
        if(String.isNotBlank(cursor) && !isCursor(cursor)) {
            cursor = null;
        }

        String endpoint = String.isNotBlank(cursor) ? (ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT + '&cursor=' + cursor) : ConfigUtil.SLACK_CONVERSATION_LIST_ENDPOINT;
        String b = HttpUtils.get(
            endpoint,
            ConfigUtil.SLACK_API_CONVERSATION_LIST_HEADERS,
            200
        );
        SlackChannelsResponse resp = (SlackChannelsResponse)JSON.deserialize(b, SlackChannelsResponse.class);
        resp?.channels?.sort();
        return resp;
    }

    public class SlackChannelsResponse {
        public Boolean ok;
        public List<SlackChannel> channels;
        public SlackChannelsResponseMetadata response_metadata;
    }

    public class SlackChannelResponse {
        public Boolean ok;
        public SlackChannel channel;
    }

    public class SlackChannelsResponseMetadata {
        public String next_cursor;
    }

    public class SlackChannel implements Comparable {
        public String id;
        public String name;
        public String is_channel;
        public Boolean is_member;
        public Boolean is_private;
        public Boolean is_archived;
        public Integer num_members;

        public Integer compareTo(Object compareTo) {
            SlackChannel compareToEmp = (SlackChannel)compareTo;
            if (name == compareToEmp.name) return 0;
            if (name > compareToEmp.name) return 1;
            return -1;
        }
    }

    public class SlackServiceException extends Exception {}

}