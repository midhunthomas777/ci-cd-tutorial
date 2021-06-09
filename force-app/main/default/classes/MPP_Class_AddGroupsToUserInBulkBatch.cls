/*
 * Class Name : MPP_Class_AddGroupsToUserInBulkBatch
 * Author : Satish Maddhi
 * Description : Batch class to insert Account_to_Group_Mapping__c records
 */

global class MPP_Class_AddGroupsToUserInBulkBatch implements Database.Batchable<sObject>{
    Set<Id> accountList = new Set<Id>();
    global MPP_Class_AddGroupsToUserInBulkBatch(Set<Id> accBatchList) {
        accountList = accBatchList;
    }
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id FROM Account WHERE ID IN :accountList]);
    }
    
    global void execute(Database.BatchableContext context, List<Account> scope) {
        Map<Id,String> tempMap = new Map<Id,String>();
        Set<Id> accountSet = new Set<Id>();
        List<Account_to_Group_Mapping__c> listAccGroupMap= new List<Account_to_Group_Mapping__c>();
        for(Account eachAcc : scope) {
        	accountSet.add(eachAcc.Id);    
        }
        tempMap = MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accountSet);
        for(Id idVal : TempMap.keySet()) {
            Account_to_Group_Mapping__c newAccGroupMap = new Account_to_Group_Mapping__c();
            newAccGroupMap.Groups__c = TempMap.get(idVal);
            newAccGroupMap.Account_Id__c = idVal;
            listAccGroupMap.add(newAccGroupMap);
        }
        if(listAccGroupMap.size()>0) {
        	Database.insert(listAccGroupMap,false);
        }
    }    
    global void finish(Database.BatchableContext context) { }
}