@isTest
public class MRCommissionOrderCalculatorCtrlTest {
 @isTest
    public static void mrCommissionOrderCalculatorTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId); 
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            MRCommissionOrderCalculatorCtrl.getFieldSets();
            MRCommissionOrderCalculatorCtrl.fetchSitePrefix();
            MRCommissionOrderCalculatorCtrl.isCCMR(partneruser.accountID);
        }
    }            
}