@isTest
private class CustandMCNAccountSharing_Test 
{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void CustandMCNAccountSharing_Test()
    { 
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id PartnerId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();   
        Account Ac = new Account(Name='TestV',billingcountrycode ='IN',RecordTypeID=prospectId,BillingPostalCode='1234',Billingcity='Test');
        Insert Ac;
        Set<Id> Accid = new Set<Id>();
        Accid.add(Ac.id);
        List<Account> prosLst = new List<Account>(); prosLst.add(Ac);
        
        Account Acc1 = new Account(Name='TestVAccount',Role_Created__c=true,RecordTypeID=PartnerId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc1;
        //Acc1.ownerId = UserInfo.getUserId();
        //Acc1.Ispartner = true;
        //update Acc1;
        
        Account Acc2 = new Account(Name='TestVAccount12',Role_Created__c=true,RecordTypeId=PartnerId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc2;
        //Acc2.ownerId = UserInfo.getUserId();
        //Acc2.Ispartner = true;
        //update Acc2;
        
        Account Acc12 = [select id from Account where id=:Acc2.id];
        System.debug('Inserted account Ispartner ---'+Acc2.Ispartner);
        Acc12.Ispartner = true;
        update Acc12;
        Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,Primary_Contact_Type__c='sales');
        Insert C1;
        Contact C2 = new contact(FirstName='First',LastName='Last',Accountid=Acc2.id,Primary_Contact_Type__c='sales');
        Insert C2;
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile partnepro = [SELECT Id FROM Profile WHERE Name = 'EMS Partner Administrator Profile NAMR'];
        User usr1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                             EmailEncodingKey='UTF-8', FirstName='VTest1',LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',UserName='sssstandarduser@testorg111.com',Core_ID__c='Test432');
        insert usr1 ;   
        Acc1.ownerId = usr1.id;
        update Acc1;   
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com',core_id__c='Test5432');
        insert usr ;
        user partusr = new user(Alias = 'standt', Email='S0001@justignoreorg.com', 
                                EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = partnepro.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testahh@T.com',
                                core_id__c='Test1232',ContactId=C2.id,isactive=TRUE);
        insert partusr;
        UserRole ur = new UserRole(PortalType = 'Partner', PortalAccountId = acc2.Id);
        List<Account> mcnLst =TestDataSetUpUtils.createMCNAccounts(1, mcnRecId, prosLst);
        mcnLst[0].Primary_Route_to_Market__c ='MR Led';
        mcnLst[0].Assigned_MR__c = Acc12.id;
        update mcnLst;
        mcnLst[0].Assigned_MR__c = null;
        update mcnLst;
        System.runas(usr)
        {
            Accountshare sh=new Accountshare(AccountAccessLevel = 'Read',ContactAccessLevel = 'Read',CaseAccessLevel = 'None', OpportunityAccessLevel = 'None',AccountId = Acc12.id, UserOrGroupId =usr.id);
            insert sh;
            Test.stopTest();
        } 
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        Map<Id,Account> newAccMap = new Map<Id,Account>();
        oldAccMap.put(Acc1.id,Acc1);
        newAccMap.put(Acc2.id,Acc2);
        //CustandMCNAccountSharing cusMCNshar = new CustandMCNAccountSharing();
        //cusMCNshar.reShareAccRecords1(Accid);
        //cusMCNshar.reShareAccRecords2(Accid);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = false;
        PartnerAccountTriggerHelper partnerHelper = new PartnerAccountTriggerHelper();
        partnerHelper.runDeleteGroupsToUserMPP(oldAccMap);
    }             
}