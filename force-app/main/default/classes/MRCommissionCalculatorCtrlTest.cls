@isTest
public class MRCommissionCalculatorCtrlTest {
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
    @isTest static void testcommissionPercentRecalCPQ(){
        //TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        TestDataSetUpUtils.assignPermissionSet(partnerUsr.Id);  
        //system.runas(partnerUsr)
        {
            Test.startTest();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            BigMachines__Quote__c objAccQuote = new BigMachines__Quote__c();
            objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
            objAccQuote.Name='testQuote';
            objAccQuote.BigMachines__Site__c=siteID;
            insert objAccQuote;
            MRCommissionCalculatorCtrl.commissionPercentRecalCPQ(objAccQuote.name,1000.20,5.0,true,'Box');
            MRCommissionCalculatorCtrl.CommissionWrapper cw = new MRCommissionCalculatorCtrl.CommissionWrapper();
            cw.effDollars=50.0;
            cw.effPercentage=10;
            cw.orderType='Box';            
            
            Test.stopTest(); 
        }
    }
    @isTest 
    public static void testMRCalc1(){
        //TestDataSetUpUtils.insertCustomSettings();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Account upMcn = new Account();
        upMcn.id= lstMCNAccount.get(0).Id;
        upMcn.ParentId=lstAccount.get(0).Id; 
        upMcn.Assigned_MR__c=partnerAccount.Id;
        update upMcn;
        
        List<PricebookEntry> priceBList =  new List<PricebookEntry>();
        
        List<Product2> prodList= new List<Product2>();      
        prodList.add(new Product2(Name='Radio', Description = 'Test'));
        prodList.add(new Product2(Name='Devices', Description= 'Test'));
        
        insert prodList;
        Pricebook2 standardPricebook = [SELECT Id from Pricebook2 limit 1 ];
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;*/
        
        for(Product2 pBE : prodList){
            priceBList.add(new PricebookEntry(pricebook2id = standardPricebook.Id, 
                                              product2Id = pBE.Id,CurrencyIsoCode='USD', 
                                              UnitPrice = 1.0, isActive = TRUE));          
        }
        insert priceBList;
        
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=partnerAccount.Id;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=partnerAccount.Id;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccount.id;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        Test.startTest();
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccount.Id;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = standardPricebook.Id;
        opp.Name='test opp';        
        opp.Approval_Status__c='Draft';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';
        opp.CDH_Account__c=upMcn.Id;        
        insert opp;
        
        OpportunityLineItem opli = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=priceBList[0].Id,Quantity=1,unitPrice=9999);
        insert opli;
        Test.stopTest();
        MR_Commission_Calculator__c mrcalc4 = new MR_Commission_Calculator__c(Box_Order_Amount__c=9999,
                                                                              Box_Override_Commission_Dollars__c=100,
                                                                              Opportunity__c = opp.Id,
                                                                              Motorola_Customer_Number__c = upMcn.Id
                                                                             );       
        insert mrcalc4;        
    }
    @isTest 
    public static void testMRCalc2(){
        //TestDataSetUpUtils.insertCustomSettings();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Account upMcn = new Account();
        upMcn.id= lstMCNAccount.get(0).Id;
        upMcn.ParentId=lstAccount.get(0).Id; 
        upMcn.Assigned_MR__c=partnerAccount.Id;
        update upMcn;

        List<PricebookEntry> priceBList =  new List<PricebookEntry>();
        
        List<Product2> prodList= new List<Product2>();      
        prodList.add(new Product2(Name='Radio', Description = 'Test'));
        prodList.add(new Product2(Name='Devices', Description= 'Test'));
        
        insert prodList;        
        Pricebook2 standardPricebook = [SELECT Id from Pricebook2];
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;  */    
        for(Product2 pBE : prodList){
            priceBList.add(new PricebookEntry(pricebook2id = standardPricebook.Id, 
                                              product2Id = pBE.Id,CurrencyIsoCode='USD', 
                                              UnitPrice = 1.0, isActive = TRUE));          
        }
        insert priceBList;
        
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=partnerAccount.Id;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=partnerAccount.Id;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccount.id;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        Test.startTest();
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccount.Id;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        Opportunity opp1 = new Opportunity(); 
        opp1.Pricebook2Id = standardPricebook.Id;
        opp1.Name='test opp1';        
        opp1.Approval_Status__c='Draft';
        opp1.AccountId=lstAccount.get(0).Id; 
        opp1.CloseDate = Date.today()+30;
        opp1.StageName='Design & Validate';
        opp1.CDH_Account__c=upMcn.Id;        
        insert opp1;
        
        OpportunityLineItem opli1 = new OpportunityLineItem(OpportunityId=opp1.Id, PricebookEntryId=priceBList[0].Id,Quantity=1,unitPrice=1009999);
        insert opli1;
        Test.stopTest();
        MR_Commission_Calculator__c mrcalc5 = new MR_Commission_Calculator__c(Box_Order_Amount__c=1009999,
                                                                              Box_PE_Discount_Percentage__c=10,
                                                                              Box_Service_Product__c ='Yes',
                                                                              Opportunity__c = opp1.Id,
                                                                              Motorola_Customer_Number__c = upMcn.Id
                                                                             );
        
        insert mrcalc5;
        
    }
}