/**
 * Created by QGBC67 on 29.07.2020.
 */

public with sharing class DTSFPART_PermissionUtils {

    private static Id mcnRecordTypeId;

    public static Boolean isMCNAccount(Id recordTypeId) {
        if (mcnRecordTypeId == null) {
            mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        }

        return mcnRecordTypeId != null && recordTypeId.equals(mcnRecordTypeId);
    }

    public static List<Account> getMcnAccountsByParent(Set<Id> accounts) {
        Id McnType = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccounts = [
                SELECT ID, ParentId, Assigned_MR__c, Parent_Record_Type__c
                FROM Account
                WHERE RecordTypeId = :McnType AND ERP_Active__c = true
                AND ParentId IN :accounts AND Motorola_Customer_Number__c != null
        ];
        return mcnAccounts;
    }

    public static List<Account> getMcnAccountsByAssignedMr(Set<Id> accounts) {
        Id McnType = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccounts = [
                SELECT ID, ParentId, Assigned_MR__c, Parent_Record_Type__c
                FROM Account
                WHERE RecordTypeId = :McnType AND ERP_Active__c = true
                AND Assigned_MR__c IN :accounts AND Motorola_Customer_Number__c != null
        ];
        return mcnAccounts;
    }

    public static Map<Id, List<Technology_Specialization__c>> sortProgramDetailByAccount(List<Technology_Specialization__c> pgds) {
        Map<Id, List<Technology_Specialization__c>> pgdsByAccount = new Map<Id, List<Technology_Specialization__c>>();
        for (Technology_Specialization__c pgd : pgds) {
            if (!pgdsByAccount.containsKey(pgd.Account__c)) {
                pgdsByAccount.put(pgd.Account__c, new List<Technology_Specialization__c>());
            }
            pgdsByAccount.get(pgd.Account__c).add(pgd);
        }
        return pgdsByAccount;
    }

    public static Map<Id, List<Technology_Specialization__c>> getProgramDetailsByAccount(Set<Id> accountIds) {
        List<Technology_Specialization__c> programDetails = [
                SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Account__c, Account__r.BillingCountry
                FROM Technology_Specialization__c
                WHERE Account__c IN :accountIds AND Technology_Specialization_Status__c = 'Active'
        ];
        return sortProgramDetailsByAccount(programDetails);
    }

    public static MCN_Permission__c createMCNPermissions(String mcnPermissionsCsv, String contactMCNPermissionsCsv) {
        return null;
    }

    // Contact permissions by Persona
    public static Map<String, List<Default_Communities_Permissions__mdt>> getContactPermissionsByPersona() {

        Map<String, List<Default_Communities_Permissions__mdt>> permissionsByPersona = new Map<String, List<Default_Communities_Permissions__mdt>> ();

        List<Default_Communities_Permissions__mdt> defaultPermissions = new List<Default_Communities_Permissions__mdt> ();
        defaultPermissions = [
                SELECT Community_Type__c, Contact_Internal_Permissions__c, Contact_Mcn_Permissions__c, Persona__c, Tags__c
                FROM Default_Communities_Permissions__mdt
                WHERE Persona__c != null
        ];

        // Add mock values for testing purposes.
        if (Test.isRunningTest()) {
            Default_Communities_Permissions__mdt testPermission = new Default_Communities_Permissions__mdt();
            testPermission.Persona__c = 'SalesManager';
            testPermission.Contact_Internal_Permissions__c = 'My View Access';
            testPermission.Contact_Mcn_Permissions__c = 'OrderSubmission';
            testPermission.Community_Type__c = 'Value Added Reseller';
            defaultPermissions.add(testPermission);
        }

        for (Default_Communities_Permissions__mdt permission : defaultPermissions) {
            if (!permissionsByPersona.containsKey(permission.Persona__c)) {
                permissionsByPersona.put(permission.Persona__c, new List<Default_Communities_Permissions__mdt>());
            }
            permissionsByPersona.get(permission.Persona__c).add(permission);
        }
        return permissionsByPersona;
    }

    public static Map<Id, Account> getAccountsWithProgramDetails(List<Contact> contacts) {
        Set<Id> AccountsIds = DTSFPART_Utils.getSetOfIds(contacts, 'AccountId');
        Map<Id, Account> accountsWithProgramDetails = new Map<Id, Account>();
        for(Account account: [
            SELECT Id,
                RecordTypeId,
                Motorola_Enterprise_ID__c,
                BillingCountry,
                ( SELECT Id, Community_Type__c
                FROM Technology_Specializations__r
                WHERE Community_Type__c != null ),
                ( SELECT Id FROM ChildAccounts )
            FROM Account
            WHERE 
                Id IN :AccountsIds  AND 
                ((RecordTypeId = :DTSFPART_Utils.getRecordTypeId('Account', 'Partner') AND
                MPE_Program_Status_New__c = 'Active') OR 
                (RecordTypeId = :DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount'))) AND
                Partner_Hub_enabled__c = TRUE
        ]){
            if(String.isNotBlank(account.Motorola_Enterprise_ID__c) && account.ChildAccounts.size() > 0){
                accountsWithProgramDetails.put(account.Id, account);
            }
        }
        
        return accountsWithProgramDetails;
    }

    // Used in Contact and User trigger. Setting MCM and internal permissions for given contacts.
    public static List<Contact> setHubDefaultPermissions(List<Contact> contacts) {
        Map<String, List<Default_Communities_Permissions__mdt>> permissionsByPersona = DTSFPART_PermissionUtils.getContactPermissionsByPersona();
        Map<Id, Account> accountsWithProgramDetails = getAccountsWithProgramDetails(contacts);
        List<Contact> changedContacts = new List<Contact>();
        for (Contact oneContact : contacts) {
            if (String.isNotBlank(oneContact.Persona__c) && permissionsByPersona.containsKey(oneContact.Persona__c)) {

                // Skip this contact if we are missing details about account as then we can't find community name
                if (oneContact.AccountId == null || !accountsWithProgramDetails.containsKey(oneContact.AccountId)) {
                    System.debug('## Empty Account ID or not found in queried accounts. Skipping contact: ' + oneContact.Id + ' ##');
                    continue;
                }

                Set<String> communityTypes = new Set<String>();
                Account acc = accountsWithProgramDetails.get(oneContact.AccountId);

                if(acc.RecordTypeId == DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount')){
                    communityTypes.add('Direct');
                }else {
                    for (Technology_Specialization__c ts : acc.Technology_Specializations__r) {
                        communityTypes.add(ts.Community_Type__c);
                    }
                }

                if (communityTypes.isEmpty()) {
                    System.debug('## Empty Community Types on Account nothing to do. Skipping contact: ' + oneContact.Id + ' ##');
                    continue;
                }

                Set<String> contactMCNPermissions = new Set<String>();
                Set<String> contactLevelInternalPermissions = new Set<String>();
                Set<String> tags = new Set<String>();

                for (Default_Communities_Permissions__mdt personaPermissions : permissionsByPersona.get(oneContact.Persona__c)) {
                    if (!communityTypes.contains(personaPermissions.Community_Type__c)) {
                        continue;
                    }

                    if (String.isNotBlank(personaPermissions.Contact_Mcn_Permissions__c)) {
                        contactMCNPermissions.addAll(personaPermissions.Contact_Mcn_Permissions__c.split('[;,]'));
                    }
                    if (String.isNotBlank(personaPermissions.Contact_Internal_Permissions__c)) {
                        contactLevelInternalPermissions.addAll(personaPermissions.Contact_Internal_Permissions__c.split('[;,]'));
                    }
                    if (String.isNotBlank(personaPermissions.Tags__c)) {
                        tags.addAll(personaPermissions.Tags__c.split('[;,]'));
                    }
                }
                
                removeCanadaPermissions(contactMCNPermissions, accountsWithProgramDetails.get(oneContact.AccountId).BillingCountry);

                if(!(permisionsEquals(oneContact.Contact_MCN_Permissions__c, contactMCNPermissions)
                        && permisionsEquals(oneContact.Contact_level_Internal_permissions__c, contactLevelInternalPermissions)
                        && permisionsEquals(oneContact.Tag__c, tags))) {
                    oneContact.Contact_MCN_Permissions__c = String.join((Iterable<String>) contactMCNPermissions, ';');
                    oneContact.Contact_level_Internal_permissions__c = String.join((Iterable<String>) contactLevelInternalPermissions, ';');
                    if(String.isNotBlank(oneContact.Tag__c)){
                        tags.addAll(oneContact.Tag__c.split('[;,]')); // https://jira.mot-solutions.com/browse/DTPART-1366
                    }
                    oneContact.Tag__c = String.join((Iterable<String>) tags, ';');
                    oneContact.Enterprise_Permission_Status__c = 'In Progress';
                    changedContacts.add(oneContact);
                }
            } else if(oneContact.Contact_MCN_Permissions__c != ''
                        || oneContact.Contact_level_Internal_permissions__c != '') {
                oneContact.Contact_MCN_Permissions__c = '';
                oneContact.Contact_level_Internal_permissions__c = '';
                oneContact.Enterprise_Permission_Status__c = 'In Progress';
                changedContacts.add(oneContact);
            }
        }
        return changedContacts;
    }

    public static Map<Id, List<MCN_Permission__c>> getMCNPermissionsByAccount(List<Id> accountsIds) {
        Map<Id, List<MCN_Permission__c>> permissionsByMCNs = new Map<Id, List<MCN_Permission__c>>();
        for (MCN_Permission__c permission : [SELECT Id, MCN_Account__c, MCN_Permissions__c, Contact_MCN_Permissions__c, Customer_OR_Partner_Account__c FROM MCN_Permission__c WHERE MCN_Account__c IN :accountsIds]) {
            if (!permissionsByMCNs.containsKey(permission.MCN_Account__c)) {
                permissionsByMCNs.put(permission.MCN_Account__c, new List<MCN_Permission__c>());
            }

            permissionsByMCNs.get(permission.MCN_Account__c).add(permission);
        }
        return permissionsByMCNs;
    }

    public static Map<Id, List<MCN_Permission__c>> getMCNPermissionsByCustomerOrPartnerAccount(List<Id> accountsIds) {
        Map<Id, List<MCN_Permission__c>> permissionsByCustomerOrPartnerAccounts = new Map<Id, List<MCN_Permission__c>>();
        for (MCN_Permission__c permission : [
                SELECT Id, 
                MCN_Account__c, 
                MCN_Account__r.Parent_Record_Type__c, 
                MCN_Account__r.Assigned_MR__c, 
                MCN_Permissions__c, 
                Contact_MCN_Permissions__c, 
                Customer_OR_Partner_Account__c 
                FROM MCN_Permission__c 
                WHERE Customer_OR_Partner_Account__c IN :accountsIds
                ]) {
            if (!permissionsByCustomerOrPartnerAccounts.containsKey(permission.Customer_OR_Partner_Account__c)) {
                permissionsByCustomerOrPartnerAccounts.put(permission.Customer_OR_Partner_Account__c, new List<MCN_Permission__c>());
            }

            permissionsByCustomerOrPartnerAccounts.get(permission.Customer_OR_Partner_Account__c).add(permission);
        }
        return permissionsByCustomerOrPartnerAccounts;
    }

    public static Map<Id, DTSFPART_AccountPermissionsWrapper> calculateDefaultMCNPermissionsByAccount(Set<Id> parentAccountIds) {
        return calculateDefaultMCNPermissionsByAccount(parentAccountIds, false);
    }

    public static Map<Id, DTSFPART_AccountPermissionsWrapper> calculateDefaultMCNPermissionsByAccount(Set<Id> parentAccountIds, Boolean isMR) {
        Map<Id, List<Technology_Specialization__c>> programDetailByAccount = getProgramDetailsByAccount(parentAccountIds);
        Map<Id, DTSFPART_AccountPermissionsWrapper> accountPermissions = new Map<Id, DTSFPART_AccountPermissionsWrapper>();

        for (Id id : parentAccountIds) {
            Set<String> mcnPermissions = new Set<String>();
            Set<String> contactMCNPermissions = new Set<String>();

            if (id != null && programDetailByAccount.containsKey(id)) {
                for (Technology_Specialization__c programDetail : programDetailByAccount.get(id)) {
                    Boolean isSignificant = programDetail.Community_Type__c != 'State/Local Manufacturer Representative'
                            && programDetail.Community_Type__c != 'Federal Manufacturer Representative';
                    isSignificant = isMR ? !isSignificant : isSignificant;
                    if (isSignificant) {
                        if (String.isNotBlank(programDetail.MCN_Permissions__c)) {
                            mcnPermissions.addAll(programDetail.MCN_Permissions__c.split(';'));
                        }
                        if (String.isNotBlank(programDetail.Contact_Mcn_Permissions__c)) {
                            contactMCNPermissions.addAll(programDetail.Contact_Mcn_Permissions__c.split(';'));
                        }

                        removeCanadaPermissions(contactMCNPermissions, programDetail.Account__r.BillingCountry);
                    }
                }
            }

            accountPermissions.put(id, new DTSFPART_AccountPermissionsWrapper(
                    String.join((Iterable<String>) mcnPermissions, ';'),
                    String.join((Iterable<String>) contactMCNPermissions, ';')
            ));
        }

        return accountPermissions;
    }

    public static DTSFPART_AccountPermissionsWrapper calculateDefaultMCNPermissionsForCustomer() {
        Default_Communities_Permissions__mdt defaultCustomerCommunitiesPermission = Default_Communities_Permissions__mdt.getInstance('Direct');
        return new DTSFPART_AccountPermissionsWrapper( defaultCustomerCommunitiesPermission.Mcn_Permissions__c, defaultCustomerCommunitiesPermission.Contact_Mcn_Permissions__c);
    }

    public static List<Contact> getContactsByParentAccounts(Set<Id> parentAccountsIds) {
        return [
                SELECT Id, Name, Persona__c, AccountId, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c
                FROM Contact
                WHERE AccountId IN :parentAccountsIds AND Delete_Requested__c = FALSE  AND Status__c != 'Inactive'
                AND Status__c != 'Deactivation Requested' AND Status__c != NULL AND Persona__c != NULL
        ];
    }

    public static Map<Id, DTSFPART_PermissionDifference> calculatePermissionChangeByAccount(
            Map<Id, Technology_Specialization__c> newProgramDetails,
            Map<Id, Technology_Specialization__c> oldProgramDetails) {
        Map<Id, DTSFPART_PermissionDifference> mcnPermissionDifferencesByAccount =
                new Map<Id, DTSFPART_PermissionDifference>();
        Map<Id, List<Technology_Specialization__c>> newProgramDetailsByAccount =
                sortProgramDetailsByAccount(newProgramDetails.values());
        Map<Id, List<Technology_Specialization__c>> oldProgramDetailsByAccount =
                sortProgramDetailsByAccount(oldProgramDetails.values());
        for (Id accountId : newProgramDetailsByAccount.keySet()) {
            DTSFPART_PermissionDifference accountChanges = new DTSFPART_PermissionDifference();
            for (Technology_Specialization__c newProgramDetail : newProgramDetailsByAccount.get(accountId)) {
                Boolean isMr = programDetailIsMr(newProgramDetail);
                Technology_Specialization__c oldProgramDetail = oldProgramDetails.get(newProgramDetail.Id);
                if (newProgramDetail.Technology_Specialization_Status__c.equals('Active')) {
                    Set<String> newMcnPermissions = splitPermissions(newProgramDetail.MCN_Permissions__c);
                    Set<String> newContactMcnPermissions = splitPermissions(newProgramDetail.Contact_Mcn_Permissions__c);
                    Set<String> mcnPermissionsAdded = new Set<String>(newMcnPermissions);
                    Set<String> contactMCNPermissionsAdded = new Set<String>(newContactMcnPermissions);
                    if (oldProgramDetail != null
                            && oldProgramDetail.Technology_Specialization_Status__c != null
                            && oldProgramDetail.Technology_Specialization_Status__c.equals('Active')) {
                        Set<String> oldMcnPermissions = splitPermissions(oldProgramDetail.MCN_Permissions__c);
                        Set<String> oldContactMcnPermissions = splitPermissions(oldProgramDetail.Contact_Mcn_Permissions__c);
                        mcnPermissionsAdded.removeAll(oldMcnPermissions);
                        contactMCNPermissionsAdded.removeAll(oldContactMcnPermissions);
                        if (newProgramDetail.Account__c == oldProgramDetail.Account__c) {
                            Set<String> mcnPermissionsRemoved = new Set<String>(oldMcnPermissions);
                            mcnPermissionsRemoved.removeAll(newMcnPermissions);
                            Set<String> contactMcnPermissionsRemoved = new Set<String>(oldContactMcnPermissions);
                            contactMcnPermissionsRemoved.removeAll(newContactMcnPermissions);
                            accountChanges.removePermissions(mcnPermissionsRemoved, contactMcnPermissionsRemoved, isMr);
                        }
                    }
                    accountChanges.addPermissions(mcnPermissionsAdded, contactMCNPermissionsAdded, isMr);
                } else if (oldProgramDetail != null
                        && oldProgramDetail.Technology_Specialization_Status__c != null
                        && oldProgramDetail.Technology_Specialization_Status__c.equals('Active')) {
                    Set<String> oldMcnPermissions = splitPermissions(oldProgramDetail.MCN_Permissions__c);
                    Set<String> oldContactMcnPermissions = splitPermissions(oldProgramDetail.Contact_Mcn_Permissions__c);
                    accountChanges.removePermissions(oldMcnPermissions, oldContactMcnPermissions, isMr);
                }
            }
            if (oldProgramDetailsByAccount != null && oldProgramDetailsByAccount.containsKey(accountId)) {
                for (Technology_Specialization__c oldProgramDetail : oldProgramDetailsByAccount.get(accountId)) {
                    Technology_Specialization__c newProgramDetail = newProgramDetails.get(oldProgramDetail.Id);
                    if (newProgramDetail.Account__c != oldProgramDetail.Account__c) {
                        Set<String> oldMcnPermissions = splitPermissions(oldProgramDetail.MCN_Permissions__c);
                        Set<String> oldContactMcnPermissions = splitPermissions(oldProgramDetail.Contact_Mcn_Permissions__c);
                        accountChanges.removePermissions(oldMcnPermissions, oldContactMcnPermissions, programDetailIsMr(oldProgramDetail));
                    }
                }
            }
            mcnPermissionDifferencesByAccount.put(accountId, accountChanges);
        }
        return mcnPermissionDifferencesByAccount;
    }

    public static Map<Id, List<Technology_Specialization__c>> sortProgramDetailsByAccount(
            List<Technology_Specialization__c> pgds) {
        Map<Id, List<Technology_Specialization__c>> pgdsByAccount = new Map<Id, List<Technology_Specialization__c>>();
        for (Technology_Specialization__c pgd : pgds) {
            if (!pgdsByAccount.containsKey(pgd.Account__c)) {
                pgdsByAccount.put(pgd.Account__c, new List<Technology_Specialization__c>());
            }
            pgdsByAccount.get(pgd.Account__c).add(pgd);
        }
        return pgdsByAccount;
    }

    public static Map<Id, List<Technology_Specialization__c>> sortMcnAccountsByParent(
            List<Technology_Specialization__c> pgds) {
        Map<Id, List<Technology_Specialization__c>> pgdsByAccount = new Map<Id, List<Technology_Specialization__c>>();
        for (Technology_Specialization__c pgd : pgds) {
            if (!pgdsByAccount.containsKey(pgd.Account__c)) {
                pgdsByAccount.put(pgd.Account__c, new List<Technology_Specialization__c>());
            }
            pgdsByAccount.get(pgd.Account__c).add(pgd);
        }
        return pgdsByAccount;
    }

    public static Map<Id, List<Contact_Permissions__c>> getContactMcnPermissionsByContact(Set<Id> contactIds) {
        List<Contact_Permissions__c> contactMcnPermissions = [
                SELECT Id, MCN_Account__c, Parent_Account__c, Contact__c, MCN_Permission__r.Contact_MCN_Permissions__c, Contact_MCN_Permissions__c, Contact__r.Contact_MCN_Permissions__c
                FROM Contact_Permissions__c
                WHERE Contact__c in :contactIds
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

    public static Set<String> splitPermissions(String permissions) {
        if (String.isBlank(permissions)) {
            return new Set<String>();
        } else {
            return new Set<String>(permissions.split(';'));
        }
    }

    public static Set<String> calculateIntersection(Set<String>permissionsA, Set<String> permissionsB) {
        permissionsA.retainAll(permissionsB);
        return permissionsA;
    }

    public static Set<String> calculateIntersection(String permissionStringA, Set<String> permissionsB) {
        Set<String> permissionsA = splitPermissions(permissionStringA);
        return calculateIntersection(permissionsA, permissionsB);
    }

    public static Set<String> calculateIntersection(String permissionsA, String permissionsB) {
        Set<String> permissionBSet = splitPermissions(permissionsB);
        Set<String> permissionASet = splitPermissions(permissionsA);
        return calculateIntersection(permissionASet, permissionBSet);
    }

    public static Boolean programDetailIsMr(Technology_Specialization__c programDetail) {
        return programDetail.Community_Type__c == 'State/Local Manufacturer Representative'
                || programDetail.Community_Type__c == 'Federal Manufacturer Representative';
    }

    public static Boolean mcnPermissionIsMr(MCN_Permission__c mcnPermission) {
        return mcnPermission.MCN_Account__r.Parent_Record_Type__c != 'Partner'
                && mcnPermission.Customer_OR_Partner_Account__c == mcnPermission.MCN_Account__r.Assigned_MR__c;
    }

    public static Boolean permisionsEquals(String expected, String actual) {
        if (expected != actual) {
            if (actual == null) {
                return false;
            }
            return permisionsEquals(expected, splitPermissions(actual));
        }
        return true;
    }
    public static Boolean permisionsEquals(String expected, Set<String> act) {
        if (String.isNotEmpty(expected)) {
            Set<String> exp = splitPermissions(expected);

            if (exp.size() != act.size()) return false;
            for (String item : act) {
                if (!exp.contains(item)) return false;
            }
            return true;
        } else if(act.isEmpty())
        {
            return true;
        }
        return false;
    }

    public static void setEnterprisePermissionStatusOnAccounts(Set<Id> enterpriseIds, String status) {
        List<Account> accounts = [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Id IN :enterpriseIds AND Partner_Hub_Enabled__c = TRUE AND Motorola_Enterprise_ID__c != null];
        for(Account acc : accounts) {
            acc.Enterprise_Permission_Status__c = status;
        }
        update accounts;
    }

    @future
	public static void assignPermissionSet(Set<Id> usersIds, String permissionName){
		List<PermissionSet> ps = [SELECT ID FROM PermissionSet WHERE Name = :permissionName];
        if(!ps.isEmpty()){
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for(Id userId: usersIds) {
                psAssignments.add(new PermissionSetAssignment(PermissionSetId=ps[0].Id, AssigneeId=userId));
            }

            try {
                insert(psAssignments);
            }
            catch(DmlException ex) {
                LogError.saveErrorPEvent('DTSFPART_UTILS.assignPermissionSet',
                                        'Permissino set name ' + permissionName + ' Affected users: ' + usersIds,
                                        ex.getMessage() + ' ' + ex.getStackTraceString());
                throw ex;
            }
        }
	}

    public static Map<Id, String> populateCountryMap(Map<Id, Contact> contacts){
        Map<Id, String> countryMap = new Map<Id, String>();

        for(Contact contact: [SELECT Id, AccountId, Account.BillingCountry FROM Contact WHERE Id IN :contacts.keySet()]){
            countryMap.put(contact.AccountId, contact.Account.BillingCountry);
        }

        return countryMap;
    }

    public static void removeCanadaPermissions(Set<String> container, String country){
        if(country.equals('Canada')){
            container.remove('RepairSubmission');
            container.remove('WarrantyOrderSubmission');
        }
    }
}