public with sharing class EmailServicesFunctionService {

    public static String createEmailServicesFunction() {
        return HttpUtils.post(
            ConfigUtil.EMAIL_SERVICES_FUNCTION_ENDPOINT,
            ConfigUtil.getRequestBodyCreateEmailServiceFunction(ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID),
            ConfigUtil.SF_REST_API_HEADERS,
            201
        );
    }
    
    public static String updateEmailServicesFunction(EmailServicesFunction emailServicesFunction, Boolean isActive) {
        EmailServicesFunctionWrapper data = new EmailServicesFunctionWrapper();
        data.IsActive = isActive;

        if (emailServicesFunction.IsActive == isActive) {
            return '';
        }
        
        return HttpUtils.post(
            ConfigUtil.EMAIL_SERVICES_FUNCTION_ENDPOINT + '/' + emailServicesFunction.Id + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
            JSON.serialize(data),
            ConfigUtil.getToolingHeaders(),
            204
        );
    }

    public class EmailServicesFunctionWrapper {
        public Boolean IsActive;
    }
}