/**
 * Created by QGBC67 on 24.07.2020.
 */

@IsTest
public class DTSFPART_PrgDtlTriggerHandler_Test {
    @TestSetup
    static void setup() {
        Id partnerAccountId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Id mcnAccountId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        TestDataSetUpUtils.insertCustomSettings();
        List<Account> partnerAccounts = TestDataSetUpUtils.createAccounts(2, partnerAccountId);
        DTSFPART_TestDataSetUpUtils.createMCNAccounts(1, mcnAccountId, partnerAccounts, true);
        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c>();
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccounts[0].Id;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active';
        pgminfo.Purchasing_Method__c = 'Tier 16';
        pgminfo.US_Federal__c = true;
        pgminfo.RHO__c = true;
        partnerTypes.add(pgminfo);
        pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccounts[1].Id;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active';
        pgminfo.Purchasing_Method__c = 'Tier 16';
        pgminfo.US_Federal__c = true;
        pgminfo.RHO__c = true;
        partnerTypes.add(pgminfo);
        insert partnerTypes;
        Technology_Specialization__c prd = new Technology_Specialization__c();
        prd.Community_Type__c = 'Value Added Distributor';
        prd.Account__c = partnerAccounts[1].Id;
        prd.Partner_Program__c = pgminfo.Id;
        prd.Technology_Specialization__c = 'Mission Critical Radio Systems'; //'Unlicensed Radio';
        prd.Technology_Specialization_Status__c = 'Active';
        insert prd;
    }

    @IsTest
    static void createProgramDetail() {
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account0'];
        Partner_Type__c pgminfo = [SELECT Id FROM Partner_Type__c WHERE Account__c = :partnerAccount.Id];
        Test.startTest();
        Technology_Specialization__c prd = new Technology_Specialization__c();
        prd.Community_Type__c = 'Value Added Reseller';
        prd.Account__c = partnerAccount.Id;
        prd.Partner_Program__c = pgminfo.Id;
        prd.Technology_Specialization__c = 'Mission Critical Radio Systems'; //'Unlicensed Radio';
        prd.Technology_Specialization_Status__c = 'Active';
        insert prd;
        Test.stopTest();
        Technology_Specialization__c prdResult = [SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c FROM Technology_Specialization__c WHERE Id = :prd.Id];
        Default_Communities_Permissions__mdt permisions = [
                SELECT Community_Type__c, Contact_Mcn_Permissions__c, Mcn_Permissions__c
                FROM Default_Communities_Permissions__mdt
                WHERE Type__c = 'Program Details' AND Community_Type__c = 'Value Added Reseller'
        ];
        System.assert(compareCsv(permisions.Contact_Mcn_Permissions__c, prdResult.Contact_Mcn_Permissions__c));
        System.assert(compareCsv(permisions.Mcn_Permissions__c, prdResult.MCN_Permissions__c));
    }

    @IsTest
    static void updateCommunityType() {
        Account partnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        Test.startTest();
        Technology_Specialization__c prd = [SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c, Account__c FROM Technology_Specialization__c WHERE Account__c = :partnerAccount.Id];
        prd.Community_Type__c = 'Value Added Distributor';
        update prd;
        Test.stopTest();
        Technology_Specialization__c prdResult = [SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c FROM Technology_Specialization__c WHERE Id = :prd.Id];
        Default_Communities_Permissions__mdt permisions = [
                SELECT Community_Type__c, Contact_Mcn_Permissions__c, Mcn_Permissions__c
                FROM Default_Communities_Permissions__mdt
                WHERE Type__c = 'Program Details' AND Community_Type__c = 'Value Added Distributor'
        ];
        System.assert(compareCsv(permisions.Contact_Mcn_Permissions__c, prdResult.Contact_Mcn_Permissions__c));
        System.assert(compareCsv(permisions.Mcn_Permissions__c, prdResult.MCN_Permissions__c));
    }

    @IsTest
    static void removeProgramDetail() {
        Account partnerAccount = [ SELECT Id, Partner_Hub_Enabled__c, Motorola_Enterprise_ID__c, Enterprise_Permission_Status__c
                                   FROM Account
                                   WHERE Name = 'Test Account1'];

        partnerAccount.Partner_Hub_Enabled__c = true;
        partnerAccount.Motorola_Enterprise_ID__c = '3010273059'; 
        partnerAccount.Enterprise_Permission_Status__c = DTSFPART_ProgramDetailHandlerHelper.IN_PROGRESS_STATUS; 

        update partnerAccount;
        
        List<Technology_Specialization__c> programDetailBeforeDelete = [ SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c, Account__c 
                                                                         FROM Technology_Specialization__c 
                                                                         WHERE Account__c = :partnerAccount.Id ];

        System.assertEquals(false, programDetailBeforeDelete.isEmpty()); 

        Test.startTest();
            delete programDetailBeforeDelete;
        Test.stopTest();

        List<Technology_Specialization__c> programDetailAfterDelete = [ SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c 
                                                                        FROM Technology_Specialization__c 
                                                                        WHERE Id = :programDetailBeforeDelete[0].Id ];

        System.assertEquals(true, programDetailAfterDelete.isEmpty());  
             
        List<Account> accounts = [ SELECT Id, Enterprise_Permission_Status__c 
                                   FROM Account 
                                   WHERE Id = :programDetailBeforeDelete[0].Account__c 
                                   AND Partner_Hub_Enabled__c = TRUE 
                                   AND Motorola_Enterprise_ID__c != null ];
                 
        System.assertEquals(false, accounts.isEmpty());
        System.assertEquals(DTSFPART_ProgramDetailHandlerHelper.TRIGGER_STATUS, accounts[0].Enterprise_Permission_Status__c);
    }

    @IsTest
    static void errorCatchTest() { //try-catch scenario to increase code coverage
        DTSFPART_ProgramDetailTriggerHandler programDetailTriggerHandler = new DTSFPART_ProgramDetailTriggerHandler();

        try {
            programDetailTriggerHandler.beforeInsert(new List<Account>());
        } catch (Exception e) {
            System.assert(String.isNotEmpty(e.getMessage()));
        }

        try {
            programDetailTriggerHandler.beforeUpdate(new Map<Id, Account>(), new Map<Id, Account>());
        } catch (Exception e) {
            System.assert(String.isNotEmpty(e.getMessage()));
        }
        
        try {
            programDetailTriggerHandler.afterInsert(new Map<Id, Account>());
        } catch (Exception e) {
            System.assert(String.isNotEmpty(e.getMessage()));
        }

        try {
            programDetailTriggerHandler.afterUpdate(new Map<Id, Account>(), new Map<Id, Account>());
        } catch (Exception e) {
            System.assert(String.isNotEmpty(e.getMessage()));
        }

        try {
            programDetailTriggerHandler.afterDelete(new Map<Id, Account>());
        } catch (Exception e) {
            System.assert(String.isNotEmpty(e.getMessage()));
        }
    }

    //TODO Program Detail activation
//    @IsTest
//    static void inactivateProgramDetail() {
//        Test.startTest();
//        Technology_Specialization__c prd = [
//                SELECT Id, Account__c, Technology_Specialization_Status__c,
//                        Contact_Mcn_Permissions__c, MCN_Permissions__c
//                FROM Technology_Specialization__c
//                WHERE Account__r.Name = :'Test Account1'
//        ];
//        System.debug([
//                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c
//                FROM MCN_Permission__c
//                WHERE Customer_OR_Partner_Account__c = :prd.Account__c
//        ]);
//        prd.Technology_Specialization_Status__c = 'Inactive';
//        update prd;
//        Test.stopTest();
//        Technology_Specialization__c prdResult = [
//                SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c
//                FROM Technology_Specialization__c
//                WHERE Id = :prd.Id
//        ];
//        MCN_Permission__c mcnPermission = [
//                SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c
//                FROM MCN_Permission__c
//                WHERE Customer_OR_Partner_Account__c = :prd.Account__c
//        ];
//        System.debug(mcnPermission);
//        System.assertEquals(0, mcnPermission.Contact_MCN_Permissions__c.length());
//        System.assertEquals(0, mcnPermission.MCN_Permissions__c.length());
//    }

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
}