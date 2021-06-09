/****************************************************************************************************************  
* File Name  : EAAgreementController_Test
* Description: This class is to unit test the updateFinanceAndContractsLegal trigger on PreSale Resource Request.    
* Author     : Anupama Ajith  
* Modification Log 
* ============================================================================= 
* Ver   Date        	   Author                         Modification 
* ----------------------------------------------------------------------------------------------------------------
* 1.0   08/16/2013   	Anupama Ajith              		   Initial Code
* 2.0   09 April 2018   Satish Maddhi(TCS)			Removed SeeAllData = true and increased code coverage
*****************************************************************************************************************/
@isTest       
    private class EAAgreementController_Test {
        @testSetup
        static void testSetUp() {
            TestDataSetUpUtils.insertCustomSettings();
        }
    	static TestMethod void testInsertEAAgreement() {
            //Create an Account
            Account a = new Account();
                RecordType rect=[Select r.Id From RecordType r where r.SobjectType='Account' and r.developername='Prospect'];
                a.RecordTypeId = rect.id;
                a.Name = 'Test Account';
                a.Type = 'Prospect';
                a.Industry = 'Education';
                a.Region__c = 'NA';
                a.Territory__c = 'T1';
                //a.Country_Listing__c = 'Venezuela';
                a.BillingCountry = 'United States';
                a.Billingstate = 'Texas';
                a.Billingcity = 'San Mateo';
            Test.startTest();
            insert a;
           
            //Create a Project
            Project__c p = new Project__c();
                p.Account__c = a.id;
                p.Project_Name__c = 'Test Project';
                p.Project_Award_Date__c = date.today();
            insert p;    
                
            //Create an Opportunity
            RecordType theRecordType4 = [SELECT Id FROM RecordType WHERE Name='Project' AND SobjectType='Opportunity' LIMIT 1];
            Opportunity opp = new Opportunity();
                opp.RecordTypeId = theRecordType4.id;       
                opp.AccountId = a.id;
                opp.Name = 'Test Opportunity';
                opp.Project_Awards__c = p.id;
                opp.Project_Name__c = 'Test EA Agreement Opportunity linkage Project';
                opp.StageName = 'Validate';
                opp.Opportunity_Forecast__c = 'Upside';
                opp.Status__c ='Active';
                //opp.Reason_for_Win_or_Loss__c='Low Opportunity Score';
                opp.CloseDate = date.today();
                opp.Industry__c = 'Public Services (non-Public Safety Government)'; 
                opp.Primary_Technology__c = 'ASTRO';
                opp.Business_Group__c = 'Channel Project';
                opp.CurrencyIsoCode = 'USD';
                opp.End_User_Segment__c = 'Government Transportation';
                opp.Probability = 40;
                opp.Type = 'Standard';
                opp.UN_Theatre__c = 'EMEA';
                opp.Service_Attached__c = 'Yes';
            insert opp;
            Test.StopTest();
            List<Opportunity> oppList = [SELECT Account.Id,RecordType.Name,Account.Name,Name,Total_Order_Value_Inc_Service__c,
                                         SYM_Transaction_Number__c,Owner.Area_Controller__c,Owner.Name,
                                         Project_Awards__c,mh_Associated_Blue_Sheet__c,Status__c,Industry__c,Primary_Technology__c
                                         FROM Opportunity Where Id =:opp.id];
            System.debug('inserted oppty name is '+ oppList[0].Name);           
            PageReference eacPage = Page.PDFdocEA;      
            Test.setCurrentPage(eacPage);           
            ApexPages.currentPage().getParameters().put('id',opp.id);
            ApexPages.StandardController sc = new ApexPages.standardController(oppList[0]);
            EAAgreementController eac = new EAAgreementController(sc);
            eac.insertAgreement();
		} 
    }