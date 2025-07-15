public without sharing class PlatformEventSubscriberConfigService {

    @TestVisible
    private final String PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME = 'PharosOrderEventTriggerConfig';
    private final String PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_AI_EVENT = 'PharosOrderEventTriggerConfigAIEvent';
    private final Integer PLATFORM_EVENT_SUBSCRIBER_CONFIG_BATCH_SIZE = 200;

    private final Map<String, String> PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_BY_SOBJECT_API_NAME = new Map<String, String>{
        Schema.SObjectType.AI_Event__e.getName() => PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_AI_EVENT,
        Schema.SObjectType.Log_Event__e.getName() => PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME
    };

    private final Map<String, String> PLATFORM_EVENT_SUBSCRIBER_CONFIG_TRIGGER_NAME_BY_SOBJECT_API_NAME = new Map<String, String>{
        Schema.SObjectType.AI_Event__e.getName() => ConfigUtil.PLATFORM_EVENT_SUBSCRIBER_CONFIG_TRIGGER_NAME_AI_EVENT,
        Schema.SObjectType.Log_Event__e.getName() => ConfigUtil.PLATFORM_EVENT_SUBSCRIBER_CONFIG_TRIGGER_NAME_LOG_EVENT
    };

    private SObjectType sobjectType;
    private String sObjectName;
    private String triggerId;
    
    public PlatformEventSubscriberConfigService(SObjectType sobjectType) {
        this.sobjectType = sobjectType;
        this.sObjectName = sobjectType.getDescribe().getName();
        this.triggerId = this.getPlatformEventSubscriberTriggerId();
    }

    public String getTriggerId() {
        return this.triggerId;
    }

    public String getUrlToPlatformEventSubscriberConfig() {
        return ConfigUtil.PLATFORM_EVENT_SUBSCRIPTION_CONFIG_URL + '?subscriptionName=' + this.triggerId.left(15) + '&topicApiName=' + this.sObjectName;
    }

    public Boolean isPlatformEventConfigSetupCompleted() {
        PlatformEventSubscriberConfigWrapper subscriberConfig = this.getPlatformEventSubscriberConfig(true);
        return subscriberConfig != null
            && String.isNotBlank(subscriberConfig.Id)
            && String.isNotBlank(subscriberConfig.userId)
            && String.isNotBlank(subscriberConfig.PlatformEventConsumerId);
    }

    public PlatformEventSubscriberConfigWrapper getPlatformEventSubscriberConfig(Boolean filterByTriggerId) {
        PlatformEventSubscriberConfigWrapper result = new PlatformEventSubscriberConfigWrapper();
        if (String.isNotBlank(this.triggerId)) {
            String query = new QBuilder('PlatformEventSubscriberConfig')
                    .selectFields(new Set<String>{'Id','UserId', 'PlatformEventConsumerId', 'DeveloperName', 'MasterLabel','BatchSize'})
                    .add(QBuilder.condition('DeveloperName').equalsTo(PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_BY_SOBJECT_API_NAME.get(this.sObjectName)))
                    .add(filterByTriggerId ? QBuilder.condition('PlatformEventConsumerId').equalsTo(this.triggerId) : null)
                    .addLimit(1)
                    .build();
            List<Object> records = HttpUtils.runToolingQuery(System.Url.getOrgDomainUrl().toExternalForm(), ConnectedOrgService.getSelfConnectedOrgAccessToken(), query, ConfigUtil.TOOLING_QUERY_API_ENDPOINT);
            if (records != null) {
                for (Object sobjectItem : records) {
                    PlatformEventSubscriberConfigWrapper w1 = (PlatformEventSubscriberConfigWrapper)JSON.deserialize(JSON.serialize(sobjectItem), PlatformEventSubscriberConfigWrapper.class);
                    result = w1;
                    break;
                }
            }
        }
        
        return result;
    }

    public PlatformEventSubscriberConfigWrapper setPlatformEventSubscriberConfig(String userId) {
        PlatformEventSubscriberConfigWrapper result = this.getPlatformEventSubscriberConfig(false);
        if (String.isNotBlank(this.triggerId)) {
            if (result == null || String.isBlank(result.Id)) {
                result = new PlatformEventSubscriberConfigWrapper();
                result.DeveloperName = PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_BY_SOBJECT_API_NAME.get(this.sObjectName);
                result.MasterLabel = PLATFORM_EVENT_SUBSCRIBER_CONFIG_NAME_BY_SOBJECT_API_NAME.get(this.sObjectName);
                result.PlatformEventConsumerId = this.triggerId;
                result.UserId = userId;
                result.BatchSize = PLATFORM_EVENT_SUBSCRIBER_CONFIG_BATCH_SIZE;
                HttpUtils.runToolingPost(System.Url.getOrgDomainUrl().toExternalForm(), ConnectedOrgService.getSelfConnectedOrgAccessToken(), JSON.serialize(result), ConfigUtil.TOOLING_API_UPDATE_PLATFORM_EVENT_SUBSCRIBER_CONFIG);
            }
            else if (result.UserId != userId || result.PlatformEventConsumerId != this.triggerId) {
                String recordId = result.Id;
                result.UserId = userId;
                result.PlatformEventConsumerId = this.triggerId;
                result.BatchSize = PLATFORM_EVENT_SUBSCRIBER_CONFIG_BATCH_SIZE;
                result.Id = null;
                HttpUtils.runToolingPatch(System.Url.getOrgDomainUrl().toExternalForm(), ConnectedOrgService.getSelfConnectedOrgAccessToken(), JSON.serialize(result), ConfigUtil.TOOLING_API_UPDATE_PLATFORM_EVENT_SUBSCRIBER_CONFIG + '/' + recordId);
            }
        }
        
        return result;
    }

    private String getPlatformEventSubscriberTriggerId() {
        List<ApexTrigger> triggers = this.getApexTriggers();

        return !triggers.isEmpty() ? triggers.get(0).Id : null;     
    }

    private List<ApexTrigger> getApexTriggers() {
        return [
            SELECT Id
            FROM ApexTrigger 
            WHERE NamespacePrefix =: ConfigUtil.NS
                AND (Name =: PLATFORM_EVENT_SUBSCRIBER_CONFIG_TRIGGER_NAME_BY_SOBJECT_API_NAME.get(this.sObjectName)
                    OR TableEnumOrId =: this.sObjectName
                )
            LIMIT 1
        ];
    }

    public class PlatformEventSubscriberConfigWrapper {
        public String Id;
        public String DeveloperName;
        public String MasterLabel;
        public String UserId;
        public String PlatformEventConsumerId;
        public Integer BatchSize;

        public PlatformEventSubscriberConfigWrapper() {}
    }
}