@isTest
private class ChannelProgramTriggerHandler_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.createLdapSetting();
        Map<String,ChannelProgram> programMap = TestDataSetUpUtils.insertChannelProgram();
        TestDataSetUpUtils.insertChannelProgramLevel(programMap.values());
        TriggerSettings__c tg = new TriggerSettings__c();
        tg.Name='CustomerAccountTriggerDisabled';
        tg.IsActive__c=true;
        insert tg;
    }
    
    static TestMethod void insertTechSpecsAndActivePartnerUser(){
        List<Account> partnerAccs = new List<Account>();
        List<Contact> partnerCons = new List<Contact>();
        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c> ();
        List<Technology_Specialization__c> techSpecs= new List<Technology_Specialization__c>();
        List<Technology_SubSegment__c> techSubSpecs= new List<Technology_SubSegment__c>();
        
        partnerAccs = TestDataSetUpUtils.createAccounts(1, GlobalUtility.recordTypeId('Account', 'Partner'));
        partnerAccs[0].Partner_Region__c = 'NAMR';
        partnerAccs[0].Metal_Level__c = 'Gold';
        update partnerAccs[0];
        partnerCons = TestDataSetUpUtils.createContacts(2, GlobalUtility.recordTypeId('Contact', 'Partner'), partnerAccs);
        
        User usr = TestDataSetUpUtils.insertPartnerAdminUser(partnerCons[0],'NAMR','testPartnerCont@mailinator.com',TRUE);
        insert usr;
        
        
        Partner_Type__c radioType = new Partner_Type__c(Program__c = 'RADIO',Account__c = partnerAccs[0].Id,Partner_Level__c = 'Premier Solution Partner',Status__c='Active',Compliance_Status__c='Compliant');
        insert radioType;
        
        Market_Specializations__c msc = new Market_Specializations__c(Account__c = partnerAccs[0].Id,Market_Specialization__c = 'US Federal',Market_Specialization_Level__c = 'Authorized');
        insert msc;
        
        Technology_Specialization__c PCRVartech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Professional and Commercial Radio',Technology_Specialization_Level__c='Elite Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Value Added Reseller');                
        Technology_Specialization__c MCRVartech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Mission Critical Radio Systems',Technology_Specialization_Level__c='Elite Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Value Added Reseller');                
        Technology_Specialization__c MCRMRtech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Mission Critical Radio Systems',Technology_Specialization_Level__c='Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Federal Manufacturer Representative');      
        Technology_Specialization__c SAStech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Software and Solutions',Technology_Specialization_Level__c='Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Federal Manufacturer Representative');      
        techSpecs.add(PCRVartech);         
        techSpecs.add(MCRVartech); 
        techSpecs.add(MCRMRtech); 
        techSpecs.add(SAStech); 
        insert techSpecs ; 
        
        Technology_SubSegment__c callWorksSub = new Technology_SubSegment__c(Account__c = partnerAccs[0].Id,Program_Detail__c = techSpecs[3].Id ,Segment__c ='Software and Solutions' ,Sub_Segment__c = 'CallWorks',Specialization_Level__c = 'Specialist');
        techSubSpecs.add(callWorksSub);
        insert techSubSpecs;
        
    }
    
    static TestMethod void insertTechSpecsAndInactivePatnerUser(){
        List<Account> partnerAccs = new List<Account>();
        List<Contact> partnerCons = new List<Contact>();
        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c> ();
        List<Technology_Specialization__c> techSpecs= new List<Technology_Specialization__c>();
        List<Technology_SubSegment__c> techSubSpecs= new List<Technology_SubSegment__c>();
        
        partnerAccs = TestDataSetUpUtils.createAccounts(1, GlobalUtility.recordTypeId('Account', 'Partner'));
        partnerAccs[0].Partner_Region__c = 'NAMR';
        partnerAccs[0].Metal_Level__c = 'Gold';
        update partnerAccs[0];
        partnerCons = TestDataSetUpUtils.createContacts(2, GlobalUtility.recordTypeId('Contact', 'Partner'), partnerAccs);
        
        User usr = TestDataSetUpUtils.insertPartnerAdminUser(partnerCons[0],'NAMR','testPartnerContfalee@mailinator.com',FALSE);
        insert usr;
        
        
        Partner_Type__c radioType = new Partner_Type__c(Program__c = 'RADIO',Account__c = partnerAccs[0].Id,Partner_Level__c = 'Premier Solution Partner',Status__c='Active',Compliance_Status__c='Compliant');
        insert radioType;
        
        Market_Specializations__c msc = new Market_Specializations__c(Account__c = partnerAccs[0].Id,Market_Specialization__c = 'US Federal',Market_Specialization_Level__c = 'Authorized');
        insert msc;
        
        Technology_Specialization__c PCRVartech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Professional and Commercial Radio',Technology_Specialization_Level__c='Elite Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Value Added Reseller');                
        Technology_Specialization__c MCRVartech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Mission Critical Radio Systems',Technology_Specialization_Level__c='Elite Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Value Added Reseller');                
        Technology_Specialization__c MCRMRtech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Mission Critical Radio Systems',Technology_Specialization_Level__c='Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Federal Manufacturer Representative');      
        Technology_Specialization__c SAStech=new Technology_Specialization__c(Account__c=partnerAccs[0].Id,Technology_Specialization__c='Software and Solutions',Technology_Specialization_Level__c='Specialist',Partner_Program__c=radioType.id,Community_Type__c = 'Federal Manufacturer Representative');      
        techSpecs.add(PCRVartech);         
        techSpecs.add(MCRVartech); 
        techSpecs.add(MCRMRtech); 
        techSpecs.add(SAStech); 
        insert techSpecs ; 
        
        Technology_SubSegment__c callWorksSub = new Technology_SubSegment__c(Account__c = partnerAccs[0].Id,Program_Detail__c = techSpecs[3].Id ,Segment__c ='Software and Solutions' ,Sub_Segment__c = 'CallWorks',Specialization_Level__c = 'Specialist');
        techSubSpecs.add(callWorksSub);
        insert techSubSpecs;
        
        User anotherAdmin = [SELECT Id FROM User WHERE ProfileId =: UserInfo.getProfileId() AND Id!=: UserInfo.getUserId() AND IsActive = TRUE LIMIT 1];
        test.startTest();
        System.runAs(anotherAdmin){
            usr.IsActive =TRUE;
            update usr;    
        }
        
        
        delete techSpecs;
        test.stopTest();
    }
    
    static TestMethod void testTagBasedPermissionSets(){
        List<Account> partnerAccs = new List<Account>();
        List<Contact> partnerCons = new List<Contact>();
        List<Partner_Type__c> partnerTypes = new List<Partner_Type__c> ();
        List<Technology_Specialization__c> techSpecs= new List<Technology_Specialization__c>();
        List<Technology_SubSegment__c> techSubSpecs= new List<Technology_SubSegment__c>();
        
        partnerAccs = TestDataSetUpUtils.createAccounts(1, GlobalUtility.recordTypeId('Account', 'Partner'));
        partnerAccs[0].Partner_Region__c = 'NAMR';
        partnerAccs[0].Metal_Level__c = 'Gold';
        update partnerAccs[0];
        partnerCons = TestDataSetUpUtils.createContacts(2, GlobalUtility.recordTypeId('Contact', 'Partner'), partnerAccs);
        partnerCons[0].Tag__c = 'Above Price Book Access;Federal Contact;Opportunity Creator';
        update partnerCons[0];
        
        User usr = TestDataSetUpUtils.insertPartnerAdminUser(partnerCons[0],'NAMR','testPartnerContfale3e@mailinator.com',FALSE);
        insert usr;
                
        User anotherAdmin = [SELECT Id FROM User WHERE ProfileId =: UserInfo.getProfileId() AND Id!=: UserInfo.getUserId() AND IsActive = TRUE LIMIT 1];
        test.startTest();
        System.runAs(anotherAdmin){
            usr.IsActive =TRUE;
            update usr;    
        }
        
        
        delete techSpecs;
        test.stopTest();
    }
}