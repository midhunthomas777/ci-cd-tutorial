/*******************************************************************************
* Description : Handler class for ContentVersionTrigger
* Date : 26th March 2020
* Jira             Date             Author       Changes
* 2.0              22/10/2020       Alok Dora    Removed the Case if condition so that can be used across all objects.
* LUCXBW-767       27/11/2020       Bona         Added the method for deleting the attachments, if the attachment type is not from the allowed custom settings
* LUCXBW-783       21/01/2021       Anusuya      There was a typo on the message:'Case created without attachment, as the attachment type does not meet the predefined attachment types'
************************************************************************************/
public class ContentVersionTriggerHandlerMSI implements ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        TriggerSettings__c ts = TriggerSettings__c.getValues('ContentVersionTriggerMSI');
        if (ts != null && ts.IsActive__c == true){
            return true;
        }
        else{
            return TriggerDisabled;
        }
    }

    public void beforeInsert(List<SObject> newItems){
        validateFile(newItems,null);
    }    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        validateFile(newItems.values(),oldItems);
    }    
    
    public void afterInsert(Map<Id, SObject> newItems) {
        //LUCXBW-579 - When a new file is uploaded or updated a Platform Event will be fired.
        //check if not integration user to avoid recursion
        if(userInfo.getUserId() != System.label.IntegrationUserId)
        {
            System.debug('#Checkpoint Insert');
            RemedyIntegrationService.publishPlatformEvent(newItems,null,trigger.isUpdate);
        }
        // LUCXBW-767 - For deleting the attached files from email source, if the attachment type not in the custom setting list- "FileUploadExtAllowed"
        deleteAttachedFiles((List<ContentVersion>)newItems.values());
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        //check if not integration user to avoid recursion
        if(userInfo.getUserId() != System.label.IntegrationUserId)
        {
            System.debug('#Checkpoint Update');
            RemedyIntegrationService.publishPlatformEvent(newItems,oldItems,trigger.isUpdate);
        } 
        // LUCXBW-767 - For deleting the attached files from email source, if the attachment type not in the custom setting list-"FileUploadExtAllowed"
        deleteAttachedFiles((List<ContentVersion>)newItems.values());
    }
    public void beforeDelete(Map<Id, SObject> oldItems){} 
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
    
    /*
** Method Name : validateFile
** CreatedDate : 05/03/2020(MM/DD/YYYY)
** Param       : Map<Id, SObject>,Map<Id, SObject>
** Description : V 1.0 - LUCXBW-656 : Check whether file uploaded is according to the extension in the custom setting"FileUploadExtAllowed".
*/ 
    public void validateFile(List<SObject> newItems, Map<Id, SObject> oldItems){
        /****Fetching allowed extension type from Custom Setting****/
        Map<String,FileUploadExtAllowed__c> extensionSet = new Map<String,FileUploadExtAllowed__c>(FileUploadExtAllowed__c.getall());
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> contentDocumentIdValidateSet = new Set<Id>();
        String fileExtension = '';
        Map<Id,Id> contentVersionIdVsContentDocumentIdMap = new Map<Id,Id>(); 
        System.debug('********Before Insert Checkpoint********');
        For(ContentVersion contentVerRec : (List<ContentVersion>)newItems){
            if(contentVerRec.FirstPublishLocationId!=null){ 
                // LUCXBW-767 - skipping the validation for EmailMessage object
                if(!String.valueOf(contentVerRec.FirstPublishLocationId).startswith('02s')){
                    contentDocumentIdValidateSet.add(contentVerRec.ContentDocumentId);
                }
            }
            else{
                contentDocumentIdSet.add(contentVerRec.ContentDocumentId);
            }
        }
        System.debug('********Before Insert Checkpoint 2********'+contentDocumentIdSet);
        /**Query to fetch the parent of the file in case of new file upload**/
        if(!contentDocumentIdSet.isEmpty()){
            For(ContentVersion contentVerRec : [SELECT ContentDocumentId,FirstPublishLocationId,Title 
                                                FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentIdSet AND VersionNumber = '1' AND FirstPublishLocationId != null])
            {
                // LUCXBW-767 - skipping the validation for EmailMessage object
                if(!String.valueOf(contentVerRec.FirstPublishLocationId).startswith('02s')){
                    contentDocumentIdValidateSet.add(contentVerRec.ContentDocumentId);
                }
            }
        }
        if(!contentDocumentIdValidateSet.isEmpty()){
            For(ContentVersion contentVerRec : (List<ContentVersion>)newItems){
                if(contentDocumentIdValidateSet.contains(contentVerRec.ContentDocumentId)){
                    fileExtension = contentVerRec.PathOnClient.substringAfterLast('.');//Extension of the file uploaded..
                    if(String.isNotBlank(fileExtension) && !extensionSet.isEmpty() && !extensionSet.keySet().contains(fileExtension.toLowerCase())){
                        contentVerRec.addError('Cannot upload '+ contentVerRec.PathOnClient);//Error message if the uploaded extension is not found in the custom setting
                    }
                }
            }
        }
    }
/*
** Method Name : LUCXBW-767
** CreatedDate : 11/27/2020(MM/DD/YYYY)
** Param       : List<ContentVersion>
** Description : V 1.0 - LUCXBW-767 : Delete the  file, if the uploaded file type is not from the custom setting "FileUploadExtAllowed".
*/
    public void deleteAttachedFiles(List<ContentVersion> newItems){
        List <ContentDocument> lstFilesToDelete = new List <ContentDocument>();
        Map<String,FileUploadExtAllowed__c> extensionSet = new Map<String,FileUploadExtAllowed__c>(FileUploadExtAllowed__c.getall());
        string fileExtension;
        list<Id> lstContentDocumentIds = new list<Id>();
        For(ContentVersion objCntVersion : newItems){
            fileExtension = objCntVersion.PathOnClient.substringAfterLast('.');//Extension of the file uploaded..
            if(String.isNotBlank(fileExtension) && !extensionSet.isEmpty() && !extensionSet.keySet().contains(fileExtension.toLowerCase())){
                lstContentDocumentIds.add(objCntVersion.ContentDocumentId);
                lstFilesToDelete.add(new ContentDocument(Id = objCntVersion.ContentDocumentId));
            }
        }
        if(lstContentDocumentIds.size() > 0){
            map<Id,String> mapMsgIdFileName = new map<Id,String>();
            string strAttachmentNames = '';
            // get  the linkedentityId from ContentDocumentLink
            for(ContentDocumentLink objCntDocLink:[SELECT id, ContentDocument.Title, ContentDocument.FileExtension, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :lstContentDocumentIds]){                           
                if(String.valueOf(objCntDocLink.LinkedEntityId).startswith('02s')){
                    if(mapMsgIdFileName.containskey(objCntDocLink.LinkedEntityId)){
                        strAttachmentNames =mapMsgIdFileName.get(objCntDocLink.LinkedEntityId)+', '+objCntDocLink.ContentDocument.Title+'.'+objCntDocLink.ContentDocument.FileExtension;
                    }else{
                         strAttachmentNames =objCntDocLink.ContentDocument.Title+'.'+objCntDocLink.ContentDocument.FileExtension;
                    }
                    mapMsgIdFileName.put(objCntDocLink.LinkedEntityId,strAttachmentNames);
                    
                  }
            }
            if(mapMsgIdFileName.keyset().size() > 0){
                //From the email message ID get the case Id
                map<Id,emailmessage> mapEmailMessages = new map<Id,EmailMessage>([SELECT id,parentId FROM emailMessage where Id IN:mapMsgIdFileName.keyset()]);
                list<FeedItem> lstFeeds = new list<FeedItem>();
                for(Id msgId:mapMsgIdFileName.keyset()){
                    FeedItem post = new FeedItem();
                    post.ParentId = mapEmailMessages.get(msgId).parentId;
                    post.Body = 'Case created without attachment, as the attachment type does not meet the predefined attachment types:'+mapMsgIdFileName.get(msgId);
                    lstFeeds.add(post);
                }
                if(lstFeeds.size() > 0){
                    INSERT lstFeeds;
                }
            }           
        }        
        if (lstFilesToDelete.size() > 0 ){
            DELETE lstFilesToDelete;
        }
    }
}