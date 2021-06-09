/*
* Purpose  : ContentversionTrigger test class
* 
* JIRA Number   Date            Developer               Description
* -----------   -----------     -------------------     -----------
* LUCXBW-767    07 Dec  2020    Bona                    Added the test method named deleteFiles
*
*/
@isTest
private class ContentVersionTriggerTest {
//configuring custom settings
    @testSetup
    static void testSetUp()
    {
          TestDataSetUpUtils.insertCustomSettings();
    }
    private static testMethod void createContentDocument() {
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types
        Id recordtypeTechnicalRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Technical_Request').getRecordTypeId();
        
        
        List<Case> csList = new List<case>();
        List<Case> csList1 = new List<case>();
        
        //creating case and adding to csList
        Case cs = new Case();
        cs.AccountId = accList.get(0).Id;
        cs.ContactId = contactList.get(0).Id;
        cs.Subject = 'Test Remedy_Destination';
        cs.Description = 'Test when Remedy_Destination is empty';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        cs.recordtypeid = recordtypeTechnicalRequest ;
        cs.Remedy_Incident_ID__c = '142425';
        csList.add(cs);
        insert csList;
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Content 1',
            FirstPublishLocationId = csList[0].Id,
            PathOnClient = 'Content.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        contentVersion_1 = new ContentVersion(
            Title = 'Content 1',
            PathOnClient = 'Content.jpg',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);     
       
       
        insert contentVersionList;
        contentVersionList[0].Title ='Content_Clone';
        update contentVersionList[0];
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionList[0].Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        System.assertEquals(documents.size(), 2);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
    }
    private static testMethod void validatContentDocumentTest() {
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types
        Id recordtypeTechnicalRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Technical_Request').getRecordTypeId();
        
        
        List<Case> csList = new List<case>();
        List<Case> csList1 = new List<case>();
        
        //creating case and adding to csList
        Case cs = new Case();
        cs.AccountId = accList.get(0).Id;
        cs.ContactId = contactList.get(0).Id;
        cs.Subject = 'Test Remedy_Destination';
        cs.Description = 'Test when Remedy_Destination is empty';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        cs.recordtypeid = recordtypeTechnicalRequest ;
        cs.Remedy_Incident_ID__c = '142425';
        csList.add(cs);
        insert csList;
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Content 1',
            FirstPublishLocationId = csList[0].Id,
            PathOnClient = 'Content.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        contentVersion_1 = new ContentVersion(
            Title = 'Content 1',
            PathOnClient = 'Content.exe',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        try{
        insert contentVersionList;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot upload') ? true : false;
        }
    }
    // LUCXBW-767 added new test method
    private static testMethod void deleteFiles() {    
        //creating case 
        Case cs = new Case();       
        cs.Subject = 'Test Remedy_Destination';
        cs.Description = 'Test when Remedy_Destination is empty';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';      
        insert cs;
        
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = 'test@abc.org';
        emailMsg.Incoming = True;
        emailMsg.Subject = 'Test email';
        emailMsg.TextBody = 'test email attachments ';
        emailMsg.ParentId = cs.Id;
        Insert emailMsg;    

        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Content 1',
            FirstPublishLocationId = emailMsg.Id,
            PathOnClient = 'Content.html',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true
        );      
        
        insert contentVersion_1;
    
    }
}