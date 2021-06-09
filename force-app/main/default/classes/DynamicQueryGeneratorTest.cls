@isTest
public class DynamicQueryGeneratorTest {
    @isTest static void testDymanicQueryGenerator(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        List<string> flds= new List<String>{'Id','Name','Motorola_Customer_Number__c','BillingStreet','ERP_Active__c'};
        List<String> ANDfilter = new List<String>{'ERP_Active__c=true'};
        List<String> Orfilter = new List<String>{'ERP_Active__c=true'};
        DynamicQueryGenerator.getQueryResult('Account',flds,ANDfilter,Orfilter,'AND','Name','Asc');
        DynamicQueryGenerator.updateRecords(lstMCNAccount);
        DynamicQueryGenerator.updateRecords(null);
        DynamicQueryGenerator.geFieldMemberByFieldSet('Account','AccountHighlightPanelForCAPP');
        DynamicQueryGenerator.getQueryResultByFieldSet('Account','AccountHighlightPanelForCAPP',ANDfilter,Orfilter,'AND','Name','Asc','5','5');
    }
}