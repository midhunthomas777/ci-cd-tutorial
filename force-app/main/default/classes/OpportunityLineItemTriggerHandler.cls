/*************************************************************************************************************
* Class Name : OpportunityLineItemTriggerHandler
* Description : Handler class for OpportunityLineItemTrigger
* Author : Satish Maddhi
* Date : 25th Sep 2018
* Modification Log:
* ===========================================================================================================
* Satish maddhi    25th Sep 2018      Added methods for Revenue deletion (SF-735) 
*
*============================================================================================================
* Test classes: testRevenueObject, 
*************************************************************************************************************/

public class OpportunityLineItemTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    //public Id registrationRecTypeId = GlobalUtility.recordTypeId('Opportunity', 'Registration');
    public static Map<Id,Map<Id,Id>> oldProductMirrorMap = new Map<Id,Map<Id,Id>>();//SF-2090
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('OpportunityLineItemTriggerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id,OpportunityLineItem> mapOLIs = new Map<Id,OpportunityLineItem>();
        if(newItems != null) mapOLIs = (Map<Id,OpportunityLineItem>) newItems;
        Map<Id,OpportunityLineItem> OPMsToBeCreated = new Map<Id,OpportunityLineItem>(); ////SF-2085
        Set<Id> oppIds = new Set<Id>();
        Map<Id,OpportunityLineItem> OPMsToBeUpdated = new Map<Id,OpportunityLineItem>();  //SF-2172
        List<Opportunity> opportunityToBeUpated = new List<Opportunity>();
        Set<Opportunity> opportunitySet = new Set<Opportunity>();
       for(OpportunityLineItem OLI : [SELECT Opportunity.Run_Rate_Definition__c,Product2Id,Opportunity.New_Currency__c,currencyISOCode,OpportunityId,Revenue_Enabled__c FROM OpportunityLineItem WHERE Id=:mapOLIs.keyset()]){
            if((OLI.Revenue_Enabled__c || OLI.Opportunity.Run_Rate_Definition__c == NULL) && String.isBlank(OLI.Opportunity.New_Currency__c)){
                OPMsToBeCreated.put(OLI.Id, OLI);
            }
            if(String.isNotBlank(OLI.Opportunity.New_Currency__c)){
                OPMsToBeUpdated.put(OLI.Id, OLI);
                opportunitySet.add(OLI.Opportunity);       
            }
            oppIds.add(OLI.OpportunityId);
        }
        if(!OPMsToBeCreated.isEmpty()){
            ProjectForecastingUtility.createOpportunityMirror(OPMsToBeCreated);
        }
          if((!OPMsToBeUpdated.isEmpty() && !oldProductMirrorMap.isEmpty())){
            ProjectForecastingUtility.updateOpportunityMirror(OPMsToBeUpdated,oldProductMirrorMap);
            if(!opportunitySet.isEmpty()){
                for(Opportunity opp : opportunitySet){
                    opp.New_Currency__c = NULL;
                    opportunityToBeUpated.add(opp);
                }
            }
        }
        if(!opportunityToBeUpated.isEmpty()){
            update opportunityToBeUpated; 
        }
        if(!oppIds.isEmpty()) {
            updateNAProductHierarchy(oppIds);
            AgreementProdFamily_Helper APF = new AgreementProdFamily_Helper();
            APF.UpdateAgreement_OLI(oppIds);     
            //Added By Srikanth - VESTA_SPILLMAN_INT-587
            PreSalesTriggerHelper.updateProductGroupOnOpportunity(oppIds);
        }       
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        //SF-2012. Added code for BeforeDelete so that sales users dont delete runrate OLIs.
        Map<Id,OpportunityLineItem> oldOLIMap = (Map<Id,OpportunityLineItem>)oldItems;
        List<String> nonSalesProfLst = new List<String>();        
        String profileName = [select name from Profile where id=:userinfo.getProfileId()].name;
        List<Non_Sales_User_Profile__c> nonSalesProf = Non_Sales_User_Profile__c.getall().values();
        for(Non_Sales_User_Profile__c ns :nonSalesProf){            
            nonSalesProfLst.add(ns.name);
        }        
        for(OpportunityLineItem OLI : oldOLIMap.values()) { 	    
            if(OLI.Opportunity_Record_Type__c =='Run Rate' && !nonSalesProfLst.contains(profileName)){                
                //OLI.adderror('Opportunity Products cannot be deleted for Run Rate Opportunities');
                OLI.adderror(System.Label.Do_Not_Delete_Run_Rate_OLI);
            }            
        }               
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {
        Map<Id,OpportunityLineItem> oldOLIMap = (Map<Id,OpportunityLineItem>)oldItems;
        List<Id> opmIds = new List<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        for(OpportunityLineItem oli : oldOLIMap.values()){
            oppIds.add(oli.OpportunityId);            
        }
        for(Opportunity oppNew : [SELECT Id,New_Currency__c FROM Opportunity WHERE Id IN : oppIds]){
            opportunityMap.put(oppNew.Id,oppNew);
        }
        if(!opportunityMap.isEmpty()){
            for(OpportunityLineItem OLI : oldOLIMap.values()) {
                if(oli.Opportunity_Product_Mirror__c != NULL && String.isBlank(opportunityMap.get(oli.OpportunityId).New_Currency__c)) {
                    opmIds.add(oli.Opportunity_Product_Mirror__c);                   
                }
                if(oli.Opportunity_Product_Mirror__c != NULL && String.isNotBlank(opportunityMap.get(oli.OpportunityId).New_Currency__c)) {
                    if(oldProductMirrorMap.containskey(oli.OpportunityId)){
                        oldProductMirrorMap.get(oli.OpportunityId).put(oli.Product2Id, oli.Opportunity_Product_Mirror__c);
                    }else{
                        oldProductMirrorMap.put(oli.OpportunityId, new Map<Id,Id>{oli.Product2Id => oli.Opportunity_Product_Mirror__c});
                    }
                }
            }
        }
       
        if(!opmIds.isEmpty()) {
            Database.delete(opmIds, false);
        }
        if(!oppIds.isEmpty()) {
            updateNAProductHierarchy(oppIds);
            AgreementProdFamily_Helper APF = new AgreementProdFamily_Helper();
            APF.UpdateAgreement_OLI(oppIds);    
            //Added By Srikanth - VESTA_SPILLMAN_INT-587
            PreSalesTriggerHelper.updateProductGroupOnOpportunity(oppIds);
        }
    }
    
    private void updateNAProductHierarchy(Set<Id> oppIds) {
        Set<Id> setOppIds = new Set<Id>();
        for(opportunity opp :[SELECT Id FROM Opportunity where Id IN:oppIds AND RecordType.DeveloperName != 'Run_Rate']){
            setOppIds.add(opp.Id);
        }
        if(!setOppIds.isEmpty()){
            NA_Product_Hierarchy_Helper helperClass = new NA_Product_Hierarchy_Helper();
            helperClass.updateOpportunites(setOppIds);
        }
    }
    
    public void BeforeInsert(List<SObject> newItems) {}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}