@isTest
public class CAPPTriggerHandler_Test {
	@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    } 
     @isTest
    public static void testCreateCAPP(){
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();   
        TestDataSetUpUtils.activateAccTrigger();
        
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        
        Id cusRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id mcnRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();  
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1,cusRecordTypeId);         
        List<Account> mcnList = TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, customerAccounts);
		Test.startTest();
        //Create CAPP Record
        List<Customer_Portfolio_Presence__c> CAPPRecords = new List<Customer_Portfolio_Presence__c>();
        Customer_Portfolio_Presence__c capp = new Customer_Portfolio_Presence__c();
        capp.Vendor__c = VendorId;
        capp.Purchase_Year__c = '2020';
        capp.RADIO_INFRASTRUCTURE_1__c ='TETRA';
        capp.RADIO_HARDWARE_MAINTENANCE__c = 'Essential';
        capp.RADIO_RELEASE_1__c = 'D5.2 (Gen 1)';
        capp.RADIO_HDW_MAINT_CONTRACT_END__c = '2022';
        capp.Number_of_RF_Sites_1__c = 3;            
        capp.Known_Total_of_incumbent_deal_MM_U__c = 10000;
        capp.Number_of_Base_Stations_1__c = 1;
        capp.RecordTypeId = cappRecordTypeId;
        capp.Temporary_MCN__c = mcnList[0].Motorola_Customer_Number__c;
        CAPPRecords.add(capp);
        
        insert CAPPRecords;
        Test.stopTest();        
    }
     @isTest
    public static void testDeleteCAPP(){
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id accessControlRecordtypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Access Control').getRecordTypeId();        
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        Test.startTest();
        List<Customer_Portfolio_Presence__c> CAPPs = TestDataSetUpUtils.createCAPPs(1, VendorId, accessControlRecordtypeId);
        
        delete CAPPs;
        Test.stopTest();       
    }
     @isTest
    public static void testUpdateCAPP(){
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id accessControlRecordtypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Access Control').getRecordTypeId();        
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        Test.startTest();
        List<Customer_Portfolio_Presence__c> CAPPs = TestDataSetUpUtils.createCAPPs(1, VendorId, accessControlRecordtypeId);
        CAPPs[0].Notes__c = 'Test';
        update CAPPs;
        Test.stopTest();       
    }
}