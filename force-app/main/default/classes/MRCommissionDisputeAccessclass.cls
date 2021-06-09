public class MRCommissionDisputeAccessclass {
    
    @future
    public static void provideaccess(List<id> usrids, Id psId) {
        Set<Id> userUniqueIds = new Set<Id>();
        for(Id userId : usrids) {
            userUniqueIds.add(userId);
        }
        List<PermissionSetAssignment> newPermissionSetAccess = new List<PermissionSetAssignment>();
        for(Id usr : userUniqueIds) {     
            PermissionSetAssignment newPSA = new PermissionSetAssignment(); //PermissionSetAssignment sobject
            newPSA.PermissionSetId = psId; //set the permission set Id
            newPSA.AssigneeId = usr; //set the User Id
            newPermissionSetAccess.add(newPSA); //add the record to the list
        }
        
        if (!newPermissionSetAccess.isEmpty()) { //if there are records to insert
            system.debug('entering into new PSAssignment');
            if(!Test.isRunningTest()) { 
                insert newPermissionSetAccess; //insert   
            }
        }
    }
    
    @future 
    public static void removeaccess(List<Id> usrids){
        List<PermissionSetAssignment>p=[select id from PermissionSetAssignment where id in :usrids];
        delete p;
    }
}