/**
 * @author: QGBC67
 * @date: 29.07.2020
 * @updated: 26.01.2021
 * @group: DTSFPART
 * @description:
 */

public with sharing class DTSFPART_AccountTriggerHandler implements ITriggerHandler {
    private static Id partnerAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
    private static Id customerAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
    private static Id mcnAccountRT = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled() {
        return TriggerDisabled || new DTSFPART_TriggerConfigurationService('AccountTrigger', 'DTSFPART_AccountTriggerHandler').isTriggerLogicDisabled();
    }

    public void beforeInsert(List<SObject> newItems) {}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        clearOldErrorMessage(newItems, oldItems); // https://jira.mot-solutions.com/browse/DTCSS-2970
        handleC360ErrorResponse(newItems, oldItems); // https://jira.mot-solutions.com/browse/DTPART-1423
        removeMCNPermissions(newItems, oldItems);
    }

    // DTCSS-2970 Clear Error Messages At Start of Enterprise Permission Updates
    public void clearOldErrorMessage(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Account> newRecords = (Map<Id, Account>) newItems;
        Map<Id, Account> oldRecords = (Map<Id, Account>) oldItems;
        for (Account acc : newRecords.values()) {
            if (acc.Enterprise_Permission_Status__c == DTSFPART_CommonStrings.IN_PROGRESS && oldRecords.get(acc.Id).Enterprise_Permission_Status__c != DTSFPART_CommonStrings.IN_PROGRESS) {
                acc.C360_Response__c = '';
            }
        }
    }

    private void handleC360ErrorResponse(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        List<Account> newAccounts = (List<Account>) newItems.values();
        Map<Id, Account> oldAccounts = (Map<Id, Account>) oldItems;

        for(Account newAccount : newAccounts) {
            Account oldAccount = oldAccounts.get(newAccount.Id);
            String newStatus = newAccount.Enterprise_Permission_Status__c;
            String newResponse = newAccount.C360_Response__c;
            String oldResponse = oldAccount.C360_Response__c;

            if(DTSFPART_Utils.hasReceivedErrorFromC360(newResponse, oldResponse, newStatus)) {
                newAccount.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.ERROR;
            }
        }
    }

    private static void removeMCNPermissions(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if (newItems != null && oldItems != null) {
            Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
            Map<Id, Account> oldAccounts = (Map<Id, Account>) oldItems;

            Set<Id> removeAllMcnPermissions = new Set<Id>();
            Set<Id> customerOrPartnerAccounts = new Set<Id>();
            Set<Id> mcnAccountsToBeCleaned = new Set<Id>();         
            Map<Id, Set<Id>> contactToRemovePermissionForMcn = new Map<Id, Set<Id>>();

            for (Id accountId : newAccounts.keySet()) {
                if(newAccounts.get(accountId).RecordTypeId != oldAccounts.get(accountId).RecordTypeId){
                    if(oldAccounts.get(accountId).RecordTypeId == mcnAccountRT){
                        removeAllMcnPermissions.add(accountId);
                    }
                } else if(newAccounts.get(accountId).RecordTypeId == mcnAccountRT){
                    if(newAccounts.get(accountId).ParentId != oldAccounts.get(accountId).ParentId){
                        if(String.isNotBlank(oldAccounts.get(accountId).ParentId)){
                            customerOrPartnerAccounts.add(oldAccounts.get(accountId).ParentId);
                            mcnAccountsToBeCleaned.add(accountId);
                        }
                    }

                    if(newAccounts.get(accountId).Assigned_MR__c != oldAccounts.get(accountId).Assigned_MR__c){
                        if(String.isNotBlank(oldAccounts.get(accountId).Assigned_MR__c)){
                            customerOrPartnerAccounts.add(oldAccounts.get(accountId).Assigned_MR__c);
                            mcnAccountsToBeCleaned.add(accountId);
                        }
                    }

                    if(!newAccounts.get(accountId).ERP_Active__c && oldAccounts.get(accountId).ERP_Active__c){
                        removeAllMcnPermissions.add(accountId);
                    }

                    if(newAccounts.get(accountId).Assigned_MR_Sales_Person__c != oldAccounts.get(accountId).Assigned_MR_Sales_Person__c){
                        if(!contactToRemovePermissionForMcn.containsKey(accountId)){
                            contactToRemovePermissionForMcn.put(accountId, new Set<Id>());
                        }
    
                        contactToRemovePermissionForMcn.get(accountId).add(oldAccounts.get(accountId).Assigned_MR_Sales_Person__c);
                    }
                }
            }

            if(!removeAllMcnPermissions.isEmpty() || !customerOrPartnerAccounts.isEmpty() || !mcnAccountsToBeCleaned.isEmpty()){
                DTSFPART_McnPermissionRemovalService.remove(removeAllMcnPermissions, customerOrPartnerAccounts, mcnAccountsToBeCleaned);
            }

            if(!contactToRemovePermissionForMcn.isEmpty()){
                DTSFPART_ContactPermissionService.removeMRPermissions(contactToRemovePermissionForMcn);
            }
        }
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        if (newItems != null) {
            Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
            if (!newAccounts.isEmpty()) {
                updatePermissionForNewMCN(newAccounts); // https://jira.mot-solutions.com/browse/DTPART-205
            }
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if (newItems != null && oldItems != null) {
            Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
            Map<Id, Account> oldAccounts = (Map<Id, Account>) oldItems;
            if (!newAccounts.isEmpty()) {
                refreshPermissions(newAccounts, oldAccounts); // https://jira.mot-solutions.com/browse/DTPART-234
                updateRelatedContacts(newAccounts, oldAccounts); // https://jira.mot-solutions.com/browse/DTPART-705
                updateContactsEnterpriseStatus(newAccounts, oldAccounts);
            }
        }
    }

    private static void updatePermissionForNewMCN(Map<Id, Account> newAccounts) {
        Map<Id, List<Account>> modifiedMCNsByParent = new Map<Id, List<Account>>();
        Map<Id, List<Account>> modifiedMCNsByAssignedMR = new Map<Id, List<Account>>();

        for (Id id : newAccounts.keySet()) {
            Account account = newAccounts.get(id);
            if (
                DTSFPART_PermissionUtils.isMCNAccount(account.RecordTypeId) &&
                account.ERP_Active__c &&
                String.isNotBlank(account.Motorola_Customer_Number__c)
            ) {
                if (account.ParentId != null && (account.Parent_Record_Type__c == DTSFPART_CommonStrings.PARTNER || account.Parent_Record_Type__c == DTSFPART_CommonStrings.CUSTOMER)) {
                    if (!modifiedMCNsByParent.containsKey(account.ParentId)) {
                        modifiedMCNsByParent.put(account.ParentId, new List<Account>());
                    }
                    modifiedMCNsByParent.get(account.ParentId).add(account);
                }
                if (account.Assigned_MR__c != null && account.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED) {
                    if (!modifiedMCNsByAssignedMR.containsKey(account.Assigned_MR__c)) {
                        modifiedMCNsByAssignedMR.put(account.Assigned_MR__c, new List<Account>());
                    }
                    modifiedMCNsByAssignedMR.get(account.Assigned_MR__c).add(account);
                }
            }
        }

        if (!modifiedMCNsByParent.isEmpty() || !modifiedMCNsByAssignedMR.isEmpty()) {
            System.enqueueJob(new DTSFPART_PopulateMCNPermissions(modifiedMCNsByParent, modifiedMCNsByAssignedMR, DTSFPART_CommonStrings.CREATE_OPERATION));
        }
    }

    private static void refreshPermissions(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        Set<Id> createAllPermissions = new Set<Id>();
        Map<Id, Set<Id>> contactToAddPermissionForMcn = new Map<Id, Set<Id>>();
        DTSFPART_McnPermissionServiceWrapper wrapper = new DTSFPART_McnPermissionServiceWrapper();

        for (Id accountId : newAccounts.keySet()) {
			Account newAccount = newAccounts.get(accountId);
			Account oldAccount = oldAccounts.get(accountId);

            if(newAccount.RecordTypeId == mcnAccountRT){
                if(oldAccount.RecordTypeId != mcnAccountRT){
                    wrapper.addRecalculateAll(accountId);
                }

                if(newAccount.ParentId != oldAccount.ParentId && String.isNotBlank(newAccount.ParentId)){
                    wrapper.addRecaluclateByParent(newAccount.ParentId, accountId);
                }
                
                if(newAccount.ERP_Active__c && !oldAccount.ERP_Active__c){
                    wrapper.addRecalculateAll(accountId);
                }
                
                if(newAccount.Assigned_MR__c != oldAccount.Assigned_MR__c && String.isNotBlank(newAccount.Assigned_MR__c)){
                    wrapper.addRecaluclateByMR(newAccount.Assigned_MR__c, accountId);
                }

                if(newAccount.Assigned_MR_Sales_Person__c != oldAccount.Assigned_MR_Sales_Person__c && String.isNotBlank(newAccount.Assigned_MR_Sales_Person__c)){
                    if(!contactToAddPermissionForMcn.containsKey(accountId)){
                        contactToAddPermissionForMcn.put(accountId, new Set<Id>());
                    }

                    contactToAddPermissionForMcn.get(accountId).add(newAccount.Assigned_MR_Sales_Person__c);
                }
            }
        }

        if(!wrapper.recalculateAll.isEmpty() || !wrapper.recalculateByMR.isEmpty() || !wrapper.recalculateByParent.isEmpty()){
            DTSFPART_McnPermissionCreationService.create(wrapper);
        }
        if(!contactToAddPermissionForMcn.isEmpty()){
            DTSFPART_ContactPermissionService.create(contactToAddPermissionForMcn);
        }
    }

    private static void updateRelatedContacts(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        List<Id> syncedAccountIds = new List<Id>();
        for (Account newAccount : newAccounts.values()) {
            Account oldAccount = oldAccounts.get(newAccount.Id);
            if (
                newAccount.RecordTypeId == partnerAccountRT &&
                oldAccount.Enterprise_Permission_Status__c != DTSFPART_CommonStrings.COMPLETED &&
                newAccount.Enterprise_Permission_Status__c == DTSFPART_CommonStrings.COMPLETED
            ) {
                syncedAccountIds.add(newAccount.Id);
            }
        }

        if (!syncedAccountIds.isEmpty()) {
            markContactsInvited(syncedAccountIds);
        }
    }

    @Future
    private static void markContactsInvited(List<Id> syncedAccountIds) {
        List<Contact> contactsToUpdate = new List<Contact>();
        if (!syncedAccountIds.isEmpty()) {
            for (Contact contact : [SELECT Id, Status__c FROM Contact WHERE AccountId IN :syncedAccountIds AND Status__c = :DTSFPART_CommonStrings.PENDING_ONBOARDING]) {
                contact.Status__c = DTSFPART_CommonStrings.INVITED;
                contactsToUpdate.add(contact);
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    private void updateContactsEnterpriseStatus(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        Set<Id> updatedAccountIds = new Set<Id>();
        for (Account newAccount : newAccounts.values()) {
            if (
                newAccount.RecordTypeId == partnerAccountRT &&
                newAccount.Enterprise_Permission_Status__c == DTSFPART_CommonStrings.COMPLETED &&
                oldAccounts.containsKey(newAccount.Id) &&
                oldAccounts.get(newAccount.Id).Enterprise_Permission_Status__c != DTSFPART_CommonStrings.COMPLETED
            ) {
                updatedAccountIds.add(newAccount.Id);
            }
        }
        if (!updatedAccountIds.isEmpty()) {
            triggerContactsSync(updatedAccountIds);
        }
    }

    @Future
    private static void triggerContactsSync(Set<Id> updatedAccountIds) {
        if (!updatedAccountIds.isEmpty()) {
            List<Contact> contacts = [
                SELECT Id, Status__c, Enterprise_Permission_Status__c
                FROM Contact
                WHERE
                    AccountId IN :updatedAccountIds
                    AND Enterprise_Permission_Status__c = :DTSFPART_CommonStrings.IN_PROGRESS
                    AND Status__c != :DTSFPART_CommonStrings.INVITED
                    AND Status__c != :DTSFPART_CommonStrings.DEACTIVATION_REQUESTED
                    AND Delete_Requested__c != TRUE
            ];
            List<Contact> updatedContact = new List<Contact>();
            for (Contact contact : contacts) {
                if (contact.Status__c == DTSFPART_CommonStrings.ACTIVE) {
                    contact.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.TRIGGER_STATUS;
                    updatedContact.add(contact);
                }
                if (contact.Status__c == DTSFPART_CommonStrings.INVITED || contact.Status__c == DTSFPART_CommonStrings.REGISTRATION_COMPLETED) {
                    contact.Enterprise_Permission_Status__c = DTSFPART_CommonStrings.COMPLETED;
                    updatedContact.add(contact);
                }
            }
            if (!updatedContact.isEmpty()) {
                update updatedContact;
            }
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
    }
}