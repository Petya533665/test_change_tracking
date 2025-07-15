public with sharing class EmailServicesService {
    /**
     * Email Services Address records service class
     */
    public static ApexEmailNotificationService apexEmailNotificationService = new ApexEmailNotificationService();

    /**
     * Email Services Address records service class
     */
    public static EmailServicesFunctionService emailServicesFunctionService = new EmailServicesFunctionService();

    /**
     * Email Services Address records service class
     */
    public static EmailServicesAddressService emailServicesAddressService = new EmailServicesAddressService();

    public with sharing class ApexEmailNotificationService {

        public String createApexEmailNotification(Map<String, Object> apexEmailNotificationData) {
            if (!apexEmailNotificationData.containsKey('UserId')) {
                apexEmailNotificationData.put('UserId', '');
            }
            
            return HttpUtils.post(
                ConfigUtil.TOOLING_API_CREATE_APEX_EMAIL_NOTIFICATION,
                JSON.serialize(apexEmailNotificationData),
                ConfigUtil.getToolingHeaders(),
                201
            );
        }

        public String updateApexEmailNotification(ApexEmailNotification apexEmailNotification, Map<String, Object> apexEmailNotificationData) {
            return HttpUtils.post(
                ConfigUtil.TOOLING_API_UPDATE_APEX_EMAIL_NOTIFICATION + apexEmailNotification.Id + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH,
                JSON.serialize(apexEmailNotificationData),
                ConfigUtil.getToolingHeaders(),
                204
            );
        }
    }

    public with sharing class EmailServicesAddressService {

        public String getEmailFromEmailServiceAddress(EmailServicesAddress address) {
            return address.LocalPart.toLowerCase() + Constants.GLOBAL_VARIABLE.SYMBOL_AT + address.EmailDomainName;
        }

        public String createEmailServicesAddress(Id functionId) {
            return HttpUtils.post(
                ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT,
                ConfigUtil.getRequestBodyCreateEmailService(functionId),
                ConfigUtil.SF_REST_API_HEADERS,
                201
            );
        }

        public String updateEmailServicesAddress(EmailServicesAddress emailServicesAddress) {
            return HttpUtils.patch(
                ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + emailServicesAddress.Id,
                ConfigUtil.getRequestBodyCreateEmailService(emailServicesAddress.FunctionId),
                ConfigUtil.SF_REST_API_HEADERS,
                204
            );
        }

        public void deleteEmailServicesAddresses(List<EmailServicesAddress> addressesToDelete) {
            for (EmailServicesAddress currentEmailServicesAddress : addressesToDelete) {
                EmailServicesAddressService.deleteEmailServicesAddress(currentEmailServicesAddress);
            }
        }

        public String deleteEmailServicesAddress(EmailServicesAddress emailServicesAddress) {
            return HttpUtils.del(
                ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + emailServicesAddress.Id,
                ConfigUtil.SF_REST_API_HEADERS,
                204
            );
        }
    }

    public with sharing class EmailServicesFunctionService {

        public String createEmailServicesFunction() {
            return HttpUtils.post(
                ConfigUtil.EMAIL_SERVICES_FUNCTION_ENDPOINT,
                ConfigUtil.getRequestBodyCreateEmailServiceFunction(ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID),
                ConfigUtil.SF_REST_API_HEADERS,
                201
            );
        }
        
        public String updateEmailServicesFunction(EmailServicesFunction emailServicesFunction, Boolean isActive) {
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
    }

    public class EmailServicesFunctionWrapper {
        public Boolean IsActive;
    }
}