public with sharing class HttpUtils {

	public static final String EXCEPTION_INVALID_SESSION_ID = 'INVALID_SESSION_ID';

	public static final String HTTP_CONTENT_TYPE_JSON = 'application/json';
	public static final String HTTP_CONTENT_TYPE_FORM_URLENCODED = 'application/x-www-form-urlencoded';
	public static final String HTTP_CONTENT_TYPE_JSON_PATCH = 'application/json-patch+json';

	public static Map<String, String> getHeadersContentType(String typeValue) {
		return new Map<String, String>{
			'Content-Type' => typeValue
		};
	}

	public static Map<String, String> getHeadersContentTypeJSON() {
		return getHeadersContentType(HTTP_CONTENT_TYPE_JSON);
	}

	public static Map<String, String> getHeadersContentTypeJSONPatch() {
		return getHeadersContentType(HTTP_CONTENT_TYPE_JSON_PATCH);
	}

	public static Map<String, String> getHeadersContentTypeFormUrlencoded() {
		return getHeadersContentType(HTTP_CONTENT_TYPE_FORM_URLENCODED);
	}

	public static Map<String, String> getHeadersAuthorization(String authValue) {
		return new Map<String, String>{
			'Authorization' => authValue
		};
	}

	public static Map<String, String> getHeadersFrom(String fromValue) {
		return new Map<String, String>{
			'From' => fromValue
		};
	}

	public static final String HTTP_ACCEPT_TYPE_JSON = 'application/json';
	public static final String HTTP_ACCEPT_TYPE_PAGER_DUTY_JSON = 'application/vnd.pagerduty+json;version=2';

	public static Map<String, String> getHeadersAccept(String acceptType) {
		return new Map<String, String>{
			'Accept' => acceptType
		};
	}

	public static Map<String, String> getHeadersAcceptJson() {
		return getHeadersAccept(HTTP_ACCEPT_TYPE_JSON);
	}

	public static Map<String, String> getHeadersAcceptPagerDutyJson() {
		return getHeadersAccept(HTTP_ACCEPT_TYPE_PAGER_DUTY_JSON);
	}

	public static Map<String, String> getHeadersAuthorizationAcceptJson(String authValue) {
		Map<String, String> headers = getHeadersAuthorization(authValue);
		headers.putAll(getHeadersAcceptJson());
		return headers;
	}

	public static Map<String, String> getHeadersAuthorizationAcceptPagerDutyJson(String authValue) {
		Map<String, String> headers = getHeadersAuthorization(authValue);
		headers.putAll(getHeadersAcceptPagerDutyJson());
		return headers;
	}

	public static boolean enableHttpDebug = false;
	public static Map<String, Object> HTTP_DEBUG_INFO_REQUEST = new Map<String, Object>();
	public static Map<String, Object> HTTP_DEBUG_INFO_RESPONSE = new Map<String, Object>();

    public static String get(String url, Map<String, String> headers, Integer expectedResponseCode) {
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        req.setTimeout(120000);
        debugHttpRequest(req, headers);

        Http h = new Http();
        HttpResponse res = h.send(req);
        debugHttpResponse(res);
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        if (res.getStatusCode() == expectedResponseCode) {
	        if (String.isNotBlank(res.getHeader('Content-Type')) && res.getHeader('Content-Type').toLowerCase().contains('zip')) {
		        try {
			        Compression.ZipReader reader = new Compression.ZipReader(res.getBodyAsBlob());
			        Compression.ZipEntry entry = reader.getEntry(reader.getEntries()[0].getName());
			        return reader.extract(entry).toString();
		        } catch (Exception e) {
			        return res.getBody();
		        }
	        } else {
		        return res.getBody();
	        }
        } else {
            throw new HttpUtilsException(res.getStatusCode() + ': ' + res.getBody());
        }
    }

	public static String getHttpDebugInfo() {
		return JSON.serialize(
			new Map<String, Object>{
				'request' => HTTP_DEBUG_INFO_REQUEST,
				'response' => HTTP_DEBUG_INFO_RESPONSE
			}
		);
	}

	public static void debugHttpRequest(HTTPRequest req, Map<String, String> headers) {
		if(req != null && enableHttpDebug) {
			HTTP_DEBUG_INFO_REQUEST.putAll(new Map<String, Object>{
				'endpoint' => req?.getEndpoint(),
				'method' => req?.getMethod(),
				'body' => req?.getBody(),
				'headers' => headers
			});
		}
	}

	public static void debugHttpResponse(HttpResponse res) {
		if(res != null && enableHttpDebug) {
			Map<String, String> headers = new Map<String, String>();
			for(String headerKey : res?.getHeaderKeys()) {
				headers.put(headerKey, res.getHeader(headerKey));
			}
			HTTP_DEBUG_INFO_RESPONSE.putAll(new Map<String, Object>{
				'statusCode' => res?.getStatusCode(),
				'body' => res?.getBody(),
				'status' => res?.getStatus(),
				'headers' => headers
			});
		}
	}

    public static String patch(String url, String body, Map<String, String> headers, Integer expectedResponseCode) {
        return postput('PATCH', url, body, headers, expectedResponseCode, null);
    }

    public static String del(String url, Map<String, String> headers, Integer expectedResponceCode) {
        return postput('DELETE', url, null, headers, expectedResponceCode, null);
    }

    public static String post(String url, String body, Map<String, String> headers, Integer expectedResponceCode) {
        return postput('POST', url, body, headers, expectedResponceCode, null);
    }

    public static String post(String url, String body, Map<String, String> headers, Integer expectedResponceCode, MetadataService.RemoteSiteSetting rssInstance) {
        return postput('POST', url, body, headers, expectedResponceCode, rssInstance);
    }

    public static String put(String url, String body, Map<String, String> headers, Integer expectedResponseCode) {
        return postput('PUT', url, body, headers, expectedResponseCode, null);
    }

    public static Map<String, String> responseHeaders = new Map<String, String>();

    public static String postput(String method, String url, String body, Map<String, String> headers, Integer expectedResponseCode, MetadataService.RemoteSiteSetting rssInstance) {
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        if(body != null) {
            req.setBody(body);
        }
        req.setTimeout(120000);
        debugHttpRequest(req, headers);

        Http h = new Http();
        HttpResponse res = h.send(req);
        debugHttpResponse(res);
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            if(rssInstance != null) {
                rssInstance.url = res.getHeader('Location');
                MetadataServiceUtil.upsertRemoteSiteSettingsMetadata(rssInstance);
            }
            res = new Http().send(req);
        }
        if (res.getStatusCode() == expectedResponseCode) {
            for(String headerKey : res.getHeaderKeys()) {
                responseHeaders.put(headerKey, res.getHeader(headerKey));
            }
            return res.getBody();
        } else {
            throw new HttpUtilsException(res.getStatusCode() + ': ' + res.getBody());
        }
    }

    public static HttpResponse send(String endpoint, String method, Map<String, String> headers, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        if (body != null) {
            req.setBody(body);
        }
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        return res;
    }

	public static Map<String, String> getHeaders(String accessToken) {
		return new Map<String, String> {
			'Authorization' => 'Bearer ' + accessToken,
			'Content-Type' => 'application/json'
		};
	}

	public static List<Object> runToolingQuery(String instance, String accessToken, String q) {
		return runToolingQuery(instance, accessToken, q, ConfigUtil.QUERY_REST_API_PATH, ConfigUtil.TOOLING_ITEMS_KEY_RECORDS);
	}

	public static List<Object> runToolingQuery(String instance, String accessToken, String q, String path) {
		return runToolingQuery(instance, accessToken, q, path, ConfigUtil.TOOLING_ITEMS_KEY_RECORDS);
	}

	public static List<Object> runToolingQuery(String instance, String accessToken, String q, String path, String keyItems) {
		String b = get(
			instance + path + EncodingUtil.urlEncode(q, 'UTF-8'),
			getHeaders(accessToken),
			200
		);
		Map<String, Object> objectMap = (Map<String, Object>)JSON.deserializeUntyped(b);
		return (List<Object>)objectMap.get(keyItems);
	}

	public static LogPostProcessingService.ExternalSObjectsDescribeInfoWrapper runToolingQuerySObjects(String instance, String accessToken) {
		String b = get(
			instance + ConfigUtil.DESCRIBE_SOBJECT_PATH,
			getHeaders(accessToken),
			200
		);
		LogPostProcessingService.ExternalSObjectsDescribeInfoWrapper result = (LogPostProcessingService.ExternalSObjectsDescribeInfoWrapper)JSON.deserialize(b, LogPostProcessingService.ExternalSObjectsDescribeInfoWrapper.class);
		return result;
	}

    public static String runToolingPost(String instance, String accessToken, String body, String path) {
		return runToolingUpsert(instance, accessToken, body, path, 201);
	}
    
	public static String runToolingPatch(String instance, String accessToken, String body, String path) {
		return runToolingUpsert(instance, accessToken, body, path + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH, 204);
	}

	public static String runToolingUpsert(String instance, String accessToken, String body, String path, Integer expectedCode) {
		String b = post(
			instance + path,
			body,
			getHeaders(accessToken),
			expectedCode
		);
		return b;
	}

	public static final String HTTP_URL_PARAM_CODE = 'code';
	public static final String HTTP_URL_PARAM_REFRESH_TOKEN = 'refresh_token';
	public static final String HTTP_URL_PARAM_AUTHORIZATION_CODE = 'authorization_code';
	public static final String HTTP_URL_PARAM_CLIENT_ID = 'client_id';
	public static final String HTTP_URL_PARAM_CLIENT_SECRET = 'client_secret';
	public static final String HTTP_URL_PARAM_GRANT_TYPE = 'grant_type';
	public static final String HTTP_URL_PARAM_RESPONSE_TYPE = 'response_type';
	public static final String HTTP_URL_PARAM_REDIRECT_URI = 'redirect_uri';
	public static final String HTTP_URL_PARAM_SCOPE = 'scope';
	public static final String HTTP_URL_PARAM_RESPONSE_MODE = 'response_mode';
	public static final String HTTP_URL_PARAM_STATE = 'state';
	public static final String HTTP_URL_PARAM_PROMPT = 'prompt';
	public static final String HTTP_URL_PARAM_PROMPT_CONSENT = 'consent';
	public static final String HTTP_URL_PARAM_AUDIENCE = 'audience';
	public static final String HTTP_URL_PARAM_AUDIENCE_JIRA_API = 'api.atlassian.com';
	public static final String HTTP_URL_PARAM_CLIENT_ASSERTATION_TYPE = 'client_assertion_type';
	public static final String HTTP_URL_PARAM_CLIENT_ASSERTATION_TYPE_VALUE_JWT = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer';
	public static final String HTTP_URL_PARAM_GRANT_TYPE_VALUE_JWT = 'urn:ietf:params:oauth:grant-type:jwt-bearer';
	public static final String HTTP_URL_PARAM_ASSERTATION = 'assertion';
	public static final String HTTP_URL_PARAM_CLIENT_ASSERTATION = 'client_assertion';


	public class HttpURLParameters {
		private String parameters;
		private Map<String, String> parametersMap;

		public HttpURLParameters() {
			this.parameters = null;
			this.parametersMap = new Map<String, String>();
		}

		public HttpURLParameters addParameter(String paramName, String paramValue) {
			this.parametersMap.put(paramName, paramValue);
			return this;
		}

		public HttpURLParameters addEncodedParameter(String paramName, String paramValue) {
			addParameter(paramName, EncodingUtil.urlEncode(paramValue, 'UTF-8'));
			return this;
		}

		public HttpURLParameters addEncodedParameterWithFixedWhitespace(String paramName, String paramValue) {
			addParameter(paramName, EncodingUtil.urlEncode(paramValue, 'UTF-8').replace('+', '%20'));
			return this;
		}

		public String toStringParameters() {
			return toStringParameters('');
		}

		public String toStringParameters(String startWith) {
			List<String> valuesParts = new List<String>();

			for(String key : this.parametersMap.keySet()) {
				valuesParts.add(key + '=' + this.parametersMap.get(key));
			}
			return startWith + String.join(valuesParts, '&');
		}
	}

	public class HttpUtilsException extends Exception {}
}