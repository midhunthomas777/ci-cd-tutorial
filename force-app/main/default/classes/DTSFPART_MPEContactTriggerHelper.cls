/**
 * @author       Sagar Sindhi
 * @created      2020-08-05
 * @updated      2020-10-12
 * @description  Trigger Helper on MPEContact__c Trigger for all the functional logic
 */
public with sharing class DTSFPART_MPEContactTriggerHelper {


	public void notifyPartnerContacts(Map<Id, List<Id>> accountWithMPEMap, List<MPEContact__c> mpeContacts) {
		Map<Id, List<String>> objWithEmails = new Map<Id, List<String>>();
		if (!accountWithMPEMap.isEmpty()) {
			for (Contact eachContact: [
					SELECT Id, AccountId, Email
					FROM Contact
					WHERE
					Contact_MCN_Permissions__c INCLUDES('UserAdmin')
					AND AccountId IN: accountWithMPEMap.keySet()
				]) {
				List<Id>partnerContactIds = accountWithMPEMap.get(eachContact.AccountId);
				if (!partnerContactIds.isEmpty()) {
					for (Id eachMPEId: partnerContactIds) {
						if (objWithEmails.containsKey(eachMPEId)) {
							List<String>addresses = objWithEmails.get(eachMPEId);
							addresses.add(eachContact.Email);
							objWithEmails.put(eachMPEId, addresses);
						} else {
							objWithEmails.put(
								eachMPEId,
								new List<String>{eachContact.Email}
							);
						}
					}
				}
			}
		}

		List<Id> targetobjIds = new List<Id>();
		Map<Id, Contact> targetObjMap = new Map<Id, Contact>(
			[
				SELECT Id
				FROM Contact
				WHERE
				RecordType.DeveloperName = 'MPE_Partner_Contact'
				AND Email != NULL
				AND AccountId IN: accountWithMPEMap.keySet()
				LIMIT 1
			]
		);
		targetobjIds.addAll(targetObjMap.keySet());

		EmailTemplate template = [
			SELECT Id
			FROM EmailTemplate
			WHERE DeveloperName = 'User_Registration_Notification_To_Admin'
		];
		if (!objWithEmails.isEmpty()) {
			EmailMessagingClass.sendEmailMessage(
				targetobjIds,
				template.Id,
				mpeContacts,
				false,
				null,
				null,
				null,
				false,
				objWithEmails
			);
		}
	}
}