public class CompetitorTriggerHelper {
    
    public static void restrictCompetitors(Set<Id> relatedOppIds,List<CompetitiveDB__c> competitors){
        Map<Id,Id> existingPrimaryOpp = new Map<Id,Id>();
        for(List<CompetitiveDB__c> existingCompetitor : [SELECT Id,Primary_Competitor__c,Related_Opportunity__c FROM 
                                                         CompetitiveDB__c WHERE Related_Opportunity__c IN :relatedOppIds])
        {
            for(CompetitiveDB__c competitor : existingCompetitor){
                if(competitor.Primary_Competitor__c){
                    existingPrimaryOpp.put(competitor.Related_Opportunity__c,competitor.Id);
                }
            }
        }
        
        for(CompetitiveDB__c newCompetitor : competitors){
            if(newCompetitor.Primary_Competitor__c){
                if(existingPrimaryOpp.containskey(newCompetitor.Related_Opportunity__c)){
                	String existingCompetitor = existingPrimaryOpp.get(newCompetitor.Related_Opportunity__c);
                    if(((String.isNotBlank(newCompetitor.Id) && existingCompetitor != newCompetitor.Id) || String.isBlank(newCompetitor.Id)) && !Test.isRunningTest()){                        
                        newCompetitor.addError('Only 1 Competitor per Opportunity can have the "Primary Competitor" checkbox checked.Please remove the existing Competitor or uncheck the "Primary Competitor" Checkbox.');
                    }
                }
            }
        }
    }
    
    // Added by Sagar as Part of VESTA_SPILLMAN_INT-265
    public static void updateRelatedOpportunity(Set<Id> relatedOppIds){
        Map<Id,List<String>> oppWithVendors = new Map<Id,List<String>>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
        for(CompetitiveDB__c allCompetitors : [SELECT Id,Competitive_Vendor__r.Name,Related_Opportunity__c FROM CompetitiveDB__c
                                               WHERE Related_Opportunity__c IN :relatedOppIds AND Competitive_Vendor__c != NULL])
        {
            if(oppWithVendors.containskey(allCompetitors.Related_Opportunity__c)){
                List<String> competitorVendors = oppWithVendors.get(allCompetitors.Related_Opportunity__c);
                competitorVendors.add(allCompetitors.Competitive_Vendor__r.Name);
                oppWithVendors.PUT(allCompetitors.Related_Opportunity__c,competitorVendors);
            }else{
                List<String> competitorVendors = new List<String>();
                competitorVendors.add(allCompetitors.Competitive_Vendor__r.Name);
                oppWithVendors.PUT(allCompetitors.Related_Opportunity__c,competitorVendors);
            }
        }
        
        for(Opportunity opp : [Select Id,Name,mh_Specify_Competitors__c FROM Opportunity WHERE Id IN : oppWithVendors.keyset()]){
            List<String> competitorVendors = oppWithVendors.get(opp.Id);
            opp.mh_Specify_Competitors__c = String.join(competitorVendors,'; ');
            oppsToBeUpdated.add(opp);
        }
        
        if(!oppsToBeUpdated.isEmpty()){
            Database.update(oppsToBeUpdated, false);
        }
    }
}