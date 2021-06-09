/**
 * @author       Sagar Sindhi
 * @created      2020-09-23
 * @updated      2021-02-03
 * @isTesting    DTSFPART_PartnerAdminController
 */
@isTest
public class DTSFPART_PartnerAdminController_Test {
    @testSetup
    static void testSetUp() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        List<Account> partnerAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(1, partnerRecordType);
        Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), true);
    }

    @isTest
    public static void test_AdminProcess() {
        List<Account> partnerAccounts = [SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 1];

        Test.startTest();
        List<MPEContact__c> contactResult = DTSFPART_TestDataSetUpUtils.createMPEContacts(1, partnerAccounts, false);
        contactResult.get(0).Country__c = 'United States';
        Insert contactResult;
        System.assertEquals(partnerAccounts.get(0).Id, contactResult.get(0).Account__c);

        DTSFPART_PartnerAdminController.getExistingDetails(contactResult.get(0).Id);
        DTSFPART_PartnerAdminController.denyUserANDSendNotification(contactResult.get(0).Id);
        Test.stopTest();
    }
}