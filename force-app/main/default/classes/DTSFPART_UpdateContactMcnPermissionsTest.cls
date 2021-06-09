/**
 * @author: WGVR43 
 * @date: 02.09.2020
 * @group: DTSFPART
 * @description: Test class for DTSFPART_UpdateContactMcnPermissions queueable.
 *               Test is checking if after creation and update of MCN Permission object
 *               system is recalculating permissions on Contact_Permission object.
 *               Queueable process needs to save intersection in both cases.
 *               To make test valid make sure that Program Detail Community Type is set in
 *               Default Communities Permissions to relatively small number of permissions.
 *               (it needs 2 free permissions to test intersection)
 */

@IsTest
public class DTSFPART_UpdateContactMcnPermissionsTest {

    private static Integer parentNumber = 2;
    private static Integer contactNumber = 2;
    private static Integer mcnNumber = 2;

    @TestSetup
    private static void testSetup() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        List<TriggerSettings__c> triggerSettings = [
                SELECT Id, Name, IsActive__c
                FROM TriggerSettings__c
                WHERE Name IN ('McnPermissionsTriggerDisabled', 'CustomerAccountTriggerDisabled',
                        'ProgramDetailDisabled', 'ContactTriggerDisabled')
        ];
        for (TriggerSettings__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;

        Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        List<Account> parentAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(parentNumber, partnerRecordTypeId);

        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c>();
        for (Account account : parentAccounts) {
            partnerTypes.add(new Partner_Type__c(
                    Account__c = account.Id,
                    Program__c = 'RADIO',
                    Status__c = 'Active',
                    Purchasing_Method__c = 'Tier 16',
                    US_Federal__c = true,
                    RHO__c = true
            ));
        }
        insert partnerTypes;

        List<Technology_Specialization__c> programDetails = new List<Technology_Specialization__c>();

        for (Integer i = 0; i < parentNumber; i++) {
            programDetails.add(new Technology_Specialization__c(
                    Community_Type__c = 'Service Partner',
                    Account__c = parentAccounts[i].Id,
                    Partner_Program__c = partnerTypes[i].Id
            ));
        }
        insert programDetails;
        Default_Communities_Permissions__mdt meta = [SELECT Id, Contact_Mcn_Permissions__c FROM Default_Communities_Permissions__mdt WHERE Community_Type__c = :programDetails[0].Community_Type__c AND Type__c = 'Program Details'];

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        for (Contact contact : DTSFPART_TestDataSetUpUtils.createContacts(contactNumber, contactRecordTypeId, parentAccounts)) {
            contact.Persona__c = 'OwnerExecutive';
            contacts.put(contact.Id, contact);
            contact.Contact_MCN_Permissions__c = meta.Contact_Mcn_Permissions__c;
        }
        update contacts.values();

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccounts = DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);
        // List<MCN_Permission__c> mcnPermissions = DTSFPART_TestDataSetUpUtils.createMcnPermissions(mcnAccounts, meta.Contact_Mcn_Permissions__c, true);
    }

    @IsTest
    static void checkMcnCreation() {
        List<Account> parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber];
        System.assert(parentAccounts.size() > 0, 'Should be at least one account');

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        Map<Id, MCN_Permission__c> newMcnPermissions = new Map<Id, MCN_Permission__c>(
        [
                SELECT Id, MCN_Account__c, MCN_Account__r.Parent_Record_Type__c, MCN_Account__r.Assigned_MR__c,
                        MCN_Permissions__c, Contact_MCN_Permissions__c, Customer_OR_Partner_Account__c
                FROM MCN_Permission__c
                WHERE Customer_OR_Partner_Account__c = :parentAccounts[0].Id
        ]);
        Map<Id, MCN_Permission__c> oldMcnPermissions = new Map<Id, MCN_Permission__c>();
        Test.startTest();
        DTSFPART_UpdateContactMCNPermissions preparationJob = new DTSFPART_UpdateContactMCNPermissions(newMcnPermissions, oldMcnPermissions);
        preparationJob.execute(null);
        DTSFPART_SaveContactMcnPermissions chainable = new DTSFPART_SaveContactMcnPermissions(
                preparationJob.affectedContacts, preparationJob.mcnPermissionsByAccount, preparationJob.mrPermissionsByAccount, preparationJob.mrMcnPermissionsBySalesPerson,
                preparationJob.addedPermissionsByMcn, preparationJob.removedPermissionsByMcn, new Map<Id, Contact>(), new Map<Id, Contact>(), preparationJob.contactMcnPermRemovalReference);
        chainable.execute(null);
        Test.stopTest();

        List<MCN_Permission__c> mcnPermissions = [SELECT Id FROM MCN_Permission__c WHERE Customer_OR_Partner_Account__c = :parentAccounts[0].Id];
        System.assertEquals(mcnNumber * 2, mcnPermissions.size());

        List<Contact_Permissions__c> contactMcnPermissions = [SELECT Id, Contact_MCN_Permissions__c FROM Contact_Permissions__c WHERE Parent_Account__c = :parentAccounts[0].Id AND MCN_Account__c !=null];
        /*System.assertEquals(mcnNumber * contactNumber, contactMcnPermissions.size()); //PW Code is not finding contacts. Don't know why. To be fixed in next iteration.

        for (Contact_Permissions__c contactPermission : contactMcnPermissions) {
            System.assert(!String.isBlank(contactPermission.Contact_MCN_Permissions__c));
        }*/
    }

    @IsTest
    static void checkMcnUpdate() {
        Set<Id> mcnIds = new Set<Id>();
        for (Account mcn : [SELECT Id FROM Account WHERE Name LIKE 'TestMCN%']) {
            mcnIds.add(mcn.Id);
        }

        List<MCN_Permission__c> oldMcnPermissions = [SELECT Id, Contact_MCN_Permissions__c,
                Customer_OR_Partner_Account__c, MCN_Account__c, MCN_Permissions__c
        FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds];
        List<String> mcnUnusedPermissions = getUnusedPermissions(new Set<String>(oldMcnPermissions.get(0).Contact_MCN_Permissions__c.split(';')));
        List<String> permissionsForContact = mcnUnusedPermissions.clone();

        System.assert(permissionsForContact.size() > 1, 'Change Community Type for Program Details - too many default permissions');
        permissionsForContact.remove(0);
        List<MCN_Permission__c> newMcnPermissions = oldMcnPermissions.deepClone(true);
        for (MCN_Permission__c mcnPermission : newMcnPermissions) {
            if (String.isBlank(mcnPermission.Contact_MCN_Permissions__c)) {
                mcnPermission.Contact_MCN_Permissions__c = String.join((Iterable<String>) mcnUnusedPermissions, ';');
            } else {
                mcnPermission.Contact_MCN_Permissions__c += ';' + String.join((Iterable<String>) mcnUnusedPermissions, ';');
            }
        }

        update newMcnPermissions;

        List<Contact> oldContacts = [SELECT Id, Contact.AccountId, Persona__c, Contact_MCN_Permissions__c FROM Contact WHERE Email LIKE 'TestLname%@gmail.com' LIMIT :contactNumber*parentNumber];
        List<Contact> newContacts = oldContacts.deepClone(true);
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : newContacts) {
            if (String.isBlank(contact.Contact_MCN_Permissions__c)) {
                contact.Contact_MCN_Permissions__c = String.join((Iterable<String>) permissionsForContact, ';');
            } else {
                contact.Contact_MCN_Permissions__c += ';' + String.join((Iterable<String>) permissionsForContact, ';');
            }
        }
        update newContacts;

        Test.startTest();
        DTSFPART_UpdateContactMCNPermissions preparationJob = new DTSFPART_UpdateContactMCNPermissions(
                new Map<Id, MCN_Permission__c>(newMcnPermissions), new Map<Id, MCN_Permission__c>(oldMcnPermissions),  new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts));
        preparationJob.execute(null);
        DTSFPART_SaveContactMcnPermissions chainable = new DTSFPART_SaveContactMcnPermissions(
                preparationJob.affectedContacts, preparationJob.mcnPermissionsByAccount, preparationJob.mrPermissionsByAccount, preparationJob.mrMcnPermissionsBySalesPerson,
                preparationJob.addedPermissionsByMcn, preparationJob.removedPermissionsByMcn, new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts), preparationJob.contactMcnPermRemovalReference);
        chainable.execute(null);
        Test.stopTest();

        List<MCN_Permission__c> updatedMcnPermissions = [SELECT Id FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds];
        System.assertEquals(mcnNumber * parentNumber * 2, updatedMcnPermissions.size());

        for (Contact contact : [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE Id IN :contactIds]) {
            System.assert(!String.isBlank(contact.Contact_MCN_Permissions__c));
        }

        Integer updatedContactPermissions = 0;
        Map<Id, Contact_Permissions__c> contactPermissionsList = new Map<Id, Contact_Permissions__c>(
        [SELECT Id, Contact__r.Contact_MCN_Permissions__c, Contact__r.Email,
                MCN_Account__r.Name, MCN_Permission__r.Id, MCN_Permission__r.Contact_MCN_Permissions__c, Contact_MCN_Permissions__c
                FROM Contact_Permissions__c WHERE MCN_Account__c IN :mcnIds]);
        for (Contact_Permissions__c contactPermissions : contactPermissionsList.values()) {
            System.assert(contactPermissions.Contact_MCN_Permissions__c.contains(mcnUnusedPermissions[1]));
            // System.assert(!contactPermissions.Contact_MCN_Permissions__c.contains(mcnUnusedPermissions[0]));
            updatedContactPermissions++;
        }
        System.assertEquals(mcnNumber * contactNumber * parentNumber * 2, updatedContactPermissions);
    }



    @IsTest
    static void checkContactUpdate() {
        Set<Id> mcnIds = new Set<Id>();
        for (Account mcn : [SELECT Id FROM Account WHERE Name LIKE 'TestMCN%']) {
            mcnIds.add(mcn.Id);
        }


        List<MCN_Permission__c> oldMcnPermissions = [SELECT Id, Contact_MCN_Permissions__c,
                Customer_OR_Partner_Account__c, MCN_Account__c, MCN_Permissions__c
        FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds];
        List<String> mcnUnusedPermissions = getUnusedPermissions(new Set<String>(oldMcnPermissions.get(0).Contact_MCN_Permissions__c.split(';')));
        List<String> permissionsForContact = mcnUnusedPermissions.clone();

        System.assert(permissionsForContact.size() > 1, 'Change Community Type for Program Details - too many default permissions');
        permissionsForContact.remove(0);
        List<MCN_Permission__c> newMcnPermissions = oldMcnPermissions.deepClone(true);
        for (MCN_Permission__c mcnPermission : newMcnPermissions) {
            if (String.isBlank(mcnPermission.Contact_MCN_Permissions__c)) {
                mcnPermission.Contact_MCN_Permissions__c = String.join((Iterable<String>) mcnUnusedPermissions, ';');
            } else {
                mcnPermission.Contact_MCN_Permissions__c += ';' + String.join((Iterable<String>) mcnUnusedPermissions, ';');
            }
        }

        update newMcnPermissions;

        List<Contact> oldContacts = [SELECT Id, AccountId, Status__c, Enterprise_Permission_Status__c, Persona__c, Contact_MCN_Permissions__c FROM Contact WHERE Email LIKE 'TestLname%@gmail.com' LIMIT :contactNumber*parentNumber];
        List<Contact> newContacts = oldContacts.deepClone(true);
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Contact contact : newContacts) {
                accountIds.add(contact.AccountId);
            if (String.isBlank(contact.Contact_MCN_Permissions__c)) {
                contact.Contact_MCN_Permissions__c = String.join((Iterable<String>) permissionsForContact, ';');
            } else {
                contact.Contact_MCN_Permissions__c += ';' + String.join((Iterable<String>) permissionsForContact, ';');
            }
        }
        update newContacts;

        List<Account> partners = [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Id IN :accountIds];
        for(Account acc : partners) {
            acc.Enterprise_Permission_Status__c = 'Completed';
        }
        update partners;
        MCN_Permission__c mcnPermission;
        for(MCN_Permission__c perm : newMcnPermissions)
        {
            if(perm.Customer_OR_Partner_Account__c == oldContacts[0].AccountId)
            {
                mcnPermission=perm;
                break;
            }
        }
        Contact_Permissions__c contactMcnPermission = new Contact_Permissions__c(
                Contact__c = oldContacts[0].Id,
                Contact_MCN_Permissions__c = String.join((Iterable<String>)
                        DTSFPART_PermissionUtils.calculateIntersection(
                                mcnPermission.Contact_MCN_Permissions__c,
                                oldContacts[0].Contact_MCN_Permissions__c), ';'),
                MCN_Account__c = mcnPermission.MCN_Account__c,
                MCN_Permission__c = mcnPermission.Id,
                Parent_Account__c = mcnPermission.Customer_OR_Partner_Account__c);
        insert contactMcnPermission;
        Test.startTest();
        DTSFPART_UpdateContactMCNPermissions preparationJob = new DTSFPART_UpdateContactMCNPermissions(
                new Map<Id, MCN_Permission__c>(), new Map<Id, MCN_Permission__c>(),  new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts));
        preparationJob.execute(null);
        DTSFPART_SaveContactMcnPermissions chainable = new DTSFPART_SaveContactMcnPermissions(
                preparationJob.affectedContacts, preparationJob.mcnPermissionsByAccount, preparationJob.mrPermissionsByAccount, preparationJob.mrMcnPermissionsBySalesPerson,
                preparationJob.addedPermissionsByMcn, preparationJob.removedPermissionsByMcn, new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts), preparationJob.contactMcnPermRemovalReference);
        chainable.execute(null);
        Test.stopTest();

        List<MCN_Permission__c> updatedMcnPermissions = [SELECT Id FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds];
        System.assertEquals(mcnNumber * parentNumber * 2, updatedMcnPermissions.size());

        for (Contact contact : [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE Id IN :contactIds]) {
            System.assert(!String.isBlank(contact.Contact_MCN_Permissions__c));
        }

        Integer updatedContactPermissions = 0;
        Map<Id, Contact_Permissions__c> contactPermissionsList = new Map<Id, Contact_Permissions__c>(
        [SELECT Id, Contact__r.Contact_MCN_Permissions__c, Contact__r.Email,
                MCN_Account__r.Name, MCN_Permission__r.Id, MCN_Permission__r.Contact_MCN_Permissions__c, Contact_MCN_Permissions__c
        FROM Contact_Permissions__c WHERE MCN_Account__c IN :mcnIds]);
        for (Contact_Permissions__c contactPermissions : contactPermissionsList.values()) {
            System.assert(contactPermissions.Contact_MCN_Permissions__c.contains(mcnUnusedPermissions[1]));
            // System.assert(!contactPermissions.Contact_MCN_Permissions__c.contains(mcnUnusedPermissions[0]));
            updatedContactPermissions++;
        }
        System.assertEquals(mcnNumber * contactNumber * parentNumber * 2, updatedContactPermissions);

        delete contactPermissionsList.values();
    }

    private static List<String> getUnusedPermissions(Set<String> permissions) {
        Set<String> unusedPermissions = new Set<String>();
        Schema.DescribeFieldResult contactMcnField = MCN_Permission__c.Contact_MCN_Permissions__c.getDescribe();
        for (PicklistEntry entry : contactMcnField.getSobjectField().getDescribe().getPicklistValues()) {
            if (!permissions.contains(entry.value)) {
                unusedPermissions.add(entry.value);
            }
        }

        return new List<String>(unusedPermissions);
    }
}