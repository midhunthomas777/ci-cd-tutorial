@isTest
public class DTSFPART_ContactC360SyncAPITest {
    
    @isTest
    static void getContactC360Sync_SuccessTest() {

        Account account = new Account();

        Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Account partnerAccount = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerRecordType, true);
        Contact contact =  DTSFPART_TestDataSetUpUtils.createPartnerContact(partnerAccount, true);

        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/contact/c360sync';
        request.httpMethod = 'GET';
        request.params.put('contactId', contact.Id);

        RestContext.request = request; 

        List<Contact> contacts = new List<Contact>();

        try {
            Test.startTest();
                contacts = DTSFPART_ContactC360SyncAPI.getContactC360Sync();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e == null);
        }

        System.assertEquals(1, contacts.size());
    }

    @isTest
    static void getContactC360Sync_FailureTest() {

        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/contact/c360sync';
        request.httpMethod = 'GET';
        request.params.put('contactId', 'Invalid Id');

        RestContext.request = request;

        List<Contact> contacts = new List<Contact>();

        try {
            Test.startTest();
                contacts = DTSFPART_ContactC360SyncAPI.getContactC360Sync();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e != null);
        }

        System.assertEquals(0, contacts.size());
    }
}