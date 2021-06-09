/*  
* Class Name  : CompetitorTriggerTest
* Description:  This class is used for test coverage of CompetitorTrigger, CompetitorTriggerHelper and CompetitorTriggerHandler
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   31/12/2019    Sagar    		This test class covered the CompetitorTrigger, CompetitorTriggerHelper and CompetitorTriggerHandler.
*/

@isTest
public class CompetitorTriggerTest {
    
    @testSetup static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
     
    @isTest static void testInsertCompetitor(){
        Id ProspectRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(); 
        Id ProjectRecordType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
        Id CompetitorRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        List<Account> competitorAccList = TestDataSetUpUtils.createAccounts(2,CompetitorRecordType);
        List<Account> ProspectAccList = TestDataSetUpUtils.createAccounts(1,ProspectRecordType);        
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRecordType, ProspectAccList);
        Test.startTest();
        List<CompetitiveDB__c> CDBList = TestDataSetUpUtils.createCompetitiveDBWithOpp(1,competitorAccList,OppList);
        System.assertEquals(2, CDBList.size());
        Test.stopTest();
    }
    @isTest static void testUpdateCompetitor(){
        Id ProspectRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(); 
        Id ProjectRecordType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
        Id CompetitorRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        List<Account> competitorAccList = TestDataSetUpUtils.createAccounts(2,CompetitorRecordType);
        List<Account> ProspectAccList = TestDataSetUpUtils.createAccounts(1,ProspectRecordType);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRecordType, ProspectAccList);
        List<CompetitiveDB__c> CDBList = TestDataSetUpUtils.createCompetitiveDBWithOpp(1,competitorAccList,OppList);
        System.assertEquals(2, CDBList.size());
        Test.startTest(); 
        CompetitiveDB__c compRec = new CompetitiveDB__c();
        compRec = CDBList[0];
        compRec.Primary_Competitor__c = TRUE;
        Update compRec;
        Test.stopTest();
    }
    @isTest static void testDeleteCompetitor(){
        Id ProspectRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(); 
        Id ProjectRecordType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
        Id CompetitorRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        List<Account> competitorAccList = TestDataSetUpUtils.createAccounts(2,CompetitorRecordType);
        List<Account> ProspectAccList = TestDataSetUpUtils.createAccounts(1,ProspectRecordType);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRecordType, ProspectAccList);
        List<CompetitiveDB__c> CDBList = TestDataSetUpUtils.createCompetitiveDBWithOpp(1,competitorAccList,OppList);
        System.assertEquals(2, CDBList.size());
        Test.startTest(); 
        CompetitiveDB__c compRec = new CompetitiveDB__c();
        compRec = CDBList[0];
        delete compRec;
        Test.stopTest();
    }
}