/*  
* Class         : EmailMessageTriggerHandler
* Description   : This class is the handler class of EmailMessageTrigger
* @author       : Hemant
*
* Modification Log
* =============================================================================
*   Ver     Date         Author          Modification
*------------------------------------------------------------------------------
*   1.0     15-06-20    Hemant            Initial Creation
*/
public class EmailMessageTriggerHandler implements ITriggerHandler {
    public Boolean isDisabled() {        
        return TriggerSettings__c.getValues('EmailMessageDisabled').IsActive__c;
    }
    public void beforeInsert(List<SObject> newItems) {}
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}    
    public void beforeDelete(Map<Id, SObject> oldItems) {}    
    public void afterInsert(Map<Id, SObject> newItems) {
        updateCaseCCList(newItems.values());
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
    /*
** Method Name : updateCaseCCList
** CreatedDate : 08/07/2020(MM/DD/YYYY)
** Param       : List<sObject>
** Description : V 1.0 - LUCXBW-688 : CC List Process builder redesign to enable Email Draft settings.
*/ 
    public static void updateCaseCCList(List<SObject> newEmailmessage) {
        /**** Initialize variable ****/
        Map<Id,String> caseIdVsCCListMap = new Map<Id,String>();
        List<Case> caseListUpdate = new List<Case>();
        String ccListTemp;
        Set<String> emailTempSet = new Set<String>();
        for(EmailMessage newEmail : (List<EmailMessage>)newEmailmessage) {
            if(newEmail.Incoming && newEmail.CcAddress != null && newEmail.ParentId != null && newEmail.ParentId.getsobjecttype().getDescribe().getName() == 'Case') {
                caseIdVsCCListMap.put(newEmail.ParentId,newEmail.CcAddress);
            }
        }
        System.debug('*******caseIdVsCCListMap***'+caseIdVsCCListMap);
        //Query case and update the CCList...
        if(!caseIdVsCCListMap.isEmpty()) {
            For(Case caseRecord : [SELECT Id,CC_List__c FROM Case WHERE Id IN : caseIdVsCCListMap.keySet()]) {
                ccListTemp = '';
                ccListTemp = caseRecord.CC_List__c!=null?(caseRecord.CC_List__c+';'+caseIdVsCCListMap.get(caseRecord.Id)):caseIdVsCCListMap.get(caseRecord.Id);
                caseRecord.CC_List__c = String.join(new List<String>(new Set<String>(ccListTemp.deletewhitespace().split(';'))),';'); //replaceAll( '\\s+', '')
                caseListUpdate.add(caseRecord);
            }
            System.debug('*******caseListUpdate***'+caseListUpdate);
            //Update case list...
            if(!caseListUpdate.isEmpty()) {
                update caseListUpdate;
            }       
        }
    }
}