/********************************************************************
* Class Name  : OpportunitySubAccountTriggerTest
* Description:  This is Test Class for OpportunitySubAccountTrigger              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -------------------------------------------------------------------------------------------------
*************************************************************************************************/

@isTest
public class OpportunitySubAccountTriggerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testBeforeInsert(){ 
        //Create Prospect Account
        Id prospectRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id customerRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id prospectAccountId = TestDataSetUpUtils.createAccounts(1, prospectRecTypeId)[0].Id;
        Id customerAccountId = TestDataSetUpUtils.createAccounts(1, customerRecTypeId)[0].Id;
        Id opptyId = TestDataSetUpUtils.createProjectOpportunity()[0].Id;
        List<Account> accountToBeInserted = new List<Account>();
        
        Account Chilaccount =new Account(Name = 'MCN1',RecordTypeId = mcnRecTypeId, ParentId=customerAccountId,
                                         CurrencyIsoCode ='USD',ERP_Active__c=true);
        Account Chilaccount1 =new Account(Name = 'MCN2',RecordTypeId = mcnRecTypeId, ParentId=customerAccountId,
                                          CurrencyIsoCode ='USD',ERP_Active__c=true);
        accountToBeInserted.add(Chilaccount);
        accountToBeInserted.add(Chilaccount1);
        insert accountToBeInserted;
        Test.startTest();
        try{
            TestDataSetUpUtils.createSubAccounts(2, opptyId, prospectAccountId);
            TestDataSetUpUtils.createSubAccounts(1, opptyId, customerAccountId);
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    public static void testBeforeUpdate(){  
       //Create Prospect Account
        Id accProsRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(2, accProsRecordTypeId);
        Id accId = accList[0].Id;
        Id accId1 = accList[1].Id;
        Id opptyId = TestDataSetUpUtils.createProjectOpportunity()[0].Id;       
       
        List<SubAgency__c> subAccList = TestDataSetUpUtils.createSubAccounts(1, opptyId, accId);
        Test.startTest();
        SubAgency__c subAcc = subAccList[0];
        subAcc.Sub_Account__c = accId1;
        update subAcc;
        delete subAcc;
        Test.stopTest();
    }
}