public with sharing class EventRecordDetailsController {

    public String eventJson { get; set; }
    public String logData { get; set; }
    public Boolean isDev { get; set; }
    public String packageNamespace { get {return Configutil.getNameSpacePrefix();} set; }
    public static String baseUrl { get{
        return System.URL.getOrgDomainUrl().toExternalForm();
    } set; }

    public EventRecordDetailsController(ApexPages.StandardController stdController) {
        System.PageReference pageReference = ApexPages.currentPage();
		String recordId = pageReference.getParameters().get('recordId');
        isDev = ConfigUtil.initializeDevelopmentMode(pageReference);

        Event__c event = [
            SELECT Id, Name, Records__c
            FROM Event__c
            WHERE Id = :recordId
        ];


        eventJson = JSON.serialize(event);
        logData = EventsChartsWrapperController.getLogsJson(event.Records__c);
    }

    @AuraEnabled
    public static List<LogData> getLogsData(String recordId) {
        List<LogData> logData = new List<LogData>();
        List<Event__c> events = [SELECT Id, Records__c FROM Event__c WHERE Id = :recordId];
        if (!events.isEmpty() && String.isNotBlank(events[0].Records__c)) {
            List<String> logIds = EventsChartsWrapperController.parseIds(events[0].Records__c);
            List<Log__c> eventLogs = [
                    SELECT Id, Name, Hash_1__c, Created_At__c, Summary__c, Type__c, Category__c
                    FROM Log__c
                    WHERE Id IN: logIds
                    ORDER BY Created_At__c];
            for (Log__c log : eventLogs) {
                logData.add(new LogData(log));
            }
        }
        return logData;
    }

    public class LogData {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String summary;
        @AuraEnabled
        public Datetime createdAt;
        @AuraEnabled
        public String url;
        public LogData(Log__c log) {
            id = log.Id;
            name = log.Name;
            category = log.Category__c;
            type = log.Type__c;
            summary = log.Summary__c;
            createdAt = log.Created_At__c;
            url = System.Url.getOrgDomainUrl().toExternalForm() + '/' + log.Id;
        }
    }

}