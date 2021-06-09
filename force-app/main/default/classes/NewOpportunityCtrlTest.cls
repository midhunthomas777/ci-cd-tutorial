@isTest
public class NewOpportunityCtrlTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }  
    
    @isTest
    public static void testMethodOne(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id projectOppotunityRecType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
        // Id opportunitySERecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SE-New Business Development').getRecordTypeId();        
        Test.startTest();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createOpportunities(1,projectOppotunityRecType,lstAccount);
        NewOpportunityCtrl.getMCN(lstOpportunity.get(0).Id);
        NewOpportunityCtrl.getUserTheme();
        NewOpportunityCtrl.fetchOpportunityAccess();
        // NewOpportunityCtrl.validateSERecordType(opportunitySERecordType);
        NewOpportunityCtrl.getFieldSets('Opportunity');
        NewOpportunityCtrl.fetchCustomerAccount(lstAccount.get(0).Id,'NewOpportunity',false);
        NewOpportunityCtrl.getAccRegionTerritory(lstAccount.get(0).Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodTwo(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id projectOpportunityRecType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();         
        Test.startTest();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1,accrectypeID);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createOpportunities(1,projectOpportunityRecType,lstAccount);
        NewOpportunityCtrl.getMetaMessages('New_Opportunity');
        // NewOpportunityCtrl.validateSERecordType(projectOpportunityRecType);
        NewOpportunityCtrl.FieldSetMember fieldSetClass = new NewOpportunityCtrl.FieldSetMember(true);
        NewOpportunityCtrl.fetchCustomerAccount(lstOpportunity.get(0).Id,'NewOpportunity',true);
        //NewOpportunityCtrl.getAccountRegionTerritory('Account','Region__c','Territory__c');
        //NewOpportunityCtrl.getOpportunityRegionTerritory('Opportunity','Region__c','Territory__c');
        NewOpportunityCtrl.getAccRegionTerritory(lstAccount.get(0).Id);
        UtilsDeeperClone.getUserTheme();        
        UtilsDeeperClone.fetchOpportunityAccess();
        UtilsDeeperClone.fetchOriginalClone(lstOpportunity.get(0).Id,'Opportunity_Clone');
        UtilsDeeperClone.sObjectChildSelectionFunc(lstOpportunity.get(0).Id,'Opportunity_Clone');
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodThree(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id competitorRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id projectOpportunityRecType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
        Test.startTest();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1,accrectypeID);
        List<Account> competitorAccounts = TestDataSetUpUtils.createAccounts(1,competitorRecTypeID);
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createOpportunities(1,projectOpportunityRecType,lstAccount);
        List<CompetitiveDB__c> competitors = TestDataSetUpUtils.createCompetitiveDBWithOpp(1,competitorAccounts,lstOpportunity);
        List<String> childRecordsForClone = new List<String>();
        childRecordsForClone.add('CompetitiveDB__c');
        Opportunity newOpportunityByClone = new Opportunity(Name='test opportunity',Pricebook2Id=Test.getStandardPricebookId(),
                                                            StageName='Design & Validate',AccountId=lstAccount.get(0).Id,
                                                            CloseDate = Date.today()+30);
        NewOpportunityCtrl.cloneRecords(childRecordsForClone,lstOpportunity.get(0).Id,'Opportunity_Clone',newOpportunityByClone);
        Test.stopTest();
    }
}