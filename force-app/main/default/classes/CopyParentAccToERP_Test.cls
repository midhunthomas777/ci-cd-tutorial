@isTest
/*
 * File Name  : CopyParentAccToERP_Test
 * Description: This class is to unit test code for the trigger: CopyParentAccToERP
 * Author     : Meghana Sreenath Basetty
 * Modification Log 
 * ============================================================================= 
 * Ver   Date        Author                         Modification 
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 1.0   12/10/2012   Meghana Sreenath Basetty       Initial Code.
 */ 
private class CopyParentAccToERP_Test {
	@testSetup
	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
    }
        public static testMethod void testCopyParentAccToERP(){
    
    // Create an Account
    RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account parentAcc = new Account(name='Test Account1test008',RecordTypeId=theRecordType.Id,Partner_Region__c = 'APAC',Metal_Level__c = 'GOLD',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123' );
        insert parentAcc ;
        Account child = new Account(name='Test Account2VKC009', ParentId=parentAcc.id,Partner_Region__c = 'EMEA' ,Hierarchy_Placement__c='ERP Account',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123' );
        insert child ;
    // Create Prog info for the child account
    
    List<Partner_Type__c> ProgInfolist = new List<Partner_Type__c>();
    Partner_Type__c p1 = new Partner_Type__c(Account__c=child.id,Program__c='SCADA',US_Federal__c = true);
    ProgInfolist.add(p1);
    Partner_Type__c p2 = new Partner_Type__c(Account__c=child.id,Program__c='Wireless Network Solutions');
    ProgInfolist.add(p2);
    Partner_Type__c p3 = new Partner_Type__c(Account__c=child.id,Program__c='Radio Solutions');
    ProgInfolist.add(p3);
    Partner_Type__c p4 = new Partner_Type__c(Account__c=child.id,Program__c='Mobility');
    ProgInfolist.add(p4);
    insert ProgInfolist ;    
    /* Partner_Type__c ProgInfolist = new Partner_Type__c(Account__c = child.id,Program__c='SCADA',US_Federal_Specialization__c = 'Authorized');
     insert ProgInfolist ;
     Partner_Type__c ProgInfolist1 = new Partner_Type__c(Account__c = child.id,Program__c='SCADA',US_Federal_Specialization__c = 'Authorized');
     insert ProgInfolist1 ;*/
     parentAcc.Partner_Region__c = 'LACR';
     parentAcc.Metal_Level__c = 'Platinum'; 
     Update parentAcc ; 
     parentAcc.Partner_Region__c = 'APAC';
     parentAcc.Metal_Level__c = 'Gold'; 
     Update parentAcc ;     
       
        }
  }