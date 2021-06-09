/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */ 
@isTest
private class APTPS_TestReassignFilterController {
    @testSetup
   	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
	}

    static testMethod void myUnitTest() 
    {
        // TO DO: Create test data
        
        List<User> userList = new List<User>();     
        Profile p = [select id from profile where Name='System Administrator' limit 1];

        // 1. Create Users
        User UserSetting = [select TimeZoneSidKey, 
                            LocaleSidKey, 
                            EmailEncodingKey, 
                            ProfileId, 
                            LanguageLocaleKey
                        from User LIMIT 1];
        
        // Create New Users
        User user1 = new User (FirstName = 'Test', 
                                LastName = 'User1', 
                                Username = 'TestUser1Subu@apttus.com',
                                Email =  'TestUser1Subu@apttus.com',
                                Alias = 'TestUsr1',
                                APTPS_Region__c = 'North America',
                                APTPS_Permissible_Assignee_Label__c = 'Test',
                                APTPS_Agreement_RecordType__c = 'Procurement',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user1);
        //insert user1; // Create Test User 1
        
        User user2 = new User (FirstName = 'Test', 
                                LastName = 'User2', 
                                Username = 'TestUser2Subu@apttus.com',
                                Email =  'TestUser2Subu@apttus.com',
                                Alias = 'TestUsr2',
                                APTPS_Region__c = 'North America',
                                APTPS_Permissible_Assignee_Label__c = 'Test',
                                APTPS_Agreement_RecordType__c = 'Procurement',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user2);
        //insert user2; // Create Test User 2     
        
        User user3 = new User (FirstName = 'Test', 
                                LastName = 'User3', 
                                Username = 'TestUser3Subu@apttus.com',
                                Email =  'TestUser3Subu@apttus.com',
                                Alias = 'TestUsr3',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user3);
        //insert user3; // Create Test User 3
        
        User user4 = new User (FirstName = 'Test', 
                                LastName = 'User4', 
                                Username = 'TestUser4Subu@apttus.com',
                                Email =  'TestUser4Subu@apttus.com',
                                Alias = 'TestUsr4',
                                APTPS_Region__c = 'North America',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user4);
        //insert user4; // Create Test User 4      
          
        insert userList;
        // Create Approval Matrix for User 3
        Apttus_Approval__Approval_Matrix__c currentMatrix = new Apttus_Approval__Approval_Matrix__c (Apttus_Approval__User__c  = user3.id,
                                                        Apttus_Approval__Is_Active__c = true,
                                                        Apttus_Approval__Approval_Level__c = 'Level 5',
                                                        Apttus_Approval__Next_Level_Approver__c = user1.id,
                                                        Apttus_Approval__Approver_1_Level__c = 'Level 1',
                                                        Apttus_Approval__Approver_1__c = user1.id,
                                                        Apttus_Approval__Approver_2_Level__c = 'Level 2',
                                                        Apttus_Approval__Approver_2__c = user2.id);
        insert currentMatrix;
        

        
        // Set Backup Approver for User 4
        Apttus_Approval__Backup_Approver__c currentUser = new Apttus_Approval__Backup_Approver__c(
                                                Apttus_Approval__Current_User__c = user4.Id,
                                                Apttus_Approval__Backup_User__c = user3.Id,
                                                Apttus_Approval__IsActive__c = true, 
                                                Apttus_Approval__InEffect__c = true);
        insert currentUser;
        
        // 2. Create Agreement
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
        insert agmt;
        
        // 3. Create Approval Process
        Apttus_Approval__Approval_Process__c aProc = new Apttus_Approval__Approval_Process__c ();
        insert aproc;
        
        // 4. Create Approval Instance
        Apttus_Approval__ApprovalProcessInstance__c pInstance = new Apttus_Approval__ApprovalProcessInstance__c();
        pInstance.Apttus_Approval__ApprovalProcessId__c = aproc.id;
        pInstance.Apttus_Approval__BusinessObjectId__c = agmt.id;
        pInstance.Apttus_Approval__Status__c = 'Not Submitted';
        pInstance.Apttus_Approval__BusinessObjectType__c = 'Apttus__APTS_Agreement__c';
        insert pInstance;
        
        // 5. Create Approval Request
        Apttus_Approval__Approval_Request__c areq = new Apttus_Approval__Approval_Request__c();
        areq.Apttus_Approval__ProcessInstanceId__c = pInstance.id;
        areq.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq.Apttus_Approval__Assigned_To_Id__c = user1.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Not Submitted';
        areq.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq;
        
        areq.Apttus_Approval__Approval_Status__c = 'Assigned';
        update areq;
        
        Apttus_Approval__Approval_Request__c areq2 = new Apttus_Approval__Approval_Request__c();
        areq2.Apttus_Approval__ProcessInstanceId__c = pInstance.id;
        areq2.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq2.Apttus_Approval__Assigned_To_Id__c = user2.Id;
        areq2.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq2.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq2;
        
        Apttus_Approval__Approval_Request__c areq3 = new Apttus_Approval__Approval_Request__c();
        areq3.Apttus_Approval__ProcessInstanceId__c = pInstance.id;
        areq3.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq3.Apttus_Approval__Assigned_To_Id__c = user3.Id;
        areq3.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq3.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq3;
        
        Apttus_Approval__Approval_Request__c areq4 = new Apttus_Approval__Approval_Request__c();
        areq4.Apttus_Approval__ProcessInstanceId__c = pInstance.id;
        areq4.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq4.Apttus_Approval__Assigned_To_Id__c = user4.Id;
        areq4.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq4.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq4;
        
        // Beginning of Test Cases
        
        // Test Cases #1
        
        // Create the controller
        PageReference currPage = Page.APTPS_Reassign_Filter;
        
        // Add parameters to page URL
        //currPage.getParameters().put('Id', user1.id);
        currPage.getParameters().put('searchText', 'Test');
        currPage.getParameters().put('pageSizeDefault','50');
        
        // Set Test Page        
        Test.setCurrentPage(currPage);
        
        //areq = getSObject(areq.Id);
        areq.Apttus_Approval__Assigned_To_Type__c = 'User';
        
        // Create the page controller
        APTPS_ReassignFilterController controller1 = new APTPS_ReassignFilterController(new ApexPages.StandardController(areq));
        
        controller1.getUserSet();
        controller1.searchText = null;
        controller1.doSearch();
        controller1.setPageSize(50);
        controller1.getPageSize();
        controller1.getUserList();
        controller1.getCurrentPageNumber();
        controller1.firstPage();
        controller1.nextPage();
        controller1.lastPage();
        controller1.previousPage();
        controller1.firstPage();
        controller1.getHasUsers();
        controller1.getHasNextPage();
        controller1.getHasPreviousPage();
        controller1.getTotalPages();
        controller1.doReturn();
        
        // Test Case #2
        
        // Create the page controller
        PageReference currPage2 = Page.APTPS_Reassign_Filter;
        currPage2.getParameters().put('searchText', 'Test');
        currPage2.getParameters().put('pageSizeDefault','50');
        Test.setCurrentPage(currPage2);
        areq.Apttus_Approval__Assigned_To_Type__c = 'User';
        
        APTPS_ReassignFilterController controller2 = new APTPS_ReassignFilterController(new ApexPages.StandardController(areq));
                
        controller2.searchText = 'Test';
        controller2.doSearch();
        currPage2.getParameters().put('reassignedToId', user2.Id);
        currPage2.getParameters().put('reassignedToName', user2.Name);
        controller2.doChooseUser();
        controller2.getReassignedToName();
        controller2.getReassignedToId();    
        
        // Test Case #3
        
        // Create the page controller
        PageReference currPage3 = Page.APTPS_Reassign_Filter;
        currPage3.getParameters().put('searchText', 'Test');
        currPage3.getParameters().put('pageSizeDefault','50');
        Test.setCurrentPage(currPage3);
        areq3.Apttus_Approval__Assigned_To_Type__c = 'User';
        
        APTPS_ReassignFilterController controller3 = new APTPS_ReassignFilterController(new ApexPages.StandardController(areq3));
                
        controller3.searchText = 'Test';
        controller3.doSearch();            
            
    }
}