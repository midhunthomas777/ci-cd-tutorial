public class NewCustomerAccountRedirectExtn {
    public NewCustomerAccountRedirectExtn(ApexPages.StandardController controller){}
    public PageReference redirectPage() {
        Id userId = UserInfo.getUserId();
        Id userProfileId = UserInfo.getProfileId();
        Set<Id> profileSet = new Set<Id>();
        system.debug(' In New CustomerAccount RedirectExtn ');
        List<Profile> profileDetails = [SELECT Id, 
                                        Name 
                                        FROM Profile 
                                        WHERE UserLicense.Name = 'Partner Community']; 
        system.debug(' ProfileDetails '+ProfileDetails);
        
        for(Profile partnerProfile : profileDetails ){
            profileSet.add(partnerProfile.Id);
        }
        
        PageReference pageRef;
        Id accountId = ApexPages.currentPage().getParameters().get('id');
        if(profileSet.contains(userProfileId)){           
            pageRef = new PageReference('/partnercommunity/apex/New_CustomerAccountMR?='+accountId);        
            return pageRef;              
        }
        else{     
            system.debug(' In Else in NewCustomeAccountRedirection ');
            pageRef = new PageReference('/apex/New_CustomerAccountMR?='+accountId);        
            return pageRef; 
        }
        return null;
    }
}