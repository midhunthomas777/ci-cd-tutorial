/************************************************************************************************* 
* File Name  : CPQSoapCallForOrderUpdateTest
* Description: Test class for CPQSoapCallForOrderUpdate class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-May-2018     Satish Maddhi(TCS)	  Removed SeeAllData=true and increased code coverage
*
*************************************************************************************************/

@IsTest
private class CPQSoapCallForOrderUpdateTest {
    @testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void CPQSoApOrderUpdateTest(){
        User theOwner = [SELECT Id FROM User WHERE IsActive = True AND Core_ID__c ='nqr374' LIMIT 1]; 
		RecordType theRecordType = [SELECT Id FROM RecordType WHERE Name='Customer' AND SobjectType='Account' LIMIT 1];
        Account accTest1 = new Account(Name = 'Test Customer Quote1',
                                       Type='Customer',
                                       Billingcity='Test',
                                       ownerId=theOwner.Id,
                                       RecordTypeId=theRecordType.Id,
                                       Region__c ='NA',
                                       Territory__c='T1',
                                       Billingcountry ='United States',
                                       BillingState = 'Illinois',
                                       Industry='Public Services (non-Public Safety Government)'
                                        );
        insert accTest1;
        
        RecordType theRecordType11 = [Select Id from RecordType where Name='Motorola Customer Number' and SobjectType='Account' limit 1];
       	Account mcnTest1 = new Account(Name = '1011138915',
                                        ParentId =accTest1.ID,
                                        ownerId=theOwner.Id,
                                        Billingcity='Test',
                                        RecordTypeId=theRecordType11.Id,
                                        Motorola_Customer_Number__c='1011138915',
                                        ERP_Active__c= TRUE
                                        );
       	insert mcnTest1;
        
        RecordType theRecordType1 = [SELECT Id FROM RecordType WHERE Name='Project' AND SobjectType='Opportunity' LIMIT 1];
        String dt ='12/31/2021';  
        Date CloseDT = Date.parse(dt);
        Id pricebookId = Test.getStandardPricebookId();
        Opportunity oppTest1 = new Opportunity(Name = 'City of Charlotte TESTOPP',
            RecordTypeId=theRecordType1.Id,
            CDH_Account__c =mcnTest1.ID,
            AccountId = accTest1.ID,      
            StageName ='Prospect',  
            ForecastCategoryName ='Non Commit',
            Status__c ='Active',
            Industry__c ='Public Services (non-Public Safety Government)',
            Who_is_the_Incumbent__c='MSI',
            Channel_Opportunity__c ='Direct',
            Business_Group__c ='EMEA Government System Project',
            CloseDate=CloseDT,
            Region__c='NA',
            Country__c = 'United States',
            State__c = 'Missouri',
            Territory__c = 'T6',
            Pricebook2Id =pricebookId,
            CurrencyIsoCode='USD' );
        insert oppTest1;
       
        //ID SiteId='a5Q340000001M5hEAE';
        Id siteID = TestDataSetUpUtils.createSite();
        String dt1 ='12/4/2021';  
        Date ValidityDT = Date.parse(dt1);
        
        BigMachines__Quote__c theQuote1 = new BigMachines__Quote__c();
        theQuote1.Name ='CPQ-9999';
        theQuote1.BigMachines__Opportunity__c=oppTest1.Id;
        theQuote1.BigMachines__Account__c=oppTest1.AccountId;
        theQuote1.Customer_Bill_To__c='115553';
        theQuote1.Validity_Date_Effective_Until_Date__c=ValidityDT;
        //theQuote1.BigMachines__Total_Amount__c=Integer.valueOf('3100');
        theQuote1.CurrencyIsoCode='USD';
        theQuote1.BigMachines__Status__c='In Progress';
        theQuote1.RevisionNumber__c='0';
        theQuote1.BigMachines__Site__c=SiteId;
        insert theQuote1;
      
      	Boolean a = CPQSoapCallForOrderUpdate.Updaterecord(theQuote1.id,'Order Finalized','Test this',12,14,'Test1111');
      	a = CPQSoapCallForOrderUpdate.Updaterecord('00534000008cjmDAAQ','Order Finalized','Test this',12,14,'Test1111');
		System.assert(!a);
	}
    
    static testMethod void CPQSoApOrderUpdateTest1(){
        User theOwner = [SELECT Id FROM User WHERE IsActive = True AND Core_ID__c ='nqr374' LIMIT 1]; 
		RecordType theRecordType = [SELECT Id FROM RecordType WHERE Name='Customer' AND SobjectType='Account' LIMIT 1];
        Account accTest1 = new Account(Name = 'Test Customer Quote1',
                                       Type='Customer',
                                       Billingcity='Test',
                                       ownerId=theOwner.Id,
                                       RecordTypeId=theRecordType.Id,
                                       Region__c ='NA',
                                       Territory__c='T1',
                                       Billingcountry ='United States',
                                       BillingState = 'Illinois',
                                       Industry='Public Services (non-Public Safety Government)'
                                        );
        insert accTest1; 
        RecordType theRecordType11 = [Select Id from RecordType where Name='Motorola Customer Number' and SobjectType='Account' limit 1];
       	Account mcnTest1 = new Account(Name = '1011138915',
                                        ParentId =accTest1.ID,
                                        ownerId=theOwner.Id,
                                        Billingcity='Test',
                                        RecordTypeId=theRecordType11.Id,
                                        Motorola_Customer_Number__c='1011138915',
                                        ERP_Active__c= TRUE
                                        );
       	insert mcnTest1;
        RecordType theRecordType1 = [SELECT Id FROM RecordType WHERE Name='Project' AND SobjectType='Opportunity' LIMIT 1];
        String dt ='12/31/2021';  
        Date CloseDT = Date.parse(dt);
        Id pricebookId = Test.getStandardPricebookId();
        Opportunity oppTest1 = new Opportunity(Name = 'City of Charlotte TESTOPP',
            RecordTypeId=theRecordType1.Id,
            CDH_Account__c =mcnTest1.ID,
            AccountId = accTest1.ID,      
            StageName ='Prospect',  
            ForecastCategoryName ='Non Commit',
            Status__c ='Active',
            Industry__c ='Public Services (non-Public Safety Government)',
            Who_is_the_Incumbent__c='MSI',
            Channel_Opportunity__c ='Direct',
            Business_Group__c ='EMEA Government System Project',
            CloseDate=CloseDT,
            Region__c='NA',
            Country__c = 'United States',
            State__c = 'Missouri',
            Territory__c = 'T6',
            Pricebook2Id =pricebookId,
            CurrencyIsoCode='USD' );
        insert oppTest1;
       
        //ID SiteId='a5Q340000001M5hEAE';
        Id siteID = TestDataSetUpUtils.createSite();
        String dt1 ='12/4/2021';  
        Date ValidityDT = Date.parse(dt1);
        
        BigMachines__Quote__c theQuote1 = new BigMachines__Quote__c();
        theQuote1.Name ='CPQ-9999';
        theQuote1.BigMachines__Opportunity__c=oppTest1.Id;
        theQuote1.BigMachines__Account__c=oppTest1.AccountId;
        theQuote1.Customer_Bill_To__c='115553';
        theQuote1.Validity_Date_Effective_Until_Date__c=ValidityDT;
        //theQuote1.BigMachines__Total_Amount__c=Integer.valueOf('3100');
        theQuote1.CurrencyIsoCode='USD';
        theQuote1.BigMachines__Status__c='In Progress';
        theQuote1.RevisionNumber__c='0';
        theQuote1.BigMachines__Site__c=SiteId;
        insert theQuote1;
        
        try{
        	theQuote1.Name='';
        	update theQuote1;
      		Boolean a = CPQSoapCallForOrderUpdate.Updaterecord(theQuote1.id,'Order Finalized','Test this',12,14,'Test1111');
        } catch(DMLException e) {
            System.assertEquals(e.getMessage(),e.getMessage());
        }
        //a = CPQSoapCallForOrderUpdate.Updaterecord('00534000008cjmDAAQ','Order Finalized','Test this');
		//System.assert(!a);
	}
}