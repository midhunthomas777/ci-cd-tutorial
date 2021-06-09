global class DeleteandInsertAccountToGroupMapping implements Database.Batchable<sObject>{
    
    Set<Id> accSetforAGM = new Set<Id>();
    global DeleteandInsertAccountToGroupMapping(Set<Id> accountsForAccountToGroupMapping) {
        accSetforAGM = accountsForAccountToGroupMapping;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id FROM Account_to_Group_Mapping__c]);
    }
    
    global void execute(Database.BatchableContext context, List<sObject> scope) {
        Database.delete(scope,false);
    }
    
    global void finish(Database.BatchableContext context) {
        System.debug('Entered Finish Method to execute insertion of Account to Group Mapping Records');
        MPP_Class_AddGroupsToUserInBulkBatch batchInstance = new MPP_Class_AddGroupsToUserInBulkBatch(accSetforAGM);
        ID batchprocessid = Database.executeBatch(batchInstance);
        System.debug('Entered Finish Method to execute insertion of Account to Group Mapping Records###'+batchprocessid);
    }
}