/**
 * @author		Paweł Woźniak
 * @created		2020-09-04
 * @description Various methods for LWC frontend usage.
 */

public without sharing class DTSFPART_LWC_PermissionPicklists {
    /**
     * Chek possible permission values for given MCN PermissionRecord
     * @link https://jira.mot-solutions.com/browse/DTPART-100 //a3R2C00000038IdUAI
     * @param contactMCNPermisionRecorId record Id
     * @return allowedPermValuesWrapper which contains allowed MCNPermissions and contactMCNPermissions
     */

    @AuraEnabled
    public static AllowedPermValuesWrapper contactMCNPermissions_AllowedPermissionValues(
        Id contactMCNPermisionRecorId
    ) {
        try {
            if (String.isBlank(contactMCNPermisionRecorId)) {
                LogError.saveInfo(
                    'DTSFPART_LWC_PermissionPicklists.contactMCNPermissions_AllowedPermissionValues',
                    'Method was called with empty parameter. Nothing to do.',
                    'If this error repet often check LWC which is calling this method.'
                );
                return null;
            }

            List<Contact_Permissions__c> contactPermissions = [
                SELECT Id, MCN_Account__c
                FROM Contact_Permissions__c
                WHERE Id = :contactMCNPermisionRecorId
            ];

            if (contactPermissions.isEmpty()) {
                LogError.saveError(
                    'DTSFPART_LWC_PermissionPicklists.contactMCNPermissions_AllowedPermissionValues',
                    'Contact Permision record for provided Id: ' +
                    contactMCNPermisionRecorId +
                    ' not found.',
                    ''
                );
                return null;
            }

            return mcnPermissions_AllowedPermissionValues(contactPermissions[0].MCN_Account__c);
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Chek possible permission values for given MCN PermissionRecord
     * @link https://jira.mot-solutions.com/browse/DTPART-100
     * @param mcnAccountId record Id
     * @return allowedPermValuesWrapper which contains allowed MCNPermissions and contactMCNPermissions
     */

    @AuraEnabled
    public static AllowedPermValuesWrapper mcnPermissions_AllowedPermissionValues(Id mcnAccountId) {
        try {
            AllowedPermValuesWrapper apvWrapper = new AllowedPermValuesWrapper();

            List<MCN_Permission__c> MCNPermissions = [
                SELECT Id, MCN_Permissions__c, Contact_MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE MCN_Account__c = :mcnAccountId
            ];

            for (MCN_Permission__c onePerm : MCNPermissions) {
                apvWrapper.MCNPermissionId = onePerm.Id;
                if (String.isNotBlank(onePerm.MCN_Permissions__c)) {
                    apvWrapper.MCNPermissions.addAll(onePerm.MCN_Permissions__c.split('[;]'));
                }
                if (String.isNotBlank(onePerm.Contact_MCN_Permissions__c)) {
                    apvWrapper.ContactMCNPermissions.addAll(onePerm.Contact_MCN_Permissions__c.split('[;]'));
                }
            }

            return apvWrapper;
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     *  Returns details of selected Contact_Permissions__c .
     *  @link https://jira.mot-solutions.com/browse/DTPART-741
     *  @param contactMcnPermissionsId
     *  @return Contact_Permissions__c
     */
    @AuraEnabled
    public static Contact_Permissions__c getContactMcnPermissionsDetails(Id contactMcnPermissionsId) {
        try {
            return [
                SELECT
                    Id,
                    Contact_MCN_Permissions__c,
                    Motorola_Customer_Number__c,
                    MCN_Account__r.Name,
                    MCN_Account__r.MCN_Account_Name__c,
                    Contact__c
                FROM Contact_Permissions__c
                WHERE Id = :contactMcnPermissionsId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     *  Returns parent account id for selected account.
     *  @link https://jira.mot-solutions.com/browse/DTPART-741
     *  @param accountId
     *  @return string - parent id converted to string.
     */
    @AuraEnabled
    public static String getParentAccountId(Id accountId) {
        try {
            Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :accountId LIMIT 1];

            return String.valueOf(acc.ParentId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getParentAccountIdBasedOnContactId(Id contactId) {
        try {
            Contact currentContact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId LIMIT 1];

            return String.valueOf(currentContact?.AccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     *  Returns allowed values for pciklists for contact with given persona.
     *  Used on frontend in LWC component for limiting possible choice from all values on picklist.
     *  @link https://jira.mot-solutions.com/browse/DTPART-99
     *  @param ContactId contact Id
     *  @param personaAPIName persona API name
     *  @return AllowedPermValuesByPersonaWrapper with values for picklists.
     */
    @AuraEnabled(cacheable=true)
    public static AllowedPermValuesByPersonaWrapper contact_AllowedPermissionValuesByPersona(
        String ContactId,
        String personaAPIName
    ) {
        try {
            AllowedPermValuesByPersonaWrapper apvWrapper = new AllowedPermValuesByPersonaWrapper();

            Contact oneContact = [SELECT Id, AccountId FROM Contact WHERE Id = :ContactId];
            Map<String, List<Default_Communities_Permissions__mdt>> permissionsByPersona = DTSFPART_PermissionUtils.getContactPermissionsByPersona();
            Map<Id, Account> accountsWithProgramDetails = DTSFPART_PermissionUtils.getAccountsWithProgramDetails(
                new List<Contact>{ oneContact }
            );

            if (!permissionsByPersona.containsKey(personaAPIName)) {
                LogError.saveErrorFuture(
                    'DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona()',
                    'Settings for persona: ' +
                    personaAPIName +
                    ' not found.',
                    'Check "Default Communities Permission" (Default_Communities_Permissions__mdt) custom metadata for valid configuration.'
                );
                return null;
            }

            if (oneContact.AccountId == null || !accountsWithProgramDetails.containsKey(oneContact.AccountId)) {
                LogError.saveInfoFuture(
                    'DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona()',
                    'Empty Account ID or not found in queried accounts. Skipping contact: ' + oneContact.Id,
                    ''
                );
                return null;
            }

            Set<String> communityTypes = new Set<String>();
            Account acc = accountsWithProgramDetails.get(oneContact.AccountId);

            if (acc.RecordTypeId == DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount')) {
                communityTypes.add('Direct');
            } else {
                for (Technology_Specialization__c ts : acc.Technology_Specializations__r) {
                    communityTypes.add(ts.Community_Type__c);
                }
            }

            if (communityTypes.isEmpty()) {
                LogError.saveInfoFuture(
                    'DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona()',
                    'Empty Community Types on Account nothing to do. Skipping contact: ' + oneContact.Id,
                    ''
                );
                return null;
            }
            if (acc.RecordTypeId == DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount')) {
                communityTypes.add('Direct');
            } else {
                for (Technology_Specialization__c ts : acc.Technology_Specializations__r) {
                    communityTypes.add(ts.Community_Type__c);
                }
            }
            for (Default_Communities_Permissions__mdt personaPermissions : permissionsByPersona.get(personaAPIName)) {
                if (!communityTypes.contains(personaPermissions.Community_Type__c)) {
                    continue;
                }
                if (String.isNotBlank(personaPermissions.Contact_Mcn_Permissions__c)) {
                    apvWrapper.contactMCNPermissions.addAll(
                        personaPermissions.Contact_Mcn_Permissions__c.split('[;,]')
                    );
                }
                if (String.isNotBlank(personaPermissions.Contact_Internal_Permissions__c)) {
                    apvWrapper.contactLevelInternalPermissions.addAll(
                        personaPermissions.Contact_Internal_Permissions__c.split('[;,]')
                    );
                }
                if (String.isNotBlank(personaPermissions.Tags__c)) {
                    apvWrapper.tags.addAll(personaPermissions.Tags__c.split('[;,]'));
                }
            }

            return apvWrapper;
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Check if user have given permission on Contact MCN permission (Contact_Permissions__c) object.
     *
     * @link https://jira.mot-solutions.com/browse/DTPART-451
     * @param permissionAPIName permission API name which need to be checked
     * @return boolean true/false
     */
    @AuraEnabled(cacheable=true)
    public static boolean doesUserHavePermission(String permissionAPIName) {
        try {
            User runningUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            List<Contact_Permissions__c> contactPermissions = [
                SELECT Id, Contact_MCN_Permissions__c
                FROM Contact_Permissions__c
                WHERE
                    MCN_Account__r.Customer_or_Prospect_Account__c = :runningUser.Contact.AccountId
                    AND Contact_MCN_Permissions__c INCLUDES (:permissionAPIName)
                LIMIT 1
            ];
            return !contactPermissions.isEmpty();
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Data wrapper which return MCNPermissions and contactMCNPermissions values.
     */
    public class AllowedPermValuesWrapper {
        @AuraEnabled
        public Id MCNPermissionId {get; set;}
        @AuraEnabled
        public Set<String> MCNPermissions { get; set; }
        @AuraEnabled
        public Set<String> contactMCNPermissions { get; set; }

        AllowedPermValuesWrapper() {
            MCNPermissions = new Set<String>();
            contactMCNPermissions = new Set<String>();
        }
    }

    /**
     * Data wrapper which return contactMCNPermissions, contactLevelInternalPermissions and tags values.
     */
    public class AllowedPermValuesByPersonaWrapper {
        @AuraEnabled
        public Set<String> contactMCNPermissions { get; set; }
        @AuraEnabled
        public Set<String> contactLevelInternalPermissions { get; set; }
        @AuraEnabled
        public Set<String> tags { get; set; }

        AllowedPermValuesByPersonaWrapper() {
            contactMCNPermissions = new Set<String>();
            contactLevelInternalPermissions = new Set<String>();
            tags = new Set<String>();
        }
    }
}