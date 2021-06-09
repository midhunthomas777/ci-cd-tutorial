/****************************************************************
* Class Name : AgreementTriggerHandler
* Description : This class used in Agreement trigger
* Author : Vineela N
* Date : 17 sep 2018
****************************************************************/ 
public class AgreementTriggerHandler implements ITriggerHandler {
    Id agreeSalesRecTypeId = GlobalUtility.recordTypeId('Apttus__APTS_Agreement__c','Sales');
    public static Boolean TriggerDisabled = false;
    //BeforeInsert event
    public void BeforeInsert(List<SObject> newItems) {  
    }
    //BeforeUpdate event
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
    }
    //BeforeDelete event
    public void BeforeDelete(Map<Id, SObject> oldItems) {  
        
    }
    //After Insert
    public void afterInsert(Map<Id, SObject> newItems) {
        List<Apttus__APTS_Agreement__c> agreementlist = (List<Apttus__APTS_Agreement__c>)newItems.values();
        Set<Id> agreementIds = new Set<Id>();
        Set<Id> psrrIds = new Set<Id>();
        List<Apttus__APTS_Agreement__c> naAgreeList = new List<Apttus__APTS_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agreement : agreementlist)  {
            if(agreement.recordtypeId == agreeSalesRecTypeId && agreement.m_GTM_Region__c == 'North America') {
                agreementIds.add(agreement.Id);
                psrrIds.add(agreement.Related_Presales_Resource_Request__c);
                naAgreeList.add(agreement);
            }
        }
        
        if(!naAgreeList.isEmpty()){
            validateAutoApproval(naAgreeList);
        }
        
        if(!agreementIds.isEmpty()) {
            AgreementHelper.agreeAccessforoppty(agreementIds); //calling the Agreement sharing class if Map is not empty
        }
        
        
    }
    //ended by Vineela as a part of SF-115
    //After Update
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
       
    }
    
    //after Delete
    public void afterDelete(Map<Id, SObject> oldItems) {
        
    }
    //After Undelete
    public void afterUndelete(Map<Id, SObject> oldItems) {
        
    }
    
    public Boolean isDisabled(){
        if(TriggerSettings__c.getValues('AgreementTriggerDisabled').IsActive__c) {
            return true;
        } else{
            return TriggerDisabled;
        }
    }
    
    public void validateAutoApproval(List<Apttus__APTS_Agreement__c> naAgreeList) {
        System.debug('ENTERED AUTO APPROVAL##=>'+json.serializePretty(naAgreeList));
        List<Apttus__APTS_Agreement__c> toBeUpdated = new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c incoming : [SELECT Id,Agreement_Type__c,m_State_and_Local_Territory__c,
                                                  Auto_Approval__c,Project_Type__c,Apttus__Total_Contract_Value__c,
                                                  Mature_Products__c,Motorola_Entity_Account__c,Apttus__Account__c,
                                                  Proposal_Due_Date__c,m_Responsible_Attorney__c,Finance_Approver_c__c
                                                  FROM Apttus__APTS_Agreement__c
                                                 WHERE ID IN : naAgreeList] ) {
            if( (incoming.Agreement_Type__c !='RFI/Non-binding proposal' || 
                incoming.Agreement_Type__c !='RFP/Non-binding proposal' || 
                incoming.Agreement_Type__c !='Unsolicited, non-binding proposal' || 
                incoming.Agreement_Type__c !='Trial or Evaluation Agreement')
               && incoming.Auto_Approval__c == False 
               && incoming.m_State_and_Local_Territory__c != null 
               && (incoming.Project_Type__c== 'Sole-Source'||incoming.Project_Type__c == 'Sole Source')
               && incoming.Apttus__Total_Contract_Value__c <= 10000000 
               && incoming.Mature_Products__c== True 
               && incoming.Motorola_Entity_Account__c != null 
               && incoming.Apttus__Account__c!= null 
               && incoming.Proposal_Due_Date__c!= null 
               && incoming.m_Responsible_Attorney__c != null 
               && incoming.Finance_Approver_c__c != null
              ) {
                  if(!Test.isrunningTest()) {
                      System.debug('Entered Method to submit for Auto Approval');
                      PreSalesController.autoApproval(UserInfo.getSessionID(),incoming.Id);  
                   }
                  incoming.Auto_Approval__c = TRUE; 
                  toBeUpdated.add(incoming);
                   }
              }
        
        
        if(!toBeUpdated.isEmpty()){
            update toBeUpdated;
        }
    }
   
}