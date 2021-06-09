/************************************************************************************************* 
* File Name  : CalculateStageDurationAndScoreCard_UT
* Description: Test class for OpportunityTrigger and OpportunityTriggerHandler
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 23-Nov-2017     Satish Maddhi(TCS)	  Fixed test class failures and increased code coverage
*
*************************************************************************************************/

@isTest
private class CalculateStageDurationAndScoreCard_UT {
    @testSetup
    static void testSetup() {
        TestDataSetupUtils.insertCustomSettings();
    }
    
    static testMethod void Test_CalculateStageDuration1() {
        Id prosRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id prjtRecId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(1, prosRecId);
        List<Opportunity> oppList = TestDataSetUpUtils.createOpportunities(1, prjtRecId, accList);
        oppList[0].StageName='Position';
        Recursionblocker.flag=true;
        update oppList[0];
    }
    static testMethod void Test_CalculateStageDuration2() {
        Id prosRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id prjtRecId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(1, prosRecId);
        List<Opportunity> oppList = TestDataSetUpUtils.createOpportunities(1, prjtRecId, accList);
        SalesFunnelStageDuration__c salesFunnelNew = new SalesFunnelStageDuration__c();
        salesFunnelNew.Opportunity__c = oppList[0].Id;
        salesFunnelNew.Last_Assigned_Date__c = Date.Today();
        salesFunnelNew.Business_Score__c = 20;
        salesFunnelNew.Opportunity_Score__c = 30;
        salesFunnelNew.Total_Score__c = 50;
        salesFunnelNew.Place_in_Sales_FunnelPipeline__c = 'Prospect';               
        Date stageUpdatedDate = Date.newinstance(2013, 07, 09);
        salesFunnelNew.Stage_Duration__c = (stageUpdatedDate).daysbetween(Date.Today());
        insert salesFunnelNew;
        oppList[0].StageName = 'Pipeline';
        Recursionblocker.flag = true;
        update oppList[0];
    }
}