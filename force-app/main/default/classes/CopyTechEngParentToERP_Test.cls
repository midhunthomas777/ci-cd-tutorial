@isTest
/*
 * File Name  : CopyTechEngParentToERP_Test
 * Description: This class is to unit test code for the trigger: CopyTechEngParentToERP
 * Author     : Meghana Sreenath Basetty
 * Modification Log 
 * ============================================================================= 
 * Ver   Date        Author                         Modification 
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 1.0   12/10/2012   Meghana Sreenath Basetty       Initial Code.
 */ 
 
 private class CopyTechEngParentToERP_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c trgrdisbld = new TriggerSettings__c(Name = 'CustomerAccountTriggerDisabled',IsActive__c = TRUE);
        insert trgrdisbld;
    }
        public static testMethod void testCopyTechEngParentToERP(){
        
      // Create an Account
    RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account parentAcc = new Account(name='Test Account1',RecordTypeId=theRecordType.Id,Partner_Region__c = 'APAC',Metal_Level__c = 'GOLD' );
        insert parentAcc ;
        Account child = new Account(name='Test Account2',BillingCountry='India',Billingcity='Test', ParentId=parentAcc.id,Partner_Region__c = 'EMEA' ,Hierarchy_Placement__c='ERP Account' );
        insert child ;
    // Create Prog info for the child account
    
     List<Partner_Type__c> ProgInfolist = new List<Partner_Type__c>();
     Partner_Type__c p1 = new Partner_Type__c(Account__c=parentAcc.id,Program__c='SCADA',US_Federal__c = true, Status__c = '',Purchasing_Method__c = 'Tier1');
     ProgInfolist.add(p1);
     Partner_Type__c p2 = new Partner_Type__c(Account__c=parentAcc.id,Program__c='Mobility',US_Federal__c = true, Status__c = 'Inactive',Purchasing_Method__c = '');
     ProgInfolist.add(p2);
     insert ProgInfolist ; 
     List<Partner_Type__c> ProgInfolist1 = new List<Partner_Type__c>();
     Partner_Type__c p3 = new Partner_Type__c(Account__c=child.id,Program__c='SCADA',US_Federal__c = true);
     ProgInfolist1.add(p3);
     Partner_Type__c p4 = new Partner_Type__c(Account__c=child.id,Program__c='Mobility',US_Federal__c = true);
     ProgInfolist1.add(p4);
     insert ProgInfolist1 ; 
        
     
      // Create ProgramDetails
    List<Technology_Specialization__c> ProgDetailslist = new List<Technology_Specialization__c>();

    Technology_Specialization__c t1 = new Technology_Specialization__c(Partner_Program__c= p1.id,Community_Type__c='Value Added Reseller',
                        Technology_Specialization__c='Mobile Computing',Technology_Specialization_Level__c='Open',Type__c = 'Technology');
    ProgDetailslist.add(t1);
    Technology_Specialization__c t2 = new Technology_Specialization__c(Partner_Program__c= p2.id,Community_Type__c='Value Added Reseller',
                        Technology_Specialization__c='RFID',Technology_Specialization_Level__c='Open',Type__c = 'Technology');
    ProgDetailslist.add(t2);
    insert ProgDetailslist;
     List<Technology_Specialization__c> ProgDetailslist1 = new List<Technology_Specialization__c>();
    Technology_Specialization__c t3 = new Technology_Specialization__c(Partner_Program__c= p3.id,Community_Type__c='Value Added Reseller',
                        Technology_Specialization__c='Mobile Computing',Technology_Specialization_Level__c='Open',Type__c = 'Technology');
    ProgDetailslist1.add(t3);
    Technology_Specialization__c t4 = new Technology_Specialization__c(Partner_Program__c= p4.id,Community_Type__c='Value Added Reseller',
                        Technology_Specialization__c='RFID',Technology_Specialization_Level__c='Open',Type__c = 'Technology');
    ProgDetailslist1.add(t4);
    insert ProgDetailslist1;
    List<Technology_Specialization__c> UpdateProgDetailslist = new List<Technology_Specialization__c>();
    t1.Technology_Specialization_Level__c='Authorized';
    UpdateProgDetailslist.add(t1);
    Update UpdateProgDetailslist;
    UpdateProgDetailslist.clear();
    t2.Technology_Specialization_Level__c='Specialist';
    UpdateProgDetailslist.add(t2);
    Update UpdateProgDetailslist;
        
 }
 }