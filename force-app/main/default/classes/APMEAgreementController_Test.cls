@isTest
/*  
* File Name  : APMEAgreementController_Test
* Description: This class is to unit test the updateFinanceAndContractsLegal trigger on PreSale Resource Request.    
* Author     : Vivekh R  
* Modification Log 
* ============================================================================= 
* Ver   Date           Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   06/11/2014     Vivekh R                       Initial Code
*/


private class APMEAgreementController_Test{    
    static TestMethod void testInsertAPMEAgreement(){
        TestDataSetUpUtils.insertCustomSettings();
        
        // Create an Account
        Account a = new Account();
        RecordType rect=[Select r.Id From RecordType r where r.SobjectType='Account' and r.developername='Prospect'];
        a.RecordTypeId = rect.id;
        a.Name = 'Test Account';
        a.Billingcountry='United States';
        a.Billingstate= 'Illinois';
        a.BillingCity = 'Chicago';
        a.Type = 'Prospect';
        a.Industry = 'Education';
        a.Region__c = 'NA';
        a.Territory__c = 'T1';
        a.Country_Listing__c = 'Venezuela';
        Test.startTest();
        insert a;
        
        //Create account for custom settings
        Account acc = new Account();
        RecordType rect1=[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Competitor'];
        acc.RecordTypeId = rect1.id;
        acc.Name = 'Motorola Solutions, Inc.';
        acc.Type = 'Motorola Entity';
        acc.Is_Active__c=true;
        insert acc;
        
        // Create a Custom settings
        Agreement__c setting = new Agreement__c();
        setting.Name='Egypt01';
        setting.Billing_Country__c='Egypt';
        setting.Sub_Region__c='Mele';
        setting.Motorola_Entity_ID__c=acc.id;
        insert setting;
        
        //Create a Project
        Project__c p = new Project__c();
        p.Account__c = a.id;
        p.Project_Name__c = 'Test Project';
        p.Project_Award_Date__c = date.today();
        insert p;    
        
        //Create an Opportunity
        
        Opportunity opp = new Opportunity();
        //RecordType theRecordType4 = [Select Id from RecordType where name='EMEA Government Channel Project' and SobjectType='Opportunity' limit 1];
        //added the recordtype developer due to the change in cr---SHANTHI
        RecordType theRecordType4 = [Select Id from RecordType where developerName='Government_Standard' and SobjectType='Opportunity' limit 1];
        
        opp.RecordTypeId = theRecordType4.id;       
        opp.AccountId = a.id;
        opp.Name = 'Test Opportunity';
        opp.Award_Date__c = system.today();
        
        
        opp.Project_Awards__c = p.id;
        opp.Primary_Competitor_Account__c = acc.id;
        opp.Project_Name__c = 'Test APME Agreement Opportunity linkage Project';
        opp.StageName = 'No Pursuit';
        opp.Opportunity_Forecast__c = 'Upside';
        opp.Status__c ='Active';
        opp.Reason_for_Win_or_Loss__c='SSO not prioritized within MSI';
        opp.CloseDate = date.today();
        opp.Industry__c = 'Public Services (non-Public Safety Government)'; 
        opp.Primary_Technology__c = 'ASTRO';
        opp.Business_Group__c = 'Channel Project';
        opp.CurrencyIsoCode = 'USD';
        //opp.End_User_Segment__c = 'Government Transportation';
        opp.Probability = 40;
        opp.Type = 'Standard';
        
        opp.UN_Theatre__c = 'APAC';
        opp.Service_Attached__c = 'Yes';
        insert opp;
        Test.stopTest();
        List<Opportunity> oppList = [SELECT Account.Id,RecordType.Name,Account.Name,Name,Total_Order_Value_Inc_Service__c,
                                     SYM_Transaction_Number__c,Owner.Area_Controller__c,Owner.Name,
                                     Project_Awards__c,mh_Associated_Blue_Sheet__c,Status__c,Industry__c,Primary_Technology__c
                                     FROM Opportunity Where Id =:opp.id];
        system.debug('inserted oppty name is '+ oppList[0].Name);           
        PageReference eacPage = Page.PDFdocEA;      
        Test.setCurrentPage(eacPage);           
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oppList[0]);
        APMEAgreementController eac = new APMEAgreementController(sc);
        
        
        //integer value = APMEAgreementController.profileCheck();                
        eac.insertAgreement();
        
    } 
}