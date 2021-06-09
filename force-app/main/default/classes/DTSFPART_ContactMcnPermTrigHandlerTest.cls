/**
 * Created by QGBC67 on 18.01.2021.
 */

@IsTest
public with sharing class DTSFPART_ContactMcnPermTrigHandlerTest {
    @TestSetup
    private static void testSetup(){
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
        Account parentAccount = DTSFPART_TestDataSetUpUtils.createAccounts(1, partnerRecordTypeId)[0];
        Partner_Type__c partnerType =  new Partner_Type__c(
                Account__c = parentAccount.Id,
                Program__c = 'RADIO',
                Status__c = 'Active',
                Purchasing_Method__c = 'Tier 16',
                US_Federal__c = true,
                RHO__c = true
        );
        insert partnerType;
        Technology_Specialization__c programDetail = new Technology_Specialization__c(
                Community_Type__c = 'Service Partner',
                Account__c = parentAccount.Id,
                Partner_Program__c = partnerType.Id);
        insert programDetail;

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccounts = DTSFPART_TestDataSetUpUtils.createMCNAccounts(2, mcnRecordTypeId, new List<Account>{parentAccount}, true);
        Default_Communities_Permissions__mdt meta = [SELECT Id, Contact_Mcn_Permissions__c FROM Default_Communities_Permissions__mdt WHERE Community_Type__c = :programDetail.Community_Type__c AND Type__c = 'Program Details'];
        List<MCN_Permission__c> mcnPermissions = DTSFPART_TestDataSetUpUtils.createMcnPermissions(mcnAccounts, meta.Contact_Mcn_Permissions__c, true);

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = new List<Contact>();
        for(Contact contact: DTSFPART_TestDataSetUpUtils.createContacts(2, contactRecordTypeId, new List<Account>{parentAccount})){
            contact.Persona__c = 'OwnerExecutive';
            contact.Status__c = 'Completed';
            contacts.add(contact);
        }

        MCN_Permission__c mcnPermission = [SELECT Id, MCN_Account__c, Contact_MCN_Permissions__c, Customer_OR_Partner_Account__c FROM MCN_Permission__c WHERE MCN_Account__r.Name = 'TestMCN0'];

        insert new Contact_Permissions__c(
                Contact__c = contacts[0].Id,
                Contact_MCN_Permissions__c = String.join((Iterable<String>)
                        DTSFPART_PermissionUtils.calculateIntersection(
                                mcnPermission.Contact_MCN_Permissions__c,
                                contacts[0].Contact_MCN_Permissions__c), ';'),
                MCN_Account__c = mcnPermission.MCN_Account__c,
                MCN_Permission__c = mcnPermission.Id,
                Parent_Account__c = mcnPermission.Customer_OR_Partner_Account__c);

        update contacts;

        parentAccount.Enterprise_Permission_Status__c = 'Completed';
        update parentAccount;
    }

    @IsTest
    static void createContactMcnPermission() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        Contact contact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE AccountId = :parentAccount.Id AND Email LIKE 'TestLname%@gmail.com' LIMIT 1];
        Account mcnAccount = [SELECT Id FROM Account WHERE ParentId = :parentAccount.Id AND Name = 'TestMCN1'];
        MCN_Permission__c mcnPermission = [SELECT Id, Contact_MCN_Permissions__c, MCN_Account__c, Customer_OR_Partner_Account__c FROM MCN_Permission__c WHERE MCN_Account__c = :mcnAccount.Id][0];

        Test.startTest();
        insert new Contact_Permissions__c(
                Contact__c = contact.Id,
                Contact_MCN_Permissions__c = String.join((Iterable<String>)
                        DTSFPART_PermissionUtils.calculateIntersection(
                                mcnPermission.Contact_MCN_Permissions__c,
                                contact.Contact_MCN_Permissions__c), ';'),
                MCN_Account__c = mcnPermission.MCN_Account__c,
                MCN_Permission__c = mcnPermission.Id,
                Parent_Account__c = mcnPermission.Customer_OR_Partner_Account__c);
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :contact.Id];

        System.assertNotEquals('Completed', updatedContact.Enterprise_Permission_Status__c);
    }

    @IsTest
    static void updateContactMcnPermission() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        Contact contact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE AccountId = :parentAccount.Id AND Email LIKE 'TestLname%@gmail.com' LIMIT 1];
        Account mcnAccount = [SELECT Id FROM Account WHERE ParentId = :parentAccount.Id AND Name = 'TestMCN0'];
        Contact_Permissions__c contactMcnPermission = [SELECT Id, Contact_MCN_Permissions__c, MCN_Account__c, Parent_Account__c
        FROM Contact_Permissions__c WHERE Contact__c = :contact.Id AND MCN_Account__c = :mcnAccount.Id];

        contactMcnPermission.Contact_MCN_Permissions__c = '';

        Test.startTest();
        update contactMcnPermission;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :contact.Id];

        System.assertNotEquals('Completed', updatedContact.Enterprise_Permission_Status__c);
    }

    @IsTest
    static void deleteContactMcnPermission() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        Contact contact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE AccountId = :parentAccount.Id AND Email LIKE 'TestLname%@gmail.com' LIMIT 1];
        Account mcnAccount = [SELECT Id FROM Account WHERE ParentId = :parentAccount.Id AND Name = 'TestMCN0'];
        Contact_Permissions__c contactMcnPermission = [SELECT Id, Contact_MCN_Permissions__c, MCN_Account__c, Parent_Account__c
        FROM Contact_Permissions__c WHERE Contact__c = :contact.Id AND MCN_Account__c = :mcnAccount.Id];

        Test.startTest();
        delete contactMcnPermission;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :contact.Id];

        System.assertNotEquals('Completed', updatedContact.Enterprise_Permission_Status__c);
    }
}