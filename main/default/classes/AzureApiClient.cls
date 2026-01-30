public with sharing class AzureApiClient {

    //POST https://dev.azure.com/{organization}/{project}/_apis/wit/attachments?fileName={fileName}&api-version=7.1-preview.3
    public static String AZURE_DEVOPS_REST_API_WORK_ATTACHMENT = 'https://dev.azure.com/{0}/{1}/_apis/wit/attachments?fileName={2}&api-version=7.1-preview.3';

    //POST https://dev.azure.com/{organization}/{project}/_apis/wit/workItems/{workItemId}/comments?api-version=7.0-preview.3
    public static String AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems/{2}/comments?api-version=7.0-preview.3';

    //https://dev.azure.com/{organization}/{project}/_apis/wit/workItems/{id}/comments?api-version=7.0
    public static String AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENTS = 'https://dev.azure.com/{0}/{1}/_apis/wit/workitems/{2}/comments';

    private String organization;
    private String project;
    private String workItem;

    public class AzureApiClientException extends Exception {}
    
    private static final String ERROR_CONTEXT_NOT_SET =
        'Azure DevOps Work Item context is not set (organization/project/workItem). ' +
        'Check Azure DevOps settings and the Bug Tracker URL.';
    private static final String ERROR_COMMENT_CALL_REDIRECTED_TO_SIGNIN =
        'Azure DevOps comment call was redirected to sign-in (302). ' +
        'Please re-auth Azure DevOps and verify organization/project.';
    private static final String ERROR_ATTACHMENT_UPLOAD_REDIRECTED_TO_SIGNIN =
        'Azure DevOps attachment upload was redirected to sign-in (302). ' +
        'This usually means the OAuth token is missing/expired or the URL context is invalid. ' +
        'Please re-auth Azure DevOps and verify organization/project.';
    private static final String ERROR_ATTACHMENT_BLOB_REQUIRED = 'Attachment blob is required';
    private static final String ERROR_ATTACHMENT_FILENAME_REQUIRED = 'Attachment fileName is required';
    
    // Sign-in redirect detection strings
    private static final String SIGNIN_REDIRECT_OBJECT_MOVED = 'object moved';
    private static final String SIGNIN_REDIRECT_SIGNIN_PATH = '/_signin';
    private static final String SIGNIN_REDIRECT_VSSPS = 'vssps';
    private static final String SIGNIN_REDIRECT_LOGIN_MICROSOFTONLINE = 'login.microsoftonline.com';

    public AzureApiClient setOrganization(String organization) {
        this.organization = organization;

        return this;
    }

    public AzureApiClient setProject(String project) {
        this.project = project;

        return this;
    }

    public AzureApiClient setWorkItem(String workItem) {
        this.workItem = workItem;

        return this;
    }

    private void validateContext() {
        if (String.isBlank(this.organization) || this.organization.toLowerCase() == 'null'
            || String.isBlank(this.project) || this.project.toLowerCase() == 'null'
            || String.isBlank(this.workItem) || this.workItem.toLowerCase() == 'null') {
            throw new AzureApiClientException(ERROR_CONTEXT_NOT_SET);
        }
    }

    private static Boolean isLikelySigninRedirect(String messageOrBody) {
        if (String.isBlank(messageOrBody)) {
            return false;
        }
        String m = messageOrBody.toLowerCase();
        return m.contains(SIGNIN_REDIRECT_OBJECT_MOVED) 
            || m.contains(SIGNIN_REDIRECT_SIGNIN_PATH) 
            || m.contains(SIGNIN_REDIRECT_VSSPS) 
            || m.contains(SIGNIN_REDIRECT_LOGIN_MICROSOFTONLINE);
    }

    public virtual String addCommentWithAttachments(String message, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {
        validateContext();
        if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {

            for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                if (chart != null && String.isNotBlank(chart)) {
                    ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);

                    if (chartEnum != null) {
                        Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                        String fileName = HttpUtils.getNameAttachment(chartEnum.name() + Constants.GLOBAL_VARIABLE.FILE_EXTENSION_PNG);
                        String imageUrl = addAttachment(chartBlob, fileName);
                        if (String.isNotBlank(imageUrl)) {
                            message += String.format(
                                Constants.GLOBAL_VARIABLE.HTML_IMG_TAG_WITH_QUERY_TEMPLATE,
                                new List<String>{ imageUrl, Constants.GLOBAL_VARIABLE.IMAGE_QUERY_TINYSRGB, fileName }
                            );
                        }
                    } else {
                        // Chart type not found in enum
                    }
                }
            }
            // addComment() already wraps payload as {"text": ...}. Don't serialize JSON here,
            // otherwise the work item comment will display a raw JSON string.
            addComment(message);
        }
        return message;
    }

    public String addAttachment(Blob imageBlob, String fileName) {
        validateContext();
        if (imageBlob == null) {
            throw new AzureApiClientException(ERROR_ATTACHMENT_BLOB_REQUIRED);
        }
        if (String.isBlank(fileName)) {
            throw new AzureApiClientException(ERROR_ATTACHMENT_FILENAME_REQUIRED);
        }

        String endpoint = String.format(
            AZURE_DEVOPS_REST_API_WORK_ATTACHMENT,
            new List<String>{this.organization, this.project, EncodingUtil.urlEncode(fileName, 'UTF-8')}
        );

        Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AzureService.AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + AzureService.OAUTH_API_TOKEN);
        headers.put('Content-Type', 'application/octet-stream');

        String b;
        try {
            b = HttpUtils.postputBlobBody(
                endpoint,
                imageBlob,
                headers,
                201
            );
        } catch (HttpUtils.HttpUtilsException e) {
            if (isLikelySigninRedirect(e.getMessage())) {
                throw new AzureApiClientException(ERROR_ATTACHMENT_UPLOAD_REDIRECTED_TO_SIGNIN);
            }
            throw e;
        }

        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(b);
        return (String) result.get(Constants.GLOBAL_VARIABLE.JSON_KEY_URL);
    }

    public String addComment(String comment) {
        validateContext();

        String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT, new List<String>{this.organization, this.project, this.workItem});
        Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AzureService.AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + AzureService.OAUTH_API_TOKEN);
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());
        headers.putAll(HttpUtils.getHeadersAcceptJson());

        Map<String, Object> body = new Map<String, Object>{
            ADFBuilder.ATTR_TEXT => comment
        };

        String responseBody;
        try {
            responseBody = HttpUtils.post(
                endpoint,
                JSON.serialize(body),
                headers,
                200
            );
        } catch (HttpUtils.HttpUtilsException e) {
            if (isLikelySigninRedirect(e.getMessage())) {
                throw new AzureApiClientException(ERROR_COMMENT_CALL_REDIRECTED_TO_SIGNIN);
            }
            throw e;
        }

        return responseBody;
    }


}