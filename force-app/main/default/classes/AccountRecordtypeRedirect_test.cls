@isTest
private class AccountRecordtypeRedirect_test{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void AccountRedirect1() 
    {
        Test.startTest();            
        Id conPArtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();
        RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='partner' limit 1]; 
        Account Acc1 = new Account(Name='TestVAccount12', RecordTypeId=rt1.id,BillingCountry='India',BillingPostalCode='1234');
        Insert Acc1;  
        Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,Primary_Contact_Type__c='sales', 
                                 Email='test@qa.com',recordtypeId= conPArtId);
        Insert C1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile APAC' limit 1] ; 
        User usr = new User(Alias = 'standt', Email='standarduser@motorolasolutions.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, contactid=C1.id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com',
                            CommunityNickname='ABCD',	FederationIdentifier='ABCD',
                                Core_ID__c='ABCD',EmployeeNumber = 'ABCD'
                             );
        insert usr ;
        
        System.RunAs(usr){
            
            RecordType rt2 = [select Id from RecordType where SObjectType='Account' and DeveloperName='partner' limit 1];  
            Account Acc2 = new Account(Name='TestVAccount12',Tax_Certificate_on_File__c='Yes', RecordTypeId=rt2.id,BillingCountry='India',BillingPostalCode='1234');
            Insert Acc2;
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Acc2);
            AccountRecordtypeRedirect cont= new AccountRecordtypeRedirect(sc);
            PageReference pageRef = Page.AccountRecordTypeSelection;       
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',Acc2.id); 
            // cont.checkSF1orDesktop='false';   
            cont.redirect();
            
        }
        Test.stopTest();
    }
    static testMethod void AccountRedirect2() 
    {
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1] ; 
        User usr = new User(Alias = 'standtq', Email='standarduser@motorolasolutions.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest2',LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='ABCD01', CommunityNickname='ABCD01', FederationIdentifier='ABCD01',
                            TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser1@motorolasolutions.com',Core_ID__c='ABCD01');
        insert usr ;
        
        System.RunAs(usr){
            RecordType rt = [Select Id,Name From RecordType Where SobjectType = 'Account' and Name = 'Prospect']; 
            Account accMain = new Account();
            accMain.Name='Check';
            accMain.recordtypeId=rt.id;
            accMain.billingcountry = 'United States';
            accMain.billingcity='texas';
            accMain.billingstate='Texas';
            accMain.Territory__c = 'T1';
            accMain.Billing_County__c = 'texas';
            //accMain.party_number__c = '5678';
            insert accMain;
            PageReference pageRef = Page.AccountRecordTypeSelection; // Add your VF page Name here
            pageRef.getParameters().put('RecordType',rt.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(accMain);
            AccountRecordtypeRedirect cont= new AccountRecordtypeRedirect(sc);
            cont.redirect();
            Test.stopTest();
        }
        
    }
    
    static testMethod void AccountRedirect3() 
    {
        Test.startTest();
        RecordType rt = [Select Id,Name From RecordType Where SobjectType = 'Account' and Name = 'Motorola Customer Number']; 
        Account accMain = new Account();
        accMain.Name='Test acc';
        accMain.recordtypeId=rt.id;
        accMain.billingcountry = 'United States';
        accMain.billingcity='texas';
        accMain.billingstate='Texas';
        accMain.Motorola_Customer_Number__c = '123445';
        accMain.MCN_Account_Name__c = 'Test acc';
        // accMain.party_number__c = '5678';
        insert accMain;
        PageReference pageRef = Page.AccountRecordTypeSelection; // Add your VF page Name here
        pageRef.getParameters().put('RecordType',rt.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(accMain);
        AccountRecordtypeRedirect cont= new AccountRecordtypeRedirect(sc);
        cont.redirect();
        Test.stopTest();
    }
    
    
    static testMethod void AccountRedirect_MasterRec() 
    {
        Test.startTest();
        
        RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='partner' limit 1];  
        Account Acc1 = new Account(Name='TestVAccount12', RecordTypeId=rt1.id,BillingCountry='India',BillingPostalCode='1234');
        Insert Acc1;  
        //Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,Primary_Contact_Type__c='sales');
        // Insert C1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Legal Std. Adv Approvals Procurement User' limit 1] ; 
        User usr = new User(Alias = 'standt', Email='standarduser@motorolasolutions.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='ABCD12', CommunityNickname='ABCD12', FederationIdentifier='ABCD12',
                            TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@motorolasolutions.com',Core_ID__c='ABCD12');
        insert usr ;
        
        System.RunAs(usr){
            
            //  RecordType rt2 = [select Id from RecordType where SObjectType='Account' and DeveloperName='partner' limit 1];  
            Account Acc2 = new Account(Name='TestVAccount12',Tax_Certificate_on_File__c='Yes',BillingCountry='India',Billingcity='Test',BillingPostalCode='1234',Territory__c = 'T1');
            Insert Acc2;
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Acc2);
            AccountRecordtypeRedirect cont= new AccountRecordtypeRedirect(sc);
            PageReference pageRef = Page.AccountRecordTypeSelection;       
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',Acc2.id); 
            // cont.checkSF1orDesktop='false';   
            cont.redirect();
            
        }
        Test.stopTest();
    }
}