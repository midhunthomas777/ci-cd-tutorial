/*******************************************************************************
* Description : Handler class for Opportunity Team Member
* Author : Anand Sengunthar
* Date : 24th March 2020
******************************************************************************/
public class OpportunityTeamMemberTriggerHandler implements ITriggerHandler {
    OpportunityTeamMemberTriggerHelper otmHelper = new OpportunityTeamMemberTriggerHelper();
	public Boolean isDisabled(){        
        return TriggerSettings__c.getValues('OpportunityTeamMemberTriggerDisabled').IsActive__c;
    }
    public void beforeInsert(List<SObject> newItems){
        List<OpportunityTeamMember> newList = new List<OpportunityTeamMember>();
        if(newItems != null) newList = (List<OpportunityTeamMember>) newItems;
        for(OpportunityTeamMember opptyTeamMember : newList){
            if(string.isNotBlank(opptyTeamMember.TeamMemberRole) && (!GlobalUtility.isPicklistValuesFromValueSet('OpportunityTeamMember', 'TeamMemberRole', opptyTeamMember.TeamMemberRole))){
                opptyTeamMember.addError(system.label.Picklist_Value_Incorrect);
            }
        }
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        for(OpportunityTeamMember opptyTeamMember:(List<OpportunityTeamMember>)newItems.values()){
            if(string.isNotBlank(opptyTeamMember.TeamMemberRole) && (!GlobalUtility.isPicklistValuesFromValueSet('OpportunityTeamMember', 'TeamMemberRole', opptyTeamMember.TeamMemberRole))){
                opptyTeamMember.addError(system.label.Picklist_Value_Incorrect);
            }
        }
    }
    public void beforeDelete(Map<Id, SObject> oldItems){
        Map<Id,OpportunityTeamMember> mapOldOpptyOTM = new Map<Id, OpportunityTeamMember>();        
        Map<Id,OpportunityTeamMember> oldOTMMap = new Map<Id,OpportunityTeamMember>();
        if(oldItems != null){
            oldOTMMap = (Map<Id,OpportunityTeamMember>) oldItems;
        }        
        for(OpportunityTeamMember otm:oldOTMMap.values()){           
            mapOldOpptyOTM.put(otm.OpportunityId, otm);
        }
        if(!mapOldOpptyOTM.keyset().isEmpty()){
            otmHelper.deleteShare(mapOldOpptyOTM);
        }        
    }
    public void afterInsert(Map<Id, SObject> newItems){        
        Map<Id,OpportunityTeamMember> mapOpptyOTM = new Map<Id, OpportunityTeamMember>();
        Set<Id> setExistingGoogleDriveInfo = new Set<Id>();
        Set<String> setOTMAdded = new Set<String>();
        List<Id> nonRunRateIds = new List<Id>();
        Set<Id> oppIds = new Set<Id>(); 
        for(OpportunityTeamMember opptyTeamMember:(List<OpportunityTeamMember>)newItems.values()){           
            if(opptyTeamMember.UserId!= null){               
                mapOpptyOTM.put(opptyTeamMember.OpportunityId, opptyTeamMember);
            }
            oppIds.add(opptyTeamMember.OpportunityId);
        }
        if(!mapOpptyOTM.keyset().isEmpty()){
            otmHelper.addNewShare(mapOpptyOTM);
        }
        /*for(Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN : oppIds AND RecordType.DeveloperName = 'Government_Standard']){
            nonRunRateIds.add(opp.Id);
        }
        if(!nonRunRateIds.isEmpty()){
            GoogleDriveSetpermissions.FolderPermissions(nonRunRateIds);
        }*/
        //SF-2223 Google Drive Changes
        for(Google_Drive_Folder__c gd :[SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name =: oppIds AND Parent_Name__c = NULL]){
            setExistingGoogleDriveInfo.add(gd.Name);
        }
        for(OpportunityTeamMember otm : [SELECT Id,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: setExistingGoogleDriveInfo 
                                         AND Id IN : newItems.keySet() AND Opportunity.RecordType.DeveloperName = 'Government_Standard' AND User.UserType ='Standard']) {   
                                             setOTMAdded.add(otm.Id+';'+otm.OpportunityId);
                                         } 
        if(!setOTMAdded.isEmpty()){
            system.debug('OpportunityTeamMember'+setOTMAdded);
            GoogleDriveUtility.googleDriveFunctions(new List<String>(setOTMAdded),'Create');
            system.debug('after OpportunityTeamMember'+setOTMAdded);
        }    
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,OpportunityTeamMember> mapOldOpptyOTM = new Map<Id, OpportunityTeamMember>();
        Map<Id,OpportunityTeamMember> mapNewOpptyOTM = new Map<Id, OpportunityTeamMember>();        
        Map<Id,OpportunityTeamMember> mapNewOpptyTeamMember = new Map<Id,OpportunityTeamMember>();
        Map<Id,OpportunityTeamMember> mapOldOpptyTeamMember = new Map<Id,OpportunityTeamMember>();
        if(newItems != null) mapNewOpptyTeamMember = (Map<Id,OpportunityTeamMember>) newItems;
         if(oldItems != null) mapOldOpptyTeamMember = (Map<Id,OpportunityTeamMember>) oldItems;
        
        Set<Id> OTMIds = new Set<Id>();
        Set<String> changesOTMIds = new Set<String>();
        Set<Id> setExistingGoogleDriveInfo = new Set<Id>();
        
        for(OpportunityTeamMember otm: mapNewOpptyTeamMember.values()){            
            mapNewOpptyOTM.put(otm.OpportunityId, otm);
			OpportunityTeamMember oldOpptyTM = (OpportunityTeamMember) oldItems.get(otm.Id);            
       		System.debug('+++Update++++'+otm.UserId);                         
            if (oldOpptyTM.UserId!=null){
                 mapOldOpptyOTM.put(oldOpptyTM.OpportunityId, oldOpptyTM);      
            }                                   
            System.debug('+++Update++++'+otm.UserId);                  
            //addNewShare(otm);  
       }
       if(!mapOldOpptyOTM.keyset().isEmpty()){
            otmHelper.deleteShare(mapOldOpptyOTM);
       }
       if(!mapNewOpptyOTM.keyset().isEmpty()){
            otmHelper.addNewShare(mapNewOpptyOTM);
       }       
        //SF-2223 Google Drive Changes
        //system.debug('mapNewOpptyOTM'+mapNewOpptyOTM);
        for(Google_Drive_Folder__c gd :[SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name =: mapNewOpptyOTM.keySet() AND Parent_Name__c = NULL]){
            setExistingGoogleDriveInfo.add(gd.Name);
        }
        system.debug('setExistingGoogleDriveInfo'+setExistingGoogleDriveInfo);
        for(OpportunityTeamMember otm : [SELECT Id,OpportunityId,OpportunityAccessLevel FROM OpportunityTeamMember
                                         WHERE OpportunityId IN: setExistingGoogleDriveInfo AND Opportunity.RecordType.DeveloperName = 'Government_Standard'
                                         AND Id IN : mapNewOpptyTeamMember.keySet() AND User.UserType = 'Standard' ]) {
                                             OpportunityTeamMember oldOpptyTM = mapOldOpptyTeamMember.get(otm.Id); 
                                             system.debug('oldOpptyTM**'+oldOpptyTM);
                                             if(otm.OpportunityAccessLevel != oldOpptyTM.OpportunityAccessLevel){
                                                 changesOTMIds.add(otm.Id+';'+otm.OpportunityId);
                                             }
                                         }       
        //SF-2223 Google Drive Changes
        if(!changesOTMIds.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(new List<String>(changesOTMIds),'Update');    
        }
    }
    public void afterDelete(Map<Id, SObject> oldItems){
        Map<Id,OpportunityTeamMember> mapOldOpptyOTM = new Map<Id, OpportunityTeamMember>();
        Set<String> setOTMDeleted = new Set<String>();
        Map<Id,String> mapOTMUserOppIds = new Map<Id,String>();
        Set<String> existingGDriveOppIds = new Set<String>();
        Map<String,String> mapOpportunityOwnerId = new Map<String,String>();
        if(oldItems != null) mapOldOpptyOTM = (Map<Id,OpportunityTeamMember>) oldItems;
        //SF-2223 Google Drive Changes
        for(OpportunityTeamMember otm : mapOldOpptyOTM.values()) {
            system.debug('otm.Opportunity.OwnerId==>' + otm.Opportunity.OwnerId);
            if(otm.Opportunity.OwnerId != otm.userId){
                mapOTMUserOppIds.put(otm.userId,otm.OpportunityId);
            }
        }
        for(Opportunity opp : [SELECT Id,ownerID FROM Opportunity WHERE Id IN : mapOTMUserOppIds.values()]){
            mapOpportunityOwnerId.put(opp.Id,opp.ownerID);
        }
        for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: mapOTMUserOppIds.values() AND Parent_Name__c = NULL]){
            existingGDriveOppIds.add(gdrive.Name);
        }
        if(!mapOTMUserOppIds.isEmpty()){
            for(User usr : [SELECT Id, Email FROM User WHERE Id IN: mapOTMUserOppIds.keySet() AND UserType = 'Standard']){
                if(existingGDriveOppIds.contains(mapOTMUserOppIds.get(usr.Id))){
                    String oppId = mapOTMUserOppIds.get(usr.Id);
                    String oppOwnerId = mapOpportunityOwnerId.get(oppId);
                    if(usr.Id != oppOwnerId){
                        setOTMDeleted.add(oppId+';'+usr.Email);
                    }
                }
            }
        }
        if(!setOTMDeleted.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(new List<String>(setOTMDeleted),'RevokePermission');  
            System.debug('After Delete OTM==>'+setOTMDeleted);
        }
    }
    public void afterUndelete(Map<Id, SObject> oldItems){}          
}