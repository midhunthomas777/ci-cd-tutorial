@isTest
private class ApprovalItemController_Test
{

 static testMethod void getAllApprovalStep()
{
    TestDataSetupUtils.insertCustomSettings();
Id profId;
test.starttest();
RecordType rt2 = [select Id from RecordType where SObjectType='Apttus__APTS_Agreement__c' and DeveloperName='Procurement' limit 1];

Apttus__APTS_Agreement__c agrr = new Apttus__APTS_Agreement__c(
Name='Test Agreement',
RecordTypeId =rt2.Id,
Procurement_Category__c='Advertising and Creative',
m_Business_Unit__c='Government'
);
insert agrr;
User tempUser = [Select Id,ProfileId from User where isActive = TRUE AND UserType = 'Standard' LIMIT 1];
profId = tempUser.ProfileId;

User PUsers = new User(FirstName='Test', LastName='User', alias='test', email='apttustest@mailinator.com', username='apttustest@mailinator.com', communityNickname='Apttustest1', profileId=profId, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='NAMR',Primary_Business_Group__c = 'Government'); 
insert PUsers;

User PUsers2 = new User(FirstName='XYZ', LastName='User', alias='test2', email='apttustest1@mailinator.com', username='apttustest1@mailinator.com', communityNickname='Apttustest2', profileId=profId, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='NAMR',Primary_Business_Group__c = 'Government'); 
insert PUsers2;

User PUsers3 = new User(FirstName='ABC', LastName='User', alias='test3', email='apttustest2@mailinator.com', username='apttustest2@mailinator.com', communityNickname='Apttustest3', profileId=profId, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='NAMR',Primary_Business_Group__c = 'Government'); 
insert PUsers3;

Apttus_Approval__Approval_Request__c appRequest1 = new Apttus_Approval__Approval_Request__c(
Apttus_Approval__Related_Agreement__c=agrr.id,
Apttus_Approval__StepSequence__c=1.001,
Apttus_Approval__PrevAssignedToName__c='ABC User',
Apttus_Approval__Approval_Status__c='Assigned',
Apttus_Approval__Approver_Comments__c='test',
Apttus_Approval__Assigned_To_Name__c='Test User',
Apttus_Approval__Date__c=System.Today()+1,
Apttus_Approval__Actual_Approver__c =PUsers.Id
);

Apttus_Approval__Approval_Request__c appRequest2 = new Apttus_Approval__Approval_Request__c(
Apttus_Approval__Related_Agreement__c=agrr.id,
Apttus_Approval__StepSequence__c=1.002,
Apttus_Approval__PrevAssignedToName__c='ABC User',
Apttus_Approval__Approval_Status__c='Not Submitted',
Apttus_Approval__Approver_Comments__c='test comment2',
Apttus_Approval__Assigned_To_Name__c='XYZ User',
Apttus_Approval__Date__c=System.Today()+1,
Apttus_Approval__Actual_Approver__c =PUsers2.Id);

Apttus_Approval__Approval_Request__c appRequest3 = new Apttus_Approval__Approval_Request__c(
Apttus_Approval__Related_Agreement__c=agrr.id,
Apttus_Approval__StepSequence__c=2.000,
Apttus_Approval__PrevAssignedToName__c='XYZ User',
Apttus_Approval__Approval_Status__c='Not Submitted',
Apttus_Approval__Approver_Comments__c='test comment3',
Apttus_Approval__Assigned_To_Name__c='ABC User',
Apttus_Approval__Date__c=System.Today()+1,
Apttus_Approval__Actual_Approver__c =PUsers3.Id);

Apttus_Approval__Approval_Request__c appRequest4 = new Apttus_Approval__Approval_Request__c(
Apttus_Approval__Related_Agreement__c=agrr.id,
Apttus_Approval__StepSequence__c=3.000,
Apttus_Approval__PrevAssignedToName__c='XYZ User',
Apttus_Approval__Approval_Status__c='Assigned',
Apttus_Approval__Approver_Comments__c='test comment4',
Apttus_Approval__Assigned_To_Name__c='ABC User',
Apttus_Approval__Date__c=System.Today()+1,
Apttus_Approval__Actual_Approver__c =PUsers.Id);

insert appRequest1;
insert appRequest2;
insert appRequest3;
insert appRequest4;

/*FROM Apttus_Approval__Approval_Request__c
Apttus_Approval__Related_Agreement__c
Apttus_Approval__Approval_Status__c != 'Pending Approval' AND Apttus_Approval__Approval_Status__c != 'Approval Required' ORDER BY Apttus_Approval__StepSequence__c*/
ApprovalItemController testExe = new ApprovalItemController ();
testExe.relatedRecordId = agrr.Id;
testExe.getAllApprovalStep();
test.stoptest();
}
}