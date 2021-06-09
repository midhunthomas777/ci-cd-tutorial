/*
* Name : BRRAccountTriggerHandler
* Description: This class is for implementing Lock Down feature for BRR
* Author : Adilraza Shaikh
* Date : 12/07/2020
*/
public class BRRAccountTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('BRRAccountTriggerDisabled').IsActive__c){
            return true;
        }
        else{
            return TriggerDisabled;
        }
    }
    public void BeforeInsert(List<SObject> newItems) {
        //List<BRR_Opportunity__c> newBRROppList = new List<BRR_Opportunity__c>();
        //if(newItems != null) newBRROppList = (List<BRR_Opportunity__c>) newItems;
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,BRR_Account__c> oldBRRAccMap = new Map<Id,BRR_Account__c>();
        Map<Id,BRR_Account__c> newBRRAccMap = new Map<Id,BRR_Account__c>();
        if(oldItems != null) oldBRRAccMap = (Map<Id,BRR_Account__c>) oldItems;
        if(newItems != null) newBRRAccMap = (Map<Id,BRR_Account__c>) newItems;
        if(!newBRRAccMap.isEmpty()){
            evaluateLockDown(newBRRAccMap);
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        Map<Id,BRR_Account__c> oldBRRAccMap = new Map<Id,BRR_Account__c>();
        if(oldItems != null) oldBRRAccMap = (Map<Id,BRR_Account__c>) oldItems;
        if(!oldBRRAccMap.isEmpty()){
            evaluateLockDown(oldBRRAccMap);
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
        //Map<Id,BRR_Opportunity__c> newBRROppMap = new Map<Id,BRR_Opportunity__c>();
        //if(newItems != null) newBRROppMap = (Map<Id,BRR_Opportunity__c>) newItems;
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        //Map<Id,BRR_Opportunity__c> oldBRROppMap = new Map<Id,BRR_Opportunity__c>();
        //Map<Id,BRR_Opportunity__c> newBRROppMap = new Map<Id,BRR_Opportunity__c>();
        //if(oldItems != null) oldBRROppMap = (Map<Id,BRR_Opportunity__c>) oldItems;
        //if(newItems != null) newBRROppMap = (Map<Id,BRR_Opportunity__c>) newItems;
        
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    public void evaluateLockDown(Map<Id,BRR_Account__c> BRRAccMap){
       	Map<Id,String> accOwnerTerritoryMap = new Map<Id,String>();        
        Set<Id> subroles = new Set<Id>();
        Set<Id> brrId = new Set<Id>();
        Set<Id> accOwnerRole = new Set<Id>();
        for(BRR_Account__c BRRAcc : BRRAccMap.values()) {
			//system.debug('newBRRAcc OWNER'+newBRRAcc.Account_Owner__c);
            accOwnerTerritoryMap.put(BRRAcc.Account_Owner__c, BRRAcc.Account_Territory__c);            
            brrId.add(BRRAcc.Briefing_Room_Report__c);
        }
        if(!accOwnerTerritoryMap.isEmpty()){
            for(User usr : [SELECT Id,userRoleId FROM User WHERE Id IN : accOwnerTerritoryMap.keyset() AND isActive = TRUE]){
                accOwnerRole.add(usr.userRoleId);
            }
        } 
        if(!accOwnerRole.isEmpty()){
            subroles = GlobalUtility.getAllSubRoleIds(accOwnerRole); //subRoles of OpportunityOwner
            subroles.addALL(accOwnerRole); // acc owner role
        }                
        //Map<String,Integer> mapRegionLockDownDay = BRRUtility.getLockdownDayByRegion(accOwnerRegionMap.values());
        if(!subroles.isEmpty() && subroles.contains(userinfo.getUserRoleId())){
            Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta = BRRUtility.getLockdownDayByTerritory(accOwnerTerritoryMap.values());
            Map<Id,Briefing_Room_Report__c> mapBRRWeek = BRRUtility.getBRR(brrId);  
            for(BRR_Account__c BRRAcc : BRRAccMap.values()) {
                Boolean isOutsideLockingPeriod = BRRUtility.isOutsideLockingPeriod(mapTerritoryBRRMeta,BRRAcc.Account_Territory__c);
                if(mapBRRWeek.get(BRRAcc.Briefing_Room_Report__c).This_Week_BRR__c == True){
                    if(isOutsideLockingPeriod){
                        BRRAcc.addError(system.label.BRR_Lock_Down);
                    }
                }else if(mapBRRWeek.get(BRRAcc.Briefing_Room_Report__c).Past_Week__c == True){
                    BRRAcc.addError(system.label.BRR_Lock_Down);
                }
            }
        }
    }
}