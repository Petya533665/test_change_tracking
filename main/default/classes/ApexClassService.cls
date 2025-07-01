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
}