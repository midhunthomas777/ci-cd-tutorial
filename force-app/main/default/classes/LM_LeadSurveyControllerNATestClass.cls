@isTest
private class LM_LeadSurveyControllerNATestClass {

/*  
* File Name     : LM_LeadSurveyControllerNATestClass  
* Description   : This trigger is used to Route NA Radio Leads to Radio Inside Sales team by 
*                 querying CAM Geo Map object. Share the Leads with the MQL Group.
*                 Share the Lead to the Partner Users associated with the Partner Assigned Company.
*                 Remove the Partner Assigned Attributes after the 7 Day Reassign email is triggered.
* Modification Log
* =============================================================================
*   Ver     Date         Author              Modification
*------------------------------------------------------------------------------
*  while creating Contacts
* 
*/
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

     static void setup(){
         //Added by Niran - test class stabilization - December 27,2017
         TriggerDeactivateSwitch__c  objTriggerDeactivateSwitch = new TriggerDeactivateSwitch__c(Name='AccountUpdateRelatedMCNTrigger', IsTriggerActive__c=FALSE);
         insert objTriggerDeactivateSwitch;
         List<DeactivatePLTrigger__c> customsettingslist = new List<DeactivatePLTrigger__c>();
         DeactivatePLTrigger__c DeactivatePLTrigger = new DeactivatePLTrigger__c (Name='DeativateLocName',Deactivate__c = true);
         customsettingslist.add(DeactivatePLTrigger);
         DeactivatePLTrigger__c DeactivatePLTrigger1 = new DeactivatePLTrigger__c (Name='DeativateUpdateHQ',Deactivate__c = true);
         customsettingslist.add(DeactivatePLTrigger1);
         DeactivatePLTrigger__c DeactivatePLTrigger2 = new DeactivatePLTrigger__c (Name='DeativateContactTrigger',Deactivate__c = true);
         customsettingslist.add(DeactivatePLTrigger2);        
         insert customsettingslist;

        
        }

    public static testMethod void LeadSurveyControllerNATestMethod () {

        User owner = [select Id, name, email from User where profile.name='System Administrator' and isActive=true limit 1];

        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='SoldToAccount' limit 1];
        RecordType rt2 = [select Id from RecordType where SObjectType='Account' and Name='Partner' limit 1];
        RecordType rtPartner = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        // Account test data created
        Id PartnerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        List<Account> PartnerAccList = TestDataSetUpUtils.createAccounts(2,PartnerRecordTypeID);
        PartnerAccList[0].Radio_Leads__c = true;
        update PartnerAccList;
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,PartnerAccList);
        contactList[0].Contact_Type__c = 'Lead Contact';
        contactList[1].Contact_Type__c = 'Lead Contact';
        Update contactList;
        
    
        RecordType Rec = [Select id from RecordType where Name = 'Global Lead Record' and SobjectType ='Lead' ];
        CAM_Geo_Map__c cam=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='DEFAULT OWNER NAMR',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert cam;
        CAM_Geo_Map__c camUS=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='United States',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert camUS;
        LM_GeoCodeMaxLimit__c lmgcml = new LM_GeoCodeMaxLimit__c();     
        lmgcml.name = 'GeoCode Limit';
        lmgcml.LM_limit__c = 100;
        insert lmgcml;
        List<Partner_location__c> partnerList= new List<Partner_location__c>();
        Partner_location__c partnerLoc = new Partner_location__c(State__c='IL',Country1__c='United States' );
        partnerLoc.Account__c= PartnerAccList[0].id;
        partnerLoc.City__c = 'Bengaluru';
        partnerLoc.Phone__c = '234234234';
        partnerLoc.Country1__c = 'dfdsfsdf';
        partnerLoc.State_Code__c = 'IL';
        partnerLoc.State__c = '42342';
        partnerLoc.Postal_code__c = '342424';
        partnerLoc.Address_Type__c ='Primary Location';
        //insert partnerLoc;
        partnerList.add(partnerLoc);
        // Lead test data created
        /*Lead[] newLeads = new Lead[2];
        newLeads[0] = new Lead(Partner_Account_NA__c=PartnerAccList[0].id,Partner_Assigned_Contact_NA__c=contactList[0].id,lastname='test lead',RecordTypeId = '01280000000LqYf',Track__c = 'Radio',Country= 'United states',state='Alabama',Company='Infosys',Industry='Manufacturing',Status='New',Technology_Segment__c='Professional and Commercial Radio',Latitude=42.070531300000000,Longitude=-88.050729800000000,email='asd@gmail.com',phone='2342342');
        newLeads[1] = new Lead(Partner_Account_NA__c=PartnerAccList[1].id,Partner_Assigned_Contact_NA__c=contactList[1].id,lastname='test lead',RecordTypeId = '01280000000LqYf',Track__c = 'Radio',Country= 'United states',state='Alabama',Company='Infosys',Industry='Manufacturing',Status='New',Technology_Segment__c='Professional and Commercial Radio',Latitude=42.070531300000000,Longitude=-88.050729800000000,email='asd@gmail.com',phone='2342342'); 
        insert newLeads;
		*/
        Account pa = new Account();
        pa.Name = 'ParentAccount';
        pa.Hierarchy_Placement__c = 'Global Account';
        pa.Partner_Region__c = 'APAC';
        pa.BillingCity='Bangalore';
        pa.BillingCountry='India';
        insert pa;
        RecordType objLeadRecTypeAcc = [Select Id from RecordType where sObjectType ='Account' And DeveloperName ='Motorola_Customer_Number' limit 1];
        Account acc= new Account(Customer_or_Prospect_Account__c = pa.Id,Name = 'Test123', Hierarchy_Placement__c = 'Global Account', Partner_Region__c = 'APAC', RecordTypeId = objLeadRecTypeAcc.ID,BillingCity='Bangalore',BillingCountry='India');
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u3 = new User(Alias = 'ran12', Email='test12345@testorg.com', 
                           EmailEncodingKey='UTF-8',FirstName='First', LastName='Testing123', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='ndsabc'+Math.random()+'@testorg.com');
        insert u3;
        Id objLeadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        Lead leadRecord2 = new Lead();
        leadRecord2.Company = 'IT';
        leadRecord2.Status = 'Marketing Lead';
        leadRecord2.Track__c = 'Direct';
        leadRecord2.Region__c = 'NA';
        leadRecord2.LastName = 'Test';
        leadRecord2.Industry = 'Education';
        leadRecord2.Email = 'test@gmail.com';
        leadRecord2.Country='Canada';
        leadRecord2.State = 'Alberta';
        leadRecord2.Street = 'New Colony';
        leadRecord2.Territory__c = 'T1';
        leadRecord2.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        leadRecord2.City ='test';
        leadRecord2.Account__c = pa.Id;
        leadRecord2.Visitor_Info__c = 'Test Visitor';
        leadRecord2.Technology_Segment__c = 'Accessories & Energy';
        leadRecord2.RecordTypeId = objLeadRecType;
        leadRecord2.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        leadRecord2.Indirect_CAM__c = u3.id;
        leadRecord2.Channel_Partner__c = acc.id;
        leadRecord2.Overdue_Status__c = 'Overdue';
        leadRecord2.Countrycode = 'CA';
        leadRecord2.Statecode = 'AB';
        leadRecord2.Lead_Value__c = 50;
        leadRecord2.OwnerId = u3.id;
        leadRecord2.Partner_Assigned_Status__c = 'Reassign';
        leadRecord2.Partner_Account_NA__c = PartnerAccList[0].Id;
        leadRecord2.Partner_Assigned_Contact_NA__c = contactList[0].Id;
        leadRecord2.Latitude = 17.3850;
        leadRecord2.Longitude = 78.4867;
        leadRecord2.Technology_Segment__c = 'Professional and Commercial Radio';
        insert leadRecord2;
        
        // Test lead surveys created
        Lead_Survey__c[] newLeadSurveys = new Lead_Survey__c[2];
        newLeadSurveys[0] = new Lead_Survey__c(Lead__c=leadRecord2.id, Contact__r=contactList[0], Created_On__c=Datetime.now() );    
        newLeadSurveys[1] = new Lead_Survey__c(Lead__c=leadRecord2.id, Contact__r=contactList[1], Created_On__c=Datetime.now() );    

        insert newLeadSurveys; 
        test.startTest();
        PageReference pageRef = Page.LeadSurveyNA;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', newLeadSurveys[0].id);
        LeadSurveyControllerNA leadSurveyControllerNA = new LeadSurveyControllerNA(); 
       leadSurveyControllerNA.locationList= partnerList;
       leadSurveyControllerNA.getAccountName();
       leadSurveyControllerNA.getEmail();
        // Getting the lead survey and populating the response 
        leadSurveyControllerNA.getrCurrentLeadSurvey();
        /* system.debug( 'Account Name=' + leadSurveyController.getAccountName() + 'Survey Id' + leadSurveyControllerNA.rCurrentLeadSurvey.id ); */
        if(leadSurveyControllerNA.getQuestionInTouch() == '') 
            leadSurveyControllerNA.setQuestionInTouch('Yes');//rCurrentLeadSurvey.Question_1__c);
        if(leadSurveyControllerNA.getQuestionInteraction() == null) 
            leadSurveyControllerNA.setQuestionInteraction('Good');
        if(leadSurveyControllerNA.getQuestionFollowUp() == null)     
            leadSurveyControllerNA.setQuestionFollowUp('Good');
        if(leadSurveyControllerNA.getQuestionComments() == '')     
            leadSurveyControllerNA.setQuestionComments('Test Comment'); 
        
        // Submitting the survey         
        PageReference nextPage = leadSurveyControllerNA.save();
        
        PageReference successPageReference =new PageReference ('/apex/LeadSurveyGovtThankYou');
        
        // Check for success page
        System.assertEquals(successPageReference.getUrl(), nextPage.getUrl());
        
        PageReference pageRef2 = Page.LeadSurveyNA;
        
        Test.setCurrentPage(pageRef2);
        
                
        ApexPages.currentPage().getParameters().put('id', newLeadSurveys[1].id);

        LeadSurveyControllerNA leadSurveyControllerNA2 = new LeadSurveyControllerNA(); 
        
        leadSurveyControllerNA2.getrCurrentLeadSurvey();
        // Unfilled survey submitted
        PageReference nextPage2 = leadSurveyControllerNA2.save();
        // null PageReference is returned by controller  
        System.assertEquals(null, nextPage2);
        
        test.stopTest();
        
}
 

}