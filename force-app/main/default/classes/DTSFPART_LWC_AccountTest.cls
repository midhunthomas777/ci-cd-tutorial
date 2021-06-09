@isTest
public class DTSFPART_LWC_AccountTest {
    
    @IsTest
    private static void getCustomerNumbersByAccountId(){
        Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Account partnerAccount = [SELECT Id, Motorola_Customer_Number__c FROM Account WHERE Name = 'Test Account' AND RecordTypeId = :partnerRecordTypeId LIMIT 1];

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        Test.startTest();
        TestDataSetUpUtils.createMCNAccounts(2, mcnRecordTypeId, new List<Account>{partnerAccount});

        List<Account> testAccounts;
        //Test.startTest();
            testAccounts = DTSFPART_CommonComponentsController.getCustomerNumbersByAccountId(partnerAccount.Id);
        Test.stopTest();

        System.assertEquals(2, testAccounts.size());
    }

}