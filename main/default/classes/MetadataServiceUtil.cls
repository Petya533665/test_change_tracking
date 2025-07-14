public with sharing class MetadataServiceUtil {

    public static final MetadataService.CaseSettings CASE_SETTINGS {
        get {
            if (CASE_SETTINGS == null) {
                CASE_SETTINGS = getCaseSettings();
            }
            return CASE_SETTINGS;
        }
        private set;
    }

    public static MetadataService.CaseSettings getCaseSettings() {
        MetadataService.MetadataPort service = getCaseSettingsService();

        List<MetadataService.CaseSettings> caseSettingsList =
            (List<MetadataService.CaseSettings>) service.readMetadata('CaseSettings',
                new String[] { 'Case' }).getRecords();
        MetadataService.CaseSettings caseSettings = (!caseSettingsList.isEmpty()) ? caseSettingsList.get(0): null;
        return caseSettings;
    }

    public static MetadataService.MetadataPort getCaseSettingsService() {
        MetadataService.MetadataPort service = createMetadataPort();
        service.setMetadataAPIVersion('50.0');
        return service;
    }

    public static MetadataService.FlowSettings getFlowSettings() {
        MetadataService.MetadataPort service = getFlowSettingsService();

        MetadataService.FlowSettings flowSettings =
            (MetadataService.FlowSettings) service.readMetadata('FlowSettings',
                new String[] { 'Flow' }).getRecords()[0];

        return flowSettings;
    }

    public static void setAutomatedFlowErrorTracking(Boolean value) {
        MetadataService.MetadataPort service = getFlowSettingsService();

        MetadataService.FlowSettings flowSettings = getFlowSettings();
        flowSettings.enableFlowUseApexExceptionEmail = value;

        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] {flowSettings});
        handleSaveResults(results[0]);
    }

    public static MetadataService.MetadataPort getFlowSettingsService() {
        MetadataService.MetadataPort service = createMetadataPort();
        service.setMetadataAPIVersion('63.0');
        return service;
    }

    public static void deleteRemoteSiteSettingsMetadata(List<String> rssList) {
        MetadataService.MetadataPort service = createMetadataPort();

        List<MetadataService.DeleteResult> results = service.deleteMetadata(
            'RemoteSiteSetting', rssList);
        handleDeleteResults(results[0]);
    }

    public static void upsertRemoteSiteSettingsMetadata(MetadataService.RemoteSiteSetting rss) {
        upsertRemoteSiteSettingsMetadata(rss, null);
    }

    public static void upsertRemoteSiteSettingsMetadata(MetadataService.RemoteSiteSetting rss, String accessToken) {
        MetadataService.MetadataPort service = createMetadataPort(accessToken);

        List<MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new MetadataService.Metadata[] {rss});
        handleUpsertResults(results[0]);
    }

    public static MetadataService.RemoteSiteSetting createRemoteSiteSettingInstance(String name, String url, String description) {
        MetadataService.RemoteSiteSetting rss = new MetadataService.RemoteSiteSetting();
        rss.fullName = name;
        rss.description = description;
        rss.disableProtocolSecurity = false;
        rss.isActive = true;
        rss.url = url;
        return rss;
    }

    public static MetadataService.ConnectedApp getConnectedAppMetadataByApiName(String connectedAppApiName) {
        MetadataService.MetadataPort service = createMetadataPort();
        return (MetadataService.ConnectedApp)service.readMetadata('ConnectedApp', new String[] {connectedAppApiName}).getRecords()[0];
    }

    public static void deleteConnectedAppMetadata(String connectedAppApiName) {
        MetadataService.MetadataPort service = createMetadataPort();
        MetadataService.DeleteResult deleteResult = service.deleteMetadata('ConnectedApp', new String[] {connectedAppApiName})[0];

        handleDeleteResults(deleteResult);
    }

    public static void createConnectedAppMetadata(String payload) {
        MetadataService.MetadataPort service = createMetadataPort();

        MetadataService.ConnectedApp app = (MetadataService.ConnectedApp)JSON.deserialize(payload, MetadataService.ConnectedApp.class);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { app });
        handleSaveResults(results[0]);
    }

    public static MetadataService.MetadataPort createMetadataPort() {
        return createMetadataPort(null);
    }

    public static MetadataService.MetadataPort createMetadataPort(String accessToken) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = String.isNotBlank(accessToken) ? accessToken : ConnectedOrgService.getSelfConnectedOrgAccessToken();
        return service;
    }

    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult) {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null) {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                        ( error.fields!=null && error.fields.size()>0 ?
                            ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceUtilException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceUtilException('Request failed with no specified error.');
    }

    public static void handleSaveResults(MetadataService.SaveResult saveResult) {
        // Nothing to see?
        if(saveResult==null || saveResult.success) {
            return;
        }
        // Construct error message and throw an exception
        if(saveResult.errors!=null) {
            List<String> messages = new List<String>();
            messages.add((saveResult.errors.size() == 1 ? Constants.METADATA.HANDLE_SAVE_RESULT_KEY_ERROR : Constants.METADATA.HANDLE_SAVE_RESULT_KEY_ERRORS) +
                Constants.METADATA.HANDLE_SAVE_RESULT_KEY_COMPONENTS + saveResult.fullName + '.'
            );
            for(MetadataService.Error error : saveResult.errors) {
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    (error.fields != null && error.fields.size() > 0 ?
                        Constants.METADATA.HANDLE_SAVE_RESULT_KEY_FIELDS + String.join(error.fields, ',') + '.' : '' ) );
            }
            if(messages.size() > 0) {
                throw new MetadataServiceUtilException(String.join(messages, ' '));
            }
        }
        if(!saveResult.success) {
            throw new MetadataServiceUtilException(Constants.METADATA.FAILED_NO_ERRORS_MESSAGE);
        }
    }

    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult) {
        // Nothing to see?
        if(upsertResult == null || upsertResult.success) {
            return;
        }
        // Construct error message and throw an exception
        if(upsertResult.errors != null) {
            List<String> messages = new List<String>();
            messages.add((upsertResult.errors.size() == 1 ? Constants.METADATA.HANDLE_SAVE_RESULT_KEY_ERROR : Constants.METADATA.HANDLE_SAVE_RESULT_KEY_ERRORS) +
                    Constants.METADATA.HANDLE_SAVE_RESULT_KEY_COMPONENTS + upsertResult.fullName + '.'
            );
            for(MetadataService.Error error : upsertResult.errors) {
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                        (error.fields != null && error.fields.size() > 0 ?
                            Constants.METADATA.HANDLE_SAVE_RESULT_KEY_FIELDS + String.join(error.fields, ',') + '.' : '' ) );
            }
            if(messages.size() > 0) {
                throw new MetadataServiceUtilException(String.join(messages, ' '));
            }
        }
        if(!upsertResult.success) {
            throw new MetadataServiceUtilException(Constants.METADATA.FAILED_NO_ERRORS_MESSAGE);
        }
    }

    public class RemoteSiteSettingsWrapper {
        public String Id;
        public Boolean IsActive;
        public String SiteName;
        public String EndpointUrl;
    }

    public class MetadataServiceUtilException extends Exception {}

    public class CspTrustedSiteWrapper {
        public String Id;
        public Boolean IsActive;
        public String DeveloperName;
        public String EndpointUrl;
    }

    public static List<CspTrustedSiteWrapper> getCspTrustedSites() {
        return getCspTrustedSites(ConnectedOrgService.getSelfConnectedOrgAccessToken());
    }

    public static List<CspTrustedSiteWrapper> getCspTrustedSites(String accessToken) {
        List<CspTrustedSiteWrapper> cspTrustedSitesList = new List<CspTrustedSiteWrapper>();
        try {
            String b = HttpUtils.get(
                ConfigUtil.TOOLING_QUERY_ENDPOINT + ConfigUtil.REST_CSP_TRUSTED_SITES_QUERY,
                ConfigUtil.getCspTrustedSitesHeadersMap(accessToken),
                200
            );
            Map<String, Object> respResults = (Map<String, Object>)JSON.deserializeUntyped(b);
            if (respResults.get(ConfigUtil.CSP_TRUSTED_SITES_KEY_RECORDS) != null) {
                cspTrustedSitesList = (List<CspTrustedSiteWrapper>)JSON.deserialize(JSON.serialize(respResults.get(ConfigUtil.CSP_TRUSTED_SITES_KEY_RECORDS)), List<CspTrustedSiteWrapper>.class);
                return cspTrustedSitesList;
            }
        }
        catch (HttpUtils.HttpUtilsException e) {
            AdminService.debugSession(e, 'getCspTrustedSites');
        }
        return cspTrustedSitesList;
    }

    public static Map<String, CspTrustedSiteWrapper> getCspTrustedSitesMap() {
        Map<String, CspTrustedSiteWrapper> output = new Map<String, CspTrustedSiteWrapper>();
        for (CspTrustedSiteWrapper csp : getCspTrustedSites()) {
            output.put(csp.EndpointUrl, csp);
        }
        return output;
    }

    public static void upsertCspTrustedSite(String name, String url, String description) {
        Map<String, CspTrustedSiteWrapper> createdCspTrustedSites = getCspTrustedSitesMap();
        if (createdCspTrustedSites.containsKey(url) && createdCspTrustedSites.get(url).DeveloperName == name) {
            return;
        }

        MetadataService.CspTrustedSite csp = createCspTrustedSiteInstance(name, url, description);
        upsertCspTrustedSiteMetadata(csp);
    }

    public static MetadataService.CspTrustedSite createCspTrustedSiteInstance(String name, String url, String description) {
        MetadataService.CspTrustedSite csp = new MetadataService.CspTrustedSite();
        csp.fullName = name;
        csp.description = description;
        csp.endpointUrl = url;
        csp.isActive = true;
        csp.context = 'All';
        csp.isApplicableToConnectSrc = true;
        return csp;
    }

    public static void upsertCspTrustedSiteMetadata(MetadataService.CspTrustedSite csp) {
        upsertCspTrustedSiteMetadata(csp, null);
    }

    public static void upsertCspTrustedSiteMetadata(MetadataService.CspTrustedSite csp, String accessToken) {
        MetadataService.MetadataPort service = createMetadataPort(accessToken);
        service.setMetadataAPIVersion('63.0');

        List<MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new MetadataService.Metadata[] {csp});
        handleUpsertResults(results[0]);
    }

    public static void removeCspTrustedSite(String name) {
        MetadataService.MetadataPort service = createMetadataPort();
        service.deleteMetadata('CspTrustedSite', new List<String> {name});
    }
}