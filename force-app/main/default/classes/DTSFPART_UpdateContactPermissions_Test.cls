/**
 * Created by QGBC67 on 19.11.2020.
 */

@IsTest
public with sharing class DTSFPART_UpdateContactPermissions_Test {

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
        for(Account account: parentAccounts) {
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
        for(Integer i = 0; i < parentAccounts.size(); i++) {
            programDetails.add(new Technology_Specialization__c(
                    Community_Type__c = 'Service Partner',
                    Account__c = parentAccounts[i].Id,
                    Partner_Program__c = partnerTypes[i].Id
            ));
        }
        insert programDetails;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = new List<Contact>();
        for(Contact contact: DTSFPART_TestDataSetUpUtils.createContacts(contactNumber, contactRecordTypeId, parentAccounts)){
            contact.Persona__c = 'OwnerExecutive';
            contact.Status__c = 'Active';
            contacts.add(contact);
        }
        update contacts;

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
        DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);
    }

    @IsTest
    static void changeProgramDetailPermissions(){
        Account  parentAccount = [SELECT Id FROM Account WHERE Name LIKE 'Test Account0'];
        List<Technology_Specialization__c> oldProgramDetails = [SELECT Id, Account__c, Community_Type__c  FROM Technology_Specialization__c WHERE Account__c = :parentAccount.Id];
        List<Technology_Specialization__c> newProgramDetails = oldProgramDetails.deepClone(true);
        newProgramDetails[0].Community_Type__c = 'Value Added Reseller';
        update newProgramDetails;
        Test.startTest();
        DTSFPART_UpdateContactPermissions job = new DTSFPART_UpdateContactPermissions(
                new Map<Id, Technology_Specialization__c>(newProgramDetails),
                new Map<Id, Technology_Specialization__c>(oldProgramDetails));
        job.execute(null);
        Test.stopTest();
        List<Account> parentAccountTest = [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Id = :parentAccount.Id];
    }

    static Boolean compareCsv(String expected, String actual) {
        System.debug('expected csv=>' + expected);
        System.debug('actual csv=>' + actual);
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