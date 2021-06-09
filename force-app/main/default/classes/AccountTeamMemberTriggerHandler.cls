/*******************************************************************************
* Description : Handler class for Account Team Member
* Author : Anand Sengunthar
* Date : 24th March 2020
******************************************************************************/
public class AccountTeamMemberTriggerHandler implements ITriggerHandler {
    public Boolean isDisabled(){        
        return TriggerSettings__c.getValues('AccountTeamMemberTriggerDisabled').IsActive__c;
    }
    public void beforeInsert(List<SObject> newItems){
        List<AccountTeamMember> newList = new List<AccountTeamMember>();
        if(newItems != null) newList = (List<AccountTeamMember>) newItems;
        Set<Id> userIds = new Set<Id>();
        for(AccountTeamMember acntTeamMember : newList){
            userIds.add(acntTeamMember.UserId);
            if(string.isNotBlank(acntTeamMember.TeamMemberRole) && (!GlobalUtility.isPicklistValuesFromValueSet('AccountTeamMember', 'TeamMemberRole', acntTeamMember.TeamMemberRole))){
                acntTeamMember.addError(system.label.Picklist_Value_Incorrect);
            }
        }
        Map<Id,User> mapExternalUsers = new Map<Id,User>([SELECT Id FROM User WHERE UserType != 'Standard' AND Id IN : userIds]);
        if(!mapExternalUsers.isEmpty()){
            for(AccountTeamMember acntTeamMember : newList){
                if(acntTeamMember.Quote_Access__c != 'Private' && mapExternalUsers.containsKey(acntTeamMember.UserId)){
                    acntTeamMember.addError(System.Label.External_User_Quote_Access_Error);
                }
            }
        }
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,AccountTeamMember> mapOldAccATM = new Map<Id,AccountTeamMember>();
        Map<Id,AccountTeamMember> mapNewAccATM = new Map<Id,AccountTeamMember>();
        if(oldItems != null) mapOldAccATM = (Map<Id,AccountTeamMember>) oldItems;
        if(newItems != null) mapNewAccATM = (Map<Id,AccountTeamMember>) newItems;
        Set<String> setAccTeamMemberAccId = new Set<String>();
        Set<String> setAccOwner = new Set<String>();
        Set<Id> setAccOwnerRole = new Set<Id>();
        Set<Id> setSubroles = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(AccountTeamMember acntTeamMember : mapNewAccATM.values()){
            if(string.isNotBlank(acntTeamMember.TeamMemberRole) && (!GlobalUtility.isPicklistValuesFromValueSet('AccountTeamMember', 'TeamMemberRole', acntTeamMember.TeamMemberRole))){
                acntTeamMember.addError(system.label.Picklist_Value_Incorrect);
            }
            AccountTeamMember oldatm = mapOldAccATM.get(acntTeamMember.Id);
            if(acntTeamMember.Quote_Access__c != oldatm.Quote_Access__c){
                setAccTeamMemberAccId.add(acntTeamMember.AccountId);
                userIds.add(acntTeamMember.UserId);
            } 
        }
        Map<Id,User> mapExternalUsers = new Map<Id,User>([SELECT Id FROM User WHERE UserType != 'Standard' AND Id IN : userIds]);
        if(!mapExternalUsers.isEmpty()){
            for(AccountTeamMember acntTeamMember : mapNewAccATM.values()){
                if(acntTeamMember.Quote_Access__c != 'Private' && mapExternalUsers.containsKey(acntTeamMember.UserId)){
                    acntTeamMember.addError(System.Label.External_User_Quote_Access_Error);
                }
            }
        }
        for(Account acc :[SELECT Id,ownerId,Owner.userRoleId FROM Account WHERE Id IN:setAccTeamMemberAccId]){
            //setAccOwner.add(acc.ownerId); //Booking owner
            setAccOwnerRole.add(acc.Owner.userRoleId);
        }
        /*if(!setAccOwner.isEmpty()){
            for(User userList : [SELECT Id,userRoleId FROM User WHERE Id IN :setAccOwner AND IsActive = True]){
                setAccOwnerRole.add(userList.userRoleId);
            }
        }*/
        if(!setAccOwnerRole.isEmpty() && !Test.isRunningTest()){
            setSubroles = GlobalUtility.getAllSubRoleIds(setAccOwnerRole);
        }
        for(AccountTeamMember accts :mapNewAccATM.values()) {
            if(setSubroles.contains(userinfo.getUserRoleId())){
                accts.addError('You are not allowed to Edit "Quote Access" Field');
            }
        }  
    }
    public void beforeDelete(Map<Id, SObject> oldItems){}
    public void afterInsert(Map<Id, SObject> newItems){        
        Map<Id,AccountTeamMember> mapNewAccTeamMember = new Map<Id, AccountTeamMember>();
        Set<String> setATMAdded = new Set<String>();
        Set<Id> AccountIds = new Set<Id>();
        Set<Id> setExistingGoogleDriveInfo = new Set<Id>();
        Set<Id> setAccTeamMemberIdToShare = new Set<Id> ();
        List<BigMachines__Quote__Share> lstQuoteShare = new List<BigMachines__Quote__Share>();
        if(newItems != null){
            mapNewAccTeamMember = (Map<Id,AccountTeamMember>) newItems;
        }  
        for (AccountTeamMember atm : mapNewAccTeamMember.values()){
            //SF-2143
             if(atm.Quote_Access__c == 'Read/Write'){ 
                setAccTeamMemberIdToShare.add(atm.UserId);
            }
            AccountIds.add(atm.AccountId);
        }
         //SF-2143
        if(!setAccTeamMemberIdToShare.isEmpty()){
            List<BigMachines__Quote__c> lstquotes =[SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Account__c In :AccountIds
                                                    AND OwnerId NOT IN: setAccTeamMemberIdToShare];
            system.debug('lstquotes'+lstquotes);
            if(!lstquotes.isEmpty()){
                for(Id usrId: setAccTeamMemberIdToShare){
                    for(BigMachines__Quote__c quote : lstquotes){
                        lstQuoteShare.add(new BigMachines__Quote__Share(
                            ParentId = quote.Id,
                            AccessLevel = 'Edit',
                            UserOrGroupId = usrId));
                    }
                }
            }
        }
        if(!lstQuoteShare.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstQuoteShare, true);
        }
        //New Google Drive Changes
        for(Google_Drive_Folder__c gd :[SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name =: AccountIds AND Parent_Name__c = NULL]){
            setExistingGoogleDriveInfo.add(gd.Name);
        }        
        for(AccountTeamMember atm : [SELECT Id,AccountId,Quote_Access__c FROM AccountTeamMember WHERE Id IN: mapNewAccTeamMember.keySet() AND AccountId IN : setExistingGoogleDriveInfo AND User.UserType = 'Standard' AND Quote_Access__c = 'Read/Write']) {
            setATMAdded.add(atm.Id+';'+atm.AccountId);
        }
        if(!setATMAdded.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(new List<String>(setATMAdded),'Create');
        }
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,AccountTeamMember> mapOldAccTeamMember = new Map<Id, AccountTeamMember>();
        Map<Id,AccountTeamMember> mapNewAccTeamMember = new Map<Id,AccountTeamMember>();
        if(oldItems != null) mapOldAccTeamMember = (Map<Id,AccountTeamMember>) oldItems;
        if(newItems != null) mapNewAccTeamMember = (Map<Id,AccountTeamMember>) newItems;
        Set<Id> accountIds = new Set<Id>();
        Set<String> changesATMIds = new Set<String>();
        Set<String> revokeATMIds = new Set<String>();
        List<BigMachines__Quote__Share> lstQuoteShare = new List<BigMachines__Quote__Share>();
        List<BigMachines__Quote__Share> lstQuoteShareToDelete = new List<BigMachines__Quote__Share>();
        Set<Id> setAccTeamMemberIdToShare = new Set<Id> ();
        Set<Id> setAccTMIdToRevoke = new Set<Id> ();
        Set<Id> setQuoteIdToBeRevoked = new Set<Id> ();
        Set<String> setAccountOpp = new Set<String>();
        Set<Id> setExistingGoogleDriveInfo = new Set<Id>();
        for (AccountTeamMember atm: mapNewAccTeamMember.values()){
            AccountTeamMember oldatm = mapOldAccTeamMember.get(atm.Id);            
            if(atm.Quote_Access__c == 'Read/Write' && oldatm.Quote_Access__c != atm.Quote_Access__c ){ //SF-2143
                setAccTeamMemberIdToShare.add(atm.UserId);
                system.debug('setAccTeamMemberIdToShare'+setAccTeamMemberIdToShare);
            }
            if(atm.Quote_Access__c == 'Private' && oldatm.Quote_Access__c != atm.Quote_Access__c ){//SF-2143
                setAccTMIdToRevoke.add(atm.UserId);
                system.debug('setAccTMIdToRevoke'+setAccTMIdToRevoke);
            }
            accountIds.add(atm.AccountId);
        }
        //SF-2143
        if(!setAccTeamMemberIdToShare.isEmpty()){
            List<BigMachines__Quote__c> lstquotes =[SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Account__c IN :accountIds
                                                    AND OwnerId NOT IN: setAccTeamMemberIdToShare];
            system.debug('lstquotes'+lstquotes);
            if(!lstquotes.isEmpty()){
                for(Id usrId: setAccTeamMemberIdToShare){
                    for(BigMachines__Quote__c quote : lstquotes){
                        lstQuoteShare.add(new BigMachines__Quote__Share(
                            ParentId = quote.Id,
                            AccessLevel = 'Edit',
                            UserOrGroupId = usrId));
                    }
                }
            }
        }
        //SF-2143
        if(!setAccTMIdToRevoke.isEmpty()){
            for(OpportunityTeamMember otm : [SELECT Id,OpportunityId FROM OpportunityTeamMember WHERE Opportunity.AccountId IN: AccountIds
                                             AND UserId IN:setAccTMIdToRevoke]){
                                                 setAccountOpp.add(otm.OpportunityID);
                                             }
            for(BigMachines__Quote__c quote : [SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Account__c IN : AccountIds
                                               AND BigMachines__Opportunity__c NOT IN: setAccountOpp AND OwnerId NOT IN: setAccTMIdToRevoke]){
                                                   setQuoteIdToBeRevoked.add(quote.Id);
                                               } 
            if(!setQuoteIdToBeRevoked.isEmpty()){
                lstQuoteShareToDelete =[SELECT Id,parentId,UserOrGroupId FROM BigMachines__Quote__Share WHERE parentId IN :setQuoteIdToBeRevoked
                                        AND UserOrGroupId IN:setAccTMIdToRevoke ];
            }
        }
        //SF-2143
        if(!lstQuoteShare.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstQuoteShare, true);
        }
        //SF-2143
        if(!lstQuoteShareToDelete.isEmpty()){
            Database.DeleteResult[] delList = Database.delete(lstQuoteShareToDelete, true);
        }
        //SF-2223 Google Drive Changes
        for(Google_Drive_Folder__c gd :[SELECT Id,Name  FROM Google_Drive_Folder__c WHERE Name =: accountIds AND Parent_Name__c = NULL]){
            setExistingGoogleDriveInfo.add(gd.Name); 
        }
        for(AccountTeamMember actm : [SELECT Id,userId,AccountId,Quote_Access__c,User.Email,Account.OwnerId FROM AccountTeamMember WHERE Id IN: mapNewAccTeamMember.keySet() AND AccountId IN : setExistingGoogleDriveInfo AND User.UserType = 'Standard']) {
            AccountTeamMember oldAccTM = mapOldAccTeamMember.get(actm.Id);            
            if(actm.Quote_Access__c != oldAccTM.Quote_Access__c && actm.Quote_Access__c == 'Read/Write'){
                changesATMIds.add(actm.Id+';'+actm.AccountId);
            }
            if(actm.Quote_Access__c != oldAccTM.Quote_Access__c && actm.Quote_Access__c == 'Private' && actm.userId != actm.Account.OwnerId ){
                revokeATMIds.add(actm.AccountId+';'+actm.User.Email);
            }
        }
        if(!changesATMIds.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(new List<String>(changesATMIds),'Update');    
        }
        if(!revokeATMIds.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(new List<String>(revokeATMIds),'RevokePermission');    
        }
    }
    public void afterDelete(Map<Id, SObject> oldItems){
        Map<Id,AccountTeamMember> mapOldAccATM = new Map<Id, AccountTeamMember>();
        if(oldItems != null) mapOldAccATM = (Map<Id,AccountTeamMember>) oldItems;
        Set<String> setATMDeleted = new Set<String>();
        Map<Id,AccountTeamMember> mapDeleteAccAccess = new Map<Id,AccountTeamMember>();
        Set<Id> AccountIds = new Set<Id>();
        Map<Id,String> mapATMUserAccIds = new Map<Id,String>();
        Map<Id,String> mapATMQuoteUserAccIds = new Map<Id,String>();
        Set<String> existingGDriveAccIds = new Set<String>();
        Set<Id> setQuoteIdToBeRevoked = new Set<Id> ();
        Set<String> setAccountOpp = new Set<String>();
        Map<String,String> mapAccountOwnerId = new Map<String,String>();
        List<BigMachines__Quote__Share> lstQuoteShareToDelete = new List<BigMachines__Quote__Share>();
        for(AccountTeamMember atm: mapOldAccATM.values()){
            mapATMUserAccIds.put(atm.userId,atm.AccountId);
            if(atm.Quote_Access__c == 'Read/Write'){
             mapATMQuoteUserAccIds.put(atm.userId,atm.AccountId);   
            }
        }
        for(Account acc : [SELECT Id,ownerID FROM Account WHERE Id IN : mapATMQuoteUserAccIds.values()]){
            mapAccountOwnerId.put(acc.Id,acc.ownerID);
        }
        //SF-2223 Google Drive Changes
        for(Google_Drive_Folder__c gdrive : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: mapATMQuoteUserAccIds.values() AND Parent_Name__c = NULL]){
            existingGDriveAccIds.add(gdrive.Name);
        }
        if(!mapATMQuoteUserAccIds.isEmpty()){
            for(User usr : [SELECT Id, Email FROM User WHERE Id IN: mapATMQuoteUserAccIds.keySet() AND UserType = 'Standard']){
                if(existingGDriveAccIds.contains(mapATMQuoteUserAccIds.get(usr.Id))){
                    String accId = mapATMQuoteUserAccIds.get(usr.Id);
                    String accownerId = mapAccountOwnerId.get(accId);
                    if(usr.Id != accownerId){
                        setATMDeleted.add(accId+';'+usr.Email);
                    }
                }
            }
        }
        if(!mapATMUserAccIds.isEmpty()){
            //SF-2143
            for(OpportunityTeamMember otm:[SELECT Id,OpportunityId FROM OpportunityTeamMember WHERE Opportunity.AccountId IN:mapATMUserAccIds.values()
                                           AND UserId IN:mapATMUserAccIds.keyset()]){
                                               setAccountOpp.add(otm.OpportunityID);
                                           }
            for(BigMachines__Quote__c quote :[SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Account__c IN :mapATMUserAccIds.values()
                                              AND BigMachines__Opportunity__c  NOT IN:setAccountOpp AND OwnerId NOT IN:mapATMUserAccIds.keyset()]){
                                                  setQuoteIdToBeRevoked.add(quote.Id);
                                              } 
            if(!setQuoteIdToBeRevoked.isEmpty()){
                lstQuoteShareToDelete = [SELECT Id,parentId,UserOrGroupId FROM BigMachines__Quote__Share WHERE parentId IN :setQuoteIdToBeRevoked
                                         AND  UserOrGroupId IN:mapATMUserAccIds.keyset()];
            }
        } 
        //SF-2143
        if(!lstQuoteShareToDelete.isEmpty()){ 
            Database.DeleteResult[] delList = Database.delete(lstQuoteShareToDelete, true);
        } 
        //SF-2223 Google Drive Changes
        if(!setATMDeleted.isEmpty()){ 
            GoogleDriveUtility.googleDriveFunctions(new List<String>(setATMDeleted),'RevokePermission');    
        }
    }
    
    public void afterUndelete(Map<Id, SObject> oldItems){}
}