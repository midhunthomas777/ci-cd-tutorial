/*  
* File Name  : DistributorTypeCheck
* Description: This Code is written for the Project "Partner Coverage Map" to set the Distributor Type value as True if atleast one Partner Type Record having the 
               Partnertype filed as Distributor'.This Batch class will be executed every day . 

* author     : Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author      Modification 
* ---   ---------   ----------- ----------------------------------------------- 
* 1.0   12-Sep-11   Infosys  Initial Code
* 
*/

global class DistributorTypeCheck implements Database.Batchable<sObject>{


global String query;
set<Id> accId=new set<Id>();

global  database.QueryLocator start(Database.BatchableContext BC)
    {
         if(test.isRunningTest()){
            query= 'select id,Account__c from Partner_Type__c where Partner_Track__c=\'Distributor\' and Account__r.Distributor_Partner__c=False Limit 1';
         }else{
        query= 'select id,Account__c from Partner_Type__c where Partner_Track__c=\'Distributor\' and Account__r.Distributor_Partner__c=False';
      system.debug('query :' + Database.getQueryLocator(query));
         }
         return Database.getQueryLocator(query);
         
    }
global void execute(Database.BatchableContext BC, list<Partner_Type__c> pType)
    {
          for(Partner_Type__c p:pType){
            if(!accId.contains(p.Account__c)) {
                    accId.add(p.Account__c);    
                }
          }
          
           //system.debug('Partner Type Accouhnt Records:'+accId.size());
          
          List<Account> finalAccUpdateList = [select Id,Distributor_Partner__c from Account where Id in:accId];
        
        for(Account acc:finalAccUpdateList){
            acc.Distributor_Partner__c=TRUE;
        }
        
        system.debug('Final Account Records:'+finalAccUpdateList);
        
        if(finalAccUpdateList.size()>0)
                update finalAccUpdateList;
    
    }
    
global void finish(Database.BatchableContext BC)
    {
    
    }

}