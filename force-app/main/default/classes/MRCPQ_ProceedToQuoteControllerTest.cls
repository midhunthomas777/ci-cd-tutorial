@isTest
public class MRCPQ_ProceedToQuoteControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    @isTest
    public static void test_ProceedToQuote(){
        Id projectRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id accrectypeIDPartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> partnerlstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeIDPartner);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        
        List<Opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1,projectRecTypeId,lstAccount);
        opportunityList.get(0).Purchasing_Entity__c = null;
        opportunityList.get(0).CDH_Account__c = lstMCNAccount[0].Id;
        update opportunityList;
        List<SubAgency__c> subAccsList = TestDataSetUpUtils.createSubAccounts(1, opportunityList.get(0).Id, lstAccount.get(0).Id); 
        List<SubAgency__c> insertedSubAccsList = [SELECT ID,Opportunity__c FROM SubAgency__c WHERE Opportunity__c =:opportunityList.get(0).Id];
        insertedSubAccsList.get(0).Billing_Agency__c = null;
        update insertedSubAccsList;
        Product2 prd = new Product2(ECW_shortcut__c=true, Name='Test Product Entry 1',Description='Test Product Entry 1',
                                    productCode = 'ABC', isActive = true,Personal_Information__c='Yes',
                                    Needs_FTE_for_Quote__c=true);
        insert prd;
        PricebookEntry priceBook = new PricebookEntry(Product2ID=prd.Id, Pricebook2ID=Test.getStandardPricebookId(),
                                                      UnitPrice=50, isActive=true);
        insert priceBook;
        
        OpportunityLineItem OLI = new OpportunityLineItem(OpportunityID=opportunityList.get(0).id,quantity=4,totalprice=200,
                                                          PriceBookEntryID=priceBook.Id);
        insert OLI;
        
        User partneruser= TestDataSetUpUtils.createPortalUser();
        Test.startTest();
        system.runAs(partneruser){
            List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
            MRCPQ_ProceedToQuoteController.fetchSitePrefix();
            MRCPQ_ProceedToQuoteController.getPartnerCommissionDetails('Box','Elite Specialist','State/Local Manufacturer Representative');
            MRCPQ_ProceedToQuoteController.getAccountDetails(mncNumber,lstAccount.get(0).Id,partnerlstAccount.get(0).id);
            MRCPQ_ProceedToQuoteController.getAccountDetails(mncNumber,lstAccount.get(0).Id,null);
            MRCPQ_ProceedToQuoteController.createCPQSession(lstAccount.get(0).Id,lstMCNAccount.get(0).Id,2.2,'1254','Box',lstOpportunity.get(0).Id,'TEST','');
            MRCPQ_ProceedToQuoteController.fetchOrderType();
            MRCPQ_ProceedToQuoteController.getMCN(lstOpportunity.get(0).Id);
            MRCPQ_ProceedToQuoteController.getMCN(lstProspectAccount.get(0).Id);
            MRCPQ_ProceedToQuoteController.getMCN(lstAccount.get(0).Id);
            MRCPQ_ProceedToQuoteController.fetchQuoteAccess();
            MRCPQ_ProceedToQuoteController.canCreateQuoteFromAcc();
        }
        MRCPQ_ProceedToQuoteController.fetchSitePrefix(); 
        try{
            MRCPQ_ProceedToQuoteController.isValidOpp(opportunityList.get(0).Id,UserInfo.getUserId());
        }catch(Exception ex){}
        Test.stopTest();
    }
    @isTest
    public static void test_ProceedToQuote2(){
        Id projectRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id partnerAccRectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Account> lstAccount1 = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> partnerAccLst = TestDataSetUpUtils.createAccounts(1, partnerAccRectypeID);
        List<Opportunity> opportunityList1 = TestDataSetUpUtils.createOpportunities(2,projectRecTypeId,lstAccount1);
        opportunityList1[0].Purchasing_Entity__c = lstAccount1.get(0).Id;
        opportunityList1[1].Purchasing_Entity__c = null;
        update opportunityList1;
        List<Partners2__c> oppPartners = TestDataSetUpUtils.createPartnersWithOpp(1, opportunityList1,partnerAccLst,'Channel Partner');
        List<SubAgency__c> subAccsList = TestDataSetUpUtils.createSubAccounts(1, opportunityList1.get(1).Id, lstAccount1.get(0).Id); 
        List<SubAgency__c> insertedSubAccsList = [SELECT ID,Opportunity__c FROM SubAgency__c WHERE Opportunity__c =:opportunityList1.get(1).Id];
        System.debug('Before Insert SubAccs...'+insertedSubAccsList);
        insertedSubAccsList.get(0).Billing_Agency__c = null;
        //update insertedSubAccsList;
        System.debug('Before Update SubAccs...'+insertedSubAccsList);
        Product2 prd1 = new Product2(ECW_shortcut__c=true, Name='Test Product Entry 2',Description='Test Product Entry 2',
                                     productCode = 'ABC', isActive = true,Personal_Information__c='Yes',
                                     Site_Required_for_Quoting__c=true);
        insert prd1;
        PricebookEntry priceBook1 = new PricebookEntry(Product2ID=prd1.Id, Pricebook2ID=Test.getStandardPricebookId(),
                                                       UnitPrice=200, isActive=true);
        insert priceBook1;
         List<OpportunityLineItem> OLILst = new List<OpportunityLineItem>();
        OpportunityLineItem OLI1 = new OpportunityLineItem(OpportunityID=opportunityList1.get(0).id,quantity=4,totalprice=200,
                                                           PriceBookEntryID=priceBook1.Id);
        OLILst.add(OLI1);
       OpportunityLineItem OLI2 = new OpportunityLineItem(OpportunityID=opportunityList1.get(1).id,quantity=4,totalprice=500,
                                                          PriceBookEntryID=priceBook1.Id);
        OLILst.add(OLI2);
        insert OLILst;
        Id siteID = TestDataSetUpUtils.createSite();  
        Test.startTest();
        MRCPQ_ProceedToQuoteController.getMCN(opportunityList1.get(0).Id);
        MRCPQ_ProceedToQuoteController.getMCN(oppPartners.get(0).Id);
        MRCPQ_ProceedToQuoteController.fetchQuoteAccess(); //Running as normal user(not a partner user)
        MRCPQ_ProceedToQuoteController.canCreateQuoteFromAcc();
        MRCPQ_ProceedToQuoteController.fetchCPQSiteId();
        try{
            MRCPQ_ProceedToQuoteController.isValidOpp(opportunityList1.get(0).Id,UserInfo.getUserId());
            MRCPQ_ProceedToQuoteController.isValidOpp(opportunityList1.get(1).Id,UserInfo.getUserId());
            MRCPQ_ProceedToQuoteController.isValidOpp(oppPartners.get(0).Id,UserInfo.getUserId());
        }catch(Exception ex){}
        Test.stopTest();
    }
    
}