public with sharing class DataDirectionService {

    public static void sendLog(Log__c log) {
        sendLogs(new List<Log__c>{log});
    }

    public static void sendLogs(List<Log__c> logs) {
        List<Connected_Org__c> connectedOrgs = ConnectedOrgService.getDataDirectionConnectedOrgs(ConnectedOrgService.DATA_DIRECTION_SEND_TO);
        if (!connectedOrgs.isEmpty()) {
            System.enqueueJob(new DataDirectionQueueable(logs, connectedOrgs));
        } else {
            throw new DataDirectionServiceException(ConfigUtil.CONNECTED_ORG_NOT_FOUND_DATA_DIRECTION);
        }
    }

    public class DataDirectionQueueable implements Queueable, Database.AllowsCallouts {
        private List<Log__c> logs;
        private List<Connected_Org__c> connectedOrgs;
        public DataDirectionQueueable(List<Log__c> logs, List<Connected_Org__c> connectedOrgs) {
            this.logs = logs;
            this.connectedOrgs = connectedOrgs;
        }
        public void execute(QueueableContext context) {
            String body = JSON.serialize(new Map<String, Object>{
                    'logs' => logs,
                    'organizationId' => UserInfo.getOrganizationId()
            });
            for (Connected_Org__c corg : connectedOrgs) {
                String b = HttpUtils.post(
                        corg.Instance_Url__c + ConfigUtil.PHAROS_REST_SERVICE_ENDPOINT + '?' + ConfigUtil.PARAMS_TYPE + '=' + ConfigUtil.TYPE_DATA_DIRECTION,
                        body,
                        ConfigUtil.getSFRestAPIHeaders(corg.Access_Token__c),
                        200
                );
            }
        }
    }

    public static void parseIncomingData(IncomingData data) {
        if (String.isNotBlank(data.organizationId)) {
            Boolean exist = false;
            for (Connected_Org__c corg : ConnectedOrgService.getDataDirectionConnectedOrgs(ConnectedOrgService.DATA_DIRECTION_RECEIVE_FROM)) {
                if (corg.Name == data.organizationId.left(15)) {
                    exist = true;
                    break;
                }
            }
            if (exist) {
                if (data.logs != null) {
                    PermissionsUtil.performInsertDML(data.logs, Schema.SObjectType.Log__c);
                } else if (data.contentVersionWrapper != null) {
                    ContentVersion contentVersion = data.contentVersionWrapper.contentVersion;
                    contentVersion.VersionData = Blob.valueOf(data.contentVersionWrapper.contentVersionData);
                    insert contentVersion;
                }
            }
        }
    }

    public class IncomingData {
        public List<Log__c> logs;
        public BulkAPIJobBatchService.ContentVersionWrapper contentVersionWrapper;
        public String organizationId;
    }

    public class DataDirectionServiceException extends Exception {}

}