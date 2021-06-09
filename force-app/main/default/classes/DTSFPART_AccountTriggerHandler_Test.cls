/**
 * Created by QGBC67 on 30.07.2020.
 */
@IsTest
public with sharing class DTSFPART_AccountTriggerHandler_Test {

    @TestSetup
    private static void setup() {
        AccountTriggerHandler.TriggerDisabled = true;
        Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Id customerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();

        List<Account> partnerAccounts = new List<Account>();
        for(Account partnerAccount: DTSFPART_TestDataSetUpUtils.createAccounts(2, partnerRecordTypeId)){
                partnerAccount.MPE_Program_Status_New__c = 'Active';
                partnerAccount.Partner_Hub_Enabled__c = true;
                partnerAccounts.add(partnerAccount);
        }
        update partnerAccounts;
        List<Account> customerAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(1, customerRecordTypeId);
        customerAccounts[0].Name = 'TestCustomerAccount';
        update  customerAccounts;
        DTSFPART_TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, partnerAccounts, true);

        Account mcnAccount = new Account(
                Name = 'TestMCN',
                RecordTypeId = mcnRecordTypeId,
                parentid = customerAccounts[0].id,
                Customer_or_Prospect_Account__c = customerAccounts[0].id,
                Motorola_Customer_Number__c = string.valueof(integer.valueof(math.random() * 100000000)) + '00',
                ShippingCountry = 'United States',
                ShippingState = 'Illinois',
                ERP_Active__c = true,
                Primary_Route_to_Market__c = 'MR Led',
                Enterprise_Permission_Status__c = 'Completed',
                Assigned_MR__c = partnerAccounts[1].Id
        );
        insert mcnAccount;

        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c>();
        partnerTypes.add(new Partner_Type__c(
                Account__c = partnerAccounts[0].Id,
                Program__c = 'RADIO',
                Status__c = 'Active',
                Purchasing_Method__c = 'Tier 16',
                US_Federal__c = true,
                RHO__c = true
        ));
        partnerTypes.add(new Partner_Type__c(
                Account__c = partnerAccounts[1].Id,
                Program__c = 'RADIO',
                Status__c = 'Active',
                Purchasing_Method__c = 'Tier 16',
                US_Federal__c = true,
                RHO__c = true
        ));
        insert partnerTypes;

        List<Technology_Specialization__c> prds = new List<Technology_Specialization__c>();
        prds.add(new Technology_Specialization__c(
                Community_Type__c = 'Value Added Reseller',
                Account__c = partnerAccounts[1].Id,
                Partner_Program__c = partnerTypes[1].Id,
                Technology_Specialization__c = 'Mission Critical Radio Systems', //'Unlicensed Radio',
                Technology_Specialization_Status__c = 'Active'
        ));
        prds.add(new Technology_Specialization__c(
                Community_Type__c = 'Federal Manufacturer Representative',
                Account__c = partnerAccounts[0].Id,
                Partner_Program__c = partnerTypes[0].Id,
                Technology_Specialization__c = 'Mission Critical Radio Systems', //'Unlicensed Radio',
                Technology_Specialization_Status__c = 'Active'
        ));

        insert prds;
    }
    @IsTest
    private static void createMcn() {
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

        Test.startTest();
        List<Account> mcnAccounts = DTSFPART_TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, new List<Account>{
                partnerAccount
        }, true);
        Test.stopTest();

        Account testMCN = [SELECT Id, ParentId FROM Account WHERE Id = :mcnAccounts[0].Id];
        Technology_Specialization__c prd = [
                SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :testMCN.ParentId
        ];

        MCN_Permission__c mcnPermission = [
                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE MCN_Account__c = :testMCN.Id
        ];

        System.assert(compareCsv(prd.Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c), 'Contact MCN Permissions are incorrect');
        System.assert(compareCsv(prd.MCN_Permissions__c, mcnPermission.MCN_Permissions__c), 'MCN Permissions are incorrect');
    }

    @IsTest
    private static void createMrMcn() {
        Id CustomerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
        Account customerAccount = [SELECT Id FROM Account WHERE RecordTypeId = :CustomerRecordTypeId];
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];
        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

        Test.startTest();
        Account mcnAccount = new Account(
                Name = 'TestMCN',
                RecordTypeId = mcnRecordTypeId,
                parentid = customerAccount.id,
                Customer_or_Prospect_Account__c = customerAccount.id,
                Motorola_Customer_Number__c = string.valueof(integer.valueof(math.random() * 100000000)) + '00',
                ShippingCountry = 'United States',
                ShippingState = 'Illinois',
                ERP_Active__c = true,
                Primary_Route_to_Market__c = 'MR Led',
                Enterprise_Permission_Status__c = 'Completed',
                Assigned_MR__c = partnerAccount.Id
        );
        insert mcnAccount;
        Test.stopTest();

        Account testMCN = [SELECT Id, ParentId, Assigned_MR__c FROM Account WHERE Id = :mcnAccount.Id];
        Technology_Specialization__c prd = [
                SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :testMCN.Assigned_MR__c
        ];

        MCN_Permission__c mcnPermission = [
                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c, Association_Type__c
                FROM MCN_Permission__c
                WHERE MCN_Account__c = :testMCN.Id AND Customer_OR_Partner_Account__c = :testMCN.Assigned_MR__c
        ];

        System.assert(compareCsv(prd.Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c), 'Contact MCN Permissions are incorrect');
        System.assert(compareCsv(prd.MCN_Permissions__c, mcnPermission.MCN_Permissions__c), 'MCN Permissions are incorrect');
    }

    @IsTest
    private static void changeAccount() {
        Account oldAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1'];

        Test.startTest();
        Account mcn = [
                SELECT Id, ParentId
                FROM Account
                WHERE ParentId = :oldAccount.Id
        ];
        mcn.ParentId = newAccount.Id;
        update mcn;
        Test.stopTest();

        Technology_Specialization__c prd = [
                SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :newAccount.Id
        ];

        MCN_Permission__c mcnPermission = [
                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE MCN_Account__c = :mcn.Id
        ];

        Account mcnAccount = [SELECT Id, ParentId FROM Account WHERE Id = :mcn.Id];

        System.assertEquals(newAccount.Id, mcnAccount.ParentId);
        System.assert(compareCsv(prd.Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c));
        System.assert(compareCsv(prd.MCN_Permissions__c, mcnPermission.MCN_Permissions__c));

    }

    @IsTest
    private static void changeMrAccount() {
        Account oldAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];

        Test.startTest();
        Account mcn = [
                SELECT Id, Assigned_MR__c
                FROM Account
                WHERE Assigned_MR__c = :oldAccount.Id
        ];
        mcn.Assigned_MR__c = newAccount.Id;
        update mcn;
        Test.stopTest();

        Technology_Specialization__c prd = [
                SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c
                FROM Technology_Specialization__c
                WHERE Account__c = :newAccount.Id
        ];

        MCN_Permission__c mcnPermission = [
                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c
                FROM MCN_Permission__c
                WHERE MCN_Account__c = :mcn.Id AND Customer_OR_Partner_Account__c = :newAccount.Id
        ]; // will get 2 MCN Permissions for Partner and Customer

        Account mcnAccount = [SELECT Id, Assigned_MR__c FROM Account WHERE Id = :mcn.Id];

        System.assertEquals(newAccount.Id, mcnAccount.Assigned_MR__c);
        System.assert(compareCsv(prd.Contact_Mcn_Permissions__c, mcnPermission.Contact_MCN_Permissions__c));
        System.assert(compareCsv(prd.MCN_Permissions__c, mcnPermission.MCN_Permissions__c));

    }
    
    @IsTest
    private static void updateContacts() {
        Test.startTest();
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];
        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(newAccount, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Status__c = 'Pending Onboarding';
        insert cnt;

        Account acc = [
                SELECT Id, Enterprise_Permission_Status__c
                FROM Account
                WHERE Id = :newAccount.Id
        ];
        acc.Enterprise_Permission_Status__c = 'Completed';
        update acc;
        Test.stopTest();
        System.assertEquals(acc.Enterprise_Permission_Status__c, 'Completed');
    }

    static Boolean compareCsv(String expected, String actual) {
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
    static void synTimeoutNotification() {
        List<Account> newAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];
        newAccount.get(0).Enterprise_Permission_Status__c = 'Completed';
        update newAccount;
        
        Test.startTest();
        Contact contactRecord = DTSFPART_TestDataSetUpUtils.createPartnerContact(newAccount.get(0),false);
        contactRecord.Email = 'contact_test_newUsr@mail.com';
        insert contactRecord;
        
        newAccount.get(0).Enterprise_Permission_Status__c = 'In Progress';
        update newAccount;
        System.assertEquals('In Progress', newAccount.get(0).Enterprise_Permission_Status__c);
        Test.stopTest();
    }
    
    @isTest
    private static void test_clearOldErrorMessage() {
        Account newAccount = [SELECT Id, Enterprise_Permission_Status__c, C360_Response__c FROM Account WHERE Name = 'Test Account0'];
        newAccount.Enterprise_Permission_Status__c = 'Completed';
        newAccount.C360_Response__c = '{"status": 200"}';
        update newAccount;

        newAccount = [SELECT Id, Enterprise_Permission_Status__c, C360_Response__c FROM Account WHERE Name = 'Test Account0'];
        System.assertEquals('{"status": 200"}', newAccount.C360_Response__c, 'Should contains fake response');

        Test.startTest();
        newAccount.Enterprise_Permission_Status__c = 'In Progress';
        update newAccount;

        newAccount = [SELECT Id, Enterprise_Permission_Status__c, C360_Response__c FROM Account WHERE Name = 'Test Account0'];
        System.assert(String.isBlank(newAccount.C360_Response__c), 'Should be cleared by trigger');

        Test.stopTest();


    }

    @isTest
    private static void handleC360ErrorResponse() {
        Account acc = [SELECT Id, Enterprise_Permission_Status__c, C360_Response__c FROM Account WHERE Name = 'Test Account0'];
        
        Test.startTest();
        acc.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.RESYNC;
        acc.C360_Response__c = '{"status": 500"}';
        update acc;
        Test.stopTest();

        Account accountAfterUpdate = [SELECT Id, Enterprise_Permission_Status__c, C360_Response__c FROM Account WHERE Name = 'Test Account0'];
        System.assertEquals(acc.C360_Response__c, accountAfterUpdate.C360_Response__c, 'C360 responses are not the same');
        System.assertEquals(DTSFPART_CommonStrings.ERROR, accountAfterUpdate.Enterprise_Permission_Status__c, 'Expected value for Enterprise Permission Status is Error');
    }
    
}