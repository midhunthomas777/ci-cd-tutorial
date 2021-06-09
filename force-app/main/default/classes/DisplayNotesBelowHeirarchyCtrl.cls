/*
 * Name : DisplayNotesBelowHeirarchyCtrl
* Description: This is used to display notes on BRR based upon Role heirarchy
* Author : Adilraza Shaikh, Afzal Wasi
* Date : 6/1/2020
*/
public class DisplayNotesBelowHeirarchyCtrl {
    @AuraEnabled
    public static List<contentNote> getNotesForUser(String recId){
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> contentNoteCreatedByRoleId = new Set<Id>();
        Set<id> currentUserRole = new Set<Id>();
        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recId]){
            contentDocumentIds.add(conDoc.ContentDocumentId);
        }
        //system.debug('contentDocumentIds**'+contentDocumentIds);
        currentUserRole.add(UserInfo.getUserRoleId());
        set<Id> subroles = GlobalUtility.getAllSubRoleIds(currentUserRole);
        subroles.add(UserInfo.getUserRoleId());
        //system.debug('subroles**'+subroles);
        List<contentNote>  lstContentNotes = [SELECT Id,Title,TextPreview,LastViewedDate,CreatedBy.Name,LastModifiedBy.Name,
                                              CreatedById,CreatedBy.UserRoleId,OwnerId FROM ContentNote WHERE Id IN: contentDocumentIds
                                              AND CreatedBy.UserRoleId IN: subroles];
        //system.debug('lstContentNotes**'+lstContentNotes);
        return lstContentNotes;
    }
    
}