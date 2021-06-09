/*
* Name : AttachmentTriggerHandler
* Description: Handler class of attachment Trigger, used to set content type if it is missing
* Author : Adilraza Shaikh
* Date : 6/17/2020
*/
public class AttachmentTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        TriggerSettings__c ts = TriggerSettings__c.getValues('AttachmentTriggerDisabled');
        if (ts != null && ts.IsActive__c == true){
            return true;
        }
        else{
            return TriggerDisabled;
        }
    }
    public void BeforeInsert(List<SObject> newItems) {
        List<Attachment> newAttachmentList = new List<Attachment>();
        if(newItems != null) newAttachmentList = (List<Attachment>) newItems;
        Map<String,MIME_Type__mdt> mapMimeType = new Map<String,MIME_Type__mdt>();
        for(MIME_Type__mdt mime : [SELECT MasterLabel, DeveloperName, Value__c FROM MIME_Type__mdt]){
            mapMimeType.put(mime.DeveloperName, mime);
        } 
        for(Attachment att : newAttachmentList){
            if(att.contentType == NULL && GlobalUtility.getSObjectNameById(att.parentId) == 'BigMachines__Quote__c'){
                if(String.isNotBlank(att.Name)){
                    String extension = getFileExtensionByFileName(att.Name);
                    if( String.isNotBlank(extension) && mapMimeType.containsKey(extension) ){
                        att.contentType = mapMimeType.get(extension).value__c;
                    }
                }
            }
        }
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {
       
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
        
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public static String getFileExtensionByFileName(String fileName){
        String extension;
        Integer extensionIndex = fileName.lastIndexOf('.');
        if (extensionIndex > 0) {
            extension = fileName.substring(extensionIndex+1);
        }
        return extension;
    }
}