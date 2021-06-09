/*  
 * File Name  : MPE_Compl_TrigUpdateAPRD_Test
 * Description: Test class for Account object
 * Modification Log 
 * ============================================================================= 
 * Ver    Date          Author                         creation 
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 1.0    19/02/2013    Dhivya               test class for MPE_Compl_trigUpdateAPRD
 *
 */

@isTest
Private class MPE_Compl_TrigUpdateAPRD_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    public static testmethod void TrigUpdateAPRD_Test() {
        string strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Partner'].Id;
        List<Account> accList = TestDataSetUpUtils.createAccounts(2,strRecordTypeId);
        accList[0].Partner_Account_Name__c='ParentAccount';
        accList[0].Partner_Region__c='APAC';
        accList[0].Partner_Zone__c ='1';
        accList[0].MPE_Program_Status_New__c='Active';
        accList[0].Hierarchy_Placement__c='Regional Account' ;   
        accList[0].Metal_Level__c='Authorized'; 
        update accList;
        accList[1].Partner_Account_Name__c='ParentAccountEMEA';
        accList[1].Partner_Region__c='EMEA';
        accList[1].Partner_Zone__c ='3';
        accList[1].MPE_Program_Status_New__c='Active';
        accList[1].Hierarchy_Placement__c='Regional Account' ;   
        accList[1].Metal_Level__c='Authorized';   
        update accList;
        /*Account acc = new Account();
acc.RecordTypeId=strRecordTypeId ;
acc.Name='ParentAccount';
acc.Partner_Account_Name__c='ParentAccount';
acc.Partner_Region__c='APAC';
acc.Partner_Zone__c ='1';
acc.MPE_Program_Status_New__c='Active';
acc.Hierarchy_Placement__c='Regional Account' ;   
acc.Metal_Level__c='Authorized';   
insert acc;

List <Account> ac = new List<Account>();  
ac.add(acc);  

acc = new Account();
acc.RecordTypeId=strRecordTypeId ;
acc.Name='ParentAccountEMEA';
acc.Partner_Account_Name__c='ParentAccountEMEA';
acc.Partner_Region__c='EMEA';
acc.Partner_Zone__c ='3';
acc.MPE_Program_Status_New__c='Active';
acc.Hierarchy_Placement__c='Regional Account' ;   
acc.Metal_Level__c='Authorized';   
insert acc;
ac.add(acc); */
        
        List<Account> accUpdate= new List<Account>();
        for(Account a:accList) {    
            a.Program_Join_Date__c = System.today();
            update a; 
            accUpdate.add(a);
        } 
        
        for(Account a:accUpdate) {    
            a.PartnerEmpower_Inactivated_Date__c =system.today(); 
            a.PartnerEmpower_Reactivated_Date__c=system.today();
            update a; 
        } 
    }
}