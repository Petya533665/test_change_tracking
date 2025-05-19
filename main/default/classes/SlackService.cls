public without sharing class SlackService {

    public static void sendMessageToSlack(String message, String slack_channel_id) {

        if(!PermissionsUtil.SlackIntegrationEnabled) return;

        if (!ConfigUtil.SLACK_SETTINGS.Slack_Enabled__c ||
            ConfigUtil.SLACK_SETTINGS.Slack_API_Token__c == null ||
            slack_channel_id == null) {
            throw new SlackServiceException('Slack settings are invalid');
        }

        Map<String, Object> payload = new Map<String, Object>{
            'channel' => slack_channel_id,
            'text' => message
        };

        String b = HttpUtils.post(
            ConfigUtil.SLACK_POST_MESSAGE_ENDPOINT,
            JSON.serialize(payload),
            ConfigUtil.SLACK_API_HEADERS,
            200
        );
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