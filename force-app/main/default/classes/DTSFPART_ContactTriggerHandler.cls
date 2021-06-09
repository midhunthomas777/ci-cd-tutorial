/**
* @author       Pawel Wozniak
* @created      2020-07-21
* @updated      2021-01-27
* @description Trigger handler on COntacts for DTSFPART project
*/
public with sharing class DTSFPART_ContactTriggerHandler implements ITriggerHandler {

    private static Id partnerContactRT = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
    private static Id standardContactRT = DTSFPART_Utils.getRecordTypeId('Contact', 'EMS_Standard_Contact');

    public static Boolean TriggerDisabled = false;
    
    public Boolean isDisabled() {
        return TriggerDisabled || new DTSFPART_TriggerConfigurationService('ContactTrigger','DTSFPART_ContactTriggerHandler').isTriggerLogicDisabled();
    }

    /* Before */
    public void beforeInsert(List<SObject> newItems) {
        List<Contact> newContacts = (List<Contact>) newItems;
        setHubDefaultPermissions_OnInsert(newContacts);     // https://jira.mot-solutions.com/browse/DTPART-231
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        List<Contact> newContacts = (List<Contact>) newItems.values();
        Map<Id, Contact> oldContacts = (Map<Id, Contact>) oldItems;

        cleanC360errors(newContacts, oldContacts);
        handleC360ErrorResponse(newContacts, oldContacts);  // https://jira.mot-solutions.com/browse/DTPART-1423
        setHubDefaultPermissions_OnUpdate(newContacts, oldContacts);     // https://jira.mot-solutions.com/browse/DTPART-231
        handlePermissionChange((Map<Id, Contact>) newItems, oldContacts); // https://jira.mot-solutions.com/browse/DTPART-355
    }

    private void cleanC360errors(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        for(Contact newContact : newContacts) {
            Contact oldContact = oldContacts.get(newContact.Id);
            if(newContact.Enterprise_Permission_Status__c == DTSFPART_CommonStrings.IN_PROGRESS
                    && oldContact.Enterprise_Permission_Status__c != DTSFPART_CommonStrings.IN_PROGRESS) {
                newContact.C360_Response__c = DTSFPART_CommonStrings.EMPTY_STRING;
            }
        }
    }

    private void handleC360ErrorResponse(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        for(Contact newContact : newContacts) {
            Contact oldContact = oldContacts.get(newContact.Id);
            String newStatus = newContact.Enterprise_Permission_Status__c;
            String newResponse = newContact.C360_Response__c;
            String oldResponse = oldContact.C360_Response__c;

            if(DTSFPART_Utils.hasReceivedErrorFromC360(newResponse, oldResponse, newStatus)) {
                newContact.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.ERROR;
            }
        }
    }

    /* After */
    public void afterInsert(Map<Id, SObject> newItems) {
        // Call default permissions
        // @Batch for Defualt Permisison DTSFPART_PermissionUtils.setPartnerDefaultPermissions(newItems);
        // Update Enterprise_Permission_Status__c = 'Completed'
        if (newItems != null) {
            Map<Id, Contact> newContacts = (Map<Id, Contact>) newItems;
            Map<Id, Id> contactIdWithMPEId = new Map<Id, Id>();
            for (Contact eachContact : newContacts.values()) {
                if ((eachContact.RecordTypeId == partnerContactRT || eachContact.RecordTypeId == standardContactRT) && String.isNotEmpty(eachContact.MPE_ContactId__c)) {
                    contactIdWithMPEId.put(eachContact.Id, eachContact.MPE_ContactId__c);
                }
            }
            if (!contactIdWithMPEId.isEmpty()) {
                DTSFPART_PerformApprovalAction.deleteMPEContactAndSendEmail(contactIdWithMPEId);
            }
            System.enqueueJob(new DTSFPART_UpdateMcnPermissions(newContacts, new Map<id, Contact>()));
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if (newItems != null && oldItems != null) {
            Map<Id, Contact> mapNewContact = (Map<Id, Contact>) newItems;
            Map<Id, Contact> mapOldContact = (Map<Id, Contact>) oldItems;

            execute_UserCreationJob(mapNewContact, mapOldContact); // https://jira.mot-solutions.com/browse/DTPART-270
            refreshPermissions(mapNewContact, mapOldContact); // https://jira.mot-solutions.com/browse/DTPART-245
            send_RegistrationNotification(mapNewContact, mapOldContact); // https://jira.mot-solutions.com/browse/DTPART-257
            syncTimeoutNotification(mapNewContact, mapOldContact); // https://jira.mot-solutions.com/browse/DTPART-942
        }
    }

    private void refreshPermissions(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        if (!DTSFPART_RunOnce.hasAlreadyfired('DTSFPART_ContactTriggerHandler.refreshPermissions')
                && !DTSFPART_Utils.isAsynchronous()) {
            DTSFPART_RunOnce.setAlreadyfired('DTSFPART_ContactTriggerHandler.refreshPermissions');
            Map<Id, Contact> editedNewContact = new Map<Id, Contact>();
            Map<Id, Contact> editedOldContact = new Map<Id, Contact>();
            for (Contact newContact : newContacts.values()) {
                Contact oldContact = oldContacts.get(newContact.Id);
                if (
                    (String.isBlank(newContact.Contact_MCN_Permissions__c) &&
                    String.isNotBlank(oldContact.Contact_MCN_Permissions__c)) ||
                    ((newContact.Contact_MCN_Permissions__c != null &&
                    !newContact.Contact_MCN_Permissions__c.equals(oldContact.Contact_MCN_Permissions__c)) ||
                    newContact.Account != oldContact.Account) ||
                    (newContact.Status__c != null &&
                    newContact.Status__c.equals('Active') &&
                    (oldContact.Status__c == null ||
                    (!oldContact.Status__c.equals('Reg. completed') && !oldContact.Status__c.equals('Active'))))
                ) {
                    editedNewContact.put(newContact.Id, newContact);
                    editedOldContact.put(newContact.Id, oldContact);
                }
            }
            if (!editedNewContact.isEmpty()) {
                System.enqueueJob(new DTSFPART_UpdateMcnPermissions(editedNewContact, editedOldContact));
            }
        }
    }

    /* Delete */
    public void beforeDelete(Map<Id, SObject> oldItems) {
        deleteMcnPermissions(oldItems.keySet());
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
    }

    // Trigger Logic
    private void handlePermissionChange(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        for (Contact newContact : newContacts.values()) {
            Contact oldContact = oldContacts.get(newContact.Id);
            if (newContact.Contact_MCN_Permissions__c != oldContact.Contact_MCN_Permissions__c
                    && (newContact.Enterprise_Permission_Status__c != null ||
                    newContact.Enterprise_Permission_Status__c == 'Completed')) {
                newContact.Enterprise_Permission_Status__c = 'In Progress';
            }
        }
    }

    private void setHubDefaultPermissions_OnInsert(List<Contact> newContacts) {
        List<Contact> contactsForUpdate = new List<Contact> ();

        for (Contact oneContact : newContacts) {
            // DTPART-99 skip this calulation when value was set in LWC
            if (oneContact.Skip_Persona_Based_Perm_Calculation__c == true) {
                oneContact.Skip_Persona_Based_Perm_Calculation__c = false;
                continue;
            }
            if ( (oneContact.RecordTypeId == partnerContactRT || oneContact.RecordTypeId == standardContactRT)  && String.isNotBlank(oneContact.Persona__c)) {
                contactsForUpdate.add(oneContact);
                oneContact.Enterprise_Permission_Status__c = 'In Progress';
                oneContact.Email = oneContact.Email.toLowercase();
                oneContact.LDAP_Login__c = oneContact.Email;
            }
        }
        if(!contactsForUpdate.isEmpty()) {
            DTSFPART_PermissionUtils.setHubDefaultPermissions(contactsForUpdate);
        }
    }

    private void setHubDefaultPermissions_OnUpdate(List<Contact> newContacts, Map<Id, Contact> oldContacts) {
        List<Contact> contactsForUpdate = new List<Contact> ();

        for (Contact oneContact : newContacts) {
            // DTPART-99 skip this calulation when value was set in LWC
            if (oneContact.Skip_Persona_Based_Perm_Calculation__c == true) {
                oneContact.Skip_Persona_Based_Perm_Calculation__c = false;
                continue;
            }
            if ((oneContact.RecordTypeId == partnerContactRT || oneContact.RecordTypeId == standardContactRT) && oneContact.Persona__c != oldContacts.get(oneContact.Id).Persona__c) {
                contactsForUpdate.add(oneContact);
            }
        }
        if(!contactsForUpdate.isEmpty()) {
            DTSFPART_PermissionUtils.setHubDefaultPermissions(contactsForUpdate);
        }
    }

    private void execute_UserCreationJob(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        if (!DTSFPART_RunOnce.hasAlreadyfired('DTSFPART_ContactTriggerHandler.execute_UserCreationJob')) {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            for (Contact eachContact : newContacts.values()) {
                if ('Completed'.equals(eachContact.Enterprise_Permission_Status__c) &&
                        'Registration Completed'.equals(eachContact.Status__c) &&
                        String.isNotEmpty(eachContact.Persona__c)) {
                    contactIds.add(eachContact.Id);
                    accountIds.add(eachContact.AccountId);
                }
            }
            if (!contactIds.isEmpty()) {
                DTSFPART_RunOnce.setAlreadyfired('DTSFPART_ContactTriggerHandler.execute_UserCreationJob');
                for (User eachUser : [Select Id, Name, ContactId from User Where ContactId IN :contactIds]) {
                    contactIds.remove(eachUser.ContactId);
                }
                if (!contactIds.isEmpty()) {
                    System.enqueueJob(new DTSFPART_PortalUserCreation(contactIds, accountIds));
                }
            }
        }
    }

    private static void send_RegistrationNotification(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        List<Id> contactIds = new List<Id>();
        for (Contact eachContact : newContacts.values()) {
            Contact oldContact = oldContacts.get(eachContact.Id);
            if (eachContact.RecordTypeId != NULL && eachContact.RecordTypeId.equals(partnerContactRT) && eachContact.LastModifiedById.equals(System.Label.PP_Mulesoft_UserId)
                    && String.isNotEmpty(eachContact.Status__c) && eachContact.Status__c.equals('Registration Completed') &&
                    !eachContact.Status__c.equals(oldContact.Status__c) && oldContact.Status__c.equals('Invited')) {
                contactIds.add(eachContact.Id);
            }
        }

        if (!contactIds.isEmpty()) {
            DTSFPART_UserInvitationController.send_RegistrationNotification(contactIds);
        }
    }

    private static void deleteMcnPermissions(Set<Id> contactIds) {
        List<Contact_Permissions__c> contactMcnPermissions = [SELECT Id FROM Contact_Permissions__c WHERE Contact__c IN :contactIds];
        delete contactMcnPermissions;
    }

    private static void syncTimeoutNotification(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        List<Id> contactIds = new List<Id>();
        for (Contact eachContact : newContacts.values()) {
            Contact oldContact = oldContacts.get(eachContact.Id);
            if (eachContact.RecordTypeId == partnerContactRT && oldContact.Enterprise_Permission_Status__c != 'In Progress'
                    && eachContact.Enterprise_Permission_Status__c == 'In Progress' && eachContact.Status__c == 'Active') {
                contactIds.add(eachContact.Id);
            }
        }
    }
}