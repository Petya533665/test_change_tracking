public with sharing class LogEventTriggerHandler {

    @TestVisible
    private static final DateTime testCreatedAt = Datetime.now();

    public static void logEventHandler(List<Log_Event__e> events) {
        List<Log__c> allLogs = new List<Log__c>();
        Datetime createAt = (Test.isRunningTest()) ? testCreatedAt : Datetime.now();

        for (Log_Event__e event : events) {
            List<Log__c> logs = (List<Log__c>)JSON.deserialize(event.body__c, List<Log__c>.class);
            allLogs.addAll(logs);
        }

        if (!allLogs.isEmpty()) {
            addOrgInfoForManualLog(allLogs, createAt);
            Database.SaveResult[] saveResults = DatabaseUtils.getInstance().performInsertDML(allLogs, Schema.SObjectType.Log__c)
                .handleError(LogEventTriggerHandler.class.getName(), '.logEventHandler').saveResults;
            logSaveResults(saveResults, allLogs);
        }
    }

    public static void addOrgInfoForManualLog(List<Log__c> logs, Datetime createdAt) {
        for (Log__c log : logs) {
            log.Created_At__c = (log.Created_At__c == null) ? createdAt : log.Created_At__c;
            log.Organization_Id__c = (String.isBlank(log.Organization_Id__c)) ? UserInfo.getOrganizationId() : log.Organization_Id__c;
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(log.Organization_Id__c);
            if (corg != null) {
                log.Organization_Name__c = corg.Title__c;
                log.Organization_Url__c = corg.Instance_Url__c;
            }
            LogService.calculateHashes(log);
        }
    }

    private static void logSaveResults(Database.SaveResult[] results, Log__c[] queue) {
        Log__c[] logs = new Log__c[0];
        Integer index = 0;
        for(Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                String details = '';
                for (Database.Error err : sr.getErrors()) {
                    details += err.getStatusCode() + ': ' + err.getMessage() + '\n\n';
                    if(err.getFields().size() > 0) {
                        details += 'Fields: ' + err.getFields() + '\n\n';
                    }
                }

                details += JSON.serializePretty(queue[index]);

                Log__c log = LogBuilder.getInstance()
                    .category(Logger.CATEGORY_PHAROS_ERROR)
                    .summary('Unable to save log records')
                    .details(details)
                    .area(Logger.AREA_PHAROS_ERROR)
                    .type(System.DmlException.class.getName())
                    .attribute(Schema.SObjectType.Log__c.fields.Organization_Id__c.Name, UserInfo.getOrganizationId().left(15))
                    .attribute(Schema.SObjectType.Log__c.fields.Hash__c.Name, LogService.generateHash_0(details))
                    .attribute(Schema.SObjectType.Log__c.fields.Hash_1__c.Name, LogService.generateHash_1(details))
                    .attribute(Schema.SObjectType.Log__c.fields.Hash_2__c.Name, LogService.generateHash_2(details))
                    .attribute(Schema.SObjectType.Log__c.fields.Hash_3__c.Name, LogService.generateHash_3(details))
                    .build();
                logs.add(log);
            }
            index++;
        }
        DatabaseUtils.getInstance().performInsertDML(logs, Schema.SObjectType.Log__c)
                .handleError(LogEventTriggerHandler.class.getName(), '.logSaveResults');
    }

}