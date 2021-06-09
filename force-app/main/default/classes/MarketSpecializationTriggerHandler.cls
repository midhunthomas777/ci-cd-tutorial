public class MarketSpecializationTriggerHandler implements ITriggerHandler{
    
    public Boolean IsDisabled(){
        
        return false;
    }
    
    public void BeforeInsert(List<SObject> newItems){}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){
        Map<Id,Market_Specializations__c> newMarSpecMap = new Map<Id,Market_Specializations__c>();
        
        Set<Id> allAccIds = new Set<Id>();
        
        if(newItems != null){
            newMarSpecMap = (Map<Id,Market_Specializations__c>) newItems;  
        } 
        
        for(Market_Specializations__c incomingMS:newMarSpecMap.values()){
            allAccIds.add(incomingMS.Account__c);
        }
        
        if(allAccIds.size()>0){
            ProgramDetailTriggerHandler prgDetailHelper = new ProgramDetailTriggerHandler();
            prgDetailHelper.updateAccPLCommunity(allAccIds);
        }
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){
        Map<Id,Market_Specializations__c> delMarSpecMap = new Map<Id,Market_Specializations__c>();
        
        Set<Id> allAccIds = new Set<Id>();
        
        if(oldItems != null){
            delMarSpecMap = (Map<Id,Market_Specializations__c>) oldItems;  
        } 
        
        for(Market_Specializations__c delMS:delMarSpecMap.values()){
            allAccIds.add(delMS.Account__c);
        }
        
        if(allAccIds.size()>0){
            ProgramDetailTriggerHandler prgDetailHelper = new ProgramDetailTriggerHandler();
            prgDetailHelper.updateAccPLCommunity(allAccIds);
        }
        
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
   
}