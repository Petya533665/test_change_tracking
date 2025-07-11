public with sharing class ApexClassService {

    private static ApexClassSelector apexClassSelector = new ApexClassSelector();
    
    public static final Id APEX_CLASS_EMAIL_HANDLER_ID {
        get {
            if (APEX_CLASS_EMAIL_HANDLER_ID == null) {
                APEX_CLASS_EMAIL_HANDLER_ID = apexClassSelector.getApexClassEmailHandler().get(0).Id;
            }
            return APEX_CLASS_EMAIL_HANDLER_ID;
        }
        set;
    }

    public with sharing class ApexClassSelector {

        public List<ApexClass> getApexClassEmailHandler() {
            return [
                SELECT Id
                FROM ApexClass
                WHERE Name = :ConfigUtil.EMAIL_SERVICE_HANDLER_NAME AND NamespacePrefix = :ConfigUtil.NS
            ];
        }
    }
}