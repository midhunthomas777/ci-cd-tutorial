/*
* Description: Test class defined to run unit test on AccountsDetailController apex controller written on Account Object
*
*
*Author                 :   Niran N
*Date                   :   24-Sep-2017
*/


@isTest
private class CommunitiesWithoutSharingClassTest{
	@testSetup
	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
	}
         
    public static testMethod void CommunitiesWithoutSharingClassTest1() {
        /*List<AccountRecordTypeList__c> accCustSettings = new List<AccountRecordTypeList__c>();
        accCustSettings.add(new AccountRecordTypeList__c(Name='CustomerAccount', RecordTypeID__c = '012300000000OShAAM'));
        accCustSettings.add(new AccountRecordTypeList__c(Name='ProspectAccount', RecordTypeID__c = '012300000000OScAAM'));
        insert accCustSettings;
        
        List<OpportunityStagePicklistValues__c> stageCustomSettings = new List<OpportunityStagePicklistValues__c>();
        stageCustomSettings.add(new OpportunityStagePicklistValues__c(Name='SalesWayProcessStageValues', StageValuesForSalesWayProcess__c='Active, Won, Lost, NoPursuit'));
        stageCustomSettings.add(new OpportunityStagePicklistValues__c(Name='SalesWayProcessStageValuesDetail',StageValuesForSalesWayProcess__c='Prospect,Position & Align,Design & Validate,Secure,Execute & Expand'));
        insert stageCustomSettings;*/
        
        // define schema to get record types using map
        Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = accSchema.getRecordTypeInfosByName();
        
        List <Account> accList = new List<Account>();
        
        //creat partner account records
        Account accTest = new Account( Name='Test Account Partner',
            						  RecordTypeId = recordTypeMap.get('Partner').getRecordTypeId(),BillingStreet='12th Street',BillingCity='Bangalore',BillingCountry='India',BillingPostalCode='560100',
                                      Motorola_Customer_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100),Role_Created__c = true);
        insert accTest;
        accTest.IsPartner = true;
        update accTest;
        
        //creat customer account records
        Account accTestCust = new Account( Name='Test Account Customer',RecordTypeId = recordTypeMap.get('Customer').getRecordTypeId(),
                                          BillingStreet='12th Street',BillingCity='Schaumburg',BillingCountry='United States',BillingState = 'Illinois',
                                          BillingPostalCode='560100',Industry = 'Manufacturing',Territory__c = 'T2',Region__c  = 'NA', 
                                          Motorola_Customer_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100));
        insert accTestCust;
        
        Account accTestCust2 = new Account( Name='Test Account Customer2', RecordTypeId = recordTypeMap.get('Customer').getRecordTypeId(),
                                           BillingStreet='12th Street',BillingCity='Schaumburg', BillingCountry='United States', 
                                           BillingState = 'Illinois', BillingPostalCode='560100', Industry = 'Manufacturing',Territory__c = 'T2', 
                                           Region__c  = 'NA', Motorola_Customer_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100));
        insert accTestCust2;
        
        Account accTestMCN1 = new Account(Name='Test Account MCN1', RecordTypeId = recordTypeMap.get('Motorola Customer Number').getRecordTypeId(),
                                          ParentId = accTestCust.Id, Customer_or_Prospect_Account__c = accTestCust.Id);
        insert accTestMCN1;
       
        Schema.DescribeSObjectResult conSchema = Schema.SObjectType.Contact;
        Map <String,Schema.RecordTypeInfo> recordTypeMapCon = conSchema.getRecordTypeInfosByName();
        
        Contact partTestCont = new Contact(AccountId = accTest.Id,RecordtypeId = recordTypeMapCon.get('Partner').getRecordTypeId(),FirstName = 'Test',LastName = 'Partner Contact',FirstNameLocal = 'Test', LastNameLocal = 'Partner Contact');
        insert partTestCont;
        
        String nonPartnerUser = UserInfo.getUserId();
        
        //Account_Identifier__c AccountIdentifier = new Account_Identifier__c(Account__c=accTestMCN1.id,Address_Type__c='Headquarters',Assigned_Sales_Person__c = nonPartnerUser);
        //insert AccountIdentifier;
        
        Partner_Location__c partnerLocation1 = new Partner_Location__c(Account__c = accTest.id,Address_Type__c = 'Primary Location',Location_Publish_Flag__c = true);
        insert partnerLocation1 ;
        
        Partner_Profiles__c PartnerProfile = new Partner_Profiles__c (Account__c = accTest.id,Company_Owned_Type__c='Privately Held' );
        insert PartnerProfile ;

        //Lead ld = new Lead(LastName='Test Lead Name', Region__c ='NA', Email='abc@org.com', Phone='1234567890', Company='Test Company',status='inquiry',Country='United States', State='Kentucky', City='Test City', Lead_Type__c='MR');
        //insert ld;

        Test.startTest(); 
        //Lead testLead = [SELECT Id FROM Lead WHERE LastName = : 'Test Lead Name'];
        //CommunitiesWithoutSharingClass.getLeadDetail(testLead.id);
        
        Account testCustomerAcc = [SELECT Id FROM Account WHERE Name =: 'Test Account Customer'];
        CommunitiesWithoutSharingClass.getAccountDetail(testCustomerAcc.Id);
        
       //Account testCustomerMCN1 = [SELECT Id FROM Account WHERE Name =: 'Test Account MCN1'];  
        //Account_Identifier__c testAccountIdentifier = [SELECT id from Account_Identifier__c WHERE Account__c=:accTestMCN1.Id];
        CommunitiesWithoutSharingClass.getAccountIdentifierDetail(testCustomerAcc.id);
        
        Partner_Location__c testpartnerloc = [SELECT Id FROM Partner_Location__c LIMIT 1];
        Account testpartnerAcc = [SELECT Id FROM Account WHERE Name =: 'Test Account Partner'];  
        CommunitiesWithoutSharingClass.getPartnerLocationDetail(testpartnerloc.id);    
        
        Partner_Profiles__c testPartnerProfile = [SELECT Id from Partner_Profiles__c where Account__c =: testpartnerAcc.Id];
        CommunitiesWithoutSharingClass.getPartnerProfileDetail(testPartnerProfile.id);
           
        Contact testContact = [SELECT Id from Contact where FirstName = 'Test' and AccountId =: testpartnerAcc.Id];
        CommunitiesWithoutSharingClass.fetchContact(testContact.Id);
        
        //Lead testLead = [SELECT id from Lead];
        //CommunitiesWithoutSharingClass.getLeadDetail(testLead.id);
        try{
        Id leadRecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        Lead l = new Lead(LastName='Test Name',Track__c='Radio', Region__c ='NA', Email='abc@org.com', Phone='1234567890', Company='Test Company',status='Marketing Lead',Country='India', City='Test City', Lead_Type__c='MR', RecordTypeId = leadRecordTypeID);
        insert l;
        CommunitiesWithoutSharingClass.getLeadDetail(l.id);
        } catch(Exception exp){}
        Test.stopTest();
         
        }
        
}