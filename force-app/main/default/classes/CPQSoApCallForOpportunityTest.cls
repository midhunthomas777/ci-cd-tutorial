@IsTest
private class CPQSoApCallForOpportunityTest {
   @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
 
  static testMethod void testMyWebSvc()
  {
      
       //Inset Product1
       Product2 theprod = new Product2(Name = 'ASTRO Devices1');
       insert theprod;
 
       //Inset Product2
       Product2 theprod1 = new Product2(Name = 'Si Series BodyWorn Video Speaker Mic');
       insert theprod1;

       Id pricebookId = Test.getStandardPricebookId();        
       system.debug(logginglevel.WARN,'PricebookID - ' + pricebookId );
       
       //PricebookEntry for AstroDevice1 StandardPricebook 
       PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = theprod.Id, CurrencyIsoCode='USD', UnitPrice = 0, IsActive = true);
       insert standardPrice;
       
       //PricebookEntry for Si Series BodyWorn Video Speaker Mic StandardPricebook
       PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = theprod1.Id, CurrencyIsoCode='USD', UnitPrice = 0, IsActive = true);
       insert standardPrice1;
        
       /* 
       //Insert Custom Pricebook
       Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
       insert customPB;
       
       //Insert Custom PriceBookEntry
       PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
       insert customPrice;*/
       
       //Insert Account
       User theOwner = [Select Id From User where IsActive = True and Core_ID__c ='nqr374' limit 1];           
       RecordType theRecordType = [Select Id from RecordType where Name='Customer' and SobjectType='Account' limit 1];
       Account accTest1 =new Account(Name = 'Test Customer Quote1',
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
       System.debug('Account - ' + accTest1.Id);
       
       //Insert MCN
       RecordType theRecordType11 = [Select Id from RecordType where Name='Motorola Customer Number' and SobjectType='Account' limit 1];
       Account mcnTest1 = new Account(Name = '1011138915',
                                        ParentId =accTest1.ID,
                                        ownerId=theOwner.Id,
                                        Billingcity='Test',
                                        RecordTypeId=theRecordType11.Id,
                                        Motorola_Customer_Number__c='1011138915',
                                        ERP_Active__c = TRUE
                                        //Territory__c = 'T2'
                                        );
       insert mcnTest1;
       System.debug('MCN' + mcnTest1.Id);
       
       //Insert Opportunity
       String dt ='12/31/2016';  
       date CloseDT=date.parse(dt);  
       RecordType theRecordType1 = [Select Id from RecordType where Name='Project' and SobjectType='Opportunity' limit 1];     
         
       Opportunity oppTest1 = new Opportunity(Name = 'City of Charlotte TESTOPP',
       RecordTypeId=theRecordType1.Id,
       CDH_Account__c =mcnTest1.ID ,
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
       System.debug('OPP_ID - ' + oppTest1.Id);
                          
       //Insert Forecasting Product Family1
       Forecasting_Product_Family__c theFPF = new Forecasting_Product_Family__c();
       theFPF.Name='ASTRO Devices1';
       theFPF.Forecast_Rollup_WWAPC_Code__c='5699';
       theFPF.Product_Family__c=theProd.ID;
       
       insert theFPF;     
       System.debug('FPG - ' + theFPF.Product_Family__c);
       
       //Insert Forecasting Product Family2
       Forecasting_Product_Family__c theFPF2 = new Forecasting_Product_Family__c();
       theFPF2.Name='Accessories & Energy';
       theFPF2.APC__c='372A';
       theFPF2.Product_Family__c=theProd1.ID;
       
       insert theFPF2;      
       
       //Insert Forecasting Product Family3
       Forecasting_Product_Family__c theFPF3 = new Forecasting_Product_Family__c();
       theFPF3.Name='N/A';
       theFPF3.Forecast_Rollup_WWAPC_Code__c='0007';
              
       insert theFPF3;      
       
       //Insert Quote
       //Test Sandbox UAT
       //ID SiteId='a6Z1b000000CbT2EAK';
       //Production
       //ID SiteId='a5Q340000001M5hEAE';
       Id siteID = TestDataSetUpUtils.createSite();
       String dt1 ='12/4/2016';  
       date ValidityDT=date.parse(dt1);  
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
       theQuote1.BigMachines__Site__c='a6Z1b000000CbT2EAK';
       theQuote1.BigMachines__Site__c=SiteId;
 
       insert theQuote1;
       
       //Insert Quote Product1
       BigMachines__Quote_Product__c    theQP1 = new BigMachines__Quote_Product__c();
       theQP1.Name ='H84WCF9PW6AN';
       theQP1.BigMachines__Quote__c=theQuote1.id;
       theQP1.BigMachines__Description__c='APX 1000 900MHZ MODEL 2';
       theQP1.Line_number__c='1';
       theQP1.APC__c='0837';
       theQP1.WWAPC__c='5699';
       theQP1.Payment_term__c='30 NET';
       //theQP1.BigMachines__Total_Price__c=Integer.valueOf('3100');
       theQP1.CurrencyIsoCode='USD';
       theQP1.BigMachines__Sales_Price__c=Integer.valueOf('1550');
       theQP1.BigMachines__Quantity__c=Integer.valueOf('1');
    
       
       insert theQP1;
       
       test.startTest();
       Boolean act =   CPQSoApCallForOpportunity.GetrecordAccess('Anitha',theQuote1.Id);
       if(act)
        system.assert(act == TRUE);
       else
        system.assert(act == FALSE);
          
       System.debug('Anitha - ' + act );
       act =   CPQSoApCallForOpportunity.GetrecordAccess('nqr374',theQuote1.Id);
       //'a6fe00000000IM4AAM'
       if(act)
        system.assert(act == TRUE);
       else
        system.assert(act == FALSE);
        
       System.debug('nqr374- ' + act );
       test.stopTest();
  }
}