/*  
* File Name     : ADPUpdAccOnLicCreationTest
* Description   : Test class for ADPUpdAccOnLicCreation
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     21-Feb-17   Poongodi V               Initial creation
*   2.0     1-Mar-17   Poongodi V                Added Methods to cover the Matching Account scenarios
*/
@isTest

public class ADPUpdAccOnLicCreationTest{
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }


//Test to cover the Matching scenario: Company Name having more than one word and the starting word starts with 'The' 
private static testMethod void doTest1() {

Test.startTest();
        
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Approved - ADP Lead';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        //NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
   
         RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Name=NewADPReg.Company_Name__c;
        NewAcc.ADP_Partner__c=TRUE;
        Insert NewAcc;
        
         Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        NewADPReg.Partner_Account__c =NewAcc.Id;
        NewADPReg.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert NewADPReg;

        ADPUpdAccOnLicCreation.updAccount(NewADPReg.Id);

    Test.stopTest();
        
}


//
private static testMethod void doTest2() {

Test.startTest();
        
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Approved - ADP Lead';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United Kingdom';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='Europe, Middle East and Africa (EMEA)';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
   
         RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Name=NewADPReg.Company_Name__c;
        NewAcc.ADP_Technology_Segment__c='Convergence Suite';
        NewAcc.ADP_Partner__c=TRUE;
        Insert NewAcc;
        
        Partner_Type__c ProgInfo=new Partner_Type__c();
            ProgInfo.Account__c=NewAcc.Id;
            ProgInfo.Status__c='Active';
            ProgInfo.Program__c='RADIO';
            Insert ProgInfo;
            
         Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        NewADPReg.Partner_Account__c =NewAcc.Id;
        NewADPReg.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert NewADPReg;

        ADPUpdAccOnLicCreation.updAccount(NewADPReg.Id);

    Test.stopTest();
        
}

}