/**
 * Created by QGBC67 on 09.11.2020.
 */

public with sharing class DTSFPART_UpdateMcnPermissions implements Queueable {
    private Map<Id, Technology_Specialization__c> newProgramDetails;
    private Map<Id, Technology_Specialization__c> oldProgramDetails;
    private Map<Id, Contact> newContacts;
    private Map<Id, Contact> oldContacts;
    private Map<Id, DTSFPART_AccountPermissionsWrapper> defaultPartnerMCNPermissionsByAccount;
    private Map<Id, DTSFPART_AccountPermissionsWrapper> defaultMrMCNPermissionsByAccount;


    public DTSFPART_UpdateMcnPermissions(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        this.newProgramDetails = new Map<Id, Technology_Specialization__c>();
        this.oldProgramDetails = new Map<Id, Technology_Specialization__c>();
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
    }

    public DTSFPART_UpdateMcnPermissions(Map<Id, Technology_Specialization__c> newProgramDetails, Map<Id, Technology_Specialization__c> oldProgramDetails,
            Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        this.newProgramDetails = newProgramDetails;
        this.oldProgramDetails = oldProgramDetails;
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
    }

    public void execute(QueueableContext param1) {
        try {
            List<MCN_Permission__c> editedMcnPermissions = new List<MCN_Permission__c>();
            Set<Id> modifiedAccounts = getModifiedAccounts();
            defaultPartnerMCNPermissionsByAccount = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(modifiedAccounts, false);
            defaultMrMCNPermissionsByAccount = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(modifiedAccounts, true);
            Map<Id, List<MCN_Permission__c>> mcnPermissionsByPartner = DTSFPART_PermissionUtils.getMCNPermissionsByCustomerOrPartnerAccount(new List<Id>(modifiedAccounts));
            List<MCN_Permission__c> oldMcnPermissions = new List<MCN_Permission__c>();
            for (List<MCN_Permission__c> permissions : mcnPermissionsByPartner.values()) {
                oldMcnPermissions.addAll(permissions.deepClone(true));
            }
            if (!newProgramDetails.isEmpty()) { // if not triggered by Contact change
                Map<Id, DTSFPART_PermissionDifference> mcnPermissionDifferencesByAccount = DTSFPART_PermissionUtils.calculatePermissionChangeByAccount(newProgramDetails, oldProgramDetails);
                compareDifferenceWithDefaults(mcnPermissionDifferencesByAccount);
                editedMcnPermissions.addAll(updateExistingMcnPermissions(mcnPermissionsByPartner, mcnPermissionDifferencesByAccount));
            }
            editedMcnPermissions.addAll(createMissingMcnPermissions(mcnPermissionsByPartner, modifiedAccounts));
            upsert editedMcnPermissions;
            if (!Test.isRunningTest()) {
                System.enqueueJob(new DTSFPART_UpdateContactMCNPermissions(
                        new Map<Id, MCN_Permission__c>(editedMcnPermissions), new Map<Id, MCN_Permission__c>(oldMcnPermissions),
                        new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts)));
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_UpdateMcnPermissions.execute', '', '', e);
            throw e;
        }
    }

    private Set<Id> getModifiedAccounts() {
        Set<Id> accounts = DTSFPART_Utils.getSetOfIds(newProgramDetails.values(), 'Account__c');
        accounts.addAll(DTSFPART_Utils.getSetOfIds(oldProgramDetails.values(), 'Account__c'));
        accounts.addAll(DTSFPART_Utils.getSetOfIds(newContacts.values(), 'AccountId'));
        accounts.addAll(DTSFPART_Utils.getSetOfIds(oldContacts.values(), 'AccountId'));
        return accounts;
    }

    private List<MCN_Permission__c> createMissingMcnPermissions(Map<Id, List<MCN_Permission__c>> mcnPermissionsByParent, Set<Id> modifiedAccounts) {
        Map<Id, List<Account>> mcnAccountsByParent = DTSFPART_Utils.groupObjectsByIdField( DTSFPART_PermissionUtils.getMcnAccountsByParent(modifiedAccounts), 'ParentId');
        Map<Id, List<Account>> mcnAccountsByAssignedMr = DTSFPART_Utils.groupObjectsByIdField( DTSFPART_PermissionUtils.getMcnAccountsByAssignedMr(modifiedAccounts), 'Assigned_Mr__c');
        DTSFPART_AccountPermissionsWrapper customerPermissions = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsForCustomer();
        List<MCN_Permission__c>newMcnPermissions = new List<MCN_Permission__c>();
        for (Id parentId : mcnAccountsByParent.keySet()) {
            List<MCN_Permission__c> permissions = mcnPermissionsByParent.get(parentId);
            List<Account> parentMcns = mcnAccountsByParent.get(parentId);
            List<Account> mrMcns = mcnAccountsByAssignedMr.get(parentId);
            Integer mcnCount = 0;
            if (parentMcns != null) {
                mcnCount = parentMcns.size();
            }
            if (mrMcns != null) {
                mcnCount += mrMcns.size();
            }
            if (permissions == null || permissions.size() != mcnCount) {
                Map<Id, List<MCN_Permission__c>> permissionsByMcn = (Map<Id, List<MCN_Permission__c>>) DTSFPART_Utils.groupObjectsByIdField(permissions, 'MCN_Account__c');
                if (parentMcns != null) {
                    for (Account mcn : parentMcns) {
                        DTSFPART_AccountPermissionsWrapper accountPermissions = customerPermissions;
                        if( mcn.Parent_Record_Type__c == 'partner')
                        {
                            accountPermissions = defaultPartnerMCNPermissionsByAccount.get(parentId);
                        }
                        if (!permissionsByMcn.containsKey(mcn.Id)) {
                            newMcnPermissions.add(new MCN_Permission__c(
                                    MCN_Account__c = mcn.Id,
                                    MCN_Permissions__c = accountPermissions.mcnPermissions,
                                    Contact_MCN_Permissions__c = accountPermissions.contactMCNPermissions,
                                    Customer_OR_Partner_Account__c = parentId
                            ));
                        }
                    }
                }
                if (mrMcns != null) {
                    for (Account mcn : mrMcns) {
                        if (!permissionsByMcn.containsKey(mcn.Id)) {
                            newMcnPermissions.add(new MCN_Permission__c(
                                    MCN_Account__c = mcn.Id,
                                    MCN_Permissions__c = defaultMrMCNPermissionsByAccount.get(parentId).mcnPermissions,
                                    Contact_MCN_Permissions__c = defaultMrMCNPermissionsByAccount.get(parentId).contactMCNPermissions,
                                    Customer_OR_Partner_Account__c = parentId
                            ));
                        }
                    }
                }
            }
        }
        return newMcnPermissions;
    }

    private List<MCN_Permission__c> updateExistingMcnPermissions(Map<Id, List<MCN_Permission__c>> mcnPermissionsByCustomerOrPartnerAccount,
            Map<Id, DTSFPART_PermissionDifference> mcnPermissionDifferencesByAccount) {
        List<MCN_Permission__c> updatedMcnPermissions = new List<MCN_Permission__c>();
        for (Id accountId : mcnPermissionDifferencesByAccount.keySet()) {
            if (mcnPermissionsByCustomerOrPartnerAccount.containsKey(accountId)) {
                for (MCN_Permission__c mcnPermission : mcnPermissionsByCustomerOrPartnerAccount.get(accountId)) {
                    DTSFPART_PermissionDifference permissionDifference = mcnPermissionDifferencesByAccount.get(accountId);
                    Boolean isMr = DTSFPART_PermissionUtils.mcnPermissionIsMr(mcnPermission);
                    Set<String> mcnPermissions = DTSFPART_PermissionUtils.splitPermissions(mcnPermission.MCN_Permissions__c);
                    Set<String> contactMcnPermissions = DTSFPART_PermissionUtils.splitPermissions(mcnPermission.Contact_MCN_Permissions__c);
                    mcnPermissions.removeAll(permissionDifference.getRemovedMcnPermissions(isMr));
                    contactMcnPermissions.removeAll(permissionDifference.getRemovedContactMCNPermissions(isMr));
                    mcnPermissions.addAll(permissionDifference.getAddedMcnPermissions(isMr));
                    contactMcnPermissions.addAll(permissionDifference.getAddedContactMcnPermissions(isMr));
                    if(!DTSFPART_PermissionUtils.permisionsEquals(mcnPermission.MCN_Permissions__c, mcnPermissions)
                            || !DTSFPART_PermissionUtils.permisionsEquals(mcnPermission.Contact_MCN_Permissions__c, contactMcnPermissions)) {
                        mcnPermission.MCN_Permissions__c = String.join((Iterable<String>) mcnPermissions, ';');
                        mcnPermission.Contact_MCN_Permissions__c = String.join((Iterable<String>) contactMcnPermissions, ';');
                    }
                }

                updatedMcnPermissions.addAll(mcnPermissionsByCustomerOrPartnerAccount.get(accountId));
            }
        }
        return updatedMcnPermissions;
    }

    private void compareDifferenceWithDefaults(Map<Id, DTSFPART_PermissionDifference> permissionDifferencesByAccount) {
        for (Id accountId : permissionDifferencesByAccount.keySet()) {
            DTSFPART_AccountPermissionsWrapper defaultPartnerMCNPermissions = defaultPartnerMCNPermissionsByAccount.get(accountId);
            DTSFPART_AccountPermissionsWrapper defaultMrMCNPermissions = defaultMrMCNPermissionsByAccount.get(accountId);
            DTSFPART_PermissionDifference permissionDifference = permissionDifferencesByAccount.get(accountId);
            permissionDifference.revokeRemovePermissions(
                    DTSFPART_PermissionUtils.splitPermissions(defaultPartnerMCNPermissions.mcnPermissions),
                    DTSFPART_PermissionUtils.splitPermissions(defaultPartnerMCNPermissions.contactMCNPermissions),
                    false);
            permissionDifference.revokeRemovePermissions(
                    DTSFPART_PermissionUtils.splitPermissions(defaultMrMCNPermissions.mcnPermissions),
                    DTSFPART_PermissionUtils.splitPermissions(defaultMrMCNPermissions.contactMCNPermissions),
                    true);
        }
    }
}