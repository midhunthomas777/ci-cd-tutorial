public class PartnershipRecordTriggerHandler implements ITriggerHandler { 

    public static Boolean isTriggerDisabled = false;

    public void BeforeInsert(List<Partnership_Record__c> newItems){
        DTSFPART_PartnershipRecordTriggerHelper.setPartnershipRecordAccountBasedOnPartnerEmpowerId(newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}

    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    public Boolean IsDisabled(){
        return isTriggerDisabled || new DTSFPART_TriggerConfigurationService('PartnershipRecordTrigger', 'PartnershipRecordTriggerHandler').isTriggerLogicDisabled();
    }
}