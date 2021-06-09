@isTest
private class ContacttriggerTest
{
    	@testSetup
        static void testSetUp() {
            TestDataSetUpUtils.insertCustomSettings();
            TriggerSettings__c trgrdisbld = new TriggerSettings__c(Name = 'UserTriggerDisabled',IsActive__c=FALSE);
            //TriggerSettings__c trgrdisbld1 = new TriggerSettings__c(Name = 'ContactTriggerDisabled',IsActive__c=FALSE);
            insert trgrdisbld;
            //insert trgrdisbld1;
        }    
    	static void inactiveTriggers() {
        
        List<DeactivateOpportunityTrigger__c> oppTgrList = new List<DeactivateOpportunityTrigger__c>();
        DeactivateOpportunityTrigger__c tgr1 = new DeactivateOpportunityTrigger__c(Name='Deactivate OppRelatedActions',Deactivate__c = FALSE);
        oppTgrList.add(tgr1);
        DeactivateOpportunityTrigger__c tgr2 = new DeactivateOpportunityTrigger__c(Name='Deactivate UpdateAwardStatusValue',Deactivate__c = FALSE);
        oppTgrList.add(tgr2);
        DeactivateOpportunityTrigger__c tgr3 = new DeactivateOpportunityTrigger__c(Name='BypassPartnerOpptyRegistration',Deactivate__c = FALSE);
        oppTgrList.add(tgr3);
        Database.insert(oppTgrList,false);
        
        /*DataActivity__c Temp3 = new DataActivity__c(Name='DeactivateMain',DeactivateTrigger__c = FALSE);
        insert Temp3;*/
        TriggerDeactivateSwitch__c tgrSwitch = new TriggerDeactivateSwitch__c(Name='AccountUpdateRelatedMCNTrigger',IsTriggerActive__c =TRUE);
        insert tgrSwitch;
        
        List<DeactivatePLTrigger__c> deactiveTgrList = new List<DeactivatePLTrigger__c>();
        DeactivatePLTrigger__c DPL = new DeactivatePLTrigger__c(Name='DeativateContactTrigger',Deactivate__c=FALSE);
        deactiveTgrList.add(DPL);
        DeactivatePLTrigger__c DPL1 = new DeactivatePLTrigger__c(Name='DeativateLocName',Deactivate__c=FALSE);
        deactiveTgrList.add(DPL1);
        DeactivatePLTrigger__c DPL2 = new DeactivatePLTrigger__c(Name='DeativateUpdateHQ',Deactivate__c=FALSE);
        deactiveTgrList.add(DPL2);
        Database.insert(deactiveTgrList,false);
        
        /*Partner_Regions_Locations__c CS_PL = new Partner_Regions_Locations__c(Name='Contact Grouping 1',Region__c='NAMR');
        insert CS_PL;*/
    } 
    static List<Account> createAccounts() {
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' AND r.name='Partner'];
        List<Account> accList = new List<Account>();
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.partner_region__c='NAMR';
        accnt1.Partner_HQ_Country__c='United states';
        accnt1.Partner_Primary_State__c='Alabama';
        acclist.add(accnt1);
        insert acclist;
        return acclist;
    }
    //Contact data creation
    static testmethod void createContacts() {
        Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        /*  MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',  MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;*/
        ContacttriggerTest.inactiveTriggers();
        List<Account> accountList = ContacttriggerTest.createAccounts();
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=accountList[0].id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr',TAG__C='ADP',email='abctest3@gmail.com');
        Insert ConData;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1', Accountid=accountList[0].id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr1',TAG__C='',email='abctest71@gmail.com');
        Insert ConData1;
        ConData1.TAG__C='ADP';
        UPDATE CONDATA1;
        List<Contact> CList = new List<Contact>();
        
        Partner_Location__c PL = new Partner_Location__c(Account__c=accountList[0].id,Country1__c='United States',Address_Type__c='Primary Location');
        insert PL;
        for(Contact Con2 : [SELECT id,firstname FROM contact WHERE ID = : ConData1.id])
        {
            Con2.firstname='Testttt';
            Con2.tag__c='SFDC Partner Admin';
            Con2.email='abctest31@gmail.com';
            CList.add(Con2);
        }
        SFDC_LMSInterface__c lmsObj=new SFDC_LMSInterface__c(Contact_LDAP_Login__c='Ldaptr',Contact__c = ConData.id,Contact_Active_Delete__c=TRUE);
        insert lmsObj;
        update CList;
        //delete CList;
    }
    static testmethod void createContacts2() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id,
            System_Integration__c = true
        );
        insert u;
        System.runAs(u){
            TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
            insert triggerSetting;
            Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            //MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
            ContacttriggerTest.inactiveTriggers();
            List<Contact> insertContacts = new List<Contact>();
            List<Account> accountList = ContacttriggerTest.createAccounts();
            
            for(integer i=0; i<=40 ;i++){
                Contact contact = new Contact();
                contact.RecordTypeId = PartConId;
                contact.AccountID = accountList[0].id;
                contact.firstname = 'Eloqua';
                contact.Lastname = 'TestCont'+i;
                contact.email = 'test'+i+'@test.com';
                insertContacts.add(contact);
            }
            insert insertContacts ; 
       
            Profile p = [SELECT Id FROM Profile WHERE Name='MPE Partner Profile'];
            User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, contactid=insertContacts[1].id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testswing@testorg.com');
            insert usr ;
        }
    }   
    static testmethod void createContacts3() {
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        /*  MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',  MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;*/
        ContacttriggerTest.inactiveTriggers();
        List<Account> accountList = ContacttriggerTest.createAccounts();
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=accountList[0].id,RecordTypeId=PartConId,LDAP_Login__c='Ldaptr',TAG__C='SFDC Partner Admin',email='abctes7t@gmail.co');
        Insert ConData;
        Contact ConData2 = new Contact(FirstName='First',LastName='Last2', Accountid=accountList[0].id,RecordTypeId=PartConId,LDAP_Login__c='Ldaptr1',TAG__C='SFDC Partner Admin',email='abctes71t@gmail.co');
        Insert ConData2;
        Contact ConData3 = new Contact(FirstName='First',LastName='Last3', Accountid=accountList[0].id,RecordTypeId=PartConId,LDAP_Login__c='Ldaptr2',TAG__C='SFDC Partner Admin',email='abctes72t@gmail.co');
        Insert ConData3;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1', Accountid=accountList[0].id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr3',TAG__C='ADP',email='abctest1@gmail.com');
        Insert ConData1;
        List<Contact> CList = new List<Contact>();
        List<Contact> CList2 = new List<Contact>();
        Partner_Location__c PL = new Partner_Location__c(Account__c=accountList[0].id,Country1__c='United States',Address_Type__c='Primary Location');
        insert PL;
        
        delete ConData;
    }
    static testmethod void createContacts4() {
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        /* MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',  MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;*/
        ContacttriggerTest.inactiveTriggers();
        List<Account> accountList = ContacttriggerTest.createAccounts();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Contact ConData = new Contact(FirstName='First',LastName='Last', Account_Region__c='NAMR',Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='true',TAG__C='',email='abctest1@gmail.com');
        Insert ConData;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1', Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='Ldaptr1',TAG__C='ADP',email='abctes5t@gmail.com');
        Insert ConData1;
        
        List<Contact> CList = new List<Contact>();
        
        Partner_Location__c PL = new Partner_Location__c(Account__c=accountList[0].id,Country1__c='United States',Address_Type__c='Primary Location');
        insert PL;
        for(Contact Con2 : [SELECT id,firstname,tag__c FROM contact WHERE ID = : ConData.id])
        {
            Con2.firstname='Testttt';
            Con2.tag__c='ADP,SFDC Partner Admin';            
            Con2.email='abctest11@gmail.com';
            Con2.LDAP_Login__c='false';
            Con2.ldap_update__c='Y';
            //Con2.Account_Region__c='NAMR';
            CList.add(Con2);
        }
        SFDC_LMSInterface__c lmsObj=new SFDC_LMSInterface__c(Contact_LDAP_Login__c='Ldaptr',Contact__c = ConData.id,Contact_Active_Delete__c=TRUE);
        insert lmsObj;
        update CList;
        
        
    }
    static testmethod void createContacts5() {
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        /*  MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',  MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;*/
        ContacttriggerTest.inactiveTriggers();
        List<Account> accountList = ContacttriggerTest.createAccounts();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Contact ConData = new Contact(FirstName='First',LastName='Last', ldap_update__c='Y',Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='Ldaptr',TAG__C='SFDC Partner Admin,ADP',email='abctest1@gmail.com');
        Insert ConData;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1',ldap_update__c='N',ldap_batch__c='R', Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='Ldaptr1',TAG__C='ADP',email='abctes5t@gmail.com');
        Insert ConData1;
        
        List<Contact> CList = new List<Contact>();
        
        Partner_Location__c PL = new Partner_Location__c(Account__c=accountList[0].id,Country1__c='United States',Address_Type__c='Primary Location');
        insert PL;
        for(Contact Con2 : [SELECT id,firstname,tag__c FROM contact WHERE ID = : ConData.id])
        {
            Con2.firstname='Testttt';
            Con2.lastname='Assignee';
            Con2.tag__c='ADP';            
            Con2.email='abctest11@gmail.com';
            Con2.LDAP_Login__c='lda';
            Con2.ldap_update__c='N';
            Con2.ldap_batch__c='R';
            CList.add(Con2);
        }
        SFDC_LMSInterface__c lmsObj=new SFDC_LMSInterface__c(Contact_LDAP_Login__c='Ldaptr',Contact__c = ConData.id,Contact_Active_Delete__c=TRUE);
        insert lmsObj;
        update CList;
    }
    static testmethod void createContacts8() {
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting;
        Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        /* MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',  MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;*/
        ContacttriggerTest.inactiveTriggers();
        List<Account> accountList = ContacttriggerTest.createAccounts();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Contact ConData = new Contact(FirstName='First',LastName='Last', ldap_update__c='Y',Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='Ldaptr',TAG__C='SFDC Partner Admin',email='abctest1@gmail.com');
        Insert ConData;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1',ldap_update__c='N',ldap_batch__c='R', Accountid=accountList[0].id,RecordTypeId='01280000000LsIzAAK',LDAP_Login__c='Ldaptr1',TAG__C='ADP',email='abctes5t@gmail.com');
        Insert ConData1;
        
        List<Contact> CList = new List<Contact>();
        List<Contact> CList1 = new List<Contact>();
        Test.startTest();
        Partner_Location__c PL = new Partner_Location__c(Account__c=accountList[0].id,Country1__c='United States',Address_Type__c='Primary Location');
        insert PL;
        for(Contact Con2 : [SELECT id,firstname,tag__c FROM contact WHERE ID = : ConData.id])
        {
            Con2.firstname='Test123';
            Con2.lastname='Assignee2';
            Con2.tag__c='ADP';
            Con2.email='abctest11@gmail.com';
            Con2.LDAP_Login__c='lda';
            Con2.ldap_update__c='N';
            Con2.ldap_batch__c='R';
            CList.add(Con2);
        }
        for(Contact Con3 : [SELECT id,firstname,tag__c FROM contact WHERE ID = : ConData1.id])
        {
            Con3.firstname='Test345';
            Con3.lastname='Assignee3';
            Con3.tag__c='SFDC Partner Admin,ADP';
            Con3.email='abctest145@gmail.com';
            Con3.LDAP_Login__c='lda';
            Con3.ldap_update__c='N';
            Con3.ldap_batch__c='R';
            CList1.add(Con3);
        }
        SFDC_LMSInterface__c lmsObj=new SFDC_LMSInterface__c(Contact_LDAP_Login__c='Ldaptr',Contact__c = ConData.id,Contact_Active_Delete__c=TRUE);
        insert lmsObj;
        Test.stopTest();
        update CList;
        update CList1;
    }
    /*static testmethod void createContacts7() {
        List<Account> accccts = new List<Account>();
        TriggerSettings__c triggerSetting=new TriggerSettings__c(name='OpportunityTriggerDisabled',IsActive__c= TRUE);
        INSERT triggerSetting;
        //   MPE_Partner_Contact_Settings__c customSettingRecordTypeId = MPE_Partner_Contact_Settings__c.getValues('Data');
        MPE_Partner_Contact_Settings__c customSettingRecordTypeId=new MPE_Partner_Contact_Settings__c(name='Data',    MPE_Partner_Contact_Record_Type__c='01280000000LsIz',MPE_Partner_Record_Type__c='01280000000UCx6',  Disable_Contact_Trigger__c=false);
        insert customSettingRecordTypeId;
        System.debug('==customSettingRecordTypeId===='+customSettingRecordTypeId);
        
        TriggerSettings__c triggerSetting1=new TriggerSettings__c(name='CustomerAccountTriggerDisabled',IsActive__c= TRUE);
        insert triggerSetting1;
        RecordType OppRT = [Select Id from RecordType where Name='Project' and SobjectType='Opportunity' limit 1];           
        RecordType AccRT = [Select Id from RecordType where Name='Prospect' and SobjectType='Account' limit 1];           
        List<Contact> CONList = new List<Contact>();
        DeactivateOpportunityTrigger__c deactivatePartnerTrigger = new DeactivateOpportunityTrigger__c(Name='populateAccountExecutiveDeactivate',Deactivate__c =false); 
        insert deactivatePartnerTrigger;
        ContacttriggerTest.inactiveTriggers();
        // List<Account> accountList = ContacttriggerTest.createAccounts();
        Account AccRec = new Account(Name='test account001',Motorola_Enterprise_ID__c='1013016903',recordtypeId=AccRT.Id,BillingCity='Test',billingcountry='United States',BillingState='Alabama',BillingPostalCode='123');  
        insert AccRec;
        Account AccRec1 = new Account(Name='test account219',recordtypeId=AccRT.Id,BillingCity='TestCity',billingcountry='Canada',BillingState='Alberta',BillingPostalCode='12345');  
        insert AccRec1;
        List<Opportunity> Oppts = new List<Opportunity>();
        Opportunity Oppts1 = new Opportunity(Name='TestOppty1',AccountId=AccRec.Id,Aging_Type__c = 'Fixed',Award_Date__c=System.Today(),CloseDate=System.Today(),StageName='Execute & Expand / Won',Status__c='Active',Deal_Location_Country__c ='Brazil',Deal_Location_State__c='Acre',Primary_Product_Track__c ='Mobility',Product_Track_Detail__c ='ADC',INDUSTRY__C='Healthcare',Reason_for_Win_or_Loss__c='MSI as the Provider',recordtypeId=OppRT.Id);                            
        Oppts.add(Oppts1); 
        insert Oppts;
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=AccRec.id,RecordTypeId='01280000000LsIz',ldap_update__c='N',LDAP_Login__c='Ldaptr',TAG__C='SFDC Partner Admin,ADP',email='abctest1@gmail.com');
        Insert ConData;
        Contact ConData1 = new Contact(FirstName='First',LastName='Last1', Accountid=AccRec1.id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr1',TAG__C='ADP',email='abctest11@gmail.com');
        Insert ConData1;
        Contact ConData2 = new Contact(FirstName='First',LastName='Last2', Accountid=AccRec.id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr2',TAG__C='ADP',email='abctest111@gmail.com');
        Insert ConData2;
        List<Contact> CList = new List<Contact>();
        for(Contact Con2 : [SELECT id,firstname,tag__c FROM contact WHERE ID = : ConData.id])
        {
            Con2.firstname='Testttt';
            Con2.lastname='Assignee';
            Con2.tag__c='ADP';            
            Con2.email='abctest1111@gmail.com';
            Con2.LDAP_Login__c='lda';
            CList.add(Con2);
        }
        List<Buying_Influences__c> BIs = new List<Buying_Influences__c>();  
        Buying_Influences__c BI1 = new Buying_Influences__c(Opportunity__c= Oppts1.id, Role__c = 'Economic',Contact__c=ConData.id);                    
        BIs.add(BI1);
        update CList;
        delete ConData;
        
    }*/       
}