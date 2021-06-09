/*  
* File Name     : NaRadioLeadAssignToCAMTestClass  
* Description   : This Test Class is written to ensure the code coverage for the Trigger "NaRadioLeadAssignToCAM"
*                 is above the mandatory 75%.
* Modification Log
* =============================================================================
*   Ver     Date         Author          Modification
*------------------------------------------------------------------------------
*   1.0    3-Nov-11   Ashutosh Diwedi    Created - 84% of the code is covered.
*   2.0    2-Jul-12   Sirish Soma        Modified to include MPE Parnter Contact Record Type while creating Contacts.
*/

@isTest
private class NaRadioLeadAssignToCAMTestClass {
    @testSetup
   	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c trgrdisbld = new TriggerSettings__c(Name = 'UserTriggerDisabled',IsActive__c=FALSE);
        insert trgrdisbld;
	}
    
    public static testMethod void AssignLeadToCAMTestMethod () {
        User owner = [select Id from User where profile.name='System Administrator' and isActive=true limit 1];
        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='SoldToAccount' limit 1];
        RecordType rt2 = [select Id from RecordType where SObjectType='Account' and Name='Partner' limit 1];
        
        // Created test account        
        Account[] Acts = new Account[1];
        Acts[0] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt2.Id, Level__c='Value Added Distributor',WNS_Track__c= true,Mobility_Track__c=true,Radio_Leads__c=true, Status__c='Active', type='Partner',Role_Created__c = true);
        //Acts[1] = new Account(Name='XXXXXXXX',ownerId=owner.Id, RecordTypeId=rt2.Id, Level__c='Value Added Distributor',WNS_Track__c= false,Mobility_Track__c=true,Radio_Leads__c=true, Status__c='Active', type='Partner');
        //Acts[2] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Value Added Distributor',WNS_Track__c= true,Mobility_Track__c=false, Status__c='Active');
        insert Acts;
        
        // Created test contacts
        Contact[] Conts = new Contact[1];
        //    Conts[0] = new Contact(FirstName='First', LastName='Last', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id, Contact_Type__c='Radio Lead Contact' );
        //    Conts[1] = new Contact(FirstName='Mobility', LastName='last', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id, Contact_Type__c='Radio Lead Contact' );
        //    Conts[2] = new Contact(FirstName='WNS', LastName='last', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id, Contact_Type__c='Radio Lead Contact' );
        // Commented above lines, to update it with Record Type Id for MPE PArtner Contact  
        Conts[0] = new Contact(FirstName='First', LastName='Last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id, Contact_Type__c='Lead Contact' );
        //Conts[1] = new Contact(FirstName='Mobility', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id, Contact_Type__c='Lead Contact' );
        //Conts[2] = new Contact(FirstName='WNS', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id, Contact_Type__c='Lead Contact' );
        insert Conts;
        
        Profile p = [select Id from Profile where Name='EMS Partner Profile NAMR' limit 1];
        String orgId = UserInfo.getOrganizationId();       
        String dateString = 
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        // Created test users  
        User[] PUsers = new User[1];
        PUsers[0] = new User(ContactId=Conts[0].Id, FirstName='First', LastName='Last', alias='abcd', email='last@company.com',Username = uniqueName + '@test' + orgId + '.org',
                             communityNickname='testGuy', profileId=p.Id, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US'); 
        //PUsers[1] = new User(ContactId=Conts[1].Id, FirstName='Mobility', LastName='Partner', alias='abcd', email='last1@company.com', username='Mobility@company.com', communityNickname='testGuy1', profileId=p.Id, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US'); 
        //PUsers[2] = new User(ContactId=Conts[2].Id, FirstName='WNS', LastName='Partner', alias='abcd', email='last2@company.com', username='WNS@company.com', communityNickname='testGuy2', profileId=p.Id, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US' ); 
        try{
        	insert PUsers;
        } catch (Exception exp){
            System.debug('Exception found in NaRadioLeadAssignToCAMTestClass class'+exp.getMessage());
        }        
        RecordType Rec = [Select id from RecordType where Name = 'Global Lead Record' and SobjectType ='Lead' ];
        test.startTest();
        // Created test leads 
        Lead[] newLead = new Lead[1]; 
        
        newLead[0] = new Lead(FirstName='First', LastName='Last', Company='Abc Tele', email='last@aoc.gov', RecordTypeId=Rec.Id, Account__c=Acts[0].Id, ownerId=owner.Id, status='New', state='Alaska', country='United States', Track__c='Radio', Partner_Account_NA__c=Acts[0].id );
        //newLead[1] = new Lead(FirstName='First2', LastName='Last2', Company='army', email='last2@aoc.gov', RecordTypeId=Rec.Id, Account__c=Acts[1].Id, ownerId=owner.Id, status='New', state='Alaska', country='United States', Track__c='Federal-Radio', Partner_Account_NA__c=Acts[0].id, Partner_Assigned_Status__c='Reassign');
        //newLead[2] = new Lead(FirstName='First3', LastName='Last3', Company='army', email='last2@aoc.gov', RecordTypeId=Rec.Id, Account__c=Acts[2].Id, ownerId=owner.Id, status='New', state='Alaska', country='United States', Track__c='Radio' );
        insert newLead; 
        
        
        CAM_Geo_Map__c newCamGeoMap = new CAM_Geo_Map__c(Channel_Account_Manager__c=owner.id, Country__c='United States', State_Province__c='IN', Track__c='Radio' ); 
        insert newCamGeoMap;
        
        // Ressign partner and update partner assigned status
        //newLead[0].Partner_Account_NA__c=Acts[1].id; 
        //newLead[0].Partner_Assigned_Status__c='Reassign';
        //update newLead[0];
        
        // Assign partner
        newLead[0].Partner_Account_NA__c=Acts[0].id; 
        update newLead[0];
        
        // Get the newly created survey for the lead
        List<Lead_Survey__c> newLeadSurvey = new List<Lead_Survey__c>([select Id, Lead__c  from Lead_Survey__c where Lead__c =: newLead[0].id limit 1]);
        
        // Assert if lead survey is found
        //System.assert(newLeadSurvey.size()>0);
        
        // Reassign partner
        newLead[0].Partner_Account_NA__c=Acts[0].id; 
        newLead[0].Partner_Assigned_Status__c='Reassign';
        //newLead[1].Partner_Assigned_Status__c='On time';
        newLead[0].Partner_Assigned_Contact_NA__c = Conts[0].id;
        //update newLead[0];
        // Assign Partner
        //newLead[2].Partner_Account_NA__c=Acts[1].id; 
        //update newLead[2];
        test.stopTest();   
    }
}