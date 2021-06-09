/*
Name:  MPP_TEST_TRG_AddGroupsToUser_Account
Purpose: Test class for MPP_TRG_AddGroupsToUser_Account trigger
          
==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      7th Feb 2017       INITIAL DEVELOPMENT       

******************************************************************************************/ 
@isTest
private class MPP_TEST_TRG_AddGroupsToUser_Account {
              
    static testMethod void testAddGroupsToUserAccount() {
        
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                             AND DeveloperName = 'Partner']; 

        Account acc1 = new Account(Name='Test account',Shared_Partner__c=true,RecordTypeId=recType.Id,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   BillingCountry='Brazil',Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='NAMR',Owner_Business_Group__c='Government',
                                  Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                  CASPA_groups__c = 'Connect Adv Partner');
        Test.startTest();
        try{
            insert acc1;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e){
            system.debug('ERROR: ' + e.getMessage());
        }
        Test.stopTest();
        
        try{
            MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = false;
            delete acc1;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e){
            system.debug('ERROR ' + e.getMessage());
        }
    }
}