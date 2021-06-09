public class OpportunitySubAccountTriggerHelper {
    
    public static void upsertMCN(Set<Id> subaccountIds,List<SubAgency__c> subAccounts,Set<Id> siteIds,Boolean isSubAccountChanged,Set<Id> opportunityIds){
        Map<Id,List<Account>> mcnAccountsWithParentId = new Map<Id,List<Account>>();
        Map<Id,Boolean> secondaryAccountWIthNOMCN = new Map<Id,Boolean>();
        Map<Id,List<String>> oppAccMap = new Map<Id,List<String>>();
        Map<Id,List<String>> accountANDSIteMap = new Map<Id,List<String>>();
        Map<Id,Id> oppPurchasingEntityMap = new Map<Id,Id>();
        Map<Id,Id> siteIdWithMCN = new Map<Id,Id>();
        Set<Id> mcnAccountIds = new Set<ID>();
        
        for(Account mcnRecord : [SELECT ParentId,ID,NAME,Parent.RecordType.DeveloperName FROM Account WHERE ParentId 
                                 IN : subaccountIds AND RecordType.DeveloperName = 'Motorola_Customer_Number' AND 
                                 (Parent.RecordType.DeveloperName = 'SoldToAccount' OR Parent.RecordType.DeveloperName = 'Partner')])
        { 
            if(mcnAccountsWithParentId.get(mcnRecord.ParentId) != NULL){
                List<Account> mcnAccounts = mcnAccountsWithParentId.get(mcnRecord.ParentId);
                mcnAccountIds.add(mcnRecord.Id);
                mcnAccounts.add(mcnRecord); 
            } 
            else{
                mcnAccountIds.add(mcnRecord.Id);
                mcnAccountsWithParentId.put(mcnRecord.ParentId,new List<Account>{mcnRecord});
            } 
        }
        for(Technical_Site__c siteRecord : [SELECT Id,MCN_Account__c FROM Technical_Site__c WHERE Id IN :siteIds]){
            siteIdWithMCN.put(siteRecord.Id,siteRecord.MCN_Account__c);
        }
        for(Account secondaryAccount : [SELECT Id,RecordType.DeveloperName FROM ACCOUNT WHERE Id IN : subaccountIds AND 
                                        (RecordType.DeveloperName = 'SoldToAccount' OR RecordType.DeveloperName = 'Partner')])
        {
            secondaryAccountWIthNOMCN.put(secondaryAccount.Id, true); 
        }
        for(SubAgency__c subAccount : [SELECT Id,Sub_Account__c,MCN_Account__c,Opportunity__c,End_User_Site__c,Opportunity__r.Purchasing_Entity__c 
                                       FROM SubAgency__c WHERE Opportunity__c IN : opportunityIds])
        {
            String subAccountANDMCNId = subAccount.Sub_Account__c+':'+subAccount.MCN_Account__c;
            String accountMCNANDSite = subAccount.Sub_Account__c+':'+subAccount.MCN_Account__c+':'+subAccount.End_User_Site__c;
            if(oppAccMap.containsKey(subAccount.Opportunity__c)){
                List<String> subAccountANDMCNList = oppAccMap.get(subAccount.Opportunity__c);
                List<String> accountMCNANDSiteList = accountANDSIteMap.get(subAccount.Opportunity__c);
                subAccountANDMCNList.add(subAccountANDMCNId);
                accountMCNANDSiteList.add(accountMCNANDSite);
                oppAccMap.put(subAccount.Opportunity__c,subAccountANDMCNList);
                accountANDSIteMap.put(subAccount.Opportunity__c,accountMCNANDSiteList);
            } 
            else{
                oppAccMap.put(subAccount.Opportunity__c,new List<String>{subAccountANDMCNId});
                accountANDSIteMap.put(subAccount.Opportunity__c, new List<String>{accountMCNANDSite});
                oppPurchasingEntityMap.put(subAccount.Opportunity__c,subAccount.Opportunity__r.Purchasing_Entity__c);
            } 
        }
        for(SubAgency__c eachSubAccount : subAccounts){
            Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(null, 'SpillmanQuoteValidationMessages');
            List<String> existingAccIDs = oppAccMap.get(eachSubAccount.Opportunity__c);
            List<String> existingAccountSiteMCN = accountANDSIteMap.get(eachSubAccount.Opportunity__c);
            if(String.isBlank(eachSubAccount.Billing_Agency__c)){
                eachSubAccount.Billing_Agency__c = oppPurchasingEntityMap.get(eachSubAccount.Opportunity__c);
            }
            if(!mcnAccountsWithParentId.isEmpty() && mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c) != null){
                if(mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c).size() == 1){
                    eachSubAccount.MCN_Account__c = mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c)[0].Id;
                }else if(mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c).size() > 1 && String.isBlank(eachSubAccount.MCN_Account__c) &&
                   String.isNotBlank(eachSubAccount.End_User_Site__c))
                {
                    eachSubAccount.MCN_Account__c = siteIdWithMCN.get(eachSubAccount.End_User_Site__c);
                }
                if((String.isBlank(eachSubAccount.MCN_Account__c) || !mcnAccountIds.contains(eachSubAccount.MCN_Account__c)) &&
                   mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c).size() > 1 && String.isBlank(eachSubAccount.End_User_Site__c))
                {
                    eachSubAccount.addError(alertMessageMap.get('SecondaryAcc_With_More_Than_One_MCN').Message__c);
                }else if((existingAccIDs != NULL || existingAccountSiteMCN != NULL) && isSubAccountChanged){
                    if(String.isBlank(eachSubAccount.End_User_Site__c) && oppAccMap.containsKey(eachSubAccount.Opportunity__c) && 
                       mcnAccountsWithParentId.get(eachSubAccount.Sub_Account__c).size() > 0 &&
                       existingAccIDs.contains(eachSubAccount.Sub_Account__c+':'+eachSubAccount.MCN_Account__c))
                    {
                        eachSubAccount.addError(alertMessageMap.get('Duplicate_SecondaryAcc_With_MCN_Check').Message__c);
                    }else if(existingAccountSiteMCN != NULL){
                        if(existingAccountSiteMCN.contains(eachSubAccount.Sub_Account__c+':'+eachSubAccount.MCN_Account__c+':'+eachSubAccount.End_User_Site__c)) 
                        {
                            eachSubAccount.addError(alertMessageMap.get('Duplicate_SecondaryAcc_With_MCNSite').Message__c);
                        }
                    }
                }
            }else if(secondaryAccountWIthNOMCN.containsKey(eachSubAccount.Sub_Account__c) && secondaryAccountWIthNOMCN.get(eachSubAccount.Sub_Account__c) &&
                     String.isBlank(eachSubAccount.MCN_Account__c))
            { 
                eachSubAccount.addError(alertMessageMap.get('Secondary_Acc_With_No_MCN_Check').Message__c);
            }else if(oppAccMap.containsKey(eachSubAccount.Opportunity__c) && existingAccIDs.contains(eachSubAccount.Sub_Account__c+':'+null) &&
                     String.isBlank(eachSubAccount.End_User_Site__c) && isSubAccountChanged)
            {
                eachSubAccount.addError(alertMessageMap.get('Duplicate_Secondary_Account_Check').Message__c);
            }
        }
    }
    
    public static void insertOppSubAgency(List<SubAgency__c> subAccounts){
        Set<Id> subaccountIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for(SubAgency__c eachSubAccount : subAccounts){
            subaccountIds.add(eachSubAccount.Sub_Account__c);
            if(String.isNotBlank(eachSubAccount.Opportunity__c)){
                opportunityIds.add(eachSubAccount.Opportunity__c);
            }
            if(String.isNotBlank(eachSubAccount.End_User_Site__c)){
                siteIds.add(eachSubAccount.End_User_Site__c);
            }
        }
        upsertMCN(subaccountIds,subAccounts,siteIds,true,opportunityIds);   
    }
    
    public static void updateOppSubAgency(Map<Id,SubAgency__c> newRecords,Map<Id,SubAgency__c> oldRecords){
        Set<Id> subaccountIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Boolean isSubAccountChanged = false;
        List<SubAgency__c> subAccounts = new List<SubAgency__c>();
        Set<Id> opportunityIds = new Set<Id>();
        for(SubAgency__c eachSubAccount : newRecords.values()){
            SubAgency__c oldSubAccount = (SubAgency__c)oldRecords.get(eachSubAccount.Id);
            subAccounts.add(eachSubAccount);
            subaccountIds.add(eachSubAccount.Sub_Account__c);
            if(String.isNotBlank(eachSubAccount.Opportunity__c)){
                opportunityIds.add(eachSubAccount.Opportunity__c);
            }
            
            if(eachSubAccount.Sub_Account__c != oldSubAccount.Sub_Account__c){
                isSubAccountChanged = true;
            }
            if(String.isNotBlank(eachSubAccount.End_User_Site__c)){
                siteIds.add(eachSubAccount.End_User_Site__c);
            }
        }
        
        if(!subAccounts.isEmpty()){
            upsertMCN(subaccountIds,subAccounts,siteIds,isSubAccountChanged,opportunityIds);
        }
    }
}