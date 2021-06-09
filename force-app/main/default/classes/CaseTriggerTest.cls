/*  
* Class Name  : CaseTriggerTest
* Description:  This class is used in Case trigger              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0  27 February 2018    Shahanawaz    This test class covered the CaseTriggerHandler class.
* 2.0  29 January  2019    Suveen      Test coverage for SendEmail and AutoSubmitForApproval
*/

@isTest 
public class CaseTriggerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static List<LM_StateCode__c> customSettings1(){
        List<LM_StateCode__c> LMSList= New List<LM_StateCode__c>();
        LM_StateCode__c LMS1= new LM_StateCode__c(Name='Alabama', State_Name__c='Alabama',Country__c = 'United States', State_Code__c = 'AL');
        LMSList.add(LMS1); 
        insert LMSList;
        return LMSList;
    }
    
    static List<Account> createAccounts(){        
        //RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account accnt1 = new Account(name='cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=accrectypeID;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'Grant Park';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';       
        accnt1.Territory__c = '';
        acclist.add(accnt1);
        Account accnt2 = new Account(name='customerAccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=accrectypeID;
        //accnt2.Federal_Agency__c = 'Department of State';
        accnt2.BillingCity = 'Haskell';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'California';
        accnt2.Billing_County__c = 'Bibb';
        accnt2.Territory__c = '';
        acclist.add(accnt2);
        Account accnt3 = new Account(name='accountCust3');
        accnt3.Type ='Customer';
        accnt3.RecordTypeId=accrectypeID;
        //accnt3.Federal_Agency__c = 'Law Enforcement Agencies';
        accnt3.BillingCity = 'NEW BERN';
        accnt3.BillingCountry = 'United states';
        accnt3.BillingState = 'New Jersey';
        accnt3.Region__c='NA';
        accnt3.Territory__c = 'T3';
        acclist.add(accnt3);
        
        Account accnt4 = new Account(name='newCustomerAcc4');
        accnt4.Type ='Customer';
        accnt4.RecordTypeId=accrectypeID;
        accnt4.Federal_Agency__c = 'Law Enforcement Agencies';
        accnt4.BillingCity = 'ONTARIO';
        accnt4.BillingCountry = 'United states';
        accnt4.BillingState = 'Iowa';
        accnt4.Region__c='NA';
        accnt4.Territory__c = 'T3';
        acclist.add(accnt4);
        Account accnt5 = new Account(name='cusaccount5');
        accnt5.Type ='Customer';
        accnt5.RecordTypeId=accrectypeID;
        accnt5.Federal_Agency__c = 'Department of Defense';
        accnt5.BillingCity = 'Grant Park';
        accnt5.BillingCountry = 'United States';
        accnt5.BillingState = 'Alabama';
        accnt5.Billing_County__c = 'Yuma';       
        accnt5.Territory__c = '';
        acclist.add(accnt5);
        insert acclist;
        return acclist;
    }
    
    static CAM_Geo_Onboarding_Map__c CreateGeoMap(){
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='Department of Defense',Community__c='test',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States',County__c ='United States');
        insert CAM;
        return CAM;
    }
    
    static testmethod void accountCreationRT1(){
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        Id rectSuppReqId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Request').getRecordTypeId();
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        CaseTriggerTest.customSettings1();
        LM_StateCode__c LMS = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS;
        CaseTriggerTest.CreateGeoMap();
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);   
        
        cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectSuppReqId;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);      
        
        insert CSList;
        
        update CSList[1];
    }
    static testmethod void accountCreationRT11(){
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        CaseTriggerTest.customSettings1();
        LM_StateCode__c LMS = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS;
        CaseTriggerTest.CreateGeoMap();
        
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM1 = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='',Community__c='test',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States',County__c ='United States');
        insert CAM1;
        Case cs3 = new case();
        cs3.Accountid = accountList[0].id;
        cs3.RecordTypeId = rectcsid;
        cs3.Status = 'New';
        cs3.ASM_Approval_Status__c = 'In Approval';
        cs3.Assigned_ASM__c=CAMuser.id;
        cs3.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs3);
        insert CSList;
    }
    
    static testmethod void accountCreationRT2() {
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        String camCounty='United states';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        user CAMuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        user Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' limit 1];
        CaseTriggerTest.customSettings1();
        LM_StateCode__c LMS = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS;
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='test',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='United States');
        insert CAM;
        system.debug('CAM GEOTestclass11' +CAM);
        Case cs2 = new case();
        cs2.Accountid = accountList[1].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void accountCreationRT3() {
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String camCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        user CAMuser =[SELECT id FROM user WHERE isactive=true limit 1];
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='Canada');
        insert CAM;
        system.debug('CAM GEOTestclass2' +CAM);
        
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[1].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void commissionInquiryRT1() {
        String camCountry='United states';
        String camStateCode='';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String camCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id caseinquiryRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Commission Inquiry').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        user CAMuser=[SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='United states');
        insert CAM;
        system.debug('CAM GEOTestclass2' +CAM);
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[2].id;
        cs2.RecordTypeId = caseinquiryRecordTypeId;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void accountUpdateRT1() {
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        user CAMuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='Canada');
        insert CAM;
        system.debug('CAM GEOTestclass2' +CAM);
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[2].id;
        cs2.RecordTypeId = rectcsupdid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void accountCreationRT4() {
        
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        user CAMuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        user CAMuser1 = [SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser1.id,Territory__c='T3',Country__c='Canada');
        insert CAM;
        system.debug('CAM GEOTestclass2' +CAM);
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[2].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        CSList.add(cs2);
        insert CSList;
        
        
    }
    
    static testmethod void accountUpdateRT2() {
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        User Asmuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        User CAMuser = [SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='Canada');
        insert CAM;
        system.debug('CAM GEOTestclass2' +CAM);
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[3].id;
        cs2.RecordTypeId = rectcsupdid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=Asmuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void accountCreationRT123() {
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        CaseTriggerTest.customSettings1();
        LM_StateCode__c LMS = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS;
        CaseTriggerTest.CreateGeoMap();
        Case cs2 = new case();
        cs2.Accountid = accountList[3].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void assignedASM1() {
        
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        User Asmuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS1;
        User CAMuser = [SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='State and Local MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=CAMuser.id,Territory__c='T3',Country__c='Canada');
        insert CAM;
        
        system.debug('CAM GEOTestclass2' +CAM);
        List<Account> accountList = new List<Account>();
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        //accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Territory__c = '';
        accountList.add(accnt1);
        insert accountList;
        List<Case> CSList = new List<Case>();
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsupdid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=Asmuser.id;
        CSList.add(cs2);
        insert CSList;
        
    }
    
    static testmethod void assignedASM2() {
        
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        List<Account> accountList = new List<Account>();
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Territory__c = '';
        accountList.add(accnt1);
        insert accountList;
        
        User Asmuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1];
        User CAMuser = [SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        system.debug('CAMuser '+CAMuser);
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='Federal MR', County__c = 'test', Director__c = CAMuser.id, Track__c = 'Radio',Function__c = 'Onboarding', Federal_Agency__c = 'Department of Defense', Channel_Account_Manager__c = CAMuser.id, Territory__c='T3',Country__c='United States', State_Province__c = 'AL');
        insert CAM;
        system.debug('CAM '+CAM);
        List<Case> CSList = new List<Case>();
        
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsupdid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=Asmuser.id;
        CSList.add(cs2);
        //insert CSList;
        
        // LM_StateCode__c LMS1 = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama', Country__c = 'United States', State_Code__c = 'AL');
        // insert LMS1;
        //system.debug('LMS1 '+LMS1);
        
        
    }
    
    static testmethod void assignedASM3() {
        
        String camCountry='CANADA';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String accTerritory='T3';
        String accBillingState='Manitoba';
        CaseTriggerTest.customSettings1();
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        List<Account> accountList = new List<Account>();
        User CAMuser = [SELECT id FROM user WHERE isactive=true and contactId='' limit 1];
        User Asmuser = [SELECT id FROM user WHERE name='Ken Rey' limit 1]; 
        system.debug('CAMuser '+CAMuser);
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(Community__c='Federal MR', County__c = 'test', Director__c = CAMuser.id, Track__c = 'Radio',Function__c = 'Onboarding', Federal_Agency__c = 'Department of Defense', Channel_Account_Manager__c = CAMuser.id, Territory__c='T3',Country__c='United States', State_Province__c = 'AL');
        insert CAM;
        system.debug('CAM '+CAM);
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = null;
        accnt1.Territory__c = '';
        accountList.add(accnt1);   
        insert accountList;
        
        List<Case> CSList = new List<Case>();
        
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsupdid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=Asmuser.id;        
        CSList.add(cs2);        
        
        
    }
    
    static testmethod void  triggerInvoke(){        
        List<ADP_Global_Account_Name__c> adpAccList = new List<ADP_Global_Account_Name__c>();
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test1', GitLab_Group_Id__c = 45));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test2', GitLab_Group_Id__c = 55));
        //adpAcc.Name = 'Test';
        //adpAcc.GitLab_Group_Id__c = 45;
        insert adpAccList;
        
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Partner'];
        List<Account> accList = new List<Account>();
        //Account1: 
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.ADP_Global_Account_Name1__c = adpAccList[0].id;
        acclist.add(accnt1);
        //Acount2:
        Account accnt2 = new Account(name='test_cusaccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=rect.Id;
        accnt2.Federal_Agency__c = 'Department of Defense';
        accnt2.BillingCity = 'test';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'Alabama';
        accnt2.Billing_County__c = 'Yuma';
        accnt2.Territory__c = '';
        accnt2.ADP_Global_Account_Name1__c = adpAccList[1].id;
        acclist.add(accnt2);
        insert acclist;
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.FirstName = 'First';
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'test@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        accContactList.add(objAccnt1Contact0);
        
        insert accContactList;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='ADP Partner Contact Request' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        
        case newcase = new case();
        
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other';
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        //newcase.Status = 'Closed';
        //newcase.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase.Status = 'Open';
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';        
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        newcase.Associate_First_Name__c ='Test';
        newcase.Associate_Last_Name__c ='Person1';
        newcase.ContactID =accContactList[0].Id;
        newcase.Admin__c = true;
        insert newcase;
        newcase.Subject ='sample';        
        update newcase;
        
        case newcase1 = new case();
        newcase1.Subject = 'testing';
        newcase1.Issue_Type__c ='Other';
        newcase1.Description = 'testing';
        newcase1.Priority='Low';
        newcase1.Preferred_Method_of_Contact__c = 'Email';
        newcase1.Status = 'closed';
        newcase1.RecordTypeId =rt.id;
        newcase1.Support_Region__c = 'Middle East';
        newcase1.Reason = 'Approved';
        newcase1.ADPEmail__c = 'test1@gmail.com';
        newcase1.AccountId = acclist[1].Id;
        //newcase1.ContactID =accContactList[0].Id;
        newcase1.Admin__c = true;
        
        //insert newcase1;
        
        case newcase2 = new case();
        newcase2.Subject = 'testing';
        newcase2.Issue_Type__c ='Other';
        newcase2.Description = 'testing';
        newcase2.Priority='Low';
        newcase2.Preferred_Method_of_Contact__c = 'Email';
        newcase2.Status = 'closed';
        newcase2.RecordTypeId =rt.id;
        newcase2.Support_Region__c = 'Middle East';
        newcase2.Reason = 'Approved';
        newcase2.ADPEmail__c = 'test@gmail.com';
        newcase2.AccountId = acclist[0].Id;
        newcase2.Admin__c = true;
        //newcase2.ContactID =accContactList[0].Id;
        
        
        //insert newcase2;
        
        Set<Id> caselst = new Set<Id>();
        caselst.add(newcase.id);
        caselst.add(newcase.id);
        caselst.add(newcase2.id);
        
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : accContactList) {
            contactIds.add(con.id);
        }
        CaseTriggerHelper.deleteRelatedRecords(caselst,contactIds);   
    }
    static testmethod void  triggerInvoke111(){        
        List<ADP_Global_Account_Name__c> adpAccList = new List<ADP_Global_Account_Name__c>();
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test1', GitLab_Group_Id__c = 45));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test2', GitLab_Group_Id__c = 55));
        //adpAcc.Name = 'Test';
        //adpAcc.GitLab_Group_Id__c = 45;
        insert adpAccList;
        
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Partner'];
        List<Account> accList = new List<Account>();
        //Account1: 
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.ADP_Global_Account_Name1__c = adpAccList[0].id;
        acclist.add(accnt1);
        //Acount2:
        Account accnt2 = new Account(name='test_cusaccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=rect.Id;
        accnt2.Federal_Agency__c = 'Department of Defense';
        accnt2.BillingCity = 'test';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'Alabama';
        accnt2.Billing_County__c = 'Yuma';
        accnt2.Territory__c = '';
        accnt2.ADP_Global_Account_Name1__c = adpAccList[1].id;
        acclist.add(accnt2);
        insert acclist;
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.FirstName = 'First';
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'testadp1@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        accContactList.add(objAccnt1Contact0);
        
        insert accContactList;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='ADP Partner Contact Request' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        
        case newcase = new case();
        
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other'; 
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        //newcase.Status = 'Closed';
        //newcase.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase.Status = 'Open';
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';        
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        newcase.Associate_First_Name__c ='Test';
        newcase.Associate_Last_Name__c ='Person1';
        newcase.ContactID =accContactList[0].Id;
        newcase.Admin__c = true;
        insert newcase;
        newcase.Subject ='sample';   
        newcase.Status = 'Closed';
        update newcase;
        
        case newcase1 = new case();
        newcase1.Subject = 'testing';
        newcase1.Issue_Type__c ='Other';
        newcase1.Description = 'testing';
        newcase1.Priority='Low';
        newcase1.Preferred_Method_of_Contact__c = 'Email';
        newcase1.Status = 'closed';
        newcase1.RecordTypeId =rt.id;
        newcase1.Support_Region__c = 'Middle East';
        newcase1.Reason = 'Approved';
        newcase1.ADPEmail__c = 'test1@gmail.com';
        newcase1.AccountId = acclist[1].Id;
        //newcase1.ContactID =accContactList[0].Id;
        newcase1.Admin__c = true;
        
        //insert newcase1;
        
        case newcase2 = new case();
        newcase2.Subject = 'testing';
        newcase2.Issue_Type__c ='Other';
        newcase2.Description = 'testing';
        newcase2.Priority='Low';
        newcase2.Preferred_Method_of_Contact__c = 'Email';
        newcase2.Status = 'closed';
        newcase2.RecordTypeId =rt.id;
        newcase2.Support_Region__c = 'Middle East';
        newcase2.Reason = 'Approved';
        newcase2.ADPEmail__c = 'test@gmail.com';
        newcase2.AccountId = acclist[0].Id;
        newcase2.Admin__c = true;
        //newcase2.ContactID =accContactList[0].Id;
        
        
        //insert newcase2;
        
        Set<Id> caselst = new Set<Id>();
        caselst.add(newcase.id);
        caselst.add(newcase.id);
        caselst.add(newcase2.id);
        
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : accContactList) {
            contactIds.add(con.id);
        }
        CaseTriggerHelper.deleteRelatedRecords(caselst,contactIds);     
    }    
    //testclass update
    static testmethod void sendEmail(){
        CaseTriggerHandler handler = new CaseTriggerHandler();
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        string templateCId, templateUId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        CaseTriggerTest.customSettings1();
        Case CS = new case();
        CS.Accountid = accountList[0].id;
        CS.RecordTypeId = caseRecordTypeId;
        CS.Status = 'New';
        CS.ASM_Approval_Status__c = 'In Approval';
        CS.Assigned_ASM__c=CAMuser.id;
        CS.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(CS);
    }
    
    static testmethod void AutoSubmitForApproval(){
        CaseTriggerHandler handler = new CaseTriggerHandler();
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        List<Case> toBeSubmitted = new List<Case>();
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        string templateCId, templateUId;
        List<Account> accountList = CaseTriggerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        CaseTriggerTest.customSettings1();
        Case CS = new case();
        CS.Accountid = accountList[0].id;
        CS.RecordTypeId = caseRecordTypeId;
        CS.Status = 'New';
        CS.ASM_Approval_Status__c = 'In Approval';
        CS.Assigned_ASM__c=CAMuser.id;
        CS.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(CS);
        for(Case eachCase:CSList){
            toBeSubmitted.add(eachCase);
            if(!toBeSubmitted.isEmpty()){
                caseHelper.autoSubmitForApproval(toBeSubmitted);   
            }
        }
    }
    
    static testmethod void  triggerInvoke2(){
        
        List<ADP_Global_Account_Name__c> adpAccList = new List<ADP_Global_Account_Name__c>();
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test1', GitLab_Group_Id__c = 45));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test2', GitLab_Group_Id__c = 55));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test3', GitLab_Group_Id__c = 65));
        
        insert adpAccList;
        
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Partner'];
        List<Account> accList = new List<Account>();
        //Account1: 
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.ADP_Global_Account_Name1__c = adpAccList[0].id;
        acclist.add(accnt1);
        //Account2:
        Account accnt2 = new Account(name='test_cusaccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=rect.Id;
        accnt2.Federal_Agency__c = 'Department of Defense';
        accnt2.BillingCity = 'test';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'Alabama';
        accnt2.Billing_County__c = 'Yuma';
        accnt2.Territory__c = '';
        accnt2.ADP_Global_Account_Name1__c = adpAccList[1].id;
        acclist.add(accnt2);
        
        Account accnt3 = new Account(name='test_cusaccount3');
        accnt3.Type ='Customer';
        accnt3.RecordTypeId=rect.Id;
        accnt3.Federal_Agency__c = 'Department of Defense';
        accnt3.BillingCity = 'test';
        accnt3.BillingCountry = 'United States';
        accnt3.BillingState = 'Alabama';
        accnt3.Billing_County__c = 'Yuma';
        accnt3.Territory__c = '';
        accnt3.ADP_Global_Account_Name1__c = adpAccList[2].id;
        acclist.add(accnt3);
        
        insert acclist;
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'test@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        objAccnt1Contact0.Tag__c = 'SFDC Partner Admin';
        accContactList.add(objAccnt1Contact0);
        
        Contact objAccnt1Contact1 = new Contact();
        objAccnt1Contact1.LastName = 'TestAccnt2Con';
        objAccnt1Contact1.Email = 'test@gmail.com';
        objAccnt1Contact1.RecordTypeId = rectContact.Id;
        objAccnt1Contact1.AccountId = acclist[1].Id;
        accContactList.add(objAccnt1Contact1);
        
        Contact objAccnt1Contact2 = new Contact();
        objAccnt1Contact2.Firstname = 'First';
        objAccnt1Contact2.LastName = 'TestAccnt3Con';
        objAccnt1Contact2.Email = 'test@gmail.com';
        objAccnt1Contact2.RecordTypeId = rectContact.Id;
        objAccnt1Contact2.AccountId = acclist[2].Id;
        objAccnt1Contact2.Tag__c = 'SFDC Partner Admin';
        accContactList.add(objAccnt1Contact2);
        
        
        insert accContactList;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='ADP Partner Contact Request' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        List<Case> caseList = new List<Case>();
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest;
        case newcase11 = new case();
        newcase11.Subject = 'testing';
        newcase11.Issue_Type__c ='Other';
        newcase11.Description = 'testing';
        newcase11.Priority='Low';
        newcase11.Preferred_Method_of_Contact__c = 'Email';
        newcase11.Status = 'New';
        newcase11.RecordTypeId =CaseSupportRequest.Case_Record_Type_Support_Request__c;
        insert newcase11;
        caseList.add(newcase11);
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.SupportRequestGrantAccessToCreator(caseList);
        case newcase = new case();
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other';
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        //newcase.Status = 'Closed';
        //newcase.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase.Status = 'Open';
        
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        newcase.ContactID =accContactList[0].Id;
        newcase.Admin__c = true;
        insert newcase;
        newcase.Subject ='sample';
        update newcase;
        
        case newcase1 = new case();
        newcase1.Subject = 'testing';
        newcase1.Issue_Type__c ='Other';
        newcase1.Description = 'testing';
        newcase1.Priority='Low';
        newcase1.Preferred_Method_of_Contact__c = 'Email';
        newcase1.Status = 'closed';
        newcase1.RecordTypeId =rt.id;
        newcase1.Support_Region__c = 'Middle East';
        newcase1.Reason = 'Approved';
        newcase1.ADPEmail__c = 'test1@gmail.com';
        newcase1.AccountId = acclist[1].Id;
        
        //insert newcase1;
        
    }
    
    static testmethod void  triggerInvoke3(){
        
        List<ADP_Global_Account_Name__c> adpAccList = new List<ADP_Global_Account_Name__c>();
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test1', GitLab_Group_Id__c = 45));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test2', GitLab_Group_Id__c = 55));
        
        insert adpAccList;
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Partner'];
        List<Account> accList = new List<Account>();
        //Account1: 
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.ADP_Global_Account_Name1__c = adpAccList[0].id;
        acclist.add(accnt1);
        
        Account accnt2 = new Account(name='test_cusaccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=rect.Id;
        accnt2.Federal_Agency__c = 'Department of Defense';
        accnt2.BillingCity = 'test';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'Alabama';
        accnt2.Billing_County__c = 'Yuma';
        accnt2.Territory__c = '';
        accnt2.ADP_Global_Account_Name1__c = adpAccList[1].id;
        acclist.add(accnt2);
        
        insert acclist;
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'test@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        objAccnt1Contact0.Tag__c = 'SFDC Partner Admin';
        accContactList.add(objAccnt1Contact0);
        
        Contact objAccnt1Contact1 = new Contact();
        objAccnt1Contact1.FirstName = 'First';
        objAccnt1Contact1.LastName = 'TestAccnt1Con';
        objAccnt1Contact1.Email = 'test@gmail.com';
        objAccnt1Contact1.RecordTypeId = rectContact.Id;
        objAccnt1Contact1.AccountId = acclist[0].Id;
        objAccnt1Contact1.Tag__c = 'Federal Contact';
        accContactList.add(objAccnt1Contact1);
        
        
        insert accContactList;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='ADP Partner Contact Request' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        
        case newcase = new case();
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other';
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        //newcase.Status = 'Closed';
        //newcase.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase.Status = 'Open';        
        
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        newcase.Admin__c = true;
        
        insert newcase;
        
        newcase.Subject ='sample';
        update newcase;
        
        case newcase1 = new case();
        newcase1.Subject = 'testing';
        newcase1.Issue_Type__c ='Other';
        newcase1.Description = 'testing';
        newcase1.Priority='Low';
        newcase1.Preferred_Method_of_Contact__c = 'Email';
        //newcase1.Status = 'Closed';
        //newcase1.Status = 'Closed';
        //newcase1.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase1.RecordTypeId =rt.id;
        newcase1.Support_Region__c = 'Middle East';
        newcase1.Reason = 'Approved';
        newcase1.ADPEmail__c = 'test@gmail.com';
        newcase1.AccountId = acclist[0].id;
        newcase1.Admin__c = true;
        
        insert newcase1;
    }
    
    static testmethod void  triggerInvoke4(){
        
        List<ADP_Global_Account_Name__c> adpAccList = new List<ADP_Global_Account_Name__c>();
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test1', GitLab_Group_Id__c = 45));
        adpAccList.add(new ADP_Global_Account_Name__c(Name = 'Test2', GitLab_Group_Id__c = 55));
        
        insert adpAccList;
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Partner'];
        List<Account> accList = new List<Account>();
        
        
        Account accnt2 = new Account(name='test_cusaccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=rect.Id;
        accnt2.Federal_Agency__c = 'Department of Defense';
        accnt2.BillingCity = 'test';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'Alabama';
        accnt2.Billing_County__c = 'Yuma';
        accnt2.Territory__c = '';
        accnt2.ADP_Global_Account_Name1__c = adpAccList[1].id;
        acclist.add(accnt2);
        
        insert acclist;
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        
        Contact objAccnt1Contact1 = new Contact();
        objAccnt1Contact1.firstName='First';
        objAccnt1Contact1.LastName = 'TestAccnt1Con';
        objAccnt1Contact1.Email = 'test@gmail.com';
        objAccnt1Contact1.RecordTypeId = rectContact.Id;
        objAccnt1Contact1.AccountId = acclist[0].Id;
        objAccnt1Contact1.Tag__c = 'Federal Contact';
        accContactList.add(objAccnt1Contact1);
        
        insert accContactList;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='ADP Partner Contact Request' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        
        case newcase1 = new case();
        newcase1.Subject = 'testing';
        newcase1.Issue_Type__c ='Other';
        newcase1.Description = 'testing';
        newcase1.Priority='Low';
        newcase1.Associate_First_Name__c = 'TestFirst001';
        newcase1.Preferred_Method_of_Contact__c = 'Email';
        //newcase1.Status = 'Closed';
        //newcase1.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase1.Status = 'Open';
        
        newcase1.RecordTypeId =rt.id;
        newcase1.Support_Region__c = 'Middle East';
        newcase1.Reason = 'Approved';
        newcase1.ADPEmail__c = 'test@gmail.com';
        newcase1.AccountId = acclist[0].id;
        newcase1.Admin__c = true;
        
        insert newcase1;
        try{
            delete newcase1;
            undelete newcase1;
        } catch(Exception exp){}
    }
    
    static testmethod void  testClarifyCase(){
        
        List<Account> acclist = CaseTriggerTest.createAccounts();
        
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.Firstname='First';
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'test@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        accContactList.add(objAccnt1Contact0);
        Insert accContactList;
        
        Profile p = [select Id,name from Profile where name = 'System Administrator' limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='MR Customer Account Creation' Limit 1];
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        
        
        case newcase = new case();
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other';
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        newcase.Status = 'Closed';
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        
        //insert newcase;
        system.debug('newcase.CreatedBy.ContactId----'+newcase.CreatedBy.ContactId);
        newcase.Subject ='sample';
        
        //update newcase;
        
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='Department of Defense',Community__c='Federal MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States');
        insert CAM;
    }
    
    static testmethod void  testClarifyCase1(){
        List<Account> acclist = CaseTriggerTest.createAccounts();
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> accContactList = new List<Contact>();
        Contact objAccnt1Contact0 = new Contact();
        objAccnt1Contact0.LastName = 'TestAccnt1Con';
        objAccnt1Contact0.Email = 'test@gmail.com';
        objAccnt1Contact0.RecordTypeId = rectContact.Id;
        objAccnt1Contact0.AccountId = acclist[0].Id;
        accContactList.add(objAccnt1Contact0);
        Contact objAccnt1Contact1 = new Contact();
        objAccnt1Contact1.LastName = 'TestAccnt1Con';
        objAccnt1Contact1.Email = 'test@gmail.com';
        objAccnt1Contact1.RecordTypeId = rectContact.Id;
        objAccnt1Contact1.AccountId = acclist[4].Id;        
        accContactList.add(objAccnt1Contact1);
        Insert accContactList;
        
        Profile p = [select Id,name from Profile where name = 'System Administrator' limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='MR Customer Account Creation' Limit 1];
        ID CAS_RTId = Schema.SObjectType.Case.RecordTypeInfosByName.get('RTM').RecordTypeId;
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MSI Support Case').RecordTypeId; //('MR Customer Account Creation').RecordTypeId;
        Id caseupdRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        CaseTeamRole role = [Select ID from CaseTeamRole where Name = 'Support Request Owner' LIMIT 1];
        Case_Record_Type_Support_Request__c CaseSupportRequest = new Case_Record_Type_Support_Request__c();
        CaseSupportRequest.Active_Trigger__c = True;
        CaseSupportRequest.Case_TeamRoleId__c = role.id;
        CaseSupportRequest.Case_Record_Type_Support_Request__c =rt.id;
        insert CaseSupportRequest; 
        User theuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        List<Case> shareCases = new List<Case>();
        Case newcase11 = new Case();
        newcase11.Subject = 'testing';
        newcase11.Issue_Type__c ='Other';
        newcase11.Description = 'testing';
        newcase11.Priority='Low';
        newcase11.Preferred_Method_of_Contact__c = 'Email';
        //newcase11.Status = 'Closed';  //passing Validation rule "Closed cases cannot be edited"
        newcase11.Status = 'Open';
        newcase11.OwnerId = theuser.Id;
        insert newcase11; 
        shareCases.add(newcase11);
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.caseShareForCaseRequestor(shareCases);
        Case newcase = new Case();
        newcase.Subject = 'testing';
        newcase.Issue_Type__c ='Other';
        newcase.Description = 'testing';
        newcase.Priority='Low';
        newcase.Preferred_Method_of_Contact__c = 'Email';
        newcase.Status = 'Closed';
        newcase.RecordTypeId =rt.id;
        newcase.Support_Region__c = 'Middle East';
        newcase.Reason = 'Approved';
        newcase.ADPEmail__c = 'test@gmail.com';
        newcase.AccountId = acclist[0].id;
        //insert newcase
        system.debug('newcase.CreatedBy.ContactId----'+newcase.CreatedBy.ContactId);
        newcase.Subject ='sample';
        //update newcase;        
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='Department of Defense',Community__c='Federal MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States');
        insert CAM;
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        //User accOwner = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        Id accMCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Account mcnAcc = new Account(name='newMCNAcc5');
        //mcnAcc.Type ='Customer';
        mcnAcc.RecordTypeId=accMCNrectypeID;
        mcnAcc.ParentId=acclist[0].Id;     
        mcnAcc.BillingCity = 'ONTARIO';
        mcnAcc.BillingCountry = 'United states';
        mcnAcc.BillingState = 'Iowa';
        mcnAcc.Region__c='NA';
        mcnAcc.Territory__c = 'T3';
        mcnAcc.Primary_Route_to_Market__c='MSI Led';
        insert mcnAcc;
        if(!Test.isRunningtest()){
            Case newcase22 = new Case();
            newcase22.Subject = 'testing';
            newcase22.Issue_Type__c ='Other';
            newcase22.Description = 'testing';
            newcase22.Priority='Low';
            newcase22.Preferred_Method_of_Contact__c = 'Email';
            newcase22.Status = 'New';
            newcase22.RecordTypeId =CAS_RTId;
            newcase22.ASM_Approval_Status__c ='In Approval';
            newcase22.AccountId = mcnAcc.Id;
            newcase22.Assigned_ASM__c=CAMuser.id;
            newcase22.OwnerID=userinfo.getUserId();
            newcase22.Proposed_Route_to_Market__c ='Open';            
            
            insert newcase22;
        
        
        
        List<Case> caseList = new List<Case>();
        caseList.add(newcase22);
        CaseTriggerHelper casHelper = new CaseTriggerHelper();
        casHelper.RTMCaseCreation(caseList);
        }
        ID partnerAccRecordId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner').RecordTypeId;
        List<Account> lstPartAccount = TestDataSetUpUtils.createAccounts(1,partnerAccRecordId);
        ID partnerRecordId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        List<Contact> lstContacts =  TestDataSetUpUtils.createContacts(1,partnerRecordId,lstPartAccount);        
        User partneruser = TestDataSetUpUtils.createPartnerAdministrator(lstContacts[0].id,'NAMR');
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = acclist[0].Id;
        accountShare.UserOrGroupId = partneruser.ID ;
        accountShare.AccountAccessLevel = 'Edit';
        accountShare.ContactAccessLevel = 'Edit';
        accountShare.CaseAccessLevel = 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        insert accountShare; 
        AccountShare accountShare1 = new AccountShare();
        accountShare1.AccountId = acclist[4].Id;
        accountShare1.UserOrGroupId = partneruser.ID ;
        accountShare1.AccountAccessLevel = 'Edit';
        accountShare1.ContactAccessLevel = 'Edit';
        accountShare1.CaseAccessLevel = 'Edit';
        accountShare1.OpportunityAccessLevel = 'Edit';
        insert accountShare1; 
        Case newcase23 = new Case();
        System.runAs(partneruser){
            test.starttest();
            newcase23.Subject = 'testing';
            newcase23.Issue_Type__c ='Other';
            newcase23.Description = 'testing';
            newcase23.Priority='Low';
            newcase23.Preferred_Method_of_Contact__c = 'Email';
            newcase23.Status = 'New';
            newcase23.RecordTypeId =caseRecordTypeId;
            newcase23.AccountId = acclist[0].Id;
            newcase23.ContactId = accContactList.get(0).Id;
            insert(newcase23);

            Case newcase24 = new Case();
            newcase24.Subject = 'testing';
            newcase24.Issue_Type__c ='Other';
            newcase24.Description = 'testing';
            newcase24.Priority='Low';
            newcase24.Preferred_Method_of_Contact__c = 'Email';
            newcase24.Status = 'New';
            newcase24.RecordTypeId =caseRecordTypeId;                    //caseupdRecordTypeId;
            newcase24.AccountId = acclist[4].Id;
            newcase24.ContactId = accContactList.get(1).Id;
            insert newcase24;
            test.stoptest();
        }
        system.debug('newcase23.CreatedBy.ContactId==>' +newcase23.CreatedBy.ContactId);
        newcase23.ASM_Approval_Status__c = 'Approved';
        update newcase23;

    }
    static testmethod void  handleDealtest(){
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();  
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();         
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id msiSupportCase =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'Admin_Service_Case');
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, accList);
        
        
        ID partnerAccRecordId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner').RecordTypeId;
        List<Account> lstPartAccount = TestDataSetUpUtils.createAccounts(1,partnerAccRecordId);
        ID partnerRecordId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        List<Contact> lstContacts =  TestDataSetUpUtils.createContacts(1,partnerRecordId,lstPartAccount);        
        //User currentUser = TestDataSetUpUtils.createPartnerAdministrator(lstContacts[0].id,'NAMR');
        User Usr = new User(ContactId=lstContacts[0].id, FirstName='NAMR', LastName='Partner', alias='abcd', email='NAMR@partner.com', 
        username='MRDRNAMREAPROFILE@partner.com', communityNickname='testGuy', profileId=Label.EA_Partner_Profile, 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
        Theater__c='NAMR',Primary_Business_Group__c = 'Government'); 
        insert Usr;
        
        Id oppoId = OppList.get(0).Id;
        OpportunityShare oppShare1 = new OpportunityShare();
        oppShare1.OpportunityAccessLevel='Edit';
        oppShare1.OpportunityId=oppoId;
        oppShare1.UserOrGroupId=Usr.Id;
        insert oppShare1;
        
        System.runAs(Usr){
            case newcase1 = new case();
            newcase1.Subject = 'testing';
            newcase1.Issue_Type__c ='Other';
            newcase1.Description = 'testing';
            newcase1.Priority='Low';
            newcase1.Associate_First_Name__c = 'TestFirst001';
            newcase1.Preferred_Method_of_Contact__c = 'Email';
            newcase1.Status = 'Open';
            newcase1.RecordTypeId =msiSupportCase;        
            newcase1.Related_Opportunity__c=oppoId;
            try{
                insert newcase1;
                CaseTriggerHelper trigHelper = new CaseTriggerHelper();
                trigHelper.handleDeaExtention(new List<Id>{oppoId},new List<Case>{newcase1});
            }
            catch(exception ex){
                System.debug('exception print'+ex);
            }
        }
        
    }
    static testmethod void serviceCloudCases(){
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> custAcclist = TestDataSetUpUtils.createAccounts(1, customerRTId);
        List<Account> mcnAcclist = TestDataSetUpUtils.createAccounts(1, mcnRecId);
        mcnAcclist[0].parentId=custAcclist[0].id;
        update mcnAcclist; 
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,custAcclist);
        
        Id sc1 =  GlobalUtility.getRecordTypeIdByDeveloperName('Case','Admin_Service_Case');
        Case cs2 = new case();
        cs2.Accountid = custAcclist[0].id;
        cs2.ContactId = contactList[0].id;
        cs2.RecordTypeId = sc1;
        insert cs2;
    }
    
    static testmethod void serviceCloudCases1(){
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> custAcclist = TestDataSetUpUtils.createAccounts(1, customerRTId);
        List<Account> mcnAcclist = TestDataSetUpUtils.createAccounts(1, mcnRecId);
        mcnAcclist[0].parentId=custAcclist[0].id;
        update mcnAcclist;   
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,custAcclist);
        Id sc3 =  GlobalUtility.getRecordTypeIdByDeveloperName('Case','MSI_Support_Case_Technical_Request');
        Technical_Site__c techSite = new Technical_Site__c(
            MCN_Account__c = mcnAcclist[0].id,
            Customer__c = custAcclist[0].id,
            Status__c = 'Inactive',
            Site_Type__c= 'Inactive',
            Site_ID__c = '12345'+system.now()
        );
        insert techSite;
        Case cs3 = new Case();
        cs3.AccountId = techSite.Customer__c;
        cs3.Technical_Site__c = techSite.Id;
        cs3.RecordTypeId = sc3;
        cs3.ContactId = contactList[0].id;
        insert cs3;
    }
    static testmethod void  testClarifyCaseNewFix(){
        List<Account> acclist = CaseTriggerTest.createAccounts();
        RecordType rectContact=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Contact' and r.name='Partner'];
        
       // Test.startTest();
        Profile p = [select Id,name from Profile where name = 'System Administrator' limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='case' and Name='MR Customer Account Creation' Limit 1];
        ID CAS_RTId = Schema.SObjectType.Case.RecordTypeInfosByName.get('RTM').RecordTypeId;
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id caseupdRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        
        User theuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        List<Case> shareCases = new List<Case>();
        
        
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='Department of Defense',Community__c='Federal MR',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States');
        insert CAM;
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        //User accOwner = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        Id accMCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Account mcnAcc = new Account(name='newMCNAcc5');
        //mcnAcc.Type ='Customer';
        mcnAcc.RecordTypeId=accMCNrectypeID;
        mcnAcc.ParentId=acclist[0].Id;     
        mcnAcc.BillingCity = 'ONTARIO';
        mcnAcc.BillingCountry = 'United states';
        mcnAcc.BillingState = 'Iowa';
        mcnAcc.Region__c='NA';
        mcnAcc.Motorola_Customer_Number__c='10000111';
        mcnAcc.Territory__c = 'T3';
        mcnAcc.Primary_Route_to_Market__c='MSI LED';
        insert mcnAcc;
        // if(Test.isRunningtest()){
            Case newcase22 = new Case();
            newcase22.Subject = 'testing';
            newcase22.Issue_Type__c ='Other';
            newcase22.Description = 'testing';
            newcase22.Priority='Low';
            newcase22.Preferred_Method_of_Contact__c = 'Email';
            newcase22.Status = 'New';
            //newcase22.RecordTypeId =CAS_RTId;
            newcase22.ASM_Approval_Status__c ='In Approval';
            newcase22.AccountId = mcnAcc.Id;
            newcase22.Assigned_ASM__c=CAMuser.id;
            
            newcase22.Assigned_ASM__c=userinfo.getUserId();
            newcase22.OwnerID=userinfo.getUserId();
            //newcase22.Proposed_Route_to_Market__c ='Open';                       
            insert newcase22;
            
            List<Case> caseList = new List<Case>();
            caseList.add(newcase22);
            CaseTriggerHelper casHelper = new CaseTriggerHelper();
            casHelper.RTMCaseCreation(caseList);
            
     //   }        
       // test.stoptest();
    }
    
}