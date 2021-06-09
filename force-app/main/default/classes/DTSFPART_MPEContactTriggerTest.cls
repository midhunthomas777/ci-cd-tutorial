/**
 * @author       Sagar Sindhi
 * @created      2020-09-22
 * @updated      2020-12-28
 * @isTesting	 DTSFPART_MPEContactTrigger, DTSFPART_MPEContactTriggerHandler, DTSFPART_MPEContactTriggerHelper
 * @description  Test for trigger class
 */

@isTest
public class DTSFPART_MPEContactTriggerTest {
	@testSetup
	static void testSetUp() {
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();
		Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
		List<Account>partnerAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(1, partnerRecordType);

		Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), true);
		Contact adminContact = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), false);
        adminContact.Email = 'testcontact@gmail.com';
        insert adminContact;
		adminContact.Contact_MCN_Permissions__c = 'UserAdmin';
		update adminContact;
	}

	@isTest
	public static void testInsert() {
		List<Account>partnerAccounts = [SELECT Id, Name FROM Account LIMIT 1];
		List<Contact>contacts = [SELECT Id, Name FROM Contact LIMIT 2];
		DTSFPART_TestDataSetUpUtils.createPortalUserWithoutRole(contacts.get(0), true);

		Test.startTest();
		List<User>muleSoftUser = [
			SELECT Id
			FROM user
			WHERE name = 'Mulesoft Integration'
			LIMIT 1
		];
		if (!muleSoftUser.isEmpty()) {
			System.runAs(muleSoftUser.get(0)) {
				List<MPEContact__c>mpeContacts = DTSFPART_TestDataSetUpUtils.createMPEContacts(2, partnerAccounts, true);
				System.assertEquals(partnerAccounts.get(0).Id, mpeContacts.get(0).Account__c);
			}
		}
		Test.stopTest();
	}

	@isTest
	public static void testUpdate() {
		List<Account>partnerAccounts = [SELECT Id, Name FROM Account LIMIT 1];
		Test.startTest();
		List<MPEContact__c>mpeContacts = DTSFPART_TestDataSetUpUtils.createMPEContacts(1, partnerAccounts, true);
		mpeContacts.get(0).First_Name__c = 'test update';
		update mpeContacts;
		Test.stopTest();
		System.assertEquals('test update', mpeContacts.get(0).First_Name__c);
	}

	@isTest
	public static void testDelete() {
		List<Account>partnerAccounts = [SELECT Id, Name FROM Account LIMIT 1];
		Test.startTest();
		List<MPEContact__c>mpeContacts = DTSFPART_TestDataSetUpUtils.createMPEContacts(1, partnerAccounts, true);
        System.assert(!mpeContacts.isEmpty());
		delete mpeContacts;
		Test.stopTest();
	}
}