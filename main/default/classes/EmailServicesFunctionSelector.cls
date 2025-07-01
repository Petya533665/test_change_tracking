public with sharing class EmailServicesFunctionSelector {
    
    public List<EmailServicesFunction> getPackageEmailServicesFunctions() {
        return [
            SELECT Id, IsActive, FunctionName, ApexClassId
            FROM EmailServicesFunction
            WHERE ApexClassId = :ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID
            AND FunctionName = :ConfigUtil.EMAIL_SERVICE_HANDLER_NAME
        ];
    }
}