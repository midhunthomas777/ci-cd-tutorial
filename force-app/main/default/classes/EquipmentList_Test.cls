@isTest
private class EquipmentList_Test
{
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }


static testmethod void InsertEquipmentList()
{   
       test.startTest();
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User us = new User();
        User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser){
        us = new User(Alias = 'zzebi', Email='testOppo@abc1.com',
        EmailEncodingKey='UTF-8', LastName='Kommula', FirstName='Narsa Reddy', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles',Primary_Business_Group__c='Government', UserName='testxyzUser@testorg.com',Core_ID__c = 'CDTX888',IsActive=true);
        insert us;
        }
     System.RunAs(us)
     {
        //Opportunity opp = new Opportunity(name='testopp',Equipment_List_Attached__c=true, stagename='Prospect',closedate=System.today(), ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1, pull_forward_date__c=System.today()-1);
        RecordType rtype = [Select Id from RecordType where DeveloperName='Registration' and SobjectType='Opportunity' limit 1];
        Opportunity opp = new Opportunity(name='testopp',Equipment_List_Attached__c=true,Status__c='Active' ,stagename='Prospect',closedate=System.today(), ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1,ForecastCategoryName='Non Commit',recordtypeid=rtype.id);
        DeactivateOpportunityTrigger__c TestCT=new DeactivateOpportunityTrigger__c();
        TestCT.Deactivate__c=false;
        TestCT.name='Deactivate OppRelatedActions';
        Insert TestCT;
        
         DeactivateOpportunityTrigger__c TestCT1=new DeactivateOpportunityTrigger__c ();
         TestCT1.Deactivate__c=false;
         TestCT1.name='Deactivate UpdateAwardStatusValue';
         insert TestCT1;
        
        DeactivateOpportunityTrigger__c TestCT2=new DeactivateOpportunityTrigger__c ();
         TestCT2.Deactivate__c=false;
         TestCT2.name='BypassPartnerOpptyRegistration';
         insert TestCT2;
         
        insert opp;
          Blob b = Blob.valueOf('Test Data1234444');  
   
        attachment at=new attachment(); 
        at.name='EQ';
        at.parentId=opp.Id;
        at.Description='test attachment';
        at.Body=b;
        insert at;
      test.stopTest();
     }
     
     
     }
     
     static testmethod void DeleteEquipmentList()
{   
       test.startTest();
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User us = new User();
        User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser){
        us = new User(Alias = 'zzebi', Email='testOppo@abc1.com',
        EmailEncodingKey='UTF-8', LastName='Kommula', FirstName='Narsa Reddy', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles',Primary_Business_Group__c='Government', UserName='testxyzUser@testorg.com',Core_ID__c = 'FTRS111',IsActive=true);
        insert us;
        }
     System.RunAs(us)
     {
        //Opportunity opp = new Opportunity(name='testopp',Equipment_List_Attached__c=true, stagename='Secure',closedate=System.today(), ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1, pull_forward_date__c=System.today()-1);
        Opportunity opp = new Opportunity(name='testopp',Equipment_List_Attached__c=true, Status__c ='Active',stagename='Secure',closedate=System.today(), ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1, pull_forward_date__c=System.today()-1,ForecastCategoryName='Commit');
        DeactivateOpportunityTrigger__c TestCT=new DeactivateOpportunityTrigger__c();
        TestCT.Deactivate__c=false;
        TestCT.name='Deactivate OppRelatedActions';
        Insert TestCT;
        
         DeactivateOpportunityTrigger__c deactivateUpdateAwardStatus = DeactivateOpportunityTrigger__c.getValues('Deactivate UpdateAwardStatusValue');   
         DeactivateOpportunityTrigger__c TestCT1=new DeactivateOpportunityTrigger__c ();
         TestCT1.Deactivate__c=false;
         TestCT1.name='Deactivate UpdateAwardStatusValue';
         insert TestCT1;
         
           DeactivateOpportunityTrigger__c TestCT2=new DeactivateOpportunityTrigger__c ();
         TestCT2.Deactivate__c=false;
         TestCT2.name='BypassPartnerOpptyRegistration';
         insert TestCT2;
        insert opp;
        Blob b = Blob.valueOf('Test Data123tytytytyttyt4'); 
        attachment at=new attachment();
        
        at.name='EQ';
        at.parentId=opp.Id;
        at.Description='test attachment232322';
        at.body=b;
        insert at;
        delete at;
      test.stopTest();
     }
     
     
     }
     
}