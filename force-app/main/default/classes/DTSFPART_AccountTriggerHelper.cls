/**
 * @description: Creates data maps for MCN -> Enterprise relation
 */
public inherited sharing class DTSFPART_AccountTriggerHelper {
    private static Id partnerAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
    private static Id customerAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount'); // customer record type
    private static Id mcnAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
    private static Id mrAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');

    public Map<Id, Account> parentAccounts { get; private set; }
    public Map<Id, Account> mcnAccounts { get; private set; }

    public DTSFPART_AccountTriggerHelper(Map<Id, SObject> accounts) {
        this(accounts.keySet());
    }

    public DTSFPART_AccountTriggerHelper(List<Account> accounts) {
        Set<Id> parentIds = new Set<Id>();
        for(Account account: accounts){
            if(String.isNotBlank(account.ParentId)){
                parentIds.add(account.ParentId);
            }
        }
        
        parentAccounts = new Map<Id, Account>();
        mcnAccounts = new Map<Id, Account>();
        setParentAccounts(parentIds);
    }

    public DTSFPART_AccountTriggerHelper(Set<Id> accountsIds) {
        parentAccounts = new Map<Id, Account>();
        mcnAccounts = new Map<Id, Account>();

        setParentAccounts(accountsIds);
    }

    private void setParentAccounts(Set<Id> accountIds) {        
        for (Account account : [
            SELECT
                Id,
                Partner_Hub_enabled__c,
                MPE_Program_Status_New__c,
                Motorola_Enterprise_ID__c,
                RecordTypeId,
                ParentId,
                Parent.Partner_Hub_enabled__c,
                Parent.MPE_Program_Status_New__c,
                Parent.Motorola_Enterprise_ID__c,
                Parent.RecordTypeId,
                (SELECT Id FROM ChildAccounts WHERE RecordTypeId = :mcnAccountRT)
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            if(account.RecordTypeId == mcnAccountRT){
                parentAccounts.put(account.ParentId, account.Parent);
                mcnAccounts.put(account.Id, account);
            } else {
                parentAccounts.put(account.Id, account);
            }
        }
    }

    /*public Map<Id, Account> getHubAccounts(Map<Id, SObject> accountMap) {
        Map<Id, Account> resultMap = new Map<Id, Account>();

        for (Account account : (List<Account>) accountMap.values()) {
            if (
                (account.RecordTypeId == partnerAccountRT || account.RecordTypeId == customerAccountRT) && parentAccounts.containsKey(account.Id) ||
                account.RecordTypeId == mcnAccountRT && 
                (
                    (String.isNotBlank(account.ParentId) && parentAccounts.containsKey(account.ParentId)) || 
                    (String.isNotBlank(account.Assigned_MR__c) && parentAccounts.containsKey(account.Assigned_MR__c))
                )
            ) {
                resultMap.put(account.Id, account);
            }
        }

        return resultMap;
    }*/
}