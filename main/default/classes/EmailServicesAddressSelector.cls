public with sharing class EmailServicesAddressSelector {
    
    public List<EmailServicesAddress> getEmailServicesAddressByFunctionId(Id functionId) {
        return [
            SELECT Id, IsActive
            FROM EmailServicesAddress
            WHERE FunctionId = :functionId
            LIMIT 1
        ];
    }
    
    public List<EmailServicesAddress> getActiveEmailServicesAddressesByFunctionIdsOrderingByCreatedDate(Set<Id> functionIds) {
        return [
            SELECT DeveloperName, RunAsUserId, LocalPart, EmailDomainName, IsActive, FunctionId
            FROM EmailServicesAddress
            WHERE FunctionId IN :functionIds 
            AND IsActive = true
            ORDER BY CreatedDate ASC
        ];
    }

    public List<EmailServicesAddress> getPackageAllAddresses() {
        return [
            SELECT DeveloperName, RunAsUserId, LocalPart, EmailDomainName, IsActive, FunctionId
            FROM EmailServicesAddress
            WHERE Function.ApexClassId = :ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID
            AND Function.FunctionName = :ConfigUtil.EMAIL_SERVICE_HANDLER_NAME
        ];
    }

    public List<EmailServicesAddress> getPackageAllActiveAddresses() {
        return [
            SELECT DeveloperName, RunAsUserId, LocalPart, EmailDomainName, IsActive, FunctionId
            FROM EmailServicesAddress
            WHERE Function.ApexClassId =: ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID
            AND Function.FunctionName = :ConfigUtil.EMAIL_SERVICE_HANDLER_NAME
            AND IsActive = true
        ];
    }
}