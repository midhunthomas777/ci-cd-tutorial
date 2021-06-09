/**
* @author ACCENTURE
* @date March 2020
* @description Controller for MotoCommunityHeader Component
*/
public class MotoCommunityHeaderController{
    
    /****************************************************
*@description Wrapper class for user details
*@param NA
*@return NA
*/
    public class UserDetails{
        @AuraEnabled public String firstName;
        @AuraEnabled public Id accountId;
        @AuraEnabled public Boolean isVestaPartnerAdmin;
        @AuraEnabled public SamlSsoConfig sso;
    }
    
    /****************************************************
*@description Returns User details
*@param NA
*@return Object of User details
*/
    @AuraEnabled
    public static UserDetails getUserDetails(String communityName) {
        system.debug('######communityName####### => ' + communityName);
        UserDetails userDetails = new UserDetails();        
        // Get current user details
        List<User> currentUser = [SELECT Id, FirstName, AccountId FROM User where Id =:UserInfo.getUserId() and UserType != 'Guest'];
        List<Profile> currentProfile = [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1];
        String currentProfileName = currentProfile[0].Name;
        if(!currentUser.isEmpty()) {
            userDetails.firstName = currentUser[0].FirstName;
            userDetails.accountId = currentUser[0].AccountId;
        }
        // check if user is added to Vesta Partner Admin perission set
        if (currentProfileName.equalsIgnoreCase('Vesta Partner Community Admin with CC License')
                || currentProfileName.equalsIgnoreCase('Vesta Partner Community Admin with CCP License')) {
            userDetails.isVestaPartnerAdmin = true;
        } else {
            userDetails.isVestaPartnerAdmin = false;
        }
        
        List<SamlSsoConfig> sso = [Select Id,LoginUrl,LogoutUrl,SingleLogoutUrl from SamlSsoConfig where MasterLabel =: communityName LIMIT 1];
        if(!sso.isEmpty()) {
            userDetails.sso = sso.get(0);
        }
        
        return userDetails;
    }
    
}