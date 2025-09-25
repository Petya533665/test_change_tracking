public with sharing class AccountErrorTriggerHandler {

    public static void onBeforeInsert() {
        //generateError();
    }

    public static void onBeforeUpdate() {
        //generateError();
    }

    @Future (Callout=true)
    private static void generateError() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Url.getOrgDomainUrl().toExternalForm() + '/services/async/52.0/job/7505e0000062E8CAAU/batch?id=7505e0000062E8CAAU&key=ppp');
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('[' +
                '{' +
                '"Status":"New",' +
                '"Industry":"",' +
                '"Company":"TestCompanyName",' +
                '"LastName":"TestLastName",' +
                '"Description":"TestDescription"' +
                '},' +
                '{' +
                '"Status":"New",' +
                '"Industry":"",' +
                '"Company":"TestCompanyName2",' +
                '"LastName":"TestLastName2",' +
                '"Description":"TestDescription2"' +
                '}' +
                ']');
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(res);
        if (res.getStatusCode() != 200) {
            LogUtil.instance.integration(LogUtil.Type.Backend, LogUtil.Area.Community, 'some integration', 'error details', req, res);
        }

        Contact contact = new Contact();
        contact.LastName = 'Last';
        insert contact;

        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint(System.Url.getOrgDomainUrl().toExternalForm() + '/services/async/52.0/job/7505e0000062E8CAAU/batch');
        req2.setMethod('POST');
        req2.setHeader('X-SFDC-Session', UserInfo.getSessionId());
        req2.setHeader('Content-Type', 'application/json');
        req2.setBody('[' +
                '{' +
                '"Status":"New",' +
                '"Industry":"",' +
                '"Company":"TestCompanyName",' +
                '"LastName":"TestLastName",' +
                '"Description":"TestDescription"' +
                '},' +
                '{' +
                '"Status":"New",' +
                '"Industry":"",' +
                '"Company":"TestCompanyName2",' +
                '"LastName":"TestLastName2",' +
                '"Description":"TestDescription2"' +
                '}' +
                ']');
        req2.setTimeout(120000);
        Http h2 = new Http();
        HttpResponse res2;
        try {
            res2 = h2.send(req);
        } catch (Exception e) {
            System.debug(e);
            LogUtil.instance.integration(LogUtil.Area.Community, e, req2, res2);
        }
    }

}