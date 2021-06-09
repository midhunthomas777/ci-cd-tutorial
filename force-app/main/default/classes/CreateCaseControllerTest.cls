/*
* Name : CreateCaseControllerTest
* Description : Test class for CreateCaseController
* Author : Hemant R
* Date : 12th Aug 2020
*/
@isTest
public class CreateCaseControllerTest {
@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        
    }
    public static testMethod void unitTestCreateMSICase() {
        
        Task task = new Task( subject = 'Attachement Updated', status='Completed');  
        insert task;
        
       
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types
        Id caseMSIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Technical_Request').getRecordTypeId();
        List<Case> caseList_MSI = TestDataSetUpUtils.createCases(1,caseMSIRecordTypeId,contactList);
        caseList_MSI[0].Case_Type_1__c='Technical Support';
        update caseList_MSI[0];
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        LiveChatTranscript lct = new LiveChatTranscript(CaseId=caseList_MSI[0].id,LiveChatVisitorId =lcv.Id);
        insert lct;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = contactList[0].id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        CreateCaseController.getPickListValuesIntoList();
        CreateCaseController.getTaskRecord(task.id,'Id,Subject,WhoId,Who.name');
        CreateCaseController.updateTaskRecord(task.id,caseList_MSI[0].id);
        CreateCaseController.fetchRecords('Case','Test FName0',caseMSIRecordTypeId,accList[0].id);
        CreateCaseController.fetchRecords('Case','Test FName0','',accList[0].id);
        CreateCaseController.updateTranscriptRecord(lct.id,caseList_MSI[0].id);
        CreateCaseController.getChatTranscriptRecord(lct.id);
        CreateCaseController.getAccountChildRecords(accList[0].id);
        CreateCaseController.validateContact(contactList[0].id);
        
        
    }
}