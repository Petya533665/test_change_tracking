public with sharing class BroadcastService {

    public static final String BROADCAST_STATUS_NEEDED = 'Needed';
    public static final String BROADCAST_STATUS_COMPLETED = 'Completed';

    private static final Integer MAX_SIZE_OF_BYTE_LENGTH = 12000000;

    public static Integer queryLimit {
        get {
            if (queryLimit == null) {
                Integer byteLength = 0;
                for (SObjectField field : Log__c.SObjectType.getDescribe().fields.getMap().values()) {
                    byteLength += field.getDescribe().getByteLength();
                }
                queryLimit = Integer.valueOf(Math.floor(MAX_SIZE_OF_BYTE_LENGTH / byteLength));
            }
            return queryLimit;
        }
        private set;
    }

    public static void parseIncomingData(IncomingData data) {
        if (String.isNotBlank(data.organizationId)) {
            Connected_Org__c corg;
            for (Connected_Org__c connectedOrg : ConnectedOrgService.getBroadcastConnectedOrgs(ConnectedOrgService.BROADCAST_RECEIVE_FROM)) {
                if (connectedOrg.Name == data.organizationId.left(15)) {
                    corg = connectedOrg;
                    break;
                }
            }
            if (corg != null) {
                if (data.logs != null && !data.logs.isEmpty()) {
                    List<Log__c> logsForInsert = new List<Log__c>();
                    List<Log__c> logsForUpdate = new List<Log__c>();
                    Map<String, Schema.RecordTypeInfo> mapRecordTypesByName = Schema.SObjectType.Log__c.getRecordTypeInfosByName();
                    Set<String> externalIds = new Set<String>();
                    Map<String, String> mapExternalIds = new Map<String, String>();
                    for (Log__c log : data.logs) {
                        if(String.isNotBlank(log.External_Id__c)) {
                            externalIds.add(log.External_Id__c);
                        }
                    }
                    if(!externalIds.isEmpty()) {
                        for(Log__c log : [SELECT Id, External_Id__c FROM Log__c WHERE External_Id__c IN :externalIds]) {
                            mapExternalIds.put(log.External_Id__c, log.Id);
                        }
                    }
                    for (Log__c log : data.logs) {
                        if (String.isNotBlank(String.valueOf(log.RecordTypeId))) {
                            log.RecordTypeId = mapRecordTypesByName.get(data.mapRecordTypesById.get(log.RecordTypeId)).getRecordTypeId();
                        }
                        Map<String, Object> mapLog = new Map<String, Object>(log.getPopulatedFieldsAsMap());
                        for (Schema.SObjectField sObjectField : Schema.SObjectType.Log__c.getSObjectType().getDescribe().fields.getMap().values()) {
                            if (String.valueOf(sObjectField.getDescribe().getType()) == 'REFERENCE' && sObjectField.getDescribe().getName() != 'RecordTypeId') {
                                mapLog.remove(sObjectField.getDescribe().getName());
                            }
                        }
                        String externalId = mapExternalIds.containsKey(log.External_Id__c) ? mapExternalIds.get(log.External_Id__c) : null;
                        if(String.isNotBlank(externalId)) {
                            Log__c logForUpdate = (Log__c)JSON.deserialize(JSON.serialize(mapLog), Log__c.class);
                            PermissionsUtil.putSObjectField(logForUpdate, Schema.SObjectType.Log__c.fields.Id, externalId);
                            logsForUpdate.add(logForUpdate);
                        }
                        else {
                            logsForInsert.add((Log__c)JSON.deserialize(JSON.serialize(mapLog), Log__c.class));
                        }
                    }
                    if (!logsForInsert.isEmpty()) {
                        PermissionsUtil.putSObjectFields(logsForInsert, Schema.SObjectType.Log__c.fields.Organization_Name__c, corg.Title__c, true);
                        PermissionsUtil.putSObjectFields(logsForInsert, Schema.SObjectType.Log__c.fields.Originated_From__c, ConfigUtil.ORIGINATED_FROM_BROADCAST, true);
                        PermissionsUtil.putSObjectFields(logsForInsert, Schema.SObjectType.Log__c.fields.Broadcast_Status__c, BROADCAST_STATUS_COMPLETED, true);
                        DatabaseUtils.getInstance().performInsertDML(logsForInsert, Schema.SObjectType.Log__c)
                                .handleError(BroadcastService.class.getName(), '.parseIncomingData');
                    }
                    if (!logsForUpdate.isEmpty()) {
                        PermissionsUtil.putSObjectFields(logsForUpdate, Schema.SObjectType.Log__c.fields.Organization_Name__c, corg.Title__c, true);
                        PermissionsUtil.putSObjectFields(logsForUpdate, Schema.SObjectType.Log__c.fields.Originated_From__c, ConfigUtil.ORIGINATED_FROM_BROADCAST, true);
                        PermissionsUtil.putSObjectFields(logsForUpdate, Schema.SObjectType.Log__c.fields.Broadcast_Status__c, BROADCAST_STATUS_COMPLETED, true);
                        DatabaseUtils.getInstance().performUpdateDML(logsForUpdate, Schema.SObjectType.Log__c)
                                .handleError(BroadcastService.class.getName(), '.parseIncomingData');
                    }

                } else if (data.contentVersionWrapper != null) {
                    ContentVersion contentVersion = data.contentVersionWrapper.contentVersion;
                    contentVersion.VersionData = Blob.valueOf(data.contentVersionWrapper.contentVersionData);
                    DatabaseUtils.getInstance().performInsertDML(new List<ContentVersion>{contentVersion}, Schema.SObjectType.ContentVersion)
                            .handleError(BroadcastService.class.getName(), '.parseIncomingData');
                }
            }
        }
    }

    public class IncomingData {
        public List<Log__c> logs;
        public Map<String, String> mapRecordTypesById;
        public BulkAPIJobBatchService.ContentVersionWrapper contentVersionWrapper;
        public String organizationId;
    }

    public class BroadcastServiceException extends Exception {}

}