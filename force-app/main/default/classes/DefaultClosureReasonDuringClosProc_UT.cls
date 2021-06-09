/************************************************************************************************* 
* File Name  : DefaultClosureReasonDuringClosProc_UT
* Description: Test class for OpportunityTrigger and OpportunityTriggerHandler
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 22-Nov-2017     Satish Maddhi(TCS)	  Fixed test class failures and increased code coverage
*
*************************************************************************************************/

@isTest
private class DefaultClosureReasonDuringClosProc_UT {

    @testSetup
    static void testSetup() {
        TestDatasetupUtils.insertCustomSettings();
    }
   
    static testmethod void StageAndPlaceinSalesFunnelTest(){
        Id rec = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Registration').RecordTypeId;
        Opportunity opp1= new Opportunity(name = 'XYZ', RecordTypeId = rec, stageName ='Prospect',Status__c='Active',mh_Place_in_Sales_Funnel__c= 'Execute',closedate = system.today());
        Opportunity opp2= new Opportunity(name = 'XYZ', RecordTypeId = rec, stageName ='Prospect',Status__c='Active',mh_Place_in_Sales_Funnel__c= 'Execute',closedate = system.today());
        Test.startTest();
        insert opp1;
        opp1.Status__c='Active';
        opp1.stageName= 'Execute & Expand / Won';
        opp1.Reason_for_Win_or_Loss__c='MSI as the provider';
        opp1.Aging_Type__c = 'Fixed';
        update opp1;
        insert opp2;
        
        //update opp1;
        Test.stopTest();
    }
}