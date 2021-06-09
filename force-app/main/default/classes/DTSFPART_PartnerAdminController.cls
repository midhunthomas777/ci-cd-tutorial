/**
 * @author       Sagar Sindhi
 * @created      2020-08-06
 * @updated      2021-02-03
 * @description  Controller for DTSFPART_PartnerAdminApproval, DTSFPART_PartnerAdminARejection for all backend logic
 */
public without sharing class DTSFPART_PartnerAdminController {
    @AuraEnabled
    public static DTSFPART_PartnerAdminControllerWrapper.ContactWrapper getExistingDetails(String currentRecordId) {
        try {
            List<MPEContact__c> contactResult = getMPEContact(currentRecordId);
            if (!contactResult.isEmpty()) {
                return new DTSFPART_PartnerAdminControllerWrapper.ContactWrapper(
                    contactResult.get(0).Salutation__c,
                    contactResult.get(0).First_Name__c,
                    contactResult.get(0).Last_Name__c,
                    contactResult.get(0).Email__c,
                    contactResult.get(0).Status__c,
                    DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact'),
                    contactResult.get(0).Account__c,
                    String.isNotBlank(contactResult.get(0).Country__c) ? getCountryCode(contactResult.get(0).Country__c) : '',
                    String.isNotBlank(contactResult.get(0).Mobile__c) ? contactResult.get(0).Mobile__c : '',
                    String.isNotBlank(contactResult.get(0).Phone__c) ? contactResult.get(0).Phone__c : '',
                    String.isNotBlank(contactResult.get(0).Fax__c) ? contactResult.get(0).Fax__c : '',
                    contactResult.get(0).Primary_Language__c
                );
            } else {
                return new DTSFPART_PartnerAdminControllerWrapper.ContactWrapper(
                    '','', '', '', '', DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact'), '','','','','',''
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ListView> denyUserANDSendNotification(String currentRecordId) {
        try {
            List<MPEContact__c> contactResult = getMPEContact(currentRecordId);
            if (!contactResult.isEmpty()) {
                contactResult.get(0).Approve_Decline__c = 'Reject';
                contactResult.get(0).Status__c = 'Registration Denied';
                try {
                    update contactResult;
                    sendEmailNotification(contactResult);
                } catch (Exception e) {
                    LogError.saveExceptionPEvent(
                        'DTSFPART_PartnerAdminController.denyUserANDSendNotification',
                        '', '', e
                    );
                    throw new AuraHandledException(e.getMessage());
                }
            }
            return [
                SELECT Id, Name
                FROM ListView
                WHERE SobjectType = 'MPEContact__c'
                AND DeveloperName = 'Pending_Users'
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getCountryCode(String countryName) {
        String countrycode;
        List<Schema.PicklistEntry> picklistEntries = User.Countrycode.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries){
            if (entry.getLabel() == countryName) {
                countrycode = entry.getValue();
                break;
            }
        }
        return countrycode;
    }

    private static List<MPEContact__c> getMPEContact(String currentRecordId) {
        return [
            SELECT
            Id,
            Salutation__c,
            First_Name__c,
            Last_Name__c,
            Email__c,
            Status__c,
            Account__c,
            Approve_Decline__c,
            Mobile__c,
            Phone__c,
            Fax__c,
            Country__c,
            Primary_Language__c
            FROM MPEContact__c
            WHERE Id =: currentRecordId
        ];
    }

    private static void sendEmailNotification(List<MPEContact__c> contactResult) {
        try {
            List<Id> targetobjIds = new List<Id>();
            Id accountId = contactResult.get(0).Account__c;
            Map<Id, Contact> targetObjMap = new Map<Id, Contact>(
                [
                    SELECT Id
                    FROM Contact
                    WHERE
                    RecordType.DeveloperName = 'MPE_Partner_Contact'
                    AND Email != NULL
                    AND AccountId =: accountId
                    LIMIT 1
                ]
            );
            targetobjIds.addAll(targetObjMap.keySet());
    
            if (!targetobjIds.isEmpty()) {
                Map<Id, List<String>> objWithAddress = new Map<Id, List<String>> {
                    contactResult.get(0).Id => new List<String>{
                        contactResult.get(0).Email__c
                    }
                };
                EmailTemplate template = [
                    SELECT Id
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Partner_Admin_Rejection_Notification'
                ];
    
                EmailMessagingClass.sendEmailMessage(
                    targetobjIds,
                    template.Id,
                    contactResult,
                    false,
                    null,
                    null,
                    null,
                    false,
                    objWithAddress
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future
    public static void updateContactStatus(Set<Id>userIds) {
        Set<Id> contactIds = new Set<Id>();
        for (User eachUser: [
                SELECT Id, ContactId
                FROM User
                WHERE Id IN: userIds
            ]) {
            contactIds.add(eachUser.ContactId);
        }
        List<Contact> contactsToBeUpdated = new List<Contact>();
        if (!contactIds.isEmpty()) {
            for (Contact eachContact: [
                    SELECT Id, Status__c
                    FROM Contact
                    WHERE Id IN: contactIds
                ]) {
                eachContact.Status__c = 'Active';
                eachContact.Source_Code__c = 'MSI';
                contactsToBeUpdated.add(eachContact);
            }
        }
        if (!contactsToBeUpdated.isEmpty()) {
            try {
                update contactsToBeUpdated;
            } catch (Exception e) {
                LogError.saveExceptionPEvent(
                    'DTSFPART_PartnerAdminController.updateContactStatus',
                    '', '', e
                );
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}