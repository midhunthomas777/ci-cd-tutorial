@isTest
public class AddMRDisputePermissionset_Test{
	
    //Method added by Satish to fix test class failures (SF-131)
 	@testSetup
	static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
 public static testMethod void MRMethod1()
 {
 Id PartnerId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
 Id PartnerConId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
 
 Account Acc1 = new Account(Name='TestVAccount12', RecordTypeId=PartnerId,Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123',Partner_Region__c='NAMR',MPE_Program_Status_New__c='Active');
 Insert Acc1;  
 
 Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,recordtypeId=PartnerConId);
 Insert C1;
 

 Profile p = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile NAMR']; 
 
 User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                        EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, contactid=C1.id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com');
  Insert usr;
 
 
 Partner_Type__c PTC=new Partner_Type__c(Account__c=Acc1.Id,Program__c='Radio Solutions',Status__c='Active');
 Insert PTC;
 
 Technology_Specialization__c TSC=new Technology_Specialization__c(Partner_Program__c=PTC.Id,Account__c=Acc1.Id,Community_Type__c='Federal Manufacturer Representative',Technology_Specialization__c ='Mission Critical Radio Systems',Technology_Specialization_Status__c='Active',Technology_Specialization_Level__c='Authorized');
 Insert TSC;
  
 }
 
 public static testMethod void MRMethod2()
 {
 Id PartnerId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
 Id PartnerConId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
 
 Account Acc1 = new Account(Name='TestVAccount12', RecordTypeId=PartnerId,Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123',Partner_Region__c='NAMR',MPE_Program_Status_New__c='Active');
 Insert Acc1;  
 
 Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,recordtypeId=PartnerConId);
 Insert C1;
 

 Profile p = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile NAMR']; 
 
 User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                        EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, contactid=C1.id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com');
  Insert usr;
 
 
 Partner_Type__c PTC=new Partner_Type__c(Account__c=Acc1.Id,Program__c='Radio Solutions',Status__c='Active');
 Insert PTC;
 
 Technology_Specialization__c TSC=new Technology_Specialization__c(Partner_Program__c=PTC.Id,Account__c=Acc1.Id,Community_Type__c='Federal Manufacturer Representative',Technology_Specialization__c ='Mission Critical Radio Systems',Technology_Specialization_Status__c='Inactive',Technology_Specialization_Level__c='Open');
 Insert TSC;
 TSC.Technology_Specialization_Level__c='Authorized';
 TSC.Technology_Specialization_Status__c='Active';
 update TSC;
 }
 
 
 
}