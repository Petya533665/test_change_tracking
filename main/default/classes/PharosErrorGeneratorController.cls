public with sharing class PharosErrorGeneratorController {

    private static final String BASE_URL = System.Url.getOrgDomainUrl().toExternalForm();
    private static final String TOOLING_API_ENDPOINT = BASE_URL + '/services/data/v53.0/tooling/query?q=';
    private static final String REST_API_ENDPOINT = BASE_URL + '/services/apexrest/test/test';
    private static final String BULK_API_V1_ENDPOINT = BASE_URL + '/services/async/53.0/job';
    private static final String BULK_API_V2_ENDPOINT = BASE_URL + '/services/data/v53.0/jobs/ingest';
    private static final String METHOD_POST = 'POST';
    private static final String METHOD_PUT = 'PUT';
    private static final String METHOD_PATCH = 'PATCH';
    private static final String METHOD_GET = 'GET';

    private static Map<String, String> AUTHORIZATION_HEADERS = new Map<String, String>{
        'Authorization' => 'Bearer ' + UserInfo.getSessionId()
    };
    private static Map<String, String> X_SFDC_SESSION_HEADERS = new Map<String, String>{
        'X-SFDC-Session' => UserInfo.getSessionId()
    };

    @TestVisible
    private static final String FLOW_1_ERROR = 'Flow #1',
        FLOW_2_ERROR = 'Flow #2',
        PROCESS_BUILDER_ERROR = 'Process Builder',
        APEX_ERROR = 'Apex',
        INTEGRATION_ERROR = 'Integration',
        REST_API_ERROR = 'REST API',
        ASYNC_JOB_ERROR = 'Async Job',
        BULK_API_V1_ERROR = 'Bulk API v1',
        BULK_API_V2_ERROR = 'Bulk API v2';

    @TestVisible
    private static final String FLOW_ERROR_CATEGORY = 'Flow',
        PROCESS_BUILDER_ERROR_CATEGORY = 'Process Builder',
        APEX_ERROR_CATEGORY = 'Apex',
        INTEGRATION_ERROR_CATEGORY = 'Integration',
        REST_API_ERROR_CATEGORY = 'Integration',
        ERROR_ERROR_CATEGORY = 'Error',
        BULK_API_V1_ERROR_CATEGORY = 'Bulk API v1',
        BULK_API_V2_ERROR_CATEGORY = 'Bulk API v2';

    private static final Map<String, String> MAP_ERROR_CATEGORY_BY_ERROR = new Map<String, String>{
        FLOW_1_ERROR => FLOW_ERROR_CATEGORY,
        FLOW_2_ERROR => FLOW_ERROR_CATEGORY,
        PROCESS_BUILDER_ERROR => PROCESS_BUILDER_ERROR_CATEGORY,
        APEX_ERROR => APEX_ERROR_CATEGORY,
        INTEGRATION_ERROR => INTEGRATION_ERROR_CATEGORY,
        REST_API_ERROR => REST_API_ERROR_CATEGORY,
        ASYNC_JOB_ERROR => ERROR_ERROR_CATEGORY,
        BULK_API_V1_ERROR => BULK_API_V1_ERROR_CATEGORY,
        BULK_API_V2_ERROR => BULK_API_V2_ERROR_CATEGORY
    };

    @AuraEnabled
    public static List<String> getErrors() {
        return new List<String>(MAP_ERROR_CATEGORY_BY_ERROR.keySet());
    }

    @AuraEnabled
    public static petriv__Log__c getLog(String error, String strDatetime) {
        List<petriv__Log__c> logs = [
            SELECT Id, Name
            FROM petriv__Log__c
            WHERE petriv__Category__c = :MAP_ERROR_CATEGORY_BY_ERROR.get(error)
            AND CreatedDate >= :Datetime.valueOfGmt(strDatetime)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!logs.isEmpty()) {
            return logs[0];
        }
        return null;
    }

    @AuraEnabled
    public static String generateError(String error) {
        String result = String.valueOfGmt(System.now());
        if (error.equals(FLOW_1_ERROR)) {
            generateFlow1Error();
        } else if (error.equals(FLOW_2_ERROR)) {
            generateFlow2Error();
        } else if (error.equals(PROCESS_BUILDER_ERROR)) {
            generateProcessBuilderError();
        } else if (error.equals(APEX_ERROR)) {
            generateApexError();
        } else if (error.equals(INTEGRATION_ERROR)) {
            generateIntegrationError();
        } else if (error.equals(REST_API_ERROR)) {
            generateRESTAPIError();
        } else if (error.equals(ASYNC_JOB_ERROR)) {
            Database.executeBatch(new PharosErrorGeneratorBatch(true));
        } else if (error.equals(BULK_API_V1_ERROR)) {
            generateBulkAPIv1Error();
        } else if (error.equals(BULK_API_V2_ERROR)) {
            generateBulkAPIv2Error();
        }
        return result;
    }

    @Future
    private static void generateFlow1Error() {
        try {
            Flow.Interview flow1Error = Flow.Interview.createInterview('Flow_1_Error', new Map<String, Object>());
            flow1Error.start();
        } catch (Exception e) {}
    }

    @Future
    private static void generateFlow2Error() {
        try {
            Flow.Interview flow2Error = Flow.Interview.createInterview('Flow_2_Error', new Map<String, Object>());
            flow2Error.start();
        } catch (Exception e) {}
    }

    @Future
    private static void generateProcessBuilderError() {
        try {
            Triton_Error_Data__c tritonErrorData = new Triton_Error_Data__c();
            tritonErrorData.Name = 'Process Builder Error';
            tritonErrorData.Description__c = 'Process Builder Error';
            insert tritonErrorData;
        } catch (DmlException e) {
        }
    }

    @Future
    private static void generateApexError() {
        Decimal averageFrequency = 0;
        Set<Id> tritonErrorDataIds = new Set<Id>();
        for (Integer i = 10; i >= 0; i--) {
            List<Triton_Error_Data__c> tritonErrorDataList = [SELECT Id FROM Triton_Error_Data__c LIMIT :i];
            for (Triton_Error_Data__c currentTritonErrorData : tritonErrorDataList) {
                tritonErrorDataIds.add(currentTritonErrorData.Id);
            }
            averageFrequency += tritonErrorDataIds.size() / i;
        }
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'Apex Error';
        contentVersion.Title = 'Apex Error';
        contentVersion.PathOnClient = 'ApexError.pdf';
        insert contentVersion;
    }

    @Future(Callout=true)
    private static void generateIntegrationError() {
        List<Triton_Error_Data__c> tritonErrorDataRecords = [SELECT Id FROM Triton_Error_Data__c LIMIT 1];
        if (!tritonErrorDataRecords.isEmpty()) {
            update tritonErrorDataRecords;
        }
        String query = 'SELECT Id FROM AsyncApexJob LIMIT 5';
        AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeJSON());
        httpRequest(
            TOOLING_API_ENDPOINT + EncodingUtil.urlEncode(query, 'UTF-8'),
            METHOD_GET,
            AUTHORIZATION_HEADERS,
            null
        );
    }

    @Future(Callout=true)
    private static void generateRESTAPIError() {
        AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeJSON());
        httpRequest(
            REST_API_ENDPOINT,
            METHOD_GET,
            AUTHORIZATION_HEADERS,
            null
        );
    }

    @Future(Callout=true)
    private static void generateBulkAPIv1Error() {
        X_SFDC_SESSION_HEADERS.putAll(getHeadersContentTypeJSON());
        Map<String, Object> job = (Map<String, Object>)JSON.deserializeUntyped(
            httpRequest(
                BULK_API_V1_ENDPOINT,
                METHOD_POST,
                X_SFDC_SESSION_HEADERS,
                '{"operation":"insert","object":"Triton_Error_Data__c","contentType":"JSON"}'
            )
        );
        httpRequest(
            BULK_API_V1_ENDPOINT + '/' + job.get('id') + '/batch',
            METHOD_POST,
            X_SFDC_SESSION_HEADERS,
            '[{"Name":"Bulk API v1 Error","Description__c":"123"}]'
        );
        httpRequest(
            BULK_API_V1_ENDPOINT + '/' + job.get('id'),
            METHOD_POST,
            X_SFDC_SESSION_HEADERS,
            '{"state":"Closed"}'
        );
    }

    @Future(Callout=true)
    private static void generateBulkAPIv2Error() {
        AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeJSON());
        Map<String, Object> job = (Map<String, Object>)JSON.deserializeUntyped(
            httpRequest(
                BULK_API_V2_ENDPOINT,
                METHOD_POST,
                AUTHORIZATION_HEADERS,
                '{"operation":"insert","object":"Triton_Error_Data__c","contentType":"CSV"}'
            )
        );
        AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeCSV());
        httpRequest(
            BULK_API_V2_ENDPOINT + '/' + job.get('id') + '/batches',
            METHOD_PUT,
            AUTHORIZATION_HEADERS,
            'Name,Description__c\n"Bulk API v2 Error","123"'
        );
        AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeJSON());
        httpRequest(
            BULK_API_V2_ENDPOINT + '/' + job.get('id'),
            METHOD_PATCH,
            AUTHORIZATION_HEADERS,
            '{"state":"UploadComplete"}'
        );
    }

    private static String httpRequest(String endpoint, String method, Map<String, String> headers, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        if (String.isNotBlank(body)) req.setBody(body);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res;
        try {
            res = h.send(req);
        } catch (Exception e) {
            Triton.instance.integrationError(TritonTypes.Area.Community, e, req, res);
        }
        if (res != null && res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            Triton.instance.integrationError(TritonTypes.Type.Backend, TritonTypes.Area.Community, res.getStatus(), res.getStatus(), req, res);
        }
        return res != null ? res.getBody() : null;
    }

    private static Map<String, String> getHeadersContentTypeJSON() {
        return new Map<String, String>{
            'Content-Type' => 'application/json'
        };
    }

    private static Map<String, String> getHeadersContentTypeCSV() {
        return new Map<String, String>{
            'Content-Type' => 'text/csv'
        };
    }

    public class PharosErrorGeneratorControllerException extends Exception {}
}