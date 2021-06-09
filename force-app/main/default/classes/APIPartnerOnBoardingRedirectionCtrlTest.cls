@isTest
public class APIPartnerOnBoardingRedirectionCtrlTest {
    @isTest private static void generateAccessCodeTest(){
        TestDataSetUpUtils.insertCustomSettings();
        test.startTest();
        API_Partner_Application__c apiPartner;
        USer u = TestDataSetUpUtils.createGuestUser();
        System.RunAs(u){
            apiPartner = TestDataSetUpUtils.createAPIPartnerAppl();
        }
        APIPartnerOnBoardingRedirectionCtrl.generateAccessCode(apiPartner.Id);
        apiPartner.Access_Code__c='ed72fde7-aec0-4f9f-9393-b6aa43304c67';
        update apiPartner;
        APIPartnerOnBoardingRedirectionCtrl.getRecordId(apiPartner.Access_Code__c);
        APIPartnerOnBoardingRedirectionCtrl.getRecordId(null);
        test.stopTest();
    }
}