@isTest
Private class DealRegistrationCreateAPACopp {

@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    /******
static testMethod void DealtestThree(){
    
        Deal_Registration__c drFour = [select Id, Name from Deal_Registration__c where approval_status__c = 'Approved - Final' and CreatedBy.Profile.Name='EMS Partner Profile APAC' and Opportunity__c = null limit 1];
        
         System.currentPageReference().getParameters().put('Id',(String)drFour.Id);
         test.StartTest();
         dealToOppExtension dTOE = new dealToOppExtension(new ApexPages.StandardController(drFour));
         dTOE.initCheck();

        test.stopTest();

    }   
    ********/
}