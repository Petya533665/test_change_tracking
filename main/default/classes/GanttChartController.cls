public with sharing class GanttChartController {

    public String recordId { get; set; }
    public Boolean isDev { get; set; }

    public String packageNamespace {
        get {
            return ConfigUtil.getNameSpacePrefix();
        }
        set;
    }

    public Integer userTimezoneOffset {
        get {
            return AdminService.getUserTimezoneOffset();
        }
        set;
    }

    public GanttChartController(ApexPages.StandardController stdController) {
        System.PageReference pageReference = ApexPages.currentPage();
        recordId = pageReference.getParameters().get('recordId');
        isDev = ConfigUtil.initializeDevelopmentMode(pageReference);
    }

    @RemoteAction
    public static String remoteActionHandler(String input) {
        String result;
        RemoteActionResponse response = new RemoteActionResponse();
        String methodName;

        try {
            Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(input);
            response.params = request;
            String method = (String)request.get('method');
            methodName = method;
            Object data = request.get('data');
            if (method == 'getChildLogs') {
                response.data = getChildLogs(data);
            } else {
                response.error = 'Action not found';
            }
            result = JSON.serialize(response);
            Logger.getInstance().flush();
        }
        catch(Exception e) {
            response.error = e.getMessage();
            response.stack = e.getStackTraceString();
            Logger.getInstance().internalError(e, GanttChartController.class.getName(), 'remoteActionHandler' + (String.isNotBlank(methodName) ? '.' + methodName : ''));
        }
        finally {
            try {
                result = JSON.serialize(response);
            }
            catch(Exception e) {
                Logger.getInstance().internalError(e, GanttChartController.class.getName(), 'remoteActionHandler.serializeResponse');
            }
        }
        return result;
    }

    public static String TRITON_LOG_LEVEL_FIELDS_NAME = 'Log_Level__c';

    private static String tritonField;

    public static void resetTritonField() {
        tritonField = null;
    }

    public static void setTritonField(String value) {
        if (String.isNotBlank(value)) {
            tritonField = value;
        }
    }

    private static String getTritonField() {
        return tritonField ?? TRITON_LOG_LEVEL_FIELDS_NAME;
    }

    public static final Boolean TRITON_LOG_LEVEL_AVAILABLE {
        get {
            if(TRITON_LOG_LEVEL_AVAILABLE == null) {
                Map<String, Schema.SObjectField> logFieldMap = Schema.SObjectType.Log__c.fields.getMap();
                TRITON_LOG_LEVEL_AVAILABLE = (logFieldMap?.containsKey(getTritonField().toLowerCase()))
                    || (logFieldMap?.containsKey(ConfigUtil.prefixCurrentOrgNamespace(getTritonField()).toLowerCase()));
            }
            return TRITON_LOG_LEVEL_AVAILABLE;
        }
        private set;
    }

    public static final Schema.DescribeFieldResult TRITON_LOG_LEVEL_FIELD_DESCRIBE {
        get {
            if(TRITON_LOG_LEVEL_AVAILABLE && TRITON_LOG_LEVEL_FIELD_DESCRIBE == null) {
                Map<String, Schema.SObjectField> logFieldMap = Schema.SObjectType.Log__c.fields.getMap();
                // check Log_Level__c
                // check orgnamespace__Log_Level__c
                String logFieldNameWithNameSpace = (logFieldMap?.containsKey(getTritonField().toLowerCase()))
                    ? getTritonField().toLowerCase()
                    : ((logFieldMap?.containsKey(ConfigUtil.prefixCurrentOrgNamespace(getTritonField()).toLowerCase()))
                        ? ConfigUtil.prefixCurrentOrgNamespace(getTritonField()).toLowerCase() : null);
                
                TRITON_LOG_LEVEL_FIELD_DESCRIBE = Schema.SObjectType.Log__c.fields.getMap()?.get(logFieldNameWithNameSpace)?.getDescribe();
            }
            return TRITON_LOG_LEVEL_FIELD_DESCRIBE;
        }
        private set;
    }
    public static final String TRITON_LOG_LEVEL_FIELD_API_NAME {
        get {
            if(TRITON_LOG_LEVEL_AVAILABLE && TRITON_LOG_LEVEL_FIELD_API_NAME == null) {
                TRITON_LOG_LEVEL_FIELD_API_NAME = TRITON_LOG_LEVEL_FIELD_DESCRIBE?.getName();
            }
            return TRITON_LOG_LEVEL_FIELD_API_NAME;
        }
        private set;
    }
    public static final List<PickListEntry> TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES {
        get {
            if(TRITON_LOG_LEVEL_AVAILABLE && TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES == null) {
                TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES = TRITON_LOG_LEVEL_FIELD_DESCRIBE?.getPicklistValues();
            }
            return TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES;
        }
        private set;
    }

    public class PickListValue {
        public String label;
        public String value;
        public Boolean isActive;

        public PickListValue(String label, String value, Boolean isActive) {
            this.label = label;
            this.value = value;
            this.isActive = isActive;
        } 
    }

    private static List<PickListValue> getTritonLogLevelValues() {
        List<PickListValue> result = new List<PickListValue>();

        if(TRITON_LOG_LEVEL_AVAILABLE && TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES != null) {
            for(Schema.PicklistEntry entry : TRITON_LOG_LEVEL_FIELD_PICK_LIST_ENTRIES) {
                result.add(new PickListValue(entry.getLabel(), entry.getValue(), entry.isActive()));
            }
        }

        return result;
    }

    private static List<SObject> getChildLogsSObjectsWithTritonFields(String logParentId) {
        List<SObject> records = new List<SObject>();
        String parentId = logParentId;

        Set<String> fields = new Set<String>{
            Schema.SObjectType.Log__c.fields.Id.getName(),
            Schema.SObjectType.Log__c.fields.Name.getName(),
            Schema.SObjectType.Log__c.fields.Category__c.getName(),
            Schema.SObjectType.Log__c.fields.Type__c.getName(),
            Schema.SObjectType.Log__c.fields.Summary__c.getName(),
            Schema.SObjectType.Log__c.fields.Duration__c.getName(),
            Schema.SObjectType.Log__c.fields.Created_Timestamp__c.getName(),
            Schema.SObjectType.Log__c.fields.Parent__c.getName()
        };

        // if Triton log level fields available, add to query
        if(TRITON_LOG_LEVEL_AVAILABLE && String.isNotBlank(TRITON_LOG_LEVEL_FIELD_API_NAME)) {
            fields.add(TRITON_LOG_LEVEL_FIELD_API_NAME);
        }

        String query = new QBuilder(Log__c.getSObjectType().getDescribe().getName())
            .selectFields(fields)
            .add(QBuilder.condition(Schema.SObjectType.Log__c.fields.Parent__c.getName())
                .equalsTo(parentId))
            .addLimit(1000)
            .build();
        records = Database.query(query);

        return records;
    }

    public static List<GanttChartData> getChildLogs(Object data) {
        List<GanttChartData> ganttChartData = new List<GanttChartData>();
        if (data != null) {
            String recordId = (String) JSON.deserializeUntyped(JSON.serialize(data));

            if(TRITON_LOG_LEVEL_AVAILABLE) {
                List<SObject> logs = getChildLogsSObjectsWithTritonFields(recordId);
                for (SObject log : logs) {
                    ganttChartData.add(new GanttChartData(log));
                }
            }
            else {
                List<Log__c> logs = [
                    SELECT Id, Name, Category__c, Type__c, Summary__c, Duration__c, Created_Timestamp__c
                    FROM Log__c
                    WHERE Parent__c = :recordId
                ];
                for (Log__c log : logs) {
                    ganttChartData.add(new GanttChartData(log));
                }
            }
        }
        return ganttChartData;
    }

    public class GanttChartData {
        public String recordId;
        public String name;
        public String category;
        public String type;
        public String summary;
        public Decimal duration;
        public Decimal createdTimestamp;
        public String logLevel;
        public List<PickListValue> logLevelValues;

        public GanttChartData(SObject logRecord) {
            this.recordId = (logRecord?.get(Schema.SObjectType.Log__c.fields.Id.getName()) != null)
                ? String.valueOf(logRecord.get(Schema.SObjectType.Log__c.fields.Id.getName())) : null;
            this.name = (logRecord?.get(Schema.SObjectType.Log__c.fields.Name.getName()) != null)
                ? String.valueOf(logRecord.get(Schema.SObjectType.Log__c.fields.Name.getName())) : null;
            this.category = (logRecord?.get(Schema.SObjectType.Log__c.fields.Category__c.getName()) != null)
                ? String.valueOf(logRecord.get(Schema.SObjectType.Log__c.fields.Category__c.getName())) : null;
            this.type = (logRecord?.get(Schema.SObjectType.Log__c.fields.Type__c.getName()) != null)
                ? String.valueOf(logRecord.get(Schema.SObjectType.Log__c.fields.Type__c.getName())) : null;
            this.summary = (logRecord?.get(Schema.SObjectType.Log__c.fields.Summary__c.getName()) != null)
                ? String.valueOf(logRecord.get(Schema.SObjectType.Log__c.fields.Summary__c.getName())) : null;
            this.duration = (logRecord?.get(Schema.SObjectType.Log__c.fields.Duration__c.getName()) != null)
                ? (Decimal)(logRecord.get(Schema.SObjectType.Log__c.fields.Duration__c.getName())) : null;
            this.createdTimestamp = (logRecord?.get(Schema.SObjectType.Log__c.fields.Created_Timestamp__c.getName()) != null)
                ? (Decimal)(logRecord.get(Schema.SObjectType.Log__c.fields.Created_Timestamp__c.getName())) : null;
            
            if(TRITON_LOG_LEVEL_AVAILABLE && String.isNotBlank(TRITON_LOG_LEVEL_FIELD_API_NAME)) {
                this.logLevel = (logRecord?.get(TRITON_LOG_LEVEL_FIELD_API_NAME) != null)
                    ? String.valueOf(logRecord.get(TRITON_LOG_LEVEL_FIELD_API_NAME)) : null;
            }
            this.logLevelValues = getTritonLogLevelValues();
        }

        public GanttChartData(Log__c log) {
            recordId = log.Id;
            name = log.Name;
            category = log.Category__c;
            type = log.Type__c;
            summary = log.Summary__c;
            duration = log.Duration__c;
            createdTimestamp = log.Created_Timestamp__c;
        }
    }

    public class RemoteActionResponse {
        public Object params;
        public Object data;
        public String error;
        public String stack;
    }

}