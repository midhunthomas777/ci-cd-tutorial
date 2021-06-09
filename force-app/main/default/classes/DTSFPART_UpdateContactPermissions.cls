/**
 * @author: WGVR43 
 * @date: 18.08.2020
 * @group: DTSFPART
 * @description: 
 */

public with sharing class DTSFPART_UpdateContactPermissions implements Queueable {
	private Map<Id, Technology_Specialization__c> newProgramDetails;
	private Map<Id, Technology_Specialization__c> oldProgramDetails;
	private Set<Id> accountIds;

	public DTSFPART_UpdateContactPermissions(Map<Id, Technology_Specialization__c> newProgramDetails,
			Map<Id, Technology_Specialization__c> oldProgramDetails){
		this.newProgramDetails = newProgramDetails;
		this.oldProgramDetails = oldProgramDetails;
		setAccountIds();
	}

	private void setAccountIds() {
		accountIds = new Set<Id>();
		for( Technology_Specialization__c programDetail : newProgramDetails.values()) {
			accountIds.add(programDetail.Account__c);
		}
	}

	public void execute(QueueableContext context) {
		try {
			if(accountIds != null){
				List<Contact> contacts = getContactsByParentAccounts(accountIds);
				List<Contact> oldContacts = contacts.deepClone(true);
				List<Contact> newContacts = DTSFPART_PermissionUtils.setHubDefaultPermissions(contacts);
				update newContacts;
				if (!Test.isRunningTest()) {
					System.enqueueJob(new DTSFPART_UpdateMcnPermissions(newProgramDetails, oldProgramDetails,
							new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts)));
				}
			}
		}
		catch(Exception e)
		{
			LogError.saveExceptionPEvent('DTSFPART_UpdateContactPermissions.execute',
					'','',e
			);
			throw e;
		}
	}

	public static List<Contact> getContactsByParentAccounts(Set<Id> parentAccountsIds) {
		return [
				SELECT Id, Name, Persona__c, AccountId, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c, Tag__c
				FROM Contact
				WHERE 
					AccountId IN :parentAccountsIds AND 
					Account.Partner_Hub_enabled__c = TRUE AND
					Account.MPE_Program_Status_New__c = 'Active' AND
					Account.Motorola_Enterprise_ID__c != '' AND
					Delete_Requested__c = FALSE AND 
					Persona__c != NULL AND 
					Status__c != 'Inactive' AND 
					Status__c != 'Deactivation Requested' AND 
					Status__c != NULL AND 
					Persona__c != NULL
		];
	}
}