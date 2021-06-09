public with sharing class DTSFPART_CommunityRedirectController {

    public class RedirectResponse {
        @AuraEnabled
        public Boolean isSuccess = true;
        @AuraEnabled
        public Boolean redirectUser = true;
        @AuraEnabled
        public String destinationBasedUrl = null;

        public RedirectResponse(Boolean isSuccess, 
                                Boolean redirectUser, 
                                String destinationBasedUrl) {
            this.isSuccess = isSuccess; 
            this.redirectUser = redirectUser;  
            this.destinationBasedUrl = destinationBasedUrl;                     
        }
    }

    @AuraEnabled(cacheable=true)
    public static RedirectResponse getCommunityBasedUrl(Id currentNetworkId, Boolean isRedirectPage, String newNewNetworkName, String legacyNetworkName, String ignoredProfiles) {

        Id newNetworkId = null;
        Id legacyNetworkId = null;

        for (Network network : [ SELECT Id, Name, UrlPathPrefix
                                 FROM Network
                                 WHERE Name IN :new List<String>{ newNewNetworkName, legacyNetworkName } ]) {          
            if (network.Name == newNewNetworkName) {
                newNetworkId = network.Id;
            } else if (network.Name == legacyNetworkName) {
                legacyNetworkId = network.Id;
            }
        }

        try {

            Boolean isPartnerHubEnabled =  [ SELECT Id, Account.Partner_Hub_Enabled__c 
                                             FROM User
                                             WHERE Id = :UserInfo.getUserId() ]?.Account?.Partner_Hub_Enabled__c;

            List<Id> networkIdWhereCurrentUserIsMember = new List<Id>();

            for (NetworkMember networkMember : [ SELECT Id, MemberId, NetworkId 
                                                 FROM NetworkMember 
                                                 WHERE NetworkId IN :new List<Id>{ newNetworkId, legacyNetworkId }  
                                                 AND MemberId = :UserInfo.getUserId() ]) {

                networkIdWhereCurrentUserIsMember.add(networkMember.NetworkId);                                                                          
            }

            String userProfileName = [ SELECT Id, Name 
                                       FROM Profile 
                                       WHERE Id =: userinfo.getProfileId()].Name;

            if (ignoredProfiles.split(';').contains(userProfileName)) { //peoples with ignored profiles are not redirected
                return new RedirectResponse(true, false, ''); //do nothing, user will stay on current page
            } else if (networkIdWhereCurrentUserIsMember.contains(newNetworkId) && currentNetworkId == newNetworkId && isPartnerHubEnabled && isRedirectPage) {
                return new RedirectResponse(true, true, ConnectApi.Communities.getCommunity(newNetworkId)?.siteUrl + '/s'); //redirect to new community
            } else if (networkIdWhereCurrentUserIsMember.contains(newNetworkId) && currentNetworkId == newNetworkId && isPartnerHubEnabled && !isRedirectPage) {
                return new RedirectResponse(true, false, ''); //do nothing, user will stay on current page
            } else if (networkIdWhereCurrentUserIsMember.contains(legacyNetworkId) && currentNetworkId == newNetworkId && !isPartnerHubEnabled) {
                return new RedirectResponse(true, true, ConnectApi.Communities.getCommunity(legacyNetworkId)?.siteUrl + '/s'); //redirect to legacy community
            } else if (networkIdWhereCurrentUserIsMember.contains(newNetworkId) && currentNetworkId == legacyNetworkId && isPartnerHubEnabled) {
                return new RedirectResponse(true, true, ConnectApi.Communities.getCommunity(newNetworkId)?.siteUrl + '/s'); //redirect to new community
            } else if (networkIdWhereCurrentUserIsMember.contains(legacyNetworkId) && currentNetworkId == legacyNetworkId && !isPartnerHubEnabled) {
                return new RedirectResponse(true, false, ''); //do nothing, user will stay on current page
            } else {
                return new RedirectResponse(false, true, ConnectApi.Communities.getCommunity(newNetworkId)?.siteUrl + '/s'); //redirect to error page
            }              
        } catch (Exception e) {
            return new RedirectResponse(false, true, ConnectApi.Communities.getCommunity(newNetworkId)?.siteUrl + '/s'); //redirect to error page
        }
    }
}