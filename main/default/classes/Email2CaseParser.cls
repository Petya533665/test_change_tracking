global class Email2CaseParser extends ApexExceptionParser {

    private static final String CASE_ERROR_START = 'The following errors were encountered while processing an incoming email:';
    private static final String CASE_ERROR_END = 'From:';
    private static final String EMAIL_TO_CASE_MARKER = 'Email-to-Case:';
    private static final String LOG_SUMMARY = 'Email to Case Failure';
    private static final String CATEGORY_ERROR_TYPE = 'Email-to-Case';
    private static final String ERROR_TYPE = 'Error';
    private static final String LOG_AREA = 'Cases';

    private String emailSubject;
    private String emailSentFrom;
    private String errorBody;
    private String error;
    private String category;

    global override String getOrganizationId() {
        return UserInfo.getOrganizationId();
    }

    global override Boolean canProcess() {
        return String.isNotBlank(emailSubject) && emailSubject.contains(EMAIL_TO_CASE_MARKER);
    }

    global override void init(String errorBody, String emailSubject, String emailSentFrom) {
        super.init(errorBody, emailSubject, emailSentFrom);
        this.errorBody = errorBody;
        this.emailSubject = emailSubject;
        this.emailSentFrom = emailSentFrom;
        this.error = String.isBlank(this.errorBody)
            ? ''
            : (this.errorBody.containsIgnoreCase(CASE_ERROR_START) && this.errorBody.containsIgnoreCase(CASE_ERROR_END)
                ? this.errorBody.substring(this.errorBody.indexOf(CASE_ERROR_START) + CASE_ERROR_START.length(), this.errorBody.indexOf(CASE_ERROR_END))
                : '');
        this.category = CATEGORY_ERROR_TYPE;
    }

    global override void process() {}

    global override String getError() {
        return this.error;
    }

    global override String getErrorSummary() {
        return LOG_SUMMARY;
    }

    global override String getErrorDetails() {
        return this.errorBody;
    }

    global override String getErrorType() {
        return ERROR_TYPE;
    }

    global override String getStackTrace() {
        return this.error;
    }

    global override String getArea() {
        return LOG_AREA;
    }

    global override String getCategory() {
        return CATEGORY_ERROR_TYPE;
    }

    global override List<ICustomErrorInfo> getCustomInfo() {
        List<ICustomErrorInfo> customFields = new List<ICustomErrorInfo>{
            new CategoryField(this.getCategory())
        };
        return customFields;
    }

    public class CategoryField implements ICustomErrorInfo {
        public String category;
        public CategoryField(String value) {
            this.category = value;
        }
        public String getValue() {
            return this.category;
        }
        public String getLogFieldName() {
            return Schema.sObjectType.Log__c.fields.Category__c.getName();
        }
    }

    global override String getHash1() {
        return LogService.generateHash_1(Web2LeadParser.getValueForHash(getError()));
    }

    global override String getHash2() {
        return LogService.generateHash_2(Web2LeadParser.getValueForHash(getError()));
    }

    global override String getHash3() {
        return LogService.generateHash_3(Web2LeadParser.getValueForHash(getCategory() + getErrorType() + getArea()));
    }

}