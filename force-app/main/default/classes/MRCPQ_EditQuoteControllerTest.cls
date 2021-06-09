@isTest
public class MRCPQ_EditQuoteControllerTest {
    
    @isTest static void testEditQuote(){
        
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
            
            String Idsite = MRCPQ_EditQuoteController.fetchCPQSiteId();
            system.assertEquals(siteID, Idsite);
            String editUrlWithAccount=MRCPQ_EditQuoteController.getPageUrl(String.valueOf(objAccQuote.Id));
            //system.assertEquals('https://sfcpqdev-mpecommunity.cs26.force.com/NA/s/apex/BigMachines__QuoteEdit?actId='+lstAccount.get(0).Id, editUrlWithAccount);
            String editUrlWithOpportunity=MRCPQ_EditQuoteController.getPageUrl(String.valueOf(objOppQuote.Id));
            //system.assertEquals('https://sfcpqdev-mpecommunity.cs26.force.com/NA/s/apex/BigMachines__QuoteEdit?oppId='+lstOpportunity.get(0).Id, editUrlWithOpportunity);
            try{
            MRCPQ_AddProductsToOpportunity.addProductsToOppo(objAccQuote.id,lstOpportunity[0].id);
            MRCPQ_AddProductsToOpportunity.removeProductsToOppo(objAccQuote.id,objOppQuote.BigMachines__Opportunity__c);
           } catch(Exception exp){}
        }
    }
}