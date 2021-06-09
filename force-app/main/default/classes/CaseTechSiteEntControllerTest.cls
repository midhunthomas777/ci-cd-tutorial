@isTest
public class CaseTechSiteEntControllerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings(); 
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name = 'FeedItemTriggerDisabled', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'ContentVersionTriggerMSI', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'TaskTypeUpdateDisabled', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'ContentDocumentLinkTrigger_MSI', IsActive__C=false));//Added by Hemant
        insert tsc;  
    }    
    public static testMethod void callMuleData(){
        test.startTest();
        String responseBody = '[{"P_STATUS_MSG":null,"P_STATUS_FLAG":"Success"}]';
        Profile prof = [select id from profile where name LIKE 'System Administrator'];
        User user = new User();
        user.firstName = 'Caseticket';
        user.lastName = 'test';
        user.profileId = prof.id;
        user.EmailEncodingKey='UTF-8';
        user.LocaleSidKey='en_US';
        user.LanguageLocaleKey='en_US';
        user.Alias = 'standt';
        user.TimeZoneSidKey='America/Los_Angeles';
        user.username = 'motorolaservice@test.com';
        user.email = 'test@test.com';
        //insert user;
        
        //Running test through created test user
        System.runAs(user)
        {   
            string strRecordTypeId = [select id from RecordType where SobjectType='Account' AND IsPersonType=False AND DeveloperName = 'Partner'  limit 1].id;
            Set<Id> IdSet = new Set<Id>();
            Account account = new Account();           
            account.RecordTypeID=strRecordTypeId;
            account.Name='Test Remedy Outbound Interest';
            account.Phone='125467';
            account.ShippingCountry='United States';
            account.ShippingState = 'Illinois';
            account.BillingCity = 'Chicago';
            account.BillingCountry = 'United States';
            account.BillingCountryCode='US';
            account.Billing_County__c='Cook county';
            account.BillingPostalCode = '60173';            
            account.Industry = 'Manufacturing'; 
            insert account; 
            
            Account acc = new Account();           
            acc.RecordTypeID=strRecordTypeId;
            acc.ParentId = account.Id;
            acc.Name='Test Remedy Outbound Int';
            acc.Phone='125467';
            acc.ShippingCountry='United States';
            acc.ShippingState = 'Illinois';
            acc.BillingCity = 'Chicago';
            acc.BillingCountry = 'United States';
            acc.BillingCountryCode='US';
            acc.Billing_County__c='Cook county';
            acc.BillingPostalCode = '60173';            
            acc.Industry = 'Manufacturing'; 
            insert acc; //create test account
            
            Contact con = new Contact();
            con.FirstName='test';
            con.LastName='Contact';
            con.AccountId=acc.Id;
            con.Phone = '1233456';
            con.Web_User_ID__c = '55467';
            con.Email = 'NewContact@abc.com';
            insert con;       //create contact     
            
            //Query necessary record types
            Id recordtype1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Administrative').getRecordTypeId();
            
            Technical_Site__c tsite = new Technical_Site__c();
            //tsite.Name = '5601 Allegan Co Dispatch3';
            tsite.Status__c = 'Active';
            tsite.Site_ID__c='7784356';
            tsite.MCN_Account__c = acc.Id;
            tsite.Customer__c = account.Id;
            tsite.Primary_Street__c = 'testStreet';
            tsite.Primary_City__c='Pune';
            tsite.Primary_State_Province__c= 'MH';
            tsite.Primary_Country__c = 'India';
            tsite.Primary_Zip_Postal_Code__c = '411057';
            insert tsite; //create technical site
            
            List<Case> csList = new List<case>();

            
            //creating case and adding to csList
            Case cs = new Case();
            cs.AccountId = acc.Id;
            cs.ContactId = con.Id;
            cs.Subject = 'Test Remedy_Destination';
            cs.Technical_Site__c = tsite.id;
            cs.Description = 'Test when Remedy_Destination is empty';
            cs.Case_Type_1__c = 'Accounts Receivable';
            cs.Status = 'Open';
            cs.Impact__c = 'Severity 3';
            cs.recordtypeid = recordtype1;
            //cs.Remedy_Incident_ID__c = '142425';
            csList.add(cs);
            
            insert csList;

            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            String decision = 'SITE';
            CaseTechSiteEntController.fetchTechSiteEntitlements(decision,csList.get(0).Id);
            CaseTechSiteEntController.updateCase(csList.get(0).Id, 'csList');
            Test.stopTest();
        }
    }
    
     public static testMethod void callMuleData1(){
        test.startTest();
        String responseBody = '[{"P_STATUS_MSG":null,"P_STATUS_FLAG":"Success"}]';
        Profile prof = [select id from profile where name LIKE 'System Administrator'];
        User user = new User();
        user.firstName = 'Caseticket';
        user.lastName = 'test';
        user.profileId = prof.id;
        user.EmailEncodingKey='UTF-8';
        user.LocaleSidKey='en_US';
        user.LanguageLocaleKey='en_US';
        user.Alias = 'standt';
        user.TimeZoneSidKey='America/Los_Angeles';
        user.username = 'motorolaservice@test.com';
        user.email = 'test@test.com';
        //insert user;
        
        //Running test through created test user
        System.runAs(user)
        {   
            string strRecordTypeId = [select id from RecordType where SobjectType='Account' AND IsPersonType=False AND DeveloperName = 'Partner'  limit 1].id;
            Set<Id> IdSet = new Set<Id>();
            
            Account account = new Account();
            account.RecordTypeID=strRecordTypeId;
            account.Name='Test Remedy Outbound Intro';
            account.Phone='125467';
            account.ShippingCountry='United States';
            account.ShippingState = 'Illinois';
            account.BillingCity = 'Chicago';
            account.BillingCountry = 'United States';
            account.BillingCountryCode='US';
            account.Billing_County__c='Cook county';
            account.BillingPostalCode = '60173';            
            account.Industry = 'Manufacturing'; 
            insert account;
                
            Account acc = new Account();
            acc.RecordTypeID=strRecordTypeId;
            acc.ParentId = account.Id;
            acc.Name='Test Remedy Outbound Int';
            acc.Phone='125467';
            acc.ShippingCountry='United States';
            acc.ShippingState = 'Illinois';
            acc.BillingCity = 'Chicago';
            acc.BillingCountry = 'United States';
            acc.BillingCountryCode='US';
            acc.Billing_County__c='Cook county';
            acc.BillingPostalCode = '60173';            
            acc.Industry = 'Manufacturing'; 
            insert acc; //create test account
            
            Contact con = new Contact();
            con.FirstName='test';
            con.LastName='Contact';
            con.AccountId=acc.Id;
            con.Phone = '1233456';
            con.Web_User_ID__c = '55467';
            con.Email = 'NewContact@abc.com';
            insert con;       //create contact     
            
            //Query necessary record types
            Id recordtype1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Administrative').getRecordTypeId();
            
            Technical_Site__c tsite = new Technical_Site__c();
            //tsite.Name = '5601 Allegan Co Dispatch3';
            tsite.Status__c = 'Active';
            tsite.Site_ID__c='7784356';
            tsite.MCN_Account__c = acc.Id;
            tsite.Customer__c = account.Id;
            tsite.Primary_Street__c = 'testStreet';
            tsite.Primary_City__c='Pune';
            tsite.Primary_State_Province__c= 'MH';
            tsite.Primary_Country__c = 'India';
            tsite.Primary_Zip_Postal_Code__c = '411057';
            insert tsite; //create technical site
            
            List<Case> csList = new List<case>();

            //creating case and adding to csList
            Case cs = new Case();
            cs.AccountId = acc.Id;
            cs.ContactId = con.Id;
            cs.Subject = 'Test Remedy_Destination';
            cs.Technical_Site__c = tsite.id;
            cs.Description = 'Test when Remedy_Destination is empty';
            cs.Case_Type_1__c = 'Accounts Receivable';
            cs.Status = 'Open';
            cs.Impact__c = 'Severity 3';
            cs.recordtypeid = recordtype1;
            cs.Serial__c ='test Serial';
            //cs.Remedy_Incident_ID__c = '142425';
            csList.add(cs);
            
            insert csList;

            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            String decision = 'Serial';
            CaseTechSiteEntController.fetchTechSiteEntitlements(decision,csList.get(0).Id);
           // CaseTechSiteEntController.updateCase(csList.get(0).Id, 'csList');
            CaseTechSiteEntController.updateCase('', '');
            Test.stopTest();
        }
    }
    
}