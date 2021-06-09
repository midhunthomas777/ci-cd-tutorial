@isTest
public class DTSFPART_PartnershipFileControllerTest {
    
    @TestSetup
    static void createData() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();

       // UserTriggerHandler.TriggerDisabled = true;
        //DTSFPART_ProgramDetailTriggerHandler.TriggerDisabled = true;
        //ProgramDetailTriggerHandler.TriggerDisabled = true;
        PartnershipRecordTriggerHandler.isTriggerDisabled = true;

        Account account = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact contact = DTSFPART_TestDataSetUpUtils.createPartnerContact(account, false);
        contact.Persona__c = 'SalesManager';
        contact.Partner_Region__c = 'NAMR';
        contact.Tag__c = 'LeadAdmin';

        insert contact;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(contact);

        Partnership_Record__c partnershipFile = new Partnership_Record__c();
        partnershipFile.Name = 'TestFile2';
        partnershipFile.Partner_Empower_ID__c = '12345';//account.Partner_Membership_Id__c;
        partnershipFile.Account__c = account.Id;
        partnershipFile.File_Id__c = '15W9puJ8o8qgikAkHMaUYCK6WBAh3yLMN4-SrZIEa6I';
        partnershipFile.File_Type__c = 'Certification Report';
        partnershipFile.Mime_Type__c = 'Microsoft Excel';

        insert partnershipFile;
    }

    @isTest
    static void getRecentlyViewedPartnershipRecordsTest() {
        List<Partnership_Record__c> partnershipsRecords = new List<Partnership_Record__c>();
        User communityUser = [ SELECT Id FROM User WHERE Username = 'test123asdfresdf@noemail.com' ];
        Test.startTest();
        System.runAs(communityUser) {
            partnershipsRecords = DTSFPART_PartnershipFileController.getRecentlyViewedPartnershipRecordsByCurrentUser();
        }
        Test.stopTest();

        System.assert(partnershipsRecords.size() == 0);
    }

    @isTest
    static void getAccountRelatedPartnershipRecordsTest() {
        Map<Boolean,List<Partnership_Record__c>> partnershipsRecords = new  Map<Boolean,List<Partnership_Record__c>>();

        Account account = [ SELECT Id FROM Account WHERE Name = 'Test Account'];

        User communityUser = [ SELECT Id FROM User WHERE Username = 'test123asdfresdf@noemail.com' ];
        Test.startTest();
        System.runAs(communityUser) {
            partnershipsRecords = DTSFPART_PartnershipFileController.getActivePartnershipRecordsMapForCurrentUserContactAccount();
        }
        Test.stopTest();

        System.assert(partnershipsRecords != null);
    }

    @isTest
    static void getMimeTypePicklistTest() {
         Map<String, String> mimeTypeOptions = new  Map<String, String>();

        Account account = [ SELECT Id FROM Account WHERE Name = 'Test Account'];

        User communityUser = [ SELECT Id FROM User WHERE Username = 'test123asdfresdf@noemail.com' ];
        Test.startTest();
        System.runAs(communityUser) {
            mimeTypeOptions = DTSFPART_PartnershipFileController.getMimeTypePicklist();
        }
        Test.stopTest();

        System.assert(mimeTypeOptions != null);
    }

    @isTest
    static void downloadFileTest() {
        DTSFPART_PartnershipFileHelper.FileWrapper fileWrapper = new DTSFPART_PartnershipFileHelper.FileWrapper();

        User communityUser = [ SELECT Id FROM User WHERE Username = 'test123asdfresdf@noemail.com' ];
        Partnership_Record__c partnerFile = [ SELECT ID FROM Partnership_Record__c WHERE Name = 'TestFile2' ];

        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
        Test.startTest();
        System.runAs(communityUser) {
            try {
                fileWrapper = DTSFPART_PartnershipFileController.downloadFile(partnerFile.Id);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();

        System.assert(fileWrapper != null);
    }
}