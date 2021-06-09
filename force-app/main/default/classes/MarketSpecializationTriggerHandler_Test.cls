/************************************************************************************************* 
* File Name  : MarketSpecializationTriggerHandler_Test
* Description: Test class for MarketSpecializationTriggerHandler class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 15-Aug-2018     Satish Maddhi(TCS)	  			Initial development
*
*************************************************************************************************/

@isTest
public class MarketSpecializationTriggerHandler_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testmethod void test_MarketSpecializationTgr() {
        Account acc = new Account(Name='test',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123');
        insert acc;
        
        Partner_Type__c part = new Partner_Type__c();
        part.Account__c=acc.id;
        part.Status__c='Inactive';
        part.US_Federal__c=false;
        insert part;
        
        Market_Specializations__c market = new Market_Specializations__c();
        market.Market_Specialization__c = 'US Federal';
        market.Account__c=acc.id;
        insert market;
        
        Test.startTest();
        
        Partner_Type__c part1 = new Partner_Type__c();
        part1.Account__c=acc.id;
        part1.Status__c='Active';
        part1.id = part.id;
        part1.US_Federal__c=true;
        update part1;
        
        Market_Specializations__c market1 = new Market_Specializations__c();
        market1.Market_Specialization__c = 'US Federal';
        market1.Account__c=acc.id;
        market1.id = market.id;
        market1.Market_Specialization__c = 'US Federal';
        market1.Market_Specialization_Level__c='none';
        update market1;
        
        market1.Market_Specialization__c = 'US Federal';
        delete market1;
		undelete market1;        
        Test.Stoptest();
    }
}