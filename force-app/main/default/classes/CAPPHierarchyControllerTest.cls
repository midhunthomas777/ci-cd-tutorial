/********************************************************************
* Class Name  : CAPPHierarchyControllerTest
* Description:  This is Test Class for CAPPHierarchyController              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -------------------------------------------------------------------------------------------------
*************************************************************************************************/

@isTest
public class CAPPHierarchyControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    @isTest
    public static void testCAPPHierarchy(){  
        
        Test.startTest();
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id accessControlRecordtypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        
        //Create Customer Accounts
        Id customerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(5,customerRecordType);
        
        //Create CAPP Record
        Id CAPPId =  TestDataSetUpUtils.createCAPPs(1, VendorId, accessControlRecordtypeId)[0].Id;
        //Create parent System Relationship
        Id ParentId = TestDataSetUpUtils.createSystemRelations(1,CAPPId,customerAccounts.get(0).Id,null,null)[0].Id;
        //Create child System Relationship
        Id childId = TestDataSetUpUtils.createSystemRelations(1,CAPPId,customerAccounts.get(1).Id,ParentId,null)[0].Id;
        //Create grandChild System Relationship
        Id grandChildId = TestDataSetUpUtils.createSystemRelations(1,CAPPId,customerAccounts.get(2).Id,childId,null)[0].Id;
        //Create grandGrandChild System Relationship
        Id grandGrandChildId = TestDataSetUpUtils.createSystemRelations(1,CAPPId,customerAccounts.get(3).Id,grandChildId,null)[0].Id;
        //Create superGrandChild System Relationship
        Id superGrandChildId = TestDataSetUpUtils.createSystemRelations(1,CAPPId,customerAccounts.get(4).Id,grandGrandChildId,null)[0].Id;
        
        CAPPHierarchyController.SRResponseWrapper srwrapper = CAPPHierarchyController.getData(CAPPId);
        Test.stopTest();
    }
    
}