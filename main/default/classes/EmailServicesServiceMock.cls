@IsTest
public with sharing class EmailServicesServiceMock {

    /**
     * Apex Email Notification records service mock class
     */
    public static ApexEmailNotificationServiceMock apexEmailNotificationServiceMock = new ApexEmailNotificationServiceMock();

    /**
     * Email Services Function records service mock class
     */
    public static EmailServicesFunctionServiceMock emailServicesFunctionServiceMock = new EmailServicesFunctionServiceMock();

    /**
     * Email Services Address records service mock class
     */
    public static EmailServicesAddressServiceMock emailServicesAddressServiceMock = new EmailServicesAddressServiceMock();

    public with sharing class ApexEmailNotificationServiceMock {
        public Map<String, HttpCalloutMock> getCreateApexEmailNotificationMock() {
            return new Map<String, HttpCalloutMock>{
                ConfigUtil.TOOLING_API_CREATE_APEX_EMAIL_NOTIFICATION => new TestDataFactory.SingleRequestMock(
                    201,
                    'OK',
                    '{}'
                )
            };
        }

        public Map<String, HttpCalloutMock> getUpdateApexEmailNotificationMock(Id apexEmailNotificationId) {
            return new Map<String, HttpCalloutMock>{
                ConfigUtil.TOOLING_API_UPDATE_APEX_EMAIL_NOTIFICATION + apexEmailNotificationId + ConfigUtil.OVERRIDE_HTTP_METHOD_PATCH =>
                new TestDataFactory.SingleRequestMock(
                    204,
                    'No Content',
                    JSON.serialize(new Map<String, Object>{})
                )
            };
        }
    }

    public with sharing class EmailServicesFunctionServiceMock {
        public Map<String, HttpCalloutMock> getCreateEmailServicesFunctionMock(Id emailServicesFunctionIdToReponse) {
            AdminService.SObjectsCreateResponse response = new AdminService.SObjectsCreateResponse();
            response.id = emailServicesFunctionIdToReponse;
            response.success = true;

            return new Map<String, HttpCalloutMock>{
                ConfigUtil.EMAIL_SERVICES_FUNCTION_ENDPOINT => new TestDataFactory.SingleRequestMock(
                    201,
                    'OK',
                    JSON.serialize(response)
                )
            };
        }
    }

    public with sharing class EmailServicesAddressServiceMock {

        public Map<String, HttpCalloutMock> getCreateEmailServicesAddressMock(Id emailServicesAddressIdToReponse) {
            AdminService.SObjectsCreateResponse response = new AdminService.SObjectsCreateResponse();
            response.id = emailServicesAddressIdToReponse;
            response.success = true;

            return new Map<String, HttpCalloutMock>{
                ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT => new TestDataFactory.SingleRequestMock(
                    201,
                    'OK',
                    JSON.serialize(response)
                )
            };
        }

        public Map<String, HttpCalloutMock> getUpdateEmailServicesAddressMocks(List<Id> emailServicesAddressIds) {
            Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
            for (Id currentEmailServicesAddressId : emailServicesAddressIds) {
                endpoint2TestResp.put(
                    ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + currentEmailServicesAddressId,
                    new TestDataFactory.SingleRequestMock(
                        204,
                        'No Content',
                        JSON.serialize(new Map<String, Object>{})
                    )
                );
            }
            return endpoint2TestResp;
        }

        public Map<String, HttpCalloutMock> getDeleteEmailServicesAddressMocks(List<Id> emailServicesAddressIds) {
            Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
            for (Id currentEmailServicesAddressId : emailServicesAddressIds) {
                endpoint2TestResp.put(
                    ConfigUtil.EMAIL_SERVICES_ADDRESS_ENDPOINT + '/' + currentEmailServicesAddressId,
                    new TestDataFactory.SingleRequestMock(
                        204,
                        'No Content',
                        JSON.serialize(new Map<String, Object>{})
                    )
                );
            }
            return endpoint2TestResp;
        }
    }
}