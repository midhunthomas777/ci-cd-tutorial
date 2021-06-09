/*
* Name : GoogleDriveTest
* Author : Adilraza Shaikh
* Date : 6/9/2020
* Description: This test class cover all google drive functionality which mainly include the following classes
* 1. GoogleDriveFolderStructure
* 2. GoogleDriveUtility
* 3. AccountTriggerHandler
* 4. OpportunityTriggerHandler
* 5. OpportunityTeamMemberTriggerHandler
* 6. AccountTeamMemberTriggerHandler
*/
@isTest 
public class GoogleDriveTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.loadGoogleDriveTestData();
        TestDataSetUpUtils.loadGoogleDriveTestDataAP();
    }
    
    @isTest public static void opportunityGoogleDriveTest(){
        Test.startTest();
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity limit 1];
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'create');
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'Update');
        Test.stopTest();

        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id+';'+'testmail@mail.com', 'RevokePermission');
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id+';'+'testmail@mail.com', 'Provision');
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'Delete');
    }
    @isTest public static void opportunityGoogleDriveTestAP(){
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity where Region__c = 'AP' limit 1];
        Test.startTest();
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'create');  
        
        lstOpportunity.get(0).Territory__c = 'AP';
        lstOpportunity.get(0).Country__c = 'Tuvalu';
        lstOpportunity.get(0).State__c ='';
        update lstOpportunity;
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'create');        
        Test.stopTest();
    }
     @isTest public static void opportunityGoogleDriveTestEA(){
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity where Region__c = 'AP' limit 1];        
        Test.startTest();
        lstOpportunity.get(0).Region__c = 'EA';
        lstOpportunity.get(0).Territory__c = 'United Nations'; 
        lstOpportunity.get(0).Country__c = 'Algeria';
        lstOpportunity.get(0).State__c ='';
        update lstOpportunity;
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'create');        
        Test.stopTest();
    }
     @isTest public static void opportunityGoogleDriveTestLA(){
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity where Region__c = 'AP' limit 1];
        Test.startTest();             
        lstOpportunity.get(0).Region__c = 'LA';
        lstOpportunity.get(0).Territory__c = 'Brazil';
        lstOpportunity.get(0).Country__c = 'Brazil';
        lstOpportunity.get(0).State__c ='';
        update lstOpportunity;
        callGetGoogleStructureDataModel(lstOpportunity.get(0).Id, 'create'); 
        Test.stopTest();
    }
    @isTest public static void opportunityTeamMemberGoogleDriveTest(){
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity limit 1];
        List<OpportunityTeamMember> lstOTM = new List<OpportunityTeamMember>();
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.opportunityId = lstOpportunity.get(0).Id;
        otm.UserId = System.label.Salesforce_Operations_User_Id;
        otm.OpportunityAccessLevel = 'Read';
		otm.TeamMemberRole = 'CAM'; 
        lstOTM.add(otm);
        OpportunityTeamMember otm1 = new OpportunityTeamMember();
        otm1.opportunityId = lstOpportunity.get(0).Id;
        otm1.UserId = System.label.Salesforce_Operations_User_Id;
        otm1.OpportunityAccessLevel = 'Edit';
		otm1.TeamMemberRole = 'CAM'; 
        lstOTM.add(otm1);
        Test.startTest();
        insert lstOTM;
        callGetGoogleStructureDataModel(lstOTM.get(0).Id+';'+lstOpportunity.get(0).Id, 'create');
        OpportunityTeamMember otmUpdate = lstOTM.get(0);
        otmUpdate.OpportunityAccessLevel = 'Edit';
        update otmUpdate;
        
        Opportunity oppOwnerChange = lstOpportunity.get(0);
        oppOwnerChange.ownerId = System.label.Salesforce_Operations_User_Id;
        update oppOwnerChange;
        Test.stopTest();
        delete otmUpdate;
    }
    @isTest public static void accountGoogleDriveTest(){
        List<Account> lstAccount = [SELECT Id,Owner.Email,Owner_Email__c FROM Account limit 1];
        Account accUpdate = lstAccount.get(0);
        accUpdate.Name = 'updateGriveAcc';
        accUpdate.OwnerId = System.label.Salesforce_Operations_User_Id;
        update accUpdate;
        callGetGoogleStructureDataModel(lstAccount.get(0).Id, 'Update');
        Test.startTest();
        callGetGoogleStructureDataModel(lstAccount.get(0).Id+';'+'testmail@mail.com', 'RevokePermission');
        callGetGoogleStructureDataModel(lstAccount.get(0).Id+';'+'testmail@mail.com', 'Provision');
        
        callGetGoogleStructureDataModel(lstAccount.get(0).Id, 'Delete');
        Test.stopTest();
    }
    @isTest public static void accountTeamMemberGoogleDriveTest(){
        List<Account> lstAccount = [SELECT Id,Owner.Email,Owner_Email__c FROM Account limit 1];
        List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = lstAccount.get(0).Id;
        atm.UserId = System.label.Salesforce_Operations_User_Id;
        atm.AccountAccessLevel = 'Read';
		atm.TeamMemberRole = 'CAM'; 
        atm.Quote_Access__c = 'Read/Write';
        lstATM.add(atm);
        AccountTeamMember otm1 = new AccountTeamMember();
        otm1.AccountId = lstAccount.get(0).Id;
        otm1.UserId = System.label.Salesforce_Operations_User_Id;
        otm1.AccountAccessLevel = 'Edit';
		otm1.TeamMemberRole = 'CAM'; 
        otm1.Quote_Access__c = 'Read/Write';
        lstATM.add(otm1);
        Test.startTest();
        insert lstATM;
        callGetGoogleStructureDataModel(lstATM.get(0).Id+';'+lstAccount.get(0).Id, 'create');
        AccountTeamMember atmUpdate = lstATM.get(0);
        atmUpdate.AccountAccessLevel = 'Edit';
        update atmUpdate;
        Account accOwnerChange = lstAccount.get(0);
        accOwnerChange.ownerId = System.label.Salesforce_Operations_User_Id;
        update accOwnerChange;
        Test.stopTest();
        //delete atmUpdate;
    }
    @isTest public static void quoteGoogleDriveTest(){
        Id siteID = TestDataSetUpUtils.createSite();
        List<Account> lstAccount = [SELECT Id,Owner.Email,Owner_Email__c FROM Account limit 2];
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity limit 2];
        List<BigMachines__Quote__c> lstQuote = new List<BigMachines__Quote__c>();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Account__c=lstAccount.get(0).Id;
        objQuote.Name='testQuote';
        objQuote.BigMachines__Site__c=siteID;
        objQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
        objQuote.BigMachines__Transaction_Id__c='12345';
        objQuote.MR_ID__c='1234';
        objQuote.IsFinalizedQuoteSubmitted__c=true;
        objQuote.QuotePDFFile__c='true';
        objQuote.SendFilestoFinancialFolder__c=false;
        lstQuote.add(objQuote);
        
        BigMachines__Quote__c objQuoteAcc = new BigMachines__Quote__c();
        objQuoteAcc.BigMachines__Account__c=lstAccount.get(1).Id;
        objQuoteAcc.Name='testQuote';
        objQuoteAcc.BigMachines__Site__c=siteID;
        objQuoteAcc.BigMachines__Transaction_Id__c='1234565';
        objQuoteAcc.MR_ID__c='123435';
        objQuoteAcc.IsFinalizedQuoteSubmitted__c=true;
        objQuoteAcc.QuotePDFFile__c='true';
        objQuoteAcc.SendFilestoFinancialFolder__c=false;
        lstQuote.add(objQuoteAcc);        
        
        BigMachines__Quote__c objQuoteOpp = new BigMachines__Quote__c();
        objQuoteOpp.BigMachines__Account__c=lstAccount.get(0).Id;
        objQuoteOpp.Name='testQuote';
        objQuoteOpp.BigMachines__Site__c=siteID;
        objQuoteOpp.BigMachines__Opportunity__c=lstOpportunity.get(1).Id;
        objQuoteOpp.BigMachines__Transaction_Id__c='1234532';
        objQuoteOpp.MR_ID__c='1234111';
        objQuoteOpp.IsFinalizedQuoteSubmitted__c=true;
        objQuoteOpp.QuotePDFFile__c='true';
        objQuoteOpp.SendFilestoFinancialFolder__c=false;
        lstQuote.add(objQuoteOpp);
        Test.startTest();
        insert lstQuote;
        callGetGoogleStructureDataModel(objQuote.Id, 'QuoteFiles');
        Attachment attachment = new Attachment( ParentId = lstQuote.get(0).Id,Name = 'myAttachment.pdf',Body = Blob.valueOf('test'));
        attachment.ContentType = NULL;
       
        insert attachment;
        ContentVersion contentVersion = GlobalUtility.createContentVersion('Test Doc',EncodingUtil.base64Decode('body'));
        insert contentVersion;
        List<contentVersion> lstContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];
     	ContentDocumentLink contentDocumentLink = GlobalUtility.createContentDocumentLink(lstContentVersions.get(0).contentDocumentId,
                                                                                         lstQuote.get(0).Id,'I','InternalUsers');
        
       	insert contentDocumentLink;
        callGetGoogleStructureDataModel(lstQuote.get(0).Id, 'QuoteFiles');         //Opportunity with existing Google Drive Folder
        
        callGetGoogleStructureDataModel(lstQuote.get(1).Id, 'QuoteFiles');  //Account with Non existing Google Drive Folder
        callGetGoogleStructureDataModel(lstQuote.get(2).Id, 'QuoteFiles');
        Test.stopTest();
    }
    @isTest public static void quickCheckForDriveTest(){
        Id siteID = TestDataSetUpUtils.createSite();
        List<Account> lstAccount = [SELECT Id,Owner.Email,Owner_Email__c FROM Account limit 2];
        List<Opportunity> lstOpportunity = [SELECT Id,Owner.Email,Owner_Email__c FROM Opportunity limit 2];
        Test.startTest();
        GoogleDriveUtility.quickCheckForDrive(lstOpportunity.get(0).Id,true);
        Test.stopTest();
        GoogleDriveUtility.quickCheckForDrive(lstOpportunity.get(0).Id,false);
    }
    public static void callGetGoogleStructureDataModel(String recordId, String action){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =URL.getSalesforceBaseUrl()+'/services/apexrest/getGoogleFolderStructure';
        request.params.put('id', recordId);
        request.params.put('action', action);
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = res;
        GoogleDriveFolderStructure.getGoogleStructureDataModel(); 
    }
}