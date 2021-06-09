@isTest
public class MRCPQ_NewQuoteControllerTest {

    @TestSetup
    static void setup() {
        TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    public static void newQuoteTest() {
        DTSFPART_ContactTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;

        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id prospectaccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();

        User partneruser = TestDataSetUpUtils.createPortalUser();

        Test.startTest();
        TestDataSetUpUtils.assignPermissionSet(partneruser.Id);
        Test.stopTest();

        System.runAs(partneruser){
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Account> lstProspectAccount = TestDataSetUpUtils.createProspectAccounts(1, prospectaccrectypeID);

            String result = MRCPQ_NewQuoteController.getAccountRecordTypeDeveloperNameWhenUserHasAccessToNewQuota(lstAccount.get(0).Id);
            String prospectResult = MRCPQ_NewQuoteController.getAccountRecordTypeDeveloperNameWhenUserHasAccessToNewQuota(lstProspectAccount.get(0).Id);

            MRCPQ_NewQuoteController.isPartnerUser();

            System.assertEquals('SoldToAccount', result);
            System.assertEquals('Prospect', prospectResult);
        }
    }
}