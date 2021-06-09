/**
 * @author       Sagar Sindhi
 * @created      2020-09-24
 * @updated      2020-10-15
 * @isTesting	 EmailMessagingClass
 */
@isTest
public class EmailMessagingClass_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        List<Account> partnerAccounts = TestDataSetUpUtils.createAccounts(1, partnerRecordType);
        DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), true);
        List<MPEContact__c> mpeContacts = DTSFPART_TestDataSetUpUtils.createMPEContacts(2, partnerAccounts, false);
        mpeContacts.get(1).Email__c = 'sampletest@test.com';
        insert mpeContacts;

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // Run as current user to to avoid Mixed DML error
        System.runAs(thisUser) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Test Template';
            validEmailTemplate.DeveloperName = 'Test_Template';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
            System.assert(String.isNotEmpty(validEmailTemplate.FolderId));
        }
    }

    @isTest
    public static void testEmail_Method() {
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact];
        List<MPEContact__c> mpeContactsList = [
            SELECT Id, Account__c, Email__c
            FROM MPEContact__c
        ];
        List<EmailTemplate> templates = [
            SELECT Id
            FROM EmailTemplate
            WHERE Name = 'Test Template'
        ];

        List<Id> contactIds = new List<Id> ();
        Test.startTest();
        for (Contact eachContact: contacts) {
            contactIds.add(eachContact.Id);
        }
        Map<Id, List<Id>> objMappingMap = new Map<Id, List<Id>> {
            contacts.get(0).AccountId => contactIds
        };
        System.assertEquals(contacts.get(0).AccountId, mpeContactsList.get(0).Account__c);
        EmailMessagingClass.sendEmailMessage(
            contactIds,
            templates.get(0).Id,
            mpeContactsList,
            false,
            null,
            objMappingMap,
            'Account__c',
            true,
            null
        );
        Test.stopTest();
    }
}