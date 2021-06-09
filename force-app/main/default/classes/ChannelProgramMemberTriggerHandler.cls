public class ChannelProgramMemberTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    
    public void BeforeInsert(List<SObject> newItems){}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){
        /*Map<Id,ChannelProgramMember> newChannelProgramMembersMap = new Map<Id,ChannelProgramMember>();
        if(newItems != null) newChannelProgramMembersMap = (Map<Id,ChannelProgramMember>) newItems;
        
        /*if(!(System.isFuture() || System.isBatch())) {
            system.debug('######insertPartnerExecsToPublicGroupFuture###### isFuture => ' + newItems.size());
            insertPartnerExecsToPublicGroupFuture(newItems.keySet());    
        } else{
            insertPartnerExecsToPublicGroup(newItems.keySet());
        }*/
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){
        // We need to handle the deletion
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('ChannelProgramMemberTriggerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    //Public Group Name should be same as Channel Program Name
    /*@future
    public static void insertPartnerExecsToPublicGroupFuture(Set<Id> newMembers) {
        insertPartnerExecsToPublicGroup(newMembers);
    }
    
    public static void insertPartnerExecsToPublicGroup(Set<Id> newMembers){
        System.debug('Entered the Method Insertion to Public Group');
        Map<Id, ChannelProgramMember> memberMap = new Map<Id,ChannelProgramMember>(); 
        Set<String> programName = new Set<String>();
        Set<Id> partnerIds = new Set<Id>();
        for(ChannelProgramMember incomingMember:[SELECT Id,PartnerId,Program.DeveloperName__c FROM ChannelProgramMember WHERE Id IN:newMembers]){
            programName.add(incomingMember.Program.DeveloperName__c);
            memberMap.put(incomingMember.Id,incomingMember);
            partnerIds.add(incomingMember.PartnerId);
        }
        
        Map<Id,Id> partnerRoleMap =new Map<Id,Id>();
        
        for(UserRole usrRole:[SELECT Id, Name, PortalRole,PortalAccountId FROM UserRole 
                         WHERE PortalAccountId IN :partnerIds AND DeveloperName like '%PartnerExecutive%']){
                             partnerRoleMap.put(usrRole.PortalAccountId,usrRole.Id);
                         }
        
        Map<Id,Id> roleGrpMap = new Map<Id,Id>();
        for(Group grp:[SELECT Id,Type,RelatedId FROM Group WHERE 
                      RelatedId in :partnerRoleMap.values() AND Type='Role' AND DeveloperName like '%PartnerExecutive%']){
                          roleGrpMap.put(grp.RelatedId,grp.Id);
                      }
        
        Map<String,Id> publicGroupIdMap = new Map<String,Id>();
        for(Group publicGrp:[SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN:programName and Type='Regular']){
            publicGroupIdMap.put(publicGrp.DeveloperName,publicGrp.Id);
        }
        
        List<GroupMember> execRolesToBeAdded = new List<GroupMember>();
        
        for(ChannelProgramMember channelMember:memberMap.values()){
            if(publicGroupIdMap.get(memberMap.get(channelMember.Id).Program.DeveloperName__c) != null && partnerRoleMap.containsKey(channelMember.PartnerId)){
                GroupMember grpMem = new GroupMember();
                grpMem.UserOrGroupId = roleGrpMap.get(partnerRoleMap.get(channelMember.PartnerId));
                grpMem.GroupId = publicGroupIdMap.get(memberMap.get(channelMember.Id).Program.DeveloperName__c);
                execRolesToBeAdded.add(grpMem);  
            }
            
        }
        System.debug('execRolesToBeAdded###=>'+execRolesToBeAdded);
        if(execRolesToBeAdded.size()>0){
            Database.insert(execRolesToBeAdded,false);
        }
    }*/
}