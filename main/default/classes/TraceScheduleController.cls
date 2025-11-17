public with sharing class TraceScheduleController {
    // Updated to support AutoTrace functionality

    private ApexPages.StandardSetController setController;

    public String traceScheduleId { get; set; }
    public String traceScheduleStatus { get; set; }

    public String lexOrigin { get; set; }

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

    public String userTimezone {
        get {
            return UserInfo.getTimeZone().getID();
        }
        set;
    }

    public String orgId {
        get {
            return UserInfo.getOrganizationId().left(15);
        }
        set;
    }

    private static final Set<String> TRACE_SCHEDULE_NO_ACTIVE_STATUSES = new Set<String>{'Completed', 'Inactive'};
    private static final String RECORD_ID = 'recordId';
    private static final String RANGE = 'range';
    private static final String ORGANIZATION_ID = 'organizationId';
    private static final String START_DATE = 'startDate';
    private static final String END_DATE = 'endDate';


    public class ConnectedOrgInfo {
        @AuraEnabled
        public String orgName;
        @AuraEnabled
        public String orgId;
        @AuraEnabled
        public Boolean isAvailable;
    }

    @AuraEnabled
    public static String getNameSpacePrefix() {
        return ConfigUtil.getNameSpacePrefix();
    }

    @AuraEnabled
    public static String getTraceScheduleId(String issueId) {
        List<Trace_Schedule__c> traceSchedules = [SELECT Id FROM Trace_Schedule__c WHERE Issue__c = :issueId AND Status__c NOT IN :TRACE_SCHEDULE_NO_ACTIVE_STATUSES];
        return !traceSchedules.isEmpty() ? traceSchedules[0].Id : null;
    }

    @AuraEnabled
    public static ConnectedOrgInfo getConnectedOrgInfo(String issueId) {
        ConnectedOrgInfo connectedOrgInfo = new ConnectedOrgInfo();
        connectedOrgInfo.isAvailable = false;
        List<Issue__c> issues = [SELECT Id, Log__r.Organization_Id__c, Log__r.Organization_Name__c FROM Issue__c WHERE Id = :issueId];
        if (!issues.isEmpty() && String.isNotBlank(issues[0].Log__r.Organization_Id__c)) {
            connectedOrgInfo.orgName = issues[0].Log__r.Organization_Name__c;
            connectedOrgInfo.orgId = issues[0].Log__r.Organization_Id__c;
            for (Connected_Org__c corg : ConnectedOrgService.getConnectedOrgsList()) {
                if (corg.Name.left(15) == issues[0].Log__r.Organization_Id__c.left(15)) {
                    if (ConnectedOrgService.isSelfConnectedOrg(corg) || (corg.Connection_Valid__c && String.isNotBlank(corg.Access_Token__c))) connectedOrgInfo.isAvailable = true;
                    break;
                }
            }
        }
        return connectedOrgInfo;
    }

    @AuraEnabled
    public static String createTraceRequest(String issueId) {
        List<Issue__c> issues = [SELECT Id, Name, Summary__c FROM Issue__c WHERE Id = :issueId];
        if (!issues.isEmpty()) {
            Trace_Schedule__c traceSchedule = new Trace_Schedule__c();
            traceSchedule.Name = issues[0].Name;
            traceSchedule.Description__c = issues[0].Summary__c;
            traceSchedule.Issue__c = issues[0].Id;
            insert traceSchedule;
            return traceSchedule.Id;
        }
        return null;
    }

    public TraceScheduleController(ApexPages.StandardSetController setController) {
        this.setController = setController;
        this.traceScheduleId = ApexPages.currentPage().getParameters().get('Id');
        List<Trace_Schedule__c> traceSchedules = [SELECT Id, Status__c FROM Trace_Schedule__c WHERE Id = :this.traceScheduleId];
        if (!traceSchedules.isEmpty()) {
            this.traceScheduleStatus = traceSchedules[0].Status__c;
        }
        this.lexOrigin = Url.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        String isDevParam = ApexPages.currentPage().getParameters().get('dev').escapeHtml4();
        if (String.isNotBlank(isDevParam)) {
            Cookie devCookie = new Cookie('a2developmentMode', isDevParam, null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{ devCookie });
            isDev = Boolean.valueOf(isDevParam);
        } else {
            Cookie devCookie = ApexPages.currentPage().getCookies().get('a2developmentMode');
            isDev = devCookie != null ? Boolean.valueOf(devCookie.getValue()) : false;
        }
    }

    public PageReference doRedirect() {
        return new ApexPages.Action('{!List}').invoke();
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
            if (method == 'getConnectedOrgs') {
                response.data = getConnectedOrgs();
            } else if (method == 'getUserOptions') {
                response.data = getUserOptions(data);
            } else if (method == 'getLogsByRange') {
                response.data = getLogsByRange(data);
            } else if (method == 'createTraceRequests') {
                response.data = createTraceRequests(data);
            } else if (method == 'updateTraceRequests') {
                response.data = updateTraceRequests(data);
            } else if (method == 'deleteTraceRequests') {
                response.data = deleteTraceRequests(data);
            } else if (method == 'getTraceRequests') {
                response.data = getTraceRequests(data);
            } else if (method == 'getTraceRequestsByTraceScheduleId') {
                response.data = getTraceRequestsByTraceScheduleId(data);
            } else if (method == 'deactivateTraceSchedule') {
                response.data = deactivateTraceSchedule(data);
            } else if (method.equals('setForecastSetting')) {
                response.data = HoltwintersForecastController.updateForecastSetting((String)request.get('data'));
            } else if (method.equals('getLogsCountByDayLargeDataset')) {
                response.data = HoltwintersForecastController.getLogsCountByDayLargeDataset((String)request.get('data'));
            } else if (method.equals('getUserIdToDateTime')) {
                response.data = HoltwintersForecastController.getUserIdToDateTime((String)request.get('data'));
            } else if (method.equals('createAutoTraceRequests')) {
                response.data = HoltwintersForecastController.createAutoTraceRequests((String)request.get('data'));
            } else if (method.equals('getIsEnabledHoltwinters')) {
                response.data = HoltwintersForecastController.getIsEnabledHoltwinters();
            } else {
                response.error = 'Action not found';
            }
            result = JSON.serialize(response);
            Logger.getInstance().flush();
        }
        catch(Exception e) {
            response.error = e.getMessage();
            response.stack = e.getStackTraceString();
            Logger.getInstance().internalError(e, TraceScheduleController.class.getName(), 'remoteActionHandler' + (String.isNotBlank(methodName) ? '.' + methodName : ''));
        }
        finally {
            try {
                result = JSON.serialize(response);
            }
            catch(Exception e) {
                Logger.getInstance().internalError(e, TraceScheduleController.class.getName(), 'remoteActionHandler.serializeResponse');
            }
        }
        return result;
    }

    public static Map<String, Object> getConnectedOrgs() {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, String> mapConnectedOrgs = new Map<String, String>();
        Connected_Org__c selfCorg = ConnectedOrgService.getConnectedOrgById(UserInfo.getOrganizationId().left(15));
        mapConnectedOrgs.put(selfCorg.Name, selfCorg.Title__c);
        for (Connected_Org__c corg : ConnectedOrgService.getConnectedOrgsList()) {
            if (corg.Connection_Valid__c && String.isNotBlank(corg.Access_Token__c) && corg.Data_Direction__c == ConnectedOrgService.BROADCAST_RECEIVE_FROM) {
                mapConnectedOrgs.put(corg.Name, corg.Title__c);
            }
        }
        output.put('connectedOrgs', mapConnectedOrgs);
        return output;
    }

    public static Map<String, Object> getUserOptions(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            String recordId = String.valueOf(input.get('recordId'));
            String filter = input.containsKey('filter') ? ('%' + String.valueOf(input.get('filter')) + '%') : null;
            List<Trace_Schedule__c> traceSchedules = [SELECT Id, Issue__c FROM Trace_Schedule__c WHERE Id = :recordId];
            if (!traceSchedules.isEmpty()) {
                Set<String> userIds = new Set<String>();
                List<Issue__c> issues = [SELECT Id, Impacted_Users__c, Log__r.Organization_Id__c FROM Issue__c WHERE Id = :traceSchedules[0].Issue__c];
                if (String.isNotBlank(issues[0].Impacted_Users__c)) {
                    List<Object> impactedUsers = (List<Object>)JSON.deserializeUntyped(issues[0].Impacted_Users__c);
                    for (Object impactedUser : impactedUsers) {
                        userIds.add((String)impactedUser);
                    }
                }
                Map<String, String> userOptions = new Map<String, String>();
                if (String.isNotBlank(issues[0]?.Log__r?.Organization_Id__c)) {
                    String organizationId = issues[0].Log__r.Organization_Id__c;
                    List<User> users = getUsersByOrganizationId(organizationId, userIds, filter);
                    for (User user : users) {
                        userOptions.put(user.Id, user.Name);
                    }
                }
                output.put('userOptions', userOptions);
            }
        }
        return output;
    }

    public static Map<String, Object> getLogsByRange(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            String recordId = (String)input.get(RECORD_ID);
            Integer range = (Integer)input.get(RANGE);
            List<Trace_Schedule__c> traceSchedules = [SELECT Id, Issue__c FROM Trace_Schedule__c WHERE Id = :recordId];
            if (!traceSchedules.isEmpty()) {
                List<Map<String, Object>> logs = new List<Map<String, Object>>();
                Datetime createdAt = System.now().addDays(-range);
                
                List<Log__c> allLogs = [
                    SELECT Id, User_Id__c, User_Name__c, Created_At__c
                    FROM Log__c
                    WHERE (Issue__c = :traceSchedules[0].Issue__c OR (Issue__r.Related_Issue__c = :traceSchedules[0].Issue__c AND Issue__r.Status__c = :IssueService.ISSUE_STATUS_DUPLICATE))
                    AND Created_At__c >= :createdAt
                    LIMIT 40000
                ];
                Integer totalLogs = allLogs.size();
                Integer intervalMinutes = (totalLogs < 500) ? 5 : ((totalLogs < 5000) ? 10 : 20);

                Map<String, Map<String, Object>> intervalGroups = new Map<String, Map<String, Object>>();
                for (Log__c log : allLogs) {
                    if (String.isNotBlank(log.User_Id__c) && String.isNotBlank(log.User_Name__c) && log.Created_At__c != null) {
                        Long diffMs = log.Created_At__c.getTime() - createdAt.getTime();
                        Integer minutesFromStart = (Integer)(diffMs / (1000 * 60));
                        Integer intervalNumber = minutesFromStart / intervalMinutes;
                        String intervalKey = String.valueOf(intervalNumber);

                        if (!intervalGroups.containsKey(intervalKey)) {
                            Map<String, Object> intervalData = new Map<String, Object>();
                            intervalData.put('id', log.Id);
                            intervalData.put('createdAt', log.Created_At__c);
                            intervalData.put('logTimesByUser', new Map<String, List<Datetime>>());
                            intervalGroups.put(intervalKey, intervalData);
                        }

                        Map<String, List<Datetime>> usersMap = (Map<String, List<Datetime>>)intervalGroups.get(intervalKey).get('logTimesByUser');
                        if (!usersMap.containsKey(log.User_Name__c)) {
                            usersMap.put(log.User_Name__c, new List<Datetime>());
                        }
                        List<Datetime> times = usersMap.get(log.User_Name__c);
                        if (times.size() < 5) {
                            times.add(log.Created_At__c);
                        }
                    }
                }

                List<Map<String, Object>> intervalGroupsList = new List<Map<String, Object>>();
                for (String intervalKey : intervalGroups.keySet()) {
                    intervalGroupsList.add(intervalGroups.get(intervalKey));
                }
                output.put('logs', intervalGroupsList);
            }
        }
        return output;
    }

    public static Map<String, Object> createTraceRequests(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            List<TraceRequest> traceRequestWrappers = (List<TraceRequest>)JSON.deserialize(JSON.serialize(data), List<TraceRequest>.class);
            Set<String> traceScheduleIds = new Set<String>();
            for (TraceRequest traceRequestWrapper : traceRequestWrappers) {
                traceScheduleIds.add(traceRequestWrapper.traceSchedule);
            }
            Map<Id, Trace_Schedule__c> traceSchedules = new Map<Id, Trace_Schedule__c>([
                SELECT Id, Issue__c, Issue__r.Log__r.Organization_Id__c
                FROM Trace_Schedule__c 
                WHERE Id IN :traceScheduleIds
            ]);

            List<Trace_Request__c> traceRequestsToInsert = new List<Trace_Request__c>();
            for (TraceRequest traceRequestWrapper : traceRequestWrappers) {
                Trace_Request__c traceRequest = traceRequestWrapper.getTraceRequest();
                String sourceId = traceSchedules.containsKey(traceRequest.Trace_Schedule__c)
                    ? traceSchedules.get(traceRequest.Trace_Schedule__c).Issue__r.Log__r.Organization_Id__c
                    : null;
                traceRequest.Issue__c = traceSchedules.containsKey(traceRequest.Trace_Schedule__c) ? traceSchedules.get(traceRequest.Trace_Schedule__c).Issue__c : null;
                traceRequest.Source__c = sourceId;
                traceRequestsToInsert.add(traceRequest);
            }
            output.put('result', DatabaseUtils.getInstance().performInsertDML(traceRequestsToInsert, Schema.SObjectType.Trace_Request__c)
                    .handleError(TraceScheduleController.class.getName(), '.createTraceRequests').saveResults);
            output.put('traceRequests', getTraceRequestWrappers(traceRequestsToInsert));
        }
        return output;
    }

    public static Map<String, Object> updateTraceRequests(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            List<TraceRequest> traceRequestWrappers = (List<TraceRequest>)JSON.deserialize(JSON.serialize(data), List<TraceRequest>.class);
            List<Trace_Request__c> traceRequestsToUpdate = new List<Trace_Request__c>();
            for (TraceRequest traceRequestWrapper : traceRequestWrappers) {
                Trace_Request__c traceRequest = traceRequestWrapper.getTraceRequest();
                traceRequestsToUpdate.add(traceRequest);
            }
            output.put('result', DatabaseUtils.getInstance().performUpdateDML(traceRequestsToUpdate, Schema.SObjectType.Trace_Request__c)
                    .handleError(TraceScheduleController.class.getName(), '.updateTraceRequests').saveResults);
            output.put('traceRequests', getTraceRequestWrappers(traceRequestsToUpdate));
        }
        return output;
    }

    public static List<TraceRequest> getTraceRequestWrappers(List<Trace_Request__c> traceRequests) {
        List<TraceRequest> traceRequestWrappers = new List<TraceRequest>();
        for (Trace_Request__c traceRequest : traceRequests) {
            traceRequestWrappers.add(new TraceRequest(traceRequest));
        }
        return traceRequestWrappers;
    }

    public static Map<String, Object> deleteTraceRequests(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            List<TraceRequest> traceRequestWrappers = (List<TraceRequest>)JSON.deserialize(JSON.serialize(data), List<TraceRequest>.class);
            List<Trace_Request__c> traceRequestsToDelete = new List<Trace_Request__c>();
            for (TraceRequest traceRequestWrapper : traceRequestWrappers) {
                Trace_Request__c traceRequest = traceRequestWrapper.getTraceRequest();
                traceRequestsToDelete.add(traceRequest);
            }
            output.put('result', DatabaseUtils.getInstance().performDeleteDML(traceRequestsToDelete, Schema.SObjectType.Trace_Request__c)
                .handleError(TraceScheduleController.class.getName(), '.deleteTraceRequests').deleteResults);
        }
        return output;
    }

    public static Map<String, Object> getTraceRequests(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
            String organizationId = (String)input.get(ORGANIZATION_ID);
            Date startDate = Date.valueOf((String)input.get(START_DATE)).addDays(-1);
            Date endDate = Date.valueOf((String)input.get(END_DATE)).addDays(1);
            List<Trace_Request__c> traceRequests = [
                SELECT Id, Name, Parent__c, Status__c, Schedule__c, Start_Date__c, End_Date__c, Trace_Schedule__c, Issue__c, Traced_Entity_Id__c, Type__c 
                FROM Trace_Request__c 
                WHERE Issue__c != NULL AND End_Date__c >= :startDate AND Start_Date__c <= :endDate
            ];
            Set<String> issueIds = new Set<String>();
            for (Trace_Request__c traceRequest : traceRequests) {
                issueIds.add(traceRequest.Issue__c);
            }
            List<Issue__c> issues = [
                SELECT Id, Log__r.Organization_Id__c
                FROM Issue__c
                WHERE Id IN :issueIds AND Log__r.Organization_Id__c != NULL
            ];
            issueIds = new Set<String>();
            for (Issue__c issue : issues) {
                if (organizationId.left(15) == issue.Log__r.Organization_Id__c.left(15)) issueIds.add(issue.Id);
            }
            traceRequests = [
                SELECT Id, Name, Parent__c, Status__c, Schedule__c, Start_Date__c, End_Date__c, Trace_Schedule__c, Issue__c, Traced_Entity_Id__c, Type__c 
                FROM Trace_Request__c 
                WHERE Issue__c IN :issueIds
            ];
            output.put('traceRequests', !traceRequests.isEmpty() ? getTraceRequests(traceRequests) : new List<TraceRequest>());
        }
        return output;
    }

    public static Map<String, Object> getTraceRequestsByTraceScheduleId(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        String traceScheduleId = (String)JSON.deserializeUntyped(JSON.serialize(data));
        List<Trace_Request__c> traceRequests = [
            SELECT Id, Name, Parent__c, Status__c, Schedule__c, Start_Date__c, End_Date__c, Trace_Schedule__c, Issue__c, Traced_Entity_Id__c, Type__c 
            FROM Trace_Request__c 
            WHERE Trace_Schedule__c = :traceScheduleId
        ];
        output.put('traceRequests', traceRequests.isEmpty() ? new List<TraceRequest>() : getTraceRequests(traceRequests));
        return output;
    }

    public static List<TraceRequest> getTraceRequests(List<Trace_Request__c> traceRequests) {
        Set<String> issueIds = new Set<String>();
        Set<String> tracedEntityIds = new Set<String>();
        for (Trace_Request__c traceRequest : traceRequests) {
            if (String.isNotBlank(traceRequest.Issue__c)) issueIds.add(traceRequest.Issue__c);
            if (String.isNotBlank(traceRequest.Traced_Entity_Id__c)) tracedEntityIds.add(traceRequest.Traced_Entity_Id__c);
        }
        List<Issue__c> issues = [SELECT Id, Log__r.Organization_Id__c FROM Issue__c WHERE Id IN :issueIds AND Log__r.Organization_Id__c != NULL LIMIT 1];
        String organizationId;
        if (!issues.isEmpty()) {
            organizationId = issues[0].Log__r.Organization_Id__c.left(15);
        }
        List<TraceRequest> traceRequestWrappers = new List<TraceRequest>();
        if (String.isNotBlank(organizationId)) {
            Map<Id, User> users = new Map<Id, User>();
            users.putAll(getUsersByOrganizationId(organizationId, tracedEntityIds, null));

            for (Trace_Request__c traceRequest : traceRequests) {
                traceRequestWrappers.add(new TraceRequest(traceRequest, users.containsKey(traceRequest.Traced_Entity_Id__c) ? users.get(traceRequest.Traced_Entity_Id__c)?.Name : null));
            }
        }
        return traceRequestWrappers;
    }

    private static List<User> getUsersByOrganizationId(String organizationId, Set<String> userIds, String filter) {
        List<User> users = new List<User>();
        if (String.isNotBlank(organizationId) && !userIds.isEmpty()) {
            Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById(organizationId);
            String query = new QBuilder(User.SObjectType)
                    .selectFields(LogPostProcessingService.USER_FIELDS)
                    .add(QBuilder.condition('Id').isIn(new List<String>(userIds)))
                    .add((String.isNotBlank(filter)) ? QBuilder.condition('Name').isLike(filter) : null)
                    .addLimit(1000)
                    .build();
            List<Object> objectsList = LogPostProcessingService.runQuery(corg, query);
            users = (List<User>)JSON.deserialize(JSON.serialize(objectsList), List<User>.class);
        }
        return users;
    }

    public static Map<String, Object> deactivateTraceSchedule(Object data) {
        Map<String, Object> output = new Map<String, Object>();
        if (data != null) {
            String recordId = (String)JSON.deserializeUntyped(JSON.serialize(data));
            List<Trace_Schedule__c> traceSchedules = [SELECT Id, Status__c FROM Trace_Schedule__c WHERE Id = :recordId];
            if (!traceSchedules.isEmpty()) {
                Boolean isInProgress = false;
                List<Trace_Request__c> traceRequests = [SELECT Id, Status__c FROM Trace_Request__c WHERE Trace_Schedule__c = :traceSchedules[0].Id];
                for (Trace_Request__c traceRequest : traceRequests) {
                    if (traceRequest.Status__c != TraceService.TRACE_REQUEST_STATUS_IN_PROGRESS) {
                        traceRequest.Status__c = TraceService.TRACE_REQUEST_STATUS_INACTIVE;
                    } else {
                        isInProgress = true;
                    }
                }
                if (!isInProgress && traceSchedules[0].Status__c != TraceService.TRACE_SCHEDULE_STATUS_IN_PROGRESS) {
                    traceSchedules[0].Status__c = TraceService.TRACE_SCHEDULE_STATUS_INACTIVE;
                } else {
                    isInProgress = true;
                }
                output.put('traceRequestsResult', DatabaseUtils.getInstance().performUpdateDML(traceRequests, Schema.SObjectType.Trace_Request__c)
                        .handleError(TraceScheduleController.class.getName(), '.deactivateTraceSchedule').saveResults);
                output.put('traceSchedulesResult', DatabaseUtils.getInstance().performUpdateDML(traceSchedules, Schema.SObjectType.Trace_Schedule__c)
                        .handleError(TraceScheduleController.class.getName(), '.deactivateTraceSchedule').saveResults);
                output.put('isInProgress', isInProgress);
            }
        }
        return output;
    }

    public class TraceSchedule {
        public String id;
        public String name;
        public String status;
        public String description;
        public List<TraceRequest> traceRequests;

        public TraceSchedule() {}

        public TraceSchedule(Trace_Schedule__c traceSchedule) {
            this.id = traceSchedule.Id;
            this.name = traceSchedule.Name;
            this.status = traceSchedule.Status__c;
            this.description = traceSchedule.Description__c;
            this.traceRequests = new List<TraceRequest>();
        }

        public TraceSchedule addTraceRequest(List<Trace_Request__c> traceRequests) {
            for (Trace_Request__c traceRequest : traceRequests) {
                this.traceRequests.add(new TraceRequest(traceRequest));
            }
            return this;
        }
    }

    public class TraceRequest {
        public String id;
        public String name;
        public String parent;
        public String status;
        public String type;
        public String traceSchedule;
        public String schedule;
        public String tracedEntityId;
        public String tracedEntityName;
        public Datetime startDate;
        public Datetime endDate;

        public TraceRequest() {}

        public TraceRequest(Trace_Request__c traceRequest) {
            this.id = traceRequest.Id;
            this.name = traceRequest.Name;
            this.parent = traceRequest.Parent__c;
            this.status = traceRequest.Status__c;
            this.type = traceRequest.Type__c;
            this.traceSchedule = traceRequest.Trace_Schedule__c;
            this.schedule = traceRequest.Schedule__c;
            this.tracedEntityId = traceRequest.Traced_Entity_Id__c;
            this.startDate = traceRequest.Start_Date__c;
            this.endDate = traceRequest.End_Date__c;
        }

        public TraceRequest(Trace_Request__c traceRequest, String userName) {
            this.id = traceRequest.Id;
            this.name = traceRequest.Name;
            this.parent = traceRequest.Parent__c;
            this.status = traceRequest.Status__c;
            this.type = traceRequest.Type__c;
            this.traceSchedule = traceRequest.Trace_Schedule__c;
            this.schedule = traceRequest.Schedule__c;
            this.tracedEntityId = traceRequest.Traced_Entity_Id__c;
            this.tracedEntityName = userName;
            this.startDate = traceRequest.Start_Date__c;
            this.endDate = traceRequest.End_Date__c;
        }

        public Trace_Request__c getTraceRequest() {
            return new Trace_Request__c(
                    Id = id,
                    Parent__c = parent,
                    Status__c = status,
                    Type__c = type,
                    Trace_Schedule__c = traceSchedule,
                    Schedule__c = schedule,
                    Traced_Entity_Id__c = tracedEntityId,
                    Start_Date__c = startDate,
                    End_Date__c = endDate
            );
        }
    }

    public class RemoteActionResponse {
        public Object params;
        public Object data;
        public String error;
        public String stack;
    }

}