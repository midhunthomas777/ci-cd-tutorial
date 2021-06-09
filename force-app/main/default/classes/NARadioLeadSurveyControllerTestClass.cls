@isTest
private class NARadioLeadSurveyControllerTestClass {
    
    /*  
* File Name     : NARadioLeadSurveyControllerTestClass  
* Description   : This trigger is used to Route NA Radio Leads to Radio Inside Sales team by 
*                 querying CAM Geo Map object. Share the Leads with the MQL Group.
*                 Share the Lead to the Partner Users associated with the Partner Assigned Company.
*                 Remove the Partner Assigned Attributes after the 7 Day Reassign email is triggered.
* Modification Log
* =============================================================================
*   Ver     Date         Author              Modification
*------------------------------------------------------------------------------
*   1.0    13-Feb-09   Michael Farrington    Created
*   2.0    02-Jul-12   Sirish Soma           Modified to include MPE Partner Contact Record type while creating Contacts
* 
*/
    @testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
    }
    public static testMethod void LeadSurveyControllerTestMethod () {
        
        TriggerSettings__c  objTriggerDeactivateSwitch1 = new TriggerSettings__c(Name='CustomerAccountTriggerDisabled', IsActive__c=false);
        insert objTriggerDeactivateSwitch1;
        
        DeactivatePLTrigger__c  objTriggerDeactivateSwitch2 = new DeactivatePLTrigger__c(Name='DeativateContactTrigger', Deactivate__c=false);
        insert objTriggerDeactivateSwitch2;
        
        User owner = [select Id from User where profile.name='System Administrator' and isActive=true limit 1];
        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        RecordType rt2 = [select Id from RecordType where SObjectType='Account' and Name='Partner' limit 1];
        
        // Account test data created
        Account[] Acts = new Account[3];
        Acts[0] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt2.Id, Level__c='Value Added Distributor',WNS_Track__c= true,Mobility_Track__c=true,Radio_Leads__c=true, Status__c='Active', type='Partner',BillingCity='San Mateo',BILLINGSTATE='Texas',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States');
        Acts[1] = new Account(Name='XXXXXXXX',ownerId=owner.Id, RecordTypeId=rt2.Id, Level__c='Value Added Distributor',WNS_Track__c= false,Mobility_Track__c=true,Radio_Leads__c=true, Status__c='Active', type='Partner',BillingCity='San Mateo',BILLINGSTATE='Texas',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States');
        Acts[2] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Value Added Distributor',WNS_Track__c= true,Mobility_Track__c=false, Status__c='Active',BillingCity='San Mateo',BILLINGSTATE='Texas',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States');
        insert Acts;
        
        // Contact test data created
        Contact[] Conts = new Contact[3];
        //  Conts[0] = new Contact(FirstName='First', LastName='Last', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id);
        //  Conts[1] = new Contact(FirstName='Mobility', LastName='last', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id);
        // Commented above lines, to update it with Record Type Id for MPE PArtner Contact
        Conts[0] = new Contact(FirstName='First', LastName='Last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id);
        Conts[1] = new Contact(FirstName='Mobility', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[1].Id, ownerId=owner.Id);
        Conts[2] = new Contact(FirstName='WNS', LastName='last', RecordTypeId='01280000000LsIz', email='last@company.com', accountId=Acts[2].Id, ownerId=owner.Id);
        insert Conts;
        
        
        RecordType Rec = [Select id from RecordType where Name = 'Global Lead Record' and SobjectType ='Lead' ];
        
        // Lead test data created
        Lead[] newLeads = new Lead[2];
        newLeads[0] = new Lead(FirstName='First', LastName='Last', Company='Abc Tele', email='last@aoc.gov', RecordTypeId=Rec.Id, Account__c=Acts[2].Id, ownerId=owner.Id, status='New', state='Indiana', country='United States', Track__c='Radio', Partner_Account_NA__c=Acts[0].id );
        newLeads[1] = new Lead(FirstName='First2', LastName='Last2', Company='army', email='last2@aoc.gov', RecordTypeId=Rec.Id, Account__c=Acts[2].Id, ownerId=owner.Id, status='New', state='Texas', country='United States', Track__c='Federal-Radio', Partner_Account_NA__c=Acts[0].id );
        insert newLeads;
        
        // Test lead surveys created
        Lead_Survey__c[] newLeadSurveys = new Lead_Survey__c[2];
        newLeadSurveys[0]  = new Lead_Survey__c(Lead__r=newLeads[0], Contact__r=Conts[0], Created_On__c=datetime.now() );    
        newLeadSurveys[1]  = new Lead_Survey__c(Lead__r=newLeads[1], Contact__r=Conts[1], Created_On__c=datetime.now() );    
        
        insert newLeadSurveys; 
        
        PageReference pageRef = Page.LeadSurvey;
        
        Test.setCurrentPage(pageRef);
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', newLeadSurveys[0].id);
        
        LeadSurveyController leadSurveyController = new LeadSurveyController(); 
        
        // Getting the lead survey and populating the response 
        leadSurveyController.getrCurrentLeadSurvey();
        system.debug( 'Account Name=' + leadSurveyController.getAccountName() + 'Survey Id' + leadSurveyController.rCurrentLeadSurvey.id );
        if(leadSurveyController.getQuestionInTouch() == '') 
            leadSurveyController.setQuestionInTouch('Yes');//rCurrentLeadSurvey.Question_1__c);
        if(leadSurveyController.getQuestionInteraction() == null) 
            leadSurveyController.setQuestionInteraction('Good');
        if(leadSurveyController.getQuestionFollowUp() == null)     
            leadSurveyController.setQuestionFollowUp('Good');
        if(leadSurveyController.getQuestionComments() == '')     
            leadSurveyController.setQuestionComments('Test Comment'); 
        
        // Submitting the survey         
        PageReference nextPage = leadSurveyController.save();
        
        PageReference successPageReference =new PageReference ('/apex/LeadSurveyThankYou');
        
        // Check for success page
        System.assertEquals(successPageReference.getUrl(), nextPage.getUrl());
        
        PageReference pageRef2 = Page.LeadSurvey;
        
        Test.setCurrentPage(pageRef2);
        
        
        ApexPages.currentPage().getParameters().put('id', newLeadSurveys[1].id);
        
        LeadSurveyController leadSurveyController2 = new LeadSurveyController(); 
        
        leadSurveyController2.getrCurrentLeadSurvey();
        // Unfilled survey submitted
        PageReference nextPage2 = leadSurveyController2.save();
        // null PageReference is returned by controller  
        System.assertEquals(null, nextPage2);
        
        test.stopTest();
        
    }
    
    
}