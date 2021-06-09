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
private class APTPS_TestApproveRejectController {
    @testSetup static void setup(){
        TestDataSetUpUtils.insertCustomSettings();
    }

    static testMethod void myUnitTest() {
        // TO DO: Create test data

       List<User> userList = new List<User>();        
        // 1. Create Users
       Profile SysAdmin = [select Id 
                            from Profile
                            where Name = 'System Administrator' LIMIT 1];
        
        
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
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = SysAdmin.Id, 
                                Primary_Business_Group__c ='Government', 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user1);
        //insert user1; // Create Test User 1
        
        User user2 = new User (FirstName = 'Test', 
                                LastName = 'User2', 
                                Username = 'TestUser2Subu@apttus.com',
                                Email =  'TestUser2Subu@apttus.com',
                                Alias = 'TestUsr2',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = SysAdmin.Id,
                                Primary_Business_Group__c ='Government',  
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
                                ProfileId = SysAdmin.Id,
                                Primary_Business_Group__c ='Government', 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user3);
        //insert user3; // Create Test User 3     
        
        User user4 = new User (FirstName = 'Test', 
                                LastName = 'User4', 
                                Username = 'TestUser4Subu@apttus.com',
                                Email =  'TestUser4Subu@apttus.com',
                                Alias = 'TestUsr4',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = SysAdmin.Id,
                                Primary_Business_Group__c ='Government',  
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
                                userList.add(user4);
        //insert user4; // Create Test User 4        
        insert userList;
        // 2. Create Agreement
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
        insert agmt;
        
        Apttus__APTS_Agreement__c agmt2 = new Apttus__APTS_Agreement__c();
        insert agmt2;
        
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
        
        Apttus_Approval__ApprovalProcessInstance__c pInstance2 = new Apttus_Approval__ApprovalProcessInstance__c();
        pInstance2.Apttus_Approval__ApprovalProcessId__c = aproc.id;
        pInstance2.Apttus_Approval__BusinessObjectId__c = agmt2.id;
        pInstance2.Apttus_Approval__Status__c = 'Not Submitted';
        pInstance2.Apttus_Approval__BusinessObjectType__c = 'Apttus__APTS_Agreement__c';
        insert pInstance2;
        
        // 5a. Create Approval Request for Approval Process Instance 1
        Apttus_Approval__Approval_Request__c areq1 = new Apttus_Approval__Approval_Request__c();
        areq1.Apttus_Approval__ProcessInstanceId__c = pInstance.id;
        areq1.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq1.Apttus_Approval__Assigned_To_Id__c = user1.Id;
        areq1.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq1.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq1;
        
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
        
        // 5b. Create Approval Request for Approval Process Instance 2
        Apttus_Approval__Approval_Request__c areq4 = new Apttus_Approval__Approval_Request__c();
        areq4.Apttus_Approval__ProcessInstanceId__c = pInstance2.id;
        areq4.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq4.Apttus_Approval__Assigned_To_Id__c = user1.Id;
        areq4.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq4.Apttus_Approval__Related_Agreement__c = agmt2.id;
        insert areq4;
        
        Apttus_Approval__Approval_Request__c areq5 = new Apttus_Approval__Approval_Request__c();
        areq5.Apttus_Approval__ProcessInstanceId__c = pInstance2.id;
        areq5.Apttus_Approval__Assigned_To_Type__c = 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq5.Apttus_Approval__Assigned_To_Id__c = user2.Id;
        areq5.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq5.Apttus_Approval__Related_Agreement__c = agmt2.id;
        insert areq5;
        
        Apttus_Approval__Approval_Request__c areq6 = new Apttus_Approval__Approval_Request__c();
        areq6.Apttus_Approval__ProcessInstanceId__c = pInstance2.id;
        areq6.Apttus_Approval__Assigned_To_Type__c= 'User';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq6.Apttus_Approval__Assigned_To_Id__c = user3.Id;
        areq6.Apttus_Approval__Approval_Status__c = 'Assigned';
        areq6.Apttus_Approval__Related_Agreement__c = agmt2.id;
        insert areq6;
        
        // Test Cases
        // 1. RE-assign to another user
        /* areq.Apttus_Approval__Assigned_To_Id__c = user2.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        update areq; */
        
        // Create the controller
        PageReference currPage = Page.APTPS_ProcApprovalSummayrPage;
        
        // Add parameters to page URL
        currPage.getParameters().put('Id', areq1.id);
        currPage.getParameters().put('actionName', 'agreement_approval_summary');
        currPage.getParameters().put('pageMode', 'approveReject');
        
        // Set Current Page        
        Test.setCurrentPage(currPage);
        
        // Create the page controller
        APTPS_ApproveRejectController controller1 = new APTPS_ApproveRejectController(new ApexPages.StandardController(areq1));
        
        // First Approver Approves Approval Request #1 for Approval Process Instance #1
        controller1.approveApprovalRequest();
        
        // Second Approver Rejects Approval Request #2 for Approval Process Instance #1
        PageReference currPage2 = Page.APTPS_ProcApprovalSummayrPage;
        currPage2.getParameters().put('Id', areq2.id);
        currPage2.getParameters().put('actionName', 'agreement_approval_summary');
        currPage2.getParameters().put('pageMode', 'approveReject');
        Test.setCurrentPage(currPage2);
        APTPS_ApproveRejectController controller2 = new APTPS_ApproveRejectController(new ApexPages.StandardController(areq2));
        controller2.rejectApprovalRequest();
        
        System.runAs(user1)
        {
            // First Approver Approves Approval Request #1 for Approval Process Instance #2
            PageReference currPage4 = Page.APTPS_ProcApprovalSummayrPage;
            currPage4.getParameters().put('Id', areq4.id);
            currPage4.getParameters().put('actionName', 'agreement_approval_summary');
            currPage4.getParameters().put('pageMode', 'approveReject');
            Test.setCurrentPage(currPage4);
            APTPS_ApproveRejectController controller4 = new APTPS_ApproveRejectController(new ApexPages.StandardController(areq4));
            PageReference anotherPage = controller4.checkCurrentApprover();
        }
        
        System.runAs(user4)
        {
            // User4 Ties to Approve Approval Request #2 for Approval Process Instance #2 - This should fail
            PageReference currPage5 = Page.APTPS_ProcApprovalSummayrPage;
            currPage5.getParameters().put('Id', areq5.id);
            currPage5.getParameters().put('actionName', 'agreement_approval_summary');
            currPage5.getParameters().put('pageMode', 'approveReject');
            Test.setCurrentPage(currPage5);
            APTPS_ApproveRejectController controller5 = new APTPS_ApproveRejectController(new ApexPages.StandardController(areq5));
            controller5.checkCurrentApprover();
            
            // User 4 adds an attachment to Approval Request #3 for Approval Process Instance #2
            Attachment attach1 = new Attachment();
            attach1.ParentId = areq6.id;
            attach1.Name = 'Sandip Test';
            //attach1.ContentType = 'image/jpg';
            //attach1.CreatedById = user4.id;
            attach1.Body = Blob.valueOf('Hello World.');
            insert attach1;
            
            // User4 Tries to approve after adding attachment
            PageReference currPage6 = Page.APTPS_ProcApprovalSummayrPage;
            currPage6.getParameters().put('Id', areq6.id);
            currPage6.getParameters().put('actionName', 'agreement_approval_summary');
            currPage6.getParameters().put('pageMode', 'approveReject');
            Test.setCurrentPage(currPage6);
            APTPS_ApproveRejectController controller6 = new APTPS_ApproveRejectController(new ApexPages.StandardController(areq6));
            controller6.checkCurrentApprover();
        }
        
        
    }
}