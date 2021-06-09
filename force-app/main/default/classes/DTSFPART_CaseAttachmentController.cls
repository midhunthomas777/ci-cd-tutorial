/**
 * @author		Michał Pycek
 * @created		2020-10-23
 * @description	Manage case files
 */
global with sharing class DTSFPART_CaseAttachmentController {
    @InvocableMethod
    public static List<ContentVersion> saveAttachmentsAsContentVersions(List<Attachment> attachments) {
        List<ContentVersion> files = new List<ContentVersion>();
        Set<Id> fileIds = new Set<Id>();
        for(Attachment att :attachments) {
            ContentVersion contVerFile = new ContentVersion();
            contVerFile.VersionData = att.Body;
            contVerFile.Title = att.Name;
            contVerFile.ContentLocation = 's';
            contVerFile.PathOnClient = att.Name;
            files.add(contVerFile);
        }

        if(files.size() > 0) {
            insert files;
        }

        for(ContentVersion contVerFile :files) {
            fileIds.add(contVerFile.Id);
        }
        
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :fileIds];
    }
}