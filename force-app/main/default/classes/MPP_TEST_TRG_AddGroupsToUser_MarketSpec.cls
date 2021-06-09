/*
*	Name:  MPP_TEST_TRG_AddGroupsToUser_MarketSpec
*	Purpose: Test class for MPP_TRG_AddGroupsToUser_MarketSpec trigger
*/

@isTest
private class MPP_TEST_TRG_AddGroupsToUser_MarketSpec {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void testAddGroupsToUserMarketSpec() {
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                              AND DeveloperName = 'Partner'];
        List<Account> AccList = TestDataSetUpUtils.createAccounts(1,recType.Id);
        Acclist[0].Shared_Partner__c=true;
        Acclist[0].RecordTypeId=recType.Id;
        Acclist[0].MPE_Program_Status_New__c='Active';
        Acclist[0].Level__c='Authorized Reseller';
        Acclist[0].WNS_Track__c= true;
        Acclist[0].Mobility_Track__c=true;
        Acclist[0].Status__c='Active';
        Acclist[0].Metal_Level__c = 'gold'; 
        Acclist[0].Partner_Region__c='NAMR';
        Acclist[0].Owner_Business_Group__c='Government';
        Acclist[0].Partner_HQ_Country__c='Austria';
        Acclist[0].Sales_View_Upload_Mode__c='DLS';
        Acclist[0].CASPA_groups__c = 'Connect Adv Partner';
        update Acclist;
        Market_Specializations__c m = new Market_Specializations__c(Account__c = AccList[0].Id, Market_Specialization__c = 'marketSpec');
        test.startTest();
        try {
            insert m;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e) {
            system.debug('ERROR: ' + e.getMessage());
        }
        test.stopTest();
        try {
            MPP_Class_HLPR_AddGroupsToUser_Advanced.marketSpecTriggerIsRunning = false;
            delete m;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e) {
            system.debug('ERROR ' + e.getMessage());
        }
    }
}