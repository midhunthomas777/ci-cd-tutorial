/********************************************************************
* Class Name  : NewCAPPControllerTest
* Description:  This is Test Class for NewCAPPController              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -------------------------------------------------------------------------------------------------
*************************************************************************************************/

@isTest
public class NewCAPPControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testgetPicklistValuesByRecordType(){ 
        
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();
        NewCAPPControllerMock mock = new NewCAPPControllerMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();        
        NewCAPPController.getPicklistValuesByRecordType('Customer_Portfolio_Presence__c','BROADBAND_CARRIER__c', cappRecordTypeId);
        NewCAPPController.handlePicklistChange('Customer_Portfolio_Presence__c','Bodyworn Camera','RADIO_INFRASTRUCTURE_1__c','RADIO_RELEASE_1__c','TETRA');
        NewCAPPController.getFieldDependencies('Customer_Portfolio_Presence__c','RADIO_INFRASTRUCTURE_1__c','RADIO_RELEASE_1__c');
        Test.stopTest();
    } 
    
    @isTest
    public static void testgetfieldsWithSections(){ 
        
        NewCAPPControllerMock mock = new NewCAPPControllerMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        NewCAPPController.getfieldsWithSections();
        NewCAPPController.getControllingPicklistFields();
        Test.stopTest();
    } 
    
    
    @isTest
    public static void testgetFieldSets(){ 
        
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();   
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        //Create Prospect Account
        Id customerRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1, customerRecordTypeId);
        //Create CAPP Record
        List<Customer_Portfolio_Presence__c> CAPPRecords = TestDataSetUpUtils.createCAPPs(1, VendorId, cappRecordTypeId);   
        //Create System Relationship records
        List<System_Relationship__c> SystemRelList = TestDataSetUpUtils.createSystemRelations(1, CAPPRecords.get(0).Id,customerAccounts.get(0).Id, null,null);
        NewCAPPControllerMock mock = new NewCAPPControllerMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest(); 
        NewCAPPController.getFieldSets(customerAccounts.get(0).Id);
        Test.stopTest();
    }  
    
    @isTest
    public static void testupsertCAPPS(){ 
        
        Test.startTest();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        
        Id customerRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1, customerRecordTypeId);

        List<Customer_Portfolio_Presence__c> CAPPs =  TestDataSetUpUtils.createCAPPs(1, VendorId, cappRecordTypeId);
        List<System_Relationship__c> SystemRelList = TestDataSetUpUtils.createSystemRelations(1, CAPPs.get(0).Id,customerAccounts.get(0).Id, null,null);
        String operation = 'creation'; 
        String wrapper = '[{"sectionName":"Emergency Call Taking (911)","currentRecordId":"'+customerAccounts.get(0).Id+'","currentObjName":"Account","fields":[{"fieldName":"Vendor__c","fieldType":"REFERENCE","fieldValue":"'+VendorId+'"},{"fieldName":"Vendor_Product_Line__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Purchase_Year__c","fieldType":"PICKLIST","fieldValue":"1995"},{"fieldName":"Version__c","fieldType":"STRING","fieldValue":""},{"fieldName":"Number_of_Positions__c","fieldType":"DOUBLE","fieldValue":""},{"fieldName":"Primary_Dispatcher__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Service_Provider__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Authorized_Agent__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"NOTES__c","fieldType":"TEXTAREA","fieldValue":""}],"recordID":"CAPPRecordID"},{"sectionName":"Emergency Call Taking (911)","currentRecordId":"'+customerAccounts.get(0).Id+'","currentObjName":"Account","fields":[{"fieldName":"Satisfaction__c","fieldType":"PICKLIST","fieldValue":"High"},{"fieldName":"Install_Date__c","fieldType":"DATE","fieldValue":"2020-06-30"},{"fieldName":"Verified_Date__c","fieldType":"DATE","fieldValue":"2020-07-16"},{"fieldName":"Initial_Ship_Date__c","fieldType":"DATE","fieldValue":""},{"fieldName":"Management_Information_System_MIS__c","fieldType":"PICKLIST","fieldValue":"MagIC"}],"recordID":"SYSTEMRecordID"}]';
        NewCAPPController.upsertCAPPS(wrapper,operation);
        wrapper = '[{"sectionName":"Emergency Call Taking (911)","currentRecordId":"'+customerAccounts.get(0).Id+'","currentObjName":"Account","fields":[{"fieldName":"Vendor__c","fieldType":"REFERENCE","fieldValue":"'+VendorId+'"},{"fieldName":"Vendor_Product_Line__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Purchase_Year__c","fieldType":"PICKLIST","fieldValue":"1995"},{"fieldName":"Version__c","fieldType":"STRING","fieldValue":""},{"fieldName":"Number_of_Positions__c","fieldType":"DOUBLE","fieldValue":""},{"fieldName":"Primary_Dispatcher__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Service_Provider__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Authorized_Agent__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"NOTES__c","fieldType":"TEXTAREA","fieldValue":""}],"recordID":"CAPPRecordID"}]';
        NewCAPPController.upsertCAPPS(wrapper,operation);
        wrapper = '[{"sectionName":"Emergency Call Taking (911)","currentRecordId":"001P000001TfTODIA3","currentObjName":"Account","fields":[{"fieldName":"Vendor__c","fieldType":"REFERENCE","fieldValue":"001P000001TfTflIAF"},{"fieldName":"Vendor_Product_Line__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Purchase_Year__c","fieldType":"PICKLIST","fieldValue":"1995"},{"fieldName":"Version__c","fieldType":"STRING","fieldValue":""},{"fieldName":"Number_of_Positions__c","fieldType":"DOUBLE","fieldValue":""},{"fieldName":"Primary_Dispatcher__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Service_Provider__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Authorized_Agent__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"NOTES__c","fieldType":"TEXTAREA","fieldValue":""}],"recordID":"CAPPRecordID"},{"sectionName":"Emergency Call Taking (911)","currentRecordId":"001P000001TfTODIA3","currentObjName":"Account","fields":[{"fieldName":"Satisfaction__c","fieldType":"PICKLIST","fieldValue":"High"},{"fieldName":"Install_Date__c","fieldType":"DATE","fieldValue":"2020-06-30"},{"fieldName":"Verified_Date__c","fieldType":"DATE","fieldValue":"2020-07-16"},{"fieldName":"Initial_Ship_Date__c","fieldType":"DATE","fieldValue":""},{"fieldName":"Management_Information_System_MIS__c","fieldType":"PICKLIST","fieldValue":"MagIC"}],"recordID":"SYSTEMRecordID"}]';
        NewCAPPController.upsertCAPPS(wrapper,operation);
        wrapper = '[{"recordID":"'+CAPPs.get(0).Id+'","fields":[{"fieldName":"Vendor__c","fieldType":"REFERENCE","fieldValue":"'+VendorId+'"},{"fieldName":"Vendor_Product_Line__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Purchase_Year__c","fieldType":"PICKLIST","fieldValue":"1995"},{"fieldName":"Version__c","fieldType":"STRING","fieldValue":"10"},{"fieldName":"Number_of_Positions__c","fieldType":"DOUBLE","fieldValue":""},{"fieldName":"Primary_Dispatcher__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Service_Provider__c","fieldType":"REFERENCE","fieldValue":""},{"fieldName":"Authorized_Agent__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"NOTES__c","fieldType":"TEXTAREA","fieldValue":"HELLO"},{"fieldName":"Name","fieldType":"STRING","fieldValue":"'+CAPPs.get(0).Name+'"}]},{"recordID":"'+SystemRelList.get(0).Id+'","fields":[{"fieldName":"Satisfaction__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"Install_Date__c","fieldType":"DATE","fieldValue":"2020-06-15 00:00:00"},{"fieldName":"Verified_Date__c","fieldType":"DATE","fieldValue":"2020-05-20 00:00:00"},{"fieldName":"Initial_Ship_Date__c","fieldType":"DATE","fieldValue":"2020-06-22 00:00:00"},{"fieldName":"Management_Information_System_MIS__c","fieldType":"PICKLIST","fieldValue":""},{"fieldName":"Name","fieldType":"STRING","fieldValue":"'+SystemRelList.get(0).Name+'"}]}]';
        operation = 'updation';
        NewCAPPController.upsertCAPPS(wrapper,operation);
        Test.stopTest();
    } 

	@isTest
    public static void testCappRecTypeId(){
        Test.startTest();
        String actid = NewCAPPController.getRecTypeId('Competitor');
        System.debug('CompetitorId; ' + actid);
        System.assert(actid.length()>0);
        String actidnull = NewCAPPController.getRecTypeId('');
        System.debug('CompetitorId; ' + actidnull);
        System.assert(actidnull == '');
        Test.stopTest();
    }  
    @isTest
    public static void testgetCompetitorIntelligenceURL(){         
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;       
        
        Test.startTest(); 
        String competitorURL = NewCAPPController.getCompetitorIntelligenceURL(VendorId);
        Test.stopTest();
    } 
    @isTest
    public static void testisVendorProdPresent(){         
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;       
        
        Test.startTest(); 
        Boolean isVendorProd = NewCAPPController.isVendorProdPresent(VendorId, 'Emergency Call Taking (911)');
        Test.stopTest();
    } 
}