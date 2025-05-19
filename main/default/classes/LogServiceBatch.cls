public with sharing class LogServiceBatch extends DatabaseUtils.PharosBatchImpl implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {

    private static LogServiceBatch instance = null;

    public static LogServiceBatch getInstance() {
        if (instance == null) {
            instance = new LogServiceBatch(Logger.getInstance());
        }
        return instance;
    }

    private LogServiceBatch(Logger logger) {
        super(logger);
    }

    public override void startBatch() {
        if (!DatabaseUtils.executeBatchWithLimitCheck('LogServiceBatch', this)) finishBatch();
    }

    public override Boolean initialValidation() {
        return ConfigUtil.SETTINGS.Service_Scheduler_Enabled__c;
    }

    public override Integer getIterationsCount() {
        return [SELECT COUNT() FROM Connected_Org__c WHERE Access_Token__c != NULL];
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, Access_Token__c, Refresh_Token__c, Private_Key__c FROM Connected_Org__c WHERE Access_Token__c != NULL]);
    }

    public void execute(Database.BatchableContext BC, List<Connected_Org__c> scope) {
        for (Connected_Org__c corg : scope) {
            corg.Connection_Valid__c = false;
            if (corg.Name == null || String.isBlank(corg.Access_Token__c) || String.isBlank(corg.Refresh_Token__c)) {
                continue;
            }
            try {
                corg = ConnectedOrgService.refreshToken(corg.Name);
                corg.Connection_Valid__c = true;
            }
            catch (Exception e) {
                loggerInstance?.add(loggerInstance.getInternalError(e, corg.Name, LogServiceBatch.class.getName(), 'refreshToken'));
            }
            try {
                DatabaseUtils.getInstance().performUpdateDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c)
                        .handleError(LogServiceBatch.class.getName(), 'execute', loggerInstance);
            }
            catch (Exception e) {
                loggerInstance?.add(loggerInstance.getInternalError(e, corg.Name, LogServiceBatch.class.getName(), 'performUpdateDML'));
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        loggerInstance?.flush();
        finishBatch();
    }

}