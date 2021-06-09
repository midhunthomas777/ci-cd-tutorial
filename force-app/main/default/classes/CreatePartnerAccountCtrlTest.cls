@isTest
public class CreatePartnerAccountCtrlTest {
    @isTest private static void isApprovedTest(){
        
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Main_place_of_business_Country__c='Canada';
        empower.Main_place_of_business_State__c = 'Alberta';
        empower.Partner_Application_Status__c='Approved';
        empower.Partner_Region__c ='LA';
        update empower;
        List<Addendum__c> lstAddendum=new List<Addendum__c>();
        for(Integer i=0;i<=2;i++){
            Addendum__c addendum=new Addendum__c(Application__c=empower.Id,Partner_Region__c='LA',Status__c='Accepted',
                                                 Partner_Community_Type__c='Value Added Reseller',Names_and_Email_of_Additional_Owners__c='test@mail.com',
                                                 Technology_Segment__c='Business Radio');
            lstAddendum.add(addendum);
        }
        insert lstAddendum;
        test.startTest();
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Canada';
        partnerAccount.BillingState='Alberta';
        partnerAccount.BillingCountryCode = 'CA';
        partnerAccount.BillingStateCode = 'AB';
        update partnerAccount;
        test.stopTest(); 
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
        
    }
    @isTest private static void createAccount(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Main_place_of_business_Country__c='Canada';
        empower.Main_place_of_business_State__c = 'Alberta';
        empower.Partner_Application_Status__c='Approved';
        empower.Are_You_Authorized_to_Sign_Legal_Agmt__c='No';
        empower.Partner_Region__c ='LA';
        update empower;
        Test.startTest();
        
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Canada';
        partnerAccount.BillingState='Alberta';
        partnerAccount.BillingCountryCode = 'CA';
        partnerAccount.BillingStateCode = 'AB';
        update partnerAccount;
        MPEContact__c newContact = new MPEContact__c(Application__c=empower.Id,Account__c=partnerAccount.Id,Last_Name__c='test',
                                                     First_Name__c='test1',Email__c='test@test.com',Phone__c='123',
                                                     Primary_Language__c='English');
        insert newContact;
        echosign_dev1__SIGN_Agreement__c adobeAgreemnt = new echosign_dev1__SIGN_Agreement__c();
        adobeAgreemnt.echosign_dev1__Status__c = 'Signed';
        adobeAgreemnt.PartnerEmpower_Application__c =empower.Id;
        insert adobeAgreemnt;
        test.stopTest();
        
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
        
    }
    @isTest private static void isApprovedTestLARegion(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Partner_Region__c ='LA';
        empower.Main_place_of_business_Country__c='Argentina';
        empower.Main_place_of_business_State__c = NULL;
        empower.Partner_Application_Status__c='Approved';
        update empower;
        List<Addendum__c> lstAddendum=new List<Addendum__c>();
        for(Integer i=0;i<=2;i++){
            Addendum__c addendum=new Addendum__c(Application__c=empower.Id,Partner_Region__c='LA',Status__c='Accepted',
                                                 Partner_Community_Type__c='Value Added Reseller',Names_and_Email_of_Additional_Owners__c='testmail.com',
                                                 Technology_Segment__c='Business Radio');
            lstAddendum.add(addendum);
        }
        insert lstAddendum;
        test.startTest();
        
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Argentina';
        partnerAccount.BillingState='Chaco';
        partnerAccount.BillingCountryCode = 'AR';
        partnerAccount.BillingStateCode = 'CC';
        update partnerAccount;
        test.stopTest(); 
        
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
    }
    @isTest private static void isApprovedTestEMEARegion(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Partner_Region__c ='EMEA';
        empower.Main_place_of_business_Country__c='France';
        empower.Main_place_of_business_State__c = NULL;
        
        empower.Detail_Helpdesk_Support__c='EMEA helpdesk';
        empower.Partner_Application_Status__c='Approved';
        update empower;
        List<Addendum__c> lstAddendum=new List<Addendum__c>();
        for(Integer i=0;i<=2;i++){
            Addendum__c addendum=new Addendum__c(Application__c=empower.Id,Partner_Region__c='EMEA',Status__c='Accepted',
                                                 Partner_Community_Type__c='Value Added Reseller',Technology_Segment__c='TETRA',
                                                 Names_and_Email_of_Additional_Owners__c='testmail.com');
            lstAddendum.add(addendum);
        }
        insert lstAddendum;
        test.startTest();
        
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'France';
        partnerAccount.BillingState=null;
        partnerAccount.BillingCountryCode = 'FR';
        partnerAccount.BillingStateCode = null;
        update partnerAccount;
        test.stopTest(); 
        
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
    }
    
    @isTest private static void isApprovedTestWithCompanyRole(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Main_place_of_business_Country__c='Canada';
        empower.Main_place_of_business_State__c = 'Alberta';
        empower.Partner_Application_Status__c='Approved';
        empower.Are_You_Authorized_to_Sign_Legal_Agmt__c = 'No';
        empower.Company_Signature_Authority_Primary_Role__c='Marketing';
        empower.Partner_Region__c ='LA';
        update empower;
        Test.startTest();
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Canada';
        partnerAccount.BillingState='Alberta';
        partnerAccount.BillingCountryCode = 'CA';
        partnerAccount.BillingStateCode = 'AB';
        update partnerAccount;
        MPEContact__c newContact = new MPEContact__c(Application__c=empower.Id,Account__c=partnerAccount.Id,Last_Name__c='test',
                                                     First_Name__c='test1',Email__c='test@test.com',Phone__c='123',
                                                     Primary_Language__c='English');
        insert newContact;
        echosign_dev1__SIGN_Agreement__c adobeAgreemnt = new echosign_dev1__SIGN_Agreement__c();
        adobeAgreemnt.echosign_dev1__Status__c = 'Signed';
        adobeAgreemnt.PartnerEmpower_Application__c =empower.Id;
        insert adobeAgreemnt;
        Test.stopTest();
        
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
    }
    
    @isTest private static void isApprovedTestWithAddedum(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Partner_Region__c ='LA';
        empower.Main_place_of_business_Country__c='Argentina';
        empower.Main_place_of_business_State__c = NULL;
        empower.Partner_Application_Status__c='Approved';
        update empower;
        List<Addendum__c> lstAddendum=new List<Addendum__c>();
        Id newApplicationRCId = DTSFPART_Utils.getRecordTypeId('Addendum__c', 'New_Application');
        for(Integer i=0;i<=2;i++){
            Addendum__c addendum=new Addendum__c(Application__c=empower.Id,Partner_Region__c='LA',Status__c='Accepted',
                                                 Partner_Community_Type__c='Value Added Reseller',Names_and_Email_of_Additional_Owners__c='testmail.com',
                                                 Technology_Segment__c='Business Radio', RecordTypeId = newApplicationRCId);
            lstAddendum.add(addendum);
        }
        insert lstAddendum;
        test.startTest();
        
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        partnerAccount.Parent_Corp_Govt_Tax_Registration_Id__c = '1234';
        partnerAccount.Total_Number_of_Technical_Personnel__c = 1;
        partnerAccount.Total_Number_of_Marketing_Personnel__c = 2;
        partnerAccount.Total_Number_of_Management_Personnel__c = 3;
        partnerAccount.BillingCountry = 'Argentina';
        partnerAccount.BillingState='Chaco';
        partnerAccount.BillingCountryCode = 'AR';
        partnerAccount.BillingStateCode = 'CC';
        update partnerAccount;
        test.stopTest(); 
        
        CreatePartnerAccountCtrl.isApproved(empower.Id);
        CreatePartnerAccountCtrl.createAccOnApplication(empower.Id);
    }
}