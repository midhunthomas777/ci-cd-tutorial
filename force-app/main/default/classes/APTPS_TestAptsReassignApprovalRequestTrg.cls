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
private class APTPS_TestAptsReassignApprovalRequestTrg {
	@testSetup
   	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
	}
    static testMethod void testReassignApprovalRequestTriggers()
    {
        // TO DO: Create test data
        // 1. Create Users
        User UserSetting = [select TimeZoneSidKey, 
                            LocaleSidKey, 
                            EmailEncodingKey, 
                            ProfileId, 
                            LanguageLocaleKey
                        from User LIMIT 1];
         Profile p = [select id from profile where Name='System Administrator' limit 1];
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
        insert user1; // Create Test User 1
        
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
        insert user2; // Create Test User 2     
        
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
    
        // Test Cases
        // 1. RE-assign to another user
        areq.Apttus_Approval__Assigned_To_Id__c = user2.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        update areq; 
        
        /*
        // 2. Re-assign to another user that is not valid
        areq.Apttus_Approval__Assigned_To_Id__c = 'ABC';
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        update areq;
        
        try
        {
                update areq;
        }
        catch (Exception e) {
            // report error
            System.assert( e.getMessage().contains('Please select a valid user.'), 
                e.getMessage() );
                
            System.assertEquals('Please select a valid user.' , 
                                 e.getDmlStatusCode(0) ); 
        }*/
        
  }
      static testMethod void testReassignApprovalRequestTriggers1()
    {
        // TO DO: Create test data
        // 1. Create Users
        User UserSetting = [select TimeZoneSidKey, 
                            LocaleSidKey, 
                            EmailEncodingKey, 
                            ProfileId, 
                            LanguageLocaleKey
                        from User LIMIT 1];
        Profile p = [select id from profile where Name='System Administrator' limit 1];

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
        insert user1; // Create Test User 1
        
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
        insert user2; // Create Test User 2     
        
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
        areq.Apttus_Approval__Assigned_To_Type__c= 'ROLE';
        //areq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
        areq.Apttus_Approval__Assigned_To_Id__c = user1.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Not Submitted';
        areq.Apttus_Approval__Related_Agreement__c = agmt.id;
        insert areq;
        
        areq.Apttus_Approval__Approval_Status__c = 'Assigned';
        update areq; 
    
        // Test Cases
        // 1. RE-assign to another user
        areq.Apttus_Approval__Assigned_To_Id__c = user2.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        update areq; 
        
        /*
        // 2. Re-assign to another user that is not valid
        areq.Apttus_Approval__Assigned_To_Id__c = 'ABC';
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        update areq;
        
        try
        {
                update areq;
        }
        catch (Exception e) {
            // report error
            System.assert( e.getMessage().contains('Please select a valid user.'), 
                e.getMessage() );
                
            System.assertEquals('Please select a valid user.' , 
                                 e.getDmlStatusCode(0) ); 
        }*/
        
  }
}