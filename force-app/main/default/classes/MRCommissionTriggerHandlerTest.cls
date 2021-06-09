@isTest
public class MRCommissionTriggerHandlerTest { 
    @isTest
    
    public static void mrcommissiontrigger(){
        TestDataSetUpUtils.insertCustomSettings();
        
        User partneruser= TestDataSetUpUtils.createPortalUser();
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Account upMcn = new Account();
        upMcn.id= lstMCNAccount.get(0).Id;
        upMcn.Assigned_MR__c=partnerAccount.Id;
        update upMcn;

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
        
        MR_Commission_Calculator__c mrcalc = new MR_Commission_Calculator__c(Box_Order_Amount__c=9999,
                                                                             Box_Override_Commission_Dollars__c=100,
                                                                             Motorola_Customer_Number__c = upMcn.Id);
        
        insert mrcalc; 
        update mrcalc;
       // delete mrcalc;
                    MRCommissionMCNDetailsController.deleteMRCalculator(mrcalc.Id);

        undelete mrcalc;
        MR_Commission_Calculator__c mrcalc1 = new MR_Commission_Calculator__c(System_Order_Amount__c=222,
                                                                              System_Override_Commission_Dollars__c=100,
                                                                              Motorola_Customer_Number__c = upMcn.Id);            
        insert mrcalc1; 
        update mrcalc1;
        MR_Commission_Calculator__c mrcalc2 = new MR_Commission_Calculator__c(CCMR_Order_Amount__c=232,
                                                                              CCMR_Override_Commission_Dollars__c=100,
                                                                              Motorola_Customer_Number__c = upMcn.Id);            
        insert mrcalc2; 
        update mrcalc2;
        MR_Commission_Calculator__c mrcalc3 = new MR_Commission_Calculator__c(SEC_Order_Amount__c=123,
                                                                              SEC_Override_Commission_Dollars__c=100,
                                                                              Motorola_Customer_Number__c = upMcn.Id);            
        insert mrcalc3; 
        update mrcalc3;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testOpp(){
        TestDataSetUpUtils.insertCustomSettings();
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
        Test.startTest();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        
        
                List<PricebookEntry> priceBList =  new List<PricebookEntry>();

        List<Product2> prodList= new List<Product2>();      
         prodList.add(new Product2(Name='Radio', Description = 'Test'));
        prodList.add(new Product2(Name='Devices', Description= 'Test'));
        
        insert prodList;
        
        Id stdPbId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        //List<PricebookEntry> priceBList =  new List<PricebookEntry>();
        for(Product2 pBE : prodList){
            priceBList.add(new PricebookEntry(pricebook2id = standardPricebook.Id, 
                                              product2Id = pBE.Id,CurrencyIsoCode='USD', 
                                              UnitPrice = 1.0, isActive = TRUE));
            //insert new PricebookEntry(pricebook2id = stdPbId, product2id = p1.id,unitprice=1.0, isActive=true);
        }
        insert priceBList;
        
      /*  Opportunity oppMrCom = new Opportunity(Name = 'testoppMRCOm',StageName = 'Prospect',
                                               CurrencyIsoCode='USD',
                                               closedate = System.today() + 30,
                                               AccountId= accTestCust.Id,
                                               Status__c='Active',
                                               //amount=9999,
                                               Customer_Account__c = 'testopp',
                                               CDH_Account__c  = mcnAcc[0].Id,
                                               recordtypeid = recordTypeMapOpp.get('Registration').getRecordTypeId());
        insert oppMrCom;*/
        
       
        
        
        
        
        
        
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = standardPricebook.Id;
        opp.Name='test opp';
        //opp.Amount=9999;
        opp.Approval_Status__c='Draft';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';
        opp.CDH_Account__c=upMcn.Id;
        insert opp;
        
        
         OpportunityLineItem opli = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=priceBList[0].Id,Quantity=1,unitPrice=9999);
        insert opli;
        
        
        
        
        
        
        update opp;
        
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
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccount.Id;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        MR_Commission_Calculator__c mrcalc4 = new MR_Commission_Calculator__c(Box_Order_Amount__c=9999,
                                                                              Box_Override_Commission_Dollars__c=100,
                                                                              Opportunity__c = opp.Id,
                                                                              Motorola_Customer_Number__c = upMcn.Id
                                                                             );
        
        insert mrcalc4;
        Test.stopTest();
    }
    @isTest
    public static void testOpenAccount(){
        TestDataSetUpUtils.insertCustomSettings();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Account upMcn = new Account();
        upMcn.id= lstMCNAccount.get(0).Id;
        upMcn.Primary_Route_to_Market__c='Open';
        update upMcn;
        Test.startTest();
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
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccount.Id;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        MR_Commission_Calculator__c mrcalc = new MR_Commission_Calculator__c(Box_Order_Amount__c=9999,
                                                                             Box_Override_Commission_Dollars__c=100,
                                                                             Motorola_Customer_Number__c = upMcn.Id,
                                                                             Partner_Account__c=partnerAccount.Id);
        
        insert mrcalc;
        Test.stopTest();
    }  
    
    
}