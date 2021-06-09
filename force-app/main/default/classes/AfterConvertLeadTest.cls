/* @Class Name   : AfterConvertLeadTest
 * @Description  : Test Class for the AfterConvertLeadTest Trigger
 * @Created By   : Ankit Kumar
 * @Created On   : 18th June 2013
 * @Modification Log:  
 * -----------------------------------------------------------------------------
 * @Developer                Date                  Description 
 * -----------------------------------------------------------------------------
 * @Ankit Kumar            18th June 2013              Created
 * @Bhargavi Vadlamani     20th June 2013              Updated
 * -----------------------------------------------------------------------------
 */ 
@isTest
private class AfterConvertLeadTest {
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
       
           TestDataSetUpUtils.createLM_GeoCodeMaxLimit(1);
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        string leadstr;
        Lead leadobj = new Lead();
        leadobj.lastname = 'TestLead001';
        leadobj.company='TestCompany'; 
        leadobj.Lead_Value__c = 12345.00;
        //Status = '😊 Qualified 😊',
        leadobj.Status = 'Qualified';
        leadobj.Region__c = 'NA';
        leadobj.Technology_Segment__c = 'ASTRO Devices';
        leadobj.Country = 'United States';
        leadobj.Email = 'abcTest@orgTest.com';
        leadobj.Lead_Type__c = 'MR';
        leadobj.RecordTypeId = LeadRecordTypeId;
        leadobj.Industry='Healthcare';
        leadobj.State='illinois';
        leadobj.Close_Date__c = Date.today()+10;
        leadobj.Territory__c = 'T2';
        Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.assignmentRuleHeader.useDefaultRule = false; 
      leadobj.setOptions(dmo);
        
        insert leadobj;         
        
        leadstr = leadobj.id;
        
        Lead leadobj1 = new Lead();
        leadobj1.lastname = 'TestFry1002';
        leadobj1.company='TestCompany009'; 
        leadobj1.Lead_Value__c = 12345.00;
        //Status = '😊 Qualified 😊',
        leadobj1.Status = 'Qualified';
        leadobj1.Region__c = 'NA';
        leadobj1.Technology_Segment__c = 'ASTRO Devices';
        leadobj1.Country = 'United States';
        leadobj1.Email = 'Testabc@Testorg001.com';
        leadobj1.Lead_Type__c = 'MR';
        leadobj1.RecordTypeId = LeadRecordTypeId;
        leadobj1.Industry='Healthcare';
        leadobj1.State='illinois';
        leadobj1.Close_Date__c = Date.today()+10;
        leadobj1.Territory__c = 'T2';
        
        Database.DMLOptions dmo1 = new Database.DMLOptions();
      dmo1.assignmentRuleHeader.useDefaultRule = false; 
      leadobj1.setOptions(dmo1);
        
        insert leadobj1; 
          
        
        
        
        
        DeactivateOpportunityTrigger__c setting1 = new DeactivateOpportunityTrigger__c (Name='Deactivate OppRelatedActions');
        insert setting1;
          DeactivateOpportunityTrigger__c setting = new DeactivateOpportunityTrigger__c (Name='Deactivate UpdateAwardStatusValue');
        insert setting;
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadobj1.id);
        lc.setLeadId(leadobj.id);
        lc.setOwnerId(UserInfo.getUserId());
       
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus('Qualified');
       System.debug('convertStatus'+convertStatus);
        //Database.LeadConvertResult lcr = Database.convertLead(lc);
        //System.assert(lcr.isSuccess());
        
        Test.stopTest();      
    }
    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        TestDataSetUpUtils.createLM_GeoCodeMaxLimit(1);
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        string leadstr;
        Lead leadobj = new Lead();
        leadobj.lastname = 'Test001Fry';
        leadobj.company='TestFryComapny'; 
        leadobj.Lead_Value__c = 12345.00;
        //Status = '😊 Qualified 😊',
        leadobj.Status = 'Qualified';
        leadobj.Region__c = 'NA';
        leadobj.Technology_Segment__c = 'ASTRO Devices';
        leadobj.Country = 'United States';
        leadobj.Email = 'Testabc@orgTest.com';
        leadobj.Lead_Type__c = 'MR';
        leadobj.RecordTypeId = LeadRecordTypeId;
        leadobj.Industry='Healthcare';
        leadobj.State='illinois';
        leadobj.Close_Date__c = Date.today()+10;
        leadobj.Territory__c = 'T2';
        Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.assignmentRuleHeader.useDefaultRule = false; 
      leadobj.setOptions(dmo);
        
        insert leadobj; 
        
        
        leadstr = leadobj.id;
        
        Lead leadobj1 = new Lead();
        leadobj1.lastname = 'TestLastnameFry';
        leadobj1.company='TestCompany001'; 
        leadobj1.Lead_Value__c = 12345.00;
        //Status = '😊 Qualified 😊',
        leadobj1.Status = 'Qualified';
        leadobj1.Region__c = 'NA';
        leadobj1.Technology_Segment__c = 'ASTRO Devices';
        leadobj1.Country = 'United States';
        leadobj1.Email = 'Testabc001@Testorg.com';
        leadobj1.Lead_Type__c = 'MR';
        leadobj1.RecordTypeId = LeadRecordTypeId;
        leadobj1.Industry='Healthcare';
        leadobj1.State='illinois';
        leadobj1.Close_Date__c = Date.today()+10;
        leadobj1.Territory__c = 'T2';
        
        Database.DMLOptions dmo2 = new Database.DMLOptions();
      dmo2.assignmentRuleHeader.useDefaultRule = false; 
      leadobj1.setOptions(dmo2);
        
        insert leadobj1; 
         
        
        DeactivateOpportunityTrigger__c setting1 = new DeactivateOpportunityTrigger__c (Name='Deactivate OppRelatedActions');
        insert setting1;
         DeactivateOpportunityTrigger__c setting = new DeactivateOpportunityTrigger__c (Name='Deactivate UpdateAwardStatusValue');
        insert setting;
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadobj1.id);
        lc.setLeadId(leadobj.id);
       lc.setOwnerId(UserInfo.getUserId());
       
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus('Qualified');
        
        //Database.LeadConvertResult lcr = Database.convertLead(lc);
        //System.assert(lcr.isSuccess());
        
        
        
        List<Lead> leadlst = new list<Lead>();
        leadlst.add(leadobj);
        leadlst.add(leadobj1);
        
        List<id> leadids = new list<id>();
        leadids.add(leadobj1.id);
        leadids.add(leadobj.id);
        UpdateLead objUpdateLead = new UpdateLead();
         objUpdateLead.UpdateLead(leadids);
        UpdateLead.UpdateLeadRecords(leadids);
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        for(Lead eachLead : leadlst) {
			newLeadMap.put(eachLead.id,eachLead);
        }
        //GenericWithoutSharing ctrl = new GenericWithoutSharing();
        //ctrl.convertLeadWithoutSharing(newLeadMap);
        Test.stopTest();      
    }
}