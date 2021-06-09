public class CompetitorTriggerHandler implements ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('CompetitorTriggerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Set<Id> relatedOpportunityIDs = new Set<Id>();
        List<CompetitiveDB__c> competitorList = new List<CompetitiveDB__c>();
        if(newItems != null) competitorList = (List<CompetitiveDB__c>) newItems;
        
        for(CompetitiveDB__c competitorRecord : competitorList){
            if(String.isNotBlank(competitorRecord.Related_Opportunity__c) && (String.isNotBlank(competitorRecord.Account_ID__c) || 
                                                                              competitorRecord.Contract_Amount__c != NULL || 
                                                                              competitorRecord.Contract_Date__c != NULL ||
                                                                              String.isNotBlank(competitorRecord.Country__c) ||
                                                                              String.isNotBlank(competitorRecord.State__c) ||
                                                                              String.isNotBlank(competitorRecord.TechnologyType__c)))
            {
				competitorRecord.addError('You can not enter Contract Amount, Contract Date, Prospect or Customer Account, Country, MSI Technology Type and State fields. It will auto populate from opportunity once record save.');                
            }else if(String.isNotBlank(competitorRecord.Related_Opportunity__c)){
                relatedOpportunityIDs.add(competitorRecord.Related_Opportunity__c);
            }
        }
        
        if(!relatedOpportunityIDs.isEmpty()){
            for(Opportunity opp : [SELECT Id,AccountId,Amount,CloseDate,CurrencyIsoCode,Country__c,OwnerId,
                                   State__c,Primary_Product__c FROM Opportunity WHERE Id IN:relatedOpportunityIDs])
            {
                opportunityMap.put(opp.Id, opp);
            }
            
            if(!opportunityMap.isEmpty()){
                fieldPopulationFromOpp(opportunityMap,competitorList);
            }
        }
        CompetitorsValidation(competitorList);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Set<Id> relatedOpportunityIDs = new Set<Id>();
        List<CompetitiveDB__c> competitorList = new List<CompetitiveDB__c>();
        if(newItems != null) competitorList = (List<CompetitiveDB__c>) newItems.values();
        
        for(CompetitiveDB__c competitorRecord : competitorList){
            CompetitiveDB__c oldCompetitor = (CompetitiveDB__c)oldItems.get(competitorRecord.Id);
            if(String.isNotBlank(competitorRecord.Related_Opportunity__c)){
                relatedOpportunityIDs.add(competitorRecord.Related_Opportunity__c);
            }
        }
        
        if(!relatedOpportunityIDs.isEmpty()){
            for(Opportunity opp : [SELECT Id,AccountId,Amount,CloseDate,CurrencyIsoCode,Country__c,OwnerId,
                                   State__c,Primary_Product__c FROM Opportunity WHERE Id IN:relatedOpportunityIDs])
            {
                opportunityMap.put(opp.Id, opp);
            }
            
            if(!opportunityMap.isEmpty()){
                fieldPopulationFromOpp(opportunityMap,competitorList);
            }
        }
        CompetitorsValidation(competitorList);
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        getOpportunties(newItems.values());
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        getOpportunties(newItems.values());
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {
        getOpportunties(oldItems.values());
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    Public void CompetitorsValidation(List<CompetitiveDB__c> competitorList){
        Set<Id> primaryComptOppIds = new Set<Id>();
        for(CompetitiveDB__c competitorRecord : competitorList){
            String combinedValue = competitorRecord.Competitive_Vendor__c+','+competitorRecord.Account_ID__c+','+competitorRecord.Related_Opportunity__c;
            competitorRecord.Unique_Competitor__c = combinedValue;
            if(competitorRecord.Primary_Competitor__c && String.isNotBlank(competitorRecord.Related_Opportunity__c)){
                primaryComptOppIds.add(competitorRecord.Related_Opportunity__c);
            }
        }
        if(!primaryComptOppIds.isEmpty()){
            CompetitorTriggerHelper.restrictCompetitors(primaryComptOppIds,competitorList);
        }
    }
    
    // Added by Sagar as Part of VESTA_SPILLMAN_INT-265
    Public void getOpportunties(List<SObject> Items){
        Set<Id> oppIds = new Set<Id>();
        List<CompetitiveDB__c> competitorList = new List<CompetitiveDB__c>();
        if(Items != null) competitorList = (List<CompetitiveDB__c>) Items;
        for(CompetitiveDB__c competitorRecord : competitorList){
            if(String.isNotBlank(competitorRecord.Related_Opportunity__c)){
                oppIds.add(competitorRecord.Related_Opportunity__c); 
            }
        }
        if(!oppIds.isEmpty()){
            CompetitorTriggerHelper.updateRelatedOpportunity(oppIds);
        }
    }
    
    // Added by Sagar as Part of VESTA_SPILLMAN_INT-265
    Public void fieldPopulationFromOpp(Map<Id,Opportunity> opportunityMap,List<CompetitiveDB__c> competitorList){
        for(CompetitiveDB__c competitor : competitorList){
            if(String.isNotBlank(competitor.Related_Opportunity__c) && opportunityMap.containsKey(competitor.Related_Opportunity__c)){
                Opportunity oppr = opportunityMap.get(competitor.Related_Opportunity__c);
                competitor.Account_ID__c = oppr.AccountId;
                competitor.Contract_Amount__c = oppr.Amount;
                competitor.Contract_Date__c = oppr.CloseDate;
                competitor.CurrencyIsoCode = oppr.CurrencyIsoCode;
                competitor.Country__c = oppr.Country__c;
                competitor.State__c = oppr.State__c;
                competitor.TechnologyType__c = oppr.Primary_Product__c;
                competitor.OwnerId = oppr.OwnerId;
            }
        }
    }
}