/**
 * Created by QGBC67 on 25.11.2020.
 */

public with sharing class DTSFPART_SaveContactMcnPermissions implements Queueable {
    private static final Set<String> personaForMR = new Set<String>{ 'Admin', 'OwnerExecutive' };
    private Map<Id, Contact> affectedContacts;
    private Map<Id, List<MCN_Permission__c>> mcnPermissionsByAccount;
    private Map<Id, List<MCN_Permission__c>> mrMcnPermissionsByAccount;
    private Map<Id, List<MCN_Permission__c>> mrMcnPermissionsBySalesPerson;
    private Map<Id, Set<String>> addedPermissionsByMcn;
    private Map<Id, Set<String>> removedPermissionsByMcn;
    private Map<Id, Contact> newContacts;
    private Map<Id, Contact> oldContacts;
    private DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference;
    private Integer maxBatchSize = 2000;

    private Map<Id, String> accountCountries;

    public DTSFPART_SaveContactMcnPermissions(
        Map<Id, Contact> affectedContacts,
        Map<Id, List<MCN_Permission__c>> mcnPermissionsByAccount,
        Map<Id, List<MCN_Permission__c>> mrMcnPermissionsByAccount,
        Map<Id, List<MCN_Permission__c>> mrMcnPermissionsBySalesPerson,
        Map<Id, Set<String>> addedPermissionsByMcn,
        Map<Id, Set<String>> removedPermissionsByMcn,
        Map<Id, Contact> newContacts,
        Map<Id, Contact> oldContacts,
        DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference
    ) {
        this.affectedContacts = affectedContacts;
        this.mcnPermissionsByAccount = mcnPermissionsByAccount;
        this.mrMcnPermissionsByAccount = mrMcnPermissionsByAccount;
        this.mrMcnPermissionsBySalesPerson = mrMcnPermissionsBySalesPerson;
        this.addedPermissionsByMcn = addedPermissionsByMcn;
        this.removedPermissionsByMcn = removedPermissionsByMcn;
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
        this.contactMcnPermRemovalReference = contactMcnPermRemovalReference;
        this.accountCountries = DTSFPART_PermissionUtils.populateCountryMap(affectedContacts);
    }

    public void execute(QueueableContext context) {
        try {
            Map<Id, Contact> thisChunk = selectContactsForUpdate();
            Set<Id> impactedContacts = new Set<Id>();

            Map<Id, List<Contact_Permissions__c>> contactMcnPermissionsByContact = getContactMcnPermissionsByContact(thisChunk.keySet());

            List<Contact_Permissions__c> addedContactMcnPermissions = new List<Contact_Permissions__c>();
            List<Contact_Permissions__c> removedContactMcnPermissions = new List<Contact_Permissions__c>();
            for (Contact contact : thisChunk.values()) {
                Set<String> addedPermissions = new Set<String>();
                Set<String> removedPermissions = new Set<String>();
                if (newContacts.containsKey(contact.Id)) {
                    impactedContacts.add(contact.Id);
                    addedPermissions.addAll(DTSFPART_PermissionUtils.splitPermissions(contact.Contact_MCN_Permissions__c));

                    if (oldContacts.containsKey(contact.Id)) {
                        Contact oldContact = oldContacts.get(contact.Id);
                        Set<String> oldPermissions = DTSFPART_PermissionUtils.splitPermissions(oldContact.Contact_MCN_Permissions__c);
                        removedPermissions.addAll(oldPermissions);
                        removedPermissions.removeAll(addedPermissions);
                        addedPermissions.removeAll(oldPermissions);
                    }
                }
                List<Id> mcnPermissionIdsWithContactMcnPerm = new List<Id>();
                Map<Id, MCN_Permission__c> contactMrMCNPermissions = new Map<Id, MCN_Permission__c>();
                if (mrMcnPermissionsBySalesPerson.containsKey(contact.Id)) {
                    contactMrMCNPermissions = new Map<Id, MCN_Permission__c>(mrMcnPermissionsBySalesPerson.get(contact.Id));
                }
                if (contactMcnPermissionsByContact != null && contactMcnPermissionsByContact.containsKey(contact.Id)) {
                    for (Contact_Permissions__c contactMcnPermission : contactMcnPermissionsByContact.get(contact.Id)) {
                        if (
                            (newContacts.containsKey(contact.Id) && oldContacts.containsKey(contact.Id)) &&
                            (personaForMR.contains(oldContacts.get(contact.Id).Persona__c) &&
                            !personaForMR.contains(newContacts.get(contact.Id).Persona__c) &&
                            !contactMrMCNPermissions.containsKey(contactMcnPermission.MCN_Permission__c))
                        ) {
                            removedContactMcnPermissions.add(contactMcnPermission);
                        } else if (contactMcnPermRemovalReference.shouldExist(contactMcnPermission)) {
                            mcnPermissionIdsWithContactMcnPerm.add(contactMcnPermission.MCN_Permission__c);
                            Set<String> contactMcnPermissionPermissions = DTSFPART_PermissionUtils.splitPermissions(
                                contactMcnPermission.Contact_MCN_Permissions__c
                            );
                            String mcnPermissions = contactMcnPermission.MCN_Permission__r.Contact_MCN_Permissions__c;
                            contactMcnPermissionPermissions.removeAll(removedPermissions);
                            contactMcnPermissionPermissions.addAll(DTSFPART_PermissionUtils.calculateIntersection(mcnPermissions, addedPermissions));
                            if (removedPermissionsByMcn.containsKey(contactMcnPermission.MCN_Account__c)) {
                                contactMcnPermissionPermissions.removeAll(removedPermissionsByMcn.get(contactMcnPermission.MCN_Account__c));
                            }
                            if (addedPermissionsByMcn.containsKey(contactMcnPermission.MCN_Account__c)) {
                                contactMcnPermissionPermissions.addAll(
                                    DTSFPART_PermissionUtils.calculateIntersection(
                                        contact.Contact_MCN_Permissions__c,
                                        addedPermissionsByMcn.get(contactMcnPermission.MCN_Account__c)
                                    )
                                );
                            }

                            DTSFPART_PermissionUtils.removeCanadaPermissions(contactMcnPermissionPermissions, accountCountries.get(contact.AccountId));

                            if (!DTSFPART_PermissionUtils.permisionsEquals(contactMcnPermission.Contact_MCN_Permissions__c, contactMcnPermissionPermissions)) {
                                contactMcnPermission.Contact_MCN_Permissions__c = String.join((Iterable<String>) contactMcnPermissionPermissions, ';');
                                addedContactMcnPermissions.add(contactMcnPermission);
                                impactedContacts.add(contact.Id);
                            }
                        } else {
                            removedContactMcnPermissions.add(contactMcnPermission);
                        }
                    }
                }

                List<MCN_Permission__c> relevantMcnPermissions = new List<MCN_Permission__c>();
                if (mcnPermissionsByAccount != null && mcnPermissionsByAccount.containsKey(contact.AccountId)) {
                    relevantMcnPermissions.addAll(mcnPermissionsByAccount.get(contact.AccountId));
                }
                if (mrMcnPermissionsByAccount != null && mrMcnPermissionsByAccount.containsKey(contact.AccountId)) {
                    if (personaForMR.contains(contact.Persona__c)) {
                        relevantMcnPermissions.addAll(mrMcnPermissionsByAccount.get(contact.AccountId));
                    } else if (mrMcnPermissionsBySalesPerson.containsKey(contact.Id)) {
                        relevantMcnPermissions.addAll(mrMcnPermissionsBySalesPerson.get(contact.Id));
                    }
                }
                for (MCN_Permission__c mcnPermission : relevantMcnPermissions) {
                    if (!mcnPermissionIdsWithContactMcnPerm.contains(mcnPermission.Id) && mcnPermission.Customer_OR_Partner_Account__c == contact.AccountId) {
                        addedContactMcnPermissions.add(createPermission(mcnPermission, contact));
                        impactedContacts.add(contact.Id);
                    }
                }
            }

            delete removedContactMcnPermissions;
            upsert addedContactMcnPermissions;
            markContactsInProgress(impactedContacts);
            if (!affectedContacts.isEmpty()) {
                System.enqueueJob(
                    new DTSFPART_SaveContactMcnPermissions(
                        affectedContacts,
                        mcnPermissionsByAccount,
                        mrMcnPermissionsByAccount,
                        mrMcnPermissionsBySalesPerson,
                        addedPermissionsByMcn,
                        removedPermissionsByMcn,
                        newContacts,
                        oldContacts,
                        contactMcnPermRemovalReference
                    )
                );
            } else {
                updateStatuses();
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_SaveContactMcnPermissions.execute', '', '', e);
            throw e;
        }
    }

    public static Map<Id, List<Contact_Permissions__c>> getContactMcnPermissionsByContact(Set<Id> contactIds) {
        List<Contact_Permissions__c> contactMcnPermissions = [
            SELECT
                Id,
                MCN_Account__c,
                Parent_Account__c,
                Contact__c,
                Contact_MCN_Permissions__c,
                MCN_Permission__r.MCN_Account__r.ParentId,
                MCN_Permission__r.MCN_Account__r.Assigned_MR__c,
                MCN_Permission__r.Contact_MCN_Permissions__c,
                Contact__r.Contact_MCN_Permissions__c
            FROM Contact_Permissions__c
            WHERE Contact__c IN :contactIds
        ];
        Map<Id, List<Contact_Permissions__c>> contactMcnPermissionsByContact = new Map<Id, List<Contact_Permissions__c>>();
        for (Contact_Permissions__c contactMcnPermission : contactMcnPermissions) {
            if (!contactMcnPermissionsByContact.containsKey(contactMcnPermission.Contact__c)) {
                contactMcnPermissionsByContact.put(contactMcnPermission.Contact__c, new List<Contact_Permissions__c>());
            }
            contactMcnPermissionsByContact.get(contactMcnPermission.Contact__c).add(contactMcnPermission);
        }
        return contactMcnPermissionsByContact;
    }

    private Contact_Permissions__c createPermission(MCN_Permission__c mcnPermission, Contact contact) {
        Set<String> permissionIntersection = DTSFPART_PermissionUtils.calculateIntersection(
            mcnPermission.Contact_MCN_Permissions__c,
            contact.Contact_MCN_Permissions__c
        );

        DTSFPART_PermissionUtils.removeCanadaPermissions(permissionIntersection, accountCountries.get(contact.AccountId));

        return new Contact_Permissions__c(
            Contact__c = contact.Id,
            Contact_MCN_Permissions__c = String.join((Iterable<String>) permissionIntersection, ';'),
            MCN_Account__c = mcnPermission.MCN_Account__c,
            MCN_Permission__c = mcnPermission.Id,
            Parent_Account__c = mcnPermission.Customer_OR_Partner_Account__c
        );
    }

    private Map<Id, Contact> selectContactsForUpdate() {
        Map<Id, Contact> thisChunk = new Map<Id, Contact>();
        Map<Id, Contact> nextChunk = new Map<Id, Contact>();
        Integer batchSize = 0;
        for (Contact contact : affectedContacts.values()) {
            if (mcnPermissionsByAccount.containsKey(contact.AccountId)) {
                batchSize += mcnPermissionsByAccount.get(contact.AccountId).size();
            }
            if (personaForMR.contains(contact.Persona__c)) {
                if (mrMcnPermissionsByAccount.containsKey(contact.AccountId)) {
                    batchSize += mrMcnPermissionsByAccount.get(contact.AccountId).size();
                }
            } else if (mrMcnPermissionsBySalesPerson.containsKey(contact.Id)) {
                batchSize += mrMcnPermissionsBySalesPerson.get(contact.Id).size();
            }
            if (batchSize <= maxBatchSize) {
                thisChunk.put(contact.Id, contact);
            } else {
                nextChunk.put(contact.Id, contact);
            }
        }
        if (thisChunk.isEmpty() && !nextChunk.isEmpty()) {
            Contact firstContact = nextChunk.remove(new List<Id>(nextChunk.keySet())[0]);
            thisChunk.put(firstContact.Id, firstContact);
        }

        affectedContacts = nextChunk;
        return thisChunk;
    }

    private void updateStatuses() {
        Set<Id> enterpriseIds = new Set<Id>(mcnPermissionsByAccount.keySet());
        enterpriseIds.addAll(mrMcnPermissionsByAccount.keySet());
        List<Account> updatedAccounts = new List<Account>();
        Set<Id> updatedContacts = new Set<Id>();
        for (Account account : [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Id IN :enterpriseIds]) {
            if (account.Enterprise_Permission_Status__c != 'Completed') {
                account.Enterprise_Permission_Status__c = 'Trigger';
                updatedAccounts.add(account);
            } else {
                updatedContacts.add(account.Id);
            }
        }
        if (!updatedAccounts.isEmpty()) {
            update updatedAccounts;
        }
        if (!updatedContacts.isEmpty()) {
            List<Contact> contacts = [
                SELECT Id, Status__c, Enterprise_Permission_Status__c
                FROM Contact
                WHERE
                    AccountId IN :updatedContacts
                    AND Enterprise_Permission_Status__c = 'In Progress'
                    AND Delete_Requested__c = FALSE
                    AND Status__c != 'Inactive'
                    AND Status__c != 'Deactivation Requested'
                    AND Status__c != NULL
                    AND Persona__c != NULL
                FOR UPDATE
            ];
            for (Contact contact : contacts) {
                if (contact.Status__c == 'Active') {
                    contact.Enterprise_Permission_Status__c = 'Trigger';
                } else if (contact.Status__c == 'Registration Completed') {
                    contact.Enterprise_Permission_Status__c = 'Completed';
                } else if (contact.Status__c == 'Invited') {
                    if (newContacts.containsKey(contact.Id) && !oldContacts.containsKey(contact.Id)) {
                        contact.Enterprise_Permission_Status__c = 'Trigger';
                    } else {
                        contact.Enterprise_Permission_Status__c = 'Completed';
                    }
                }
            }
            update contacts;
        }
    }

    private void markContactsInProgress(Set<Id> contactIds) {
        List<Contact> contacts = [
            SELECT Id, Enterprise_Permission_Status__c
            FROM Contact
            WHERE
                Id IN :contactIds
                AND Delete_Requested__c = FALSE
                AND Status__c != 'Inactive'
                AND Status__c != 'Deactivation Requested'
                AND Status__c != NULL
                AND Persona__c != NULL
            FOR UPDATE
        ];
        for (Contact contact : contacts) {
            contact.Enterprise_Permission_Status__c = 'In Progress';
        }
        update contacts;
    }
}