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
private class APTPS_TestBackupFilterController {
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
                                APTPS_Region__c = 'North America',
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
           
        // Execute Test Cases
        
        // 1. Test Case #1 
        
        // Create the controller
        PageReference currPage = Page.APTPS_Backup_Filter;
        
        // Add parameters to page URL
        currPage.getParameters().put('Id', user1.id);
        //currPage.getParameters().put('Action', 'Preview_Agreement');
        currPage.getParameters().put('searchText', 'Test');
        currPage.getParameters().put('pageSizeDefault','50');
        
        Test.setCurrentPage(currPage);
        
        // Create the page controller
        //APTPS_TestSplitAgreementLineItemsCntrl controller = new APTPS_TestSplitAgreementLineItemsCntrl(new ApexPages.StandardController(proposalSO));
        APTPS_BackupFilterController controller1 = new APTPS_BackupFilterController(new ApexPages.StandardController(user1));
        
        // Test preview mode of the controller
        //PageReference newPage1 = controller1.onLoad();
        //controller1.backupApprover = User1;
        controller1.getUserSet();
        controller1.getUserList();
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
        
        // 2. Test Case #2
        PageReference currPage2 = Page.APTPS_Backup_Filter;
        
        // Add parameters to page URL
        currPage2.getParameters().put('Id', user1.id);
        currPage2.getParameters().put('searchText', 'Test');
        currPage2.getParameters().put('pageSizeDefault','50');
        
        Test.setCurrentPage(currPage2);
        
        // Create the page controller
        APTPS_BackupFilterController controller2 = new APTPS_BackupFilterController(new ApexPages.StandardController(user1));
                
        controller2.searchText = 'Test';
        controller2.doSearch();
        currPage2.getParameters().put('backupApproverId', user2.Id);
        currPage2.getParameters().put('backupApproverName', user2.Name);
        controller2.setBackupApproverName('TestUser2');
        controller2.doChooseUser();    
        controller2.doReturn();
        
        // Verification 1: Check and see how many product line items where created
        /*Integer aCnt1 = 
                [SELECT count() 
                  FROM APTPS_Agreement_Line_Item_01__c 
                  WHERE AgreementId__c = :newagmt.Id];                                             
        System.assertEquals(4, aCnt1);*/
        
        // Call all the other methods to get test coverage
        String sBackupName = controller2.getBackupApproverName();
        String sBackupId = controller2.getBackupApproverId();
        Integer iPageNum = controller2.getCurrentPageNumber();
        Boolean bHasNextPage = controller2.getHasNextPage();
        Boolean bHasPreviousPage = controller2.getHasPreviousPage();
        Boolean bHasUsers = controller2.getHasUsers();
        Integer iPageSize = controller2.getPageSize();
        Integer iTotalPages = controller2.getTotalPages(); 
        //Integer iApprovalLevel = controller2.getLevelNumber('1');
        
        // 3. Test Case #3
        PageReference currPage3 = Page.APTPS_Backup_Filter;
        
        // Add parameters to page URL
        currPage3.getParameters().put('Id', user3.id);
        currPage3.getParameters().put('searchText', 'Test');
        currPage3.getParameters().put('pageSizeDefault','50');
        
        Test.setCurrentPage(currPage3);
        
        // Create the page controller
        APTPS_BackupFilterController controller3 = new APTPS_BackupFilterController(new ApexPages.StandardController(user3));
                
        controller3.searchText = 'Test';
        controller3.doSearch();
        
        // 3. Test Case #4
        PageReference currPage4 = Page.APTPS_Backup_Filter;
        
        // Add parameters to page URL
        currPage4.getParameters().put('Id', user4.id);
        currPage4.getParameters().put('searchText', 'Test');
        currPage4.getParameters().put('pageSizeDefault','50');
        
        Test.setCurrentPage(currPage4);
        
        // Create the page controller
        APTPS_BackupFilterController controller4 = new APTPS_BackupFilterController(new ApexPages.StandardController(user4));
                
        controller4.searchText = 'Test';
        controller4.doSearch();
                
    }
}