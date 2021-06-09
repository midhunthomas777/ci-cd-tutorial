@IsTest
public class DownloadAllCaseAttachmentControllerTest {

   @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
     static List<Account> createAccounts(){        
        //RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account accnt1 = new Account(name='cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=accrectypeID;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'Grant Park';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'Yuma';       
        accnt1.Territory__c = '';
        acclist.add(accnt1);
        insert acclist;
        return acclist;
    }
     public static testMethod void TestDownloadAllCaseAttachmentControllerPV()
     {
         
        // Case Creation
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = DownloadAllCaseAttachmentControllerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        
        
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);        
        
        insert CSList;
                
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = CSList[0].id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;   
        
        String downloadURLresult = DownloadAllCaseAttachmentController.getInitialValue(CSList[0].id);
        System.debug(downloadURLresult);
             
     }
     
     
     public static testMethod void TestDownloadAllCaseAttachmentControllerNE()
     {
         
        // Case Creation
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        //CaseTriggerTest.inactiveTriggers();
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = DownloadAllCaseAttachmentControllerTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        
        
        Case cs2 = new case();
        cs2.Accountid = accountList[0].id;
        cs2.RecordTypeId = rectcsid;
        cs2.Status = 'New';
        cs2.ASM_Approval_Status__c = 'In Approval';
        cs2.Assigned_ASM__c=CAMuser.id;
        cs2.Hidden_CAM__c=Hiddenuser.id;
        CSList.add(cs2);        
        
        insert CSList;
        
        String downloadURLresult = DownloadAllCaseAttachmentController.getInitialValue(CSList[0].id);
         System.debug(downloadURLresult);
             
     }
    
}