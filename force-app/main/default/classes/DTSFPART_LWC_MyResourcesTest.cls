@isTest
public class DTSFPART_LWC_MyResourcesTest {

    private static final String ACCOUNT_NAME = 'DTSFPART_LWC_MyResourcesTest Account';

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
    private static void getImportantLinksTest() {
         User thisUser = [ SELECT Id, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];
                          
        List<Dashboard_My_Resources_Important_Links__mdt> myResourceImportantLinks = new List<Dashboard_My_Resources_Important_Links__mdt>();

        Test.startTest();
        System.runAs(thisUser) {
            myResourceImportantLinks = DTSFPART_LWC_MyResources.getImportantLinks('Partner Hub', 'US', 'NAMR');
        }
        Test.stopTest();
        System.assertNotEquals(0, myResourceImportantLinks.size());
    }

    @isTest
    private static void getUserLinksTest() {
        User thisUser = [ SELECT Id, ContactId, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];
                          
        Contact cnt = new Contact(Id = thisUser.ContactId, DTSFPART_Dashboard_My_Resources_Links__c = 'a');
        update cnt;

        String resouceLinks = null;      

        Test.startTest();
        System.runAs(thisUser) {
            resouceLinks = DTSFPART_LWC_MyResources.getUserLinks();
        }
        Test.stopTest();
        System.assertNotEquals(null, resouceLinks);
    }

    /* PW Not possible to trigger error in such simple query
    @isTest
    private static void getUserLinksCatchTest() {
        User thisUser = [ SELECT Id, ContactId, email 
        FROM User 
        WHERE email='test123asdfresdf@noemail.com' ];

        String resouceLinks = null;      

        Test.startTest();
            resouceLinks = DTSFPART_LWC_MyResources.getUserLinks();
        Test.stopTest();
        System.assertNotEquals(null, resouceLinks);
    }*/

    @isTest
    private static void saveUserLinksTest() {
        User thisUser = [ SELECT Id, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];
        Test.startTest();
        System.runAs(thisUser) {
            DTSFPART_LWC_MyResources.saveUserLinks('Test');
        }
        Test.stopTest();
    }

    @isTest
    private static void saveUserLinksCatchTest() {
        Exception expException;
        Test.startTest();
            try {
                DTSFPART_LWC_MyResources.saveUserLinks('Test');
            } catch (Exception e){
                expException = e;
            }
        Test.stopTest();
        System.assert(expException != null);
    }
}