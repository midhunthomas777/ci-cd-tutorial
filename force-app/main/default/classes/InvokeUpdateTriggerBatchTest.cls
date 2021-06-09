@isTest
private with sharing class InvokeUpdateTriggerBatchTest {

    static testMethod void testOne()
    {
        Test.startTest();
        
        InvokeUpdateTriggerBatch b = new InvokeUpdateTriggerBatch('Case');
        b.isTest = true;
        Id i = Database.executeBatch(b,200);
        
        //InvokeUpdateTriggerBatch c = new InvokeUpdateTriggerBatch('Lead','LastName > \'m\'');
        //InvokeUpdateTriggerBatch c = new InvokeUpdateTriggerBatch('Lead','Track__c!= NULL'); 
        //c.isTest = true;
        //Id j = Database.executeBatch(c,200);
        
       //Commented below line for Salesstage Changes --Abhilash Govinda 16-May-13  ////      
        //InvokeUpdateTriggerBatch d = new InvokeUpdateTriggerBatch('Opportunity','StageName = \'Pipeline\'',true);       
        InvokeUpdateTriggerBatch d = new InvokeUpdateTriggerBatch('Opportunity','StageName = \'Prospect\'',true);
        d.isTest = true;
        Id k = Database.executeBatch(d,200);
        
        Test.stopTest();
    }

}