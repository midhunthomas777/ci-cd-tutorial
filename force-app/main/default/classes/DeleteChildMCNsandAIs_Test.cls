/***************************************************************
Test class for DeleteChildMCNsandAIs
***************************************************************/
@isTest
Private class DeleteChildMCNsandAIs_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void testcase1() {    
        Id CustomerId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account Acc = new Account(Name='Test',BillingCountry='United States',BillingCity='Test',RecordTypeId=CustomerId);
        insert Acc;
        delete Acc;
    
    }
}