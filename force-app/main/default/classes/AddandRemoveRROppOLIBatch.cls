/*
 * Name :AddandRemoveRROppOLIBatch
* Description: Batch class for Auto mass add or delete OLI's with changes to RRPGs
* Author : Adilraza Shaikh, Afzal Wasi
* Date : 6/1/2020
*/

global class AddandRemoveRROppOLIBatch implements Database.Batchable<Run_Rate_Definition__c> ,Database.Stateful {
    Map<Id,List<String>> mapNewRRPoducts;
    Map<Id,List<Opportunity>> mapRROpportunity;
    Map<Id,List<String>> mapRemovedRRProducts;
    private List<Run_Rate_Definition__c> source;
    public AddandRemoveRROppOLIBatch(Map<Id,List<String>> mapNewRRPoducts ,Map<Id,List<Opportunity>> mapRROpportunity,List<Run_Rate_Definition__c> lstRunRate,
                                     Map<Id,List<String>> mapRemovedRRProducts) {
                                         this.mapNewRRPoducts = mapNewRRPoducts;
                                         this.mapRROpportunity = mapRROpportunity;
                                         this.mapRemovedRRProducts = mapRemovedRRProducts;
                                         this.source = lstRunRate;
                                     } 
    global Iterable<Run_Rate_Definition__c> start(Database.BatchableContext BC) {
        return new BatchRRDFeeder(source);
    }
    global void execute(Database.BatchableContext BC, List<Run_Rate_Definition__c> scope) {
        system.debug('scope'+scope);
        system.debug('scope'+scope.size());
        List<PriceBookEntry> PBE = new List<PriceBookEntry> ();
        List<Opportunity> lstRROpps = new List<Opportunity>();
        List<String> lstRRProdIds = new List<String>();
        List<String> lstOldRRProdIds = new List<String>();
        List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
        Set<String> currencyCodes = new Set<String>();
        if(!scope.isEmpty()){
            for(Run_Rate_Definition__c rrd: scope){
                lstRROpps= mapRROpportunity.get(rrd.Id);
                lstRRProdIds= mapNewRRPoducts.get(rrd.Id);
                if(mapRemovedRRProducts != NULL){
                    lstOldRRProdIds = mapRemovedRRProducts.get(rrd.Id);  
                }
                currencyCodes.add(rrd.CurrencyIsoCode);
            }
            system.debug('lstRRProdIds**'+lstRRProdIds);
            if(lstRRProdIds != NULL){
                PBE = [SELECT Id,UnitPrice FROM PriceBookEntry WHERE IsActive = TRUE 
                       AND Product2Id IN : lstRRProdIds AND CurrencyIsoCode IN : currencyCodes ];   
            }
            Map<String,Id> mapPriceBookEntryOpp = new Map<String,Id>();
            List<OpportunityLineItem> lstOLIToBeDeleted = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : [SELECT Id,OpportunityId,PriceBookEntryId FROM OpportunityLineItem WHERE 
                                           PricebookEntryId IN: PBE AND OpportunityId IN : lstRROpps]){
                                               //Product Already Added
                                               mapPriceBookEntryOpp.put(oli.OpportunityId+';'+oli.PriceBookEntryId,NULL);
                                           } 
            if(lstOldRRProdIds != NULL){
                for(OpportunityLineItem oli : [SELECT Id,OpportunityId,PriceBookEntryId FROM OpportunityLineItem WHERE 
                                               Product2Id IN:lstOldRRProdIds AND OpportunityId IN : lstRROpps AND 
                                              (Run_Rate_Revenue_Amount__c = NULL OR Run_Rate_Revenue_Amount__c = 0) 
                                               AND (UnitPrice = 0 OR UnitPrice = NULL)]){
                                                   lstOLIToBeDeleted.add(oli);
                                               } 
            }
            system.debug('mapPriceBookEntryOpp'+mapPriceBookEntryOpp);
            system.debug('lstOLIToBeDeleted'+lstOLIToBeDeleted);
            
            for(Opportunity Oppty : [SELECT Id FROM Opportunity WHERE Id IN : lstRROpps ]){
                system.debug('For OLI creationOppty*******'+Oppty.Id);
                for (PriceBookEntry PBEs : PBE){ 
                    system.debug('inside PBE' +PBEs.Id);
                    if(!mapPriceBookEntryOpp.containsKey(Oppty.Id+';'+PBEs.Id)){
                        system.debug('inside condition if Match');
                        OpportunityLineItem OLI = new OpportunityLineItem(
                            UnitPrice = PBEs.UnitPrice,PricebookEntryId = PBEs.Id,
                            Description ='Run Rate OLI',opportunityId = Oppty.Id
                        );
                        lstOLI.add(OLI);  
                    }
                }
                system.debug('lstOLI*******'+lstOLI);
            }
            if(!lstOLI.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(lstOLI, true);
                system.debug('srList****'+srList);
               
            }
            if(!lstOLIToBeDeleted.isEmpty()){
                Database.DeleteResult[] delList = Database.delete(lstOLIToBeDeleted, true);
                system.debug('delList****'+delList);
            } 
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob async = [SELECT Id,Status,JobType,NumberOfErrors,JobItemsProcessed,TotalJobItems,CompletedDate,ExtendedStatus
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        if(async!= NULL && async.NumberOfErrors > 0 ){ 
            Group grp = [select Id from Group where Type = 'Queue' and  DeveloperNAME = 'Sales_Automation'];
            Case cs = new Case(subject='Error Occured While Adding/ Removing Products to RR Opportunity',
                               Status = 'New',OwnerId= grp.Id,recordtypeId='01234000000M4ZS', //'00G34000002Fnjz',//Sales Automation Queue
                               Description = async.ExtendedStatus,Issue_Type__c ='Technical Issue'
                              );
            insert cs;
        }
        
    }
    
}