//Hemant Rana: Created Test Class for ContentDocumentLinkTrigger_MSI trigger & ContentDocumentLinkTriggerHandler_MSI class
@isTest
private class ContentDocumentLinkTrigger_MSITest
{   
    //configuring custom settings
    @testSetup
    static void testSetUp()
    {  
        TestDataSetUpUtils.insertCustomSettings();
    } 
    //method that tests dispatch remedy ticket functionality invoked after case update trigger
    static testmethod void createContentDocumentLink()
    {
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types
        //Id caseMSIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Incident').getRecordTypeId();
        Id caseTechRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Technical_Request').getRecordTypeId();
        
        /*List<Case> caseList_MSI = TestDataSetUpUtils.createCases(1,caseMSIRecordTypeId,contactList );
        caseList_MSI[0].ContactId = contactList.get(0).Id;
        caseList_MSI[0].Remedy_Incident_ID__c = '142425';
        update caseList_MSI;*/
        
        List<Case> caseList_TechReq = TestDataSetUpUtils.createCases(1,caseTechRecordTypeId,contactList);
        caseList_TechReq[0].ContactId = contactList.get(0).Id;
        caseList_TechReq[0].Remedy_Incident_ID__c = '142425';
        update caseList_TechReq;
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            FirstPublishLocationId = caseList_TechReq[0].Id,
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        /*contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            FirstPublishLocationId = caseList_TechReq[0].Id,
            PathOnClient = 'Test1.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);*/
        insert contentVersionList;
        
        contentVersionList[0].Title ='Test_Update';
        //contentVersionList[1].Title ='Test1_Update';
        update contentVersionList;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionList[0].Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> contentDocLink = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId =: documents[0].Id];
        update contentDocLink;
        delete contentDocLink;
        
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
    }    
}