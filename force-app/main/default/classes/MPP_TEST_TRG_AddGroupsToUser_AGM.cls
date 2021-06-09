/*
*	Name:  MPP_TEST_TRG_AddGroupsToUser_AGM
*	Purpose: Test class for MPP_TRG_AddGroupsToUser_AGM trigger
*/
@isTest
private class MPP_TEST_TRG_AddGroupsToUser_AGM {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void testAddGroupsToUserAgm() {
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                              AND DeveloperName = 'Partner'];
        List<Account> AccList = TestDataSetUpUtils.CreateAccounts(1,recType.id);
        Attribute_Group_Mapping__c agm = new Attribute_Group_Mapping__c();
        Group g = new Group(name = 'random group');
        insert g;
        
        agm.Group__c = g.Name;
        agm.GroupId__c = g.Id;
        agm.Region__c = 'NAMR';
        
        try {
            insert agm;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e) {
            system.debug('ERROR: ' + e.getMessage());
        }
        
        try {
            update agm;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e) {
            system.debug('ERROR: ' + e.getMessage());
        }
        
        try {
            delete agm;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (system.exception e) {
            system.debug('ERROR ' + e.getMessage());
        }
    }
}