/*
 * Name : ChildRecordsByParentCtrlTest
 * Description : Test class for ChildRecordsByParentCtrl class
 * Author : Satish
 */ 
@isTest
public class ChildRecordsByParentCtrlTest {
	@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void testChildRecordsByParents() {
        String MCNNumber = String.valueOf(Integer.valueOf(Math.random()*1000000000)*100);
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
        
        Id mcnRecTypeId = GlobalUtility.recordTypeId('Account', 'Motorola Customer Number');
        Id prospectRecTypeId = GlobalUtility.recordTypeId('Account', 'Prospect');
        Account prospectAcc = new Account(Name = 'TestParent',
                                   RecordTypeId = prospectRecTypeId, 
                                   CurrencyIsoCode = 'USD',
                                   BillingCountry = 'United States',
                                   Billing_County__c= 'Australia',
                                   BillingState = 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet = 'test',
                                   MCN_Account_Number__c = MCNNumber,
                                   Industry = 'Hospitality and Retail',
                                   Segment__c = 'Service Retailers',
                                   Region__c = 'NA',
                                   Territory__c = 'T2',
                                   sic = '1011',
                                   BillingPostalCode = '112004');
        Database.insert(prospectAcc,dml); 
        Account mcnAccount=new Account(
            Name = 'MCNAccount',
            ParentId = prospectAcc.Id,
            RecordTypeId = mcnRecTypeId, 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c = '',
            Motorola_Customer_Number__c = MCNNumber,
            ERP_Active__c = true
        );
        Database.insert(mcnAccount,dml);
        ChildRecordsByParentCtrl.getFieldValues(new List<String>{'Name'}, 'Account', String.valueOf(prospectAcc.id) , 'ParentId');
        //ChildRecordsByParentCtrl.queryObjects('Account', new List<String>{'Name'}, null, 'Name', 'ASC');
    }
}