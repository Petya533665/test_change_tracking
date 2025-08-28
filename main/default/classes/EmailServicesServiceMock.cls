@IsTest
public with sharing class EmailServicesServiceMock {

    /**
     * Email Services Address records service mock class
     */
    public static EmailServicesAddressServiceMock emailServicesAddressServiceMock = new EmailServicesAddressServiceMock();

    public with sharing class EmailServicesAddressServiceMock {

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