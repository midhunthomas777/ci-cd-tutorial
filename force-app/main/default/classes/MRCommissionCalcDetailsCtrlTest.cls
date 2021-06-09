@isTest
public class MRCommissionCalcDetailsCtrlTest {
    @isTest
    public static void mrCommissionMCNDetailsTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            MRCommissionCalcDetailsCtrl.fetchAccountDetails(mncNumber,lstMCNAccount.get(0).Id,lstAccount.get(0).Id);
            MRCommissionCalcDetailsCtrl.fetchAccountDetails(mncNumber,lstMCNAccount.get(0).Id,null);
        }
    }
}