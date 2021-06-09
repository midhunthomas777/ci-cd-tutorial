/************************************************************************************************
* Description : Used for Displaying the Quotes and Quote Packages, and allow editing Product Families for multiple quotes.
* Author : Kelly Sorensen
* Date :  20th Oct 2020
**********************************************************************************************/

public class MRCPQ_EditQuotePackageController  {

    public static List<WrapperClass> quoteWrapper{get;set;}

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
        @AuraEnabled
        public string hostQuoteId{get; set;}
        @AuraEnabled
        public string hostQuoteName{get; set;}

        public WrapperClass()
        {}
        public  Integer compareTo(Object compareTo) {
            
            WrapperClass compWrap = (WrapperClass)compareTo;
            String varisPrimary= String.valueof(isPrimary);
            String varcomWrapisPrimary= String.valueof(compWrap.isPrimary);
            
            if (varisPrimary == varcomWrapisPrimary) return 0;
            if (varisPrimary > varcomWrapisPrimary) return -1;
            return 	1;  }
    }

    @AuraEnabled
    public static List<WrapperClass> getQuotePackages(Id oppId){
        List<User> users = [Select AccountId from User where Id =: UserInfo.getUserId() and AccountId != NULL];
        List<BigMachines__Quote__c> ordersToBeReturned = new List<BigMachines__Quote__c>();
        Map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>();
        String accountId;
        if(!users.isEmpty()){
            accountId = users.get(0).AccountId;
            for(BigMachines__Quote__c quotes : [SELECT Id, Name, BigMachines__Account__c, owner.Name, CreatedBy.Name, Is_Primary__c, 
                                                CreatedDate, BigMachines__Total_Amount__c, Motorola_Customer_Number__c,  
                                                BigMachines__Opportunity__c,
                                                Quote_Host__r.Id, Quote_Host__r.Name, Quote_Host__r.Motorola_Customer_Number__c,  
                                                Quote_Host__r.BigMachines__Opportunity__c
                                            FROM BigMachines__Quote__c 
                                            WHERE BigMachines__Opportunity__c = :oppId 
                                            AND CreatedBy.AccountId =: accountId 
                                            ORDER BY Quote_Host__c, Name Desc]){
                                                quotesMap.put(quotes.Id, quotes);
                                            }
        }else{
            for(BigMachines__Quote__c quotes : [SELECT Id, Name, BigMachines__Account__c, owner.Name, CreatedBy.Name, Is_Primary__c, 
                                                CreatedDate, BigMachines__Total_Amount__c, Motorola_Customer_Number__c,  
                                                BigMachines__Opportunity__c,
                                                Quote_Host__r.Id, Quote_Host__r.Name, Quote_Host__r.Motorola_Customer_Number__c,  
                                                Quote_Host__r.BigMachines__Opportunity__c
                                            FROM BigMachines__Quote__c 
                                            WHERE BigMachines__Opportunity__c = :oppId
                                            ORDER BY Quote_Host__c, Name Desc]){
                                                quotesMap.put(quotes.Id, quotes);
                                            }
        }
        quoteWrapper = new List<WrapperClass>();
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
                wrapObj.hostQuoteId=quotesMap.get(accessList.RecordId).Quote_Host__c;
                wrapObj.hostQuoteName=quotesMap.get(accessList.RecordId).Quote_Host__r.Name;
                quoteWrapper.add(wrapObj);
            }
        }
        quoteWrapper.sort();//Added by venkat on story SF-2007

        return quoteWrapper;
    }
 
    @AuraEnabled
    public static List<MR_Digitization_Settings__mdt> fetchSuccessMsg(){
        return [SELECT Long_Text_Area__c,Values__c,DeveloperName FROM MR_Digitization_Settings__mdt WHERE
                DeveloperName IN ('CPQ_SuccessMsg','CPQ_SuccessMsg1')]; //1879-CPQ success message grammar error
    }

    @AuraEnabled
    public static String UpdateOppQuoteProducts(List<String> quotes, String oppId){
        List<Id> quoteIds = new List<Id>();
        if(!quotes.isEmpty()){
            for(String idString : quotes){
                quoteIds.add((Id)idString);
            }
        }
        return CPQUtilityWithoutSharing.addProductsToOpportunity(quoteIds, oppId);
    }

    @AuraEnabled
    public static String removeAllProducts(String oppId){
        
        String retval;
        system.debug('removeAllProducts-oppId: ' + oppId);
            return DrilldownTotalPriceAll(oppId);
    }

    public static String DrilldownTotalPriceAll(Id OpptyId ){
        String returnValue = 'Success';
        String strPFGNA;
        
        Set<Id> Pids = new Set<Id> ();
        
        List<OpportunityLineItem> Olisdelete = new List<OpportunityLineItem> ();
        BigMachines__Quote__c[] OracleQPrimary = new List<BigMachines__Quote__c>();
        List<BigMachines__Quote__c> OracleQs = new List<BigMachines__Quote__c> ();
        List<BigMachines__Quote__c> OracleQUpdate = new List<BigMachines__Quote__c> ();
        List<BigMachines__Quote_Product__c> OracleQP = new List<BigMachines__Quote_Product__c> ();
        List<BigMachines__Quote_Product__c> OracleQPUpdatePFG = new List<BigMachines__Quote_Product__c> ();
        
        OracleQs = [select Id,Is_Primary__c,BigMachines__Opportunity__r.Id,BigMachines__Opportunity__r.Pricebook2Id,BigMachines__Opportunity__r.CurrencyIsoCode,CurrencyIsoCode from BigMachines__Quote__c where BigMachines__Opportunity__r.Id =: OpptyId];
        for(BigMachines__Quote__c OQ : OracleQs)
        {
            If(OQ.Is_Primary__c)
            {
                System.debug('Is Primary: ' + OQ.Is_Primary__c + '  Id: ' + OQ.Id);
                OQ.Is_Primary__c = FALSE;
                OracleQPrimary.add(OQ);
                OracleQUpdate.add(OQ);
            }
        } 
        system.debug('OQ: ' + OracleQs); 
        system.debug('OracleQPrimary: ' + OracleQPrimary);
        system.debug('OracleQUpdate: ' + OracleQUpdate);
        
        List<OpportunityLineItem> olisToHaveZeroPrice = new List<OpportunityLineItem>();        
        for(OpportunityLineItem eachLineItem:[SELECT Id 
                                              FROM opportunityLineItem 
                                              WHERE OpportunityId=:OracleQPrimary[0].BigMachines__Opportunity__r.id 
                                              AND CPQ_Updatable2__c='Yes']){
            eachLineItem.UnitPrice = 0;
            olisToHaveZeroPrice.add(eachLineItem); 
            system.debug('eachLineItem: ' + eachLineItem); 
        } 
        system.debug('olisToHaveZeroPrice: ' + olisToHaveZeroPrice);
        BypassPartnerOpptyIncludeProduct__c tempSkipValidation = BypassPartnerOpptyIncludeProduct__c.getOrgDefaults(); 
        
        if(!OracleQUpdate.isEmpty()){
            if(!olisToHaveZeroPrice.isEmpty()){
                if(Userinfo.getUserType() == 'PowerPartner') {                   
                    tempSkipValidation.Value__c = true;
                    try{
                            update tempSkipValidation;
                    } catch (DmlException e) {
                        String umsg = 'Update Failed: ' + e.getMessage();
                        system.debug(umsg);
                        return umsg;
                    }
                }
                system.debug('before update');
                try {
                    update olisToHaveZeroPrice;
                } catch (DmlException e) {
                    String umsg = 'Update Failed: ' + e.getMessage();
                    system.debug(umsg);
                    return umsg;
                }
                system.debug('afte update');
                if(Userinfo.getUserType() == 'PowerPartner') {
                    tempSkipValidation.Value__c = false;
                    try{
                        update tempSkipValidation;
                    } catch (DmlException e) {
                        String umsg = 'Update Failed: ' + e.getMessage();
                        system.debug(umsg);
                        return umsg;
                    }
                }
            }  
            try{            
                update OracleQUpdate;   
            } catch (DmlException e) {
                String umsg = 'Update Failed: ' + e.getMessage();
                system.debug(umsg);
                return umsg;
            }  
        }      
        return returnValue;
    }
    
}