global with sharing class HttpRequestWrapper {

    private final HttpRequest request;
    private final RestRequest restRequest;
    private final Set<String> HEADER_KEYS = new Set<String>{
            'Accept', 'Accept-CH', 'Accept-Charset', 'Accept-Features', 'Accept-Encoding', 'Accept-Language',
            'Accept-Ranges', 'Access-Control-Allow-Credentials', 'Access-Control-Allow-Origin',
            'Access-Control-Allow-Methods', 'Access-Control-Allow-Headers', 'Access-Control-Max-Age',
            'Access-Control-Expose-Headers', 'Access-Control-Request-Method', 'Access-Control-Request-Headers',
            'Age', 'Allow', 'Alternates', 'Authorization', 'Cache-Control', 'Connection', 'Content-Encoding',
            'Content-Language', 'Content-Length', 'Content-Location', 'Content-MD5', 'Content-Range',
            'Content-Security-Policy', 'Content-Type', 'Cookie', 'DNT', 'Date', 'ETag', 'Expect', 'Expires', 'From',
            'Host', 'If-Match', 'If-Modified-Since', 'If-None-Match', 'If-Range', 'If-Unmodified-Since',
            'Last-Event-ID', 'Last-Modified', 'Link', 'Location', 'Max-Forwards', 'Negotiate', 'Origin', 'Pragma',
            'Proxy-Authenticate', 'Proxy-Authorization', 'Range', 'Referer', 'Retry-After',
            'Sec-Websocket-Extensions', 'Sec-Websocket-Key', 'Sec-Websocket-Origin', 'Sec-Websocket-Protocol',
            'Sec-Websocket-Version', 'Server', 'Set-Cookie', 'Set-Cookie2', 'Strict-Transport-Security', 'TCN',
            'TE', 'Trailer', 'Transfer-Encoding', 'Upgrade', 'User-Agent', 'Variant-Vary', 'Vary', 'Via', 'Warning',
            'WWW-Authenticate', 'X-Content-Duration', 'X-Content-Security-Policy', 'X-DNSPrefetch-Control',
            'X-Frame-Options', 'X-Requested-With', 'X-SFDC-Session'
    };

    /**
	 * Create a new {@code HttpRequest} wrapping the given request object.
	 * @param request -- the request object to be wrapped
	 */
    global HttpRequestWrapper(HttpRequest request) {
        this.request = request;
    }

    global HttpRequestWrapper(RestRequest restRequest) {
        this.restRequest = restRequest;
    }

    /**
	 * Create a new {@code HttpRequest} wrapping the given request object.
	 * @param request -- the request object to be wrapped
	 * @param headerKeys -- the keys of headers to be wrapped
	 */
    public HttpRequestWrapper(HttpRequest request, Set<String> headerKeys) {
        this.request = request;
        this.HEADER_KEYS.addAll(headerKeys);
    }

    /**
	 * @return the wrapped request.
	 */
    public HttpRequest getRequest() {
        return request;
    }

    /**
	 * @return endpoint of the wrapped request.
	 */
    public String getEndpoint() {
        return (request != null)
            ? request.getEndpoint()
            : URL.getOrgDomainUrl().toExternalForm() + restRequest.resourcePath;
    }

    /**
	 * @return method of the wrapped request.
	 */
    public String getMethod() {
        return (request != null) ? request.getMethod() : restRequest.httpMethod;
    }

    /**
	 * @return mapHeaders of the wrapped request.
	 */
    public Map<String, String> getHeaders() {
        Map<String, String> mapHeaders = new Map<String, String>();
        for (String key : HEADER_KEYS) {
            if (request != null && String.isNotBlank(request.getHeader(key))) {
                mapHeaders.put(key, request.getHeader(key));
            }
            else if (restRequest != null && String.isNotBlank(restRequest.headers.get(key))) {
                mapHeaders.put(key, restRequest.headers.get(key));
            }
        }
        return mapHeaders;
    }

    /**
	 * @return body of the wrapped request.
	 */
    public String getBody() {
        return (request != null) ? request.getBody() : restRequest.requestBody != null ? restRequest.requestBody.toString() : null;
    }

    /**
	 * @return compressed of the wrapped request.
	 */
    public Boolean getCompressed() {
        return (request != null) ? request.getCompressed() : false;
    }

    /**
	 * @return format request of the wrapped request.
	 */
    global Map<String, Object> formatRequest() {
        if (this.request == null && this.restRequest == null) return null;
        return new Map<String, Object>{
            'endpoint' => getEndpoint(),
            'method' => getMethod(),
            'headers' => getHeaders(),
            'body' => getBody(),
            'compressed' => getCompressed()
        };
    }

}