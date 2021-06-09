public class MPP_Class_CTRL_UserGroups { 
    private ApexPages.StandardController controller {get; set;}
    private User u;
    public List<Group> groupList {get;set;}
 
    public MPP_Class_CTRL_UserGroups(ApexPages.StandardController controller) {
 		User u = (User)controller.getRecord();
 		Set<Id> groupIds = new Set<Id>();
 		for(GroupMember gm : [Select GroupId FROM GroupMember WHERE UserOrGroupId = :u.Id]){
 			groupIds.add(gm.GroupId);
 		}
 		
 		groupList = new List<Group>();
 		for(Group g : [Select g.Type, g.SystemModstamp, g.RelatedId, g.OwnerId, g.Name, g.LastModifiedDate, g.LastModifiedById, g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses, g.DeveloperName, g.CreatedDate, g.CreatedById From Group g
 					   WHERE Id IN :groupIds]){
 			groupList.add(g);			   	
		}
 
    }
}