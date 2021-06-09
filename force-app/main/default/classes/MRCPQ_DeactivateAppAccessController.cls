public class MRCPQ_DeactivateAppAccessController {
    @AuraEnabled
    public Static Boolean deactivateAppAccess(){
        List<User> usr = [SELECT Id,Profile.name FROM user WHERE Id =: UserInfo.getUserId() AND Profile.name=:'EMS Partner Administrator Profile NAMR'];
        if(usr.size()>0){
            return true;
        }else{
            return false;
        }
    }
    @AuraEnabled
    public Static void deactivateApplicationAccess(String applicationAccessId){
        CPQUtilityWithoutSharing.deactivateApplicationAccess(applicationAccessId);
    }
     @AuraEnabled
    public Static void reactivateApplicationAccess(String applicationAccessId){
        CPQUtilityWithoutSharing.reactivateApplicationAccess(applicationAccessId);
    }
}