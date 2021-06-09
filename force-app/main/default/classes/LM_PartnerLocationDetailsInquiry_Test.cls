@isTest
Private class LM_PartnerLocationDetailsInquiry_Test {

    // it tests LM_AutoRecommendationGridController class
    
     static testMethod void testPartnerLocation(){
     TestdataSetuputils.insertCustomSettings();
//            User owner = [select Id, name, email from User where profile.name='APAC CHANNEL PCR' and isActive=true limit 1];
User owner = [select Id from User where profileid='00e80000001KTLS' and isActive=true limit 1];
         RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='SoldToAccount' limit 1];
         RecordType rtPartner = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        Account[] Acts = new Account[3];
         Acts[0] = new Account(Name='Test Systems Inc. APME',ownerId=owner.Id, MPE_Program_Status_New__c='Active',
                               RecordTypeId=rtPartner.Id, Level__c='Authorized Reseller',
                               Radio_Partner__c= true,type='partner',Radio_Leads__c= TRUE,BillingCountry='Brazil',Status__c='Active');
         insert Acts[0];
         Acts[1] = new Account(Name='Test Systems Inc. lacr',type='partner',ownerId=owner.Id,
                               MPE_Program_Status_New__c='Active',RecordTypeId=rtPartner.Id, 
                               Level__c='Authorized Reseller',Radio_Partner__c= true,Radio_Leads__c= TRUE,BillingCountry='Brazil',Status__c='Active');
         insert Acts[1];
         RecordType contactrt1 = [select Id from RecordType where SObjectType='Contact' and DeveloperName='MPE_Partner_Contact' limit 1];
          Contact[] Conts = new Contact[3];
        Conts[0] = new Contact(FirstName='APME', LastName='Partner', email='NAMR@partner.com', accountId=Acts[0].Id, Contact_Type__c='Lead Contact',ownerId=owner.Id,RecordTypeId=contactrt1.Id );
        Conts[1] = new Contact(FirstName='LACR', Contact_Type__c='Lead Contact',LastName='Partner', email='LACR@partner.com', accountId=Acts[1].Id, ownerId=owner.Id,RecordTypeId=contactrt1.Id );
        Conts[2] = new Contact(FirstName='Hank', Contact_Type__c='Lead Contact',LastName='Customer', email='last@systems.com', accountId=Acts[0].Id, ownerId=owner.Id,RecordTypeId=contactrt1.Id);
       insert Conts;
         Partner_Type__c progInfo = new Partner_Type__c(Program__c= 'Radio solutions',Account__c=Acts[0].id,Status__c= 'Active');
         insert progInfo;
         Technology_Specialization__c techRecord1= new Technology_Specialization__c(Technology_Specialization__c='Professional and Commercial Radio',Technology_Specialization_Status__c='Active',Partner_Program__c = progInfo.id, Technology_Specialization_Level__c= 'Specialist',Community_Type__c='Value Added Reseller',Type__c='Technology');
         techRecord1.Account__c=Acts[0].id;
         insert techRecord1;
         Technology_Specialization__c techRecord2= new Technology_Specialization__c(Technology_Specialization__c='Business Radio',Technology_Specialization_Status__c='Active',Partner_Program__c = progInfo.id, Technology_Specialization_Level__c= 'Elite Specialist',Community_Type__c='Value Added Reseller',Type__c='Technology');
         techRecord2.Account__c=Acts[1].id;
         insert techRecord2;
         List<Partner_location__c> partnerList= new List<Partner_location__c>();
        Partner_location__c partnerLoc = new Partner_location__c(State__c='IL',Country1__c='United States' );
        partnerLoc.Account__c= Acts[0].id;
        partnerLoc.City__c = 'Bengaluru';
        partnerLoc.Phone__c = '234234234';
        partnerLoc.Country1__c = 'dfdsfsdf';
        partnerLoc.State_Code__c = 'IL';
        partnerLoc.State__c = '42342';
        partnerLoc.Postal_code__c = '342424';
        partnerLoc.Address_Type__c ='Primary Location';
        //insert partnerLoc;
        partnerList.add(partnerLoc);
        Industry__c industry=new Industry__c(Account__c=Acts[0].id,Industry_Type__c='Manufacturing');
        insert industry;
        CAM_Geo_Map__c cam=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='DEFAULT OWNER NAMR',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert cam;
        LM_GeoCodeMaxLimit__c lmgcml = new LM_GeoCodeMaxLimit__c();     
        lmgcml.name = 'GeoCode Limit';
        lmgcml.LM_limit__c = 100;
        insert lmgcml;
        CAM_Geo_Map__c camUS=new CAM_Geo_Map__c(Status__c='New',Indirect_Channel_Account_Manager__c=owner.id,Channel_Account_Manager__c= owner.id,Country__c='United States',State_Province__c='IL',Region__c='NAMR',Track__c='Radio', Functions__c = 'Lead Mgt');
        insert camUS;
        RecordType leadrt1 = [Select id from RecordType where DeveloperName = 'Global_Lead_Record' and SobjectType ='Lead'];
        Lead leadRecord1 = new Lead(Partner_Account_NA__c=Acts[0].id,Partner_Assigned_Contact_NA__c=Conts[0].id,Region__c = 'NA',
                                    lastname='test lead',RecordTypeId = leadrt1.id,Track__c = 'Radio',
                                    Country= 'United states',state='Illinois',Company='Infosys',Industry='Manufacturing',
                                    Status='New',Technology_Segment__c='Professional and Commercial Radio',
                                    Latitude=42.070531300000000,Longitude=-88.050729800000000);
        insert leadRecord1;
        Lead_Survey__c[] newLeadSurveys = new Lead_Survey__c[2];
        newLeadSurveys[0]  = new Lead_Survey__c(Lead__c=leadRecord1.id, Contact__r=Conts[0], Created_On__c=datetime.now() );    
        newLeadSurveys[1]  = new Lead_Survey__c(Lead__c=leadRecord1.id, Contact__r=Conts[1], Created_On__c=datetime.now() );    

        insert newLeadSurveys; 
            LM_PartnerLocationDetailsInquiry  test = new LM_PartnerLocationDetailsInquiry();
            test.name ='test';
            test.partnerWebsite  ='http://google.co.in';
            test.partnerPhone  ='1258787';
            test.partnerCity  ='test city';
            test.partnerState  ='IL';
            test.partnerCountry  ='USA';
            test.zipCode ='545646';
            test.partnerAssignedContactName=Conts[0].id;
            test.locationList= partnerList;
            test.setLeadSurveyId(newLeadSurveys[0].id);
            test.getLeadSurveyId ();
            test.getDetails();
     }
     
     }