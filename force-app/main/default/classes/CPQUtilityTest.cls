@isTest
public class CPQUtilityTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest static void testUtil7(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        //system.runas(partnerUsr){
        Test.startTest();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        
        BigMachines__Quote__c objAccQuote = new BigMachines__Quote__c();
        objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
        objAccQuote.Name='testQuote';
        objAccQuote.BigMachines__Site__c=siteID;
        insert objAccQuote;
        
        BigMachines__Quote__c objOppQuote = new BigMachines__Quote__c();
        objOppQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
        objOppQuote.Name='testQuote';
        objOppQuote.BigMachines__Site__c=siteID;
        insert objOppQuote;
        
        String CPQSessionResult= CPQUtility.createCPQSession(lstAccount.get(0).Id,lstMCNAccount.get(0).Motorola_Customer_Number__c,10.00,'12345','Box',lstOpportunity.get(0).Id,'Partner Quote',null);
        String sitePrefix = CPQUtility.fetchSitePrefix();
        system.debug('sitePrefix====>'+sitePrefix);
        //system.assertEquals('https://uat-mpecommunity.cs2.force.com/NA/s', sitePrefix);
        String Idsite = CPQUtility.fetchCPQSiteId();
        system.assertEquals(siteID, Idsite);
        String editUrlWithAccount=CPQUtility.getPageUrl(String.valueOf(objAccQuote.Id));
        //system.assertEquals('https://uat-mpecommunity.cs2.force.com/NA/s/apex/BigMachines__QuoteEdit?actId='+lstAccount.get(0).Id, editUrlWithAccount);
        String editUrlWithOpportunity=CPQUtility.getPageUrl(String.valueOf(objOppQuote.Id));
        Test.stopTest();
        //}
    }
    
        /*@isTest static void testUtil()
    TestDataSetUpUtils.insertCustomSettings();
    Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
    Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
    //Test.startTest();
    User partnerUsr = TestDataSetUpUtils.createPortalUser();
    Id siteID = TestDataSetUpUtils.createSite();
    MetadataCoverageTest.setMetadata('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt'
    , (List<FedTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"DOD-West"}]', List<FedTerritories__mdt>.class));
    MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM SLTerritories__mdt'
    , (List<SLTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"T8"}]', List<SLTerritories__mdt>.class));
    MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt'
    , (List<MR_Order_Types_for_CPQ__mdt>) JSON.deserialize('[{"MasterLabel":"Box","Is_Available_for_MRs__c":"true"}]', List<MR_Order_Types_for_CPQ__mdt>.class));
    MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName,Percentage__c FROM MR_Tech_Specialization_Level__mdt'
    , (List<MR_Tech_Specialization_Level__mdt>) JSON.deserialize('[{"MasterLabel":"Elite Specialist","Percentage__c":"8.20","DeveloperName":"Fed_Elite_Specialist"}]', List<MR_Tech_Specialization_Level__mdt>.class));
    
    MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Territories_Commission__mdt'
    , (List<MR_Territories_Commission__mdt>) JSON.deserialize('[{"MasterLabel":"State/Local Manufacturer Representative","Territory_Commission__c":"8.2","MR_Tech_Specialization_Level__r.MasterLabel":"Elite Specialist","MR_Tech_Specialization_Level__r.Percentage__c":"8.20"}]', List<MR_Territories_Commission__mdt>.class));
    
    
    contact con = [SELECT ID,AccountID from Contact where ID =: partnerUsr.ContactId ];
    
    
    system.runas(partnerUsr){            
    List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
    List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
    //  List<Technology_Specialization__c> TestDataSetUpUtils.createTechSpecInfoRecords();
    Set<String> fedter= CPQUtility.fetchFedTerritories();
    Set<String> slter= CPQUtility.fetchSLTerritories();
    //Set<String> mdOrder= CPQUtility.getOrderType();
    
    
    BigMachines__Quote__c objAccQuote = new BigMachines__Quote__c();
    objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
    objAccQuote.Name='testQuote';
    objAccQuote.BigMachines__Site__c=siteID;
    insert objAccQuote;
    BigMachines__Quote__c objOppQuote = new BigMachines__Quote__c();
    objOppQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
    objOppQuote.Name='testQuote';
    objOppQuote.BigMachines__Site__c=siteID;
    insert objOppQuote;
    Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
    List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
    List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
    system.debug('partnerUsrAccountId'+partnerUsr.AccountId);
    Partner_Identifier__c pI = new Partner_Identifier__c();
    pI.ID_Number__c='965432';
    pI.ID_Type__c='Federal Manufacturer Representative ID';
    pI.Account__c=partnerAccount.Id;
    insert pI;
    // Test.stopTest();    
    Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
    partnerIdentifier.ID_Number__c='9654432';
    partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
    partnerIdentifier.Account__c=partnerAccount.Id;
    insert partnerIdentifier;
    
    Test.startTest();
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
    techspec.Community_Type__c= 'State and Local Manufacturer Representative';
    insert techspec;
    
    
    
    //Account partnerAccountDetails = CPQUtility.fetchPartnerAccountDetails();
    //Account fetchCustomerDetails = CPQUtility.fetchCustomerorProspectAccountDetails(lstMCNAccount.get(0).Motorola_Customer_Number__c,lstMCNAccount.get(0).Id,'Customer');
    //Account fetchProspectDetails = CPQUtility.fetchCustomerorProspectAccountDetails(lstMCNAccount.get(0).Motorola_Customer_Number__c,lstProspectAccount.get(0).Id,'Prospect');
    
    //String PartnerIdentifierNumberSL=CPQUtility.fetchPartnerIdentifierNumber('T8',partnerAccount.Id);
    //String PartnerIdentifierNumberFed=CPQUtility.fetchPartnerIdentifierNumber('DOD-West',partnerAccount.Id);
    String CPQSessionResult= CPQUtility.createCPQSession(lstAccount.get(0).Id,lstMCNAccount.get(0).Motorola_Customer_Number__c,10.00,'12345','Box');
    String sitePrefix = CPQUtility.fetchSitePrefix();
    system.debug('sitePrefix====>'+sitePrefix);
    //system.assertEquals('https://uat-mpecommunity.cs2.force.com/NA/s', sitePrefix);
    String Idsite = CPQUtility.fetchCPQSiteId();
    system.assertEquals(siteID, Idsite);
    String editUrlWithAccount=CPQUtility.getPageUrl(String.valueOf(objAccQuote.Id));
    //system.assertEquals('https://uat-mpecommunity.cs2.force.com/NA/s/apex/BigMachines__QuoteEdit?actId='+lstAccount.get(0).Id, editUrlWithAccount);
    String editUrlWithOpportunity=CPQUtility.getPageUrl(String.valueOf(objOppQuote.Id));
    //system.assertEquals('https://uat-mpecommunity.cs2.force.com/NA/s/apex/BigMachines__QuoteEdit?oppId='+lstOpportunity.get(0).Id, editUrlWithOpportunity);
    
    
    CPQUtility.SpecAndCTypeWrapper specTier = new CPQUtility.SpecAndCTypeWrapper();     
    specTier.mrTierLevel='Elite Specialist';     
    specTier.mrCommunityType='State/Local Manufacturer Representative';
    specTier.territory='T8';
    
    
    CPQUtility.AccountDetailsWrapper accDetailWrap = new CPQUtility.AccountDetailsWrapper();     
    accDetailWrap.customerAccount=lstAccount.get(0);
    accDetailWrap.partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
    accDetailWrap.prospectAccount=lstProspectAccount.get(0);
    accDetailWrap.mrCommunityType='State and Local Manufacturer Representative';
    accDetailWrap.mrAssignedMR='Yes';
    accDetailWrap.mrId='12345';
    accDetailWrap.mrTierLevel='Elite Specialist';
    
    String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
    CPQUtility.fetchAccDetailsForMSILED(mncNumber); 
    CPQUtility.fetchAccountDetails(mncNumber,partnerAccount.Id,lstAccount.get(0).Id);
    }
    Test.stopTest();   
    }*/
    
    @isTest static void testUtil2(){
        
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        //Test.startTest();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        MetadataCoverageTest.setMetadata('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt'
                                         , (List<FedTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"DOD-West"}]', List<FedTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM SLTerritories__mdt'
                                         , (List<SLTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"T8"}]', List<SLTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt'
                                         , (List<MR_Order_Types_for_CPQ__mdt>) JSON.deserialize('[{"MasterLabel":"Box","Is_Available_for_MRs__c":"true"}]', List<MR_Order_Types_for_CPQ__mdt>.class));
        
        system.debug('partnerUsrAccountId out'+partnerUsr);
        contact con = [SELECT ID,AccountID from Contact where ID =: partnerUsr.ContactId ];
        system.debug('contact AccountId out'+con);
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=con.accountId;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State/Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=con.accountId;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = con.accountId;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = con.accountId;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        system.debug('techspec in test'+techspec);
        
        
        Test.startTest();
        system.runas(partnerUsr){           
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            //  List<Technology_Specialization__c> TestDataSetUpUtils.createTechSpecInfoRecords();
            Set<String> fedter= CPQUtility.fetchFedTerritories();
            Set<String> slter= CPQUtility.fetchSLTerritories();
            //Set<String> mdOrder= CPQUtility.getOrderType();            
            
            Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
            List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
            List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
            system.debug('partnerUsrAccountId'+partnerUsr.AccountId);
            CPQUtility.fetchAccountDetails(null,con.accountId,lstProspectAccount.get(0).Id);
            CPQUtility.fetchPartnerTerritoryCommission(con.accountId,'Box','Elite Specialis','State/Local Manufacturer Representative');    
        }
        Test.stopTest();   
    }
    
    @isTest 
    static void testUtil3(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        //Test.startTest();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        MetadataCoverageTest.setMetadata('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt'
                                         , (List<FedTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"DOD-West"}]', List<FedTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM SLTerritories__mdt'
                                         , (List<SLTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"T8"}]', List<SLTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt'
                                         , (List<MR_Order_Types_for_CPQ__mdt>) JSON.deserialize('[{"MasterLabel":"Box","Is_Available_for_MRs__c":"true"}]', List<MR_Order_Types_for_CPQ__mdt>.class));
        
        contact con = [SELECT ID,AccountID from Contact where ID =: partnerUsr.ContactId ];
        
        
        system.runas(partnerUsr){
            
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            //  List<Technology_Specialization__c> TestDataSetUpUtils.createTechSpecInfoRecords();
            Set<String> fedter= CPQUtility.fetchFedTerritories();
            Set<String> slter= CPQUtility.fetchSLTerritories();
            //Set<String> mdOrder= CPQUtility.getOrderType();
            
            Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
            List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
            
            system.debug('partnerUsrAccountId'+partnerUsr.AccountId);
            
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
            List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
            Technology_Specialization__c techspec = new Technology_Specialization__c();
            techspec.Account__c = partnerAccount.Id;
            techspec.Partner_Program__c = pgminfo.Id;
            techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
            techspec.Technology_Specialization_Status__c =  'Active';
            techspec.Community_Type__c= 'State/Local Manufacturer Representative';
            insert techspec;
            
            CPQUtility.SpecAndCTypeWrapper specTier = new CPQUtility.SpecAndCTypeWrapper();     
            specTier.mrTierLevel='Elite Specialist';     
            specTier.mrCommunityType='State/Local Manufacturer Representative';
            specTier.territory='T8';
            
            
            CPQUtility.AccountDetailsWrapper accDetailWrap = new CPQUtility.AccountDetailsWrapper();     
            accDetailWrap.customerAccount=lstAccount.get(0);
            accDetailWrap.partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
            accDetailWrap.prospectAccount=lstProspectAccount.get(0);
            accDetailWrap.mrCommunityType='State and Local Manufacturer Representative';
            accDetailWrap.mrAssignedMR='Yes';
            accDetailWrap.mrId='12345';
            accDetailWrap.mrTierLevel='Elite Specialist';
            
            String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
            CPQUtility.fetchAccDetailsForMSILED(mncNumber); 
            CPQUtility.fetchAccountDetails(mncNumber,partnerAccount.Id,null);
            CPQUtility.fetchPartnerIdentifierNumber('T8','Federal',partnerAccount.id);
            CPQUtility.fetchPartnerIdentifierNumber('DOD-West','State and Local',partnerAccount.id);
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void testUtil4(){
        
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        system.debug('partnerAccount in test '+partnerAccount);
        Test.startTest();
        CPQUtility.fetchOrderType(true,partnerAccount.Id);
        CPQUtility.fetchOrderType(false,partnerAccount.Id); 
        CPQUtility.fetchPartnerTerritoryCommission(null,'Box','Elite Specialist','State/Local Manufacturer Representative');
        CPQUtility.fetchPartnerTerritoryCommission(null,'Box','Elite Specialist','Federal Manufacturer Representative');
        Test.stopTest();          
    }
    //CPQ Quote Internal User
    @isTest
    static void testUtil5(){       
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        Id siteID = TestDataSetUpUtils.createSite();
        Test.startTest();
        BigMachines__Quote__c objAccQuote = new BigMachines__Quote__c();
        objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
        objAccQuote.Name='testQuote';
        objAccQuote.BigMachines__Site__c=siteID;
        insert objAccQuote;
        
        BigMachines__Quote__c objOppQuote = new BigMachines__Quote__c();
        objOppQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
        objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
        objOppQuote.Name='testQuote';
        objOppQuote.BigMachines__Site__c=siteID;
        objOppQuote.Represent_Entire_Opportunity__c=true;
        insert objOppQuote;
        List<BigMachines__Quote_Product__c> BQPList = new list<BigMachines__Quote_Product__c>();
        //Insert Quote Product1
        BigMachines__Quote_Product__c    theQP1 = new BigMachines__Quote_Product__c();
        theQP1.Name ='H84WCF9PW6AN';
        theQP1.BigMachines__Quote__c=objOppQuote.id;
        theQP1.BigMachines__Description__c='APX 1000 900MHZ MODEL 2';
        theQP1.Line_number__c='1';
        theQP1.APC__c='0837';
        theQP1.WWAPC__c='5699';
        theQP1.Payment_term__c='30 NET';
        //theQP1.BigMachines__Total_Price__c=Integer.valueOf('3100');
        theQP1.CurrencyIsoCode='USD';
        theQP1.BigMachines__Sales_Price__c=Integer.valueOf('1550');
        theQP1.BigMachines__Quantity__c=Integer.valueOf('1');    
        //insert theQP1;
        BQPList.add(theQP1);
        //Insert Quote Product2
        BigMachines__Quote_Product__c    theQP2 = new BigMachines__Quote_Product__c();
        theQP2.Name ='H84WCF9PW6AB';
        theQP2.BigMachines__Quote__c=objOppQuote.id;
        theQP2.BigMachines__Description__c='APX 1000 900MHZ MODEL 2';
        theQP2.Line_number__c='1';
        theQP2.APC__c='372A';
        //theQP2.WWAPC__c='5699';
        theQP2.Payment_term__c='30 NET';
        //theQP1.BigMachines__Total_Price__c=Integer.valueOf('3100');
        theQP2.CurrencyIsoCode='USD';
        theQP2.BigMachines__Sales_Price__c=Integer.valueOf('1000');
        theQP2.BigMachines__Quantity__c=Integer.valueOf('1');           
        //insert theQP2;     
        BQPList.add(theQP2);
        insert BQPList;
        String Result1;
        //CPQ Button RollupLogic Include in Product Family
        Result1=CPQUtility.upsertOpportunityLineItems('CPQ',objOppQuote.id,objOppQuote.BigMachines__Opportunity__c,'Button');
        CPQUtility.createQuoteProductQTFMapRecs(BQPList);
        //Update Quote Product
        BQPList[1].BigMachines__Quantity__c=Integer.valueOf('2');           
        update BQPList;     
        Test.stopTest();          
    }
    //BidScrub Internal User
    @isTest
    static void testUtil6(){       
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
        
        String Result1;
        //BidScrub Button Load Data
        Result1= CPQUtility.upsertOpportunityLineItems('BidScrub',null,bid.Opportunity__c,null);
        Test.stopTest();          
    }
    
}