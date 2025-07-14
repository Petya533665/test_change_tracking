public with sharing class TemplateUtil {

    public static final EventSObject EVENT_SOBJECT {
        get { return EVENT_SOBJECT == null ? (EVENT_SOBJECT = new EventSObject()) : EVENT_SOBJECT; }
        private set;
    }
    
    public static final IssueSObject ISSUE_SOBJECT {
        get { return ISSUE_SOBJECT == null ? (ISSUE_SOBJECT = new IssueSObject()) : ISSUE_SOBJECT; }
        private set;
    }

    public static final LogSObject LOG_SOBJECT {
        get { return LOG_SOBJECT == null ? (LOG_SOBJECT = new LogSObject()) : LOG_SOBJECT; }
        private set;
    }

    public static final TraceResultSObject TRACE_RESULT_SOBJECT {
        get { return TRACE_RESULT_SOBJECT == null ? (TRACE_RESULT_SOBJECT = new TraceResultSObject()) : TRACE_RESULT_SOBJECT; }
        private set;
    }

    public inherited sharing class EventSObject {
        private String defaultMonitoringActionSubject = 'New Critical Event: \'{!\'{0}.{1}\'}\'';
        private String defaultMonitoringActionBody = '\'{\'!{0}.Link\'}\'\n\'{\'!{0}.{1}\'}\' records in the triggered event.\nDetails:\n \'{\'!{0}.{2}\'}\'\n';

        /*
        [Subject]
        New Critical Event: {!pharos__Event__c.pharos__Rule_Description__c}

        [Body]
        {!pharos__Event__c.Link}
        {!pharos__Event__c.pharos__RecordCount__c} records in the triggered event.
        Details:
        {!pharos__Event__c.Event_Details__c}
        */
        public final Map<String, String> DEFAULT_MONITORING_ACTION = new Map<String, String>{
            'subject' => String.format(defaultMonitoringActionSubject,
                new List<String> {
                    Schema.SObjectType.Event__c.getName(),
                    Schema.SObjectType.Event__c.fields.Rule_Description__c.getName()
                }),
            'body' => String.format(defaultMonitoringActionBody,
                new List<String> {
                    Schema.SObjectType.Event__c.getName(),
                    Schema.SObjectType.Event__c.fields.RecordCount__c.getName(),
                    Schema.SObjectType.Event__c.fields.Event_Details__c.getName()
                })
        };
    }

    public inherited sharing class IssueSObject {
        private String defaultNotificationSubject = 'New \'{!\'{0}.{1}\'}\' Issue in \'{!\'{0}.{2}\'}\':  \'{!\'{0}.{3}\'}\'';
        private String defaultNotificationBody = '\'{\'!{0}.Link\'}\'\n' +
            'Functional Area: \'{\'!{0}.{1}\'}\'\n' +
            '\'{\'!{0}.{2}\'}\'\n';

        /*
        [Subject]
        New {!pharos__Issue__c.pharos__Category__c} Issue in {!pharos__Issue__c.pharos__Organization_Name__c}: {!pharos__Issue__c.pharos__Summary__c}

        [Body]
        {!pharos__Issue__c.Link}
        Functional Area: {!pharos__Issue__c.pharos__Functional_Area__c}
        {!pharos__Issue__c.pharos__Description__c}
        */
        public final Map<String, String> DEFAULT_NOTIFICATION = new Map<String, String>{
            'subject' => String.format(defaultNotificationSubject,
                new List<String> {
                    Schema.SObjectType.Issue__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Category__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Organization_Name__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Summary__c.getName()
                }),
            'body' => String.format(defaultNotificationBody,
                new List<String> {
                    Schema.SObjectType.Issue__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Functional_Area__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Description__c.getName()
                })
        };

        private String defaultJiraActionSubject = 'New Issue in  \'{!\'{0}.{1}\'}\' : \'{!\'{0}.{2}\'}\'';
        private String defaultJiraActionBody = '\'{\'!{0}.Link\'}\'\nDetails: \'{\'!{0}.{1}\'}\'\n';

        /*
        [Subject]
        New Issue in {!pharos__Issue__c.pharos__Organization_Name__c}: {!pharos__Issue__c.pharos__Summary__c}

        [Body]
        {!pharos__Issue__c.Link}
        Details: {!pharos__Issue__c.pharos__Description__c}
        */
        public final Map <String, String> DEFAULT_JIRA_ACTION = new Map<String, String>{
            'subject' => String.format(defaultJiraActionSubject,
                new List<String> {
                    Schema.SObjectType.Issue__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Organization_Name__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Summary__c.getName()
                }),
            'body' => String.format(defaultJiraActionBody,
                new List<String> {
                    Schema.SObjectType.Issue__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Description__c.getName()
                })
        };

        private String defaultTicketCommentActionSubject = null;
        private String defaultTicketCommentActionBody = '\'{\'!{0}.Link\'}\'\nDetails: \'{\'!{0}.{1}\'}\'\n';

        /*
        [Subject]
        null

        [Body]
        {!pharos__Issue__c.Link}
        Details: {!pharos__Issue__c.pharos__Description__c}
        */
        public final Map<String, String> DEFAULT_TICKET_COMMENT_ACTION = new Map<String, String>{
            'subject' => defaultTicketCommentActionSubject,
            'body' => String.format(defaultTicketCommentActionBody,
                new List<String> {
                    Schema.SObjectType.Issue__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Description__c.getName()
            })
        };
    }

    public inherited sharing class LogSObject {
        private String defaultNotificationSubject = 'New \'{!\'{0}.{1}\'}\' Log in \'{!\'{0}.{2}\'}\': \'{!\'{0}.{3}\'}\'';
        private String defaultNotificationBody = '\'{\'!{0}.Link\'}\'\n' +
            'Functional Area: \'{\'!{0}.{1}\'}\'\n' +
            'Type: \'{\'!{0}.{2}\'}\'\n' +
            '\'{\'!{0}.{3}\'}\'\n';
                
        /*
        [Subject]
        New {!pharos__Log__c.pharos__Category__c} Log in {!pharos__Log__c.pharos__Organization_Name__c}: {!pharos__Log__c.pharos__Summary__c}
        
        [Body]
        {!pharos__Log__c.Link}
        Functional Area: {!pharos__Log__c.pharos__Area__c} 
        Type: {!pharos__Log__c.pharos__Type__c}
        {!pharos__Log__c.pharos__Details__c}
        */
        public final Map<String, String> DEFAULT_NOTIFICATION = new Map<String, String>{
            'subject' => String.format(defaultNotificationSubject,
                new List<String> {
                    Schema.SObjectType.Log__c.getName(),
                    Schema.SObjectType.Log__c.fields.Category__c.getName(),
                    Schema.SObjectType.Log__c.fields.Organization_Name__c.getName(),
                    Schema.SObjectType.Log__c.fields.Summary__c.getName()
                }),
            'body' => String.format(defaultNotificationBody,
                new List<String> {
                    Schema.SObjectType.Log__c.getName(),
                    Schema.SObjectType.Log__c.fields.Area__c.getName(),
                    Schema.SObjectType.Log__c.fields.Type__c.getName(),
                    Schema.SObjectType.Log__c.fields.Details__c.getName()
                })
        };

        private String defaultJiraActionSubject = 'New Error in  \'{!\'{0}.{1}\'}\' : \'{!\'{0}.{2}\'}\'';
        private String defaultJiraActionBody = '\'{\'!{0}.Link\'}\'\nCategory: \'{\'!{0}.{1}\'}\'\nType: \'{\'!{0}.{2}\'}\'\nArea: \'{\'!{0}.{3}\'}\' \'{\'!{0}.{4}\'}\'';

        /*
        [Subject]
        New Error in {!pharos__Log__c.pharos__Organization_Name__c} : {!pharos__Log__c.pharos__Summary__c}
        
        [Body]
        {!pharos__Log__c.Link}
        Category: {!pharos__Log__c.pharos__Category__c}
        Type: {!pharos__Log__c.pharos__Type__c}
        Area: {!pharos__Log__c.pharos__Area__c} 
        {!pharos__Log__c.pharos__Details__c}
        */
        public final Map <String, String> DEFAULT_JIRA_ACTION = new Map<String, String>{
            'subject' => String.format(defaultJiraActionSubject,
                new List<String> {
                    Schema.SObjectType.Log__c.getName(),
                    Schema.SObjectType.Log__c.fields.Organization_Name__c.getName(),
                    Schema.SObjectType.Log__c.fields.Summary__c.getName()
                }),
            'body' => String.format(defaultJiraActionBody,
                new List<String> {
                    Schema.SObjectType.Log__c.getName(),
                    Schema.SObjectType.Log__c.fields.Category__c.getName(),
                    Schema.SObjectType.Log__c.fields.Type__c.getName(),
                    Schema.SObjectType.Log__c.fields.Area__c.getName(),
                    Schema.SObjectType.Log__c.fields.Details__c.getName()
                })
        };
    }

    public inherited sharing class TraceResultSObject {
        private String defaultNotificationSubject = 'New Trace Result available for Issue \'{!\'{0}.{1}.{2}\'}\' : \'{!\'{0}.{1}.{3}\'}\'';
        private String defaultNotificationBody = 'Access the Trace Result here: \'{!\'{0}.Link\'}\'\nCategory: \'{\'!{0}.{1}.{2}\'}\'\n Functional Area: \'{\'!{0}.{1}.{3}\'}\'';

        /*
        [Subject]
        New Trace Result available for Issue {!pharos__Trace_Result__c.pharos__Issue__r.Name} : {!pharos__Trace_Result__c.pharos__Issue__r.pharos__Summary__c}
        
        [Body]
        Access the Trace Result here: {!pharos__Trace_Result__c.Link}
        Category: {!pharos__Trace_Result__c.pharos__Issue__r.pharos__Category__c}
        Functional Area: {!pharos__Trace_Result__c.pharos__Issue__r.pharos__Functional_Area__c}
        */
        public final Map<String, String> DEFAULT_NOTIFICATION = new Map<String, String>{
            'subject' => String.format(defaultNotificationSubject,
                new List<String> {
                    Schema.SObjectType.Trace_Result__c.getName(),
                    Schema.SObjectType.Trace_Result__c.fields.Issue__c.getRelationshipName(),
                    Schema.SObjectType.Issue__c.fields.Name.getName(),
                    Schema.SObjectType.Issue__c.fields.Summary__c.getName()
                }),
            'body' => String.format(defaultNotificationBody,
                new List<String> {
                    Schema.SObjectType.Trace_Result__c.getName(),
                    Schema.SObjectType.Trace_Result__c.fields.Issue__c.getRelationshipName(),
                    Schema.SObjectType.Issue__c.fields.Category__c.getName(),
                    Schema.SObjectType.Issue__c.fields.Functional_Area__c.getName()
                })
        };
    }
}