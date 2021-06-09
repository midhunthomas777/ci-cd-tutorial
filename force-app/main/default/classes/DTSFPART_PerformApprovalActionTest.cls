@IsTest
public with sharing class DTSFPART_PerformApprovalActionTest {

    @TestSetup
    private static void setup() {
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=DTSFPART_TestDataSetUpUtils.createPartnerEmpower();
        empower.Main_place_of_business_Country__c='Canada';
        empower.Main_place_of_business_State__c = 'Alberta';
        empower.Partner_Application_Status__c='Approved';
        empower.Are_You_Authorized_to_Sign_Legal_Agmt__c='No';
        update empower;
        
        Account partnerAccount=DTSFPART_TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId, true);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Canada';
        partnerAccount.BillingState='Alberta';
        partnerAccount.BillingCountryCode = 'CA';
        partnerAccount.BillingStateCode = 'AB';
        update partnerAccount;

        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            MPEContact__c newContact = new MPEContact__c(Application__c=empower.Id,Account__c=partnerAccount.Id,Last_Name__c='test',
            First_Name__c='test1',Email__c='test@test.com',Phone__c='123',
            Primary_Language__c='English');
            insert newContact;

            Contact contact = DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccount, false);
            contact.FirstName = 'Test';
            contact.LastName = 'setup';
            contact.Email = 'setup@test.test';
            contact.Persona__c = 'OwnerExecutive';
            insert contact;
            contact.C360_Response__c = 'some response from C360';
            contact.Enterprise_Permission_Status__c = 'Completed';
            update contact;
        }
    }

    @IsTest
    private static void deleteMPEContactAndSendEmailTest() {
        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Map<Id, Id> contactWithMPEID = new Map<Id, Id>();
        System.runAs(thisUser) {
            Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
            Id newContactId = [SELECT Id FROM MPEContact__c LIMIT 1].Id;
            Test.startTest();
            contactWithMPEID.put(contactId, newContactId);
            DTSFPART_PerformApprovalAction.deleteMPEContactAndSendEmail(contactWithMPEID);
            Test.stopTest();
            System.assertEquals(0, [SELECT Id FROM MPEContact__c].size(), 'MPEContact__c records should be deleted.');
        }
    }
}