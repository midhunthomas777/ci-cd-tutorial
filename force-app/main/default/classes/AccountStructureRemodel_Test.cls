/************************************************************************************************* 
* File Name  : AccountStructureRemodel
* Description: Test class for AccountStructureRemodel class
* Initial development : Saranya Sista
* Modification Log 
* ============================================================================= 
*   Date               Author           Modification 
* ---------------------------------------------------------------------------------------
* 05-May-2018     Saranya Sista(TCS)    Initial Development
* 11-Nov-2018     Suveen Mekala         Addition of test for MNA
*************************************************************************************************/

@isTest
public class AccountStructureRemodel_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c disbltrgr = new TriggerSettings__c(Name = 'CustomerAccountTriggerDisabled' , IsActive__c = TRUE);
        insert disbltrgr;
    }
    
    static testMethod void TestMethod1()
    {
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id partnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prosAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id standardCon = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        User newUser = TestDataSetUpUtils.createInternalUser();
        
        List<Account> cusAcc = TestDataSetUpUtils.createAccounts(3,custRecTypeId);
        cusAcc[0].OwnerId = newUser.Id;
        cusAcc[1].OwnerId = newUser.Id;
        cusAcc[1].ShippingPostalCode = '54321';
        cusAcc[1].ShippingState = 'Illinois';
        cusAcc[1].ShippingCountry = 'United States';
        cusAcc[1].ShippingCity = 'us state';
        cusAcc[1].ShippingPostalCode = '54321';
        cusAcc[2].OwnerId = newUser.Id;
        update cusAcc;
        List<Account> cusAcc1 = TestDataSetUpUtils.createAccounts(1,custRecTypeId);// Added SF-1944
        List<Account> prosAcc = TestDataSetUpUtils.createAccounts(1,prosAccRecTypeId);
        prosAcc[0].OwnerId = newUser.Id;
        update prosAcc[0];
        
        List<Account> mcnAcc = TestDataSetUpUtils.createAccounts(1,mcnRecTypeId);
        mcnAcc[0].Customer_or_Prospect_Account__c = cusAcc[0].id;
        mcnAcc[0].Motorola_Customer_Number__c = '123445';
        update mcnAcc;
        
        List<Contact> conLst = TestDataSetUpUtils.createContacts(1,standardCon,cusAcc);
        List<Contact> conLst1 = TestDataSetUpUtils.createContacts(1,standardCon,cusAcc1);//SF-1944

        Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Account accTest = new Account( Name='Test Account Partner',
                                      RecordTypeId = partnerRecTypeId,BillingStreet='12th Street',
                                      BillingCity='Bangalore',BillingCountry='India',BillingPostalCode='560100',
                                      Motorola_Customer_Number__c=String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Role_Created__c = true,Partner_Region__c='NAMR');
        insert accTest;
        accTest.IsPartner = true;
        update accTest;
        
        Account partneraccTest = new Account( Name='PartnerAcc',RecordTypeId = partnerRecTypeId,BillingStreet='12th Street',
                                             BillingCity='Schaumburg',BillingCountry='United States',BillingState = 'Illinois',
                                             BillingPostalCode='560100',Partner_Region__c='NAMR');
        insert partneraccTest;
        partneraccTest.IsPartner = true;
        update partneraccTest;
        Id PartnrConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partTestCont1 = new Contact(AccountId = partneraccTest.Id,RecordtypeId = PartnrConRecordTypeId,FirstName = 'Test',LastName = 'Partner Contact',FirstNameLocal = 'Test',LastNameLocal = 'Partner Contact',Primary_Contact_Type__c='Sales',Contact_Type__c='sales');
        insert partTestCont1;
        
        
        Account accTestCust = new Account( Name='Test Account Customer',RecordTypeId = custRecTypeId,
                                          BillingStreet='12th Street',BillingCity='Schaumburg',BillingCountry='United States',
                                          BillingState = 'Illinois',BillingPostalCode='560100',Industry = 'Manufacturing',
                                          Region__c  = 'NA', Territory__c='DOD-East',Parentid=accTest.id,
                                         Motorola_Customer_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100));
        insert accTestCust;
        
        Account accTestMCN1 = new Account(Name='Test Account MCN1', RecordTypeId = mcnRecTypeId,
                                          ParentId = accTestCust.Id, Customer_or_Prospect_Account__c = accTestCust.Id,
                                          BillingStreet='12th Street',BillingCity='Schaumburg', ERP_Active__c = TRUE,
                                          BillingCountry='United States', BillingState = 'Illinois', BillingPostalCode='56010',
                                          Motorola_Customer_Number__c='10000123',Primary_Route_to_Market__c = 'MR Led',Assigned_MR__c = partneraccTest.id,
                                          Assigned_MR_Sales_Person__c = partTestCont1.id);
        insert accTestMCN1;
        
        Opportunity Opplist = new Opportunity();
        Opplist.Name = 'testOppty';
        Opplist.StageName = 'Prospect';
        Opplist.Description='Testing';
        Opplist.closedate = System.today() + 30;                                             
        Opplist.AccountId= accTestCust.Id;
        Opplist.Status__c='Active';
        Opplist.recordtypeid = recId;
        Opplist.CDH_Account__c = accTestMCN1.Id;
        Opplist.Country__c = 'United States';            
        Opplist.Region__c= 'NA';
        Opplist.State__c = 'Alabama';
        Opplist.Territory__c = 'T1';
        insert Opplist;
        
        Note newNote = new Note(Body = 'Test Note',Title = 'Test Addition',ParentId = cusAcc[0].Id);
        insert newNote;
        List<Note> note =  new List<Note>();
        note.add(newNote);
        
        
        //ID SiteId='a5Q340000001M5hEAE';
        Id siteID = TestDataSetUpUtils.createSite();
        BigMachines__Quote__c theQuote1 = new BigMachines__Quote__c();   
        theQuote1.Name ='CPQ-0001';       
        theQuote1.BigMachines__Account__c=cusAcc[0].Id;
        theQuote1.Motorola_Customer_Number__c = mcnAcc[0].Motorola_Customer_Number__c;
        theQuote1.BigMachines__Status__c='In Progress';
        theQuote1.BigMachines__Site__c = SiteId;
        theQuote1.BigMachines__status__c='Finalized';
        //theQuote1.BigMachines__Opportunity__c=Opplist.id;
        insert theQuote1;
        
        BigMachines__Quote__c theQuote2 = new BigMachines__Quote__c();   
        theQuote2.Name ='CPQ-0001';       
        theQuote2.BigMachines__Account__c=cusAcc[0].Id;
        theQuote2.Motorola_Customer_Number__c = mcnAcc[0].Motorola_Customer_Number__c;
        theQuote2.BigMachines__Status__c='In Progress';
        theQuote2.BigMachines__Site__c = SiteId;
        theQuote2.BigMachines__status__c='Finalized';
        theQuote2.BigMachines__Opportunity__c=Opplist.id;
        insert theQuote2;
        
        String oldfoldername = cusAcc[1].Id+'_'+cusAcc[1].Name;
        String newfoldername = cusAcc[2].Id+'_'+cusAcc[2].Name;
        List<AccountGoogleDriveList__c> GoogleLst = new  List<AccountGoogleDriveList__c>();
        AccountGoogleDriveList__c oldAccGoogleLst = new AccountGoogleDriveList__c();
        oldAccGoogleLst.CPQQuoteArchiveFolderId__c = '1112334';
        oldAccGoogleLst.CurrentYear__c = System.Today().year();
        oldAccGoogleLst.GoogleFolderName__c = oldfoldername;
        oldAccGoogleLst.CurrentYearFolderId__c = '1313';
        oldAccGoogleLst.GoogleFolderID__c = '456788';
        GoogleLst.add(oldAccGoogleLst);
        
        Apttus__APTS_Agreement__c aptsAgrmt = new Apttus__APTS_Agreement__c();
        //Id ssRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Services_Solutions').getRecordTypeId(); 
        aptsAgrmt.Apttus__Account__c = cusAcc[1].Id;
        //aptsAgrmt.recordTypeID = ssRecordTypeId;
        aptsAgrmt.Apttus__Related_Opportunity__c = Opplist.id;
        insert aptsAgrmt;
        
        AccountGoogleDriveList__c newAccGoogleLst = new AccountGoogleDriveList__c();
        newAccGoogleLst.CPQQuoteArchiveFolderId__c = '1112334';
        newAccGoogleLst.CurrentYear__c = System.Today().year();
        newAccGoogleLst.GoogleFolderName__c = newfoldername;
        newAccGoogleLst.CurrentYearFolderId__c = '1313';
        newAccGoogleLst.GoogleFolderID__c = '456788';
        GoogleLst.add(newAccGoogleLst);
        insert GoogleLst;
        
        List<String> quoteFileIds = new  List<String>();
        quoteFileIds.add(theQuote1.id);
        quoteFileIds.add(theQuote2.id);
        
       // test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        AccountStructureRemodel.createNewCustomer(cusAcc[0].id);
        AccountStructureRemodel.restructureTheMCNaccount(mcnAcc[0].id);
        AccountStructureRemodel.quotesInGoogle(cusAcc[1].Id,cusAcc[2].Id);
       // test.stopTest();
        List<Account> custLst = new List<Account>();
        custLst.add(cusAcc[0]);
        custLst.add(cusAcc[1]); 
        AccountStructureRemodel.createCustomersFromMCNs(custLst); //Added for MNA project
        AccountStructureRemodel.createCustomerAccount(cusAcc[0]);
        AccountStructureRemodel.createCustomerAccount(cusAcc[1]);
        //AccountStructureRemodel.createContactRoles(cusAcc[0],conLst);
        AccountStructureRemodel.createContactRoles(cusAcc[0],conLst1);// SF-1944

        HttpRequest req = new HttpRequest();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        Test.startTest();
        HttpResponse res = mock.respond(req);
        try{
        AccountStructureRemodel.createAndShareGDFolder(GoogleLst[0].GoogleFolderName__c,'testtoken',GoogleLst[0].id,'test@gmail.com',GoogleLst[0]);
        }catch(Exception exp){}
        try{
            AccountStructureRemodel.getChildrenFiles(newAccGoogleLst.GoogleFolderID__c);
        } catch(Exception exp){}
        try{
            AccountStructureRemodel.copyQuotesToFolder(quoteFileIds,newAccGoogleLst.GoogleFolderID__c);
        } catch(Exception exp){}
        try{
        AccountStructureRemodel.PermissionClass pmclassinner = new  AccountStructureRemodel.PermissionClass('role','type','value');
        } catch(Exception exp){}
        Test.stopTest();
        AccountStructureRemodel.insertLogRecord('error',cusAcc[0].Id);
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(Opplist.id);
        AccountStructureRemodel.reParentOpportunies(accTestCust.Id,accTestMCN1.id,oppIdSet);
   }
}