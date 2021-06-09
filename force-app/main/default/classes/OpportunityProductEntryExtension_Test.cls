@isTest
private class OpportunityProductEntryExtension_Test {
        @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    /*
    * Method name   : test
    * Description   : To test constructor of class opportunityProductEntryExtension
    * Return Type   : N/A
    * Parameter : nil
    */
    private static testMethod void test() {
        TestDataSetUpUtils.activateAccTrigger();
        TestDataSetUpUtils.activateOppTrigger();
        TestDataSetUpUtils.activatPartnerCommunityOpportunityMasterTrigger();
        TestDataSetUpUtils.activateOpplineItemTrigger();
        List<Opportunity> lstOpps = TestDataSetUpUtils.createOpportunities(1,Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
        ApexPages.currentPage().getParameters().put('Id',lstOpps[0].Id);
        PriceBook2 instOfPriceB  = TestDataSetUpUtils.createPriceBook2();
        lstOpps[0].Pricebook2Id = instOfPriceB.Id;
        lstOpps[0].Pricebook2 = instOfPriceB;
        update lstOpps[0];
        PricebookEntry instOfPBE = TestDataSetUpUtils.createPriceBookEntryCustom(instOfPriceB.Id);
        TestDataSetUpUtils.createOpportunityLineItems(4,lstOpps[0].Id,instOfPBE);
        ApexPages.StandardController stdtController = new ApexPages.StandardController(lstOpps[0]);
       
    }
    /*
    * Method name   : testSec
    * Description   : To test constructor of class opportunityProductEntryExtension
    * Return Type   : N/A
    * Parameter : nil
    */
    private static testMethod void testSec() {
        TestDataSetUpUtils.activateAccTrigger();
        TestDataSetUpUtils.activateOppTrigger();
        TestDataSetUpUtils.activatPartnerCommunityOpportunityMasterTrigger();
        TestDataSetUpUtils.activateOpplineItemTrigger();
        List<Opportunity> lstOpps = TestDataSetUpUtils.createOpportunities(1,Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
        ApexPages.currentPage().getParameters().put('Id',lstOpps[0].Id);
        PriceBook2 instOfPriceB  = TestDataSetUpUtils.createPriceBook2();
        ApexPages.StandardController stdtController = new ApexPages.StandardController(lstOpps[0]);
       
    }
}