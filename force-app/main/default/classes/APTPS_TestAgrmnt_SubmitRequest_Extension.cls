/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class APTPS_TestAgrmnt_SubmitRequest_Extension {
	@testSetup
   	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
	}
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        // 1. Create Users
           Profile SysAdmin = [select Id 
                                from Profile
                                where Name = 'System Administrator' LIMIT 1];
           
           
           User UserSetting = [select TimeZoneSidKey, 
                               LocaleSidKey, 
                               EmailEncodingKey, 
                               ProfileId, 
                               LanguageLocaleKey
                           from User LIMIT 1];
           
           // Create New Users
           User user1 = new User (FirstName = 'Test', 
                                   LastName = 'User1', 
                                   Username = 'TestUser1Subu@apttus.com',
                                   Email =  'TestUser1Subu@apttus.com',
                                   Alias = 'TestUsr1',
                                   TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                   LocaleSidKey = UserSetting.LocaleSidKey, 
                                   EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                   ProfileId = SysAdmin.Id, 
                                   LanguageLocaleKey = UserSetting.LanguageLocaleKey,
                                   // Ruchika(23-June-2014): Added the below line as part of "Opportunities" project as below field is mandatory now for creating a user record.
                                   Primary_Business_Group__c='Enterprise');
           insert user1; // Create Test User 1
        
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
           // 2. Create Agreement
           Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
           agmt.recordtypeid= '01280000000UCxLAAW';
           
         
           Datetime dateTimetemp = System.now();
           
           //3a. Set the ReadyForSubmission to True
           agmt.Ready_For_Submission__c = true;
           agmt.Procurement_Category__c = 'Facilities';
           agmt.m_Business_Unit__c = 'Enterprise';
           agmt.m_GTM_Region__c = 'EMEA';
           agmt.Motorola_Contract_Signatory__c = 'Subu';
           agmt.Apttus__Subtype__c = 'Master or Stand-Alone Agreement';           
           //agmt.M7_Required_Contract_Completion_Date__c = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());
           agmt.Apttus__Total_Contract_Value__c = 100;
           agmt.Apttus__Contract_Start_Date__c=date.today();
           agmt.Contract_Labor__c = 'Yes';
           agmt.Contracting_Party_Account__c = acct2.id; 
           agmt.Motorola_Entity_Account__c = acct1.id;
           insert agmt;
          /* List<Account> apt_contracting_party = [
                                                        Select id
                                                        from Account 
                                                        where  Type = 'Contracting Party Procurement' limit 1];
           
           List<Account> apt_mot_entity = [
                                                            Select id
                                                            from Account
                                                            where Type = 'Motorola Entity' limit 1];
           
           agmt.Contracting_Party_Account__c = apt_contracting_party[0].id;
           
           agmt.Motorola_Entity_Account__c = apt_mot_entity[0].id;*/
           
           
          /*  Ruchika(23-06-2014) Commented the below code as part of Accounts and Contacts Project. 
           List<m_Agreement_Account__c> apt_contracting_party = [
                                                        Select id
                                                        from m_Agreement_Account__c 
                                                        where  m_Type__c = 'Contracting Party Procurement' limit 1];
           
           List<m_Agreement_Account__c> apt_mot_entity = [
                                                            Select id
                                                            from m_Agreement_Account__c 
                                                            where m_Type__c = 'Motorola Entity' limit 1];
           
           agmt.Contracting_Party_Account__c = apt_contracting_party[0].id;
           
           agmt.Motorola_Entity_Account__c = apt_mot_entity[0].id;
           
           
           update agmt;
           */
           
           
            // Ruchika(23-06-2014) Added below code in place of above to change the reference from Agreement Account to Account object.
           RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Procurement' limit 1]; 
           Account apt_contracting_party = new Account(Territory__c = 'T6',Region__c='NA',BillingState= 'Texas',BillingCountry = 'United States',RecordTypeId=rt.Id);
       
          /* List<Account> apt_contracting_party = [
                                                        Select id
                                                        from Account 
                                                        where  RecordType.DeveloperName = 'Procurement'  limit 1]; */
           RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='Motorola_Entity' limit 1]; 
           Account apt_mot_entity = new Account(Territory__c = 'T6',Region__c='NA',BillingState= 'Texas',BillingCountry = 'United States',RecordTypeId=rt1.Id);
       
           /*List<Account> apt_mot_entity = [
                                                            Select id
                                                            from Account 
                                                            where RecordType.DeveloperName = 'Motorola_Entity' limit 1];*/
           
           agmt.Contracting_Party_Account__c = apt_contracting_party.id;
           
           agmt.Motorola_Entity_Account__c = apt_mot_entity.id;
           
           
           /* Added this line to validate the change set */
           /* List<m_Agreement_Account__c> apt_contracting_party_PROC = [
                                                        Select id
                                                        from m_Agreement_Account__c 
                                                        where  m_Type__c = 'Contracting Party Procurement' limit 1];
           
           List<m_Agreement_Account__c> apt_mot_entity_ME = [
                                                            Select id
                                                            from m_Agreement_Account__c 
                                                            where m_Type__c = 'Motorola Entity' limit 1];
           agmt.m_contracting_party__c= apt_contracting_party_PROC[0].id;
           agmt.m_Motorola_Entity__c=apt_mot_entity_ME[0].id;
             */
           
           //update agmt;
           
           
           //final String AgrmtReasonForCancellation = 'Contract Awarded';
          // final String AgrmtSubmitRequest = 'YES';
           //final String AgrmtStatusCategory = 'Request';
          // final String AgrmtStatus = 'Submitted Request';
          // final String AgmtHiddenRecordTypeName = 'Procurement';
           
           //3b. Set the Record Type name to Procurement
           //agmt.Hidden_Record_Type_Name__c = 'Procurement';
           
        // Test Cases
       /**
        * Set the Status and Status Category and Submit Request. 
        */
           
           // Create the controller
           PageReference currPage = Page.APTPS_AgreementSubmitRequestAction;
           
           // Add parameters to page URL
           currPage.getParameters().put('Id', agmt.id);
           
           // Set Current Page        
           Test.setCurrentPage(currPage);
           
           
           System.runAs(user1){
               // Create the page controller
               APTPS_Agreement_SubmitRequest_Extension controller1 = new APTPS_Agreement_SubmitRequest_Extension(new ApexPages.StandardController(agmt));
                        
               try{
               controller1.autoRun();
               
               
               //agmt.Reason_for_Cancellation__c = 'Contract Awarded';
               //agmt.Submit_Request__c = 'YES';
               //agmt.Apttus__Status_Category__c = 'Request';
               //agmt.Apttus__Status__c = 'Submitted Request';
               
               //update agmt;
               
               //System.assertequals(AgmtHiddenRecordTypeName, agmt.Hidden_Record_Type_Name__c);
              // System.assertequals(AgrmtSubmitRequest, agmt.Submit_Request__c);
              // System.assertequals(AgrmtStatusCategory, agmt.Apttus__Status_Category__c);
               //System.assertequals(AgrmtStatus, agmt.Apttus__Status__c);
               
           }catch(exception e){
            System.debug('Agreement update failed due to '+ e);
           }
           
           }
           
           
    }
}