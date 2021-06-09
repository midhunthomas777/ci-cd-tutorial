@isTest
public class DTSFPART_UserInfoServiceTest {
    
    @isTest
    static void getCurrentUserDetailInfoTest() {
        User currentUser = null;
        Id accountId = null;
        Id contactId = null;

        Test.startTest();
        currentUser = DTSFPART_UserInfoService.getCurrentUserDetailInfo();
        accountId = DTSFPART_UserInfoService.getCurrentUserContactAccountId();
        contactId = DTSFPART_UserInfoService.getCurrentUserContactId();
        Test.stopTest();

        System.assert(currentUser != null);
    }
}