public with sharing class EmailServicesAddressService {

    public static String getEmailFromEmailServiceAddress(EmailServicesAddress address) {
        return address.LocalPart.toLowerCase() + ConfigUtil.EMAIL_SERVICE_DATA_KEY_EMAIL_SYMBOL + address.EmailDomainName;
    }

    public static String createEmailServicesAddress(Id functionId) {
        return HttpUtils.post(
            ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT,
            ConfigUtil.getRequestBodyCreateEmailService(functionId),
            ConfigUtil.SF_REST_API_HEADERS,
            201
        );
    }

    public static String updateEmailServicesAddress(EmailServicesAddress emailServicesAddress) {
        return HttpUtils.patch(
            ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + emailServicesAddress.Id,
            ConfigUtil.getRequestBodyCreateEmailService(emailServicesAddress.FunctionId),
            ConfigUtil.SF_REST_API_HEADERS,
            204
        );
    }

    public static void deleteEmailServicesAddresses(List<EmailServicesAddress> addressesToDelete) {
        for (EmailServicesAddress currentEmailServicesAddress : addressesToDelete) {
            EmailServicesAddressService.deleteEmailServicesAddress(currentEmailServicesAddress);
        }
    }

    public static String deleteEmailServicesAddress(EmailServicesAddress emailServicesAddress) {
        return HttpUtils.del(
            ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + emailServicesAddress.Id,
            ConfigUtil.SF_REST_API_HEADERS,
            204
        );
    }
}