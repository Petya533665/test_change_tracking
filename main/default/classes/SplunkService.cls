public without sharing class SplunkService {

    public static String generateToken(String username, String password) {
        String b = HttpUtils.post(
            ConfigUtil.SPLUNK_TOKEN_ENDPOINT,
            'username='+username+'&password='+password,
            ConfigUtil.SPLUNK_API_TOKEN_HEADERS,
            200
        );
        SplunkLoginResponse response = (SplunkLoginResponse)JSON.deserialize(b, SplunkLoginResponse.class);
        return response.sessionKey;
    }

    public static void sendMessage(String message) {
        String massageToken = 'm_' + String.valueOf(Datetime.now().getTime()/1000);
        String body = 'name='+massageToken+'&value='+message;
        String b = HttpUtils.post(
            ConfigUtil.SPLUNK_MESSAGES_ENDPOINT,
            body,
            ConfigUtil.SPLUNK_API_HEADERS,
            201
        );
    }

    public static List<String> DEFAULT_LOG_FIELDS_FOR_SPLUNK = new List<String>{
        'Id',
        'Name',
        'Summary__c',
        'Apex_Name__c',
        'Namespace__c',
        'Visualforce_Page__c',
        'Area__c',
        'Async_Job_Name__c',
        'Category__c',
        'Type__c',
        'User_Id__c',
        'Hash_1__c',
        'Hash_2__c',
        'Hash_3__c',
        'Related_Id__c',
        'Related_Object_Type__c',
        'Total_Active_Sessions__c',
        'Created_At__c',
        'First_Occurred_On__c'
    };

    public static List<String> EXCLUDE_LOG_FIELDS_FOR_SPLUNK = new List<String>{
        'OwnerId',
        'IsDeleted',
        'CreatedDate',
        'CreatedById',
        'LastModifiedDate',
        'LastModifiedById',
        'SystemModstamp',
        'LastActivityDate',
        'LastViewedDate',
        'LastReferencedDate',
        'Details__c',
        'Icon__c',
        'Stacktrace__c',
        'Stacktrace_Parse_Result__c',
        'User__c',
        'Bug_Tracker__c',
        'Pending_Jobs__c',
        'Installed_Packages__c',
        'Setup_Audit_Trail__c',
        'Deploy_Results__c',
        'Is_New__c',
        'Related_Object__c',
        'Post_Processing__c',
        'Sent_To_Splunk__c',
        'Splunk_Link__c'

    };

    public static List<String> getLogFieldsForSplunk() {
        return ConfigUtil.SPLUNK_FIELDS.splunk_fields;
    }


    @Future(Callout=true)
    public static void sendLogAsync(Id logId) {
        sendLog(logId);
    }

    public static void sendLog(List<Log__c> logs) {
        Log__c log = logs.get(0);
        sendLog(log.Id);
    }

    public static void sendLog(Id logId) {
        Set<String> fieldsFromConfig = new Set<String>(getLogFieldsForSplunk());
        if (fieldsFromConfig.isEmpty()) return;
        fieldsFromConfig.add('Created_At__c');
        fieldsFromConfig.add('Sent_To_Splunk__c');
        Set<String> setFields = new Set<String>();
        for (String fieldFromConfig : fieldsFromConfig) {
            setFields.add(fieldFromConfig.replace(ConfigUtil.getNameSpacePrefix(), ''));
        }
        String q = 'SELECT '+String.join(new List<String>(setFields), ',')+' FROM Log__c WHERE Id = :logId';
        Log__c log = Database.query(q);

        if (log.Sent_To_Splunk__c != null) {
            throw new SplunkServiceException('Log with ID '+log.Id+' was already sent to Splunk');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ConfigUtil.SPLUNK_SETTINGS.Splunk_Url__c + ':8088/services/collector/event');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Splunk '+ConfigUtil.SPLUNK_SETTINGS.Splunk_Event_Collector_Token__c);
        req.setTimeout(120000);

        List<String> messageItems = new List<String>();
        for (String f : getLogFieldsForSplunk()) {
            String v;
            try {
                v = String.valueOf(log.get(f.replace(ConfigUtil.getNameSpacePrefix(), '')));
            } catch(Exception e) {
                continue;
            }
            messageItems.add(f.replace(ConfigUtil.getNameSpacePrefix(), '')+'='+JSON.serialize(v)); // v.replace('"', '\\"')
        }

        String message = String.join(messageItems, ' ');

        Map<String, Object> messageObj = new Map<String, Object> {
            'event' => message,
            'time' => log.Created_At__c != null ? log.Created_At__c.getTime() : Datetime.now().getTime()
        };

        String body = JSON.serialize(messageObj);

        req.setBody(body);

        Http h = new Http();
        HttpResponse res = h.send(req);

        String responseStr = res.getBody();
        if (res.getStatusCode() == 200 && responseStr.startsWith('{')) {
            PermissionsUtil.putSObjectField(log, Schema.SObjectType.Log__c.fields.Sent_To_Splunk__c, Datetime.now());
            if (log.Id != null) {
                DatabaseUtils.getInstance().performUpdateDML(new List<Log__c>{log}, Schema.SObjectType.Log__c)
                        .handleError(SplunkService.class.getName(), '.sendLog');
            }
        }
        else {
            throw new SplunkServiceException(res.getStatusCode() + ' || '+ responseStr);
        }
    }

    class SplunkLoginResponse {
        public String sessionKey;
        public String message;
        public String code;
    }

    public class SplunkServiceException extends Exception {}

}