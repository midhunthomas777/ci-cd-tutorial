/**
 * @author		Paweł Woźniak
 * @created		2020-07-27
 * @updated		2020-09-21
 * @isTesting	DTSFPART_ContactTriggerHandler
 * @description	Test for trigger class
 */

@IsTest
private class DTSFPART_ContactTriggerHandler_Test {

    public static final String REGISTRATION_COMPLETED = 'Registration Completed';

    @TestSetup
    static void setup() {
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.currentuserSetting();
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
        acc.Partner_Hub_Enabled__c = true;
        update acc;
        
        Id mcnAccountId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccount =
                DTSFPART_TestDataSetUpUtils.createMCNAccounts(1, mcnAccountId,
                        new List<Account>{acc}, true);
        Contact contact = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        contact.FirstName = 'Test';
        contact.LastName = 'setup';
        contact.Email = 'setup@test.test';
        contact.Persona__c = 'OwnerExecutive';
        insert contact;
        contact.C360_Response__c = 'some response from C360';
        contact.Enterprise_Permission_Status__c = 'Completed';
        update contact;
    }

    @IsTest
    static void clearC360Response() {
        Contact contact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Email = 'setup@test.test'];
        Test.startTest();
        contact.Enterprise_Permission_Status__c = 'In Progress';
        update contact;
        Test.stopTest();
        Contact contactAfterInsert = [
                SELECT Id, C360_Response__c
                FROM Contact
                WHERE Id = :contact.Id
        ];
        System.debug(contactAfterInsert.C360_Response__c);
        System.assert(String.isEmpty(contactAfterInsert.C360_Response__c));
    }

    @IsTest
    static void handleC360ErrorResponse() {
        Contact contact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Email = 'setup@test.test'];
        Test.startTest();
        contact.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.RESYNC;
        contact.C360_Response__c = '{status: 500}';
        update contact;
        Test.stopTest();
        Contact contactAfterUpdate = [
                SELECT Id, C360_Response__c, Enterprise_Permission_Status__c
                FROM Contact
                WHERE Id = :contact.Id
        ];
        System.assertEquals(contact.C360_Response__c, contactAfterUpdate.C360_Response__c, 'C360 responses are not the same');
        System.assertEquals(DTSFPART_CommonStrings.ERROR, contactAfterUpdate.Enterprise_Permission_Status__c, 'Expected value for Enterprise Permission Status is Error');
    }

    @IsTest
    static void setPartnerDefaultPermissions() {
        Id partnerRT = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :partnerRT LIMIT 1];
        
        Test.startTest();
            // With filled in Persona
            Contact cnt2 = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
            cnt2.FirstName = 'Test';
            cnt2.LastName = 'setPartnerDefaultPermissions';
            cnt2.Email = 'setPartnerDefaultPermissions@test.test';
            cnt2.Persona__c = 'SalesManager';
            cnt2.Status__c = 'Active';
            insert cnt2;

        Test.stopTest();

        // Inserted with Persona - expecting values set
        Contact cnt2AfterInsert = [
                SELECT Id, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c, Tag__c
                FROM Contact
                WHERE Id = :cnt2.Id
        ];

        System.assert (String.isNotEmpty(cnt2AfterInsert.Contact_MCN_Permissions__c), 'Expected value for Contact_MCN_Permissions__c');
        System.assert (String.isNotEmpty(cnt2AfterInsert.Contact_level_Internal_permissions__c), 'Expected value for Contact_level_Internal_permissions__c');
        System.assert (String.isNotEmpty(cnt2AfterInsert.Tag__c), 'Expected value for Contact_level_Internal_permissions__c');

    }

    @IsTest
    static void createContact() {
        Id partnerRT = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Id mcnRT = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :partnerRT LIMIT 1];
        List<Account> mcnAccounts = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND RecordTypeId = :mcnRT];
        
        Test.startTest();
        Contact contact = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        contact.FirstName = 'Test';
        contact.LastName = 'createContactMcnPermissions';
        contact.Email = 'createContactMcnPermissions@test.test';
        contact.Persona__c = 'OwnerExecutive';
        contact.Status__c = 'Active';
        insert contact;
        Test.stopTest();
        Contact contactAfterInsert = [
                SELECT Id, Contact_MCN_Permissions__c
                FROM Contact
                WHERE Id = :contact.Id
                LIMIT 1
        ];
        Default_Communities_Permissions__mdt permisions = [
                SELECT Community_Type__c, Contact_Mcn_Permissions__c, Mcn_Permissions__c
                FROM Default_Communities_Permissions__mdt
                WHERE Persona__c = 'OwnerExecutive' AND Community_Type__c = 'Value Added Reseller'
        ];
        System.assert(compareCsv(contactAfterInsert.Contact_MCN_Permissions__c, permisions.Contact_MCN_Permissions__c), 'Expected: ' + permisions.Contact_MCN_Permissions__c + ' Actual: ' +  contactAfterInsert.Contact_MCN_Permissions__c);
    }

    static Boolean compareCsv(String expected, String actual) {
        System.debug('csv====>' + expected);
        System.debug('csv====>' + actual);
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
    
    @IsTest
    static void performAdminApprovalAction() {
        List<Account> partnerAccounts = [Select Id, Name from Account LIMIT 1];
        List<MPEContact__c> mpeContacts = DTSFPART_TestDataSetUpUtils.createMPEContacts(1, partnerAccounts, true);
        
        Test.startTest();
        Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), false);
        contactRecord.Email = 'testcontact@mail.com';
        contactRecord.MPE_ContactId__c = mpeContacts.get(0).Id;
        contactRecord.Persona__c = 'SalesManager';
        insert contactRecord;

        contactRecord.Enterprise_Permission_Status__c = 'Completed';
        contactRecord.Status__c = REGISTRATION_COMPLETED;
        update contactRecord;
        Test.stopTest();
        System.assert(!mpeContacts.isEmpty());
    }

    @IsTest
    static void set_StatusRegCompleted() {
        List<Account> partnerAccounts = [Select Id, Name from Account LIMIT 1];
        List<User> muleSoftUser = [Select Id from user where name = 'Mulesoft Integration' LIMIT 1];

        Test.startTest();
        Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0),false);
        contactRecord.Email = 'testcontact@mail.com';
        contactRecord.Status__c = 'Invited';
        contactRecord.Persona__c = 'SalesManager';
        insert contactRecord;
        System.assertEquals('Invited', contactRecord.Status__c);
        if(!muleSoftUser.isEmpty()) {
            System.runAs(muleSoftUser.get(0)) {  
                contactRecord.Enterprise_Permission_Status__c = 'Completed';
        		contactRecord.Status__c = REGISTRATION_COMPLETED;
                update contactRecord;
            }
        }
        Test.stopTest();
        System.assertEquals(REGISTRATION_COMPLETED, contactRecord.Status__c);
    }

    @IsTest
    static void synTimeoutNotification() {
        List<Account> partnerAccounts = [Select Id, Name from Account LIMIT 1];
        partnerAccounts.get(0).Enterprise_Permission_Status__c = 'Completed';
        update partnerAccounts;
        
        Test.startTest();
        Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0),false);
        contactRecord.Email = 'testcontactnew_user@mail.com';
        contactRecord.Status__c = 'Invited';
        contactRecord.Persona__c = 'SalesManager';
        insert contactRecord;
        
        contactRecord.Status__c = 'Active';
        contactRecord.Enterprise_Permission_Status__c = 'Completed';
		update contactRecord;
        
        contactRecord.Enterprise_Permission_Status__c = 'In Progress';
        update contactRecord;
        System.assertEquals('Active', contactRecord.Status__c);
        Test.stopTest();
    }
}