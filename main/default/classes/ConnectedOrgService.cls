public with sharing class ConnectedOrgService {

    public static final Set<String> CONNECTED_ORG_TYPES = new Set<String> {
        'production',
        'sandbox'
    };

    public static final String BROADCAST_SEND_TO = 'sendTo';
    public static final String BROADCAST_RECEIVE_FROM = 'receiveFrom';
    public static final String SOURCE_QUICK_START = 'QuickStart';
    public static final String DEFAULT_DEVOPS_ORG_NAME = 'DevOps Center';

    public static List<Connected_Org__c> getConnectedOrgsList() {

        List<Connected_Org__c> corgs = Connected_Org__c.getAll().values();

        List<Connected_Org__c> filteredCOrgs = new List<Connected_Org__c>();
        for (Connected_Org__c corg : cOrgs) {
            if (corg.Name.length() <= 18) {
                filteredCOrgs.add(corg);
            }
        }

        return filteredCOrgs;
    }

    public static Connected_Org__c getPassthroughConnectedOrg() {
        Connected_Org__c corg;
        if (String.isNotBlank(ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c)) {
            corg = getConnectedOrgById(ConfigUtil.CONNECTED_ORGS_SETTINGS.Passthrought_Email__c);
        }
        return corg != null && corg.Connection_Valid__c ? corg : null;
    }

    public static List<Connected_Org__c> getBroadcastConnectedOrgs(String dataDirection) {
        List<Connected_Org__c> result = new List<Connected_Org__c>();
        for (Connected_Org__c corg : getConnectedOrgsList()) {
            if (corg.Connection_Valid__c && corg.Data_Direction__c == dataDirection) {
                result.add(corg);
            }
        }
        return result;
    }

    public static Connected_Org__c getDevOpsCenterConnectedOrg() {
        for (Connected_Org__c corg : getConnectedOrgsList()) {
            if (corg.Title__c == DEFAULT_DEVOPS_ORG_NAME) {
                return corg;
            }
        }
        return null;
    }

    public static List<AdminService.ConnectedOrgDTO> getQSAnotherConnectedOrg() {
        List<AdminService.ConnectedOrgDTO> result = new List<AdminService.ConnectedOrgDTO>();
        for(Connected_Org__c corg : getConnectedOrgsList()) {
            if(corg.Source__c == SOURCE_QUICK_START) {
                result.add(new AdminService.ConnectedOrgDTO(corg));
                break;
            }
        }
        return result;
    }

    public static Boolean isMyDomainEnabled() {
        Boolean isMyDomainEnabledCheck1 = Url.getOrgDomainUrl().getHost().contains('--');
        Boolean isMyDomainEnabledCheck2 = Url.getOrgDomainUrl().getHost().endsWith('my.salesforce.com');
        return isMyDomainEnabledCheck1 || isMyDomainEnabledCheck2;
    }

    public static Boolean isSelfConnectedOrg(Connected_Org__c corg) {
        return (UserInfo.getOrganizationId().left(15) == corg.Name.left(15)
            && isMyDomainEnabled());
    }

    public static String getConnectedOrgAccessToken(Connected_Org__c corg) {
        return getConnectedOrgAccessToken(corg, null);
    }

    public static String getSelfConnectedOrgAccessToken() {
        return getConnectedOrgAccessToken(getConnectedOrgById(UserInfo.getOrganizationId()), null);
    }

    public static String getConnectedOrgAccessToken(Connected_Org__c corg, Logger logger) {
        if (corg == null || (isSelfConnectedOrg(corg) && String.isBlank(corg.Access_Token__c))) {
            return ConfigUtil.USER_SESSION_ID;
        }
        return getDecryptedTokenFromCache(corg, logger);
    }

    public static Connected_Org__c createSelfConnectedOrg(String name, String description) {
        Connected_Org__c newCorg = new Connected_Org__c(
            Name = DEFAULT_DEVOPS_ORG_NAME.equals(name) ? UserInfo.getOrganizationId() : UserInfo.getOrganizationId().left(15),
            Title__c = name,
            Description__c = description,
            Type__c = ConfigUtil.currentOrgIsSandbox ? 'sandbox' : 'production',
            Instance_Url__c = System.Url.getOrgDomainUrl().toExternalForm(),
            Connection_Valid__c = true
        );
        DatabaseUtils.getInstance().performInsertDML(new List<Connected_Org__c>{newCorg}, Schema.SObjectType.Connected_Org__c)
                .handleError(ConnectedOrgService.class.getName(), '.createSelfConnectedOrg');
        return newCorg;
    }

    public static Connected_Org__c createConnectedOrg(String name, String type) {
        return createConnectedOrg(name, type, null, null, null, null);
    }

    public static Connected_Org__c createConnectedOrg(String name, String type, String description, String source, String dataDirection, String organizationId) {

        if (!CONNECTED_ORG_TYPES.contains(type)) {
            throw new ConnectedOrgServiceException('Invalid Connected Org type: ' + type);
        }

        Connected_Org__c newCorg = new Connected_Org__c(
            Name = String.isNotBlank(organizationId) ? organizationId.left(15) : ConfigUtil.generateUUID4(),
            Title__c = name,
            Description__c = description,
            Type__c = type,
            Access_Token__c = null,
            Refresh_Token__c = null,
            Token_Refreshed_At__c = null,
            Instance_Url__c = null,
            Identity_Url__c = null,
            Source__c = source,
            Data_Direction__c = dataDirection,
            Connection_Valid__c = String.isNotBlank(organizationId)
        );

        DatabaseUtils.getInstance().performInsertDML(new List<Connected_Org__c>{newCorg}, Schema.SObjectType.Connected_Org__c)
                .handleError(ConnectedOrgService.class.getName(), '.createConnectedOrg');

        return newCorg;
    }

    public static Connected_Org__c getConnectedOrgById(String orgId) {
        Connected_Org__c corg = Connected_Org__c.getInstance(orgId.left(15));
        return corg;
    }

    public static Connected_Org__c updateConnectedOrg(Connected_Org__c corg) {
        return null;
    }

    public static void deleteFakeConnectedOrgs() {
        List<Connected_Org__c> cOrgs = Connected_Org__c.getAll().values();
        List<Connected_Org__c> fakeCOrgs = new List<Connected_Org__c>();
        for (Connected_Org__c corg : cOrgs) {
            if (corg.Name.length() > 18) {
                fakeCOrgs.add(corg);
            }
        }
        DatabaseUtils.getInstance().performDeleteDML(fakeCOrgs, Schema.SObjectType.Connected_Org__c)
                .handleError(ConnectedOrgService.class.getName(), '.deleteFakeConnectedOrgs');
    }

    public static Connected_Org__c generateTokenForConnectedOrg(String codeFromOAuth, Object stateFromOAuth, String redirectUrl) {

        StateDTO state;
        try {
            state = (StateDTO)JSON.deserialize(JSON.serialize(stateFromOAuth), StateDTO.class);
        } catch (Exception e) {
            throw new ConnectedOrgServiceException(ConfigUtil.INVALID_OAUTH_STATE_MESSAGE + state);
        }

        Connected_Org__c corg = Connected_Org__c.getInstance(state.code);
        if (corg == null) {
            throw new ConnectedOrgServiceException(ConfigUtil.CONNECTED_ORG_NOT_FOUND_MESSAGE +  state.code);
        }

        String endpoint = (state.loginUrl.endsWith('/') ? state.loginUrl.removeEnd('/') : state.loginUrl) + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT;
        HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
        bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, HttpUtils.HTTP_URL_PARAM_AUTHORIZATION_CODE);
        bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_CODE, codeFromOAuth);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REDIRECT_URI, redirectUrl);
        String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                ConfigUtil.OAUTH_HEADERS_MAP,
                200
        );

        AuthTokenResponse resp = (AuthTokenResponse)JSON.deserialize(b, AuthTokenResponse.class);

        String organizationId = resp.id.split('/')[4];
        String organizationId15 = organizationId.left(15);
        Connected_Org__c corgExisting = getConnectedOrgById(organizationId15);
        if (corgExisting != null && corgExisting.Source__c != SOURCE_QUICK_START && corg.Source__c == SOURCE_QUICK_START) {
            throw new ConnectedOrgServiceException('Org with ID ' + organizationId + ' already exists');
        } else {
            // allow upsert QuickStart settings
            String accessToken = ConfigUtil.CONNECTED_ORGS_SETTINGS.Use_Oauth_for_Self_Org__c && organizationId15 == UserInfo.getOrganizationId().left(15) ? resp.access_token : null;
            createRemoteSiteSettingInstance(organizationId15, resp.instance_url, corg.Title__c, accessToken);
            if ((corgExisting != null && corgExisting.Source__c == SOURCE_QUICK_START) || (corg != null && corg.Source__c == SOURCE_QUICK_START)) {
                PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Id, null);
            }
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Name, organizationId15);
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Access_Token__c, resp.access_token);
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Refresh_Token__c, resp.refresh_token);
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Private_Key__c, generatePrivateKey(corg));
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Instance_Url__c, resp.instance_url);
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Identity_Url__c, resp.id);
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Token_Refreshed_At__c, Datetime.now());
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Is_Sandbox__c, isSandbox(corg));
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Connection_Valid__c, true);

            putEncryptedTokenToCache(corg);
            if (corg != null || (corgExisting != null && corgExisting.Source__c == SOURCE_QUICK_START)) {
                DatabaseUtils.getInstance().performUpsertDML(new List<Connected_Org__c>{corg}, Schema.SObjectType.Connected_Org__c)
                        .handleError(ConnectedOrgService.class.getName(), '.generateTokenForConnectedOrg');
            }
        }
        return corg;
    }

    public static void createRemoteSiteSettingInstance(String organizationId15, String instanceUrl, String title, String accessToken) {
        MetadataService.RemoteSiteSetting rssInstance;
        try {
            rssInstance = AdminService.createRemoteSiteSettingInstance(
                    AdminService.CONNECTED_ORG_REMOTE_SITE_SETTINGS_NAME + organizationId15,
                    instanceUrl,
                    'Pharos.ai login URL for connected org ' + title + ' (' + organizationId15 + ')'
            );
            AdminService.upsertRemoteSiteSettingsMetadata(rssInstance, accessToken);
        }
        catch (Exception e) {
            throw new ConnectedOrgServiceException('RemoteSiteSetting creation error: ' + e.getMessage());
        }
    }

    public static Boolean isSandbox(Connected_Org__c corg) {
        String query = new QBuilder(Organization.SObjectType)
            .selectFields(new Set<String>{Schema.SObjectType.Organization.fields.IsSandbox.getName()})
            .addLimit(1)
            .build();
        List<Organization> objectList;
        try {
            objectList = (List<Organization>)JSON.deserialize(JSON.serialize(LogPostProcessingService.runQuery(corg, query)), List<Organization>.class);
        }
        catch (Exception e) {
            Logger.getInstance().internalError(e, corg.Name, true, ConnectedOrgService.class.getName(), 'isSandbox');
        }
        return objectList != null && !objectList.isEmpty() && objectList.get(0).IsSandbox;
    }

    public static Connected_Org__c refreshToken(String orgId) {
        Connected_Org__c corg = getConnectedOrgById(orgId);

        if (corg == null) {
            throw new ConnectedOrgServiceException(ConfigUtil.getConnectedOrgNotSetError(orgId));
        }
        return refreshToken(corg);
    }

    public static Connected_Org__c refreshToken(Connected_Org__c corg) {

        if (isSelfConnectedOrg(corg) && String.isBlank(corg.Access_Token__c)) return corg;

        /** IMPORTANT This method doesn't update Connected Org in DB to prevent "You have uncommitted work pending." issue
         *  Please do unpdate manualy after this method
        */

        String endpoint = corg.Instance_Url__c + ConfigUtil.SF_OAUTH_TOKEN_ENDPOINT;
        HttpUtils.HttpURLParameters bodyParams = new HttpUtils.HttpURLParameters();
        bodyParams.addParameter(HttpUtils.HTTP_URL_PARAM_GRANT_TYPE, HttpUtils.HTTP_URL_PARAM_REFRESH_TOKEN);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_REFRESH_TOKEN, corg.Refresh_Token__c);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_ID, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Key__c);
        bodyParams.addEncodedParameter(HttpUtils.HTTP_URL_PARAM_CLIENT_SECRET, ConfigUtil.CONNECTED_ORGS_SETTINGS.Client_Secret__c);
        String b = HttpUtils.post(
                endpoint,
                bodyParams.toStringParameters(),
                ConfigUtil.OAUTH_HEADERS_MAP,
                200
        );

        AuthTokenResponse resp = (AuthTokenResponse)JSON.deserialize(b, AuthTokenResponse.class);

        PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Access_Token__c, resp.access_token);
        PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Token_Refreshed_At__c, Datetime.now());
        PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Connection_Valid__c, true);
        if (String.isBlank(corg.Private_Key__c)) {
            PermissionsUtil.putSObjectField(corg, Schema.SObjectType.Connected_Org__c.fields.Private_Key__c, generatePrivateKey(corg));
        }
        putEncryptedTokenToCache(corg);

        // upsert corg;
        // NOTE: Return unsaved Connected_Org__c to save it latter due to "You have uncommitted work pending."

        return corg;

    }

    public static String generatePrivateKey(Connected_Org__c corg) {
        return EncodingUtil.base64Encode(Crypto.generateDigest('SHA3-256', Blob.valueOf(String.valueOf(corg.Id) + String.valueOf(System.now().getTime()) + String.valueOf(ConfigUtil.generateUUID4()))));
    }

    public static void putEncryptedTokenToCache(Connected_Org__c corg) {
        try {
            if (String.isNotBlank(corg.Access_Token__c)) {
                String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_TOKEN, corg.Name, String.valueOf(corg.Token_Refreshed_At__c.getTime()));
                Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_TOKEN, keyCache);
                if (isCacheAvailableForKey) {
                    Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(corg.Private_Key__c), Blob.valueOf(corg.Access_Token__c));
                    CacheUtils.putCacheValue(keyCache, encryptedToken, CacheUtils.getTTLValue(CacheUtils.KEY_REQUEST_ENCRYPTED_TOKEN));
                }
            }
        } catch (Exception e) {
            Logger.getInstance().internalError(e, corg.Name, true, ConnectedOrgService.class.getName(), 'encryptToken');
        }
    }
    public static String getDecryptedTokenFromCache(Connected_Org__c corg) {
        return getDecryptedTokenFromCache(corg, null);
    }

    public static String getDecryptedTokenFromCache(Connected_Org__c corg, Logger logger) {
        try {
            String keyCache = CacheUtils.buildCacheKey(CacheUtils.KEY_REQUEST_ENCRYPTED_TOKEN, corg.Name, String.valueOf(corg.Token_Refreshed_At__c.getTime()));
            Boolean isCacheAvailableForKey = CacheUtils.isCacheAvailableForKey(CacheUtils.KEY_REQUEST_ENCRYPTED_TOKEN, keyCache);
            if (isCacheAvailableForKey) {
                Object cacheObject = CacheUtils.getCacheValue(keyCache);
                if (cacheObject != null) {
                    Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(corg.Private_Key__c), (Blob)cacheObject);
                    return decryptedToken.toString();
                }
            }
        }
        catch (Exception e) {
            logger?.add(logger.getInternalError(e, corg.Name, ConnectedOrgService.class.getName(), 'decryptToken'));
        }
        return corg.Access_Token__c;
    }

    public static Boolean testConnection(String orgId) {
        try {
            getIdentity(orgId);
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    public static Object getIdentity(String orgId) {

        Connected_Org__c corg = getConnectedOrgById(orgId);

        if (corg == null) {
            throw new ConnectedOrgServiceException(ConfigUtil.getConnectedOrgNotSetError(orgId));
        }

        String b = HttpUtils.get(
            corg.Identity_Url__c,
            ConfigUtil.getSFRestAPIHeaders(ConnectedOrgService.getConnectedOrgAccessToken(corg)),
            200
        );

        IdentityDTO identity = (IdentityDTO)JSON.deserialize(b, IdentityDTO.class);
        return identity;
    }

    public class IdentityDTO {
        public String id;
        public String user_id;
        public String organization_id;
        public String username;
        public String nick_name;
        public String display_name;
        public String email;
        public String first_name;
        public String last_name;
        public String timezone;
        public Boolean active;
        public String user_type;
        public String language;
        public String locale;
    }

    public class StateDTO {
        public String code;
        public String loginUrl;
        public String redirectUrl;
    }

    public class AuthTokenResponse {
        public String access_token;
        public String refresh_token;
        public String signature;
        public String scope;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public AuthTokenResponse(){}
    }

    public class ConnectedOrgServiceException extends Exception {}

}