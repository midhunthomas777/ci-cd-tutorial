@isTest
private class InsertCDHAccountAccID_Test {
	@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
    static testMethod void InsertCDHAccountAccID_Test() {
    
   /* DataActivity__c Temps1 = new DataActivity__c (Name='DeactivateMain',DeactivateTrigger__c=false);
    insert Temps1;
    
     DataActivity__c Temps2 = new DataActivity__c (Name='DeactivateTrigger',DeactivateTrigger__c=false);
    insert Temps2;*/
    
    SicCodeMapping__c TempS3 =new SicCodeMapping__c(Name='0111',Current_Segment__c='Construction',Industry__c='Manufacturing',SicCode__c='0111');
    Insert TempS3;
     Id CustomerId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
     Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
     Id CDHId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
    Account Acc = new Account(Name='TestVAccount', RecordTypeId=prospectId,billingcountry='India',BILLINGCITY='Hyderabad',BillingPostalCode='1234',Sic='0111',shippingcountry='India',shippingpostalcode='522002');
    Insert Acc;
    Account Acc1 = new Account(Name='Test123VAccount', RecordTypeId=CDHId,Customer_or_Prospect_Account__C=Acc.Id);
    Insert Acc1;
    Acc1.Name='UpdatedAcc';
    Update Acc1;
    System.debug('Account Created' + Acc);
                Test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com',core_id__c='test456');
            insert usr ;
            System.runAs(usr)
            {
                Acc.ownerId = usr.id;
                update Acc;
                
                Acc1.ownerId = usr.id;
                update Acc1;
            }
        Test.stopTest();    
    }
    
    
    static testMethod void InsertCDHAccountAccID_Test2() {
    
   /* DataActivity__c Temps1 = new DataActivity__c (Name='DeactivateMain',DeactivateTrigger__c=false);
    insert Temps1;
    
     DataActivity__c Temps2 = new DataActivity__c (Name='DeactivateTrigger',DeactivateTrigger__c=True);
    insert Temps2;
    
    SicCodeMapping__c TempS3 =new SicCodeMapping__c(Name='0111',Current_Segment__c='Agriculture and Forestry',Industry__c='Natural Resources',Industry_Description__c='Wheat farm',SicCode__c='0111');
    Insert TempS3;*/
    
    Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
     Id CUSID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
          Id CDHID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
               Id PartnerId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
                              Id PartConId =Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

    
    Account  Acts1 = new Account(Name='Test Systems Inc.',RecordTypeId=CUSID, BillingCountry='India',BillingPostalCode='123', BILLINGCITY='Hyderabad',Status__c='Active',Motorola_Customer_Number__c='TEST1234');
    Insert Acts1;
System.Debug('Customer ACCOUNT Acts1 Id**'+Acts1.Id);    
    Account Acts2 = new Account(Name='Abc Abc',Status__c='Active',Customer_or_Prospect_Account__c=acts1.id,BillingCountry='India',BillingPostalCode='123',recordtypeid=CDHID);
    insert Acts2;
    System.Debug('CDH ACCOUNT Acts2 Id**'+Acts2.Id);
    Account Acts3 = new Account(Name='Abc Abc1',Status__c='Active',Customer_or_Prospect_Account__c=acts1.id,BillingCountry='India',BillingPostalCode='123',recordtypeid=CDHID);
    Insert Acts3;
System.Debug('CDH ACCOUNT Acts3 Id**'+Acts3.Id);
    
    
    Account Acc1 = new Account(Name='TestVAccount12', RecordTypeId=PartnerId,BillingCountry='United States',BillingPostalCode='1234');
    Insert Acc1;  
    Contact C1 = new contact(FirstName='First',LastName='Last',Accountid=Acc1.id,recordtypeId=PartConId);
    Insert C1;
 
     
    
    Profile TempPro = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile NAMR']; 
    
            User Tempusr = new User(Alias = 'standt', Email='standarduserttt@testorg.com', 
                        EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = TempPro.Id, contactid=C1.id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='sssstandarduser@testorg.com');
            insert Tempusr ;
    
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='tttstandarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='ssss1tandarduser@testorg.com',core_id__c='test1234');
        insert usr ;
        System.runAs(usr)
        {
            Acts1.ownerId = usr.id;
            update Acts1;
            
            Acts2.ownerId = usr.id;
            update Acts2;
        }
        Test.stopTest();
    }
}