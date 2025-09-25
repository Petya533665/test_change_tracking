public with sharing class ProcessBuilderController {

    // public Boolean jiraSettingAvailable { get; set; }
    // public Log__c log { get; set; }
    // public String errorMessage { get; set; }
    // public Boolean redirect { get; set; }
    // public String taskDescription { get; set; }
    // public String taskLabels { get; set; }
    // public String taskAssignee { get; set; }
    // public String taskAssigneeId { get; set; }
    // public List<SelectOption> jiraUsersOptions { get; set; }
    // public List<String> taskComponents { get; set; }
    // public List<SelectOption> jiraComponentsOptions { get; set; }
    // public String epicId { get; set; }
    // public List<SelectOption> epicsOptions { get; set; }
    // public String projectId { get; set; }
    // public String taskProject { get; set; }
    // public List<SelectOption> jiraProjectOptions { get; set; }
    // public String issueTypeId { get; set; }
    // public String issueType { get; set; }
    // public List<SelectOption> issueTypeOptions { get; set; }

    public ProcessBuilderController(ApexPages.StandardController stdController) {
        // this.log = [
        //     SELECT Id, Name, Summary__c, Details__c, Bug_Tracker__c, Hash_1__c, Hash_2__c, Hash_3__c
        //     FROM Log__c
        //     WHERE Id = :stdController.getId()
        // ];
        // this.taskDescription = URL.getSalesforceBaseUrl().toExternalForm() + '/' + log.Id + '\n\n' + this.log.Details__c;
        // Action__c defaultJiraAction = ConfigUtil.getDefaultJiraAction();
        // this.taskLabels = defaultJiraAction.JIRALabels__c;
        // this.taskAssignee = defaultJiraAction.JIRAAssignee__c;
        // this.taskAssigneeId = defaultJiraAction.JIRAAssignee_Id__c;
        // this.epicId = defaultJiraAction.JIRAEpic__c;
        // this.taskComponents = String.isNotBlank(defaultJiraAction.JIRAComponents__c) ? defaultJiraAction.JIRAComponents__c.split(',') : new List<String>();
        // this.projectId = defaultJiraAction.JIRAProject__c;
        // this.issueTypeId = defaultJiraAction.JIRAIssueType__c;
        // if (this.log.Bug_Tracker__c == null) {
        //     errorMessage = ConfigUtil.JIRA_TASK_NOT_FOUND_MESSAGE;
        // }
        // jiraSettingAvailable = String.isNotBlank(ConfigUtil.JIRA_SETTINGS.Jira_Base_Url__c);
        // if (!jiraSettingAvailable) {
        //     errorMessage = ConfigUtil.JIRA_SETTINGS_NOT_FOUND_MESSAGE;
        // } else {
        //     this.jiraUsersOptions = new List<SelectOption>();
        //     List<JiraService.JiraUser> users = JiraService.getProjectAssignableUsers(this.projectId);
        //     this.jiraUsersOptions.add(new SelectOption('','Unassigned'));
        //     for (JiraService.JiraUser u : users) {
        //         // u.name for Jira Server platform
        //         // u.accountId for Jira Cloud
        //         String assigneeId = (u.accountId == null) ? u.name : u.accountId;
        //         this.jiraUsersOptions.add(new SelectOption(assigneeId, u.displayName));
        //     }
        //     this.jiraComponentsOptions = new List<SelectOption>();
        //     List<JiraService.JiraComponent> components = JiraService.getProjectComponents(this.projectId);
        //     this.jiraComponentsOptions.add(new SelectOption('','-none-'));
        //     for (JiraService.JiraComponent c : components) {
        //         this.jiraComponentsOptions.add(new SelectOption(c.id, c.name));
        //     }
        //     // get Epics
        //     List<JiraService.Epic> epics = JiraService.getEpics(this.projectId);
        //     this.epicsOptions = new List<SelectOption>();
        //     this.epicsOptions.add(new SelectOption('','-none-'));
        //     for (JiraService.Epic epic : epics) {
        //         this.epicsOptions.add(new SelectOption(epic.key, epic.fields.summary + ' (' + epic.key + ')'));
        //     }
        //     // get Projects and Issue Types
        //     List<JiraService.JiraProjectMeta> projects = JiraService.getProjects();
        //     this.jiraProjectOptions = new List<SelectOption>();
        //     this.issueTypeOptions = new List<SelectOption>();
        //     List<JiraService.JiraIssueType> jiraIssueTypes = new List<JiraService.JiraIssueType>();
        //     for (JiraService.JiraProjectMeta p : projects) {
        //         this.jiraProjectOptions.add(new SelectOption(p.id, p.name));
        //         if(p.id == this.projectId) {
        //             this.taskProject = p.id;
        //             jiraIssueTypes.addAll(p.issueTypes);
        //             for(JiraService.JiraIssueType type :jiraIssueTypes) {
        //                 this.issueTypeOptions.add(new SelectOption(type.id, type.name));
        //                 if(type.id == this.issueTypeId) {
        //                     issueType = type.id;
        //                 }
        //             }
        //         }
        //     }      
        // }
        // redirect = false;
    }

    public PageReference init() {
        // if (String.isNotBlank(log.Bug_Tracker__c)) {
        //     PageReference pageRef = new PageReference(log.Bug_Tracker__c);
        //     return pageRef;
        // }
        return null;
    }

    // public PageReference createNewJiraTask() {
    //     try {
    //         List<Log__c> logs = JiraService.getLogs(this.log.Id);
    //         Log__c log = logs.get(0);
    //         JiraService.JiraTaskInfo jti = new JiraService.JiraTaskInfo();
    //         jti.summary = log.Summary__c;
    //         jti.details = this.taskDescription;
    //         jti.assignee = this.taskAssigneeId;
    //         jti.labels = this.taskLabels;
    //         jti.componentIds = this.taskComponents;
    //         jti.epicId = this.epicId;
    //         jti.projectJiraId = this.taskProject;
    //         jti.jiraIssueTypeId = this.issueType;
    //         JiraService.createTask(logs, jti);

    //         errorMessage = null;
    //         this.redirect = true;
    //         return null;
    //     } catch(Exception e) {
    //         errorMessage = 'ERROR: ' + e.getMessage();
    //         Logger.getInstance().internalError(e);
    //     }
    //     return null;
    // }
}