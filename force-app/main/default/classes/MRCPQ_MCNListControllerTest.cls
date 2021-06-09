@isTest
public class MRCPQ_MCNListControllerTest {
 @isTest
    public static void mcnListControllerTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id accMCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            Test.startTest();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID); 
            List<Account> lstMCNAccount =TestDataSetUpUtils.createMCNAccounts(2,accMCNrectypeID,lstAccount);
            Test.stopTest();
            List<Account> lstAccountResult= MRCPQ_MCNListController.getLimitedAccounts(lstAccount.get(0).Id);
            system.assertEquals(2,lstAccountResult.size());
        }
     }
}