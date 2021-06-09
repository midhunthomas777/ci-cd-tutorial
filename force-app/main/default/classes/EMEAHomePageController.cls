public without sharing class EMEAHomePageController {
    
    @AuraEnabled
    public static List<User> getKeyContacts(){
        List<User> currentUser = new List<User>();
        currentUser = [Select AccountId, Id from User Where Id =: UserInfo.getUserId()];
            return [Select Id,Contact.Name,Contact.Email,Contact.Phone from User where AccountId =: currentUser[0].AccountId
                    AND IsPortalEnabled = true and IsActive = true and Contact.Tag__c includes ('SFDC Partner Admin')];
    }
}