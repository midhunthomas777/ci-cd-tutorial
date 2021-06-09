@isTest
public class DTSFPART_AccountC360SyncAPITest {
    
    @isTest
    static void getAccountC360Sync_SuccessTest() {

        Account account = new Account();

        Id partnerRecordType = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
        Account partnerAccount = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerRecordType, true);

        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/account/c360sync';
        request.httpMethod = 'GET';
        request.params.put('accountId', partnerAccount.Id);

        RestContext.request = request;

        List<Account> accounts = new List<Account>();
        try {
            Test.startTest();
            accounts = DTSFPART_AccountC360SyncAPI.getAccountC360Sync();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e == null);
        }

        System.assertEquals(1, accounts.size());
    }

    @isTest
    static void getAccountC360Sync_FailureTest() {

        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/account/c360sync';
        request.httpMethod = 'GET';
        request.params.put('accountId', 'Invalid Id');

        RestContext.request = request;

        List<Account> accounts = new List<Account>();
        try {
            Test.startTest();
            accounts = DTSFPART_AccountC360SyncAPI.getAccountC360Sync();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e != null);
        }

        System.assertEquals(0, accounts.size());
    }
}