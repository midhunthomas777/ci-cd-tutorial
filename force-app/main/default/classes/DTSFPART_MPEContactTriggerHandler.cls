/**
 * @author       Sagar Sindhi
 * @created      2020-08-05
 * @updated      2020-12-28
 * @description  Trigger Handler on MPEContact__c for DTSFPART project
 */
public with sharing class DTSFPART_MPEContactTriggerHandler implements ITriggerHandler {
	public static Boolean TriggerDisabled = false;
	public DTSFPART_MPEContactTriggerHelper triggerHelper = new DTSFPART_MPEContactTriggerHelper();

	public Boolean isDisabled() {
		if (TriggerSettings__c.getValues('MPETriggerDisabled') != null && TriggerSettings__c.getValues('MPETriggerDisabled').IsActive__c)
			return true;
		else
			return TriggerDisabled;
	}

	public void beforeInsert(List<SObject> newItems) {
	}
	public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
	public void beforeDelete(Map<Id, SObject> oldItems) {}

	public void afterInsert(Map<Id, SObject> newItems) {
		Map<Id, MPEContact__c> newMPEContactsMap = (Map<Id, MPEContact__c> ) newItems;
		Map<Id, List<Id>> accountWithMPEMap = new Map<Id, List<Id>> ();

		List<MPEContact__c> mpeContacts = [
			SELECT Id, Account__c, Status__c, CreatedById
			FROM MPEContact__c
			WHERE Id IN: newMPEContactsMap.keyset() AND Account__c != NULL
		];

		if (!mpeContacts.isEmpty()) {
			accountWithMPEMap = getAccountsWithMPEContacts(mpeContacts);
		}

		if (!accountWithMPEMap.isEmpty()) {
			triggerHelper.notifyPartnerContacts(
				accountWithMPEMap,
				newMPEContactsMap.values()
			); // https://jira.mot-solutions.com/browse/DTPART-270
		}
	}

	public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
	public void afterDelete(Map<Id, SObject> oldItems) {}
	public void afterUndelete(Map<Id, SObject> oldItems) {}

	private static Map<Id, List<Id>> getAccountsWithMPEContacts(List<MPEContact__c> mpeContacts) {
		Map<Id, List<Id>> accountWithMPEMap = new Map<Id, List<Id>> ();
		List<User> userList = [
			SELECT Id, Name
			FROM User
			WHERE Name = 'Mulesoft Integration'
		];

		for (MPEContact__c eachMPEContact: mpeContacts) {
            if (String.isNotBlank(eachMPEContact.Status__c)) {
                if (eachMPEContact.Status__c.equals('Pending Registration') && eachMPEContact.CreatedById.equals(userList.get(0).Id)) {
                    if (accountWithMPEMap.containsKey(eachMPEContact.Account__c)) {
                        List<Id> mpeIds = accountWithMPEMap.get(eachMPEContact.Account__c);
                        mpeIds.add(eachMPEContact.Id);
                        accountWithMPEMap.put(eachMPEContact.Account__c, mpeIds);
                    } else {
                        accountWithMPEMap.put(
                            eachMPEContact.Account__c,
                            new List<Id> {eachMPEContact.Id}
                        );
                    }
                }
            }
		}
		return accountWithMPEMap;
	}
}