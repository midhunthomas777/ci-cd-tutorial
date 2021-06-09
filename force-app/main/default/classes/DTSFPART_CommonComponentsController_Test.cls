/**
 * Created by QGBC67 on 28.09.2020.
 */

@IsTest
public class DTSFPART_CommonComponentsController_Test {

    @TestSetup
    static void setup() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(currentUser) {
            TestDataSetUpUtils.insertCustomSettings();
        }
        UserTriggerHandler.TriggerDisabled = true;
        User admin = DTSFPART_TestDataSetUpUtils.createAdminUser();
        System.runAs(admin) {
            Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
            Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
            List<Contact> contacts = TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{acc});
            contacts.get(0).MailingCountryCode = 'PL';
            update contacts;
            User user = DTSFPART_TestDataSetUpUtils.createPartnerPortalUser(contacts[0].Id);
            System.debug('MPYC user ' + user.Id);
            System.debug('MPYC user Username ' + user.Username);
        }
    }

    @IsTest
    private static void getCustomerNumbers () {
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User user = [SELECT Id, Contact.Id FROM User WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER];
            List<Account> accounts;
            Test.startTest();
                System.runAs(user) {
                    accounts = DTSFPART_CommonComponentsController.getCustomerNumbers();
                }
            Test.stopTest();

            for(Account acc : accounts) {
                System.assert(acc.Motorola_Customer_Number__c !='');
            }
        }
    }

    @IsTest
    private static void callMulesoft() {
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
            Map<String, Object> opportunities = DTSFPART_CommonComponentsController.callMulesoft(
                    '',
                    'DTSFPART_MOL_OrderHistory',
                    '',
                    user.FederationIdentifier
            );
            Test.stopTest();
            System.assert(opportunities != null);
        }
    }

    @IsTest
    private static void callMulesoftCache() {
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
            Map<String, Object> opportunities = DTSFPART_CommonComponentsController.callMulesoftWithCache(
                    '',
                    'DTSFPART_MOL_OrderHistory',
                    '',
                    user.FederationIdentifier
            );
            Test.stopTest();
            System.assert(opportunities != null);
        }
    }

    @IsTest
    private static void callMyViewProxy() {
        Map<String, Object> response;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
        response = DTSFPART_CommonComponentsController.callMyViewProxy('{"method": "GET", "endpoint": "", "credentials": "Mulesoft_OAuth", "body": ""}');
        Test.stopTest();

        System.assert(!response.isEmpty());
        System.assert((Boolean) response.get('ok'));
        System.assertEquals('OK', response.get('statusText'));
        System.assertEquals(200, response.get('status'));
    }

    @IsTest
    private static void callMyViewFileProxy(){
        Map<String, Object> response;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
        response = DTSFPART_CommonComponentsController.callMyViewFileProxy(
                '{"method": "POST", "endpoint": ""}',
                '{"testParam1":"testValue"}',
                '[{"mime":"text/plan", "name": "test.txt", "key": "file", "data": "UmVtZWR5Q2FzZVRlc3QgYXR0YWNobWVudA"}]}');
        Test.stopTest();

        System.assert(!response.isEmpty());
        System.assert((Boolean) response.get('ok'));
        System.assertEquals('OK', response.get('statusText'));
        System.assertEquals(200, response.get('status'));
    }

    @IsTest
    private static void addRemedyAttachment(){
        Map<String, Object> response;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
        response = DTSFPART_CommonComponentsController.addRemedyAttachment(
                '{"metadata":"DTSFPART_Add_Attachment_To_Ticket","credentials":"Mulesoft_OAuth","federationId":true}',
                '{' +
                        '"values": {' +
                        '"Incident Number": "INC000003309657",' +
                        '"Work Log Submitter":"intmyview",' +
                        '"z1D Action": "CREATE",' +
                        '"Work Log Type": "General Information",' +
                        '"View Access": "Internal",' +
                        '"Secure Work Log": "No",' +
                        '"Detailed Description": "Add your description",' +
                        '"z2AF Work Log01": "chattext.txt"' +
                        '}' +
                    '}',
                '[{"name":"remedyCaseTest.txt","mime":"text/plain","key":"attach-z2AF Work Log01","data":"UmVtZWR5Q2FzZVRlc3QgYXR0YWNobWVudA=="}]');
        Test.stopTest();

        System.assert(!response.isEmpty());
        System.assert((Boolean) response.get('ok'));
        System.assertEquals('SUCCESS', response.get('statusText'));
        System.assertEquals(200, response.get('status'));
    }

    @IsTest
    private static void testJWTToken(){
        String jwtToken;
        Test.startTest();
            jwtToken = DTSFPART_CommonComponentsController.generateCustomerNumberJson('123');
        Test.stopTest();

        System.assert(String.isNotBlank(jwtToken));
    }

    @IsTest
    private static void getCustomerCountry(){
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {

            User user = [SELECT Id, Contact.AccountId FROM User WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER];

            String countryCode;
            Test.startTest();
            System.runAs(user) {
                countryCode = DTSFPART_CommonComponentsController.getCustomerCountry();
            }
            Test.stopTest();

            System.assertEquals('US', countryCode);
        }
    }
}