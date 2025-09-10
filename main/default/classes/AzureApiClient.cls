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

    public virtual String addCommentWithAttachments(String message, ChartGeneratorImageLambdaClient chartGeneratorImageLambdaClient) {
        if (chartGeneratorImageLambdaClient != null && chartGeneratorImageLambdaClient.hasCharts()) {

            for (String chart : chartGeneratorImageLambdaClient.getAvailableChartTypes()) {
                if (chart != null && String.isNotBlank(chart)) {
                    ChartService.Chart chartEnum = ChartService.getChartEnumByChartName(chart);

                    if (chartEnum != null) {
                        Blob chartBlob = chartGeneratorImageLambdaClient.getBlobImageForChart(chartEnum.name());
                        String fileName = HttpUtils.getNameAttachment(chartEnum.name() + '.png');
                        String imageUrl = addAttachment(chartBlob, fileName);
                        message += '<img src="' + imageUrl + +'?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"';
                    } else {
                        // Chart type not found in enum
                    }
                }
            }

            Map<String, Object> body = new Map<String, Object>{
                'text' => message
            };

            String result = addComment(JSON.serialize(body));
        }
        return message;
    }

    public String addAttachment(Blob imageBlob, String fileName) {
        String endpoint = String.format(
            AZURE_DEVOPS_REST_API_WORK_ATTACHMENT,
            new List<String>{this.organization, this.project, EncodingUtil.urlEncode(fileName, 'UTF-8')}
        );

        Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AzureService.AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + AzureService.OAUTH_API_TOKEN);
        headers.put('Content-Type', 'application/octet-stream');

        String b = HttpUtils.postputBlobBody(
            endpoint,
            imageBlob,
            headers,
            201
        );

        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(b);
        return (String) result.get('url');
    }

    public String addComment(String comment) {

        String endpoint = String.format(AZURE_DEVOPS_REST_API_WORK_ITEM_COMMENT, new List<String>{this.organization, this.project, this.workItem});
        Map<String, String> headers = HttpUtils.getHeadersAuthorizationAcceptJson(AzureService.AZURE_DEVOPS_REST_API_TOKEN_TYPE_BEARER + AzureService.OAUTH_API_TOKEN);
        headers.putAll(HttpUtils.getHeadersContentTypeJSON());
        headers.putAll(HttpUtils.getHeadersAcceptJson());

        Map<String, Object> body = new Map<String, Object>{
            'text' => comment
        };

        String responseBody = HttpUtils.post(
            endpoint,
            JSON.serialize(body),
            headers,
            200
        );

        return responseBody;
    }


}