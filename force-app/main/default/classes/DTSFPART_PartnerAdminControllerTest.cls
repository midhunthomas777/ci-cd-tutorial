@isTest
public class DTSFPART_PartnerAdminControllerTest {
   
    @TestSetup
    static void setup(){
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

        Account partnerAccount = DTSFPART_TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId, true);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Canada';
        partnerAccount.BillingState='Alberta';
        partnerAccount.BillingCountryCode = 'CA';
        partnerAccount.BillingStateCode = 'AB';
        update partnerAccount;

        Empower_Application__c empower = DTSFPART_TestDataSetUpUtils.createPartnerEmpower();
        empower.Main_place_of_business_Country__c='Canada';
        empower.Main_place_of_business_State__c = 'Alberta';
        empower.Partner_Application_Status__c='Approved';
        empower.Are_You_Authorized_to_Sign_Legal_Agmt__c='No';
        update empower;

        MPEContact__c newContact = new MPEContact__c(Application__c=empower.Id,Account__c=partnerAccount.Id,Last_Name__c='test',
                                                     First_Name__c='test1',Email__c='test@test.com',Phone__c='123',
                                                     Primary_Language__c='English');
        insert newContact;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = DTSFPART_TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{partnerAccount});

        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User user = null;

        System.runAs(thisUser) {
            user = DTSFPART_TestDataSetUpUtils.createPartnerPortalUser(contacts[0].Id);
        }   
    }

    @isTest
    private static void getExistingDetailsTest() {
        MPEContact__c mpeContact = [ SELECT Id, Last_Name__c
                                     FROM MPEContact__c
                                     WHERE Last_Name__c = 'test' ];
        DTSFPART_PartnerAdminControllerWrapper.ContactWrapper exiistingDetails = null;
        Test.startTest();
        exiistingDetails = DTSFPART_PartnerAdminController.getExistingDetails(mpeContact.Id);
        Test.stopTest();

        System.assertNotEquals(null, exiistingDetails);
    }

    @isTest
    private static void getExistingDetailsNegativeTest() {
        DTSFPART_PartnerAdminControllerWrapper.ContactWrapper exiistingDetails = null;
        Test.startTest();
        exiistingDetails = DTSFPART_PartnerAdminController.getExistingDetails(null);
        Test.stopTest();

        System.assertNotEquals(null, exiistingDetails);
    }

    @isTest
    private static void denyUserANDSendNotificationTest() {
        MPEContact__c mpeContact = [ SELECT Id, Last_Name__c
                                     FROM MPEContact__c
                                     WHERE Last_Name__c = 'test' ];
        List<ListView> listView = null;
        Test.startTest();
        listView = DTSFPART_PartnerAdminController.denyUserANDSendNotification(mpeContact.Id);
        Test.stopTest();

        System.assertNotEquals(null, listView);
    }

    @isTest
    private static void updateContactStatusTest() {
        User thisUser = [ SELECT Id, email 
                          FROM User 
                          WHERE email='test123asdfresdf@noemail.com' ];

        Test.startTest();
        DTSFPART_PartnerAdminController.updateContactStatus(new Set<Id>{thisUser.Id});
        Test.stopTest();
    }
    
}