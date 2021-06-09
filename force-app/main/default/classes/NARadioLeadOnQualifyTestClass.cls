@isTest
private class NARadioLeadOnQualifyTestClass {
    /*  
* File Name     : NARadioLeadOnQualifyTestClass  
* Description   : This test class is written to ensure the code covergae for the Trigger "NARadioLeadOnQualify"
*                 is above the mandatory 75%.
* Modification Log
* =============================================================================
*   Ver     Date         Author           Modification
*------------------------------------------------------------------------------
*   1.0    03-Nov-11   Ashutosh Diwedi    Created
*   2.0    02-Jul-12   Sirish Soma        Modified to include MPE Parnter Contact Record Type while creating Contacts.
*   3.0    27-Oct-15   Sai Sampath        Renamed Profile NAMR Enterprise Standard User renamed to NAMR Zebra Standard User
*/
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    public static testMethod void OnQualifyNewTestMethod () {
        
        TriggerSettings__c  objTriggerDeactivateSwitch1 = new TriggerSettings__c(Name='CustomerAccountTriggerDisabled', IsActive__c=false);
        insert objTriggerDeactivateSwitch1;
        
        DeactivatePLTrigger__c  objTriggerDeactivateSwitch2 = new DeactivatePLTrigger__c(Name='DeativateContactTrigger', Deactivate__c=false);
        insert objTriggerDeactivateSwitch2;
        
        //User owner = [select Id from User where profile.name='Motorola Enterprise Standard User' and isActive=true limit 1];
        
        // User owner = [select Id from User where profile.name='NAMR Zebra Standard User' and isActive=true limit 1];
        User owner = [select Id from User where isActive=true and Isportalenabled=false limit 1]; 
        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and Name='Partner' limit 1];
        
        //Accounts for test data
        Account[] Acts = new Account[3];
        Acts[0] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true, Status__c='Active', Radio_Leads__c=true, type='Partner');
        Acts[1] = new Account(Name='XXXXXXXX',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Authorized Reseller',WNS_Track__c= false,Mobility_Track__c=true, Status__c='Active', Radio_Leads__c=true, type='Partner');
        Acts[2] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=false, Status__c='Active', Radio_Leads__c=true, type='Partner');
        insert Acts;
        
        //Contacts for test data
        Contact[] Conts = new Contact[3];
        //        Conts[0] = new Contact(FirstName='First', LastName='Last', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id);
        //        Conts[1] = new Contact(FirstName='Mobility', LastName='last', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id);
        //       Conts[2] = new Contact(FirstName='WNS', LastName='last', email='last@company.com', accountId=Acts[2].Id, ownerId=owner.Id);
        // Commented above lines, to update it with Record Type Id for MPE PArtner Contact
        Conts[0] = new Contact(FirstName='First', LastName='Last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id);
        Conts[1] = new Contact(FirstName='Mobility', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id);
        Conts[2] = new Contact(FirstName='WNS', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[2].Id, ownerId=owner.Id);
        insert Conts;
        
        RecordType Rec = [Select id from RecordType where Name = 'Global Lead Record' and SobjectType ='Lead' ];
        // New Lead created
        Lead newLead = new Lead(FirstName='First', LastName='Last', Company='Abc Tele', email='last@company.com', RecordTypeId=Rec.Id, Account__c=Acts[0].Id, ownerId=owner.Id);
        insert newLead ;
        String dt ='12/31/2018';  
            date CloseDT=date.parse(dt);
        
        test.startTest(); 
        
        newLead.status ='In Progress';
        //Commented as part of Delete_unused_Objects_SF-488
        //newLead.Opportunity_Stage__c = 'Identified';
        newLead.Budget_Value__c  = 12345;
        
        update newLead;
        
        // Lead status updated to 'Qualified'
        newLead.status ='Qualified';
        //Commented as part of Delete_unused_Objects_SF-488
        //newLead.Opportunity_Stage__c = 'Identified';
        newLead.Budget_Value__c  = 12345;
        newlEad.Lead_Value__c = 12345;
        newlEad.Close_Date__c = CloseDT;
        update newLead;
        
        // Lead Opportunity Stage updated to 'Identified'
        //Commented as part of Delete_unused_Objects_SF-488
        //newLead.Opportunity_Stage__c='Identified';
        update newLead;
        // Check is opportunity is created
        /*Commenting as part of SF-491 - Delete unused custom objects - Start
List<Opportunity__c> newOpp = new List<Opportunity__c>( [SELECT Id, Lead_Id__c FROM Opportunity__c WHERE Lead_Id__c =:newLead.id]);
Commenting as part of SF-491 - Delete unused custom objects - End*/
        //System.assert(newOpp.size()>0 );
        
        //   Campaign camp = new Campaign(Name='Test Camp',Demand_Center_Lead__c = 'Laura Meier', Event_Date__c=System.TODAY());
        //   Database.SaveResult sr = Database.insert(camp);
        
        test.stopTest();   
        
        
    }
}