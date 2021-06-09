/**
 * @author: WGVR43
 * @date: 26.08.2020
 * @group: DTSFPART
 * @description:
 */

public with sharing class DTSFPART_UpdateContactMCNPermissions implements Queueable {
    private Map<Id, MCN_Permission__c> newMcnPermissions;
    private Map<Id, MCN_Permission__c> oldMcnPermissions;
    private Map<Id, Contact> newContacts;
    private Map<Id, Contact> oldContacts;
    private Set<Id> mcnParentAccountsIds;
    private Set<Id> contactParentAccountsIds;
    public Map<Id, Set<String>> addedPermissionsByMcn;
    public Map<Id, Set<String>> removedPermissionsByMcn;
    public DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference;
    public Map<Id, Contact> affectedContacts;
    public Map<Id, List<MCN_Permission__c>> mrMcnPermissionsBySalesPerson;
    public Map<Id, List<MCN_Permission__c>> mrPermissionsByAccount;
    public Map<Id, List<MCN_Permission__c>> mcnPermissionsByAccount;

    public DTSFPART_UpdateContactMCNPermissions(Map<Id, MCN_Permission__c> newMcnPermissions, Map<Id, MCN_Permission__c> oldMcnPermissions, DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference) {
        this.newMcnPermissions = newMcnPermissions;
        this.oldMcnPermissions = oldMcnPermissions;
        this.newContacts = new Map<Id, Contact>();
        this.oldContacts = new Map<Id, Contact>();
        this.contactMcnPermRemovalReference = contactMcnPermRemovalReference;
        getParentAccountsIds();
    }

    public DTSFPART_UpdateContactMCNPermissions(Map<Id, MCN_Permission__c> newMcnPermissions, Map<Id, MCN_Permission__c> oldMcnPermissions) {
        this.newMcnPermissions = newMcnPermissions;
        this.oldMcnPermissions = oldMcnPermissions;
        this.newContacts = new Map<Id, Contact>();
        this.oldContacts = new Map<Id, Contact>();
        this.contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        getParentAccountsIds();
    }

    public DTSFPART_UpdateContactMCNPermissions(Map<Id, MCN_Permission__c> newMcnPermissions, Map<Id, MCN_Permission__c> oldMcnPermissions, Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        this.newMcnPermissions = newMcnPermissions;
        this.oldMcnPermissions = oldMcnPermissions;
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
        this.contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        getParentAccountsIds();
    }

    public void execute(QueueableContext context) {
        try {
            calculateMcnPermissionsDelta();
            affectedContacts = getAllAffectedContacts();
            mcnPermissionsByAccount = getMcnPermissionsByParent();
            mrPermissionsByAccount = getMcnPermissionsByAssignedMr();
            mrMcnPermissionsBySalesPerson = groupMcnPermissionBySalesPerson(mrPermissionsByAccount);
            if (!Test.isRunningTest()) {
                System.enqueueJob(new DTSFPART_SaveContactMcnPermissions(
                        affectedContacts, mcnPermissionsByAccount, mrPermissionsByAccount, mrMcnPermissionsBySalesPerson,
                        addedPermissionsByMcn, removedPermissionsByMcn, newContacts, oldContacts, contactMcnPermRemovalReference));
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_UpdateContactMCNPermissions.execute', '', '', e);
            throw e;
        }
    }

    private Map<Id, List<MCN_Permission__c>> getMcnPermissionsByParent() {
        Set<Id> enterpriseIds = new Set<Id>(mcnParentAccountsIds);
        enterpriseIds.addAll(contactParentAccountsIds);
        List<MCN_Permission__c> mcnPermissions = [
                SELECT Id, Customer_OR_Partner_Account__c, MCN_Account__c, MCN_Account__r.ParentId,
                        MCN_Permissions__c, Contact_MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE MCN_Account__r.ParentId IN :enterpriseIds
        ];
        return DTSFPART_Utils.groupObjectsByIdField(mcnPermissions, 'Customer_OR_Partner_Account__c');
    }
    private Map<Id, List<MCN_Permission__c>> getMcnPermissionsByAssignedMr() {
        Set<Id> enterpriseIds = new Set<Id>(mcnParentAccountsIds);
        enterpriseIds.addAll(contactParentAccountsIds);
        List<MCN_Permission__c> mcnPermissions = [
                SELECT Id, Customer_OR_Partner_Account__c, MCN_Account__c, MCN_Account__r.ParentId,
                        MCN_Permissions__c, Contact_MCN_Permissions__c, MCN_Account__r.Assigned_MR_Sales_Person__c
                FROM MCN_Permission__c
                WHERE MCN_Account__r.Assigned_MR__c IN :enterpriseIds
        ];
        return DTSFPART_Utils.groupObjectsByIdField(mcnPermissions, 'Customer_OR_Partner_Account__c');
    }

    private Map<Id, List<MCN_Permission__c>> groupMcnPermissionBySalesPerson(Map<Id, List<MCN_Permission__c>> mcnPermissionsByAccount) {
        Map<Id, List<MCN_Permission__c>> mcnPermissionsBySalesPerson = new Map<Id, List<MCN_Permission__c>>();
        for(List<MCN_Permission__c> mcnPermissions : mcnPermissionsByAccount.values()) {
            for(MCN_Permission__c mcnPermission : mcnPermissions) {
                if(mcnPermission.MCN_Account__r.Assigned_MR_Sales_Person__c != null) {
                    Id salesPersonId = mcnPermission.MCN_Account__r.Assigned_MR_Sales_Person__c;
                    if(!mcnPermissionsBySalesPerson.containsKey(salesPersonId)) {
                        mcnPermissionsBySalesPerson.put(salesPersonId, new List<MCN_Permission__c>());
                    }
                    mcnPermissionsBySalesPerson.get(salesPersonId).add(mcnPermission);
                }
            }
        }
        return mcnPermissionsBySalesPerson;
    }

    private Map<Id, Contact> getAllAffectedContacts() {
        Map<Id, Contact> affectedContacts = new Map<Id, Contact>([
                SELECT Id, AccountId, Contact_MCN_Permissions__c, Persona__c
                FROM Contact
                WHERE AccountId IN :mcnParentAccountsIds AND Delete_Requested__c = FALSE AND Status__c != 'Inactive'
                AND Status__c != 'Deactivation Requested' AND Status__c != NULL AND Persona__c != NULL
        ]);
        affectedContacts.putAll(newContacts);
        return affectedContacts;
    }

    private void getParentAccountsIds() {
        mcnParentAccountsIds = new Set<Id>();
        for (Id mcnPermissionId : newMcnPermissions.keySet()) {
            mcnParentAccountsIds.add(newMcnPermissions.get(mcnPermissionId).Customer_OR_Partner_Account__c);
        }
        contactParentAccountsIds = new Set<Id>();
        for (Id contactId : newContacts.keySet()) {
            contactParentAccountsIds.add(newContacts.get(contactId).AccountId);
        }
    }

    private void calculateMcnPermissionsDelta() {
        addedPermissionsByMcn = new Map<Id, Set<String>>();
        removedPermissionsByMcn = new Map<Id, Set<String>>();
        for (MCN_Permission__c newMcnPermission : newMcnPermissions.values()) {
            Set<String> addedPermissions = DTSFPART_PermissionUtils.splitPermissions(newMcnPermission.Contact_MCN_Permissions__c);
            Set<String> removedPermissions = new Set<String>();
            if (oldMcnPermissions.containsKey(newMcnPermission.Id)) {
                MCN_Permission__c oldMcnPermission = oldMcnPermissions.get(newMcnPermission.Id);
                Set<String> oldPermissions = DTSFPART_PermissionUtils.splitPermissions(oldMcnPermission.Contact_MCN_Permissions__c);
                removedPermissions.addAll(oldPermissions);
                removedPermissions.removeAll(addedPermissions);
                addedPermissions.removeAll(oldPermissions);
            }
            addedPermissionsByMcn.put(newMcnPermission.MCN_Account__c, addedPermissions);
            removedPermissionsByMcn.put(newMcnPermission.MCN_Account__c, removedPermissions);
        }
    }
}