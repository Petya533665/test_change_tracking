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
			PLATFORM_EVENT_ERROR = 'Platform Event',
			BULK_API_V1_ERROR = 'Bulk API v1',
			BULK_API_V2_ERROR = 'Bulk API v2',
			LWC_ERROR = 'LWC';

	@TestVisible
	private static final String FLOW_ERROR_CATEGORY = 'Flow',
			PROCESS_BUILDER_ERROR_CATEGORY = 'Process Builder',
			APEX_ERROR_CATEGORY = 'Apex',
			INTEGRATION_ERROR_CATEGORY = 'Integration',
			REST_API_ERROR_CATEGORY = 'Integration',
			ERROR_ERROR_CATEGORY = 'Error',
			BULK_API_V1_ERROR_CATEGORY = 'Bulk API v1',
			BULK_API_V2_ERROR_CATEGORY = 'Bulk API v2',
			LWC_ERROR_CATEGORY = 'LWC';

	private static final Map<String, String> MAP_ERROR_CATEGORY_BY_ERROR = new Map<String, String>{
			FLOW_1_ERROR => FLOW_ERROR_CATEGORY,
			FLOW_2_ERROR => FLOW_ERROR_CATEGORY,
			PROCESS_BUILDER_ERROR => PROCESS_BUILDER_ERROR_CATEGORY,
			APEX_ERROR => APEX_ERROR_CATEGORY,
			INTEGRATION_ERROR => INTEGRATION_ERROR_CATEGORY,
			REST_API_ERROR => REST_API_ERROR_CATEGORY,
			PLATFORM_EVENT_ERROR => ERROR_ERROR_CATEGORY,
			BULK_API_V1_ERROR => BULK_API_V1_ERROR_CATEGORY,
			BULK_API_V2_ERROR => BULK_API_V2_ERROR_CATEGORY,
			LWC_ERROR => LWC_ERROR_CATEGORY
	};

	@AuraEnabled
	public static List<String> getErrors() {
		return new List<String>(MAP_ERROR_CATEGORY_BY_ERROR.keySet());
	}

	@AuraEnabled
	public static pharos__Log__c getLog(String error, String strDatetime) {
		List<pharos__Log__c> logs = [
				SELECT Id, Name
				FROM pharos__Log__c
				WHERE pharos__Category__c = :MAP_ERROR_CATEGORY_BY_ERROR.get(error)
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
		if (error == FLOW_1_ERROR) {
			generateFlow1Error();
		} else if (error == FLOW_2_ERROR) {
			generateFlow2Error();
		} else if (error == PROCESS_BUILDER_ERROR) {
			generateProcessBuilderError();
		} else if (error == APEX_ERROR) {
			generateApexError();
		} else if (error == INTEGRATION_ERROR) {
			generateIntegrationError();
		} else if (error == REST_API_ERROR) {
			generateRESTAPIError();
		}  else if (error == PLATFORM_EVENT_ERROR) {
			Database.executeBatch(new PlatformEventBatch(true));
		} else if (error == BULK_API_V1_ERROR) {
			generateBulkAPIv1Error();
		} else if (error == BULK_API_V2_ERROR) {
			generateBulkAPIv2Error();
		} else if (error == LWC_ERROR) {
			throw new PharosErrorGeneratorControllerException('LWC Error');
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
			Account account = new Account();
			account.Name = 'Process Builder Error';
			account.Description = 'Process Builder Error';
			insert account;
		} catch (DmlException e) {
		}
	}

	@Future
	private static void generateApexError() {
		Decimal averageFrequency = 0;
		Set<Id> contactIds = new Set<Id>();
		for (Integer i = 10; i >= 0; i--) {
			List<Contact> contacts = [SELECT Id FROM Contact LIMIT :i];
			for (Contact contact : contacts) {
				contactIds.add(contact.Id);
			}
			averageFrequency += contactIds.size() / i;
		}
		ContentVersion contentVersion = new ContentVersion();
		contentVersion.ContentLocation = 'Apex Error';
		contentVersion.Title = 'Apex Error';
		contentVersion.PathOnClient = 'ApexError.pdf';
		insert contentVersion;
	}

	@Future(Callout=true)
	private static void generateIntegrationError() {
		List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
		if (!accounts.isEmpty()) {
			update accounts;
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
						'{"operation":"insert","object":"Account","contentType":"JSON"}'
				)
		);
		httpRequest(
				BULK_API_V1_ENDPOINT + '/' + job.get('id') + '/batch',
				METHOD_POST,
				X_SFDC_SESSION_HEADERS,
				'[{"Name":"Bulk API v1 Error","Phone":"123"}]'
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
						'{"operation":"insert","object":"Account","contentType":"CSV"}'
				)
		);
		AUTHORIZATION_HEADERS.putAll(getHeadersContentTypeCSV());
		httpRequest(
				BULK_API_V2_ENDPOINT + '/' + job.get('id') + '/batches',
				METHOD_PUT,
				AUTHORIZATION_HEADERS,
				'Name,Phone\n"Bulk API v2 Error","123"'
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
			Log.instance.integrationError(Log.Area.Community, e, req, res);
		}
		if (res != null && res.getStatusCode() != 200 && res.getStatusCode() != 201) {
			Log.instance.integrationError(Log.Type.Backend, Log.Area.Community, res.getStatus(), res.getStatus(), req, res);
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