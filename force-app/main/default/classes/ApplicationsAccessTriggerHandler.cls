/************************************************************************************************
* Description : This class is handler for Applications_Access__c object
on Applications Access object.
* Author : Adilraza Shaikh
* Date :  20th Sep 2018
**********************************************************************************************/
public class ApplicationsAccessTriggerHandler implements ITriggerHandler {
    public static Boolean triggerDisabled = false;
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Applications_Access__c> newItemsMap = new Map<Id,Applications_Access__c>();
        Map<Id,Applications_Access__c> oldItemsMap = new Map<Id,Applications_Access__c>();
        if(newItems != null) newItemsMap = (Map<Id,Applications_Access__c>) newItems;
        if(oldItems != null) oldItemsMap = (Map<Id,Applications_Access__c>) oldItems;
        
        Set<Id> assignPermissionSetContactIds = new Set<Id>();
        Set<Id> revokePermissionSetContactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Id incomingAppStatusId : newItemsMap.keySet()) {
            Applications_Access__c oldAppStatus = oldItemsMap.get(incomingAppStatusId);
            Applications_Access__c newAppStatus = newItemsMap.get(incomingAppStatusId);
            List<Contact> conUserList = new List<Contact>();
            conUserList = [SELECT User__c FROM Contact WHERE Id =: newAppStatus.Contact__c AND User__c!=null];
            if(!conUserList.isEmpty()){
                for(Contact con:conUserList){                    
					userIds.add(con.User__c);                    
                }                 
            }                       
            system.debug('Outer incommingAppContact #######' +newAppStatus.Contact__c);
            system.debug('Outer App Con Userid #####' + userIds);
            if(newAppStatus.App_Access_Status__c != NULL && newAppStatus.App_Access_Status__c != oldAppStatus.App_Access_Status__c) {
                if(newAppStatus.App_Access_Status__c == 'Active'){
                    system.debug('incommingAppContact #######' +newAppStatus.Contact__c);
                    system.debug('App Con Userid #####' + userIds);
                    if(!userIds.isEmpty()){
                    	oracleUserCreation(userIds);
                    }
                    assignPermissionSetContactIds.add(newAppStatus.Contact__c);
                }
                if(newAppStatus.App_Access_Status__c == 'InActive'){
                    revokePermissionSetContactIds.add(newAppStatus.Contact__c);
                }
            }
            Map<Id,User> conUsers = new Map<Id, User>([Select Id From User where ContactId IN : assignPermissionSetContactIds]);
            TagBasedPermissionSets.assignBulkIndividualsPS(conUsers.keySet(), 'CPQ_Permission_Sets');
            //PermissionSetsHelper.revokeCPQPermissionSetsByContact(revokePermissionSetContactIds, new Set<String>{'NA_CPQ_User'});
            PermissionSetsHelper.revokePermissionSetsByMetaTag(revokePermissionSetContactIds, new Set<String>{'CPQ_Permission_Sets'});
        }
    }
    public void BeforeInsert(List<SObject> newItems){
        List<Applications_Access__c> newItemsList = new List<Applications_Access__c>();
        if(newItems != null) newItemsList = (List<Applications_Access__c>) newItems;
        Schema.DescribeFieldResult userGroupFieldResult =Applications_Access__c.User_Groups__c.getDescribe();
        List<Schema.PicklistEntry> userGroupEntries = userGroupFieldResult.getPicklistValues();
        String userGroup='';
        for( Schema.PicklistEntry entry : userGroupEntries){
            userGroup=entry.getValue()+';'+userGroup;   
        }       
        for(Applications_Access__c appAcess : newItemsList){
            if(appAcess.App_Name__c=='CPQ' && appAcess.App_Access_Status__c==null){
                appAcess.User_Groups__c=userGroup;
            }
        }
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterInsert(Map<Id, SObject> newItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    /*public Boolean isDisabled(){ 
        DeactivatePLTrigger__c Isactive = DeactivatePLTrigger__c.getValues('DeativateContactTrigger');     
        if (!Isactive.Deactivate__c) {
            return false;   
        } else {
            return TriggerDisabled;   
        }
    }*/
    //MR Digital  
    public Boolean isDisabled(){
        
        if (TriggerSettings__c.getValues('ApplicationAccessTriggerDisabled').IsActive__c){
            return true;
        } else{
            return TriggerDisabled;
        }
    }
    //MR Digital  
    //@future
    public static void oracleUserCreation(Set<Id> UserIds){
        system.debug('Oracle USer ###' + UserIds);
        List<BigMachines__Oracle_User__c> oracleUserList = new List<BigMachines__Oracle_User__c>();
        Id activeOracleSiteId =[Select Id from BigMachines__Configuration_Record__c where BigMachines__Is_Active__c =True].Id;
        if(UserIds.size()>0)
        {
            for(Id userId:UserIds){
                BigMachines__Oracle_User__c  oracleuser = new BigMachines__Oracle_User__c();
                oracleuser.BigMachines__Allow_Quote_Creation__c = true;
                oracleuser.BigMachines__Association_to_Organization__c = 'Partner User';
                oracleuser.BigMachines__Access_Type__c ='SalesAgent';
                oracleuser.BigMachines__Salesforce_User__c = userId;
                oracleuser.BigMachines__Oracle_CPQ_Cloud_Site__c= activeOracleSiteId;
                oracleUserList.add(oracleuser);
            }
            if(!oracleUserList.isEmpty()){
                Database.insert(oracleUserList);
            }  
        }
    }
}