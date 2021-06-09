/*  
* File Name     : ADP_AEMServiceTest
* Description   : Test class for ADP_AEMService
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     20-Jan-17    Poongodi V                  Initial Creation
*   2.0 	10-May-18	 Satish Maddhi		   Removed SeeAllData=true and increased code coverage
*/
@isTest
public class ADP_AEMServiceTest {
	@testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c trgrdisbld = new TriggerSettings__c(Name = 'UserTriggerDisabled',IsActive__c=FALSE);
        insert trgrdisbld;
    }
    static testMethod void testMethodForAll() {
        Test.startTest();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
        
        RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name='test';
        NewAcc.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;
        NewAcc.ADP_Technology_Segment__c='ASTRO';
        NewAcc.BillingStreet='Test Street1';
        NewAcc.BillingCity='Test City';
        NewAcc.BillingState='Illinois';
        NewAcc.BillingCountry ='United States';
        NewAcc.BillingPostalCode=String.Valueof(1234);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        Insert NewAcc;
        
        Account NewAcc2=new Account();
        NewAcc2.recordtypeId=theRecordType.Id;
        NewAcc2.Name='test';
        NewAcc2.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;
        NewAcc2.ADP_Technology_Segment__c='DIMETRA';
        NewAcc2.BillingStreet='Test Street1';
        NewAcc2.BillingCity='Test City';
        NewAcc2.BillingState='Illinois';
        NewAcc2.BillingCountry ='United States';
        NewAcc2.BillingPostalCode=String.Valueof(1234);
        NewAcc2.ADP_Partner__c=true;
        NewAcc2.Hierarchy_Placement__c='Regional Account';
        NewAcc2.MPE_Program_Status_New__c='Active';
        NewAcc2.Partner_Region__c='NAMR';
        Insert NewAcc2;

        Account NewAcc3=new Account();
        NewAcc3.recordtypeId=theRecordType.Id;
        NewAcc3.Name='test';
        NewAcc3.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;
        NewAcc3.ADP_Technology_Segment__c='MOTOTRBO';
        NewAcc3.BillingStreet='Test Street1';
        NewAcc3.BillingCity='Test City';
        NewAcc3.BillingState='Illinois';
        NewAcc3.BillingCountry ='United States';
        NewAcc3.BillingPostalCode=String.Valueof(1234);
        NewAcc3.ADP_Partner__c=true;
        NewAcc3.Hierarchy_Placement__c='Regional Account';
        NewAcc3.MPE_Program_Status_New__c='Active';
        NewAcc3.Partner_Region__c='NAMR';
        Insert NewAcc3;
        
        Account NewAcc4=new Account();
        NewAcc4.recordtypeId=theRecordType.Id;
        NewAcc4.Name='test';
        NewAcc4.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;
        NewAcc4.ADP_Technology_Segment__c='Convergence Suite';
        NewAcc4.BillingStreet='Test Street1';
        NewAcc4.BillingCity='Test City';
        NewAcc4.BillingState='Illinois';
        NewAcc4.BillingCountry ='United States';
        NewAcc4.BillingPostalCode=String.Valueof(1234);
        NewAcc4.ADP_Partner__c=true;
        NewAcc4.Hierarchy_Placement__c='Regional Account';
        NewAcc4.MPE_Program_Status_New__c='Active';
        NewAcc4.Partner_Region__c='NAMR';
        Insert NewAcc4;
        
		User user1 = new User();
        user1.FirstName = 'Testuser'; 
        user1.LastName = 'One'; 
        user1.Username = 'Testuserone@motorolasolutions.com';
        user1.Email =  'Testuserone@motorolasolutions.com';
        user1.Alias = 'TOne1';
        user1.TimeZoneSidKey = 'America/Los_Angeles'; 
        user1.LocaleSidKey = 'en_US'; 
        user1.EmailEncodingKey = 'UTF-8'; 
        user1.ProfileId = [SELECT Id FROM Profile WHERE id = '00e80000001KUEW'].Id; 
        user1.LanguageLocaleKey ='en_US'; 
        user1.Primary_Business_Group__c='Government'; 
        user1.Core_ID__c = 'ABCD';
        user1.Core_ID__c = 'ABCD';
        user1.CommunityNickname = 'ABCD';
        user1.FederationIdentifier = 'ABCD	';
        user1.EmployeeNumber = 'ABCD';

        insert user1; 
                
        ID ADPLicRTypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.RecordTypeInfosByName.get('ADP License').RecordTypeId;
        String technology = 'ASTRO';
            
        //ASTRO
        Apttus__APTS_Agreement__c newLicAgr = new Apttus__APTS_Agreement__c();
        newLicAgr.ADP_Technology__c = NewAcc.ADP_Technology_Segment__c;
        newLicAgr.Agreement_Title__c = 'Testing License';
        newLicAgr.Apttus__Account__c= NewAcc.Id;
        newLicAgr.RecordTypeID = ADPLicRTypeID;
        newLicAgr.Apttus__Contract_End_Date__c=Date.valueof('2019-02-20');
        newLicAgr.m_Business_Unit__c='Government';
        newLicAgr.Signed_Executed_Agreement__c=true;
        newLicAgr.m_Ready_for_Activation__c=true;
        newLicAgr.m_Technology__c='ASTRO';
        newLicAgr.Apttus__Contract_Start_Date__c=Date.valueof('2018-02-20');
        newLicAgr.Additional_Approvers_c__c=user1.Id;
        newLicAgr.Apttus__Status__c='Activated';
        newLicAgr.Apttus__Status_Category__c='In Effect';
        newLicAgr.m_Record_Retention_Date__c=Date.valueof('2018-02-20');
        newLicAgr.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        newLicAgr.Business_Contact__c =user1.Id;
        newLicAgr.Finance_Approver_c__c=user1.Id;
        newLicAgr.MSI_Contract_Signatory__c=user1.Id;
        newLicAgr.Royalty_Bearing__c = 'No';
        insert newLicAgr;
        
        //DIMETRA
        Apttus__APTS_Agreement__c newLicAgr2 = new Apttus__APTS_Agreement__c();
        newLicAgr2.ADP_Technology__c = NewAcc2.ADP_Technology_Segment__c;
        newLicAgr2.Agreement_Title__c = 'Testing License';
        newLicAgr2.Apttus__Account__c= NewAcc2.Id;
        newLicAgr2.RecordTypeID = ADPLicRTypeID;
        newLicAgr2.Apttus__Contract_End_Date__c=Date.valueof('2019-02-20');
        newLicAgr2.m_Business_Unit__c='Government';
        newLicAgr2.Signed_Executed_Agreement__c=true;
        newLicAgr2.m_Ready_for_Activation__c=true;
        newLicAgr2.m_Technology__c='DIMETRA';
        newLicAgr2.Apttus__Contract_Start_Date__c=Date.valueof('2018-02-20');
        newLicAgr2.Additional_Approvers_c__c=user1.Id;
        newLicAgr2.Apttus__Status__c='Activated';
        newLicAgr2.Apttus__Status_Category__c='In Effect';
        newLicAgr2.m_Record_Retention_Date__c=Date.valueof('2018-02-20');
        newLicAgr2.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        newLicAgr2.Business_Contact__c =user1.Id;
        newLicAgr2.Finance_Approver_c__c=user1.Id;
        newLicAgr2.MSI_Contract_Signatory__c=user1.Id;
        newLicAgr2.Royalty_Bearing__c = 'No';
        insert newLicAgr2;
        
        //MOTOTRBO
        Apttus__APTS_Agreement__c newLicAgr3 = new Apttus__APTS_Agreement__c();
        newLicAgr3.ADP_Technology__c = NewAcc3.ADP_Technology_Segment__c;
        newLicAgr3.Agreement_Title__c = 'Testing License';
        newLicAgr3.Apttus__Account__c= NewAcc3.Id;
        newLicAgr3.RecordTypeID = ADPLicRTypeID;
        newLicAgr3.Apttus__Contract_End_Date__c=Date.valueof('2019-02-20');
        newLicAgr3.m_Business_Unit__c='Government';
        newLicAgr3.Signed_Executed_Agreement__c=true;
        newLicAgr3.m_Ready_for_Activation__c=true;
        newLicAgr3.m_Technology__c='MOTOTRBO';
        newLicAgr3.Apttus__Contract_Start_Date__c=Date.valueof('2018-02-20');
        newLicAgr3.Additional_Approvers_c__c=user1.Id;
        newLicAgr3.Apttus__Status__c='Activated';
        newLicAgr3.Apttus__Status_Category__c='In Effect';
        newLicAgr3.m_Record_Retention_Date__c=Date.valueof('2018-02-20');
        newLicAgr3.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        newLicAgr3.Business_Contact__c =user1.Id;
        newLicAgr3.Finance_Approver_c__c=user1.Id;
        newLicAgr3.MSI_Contract_Signatory__c=user1.Id;
        newLicAgr3.Royalty_Bearing__c = 'No';
        insert newLicAgr3;
        
        //Convergence Suite
        Apttus__APTS_Agreement__c newLicAgr4 = new Apttus__APTS_Agreement__c();
        newLicAgr4.ADP_Technology__c = NewAcc4.ADP_Technology_Segment__c;
        newLicAgr4.Agreement_Title__c = 'Testing License';
        newLicAgr4.Apttus__Account__c= NewAcc4.Id;
        newLicAgr4.RecordTypeID = ADPLicRTypeID;
        newLicAgr4.Apttus__Contract_End_Date__c=Date.valueof('2019-02-20');
        newLicAgr4.m_Business_Unit__c='Government';
        newLicAgr4.Signed_Executed_Agreement__c=true;
        newLicAgr4.m_Ready_for_Activation__c=true;
        newLicAgr4.m_Technology__c='Convergence Suite';
        newLicAgr4.Apttus__Contract_Start_Date__c=Date.valueof('2018-02-20');
        newLicAgr4.Additional_Approvers_c__c=user1.Id;
        newLicAgr4.Apttus__Status__c='Activated';
        newLicAgr4.Apttus__Status_Category__c='In Effect';
        newLicAgr4.m_Record_Retention_Date__c=Date.valueof('2018-02-20');
        newLicAgr4.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        newLicAgr4.Business_Contact__c =user1.Id;
        newLicAgr4.Finance_Approver_c__c=user1.Id;
        newLicAgr4.MSI_Contract_Signatory__c=user1.Id;
        newLicAgr4.Royalty_Bearing__c = 'No';
        insert newLicAgr4;
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.params.put('groupid', String.Valueof(NewADPGlobalAccName.GitLab_Group_Id__c));
        req.params.put('GetGoogeldriveId', 'false');        
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/showlicenses/' ; 
        RestContext.request = req;
        RestContext.response = res;
        ADP_AEMService.MainClass results = ADP_AEMService.getAgreements();
        Test.stopTest();  
	}
}