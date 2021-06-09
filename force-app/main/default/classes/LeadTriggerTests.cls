@isTest
public class LeadTriggerTests {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    public static testMethod void testRunner(){
        //Added by harish
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        String RTStr=rt.Id;
        
        List<Account> twoAccounts = new List<Account>();
        Account acc1 = new Account(Name='testAccount1',Type='Partner',RECORDTYPEID=RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC'
                                  );
        twoAccounts.add(acc1);
        Account acc2 = new Account(Name='testAccount2',Type='Partner',RECORDTYPEID
                                   =RTStr,BILLINGSTREET='24-60 20 CALLE',BillingCity='GUATEMALA',
                                   BILLINGSTATE='Alaska',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States',
                                   INDUSTRY='Professional Services',
                                   LEVEL__C='Authorized Reseller',
                                   Metal_Level__c='test',
                                   Partner_Region__c='APAC'
                                  );  
        twoAccounts.add(acc2);
        insert twoAccounts;
        String LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Global Lead Record').getRecordTypeId();
        Lead myLead = new Lead(lastname = 'Fry', 
                               company='Fry And Sons', 
                               Channel_Partner__c=twoAccounts[0].Id, 
                               Distributor__c=twoAccounts[1].Id,
                               Lead_Value__c = 12345.00,
                               //Status = '😊 Qualified 😊',
                               Status = 'Qualified',
                               Region__c = 'NA',
                               Technology_Segment__c = 'ASTRO Devices',
                               Country = 'United States',
                               Email = 'abc@org.com',
                               Lead_Type__c = 'MR',
                               RecordTypeId = LeadRecordTypeId,
                               Industry='Healthcare',
                               State='illinois',
                               Close_Date__c = Date.today()+10,
                               Territory__c = 'T2'
                              );
        insert myLead;
        
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(myLead.id);
        lc.setDoNotCreateOpportunity(false);
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
    }
    
        
}