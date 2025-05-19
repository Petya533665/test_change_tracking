@isTest
public class Test_ConnectedOrgService {

    static testMethod void test1 () {

        Test.startTest();

        ConnectedOrgService.createConnectedOrg('00D200000006k0s', 'production');
        Connected_Org__c corg = ConnectedOrgService.getConnectedOrgById('00D200000006k0s');
        ConnectedOrgService.updateConnectedOrg(corg);
        Connected_Org__c token,refreshToken;
        try {
            token = ConnectedOrgService.generateTokenForConnectedOrg('CodeCodeCode', new Map<String, String>(), '');
        }
        catch(Exception e) {}
        try {
            refreshToken = ConnectedOrgService.refreshToken('00D200000006k0s');
        }
        catch(Exception e) {}
        ConnectedOrgService.testConnection('00D200000006k0s');

        Test.stopTest();

        System.assertEquals(null, token);
        System.assertEquals(null, refreshToken);
    }
}