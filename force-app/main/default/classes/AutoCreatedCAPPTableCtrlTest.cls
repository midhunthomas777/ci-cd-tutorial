/*============================================================================================ 
Name : AutoCreatedCAPPTableCtrlTest
Description    : Test Class for AutoCreatedCAPPTableCtrlTest
Author : Srikanth
Created Date : 26th August 2020
Requirement: SF-2461
Modification History:   
===============================================================================================*/
@isTest
public class AutoCreatedCAPPTableCtrlTest {
    
    
     @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testgetCAPPRecords(){
    	//Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();   
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        //Create Prospect Account
        Id customerRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1, customerRecordTypeId);
        //Create CAPP Record
        List<Customer_Portfolio_Presence__c> CAPPRecords = TestDataSetUpUtils.createCAPPs(1, VendorId, cappRecordTypeId);
        //Create Opportunity Record
        TestDataSetUpUtils.activateOppTrigger();
        List<Opportunity> lstOpps = TestDataSetUpUtils.createOpportunities(1,Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
		CAPPRecords[0].Opportunity_Auto_Created_or_Modified_Fr__c = lstOpps[0].Id;
        update CAPPRecords;
        
        Test.startTest();
        List<Customer_Portfolio_Presence__c> cappList = AutoCreatedCAPPTableCtrl.getCAPPRecords('Id, Name, Opportunity_Auto_Created_or_Modified_Fr__c,Reviewed_by_Sales__c',lstOpps[0].Id );
        AutoCreatedCAPPTableCtrl.updateCAPPRecords('Id, Name, Opportunity_Auto_Created_or_Modified_Fr__c,Reviewed_by_Sales__c',lstOpps[0].Id );
        Test.stopTest();
    }    
}