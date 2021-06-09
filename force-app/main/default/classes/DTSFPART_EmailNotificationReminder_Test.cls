/**
* @author       Sagar Sindhi
* @created      2020-09-29
* @updated      2020-12-30
* @isTesting    DTSFPART_EmailNotificationReminder
*/

@isTest
public class DTSFPART_EmailNotificationReminder_Test {
    
    @testSetup
    static void testSetUp() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        List<Account> partnerAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(1, partnerRecordType);
        DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), true);
        Contact adminContact = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccounts.get(0), false);
        adminContact.Email = 'testcontact@gmail.com';
        insert adminContact;
        adminContact.Contact_MCN_Permissions__c = 'UserAdmin';
        update adminContact;
        DTSFPART_TestDataSetUpUtils.createMPEContacts(2, partnerAccounts, true);
        
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
            System.assertEquals('Test_Template', validEmailTemplate.DeveloperName);
        }
    }
    
    @isTest
    static void test_ReminderNotification() {
        List<MPEContact__c> mpeContacts = [SELECT Id FROM MPEContact__c];
        List<EmailTemplate> templates = [
            SELECT Id
            FROM EmailTemplate
            WHERE Name = 'Test Template'
        ];
        
        List<DTSFPART_EmailNotificationReminder.EmailNotificationRequest> wrapList = new List<DTSFPART_EmailNotificationReminder.EmailNotificationRequest>();
        DTSFPART_EmailNotificationReminder.EmailNotificationRequest wrapper = new DTSFPART_EmailNotificationReminder.EmailNotificationRequest();
        wrapper.mpeContactId = mpeContacts.get(0).Id;
        wrapper.templateID = templates.get(0).Id;
        wrapList.add(wrapper);
        System.assertEquals(templates.get(0).Id, wrapper.templateID);
        Test.startTest();
        DTSFPART_EmailNotificationReminder.sendEmailNotification(wrapList);
        Test.stopTest();
    }
}