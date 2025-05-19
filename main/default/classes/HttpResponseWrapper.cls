global with sharing class HttpResponseWrapper {

    private final HttpResponse response;
    private final RestResponse restResponse;

    /**
	 * Create a new {@code HttpResponse} wrapping the given response object.
	 * @param response -- the response object to be wrapped.
	 */
    global HttpResponseWrapper(HttpResponse response) {
        this.response = response;
    }
    global HttpResponseWrapper(RestResponse restResponse) {
        this.restResponse = restResponse;
    }

    /**
	 * @return the wrapped response.
	 */
    public HttpResponse getResponse() {
        return response;
    }

    /**
	 * @return headerKeys of the wrapped response.
	 */
    public List<String> getHeaderKeys() {
        return (response != null) ? response.getHeaderKeys() : new List<String>(restResponse.headers.keySet());
    }

    /**
     * @param key -- the key of the header.
	 * @return header of the wrapped response.
	 */
    public String getHeader(String key) {
        return (response != null) ? response.getHeader(key) : restResponse.headers.get(key);
    }

    /**
	 * @return headers of the wrapped response.
	 */
    public Map<String, String> getHeaders() {
        Map<String, String> mapHeaders = new Map<String, String>();
        if (response != null) {
            for (String key : response.getHeaderKeys()) {
                mapHeaders.put(key, getHeader(key));
            }
        }
        return mapHeaders;
    }

    /**
	 * @return body of the wrapped response.
	 */
    public String getBody() {
        return (response != null) ? response.getBody() : restResponse.responseBody != null ? restResponse.responseBody.toString() : null;
    }

    /**
	 * @return bodyAsBlob of the wrapped response.
	 */
    public Blob getBodyAsBlob() {
        return (response != null) ? response.getBodyAsBlob() : restResponse.responseBody;
    }

    /**
	 * @return status of the wrapped response.
	 */
    public String getStatus() {
        return (response != null) ? response.getStatus() : null;
    }

    /**
	 * @return statusCode of the wrapped response.
	 */
    public Integer getStatusCode() {
        return (response != null) ? response.getStatusCode() : restResponse.statuscode;
    }

    /**
	 * @return format response of the wrapped response.
	 */
    global Map<String, Object> formatResponse() {
        if (response == null && restResponse == null) return null;
        return new Map<String, Object>{
                'headerKeys' => getHeaderKeys(),
                'headers' => getHeaders(),
                'body' => getBody(),
                'bodyAsBlob' => getBodyAsBlob(),
                'status' => getStatus(),
                'statusCode' => getStatusCode()
        };
    }

}