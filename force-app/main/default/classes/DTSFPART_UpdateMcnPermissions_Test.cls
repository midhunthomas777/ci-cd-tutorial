/**
 * Created by QGBC67 on 20.11.2020.
 */

@IsTest
public with sharing class DTSFPART_UpdateMcnPermissions_Test {

    private static Integer parentNumber = 1;
    private static Integer contactNumber = 1;
    private static Integer mcnNumber = 1;

    @TestSetup
    private static void testSetup() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        List<TriggerSettings__c> triggerSettings = [
                SELECT Id, Name, IsActive__c
                FROM TriggerSettings__c
                WHERE Name IN ('CustomerAccountTriggerDisabled', 'McnPermissionsTriggerDisabled',
                        'ProgramDetailDisabled', 'ContactTriggerDisabled')
        ];
        for(TriggerSettings__c triggerSetting : triggerSettings) {
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
        for (Integer i = 0; i < parentAccounts.size(); i++) {
            programDetails.add(new Technology_Specialization__c(
                    Community_Type__c = 'Service Partner',
                    Account__c = parentAccounts[i].Id,
                    Partner_Program__c = partnerTypes[i].Id,
                    Contact_Mcn_Permissions__c = 'WarrantyClaims;WarrantyAndRepairSubmission'
            ));
        }
        insert programDetails;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : DTSFPART_TestDataSetUpUtils.createContacts(contactNumber, contactRecordTypeId, parentAccounts)) {
            contact.Persona__c = 'OwnerExecutive';
            contacts.add(contact);
        }
        update contacts;

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);
    }

    @IsTest
    static void createMcnPermissions() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account0'];
        List<Technology_Specialization__c> oldProgramDetails = [
                SELECT Id, Account__c, Community_Type__c, Technology_Specialization_Status__c, MCN_Permissions__c, Contact_Mcn_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :parentAccount.Id
        ];
        List<Technology_Specialization__c> newProgramDetails = oldProgramDetails.deepClone(true);
        //newProgramDetails[0].Community_Type__c = 'Value Added Reseller';
        newProgramDetails[0].Contact_Mcn_Permissions__c = 'OrderSubmission;BillingManagement;WarrantyClaims;WarrantyAndRepairSubmission';
        List<Contact> oldContacts = [
                SELECT Id, Persona__c, Contact_MCN_Permissions__c, Contact.AccountId
                FROM Contact
                WHERE AccountId = :parentAccount.Id
        ];
        List<Contact> newContacts = oldContacts.deepClone(true);
        update newProgramDetails;
        Account mcn = [SELECT Id FROM Account WHERE ParentId = :parentAccount.Id LIMIT 1];
        MCN_Permission__c mcnPerm = new MCN_Permission__c(
                MCN_Account__c = mcn.Id,
                Customer_OR_Partner_Account__c = parentAccount.Id,
                Contact_Mcn_Permissions__c = oldProgramDetails[0].Contact_Mcn_Permissions__c
        );
        //insert mcnPerm;
        Test.startTest();
        System.enqueueJob(new DTSFPART_UpdateMcnPermissions(
                new Map<Id, Technology_Specialization__c>(newProgramDetails), new Map<Id, Technology_Specialization__c>(oldProgramDetails),
                new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts)));
        Test.stopTest();
        List<Account> mcnAccounts = [
                SELECT Id, Assigned_MR__c, ParentId
                FROM Account
                WHERE ParentId = :parentAccount.Id OR Assigned_MR__c = :parentAccount.Id
        ];
        List<MCN_Permission__c> mcnPermissions = [
                SELECT Id, Parent_Account__c, MCN_Account__c, Contact_MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE Parent_Account__c = :parentAccount.Id
        ];

        System.assertEquals(mcnAccounts.size(), mcnPermissions.size());
        for(MCN_Permission__c mcnPermission : mcnPermissions) {
            System.assert(compareCsv(newProgramDetails[0].Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c));
        }
    }

    @IsTest
    static void updateMcnPermissions() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account0'];
        List<Technology_Specialization__c> oldProgramDetails = [
                SELECT Id, Account__c, Community_Type__c, Technology_Specialization_Status__c, MCN_Permissions__c, Contact_Mcn_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :parentAccount.Id
        ];
        List<Technology_Specialization__c> newProgramDetails = oldProgramDetails.deepClone(true);
        //newProgramDetails[0].Community_Type__c = 'Value Added Reseller';
        newProgramDetails[0].Contact_Mcn_Permissions__c = 'OrderSubmission;BillingManagement;WarrantyClaims;WarrantyAndRepairSubmission';
        List<Contact> oldContacts = [
                SELECT Id, Persona__c, Contact_MCN_Permissions__c, Contact.AccountId
                FROM Contact
                WHERE AccountId = :parentAccount.Id
        ];
        List<Contact> newContacts = oldContacts.deepClone(true);
        update newProgramDetails;
        Account mcn = [SELECT Id FROM Account WHERE ParentId = :parentAccount.Id LIMIT 1];
        MCN_Permission__c mcnPerm = new MCN_Permission__c(
                MCN_Account__c = mcn.Id,
                Customer_OR_Partner_Account__c = parentAccount.Id,
                Contact_Mcn_Permissions__c = oldProgramDetails[0].Contact_Mcn_Permissions__c
        );
        insert mcnPerm;
        Test.startTest();
        System.enqueueJob(new DTSFPART_UpdateMcnPermissions(
                new Map<Id, Technology_Specialization__c>(newProgramDetails), new Map<Id, Technology_Specialization__c>(oldProgramDetails),
                new Map<Id, Contact>(newContacts), new Map<Id, Contact>(oldContacts)));
        Test.stopTest();
        List<Account> mcnAccounts = [
                SELECT Id, Assigned_MR__c, ParentId
                FROM Account
                WHERE ParentId = :parentAccount.Id OR Assigned_MR__c = :parentAccount.Id
        ];
        List<MCN_Permission__c> mcnPermissions = [
                SELECT Id, Parent_Account__c, MCN_Account__c, Contact_MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE Parent_Account__c = :parentAccount.Id
        ];

        System.assertEquals(mcnAccounts.size(), mcnPermissions.size());
        for(MCN_Permission__c mcnPermission : mcnPermissions) {
            System.assert(compareCsv(newProgramDetails[0].Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c));
        }
    }

    static Boolean compareCsv(String expected, String actual) {
        System.debug('expected csv=>' + expected);
        System.debug('expected csv=>' + actual);
        if (expected != actual) {
            if (expected == null || actual == null) {
                return false;
            }
            List<String> exp = expected.split(';');
            List<String> act = actual.split(';');
            if (exp.size() != act.size()) return false;
            for (String item : act) {
                if (!exp.contains(item)) return false;
            }
        }
        return true;
    }
}