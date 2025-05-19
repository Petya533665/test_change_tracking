@RestResource(urlMapping='/logs/*')
global with sharing class LogRestService {

    public static final String STATUS_SUCCESS = 'success';
    public static final String STATUS_FAIL = 'fail';
    public static final Integer STATUS_CODE_SUCCESS = 200;
    public static final Integer STATUS_CODE_INTERNAL_ERROR = 500;
    public static final Integer STATUS_CODE_BAD_REQUEST = 400;
    public static final Integer LIMIT_ROWS = 50000;
    public static final String HASH1_PARAMS = 'hash1';
    public static final String LIMIT_PARAMS = 'limitRows';
    public static final String START_DATE_PARAMS = 'startDate';
    public static final String END_DATE_PARAMS = 'endDate';
    public static final String START_DATE_BAD_VALUE = 'startDate parameter is invalid';
    public static final String END_DATE_BAD_VALUE = 'endDate parameter is invalid';

    public class LogRestServiceException extends Exception {}

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetLogResult result = new GetLogResult();
        Blob responseData = null;

        Map<String, String> params = (req != null && req.params != null) ? req.params : new Map<String, String>();
        result = new GetLogResult(params);
        responseData = Blob.valueOf(JSON.serialize(result));

        res.responseBody = responseData;
        res.statusCode = result.statusCode;
    }

    public class GetLogResult {
        public String status;
        public Integer statusCode;
        public String error;
        public DateTime startDate;
        public DateTime endDate;
        public String hash1;
        public Integer limitRows;
        public List<Map<String, Object>> logs;

        public GetLogResult() {}

        public GetLogResult(Map<String, String> params) {

            String errorMessage;

            try {
                this.startDate = getStartDate(params);
                this.endDate = getEndDate(params);
                this.hash1 = getHash1(params);
                this.limitRows = getLimitRows(params);
                this.logs = new List<Map<String, Object>>();

                try {
                    retrieveLogs();
                }
                catch (Exception e) {
                    errorMessage = e.getMessage();
                    this.statusCode = STATUS_CODE_INTERNAL_ERROR;
                }

                this.statusCode = STATUS_CODE_SUCCESS;
            }
            catch (LogRestServiceException e) {
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

        private void retrieveLogs() {
            List<String> logFields = getLogFields();
            String nameSpacePrefix = ConfigUtil.nameSpacePrefix;
            Map<String, String> mapFields = getMapFields(logFields, nameSpacePrefix);
            Integer limitRows = (this.limitRows != null) ? this.limitRows : LIMIT_ROWS;

            String query = new QBuilder(Log__c.SObjectType)
                .selectFields(new Set<String>(logFields))
                .add(this.StartDate != null ? QBuilder.condition('CreatedDate').isGreaterOrEquals(this.startDate) : null)
                .add(this.EndDate != null ? QBuilder.condition('CreatedDate').isLessOrEquals(this.endDate) : null)
                .add(String.isNotBlank(this.hash1) ? QBuilder.condition('Hash_1__c').equalsTo(this.hash1) : null)
                .addLimit(limitRows)
                .build();

            List<SObject> rows = Database.query(query);
            for(SObject row : rows) {
                Map<String, Object> rowSO = row.getPopulatedFieldsAsMap();
                Map<String, Object> newSO = new Map<String, Object>();
                for (String fieldName : rowSO.keySet()) {
                    Object value = rowSO.get(fieldName);
                    String newFieldName = mapFields.get(fieldName.toLowerCase());
                    newSO.put(newFieldName, value);
                }
                this.logs.add(newSO);
            }
        }

        private Map<String, String> getMapFields(List<String> logFields, String nameSpacePrefix) {
            Map<String, String> result = new Map<String, String>();

            for(String logFieldName : logFields) {
                String newFieldName = logFieldName.replace(nameSpacePrefix, '');
                newFieldName = newFieldName.replace('__c', '');
                newFieldName = newFieldName.replace('_', '');
                result.put(logFieldName, newFieldName);
            }
            return result;
        }

        private List<String> getLogFields() {
            List<String> fields = new List<String>();

            Schema.DescribeSObjectResult d = Log__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = d.fields.getMap();
            Set<String> logFieldsSet = fieldsMap.keySet();

            //remove from fieldsSet
            fields.addAll(logFieldsSet);
            return fields;
        }

        private DateTime getStartDate(Map<String, String> params) {
            DateTime startDate;

            try {
                startDate = params.containsKey(START_DATE_PARAMS) ? DateTime.valueOf(params.get(START_DATE_PARAMS)) : null;
            }
            catch (Exception e) {
                throw new LogRestServiceException(START_DATE_BAD_VALUE);
            }
            return startDate;
        }

        private DateTime getEndDate(Map<String, String> params) {
            DateTime endDate;

            try {
                endDate = params.containsKey(END_DATE_PARAMS) ? DateTime.valueOf(params.get(END_DATE_PARAMS)) : null;
            }
            catch (Exception e) {
                throw new LogRestServiceException(END_DATE_BAD_VALUE);
            }
            return endDate;
        }

        private String getHash1(Map<String, String> params) {
            return params.containsKey(HASH1_PARAMS) ? params.get(HASH1_PARAMS) : null;
        }

        private Integer getLimitRows(Map<String, String> params) {
            return params.containsKey(LIMIT_PARAMS) ? Integer.valueOf(params.get(LIMIT_PARAMS)) : null;
        }
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            if (!RestContext.request.params.isEmpty()) {
                if (RestContext.request.params.get(ConfigUtil.PARAMS_TYPE) == ConfigUtil.TYPE_PASSTHROUGH_MODE) {
                    PassthroughtModeService.IncomingLogData data = (PassthroughtModeService.IncomingLogData)JSON.deserialize(req.requestBody.toString(), PassthroughtModeService.IncomingLogData.class);
                    PassthroughtModeService.parseIncomingData(data);
                } else if (RestContext.request.params.get(ConfigUtil.PARAMS_TYPE) == ConfigUtil.TYPE_BROADCAST) {
                    BroadcastService.IncomingData data = (BroadcastService.IncomingData)JSON.deserialize(req.requestBody.toString(), BroadcastService.IncomingData.class);
                    BroadcastService.parseIncomingData(data);
                }
            }
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = STATUS_CODE_INTERNAL_ERROR;
            Logger.getInstance().addInternalError(e, LogRestService.class.getName(), 'doPost');
        }
        if (!Logger.getInstance().logsQueue.isEmpty()) {
            Logger.getInstance().flush();
        } else {
            res.responseBody = Blob.valueOf('Done');
            res.statusCode = STATUS_CODE_SUCCESS;
        }
    }

}