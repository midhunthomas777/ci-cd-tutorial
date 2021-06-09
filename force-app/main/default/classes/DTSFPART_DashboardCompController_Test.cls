/**
 * Created by QGBC67 on 28.09.2020.
 */

@IsTest
public with sharing class DTSFPART_DashboardCompController_Test {
    @TestSetup
    static void setup() {
        TestDataSetUpUtils.insertCustomSettings();
        Id accountRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Account acc = TestDataSetUpUtils.createPartnerAccount(accountRecordTypeId);
        acc.Region__c = 'NA';
        acc.IsPartner = true;
        update acc;
        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{acc});
        contacts[0].Status__c = 'Active';
        contacts[0].Owner_Business_Group__c = 'Government';
        contacts[0].Persona__c = 'OwnerExecutive';
        update contacts;
        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            User user = DTSFPART_TestDataSetUpUtils.createPartnerPortalUser(contacts[0].Id, false);
            UserRole r = new UserRole();
            r.PortalType = 'Partner';
            r.PortalAccountId = acc.Id;
            insert r;
            user.UserRoleId = r.Id;
            insert user;
        }
        List<MPEContact__c> mpes = DTSFPART_TestDataSetUpUtils.createMPEContacts(2, new List<Account>{acc}, false);
        mpes[0].Primary_Role__c = 'Marketing';
        mpes[0].Status__c = 'Pending Registration';
        insert mpes;
    }
    
    @IsTest
    private static void getDashboardOpportunities() {
        Test.startTest();
        List<Opportunity> opportunities = DTSFPART_DashboardComponentsController.getDashboardOpportunities();
        Test.stopTest();
        for (Opportunity opp : opportunities) {
            System.assert(opp.Amount != null);
        }
    }

    @IsTest
    private static void getAllPartnersListViewId() {
        Test.startTest();
        ListView listView = DTSFPART_DashboardComponentsController.getAllPartnersListViewId();
        Test.stopTest();
        System.assert(listView != null);
    }

    @IsTest
    private static void getDashboardLeads() {
        Test.startTest();
        List<Lead> leads = DTSFPART_DashboardComponentsController.getDashboardLeads();
        Test.stopTest();
        for (Lead lead : leads) {
            System.assert(lead.Budget_Value__c != null);
        }
    }

    @IsTest
    private static void getDashboardUsers() {
        Test.startTest();
        List<MPEContact__c> mpes = DTSFPART_DashboardComponentsController.getDashboardUsers('Marketing');
        Test.stopTest();
        System.assertEquals(1, mpes.size());
    }

    @IsTest
    private static void getRolesForUsers() {
        Test.startTest();
        List<DTSFPART_DashboardComponentsController.LabelValueWrapper> labelValues = DTSFPART_DashboardComponentsController.getRolesForUsers();
        Test.stopTest();
        System.assert(labelValues != null);
    }

    @IsTest
    private static void getCurrentUserPersona() {
        User user = [SELECT Id FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        Test.startTest();
        String persona;
        System.runAs(user) {
            persona = DTSFPART_DashboardComponentsController.getCurrentUserPersona();
        }
        Test.stopTest();
        System.assert(persona != null, [SELECT Contact.Persona__c FROM User WHERE Contact.Persona__c = 'OwnerExecutive']);
    }

    @IsTest
    private static void getDefaultSettingsForCurrentPersona() {
        User user = [SELECT Id FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        Test.startTest();
        List<Dashboard_Setting__mdt> dSettings;
        System.runAs(user) {
             dSettings = DTSFPART_DashboardComponentsController.getDefaultSettingsForCurrentPersona('Partner Hub');
        }
        Test.stopTest();
        System.assert(dSettings != null);
    }

    @IsTest
    private static void getCurrentUserSettings() {
        User user = [SELECT Id, Contact.DTSFPART_Dashboard_Settings__c FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        user.Contact.DTSFPART_Dashboard_Settings__c = 'test value for testing purposes';
        update user.Contact;
        Test.startTest();
        String settings;
        System.runAs(user) {
            settings = DTSFPART_DashboardComponentsController.getCurrentUserSettings();
        }
        Test.stopTest();
        System.assertEquals(user.Contact.DTSFPART_Dashboard_Settings__c, settings);
    }

    @IsTest
    private static void saveCurrentUserSettings() {
        User user = [SELECT Id, Contact.Id FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        String settings = 'test value for testing purposes2';

        Test.startTest();
        System.runAs(user) {
            DTSFPART_DashboardComponentsController.saveCurrentUserSettings(settings);
        }
        Test.stopTest();
        Contact contact = [SELECT Id, DTSFPART_Dashboard_Settings__c FROM Contact WHERE Id = :user.Contact.Id];
        System.assertEquals(contact.DTSFPART_Dashboard_Settings__c, settings);
    }

    @IsTest
    private static void getDashboardUsersCounter() {
        User user = [SELECT Id, Contact.Id FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        Test.startTest();
        List<DTSFPART_DashboardComponentsController.LabelValueWrapper> labelValue;
        System.runAs(user) {
            labelValue = DTSFPART_DashboardComponentsController.getDashboardUsersCounter();
        }
        Test.stopTest();
        System.assert(labelValue != null);
    }

    @IsTest
    private static void getDashboardCases() {
        User user = [SELECT Id, Contact.Id FROM User WHERE Contact.Persona__c = 'OwnerExecutive'];
        Test.startTest();
        List<DTSFPART_DashboardComponentsController.CasesWrapper> cases;
        System.runAs(user) {
            cases = DTSFPART_DashboardComponentsController.getDashboardCases();
        }
        Test.stopTest();
        System.assert(cases != null);
    }
}