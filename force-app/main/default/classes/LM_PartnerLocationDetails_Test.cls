@isTest
Private class LM_PartnerLocationDetails_Test {
    
    // it tests LM_AutoRecommendationGridController class
    
    static testMethod void testPartnerLocation(){
        Testdatasetuputils.insertcustomsettings();
        Id objLeadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        User owner = [select Id from User where profileid='00e80000001KTLS' and isActive=true limit 1];

        Id PartnerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();  
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        List<Account> PartnerAccList = TestDataSetUpUtils.createAccounts(2,PartnerRecordTypeID);
        PartnerAccList[0].Radio_Leads__c = true;
        update PartnerAccList;
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,PartnerAccList);
        contactList[0].Contact_Type__c = 'Lead Contact';
        contactList[1].Contact_Type__c = 'Lead Contact';
        Update contactList;
        
        Partner_Type__c progInfo = new Partner_Type__c(Program__c= 'Radio solutions',Account__c=PartnerAccList[0].id,Status__c= 'Active');
        insert progInfo;
        Technology_Specialization__c techRecord1= new Technology_Specialization__c(Technology_Specialization__c='Professional and Commercial Radio',Technology_Specialization_Status__c='Active',Partner_Program__c = progInfo.id, Technology_Specialization_Level__c= 'Specialist',Community_Type__c='Value Added Reseller',Type__c='Technology');
        techRecord1.Account__c=PartnerAccList[0].id;
        insert techRecord1;
        Technology_Specialization__c techRecord2= new Technology_Specialization__c(Technology_Specialization__c='Business Radio',Technology_Specialization_Status__c='Active',Partner_Program__c = progInfo.id, Technology_Specialization_Level__c= 'Elite Specialist',Community_Type__c='Value Added Reseller',Type__c='Technology');
        techRecord2.Account__c=PartnerAccList[1].id;
        insert techRecord2;
        
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
        Industry__c industry=new Industry__c(Account__c=PartnerAccList[0].id,Industry_Type__c='Manufacturing');
        insert industry;
        CAM_Geo_Map__c cam=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='DEFAULT OWNER NAMR',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert cam;
        LM_GeoCodeMaxLimit__c lmgcml = new LM_GeoCodeMaxLimit__c();     
        lmgcml.name = 'GeoCode Limit';
        lmgcml.LM_limit__c = 100;
        insert lmgcml;
        CAM_Geo_Map__c camUS=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='United States',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert camUS;

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
        
        Lead leadRecord1 = new Lead();
        leadRecord1.Company = 'IT';
        leadRecord1.Status = 'Marketing Lead';
        leadRecord1.Track__c = 'Direct';
        leadRecord1.Region__c = 'NA';
        leadRecord1.LastName = 'Test';
        leadRecord1.Industry = 'Education';
        leadRecord1.Email = 'test@gmail.com';
        leadRecord1.Country='Canada';
        leadRecord1.State = 'Alberta';
        leadRecord1.Street = 'New Colony';
        leadRecord1.Territory__c = 'T1';
        leadRecord1.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        leadRecord1.City ='test';
        leadRecord1.Account__c = pa.Id;
        leadRecord1.Visitor_Info__c = 'Test Visitor';
        leadRecord1.Technology_Segment__c = 'Accessories & Energy';
        leadRecord1.RecordTypeId = objLeadRecType;
        leadRecord1.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        leadRecord1.Indirect_CAM__c = u3.id;
        leadRecord1.Channel_Partner__c = acc.id;
        leadRecord1.Overdue_Status__c = 'Overdue';
        leadRecord1.Countrycode = 'CA';
        leadRecord1.Statecode = 'AB';
        leadRecord1.Lead_Value__c = 50;
        leadRecord1.OwnerId = u3.id;
        leadRecord1.Partner_Assigned_Status__c = 'Reassign';
        leadRecord1.Partner_Account_NA__c = PartnerAccList[0].Id;
        leadRecord1.Partner_Assigned_Contact_NA__c = contactList[0].Id;
        leadRecord1.Technology_Segment__c = 'Professional and Commercial Radio';
        leadRecord1.Latitude = 17.3850;
        leadRecord1.Longitude = 78.4867;
        insert leadRecord1;
        
        LM_PartnerLocationDetails test = new LM_PartnerLocationDetails();
        test.name ='test';
        test.partnerWebsite  ='http://google.co.in';
        test.partnerPhone  ='1258787';
        test.partnerCity  ='test city';
        test.partnerState  ='IL';
        test.partnerCountry  ='USA';
        test.zipCode ='545646';
        test.locationList= partnerList;
        test.setLeadId(leadRecord1.id);
        test.getLeadId();
        test.getDetails();
    }
}