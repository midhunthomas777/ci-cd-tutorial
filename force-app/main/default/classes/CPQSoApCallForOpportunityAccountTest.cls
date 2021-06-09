@IsTest
private class CPQSoApCallForOpportunityAccountTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void testMyWebSvc()
    {
        //Inset Product1
        Product2 theprod = new Product2(Name = 'ASTRO Devices1');
        insert theprod;
        
        //Inset Product2
        Product2 theprod1 = new Product2(Name = 'Si Series BodyWorn Video Speaker Mic');
        insert theprod1;
        Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry for AstroDevice1 StandardPricebook 
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = theprod.Id, CurrencyIsoCode='USD', UnitPrice = 0, IsActive = true);
        insert standardPrice;
        //PricebookEntry for Si Series BodyWorn Video Speaker Mic StandardPricebook
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = theprod1.Id, CurrencyIsoCode='USD', UnitPrice = 0, IsActive = true);
        insert standardPrice1;
        User thisUser = [SELECT Id,Core_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account> acParent=new List<Account>();
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount'); //customer
        Account accTest1 = new Account(Name = 'Test Customer Quote1',
                                       Type='Customer',
                                       Billingcity='Test',
                                       ownerId=thisUser.Id,
                                       RecordTypeId=custRecTypeId,
                                       Region__c ='NA',
                                       Territory__c='T1',
                                       Billingcountry ='United States',
                                       BillingState = 'Illinois',
                                       Industry='Public Services (non-Public Safety Government)'
                                      );
        insert accTest1;
        acParent.add(accTest1);
        Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Account mcnTest1 = new Account(Name = '1011138915',
                                       ParentId =accTest1.ID,
                                       ownerId=thisUser.Id,
                                       RecordTypeId=mcnRecTypeId,
                                       Motorola_Customer_Number__c='1011138915',
                                       ERP_Active__c   =True
                                      );
        insert mcnTest1;
        String dt ='12/31/2016';  
        date CloseDT=date.parse(dt);  
        Id projectRecTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Government_Standard');
        Opportunity oppTest1 = new Opportunity(Name = 'City of Charlotte TESTOPP',
                                               RecordTypeId=projectRecTypeId,
                                               //CDH_Account__c =mcnTest1.ID ,
                                               AccountId = accTest1.ID,      
                                               StageName ='Prospect',  
                                               ForecastCategoryName ='Non Commit',
                                               Status__c ='Active',
                                               Industry__c ='Public Services (non-Public Safety Government)',
                                               Who_is_the_Incumbent__c='MSI',
                                               Channel_Opportunity__c ='Direct',
                                               Business_Group__c ='EMEA Government System Project',
                                               CloseDate = Date.today() + 60,
                                               Region__c='NA',
                                               Country__c = 'United States',
                                               State__c = 'Missouri',
                                               Territory__c = 'T6',
                                               Pricebook2Id =pricebookId,
                                               CurrencyIsoCode='USD' );
        
        insert oppTest1;
        UserSessionCPQ__c theUSCPQ=new UserSessionCPQ__c();
        theUSCPQ.Account_ID__c=accTest1.ID;
        theUSCPQ.CDH_Account_ID__c=mcnTest1.Id;
        theUSCPQ.Opportunity_Id__c = oppTest1.Id;
        theUSCPQ.User_Id__c=thisUser.Id;
        insert theUSCPQ;
        
        Id prosAccRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Prospect');
        test.startTest();
        Account accTest2 = new Account(Name = 'Test Prospect Quote1',                                        
                                       ownerId=thisUser.Id,
                                       Region__c='NA',
                                       Industry = 'Manufacturing',
                                       Billingcity='test',
                                       BillingCountry='United States',
                                       RecordTypeId=prosAccRecTypeId,
                                       Territory__c='T6'  ,Billing_County__c = 'US'                                      
                                      );
        insert accTest2;
        Opportunity oppTest2 = new Opportunity(Name = 'City of Charlotte TESTOPP',
                                               RecordTypeId=projectRecTypeId,
                                               //CDH_Account__c =mcnTest1.ID ,
                                               AccountId = accTest2.ID,      
                                               StageName ='Prospect',  
                                               ForecastCategoryName ='Non Commit',
                                               Status__c ='Active',
                                               Industry__c ='Public Services (non-Public Safety Government)',
                                               Who_is_the_Incumbent__c='MSI',
                                               Channel_Opportunity__c ='Direct',
                                               Business_Group__c ='EMEA Government System Project',
                                               CloseDate=CloseDT,
                                               Region__c='NA',
                                               Country__c = 'United States',
                                               State__c = 'Missouri',
                                               Territory__c = 'T6',
                                               Pricebook2Id =pricebookId,
                                               CurrencyIsoCode='USD' );
        
        insert oppTest2;
        UserSessionCPQ__c theUSCPQ1=new UserSessionCPQ__c();
        theUSCPQ1.Account_ID__c=accTest2.ID;
        //theUSCPQ1.CDH_Account_ID__c=mcnTest2.Id;
        theUSCPQ1.User_Id__c=thisUser.Id;
        insert theUSCPQ1;
        Id prospectaccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();        
        User partnerUsr= TestDataSetUpUtils.createPortalUser();
        TestDataSetUpUtils.assignPermissionSet(partnerUsr.Id);
        
        //Customer Account
        String stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,accTest1.ID,null);
        stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,null,oppTest1.Id);       
        
        CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,accTest1.ID,oppTest1.Id);
        CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,accTest1.ID,oppTest1.Id);
        
        //Prospect Account
        stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,accTest2.ID,null);
        System.debug('StrACC Valid User ' + stract);
        
        stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess(thisUser.Core_ID__c,null,null,oppTest2.Id);       
        System.debug('StrACC Valid User ' + stract); 
        test.stopTest();
        String dt1 ='12/4/2021';  
        Date ValidityDT = Date.parse(dt1);
        //Partner Prospect Quote Creation
        system.runAs(partnerUsr){  
            Id siteID = TestDataSetUpUtils.createSite();
            List<Account> lstProspectAccount = TestDataSetUpUtils.createProspectAccounts(1, prospectaccrectypeID);
            //UserSessionCPQ 
            UserSessionCPQ__c thePartnerUSCPQ1=new UserSessionCPQ__c();
            thePartnerUSCPQ1.Account_ID__c=lstProspectAccount.get(0).Id;
            thePartnerUSCPQ1.User_Id__c=partnerUsr.Id;
            insert thePartnerUSCPQ1;            
            system.debug('prospect acc -' +lstProspectAccount.get(0).Id + '----partneruser' + partnerUsr.Core_ID__c);
            //Prospect Quote
            BigMachines__Quote__c theQuote1 = new BigMachines__Quote__c();
            theQuote1.Name ='CPQ-99991';
            theQuote1.BigMachines__Account__c=lstProspectAccount.get(0).Id;
            theQuote1.Customer_Bill_To__c='115553';
            theQuote1.Validity_Date_Effective_Until_Date__c=ValidityDT;
            theQuote1.CurrencyIsoCode='USD';
            theQuote1.BigMachines__Status__c='In Progress';
            theQuote1.RevisionNumber__c='0';
            theQuote1.BigMachines__Site__c=siteID;
            theQuote1.Motorola_Customer_Number__c = '1011138915';
            insert theQuote1;
            
            stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess(partnerUsr.Core_ID__c,null,lstProspectAccount.get(0).Id,null);
            System.debug('StrACC Partner Prospect Valid User ' + stract);
        }
        
        //Null Check      
        stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess('Anitha',null,accTest1.ID,null);
        System.debug('StrACC Invalid User' + stract);
        
        stract =   CPQSoApCallForOpportunityAccount.GetrecordAccess('Anitha',null,null,oppTest1.Id);       
        System.debug('StrACC Invalid User' + stract);
        
        stract =  CPQSoApCallForOpportunityAccount.commissionPercentRecal(theUSCPQ1.id,10.0,2.0,true,'Box');
        
        
    }
    
}