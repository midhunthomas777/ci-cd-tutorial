/**
 * @author		Paweł Woźniak
 * @created		2020-09-08
 * @updated		2020-10-16
 * @isTesting	DTSFPART_LWC_PermissionPicklists
 * @description
 */

@IsTest
public class DTSFPART_LWC_PermissionPicklists_Test {

    @TestSetup
    static void setup() {
        TestDataSetUpUtils.insertCustomSettings();
        DTSFPART_AccountTriggerHandler.TriggerDisabled = true;

        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
        Contact cnt2 = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt2.Persona__c = 'SalesManager';
        insert cnt2;

        // MCN Account
        Id mcnAccountRTId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        Account mcnAcc = TestDataSetUpUtils.createMCNAccounts(1, mcnAccountRTId, new List<Account> {acc})[0];

        // MCN Permission
        MCN_Permission__c mcnperm = new MCN_Permission__c();
        mcnperm.MCN_Account__c = mcnAcc.Id;
        mcnperm.Customer_OR_Partner_Account__c = cnt2.AccountId;
        mcnperm.Contact_MCN_Permissions__c = 'OrderSubmission';
        mcnperm.MCN_Permissions__c = 'Ecommerce';
        mcnperm.Enterprise_MCN_Unique__c = cnt2.AccountId+'#'+mcnAcc.Id;
        insert mcnperm;

        // Contact MCN Permission
        Contact_Permissions__c cp = new Contact_Permissions__c();
        cp.Contact__c = cnt2.Id;
        cp.MCN_Account__c = mcnAcc.Id;
        cp.Parent_Account__c = cnt2.AccountId;
        cp.MCN_Permission__c = mcnperm.Id;
        cp.Contact_MCN_Permissions__c = 'OrderSubmission';
        insert cp;
    }

    @IsTest
    private static void test_DTSFPART_LWC_PermissionPicklists () {
        List<Contact> cnts = [SELECT Id FROM Contact];
        System.assertEquals(1, cnts.size());
        List<Contact_Permissions__c> cp = [SELECT Id FROM Contact_Permissions__c WHERE Contact__c = :cnts[0].Id];

        DTSFPART_LWC_PermissionPicklists.AllowedPermValuesWrapper apvWrapper = DTSFPART_LWC_PermissionPicklists.contactMCNPermissions_AllowedPermissionValues(cp[0].Id);
        System.assertNotEquals(null, apvWrapper.MCNPermissionId);

    }

    @IsTest
    private static void test_DTSFPART_LWC_PermissionPicklists_ForInvalidContact () {
        Id invalidContactId = null;

        Test.startTest();
        DTSFPART_LWC_PermissionPicklists.AllowedPermValuesWrapper apvWrapper = DTSFPART_LWC_PermissionPicklists.contactMCNPermissions_AllowedPermissionValues(invalidContactId);
        Test.stopTest();

        System.assertEquals(null, apvWrapper);
    }

    @isTest
    private static void test_contact_AllowedPermissionValuesByPersona () {

        List<Contact> cnts = [SELECT Id FROM Contact];
        System.assertEquals(1, cnts.size());

        DTSFPART_LWC_PermissionPicklists.allowedPermValuesByPersonaWrapper apvWrapper = DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona(cnts[0].Id, 'SalesManager');
        System.assertEquals(false, apvWrapper.contactLevelInternalPermissions.isEmpty());
        System.assertEquals(false, apvWrapper.contactMCNPermissions.isEmpty());
        System.assertEquals(false, apvWrapper.tags.isEmpty());

    }
    @isTest
    private static void test_contact_AllowedPermissionValuesByPersona_ForInvalidPersonaAPIName () {
        List<Contact> cnts = [SELECT Id FROM Contact];
        String invalidAPIName = null;

        DTSFPART_LWC_PermissionPicklists.allowedPermValuesByPersonaWrapper apvWrapper = DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona(cnts[0].Id, invalidAPIName);
        System.assertEquals(null, apvWrapper);
    }

    @isTest
    private static void getParentAccountIdBasedOnContactIdTest() {

        List<Contact> cnts = [SELECT Id FROM Contact];
        System.assertEquals(1, cnts.size());

        String accountParentId = DTSFPART_LWC_PermissionPicklists.getParentAccountIdBasedOnContactId(cnts[0].Id);
        System.assertNotEquals(null, accountParentId);
    }

    @IsTest
    private static void test_getParentAccountIdBasedOnContactId_ForInvalidContact () {
        Id invalidContactId = null;
        String accountParentId;
        Test.startTest();
        try {
            accountParentId = DTSFPART_LWC_PermissionPicklists.getParentAccountIdBasedOnContactId(invalidContactId);
        } catch (Exception e) {
            System.assert(String.isNotBlank(e.getMessage()));
        }
        Test.stopTest();

        System.assertEquals(null, accountParentId);
    }

    @IsTest
    private static void test_doesUserHavePermission() {
        List<Contact> cnts = [SELECT Id FROM Contact];
        System.assertEquals(1, cnts.size());

        Test.startTest();
            DTSFPART_TestDataSetUpUtils.createPartnerUser(cnts.get(0), true);
        Test.stopTest();

        List<User> users = [SELECT Id FROM User WHERE contactId = :cnts[0].Id];
        System.assertEquals(1, users.size());

        User partnerUser = users[0];

        System.runAs(partnerUser) {
            boolean havePerm2 = DTSFPART_LWC_PermissionPicklists.doesUserHavePermission('OrderSubmission');
            System.assertEquals(true, havePerm2, 'User should have OrderSubmission permission');
        }
    }

    @IsTest
    private static void getParentAccountId(){
        Id mcnAccountRTId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcn = [SELECT Id, ParentId FROM Account WHERE RecordTypeId = :mcnAccountRTId LIMIT 1];

        System.assertEquals(mcn.get(0).ParentId, DTSFPART_LWC_PermissionPicklists.getParentAccountId(mcn.get(0).Id));
    }

    @IsTest
    private static void getContactPermissionDetail(){
        List<Contact> contact = [SELECT Id FROM Contact];
        List<Contact_Permissions__c> contactPermissions = [SELECT Id, Contact_MCN_Permissions__c
            FROM Contact_Permissions__c WHERE Contact__c = :contact.get(0).Id];

        System.assertEquals(contactPermissions.get(0).Contact_MCN_Permissions__c,
                DTSFPART_LWC_PermissionPicklists.getContactMcnPermissionsDetails(contactPermissions.get(0).Id).Contact_MCN_Permissions__c);

    }

    @IsTest
    private static void getParentAccountIdException(){
        Id mcnAccountRTId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

        Exception expException;
        try {
            DTSFPART_LWC_PermissionPicklists.getParentAccountId(mcnAccountRTId);
        } catch (AuraHandledException e){
            expException = e;
            System.assert(String.isNotBlank(e.getMessage()));
        }
        System.assert(expException != null);
    }

    @IsTest
    private static void getParentOnContactException(){
        Id mcnAccountRTId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

        Exception expException;
        try {
            DTSFPART_LWC_PermissionPicklists.getParentAccountIdBasedOnContactId(mcnAccountRTId);
        } catch (AuraHandledException e){
            expException = e;
            System.assert(String.isNotBlank(e.getMessage()));
        }
        System.assert(expException != null);
    }

    @IsTest
    private static void getContactPermissionDetailException(){
        List<Contact> contact = [SELECT Id FROM Contact];

        Exception expException;
        try {
            DTSFPART_LWC_PermissionPicklists.getContactMcnPermissionsDetails(contact.get(0).Id);
        } catch (AuraHandledException e){
            expException = e;
            System.assert(String.isNotBlank(e.getMessage()));
        }
        System.assert(expException != null);

    }

    @IsTest
    private static void allowedPermissionValuesByPersonaException(){
        Exception expException;
        try {
            DTSFPART_LWC_PermissionPicklists.contact_AllowedPermissionValuesByPersona(null, null);
        } catch (AuraHandledException e){
            expException = e;
        }
        System.assert(expException != null);

    }

}