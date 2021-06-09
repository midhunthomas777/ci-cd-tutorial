/************************************************************************************************* 
* File Name  : PartnerSharingHelper_Test
* Description: Test class for PartnerSharingHelper class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 14-Aug-2018     Satish Maddhi(TCS)                Initial development
*
*************************************************************************************************/
@isTest
public class PartnerSharingHelper_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }    
    public static testmethod void test_partnerSharingHelper() {
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id partRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id partnerContactRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        Id caseSupprotRecId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'Support_Request');

        ID conPartnerRecordId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> custAcclist = TestDataSetUpUtils.createAccounts(1, customerRTId);
        List<Account> mcnAcclist = TestDataSetUpUtils.createAccounts(1, mcnRecId);
        List<Lead> leadsToUpdate = new List<Lead>(); 
        List<Contact> contactsToUpdate = new List<Contact>();
        
        List<Account> partAccLst = TestDataSetUpUtils.createAccounts(1,partRecTypeId);
        partAccLst[0].Partner_Region__c = 'NAMR';
        partAccLst[0].Radio_Leads__c = True;
        update partAccLst[0];
        List<Account> cusAccLst = TestDataSetUpUtils.createAccounts(1,custRecTypeId);
        cusAccLst[0].Assigned_MR__c = partAccLst[0].id;
        update cusAccLst[0];
        Case cas = new Case();
        cas.AccountId = cusAccLst[0].id;
        cas.RecordtypeId = caseSupprotRecId;
        cas.Status='Test Status';
        cas.Priority='Medium';
        cas.Type ='Support Request';
        cas.Subject='Test Subject';
        cas.Subordinates_EmailId__c = 'test@mailinator.com';
        insert cas;

        Test.startTest();
        List<Lead> leadlst = TestDataSetUpUtils.createLeadRecords(2);
        Map<Id,Id> newLeadMap = new Map<Id,Id>();
        Map<Id,Id> leadOldAccMap = new Map<Id,Id>();
        for(Lead eachLead : leadlst) {            
            leadOldAccMap.put(eachLead.id,eachLead.id);
        }
        leadlst[0].Partner_Account_NA__c=partAccLst[0].id;
        leadsToUpdate.add(leadlst[0]);
        //Update leadlst[0];
        
        Contact assignedMRSP = new Contact(FirstName='First',LastName='Last',Accountid=partAccLst[0].id,Primary_Contact_Type__c='sales',Tag__c='Lead Admin',Email='test@testnew.com');
        Insert assignedMRSP;
        
        PartnerSharingHelper ctrl = new PartnerSharingHelper();
        
        //ctrl.removeLeadSharingOfAPandLALeads(newLeadMap);
        ctrl.removeLeadSharingOfAPandLALeads(new Map<Id,Lead>());
        
        ctrl.revokeAccessToPartnerExecs(leadOldAccMap);
        ctrl.revokeAccessToPartnerUsers(leadOldAccMap);
        // Test.Stoptest();
        Account Acc2 = new Account(Name='TestVAccount12',RecordTypeId=partRecTypeId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234',Radio_Leads__c = True);
        Insert Acc2;        
        
        Contact partCon = new contact(FirstName='First',LastName='Last',Accountid=Acc2.id,Primary_Contact_Type__c='sales',Tag__c='Lead Admin',LDAP_Login__c='Test1232'/*,Master_Flag__c='nomaster'*/,email='S0001@justignoreorg.com');
        Insert partCon;
        Profile partnepro = [SELECT Id FROM Profile WHERE Name = 'EMS Partner Administrator Profile NAMR' LIMIT 1];
        User partusr = new user(Alias = 'standt', Email='S0001@justignoreorg.com', 
                                EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = partnepro.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testahh@T.com',
                                core_id__c='Test1232',ContactId=partCon.id,isActive=TRUE);
        insert partusr;
        system.debug('Acc2==>'+ Acc2);
        system.debug('Acc2==>'+ Acc2.Radio_Leads__c);
        system.debug('partCon==>'+ partCon);
        system.debug('partCon==>'+ partCon.Radio_Lead_Contact__c);
        leadlst[1].Partner_Account_NA__c=Acc2.id;
        leadsToUpdate.add(leadlst[1]);
        Database.update(leadsToUpdate,false);
        
        //Update leadlst[1];
        
        Map<Id,Id> leadPartnerMap = new Map<Id,Id>();
        //leadPartnerMap.put(partusr.id,partusr.Contact.AccountId);
        leadPartnerMap.put(leadlst[1].Id,leadlst[1].Partner_Account_NA__c);
        ctrl.leadSharingOfAPandLALeads(leadPartnerMap);
        
        Set<Id> userIds = new Set<Id>();
        userIds.add(partusr.Id);
        ctrl.getAccountIdFromUser(userIds);
        
        Set<Id> partnerAccIds = new Set<Id>();
        partnerAccIds.add(Acc2.id);
        
        newLeadMap.put(leadlst[1].id,partCon.Id);
        ctrl.revokeAccessToPartnerExecs(newLeadMap);
        
        Map<Id,Id> aacLeadPartnerMap = new Map<Id,Id>();
        aacLeadPartnerMap.put(partCon.AccountId,partCon.AccountId);
        ctrl.shareToExecutiveRoles(aacLeadPartnerMap);
        ctrl.shareToAllRoles(aacLeadPartnerMap);
        
        Map<Id,Id> aacLeadPartnerMap1 = new Map<Id,Id>();
        aacLeadPartnerMap1.put(leadlst[0].id,partCon.AccountId);
        ctrl.shareToExecutiveRoles(aacLeadPartnerMap1);

        Map<id,id> caseAccMap = new Map<id,id>();
        caseAccMap.put(cas.id,partCon.AccountId);
        ctrl.shareToExecutiveRoles(caseAccMap);

        /*mcnAcclist[0].Validation_Status__c='OBSOLETE';
        mcnAcclist[0].Assigned_MR__c =Acc2.id ;
        mcnAcclist[0].Assigned_MR_Sales_Person__c=partCon.Id;
        mcnAcclist[0].parentId=custAcclist[0].id;
        update mcnAcclist; */
        
        Map<Id,Id> aacLeadPartnerUserMap = new Map<Id,Id>();
        aacLeadPartnerUserMap.put(partCon.AccountId,partusr.ContactId);        
        ctrl.shareToPartnerUser(aacLeadPartnerUserMap);
        
        Map<Id,Id> aacLeadPartnerUserMap1 = new Map<Id,Id>();
        aacLeadPartnerUserMap1.put(leadlst[0].id,partusr.ContactId);
        
        ctrl.shareToPartnerUser(aacLeadPartnerUserMap1);
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1', Accountid=partAccLst[0].id,RecordTypeId=conPartnerRecordId,LDAP_Login__c='Ldaptr1',TAG__C='ADP'/*,Master_Flag__c='nomaster'*/,email='abctest71@gmail.com');
        insert ConData1;

        Test.Stoptest();
        User partusr1 = new user(Alias = 'standt', Email='abctest71@gmail.com', 
                                EmailEncodingKey='UTF-8', FirstName='First',LastName='Last1', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = partnepro.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='abctest71@gmail.com',
                                core_id__c='Ldaptr1',ContactId=ConData1.id,isActive=TRUE);
        insert partusr1;
        
        ConData1.TAG__C='Lead Admin';
        //contactsToUpdate.add(ConData1);
        UPDATE CONDATA1;
        
        ConData1.TAG__C='ADP';
        //contactsToUpdate.add(ConData1)
        UPDATE CONDATA1;
        
        
        //revokeAccAccessToPartnerExecs
        //getAccountIdFromUser
    }    
    public static testmethod void test_partnerSharingHelper1() {
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id partRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id partnerConTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        
        List<Account> partAccLst = TestDataSetUpUtils.createAccounts(1,partRecTypeId);
        partAccLst[0].Partner_Region__c = 'NAMR';
        update partAccLst[0];
        Contact assignedMRSP = new Contact(recordtypeId=partnerConTypeId,FirstName='First',LastName='Last',Accountid=partAccLst[0].id,Primary_Contact_Type__c='sales',Tag__c='Lead Admin');
        Insert assignedMRSP;
        
        PartnerSharingHelper ctrl = new PartnerSharingHelper();
        Test.StartTest();
        List<Account> acParent=new List<Account>();
        List<Account> acChild=new List<Account>();
        Account Pacc1= new Account(Name = 'TestParent',
                                   RecordTypeId = prospectRecTypeId, 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   BillingCountryCode = 'US',
                                   Billing_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   Region__c = 'NA',
                                   Territory__c = 'NYC',
                                   MCN_Account_Number__c=String.valueof(Integer.valueof(math.random()*1000000)*100), 
                                   BillingPostalCode = '112004'
                                  );
        acParent.add(Pacc1);
        Account Pacc2= new Account(Name = 'TestParent2',
                                   RecordTypeId = prospectRecTypeId, 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   BillingCountryCode = 'US',
                                   Billing_County__c= 'Australia',
                                   BillingState= 'Montana',
                                   BillingCity = 'Billings',
                                   BillingStreet= 'test', 
                                   Region__c = 'NA',
                                   Territory__c = 'NYC',
                                   MCN_Account_Number__c=String.valueof(Integer.valueof(math.random()*1000000)*100),
                                   BillingPostalCode = '112004'
                                  );
        acParent.add(Pacc2);
        insert acParent;
        
        Account Chilacc1=new Account(
            Name = 'MCN1',
            ParentId=acParent[0].Id,
            RecordTypeId = mcnRecTypeId, 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='',
            Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*1000000)*100),
            ERP_Active__c=true,
            Assigned_MR__c = partAccLst[0].id,
            Assigned_MR_Sales_Person__c = assignedMRSP.id
        );
        acChild.add(Chilacc1);
        
        Account Chilacc2=new Account(
            Name = 'MCN1',
            ParentId=acParent[1].Id,
            RecordTypeId = mcnRecTypeId, 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='Partner Led',
            Motorola_Customer_Number__c = String.valueOf(Integer.valueOf(Math.random()*1000000)*100),
            ERP_Active__c = true,
            Assigned_MR__c = partAccLst[0].id,
            Assigned_MR_Sales_Person__c = assignedMRSP.id
        );
        acChild.add(Chilacc2);
        insert acChild;
        
        Set<Id> allMRChangedCustomers1 = new Set<Id>();
        for(Account acc : acParent) {
            allMRChangedCustomers1.add(acc.id);
        }        
        ctrl.shareToExecutiveRoles(allMRChangedCustomers1);
        ctrl.shareToPartnerUser(allMRChangedCustomers1);
        ctrl.populateMRNamesonCustomer(allMRChangedCustomers1);
        Account Acc2 = new Account(Name='TestVAccount12',RecordTypeId=partRecTypeId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc2;
        Contact partCon = new contact(FirstName='First',LastName='Last',Accountid=Acc2.id,Primary_Contact_Type__c='sales',Tag__c='Lead Admin',Email_Unknown__c=true);
        Insert partCon;
        Profile partnepro = [SELECT Id FROM Profile WHERE Name = 'EMS Partner Administrator Profile NAMR'];
        User partusr = new user(Alias = 'standt', Email='S0001@justignoreorg.com', 
                                EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = partnepro.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testahh12312311@T.com',
                                core_id__c='TestTest1232',ContactId=partCon.id,isActive=TRUE);
        
        insert partusr;
        
        AccountTriggerHandler accHandler = new AccountTriggerHandler();
        AccountTriggerHelper acchelper = new AccountTriggerHelper(); //Added by Meher        
        //GoogleDriveAccountTriggerHelper googleDriveAccntHelper = new GoogleDriveAccountTriggerHelper(); //Added by Meher
        Set<Id> accIds = new Set<Id>();
        for(Account acc : acChild){
            accIds.add(acc.id);
        }
        Map<Id,Id> oldEmailMap = new Map<Id,Id>();
        oldEmailMap.put(partusr.id,partusr.id);      
        Test.stopTest();
        acchelper.updateOwnrOFMcns(accIds); //Added by Meher
        /*try{            
            googleDriveAccntHelper.accessToMainFolder(accIds,oldEmailMap); //Added by Meher
        } catch(Exception exp){}        
        Test.setMock(HttpCalloutMock.class, new callLDAPHttpMock());        
        GoogleDriveAccountTriggerHelper.providePermission('testahh12312311@T.com','Partner User','1112334'); //Added by Meher
        GoogleDriveAccountTriggerHelper.revokePermission('testahh12312311@T.com','Partner User','1112334'); //Added by Meher
            */    
        acchelper.getOwnerIDfromCoreIDs(new Set<String>{'TDHR73'}); //Added by Meher       
    }
}