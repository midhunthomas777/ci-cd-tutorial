@isTest
public class CloneCaseControllerTest {
    @isTest(SeeAllData=true)
    static void clonetest(){
        
      //  TestDataSetUpUtils.insertCustomSettings();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        // system.runas(partnerUsr){
        Test.startTest();
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Account__c=lstProspectAccount.get(0).Id;
        objQuote.AccountOnlyQuotes__c=lstProspectAccount.get(0).Id;
        objQuote.Name='testQuote';
        objQuote.BigMachines__Site__c=siteID;
        objQuote.BigMachines__Opportunity__c=null;
        objQuote.BigMachines__Transaction_Id__c='12345';
        objQuote.MR_ID__c='1234';
        objQuote.IsFinalizedQuoteSubmitted__c=true;
        objQuote.QuotePDFFile__c='true';
        objQuote.SendFilestoFinancialFolder__c=true;
        insert objQuote;
        
        
        Case cs= new Case();
        cs.Subject='test';
        cs.Status='New';
        cs.AccountId=lstProspectAccount.get(0).Id;
        insert cs;
        
        Case cs1 = new Case();
        cs1.ParentId=cs.Id;
        cs1.Subject='test1'; 
        cs1.Status='New';
        cs1.AccountId=lstProspectAccount.get(0).Id;
        insert cs1;
        
        
        CloneCaseController.isValidated(cs1.Id);
        cs1.AccountId=null;
        update cs1;
                CloneCaseController.isValidated(cs1.Id);
        cs1.AccountId=null;
        update cs1;


        
        
        CloneCaseController.isValidated(cs.Id);
        cs.Status='Closed';
        update cs;
        CloneCaseController.isValidated(cs.Id);
        
        CloneCaseController.cloneCase(cs.Id);
        CloneCaseController.cloneCase(null);
        // }
    }
}