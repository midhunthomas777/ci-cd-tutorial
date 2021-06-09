@isTest
public class DTSFPART_ContactStatusControllerTest {
   
    private static final String ACCOUNT_NAME = 'DTSFPART_ContactStatusControllerTest Account';

    @TestSetup
    static void setup(){
        Id partnerRTId = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Partner');
        Account account = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerRTId, true);
        account.Partner_Hub_Enabled__c = true;
        account.Name = ACCOUNT_NAME;
        update account;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = DTSFPART_TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{account});
        
        contacts[0].Enterprise_Permission_Status__c = 'In Progress';
        contacts[0].Status__c = 'Active';

        update contacts;
    }

    @isTest
    public static void getContactStatusTest() {

        Test.startTest(); 
        List<Contact> contacts = [ SELECT Id FROM Contact LIMIT 1 ];
        DTSFPART_ContactStatusController.contactWrapper contactWrapper = DTSFPART_ContactStatusController.getContactStatus(contacts[0]?.Id);
        Test.stopTest();

        System.assertEquals('In Progress', contactWrapper.enterpriseStatus);
    }
}