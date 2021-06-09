@isTest
public class DTSFPART_DashboardComponentsHelperTest {
   
    private static final String ACCOUNT_NAME = 'DTSFPART_ContactStatusControllerTest Account';

    @TestSetup
    static void setup(){
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        Id partnerRTId = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Partner');
        Account account = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerRTId, true);
        account.Partner_Hub_Enabled__c = true;
        account.Name = ACCOUNT_NAME;
        update account;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = DTSFPART_TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{account});

        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User user = null;

        System.runAs(thisUser) {
            user = DTSFPART_TestDataSetUpUtils.createPartnerPortalUser(contacts[0].Id);
        }    
    }
    
    @isTest
    public static void saveCurrentUserSettingsTest() {
        User thisUser = [ SELECT Id, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];

        System.runAs(thisUser) {
            DTSFPART_DashboardComponentsHelper.saveCurrentUserSettings('Test');
        }

        List<Contact> contacts = [ SELECT Id, DTSFPART_Dashboard_Settings__c, DTSFPART_Partner_Portal_Logged__c FROM Contact LIMIT 1 ];
        System.assertEquals('Test', contacts[0].DTSFPART_Dashboard_Settings__c);
    }

    @isTest
    public static void updatePartnerPortalFlagTest() {
        User thisUser = [ SELECT Id, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];

        System.runAs(thisUser) {
            DTSFPART_DashboardComponentsHelper.updatePartnerPortalFlag();
        }

        List<Contact> contacts = [ SELECT Id, DTSFPART_Dashboard_Settings__c, DTSFPART_Partner_Portal_Logged__c FROM Contact LIMIT 1 ];
        System.assertEquals(true, contacts[0].DTSFPART_Partner_Portal_Logged__c);
    }
}