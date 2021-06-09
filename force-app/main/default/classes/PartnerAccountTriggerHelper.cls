public class PartnerAccountTriggerHelper {
    
    public void sharePartnerAccountsPartnerRoles(Map<Id, SObject> newItems, Map<Id, SObject> oldItem){
        Set<Id> partnerAccountIds = new Set<Id>();
        for(Account acctIncoming : (List<Account>)newItems.values()){
            if(acctIncoming.Role_Created__c && acctIncoming.IsPartner){
                Account oldAccount = (Account)oldItem.get(acctIncoming.Id);
                if(acctIncoming.Role_Created__c != oldAccount.Role_Created__c || acctIncoming.Owner__c != oldAccount.Owner__c){
                    partnerAccountIds.add(acctIncoming.Id);
                }  
            }
        }
        
        // Added by Harish - if Condition as part of SF-1493
        if(!partnerAccountIds.isEmpty()){
            insertPartnerAccShareRecords(partnerAccountIds);
        }
    }
    
    public void insertPartnerAccShareRecords(Set<Id> partnerAccountIds){
        System.debug('insertPartnerAccShareRecords ENTERED');
        Map<Id,Set<Id>> accIdRoleIdMap = new Map<Id, Set<Id>>(); 
        Map<Id,String> roleIdNameMap = new Map<Id,String>();
        Map<String,String> groupMap = new Map<String,String>();
        List<UserRole> userRoleList = [SELECT Id, Name, DeveloperName,PortalRole,PortalAccountId
                                       FROM UserRole 
                                       WHERE PortalAccountId IN :partnerAccountIds AND PortalAccountId!=null AND
                                       (DeveloperName like '%PartnerExecutive%' OR DeveloperName like '%PartnerManager%' OR DeveloperName like '%PartnerUser%')];
        
        System.debug('insertPartnerAccShareRecords ENTERED userRoleList###=>'+userRoleList);
        for(UserRole uRole : userRoleList){
            roleIdNameMap.put(uRole.Id,uRole.DeveloperName);
            
            if(!accIdRoleIdMap.containsKey(uRole.PortalAccountId)){
                accIdRoleIdMap.put(uRole.PortalAccountId,new Set<Id>());
            }
            accIdRoleIdMap.get(uRole.PortalAccountId).add(uRole.Id);
            
        }
        
        for(Group grp : [select id,Type,RelatedId from Group where Type='Role' and RelatedId in :roleIdNameMap.keySet()]){
            groupMap.put(grp.RelatedId,grp.Id);
        }
        
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        for(Id acctIncomingId : partnerAccountIds){
            if(accIdRoleIdMap.containsKey(acctIncomingId)) {
                for(Id roleId:accIdRoleIdMap.get(acctIncomingId)){
                    if(roleIdNameMap.get(roleId).contains('PartnerExecutive')){
                        accountShareInsertList.add(createAccountShare('Edit', 'None', acctIncomingId, groupMap.get(roleId)));
                    }else{
                        accountShareInsertList.add(createAccountShare('Read', 'None', acctIncomingId, groupMap.get(roleId)));
                    }
                }
            }
        }
        
        if(!accountShareInsertList.isEmpty()){
            Database.insert(accountShareInsertList,false);   
        }
    }
    
    public void runAddUpdateGroupsToUserMPP(Map<Id, Account> oldItems, Map<Id, Account> newItems, boolean isUpdate) {
        if(!MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning) {
            MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = true;
            MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(oldItems, newItems, isUpdate);
        }
    }
    
    public void runDeleteGroupsToUserMPP(Map<Id, Account> oldItems) {
        if(!MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning) {
            MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = true;
            MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(oldItems);
        }
    }    
    
    private AccountShare createAccountShare(String readEdit, String none, Id recordId, Id userGroupId) {
        return new AccountShare(
            AccountAccessLevel = readEdit,
            ContactAccessLevel = readEdit,
            CaseAccessLevel = none,
            OpportunityAccessLevel = none,
            AccountId = recordId,
            UserOrGroupId = userGroupId
        );
    }
}