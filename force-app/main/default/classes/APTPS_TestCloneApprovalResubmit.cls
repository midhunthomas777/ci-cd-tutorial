@istest 
public class APTPS_TestCloneApprovalResubmit
{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testmethod void mytest() {
        RecordType accrtdType =[Select Id from RecordType where (DeveloperName='Prospect') and SobjectType='Account' limit 1]; // Added by harish
        list<Account> acct = testdatasetupUtils.createAccounts(2, accrtdType.id);
        Contact contact = new Contact();
        contact.AccountID = acct[0].Id; 
        contact.FirstName='FirstName'; 
        contact.LastName='Testing Contact';
        contact.Title='Manager';
        contact.Email='apttus_flexera_test@test.com';
        
        insert contact;
        
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = new User ();
        user1.FirstName = 'Test'; 
        user1.LastName = 'User1'; 
        user1.Username = 'TestUser1Subu@apttus.com';
        user1.Email =  'TestUser1Subu@apttus.com';
        user1.Alias = 'TestUsr1';
        user1.TimeZoneSidKey = 'America/Los_Angeles'; 
        user1.LocaleSidKey = 'en_US'; 
        user1.EmailEncodingKey = 'UTF-8'; 
        user1.ProfileId = p.id;
        user1.Primary_Business_Group__c ='Government'; 
        user1.LanguageLocaleKey ='en_US';
        
        insert user1;  
        RecordType oppRecordType =[Select Id from RecordType where (DeveloperName='Government_standard') and SobjectType='Opportunity' limit 1]; // Added by harish
        List<opportunity> opp = testdatasetupUtils.createOpportunities(2, oppRecordType.id, acct);
        Apttus__APTS_Admin__c newadmin = new Apttus__APTS_Admin__c();
        newadmin.Name ='APTS_SummaryOutputConfig';
        newadmin.Apttus__Value__c = 'true';
        newadmin.Apttus__Code__c ='Apttus__Agreement_Document__c,Apttus__Agreement__c,Attachment,parentid,Apttus_Approval__Approval_Request__c,Apttus_Approval__Related_Agreement__c';
        insert newadmin;                
        Apttus__APTS_Agreement__c parentagrmt=new Apttus__APTS_Agreement__c(Apttus__Related_Opportunity__c=opp[0].Id);
        parentagrmt.Name='TestAgrmt';
        parentagrmt.Agreement_Type__c='Sales Contract (Master Agreement)';
        parentagrmt.Project_Type__c='Budgetary';
        parentagrmt.Proposal_Due_Date__c=date.today();
        parentagrmt.Apttus__Primary_Contact__c=contact.Id;
        parentagrmt.Apttus__Status_Category__c='Request';
        parentagrmt.Apttus__Status__c='Request Submitted';
        parentagrmt.Apttus_Approval__Approval_Status__c='Rejected';
        parentagrmt.OwnerId=user1.Id; 
        
        insert parentagrmt;
        test.startTest();      
        pageReference currPage = Page.APTPS_ResubmitApprovals;
        Test.setCurrentPageReference(currPage);
        ApexPages.StandardController cont = new ApexPages.Standardcontroller(parentagrmt);    
        APTPS_CloneApprovalResubmit testController = new APTPS_CloneApprovalResubmit(cont);
        testController.cloneagreement();
 
        
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.Description='testing';
        attach.parentid=parentagrmt.Id;
        
        insert attach;
        
        
        /*Additional_Contracting_Parties__c contract=new Additional_Contracting_Parties__c();
contract.Agreement__c=parentagrmt.Id;
insert contract;*/
        //test.startTest();
        Apttus__Agreement_Document__c document=new Apttus__Agreement_Document__c();
        document.Name='testdoc';
        document.Apttus__Comments__c='formatdoc';
        document.Apttus__URL__c='http://apttus.com';
        document.Apttus__Agreement__c= parentagrmt.Id;
        document.Apttus__Path__c='http://apttus.com';
        insert  document;
        
        
        APTPS_CloneApprovalResubmittedAgreement classinstance=new APTPS_CloneApprovalResubmittedAgreement();
        classinstance.mainmethod(parentagrmt.Id);
        
        parentagrmt.Apttus__Status__c = 'Request Submitted';
        parentagrmt.Apttus__Status_Category__c='Request';
        parentagrmt.Apttus_Approval__Approval_Status__c='Not Submitted';
        
        update parentagrmt;
        
        
        
        Apttus__APTS_Agreement__c snpshtagrmt=new Apttus__APTS_Agreement__c(Apttus__Related_Opportunity__c=opp[0].Id);
        snpshtagrmt.Name='APRVL SNPSHOT- TestAgrmt'; 
        snpshtagrmt.Agreement_Type__c='Sales Contract (Master Agreement)';
        snpshtagrmt.Project_Type__c='Budgetary';
        snpshtagrmt.Proposal_Due_Date__c=date.today();
        snpshtagrmt.Apttus__Primary_Contact__c=contact.Id;
        snpshtagrmt.Apttus__Status_Category__c='Previously Approved';
        snpshtagrmt.Apttus__Status__c='Previously Approved';
        snpshtagrmt.Apttus_Approval__Approval_Status__c='Rejected';
        snpshtagrmt.OwnerId=user1.Id; 
        
        insert snpshtagrmt;
        
        
        
        Attachment attach2=new Attachment();
        attach2.Name='Unit Test Attachment';
        Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
        attach2.body=bodyBlob2;
        attach2.Description='testing';
        attach2.parentid=snpshtagrmt.Id;
        
        insert attach2;
        
        
        
        /*Additional_Contracting_Parties__c contract2=new Additional_Contracting_Parties__c();

contract2.Agreement__c=snpshtagrmt.Id;

insert contract2;*/
        
        Apttus__Agreement_Document__c document2=new Apttus__Agreement_Document__c();
        document2.Name='testdoc';
        document2.Apttus__Comments__c='formatdoc';
        document2.Apttus__URL__c='http://apttus.com';
        document2.Apttus__Agreement__c= snpshtagrmt.Id;
        document2.Apttus__Path__c='http://apttus.com';
        insert  document2;
        
        Apttus__APTS_Related_Agreement__c newRelatedAgreement = new Apttus__APTS_Related_Agreement__c();
        newRelatedAgreement.Apttus__APTS_Contract_From__c=parentagrmt.Id;
        newRelatedAgreement.Apttus__APTS_Contract_To__c =snpshtagrmt.Id;
        
        insert newRelatedAgreement;
        test.stopTest();
    }
}