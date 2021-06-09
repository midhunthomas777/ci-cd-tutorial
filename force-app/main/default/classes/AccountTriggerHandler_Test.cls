@isTest
private class AccountTriggerHandler_Test {

    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.loadGoogleDriveTestData();
        Test.startTest();
        TestDataSetUpUtils.getBRRs();
        Test.stopTest();

    }

    @isTest static void terrPopulation(){
        Id partnerId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id contactPartnerId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        test.startTest();
        List<Account> acc = TestDataSetUpUtils.createAccounts(1,partnerId);
        List<Contact> cont = TestDataSetUpUtils.createContacts(1,contactPartnerId, acc);
        user usr = TestDataSetUpUtils.createPartnerAdministrator(cont[0].id,'NAMR');
        system.runAs(usr){
            //List<Account> accList = TestDataSetUpUtils.createPartnerProspectAccounts(1,'IL','Chicago','Chicago');
            List<Account> accCountyList = TestDataSetUpUtils.createPartnerProspectAccounts(1,'CA','LA','Los Angeles');
        }
        test.stopTest();
    }

    @isTest static void testMCNInactivation(){
        Id customerRTId =  GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount'); //customer
        Id mcnRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Test.startTest();
        List<Account> custAcclist = TestDataSetUpUtils.createAccounts(1, customerRTId);
        List<Account> mcnAcclist = TestDataSetUpUtils.createAccounts(1, mcnRecId);
        Test.stopTest();
        mcnAcclist[0].Validation_Status__c='OBSOLETE';
        mcnAcclist[0].parentId=custAcclist[0].id;
        update mcnAcclist;
        delete custAccList;
        delete mcnAcclist;
    }

    @isTest static void mcnCreation(){
        Id prospectId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Prospect');
        Id mcnRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Id partnerRTId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id partContact = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        Id userId = [select Id from User where isActive=true and profile.name='system administrator' limit 1].Id;
        Account Ac = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',Territory__c='T1',
                                billingcountrycode ='US',RecordTypeID=prospectId,BillingPostalCode='1234',
                                Billingcity='Test',Sic = '1041',Billing_County__c='US');
        insert Ac;
        ac.BillingCity='test2';
        ac.BillingPostalCode='01234';
        ac.billingStreet='tests2';
        ac.Billingstatecode='IL';
        update ac;
        test.startTest();
        Account Ac1 = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',Territory__c='T1',
                                billingcountrycode ='US',RecordTypeID=prospectId,BillingPostalCode='1234',
                                Billingcity='Test',Sic = '1041',Billing_County__c='US');
        insert Ac1;

        List<Account> PartnerAcclist = TestDataSetUpUtils.createAccounts(1, partnerRTId);

        Account InsertMCN = new Account();
        InsertMCN.Name='TestMCN Record';
        InsertMCN.RecordTypeId = mcnRecId;
        InsertMCN.parentid = Ac.id;
        InsertMCN.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCN.Motorola_Customer_Number__c = '5555522';
        InsertMCN.ShippingCountry='United States';
        InsertMCN.ShippingState = 'Illinois';
        InsertMCN.Type = 'Direct Customer';
        InsertMCN.CDH_Owner_CoreID__c=null;

        insert InsertMCN;
        InsertMCN.Type ='State & Local';
        InsertMCN.CDH_Owner_CoreID__c='ABC123';
        InsertMCN.ParentId=Ac1.ID;
        InsertMCN.Is_Primary__c=true;
        InsertMCN.BillingCountry='United States';
        InsertMCN.BillingState = 'Illinois';
        InsertMCN.Motorola_Customer_Number__c = '55565522';
        //InsertMCN.Assigned_Inside_Sales_Person__c=userId;
        update InsertMCN;

        Account mcn = [SELECT Id,Is_Primary__c FROM Account WHERE ParentId = :Ac1.Id LIMIT 1];
        mcn.Is_Primary__c=true;
        mcn.ShippingCountry='United States';
        mcn.ShippingState = 'California';
        mcn.Type = 'Direct';
        update mcn;
        mcn.Is_Primary__c=false;
        update mcn;
        mcn.Is_Primary__c=True;
        mcn.CDH_Owner_CoreID__c = 'CPJ678';
        mcn.ShippingCountry='';
        mcn.ShippingState = '';
        mcn.BillingCountry = 'United States';
        mcn.BillingState = 'Texas';
        update mcn;
        mcn.Is_Primary__c=false;
        update mcn;
        mcn.Is_Primary__c=True;
        mcn.ShippingCountry='United States';
        mcn.ShippingState = 'New York';
        mcn.ownerId=  userId;
        update mcn;

        delete InsertMCN;


        Account patr = new Account();
        patr.Id= PartnerAcclist.get(0).Id;
        patr.Applications_Enabled__c='CPQ';
        patr.Hierarchy_Placement__c='Regional Account';
        patr.Partner_Zone__c='0';
        patr.MPE_Program_Status_New__c = 'Active';
        patr.Partner_Region__c='NAMR';
        patr.Program_Join_Date__c=Date.today();
        update patr;

        patr.PartnerEmpower_Inactivated_Date__c=Date.today()+2;
        patr.PartnerEmpower_Reactivated_Date__c=Date.today()+4;
        patr.Program_Level_Community__c='Value Added Reseller';
        patr.Partner_Region__c='EMEA';
        update patr;

        HttpRequest req = new HttpRequest();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        HttpResponse res = mock.respond(req);
        /*Case cse = [select id from case where accountid= :Ac.Id];
        delete cse;
        delete Ac;*/
        delete patr;

        List<Account> mcnAcclist = TestDataSetUpUtils.createAccounts(1, mcnRecId);

        //mcnAcclist[0].Primary_Route_to_Market__c = 'Open';
        //mcnAcclist[0].Assigned_Inside_Sales_Person__c=userId;
        update mcnAcclist;
        test.stopTest();

    }
    @isTest static void checkArchieved(){
        Id prospectId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Prospect');
        Id archiveRecordtypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Archived');
        Test.startTest();
        Account Ac = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',
                                Territory__c='T1',billingcountrycode ='US',
                                RecordTypeID=prospectId,BillingPostalCode='1234',Billingcity='Test',
                                Sic = '1041',Billing_County__c='US');
        insert Ac;
        Test.stopTest();
        Ac.RecordTypeId=archiveRecordtypeId;
        update Ac;
    }
    // Added by venkat as per story SF-1978
    @isTest static void restrictDeleteTest(){
        Test.startTest();
        try{
            Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
            List<Account> cusAcc = TestDataSetUpUtils.createAccounts(3,custRecTypeId);
            Apttus__APTS_Agreement__c aptsAgrmt = new Apttus__APTS_Agreement__c();
            aptsAgrmt.Apttus__Account__c = cusAcc[1].Id;
            insert aptsAgrmt;
            Delete cusAcc[1];
        }
        catch(exception e) {}
        Test.stoptest();
    }

    @isTest static void assignPartner(){
        //TestDataSetUpUtils.insertCustomSettings();
        Id partnerRTId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id partContact = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        List<Account> partnerAcclist = TestDataSetUpUtils.createAccounts(1, partnerRTId);
        List<Contact> lstContact = TestDataSetUpUtils.createContacts(1,partContact,PartnerAcclist);
        partnerAcclist.get(0).Radio_Leads__c = True;

        Update partnerAcclist;

        lstContact.get(0).Tag__c='SFDC Partner Admin';

        Update lstContact;
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'EMS Partner Administrator Profile NAMR' or name = 'System Administrator'];
        for(Profile p : ps) {
            profiles.put(p.name, p.id);
        }
        User partnerUsr = new User(alias = 'partusr',email='standarduser@motrolasolutions.com',emailencodingkey='UTF-8',
                                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', contactId=lstContact.get(0).Id,
                                profileid = profiles.get('EMS Partner Administrator Profile NAMR'),timezonesidkey='America/Los_Angeles',
                                username='partnerusr@motrolasolutions.com',CommunityNickname='pusr1', FederationIdentifier='partnerusr@motrolasolutions.com',
                                Core_ID__c='partnerusr@motrolasolutions.com',IsActive = True);
        insert partnerUsr;

        List<Lead> leadlst = TestDataSetUpUtils.createLeadRecords(2);
        leadlst.get(0).Track__c='Radio';
        leadlst.get(0).Partner_Account_NA__c=lstContact.get(0).AccountId;
        leadlst.get(0).Partner_Email_Sent__c='Email Pending';
        update leadlst;
        Test.stopTest();
        List<Id> leadIds = new List<Id>();
        leadIds.add(leadlst.get(0).Id);
        //System.debug('leadlst.get(0)===>'+leadlst.get(0));
        MassActionLeadPartnerSendEmail.sendMailsToCon(leadIds);
    }
    @isTest static void test_ldapContact() {
        //LDAP_Settings__c newLDAPSetting =  ldapContactTest.createLDAPSettings();
        //MPE_Preferred_Languages__c newMPELangSetting =  ldapContactTest.createMPEPreferredLangSettings();
        LDAP_Settings__c newSetting = new LDAP_Settings__c();
        newSetting.name = 'Current';
        newSetting.Authentication__c = 'Basic';
        newSetting.Disable_Emails__c = false;
        newSetting.Disable_Triggers__c = false;
        newSetting.Endpoint__c = 'https://wsgw-uat.motorolasolutions.com:443/';
        newSetting.Exception_Recipients__c = 'test@motorolasolutions.com';
        newSetting.New_Partner_Template_ID__c = 'testPartberUd';
        newSetting.Send_Address__c = true;
        newSetting.Send_Company_Attribute__c = true;
        newSetting.Send_Language_Attribute__c = true;
        newSetting.Update_Template_ID__c = 'test';
        insert newSetting;

        MPE_Preferred_Languages__c newSettings = new MPE_Preferred_Languages__c();
        newSettings.Name = 'English';
        newSettings.Sub_Language_Id__c = 'ENU';
        insert newSettings;

        Test.startTest();
        //Test data creation for ADP_Global_Account_Name__c object
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        ADP_Global_Account_Name__c adpGlobalAcc = new ADP_Global_Account_Name__c();
        adpGlobalAcc.Name = uniqueName;
        adpGlobalAcc.GitLab_Group_Id__c = 123456789;
        adpGlobalAcc.GoogleFolderID__c = 'testId';
        insert adpGlobalAcc;

        //Test data creation for Account object
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                                                                                                        AND DeveloperName = 'Partner' LIMIT 1];
        Account acc1 = new Account();
        acc1.Name = 'account1';
        acc1.Type = 'Partner';
        acc1.RecordTypeId = recType.Id;
        acc1.Shared_Partner__c=true;
        acc1.Metal_Level__c = 'gold';
        acc1.Partner_Region__c = 'NAMR';
        acc1.BillingCountry='India';
        acc1.BillingPostalCode='1234';
        acc1.Owner_Business_Group__c='Government';
        acc1.Partner_HQ_Country__c='India';
        acc1.Status__c='Active';
        acc1.MPE_Program_Status_New__c='Active';
        acc1.ADP_Global_Account_Name1__c = adpGlobalAcc.Id;
        acc1.ADP_Partner__c = true;
        acc1.ADP_Technology_Segment__c = 'ASTRO;DIMETRA';
        acc1.Primary_Distributor__c = 'Avantis Sweden;Quonex';
        insert acc1;

        //Test data creation for Contact object
        Contact conObj1 = new Contact();
        conObj1.FirstName = 'test';
        conObj1.LastName = 'contact1';
        conObj1.Primary_Contact_Type__c = 'Developer';
        conObj1.Contact_Type__c = 'Technician';
        conObj1.Tag__c = 'ADP;SFDC Partner Admin';
        conObj1.AccountId = acc1.Id;
        conObj1.Email='test@test.com';
        conObj1.MailingStreet = 'testmailingstreet';
        conObj1.Preferred_Language__c = 'English';
        insert conObj1;

        //Test data creation for Market_Specializations__c object
        Market_Specializations__c marketSpecialization  = new Market_Specializations__c(
            Market_Specialization_Level__c='Authorized',
            Market_Specialization__c = 'US Federal',
            Account__c = acc1.Id);
        insert marketSpecialization;

        //Test data creation for Partner_Type__c object
        Partner_Type__c pt1 = new Partner_Type__c(Account__c = acc1.Id, Program__c = 'RADIO',
                                                Purchasing_Method__c='Tier 1',Status__c='Active',Partner_Track__c='Reseller');
        insert pt1;

        //Test data creation for Technology_Specialization__c object
        Technology_Specialization__c techSpec1 = new Technology_Specialization__c(Partner_Program__c = pt1.Id,
                                                                                Account__c=acc1.Id,
                                                                                Technology_Specialization__c='Professional and Commercial Radio',
                                                                                Community_Type__c='Application Partner',
                                                                                Technology_Specialization_Status__c ='Active',
                                                                                Technology_Specialization_Level__c='Authorized',
                                                                                TechnologySubSegment__c='MOTOTRBO',
                                                                                Type__c = 'Application');
        insert techSpec1;

        //Test data creation for Technology_SubSegment__c object
        Technology_SubSegment__c techSubSegment = new Technology_SubSegment__c(Account__c=acc1.Id,
                                                                            Program_Detail__c=techSpec1.Id,
                                                                            Segment__c='Professional and Commercial Radio',
                                                                            Sub_Segment__c='MOTOTRBO Capacity Max');
        insert techSubSegment;
        Test.stopTest();
        //Creating ldapContact controller instance and calling its methods
        ldapContact ctrlInstance = new ldapContact(conObj1.Id);
        ctrlInstance.getCreateString();
        ctrlInstance.getUpdateString();
        ctrlInstance.getUpdateExString('inputString');
        ctrlInstance.getInitCreateString();
        ctrlInstance.getUserEnable();
        ctrlInstance.getAdminUserEnable();
        ctrlInstance.getUserDisable();
        ctrlInstance.getContactInactivate('inputString');
        ctrlInstance.getInitPassword();
    }

    @isTest static void CustandMCNAccountSharing_Test() {
        Id prospectId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Prospect');
        Id PartnerId =GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id mcnRecId =GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Account Ac = new Account(Name='TestV',billingcountrycode ='IN',RecordTypeID=prospectId,BillingPostalCode='1234',Billingcity='Test',Region__c='NA',Territory__c='T2');
        Insert Ac;
        Set<Id> Accid = new Set<Id>();
        Accid.add(Ac.id);
        List<Account> prosLst = new List<Account>(); prosLst.add(Ac);
        Account Acc1 = new Account(Name='TestVAccount',Role_Created__c=true,RecordTypeID=PartnerId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc1;
        Account Acc2 = new Account(Name='TestVAccount12',Role_Created__c=true,RecordTypeId=PartnerId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc2;
        Test.startTest();
        Account Acc12 = [select id from Account where id=:Acc2.id];
        System.debug('Inserted account Ispartner ---'+Acc2.Ispartner);
        Acc12.Ispartner = true;
        update Acc12;
        Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,Primary_Contact_Type__c='sales',
                                Email='contact1@mail.com');
        Insert C1;
        Contact C2 = new contact(FirstName='second',LastName='Last',Accountid=Acc2.id,Primary_Contact_Type__c='sales',
                                Email='contact2@mail.com');
        Insert C2;
        //Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile partnepro = [SELECT Id FROM Profile WHERE Name = 'EMS Partner Administrator Profile NAMR'];
        User usr1 = new User(Alias = 'standt1', Email='standarduser1@motorolasolutions.com',
                            EmailEncodingKey='UTF-8', FirstName='VTest1',LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='sssstandarduser@motorolasolutions.com',Core_ID__c='TTTT',
                            CommunityNickname='TTTT',  FederationIdentifier='TTTT',
                            EmployeeNumber = 'TTTT');
        insert usr1;
        Acc1.ownerId = usr1.id;
        update Acc1;
        User usr = new User(Alias = 'standt', Email='standarduser@motorolasolutions.com',
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser1@motorolasolutions.com',
                            core_id__c='BBBB', CommunityNickname='BBBB',FederationIdentifier='BBBB',
                            EmployeeNumber = 'BBBB');
        insert usr;
        user partusr = new user(Alias = 'standt', Email='S0001@justignoreorg.com',
                                EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = partnepro.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testahh@T.com',
                                core_id__c='Test1232',ContactId=C2.id,isactive=TRUE);
        insert partusr;
        UserRole ur = new UserRole(PortalType = 'Partner', PortalAccountId = acc2.Id);
        List<Account> mcnLst =TestDataSetUpUtils.createMCNAccounts(1, mcnRecId, prosLst);
        mcnLst[0].Primary_Route_to_Market__c ='Open';
        //mcnLst[0].Assigned_MR__c = Acc12.id;

        update mcnLst;
        test.stopTest();
        mcnLst[0].Assigned_MR__c = null;
        update mcnLst;
        System.runas(usr){
            Accountshare sh=new Accountshare(AccountAccessLevel = 'Read',ContactAccessLevel = 'Read',CaseAccessLevel = 'None', OpportunityAccessLevel = 'None',AccountId = Acc12.id, UserOrGroupId =usr.id);
            insert sh;

        }
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        Map<Id,Account> newAccMap = new Map<Id,Account>();
        oldAccMap.put(Acc1.id,Acc1);
        newAccMap.put(Acc2.id,Acc2);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = false;
        PartnerAccountTriggerHelper partnerHelper = new PartnerAccountTriggerHelper();
        partnerHelper.runDeleteGroupsToUserMPP(oldAccMap);
    }



    @isTest static void test_newMethod() {
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id partnerRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Id contactPartnerId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        List<Account> accountToBeInserted = new List<Account>();
        List<Account> cusAccLst = TestDataSetUpUtils.createAccounts(1,custRecTypeId);
        List<Account> partnerAccList = TestDataSetUpUtils.createAccounts(1,partnerRecTypeId);
        List<Contact> lstContact = TestDataSetUpUtils.createContacts(1,contactPartnerId, partnerAccList);
        Test.startTest();
        partnerAccList[0].Applications_Enabled__c = 'CPQ';
        partnerAccList[0].IsPartner = true;
        update partnerAccList;
        partnerAccList[0].Applications_Enabled__c = 'APB Opportunity';
        partnerAccList[0].IsPartner = false;
        update partnerAccList;
        Account Chilaccount =new Account(Name = 'MCN1',RecordTypeId = mcnRecTypeId, Motorola_Customer_Number__c ='3454',
                                        CurrencyIsoCode ='USD',ERP_Active__c=true,MCN_Account_Name__c = 'testnamea');
        Account Chilaccount1 =new Account(Name = 'MCN2',RecordTypeId = mcnRecTypeId, ParentId =cusAccLst.get(0).Id,
                                        CurrencyIsoCode ='USD',ERP_Active__c=true,Motorola_Customer_Number__c ='34454',
                                        MCN_Account_Name__c = 'testname');
        accountToBeInserted.add(Chilaccount);
        accountToBeInserted.add(Chilaccount1);
        Insert accountToBeInserted;
        accountToBeInserted.get(1).Primary_Route_To_Market__c='Open';
        update accountToBeInserted;
        Delete cusAccLst;
        Test.stopTest();
    }

    @isTest static void testNewMethod_MCNUpdate() {
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id partnerRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
        Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        Id contactPartnerId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        List<Account> mcnAccountToBeInserted = new List<Account>();
        List<Account> cusAccLst = TestDataSetUpUtils.createAccounts(1,custRecTypeId);
        List<Account> partnerAccList = TestDataSetUpUtils.createAccounts(2,partnerRecTypeId);

        Test.startTest();
        partnerAccList[0].Applications_Enabled__c = 'CPQ';
        partnerAccList[0].IsPartner = true;
        update partnerAccList;
        List<Account> mcnAccountsList = TestDataSetUpUtils.createMCNAccounts(1,mcnRecTypeId,cusAccLst);
        mcnAccountsList.get(0).parentid = partnerAccList.get(0).Id;
        update mcnAccountsList;
        List<Technical_Site__c> sitesList = TestDataSetUpUtils.createSites(1,mcnAccountsList.get(0).Id,cusAccLst.get(0).Id,'');
        mcnAccountsList.get(0).parentid = partnerAccList.get(1).Id;
        update mcnAccountsList;

        Test.stopTest();
    }
    @isTest static void accountGoogleDriveTest(){
        GoogleDriveTest.accountGoogleDriveTest();
    }
    @isTest static void accountTeamMemberGoogleDriveTest(){
        GoogleDriveTest.accountTeamMemberGoogleDriveTest();
    }
    @isTest static void CDMTests(){
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        List<Account> accountToBeInserted = new List<Account>();
        User[] currentUser=[select id,Core_ID__c from user where id=:UserInfo.getUserId()];
        
        List<Account> cusAccLst = TestDataSetUpUtils.createAccounts(1,custRecTypeId);
        Account mcnAcc1 =new Account(Name = 'MCN1',
                                    RecordTypeId = mcnRecTypeId,
                                    Motorola_Customer_Number__c ='3454',
                                    CurrencyIsoCode ='USD',
                                    ERP_Active__c=true,
                                    CDH_Owner_CoreID__c=currentUser[0].Core_ID__c,
                                    MCN_Account_Name__c = 'testnamea',
                                    Golden_Id__c='909202(232323232)');
        Account mcnAcc2 =new Account(Name = 'MCN2',
                                    RecordTypeId = mcnRecTypeId,
                                    Motorola_Customer_Number__c ='38454',
                                    billingStreet='123 test ln',
                                    CurrencyIsoCode ='USD',
                                    ERP_Active__c=true,
                                    MCN_Account_Name__c = 'testnamea');
        Test.startTest();
        cusAccLst.add(mcnAcc1); cusAccLst.add(mcnAcc2);
        insert mcnAcc1; insert mcnAcc2;
        mcnAcc2.Golden_Id__c = '90920222(23232322232)';
        mcnAcc2.Is_Primary__c=false;
        update mcnAcc2;
        mcnAcc2.Is_Primary__c=true;
        mcnAcc2.CDH_Owner_CoreID__c=currentUser[0].Core_ID__c;
        update mcnAcc2;
        mcnAcc2.Golden_Id__c='909202(232323232)';
        update mcnAcc2;
        
        mcnAcc1.parentId=cusAccLst[0].id;
        update mcnAcc1;
        mcnAcc2.parentId=cusAccLst[0].id;
        update mcnAcc2;
        Test.stopTest();


    }
    @isTest
    public static void BRRChange(){
        //Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
        Test.startTest();
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id FROM Briefing_Room_Report__c];

        Test.stopTest();
        Account acc= new Account();
        acc.Id =AccountList.get(0).Id;
        acc.Briefing_Room_Report__c = lstBRR.get(8).Id;
        try{
        update acc;
        }catch(Exception ex){
            
        }
        acc.Id =AccountList.get(0).Id;
        acc.Briefing_Room_Report__c = lstBRR.get(2).Id;
        try{
        update acc;
        }catch(Exception ex){
            
        }
        
        
    }  
	@isTest
    public static void accountSalesChannelMetaTest(){   
        AccountTriggerHelper helper = new AccountTriggerHelper();
        helper.accountSalesChannelMeta();
    } 
}