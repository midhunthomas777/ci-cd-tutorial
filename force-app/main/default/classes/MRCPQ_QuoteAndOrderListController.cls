/************************************************************************************************
* Description : Used for Displaying the Quote details on click of "Add/Remove Product Family" button on Opportunity in community
* Author : Adilraza Shaikh
* Date :  31th Aug 2018
**********************************************************************************************/
public class MRCPQ_QuoteAndOrderListController {
    
    public static List<WrapperClass> lstQuoteWrapper{get;set;}
    
    public class WrapperClass implements comparable{
        @AuraEnabled
        public String quoteId{get; set;}
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String createdBy{get; set;}
        @AuraEnabled
        public DateTime createdDate{get; set;}
        @AuraEnabled
        public Boolean isPrimary{get; set;}
        @AuraEnabled
        public Double netAmount{get; set;}
        @AuraEnabled
        public String ownerName{get; set;}
        public WrapperClass()
        {}
        //Added by Venkat on Story SF-2007 
        public  Integer compareTo(Object compareTo) {
            
            WrapperClass compWrap = (WrapperClass)compareTo;
            String varisPrimary= String.valueof(isPrimary);
            String varcomWrapisPrimary= String.valueof(compWrap.isPrimary);
            
            if (varisPrimary == varcomWrapisPrimary) return 0;
            if (varisPrimary > varcomWrapisPrimary) return -1;
            return 	1;  }
        //Ended on Story SF-2007
    }
    @AuraEnabled
    public static List<WrapperClass> getCPQQuoteOrders(String opportunityId) {
        System.debug('opportunityId  - ' + opportunityId);
        List<User> users = [Select AccountId from User where Id =: UserInfo.getUserId() and AccountId != NULL];
        List<BigMachines__Quote__c> ordersToBeReturned = new List<BigMachines__Quote__c>();
        Map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>();
        String accountId;
        if(!users.isEmpty()){
            accountId = users.get(0).AccountId;
            for(BigMachines__Quote__c quoteOrder : [SELECT Id,Name,BigMachines__Account__c,Owner.Name,CreatedBy.Name,Is_Primary__c,CreatedDate, BigMachines__Total_Amount__c,
                                                    Motorola_Customer_Number__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: opportunityId
                                                    AND CreatedBy.AccountId =: accountId Order BY Name DESC]){
                                                        quotesMap.put(quoteOrder.Id, quoteOrder);
                                                    }
        }else{
            for(BigMachines__Quote__c quoteOrder : [SELECT Id,Name,BigMachines__Account__c,Owner.Name,CreatedBy.Name,Is_Primary__c,CreatedDate, BigMachines__Total_Amount__c,
                                                    Motorola_Customer_Number__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: opportunityId
                                                    Order BY Name DESC]){
                                                        quotesMap.put(quoteOrder.Id, quoteOrder);
                                                    }
        }
        lstQuoteWrapper = new List<WrapperClass>();
        for(UserRecordAccess accessList : [SELECT HasEditAccess, RecordId FROM UserRecordAccess WHERE RecordId IN : quotesMap.keySet() AND UserId = :UserInfo.getUserId()]){
            if((quotesMap.containsKey(accessList.RecordId) && accessList.HasEditAccess)|| Test.isRunningTest()){
                //    ordersToBeReturned.add(quotesMap.get(accessList.RecordId));
                //    Lightining datatable doesn't read lookup related fields , Hence used Wrapper.
                WrapperClass wrapObj = new WrapperClass();
                wrapObj.quoteId=quotesMap.get(accessList.RecordId).Id;
                wrapObj.name=quotesMap.get(accessList.RecordId).Name;
                wrapObj.createdBy=quotesMap.get(accessList.RecordId).CreatedBy.Name;
                wrapObj.createdDate=quotesMap.get(accessList.RecordId).CreatedDate;
                wrapObj.isPrimary=quotesMap.get(accessList.RecordId).Is_Primary__c;
                wrapObj.netAmount=quotesMap.get(accessList.RecordId).BigMachines__Total_Amount__c;
                wrapObj.ownerName=quotesMap.get(accessList.RecordId).Owner.Name;
                lstQuoteWrapper.add(wrapObj);
            }
        }
        lstQuoteWrapper.sort();//Added by venkat on story SF-2007
        return lstQuoteWrapper;
    }
    @AuraEnabled
    public static String addProductsToOppo(String quoteId, String oppId){
        //return RollupOppProductTotalPrice.RollupTotalPrice(quoteId, oppId);
        return CPQUtilityWithoutSharing.addProductsToOpportunity(quoteId, oppId);
    }
    @AuraEnabled
    public static String removeProductsToOppo(String quoteId, String oppId){
        //return RemovefromForecast.DrilldownTotalPrice(quoteId, oppId);
        return CPQUtilityWithoutSharing.removeProductsToOpportunity(quoteId, oppId);
    }
    //Added by venkat on Story SF-2007  
    @AuraEnabled
    public static List<MR_Digitization_Settings__mdt> fetchSuccessMsg(){
        return [SELECT Long_Text_Area__c,Values__c,DeveloperName FROM MR_Digitization_Settings__mdt WHERE
                DeveloperName IN ('CPQ_SuccessMsg','CPQ_SuccessMsg1')]; //1879-CPQ success message grammar error
    }
}