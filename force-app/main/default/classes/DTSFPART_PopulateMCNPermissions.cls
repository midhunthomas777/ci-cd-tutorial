/**
 * @author: WGVR43
 * @date: 17.08.2020
 * @group: DTSFPART
 * @description:
 */

public with sharing class DTSFPART_PopulateMCNPermissions implements Queueable {
    private Map<Id, List<Account>> mcnAccountsByParent;
    private List<Id> modifiedParentIds;
    private Map<Id, List<Account>> mcnAccountsByMr;
    private List<Id> modifiedMrIds;
    private String operation;
    private DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference;
    private List<MCN_Permission__c> modifiedMcnPermissions;
    private List<MCN_Permission__c> deletedMCNPermissions;

    public DTSFPART_PopulateMCNPermissions(Map<Id, List<Account>> mcnAccountsByPartner, String operation) {
        this.mcnAccountsByParent = mcnAccountsByPartner;
        this.contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        this.operation = operation;
    }

    public DTSFPART_PopulateMCNPermissions(Map<Id, List<Account>> mcnAccountsByParent, Map<Id, List<Account>> mcnAccountsByMr, String operation) {
        this.mcnAccountsByParent = mcnAccountsByParent;
        this.mcnAccountsByMr = mcnAccountsByMr;
        this.contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        this.operation = operation;
    }

    public DTSFPART_PopulateMCNPermissions(Map<Id, List<Account>> mcnAccountsByParent, List<Id> modifiedParentIds, String operation) {
        this.mcnAccountsByParent = mcnAccountsByParent;
        this.modifiedParentIds = modifiedParentIds;
        this.contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        this.operation = operation;
    }

    public DTSFPART_PopulateMCNPermissions(
        Map<Id, List<Account>> mcnAccountsByPartner,
        List<Id> modifiedParentIds,
        Map<Id, List<Account>> mcnAccountsByMr,
        List<Id> modifiedMrIds,
        DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference,
        String operation
    ) {
        this.mcnAccountsByParent = mcnAccountsByPartner;
        this.modifiedParentIds = modifiedParentIds;
        this.mcnAccountsByMr = mcnAccountsByMr;
        this.modifiedMrIds = modifiedMrIds;
        this.operation = operation;
        this.contactMcnPermRemovalReference = contactMcnPermRemovalReference;
    }

    public DTSFPART_PopulateMCNPermissions(DTSFPART_MCNPermissionWrapper wrapper){        
        this.mcnAccountsByParent = wrapper.modifiedMCNsByParent;
        this.modifiedParentIds = wrapper.modifiedPartnerAccountsIds;
        this.mcnAccountsByMr = wrapper.modifiedMCNsByAssignedMR;
        this.modifiedMrIds = wrapper.modifiedMrAccountsIds;
        this.operation = wrapper.operation;
        this.contactMcnPermRemovalReference = wrapper.contactMcnPermRemovalReference;
    }

    public void execute(QueueableContext context) {
        try {
            modifiedMcnPermissions = new List<MCN_Permission__c>();
            deletedMcnPermissions = new List<MCN_Permission__c>();
            List<MCN_Permission__c> oldMcnPermissions = new List<MCN_Permission__c>();
            switch on operation {
                when 'create' {
                    createMCNPermissions(mcnAccountsByParent, false);
                    createMCNPermissions(mcnAccountsByMr, true);
                }
                when 'update' {
                    Map<Id, List<MCN_Permission__c>> mcnPermissionsByParent = DTSFPART_PermissionUtils.getMCNPermissionsByAccount(modifiedParentIds);
                    Map<Id, List<MCN_Permission__c>> mcnPermissionsByMr = DTSFPART_PermissionUtils.getMCNPermissionsByAccount(modifiedMrIds);
                    for (List<MCN_Permission__c> permissions : mcnPermissionsByParent.values()) {
                        oldMcnPermissions.addAll(permissions.deepClone(true));
                    }
                    for (List<MCN_Permission__c> permissions : mcnPermissionsByMr.values()) {
                        oldMcnPermissions.addAll(permissions.deepClone(true));
                    }
                    updateMCNPermissions(mcnAccountsByParent, mcnPermissionsByParent, false);
                    updateMCNPermissions(mcnAccountsByMr, mcnPermissionsByMr, true);
                }
            }
            upsert modifiedMcnPermissions;
            delete deletedMcnPermissions;
            if (!Test.isRunningTest()) {
                System.enqueueJob(
                    new DTSFPART_UpdateContactMCNPermissions(
                        new Map<Id, MCN_Permission__c>(modifiedMcnPermissions),
                        new Map<Id, MCN_Permission__c>(oldMcnPermissions),
                        contactMcnPermRemovalReference
                    )
                );
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_PopulateMCNPermissions.execute', '', '', e);
            throw e;
        }
    }

    private void createMCNPermissions(Map<Id, List<Account>> modifiedMCNsByAccount, Boolean isMr) {
        if (modifiedMCNsByAccount != null) {
            Map<Id, DTSFPART_AccountPermissionsWrapper> partnerPermissions = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(
                modifiedMCNsByAccount.keySet(),
                isMR
            );
            DTSFPART_AccountPermissionsWrapper customerPermissions = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsForCustomer();
            for (Id accountId : modifiedMCNsByAccount.keySet()) {
                for (Account mcn : modifiedMCNsByAccount.get(accountId)) {
                    DTSFPART_AccountPermissionsWrapper accountPermissions = customerPermissions;
                    if (isMr || mcn.Parent_Record_Type__c != DTSFPART_CommonStrings.CUSTOMER) {
                        accountPermissions = partnerPermissions.get(accountId);
                    }
                    modifiedMcnPermissions.add(
                        new MCN_Permission__c(
                            MCN_Account__c = mcn.Id,
                            MCN_Permissions__c = accountPermissions.mcnPermissions,
                            Contact_MCN_Permissions__c = accountPermissions.contactMCNPermissions,
                            Customer_OR_Partner_Account__c = accountId
                        )
                    );
                }
            }
        }
    }

    private void updateMCNPermissions(Map<Id, List<Account>> modifiedMCNsByParent, Map<Id, List<MCN_Permission__c>> mcnPermissionsByAccount, Boolean isMr) {
        if (modifiedMCNsByParent != null && mcnPermissionsByAccount != null) {
            Map<Id, DTSFPART_AccountPermissionsWrapper> partnerPermissions = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsByAccount(
                modifiedMCNsByParent.keySet(),
                isMR
            );
            DTSFPART_AccountPermissionsWrapper customerPermissions = DTSFPART_PermissionUtils.calculateDefaultMCNPermissionsForCustomer();
            for (Id parentId : modifiedMCNsByParent.keySet()) {
                for (Account mcn : modifiedMCNsByParent.get(parentId)) {
                    List<MCN_Permission__c> permissions = mcnPermissionsByAccount.get(mcn.Id);
                    if (String.isNotBlank(mcn.Motorola_Customer_Number__c)) {
                        DTSFPART_AccountPermissionsWrapper accountPermissions = customerPermissions;
                        if (isMr || mcn.Parent_Record_Type__c != DTSFPART_CommonStrings.CUSTOMER) {
                            accountPermissions = partnerPermissions.get(parentId);
                        }
                        if (permissions != null && !permissions.isEmpty()) {
                            for (MCN_Permission__c permission : permissions) {
                                permission.MCN_Permissions__c = accountPermissions.mcnPermissions;
                                permission.Contact_MCN_Permissions__c = accountPermissions.contactMCNPermissions;
                                permission.Customer_OR_Partner_Account__c = parentId;
                                modifiedMcnPermissions.add(permission);
                            }
                        } else {
                            modifiedMcnPermissions.add(
                                new MCN_Permission__c(
                                    MCN_Account__c = mcn.Id,
                                    MCN_Permissions__c = accountPermissions.mcnPermissions,
                                    Contact_MCN_Permissions__c = accountPermissions.contactMCNPermissions,
                                    Customer_OR_Partner_Account__c = parentId
                                )
                            );
                        }
                    } else {
                        deletedMcnPermissions.addAll(permissions);
                    }
                }
            }
        }
    }
}