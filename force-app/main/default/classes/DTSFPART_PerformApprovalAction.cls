/**
 * @author       Sagar Sindhi
 * @created      2020-09-30
 * @updated      2020-10-15
 * @description  Helper class calling from DTSFPART_ContactTriggerHandler for deletion of MPE_Contact__c record in system context
 */
public without sharing class DTSFPART_PerformApprovalAction {
	public static void deleteMPEContactAndSendEmail(Map<Id, Id> contactWithMPEID) {
		List<MPEContact__c> contactsToBeDeleted = [
			SELECT Id
			FROM MPEContact__c
			WHERE Id IN: contactWithMPEID.values()
		];
		if (!contactsToBeDeleted.isEmpty()) {
			try {
				delete contactsToBeDeleted; // Delete MPE Contacts
				updateContactRecord(contactWithMPEID.keySet());
			} catch (Exception e) {
				LogError.saveExceptionPEvent('DTSFPART_PerformApprovalAction.deleteMPEContactAndSendEmail', '', '', e);
				throw e;
			}
		}
		sendEmailNotification(contactWithMPEID.keySet());
	}

	private static void updateContactRecord(Set<Id> contactIds) {
		List<Contact> contactsTOBeUpdated = new List<Contact>();
		for (Contact eachContact: [
				SELECT Id, MPE_ContactId__c
				FROM Contact
				WHERE Id IN: contactIds
			]) {
			eachContact.MPE_ContactId__c = '';
			contactsTOBeUpdated.add(eachContact);
		}
		//update MPE_ContactId__c field to blank in the contact record as MPEContact__c record has been deleted
		if (!contactsTOBeUpdated.isEmpty()) {
			update contactsTOBeUpdated;
		}
	}

	private static void sendEmailNotification(Set<Id> contactIds) {
		List<EmailTemplate> template = [
			SELECT Id
			FROM EmailTemplate
			WHERE DeveloperName = 'Partner_Admin_Approval_Notification'
		];
		EmailMessagingClass.sendEmailMessage(
			new List<Id>(contactIds),
			template.get(0).Id,
			null,
			false,
			null,
			null,
			null,
			true,
			null
		);
	}
}