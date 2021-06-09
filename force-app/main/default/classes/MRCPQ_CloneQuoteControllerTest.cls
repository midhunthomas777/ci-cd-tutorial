@isTest
public class MRCPQ_CloneQuoteControllerTest { 
    
    @isTest static void testCloneQuote(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        system.runas(partnerUsr){
            Test.startTest();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            BigMachines__Quote__c objAccQuote = new BigMachines__Quote__c();
            objAccQuote.BigMachines__Account__c=lstAccount.get(0).Id;
            objAccQuote.Name='testQuote';
            objAccQuote.BigMachines__Site__c=siteID;
            insert objAccQuote;
            BigMachines__Quote__c objOppQuote = new BigMachines__Quote__c();
            objOppQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
            objOppQuote.Name='testQuote';
            objOppQuote.BigMachines__Site__c=siteID;
            insert objOppQuote;
            Test.stopTest();
            String cloneUrlWithAccount=MRCPQ_CloneQuoteController.getPageUrl(String.valueOf(objAccQuote.Id));
            //system.assertEquals('https://sfcpqdev-mpecommunity.cs26.force.com/NA/s/apex/BigMachines__QuoteEdit?actId='+lstAccount.get(0).Id, cloneUrlWithAccount);
            String cloneUrlWithOpportunity=MRCPQ_CloneQuoteController.getPageUrl(String.valueOf(objOppQuote.Id));
            //system.assertEquals('https://sfcpqdev-mpecommunity.cs26.force.com/NA/s/apex/BigMachines__QuoteEdit?oppId='+lstOpportunity.get(0).Id, cloneUrlWithOpportunity);

        }
    }
}