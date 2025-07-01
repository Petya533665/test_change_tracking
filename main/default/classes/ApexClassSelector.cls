public with sharing class ApexClassSelector {

    public List<ApexClass> getApexClassEmailHandler() {
        return [
            SELECT Id
            FROM ApexClass
            WHERE Name = :ConfigUtil.EMAIL_SERVICE_HANDLER_NAME AND NamespacePrefix = :ConfigUtil.NS
        ];
    }
}