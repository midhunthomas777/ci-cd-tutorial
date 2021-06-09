@isTest
public class AttachmentTriggerTest {
     @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        //TestDataSetUpUtils.loadGoogleDriveTestData();
        Id siteID = TestDataSetUpUtils.createSite();
        BigMachines__Quote__c bgQuote = new BigMachines__Quote__c();   
        bgQuote.Name ='CPQ-0001';       
        bgQuote.BigMachines__Status__c='In Progress';
        bgQuote.BigMachines__Site__c = siteID;
        bgQuote.BigMachines__status__c='Finalized';
        insert bgQuote;
    }
    @isTest public static void testAttachment(){
        List<BigMachines__Quote__c> bgQuote = [SELECT Id  FROM BigMachines__Quote__c limit 1];
        Attachment attachment = new Attachment( ParentId = bgQuote.get(0).Id,Name = 'myAttachment.pdf',Body = Blob.valueOf('test'));
        attachment.ContentType = NULL;
        Test.startTest();
        insert attachment;
        attachment.Name = '[00P8000000RhbY3EAJ]';
        update attachment;
        Test.stopTest();
    }

}