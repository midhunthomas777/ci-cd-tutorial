@isTest
public class PartnerOnBoardingRedirectionCtrlTest {
    @isTest private static void generateAccessCodeTest(){
        TestDataSetUpUtils.insertCustomSettings();
        test.startTest();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        PartnerOnBoardingRedirectionCtrl.generateAccessCode(empower.Id);
        empower.Access_Code__c='ed72fde7-aec0-4f9f-9393-b6aa43304c67';
        update empower;
        PartnerOnBoardingRedirectionCtrl.getRecordId(empower.Access_Code__c);
        PartnerOnBoardingRedirectionCtrl.getRecordId(null);
        test.stopTest();
    }
}