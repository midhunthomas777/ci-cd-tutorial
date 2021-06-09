/*************************************************************************
Class Name : AccListControllerTest
Description : Test class for AccListController class
Author : Anitha Mohankumar
**************************************************************************/
@IsTest
public Class AccListControllerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void AccListControllerTest() {
        test.StartTest();       
        RecordType prosRecType = [Select Id from RecordType where Name='Prospect' and SobjectType='Account' limit 1];
        List<Account> prosAcc = TestDataSetUpUtils.createAccounts(1, prosRecType.id);
        Account Mcn = [Select Id,Parent.Id from Account where Parent.ID=:prosAcc[0].Id limit 1];
        Id competitorId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Account Acc1 = new Account(Name='Test Competitor Account',billingcountry='United States',billingstate='Illinois',billingcity='Schaumburg',recordtypeId = competitorId);
        Insert Acc1; 
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<opportunity> opplist = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, prosAcc);    
        List<Account> accounts=AccListController.getAccounts(prosAcc[0].Id);
        String SessionID = AccListController.sessionId();
        String strSuccess = AccListController.LtnSelectedMCN(Mcn.Id);
        String strSuccess1 = AccListController.updateOpp(opplist[0].Id,Mcn.Id);
        test.StopTest();
    }
}