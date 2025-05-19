@RestResource(urlMapping='/jiraPlugin/*')
global with sharing class JiraPluginWebService {

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Blob responseData = null;

        Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        Map<String, Object> output = new Map<String, Object>();
        Integer responseCode = 404;

        String method = (String)payload.get('method');
        Object inboundData = payload.get('data');

        try {
            if (method == 'validate') {
                output = new Map<String, Object>{
                    'status' => 'ok',
                    'data' => new Map<String, Object>{
                        'userId' => UserInfo.getUserId(),
                        'organizationId' => UserInfo.getOrganizationId()
                    }
                };
                responseCode = 200;
            } else if (method == 'logsChartMeta') {
                Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(inboundData));
                String logId = (String)input.get('logId');
                Log__c log = [SELECT Id, Name, Created_At__c FROM Log__c WHERE Id = :logId];
                output = new Map<String, Object>{
                    'status' => 'ok',
                    'data' => new Map<String, Object>{
                        'currentLog'=> new Map<String, Object>{
                            'Id' => log.Id,
                            'Created_At__c' => log.Created_At__c
                        }
                    }
                };
                responseCode = 200;
            } else if (method == 'remoteActionHandler') {

                Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(inboundData));

                String remoteActionPayload = (String)input.get('sfdcPayload');
                String remoteActionMethod = (String)input.get('sfdcMethod');

                Object results = new Map<String, Object>();

                if (remoteActionMethod == 'LogsChartsWrapperController.remoteActionHandler') {
                    results = LogsChartsWrapperController.remoteActionHandler(remoteActionPayload);

                    output = new Map<String, Object>{
                        'status' => 'ok',
                        'data' => new Map<String, Object>{
                            'input' => inboundData,
                            'results' => results
                        }
                    };
                    responseCode = 200;

                } else {
                    output = new Map<String, Object>{
                        'status' => 'error',
                        'error' => 'Remote Action not found'
                    };
                }

            } else {
                output = new Map<String, Object>{
                    'status' => 'error',
                    'error' => 'Method not found'
                };
            }
        } catch(Exception e) {
            output = new Map<String, Object>{
                'status' => 'error',
                'error' => e.getMessage()
            };
            Logger.getInstance().internalError(e, null, true, JiraPluginWebService.class.getName(), 'doPost');

        }
        responseData = Blob.valueOf(JSON.serialize(output));
        res.responseBody = responseData;
        res.statusCode = responseCode;
    }

    public class JiraPluginWebServiceException extends Exception {}

}