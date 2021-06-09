public class PartnerWelcomeMessageCls {

    @AuraEnabled
    public static String getAccountManager() {
        return [SELECT Contact.Account.Owner.Name FROM User WHERE Id =: UserInfo.getUserId()].Contact.Account.Owner.Name;
    }
}