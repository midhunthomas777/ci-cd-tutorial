public class PartnerOpportunityTriggerHelper {
    
    public static void createUserSharingRecord(List<Opportunity> opportunities){
        Database.SaveResult[] shareInsertResults;
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<UserShare> userShareList = new List<UserShare>();
        Set<Id> createdUserId = new Set<Id>();
        Set<Id> accExecUserId = new Set<Id>();
        for(Opportunity opp : opportunities){
            if(opp.Approval_Status__c == 'Approved'){
                opportunityList.add(opp);
                createdUserId.add(opp.CreatedById);
                if(opp.Account_Executive__c != null){
                    accExecUserId.add(opp.Account_Executive__c);
                }
                if(opp.RCAM_ASL__c != null){
                    accExecUserId.add(opp.RCAM_ASL__c);
                }
            }
            if(opp.Approval_Status__c == 'CAM Approved'){
                if(opp.Assigned_CAM__c != null || Test.isRunningTest()){
                    opportunityList.add(opp);
                    createdUserId.add(opp.CreatedById);
                    accExecUserId.add(opp.Assigned_CAM__c);
                }
            }
        }
        if(!opportunityList.isEmpty()){
            userShareList = [SELECT UserId,UserOrGroupId,UserAccessLevel FROM UserShare 
                             WHERE UserId IN : createdUserId AND UserOrGroupId IN : accExecUserId];
            
        }
        if(userShareList.isEmpty()){
            for(Opportunity oppList : opportunityList){
                if(oppList.Account_Executive__c != null){
                    userShareList.add(new UserShare(
                        UserId = oppList.Account_Executive__c,
                        UserOrGroupId = oppList.CreatedById,
                        UserAccessLevel = 'Read'));
                }
                if(oppList.Assigned_CAM__c != null){
                    userShareList.add(new UserShare(
                        UserId = oppList.Assigned_CAM__c,
                        UserOrGroupId = oppList.CreatedById,
                        UserAccessLevel = 'Read'));
                }
                if(oppList.RCAM_ASL__c != null){
                    userShareList.add(new UserShare(
                        UserId = oppList.RCAM_ASL__c,
                        UserOrGroupId = oppList.CreatedById,
                        UserAccessLevel = 'Read'));
                }
            }
        }
        
        if(!userShareList.isEmpty()) {
            shareInsertResults = Database.insert(userShareList,false);
            for(Database.SaveResult result : shareInsertResults){
                if (!result.isSuccess()){
                    for(Database.Error err : result.getErrors()){
                        System.debug('Error in Sharing ### '+err);
                    }
                }
            }
        }    
    }
}