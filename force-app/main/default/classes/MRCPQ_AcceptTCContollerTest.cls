@isTest
public class MRCPQ_AcceptTCContollerTest {

    private static User createPortalUser(){
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account partneraccTest = new Account( Name='PartnerAcc',RecordTypeId = PartnrRecordTypeId,BillingStreet='12th Street',
                                             BillingCity='Schaumburg',BillingCountry='United States',BillingState = 'Illinois',
                                             BillingPostalCode='560100',Partner_Region__c='NAMR',
                                             Applications_Enabled__c = 'CPQ',
                                             Program_Level_Community__c='CallWorks');
        insert partneraccTest;
        partneraccTest.IsPartner = true;
        update partneraccTest;
        system.debug('partneraccTest'+partneraccTest.Id);
        Id PartnrConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partTestCont1 = new Contact(AccountId = partneraccTest.Id,RecordtypeId = PartnrConRecordTypeId,FirstName = 'Test',LastName = 'Partner Contact',FirstNameLocal = 'Test',LastNameLocal = 'Partner Contact',Primary_Contact_Type__c='Sales',Contact_Type__c='sales');
        insert partTestCont1;
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'EMS Partner Administrator Profile NAMR' or name = 'System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User partnerUsr = new User(alias = 'partusr',email='standarduser@testorg.com',emailencodingkey='UTF-8', 
                                   lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', contactId=partTestCont1.Id,
                                   profileid = profiles.get('EMS Partner Administrator Profile NAMR'),timezonesidkey='America/Los_Angeles', 
                                   username='partnerusr@testorg.com',CommunityNickname='pusr',	FederationIdentifier='partnerusr@testorg.com',
                                   Core_ID__c='partnerusr@testorg.com');
        insert partnerUsr;
        //assignPermissionSet(partnerUsr.Id);
        return partnerUsr;
    }
    
    @isTest static void testReviewButtonBeforeCPQApplnAccess(){
        TestDataSetUpUtils.insertCustomSettings();
        Test.startTest();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        Test.stopTest();
        Boolean reviewButton;
        system.runas(partnerUsr){
            reviewButton = MRCPQ_AcceptTCContoller.showReviewButton();
        }
        system.assertEquals(false,reviewButton);
    }
    
    @isTest static void testShowButtonafterAccept(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //User partnerUsr = TestDataSetUpUtils.createPortalUser();
        User partnerUsr = MRCPQ_AcceptTCContollerTest.createPortalUser();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account partneraccTest = new Account( Name='PartnerAcc',RecordTypeId = PartnrRecordTypeId,BillingStreet='12th Street',
                                             BillingCity='Schaumburg',BillingCountry='United States',BillingState = 'Illinois',
                                             BillingPostalCode='560100',Partner_Region__c='NAMR',Program_Level_Community__c='CallWorks');
        insert partneraccTest;
        partneraccTest.IsPartner = true;
        update partneraccTest;
        system.debug('partneraccTest'+partneraccTest.Id);
        Id PartnrConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partTestCont1 = new Contact(AccountId = partneraccTest.Id,RecordtypeId = PartnrConRecordTypeId,FirstName = 'Test',LastName = 'Partner Contact',FirstNameLocal = 'Test',LastNameLocal = 'Partner Contact',Primary_Contact_Type__c='Sales',Contact_Type__c='sales');
        insert partTestCont1;
        
        Applications_Access__c appAcc = new Applications_Access__c();
        appAcc.App_Name__c='CPQ';
        appAcc.Contact__c=partnerUsr.ContactId;
        appAcc.App_Access_Status__c='T&C';
        appAcc.Is_Bypass__c=true;
        
        insert appAcc;
        Boolean reviewButton;
        system.runas(partnerUsr){
            reviewButton = MRCPQ_AcceptTCContoller.showReviewButton();
            MRCPQ_AcceptTCContoller.termsAccepted();
        }
        system.assertEquals(true,reviewButton);
    }
    
    @isTest(seeAlldata=true) static void testTermsCondition(){
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        system.runas(partnerUsr){
            MRCPQ_AcceptTCContoller.fetchTermsCondition();
        }
    }
    
}