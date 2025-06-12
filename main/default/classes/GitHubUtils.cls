public with sharing class GitHubUtils {

    public static final String GIT_API_AUTHORIZE_ENDPOINT = 'https://github.com/login/oauth/authorize';
    public static final String GIT_API_TOKEN_ENDPOINT = 'https://github.com/login/oauth/access_token';
    public static final String GIT_API_SETTINGS_NAME = 'GitHubAPI';
    public static final Integer METADATA_API_VERSION = 51;
    public static final String GIT_API_DEFAULT_BASE_BRANCH_REF = ConfigUtil.GIT_API_SETTINGS.Branch_Name__c; //'main',''master;
    public static final String AWS_GIT_SERVICE_ENDPOINT = 'https://sfdx.pharos.ai/sfdxcli/sfdxcli?';

    public static String GIT_USERNAME {
        get {
            if(GIT_USERNAME == null) {
                GIT_USERNAME = ConfigUtil.GIT_API_SETTINGS.Username__c;
            }
            return GIT_USERNAME;
        }
        set;
    }
    public static String GIT_REPONAME {
        get {
            if(GIT_REPONAME == null) {
                GIT_REPONAME = ConfigUtil.GIT_API_SETTINGS.Reponame__c;
            }
            return GIT_REPONAME;
        }
        set;
    }
    public static String GIT_TOKEN {
        get {
            if(GIT_TOKEN == null) {
                GIT_TOKEN = (String.isBlank(ConfigUtil.GIT_API_SETTINGS.Token__c))
                    ? 'token ' + ConfigUtil.GIT_API_SETTINGS.oAuth_Token__c
                    : 'token ' + ConfigUtil.GIT_API_SETTINGS.Token__c;
            }
            return GIT_TOKEN;
        }
        set;
    }
    public static String GIT_API_USER_INFO = 'https://api.github.com/user';
    public static String GIT_API_REPOS_INFO = 'https://api.github.com/user/repos?per_page=100';
    public static String GIT_API_GET_REPOS_INFO = 'https://api.github.com/repos/{0}/{1}';
    public static String GIT_API_REPO_BRANCHES_INFO = 'https://api.github.com/repos/{0}/{1}/branches?per_page=100';
    public static String GIT_API_GET_REPO_BRANCHES_INFO = 'https://api.github.com/repos/{0}/{1}/branches/{2}';
    public static final String GIT_API_V3_JSON_HEADER = 'application/vnd.github.v3+json';

    public static Boolean validateGitHubConnection() {
        List<GitRepoBranchInfo> branches = getRepoBranchesInfos(ConfigUtil.GIT_API_SETTINGS.Reponame__c);
        for(GitRepoBranchInfo branch : branches) {
            if(branch.name == ConfigUtil.GIT_API_SETTINGS.Branch_Name__c) {
                return true;
            }
        }
        return false;
    }

    public static Boolean validateGitHubConnectionForChat() {
        if (String.isBlank(GIT_USERNAME) || String.isBlank(GIT_REPONAME) || String.isBlank(ConfigUtil.GIT_API_SETTINGS.Branch_Name__c)) {
            return false;
        }

        List<GitRepoBranchInfo> branches = getRepoBranchesInfos(
            GIT_USERNAME,
            GIT_REPONAME,
            ConfigUtil.GIT_API_SETTINGS.Branch_Name__c
        );
        for(GitRepoBranchInfo branch : branches) {
            if(branch.name == ConfigUtil.GIT_API_SETTINGS.Branch_Name__c) {
                return true;
            }
        }
        return false;
    }

    public static List<GitRepoBranchInfo> getRepoBranchesInfos(Object data) {
        String owner;
        String reponame;
        String branchname;

        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        owner = input.get('owner') != null ? String.valueOf(input.get('owner')) : GIT_USERNAME;
        reponame = input.get('reponame') != null ? String.valueOf(input.get('reponame')) : reponame;
        branchname = input.get('branchname') != null ? String.valueOf(input.get('branchname')) : branchname;

        return getRepoBranchesInfos(owner, reponame, branchname);
    }

    public static List<GitRepoBranchInfo> getRepoBranchesInfos(String owner, String reponame, String branchname) {
        List<GitRepoBranchInfo> result = new List<GitRepoBranchInfo>();
        String endpoint = (String.isBlank(branchName))
            ? String.format(GIT_API_REPO_BRANCHES_INFO, new List<String>{owner, reponame})
            : String.format(GIT_API_GET_REPO_BRANCHES_INFO, new List<String>{owner, reponame, branchname});
        String b = HttpUtils.get(
            endpoint,
            GitHubUtils.getGitApiHeaders(),
            200
        );
        List<GitRepoBranchInfo> response = String.isBlank(branchname)
            ? (List<GitRepoBranchInfo>)JSON.deserialize(b, List<GitRepoBranchInfo>.class)
            : new List<GitRepoBranchInfo>{((GitRepoBranchInfo)JSON.deserialize(b, GitRepoBranchInfo.class))};
        for(GitRepoBranchInfo branchInfo : response) {
            if(!branchInfo.name.startsWithIgnoreCase('OrgMetadataDump')) {
                result.add(branchInfo);
            }
        }
        return result;
    }

    public class GitRepoBranchInfo {
        public String name;
    }

    public static List<GitReposInfo> getReposInfos(Object data) {
        String reponame;
        Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(data));
        reponame = input.get('reponame') != null ? String.valueOf(input.get('reponame')) : reponame;
        return getReposInfos(GIT_USERNAME, reponame);
    }

    public static List<GitReposInfo> getReposInfos(String owner, String reponame) {
        List<GitReposInfo> result = new List<GitReposInfo>();

        String endpoint = (String.isBlank(reponame))
            ? GIT_API_REPOS_INFO
            : String.format(GIT_API_GET_REPOS_INFO, new List<String>{owner, reponame});
        String b = HttpUtils.get(
            endpoint,
            GitHubUtils.getGitApiHeaders(),
            200
        );
        List<GitReposInfo> response = String.isBlank(reponame)
            ? (List<GitReposInfo>)JSON.deserialize(b, List<GitReposInfo>.class)
            : new List<GitReposInfo>{((GitReposInfo)JSON.deserialize(b, GitReposInfo.class))};
        for(GitReposInfo r : response) {
            if(!r.archived && !r.disabled) {
                result.add(r);
            }
        }
        return result;
    }

    public class GitReposInfo {
        public String name;
        public Boolean archived;
        public Boolean disabled;
        public GitRepoOwnerInfo owner;
    }

    public class GitRepoOwnerInfo {
        public String login;
        public String type;
    }

    public static GitUserInfo getGitUserInfo() {
        return getGitUserInfo(GIT_TOKEN);
    }
    public static GitUserInfo getGitUserInfo(String token) {
        String b = HttpUtils.get(
            GIT_API_USER_INFO,
            GitHubUtils.getGitApiHeaders(token),
            200
        );
        GitUserInfo response = (GitUserInfo)JSON.deserialize(b, GitUserInfo.class);
        return response;
    }

    public class GitUserInfo {
        public String login;
        public String company;
    }

    public static Map<String, String> authHeaders() {
        Map<String, String> result = new Map<String, String>();
        AWS_Token__mdt mdtSettings = AWS_Token__mdt.getInstance('AWSToken');
        if(mdtSettings != null) {
            result.put('x-api-key', mdtSettings.Token__c);
        }
        return result;
    }

    public static Map<String, String> getGitApiHeaders() {
        return getGitApiHeaders(GIT_TOKEN);
    }

    public static Map<String, String> getGitApiHeaders(String token) {
        Map<String, String> headers = HttpUtils.getHeadersAuthorization(token);
        headers.putAll(HttpUtils.getHeadersAccept(GIT_API_V3_JSON_HEADER));
        return headers;
    }

    public static MetadataService.MetadataPort getMetadataService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = ConnectedOrgService.getSelfConnectedOrgAccessToken();
        return service;
    }

    public static MetadataService.RetrieveRequest createRetrieveRequest(String metadataType, String[] members) {
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.packageNames = null;
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
        packageType.name = metadataType;
        packageType.members = members;
        retrieveRequest.unpackaged.types.add(packageType);

        return retrieveRequest;
    }

    public static String generatePackageXML(List<GitHubCommitBatch.MetadataTypeWrapper> members) {
        String result = '<?xml version="1.0" encoding="UTF-8"?>\n' + '<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n';
        for(GitHubCommitBatch.MetadataTypeWrapper metaType : members) {
            result += '    <types>\n';
            for(String member : metaType.member) {
                result += '        <members>' + member + '</members>\n';
            }
            result += '        <name>' + metaType.type + '</name>\n' + '    </types>\n';
        }
        result += '    <version>' + String.valueOf(GitHubUtils.METADATA_API_VERSION) + '.0' + '</version>\n' + '</Package>';
        return result;
    }

}