@isTest
public class MRCPQ_OpportunityBtnPanelControllerTest {
    @isTest
    public static void opportunityBtnPanelControllerTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        Test.startTest();
        TestDataSetUpUtils.assignPermissionSet(partneruser.Id);
        Test.stopTest();
        system.runAs(partneruser){
            system.debug('checkpermissionintest '+Schema.sObjectType.Opportunity.isUpdateable()); 
            List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
            Boolean result = MRCPQ_OpportunityBtnPanelController.showAddRemoveFamilybtn(lstOpportunity.get(0).Id);
            //system.assertEquals(true ,result);
        }
    }
}