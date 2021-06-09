public class OpportunitySubAccountTriggerHandler implements ITriggerHandler {
    
    OpportunitySubAccountTriggerHelper helperObj = new OpportunitySubAccountTriggerHelper();
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('OpportunitySubAccountTrigger').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems){
        List<SubAgency__c> newSubAccsList = new List<SubAgency__c>();
        if(newItems != null) newSubAccsList = (List<SubAgency__c>) newItems;
        OpportunitySubAccountTriggerHelper.insertOppSubAgency(newSubAccsList); 
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,SubAgency__c> oldOpptySubAgencyMap = new Map<Id,SubAgency__c>();
        Map<Id,SubAgency__c> newOpptySubAgencyMap = new Map<Id,SubAgency__c>();
        if(oldItems != null) oldOpptySubAgencyMap = (Map<Id,SubAgency__c>) oldItems;
        if(newItems != null) newOpptySubAgencyMap = (Map<Id,SubAgency__c>) newItems;
        OpportunitySubAccountTriggerHelper.updateOppSubAgency(newOpptySubAgencyMap,oldOpptySubAgencyMap);
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterInsert(Map<Id, SObject> newItems){}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}