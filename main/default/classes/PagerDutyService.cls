public without sharing class PagerDutyService {

    public static void createIncident(String title, String details) {
        if(!PermissionsUtil.PagerDutyIntegrationEnabled) return;

        if (!ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c) ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_ID__c) ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_User_Email__c)
        ) {
            throw new PagerDutyServiceException('PagerDuty settings are invalid');
        }

        Map<String, Object> payload = new Map<String, Object>{
            'incident' => new Map<String, Object> {
                'type' => 'incident',
                'title' => title,
                'service' => new Map<String, Object> {
                    'id' => ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_ID__c,
                    'type' => 'service_reference'
                },
                'body' => new Map<String, Object> {
                    'type' => 'incident_body',
                    'details' => details
                }
            }
        };

        String b = HttpUtils.post(
            ConfigUtil.PAGER_DUTY_INCIDENT_ENDPOINT,
            JSON.serialize(payload),
            ConfigUtil.PAGER_DUTY_HEADERS,
            201
        );

    }

    public static void createEvent(String eventKey, String severity, String summary) {
        if(!PermissionsUtil.PagerDutyIntegrationEnabled) return;

        // https://v2.developer.pagerduty.com/docs/send-an-event-events-api-v2

        if (!ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c) ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_Integration_Key__c)
        ) {
            throw new PagerDutyServiceException('PagerDuty settings are invalid');
        }

        Map<String, Object> payload = new Map<String, Object>{
            'routing_key' => ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Service_Integration_Key__c,
            'event_action' => 'trigger',
            'dedup_key' => eventKey,  // String.valueOf(Datetime.now.getTime()),
            'images' => new List<String>(),
            'links' => new List<String>(),
            'payload' => new Map<String, Object> {
                'summary' => summary,
                'source' => 'Pharos',
                'severity' => new Set<String>(ConfigUtil.EVENT_SEVERITY).contains(severity) ? severity : 'info'
            }
        };

        String b = HttpUtils.post(
            ConfigUtil.PAGER_DUTY_EVENTS_ENDPOINT,
            JSON.serialize(payload),
            ConfigUtil.PAGER_DUTY_EVENTS_HEADERS,
            202
        );
    }

    public static List<PagerDutyServiceWrapper> getServices() {

        if (!ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_Enabled__c ||
            String.isBlank(ConfigUtil.PAGER_DUTY_SETTINGS.PagerDuty_API_Token__c)
        ) {
            throw new PagerDutyServiceException('PagerDuty settings are invalid');
        }

        String b = HttpUtils.get(
            ConfigUtil.PAGER_DUTY_SERVICES_ENDPOINT,
            ConfigUtil.PAGER_DUTY_HEADERS,
            200
        );
        PagerDutyServicesResponse resp = (PagerDutyServicesResponse)JSON.deserialize(b, PagerDutyServicesResponse.class);
        return resp.services;
    }

    public class PagerDutyServicesResponse {
        public List<PagerDutyServiceWrapper> services;
    }

    public class PagerDutyServiceWrapper {
        public String id;
        public String name;
    }

    public class PagerDutyServiceException extends Exception {}

}