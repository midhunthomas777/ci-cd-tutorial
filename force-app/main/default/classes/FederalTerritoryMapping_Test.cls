/*
Name:  FederalTerritoryMapping_Test
Purpose: Test class for FederalTerritoryMapping

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
1.0 -     Satish Maddhi      28 April 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
@isTest
public class FederalTerritoryMapping_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testmethod void test_FederalTerritoryMapping() {
        FederalTerritoryMapping ctrl = new FederalTerritoryMapping();
        FederalTerritoryMapping.getTerritoryDivision('DOD-East','Department of State (DOS)');
        FederalTerritoryMapping.getTerritoryDivision('DOD-East','');
        FederalTerritoryMapping.getTerritoryDivision('Civil','US Postal Service (USPS)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Department of Energy (DOE)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Veterans Affairs Medical Center (VAMC)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','National Aeronautics and Space Administration (NASA)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Federal Protective Service (FPS)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Immigration and Customs Enforcement (ICE)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','All Other Civil');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Federal Aviation Agency (FAA)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Federal Emergecy Management Agency (FEMA)');
        FederalTerritoryMapping.getTerritoryDivision('Civil','Department of Interior (DOI)');
        
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','US Coast Guards (USCG)');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','Customs and Border Protection (CBP)');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','Federal Bureau of Prisons (FBOP)');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','Federal Bureau of Investigation (FBI)');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','Drug Enforcement Administration (DEA)');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','All Other DHS');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','All Other DOJ');
        FederalTerritoryMapping.getTerritoryDivision('Civil LEA','US Secret Service (USSS)');
               
    }
    static testmethod void test_CommMktOpp() {
        Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = stdPricebookId.Id;
        opp.Name='test opp';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';  
        opp.RecordtypeId=OppectypeID;
        opp.Region__c = 'NA'; 
        opp.Territory__c='Comm Mkts'; 
        opp.Country__c = 'United States'; 
        opp.State__c = 'Illinois';            
        insert opp;
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
    }
    static testmethod void test_NAT2Opp() {
        Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = stdPricebookId.Id;
        opp.Name='test opp';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';  
        opp.RecordtypeId=OppectypeID;
        opp.Region__c = 'NA'; 
        opp.Territory__c='T2'; 
        opp.Country__c = 'United States'; 
        opp.State__c = 'Illinois';            
        insert opp;
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
    }
    static testmethod void test_APOpp() {
        Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = stdPricebookId.Id;
        opp.Name='test opp';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';  
        opp.RecordtypeId=OppectypeID;
        opp.Region__c = 'AP'; 
        opp.Territory__c='AP'; 
        opp.Country__c = 'Australia'; 
        opp.State__c = 'VICTORIA';            
        insert opp;
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
    }
    static testmethod void test_LAOpp() {
        Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = stdPricebookId.Id;
        opp.Name='test opp';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';  
        opp.RecordtypeId=OppectypeID;
        opp.Region__c = 'LA'; 
        opp.Territory__c='Brazil'; 
        opp.Country__c = 'Brazil';                
        insert opp;
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
    }
    static testmethod void test_NAChannelOpp() {
        Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Pricebook2 stdPricebookId=TestDataSetUpUtils.createPriceBook3();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity opp = new Opportunity(); 
        opp.Pricebook2Id = stdPricebookId.Id;
        opp.Name='test opp';
        opp.AccountId=lstAccount.get(0).Id; 
        opp.CloseDate = Date.today()+30;
        opp.StageName='Design & Validate';  
        opp.RecordtypeId=OppectypeID;
        opp.Region__c = 'NA'; 
        opp.Territory__c='CT2'; 
        opp.Country__c = 'United States'; 
        opp.State__c = 'Arizona';            
        insert opp;
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
    }
}