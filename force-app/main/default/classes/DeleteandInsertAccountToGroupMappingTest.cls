/*
Name:  DeleteandInsertAccountToGroupMappingTest
Purpose: Test class for DeleteandInsertAccountToGroupMapping         
==========================================================================================
History
-------                                                                                                                  
VERSION      AUTHOR            DATE                 DETAIL                   
1.0 -     Vineela N      03 Apr 2019       INITIAL DEVELOPMENT       

******************************************************************************************/
@isTest 
public class DeleteandInsertAccountToGroupMappingTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void testMethod1() {
        //List<Account_to_Group_Mapping__c> lstAccGrp = new List<Account_to_Group_Mapping__c>();
        Account_to_Group_Mapping__c accGrp = new Account_to_Group_Mapping__c(CurrencyIsoCode = 'USD');
        //lstAccGrp.add(accGrp);
        insert accGrp;
        Id partnrRecTypeId = GlobalUtility.recordTypeId('Account', 'Partner');
        Account partnerAcc = new Account(Name= 'PartnerAcc',RecordtypeId = partnrRecTypeId);
        insert partnerAcc;
        Test.startTest();
        List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test Systems Inc.',RecordTypeId=partnrRecTypeId,Shared_Partner__c=true,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='NAMR',Owner_Business_Group__c='Government',
                                   Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                   CASPA_groups__c = 'Connect Adv Partner');
        accountList.add(acc1);
        Account acc2 = new Account(Name='motorola Systems Inc.',RecordTypeId=partnrRecTypeId,Shared_Partner__c=true,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='EMEA',Owner_Business_Group__c='Government',
                                   Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                   CASPA_groups__c = 'Connect Adv Partner');
        accountList.add(acc2);
        Database.insert(accountList);
        Set<Id> accSet = new Set<Id>();
        for(Account eachAcc : accountList ) {
            accSet.add(eachAcc.id);
        }
        DeleteandInsertAccountToGroupMapping batchjob = new DeleteandInsertAccountToGroupMapping(accSet);
        String batchID = Database.executeBatch(batchjob, 200 );
        Test.stopTest();
    }   
}