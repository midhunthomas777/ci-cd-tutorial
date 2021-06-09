//Hemant Rana: Created Test Class for EmailMessageTrigger trigger & EmailMessageTriggerHandler class
@isTest
private class EmailMessageTriggerTest{
    //configuring custom settings
    @testSetup
    static void testSetUp()
    {  
        TestDataSetUpUtils.insertCustomSettings();
    } 
    private static testMethod void createEmailMessage() {
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types
        Id caseTechRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Technical_Request').getRecordTypeId();
        
        List<Case> caseList_MSI = TestDataSetUpUtils.createCases(1,caseTechRecordTypeId,contactList);
        caseList_MSI[0].CC_List__c = 'test@ccList.com';
        update caseList_MSI[0];
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'motorolasolutions@gmail.com', ccAddress='test@test.com', Incoming = True, ToAddress= 'testClass@dummyEmail.com', Subject = 'Test email subject', TextBody = 'Test email body', ParentId = caseList_MSI[0].Id)); 
        insert newEmail;
        update newEmail;
        delete newEmail;
        undelete newEmail;
    }
}