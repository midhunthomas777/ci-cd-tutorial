public with sharing class DTSFPART_ContactPermissionService {
    public static void create(Map<Id, Set<Id>> mcnPermissionsToContacts) {
        Map<Id, Contact> contacts = prepareContactData(mcnPermissionsToContacts.values());
        Map<Id, MCN_Permission__c> mcnPermissionByAccount = prepareMcnPermissionByAccount(
            mcnPermissionsToContacts.keySet(),
            getContactAccountIds(contacts.values())
        );
        Map<Id, Map<Id, Contact_Permissions__c>> existingPermByContactByMcn = getExistingContactPermissionsGrouped(
            contacts.keySet(),
            mcnPermissionsToContacts.keySet()
        );
        List<Contact_Permissions__c> contactPermissions = new List<Contact_Permissions__c>();
        for (Id mcnId : mcnPermissionsToContacts.keySet()) {
            Map<Id, Contact_Permissions__c> permissionsByContact = existingPermByContactByMcn.get(mcnId);
            for (Id contactId : mcnPermissionsToContacts.get(mcnId)) {
                if (mcnPermissionByAccount.containsKey(mcnId)) {
                    Set<String> permissionIntersection = DTSFPART_PermissionUtils.calculateIntersection(
                        mcnPermissionByAccount.get(mcnId).Contact_MCN_Permissions__c,
                        contacts.get(contactId).Contact_MCN_Permissions__c
                    );

                    DTSFPART_PermissionUtils.removeCanadaPermissions(permissionIntersection, contacts.get(contactId).Account.BillingCountry);

                    Contact_Permissions__c newPermission = new Contact_Permissions__c(
                        Contact__c = contactId,
                        Contact_MCN_Permissions__c = String.join((Iterable<String>) permissionIntersection, ';'),
                        MCN_Account__c = mcnId,
                        MCN_Permission__c = mcnPermissionByAccount.get(mcnId).Id,
                        Parent_Account__c = mcnPermissionByAccount.get(mcnId).Customer_OR_Partner_Account__c
                    );
                    if (permissionsByContact != null && permissionsByContact.containsKey(contactId)) {
                        newPermission.Id = permissionsByContact.get(contactId).Id;
                    }
                    contactPermissions.add(newPermission);
                }
            }
        }

        upsert contactPermissions;
    }

    public static void removeMRPermissions(Map<Id, Set<Id>> mcnPermissionsToContacts) {
        Map<Id, Contact> contacts = prepareContactData(mcnPermissionsToContacts.values());
        Set<Id> contactIdsToRemove = getContactsWithoutMRPersona(contacts.values());
        List<Contact_Permissions__c> contactPermissions = getExistingContactPermissions(contactIdsToRemove, mcnPermissionsToContacts.keySet());

        delete contactPermissions;
    }

    private static List<Contact_Permissions__c> getExistingContactPermissions(Set<Id> contactIds, Set<Id> mcnAccountIds) {
        return [SELECT Id FROM Contact_Permissions__c WHERE Contact__c IN :contactIds AND MCN_Account__c IN :mcnAccountIds];
    }

    private static Map<Id, Map<Id, Contact_Permissions__c>> getExistingContactPermissionsGrouped(Set<Id> contactIds, Set<Id> mcnAccountIds) {
        Map<Id, Map<Id, Contact_Permissions__c>> groupedPermissions = new Map<Id, Map<Id, Contact_Permissions__c>>();
        for (Contact_Permissions__c perm : [
            SELECT Id, Contact__c, MCN_Account__c
            FROM Contact_Permissions__c
            WHERE Contact__c IN :contactIds AND MCN_Account__c IN :mcnAccountIds
        ]) {
            if (!groupedPermissions.containsKey(perm.MCN_Account__c)) {
                groupedPermissions.put(perm.MCN_Account__c, new Map<Id, Contact_Permissions__c>());
            }
            groupedPermissions.get(perm.MCN_Account__c).put(perm.Contact__c, perm);
        }
        return groupedPermissions;
    }

    private static Set<Id> getContactsWithoutMRPersona(List<Contact> contacts) {
        Set<Id> nonMRIds = new Set<Id>();

        for (Contact contact : contacts) {
            if (contact.Persona__c != 'Admin' && contact.Persona__c != 'OwnerExecutive') {
                nonMRIds.add(contact.Id);
            }
        }

        return nonMRIds;
    }

    private static Map<Id, MCN_Permission__c> prepareMcnPermissionByAccount(Set<Id> mcnAccountIds, Set<Id> contactAccountIds) {
        Map<Id, MCN_Permission__c> mcnPermissionsByAccount = new Map<Id, MCN_Permission__c>();

        for (MCN_Permission__c mcnPermission : [
            SELECT Id, MCN_Account__c, Contact_MCN_Permissions__c, Customer_OR_Partner_Account__c
            FROM MCN_Permission__c
            WHERE MCN_Account__c IN :mcnAccountIds AND Customer_OR_Partner_Account__c IN :contactAccountIds
        ]) {
            mcnPermissionsByAccount.put(mcnPermission.MCN_Account__c, mcnPermission);
        }

        return mcnPermissionsByAccount;
    }

    private static Map<Id, Contact> prepareContactData(List<Set<Id>> contactIds) {
        return new Map<Id, Contact>(
            [
                SELECT Id, AccountId, Persona__c, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c, Account.BillingCountry
                FROM Contact
                WHERE Id IN :getContactIds(contactIds)
            ]
        );
    }

    private static Set<Id> getContactAccountIds(List<Contact> contacts) {
        Set<Id> result = new Set<Id>();

        for (Contact contact : contacts) {
            result.add(contact.AccountId);
        }

        return result;
    }

    private static Set<Id> getContactIds(List<Set<Id>> contactIds) {
        Set<Id> result = new Set<Id>();

        for (Set<Id> ids : contactIds) {
            result.addAll(ids);
        }

        return result;
    }
}