@IsTest
public with sharing class DTSFPART_PortalUserCreationTest {

    @TestSetup
    private static void setup() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        DTSFPART_TestDataSetUpUtils.currentuserSetting();
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
        Id mcnAccountId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccount = DTSFPART_TestDataSetUpUtils.createMCNAccounts(1, mcnAccountId, new List<Account>{acc}, true);
        Contact contact = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        contact.FirstName = 'Test';
        contact.LastName = 'setup';
        contact.Email = 'setup@test.test';
        contact.Persona__c = 'OwnerExecutive';
        insert contact;
        contact.C360_Response__c = 'some response from C360';
        contact.Enterprise_Permission_Status__c = 'Completed';
        update contact;
    }

    @IsTest
    private static void executeTest() {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Account acc :[SELECT Id FROM Account]) {
            accountIds.add(acc.Id);
        }
        for(Contact c :[SELECT Id FROM Contact]) {
            contactIds.add(c.Id);
        }
        Test.startTest();
        System.enqueueJob(new DTSFPART_PortalUserCreation(contactIds, accountIds));
        Test.stopTest();
        // System.assertEquals(0, [SELECT Id FROM MPEContact__c].size(), 'MPEContact__c records should be deleted.');
        
    }
}