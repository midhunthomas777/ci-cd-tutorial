global class InvokeUpdateTriggerBatch implements Database.Batchable<sObject> {

/**************************************************************************
This class that the Salesforce sObject name as a string in the constructor,
then executes a Apex batch that updates all of the records.  It basically runs 
a “non-destructive” update by not changing any data.  It is used for invoking 
Triggers on all data... e.g. for initializing data after changes are made to a
 trigger
**************************************************************************/

    private String sObjectName;
    private String filter;
    private Boolean forceTriggers = false;
    
    public Boolean isTest = false;
 
    global InvokeUpdateTriggerBatch(String sObjectName, string filter, Boolean forceTriggers) {
        this.sObjectName = sObjectName;
        this.filter = filter;
        this.forceTriggers = forceTriggers;
    }
 
    global InvokeUpdateTriggerBatch(String sObjectName, string filter) {
        this.sObjectName = sObjectName;
        this.filter = filter;
    }
 
    global InvokeUpdateTriggerBatch(String sObjectName) {
        this.sObjectName = sObjectName;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
 
        String query = 'SELECT Id FROM ' + sObjectName;
        
        if(filter!=null)
            query += ' where ' + filter;
            
        if(isTest)
        // by Madhavi Updated limit from 50 to 10 to avoid test class issues 
            query += ' limit 10';
            
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        if(forceTriggers){
            for(sObject s : scope){
                s.put('forceTriggers__c',true);
            }
        }
        
        update scope;
     }
 
    global void finish(Database.BatchableContext BC){
        System.debug('Batch Process Complete');
    }
}