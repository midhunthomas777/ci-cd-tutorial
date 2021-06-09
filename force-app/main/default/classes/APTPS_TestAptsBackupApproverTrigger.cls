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
private class APTPS_TestAptsBackupApproverTrigger {
    @testSetup
   	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
	}

static testMethod void testBackupApproverTriggers(){
    
        // 1. Create Users
        User UserSetting = [select TimeZoneSidKey, 
                            LocaleSidKey, 
                            EmailEncodingKey, 
                            ProfileId, 
                            LanguageLocaleKey
                        from User LIMIT 1];
        
        // Create New Users
        
    	Profile p = [select id from profile where Name='System Administrator' limit 1];
        User user1 = new User (FirstName = 'Test', 
                                LastName = 'User1', 
                                Username = 'TestUser1Subu@apttus.com',
                                Email =  'TestUser1Subu@apttus.com',
                                Alias = 'TestUsr1',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                APTPS_Region__c = 'NA',
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
        insert user1; // Create Test User 1
        
        User user2 = new User (FirstName = 'Test', 
                                LastName = 'User2', 
                                Username = 'TestUser2Subu@apttus.com',
                                Email =  'TestUser2Subu@apttus.com',
                                Alias = 'TestUsr2',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = p.Id, 
                                APTPS_Region__c = 'NA',
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
        insert user2; // Create Test User 2
        
        // Test Case 1
        Apttus_Approval__Backup_Approver__c currentUser1 = new Apttus_Approval__Backup_Approver__c(
                                                Apttus_Approval__Current_User__c = user1.Id,
                                                Apttus_Approval__Backup_User__c = user2.Id,
                                                Apttus_Approval__IsActive__c = true, 
                                                Apttus_Approval__InEffect__c = true);
        insert currentUser1;
        
        // Test Case 2 - test case for invalid backup
        //make user 2 active
        user2.isActive = true;
        update user2;
        currentUser1.Apttus_Approval__IsActive__c=false;
        update currentUser1;
        try{
        //set nbackup approver with inactive user
        Apttus_Approval__Backup_Approver__c currentUser2 = new Apttus_Approval__Backup_Approver__c(
                                                Apttus_Approval__Current_User__c = user1.Id,
                                                Apttus_Approval__Backup_User__c = user2.Id,
                                                Apttus_Approval__IsActive__c = true, 
                                                Apttus_Approval__InEffect__c = true);
        insert currentUser2;
        List <Apttus_Approval__Backup_Approver__c> bkUser = [select id from Apttus_Approval__Backup_Approver__c where Apttus_Approval__Current_User__c = :user1.id and
                Apttus_Approval__Backup_User__c = :user2.id];
        System.assert(bkuser<> null && bkuser.size() >=1, bkUser[0]);
        }catch(exception e){
            System.debug('User backup failed due to '+ e);
        }
 
 /*
        User user3 = new User (FirstName = 'Test', 
                                LastName = 'User3', 
                                Username = 'TestUser3@apttus.com',
                                Email =  'TestUser3@apttus.com',
                                Alias = 'TestUsr3',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = UserSetting.ProfileId, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
        insert user3; // Create Test User 3
        
        User user4 = new User (FirstName = 'Test', 
                                LastName = 'User4', 
                                Username = 'TestUser4@apttus.com',
                                Email =  'TestUser4@apttus.com',
                                Alias = 'TestUsr4',
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = UserSetting.ProfileId, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
        insert user4; // Create Test User 4
        
        // Test Case 1
        Apttus_Approval__Backup_Approver__c currentUser1 = new Apttus_Approval__Backup_Approver__c(
                                                Apttus_Approval__Current_User__c = user1.Id,
                                                Apttus_Approval__Backup_User__c = user2.Id,
                                                Apttus_Approval__IsActive__c = true, 
                                                Apttus_Approval__InEffect__c = true);
        insert currentUser1;
        
        // Test Case 3 - Negative Test Case
        Apttus_Approval__Backup_Approver__c currentUser3 = new Apttus_Approval__Backup_Approver__c(
                                                Apttus_Approval__Current_User__c = user3.Id,
                                                Apttus_Approval__Backup_User__c = null,
                                                Apttus_Approval__IsActive__c = true, 
                                                Apttus_Approval__InEffect__c = true);
        insert currentUser3;
        
        try
        {
                insert currentUser3;
        }
        catch (DmlException e) {
            // report error
            System.assert( e.getMessage().contains('Backup user is not specified'), 
                e.getMessage() );
                
            //Assert Status Code
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION'  , 
                        e.getDmlStatusCode(0));
                
            //System.assertEquals('System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Backup user is not specified: [Apttus_Approval__Backup_User__c]', 
            //                     e.getDmlStatusCode(0) );
                                 
        }
  */             
  }
}