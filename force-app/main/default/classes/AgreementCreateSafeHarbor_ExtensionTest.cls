@isTest
private class AgreementCreateSafeHarbor_ExtensionTest{
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

 static testMethod void validateSafeharborAgreement_Creation(){
 
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='Procurement' Limit 1]; 
        Profile p1 = [select id from profile where name='System Administrator'];  
     
        Apttus__APTS_Agreement__c procAgmt = new Apttus__APTS_Agreement__c();
         
         //User 1 
          User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser)
        {
        User user1 = new User ();
        user1.FirstName = 'Testuser'; 
        user1.LastName = 'One'; 
        user1.Username = 'Testuserone@motorolasolutions.com';
        user1.Email =  'Testuserone@motorolasolutions.com';
        user1.Alias = 'TOne1';
        user1.TimeZoneSidKey = 'America/Los_Angeles'; 
        user1.LocaleSidKey = 'en_US'; 
        user1.EmailEncodingKey = 'UTF-8'; 
        user1.ProfileId = p1.id; 
        user1.LanguageLocaleKey ='en_US'; 
        user1.Primary_Business_Group__c='Enterprise';
        user1.Core_ID__c='fffv';
        user1.CommunityNickname='fffv';
        user1.FederationIdentifier='fffv';
        user1.EmployeeNumber='fffv';
        user1.System_Integration__c = True;
        insert user1; 
        
        //User 2
        User user2 = new User ();
        user2.FirstName = 'Testuser'; 
        user2.LastName = 'Two'; 
        user2.Username = 'Testusertwo@motorolasolutions.com';
        user2.Email =  'Testusertwo@motorolasolutions.com';
        user2.Alias = 'TTwo1';
        user2.TimeZoneSidKey = 'America/Los_Angeles'; 
        user2.LocaleSidKey = 'en_US'; 
        user2.EmailEncodingKey = 'UTF-8'; 
        user2.ProfileId = p1.id; 
        user2.LanguageLocaleKey ='en_US'; 
        user2.Primary_Business_Group__c='Enterprise';
        user2.Core_ID__c='fffv1';
        user2.CommunityNickname='fffv1';
        user2.FederationIdentifier='fffv1';
        user2.EmployeeNumber='fffv1';
        user2.System_Integration__c = True;
        insert user2;      
        }
        user user1=[select id from user where username='Testuserone@motorolasolutions.com' limit 1];
        user user2=[select id from user where username='Testusertwo@motorolasolutions.com' limit 2];
        Id MotEntRecType = [select id from recordtype where developername = 'Motorola_Entity' and SobjectType = 'Account' limit 1].id;
        Account acct1 = new Account(Name='Test ME'); 
        acct1.Billingstreet = '1400 Fashion Island Blvd';
        acct1.Namelocal ='Test ME';
        acct1.Billingcity = 'San Mateo';
        acct1.Billingstate = 'Texas';
        acct1.BillingCountry = 'United States';
        acct1.BillingPostalCode = '94404'; 
        acct1.Phone ='12345';
        acct1.RecordTypeid= MotEntRecType ;
        insert acct1;
        
        Id ProcurementRecType = [select id from recordtype where developername = 'Procurement' and SobjectType = 'Account' limit 1].id;
        Account acct2 = new Account(Name='Test Contract'); 
        acct2.Billingstreet = '1400 Fashion Island Blvd';
        acct2.Namelocal ='Test CP1';
        acct2.Billingcity = 'San Mateo';
        acct2.Billingstate = 'Texas';
        acct2.BillingCountry = 'United States';
        acct2.BillingPostalCode = '94404'; 
        acct2.Phone ='12345';
        acct2.RecordTypeid= ProcurementRecType ;
        insert acct2;   
        
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();  
        template.name = 'Safe Harbor Ruling Model Clauses' ;
        template.Apttus__Type__c = 'Agreement';
        insert template; 
     
        procAgmt.Name='Testing Safe Harbor';
        procAgmt.RecordTypeID=rt1.id;
        procAgmt.Agreement_Title__c = 'Testing Safe harbor Model clauses';
        procAgmt.Apttus__Subtype__c = 'Master or Stand-Alone Agreement';
        procAgmt.Procurement_Category__c = 'Facilities';
        procAgmt.m_Business_Unit__c = 'Enterprise';
        procAgmt.m_GTM_Region__c = 'EMEA';
        procAgmt.Motorola_Contract_Signatory__c = 'Subu';
        procAgmt.Motorola_Entity_Account__c = acct1.id; 
        procAgmt.Contracting_Party_Account__c = acct2.id; 
     
        procAgmt.Procurement_Manager__c=User1.Id;
        procAgmt.m_Responsible_Attorney__c =User2.Id;  
        procAgmt.Apttus__Status_Category__c='Request';
        procAgmt.Apttus__Status__c='Request';
        procAgmt.Apttus__Contract_Start_Date__c = date.today();
        procAgmt.Apttus__Contract_End_Date__c = date.today();
        procAgmt.m_Record_Retention_Date__c =  Date.Today().addYears(20);
        procAgmt.Apttus__Total_Contract_Value__c = 100;
        procAgmt.Personal_Information__c = 'No';
        procAgmt.Payment_Terms__c = '46-60 Days';
        procAgmt.Is_the_DOA_POA_attached__c = 'No';
        procAgmt.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper';
        procAgmt.Are_all_related_contracts_filed__c = 'Yes';
        procAgmt.EU_PII_Transfer__c = 'Yes';
     
        insert procAgmt;
        
 
  }
 }