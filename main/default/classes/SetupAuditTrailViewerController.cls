public with sharing class SetupAuditTrailViewerController {

    private static final String IS_BLUR_MODE_PARAM_NAME = 'isBlurMode';
    private static final String AUDIT_TRAIL_FAKE_DATA = '[{"DelegateUser":null,"Section":"Custom Objects","Display":"Changed Log page layout Log Layout","CreatedDate":"2022-12-19T10:35:23.000+0000","CreatedBy":{"Name":"Pharos Admin"}}]';

    public Boolean isBlurMode { get; set; }
    public String blurModeUrlParameter { get; set; }
    public Log__c log { get; set; }
    public Integer hours { get; set; }
    public String data { get; set; }

    public List<SelectOption> getHoursOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', '1 hour'));
        options.add(new SelectOption('12', '12 hours'));
        options.add(new SelectOption('24', '24 hours'));
        options.add(new SelectOption('48', '48 hours'));
        return options;
    }

    public Integer userTimezoneOffset {
        get {
            return AdminService.getUserTimezoneOffset();
        }
        set;
    }

    public SetupAuditTrailViewerController(ApexPages.StandardController stdController) {
        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        this.log = [
            SELECT Id, Setup_Audit_Trail__c, Created_At__c, CreatedDate, Issue__c
            FROM Log__c
            WHERE Id = :recordId
        ];
        data = log.Setup_Audit_Trail__c;
        String isBlurModeParam = ApexPages.currentPage().getParameters().get(IS_BLUR_MODE_PARAM_NAME);
        if (String.isNotBlank(isBlurModeParam)) {
            isBlurMode = Boolean.valueOf(isBlurModeParam);
        } else {
            isBlurMode = !BlurModeService.isAvailableDebugView(this.log.Issue__c);
        }
        if (isBlurMode) {
            data = AUDIT_TRAIL_FAKE_DATA;
            blurModeUrlParameter = BlurModeService.getEncryptedUrlParameter();
        }
    }

}