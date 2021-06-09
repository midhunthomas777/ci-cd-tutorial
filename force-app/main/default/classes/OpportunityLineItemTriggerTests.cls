/****************************************************************
* Class Name : OpportunityLineItemTriggerTests
* Description : Test class for OpportunityLineItemTrigger trigger
* Author : Satish Maddhi
* Date : 25th Sep 2017
****************************************************************/ 

@isTest
public class OpportunityLineItemTriggerTests {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c TrgrDisbld = new TriggerSettings__c(Name ='OpportunityTriggerDisabled',Isactive__c=TRUE);
        insert TrgrDisbld;
    }
    @isTest
    public static void test_OpportunityLineItemNew(){
        Id accRegId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> acclist = TestDataSetUpUtils.createaccounts(1,accRegId);
        Id OppProjectId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<opportunity> opplist = TestDataSetUpUtils.createOpportunities(1, OppProjectId, acclist);                 
        opplist.get(0).New_Currency__c = 'EUR';
        update opplist[0]; 
        opplist.get(0).New_Currency__c = 'USD';
        update opplist[0];
        Id pricebookId = Test.getStandardPricebookId();
        List<Product2> pdtList = new List<Product2>();
        Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product Entry 1',Run_Rate_Product_Group__c = 'EMEA Business Light & Channel',Description='Test Product Entry 1',productCode = 'ABC', isActive = true );
        pdtList.add(prd1);
        insert pdtList;
        List<PricebookEntry> priceBkList = new List<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=80000, isActive=true,CurrencyIsoCode='USD');
        priceBkList.add(pbe1);
        insert priceBkList;
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opplist.get(0).Id,PriceBookEntryID=priceBkList[0].id,UnitPrice=80000, quantity=4);
        insert lineItem1;
        lineItem1.TotalPrice = 1000;
        Test.startTest();
        update lineItem1;        
        List<Opportunity_Product_Mirror__c> lstOppproductmirror =new List<Opportunity_Product_Mirror__c>();        
        for(integer i=0;i<20 ;i++){
            Opportunity_Product_Mirror__c opm = new Opportunity_Product_Mirror__c();
            opm.Opportunity__c=opplist.get(0).Id;
            lstOppproductmirror.add(opm);
        } 
        insert lstOppproductmirror;
        Test.stopTest();
        Revenue__c rev1 = new Revenue__c();
        rev1.Opportunity__c = opplist[0].Id;
        rev1.ProductFamily__c = pdtList[0].Id;
        rev1.Product_Family__c = lineItem1.Id;
        rev1.Revenue_Month__c = 'April';
        rev1.Revenue_Year__c = '2022';
        rev1.CurrencyIsoCode = 'USD';
        rev1.Revenue_Amount__c = 2500;
        rev1.Opportunity_Product_Mirror__c = lstOppproductmirror.get(0).Id;
        insert rev1;                              
        lineItem1.Opportunity_Product_Mirror__c = lstOppproductmirror.get(0).Id;
        update lineItem1;
        delete lineItem1; 
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opplist.get(0).Id,PriceBookEntryID=priceBkList[0].id,UnitPrice=80000, quantity=4);
        insert lineItem2;                    
        lineItem2.Opportunity_Product_Mirror__c = lstOppproductmirror.get(1).Id;
        update lineItem2;
        rev1.Product_Family__c = lineItem2.Id;
        update rev1;
    }
}