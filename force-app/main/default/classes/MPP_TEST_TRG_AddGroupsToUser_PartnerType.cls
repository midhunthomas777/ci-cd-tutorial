/*
* Name:  MPP_TEST_TRG_AddGroupsToUser_PartnerType
* Purpose: Test class for MPP_TRG_AddGroupsToUser_PartnerType trigger
*/

@isTest
private class MPP_TEST_TRG_AddGroupsToUser_PartnerType {

    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void testAddGroupsToUserPartnerType() {
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                             AND DeveloperName = 'Partner'];
        Account acc = new Account(Name='Test account',Shared_Partner__c=true,RecordTypeId=recType.Id,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='NAMR',Owner_Business_Group__c='Government',
                                  Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                  CASPA_groups__c = 'Connect Adv Partner');
        insert acc;
    	
	    Partner_Type__c pt = new Partner_Type__c(Account__c = acc.Id, Purchasing_Method__c = 'purchMethod');			
	    
	    test.startTest();
	    try{
	    	insert pt;
	    	//Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
	    }catch (system.exception e){
	    	system.debug('ERROR: ' + e.getMessage());
	    }
	    test.stopTest();
	    
	    
	    try{
	    	MPP_Class_HLPR_AddGroupsToUser_Advanced.partnerTypeTriggerIsRunning = false;
	    	delete pt;
	    	//Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
	    }catch (system.exception e){
	    	system.debug('ERROR ' + e.getMessage());
	    }
    }
}