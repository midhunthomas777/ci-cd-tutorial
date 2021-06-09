@isTest
public with sharing class BatchApexErrorEventTrigger_Test {
    static testMethod void testIfErrorWasSaved()
    {
        try {
        Test.startTest();
            
                LogErrorExampleBatchApex obj = new LogErrorExampleBatchApex();
                Database.executeBatch(obj); 
        
            
        Test.stopTest();
    } catch (Exception e) {
                
    }
        Test.getEventBus().deliver(); 

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, quiddity__c, Request_Id__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals('Error', errorLogRecords[0].Type__c);
        System.assert(errorLogRecords[0].ModuleCreatingError__c.startsWith('Batch Job: '));
        System.assertEquals('System.NullPointerException', errorLogRecords[0].Short_Error_Description__c);
        System.assert(errorLogRecords[0].ErrorString__c.startsWith('Batch Job failed'));
        System.assert(!String.isBlank(errorLogRecords[0].quiddity__c), 'Quiddity should not be empty!');
        System.assert(!String.isBlank(errorLogRecords[0].Request_Id__c), 'Request Id should not be empty!');
    }

}