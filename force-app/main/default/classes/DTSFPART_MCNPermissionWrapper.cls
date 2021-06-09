public inherited sharing class DTSFPART_MCNPermissionWrapper {
    public Map<Id, List<Account>> modifiedMCNsByParent { get; private set; }
    public Map<Id, List<Account>> modifiedMCNsByAssignedMR { get; private set; }
    public List<Id> modifiedPartnerAccountsIds { get; private set; }
    public List<Id> modifiedMrAccountsIds { get; private set; }
    public String operation { get; private set; }
    public DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference { get; private set; }

    public DTSFPART_MCNPermissionWrapper(String operation){
        this(operation, null);
    }

    public DTSFPART_MCNPermissionWrapper(String operation, DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference) {
        this.modifiedMCNsByParent = new Map<Id, List<Account>>();
        this.modifiedMCNsByAssignedMR = new Map<Id, List<Account>>();
        this.modifiedPartnerAccountsIds = new List<Id>();
        this.modifiedMrAccountsIds = new List<Id>();
        this.operation = operation;
        this.contactMcnPermRemovalReference = contactMcnPermRemovalReference;
    }
    

    public void addMRAccount(DTSFPART_AccountTriggerWrapper wrappedAccount){
        if (!modifiedMCNsByAssignedMR.containsKey(wrappedAccount.assignedMrId)) {
            modifiedMCNsByAssignedMR.put(wrappedAccount.assignedMrId, new List<Account>());
        }
        
        modifiedMCNsByAssignedMR.get(wrappedAccount.assignedMrId).add(wrappedAccount.newAccount);
        modifiedMrAccountsIds.add(wrappedAccount.Id);
    }

    public void addPartnerAccount(DTSFPART_AccountTriggerWrapper wrappedAccount){
        if (!modifiedMCNsByParent.containsKey(wrappedAccount.ParentId)) {
            modifiedMCNsByParent.put(wrappedAccount.ParentId, new List<Account>());
        }
        modifiedMCNsByParent.get(wrappedAccount.ParentId).add(wrappedAccount.newAccount);
        modifiedPartnerAccountsIds.add(wrappedAccount.id);
    }
}