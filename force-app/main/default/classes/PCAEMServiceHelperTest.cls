/*
Name:  PCAEMServiceHelperTest
Purpose: Test class for PCAEMServiceHelper, PCAEMService_Count and PCAEMService_Response
          
==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      12 Jan 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
@isTest
private class PCAEMServiceHelperTest {
@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
   
    
    //Account data creation
    static List<Account> createAccounts() {
        
        //PCAEMServiceHelperTest.inactiveTriggers();
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                             AND DeveloperName = 'Partner' LIMIT 1]; 
        List<Account> accList = new List<Account>();
        Datetime yesterday = Datetime.now().addDays(-1);
        
        Account acc1 = new Account();
        acc1.Name = 'account1';
        acc1.Type = 'Partner';
        acc1.RecordTypeId = recType.Id;
        acc1.Shared_Partner__c=true;
        acc1.Metal_Level__c = 'gold';
        acc1.Partner_Region__c = 'NAMR';
        acc1.BillingCountry='India';
        acc1.BillingPostalCode='1234';
        acc1.Owner_Business_Group__c='Government';
        acc1.Partner_HQ_Country__c='India';
        acc1.Status__c='Active';
        acc1.MPE_Program_Status_New__c='Active';
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'account2';
        acc2.Type = 'Partner';
        acc2.RecordTypeId = recType.Id;
        acc2.Shared_Partner__c=true;
        acc2.Metal_Level__c = 'gold';
        acc2.Partner_Region__c = 'EMEA';
        acc2.BillingCountry = 'United States';
        acc2.BillingPostalCode = '12345';
        acc2.Owner_Business_Group__c='Government';
        acc2.Partner_HQ_Country__c='United States';
        acc2.MPE_Program_Status_New__c='Active';
        acc2.Status__c='Active';
        accList.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'account3';
        acc3.Type = 'Partner';
        acc3.RecordTypeId = recType.Id;
        acc3.Shared_Partner__c=true;
        acc3.Metal_Level__c = 'gold';
        acc3.Partner_Region__c = 'APAC';
        acc3.BillingCountry = 'India';
        acc3.BillingPostalCode = '56432';
        acc3.Owner_Business_Group__c='Government';
        acc3.Partner_HQ_Country__c='India';
        acc3.MPE_Program_Status_New__c='Active';
        acc3.Status__c='Active';
        accList.add(acc3);
        //Test.startTest();
        Database.insert(accList,false);
        // Test.stopTest();
        return accList;
       
    }
    
    //Contacts data creation
    static List<Contact> createContacts() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = new List<Contact>();
        Datetime yesterday = Datetime.now().addDays(-1);
        Contact conObj1 = new Contact();
        conObj1.FirstName = 'test';
        conObj1.LastName = 'contact1';
        conObj1.Primary_Contact_Type__c = 'Developer';
        conObj1.Contact_Type__c = 'Technician';
        conObj1.Tag__c = 'SFDC Partner Admin';
        conObj1.AccountId = accountList[0].Id;
        contactList.add(conObj1);
        
        Contact conObj2 = new Contact();
        conObj2.FirstName = 'test';
        conObj2.LastName = 'contact2';
        conObj2.Primary_Contact_Type__c = 'Admin';
        conObj2.Contact_Type__c = 'Engineer';
        conObj2.Tag__c = 'Incentive Rep';
        conObj2.AccountId = accountList[1].Id;
        contactList.add(conObj2);
        
        Contact conObj3 = new Contact();
        conObj3.FirstName = 'test';
        conObj3.LastName = 'contact3';
        conObj3.Primary_Contact_Type__c = 'Service Rep';
        conObj3.Contact_Type__c = 'Executive';
        conObj3.Tag__c = 'Partner Scorecard Access';
        conObj3.AccountId = accountList[2].Id;
        contactList.add(conObj3);
        
        Database.insert(contactList,false);
        return contactList;
    }
    
    //Creating test data for PC_WS_Include_Regions__c custom setting
    static Set<String> createRegions() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        Set<String> regionSet = new Set<String>();
        List<PC_WS_Include_Regions__c> regionList = new List<PC_WS_Include_Regions__c>();
        PC_WS_Include_Regions__c emeaRegion = new PC_WS_Include_Regions__c();
        emeaRegion.Name = 'NAMR';
        regionList.add(emeaRegion);
        
        PC_WS_Include_Regions__c namrRegion = new PC_WS_Include_Regions__c();
        namrRegion.Name = 'EMEA';
        regionList.add(namrRegion);
        
        PC_WS_Include_Regions__c apacRegion = new PC_WS_Include_Regions__c();
        apacRegion.Name = 'APAC';
        regionList.add(apacRegion);
        
        Database.insert(regionList,false);
        for(PC_WS_Include_Regions__c eachReg : regionList) {
            regionSet.add(eachReg.Name);
        }
        return regionSet;
    }
    
    //Creating test data for PC_Empower_Application__c object
    static List<PC_Empower_Application__c> createPCAEMApplications() {
        
        //PCAEMServiceHelperTest.inactiveTriggers();
        List<PC_Empower_Application__c> empowerAppList = new List<PC_Empower_Application__c>();
        Datetime yesterday = Datetime.now().addDays(-1);
        PC_Empower_Application__c empApp1 = new PC_Empower_Application__c();
        empApp1.Application_Names__c = 'PC-ET-MOL; PC-ET-ALT-CH-REG; PC-ET-PARTNER-ORIENTATION';
        empApp1.ET_Tag__c = 'Partner Scorecard Access; SFDC Partner Admin';
        empApp1.ET_Secondary_Contact_Type__c = 'Executive';
        empApp1.ET_Primary_Contact_Type__c = 'Admin';
        empApp1.PC_Groups__c='PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX';
        empowerAppList.add(empApp1);
        
        PC_Empower_Application__c empApp2 = new PC_Empower_Application__c();
        empApp2.Application_Names__c = 'PC-ET-MOL; PC-ET-ALT-CH-REG; PC-ET-PARTNER-ORIENTATION';
        empApp2.ET_Tag__c = 'Incentive Rep';
        empApp2.ET_Secondary_Contact_Type__c = 'Engineer';
        empApp2.ET_Primary_Contact_Type__c = 'Developer';
        empApp2.PC_Groups__c='PC-EMEA-XXX-XXXX-XXXXX-XXXX-X-XX';
        empowerAppList.add(empApp2);
        
        PC_Empower_Application__c empApp3 = new PC_Empower_Application__c();
        empApp3.Application_Names__c = 'PC-ET-MOL; PC-ET-ALT-CH-REG; PC-ET-PARTNER-ORIENTATION';
        empApp3.ET_Tag__c = 'Incentive Rep';
        empApp3.ET_Secondary_Contact_Type__c = 'Technician';
        empApp3.ET_Primary_Contact_Type__c = 'Service Rep';
        empApp3.PC_Groups__c='PC-APAC-XXX-XXXX-XXXXX-XXXX-X-XX';
        empowerAppList.add(empApp3);
        //Test.startTest();
        Database.insert(empowerAppList);
        Test.setCreatedDate(empowerAppList[0].Id, yesterday);
        Test.setCreatedDate(empowerAppList[1].Id, yesterday);
        Test.setCreatedDate(empowerAppList[2].Id, yesterday);
        //Test.stopTest();
        return empowerAppList;
       
    }
    
    //Creating test data for Account_to_Group_Mapping__c object
    static List<Account_to_Group_Mapping__c> createAccountToGroupMapping() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        Datetime yesterday = Datetime.now().addDays(-1);
        
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Account_to_Group_Mapping__c> accountToGroupList = new List<Account_to_Group_Mapping__c>();
        Account_to_Group_Mapping__c maprecord1 = new Account_to_Group_Mapping__c();
        maprecord1.Account_Id__c = accountList[0].Id;
        maprecord1.Groups__c = 'PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX';
        accountToGroupList.add(maprecord1);
        
        Account_to_Group_Mapping__c maprecord2 = new Account_to_Group_Mapping__c();
        maprecord2.Account_Id__c = accountList[1].Id;
        maprecord2.Groups__c = 'PC-EMEA-XXX-XXXX-XXXXX-XXXX-X-XX';
        accountToGroupList.add(maprecord2);
        
        Account_to_Group_Mapping__c maprecord3 = new Account_to_Group_Mapping__c();
        maprecord3.Account_Id__c = accountList[2].Id;
        maprecord3.Groups__c = 'PC-APAC-XXX-XXXX-XXXXX-XXXX-X-XX;PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX';
        accountToGroupList.add(maprecord3);
        
        Database.insert(accountToGroupList);
        Test.setCreatedDate(maprecord1.Id, yesterday);
        Test.setCreatedDate(maprecord2.Id, yesterday);
        Test.setCreatedDate(maprecord3.Id, yesterday);
        return accountToGroupList;
    }
    
    //Creating test data for User object
    static List<User> createUserObj() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Profile namrProfle = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile NAMR'];
        Profile emeaProfle = [SELECT Id FROM Profile WHERE Name='EA GOVT Partner Administrator Profile'];
        Profile apacProfle = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile APAC'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        List<User> userList = new List<User>();
        User namrUser = new User();
        namrUser.firstname = 'tuserFname';
        namrUser.lastName = 'tuserLastname';
        namrUser.email = uniqueName + '@test' + orgId + '.org';
        namrUser.Username = uniqueName + '@test' + orgId + '.org';
        namrUser.EmailEncodingKey = 'ISO-8859-1';
        namrUser.Alias =uniqueName.substring(18, 23);
        namrUser.TimeZoneSidKey = 'America/Los_Angeles';
        namrUser.LocaleSidKey = 'en_US';
        namrUser.LanguageLocaleKey = 'en_US';
        namrUser.ProfileId = namrProfle.Id;
        namrUser.FederationIdentifier = 'user@user.com';
        namrUser.Core_ID__c = '123abc';
        namrUser.ContactId = contactList[0].Id;
        namrUser.IsActive = true;
        userList.add(namrUser);
        
        User emeaUser = new User();
        emeaUser.firstname = 'tuserFname';
        emeaUser.lastName = 'tuserLastname';
        emeaUser.email = uniqueName + '@test' + orgId + '.org';
        emeaUser.Username = uniqueName + '@test' + orgId + '.org';
        emeaUser.EmailEncodingKey = 'ISO-8859-1';
        emeaUser.Alias =uniqueName.substring(18, 23);
        emeaUser.TimeZoneSidKey = 'America/Los_Angeles';
        emeaUser.LocaleSidKey = 'en_US';
        emeaUser.LanguageLocaleKey = 'en_US';
        emeaUser.ProfileId = emeaProfle.Id;
        emeaUser.FederationIdentifier = 'user@user.com';
        emeaUser.Core_ID__c = '123abc';
        emeaUser.ContactId = contactList[1].Id;
        emeaUser.IsActive = true;
        userList.add(emeaUser);
        
        User apacUser = new User();
        apacUser.firstname = 'tuserFname';
        apacUser.lastName = 'tuserLastname';
        apacUser.email = uniqueName + '@test' + orgId + '.org';
        apacUser.Username = uniqueName + '@test' + orgId + '.org';
        apacUser.EmailEncodingKey = 'ISO-8859-1';
        apacUser.Alias =uniqueName.substring(18, 23);
        apacUser.TimeZoneSidKey = 'America/Los_Angeles';
        apacUser.LocaleSidKey = 'en_US';
        apacUser.LanguageLocaleKey = 'en_US';
        apacUser.ProfileId = apacProfle.Id;
        apacUser.FederationIdentifier = 'user@user.com';
        apacUser.Core_ID__c = '123abc';
        apacUser.ContactId = contactList[2].Id;
        apacUser.IsActive = true;
        userList.add(apacUser);
        Database.Insert(userList,false);
        return userList;
    }
    
    // Test method to check positive scenarios
    static testmethod void testDoGet() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        ////PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<PC_Empower_Application__c> updateEmpList = new List<PC_Empower_Application__c>();
        for(PC_Empower_Application__c eachApp : empowerAppList) {
            eachApp.Application_Names__c = 'PC-ET-ALT-CH-REG';
            updateEmpList.add(eachApp);
        }
        Database.update(updateEmpList);
        
        List<String> grpList = new List<String>();
        grpList.add('PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX');
        grpList.add('PC-EMEA-XXX-XXXX-XXXXX-XXXX-X-XX');
        grpList.add('PC-APAC-XXX-XXXX-XXXXX-XXXX-X-XX');
        Datetime yesterday = Datetime.now().addDays(-1);
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,'account1','Active');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(yesterday);
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping();
        PCAEMServiceHelper.getPCCount('true','NAMR','gov','Gold','48');
        PCAEMServiceHelper.getPCResponse('true','NAMR','gov','Gold','48','1','2');
        PCAEMService_Count aemServiceInstance = new PCAEMService_Count();
        PCAEMService_Count.getPartnerUserCount();
        
        PCAEMService_Response serviceInstance = new PCAEMService_Response();
        PCAEMService_Response.getPartnerUserInfo();
    }
 
    // Test method for business group is gov 
    static testmethod void testDoGet_gov() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        ////PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        Datetime yesterday = Datetime.now().addDays(-1);
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(yesterday);
        PCAEMServiceHelper.getPCCount('true','NAMR','gov','Gold','48');
        PCAEMServiceHelper.getPCResponse('true','NAMR','gov','Gold','48','1','2');
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        List<User> usrList = PCAEMServiceHelper.getUsers_gov(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',false);
        PCAEMServiceHelper.getUsers_shr(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',false);
        PCAEMServiceHelper.getUsers_others(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',false);
        PCAEMServiceHelper.getUsers_gov(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',true);
        PCAEMServiceHelper.getUsers_shr(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',true);
        PCAEMServiceHelper.getUsers_others(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'gold',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'gold');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'gold');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'gold');
    }
    
    // Test method for business group is gov program null
    static testmethod void testDoGet_govNull() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        Datetime yesterday = Datetime.now().addDays(-1);
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(yesterday);
        PCAEMServiceHelper.getPCCount('true','NAMR','gov','','');
        PCAEMServiceHelper.getPCResponse('true','NAMR','gov','','0','1','2');
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        List<User> usrList = PCAEMServiceHelper.getUsers_gov(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',false);
        PCAEMServiceHelper.getUsers_shr(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',false);
        PCAEMServiceHelper.getUsers_others(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',false);
        PCAEMServiceHelper.getUsers_gov(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',true);
        PCAEMServiceHelper.getUsers_shr(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',true);
        PCAEMServiceHelper.getUsers_others(accountGrpList[0].SystemModstamp,regionsList,tempAccSet,'null',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'null');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'null');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'null');
    }
    
    // Test method for business group is shr
    static testmethod void testDoGet_shr() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getPCCount('true','NAMR','shr','Silver','0');
        PCAEMServiceHelper.getPCResponse('true','NAMR','shr','Silver','0','1','2');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(accountGrpList[2].CreatedDate);
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'Silver',false);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'Silver',false);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'Silver',false);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'Silver',true);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'Silver',true);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'Silver',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'Silver');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'Silver');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'Silver');
    }
    
    // Test method for business group is others (other than gov or shr)
    static testmethod void testDoGet_others() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getPCCount('true','NAMR','other','Platinum','0');
        PCAEMServiceHelper.getPCResponse('true','NAMR','other','Platinum','0','1','2');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(accountGrpList[1].SystemModstamp);
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'Platinum',false);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'Platinum',false);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'Platinum',false);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'Platinum',true);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'Platinum',true);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'Platinum',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'Platinum');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'Platinum');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'Platinum');
    }
    
    // Test method when programLevel = null
    static testmethod void testDoGet_nullPgmLevel() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getPCCount('true','NAMR','other','','0');
        PCAEMServiceHelper.getPCResponse('true','NAMR','other','','0','1','2');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(accountGrpList[1].SystemModstamp);
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'',false);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'',false);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'',false);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'',true);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'',true);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'');
    }
    
    // Test method when programLevel is other than gold,silver and plantinum
    static testmethod void testDoGet_othersPgmLevel() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getPCCount('true','NAMR','other','nothing','0');
        PCAEMServiceHelper.getPCResponse('true','NAMR','other','nothing','0','1','2');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(accountGrpList[1].SystemModstamp);
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'nothing',false);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'nothing',false);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'nothing',false);
        PCAEMServiceHelper.getUsers_gov(DateTime.now(),regionsList,tempAccSet,'nothing',true);
        PCAEMServiceHelper.getUsers_shr(DateTime.now(),regionsList,tempAccSet,'nothing',true);
        PCAEMServiceHelper.getUsers_others(DateTime.now(),regionsList,tempAccSet,'nothing',true);
        PCAEMServiceHelper.getUsers_gov(regionsList,tempAccSet,'nothing');
        PCAEMServiceHelper.getUsers_shr(regionsList,tempAccSet,'nothing');
        PCAEMServiceHelper.getUsers_others(regionsList,tempAccSet,'nothing');
    }
    
    /*
     * Test method for PCAEMService_UName webservice methods
    */
    static testmethod void test_PCAEMService_UName() {
        //PCAEMServiceHelperTest.inactiveTriggers();
        //PCAEMServiceHelperTest.createDataActivitySetting();
        Test.startTest();
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Test.stopTest();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        //PCAEMService_UName.getPCUsers();
        PCAEMService_UName.getUserDetails(users[0].Email);
    }
    
    /*
     * Test method for PCAEMService_AccId webservice methods
    */ 
    static testmethod void test_PCAEMService_AccId_1() {
       
        //PCAEMServiceHelperTest.inactiveTriggers();
            //PCAEMServiceHelperTest.createDataActivitySetting();
        SYSTEM.DEBUG('########## ACC ID CLASS########');
        
        List<Account> accountList = PCAEMServiceHelperTest.createAccounts();
        List<Contact> contactList = PCAEMServiceHelperTest.createContacts();
        Set<String> regionsList = PCAEMServiceHelperTest.createRegions();
        List<PC_Empower_Application__c> empowerAppList = PCAEMServiceHelperTest.createPCAEMApplications();
        List<Account_to_Group_Mapping__c> accountGrpList = PCAEMServiceHelperTest.createAccountToGroupMapping();
        List<User> users = PCAEMServiceHelperTest.createUserObj();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       // req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCCount';
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/GetPCUserDetails?AccountId=0018000000ynQYLAA2';
        req.httpMethod = 'Get';
        RestContext.request = req;
        RestContext.response = res;
        
        SYSTEM.DEBUG('########## ACC ID CLASS########'+req);
        
        List<String> grpList = new List<String>();
        Set<String> tempAccSet = new Set<String>();
        for(Account_to_Group_Mapping__c eachGrp : accountGrpList) {
            grpList.add(eachGrp.Groups__c);
            tempAccSet.add(eachGrp.Account_Id__c);
        }
        
        PCAEMServiceHelper helperInstance = new PCAEMServiceHelper();
        PCAEMServiceHelper.PCAEMServiceResponse innerInstance = new PCAEMServiceHelper.PCAEMServiceResponse(users[0].Id,users[0].FederationIdentifier,users[0].firstname,users[0].Email,grpList,accountList[0].Id,accountList[0].name,'Active');
        PCAEMServiceHelper.getAccountsFrmAccToGrpMapping(accountGrpList[1].SystemModstamp);
        PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(tempAccSet);
        Test.startTest();
       // PCAEMService_AccId.getPCUsers();
        PCAEMService_AccId.getUserResponse(users);
        String accId = accountList[2].Id;
        PCAEMService_AccId.getUserDetails(accId);
        Test.stopTest();
    }
}