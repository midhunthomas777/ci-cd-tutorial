@isTest
public class DTSFPART_LWC_AttachmentsTest {

    @isTest
    private static void getFileExtensionsDefaultsTest() {

        Test.startTest();
            List<Attachment_File_Extensions__mdt> mfileExtensionMetadata = DTSFPART_LWC_Attachments.getFileExtensionsDefaults();
        Test.stopTest();

        System.assertNotEquals(null, mfileExtensionMetadata);
    }

    // @isTest
    // private static void checkFileExtensionTest() {
    //     Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
    //     Account parent = DTSFPART_TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
    //     Blob bodyBlob = EncodingUtil.convertFromHex('255044462d');
    //     Attachment attachment = new Attachment();
	// 	attachment.ParentId = parent.Id;
	// 	attachment.body = bodyBlob;
	// 	attachment.Name = 'Attachment.pdf';
    //     attachment.ContentType = 'application/pdf';
    //     insert attachment;
    //     Boolean result = false;
    //     Test.startTest();
    //         result = DTSFPART_LWC_Attachments.isValidFile([SELECT Id, ContentType, Body FROM Attachment LIMIT 1].Body);
    //     Test.stopTest();

    //     System.assertEquals(true, result);
    // }
}