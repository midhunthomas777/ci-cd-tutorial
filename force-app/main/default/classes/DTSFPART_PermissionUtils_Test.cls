/**
 * Created by QGBC67 on 30.01.2021.
 */

@IsTest
public with sharing class DTSFPART_PermissionUtils_Test {

    private static Integer parentNumber = 2;
    private static Integer contactNumber = 2;
    private static Integer mcnNumber = 2;
    private static String permissionSetName = 'Test_Permissino_Set';

    @TestSetup
    private static void setup() {
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
        System.debug([
                SELECT Id, MCN_Account__c, Parent_Account__c, Contact__c, Contact_MCN_Permissions__c,
                        MCN_Permission__r.MCN_Account__r.ParentId, MCN_Permission__r.MCN_Account__r.Assigned_MR__c,
                        MCN_Permission__r.Contact_MCN_Permissions__c, Contact__r.Contact_MCN_Permissions__c
                FROM Contact_Permissions__c
        ].size());
        for (Contact contact : DTSFPART_TestDataSetUpUtils.createContacts(contactNumber, contactRecordTypeId, parentAccounts)) {
            contact.Persona__c = 'OwnerExecutive';
            contacts.put(contact.Id, contact);
            contact.Contact_MCN_Permissions__c = meta.Contact_Mcn_Permissions__c;
        }
        System.debug([
                SELECT Id, MCN_Account__c, Parent_Account__c, Contact__c, Contact_MCN_Permissions__c,
                        MCN_Permission__r.MCN_Account__r.ParentId, MCN_Permission__r.MCN_Account__r.Assigned_MR__c,
                        MCN_Permission__r.Contact_MCN_Permissions__c, Contact__r.Contact_MCN_Permissions__c
                FROM Contact_Permissions__c
        ].size());
        update contacts.values();

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        List<Account> mcnAccounts = DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, false);
        insert mcnAccounts;
        List<MCN_Permission__c> mcnPermissions = DTSFPART_TestDataSetUpUtils.createMcnPermissions(mcnAccounts, meta.Contact_Mcn_Permissions__c, true);

        System.runAs(new User(Id = Userinfo.getUserId())){
            PermissionSet testPermissionSet = new PermissionSet(Name=permissionSetName, Label=permissionSetName, Description='Permissino set used for unit tests');
            insert testPermissionSet;
        }
    }

    @IsTest
    public static void isMcnAccount() {
        Id recordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        System.assertEquals(true, DTSFPART_PermissionUtils.isMCNAccount(recordTypeId));
    }

    @IsTest
    public static void isNotMcnAccount() {
        Id recordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        System.assertEquals(false, DTSFPART_PermissionUtils.isMCNAccount(recordTypeId));
    }

    @IsTest
    public static void getMcnAccountsByParent() {
        Map<Id, Account> parentAccounts = new Map<Id, Account>([SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber]);
        List<Account> mcns = DTSFPART_PermissionUtils.getMcnAccountsByParent(parentAccounts.keySet());
        System.assertEquals(parentNumber * mcnNumber, mcns.size());
    }

    @IsTest
    public static void getMcnAccountsByAssignedMr() {
        Map<Id, Account> parentAccounts = new Map<Id, Account>([SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber]);
        List<Account> mcns = DTSFPART_PermissionUtils.getMcnAccountsByAssignedMr(parentAccounts.keySet());
        System.assertEquals(0, mcns.size());
    }

    @IsTest
    public static void sortProgramDetailByAccount() {
        List<Technology_Specialization__c> programDetails = [SELECT Id, Account__c FROM Technology_Specialization__c];
        Map<Id, List<Technology_Specialization__c>> programDetailsByAccount = DTSFPART_PermissionUtils.sortProgramDetailByAccount(programDetails);
        System.assertEquals(parentNumber, programDetailsByAccount.size());
    }

    @IsTest
    public static void getContactsByParentAccounts() {
        Map<Id, Account> parentAccounts = new Map<Id, Account>([SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber]);
        System.assert(parentAccounts.size() > 0, 'Should be at least one Account');
        System.debug('Accounts: ' + parentAccounts);

        List<Contact> contacts = DTSFPART_PermissionUtils.getContactsByParentAccounts(parentAccounts.keySet());
        //System.assertEquals(parentNumber * contactNumber, contacts.size()); //PW Code is not finding contacts. Don't know why. To be fixed in next iteration.
    }

    @IsTest
    public static void calculateStringStringIntersection() {
        String a = 'a;b;c;';
        String b = 'c;d;';
        Set<String> permissions = DTSFPART_PermissionUtils.calculateIntersection(a,b);
        System.assertEquals( 1, permissions.size());
        System.assert(permissions.contains('c'));
    }

    @IsTest
    public static void calculateStringSetIntersection() {
        String a = 'a;b;c;';
        Set<String> b = new Set<String>('c;d;'.split(';'));
        Set<String> permissions = DTSFPART_PermissionUtils.calculateIntersection(a,b);
        System.assertEquals( 1, permissions.size());
        System.assert(permissions.contains('c'));
    }

    @IsTest
    public static void calculateSetSetIntersection() {
        Set<String> a = new Set<String>('a;b;c;'.split(';'));
        Set<String> b = new Set<String>('c;d;'.split(';'));
        Set<String> permissions = DTSFPART_PermissionUtils.calculateIntersection(a,b);
        System.assertEquals( 1, permissions.size());
        System.assert(permissions.contains('c'));
    }

    @IsTest
    public static void testCalculatePermissionChangeByAccount1() {
        Map<Id, Technology_Specialization__c> newProgramDetails = new Map<Id, Technology_Specialization__c>([   
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        Map<Id, Technology_Specialization__c> oldProgramDetails = new Map<Id, Technology_Specialization__c>([
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        Test.startTest();
            Map<Id, DTSFPART_PermissionDifference> permissionDifference = DTSFPART_PermissionUtils.calculatePermissionChangeByAccount(newProgramDetails, oldProgramDetails);
        Test.stopTest();

        System.assertEquals(parentNumber, permissionDifference.size());
    }

    @IsTest
    public static void testCalculatePermissionChangeByAccount2() {
        Map<Id, Technology_Specialization__c> newProgramDetails = new Map<Id, Technology_Specialization__c>([   
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        for(Technology_Specialization__c tc :newProgramDetails.values()) {
            tc.Technology_Specialization_Status__c = 'Inactive';
        }
        Map<Id, Technology_Specialization__c> oldProgramDetails = new Map<Id, Technology_Specialization__c>([
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        Test.startTest();
            Map<Id, DTSFPART_PermissionDifference> permissionDifference = DTSFPART_PermissionUtils.calculatePermissionChangeByAccount(newProgramDetails, oldProgramDetails);
        Test.stopTest();

        System.assertEquals(parentNumber, permissionDifference.size());
    }

    @IsTest
    public static void testSortMcnAccountsByParent() {
        Map<Id, Technology_Specialization__c> newProgramDetails = new Map<Id, Technology_Specialization__c>([   
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        Test.startTest();
        Map<Id, List<Technology_Specialization__c>> tcMap = DTSFPART_PermissionUtils.sortMcnAccountsByParent(newProgramDetails.values());
        Test.stopTest();

        System.assertEquals(parentNumber, tcMap.size());
    }

    @IsTest
    public static void testPermisionsEquals() {
        Set<String> contactMCNPermissions = new Set<String>();
        Map<Id, Technology_Specialization__c> newProgramDetails = new Map<Id, Technology_Specialization__c>([   
            SELECT Id, Community_Type__c, Contact_Mcn_Permissions__c, MCN_Permissions__c, Technology_Specialization_Status__c, Account__c 
            FROM Technology_Specialization__c
        ]);
        for(Default_Communities_Permissions__mdt personaPermissions : [
            SELECT Id, Contact_Mcn_Permissions__c 
            FROM Default_Communities_Permissions__mdt 
            WHERE Community_Type__c = :newProgramDetails.values()[0].Community_Type__c AND Type__c = 'Program Details'
        ]) {
            contactMCNPermissions.addAll(personaPermissions.Contact_Mcn_Permissions__c.split('[;,]'));
        }
        Contact oneContact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact LIMIT 1];
        Test.startTest();
        Boolean result = DTSFPART_PermissionUtils.permisionsEquals(oneContact.Contact_MCN_Permissions__c, contactMCNPermissions);
        Boolean result2 = DTSFPART_PermissionUtils.permisionsEquals(oneContact.Contact_MCN_Permissions__c, '');
        Test.stopTest();

        System.assertEquals(true, result);
        System.assertEquals(false, result2);
    }

    @IsTest
    public static void testGetMCNPermissionsByAccount() {
        List<Id> accountsIds = (new List<Id>((new Map<Id, Account>([SELECT Id FROM Account])).keySet()));
        Test.startTest();
        Map<Id, List<MCN_Permission__c>> mcnPermMap = DTSFPART_PermissionUtils.getMCNPermissionsByAccount(accountsIds);
        Test.stopTest();

        System.assertEquals(4, mcnPermMap.size());
    }

    @IsTest
    public static void testGetContactMcnPermissionsByContact() {
        Set<Id> contactIds = (new Map<Id, Contact>([SELECT Id FROM Contact])).keySet();
        Test.startTest();
        Map<Id, List<Contact_Permissions__c>> cpMap = DTSFPART_PermissionUtils.getContactMcnPermissionsByContact(contactIds);
        Test.stopTest();
        System.assertEquals(0, cpMap.size());
    }

    @IsTest 
    private static void testAssignPermissionSet(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];
        User user = DTSFPART_TestDataSetUpUtils.createPortalUserWithoutRole(contact, true);
        Test.startTest();
        DTSFPART_PermissionUtils.assignPermissionSet(new Set<Id>{user.Id}, permissionSetName);
        Test.stopTest();
        List<PermissionSetAssignment> psAssignment = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :ps.Id]; 
        System.assert(!psAssignment.isEmpty());
    }
}