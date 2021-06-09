@isTest
public class AccountCAPPAndSRHierarchyControllerTest {

    @testSetup
    static void testSetUp(){
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testMethodOne(){
        Id customerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id competitorRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Bodyworn Camera').getRecordTypeId();
        
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1, customerRecordType);
        List<Account> mcnAccounts = TestDataSetUpUtils.createMCNAccounts(1, mcnRecordType, customerAccounts);
        List<Account> competitorAccounts = TestDataSetUpUtils.createAccounts(1, competitorRecordType);
        List<Customer_Portfolio_Presence__c> cappsList = TestDataSetUpUtils.createCAPPs(1,competitorAccounts.get(0).Id,cappRecordTypeId);
        List<Technical_Site__c> siteList = TestDataSetUpUtils.createSites(4,mcnAccounts.get(0).Id,customerAccounts.get(0).Id,null);
        List<System_Relationship__c> firstLevelSystemRelation = TestDataSetUpUtils.createSystemRelations(1,cappsList.get(0).Id,customerAccounts.get(0).Id, null,null);
        List<System_Relationship__c> secondLevelSystemRelation = TestDataSetUpUtils.createSystemRelations(1,cappsList.get(0).Id,customerAccounts.get(0).Id,firstLevelSystemRelation.get(0).Id,
                                                                                      siteList.get(0).Id);
        List<System_Relationship__c> thirdLevelSystemRelation = TestDataSetUpUtils.createSystemRelations(1,cappsList.get(0).Id,customerAccounts.get(0).Id,secondLevelSystemRelation.get(0).Id,
                                                                                      siteList.get(1).Id);
        List<System_Relationship__c> fourthLevelSystemRelation = TestDataSetUpUtils.createSystemRelations(1,cappsList.get(0).Id,customerAccounts.get(0).Id,thirdLevelSystemRelation.get(0).Id,
                                                                                      siteList.get(2).Id);
        List<System_Relationship__c> fifthLevelSystemRelation = TestDataSetUpUtils.createSystemRelations(1,cappsList.get(0).Id,customerAccounts.get(0).Id,fourthLevelSystemRelation.get(0).Id,
                                                                                      siteList.get(3).Id);
        
        
        Test.startTest();
        AccountCAPPAndSRHierarchyController.getFieldsData(customerAccounts.get(0).Id);
        Test.stopTest();
    }
}