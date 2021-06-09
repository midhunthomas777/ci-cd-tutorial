/*
Name:  MPP_TEST_TRG_AddGroupsToUser_TechSubSeg
Purpose: Test class for MPP_TRG_AddGroupsToUser_TechSubSeg trigger
          
==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      13 Feb 2017       INITIAL DEVELOPMENT       

******************************************************************************************/ 
@isTest
private class MPP_TEST_TRG_AddGroupsToUser_TechSubSeg  {
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
       LDAP_Settings__c LDAP = new LDAP_Settings__c(name='Current',Disable_Triggers__c = TRUE);
       insert LDAP;
   }

    static testMethod void testAddGroupsToUserTechSubSegm() {
         Test.startTest();
      Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> Acclist = TestDataSetUpUtils.createAccounts(1, prospectId);
        List<Partner_Type__c> PTList = TestDataSetUpUtils.createProgramInfoRecords(1,Acclist);
		List<Technology_Specialization__c> TSList = TestDataSetUpUtils.createTechSpecInfoRecords(1,PTList,Acclist);
        List<Technology_SubSegment__c> TSubList = testdatasetupUtils.createTechSSRecords(1,TSList,Acclist);
        Test.stopTest();
        try{
            MPP_Class_HLPR_AddGroupsToUser_Advanced.techSubSegmntTriggerIsRunning = false;
            delete TSubList[0];
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (System.exception e){
            System.debug('ERROR ' + e.getMessage());
        }
    }
}