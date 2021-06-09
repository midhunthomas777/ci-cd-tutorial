@isTest
public class CPQUtilityWithoutSharingTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    @istest static void CPQUtilityWithoutSharing() {
        //TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        ID partnerAccountId= [Select accountId from Contact WHERE Id=:partnerUsr.ContactId].accountId;
        system.debug('Only partnerAccountId'+partnerAccountId); 
        Account acc = new Account(id=partnerAccountId,BigMachines__Partner_Organization__c ='test34',Applications_Enabled__c ='CPQ');
        update acc;
        Applications_Access__c appAcc = new Applications_Access__c();
        appAcc.App_Name__c='CPQ';
        appAcc.Contact__c=partnerUsr.ContactId;
        appAcc.App_Access_Status__c='T&C';
        appAcc.Is_Bypass__c=true;        
        //appAcc.App_Access_Status__c='T&C';
        insert appAcc;
        //partnerUsr.FederationIdentifier=null;
        //update partnerUsr;
        //appAcc.App_Access_Status__c='T&C';        
        //update appAcc;
        List<BigMachines__Quote__c> lstQuoteOrdersResult;
        system.runas(partnerUsr){            
            CPQUtilityWithoutSharing.updateTC();
            List<Applications_Access__c> lstApplicationAccess=[SELECT Id,App_Access_Status__c FROM Applications_Access__c
                                                               WHERE Id=:appAcc.Id];
            Test.startTest();            
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
            objQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
            objQuote.BigMachines__Account__c=lstAccount.get(0).Id;
            objQuote.Name='testQuote';
            //objQuote.BigMachines__Site__c=siteID;
            insert objQuote;
            //List<OpportunityLineItem> oplineitem =TestDataSetUpUtils.createOLIs(lstOpportunity);
            Test.stopTest();
            CPQUtilityWithoutSharing.removeIsPrimaryFromReadOnlyQuote(String.valueof(lstOpportunity.get(0).Id));
            // String addProductToOpp =  CPQUtilityWithoutSharing.addProductsToOpportunity(String.valueof(objQuote.Id),String.valueof(lstOpportunity.get(0).Id));
            // String removeProductToOpp = CPQUtilityWithoutSharing.removeProductsToOpportunity(String.valueof(objQuote.Id),String.valueof(lstOpportunity.get(0).Id));
            CPQUtilityWithoutSharing.deactivateApplicationAccess(lstApplicationAccess.get(0).Id);         
            CPQUtilityWithoutSharing.deactivateApplicationAccess(lstOpportunity.get(0).Id);
            CPQUtilityWithoutSharing.reactivateApplicationAccess(lstApplicationAccess.get(0).Id);
            CPQUtilityWithoutSharing.reactivateApplicationAccess(lstOpportunity.get(0).Id);
            // system.assertEquals('Active',lstApplicationAccess.get(0).App_Access_Status__c);
        } 
    }
    
    
}