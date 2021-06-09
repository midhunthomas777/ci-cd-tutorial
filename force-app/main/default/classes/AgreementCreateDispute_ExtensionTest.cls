@isTest
private class AgreementCreateDispute_ExtensionTest{
     @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

 static testMethod void validateDisputeAgreement_Creation(){
     
      //Get the Procurement recordtype instead of hardcoding the recordtype ID
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='Procurement' Limit 1]; 
     
     //Use this profile which does not have access to the Agreement object
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
        // Ruchika(23-06-2014) Added below line as part of Opportunities project.
        user1.Primary_Business_Group__c='Enterprise'; 
        user1.Core_ID__c='fffv';
        user1.CommunityNickname='fffv';
        user1.FederationIdentifier='fffv';
        user1.EmployeeNumber='fffv';
        user1.System_Integration__c = True;
        insert user1;  
        // System.debug('User1 adding' + user1.Id);
        }
        user user1=[select id from user where username='Testuserone@motorolasolutions.com' limit 1];
        //User 2
      /*  User user2 = new User ();
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
        // Ruchika(23-06-2014) Added below line as part of Opportunities project.
        user2.Primary_Business_Group__c='Enterprise';
        user2.core_id__c='testff';
        insert user2; */  
        
        /* Ruchika(23-06-2014) Commented the below code as part of Accounts and Contacts Project.
        m_Agreement_Account__c acct1 = new m_Agreement_Account__c(Name='Test ME');     
        acct1.m_Billing_Address_Street1__c= '1400 Fashion Island Blvd';
        acct1.m_Friendly_Contracting_Party_Name__c='Test CP';        
        acct1.m_Billing_Address_City__c= 'San Mateo';
        acct1.m_Billing_Address_State__c= 'CA';
        acct1.m_Billing_Address_Country__c = 'US';
        acct1.m_Billing_Address_Zip__c= '94404'; 
        acct1.m_Phone_Number__c='12345';      
        acct1.m_Type__c='Motorola Entity';
        insert acct1;  */

        /*
        m_Agreement_Account__c acct1ME = new m_Agreement_Account__c(Name='Test ME');     
        acct1ME.m_Billing_Address_Street1__c= '1400 Fashion Island Blvd';
        acct1ME.m_Friendly_Contracting_Party_Name__c='Test CP';        
        acct1ME.m_Billing_Address_City__c= 'San Mateo';
        acct1ME.m_Billing_Address_State__c= 'CA';
        acct1ME.m_Billing_Address_Country__c = 'US';
        acct1ME.m_Billing_Address_Zip__c= '94404'; 
        acct1ME.m_Phone_Number__c='12345';      
        acct1ME.m_Type__c='Motorola Entity';
        insert acct1ME;         
        */
  
        // Ruchika(23-06-2014)(Line 59-69) Added below code in place of above to change the reference from Agreement Account to Account object.
        
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
     
        /* Ruchika(23-06-2014) Commented the below code as part of Accounts and Contacts Project.
        m_Agreement_Account__c acct2 = new m_Agreement_Account__c(Name='Test Contract');     
        acct2.m_Billing_Address_Street1__c= '1400 Fashion Island Blvd';
        acct2.m_Friendly_Contracting_Party_Name__c='Test CP1';        
        acct2.m_Billing_Address_City__c= 'San Mateo';
        acct2.m_Billing_Address_State__c= 'CA';
        acct2.m_Billing_Address_Country__c = 'US';
        acct2.m_Billing_Address_Zip__c= '94404'; 
        acct2.m_Phone_Number__c='12345';      
        acct2.m_Type__c='Contracting Party Procurement';
        insert acct2;
        
         m_Agreement_Account__c acct2CP = new m_Agreement_Account__c(Name='Test Contract');     
        acct2CP.m_Billing_Address_Street1__c= '1400 Fashion Island Blvd';
        acct2CP.m_Friendly_Contracting_Party_Name__c='Test CP1';        
        acct2CP.m_Billing_Address_City__c= 'San Mateo';
        acct2CP.m_Billing_Address_State__c= 'CA';
        acct2CP.m_Billing_Address_Country__c = 'US';
        acct2CP.m_Billing_Address_Zip__c= '94404'; 
        acct2CP.m_Phone_Number__c='12345';      
        acct2CP.m_Type__c='Contracting Party Procurement';
        insert acct2CP;  
        */

        // Ruchika(23-06-2014)(Line 85-95) Added below code in place of above to change the reference from Agreement Account to Account object.
        
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
     
        procAgmt.Name='Testing Dispute';
        procAgmt.Agreement_Title__c = 'Testing Dispute';
        procAgmt.Apttus__Subtype__c = 'Master or Stand-Alone Agreement';
     
        procAgmt.m_Ready_for_Activation__c = true;
        procAgmt.Signed_Executed_Agreement__c = true;
        procAgmt.Procurement_Category__c = 'Facilities';
        procAgmt.m_Business_Unit__c = 'Enterprise';
        procAgmt.m_GTM_Region__c = 'EMEA';
        procAgmt.Motorola_Contract_Signatory__c = 'Subu';
        procAgmt.Motorola_Entity_Account__c = acct1.id; 
        //procAgmt.m_Motorola_Entity__c= acct1ME.id; 
        procAgmt.Contracting_Party_Account__c = acct2.id; 
        //procAgmt.m_Contracting_Party__c = acct2CP.id; 
        ProcAgmt.New_Country_of_Deployment__c = 'Algeria';
     
        procAgmt.Procurement_Manager__c=User1.Id;
        procAgmt.m_Responsible_Attorney__c =sysuser.Id;  
        procAgmt.Apttus__Status_Category__c='In Effect';
        procAgmt.Apttus__Status__c='Activated';
        procAgmt.Apttus__Contract_Start_Date__c = date.today();
        procAgmt.Apttus__Contract_End_Date__c = date.today();
        procAgmt.m_Record_Retention_Date__c =  Date.Today().addYears(20);
        procAgmt.Apttus__Total_Contract_Value__c = 100;
        procAgmt.Personal_Information__c = 'No';
        procAgmt.Payment_Terms__c = '46-60 Days';
        procAgmt.Is_the_DOA_POA_attached__c = 'No';
        procAgmt.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper';
        procAgmt.Are_all_related_contracts_filed__c = 'Yes';
        procAgmt.Outside_Counsel_Name_Account__c = 'Test';
        procAgmt.m_Technology__c = 'ADC (Data Capture)';
        insert procAgmt;
     
         System.runAs(sysuser) {     
           //Use the PageReference Apex class to instantiate a page
            PageReference pageRef = Page.AgreementCreateDispute;
           //In this case, the Visualforce page named 'AgreementCreateDispute' is the starting point of this test method. 
            Test.setCurrentPage(pageRef);
           //Instantiate and construct the controller class.   
            ApexPages.StandardController controller = new ApexPages.StandardController(procAgmt);
           //Instantiate and construct the extension class.  
            AgreementCreateDispute_Extension ext = new AgreementCreateDispute_Extension(controller);
           
            System.assert(controller!=null);
              
             system.assert(ext.createDisputeAgreement()!=null);
             
             
        }
     
     
     
     
     

  
     
        
 }
    
}