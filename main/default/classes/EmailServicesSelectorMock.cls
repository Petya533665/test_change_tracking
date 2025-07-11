@IsTest
public with sharing class EmailServicesSelectorMock implements System.StubProvider {


    private static final String TEST_TEMPLATE_APEX_EMAIL_NOTIFICATIONS_EMAIL = ConfigUtil.EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME.toLowerCase() + '@testpharos.io';
    private static final String TEST_EMAIL_SERVICES_ADDRESS_EMAIL_DOMAIN_NAME = 'testpharos.io';
        
    private String apexEmailNotificationsEmail;
    private String emailServicesAddressDeveloperName;
    
    private List<Id> apexEmailNotificationIds;
    private List<Id> emailServicesFunctionIds;
    private List<Id> emailServicesAddressIds;

    public EmailServicesSelectorMock(List<Id> apexEmailNotificationIds, List<Id> emailServicesFunctionIds, List<Id> emailServicesAddressIds) {
        this.apexEmailNotificationIds = apexEmailNotificationIds;
        this.emailServicesFunctionIds = emailServicesFunctionIds;
        this.emailServicesAddressIds = emailServicesAddressIds;
    }

    public void setApexEmailNotificationsEmail(String apexEmailNotificationsEmail) {
        this.apexEmailNotificationsEmail = apexEmailNotificationsEmail;
    }

    public String getApexEmailNotificationsEmail() {
        return this.apexEmailNotificationsEmail ?? TEST_TEMPLATE_APEX_EMAIL_NOTIFICATIONS_EMAIL;
    }

    public void setEmailServicesAddressDeveloperName(String emailServicesAddressDeveloperName) {
        this.emailServicesAddressDeveloperName = emailServicesAddressDeveloperName;
    }

    public String getEmailServicesAddressDeveloperName() {
        return this.emailServicesAddressDeveloperName ?? ConfigUtil.EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME;
    }
    
    public Object handleMethodCall(Object stubbedObject,
                                    String stubbedMethodName,
                                    Type returnType,
                                    List<Type> listOfParamTypes,
                                    List<String> listOfParamNames,
                                    List<Object> listOfArgs) {

        if (stubbedMethodName.equals('getApexEmailNotifications')) {
            return this.getApexEmailNotifications();
        } else if (stubbedMethodName.equals('getPackageAllAddresses')) {
            return this.getPackageAllAddresses();
        } else if (stubbedMethodName.equals('getPackageEmailServicesFunctions')) {
            return this.getPackageEmailServicesFunctions();
        } else {
            return null;
        }
    }

    private List<ApexEmailNotification> getApexEmailNotifications() {
        List<ApexEmailNotification> apexEmailNotifications = new List<ApexEmailNotification>();

        Boolean isSkipCreationNeeded = 
            this.apexEmailNotificationIds == null
            || this.apexEmailNotificationIds.isEmpty();

        if (isSkipCreationNeeded) {
            return apexEmailNotifications;
        }

        for (Integer i = 0; i < this.apexEmailNotificationIds.size(); i++) {
            apexEmailNotifications.add(new ApexEmailNotification(
                Id = this.apexEmailNotificationIds.get(i),
                Email = this.getApexEmailNotificationsEmail() + i
            ));
        }
        return apexEmailNotifications;
    }
    
    private List<EmailServicesAddress> getPackageAllAddresses() {
        List<EmailServicesAddress> emailServicessAddresses = new List<EmailServicesAddress>();
        Boolean isSkipCreationNeeded =
            this.emailServicesFunctionIds == null 
            || this.emailServicesFunctionIds.isEmpty() 
            || this.emailServicesAddressIds == null 
            || this.emailServicesAddressIds.isEmpty();
        if (isSkipCreationNeeded) {
            return emailServicessAddresses;
        }

        for (Integer i = 0; i < this.emailServicesAddressIds.size(); i++) {
            // use this approach to avoid the error 'Field EmailDomainName is not editable'
            emailServicessAddresses.add((EmailServicesAddress) JSON.deserialize(
                JSON.serialize(
                    new Map<String, Object>{
                        'Id' => this.emailServicesAddressIds.get(i),
                        'DeveloperName' => this.getEmailServicesAddressDeveloperName(),
                        'RunAsUserId' => UserInfo.getUserId(),
                        'LocalPart' => ConfigUtil.EMAIL_SERVICES_ADDRESS_DEVELOPER_NAME.toLowerCase(),
                        'EmailDomainName' => TEST_EMAIL_SERVICES_ADDRESS_EMAIL_DOMAIN_NAME + i,
                        'IsActive' => true,
                        'FunctionId' => emailServicesFunctionIds.get(0)
                    }
                ),
                EmailServicesAddress.class
            ));
        }

        return emailServicessAddresses;
    }

    public List<EmailServicesFunction> getPackageEmailServicesFunctions() {
        List<EmailServicesFunction> emailServicesFunctions = new List<EmailServicesFunction>();
        Boolean isSkipCreationNeeded =
            this.emailServicesFunctionIds == null
            || this.emailServicesFunctionIds.isEmpty();

        if (isSkipCreationNeeded) {
            return emailServicesFunctions;
        }

        for (Integer i = 0; i < this.emailServicesFunctionIds.size(); i++) {
            emailServicesFunctions.add(new EmailServicesFunction(
                Id = this.emailServicesFunctionIds.get(i),
                IsActive = true,
                FunctionName = ConfigUtil.EMAIL_SERVICE_HANDLER_NAME,
                ApexClassId = ApexClassService.APEX_CLASS_EMAIL_HANDLER_ID
            ));
        }
        return emailServicesFunctions;
    }
}