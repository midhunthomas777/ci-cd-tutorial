/*
* Created on: 07-dec-2019
* Test class for CountTasksOfCaseTriggerHandler case.
* US: Open Tasks prevent Case Closure (7)
*/

@isTest
public class CountTasksOfCaseTriggerHandler_Test{
    @testSetup
    static void testSetUp()
    {  
        TestDataSetUpUtils.insertCustomSettings();
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name = 'FeedItemTriggerDisabled', IsActive__C=false));
        Insert tSC; 
        test.startTest();
        test.stopTest();
    }     
   
    @isTest
    public static void checkNonClosedTasks()
    {
        test.startTest();
        Id recordtype1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Image').getRecordTypeId();
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        
        Id RecordTypeIdMCN = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();  
        List<Account> accMCNList = TestDataSetUpUtils.createAccounts(1,RecordTypeIdMCN);
        //List<Contact> contactList = new List<Contact>();//TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList);
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList);
        List<Case> csList = new List<case>();  
        
        system.debug('contactList ID '+contactList.get(0).Id);
        
        Id conId = contactList.get(0).Id;
        Case cs = new Case();
        cs.AccountId = accList.get(0).Id;
        cs.ContactId =conId;
        cs.Subject = 'Test non closed tasks';
        cs.Description = 'Test non closed tasks';
        cs.Case_Type_1__c = 'Portal';
        cs.Case_Type_2__c = 'CPQ';
        cs.Case_Type_3__c = 'Navigation';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        //cs.Customer_Account__c = accMCNList.get(0).Id;
        cs.RecordTypeId = recordtype1;
        cs.Customer_Number__c = '1234567890';
                
        csList.add(cs);
        insert cslist; 
        
        cs.Status = 'Closed';
        update cs;   
        
        test.stopTest();
    }
}