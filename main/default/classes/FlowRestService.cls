@RestResource(urlMapping='/flowservice/*')
global with sharing class FlowRestService {

    public static final String FLOW_API_NAME_PARAMS = 'flow';
    public static final String FLOW_TYPE_PARAMS = 'type';
    public static final String FLOW_API_NAME_BAD_VALUE = 'flow api name parameter is invalid';
    public static final String FLOW_TYPE_BAD_VALUE = 'flow type parameter is invalid';
    public static final Integer STATUS_CODE_SUCCESS = 200;
    public static final Integer STATUS_CODE_INTERNAL_ERROR = 500;
    public static final Integer STATUS_CODE_BAD_REQUEST = 400;
    public static final String STATUS_SUCCESS = 'success';
    public static final String STATUS_FAIL = 'fail';
    public static final String FLOW_TYPE_FLOW = 'flow';
    public static final String FLOW_TYPE_PROCESS_BUILDER = 'pb';

    public class FlowRestServiceException extends Exception {}
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetFlowMetadataResult result = new GetFlowMetadataResult();
        Blob responseData = null;

        Map<String, String> params = (req != null && req.params != null) ? req.params : new Map<String, String>();
        result = new GetFlowMetadataResult(params);
        responseData = Blob.valueOf(JSON.serialize(result));

        res.responseBody = responseData;
        res.statusCode = result.statusCode;
    }

    public class GetFlowMetadataResult {
        public String status;
        public Integer statusCode;
        public String error;
        public String flowFullName;
        public String flowType;

        public FlowService.Flow flow;
        public FlowService.ProcessBuilder processBuilder; 

        public GetFlowMetadataResult() {}

        public GetFlowMetadataResult(Map<String, String> params) {

            String errorMessage;

            try {
                this.flowFullName = getFlowFullName(params);
                this.flowType = getFlowType(params);

                try {
                    StackTraceParser.corg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
                    if(this.flowType == FLOW_TYPE_FLOW) {
                        String flowApiNameWithVersion = this.flowFullName;
                        this.flow = FlowService.getSFDCFlow(flowApiNameWithVersion);
                    }
                    else if(this.flowType == FLOW_TYPE_PROCESS_BUILDER) {
                        String flowApiNameWithVersion = this.flowFullName;
                        FlowService.ProcessBuilderHelper helper = new FlowService.ProcessBuilderHelper();
                        this.processBuilder = FlowService.getProcessBuilder(flowApiNameWithVersion, helper);
                        helper.replaceIdsByNames(this.processBuilder);
                    }
                }
                catch (Exception e) {
                    errorMessage = e.getMessage();
                    this.statusCode = STATUS_CODE_INTERNAL_ERROR;
                }

                this.statusCode = STATUS_CODE_SUCCESS;
            }
            catch (FlowRestServiceException e) {
                errorMessage = e.getMessage();
                this.statusCode = STATUS_CODE_BAD_REQUEST;
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
                this.statusCode = STATUS_CODE_INTERNAL_ERROR;
            }
            finally {
                this.status = (String.isNotBlank(errorMessage)) ? STATUS_FAIL : STATUS_SUCCESS;
                this.error = (String.isNotBlank(errorMessage)) ? errorMessage : null;
            }

        }

        private String getFlowFullName(Map<String, String> params) {
            String flowFullName;
            try {
                flowFullName = params.containsKey(FLOW_API_NAME_PARAMS) ? params.get(FLOW_API_NAME_PARAMS) : null;
            }
            catch (Exception e) {
                throw new FlowRestServiceException(FLOW_API_NAME_BAD_VALUE);
            }
            return flowFullName;
        }

        private String getFlowType(Map<String, String> params) {
            String flowType;
            try {
                flowType = params.containsKey(FLOW_TYPE_PARAMS) ? params.get(FLOW_TYPE_PARAMS) : null;
            }
            catch (Exception e) {
                throw new FlowRestServiceException(FLOW_TYPE_BAD_VALUE);
            }
            return flowType;
        }
    }

}