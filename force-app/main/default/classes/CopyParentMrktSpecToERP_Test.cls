@isTest
/*
 * File Name  : CopyParentMrktSpecToERP_Test
 * Description: This class is to unit test code for the trigger: ParentProgInfoToERP
 * Author     : Meghana Sreenath Basetty
 * Modification Log 
 * ============================================================================= 
 * Ver   Date        Author                         Modification 
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 1.0   jan/17/2013   Meghana Sreenath Basetty       Initial Code.
 */ 
 private class CopyParentMrktSpecToERP_Test {
		@testSetup
	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
    }
        public static testMethod void testCopyParentMrktSpecToERP(){
        
          // Create an Account
    RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account parentAcc = new Account(name='Test Account1acc009',RecordTypeId=theRecordType.Id,Partner_Region__c = 'APAC',Metal_Level__c = 'GOLD',Hierarchy_Placement__c = 'ERP Account',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123' );
        insert parentAcc ;
        Account child = new Account(name='Test2accVKC0098', ParentId=parentAcc.id,Partner_Region__c = 'EMEA', Hierarchy_Placement__c = 'ERP Account',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123'  );
        insert child ;
        Account child1 = new Account(name='TestAcc30089', ParentId=parentAcc.id,Partner_Region__c = 'EMEA',Hierarchy_Placement__c = 'ERP Account',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123'  );
        insert child1 ;
        
        //create the market specialisation records
    List<Market_Specializations__c> mrkSpecList1 = new List<Market_Specializations__c>();
    List<Market_Specializations__c> mrkSpecList2 = new List<Market_Specializations__c>();
     List<Market_Specializations__c> mrkSpecList3 = new List<Market_Specializations__c>();
    List<Market_Specializations__c> UpdatemrkSpecList = new List<Market_Specializations__c>();  
       
    Market_Specializations__c mrkSpec1 = new Market_Specializations__c(Account__c = parentAcc.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Authorized' );
    mrkSpecList1.add(mrkSpec1);
    Market_Specializations__c mrkSpec2 = new Market_Specializations__c(Account__c = parentAcc.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Specialist' );
    mrkSpecList1.add(mrkSpec2);
    insert mrkSpecList1; 
    Market_Specializations__c mrkSpec3 = new Market_Specializations__c(Account__c = child.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Authorized' );
    mrkSpecList2.add(mrkSpec3);
    Market_Specializations__c mrkSpec4 = new Market_Specializations__c(Account__c = child.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Specialist' );
    mrkSpecList2.add(mrkSpec4);
    insert mrkSpecList2; 
    Market_Specializations__c mrkSpec5 = new Market_Specializations__c(Account__c = child1.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Authorized' );
    mrkSpecList2.add(mrkSpec5);
    Market_Specializations__c mrkSpec6 = new Market_Specializations__c(Account__c = child1.id, Market_Specialization__c = 'US Federal', Market_Specialization_Level__c = 'Specialist' );
    mrkSpecList2.add(mrkSpec6);
    insert mrkSpecList3; 
    mrkSpec1.Market_Specialization_Level__c = 'Elite Specialist';
    mrkSpec2.Market_Specialization_Level__c = 'Authorized';
    
    UpdatemrkSpecList.add(mrkSpec1);
    UpdatemrkSpecList.add(mrkSpec2);
    update UpdatemrkSpecList;
    }
    
    }