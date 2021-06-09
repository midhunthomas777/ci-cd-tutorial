/*
* Name : BidScrubTriggerHandler_Test
* Description : Test class for BidScrubTriggerHandler_Test
* Author : Anitha M
* Date : 5th July 2019
*/
@isTest
public class BidScrubTriggerHandler_Test {
    @isTest static void testUtil(){
        TestDataSetUpUtils.insertCustomSettings();
    }
    @isTest(SeeAllData=true)
    static void testBidScrubProductTgr() {
            Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            
            Test.startTest();
            Bid_Scrub__c bid = new Bid_Scrub__c();
            bid.Opportunity_Transaction_Number__c =lstOpportunity.get(0).SYM_Transaction_Number__c;
            bid.Opportunity__c = lstOpportunity.get(0).Id;           
            bid.Product_APC__c = '567';
            bid.Product_WWAPC__c = '5336';
            bid.Quantity__c = 100;
            bid.UnitPrice__c = 1000;
            bid.CurrencyIsoCode = 'USD';
            insert bid;  

			Bid_Scrub__c bid1 = new Bid_Scrub__c();
            bid1.Opportunity_Transaction_Number__c =lstOpportunity.get(0).SYM_Transaction_Number__c;
            bid1.Opportunity__c = lstOpportunity.get(0).Id;           
            bid1.Product_APC__c = '';
            bid1.Product_WWAPC__c = '5882';
            bid1.Quantity__c = 100;
            bid1.UnitPrice__c = 1000;
            bid1.CurrencyIsoCode = 'USD';
            insert bid1;   
        
        	bid1.Product_WWAPC__c = '5699';
        	update bid1;
            Test.stopTest();           
        }
    }