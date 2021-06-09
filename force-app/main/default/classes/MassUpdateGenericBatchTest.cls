@isTest
public class MassUpdateGenericBatchTest {
    
    @testSetup static void testDataSetupMethod1() {
        TestDataSetUpUtils.insertCustomSettings();
        List<Account> customerAccList = TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),customerAccList);
        List<Account> CompetitorAccList = TestDataSetUpUtils.createAccounts(3,Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId());
    }
    
    @isTest static void testDaysInStageBatch(){
        List<Opportunity> OppList = [Select Id from Opportunity LIMIT 1];
        List<OpportunityFieldHistory> fieldHistoryList = new List<OpportunityFieldHistory>();
        for(Integer i=0;i<2;i++){
            OpportunityFieldHistory fieldHistory = new OpportunityFieldHistory(OpportunityId = OppList[0].id, Field = 'CloseDate');
            OpportunityFieldHistory fieldHistory1 = new OpportunityFieldHistory(OpportunityId = OppList[0].id, Field = 'StageName');
            fieldHistoryList.add(fieldHistory);
            fieldHistoryList.add(fieldHistory1);
        }
        Test.startTest();
        if(!fieldHistoryList.isEmpty()){
            insert fieldHistoryList;
        }
        //Test for DaysInStageBatch
        String query1 = 'SELECT Field, CreatedDate, NewValue, OldValue, OpportunityId FROM OpportunityFieldHistory WHERE Field = \''+'StageName'+'\' order by CreatedDate';
        Database.executeBatch(new MassUpdateGenericBatch(query1, 'DaysInStageBatch', true),2);
        Test.stopTest();
        //Test for CloseDateCounterBatch
        String query2 = 'SELECT Field, CreatedDate, NewValue, OldValue, OpportunityId FROM OpportunityFieldHistory WHERE Field = \''+'CloseDate'+'\' order by CreatedDate';
        Database.executeBatch(new MassUpdateGenericBatch(query2, 'CloseDateCounterBatch', true),2);
    }  
    
    @isTest static void testProposalBatch(){
        Id NARecordType = Schema.SObjectType.PreSales__c.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        List<Opportunity> OppList = [Select Id from Opportunity LIMIT 1];
        Test.startTest();
        //Create Presales with Opportunities
        List<PreSales__c> preSalesList = TestDataSetUpUtils.createPreSalesWithOpp(2, OppList, NARecordType);
        Test.stopTest();
        String query = 'SELECT Id, Name, Opportunity__c,Proposal_Type_N__c,Revision_Number__c,RFx_Proposal_Due_Date__c from PreSales__c WHERE Proposal_Type_N__c != \''+'Non Proposal Project Support'+'\' AND Opportunity__c != NULL';
        Database.executeBatch(new MassUpdateGenericBatch(query, 'ProposalDueDateBatch', true),2);
    }
    
    @isTest static void testIncumbentCreation(){
        List<Opportunity> OppListVal = [Select Id,Primary_Competitor_Account__c,Incumbent_Lookup__c from Opportunity LIMIT 1];
        List<Account> CompetitorAccList = [Select Id,Name from Account WHERE RecordType.Name = 'Competitor'];
        for(Opportunity oppr : OppListVal){
            oppr.Incumbent_Lookup__c = CompetitorAccList[0].Id;
        }
        Test.startTest();
        update OppListVal;
        // cover new competitors insertion
        String query1 = 'SELECT Id,Name,Incumbent_Lookup__c,(Select Id,Name,Competitive_vendor__c from Competitive_DB_Records__r)FROM Opportunity WHERE Incumbent_Lookup__c!=NULL';
        Database.executeBatch(new MassUpdateGenericBatch(query1, 'IncumbentCompetitorBatch', true),2);
        Test.stopTest();
    }
    
    @isTest static void testManufacturerBatch(){
        List<Account> CompetitorAccList = [Select Id,Name from Account WHERE RecordType.Name = 'Competitor'];
        List<Opportunity> OppListVal = [Select Id,Primary_Competitor_Account__c,Incumbent_Lookup__c from Opportunity LIMIT 1];
        
        Test.startTest();
        for(Opportunity oppr : OppListVal){
            oppr.Primary_Competitor_Account__c = CompetitorAccList[0].Id;
        }
        update OppListVal;
        String query = 'Select Id,Name,Primary_Competitor_Account__c, (select Id,Competitive_Vendor__c from Competitive_DB_Records__r) from Opportunity where Primary_Competitor_Account__c != NULL';
        Database.executeBatch(new MassUpdateGenericBatch(query, 'ManufacturerAwardedCompetitorBatch', true),2);
        Test.stopTest();
    }
    
    @isTest static void testPrimaryCompetitorBatch(){
        List<Opportunity> OppListVal = [Select Id,Primary_Competitor_Account__c,Incumbent_Lookup__c from Opportunity LIMIT 1];        
        for(Opportunity oppr : OppListVal){
            oppr.Primary_Competitor__c = 'Airwave';
        }
        Test.startTest();
        update OppListVal;
        String query = 'Select Id,name,Primary_Competitor__c,(Select Id,competitive_vendor__c,competitive_vendor__r.name from competitive_DB_Records__r) from opportunity where Primary_Competitor__c != null';
        Database.executeBatch(new MassUpdateGenericBatch(query, 'UpdatePrimaryCompetitorValueBatch', false),2);
        Test.stopTest();
    }
    
    @isTest static void testCreateCompetitorBatch(){
        List<Opportunity> OppListVal = [Select Id,Primary_Competitor_Account__c,Incumbent_Lookup__c from Opportunity LIMIT 1];        
        for(Opportunity oppr : OppListVal){
            oppr.Competition__c = '5 points;Avtec';
        }
        Test.startTest();
        update OppListVal;
        String query = 'Select Id,Name,Competition__c,(select id,competitive_vendor__c,competitive_vendor__r.name from competitive_DB_Records__r) from opportunity where Competition__c != null';
        Database.executeBatch(new MassUpdateGenericBatch(query, 'CreateCompetitorRecordsBatch', false),2);
        Test.stopTest();
    }
    
    @isTest static void testUpdateSearchHelper(){
        Test.startTest();
        String query1 = 'Select Id,Search_Helper__c from CompetitiveDB__c';
        Database.executeBatch(new MassUpdateGenericBatch(query1, 'UpdateSearchHelper', true),3);
        String query2 = 'Select Id,Search_Helper_for_MCNs__c from Account WHERE RecordType.DeveloperName = \'Prospect\'';
        Database.executeBatch(new MassUpdateGenericBatch(query2, 'UpdateSearchHelper', true),2);
        Test.stopTest();
    }
    
    @isTest static void testUpdateUniqueCompetitor(){
        List<CompetitiveDB__c> competitorList = new List<CompetitiveDB__c>();
        List<Account> CompetitorAccList = [Select Id,Name from Account WHERE RecordType.Name = 'Competitor'];
        List<Opportunity> OppListVal = [Select Id,Name from Opportunity LIMIT 1];
        for(Account acc : CompetitorAccList) {
            CompetitiveDB__c competitor = new CompetitiveDB__c();
            competitor.Competitive_Vendor__c = acc.Id;
            competitor.Related_Opportunity__c = OppListVal[0].Id;
            competitorList.add(competitor);
        }
        if(!competitorList.isEmpty()) insert competitorList;
        String query = 'Select Id,Competitive_Vendor__c,Account_ID__c,Related_Opportunity__c from CompetitiveDB__c';
        Test.startTest();
        Database.executeBatch(new MassUpdateGenericBatch(query, 'UpdateUniqueCompetitor', true),3);
        Test.stopTest();
    }
}