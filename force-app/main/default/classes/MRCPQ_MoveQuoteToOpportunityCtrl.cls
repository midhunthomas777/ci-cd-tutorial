/*******************************************************************************
* Description : This class is used for "Move Quote CPQ" button on Quote layout on community.
* Author : Afzal Wasi
* Date : 23rd Aug 2018
******************************************************************************/

public with sharing class MRCPQ_MoveQuoteToOpportunityCtrl {
    
   
    @AuraEnabled
    public static String moveQuoteToOpportunity(String selectedOppId , String quoteId){
        String mcnNumber=[SELECT CDH_Account__r.Motorola_Customer_Number__c FROM Opportunity WHERE Id=:selectedOppId].CDH_Account__r.Motorola_Customer_Number__c;
        String  partnerId;
        //String  partnerId = [SELECt Id,createdBy.AccountID FROM BigMachines__Quote__c WHERE Id=:quoteId].createdBy.AccountID;
        List<User> users = [Select AccountId from User where Id =: UserInfo.getUserId() and AccountId != NULL];
        if(!users.isEmpty()){
            partnerId=users.get(0).AccountId;
        }
        BigMachines__Quote__c objQuote= new BigMachines__Quote__c();
        objQuote.Id=quoteId;
        objQuote.AccountOnlyQuotes__c=null;
        objQuote.BigMachines__Opportunity__c=selectedOppId;
        if(String.isNotBlank(mcnNumber)){
            objQuote.Motorola_Customer_Number__c=mcnNumber;
        }
        String responseFromCPQ = MRCPQ_MoveQuoteToAccountCtrl.updateQuoteDetailsInCPQ(quoteId,mcnNumber,partnerId);
        system.debug('responseFromCPQ is'+responseFromCPQ);
        if(responseFromCPQ == 'Ok'){
            try{
                update objQuote;
                system.debug('updated objQuote'+objQuote.Id);
            }
            catch(DMLException ex){
                system.debug('Exception is...'+ex.getMessage());
            }
            return 'Ok';
        }else{
            return 'FAIL';
        }
        
    }
    @AuraEnabled
    public static String fetchSitePrefix(){
        return CPQUtility.fetchSitePrefix();
    }
    //SF-2205 - New Opportunity button on Quote "Move to Opportunity" popup doesn't work
    @AuraEnabled
    public static Boolean isLoggedinPartnerUser(){
        return GlobalUtility.isLoggedinPartnerUser();
    }
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm,String accountId){
        system.debug('searchTerm'+searchTerm);
        system.debug('accountId'+accountId);
        String searchName= '%'+searchTerm+'%';
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String opptyIcon = 'standard:opportunity';
        // return [select id from opportunity WHERE accountID=: accountId ];
        for (Opportunity oppty : [SELECT Id,Name, Amount,CDH_Account__r.Motorola_Customer_Number__c from opportunity WHERE accountID=: accountId AND RecordType.Developername='Government_Standard' AND Name LIKE :searchName ]) {
            results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, oppty.CDH_Account__r.Motorola_Customer_Number__c +' | '+ oppty.Amount));
        }
        return results;
        
    }
    @AuraEnabled
    public static Boolean canMoveQuote(String quoteId) {
        List<BigMachines__Quote__c> lstQuote = [SELECT BigMachines__Status__c FROM BigMachines__Quote__c WHERE Id=:quoteId 
                                                AND BigMachines__Status__c IN ('Approval Pending','Order Creation In Progress','Order Creation Successful','Completed')];
        if(lstQuote.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
    
}