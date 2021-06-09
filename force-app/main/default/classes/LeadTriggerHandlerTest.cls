/*  
* Class Name  : LeadTriggerHandlerTest
* Description:  This class is used in Lead trigger              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   1 February 2018    Vivek         Remove APAC Call Center Lead record type 
* 1.1  27 February 2018    Shahanawaz    This test class covered the LeadTriggerHandler class.
*/

@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup static void testSetUp() {
    	TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest static void testmethodOne() {       
        LM_StateCode__c lmSCode1= new LM_StateCode__c();
        lmSCode1.Country__c ='Canada';
        lmSCode1.Name = 'Alberta';
        lmSCode1.State_Code__c = 'AB';
        insert lmSCode1;
        /*OppStageUpdate__c LS = new OppStageUpdate__c(Name='Current',Disable_Trigger__c =false);  
        insert LS; */
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Userrole ur=[select id,name from userrole where name = 'Worldwide Sales'];
        
        User u3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                           EmailEncodingKey='UTF-8',FirstName='First', LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='QHVX471',
                                    Core_ID__c='QHVX471',CommunityNickname = 'QHVX471',EmployeeNumber='QHVX471');
        insert u3;
        User user4 = new User(Alias = 'ran45', Email='testabc123@motorolasolutions.com', 
                              EmailEncodingKey='UTF-8',FirstName='First', LastName='Testing3', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='LHVX471',
                                    Core_ID__c='LHVX471',CommunityNickname = 'LHVX471',EmployeeNumber='LHVX471');
        
        insert user4;
        // InsertParent Account
        Account pa = new Account();
        pa.Name = 'ParentAccount';
        pa.Hierarchy_Placement__c = 'Global Account';
        pa.Partner_Region__c = 'APAC';
        pa.BillingCity='Bangalore';
        pa.BillingCountry='India';
        insert pa;
        //Insert account
        RecordType objLeadRecTypeAcc = [Select Id from RecordType where sObjectType ='Account' And DeveloperName ='Motorola_Customer_Number' limit 1];
        Account acc= new Account(Customer_or_Prospect_Account__c = pa.Id,Name = 'Test123', Hierarchy_Placement__c = 'Global Account', Partner_Region__c = 'APAC', RecordTypeId = objLeadRecTypeAcc.ID,BillingCity='Bangalore',BillingCountry='India');
        insert acc;
        //Insert partner account and contact
        Id PartnerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        List<Account> PartnerAccList = TestDataSetUpUtils.createAccounts(1,PartnerRecordTypeID);
        PartnerAccList[0].Radio_Leads__c = true;
        update PartnerAccList;
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,PartnerAccList);
        contactList[0].Contact_Type__c = 'Lead Contact';
        contactList[1].Contact_Type__c = 'Lead Contact';
        Update contactList;
 
        Campaign camp = new Campaign();
        camp.Name='Onvia_Pursuits_Term_Contracts';
        insert camp;
        Product2 prod = new Product2();
        prod.Name = 'Prod1';
        prod.IsActive = true;
        prod.Personal_Information__c='Yes';
        // prod.APC__c = 'test';
        //prod.Business_Group__c = 'Enterprise';
        insert prod;
        
        CAM_Geo_Map__c usCamDetails = new CAM_Geo_Map__c();
        usCamDetails.Functions__c = 'Lead Mgt';
        usCamDetails.region__c ='NAMR'; 
        usCamDetails.State_Province__c = 'AK';
        usCamDetails.Country__c = 'USA';
        usCamDetails.Territory__c = 'T1';
        usCamDetails.Channel_Account_Manager__c = u3.id;
        usCamDetails.Indirect_Channel_Account_Manager__c = u3.id;
        usCamDetails.Status__c = 'New';
        usCamDetails.Vertical__c = 'Education';
        usCamDetails.Track__c = 'Direct';
        usCamDetails.product_family__c = prod.id;
        insert usCamDetails;
        
        CAM_Geo_Map__c usCamDetails1 = new CAM_Geo_Map__c();
        usCamDetails1.Functions__c = 'Lead Mgt';
        usCamDetails1.region__c ='NAMR'; 
        usCamDetails1.State_Province__c = 'IN';
        usCamDetails1.Country__c = 'Canada';
        usCamDetails1.Territory__c = 'Africa';
        usCamDetails1.Channel_Account_Manager__c = u3.id;
        usCamDetails1.Indirect_Channel_Account_Manager__c = u3.id;
        usCamDetails1.Status__c = 'New';
        usCamDetails1.product_family__c = prod.id;
        insert usCamDetails1;
        
        CAM_Geo_Map__c defCamDetails = new CAM_Geo_Map__c();
        defCamDetails.Functions__c = 'Lead Mgt';
        defCamDetails.region__c ='NAMR'; 
        defCamDetails.State_Province__c = 'AB';
        defCamDetails.Country__c = 'Canada';
        defCamDetails.Territory__c = 'Africa';
        defCamDetails.Channel_Account_Manager__c = u3.id;
        defCamDetails.Indirect_Channel_Account_Manager__c = u3.id;
        defCamDetails.Status__c = 'New';
        defCamDetails.Track__c = 'Direct';
        insert defCamDetails;
        
        defCamDetails.Country__c = 'DEFAULT OWNER NAMR';
        update defCamDetails;
        LM_StateCode__c lmSCode= new LM_StateCode__c();
        lmSCode.Country__c ='Canada';
        lmSCode.Name = 'Alberta';
        lmSCode.State_Code__c = 'AB';
        insert lmSCode;
        
        CDH_Country_Region_Mapping__c cdh = new CDH_Country_Region_Mapping__c();
        cdh.Name = 'CA';
        cdh.Country__c = 'Canada';
        insert cdh;
        
        AccAndConData__c accdh = new AccAndConData__c();
        accdh.Name = 'Current';
        accdh.NAMRPartnerAdminProfileID__c = '';
        accdh.NAMRPartnerProfileID__c = '';
        insert accdh;
        
        LM_GeoCodeMaxLimit__c geoLimit = new LM_GeoCodeMaxLimit__c();
        geoLimit.Name = 'GeoCode Limit';
        geoLimit.LM_limit__c = 100;
        insert geoLimit;
        User thisUsr = [Select Id from User where Id = :UserInfo.getUserId()];
        //Insert lead
        RecordType objLeadRecType = [Select Id from RecordType where sObjectType='Lead' And DeveloperName='Global_Lead_Record' limit 1];
        Test.startTest();
        try{
            Lead objlead = new Lead();
            objlead.Company = 'IT';
            objlead.Status = 'Marketing Lead';
            objlead.Track__c = 'Direct';
            objlead.Region__c = 'NA';
            objlead.LastName = 'Test';
            objlead.Industry = 'Education';
            objlead.Email = 'test@gmail.com';
            objlead.Country='Canada';
            objlead.State = 'Alberta';
            objlead.Street = 'New Colony';
            objlead.Territory__c = 'T1';
            objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
            objlead.City ='test';
            objlead.Account__c = pa.Id;
            objlead.Visitor_Info__c = 'Test Visitor';
            objlead.Technology_Segment__c = 'Accessories & Energy';
            objlead.RecordTypeId = objLeadRecType.ID;
            objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
            objlead.Indirect_CAM__c = u3.id;
            objlead.Channel_Partner__c = acc.id;
            objlead.Overdue_Status__c = 'Overdue';
            objlead.Countrycode = 'CA';
            objlead.Statecode = 'AB';
            objlead.Lead_Value__c = 50;
            objlead.OwnerId = thisUsr.id;
            objlead.Partner_Assigned_Status__c = 'Reassign';
            objlead.Partner_Account_NA__c = PartnerAccList[0].Id;
            objlead.Partner_Assigned_Contact_NA__c = contactList[0].Id;
            insert objlead;
            
            objlead.Status = 'Marketing Lead';
            objlead.Street = 'Test New Colony';
            objlead.Indirect_CAM__c = user4.id;
            objlead.Email = '123@gmail.com';
            objlead.Partner_Assigned_Status__c = 'On time';
            objlead.Track__c = 'Mobility';
            objlead.Countrycode = 'US';
            objlead.Statecode = 'AK';
            objlead.Technology_Segment__c = 'ASTRO Devices';
            objlead.Partner_Assigned_Contact_NA__c = contactList[1].Id;
            update objlead;
        }catch(Exception ex){
            System.debug('exception == '+ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo() {
        // InsertParent Account
        Account pa = new Account();
        pa.Name = 'ParentAccount';
        pa.Hierarchy_Placement__c = 'Global Account';
        pa.Partner_Region__c = 'APAC';
        pa.BillingCity='Bangalore';
        pa.BillingCountry='India';
        insert pa;
        
        //Insert account
        RecordType objLeadRecTypeAcc = [Select Id from RecordType where sObjectType ='Account' And DeveloperName ='Motorola_Customer_Number' limit 1];
        Account acc= new Account(Customer_or_Prospect_Account__c = pa.Id,Name = 'Test123', Hierarchy_Placement__c = 'Global Account', Partner_Region__c = 'APAC', RecordTypeId = objLeadRecTypeAcc.ID,BillingCity='Bangalore',BillingCountry='India');
        insert acc;
        //Insert partner account and contact
        Id PartnerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        List<Account> PartnerAccList = TestDataSetUpUtils.createAccounts(1,PartnerRecordTypeID);
        PartnerAccList[0].Radio_Leads__c = true;
        update PartnerAccList;
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,PartnerAccList);
        contactList[0].Contact_Type__c = 'Lead Contact';
        contactList[1].Contact_Type__c = 'Lead Contact';
        Update contactList;
        Test.startTest(); 
        //Insert lead
        RecordType objLeadRecType = [Select Id from RecordType where sObjectType='Lead' And DeveloperName='Global_Lead_Record' limit 1];
        Lead objlead = new Lead();
        objlead.Company = 'IT';
        objlead.Status = 'Marketing Lead';
        objlead.Track__c = 'Direct';
        objlead.Region__c = 'NA';
        objlead.LastName = 'Test';
        objlead.Industry = 'Education';
        objlead.Email = 'test@gmail.com';
        objlead.Country='Canada';
        objlead.State = 'Alberta';
        objlead.Street = 'New Colony';
        objlead.Territory__c = 'T1';
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.City ='test';
        objlead.Account__c = pa.Id;
        objlead.Visitor_Info__c = 'Test Visitor';
        objlead.Technology_Segment__c = 'Accessories & Energy';
        objlead.RecordTypeId = objLeadRecType.ID;
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.Channel_Partner__c = acc.id;
        objlead.Overdue_Status__c = 'Overdue';
        objlead.Countrycode = 'CA';
        objlead.Statecode = 'AB';
        objlead.Lead_Value__c = 50;
        objlead.Partner_Assigned_Status__c = 'Reassign';
        objlead.Partner_Account_NA__c = PartnerAccList[0].Id;
        objlead.Partner_Assigned_Contact_NA__c = contactList[0].Id;
        insert objlead;
        
        objlead.Status = 'Marketing Lead';
        objlead.Street = 'Test New Colony';
        objlead.Email = '123@gmail.com';
        objlead.Partner_Assigned_Status__c = 'On time';
        objlead.Track__c = 'Direct';
        objlead.Countrycode = 'US';
        objlead.Statecode = 'AK';
        objlead.Technology_Segment__c = 'ASTRO Devices';
        objlead.Partner_Assigned_Contact_NA__c = contactList[1].Id;
        update objlead;
        Test.stopTest();
    }
    
    @isTest static void LM_PartnerLeadManagementGlobalBeforeInsertTest(){
        Test.startTest();
        List<User> currentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //insert user
        User user3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                              EmailEncodingKey='UTF-8',FirstName='Onvia', LastName='Integration', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='QJVX471',
                                    Core_ID__c='QJVX471',CommunityNickname = 'QJVX471',EmployeeNumber='QJVX471');
        
        System.runAs(currentUser[0]){
            insert user3;
        }
        
        Product2 prod = new Product2();
        prod.Name = 'Prod1';
        prod.IsActive = true;
        prod.Personal_Information__c='Yes';
        //prod.APC__c = 'test';
        //prod.Business_Group__c = 'Enterprise';
        insert prod;
        
        CAM_Geo_Map__c usCamDetails = new CAM_Geo_Map__c();
        usCamDetails.Functions__c = 'Lead Mgt';
        usCamDetails.region__c ='NAMR'; 
        usCamDetails.State_Province__c = 'AB';
        usCamDetails.Country__c = 'Canada';
        usCamDetails.Territory__c = 'Africa';
        usCamDetails.Channel_Account_Manager__c = user3.id;
        usCamDetails.Indirect_Channel_Account_Manager__c = user3.id;
        usCamDetails.Status__c = 'New';
        usCamDetails.Vertical__c = 'Education';
        usCamDetails.Track__c = 'Direct';
        usCamDetails.product_family__c = prod.id;
        
        insert usCamDetails;
        
        // InsertParent Account
        Account pa = new Account();
        pa.Name = 'ParentAccount';
        pa.Hierarchy_Placement__c = 'Global Account';
        pa.Partner_Region__c = 'APAC';
        pa.BillingCity='Bangalore';
        pa.BillingCountry='India';
        //insert pa;
        
        RecordType objLeadRecTypeAcc = [Select Id from RecordType where sObjectType ='Account' And DeveloperName ='Motorola_Customer_Number' limit 1];
        Account acc= new Account(Customer_or_Prospect_Account__c = pa.Id,Name = 'Test123', Hierarchy_Placement__c = 'Global Account', Partner_Region__c = 'APAC', RecordTypeId = objLeadRecTypeAcc.ID,BillingCity='Bangalore',BillingCountry='India');
        Insert acc;
        
        //insert partner account and contact
        Id PartnerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        List<Account> PartnerAccList = TestDataSetUpUtils.createAccounts(1,PartnerRecordTypeID);
        PartnerAccList[0].Radio_Leads__c = true;
        update PartnerAccList;
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(1,contactRecordTypeID,PartnerAccList);
        contactList[0].Contact_Type__c = 'Lead Contact';
        //contactList[1].Contact_Type__c = 'Lead Contact1';
        Update contactList;
        
        //Insert lead
        /* RecordType objLeadRecType = [Select Id from RecordType where sObjectType='Lead' And DeveloperName='Global_Lead_Record' limit 1];
        Lead objlead = new Lead();
        objlead.Company = 'IT';
        objlead.Status = 'Marketing Lead';
        objlead.Track__c = 'Direct';
        objlead.Region__c = 'NA';
        objlead.LastName = 'Test';
        objlead.Industry = 'Education';
        objlead.Email = 'test@gmail.com';
        objlead.Country='Canada';
        objlead.State = 'Alberta';
        objlead.Street = 'New Colony';
        objlead.Territory__c = 'T1';
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.City ='test';
        //objlead.Account__c = pa.Id;
        objlead.Visitor_Info__c = 'Test Visitor';
        objlead.Technology_Segment__c = 'Accessories & Energy';
        objlead.RecordTypeId = objLeadRecType.ID;
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.Indirect_CAM__c = user3.id;
        //objlead.Channel_Partner__c = acc.id;
        objlead.Overdue_Status__c = 'Overdue';
        objlead.Countrycode = 'CA';
        objlead.Statecode = 'AB';
        objlead.Lead_Value__c = 50;
        objlead.OwnerId = user3.id;
        objlead.Partner_Assigned_Status__c = 'Reassign';
        insert objlead; */
        Campaign camp1 = new Campaign(Name = 'Onvia_Pursuits_Term_Contracts', IsActive = True);
        Insert camp1;
        
        RecordType objLeadRecType = [Select Id from RecordType where sObjectType='Lead' And DeveloperName='Global_Lead_Record' limit 1];
        Lead objlead = new Lead();
        objlead.Company = 'ITTest';
        objlead.Status = 'Marketing Lead';
        objlead.Track__c = 'Radio';
        objlead.Region__c = 'NA';
        objlead.LastName = 'Test';
        objlead.Industry = 'Education';
        objlead.Email = 'test123@ggmail.com';
        objlead.Country='Canada';
        objlead.State = 'Alberta';
        objlead.Street = 'New Colony';
        objlead.Territory__c = 'T1';
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.City ='test';
        objlead.Account__c = pa.Id;
        objlead.Visitor_Info__c = 'Test Visitor';
        objlead.Technology_Segment__c = 'Accessories & Energy';
        objlead.RecordTypeId = objLeadRecType.ID;
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.Indirect_CAM__c = user3.id;
        objlead.Channel_Partner__c = acc.id;
        objlead.Overdue_Status__c = 'Overdue';
        objlead.Countrycode = 'CA';
        objlead.Statecode = 'AB';
        objlead.Lead_Value__c = 50;
        objlead.OwnerId = user3.id;
        objlead.Partner_Assigned_Status__c = 'Reassign';
        objlead.Partner_Account_NA__c = PartnerAccList[0].Id;
        objlead.Partner_Assigned_Contact_NA__c = contactList[0].Id;
        insert objlead;
        
        objlead.Status = 'Marketing Lead';
        objlead.Street = 'Test New Colony';
        objlead.Indirect_CAM__c = user3.id;
        objlead.Email = '123@gmail.com';
        objlead.Partner_Assigned_Status__c = 'On time';
        objlead.Track__c = 'Mobility';
        objlead.Countrycode = 'US';
        objlead.Statecode = 'AK';
        objlead.Technology_Segment__c = 'ASTRO Devices';
        //objlead.Partner_Assigned_Contact_NA__c = contactList[1].Id;
        //update objlead;
        Test.stopTest();
    }
    
    @isTest static void LM_PartnerLeadManagementGlobalBeforeInsertTest1(){
        
        LM_StateCode__c lmSCode3= new LM_StateCode__c();
        lmSCode3.Country__c ='Canada';
        lmSCode3.Name = 'Alberta';
        lmSCode3.State_Code__c = 'AB';
        insert lmSCode3;
        Id accRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id partnerAccRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id objLeadRecType = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, accRecId);
        List<Account> partnerAccountList = TestDataSetUpUtils.createAccounts(1, partnerAccRecId);
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //insert user
        User u3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                           EmailEncodingKey='UTF-8', FirstName='First',LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com');
        insert u3;
        String dt ='12/31/2018';  
        date CloseDT=date.parse(dt);*/
        
        // InsertParent Account
        /*Account pa = new Account();
        pa.Name = 'ParentAccount';
        pa.Hierarchy_Placement__c = 'Global Account';
        pa.Partner_Region__c = 'APAC';
        pa.BillingCity='Bangalore';
        pa.BillingCountry='India';*/
        //insert pa;
        
        //Insert account
        //RecordType objLeadRecTypeAcc = [Select Id from RecordType where sObjectType ='Account' And DeveloperName ='Motorola_Customer_Number' limit 1];
        //Account acc= new Account(Customer_or_Prospect_Account__c = pa.Id,Name = 'Test123', Hierarchy_Placement__c = 'Global Account', Partner_Region__c = 'APAC', RecordTypeId = objLeadRecTypeAcc.ID,BillingCity='Bangalore',BillingCountry='India');
        //insert acc;
        
        //Insert lead
        /*Lead objlead1 = new Lead();
        objlead1.Company = 'ITtestinggg';
        objlead1.Status = 'Marketing Lead';
        objlead1.Track__c = 'Direct';
        objlead1.Region__c = 'NA';
        objlead1.LastName = 'Test';
        objlead1.Industry = 'Education';
        objlead1.Email = 'test@testgmail.com';
        objlead1.Country='Canada';
        objlead1.State = 'Alberta';
        objlead1.Street = 'New Colony';
        objlead1.Territory__c = 'T1';
        objlead1.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead1.City ='test';
        //objlead.Account__c = pa.Id;
        objlead1.Visitor_Info__c = 'Test Visitor';
        objlead1.Technology_Segment__c = 'Accessories & Energy';
        objlead1.RecordTypeId = objLeadRecType.ID;
        objlead1.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead1.Indirect_CAM__c = u3.id;
        //objlead.Channel_Partner__c = acc.id;
        objlead1.Overdue_Status__c = 'Overdue';
        objlead1.Countrycode = 'CA';
        objlead1.Statecode = null;
        objlead1.Lead_Value__c = 50;
        objlead1.OwnerId = UserInfo.getUserId();
        insert objlead1;
        objlead1.Close_Date__c = CloseDT;
        objlead1.Status  = 'Qualified';
		update objlead1;*/
        Test.startTest();
        Lead objlead1 = new Lead(lastname = 'Fry', company='Test Account', Lead_Value__c = 12345.00,
                                 Region__c = 'NA', Technology_Segment__c = 'ASTRO Devices', Country = 'United States',
                                 Email = 'abc@org.com', Lead_Type__c = 'MR', RecordTypeId = objLeadRecType,
                                 Industry='Healthcare', State='illinois', Close_Date__c = Date.today()+10, Territory__c = 'T2',
                                 SAL__c =true, Status = 'Qualified',City ='Chicago',Street ='Mall Road',
                                 Account__c= AccountList.get(0).Id);
        Insert objlead1;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(objlead1.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }
    
    @isTest static void LM_PartnerLeadManagementGlobalBeforeInsertTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Test.startTest();
        User u3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                           EmailEncodingKey='UTF-8', FirstName='First',LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='QHVX471',
                                    Core_ID__c='QHVX471',CommunityNickname = 'QHVX471',EmployeeNumber='QHVX471');
        insert u3;
        
        CAM_Geo_Map__c defCamDetails = new CAM_Geo_Map__c();
        defCamDetails.Functions__c = 'Lead Mgt';
        defCamDetails.region__c ='NAMR'; 
        defCamDetails.State_Province__c = 'AB';
        defCamDetails.Country__c = 'DEFAULT OWNER NAMR';
        defCamDetails.Territory__c = 'Africa';
        defCamDetails.Channel_Account_Manager__c = u3.id;
        defCamDetails.Indirect_Channel_Account_Manager__c = u3.id;
        defCamDetails.Status__c = 'New';
        defCamDetails.Track__c = 'Direct';        
        insert defCamDetails;
		Test.stopTest();        
    }
    
    @isTest public static void testRunner(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String dt ='12/31/2018';  
        date CloseDT=date.parse(dt);
        //insert user
        //Test.startTest();
        User u3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                           EmailEncodingKey='UTF-8', FirstName='First',LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='QHVX471',
                                    Core_ID__c='QHVX471',CommunityNickname = 'QHVX471',EmployeeNumber='QHVX471');
        insert u3;
        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        String RTStr=rt.Id;
        
        List<Account> twoAccounts = new List<Account>();
        Account acc1 = new Account(Name='testAccount1',Type='Partner',RECORDTYPEID=RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC',
                                   Radio_Leads__c = TRUE
                                  );
        twoAccounts.add(acc1);
        Account acc2 = new Account(Name='testAccount2',Type='Partner',RECORDTYPEID
                                   =RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC',
                                   Radio_Leads__c = TRUE
                                  );  
        twoAccounts.add(acc2);
        insert twoAccounts;
        Lead myLead = new Lead(lastname = 'lname111', Lead_Value__c=12345,Region__c='NA',Partner_Assigned_Status__c = 'Reassign 2',company='Fry And Sons',Partner_Account_NA__c = twoAccounts[1].id, Channel_Partner__c=twoAccounts[0].Id, Distributor__c=twoAccounts[1].Id,TRACK__c= 'Radio');
        insert myLead;
        User thisUsr = [ select Id from User where Id = :UserInfo.getUserId() ];
        mylead.Partner_Account_NA__c = twoAccounts[0].id;
        mylead.Status = 'Qualified';
        mylead.Partner_Assigned_Status__c ='Reassign';
        mylead.Lead_Value__c = 1222;
        mylead.Close_Date__c = CloseDT;
        mylead.OwnerId = thisUsr.id;
        Test.startTest();
        update mylead;
        Lead myLead1 = new Lead(lastname = 'lname123', Lead_Value__c=555,Region__c='AP',Partner_Assigned_Status__c = 'Reassign 2',company='Fry And Sons',Partner_Account_NA__c = twoAccounts[1].id, Channel_Partner__c=twoAccounts[0].Id, Distributor__c=twoAccounts[1].Id,TRACK__c= 'Radio');
        insert myLead1;
       
        mylead1.Partner_Account_NA__c = twoAccounts[0].id;
        mylead1.Status = 'Qualified';
        mylead1.Partner_Assigned_Status__c ='Reassign';
        mylead1.OwnerId = thisUsr.id;
        mylead1.Lead_Value__c = 1222;
        mylead1.Close_Date__c = CloseDT;
        update mylead1;
		Test.stopTest();
        //LeadTriggerHandler LTH = new LeadTriggerHandler();
        delete mylead;
        undelete mylead;
        //Test.stopTest();
    }
    
    @isTest public static void testAfterConvertLead(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String dt ='12/31/2018';  
        date CloseDT=date.parse(dt);
        
        User u3 = new User(Alias = 'ran12', Email='test12345@motorolasolutions.com', 
                           EmailEncodingKey='UTF-8', FirstName='First',LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@motorolasolutions.com',FederationIdentifier='QHVX471',
                                    Core_ID__c='QHVX471',CommunityNickname = 'QHVX471',EmployeeNumber='QHVX471');
        insert u3;
        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        String RTStr=rt.Id;
        
        List<Account> twoAccounts = new List<Account>();
        Account acc1 = new Account(Name='testAccount1',Type='Partner',RECORDTYPEID=RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC',
                                   Radio_Leads__c = TRUE
                                  );
        twoAccounts.add(acc1);
        Account acc2 = new Account(Name='testAccount2',Type='Partner',RECORDTYPEID
                                   =RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC',
                                   Radio_Leads__c = TRUE
                                  );  
        twoAccounts.add(acc2);
        insert twoAccounts;
        Lead myLead = new Lead(lastname = 'lname111', Lead_Value__c=12345,Region__c='NA',Partner_Assigned_Status__c = 'Reassign 2',company='Fry And Sons',Partner_Account_NA__c = twoAccounts[1].id, Channel_Partner__c=twoAccounts[0].Id, Distributor__c=twoAccounts[1].Id,TRACK__c= 'Radio');
        insert myLead;
        User thisUsr = [ select Id from User where Id = :UserInfo.getUserId() ]; 
        mylead.Partner_Account_NA__c = twoAccounts[0].id;
        mylead.Status = 'Qualified';
        mylead.Partner_Assigned_Status__c ='Reassign';
        mylead.Lead_Value__c = 1222;
        mylead.Close_Date__c = CloseDT;
        mylead.OwnerId = thisUsr.id;
        Test.startTest();
        update mylead;
        Lead myLead1 = new Lead(lastname = 'lname123', Lead_Value__c=555,Region__c='AP',Partner_Assigned_Status__c = 'Reassign 2',company='Fry And Sons',Partner_Account_NA__c = twoAccounts[1].id, Channel_Partner__c=twoAccounts[0].Id, Distributor__c=twoAccounts[1].Id,TRACK__c= 'Radio');
        insert myLead1;
        mylead1.Partner_Account_NA__c = twoAccounts[0].id;
        mylead1.Status = 'Qualified';
        mylead1.Partner_Assigned_Status__c ='Reassign';
        mylead1.OwnerId = u3.id;
        mylead1.Lead_Value__c = 1222;
        mylead1.Close_Date__c = CloseDT;
        mylead1.Track__c = 'Indirect';
        //mylead1.IsConverted = true;
        //update mylead1;
        mylead1.Lead_Type__c = 'KYC';
        update mylead1;
        
        LeadTriggerHandler LTH = new LeadTriggerHandler();
        delete mylead;
        undelete mylead;
        Test.stopTest();
    }
    
    @isTest static void testNewMethod(){
        Test.startTest();
        Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id leadRecTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, accRecTypeId);
        
        Lead leadRecord = new Lead(lastname = 'Fry', company='Fry And Sons', Lead_Value__c = 12345.00, Status = 'Qualified',
                                   Region__c = 'NA', Technology_Segment__c = 'ASTRO Devices', Country = 'United States',
                                   Email = 'abc@org.com', Lead_Type__c = 'MR', RecordTypeId = leadRecTypeId,
                                   Industry='Healthcare', State='illinois', Close_Date__c = Date.today()+10, Territory__c = 'T2',
                                   SAL__c =true,Onvia_Opportunity_Type__c = 'Bid',Account__c= AccountList.get(0).Id);
        Insert leadRecord;
        Lead leadRecord1 = new Lead(lastname = 'Fry', company='test And test', Lead_Value__c = 12345.00, Status = 'Qualified',
                                   Region__c = 'NA', Technology_Segment__c = 'ASTRO Devices', Country = 'United States',
                                   Email = 'test@gmail.com', Lead_Type__c = 'MR', RecordTypeId = leadRecTypeId,
                                   Industry='Healthcare', State='illinois', Close_Date__c = Date.today()+10, Territory__c = 'T2',
                                   SAL__c =true,Onvia_Opportunity_Type__c = 'Lead',Account__c= AccountList.get(0).Id);
        Insert leadRecord1;
        Lead leadRecord2 = new Lead(lastname = 'Fry', company='Demo Company', Lead_Value__c = 12345.00, Status = 'Qualified',
                                   Region__c = 'NA', Technology_Segment__c = 'ASTRO Devices', Country = 'United States',
                                   Email = 'leadtest@email.com', Lead_Type__c = 'MR', RecordTypeId = leadRecTypeId,
                                   Industry='Healthcare', State='illinois', Close_Date__c = Date.today()+10, Territory__c = 'T2',
                                   SAL__c =true,Onvia_Opportunity_Type__c = 'FBO Notice',Account__c= AccountList.get(0).Id,
                                   Partner_Assigned_Status__c = 'On time');
        Insert leadRecord2;
        Test.stopTest();
    }
    
    //Test method for testing Leads where Track='Direct' - SF-2468
    @isTest static void testDirectLeads(){
        
        List<Lead> leadsToInsert = new List<Lead>();
                
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = [SELECT Id FROM User WHERE ProfileId =: p1.Id LIMIT 1];
        
        RecordType globalLeadRecType = [SELECT Id,developerName FROM RecordType WHERE Name = 'Global Lead Record'];
        RecordType customerAccRecType = [SELECT Id,developerName FROM RecordType WHERE Name = 'Customer'];
        
        List<Account> accountList = TestDataSetUpUtils.createAccountsForLeads();
        system.debug('accountList :='+accountList);
		List<Product2> productList = TestDataSetUpUtils.createProductsForLeads(); 
        List<CAM_Geo_Map__c> camGeoMapList = TestDataSetUpUtils.createCamGeoMapforDirectLeads();
        
        Lead lead111 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead1', Track__c='Direct', Technology_Segment__c = productList[0].Name, OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead111);
        Lead lead112 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead1', Track__c='Business', Technology_Segment__c = productList[0].Name, OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead112);
        Lead lead1 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead1', Track__c='Direct', Technology_Segment__c = productList[0].Name, Account__c=accountList[0].Id,OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead1);
        
        Lead lead2 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead2', Track__c='Direct', Technology_Segment__c = productList[0].Name, Account__c=accountList[1].Id,OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead2);
        Lead lead3 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[0].Name, Account__c=accountList[2].Id,OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead3);
		Lead lead4 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[0].Name, Account__c=accountList[3].Id,OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead4);
        Lead lead5 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead4', Track__c='Direct', Technology_Segment__c = productList[1].Name, Account__c=accountList[0].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead5);
        Lead lead6 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead5', Track__c='Direct', Technology_Segment__c = productList[1].Name, Account__c=accountList[1].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead6);
        Lead lead7 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead5', Track__c='Direct', Technology_Segment__c = productList[1].Name, Account__c=accountList[2].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead7);
		Lead lead8 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead5', Track__c='Direct', Technology_Segment__c = productList[1].Name, Account__c=accountList[3].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead8);
        Lead lead9 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead6', Track__c='Direct', Technology_Segment__c = productList[2].Name, Account__c=accountList[0].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead9);
        Lead lead10 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead6', Track__c='Direct', Technology_Segment__c = productList[2].Name, Account__c=accountList[1].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead10);
        Lead lead11 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead6', Track__c='Direct', Technology_Segment__c = productList[2].Name, Account__c=accountList[2].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead11);
		Lead lead12 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead6', Track__c='Direct', Technology_Segment__c = productList[2].Name, Account__c=accountList[3].Id, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead12);
        Lead lead13 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead1', Track__c='Direct', Technology_Segment__c = productList[3].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead13);
        Lead lead14 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead2', Track__c='Direct', Technology_Segment__c = productList[3].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead14);
        Lead lead15 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[3].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead15);
		Lead lead16 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[3].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead16);
        Lead lead17 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead1', Track__c='Direct', Account__c=accountList[0].Id,OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead17);
        Lead lead18 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead2', Track__c='Direct', Account__c=accountList[1].Id,OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead18);
        Lead lead19 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Account__c=accountList[2].Id,OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead19);
		Lead lead20 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Account__c=accountList[3].Id,OwnerId = u1.Id,RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead20);
        Lead lead21 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[4].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead21);
        Lead lead22 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[5].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead22);
        Lead lead23 = new Lead(Status='Marketing Lead', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[6].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id);
        leadsToInsert.add(lead23);
        List<Account> accLeads= TestDataSetUpUtils.createAccountsForLeads();
        List<Lead> newLeads = new List<lead>();
        Set<String> productsOnLead = new Set<String>();
        Map<String,Lead> accountLeadMap = new Map<String,Lead>();
        Map<String,Lead> productLeadMap = new Map<String,Lead>();
        
        System.debug('productList[0].Name==>'+productList[0].Name);
		Test.startTest();        
        insert leadsToInsert;
        Lead lead24 = new Lead(Status='Inquiry', Company='Test Co.', Region__c='NA', Industry='Manufacturing', LastName='Test Lead3', Track__c='Direct', Technology_Segment__c = productList[0].Name, OwnerId = u1.Id, RecordTypeId=globalLeadRecType.Id,account__c=accleads[1].id,Country = 'United States',State='Illinois');
        insert lead24;
        lead24.status='Marketing Lead';
        update lead24;
        productsOnLead.add(lead24.Technology_Segment__c);
        productLeadMap.put(lead24.Technology_Segment__c,lead24);
        accountLeadMap.put(lead24.Account__c,lead24);
        newLeads.add(lead24);
        System.debug('Lead Values==>' + newLeads.get(0).Account__c +'--' + newLeads.get(0).status);
        LeadRoutingHelper l = new LeadRoutingHelper();
        l.methodForTrackDirect(productsOnLead,accountLeadMap,productLeadMap,newLeads);
		lead24.Technology_Segment__c = productList[5].Name;
        lead24.account__c=accleads[1].id;
        update lead24;
        newLeads.add(lead24);
        System.debug('newItems2==>'+newLeads);
        System.debug('Updated Lead Values==>' + newLeads.get(0).Account__c +'--' + newLeads.get(0).status);
		l.methodForTrackDirect(productsOnLead,accountLeadMap,productLeadMap,newLeads);
        Test.stopTest();
        /*try{
        LeadRoutingHelper l = new LeadRoutingHelper();
        l.insertSurveyToCustomer(new Set<Lead>(leadsToInsert));
        }catch(Exception ex){
            
        }*/
        }
        
}