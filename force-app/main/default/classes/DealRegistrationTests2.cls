@isTest
Private class DealRegistrationTests2 {

@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }

/******************************************************************************
*******************************************************************************

    This is 2 of three test classes that test the Deal Registration Apex Code.
    It tests the following:

    Classes:
        dealToOppExtension
        

    Triggers:
        dealToOppAutomater
        dealRegManager (Opportunity)
        
    Last Modified by: Kalaivani Rajendran
    Reason: For DR Next rel 3 project
    Version:5.0
    Date:7/11/2012     
         
    Last Modified by: Kalaivani Rajendran
    Reason: For EMEA DR project
    Version:4.0
    Date:4/9/2012     



static testMethod void DealtestOne(){
    
        Deal_Registration__c drThree = [select Id, Name from Deal_Registration__c where approval_status__c = 'Approved - Final' and CreatedBy.Profile.Name='EMS Partner Profile EMEA' limit 1];
     
        //Deal_Registration__c drThree =[select Id, Name from Deal_Registration__c where CreatedBy.Profile.Name='EMS Partner Profile EMEA' limit 1];
        
         System.currentPageReference().getParameters().put('Id',(String)drThree.Id);
         test.StartTest();
         dealToOppExtension dTOE = new dealToOppExtension(new ApexPages.StandardController(drThree));
         dTOE.initCheck();

        test.stopTest();

    }   
      
  *****************************************************************************/
}