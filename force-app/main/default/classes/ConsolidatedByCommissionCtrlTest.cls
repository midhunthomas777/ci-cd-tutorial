@isTest
public class ConsolidatedByCommissionCtrlTest {
    @isTest
    public static void mrCommissionMCNDetailsTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            Test.startTest();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);  
            ApexPages.currentPage().getParameters().put('mcnNum',mncNumber);
            ApexPages.currentPage().getParameters().put('accName',lstAccount.get(0).Name);
            ApexPages.currentPage().getParameters().put('TOA','255');
            ApexPages.currentPage().getParameters().put('OTCD','100');
            ApexPages.currentPage().getParameters().put('rs','[{"sobjectType":"ConsolidatedBy_Partner_Information__mdt","MR_Name__c":"test","MRID__c":"33","End_user_Customer_number__c":"44","End_user_Customer_name__c":"test","Dollar_amount_to_be_associated_to_MR__c":200,"Commission_amount_to_be_associated_to_MR__c":200}]');
            ApexPages.currentPage().getParameters().put('TComPer','5');
            ApexPages.currentPage().getParameters().put('TComDolr','2');
            ApexPages.currentPage().getParameters().put('cmts','test');
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment'); 
            ApexPages.currentPage().getHeaders().put('filename', 'pdf');
            ConsolidatedByCommissionCtrl cbctrl = new ConsolidatedByCommissionCtrl();
            Test.stopTest();
        }
    }
}