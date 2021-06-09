@istest
private class KeyWordSearch1Test {
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

static testMethod void classTest(){  
   
                  
    Account ac1 = new Account(Name='Testing KeyWord',Type = 'Prospect', Company_Description__c = 'Testing Description', DBA_Trading_Name__c = 'Hi', Services_Provided__c = 'Testing SP', Value_Add__c = 'Testing Value add',BillingCountry='India',Billingcity='Test');    
    Account ac2 = new Account(Name='Testing KeyWord1',Type = 'Prospect',BillingCountry='India',Billingcity='Test');    
    Account ac3 = new Account(Name='Testing KeyWord2',Type = 'Prospect',BillingCountry='India',Billingcity='Test');    
    Account ac4 = new Account(Name='Testing KeyWord3',Type = 'Prospect',BillingCountry='India',Billingcity='Test');    
    List<Account> accList = new List<Account>();
    accList.add(ac1);
    accList.add(ac2);
    accList.add(ac3);
    accList.add(ac4);
    
    insert accList;   

    
    Product_offered__c poc1 = new Product_offered__c(Account__c = ac1.Id, Product_offering__c = 'SCADA');
 
        
    Partner_location__c plc1 = new Partner_location__c(Account__c = ac1.Id, Postal_code__c = '570036',Country1__c= 'India', State__c = 'Karnataka', city__c = 'Bangalore' );
    Partner_location__c plc2 = new Partner_location__c(Account__c = ac2.Id, State__c = 'Karnataka');
    Partner_location__c plc3 = new Partner_location__c(Account__c = ac3.Id, Postal_code__c = '570036');
    Partner_location__c plc4 = new Partner_location__c(Account__c = ac4.Id, Country1__c= 'India');
    List<Partner_location__c> partLocList= new List<Partner_location__c>();
    partLocList.add(plc1);
    partLocList.add(plc2);
    partLocList.add(plc3);
    partLocList.add(plc4);
    
    
    Industry__c ic1 = new Industry__c(Account__c = ac1.Id, Industry_Type__c = 'Transportation & Logistics',Publish_Flag__c=true);
    Partner_Type__c ptc1 = new Partner_Type__c(Account__c = ac1.Id, Partner_Level__c = '10-Premier Solution Partner',Status__c='Active');
    //Commented as part of SF-491-Delete unused objects
    //Validated_Solution__c vsc1 = new Validated_Solution__c(Account__c = ac1.Id, Solution__c = 'Enterprise Mobility Compatible',Publish_Flag__c=true);
    Partner_Certification__c pcc1 = new Partner_Certification__c(Account__c = ac1.Id, Certificate_Name__c = 'Testing Partner',Publish_Flag__c=true);
    
    insert poc1;
    insert partLocList;
    insert ic1;
    insert ptc1;
    //Commented as part of SF-491-Delete unused objects
    //insert vsc1;
    insert pcc1;
    
    KeyWordSearch1 b = new KeyWordSearch1(); 
    b.query = 'select Id,Name,Company_Description__c,Value_add__c,DBA_Trading_Name__c,Services_Provided__c,(select Id,Product_offering__c from Account.Product_offered__r),(select City__c,Postal_code__c,Country1__c,Id,State__c from Account.Partner_locations__r),(select Id,Industry_Type__c from Account.Industries__r where Publish_Flag__c=true),(select Partner_Level__c,Status__c from Partner_Types__r),(select Certificate_Name__c from Partner_Certifications__r where Publish_Flag__c=true) from Account where Name=\'Testing KeyWord\' or Name=\'Testing KeyWord1\' or Name=\'Testing KeyWord2\' or Name=\'Testing KeyWord3\''; 
    test.startTest();    
    database.executebatch(b);    
    test.stopTest();
    }

}