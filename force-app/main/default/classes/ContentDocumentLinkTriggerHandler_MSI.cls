/*******************************************************************************
* Description : Handler class for ContentDocumentLinkTrigger_MSI
* Date : 5th June 2020
******************************************************************************/

public class ContentDocumentLinkTriggerHandler_MSI implements ITriggerHandler {
    
    public Boolean isDisabled(){        
        return TriggerSettings__c.getValues('ContentDocumentLinkTrigger_MSI').IsActive__c;
    }
    
    public void beforeInsert(List<SObject> newItems){}    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}    
    
    public void afterInsert(Map<Id, SObject> newItems) {
        //LUCXBW-579 - When a new file is uploaded or updated a Platform Event will be fired.
        //check if not integration user to avoid recursion
        if(userInfo.getUserId() != System.label.IntegrationUserId)
        {
            System.debug('#Checkpoint Insert');
            RemedyIntegrationService.publishContentDocumentLinkPE(newItems);
        }
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void beforeDelete(Map<Id, SObject> oldItems){} 
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
}