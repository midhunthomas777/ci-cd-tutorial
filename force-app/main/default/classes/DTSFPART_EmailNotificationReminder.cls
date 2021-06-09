/**
 * @author       Sagar Sindhi
 * @created      2020-08-19
 * @updated      2020-10-15
 * @description  Helper class calling from Process on MPE_Contact__c object to send Reminder Email Notification to Partner Admin
 */
public with sharing class DTSFPART_EmailNotificationReminder {

	@InvocableMethod(label = 'Reminder Email Notification')
	public static void sendEmailNotification(List<EmailNotificationRequest> notificationRequest) {
		List<Id> mpeContactIds = new List<Id>();
		Id templateId;
		for (EmailNotificationRequest req: notificationRequest) {
			templateId = req.templateID;
			mpeContactIds.add(req.mpeContactId);
		}

		if (!mpeContactIds.isEmpty()) {
			MPE_ContactResponse contactResponse = getMPEContacts(mpeContactIds);
			Map<Id, List<String>> recordIdWithEmails = getRecordIdWithEmails(contactResponse.accountContactMap);
			List<Id> targetobjIds = getTargetObjectIds(contactResponse.accountContactMap);
			List<MPEContact__c> mpeContactList = contactResponse.contactList;

			EmailMessagingClass.sendEmailMessage(
				targetobjIds,
				templateId,
				mpeContactList,
				false,
				null,
				null,
				null,
				false,
				recordIdWithEmails
			);
		}
	}

	private static MPE_ContactResponse getMPEContacts(List<Id> mpeContactIds) {
		Map<Id, List<Id>> accountContactMap = new Map<Id, List<Id>> ();
		List<MPEContact__c> mpeContactList = new List<MPEContact__c>();
		for (MPEContact__c eachMPEContact: [
				SELECT Id, Account__c
				FROM MPEContact__c
				WHERE Id IN: mpeContactIds
			]) {
			if (!accountContactMap.containskey(eachMPEContact.Account__c)) {
				accountContactMap.put(eachMPEContact.Account__c, new List<Id>());
			}
			accountContactMap.get(eachMPEContact.Account__c).add(eachMPEContact.Id);
			mpeContactList.add(eachMPEContact);
		}
		MPE_ContactResponse contactResponse = new MPE_ContactResponse();
		contactResponse.accountContactMap = accountContactMap;
		contactResponse.contactList = mpeContactList;
		return contactResponse;
	}

	private static Map<Id, List<String>> getRecordIdWithEmails(Map<Id, List<Id>> accountContactMap) {
		Map<Id, List<String>> recordIdWithEmails = new Map<Id, List<String>> ();
		for (Contact eachContact: [
				SELECT Id, AccountId, Email
				FROM Contact
				WHERE
				Contact_MCN_Permissions__c INCLUDES('UserAdmin')
				AND AccountId IN: accountContactMap.keySet()
			]) {
			List<Id> partnerContactIds = accountContactMap.get(eachContact.AccountId);
			if (!partnerContactIds.isEmpty()) {
				for (Id eachMPEId: partnerContactIds) {
					if (!recordIdWithEmails.containskey(eachMPEId)) {
						recordIdWithEmails.put(eachMPEId, new List<String>());
					}
					recordIdWithEmails.get(eachMPEId).add(eachContact.Email);
				}
			}
		}
		return recordIdWithEmails;
	}

	private static List<Id> getTargetObjectIds(Map<Id, List<Id>> accountContactMap) {
		List<Id> targetobjIds = new List<Id>();
		Map<Id, Contact>targetObjMap = new Map<Id, Contact>(
			[
				SELECT Id
				FROM Contact
				WHERE
				RecordType.DeveloperName = 'MPE_Partner_Contact'
				AND Email != NULL
				AND AccountId IN: accountContactMap.keySet()
				LIMIT 1
			]
		);
		targetobjIds.addAll(targetObjMap.keySet());
		return targetobjIds;
	}

	public class MPE_ContactResponse {
		public Map<Id, List<Id>> accountContactMap;
		public List<MPEContact__c> contactList;
	}

	public class EmailNotificationRequest {
		@InvocableVariable(label = 'MPEContact ID')
		public Id mpeContactId;

		@InvocableVariable(label = 'Email Template ID')
		public Id templateID;
	}
}