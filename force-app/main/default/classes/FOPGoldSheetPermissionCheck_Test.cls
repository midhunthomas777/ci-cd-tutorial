/* @Class Name   : FOPGoldSheetPermissionCheck_Test
* @Description  : Test Class for the FOPGoldSheetPermissionCheck
* @Created By   : Vivek Pokharia
* @Created On   : 6  March  2018
* @Modification Log:  
* -----------------------------------------------------------------------------
* @Developer                Date                  Description 
* -----------------------------------------------------------------------------
* @Vivek Pokharia         6 March 2018              Created
* -----------------------------------------------------------------------------
*/ 
@isTest
private class FOPGoldSheetPermissionCheck_Test {
    
    private static testMethod void testMethod1() {
        TestDataSetUpUtils.activateAccTrigger();
        TestDataSetUpUtils.activateContTrigger();
        list<Account> AccountRecRec=TestDataSetUpUtils.createAccounts(2,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId);
        list<field_Of_Play__c> fop= TestDataSetUpUtils.createFOPRecords(2,AccountRecRec);
        PageReference pageRef = Page.FieldOfPlayGoldSheetLaunch; 
        ApexPages.CurrentPage().getParameters().put('id',fop[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(AccountRecRec[0]);
        FOPGoldSheetPermissionCheck testAccPlan = new FOPGoldSheetPermissionCheck(sc);
        testAccPlan.isReadOnlyFlag=null;
        Boolean testError = testAccPlan.isReadOnlyFlag;
        System.assert(testError == true);
        
    }
    
}