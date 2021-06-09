@istest
public class NotesandAttachmentControllerTest {
    @testSetup
    static void testSetUp(){
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c tgrSetting = new TriggerSettings__c(Name = 'OpportunityTriggerDisabled', IsActive__c = TRUE);
       insert tgrSetting;
    }
    public static testMethod void addNotes() { 
        Id partnerRecordTypeID =  Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner').RecordTypeId;
        Id ConRecordTypeID =  Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        List<Account> Acclist = TestDataSetUpUtils.createAccounts(1,partnerRecordTypeID);
        Acclist[0].Ispartner = true;
        update Acclist;  
        
        List<contact> Conlist = TestDataSetUpUtils.createContacts(1,ConRecordTypeID,Acclist);
        
        Id custRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> CusAccList = TestDataSetUpUtils.createAccounts(1,custRecordTypeID);
        
        
        Id motoRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        List<Account> MCNAccountList = TestDataSetUpUtils.createMCNAccounts(2,motoRecordTypeID,CusAccList);
        MCNAccountList[0].ERP_Active__c = True;
        update MCNAccountList[0];
        
        /*Id AIRTID = Schema.SObjectType.Account_identifier__c.getRecordTypeInfosByName().get('Prospect/Customer').getRecordTypeId();
        List<Account_identifier__c> AIList = TestDataSetUpUtils.createAIRecords(2,AIRTID,MCNAccountList);
        AIList[0].Route_to_Market__c='MR Led';
        AIList[0].Assigned_MR__c=Acclist[0].Id;
        AIList[1].Route_to_Market__c='MR Led';
        AIList[1].Assigned_MR__c=Acclist[0].Id;
        update AIList;
        */
        
        Profile p = [SELECT Id FROM Profile WHERE Name='EMS Partner Administrator Profile NAMR']; 
        User user = new User(Alias = 'standt', Email='tttstandarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, ContactId=Conlist[0].Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='ssss1tandarduser@testorg.com');
        insert user;      
        AccountShare actsShare = new AccountShare();
        actsShare = new AccountShare(UserOrGroupId=user.Id, AccountId=CusAccList[0].Id, AccountAccessLevel='Edit', opportunityAccessLevel='read', contactAccessLevel='read');
        insert actsShare;
        AccountShare actsShare1= new AccountShare();
        actsShare1= new AccountShare(UserOrGroupId=user.Id, AccountId=MCNAccountList[0].Id, AccountAccessLevel='Edit', opportunityAccessLevel='read', contactAccessLevel='read');
        insert actsShare1;
        AccountShare actsShare2=new AccountShare();
        actsShare2= new AccountShare(UserOrGroupId=user.Id, AccountId=MCNAccountList[1].Id, AccountAccessLevel='Edit', opportunityAccessLevel='read', contactAccessLevel='read');
        insert actsShare2;
        System.runAs(user) {
            Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Opportunity Opplist = new Opportunity();
            Opplist.Name = 'testOppty';
            Opplist.StageName = 'Prospect';
            Opplist.Description='Testing';
            Opplist.closedate = System.today() + 30;                                             
            Opplist.AccountId= CusAccList[0].Id;
            Opplist.Status__c='Active';
            Opplist.recordtypeid = recId;
            Opplist.CDH_Account__c = MCNAccountList[0].Id;
            Opplist.Country__c = 'United States';            
            Opplist.Region__c= 'NA';
            Opplist.State__c = 'Alabama';
            Opplist.Territory__c = 'T1';
            //Test.startTest();
            insert Opplist;
            //Test.stopTest();
            
            Note n = new Note(Title='Test Note', Body =  'Testing...');
            n.Title='Test Update';
            Attachment a  = new Attachment(parentId =Opplist.Id, Body=Blob.valueOf('Unit Test Attachment Body'), Name ='Test', ContentType='application/msword');
            insert a;
            String fileName='TestName';
            String base64Data = 'Unit Test Attachment Body';
            String contentType = 'application/msword';
            String aId = String.valueOf(a.id);
            //NotesAndAttachmentsController.appendToFile(a.Id, base64Data);  
            
            a.Name='';
            n.Title='';
        }
    }   
}