/* @Class Name   : Patch5dot64dot1
* @Description  : Test Class for the Patch5dot64dot1_Test
* @Created By   : Vivek Pokharia
* @Created On   : 1  March  2018
* @Modification Log:  
* -----------------------------------------------------------------------------
* @Developer                Date                  Description 
* -----------------------------------------------------------------------------
* @Vivek Pokharia         1 March 2018              Created
* -----------------------------------------------------------------------------
*/ 


@isTest
private class Patch5dot64dot1_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c trgrdisbld = new TriggerSettings__c(Name = 'UserTriggerDisabled',IsActive__c=FALSE);
        insert trgrdisbld;
    }
    
    private static testMethod void testMethod1() {
        //User instOfUser;       
        Profile p = [select Id,name from Profile where Name ='EMS Partner Administrator Profile NAMR' limit 1];
        
        /*instOfUser = new User(            
            profileId = p.id,
            username = 'newUsddddd9988uuy66ttre3r@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            UserPermissionsSFContentUser = true,
            lastname='lastname'
            
        );*/
        //insert instOfUser;   
         User instoFUser = [SELECT Id,profileId FROm USER WHERE Id=: UserInfo.getUserId()];
   
        TestDataSetUpUtils.createAccAndConData(instOfUser.profileId,instOfUser.profileId);      
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
        areq.Apttus_Approval__Assigned_To_Id__c = instOfUser.Id;
        areq.Apttus_Approval__Object_Type__c='testData1';
        areq.Apttus_Approval__Object_Id__c='testdata2';
        areq.Apttus_Approval__Approval_Status__c = 'Not Submitted';
        areq.Apttus_Approval__Related_Agreement__c = agmt.id;
        areq.Apttus_Approval__Backup_From_User__c = userinfo.getuserId();
        insert areq;       
        areq.Apttus_Approval__Approval_Status__c = 'Assigned';
        update areq;     
        // Test Cases
        // 1. RE-assign to another user
        areq.Apttus_Approval__Assigned_To_Id__c = instOfUser.Id;
        areq.Apttus_Approval__Approval_Status__c = 'Reassigned';
        areq.Apttus_Approval__Backup_From_User__c = userinfo.getuserId();
        update areq; 
        Patch5dot64dot1 fix = new Patch5dot64dot1();
        fix.runFix();
        
    }
    
}