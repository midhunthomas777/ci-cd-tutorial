public inherited sharing class DTSFPART_UserInfoService {
    
    private static User currentUser;

    public static Id getCurrentUserContactAccountId() {
        return getCurrentUserDetailInfo()?.Contact?.AccountId;
    }

    public static Id getCurrentUserContactId() {
        return getCurrentUserDetailInfo()?.ContactId;
    }

    public static User getCurrentUserDetailInfo() {
        if (currentUser == null) {
            currentUser = [ SELECT Id, ContactId, Contact.AccountId
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        }
        return currentUser;
    }
}