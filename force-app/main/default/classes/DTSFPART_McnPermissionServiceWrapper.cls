public inherited sharing class DTSFPART_McnPermissionServiceWrapper {
    public Set<Id> recalculateAll;
    public Map<Id, Set<Id>> recalculateByParent { get; private set; }
    public Map<Id, Set<Id>> recalculateByMR { get; private set; }
    public Map<Id, Account> recalculateAllData { get; private set; }

    public DTSFPART_McnPermissionServiceWrapper() {
        this.recalculateAll = new Set<Id>();
        this.recalculateByParent = new Map<Id, Set<Id>>();
        this.recalculateByMR = new Map<Id, Set<Id>>();
    }

    public void addRecalculateAll(Id mcnId) {
        recalculateAll.add(mcnId);
    }

    public void addRecaluclateByParent(Id parentId, Id mcnId) {
        if (!recalculateByParent.containsKey(parentId)) {
            recalculateByParent.put(parentId, new Set<Id>());
        }

        recalculateByParent.get(parentId).add(mcnId);
    }

    public void addRecaluclateByMR(Id parentId, Id mcnId) {
        if (!recalculateByMR.containsKey(parentId)) {
            recalculateByMR.put(parentId, new Set<Id>());
        }

        recalculateByMR.get(parentId).add(mcnId);
    }

    public Map<Id, DTSFPART_AccountPermissionsWrapper> getPreparedPermissionsForParent() {
        return DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(recalculateByParent.keySet(), false);        
    }

    public Map<Id, DTSFPART_AccountPermissionsWrapper> getPreparedPermissionsForMR() {
        return DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(recalculateByMR.keySet(), true);        
    }

    public void prepareAllToRecalculate() {
        recalculateAllData = new Map<Id, Account>();
        for (Account account : [
            SELECT Id, ParentId, Assigned_MR__c, Assigned_MR_Sales_Person__c, RecordTypeId
            FROM Account
            WHERE Id IN :recalculateAll AND RecordTypeId = :DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number')
        ]) {
            if(String.isNotBlank(account.ParentId)){
                addRecaluclateByParent(account.ParentId, account.Id);
            }
            if(String.isNotBlank(account.Assigned_MR__c)){
                addRecaluclateByMR(account.Assigned_MR__c, account.Id);
            }
            recalculateAllData.put(account.Id, account);
        }
    }
}