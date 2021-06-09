/*
* Name : BRROpportunityTriggerHandler
* Description: This class is for implementing Lock Down feature for BRR
* Author : Adilraza Shaikh
* Date : 12/07/2020
*/
public class BRROpportunityTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('BRROpportunityTriggerDisabled').IsActive__c){
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
        Map<Id,BRR_Opportunity__c> oldBRROppMap = new Map<Id,BRR_Opportunity__c>();
        Map<Id,BRR_Opportunity__c> newBRROppMap = new Map<Id,BRR_Opportunity__c>();
        if(oldItems != null) oldBRROppMap = (Map<Id,BRR_Opportunity__c>) oldItems;
        if(newItems != null) newBRROppMap = (Map<Id,BRR_Opportunity__c>) newItems;
        if(!newBRROppMap.isEmpty()){
            evaluateLockDown(newBRROppMap);
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        Map<Id,BRR_Opportunity__c> oldBRROppMap = new Map<Id,BRR_Opportunity__c>();
        if(oldItems != null) oldBRROppMap = (Map<Id,BRR_Opportunity__c>) oldItems;
        if(!oldBRROppMap.isEmpty()){
            evaluateLockDown(oldBRROppMap);
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
    public void evaluateLockDown(Map<Id,BRR_Opportunity__c> brrOppMap){
        Map<Id,String> oppOwnerTerritoryMap = new Map<Id,String>();        
        Set<Id> subroles = new Set<Id>();
        Set<Id> brrId = new Set<Id>();
        Set<Id> oppOwnerRole = new Set<Id>();
        for(BRR_Opportunity__c brropp : brrOppMap.values()) {
			//system.debug('newBRROpp OWNER'+brropp.Opportunity_Owner__c);
            oppOwnerTerritoryMap.put(brropp.Opportunity_Owner__c, brropp.Territory__c);            
            brrId.add(brropp.Briefing_Room_Report__c);
        }
        if(!oppOwnerTerritoryMap.isEmpty()){
            for(User usr : [SELECT Id,userRoleId FROM User WHERE Id IN : oppOwnerTerritoryMap.keyset() AND isActive = TRUE]){
                oppOwnerRole.add(usr.userRoleId);
            }
        } 
        if(!oppOwnerRole.isEmpty()){
            subroles = GlobalUtility.getAllSubRoleIds(oppOwnerRole); //subRoles of OpportunityOwner
           	subroles.addALL(oppOwnerRole); // opp owner role
        }                
        if(!subroles.isEmpty() && subroles.contains(userinfo.getUserRoleId())){
            Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta = BRRUtility.getLockdownDayByTerritory(oppOwnerTerritoryMap.values());
            Map<Id,Briefing_Room_Report__c> mapBRRWeek = BRRUtility.getBRR(brrId);  
            for(BRR_Opportunity__c brropp : brrOppMap.values()) {
                Boolean isOutsideLockingPeriod = BRRUtility.isOutsideLockingPeriod(mapTerritoryBRRMeta,brropp.Territory__c);
                if(mapBRRWeek.get(brropp.Briefing_Room_Report__c).This_Week_BRR__c == True){
                    if(isOutsideLockingPeriod){
                        brropp.addError(system.label.BRR_Lock_Down);
                    }
                }else if(mapBRRWeek.get(brropp.Briefing_Room_Report__c).Past_Week__c == True){
                    brropp.addError(system.label.BRR_Lock_Down);
                }
            }
        }
    }
}