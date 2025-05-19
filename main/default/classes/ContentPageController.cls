public class ContentPageController {

    public String getJsonData() {
        String contentDocumentId = (String)ApexPages.currentPage().getParameters().get('contentDocumentId');
        List<ContentVersion> lstContentVersions = [SELECT Id, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId AND IsLatest = TRUE];
        if (!lstContentVersions.isEmpty()) {
          return JSON.serialize(new Map<String, Blob>{lstContentVersions[0].FileExtension => lstContentVersions[0].VersionData});
        }
        return '';
    }
}