@IsTest
public with sharing class DTSFPART_CaseAttachmentControllerTest {

    @TestSetup
    private static void setup() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @IsTest
    private static void saveAttachmentsTest() {
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account parent = DTSFPART_TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId, true);
        Attachment attachment = new Attachment();
        Blob bodyBlob = Blob.valueOf('test');
		attachment.ParentId = parent.Id;
		attachment.body = bodyBlob;
		attachment.Name = 'Attachment.pdf';
		insert attachment;
        List<ContentVersion> files = new List<ContentVersion>();
        Test.startTest();
        files = DTSFPART_CaseAttachmentController.saveAttachmentsAsContentVersions(new List<Attachment>{attachment});
        Test.stopTest();

        // System.assertEquals(1, files.size(), 'Wrong number of files created.');
    }
}