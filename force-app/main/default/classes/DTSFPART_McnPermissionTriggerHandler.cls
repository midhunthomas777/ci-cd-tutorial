/**
 * @author: WGVR43 
 * @date: 25.08.2020
 * @group: DTSFPART
 * @description: 
 */
public with sharing class DTSFPART_McnPermissionTriggerHandler implements ITriggerHandler {
	
	public Boolean isDisabled() {
		return new DTSFPART_TriggerConfigurationService('McnPermissionsTrigger','DTSFPART_McnPermissionTriggerHandler').isTriggerLogicDisabled();
	}

	public void beforeInsert(List<SObject> newItems) {
		if (newItems != null) {
			List<MCN_Permission__c> newMcnPermissions = (List<MCN_Permission__c>) newItems;
			Set<Id> enterpriseIds = new Set<Id>();
			for (MCN_Permission__c mcnPermission : newMcnPermissions) {
				enterpriseIds.add(mcnPermission.Customer_OR_Partner_Account__c);
			}
			DTSFPART_PermissionUtils.setEnterprisePermissionStatusOnAccounts(enterpriseIds, 'In Progress');
		}
	}

	public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		if (newItems != null) {
			Map<Id, MCN_Permission__c> newMcnPermissions = (Map<Id, MCN_Permission__c>) newItems;
			Map<Id, MCN_Permission__c> oldMcnPermissions = (Map<Id, MCN_Permission__c>) oldItems;
			Set<Id> enterpriseIds = new Set<Id>();
			for (MCN_Permission__c newMcnPermission : newMcnPermissions.values()) {
				MCN_Permission__c oldMcnPermission = oldMcnPermissions.get(newMcnPermission.Id);
				if(newMcnPermission.Contact_MCN_Permissions__c != oldMcnPermission.Contact_MCN_Permissions__c
						|| newMcnPermission.MCN_Permissions__c != oldMcnPermission.MCN_Permissions__c) {
					enterpriseIds.add(newMcnPermission.Customer_OR_Partner_Account__c);
				}
			}
			if(!enterpriseIds.isEmpty()) {
				DTSFPART_PermissionUtils.setEnterprisePermissionStatusOnAccounts(enterpriseIds, 'In Progress');
			}
		}
	}

	public void beforeDelete(Map<Id, SObject> oldItems) {
		deleteContactMcnPermissions(oldItems.keySet());
	}

	public void afterInsert(Map<Id, SObject> newItems) {
		if(newItems != null && !DTSFPART_Utils.isAsynchronous()){
			Map<Id, MCN_Permission__c> mcnPermissions = (Map<Id, MCN_Permission__c>) newItems;

			// https://jira.mot-solutions.com/browse/DTPART-232
			System.enqueueJob(new DTSFPART_UpdateContactMCNPermissions(mcnPermissions, new Map<Id, MCN_Permission__c>()));
		}
	}

	public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		if(newItems != null && oldItems != null  && !DTSFPART_Utils.isAsynchronous()){
			Map<Id, MCN_Permission__c> newMcnPermissions = new Map<Id, MCN_Permission__c>();
			Map<Id, MCN_Permission__c> oldMcnPermissions = new Map<Id, MCN_Permission__c>();
			for(MCN_Permission__c newMcnPermission : (List<MCN_Permission__c>) newItems.values()) {
				MCN_Permission__c oldMcnPermission = (MCN_Permission__c) oldItems.get(newMcnPermission.Id);
				if(newMcnPermission.Contact_MCN_Permissions__c != oldMcnPermission.Contact_MCN_Permissions__c) {
					newMcnPermissions.put(newMcnPermission.Id, newMcnPermission);
					oldMcnPermissions.put(oldMcnPermission.Id, oldMcnPermission);
				}
			}

			// https://jira.mot-solutions.com/browse/DTPART-232
			System.enqueueJob(new DTSFPART_UpdateContactMCNPermissions(newMcnPermissions, oldMcnPermissions));
		}
	}

	public void afterDelete(Map<Id, SObject> oldItems) {
		List<MCN_Permission__c> oldMcns = (List<MCN_Permission__c>) oldItems.values();
		Set<Id> enterpriseIds = new Set<Id>();
		for (MCN_Permission__c mcn : oldMcns) {
			enterpriseIds.add(mcn.Customer_OR_Partner_Account__c);
		}
		DTSFPART_PermissionUtils.setEnterprisePermissionStatusOnAccounts(enterpriseIds, 'Trigger');
	}

	public void afterUndelete(Map<Id, SObject> oldItems) {}

	private void deleteContactMcnPermissions(Set<Id> mcnPermIds) {
		List<Contact_Permissions__c> cmps = [SELECT Id FROM Contact_Permissions__c WHERE MCN_Permission__c IN :mcnPermIds];
		System.debug(cmps);
		delete cmps;
	}
}