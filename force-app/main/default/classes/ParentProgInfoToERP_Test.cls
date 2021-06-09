@isTest
/*
* File Name  : ParentProgInfoToERP_Test
* Description: This class is to unit test code for the trigger: ParentProgInfoToERP
* Author     : vivek Pokharia
* 

*/ 
private class ParentProgInfoToERP_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    public static testMethod void testParentProgInfoToERP(){
        RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        // Create an Account
        Account acc = new Account();
        acc.Name = 'Test Parent';
        acc.RecordTypeId = theRecordType.id;
        acc.BillingStreet = '1110 E Algonquin Rd';
        acc.BillingState='Illinois';
        acc.BillingCity = 'Schaumburg';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '60173';
        acc.Motorola_Customer_Number__c = '123456789';
        acc.Role_Created__c = true;
        acc.Industry = 'Manufacturing';
        acc.Region__c = 'NA';
        acc.Partner_Region__c = 'NAMR';
        acc.Hierarchy_Placement__c='ERP Account';
        acc.Territory__c = 'T2';
        acc.Metal_Level__c = 'Authorized';
        acc.Type='Motorola Entity';
        // acc.parentid=null;
        insert acc;
        
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1,theRecordType.id);
        acclist[0].parentid=acc.id;
        update acclist[0];
        acclist.add(acc);
        List<Partner_Type__c> PROGRAMLISTlist =TestDataSetUpUtils.createProgramInfoRecords(1,acclist);
        list<Partner_Type__c>plist=new list<Partner_Type__c>();
        for(Partner_Type__c partner:PROGRAMLISTlist){
            partner.Purchasing_Method__c='tier 14';
            partner.US_Federal__c=false;
            partner.RHO__c=false;
            plist.add(partner);
        }
        update plist;
    }
    
    
}