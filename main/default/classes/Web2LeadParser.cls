global class Web2LeadParser extends ApexExceptionParser {

    private static final String WEB_TO_LEAD_MARKER = 'Salesforce Could Not Create This Lead';
    private static final String LOG_SUMMARY = 'Web to Lead Failure:';
    private static final Pattern PATTERN_REASON = Pattern.compile('Reason: ([\\s\\S]+?)[\\n|\\r\\n|\\r]');
    private static final Pattern LEAD_PATTERN_CAUSED_BY_NAME_LONG = Pattern.compile('caused by: ([\\s\\S]+?): ([\\s\\S]+?): ([\\s\\S]+?)([\\n|\\r\\n|\\r]|\\Z)');
    private static final String CATEGORY_ERROR_TYPE = 'Web-to-Lead';
    private static final String ERROR_TYPE = 'Error';
    private static final String LOG_AREA = 'Leads';

    private String emailSubject;
    private String emailSentFrom;
    private String errorBody;
    private String error;
    private String category;
    private String stacktrace;
    private String summary;

    global override String getOrganizationId() {
        return UserInfo.getOrganizationId();
    }

    global override Boolean canProcess() {
        return String.isNotBlank(emailSubject) && emailSubject.contains(WEB_TO_LEAD_MARKER);
    }

    global override void init(String errorBody, String emailSubject, String emailSentFrom) {
        super.init(errorBody, emailSubject, emailSentFrom);
        this.errorBody = errorBody;
        this.emailSubject = emailSubject;
        this.emailSentFrom = emailSentFrom;
        this.error = this.errorBody;
        this.category = CATEGORY_ERROR_TYPE;
        this.summary = LOG_SUMMARY;
    }

    global override void process() {
        super.parseErrorMessage();
    }

    global override String getError() {
        return this.error;
    }

    global override String getErrorSummary() {
        Matcher pm = PATTERN_REASON.matcher(getError());
        if (pm.find()) {
            this.summary += pm.group(1);
        }
        return this.summary.abbreviate(255);
    }

    global override String getErrorDetails() {
        return this.errorBody;
    }

    global override String getErrorType() {
        return String.isBlank(super.getErrorType()) ? ERROR_TYPE : super.getErrorType();
    }

    global override String getStackTrace() {
        Matcher pm = LEAD_PATTERN_CAUSED_BY_NAME_LONG.matcher(getError());
        while (pm.find()) {
            this.stacktrace = pm.group(3);
        }
        return this.stacktrace;
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

    private String getErrorMessageWithStacktrace() {
        return this.summary + (String.isNotBlank(this.stacktrace) ? this.stacktrace : '');
    }

    global override String getHash1() {
        return LogService.generateHash_1(getValueForHash(getErrorMessageWithStacktrace()));
    }

    global override String getHash2() {
        return LogService.generateHash_2(getValueForHash(this.summary));
    }

    global override String getHash3() {
        return LogService.generateHash_3(getValueForHash(getCategory() + getErrorType() + getArea()));
    }

    public static String getValueForHash(String inputValue) {
        if(String.isNotBlank(inputValue)) {
            // remove all IDs (pseudo Ids)
            inputValue = inputValue.replaceAll(LogService.REGEX_ID_PATTERN, '');
            // remove all Non-alphanum characters and whitespaces
            inputValue = inputValue.replaceAll(LogService.REGEX_NON_ALPHANUMERIC_PATTERN, '');
            // remove all numbers
            inputValue = inputValue.replaceAll(LogService.REGEX_ALL_NUMBERS_PATTERN, '');
        }
        return inputValue;
    }

}