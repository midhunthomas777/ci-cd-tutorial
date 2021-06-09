/**
 * Created by QGBC67 on 11.01.2021.
 */

public with sharing class DTSFPART_ContactMcnPermTriggerHandler implements ITriggerHandler {
    public void beforeInsert(List<SObject> newItems) {
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        if (newItems != null) {
            Map<Id, Contact_Permissions__c> newContactPermissions = (Map<Id, Contact_Permissions__c>) newItems;
            updateContactOnInsert(newContactPermissions);
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if (newItems != null) {
            Map<Id, Contact_Permissions__c> newContactPermissions = (Map<Id, Contact_Permissions__c>) newItems;
            Map<Id, Contact_Permissions__c> oldContactPermissions = (Map<Id, Contact_Permissions__c>) oldItems;
            updateContactOnUpdate(newContactPermissions, oldContactPermissions);
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        if (oldItems != null) {
            Map<Id, Contact_Permissions__c> oldContactPermissions = (Map<Id, Contact_Permissions__c>) oldItems;
            updateContactsProgress(oldContactPermissions, 'In Progress');
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        if (oldItems != null) {
            Map<Id, Contact_Permissions__c> oldContactPermissions = (Map<Id, Contact_Permissions__c>) oldItems;
            updateContactsProgress(oldContactPermissions, 'Trigger');
        }
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
    }

    public Boolean isDisabled() {
        if (TriggerSettings__c.getValues('ContactPermissionsTriggerDisabled').IsActive__c) {
            return true;
        } else {
            return false;
        }
    }

    private void updateContactOnInsert(Map<Id, Contact_Permissions__c> newContactPermissions) {
        if (!DTSFPART_Utils.isAsynchronous()) {
            Set<Id> contactIds = new Set<Id>();
            for (Contact_Permissions__c newContactPermission : newContactPermissions.values()) {
                contactIds.add(newContactPermission.Contact__c);
            }
            if (!contactIds.isEmpty()) {
                changeContactStatus(contactIds);
            }
        }
    }

    private void updateContactOnUpdate(
        Map<Id, Contact_Permissions__c> newContactPermissions,
        Map<Id, Contact_Permissions__c> oldContactPermissions
    ) {
        if (!DTSFPART_Utils.isAsynchronous()) {
            Set<Id> contactIds = new Set<Id>();
            for (Contact_Permissions__c newContactPermission : newContactPermissions.values()) {
                Contact_Permissions__c oldContactPermission = oldContactPermissions.get(newContactPermission.Id);
                if (
                    !DTSFPART_PermissionUtils.permisionsEquals(
                        newContactPermission.Contact_MCN_Permissions__c,
                        oldContactPermission.Contact_MCN_Permissions__c
                    )
                ) {
                    contactIds.add(newContactPermission.Contact__c);
                }
            }
            if (!contactIds.isEmpty()) {
                changeContactStatus(contactIds);
            }
        }
    }

    private void changeContactStatus(Set<Id> ids) {
        Id customerAccRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
        List<Contact> contacts = [
            SELECT Id, Enterprise_Permission_Status__c, Account.Enterprise_Permission_Status__c
            FROM Contact
            WHERE
                Id IN :ids
                AND Account.Partner_Hub_enabled__c = TRUE
                AND (Account.MPE_Program_Status_New__c = 'Active'
                OR Account.RecordTypeId = :customerAccRecordType)
                AND Account.Motorola_Enterprise_ID__c != ''
                AND Delete_Requested__c = FALSE
                AND Status__c = 'Active'
                AND Persona__c != NULL
            FOR UPDATE
        ];
        for (Contact contact : contacts) {
            if (contact.Account.Enterprise_Permission_Status__c == 'Completed') {
                contact.Enterprise_Permission_Status__c = 'Trigger';
            } else {
                contact.Enterprise_Permission_Status__c = 'In Progress';
            }
        }
        update contacts;
    }

    private void updateContactsProgress(Map<Id, Contact_Permissions__c> oldContactPermissions, String status) {
        Id customerAccRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
        Set<Id> impactedContacts = new Set<Id>();
        for (Contact_Permissions__c permissions : oldContactPermissions.values()) {
            impactedContacts.add(permissions.Contact__c);
        }
        List<Contact> contacts = [
            SELECT Id, Enterprise_Permission_Status__c, Account.Enterprise_Permission_Status__c
            FROM Contact
            WHERE
                Id IN :impactedContacts
                AND Account.Partner_Hub_enabled__c = TRUE
                AND (Account.MPE_Program_Status_New__c = 'Active'
                OR Account.RecordTypeId = :customerAccRecordType)
                AND Account.Motorola_Enterprise_ID__c != ''
                AND Delete_Requested__c = FALSE
                AND Status__c = 'Active'
                AND Persona__c != NULL
            FOR UPDATE
        ];
        for (Contact contact : contacts) {
            system.debug(contact);
            if (contact.Account.Enterprise_Permission_Status__c == 'Completed') {
                contact.Enterprise_Permission_Status__c = status;
            } else {
                contact.Enterprise_Permission_Status__c = 'In Progress';
            }
        }
        update contacts;
    }
}