@isTest
public class CreateRevenueCtrlTest {
    @testSetup
    static void testSetUp() {
        
        TestDataSetUpUtils.insertCustomSettings();
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
    }
    @isTest
    public static void CreateRevenueCtrl(){
        //TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        //Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        
        //system.debug('Custom PricebookId'+stdPricebookId);
        /*Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;*/
		ID pricebookId = [SELECT Id from Pricebook2 limit 1 ].Id;
        system.debug('Std pricebookId'+pricebookId);
        List<Opportunity> lstOpportunity =new List<Opportunity>();
        for(integer i=0;i<20 ;i++){
            Opportunity opp = new Opportunity(); 
            opp.Pricebook2Id = pricebookId;
            opp.Name='test opp'+i;
            opp.AccountId=lstAccount.get(0).Id; 
            opp.CloseDate = Date.today()+30;
            opp.StageName='Design & Validate';
            lstOpportunity.add(opp);
        }
        insert lstOpportunity;
        List<Product2> pdtList = new List<Product2>();
        Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c ='Yes',Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        pdtList.add(prd1);
        insert pdtList;
        List<PricebookEntry> priceBkList = new List<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true , CurrencyISOCode ='USD');
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true, CurrencyISOCode ='EUR');
        priceBkList.add(pbe1);
        priceBkList.add(pbe2);
        Test.startTest();
        insert priceBkList;
        List<OpportunityLineItem> OLIlst = new List<OpportunityLineItem>();
        for(Opportunity op : lstOpportunity) {
            OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
            OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
            OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
            OpportunityLineItem lineItem4 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=5, totalprice=300);
            OLIlst.add(lineItem1);
            OLIlst.add(lineItem2);
            OLIlst.add(lineItem3);
            OLIlst.add(lineItem4);
        }
        Insert OLIlst;
        List<Opportunity_Product_Mirror__c> lstOppproductmirror =new List<Opportunity_Product_Mirror__c>();
        for(integer i=0;i<20 ;i++){
            Opportunity_Product_Mirror__c opm = new Opportunity_Product_Mirror__c();
            opm.Opportunity__c=lstOpportunity.get(0).Id;
            lstOppproductmirror.add(opm);
        } 
        insert lstOppproductmirror;
        Test.stopTest();
        Revenue__c rev = new Revenue__c();
        rev.Revenue_Month__c='January';
        rev.Opportunity__c=lstOpportunity.get(0).Id;
        rev.Opportunity_Product_Mirror__c=lstOppproductmirror.get(0).Id;
        rev.Revenue_Year__c='2020';
        rev.Revenue_Amount__c=10;
        rev.ProductFamily__c = pdtList.get(0).Id;
        insert rev;
        String jsonRevenue = '[{"sobjectType":"Revenue__c","Revenue_Month__c":"August","Revenue_Year__c":2020,"Revenue_Amount__c":599267},{"sobjectType":"Revenue__c","Revenue_Month__c":"July","Revenue_Year__c":"2021","Revenue_Amount__c":23}]';
        CreateRevenueCtrl.insertRevenues(OLIlst.get(0).Id, jsonRevenue);
        //Opportunity oppUpdate = new Opportunity(Id= lstOpportunity.get(0).Id, New_Currency__c = 'EUR' );
        //update oppUpdate;
        
        CreateRevenueCtrl.getOLIDetails(OLIlst.get(0).Id);
        CreateRevenueCtrl.getAllRevenuesPerOppo(lstOpportunity.get(0).Id);
        CreateRevenueCtrl.getRevenuesmonth();
        CreateRevenueCtrl.updateOLI(OLIlst.get(0).Id,OLIlst.get(0));
        CreateRevenueCtrl.updateOLI(null,OLIlst.get(0));
        CreateRevenueCtrl.getOpportunityDetails(OLIlst.get(0).Id);
        CreateRevenueCtrl.getExistingRevenueYears(OLIlst.get(0).Id);
        CreateRevenueCtrl.getRevenueOldYear(rev.Id);
    }
    
    @isTest
    public static void currencyChangeTest(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        //Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        
        //system.debug('Custom PricebookId'+stdPricebookId);
       /* Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;*/
		Id pricebookId = [SELECT Id from Pricebook2 limit 1 ].Id;
        system.debug('Std pricebookId'+pricebookId);
        List<Opportunity> lstOpportunity =new List<Opportunity>();
        for(integer i=0;i<2 ;i++){
            Opportunity opp = new Opportunity(); 
            opp.Pricebook2Id = pricebookId;
            opp.Name='test opp'+i;
            opp.AccountId=lstAccount.get(0).Id; 
            opp.CloseDate = Date.today()+30;
            opp.StageName='Design & Validate';
            lstOpportunity.add(opp);
        }
        insert lstOpportunity;
        List<Product2> pdtList = new List<Product2>();
        Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c ='Yes',Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        pdtList.add(prd1);
        insert pdtList;
        List<PricebookEntry> priceBkList = new List<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true , CurrencyISOCode ='USD');
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true, CurrencyISOCode ='EUR');
        priceBkList.add(pbe1);
        priceBkList.add(pbe2);
        Test.startTest();
        insert priceBkList;
        List<OpportunityLineItem> OLIlst = new List<OpportunityLineItem>();
        for(Opportunity op : lstOpportunity) {
            OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
            OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
            OLIlst.add(lineItem1);
            OLIlst.add(lineItem2);
        }
        Insert OLIlst;
        List<Opportunity_Product_Mirror__c> lstOppproductmirror =new List<Opportunity_Product_Mirror__c>();
        for(integer i=0;i<2 ;i++){
            Opportunity_Product_Mirror__c opm = new Opportunity_Product_Mirror__c();
            opm.Opportunity__c=lstOpportunity.get(0).Id;
            lstOppproductmirror.add(opm);
        } 
        insert lstOppproductmirror;
        Test.stopTest();
        Opportunity oppUpdate = new Opportunity(Id= lstOpportunity.get(0).Id, New_Currency__c = 'EUR' );
        update oppUpdate;
    }
    
}