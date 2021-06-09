@isTest
public class OpportunityLineItemTableCtrlTest {
    
    @testSetup
    static void testSetUp(){
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testMethodOne(){
        Id customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id projectRecordtype = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<Account> accountList = TestDataSetUpUtils.createAccounts(1,customerRecordType);
        List<Account> mcnAccountList = TestDataSetUpUtils.createMCNAccounts(1,mcnRecordType,accountList);
        List<opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1, projectRecordtype, accountList);
        opportunityList[0].Sales_Process__c = 'New_Business_Development';
        update opportunityList;
        list<OpportunityLineItem> oliList = TestDataSetUpUtils.createOLIs(opportunityList);
        
        String oppProducts = '[{"endDate":"2020-07-05","isSubscriptionBased":false,"name":"SE Flex CAD","PricebookEntryId":"01u2H00000FPlI9QAL","rowId":"row-0","startDate":"2020-07-01","unitPrice":75000}]';
        Test.startTest();
        OpportunityLineItemTableCtrl.validateOpportunityAccess();
        oliList[0].Contract_Subscription_Start_Date__c = System.today()+1;
        oliList[0].Contract_Subscription_End_Date__c = System.today()+30;
        update oliList;
        OpportunityLineItemTableCtrl.getOpportunityLineitems(opportunityList.get(0).Id);
        OpportunityLineItemTableCtrl.createRenewalOpportunity(oppProducts,new List<String>{'Partners2__c','SubAgency__c'},opportunityList.get(0).Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodTwo(){
        Id customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id projectRecordtype = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<Account> accountList = TestDataSetUpUtils.createAccounts(1,customerRecordType);
        List<opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1, projectRecordtype, accountList);
        String oppProducts = '[{"startDate":"2020-01-05","endDate":"2020-07-05","isSubscriptionBased":false,"name":"SE Flex CAD","PricebookEntryId":"01u2H00000FPlI9QAL","rowId":"row-0","unitPrice":75000}]';
        Test.startTest();
        OpportunityLineItemTableCtrl.createRenewalOpportunity(oppProducts,new List<String>{'Partners2__c'},opportunityList.get(0).Id);
        
        opportunityList[0].StageName = 'Execute & Expand / Won';
        opportunityList[0].Reason_for_Win_or_Loss__c = 'MSI as the provider';
        opportunityList[0].Award_Date__c = system.today();
        update opportunityList;
        OpportunityLineItemTableCtrl.createRenewalOpportunity(oppProducts,new List<String>{'Partners2__c'},opportunityList.get(0).Id);
        Test.stopTest();
    }
}