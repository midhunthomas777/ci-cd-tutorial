@isTest
public class CommissionSummaryTriggerTest {
    @isTest
    public static void commissionTriggerTest(){
        TestDataSetUpUtils.insertCustomSettings();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        String partnerAccountId = [select id,accountId from User where id=:partnerUsr.Id].accountId;
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c = '965432';
        pI.ID_Type__c = 'Federal Manufacturer Representative ID';
        pI.Account__c = partnerAccountId;
        insert pI;
        
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        List<Account> lstProspectAccount=TestDataSetUpUtils.createProspectAccounts(1, prospectAccrectypeID);
        List<Account> lstMCNAccount = TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstProspectAccount);
        insert new Commission_Summary__c(
        	AgentMR_ID__c = '965432',
            Customer_Number__c = lstMCNAccount.get(0).Motorola_Customer_Number__c,
            Unique_External_Id__c = 123123.00
        );
    }
}