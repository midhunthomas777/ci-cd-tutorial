/*******************************************************************************
* Description : For community partner logo management. 
* Date : 27th Apr 2018
* Test Class- PartnerLevelLogoCls
*******************************************************************************/
public class PartnerLevelLogoCls {
    @AuraEnabled
    public static LogoWrapper getPartnerLevelLogo(){
        List<User> accLevel = [SELECT Contact.Account.Metal_Level__c,Contact.Account.Partner_Region__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(String.isNotBlank(accLevel.get(0).Contact.Account.Metal_Level__c)) {
            if(accLevel.get(0).Contact.Account.Metal_Level__c == 'Registered' && (accLevel.get(0).Contact.Account.Partner_Region__c == 'EMEA' 
                                                                                  || accLevel.get(0).Contact.Account.Partner_Region__c == 'NAMR'))
            {
                return new LogoWrapper(Site.getBaseUrl(),'NO_DATA');
            }
            List<Document> instOfDocList = [SELECT Id FROM Document WHERE Name =:accLevel.get(0).Contact.Account.Metal_Level__c LIMIT 1];
            if(instOfDocList.size() > 0) {
                return new LogoWrapper(Site.getBaseUrl(),instOfDocList.get(0).Id);   
            }
        } else if(String.isBlank(accLevel.get(0).Contact.Account.Metal_Level__c)) {
            List<Document> instOfDocList = [SELECT Id FROM Document WHERE DeveloperName = 'EADistributor' LIMIT 1];
            if(instOfDocList.size() > 0)
                return new LogoWrapper(Site.getBaseUrl(),instOfDocList.get(0).Id);
        }
        return null;
    }
    
    public class LogoWrapper {
        @AuraEnabled
        public String siteBaseUrl;
        @AuraEnabled
        public String docId;
        public LogoWrapper(String siteBaseUrl,String docId) {
            this.siteBaseUrl = siteBaseUrl;
            this.docId = docId;
        }
    }
}